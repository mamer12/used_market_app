---
name: luqta-go-backend
description: Go backend development skill for Luqta — the Iraqi super-app e-commerce OS. Use when building any API handler, service, repository, worker, FSM, WebSocket hub, or database migration for Luqta. Enforces Hexagonal Clean Architecture, the Escrow FSM, COD commission freeze logic, RabbitMQ async workers, Redis pub/sub for auctions, and ZainCash integration patterns.
---

# Luqta Go Backend Skill

You are building the backend of **Luqta** — the Operating System for Iraqi Commerce. This is a Go backend with Hexagonal Clean Architecture, a PostgreSQL relational core, RabbitMQ for async events, Redis for caching and WebSocket pub/sub, and a mission-critical Escrow Finite State Machine.

---

## 🏗️ Hexagonal Clean Architecture

```
luqta-backend/
├── cmd/
│   ├── api/          # HTTP server entrypoint
│   └── worker/       # RabbitMQ consumer entrypoint
├── internal/
│   ├── domain/       # Pure business logic — NO framework imports
│   │   ├── escrow/
│   │   ├── auction/
│   │   ├── wallet/
│   │   ├── order/
│   │   └── user/
│   ├── application/  # Use cases / services
│   ├── ports/        # Interfaces (driven & driving)
│   │   ├── inbound/  # HTTP handlers, WS handlers, consumers
│   │   └── outbound/ # DB repos, ZainCash client, SMS, push
│   └── adapters/     # Concrete implementations
│       ├── postgres/
│       ├── redis/
│       ├── rabbitmq/
│       └── zaincash/
└── pkg/              # Shared utilities (logger, errors, pagination)
```

**The golden rule:** `domain/` must have ZERO imports from `adapters/`. Domain only depends on standard library and `ports/` interfaces.

---

## 🛡️ The Escrow FSM (Most Critical System)

The Escrow FSM is Luqta's core trust layer. Every state transition must be atomic and logged.

### States & Transitions

```go
type EscrowState string

const (
    EscrowIdle      EscrowState = "idle"       // Order created, awaiting payment
    EscrowLocked    EscrowState = "locked"     // ZainCash payment confirmed, funds held
    EscrowShipped   EscrowState = "shipped"    // Seller marked as shipped
    EscrowDelivered EscrowState = "delivered"  // Buyer confirmed delivery
    EscrowReleased  EscrowState = "released"   // Funds sent to seller wallet
    EscrowDisputed  EscrowState = "disputed"   // Buyer opened dispute
    EscrowRefunded  EscrowState = "refunded"   // Admin forced refund to buyer
)

// Valid transitions — ENFORCE these strictly
var validTransitions = map[EscrowState][]EscrowState{
    EscrowIdle:      {EscrowLocked},
    EscrowLocked:    {EscrowShipped, EscrowRefunded},
    EscrowShipped:   {EscrowDelivered, EscrowDisputed},
    EscrowDelivered: {EscrowReleased},
    EscrowDisputed:  {EscrowReleased, EscrowRefunded}, // Admin resolves
    // released and refunded are terminal — no exits
}

func (e *EscrowService) Transition(ctx context.Context, escrowID string, to EscrowState, actorID string) error {
    escrow, err := e.repo.LockForUpdate(ctx, escrowID) // SELECT FOR UPDATE
    if err != nil { return err }

    allowed := validTransitions[escrow.State]
    for _, s := range allowed {
        if s == to { goto valid }
    }
    return ErrInvalidEscrowTransition{From: escrow.State, To: to}

valid:
    escrow.State = to
    escrow.UpdatedAt = time.Now()

    if err := e.repo.Save(ctx, escrow); err != nil { return err }

    // Always publish state change event
    e.publisher.Publish(ctx, "escrow.state_changed", EscrowEvent{
        EscrowID: escrowID,
        From:     escrow.State,
        To:       to,
        ActorID:  actorID,
        At:       time.Now(),
    })

    // On release: transfer funds to seller wallet
    if to == EscrowReleased {
        return e.walletService.Transfer(ctx, LuqtaHoldAccountID, escrow.SellerID, escrow.SellerAmount)
    }

    // On refund: return funds to buyer wallet
    if to == EscrowRefunded {
        return e.walletService.Transfer(ctx, LuqtaHoldAccountID, escrow.BuyerID, escrow.BuyerAmount)
    }

    return nil
}
```

### COD Commission Freeze (Genius Logic)

```go
// When seller ACCEPTS a COD order:
func (s *OrderService) AcceptCODOrder(ctx context.Context, orderID string, sellerID string) error {
    order, err := s.orderRepo.Get(ctx, orderID)
    if err != nil { return err }
    if order.PaymentMethod != PaymentCOD { return ErrNotCODOrder }

    commission := order.TotalAmount * LuqtaCommissionRate // 0.03

    // Freeze commission from seller's existing digital wallet
    if err := s.walletService.Freeze(ctx, sellerID, commission, FreezeReasonCODCommission, orderID); err != nil {
        return fmt.Errorf("cannot accept COD: seller wallet insufficient for commission: %w", err)
    }

    order.Status = OrderAccepted
    order.CommissionFrozen = commission
    return s.orderRepo.Save(ctx, order)
}

// When COD delivery is confirmed (by delivery webhook or admin):
func (s *OrderService) ConfirmCODDelivery(ctx context.Context, orderID string) error {
    order, _ := s.orderRepo.Get(ctx, orderID)
    // Release the frozen commission — Luqta keeps it
    return s.walletService.ReleaseFrozen(ctx, order.SellerID, order.CommissionFrozen, orderID)
}
```

---

## 🔥 Auction System (Mazadat)

### WebSocket Hub

```go
type AuctionHub struct {
    redis       *redis.Client
    rooms       sync.Map // auctionID -> *Room
}

type Room struct {
    auctionID   string
    clients     sync.Map // connID -> *Client
    broadcast   chan []byte
}

// Subscribe to Redis pub/sub channel for this auction
func (h *AuctionHub) Subscribe(auctionID string) {
    pubsub := h.redis.Subscribe(ctx, "auction:"+auctionID)
    go func() {
        for msg := range pubsub.Channel() {
            room, _ := h.rooms.Load(auctionID)
            room.(*Room).broadcast <- []byte(msg.Payload)
        }
    }()
}

// Publish a bid event — all connected clients receive it via Redis pub/sub
func (h *AuctionHub) PublishBid(ctx context.Context, auctionID string, bid Bid) error {
    payload, _ := json.Marshal(BidEvent{
        Type:        "new_bid",
        AuctionID:   auctionID,
        BidderID:    bid.BidderID,
        Amount:      bid.Amount,
        Remaining:   bid.AuctionRemainingSeconds,
    })
    return h.redis.Publish(ctx, "auction:"+auctionID, payload).Err()
}
```

### Auction Close Worker (RabbitMQ)

```go
// Background Go worker — consumes "auction.close" queue
func (w *AuctionCloseWorker) Handle(ctx context.Context, msg amqp.Delivery) error {
    var event AuctionCloseEvent
    json.Unmarshal(msg.Body, &event)

    auction, _ := w.auctionRepo.Get(ctx, event.AuctionID)
    if len(auction.Bids) == 0 {
        return w.auctionRepo.SetStatus(ctx, event.AuctionID, AuctionNoBids)
    }

    winner := auction.Bids[0] // highest bid

    // Generate invoice for winner
    invoice := Invoice{
        BuyerID:   winner.BidderID,
        SellerID:  auction.SellerID,
        Amount:    winner.Amount,
        AuctionID: auction.ID,
        ExpiresAt: time.Now().Add(24 * time.Hour), // 24h to pay
        PaymentMethods: []PaymentMethod{PaymentZainCash, PaymentWallet}, // NO COD
    }
    w.invoiceRepo.Create(ctx, invoice)

    // Send push notification to winner
    w.notifier.Push(ctx, winner.BidderID, PushNotification{
        Title: "🏆 لقد فزت بالمزاد!",
        Body:  fmt.Sprintf("لديك 24 ساعة للدفع: %s د.ع", formatIQD(winner.Amount)),
        Data:  map[string]string{"invoiceID": invoice.ID},
    })

    // If winner ghosts after 24h — separate worker fires "Second Chance Offer"
    w.scheduler.ScheduleAt(ctx, time.Now().Add(24*time.Hour), "auction.ghost_check", event.AuctionID)

    return nil
}

// Ghost check worker
func (w *GhostCheckWorker) Handle(ctx context.Context, msg amqp.Delivery) error {
    auctionID := string(msg.Body)
    invoice, _ := w.invoiceRepo.GetByAuction(ctx, auctionID)

    if invoice.Status != InvoicePaid {
        // Strike the winner
        w.userService.AddStrike(ctx, invoice.BuyerID)

        // Fire Second Chance Offer to runner-up
        auction, _ := w.auctionRepo.Get(ctx, auctionID)
        if len(auction.Bids) > 1 {
            runnerUp := auction.Bids[1]
            w.notifier.Push(ctx, runnerUp.BidderID, PushNotification{
                Title: "🎯 عرض فرصة ثانية!",
                Body:  "الفائز الأول لم يدفع. هل تريد الشراء بسعرك؟",
            })
        }
    }
    return nil
}
```

---

## 💳 ZainCash Integration

```go
type ZainCashClient struct {
    merchantID string
    secret     string
    baseURL    string // https://api.zaincash.iq
}

// Initiate payment — returns redirect URL for user
func (z *ZainCashClient) InitiatePayment(ctx context.Context, req PaymentRequest) (*PaymentResponse, error) {
    // ZainCash uses JWT-signed requests
    claims := jwt.MapClaims{
        "amount":      req.Amount,
        "serviceType": req.ServiceType,
        "msisdn":      req.PhoneNumber,
        "orderId":     req.OrderID,
        "redirectUrl": req.CallbackURL,
        "iat":         time.Now().Unix(),
        "exp":         time.Now().Add(1 * time.Hour).Unix(),
    }
    token, _ := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(z.secret))

    // POST to ZainCash, get back transaction URL
    // ...
}

// Webhook handler — ZainCash posts here on payment completion
func (h *ZainCashWebhookHandler) Handle(w http.ResponseWriter, r *http.Request) {
    // 1. Verify JWT signature from ZainCash
    // 2. Extract orderID and status
    // 3. If status == "success": trigger EscrowService.Transition(ctx, escrowID, EscrowLocked, "zaincash")
    // 4. Publish "payment.confirmed" to RabbitMQ
    // 5. Respond 200 OK immediately (ZainCash retries on non-200)
}
```

---

## 🗄️ Key Database Patterns

### Always Use SELECT FOR UPDATE on Financial Operations

```go
// Any wallet debit, freeze, or escrow transition:
func (r *WalletRepo) DebitWithLock(ctx context.Context, tx pgx.Tx, walletID string, amount int64) error {
    var balance int64
    err := tx.QueryRow(ctx,
        `SELECT balance FROM wallets WHERE id = $1 FOR UPDATE`,
        walletID,
    ).Scan(&balance)

    if balance < amount {
        return ErrInsufficientBalance
    }

    _, err = tx.Exec(ctx,
        `UPDATE wallets SET balance = balance - $1, updated_at = NOW() WHERE id = $2`,
        amount, walletID,
    )
    return err
}
```

### Key Tables

```sql
-- Escrow table
CREATE TABLE escrows (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID NOT NULL REFERENCES orders(id),
    buyer_id        UUID NOT NULL REFERENCES users(id),
    seller_id       UUID NOT NULL REFERENCES users(id),
    total_amount    BIGINT NOT NULL,           -- in IQD fils (smallest unit)
    seller_amount   BIGINT NOT NULL,           -- total - commission
    commission      BIGINT NOT NULL,
    state           TEXT NOT NULL DEFAULT 'idle',
    payment_method  TEXT NOT NULL,             -- 'zaincash' | 'wallet' | 'cod'
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Wallet freeze ledger
CREATE TABLE wallet_freezes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id   UUID NOT NULL REFERENCES wallets(id),
    amount      BIGINT NOT NULL,
    reason      TEXT NOT NULL,               -- 'cod_commission' | 'auction_hold'
    ref_id      UUID,                        -- order_id or auction_id
    released_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Auction bids
CREATE TABLE bids (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_id  UUID NOT NULL REFERENCES auctions(id),
    bidder_id   UUID NOT NULL REFERENCES users(id),
    amount      BIGINT NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    INDEX idx_bids_auction_amount (auction_id, amount DESC)
);

-- User strikes (for auction ghosts)
CREATE TABLE user_strikes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    reason      TEXT NOT NULL,
    ref_id      UUID,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
-- 3 strikes within 90 days = auto-ban via trigger or worker
```

---

## 📨 RabbitMQ Queue Registry

```go
// All queues — define as constants
const (
    QueueAuctionClose       = "auction.close"        // Fired when timer hits 0
    QueueAuctionGhostCheck  = "auction.ghost_check"  // Fired 24h after winner invoice
    QueuePaymentConfirmed   = "payment.confirmed"    // Fired by ZainCash webhook
    QueueEscrowReleased     = "escrow.released"      // Trigger seller wallet credit
    QueuePushNotification   = "push.notification"    // Fan-out to FCM/APNs
    QueueWithdrawalRequest  = "withdrawal.request"   // Manual ops queue
    QueueDisputeOpened      = "dispute.opened"       // Alert admin CMS
)
```

---

## 🔒 Business Rules to Enforce

| Rule | Where to Enforce |
|------|-----------------|
| No COD on Mazadat (auctions) | Invoice creation — reject if `paymentMethod == COD` |
| 3 strikes = ban | `UserService.AddStrike()` — check count and call `BanUser()` |
| Seller must have wallet balance ≥ 3% commission to accept COD | `AcceptCODOrder()` |
| Auction bids must be strictly greater than current highest | `PlaceBid()` domain validation |
| Mustamal orders never enter Escrow | Route guard — Mustamal has no checkout flow |
| Withdrawal only from Released escrows | `WithdrawalService` checks escrow state |

---

## 🚫 Never Do

- Never mutate wallet balance without `SELECT FOR UPDATE` inside a transaction
- Never allow direct `EscrowState` writes — always go through `EscrowService.Transition()`
- Never process ZainCash webhooks without verifying the JWT signature
- Never allow COD payment method on auction invoices
- Never call external services (ZainCash, SMS) inside a database transaction
- Never store amounts as floats — always use `BIGINT` in IQD fils

## ✅ Always Do

- Use `SELECT FOR UPDATE` on all financial row reads
- Publish a RabbitMQ event after every state change
- Log every Escrow FSM transition with actor, timestamp, and reason
- Return Arabic-friendly error messages in API responses (`message_ar` field)
- Validate bid amount > current highest bid in domain layer, not HTTP layer
- Schedule ghost-check jobs immediately when winner invoice is created
- Handle ZainCash webhook idempotently (same payment can arrive twice)
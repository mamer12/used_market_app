# Lugta API — Mobile Integration Guide

**Base URL:** `http://<host>:8080/api/v1`  
**Interactive Docs:** `http://<host>:8080/swagger/`  
**Protocol:** REST / JSON + WebSocket for real-time bidding

---

## Table of Contents

1. [Response Envelope](#1-response-envelope)
2. [Authentication](#2-authentication)
3. [Users](#3-users)
4. [Shops & Products](#4-shops--products)
5. [Auctions](#5-auctions)
6. [Cart](#6-cart)
7. [Saved Items (Wishlist)](#7-saved-items-wishlist)
8. [Orders & Escrow](#8-orders--escrow)
9. [Media Uploads](#9-media-uploads)
10. [Real-Time Bidding (WebSocket)](#10-real-time-bidding-websocket)
11. [Money Fields](#11-money-fields)
12. [Error Handling](#12-error-handling)
13. [Search](#13-search)
14. [Invoices](#14-invoices)

---

## 1. Response Envelope

Every response follows the same wrapper:

```json
// Success
{
  "success": true,
  "message": "ok",
  "data": { ... }
}

// Error
{
  "success": false,
  "error": "human-readable message"
}
```

---

## 2. Authentication

All protected endpoints require a **Bearer token** in the `Authorization` header:

```
Authorization: Bearer <token>
```

The token is returned by any login or register endpoint. It is a **JWT** valid for **72 hours** by default.

### 2.1 Register with Password

```
POST /auth/register
```

```json
// Request
{
  "full_name": "Ahmed Ali",
  "phone_number": "+9647701234567",
  "password": "securePass123"
}

// Response 201
{
  "success": true,
  "data": {
    "token": "<jwt>",
    "user": {
      "id": "uuid",
      "full_name": "Ahmed Ali",
      "phone_number": "+9647701234567",
      "role": "user",
      "is_verified": false,
      "created_at": "2026-02-21T12:00:00Z",
      "updated_at": "2026-02-21T12:00:00Z"
    }
  }
}
```

> `phone_number` must be in **E.164 format** — e.g. `+9647701234567`.

### 2.2 Login with Password

```
POST /auth/login
```

```json
// Request
{
  "phone_number": "+9647701234567",
  "password": "securePass123"
}

// Response 200 — same shape as register
```

### 2.3 OTP Flow (Passwordless)

**Step 1 — Request OTP**

```
POST /auth/otp/send
```

```json
{ "phone_number": "+9647701234567" }
```

Returns `200 { "success": true, "data": { "message": "otp sent" } }`.  
The OTP is a **6-digit code** delivered via SMS.

**Step 2a — Login with OTP** (existing user)

```
POST /auth/otp/login
```

```json
{
  "phone_number": "+9647701234567",
  "otp": "482910"
}
// Response 200 → token + user
```

**Step 2b — Register with OTP** (new user)

```
POST /auth/otp/register
```

```json
{
  "full_name": "Ahmed Ali",
  "phone_number": "+9647701234567",
  "otp": "482910"
}
// Response 201 → token + user
```

### 2.4 Token Storage Recommendation

Store the token in **secure storage** (iOS Keychain / Android EncryptedSharedPreferences). Refresh by re-logging in when a `401` is received.

---

## 3. Users

### Get Current User

```
GET /users/me
Authorization: Bearer <token>
```

```json
// Response 200
{
  "success": true,
  "data": {
    "id": "uuid",
    "full_name": "Ahmed Ali",
    "phone_number": "+9647701234567",
    "role": "user",
    "avatar_url": "",
    "is_verified": false,
    "created_at": "...",
    "updated_at": "..."
  }
}
```

### 3.2 Update User Profile

```
PATCH /users/me
Authorization: Bearer <token>
```

```json
// Request
{
  "full_name": "Ahmed Ali 2",
  "avatar_url": "https://..."
}

// Response 200
{
  "success": true,
  "data": {
    "id": "uuid",
    "full_name": "Ahmed Ali 2",
    "phone_number": "+9647701234567",
    "role": "user",
    "avatar_url": "https://...",
    "is_verified": false,
    "created_at": "...",
    "updated_at": "..."
  }
}
```

---

## 4. Shops & Products

### 4.1 List All Shops

```
GET /shops?page=1&limit=20
GET /shops?category=electronics&page=1&limit=20
```

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "owner_id": "uuid",
      "name": "Baghdad Electronics",
      "slug": "baghdad-electronics",
      "description": "Best electronics in Iraq",
      "category": "electronics",
      "contact_number": "+9647701234567",
      "location_city": "Baghdad",
      "location_district": "Karrada",
      "location_address": "Al-Nidal St., Building 12",
      "image_url": "https://minio.lugta.com/lugta/uploads/shop-cover.jpg",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

> Pass `?category=<value>` to filter. Omit it to get all shops.

### 4.2 Get Shop Catalog (Shop + Products)

```
GET /shops/{slug}/products?page=1&limit=20
GET /shops/{slug}/products?category=phones&page=1&limit=20
```

```json
// Response 200
{
  "success": true,
  "data": {
    "shop": {
      "id": "uuid",
      "name": "Baghdad Electronics",
      "category": "electronics",
      "contact_number": "+9647701234567",
      "location_city": "Baghdad",
      "location_district": "Karrada",
      "location_address": "Al-Nidal St., Building 12",
      "image_url": "https://minio.lugta.com/lugta/uploads/shop-cover.jpg"
    },
    "products": [
      {
        "id": "uuid",
        "shop_id": "uuid",
        "title": "Samsung Galaxy S24",
        "description": "Brand new",
        "category": "phones",
        "price": "850000",
        "stock_quantity": 5,
        "sku": "SAM-S24-BLK",
        "images": ["https://..."],
        "is_active": true,
        "created_at": "...",
        "updated_at": "..."
      }
    ]
  }
}
```

> `?category=` filters **products within the shop**, not the shop itself.  
> `price` is returned as a **string** — see [§11 Money Fields](#11-money-fields).

### 4.3 Create a Shop *(seller)*

```
POST /shops
Authorization: Bearer <token>
```

```json
// Request
{
  "name": "My Store",
  "slug": "my-store",
  "description": "Optional description",
  "category": "electronics",
  "contact_number": "+9647701234567",
  "location_city": "Baghdad",
  "location_district": "Karrada",
  "location_address": "Al-Nidal St., Building 12",
  "image_url": "https://minio.lugta.com/lugta/uploads/shop-cover.jpg"
}
// Response 201 → Shop object (includes all fields above)
```

> All detail fields are **optional**. Upload the shop image first with `POST /media`, then pass the returned URL as `image_url`.

### 4.4 Add a Product to Your Shop *(seller)*

```
POST /shops/{shop_id}/products
Authorization: Bearer <token>
```

```json
// Request
{
  "title": "iPhone 15 Pro",
  "description": "Sealed box",
  "category": "phones",
  "price": 1200000,
  "stock_quantity": 3,
  "sku": "APL-IP15P",
  "images": ["https://..."]
}
// Response 201 → ShopProduct object
```

> Only the **owner** of the shop can add products. Returns `403` otherwise.

### 4.5 Update a Shop *(seller)*

```
PATCH /shops/{id}
Authorization: Bearer <token>
```

```json
// Request (all fields optional)
{
  "name": "My New Store Name",
  "description": "Updated description",
  "image_url": "https://minio.lugta.com/lugta/uploads/new-cover.jpg"
}

// Response 200 → Updated Shop object
```

### 4.6 Update a Product *(seller)*

```
PATCH /shops/{id}/products/{productId}
Authorization: Bearer <token>
```

```json
// Request (all fields optional)
{
  "price": 1150000,
  "stock_quantity": 10
}

// Response 200 → Updated ShopProduct object
```

### 4.7 Delete a Product *(seller)*

```
DELETE /shops/{id}/products/{productId}
Authorization: Bearer <token>
```

```json
// Response 200
{
  "success": true,
  "data": { "status": "deleted" }
}
```

---

## 5. Auctions

### 5.1 List Active Auctions

```
GET /auctions?page=1&limit=20
```

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "item_id": "uuid",
      "item": {
        "title": "Vintage Watch",
        "category": "accessories",
        "condition": "used_good",
        "images": ["https://minio.lugta.com/lugta/uploads/watch1.jpg"],
        "...": "..."
      },
      "start_price": "50000",
      "current_price": "75000",
      "min_bid_increment": "5000",
      "status": "active",
      "start_time": "...",
      "end_time": "2026-02-22T18:00:00Z",
      "winner_id": null,
      "stream_url": "https://stream.lugta.com/live/auction-uuid/index.m3u8"
    }
  ]
}
```

> `stream_url` is an empty string `""` when no live stream is active. Check `stream_url !== ""` before showing the video player.

### 5.2 Get Single Auction

```
GET /auctions/{id}
```

### 5.3 List Bids for an Auction

```
GET /auctions/{id}/bids
```

```json
// Response 200
{
  "success": true,
  "data": [
    { "id": "uuid", "auction_id": "uuid", "bidder_id": "uuid", "amount": "80000", "created_at": "..." }
  ]
}
```

### 5.4 Create an Auction *(seller)*

```
POST /auctions
Authorization: Bearer <token>
```

```json
// Request
{
  "title": "Vintage Watch",
  "description": "Omega Seamaster 1970s",
  "category": "accessories",
  "condition": "used_good",
  "start_price": 50000,
  "min_bid_increment": 5000,
  "duration_hours": 24,
  "images": [
    "https://minio.lugta.com/lugta/uploads/watch-front.jpg",
    "https://minio.lugta.com/lugta/uploads/watch-side.jpg"
  ],
  "stream_url": "https://stream.lugta.com/live/my-auction/index.m3u8"
}
// Response 201 → Auction object
```

**Condition values:** `new` | `used_good` | `used_fair`  
**Duration:** 1–168 hours

**`images`** — optional array of pre-uploaded URLs (use `POST /media` first).  
**`stream_url`** — optional live-stream URL. Supported formats:
  - HLS playlist: `https://…/index.m3u8`
  - RTMP: `rtmp://…/live/stream-key`
  - YouTube embed: `https://www.youtube.com/embed/<id>`

Leave `stream_url` empty or omit it if there is no live video.

### 5.5 Place a Bid *(buyer)*

```
POST /auctions/{id}/bids
Authorization: Bearer <token>
```

```json
// Request
{ "amount": 85000 }
// Response 201 → Bid object
```

> The bid must exceed `current_price + min_bid_increment`. A `400` is returned if the amount is too low or the auction is not active.

---

## 6. Cart

The cart is **per-user** and persisted server-side. It supports both **shop products** and **auction items**.

### 6.1 Get Cart

```
GET /cart
Authorization: Bearer <token>
```

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "cart-item-uuid",
      "user_id": "uuid",
      "item_type": "shop_product",
      "reference_id": "product-uuid",
      "quantity": 2,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

### 6.2 Add Item to Cart

```
POST /cart
Authorization: Bearer <token>
```

```json
// Request
{
  "item_type": "shop_product",
  "reference_id": "product-uuid",
  "quantity": 1
}
// Response 201 → CartItem
```

> If the same `(item_type, reference_id)` already exists in the cart, the **quantity is replaced** (upsert).

**`item_type` values:** `shop_product` | `auction`

### 6.3 Update Item Quantity

```
PATCH /cart/{cart_item_id}
Authorization: Bearer <token>
```

```json
// Request
{ "quantity": 3 }
// Response 200 → Updated CartItem
```

### 6.4 Remove Single Item

```
DELETE /cart/{cart_item_id}
Authorization: Bearer <token>
// Response 204 No Content
```

### 6.5 Clear Entire Cart

```
DELETE /cart
Authorization: Bearer <token>
// Response 204 No Content
```

---

## 7. Saved Items (Wishlist)

### 7.1 Get Wishlist

```
GET /saved-items
Authorization: Bearer <token>
```

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "saved-item-uuid",
      "user_id": "uuid",
      "item_type": "auction",
      "reference_id": "auction-uuid",
      "created_at": "..."
    }
  ]
}
```

### 7.2 Save an Item

```
POST /saved-items
Authorization: Bearer <token>
```

```json
// Request
{
  "item_type": "shop_product",
  "reference_id": "product-uuid"
}
// Response 201 → SavedItem
```

> This is **idempotent** — saving the same item twice is safe.

### 7.3 Remove a Saved Item

```
DELETE /saved-items/{saved_item_id}
Authorization: Bearer <token>
// Response 204 No Content
```

---

## 8. Orders & Escrow

### Order State Machine

```
PENDING_PAYMENT
      │ (payment webhook SUCCESS)
      ▼
PAID_TO_ESCROW
      │ (seller ships)
      ▼
   SHIPPED
      │ (buyer confirms delivery)
      ▼
  DELIVERED
      │ (funds auto-released)
      ▼
FUNDS_RELEASED

  (any stage) → CANCELLED
```

### 8.1 Buy a Shop Product

```
POST /orders/shop
Authorization: Bearer <token>
```

```json
// Request
{
  "product_id": "product-uuid",
  "quantity": 1,
  "shipping_address": {
    "city": "Baghdad",
    "district": "Karrada",
    "street": "Al-Nidal St.",
    "building": "12",
    "phone": "+9647701234567"
  }
}
// Response 201 → Order object (status: PENDING_PAYMENT)
```

> Stock is decremented immediately. If payment fails, the order is cancelled.

### 8.2 Get My Orders

```
GET /orders/me
Authorization: Bearer <token>
```

```json
// Response 200 → array of Order objects
```

### 8.3 Advance Order State *(seller or buyer)*

```
PATCH /orders/{id}/status
Authorization: Bearer <token>
```

```json
// Request — allowed values: SHIPPED | DELIVERED | CANCELLED
{ "status": "SHIPPED" }
// Response 200 → Updated Order
```

| Caller | Allowed transition |
|---|---|
| Seller | `PAID_TO_ESCROW` → `SHIPPED` |
| Buyer | `SHIPPED` → `DELIVERED` |
| Either | Any state → `CANCELLED` |

### 8.5 Get Single Order

```
GET /orders/{id}
Authorization: Bearer <token>
```

```json
// Response 200 → Order object
```

### 8.6 Payment Webhook *(server-to-server only)*

```
POST /orders/webhook/{provider}
```

The payment gateway (ZainCash / FIB) calls this endpoint directly. Mobile clients do **not** call this.

---

## 9. Media Uploads

Upload images before creating auctions or products. The returned URL is what you pass in the `images` array.

```
POST /media
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

Form field name: `file`

```json
// Response 201
{
  "success": true,
  "data": { "url": "https://minio.lugta.com/lugta/uploads/abc123.jpg" }
}
```

**Workflow:**
1. Upload image → get URL
2. Include URL in `images: [...]` when creating auction / product

---

## 10. Real-Time Bidding (WebSocket)

Connect to receive live bid updates for a specific auction without polling.

### Connection

```
ws://<host>:8080/ws/{auction_id}?token=<jwt>
```

Pass the JWT as a **query parameter**.

### Incoming Messages

```json
// New bid placed
{
  "type": "bid_placed",
  "auction_id": "uuid",
  "bid": {
    "id": "uuid",
    "bidder_id": "uuid",
    "amount": "90000",
    "created_at": "..."
  },
  "current_price": "90000"
}

// Auction ended / sold
{
  "type": "auction_ended",
  "auction_id": "uuid",
  "winner_id": "uuid",
  "final_price": "90000"
}
```

### Recommended Mobile Handling

```
onConnect     → show "Live" indicator
onMessage     → update current_price & bids list in UI
onDisconnect  → attempt reconnect with exponential backoff (1s, 2s, 4s…)
onError       → fall back to REST polling every 5s
```

---

## 11. Money Fields

All monetary values (prices, amounts, bids) are:

- Stored as **integers** in the **smallest currency unit** (Iraqi Dinar fils, or cents for USD).
- Serialized in JSON as **strings** to avoid JavaScript/Dart `int` precision loss.

```json
// 850,000 IQD = "850000" in the API
{ "price": "850000" }
```

**Parsing example (Dart/Flutter):**

```dart
final price = int.parse(product.price); // 850000
final display = NumberFormat('#,###').format(price); // "850,000"
```

---

## 12. Error Handling

| HTTP Status | Meaning | Action |
|---|---|---|
| `400` | Validation error | Show field-level error from `error` field |
| `401` | Missing / expired token | Redirect to login |
| `403` | Forbidden (e.g. not shop owner) | Show permission error |
| `404` | Resource not found | Show not-found state |
| `500` | Server error | Show generic retry message |

All errors follow the same envelope:

```json
{ "success": false, "error": "human-readable message" }
```

---

## 13. Search

The federated search endpoint queries new auctions, used auctions, and shop products **concurrently** and returns a single unified response.

### Endpoint

```
GET /api/v1/search?q={query}
```

- **Auth**: not required  
- `q` must be **at least 2 characters**; shorter queries return `400`
- Results are ranked by text similarity (powered by `pg_trgm` on the database)

### Response

```json
{
  "success": true,
  "data": {
    "query": "ايفون",
    "auctions": [
      {
        "auction_id": "uuid",
        "item_id": "uuid",
        "title": "ايفون 14 برو",
        "description": "جديد بالكرتون",
        "category": "electronics",
        "condition": "new",
        "current_price": "850000",
        "end_time": "2026-03-01T18:00:00Z",
        "images": ["https://..."],
        "status": "active"
      }
    ],
    "used": [
      {
        "auction_id": "uuid",
        "condition": "used_good",
        "current_price": "550000",
        "...": "..."
      }
    ],
    "shops": [
      {
        "id": "uuid",
        "shop_id": "uuid",
        "name": "ايفون 14",
        "description": "...",
        "price": "799000",
        "category": "electronics",
        "images": ["https://..."]
      }
    ]
  }
}
```

| Bucket | Description |
|---|---|
| `auctions` | Active auctions with `condition = 'new'` |
| `used` | Active auctions with `condition = 'used_good'` or `'used_fair'` |
| `shops` | Shop products matching the query |

> Empty buckets are returned as `[]`, never `null`.

### Flutter Example

```dart
Future<SearchResponse> search(String query) async {
  final res = await dio.get(
    '/search',
    queryParameters: {'q': query},
  );
  return SearchResponse.fromJson(res.data['data']);
}
```

### Error Cases

| Condition | Status | Error |
|---|---|---|
| `q` missing or < 2 chars | `400` | `"query must be at least 2 characters"` |
| Server error | `500` | `"search failed"` |

---

## 14. Invoices

### 14.1 List My Invoices

Retrieve a list of all invoices linked to the current user (either as a buyer or seller). Invoices provide details regarding completed auctions or direct shop transactions.

```
GET /invoices/me
Authorization: Bearer <token>
```

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "auction_id": "uuid",
      "seller_id": "uuid",
      "buyer_id": "uuid",
      "amount": "80000",
      "status": "paid",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

---

## Quick Reference

| Feature | Method | Endpoint | Auth |
|---|---|---|---|
| Register | POST | `/auth/register` | — |
| Login | POST | `/auth/login` | — |
| Send OTP | POST | `/auth/otp/send` | — |
| OTP Login | POST | `/auth/otp/login` | — |
| OTP Register | POST | `/auth/otp/register` | — |
| Get Me | GET | `/users/me` | ✓ |
| Update Profile | PATCH | `/users/me` | ✓ |
| List Shops | GET | `/shops` | — |
| Shop Catalog | GET | `/shops/:slug/products` | — |
| Create Shop | POST | `/shops` | ✓ |
| Update Shop | PATCH | `/shops/:id` | ✓ |
| Add Product | POST | `/shops/:id/products` | ✓ |
| Update Product | PATCH | `/shops/:id/products/:productId` | ✓ |
| Delete Product | DELETE | `/shops/:id/products/:productId` | ✓ |
| List Auctions | GET | `/auctions` | — |
| Get Auction | GET | `/auctions/:id` | — |
| List Bids | GET | `/auctions/:id/bids` | — |
| Create Auction | POST | `/auctions` | ✓ |
| Place Bid | POST | `/auctions/:id/bids` | ✓ |
| Get Cart | GET | `/cart` | ✓ |
| Add to Cart | POST | `/cart` | ✓ |
| Update Cart Item | PATCH | `/cart/:id` | ✓ |
| Remove Cart Item | DELETE | `/cart/:id` | ✓ |
| Clear Cart | DELETE | `/cart` | ✓ |
| Get Wishlist | GET | `/saved-items` | ✓ |
| Save Item | POST | `/saved-items` | ✓ |
| Remove Saved Item | DELETE | `/saved-items/:id` | ✓ |
| Buy Product | POST | `/orders/shop` | ✓ |
| My Orders | GET | `/orders/me` | ✓ |
| Get Single Order | GET | `/orders/:id` | ✓ |
| Advance Order | PATCH | `/orders/:id/status` | ✓ |
| List My Invoices | GET | `/invoices/me` | ✓ |
| Upload Media | POST | `/media` | ✓ |
| Live Bidding | WS | `/ws/:auction_id?token=` | ✓ |
| **Search** | **GET** | **`/search?q=`** | **—** |

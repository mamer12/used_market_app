# Specification: Supply Forms and Global Search

**Feature**: `004-supply-and-search`
**Created**: 2026-03-09

---

## 1. Overview
The marketplace currently lacks two critical functions for MVP launch: Supply (the ability for users to submit C2C Mustamal and B2B Balla listings) and Discovery (a functional global search system instead of a placeholder). This feature will wire up the existing UI forms for item creation to the backend APIs, including handling multi-image uploads. It will also introduce a dynamic, debounced global search page capable of displaying polymorphic search results seamlessly across different item types (Auctions, Shops, and Balla).

## 2. User Scenarios & Acceptance Criteria

### Scenario 1: User creates a C2C (Mustamal) item listing
**Background:** A user wants to sell a used item on the Mustamal marketplace.
- **When** the user fills out the 'Create Mustamal Listing' form, selects images, and taps submit.
- **Then** the app uploads the images to the media CDN and acquires their URLs.
- **And** the app calls the item creation API with `listing_type` set to `fixed_price` and the image URLs attached.
- **And** upon success, the user is shown a success Snackbar and navigated back to the previous screen.
- **And** upon failure, the user sees an error message detailing the issue.

### Scenario 2: Merchant creates a B2B (Balla) bulk listing
**Background:** A bulk merchant wants to add a Balla bale for sale.
- **When** the merchant completes the 'Add Balla Listing' form with pricing/weights and image selections.
- **Then** the images are uploaded to the CDN seamlessly.
- **And** the Balla creation endpoint is hit with `is_balla: true` appended to the listing data alongside the CDN URLs.
- **And** the UI handles loading, success (Snackbar + pop), and failure (error message) states clearly.

### Scenario 3: User searches for items globally
**Background:** A user is looking for a specific item across all marketplaces (Mustamal, Balla, Auctions, Matajir).
- **When** the user opens the Search screen and types a query.
- **Then** the search input debounces for 400ms to prevent spamming the backend API.
- **And** the search results render dynamically via a responsive masonry grid.
- **And** the results properly display the polymorphic elements (Auction cards, Retail cards, or Balla cards) tailored to their specific data shape and aesthetics.

## 3. Functional Requirements

### FR1: C2C/Mustamal Creation Workflow
- The app must support capturing and uploading user-selected images via the existing `MediaRemoteDataSource`.
- The system must use the exact CDN URLs returned by the media service to form the `createListing()` payload.
- The creation request MUST include `listing_type` classification (as 'fixed_price') to classify it correctly as a Mustamal item.

### FR2: B2B/Balla Creation Workflow
- The Balla addition form must upload images similarly to the Mustamal flow.
- The endpoint payload must have the flag `is_balla` identifying the target bulk market structure.
- Both success and error UI states must be managed to inform the user of the outcome.

### FR3: Global Search Data Fetching
- The search functionality must query the search endpoint provided by the search service.
- Search queries strictly implement a 400ms debounce buffer to prevent overwhelming network load.

### FR4: Global Search UI Engine
- Ensure that the Search Results view uses a dynamic, staggered container logic (like Masonry) to elegantly package variable-sized catalog items.
- The UI engine must support polymorphic rendering, identifying the source of each result and painting the right matching widget (e.g. `AuctionCard`, `RetailCard` or `BallaCard`), leveraging similar logic as the Home Screen discovery feed.

## 4. Success Criteria
*   Users can successfully create and publish a Mustamal post with at least one image attached via the UI.
*   Users can successfully create and publish a Balla post with full metadata and images attached.
*   The global search page is entirely functional: returning data from the backend search engine and rendering varying item types seamlessly in a single feed.
*   Search network requests are provably reduced by typing quickly, verifying the 400ms debounce.

## 5. Assumptions
*   The existing media upload flow and underlying media service structure is already stable and functioning perfectly.
*   The backend endpoints for `Search`, `Item Creation`, and `Balla Creation` have been prepared to accept the shapes matching the Front-End forms.
*   The required components or basic visual building blocks for the cards are already available within the codebase from previous UI builds.

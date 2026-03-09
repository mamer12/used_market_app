# Implementation Plan: Supply Forms and Global Search

**Branch**: `004-supply-and-search` | **Date**: 2026-03-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-supply-and-search/spec.md`

## Summary
The goal is to implement B2B/C2C item creation endpoints (with media uploading) and global discovery via a masonry-style search screen. This translates down to defining robust DTOs for `Mustamal` and `Balla` item creations, orchestrating a 2-step Cubit upload loop, and constructing the `Search` infrastructure (Cubit + DI) to dynamically list multi-type catalogs.

## Technical Context
**Language/Version**: Dart 3.x / Flutter 3.19+  
**Primary Dependencies**: `flutter_bloc`, `json_serializable`, `dio`, `injectable`, `go_router`, `flutter_staggered_grid_view` (assuming Masonry dependency exists)
**Target Platform**: iOS and Android  

## 1. Data Layer (Mustamal & Balla)

### 1.1 Data Transfer Objects (DTOs)
We will introduce strictly typed request DTOs using Code Generation (`freezed` or raw `json_serializable`).

- **CreateMustamalRequest**:
  - Requires: `title` (String), `description` (String), `price` (double), `categoryId` (int), `condition` (String), `images` (List<String>).
  - Implicit parameter for backend: `listing_type` set to `'fixed_price'`.
  
- **CreateBallaRequest**:
  - Requires: `title` (String), `description` (String), `price` (double), `categoryId` (int), `condition` (String), `images` (List<String>).
  - Specific fields: `salesUnit` (String - piece/kg/bundle), `weight` (double).
  - Implicit parameter for backend: `is_balla` set to `true`.

### 1.2 Remote Data Sources (`Dio` Setup)
- **ItemRemoteDataSource.createListing()**:
  Will implement `POST /item` using `CreateMustamalRequest.toJson()`. Returns the created item `ProductModel`.
  
- **BallaRemoteDataSource.createListing()**:
  Will implement `POST /item` using `CreateBallaRequest.toJson()`. Returns the created item `ProductModel`.
  
*(Assume `MediaRemoteDataSource.uploadImages(List<File>)` already correctly `POST`s multi-part data to `/media` and returns `List<String>` of CDN URLs)*

## 2. Presentation Layer (Wiring the Forms)

### 2.1 State Management (Cubit Logic)
Both creation forms share an identical 2-step remote operation process. We will create two Cubits: `CreateMustamalCubit` and `CreateBallaCubit`. 
Their state will map to: `initial`, `loading`, `success`, `error`.

**Cubit Submit Workflow:**
1. Switch state to `loading`.
2. Await `MediaRemoteDataSource.uploadImages(localFiles)`.
3. Receive CDN URLs.
4. Construct the respective Request DTO.
5. Await `DataSource.createListing()`.
6. Switch state to `success` (causing `context.pop()` in BlocListener).

### 2.2 Updating UI Forms
- Replace `// TODO` in `create_mustamal_page.dart` and `add_balla_page.dart`.
- Bind action buttons to their injected Cubit representations.
- Wrap content in `BlocConsumer` blocks to manage the `Loading Overlay` dynamically and gracefully display network errors inside `ScaffoldMessenger.showSnackBar()`.

## 3. Search Feature (/search)

### 3.1 Domain & State (SearchCubit)
- **State**:
  - `initial` (before typing) 
  - `loading` (searching)
  - `success` (holds `List<dynamic>` of search results matching the diverse types)
  - `error` (holds exception message).
- **Behavior**: Implements a `rxdart` Debouncer or manual delayed `Timer` of exactly 400ms before making a network call to `SearchRemoteDataSource.search(query)`.

### 3.2 UI Design (SearchPage)
- Setup an isolated file: `lib/features/search/presentation/pages/search_page.dart`.
- **Header**: An auto-focused generic `TextField` acting as the omnibox query listener.
- **Body**: Consumes a `SliverMasonryGrid` (using `flutter_staggered_grid_view` equivalent) mapping through state results. 
- **Polymorphism**: The `SearchPage` iterates the result items and determines their class instance (or field type enum) and conditionally paints `_MustamalCard`, `_ProductCard` (from Matajir), or `_AuctionCard` natively.

### 3.3 Router Overhaul
- Hook into `lib/core/router/app_router.dart` and swap the existing `Placeholder()` dummy screen representing `/search` to load the brand new `SearchPage()` injected with a `BlocProvider<SearchCubit>`.

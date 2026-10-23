# LocalMart

LocalMart is a SwiftUI marketplace app demonstrating remote product
fetching, local listing management, favorites, and queued
synchronization.

## Features

-   Fetch products from a remote API.
-   Persist listings using SwiftData.
-   Create/edit listings and toggle favorites.
-   Queue local create/update operations for synchronization.
-   Test local persistence and network fetching with XCTest, an
    in-memory SwiftData container, and MockURLProtocol.

## Technology

Swift, SwiftUI, SwiftData, URLSession, Swift concurrency, XCTest.

## Architecture

The app uses MVVM with a repository layer. Views delegate to
`MarketplaceViewModel`; the ViewModel depends on
`MarketplaceRepositoryProtocol`; the repository coordinates
`APIClientProtocol` and `MarketplaceLocalDataSource`.

## Setup

1.  Open `LocalMart.xcodeproj` in Xcode.
2.  Select the `LocalMart` scheme and a supported simulator/device.
3.  Build and run.

## Tests

Run the `LocalMartTests` target from Xcode's Test navigator.

-   `testToggleFavorite()` --- verifies favorite state persistence.
-   `testCreateListing()` --- verifies local creation and pending sync
    state.
-   `testRefreshFetchesProductsFromServer()` --- exercises ViewModel →
    Repository → APIClient with a mock response and in-memory SwiftData.

## Documentation

-   [EngineeringStandards.md](EngineeringStandards.md)
-   [Architecture diagram](ArchitectureDiagram.png)
-   [Fetch sequence](FetchSequence.png)
-   [Create sequence](CreateSequence.png)
-   [Sync sequence](SyncSequence.png)

## Note

The remote API is used to demonstrate client integration. Demo APIs may
not persist write operations permanently; verify server behavior before
assuming remote writes are durable.

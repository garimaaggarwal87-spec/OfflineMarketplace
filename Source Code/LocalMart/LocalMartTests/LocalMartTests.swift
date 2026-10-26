//
//  LocalMartTests.swift
//  LocalMartTests
//
//  Created by Garima Aggarwal on 22/10/26.
//

import XCTest
import SwiftData
@testable import LocalMart

@MainActor
final class LocalMartTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    var dataSource: ListingsLocalStore!

    override func setUpWithError() throws {
           let configuration = ModelConfiguration(
               isStoredInMemoryOnly: true
           )

           container = try ModelContainer(
               for: Listing.self, SyncOperation.self,
               configurations: configuration
           )

           context = ModelContext(container)

           dataSource = ListingsLocalStore(
               context: context
           )
       }
    
    private func makeMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral

        configuration.protocolClasses = [MockURLProtocol.self]

        return URLSession(configuration: configuration)
    }
    
    func testRefreshFetchesProductsFromServer() async throws {
        // Arrange: Prepare fake server data
        let mockJSON = """
        {
            "products": [
                {
                    "id": 101,
                    "title": "Test Chair",
                    "description": "A wooden chair",
                    "price": 49.99,
                    "thumbnail": "https://example.com/chair.jpg"
                },
                {
                    "id": 102,
                    "title": "Test Table",
                    "description": "A dining table",
                    "price": 199.99,
                    "thumbnail": "https://example.com/table.jpg"
                }
            ],
            "total": 2,
            "skip": 0,
            "limit": 0
        }
        """

        let mockData = Data(mockJSON.utf8)

        MockURLProtocol.requestHandler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
            )

            return (response, mockData)
        }

        // Arrange: Create in-memory SwiftData
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: Listing.self, SyncOperation.self,
            configurations: configuration
        )

        let context = ModelContext(container)

        // Arrange: Inject dependencies
        let apiClient = ListingsAPIService(session: makeMockSession())

        let repository = ListingsRepository(
            context: context,
            apiClient: apiClient
        )

        let viewModel = ListingsViewModel(
            context: context,
            repository: repository
        )

        // Act
        viewModel.refresh()

        // Wait for the Combine request to complete.
        let timeout = Date().addingTimeInterval(5)

        while viewModel.isLoading && Date() < timeout {
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        // Assert
        XCTAssertFalse(
            viewModel.isLoading,
            "Refresh did not complete within 5 seconds"
        )

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.listings.count, 2)

        let chair = try XCTUnwrap(
            viewModel.listings.first { $0.serverID == 101 }
        )

        XCTAssertEqual(chair.title, "Test Chair")
        XCTAssertEqual(chair.price, 49.99)

        let table = try XCTUnwrap(
            viewModel.listings.first { $0.serverID == 102 }
        )

        XCTAssertEqual(table.title, "Test Table")
        XCTAssertEqual(table.price, 199.99)

    }

    
    func testToggleFavorite() throws {
        // Arrange: create and save a listing.
        let listing = Listing(
            title: "Test Chair",
            listingDescription: "Wooden chair",
            price: 49.99
        )

        context.insert(listing)
        try context.save()

        XCTAssertFalse(listing.isFavorite)

        // Act: toggle the favorite.
        try dataSource.toggleFavorite(listing)

        // Assert: verify the favorite changed.
        XCTAssertTrue(listing.isFavorite)

        // Verify the change was saved in SwiftData.
        let listings = try dataSource.fetchListings()

        XCTAssertEqual(listings.count, 1)
        XCTAssertTrue(try XCTUnwrap(listings.first).isFavorite)
    }
    
    func testCreateListing() throws {
        // Arrange
        let title = "Test Table"
        let description = "Wooden dining table"
        let price = 199.99

        // Act
        try dataSource.createListing(
            title: title,
            description: description,
            price: price,
            imageData: nil
        )

        // Assert
        let listings = try dataSource.fetchListings()

        XCTAssertEqual(listings.count, 1)

        let listing = try XCTUnwrap(listings.first)

        XCTAssertEqual(listing.title, title)
        XCTAssertEqual(listing.listingDescription, description)
        XCTAssertEqual(listing.price, price)
        XCTAssertEqual(listing.syncStatus, .pending)
        XCTAssertTrue(listing.isLocallyCreated)
    }
    
    
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataSource = nil
        context = nil
        container = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

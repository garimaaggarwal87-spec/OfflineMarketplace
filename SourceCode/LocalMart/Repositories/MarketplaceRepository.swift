//
//  MarketplaceRepository.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import SwiftData

@MainActor
struct MarketplaceRepository: MarketplaceRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let localDataSource: MarketplaceLocalDataSource

    init(context: ModelContext, apiClient: APIClientProtocol? = nil) {
        self.apiClient = apiClient ?? APIClient()
        self.localDataSource = MarketplaceLocalDataSource(
            context: context
        )
    }

    // MARK: - Remote

    func fetchProducts() async throws -> [ProductDTO] {
        try await apiClient.fetchProducts()
    }

    func createProduct(title: String, description: String, price: Double) async throws -> ProductWriteResponse {
        try await apiClient.createProduct(
            title: title,
            description: description,
            price: price
        )
    }

    func updateProduct(serverID: Int,
                       title: String,
                       description: String,
                       price: Double) async throws -> ProductWriteResponse {
        try await apiClient.updateProduct(
            serverID: serverID,
            title: title,
            description: description,
            price: price
        )
    }

    // MARK: - Local

    func fetchListings() throws -> [Listing] {
        try localDataSource.fetchListings()
    }

    func fetchPendingCount() throws -> Int {
        try localDataSource.fetchPendingCount()
    }

    func fetchAllSyncOperations() throws -> [SyncOperation] {
        try localDataSource.fetchAllSyncOperations()
    }

    func mergeProducts(_ products: [ProductDTO]) throws {
        try localDataSource.mergeProducts(products)
    }

    func createListing(title: String, description: String, price: Double, imageData: Data?) throws {
        try localDataSource.createListing(
            title: title,
            description: description,
            price: price,
            imageData: imageData
        )
    }

    func updateListing(_ listing: Listing,
                       title: String,
                       description: String,
                       price: Double) throws {
        try localDataSource.updateListing(
            listing,
            title: title,
            description: description,
            price: price
        )
    }

    func toggleFavorite(_ listing: Listing) throws {
        try localDataSource.toggleFavorite(listing)
    }

    func deleteSyncOperation(_ operation: SyncOperation) {
        localDataSource.deleteSyncOperation(operation)
    }

    func saveLocalChanges() throws {
        try localDataSource.save()
    }
}

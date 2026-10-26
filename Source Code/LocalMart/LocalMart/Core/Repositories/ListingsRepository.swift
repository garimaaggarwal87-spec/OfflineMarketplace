//
//  ListingsRepository.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import SwiftData
import Combine

@MainActor
struct ListingsRepository: ListingsRepositoryProtocol {

    private let apiClient: ListingsAPIServiceProtocol
    private let localDataSource: ListingsLocalStore

    init(context: ModelContext, apiClient: ListingsAPIServiceProtocol? = nil) {
        self.apiClient = apiClient ?? ListingsAPIService()
        self.localDataSource = ListingsLocalStore(
            context: context
        )
    }

    // MARK: - Remote

    func fetchProducts() -> AnyPublisher<[ProductDTO], Error> {
        apiClient.fetchProducts()
    }

    func createProduct(
        title: String,
        description: String,
        price: Double
    ) -> AnyPublisher<ProductWriteResponse, Error> {
        apiClient.createProduct(
            title: title,
            description: description,
            price: price
        )
    }

    func updateProduct(
        serverID: Int,
        title: String,
        description: String,
        price: Double
    ) -> AnyPublisher<ProductWriteResponse, Error> {
        apiClient.updateProduct(
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
        try localDataSource.saveLocalChanges()
    }
}

//
//  MarketplaceRepositoryProtocol.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

@MainActor
protocol MarketplaceRepositoryProtocol {

    func fetchProducts() async throws -> [ProductDTO]

    func createProduct(title: String, description: String, price: Double) async throws -> ProductWriteResponse

    func updateProduct(serverID: Int,
                       title: String,
                       description: String,
                       price: Double) async throws -> ProductWriteResponse

    func fetchListings() throws -> [Listing]

    func fetchPendingCount() throws -> Int

    func fetchAllSyncOperations() throws -> [SyncOperation]

    func mergeProducts(_ products: [ProductDTO]) throws

    func createListing(title: String, description: String, price: Double, imageData: Data?) throws

    func updateListing(_ listing: Listing, title: String, description: String, price: Double) throws

    func toggleFavorite(_ listing: Listing) throws

    func deleteSyncOperation(_ operation: SyncOperation)

    func saveLocalChanges() throws
}

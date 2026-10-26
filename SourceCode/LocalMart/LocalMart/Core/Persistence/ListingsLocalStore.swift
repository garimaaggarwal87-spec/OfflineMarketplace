//
//  ListingsLocalStore.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftData
import Foundation

@MainActor
final class ListingsLocalStore: ListingsLocalStoreProtocol {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Fetch

    func fetchListings() throws -> [Listing] {
       try context.fetch(
            FetchDescriptor<Listing>(
                sortBy: [SortDescriptor(\.title)]
            )
        )
    }

    func fetchPendingCount() throws -> Int {
        try context.fetchCount(
            FetchDescriptor<SyncOperation>()
        )
    }

    func fetchAllSyncOperations() throws -> [SyncOperation] {
        try context.fetch(
            FetchDescriptor<SyncOperation>(
                sortBy: [SortDescriptor(\.createdAt)]
            )
        )
    }

    func fetchListing(serverID: Int) throws -> Listing? {
        let descriptor = FetchDescriptor<Listing>(
            predicate: #Predicate<Listing> { listing in
                listing.serverID == serverID
            }
        )
        return try context.fetch(descriptor).first
    }

    func fetchSyncOperations(for listingID: UUID) throws -> [SyncOperation] {
        let descriptor = FetchDescriptor<SyncOperation>(
            predicate: #Predicate<SyncOperation> { operation in
                operation.listingID == listingID
            }
        )
        return try context.fetch(descriptor)
    }

    // MARK: - Refresh Local Listings

    func mergeProducts(_ products: [ProductDTO]) throws {
        for product in products {
            if let existing = try fetchListing(serverID: product.id) {
                // Never overwrite a listing that has pending local changes.
                if existing.syncStatus == .synced {
                    existing.title = product.title
                    existing.listingDescription = product.description
                    existing.price = product.price
                    existing.remoteImageURL = product.thumbnail
                }
            } else {
                context.insert(
                    Listing(
                        serverID: product.id,
                        title: product.title,
                        listingDescription: product.description,
                        price: product.price,
                        remoteImageURL: product.thumbnail
                    )
                )
            }
        }

        try context.save()
    }

    // MARK: - Create Listing

    func createListing(
        title: String,
        description: String,
        price: Double,
        imageData: Data?
    ) throws {
        let imagePath = try imageData.map(saveImage)

        let listing = Listing(
            title: title,
            listingDescription: description,
            price: price,
            localImagePath: imagePath,
            syncStatus: .pending,
            isLocallyCreated: true
        )

        context.insert(listing)
        context.insert(
            SyncOperation(
                listingID: listing.id,
                operationType: .create
            )
        )

        try context.save()
    }

    // MARK: - Update Listing

    func updateListing(
        _ listing: Listing,
        title: String,
        description: String,
        price: Double
    ) throws {
        listing.title = title
        listing.listingDescription = description
        listing.price = price
        listing.updatedAt = .now
        listing.syncStatus = .pending

        if !listing.isLocallyCreated {
            let existing = try fetchSyncOperations(for: listing.id)

            if existing.isEmpty {
                context.insert(
                    SyncOperation(
                        listingID: listing.id,
                        operationType: .update
                    )
                )
            }
        }

        try context.save()
    }

    // MARK: - Favorites

    func toggleFavorite(_ listing: Listing) throws {
        listing.isFavorite.toggle()
        try context.save()
    }

    // MARK: - Sync Persistence

    func deleteSyncOperation(_ operation: SyncOperation) {
        context.delete(operation)
    }

    func saveLocalChanges() throws {
        try context.save()
    }

    // MARK: - Local Image Storage

    private func saveImage(_ data: Data) throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
        return filename
    }
}

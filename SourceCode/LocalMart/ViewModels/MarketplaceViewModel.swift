//
//  MarketplaceViewModel.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class MarketplaceViewModel {

    private let repository: MarketplaceRepositoryProtocol

    var listings: [Listing] = []
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?
    var favoritesOnly = false
    var pendingCount = 0

    init(context: ModelContext, repository: MarketplaceRepositoryProtocol? = nil) {

        self.repository = repository ?? MarketplaceRepository(context: context)
        loadLocal()
    }

    var visibleListings: [Listing] {
        favoritesOnly ? listings.filter { $0.isFavorite } : listings
    }

    func loadLocal() {
        do {
            listings = try repository.fetchListings()
            pendingCount = try repository.fetchPendingCount()
        } catch {
            errorMessage = "Couldn't load local data: \(error.localizedDescription)"
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }

        do {
            let products = try await repository.fetchProducts()
            try repository.mergeProducts(products)
            loadLocal()
        } catch {
            errorMessage = "Refresh failed: \(error.localizedDescription)"
            loadLocal()
        }
    }

    func addListing(
        title: String,
        description: String,
        priceText: String,
        imageData: Data?
    ) {
        errorMessage = nil

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else {
            errorMessage = "Enter a title."
            return
        }

        guard let price = Double(priceText), price > 0 else {
            errorMessage = "Enter a price greater than zero."
            return
        }

        do {
            try repository.createListing(
                title: cleanTitle,
                description: description,
                price: price,
                imageData: imageData
            )
            loadLocal()
        } catch {
            errorMessage = "Couldn't save listing: \(error.localizedDescription)"
        }
    }

    func updateListing(
        _ listing: Listing,
        title: String,
        description: String,
        priceText: String
    ) {
        errorMessage = nil

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else {
            errorMessage = "Enter a title."
            return
        }

        guard let price = Double(priceText), price > 0 else {
            errorMessage = "Enter a price greater than zero."
            return
        }

        do {
            try repository.updateListing(
                listing,
                title: cleanTitle,
                description: description,
                price: price
            )

            loadLocal()
        } catch {
            errorMessage = "Couldn't save edit: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(_ listing: Listing) {
        do {
            try repository.toggleFavorite(listing)
            loadLocal()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func syncPending() async {

        guard !isSyncing else { return }

        isSyncing = true
        defer {
            isSyncing = false
        }

        let operations: [SyncOperation]

        do {
            operations = try repository.fetchAllSyncOperations()
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        for operation in operations {
            guard let listing = listings.first(where: {
                $0.id == operation.listingID
            }) else {
                continue
            }

            do {
                if operation.operationType == .create {

                    let response = try await repository.createProduct(
                        title: listing.title,
                        description: listing.listingDescription,
                        price: listing.price
                    )

                    if let id = response.id {
                        listing.serverID = id
                    }

                    listing.isLocallyCreated = false

                } else if let serverID = listing.serverID {
                    _ = try await repository.updateProduct(
                        serverID: serverID,
                        title: listing.title,
                        description: listing.listingDescription,
                        price: listing.price
                    )
                } else {
                    throw URLError(.badURL)
                }

                repository.deleteSyncOperation(operation)
                listing.syncStatus = .synced

            } catch {
                print("Operation failed: \(error.localizedDescription)")
                listing.syncStatus = .failed
            }
        }

        do {
            try repository.saveLocalChanges()
            loadLocal()
        } catch {
            errorMessage = "Couldn't save sync results: \(error.localizedDescription)"
        }
    }

    private func saveImage(_ data: Data) throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
        return filename
    }
}

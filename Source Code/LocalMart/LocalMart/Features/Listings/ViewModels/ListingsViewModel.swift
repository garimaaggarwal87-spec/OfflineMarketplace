//
//  ListingsViewModel.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import SwiftData
import Observation
import Combine

@MainActor
@Observable
final class ListingsViewModel {

    // MARK: - Properties and Initialization

    private let repository: ListingsRepositoryProtocol

    private var cancellables = Set<AnyCancellable>()

    var listings: [Listing] = []
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?
    var favoritesOnly = false
    var pendingCount = 0

    init(context: ModelContext, repository: ListingsRepositoryProtocol? = nil) {

        self.repository = repository ?? ListingsRepository(context: context)
        loadLocal()
    }

    // MARK: - Getting Listings

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

    func refresh() {
        isLoading = true
        errorMessage = nil

        repository.fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }

                    if case .failure(let error) = completion {
                        self.errorMessage = "Refresh failed: \(error.localizedDescription)"
                        self.loadLocal()
                    }

                    self.isLoading = false
                },
                receiveValue: { [weak self] products in
                    guard let self else { return }

                    do {
                        try self.repository.mergeProducts(products)
                        self.loadLocal()
                    } catch {
                        self.errorMessage = "Refresh failed: \(error.localizedDescription)"
                        self.loadLocal()
                    }
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Create and Update Listings

    func addListing(titleText: String, description: String, priceText: String, imageData: Data?) {
        errorMessage = nil

        guard let validated = validateListing(titleText: titleText, priceText: priceText) else {
            return
        }

        do {
            try repository.createListing(
                title: validated.title,
                description: description,
                price: validated.price,
                imageData: imageData
            )
            loadLocal()
        } catch {
            errorMessage = "Couldn't save listing: \(error.localizedDescription)"
        }
    }

    func updateListing(_ listing: Listing, titleText: String, description: String, priceText: String) {
        errorMessage = nil

        guard let validated = validateListing(titleText: titleText, priceText: priceText) else {
            return
        }

        do {
            try repository.updateListing(
                listing,
                title: validated.title,
                description: description,
                price: validated.price
            )
            loadLocal()
        } catch {
            errorMessage = "Couldn't save edit: \(error.localizedDescription)"
        }
    }

    private func validateListing(titleText: String, priceText: String) -> (title: String, price: Double)? {

        let title = titleText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !title.isEmpty else {
            errorMessage = "Enter a title."
            return nil
        }

        guard let price = Double(priceText.trimmingCharacters(in: .whitespacesAndNewlines)),
                  price > 0 else {
            errorMessage = "Enter a price greater than zero."
            return nil
        }

        return (title, price)
    }

    // MARK: - Favorites

    func toggleFavorite(_ listing: Listing) {
        do {
            try repository.toggleFavorite(listing)
            loadLocal()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Synchronization

    func syncPending() {
        guard !isSyncing else { return }

        isSyncing = true
        errorMessage = nil

        do {
            let operations = try repository.fetchAllSyncOperations()
            processNextOperation(operations, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            finishSync()
        }
    }

    private func processNextOperation(_ operations: [SyncOperation], at index: Int) {

        guard index < operations.count else {
            finishSync()
            return
        }

        let operation = operations[index]

        guard let listing = listings.first(where: {
            $0.id == operation.listingID
        }) else {
            processNextOperation(operations, at: index + 1)
            return
        }

        processSyncOperation(operation, listing: listing)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }

                    if case .failure(let error) = completion {
                        listing.syncStatus = .failed
                        print("Sync failed: \(error.localizedDescription)")
                    }
                    self.processNextOperation(operations, at: index + 1)
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    private func processSyncOperation(_ operation: SyncOperation, listing: Listing) -> AnyPublisher<Void, Error> {

        let request: AnyPublisher<ProductWriteResponse, Error>

        if operation.operationType == .create {
            request = repository.createProduct(
                title: listing.title,
                description: listing.listingDescription,
                price: listing.price
            )
        } else if let serverID = listing.serverID {
            request = repository.updateProduct(
                serverID: serverID,
                title: listing.title,
                description: listing.listingDescription,
                price: listing.price
            )
        } else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return request
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                if operation.operationType == .create {
                    if let id = response.id {
                        listing.serverID = id
                    }

                    listing.isLocallyCreated = false
                }

                self.repository.deleteSyncOperation(operation)
                listing.syncStatus = .synced
            }
            .eraseToAnyPublisher()
    }

    private func finishSync() {
        do {
            try repository.saveLocalChanges()
            loadLocal()
        } catch {
            errorMessage = "Couldn't save sync results: \(error.localizedDescription)"
        }
        isSyncing = false
    }

}

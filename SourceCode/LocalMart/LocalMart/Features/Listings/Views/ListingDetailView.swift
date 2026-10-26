//
//  ListingDetailView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import SwiftData

struct ListingDetailView: View {
    @Bindable var listing: Listing
    let viewModel: ListingsViewModel
    @State private var showingEdit = false

    var body: some View {
        Form {
            Section("Product image") {
                ListingImageView(
                    listing: listing
                )
                .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            Section("Details") {
                LabeledContent("Title", value: listing.title)
                LabeledContent("Price",
                               value: listing.price.formatted(.currency(code:
                                                                    Locale.current.currency?.identifier ?? "USD")))
                Text(listing.listingDescription.isEmpty ? "No description" : listing.listingDescription)
                LabeledContent("Sync status", value: listing.syncStatus.rawValue)
            }
            Section {
                Button {
                    viewModel.toggleFavorite(listing)
                } label: {
                    Label(listing.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                          systemImage: listing.isFavorite ? "heart.slash" : "heart")
                }
                Button("Edit Listing") {
                    showingEdit = true
                }
            }
        }
        .navigationTitle("Listing Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            EditListingView(listing: listing, viewModel: viewModel)
        }
    }
}

#Preview {
    if let container = try? ModelContainer(
        for: Listing.self,
        SyncOperation.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        let listing = Listing(
            title: "Wooden Chair",
            listingDescription: "A comfortable wooden chair",
            price: 1500
        )
        ListingDetailView(
            listing: listing,
            viewModel: ListingsViewModel(context: container.mainContext)
        )
    } else {
        Text("Unable to create preview")
    }
}

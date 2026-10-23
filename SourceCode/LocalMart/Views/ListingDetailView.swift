//
//  ListingDetailView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI

struct ListingDetailView: View {
    @Bindable var listing: Listing
    let viewModel: MarketplaceViewModel
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
                Button("Edit Listing") { showingEdit = true }
            }
        }
        .navigationTitle("Listing Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            EditListingView(listing: listing, viewModel: viewModel)
        }
    }
}

struct EditListingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var listing: Listing
    let viewModel: MarketplaceViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                TextField("Price", text: $price).keyboardType(.decimalPad)
            }
            .navigationTitle("Edit Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateListing(listing, title: title, description: description, priceText: price)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                title = listing.title
                description = listing.listingDescription
                price = String(listing.price)
            }
        }
    }
}

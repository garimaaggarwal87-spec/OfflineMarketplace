//
//  EditListingView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 24/10/26.
//

import SwiftUI
import SwiftData

struct EditListingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var listing: Listing
    let viewModel: ListingsViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField("Description", text: $description, axis: .vertical)

                TextField("Price", text: $price).keyboardType(.decimalPad)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Edit Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.errorMessage = nil

                        viewModel.updateListing(
                            listing,
                            titleText: title,
                            description: description,
                            priceText: price
                        )

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
        EditListingView(
            listing: listing,
            viewModel: ListingsViewModel(context: container.mainContext)
        )
    } else {
        Text("Unable to create preview")
    }
}

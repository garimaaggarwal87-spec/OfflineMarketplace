//
//  CreateListingView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: MarketplaceViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField(
                    "Description",
                    text: $description,
                    axis: .vertical
                )

                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)

                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Label("Choose a photo", systemImage: "photo")
                }

                if selectedImageData != nil {
                    Label(
                        "Photo selected",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                }
            }
            .navigationTitle("New Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveListing()
                    }
                }
            }
            .task(id: selectedPhoto) {
                await processSelectedPhoto()
            }
        }
    }

    @MainActor
    private func processSelectedPhoto() async {
        selectedImageData = nil
        validationMessage = nil

        guard let selectedPhoto else {
            return
        }

        do {
            guard let originalData = try await selectedPhoto
                .loadTransferable(type: Data.self) else {
                return
            }

            try Task.checkCancellation()
            selectedImageData = originalData
        } catch is CancellationError {
            // The selected photo changed or this task was cancelled.
        } catch {
            validationMessage = "Unable to load the selected photo."
        }
    }

    private func saveListing() {
        validationMessage = nil

        guard !title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            validationMessage = "Enter a title."
            return
        }

        guard let priceValue = Double(
            price.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        ), priceValue > 0 else {
            validationMessage = "Enter a price greater than zero."
            return
        }

        viewModel.addListing(
            title: title,
            description: description,
            priceText: price,
            imageData: selectedImageData
        )

        if viewModel.errorMessage == nil {
            dismiss()
        } else {
            validationMessage = viewModel.errorMessage
            viewModel.errorMessage = nil
        }
    }
}

//
//  CreateListingView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct CreateListingView: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: ListingsViewModel

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

                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {

                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button(role: .destructive) {
                            selectedPhoto = nil
                            selectedImageData = nil
                            validationMessage = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash").foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)

                } else {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label("Choose a Photo", systemImage: "photo")
                    }
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
            // Ignore cancellation when the selected photo changes.
        } catch {
            validationMessage = "Unable to load the selected photo."
        }
    }

    private func saveListing() {
        validationMessage = nil

        viewModel.addListing(
            titleText: title,
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

#Preview {
    if let container = try? ModelContainer(
        for: Listing.self,
        SyncOperation.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        CreateListingView(
            viewModel: ListingsViewModel(context: container.mainContext)
        )
    } else {
        Text("Unable to create preview")
    }
}

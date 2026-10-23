//
//  ListingCardView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import UIKit

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ListingImageView(listing: listing)
                .frame(height: 125)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(listing.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(.primary)
            Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            HStack {
                Text(listing.syncStatus.rawValue)
                               .font(.caption2)
                               .foregroundStyle(
                                    listing.syncStatus == .synced
                                        ? Color.secondary
                                        : Color.orange
                              )

                Spacer()
                Image(
                    systemName: listing.isFavorite ? "heart.fill" : "heart"
                ).foregroundStyle(listing.isFavorite ? .red : .secondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.gray.opacity(0.2))
        }
    }
}

struct ListingImageView: View {
    let listing: Listing

    @State private var image: UIImage?

    init(listing: Listing) {
        self.listing = listing

        let key: String

        if let filename = listing.localImagePath {
            key = "local:\(filename)"
        } else if let url = listing.remoteImageURL {
            key = "remote:\(url)"
        } else {
            key = "placeholder"
        }

        _image = State(
            initialValue: ImageLoader.shared.cachedImage(for: key)
        )
    }

    private var cacheKey: String {
        if let filename = listing.localImagePath {
            return "local:\(filename)"
        }

        if let url = listing.remoteImageURL {
            return "remote:\(url)"
        }

        return "placeholder"
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipped()
                } else {
                    placeholder
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                }
            }
        }
        .task(id: cacheKey) {
            do {
                if let filename = listing.localImagePath {
                    image = try ImageLoader.shared.loadLocalImage(
                        from: filename
                    )
                } else if let urlString = listing.remoteImageURL {
                    image = try await ImageLoader.shared.loadRemoteImage(
                        from: urlString
                    )
                }
            } catch {
                image = nil
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.12))
            .overlay {
                Image(systemName: "shippingbox")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    ListingCardView(
        listing: Listing(title: "Coffee Mug", price: 67.00)
    )
}

//
//  ListingImageView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 24/10/26.
//

import SwiftUI

struct ListingImageView: View {
    let listing: Listing

    @State private var image: UIImage?

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

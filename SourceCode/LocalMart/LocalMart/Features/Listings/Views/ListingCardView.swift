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
                .stroke(.gray.opacity(0.3))
        }
    }
}

#Preview {
    ListingCardView(
        listing: Listing(
            title: "Wooden Chair",
            listingDescription: "A comfortable wooden chair",
            price: 1500
        )
    )
}

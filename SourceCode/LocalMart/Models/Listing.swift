//
//  Listing.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//
import Foundation
import SwiftData

@Model
final class Listing {

    @Attribute(.unique) var id: UUID
    var serverID: Int?
    var title: String
    var listingDescription: String
    var price: Double
    var remoteImageURL: String?
    var localImagePath: String?
    var isFavorite: Bool
    var updatedAt: Date
    var syncStatusRawValue: String
    var isLocallyCreated: Bool

    var syncStatus: SyncStatus {
        get {
            SyncStatus(rawValue: syncStatusRawValue) ?? .pending
        }
        set {
            syncStatusRawValue = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        serverID: Int? = nil,
        title: String,
        listingDescription: String = "",
        price: Double,
        remoteImageURL: String? = nil,
        localImagePath: String? = nil,
        isFavorite: Bool = false,
        updatedAt: Date = .now,
        syncStatus: SyncStatus = .synced,
        isLocallyCreated: Bool = false
    ) {
        self.id = id
        self.serverID = serverID
        self.title = title
        self.listingDescription = listingDescription
        self.price = price
        self.remoteImageURL = remoteImageURL
        self.localImagePath = localImagePath
        self.isFavorite = isFavorite
        self.updatedAt = updatedAt
        self.syncStatusRawValue = syncStatus.rawValue
        self.isLocallyCreated = isLocallyCreated
    }
}

enum SyncStatus: String, Codable {
    case synced = "Synced"
    case pending = "Pending"
    case failed = "Failed"
}

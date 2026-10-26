//
//  SyncOperation.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import SwiftData

@Model
final class SyncOperation {

    @Attribute(.unique) var id: UUID
    var listingID: UUID
    var operationTypeRawValue: String
    var createdAt: Date

    var operationType: SyncOperationType {
        get {
            SyncOperationType(rawValue: operationTypeRawValue) ?? .update
        }
        set {
            operationTypeRawValue = newValue.rawValue
        }
    }

    init(listingID: UUID, operationType: SyncOperationType) {
        self.id = UUID()
        self.listingID = listingID
        self.operationTypeRawValue = operationType.rawValue
        self.createdAt = .now
    }
}

enum SyncOperationType: String {
    case create
    case update
}

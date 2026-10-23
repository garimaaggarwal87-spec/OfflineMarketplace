//
//  LocalMartApp.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import SwiftData

@main
struct LocalMartApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [Listing.self, SyncOperation.self])
    }
}

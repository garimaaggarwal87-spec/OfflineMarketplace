//
//  ContentView.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var context
    @State private var viewModel: MarketplaceViewModel?
    @State private var showingCreate = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if let viewModel {
                NavigationStack {
                    ScrollView {
                        if viewModel.isLoading && viewModel.visibleListings.isEmpty {
                            ProgressView("Loading listings…")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                        } else if viewModel.visibleListings.isEmpty {
                            ContentUnavailableView(
                                "No Listings",
                                systemImage: "shippingbox",
                                description: Text("Pull to refresh to load products.")
                            )
                            .padding(.top, 60)
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.visibleListings) { listing in
                                    NavigationLink {
                                        ListingDetailView(
                                            listing: listing,
                                            viewModel: viewModel
                                        )
                                    } label: {
                                        ListingCardView(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                    }
                    .navigationTitle("LocalMart")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.favoritesOnly.toggle()
                            } label: {
                                Image(systemName: viewModel.favoritesOnly ? "heart.fill" : "heart")
                            }
                            .accessibilityLabel("Toggle favorites")
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button {
                                showingCreate = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Button {
                                Task {
                                    await viewModel.syncPending()
                                }
                            } label: {
                                if viewModel.isSyncing {
                                    ProgressView()
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                            }
                            .disabled(viewModel.isSyncing)
                            .accessibilityLabel("Sync pending changes")
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .task {
                        if viewModel.listings.isEmpty {
                            await viewModel.refresh()
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Text("\(viewModel.listings.count) listings")
                            Spacer()
                            Text("\(viewModel.pendingCount) pending")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.bar)
                    }
                    .sheet(isPresented: $showingCreate) {
                        CreateListingView(viewModel: viewModel)
                    }
                    .alert(
                        "LocalMart",
                        isPresented: Binding(
                            get: {
                                viewModel.errorMessage != nil
                            },
                            set: {
                                if !$0 {
                                    viewModel.errorMessage = nil
                                }
                            }
                        )
                    ) {
                        Button("OK") {
                            viewModel.errorMessage = nil
                        }
                    } message: {
                        Text(viewModel.errorMessage ?? "Unknown error")
                    }
                }
            } else {
                ProgressView("Loading listings…")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = MarketplaceViewModel(context: context)
            }
        }
    }
}

#Preview {
    ContentView()
}

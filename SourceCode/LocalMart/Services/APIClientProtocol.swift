//
//  APIClientProtocol.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

@MainActor
protocol APIClientProtocol {
    func fetchProducts() async throws -> [ProductDTO]

    func createProduct(
        title: String,
        description: String,
        price: Double
    ) async throws -> ProductWriteResponse

    func updateProduct(
        serverID: Int,
        title: String,
        description: String,
        price: Double
    ) async throws -> ProductWriteResponse
}

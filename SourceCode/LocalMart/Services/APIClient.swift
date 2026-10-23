//
//  APIClient.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation

struct APIClient: APIClientProtocol {

    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts() async throws -> [ProductDTO] {
        var components = URLComponents(
            url: APIConfiguration.productsURL,
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = [
            URLQueryItem(name: "limit", value: "0")
        ]

        let (data, response) = try await session.data(
            from: components.url!
        )

        try validate(response)

        return try JSONDecoder()
            .decode(ProductResponse.self, from: data)
            .products
    }

    func createProduct(title: String, description: String, price: Double) async throws -> ProductWriteResponse {
        try await sendProduct(
            path: "products/add",
            method: "POST",
            title: title,
            description: description,
            price: price
        )
    }

    func updateProduct(serverID: Int,
                       title: String,
                       description:
                       String,
                       price: Double) async throws -> ProductWriteResponse {
        try await sendProduct(
               path: "products/\(serverID)",
               method: "PATCH",
               title: title,
               description: description,
               price: price
           )
    }

    private func sendProduct(
        path: String,
        method: String,
        title: String,
        description: String,
        price: Double
    ) async throws -> ProductWriteResponse {

        let url = APIConfiguration.baseURL.appending(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(
            ProductWriteRequest(
                title: title,
                description: description,
                price: price
            )
        )

        do {
            let (data, response) = try await session.data(for: request)

            try validate(response)

            let decodedResponse = try JSONDecoder().decode(
                ProductWriteResponse.self,
                from: data
            )
            return decodedResponse

        } catch {
            print("Request failed: \(error)")
            throw error
        }
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

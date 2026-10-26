//
//  APIClient.swift
//  LocalMart
//
//  Created by Garima Aggarwal on 22/10/26.
//

import Foundation
import Combine

struct ListingsAPIService: ListingsAPIServiceProtocol {

    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts() -> AnyPublisher<[ProductDTO], Error> {

        guard let url = APIConfiguration.makeURL(
            queryItems: [
                URLQueryItem(name: "limit", value: "0")
            ]
        ) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { output in
                try validate(output.response)
                return output.data
            }
            .decode(type: ProductResponse.self, decoder: JSONDecoder())
            .map(\.products)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func createProduct(title: String, description: String, price: Double) -> AnyPublisher<ProductWriteResponse, Error> {
        sendProduct(
            path: "add",
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
                       price: Double) -> AnyPublisher<ProductWriteResponse, Error> {
        sendProduct(
            path: "\(serverID)",
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
    ) -> AnyPublisher<ProductWriteResponse, Error> {

        guard let url = APIConfiguration.makeURL(path: path) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(
                ProductWriteRequest(
                    title: title,
                    description: description,
                    price: price
                )
            )
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
                    .tryMap { output in
                        try validate(output.response)
                        return output.data
                    }
                    .decode(
                        type: ProductWriteResponse.self,
                        decoder: JSONDecoder()
                    )
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

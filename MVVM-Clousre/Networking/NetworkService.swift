//
//  NetworkService.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/12/24.
//

import Foundation

// MARK: - Enums
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingError
    case serverError(statusCode: Int)
    case noData
    case unauthorized
    case networkConnectionError
}

// MARK: - Protocols
protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ router: APIRouterProtocol,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )

    func requestRawData(
        _ router: APIRouterProtocol,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )
}

// MARK: - Network Service
class NetworkService: NetworkServiceProtocol {
    // Singleton instance
    static let shared = NetworkService()

    // Timeout configuration
    private let timeoutInterval: TimeInterval = 30

    // Prevent direct initialization
    private init() {}

    // MARK: - Request with Decoding
    func request<T: Decodable>(
        _ router: APIRouterProtocol,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Build URLRequest
        guard let urlRequest = try? router.asURLRequest() else {
            completion(.failure(.invalidURL))
            return
        }

        // Perform request
        performDataTask(urlRequest: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Raw Data Request
    func requestRawData(
        _ router: APIRouterProtocol,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        // Build URLRequest
        guard let urlRequest = try? router.asURLRequest() else {
            completion(.failure(.invalidURL))
            return
        }

        // Perform request
        performDataTask(urlRequest: urlRequest, completion: completion)
    }

    // MARK: - Private Helper Methods
    private func performDataTask(
        urlRequest: URLRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Check network connection error
            if let error = error as NSError?, error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
                    completion(.failure(.networkConnectionError))
                default:
                    completion(.failure(.requestFailed))
                }
                return
            }

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed))
                return
            }

            // Handle status codes
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(data))

            case 401:
                completion(.failure(.unauthorized))

            case 400...499:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))

            case 500...599:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))

            default:
                completion(.failure(.requestFailed))
            }
        }
        task.resume()
    }
}

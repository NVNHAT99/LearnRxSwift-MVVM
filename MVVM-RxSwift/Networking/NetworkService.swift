//
//  NetworkService.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/12/24.
//

import Foundation
import RxSwift

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
        _ router: APIRouterProtocol) -> Observable<T>
    

    func requestRawData(
        _ router: APIRouterProtocol
    ) -> Observable<Data>
}

// MARK: - Network Service
class NetworkService: NetworkServiceProtocol {
    // Singleton instance
    static let shared = NetworkService()

    private let session: URLSession
    // Prevent direct initialization
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .useProtocolCachePolicy
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Request with Decoding
    func request<T: Decodable>(_ router: APIRouterProtocol) -> Observable<T> {
        guard let urlRequest = try? router.asURLRequest() else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        return performRequest(urlRequest)
            .map { data in
                try JSONDecoder().decode(T.self, from: data)
            }.catch { error in
                return Observable.error(NetworkError.decodingError)
            }
    }

    // MARK: - Raw Data Request
    func requestRawData(_ router: APIRouterProtocol) -> Observable<Data> {
        // Build URLRequest
        guard let urlRequest = try? router.asURLRequest() else {
            return .error(NetworkError.invalidURL)
        }

        // Perform request
        return performRequest(urlRequest)
    }

    // MARK: - Private Helper Methods
    private func performRequest(_ urlRequest: URLRequest) -> Observable<Data> {
        return Observable.create { observer in
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain {
                    switch error.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
                        observer.onError(NetworkError.networkConnectionError)
                    default:
                        observer.onError(NetworkError.requestFailed)
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.requestFailed)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        observer.onError(NetworkError.noData)
                        return
                    }
                    observer.onNext(data)
                    observer.onCompleted()
                case 401:
                    observer.onError(NetworkError.unauthorized)
                case 400...499, 500...599:
                    observer.onError(NetworkError.serverError(statusCode: httpResponse.statusCode))
                default:
                    observer.onError(NetworkError.requestFailed)
                }
            }
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

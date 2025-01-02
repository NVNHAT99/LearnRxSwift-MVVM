//
//  APIRouter.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

protocol APIRouterProtocol {
    var baseURL: String { get }
    var endPoint: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }

    func asURLRequest() throws -> URLRequest
}

extension APIRouterProtocol {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + endPoint) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw NetworkError.requestFailed
            }
        }

        return urlRequest
    }
}

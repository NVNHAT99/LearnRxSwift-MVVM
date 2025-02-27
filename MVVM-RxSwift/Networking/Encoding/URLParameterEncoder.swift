//
//  URLParameterEncoder.swift
//  MVVM-RxSwift
//
//  Created by Nhat on 2/26/25.
//

import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    public func encode(from urlRequest: inout URLRequest,
                        with paramters: Parameters) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !paramters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in paramters {
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            let urlString = urlComponents.url?.absoluteString.replacingOccurrences(of: "+", with: "%2B")
            urlRequest.url = URL(string: urlString ?? "")
        }
        if urlRequest.value(forHTTPHeaderField: HTTPHeaderField.contentType.rawValue) == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}

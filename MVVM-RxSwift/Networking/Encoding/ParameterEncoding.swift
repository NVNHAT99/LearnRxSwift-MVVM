//
//  ParameterEncoding.swift
//  MVVM-RxSwift
//
//  Created by Nhat on 2/23/25.
//

import Foundation

public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    func encode(from urlRequest: inout URLRequest, with paramters: Parameters) throws
}

public enum ParameterEncoding {
    case urlEncoding
    case jsonEncodeing
    case urlAndJsonEncoding
    case multiPartEncoding
    
    public func encode(from urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(from: &urlRequest, with: urlParameters)
            case .jsonEncodeing:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(from: &urlRequest, with: bodyParameters)
            case .urlAndJsonEncoding:
                guard let urlParameters = urlParameters,
                      let bodyParameters = bodyParameters else { return }
                try URLParameterEncoder().encode(from: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(from: &urlRequest, with: bodyParameters)
            case .multiPartEncoding:
                break
            }
        }
    }
    
    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: MultipartFormData) throws {
        do {
            switch self {
            case .multiPartEncoding:
                try MultiplePartParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
            default:
                break
            }
        } catch {
            throw error
        }
    }
}

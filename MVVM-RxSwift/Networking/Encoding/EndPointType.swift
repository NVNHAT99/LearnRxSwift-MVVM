//
//  APIRouterProtocol.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var timeoutInterval: Double? { get }
}

//
//  ItemImageModel.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation

struct ItemImageModel: Codable {
    let id, author: String?
    let width, height: Int?
    let url, downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}

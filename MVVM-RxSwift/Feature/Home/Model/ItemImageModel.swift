//
//  ItemImageModel.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import Foundation
import RxDataSources

struct ItemImageModel: Codable, IdentifiableType, Equatable {
    typealias Identity = String
    var identity: String { UUID().uuidString }
    let id, author: String?
    let width, height: Int?
    let url, downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}

struct ItemImageModelSection {
    var header: String
    var items: [Item]
    var identity: String { UUID().uuidString }
}

extension ItemImageModelSection: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ItemImageModel
    
    init(original: ItemImageModelSection, items: [Item]) {
        self = original
        self.items = items
    }
}

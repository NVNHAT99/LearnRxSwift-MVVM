//
//  ImageItemTableViewCell.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import UIKit

class ImageItemTableViewCell: UITableViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageCell.image = nil
        authorLabel.text = ""
        sizeLabel.text = ""
    }
}

extension ImageItemTableViewCell {
    func configureImage(with image: UIImage?) {
        self.imageCell.image = image
    }
    
    func configCell(with data: ItemImageModel, image: UIImage?) {
        self.authorLabel.text = data.author
        self.sizeLabel.text = "Size: \(data.width ?? 0)x\(data.height ?? 0)"
        self.imageCell.image = image
    }
    
    func configCell(with data: ItemImageModel) {
        self.authorLabel.text = data.author
        self.sizeLabel.text = "Size: \(data.width ?? 0)x\(data.height ?? 0)"
    }
}

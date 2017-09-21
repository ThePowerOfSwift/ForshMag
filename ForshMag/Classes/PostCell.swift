//
//  PostCell.swift
//  ForshMag
//
//  Created by  Tim on 12.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell, PostCellProtocol {
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var categoriesLbl: UILabel!
    @IBOutlet weak var postHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func make() -> PostCellProtocol {
        return PostCell()
    }
    
    func name() -> String {
        return "PostCell"
    }
    
    func configureCell (post: Post, img: UIImage? = nil, imgURL: String? = nil) {
        postHeader.text = post.title
        categoriesLbl.text = post.category
        if img != nil {
            postImg.image = img
        } else {
            postImg.image = UIImage(named: "empty.png")
        }
    }
}

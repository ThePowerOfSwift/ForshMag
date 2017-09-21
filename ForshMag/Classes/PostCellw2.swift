//
//  PostCellw2.swift
//  ForshMag
//
//  Created by  Tim on 01.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire

class PostCellw2: UITableViewCell, PostCellProtocol {
    
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postHeader: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func make() -> PostCellProtocol {
        return PostCellw2()
    }
    
    func name() -> String {
        return "PostCellw2"
    }
    
    func configureCell (post: Post, img: UIImage? = nil, imgURL: String? = nil) {
        self.postHeader.text = post.title
        self.categoryLbl.text = post.category
        if img != nil {
            postImg.image = img
        } else {
            postImg.image = UIImage(named: "empty.png")
        }
    }
}

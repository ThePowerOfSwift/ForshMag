//
//  PostCellw.swift
//  ForshMag
//
//  Created by  Tim on 12.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire

class PostCellw: UITableViewCell, PostCellProtocol {
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postHeader: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func make() -> PostCellProtocol {
        return PostCellw()
    }
    
    func name() -> String {
        return "PostCellw"
    }
    
    func configureCell (post: Post, img: UIImage? = nil, imgURL: String? = nil) {
        self.postHeader.text = post.title
        if img != nil {
            postImg.image = img
        } else {
            postImg.image = UIImage(named: "empty.png")
        }
    }
}

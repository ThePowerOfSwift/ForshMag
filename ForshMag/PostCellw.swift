//
//  PostCellw.swift
//  ForshMag
//
//  Created by  Tim on 12.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit

class PostCellw: UITableViewCell {

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
    
    func configureCell (post: Post, img: UIImage? = nil) {
        self.postHeader.text = post.postTitle
        //self.categoriesLbl.text = post.postCategory
        if img != nil {
            postImg.image = img
        } else {
            if post.postImgUrl != nil {
                let url = NSURL(string: post.postImgUrl!)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url! as URL)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        self.postImg.image = image
                        FeedVC.imageCache.setObject(image!, forKey: post.postImgUrl! as NSString)
                    }
                }
            } else {
                postImg.image = UIImage(named: "empty")
            } 
        }
        
    }

}

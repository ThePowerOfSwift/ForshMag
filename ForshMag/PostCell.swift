//
//  PostCell.swift
//  ForshMag
//
//  Created by  Tim on 12.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
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
    
    func configureCell (post: Post) {
        self.postHeader.text = post.postTitle
        self.categoriesLbl.text = post.postCategory
        if post.postImgUrl != nil {
            let url = NSURL(string: post.postImgUrl!)
            let data = NSData(contentsOf: url! as URL)
            let image = UIImage(data: data! as Data)
            postImg.image = image
            //self.postImg.image = maskImage(image: image!, withMask: self.postImg!)

        }
    }

    func mask(viewToMask: UIImage, maskRect: CGRect) {
        
    }

}

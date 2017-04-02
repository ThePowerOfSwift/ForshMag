//
//  PostCellw2.swift
//  ForshMag
//
//  Created by  Tim on 01.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit

class PostCellw2: UITableViewCell {
    

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
    
    func configureCell (post: Post) {
        self.postHeader.text = post.postTitle
        self.categoryLbl.text = post.postCategory
        if post.postImgUrl != nil {
            let url = NSURL(string: post.postImgUrl!)
            let data = NSData(contentsOf: url! as URL)
            let image = UIImage(data: data! as Data)
            postImg.image = image
            
        }
    }
    
}

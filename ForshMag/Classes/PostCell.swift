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
        postHeader.text = post.postTitle
        categoriesLbl.text = post.postCategory
        if img != nil {
            postImg.image = img
        } else if let mediaId = post.postMediaId {
            Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON(completionHandler: { (response) in
                if let json = response.result.value as? Dictionary<String, Any> {
                    if let media = json ["media_details"] as? Dictionary<String, Any> {
                        if let sizes = media["sizes"] as? Dictionary<String, Any> {
                            if let type = sizes[post.postType] as? Dictionary<String,Any>{
                                if let imgUrl = type["source_url"] as? String {
                                    let url = NSURL(string: imgUrl)
                                    DispatchQueue.global().async {
                                        let data = try? Data(contentsOf: url! as URL)
                                        DispatchQueue.main.async {
                                            let image = UIImage(data: data!)
                                            self.postImg.image = image
                                            FeedVC.imageCache.setObject(image!, forKey: "\(post.postMediaId!)" as NSString)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        } else {
            postImg.image = UIImage(named: "empty")
        }
        
    }
}



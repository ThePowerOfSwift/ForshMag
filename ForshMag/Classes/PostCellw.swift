//
//  PostCellw.swift
//  ForshMag
//
//  Created by  Tim on 12.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire

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
        if img != nil {
            postImg.image = img
            print ("cache")
        } else if let mediaId = post.postMediaId, post.postMediaId != 0 {
            //postImg.image = UIImage(named: "empty")
            Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON(completionHandler: { (response) in
                if let json = response.result.value as? Dictionary<String, Any> {
                    if let media = json ["media_details"] as? Dictionary<String, Any> {
                        if let sizes = media["sizes"] as? Dictionary<String, Any> {
                            if let type = sizes["w2"] as? Dictionary<String,Any>{
                                if let imgUrl = type["source_url"] as? String {
                                    let url = NSURL(string: imgUrl)
                                    DispatchQueue.global().async {
                                        let data = try? Data(contentsOf: url! as URL)
                                        DispatchQueue.main.async {
                                            let image = UIImage(data: data!)
                                            self.postImg.image = image
                                            FeedVC.imageCache.setObject(image!, forKey: "\(post.postMediaId!)" as NSString)
                                            print ("load")
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

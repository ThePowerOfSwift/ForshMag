//
//  ForshMagAPI.swift
//  ForshMag
//
//  Created by  Tim on 19.09.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ForshMagAPI {
    
    static var sharedInstance: ForshMagAPI = ForshMagAPI()
    
    func getPost(withId id: Int, completion: @escaping(Dictionary<String, Any>) -> ()) {
        var postData = Dictionary<String, Any>()
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/\(id)", method: .get).responseJSON { response in
            let json = JSON(response.result.value ?? [])
            if let headerText = json["title"]["rendered"].string {
                postData["headerText"] = headerText
            }
            if let headerImg = json["acf"]["header-image"].string {
                postData["headerImgUrl"] = headerImg
            }
            if let date = json["date"].string {
                postData["date"] = self.parseDate(date: date)
            }
            if let author = json["acf"]["header-author"]["display_name"].string {
                postData["author"] = author
            }
            if let body = json["content"]["rendered"].string {
                postData["body"] = body
            }
            completion(postData)
        }
    }
    
    func imageLoader(mediaId: Int, completion: @escaping(UIImage) -> ()) {
        apiPreviewImages(mediaId: mediaId) { imgURL in
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: imgURL!) else {return}
                guard let image = UIImage(data: data) else {return}
                DispatchQueue.main.async {
                    FeedVC.imageCache.setObject(image, forKey: "\(mediaId)" as NSString)
                    completion (image)
                }
            }
        }
    }

    func apiPreviewImages (mediaId: Int, completion: @escaping(URL?) -> ()) {
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON { response in
            let json = JSON(response.result.value ?? [])
            if let imgURL = json["media_details"]["sizes"]["medium_large"]["source_url"].string {
                completion(URL(string: imgURL))
            }
        }
    }
    
    func getFeed(forPage page: String, completion: @escaping([Post]) -> ()) {
        var posts: [Post] = []
        let parameters = ["per_page": 10, "page": page] as [String : Any]
        
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/", method: .get, parameters: parameters).responseJSON { response in
            if let result = JSON(response.result.value ?? []).array {
                result.forEach{
                    let json = $0
                    var postTemp: Dictionary<String, Any> = [:]
                    if let id = json["id"].int {
                        postTemp["id"] = id
                    }
                    if let title = json["title"]["rendered"].string {
                        postTemp["title"] = title
                    }
                    if let thumb = json["acf"]["thumb-size"].string {
                        postTemp["type"] = thumb
                    }
                    if let mediaId = json["featured_media"].int {
                        postTemp["mediaId"] = mediaId
                    }
                    if let category = json["categories"].arrayObject {
                        postTemp["category"] = category[0]
                    }
                    let post = Post(title: postTemp["title"]! as! String,
                                    category: postTemp["category"] as! Int,
                                    url: postTemp["id"] as! Int,
                                    type: postTemp["type"]! as! String,
                                    mediaId: postTemp["mediaId"] as! Int)
                    posts.append(post)
                }
                completion(posts)
            }
        }
    }
    
    func parseDate (date: String) -> String {
        var dateArg = date.components(separatedBy: "T")
        dateArg = dateArg[0].components(separatedBy: "-")
        return "\(dateArg[2]).\(dateArg[1]).\(dateArg[0])"
    }
}

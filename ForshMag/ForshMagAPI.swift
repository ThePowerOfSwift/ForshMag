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
    
    func getPost(withId id: Int, completion: @escaping (Dictionary<String, Any>) -> ()) {
        var postData = Dictionary<String, Any>()
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/\(id)", method: .get).responseJSON { response in
            if let json = response.result.value! as? Dictionary<String, Any> {
                let json = JSON(json)
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
    }
    
    func imageLoader(mediaId: Int, completion: @escaping (UIImage) -> ()) {
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

    func apiPreviewImages (mediaId: Int, completion: @escaping (URL?) -> ()) {
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON { response in
            guard let json = response.result.value as? Dictionary<String, Any> else { return }
            guard let media = json ["media_details"] as? Dictionary<String, Any> else { return }
            guard let sizes = media["sizes"] as? Dictionary<String, Any> else { return }
            guard let type = sizes["medium_large"] as? Dictionary<String,Any> else { return }
            guard let imgUrl = type["source_url"] as? String else { return }
            completion(URL(string: imgUrl))
        }
    }
    
    func getFeed(forPage page: String, completion: @escaping  ([Post]) -> ()) {
        var posts: [Post] = []
        let parameters = ["per_page": 10, "page": page] as [String : Any]
        
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/", method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value! as? Array<Dictionary<String, Any>> {
                for post in json {
                    var postTemp: Dictionary<String, Any> = [:]
                    if let link = post["id"] as? Int{
                        postTemp["id"] =  link
                    }
                    if let title = post["title"] as? Dictionary<String, Any> {
                        if let rendered = title["rendered"] as? String{
                            postTemp["title"] = rendered
                        }
                    }
                    if let acf = post["acf"] as? Dictionary<String, Any> {
                        if let thumb = acf["thumb-size"] as? String {
                            postTemp["type"] = thumb
                        }
                    }
                    if let mediaId = post["featured_media"] as? Int {
                        postTemp["mediaId"] = mediaId
                    }
                    if let categories = post["categories"] as? Array<Int> {
                        postTemp["categories"] = categories[0]
                    }
                    let post = Post(title: postTemp["title"]! as! String,
                                    category: postTemp["categories"] as! Int,
                                    url: postTemp["id"] as! Int,
                                    type: postTemp["type"]! as! String,
                                    mediaId: postTemp["mediaId"] as! Int)
                    posts.append(post)
                }
            }
            completion(posts)
        }
    }
    
    func parseDate (date: String) -> String {
        var dateArg = date.components(separatedBy: "T")
        dateArg = dateArg[0].components(separatedBy: "-")
        return "\(dateArg[2]).\(dateArg[1]).\(dateArg[0])"
    }
}

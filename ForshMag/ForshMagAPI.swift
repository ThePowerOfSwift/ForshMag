//
//  ForshMagAPI.swift
//  ForshMag
//
//  Created by  Tim on 19.09.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import Alamofire

class ForshMagAPI {
    
    static var sharedInstance: ForshMagAPI = ForshMagAPI()
    
    func getPost(withId id: Int, completion: @escaping (Dictionary<String, Any>) -> ()) {
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/\(id)", method: .get).responseJSON { response in
            if let json = response.result.value! as? Dictionary<String, Any> {
                completion(json)
            }
        }
    }
    
    func imageLoader(mediaId: Int, completion: @escaping (UIImage) -> ()) {
        apiPreviewImages(mediaId: mediaId) { imgURL in
            guard let data = try? Data(contentsOf: imgURL!) else {return}
            guard let image = UIImage(data: data) else {return}
            FeedVC.imageCache.setObject(image, forKey: "\(mediaId)" as NSString)
            completion (image)
        }
    }

    func apiPreviewImages (mediaId: Int, completion: @escaping (URL?) -> ()) {
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON { response in
            guard let json = response.result.value as? Dictionary<String, Any> else { return }
            guard let media = json ["media_details"] as? Dictionary<String, Any> else { return }
            guard let sizes = media["sizes"] as? Dictionary<String, Any> else { return }
            guard let type = sizes["medium_large"] as? Dictionary<String,Any> else { return }
            //                guard let type = sizes["\(post["type"]!)"] as? Dictionary<String,Any> else { return }
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
}

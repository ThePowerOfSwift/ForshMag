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
    
    func getFeed (forPage page: String, completionHandler: @escaping ([Post]) -> ()) {
        apiFeed(forPage: page) { posts in
            self.getPreviewImages(forPosts: posts, completion: completionHandler)
        }
    }
    
    func getPreviewImages(forPosts posts: [Dictionary<String, Any>], completion: @escaping ([Post]) -> ()) {
        apiPreviewImages(postsDict: posts, completionHandler: completion)
    }
    
    func apiPreviewImages (postsDict: [Dictionary<String, Any>], completionHandler: @escaping ([Post]) -> ()) {
        var posts: [Post] = []
        for post in postsDict {
            Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(post["mediaId"] ?? "00")", method: .get).responseJSON(completionHandler: { (response) in
                if let json = response.result.value as? Dictionary<String, Any> {
                    if let media = json ["media_details"] as? Dictionary<String, Any> {
                        if let sizes = media["sizes"] as? Dictionary<String, Any> {
                            if let type = sizes["\(post["type"] ?? "w")"] as? Dictionary<String,Any>{
                                if let imgUrl = type["source_url"] as? String {
                                    let url = NSURL(string: imgUrl)
                                    let data = try? Data(contentsOf: url! as URL)
                                    let image = UIImage(data: data!)
                                    let post = Post(title: post["title"]! as! String, category: post["categories"] as! Int, url: post["id"] as! Int, type: post["type"]! as! String, mediaId: post["mediaId"] as? Int, postPreview: image)
                                    posts.append(post)
                                    if posts.count == 10 {
                                        completionHandler(posts)
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func apiFeed (forPage page: String, completion: @escaping  ([Dictionary<String, Any>]) -> ()) {
        var posts: [Dictionary<String, Any>] = []
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
                    posts.append(postTemp)
                }
            }
            completion(posts)
        }
    }
}

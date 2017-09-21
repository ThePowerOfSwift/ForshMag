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
        var posts: [Post] = []
        apiFeed(forPage: page) { postsDict in
            self.getPreviewImages(forPosts: postsDict) { images in
                for i in 0..<postsDict.count {
                    let indexOfImage = images.index(where: {
                        $0.1 == postsDict[i]["mediaId"] as! Int
                    })
                    let imageURL = indexOfImage != nil ? images[indexOfImage!].0 : nil
                    let post = Post(title: postsDict[i]["title"]! as! String,
                                    category: postsDict[i]["categories"] as! Int,
                                    url: postsDict[i]["id"] as! Int,
                                    type: postsDict[i]["type"]! as! String,
                                    mediaId: postsDict[i]["mediaId"] as? Int,
                                    postPreview: imageURL)
                    posts.append(post)
                }
                completionHandler(posts)
            }
        }
    }
    
    func getPreviewImages(forPosts posts: [Dictionary<String, Any>], completion: @escaping ([(URL, Int)]) -> ()) {
        apiPreviewImages(posts: posts, completionHandler: completion)
    }
    
    func imageLoared (mediaId: Int, imgURL: URL) -> UIImage {
        guard let data = try? Data(contentsOf: imgURL) else {return UIImage(named: "empty.png")!}
        guard let image = UIImage(data: data) else {return UIImage(named: "empty.png")!}
        FeedVC.imageCache.setObject(image, forKey: "\(mediaId)" as NSString)
        return image
    }
    
    func apiPreviewImages (posts: [Dictionary<String, Any>], completionHandler: @escaping ([(URL, Int)]) -> ()) {
        var urls: [(URL, Int)] = []
        for (index, post) in posts.enumerated() {
            guard let mediaId = post["mediaId"] else {continue}
            Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON { response in
                guard let json = response.result.value as? Dictionary<String, Any> else { return }
                guard let media = json ["media_details"] as? Dictionary<String, Any> else { return }
                guard let sizes = media["sizes"] as? Dictionary<String, Any> else { return }
                guard let type = sizes["medium_large"] as? Dictionary<String,Any> else { return }
//                guard let type = sizes["\(post["type"]!)"] as? Dictionary<String,Any> else { return }
                guard let imgUrl = type["source_url"] as? String else { return }
                let url = URL(string: imgUrl)
                urls.append((url!, post["mediaId"] as! Int))
                if index == posts.count - 1 {
                    completionHandler(urls)
                }
            }
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

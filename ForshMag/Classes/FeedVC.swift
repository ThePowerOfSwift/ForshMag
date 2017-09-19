//
//  FeedVC.swift
//  ForshMag
//
//  Created by  Tim on 11.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    static var imageCache: NSCache<NSString, UIImage> = NSCache ()
    
    private var posts = [Post] ()
    private var filtered = [Post] ()
    private var isFiltered = false
    private var loadMorePosts = false
    private var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 134
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        tableView.tableFooterView?.isHidden = true
        
        parseJSON(page: "\(currentPage)")
    }
    
    func refresh() {
        DispatchQueue.global(qos: .background).async {
            self.posts.removeAll()
            self.currentPage = 1
            self.parseJSON(page: "\(self.currentPage)")
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.isFiltered = false
                self.tableView.reloadData()
            }
        }
    }
    
    func parseJSON (page: String) {
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
                    let post = Post(title: postTemp["title"]! as! String, category: postTemp["categories"] as! Int, url: postTemp["id"] as! Int, type: postTemp["type"]! as! String, mediaId: postTemp["mediaId"] as? Int)
                    self.posts.append(post)
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
    //RES FUNC
    func loadImage (type: String, mediaId: Int, completion: @escaping (String) -> ()) {
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/media/\(mediaId)", method: .get).responseJSON(completionHandler: { (response) in
            if let json = response.result.value as? Dictionary<String, Any> {
                if let media = json ["media_details"] as? Dictionary<String, Any> {
                    if let sizes = media["sizes"] as? Dictionary<String, Any> {
                        if let type = sizes[type] as? Dictionary<String,Any>{
                            if let imgUrl = type["source_url"] as? String {
                                completion(imgUrl)
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post!
        let postCell: PostCellFactory!
        
        if isFiltered {
            post = filtered[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        
        switch (post.postType) {
        case "w":
            postCell = PostCellHelper.factory(for: .w)
        case "w2":
            postCell = PostCellHelper.factory(for: .w2)
        default:
            postCell = PostCellHelper.factory(for: .w4)
        }
        
        let cel = postCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: cel.name()) as? PostCellProtocol {
            if let mediaId = post.postMediaId {
                if let img = FeedVC.imageCache.object(forKey: "\(mediaId)" as NSString) {
                    cell.configureCell(post: post, img: img, imgURL: nil)
                    return cell as! UITableViewCell
                } else {
                    cell.configureCell(post: post, img: nil, imgURL: nil)
                    return cell as! UITableViewCell
                }
            } else {
                cell.configureCell(post: post, img: nil, imgURL: nil)
                return cell as! UITableViewCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.posts.count - 1 ) {
            currentPage += 1
            parseJSON(page: "\(currentPage)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filtered.count
        } else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        var post: Post!
        if isFiltered {
            post = filtered[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        performSegue(withIdentifier: "PostVC", sender: post)
    }
    
    // MARK: - FiltersByCategory
    
    @IBAction func filterLearn(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.postCategory == "#УЧИТЬСЯ"})
        tableView.reloadData()
    }
    
    @IBAction func filterDo(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.postCategory == "#ДЕЛАТЬ"})
        tableView.reloadData()
    }
    @IBAction func filterRest(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.postCategory == "#ОТДЫХАТЬ"})
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostVC" {
            if let detailVC = segue.destination as? PostVC {
                if let post = sender as? Post {
                    detailVC.post = post
                }
            }
        }
    }
}


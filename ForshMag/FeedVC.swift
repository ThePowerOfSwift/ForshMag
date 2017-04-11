//
//  FeedVC.swift
//  ForshMag
//
//  Created by  Tim on 11.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post] ()
    var filtered = [Post] ()
    var isFiltered = false
    var refreshControl: UIRefreshControl!
    var loadMorePosts = false
    static var imageCache: NSCache<NSString, UIImage> = NSCache ()
    
    
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
        parseJSON(page: "1")
        
        
    }
    
    func refresh() {
        DispatchQueue.global(qos: .background).async {
            self.posts.removeAll()
            self.parseJSON(page: "2")
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.isFiltered = false
                self.tableView.reloadData()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            //loadMore()
        }
    }
    
    func loadMore() {
        print("Loading")
        if ( !loadMorePosts ) {
            self.loadMorePosts = true
            //self.activityIndicator.startAnimating()
            self.tableView.tableFooterView?.isHidden = false
            DispatchQueue.global(qos: .background).async {
                self.parse()
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.isFiltered = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func parseJSON (page: String) {
        let parameters = ["per_page": 10, "page": page] as [String : Any]
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/", method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value! as? Array<Dictionary<String, Any>> {
                for post in json {
                    var postTemp: Dictionary<String, String> = [:]
                    if let link = post["id"] as? Int{
                        postTemp["id"] =  "\(link)"
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
                        postTemp["mediaId"] = "\(mediaId)"
                    }
                    let post = Post(title: postTemp["title"]!, category: "", url: postTemp["id"]!, type: postTemp["type"]!, imgUrl: nil)
                    self.posts.append(post)
                }

            }
            self.tableView.reloadData()
        }
    }
    
    
    
    func parse () {
        Alamofire.request("http://forshmag.me/", method: .get).responseString { (response) in
            if let doc = Kanna.HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
                for mainloop in doc.css("#mainloop .item") {
                    var post: [String] = []
                    for css in mainloop.css("span"){
                        if let title = css.text {
                            //print(title)
                            post.append(title)
                        }
                        if let category = css["data-cat-name"]{
                            //print(category)
                            post.append(category)
                        }
                    }
                    for css in mainloop.css("a"){
                        if let url = css["href"] {
                            //print(url)
                            post.append(url)
                        }
                        
                    }
                    if let className = mainloop.className {
                        let showString = className.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let showStringArr = showString.components(separatedBy: " ")
                        post.append(showStringArr[2])
                    }
                    for css in mainloop.css("img"){
                        if let imgUrl = css["src"] {
                            //print (imgUrl)
                            post.append(imgUrl)
                        }
                    }
                    let pos: Post
                    if post.count == 4 {
                        pos = Post(title: post[0], category: post[1], url: post[2], type: post[3], imgUrl: nil)
                    } else {
                        pos = Post(title: post[0], category: post[1], url: post[2], type: post[3], imgUrl: post[4])
                        
                    }
                    self.posts.append(pos)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post!
        if isFiltered {
            post = filtered[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        switch (post.postType) {
        case "w4":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
//                if let img = FeedVC.imageCache.object(forKey: post.postImgUrl! as NSString) {
//                    cell.configureCell(post: post, img: img)
//                    print("Image cached")
//                } else {
//                    cell.configureCell(post: post)
//                    print("Image Loaded")
//                }
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCell()
            }
        case "w":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw") as? PostCellw {
                if let imgUrl = post.postImgUrl {
                    if let img = FeedVC.imageCache.object(forKey: imgUrl as NSString) {
                        cell.configureCell(post: post, img: img)
                        print("Image cached")
                    } else {
                        cell.configureCell(post: post)
                        print("Image Loaded")
                    }
                } else {
                    cell.configureCell(post: post)
                    print("Image Loaded")
                }
                return cell
                
            } else {
                return PostCellw()
            }
        case "w2":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw2") as? PostCellw2 {
//                if let img = FeedVC.imageCache.object(forKey: post.postImgUrl! as NSString) {
//                    cell.configureCell(post: post, img: img)
//                    print("Image cached")
//                } else {
//                    cell.configureCell(post: post)
//                    print("Image Loaded")
//                }
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCellw2()
            }
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCell()
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filtered.count
        } else {
            return posts.count
        }
    }
    
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


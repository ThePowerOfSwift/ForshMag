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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 134
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
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCell()
            }
        case "w":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw") as? PostCellw {
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCellw()
            }
        case "w2":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw2") as? PostCellw2 {
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


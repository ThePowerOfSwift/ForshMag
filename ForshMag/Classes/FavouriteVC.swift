//
//  FavouriteVC.swift
//  ForshMag
//
//  Created by  Tim on 17.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FavouriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post] ()
    var controller: NSFetchedResultsController<Favourite>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 134
    }
    
    override func viewDidAppear(_ animated: Bool) {
        posts.removeAll()
        attemptFetch()
    }
    
    func getFavourites(ids: [Int]) {
        let parameters = ["include": ids]
        ForshMagAPI.sharedInstance.getFeed(withParameters: parameters) { posts in
            self.posts += posts
            self.tableView.reloadData()
        }
    }
    
    func attemptFetch(){
        let fetchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        var ids: [Int] = []
        do {
            let po = try context.fetch(fetchRequest)            
            for i in po {
                ids.append(Int(i.id))
                //context.delete(i)
            }
        } catch {
        }
        getFavourites(ids: ids)
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
    
    // MARK: - UITableViewDelegate & DataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let postCell: PostCellFactory
        switch (post.type) {
        case "w":
            postCell = PostCellHelper.factory(for: .w)
        case "w2":
            postCell = PostCellHelper.factory(for: .w2)
        default:
            postCell = PostCellHelper.factory(for: .w4)
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: postCell().name()) as? PostCellProtocol {
            if post.mediaId != 0 {
                if let img = FeedVC.imageCache.object(forKey: "\(post.mediaId)" as NSString) {
                    cell.configureCell(post: post, img: img)
                } else {
                    ForshMagAPI.sharedInstance.imageLoader(mediaId: post.mediaId) { image in
                        cell.configureCell(post: post, img: image)
                    }
                }
                return cell as! UITableViewCell
            } else {
                cell.configureCell(post: post, img: nil)
                return cell as! UITableViewCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        var post: Post!
        post = posts[indexPath.row]
        performSegue(withIdentifier: "PostVC", sender: post)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

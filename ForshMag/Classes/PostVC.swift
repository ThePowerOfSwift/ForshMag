//
//  PostVC.swift
//  ForshMag
//
//  Created by  Tim on 13.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class PostVC: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var post: Post!
    var articleView: Article!
    var rightBars: [UIBarButtonItem] = []
    var isFavourite: Bool = false
    var currentPost : Favourite?
    
    let api = ForshMagAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isInFavourite()
        articleView = Article (bounds: mainView.bounds)
        self.title = post.category
        var view = UIView()
        ForshMagAPI.sharedInstance.getPost(withId: self.post.urlId, completion: { post in
            view = self.articleView.getPostView(article: post)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.mainView.addSubview(view)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func addToFavourite () {
        if isFavourite {
            context.delete(currentPost!)
            ad.saveContext()
            print("fav delete")
            var faveBtn: UIBarButtonItem
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
            self.navigationItem.setRightBarButtonItems([(self.navigationItem.rightBarButtonItems?.first)!, faveBtn], animated: true)            
        } else {
            let fav = Favourite(context: context)
            fav.id = Int16(post.urlId)
            fav.isFavourite = true
            ad.saveContext()
            print("Fav")
            var faveBtn: UIBarButtonItem
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-added"), style: .plain, target: self, action: #selector(addToFavourite))
            self.navigationItem.setRightBarButtonItems([(self.navigationItem.rightBarButtonItems?.first)!, faveBtn], animated: true)
        }
    }
    
    func isInFavourite() {
        let fetchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        var shareBtn = UIBarButtonItem()
        var faveBtn = UIBarButtonItem()
        shareBtn = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(share))
        rightBars.append(shareBtn)
        do {
            let po = try context.fetch(fetchRequest)
            for i in po {
                if post.urlId == Int(i.id) {
                    currentPost = i
                    isFavourite = true
                    print ("yes")
                    break
                    //faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-added"), style: .plain, target: self, action: #selector(addToFavourite))
                } else {
                    isFavourite = false
                    //faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
                }
            }
        } catch {
            
        }
        if isFavourite {
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-added"), style: .plain, target: self, action: #selector(addToFavourite))
        } else {
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
        }
        rightBars.append(faveBtn)
        self.navigationItem.rightBarButtonItems = rightBars
    }
    
    func share () {
        print("shared")
        let activityVC = UIActivityViewController(activityItems: ["SHARE", "dsa"], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}

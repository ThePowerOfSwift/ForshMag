//
//  PostVC.swift
//  ForshMag
//
//  Created by  Tim on 13.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import CoreData

class PostVC: UIViewController {
    @IBOutlet weak var mainView: UIView!
    
    var post: Post!
    
    var articleView: Article!

    var rightBars: [UIBarButtonItem] = []
    
    var isFavourite: Bool = false
    
    var currentPost : Favourite?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isInFavourite()
        let shareBtn = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(share))
        rightBars.append(shareBtn)
        var faveBtn: UIBarButtonItem
        if isFavourite {
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-added"), style: .plain, target: self, action: #selector(addToFavourite))
        } else {
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
        }
        rightBars.append(faveBtn)
        self.navigationItem.rightBarButtonItems = rightBars
    }
    func addToFavourite () {
        if isFavourite {
            context.delete(currentPost!)
            print("fav delete")
            var faveBtn: UIBarButtonItem
            faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
            self.navigationItem.setRightBarButtonItems([(self.navigationItem.rightBarButtonItems?.first)!, faveBtn], animated: true)
            
        } else {
            let fav = Favourite(context: context)
            fav.id = Int16(post.postURL)
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
        do {
            let po = try context.fetch(fetchRequest)
            for i in po {
                if post.postURL == Int(i.id) {
                    currentPost = i
                    isFavourite = true
                    print ("yes")
                } else {
                    isFavourite = false
                }
            }
            
        } catch {
            
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    func share () {
        print("shared")
        let activityVC = UIActivityViewController(activityItems: ["SHARE", "dsa"], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(mainView.bounds.width)
        articleView = Article (bounds: mainView.bounds)
        parse ()

    }

    func parse () {
//        Alamofire.request(post.postURL, method: .get).responseString { (response) in
//            if let doc = Kanna.HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
//                for article in doc.css("article") {
//                    self.mainView.addSubview(self.articleView.getContentHTML(article: article))
//                    self.title = "#" + self.articleView.category.localizedUppercase
//                }
//            }
//        }
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/\(post.postURL)", method: .get).responseJSON { response in
            if let json = response.result.value! as? Dictionary<String, Any> {
                self.mainView.addSubview(self.articleView.getContentJSON(article: json))
                self.title = self.post.postCategory
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

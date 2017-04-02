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

class PostVC: UIViewController {
    @IBOutlet weak var mainView: UIView!
    
    var post: Post!
    
    var articleView: Article!

    var rightBars: [UIBarButtonItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareBtn = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(share))
        rightBars.append(shareBtn)
        let faveBtn = UIBarButtonItem(image: UIImage(named: "Favourite-add"), style: .plain, target: self, action: #selector(addToFavourite))
        rightBars.append(faveBtn)
        self.navigationItem.rightBarButtonItems = rightBars
    }
    func addToFavourite () {
        print("Added")
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
        Alamofire.request(post.postURL, method: .get).responseString { (response) in
            if let doc = Kanna.HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
                for article in doc.css("article") {
                    self.mainView.addSubview(self.articleView.getContent(article: article))
                    self.title = "#" + self.articleView.category.localizedUppercase
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

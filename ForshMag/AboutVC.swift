//
//  AboutVC.swift
//  ForshMag
//
//  Created by  Tim on 17.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class AboutVC: UIViewController{
    @IBOutlet weak var mainView: UIView!
    //@IBOutlet weak var mainView: UIScrollView!
    var articleView: Article! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //articleView = Article (bounds: mainView.frame)
        //parse()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        articleView = Article (bounds: mainView.bounds)
        parse()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func parse () {
        Alamofire.request("http://forshmag.me/about/", method: .get).responseString { (response) in
            if let doc = Kanna.HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
                for article in doc.css("article") {
                    self.mainView.addSubview(self.articleView.getContent(article: article))
                }
            }
        }
    }
    
}

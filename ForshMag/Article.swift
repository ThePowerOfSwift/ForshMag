//
//  Article.swift
//  ForshMag
//
//  Created by  Tim on 23.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import Kanna
import UIKit
import Alamofire
import SwiftSoup

class Article {
    
    var articleView = UIScrollView ()
    
    var category: String!
    
    var header: Dictionary <String, String> = [:]
    
    var height: CGFloat!
    
    init(bounds: CGRect) {
        articleView.frame = bounds
        articleView.contentSize.height = 0
    }
    
    func parseDate (date: String) -> String{
        print(date)
        var dateArg = date.components(separatedBy: "T")
        dateArg = dateArg[0].components(separatedBy: "-")
        return "\(dateArg[2]).\(dateArg[1]).\(dateArg[0])"
    }
    
    func getContentJSON (article: Dictionary<String,Any>) -> UIScrollView{
        if let title = article["title"] as? Dictionary<String, Any> {
            if let rendered = title["rendered"] as? String{
                header["text"] = rendered
                getHeader()
            }
        }
        if let acf = article["acf"] as? Dictionary<String, Any> {
            if let headerImg = acf["header-image"] as? String {
                getImage(url: headerImg, first: true)
            }
        }
        if let date = article["date"] as? String {
            let dataForView = parseDate(date: date)
            header["date"] = dataForView
            //getMeta()
        }
        if let authorId = article["author"] as? Int {
            Alamofire.request("http://forshmag.me/wp-json/wp/v2/users/\(authorId)", method: .get).responseJSON(completionHandler: { response in
                if let json = response.result.value as? Dictionary <String, Any> {
                    if let author = json["name"] as? String {
                        self.header["author"] = author
                        self.getMeta()
                    }
                }
            })
        }
        if let content = article["content"] as? Dictionary <String, Any> {
            if let rendered = content["rendered"] as? String {
                getContent(content: rendered)
            }
        }
        
        return articleView
    }
    
    func getContent (content: String) {
        do{
            let doc: Document = try! SwiftSoup.parse(content)
            let cont: Elements = try! doc.select("h2, p, img")
            for element in cont {
                switch element.tagName() {
                case "p":
                    let text: String = try! element.text()
                    getText(text: text, style: element.tagName())
                case "h2":
                    let text: String = try! element.text()
                    getText(text: text, style: element.tagName())
                case "img":
                    print(try! element.toString())
                    let attr: String = try! element.attr("src")
                    if attr != "" {
                        getImage(url: attr, first: nil)
                    }
                default:
                    let text: String = try! element.text()
                    getText(text: text, style: element.tagName())
                }
            }
        }
    }
    
    func getContentHTML (article: XMLElement) -> UIScrollView{
        for element in article.css("h1, h2, p, img, li") {
            //print (element.tagName!)
            if let tag = element.tagName {
                switch tag {
                case "h1":
                    if let text = element.text {
                        header["text"] =  text
                        getHeader()
                    }
                case "h2" :
                    if let text = element.text{
                        getText(text: text, style: "h2")
                    }
                case "img":
                    if let className = element.className {
                        if className == "main-image" {
                            if let urlStr = element["src"] {
                                print(className)
                                getImage(url: urlStr, first: true)
                            }
                        } else if let urlStr = element["src"] {
                            if urlStr != "" {
                                getImage(url: urlStr, first: nil)
                            }
                        }
                    }
                case "p":
                    if let className = element.className{
                        switch className {
                        case "intro":
                            if let text = element.text{
                                getText(text: text, style: className)
                            }
                        case "excerpt":
                            if let text = element.text{
                                getExcerpt(text: text)
                            }
                        default:
                            if let text = element.text{
                                getText(text: text, style: className)
                            }
                        }
                    } else {
                        if let text = element.text {
                            getText(text: text, style: "p")
                        }
                    }
                case "li":
                    if let className = element.className {
                        if className == "author" {
                            header["author"] = element.text!
                        } else if className == "date" {
                            header["date"] = element.text!
                        } else {
                            header["category"] = element.text!
                            category = removeSpecialCharsFromString(text: element.text!)
                            getMeta()
                        }
                    }
                default:
                    if let text = element.text {
                        if text != " " {
                            getText(text: text, style: "p")
                        }
                    }
                }
            }
        }
        return articleView
    }
    
    func getExcerpt (text: String){
        let block = UIView(frame: CGRect(x: 0, y: CGFloat(calculateHeightView()), width: articleView.bounds.width/6, height: 5))
        block.backgroundColor = UIColor.init(netHex: 0x6DA96D)
        block.layer.zPosition = 1
        block.center = CGPoint (x: articleView.layer.frame.width/2, y: CGFloat(calculateHeightView()))
        articleView.addSubview(block)
        let textView = UITextView(frame: CGRect(x: 15, y: CGFloat(calculateHeightView()+block.frame.height), width: articleView.layer.frame.size.width-30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: "excerpt", text: text)
        textView.sizeToFit()
        //textView.backgroundColor = UIColor.red
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.layer.frame.size.width-30, height: textView.frame.height)
        articleView.addSubview(textView)
        let block2 = UIView(frame: CGRect(x: 0, y: CGFloat(calculateHeightView()+textView.frame.height+block.frame.height), width: articleView.layer.frame.width/6, height: 5))
        block2.backgroundColor = UIColor.init(netHex: 0x6DA96D)
        block2.layer.zPosition = 1
        block2.center = CGPoint (x: articleView.layer.frame.width/2, y: CGFloat(calculateHeightView()+textView.frame.height))
        articleView.addSubview(block2)
        articleView.contentSize.height += textView.frame.height.rounded()
    }
    
    func getHeader() {
        let textView = UITextView(frame: CGRect(x: 0, y: 10, width: articleView.layer.frame.size.width-30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: "h1", text: header["text"]!)
        textView.sizeToFit()
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: 10, width: articleView.layer.frame.size.width-30, height: textView.frame.height)
        textView.textAlignment = .center
        textView.layer.zPosition = 1
        height = textView.frame.height
        articleView.addSubview(textView)
    }
    
    func getMeta (){
        let textView = UITextView(frame: CGRect(x: 0, y: height, width: articleView.layer.frame.size.width-30, height: CGFloat.greatestFiniteMagnitude))
        let str = header["author"]!+" · "+header["date"]!
        textView.attributedText = typography(style: "meta", text: str.localizedUppercase)
        textView.sizeToFit()
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: height, width: articleView.layer.frame.size.width-30, height: textView.frame.height)
        textView.textAlignment = .right
        textView.layer.zPosition = 1
        articleView.addSubview(textView)
    }
    
    func getText (text: String, style: String) {
        let textView = UITextView(frame: CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.layer.frame.size.width-30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: style, text: text)
        textView.sizeToFit()
        //textView.backgroundColor = UIColor.red
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.layer.frame.size.width-30, height: textView.frame.height)
        articleView.addSubview(textView)
        if style == "intro" {
            articleView.contentSize.height = articleView.contentSize.height + textView.frame.height.rounded() + 30
        } else {
            articleView.contentSize.height += textView.frame.height.rounded()
        }
        
    }
    
    func getImage (url: String, first: Bool?){
        
        let url = NSURL(string: url)
        let data = NSData(contentsOf: url! as URL)
        let image = UIImageView()
        image.image = UIImage(data: data! as Data)
        if first != nil {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
            image.frame = CGRect(x: 0, y: 0, width: articleView.bounds.width, height: self.calculateHeightImage(sourceImage: image.image!))
            gradient.frame = image.frame
            gradient.opacity = 0.5
            image.layer.addSublayer(gradient)
            
        } else {
            image.frame = CGRect(x: 0, y: CGFloat(calculateHeightView()), width: articleView.layer.frame.size.width, height: self.calculateHeightImage(sourceImage: image.image!))
        }
        
        articleView.addSubview(image)
        articleView.contentSize.height += image.frame.height.rounded()
    }
    
    func calculateHeightImage (sourceImage: UIImage) -> CGFloat {
        let oldWidth = sourceImage.size.width
        let scaleFactor = articleView.layer.frame.size.width / oldWidth
        let newHeight = sourceImage.size.height * scaleFactor
        return CGFloat(newHeight)
    }
    
    func calculateHeightView () -> CGFloat{
        //        let array = articleView.subviews
        //        for view in array {
        //            height += Int(view.bounds.maxY)
        //            height += 20
        //        }
        return articleView.contentSize.height + 20
    }
    
    func typography (style: String, text: String) -> NSAttributedString{
        switch style {
        case "h1":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Lora", size: 20.0)!], range: NSRange(location:0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            attributedText.addAttributes([NSForegroundColorAttributeName : UIColor.white], range: NSRange(location:0, length:attributedText.length))
            return attributedText
        case "h2":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Lora-Bold", size: 18.0)!], range: NSRange(location:0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        case "p":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Noto Sans", size: 14.0)!], range: NSRange(location:0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        case "meta":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "FiraSans-Light", size: 14.0)!], range: NSRange(location:0, length:attributedText.length))
            attributedText.addAttributes([NSForegroundColorAttributeName : UIColor.white], range: NSRange(location:0, length:attributedText.length))
            return attributedText
        case "intro","excerpt":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "NotoSans-Bold", size: 14.0)!], range: NSRange(location:0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = NSTextAlignment.center
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        default:
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Noto Sans", size: 14.0)!], range: NSRange(location:0, length: attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        }
        
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ абвгдеёзжиклмонпрстуфхцчьъшщыэюя АБВГДЕЁЖЗИКЛМОПРСТУФХЦЧШЩЬЪЫЭЮЯ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

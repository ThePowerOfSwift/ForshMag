//
//  Article.swift
//  ForshMag
//
//  Created by  Tim on 23.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kanna
import SwiftSoup
import SwiftyJSON

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
        var dateArg = date.components(separatedBy: "T")
        dateArg = dateArg[0].components(separatedBy: "-")
        return "\(dateArg[2]).\(dateArg[1]).\(dateArg[0])"
    }
    
    func getPostView(article: Dictionary<String,Any>) -> UIScrollView {
        getHeader(article)
        getImage(url: article["headerImgUrl"] as! String, first: true)
        getMeta(article)
        getContent(content: article["body"] as! String)
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
                    let attr: String = try! element.attr("srcset")
                    if attr != "" {
                        let originalWidth = try! element.attr("width")
                        let originalHeight = try! element.attr("height")
                        
                        let imageWithSize = getImageWithSize(srcset: attr, originalSize: (Int(originalWidth)!, Int(originalHeight)!))
                        if imageWithSize.0 != nil {
                            getImage(url: imageWithSize.0!, width: imageWithSize.1!, height: imageWithSize.2!)
                        } else {
                            getImage(url: try! element.attr("src"))
                        }
                    }
                default:
                    let text: String = try! element.text()
                    getText(text: text, style: element.tagName())
                }
            }
        }
    }
    
    func getImageWithSize(srcset: String, originalSize: (Int, Int)) -> (String?, Int?, Int?) {
        var url: String?
        var width: Int?
        var height: Int?
        let set = srcset.components(separatedBy: ",")
        set.forEach {
            var alt = $0.components(separatedBy: " ")
            if alt[0] == "" {
                alt.remove(at: 0)
            }
            if alt[1] == "768w"{
                url = alt[0]
                width = 768
                height = Int(Double(originalSize.1) / (Double(originalSize.0) / 768.0))
            }
        }
        return (url, width, height)
    }
    
    func getExcerpt (text: String){
        let block = UIView(frame: CGRect(x: 0, y: CGFloat(calculateHeightView()), width: articleView.bounds.width / 6, height: 5))
        block.backgroundColor = UIColor.init(netHex: 0x6DA96D)
        block.layer.zPosition = 1
        block.center = CGPoint (x: articleView.frame.width / 2, y: CGFloat(calculateHeightView()))
        articleView.addSubview(block)
        
        let textView = UITextView(frame: CGRect(x: 15, y: CGFloat(calculateHeightView() + block.frame.height), width: articleView.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: "excerpt", text: text)
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.frame.size.width - 30, height: textView.frame.height)
        articleView.addSubview(textView)
        
        let block2 = UIView(frame: CGRect(x: 0, y: CGFloat(calculateHeightView()+textView.frame.height + block.frame.height), width: articleView.frame.width / 6, height: 5))
        block2.backgroundColor = UIColor.init(netHex: 0x6DA96D)
        block2.layer.zPosition = 1
        block2.center = CGPoint (x: articleView.frame.width / 2, y: CGFloat(calculateHeightView()+textView.frame.height))
        articleView.addSubview(block2)
        articleView.contentSize.height += textView.frame.height.rounded()
    }
    
    func getHeader(_ header: Dictionary<String, Any>) {
        let textView = UITextView(frame: CGRect(x: 0, y: 10, width: articleView.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: "h1", text: header["headerText"] as! String)
        textView.sizeToFit()
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: 10, width: articleView.frame.size.width - 30, height: textView.frame.height)
        textView.textAlignment = .center
        textView.layer.zPosition = 1
        height = textView.frame.height
        articleView.addSubview(textView)
    }
    
    func getMeta (_ header: Dictionary<String, Any>){
        let textView = UITextView(frame: CGRect(x: 0, y: height, width: articleView.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        let str = (header["author"] as? String ?? "") + " · " + (header["date"] as! String)
        textView.attributedText = typography(style: "meta", text: str.localizedUppercase)
        textView.sizeToFit()
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: height, width: articleView.frame.size.width - 30, height: textView.frame.height)
        textView.textAlignment = .right
        textView.layer.zPosition = 1
        articleView.addSubview(textView)
    }
    
    func getText (text: String, style: String) {
        let textView = UITextView(frame: CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = typography(style: style, text: text)
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.frame = CGRect(x: 15, y: CGFloat(calculateHeightView()), width: articleView.frame.size.width - 30, height: textView.frame.height)
        articleView.addSubview(textView)
        if style == "intro" {
            articleView.contentSize.height = articleView.contentSize.height + textView.frame.height.rounded() + 30
        } else {
            articleView.contentSize.height += textView.frame.height.rounded()
        }
        
    }
    
    func getImage (url: String, width: Int? = nil, height: Int? = nil, first: Bool? = false){
        let image = UIImageView()
        if let _ = width, let _ = height {
            DispatchQueue.global().async {
                let url = NSURL(string: url)
                let data = NSData(contentsOf: url! as URL)
                DispatchQueue.main.async {
                    image.image = UIImage(data: data! as Data)
                }
            }
        } else {
            let url = NSURL(string: url)
            let data = NSData(contentsOf: url! as URL)
            image.image = UIImage(data: data! as Data)
        }
        let width = width != nil ? CGFloat(width!) : (image.image?.size.width)!
        let height = height != nil ? CGFloat(height!) : (image.image?.size.height)!
        if first! {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
            image.frame = CGRect(x: 0, y: 0, width: articleView.bounds.width, height: calculateNewHeightImage(width: width, height: height))
            gradient.frame = image.frame
            gradient.opacity = 0.5
            image.layer.addSublayer(gradient)
            
        } else {
            image.frame = CGRect(x: 0, y: CGFloat(calculateHeightView()), width: articleView.frame.size.width, height: calculateNewHeightImage(width: width, height: height))
        }
        articleView.addSubview(image)
        articleView.contentSize.height += image.frame.height.rounded()
    }
    
    func calculateNewHeightImage(width: CGFloat, height: CGFloat) -> CGFloat {
        let scaleFactor = articleView.frame.size.width / CGFloat(width)
        let newHeight = CGFloat(height) * scaleFactor
        return CGFloat(newHeight)
    }
    
    func calculateHeightView () -> CGFloat{
        return articleView.contentSize.height + 20
    }
    
    func typography (style: String, text: String) -> NSAttributedString{
        switch style {
        case "h1":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Lora", size: 20.0)!], range: NSRange(location: 0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            attributedText.addAttributes([NSForegroundColorAttributeName : UIColor.white], range: NSRange(location: 0, length:attributedText.length))
            return attributedText
        case "h2":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Lora-Bold", size: 18.0)!], range: NSRange(location: 0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        case "p":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Noto Sans", size: 14.0)!], range: NSRange(location: 0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        case "meta":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "FiraSans-Light", size: 14.0)!], range: NSRange(location: 0, length:attributedText.length))
            attributedText.addAttributes([NSForegroundColorAttributeName : UIColor.white], range: NSRange(location: 0, length:attributedText.length))
            return attributedText
        case "intro","excerpt":
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "NotoSans-Bold", size: 14.0)!], range: NSRange(location: 0, length:attributedText.length))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = NSTextAlignment.center
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            return attributedText
        default:
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSFontAttributeName : UIFont(name: "Noto Sans", size: 14.0)!], range: NSRange(location: 0, length: attributedText.length))
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
    
    func getContentHTML (article: XMLElement) -> UIScrollView{
        for element in article.css("h1, h2, p, img, li") {
            if let tag = element.tagName {
                switch tag {
                case "h1":
                    if let text = element.text {
                        header["text"] =  text
                        getHeader(header)
                    }
                case "h2" :
                    if let text = element.text{
                        getText(text: text, style: "h2")
                    }
                case "img":
                    if let className = element.className {
                        if className == "main-image" {
                            if let urlStr = element["src"] {
                                getImage(url: urlStr, first: true)
                            }
                        } else if let urlStr = element["src"] {
                            if urlStr != "" {
                                getImage(url: urlStr)
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
                            getMeta(header)
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

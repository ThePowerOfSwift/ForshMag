//
//  Posts.swift
//  ForshMag
//
//  Created by  Tim on 01.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import UIKit

enum Category: String {
    case learn = "#УЧИТЬСЯ"
    case to_do = "#ДЕЛАТЬ"
    case rest = "#ОТДЫХАТЬ"
    case none = "#БЕЗ РУБРИКИ"
}

class Post {
    private(set) var postTitle: String!
    private(set) var postURL: Int!
    private(set) var postMediaId: Int?
    private(set) var postPreview: URL?
    private(set) var postCategory: String!
    private(set) var postType: String!
    private let categories = ["#БЕЗ РУБРИКИ", "#УЧИТЬСЯ", "#ДЕЛАТЬ", "#ОТДЫХАТЬ"]
    
    init(title: String, category: Int, url: Int, type: String, mediaId: Int?, postPreview: URL?) {
        self.postTitle = title
        self.postURL = url
        self.postMediaId = mediaId
        self.postPreview = postPreview
        self.postType = type
        switch category {
        case 1:
            postCategory = Category.learn.rawValue
        case 2:
            postCategory = Category.to_do.rawValue
        case 3:
            postCategory = Category.rest.rawValue
        default:
            postCategory = Category.none.rawValue
        }
    }
}

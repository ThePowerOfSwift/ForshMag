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
    case none = "#БЕЗ РУБРИКИ"
    case learn = "#УЧИТЬСЯ"
    case rest = "#ОТДЫХАТЬ"
    case to_do = "#ДЕЛАТЬ"
}

class Post {
    private(set) var postTitle: String!
    private(set) var postURL: Int!
    private(set) var postMediaId: Int?
    private(set) var postPreview: URL?
    private(set) var postCategory: String!
    private(set) var postType: String!
    
    init(title: String, category: Int, url: Int, type: String, mediaId: Int?, postPreview: URL?) {
        self.postTitle = title
        self.postURL = url
        self.postMediaId = mediaId
        self.postPreview = postPreview
        self.postType = type
        switch category {
        case 2:
            postCategory = Category.learn.rawValue
        case 3:
            postCategory = Category.to_do.rawValue
        case 4:
            postCategory = Category.rest.rawValue
        default:
            postCategory = Category.none.rawValue
        }
    }
}

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
    private(set) var title: String
    private(set) var urlId: Int
    private(set) var category: String
    private(set) var type: String
    private(set) var mediaId: Int?
    private(set) var previewImgUrl: URL?
    
    init(title: String, category: Int, url: Int, type: String, mediaId: Int?, postPreview: URL?) {
        self.title = title
        self.urlId = url
        self.mediaId = mediaId
        self.previewImgUrl = postPreview
        self.type = type
        switch category {
        case 2:
            self.category = Category.learn.rawValue
        case 3:
            self.category = Category.to_do.rawValue
        case 4:
            self.category = Category.rest.rawValue
        default:
            self.category = Category.none.rawValue
        }
    }
}

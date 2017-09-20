//
//  Posts.swift
//  ForshMag
//
//  Created by  Tim on 01.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import UIKit

class Post {
    private var _postTitle: String!
    private var _postURL: Int!
    private var _postMediaId: Int?
    private var _postPreview: UIImage?
    private var _postCategory: String!
    private var _postType: String!
    private let _categories = ["#БЕЗ РУБРИКИ", "#УЧИТЬСЯ", "#ДЕЛАТЬ", "#ОТДЫХАТЬ"]
    
    var postTitle: String {
        return _postTitle
    }
    
    var postURL: Int {
        return _postURL
    }
    
    var postMediaId: Int? {
        return _postMediaId
    }
    
    var postType: String {
        return _postType
    }
    
    var postCategory: String {
        return _postCategory
    }
    
    var postPreview: UIImage? {
        return _postPreview
    }
    
    init(title: String, category: Int, url: Int, type: String, mediaId: Int?, postPreview: UIImage? = nil) {
        self._postTitle = title
        self._postURL = url
        if (mediaId != nil) {
            self._postMediaId = mediaId
        }
        if postPreview != nil {
            self._postPreview = postPreview
        }
        self._postType = type
        
        self._postCategory = _categories[category - 1]

    }
}

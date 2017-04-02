//
//  Posts.swift
//  ForshMag
//
//  Created by  Tim on 01.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation

class Post {
    private var _postTitle: String!
    private var _postURL: String!
    private var _postImgUrl: String?
    private var _postCategory: String!
    private var _postType: String!
    
    var postTitle: String {
        return _postTitle
    }
    
    var postURL: String {
        return _postURL
    }
    
    var postImgUrl: String? {
        return _postImgUrl
    }
    
    var postType: String {
        return _postType
    }
    
    var postCategory: String {
        return _postCategory
    }
    
    init(title: String, category: String, url: String, type: String, imgUrl: String?) {
        self._postTitle = title
        self._postURL = url
        if (imgUrl != nil) {
            self._postImgUrl = imgUrl
        }
        self._postType = type
        self._postCategory = "#" + category.localizedUppercase

    }
}

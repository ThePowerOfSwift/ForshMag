//
//  PostCellFactory.swift
//  ForshMag
//
//  Created by  Tim on 19.09.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import UIKit

protocol PostCellProtocol {
    static func make() -> PostCellProtocol
    func name() -> String
    func configureCell(post: Post, img: UIImage?)
}

typealias PostCellFactory = () -> PostCellProtocol

enum PostType {
    case w, w2, w4
}

enum PostCellHelper {
    static func factory(for type: PostType) -> PostCellFactory {
        switch type {
        case .w:
            return PostCellw.make
        case .w2:
            return PostCellw2.make
        case .w4:
            return PostCell.make
        }
    }
}

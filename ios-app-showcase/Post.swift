//
//  Post.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDesc: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _uid: String!
    private var _postKey: String!
    
    private var _postRef: Firebase!
    
    var description: String {
        return _postDesc
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    var uid: String? {
        return _uid
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDesc = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, props: [String: AnyObject]) {
        self._postKey = postKey
        
        if let likes = props["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = props["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let descr = props["description"] as? String {
            self._postDesc = descr
        }
        
        if let uid = props["uid"] as? String {
            self._uid = uid
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(_postKey)
    }
    
    func adjustLikes (addLike: Bool) {
        _likes! += addLike ? 1 : -1
        
        self._postRef.childByAppendingPath("likes").setValue(_likes)
    }
}
//
//  DataService.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation

import Firebase
import Alamofire

let URL_BASE = "https://ios-showcase-app.firebaseio.com"

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: URL_BASE)
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var imageCache = NSCache()
    
    func createFirebaseUser (uid: String, user: [String: String]) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)")
            .childByAppendingPath("/users")
            .childByAppendingPath(uid)
        
        return user!
    }

    func uploadImage(img: UIImage, _ cb: (err: NSError?, url: String?)->()) {
        let url = NSURL(string: "https://post.imageshack.us/upload_api.php")!
        let imgData = UIImageJPEGRepresentation(img, 0.6)!
        let keyData = IMGSHACK_API_KEY.dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
            
            multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
            multipartFormData.appendBodyPart(data: keyData, name: "key")
            multipartFormData.appendBodyPart(data: keyJSON, name: "format")
            
            }, encodingCompletion: { encodingResult in
                switch (encodingResult) {
                case .Success(let request, _, _):
                    request.responseJSON(completionHandler: { res in
                        var url: String?
                        
                        if let info = res.result.value as? [String: AnyObject] {
                            if let links = info["links"] as? [String: String] {
                                if let link = links["image_link"] {
                                    url = link
                                    self.imageCache.setObject(UIImage(data: imgData)!, forKey: link)
                                }
                            }
                        }
                        
                        cb(err: nil, url: url)
                    })
                case .Failure(let err):
                    cb(err: NSError(domain: "dunno", code: 1, userInfo: nil), url: nil)
                }
        })
    }
    
    func fetchImage(url: String, cb: (NSError?, UIImage?)->()) -> Request? {
        if let img = imageCache.objectForKey(url) {
            cb(nil, img as! UIImage)
            return nil
        }
        
        let request = Alamofire
            .request(.GET, url)
            .validate(contentType: ["image/*"])
            .response(completionHandler: { req, res, data, err in
                if err == nil {
                    let img = UIImage(data: data!)!
                    self.imageCache.setObject(img, forKey: url)
                    cb(nil, img)
                } else {
                    cb(err, nil)
                }
            })
        
        return request
    }
}
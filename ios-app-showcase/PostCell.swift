//
//  PostCell.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell (post: Post, img: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT
            .childByAppendingPath("likes")
            .childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.description
        self.likesLabel.text = String(post.likes)
        
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImage.image = img
            } else {
                request = Alamofire
                    .request(.GET, post.imageUrl!)
                    .validate(contentType: ["image/*"])
                    .response(completionHandler: { req, res, data, err in
                        if err == nil {
                            let img = UIImage(data: data!)!
                            self.showcaseImage.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl!)
                            
                        }
                    })
            }
        } else {
            self.showcaseImage.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let didNotLike = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
    var foo: String!
}


class Distance {
    private var _meters: Double
    
    init (m: Double) {
        _meters = m
    }
    
    var m: Double {
        return _meters
    }
    
    var ft: Double {
        return _meters / 0.3 // roughly :)
    }
    
    var km: Double {
        return _meters / 1000
    }
}

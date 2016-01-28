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
    @IBOutlet weak var profileImage: RemoteImage!
    @IBOutlet weak var showcaseImage: RemoteImage!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    var _oldPostDesc = ""
    
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
                self.showcaseImage.loadUrl(post.imageUrl!)
            }
        } else {
            self.showcaseImage.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
        DataService.ds.REF_USERS.childByAppendingPath(self.post.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let username = snapshot.value["username"] as! String
            self.usernameLabel.text = username
            
            if let pUrl = snapshot.value["profileImageUrl"] as? String {
                self.profileImage.loadUrl(pUrl)
                self.profileImage.alpha = 1
                self.profileImage.contentMode = .ScaleAspectFill
            }
        })
        
        if self.post.uid == DataService.ds.REF_USER_CURRENT.key {
            editButton.hidden = false
        }
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull {
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
    
    @IBAction func onEditTapped(sender: UIButton) {
        if !self.descriptionText.editable {
            _oldPostDesc = self.descriptionText.text!
            descriptionText.editable = true
            editButton.setTitle("Save", forState: .Normal)
            editButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            return
        }

        editButton.setTitle("Edit...", forState: .Normal)
        editButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        descriptionText.editable = false
        
        if let newPostText = descriptionText.text where newPostText != "" && newPostText != _oldPostDesc {
            DataService.ds.REF_POSTS.childByAppendingPath(post.postKey).childByAppendingPath("description").setValue(newPostText)
        } else {
            descriptionText.text = _oldPostDesc
        }
        
        _oldPostDesc = ""
    }
}

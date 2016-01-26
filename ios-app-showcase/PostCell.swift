//
//  PostCell.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: Post!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
}

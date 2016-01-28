//
//  FirstRunVC.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/26/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit

class FirstRunVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    let ipc = UIImagePickerController()
    var tap: UITapGestureRecognizer!
    
    var imagePicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = NSUserDefaults.standardUserDefaults().valueForKey("username") {
            performSegueWithIdentifier("toFeedVC", sender: nil)
            return
        }
        
        ipc.delegate = self
        
        tap = UITapGestureRecognizer(target: self, action: "onImageTapped:")
        imageButton.addGestureRecognizer(tap)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func onImageTapped(sender: AnyObject) {
        presentViewController(ipc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let img = info["UIImagePickerControllerOriginalImage"] as? UIImage
        
        imagePicked = true
        
        imageButton.image = img
        imageButton.layer.cornerRadius = imageButton.frame.size.width / 2
        imageButton.contentMode = .ScaleAspectFill
        imageButton.clipsToBounds = true
        imageButton.alpha = 1
        
        ipc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onContinue(sender: UIButton) {
        if let username = textField.text where username != "" {
            if imagePicked {
                DataService.ds.uploadImage(imageButton.image!, { err, url in
                    DataService.ds.REF_USER_CURRENT.childByAppendingPath("profileImageUrl").setValue(url)
                })
            }
            
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("username").setValue(username)
            NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
            NSUserDefaults.standardUserDefaults().synchronize()
            performSegueWithIdentifier("toFeedVC", sender: nil)
        } else {
            let originalBorder = self.textField.layer.borderWidth
            let originalColor = self.textField.layer.borderColor
            
            let b = CABasicAnimation(keyPath: "borderWidth")
            b.fromValue = originalBorder
            b.toValue = originalBorder + 0.5
            
            let c = CABasicAnimation(keyPath: "borderColor")
            c.fromValue = originalColor
            c.toValue = UIColor.redColor().CGColor
            
            let gr = CAAnimationGroup()
            gr.duration = 0.5
            gr.animations = [b, c]
            
            self.textField.layer.addAnimation(gr, forKey: "borderWidth and borderColor")
        }
    }
}

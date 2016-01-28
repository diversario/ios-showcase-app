//
//  FeedVC.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var postField: MaterialTextField!
    
    var posts = [Post]()
    var imagePicker = UIImagePickerController()
    var tap = UITapGestureRecognizer()
    
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        tap.delegate = self
        tap.addTarget(self, action: "onCameraButtonTapped:")
        
        cameraButton.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView()
        tableView.tableHeaderView = tableView.tableFooterView
        tableView.estimatedRowHeight = 350
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.posts = []
                
                for snap in snapshots {
                    if let postDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, props: postDict)
                        self.posts.append(post)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func onPostButton(sender: MaterialButton) {
        if let txt = postField.text where txt != "" {
            
            if let img = cameraButton.image where imageSelected {
                DataService.ds.uploadImage(img, { err, url in
                    if let _url = url {
                        self.postToFirebase(_url)
                    }
                })
            } else {
                postToFirebase(nil)
            }
        }
    }
    
    func onCameraButtonTapped(sender: AnyObject?) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cameraButton.image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        imageSelected = true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            var img: UIImage?

            if let url = post.imageUrl {
                img = DataService.ds.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            var img: UIImage?

            if let url = post.imageUrl {
                img = DataService.ds.imageCache.objectForKey(url) as? UIImage
            }
            
            let cell = PostCell()
            cell.configureCell(post, img: img)
            return cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func postToFirebase (imgUrl: String?) {
        var post: [String: AnyObject] = [
            "description": postField.text!,
            "likes": 0,
            "uid": DataService.ds.REF_USER_CURRENT.key
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(firebasePost.key).setValue(true)
        
        postField.text = ""
        cameraButton.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
}

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
    
    static var imageCache = NSCache()
    
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
            print(snapshot.value)
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.posts = []
                
                for snap in snapshots {
                    if let postDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func onPostButton(sender: MaterialButton) {
        if let txt = postField.text where txt != "" {
            
            if let img = cameraButton.image {
                let url = "https://api.imageshack.com/v2/images"
                let imgData = UIImageJPEGRepresentation(img, 0.6)!
                let keyData = IMGSHACK_API_KEY.dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
//                    multipartFormData.appendBodyPart(data: imgData, name: "file", fileName: "image", mimeType: "image/jpeg")
                    multipartFormData.appendBodyPart(data: keyData, name: "api_key", mimeType: "text/plain")
                    }, encodingCompletion: { encodingResult in
                        switch (encodingResult) {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { res in
                                if let info = res.result.value as? [String: AnyObject] {
                                    print(info)
                                }
                            })
                        case .Failure(let err):
                            print(err)
                        }
                })
            }
            
        }
    }
    
    func onCameraButtonTapped(sender: AnyObject?) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cameraButton.image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
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
}

//
//  HeaderVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/15/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class HeaderVC: UICollectionReusableView {
        
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var webTxt: UILabel!
    @IBOutlet weak var bioTxt: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingTitle: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    @IBAction func followBtn_clicked(sender: AnyObject) {
        let title = btn.titleForState(.Normal)
        
        //to follow
        if title == "FOLLOW"{
            let object = PFObject(className:"follow")
            object["follower"] = PFUser.currentUser()?.username
            object["following"] = guestname.last!
            object.saveInBackgroundWithBlock({ (success:Bool, error: NSError?)-> Void in
                if success {
                    self.btn.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    self.btn.backgroundColor = .greenColor()
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.currentUser()?.username
                    newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                    newsObj["to"] = guestname.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                    
                }else{
                    print(error?.localizedDescription)
                }
            })
            // unfollow
        } else{
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: guestname.last!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?)-> Void in
                if error == nil{
                    
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                self.btn.setTitle("FOLLOW", forState:
                                    UIControlState.Normal)
                                self.btn.backgroundColor = .lightGrayColor()
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                                newsQuery.whereKey("to", equalTo: guestname.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                
                            } else{
                                print(error?.localizedDescription)
                            }
                        })
                        
                    }
                    
                } else{
                    print(error?.localizedDescription)
                }
            })
            
        }

    
    }
    
    //default function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        let width = UIScreen.mainScreen().bounds.width
        
        avaImg.frame = CGRectMake(width / 16, width / 16, width / 4, width / 4)
        posts.frame = CGRectMake(width / 2.6, avaImg.frame.origin.y, 50, 30)
        followers.frame = CGRectMake(width / 1.7, avaImg.frame.origin.y, 50, 30)
        followings.frame = CGRectMake(width / 1.25, avaImg.frame.origin.y, 50, 30)
        
        postTitle.center = CGPointMake(posts.center.x - 10, posts.center.y + 20)
        followersTitle.center = CGPointMake(followers.center.x, followers.center.y + 20)
        followingTitle.center = CGPointMake(followings.center.x, followings.center.y + 20)
        
        btn.frame = CGRectMake(postTitle.frame.origin.x, postTitle.center.y + 20, width - postTitle.frame.origin.x - 10,30)
        fullname.frame = CGRectMake(avaImg.frame.origin.x, avaImg.frame.origin.y + avaImg.frame.size.height, width - 30, 30)
        webTxt.frame = CGRectMake(avaImg.frame.origin.x, fullname.frame.origin.y + 20, width - 30, 30)
        bioTxt.frame = CGRectMake(avaImg.frame.origin.x, webTxt.frame.origin.y + 30, width - 30, 30)
        
        //round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        
    }
    
}

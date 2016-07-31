//
//  FollowersCell.swift
//  Instagram
//
//  Created by Boyu Ran on 5/18/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class followersCell: UITableViewCell {

    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        let width = UIScreen.mainScreen().bounds.width
        
        avaImg.frame = CGRectMake(10, 10, width / 5.3, width / 5.3)
        username.frame = CGRectMake(avaImg.frame.size.width + 20, width / 10.666, width / 3.2, 30)
        followBtn.frame = CGRectMake(width - width / 3.5 - 20, 30, width / 3.5, 30)
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }
    

    @IBAction func followBtn_click(sender: AnyObject) {
        
        let title = followBtn.titleForState(.Normal)
        
        //to follow
        if title == "FOLLOW"{
            let object = PFObject(className:"follow")
            object["follower"] = PFUser.currentUser()?.username
            object["following"] = username.text
            object.saveInBackgroundWithBlock({ (success:Bool, error: NSError?)-> Void in
                if success {
                    self.followBtn.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    self.followBtn.backgroundColor = .greenColor()
                }else{
                print(error?.localizedDescription)
                }
            })
        // unfollow
        } else{
        
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: username.text!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?)-> Void in
                if error == nil{
                
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                self.followBtn.setTitle("FOLLOW", forState:
                                    UIControlState.Normal)
                                self.followBtn.backgroundColor = .lightGrayColor()
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
}

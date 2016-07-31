//
//  postCell.swift
//  Instagram
//
//  Created by Boyu Ran on 5/23/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var title: KILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var uuid: UILabel!
    
    //default func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        likeBtn.setTitleColor(UIColor.clearColor(), forState: .Normal)
        
        //double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(postCell.likeTap))
        likeTap.numberOfTapsRequired = 2
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
        
        
        
        
        let width = UIScreen.mainScreen().bounds.width
        
        //allow constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        date.translatesAutoresizingMaskIntoConstraints = false
        picImg.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        like.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        uuid.translatesAutoresizingMaskIntoConstraints = false
        
        
        let pictureWidth = width - 20
        //vertical constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(30)]-10-[pic(\(pictureWidth))]-5-[like(30)]",
            options: [], metrics: nil, views: ["ava":avaImg,"pic":picImg,"like":likeBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[username]",
            options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-5-[comment(30)]",
            options: [], metrics: nil, views: ["pic":picImg,"comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-15-[date]",
            options: [], metrics: nil, views: ["date":date]))
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[like]-5-[title]-5-|",
            options: [], metrics: nil, views: ["like":likeBtn,"title":title]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-5-[more(30)]",
            options: [], metrics: nil, views: ["pic":picImg,"more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[likes]",
            options: [], metrics: nil, views: ["pic":picImg,"likes":like]))
        
        //horizontal constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(30)]-10-[username]",
            options: [], metrics: nil, views: ["ava":avaImg,"username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[pic]-10-|",
            options: [], metrics: nil, views: ["pic":picImg]))
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]",
            options: [], metrics: nil, views: ["like":likeBtn,"likes":like,"comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[more(30)]-15-|",
            options: [], metrics: nil, views: ["more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[title]-15-|",
            options: [], metrics: nil, views: ["title":title]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":date]))
        
        
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
    }
    
    //double tap to like function
    func likeTap(){
        
        //create large like grey heart
        let likePic = UIImageView(image: UIImage(named: "ThumbUp.png"))
        likePic.frame.size.width = picImg.frame.size.width / 1.5
        likePic.frame.size.height = picImg.frame.size.width / 1.5
        likePic.center = picImg.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        //hide like picture with animation and transform to be smaller
        UIView.animateWithDuration(0.4) { 
            likePic.alpha = 0
            likePic.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }
        
        let title = likeBtn.titleForState(.Normal)
        
        if title == "unlike"{
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuid.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success{
                    print("liked")
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
                    
                    //send notification if we liked to refresh tableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked",object: nil)
               
                    //sned notification as like
                    if self.usernameBtn.titleLabel?.text != PFUser.currentUser()?.username {
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.currentUser()?.username
                    newsObj["to"] = self.usernameBtn.titleLabel!.text
                    newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                    newsObj["owner"] = self.usernameBtn.titleLabel!.text
                    newsObj["uuid"] = commentuuid.last
                    newsObj["type"] = "like"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                        
                    }
                }
            })
        }
        
        
    }

    @IBAction func likeBtn_clicked(sender: AnyObject) {
        let title = sender.titleForState(.Normal)
        //to like
        if title == "unlike"{
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuid.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success{
                    print("liked")
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
                    
                    //send notification if we liked to refresh tableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked",object: nil)
                
                
                    // send notification as like
                    if self.usernameBtn.titleLabel?.text != PFUser.currentUser()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.currentUser()?.username
                        newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                        newsObj["to"] = self.usernameBtn.titleLabel!.text
                        newsObj["owner"] = self.usernameBtn.titleLabel!.text
                        newsObj["uuid"] = self.uuid.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                }
            
            //to dislike
            }else{
                    
                    //request existing likes of current user to show post
                    let query = PFQuery(className: "likes")
                    query.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                    query.whereKey("to", equalTo: self.uuid.text!)
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, erro:NSError?) in
                        
                        for object in objects!{
                            object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                                if success{
                                    print("disliked")
                                    self.likeBtn.setTitle("unlike", forState: .Normal)
                                    self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
                                    
                            //send notification if we liked to refresh tableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked",object: nil)
                                
                            // delete like notification
                                    let newsQuery = PFQuery(className: "news")
                                    newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                                    newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                                    newsQuery.whereKey("uuid", equalTo: self.uuid.text!)
                                    newsQuery.whereKey("type", equalTo: "like")
                                    newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                        if error == nil {
                                            for object in objects! {
                                                object.deleteEventually()
                                            }
                                        }
                                    })
                                
                                }
                            })
                        }
                    })
                }
            
            })
        }
    }
}
    



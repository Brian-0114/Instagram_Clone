//
//  tabbarVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/23/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

// global variables of icons
var icons = UIScrollView()
var corner = UIImageView()
var dot = UIView()

class tabbarVC: UITabBarController {

    //default function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabBar.tintColor = .whiteColor()
        self.tabBar.barTintColor = UIColor(red: 37.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1)
        self.tabBar.translucent = false
        
        
        //create total icons
        icons.frame = CGRectMake(self.view.frame.size.width / 5 * 3 + 10, self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, 50, 35)
        self.view.addSubview(icons)
        
        // create corner
        corner.frame = CGRectMake(icons.frame.origin.x, icons.frame.origin.y + icons.frame.size.height, 20, 14)
        corner.center.x = icons.center.x
        corner.image = UIImage(named: "corner.png")
        corner.hidden = true
        self.view.addSubview(corner)
        
        // create dot
        dot.frame = CGRectMake(self.view.frame.size.width / 5 * 3, self.view.frame.size.height - 5, 7, 7)
        dot.center.x = self.view.frame.size.width / 5 * 3 + (self.view.frame.size.width / 5) / 2
        dot.backgroundColor = UIColor(red: 251/255, green: 103/255, blue: 29/255, alpha: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.hidden = true
        self.view.addSubview(dot)
        
        // call function of all type of notifications
        query(["like"], image: UIImage(named: "likeIcon.png")!)
        query(["follow"], image: UIImage(named: "followIcon.png")!)
        query(["mention", "comment"], image: UIImage(named: "commentIcon.png")!)
        
        // hide icons objects
        UIView.animateWithDuration(1, delay: 5, options: [], animations: { () -> Void in
            icons.alpha = 0
            corner.alpha = 0
            dot.alpha = 0
            }, completion: nil)
    }

    // multiple query
    func query (type:[String], image:UIImage) {
        
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.currentUser()!.username!)
        //query.whereKey("checked", equalTo: "no")
        query.whereKey("type", containedIn: type)
        query.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                if count > 0 {
                    self.placeIcon(image, text: "\(count)")
                }
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // multiple icons
    func placeIcon (image:UIImage, text:String) {
        
        // create separate icon
        let view = UIImageView(frame: CGRectMake(icons.contentSize.width, 0, 50, 35))
        view.image = image
        icons.addSubview(view)
        
        // create label
        let label = UILabel(frame: CGRectMake(view.frame.size.width / 2, 0, view.frame.size.width / 2, view.frame.size.height))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.text = text
        label.textAlignment = .Center
        label.textColor = .whiteColor()
        view.addSubview(label)
        
        // update icons view frame
        icons.frame.size.width = icons.frame.size.width + view.frame.size.width - 4
        icons.contentSize.width = icons.contentSize.width + view.frame.size.width - 4
        icons.center.x = self.view.frame.size.width / 5 * 4 - (self.view.frame.size.width / 5) / 4
        
        // unhide elements
        corner.hidden = false
        dot.hidden = false
    }
    
    
    // clicked upload button (go to upload)
    func upload(sender : UIButton) {
        self.selectedIndex = 2
    }



}

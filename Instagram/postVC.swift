//
//  postVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/23/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()

class postVC: UITableViewController {
    
    
    //arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [NSDate?]()
    
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title label at the top
        self.navigationItem.title = "Photo"
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(postVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        //receive notification from postCell
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postVC.refresh), name: "liked", object: nil)
        
        //dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 108
        
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil{
                self.avaArray.removeAll(keepCapacity: false)
                self.usernameArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                self.titleArray.removeAll(keepCapacity: false)
                
                for object in objects!{
                    self.avaArray.append(object.valueForKey("ava") as! PFFile)
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    self.uuidArray.append(object.valueForKey("uuid")as! String)
                    self.titleArray.append(object.valueForKey("title")as! String)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    //refresh function
    func refresh(){
        self.tableView.reloadData()
    }
    
    
    //click username
    @IBAction func usernameBtn_click(sender: AnyObject) {
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username{
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    //go comment
    @IBAction func commentBtn_click(sender: AnyObject) {
        
        //call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        //send related data to global variable
        commentuuid.append(cell.uuid.text!)
        commentowner.append((cell.usernameBtn.titleLabel?.text!)!)
        //go to comments, present VC
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    //clicked more button
    @IBAction func moreBtn_clicked(sender: AnyObject) {
        
        //call index of button 
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        //delete action
        let delete = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) in
            //step 1. Delete row from tableView
            self.usernameArray.removeAtIndex(i.row)
            self.avaArray.removeAtIndex(i.row)
            self.dateArray.removeAtIndex(i.row)
            self.picArray.removeAtIndex(i.row)
            self.titleArray.removeAtIndex(i.row)
            self.uuidArray.removeAtIndex(i.row)
            
            //step 2 delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuid.text!)
            postQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            if success{
                                //send notification to rootViewController to update shown posts
                                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                                
                                //push back
                                self.navigationController?.popViewControllerAnimated(true)
                            } else{
                                print(error?.localizedDescription)
                            }
                        })
                    }
                } else{
                    print(error?.localizedDescription)
                }
            })
            
            
            //step 2 Delete likes of post from server
            let likeQuery = PFQuery(className:"likes")
            likeQuery.whereKey("to", equalTo: cell.uuid.text!)
            likeQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            
            //step 3 delete comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuid.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }
            })
            
            //step 4 delete hashtags of post from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuid.text!)
            hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }
            })
        }
        
        let complain = UIAlertAction(title: "Complain", style: .Default) { (UIAlertAction) in
            //send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.currentUser()?.username
            complainObj["to"] = cell.uuid.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success{
                    print("success")
                } else{
                    print(error?.localizedDescription)
                }
            })
        }
        
        //Cancel Action
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        //create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .ActionSheet)
        
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username{
            menu.addAction(delete)
            menu.addAction(cancel)
        }else{
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        //show menu
        self.presentViewController(menu, animated: true, completion: nil)
        
    }
    
    //go back function
    func back(sender:UIBarButtonItem){
        //push back
        self.navigationController?.popViewControllerAnimated(true)
        //clean postuuid from last hold
        if !postuuid.isEmpty{
            postuuid.removeLast()
        }
    
    }
    
    //cell #
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }
    
    //cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath) as! postCell
        
        //connect objects with our information from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: UIControlState.Normal)
        cell.usernameBtn.sizeToFit()
        cell.uuid.text = uuidArray[indexPath.row]
        cell.title.text = titleArray[indexPath.row]
        cell.title.sizeToFit()
        //place profile pic
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        //place post picture
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            cell.picImg.image = UIImage(data: data!)
        }
        
        //calculate post date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day,.WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        if difference.second <= 0{
            cell.date.text = "now"
        }
        if difference.second > 0 && difference.minute == 0{
            cell.date.text = "\(difference.second)s."   //show 25s for example
        }
        
        if difference.minute > 0 && difference.hour == 0{
            cell.date.text = "\(difference.minute)m."   //1m for example
        }
        if difference.hour > 0 && difference.day == 0{
            cell.date.text = "\(difference.hour)h."
        }
        if difference.day > 0 && difference.weekOfMonth == 0{
            cell.date.text = "\(difference.day)d."
        }
        if difference.weekOfMonth > 0{
            cell.date.text = "\(difference.weekOfMonth)w."
        }
        
        //manipulate like button depending on if clicked or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        didLike.whereKey("to", equalTo: cell.uuid.text!)
        didLike.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            if count == 0{
                cell.likeBtn.setTitle("unlike", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
            }else{
                cell.likeBtn.setTitle("like", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
            }
        }
        
        //count total likes of shown posts
        let countlikes = PFQuery(className: "likes")
        countlikes.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        countlikes.whereKey("to", equalTo: cell.uuid.text!)
        countlikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            cell.like.text = "\(count)"
        }
        
        
        //assign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        //@mention is tapped
        cell.title.userHandleLinkTapHandler = {label,handle,rang in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            if mention.lowercaseString == PFUser.currentUser()?.username {
                let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            }else{
                guestname.append(mention.lowercaseString)
                let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        //#hashtag is tapped
        cell.title.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention)
            let hash = self.storyboard?.instantiateViewControllerWithIdentifier("hashtagVC") as! hashtagVC
            self.navigationController?.pushViewController(hash, animated: true)
            
        }
        return cell
    }

   
}

//
//  commentVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/24/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentowner = [String]()

class commentVC: UIViewController,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var send: UIButton!
    var refresher = UIRefreshControl()
    
    //values for resetting UI to default
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    //arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dataArray = [NSDate?]()
    
    //value to hold keyboard frame size
    var keyboard = CGRect()

    //page size
    var page : Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "COMMENTS"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(commentVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(commentVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        
        //catch notification 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //disable the send button
        send.enabled = false
        
        //alignment
        alignment()
        loadComments()
    }
    
    func keyboardWillShow(notification: NSNotification){
        
        
        //define keyboard frame size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //move UI up
        UIView.animateWithDuration(0.4) { 
                self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.comment.frame.size.height + self.commentHeight
                self.comment.frame.origin.y = self.commentY - self.keyboard.height - self.comment.frame.size.height + self.commentHeight
                self.send.frame.origin.y = self.comment.frame.origin.y
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
    
        //move UI down
        UIView.animateWithDuration(0.4) { 
            self.tableView.frame.size.height = self.tableViewHeight
            self.comment.frame.origin.y = self.commentY
            self.send.frame.origin.y = self.commentY
        }
    }
    
    //cell editable
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    //swipe cell for actions
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! commentCell
        //Action 1. Delete comment from server
        let delete = UITableViewRowAction(style: .Normal, title: "    ") { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentlabel.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
            
            //step 2 delete #hashtag from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last!)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.commentlabel.text!)
            hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }
            })
            //step 3 Delete notification: mention comment
            let newsQuery = PFQuery(className: "news")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            newsQuery.whereKey("to", equalTo: commentowner.last!)
            newsQuery.whereKey("uuid", equalTo: commentuuid.last!)
            newsQuery.whereKey("type", containedIn: ["comment","mention"])
            newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }
            })
            //close cell
            tableView.setEditing(false, animated: true)
            
            //step 3. delete comment row from tableView
            self.commentArray.removeAtIndex(indexPath.row)
            self.dataArray.removeAtIndex(indexPath.row)
            self.usernameArray.removeAtIndex(indexPath.row)
            self.avaArray.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        //Action 2. Mention or address message to someone
        let address = UITableViewRowAction(style: .Normal, title: "    ") { (action: UITableViewRowAction, indexPath:NSIndexPath) in
            self.comment.text = "\(self.comment.text + "@" + self.usernameArray[indexPath.row] + " ")"
            
            self.send.enabled = true
            
            tableView.setEditing(false, animated: true)
        }
        
        //Action 3 Complain
        let complain = UITableViewRowAction(style: .Normal, title: "3") { (action:UITableViewRowAction, indexPath: NSIndexPath) in
            //send complain to server regarding selected comment
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.currentUser()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentlabel.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success{
                    self.alert("complain has been made successfully",message: "Thank you, we will consider your complain")
                }else{
                    self.alert("Error",message: error!.localizedDescription)
                }
            })
            
            //close cell
            tableView.setEditing(false, animated: true)
        }
        
        //button background
        delete.backgroundColor = UIColor(patternImage: UIImage(named:"delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor.grayColor()
        
        //comment belongs to user
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username{
            return [delete,address]
        }
        //post belongs to user
        else if commentowner.last == PFUser.currentUser()?.username{
            return [delete,address,complain]
        }
        //posts belong to another user
        else{
            return[address,complain]
        }
    }
    
    func alert(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //back function
    func back(sender : UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
        
        //clean comments uuid from last holding information
        if !commentuuid.isEmpty{
            commentuuid.removeLast()
        }
        
        //clean comment owner 
        if !commentowner.isEmpty{
            commentowner.removeLast()
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        //hide bottom bar
        self.tabBarController?.tabBar.hidden = true
        //call keyboard
        comment.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
   
    func alignment(){
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRectMake(0, 0, width, height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        comment.frame = CGRectMake(10, tableView.frame.size.height + height / 50, width / 1.306, 33)
        comment.layer.cornerRadius = comment.frame.size.width / 50
        
        send.frame = CGRectMake(comment.frame.origin.x + comment.frame.size.width + width / 32, comment.frame.origin.y, width - (comment.frame.origin.x + comment.frame.size.width) - (width / 32) * 2, comment.frame.size.height)
        
        
        //delegates
        comment.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //assign resetting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = comment.frame.size.height
        commentY = comment.frame.origin.y
        
    }
    
    //while writing something
    func textViewDidChange(textView: UITextView) {
        //disable button if no text entered
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        
        if !comment.text.stringByTrimmingCharactersInSet(spacing).isEmpty{
            send.enabled  = true
        } else{
            send.enabled  = false
        }
        
        //+ paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130{
            let difference = textView.contentSize.height - textView.frame.size.height
            
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            //move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        
        // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            let difference = textView.frame.size.height - textView.contentSize.height
            
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            //move down tableView
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
        
    }
    
    //load comments function
    func loadComments(){
        
        
        //Step 1: Count total comments in order to skip all except(page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            
            //if comments on the server for the current post are more than 15, implement pull to refresh func
            if self.page < count{
                self.refresher.addTarget(self, action: #selector(commentVC.loadMore), forControlEvents: UIControlEvents.ValueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            //step 2. Request Last 15 comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    
                    //clean up
                    self.usernameArray.removeAll(keepCapacity: false)
                    self.avaArray.removeAll(keepCapacity: false)
                    self.commentArray.removeAll(keepCapacity: false)
                    self.dataArray.removeAll(keepCapacity: false)
                    
                    //find related objects
                    for object in objects!{
                        self.usernameArray.append(object.objectForKey("username") as! String)
                        self.avaArray.append(object.objectForKey("ava") as! PFFile)
                        self.commentArray.append(object.objectForKey("comment")as! String)
                        self.dataArray.append(object.createdAt)
                        self.tableView.reloadData()
                        
                        //scroll to bottom
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:self.commentArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    }
                } else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    //pagination
    func loadMore(){
        //step 1. Count total comments in order to skip all except ( page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            //self refresher
            self.refresher.endRefreshing()
            
            //remove refresher if loaded all comments
            if self.page >= count{
                self.refresher.removeFromSuperview()
            }
            
            //step 2 load more comments
            if self.page < count{
                
                self.page = self.page + 15
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                    if error == nil{
                        
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        self.commentArray.removeAll(keepCapacity: false)
                        self.dataArray.removeAll(keepCapacity: false)
                        
                        //find related objects
                        for object in objects!{
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.commentArray.append(object.objectForKey("comment")as! String)
                            self.dataArray.append(object.createdAt)
                            self.tableView.reloadData()
                            
                        }
                    } else{
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    //clicked username button
    @IBAction func usernameBtn_clicked(sender: AnyObject) {
        
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        let cell = tableView.cellForRowAtIndexPath(i) as! commentCell
        
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username{
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else{
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    @IBAction func sendBtn_clicked(sender: AnyObject) {
        
        //step 1 add row in tableView
        usernameArray.append(PFUser.currentUser()!.username!)
        avaArray.append(PFUser.currentUser()?.objectForKey("ava") as! PFFile)
        dataArray.append(NSDate())
        commentArray.append(comment.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        tableView.reloadData()
    
        //step 2 send comments to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.currentUser()?.username
        commentObj["ava"] = PFUser.currentUser()?.valueForKey("ava")
        commentObj["comment"] = comment.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        commentObj.saveEventually()
        
        
        //STEP 3 send #hashtag to server
        let words:[String] = comment.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for var word in words {
            if word.hasPrefix("#"){
                
                //cut symbol
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = PFUser.currentUser()?.username
                hashtagObj["hashtag"] = word.lowercaseString
                hashtagObj["comment"] = comment.text
                hashtagObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                    if success{
                        print("hashtag \(word) is created")
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        //step 4 sned notification as @mention
        var mentionCreated = Bool()
        
        for var word in words{
            
            if word.hasPrefix("@"){
                
                //cut symbol
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let newsObj = PFObject(className: "news")
                newsObj["by"] = PFUser.currentUser()?.username
                newsObj["to"] = word
                newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                newsObj["owner"] = commentowner.last
                newsObj["uuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                mentionCreated = true
            }
        }
        
        //step 5 send notification as comment 
        if commentowner.last != PFUser.currentUser()?.username && mentionCreated == false {
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.currentUser()?.username
            newsObj["to"] = commentowner.last
            newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
            newsObj["owner"] = commentowner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        
        
        //scroll to bottom
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: commentArray.count - 1,inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        
        //step 6 reset UI
        send.enabled = false
        comment.text = ""
        comment.frame.size.height = commentHeight
        comment.frame.origin.y = send.frame.origin.y
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.comment.frame.size.height + self.commentHeight
    
    }
    //cell numb
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    //cell height
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //cell config
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! commentCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: .Normal)
        cell.usernameBtn.sizeToFit()
        
        cell.commentlabel.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            cell.avaImg.image = UIImage(data:data!)
        }
        
        //calculate date
        let from = dataArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference  = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        if difference.second <= 0{
            cell.date.text = "now"
        }
        if difference.second > 0 && difference.minute == 0{
            cell.date.text = "\(difference.second)s"
        }
        if difference.minute > 0 && difference.hour == 0{
            cell.date.text = "\(difference.minute)m"
        }
        if difference.hour > 0 && difference.day == 0{
            cell.date.text = "\(difference.hour)h"
        }
        
        if difference.day > 0 && difference.weekOfMonth==0 {
            cell.date.text = "\(difference.day)d"
        }
        if difference.weekOfMonth > 0{
            cell.date.text = "\(difference.weekOfMonth)w"
        }
        
        
        //@mention is tapped
        cell.commentlabel.userHandleLinkTapHandler = {label,handle,rang in
            
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
        cell.commentlabel.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercaseString)
            let hash = self.storyboard?.instantiateViewControllerWithIdentifier("hashtagVC") as! hashtagVC
            self.navigationController?.pushViewController(hash, animated: true)
            
        }
        //assign indexes of buttons
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }

  

}

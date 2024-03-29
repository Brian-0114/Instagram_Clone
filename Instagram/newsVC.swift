//
//  newsVC.swift
//  Instagram
//
//  Created by Boyu Ran on 6/30/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class newsVC: UITableViewController {

    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [NSDate?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic tableView height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        // title at the top
        self.navigationItem.title = "NOTIFICATIONS"
        
        // request notifications
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.currentUser()!.username!)
        query.limit = 30
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                self.typeArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                self.ownerArray.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.objectForKey("by") as! String)
                    self.avaArray.append(object.objectForKey("ava") as! PFFile)
                    self.typeArray.append(object.objectForKey("type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.objectForKey("uuid") as! String)
                    self.ownerArray.append(object.objectForKey("owner") as! String)
                    
                    
                    
                    // save notifications as checked
                    object["checked"] = "yes"
                    object.saveEventually()
                }
                
                // reload tableView to show received data
                self.tableView.reloadData()
            }
        })

    }

    //cell #
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // declare cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! newsCell
        
        // connect cell objects with received data from server
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: .Normal)
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second <= 0 {
            cell.datelbl.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            cell.datelbl.text = "\(difference.second)s."
        }
        if difference.minute > 0 && difference.hour == 0 {
            cell.datelbl.text = "\(difference.minute)m."
        }
        if difference.hour > 0 && difference.day == 0 {
            cell.datelbl.text = "\(difference.hour)h."
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.datelbl.text = "\(difference.day)d."
        }
        if difference.weekOfMonth > 0 {
            cell.datelbl.text = "\(difference.weekOfMonth)w."
        }
        
        // define info text
        if typeArray[indexPath.row] == "mention" {
            cell.infolabel.text = "has mentioned you."
        }
        if typeArray[indexPath.row] == "comment" {
            cell.infolabel.text = "has commented your post."
        }
        if typeArray[indexPath.row] == "follow" {
            cell.infolabel.text = "now following you."
        }
        if typeArray[indexPath.row] == "like" {
            cell.infolabel.text = "likes your post."
        }
        
        
        // asign index of button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // clicked username button
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! newsCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    
    // clicked cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("pressed")
        // call cell for calling cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! newsCell
        
        
        // going to @menionted comments
        if cell.infolabel.text == "has mentioned you." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go comments
            let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // going to own comments
        if cell.infolabel.text == "has commented your post." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go comments
            let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // going to user followed current user
        if cell.infolabel.text == "now following you." {
            
            // take guestname
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            
            // go guest
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        
        // going to liked post
        if cell.infolabel.text == "likes your post." {
            
            // take post uuid
            postuuid.append(uuidArray[indexPath.row])
            
            // go post
            let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
            self.navigationController?.pushViewController(post, animated: true)
        }
        
    }

    
    
}

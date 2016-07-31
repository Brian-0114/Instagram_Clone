//
//  folowersVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/18/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

var show = String()
var user = String()


class followersVC: UITableViewController {

    //arays to hold data received from servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    //Array showing who do we follow or who followings us
    var followArray = [String]()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()

       //title at the top
        self.navigationItem.title = show
        
        if show == "followers"{
        loadFollowers()
        }
        
        if show == "followings"{
        loadFollowings()
        }
    }
    
    func loadFollowers(){
        
        //step 1: find in FOLLOW class people following User
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil{
                
                //clean up
                self.followArray.removeAll(keepCapacity: false)
                
                //Step 2. Hold received data
                //find related objects depending on query settings
                for object in objects!{
                self.followArray.append(object.valueForKey("follower") as! String)
                }
                
                //Step 3. Find in USER data of users following "user"
                //find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn:  self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?)-> Void in
                    if error == nil{
                        
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        
                        //find related objects in User class of Parse
                        for object in objects!{
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    func loadFollowings(){
    
        //step 1: find in FOLLOW class people following User
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil{
                
                //clean up
                self.followArray.removeAll(keepCapacity: false)
                
                //Step 2. Hold received data
                //find related objects depending on query settings
                for object in objects!{
                    self.followArray.append(object.valueForKey("following") as! String)
                }
                
                //Step 3. Find in USER data of users following "user"
                //find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn:  self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?)-> Void in
                    if error == nil{
                        
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        
                        //find related objects in User class of Parse
                        for object in objects!{
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //cell #
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    //cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    
    
    //cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        // Configure the cell...
        cell.username.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error:NSError?)-> Void in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        //show do user following or do not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("following", equalTo: cell.username.text!)
        query.countObjectsInBackgroundWithBlock { (count:Int32, error: NSError?)-> Void in
            if error == nil{
                if count == 0 {
                    cell.followBtn.setTitle("FOLLOW", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = .lightGrayColor()
                } else{
                    cell.followBtn.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = UIColor.greenColor()
                }
            }
        }
        
        if cell.username.text == PFUser.currentUser()?.username{
            cell.followBtn.hidden = true
        }
        
        return cell
    }
   

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        //if user tapped himself , go home , else go to guest profile
        if cell.username.text! == PFUser.currentUser()?.username{
        
                let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
        }
        else{
                guestname.append(cell.username.text!)
                let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

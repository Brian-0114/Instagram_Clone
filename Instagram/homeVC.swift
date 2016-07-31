//
//  homeVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/15/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class homeVC: UICollectionViewController {

    //refresher
    var refresher: UIRefreshControl!
    
    //size of page
    var page : Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        
        //background color
        collectionView?.backgroundColor = .whiteColor();
        
        //title at the top
        self.navigationItem.title = PFUser.currentUser()?.username?.uppercaseString
        
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //receive notification from editVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(homeVC.reload(_:)), name: "reload", object: nil)
        
        
        //load posts func
        loadPosts()
    }
    
    //refreshing func
    func refresh(){
        //reload data information
        collectionView?.reloadData()
        
        //
        refresher.endRefreshing()
    }
    
        
    //reload func
    func reload(notification: NSNotification){
      collectionView?.reloadData()
    }
    
    //load posts func
    func loadPosts(){
        
        let query = PFQuery(className:"posts")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                
                    //add found data to arrays(holders)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            } else{
                print(error!.localizedDescription)
            }
        }
    }

    //load more while scrolling down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMore()
        }
    }
    
    
    //paging
    
    func loadMore(){
        //if there is more objects
        if page <= picArray.count {
            
            //increase page size
            page = page + 12
        
            //load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    //clean up
                    self.uuidArray.removeAll(keepCapacity: false)
                    self.picArray.removeAll(keepCapacity: false)
                    
                    for object in objects! {
                        
                        //add found data to arrays(holders)
                        self.uuidArray.append(object.valueForKey("uuid") as! String)
                        self.picArray.append(object.valueForKey("pic") as! PFFile)
                    }
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                } else{
                    print(error!.localizedDescription)
                }
            })
        }
    }
    //cell #
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    //cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath
    indexPath : NSIndexPath) -> CGSize{
    
        let size = CGSize(width:self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        return size
    
    }
    
    
    
    //cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        
        //get picture from the picArray
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.picImg.image = UIImage(data:data!)
                
            }else{
                print(error!.localizedDescription)
            }

        }
        
        return cell
    }
    
    
    //header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderVC
        
        //step 1 get user data
        //get user's data from PFuser class
        header.fullname.text = (PFUser.currentUser()?.objectForKey("fullname") as? String)?.uppercaseString
        header.webTxt.text = PFUser.currentUser()?.objectForKey("web") as? String
        header.webTxt.sizeToFit()
        header.bioTxt.text = PFUser.currentUser()?.objectForKey("bio") as? String
        header.bioTxt.sizeToFit()
        header.btn.setTitle("edit profile", forState: UIControlState.Normal)
        
        let avaQuery = PFUser.currentUser()?.objectForKey("ava") as! PFFile
        avaQuery.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            header.avaImg.image = UIImage(data:data!)
        }
        
        //step 2 count statistics
        
        //count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.posts.text = "\(count)"
            }
        })
        
        //count total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        followers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.followers.text = "\(count)"
            }
        })
        
        //count total following
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followings.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.followings.text = "\(count)"
            }
        })
        
        //step 3 Implement tap gestures
        
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
        
    }
    
    func postsTap(){
    
        if !picArray.isEmpty{
            
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    func followersTap(){
        user = PFUser.currentUser()!.username!
        show = "followers"
        
        
        //make reference to followersVC
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //present
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    func followingsTap(){
        user = PFUser.currentUser()!.username!
        show = "followings"
        
        //make reference to followersVC
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //present
        self.navigationController?.pushViewController(followings, animated: true)
    }


    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?)-> Void in
            if error == nil{
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let signin = self.storyboard?.instantiateViewControllerWithIdentifier("signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController =  signin
            }
        }
    }
   
    //go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        //navigate to post view controller
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
}

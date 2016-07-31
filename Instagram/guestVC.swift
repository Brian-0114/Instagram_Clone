//
//  guestVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/19/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()

class guestVC: UICollectionViewController {

    //UI objects
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    //arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()

        //allow vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        self.collectionView?.backgroundColor = .whiteColor()
        
        self.navigationItem.title = guestname.last?.uppercaseString
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(guestVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //call loadPosts function
        loadPosts()
    }
    
    func back(sender : UIBarButtonItem){
    
        self.navigationController?.popViewControllerAnimated(true)
        
        if !guestname.isEmpty{
            guestname.removeLast()
        
        }
    }
    
    func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    func loadPosts(){
    
        //load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username",  equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?)-> Void in
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                
                //find related objects
                for object in objects! {
                    
                    
                    //hold found information in arrays
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            }else{
                print(error?.localizedDescription)
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
            query.whereKey("username", equalTo: guestname.last!)
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
                    self.collectionView?.reloadData()
                } else{
                    print(error!.localizedDescription)
                }
            })
        }
    }

    
    //cell #
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        //define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?)-> Void in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
    return cell
    }
    
    //header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        //define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderVC
        
        //Step 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?)-> Void in
            if error == nil{
                if objects!.isEmpty{
                    let alert = UIAlertController(title: "\(guestname.last!.uppercaseString)", message: "does not exist", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
                for object in objects!{
                    header.fullname.text = (object.objectForKey("fullname") as? String)?.uppercaseString
                    header.bioTxt.text = object.objectForKey("bio") as? String
                    header.bioTxt.sizeToFit()
                    header.webTxt.text = object.objectForKey("web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.objectForKey("ava") as? PFFile)!
                    avaFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        header.avaImg.image = UIImage(data:data!)
                    })
                }
            }else{
                print(error?.localizedDescription)
            }
        }
        
    //step 2 show do current user follow guest or do not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if error == nil{
                if count == 0 {
                    header.btn.setTitle("FOLLOW", forState: .Normal)
                    header.btn.backgroundColor = .lightGrayColor()
                }else{
                    header.btn.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    header.btn.backgroundColor = .greenColor()
                }
                
            
            }else{
                print(error?.localizedDescription)
            }
        }
        
    //step 3 count statistics
    //count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?)-> Void in
            if error == nil{
                header.posts.text = "\(count)"
            } else{
                print(error?.localizedDescription)
            }
        })
    //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?)-> Void in
            if error == nil{
                header.followers.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        })
    //count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?)-> Void in
            if error == nil{
                header.followings.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        })
    
    //step 4 implement tap gestures
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //tap to followers
        let followersTap = UITapGestureRecognizer(target:self, action:#selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //tap to following label
        let followingsTap = UITapGestureRecognizer(target:self, action:#selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)

        return header
        
    }
    
    func postsTap(){
        if !picArray.isEmpty{
            let index = NSIndexPath(forItem: 3, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
            
            
        }
    }
    
    func followersTap(){
        user = guestname.last!
        show = "followers"
        
        //define followers
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        //navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    func followingsTap(){
        user = guestname.last!
        show = "followings"
        
        //define followersVC
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        self.navigationController?.pushViewController(followings, animated: true)
        
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


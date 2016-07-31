//
//  hashtagVC.swift
//  Instagram
//
//  Created by Boyu Ran on 6/27/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

var hashtag = [String]()

class hashtagVC: UICollectionViewController {
    //UI objects
    var refresher: UIRefreshControl!
    var page : Int = 24
    
    //arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercaseString)"
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(hashtagVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hashtagVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(hashtagVC.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        loadHashtags()
    }
    
    //go back func
    func back(sender : UIBarButtonItem){
        
        self.navigationController?.popViewControllerAnimated(true)
        
        if !hashtag.isEmpty{
            hashtag.removeLast()
            
        }
    }
    
    func refresh(){
        //call refresh
        loadHashtags()
    }
    
    //load hash function
    func loadHashtags(){
        
        //Step 1. Find posts related to hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil{
                
                //clean up
                self.filterArray.removeAll(keepCapacity: false)
                
                for object in objects!{
                
                    self.filterArray.append(object.valueForKey("to") as! String)
                }
                
                //step 2 find posts that have uuid appended to filterArray
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                    if error == nil{
                        
                        //clean up
                        self.picArray.removeAll(keepCapacity: false)
                        self.uuidArray.removeAll(keepCapacity: false)
                        
                        //find related objects
                        for object in objects!{
                            self.picArray.append(object.valueForKey("pic") as! PFFile)
                            self.uuidArray.append(object.valueForKey("uuid") as! String)
                        }
                        
                        //reload
                        
                        self.collectionView?.reloadData()
                        print("reloaded view")

                        
                    }else{
                        print(error?.localizedDescription)
                    }
                })
            } else{
                print(error?.localizedDescription)
            }
        }
    }
    
    //scrolled down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
    
    func loadMore(){
        if page <= uuidArray.count{
            page = page + 15
            
            //Step 1. Find posts related to hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                    
                    //clean up
                    self.filterArray.removeAll(keepCapacity: false)
                    
                    for object in objects!{
                        
                        self.filterArray.append(object.valueForKey("to") as! String)
                    }
                    
                    //step 2 find posts that have uuid appended to filterArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                        if error == nil{
                            
                            //clean up
                            self.picArray.removeAll(keepCapacity: false)
                            self.uuidArray.removeAll(keepCapacity: false)
                            
                            //find related objects
                            for object in objects!{
                                self.picArray.append(object.valueForKey("pic") as! PFFile)
                                self.uuidArray.append(object.valueForKey("uuid") as! String)
                            }
                            
                            //reload
                            self.collectionView?.reloadData()
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
                } else{
                    print(error?.localizedDescription)
                }
            }

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
    
    //go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        //navigate to post view controller
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
}

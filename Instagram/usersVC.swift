//
//  usersVC.swift
//  Instagram
//
//  Created by Boyu Ran on 6/29/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //declare search bar
    var searchBar = UISearchBar()
    
    
    //tableView arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    
    //collectionView UI 
    var collectionView : UICollectionView!
    
    //collectionView arrays to hold information from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 15
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //implement search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        
        loadUsers()
        
        collectionViewLaunch()
    }

    func loadUsers(){
        let userQuery = PFQuery(className: "_User")
        userQuery.addDescendingOrder("createdAt")
        userQuery.limit = 20
        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil{
                
                //clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                //found related objects
                for object in objects!{
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.avaArray.append(object.valueForKey("ava") as! PFFile)
                }
                
                self.tableView.reloadData()
            } else{
                print(error!.localizedDescription)
            }
        }
    
    }
    
    //search updated
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //find by username
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil{
                
                //find by fullname
                if objects!.isEmpty{
                    
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                        if error == nil{
                        
                                //clean up
                                self.usernameArray.removeAll(keepCapacity: false)
                                self.avaArray.removeAll(keepCapacity: false)
                            
                                //found related objects
                            for object in objects!{
                                self.usernameArray.append(object.valueForKey("username") as! String)
                                self.avaArray.append(object.valueForKey("ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                }
                
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.avaArray.append(object.objectForKey("ava") as! PFFile)
                }
                
                self.tableView.reloadData()
            }
        }
        return true
        
    }
    
    //tapped on the searchBar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //hide collectionView when started search
        collectionView.hidden = true
        searchBar.showsCancelButton = true
    }
    //clicked cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        collectionView.hidden = false
        
        self.searchBar.resignFirstResponder()
        
        searchBar.showsCancelButton = false
        
        searchBar.text = ""
        
        loadUsers()
    }
    
    
    //cell number
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }
    
    //cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        
        
        //hide follow button
        cell.followBtn.hidden = true
        
        //connect cell objects with received information from server
        cell.username.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    //selected tableview cell - selected user
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        if cell.username.text! ==  PFUser.currentUser()?.username{
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else{
            guestname.append(cell.username.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    //CollectionView Code
    func collectionViewLaunch(){
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(self.view.frame.size.width / 3, self.view.frame.size.width / 3)
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        //declare collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .whiteColor()
        self.view.addSubview(collectionView)
        
        //define cell for collectionView
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        loadPosts()
        
    }
    
    //cell line spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    //cell inter spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    //cell #
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell config
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        //create picture imageView in cell to show loaded pictures
        let picImg = UIImageView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil{
                picImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        postuuid.append(uuidArray[indexPath.row])
        
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    
    func loadPosts(){
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil{
                //clean up
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    self.picArray.append(object.objectForKey("pic") as! PFFile)
                    self.uuidArray.append(object.objectForKey("uuid") as! String)
                }
                
                self.collectionView.reloadData()
                
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    
    //scrolled down ( for paging)
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    //pagination
    func loadMore(){
        if page <= picArray.count{
        
            page = page + 15
            
            
            //load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil{
                
                        //clean up
                        self.picArray.removeAll(keepCapacity: false)
                        self.uuidArray.removeAll(keepCapacity: false)
                    
                    for object in objects!{
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                    }
                    
                    self.collectionView.reloadData()
                }else{
                    print(error?.localizedDescription)
                }
            })
            
        }
    }
}

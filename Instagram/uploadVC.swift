//
//  uploadVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/22/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class uploadVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publish: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable publish btn
        publish.enabled = false
        publish.backgroundColor = .lightGrayColor()
        
        
        //hide remove button
        removeBtn.hidden = true
        
        //standard UI
        picImg.image = UIImage(named: "grey_image_holder.png")
        
        
        //hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hidekeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
        
    }
    
    //preload function
    override func viewWillAppear(animated: Bool) {
        alignment()
    }
    
    func selectImg(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //hold selected image in picImg object and dismiss PickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //enable publish button
        publish.enabled = true
        publish.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        
        //unhide remove button
        removeBtn.hidden = false
        
        //implement second tap for zooming image
        let zoomtap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomtap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(zoomtap)
    }
    
    //zoom in/out function
    func zoomImg(){
        let unzoom = CGRectMake(15, 15, self.view.frame.size.width / 4.5, self.view.frame.size.width / 4.5)
        let zoom = CGRectMake(0, self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.width)
        
        if picImg.frame == unzoom{
            //with animation
            UIView.animateWithDuration(0.3, animations: { 
                self.picImg.frame = zoom
                
                //hide objects from background
                self.view.backgroundColor = .blackColor()
                self.titleTxt.alpha = 0 //transparent
                self.publish.alpha = 0
                self.removeBtn.alpha = 0
            })
        } else{
            UIView.animateWithDuration(0.3, animations: { 
                self.picImg.frame = unzoom
                self.view.backgroundColor = .whiteColor()
                self.titleTxt.alpha = 1
                self.publish.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
    }
    
    func hidekeyboardTap(){
        self.view.endEditing(true)
    }
    //alignment
    func alignment(){
         let width = self.view.frame.size.width
         let height = self.view.frame.size.height
        
         picImg.frame = CGRectMake(15, 15, width / 4.5, width / 4.5)
         titleTxt.frame = CGRectMake(picImg.frame.size.width + 25, picImg.frame.origin.y, width / 1.488, picImg.frame.size.height)
         publish.frame = CGRectMake(0, height / 1.09, width, width / 8)
         removeBtn.frame = CGRectMake(picImg.frame.origin.x, picImg.frame.origin.y + picImg.frame.size.height, picImg.frame.size.width, 30)
        
        
    }
    
    @IBAction func publishBtn_clicked(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        //send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.currentUser()?.username
        object["ava"] = PFUser.currentUser()?.valueForKey("ava") as! PFFile
        
        let uuid = NSUUID().UUIDString
        object["uuid"] = "\(PFUser.currentUser()!.username) \(uuid)"
        
        if titleTxt.text.isEmpty {
                object["title"] = ""
        }else{
                object["title"] = titleTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        //send pic to server after converting to File and compression
        let picData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let picFile = PFFile(name: "post_picture.jpg",data: picData!)
        object["pic"] = picFile
        
        //send #hashtag to server
        let words:[String] = titleTxt.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for var word in words {
            if word.hasPrefix("#"){
                
                //cut symbol
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = uuid
                hashtagObj["by"] = PFUser.currentUser()?.username
                hashtagObj["hashtag"] = word.lowercaseString
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                    if success{
                        print("hashtag \(word) is created")
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
        }

        
        //finally save information
        object.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if error == nil {
                //send notification with name "uploaded"
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                //switch to antoher viewController at 0 index of tabbar
                self.tabBarController?.selectedIndex = 0
                
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        }
    }
    
    @IBAction func removePic_clicked(sender: AnyObject) {
        self.viewDidLoad()
    }
    
    
}

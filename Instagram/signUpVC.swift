//
//  signUpVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/9/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    //profile image
    
    @IBOutlet weak var avaImg: UIImageView!
    
    //text field
   
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    //button
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    
    //UIScrollView
    @IBOutlet weak var scrollview: UIScrollView!
    
    //reset default size
    var scrollViewHeight : CGFloat = 0
    
    
    //keyboard frame size
    var keyboard = CGRect()
    
    
    @IBAction func signUp(sender: AnyObject) {
        print("sign up clicked")
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        //if fields are empty, alert message
        if(usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || fullnameTxt.text!.isEmpty){
            
            let alert = UIAlertController(title: "Please", message: "fill all fields", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
            
        }
        
        //if different passwords
        if(passwordTxt.text != repeatPasswordTxt.text){
            let alert = UIAlertController(title: "Passwords", message: "do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        
        //send data to server
        let user = PFUser()
        user.username = usernameTxt.text?.lowercaseString
        user.password = passwordTxt.text
        user.email = emailTxt.text
        user["fullname"] = fullnameTxt.text?.lowercaseString
        
        
        //in edit profile, it's gonna be assigned
        user["bio"] = ""
        user["web"] = ""
        user["tel"] = ""
        user["gender"] = ""
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name:"ava.jpg",data:avaData!)
        user["ava"] = avaFile
        
        //save data in server
        user.signUpInBackgroundWithBlock{(success:Bool,error:NSError?)-> Void in
            if success {
                print("register")
                
                //remember logged user
                NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //call login func from appdelegate swift class
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
                
            }else{
                
                let alert = UIAlertController(title:"Error  ",message: error?.localizedDescription,preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        print("cancel clicked")
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //scrollview frame size
        scrollview.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollview.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollview.frame.size.height
        
        //check notification if keyboard is shown or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpVC.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpVC.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action:#selector(signUpVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target:self,action:#selector(signUpVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.userInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        //alignment
        avaImg.frame = CGRectMake(self.view.frame.size.width / 2 - 40, 40 , 80, 80)
        usernameTxt.frame = CGRectMake(10, avaImg.frame.origin.y + 90, self.view.frame.size.width - 20, 30)
        passwordTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        repeatPasswordTxt.frame = CGRectMake(10, passwordTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        fullnameTxt.frame = CGRectMake(10, repeatPasswordTxt.frame.origin.y + 60, self.view.frame.size.width - 20, 30)
        emailTxt.frame = CGRectMake(10,fullnameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        
        signUp.frame = CGRectMake(20, emailTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30)
        cancel.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, signUp.frame.origin.y, self.view.frame.size.width / 4, 30)
        
        
        //background
        let bg = UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image = UIImage(named: "image_1.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    //call picker to select image
    func loadImg(recognizer:UITapGestureRecognizer){
    let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker,animated:true,completion: nil)
    }
    
    //connect selected image to our ImageView
    func imagePickerController(picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[String : AnyObject]){
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //hide keyboard if tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func showKeyboard(notification: NSNotification){
        //define keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //move up UI
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollview.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    func hideKeyboard(notification:NSNotification){
        
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollview.frame.size.height = self.view.frame.height
        }
    }
}

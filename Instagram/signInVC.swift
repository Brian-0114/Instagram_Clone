//
//  signInVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/9/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class signInVC: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    //default func
    override func viewDidLoad(){
        super.viewDidLoad()
        
        label.font = UIFont(name:"Pacifico",size: 25)
        
        //alignment
        label.frame = CGRectMake(10, 80, self.view.frame.size.width - 20, 50)
        
        usernameTxt.frame = CGRectMake(10, label.frame.origin.y + 70, self.view.frame.size.width - 20, 30)
        passwordTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        //forgotBtn.frame = CGRectMake(10, passwordTxt.frame.origin.y + 30, self.view.frame.size.width - 20, 30)
        signInBtn.frame = CGRectMake(20, forgotBtn.frame.origin.y + 40, self.view.frame.size.width / 4, 30)
        signUpBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width/4 - 20, signInBtn.frame.origin.y, self.view.frame.size.width / 4, 30)
    
        //tap to hide keyboard
        let hidetap = UITapGestureRecognizer(target:self,action:#selector(signInVC.hideKeyboard(_:)))
        hidetap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
        
        //background
        let bg = UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image = UIImage(named: "image_1.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    //hide keyboard if tapped
    func hideKeyboard(recognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    //clicked sign in button
    @IBAction func signInBtn_click(sender: AnyObject) {
        print("sign in pressed")
        
        //hide keyboard
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty{
        
            let alert = UIAlertController(title:"Please",message: "fill in fields",preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        //login function
        PFUser.logInWithUsernameInBackground(usernameTxt.text!, password: passwordTxt.text!) {(user:PFUser?, error:NSError?) -> Void in
            if error == nil{
                //remember user or save in app memeory
                NSUserDefaults.standardUserDefaults().setObject(user!.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //call login function from appdelegate swift class
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
}

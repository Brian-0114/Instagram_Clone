//
//  resetPasswordVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/9/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var ResetBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    
    @IBAction func resetBtn_click(sender: AnyObject) {
    
        self.view.endEditing(true)
        
        if emailTxt.text!.isEmpty{
            
            let alert = UIAlertController(title: "email field", message: "is empty", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        //request for resetting password
        PFUser.requestPasswordResetForEmailInBackground(emailTxt.text!) { (success:Bool, error:NSError?)-> Void in
            if success{
            
                let alert = UIAlertController(title:"email for reseting password", message:"has been sent to texted email",
                                              preferredStyle: UIAlertControllerStyle.Alert)
                
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)-> Void in
                    self.dismissViewControllerAnimated(true,completion:nil)
                })
                alert.addAction(ok)
                self.presentViewController(alert,animated:true,completion:nil)
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelBtn_click(sender: AnyObject) {
        
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTxt.frame = CGRectMake(10, 120, self.view.frame.size.width - 20, 30)
        ResetBtn.frame = CGRectMake(20, emailTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30)
        CancelBtn.frame = CGRectMake(self.view.frame.width - self.view.frame.size.width / 4 - 20, ResetBtn.frame.origin.y, self.view.frame.size.width / 4, 30)
        
        //background
        let bg = UIImageView(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image = UIImage(named: "image_1.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
}

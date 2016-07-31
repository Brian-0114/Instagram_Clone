//
//  editVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/22/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit
import Parse

class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //user interface objects
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var web: UITextField!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var private_info: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var tel: UITextField!
    @IBOutlet weak var gender: UITextField!
    
    
    var genderPicker : UIPickerView!
    let genders = ["male","female"]
    
    
    //value to hold keyboard frame size
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alignment()
        
        //create picker 
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackgroundColor()
        genderPicker.showsSelectionIndicator = true
        gender.inputView = genderPicker
        
        //check notification of keyboard - shown or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(editVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(editVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.userInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        //call information function
        information()
        
    }
    
    //func to hide keyboard
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    //func when keyboard is shown
    func keyboardWillShow(notification: NSNotification){
        //define keyboar frame size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue())!
        
        //move up with animation
        UIView.animateWithDuration(0.4) { 
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2  //when the keyboard is shown, the scrollview is scrollable
        }
    }
    
    //func when keyboard is hidden
    func keyboardWillHide(notification: NSNotification){
        //define keyboar frame size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue())!
        
        //move up with animation
        UIView.animateWithDuration(0.4) {
           self.scrollView.contentSize.height = 0           //when the keyboard is hidden, the scrollview is not scrollable
        }
    }
    
    //func to call UIImagePickerController
    func loadImg(recognizer: UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker,animated : true, completion : nil)
        
    }
    
    //method to finalize our action
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //validate email
    func validateEmail(email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.rangeOfString(regex, options: .RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
        
    }
    
    //validate web
    func validateWeb(web: String) -> Bool {
        let regex = "www.+[A-Za-z0-9._%+-]+.[A-Za-z]{2}"
        let range = web.rangeOfString(regex, options: .RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    
    }
    func alert(error : String, message: String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert,animated: true, completion: nil)
        
    }
    //clicked cancel button
    @IBAction func cancelBtn_clicked(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func save_clicked(sender: AnyObject) {
        if !validateEmail(email.text!){
            alert("Incorret email", message: "please provide correct email address")
            return
        }
        if !validateWeb(web.text!){
            alert("Incorret web link", message: "please provide correct website")
            return
        }
        
        let user = PFUser.currentUser()
        user!.username = username.text?.lowercaseString
        user!.email = email.text?.lowercaseString
        user!["fullname"] = fullname.text?.lowercaseString
        user!["web"] = web.text?.lowercaseString
        user!["bio"] = bio.text
        
        if tel.text!.isEmpty{
            user!["tel"] = ""
        }else{
            user!["tel"] = tel.text
        }
        
        if gender.text!.isEmpty {
            user!["gender"] = ""
        }else{
            user!["gender"] = gender.text
        }
        
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user!["ava"] = avaFile
        
        //send filled information to server
        user?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
            if success{
                self.view.endEditing(true)
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                //send notification to homeVC to be reloaded
                NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
                
            }else{
                print(error!.localizedDescription)
            }
        })
        
    }
    
    //alignment function
    func alignment(){
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRectMake(0, 0, width, height)
        avaImg.frame = CGRectMake(width - 68 - 10, 15, 68, 68)
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        fullname.frame = CGRectMake(10, avaImg.frame.origin.y, width - avaImg.frame.size.width - 30, 30)
        username.frame = CGRectMake(10, fullname.frame.origin.y + 40, width - avaImg.frame.size.width - 30, 30)
        web.frame = CGRectMake(10, username.frame.origin.y + 40, width - 20, 30)
        
        bio.frame = CGRectMake(10, web.frame.origin.y + 40, width - 20, 60)
        bio.layer.borderWidth = 1
        bio.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
        bio.layer.cornerRadius = bio.frame.size.width / 50
        bio.clipsToBounds = true
        
        email.frame = CGRectMake(10, bio.frame.origin.y + 100, width - 20, 30)
        tel.frame = CGRectMake(10, email.frame.origin.y + 40, width - 20, 30)
        gender.frame = CGRectMake(10, tel.frame.origin.y + 40, width - 20, 30)
        private_info.frame = CGRectMake(15, email.frame.origin.y - 30, width - 20, 30)
        
    }
    //user information function
    func information(){
        
        //receive profile picture
        let ava = PFUser.currentUser()?.objectForKey("ava") as! PFFile
        ava.getDataInBackgroundWithBlock { (data:NSData?, error: NSError?) in
            self.avaImg.image = UIImage(data: data!)
            
        }
        
        //receive text information
        username.text = PFUser.currentUser()?.username
        fullname.text = PFUser.currentUser()?.objectForKey("fullname") as? String
        bio.text = PFUser.currentUser()?.objectForKey("bio") as? String
        web.text = PFUser.currentUser()?.objectForKey("web") as? String
        email.text = PFUser.currentUser()?.email
        tel.text = PFUser.currentUser()?.objectForKey("tel") as? String
        gender.text = PFUser.currentUser()?.objectForKey("gender") as? String
        
    }
    
    //pickerView Method
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = genders[row]
        self.view.endEditing(true)
    }
}

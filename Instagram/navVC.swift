//
//  navVC.swift
//  Instagram
//
//  Created by Boyu Ran on 5/23/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit

class navVC: UINavigationController {
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
    
    // title color at the top
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    // color of button in the navigation controller
        self.navigationBar.tintColor = UIColor.whiteColor()
    
    //background color 
        self.navigationBar.barTintColor = UIColor(red: 18.0/255.0, green: 86.0/255.0, blue: 136.0/255.0, alpha: 1)
    
    // disable tanslucent
        self.navigationBar.translucent = false
    }
    
    //white status bar function
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
}

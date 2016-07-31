//
//  newsCell.swift
//  Instagram
//
//  Created by Boyu Ran on 6/30/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

    //UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infolabel: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        infolabel.translatesAutoresizingMaskIntoConstraints = false
        datelbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(30)]-10-[username]-7-[info]-10-[date]",
            options: [], metrics: nil, views: ["ava":avaImg, "username":usernameBtn, "info":infolabel, "date":datelbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(30)]-10-|",
            options: [], metrics: nil, views: ["ava":avaImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[username(30)]",
            options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[info(30)]",
            options: [], metrics: nil, views: ["info":infolabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[date(30)]",
            options: [], metrics: nil, views: ["date":datelbl]))
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }

}

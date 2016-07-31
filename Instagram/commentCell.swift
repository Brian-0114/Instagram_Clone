//
//  commentCell.swift
//  Instagram
//
//  Created by Boyu Ran on 5/24/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var commentlabel: KILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var date: UILabel!
    
    
    override func awakeFromNib() {
      
        super.awakeFromNib()
        
        //alignment
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        commentlabel.translatesAutoresizingMaskIntoConstraints = false
        date.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[username]-(-2)-[comment]-5-|", options: [], metrics: nil, views: ["username":usernameBtn,"comment":commentlabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[date]", options: [], metrics: nil, views: ["date":date]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[ava(40)]", options: [], metrics: nil, views: ["ava":avaImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[ava(40)]-13-[comment]-20-|", options: [], metrics: nil, views: ["ava":avaImg,"comment":commentlabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[ava]-13-[username]", options: [], metrics: nil, views: ["ava":avaImg,"username":usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[date]-10-|", options: [], metrics: nil, views: ["date":date]))
        
        //round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
    }

    

}

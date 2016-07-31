//
//  pictureCell.swift
//  Instagram
//
//  Created by Boyu Ran on 5/15/16.
//  Copyright © 2016 Boyu Ran. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    //default func
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        let width = UIScreen.mainScreen().bounds.width
        
        picImg.frame = CGRectMake(0, 0, width / 3, width / 3)
        
    }
}

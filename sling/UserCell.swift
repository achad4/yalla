//
//  UserCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/31/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class UserCell : UICollectionViewCell{
    var user : PFObject
    
    @IBOutlet weak var userName: UILabel!
    
    @IBAction func addUser(sender: UIButton) {
        
    }
    override init() {
        user = PFUser()
        super.init()
    }

    required init(coder decoder: NSCoder) {
        user = PFUser()
        super.init(coder: decoder)
    }
    
}
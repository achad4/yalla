//
//  UserCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/31/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class UserCell : UICollectionViewCell{
    var user : PFObject = PFUser()
    @IBOutlet weak var userName: UILabel!
    
    @IBAction func addUser(sender: UIButton) {
        var vc = self.superview?.superview as FriendCollectionViewController
        vc.convo.addRecipient(self.user)
        
    }
    
}
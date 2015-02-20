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
    //var convo : Conversation!
    var messageText : String!
    
    var userImage: UIImageView!
    
    var userName: UILabel!
    
    var userCellView: UIView = UIView()
    
    required init(coder decoder: NSCoder) {
        user = PFUser()
        super.init(coder: decoder)
        self.addSubview(userCellView)
    }
    /*
    func userSelected() {
        if(!self.userButton.selected){
            self.userButton.alpha = 1
            self.userButton.selected = true
            self.userButton.highlighted = true
            self.convo.addRecipient(self.user)
        }
        else{
            self.userButton.alpha = 0.6
            self.userButton.selected = false
            self.userButton.highlighted = false
            self.convo.removeRecipient(self.user)
        }
        
    }
    */
    
}
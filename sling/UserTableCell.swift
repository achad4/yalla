//
//  UserTableCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 2/27/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class UserTableCell : UITableViewCell{
    var user : PFObject
    //var convo : Conversation!
    var messageText : String!
    
    var userImage: UIImageView!
    
    var userName: UILabel!
    
    var userCellView: UIView = UIView()
    
    required init?(coder decoder: NSCoder) {
        user = PFUser()
        super.init(coder: decoder)
        self.addSubview(userCellView)
    }
    
}
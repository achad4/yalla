//
//  UserData.swift
//  sling
//
//  Created by Evan O'Connor on 12/28/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class UserData{
    var conversations : NSMutableArray
    var user : PFUser

    init(theUser : PFUser){
        conversations = NSMutableArray()
        user = theUser
    }
}
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
    var convo : Conversation!
    var messageText : String!
    
    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    
    override init() {
        user = PFUser()
        super.init()
    }

    @IBAction func userSelected(sender: AnyObject) {
        self.userButton.alpha = 1
        self.userButton.selected = true
        self.userButton.highlighted = true
        var message:PFObject = PFObject(className: "Message")
        message["text"] = self.messageText
        var sentToRelation = message.relationForKey("sentTo")
        message["inConvo"] = self.convo.convo as PFObject
        message["sender"] = PFUser.currentUser()
        message.saveInBackgroundWithTarget(nil, selector: nil)
        self.convo.addRecipient(self.user)
        self.convo.save()
    }
    
    required init(coder decoder: NSCoder) {
        user = PFUser()
        super.init(coder: decoder)
    }
    
}
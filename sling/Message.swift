//
//  Message.swift
//  sling
// --avi was here
//  Created by Avi Chad-Friedman on 12/21/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class Message : JSQMessage {
    var text_: String!
    var senderUser : PFUser?
    var date_: NSDate!
    var imageUrl_: String?
    var _senderDisplayName: String?
    var _senderId: String?
    
    convenience init(text: String?, sender: PFUser?) {
        self.init(text: text, sender: sender, imageUrl: nil)
    }
    
    init(text: String?, sender: PFUser?, imageUrl: String?) {
        //uper.init(senderId: sender?.objectId, displayName: sender?.objectId, text: text)
        super.init()
        //super.init(senderId: sender?.objectId, displayName: sender?.objectId, text: text)
        self.text_ = text!
        self.senderUser = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    func user() -> PFUser! {
        return senderUser
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return senderUser?.objectForKey("username") as String
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func imageUrl() -> String? {
        return imageUrl_
    }
 
    func senderDisplayName() -> String! {
        return self._senderDisplayName
    }
    
    func senderId() -> String! {
        return self.senderUser?.objectId
    }
    */
}
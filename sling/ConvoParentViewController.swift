//
//  ConvoParentViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/29/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ConvoParentViewController : UIViewController{
    @IBOutlet weak var replyTextField: UITextField!
    var selectedConversationID : String!
    var convo : PFObject = PFObject(className: "Conversation")
    var chosen : Int!
    override func prepareForSegue(segue: (UIStoryboardSegue!),
        sender: AnyObject!) {
            if (segue.identifier == "to_convo_detail_segue") {
                println(self.selectedConversationID)
                let vc = segue.destinationViewController as ConvoDetailViewController
                vc.selectedConversationID = self.selectedConversationID as String!
                vc.convo = convo
            }
    }
    
    @IBAction func reply(sender: UIButton) {
        var message:PFObject = PFObject(className: "Message")
        message["text"] = replyTextField.text
        var query1 = PFUser.query();
        var query2 = PFUser.query();
        var sentToRelation = message.relationForKey("sentTo")
        var senderRelation = message.relationForKey("sender")
        senderRelation.addObject(PFUser.currentUser())
        message["inConvo"] = self.convo as PFObject
        convo.save()
        message.saveInBackgroundWithTarget(nil, selector: nil)
    }

    
}

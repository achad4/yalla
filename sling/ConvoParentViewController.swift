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
    
    @IBOutlet weak var sendProgress: UIProgressView!
    var selectedConversationID : String!
    var convo : PFObject = PFObject(className: "Conversation")
    var chosen : Int!
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            // sendProgress.setProgress(fractionalProgress, animated: animated)
        }
    }
    func count(start : Int, end : Int) {
        self.counter = 0
        for i in start..<end {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                sleep(1)
                dispatch_async(dispatch_get_main_queue(), {
                    self.counter++
                    return
                })
            })
        }
        // self.sendProgress.setProgress(0, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sendProgress.setProgress(0, animated: true)
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!),
        sender: AnyObject!) {
            if (segue.identifier == "to_convo_detail_segue") {
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
        //self.sendProgress.setProgress(100, animated: true)
        self.count(0, end: 50)
        convo.save()
        message.save()
        self.count(50, end: 100)
        let table = self.childViewControllers[0] as ConvoDetailViewController
        table.loadData(1)    }

    
}

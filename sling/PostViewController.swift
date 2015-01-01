//
//  PostViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/17/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//
import Foundation
import UIKit

class PostViewController: UIViewController, UITextFieldDelegate {
    
    var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var users : NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var postText: UITextField!
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "toUsersSegue"){
            let userView = segue.destinationViewController as FriendCollectionViewController
            userView.convo = self.convo
        }
    }
    
    @IBAction func submitPost(sender: AnyObject) {
        
        var feed:QuestionFeedTableView = QuestionFeedTableView()
        var questionText:String        = postText.text
        var message:PFObject           = PFObject(className: "Message")
        message["text"] = questionText;
        var query1 = PFUser.query();
        var query2 = PFUser.query();
        var sentToRelation = message.relationForKey("sentTo")
        var senderRelation = message.relationForKey("sender")
        senderRelation.addObject(PFUser.currentUser())
        message["inConvo"] = convo.convo as PFObject
        self.convo.save()
        message.saveInBackgroundWithTarget(nil, selector: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postText.font = UIFont(name: "Avenir", size: 16)
        // self.view.backgroundColor = UIColor(red: 0.2, green: 0.9, blue: 0.55, alpha: 1.0)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

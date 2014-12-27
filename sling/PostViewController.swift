//
//  PostViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/17/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//
import Foundation
import UIKit

class PostViewController: UIViewController, UITextFieldDelegate{
    
    
    
    @IBOutlet weak var postText: UITextField!


    @IBAction func submitPost(sender: AnyObject) {
        var feed:QuestionFeedTableView = QuestionFeedTableView()
        var questionText:String        = postText.text
        var question:PFObject          = PFObject(className: "Question")
        /*
        question["text"]    = questionText
        question["askedBy"] = PFUser.currentUser()
        question["score"]   = 0
        question["recievedBy"] = PFUser.currentUser()["username"]
        
        question.saveInBackgroundWithTarget(nil, selector: nil)
         */
        //feed.addQuestion(questionText)
        //feed.tableView.reloadData()
        
        var message:PFObject = PFObject(className: "Message")
        message["text"] = questionText;
       
        var query1 = PFUser.query();
        //send to JoeTest2
        var user1 = query1.getObjectWithId("Bi1WevBzYa") as PFUser
        //send to JoeTest1
        var query2 = PFUser.query();
        var user2 = query2.getObjectWithId("KK2oWLTPE4") as PFUser
        //user1["recieved"] = message;
        //user2["recieved"] = message;
        var sentToRelation = message.relationForKey("sentTo")
        sentToRelation.addObject(user1)
        sentToRelation.addObject(user2)
        var senderRelation = message.relationForKey("sender")
        senderRelation.addObject(PFUser.currentUser())
        var convo : Conversation = Conversation(initialMessage: message, sender: PFUser.currentUser())
        convo.addRecipient(user1)
        convo.addRecipient(user2)
        convo.save()
        message.saveInBackgroundWithTarget(nil, selector: nil)
        user1.saveInBackgroundWithTarget(nil, selector: nil)
        user2.saveInBackgroundWithTarget(nil, selector: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    query.whereKey("username", equalTo:"JoeTest2");
    
    query.findObjectsInBackgroundWithBlock{(recievers : [AnyObject]!, error : NSError!)->Void in
    if(error == nil){
    for r in recievers as [PFObject]{
    var relation = message.relationForKey("recievers");
    var user = r as PFUser
    //relation.addObject(r);
    message["recievers"] = user;
    println(user.objectId)
    message.saveEventually()
    }
    }
    else{
    println(error.localizedDescription)
    }
    }
    */
}

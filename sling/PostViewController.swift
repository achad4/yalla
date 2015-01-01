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
        var message:PFObject = PFObject(className: "Message")
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

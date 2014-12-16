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
        var feed : QuestionFeedTableView = QuestionFeedTableView()
        var questionText:String = postText.text
        var question:PFObject = PFObject(className: "Question")
        question["text"] = questionText
        question["askedBy"] = PFUser.currentUser()
        question["score"] = 0
        question.saveInBackgroundWithTarget(nil, selector: nil)
        //feed.addQuestion(questionText)
        //feed.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

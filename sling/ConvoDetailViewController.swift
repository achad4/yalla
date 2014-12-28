//
//  QuestionFeedTableView.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/16/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class ConvoDetailViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //var managedContext : NSManagedObjectContext = NSManagedObjectContext()
    var timeLineData : NSMutableArray = NSMutableArray()
    var selectedConversationID : String!
    var chosen : Int!
    
    @IBAction func logout(sender: AnyObject) {
        if(PFUser.currentUser() != nil){
            PFUser.logOut()
            viewDidAppear(true)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
      
        NSLog(String(chosen))
        //self.tableView.registerClass(MessageCell.self as AnyClass, forCellReuseIdentifier: "Cell");
    }
    
    /*
    func myVCDidFinish(controller: QuestionFeedTableView, text: String) {
        selectedConversationID = text
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let controller = segue.destinationViewController as SecondViewController
        controller.string = textField.text
    }
*/
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    func loadData(order: Int){
        
        
        var findTimeLineData:PFQuery = PFQuery(className: "Message")
        
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        
        //else if(order == 1){
        //    findTimeLineData.orderByDescending("score")
        //}
        
        // Filtering questions to only see those posted by current user
        var currentUser = PFUser.currentUser();
        
        // Option to limit number of results from query (if needed)
        //findTimeLineData.limit = 3
        
        findTimeLineData.whereKey("objectID", equalTo: "MgJ3DUEvVa")
        
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.timeLineData.addObject(pdf)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    func sortByScore(){
        
    }
    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeLineData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MessageCell
        let message:PFObject = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
        cell.messageText.text = " " as NSString
        
        if(message.objectForKey("text") != nil){
            cell.messageText.text = message.objectForKey("text") as NSString
        }
        let date = message.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        println(stringDate)
        cell.timeSent.text = stringDate as NSString
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    

 
    
}

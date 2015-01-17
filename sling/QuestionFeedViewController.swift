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

//TODO: Should probably rename this class to QuestionFeedTableViewController
protocol QuestionFeedTableViewControllerDelegate{
    func myVCDidFinish(controller:QuestionFeedTableView,text:String)
}

class QuestionFeedTableView : UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var timeLineData : NSMutableArray = NSMutableArray()
    var delegate:QuestionFeedTableViewControllerDelegate? = nil
    var convoID:String = "aaa"
    var sideMenuOpen : Bool = false
    

    @IBAction func showMenu(sender: AnyObject) {
        revealViewController().revealToggle(sender)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "to_message_view"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as TableCell
            let parent = segue.destinationViewController as MessagesViewController
            //parent.selectedConversationID = cell.convo.objectId as String!
            parent.convo = cell.convo
            parent.isAnon = cell.convo.convo.objectForKey("isAnon") as? Bool
            parent.newMessgae = false
        }
        if(segue.identifier == "new_message_segue"){
            //var convo : Conversation = Conversation(sender: PFUser.currentUser())
            //convo.save()
            let parent = segue.destinationViewController as MessagesViewController
            //parent.convo = convo
            //parent.isAnon = convo.isAnon
            parent.isAnon = true
            parent.newMessgae = true
            parent.addedParticipants = false
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) -> Void{
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        recognizer.direction = .Left
        self.view .addGestureRecognizer(recognizer)
        let recognizer2: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        recognizer2.direction = .Right
        self.view .addGestureRecognizer(recognizer2)
        if(PFUser.currentUser() != nil){
            self.loadData(0)
        }
        
    }
    @IBAction func swipeRight(recognizer2 : UISwipeGestureRecognizer) {
        println("swiped right")
        revealViewController().revealToggle(self)
        self.sideMenuOpen = true
    }
    
    
    @IBAction func swipeLeft(recognizer : UISwipeGestureRecognizer) {
        println("swiped left")
        if(self.sideMenuOpen){
             revealViewController().revealToggle(self)
            self.sideMenuOpen = false
        }
        else{
            var storyboard = UIStoryboard(name: "Feed", bundle: nil)
            //var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
            var controller = storyboard.instantiateViewControllerWithIdentifier("FeedView") as UIViewController
            self.navigationController?.pushViewController(controller, animated: true)
            //self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    func loadData(order: Int){
        self.timeLineData.removeAllObjects()
        //var currentUserData:UserData = UserData(theUser: PFUser.currentUser())
       
        //var findTimeLineData:PFQuery = PFQuery(className: "Message")
        var findTimeLineData:PFQuery = PFQuery(className: "Conversation")
        
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        var currentUser = PFUser.currentUser();
        findTimeLineData.whereKey("participant", equalTo: currentUser)
        
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.timeLineData.addObject(pdf)
                }
                //let array:NSArray = self.timeLineData.reverseObjectEnumerator().allObjects
                //self.timeLineData = array as NSMutableArray
                
                self.tableView.reloadData()
            }
        }
     
    }

    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeLineData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableCell
        //let question:PFObject = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
        let convo:PFObject = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
        let convoObject : Conversation = Conversation(convo: convo)
        //cell.questionText.text = " " as NSString
        /*
        if(message.objectForKey("text") != nil){
            cell.questionText.text = message.objectForKey("text") as NSString
        }
        */
        let date = convo.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        //if(convo[])
        let user : PFUser = convo["owner"].fetchIfNeeded() as PFUser
        let userString : String = user.username
        cell.userNames.text = userString
        cell.timePosted.text = stringDate as NSString
        cell.convo = convoObject
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

}

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
protocol InboxTableViewControllerDelegate{
    func myVCDidFinish(controller:InboxTableViewController,text:String)
}

class InboxTableViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource{
    
    var timeLineData : NSMutableArray = NSMutableArray()
    var delegate:InboxTableViewControllerDelegate? = nil
    var convoID:String = "aaa"
    var sideMenuOpen : Bool = false
    var screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Yalla"
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        recognizer.direction = .Left
        self.view .addGestureRecognizer(recognizer)
        let recognizer2: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        recognizer2.direction = .Right
        self.view .addGestureRecognizer(recognizer2)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //self.navigationController?.navigationBar.layer.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7).CGColor
        //self.navigationController?.navigationBar.layer.shadowOffset  = CGSizeMake(0, 2)
        //self.navigationController?.navigationBar.layer.shadowOpacity = 0.9
        //self.navigationController?.navigationBar.layer.shadowRadius  = 4.0
        self.navigationController?.navigationBar.topItem?.title = "inbox"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor(red: 120/255, green: 173/255, blue: 200/255, alpha: 1.0)]
    }
    
    @IBAction func showMenu(sender: AnyObject) {
        revealViewController().revealToggle(sender)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if(segue.identifier == "to_message_view"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as TableCell
            let parent = segue.destinationViewController as MessagesViewController
            var convoQuery:PFQuery = PFQuery(className: "Participant")
            convoQuery.whereKey("participant", equalTo: PFUser.currentUser())
            convoQuery.whereKey("convo", equalTo: cell.convo.convo)
            var participant = convoQuery.getFirstObject()
            
            parent.convo = cell.convo
            var active = participant["active"] as Bool
            parent.isAnon = !active
            parent.newMessgae = false
        }
        
        if(segue.identifier == "new_message_segue"){
            let parent = segue.destinationViewController as MessagesViewController
            parent.isAnon = true
            parent.newMessgae = true
            parent.addedParticipants = false
        }
    }
    
    
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            /*
        else{
            var storyboard = UIStoryboard(name: "Feed", bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier("FeedView") as UIViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        */
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
         return self.timeLineData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func loadData(order: Int){
        
        self.timeLineData.removeAllObjects()
       
        var convoQuery:PFQuery = PFQuery(className: "Participant")
        convoQuery.orderByDescending("updatedAt")
        convoQuery.whereKey("participant", equalTo: PFUser.currentUser())
        convoQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    if(pdf["convo"].fetchIfNeeded() != nil){
                        self.timeLineData.addObject(pdf["convo"].fetchIfNeeded())
                    }
                }
                self.tableView.reloadData()
            }
        }
        /*
        var findTimeLineData:PFQuery = PFQuery(className: "Conversation")
        
        findTimeLineData.orderByDescending("updatedAt")
        var currentUser = PFUser.currentUser();
        findTimeLineData.whereKey("participant", equalTo: currentUser)
        
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
        */
    }    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableCell
        let convo:PFObject = self.timeLineData.objectAtIndex(indexPath.section) as PFObject
        let convoObject : Conversation = Conversation(convo: convo)
        let date = convo.updatedAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle) as NSString
        
        var userString : String = ""
        
        self.tableView.rowHeight = 125
        
        cell.tableCell.frame = CGRectMake(0, 0, screenWidth*0.95, 115)
        cell.tableCell.center = CGPointMake(screenWidth * 0.5, 67.5)

        //trash all the subviews to prevent overlays
        for next in cell.tableCell.subviews as [UIView]{
            next.removeFromSuperview()
        }

        var previewLabel = UILabel(frame: CGRectMake(0, 0, screenWidth*0.85, 50))
        previewLabel.center = CGPointMake(screenWidth * 0.5 - 10, 85)
        previewLabel.textAlignment = .Left
        previewLabel.numberOfLines = 2
        previewLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        //previewLabel.layer.borderColor = UIColor.blackColor().CGColor
        //previewLabel.layer.borderWidth = 3
        cell.tableCell.addSubview(previewLabel)
        
        var timeLabel = UILabel(frame: CGRectMake(0, 0, 100, 25))
        timeLabel.center = CGPointMake(screenWidth - 90, 35)
        timeLabel.textAlignment = .Right
        timeLabel.font = UIFont(name: "AvenirNext-Regular", size: 18)
        timeLabel.text = stringDate
        cell.tableCell.addSubview(timeLabel)
        
        
        var preview:PFQuery = PFQuery(className: "Message")
        preview.whereKey("inConvo", equalTo: convo)
        preview.orderByDescending("createdAt")
        preview.getFirstObjectInBackgroundWithBlock {
            (object:PFObject!, error:NSError!) -> Void in
            if(object != nil){
                if (object["text"] != nil) {
                    let previewText = object.objectForKey("text") as String
                    previewLabel.text = previewText
                }
            }
        }
        
        
        var relation : PFRelation = convo.relationForKey("participant")
        var query : PFQuery = relation.query()
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) -> Void in
            if !(error != nil){
                var users : NSMutableArray = NSMutableArray()
                for object in objects{
                    users.addObject(object)
                }
                cell.displayUserPics(users)
            }
        }
        
        cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        
        // Convo cell appearance
        cell.tableCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.tableCell.layer.cornerRadius  = 9.0
        
        cell.tableCell.layer.shadowColor   = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7).CGColor
        cell.tableCell.layer.shadowOffset  = CGSizeMake(0, 2)
        cell.tableCell.layer.shadowOpacity = 0.5
        cell.tableCell.layer.shadowRadius  = 4.0
        
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        
        cell.convo = convoObject
        
        return cell
    }
}

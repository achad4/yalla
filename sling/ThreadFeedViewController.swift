//
//  ThreadFeedViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/5/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadFeedViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var threads : NSMutableArray = NSMutableArray()
    override func viewDidLoad(){
        super.viewDidLoad()
        //self.tableView.registerClass(TableCell.self, forCellReuseIdentifier: "Cell");
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    func loadData(order: Int){
        self.threads.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Thread")
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.threads.addObject(pdf)
                }
                //let array:NSArray = self.timeLineData.reverseObjectEnumerator().allObjects
                //self.timeLineData = array as NSMutableArray
                
                self.tableView.reloadData()
            }
        }
        
        
        
        
    }
    func sortByScore(){
        
    }
    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.threads.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as ThreadCell
        let thread:PFObject = self.threads.objectAtIndex(indexPath.row) as PFObject
        let date = thread.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        cell.topic.text = thread.objectForKey("topic") as? String
        cell.date.text = stringDate as NSString
        cell.thread = thread
        var query:PFQuery = PFQuery(className: "Thread")
        var threadsFollowing : NSMutableArray = NSMutableArray()
        query.whereKey("follower", equalTo: PFUser.currentUser())
        println(PFUser.currentUser().objectId)
        var count : Int = 0;
        query.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    count++
                    let pdf = object as PFObject
                    threadsFollowing.addObject(pdf)
                }
            }
            println(count)
            var followRelation : PFRelation = thread.relationForKey("follower")
            if(count == 0){
                println("User is not a follower")
                cell.follow.setTitle("Follow", forState: UIControlState.Normal)
                //followRelation.addObject(PFUser.currentUser())
                
            }
            else{
                println("User is a follower")
                cell.follow.setTitle("Unfollow", forState: UIControlState.Normal)
                //followRelation.removeObject(PFUser.currentUser())
                
            }
        }

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

}
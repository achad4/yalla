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
    //var managedContext : NSManagedObjectContext = NSManagedObjectContext()
    var timeLineData : NSMutableArray = NSMutableArray()
    var delegate:QuestionFeedTableViewControllerDelegate? = nil
    var convoID:String = "aaa"
    
    @IBAction func logout(sender: AnyObject) {
        if(PFUser.currentUser() != nil){
            PFUser.logOut()
            viewDidAppear(true)
        }
    }
    /*
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "conversationSegue"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as TableCell
            let parent = segue.destinationViewController as ConvoParentViewController
            parent.selectedConversationID = cell.convo.objectId as String!
            parent.convo = cell.convo
        }
        
    }
*/
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "to_message_view"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as TableCell
            let parent = segue.destinationViewController as MessagesViewController
            //parent.selectedConversationID = cell.convo.objectId as String!
            parent.convo = cell.convo
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        //self.loadData()
        if ((PFUser.currentUser()) == nil) {
            
            //Create an UIAlertController if there isn't an user
            var loginAlert:UIAlertController = UIAlertController(title: "Sign Up/ Log In", message: "Please sign up or log in", preferredStyle: UIAlertControllerStyle.Alert)
            
            //Add a textView in the Log In Alert for the username
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Username"
            })
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Email"
            })
            
            //Add a textView in the Log In Alert for the password
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Password"
                textfield.secureTextEntry = true
            })
            
            //Place the user-input into an array and set the username and password accordingly for Log In
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let emailTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(2) as UITextField
                
                PFUser.logInWithUsernameInBackground(usernameTextfield.text, password: passwordTextfield.text){
                    (user:PFUser!, error:NSError!)->Void in
                    if ((user) != nil){
                        println("Login successfull")
                        self.viewDidLoad()
                    }else{
                        println("Login failed")
                        self.viewDidAppear(true)
                    }
                    
                }
                
            }))
            
            //Place the user-input into an array and set the username and password accordingly for Sign Up
            loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let emailTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(2) as UITextField
                
                var slinger:PFUser = PFUser()
                slinger.username = usernameTextfield.text
                slinger.email = emailTextfield.text
                slinger.password = passwordTextfield.text
                
                slinger.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!)->Void in
                    if !(error != nil){
                        println("Sign Up successfull")
                        self.tableView.reloadData()
                    }else{
                        let errorString = error.userInfo!["error"] as NSString
                        println(errorString)
                    }
                    
                    
                }
            }))
            self.presentViewController(loginAlert, animated: true, completion: nil)
        
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) -> Void{
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        self.timeLineData.removeAllObjects()
        //var currentUserData:UserData = UserData(theUser: PFUser.currentUser())
       
        //var findTimeLineData:PFQuery = PFQuery(className: "Message")
        var findTimeLineData:PFQuery = PFQuery(className: "Conversation")
        
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
    
        //else if(order == 1){
        //    findTimeLineData.orderByDescending("score")
        //}
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
    func sortByScore(){
        
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
        //cell.questionText.text = " " as NSString
        /*
        if(message.objectForKey("text") != nil){
            cell.questionText.text = message.objectForKey("text") as NSString
        }
        */
        let date = convo.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        cell.timePosted.text = stringDate as NSString
        cell.convo = convo
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let controller = segue.destinationViewController as ConvoDetailViewController
        controller.selectedConversationID = convoID
    }*/

}

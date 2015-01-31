//
//  ThreadDetailViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadDetailViewController : JSQMessagesViewController {
    
    //var messages = [Message]()
    var messageArray : NSMutableArray = NSMutableArray()
    var replyObjectArray : NSMutableArray = NSMutableArray()
    // var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var batchMessages = true
    var thread : PFObject = PFObject(className: "Thread")
    var timeLineData : NSMutableArray = NSMutableArray()
    var newThread : Bool?
    
    func loadData(order: Int){
        println("loading messages")
        timeLineData.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Reply")
        if(order == 0){
            findTimeLineData.orderByAscending("createdAt")
        }
        // Filtering questions to only see those posted by current user
        var currentUser = PFUser.currentUser()
        
        findTimeLineData.whereKey("inThread", equalTo: self.thread)
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                var i = 0
                for object in objects{
                    let pdf = object as PFObject
                    let text = pdf.objectForKey("text") as String
                    let sender = pdf["sender"].fetchIfNeeded() as PFUser
                    let score = pdf["score"] as Int
                    //self.messages[i] = Message(text: text, sender: sender)
                    let reply = Reply(text: text, sender: sender)
                    reply.score = score
                    self.messageArray.addObject(reply)
                    self.replyObjectArray.addObject(pdf)
                    i++
                    //self.timeLineData.addObject(pdf)
                }
            }
            self.collectionView?.reloadData()
        }
        
        
    }
    func sortByScore(){
        println("sortByScore called")
    }
    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    
    func sendMessage(var text: String!, var sender: String!) {
        //This is a new thread-- create a new thread with a new topic
        if(self.newThread == true){
            var reply:PFObject = PFObject(className: "Reply")
            reply["text"] = text
            reply["sender"] = PFUser.currentUser()
            reply["score"] = 0
            reply.ACL.setPublicWriteAccess(true)
            var topic : String = ""
            var thread:Thread = Thread(sender: PFUser.currentUser(), topic: topic)
            self.thread = thread.thread
            reply["inThread"] = self.thread as PFObject
            var words : NSArray = text.componentsSeparatedByString(" ")
            for word in words{
                 println(word)
                if(word.hasPrefix("@")){
                    topic = word as String
                    self.title = word as? String
                    var range = (text as NSString).rangeOfString(word as NSString)
                    //var attributedString = NSMutableAttributedString(string:text)
                    //attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: range)
                }
            }
            if(topic == "" || topic == "@"){
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Post Failed"
                alertView.message = "Specify a topic with @<topic>"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
            else{
                self.thread["topic"] = topic
                //self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                self.newThread = false
                reply.saveInBackgroundWithTarget(nil, selector: nil)
                self.thread.save()
                self.replyObjectArray.addObject(reply)
                self.appendMessage(text, sender: PFUser.currentUser())
                self.loadData(0)
            }
        }
        //This is an existing thread-- create a new reply
        else{
            var reply:PFObject = PFObject(className: "Reply")
            reply["text"] = text
            reply["inThread"] = self.thread as PFObject
            reply["sender"] = PFUser.currentUser()
            reply["score"] = 0
            reply.ACL.setPublicWriteAccess(true)
            self.thread.save()
            reply.saveInBackgroundWithTarget(nil, selector: nil)
            self.replyObjectArray.addObject(reply)
            self.appendMessage(text, sender: PFUser.currentUser())
            self.loadData(0)
        }
    }
    
    func appendMessage(text: String!, sender: PFUser!) {
        println("tempSendMessage called")
        let message = Reply(text: text, sender: sender)
        messageArray.addObject(message)
    }
    
    override func viewDidLoad() {
        //println("viewDidLoad called")
        super.viewDidLoad()
        self.title = self.thread.objectForKey("topic") as? String
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Futura-MediumItalic", size: 18)!]
        if(PFUser.currentUser() != nil && (self.newThread != true)) {
            self.loadData(0)
        }
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        sender = (sender != nil) ? sender : "Anonymous"
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        //println("viewDidDisappear called")
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        //println("viewWillDisappear called")
        super.viewWillDisappear(animated)
        
    }
    
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        println("rMessagePressed called")
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        println("didPressSendButton called")
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        //println("collectionView 1")
        //let message = Message(text: text, sender: sender)
        // self.append(message)
        //return messages[indexPath.item]
        return messageArray.objectAtIndex(indexPath.item) as Reply
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        //println("collectionView 2")
        //let message = messages[indexPath.item]
        let message = messageArray.objectAtIndex(indexPath.item) as Reply
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        /*
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
        */
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //println("collectionView 3")
        return messageArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //println("collectionView 4")
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        //let message = messages[indexPath.item]
        let reply = messageArray.objectAtIndex(indexPath.item) as Reply
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        cell.textView.textColor = UIColor.blackColor()
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    override func collectionView(collectionView: UICollectionView, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath) -> UIImageView? {
        var image = UIImage(named: "like.jpg")
        let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
        var avatarView = ThreadAvatarImageView(image: userAvatar)
        avatarView.reply = self.replyObjectArray.objectAtIndex(indexPath.item) as PFObject
        return avatarView
    }
    /*
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        //println("collectionView 5")
        // let message = messages[indexPath.item];
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            //let previousMessage = messages[indexPath.item - 1];
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    */
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var description : String = "Score: "
        
        let reply = messageArray.objectAtIndex(indexPath.item) as Reply
        /*
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        */
        description += reply.stringScore()
        return NSAttributedString(string: description)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

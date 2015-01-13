//
//  ThreadBubble.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadAvatarImageView : UIImageView {
    var reply :PFObject = PFObject(className: "Reply")
    
    override init() {
        super.init()
        self.userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
    
    func tapped(nizer: UITapGestureRecognizer){
        println("avatar tapped")
        println(reply.objectId)
        var score : Int = reply["score"] as Int
        score = score + 1
        reply["score"] = score
        reply.saveInBackgroundWithTarget(nil, selector: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(image: UIImage!) {
        super.init(image: image)
        self.userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
}
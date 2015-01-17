//
//  TableCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/23/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit
class TableCell: UITableViewCell{
    //@IBOutlet weak var timePosted: UILabel!
    
    //@IBOutlet weak var score: UILabel!
    
    //@IBOutlet weak var questionText: UILabel!
    //var convo : PFObject = PFObject(className: "Conversation")
    var convo : Conversation = Conversation(sender : PFUser.currentUser())
    
    @IBOutlet weak var userNames: UILabel!
    
    @IBOutlet weak var timePosted: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    */
    
    
    
}
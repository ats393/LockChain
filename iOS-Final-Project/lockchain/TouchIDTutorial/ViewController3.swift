//
//  ViewController.swift
//  devdactic-rest
//
//  Created by Simon Reimler on 16/03/15.
//  Copyright (c) 2015 Devdactic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView:UITableView?
    var items = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        let frame:CGRect = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height-100)
        self.tableView = UITableView(frame: frame)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.view.addSubview(self.tableView!)

        let btn = UIButton(frame: CGRect(x: 0, y: 25, width: self.view.frame.width, height: 50))
        btn.backgroundColor = UIColor.cyanColor()
        btn.setTitle("Add new Dummy", forState: UIControlState.Normal)
        btn.addTarget(self, action: "addDummyData", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
    }

    func addDummyData() {
        RestApiManager.sharedInstance.getRandomUser { (json: JSON) in
            let results = json["results"]
            for (index: String, subJson: JSON) in results {
                let user: AnyObject = subJson["user"].object
                self.items.addObject(user)
                dispatch_async(dispatch_get_main_queue(),{
                    tableView?.reloadData()
                })
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }

        let user:JSON =  JSON(self.items[indexPath.row])

        let picURL = user["picture"]["medium"].string
        let url = NSURL(string: picURL!)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check

        cell!.textLabel?.text = user["username"].string
        cell?.imageView?.image = UIImage(data: data!)

        return cell!
    }

}


//
//  ViewController.swift
//  TouchIDTutorial
//
//  Created by Jason Rosenstein on 3/23/16.
//  Copyright © 2016 Frederik Jacques. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

//    @IBOutlet weak var uniqueID: UILabel!

//    @IBOutlet weak var priv2: UILabel!
//    @IBOutlet weak var pub2_hash: UILabel!
//    @IBOutlet weak var priv1: UILabel!
//    @IBOutlet weak var pub1_hash: UILabel!
    
//    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var message_send: UIButton!
    
    @IBOutlet weak var AccountInputField: UITextField!
    
    @IBOutlet weak var UserNameInputField: UITextField!
    
    @IBOutlet weak var PasswordInputField: UITextField!
    
//    @IBOutlet weak var show_message: UILabel!
    @IBOutlet weak var getMessage: UIButton!
    @IBOutlet weak var new_keys: UIButton!
    
    var hello:String!
    let keychain = Keychain()
    var pub1:String!
    var priv1raw:String!
    var pub2:String!
    var priv2raw:String!
    var newUser:Bool = false
    var req = ["pub1hash", "pub2", "priv1", "priv2"] //requirements
    //let url_to_request:String = "http://trancendus.com:8081/api/pk"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keychain["deviceId"] = NSUUID().UUIDString // Set string
        let deviceId = keychain["deviceId"] // Get string
//        uniqueID.text = deviceId;
        
        
        ////////
        key_gen("http://trancendus.com:8081/api/pk")

        //keychain keys print
        if(keychain[req[0]] != nil){
            for var i = 0; i < req.count; i++ {
                print(req[i] + ": " + keychain[req[i]]!)
            }
        }
        
        //download_request()
        
        //upload_request()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        super.touchesBegan(touches, withEvent: event);
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func send_data(sender: UIButton) {
        if(self.AccountInputField.text == "" || self.PasswordInputField.text == "" || self.UserNameInputField.text == ""){
            print("There is no message")
        }else{
            encrypt("http://trancendus.com:8081/api/encrypt_send")
            print("hello")
            AccountInputField.text = "";
            UserNameInputField.text = "";
            PasswordInputField.text = "";
            
            var myAlert = UIAlertController(title: "Alert", message: "Password Stored", preferredStyle: UIAlertControllerStyle.Alert);
            myAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(myAlert, animated:true, completion: nil);
            
            
        }
        
    }
    

//    @IBAction func get_data(sender: AnyObject) {
//        decrypt("http://trancendus.com:8081/api/reassemble")
//    }

    @IBAction func get_newKey(sender: AnyObject) {
        self.newUser = true
        key_gen("http://trancendus.com:8081/api/pk")
        //self.newUser = false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //store keys into keychain
    func store_keys(pub1:String, pub2:String, priv1:String, priv2:String){
        
        keychain["pub1hash"] = pub1
        keychain["pub2"] = pub2
        keychain["priv1"] = priv1
        keychain["priv2"] = priv2
    }
    
    //generates keys
    func key_gen(url_requested: String)
    {
        let url:NSURL = NSURL(string: url_requested)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "data=Hello"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(dataString)
            
            do {
                let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[])
                self.pub1 = jsonArray["alicePay"] as! String
                self.priv1raw = jsonArray["alicePriv"] as! String
                self.pub2 = jsonArray["bobPub"] as! String
                self.priv2raw = jsonArray["bobPriv"] as! String
                
//                print("Pub1: \(self.pub1)")
//                print("Priv1: \(self.priv1raw)")
//                print("Pub2: \(self.pub2)")
//                print("Priv2: \(self.priv2raw)")
                
                //use reqs to fill access_keys from keychain if nothing then it's a new User
//                for var i = 0; i < self.req.count; i++ {
//                    if(self.keychain[self.req[i]] == nil){
//                        self.newUser = true
//                    }
//                }
                
                //if newUser give them their new keys
                if(self.newUser){
                    print("hit")
                    self.store_keys(self.pub1, pub2: self.pub2, priv1: self.priv1raw, priv2: self.priv2raw)
                }
                
                ////////
                dispatch_async(dispatch_get_main_queue()) {
//                    self.pub1_hash.text = self.pub1
//                    self.priv1.text = self.priv1raw
//                    self.pub2_hash.text = self.pub2
//                    self.priv2.text = self.priv2raw
                }
            }
            catch {
                print("Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    //encrypt and send
    func encrypt(url_requested: String){
        let private1 = keychain["priv1"]!
        let public2 = keychain["pub2"]!
//        let private1 = self.priv1raw!
//        let public2 = self.pub2!
       
        let json = [
            "message" : "\(self.AccountInputField.text! + ":" + self.UserNameInputField.text! + ":" + self.PasswordInputField.text!)",
            "publicKey2" : "\(public2)",
            "privateKey1" : "\(private1)"
        ]
                
        do{
            let url = NSURL(string: url_requested)!
            let session = NSURLSession.sharedSession()
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)

            let task = session.dataTaskWithRequest(request){ data,response,error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                do {
                    let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(dataString)
                }catch{
                    //print(error)
                }
            }
        task.resume()
        }catch{
            print(error)
        }
        
    }
    
//    func decrypt(url_requested: String){
//        let private2 = keychain["priv2"]!
//        let public2 = keychain["pub2"]!
////        let private2 = self.priv2raw!
////        let public2 = self.pub2!
//        
//        let json = [
//            "message" : "\(public2)",
//            "privateKey" : "\(private2)"
//        ]
//        
//        do{
//            let url:NSURL = NSURL(string: url_requested)!
//            let session = NSURLSession.sharedSession()
//            
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "POST"
//            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
//            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
//            
//            let task = session.dataTaskWithRequest(request){ data,response,error in
//                if error != nil{
//                    print(error!.localizedDescription)
//                    return
//                }
//                do {
//                    //let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[])
//                    let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                    dispatch_async(dispatch_get_main_queue()) {
////                         self.show_message.text = dataString as! String
//                    }
//                     print(dataString)
//               }catch{
//                    print(error)
//               }
//                
//            }
//            task.resume()
//        }catch{
//            print(error)
//        }
//        
//    }
    
    
    

    func download_request(url_requested: String)
    {
        let url:NSURL = NSURL(string: url_requested)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "data=Hello"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = session.downloadTaskWithRequest(request) {
            (
            let location, let response, let error) in
            
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let urlContents = try! NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
            
            guard let _:NSString = urlContents else {
                print("error")
                return
            }
            
            print(urlContents)
            
        }
        
        task.resume()
        
    }
    
    
    func upload_request(url_requested: String)
    {
        let url:NSURL = NSURL(string: url_requested)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        let data = "data=Hi".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
            }
        )
        
        task.resume()
        
    }
    
}
//
//  GetDataViewController.swift
//  lockchain
//
//  Created by Daniel Bell on 5/2/16.
//  Copyright © 2016 Frederik Jacques. All rights reserved.
//

import UIKit

class GetDataViewController: UIViewController {

    @IBOutlet weak var show_message: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let keychain = Keychain()
    var pub1:String!
    var priv1raw:String!
    var pub2:String!
    var priv2raw:String!
    var newUser:Bool = false
    var req = ["pub1hash", "pub2", "priv1", "priv2"] //requirements
    

    @IBAction func getDataTap(sender: AnyObject) {
        decrypt("http://trancendus.com:8081/api/reassemble")
    }
    @IBAction func getQRData(sender: AnyObject) {
        decryptQR("http://trancendus.com:8081/apireassemble")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func decrypt(url_requested: String){
        let private2 = keychain["priv2"]!
        let public2 = keychain["pub2"]!
        //        let private2 = self.priv2raw!
        //        let public2 = self.pub2!
        
        let json = [
            "message" : "\(public2)",
            "privateKey" : "\(private2)"
        ]
        print(keychain["QR"])
        do{
            let url:NSURL = NSURL(string: url_requested)!
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
                    //let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[])
                    var dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    dataString = dataString!.stringByReplacingOccurrencesOfString("]", withString: "")
                    dataString = dataString!.stringByReplacingOccurrencesOfString("[", withString: "")
                    dataString = dataString!.stringByReplacingOccurrencesOfString(",", withString: "")
                    //make objects split "" into arrays
                    //then set objects with array indexes
                    dispatch_async(dispatch_get_main_queue()) {
                        self.show_message.text = dataString as! String
                    }
                    print(dataString)
                }catch{
                    print(error)
                }
                
            }
            task.resume()
        }catch{
            print(error)
        }
        
    }
    func decryptQR(url_requested: String){
        let private2 = keychain["priv2"]!
        let public2 = keychain["QR"]!
        //        let private2 = self.priv2raw!
        //        let public2 = self.pub2!
        
        let json = [
            "message" : "\(public2)",
            "privateKey" : "\(private2)"
        ]
        print(keychain["QR"])
        do{
            let url:NSURL = NSURL(string: url_requested)!
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
                    //let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[])
                    var dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    dataString = dataString!.stringByReplacingOccurrencesOfString("]", withString: "")
                    dataString = dataString!.stringByReplacingOccurrencesOfString("[", withString: "")
                    dataString = dataString!.stringByReplacingOccurrencesOfString(",", withString: "")
                    //make objects split "" into arrays
                    //then set objects with array indexes
                    dispatch_async(dispatch_get_main_queue()) {
                        self.show_message.text = dataString as! String
                    }
                    print(dataString)
                }catch{
                    print(error)
                }
                
            }
            task.resume()
        }catch{
            print(error)
        }
        
    }

}

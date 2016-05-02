//
//  LoginViewController.swift
//  lockchain
//
//  Created by Daniel Bell on 5/1/16.
//  Copyright © 2016 Frederik Jacques. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userEmailTextField.delegate = self;
        self.userPasswordTextField.delegate = self;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        super.touchesBegan(touches, withEvent: event);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder();
        //        print("hello");
        return true;
    }
    
    
    
    
    
    
    @IBAction func LoginButtonTapped(sender: AnyObject) {
        
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        
        let userEmailStored = NSUserDefaults.standardUserDefaults().stringForKey("userEmail");
        
        let userPasswordStored = NSUserDefaults.standardUserDefaults().stringForKey("userPassword");
        
        
        if (userEmailStored == userEmail){
            if (userPasswordStored == userPassword){
                //login is successful 
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn");
                
                NSUserDefaults.standardUserDefaults().synchronize();
                
                self.dismissViewControllerAnimated(true, completion: nil);
            }
        }
    }
    
    
    
    

}

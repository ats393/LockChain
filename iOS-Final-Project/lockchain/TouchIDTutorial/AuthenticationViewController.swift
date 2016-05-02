//
//  ViewController.swift
//  TouchIDTutorial
//
//  Created by Frederik Jacques on 30/09/15.
//  Copyright © 2015 Frederik Jacques. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {

    /**
        This method gets called when the users clicks on the
        login button in the user interface.
    
        - parameter sender: a reference to the button that has been touched
    */
    
    @IBOutlet var TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn");
        
        if (!isUserLoggedIn){
         self.performSegueWithIdentifier("registerView", sender: self)   
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        super.touchesBegan(touches, withEvent: event);
    }
    
    
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn");
        NSUserDefaults.standardUserDefaults().synchronize();
        self.performSegueWithIdentifier("registerView", sender: self);
        
    }
    
    
    @IBAction func userTappedBackground(sender: AnyObject){
        view.endEditing(true);
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        
        // 1. Create a authentication context
        let authenticationContext = LAContext()
        var error:NSError?
        
        // 2. Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.navigateToAuthenticatedViewController() //remember to change
            //showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
            
        }
        
        // 3. Check the fingerprint
        authenticationContext.evaluatePolicy(
            .DeviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Login with Fingerprint",
            reply: { [unowned self] (success, error) -> Void in
                
            if(success) {
                
                // Fingerprint recognized
                // Go to view controller
                self.navigateToAuthenticatedViewController()
                
            }else {
                
                // Check if there is an error
                if let error = error {
                    
                    let message = self.errorMessageForLAErrorCode(error.code)
                    self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                    
                }
                
            }
            
        })
        
    }
    
    /**
        This method will present an UIAlertViewController to inform the user that the device has not a TouchID sensor.
    */
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        
        showAlertWithTitle("Error", message: "This device does not have a TouchID sensor.")
        
    }
    
    /**
        This method will present an UIAlertViewController to inform the user that there was a problem with the TouchID sensor.
    
        - parameter error: the error message
    
    */
    func showAlertViewAfterEvaluatingPolicyWithMessage( message:String ){
        
        showAlertWithTitle("Error", message: message)
        
    }

    /**
        This method presents an UIAlertViewController to the user.
        
        - parameter title:  The title for the UIAlertViewController.
        - parameter message:The message for the UIAlertViewController.
    
    */
    func showAlertWithTitle( title:String, message:String ) {
     
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
            self.presentViewController(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    /**
    This method will return an error message string for the provided error code.
    The method check the error code against all cases described in the `LAError` enum.
    If the error code can't be found, a default message is returned.
    
    - parameter errorCode: the error code
    - returns: the error message
    */
func errorMessageForLAErrorCode( errorCode:Int ) -> String{
    
    var message = ""
    
    switch errorCode {
        
    case LAError.AppCancel.rawValue:
        message = "Authentication was cancelled by application"
        
    case LAError.AuthenticationFailed.rawValue:
        message = "The user failed to provide valid credentials"
        
    case LAError.InvalidContext.rawValue:
        message = "The context is invalid"
        
    case LAError.PasscodeNotSet.rawValue:
        message = "Passcode is not set on the device"
        
    case LAError.SystemCancel.rawValue:
        message = "Authentication was cancelled by the system"
        
    case LAError.TouchIDLockout.rawValue:
        message = "Too many failed attempts."
        
    case LAError.TouchIDNotAvailable.rawValue:
        message = "TouchID is not available on the device"
        
    case LAError.UserCancel.rawValue:
        message = "You have cancelled your login attempt"
        
    case LAError.UserFallback.rawValue:
        message = "The user chose to use the fallback"
        
    default:
        message = "Did not find error code on LAError object"
        
    }
    
    return message
    
}
    
    /**
        This method will push the authenticated view controller onto the UINavigationController stack
    */
    func navigateToAuthenticatedViewController(){
        
        if let loggedInVC = storyboard?.instantiateViewControllerWithIdentifier("LoggedInViewController") {
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                self.navigationController?.pushViewController(loggedInVC, animated: true)
                
            }
            
        }
        
    }

}


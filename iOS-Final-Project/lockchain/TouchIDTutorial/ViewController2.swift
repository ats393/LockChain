//
//  ViewController.swift
//  QRCodeReaderDemo
//
//  Created by TheAppGuruz-iOS-103 on 19/01/15.
//  Copyright (c) 2015 TheAppGururz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController2: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var lblQRCodeResult: UILabel!
    @IBOutlet weak var lblQRCodeLabel: UILabel!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwQRCode:UIView?
    let keychain = Keychain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        super.touchesBegan(touches, withEvent: event);
    }
    
    
    
    func configureVideoCapture() {
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
            
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            let alertView:UIAlertView = UIAlertView(title: "Device Error", message:"Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done") 
            alertView.show()
            return
        }
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    func addVideoPreviewLayer() {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        self.view.bringSubviewToFront(lblQRCodeResult)
        self.view.bringSubviewToFront(lblQRCodeLabel)
    }
    
    func initializeQRView() {
        vwQRCode = UIView()
        vwQRCode?.layer.borderColor = UIColor.redColor().CGColor
        vwQRCode?.layer.borderWidth = 5
        self.view.addSubview(vwQRCode!)
        self.view.bringSubviewToFront(vwQRCode!)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwQRCode?.frame = CGRectZero
            lblQRCodeResult.text = "NO QRCode text detacted"
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwQRCode?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                lblQRCodeResult.text = objMetadataMachineReadableCodeObject.stringValue
                keychain["QR"] = objMetadataMachineReadableCodeObject.stringValue
                var myAlert = UIAlertController(title: "Alert", message: "Key Captured", preferredStyle: UIAlertControllerStyle.Alert);
                let okAction = (UIAlertAction(title: "Thanks", style: .Default, handler:
                    {
                        [unowned self] (action) -> Void in
                        
                        self.performSegueWithIdentifier("QRdone", sender: self)
                    }))

                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated: true, completion:nil);

            }
        }
    }
}

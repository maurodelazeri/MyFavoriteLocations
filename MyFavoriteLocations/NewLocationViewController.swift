//
//  NewLocationViewController.swift
//  MyFavoriteLocations
//
//  Created by Steven De Cock on 12/11/14.
//  Copyright (c) 2014 Steven De Cock. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData
import CoreLocation
import MobileCoreServices

class NewLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate,UIAlertViewDelegate{
    
    var geolocation : CLGeocoder!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var locationImage: UIImageView!
    //var captureDevice : AVCaptureDevice?
    var locationManager = CLLocationManager()
    var imageData : NSData?
    var beenHereBefore = false
    var cameraController : UIImagePickerController?
    var plaatsName : String?
    
    var favLoc : FavoritePlace!
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    
    override func viewDidLoad() {
        println("view did load")

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
   
    }
    
    func cameraSupportMedia(mediaType : String , sourceType : UIImagePickerControllerSourceType) -> Bool
    {
        let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType)as [String]
        for type in availableMediaTypes
        {
            if type == mediaType{
                return true
            }
        }
        return false
    }
    
    
    func doesCameraSupportTakingPhoto() ->  Bool
    {
        return cameraSupportMedia(kUTTypeImage, sourceType: .Camera)
    }
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if beenHereBefore{
            return
        }
        else{
            beenHereBefore = true
        }
        if isCameraAvailable() && doesCameraSupportTakingPhoto(){
            cameraController = UIImagePickerController()
            
            if let theController = cameraController {
                theController.sourceType = .Camera
                theController.mediaTypes = [kUTTypeImage as NSString]
                theController.allowsEditing = true
                theController.delegate = self
                
                presentViewController(theController, animated: true, completion: nil)
            }
        }
        else
        {
            println("Camera Not Available")
        }
    }
    func imageWasSavedSuccessfully( image : UIImage, didFinishSavingWithError error: NSError!,context : UnsafeMutablePointer<()>){
        if let theError = error{
            println("a wild error appeared :\(theError) ")
        }
        else
        {
            println("image successfully saved")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        println("Successfull picked")
        
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
        
        if let type: AnyObject = mediaType{
            if type is String {
                let stringType = type as String
                
              if stringType == kUTTypeImage as NSString {
                    let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
                    if let theMetaData = metadata{
                        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                        if var theImage = image{
                            
                            var rotatedImage : UIImage!
                            if theImage.imageOrientation == UIImageOrientation.Up
                            {
                                rotatedImage = theImage
                            }
                            else
                            {
                                UIGraphicsBeginImageContextWithOptions(theImage.size, false, theImage.scale)
                                var rect = CGRect(origin: CGPoint(x: 0,y: 0), size: theImage.size)
                                theImage.drawInRect(rect)
                                rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                                
                            }
                
                            
                            locationImage.image = rotatedImage
                            imageData = UIImagePNGRepresentation(rotatedImage)
                            
                        }
                    }
                }
            }
        }
        locationManager.startUpdatingLocation()
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var CancelButton: UIButton!
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       let sender = sender as UIButton
        println("prepereForSegue aangeroepen")
        if(segue.identifier == "todetail")
        {
            if(sender == self.CancelButton)
            {
                println("Perform segue cancelbutton")
            }
            else
            {
                favLoc = NSEntityDescription.insertNewObjectForEntityForName("FavoritePlace", inManagedObjectContext: self.managedObjectContext!) as FavoritePlace
                favLoc.name = titleTextField.text
                favLoc.placeName = plaatsName!
                favLoc.longitude = NSNumber(double: locationManager.location.coordinate.longitude)
                favLoc.latitude = NSNumber(double:locationManager.location.coordinate.latitude)
                favLoc.foto = self.imageData!
                favLoc.comment = commentTextField.text
                
                
                NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
                
                var loc = segue.destinationViewController as LocationViewController
               
                
                loc.favPlace = favLoc
                println("Favloc.place \(favLoc.placeName)")
            }
        
            
        }
        
    }
    
    
    
    
    @IBAction func submit(sender: UIButton) {

        println("start updating")
                //locationManager.stopUpdatingLocation()

        performSegueWithIdentifier("todetail", sender: sender)
       
    }

    @IBAction func cancel(sender: AnyObject) {
        
        var alertView = UIAlertView(title: "Are you sure?", message: "The photo will be deleted, are you sure??", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alertView.show()
        
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 1)
        {
            performSegueWithIdentifier("todetail", sender: self.CancelButton)
        }
    }

    
    let plaatsname : String!
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        var loc = locations.last as CLLocation
        println("Latitude :\(loc.coordinate.latitude) Longitude \(loc.coordinate.longitude)")
        locationToAdress(loc.coordinate.latitude, long: loc.coordinate.longitude)
 
    }
    func locationToAdress(lat : Double , long : Double)
    {
        var location = CLLocation(latitude: lat, longitude: long)
        geolocation = CLGeocoder()
        geolocation.reverseGeocodeLocation(location, completionHandler:
            {(placemarks,error) in
                if (error != nil) {
                    println("Reversegeocode failure  : \(error.localizedDescription)")
                    return
                }
                if placemarks.count > 0{
                    
                    var place = CLPlacemark(placemark : placemarks[0] as CLPlacemark)
                    var stringResult =  "\(place.locality), \(place.postalCode), \(place.thoroughfare)"
                    self.plaatsName = stringResult
                    
                }
                else
                {
                    println("Geen klodden gevonden")
                }
                
        })
    }

 
}

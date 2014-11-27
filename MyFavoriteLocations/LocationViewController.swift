//
//  LocationViewController.swift
//  MyFavoriteLocations
//
//  Created by Steven De Cock on 5/11/14.
//  Copyright (c) 2014 Steven De Cock. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class LocationViewController : UIViewController , UITabBarDelegate{
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    var favPlace : FavoritePlace!

    
    @IBOutlet weak var plaatAdres: UILabel!
    @IBOutlet weak var plaatTitle: UILabel!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favFoto: UIImageView!
    
    func createDummyData(title:NSString,plaats: NSString, longitude: Double, latitude:Double)
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("FavoritePlace", inManagedObjectContext: self.managedObjectContext!) as FavoritePlace
        newItem.name = title
        newItem.placeName = plaats
        newItem.longitude = longitude
        newItem.latitude = latitude
        //newItem.foto = "hogent"
        newItem.comment = "een hele lange tekst over die plaats die hier te zien is"
        
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        switch item.tag{
        case 1: self.createMapView(MKMapType.Standard)
        break
        case 2: self.createMapView(MKMapType.Satellite)
        break
        default:self.mapView.mapType = MKMapType.Standard
        break
        }
        
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad()
    {
        if(coreDataHasEntriesForFavoriteLocation())
        {
            if(favPlace == nil)
            {
                persistData()
                
            }
        }
        else
        {
           createDummyData("HoGent", plaats: "Aalst", longitude: 4.0335872,latitude: 50.9376287)
            if(favPlace == nil)
            {
                persistData()
            }
            
        }
        
        self.navigationItem.title = favPlace.name
        self.plaatTitle.text = favPlace.name
        
        if(favFoto == nil)
        {
            self.favFoto.image = UIImage(named: "hogent")
        }
        else
        {
           self.favFoto.image = UIImage(data:favPlace.foto)
        }
        
        self.plaatTitle.text = favPlace.name
        self.commentTextView.text = favPlace.comment
        self.plaatAdres.text = favPlace.placeName
        createMapView(MKMapType.Standard)
        
        
        
        
    }
    @IBOutlet weak var standaardButton: UITabBar!
    @IBOutlet weak var satteliteButton: UITabBar!
    
    
    
    func persistData()
    {
        let fetch = NSFetchRequest(entityName:"FavoritePlace")
        if let fetchRes = managedObjectContext!.executeFetchRequest(fetch, error: nil) as? [FavoritePlace]{
            favPlace = fetchRes.first;
         
        }
    }
    
    func coreDataHasEntriesForFavoriteLocation()->Bool
    {
        let fetch = NSFetchRequest(entityName: "FavoritePlace")
        let fetchRes = managedObjectContext!.executeFetchRequest(fetch, error: nil)
        return fetchRes?.count != 0
    }
    
    func createMapView(type : MKMapType)
    {
        
        let lat : Double = favPlace.latitude as Double
        let long : Double = favPlace.longitude as Double
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegionMakeWithDistance(center, 1000,1000)
        mapView.region = region
        mapView.mapType = type
        let pin = MKPointAnnotation()
        pin.coordinate = center
        pin.title = favPlace.placeName
        mapView.addAnnotation(pin)
    }
    

}

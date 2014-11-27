//
//  LocationsViewController.swift
//  MyFavoriteLocations
//
//  Created by Steven De Cock on 5/11/14.
//  Copyright (c) 2014 Steven De Cock. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewController : UITableViewController, UIGestureRecognizerDelegate, UIAlertViewDelegate{
    
    var locations : [FavoritePlace] = []

    
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
       
        let fetch = NSFetchRequest(entityName:"FavoritePlace")
        if let fetchRes = managedObjectContext!.executeFetchRequest(fetch, error: nil) as? [FavoritePlace]{
        locations = fetchRes;
            println("\(locations.count)")
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh:", name: "refresh", object: nil)
        
        
        
    }
    
    
    @IBAction func addNewItem(sender: AnyObject) {
        
        performSegueWithIdentifier("newSegue", sender: sender)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favCell") as UITableViewCell
        let loc = locations[indexPath.row]
            cell.textLabel.text = loc.name
            cell.detailTextLabel?.text = loc.placeName
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count;
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(segue.identifier)")
       if(segue.identifier == "tableSegue")
       {
        println("prepare for segue tableSegue")
        let locationViewController = segue.destinationViewController as LocationViewController
        locationViewController.favPlace = locations[tableView.indexPathForSelectedRow()!.row]
        
        }
        

    }

    func refresh(notification : NSNotificationCenter)
    {
        let fetch = NSFetchRequest(entityName:"FavoritePlace")
        if let fetchRes = managedObjectContext!.executeFetchRequest(fetch, error: nil) as? [FavoritePlace]{
            locations = fetchRes;
            println("\(locations.count)")
        }
        println("refresh aangeroepen")
        self.tableView.reloadData();
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete)
        {
            let locationToDelete = locations[indexPath.row] as FavoritePlace
            
            deleteFavLocation(locationToDelete)
            
            
        }
    }
    
    func deleteFavLocation(location : FavoritePlace)
    {
        if(locations.count>1)
        {
            managedObjectContext?.deleteObject(location)
            NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)

        }
    }
    
 }
    
  


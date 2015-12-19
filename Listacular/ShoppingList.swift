//
//  ShoppingList.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class ShoppingList: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "SList")
        let primarySortDescription = NSSortDescriptor(key: "slcross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "slitem", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        return fetchRequest
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "slcross", cacheName: nil)
        return frc
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func AddNew(sender: AnyObject) {
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        
        self.tableView.reloadData()
        
        //TableView Background Color
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.blackColor()
        self.tableView.rowHeight = 80
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }
    
        func editButtonPressed(){
            tableView.setEditing(!tableView.editing, animated: true)
            if tableView.editing == true{
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
            }else{
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
            }

        }//end edit button
    
    
    override func viewDidDisappear(animated: Bool) {
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        self.tableView.reloadData()
    }
    
    //tableView Data
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        moc.deleteObject(managedObject)
        do {
            try moc.save()
        } catch _ {
            print("Failed to save.")
            return
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let numberOfSections = frc.sections?.count
        return numberOfSections!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        let sectionHeader = "Items - #\(frc.sections![section].numberOfObjects)"
        let sectionHeader1 = "Crossed Off Items - #\(frc.sections![section].numberOfObjects)"
        if (frc.sections!.count > 0) {
            let sectionInfo = frc.sections![section]
            if (sectionInfo.name == "0") { // "0" is the string equivalent of false
                return sectionHeader
            } else {
                return sectionHeader1 
            } 
        } else { 
            return nil; 
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = frc.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SLTableViewCell
        let items = frc.objectAtIndexPath(indexPath) as! SList
        cell.backgroundColor = UIColor.clearColor()
        cell.cellLabel.text = "\(items.slitem!) - Qty: \(items.slqty!)"
        cell.cellLabel.font = UIFont.systemFontOfSize(30)
        if (items.slcross == true) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let items = frc.objectAtIndexPath(indexPath) as! SList
        
        if (items.slcross == true) {
            items.slcross = false
        } else {
            items.slcross = true
        }
        tableView.reloadData()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    //segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "editCell" {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let SListController:SLEdit = segue.destinationViewController as! SLEdit
            let items:SList = frc.objectAtIndexPath(indexPath!) as! SList
            SListController.item = items
        }
    }
    
}
//
//  ViewController.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/10/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var contactArray = [Contact]()
    @IBOutlet weak var contactTableView: UITableView!

    
    //MARK: - Interactivty Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! DetailsViewController
        if segue.identifier == "seeSelectedContact" {
            let indexPath = contactTableView.indexPathForSelectedRow
            let selectedContact = contactArray[indexPath!.row]
            destController.selectedContact = selectedContact
            contactTableView.deselectRowAtIndexPath(indexPath!, animated: true)
        } else if segue.identifier == "addNewContact" {
            destController.selectedContact = nil
        }
        
    }
    
    //MARK: - TableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let currentContact = contactArray[indexPath.row]
        cell.textLabel?.text = "\(currentContact.lastName!), \(currentContact.firstName!) "
        cell.detailTextLabel?.text = "\(currentContact.emailAddress!)"
        return cell
    }
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! CustomCellTableViewCell
        let currentContact = contactArray[indexPath.row]
        cell.nameLabel!.text = "\(currentContact.lastName!), \(currentContact.firstName!) "
        cell.emailLabel!.text = currentContact.emailAddress!
        cell.phoneLabel!.text = currentContact.phoneNumber!
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func refreshTableData() {
        self.fetchEntries()
        contactTableView.reloadData()
    }
    
    //MARK: - Core Data Methods
    
    func tempAddRecords() {
        let entityDescription = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedObjectContext)!
        
        let newcontact1 = Contact(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newcontact1.lastName = "Crowder"
        newcontact1.firstName = "Geoff"
        newcontact1.emailAddress = "Gcrowds@gmail.com"
        newcontact1.streetAddress = "1001 Woodward Ave"
        newcontact1.cityAddress = "Detroit"
        newcontact1.stateAddress = "MI"
        newcontact1.zipAddress = "48304"
        newcontact1.phoneNumber = "2488774949"
        
        let newcontact2 = Contact(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newcontact2.lastName = "Zeffer"
        newcontact2.firstName = "Phil"
        newcontact2.emailAddress = "Phil@theZeff.com"
        newcontact2.streetAddress = "4753 California"
        newcontact2.cityAddress = "Santa Ana"
        newcontact2.stateAddress = "CA"
        newcontact2.zipAddress = "77777"
        newcontact2.phoneNumber = "6785551234"
        
        appDelegate.saveContext()
    }
    
    func fetchEntries() -> [Contact]? {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        do {
            let tempArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Contact]
            return tempArray
        }catch {
            return nil
        }
    }

    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tempAddRecords()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        contactArray = fetchEntries()!
        print("Count : \(contactArray.count)")
        self.refreshTableData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


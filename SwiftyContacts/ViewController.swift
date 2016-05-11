//
//  ViewController.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/10/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var contactArray = [Contact]()
    @IBOutlet private weak var contactTableView: UITableView!
    @IBOutlet private weak var lastNameTxtField:UITextField!
    var contactStore = CNContactStore()

    //MARK: - ContactPicker Methods
    
    @IBAction private func showContactList(sender: UIBarButtonItem){
        print("Show Contact List")
        let contactListVC = CNContactPickerViewController()
        contactListVC.delegate = self
        presentViewController(contactListVC, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        let entityDescription = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedObjectContext)!
        let newlistcontact = Contact(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newlistcontact.lastName = contact.familyName
        newlistcontact.firstName = contact.givenName
        if let email = contact.emailAddresses.first?.value as? String {
            newlistcontact.emailAddress = email
        }
        if let address = contact.postalAddresses.first {
            let addressValue = address.value as! CNPostalAddress
            newlistcontact.streetAddress = addressValue.street
            newlistcontact.cityAddress = addressValue.city
            newlistcontact.stateAddress = addressValue.state
            newlistcontact.zipAddress = addressValue.postalCode
        }
        if let phone = contact.phoneNumbers.first?.value as? String {
            newlistcontact.phoneNumber = phone
        }
        newlistcontact.rating = 0
        newlistcontact.contactIdentifer = contact.identifier
        appDelegate.saveContext()
    }
    
    //MARK: - Interactivty Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! DetailsViewController
        if segue.identifier == "seeSelectedContact" {
            let indexPath = contactTableView.indexPathForSelectedRow!
            let selectedContact = contactArray[indexPath.row]
            destController.selectedContact = selectedContact
            contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        cell.nameLabel.text = "\(currentContact.lastName!), \(currentContact.firstName!) "
        if let email = currentContact.emailAddress {
            cell.emailLabel.text = email
        } else {
            cell.emailLabel.text = ""
        }
        if let phone = currentContact.phoneNumber {
            cell.phoneLabel.text = phone
        } else {
            cell.phoneLabel.text = ""
        }
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
        newcontact1.rating = 3
        newcontact1.contactIdentifer = ""
        
        let newcontact2 = Contact(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newcontact2.lastName = "Zeffer"
        newcontact2.firstName = "Phil"
        newcontact2.emailAddress = "Phil@theZeff.com"
        newcontact2.streetAddress = "4753 California"
        newcontact2.cityAddress = "Santa Ana"
        newcontact2.stateAddress = "CA"
        newcontact2.zipAddress = "77777"
        newcontact2.phoneNumber = "6785551234"
        newcontact2.rating = 7
        newcontact2.contactIdentifer = ""
        
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

    //MARK: - Contact Access Verification methods
    
    private func requestAccessToContactType(type: CNEntityType) {
        contactStore.requestAccessForEntityType(type) { (accessGranted: Bool, error: NSError?) -> Void in
            if accessGranted {
                print("Granted")
            } else {
                print("Not Granted")
            }
        }
    }
    
    private func checkContactAuthorizationStatus(type: CNEntityType) {
        let status = CNContactStore.authorizationStatusForEntityType(type)
        switch status {
        case .NotDetermined:
            print("Not Determined")
            requestAccessToContactType(type)
        case .Authorized:
            print("Authorized")
        case.Restricted, .Denied:
            print("Restricted/Denied")
        }
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tempAddRecords()
        checkContactAuthorizationStatus(.Contacts)
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


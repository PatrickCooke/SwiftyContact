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
    var indexArray = [String]()

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
        if let phone = contact.phoneNumbers.first?.value as? CNPhoneNumber {
            newlistcontact.phoneNumber = phone.stringValue
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
            //let selectedContact = contactArray[indexPath.section]
            let selectedContact = filterArrayForSection(contactArray, section: indexPath.section)
            destController.selectedContact = selectedContact[indexPath.row]
            contactTableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "addNewContact" {
            destController.selectedContact = nil
        }
        
    }
    
    //MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArrayForSection(contactArray, section: section).count
        //return contactArray.count
    }
    
   /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//        let currentContact = contactArray[indexPath.row]
        let sectionArray = filterArrayForSection(contactArray, section: indexPath.section)
        let currentContact = sectionArray[indexPath.row]
        cell.textLabel?.text = "\(currentContact.lastName!), \(currentContact.firstName!) "
        cell.detailTextLabel?.text = "\(currentContact.emailAddress!)"
        return cell
    }
   */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! CustomCellTableViewCell
        let sectionArray = filterArrayForSection(contactArray, section: indexPath.section)
        let currentContact = sectionArray[indexPath.row]
        //cell.nameLabel.text = "\(currentContact.lastName), \(currentContact.firstName)"
        
        if let firstName = currentContact.firstName {
        if let lastName = currentContact.lastName {
            cell.nameLabel.text = "\(lastName), \(firstName)"
            }
        }
        
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
        contactArray = self.fetchEntries()!
        print("Count : \(contactArray.count)")
        indexArray = createIndexfromArray(contactArray)
        print(indexArray)
        contactTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexArray[section]
        
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexArray
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionArray = filterArrayForSection(contactArray, section: section)
        return "Count: \(sectionArray.count)"
    }
    
    //MARK: - Core Data Methods
    

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

    private func filterArrayForSection(array: [Contact], section: Int) -> [Contact] {
        let sectionHeader = indexArray[section]
        return array.filter {String($0.lastName![$0.lastName!.startIndex.advancedBy(0)]) == sectionHeader}
    }

    
    private func createIndexfromArray(array: [Contact]) -> [String] {
        let letterArray = array.map {String($0.lastName![$0.lastName!.startIndex.advancedBy(0)])}
        var uniqueArray = Array(Set(letterArray))
        uniqueArray.sortInPlace()
        return uniqueArray
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
        self.refreshTableData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


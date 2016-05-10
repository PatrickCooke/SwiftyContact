//
//  DetailsViewController.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/10/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {

    var selectedContact :Contact?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var streetTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var zipTxtField: UITextField!
    
    
    //MARK: - Interactivity Methods
   
    func saveAndPop() {
        appDelegate.saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButton(sender: UIBarButtonItem) {
        if let selContact = selectedContact {
            selContact.firstName = firstNameTxtField.text
            selContact.lastName = lastNameTxtField.text
            selContact.emailAddress = emailTxtField.text
            selContact.phoneNumber = phoneTxtField.text
            selContact.streetAddress = streetTxtField.text
            selContact.cityAddress = cityTxtField.text
            selContact.stateAddress = stateTxtField.text
            selContact.zipAddress = zipTxtField.text
            self.saveAndPop()
        }
    }
    
    @IBAction func deletebutton(sender: UIBarButtonItem) {
        managedObjectContext.deleteObject(selectedContact!)
        self.saveAndPop()
    }
    
    
    
    //MARK: -  Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selContact = selectedContact {
            nameLabel.text = selContact.firstName! + " " + selContact.lastName!
            firstNameTxtField.text = selContact.firstName!
            lastNameTxtField.text = selContact.lastName!
            emailTxtField.text = selContact.emailAddress
            phoneTxtField.text = selContact.phoneNumber
            streetTxtField.text = selContact.streetAddress
            cityTxtField.text = selContact.cityAddress
            stateTxtField.text = selContact.stateAddress
            zipTxtField.text = selContact.zipAddress
        } else {
            let entityDescription = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedObjectContext)!
            selectedContact = Contact(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
            nameLabel.text = ""
            firstNameTxtField.text = ""
            lastNameTxtField.text = ""
            emailTxtField.text = ""
            phoneTxtField.text = ""
            streetTxtField.text = ""
            cityTxtField.text = ""
            stateTxtField.text = ""
            zipTxtField.text = ""
        }
    }

    override func viewWillDisappear(animated: Bool) {
        if (managedObjectContext .hasChanges) {
            managedObjectContext .rollback();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

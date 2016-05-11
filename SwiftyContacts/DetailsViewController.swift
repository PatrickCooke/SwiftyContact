//
//  DetailsViewController.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/10/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class DetailsViewController: UIViewController, CNContactViewControllerDelegate {

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
    @IBOutlet weak var ratingStackView: UIStackView!
    var starRating = 0 as Int
    var contactStore = CNContactStore()
    
    //MARK: - Contact List Search
    
    @IBAction private func showContactEditor(sender: UIBarButtonItem){
        print("Show Editor")
        if let identifier = selectedContact?.contactIdentifer {
            presentContactMatchingidentifier(identifier)
        }
    }
    
    private func presentContactMatchingidentifier(identifier: String){
        let predicate = CNContact.predicateForContactsWithIdentifiers([identifier])
        let keysToFetch = [CNContactViewController.descriptorForRequiredKeys()]
        do {
            let contacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            if let firstContact = contacts.first {
                print("Contant: " + firstContact.givenName)
                displayContact(firstContact)
            }
        } catch {
            print("error")
        }
    }
    private func displayContact(contact: CNContact) {
        let contactVC = CNContactViewController(forContact: contact)
        contactVC.contactStore = contactStore
        contactVC.delegate = self
        navigationController!.pushViewController(contactVC, animated: true)
    }
    
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?) {
        print("Done with: \(contact!.familyName)")
        selectedContact!.lastName = contact!.familyName
        selectedContact!.firstName = contact!.givenName
        if let email = contact!.emailAddresses.first?.value as? String {
            selectedContact!.emailAddress = email
        }
        if let address = contact!.postalAddresses.first {
            let addressValue = address.value as! CNPostalAddress
            selectedContact!.streetAddress = addressValue.street
            selectedContact!.cityAddress = addressValue.city
            selectedContact!.stateAddress = addressValue.state
            selectedContact!.zipAddress = addressValue.postalCode
        }
        if let phone = contact!.phoneNumbers.first?.value as? CNPhoneNumber {
            selectedContact!.phoneNumber = phone.stringValue
        }
        selectedContact!.rating = 0
        selectedContact!.contactIdentifer = contact!.identifier
        appDelegate.saveContext()
        reloadDetailScreen()
    }

    
    //MARK: - Interactivity Methods
   
    func saveAndPop() {
        appDelegate.saveContext()
        self.navigationController!.popViewControllerAnimated(true)
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
            if ratingStackView.arrangedSubviews.count > 1 {
                selContact.rating = ratingStackView.arrangedSubviews.count - 1
            } else {
                selContact.rating = 0
            }
            self.saveAndPop()
        }
    }
    
    @IBAction func deletebutton(sender: UIBarButtonItem) {
        if let selContact = selectedContact{
            managedObjectContext.deleteObject(selContact)
            self.saveAndPop()
        }
    }
    
    private func addStar() {
        let starImageView = UIImageView(image: UIImage(named: "IconStar"))
        starImageView.contentMode = .ScaleAspectFit
        let starcount = ratingStackView.arrangedSubviews.count
        if starcount < 10{
            ratingStackView.insertArrangedSubview(starImageView, atIndex: starcount - 1)
            UIView.animateWithDuration(0.25) { () -> Void in
                self.ratingStackView.layoutIfNeeded()
            }
        }
    }
    
    @IBAction private func addButtonPressed(sender: UIButton){
        print("add")
        addStar()
    }
    
    @IBAction private func removedButtonPressed(sender: UIButton){
        print("remove")
        let starCount = ratingStackView.arrangedSubviews.count
        if starCount > 1 {
            let starToRemove = ratingStackView.arrangedSubviews[starCount - 2]
            ratingStackView.removeArrangedSubview(starToRemove)
            starToRemove.removeFromSuperview()
            UIView.animateWithDuration(0.25) { () -> Void in
                self.ratingStackView.layoutIfNeeded()
            }
        }
    }
    
    private func reloadDetailScreen () {
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
            if let rating = selContact.rating?.intValue {
                for _ in 0..<rating {
                    addStar()
                }
            }
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
    
    //MARk: - Data Validation Methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTxtField {
            let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            return string == numberFiltered
        }
        return true
    }
    
    //MARK: -  Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDetailScreen()
        print(selectedContact?.contactIdentifer)
    }

    override func viewWillDisappear(animated: Bool) {
        if (managedObjectContext .hasChanges) {
            managedObjectContext .rollback()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

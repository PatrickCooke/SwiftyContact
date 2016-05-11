//
//  Contact+CoreDataProperties.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/11/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var cityAddress: String?
    @NSManaged var emailAddress: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var stateAddress: String?
    @NSManaged var streetAddress: String?
    @NSManaged var zipAddress: String?
    @NSManaged var contactIdentifer: String?

}

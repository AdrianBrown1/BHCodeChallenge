//
//  CoreDataStack.swift
//  TrackingISS
//
//  Created by Adrian Brown on 4/18/17.
//  Copyright © 2017 Adrian Brown. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private static let name = "PinModel"

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStack.name)
        
        container.loadPersistentStores { storeDescription, error in
        
            if let error = error as NSError? {
                print(error)
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges{
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}

extension Pin {
    class var fetch: NSFetchRequest<Pin> {
        do {
            return NSFetchRequest<Pin>(entityName: "Pin")
        }
   
    }
    
    public override var description: String {
        
        return "Pins name \(name) lat: \(latitude) long: \(longitude)"
        
    }
    
    
    
}

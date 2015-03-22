//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import CoreData


///  An instance of `CoreDataModel` represents a Core Data model.
///  It provides the model and store URLs as well as functions for interacting with the store.
public struct CoreDataModel: Printable {

    ///  The name of the Core Data model resource.
    public let name: String

    ///  The bundle in which the model is located.
    public let bundle: NSBundle

    ///  The file URL specifying the store in the documents directory.
    public var storeURL: NSURL {
        get {
            var error: NSError?
            let documentsDirectoryURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
            assert(documentsDirectoryURL != nil, "*** Error finding documents directory: \(error)")
            return documentsDirectoryURL!.URLByAppendingPathComponent(databaseFileName)
        }
    }

    ///  The file URL specifying the model file in the bundle specified by `bundle`.
    public var modelURL: NSURL {
        get {
            let url = bundle.URLForResource(name, withExtension: "momd")
            assert(url != nil, "*** Error loading resource for model: \(name)")
            return url!
        }
    }

    ///  The database file name for the store.
    public var databaseFileName: String {
        get {
            return name + ".sqlite"
        }
    }

    ///  The managed object model for the model specified by `name`.
    public var managedObjectModel: NSManagedObjectModel {
        get {
            let model = NSManagedObjectModel(contentsOfURL: modelURL)
            assert(model != nil, "*** Error loading managed object model at url: \(modelURL)")
            return model!
        }
    }

    ///  Queries the meta data for the persistent store specified by the receiver and returns whether or not a migration is needed.
    ///  Returns `true` if the store requires a migration, `false` otherwise.
    public var modelStoreNeedsMigration: Bool {
        get {
            var error: NSError?
            if let sourceMetaData = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(nil, URL: storeURL, error: &error) {
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            }
            println("*** \(toString(CoreDataModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Failure checking persistent store coordinator meta data: \(error)")
            return false
        }
    }

    ///  Removes the existing model store specfied by the receiver.
    ///
    ///  :returns: A tuple value containing a boolean to indicate success and an error object if an error occurred.
    public func removeExistingModelStore() -> (success: Bool, error: NSError?) {
        var error: NSError?
        let fileManager = NSFileManager.defaultManager()

        if let storePath = storeURL.path {
            if fileManager.fileExistsAtPath(storePath) {
                let success = fileManager.removeItemAtURL(storeURL, error: &error)
                if !success {
                    println("*** \(toString(CoreDataModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Could not remove model store at url: \(error)")
                }
                return (success, error)
            }
        }

        return (false, nil)
    }

    ///  Constructs new `CoreDataModel` instance with the specified name and bundle.
    ///
    ///  :param: name   The name of the Core Data model.
    ///  :param: bundle The bundle in which the model is located. The default parameter value is `NSBundle.mainBundle()`.
    ///
    ///  :returns: A new `CoreDataModel` instance.
    public init(name: String, bundle: NSBundle = NSBundle.mainBundle()) {
        self.name = name
        self.bundle = bundle
    }

    // MARK: Printable

    /// A string containing a textual representation of the `CoreDataModel`.
    public var description: String {
        get {
            return "<\(toString(CoreDataModel.self)): name=\(name), needsMigration=\(modelStoreNeedsMigration), databaseFileName=\(databaseFileName), modelURL=\(modelURL), storeURL=\(storeURL)>"
        }
    }
    
}

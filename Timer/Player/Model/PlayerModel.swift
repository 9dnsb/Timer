//
//  PlayerModel.swift
//  Timer
//
//  Created by David Blatt on 3/22/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import CoreData


struct playerModel {
    var isTimerRunning = false
    var seconds = 0
    var currentIntervalCycle = 0
    var totalIntervalCycles = 0
    var currentCycle = 0
    var totalCycles = 0
    var totalTime = 0
    var elapsedTime = 0
    var veryFirstInterval = true
    var prevSecond = 0

}

struct currentInterval {
    var totalIntervalSets = 0
    var currentIntervalSet = 0
    var firstInterval = true
    var currFirstInterval = true
    var runHigh = false
    var runLow = false
}

struct resumeButton {
    var resumeTapped = true
    var text = ""
}

protocol StructDecoder {
    // The name of our Core Data Entity
    static var EntityName: String { get }
    // Return an NSManagedObject with our properties set
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject
}

enum SerializationError: Error {
    // We only support structs
    case structRequired
    // The entity does not exist in the Core Data Model
    case unknownEntity(name: String)
    // The provided type cannot be stored in core data
    case unsupportedSubType(label: String?)
}

extension StructDecoder {
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject {
        let entityName = type(of:self).EntityName

        // Create the Entity Description
        guard let desc = NSEntityDescription.entity(forEntityName: entityName, in: context)
            else { throw SerializationError.unknownEntity(name: entityName) }

        // Create the NSManagedObject
        let managedObject = NSManagedObject(entity: desc, insertInto: context)

        // Create a Mirror
        let mirror = Mirror(reflecting: self)

        // Make sure we're analyzing a struct
        guard mirror.displayStyle == .some(.struct) else { throw SerializationError.structRequired }

        for case let (label?, anyValue) in mirror.children {
            managedObject.setValue(anyValue, forKey: label)
        }

        return managedObject
    }
}

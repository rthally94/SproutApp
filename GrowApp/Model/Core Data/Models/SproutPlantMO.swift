//
//  SproutPlantMO.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/2/21.
//

import CoreData
import UIKit

enum IconImageError: Error {
    case invalidParametersError
}

class SproutPlantMO: NSManagedObject {
    static func createNewPlant(in context: NSManagedObjectContext, completion: @escaping (SproutPlantMO) -> Void) {
        context.performAndWait {
            let newPlant = SproutPlantMO(context: context)
            newPlant.id = UUID().uuidString
            newPlant.creationDate = Date()

            completion(newPlant)
        }
    }

    static func createNewPlant(from existingPlant: SproutPlantMO, completion: @escaping (SproutPlantMO) -> Void) throws {
        guard let context = existingPlant.managedObjectContext else { throw NSManagedObjectError.noManagedObjectContextError }
        context.performAndWait {
            let newPlant = SproutPlantMO(context: context)
            newPlant.id = UUID().uuidString
            newPlant.creationDate = Date()

            newPlant.isTemplate = false

            newPlant.scientificName = existingPlant.scientificName
            newPlant.commonName = existingPlant.commonName
            if let nickName = existingPlant.nickname {
                newPlant.nickname = nickName + " Copy"
            }

            newPlant.imageData = existingPlant.imageData
            newPlant.symbolName = existingPlant.symbolName
            newPlant.hexColor = existingPlant.hexColor

            existingPlant.allTasks.forEach { task in
                do {
                    try SproutCareTaskMO.createNewTask(from: task) { newTask in
                        newPlant.managedObjectContext?.perform {
                            newPlant.addToCareTasks(newTask)
                        }
                    }
                } catch {
                    print("Error duplicating tasks to new plant: \(error)")
                }
            }

            completion(newPlant)
        }
    }

    var allTasks: Set<SproutCareTaskMO> {
        get { careTasks as? Set<SproutCareTaskMO> ?? [] }
        set { careTasks = newValue as NSSet }
    }

    var icon: UIImage? {
        if let imageData = imageData, let image = UIImage(data: imageData) {
            return image
        } else if let symbolName = symbolName, let symbolImage = UIImage(named: symbolName) ?? UIImage(systemName: symbolName) {
            return symbolImage
        } else {
            return nil
        }
    }

    var tintColor: UIColor? {
        if let hexColor = hexColor, let color = UIColor(hex: hexColor) {
            return color
        } else {
            return nil
        }
    }
}

extension SproutPlantMO {
    func setSymbol(name: String, tintColor: UIColor?) throws {
        guard let _  = UIImage(named: name) ?? UIImage(systemName: name) else { throw IconImageError.invalidParametersError }
        guard let hexString = tintColor?.hexString() else { throw IconImageError.invalidParametersError }

        symbolName = name
        hexColor = hexString
        imageData = nil
    }

    func setImage(_ image: UIImage?) throws {
        guard let data = image?.pngData() else { throw IconImageError.invalidParametersError }

        symbolName = nil
        hexColor = nil
        imageData = data
    }
}

extension SproutPlantMO {
    static func allTemplatesFetchRequest() -> NSFetchRequest<SproutPlantMO> {
        let request: NSFetchRequest<SproutPlantMO> = SproutPlantMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K == true", #keyPath(SproutPlantMO.isTemplate))

        let sortByCommonName = NSSortDescriptor(keyPath: \SproutPlantMO.commonName, ascending: true)
        request.sortDescriptors = [sortByCommonName]
        return request
    }
}

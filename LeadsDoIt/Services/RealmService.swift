//
//  RealmService.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 14.01.2024.
//

import Foundation
import RealmSwift

struct RealmService {
    static let realm = try? Realm()
    
    static func addBrowseToRealm(roverName: String, cameraName: String, date: Date) {
        let realmObject = RealmHistoryService()
        
        do {
            try realm?.write {
                realmObject.roverName = roverName
                realmObject.cameraName = cameraName
                realmObject.date = date
                realm?.add(realmObject)
            }
        } catch {
            print("Realm writing error")
        }
    }
}

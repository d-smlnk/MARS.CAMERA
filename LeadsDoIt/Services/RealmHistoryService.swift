//
//  RealmHistoryService.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 14.01.2024.
//

import Foundation
import RealmSwift

class RealmHistoryService: Object {
    @Persisted dynamic var roverName: String
    @Persisted dynamic var cameraName: String
    @Persisted dynamic var date: Date
}

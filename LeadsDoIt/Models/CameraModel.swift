//
//  CameraModel.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 15.01.2024.
//

import Foundation

struct CameraModel: Decodable {
    let id: Int?
    let name: String
    let rover_id: Int?
    let full_name: String
}

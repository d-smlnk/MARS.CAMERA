//
//  RoverModel.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 15.01.2024.
//

import Foundation

struct RoverModel: Decodable {
    let id: Int
    let name: String
    let landing_date: String
    let launch_date: String
    let status: String
    let max_sol: Int
    let max_date: String
    let total_photos: Int
    let cameras: [CameraModel]
}

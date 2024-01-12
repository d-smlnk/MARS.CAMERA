//
//  QueryModel.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 12.01.2024.
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

struct CameraModel: Decodable {
    let id: Int?
    let name: String
    let rover_id: Int?
    let full_name: String
}

struct PhotoModel: Decodable {
    let id: Int
    let sol: Int
    let camera: CameraModel
    let img_src: URL
    let earth_date: String
    let rover: RoverModel
}

struct MarsRoverResponseModel: Decodable {
    let photos: [PhotoModel]
}

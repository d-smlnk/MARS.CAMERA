//
//  PhotoModel.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 15.01.2024.
//

import Foundation

struct PhotoModel: Decodable {
    let id: Int
    let sol: Int
    let camera: CameraModel
    let img_src: URL
    let earth_date: String
    let rover: RoverModel
}

//
//  MarsAPIService.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 12.01.2024.
//

import Foundation
import Alamofire
import UIKit
import SDWebImage

final class MarsAPIService {
    
    enum Link {
        case nasa
        
        var url: URL {
            switch self {
            case .nasa:
                return URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/") ?? URL(fileURLWithPath: "")
            }
        }
    }
    
    enum ErrorData: Error {
        case invalidData
        case InvalidResponse
        case message(_ error: Error)
    }
    
    init() {}
    
    static let shared = MarsAPIService()
    
    weak var queryDelegate: SendQueryDelegate?
    
    func fetchRoverData(completion: @escaping(Result<MarsRoverResponseModel, Error>) -> Void) {
        print("start fetching")
        
        let roverNameQuery = queryDelegate?.roverQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let cameraNameQuery = queryDelegate?.cameraQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let dateQuery = queryDelegate?.dateQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var fullURL = String()
        
        switch (roverNameQuery, cameraNameQuery, dateQuery) {
        case (nil, nil, nil):
            fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(Date())&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
        case (nil, nil, let date?):
            fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
        case (nil, let cameraName?, nil):
            if cameraName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(Date())&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(Date())&camera=\(cameraName)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        case (let roverName?, nil, nil):
            if roverName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(Date())&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else {
                fullURL = "\(Link.nasa.url)\(roverName)/photos?earth_date=\(Date())&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        case (let roverName?, let cameraName?, nil):
            if roverName == "All", cameraName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(Date())&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else {
                fullURL = "\(Link.nasa.url)\(roverName)/photos?earth_date=\(Date())&camera=\(cameraName)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        case (let roverName?, nil, let date?):
            if roverName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else {
                fullURL = "\(Link.nasa.url)\(roverName)/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        case (nil, let cameraName?, let date?):
            print("nil, let cameraName?, let date?")
            if cameraName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&camera=\(cameraName)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        case (let roverName?, let cameraName?, let date?):
            if roverName != "All" && cameraName != "All" {
                fullURL = "\(Link.nasa.url)\(roverName)/photos?earth_date=\(date)&camera=\(cameraName)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else if roverName == "All", cameraName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else if cameraName == "All" {
                fullURL = "\(Link.nasa.url)\(roverName)/photos?earth_date=\(date)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            } else if roverName == "All" {
                fullURL = "\(Link.nasa.url)curiosity/photos?earth_date=\(date)&camera=\(cameraName)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"
            }
        }

        AF.request(fullURL)
            .validate()
            .responseDecodable(of: MarsRoverResponseModel.self) { response in
                print("Status code: \(String(describing: response.response?.statusCode))")
                
                if response.error != nil {
                    print("Error: \(String(describing: response.error))")
                } else {
                    guard let decodedQuery = response.value else { return }
                    completion(.success(decodedQuery))
                    
                    guard let error = response.error else { return }
                    completion(.failure(ErrorData.message(error)))
                }
            }
    }

    func getImageFromUrl(_ imageURL: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(
            with: imageURL,
            options: [.progressiveLoad, .continueInBackground],
            progress: nil,
            completed: { (image, _, _, cacheType, _, _) in
                if let image = image {
                    completion(image)
                } else {
                    AF.request(imageURL).response { response in
                        switch response.result {
                        case .success(_):
                            guard let imageData = response.data else {
                                completion(nil)
                                return
                            }
                            let downloadedImage = UIImage(data: imageData)
                            completion(downloadedImage)
                            
                            if let downloadedImage = downloadedImage {
                                SDImageCache.shared.store(downloadedImage, forKey: imageURL.absoluteString, completion: nil)
                            }
                            
                        case .failure(let error):
                            print("Error loading image: \(error)")
                            completion(nil)
                        }
                    }
                }
            }
        )
    }
}

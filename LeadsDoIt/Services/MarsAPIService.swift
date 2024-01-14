//
//  MarsAPIService.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 12.01.2024.
//

import Foundation
import Alamofire
import UIKit

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
        
        guard let roverNameQuery = queryDelegate?.roverQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let cameraNameQuery = queryDelegate?.cameraQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let dateQuery = queryDelegate?.dateQueryDelegate?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        
        let fullURL = "\(Link.nasa.url)\(roverNameQuery)/photos?earth_date=\(dateQuery)&camera=\(cameraNameQuery)&api_key=6nPtiIfSFRBDNEL7z3wcXML171RLegjYZeIATasd"

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
        AF.request(imageURL).response { response in
            switch response.result {
            case .success(_):
                guard let imageData = response.data else {
                    completion(nil)
                    return
                }
                let image = UIImage(data: imageData)
                completion(image)
            case .failure(let error):
                print("Error loading image: \(error)")
                completion(nil)
            }
        }
    }
}

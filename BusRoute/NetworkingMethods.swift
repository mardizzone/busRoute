//
//  NetworkingMethods.swift
//  BusRoute
//
//  Created by Michael Ardizzone on 12/29/17.
//  Copyright © 2017 Michael Ardizzone. All rights reserved.
//
import Foundation

class Networking {
    class func getAllBusRoutes(completion: @escaping ([Route]) -> ()) {
        let decoder = JSONDecoder()
        let urlString = "http://www.mocky.io/v2/5a0b474a3200004e08e963e5"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let busRouteDataFromServer = data else { return }
            do {
                let allBusRoutes = try decoder.decode([Route].self, from: busRouteDataFromServer)
                completion(allBusRoutes)
            } catch {
                print(error)
            }
        }.resume()
    }
}

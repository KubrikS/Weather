//
//  Service.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit
import CoreLocation

class NetworkingService {
    public func fetch<T: Decodable>(with request: URLRequest,
                                    decoder: JSONDecoder = JSONDecoder(),
                                    completion: @escaping (Result<T, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(FetchError.noHTTPResponse))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(FetchError.unacceptableStatusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure(FetchError.noDataReceived))
                return
            }
            
            do {
                let object = try decoder.decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private enum FetchError: Error {
        case noHTTPResponse
        case noDataReceived
        case unacceptableStatusCode
    }
}

protocol WeatherSource {
    var urlRequest: URLRequest? { get }
}

struct CoordinateWeatherSource: WeatherSource {
    let coordinate: CLLocationCoordinate2D
    var url: URL {
        return URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&units=metric&appid=7a0ff9137db17563fb75c322ec42dc11")!
    }
    var urlRequest: URLRequest? {
        return URLRequest(url: url)
    }
}

struct NameWeatherSource: WeatherSource {
    var name: String
    var url: URL {
        let city = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=7a0ff9137db17563fb75c322ec42dc11")!
    }
    
    var urlRequest: URLRequest? {
        return URLRequest(url: url)
    }
}

struct NameWeatherFiveDaySource: WeatherSource {
    var name: String
    var url: URL {
        let city = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://api.openweathermap.org/data/2.5/forecast?q=\(city)&units=metric&appid=7a0ff9137db17563fb75c322ec42dc11")!
    }
    var urlRequest: URLRequest? {
        return URLRequest(url: url)
    }
}


struct FetchWeather {
    let networkingService = NetworkingService()
    
    func fetchCurrentWeather(for source: WeatherSource, completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void) {
        let request = source
        networkingService.fetch(with: request.urlRequest!, completion: completion)
    }
    
    func fetchForecastWeather(for source: WeatherSource, completion: @escaping (Result<ForecastModel, Error>) -> Void) {
        let request = source
        networkingService.fetch(with: request.urlRequest!, completion: completion)
    }
    
    func fetchCurrentWeather(for city: String, completion: @escaping (CurrentWeatherModel) -> Void) {
        fetchCurrentWeather(for: NameWeatherSource(name: city), completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let weather = CurrentWeatherModel(name: response.name,
                                                      dt: response.dt,
                                                      main: response.main,
                                                      weather: response.weather,
                                                      wind: response.wind,
                                                      coord: response.coord,
                                                      sys: response.sys,
                                                      timezone: response.timezone,
                                                      cod: response.cod)
                    completion(weather)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func fetchForecastWeather(for city: String, completion: @escaping (ForecastModel) -> Void) {
        fetchForecastWeather(for: NameWeatherFiveDaySource(name: city), completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let filterdResponse = response.list.filter({ unixConvertor(unixTime: Double($0.dt), type: .time) == "15:00" })
                    let weather = ForecastModel(list: filterdResponse)
                    completion(weather)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func fetchCurrentWeather(for coordinate: CLLocationCoordinate2D, completion: @escaping (CurrentWeatherModel) -> Void) {
        fetchCurrentWeather(for: CoordinateWeatherSource(coordinate: coordinate), completion: { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let weather = CurrentWeatherModel(name: response.name,
                                                      dt: response.dt,
                                                      main: response.main,
                                                      weather: response.weather,
                                                      wind: response.wind,
                                                      coord: response.coord,
                                                      sys: response.sys,
                                                      timezone: response.timezone,
                                                      cod: response.cod)
                    completion(weather)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
}

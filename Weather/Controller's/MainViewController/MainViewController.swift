//
//  ViewController.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit
import CoreLocation
import CoreData

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

protocol FavouriteDelegate: AnyObject {
    func mainWeatherUpdate(for city: String)
}

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var settingsFavouriteButton: UIButton!
    private lazy var coreDataStack = CoreDataStack(modelName: "FavouriteCity")
    private var locationManager = CLLocationManager()
    private var locationCity: CurrentWeatherModel?
    private let network = FetchWeather()
    var current: CurrentWeatherModel?
    var forecast: ForecastModel?
    
    @IBAction func transitionToSearch(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "searchSegue", sender: nil)
    }
    
    @IBAction func transitionToFavourite(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "favouriteSegue", sender: nil)
    }
    
    @IBAction func addFavouriteButton(_ sender: UIButton) {
        coreDataMethods(.addNewCity)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        navigationController!.navigationBar.shadowImage = UIImage()
        
        setSettingsLocationManager()
        coreDataMethods(.updateToNewData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coreDataMethods(.checkCities)
    }
    
    @objc private func updateData() {
        if let city = current?.name {
            fetchCurrentWeather(with: city)
        }
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - TableView Delegate & DataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        default: return forecast?.list.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 300
        case 1: return 100
        default: return 80
        }
    }
    
    private func configureCell(_ indexPath: IndexPath) -> UITableViewCell {
        // Current temperature
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currentCell", for: indexPath) as! CurrentTempCell
            cell.cityLabel.text = current?.name ?? "City"
            cell.icon.image = setIcon(condition: current?.weather[indexPath.row].main ?? "Clear")
            cell.desriptionLabel.text = current?.weather[indexPath.row].description ?? "Clear sky"
            cell.tempLabel.text = "\(Int(current?.main.temp ?? 0))°"
            cell.feelsLabel.text = "Feel's like: \(Int(current?.main.feelsLike ?? 0))°"
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            coreDataMethods(.checkCities)
            return cell
        }
        // Conditions weather
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "conditionCell", for: indexPath) as! ConditionCell
            let sunrise = unixConvertor(unixTime: Double(current?.sys.sunrise ?? 0), timezone: current?.timezone ?? 0, type: .timeWithTimezone)
            let sunset = unixConvertor(unixTime: Double(current?.sys.sunset ?? 0), timezone: current?.timezone ?? 0, type: .timeWithTimezone)
            cell.sunriseLabel.text = sunrise
            cell.windLabel.text = "\(Int(current?.wind.speed ?? 0))m/s"
            cell.humidityLabel.text = "\(Int(current?.main.humidity ?? 0))%"
            cell.pressureLabel.text = "\(convertToMercury(current?.main.pressure ?? 0))mm"
            cell.sunsetLabel.text = sunset
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        }
        
        // Forecast for 5 day's
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell
        let date = unixConvertor(unixTime: Double(forecast?.list[indexPath.row].dt ?? 0), type: .date)
        let day = unixConvertor(unixTime: Double(forecast?.list[indexPath.row].dt ?? 0), type: .weekDay)
        
        cell.dateLabel.text = date
        cell.daylabel.text = day
        cell.icon.image = setIcon(condition: (forecast?.list[indexPath.row].weather[0].main)!)
        cell.tempLabel.text = "\(Int(forecast?.list[indexPath.row].main.temp ?? 0))°"
        
        return cell
    }
}


// MARK: - Location Manager
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if current == nil {
            fetchCurrentWeather(with: location.coordinate)
        }
    }
    
    private func setSettingsLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("AuthorizedWhenInUse")
        case .denied:
            let alertController = UIAlertController(title: "Location not found",
                                                    message: "Please, check geolocation settings or find city in search!",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        case .notDetermined:
            locationManager.startUpdatingLocation()
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        default:
            print("Authorized")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - Fetch method current and forecast weather
extension MainViewController {
    private func fetchCurrentWeather(with coordinate: CLLocationCoordinate2D) {
        network.fetchCurrentWeather(for: coordinate, completion: { result in
            self.current = result
            self.locationCity = result
            self.forecastWeather(for: result.name)
        })
    }
    
    private func fetchCurrentWeather(with nameCity: String) {
        network.fetchCurrentWeather(for: nameCity, completion: { result in
            self.current = result
            self.forecastWeather(for: result.name)
        })
    }
    
    private func forecastWeather(for city: String) {
        network.fetchForecastWeather(for: city, completion: { result in
            self.forecast = result
            self.tableView.reloadData()
        })
    }
}


// MARK: - Favourite City Delegate
extension MainViewController: FavouriteDelegate {
    func mainWeatherUpdate(for city: String) {
        fetchCurrentWeather(with: city)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let favouriteVC = segue.destination as? FavouriteViewController {
            favouriteVC.delegate = self
            favouriteVC.locationCity = locationCity
        }
        
        if let searchVC = segue.destination as? SearchViewController {
            searchVC.delegate = self
        }
    }
}

// MARK: - Add and check favourite city in CoreData
// .addNewCity - Add new city in CoreData
// .checkCities - check existing cities in CoreData
// .updateToNewData - update CoreData to the new data (for favourite cities)

extension MainViewController {
    func coreDataMethods(_ type: MethodsCoreData) {
        let request = NSFetchRequest<City>(entityName: "City")
        guard var addedCities = (try? coreDataStack.managedContext.fetch(request)) else { return }
        
        switch type {
        case .addNewCity:
            if current?.name != nil {
                if !addedCities.contains(where: { $0.name == current?.name }) {
                    let city = City(context: coreDataStack.managedContext)
                    if let current = current {
                        city.name = current.name
                        city.temp = current.main.temp
                        addedCities.append(city)
                        settingsFavouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        settingsFavouriteButton.imageView?.tintColor = .systemOrange
                    }
                } else {
                    for city in addedCities {
                        if city.name == current?.name {
                            coreDataStack.managedContext.delete(city)
                            settingsFavouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                            settingsFavouriteButton.imageView?.tintColor = .darkGray
                        }
                    }
                }
            }
            coreDataStack.saveContext()
        case .checkCities:
            if !addedCities.contains(where: { $0.name == current?.name}) {
                settingsFavouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                settingsFavouriteButton.imageView?.tintColor = .darkGray
            } else {
                settingsFavouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                settingsFavouriteButton.imageView?.tintColor = .systemOrange
            }
        case .updateToNewData:
            for city in addedCities {
                network.fetchCurrentWeather(for: NameWeatherSource(name: city.name!), completion: { result in
                    switch result {
                    case .success(let response):
                        city.temp = response.main.temp
                        self.coreDataStack.saveContext()
                    case .failure(let error):
                        print("Error in \(#function) - \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    enum MethodsCoreData {
        case addNewCity
        case checkCities
        case updateToNewData
    }
}

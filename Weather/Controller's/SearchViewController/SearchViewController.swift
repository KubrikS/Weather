//
//  SearchViewController.swift
//  Weather
//
//  Created by Stanislav on 01.11.2020.
//

import UIKit
import Network

class SearchViewController: UIViewController {    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchController: UISearchBar!
//    @IBOutlet var searchView: UIView!
    private let network = FetchWeather()
    private var cities = [CurrentWeatherModel]()
    weak var delegate: FavouriteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSettingsTableView()
        setSettingsSearchController()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    private func setSettingsTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
    }
    
    private func setSettingsSearchController() {
        searchController.delegate = self
        searchController.becomeFirstResponder()
        searchController.layer.cornerRadius = 15
    }
}

// MARK: - TableView delegate & datasource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cities.count > 0 {
            searchController.layer.cornerRadius = 0
        }
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.cityLabel.text = cities[indexPath.row].name
        cell.tempLabel.text = "\(Int(cities[indexPath.row].main.temp))°"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.mainWeatherUpdate(for: cities[indexPath.row].name)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return searchController.frame.height
    }
    
}

// MARK: - Search Cities
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text else { return }
        if city.count == 0 {
            searchController.placeholder = "Enter your city"
            errorShakeSearch()
        } else {
            fetchingWeather(for: city)
        }
    }
    
    private func fetchingWeather(for city: String) {
        network.fetchCurrentWeather(for: NameWeatherSource(name: city), completion: { result in
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
                    self.cities.insert(weather, at: 0)
                    if self.cities.count > 1 {
                        self.cities.removeLast()
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorShakeSearch()
                    self.searchController.text = ""
                    self.searchController.placeholder = " '\(city)' not found"
                }
                print(error.localizedDescription)
            }
        })
    }
    
    private func errorShakeSearch() {
        let shakeState = CGRect(x: 15, y: 0, width: self.view.bounds.width,
                            height: self.searchController.bounds.height)
        let normalState = CGRect(x: 0, y: 0, width: self.view.bounds.width,
                                 height: self.searchController.bounds.height)
        
        self.searchController.frame = shakeState
        self.tableView.frame = shakeState
        
        UIView.animate(withDuration: 1, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 0.4,
                       options: [], animations: {
                        self.searchController.frame = normalState
                        self.tableView.frame = normalState
                       })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Transitioning delegate
extension SearchViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationPresented(timeInterval: 0.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationPresented(timeInterval: 0.5, animationType: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting ?? source)
    }
}

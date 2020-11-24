//
//  FavouriteViewController.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit
import CoreData

class FavouriteViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var locationCity: CurrentWeatherModel?
    weak var delegate: FavouriteDelegate?
    
    // MARK: - CoreDataStack and FetchedResultsController settings
    private lazy var coreDataStack = CoreDataStack(modelName: "FavouriteCity")
    private lazy var citiesFetchRequest = NSFetchRequest<City>(entityName: "City")
    private lazy var fetchedResultsController: NSFetchedResultsController<City> = {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest,
                                                                   managedObjectContext: coreDataStack.managedContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
}

// MARK: - TableView Delegate and DataSource
extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default:
            guard let sections = fetchedResultsController.sections?[0] else { return 0 }
            return sections.numberOfObjects
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath)
    }
    
    private func configureCell(_ indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationCell
            cell.cityLabel.text = locationCity?.name ?? "Location not found"
            cell.descriptionLabal.text = locationCity?.weather.first?.description.localizedCapitalized
            cell.tempLabel.text = "\(Int(locationCity?.main.temp ?? 0))°"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! FavouriteCell
            let city = fetchedResultsController.fetchedObjects![indexPath.row]
            cell.cityLabel.text = city.name
            cell.descriptionLabel.text = city.descrip
            cell.tempLabel.text = "\(Int(city.temp))°"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        default: return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let city = locationCity?.name {
                delegate?.mainWeatherUpdate(for: city)
            }
            navigationController?.popViewController(animated: true)
        case 1:
            let city = fetchedResultsController.fetchedObjects![indexPath.row]
            delegate?.mainWeatherUpdate(for: city.name ?? "")
            navigationController?.popViewController(animated: true)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (_, _, _) in
            if indexPath.section == 1 {
                let newIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
                let city = self.fetchedResultsController.fetchedObjects?[newIndexPath.row]
                self.coreDataStack.managedContext.delete(city!)
                self.coreDataStack.saveContext()
            }
        }
        
        delete.image = UIImage(named: "delete")
        delete.backgroundColor = UIColor(red: 245, green: 248, blue: 253, alpha: 0)
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current Location" : "Favourite Cities"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 80 : 90
    }
}

// MARK: - FetchedResultsControllerDelegate
extension FavouriteViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? FavouriteCell {
                let city = fetchedResultsController.object(at: indexPath)
                cell.cityLabel.text = city.name?.localizedCapitalized
                cell.tempLabel.text = "\(city.temp) C"
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                let newIndexPath = IndexPath(row: indexPath.row, section: indexPath.section + 1)
                tableView.deleteRows(at: [newIndexPath], with: .automatic)
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

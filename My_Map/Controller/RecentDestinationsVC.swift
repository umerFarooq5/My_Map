//
//  ResultsVC.swift
//  My_Map
//
//  Created by umer malik on 30/10/2020.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

protocol selectDestinationProtocol {
    func sendBackDestination(destination: String)
}


class RecentDestinationsVC: UIViewController {
    

    let destinationTable = UITableView()
    var selectDestinationDelegate: selectDestinationProtocol!
    
    var searchedPlaces = [DataModel]()
    var sortedByDatePlaces = [DataModel]()

    func loadLocations() {
        let request: NSFetchRequest<DataModel> = DataModel.fetchRequest()
        do {
            searchedPlaces = try  CONTEXT.fetch(request)
            sortedByDatePlaces =   searchedPlaces.sorted {$0.date! > $1.date!  }
        } catch {
            print("error loading locations")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        loadLocations()
    }
    
    
    func setDate(searchDate: Date, com: @escaping(String, String) -> ()) {
        let time = DateFormatter.localizedString(from: searchDate, dateStyle: .none, timeStyle: .short)
        let date = DateFormatter.localizedString(from: searchDate, dateStyle: .medium, timeStyle: .none)
        com(time, date)
    }
    
    
    func constraints() {
        configureNavigationBar(withTitle: "recent searches", prefersLargeTitles: false)
        
        destinationTable.register(DestinationCell.self, forCellReuseIdentifier: "cell")
        destinationTable.delegate = self
        destinationTable.dataSource = self
        destinationTable.separatorStyle = .none
        view.addSubview(destinationTable)
        destinationTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    
    
    
}



extension RecentDestinationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedByDatePlaces.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DestinationCell
        cell.dataModel =   sortedByDatePlaces[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDestinationDelegate.sendBackDestination(destination: searchedPlaces[indexPath.row].destination!)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            do {
                CONTEXT.delete(sortedByDatePlaces[indexPath.row])
                sortedByDatePlaces.remove(at: indexPath.row)
                try CONTEXT.save()
            } catch {
                print("error deleting locations")
            }
            destinationTable.reloadData()
        }
    }
    
    
    
}

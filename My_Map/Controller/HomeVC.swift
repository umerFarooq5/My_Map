//
//  ViewController.swift
//  My_Map
//
//  Created by umer malik on 29/10/2020.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

let CONTEXT = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class HomeVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate  {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var routeDirections = [String]()

    
    let goButton : UIButton = {
        let button = UIButton()
        button.setTitle("go", for: .normal)
        button.titleLabel?.font = UIFont(name: "chalkDuster", size: 20)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleGo), for: .touchUpInside)
        return button
    }()
    
    
    let destinationTxt  : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "destination"
        textfield.textAlignment = .center
        textfield.backgroundColor = .white
        textfield.layer.cornerRadius = 5
        return textfield
    }()
    
    
    let estTimeLbl : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        return lbl
    }()
    
    let detailBtn : UIButton = {
        let button = UIButton()
        button.setTitle("route", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleDetailBtn), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        islocationServicesEnabled()
        
        mapView.delegate = self
        locationManager.delegate = self
        
    }
    
    
    func islocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            checkAuthorisationStatus()
        }
    }
    
    
    func checkAuthorisationStatus()  {
        // just to check if we have authorisation from the user to get the location and what to do in each case
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse:
            showLocation()
        case .authorizedAlways:
            showLocation()
        case .denied:
            showAlert(textToShow: "to find a destination you will need to enable location services in your settings")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    
    // current users location
    func showLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    // get the address that you wish to go to and use the Geocoder to change it from string to longitude and latitude values
    func getAddressTo(address: String) {
        let geoder = CLGeocoder()
        geoder.geocodeAddressString(address) { (placemark, error) in
            guard let placemark = placemark, let location = placemark.first?.location else {return}
            self.prepareRequest(destination: location.coordinate)
        }
    }
    
    
    @objc func handleGo() {
    
        guard let destinationAddress = destinationTxt.text else { return }
        if !destinationAddress.isEmpty {
        getAddressTo(address: destinationAddress)
        self.view.endEditing(true)
        saveLocation()
        }
        
    }
    
    
    func prepareRequest(destination: CLLocationCoordinate2D) {
        // get current location
        guard let currentLocation = locationManager.location?.coordinate else {return}
        // set current location as MKPlaceMark
        let startPlacemark = MKPlacemark(coordinate: currentLocation)
        // set the destination as MKPlaceMark
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let request = MKDirections.Request()
        // the start location on the map
        request.source = MKMapItem(placemark: startPlacemark)
        // the end location shown on the map
        request.destination = MKMapItem(placemark: destinationPlacemark)
        // you can pick what type of transport you will be using
        request.transportType = .automobile
        
        dealWithRequest(request: request)
    }
    
    
    
    func dealWithRequest( request: MKDirections.Request) {
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let response = response else { return }
            // remove the overlay lines of any previous route
            mapView.removeOverlays(mapView.overlays)
            
            for route in response.routes {

                // estimated travel route comes back in seconds convert to hours and minutes to show on our label
                convertSecondsToHoursMins(seconds: Int(route.expectedTravelTime))
               
                // add an opening line to show the route on the map
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                routeInText(steps: route)
            }
        }
        
    }
    
    
    func routeInText(steps: MKRoute) {
        // this will print out the route in text
        for steps in steps.steps {
            let step = steps.instructions
            routeDirections.append(step.description)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        // only update the current location if the user lose more than 5 metres
        locationManager.distanceFilter = 5
        
    }
    
    
    @objc func handleNavBtn() {
        let recentDestinationsVC = RecentDestinationsVC()
        recentDestinationsVC.selectDestinationDelegate = self
        navigationController?.pushViewController(recentDestinationsVC, animated: true)
    }
    
    
    @objc func handleDetailBtn() {
        let journeyDetailVC = JourneyDetailVC()
        
        journeyDetailVC.destination = routeDirections
        journeyDetailVC.navigationItem.title = destinationTxt.text
        
        navigationController?.pushViewController(journeyDetailVC, animated: true)
    }
    
    
    func convertSecondsToHoursMins (seconds: Int)  {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        var hourText = ""
        var minText = ""
        hourText = hours == 1 ? "hour" : "hours"
        minText = minutes <= 9 ? "min" : "mins"
        self.estTimeLbl.text =  ("ETA  \(hours)  \(hourText)  \(minutes) \(minText)")
    }
    
    
}


extension HomeVC: selectDestinationProtocol  {
    
    func sendBackDestination(destination: String) {
        // this is the protocol function that is called when a user taps on a table view cell in the recentDestinationsVC
        getAddressTo(address: destination)
        destinationTxt.text = destination
        navigationController?.popViewController(animated: true)
    }
    
    
    func saveLocation() {
        guard let destination = destinationTxt.text else {return}
        let recentPlaces = DataModel(context: CONTEXT)
        let date = Date()
        recentPlaces.date = date
        recentPlaces.destination = destination

        do {
            try CONTEXT.save()
        } catch {
            print("successfully saved contact")
        }
    }
    
}



extension HomeVC {
    
    func constraints() {
        
        configureNavigationBar(withTitle: "maps", prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNavBtn))
        
        view.addSubview(mapView)
        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor , bottom: view.bottomAnchor, right: view.rightAnchor)
        
        mapView.addSubview(destinationTxt)
        destinationTxt.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, height: 30)
        
        mapView.addSubview(goButton)
        goButton.anchor(top: destinationTxt.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10, width: 50, height: 50)
        
        mapView.addSubview(estTimeLbl)
        estTimeLbl.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 8, paddingRight: 8, width: 200, height: 30)
        
        mapView.addSubview(detailBtn)
        detailBtn.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 8, paddingBottom: 20, width: 80, height: 40)

        
        
    }
    
    
    
    
}

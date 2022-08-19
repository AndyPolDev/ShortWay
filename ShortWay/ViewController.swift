import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAddressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAddress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let navigateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "navigate"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reload"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setConstraints()
        
        addAddressButton.addTarget(self, action: #selector(addAddressButtonPressed), for: .touchUpInside)
        navigateButton.addTarget(self, action: #selector(navigateButtonPressed), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
    }
    
    
    @objc func addAddressButtonPressed() {
        alertAddAddress(title: "Добавить", placeholder: "Введите адрес") { (text) in
            self.setupPlacemark(addressPlace: text)
        }
    }
    
    @objc func navigateButtonPressed() {
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func resetButtonPressed() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        navigateButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(addressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                self.alertError(title: "Ошибка", message: "Попробуйте ввести адрес еще раз")
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation  = MKPointAnnotation()
            annotation.title = addressPlace
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.annotationsArray.append(annotation)
            
            if self.annotationsArray.count > 2 {
                self.navigateButton.isHidden = false
                self.resetButton.isHidden = false
            }
            
            self.mapView.showAnnotations(self.annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (responce, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Невозможно построить маршрут")
                return
            }
            
            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}

extension ViewController {
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAddressButton)
        NSLayoutConstraint.activate([
            addAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAddressButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 30),
            addAddressButton.heightAnchor.constraint(equalToConstant: 55),
            addAddressButton.widthAnchor.constraint(equalToConstant: 55)
        ])
        
        mapView.addSubview(navigateButton)
        NSLayoutConstraint.activate([
            navigateButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            navigateButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            navigateButton.heightAnchor.constraint(equalToConstant: 55),
            navigateButton.widthAnchor.constraint(equalToConstant: 55)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            resetButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 30),
            resetButton.heightAnchor.constraint(equalToConstant: 55),
            resetButton.widthAnchor.constraint(equalToConstant: 55)
        ])
    }
}


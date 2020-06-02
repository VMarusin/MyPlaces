//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 11.05.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import MapKit //отвечает за карту
import CoreLocation //отвечает за позиционирование на карте


protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate:  MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier" //создаем свойство класса с идентификаторомannotationIndentifier
    var incomeSegueIdentifier = "" //идентификатор segue
    
    var previousLocation: CLLocation?  {//первоначальное местоположение пользователя
        //после того как мы построим маршрут нам нужно постоянно фокусировать карту на пользователе
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                and: previousLocation) { (currentLocation) in
                    
                    self.previousLocation = currentLocation
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }
            }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = "" //по умолчанию задаем пустой адрес нашего местоположения
        mapView.delegate = self //подписываемся под протокол т.е назначаем делекатом сам класс
        setupMapView()
    }
    
    //кнопка для центрирования местоположения пользователя
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text) // при нажатии кнопки Done получаем адрес
        dismiss(animated: true) //закрываем VC
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
        
}
        private func setupMapView() {

            goButton.isHidden = true

            mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
                mapManager.locationManager.delegate = self
            }

            if incomeSegueIdentifier == "showPlace" {
                mapManager.setupPlacemark(place: place, mapView: mapView)
                mapPinImage.isHidden = true //скрываем маркер если мы перешли по segue showPlace
                addressLabel.isHidden = true
                doneButton.isHidden = true
                goButton.isHidden = false
        }
    }

}

//подписываемся под расширение протокола MKMapViewDelegate для реализации аннтоаций карты
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //убеждаемся в том что данный обьект не является аннотацией определяющей текущее положение пользователя
        guard !(annotation is MKUserLocation) else { return nil }//если annotation является MKUserLocation то не создаем ни какой аннтоации
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView //приводим тип обьекта AnnotationView к типу MKPinAnnotationView для отображения маркера булавки
        
        if annotationView == nil {//если на карте не окажется ни одного представления с аннтоацией которое мы могли бы переиспользовать то инициализируем этот обьект новым значение присовим ему обьект класса MKAnnotationView
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true //отображаем аннотацию ввиде банера
        }
        
        if let imageData = place.imageData { //принудительно извлекаме опционал imageData
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) //размер изображения заведения на банере
            imageView.layer.cornerRadius = 10 //сглаживаем углы изображения
            imageView.clipsToBounds = true //обрезам изображение по границам imageView
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView // отображаем imageView на баннере
        }
        
        return annotationView
    }
     
    //метод протокола будет выязыватся каждый раз при смене отображаемого на экране региона и будет отображать адрес
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView) //определяем текущие координаты по центру отображаемой области
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { //позиционируем карту по местоположению пользователя с задержкуой 3 сек
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode() //освобождаем ресурсы связанные с геокодированием делаем отмену отложенного запроса
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in //преобразовываем адрес в координаты
            if let error = error {  //проверяем на ошибки
                print(error)
                return
            }
            guard let placemarks = placemarks else { return } //извлекаем массив меток
            let placemark = placemarks.first
            let streenName = placemark?.thoroughfare//извлекаме улицу
            let buildNumber = placemark?.subThoroughfare//извлекаме улицу
            
            DispatchQueue.main.async { //обновляем данные асинхронно
                if streenName != nil && buildNumber != nil  {
                    self.addressLabel.text = "\(streenName!), \(buildNumber!)" //передаем текущий адрес в лейбл
                } else if streenName != nil  { //если есть только улица то передаем ее
                    self.addressLabel.text = "\(streenName!)" //передаем текущий адрес в лейбл
                } else {
                    self.addressLabel.text = "" // если адреса нет то передаем пустую строку
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline) //рендерим наложение маршрутов
        renderer.strokeColor = .blue //цвет маршрута
        
        return renderer
    }
}

//отслеживание в реальном времени изменение статуса разрешение использования геолокации
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
         mapManager.checkLocationAuthorization(mapView: mapView,
                                               segueIdentifier: incomeSegueIdentifier)//при изменении статуса запускаем метод проверяющий текущий статус
    }
}


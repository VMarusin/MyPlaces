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

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier" //создаем свойство класса с идентификаторомannotationIndentifier
    let locationManader = CLLocationManager() //экземпляр ответчат за настройку службами геолокации
    let regionInMaters = 10_000.00
    var incomeSegueIdentifier = "" //идентификатор segue
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adressLabel.text = "" //по умолчанию задаем пустой адрес нашего местоположения
        mapView.delegate = self //подписываемся под протокол т.е назначаем делекатом сам класс
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    
    //кнопка для центрирования местоположения пользователя
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true //скрываем маркер если мы перешли по segue showPlace
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    //маркер отображения обьекта на карте
    private func setupPlacemark() {
        guard let  location = place.location else { return } //извлекаем адрес заведения
        
        //отвечает за преобразование геокординат и геоназваний в удобоваримый пользовательский вид
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in //возвращаем массив меток соответствующий перданному адресу
            if let error = error { //проверяем не содержит ли обьект Error каких либо данных
                print(error)
                return
            }
            //если ошибки нет то извлекаем опционал из обьекта placemarks
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first //получаем метку на карте
            let annotation = MKPointAnnotation() //описывет точку на карте
            annotation.title = self.place.name //определяем в качеств заголовка аннтации название места
            annotation.subtitle = self.place.type //подзоголовок аннотоации
            
            //привязываем аннтоация к конкретной точке на карте в соответствии с положением маркера
            
            guard let placemarkLocation = placemark?.location else { return }//определяем местоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate//привязваем аннотацию к точке на карте
            
            //задаем видимую область карты что мы на ней видны были всесозданные аннтоации
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true) //выделяем аннтацию
        }
    }
    // проверяем включены ли у нас соответствующие службы геолокации
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager() //если службы геолокации доступны
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Ваша локация недоступна",
                    message: "Включите службу геолокации: Настройки -> MyPlaces -> Вкл геолокацию"
                )
            }
        }
    }
    
    //метод определяет точность определения геолокации
    private func setupLocationManager() {
        locationManader.delegate = self //определяем делегата
        locationManader.desiredAccuracy = kCLLocationAccuracyBest //выставляем максимальную точность
    }
    
    //метод определяющий статус разрешения определения геолокации
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() { //всего 5 статусов, проверяим их все
        case .authorizedWhenInUse: //приложению разрешено определять геолокацию в момент его использования
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" { showUserLocation() }
            print("Разрешение на геолокацию дано")
            break
        case .denied: //приложению запрещено использовать службу геолокации (отключены в настройках)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Ваша локация недоступна",
                    message: "Включите службу геолокации: Настройки -> MyPlaces -> Вкл геолокацию"
                )
            }
            print("Запрещена геолокация")
            break
        case .notDetermined: //статус не определен (пользователь еще не сделал выбор вкл или выкл)
            locationManader.requestWhenInUseAuthorization()
            print("Пользователь еще не выбрал геолокацию")
            break
        case .restricted: //если приложение не авторизовано для исползования служб геолокации
            //здесь будет алерт контроллер с предупрежением
            print("Приложение не авторизаовано на геолокацию")
            break
        case .authorizedAlways: //приложению разрешено определять геолокацию постоянно
            print("Геолокация включана постоаянно")
            break
        @unknown default: //срабатывает если в будущем в перечисленнии появятся еще варианты кейса
            print("Новый кейс доступен")
        }
    }
    
    private func showUserLocation() {
        if let location = locationManader.location?.coordinate {//проверяем координаты пользователя
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMaters, longitudinalMeters: regionInMaters) //определяем регион для позиционирования карты
            mapView.setRegion(region, animated: true) //устанавливаем регион отображения на экране
        }
    }
    //метод AlertController для карты
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
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
        let center = getCenterLocation(for: mapView) //определяем текущие координаты по центру отображаемой области
        let geocoder = CLGeocoder()
        
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
                    self.adressLabel.text = "\(streenName!), \(buildNumber!)" //передаем текущий адрес в лейбл
                } else if streenName != nil  { //если есть только улица то передаем ее
                    self.adressLabel.text = "\(streenName!)" //передаем текущий адрес в лейбл
                } else {
                    self.adressLabel.text = "" // если адреса нет то передаем пустую строку
                }
            }
        }
    }
    
    
    //метод определения координат под маркером
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude //получаем широту
        let longitude = mapView.centerCoordinate.longitude //получаем долготу
        
        return CLLocation(latitude: latitude, longitude: longitude) //возвращаем координаты центра
    }
}

//отслеживание в реальном времени изменение статуса разрешение использования геолокации
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization() //при изменении статуса запускаем метод проверяющий текущий статус
    }
}

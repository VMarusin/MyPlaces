//
//  MapManager.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 01.06.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() //экземпляр ответчат за настройку службами геолокации
    
    private let regionInMaters = 1000.00 //радиус отображаемой карты
    private var directionsArray: [MKDirections] = []//массив для хранения маршруштов
    private var placeCoordinate: CLLocationCoordinate2D? //координаты заведения
    
    //маркер отображения обьекта на карте
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name //определяем в качеств заголовка аннтации название места
            annotation.subtitle = place.type //подзоголовок аннотоации
            
            //привязываем аннтоация к конкретной точке на карте в соответствии с положением маркера
            
            guard let placemarkLocation = placemark?.location else { return }//определяем местоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate//привязваем аннотацию к точке на карте
            self.placeCoordinate = placemarkLocation.coordinate //передаем координаты заведения
            
            //задаем видимую область карты что мы на ней видны были всесозданные аннтоации
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true) //выделяем аннтацию
        }
    }
    
    // проверяем включены ли у нас соответствующие службы геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //наилучшая точность определения геопозиции
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Ваша локация недоступна",
                    message: "Включите службу геолокации: Настройки -> MyPlaces -> Вкл геолокацию"
                )
            }
        }
    }
    
    //метод определяющий статус разрешения определения геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() { //всего 5 статусов, проверяим их все
        case .authorizedWhenInUse: //приложению разрешено определять геолокацию в момент его использования
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
            locationManager.requestWhenInUseAuthorization()
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
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {//проверяем координаты пользователя
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMaters, longitudinalMeters: regionInMaters) //определяем регион для позиционирования карты
            mapView.setRegion(region, animated: true) //устанавливаем регион отображения на экране
        }
    }
    
    
    //метод для прокладки маршрута
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        //определям координаты местоположения пользователя
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation() //включаем режим постоянного отслеживания местополжоения пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) //передаем текущие координаты местоположения пользователя в свойство previousLocation

        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destenation is not found")
            return
        }
        
        let directions  = MKDirections(request: request)//если все прошло успешно строим маршрут
        resetMapView(withNew: directions, mapView: mapView) //удаляем старый массив маршрутов
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else  {//извлекаем обработанный маршрут
                self.showAlert(title: "Error", message: "Direction is not avaible")
                return
            }
            //перебераем маршруты
            for route in response.routes { //route содержит маршрут (геометрия ожидаемое время в пути дистанция и тд
                mapView.addOverlay(route.polyline) //накладываем маршруты с геометрией
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) //зона видимости карты
                
                let distance = String(format: "%.1f", route.distance / 1000)//округляем до десятых (км)
                let timeInterval = route.expectedTravelTime//время в пути
                
                print("Расстояние до места\(distance) км")
                print("Время в пути\(timeInterval) сек")
            }
        }
    }
    
    
    //настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)//определяем точку начала маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate) // координаты места назначения
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)// начальная точка маршрута
        request.destination = MKMapItem(placemark: destination) //конкчная точка маршрута
        request.transportType = .automobile//задаем тип транспорта (выбираем автомобиль
        request.requestsAlternateRoutes = true //включет построение нескольких маршрутов если есть альтернатива
        
        return request
    }
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView) //определяем текущие коородинаты центра отображаемой области
        //облновляем координаты только в случае если рассторяние между двумя точками  более 50м тогда будем обновлять текущее местоположение пользователя в сответствии с текущим центром
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    //метод для сбрасывания старых маршрутов
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays) //удаляем старые маршруты
        directionsArray.append(directions) //добавляем маршруты
        let _ = directionsArray.map { $0.cancel() } //проходим по каждому элементу массива и отменяе его
        directionsArray.removeAll() //удаляем все элементы массива
    }
    
    //метод определения координат под маркером
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude //получаем широту
        let longitude = mapView.centerCoordinate.longitude //получаем долготу
        
        return CLLocation(latitude: latitude, longitude: longitude) //возвращаем координаты центра
    }
    //метод AlertController для карты
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds) //определяем окно по границе экрана
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1 //определяем позиционирование окна относительно других окон
        alertWindow.makeKeyAndVisible() //делаем окно ключевым и видимым
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}

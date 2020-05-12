//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 11.05.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier" //создаем свойство класса с идентификаторомannotationIndentifier

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self //подписываемся под протокол т.е назначаем делекатом сам класс
        setupPlacemark()

    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
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
}

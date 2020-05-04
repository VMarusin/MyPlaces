//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 28.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit

//описываем модель ресторана
struct Place {
    
    //все поля опциональны кроме name т.к оно обязательно
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    //временныйы костыль для того что бы заполнить массив модели
    static func getPlaces() -> [Place] {
        var places = [Place]() // обьявим пустой массив в типом Place
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Уфа", type: "Ресторан", image: nil, restaurantImage: place))
        }
        return places
    }
}

//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 28.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import Foundation

//описываем модель
struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
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
            places.append(Place(name: place, location: "Уфа", type: "Ресторан", image: place))
        }
        return places
    }
}

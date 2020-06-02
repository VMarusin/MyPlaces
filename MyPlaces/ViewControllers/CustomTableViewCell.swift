//
//  CastomTableViewCell.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 28.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2 //скругляем края (берем половину от высоты размера imageOfPlace) если нужно скугление от размера ячейки то imageOfPlace cell.frame.size.height / 2
            imageOfPlace.clipsToBounds = true // обрезаем изображение по границам закругления
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false// отключаем возможность выбирать звезды на стартовом экране
        }
    }
}

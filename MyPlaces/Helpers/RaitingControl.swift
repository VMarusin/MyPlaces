//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 10.05.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit

@IBDesignable class RaitingControl: UIStackView { //@IBDesignable отображаем изменения сразу в интерфейс билдере
    
    //MARK:  Properties
    
    var raiting = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var raitingButtons = [UIButton]() //массив рейтинга завеедния
    
    var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {//размер кнопок @IBInspectable выводит в атрибут инспектор настройки для удобства
    
        // позволяет в реальном времени видеть добавление кнопок
        didSet {
            setupButtons()
        }
    }
    var starCount: Int = 5 {//переменная кол-во звезд
    
        didSet {
            setupButtons()
        }
    }
    
    //MARK: инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    
    @objc func raitingButtonTapped(button: UIButton) {
        guard let index = raitingButtons.firstIndex(of: button) else { return } //firstIndex возвращает инекс первого выбранного элемента
        
        //определяем рйтинг в соответствии с выбранной звездой
        let selectedRaiting = index + 1 //присваиваем порядковый номер выбранной звезды
        
        //если номер совпдаает с текущим рейтингом то обнуляем его
        if selectedRaiting == raiting {
            raiting = 0
        } else {
            raiting = selectedRaiting
        }
    }
    
    //MARK: Private Methods
    
    private func setupButtons() {
        
        for button in raitingButtons { //перебираем и удаляем все элементы массива raitingButtons
            removeArrangedSubview(button) // из списка SubView
            button.removeFromSuperview() // из StackView
        }
        
        raitingButtons.removeAll() //очищаем весь массив кнопок
        
        //загрузка картинок звезд. Передаем значение свойств в интерфейс билдер, что бы они там отображались (а то будут просто квадраты)
        let bundle = Bundle(for: type(of: self))// определяем место размещение ресурсов в каталоге Assets и указываем имена файлов звезд
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount { //добавляем через цикл 5 кнопкок рейтинга}
            
            let button = UIButton() //создаем кнопку
            button.setImage(emptyStar, for: .normal) //подставляем вместо кнопки звезду состояник кнопка не нажата
            button.setImage(filledStar, for: .selected) //подставляем вместо кнопки звезду состояник кнопка нажата
            button.setImage(highlightedStar, for: .highlighted) //подсвечиваем звезду при прикосновении
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            
            //Добавляем констрайнты что бы определить размеры звезд
            button.translatesAutoresizingMaskIntoConstraints = false //отключает автоматически сгеренированне констрейнты для кнопки
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true //высота кнопки
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true //ширина кнопки
            
            button.addTarget(self, action: #selector(raitingButtonTapped(button:)), for: .touchUpInside) //добавляем на кнопку реацию нажатия
            
            //Добавляем кнопку в StackView
            addArrangedSubview(button) //добавляет созданную кнопку в список представлений как subview класса RaitingControl
            
            //Добавляем кнопки в массив
            raitingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    //метод отвечает за заполняемость звезд
    private func updateButtonSelectionState() {
        for (index, button) in raitingButtons.enumerated() {
            button.isSelected = index < raiting
        }
    }
}

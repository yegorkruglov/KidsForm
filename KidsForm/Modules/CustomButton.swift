//
//  CustomButton.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class CustomButton: UIButton {
    
    enum Kind {
        case add
        case clear
    }
    
    init(kind: CustomButton.Kind) {
        super.init(frame: .zero)
        setupAs(kind)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    private func setupAs(_ kind: CustomButton.Kind) {
        var configuration = UIButton.Configuration.plain()
        
        configuration.title = kind == .add ? "Добавить ребенка" : "Очистить"
        configuration.baseForegroundColor = kind == .add ? .systemBlue : .systemRed
        configuration.imagePlacement = .leading
        configuration.imagePadding = 16
        configuration.image = kind == .add ? UIImage(systemName: "plus") : nil
        configuration.contentInsets  = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        self.configuration = configuration
        
        layer.borderWidth = 1
        layer.borderColor = kind == .add ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
    }
}

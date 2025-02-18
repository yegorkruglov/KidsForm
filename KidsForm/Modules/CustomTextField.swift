//
//  CustomTextField.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class CustomTextField: UIView {
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()
    
    init(placeHolder: String, keyboardType: UIKeyboardType) {
        super.init(frame: .zero)
        placeholderLabel.text = placeHolder
        textField.keyboardType = keyboardType
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(text: String) {
        textField.text = text
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
        
        [placeholderLabel, textField]
            .forEach { subview in
                subview.translatesAutoresizingMaskIntoConstraints = false
                addSubview(subview)
            }
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            textField.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
        ])
    }
}

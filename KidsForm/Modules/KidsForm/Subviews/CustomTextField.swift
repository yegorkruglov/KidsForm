//
//  CustomTextField.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

protocol CustomTextFieldDelegate: AnyObject {
    func didEndEditing()
}

final class CustomTextField: UIView {
    
    weak var delegate: CustomTextFieldDelegate?
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .preferredFont(forTextStyle: .body)
        textField.delegate = self
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
        layoutIfNeeded()
    }
    
    func getCurrentText() -> String {
        return textField.text ?? String()
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
        
        let vStack = UIStackView(arrangedSubviews: [placeholderLabel, textField])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.distribution = .fillProportionally
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints =  false

        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            
        ])
    }
}

extension CustomTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didEndEditing()
    }
}

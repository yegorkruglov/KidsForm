//
//  CustomTextField.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit
import Combine

final class CustomTextField: UIView {
    
    // MARK: - publishers
    
    private var cancellables = Set<AnyCancellable>()
    private(set) lazy var textPublisher = PassthroughSubject<String, Never>()
    
    // MARK: -  ui elements
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .preferredFont(forTextStyle: .body)
        textField.returnKeyType = .done
        return textField
    }()
    
    // MARK: -  initializers
    
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
    
    // MARK: -  public methods
    
    func configureWith(text: String) {
        textField.text = text
        textField.delegate = self
        layoutIfNeeded()
    }
    
    // MARK: - private methods
    
    private func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
        
        let vStack = UIStackView(arrangedSubviews: [placeholderLabel, textField])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.distribution = .fillProportionally
        vStack.translatesAutoresizingMaskIntoConstraints =  false
        addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension CustomTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }

        textPublisher.send(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

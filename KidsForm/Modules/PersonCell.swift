//
//  PersonCell.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class PersonCell: UICollectionViewCell {
    
    static var ientifier: String { String(describing: Self.self) }
    
    private lazy var nameTextField = CustomTextField(placeHolder: "Имя", keyboardType: .default)
    private lazy var ageTextFiled = CustomTextField(placeHolder: "Возраст", keyboardType: .numberPad)
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        deleteButton.isHidden = false
        nameTextField.configureWith(text: String())
        ageTextFiled.configureWith(text: String())
    }
    
    func configureWith(_ person: Person, deleteButtonIsHidden: Bool) {
        nameTextField.configureWith(text: person.name)
        ageTextFiled.configureWith(text: person.age)
        deleteButton.isHidden = deleteButtonIsHidden
    }
    
    private func setupUI() {
        let vStack = UIStackView(arrangedSubviews: [nameTextField, ageTextFiled])
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 8
        vStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [vStack, deleteButton])
        hStack.distribution = .fillProportionally
        hStack.spacing = 16
        
        [hStack].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}

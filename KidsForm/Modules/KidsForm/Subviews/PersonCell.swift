//
//  PersonCell.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit
protocol PersonCellDelegate: AnyObject {
    func deletePerson(_ person: Person)
    func personUpdated(_ person: Person)
}

final class PersonCell: UICollectionViewCell, CustomTextFieldDelegate {
    
    static var ientifier: String { String(describing: Self.self) }
    
    weak var delegate: PersonCellDelegate?
    
    private var person: Person?
    
    private lazy var nameTextField = {
        let tf = CustomTextField(placeHolder: "Имя", keyboardType: .default)
        return tf
    }()
    
    private lazy var ageTextFiled = {
        let tf = CustomTextField(placeHolder: "Возраст", keyboardType: .numberPad)
        tf.delegate = self
        return tf
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self, let person else { return }
                    self.delegate?.deletePerson(person)
                }
            ),
            for: .touchUpInside
        )
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
        
        drainDelegates()
        deleteButton.isHidden = false
        nameTextField.configureWith(text: String())
        ageTextFiled.configureWith(text: String())
    }
    
    func configureWith(_ person: Person, deleteButtonIsHidden: Bool) {
        self.person = person
        nameTextField.configureWith(text: person.name)
        ageTextFiled.configureWith(text: person.age)
        nameTextField.delegate = self
        ageTextFiled.delegate = self
        deleteButton.isHidden = deleteButtonIsHidden
    }
    
    func didEndEditing() {
        person?.name = nameTextField.getCurrentText()
        person?.age = ageTextFiled.getCurrentText()
        
        guard let person = person else { return }
        
        delegate?.personUpdated(person)
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
    
    private func drainDelegates() {
        delegate = nil
        nameTextField.delegate = nil
        ageTextFiled.delegate = nil
    }
}

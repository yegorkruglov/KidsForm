//
//  PersonCell.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit
import Combine

final class PersonCell: UICollectionViewCell {
    
    static var ientifier: String { String(describing: Self.self) }
    
    // MARK: - publishers
    
    weak var deleteChildButtonPublisher: PassthroughSubject<Person, Never>?
    weak var updatePersonPublisher: PassthroughSubject<Person, Never>?
    private weak var namePublisher: PassthroughSubject<String, Never>?
    private weak var agePublisher: PassthroughSubject<String, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: -  private properties
    
    private var person: Person?
    
    // MARK: - ui elements
    
    private lazy var nameTextField = CustomTextField(placeHolder: "Имя", keyboardType: .default)
    private lazy var ageTextFiled = CustomTextField(placeHolder: "Возраст", keyboardType: .numberPad)
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self, let person else { return }
                    deleteChildButtonPublisher?.send(person)
                }
            ),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: -  initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        deleteButton.isHidden = false
        deleteChildButtonPublisher = nil
        namePublisher = nil
        agePublisher = nil
        cancellables.removeAll()
    }
    
    // MARK: - public methods
    
    func configureWith(_ person: Person, deleteButtonIsHidden: Bool) {
        self.person = person
        nameTextField.configureWith(text: person.name)
        ageTextFiled.configureWith(text: person.age)
        deleteButton.isHidden = deleteButtonIsHidden
        namePublisher = nameTextField.textPublisher
        agePublisher = ageTextFiled.textPublisher
        handlePublishers()
    }
    
    // MARK: -  private methods
    
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
    
    private func handlePublishers() {
        namePublisher?
            .sink(receiveValue: { [weak self] name in
                self?.person?.name = name
                guard let person = self?.person else { return }
                self?.updatePersonPublisher?.send(person)
            })
            .store(in: &cancellables)
        
        agePublisher?
            .sink(receiveValue: { [weak self] age in
                self?.person?.age = age
                guard let person = self?.person else { return }
                self?.updatePersonPublisher?.send(person)
            })
            .store(in: &cancellables)
    }
}

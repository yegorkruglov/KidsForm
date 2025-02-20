//
//  CustomHeaderView.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit
import Combine

final class CustomHeaderView: UICollectionReusableView {
    
    static var identifier: String { String(describing: Self.self) }
    
    // MARK: - public properties
    
    weak var addChildButtonPublisher: PassthroughSubject<Void, Never>?
    
    // MARK: -  ui elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    private lazy var addButton: CustomButton = {
        let button = CustomButton(kind: .add)
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.addChildButtonPublisher?.send()
                }
            ),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        addChildButtonPublisher = nil
    }
    
    // MARK: - public methods
    
    func configureForSectionKind(_ kind: KidsFormViewController.Section) {
        titleLabel.text = (kind == .parent) ? "Персональные данные" : "Дети (макс. 5)"
        let isParent = (kind == .parent)
        addButton.isHidden = isParent || kind == .kids(isAddChildButtonEnabled: false)
        layoutIfNeeded()
    }
    
    // MARK: -  private methods
    
    private func setupUI() {
        addButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel, addButton])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .fill
        
        addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])
    }
}


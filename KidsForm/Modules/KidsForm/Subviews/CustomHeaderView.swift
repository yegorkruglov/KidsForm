//
//  CustomHeaderView.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

protocol CustomHeaderViewDelegate: AnyObject {
    func didTapAddButton()
}

final class CustomHeaderView: UICollectionReusableView {
    
    static var identifier: String { String(describing: Self.self) }
    
    weak var delegate: CustomHeaderViewDelegate?
    
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
                    self?.delegate?.didTapAddButton()
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
        titleLabel.text = nil
        delegate = nil
    }
    
    func configureForSectionKind(_ kind: CustomHeaderView.Kind) {
        titleLabel.text = (kind == .parent) ? "Персональные данные" : "Дети (макс. 5)"
        let isParent = (kind == .parent)
        addButton.isHidden = isParent || kind == .kids(isAddChildButtonEnabled: false)
        layoutIfNeeded()
    }
    
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

extension CustomHeaderView {
    enum Kind: Equatable {
        case parent
        case kids(isAddChildButtonEnabled: Bool)
    }
}

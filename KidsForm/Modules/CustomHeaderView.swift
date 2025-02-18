//
//  CustomHeaderView.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class CustomHeaderView: UICollectionReusableView {
    enum Kind {
        case parent
        case kids
    }
    
    static var identifier: String { String(describing: Self.self) }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    
    private lazy var addButton: CustomButton = {
        let button = CustomButton(kind: .add)
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
        addButton.isHidden = false
    }
    
    func configureForSectionKind(_ kind: CustomHeaderView.Kind) {
        titleLabel.text = kind == .parent ? "Персональные данные" : "Дети (макс. 5)"
        addButton.isHidden = kind == .parent
    }
    
    private func setupUI() {
        [titleLabel, addButton].forEach { subview in
            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -16)
        ])
    }
}

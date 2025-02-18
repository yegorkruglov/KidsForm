//
//  KidsFormViewController.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class KidsFormViewController: UIViewController {
    enum Section: Int {
        case parent
        case kids
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Person>?
    private lazy var layout: UICollectionViewLayout = {
        
        UICollectionViewCompositionalLayout { sectionNumber, _ in
            let layoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/5)
            )
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            
            guard let sectionType = Section(rawValue: sectionNumber) else { return section }
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/5)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }()
    
    // MARK: - ui elements
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.register(
            PersonCell.self,
            forCellWithReuseIdentifier: PersonCell.ientifier
        )
        cv.register(
            CustomHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CustomHeaderView.identifier
        )
        cv.showsVerticalScrollIndicator = false
        
        return cv
    }()
    
    private lazy var clearButton: CustomButton = {
        let button = CustomButton(kind: .clear)
        return button
    }()
    
    // MARK: - initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        initDataSource()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        applyEmptySnapshot()
    }
}

// MARK: - private methods

private extension KidsFormViewController {
    func setup() {
        addSubviews()
        configureSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        [collectionView, clearButton].forEach { subview in
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func configureSubviews() {
        view.backgroundColor = .systemBackground
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: clearButton.topAnchor, constant: -16)
        ])
    }
    
    func initDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Person>(collectionView: collectionView) { collectionView, indexPath, item in
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PersonCell.ientifier,
                    for: indexPath) as? PersonCell
            else { return UICollectionViewCell()
            }
            
            cell.configureWith(item, deleteButtonIsHidden: indexPath.section == 0)
            
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            guard let sectionType = Section(rawValue: indexPath.section) else { return nil }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CustomHeaderView.identifier,
                for: indexPath
            ) as? CustomHeaderView else { return nil }
            
            switch sectionType {
            case .parent:
                header.configureForSectionKind(.parent)
            case .kids:
                header.configureForSectionKind(.kids)
            }
            
            return header
        }
    }
    
//    func applyEmptySnapshot() {
//        guard let dataSource else { return }
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Person>()
//        snapshot.appendSections([.parent, .kids])
//        snapshot.appendItems([.init(name: "Egor", age: "32")], toSection: .parent)
//        snapshot.appendItems([
//            .init(name: "Alex", age: "34"),
//            .init(name: "Dmitry", age: "27"),
//            .init(name: "Nikita", age: "45"),
//            .init(name: "Sergey", age: "19"),
//            .init(name: "Vlad", age: "52")
//        ], toSection: .kids)
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
}

//
//  KidsFormViewController.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit
import Combine

final class KidsFormViewController: UIViewController {

    // MARK: -  view model
    
    private let viewModel: KidsFormViewModel
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private var clearButtonPublisher: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    private var addChildButtonPublisher: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    private var deleteChildButtonPublisher: PassthroughSubject<Person, Never> = PassthroughSubject<Person, Never>()
    
    // MARK: -  private properties
    
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
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.clearButtonPublisher.send()
                }
            ),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - initializers
    
    init(viewModel: KidsFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        setup()
        bind()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false // Позволяет нажимать на кнопки
            view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    
    func bind() {
        let input = KidsFormViewModel.Input(
            clearButtonPublisher: clearButtonPublisher.eraseToAnyPublisher(),
            addChildButtonPublisher: addChildButtonPublisher.eraseToAnyPublisher(),
            deleteChildButtonPublisher: deleteChildButtonPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.bind(input)
        
        handleDataPublisher(output.dataPublisher)
    }
    
    func handleDataPublisher(_ publisher: AnyPublisher<KidsFormViewModel.StateData, Never>) {
        publisher
            .sink { [weak self] data in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Person>()
                snapshot.appendSections([.parent, .kids])
                snapshot.appendItems(data.parent, toSection: .parent)
                snapshot.appendItems(data.kids, toSection: .kids)
                self?.display(snapshot)
            }
            .store(in: &cancellables)
    }
    
    func display(_ snapshot: NSDiffableDataSourceSnapshot<Section, Person>) {
        dataSource?.applySnapshotUsingReloadData(snapshot)
    }
    
}


extension KidsFormViewController {
    enum Section: Int {
        case parent
        case kids
    }
}

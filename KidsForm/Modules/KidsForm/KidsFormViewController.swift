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
    private var personUpdatePublisher: PassthroughSubject<[Person], Never> = PassthroughSubject<[Person], Never>()
    
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
                heightDimension: .estimated(150)
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
    private lazy var collectionViewBottomPadding: CGFloat = 8
    private lazy var clearButtonBottomPadding: CGFloat = 8
    private lazy var collectionViewBottomConstraint: NSLayoutConstraint = {
        collectionView.bottomAnchor.constraint(
            equalTo: clearButton.topAnchor,
            constant: -collectionViewBottomPadding
        )
    }()
    private var isAddChildButtonEnabled = true
    
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
    }
}

// MARK: - private methods

private extension KidsFormViewController {
    func setup() {
        addSubviews()
        configureSubviews()
        makeConstraints()
        addDismissKeyboardTapGestureRecognizer()
        subscribeToKeyboardNotifications()
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
            clearButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -clearButtonBottomPadding
            ),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionViewBottomConstraint
        ])
    }
    
    func initDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Person>(collectionView: collectionView) {
            [weak self] collectionView, indexPath, item in
            
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PersonCell.ientifier,
                    for: indexPath) as? PersonCell
            else {
                return UICollectionViewCell()
            }
            
            cell.textFieldDelegate = self
            cell.deleteChildButtonPublisher = self?.deleteChildButtonPublisher
            cell.configureWith(item, deleteButtonIsHidden: indexPath.section == 0)
            
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
            guard let self = self,
                  let sectionType = Section(rawValue: indexPath.section),
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CustomHeaderView.identifier,
                    for: indexPath
                  ) as? CustomHeaderView
            else {
                return nil
            }
            
            switch sectionType {
            case .parent:
                header.configureForSectionKind(.parent)
            case .kids:
                header.configureForSectionKind(.kids(isAddChildButtonEnabled: isAddChildButtonEnabled))
                header.delegate = self
            }
            
            return header
        }
    }
    
    func bind() {
        let input = KidsFormViewModel.Input(
            clearButtonPublisher: clearButtonPublisher.eraseToAnyPublisher(),
            addChildButtonPublisher: addChildButtonPublisher.eraseToAnyPublisher(),
            deleteChildButtonPublisher: deleteChildButtonPublisher.eraseToAnyPublisher(),
            personUpdatePublisher: personUpdatePublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.bind(input)
        
        handleDataPublisher(output.dataPublisher)
    }
    
    func handleDataPublisher(_ publisher: AnyPublisher<KidsFormViewModel.StateData, Never>) {
        publisher
            .sink { [weak self] data in
                
                self?.display(data)
            }
            .store(in: &cancellables)
    }
    
    func display(_ data: KidsFormViewModel.StateData) {
        DispatchQueue.main.async { [weak self] in
            
            self?.isAddChildButtonEnabled = data.isAddChildButtonEnabled

            var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Person>()
            dataSourceSnapshot.appendSections([.parent, .kids])
            dataSourceSnapshot.appendItems(data.parent, toSection: .parent)
            dataSourceSnapshot.appendItems(data.kids, toSection: .kids)
            
            self?.dataSource?.apply(dataSourceSnapshot)
            
           
        }
    }
    
    func addDismissKeyboardTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func adjustCollectionViewBottomConstraint(constant: CGFloat) {
        collectionViewBottomConstraint.constant = -constant
        view.layoutIfNeeded()
    }
    
    func collectDataFromCells() {
        var allIndexPaths: [IndexPath] = []

        let numberOfSections = collectionView.numberOfSections
        for section in 0..<numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            for row in 0..<numberOfItems {
                allIndexPaths.append(IndexPath(item: row, section: section))
            }
        }
        
        var currentPersons: [Person] = []
        
        allIndexPaths.forEach { IndexPath in
            if let cell = collectionView.cellForItem(at: IndexPath) as? PersonCell {
                guard let currentPerson = cell.getCurrentPersonInfo() else { return }
                currentPersons.append(currentPerson)
            }
        }
    
        personUpdatePublisher.send(currentPersons)
    }
}

// MARK: - objc methods

private extension KidsFormViewController {
    @objc func dismissKeyboard() {
        view.resignFirstResponder()
        view.endEditing(true)
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        let isKeyboardHidden = notification.name == UIResponder.keyboardWillHideNotification
        
        guard !isKeyboardHidden else {
            adjustCollectionViewBottomConstraint(constant: collectionViewBottomPadding)
            return
        }
        
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottomIsnset = view.safeAreaInsets.bottom
        let clearButtonHeight = clearButton.frame.height
        let padding = keyboardHeight - clearButtonHeight - clearButtonBottomPadding - safeAreaBottomIsnset + collectionViewBottomPadding
        
        adjustCollectionViewBottomConstraint(constant: padding)
    }
}

// MARK: - custom header delegate

extension KidsFormViewController: CustomHeaderViewDelegate {
    func didTapAddButton() {
        addChildButtonPublisher.send()
    }
}

// MARK: - UITextFieldDelegate

extension KidsFormViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        collectDataFromCells()
    }
}

extension KidsFormViewController {
    enum Section: Int {
        case parent
        case kids
    }
}


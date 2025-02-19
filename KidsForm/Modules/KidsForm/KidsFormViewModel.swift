//
//  KidsFormViewModel.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import Foundation
import Combine

final class KidsFormViewModel {
    
    private var data: StateData = StateData(
        parent: [
            Person(name: String(), age: String())]
        ,
        kids: [
            Person(name: "Alex", age: "34"),
            Person(name: "Dmitry", age: "27"),
            Person(name: "Nikita", age: "45")
        ],
        isAddChildButtonEnabled: true
    )
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var dataPublisher: CurrentValueSubject<StateData, Never> = CurrentValueSubject<StateData, Never>(data)
    
    func bind(_ input: Input) -> Output {
        
        handleClearButtonPublisher(input.clearButtonPublisher)
        handleAddChildButtonPublisher(input.addChildButtonPublisher)
        handleDeleteChildButtonPublisher(input.deleteChildButtonPublisher)
        
        
        
        
        
        
        
        let output = Output(dataPublisher: dataPublisher.eraseToAnyPublisher())
       

        return output
    }  
    
}

// MARK: - private methods

private extension KidsFormViewModel {
    func handleClearButtonPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher.sink { [weak self] _ in
            let data = StateData(
                 parent: [
                     Person(
                         name: String(),
                         age: String()
                     )
                 ],
                 kids: [],
                 isAddChildButtonEnabled: true
             )
            self?.data = data
            self?.dataPublisher.send(data)
        }
        .store(in: &cancellables)
    }
    func handleAddChildButtonPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self] _ in
                guard let self, data.kids.count < 5 else { return }
                
                data.kids.append(Person(name: String(), age: String()))
                
                dataPublisher.send(
                    StateData(
                        parent: data.parent,
                        kids: data.kids,
                        isAddChildButtonEnabled: data.kids.count < 5
                    )
                )
            }
            .store(in: &cancellables)
    }
    func handleDeleteChildButtonPublisher(_ publisher: AnyPublisher<Person, Never>) {
        
    }
}

extension KidsFormViewModel {
    
    struct Input {
        let clearButtonPublisher: AnyPublisher<Void, Never>
        let addChildButtonPublisher: AnyPublisher<Void, Never>
        let deleteChildButtonPublisher: AnyPublisher<Person, Never>
    }
    
    struct Output {
        let dataPublisher: AnyPublisher<StateData, Never>
    }
    
    struct StateData {
        let parent: [Person]
        var kids: [Person]
        let isAddChildButtonEnabled: Bool
    }
}

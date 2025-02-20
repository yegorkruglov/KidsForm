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
        kids: []
    )
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var dataPublisher: CurrentValueSubject<StateData, Never> = CurrentValueSubject<StateData, Never>(data)
    
    // MARK: - public methods
    
    func bind(_ input: Input) -> Output {
        handleClearButtonPublisher(input.clearButtonPublisher)
        handleAddChildButtonPublisher(input.addChildButtonPublisher)
        handleDeleteChildButtonPublisher(input.deleteChildButtonPublisher)
        handlePersonUpdatePublisher(input.personUpdatePublisher)

        return Output(dataPublisher: dataPublisher.eraseToAnyPublisher())
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
                 kids: []
             )
            self?.data = data
            self?.dataPublisher.send(data)
        }
        .store(in: &cancellables)
    }
    func handleAddChildButtonPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self] _ in
                guard let self, data.isAddChildButtonEnabled else { return }
                
                data.kids.append(Person(name: String(), age: String()))
                
                dataPublisher.send(data)
            }
            .store(in: &cancellables)
    }
    func handleDeleteChildButtonPublisher(_ publisher: AnyPublisher<Person, Never>) {
        publisher
            .sink { [weak self] person in

                guard
                    let self,
                    let index = data.kids.firstIndex(where: { $0.id == person.id })
                else {
                    return
                }
                
                data.kids.remove(at: index)
                
                dataPublisher.send(data)
                
            }
            .store(in: &cancellables)
    }
    func handlePersonUpdatePublisher(_ publisher: AnyPublisher<Person, Never>) {
        publisher
            .sink { [weak self] person in
                
                guard let self else { return }
                
                if person.id == data.parent.first?.id {
                    data.parent = [person]
                } else if let index = data.kids.firstIndex(where: { $0.id == person.id }) {
                    data.kids[index] = person
                }
                
                dataPublisher.send(data)
            }
            .store(in: &cancellables)
    }
}


// MARK: - Entities

extension KidsFormViewModel {
    
    struct Input {
        let clearButtonPublisher: AnyPublisher<Void, Never>
        let addChildButtonPublisher: AnyPublisher<Void, Never>
        let deleteChildButtonPublisher: AnyPublisher<Person, Never>
        let personUpdatePublisher: AnyPublisher<Person, Never>
    }
    
    struct Output {
        let dataPublisher: AnyPublisher<StateData, Never>
    }
    
    struct StateData {
        var parent: [Person]
        var kids: [Person]
        var isAddChildButtonEnabled: Bool { kids.count < 5 }
    }
}

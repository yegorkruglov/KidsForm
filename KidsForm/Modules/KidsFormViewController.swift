//
//  KidsFormViewController.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import UIKit

final class KidsFormViewController: UIViewController {

    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
        
    }
    
    func configureSubviews() {
        view.backgroundColor = .systemBackground

    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
           
        ])
    }
}

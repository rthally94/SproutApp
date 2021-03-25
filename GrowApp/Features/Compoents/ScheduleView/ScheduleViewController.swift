//
//  ScheduleViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/7/21.
//

import UIKit

class ScheduleViewController: UIViewController {
    lazy var headerImage: UIImageView = {
        let view = UIImageView()
        view.setContentHuggingPriority(view.contentHuggingPriority(for: .horizontal) + 1, for: .horizontal)
        return view
    }()
    
    lazy var headerLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    private lazy var header: some UIView = {
        let view = UIStackView(arrangedSubviews: [headerImage, headerLabel])
        view.axis = .horizontal
        view.alignment = .firstBaseline
        view.distribution = .fill
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    func configureHiearchy() {
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        header.pinToLayoutMarginsOf(view)
    }
}

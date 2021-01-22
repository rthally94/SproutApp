//
//  WeekPicker.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

class WeekPicker: UIView {
    private var pickerView: UICollectionView!
    private var pickerHeader: UIStackView!
    private var currentDateLabel = UILabel(frame: .zero)
    
    var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    var dates = [Date]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurePickerHeader()
        configurePickerCollection()
        configureHiearchy()
        
        configureDates(for: Date())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configurePickerHeader() {
        var views = [UIView]()
        for i in 0..<7 {
            let label = UILabel(frame: .zero)
            label.text = Calendar.current.shortStandaloneWeekdaySymbols[i]
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textAlignment = .center
            views.append(label)
        }
        
        pickerHeader = UIStackView(arrangedSubviews: views)
        pickerHeader.axis = .horizontal
        pickerHeader.distribution = .fillEqually
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return layout
    }
    
    private func configurePickerCollection() {
        pickerView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        pickerView.isPagingEnabled = true
        pickerView.showsHorizontalScrollIndicator = false
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.register(WeekPickerCell.self, forCellWithReuseIdentifier: WeekPickerCell.reuseIdentifier)
        pickerView.backgroundColor = .clear
    }
    
    private func configureHiearchy() {
        pickerHeader.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        currentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(pickerHeader)
        addSubview(pickerView)
        addSubview(currentDateLabel)
        
        NSLayoutConstraint.activate([
            pickerHeader.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            pickerHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pickerView.topAnchor.constraint(equalTo: pickerHeader.bottomAnchor),
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func configureDates(for date: Date) {
        guard let startOfWeek = Calendar.current.nextWeekend(startingAfter: date, direction: .backward)?.start,
              let previousWeek = Calendar.current.date(byAdding: .day, value: -7, to: startOfWeek),
              let nextWeek = Calendar.current.date(byAdding: .day, value: 14, to: startOfWeek)
        else { return }
        
        var dates = [Date]()
        Calendar.current.enumerateDates(startingAfter: previousWeek, matching: .init(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime, using: {(date, strict, stop) in
            if let date = date {
                if date <= nextWeek {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        })
        
        self.dates = dates
    }
    
    // MARK:- Intents
    func selectDate(_ date: Date, animated: Bool = true) {
        selectedWeekday = Calendar.current.component(.weekday, from: date)
        configureDates(for: date)
        pickerView.reloadData()
        pickerView.scrollToItem(at: IndexPath(item: 7+selectedWeekday, section: 0), at: .centeredHorizontally, animated: animated)
    }
}

extension WeekPicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekPickerCell.reuseIdentifier, for: indexPath) as? WeekPickerCell else { return UICollectionViewCell() }
        
        let date = dates[indexPath.item]
        cell.textLabel.text = String(Calendar.current.component(.day, from: date))
        
        if Calendar.current.isDateInToday(date) {
            cell.textLabel.textColor = .red
        }
        
        if (indexPath.item % 7)+1 == selectedWeekday {
            cell.textLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        }
        
        return cell
    }
}

extension WeekPicker: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if newPage == 0 {
            selectDate(dates[(selectedWeekday-1) + 7*newPage], animated: false)
        } else if newPage == 2 {
            selectDate(dates[(selectedWeekday-1) + 7*newPage], animated: false)
        }
    }
}

extension WeekPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width/7)
        return CGSize(width: width, height: width)
    }
}

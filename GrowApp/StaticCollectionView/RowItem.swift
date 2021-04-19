//
//  RowItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/18/21.
//

import UIKit

struct RowItem: Hashable {
    static func == (lhs: RowItem, rhs: RowItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    typealias Icon = GHIcon

    enum RowType: Hashable {
        // List Cells
        case value1, value2, subtitle

        // Form Cells
        case textField, button

        // Sprout Cells
        case compactCard
        case icon, header
        case statistic
        case todo
    }

    enum DisplayContext: Int, Hashable {
        case normal, primary, destructive
    }

    var id: UUID
    var rowType: RowType

    var text: String?
    var secondaryText: String?
    var tertiaryText: String?
    var image: UIImage?
    var icon: Icon?
    var isOn: Bool
    var tintColor: UIColor?
    var displayContext: DisplayContext?

    var action: ((_ sender: AnyObject) -> Void)?

    /// Memberwise Initialzier. Not all properties are used in every row type.
    /// - Parameters:
    ///   - id: Unique Identifier of the item
    ///   - rowType: Visual representation of the row
    ///   - text: Primary Text
    ///   - secondaryText: Secondary Text
    ///   - tertiaryText: Tertiary Text
    ///   - image: Image to display
    ///   - icon: Icon to display
    ///   - isOn: Flag to represent the state of a switch with an on/off state
    private init(id: UUID = UUID(), rowType: RowType, text: String? = nil, secondaryText: String? = nil, tertiaryText: String? = nil, image: UIImage? = nil, icon: Icon? = nil, isOn: Bool = false, tintColor: UIColor? = .systemBlue, displayContext: DisplayContext? = nil, action: ((_ sender: AnyObject) -> Void)? = nil) {
        self.id = id
        self.rowType = rowType
        self.text = text
        self.secondaryText = secondaryText
        self.tertiaryText = tertiaryText
        self.image = image
        self.icon = icon
        self.isOn = isOn
        self.tintColor = tintColor
        self.displayContext = displayContext
        self.action = action
    }

    // MARK: - List Cell Factory Methods

    /// Creates a new RowItem for a UICollectionViewListCell
    /// - Parameters:
    ///   - id: Unique identifier for the item
    ///   - text: The primary text
    ///   - secondaryText: The secondary text
    ///   - image: The image to display
    /// - Returns: The configured RowItem
    static func listCell(id: UUID = UUID(), rowType: RowType = .value1, text: String? = nil, secondaryText: String? = nil, image: UIImage? = nil) -> RowItem {
        RowItem(id: id, rowType: rowType, text: text, secondaryText: secondaryText, image: image)
    }

    // MARK: - Form Cell Factory Methods

    /// Creates a new RowItem for a TextFieldCell
    /// - Parameters:
    ///   - id: Uniequ identifier for the item
    ///   - title: The title of the cell
    ///   - placeholder: The placeholder text of the text field
    ///   - initialValue: The initial value of the text field
    ///   - onChange: Closure to perform an action when the text field text changes
    /// - Returns: The configured RowItem
    static func textFieldCell(id: UUID = UUID(), title: String? = nil, placeholder: String?, initialValue: String?, onChange: ((_ sender: AnyObject) -> Void)? ) -> RowItem {
        RowItem(id: id, rowType: .textField, text: title, secondaryText: placeholder, tertiaryText: initialValue, action: onChange)
    }

    static func buttonCell(id: UUID = UUID(), context: DisplayContext = .normal, title: String? = nil, image: UIImage? = nil, tintColor: UIColor? = nil, onChange: ((_ sender: AnyObject) -> Void)?) -> RowItem {
        return RowItem(id: id, rowType: .button, text: title, image: image, tintColor: tintColor, displayContext: context, action: onChange)
    }

    // MARK: - Sprout Cell Factory Methods
    
    /// Creates a new RowItem for an Icon
    /// - Parameters:
    ///   - id: Unique identifier for the item
    ///   - icon: The icon
    /// - Returns: The configured RowItem
    static func icon(id: UUID = UUID(), icon: Icon?) -> RowItem {
        RowItem(id: id, rowType: .icon, icon: icon)
    }

    /// Creates a new RowItem for a large header
    /// - Parameters:
    ///   - id: Unique identifier for the item
    ///   - title: The title
    ///   - subtitle: The subtitle
    /// - Returns: The configured RowItem
    static func largeHeader(id: UUID = UUID(), title: String?, subtitle: String?) -> RowItem {
        RowItem(id: id, rowType: .header, text: title, secondaryText: subtitle)
    }

    /// Creates a new RowItem for a statistic cell
    /// - Parameters:
    ///   - id: Unique identifier for the item
    ///   - title: The title
    ///   - value: The value
    ///   - unit: The unit
    ///   - icon: The icon
    ///   - tintColor: Primary tint color of the item
    /// - Returns: The configured RowItem
    static func statistic(id: UUID = UUID(), title: String?, value: String?, unit: String? = nil, image: UIImage? = nil, icon: Icon? = nil, tintColor: UIColor? = nil) -> RowItem {
        RowItem(id: id, rowType: .statistic, text: title, secondaryText: value, tertiaryText: unit, image: image, icon: icon, tintColor: tintColor)
    }

    /// Creates a new RowItem for a todo cell
    /// - Parameters:
    ///   - id: Unique identifier for the item
    ///   - title: The title
    ///   - subtitle: The subtitle
    ///   - image: The image
    ///   - icon: The icon
    ///   - taskState: Flag to represent the state of a switch with an on/off state
    ///   - tintColor: Primary tint color of the item
    /// - Returns: The configured RowItem
    static func todo(id: UUID = UUID(), title: String?, subtitle: String?, image: UIImage? = nil, icon: Icon? = nil, taskState: Bool, tintColor: UIColor? = nil) -> RowItem {
        RowItem(id: id, rowType: .todo, text: title, secondaryText: subtitle, image: image, icon: icon, isOn: taskState, tintColor: tintColor)
    }

    static func compactCardCell(id: UUID = UUID(), title: String?, value: String?, image: UIImage? = nil) -> RowItem {
        RowItem(id: id, rowType: .compactCard, text: title, secondaryText: value, image: image)
    }
}

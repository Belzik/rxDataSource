//
//  AnimatableSectionsViewController.swift
//  ReserchRxDataSource
//
//  Created by Александр Катрыч on 13.05.2021.
//

import Foundation
import RxDataSources

struct NumberSection {
    var header: String
    var numbers: [IntItem]

    var updated: Date

    init(header: String, numbers: [Item], updated: Date) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

struct IntItem {
    let number: Int
    let date: Date
}

extension NumberSection: AnimatableSectionModelType {
    typealias Item = IntItem
    typealias Identity = String

    var identity: String {
        return header
    }

    var items: [IntItem] {
        return numbers
    }

    init(original: NumberSection, items: [Item]) {
        self = original
        self.numbers = items
    }
}

extension IntItem: IdentifiableType, Equatable {
    typealias Identity = Int

    var identity: Int {
        return number
    }
}

// equatable, this is needed to detect changes
func == (lhs: IntItem, rhs: IntItem) -> Bool {
    return lhs.number == rhs.number && lhs.date == rhs.date
}

extension NumberSection: Equatable {
    
}

func == (lhs: NumberSection, rhs: NumberSection) -> Bool {
    return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}

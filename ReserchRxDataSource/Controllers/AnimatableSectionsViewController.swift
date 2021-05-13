//
//  AnimatableSectionsViewController.swift
//  ReserchRxDataSource
//
//  Created by Александр Катрыч on 13.05.2021.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class AnimatableSectionsViewController: UIViewController {
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let dataSource = createDataSource()

        let sections: [NumberSection] = [
            NumberSection(header: "Section 1", numbers: [], updated: Date()),
            NumberSection(header: "Section 2", numbers: [], updated: Date()),
            NumberSection(header: "Section 3", numbers: [], updated: Date())
        ]
        let initialState = SectionedTableViewState(sections: sections)
        let addItemsAddStart = Observable.of((), (), ())

        let addCommand = Observable.of(addButton.rx.tap.asObservable(), addItemsAddStart)
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView.rx.itemDeleted.asObservable().map(TableViewEditingCommand.deleteItem)
        let movedCommand = tableView.rx.itemMoved.asObservable().map(TableViewEditingCommand.moveItem)

        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) { state, command in
                return state.execute(command: command)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }

    // MARK: - Methods

    func createDataSource() -> RxTableViewSectionedAnimatedDataSource<NumberSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "\(item.number)"
                return cell
            },
            titleForHeaderInSection: { dataSource, section in
                return dataSource[section].header
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
    }

}

enum TableViewEditingCommand {
    case appendItem(item: IntItem, section: Int)
    case moveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case deleteItem(IndexPath)
}

struct SectionedTableViewState {
    fileprivate var sections: [NumberSection]

    init(sections: [NumberSection]) {
        self.sections = sections
    }

    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .appendItem(let item, let section):
            var sections = self.sections
            let items = sections[section].items + [item]
            sections[section] = NumberSection(original: sections[section], items: items)
            return SectionedTableViewState(sections: sections)
        case .deleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = NumberSection(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .moveItem(let sourceIndex, let destinationIndex):
            var sections = self.sections
            var sourceItems = sections[sourceIndex.section].items
            var destinationItems = sections[destinationIndex.section].items

            if sourceIndex.section == destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndex.row),
                                        at: destinationIndex.row)
                let destinationSection = NumberSection(original: sections[destinationIndex.section], items: destinationItems)
                sections[sourceIndex.section] = destinationSection

                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndex.row)
                destinationItems.insert(item, at: destinationIndex.row)
                let sourceSection = NumberSection(original: sections[sourceIndex.section], items: sourceItems)
                let destinationSection = NumberSection(original: sections[destinationIndex.section], items: destinationItems)
                sections[sourceIndex.section] = sourceSection
                sections[destinationIndex.section] = destinationSection

                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

extension TableViewEditingCommand {
    static var nextNumber = 0
    static func addRandomItem() -> TableViewEditingCommand {
        defer { nextNumber = nextNumber + 1 }
        let randSection = Int.random(in: 0...2)
        let number = nextNumber
        let item = IntItem(number: number, date: Date())
        return TableViewEditingCommand.appendItem(item: item, section: randSection)
    }
}

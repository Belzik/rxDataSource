//
//  SectionsViewController.swift
//  ReserchRxDataSource
//
//  Created by Александр Катрыч on 13.05.2021.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

struct MySection {
    var header: String
    var items: [Item]
}

extension MySection : SectionModelType {
    typealias Item = String

    var identity: String {
        return header
    }

    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

class SectionsViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<MySection>?

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let dataSource = RxTableViewSectionedReloadDataSource<MySection>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "Item \(item)"

                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )

        self.dataSource = dataSource

        let sections = [
            MySection(header: "First section", items: [
                "String 1",
                "String 2"
            ]),
            MySection(header: "Second section", items: [
                "String 3",
                "String 4"
            ])
        ]

        Observable.of(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

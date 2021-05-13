//
//  ViewController.swift
//  ReserchRxDataSource
//
//  Created by Александр Катрыч on 13.05.2021.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

// MARK: - Простой пример, когда у нас только одна секция

class SimpleViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let strings = Observable.of(["String 1", "String 2", "String 3", "String 4", "String 5"])
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        strings
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = element
                return cell
            }
            .disposed(by: bag)

        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { model in
                print("\(model) was selected")
            })
            .disposed(by: bag)


        // tableView:commitEditingStyle:forRowAtIndexPath:
        tableView.rx
            .modelDeleted(String.self)
            .subscribe(onNext: { model in
            })
            .disposed(by: bag)


        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { element in

            })
            .disposed(by: bag)


    }

}

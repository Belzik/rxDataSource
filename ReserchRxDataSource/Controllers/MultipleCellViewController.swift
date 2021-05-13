//
//  MultipleCellViewController.swift
//  ReserchRxDataSource
//
//  Created by Александр Катрыч on 13.05.2021.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

enum MyModel {
  case text(String)
  case image(UIImage)
}

class MultipleCellViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    let observable = Observable<[MyModel]>.of([
        .text("Cat 1"),
        .image(UIImage(named: "cat")!),
        .text("Cat 2"),
        .image(UIImage(named: "cat")!)
    ])
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageCellNib = UINib(nibName: ImageTableViewCell.identtifier, bundle: nil)
        tableView.register(imageCellNib, forCellReuseIdentifier: ImageTableViewCell.identtifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "textCell")

        observable.bind(to: tableView.rx.items) { tableView, index, element in
            let indexPath = IndexPath(item: index, section: 0)
            switch element {
            case .text(let title):
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
                cell.textLabel?.text = title
                return cell
            case .image(let image):
                let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identtifier, for: indexPath) as! ImageTableViewCell
                cell.someImageView.image = image
                return cell
            }
        }
        .disposed(by: bag)
    }

}

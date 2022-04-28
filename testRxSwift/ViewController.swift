//
//  ViewController.swift
//  testRxSwift
//
//  Created by yuki.osu on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    let disposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        let talkRoomInfo: Single<String> = apiCall(param: "Get TalkRoomInfo", interval: 3)
        let dealInfo: Single<String> = apiCall(param: "Get DealInfo", interval: 1)

        talkRoomInfo
            .debug("[TalkRoomInfo]", trimOutput: false)
            .asDriver(onErrorDriveWith: .empty())
            .drive(label1.rx.text)
            .disposed(by: disposeBag)

        dealInfo
            .debug("[DealInfo]", trimOutput: false)
            .asObservable()
            .withLatestFrom(talkRoomInfo) { ($0, $1) }
            .map { "\($0) + \($1)" }
            .asDriver(onErrorDriveWith: .empty())
            .drive(label2.rx.text)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func apiCall(param: String, interval: Int) -> Single<String> {
        return Single.create { (observer) -> Disposable in
            DispatchQueue.init(label: "background").async {
                sleep(UInt32(interval))
                observer(.success(param))
            }

            return Disposables.create()
        }
    }

}

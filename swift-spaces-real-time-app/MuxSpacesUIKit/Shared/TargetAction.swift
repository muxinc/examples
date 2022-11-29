//
//  TargetAction.swift
//

import Foundation
import UIKit

/// Works around lack of UIAction APIs on iOS 13
///
final class TargetAction {
    let execute: () -> ()

    init(_ execute: @escaping () -> ()) {
        self.execute = execute
    }

    @objc func action(_ sender: Any) {
        execute()
    }
}

final class TargetActionSender {
    let execute: (AnyObject) -> ()

    init(_ execute: @escaping (AnyObject) -> ()) {
        self.execute = execute
    }

    @objc func action(_ sender: AnyObject) {
        execute(sender)
    }
}

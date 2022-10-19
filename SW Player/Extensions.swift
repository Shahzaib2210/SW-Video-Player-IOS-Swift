//
//  Extensions.swift
//  SW Player
//
//  Created by Shahzaib Mumtaz on 09/09/2022.
//

import Foundation
import AVKit
import AVFoundation

struct Helper {
    
    // MARK:- Show Alert Function.
    
    func showAlert(message:String,title:String, viewController: UIViewController) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(action) in  print("OK...")
        }))
        viewController.present(alert, animated:true)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

//
//  CompassViewController.swift
//  Practise Application
//
//  Created by 葉家均 on 2022/8/21.
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {
    @IBOutlet weak var layout: UIStackView!
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.startUpdatingHeading()

    }
}

extension CompassViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let trueHeading = newHeading.trueHeading
        let degress = CGFloat.pi / 180 * trueHeading
        let transform = CGAffineTransform.init(rotationAngle: -degress)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.layout.transform = transform
        })
    }
}

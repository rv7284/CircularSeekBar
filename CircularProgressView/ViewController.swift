//
//  ViewController.swift
//  CircularProgressView
//
//  Created by Ravi on 17/10/18.
//  Copyright © 2018 Ravi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var circularProgressView: CircularSeekBarView!
    @IBOutlet weak var lblValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        circularProgressView.trackColor = .black
        circularProgressView.trackWidth = 8.0
        circularProgressView.progressWidth = 10.0
        circularProgressView.delelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        circularProgressView.createCircularPath()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.circularProgressView.setProgress(0.5, true)
//        }
    }
    
    @IBAction func setProgress(_ sender: UIButton) {
        self.circularProgressView.setProgress(CGFloat(Double(sender.title(for: .normal)!)!), false)
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        
    }
}

extension ViewController: CirclularSeekBarDelegate {
    func seekBar(_ seekbar: CircularSeekBarView, valueUpdate value: CGFloat) {
        lblValue.text = "\(Double(round(1000*value)/1000))"
    }
}

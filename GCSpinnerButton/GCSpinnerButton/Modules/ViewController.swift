//
//  ViewController.swift
//  GCSpinnerButton
//
//  Created by Guilherme Coelho on 30/07/18.
//  Copyright © 2018 DevForFun_Guilherme_Coelho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Outlets
  
  @IBOutlet weak var btnSpinner: GCSpinnerButton!
  
  // MARK: - Properties
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureButton()
  }
  
  // MARK: - Class Methods
  
  private func configureButton() {
    btnSpinner.backgroundColor = UIColor.cyan
  }
  
  // MARK: - Actions
  
  @IBAction func startIsPressed(_ sender: Any) {
    btnSpinner.animate(2.2) {
      
    }
  }
  
}


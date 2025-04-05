//
//  ViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-04.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var call = Api_Network.shared
        call.makeCategoryRequest()
        // Do any additional setup after loading the view.
    }


}


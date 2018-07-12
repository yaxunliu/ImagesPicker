//
//  ViewController.swift
//  ImagesPicker
//
//  Created by liuyaxun on 07/09/2018.
//  Copyright (c) 2018 liuyaxun. All rights reserved.
//

import UIKit
import ImagesPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = AlbumListController { (models) in
            
        }
        present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)

    }

}


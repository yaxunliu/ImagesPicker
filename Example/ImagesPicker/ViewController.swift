//
//  ViewController.swift
//  ImagesPicker
//
//  Created by liuyaxun on 07/09/2018.
//  Copyright (c) 2018 liuyaxun. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = AlbumListController { (models) in
            print("select models -> ", models.count)
        }
        present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
        
    }
    

}


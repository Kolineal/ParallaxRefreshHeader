//
//  ViewController.swift
//  ParallaxRefreshHeader
//
//  Created by Kolineal on 06/21/2018.
//  Copyright (c) 2018 Kolineal. All rights reserved.
//

import UIKit
import ParallaxRefreshHeader

class ViewController: UIViewController {

//  var collectionView : ParallaxRefreshCollectionView = ParallaxRefreshCollectionView()
    override func viewDidLoad() {
        let coll = ParallaxRefreshCollectionView()
        coll.parallaxHeader.pullToRefresh.addRefreshAction {
          print("hello")
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


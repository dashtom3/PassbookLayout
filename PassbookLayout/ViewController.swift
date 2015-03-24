//
//  ViewController.swift
//  PassbookLayout
//
//  Created by 田程元 on 15/3/23.
//  Copyright (c) 2015年 田程元. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerNib(UINib(nibName: "PassbookCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "pass")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
//MARK: - UICollectionViewDatasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200;
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("pass", forIndexPath: indexPath) as PassbookCell
        cell.setStyle(indexPath.row%cell.names.count)
        return cell
    }
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        var shouldSelect = true;
        var indexPath:NSIndexPath
        for indexPath in collectionView.indexPathsForSelectedItems(){
            collectionView.deselectItemAtIndexPath(indexPath as? NSIndexPath, animated: true)
            self.collectionView(collectionView, didDeselectItemAtIndexPath: indexPath as NSIndexPath)
            shouldSelect = false
        }
        return shouldSelect
    }
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.performBatchUpdates(nil, completion: nil)
        collectionView.scrollEnabled = true
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.performBatchUpdates(nil, completion: nil)
        collectionView.scrollEnabled = false
    }
    
    
//MARK: - Miscellaneous

//MARK: Status Bar color
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}


//
//  ViewController.swift
//  CustomCollectionViewLayoutWithSwiftDemo
//
//  Created by DBC on 16/12/12.
//  Copyright © 2016年 DBC. All rights reserved.
//

import UIKit

class ViewController: UIViewController , SFCustomCollectionViewLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let layout:SFCustomCollectionViewLayout = SFCustomCollectionViewLayout()
        layout.lineSpacing = 1
        layout.interitemSpacing = 1;
        layout.contentInset = UIEdgeInsetsMake(1, 1, 1, 1)
        layout.delegate = self
        
        let collectionView:UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
    }
    
    func customLayout(_ customLayout:SFCustomCollectionViewLayout, itemSizeAt indexPath:IndexPath) -> CGSize{
        if indexPath.item%3 == 0 {
            return CGSize(width:70,height:30);
        } else if indexPath.item%2 == 0 {
            return CGSize(width:90,height:30);
        }
        return CGSize(width:50,height:30);
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 25
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.968627451, blue: 0.4980392157, alpha: 1)
        return cell
    }

    

}


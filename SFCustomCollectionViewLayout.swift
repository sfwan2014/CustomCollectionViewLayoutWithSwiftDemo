//
//  SFCustomCollectionViewLayout.swift
//  CustomCollectionViewLayoutWithSwiftDemo
//
//  Created by DBC on 16/12/12.
//  Copyright © 2016年 DBC. All rights reserved.
//

import UIKit


@objc public  protocol SFCustomCollectionViewLayoutDelegate : NSObjectProtocol {
    // item size
    @objc optional func customLayout(_ customLayout:SFCustomCollectionViewLayout, itemSizeAt indexPath:IndexPath) -> CGSize
    // header size
    @objc optional func customLayout(_ customLayout:SFCustomCollectionViewLayout, headerViewSizeAt section:NSInteger) -> CGSize
    // footer size
    @objc optional func customLayout(_ customLayout:SFCustomCollectionViewLayout, footerViewSizeAt section:NSInteger) -> CGSize
    
    // 垂直间距
    @objc optional func customLayout(customLayout:SFCustomCollectionViewLayout, minimumLineSpacingAt section:NSInteger) -> CGFloat
    // 左右间距
    @objc optional func customLayout(customLayout:SFCustomCollectionViewLayout, minimumInteritemSpacingAt section:NSInteger) -> CGFloat
    
    // 边距
    @objc optional func customLayout(customLayout:SFCustomCollectionViewLayout, contentInsetForSection section:Int) -> UIEdgeInsets
    
    // 计算contentSize 协议方法
    @objc optional func customLayout(customLayout:SFCustomCollectionViewLayout, numberOfItemsIn section:NSInteger) -> Int
}

public class SFCustomCollectionViewLayout: UICollectionViewLayout {
    public var contentSize:CGSize?
    
    private var _itemSize:CGSize?
    public var itemSize:CGSize? {
        get{
            return _itemSize
        }
        set(newValue){
            self._itemSize = newValue
            self.invalidateLayout()
        }
    }
    public var layoutInfoArr:Array<Any>?
    
    private var _lineSpacing:CGFloat?
    public var lineSpacing:CGFloat?{
        get{
            return _lineSpacing
        }
        set(newValue){
            self._lineSpacing = newValue
            self.invalidateLayout()
        }
    }
    
    private var _interitemSpacing:CGFloat?
    public var interitemSpacing:CGFloat?{
        get{
            return _interitemSpacing
        }
        
        set(newValue){
            self._interitemSpacing = newValue
            self.invalidateLayout()
        }
    }
    public var contentInset:UIEdgeInsets?
    public var delegate:SFCustomCollectionViewLayoutDelegate?
    
    public override var collectionViewContentSize: CGSize { get{
            return self.contentSize!
        }
    }
    
    private var _offsetRow = 0 // 当前第几行
    private var _offsetX:CGFloat = 0.0 // 当前偏移量 x
    private var _offsetY:CGFloat = 0.0 // 当前偏移量 y
    private var _lastItemHeight:CGFloat = 0.0  // 最后一个item 高度
    private var _lastFooterHeight:CGFloat = 0.0 // 最后一个footer 高度
    private var _lastHeaderHeight:CGFloat = 0.0 // 最后一个header 高度
    
    public override init(){
        super.init();
        itemSize = CGSize(width: 50, height: 50);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func SFCustomCollectionViewLayout(){
        contentSize = CGSize();
        itemSize = CGSize();
    }
    
    
    public override func prepare() {
        super.prepare()
        
        _offsetRow = 0
        _offsetX = (self.contentInset?.left)!
        _offsetY = 0.0
        _lastItemHeight = 0
        _lastFooterHeight = 0
        _lastHeaderHeight = 0
        
        layoutInfoArr = Array<Any>()
        
        var maxNumberOfItems:Int! = 0
        let numberOfSections = self.collectionView?.numberOfSections
        
        for section in 0...numberOfSections!-1 {
            let numberOfItems = self.collectionView?.numberOfItems(inSection: section)
            var subArr:Array<UICollectionViewLayoutAttributes> =  Array<UICollectionViewLayoutAttributes>()
            
            for item in 0...numberOfItems!-1 {
                let indexPath = IndexPath(item: item, section: section)
                
                if item == 0 {
                    let size:CGSize = self.sectionHeaderViewSizeAtIndexPath(indexPath)!
                    if size.height > 0 {
                        
                        if let headerAttributes:UICollectionViewLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
                            subArr.append(headerAttributes)
                        }
                    }
                }
                
                let attributes:UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: indexPath)!
                subArr .append(attributes)
                
                if item == numberOfItems! - 1 {
                    let size:CGSize = self .sectionFooterViewSizeAtIndexPath(indexPath)!
                    if size.height > 0 {
                        if let footerAttributes:UICollectionViewLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: indexPath) {
                            subArr.append(footerAttributes)
                        }
                    }
                }
            }
            
            if maxNumberOfItems < numberOfItems! {
                maxNumberOfItems = numberOfItems
            }
            
            layoutInfoArr!.append(subArr)
            let height = _offsetY + _lastItemHeight + _lastFooterHeight + _lastHeaderHeight + self.contentInset!.bottom + self.lineSpacing!
            let size:CGSize = CGSize(width: self.collectionView!.frame.size.width, height: height)
            self.contentSize = size
            
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesArr:Array<UICollectionViewLayoutAttributes> = Array<UICollectionViewLayoutAttributes>()
        for elements in self.layoutInfoArr! {
            let array:Array<UICollectionViewLayoutAttributes> = elements as! Array
            for  obj in array {
                if obj.frame.intersects(rect) {
                    layoutAttributesArr.append(obj)
                }
            }
        }
        return layoutAttributesArr
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        let attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let size:CGSize = self.itemSizeAtIndexPath(indexPath: indexPath)!
        let lineSpacing:CGFloat = CGFloat(self.lineSpacingForSection(indexPath.section))
        let interitemSpacing:CGFloat = CGFloat(self.interitemSpacingForSection(indexPath.section))
        let contentInset = self.contentInsetForSection(indexPath.section)
        if _offsetY == 0 {
            _offsetY = contentInset.top
        }
        var offsetX = _offsetX
        var offsetY = _offsetY
        if _lastHeaderHeight > 0.0 {
            offsetX = contentInset.left
        }
        if _lastFooterHeight > 0.0 {
            offsetX = contentInset.left
        }
        
        _lastFooterHeight = 0;
        _lastHeaderHeight = 0;
        
        let tmpX = offsetX + size.width + interitemSpacing + contentInset.right
        if tmpX > (self.collectionView?.frame.size.width)! + 10 {
            _offsetRow += 1
            offsetY = offsetY + _lastItemHeight + lineSpacing
            offsetX = contentInset.left
        }
        
        attributes.frame = CGRect(x: offsetX, y: offsetY, width: size.width, height: size.height)
        offsetX = offsetX + size.width + interitemSpacing
        
        _lastItemHeight = size.height
        _offsetX = offsetX
        _offsetY = offsetY
        
        return attributes
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        if !((elementKind == UICollectionElementKindSectionHeader) || (elementKind == UICollectionElementKindSectionFooter))  {
            return nil
        }
        
        let attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        let contentInset:UIEdgeInsets = self.contentInsetForSection(indexPath.section)
        if elementKind == UICollectionElementKindSectionHeader {
            let size:CGSize = self.sectionHeaderViewSizeAtIndexPath(indexPath)!
            if size.height == 0{
                return attributes;
            }
            var offsetY:CGFloat = _offsetY
            if _lastItemHeight > 0 {
                let hadFooter:Bool = self.lastSectionHadFooterAtIndexPath(indexPath)
                if hadFooter {
                    offsetY = _offsetY;
                } else {
                    offsetY = _offsetY + _lastItemHeight + contentInset.top
                }
            }
            
            attributes.frame = CGRect(x: 0, y: offsetY, width: size.width, height: size.height)
            offsetY += (size.height + contentInset.top)
            _offsetY = offsetY
            _offsetX = contentInset.left;
            return attributes
        } else {
            let size:CGSize = self.sectionFooterViewSizeAtIndexPath(indexPath)!
            _lastFooterHeight = size.height
            if size.height == 0 {
                return attributes
            }
            
            var offsetY:CGFloat = _offsetY + contentInset.bottom + _lastItemHeight
            attributes.frame = CGRect(x: 0, y: offsetY, width: size.width, height: size.height)
            offsetY += (size.height + contentInset.bottom)
            _offsetY = offsetY
            _offsetX = contentInset.left
            return attributes
        }
    }
    
    
//    #prama
    private func lastSectionHadFooterAtIndexPath(_ indexPath:IndexPath) -> Bool{
        let section = indexPath.section;
        if section == 0 {
            return false;
        }
        
        let lastSectionIndex:IndexPath = IndexPath.init(item: indexPath.item, section: indexPath.section-1)
        let size:CGSize = self.sectionFooterViewSizeAtIndexPath(lastSectionIndex)!
        if size.height <= 0 {
            return false
        }
        return true
    }
    
    private func itemSizeAtIndexPath(indexPath:IndexPath) -> CGSize?{
        
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(_:itemSizeAt:))))! {
            let res = self.delegate!.customLayout!(self, itemSizeAt: indexPath)
            return res
        }
        return self.itemSize
    }
    
    private func sectionHeaderViewSizeAtIndexPath(_ indexPath: IndexPath) -> CGSize? {
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(_:headerViewSizeAt:))))! {
            let res = self.delegate!.customLayout!(self, headerViewSizeAt: indexPath.section)
            return res
        }
        return CGSize()
    }
    
    private func sectionFooterViewSizeAtIndexPath(_ indexPath: IndexPath) -> CGSize? {
        
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(_:footerViewSizeAt:))))! {
            let res = self.delegate!.customLayout!(self, footerViewSizeAt: indexPath.section)
            return res
        }
        return CGSize()
    }
    
    private func lineSpacingForSection(_ section:Int) -> CGFloat{
        
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(customLayout:minimumLineSpacingAt:))))! {
            let res = self.delegate!.customLayout!(customLayout: self, minimumLineSpacingAt: section)
            return res;
        }
        return self.lineSpacing!;
    }
    
    private func interitemSpacingForSection(_ section:Int) -> CGFloat{
        
        
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(customLayout:minimumInteritemSpacingAt:))))! {
            let res = self.delegate!.customLayout!(customLayout: self, minimumInteritemSpacingAt: section);
            return res
        }
        return self.interitemSpacing!;
    }
    
    private func contentInsetForSection(_ section:Int) -> UIEdgeInsets{
        
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(customLayout:contentInsetForSection:))))! {
            let res = self.delegate!.customLayout!(customLayout: self, contentInsetForSection: section)
            return res
        }
        return self.contentInset!
    }
    
    
    
    public func caculateContentSize() -> CGSize?{
        _offsetRow = 0
        _offsetX = self.contentInset!.left
        _offsetY = 0
        _lastItemHeight = 0
        _lastFooterHeight = 0
        _lastHeaderHeight = 0
        
        let numberOfSections = self.collectionView!.numberOfSections
        for section in 0...numberOfSections-1 {
            let numberOfItems:Int = self.numberOfItemInsection(section)!
            var subArr:Array<UICollectionViewLayoutAttributes> = Array<UICollectionViewLayoutAttributes>()
            for item in 0...numberOfItems-1 {
                let indexPath:IndexPath = IndexPath.init(item: item, section: section)
                
                if item == 0 {
                    let size:CGSize = self.sectionHeaderViewSizeAtIndexPath(indexPath)!
                    if size.height > 0 {
                        let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath)!
                        subArr.append(headerAttributes)
                    } else {
                       _lastHeaderHeight = 0
                    }
                }
                
                let attributes:UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: indexPath)!
                subArr.append(attributes)
                
                if item == numberOfItems - 1 {
                    let size:CGSize = self.sectionFooterViewSizeAtIndexPath(indexPath)!
                    if size.height > 0 {
                        let footerAttributes:UICollectionViewLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: indexPath)!
                        subArr.append(footerAttributes)
                        
                        _lastItemHeight = 0
                        _lastFooterHeight = 0
                    } else {
                        _lastFooterHeight = 0
                    }
                }
            }
        }
        
        let size:CGSize = CGSize(width: self.collectionView!.frame.size.width, height: _offsetY+_lastItemHeight + _lastFooterHeight + _lastHeaderHeight+self.contentInset!.bottom+self.lineSpacing!)
        
        _offsetRow = 0
        _offsetX = self.contentInset!.left
        _offsetY = 0
        _lastItemHeight = 0
        _lastFooterHeight = 0
        _lastHeaderHeight = 0
        
        return size
    }
    
    private func numberOfItemInsection(_ section:Int) -> Int?{
        if (self.delegate?.responds(to: #selector(SFCustomCollectionViewLayoutDelegate.customLayout(customLayout:numberOfItemsIn:))))! {
            let res = self.delegate!.customLayout!(customLayout: self, numberOfItemsIn: section)
            return res
        }
        return 0
    }
    
}

//
//  PassbookLayout.swift
//  PassbookLayout
//
//  Created by 田程元 on 15/3/23.
//  Copyright (c) 2015年 田程元. All rights reserved.
//

import UIKit
struct PassMetrics {
    /// Size of a state of a pass
    var size:CGSize
    
    /// Amount of "pixels" of overlap between this pass and others.
    var overlap:CGFloat
}
struct PassbookLayoutMetrics{
    /// Normal is the real size of the pass, the "full screen" display of it.
    var normal:PassMetrics
    
    /// Collapsed is when
    var collapsed:PassMetrics
    
    /// The size of the bottom stack when a pass is selected and all others are stacked at bottom
    var bottomStackedTotalHeight:CGFloat
    
    /// The visible size of each cell in the bottom stack
    var bottomStackedHeight:CGFloat
}
struct PassbookLayoutEffects{
    /// How much of the pulling is translated into movement on the top. An inheritance of 0 disables this feature (same as bouncesTop)
    var inheritance:CGFloat
    
    /// Allows for bouncing when reaching the top
    var bouncesTop:Bool
    
    /// Allows the cells get "stuck" on the top, instead of just scrolling outside
    var sticksTop:Bool
}
class PassbookLayout: UICollectionViewLayout {
    var metrics:PassbookLayoutMetrics = PassbookLayoutMetrics(normal: PassMetrics(size: CGSizeMake(320.0, 420.0), overlap: 0.0), collapsed: PassMetrics(size: CGSizeMake(320.0, 96.0), overlap: 32.0), bottomStackedTotalHeight: 32.0, bottomStackedHeight: 8.0)
    var effects:PassbookLayoutEffects = PassbookLayoutEffects(inheritance: 0.20, bouncesTop: true, sticksTop: true)
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        
        var attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        var selectedIndexPaths = (self.collectionView?.indexPathsForSelectedItems())! as NSArray
        if (selectedIndexPaths.count>0 && selectedIndexPaths[0] as NSIndexPath == indexPath)
        {
            // Layout selected cell (normal size)
            attributes.frame = frameForSelectedPass((collectionView?.bounds)!, m: metrics)
        }else if (selectedIndexPaths.count>0){
            // Layout unselected cell (bottom-stuck)
            attributes.frame  = frameForUnselectedPass(indexPath, indexPathSelected:selectedIndexPaths[0] as NSIndexPath,b:(collectionView?.bounds)!, m:metrics)
        }
        else{
            // Layout collapsed cells (collapsed size)
            var isLast:Bool = (indexPath.item == (collectionView?.numberOfItemsInSection(indexPath.section))!-1)
            attributes.frame = frameForPassAtIndex(indexPath, isLastCell: isLast, b: (collectionView?.bounds)!, m: metrics, e: effects)
        }
        attributes.zIndex = zIndexForPassAtIndex(indexPath)
        return attributes
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var range = rangeForVisibleCells(rect, count: (collectionView?.numberOfItemsInSection(0))! , m: metrics)
        
        // Uncomment to see the current range
        //NSLog(@"Visible range: %@", NSStringFromRange(range));
        
        var cells = NSMutableArray(capacity: range.length)
        
        for (var index=0,item=range.location; item < (range.location + range.length); item++, index++)
        {
            cells[index] = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0))
        }
        
        return cells;
    }

    override func collectionViewContentSize() -> CGSize {
        return collectionViewSize((collectionView?.bounds)!, count: (collectionView?.numberOfItemsInSection(0))!, m: metrics)
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true;
    }
    
//MARK: - Postioning
    
//MARK: Cell visibility
    func rangeForVisibleCells(rect:CGRect,count:NSInteger,m:PassbookLayoutMetrics)->NSRange{
        var min:NSInteger = NSInteger(floor(rect.origin.y/(m.collapsed.size.height - m.collapsed.overlap)))
        var max:NSInteger = NSInteger(ceil((rect.origin.y + rect.size.height)/(m.collapsed.size.height - m.collapsed.overlap)))
        
        max = (max > count) ? count : max;
        
        min = (min < 0)     ? 0   : min;
        min = (min < max)   ? min : max;

        var r = NSMakeRange(min, max-min);
        
        return r;

    }
    func collectionViewSize(bounds:CGRect,count:NSInteger,m:PassbookLayoutMetrics )->CGSize{
        return CGSizeMake(bounds.size.width, CGFloat(count)*(m.collapsed.size.height-m.collapsed.overlap));
    }
    
//MARK: Cell positioning
    
    /// Normal collapsed cell, with bouncy animations on top
    func frameForPassAtIndex(indexPath:NSIndexPath,isLastCell:Bool,b:CGRect,m:PassbookLayoutMetrics,e:PassbookLayoutEffects)->CGRect{
        var f:CGRect = CGRectZero
        f.origin.x = (b.size.width - m.normal.size.width) / 2.0
        f.origin.y = CGFloat(indexPath.item)*(m.collapsed.size.height - m.collapsed.overlap)
        
        // The default size is the normal size
        f.size = m.collapsed.size
        
        if (b.origin.y < 0 && e.inheritance > 0.0 && e.bouncesTop)
        {
            // Bouncy effect on top (works only on constant invalidation)
            if (indexPath.section == 0 && indexPath.item == 0)
            {
                // Keep stuck at top
                f.origin.y      = b.origin.y * e.inheritance/2.0
                f.size.height   = m.collapsed.size.height - b.origin.y * (1 + e.inheritance)
            }
            else
            {
                // Displace in stepping amounts factored by resitatnce
                f.origin.y     -= b.origin.y * CGFloat(indexPath.item) * e.inheritance
                f.size.height  -= b.origin.y * e.inheritance
            }
        }
        else if (b.origin.y > 0)
        {
            // Stick to top
            if (f.origin.y < b.origin.y && e.sticksTop)
            {
                f.origin.y = b.origin.y
            }
        }
        
        // Edge case, if it's the last cell, display in full height, to avoid any issues.
        if (isLastCell)
        {
            f.size = m.normal.size
        }
        
        return f
    }
    
    /// Centered cell
    func frameForSelectedPass(b:CGRect,m:PassbookLayoutMetrics)->CGRect{
        var f:CGRect = CGRectZero
        f.size      = m.normal.size
        f.origin.x  =              (b.size.width  - f.size.width ) / 2.0
        f.origin.y  = b.origin.y + (b.size.height - f.size.height) / 2.0
        
        return f
    }
    
    /// Bottom-stack cell
    func frameForUnselectedPass(indexPath:NSIndexPath,indexPathSelected:NSIndexPath,b:CGRect,m:PassbookLayoutMetrics)->CGRect{
        var f:CGRect = CGRectZero
        
        f.size        = m.collapsed.size
        f.origin.x    = (b.size.width - m.normal.size.width) / 2.0
        f.origin.y    = b.origin.y + b.size.height - m.bottomStackedTotalHeight + m.bottomStackedHeight*CGFloat(indexPath.item - indexPathSelected.item)
        
        return f
    }
    
//MARK: z-index
    
    func zIndexForPassAtIndex(indexPath:NSIndexPath)->NSInteger
    {
        return indexPath.item
    }
    
//MARK: - Accessors
    func setMetrics(metrics:PassbookLayoutMetrics){
        self.metrics = metrics
        
        self.invalidateLayout()
    }

    func setEffects(effects:PassbookLayoutEffects){
        self.effects = effects
        
        self.invalidateLayout()
    }
}

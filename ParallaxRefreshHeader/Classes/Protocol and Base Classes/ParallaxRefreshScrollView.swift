//
//  ParallaxRefreshScrollView.swift
//  ParallaxHeader
//
//  Created by Igor on 20/06/2018.
//  Copyright © 2018 MagicLab. All rights reserved.
//

import Foundation
import UIKit
public class ParallaxRefreshScrollView: UITableView, ParallaxAndRefreshCompatible {
  var _parallaxHeader: ParallaxHeader? = nil
  public var parallaxHeader: ParallaxHeader {
    get {
      if let header = _parallaxHeader {
        return header
      }
      let header = ParallaxHeader()
      self.parallaxHeader = header
      return header
    }
    set(parallaxHeader) {
      _parallaxHeader = parallaxHeader
      _parallaxHeader!.scrollView = self
    }
  }
  
  public var topPullToRefresh: PullToRefresh? = nil
  
  public var bottomPullToRefresh: PullToRefresh? = nil
  
  public var normalizedContentOffset: CGPoint {
    get {
      let contentOffset = self.contentOffset
      let contentInset = self.effectiveContentInset
      
      let output = CGPoint(x: contentOffset.x + contentInset.left, y: contentOffset.y + contentInset.top)
      return output
    }
  }
  
  public var effectiveContentInset: UIEdgeInsets {
    get {
      if #available(iOS 11, *) {
        return adjustedContentInset
      } else {
        return contentInset
      }
    }
    
    set {
      if #available(iOS 11.0, *), contentInsetAdjustmentBehavior != .never {
        contentInset = newValue - safeAreaInsets
      } else {
        contentInset = newValue
      }
    }
  }
  
  public func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
    let view = pullToRefresh.refreshView
    var originY: CGFloat
    switch pullToRefresh.position {
    case .top:
      originY = -view.frame.size.height
    case .bottom:
      originY = contentSize.height
    }
    
    return CGRect(x: 0, y: originY, width: frame.width, height: view.frame.height)
  }
  
  public func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ()) {
    pullToRefresh.scrollView = self
    
    let view = pullToRefresh.refreshView
    
    switch pullToRefresh.position {
    case .top:
      removePullToRefresh(at: Position.top)
      topPullToRefresh = pullToRefresh;
    case .bottom:
      removePullToRefresh(at: Position.bottom);
      bottomPullToRefresh = pullToRefresh;
    }
    
    view.frame = defaultFrame(forPullToRefresh: pullToRefresh)
    
  }
  
}

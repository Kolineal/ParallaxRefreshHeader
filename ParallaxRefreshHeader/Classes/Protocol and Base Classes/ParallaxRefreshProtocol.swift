//
//  ParalaxRefreshProtocol.swift
//  ParallaxHeader
//
//  Created by Igor on 20/06/2018.
//  Copyright © 2018 MagicLab. All rights reserved.
//

import Foundation
import UIKit

public protocol ParallaxAndRefreshCompatible: NSObjectProtocol {
  var parallaxHeader: ParallaxHeader {get set}
  var topPullToRefresh: PullToRefresh? {get set}
  var bottomPullToRefresh: PullToRefresh? {get set}
  var normalizedContentOffset: CGPoint {get}
  var effectiveContentInset: UIEdgeInsets {get set}
  
  //optional
  func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect
  func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ())
  func refresher(at position: Position) -> PullToRefresh?//
  func removePullToRefresh(at position: Position)
  func removeAllPullToRefresh()
  func startRefreshing(at position: Position)
  func endRefreshing(at position: Position)
  func endAllRefreshing()
}

public extension ParallaxAndRefreshCompatible {
  
  func addPullToRefresh(_ pullToRefresh: PullToRefresh, action: @escaping () -> ()) {
    if !self.isKind(of: UIScrollView.self) {
      assertionFailure("The class coforming to ParallaxAndRefreshCompatible protocol is not a child of UIScrollView")
    }
    pullToRefresh.scrollView = self as? (UIScrollView & ParallaxAndRefreshCompatible)
    
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
  func defaultFrame(forPullToRefresh pullToRefresh: PullToRefresh) -> CGRect {
    if !self.isKind(of: UIScrollView.self) {
      assertionFailure("The class coforming to ParallaxAndRefreshCompatible protocol is not a child of UIScrollView")
    }
    let scrollView = self as! UIScrollView
    let view = pullToRefresh.refreshView
    var originY: CGFloat
    switch pullToRefresh.position {
    case .top:
      originY = -view.frame.size.height
    case .bottom:
      originY = scrollView.contentSize.height
    }
    
    return CGRect(x: 0, y: originY, width: scrollView.frame.width, height: view.frame.height)
  }
  public func refresher(at position: Position) -> PullToRefresh? {
    switch position {
    case .top:
      return topPullToRefresh
      
    case .bottom:
      return bottomPullToRefresh
    }
  }
  public func removePullToRefresh(at position: Position) {
    switch position {
    case .top:
      topPullToRefresh?.refreshView.removeFromSuperview()
      topPullToRefresh = nil
      
    case .bottom:
      bottomPullToRefresh?.refreshView.removeFromSuperview()
      bottomPullToRefresh = nil
    }
  }
  public func removeAllPullToRefresh() {
    removePullToRefresh(at: Position.top)
    removePullToRefresh(at: Position.bottom)
  }
  
  public func startRefreshing(at position: Position) {
    switch position {
    case .top:
      topPullToRefresh?.startRefreshing()
      
    case .bottom:
      bottomPullToRefresh?.startRefreshing()
    }
  }
  
  public func endRefreshing(at position: Position) {
    switch position {
    case .top:
      topPullToRefresh?.endRefreshing()
      
    case .bottom:
      bottomPullToRefresh?.endRefreshing()
    }
  }
  
  public func endAllRefreshing() {
    endRefreshing(at: Position.top)
    endRefreshing(at: Position.bottom)
  }

}

internal func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
  return UIEdgeInsets(
    top: lhs.top - rhs.top,
    left: lhs.left - rhs.left,
    bottom: lhs.bottom - rhs.bottom,
    right: lhs.right - rhs.right
  )
}

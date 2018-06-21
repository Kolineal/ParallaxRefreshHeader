//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit

public enum Position {
    
    case top, bottom
    
    var opposite: Position {
        switch self {
        case .top:
            return .bottom
        case .bottom:
            return .top
        }
    }
    
}

public class PullToRefresh: NSObject {
    
    open var position: Position = .top
    
    open var animationDuration: TimeInterval = 1
    open var hideDelay: TimeInterval = 0
    open var springDamping: CGFloat = 0.4
    open var initialSpringVelocity: CGFloat = 0.8
    open var animationOptions: UIViewAnimationOptions = [.curveLinear]
    open var shouldBeVisibleWhileScrolling: Bool = false
  open var headerOffset: CGFloat = 0 {
    didSet{
      scrollViewDefaultInsets.top = -headerOffset
    }
  }
    let refreshView: UIView
    var isEnabled: Bool = false {
        didSet{
            refreshView.isHidden = !isEnabled
            if isEnabled {
                addScrollViewObserving()
            } else {
                removeScrollViewObserving()
            }
        }
    }
    var action: (() -> Void)?
    
    weak var scrollView: (UIScrollView & ParallaxAndRefreshCompatible)? {
        willSet {
            removeScrollViewObserving()
        }
        didSet {
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                addScrollViewObserving()
            }
        }
    }
    
    fileprivate let animator: RefreshViewAnimator
    fileprivate var isObserving = false
    
    // MARK: - ScrollView & Observing
    
    fileprivate var scrollViewDefaultInsets: UIEdgeInsets = .zero
    fileprivate var previousScrollViewOffset: CGPoint = CGPoint.zero
    
    // MARK: - State
    
    open fileprivate(set) var state: State = .initial {
        willSet{
            switch newValue {
            case .finished:
                if shouldBeVisibleWhileScrolling {
                    sendRefreshViewToScrollView()
                }
            default: break
            }
        }
        didSet {
          switch state {
          case .loading:
            stateString = "loading"
          case .initial:
            stateString = "initial"
          case .finished:
            stateString = "finished"
          case .releasing(_):
            if stateString != "releasing"{
              stateString = "releasing"
            }
          default:
            stateString = "initial"
          }
          
            animator.animate(state)
            switch state {
            case .loading:
                if oldValue != .loading {
                    animateLoadingState()
                }
                
            case .finished:
                if isCurrentlyVisible {
                    animateFinishedState()
                } else {
                    scrollView?.contentInset = self.scrollViewDefaultInsets
                    state = .initial
                }
            case .releasing(progress: let value) where value < 0.1:
                state = .initial
            
            default: break
            }
            self.enableOppositeRefresher(state == .initial)
          switch state {
          case .loading:
            stateString = "loading"
          case .initial:
            stateString = "initial"
          case .finished:
            stateString = "finished"
          case .releasing(_):
            stateString = "releasing"
          default:
            stateString = "initial"
          }
        }
    }
  @objc public dynamic var stateString: NSString! = "initial"
    // MARK: - Initialization
    
    public init(refreshView: UIView, animator: RefreshViewAnimator, height: CGFloat, position: Position) {
        self.refreshView = refreshView
        self.animator = animator
        self.position = position
    }
    
    public convenience init(height: CGFloat = 40, position: Position = .top) {
        let refreshView = DefaultRefreshView()
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        refreshView.autoresizingMask = [.flexibleWidth]
        refreshView.frame.size.height = height
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView), height: height, position: position)
    }
  public func addRefreshAction(action: @escaping (() -> Void)) {
    self.action = action
  }
    deinit {
        scrollView?.removePullToRefresh(at: position)
        removeScrollViewObserving()
    }
}

// MARK: KVO
extension PullToRefresh {
    
    fileprivate struct KVO {
        
        static var context = "PullToRefreshKVOContext"
        
        enum ScrollViewPath {
            static let contentOffset = #keyPath(UIScrollView.contentOffset)
            static let contentInset = #keyPath(UIScrollView.contentInset)
            static let contentSize = #keyPath(UIScrollView.contentSize)
        }
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        previousScrollViewOffset.y = scrollView?.normalizedContentOffset.y ?? 0

        if (context == &KVO.context && keyPath == KVO.ScrollViewPath.contentOffset && object as? UIScrollView == scrollView) {

            var offset: CGFloat
            switch position {
            case .top:
                offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
//                offset += headerOffset
              
            case .bottom:
                if scrollView!.contentSize.height > scrollView!.bounds.height {
                    offset = scrollView!.contentSize.height - previousScrollViewOffset.y - scrollView!.bounds.height
                } else {
                    offset = scrollView!.contentSize.height - previousScrollViewOffset.y
                }
                if #available(iOS 11, *) {
                    offset += scrollView!.safeAreaInsets.top
                }
            }

            let refreshViewHeight = refreshView.frame.size.height
            switch offset {
            case (-headerOffset) where (state != .loading):
              state = .initial
            case (-refreshViewHeight - headerOffset)...(-headerOffset) where (state != .loading && state != .finished):
                state = .releasing(progress: (-offset - headerOffset) / refreshViewHeight)
                
            case -3000...(-refreshViewHeight - headerOffset):
                if state == .releasing(progress: 1) && scrollView?.isDragging == false {
                    state = .loading
                } else if state != .loading && state != .finished {
                    state = .releasing(progress: 1)
                }
            default:
              break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func addScrollViewObserving() {
        guard let scrollView = scrollView, !isObserving else {
            return
        }
        
        scrollView.addObserver(self, forKeyPath: KVO.ScrollViewPath.contentOffset, options: .initial, context: &KVO.context)
        isObserving = true
    }
    
    fileprivate func removeScrollViewObserving() {
        guard let scrollView = scrollView, isObserving else {
            return
        }
        
        scrollView.removeObserver(self, forKeyPath: KVO.ScrollViewPath.contentOffset, context: &KVO.context)
        isObserving = false
    }
    
}

// MARK: - Start/End Refreshin
extension PullToRefresh {
    
    func startRefreshing() {
        guard !isOppositeRefresherLoading, state == .initial, let scrollView = scrollView else {
            return
        }
        
        let topInset: CGFloat = {
            if #available(iOS 11, *) {
                return scrollView.safeAreaInsets.top
            }
            return 0
        }()
        
        var offsetY: CGFloat
        switch position {
        case .top:
            offsetY = -refreshView.frame.height - scrollViewDefaultInsets.top - topInset
        case .bottom:
            if scrollView.contentSize.height + refreshView.frame.height > scrollView.frame.height {
                offsetY = scrollView.contentSize.height
                    + refreshView.frame.height
                    + scrollViewDefaultInsets.bottom
                    - scrollView.bounds.height
            } else {
                offsetY = 0 - topInset
            }
        }
        state = .loading
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
    
    func endRefreshing() {
        if state == .loading {
            state = .finished
        }
    }
}

// MARK: - Animate scroll view
private extension PullToRefresh {
    
    var isOppositeRefresherLoading: Bool {
        guard let scrollView = scrollView, let oppositeRefresher = scrollView.refresher(at: position.opposite) else {
            return false
        }
        return oppositeRefresher.state != .initial
    }
    
    func enableOppositeRefresher(_ enable: Bool) {
        if let scrollView = scrollView, let oppositeRefresher = scrollView.refresher(at: position.opposite) {
            oppositeRefresher.isEnabled = enable
        }
    }
    
    func animateLoadingState() {
        guard !isOppositeRefresherLoading, let scrollView = scrollView else {
            return
        }
        action?()
    }
    
    func animateFinishedState() {
        self.state = .initial
    }
}

// MARK: - Helpers
private extension PullToRefresh {
    
    var isCurrentlyVisible: Bool {
        guard let scrollView = scrollView else { return false }
        
        return scrollView.normalizedContentOffset.y <= -scrollViewDefaultInsets.top
    }
    
    func bringRefreshViewToSuperview() {
        guard let scrollView = scrollView, let superView = scrollView.superview else { return }
        let frame = scrollView.convert(refreshView.frame, to: superView)
        refreshView.removeFromSuperview()
        superView.insertSubview(refreshView, aboveSubview: scrollView)
        refreshView.frame = frame
        refreshView.layoutSubviews()
    }
    
    func sendRefreshViewToScrollView() {
        refreshView.removeFromSuperview()
        guard let scrollView = scrollView else { return }
        scrollView.addSubview(refreshView)
        refreshView.frame = scrollView.defaultFrame(forPullToRefresh: self)
        scrollView.sendSubview(toBack: refreshView)
    }
    
}

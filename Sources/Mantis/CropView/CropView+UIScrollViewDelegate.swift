//
//  CropView+UIScrollViewDelegate.swift
//  Mantis
//
//  Created by Echo on 5/24/19.
//

import Foundation
import UIKit

extension CropView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainer
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.cropViewDidBeginCrop(self)
        viewModel.setTouchImageStatus()
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        // A resize event has begun via gesture on the photo (scrollview), so notify delegate
        delegate?.cropViewDidBeginResize(self)
        viewModel.setTouchImageStatus()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard !scrollView.subviews.isEmpty else {
            return
        }
        
        let subView = scrollView.subviews[0]
        
        let offsetX: CGFloat = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY: CGFloat = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.setBetweenOperationStatus()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
	        delegate?.cropViewDidEndResize(self)
        makeSureImageContainsCropOverlay()
        
        isManuallyZoomed = true
        viewModel.setBetweenOperationStatus()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            viewModel.setBetweenOperationStatus()
        }
    }
}

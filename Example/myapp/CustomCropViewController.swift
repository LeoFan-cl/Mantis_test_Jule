//
//  CustomCropViewController.swift
//  Mantis
//
//  Created by Jules on 2025-09-04.
//  Copyright © 2025 Echo Studio. All rights reserved.
//

import UIKit
import Mantis

class CustomCropViewController: CropViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [.clockwiseRotate, .reset, .ratio, .horizontallyFlip, .verticallyFlip]
        config.cropToolbarConfig.ratioCandidatesShowType = .alwaysShowRatioList
        config.cropViewConfig.builtInRotationControlViewType = .slideDial()

        config.ratioOptions = [.original, .square, .custom]
        config.addCustomRatio(byHorizontalWidth: 16, andHorizontalHeight: 9)
        config.addCustomRatio(byHorizontalWidth: 4, andHorizontalHeight: 3)
        config.addCustomRatio(byHorizontalWidth: 3, andHorizontalHeight: 4)
        config.addCustomRatio(byHorizontalWidth: 9, andHorizontalHeight: 16)

        self.config = config
    }
}

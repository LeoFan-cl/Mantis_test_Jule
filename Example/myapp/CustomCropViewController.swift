import UIKit
import Mantis

class CustomCropViewController: CropViewController {

    required init(config: Mantis.Config = Mantis.Config()) {
        var newConfig = config

        // Prevent the default ratio selector from being created, as our custom toolbar handles it.
        newConfig.cropToolbarConfig.includeFixedRatiosSettingButton = false

        // Set the rotation dial to the slide dial style from the screenshot
        newConfig.cropViewConfig.builtInRotationControlViewType = .slideDial()

        // Set the available ratios
        newConfig.ratioOptions = [.original, .square, .custom]
        newConfig.addCustomRatio(byHorizontalWidth: 9, andHorizontalHeight: 16)
        newConfig.addCustomRatio(byHorizontalWidth: 3, andHorizontalHeight: 4)
        newConfig.addCustomRatio(byHorizontalWidth: 4, andHorizontalHeight: 3)
        newConfig.addCustomRatio(byHorizontalWidth: 1, andHorizontalHeight: 1)
        newConfig.addCustomRatio(byHorizontalWidth: 16, andHorizontalHeight: 9)

        super.init(config: newConfig)
    }

    required init?(coder aDecoder: NSCoder) {
        // This is required by the compiler
        var newConfig = Mantis.Config()
        newConfig.cropToolbarConfig.includeFixedRatiosSettingButton = false
        newConfig.cropViewConfig.builtInRotationControlViewType = .slideDial()
        super.init(config: newConfig)
        // If you need to support storyboard instantiation, you might need to handle config differently.
    }

    override func viewDidLoad() {
        // Assign our custom toolbar before super.viewDidLoad() so the CropViewController uses it for setup.
        self.cropToolbar = MyCustomToolbar(frame: .zero)
        super.viewDidLoad()
    }
}

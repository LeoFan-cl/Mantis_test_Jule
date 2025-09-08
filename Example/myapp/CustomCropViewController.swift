import UIKit
import Mantis

// A custom button for displaying a ratio
fileprivate class RatioButton: UIButton {
    let ratio: RatioItemType

    init(ratio: RatioItemType) {
        self.ratio = ratio
        super.init(frame: .zero)

        let title = ratio.nameH
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.systemBlue, for: .selected)
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class MyCustomToolbar: UIView, CropToolbarProtocol {
    public var iconProvider: CropToolbarIconProvider?
    public weak var delegate: CropToolbarDelegate?
    public var config = CropToolbarConfig()

    private var ratioButtons: [RatioButton] = []
    private var resetButton: UIButton!
    private var slideDial: SlideDial!

    public func createToolbarUI(config: CropToolbarConfig) {
        self.config = config
        backgroundColor = .black

        guard let cropViewController = delegate as? CropViewController,
              let cropView = cropViewController.cropView else {
            return
        }

        // --- Create Slide Dial ---
        let slideDialConfig = SlideDialConfig()
        let slideDialViewModel = SlideDialViewModel()
        let slideRuler = SlideRuler(frame: .zero, config: slideDialConfig)
        slideDial = SlideDial(frame: .zero, config: slideDialConfig, viewModel: slideDialViewModel, slideRuler: slideRuler)
        slideDial.setupUI(withAllowableFrame: CGRect(x: 0, y: 0, width: 280, height: 60))

        slideDial.didUpdateRotationValue = { [weak cropView] angle in
            cropView?.rotate(by: angle)
        }

        slideDial.didFinishRotation = { [weak cropViewController, weak cropView] in
            guard let cropViewController = cropViewController, let cropView = cropView else { return }
            cropViewController.cropView.delegate?.cropViewDidEndResize(cropView)
        }

        // --- Create Ratio Selector ---
        let ratioScrollView = UIScrollView()
        ratioScrollView.showsHorizontalScrollIndicator = false

        let ratioStackView = UIStackView()
        ratioStackView.axis = .horizontal
        ratioStackView.spacing = 20

        let originalRatio = cropView.getImageHorizontalToVerticalRatio()

        let ratioManager = FixedRatioManager(type: .horizontal,
                                             originalRatioH: originalRatio,
                                             ratioOptions: cropViewController.config.ratioOptions,
                                             customRatios: cropViewController.config.customRatioItems.compactMap { $0 })

        ratioButtons.removeAll()
        for ratioItem in ratioManager.ratios {
            let button = RatioButton(ratio: ratioItem)
            button.addTarget(self, action: #selector(selectRatio(_:)), for: .touchUpInside)
            ratioStackView.addArrangedSubview(button)
            ratioButtons.append(button)
        }

        ratioScrollView.addSubview(ratioStackView)
        ratioStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratioStackView.topAnchor.constraint(equalTo: ratioScrollView.topAnchor),
            ratioStackView.bottomAnchor.constraint(equalTo: ratioScrollView.bottomAnchor),
            ratioStackView.leadingAnchor.constraint(equalTo: ratioScrollView.leadingAnchor),
            ratioStackView.trailingAnchor.constraint(equalTo: ratioScrollView.trailingAnchor),
            ratioStackView.heightAnchor.constraint(equalTo: ratioScrollView.heightAnchor)
        ])

        // --- Create Reset Button ---
        resetButton = createTextButton(withTitle: "Reset", andAction: #selector(reset))
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)

        // --- Create Bottom Toolbar ---
        let bottomToolbarStackView = UIStackView()
        bottomToolbarStackView.axis = .horizontal
        bottomToolbarStackView.distribution = .fillEqually

        let cancelButton = createIconButton(systemName: "xmark", andAction: #selector(cancel))
        let ccwButton = createIconButton(systemName: "arrow.counterclockwise", andAction: #selector(counterClockwiseRotate))
        let cwButton = createIconButton(systemName: "arrow.clockwise", andAction: #selector(clockwiseRotate))
        let doneButton = createIconButton(systemName: "checkmark", andAction: #selector(crop))

        bottomToolbarStackView.addArrangedSubview(cancelButton)
        bottomToolbarStackView.addArrangedSubview(ccwButton)
        bottomToolbarStackView.addArrangedSubview(cwButton)
        bottomToolbarStackView.addArrangedSubview(doneButton)

        // --- Main Layout ---
        let mainStackView = UIStackView(arrangedSubviews: [slideDial, ratioScrollView, resetButton, bottomToolbarStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 15

        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            slideDial.heightAnchor.constraint(equalToConstant: 60),
            ratioScrollView.heightAnchor.constraint(equalToConstant: 40)
        ])

        if let firstButton = ratioButtons.first {
            selectRatio(firstButton)
        }
    }

    @objc private func selectRatio(_ sender: RatioButton) {
        ratioButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
        let ratioValue = sender.ratio.ratioH
        delegate?.didSelectRatio(self, ratio: ratioValue)
    }

    public func handleFixedRatioSetted(ratio: Double) {
        for button in ratioButtons {
            button.isSelected = button.ratio.ratioH == ratio
        }
    }

    public func handleFixedRatioUnSetted() {
        ratioButtons.forEach { $0.isSelected = false }
    }

    public func handleCropViewDidBecomeResettable() {
        resetButton?.isEnabled = true
    }

    public func handleCropViewDidBecomeUnResettable() {
        resetButton?.isEnabled = false
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 220)
    }

    @objc private func reset() { delegate?.didSelectReset(self) }
    @objc private func cancel() { delegate?.didSelectCancel(self) }
    @objc private func counterClockwiseRotate() { delegate?.didSelectCounterClockwiseRotate(self) }
    @objc private func clockwiseRotate() { delegate?.didSelectClockwiseRotate(self) }
    @objc private func crop() { delegate?.didSelectCrop(self) }

    private func createTextButton(withTitle title: String, andAction action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func createIconButton(systemName: String, andAction action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    public func getRatioListPresentSourceView() -> UIView? { return nil }
    public func adjustLayoutWhenOrientationChange() {}

    public func updateRotationValue(angle: Angle) {
        slideDial.updateRotationValue(by: angle)
    }
}


public class CustomCropViewController: CropViewController {

    required public init(config: Mantis.Config = Mantis.Config()) {
        var newConfig = config

        newConfig.cropToolbarConfig.includeFixedRatiosSettingButton = false
        newConfig.cropViewConfig.showAttachedRotationControlView = false

        newConfig.ratioOptions = [.original, .square, .custom]
        newConfig.addCustomRatio(byHorizontalWidth: 9, andHorizontalHeight: 16)
        newConfig.addCustomRatio(byHorizontalWidth: 3, andHorizontalHeight: 4)
        newConfig.addCustomRatio(byHorizontalWidth: 4, andHorizontalHeight: 3)
        newConfig.addCustomRatio(byHorizontalWidth: 1, andHorizontalHeight: 1)
        newConfig.addCustomRatio(byHorizontalWidth: 16, andHorizontalHeight: 9)

        super.init(config: newConfig)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let myToolbar = cropToolbar as? MyCustomToolbar,
           let cropView = self.cropView {
            cropView.didUpdateRotation = { [weak myToolbar] angle in
                myToolbar?.updateRotationValue(angle: angle)
            }
        }
    }
}

//
//  Created for MuxSpacesUIKit.
//
//  Copyright © 2022 Mux, Inc.
//  Licensed under the MIT License.
//

import Combine
import UIKit

import MuxSpaces

class JoinSpaceViewController: UIViewController {

    var controlsStackView: UIStackView = UIStackView()

    var joinSpaceButton: UIButton = UIButton()

    var audioLabel: UILabel = UILabel()
    var audioToggle: UISwitch = UISwitch()
    var audioStackView: UIStackView = UIStackView()

    var audioOptionsLabel: UILabel = UILabel()
    var audioOptionsStackView: UIStackView = UIStackView()

    var targetActions: [TargetActionSender] = []

    var videoLabel: UILabel = UILabel()
    var videoToggle: UISwitch = UISwitch()
    var videoStackView: UIStackView = UIStackView()

    var captureDeviceSelectionLabel: UILabel = UILabel()
    var captureDeviceSelectionControl: UISegmentedControl = UISegmentedControl()

    var space: Space

    var cancellables: [AnyCancellable] = []

    @Published var cameraCaptureOptions: CameraCaptureOptions? = CameraCaptureOptions()
    @Published var audioCaptureOptions: AudioCaptureOptions? = AudioCaptureOptions()

    // MARK: Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not available.")
    }

    init(
        space: Space
    ) {
        self.space = space
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: Deinitialization

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = NSLocalizedString(
            "Join a Space",
            comment: "Join space title"
        )

        setupControlsStackView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func setupJoinSpaceButton() {
        joinSpaceButton.translatesAutoresizingMaskIntoConstraints = false
        joinSpaceButton.setTitle(
            NSLocalizedString(
                "Join Space",
                comment: "Button that triggers connecting and joining a space"
            ),
            for: .normal
        )
        joinSpaceButton.setTitleColor(
            .white,
            for: .normal
        )
        joinSpaceButton.titleLabel?.textAlignment = .center
        joinSpaceButton.tintColor = .systemBlue
        joinSpaceButton.addAction(
            UIAction(
                handler: { [weak self] _ in

                    guard let self = self else {
                        return
                    }

                    self.displayParticipantsViewController(
                        space: self.space,
                        audioCaptureOptions: self.audioCaptureOptions,
                        cameraCaptureOptions: self.cameraCaptureOptions
                    )
                }
            ),
            for: .touchUpInside
        )
    }

    func setupAudioEnablementControls() {
        audioLabel.text = NSLocalizedString(
            "Publish Audio?",
            comment: "Publish Audio Toggle Label"
        )
        audioLabel.font = UIFont.preferredFont(
            forTextStyle: .callout
        ).withSize(16.0)
        audioLabel.textColor = .label
        audioToggle.translatesAutoresizingMaskIntoConstraints = false
        audioToggle.isEnabled = true
        audioToggle.isOn = audioCaptureOptions != nil

        let targetAction = TargetActionSender { [weak self] sender in
            guard let self = self else { return }

            guard let toggle = sender as? UISwitch else { return }

            if toggle.isOn {
                self.audioCaptureOptions = AudioCaptureOptions()
            } else {
                self.audioCaptureOptions = nil
            }
        }
        audioToggle.addTarget(
            targetAction,
            action: #selector(targetAction.action(_:)),
            for: .valueChanged
        )
        targetActions.append(targetAction)

        audioStackView.axis = .horizontal
        audioStackView.distribution = .fillProportionally
        audioStackView.translatesAutoresizingMaskIntoConstraints = false
        audioStackView.spacing = 16.0
        audioStackView.backgroundColor = .secondarySystemGroupedBackground
        audioStackView.isLayoutMarginsRelativeArrangement = true
        audioStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8.0,
            leading: 24.0,
            bottom: 8.0,
            trailing: 24.0
        )
        audioStackView.layer.cornerRadius = 12.0

        audioStackView.addArrangedSubview(audioLabel)
        audioStackView.addArrangedSubview(audioToggle)
    }

    func setupVideoEnablementControls() {
        videoLabel.text = NSLocalizedString(
            "Publish Video?",
            comment: "Publish Video Toggle Label"
        )
        videoLabel.font = UIFont.preferredFont(
            forTextStyle: .callout
        ).withSize(16.0)
        videoLabel.textColor = .label
        videoToggle.translatesAutoresizingMaskIntoConstraints = false
        videoToggle.isEnabled = true
        videoToggle.isOn = cameraCaptureOptions != nil

        let targetAction = TargetActionSender {  [weak self] sender in
            guard let self = self else { return }

            guard let toggle = sender as? UISwitch else { return }

            if toggle.isOn {
                self.cameraCaptureOptions = CameraCaptureOptions()
            } else {
                self.cameraCaptureOptions = nil
            }
        }
        videoToggle.addTarget(
            targetAction,
            action: #selector(targetAction.action(_:)),
            for: .valueChanged
        )

        targetActions.append(targetAction)

        videoStackView.axis = .horizontal
        videoStackView.distribution = .fillProportionally
        videoStackView.translatesAutoresizingMaskIntoConstraints = false
        videoStackView.spacing = 16.0
        videoStackView.backgroundColor = .secondarySystemGroupedBackground
        videoStackView.isLayoutMarginsRelativeArrangement = true
        videoStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8.0,
            leading: 24.0,
            bottom: 8.0,
            trailing: 24.0
        )
        videoStackView.layer.cornerRadius = 12.0

        videoStackView.addArrangedSubview(videoLabel)
        videoStackView.addArrangedSubview(videoToggle)
    }

    func setupCameraPositionControls() {
        captureDeviceSelectionLabel.font = UIFont.preferredFont(
            forTextStyle: .callout
        )
        .withSize(16.0)

        captureDeviceSelectionLabel.text = NSLocalizedString(
            "Select Camera Position",
            comment: "Camera position selection control label"
        )

        captureDeviceSelectionControl.addTarget(
            self,
            action: #selector(handleCaptureDeviceSelectionControlValueChanged(_:)),
            for: .valueChanged
        )

        let segmentTitles = [
            NSLocalizedString("Front", comment: "Front camera position selection"),
            NSLocalizedString("Back", comment: "Back camera position selection"),
        ]

        for (index, segmentTitle) in segmentTitles.enumerated() {
            captureDeviceSelectionControl.insertSegment(
                withTitle: segmentTitle,
                at: index,
                animated: false
            )
        }

        captureDeviceSelectionControl.selectedSegmentIndex = 0

        $cameraCaptureOptions
            .map { return $0 == nil }
            .assign(
                to: \.isHidden,
                on: captureDeviceSelectionLabel
            )
            .store(in: &cancellables)

        $cameraCaptureOptions
            .map { return $0 == nil }
            .assign(
                to: \.isHidden,
                on: captureDeviceSelectionControl
            )
            .store(in: &cancellables)
    }

    func setupAudioOptionsControls() {
        audioOptionsLabel.font = UIFont.preferredFont(
            forTextStyle: .callout
        )
        .withSize(16.0)
        audioOptionsLabel.translatesAutoresizingMaskIntoConstraints = false
        audioOptionsLabel.text = NSLocalizedString(
            "Available Audio Options",
            comment: "Available audio options control label"
        )
        audioOptionsLabel.textColor = .label

        let options = [
            (
                NSLocalizedString(
                    "Echo Cancellation",
                    comment: "Echo cancellation label text"
                ),
                \AudioCaptureOptions.echoCancellation
            ),
            (
                NSLocalizedString(
                    "Noise Suppression",
                    comment: "Noise suppression label text"
                ),
                \AudioCaptureOptions.noiseSuppression
            ),
            (
                NSLocalizedString(
                    "Auto Gain Control",
                    comment: "Auto gain control label text"
                ),
                \AudioCaptureOptions.autoGainControl
            )
        ]

        audioOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        audioOptionsStackView.backgroundColor = .systemBackground
        audioOptionsStackView.alignment = .center
        audioOptionsStackView.axis = .vertical
        audioOptionsStackView.distribution = .equalSpacing
        audioOptionsStackView.spacing = 16.0
        audioOptionsStackView.isLayoutMarginsRelativeArrangement = true
        audioOptionsStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8.0,
            leading: 12.0,
            bottom: 8.0,
            trailing: 12.0
        )
        audioOptionsStackView.layer.cornerRadius = 12.0

        for option in options {
            let optionLabel = UILabel()
            optionLabel.text = option.0
            optionLabel.font = UIFont.preferredFont(
                forTextStyle: .callout
            ).withSize(16.0)
            optionLabel.textColor = .label

            let optionToggle = UISwitch()
            optionToggle.translatesAutoresizingMaskIntoConstraints = false
            optionToggle.isEnabled = true
            optionToggle.isOn = audioCaptureOptions?[keyPath: option.1] ?? false

            let targetAction = TargetActionSender { [weak self] (sender: AnyObject) in

                guard let self = self else { return }

                guard let toggle = sender as? UISwitch else { return }

                self.audioCaptureOptions?[keyPath: option.1] = toggle.isOn

            }

            optionToggle.addTarget(
                targetAction,
                action: #selector(targetAction.action(_:)),
                for: .valueChanged
            )

            targetActions.append(targetAction)

            let optionStackView = UIStackView()

            optionStackView.axis = .horizontal
            optionStackView.distribution = .fillProportionally
            optionStackView.translatesAutoresizingMaskIntoConstraints = false
            optionStackView.spacing = 16.0
            optionStackView.backgroundColor = .clear
            optionStackView.isLayoutMarginsRelativeArrangement = true
            optionStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: 0.0,
                leading: 2.0,
                bottom: 0.0,
                trailing: 2.0
            )
            optionStackView.layer.cornerRadius = 12.0

            optionStackView.addArrangedSubview(optionLabel)
            optionStackView.addArrangedSubview(optionToggle)

            audioOptionsStackView.addArrangedSubview(
                optionStackView
            )
        }

        $audioCaptureOptions
            .map { $0 == nil }
            .assign(
                to: \.isHidden,
                on: audioOptionsLabel
            )
            .store(in: &cancellables)

        $audioCaptureOptions
            .map { $0 == nil }
            .assign(
                to: \.isHidden,
                on: audioOptionsStackView
            )
            .store(in: &cancellables)
    }

    @objc func handleCaptureDeviceSelectionControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.cameraCaptureOptions?.specifier = .position(.front)
        case 1:
            self.cameraCaptureOptions?.specifier = .position(.back)
        default:
            self.cameraCaptureOptions?.specifier = .position(.front)
        }
    }

    func setupControlsStackView() {

        /// setup join space button
        setupJoinSpaceButton()

        /// setup audio controls
        setupAudioEnablementControls()

        /// setup video controls
        setupVideoEnablementControls()

        /// setup camera position
        setupCameraPositionControls()

        /// setup audio options position
        setupAudioOptionsControls()

        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.backgroundColor = .systemGroupedBackground
        controlsStackView.alignment = .center
        controlsStackView.axis = .vertical
        controlsStackView.distribution = .equalSpacing
        controlsStackView.spacing = 15.0
        controlsStackView.isLayoutMarginsRelativeArrangement = true
        controlsStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 12.0,
            leading: 12.0,
            bottom: 12.0,
            trailing: 12.0
        )
        controlsStackView.layer.cornerRadius = 12.0

        controlsStackView.addArrangedSubview(joinSpaceButton)
        controlsStackView.addArrangedSubview(audioStackView)
        controlsStackView.addArrangedSubview(audioOptionsLabel)
        controlsStackView.addArrangedSubview(audioOptionsStackView)
        controlsStackView.addArrangedSubview(videoStackView)
        controlsStackView.addArrangedSubview(captureDeviceSelectionLabel)
        controlsStackView.addArrangedSubview(captureDeviceSelectionControl)

        view.addSubview(
            controlsStackView
        )
        view.addConstraints([
            controlsStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            controlsStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            controlsStackView.widthAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor,
                constant: -64.0
            ),
            controlsStackView.heightAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.7
            ),
        ])
    }

    func displayParticipantsViewController(
        space: Space,
        audioCaptureOptions: AudioCaptureOptions?,
        cameraCaptureOptions: CameraCaptureOptions?
    ) {
        navigationController?.pushViewController(
            ParticipantsViewController(
                space: space,
                audioCaptureOptions: audioCaptureOptions,
                cameraCaptureOptions: cameraCaptureOptions
            ),
            animated: true
        )
    }

    @objc func keyboardWillShow(
       _ notification: NSNotification
    ) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }

        self.view.frame.origin.y -= keyboardSize.height / 2
    }

    @objc func keyboardWillHide(
        _ notification: NSNotification
    ) {
        self.view.frame.origin.y = 0
    }
}

extension JoinSpaceViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

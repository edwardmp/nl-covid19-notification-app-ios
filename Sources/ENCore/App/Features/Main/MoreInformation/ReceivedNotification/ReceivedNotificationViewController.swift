/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import ENFoundation
import Foundation
import SnapKit
import UIKit

/// @mockable
protocol ReceivedNotificationViewControllable: ViewControllable {}

final class ReceivedNotificationViewController: ViewController, ReceivedNotificationViewControllable, UIAdaptivePresentationControllerDelegate, Logging {

    // MARK: - Init

    init(listener: ReceivedNotificationListener, theme: Theme) {
        self.listener = listener

        super.init(theme: theme)
    }

    // MARK: - ViewController Lifecycle

    override func loadView() {
        self.view = internalView
        self.view.frame = UIScreen.main.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hasBottomMargin = true
        title = .moreInformationReceivedNotificationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapCloseButton(sender:)))

        internalView.contactButtonActionHandler = { [weak self] in
            if let url = URL(string: .coronaTestPhoneNumber), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self?.logError("Unable to open \(String.coronaTestPhoneNumber)")
            }
        }
    }

    // MARK: - Private

    private weak var listener: ReceivedNotificationListener?
    private lazy var internalView: ReceivedNotificationView = ReceivedNotificationView(theme: self.theme)

    @objc private func didTapCloseButton(sender: UIBarButtonItem) {
        listener?.receivedNotificationWantsDismissal(shouldDismissViewController: true)
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        listener?.receivedNotificationWantsDismissal(shouldDismissViewController: false)
    }
}

private final class ReceivedNotificationView: View {

    var contactButtonActionHandler: (() -> ())? {
        get { infoView.actionHandler }
        set { infoView.actionHandler = newValue }
    }

    private let infoView: InfoView

    // MARK: - Init

    override init(theme: Theme) {
        let config = InfoViewConfig(actionButtonTitle: .moreInformationReceivedNotificationButtonTitle,
                                    headerImage: .receivedNotificationHeader)
        self.infoView = InfoView(theme: theme, config: config)
        super.init(theme: theme)
    }

    // MARK: - Overrides

    override func build() {
        super.build()

        infoView.addSections([
            notificationExplanation(),
            situation(),
            measures(),
            doCoronaTest(),
            info(),
            complaints()
        ])

        addSubview(infoView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        infoView.snp.makeConstraints { (maker: ConstraintMaker) in
            maker.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    // MARK: - Private

    private func notificationExplanation() -> View {
        InfoSectionTextView(theme: theme,
                            title: .moreInformationReceivedNotificationNotificationExplanationTitle,
                            content: [String.moreInformationReceivedNotificationNotificationExplanationContent.attributed()])
    }

    private func complaints() -> View {
        let list: [String] = [
            .moreInformationComplaintsItem1,
            .moreInformationComplaintsItem2,
            .moreInformationComplaintsItem3,
            .moreInformationComplaintsItem4,
            .moreInformationComplaintsItem5
        ]
        let bulletList = NSAttributedString.bulletList(list, theme: theme, font: theme.fonts.body)

        return InfoSectionTextView(theme: theme,
                                   title: .moreInformationComplaintsTitle,
                                   content: bulletList)
    }

    private func situation() -> View {
        let list: [String] = [
            .moreInformationSituationStep1,
            .moreInformationSituationStep2,
            .moreInformationSituationStep3
        ]
        let bulletList = NSAttributedString.bulletList(list, theme: theme, font: theme.fonts.body)

        return InfoSectionTextView(theme: theme,
                                   title: .moreInformationSituationTitle,
                                   content: bulletList)
    }

    private func measures() -> View {
        let list: [String] = [
            .moreInformationNotificationMeasuresStep1,
            .moreInformationNotificationMeasuresStep2,
            .moreInformationNotificationMeasuresStep3
        ]
        let bulletList = NSAttributedString.bulletList(list, theme: theme, font: theme.fonts.body)

        return InfoSectionTextView(theme: theme,
                                   title: .moreInformationNotificationMeasuresTitle,
                                   content: bulletList)
    }

    private func doCoronaTest() -> View {
        InfoSectionTextView(theme: theme,
                            title: .moreInformationReceivedNotificationDoCoronaTestTitle,
                            content: String.moreInformationReceivedNotificationDoCoronaTestContent.attributedStrings())
    }

    private func info() -> View {
        let string = NSAttributedString.make(text: .moreInformationInfoTitle, font: theme.fonts.subhead, textColor: theme.colors.gray)
        return InfoSectionCalloutView(theme: theme, content: string)
    }
}

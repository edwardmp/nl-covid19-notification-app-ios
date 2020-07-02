/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Combine
import Foundation

enum ExposureDataError: Error, Equatable {
    case networkUnreachable
    case serverError
    case internalError
    case inactive(ExposureStateInactiveState)
    case notAuthorized
    case responseCached
}

/// @mockable
protocol ExposureDataControlling {

    // MARK: - Exposure Detection

    var lastExposure: ExposureReport? { get }
    var lastSuccessfulFetchDate: Date { get }
    func removeLastExposure() -> Future<(), Never>
    func fetchAndProcessExposureKeySets(exposureManager: ExposureManaging) -> AnyPublisher<(), ExposureDataError>

    // MARK: - Lab Flow

    func processPendingUploadRequests() -> AnyPublisher<(), ExposureDataError>
    func requestLabConfirmationKey() -> AnyPublisher<LabConfirmationKey, ExposureDataError>
    func upload(diagnosisKeys: [DiagnosisKey], labConfirmationKey: LabConfirmationKey) -> AnyPublisher<(), ExposureDataError>

    // MARK: - Misc

    func getMinimumiOSVersion() -> AnyPublisher<String?, ExposureDataError>
    func getiOSAppStoreURL() -> AnyPublisher<String?, ExposureDataError>
    func getiOSMinimumVersionMessage() -> AnyPublisher<String?, ExposureDataError>
}

protocol ExposureDataControllerBuildable {
    func build() -> ExposureDataControlling
}

protocol ExposureDataControllerDependency {
    var networkController: NetworkControlling { get }
    var storageController: StorageControlling { get }
}

private final class ExposureDataControllerDependencyProvider: DependencyProvider<ExposureDataControllerDependency>, ExposureDataOperationProviderDependency {

    // MARK: - ExposureDataOperationProviderDependency

    var networkController: NetworkControlling {
        return dependency.networkController
    }

    var storageController: StorageControlling {
        return dependency.storageController
    }

    // MARK: - Private Dependencies

    var operationProvider: ExposureDataOperationProvider {
        return ExposureDataOperationProviderBuilder(dependency: self).build()
    }
}

final class ExposureDataControllerBuilder: Builder<ExposureDataControllerDependency>, ExposureDataControllerBuildable {
    func build() -> ExposureDataControlling {
        let dependencyProvider = ExposureDataControllerDependencyProvider(dependency: dependency)

        return ExposureDataController(operationProvider: dependencyProvider.operationProvider,
                                      storageController: dependencyProvider.storageController)
    }
}

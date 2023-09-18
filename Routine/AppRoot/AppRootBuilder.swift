//
//  AppRootBuilder.swift
//  Routine
//
//  Created by 한현규 on 2023/09/14.
//

import ModernRIBs

protocol AppRootDependency: Dependency {
    
}


// MARK: - Builder

protocol AppRootBuildable: Buildable {
    func build() -> (launchRouter: LaunchRouting, urlHandler: URLHandler)
}

final class AppRootBuilder: Builder<AppRootDependency>, AppRootBuildable {

    override init(dependency: AppRootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> (launchRouter: LaunchRouting, urlHandler: URLHandler) {
                
        let component = AppRootComponent(dependency: dependency)
        let viewController = AppRootViewController()
                        
        let interactor = AppRootInteractor(presenter: viewController)
        
        let routineBuildable = RoutineHomeBuilder(dependency: component)
        let recordHomeBuildable = RecordHomeBuilder(dependency: component)
        let timerBuildable = TimerHomeBuilder(dependency: component)
        let profileBuildable = ProfileHomeBuilder(dependency: component)
        
        let router = AppRootRouter(
            interactor: interactor,
            viewController: viewController,
            routineHomeBuildable: routineBuildable,
            recordHomeBuildable: recordHomeBuildable,
            timerHomeBuildable: timerBuildable,
            profileHomeBuildable: profileBuildable
        )
        
        return (router , interactor)
    }
}

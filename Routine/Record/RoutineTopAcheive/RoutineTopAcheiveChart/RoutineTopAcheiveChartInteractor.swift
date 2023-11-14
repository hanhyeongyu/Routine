//
//  RoutineTopAcheiveChartInteractor.swift
//  Routine
//
//  Created by 한현규 on 11/13/23.
//

import Foundation
import ModernRIBs
import Combine

protocol RoutineTopAcheiveChartRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RoutineTopAcheiveChartPresentable: Presentable {
    var listener: RoutineTopAcheiveChartPresentableListener? { get set }
    func setChart(_ viewModels: [TopAcheiveChartViewModel])
}

protocol RoutineTopAcheiveChartListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

protocol RoutineTopAcheiveChartInteractorDependency{
    var topAcheives: ReadOnlyCurrentValuePublisher<[RoutineTopAcheiveModel]>{ get }
}

final class RoutineTopAcheiveChartInteractor: PresentableInteractor<RoutineTopAcheiveChartPresentable>, RoutineTopAcheiveChartInteractable, RoutineTopAcheiveChartPresentableListener {

    weak var router: RoutineTopAcheiveChartRouting?
    weak var listener: RoutineTopAcheiveChartListener?

    private let dependency: RoutineTopAcheiveChartInteractorDependency
    private var cancellables: Set<AnyCancellable>
    
    // in constructor.
    init(
        presenter: RoutineTopAcheiveChartPresentable,
        dependency: RoutineTopAcheiveChartInteractorDependency
    ) {
        self.dependency = dependency
        self.cancellables = .init()
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        
        dependency.topAcheives
            .receive(on: DispatchQueue.main)
            .sink { models in
                let viewModels = models.enumerated().map { index, model in
                    TopAcheiveChartViewModel(index: index, model)
                }
                
                self.presenter.setChart(viewModels)
            }
            .store(in: &cancellables)

    }

    override func willResignActive() {
        super.willResignActive()
        
        self.cancellables.forEach{ $0.cancel() }
        self.cancellables.removeAll()
    }
}



//let models = [
//    TopAcheiveChartModel(
//        title: "💊",
//        count: Int.random(in: 20...80),
//        tint: "#FFCCCCFF"
//    ),
//    TopAcheiveChartModel(
//        title: "🏃",
//        count: Int.random(in: 20...80),
//        tint: "#FFFFCCFF"
//    ),
//    TopAcheiveChartModel(
//        title: "💪",
//        count: Int.random(in: 20...80),
//        tint: "#E5CCFFFF"
//    ),
//    TopAcheiveChartModel(
//        title: "✍️",
//        count: Int.random(in: 20...80),
//        tint: "#FFCCE5FF"
//    ),
//    TopAcheiveChartModel(
//        title: "🚗",
//        count: Int.random(in: 20...80),
//        tint: "#CCFFFFFF"
//    ),
//    TopAcheiveChartModel(
//        title: "💧",
//        count: Int.random(in: 20...80),
//        tint: "#FFCCCCFF"
//    ),
//    TopAcheiveChartModel(
//        title: "📖",
//        count: Int.random(in: 20...80),
//        tint: "#C0C0C0FF"
//    ),
//    TopAcheiveChartModel(
//        title: "🏀",
//        count: Int.random(in: 20...80),
//        tint: "#FFE5CCFF"
//    ),
//    TopAcheiveChartModel(
//        title: "🍻",
//        count: Int.random(in: 20...80),
//        tint: "#CCFFCCFF"
//    ),
//]

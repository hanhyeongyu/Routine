//
//  AppRootComponent.swift
//  Routine
//
//  Created by 한현규 on 2023/09/18.
//

import Foundation
import ModernRIBs


final class AppRootComponent: Component<AppRootDependency> , RoutineHomeDependency, RecordHomeDependency, TimerHomeDependency, ProfileHomeDependency, CreateRoutineDependency, AppRootInteractorDependency{

    //MARK: ApplicationService
    let routineApplicationService: RoutineApplicationService
    let recordApplicationService: RecordApplicationService
    let timerApplicationService: TimerApplicationService
    
    //MARK: ReadModel
    private let routineReadModel: RoutineReadModelFacade
    private let repeatReadModel: RepeatReadModelFacade
    private let reminderReadModel: ReminderReadModelFacade
    
    private let timerReadModel: TimerReadModelFacade
    
    private let routineRecordReadModel: RoutineRecordReadModelFacade
    private let timerRecordReadModel: TimerRecordReadModelFacade
    
    
    //MAKR: Projection
    private let routineProjection: RoutineProjection
    private let recordProjection: RecordProjection
    private let timerProjection: TimerProjection
    
    //MARK: Repository
    let routineRepository: RoutineRepository
    let timerRepository: TimerRepository
    let recordRepository: RecordRepository
    
    
    
    lazy var createRoutineBuildable: CreateRoutineBuildable = {
        CreateRoutineBuilder(dependency: self)
    }()
    
   
    var startTimerBaseViewController: ViewControllable { rootViewController.topViewControllable } 
    private let rootViewController: ViewControllable
    
    
    init(
        dependency: AppRootDependency,
        viewController: ViewControllable
    ) {
        //Base Domain
        let appendOnlyStore = CDAppendOnlyStore()
        let eventStore = EventStoreImp(appendOnlyStore: appendOnlyStore)
        let snapshotRepository = CDSnapshotRepository()
        
        
        //Factory
        let routineFactory = CDRoutineFactory()
        let recordFactory = CDRecordFactory()
        let timerFactory = CDTimerFactory()
                
        //Service
        let routineService = RoutineService()
                
        //Projection
        routineProjection = try! RoutineProjection()        
        recordProjection = try! RecordProjection()
        timerProjection = try! TimerProjection()
        
        //ReadModel
        routineReadModel = try! RoutineReadModelFacadeImp()
        repeatReadModel = try! RepeatReadModelFacadeImp()
        reminderReadModel = try! ReminderReadModelFacadeImp()
                        
        timerReadModel = try! TimerReadModelFacadeImp()
        
        routineRecordReadModel = try! RoutineRecordReadModelFacadeImp()
        timerRecordReadModel = try! TimerRecordReadModelFacadeImp()
        
        //ApplicationService
        self.routineApplicationService = RoutineApplicationService(
            eventStore: eventStore,
            snapshotRepository: snapshotRepository,
            routineFactory: routineFactory,
            routineService: routineService
        )
        
        self.recordApplicationService = RecordApplicationService(
            eventStore: eventStore,
            snapshotRepository: snapshotRepository,
            recordFactory: recordFactory
        )                
        
        self.timerApplicationService = TimerApplicationService(
            eventStore: eventStore,
            snapshotRepository: snapshotRepository,
            timerFactory: timerFactory
        )
        
        //Repository
        self.routineRepository = RoutineRepositoryImp(
            routineReadModel: routineReadModel,
            repeatReadModel: repeatReadModel,
            recordReadModel: routineRecordReadModel,
            reminderReadModel: reminderReadModel
        )
                        
        self.timerRepository = TimerRepositoryImp(
            timerReadModel: timerReadModel,
            recordModel: timerRecordReadModel
        )
        
        self.recordRepository = RecordRepositoryImp(
            routineReadModel: routineReadModel,
            routineRecordReadMoel: routineRecordReadModel,
            timerRecordReadModel: timerRecordReadModel
        )
         
        self.rootViewController = viewController
        super.init(dependency: dependency)
    }
    
    

}

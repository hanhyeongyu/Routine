//
//  RoutineHomeInteractor.swift
//  Routine
//
//  Created by 한현규 on 2023/09/14.
//

import ModernRIBs
import Combine
import Foundation

protocol RoutineHomeRouting: ViewableRouting {
    func attachCreateRoutine()
    func detachCreateRoutine()
    
    func attachRoutineDetail(routineId: UUID, recordDate: Date)
    func detachRoutineDetail()
    
    func attachRoutineWeekCalendar()
    func attachRoutineList()
}

protocol RoutineHomePresentable: Presentable {
    var listener: RoutineHomePresentableListener? { get set }
}

protocol RoutineHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

protocol RoutineHomeInteractorDependency{
    var routineApplicationService: RoutineApplicationService{ get }
    var recordApplicationService: RecordApplicationService{ get }
    var routineRepository: RoutineRepository{ get }
}



final class RoutineHomeInteractor: PresentableInteractor<RoutineHomePresentable>, RoutineHomeInteractable, RoutineHomePresentableListener, AdaptivePresentationControllerDelegate {

    
    let presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    weak var router: RoutineHomeRouting?
    weak var listener: RoutineHomeListener?
    
    private let dependency : RoutineHomeInteractorDependency
    private var cancellables: Set<AnyCancellable>
    
    private var list : [RoutineListDto] = []
    private var date = Date()
    
    private var isCreate: Bool
    private var isDetail: Bool
    
    init(
        presenter: RoutineHomePresentable,
        dependency: RoutineHomeInteractorDependency
    ) {
        self.dependency = dependency
        self.cancellables = .init()
                
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        self.isDetail = false
        self.isCreate = false
        super.init(presenter: presenter)
        
        presenter.listener = self
        self.presentationDelegateProxy.delegate = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        Log.v("Routine Home DidBecome Active ✅")
        router?.attachRoutineWeekCalendar()
        router?.attachRoutineList()
    }
    
    override func willResignActive() {
        super.willResignActive()
    }
        
    
    func presentationControllerDidDismiss() {
        if isCreate{
            isCreate = false
            router?.detachCreateRoutine()
        }
        
        if isDetail{
            isDetail = false
            router?.detachRoutineDetail()
        }
    }
    
    //MARK: RoutineWeekCalendar
    func routineWeekCalendarDidTap(date: Date) {
        Task{ [weak self] in
            do{
                self?.date = date
                try await self?.dependency.routineRepository.fetchHomeList(date: date)
            }catch{
                Log.e("\(error)")
            }
        }
    }
    

    //MARK: RoutineList
    func routineListDidComplete(list: RoutineHomeListModel) {
        if list.recordId == nil{
            let command = CreateRecord(routineId: list.routineId, date: self.date)
            createRecord(command)
        }else{
            let command = SetCompleteRecord(recordId: list.recordId!, isComplete: !list.isComplete)
            setComplete(command)
        }
    }
            
    // MARK: CreateRoutine
    func createRoutineBarButtonDidTap() {                
        isCreate = true
        router?.attachCreateRoutine()
    }

    func createRoutineDismiss() {
        isCreate = false
        router?.detachCreateRoutine()
    }
        
    
    // MARK: RoutineDetail
    func routineListDidTapRoutineDetail(routineId: UUID) {
        Task{ [weak self] in
            guard let self = self else { return }
            do{
                try await dependency.routineRepository.fetchDetail(routineId)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.isDetail = true
                    self.router?.attachRoutineDetail(routineId: routineId, recordDate: self.date)
                }
            }catch{
                Log.e("\(error)")
            }
            
        }
    }
    
    func routineDetailCloseButtonDidTap() {
        isDetail = false
        self.router?.detachRoutineDetail()
    }
    
    func routineDetailDismiss() {
        isDetail = false
        self.router?.detachRoutineDetail()
    }
    
    
    private func createRecord(_ command: CreateRecord){
        Task{
            do{
                try await self.dependency.recordApplicationService.when(command)
                try await self.dependency.routineRepository.fetchLists()
            }catch{
                if let error = error as? ArgumentException{
                    Log.e(error.message)
                }else{
                    Log.e("UnkownError\n\(error)" )
                }
            }
        }
    }
    
    private func setComplete(_ command: SetCompleteRecord){
        Task{
            do{
                try await self.dependency.recordApplicationService.when(command)
                try await self.dependency.routineRepository.fetchLists()
            }catch{
                if let error = error as? ArgumentException{
                    Log.e(error.message)
                }else{
                    Log.e("UnkownError\n\(error)" )
                }
            }
        }
    }
}


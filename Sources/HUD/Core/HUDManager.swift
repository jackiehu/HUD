//
//  hudManager.swift
//  Show
//
//  Created by iOS on 2023/5/4.
//

import SwiftUI

public extension View {
    /// 添加popView控制器,需要弹窗的页面最外层添加
    func addHUD() -> some View {
        overlay(
            HUDContainerView()
        )
    }
}

public class HUDManager: ObservableObject {
    @Published var views: [AnyHUD] = []
    @Published var isPresent: Bool = false
    static let shared = HUDManager()
    private init() {}
}

public extension HUDManager {
    /// 收起最后一个hud
    func dismissLast() {
        performOperation(.removeLast)
    }
    /// 收起指定hud
    func dismiss(_ id: UUID) {
        performOperation(.remove(id: id))
    }
    /// 收起所有hud
    func dismissAll() {
        performOperation(.removeAll)
    }

}

extension HUDManager {
    /// 弹出hud
    func show(_ hud: AnyHUD, withStacking useStack: Bool = false) {
        performOperation(useStack ? .insertAndStack(hud) : .insertAndReplace(hud))
        let config = hud.setupConfig(HUDConfig())
        if config.autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.autoDismissTime) {
                self.dismiss(hud.id)
            }
        }
    }
}

extension HUDManager {
    var tops: [AnyHUD] {
        views.compactMap { now in
            if now.position == .top{
                return now
            }
            return nil
        }
    }
    var centers: [AnyHUD] {
        views.compactMap { now in
            if now.position == .center{
                return now
            }
            return nil
        }
    }
    var bottoms: [AnyHUD] {
        views.compactMap { now in
            if now.position == .bottom{
                return now
            }
            return nil
        }
    }
}

private extension HUDManager {
    
    func performOperation(_ operation: Operation) {
        DispatchQueue.main.async {
            self.updateOperationType(operation)
            self.views.perform(operation)
        }
    }
    
    func canBeInserted(_ hud: AnyHUD) -> Bool {
        !views.contains { current in
            current.id == hud.id
        }
    }
    
    func updateOperationType(_ operation: Operation) {
        switch operation {
            case .insertAndReplace, .insertAndStack:
            isPresent = true
            case .removeLast, .remove, .removeAllUpTo, .removeAll:
            isPresent = false
        }
    }
}

enum Operation {
    case insertAndReplace(AnyHUD), insertAndStack(AnyHUD)
    case removeLast, remove(id: UUID), removeAllUpTo(id: UUID), removeAll
}

fileprivate extension [AnyHUD] {
    mutating func perform(_ operation: Operation) {
        hideKeyboard()
        performOperation(operation)
    }
}

private extension [AnyHUD] {
    func canBeInserted(_ hud: AnyHUD) -> Bool {
        !contains { current in
            current.id == hud.id
        }
    }
}

private extension [AnyHUD] {

    func hideKeyboard() {
        KeyboardManager.hideKeyboard()
    }
    
    mutating func performOperation(_ operation: Operation) {
        switch operation {
        case .insertAndReplace(let popup):
            replaceLast(popup, if: canBeInserted(popup))
        case .insertAndStack(let popup):
            append(popup, if: canBeInserted(popup))
        case .removeLast:
            removeLast()
        case .remove(let id):
            removeAll(where: { $0.id == id })
        case .removeAllUpTo(let id):
            removeAllUpToElement(where: { $0.id == id })
        case .removeAll:
            removeAll()
        }
    }
}
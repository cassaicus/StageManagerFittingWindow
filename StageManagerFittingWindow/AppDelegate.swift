//
//  AppDelegate.swift
//  StageManagerFittingWindow
//
//  Created by ibis on 2022/11/13.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    func applicationDidFinishLaunching(_ notification: Notification) {
        //ドックからアイコンを消す
        NSApp.setActivationPolicy(.accessory)
        //ウィンドウを消す
        NSApp.windows.forEach{ $0.close() }
        //ステータスバーにアイコンを追加する
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        //アイコンに矢印を指定する
        let button = statusItem.button!
        button.image = NSImage(systemSymbolName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", accessibilityDescription: nil)
        //ステータスバーのアイコンをクリックした時のセレクターを指定
        button.action = #selector(popUpAction)
        //ステータスバーのアイコンをクリックした時のアクションを指定
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc func popUpAction(_ sender: NSStatusBarButton) {
        //ステータスバーのアイコンのクリック
        guard let event = NSApp.currentEvent else { return }
        if event.type == NSEvent.EventType.rightMouseUp {
            //右クリック
            //メニューの準備
            let menu = NSMenu()
            //メニュー一つ目にPreference
            menu.addItem(
                withTitle: NSLocalizedString("Preference", comment: "Show preferences window"),
                action: #selector(openSettingsWindow),
                keyEquivalent: ""
            )
            //メニュー２つ目にseparator
            menu.addItem(.separator())
            //メニュー３つ目にQuit
            menu.addItem(
                withTitle: NSLocalizedString("Quit", comment: "Quit app"),
                action: #selector(terminate),
                keyEquivalent: ""
            )
            //メニュー表示
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
            
            print("Right Click")
            return
        } else {
            //左クリック
            //ウィンドウのサイズと位置変更を関数で行う
            //デスクトップの大きさを　whdthSizeCall()　heighSizecall()　より獲得し関数に引き渡す
            //print(Int(globalGapSize))
            let pid = setWindow(setwidth: whdthDisplaySizeCall(),setheight: heighDisplaySizeCall(),gapSize: globalGapSize)
            //print(pid)
            if pid > 0 {
                Thread.sleep(forTimeInterval: 0.1)
                if checkWindow(pid: pid) == false {
                    print("OUT reSetSize")
                    reSetSize(pid: pid)
                }
            }
            print("Left Click")
            return
        }
    }
    
    @objc func  reSetSize(pid: Int){
        
        var infoVer: NSDictionary?
        
        guard
            let windowInfos = CGWindowListCopyWindowInfo([.optionAll], 0)
        else { return }
        
        for windowInfo in windowInfos as NSArray {
            if let info = windowInfo as? NSDictionary,
               info["kCGWindowOwnerName"] != nil,
               info["kCGWindowOwnerPID"] != nil,
               info["kCGWindowOwnerPID"]! as! Int == pid,
               info["kCGWindowIsOnscreen"] != nil,
               info["kCGWindowLayer"] != nil,
               info["kCGWindowLayer"] as! Int == 0
            {
                infoVer = info
                break
            }
        }
        
        guard
            let windowBounds = infoVer?["kCGWindowBounds"] as? NSDictionary,
            windowBounds["Width"] != nil,
            windowBounds["Height"] != nil
        else { return }
                
        //アクティブなウインドウを獲得
        guard
            let app = NSWorkspace.shared.runningApplications.first(where: { $0.isActive })
        else { return }
        //print("\(app)")
        //ウィンドウのプロセスの識別子を獲得
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        //ウィンドウのプロセスの識別子を数字獲得しpidに格納
        var pid: pid_t = -1
        _ = AXUIElementGetPid(appRef, &pid)
        //AXUIElementCopyAttributeValueでウィンドウの状態を獲得
        var value: AnyObject?
        _ = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        //状態を獲得出来たか判定
        guard
            let windowList = value as? [AXUIElement]
        else { return }
        //print ("windowList #\(windowList)")
        //一つ目のウィンドウの状態獲得出来たか判定
        guard
            windowList.first != nil
        else { return }

        let displayWidth = whdthDisplaySizeCall()
        let displayHeight = heighDisplaySizeCall()
        
        let windowWidth = windowBounds["Width"] as! Double
        let windowHeight = windowBounds["Height"] as! Double
        
        let sabun = (windowHeight - displayHeight) * windowWidth / windowHeight * 1.05
        let sabunhiku = Int(sabun)
        
        //ウィンドウのサイズ位置変更の準備
        var position : CFTypeRef
        var size : CFTypeRef
        //ウィンドウの左ギャップはglobalgapSizeより獲得
        var newPoint = CGPoint(x: globalGapSize, y: 0)
        //デスクトップの大きさを引数から入力　左ギャップ分小さくする
        var newSize = CGSize(width: windowWidth - Double(sabunhiku) , height: displayHeight)
        
        //ウィンドウの位置を　上は0px 左はギャップ分に移動
        position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
        AXUIElementSetAttributeValue(windowList.first!, kAXPositionAttribute as CFString, position);
        //ウィンドウの大きさを幅はギャップ分マイナス高さはデスクトップの高さに変更
        size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!
        AXUIElementSetAttributeValue(windowList.first!, kAXSizeAttribute as CFString, size);
        
    }
        
    @objc func checkWindow(pid: Int) -> Bool{
        
        var infoVer: NSDictionary?
        
        guard
            let windowInfos = CGWindowListCopyWindowInfo([.optionAll], 0)
        else { return true }
        
        for windowInfo in windowInfos as NSArray {
            if let info = windowInfo as? NSDictionary,
               info["kCGWindowOwnerName"] != nil,
               info["kCGWindowOwnerPID"] != nil,
               info["kCGWindowOwnerPID"]! as! Int == pid,
               info["kCGWindowIsOnscreen"] != nil,
               info["kCGWindowLayer"] != nil,
               info["kCGWindowLayer"] as! Int == 0
            {
                infoVer = info
                break
            }
        }
        
        guard
            let windowBounds = infoVer?["kCGWindowBounds"] as? NSDictionary,
            windowBounds["Width"] != nil,
            windowBounds["Height"] != nil
        else { return true }
                
        if heighDisplaySizeCall() < windowBounds["Height"]! as! Double {
            return false
        }else{
            return true
        }
    }
    
    @objc func whdthDisplaySizeCall() -> Double {
        //デスクトップの幅を獲得しDoubleで返す
        var displaySize: NSRect? = nil
        displaySize = NSScreen.main?.visibleFrame
        //成否判定Doubleで返す。失敗の場合は1200pxとする
        if let sizewhdth = displaySize?.width {
            return Double(sizewhdth)
        } else {
            return 1200.0
        }
    }
    
    @objc func heighDisplaySizeCall() -> Double {
        //デスクトップの高さを獲得しDoubleで返す
        var displaySize: NSRect? = nil
        displaySize = NSScreen.main?.visibleFrame
        //成否判定Doubleで返す。失敗の場合は800pxとする
        if let sizeheight = displaySize?.height {
            return Double(sizeheight)
        } else {
            return 800.0
        }
    }
    
    @objc func setWindow(setwidth: Double, setheight: Double, gapSize: Double) -> Int {
        //アクセシビリティの権限の確認
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        }
        //ウィンドウのサイズ位置変更の準備
        //アクティブなウインドウを獲得
        if let app = NSWorkspace.shared.runningApplications.first(where: { $0.isActive }) {
            //print("\(app)")
            //ウィンドウのプロセスの識別子を獲得
            let appRef = AXUIElementCreateApplication(app.processIdentifier)
            //ウィンドウのプロセスの識別子を数字獲得しpidに格納
            var pid: pid_t = -1
            _ = AXUIElementGetPid(appRef, &pid)
            //AXUIElementCopyAttributeValueでウィンドウの状態を獲得
            var value: AnyObject?
            _ = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
            //状態を獲得出来たか判定
            if let windowList = value as? [AXUIElement]{
                //print ("windowList #\(windowList)")
                //一つ目のウィンドウの状態獲得出来たか判定
                if windowList.first != nil{
                    //ウィンドウのサイズ位置変更の準備
                    var position : CFTypeRef
                    var size : CFTypeRef
                    let gapSizeInt = Int(gapSize)
                    //ウィンドウの左ギャップはglobalgapSizeより獲得
                    var newPoint = CGPoint(x: Double(gapSizeInt), y: 0)
                    //デスクトップの大きさを引数から入力　左ギャップ分小さくする
                    var newSize = CGSize(width: setwidth - Double(gapSizeInt), height: setheight)
                    //ウィンドウの位置を　上は0px 左はギャップ分に移動
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                    AXUIElementSetAttributeValue(windowList.first!, kAXPositionAttribute as CFString, position);
                    //ウィンドウの大きさを幅はギャップ分マイナス高さはデスクトップの高さに変更
                    size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!
                    AXUIElementSetAttributeValue(windowList.first!, kAXSizeAttribute as CFString, size);
                    return Int(pid)
                }
            }
        }
        return 0
    }

    @objc func openSettingsWindow() {
        //メニューでPreferenceが選択された時の処理
        print("showSettingsWindow")
        //macOS13ではshowSettingsWindowに変わったので判定処理
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        //SettingsWindow最前面に表示
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func terminate() {
        //メニューでQuitが選択された時の処理
        print("terminate")
        NSApp.terminate(self)
    }
}

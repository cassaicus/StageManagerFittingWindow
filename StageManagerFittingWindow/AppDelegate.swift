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
        //アイコンの設定
        buttonsSetting(statusItem:statusItem)
        
    }
    
    func buttonsSetting(statusItem: NSStatusItem){
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
        guard
            let event = NSApp.currentEvent
        else { return }
        
        if event.type == NSEvent.EventType.rightMouseUp {
            //右クリック
            //メニューの準備
            let menu = NSMenu()
            //メニュー1つ目にPreference
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
            
            //print("Right Click")
            return
        } else {
            //左クリック
            //アクセシビリティの権限の確認
            accessEnabled()
            //ウィンドウのサイズと位置変更を関数で行う
            //デスクトップの大きさを　whdthDisplaySizeCall()　heighDisplaySizeCall()　より獲得し関数に引き渡す 失敗はpid0を返す
            let pid = setWindow(setwidth: whdthDisplaySizeCall(),setheight: heighDisplaySizeCall(),gapSize: globalGapSize)
            //print(pid)
            if pid > 0 {
                //設定が反映するまでのインターバル
                Thread.sleep(forTimeInterval: 0.1)
                //ウインドウが大きすぎないかチェック
                //ウィンドウの高さがディスクトップより大きい時にreSetSizeする
                let windowWiHe = windowWiHe(pid: pid)
                if windowWiHe.windowHeight > heighDisplaySizeCall(){
                    //ウインドウを再設定する
                    reSetSize(displayWidth: whdthDisplaySizeCall(),displayHeight: heighDisplaySizeCall(),gapSize: globalGapSize)
                }
            }
            //print("Left Click")
            return
        }
    }
    
   func accessEnabled() {
        //アクセシビリティの権限の確認
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        }
    }

    func whdthDisplaySizeCall() -> Double {
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
    
    func heighDisplaySizeCall() -> Double {
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
    
    func setWindow(setwidth: Double, setheight: Double, gapSize: Double) -> Int {
        //ウィンドウのサイズ位置変更の準備
        //アクティブなウインドウを獲得
        guard
            let app = NSWorkspace.shared.runningApplications.first(where: { $0.isActive })
        else { return 0 }
        
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
        else { return 0 }
        //print ("windowList #\(windowList)")
        //一つ目のウィンドウの状態獲得出来たか判定
        guard
            windowList.first != nil
        else { return 0 }
        
        // ウィンドウの位置とサイズの変更
        setElement(setwidth: setwidth, setheight: setheight, gapSize: gapSize, windowList: windowList.first!)
        
        return Int(pid)
    }
    
    func setElement(setwidth: Double, setheight: Double, gapSize: Double, windowList: AXUIElement){
        //ウィンドウの位置変更の準備
        var setPosition : CFTypeRef
        //ウィンドウの左ギャップ設定
        var newPoint = CGPoint(x: gapSize, y: 0)
        //ウィンドウの位置を　上は0px 左はギャップ分　へ移動
        setPosition = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
        AXUIElementSetAttributeValue(windowList, kAXPositionAttribute as CFString, setPosition);
        
        //ウィンドウのサイズ変更の準備
        var setSize : CFTypeRef
        //デスクトップの大きさを引数から入力　左ギャップ分小さくする
        var newSize = CGSize(width: setwidth - gapSize, height: setheight)
        //ウィンドウの大きさを幅はギャップ分マイナス高さはデスクトップの高さに変更
        setSize = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!
        AXUIElementSetAttributeValue(windowList, kAXSizeAttribute as CFString, setSize);
    }
        
    
    func windowWiHe(pid: Int) -> (windowWidth:Double,windowHeight:Double){
        //forを抜けた時ようの変数
        var infoVar: NSDictionary?
        //WindowInfoを全て獲得
        guard
            let windowInfos = CGWindowListCopyWindowInfo([.optionAll], 0)
        else { return (0.0, 0.0) }
        //WindowInfosからNSDictionaryで１つ１つforで取り出す
        for windowInfo in windowInfos as NSArray {
            //下記の条件に一致すれば該当のウインドウだと思われinfoVarにコピーしてbreak
            if let info = windowInfo as? NSDictionary,
               info["kCGWindowOwnerName"] != nil,
               info["kCGWindowOwnerPID"] != nil,
               info["kCGWindowOwnerPID"]! as! Int == pid,
               info["kCGWindowIsOnscreen"] != nil,
               info["kCGWindowLayer"] != nil,
               info["kCGWindowLayer"] as! Int == 0
            {
                infoVar = info
                break
            }
        }
        //windowInfo内の入れ子のNSDictionary　["kCGWindowBounds"]　を取り出す
        guard
            let windowBounds = infoVar?["kCGWindowBounds"] as? NSDictionary,
            windowBounds["Width"] != nil,
            windowBounds["Height"] != nil
        else { return (0.0, 0.0) }
        //ウィンドウの縦横を取り出し　戻り値とする
        let windowWidth = windowBounds["Width"] as! Double
        let windowHeight = windowBounds["Height"] as! Double
        
        return (windowWidth,windowHeight)
    }
        
    
    func reSetSize(displayWidth: Double, displayHeight: Double, gapSize: Double){
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
        //ウインドウの大きさを獲得
        let windowWiHe = windowWiHe(pid: Int(pid))
        let windowWidth = windowWiHe.windowWidth
        let windowHeight = windowWiHe.windowHeight
        //ウインドウの縦横の比率で横幅から引く値を計算（調整5％大きくしているとうまく収まる）
        let sabun = (windowHeight - displayHeight) * windowWidth / windowHeight * 1.05
        let sabunhiku = Int(sabun)
        // ウィンドウの位置とサイズの変更　横幅から差分を引く
        setElement(setwidth: displayWidth - Double(sabunhiku) , setheight: displayHeight, gapSize: gapSize, windowList: windowList.first!)
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


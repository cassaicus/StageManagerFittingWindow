//
//  StageManagerFittingWindowApp.swift
//  StageManagerFittingWindow
//
//  Created by cassaicus on 2022/11/13.
//

import SwiftUI
//グローバル変数　settingWindow　と　AppDelegate　の間でギャプの値を共有
var globalGapSize: Double = 170.0

@main
struct StageManagerFittingWindowApp: App {
    
#if os(macOS)
    //AppDelegateを設定
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
#if os(macOS)
        Settings {
            //settingWindowの読み込み
            SettingsView()
        }
#endif
    }
}

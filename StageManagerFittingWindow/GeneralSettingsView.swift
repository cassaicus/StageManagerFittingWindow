//
//  GeneralSettingsView.swift
//  StageManagerFittingWindow
//
//  Created by cassaicus on 2022/11/13.
//

import SwiftUI

//SettingswindowのTabViewの子window
struct GeneralSettingsView: View {
    //SEnvironmentClassを設定する
    //@EnvironmentObject private var environment :EnvironmentClass
    //private var gapSize に初期値
    @State private var gapSize : Double = globalGapSize
    
    var body: some View {

        // フォーム
        Form {
            VStack() {
                //private var gapSize に　グローバル変数から代入
                //gapSize = environment.callGapSize()
                // スライドバー　100　から　250 範囲　gapSizeが変更される
                Slider(value: $gapSize, in: 100...250) {
                    Text("Gap Size (\(gapSize, specifier: "%.0f") pts)")
                }
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
        .onChange(of: gapSize) {
            // gapSizeが変更されるたびに値をglobalgapSizeに送る
            //environment.inGapSize(ingapSize: gapSize)
            newValue in
            globalGapSize = newValue
            //print("newValue = [\(newValue)]")
        }
    }
}

//
//  SettingsView.swift
//  StageManagerFittingWindow
//
//  Created by cassaicus on 2022/11/13.
//

import SwiftUI

//Settingswindow詳細はTabViewで表示
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}

//
//  DemosApp.swift
//  Demos
//
//  Created by Andy Ibanez on 9/15/21.
//

import SwiftUI

@main
struct DemosApp: App {
    @State private var selectedTab: Int = 1
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                Demo1View()
                    .tabItem {
                        Label {
                            Text("Demo1")
                        } icon: {
                            Image(systemName: "1.circle")
                        }
                    }
                    .tag(1)
                Demo2View()
                    .tabItem {
                        Label {
                            Text("Demo2")
                        } icon: {
                            Image(systemName: "2.circle")
                        }
                    }
                    .tag(2)
                Demo3View()
                    .tabItem {
                        Label {
                            Text("Demo3")
                        } icon: {
                            Image(systemName: "3.circle")
                        }
                    }
                    .tag(3)
                Demo4View()
                    .tabItem {
                        Label {
                            Text("Demo4")
                        } icon: {
                            Image(systemName: "4.circle")
                        }
                    }
                    .tag(4)
            }
        }
    }
}

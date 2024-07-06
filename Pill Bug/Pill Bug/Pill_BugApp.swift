//
//  Pill_BugApp.swift
//  Pill Bug
//
//  Created by Travis Domenic Ratliff on 6/27/24.
//

import SwiftUI
import SwiftData

@main
struct Pill_BugApp: App {
    @State private var localNotificationManager = LocalNotificationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(localNotificationManager)
                .modelContainer(for: [Patient.self, Medicine.self, Dose.self])
        }
    }
}

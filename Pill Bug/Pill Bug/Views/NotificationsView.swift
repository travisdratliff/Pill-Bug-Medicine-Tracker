//
//  NotificationsView.swift
//  Pill Bug
//
//  Created by Travis Domenic Ratliff on 7/6/24.
//

import SwiftUI
import SwiftData
import Foundation
import UserNotifications

struct NotificationsView: View {
    var patient: Patient
    @Environment(LocalNotificationManager.self) private var localNotificationManager
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(localNotificationManager.pendingRequests, id: \.identifier) { request in
                        if request.identifier.contains(patient.name) {
                            HStack {
                                Text(request.content.title)
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            localNotificationManager.removeRequest(withIdentifier: request.identifier)
                                        }
                                        .tint(.red)
                                    }
                                
                            }
                        }
                    }
                } header: {
                    Text("\(patient.name)'s notifications (swipe to delete)")
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle("Notifications")
            .onAppear {
                Task {
                    await localNotificationManager.getCurrentSettings()
                    await localNotificationManager.getPendingRequests()
                }
            }
        }
    }
}

//#Preview {
//    NotificationsView()
//}

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
    @Environment(LocalNotificationManager.self) private var localNotificationManager
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(localNotificationManager.pendingRequests, id: \.identifier) { request in
                        Text(request.content.title)
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    localNotificationManager.removeRequest(withIdentifier: request.identifier)
                                }
                                .tint(.red)
                            }
                    }
                } header: {
                    Text("Current notifications")
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        localNotificationManager.clearRequests()
                    } label: {
                        HStack {
                            Text("Delete All")
                            Image(systemName: "trash")
                                .font(.title2)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await localNotificationManager.getCurrentSettings()
                    await localNotificationManager.getPendingRequests()
                }
            }
        }
    }
}

#Preview {
    NotificationsView()
}

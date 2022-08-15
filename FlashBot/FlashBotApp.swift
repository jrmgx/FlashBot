//
//  FlashBotApp.swift
//  FlashBot
//
//  Created by Jerome Gangneux on 15/08/2022.
//

import SwiftUI

@main
struct FlashBotApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

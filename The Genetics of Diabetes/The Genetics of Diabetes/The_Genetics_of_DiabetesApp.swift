//
//  The_Genetics_of_DiabetesApp.swift
//  The Genetics of Diabetes
//
//  Created by David Nishimoto on 7/1/26.
//

import SwiftUI
import CoreData

@main
struct The_Genetics_of_DiabetesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CellTherapyPipelineView ()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

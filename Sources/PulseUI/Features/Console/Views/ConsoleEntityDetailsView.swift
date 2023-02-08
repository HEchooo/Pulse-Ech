// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

#if os(macOS)

import Foundation
import SwiftUI
import Pulse
import CoreData

struct ConsoleEntityDetailsView: View {
    let viewModel: ConsoleListViewModel
    @ObservedObject var router: ConsoleRouter
    @Binding var isVertical: Bool

    var body: some View {
        if let selection = router.selection {
            switch selection {
            case .entity(let objectID):
                makeDetails(for: objectID)
            case .occurence(let objectID, let occurence):
                if let entity = viewModel.entity(withID: objectID) {
                    ConsoleSearchResultView.makeDestination(for: occurence, entity: entity)
                }
            }
        }
    }

    @ViewBuilder
    private func makeDetails(for objectID: NSManagedObjectID) -> some View {
        if let entity = viewModel.entity(withID: objectID) {
            if let task = entity as? NetworkTaskEntity {
                NetworkInspectorView(task: task, toolbarItems: AnyView(toolbarItems))
            } else if let message = entity as? LoggerMessageEntity {
                if let task = message.task {
                    NetworkInspectorView(task: task, toolbarItems: AnyView(toolbarItems))
                } else {
                    ConsoleMessageDetailsView(message: message, toolbarItems: AnyView(toolbarItems))
                }
            }
        }
    }

    @ViewBuilder
    var toolbarItems: some View {
        Button(action: { isVertical.toggle() }, label: {
            Image(systemName: isVertical ? "square.split.2x1" : "square.split.1x2")
                .foregroundColor(.secondary)
        })
        .help(isVertical ? "Switch to Horizontal Layout" : "Switch to Vertical Layout")
        .buttonStyle(.plain)

        Button(action: { router.selection = nil }) {
            Image(systemName: "xmark")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

#endif

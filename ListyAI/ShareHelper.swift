//
//  ShareHelper.swift
//  ListyAI
//
//  Helper for formatting and sharing lists
//

import Foundation
import UIKit

struct ShareHelper {
    // MARK: - Format for Sharing (with emojis)

    static func formatForSharing(categories: [ListCategory]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let timestamp = dateFormatter.string(from: Date())

        var text = "📋 List-y Session - \(timestamp)\n\n"

        for category in categories {
            text += "\(category.emoji) \(category.name):\n"

            for item in category.items {
                text += "• \(item)\n"
            }

            text += "\n"
        }

        text += "---\nCaptured with List-y"

        return text
    }

    // MARK: - Format as Markdown

    static func formatAsMarkdown(categories: [ListCategory]) -> String {
        var markdown = "# Extracted Lists\n\n"

        for category in categories {
            markdown += "## \(category.name)\n\n"

            for item in category.items {
                markdown += "- \(item)\n"
            }

            markdown += "\n"
        }

        return markdown
    }

    // MARK: - Present Share Sheet

    static func presentShareSheet(text: String, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // For iPad
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        viewController.present(activityVC, animated: true)
    }
}

// MARK: - SwiftUI View Extension for Share Sheet

import SwiftUI

extension View {
    func shareSheet(isPresented: Binding<Bool>, text: String) -> some View {
        background(
            ShareSheetView(isPresented: isPresented, text: text)
        )
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let text: String

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let activityVC = UIActivityViewController(
                activityItems: [text],
                applicationActivities: nil
            )

            // For iPad
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = uiViewController.view
                popoverController.sourceRect = CGRect(
                    x: uiViewController.view.bounds.midX,
                    y: uiViewController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popoverController.permittedArrowDirections = []
            }

            activityVC.completionWithItemsHandler = { _, _, _, _ in
                isPresented = false
            }

            DispatchQueue.main.async {
                uiViewController.present(activityVC, animated: true)
            }
        }
    }
}

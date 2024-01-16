//
//  textField.swift
//  brazil-final-project
//
//  Created by Kevin Li on 11/26/23.
//

import Foundation
import SwiftUI

struct ExpandingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.calculatedHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ExpandingTextView

        init(_ textView: ExpandingTextView) {
            self.parent = textView
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.parent.calculatedHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        }
    }
}

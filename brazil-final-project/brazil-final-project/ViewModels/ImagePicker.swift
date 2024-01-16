//
//  ImagePicker.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/11/23.
//

import Foundation
import SwiftUI
import UIKit

extension UIImage {
    var filename: String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) ?? self.pngData() else {
            return nil
        }
        let filename = UUID().uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(filename)
        do {
            try imageData.write(to: fileURL)
            let fullFilename = fileURL.lastPathComponent
            return String(fullFilename.prefix(5)) + "..."
        } catch {
            print("Error writing image data to disk: \(error.localizedDescription)")
            return nil
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isImagePickerPresented: Bool
    @Binding var truncatedFilename: String?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.truncatedFilename = uiImage.filename
            }

            parent.isImagePickerPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
       // picker.allowsEditing = true // Enable image cropping if we want
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

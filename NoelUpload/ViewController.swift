//
//  ViewController.swift
//  NoelUpload
//
//  Created by Franck WERNER on 6/19/19.
//  Copyright © 2019 FranckRJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageViewOfImageToUpload: UIImageView!
    @IBOutlet weak var labelForUploadInfo: UILabel!

    private func startUploadOfThisImage(_ imageToUpload: UIImage) {
        let request: URLRequest

        do {
            request = try ImageUploadRequestBuilder.buildRequest(imageToUpload)
        } catch {
            labelForUploadInfo.text = error.localizedDescription
            return
        }

        labelForUploadInfo.text = "En cours d'upload..."
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.labelForUploadInfo.text = "Erreur : " + (error?.localizedDescription ?? "Unknown error")
                }
                return
            }

            DispatchQueue.main.async {
                self.labelForUploadInfo.text = "Upload terminé, lien : " + String(data: data, encoding: .ascii)!
            }
        }
        task.resume()
    }

    @IBAction func selectImageTapped(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            labelForUploadInfo.text = "Erreur : l'image sélectionnée n'est pas valide."
            return
        }

        imageViewOfImageToUpload.image = selectedImage
        dismiss(animated: true, completion: nil)
        startUploadOfThisImage(selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let durationInSec: Double = 5
        let message = "Upload en cours... (dans le futur)"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + durationInSec) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageViewOfImageToUpload: UIImageView!
    @IBOutlet weak var labelForUploadInfo: UILabel!

    private func replaceFirstsOccurences(inStr: String, ofStr: String, byStr: String, nbOfOcc: Int) -> String {
        var str = inStr
        var currOcc = 0

        while currOcc < nbOfOcc, let range = str.range(of: ofStr) {
            str = str.replacingCharacters(in: range, with: byStr)
            currOcc += 1
        }

        return str
    }

    private func noelshackLinkToDirectLink(_ baseLink: String) -> String {
        var link = baseLink

        if let noelshackWordRange = link.range(of: "noelshack.com/") {
            link = String(link[noelshackWordRange.upperBound...])
        } else {
            return link
        }

        if link.starts(with: "fichiers/") || link.starts(with: "fichiers-xs/") || link.starts(with: "minis/") {
            link = String(link[link.index(after: link.index(of: "/")!)...])
        } else {
            link = replaceFirstsOccurences(inStr: link, ofStr: "-", byStr: "/", nbOfOcc: 2)
        }

        /* Moyen dégueulasse pour checker si le lien utilise le nouveau format (deux nombres entre l'année et le timestamp au lieu d'un). */
        if let lastSlashRange = link.range(of: "/", options: .backwards) {
            var checkForNewStringType = String(link[link.index(after: lastSlashRange.lowerBound)...])

            if let firstDashRange = checkForNewStringType.range(of: "-") {
                checkForNewStringType = String(checkForNewStringType[..<firstDashRange.lowerBound])

                if checkForNewStringType.range(of: "[0-9]{1,8}", options: .regularExpression) != nil {
                    link = replaceFirstsOccurences(inStr: link, ofStr: "-", byStr: "/", nbOfOcc: 1)
                }
            }
        }

        return "http://image.noelshack.com/fichiers/" + link
    }

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
                    self.labelForUploadInfo.text = "Erreur : " + (error?.localizedDescription ?? "Unknown error") + "."
                }
                return
            }

            DispatchQueue.main.async {
                let pasteBoard = UIPasteboard.general
                let link: String? = String(data: data, encoding: .ascii)

                if let link = link, link.starts(with: "http://") || link.starts(with: "https://") {
                    pasteBoard.string = self.noelshackLinkToDirectLink(link)
                    self.labelForUploadInfo.text = "Upload terminé, lien copié."
                } else {
                    self.labelForUploadInfo.text = "Erreur : " + (link ?? "lien invalide.")
                }
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
}

import UIKit

extension UIViewController {
    func alertAddAddress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            let textFieldText = alertController.textFields?.first
            guard let text = textFieldText?.text else { return }
            completionHandler(text)
        }
        alertController.addTextField { (texField) in
            texField.placeholder = placeholder
            texField.autocapitalizationType = .words
        }
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okButton)
        
        present(alertController, animated: true, completion: nil)
    }
}

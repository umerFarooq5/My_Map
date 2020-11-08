//
//  Extras .swift
//  My_Map
//
//  Created by umer malik on 30/10/2020.
//

import UIKit

extension UIViewController {
    func configureNavigationBar(withTitle title: String, prefersLargeTitles: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.yellow]
        appearance.backgroundColor = .black
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationItem.title = title
        
        navigationController?.navigationBar.barStyle = .default
        
        navigationController?.navigationBar.tintColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
    
    func showAlert(textToShow: String) {
        let alert = UIAlertController(title: "Error", message: textToShow, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

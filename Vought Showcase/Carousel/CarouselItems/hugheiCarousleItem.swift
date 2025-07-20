//
//  hugheiCarousleItem.swift
//  Vought Showcase
//
//  Created by DURGESH GANPAT JADHAV on 20/07/25.
//

import UIKit


final class HugheiCarouselItem: CarouselItem {
    private var viewController: UIViewController?
    
    /// Get controller
    /// - Returns: View controller
    func getController() -> UIViewController {
        // Check if view controller is already created
        // If not, create new view controller
        // else return the existing view controller
        guard let viewController = viewController else {
            viewController = ImageViewController(imageName: "hughei")
            return viewController!
        }
        return viewController
    }
}


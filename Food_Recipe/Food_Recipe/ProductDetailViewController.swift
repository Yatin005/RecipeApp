//
//  ProductDetailViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-04.
//

import UIKit

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel?
    
    @IBOutlet weak var descriptionTextview: UITextView!
    
    @IBOutlet weak var productImageView: UIImageView!
    
 
    var product: ProductDetail?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Details"
        updateUI()
    }

    private func updateUI() {
        if let product = self.product {
            titleLabel.text = product.title ?? "No Title"
            priceLabel?.text = "Price: \(product.price?.raw ?? "N/A")"
            if let discounted = product.discountedPrice?.raw {
                discountedPriceLabel.text = "Discounted Price: \(discounted)"
            } else {
                discountedPriceLabel.text = ""
            }
            descriptionTextview.text = product.description ?? "No Description"
            if let imageURLString = product.image, let imageURL = URL(string: imageURLString) {
                // Load image asynchronously (consider using an image caching library)
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.productImageView.image = image
                        }
                    }
                }.resume()
            } else {
                productImageView.image = nil
            }
        }
    }
}

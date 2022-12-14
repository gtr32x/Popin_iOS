//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import CoreImage.CIFilterBuiltins

class HandshakeViewController: UIViewController {
    var code: String!

    static func create(code: String) -> HandshakeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "HandshakeViewController") as! HandshakeViewController
        controller.code = code
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = Data(code.utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        let outputImage = filter.outputImage!
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 3, y: 3))
        let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent)!
        
        let qrCodeImageView = UIImageView()
        qrCodeImageView.frame = CGRect(x: 10, y: 10, width: 200, height: 200)
        self.view.addSubview(qrCodeImageView)
        
        qrCodeImageView.image = UIImage(cgImage: cgImage)
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

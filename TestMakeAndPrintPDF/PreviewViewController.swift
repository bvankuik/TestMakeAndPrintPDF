//
//  PreviewViewController.swift
//  TestMakeAndPrintPDF
//
//  Created by Bart van Kuik on 06/02/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController {

    private var webView: WKWebView!
    private var printButton: UIBarButtonItem!
    
    var pdfFile: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.printButton = UIBarButtonItem(title: "Print", style: .plain, target: self, action: #selector(print))
        self.navigationItem.rightBarButtonItem = self.printButton
        
        self.webView = WKWebView()
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        
        //
        
        let viewDict: [String: AnyObject] = [
            "webView": self.webView,
            "top": self.topLayoutGuide
        ]
        let layouts = [
            "H:|[webView]|",
            "V:[top][webView]|"
        ]
        for layout in layouts {
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: layout, options: [], metrics: nil, views: viewDict)
            self.view.addConstraints(constraints)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let path = self.pdfFile {
            let url = URL(fileURLWithPath: path)
            self.webView.load(URLRequest(url: url))
        } else {
            NSLog("Couldn't load PDF")
        }
    }

    func print() {
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = (self.webView.url?.absoluteString)!
        printInfo.duplex = .none
        printInfo.orientation = .portrait
        
        printController.printPageRenderer = nil
        printController.printingItems = nil
        printController.printingItem = webView.url!
        
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        
        printController.present(from: self.printButton, animated: true, completionHandler: nil)
    }

}

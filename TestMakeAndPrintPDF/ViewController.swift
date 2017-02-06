//
//  ViewController.swift
//  TestMakeAndPrintPDF
//
//  Created by Bart van Kuik on 06/02/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit
import WebKit

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

class ViewController: UIViewController, WKNavigationDelegate, DocumentOperations {
    
    private var webView: WKWebView!
    private var pdfFile: String?
    
    // MARK: - Private methods

    private func prepareHTML() -> String? {
        
        // Create Your Image tags here
        let tags = imageTags(filenames: ["report_logo.png"])
        var html: String?
        
        // html
        if let url = Bundle.main.resourceURL {
            
            // Images are stored in the app bundle
            html = generateHTMLString(imageTags: tags, baseURL: url.absoluteString)
        }
        
        return html
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("didFinishNavigation")

        if let content = prepareHTML() {
            let path = createPDF(html: content, formmatter: webView.viewPrintFormatter(), filename: "MyPDFDocument")
            print("PDF location: \(path)")
            self.pdfFile = path
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PreviewViewController" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.pdfFile = self.pdfFile
        }
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = WKWebView()
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.navigationDelegate = self
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

        // If this gives a sandbox error, check:
        // http://stackoverflow.com/a/25973953/1085556
        let path = Bundle.main.path(forResource: "test", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        self.webView.load(URLRequest(url: url))
    }

}


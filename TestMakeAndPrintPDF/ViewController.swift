//
//  ViewController.swift
//  TestMakeAndPrintPDF
//
//  Created by Bart van Kuik on 06/02/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var pdfFile: String?
    
    // MARK: - Private methods
    
    // From: https://gist.github.com/nyg/b8cd742250826cb1471f
    func saveToPDF() {
        let path = Bundle.main.path(forResource: "test", ofType: "html")
        
        let html: String!
        do {
            html = try String(contentsOfFile:path!, encoding: .utf8)
        } catch _ as NSError {
            NSLog("Error occurred loading path")
            return
        }
        
        
        // 1. Create a print formatter
        let fmt = UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        renderer.setValue(NSValue.init(cgRect: page), forKey: "paperRect")
        renderer.setValue(NSValue.init(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(), nil)
        
        for i in 1...renderer.numberOfPages {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            //renderer.drawPageAtIndex(i - 1, inRect: bounds)
            renderer.drawPage(at: i-1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        let outPath = "\(NSTemporaryDirectory())file.pdf"
        do {
            try pdfData.write(toFile: outPath, options: .atomic)
        } catch _ as NSError {
            NSLog("Error occurred writing PDF")
            return
        }
        self.pdfFile = outPath
        print("Saved to \(outPath)") // command to open the generated file
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("didFinishNavigation")
        self.saveToPDF()
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


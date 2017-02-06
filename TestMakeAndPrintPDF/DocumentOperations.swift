//
//  DocumentOperations.swift
//  TestMakeAndPrintPDF
//
//  Created by Bart van Kuik on 06/02/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit


// From:
// http://stackoverflow.com/a/40472190/1085556

protocol DocumentOperations {
    
    // Takes your image tags and the base url and generates a html string
    func generateHTMLString(imageTags: [String], baseURL: String) -> String
    
    // Uses UIViewPrintFormatter to generate pdf and returns pdf location
    func createPDF(html: String, formmatter: UIViewPrintFormatter, filename: String) -> String
    
    
    // Wraps your image filename in a HTML img tag
    func imageTags(filenames: [String]) -> [String]
}


extension DocumentOperations  {
    
    
    func imageTags(filenames: [String]) -> [String] {
        
        let tags = filenames.map { "<img src=\"\($0)\">" }
        
        return tags
    }
    
    
    func generateHTMLString(imageTags: [String], baseURL: String) -> String {
        
        // Example: just using the first element in the array
        var string = "<!DOCTYPE html><head><base href=\"\(baseURL)\"></head>\n<html>\n<body>\n"
        string = string + "\t<h2>PDF Document With Image</h2>\n"
        string = string + "\t\(imageTags[0])\n"
        string = string + "</body>\n</html>\n"
        
        return string
    }
    
    
    func createPDF(html: String, formmatter: UIViewPrintFormatter, filename: String) -> String {
        // From: https://gist.github.com/nyg/b8cd742250826cb1471f
        
        print("createPDF: \(html)")
        
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formmatter, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        for i in 1...render.numberOfPages {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        let path = "\(NSTemporaryDirectory())\(filename).pdf"
        pdfData.write(toFile: path, atomically: true)
        print("open \(path)")
        
        return path
    }
    
}

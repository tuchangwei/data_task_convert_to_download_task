//
//  ViewController.swift
//  URLSessionBackgroundDownload
//
//  Created by Sam Wang on 11/3/14.
//  Copyright (c) 2014 Sam Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var delegate = DownloadSessionDelegate.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        let data = getData()
        download(data)
    }
    
    //MARK: NSURLSession download in background
    func download(data: [String]!) {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
        let backgroundSession = NSURLSession(configuration: configuration, delegate: self.delegate, delegateQueue: nil)
        
        let url = NSURLRequest(URL: NSURL(string: data[1])!)
        //let downloadTask = backgroundSession.downloadTaskWithRequest(url)
        let downloadTask = backgroundSession.dataTaskWithRequest(url)
        downloadTask.resume()
    }
}


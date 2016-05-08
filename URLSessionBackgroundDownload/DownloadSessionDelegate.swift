//
//  DownloadSessionDelegate.swift
//  URLSessionBackgroundDownload
//
//  Created by Sam Wang on 11/4/14.
//  Copyright (c) 2014 Sam Wang. All rights reserved.
//

import Foundation

typealias CompleteHandlerBlock = () -> ()

class DownloadSessionDelegate : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate,NSURLSessionDataDelegate {
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    
    class var sharedInstance: DownloadSessionDelegate {
        struct Static {
            static var instance : DownloadSessionDelegate?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DownloadSessionDelegate()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
        }
        
        return Static.instance!
    }
    
    //MARK: session delegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("session error: \(error?.localizedDescription).")
    }
    
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
       completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
//        if let response = response as? NSHTTPURLResponse {
//            let contentType = response.allHeaderFields["Content-Type"] as! String
//            if contentType == "image/jpeg" {
//                //change the data task to download task
//                completionHandler(.BecomeDownload)
//                return
//            }
//        }
        completionHandler(.BecomeDownload)
       
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        print("\(session.configuration.identifier)")
        
        print("didBecomeDownloadTask....")
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
            print("session \(session) download completed")
        } else {
            print("session \(session) download failed with error \(error?.localizedDescription)")
        }
    }

    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("background session \(session) finished events.")
        
        if !session.configuration.identifier!.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        var handler : CompleteHandlerBlock = handlerQueue[identifier]!
        handlerQueue!.removeValueForKey(identifier)
        handler()
    }
}
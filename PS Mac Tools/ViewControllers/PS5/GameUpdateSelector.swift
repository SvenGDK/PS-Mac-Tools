//
//  GameUpdateSelector.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/01/2024.
//

import Cocoa
import WebKit

class GameUpdateSelector: NSViewController, WKNavigationDelegate, WKDownloadDelegate, URLSessionDelegate {
    
    @IBOutlet weak var PatchBrowserWebView: WKWebView!
    
    var GameUpdatesDelegate: GameUpdates? //Used to return the modifications to the main window
    var ProsperoPatchesURL: URL?
    var CurrentGameID: String?
    
    let JS: String = "document.getElementsByClassName('navbar navbar-expand-lg bd-navbar sticky-top')[0].style.display='none';document.getElementsByClassName('py-2')[0].style.display='none';document.getElementsByClassName('py-4')[0].style.display='none';document.getElementsByClassName('ms-2 fw-normal')[0].style.display='none';document.getElementsByClassName('nav-link flex-fill share-icon')[0-x].style.display='none';"
    let AdditionalJS: String = "var sharebuttons = document.getElementsByClassName('nav-link flex-fill share-icon');for (let sharebutton of sharebuttons) { sharebutton.style.display='none'; };"
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 800, height: 800)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PatchBrowserWebView.navigationDelegate = self
        PatchBrowserWebView.load(URLRequest(url: ProsperoPatchesURL!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        PatchBrowserWebView.evaluateJavaScript(JS)
        PatchBrowserWebView.evaluateJavaScript(AdditionalJS)
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            decisionHandler(.download)
        }
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
        
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        
        let DownloadURL: URL = response.url!
        var DownloadSize: String = ""
        FetchContentLength(for: response.url!, completionHandler: { (contentLength) in
            DownloadSize = self.SizeFormatter(FileSize: contentLength ?? 0)
        })
        
        let QueueAlert = NSAlert()
        QueueAlert.messageText = "Add to download queue ?"
        QueueAlert.addButton(withTitle: "Add")
        QueueAlert.addButton(withTitle: "Cancel")
        
        // Show the alert inside the popover view
        QueueAlert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                let NewDownloadQueueItem: DownloadQueueItem = DownloadQueueItem(GameID: self.CurrentGameID!, FileName: DownloadURL.lastPathComponent, FileSize: DownloadSize, DownloadURL: DownloadURL, DownloadState: "Not downloaded", DownloadProgress: 0, MergeState: "Not merged")
                // Add to download queue
                self.GameUpdatesDelegate!.AddQueueItem(QueueItem: NewDownloadQueueItem)
            }
        })
        
        // Cancel the download inside WKWebView
        completionHandler(nil)
    }
    
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("WebKit: \(error.localizedDescription)")
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        print("WebKit: Download finished!")
    }
    
    func FetchContentLength(for url: URL, completionHandler: @escaping (_ contentLength: UInt64?) -> ()) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  let contentLength = response.allHeaderFields["Content-Length"] as? String else {
                completionHandler(nil)
                return
            }
            completionHandler(UInt64(contentLength))
        }
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func SizeFormatter(FileSize: UInt64) -> String {
        let NewByteCountFormatter = ByteCountFormatter()
        NewByteCountFormatter.allowedUnits = [.useMB,.useGB]
        NewByteCountFormatter.countStyle = .file
        NewByteCountFormatter.isAdaptive = true
        return NewByteCountFormatter.string(fromByteCount: Int64(FileSize))
    }
    
}

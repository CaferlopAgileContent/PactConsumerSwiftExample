//
//  HTTPClient.swift
//  PactConsumerSwiftExample
//
//  Created by carlos fernandez on 29/1/21.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    @discardableResult
    func sendRequest(request: HTTPRequest, completion: @escaping(Result) -> Void) -> HTTPClientTask
}

public class HTTPClientService: NSObject {
    private var session: URLSession?
    public override init() {
        super.init()
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}

extension HTTPClientService: HTTPClient {
    public func sendRequest(request: HTTPRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let newRequest = request.asUrlRequest()
        let task = session?.dataTask(with: newRequest) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task?.resume()
        return URLSessionTaskWrapper(wrapped: task!)
    }
}


extension HTTPClientService: URLSessionDelegate {
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            (challenge.protectionSpace.host.contains("0.0.0.0") || challenge.protectionSpace.host.contains("localhost")),
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        
    }
}


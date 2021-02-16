//
//  PactConsumerSwiftExampleTests.swift
//  PactConsumerSwiftExampleTests
//
//  Created by carlos fernandez on 29/1/21.
//

import Foundation
import XCTest
import PactConsumerSwift
@testable import PactConsumerSwiftExample

class Pact_ios_testTests: XCTestCase {
    
    var providerMock: MockService?
    var apiClient: HTTPClientService?

    override func setUpWithError() throws {
        super.setUp()
        makeSUT()
    }

    override func tearDownWithError() throws {
       apiClient = nil
       providerMock = nil
        super.tearDown()
    }

    func testItSaysHello() throws {
        providerMock!.uponReceiving("A request from api request")
            .withRequest(method: .GET, path: "/sayHello")
            .willRespondWith(status: 200, headers: ["Content-Type": "application/json"], body: ["reply":"Hello"])
        
        providerMock!.run { [weak self] (testComplete) in
            let request = self!.makeRequest()
            _ = self!.apiClient?.sendRequest(request: request ) { result in
                switch result {
                case .success((let data, let httpresponse)):
                    let json  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : String]
                    XCTAssertTrue(json["reply"] == "Hello")
                    XCTAssertTrue(httpresponse.url?.absoluteString == "https://127.0.0.1:1234/sayHello")
                    XCTAssertTrue(httpresponse.statusCode == 200)
                    testComplete()
                case .failure(_):
                    break
                }
            }
            
        }
    }
    
    func makeSUT() {
        apiClient = HTTPClientService()
        let pactVerificationService = PactVerificationService(url: "https://127.0.0.1", port: 1234, allowInsecureCertificates: true)
        providerMock = MockService(provider: "Api Provider", consumer: "Api Consumer",pactVerificationService: pactVerificationService)
    }
    
    
    func makeRequest(file: StaticString = #file, line: UInt = #line) -> HTTPRequest {
        let dummyRequest = RequestStub(mockedService: self.providerMock!)
        return dummyRequest
    }
    
    
    struct RequestStub: HTTPRequest {
        private let mockedService: MockService
        
        public init(mockedService: MockService) {
            self.mockedService = mockedService
        }
        var url: URL {
            return URL(string: self.mockedService.baseUrl + "/sayHello")!
        }
    }
}




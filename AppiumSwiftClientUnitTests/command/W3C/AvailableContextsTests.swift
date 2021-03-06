//
//  AvailableContextsTests.swift
//  AppiumSwiftClientUnitTests
//
//  Created by kazuaki matsuo on 2018/12/31.
//  Copyright © 2018 KazuCocoa. All rights reserved.
//

import XCTest
import Mockingjay

@testable import AppiumSwiftClient

class AvailableContextsTests: AppiumSwiftClientTestBase {

    func testAvailableCOntexts() {
        let response = """
            {"value":["NATIVE_APP", "WEBVIEW"]}
        """.data(using: .utf8)!

        func matcher(request: URLRequest) -> Bool {
            if (request.url?.absoluteString == "http://127.0.0.1:4723/wd/hub/session/3CB9E12B-419C-49B1-855A-45322861F1F7/contexts") {
                XCTAssertEqual(HttpMethod.get.rawValue, request.httpMethod)
                return true
            } else {
                return false
            }
        }

        stub(matcher, jsonData(response, status: 200))
        let driver = try! AppiumDriver(AppiumCapabilities(super.iOSOpts))
        let contexts = try! driver.getAvailableContexts().get()
        XCTAssertEqual(contexts, ["NATIVE_APP", "WEBVIEW"])
        XCTAssertTrue(contexts.count == 2)
    }
}

//
//  ScreenshotTests.swift
//  AppiumSwiftClientUnitTests
//
//  Created by kazuaki matsuo on 2019/01/01.
//  Copyright © 2019 KazuCocoa. All rights reserved.
//

import XCTest
import Mockingjay

@testable import AppiumSwiftClient

class ScreenshotTests: AppiumSwiftClientTestBase {

    func testScreenshot() {
        let base64 = "iVBORw0KGgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAA"
        let response = """
            {"value":"\(base64)"}
        """.data(using: .utf8)!

        func matcher(request: URLRequest) -> Bool {
            if (request.url?.absoluteString == "http://127.0.0.1:4723/wd/hub/session/3CB9E12B-419C-49B1-855A-45322861F1F7/screenshot") {
                XCTAssertEqual(HttpMethod.get.rawValue, request.httpMethod)
                return true
            } else {
                return false
            }
        }
        stub(matcher, jsonData(response, status: 200))
        let driver = try! AppiumDriver(AppiumCapabilities(super.iOSOpts))
        XCTAssertEqual(try driver.getBase64Screenshot().get(), base64)
    }
}

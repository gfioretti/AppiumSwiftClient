//
//  DriverTest.swift
//  AppiumSwiftClientUnitTests
//
//  Created by kazuaki matsuo on 2018/11/09.
//  Copyright © 2018 KazuCocoa. All rights reserved.
//

import XCTest
import AppiumSwiftClient

class DriverTest : XCTestCase {
    func testDriverInitializationWithW3CFormat() {
        let opts = [
            DesiredCapabilitiesEnum.platformName: "iOS",
            DesiredCapabilitiesEnum.automationName: "xcuitest",
            DesiredCapabilitiesEnum.app: "path/to/test",
            DesiredCapabilitiesEnum.platformVersion: "11.4",
            DesiredCapabilitiesEnum.deviceName: "iPhone",
            ]
        let driver = AppiumDriver(AppiumCapabilities(opts))

        let expectedJson = """
        {
            "capabilities": {
                "firstMatch": [{
                    "appium:app": "path\\/to\\/test",
                    "automationName": "xcuitest",
                    "deviceName": "iPhone",
                    "platformName": "iOS",
                    "platformVersion": "11.4"
                }]
            },
            "desiredCapabilities": {
                "app": "path\\/to\\/test",
                "automationName": "xcuitest",
                "deviceName": "iPhone",
                "platformName": "iOS",
                "platformVersion": "11.4"
            }
        }
        """
        let trimmedExpectedJson = String(expectedJson.filter { !" \n\t\r".contains($0) })

        XCTAssertEqual(trimmedExpectedJson, driver.sessionId)
    }
}

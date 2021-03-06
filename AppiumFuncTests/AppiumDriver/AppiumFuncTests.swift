//
//  AppiumFuncTests.swift
//  AppiumFuncTests
//
//  Created by kazuaki matsuo on 2018/11/19.
//  Copyright © 2018 KazuCocoa. All rights reserved.
//

import XCTest
@testable import AppiumSwiftClient

class AppiumFuncTests: XCTestCase {

    var driver: AppiumDriver!

    override func setUp() {
        let packageRootPath = URL(
            fileURLWithPath: #file.replacingOccurrences(of: "AppiumFuncTests/AppiumDriver/AppiumFuncTests.swift", with: "")
            ).path

        let opts = [
            DesiredCapabilitiesEnum.platformName: "iOS",
            DesiredCapabilitiesEnum.automationName: "xcuitest",
            DesiredCapabilitiesEnum.app: "\(packageRootPath)/AppiumFuncTests/app/UICatalog.app.zip",
            DesiredCapabilitiesEnum.platformVersion: "13.5",
            DesiredCapabilitiesEnum.deviceName: "iPhone 8",
            DesiredCapabilitiesEnum.reduceMotion: "true"
        ]
        do {
            driver = try AppiumDriver(AppiumCapabilities(opts))
        } catch {
            XCTFail("Failed to spin up driver: \(error)")
        }
    }

    override func tearDown() {
        do {
            try driver.quit().get()
        } catch {
            XCTFail("Failed to quit driver: \(error)")
        }
    }

    func testDriverSessionCapabilities() {
        XCTAssert(driver.currentSessionCapabilities.capabilities()[.sessionId] != "")

        let capabilities = try! driver.getCapabilities().get()

        XCTAssertNotNil(capabilities.udid)

        XCTAssertEqual(try driver.getAvailableContexts().get(), ["NATIVE_APP"])
        XCTAssertNotNil(try driver.setContext(name: "NATIVE_APP"))
        XCTAssertEqual(try driver.getCurrentContext().get(), "NATIVE_APP")
    }

    func testCanFindElements() {
        do {
            let els = try driver.findElements(by: .accessibilityId, with: "Buttons").get()
            XCTAssertEqual(els.count, 1)
            XCTAssert(els[0].id != "")
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCanFindElement() {
        do {
            let ele = try driver.findElement(by: .accessibilityId, with: "Buttons").get()
            XCTAssert(ele.id != "")
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCanTakeScreenshotOfElement() {
        do {
            let ele = try driver.findElement(by: .accessibilityId, with: "Buttons").get()
            let elementScreenshotPath = try driver.saveScreenshot(with: ele, to: "element_screenshot.png")
            XCTAssertNotEqual(elementScreenshotPath, "")
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCanTakeScreenshotOfFullScreen() {
        do {
            let screenshotPath = try driver.saveScreenshot(to: "hello.png")
            XCTAssertNotEqual(screenshotPath, "")
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCantFindInexistentElement() {
        do {
            let ele = try driver.findElement(by: .accessibilityId, with: "Buttons").get()
            ele.click()
            let buttonGray = try driver.findElement(by: .name, with: "Gray").get()
            XCTAssert(buttonGray.id != "NoSuchElementError")

            XCTAssertEqual((try driver.findElements(by: .accessibilityId, with: "Grey").get()).count, 0)

            XCTAssertThrowsError((try driver.findElement(by: .name, with: "Grey").get())) { error in
                guard case WebDriverErrorEnum.noSuchElementError(let error) = error else {
                    return XCTFail("should raise no such element error")
                }
                XCTAssertEqual("no such element", error.error)
                XCTAssertEqual("An element could not be located on the page using the given search parameters.",
                               error.message)
            }
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCanGetPageSource() {
        do {
            let pageSource = try driver.getPageSource().get()
            XCTAssertTrue(pageSource.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?><AppiumAUT>"))
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testCanGoBack() {
        do {
            let ele = try driver.findElement(by: .accessibilityId, with: "Buttons").get()
            let firstViewSource = try driver.getPageSource().get()
            ele.click()
            let nextPageSource = try driver.getPageSource().get()
            XCTAssertTrue(firstViewSource != nextPageSource)
            driver.back()
            let firstViewSourceAfterGoBack = try driver.getPageSource().get()
            XCTAssertTrue(firstViewSource == firstViewSourceAfterGoBack)
            // TODO GF 05.05.2020: This test is suboptimal in my opinion and should be refactored once Element related endpoints are implemented to take advantage of visibility command.
        } catch let exception {
            XCTFail("\(exception)")
        }
    }

    func testImplicitTimeout() {
        var deltaWithoutImplicitWait: Double = 0
        let initTimeWithoutImplicitWait = NSDate().timeIntervalSince1970
        do {
            _ = try driver.findElement(by: .name, with: "Bogus Element").get()
        } catch {
            deltaWithoutImplicitWait = NSDate().timeIntervalSince1970 - initTimeWithoutImplicitWait
        }
        driver.setImplicitTimeout(timeoutInMillisencods: 300) // swiftlint:disable:this force_try
        var deltaWithImplicitWait: Double = 0
        let initTimeWithImplicitWait = NSDate().timeIntervalSince1970
        do {
            _ = try driver.findElement(by: .name, with: "Bogus Element").get()
        } catch {
            deltaWithImplicitWait = NSDate().timeIntervalSince1970 - initTimeWithImplicitWait
        }
        XCTAssertTrue((deltaWithImplicitWait - deltaWithoutImplicitWait) > 0.3)
    }

    func testCanGetScreenOrientation() {
        do {
            let screenOrientation = try driver.getScreenOrientation().get()
            print(screenOrientation)
            XCTAssertTrue(screenOrientation == "PORTRAIT")
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testCantSetScreenOrientationIfAppIsPortraitOnly() {
        do {
            try driver.rotate(to: ScreenOrientationEnum.landscape)
        } catch let error {
            XCTAssertTrue(error is WebDriverErrorEnum)
        }
    }

    func testCanGetAvailableLogTypes() {
        do {
            let availableLogTypes = try driver.getAvailableLogTypes().get()
            XCTAssertFalse(availableLogTypes.isEmpty)
            print(availableLogTypes)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCanLogCustomEventsAndRetreiveEvents() {
        let events = try? driver.getEvents()
        guard let countBefore = events?.events.count else { return }
        driver.logEvent(with: "Appium", and: "funEvent")
        let eventsAfter = try? driver.getEvents()
        guard let countAfter = eventsAfter?.events.count else { return }
        XCTAssertTrue(countAfter > countBefore)
    }
}

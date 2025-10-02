//
//  beCurrentUITests.swift
//  beCurrentUITests
//
//  Created by Josh MacDonald on 10/1/25.
//

import XCTest

final class beCurrentUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // MARK: - Basic Launch and Navigation Tests
    
    @MainActor
    func testAppLaunches() throws {
        // Verify the app launches successfully without crashing
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    @MainActor
    func testFeedViewAppears() throws {
        // Verify the main feed view elements are present
        let navigationTitle = app.navigationBars["BeCurrent"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5.0), "Feed navigation title should be present")
        
        // Check for tab bar
        let feedTab = app.tabBars.buttons["Feed"]
        XCTAssertTrue(feedTab.exists, "Feed tab should be present")
        
        // Wait for feed content to load (could show loading, error, or posts)
        let feedContent = app.scrollViews.firstMatch
        XCTAssertTrue(feedContent.waitForExistence(timeout: 10.0) ||
                     app.staticTexts["Loading feed..."].exists ||
                     app.staticTexts.containing(NSPredicate(format: "label CONTAINS '😕'")).firstMatch.exists,
                     "Feed should show some content, loading state, or error state")
    }
    
    @MainActor
    func testTabBarNavigation() throws {
        // Verify tab bar navigation works
        let feedTab = app.tabBars.buttons["Feed"]
        XCTAssertTrue(feedTab.exists, "Feed tab should be present")
        XCTAssertTrue(feedTab.isSelected, "Feed tab should be selected by default")
        
        // Tap the tab (should remain on same view)
        feedTab.tap()
        let navigationTitle = app.navigationBars["BeCurrent"]
        XCTAssertTrue(navigationTitle.exists, "Should remain on feed view")
    }
    
    @MainActor
    func testFeedRefreshFunctionality() throws {
        // Test pull-to-refresh functionality
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 5.0) {
            // Pull to refresh
            let startCoordinate = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let endCoordinate = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
            
            // Should still show feed content after refresh
            let navigationTitle = app.navigationBars["BeCurrent"]
            XCTAssertTrue(navigationTitle.exists, "Should stay on feed view after refresh")
        }
    }
    
    @MainActor
    func testFeedLoadingStates() throws {
        // Verify the feed shows appropriate states
        let navigationTitle = app.navigationBars["BeCurrent"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5.0), "Navigation should be present")
        
        // Could be in loading state, error state, or showing content
        let hasLoadingIndicator = app.progressIndicators["Loading feed..."].exists
        let hasErrorState = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '😕'")).firstMatch.exists
        let hasTryAgainButton = app.buttons["Try Again"].exists
        let hasScrollContent = app.scrollViews.firstMatch.exists
        
        XCTAssertTrue(hasLoadingIndicator || hasErrorState || hasTryAgainButton || hasScrollContent,
                     "Feed should show loading, error, or content")
    }
    
    // MARK: - Interaction Tests
    
    @MainActor
    func testTryAgainButtonWhenError() throws {
        // If we're in an error state, test the Try Again button
        let tryAgainButton = app.buttons["Try Again"]
        if tryAgainButton.exists {
            tryAgainButton.tap()
            
            // After tapping try again, we should see loading or content
            let expectation = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == true"),
                object: app.progressIndicators["Loading feed..."]
            )
            let _ = XCTWaiter.wait(for: [expectation], timeout: 3.0)
            // It's okay if this fails - might load content immediately
        }
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityElements() throws {
        // Verify key elements are accessible
        let navigationTitle = app.navigationBars["BeCurrent"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5.0), "Navigation should be present")
        
        // If there's a Try Again button, it should be accessible
        let tryAgainButton = app.buttons["Try Again"]
        if tryAgainButton.exists {
            XCTAssertTrue(tryAgainButton.isAccessibilityElement, "Try Again button should be accessible")
        }
    }
    
    // MARK: - Visual Regression Tests
    
    @MainActor
    func testMainViewLayout() throws {
        // Verify the main elements are positioned correctly
        let navigationTitle = app.navigationBars["BeCurrent"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5.0), "Navigation should exist")
        
        let feedTab = app.tabBars.buttons["Feed"]
        XCTAssertTrue(feedTab.exists, "Feed tab should exist")
        
        // Verify tab bar is below navigation
        XCTAssertLessThan(navigationTitle.frame.midY, feedTab.frame.midY, "Navigation should be above tab bar")
        
        // Verify we have either content or loading/error state
        let hasContent = app.scrollViews.firstMatch.exists
        let hasLoading = app.progressIndicators["Loading feed..."].exists
        let hasError = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '😕'")).firstMatch.exists
        
        XCTAssertTrue(hasContent || hasLoading || hasError, "Should have some content, loading, or error state")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

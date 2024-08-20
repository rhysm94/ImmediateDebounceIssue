//
//  DebouncerTests.swift
//  ImmediateDebounceIssue
//
//  Created by Rhys Morgan on 20/08/2024.
//

@testable import ImmediateDebounceIssue
import ConcurrencyExtras
import Clocks
import XCTest

final class DebouncerTests: XCTestCase {
  func testDebounce_TestClock() async throws {
    let receivedValues = LockIsolated<[Int]>([])
    let clock = TestClock()
    let debouncer = Debouncer()
    
    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(1)
      }
    }

    XCTAssertTrue(receivedValues.value.isEmpty)

    await clock.advance(by: .seconds(1))

    XCTAssertEqual(receivedValues.value, [1])

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(2)
      }
    }

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(3)
      }
    }

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(4)
      }
    }

    await clock.advance(by: .seconds(1))

    XCTAssertEqual(receivedValues.value, [1, 4])
  }

  func testDebounce_ImmediateClock() async throws {
    let receivedValues = LockIsolated<[Int]>([])
    let clock = ImmediateClock()
    let debouncer = Debouncer()

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(1)
      }
    }

    XCTAssertTrue(receivedValues.value.isEmpty)

    XCTAssertEqual(receivedValues.value, [1])

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(2)
      }
    }

    XCTAssertEqual(receivedValues.value, [1, 2])

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(3)
      }
    }

    XCTAssertEqual(receivedValues.value, [1, 2, 3])

    await debouncer.debounce(clock: clock, duration: .seconds(1)) {
      receivedValues.withValue { array in
        array.append(4)
      }
    }

    XCTAssertEqual(receivedValues.value, [1, 2, 3, 4])
  }
}

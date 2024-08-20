import Clocks
import XCTest
@testable import ImmediateDebounceIssue

final class MockView: View {
  var setViewStateCallCount: Int = 0
  var setViewStateArgument: ViewState?

  func setViewState(_ viewState: ViewState) {
    setViewStateArgument = viewState
    setViewStateCallCount += 1
  }
}

final class ImmediateDebounceIssueTests: XCTestCase {
  struct SUT {
    let view: MockView
    let presenter: Presenter

    init(view: MockView, presenter: Presenter) {
      self.view = view
      self.presenter = presenter
    }
  }

  @MainActor
  private func makeSUT(
    clock: any Clock<Duration> = ImmediateClock(),
    _ lookupPrice: @Sendable @escaping (Double) async throws -> Double = { _ in 0 }
  ) -> SUT {
    let view = MockView()
    let presenter = Presenter(lookupPrice: lookupPrice, clock: clock)
    presenter.view = view

    return SUT(view: view, presenter: presenter)
  }

  @MainActor
  func testButtonStates() async throws {
    let sut = makeSUT()

    await sut.presenter.didLoadView()

    var viewState = try XCTUnwrap(sut.view.setViewStateArgument)
    XCTAssertFalse(viewState.buttonDisabled)

    await sut.presenter.didReceiveNewValue(for: nil)
    viewState = try XCTUnwrap(sut.view.setViewStateArgument)
    XCTAssertTrue(viewState.buttonDisabled)

    await sut.presenter.didReceiveNewValue(for: 20)
    viewState = try XCTUnwrap(sut.view.setViewStateArgument)
    XCTAssertFalse(viewState.buttonDisabled)
  }
}

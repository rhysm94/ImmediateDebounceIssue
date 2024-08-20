// The Swift Programming Language
// https://docs.swift.org/swift-book

import Clocks

@MainActor
protocol View: AnyObject {
  func setViewState(_ viewState: ViewState)
}

@MainActor
final class Presenter: Sendable {
  private var value: Double?
  private var totalPrice: Double?
  private var isLoading: Bool = false
  private let debouncer = Debouncer()
  private let clock: any Clock<Duration>

  weak var view: View?

  var lookupPrice: (Double) async throws -> Double

  init(
    lookupPrice: @escaping @Sendable (Double) async throws -> Double,
    clock: some Clock<Duration> = ContinuousClock()
  ) {
    self.lookupPrice = lookupPrice
    self.clock = clock
  }

  func didReceiveNewValue(for value: Double?) async {
    self.value = value

    guard let value else {
      updateViewState()
      return
    }
    
    isLoading = true
    updateViewState()

    await debouncer.debounce(
      clock: AnyClock(clock),
      duration: .milliseconds(500)
    ) { @MainActor [weak self] in
      guard let self else { return }
      do {
        let price = try await lookupPrice(value)
        self.totalPrice = price
        isLoading = false
        updateViewState()
      } catch is CancellationError {
        return
      } catch {
        totalPrice = nil
        isLoading = false
        updateViewState()
      }
    }
  }

  @MainActor
  func didLoadView() async {
    updateViewState()

    await didReceiveNewValue(for: value)
  }

  func updateViewState() {
    let viewState = ViewState(
      isLoading: isLoading,
      buttonDisabled: value != nil || isLoading
    )
    view?.setViewState(viewState)
  }
}

struct ViewState {
  var isLoading: Bool
  var buttonDisabled: Bool
}

//
//  Debouncer.swift
//  ImmediateDebounceIssue
//
//  Created by Rhys Morgan on 20/08/2024.
//

actor Debouncer {
  private var task: Task<Void, any Error>?

  init() {}

  func debounce<C: Clock>(
    clock: C,
    duration: C.Duration,
    _ perform: @escaping @Sendable () async -> Void
  ) {
    task?.cancel()

    self.task = Task {
      try await clock.sleep(for: duration)
      await perform()
    }
  }
}

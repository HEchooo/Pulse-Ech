// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse

protocol ConsoleSearchFilterProtocol {
    associatedtype Value: CustomStringConvertible

    var name: String { get }
    var values: [Value] { get }
    var valueExamples: [String] { get }

    func isMatch(_ task: NetworkTaskEntity) -> Bool
}

extension ConsoleSearchFilterProtocol {
    var token: String { makeToken(with: values.map(\.description)) }
}

enum ConsoleSearchFilter: Hashable, Codable {
    case statusCode(ConsoleSearchFilterStatusCode)
    case host(ConsoleSearchFilterHost)
    case method(ConsoleSearchFilterMethod)
    case path(ConsoleSearchFilterPath)

    var filter: any ConsoleSearchFilterProtocol {
        switch self {
        case .statusCode(let filter): return filter
        case .host(let filter): return filter
        case .method(let filter): return filter
        case .path(let filter): return filter
        }
    }

    func isSameType(as other: ConsoleSearchFilter) -> Bool {
        type(of: filter) == type(of: other.filter)
    }
}

struct ConsoleSearchFilterStatusCode: ConsoleSearchFilterProtocol, Hashable, Codable {
    var name: String { "Status Code" }
    var values: [ConsoleSearchRange<Int>]
    var valueExamples: [String] { ["200"] }

    func isMatch(_ task: NetworkTaskEntity) -> Bool {
        values.compactMap { $0.range }.contains {
            $0.contains(Int(task.statusCode))
        }
    }
}

struct ConsoleSearchFilterHost: ConsoleSearchFilterProtocol, Hashable, Codable {
    var name: String { "Host" }
    var values: [String]
    var valueExamples: [String] { ["example.com"] }

    func isMatch(_ task: NetworkTaskEntity) -> Bool {
        guard let host = task.url.flatMap(URL.init)?.host else {
            return false
        }
        return values.contains { host == $0 }
    }
}

struct ConsoleSearchFilterMethod: ConsoleSearchFilterProtocol, Hashable, Codable {
    var name: String { "Method" }
    var values: [HTTPMethod]
    var valueExamples: [String] { ["GET"] }

    func isMatch(_ task: NetworkTaskEntity) -> Bool {
        guard let method = HTTPMethod(rawValue: task.httpMethod ?? "") else { return false }
        return Set(values).contains(method)
    }
}

struct ConsoleSearchFilterPath: ConsoleSearchFilterProtocol, Hashable, Codable {
    var name: String { "Path" }
    var values: [String]
    var valueExamples: [String] { ["/example"] }

    func isMatch(_ task: NetworkTaskEntity) -> Bool {
        guard let path = task.url.flatMap(URL.init)?.path else {
            return false
        }
        return values.contains { path.contains($0) }
    }
}

enum ConsoleSearchRangeModfier: Codable {
    case open, closed
}

struct ConsoleSearchRange<T: Hashable & Comparable & Codable>: Hashable, Codable, CustomStringConvertible {
    var modifier: ConsoleSearchRangeModfier
    var lowerBound: T
    var upperBound: T

    init(_ modifier: ConsoleSearchRangeModfier, lowerBound: T, upperBound: T) {
        self.modifier = modifier
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    init(_ value: T) {
        self.modifier = .closed
        self.lowerBound = value
        self.upperBound = value
    }

    var description: String {
        guard upperBound > lowerBound else { return "\(lowerBound)" }
        if let lowerBound = lowerBound as? Int, let upperBound = upperBound as? Int {
            let upperBound = modifier == .closed ? upperBound + 1 : upperBound
            switch (lowerBound, upperBound) { // Not ideal to put it here
            case (100, 200): return "1XX"
            case (200, 300): return "2XX"
            case (300, 400): return "3XX"
            case (400, 500): return "4XX"
            case (500, 600): return "5XX"
            default: break
            }
        }
        switch modifier {
        case .open: return "\(lowerBound)..<\(upperBound)"
        case .closed: return "\(lowerBound)...\(upperBound)"
        }
    }
}

extension ConsoleSearchRange where T == Int {
    var range: ClosedRange<Int>? {
        guard upperBound >= lowerBound else { return lowerBound...lowerBound }
        switch modifier {
        case .open: return ClosedRange(lowerBound..<upperBound)
        case .closed: return lowerBound...upperBound
        }
    }
}

private func makeToken(with values: [String]) -> String {
    guard values.count > 0 else { return "–" } // Should never happen
    let title = values[0]
    return values.count > 1 ? title + "…" : title
}

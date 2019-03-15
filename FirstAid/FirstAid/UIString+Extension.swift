//
//  UIString+Extension.swift
//  FirstAid
//
//  Created by Adroit MAC on 19/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import Foundation

extension StringProtocol where IndexDistance == Int {
    func index(at offset: Int, from start: Index? = nil) -> Index? {
        return index(start ?? startIndex, offsetBy: offset, limitedBy: endIndex)
    }
    func character(at offset: Int) -> Character? {
        precondition(offset >= 0, "offset can't be negative")
        guard let index = index(at: offset) else { return nil }
        return self[index]
    }
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        let end = index(at: range.count, from: start) ?? endIndex
        return self[start..<end]
    }
    subscript(_ range: CountableClosedRange<Int>) -> SubSequence {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        let end = index(at: range.count, from: start) ?? endIndex
        return self[start..<end]
    }
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound+1)
    }
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0,count-range.lowerBound))
    }
}
extension Substring {
    var string: String { return String(self) }
}

extension String
{
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

//
//  Array+firstIndexOf.swift
//  EmojiArt
//
//  Created by Lucas Claro on 25/06/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable{
    func index(of item: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == item.id{
                return index
            }
        }
        return nil
    }
}

extension Array where Element: Identifiable{
    func containsId(of item: Element) -> Bool {
        for index in 0..<self.count {
            if self[index].id == item.id {
                return true
            }
        }
        return false
    }
}

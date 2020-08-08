//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Lucas Claro on 25/06/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import Foundation

struct  EmojiArt : Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji : Identifiable, Codable, Equatable {
        let id: Int
        
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    init() { }
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int){
        uniqueEmojiID += 1
        emojis.append(Emoji(id: uniqueEmojiID,text: text, x: x, y: y, size: size))
    }
}

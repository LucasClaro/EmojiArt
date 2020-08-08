//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Lucas Claro on 24/06/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
    
    static var palette: String = "🐶🐱🐭🐹🐰🦊"
    
    @Published private var emojiArt: EmojiArt
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    private var autosaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        autosaveCancellable =  $emojiArt.sink { emojiArt in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] {emojiArt.emojis}
    
    @Published private(set) var SelectedEmojis = [EmojiArt.Emoji]()
    
    //MARK: Intents
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(of: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(of: emoji){
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func moveSelectedEmojis(by offset: CGSize) {
        for emoji in SelectedEmojis {
            moveEmoji(emoji, by: offset)
        }
    }
    
    func scaleSelectedEmojis(by scale: CGFloat) {
        for emoji in SelectedEmojis {
            scaleEmoji(emoji, by: scale)
        }
    }
    
    var BackgroundURL: URL?{
        get{
            emojiArt.backgroundURL
        }
        set{
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    func toggleSelectEmoji (_ emoji: EmojiArt.Emoji) {
        if let index = self.SelectedEmojis.index(of: emoji) {
            self.SelectedEmojis.remove(at: index)
        }
        else {
            self.SelectedEmojis.append(emoji)
        }
    }
    
    func removeAllSelections () {
        self.SelectedEmojis.removeAll()
    }
    
//    private func fetchBackgroundImageData(){
//        backgroundImage = nil
//        if let url = self.emojiArt.backgroundURL {
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async {
//                        if url == self.emojiArt.backgroundURL {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    private var fetchImageCancellable: AnyCancellable?
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, URLResponse in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
    }

    
}



extension EmojiArt.Emoji {
    var fontSize: CGFloat {
        CGFloat(self.size)
    }
    
    var location: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

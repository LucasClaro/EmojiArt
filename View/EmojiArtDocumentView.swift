//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Lucas Claro on 24/06/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    var body: some View {
        VStack{
            
            HStack {
                PaletteChoser(document: document, chosenPalette: $chosenPalette)
                
                ScrollView(.horizontal){
                    HStack{
                        ForEach(chosenPalette.map {String($0)}, id: \.self) { emoji in
                            Text (emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag{ NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                .onAppear { self.chosenPalette = self.document.defaultPalette }
                
            }
                .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack{
                    
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                        .gesture(self.tapToUnselect())
                        .onReceive(self.document.$backgroundImage) { image in
                            self.zoomToFit(image, in: geometry.size)
                        }
                    
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large)
                    }
                    else {
                        ForEach (self.document.emojis){ emoji in
                            Text(emoji.text)
                                .if(self.document.SelectedEmojis.containsId(of: emoji)) { view in
                                    view.border(Color.black)
                                }
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale )
                                .position(self.position(for: emoji, in: geometry.size))
                                .onTapGesture {
                                    self.document.toggleSelectEmoji(emoji)
                                }
                        }
                    }
                    
                    
                    
                }
                    .clipped()
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    
                    .onDrop(of: ["public.image","public.text"], isTargeted: nil) { providers, location in
                        // SwiftUI bug (as of 13.4)? the location is supposed to be in our coordinate system
                        // however, the y coordinate appears to be in the global coordinate system
                        var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                        location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                        location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                        location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                        return self.drop(providers: providers, at: location)
                    }
                        .navigationBarItems(trailing: Button(action: {
                            if let url = UIPasteboard.general.url {
                                self.document.BackgroundURL = url
                            }
                        }, label: {
                            Image(systemName: "doc.on.clipboard").imageScale(.large)
                        }))
                
            }
                .zIndex(-1)
            
        }
    }
    
    var isLoading: Bool {
        document.BackgroundURL != nil && document.backgroundImage == nil
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        if document.SelectedEmojis.count > 0 {
            return AnyGesture(
                MagnificationGesture()
                    .onEnded { finalGestureScale in
                        self.document.scaleSelectedEmojis(by: finalGestureScale)
                    }
                
            )
            
        }
        else {
            return AnyGesture(
                
                MagnificationGesture()
                .onEnded{ finalGestureScale in
                    self.steadyStateZoomScale *= finalGestureScale
                }
                .updating($gestureZoomScale) { latestGestureScale, ourGestureStateInOut, transation in
                    ourGestureStateInOut = latestGestureScale
                }
            )
            
        }
        
    }
    
    
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        if document.SelectedEmojis.count > 0 {
            return AnyGesture(
                DragGesture()
                    .onEnded { finalDragGestureValue in
                        self.document.moveSelectedEmojis(by: finalDragGestureValue.translation)
                    }
            )
        }
        else {
            return AnyGesture(
                DragGesture()
                    .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                        gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
                    }
                    .onEnded { finalDragGestureValue in
                        self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
                    }
            )
        }
        
    }
    
    
    
    private func tapToUnselect() -> some Gesture {
        TapGesture()
            .onEnded{
                self.document.removeAllSelections()
            }
    }
    
    
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded{_ in
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool{
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.BackgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
}




struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group{
            if uiImage != nil{
                Image(uiImage: uiImage!)
            }
        }
    }
}

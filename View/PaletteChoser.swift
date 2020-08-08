//
//  PaletteChoser.swift
//  EmojiArt
//
//  Created by Lucas Claro on 07/07/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import SwiftUI

struct PaletteChoser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "pencil.circle").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: self.$chosenPalette)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
            .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0){
            Text("Palette Editor").font(.headline).padding()
            Divider()
            Form {
                Section() {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                
                Section(header: Text("Remove Emoji")) {
                    VStack {
                        ForEach(chosenPalette.map {String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .onTapGesture {
                                    self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                            }
                        }
                    }
                }
                
            }
            Spacer()
        }
            .onAppear(){ self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }
}

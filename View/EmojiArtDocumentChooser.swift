//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Lucas Claro on 10/07/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView{
            
            List{
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                    ) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
            }
                .navigationBarTitle(self.store.name)
                .navigationBarItems(leading: Button(action: {
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "plus.circle").imageScale(.large)
                    }),
                    trailing: EditButton()
                )
                .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}

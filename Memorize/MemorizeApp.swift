//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Priyanshu Kashyap on 03/06/21.
//

import SwiftUI

@main
struct MemorizeApp: App {
    let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
                .preferredColorScheme(.dark)
        }
    }
}

//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Priyanshu Kashyap on 03/06/21.
//

import SwiftUI


struct EmojiMemoryGameView: View {
    
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{
                gameBody
                HStack {
                    restart
                    Spacer()
                    shuffle
                }
                .padding()
            }
            .padding(.horizontal,2)
            deckBody
            
        }
        
    }
    
    @State private var dealt = Set<Int>()
    @Namespace private var dealingNamespace
    
    private func deal(_ card: MemoryGame<String>.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: MemoryGame<String>.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: MemoryGame<String>.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (1 / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: 1).delay(delay)
    }
    
    private func zIndex(of card: MemoryGame<String>.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var gameBody: some View {
        ScrollView{
            LazyVGrid(columns: [GridItem(.adaptive(minimum:100))]) {
                ForEach(game.cards) { card in
                    if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                        Color.clear
                    } else {
                        CardView(card: card)
                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity))
                            .zIndex(zIndex(of: card))
                            .onTapGesture {
                                withAnimation {
                                    game.choose(card: card)
                                }
                            }
                    }
                }
            }
        }
        .padding(.vertical)
        .font(.largeTitle)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
                
                
            }
        }
        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
        .padding()
        .onTapGesture {
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
            
        }
    }
    
}

struct CardView: View {
    
    let card: MemoryGame<String>.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View{
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                    }
                }
                .padding()
                .opacity(0.5)
                
                
                Text(card.content)
                    .rotationEffect(Angle(degrees: card.isMatched ? 360 : 0))
                    .animation(.spring().repeatForever())
                    .font(.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.4
        static let fontSize: CGFloat = 32
    }
}


struct ContentView_Previews: PreviewProvider {
    static let game = EmojiMemoryGame()
    static var previews: some View {
        EmojiMemoryGameView(game: game).preferredColorScheme(.dark)
        
    }
}

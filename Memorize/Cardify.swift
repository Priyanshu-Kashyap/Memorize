//
//  Cardify.swift
//  Memorize
//
//  Created by Priyanshu Kashyap on 08/06/21.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    
    var rotation: Double
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
            if rotation < 90 {
                shape.foregroundColor(.yellow)
                shape.stroke()
            } else {
                shape.foregroundColor(.orange)
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(
            Angle(degrees: rotation),
            axis: (0,1,0)
        )
    }
    
}


extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}

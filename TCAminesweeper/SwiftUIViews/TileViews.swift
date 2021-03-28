//
//  TileViews.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 04/03/2021.
//

import SwiftUI

struct OverlayTile: View {
    var isMarked = false
    var onTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    @State private var isLongPressCalled = false
    
    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                self.isLongPressCalled = true
                self.onLongPress?()
            }
    }
    
    var body: some View {
        Button(action: {
            if self.isLongPressCalled { self.isLongPressCalled = false }
            else { self.onTap?() }
        }) {
            ZStack {
                Rectangle()
                    .fill(Color.overlay)
                    .cornerRadius(5)
                    .padding(2)
                
                if isMarked {
                    Text("🚩")
                        .font(.caption)
                }
            }
        }
        .simultaneousGesture(self.longPressGesture)
    }
}

struct TextTile: View {
    let text: String
    let textColor: Color
    
    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .font(.caption)
            .fontWeight(.semibold)
    }
}

struct BombTile: View {
    let text: String
    let isMarked: Bool
    
    var body: some View {
        ZStack {
            TextTile(text: text, textColor: .black)
            
            if isMarked {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
    }
}

#if DEBUG

struct TileViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverlayTile(onTap: {}, onLongPress: {})
            OverlayTile(isMarked: true)
            TextTile(text: "1", textColor: .blue)
            BombTile(text: "💥", isMarked: false)
        }
        .previewLayout(.fixed(width: 30, height: 30))
    }
}

#endif

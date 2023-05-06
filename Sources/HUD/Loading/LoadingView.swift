//
//  LoadingView.swift
//  Show
//
//  Created by iOS on 2023/5/6.
//

import SwiftUI

struct LoadingView: Hud {
    var id: UUID = UUID()
    var position: HudPosition = .center
    
    var text: String?
    //HUD提示字体颜色
    var textColor = Color.black
    //HUD提示字体颜色
    var textFont: Font = .system(size: 15, weight: .medium)
    //HUD Loading颜色
    var accentColor = Color.blue
    
    func setupBody() -> some View  {
        VStack(spacing: 10){
            
            ProgressView()
                .scaleEffect(2)
                .frame(width: 50, height: 50)
                .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
            
            if let status = text{
                Text("\(status)")
                    .font(textFont)
                    .foregroundColor(textColor)
            }
        }
        .padding(15)
        .background(BlurView())
        .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
    }
    
    func setupConfig(_ config: Config) -> Config {
        config
            .backgroundColour(.white)
            .maxStackCount(1)
            .needMask(true)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

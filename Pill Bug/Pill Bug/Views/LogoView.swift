//
//  LogoView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/25/24.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            HStack {
                Circle()
                    .frame(width: 300, height: 300)
                    .offset(x: -10, y: -100)
                Circle()
                    .frame(width: 300, height: 300)
                    .offset(x: 10, y: -100)
            }
            HStack {
                Circle()
                    .fill(.white)
                    .frame(width: 280, height: 280)
                    .offset(x: -20, y: -100)
                    
                Circle()
                    .fill(.white)
                    .frame(width: 280, height: 280)
                    .offset(x: 20, y: -100)
            }
            RoundedRectangle(cornerRadius: 100)
                .fill(.black)
                .frame(width: 170, height: 300)
            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 100,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: 100),
                style: .continuous)
            .frame(width: 150, height: 137.5)
            .foregroundStyle(.red)
            .offset(x: 0, y: -72)
            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 0,
                bottomLeading: 100,
                bottomTrailing: 100,
                topTrailing: 0),
                style: .continuous)
            .frame(width: 150, height: 137.5)
            .foregroundStyle(.blue)
            .offset(x: 0, y: 72)
            Rectangle()
                .fill(.white)
                .offset(x: -389)
            Rectangle()
                .fill(.white)
                .offset(x: 389)
            Rectangle()
                .fill(.white)
                .offset(y: -580)
            Circle()
                .frame(width: 20, height: 20)
                .offset(x: -60, y: -202)
            Circle()
                .frame(width: 20, height: 20)
                .offset(x: 60, y: -202)
        }
        
    }
}

#Preview {
    LogoView()
}

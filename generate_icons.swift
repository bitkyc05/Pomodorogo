#!/usr/bin/env swift

import SwiftUI
import AppKit
import Foundation

// MARK: - 앱 아이콘 생성용 뷰
struct AppIconView: View {
    var body: some View {
        ZStack {
            // 토마토 배경
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.2, blue: 0.2),
                            Color(red: 0.8, green: 0.1, blue: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // 토마토 상단 잎사귀
            VStack(spacing: -10) {
                HStack(spacing: 2) {
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: 8, height: 20)
                        .rotationEffect(.degrees(-20))
                    
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: 10, height: 25)
                        .rotationEffect(.degrees(0))
                    
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: 8, height: 18)
                        .rotationEffect(.degrees(20))
                }
                .offset(y: -70)
                
                Spacer()
            }
            
            // 타이머 표시 (시계 바늘)
            VStack {
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    .frame(width: 80, height: 80)
                    .overlay(
                        VStack {
                            // 시침
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.white)
                                .frame(width: 2, height: 20)
                                .offset(y: -10)
                                .rotationEffect(.degrees(90))
                            
                            // 분침
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.white)
                                .frame(width: 1.5, height: 30)
                                .offset(y: -15)
                                .rotationEffect(.degrees(45))
                        }
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                    )
            }
            
            // 포모도로 숫자 25 표시
            VStack {
                Spacer()
                Text("25")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .offset(y: 30)
            }
        }
    }
}

// MARK: - 아이콘 생성 함수
func generateIcon(size: CGSize) -> NSImage? {
    let iconView = AppIconView()
    let hosting = NSHostingView(rootView: iconView)
    hosting.frame = NSRect(origin: .zero, size: size)
    
    guard let bitmapRep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
        return nil
    }
    
    hosting.cacheDisplay(in: hosting.bounds, to: bitmapRep)
    
    let image = NSImage(size: size)
    image.addRepresentation(bitmapRep)
    
    return image
}

func saveIconToPNG(image: NSImage, path: String) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        return false
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        return true
    } catch {
        print("Error saving icon: \(error)")
        return false
    }
}

// MARK: - 메인 실행
let iconConfigs = [
    // (filename, actualSize)
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

let iconsetPath = "/Users/jun/Documents/Pomodorogo/Pomodorogo/Assets.xcassets/AppIcon.appiconset"

// 기존 아이콘 파일들 삭제
for (filename, _) in iconConfigs {
    let filePath = "\(iconsetPath)/\(filename)"
    try? FileManager.default.removeItem(atPath: filePath)
}

// 새로운 아이콘들 생성
for (filename, size) in iconConfigs {
    if let image = generateIcon(size: CGSize(width: size, height: size)) {
        let filePath = "\(iconsetPath)/\(filename)"
        if saveIconToPNG(image: image, path: filePath) {
            print("Generated: \(filename) (\(size)x\(size))")
        } else {
            print("Failed to generate: \(filename)")
        }
    }
}

print("Icon generation complete!")
#!/usr/bin/env swift

import SwiftUI
import AppKit
import Foundation

// MARK: - 앱 아이콘 생성용 뷰
struct AppIconView: View {
    let size: CGFloat
    
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
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.3), radius: size * 0.05, x: 0, y: size * 0.025)
            
            // 토마토 상단 잎사귀
            VStack(spacing: -size * 0.05) {
                HStack(spacing: size * 0.01) {
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: size * 0.04, height: size * 0.1)
                        .rotationEffect(.degrees(-20))
                    
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: size * 0.05, height: size * 0.125)
                        .rotationEffect(.degrees(0))
                    
                    Ellipse()
                        .fill(Color.green)
                        .frame(width: size * 0.04, height: size * 0.09)
                        .rotationEffect(.degrees(20))
                }
                .offset(y: -size * 0.35)
                
                Spacer()
            }
            
            // 타이머 표시 (시계 바늘)
            VStack {
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: size * 0.015)
                    .frame(width: size * 0.4, height: size * 0.4)
                    .overlay(
                        VStack {
                            // 시침
                            RoundedRectangle(cornerRadius: size * 0.005)
                                .fill(Color.white)
                                .frame(width: size * 0.01, height: size * 0.1)
                                .offset(y: -size * 0.05)
                                .rotationEffect(.degrees(90))
                            
                            // 분침
                            RoundedRectangle(cornerRadius: size * 0.0037)
                                .fill(Color.white)
                                .frame(width: size * 0.0075, height: size * 0.15)
                                .offset(y: -size * 0.075)
                                .rotationEffect(.degrees(45))
                        }
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.03, height: size * 0.03)
                    )
            }
            
            // 포모도로 숫자 25 표시
            VStack {
                Spacer()
                Text("25")
                    .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: size * 0.01, x: 0, y: size * 0.005)
                    .offset(y: size * 0.15)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 아이콘 생성 함수 (수정된 버전)
func generateIcon(size: CGFloat) -> NSImage? {
    let iconView = AppIconView(size: size)
    let hosting = NSHostingView(rootView: iconView)
    
    // 정확한 크기로 호스팅 뷰 설정
    hosting.frame = NSRect(x: 0, y: 0, width: size, height: size)
    hosting.wantsLayer = true
    hosting.layer?.contentsScale = 1.0  // 스케일링 방지
    
    // 뷰 강제 레이아웃
    hosting.needsLayout = true
    hosting.layoutSubtreeIfNeeded()
    
    // 비트맵 생성
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return nil
    }
    
    let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    
    hosting.draw(NSRect(x: 0, y: 0, width: size, height: size))
    
    NSGraphicsContext.restoreGraphicsState()
    
    let image = NSImage(size: NSSize(width: size, height: size))
    image.addRepresentation(bitmapRep)
    
    return image
}

func saveIconToPNG(image: NSImage, path: String) -> Bool {
    guard let imageRep = image.representations.first as? NSBitmapImageRep,
          let pngData = imageRep.representation(using: .png, properties: [:]) else {
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
let iconConfigs: [(String, CGFloat)] = [
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
    print("Generating \(filename) at \(size)x\(size)...")
    
    if let image = generateIcon(size: size) {
        let filePath = "\(iconsetPath)/\(filename)"
        if saveIconToPNG(image: image, path: filePath) {
            print("✅ Generated: \(filename)")
            
            // 생성된 파일 크기 검증
            if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
               let verifyImage = NSImage(data: fileData) {
                print("   Verified size: \(verifyImage.size.width)x\(verifyImage.size.height)")
            }
        } else {
            print("❌ Failed to generate: \(filename)")
        }
    } else {
        print("❌ Failed to create image for: \(filename)")
    }
}

print("Icon generation complete!")
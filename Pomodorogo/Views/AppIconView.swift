import SwiftUI

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
                .frame(width: 200, height: 200)
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
                
                // 토마토 몸체
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
        .frame(width: 200, height: 200)
    }
}

// MARK: - 아이콘 생성 헬퍼
struct IconGenerator {
    static func generateAppIcon() -> NSImage? {
        let iconView = AppIconView()
        let hosting = NSHostingView(rootView: iconView)
        hosting.frame = NSRect(x: 0, y: 0, width: 1024, height: 1024)
        
        guard let bitmapRep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            return nil
        }
        
        hosting.cacheDisplay(in: hosting.bounds, to: bitmapRep)
        
        let image = NSImage(size: hosting.bounds.size)
        image.addRepresentation(bitmapRep)
        
        return image
    }
    
    static func saveIconToDesktop() {
        guard let icon = generateAppIcon() else {
            print("Failed to generate icon")
            return
        }
        
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let iconURL = desktopURL.appendingPathComponent("PomodoroIcon.png")
        
        if let tiffData = icon.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            
            do {
                try pngData.write(to: iconURL)
                print("Icon saved to: \(iconURL.path)")
            } catch {
                print("Failed to save icon: \(error)")
            }
        }
    }
}

#Preview {
    AppIconView()
        .frame(width: 300, height: 300)
        .background(Color.gray.opacity(0.1))
}
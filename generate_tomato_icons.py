#!/usr/bin/env python3
"""
토마토 이모지를 사용해서 앱 아이콘을 생성하는 스크립트
"""

import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_tomato_icon(size, output_path):
    """토마토 이모지 아이콘 생성"""
    
    # 이미지 생성 (투명 배경)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 배경색 (선택사항 - 투명하게 두거나 흰색 배경)
    # draw.rectangle([0, 0, size, size], fill=(255, 255, 255, 255))
    
    try:
        # 시스템 이모지 폰트 시도
        font_size = int(size * 0.7)  # 아이콘 크기의 70%
        
        # macOS 이모지 폰트 경로들
        font_paths = [
            '/System/Library/Fonts/Apple Color Emoji.ttc',
            '/Library/Fonts/Apple Color Emoji.ttc',
            '/System/Library/Fonts/Helvetica.ttc'
        ]
        
        font = None
        for font_path in font_paths:
            if os.path.exists(font_path):
                try:
                    font = ImageFont.truetype(font_path, font_size)
                    break
                except:
                    continue
        
        if font is None:
            # 기본 폰트 사용
            font = ImageFont.load_default()
        
        # 토마토 이모지 텍스트
        text = "🍅"
        
        # 텍스트 위치 계산 (중앙 정렬)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (size - text_width) // 2
        y = (size - text_height) // 2
        
        # 텍스트 그리기
        draw.text((x, y), text, font=font, fill=(255, 0, 0, 255))
        
    except Exception as e:
        print(f"폰트 로딩 실패, 간단한 원으로 대체: {e}")
        # 폰트 로딩 실패시 간단한 토마토 색 원으로 대체
        margin = size // 10
        draw.ellipse([margin, margin, size-margin, size-margin], 
                    fill=(255, 99, 71, 255))  # 토마토 색
    
    # PNG로 저장
    img.save(output_path, 'PNG')
    print(f"Created: {output_path} ({size}x{size})")

def main():
    """메인 함수"""
    
    # 출력 디렉토리
    output_dir = "/Users/jun/Documents/Pomodorogo/Pomodorogo/Assets.xcassets/AppIcon.appiconset"
    
    # 필요한 아이콘 크기들과 파일명
    icon_sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]
    
    print("토마토 이모지 앱 아이콘 생성 중...")
    
    for size, filename in icon_sizes:
        output_path = os.path.join(output_dir, filename)
        create_tomato_icon(size, output_path)
    
    print("완료! Xcode에서 앱을 다시 빌드하세요.")

if __name__ == "__main__":
    main()
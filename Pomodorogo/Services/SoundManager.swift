import Foundation
import AVFoundation
import AppKit

// MARK: - 사운드 매니저
class SoundManager: ObservableObject {
    
    static let shared = SoundManager()
    
    // MARK: - Audio Players
    private var notificationPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var ambientAudioEngine: AVAudioEngine?
    private var ambientPlayerNode: AVAudioPlayerNode?
    private var ambientBuffer: AVAudioPCMBuffer?
    
    @Published var isAmbientPlaying = false
    @Published var ambientVolume: Float = 0.5
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        // macOS doesn't use AVAudioSession like iOS
        // Audio mixing is handled automatically by the system
    }
    
    // MARK: - Notification Sounds
    func playNotificationSound(_ sound: NotificationSound) {
        switch sound {
        case .none:
            return
        case .default:
            playDefaultBeep()
        case .bell:
            playBellSound()
        case .chime:
            playChimeSound()
        }
    }
    
    private func playDefaultBeep() {
        // 시스템 기본 알림음 재생
        NSSound.beep()
    }
    
    private func playBellSound() {
        playGeneratedSound(frequency: 800, duration: 0.5, fadeOut: true)
    }
    
    private func playChimeSound() {
        playGeneratedSound(frequency: 523.25, duration: 0.6, fadeOut: true, isChime: true)
    }
    
    private func playGeneratedSound(frequency: Double, duration: Double, fadeOut: Bool = false, isChime: Bool = false) {
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        let sampleRate = mixer.outputFormat(forBus: 0).sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0), frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for channel in 0..<channels {
            let samples = buffer.floatChannelData![channel]
            
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                var amplitude: Float = 0.3
                
                if fadeOut {
                    amplitude *= Float(1.0 - (time / duration))
                }
                
                if isChime {
                    // 화음 효과
                    let fundamental = sin(2.0 * .pi * frequency * time)
                    let fifth = sin(2.0 * .pi * frequency * 1.5 * time) * 0.5
                    let octave = sin(2.0 * .pi * frequency * 2.0 * time) * 0.3
                    samples[frame] = Float(fundamental + fifth + octave) * amplitude
                } else {
                    samples[frame] = Float(sin(2.0 * .pi * frequency * time)) * amplitude
                }
            }
        }
        
        do {
            try audioEngine.start()
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: {
                audioEngine.stop()
            })
            playerNode.play()
        } catch {
            print("Failed to play generated sound: \(error)")
        }
    }
    
    // MARK: - Ambient Sounds
    func startAmbientSound(_ sound: AmbientSound, volume: Float = 0.5) {
        stopAmbientSound()
        
        ambientVolume = volume
        
        switch sound {
        case .none:
            return
        case .rain:
            playAmbientLoop(type: .rain)
        case .ocean:
            playAmbientLoop(type: .ocean)
        case .forest:
            playAmbientLoop(type: .forest)
        case .cafe:
            playAmbientLoop(type: .cafe)
        case .whiteNoise:
            playAmbientLoop(type: .whiteNoise)
        }
        
        isAmbientPlaying = true
    }
    
    func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
        
        ambientAudioEngine?.stop()
        ambientPlayerNode?.stop()
        ambientAudioEngine = nil
        ambientPlayerNode = nil
        ambientBuffer = nil
        
        isAmbientPlaying = false
    }
    
    func setAmbientVolume(_ volume: Float) {
        ambientVolume = max(0.0, min(1.0, volume))
        ambientPlayer?.volume = ambientVolume
        
        // AVAudioEngine 사용 시
        if let playerNode = ambientPlayerNode {
            playerNode.volume = ambientVolume
        }
    }
    
    private func playAmbientLoop(type: AmbientSound) {
        // 실제 구현에서는 번들에 포함된 오디오 파일을 사용하거나
        // 실시간으로 생성된 오디오를 사용할 수 있습니다.
        
        switch type {
        case .whiteNoise:
            playGeneratedAmbientSound(type: .whiteNoise)
        case .rain:
            playGeneratedAmbientSound(type: .rain)
        case .ocean:
            playGeneratedAmbientSound(type: .ocean)
        case .forest:
            playGeneratedAmbientSound(type: .forest)
        case .cafe:
            playGeneratedAmbientSound(type: .cafe)
        case .none:
            break
        }
    }
    
    private func playGeneratedAmbientSound(type: AmbientSound) {
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        let sampleRate = mixer.outputFormat(forBus: 0).sampleRate
        let bufferDuration = 2.0 // 2초 버퍼
        let frameCount = AVAudioFrameCount(sampleRate * bufferDuration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0), frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        generateAmbientBuffer(buffer: buffer, type: type, sampleRate: sampleRate)
        
        self.ambientAudioEngine = audioEngine
        self.ambientPlayerNode = playerNode
        self.ambientBuffer = buffer
        
        do {
            try audioEngine.start()
            
            // 무한 루프로 재생
            scheduleAmbientLoop()
            
        } catch {
            print("Failed to start ambient sound: \(error)")
        }
    }
    
    private func scheduleAmbientLoop() {
        guard let playerNode = ambientPlayerNode,
              let buffer = ambientBuffer else { return }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        playerNode.volume = ambientVolume
        playerNode.play()
    }
    
    private func generateAmbientBuffer(buffer: AVAudioPCMBuffer, type: AmbientSound, sampleRate: Double) {
        let frameCount = buffer.frameLength
        let channels = Int(buffer.format.channelCount)
        
        for channel in 0..<channels {
            let samples = buffer.floatChannelData![channel]
            
            switch type {
            case .whiteNoise:
                generateWhiteNoise(samples: samples, frameCount: Int(frameCount))
            case .rain:
                generateRainSound(samples: samples, frameCount: Int(frameCount), sampleRate: sampleRate)
            case .ocean:
                generateOceanSound(samples: samples, frameCount: Int(frameCount), sampleRate: sampleRate)
            case .forest:
                generateForestSound(samples: samples, frameCount: Int(frameCount), sampleRate: sampleRate)
            case .cafe:
                generateCafeSound(samples: samples, frameCount: Int(frameCount), sampleRate: sampleRate)
            case .none:
                break
            }
        }
    }
    
    private func generateWhiteNoise(samples: UnsafeMutablePointer<Float>, frameCount: Int) {
        for i in 0..<frameCount {
            samples[i] = Float.random(in: -1.0...1.0) * 0.3
        }
    }
    
    private func generateRainSound(samples: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        // 비 소리는 필터링된 화이트 노이즈로 시뮬레이션
        for i in 0..<frameCount {
            let whiteNoise = Float.random(in: -1.0...1.0)
            // 간단한 로우패스 필터 효과
            let filtered = whiteNoise * 0.5
            samples[i] = filtered * 0.4
        }
    }
    
    private func generateOceanSound(samples: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        // 바다 소리는 저주파 사인파와 노이즈의 조합
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let wave = sin(2.0 * .pi * 0.1 * time) * 0.3 // 저주파 파도
            let noise = Float.random(in: -1.0...1.0) * 0.2
            samples[i] = Float(wave) + noise * 0.3
        }
    }
    
    private func generateForestSound(samples: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        // 숲 소리는 여러 주파수의 조합
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let bird1 = sin(2.0 * .pi * 800 * time) * 0.1
            let bird2 = sin(2.0 * .pi * 1200 * time) * 0.05
            let wind = Float.random(in: -1.0...1.0) * 0.15
            samples[i] = Float(bird1 + bird2) + wind
        }
    }
    
    private func generateCafeSound(samples: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        // 카페 소리는 브라운 노이즈로 시뮬레이션
        var lastSample: Float = 0.0
        for i in 0..<frameCount {
            let white = Float.random(in: -1.0...1.0)
            lastSample = (lastSample + 0.02 * white) / 1.02
            samples[i] = lastSample * 3.5 * 0.3
        }
    }
    
    // MARK: - Preview Functions
    func playNotificationSoundPreview(_ sound: NotificationSound) {
        playNotificationSound(sound)
    }
    
    func playAmbientSoundPreview(_ sound: AmbientSound, volume: Float, duration: Double = 3.0) {
        startAmbientSound(sound, volume: volume)
        
        // 3초 후 자동 정지
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stopAmbientSound()
        }
    }
}

// MARK: - 편의 기능
extension SoundManager {
    func toggleAmbientSound(_ sound: AmbientSound, volume: Float = 0.5) {
        if isAmbientPlaying {
            stopAmbientSound()
        } else {
            startAmbientSound(sound, volume: volume)
        }
    }
}
//
// AnimatedGifView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
// 


import SwiftUI
import ImageIO


// MARK: - UIViewRepresentable для отображения GIF
struct GifImageView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Загружаем GIF из bundle
        if let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL) {
            imageView.image = UIImage.gif(data: gifData)
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Обновления не требуется
    }
}

// MARK: - Расширение UIImage для работы с GIF
extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    static func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0))
        }
        
        let duration: Int = delays.reduce(0, +)
        let gcd = gcdForArray(delays)
        
        var frames = [UIImage]()
        var frame: UIImage
        var frameCount: Int
        
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(
            with: frames,
            duration: Double(duration) / 1000.0
        )
        
        return animation
    }
    
    static func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self
        )
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                to: AnyObject.self
            )
        }
        
        if let delayValue = delayObject as? Double, delayValue > 0 {
            delay = delayValue
        } else {
            delay = 0.1
        }
        
        return delay
    }
}

// MARK: - Вспомогательные функции
func gcdForArray(_ array: [Int]) -> Int {
    if array.isEmpty {
        return 1
    }
    
    var gcd = array[0]
    
    for val in array {
        gcd = gcdForPair(val, gcd)
    }
    
    return gcd
}

func gcdForPair(_ lhs: Int, _ rhs: Int) -> Int {
    var lhs = lhs
    var rhs = rhs
    
    if rhs == 0 {
        return lhs
    } else {
        return gcdForPair(rhs, lhs % rhs)
    }
}

// MARK: - Компонент для управления GIF
struct AnimatedGifView: View {
    let gifName: String
    let width: CGFloat?
    let height: CGFloat?
    let isPlaying: Bool
    
    init(
        gifName: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        isPlaying: Bool = true
    ) {
        self.gifName = gifName
        self.width = width
        self.height = height
        self.isPlaying = isPlaying
    }
    
    var body: some View {
        Group {
            if isPlaying {
                GifImageView(gifName: gifName)
            } else {
                // Показываем первый кадр как статичное изображение
                Image(gifName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: width, height: height)
    }
}

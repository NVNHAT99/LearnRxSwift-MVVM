//
//  ImageDownloadManager.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/14/24.
//

import UIKit

class ImageDownloadManager {
    static let shared = ImageDownloadManager()
    private init() {
    }

    private var tasks: [String: URLSessionDataTask] = [:]
    private let cache = NSCache<NSString, UIImage>()
    
    // Hàm tải ảnh từ URL
    func downloadImage(with url: URL, placeholder: UIImage? = UIImage(named: "placeholder"), completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url.absoluteString
        
        // Kiểm tra ảnh đã có trong cache chưa
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            completion(cachedImage)
            return
        }
        
        // Kiểm tra nếu có tác vụ đang tải ảnh này, nếu có thì không tạo mới mà tiếp tục
        if let existingTask = tasks[cacheKey] {
            existingTask.resume()
            return
        }
        
        // Tạo tác vụ tải ảnh
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            defer { self.tasks.removeValue(forKey: cacheKey) }
            
            if let data = data, let image = UIImage(data: data) {
                // Lưu ảnh vào cache
                self.cache.setObject(image, forKey: cacheKey as NSString)
                completion(image)
            } else {
                completion(placeholder)
            }
        }
        
        tasks[cacheKey] = task
        task.resume() // Bắt đầu tải ảnh
    }
    
    // Hủy bỏ tải ảnh
    func cancelDownload(for url: URL) {
        let cacheKey = url.absoluteString
        if let task = tasks[cacheKey] {
            task.cancel()
            tasks.removeValue(forKey: cacheKey)
        }
    }
    
    // Tạm dừng tải ảnh
    func pauseDownload(for url: URL) {
        let cacheKey = url.absoluteString
        tasks[cacheKey]?.suspend()
    }
    
    // Tiếp tục tải ảnh
    func resumeDownload(for url: URL) {
        let cacheKey = url.absoluteString
        tasks[cacheKey]?.resume()
    }
    
    func getCacheImage(with cacheKey: String) -> UIImage? {
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }
        return nil
    }
}

/*
 * Copyright 2016 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

public class ImageSource {
    private let remoteFetch: RemoteFetch
    private var asks = [ImageAsk]()
    private lazy var queue: DispatchQueue = {
        return DispatchQueue(label: "Image ask queue")
    }()
    
    public init(fetch: RemoteFetch) {
        remoteFetch = fetch
    }
    
    public func hasImage(forAsk ask: ImageAsk) -> Bool {
        let path = localPathFor(ask)
        return FileManager.default.fileExists(atPath: path.path)
    }
    
    public func image(forAsk ask: ImageAsk) -> UIImage? {
        let path = localPathFor(ask)
        let data = try! Data(contentsOf: path)
        return UIImage(data: data)!
    }
    
    public func retrieveImage(for ask: ImageAsk, completion: @escaping (UIImage?) -> ()) {
        queue.async {
            if let index = self.asks.index(where: { $0.imageURL == ask.imageURL }) {
                let existing = self.asks[index]
                existing.completions.append(completion)
                return
            }
            
            self.asks.append(ask)

            let executed = ask
            executed.completions.append(completion)
            
            self.remoteFetch.fetchImage(for: executed) {
                data, response, error in
                
                if let error = error {
                    Logging.log("Retrieve image error: \(error)")
                }
                
                self.queue.async {
                    guard let index = self.asks.index(where: { $0.imageURL == executed.imageURL }) else {
                        return
                    }
                    
                    let completed = self.asks.remove(at: index)
                    let completions = completed.completions
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        for c in completions {
                            c(nil)
                        }
                        return
                    }
                    
                    self.save(data, for: executed)
                    for c in completions {
                        c(image)
                    }
                }
            }
        }
    }
    
    private func save(_ data: Data, for ask: ImageAsk) {
        let path = localPathFor(ask)
        do {
            try data.write(to: path, options: .atomicWrite)
        } catch let error as NSError {
            Logging.log("Image save error: \(error)")
        }
    }
    
    private func localPathFor(_ ask: ImageAsk) -> URL {
        let key = keyFor(ask)
        return cachePath().appendingPathComponent(key)
    }
    
    private func cachePath() -> URL {
        let identifier = Bundle.main.bundleIdentifier!
        let cache = "\(identifier).images"
        let cachesFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
        let imageCacheFolder = cachesFolder.appendingPathComponent(cache)
        if !FileManager.default.fileExists(atPath: imageCacheFolder.path) {
            do {
                try FileManager.default.createDirectory(at: imageCacheFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        
        return imageCacheFolder
    }
    
    private func keyFor(_ ask: ImageAsk) -> String {
        let path = ask.imageURL.absoluteString
        let key: String
        if ask.atSize == .zero {
            key = path
        } else {
            key = "\(path)@\(ask.atSize.width)x\(ask.atSize.width)"
        }

        return key.normalized()
    }
}

private extension String {
    static let replaced = [" ", ":", "/", "?", "=", "*"]

    func normalized() -> String {
        var normalized = self
        
        for replace in String.replaced {
            normalized = normalized.replacingOccurrences(of: replace, with: "_")
        }
        
        return normalized
    }
}

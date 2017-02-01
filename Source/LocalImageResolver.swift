/*
 * Copyright 2017 Coodly LLC
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

import Foundation

public protocol LocalImageResolver {
    func hasImage(for ask: ImageAsk) -> Bool
    func image(for ask: ImageAsk) -> UIImage?
}

public extension LocalImageResolver {
    func hasImage(for ask: ImageAsk) -> Bool {
        let path = localPath(for: ask)
        return FileManager.default.fileExists(atPath: path.path)
    }
    
    func image(for ask: ImageAsk) -> UIImage? {
        let path = localPath(for: ask)
        let data = try! Data(contentsOf: path)
        return UIImage(data: data)!
    }
}

internal extension LocalImageResolver {
    fileprivate func localPath(for ask: ImageAsk) -> URL {
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
    
    internal func save(_ data: Data, for ask: ImageAsk) {
        let path = localPath(for: ask)
        do {
            try data.write(to: path, options: .atomicWrite)
        } catch let error as NSError {
            Logging.log("Image save error: \(error)")
        }
    }
    
    private func keyFor(_ ask: ImageAsk) -> String {
        let path = ask.url.absoluteString
        let key = path
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

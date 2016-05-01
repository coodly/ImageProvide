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
    
    public init(fetch: RemoteFetch) {
        remoteFetch = fetch
    }
    
    public func hasImage(forAsk ask: ImageAsk) -> Bool {
        let path = localPathFor(ask)
        return NSFileManager.defaultManager().fileExistsAtPath(path.path!)
    }
    
    public func image(forAsk ask: ImageAsk) -> UIImage? {
        let path = localPathFor(ask)
        let data = NSData(contentsOfURL: path)!
        return UIImage(data: data)!
    }
    
    public func retrieveImage(forAsk ask: ImageAsk, completion:(UIImage?) -> ()) {
        remoteFetch.fetchImage(forAsk: ask) {
            data, error in
            
            guard let data = data, image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self.save(data, forAsk: ask)
            completion(image)
        }
    }
    
    private func save(data: NSData, forAsk ask: ImageAsk) {
        let path = localPathFor(ask)
        do {
            try data.writeToURL(path, options: .AtomicWrite)
        } catch let error as NSError {
            print("Image save error: \(error)")
        }
    }
    
    private func localPathFor(ask: ImageAsk) -> NSURL {
        let key = keyFor(ask)
        return cachePath().URLByAppendingPathComponent(key)
    }
    
    private func cachePath() -> NSURL {
        let identifier = NSBundle.mainBundle().bundleIdentifier!
        let cache = "\(identifier).images"
        let cachesFolder = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last!
        let imageCacheFolder = cachesFolder.URLByAppendingPathComponent(cache)
        if !NSFileManager.defaultManager().fileExistsAtPath(imageCacheFolder.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(imageCacheFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        
        return imageCacheFolder
    }
    
    private func keyFor(ask: ImageAsk) -> String {
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
            normalized = normalized.stringByReplacingOccurrencesOfString(replace, withString: "_")
        }
        
        return normalized
    }
}
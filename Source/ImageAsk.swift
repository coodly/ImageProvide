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

import Foundation

typealias AskCompletionClosure = (UIImage?) -> ()

public class ImageAsk {
    public let url: URL
    internal let action: AfterAction?
    
    public init(url: URL, after: AfterAction? = nil) {
        self.url = url
        self.action = after
    }
    
    internal func cacheKey(withActions: Bool = true) -> String {
        let path = url.absoluteString
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


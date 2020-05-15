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

internal class FetchOperation: ConcurrentOperation, LocalImageResolver {
    private let fetch: RemoteFetch
    internal let ask: ImageAsk
    private let completion: ImageClosure
    
    init(fetch: RemoteFetch, ask: ImageAsk, completion: @escaping ImageClosure) {
        self.fetch = fetch
        self.ask = ask
        self.completion = completion
    }
    
    override func main() {
        let callCompletionOnMain: ((PlatformImage?) -> ()) = {
            image in
            
            DispatchQueue.main.async {
                self.completion(image)
                self.finish()
            }
        }
        
        let processedKey = ask.cacheKey
        if hasImage(for: processedKey) {
            DispatchQueue.global(qos: .background).async {
                let image = self.image(for: processedKey)
                callCompletionOnMain(image)
            }
            return
        }
        
        /*let steps = ask.actionChain
        let reversed = steps.reversed()
        for step in reversed {
            if hasImage(for: step.cacheKey()) {
                DispatchQueue.global(qos: .background).async {
                    var result: PlatformImage?
                    defer {
                        callCompletionOnMain(result)
                    }
                    
                    guard let originalData = self.data(for: originalKey) else {
                        return
                    }
                    
                    guard let processed = action.process(originalData), let image = ImageCreate.image(from: processed) else {
                        result = ImageCreate.image(from: originalData)
                        return
                    }
                    
                    self.save(processed, for: processedKey)
                    result = image
                }
                return
            }
        }*/
        
        fetch.fetchImage(for: ask) {
            data, response, error in
            
            if let error = error {
                Logging.log("Retrieve image error: \(error)")
                callCompletionOnMain(nil)
                return
            }

            DispatchQueue.global(qos: .background).async {
                var result: PlatformImage?
                defer {
                    callCompletionOnMain(result)
                }

                guard let data = data else {
                    return
                }
                
                // checking that have valid image data for caching
                if let original = ImageCreate.image(from: data) {
                    result = original
                    self.save(data, for: self.ask.cacheKey)
                }
                
                /*if let action = self.ask.action, let processed = action.process(data), let created = ImageCreate.image(from: processed) {
                    result = created
                    self.save(processed, for: self.ask.cacheKey(withActions: true))
                }*/
            }
        }
    }
}

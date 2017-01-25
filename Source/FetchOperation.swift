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
import UIKit

internal class FetchOperation: ConcurrentOperation, LocalImageResolver {
    private let fetch: RemoteFetch
    private let ask: ImageAsk
    private let completion: ImageClosure
    
    init(fetch: RemoteFetch, ask: ImageAsk, completion: @escaping ImageClosure) {
        self.fetch = fetch
        self.ask = ask
        self.completion = completion
    }
    
    override func main() {
        if hasImage(for: ask) {
            let image = self.image(for: ask)
            completion(image)
            self.finish()
            return
        }
        
        fetch.fetchImage(for: ask) {
            data, response, error in
            
            defer {
                self.finish()
            }
            
            if let error = error {
                Logging.log("Retrieve image error: \(error)")
                self.completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                self.completion(nil)
                return
            }
            
            self.save(data, for: self.ask)
            self.completion(image)
        }
    }
}

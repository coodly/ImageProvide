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

internal typealias ImageClosure = ((UIImage?) -> ())

public class ImageSource: LocalImageResolver {
    private let remoteFetch: RemoteFetch
    private var asks = [ImageAsk]()
    private let queue: DispatchQueue = DispatchQueue(label: "Image ask queue")
    private let operationsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Image fetch operations queue"
        queue.qualityOfService = .utility
        return queue
    }()
    
    public init(fetch: RemoteFetch) {
        remoteFetch = fetch
    }
    
    public func retrieveImage(for ask: ImageAsk, completion: @escaping (UIImage?) -> ()) {
        let op = FetchOperation(fetch: remoteFetch, ask: ask, completion: completion)
        operationsQueue.addOperation(op)
    }
}

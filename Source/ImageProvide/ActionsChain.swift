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

internal class ActionsChain {
    internal let steps: [ImageAsk]
    internal var repository: LocalRepository!
    internal init(steps: [ImageAsk]) {
        self.steps = steps
    }
    
    internal func canResolveIn(repository: LocalRepository? = nil) -> Bool {
        (repository ?? self.repository).hasImage(for: steps.first!.cacheKey)
    }
    
    internal func process(completion: ((PlatformImage?) -> Void)) {
        for step in steps {
            if repository.hasImage(for: step.cacheKey) {
                continue
            }

            autoreleasepool {
                process(step)
            }
        }
        
        completion(repository.image(for: steps.last?.cacheKey ?? "-"))
    }
    
    private func process(_ step: ImageAsk) {
        guard let previous = step.preceding else {
            return
        }

        guard let action = step.lastAction else {
            return
        }

        guard let data = repository.data(for: previous.cacheKey) else {
            return
        }

        guard let image = ImageCreate.image(from: data) else {
            return
        }
        
        guard let processed = action.process(image) else {
            return
        }
        
        let saved: Data?
        switch data.imageContentType {
        case .jpg:
            saved = processed.jpegData(compressionQuality: 0.8)
        case .png:
            saved = processed.pngData()
        default:
            Logging.error("Unhandled content type: \(data.imageContentType)")
            saved = nil
        }
        
        guard let written = saved else {
            return
        }
        
        repository.save(written, for: step.cacheKey)
    }
}

// https://stackoverflow.com/questions/4147311/finding-image-type-from-nsdata-or-uiimage
private extension Data {
    enum ImageContentType: String {
        case jpg, png, gif, tiff, unknown

        var fileExtension: String {
            return self.rawValue
        }
    }

    var imageContentType: ImageContentType {

        var values = [UInt8](repeating: 0, count: 1)

        self.copyBytes(to: &values, count: 1)

        switch (values[0]) {
        case 0xFF:
            return .jpg
        case 0x89:
            return .png
        case 0x47:
           return .gif
        case 0x49, 0x4D :
           return .tiff
        default:
            return .unknown
        }
    }
}

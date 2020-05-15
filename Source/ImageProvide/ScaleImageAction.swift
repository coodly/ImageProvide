/*
* Copyright 2020 Coodly LLC
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
import CoreGraphics

public class ScaleImageAction: AfterAction {
    public enum Mode: String {
        case aspectFit
        case aspectFill
    }
    
    public lazy var key: String = "\(self.size.width)x\(self.size.height)x\(self.mode.rawValue)"
    
    private let size: CGSize
    private let mode: Mode
    public init(size: CGSize, mode: Mode) {
        self.size = size
        self.mode = mode
    }
    
    public func process(_ data: Data) -> Data? {
        return data
    }
}

extension ImageAsk {
    public func scaled(to size: CGSize, mode: ScaleImageAction.Mode) -> ImageAsk {
        append(action: ScaleImageAction(size: size, mode: mode))
        return self
    }
}

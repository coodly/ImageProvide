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

public protocol Logger {
    func debug<T>(_ object: T, file: String, function: String, line: Int)
    func error<T>(_ object: T, file: String, function: String, line: Int)
    func verbose<T>(_ object: T, file: String, function: String, line: Int)
}

public class Logging {
    private var logger: Logger?
    
    internal static let sharedInstance = Logging()
    
    public class func set(logger: Logger) {
        sharedInstance.logger = logger
    }
    
    internal class func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        sharedInstance.logger?.debug(object, file: file, function: function, line: line)
    }

    internal class func error<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        sharedInstance.logger?.error(object, file: file, function: function, line: line)
    }

    internal class func verbose<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        sharedInstance.logger?.verbose(object, file: file, function: function, line: line)
    }
}

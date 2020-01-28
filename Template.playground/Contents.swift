// Design Patterns: Template Method

import AVFoundation
import Photos

// Services

typealias AuthorizationCompletion = (status: Bool, message: String)

class PermissionService: NSObject {
    private var message: String = ""
    
    func authorize(_ completion: @escaping (AuthorizationCompletion) -> Void) {
        let status = checkStatus()
        
        guard !status else {
            complete(with: status, completion)
            return
        }
        
        requestAuthorization { [weak self] status in
            self?.complete(with: status, completion)
        }
    }

    func checkStatus() -> Bool {
        return false
    }
    
    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        completion(false)
    }
    
    func formMessage(with status: Bool) {
        let messagePrefix = status ? "You have access to " : "You haven't access to "
        let nameOfCurrentPermissionService = String(describing: type(of: self))
        let nameOfBasePermissionService = String(describing: type(of: PermissionService.self))
        let messageSuffix = nameOfCurrentPermissionService.components(separatedBy: nameOfBasePermissionService).first!
        message = messagePrefix + messageSuffix
    }
    
    private func complete(with status: Bool, _ completion: @escaping (AuthorizationCompletion) -> Void) {
        formMessage(with: status)
        
        let result = (status: status, message: message)
        completion(result)
    }
}

class CameraPermissionService: PermissionService {
    override func checkStatus() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video).rawValue
        return status == AVAuthorizationStatus.authorized.rawValue
    }
    
    override func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { status in
            completion(status)
        }
    }
}

class PhotoPermissionService: PermissionService {
    override func checkStatus() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus().rawValue
        return status == PHAuthorizationStatus.authorized.rawValue
    }
    
    override func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            completion(status.rawValue == PHAuthorizationStatus.authorized.rawValue)
        }
    }
}

// Usage

let permissionServices = [CameraPermissionService(), PhotoPermissionService()]

for permissionService in permissionServices {
    permissionService.authorize { (_, message) in
        print(message)
    }
}

// Result:
// You have access to Camera
// You have access to Photo

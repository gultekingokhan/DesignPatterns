// Design Patterns: Facade

import AVFoundation

// Services (may be not include in blog post)

struct FileService {
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var contentsOfDocumentDirectory: [URL] {
        return try! FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
    }
    
    func path(withPathComponent component: String) -> URL {
        return documentDirectory.appendingPathComponent(component)
    }
    
    func removeItem(at index: Int) {
        let url = contentsOfDocumentDirectory[index]
        try! FileManager.default.removeItem(at: url)
    }
}

protocol AudioSessionServiceDelegate: class {
    func audioSessionService(_ audioSessionService: AudioSessionService, recordPermissionDidAllow allowed: Bool)
}

class AudioSessionService {
    weak var delegate: AudioSessionServiceDelegate?
    
    func setupSession() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker])
        try! AVAudioSession.sharedInstance().setActive(true)
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                guard let strongSelf = self, let delegate = strongSelf.delegate else {
                    return
                }
                
                delegate.audioSessionService(strongSelf, recordPermissionDidAllow: allowed)
            }
        }
    }
    
    func deactivateSession() {
        try! AVAudioSession.sharedInstance().setActive(false)
    }
}

struct RecorderService {
    private var isRecording = false
    private var recorder: AVAudioRecorder!
    private var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    mutating func startRecord() {
        guard !isRecording else {
            return
        }
        
        isRecording = !isRecording
        recorder = try! AVAudioRecorder(url: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
        recorder.record()
    }
    
    mutating func stopRecord() {
        guard isRecording else {
            return
        }
        
        isRecording = !isRecording
        recorder.stop()
    }
}

protocol PlayerServiceDelegate: class {
    func playerService(_ playerService: PlayerService, playingDidFinish success: Bool)
}

class PlayerService: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer!
    private var url: URL
    weak var delegate: PlayerServiceDelegate?
    
    init(url: URL) {
        self.url = url
    }
    
    func startPlay() {
        player = try! AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.play()
    }
    
    func stopPlay() {
        player.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerService(self, playingDidFinish: flag)
    }
}

// Facade

protocol AudioFacadeDelegate: class {
    func audioFacadePlayingDidFinish(_ audioFacade: AudioFacade)
}

class AudioFacade: PlayerServiceDelegate {
    private let audioSessionService = AudioSessionService()
    private let fileService = FileService()
    private let fileFormat = ".m4a"
    private var playerService: PlayerService!
    private var recorderService: RecorderService!
    weak var delegate: AudioFacadeDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return dateFormatter
    }()
    
    init() {
        audioSessionService.setupSession()
    }
    
    deinit {
        audioSessionService.deactivateSession()
    }
    
    func startRecord() {
        let fileName = dateFormatter.string(from: Date()).appending(fileFormat)
        let url = fileService.path(withPathComponent: fileName)
        recorderService = RecorderService(url: url)
        recorderService.startRecord()
    }
    
    func stopRecord() {
        recorderService.stopRecord()
    }
    
    func numberOfRecords() -> Int {
        return fileService.contentsOfDocumentDirectory.count
    }
    
    func nameOfRecord(at index: Int) -> String {
        let url = fileService.contentsOfDocumentDirectory[index]
        return url.lastPathComponent
    }
    
    func removeRecord(at index: Int) {
        fileService.removeItem(at: index)
    }
    
    func playRecord(at index: Int) {
        let url = fileService.contentsOfDocumentDirectory[index]
        playerService = PlayerService(url: url)
        playerService.delegate = self
        playerService.startPlay()
    }
    
    func stopPlayRecord() {
        playerService.stopPlay()
    }
    
    func playerService(_ playerService: PlayerService, playingDidFinish success: Bool) {
        if success {
            delegate?.audioFacadePlayingDidFinish(self)
        }
    }
}

// Usage

let audioFacade = AudioFacade()
audioFacade.numberOfRecords()

// Result:
// 0

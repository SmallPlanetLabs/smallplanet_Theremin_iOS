/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 View controller for camera interface.
 */

import UIKit
import AVFoundation
import CoreVideo
import Photos
import MobileCoreServices

class CameraViewController: UIViewController, AVCaptureDepthDataOutputDelegate {
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
    private let dataOutputQueue = DispatchQueue(label: "video data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let depthDataOutput = AVCaptureDepthDataOutput()
    private var currentDepthPixelBuffer: CVPixelBuffer?
    private var renderingEnabled = true
    private var depthVisualizationEnabled = true
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    
    ///------
    
    private var oscillators = [VWWSynthesizer]()
 
    //------
    
    @IBOutlet weak private var waveTypeSlider : UISlider!
    @IBOutlet weak private var waveTypeLabel : UILabel!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveTypeSlider.maximumValue = 1;
        waveTypeSlider.minimumValue = 0;
        
        for _ in 0...3 {
            let synthesizer = VWWSynthesizer(amplitude: 0.2, frequencyLeft: 100, frequencyRight: 100)
            synthesizer!.setWaveType(VWWWaveTypeSine)
            synthesizer?.start()
            oscillators.append(synthesizer!)
        }
        updateWaveTypeLabelForWaveType(VWWWaveTypeSine);
     
        // Check video authorization status, video access is required
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant video access
             We suspend the session queue to delay session setup until the access request has completed
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
    }
    
//    @objc
//    func didEnterBackground(notification: NSNotification) {
//        // Free up resources
//        dataOutputQueue.async {
//            self.renderingEnabled = false
//            self.currentDepthPixelBuffer = nil
//        }
//    }
//
//    @objc
//    func willEnterForground(notification: NSNotification) {
//        dataOutputQueue.async {
//            self.renderingEnabled = true
//        }
//    }

    // MARK: - KVO and Notifications
    
    private var sessionRunningContext = 0
    
    // MARK: - Session Management
    
    // Call this on the session queue
    private func configureSession() {
        if setupResult != .success { return }
        
        let defaultVideoDevice: AVCaptureDevice? = videoDeviceDiscoverySession.devices.first
        
        guard let videoDevice = defaultVideoDevice else {
            print("Could not find any video device")
            setupResult = .configurationFailed
            return
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        // Add a video input
        guard session.canAddInput(videoDeviceInput) else {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.addInput(videoDeviceInput)
        
        // Add a depth data output
        if session.canAddOutput(depthDataOutput) {
            session.addOutput(depthDataOutput)
            depthDataOutput.setDelegate(self, callbackQueue: dataOutputQueue)
            depthDataOutput.isFilteringEnabled = true
            if let connection = depthDataOutput.connection(with: .depthData) {
                connection.isEnabled = depthVisualizationEnabled
            } else {
                print("No AVCaptureConnection")
            }
        } else {
            print("Could not add depth data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    @IBAction func sliderValueChanged(_ slider : UISlider) {
        NSLog("slider.value = \(slider.value)")
        
        var waveTypes = [VWWWaveTypeSine, VWWWaveTypeSawtooth, VWWWaveTypeSquare, VWWWaveTypeTriangle]
        let waveIncrement = 1/waveTypes.count;
        
        let currentWaveType = self.oscillators.first!.waveType()
        let newWaveIndex = Int(floor(Float(waveTypes.count) * slider.value))
        if (newWaveIndex < waveTypes.count) {
            let newWaveType = waveTypes[newWaveIndex]
            if (newWaveType != currentWaveType) {
                for osc in self.oscillators {
                    osc.setWaveType(newWaveType)
                }
            }
            updateWaveTypeLabelForWaveType(newWaveType)
        }
    }
    
    private func updateWaveTypeLabelForWaveType(_ waveType: VWWWaveType) {
    
        var stringRepresentation = "Sine";
        switch waveType {
            case VWWWaveTypeSawtooth:
                stringRepresentation = "Sawtooth";
            case VWWWaveTypeTriangle:
                stringRepresentation = "Triangle";
            case VWWWaveTypeSquare:
                stringRepresentation = "Square";
            default:
                break;
        }
        
        self.waveTypeLabel.text = stringRepresentation;
    }
    
    // MARK: - Depth Data Output Delegate
    
    func depthDataOutput(_ depthDataOutput: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
  
        
        NSLog("depthData output")
        
        processDepth(depthData: depthData)
    }
    
    func processDepth(depthData: AVDepthData) {
        if !renderingEnabled {
            return
        }
        
        if !depthVisualizationEnabled {
            return
        }
        
//        if !videoDepthConverter.isPrepared {
//            /*
//             outputRetainedBufferCountHint is the number of pixel buffers we expect to hold on to from the renderer. This value informs the renderer
//             how to size its buffer pool and how many pixel buffers to preallocate. Allow 2 frames of latency to cover the dispatch_async call.
//             */
//            var depthFormatDescription: CMFormatDescription?
//            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, depthData.depthDataMap, &depthFormatDescription)
//            videoDepthConverter.prepare(with: depthFormatDescription!, outputRetainedBufferCountHint: 2)
//        }
//
//        guard let depthPixelBuffer = videoDepthConverter.render(pixelBuffer: depthData.depthDataMap) else {
//            print("Unable to process depth")
//            return
//        }

        guard let pixelFormat = DepthUtlity.pixelFormatForDepthPixelBuffer(depthDataMap: depthData.depthDataMap) else {
            return;
        }

        
        let depthA = averageFromDepthPixelBuffer(depthData.depthDataMap, pixelFormat)
        
        let maxDepth : Float = 3.0;
        let minDepth : Float = 0.1;

        if (depthA > minDepth && depthA < maxDepth) {

            // make between 0 and 1
            let normalizedDepthValue = (depthA - minDepth)/(maxDepth - minDepth);

            NSLog("normalized = %.2f", normalizedDepthValue);

            let maxFrequency : Float = 3000;
            let minimumFrequncy : Float = 100;

            let newFundamental = ((maxFrequency - minimumFrequncy) * normalizedDepthValue) + minimumFrequncy;
            var newFrequency = VWWSynthesizerNotes.getClosestNote(forFrequency: newFundamental, in: VWWKeyTypeCMajor);

            NSLog("newFrequency = \(newFrequency)");
            
            var i = 0;
            for synthesizer : VWWSynthesizer in self.oscillators {

                synthesizer.setMuted(false);
                
                if (i == 1) {
                    newFrequency = newFrequency * (5/4);
                } else if (i == 2) {
                    newFrequency = newFrequency * (3/2);
                }

                synthesizer.setFrequencyLeft(newFrequency);
                synthesizer.setFrequencyRight(newFrequency);

                i += 1;
            }

//            NSLog("averageDepth = \(averageDepth)")
        } else {
            for synthesizer : VWWSynthesizer in self.oscillators {
                synthesizer.setMuted(true);
            }
        }
    }
}


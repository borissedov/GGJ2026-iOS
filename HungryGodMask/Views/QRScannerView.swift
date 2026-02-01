//
//  QRScannerView.swift
//  HungryGodMask
//
//  QR code scanner for joining multiplayer games
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Binding var scannedCode: String?
    @Binding var manualCode: String
    @Binding var navigateToPlayerName: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var isScanning = true
    @State private var showManualEntry = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                }
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Scanner or Manual Entry
                if showManualEntry {
                    manualEntryView
                } else {
                    scannerView
                }
                
                Spacer()
                
                // Toggle button
                Button(action: {
                    showManualEntry.toggle()
                }) {
                    Text(showManualEntry ? "Scan QR Code" : "Enter Code Manually")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            }
        }
    }
    
    private var scannerView: some View {
        VStack(spacing: 20) {
            Text("Scan QR Code")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Point camera at the QR code on screen")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // QR Scanner placeholder (will show camera feed)
            QRCodeScannerRepresentable(
                scannedCode: $scannedCode,
                onCodeScanned: handleCodeScanned
            )
            .frame(width: 300, height: 300)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 3)
            )
        }
    }
    
    private var manualEntryView: some View {
        VStack(spacing: 20) {
            Text("Enter Join Code")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Type the code shown on screen")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            TextField("JOIN CODE", text: $manualCode)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .onChange(of: manualCode) { _, newValue in
                    manualCode = newValue.uppercased()
                }
            
            Button(action: {
                if manualCode.count >= 6 {
                    handleCodeScanned(manualCode)
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250)
                    .padding()
                    .background(manualCode.count >= 6 ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(manualCode.count < 6)
        }
    }
    
    private func handleCodeScanned(_ code: String) {
        // Extract join code from URL if it's a deep link
        let joinCode = extractJoinCode(from: code)
        
        print("📱 QR CODE SCANNED:")
        print("   Raw: \(code)")
        print("   Extracted: \(joinCode)")
        
        scannedCode = joinCode
        navigateToPlayerName = true
    }
    
    private func extractJoinCode(from input: String) -> String {
        // If it's a deep link URL (e.g., hungrygod://join/XL3JNE)
        if let url = URL(string: input),
           let scheme = url.scheme,
           scheme.lowercased() == "hungrygod",
           url.host == "join" || url.pathComponents.contains("join") {
            
            // Extract the code from the path
            let pathComponents = url.pathComponents.filter { $0 != "/" && $0.lowercased() != "join" }
            if let code = pathComponents.first {
                return code.uppercased()
            }
        }
        
        // If it's a direct code, just return it uppercased
        return input.uppercased()
    }
}

// MARK: - QR Code Scanner Representable

struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    var onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let scanner = QRCodeScannerViewController()
        scanner.onCodeScanned = onCodeScanned
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - QR Code Scanner View Controller

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onCodeScanned: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showCameraError()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showCameraError()
            return
        }
        
        if let session = captureSession, session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            showCameraError()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if let session = captureSession, session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showCameraError()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            // Stop scanning
            captureSession?.stopRunning()
            
            // Haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Notify
            onCodeScanned?(stringValue)
        }
    }
    
    private func showCameraError() {
        let label = UILabel()
        label.text = "Camera not available"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.frame = view.bounds
        view.addSubview(label)
    }
}

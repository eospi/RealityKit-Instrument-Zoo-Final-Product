//
//  ViewController.swift
//  Instrument Zoo
//
//  Created by Ethan Saadia on 1/15/20.
//  Copyright © 2020 Ethan Saadia. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InstrumentComponent.registerComponent()

        setupGestureRecognizer()
        
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.anchors.append(anchor)
                
        let instrumentComponents: [InstrumentComponent] = [
            InstrumentComponent(audioFile: AudioFiles.guitar),
            InstrumentComponent(audioFile: AudioFiles.trumpet),
            InstrumentComponent(audioFile: AudioFiles.drums)
        ]
        
        let xCoordinates: [Float] = [-0.7, 0, 0.7]
        
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: InstrumentFiles.guitar)
            .append(ModelEntity.loadModelAsync(named: InstrumentFiles.trumpet))
            .append(ModelEntity.loadModelAsync(named: InstrumentFiles.drums))
            .collect()
            .sink(receiveCompletion: { completion in
                cancellable?.cancel()
            }, receiveValue: { entities in
                for (index, entity) in entities.enumerated() {
                    let instrument = InstrumentEntity(modelEntity: entity)
                    instrument.instrument = instrumentComponents[index]
                    
                    anchor.addChild(instrument)
 
                    instrument.position.x = xCoordinates[index]
                    instrument.position.z = -1
                }
                
                cancellable?.cancel()
            })
    }
}

extension ViewController {
    func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        guard let selectedInstrument = arView.entity(at: tapLocation) as? InstrumentEntity else { return }
        
        selectedInstrument.scale()
        selectedInstrument.makeSound()
        
        var cancellable: Cancellable? = nil
        cancellable = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: selectedInstrument) { event in
            selectedInstrument.shrink()
            cancellable?.cancel()
        }
    }
}

extension ViewController {
    struct InstrumentFiles {
        static let guitar = "guitar.usdz"
        static let trumpet = "trumpet.usdz"
        static let drums = "drums.usdz"
    }
    
    struct AudioFiles {
        static let guitar = "guitar.wav"
        static let trumpet = "trumpet.mp3"
        static let drums = "drums.wav"
    }
}

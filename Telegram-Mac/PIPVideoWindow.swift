//
//  PIPVideoWindow.swift
//  Telegram
//
//  Created by keepcoder on 26/04/2017.
//  Copyright © 2017 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import AVKit
import SwiftSignalKitMac

fileprivate class PIPVideoWindow: NSPanel {
    fileprivate let playerView:AVPlayerView
    private let rect:NSRect
    private let close:ImageButton = ImageButton()
    private let openGallery:ImageButton = ImageButton()
    fileprivate var forcePaused: Bool = false
    fileprivate let item: MGalleryVideoItem
    fileprivate weak var _delegate: InteractionContentViewProtocol?
    fileprivate let _contentInteractions:ChatMediaGalleryParameters?
    fileprivate let _type: GalleryAppearType
    init(_ player:AVPlayerView, item: MGalleryVideoItem, origin:NSPoint, delegate:InteractionContentViewProtocol? = nil, contentInteractions:ChatMediaGalleryParameters? = nil, type: GalleryAppearType) {
        
        self._delegate = delegate
        self._contentInteractions = contentInteractions
        self._type = type
        
        self.playerView = player
        self.rect = NSMakeRect(origin.x, origin.y, player.frame.width, player.frame.height)
        self.item = item
        super.init(contentRect: rect, styleMask: [.closable, .borderless, .resizable, .nonactivatingPanel], backing: .buffered, defer: true)
        
        
        close.autohighlight = false
        close.set(image: #imageLiteral(resourceName: "Icon_InlineResultCancel").precomposed(NSColor.white.withAlphaComponent(0.9)), for: .Normal)
       
        close.set(handler: { [weak self] _ in
            self?.hide()
        }, for: .Click)
        
        close.setFrameSize(40,40)
        
        close.layer?.cornerRadius = 20
        close.style = ControlStyle(backgroundColor: .blackTransparent, highlightColor: .grayIcon)
        close.layer?.opacity = 0.8
        
        
        openGallery.autohighlight = false
        openGallery.set(image: #imageLiteral(resourceName: "Icon_PipOff").precomposed(NSColor.white.withAlphaComponent(0.9)), for: .Normal)
        
        openGallery.set(handler: { [weak self] _ in
            self?._openGallery()
        }, for: .Click)
        
        openGallery.setFrameSize(40,40)
        
        openGallery.layer?.cornerRadius = 20
        openGallery.style = ControlStyle(backgroundColor: .blackTransparent, highlightColor: .grayIcon)
        openGallery.layer?.opacity = 0.8
        
        
        
        
        self.contentView?.wantsLayer = true;
        self.contentView?.layer?.cornerRadius = 4;
        
        self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor;
        self.backgroundColor = .clear;
        
        player.autoresizingMask = [.width, .height];
        
        player.setFrameOrigin(0,0)
        player.controlsStyle = .minimal
        player.removeFromSuperview()
        self.contentView?.addSubview(player)
        
        self.contentView?.addSubview(close)
        self.contentView?.addSubview(openGallery)

        
        self.level = .screenSaver
        self.isMovableByWindowBackground = true
    }
    
    
    func hide() {
        orderOut(nil)
        playerView.player?.pause()
        window = nil
    }
    
    func _openGallery() {
        close.change(opacity: 0, removeOnCompletion: false) { [weak close] completed in
            close?.removeFromSuperview()
        }
        openGallery.change(opacity: 0, removeOnCompletion: false) { [weak openGallery] completed in
            openGallery?.removeFromSuperview()
        }
        setFrame(rect, display: true, animate: true)
        hide()
        showGalleryFromPip(item: item, delegate: _delegate, contentInteractions: _contentInteractions, type: _type)
    }
    
    override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
        return 0.2
    }
    
    override func setFrame(_ frameRect: NSRect, display displayFlag: Bool, animate animateFlag: Bool) {
        //let closePoint = NSMakePoint(10, frameRect.height - 50)
      //  let openPoint = NSMakePoint(closePoint.x + close.frame.width + 10, frameRect.height - 50)
        

        super.setFrame(frameRect, display: displayFlag, animate: animateFlag)
    }
    

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        close.change(opacity: 1, animated: true)
        openGallery.change(opacity: 1, animated: true)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        close.change(opacity: 0, animated: true)
        openGallery.change(opacity: 0, animated: true)
    }
    
    override func makeKeyAndOrderFront(_ sender: Any?) {
        super.makeKeyAndOrderFront(sender)
        
        Queue.mainQueue().justDispatch {
            if let screen = NSScreen.main {
                let convert_s = self.playerView.frame.size.fitted(NSMakeSize(300, 300))
                self.minSize = convert_s
                self.aspectRatio = convert_s
                
                let closePoint = NSMakePoint(10, convert_s.height - 50)
                let openPoint = NSMakePoint(closePoint.x + self.close.frame.width + 10, convert_s.height - 50)
                
                self.close.change(pos: closePoint, animated: false)
                self.openGallery.change(pos: openPoint, animated: false)

                self.setFrame(NSMakeRect(screen.frame.maxX - convert_s.width - 30, screen.frame.maxY - convert_s.height - 50, convert_s.width, convert_s.height), display: true, animate: true)
                

            }
        }
    }
    

}

private var window: PIPVideoWindow?

func showPipVideo(_ player:AVPlayerView, item: MGalleryVideoItem, origin: NSPoint, delegate:InteractionContentViewProtocol? = nil, contentInteractions:ChatMediaGalleryParameters? = nil, type: GalleryAppearType) {
    window = PIPVideoWindow(player, item: item, origin: origin, delegate: delegate, contentInteractions: contentInteractions, type: type)
    window?.makeKeyAndOrderFront(nil)
}

func pausepip() {
    window?.playerView.player?.pause()
    window?.forcePaused = true
}

func playPipIfNeeded() {
    if let forcePaused = window?.forcePaused, forcePaused {
        window?.playerView.player?.play()
    }
}



func closePipVideo() {
    window?.hide()
    window = nil
}

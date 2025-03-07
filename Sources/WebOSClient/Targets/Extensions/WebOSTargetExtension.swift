//
//  WebOSTargetExtension.swift
//  Created by Yaroslav Sedyshev on 09.12.2023.
//

import Foundation

extension WebOSTarget: WebOSTargetProtocol {
    public var uri: String? {
        switch self {
        case .castPhoto:
            return "ssap://media.viewer/open"
        case .stopCasting:
            return "ssap://media.viewer/close"
        case .setPin:
            return "ssap://pairing/setPin"
        case .volumeUp:
            return "ssap://audio/volumeUp"
        case .volumeDown:
            return "ssap://audio/volumeDown"
        case .getVolume:
            return "ssap://audio/getVolume"
        case .setVolume:
            return "ssap://audio/setVolume"
        case .setMute:
            return "ssap://audio/setMute"
        case .play:
            return "ssap://media.controls/play"
        case .pause:
            return "ssap://media.controls/pause"
        case .stop:
            return "ssap://media.controls/stop"
        case .rewind:
            return "ssap://media.controls/rewind"
        case .fastForward:
            return "ssap://media.controls/fastForward"
        case .getSoundOutput:
            return "ssap://audio/getSoundOutput"
        case .changeSoundOutput:
            return "ssap://audio/changeSoundOutput"
        case .toast:
            return "ssap://system.notifications/createToast"
        case .getPowerState:
            return "ssap://com.webos.service.tvpower/power/getPowerState"
        case .screenOff:
            return "ssap://com.webos.service.tvpower/power/turnOffScreen"
        case .screenOn:
            return "ssap://com.webos.service.tvpower/power/turnOnScreen"
        case .systemInfo:
            return "ssap://com.webos.service.update/getCurrentSWInformation"
        case .macAddressInfo:
            return "ssap://com.webos.service.connectionmanager"
        case .turnOff:
            return "ssap://system/turnOff"
        case .listApps:
            return "ssap://com.webos.applicationManager/listApps"
        case .getForegroundApp:
            return "ssap://com.webos.applicationManager/getForegroundAppInfo"
        case .getForegroundAppMediaStatus:
            return "ssap://com.webos.media/getForegroundAppInfo"
        case .launchApp:
            return "ssap://system.launcher/launch"
        case .closeApp:
            return "ssap://system.launcher/close"
        case .insertText:
            return "ssap://com.webos.service.ime/insertText"
        case .sendEnterKey:
            return "ssap://com.webos.service.ime/sendEnterKey"
        case .deleteCharacters:
            return "ssap://com.webos.service.ime/deleteCharacters"
        case .registerRemoteKeyboard:
            return "ssap://com.webos.service.ime/registerRemoteKeyboard"
        case .getPointerInputSocket:
            return "ssap://com.webos.service.networkinput/getPointerInputSocket"
        case .channelUp:
            return "ssap://tv/channelUp"
        case .channelDown:
            return "ssap://tv/channelDown"
        case .listSources:
            return "ssap://tv/getExternalInputList"
        case .setSource:
            return "ssap://tv/switchInput"
        case .getPictureSettings, .getSoundMode:
            return "ssap://settings/getSystemSettings"
        default:
            return nil
        }
    }

    public var request: WebOSRequest {
        switch self {
        case .register(let pairingType, let clientKey):
            let payload = WebOSRequestPayload(
                forcePairing: false,
                manifest: WebOSRequestManifest(),
                pairingType: pairingType.rawValue,
                clientKey: clientKey
            )
            return .init(type: .register, payload: payload)
        case .setPin(let pin):
            let payload = WebOSRequestPayload(pin: pin)
            return .init(type: .request, uri: uri, payload: payload)
        case .getPowerState(let subscribe),
            .getVolume(let subscribe),
            .getSoundOutput(let subscribe),
            .getForegroundApp(let subscribe),
            .getForegroundAppMediaStatus(let subscribe):
            if let subscribe {
                return .init(type: subscribe ? .subscribe : .unsubscribe, uri: uri)
            }
            return .init(type: .request, uri: uri)
        case .setVolume(let volume):
            let payload = WebOSRequestPayload(volume: volume)
            return .init(type: .request, uri: uri, payload: payload)
        case .castPhoto(let url):
            let payload = WebOSRequestPayload(mediaId: url)
            return .init(type: .request, uri: uri, payload: payload)
        case .stopCasting:
            let payload = WebOSRequestPayload()
            return .init(type: .request, uri: uri, payload: payload)
        case .setMute(let mute):
            let payload = WebOSRequestPayload(mute: mute)
            return .init(type: .request, uri: uri, payload: payload)
        case .changeSoundOutput(let soundOutput):
            let payload = WebOSRequestPayload(output: soundOutput.rawValue)
            return .init(type: .request, uri: uri, payload: payload)
        case .toast(let message, let iconData, let iconExtension):
            let payload = WebOSRequestPayload(
                message: message,
                iconData: iconData,
                iconExtension: iconExtension
            )
            return .init(type: .request, uri: uri, payload: payload)
        case .screenOn, .screenOff:
            let payload = WebOSRequestPayload(standbyMode: "active")
            return .init(type: .request, uri: uri, payload: payload)
        case .launchApp(let appId, let contentId, let params):
            let payload = WebOSRequestPayload(id: appId, contentId: contentId, params: params)
            return .init(type: .request, uri: uri, payload: payload)
        case .closeApp(let appId, let sessionId):
            let payload = WebOSRequestPayload(id: appId, sessionId: sessionId)
            return .init(type: .request, uri: uri, payload: payload)
        case .insertText(let text, let replace):
            let payload = WebOSRequestPayload(text: text, replace: replace)
            return .init(type: .request, uri: uri, payload: payload)
        case .deleteCharacters(let count):
            let payload = WebOSRequestPayload(count: count)
            return .init(type: .request, uri: uri, payload: payload)
        case .registerRemoteKeyboard:
            return .init(type: .subscribe, uri: uri)
        case .setSource(let inputId):
            let payload = WebOSRequestPayload(inputId: inputId)
            return .init(type: .request, uri: uri, payload: payload)
        case .getPictureSettings(let subscribe):
            let payload = WebOSRequestPayload(
                category: "picture",
                keys: [
                    "brightness", "backlight", "contrast", "color",
                ])
            return .init(
                type: subscribe == true ? .subscribe : .unsubscribe, uri: uri, payload: payload)
        case .getSoundMode(let subscribe):
            let payload = WebOSRequestPayload(
                category: "sound", keys: ["soundMode"])
            return .init(
                type: subscribe == true ? .subscribe : .unsubscribe, uri: uri, payload: payload)
        default:
            return .init(type: .request, uri: uri)
        }
    }

}

extension LunaTarget: LunaTargetProtocol {
    public var uri: String {
        switch self {
        case .setPictureSettings(_, _, _, _), .setPictureMode(_), .setSoundMode(_):
            return "luna://com.webos.settingsservice/setSystemSettings"
        }
    }

    public var title: String {
        switch self {
        default:
            return "Setting..."
        }
    }

    public var request: LunaRequest {
        var payload = WebOSRequestPayload()
        let requestType: WebOSRequestType = .request
        switch self {

        case .setPictureSettings(let brightness, let contrast, let color, let backlight):
            payload = WebOSRequestPayload(
                category: "picture",
                settings: SystemSettings(
                    brightness: brightness, contrast: contrast, backlight: backlight, color: color)
            )
        case .setPictureMode(let mode):
            payload = WebOSRequestPayload(
                category: "picture",
                settings: SystemSettings(pictureMode: mode)
            )
        case .setSoundMode(let mode):
            payload = WebOSRequestPayload(
                category: "sound",
                settings: SystemSettings(soundMode: mode)
            )
        }
        return .init(
            type: requestType,
            payload: LunaRequestPayload(
                buttons: [
                    LunaRequestButtonPayload(
                        onClick: uri, params: payload
                    )
                ],
                onClose: LunaRequestCloseAndFailPayload(
                    uri: uri, params: payload
                ),
                onFail: LunaRequestCloseAndFailPayload(
                    uri: uri, params: payload
                ), title: title, message: title))
    }
}

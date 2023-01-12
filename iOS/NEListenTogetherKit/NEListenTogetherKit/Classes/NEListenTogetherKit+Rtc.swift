// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit
/// rtc 扩展
public extension NEListenTogetherKit {
  /// 关闭自己麦克风
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Parameter callback: 回调
  func muteMyAudio(_ callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Mute mu audio.")
    Judge.preCondition({
      guard let local = self.localMember?.account else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to mute my audio. Msg: Can't find LocalMember."
        )
        callback?(NEListenTogetherErrorCode.failed, "Can't find LocalMember", nil)
        return
      }
      self.roomContext!.updateMemberProperty(
        userUuid: local,
        key: MemberPropertyConstants.MuteAudio.key,
        value: MemberPropertyConstants.MuteAudio.off
      ) { code, msg, _ in
        var res = code
        if res == 0 {
          res = Int(self.roomContext!.rtcController.setRecordDeviceMute(muted: true))
          if res == 0 {
            NEListenTogetherLog.successLog(kitTag, desc: "Successfully mute my audio.")
          } else {
            NEListenTogetherLog.errorLog(
              kitTag,
              desc: "Failed to mute my audio. Code: \(res)."
            )
          }
        } else {
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to mute mu audio. Code: \(res). Msg: \(msg ?? "")"
          )
        }
        callback?(res, msg, nil)
      }
    }, failure: callback)
  }

  /// 打开自己麦克风
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Parameter callback: 回调
  func unmuteMyAudio(_ callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Unmute mu audio.")
    Judge.preCondition({
      guard let local = self.localMember?.account else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to mute my audio. Msg: Can't find LocalMember."
        )
        callback?(NEListenTogetherErrorCode.failed, "Can't find LocalMember", nil)
        return
      }
      self.roomContext!.updateMemberProperty(
        userUuid: local,
        key: MemberPropertyConstants.MuteAudio.key,
        value: MemberPropertyConstants.MuteAudio.on
      ) { code, msg, _ in
        var res = code
        if res == 0 {
          res = Int(self.roomContext!.rtcController.setRecordDeviceMute(muted: false))
          if res == 0 {
            NEListenTogetherLog.successLog(kitTag, desc: "Successfully unmute my audio.")
          } else {
            NEListenTogetherLog.errorLog(
              kitTag,
              desc: "Failed to unmute my audio. Code: \(res)"
            )
          }
        } else {
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to unmute my audio. Code: \(res). Msg: \(msg ?? "")"
          )
        }
        callback?(res, msg, nil)
      }
    }, failure: callback)
  }

  @discardableResult
  /// 开启耳返功能
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Parameter volume: 设置耳返音量
  /// - Returns: 0: 代表成功，否则失败
  func enableEarBack(_ volume: UInt32) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Enable earback. Volume: \(volume)")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.enableEarback(volume: volume)
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully enable earback.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to enable earback. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 关闭耳返功能
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Returns: 0: 代表成功，否则失败
  func disableEarBack() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Disable earback.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.disableEarback()
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully disable earback.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to disable earback. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 调节人声音量
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Parameter volume: 音量 范围[0-100]
  /// - Returns: 0: 代表成功，否则失败
  func adjustRecordingSignalVolume(_ volume: UInt32) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Adjust recording signal volume. Volume: \(volume)")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.adjustRecordingSignalVolume(volume: volume)
      if code == 0 {
        self.recordVolume = volume
        NEListenTogetherLog.successLog(
          kitTag,
          desc: "Successfully adjust recording signal volume."
        )
      } else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to adjust recording signal volume. Code: \(code)"
        )
      }
      return code
    }
  }

  @discardableResult
  /// 获取人声音量
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// - Returns: 0: 代表成功，否则失败
  func getRecordingSignalVolume() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get recording signal volume.")
    return Judge.syncCondition {
      return Int(self.recordVolume)
    }
  }

  @discardableResult
  /// 开始播放音乐文件
  ///
  ///  该方法指定本地或在线音频文件来和录音设备采集的音频流进行混音
  ///  支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件或在线 URL
  /// - Parameter option: 创建混音任务配置的选项，包括混音任务类型、混音文件全路径或 URL 等
  /// - Returns: 0: 代表成功，否则失败
  func startAudioMixing(_ option: NEListenTogetherCreateAudioMixingOption) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Start audio mixing.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController
        .startAudioMixing(option: option.converToRoom())
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully start audio mixing.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to start audio mixing. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  func stopAudioMixing() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Stop audio mixing.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.stopAudioMixing()
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully stop audio mixing.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to stop audio mixing. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 暂停播放音乐文件及混音
  /// - Returns: 0: 代表成功，否则失败
  func pauseAudioMixing() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Pause audio mixing.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.pauseAudioMixing()
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully pause audio mixing.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to pause audio mixing. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 恢复播放伴奏
  ///
  /// 该方法恢复混音，继续播放伴奏。请在房间内调用该方法
  /// - Returns: 0: 代表成功，否则失败
  func resumeAudioMixing() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Resume audio mixing.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.resumeAudioMixing()
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully resume audio mixing.")
      } else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to resume audio mixing. Code: \(code)"
        )
      }
      return code
    }
  }

  @discardableResult
  /// 设置伴奏音量
  ///
  /// 该方法调节混音里伴奏的音量大小
  /// - Parameter volume: 伴奏发送音量 范围[0-100]
  /// - Returns: 0: 代表成功，否则失败
  func setAudioMixingVolume(_ volume: UInt32) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Set audio mixing volume. Volume: \(volume).")
    return Judge.syncCondition {
      let sendCode = self.roomContext!.rtcController.setAudioMixingSendVolume(volume: volume)
      let playCode = self.roomContext!.rtcController
        .setAudioMixingPlaybackVolume(volume: volume)
      if sendCode == 0, playCode == 0 {
        self.mixingVolume = volume
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully set audio mixing volume.")
        return NEListenTogetherErrorCode.success
      }
      NEListenTogetherLog.errorLog(
        kitTag,
        desc: "Failed to set audio mixing volume. Code: \(NEListenTogetherErrorCode.failed)"
      )
      return NEListenTogetherErrorCode.failed
    }
  }

  @discardableResult
  /// 获取伴奏音量
  /// - Returns: 0: 代表成功，否则失败
  func getAudioMixingVolume() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get audio mixing volume.")
    return Judge.syncCondition {
      return Int(self.mixingVolume)
    }
  }

  @discardableResult
  /// 播放指定音效文件
  ///
  /// 该方法播放指定的本地或在线音效文件
  /// 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地 SD 卡中的文件和在线 URL
  /// - Parameters:
  ///   - effectId: 指定音效的 ID。每个音效均应有唯一的 ID
  ///   - option: 音效相关参数，包括混音任务类型、混音文件路径等
  /// - Returns: 0: 代表成功，否则失败
  func playEffect(_ effectId: UInt32, option: NEListenTogetherCreateAudioEffectOption) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Play effect. EffectId: \(effectId).")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.playEffect(
        effectId: effectId,
        option: option.convertToRoom()
      )
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully play effect.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to play effect. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 暂停播放指定音效文件。
  /// - Parameter effectId: 音效ID
  /// - Returns: 操作返回值，成功则返回 0
  func pauseEffect(effectId: UInt32) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Pause effect. EffectId:\(effectId)")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.pauseEffect(effectId: effectId)
      if code == 0 {
        NEListenTogetherLog.infoLog(kitTag, desc: "✅Successfully Pause effect.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "❌Failed to Pause effect. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 恢复播放指定音效文件。
  /// - Parameter effectId: 指定音效的 ID。每个音效均有唯一的 ID。
  /// - Returns: 操作返回值，成功则返回 0
  func resumeEffect(effectId: UInt32) -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Resume effect. EffectId:\(effectId)")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.resumeEffect(effectId: effectId)
      if code == 0 {
        NEListenTogetherLog.infoLog(kitTag, desc: "✅Successfully Resume effect.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "❌Failed to Resume effect. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 关闭所有音效
  /// - Returns: 0: 代表成功 否则失败
  func stopAllEffects() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Stop all effects.")
    return Judge.syncCondition {
      let code = self.roomContext!.rtcController.stopAllEffects()
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully stop all effects.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to stop all effects. Code: \(code)")
      }
      return code
    }
  }

  @discardableResult
  /// 设置音效音量
  /// - Parameters:
  ///   - effectId: 指定音效的 ID
  ///   - volume: 音效音量
  /// - Returns: 0: 代表成功，否则失败
  func setEffectVolume(_ effectId: UInt32, volume: UInt32) -> Int {
    NEListenTogetherLog.apiLog(
      kitTag,
      desc: "Set effect volume. EffectId: \(effectId). Volume: \(volume)."
    )
    return Judge.syncCondition {
      let sendCode = self.roomContext!.rtcController.setEffectSendVolume(
        effectId: effectId,
        volume: volume
      )
      let playCode = self.roomContext!.rtcController.setEffectPlaybackVolume(
        effectId: effectId,
        volume: volume
      )
      if sendCode == 0, playCode == 0 {
        self.effectVolume = volume
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully set effect volume.")
        return NEListenTogetherErrorCode.success
      }
      NEListenTogetherLog.errorLog(
        kitTag,
        desc: "Failed to set effect volume. Code: \(NEListenTogetherErrorCode.failed)"
      )
      return NEListenTogetherErrorCode.failed
    }
  }

  @discardableResult
  /// 获取音效音量
  /// - Returns: 0: 代表成功，否则失败
  func getEffectVolume() -> Int {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get effect volume.")
    return Judge.syncCondition {
      return Int(self.effectVolume)
    }
  }

  /// 禁用成员音频 (主播调用)
  /// - Parameters:
  ///   - account: 成员ID
  ///   - callback: 回调
  func banRemoteAudio(_ account: String, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Ban remote audio. Account: \(account)")
    Judge.preCondition({
      let isExist = self.allMemberList.contains { $0.account == account }
      guard isExist else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to ban remote audio. Msg: Can't find member."
        )
        callback?(NEListenTogetherErrorCode.failed, "Can't find member", nil)
        return
      }
      self.roomContext!.updateMemberProperty(
        userUuid: account,
        key: MemberPropertyConstants.CanOpenMic.key,
        value: MemberPropertyConstants.CanOpenMic.no
      ) { code, msg, _ in
        if code == 0 {
          NEListenTogetherLog.successLog(kitTag, desc: "Successfully Ban remote audio.")
        } else {
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to ban remote audio. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 解禁指定成员的音频(主播调用)
  /// - Parameters:
  ///   - account: 成员ID
  ///   - callback: 回调
  func unbanRemoteAudio(_ account: String, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Unban remote audio. Account: \(account)")
    Judge.preCondition({
      let isExist = self.allMemberList.contains { $0.account == account }
      guard isExist else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to ban remote audio. Msg: Can't find member."
        )
        callback?(NEListenTogetherErrorCode.failed, "Can't find member", nil)
        return
      }
      self.roomContext!.updateMemberProperty(
        userUuid: account,
        key: MemberPropertyConstants.CanOpenMic.key,
        value: MemberPropertyConstants.CanOpenMic.yes
      ) { code, msg, _ in
        if code == 0 {
          NEListenTogetherLog.successLog(kitTag, desc: "Successfully unban remote audio.")
        } else {
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to unban remote audio. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  @discardableResult
  /// 获取当前播放音乐长度
  /// - Returns: 长度
  func getEffectDuration() -> UInt64 {
    audioPlayService?.getEffectDuration() ?? 0
  }

  @discardableResult
  /// 设置音乐播放位置
  /// - Parameter position: 播放位置，单位毫秒
  /// - Returns: 0成功，其他失败
  func setPlayingPosition(position: UInt64) -> Int {
    audioPlayService?.setEffectPosition(position: position) ?? -1
  }
}

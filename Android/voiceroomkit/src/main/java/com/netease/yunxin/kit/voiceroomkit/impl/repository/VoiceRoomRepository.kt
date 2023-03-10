/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.repository

import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.roomkit.impl.repository.ServerConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class VoiceRoomRepository {
    companion object {
        lateinit var serverConfig: ServerConfig
    }

    private val voiceRoomApi by lazy { ServiceCreator.create(VoiceRoomApi::class.java) }

    suspend fun getVoiceRoomList(
        liveType: Int,
        live: Int,
        pageNum: Int,
        pageSize: Int
    ): Response<VoiceRoomList> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "liveType" to liveType,
            "live" to live,
            "pageNum" to pageNum,
            "pageSize" to pageSize
        )
        voiceRoomApi.getVoiceRoomList(serverConfig.appKey, params)
    }

    suspend fun startVoiceRoom(
        liveTopic: String?,
        cover: String?,
        liveType: Int,
        configId: Int,
        seatCount: Int,
        seatApplyMode: Int,
        seatInviteMode: Int
    ): Response<VoiceRoomInfo> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "liveTopic" to liveTopic,
                "cover" to cover,
                "liveType" to liveType,
                "configId" to configId,
                "seatCount" to seatCount,
                "seatApplyMode" to seatApplyMode,
                "seatInviteMode" to seatInviteMode
            )
            voiceRoomApi.startVoiceRoom(serverConfig.appKey, params)
        }

    suspend fun stopVoiceRoom(liveRecordId: Long): Response<Unit> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "liveRecordId" to liveRecordId
        )
        voiceRoomApi.stopVoiceRoom(serverConfig.appKey, params)
    }

    suspend fun getRoomInfo(liveRecordId: Long): Response<VoiceRoomInfo> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "liveRecordId" to liveRecordId
        )
        voiceRoomApi.getRoomInfo(appKey = serverConfig.appKey, params)
    }

    suspend fun getDefaultLiveInfo(): Response<VoiceRoomDefaultConfig> = withContext(Dispatchers.IO) {
        voiceRoomApi.getDefaultLiveInfo(appKey = serverConfig.appKey)
    }
}

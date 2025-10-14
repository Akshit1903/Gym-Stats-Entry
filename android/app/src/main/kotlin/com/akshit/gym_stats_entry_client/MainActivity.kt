package com.akshit.gymstats

import android.app.Activity
import android.util.Log
import com.samsung.android.sdk.health.data.HealthDataService
import com.samsung.android.sdk.health.data.permission.AccessType
import com.samsung.android.sdk.health.data.permission.Permission
import com.samsung.android.sdk.health.data.request.DataTypes
import com.samsung.android.sdk.health.data.HealthDataStore
import com.samsung.android.sdk.health.data.data.HealthDataPoint
import com.samsung.android.sdk.health.data.request.DataType
import com.samsung.android.sdk.health.data.request.LocalTimeFilter
import com.samsung.android.sdk.health.data.request.Ordering
import com.samsung.android.sdk.health.data.request.DataType.ExerciseType.PredefinedExerciseType
import com.samsung.android.sdk.health.data.data.entries.ExerciseSession
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.time.LocalDateTime

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.akshit.gymstats"
    private val TAG = "SamsungHealth"
    private lateinit var healthDataStore: HealthDataStore
    private val job = Job()
    private val scope = CoroutineScope(Dispatchers.IO + job)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBodyCompositionAndExerciseData" -> {
                    connectToSamsungHealth { success ->
                        if (success) {
                            setBodyCompositionAndLastWeightsExerciseData { data ->
                                if (data != null) result.success(data)
                                else result.error("NO_DATA", "No body composition data available", null)
                            }
                        } else {
                            result.error("CONNECT_FAILED", "Failed to connect to Samsung Health", null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }


    private fun connectToSamsungHealth(onConnected: (Boolean) -> Unit) {
        try {
            healthDataStore = HealthDataService.getStore(context)
            val permissions: Set<Permission> = setOf(
                Permission.of(DataTypes.BODY_COMPOSITION, AccessType.READ),
                Permission.of(DataTypes.EXERCISE, AccessType.READ)
            )
            scope.launch {
                try {
                    val granted = healthDataStore.getGrantedPermissions(permissions)
                    Log.e(TAG, "Granted permissions: $granted")
                    if (!granted.containsAll(permissions)) {
                        healthDataStore.requestPermissions(permissions, this@MainActivity as Activity)
                    }
                    withContext(Dispatchers.Main) {
                        onConnected(true)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Connection/Permission failed", e)
                    withContext(Dispatchers.Main) {
                        onConnected(false)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Health SDK initialization error", e)
            onConnected(false)
        }
    }

    private fun setBodyCompositionAndLastWeightsExerciseData(onResult: (Map<String, Any>?) -> Unit) {
        scope.launch {
            try {
                val resultMap = mutableMapOf<String, String>()
                val startTime = LocalDateTime.now().minusHours(12)
                val localTimeFilter = LocalTimeFilter.since(startTime)
                val bodyCompositionReadRequest = DataTypes.BODY_COMPOSITION.readDataRequestBuilder
                    .setLocalTimeFilter(localTimeFilter)
                    .setOrdering(Ordering.DESC)
                    .build()
                val bodyCompositionData : HealthDataPoint? = healthDataStore.readData(bodyCompositionReadRequest).dataList.getOrNull(0)
                Log.e(TAG, "Body composition data: $bodyCompositionData")
                if(bodyCompositionData!=null){
                    resultMap["basal_metabolic_rate"]=bodyCompositionData.getValue(DataType.BodyCompositionType.BASAL_METABOLIC_RATE).toString()
                    resultMap["body_fat"]=bodyCompositionData.getValue(DataType.BodyCompositionType.BODY_FAT).toString()
                    resultMap["body_fat_mass"]=bodyCompositionData.getValue(DataType.BodyCompositionType.BODY_FAT_MASS).toString()
                    resultMap["fat_free_mass"]=bodyCompositionData.getValue(DataType.BodyCompositionType.FAT_FREE_MASS).toString()
                    resultMap["skeletal_muscle_mass"]=bodyCompositionData.getValue(DataType.BodyCompositionType.SKELETAL_MUSCLE_MASS).toString()
                    resultMap["total_body_water"]=bodyCompositionData.getValue(DataType.BodyCompositionType.TOTAL_BODY_WATER).toString()
                    resultMap["weight"]=bodyCompositionData.getValue(DataType.BodyCompositionType.WEIGHT).toString()
                }
                val exerciseReadRequest = DataTypes.EXERCISE.readDataRequestBuilder
                    .setLocalTimeFilter(localTimeFilter)
                    .setOrdering(Ordering.DESC)
                    .build()
                fun isExerciseTypeWeight(healthDataPoint: HealthDataPoint): Boolean {
                    Log.e(TAG, "Exercise type: ${healthDataPoint.getValue(DataType.ExerciseType.EXERCISE_TYPE)}")
                    return healthDataPoint.getValue(DataType.ExerciseType.EXERCISE_TYPE) == PredefinedExerciseType.WEIGHT_MACHINE
                }
                val exerciseData : HealthDataPoint? = healthDataStore.readData(exerciseReadRequest).dataList.firstOrNull(::isExerciseTypeWeight)
                Log.e(TAG,"Exercise data: ${exerciseData.toString()}")
                if(exerciseData != null){
                    val sessionData : List<ExerciseSession> = exerciseData.getValue(DataType.ExerciseType.SESSIONS) as List<ExerciseSession>
                    val lastSession: ExerciseSession? = sessionData.firstOrNull()
                    Log.e(TAG, lastSession.toString())
                    if(lastSession != null){
                        resultMap["calories"]=lastSession.calories.toString()
                        resultMap["duration"]=lastSession.duration.toString()
                        resultMap["maxHeartRate"]=lastSession.maxHeartRate.toString()
                        resultMap["meanHeartRate"]=lastSession.meanHeartRate.toString()
                    }
                }
                withContext(Dispatchers.Main) {
                    onResult(resultMap)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to fetch body composition", e)
                withContext(Dispatchers.Main) {
                    onResult(null)
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        job.cancel()
        try {
//            healthDataStore.d
        } catch (_: Exception) { }
    }
}

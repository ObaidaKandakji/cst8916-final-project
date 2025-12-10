-- 5-minute tumbling window aggregations per device/location
WITH Aggregates AS (
    SELECT
        IoTHub.ConnectionDeviceId AS deviceId,
        location,

        AVG(iceThickness)        AS avgIceThickness,
        MIN(iceThickness)        AS minIceThickness,
        MAX(iceThickness)        AS maxIceThickness,

        AVG(surfaceTemperature)  AS avgSurfaceTemperature,
        MIN(surfaceTemperature)  AS minSurfaceTemperature,
        MAX(surfaceTemperature)  AS maxSurfaceTemperature,

        MAX(snowAccumulation)    AS maxSnowAccumulation,
        AVG(externalTemperature) AS avgExternalTemperature,

        COUNT(*)                 AS readingCount,

        System.Timestamp         AS windowEnd
    FROM
        [CST8916Final]
    GROUP BY
        IoTHub.ConnectionDeviceId,
        location,
        TumblingWindow(minute, 5)
),

WithStatus AS (
    SELECT
        -- Cosmos DB document id: {location}-{timestamp}
        CONCAT(
            location,
            '-',
            CAST(windowEnd AS nvarchar(max))
        ) AS id,

        deviceId,
        location,
        windowEnd,

        avgIceThickness,
        minIceThickness,
        maxIceThickness,

        avgSurfaceTemperature,
        minSurfaceTemperature,
        maxSurfaceTemperature,

        maxSnowAccumulation,
        avgExternalTemperature,
        readingCount,

        CASE
            WHEN avgIceThickness >= 30 AND avgSurfaceTemperature <= -2 THEN 'Safe'
            WHEN avgIceThickness >= 25 AND avgSurfaceTemperature <= 0  THEN 'Caution'
            ELSE 'Unsafe'
        END AS safetyStatus
    FROM
        Aggregates
)

-- Write aggregated data to Cosmos DB
SELECT
    *
INTO
    [SensorAggregations]
FROM
    WithStatus;

-- Write the same aggregated data to Blob Storage (historical archive)
SELECT
    *
INTO
    [historical-data]
FROM
    WithStatus;

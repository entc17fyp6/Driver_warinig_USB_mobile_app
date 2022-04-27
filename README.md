# Driver warning system

Flutter mobile application connected to Jetson AGX Xavier via USB to give following driver warnings in real time. (visual and sound warning)

- Traffic light ahead
- Left lane departure
- Right lane departure

<p align="left" width="100%">
    <img src="images\mobile_app.jpg" width="200">
</p>

## Methodology

1. Jetson AGX Xavier writes the 2 json files in path `Downloads/fyp` when new traffic lights / lane departure is detected.

    ### lane_departure_data.json
    ```
    {
    "json_id": 4,
    "beta": 0.8259314894676208
    }
    ```
    for each overwrite `json_id` has a new value
    - `beta < 0` => right lane departure
    - `beta > 0` => left lane departure

    <p align="left" width="100%">
        <img src="images\lane_detection.JPG" width="500">
        <img src="images\lane_departure.JPG" width="500">
    </p>


    ### traffic_light_data.json

    ```
    {
    "json_id": 39,
    "count": 2,
    "ids": [
        42,
        44
    ]
    }
    ```

    <p align="left" width="100%">
        <img src="images\traffic_light_detection.JPG" width="500">
        <img src="images\traffic_light_detection_2.JPG" width="500">
    </p>


    for each overwrite `json_id` has a new value
    - `count` - number of detected and tracked traffic lights
    - `ids` - tracking ids of detected and tracked traffic lights

2. Mobile app reads the json files periodically every 200ms. Check whether New traffic lights / lane departure is detected and show the warnings.

    <p align="left" width="100%">
        <img src="assets\images\left_lane_departure.png" width="100">
        <img src="assets\images\right_lane_departure.png" width="100">
        <img src="assets\images\traffic_light.png" width="100">
    </p>
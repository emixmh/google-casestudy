# Data Dictionary
Based on original [Fitbase Data Dictionary](https://www.fitabase.com/resources/knowledge-base/exporting-data/data-dictionaries/)

## Sleep
|Data Header|Data Type|Data Description|
|---|---|---|
|timestamp|timestamp| date value in yyyy-mm-dd hh:mm:ss format|
|sleep_state|string|sleep states: asleep, restless, awake|
|log_id|integer|unique identifier for sleep logs|
## Heart Rate
Note: A variable sampling technique controls the frequency at which heart rate is recorded.
|Data Header|Data Type|Data Description|
|---|---|---|
|timestamp|timestamp| date value in yyyy-mm-dd hh:mm:ss format|
|heart_rate|integer|heart rate from 5 second sample|
## Weight
|Data Header|Data Type|Data Description|
|---|---|---|
|timestamp|timestamp| date value in yyyy-mm-dd hh:mm:ss format|
|kg|numeric|weight recorded in kilograms|
|lb|numeric|weight in pounds|
|fat|numeric|body fat percentage recorded|
|bmi|integery|measure of body mass index based on the height and weight in the participant’s Fitbit.com profile|
|is_manual_report|boolean|TRUE = if the data for this weigh in was done manually, FALSE = if data was measured and syncheddirectly to Fitbit.com from a connected scale|
|log_id|integer|the unique log id in Fitbit’s systems|
## Combined
Note: The cut points for intensity classifications and METs are not determined by Fitabase, but by proprietary algorithms from Fitbit.
|Data Header|Data Type|Data Description|
|---|---|---|
|timestamp|timestamp| date value in yyyy-mm-dd hh:mm:ss format|
|steps|integer|total number of steps taken|
|mets|numeric|MET value for the given minute|
|intensity|string|intentensity value for the given minute|
|kcal_burned|numeric|total estimated energy expenditure duringactivity (in kilocalories)|
## Daily Activity
|Data Header|Data Type|Data Description|
|---|---|---|
|date|date| date value in yyyy-mm-dd format|
|steps_total|integer|total steps for the day|
|distance_total|numeric|total kilometers tracked|
|logged_activities_distance|numeric|total kilometers from logged activities|
|very_active_distance|numeric|kilometers traveled during very active activty|
|moderately_active_distance|numeric|kilometers traveled during fairly active activty|
|lightly_active_distance|numeric|kilometers traveled during lightly active activty|
|sedentary_active_distance|numeric|kilometers traveled during sedentary activty|
|very_active_min|integer|total minutes spent in very active intensity|
|moderately_active_min|integer|total minutes spent in fairly active intensity|
|lightly_active_min|integer|total minutes spent in lightly active intensity|
|sedentary_min|integer|total minutes spent in sedentary intensity|
|calories|integer|total estimated energy expenditure duringactivity (in kilocalories)|

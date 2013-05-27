BluetoothTest
=============

Wahoo FitnessのBlueSC、BlueHRと接続するサンプル

![BlueSC](http://www.wahoofitness.com/GetDynamicImage.aspx?path=bluesc4.jpg&w=396&h=246&q=100)

![BlueHR](http://www.wahoofitness.com/GetDynamicImage.aspx?dir=itemImages&path=Wahoo-Fitness-Blue-HR-Heart-Rate-Strap253.jpg&w=396&h=246&q=100)

データの構造やService、Characteristicsは [ここ](http://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx) とか [ここ](http://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_speed_and_cadence.xml)に詳細がある。

例えばBlueSCのスピードケイデンスのキャラクタリスティクスはこんな感じ

| サイズ |インデックス| Second Header |
| ------------ | ------------- |
| 8bit | 0 | Flags ホイールの回転数が提供されているか、ケイデンスが提供されているかなど|
| 32bit | 1 |ホイールの累積回転数|
| 16bit | 5 |EventTime 累積回転数が増えた時の時刻。ただし1/1024s 単位 ビットがあふれるとループする|
| 16bit | 7 |クランクの累積回転数|
| 16bit | 9 |EventTime クランク累積回転数が増えた時の時刻。ただし1/1024s 単位 ビットがあふれるとループする|

[CSC Measurement](http://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml)

正確な意味はドキュメントを参照してください。
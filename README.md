BluetoothTest
=============

Wahoo FitnessのBlueSC、BlueHRと接続するサンプル

![BlueSC](http://www.wahoofitness.com/GetDynamicImage.aspx?path=bluesc4.jpg&w=396&h=246&q=100)

![BlueHR](http://www.wahoofitness.com/GetDynamicImage.aspx?dir=itemImages&path=Wahoo-Fitness-Blue-HR-Heart-Rate-Strap253.jpg&w=396&h=246&q=100)

データの構造やService、Characteristicsは [ここ](http://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx) とか [ここ](http://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_speed_and_cadence.xml)に詳細がある。

例えばBlueSCのスピードケイデンスのキャラクタリスティクスはこんな感じ

[CSC Measurement](http://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml)
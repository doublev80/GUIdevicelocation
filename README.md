# GUIdevicelocation

これは，[idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation)をGUIで使用するツールで，Ruby-GTK2で開発しています．

> _This is a tool for using [idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation) on the GUI, developed by ruby-gtk2._

---

## 環境設定 / Environment set up

まず，Ubuntu上で[idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation#about)を動作させる環境を用意します．

> _First, prepare to run [idevicelocation](https://github.com/JonGabilondoAngulo/idevicelocation#about) on Ubuntu._

そして，Ruby，Ruby-Gtk2をインストールします．

> _Then, install ruby, ruby-gtk2._

    $ sudo apt-get install ruby
    $ sudo apt-get install ruby-gtk2

GUIdevicelocation.rbをダウンロードします．

> _Download GUIdevicelocation.rb._

    $ wget https://github.com/doublev80/GUIdevicelocation/raw/master/GUIdevicelocation.rb

---

## 実行 / Run

GUIdevicelocation.rbを実行します．

> _Run GUIdevicelocation.rb._

    $ ruby GUIdevicelocation.rb

以下のようなウィンドウが起動します．

> _This will open the following window:_

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img1.png)

---

## 使い方 / How to use

### 開始位置の設定 / Start location

以下のLati，Longが，現在の緯度(南北)，経度(東西)を表しています．  
初期状態で，東京駅の緯度経度が設定されているので，移動を開始したい位置を設定します．

> _'Lati (N/S)' and 'Long (E/W)' will represent the current latitude (north/south) and longitude (east/west).  
> The default will show the latitude and longitude of Tokyo Station.  
> Enter the co-ordinates of the desired location._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img2.png)

### UUIDの設定 / Set UUID

「Get UUID」を押すと，接続されたデバイスのUUIDが，プルダウンボックスに設定されますので，位置を変更するデバイスのUUIDをプルダウンで選択します．

> _When 'Get UUID' is pushed, the UUID of the connected device will be set within the pull-down menu.  
> Choose a UUID for device to change the location._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img3.png)

### 2メートル単位の移動 / Move by 2 meter

以下の8方向ボタンを1回押すことにより，それぞれの方向へ，2メートル移動します．  
※GUIdevicelocation.rbを実行したコンソールに，実行したコマンドが表示されます．

> _By pressing these buttons, it will move the location by 2 meter towards that direction.  
> \* It shows executed command on the console running GUIdevicelocation.rb._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img4.png)

### 指定量，回数，間隔の移動 / Move by specified amount, count, interval

以下の'Amount'に1回で移動する度数，'Count'に移動する回数，'Interval'に移動する間隔(秒)を，それぞれ設定し，8方向ボタンを1回押すことにより，それぞれの方向へ，設定した内容に従って移動します．  
初期状態は，徒歩程度の速度で，10秒移動する設定です．

> _Here, you can set the number of meters ('Amount'), the number of times you move per press of a button ('Count'), and duration of your move ('Interval'), every time you press one of the eight multi directional buttons. Default is set to 10 seconds worth of walking speed._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img5.png)

移動中，以下の'Stop!'を押すことにより，移動をキャンセルできます．

> _To cancel the movement press the 'Stop!' button._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img6.png)

### 位置シミュレーション終了 / Stop to simulate location

以下の'Stop Simu'ボタンにより，シミュレーションを終了し，現在位置に戻ります．

> _To stop the simulation and return to actual current location, press the 'Stop Simu' button._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img7.png)

### よく使用する位置の登録 / register favorite locations

以下のFav1～Fav3のLati，Longに，よく使用する位置を3つ登録することができます．

> _You can register up to three of your favourite locations using Fav1, Fav2 and Fav3._

![start](https://raw.githubusercontent.com/doublev80/GUIdevicelocation/master/img/img8.png)

---

## 位置情報の保存，復帰 / save and restore location informations

右上の×ボタンにより，GUIdevicelocation.rbを終了すると，現在位置と，Fav1～Fav3のLati，Longの位置が，'.position.yaml'というファイルに保存され，次回起動時に読み込まれます．  
保存した情報を削除したい場合は，.position.yamlを削除してください．

> _Closing the application by pressing the X button will save your positions in a file named 'position/yaml'.  
> The positions will reappear the next time the application is opened.  
> To delete the stored information please delete the file '.position.yaml'._

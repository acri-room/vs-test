ACRi Room FPGA 自動テストスクリプト
===================================

Arty A7-35 を搭載した VM 上 (ACRi Room では vs???) で，論理合成 → FPGA への書き込み → シリアル通信の結果の書き込み の一連のテストを自動的に行います．歴史的経緯で Nexys A7-100 (Nexys 4 DDR) にも対応しています．

ファイルの構成
--------------
- autobuild.rb: スクリプト本体
- build_vivado_arty.tcl: Arty A7 用バッチ論理合成スクリプト
- build_vivado_nexys.tcl: Nexys A7 用バッチ論理合成スクリプト
- write_dummy_arty.tcl: Arty A7 用ダミービットストリーム書込みスクリプト
- write_dummy_nexys.tcl: Nexys A7 用ダミービットストリーム書込みスクリプト
- README.md: このファイル
- COPYING: ライセンス表記 (修正 BSD が適用されます)

環境の準備
----------

あらかじめ用意が必要なファイル・ディレクトリ
- hello_arty ディレクトリ: この上に fpga プロジェクトを作成し，ACRi ブログの Hello, FPGA の回路を Arty A7 向けに作成してください．
- dummy_arty.bit: 適当な「無害な」Arty A7 向けビットストリーム (LED をチカチカさせるなど) を用意してください．
- generate_log ディレクトリ: Vivado のログと作成されたビットストリームがコピーされます．空のディレクトリを作成してください．
同様に，Nexys A7 に対応させるには，hello_nexys ディレクトリと dummy_nexys.bit を用意してください．

スクリプトの設定
----------------

autobuild.rb の9～17行目以降の定数を，環境に合わせて適切に変更します．上記のとおりにファイル・ディレクトリを用意した場合，変更が必要なのは9行と17行のみのはずです．
- `VIVADO_DIR`: Vivado のインストールされたディレクトリ
- `PROJ_BASE`: プロジェクトの置かれたディレクトリのプレフィクス (hello_* ディレクトリを作成した場合は修正不要）
- `IMPL_PREFIX`: ビットストリームの置かれたディレクトリ (fpga プロジェクトを作成した場合は修正不要)
- `GEN_DIR`: ログとビットストリームのコピー先ディレクトリ
- `BIT_PREFIX`: ビットストリームのファイル名 (トップモジュールが serial_fpga2 なら修正不要)
- `LOG_FILE`: Vivado のログファイル (通常修正不要のはず)
- `PORT`: ボードの UART-USB 変換器に割り当てられたデバイスファイル名

スクリプトの実行
----------------

スクリプト一式の置かれたディレクトリに移動し，

> $ ruby autobuild.rb ボード名 保存先ファイル名

でスクリプトを実行します．ボード名は arty か nexys のいずれかです．

スクリプトが正しく実行できれば，保存先ファイル名で指定された名前で Vivado のログ (log) およびビットストリーム (bit) が generate_log ディレクトリにコピーされ，シリアル通信で受け取った文字列が表示されます．通常，出力の最後の文字列は

> Data from serial port: Hello, FPGA

となります．

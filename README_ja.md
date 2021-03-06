# MPSTrainingChallenge

MetalPerformanceShaders Framework を使ってニューラルネットワークのトレーニングをする挑戦.

## 背景

[Metal for Accelerating Machine Learning - WWDC 2018](https://developer.apple.com/videos/play/wwdc2018/609/) にて, Metalを利用してニューラルネットワークの「学習」ができるようになったという発言がなされた. セッション中ではデモが行われたが, デモはTuriCreateとTensorFlowについてのものであった. ネットを検索してみても学習から推論を行っている実装が見つからないし, リファレンスにすらあまり情報がない. iOS上で学習して, 継続して推論をするという実装はどうやったら実現できるのだろうか.

## 使用するデータセット

[MNIST](http://yann.lecun.com/exdb/mnist/)

上記のページ下部に記載されているバイナリデータのファイルフォーマットに従ってデータをパースする.  ([MNIST.m](https://github.com/naru-jpn/MPSTrainingChallenge/blob/master/Training/MNIST/MNIST.m))

## ネットワークの構成

Optimizerには `MPSNNOptimizerStochasticGradientDescent` を使用.

```
              Input(28x28)
                   ↓
FullyConnectedConvolution Layer(1x1x10)  FullyConnectedConvolution Gradient Layer
                   ↓                                       ↑
             Softmax Layer                       Softmax Gradient Layer
                   │                                       ↑
                   └────────────────→ Loss ────────────────┘
```

# 現状(2018.12.15)

学習はできているらしい ( `MPSCNNConvolution.h` L.683 参照 ).
学習した結果を推論するのどうしたらいいの？

# 現状(2019)

学習と推論できた.

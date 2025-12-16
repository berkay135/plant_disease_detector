# U2-Net Background Removal Model

## Model İndirme Talimatları

Arka plan kaldırma özelliği için U2-Net TFLite modelini indirmeniz gerekmektedir.

### Adım 1: Model İndirme

Aşağıdaki kaynaklardan birinden modeli indirebilirsiniz:

#### Seçenek 1: TensorFlow Hub
```
https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/int8/4
```

#### Seçenek 2: GitHub (Önerilen)
1. Bu repoyu ziyaret edin: https://github.com/xuebinqin/U-2-Net
2. TFLite versiyonunu indirin veya kendiniz dönüştürün

#### Seçenek 3: Önceden Hazırlanmış Model
Google Drive veya başka bir kaynaktan önceden hazırlanmış `u2net.tflite` modelini indirin.

### Adım 2: Model Yerleştirme

İndirdiğiniz `u2net.tflite` dosyasını şu dizine kopyalayın:
```
assets/models/u2net.tflite
```

### Model Özellikleri
- **Input Size**: 320x320x3
- **Output Size**: 320x320x1 (mask)
- **Format**: TFLite Float32
- **Boyut**: ~10-20MB

### Model Dönüştürme (İsteğe Bağlı)

Eğer PyTorch modelini kendiniz dönüştürmek isterseniz:

```python
# U2-Net PyTorch modelini TFLite'a dönüştürme
import torch
import tensorflow as tf
from model import U2NET

# Model yükle
model = U2NET(3, 1)
model.load_state_dict(torch.load('u2net.pth'))
model.eval()

# ONNX'e dönüştür
dummy_input = torch.randn(1, 3, 320, 320)
torch.onnx.export(model, dummy_input, "u2net.onnx")

# ONNX'ten TFLite'a
# onnx-tf convert -i u2net.onnx -o u2net_tf
# tflite_convert --saved_model_dir=u2net_tf --output_file=u2net.tflite
```

## Fallback Mekanizması

Model bulunamazsa, uygulama otomatik olarak basit renk tabanlı arka plan kaldırma yöntemine geçecektir. Bu yöntem:
- ✅ Model gerektirmez
- ✅ Hızlıdır
- ⚠️ Daha az doğrudur
- ⚠️ Sadece beyaz/açık gri arka planlar için etkilidir

## Test Etme

Model doğru çalışıyor mu test etmek için:
1. Uygulamayı çalıştırın
2. Bir bitki fotoğrafı çekin veya seçin
3. Console loglarını kontrol edin:
   - `"U2-Net model loaded successfully!"` → Model çalışıyor
   - `"Warning: U2-Net model not found. Using fallback method."` → Fallback kullanılıyor

## Performans İpuçları

- Model ilk kullanımda yüklenecek ve bellekte tutulacaktır
- Arka plan kaldırma işlemi ~1-3 saniye sürer
- Daha hızlı işlem için model boyutunu küçültebilirsiniz (quantization)

## Sorun Giderme

### Model yüklenmiyor
1. Dosya adının `u2net.tflite` olduğundan emin olun
2. Dosyanın `assets/models/` klasöründe olduğunu kontrol edin
3. `flutter pub get` komutunu çalıştırın
4. Uygulamayı yeniden derleyin: `flutter run`

### Yavaş çalışıyor
- TFLite GPU delegate kullanmayı düşünün
- Model quantization yapın (int8)
- Input boyutunu küçültün (örn: 256x256)

## Alternatif Modeller

U2-Net yerine kullanabileceğiniz diğer modeller:
1. **MODNet** - Daha hızlı ama biraz daha az doğru
2. **DeepLabV3** - TensorFlow Hub'dan hazır
3. **MediaPipe Selfie Segmentation** - Çok hızlı ama insan odaklı

## Kaynaklar

- [U2-Net Paper](https://arxiv.org/abs/2005.09007)
- [U2-Net GitHub](https://github.com/xuebinqin/U-2-Net)
- [TFLite Background Removal Guide](https://www.tensorflow.org/lite/examples/segmentation/overview)

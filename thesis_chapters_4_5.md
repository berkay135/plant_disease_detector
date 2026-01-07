# 4. BULGULAR

Bu bölümde, önerilen derin öğrenme modelinin eğitim sonuçları, performans metrikleri ve geliştirilen mobil uygulamanın test sonuçları sunulmaktadır. Modelin başarımı, doğruluk (accuracy), kayıp (loss), kesinlik (precision), duyarlılık (recall) ve F1-skoru gibi metrikler kullanılarak değerlendirilmiştir.

## 4.1. Model Eğitim ve Performans Sonuçları

Bitki hastalıklarının tespiti için kullanılan EfficientNet-B3 tabanlı model, PlantVillage veri seti üzerinde eğitilmiştir. Eğitim süreci toplam 30 epok sürmüş olup, "Early Stopping" mekanizması sayesinde modelin ezberlemesi (overfitting) engellenmiştir. Eğitim sonucunda en iyi performans 21. epokta elde edilmiştir.

Modelin eğitim, doğrulama (validation) ve test setleri üzerindeki performans değerleri Tablo 4.1'de özetlenmiştir.

**Tablo 4.1:** Modelin Eğitim, Doğrulama ve Test Performans Değerleri

| Veri Seti | Kayıp (Loss) Değeri | Doğruluk (Accuracy) |
|-----------|---------------------|---------------------|
| Eğitim    | 0.0004              | %100.00             |
| Doğrulama | 0.0069              | %99.89              |
| Test      | 0.0053              | %99.85              |

Eğitim süreci boyunca kaydedilen kayıp ve doğruluk değerlerinin değişimi grafiksel olarak incelenmiştir. Şekil 4.1'de eğitim ve doğrulama hatasının epoklara göre değişimi, Şekil 4.2'de ise doğruluk oranlarının değişimi görülmektedir.

> **[BURAYA ŞEKİL EKLENECEK]**
>
> **Şekil 4.1:** Eğitim ve Doğrulama Kayıp (Loss) Grafiği. (Dosya adı: `training_loss_graph.png` olması önerilir)

> **[BURAYA ŞEKİL EKLENECEK]**
>
> **Şekil 4.2:** Eğitim ve Doğrulama Doğruluk (Accuracy) Grafiği. (Dosya adı: `training_accuracy_graph.png` olması önerilir)

Grafikler incelendiğinde, modelin eğitim ve doğrulama kayıplarının paralel bir şekilde azaldığı ve doğruluk değerlerinin yükseldiği görülmektedir. Bu durum, modelin başarılı bir şekilde genelleme yaptığını ve ezberleme (overfitting) sorunu yaşamadığını göstermektedir.

## 4.2. Sınıflandırma Performansı ve Karışıklık Matrisi

Modelin sınıf bazında performansını detaylı incelemek için Sınıflandırma Raporu (Classification Report) ve Karışıklık Matrisi (Confusion Matrix) oluşturulmuştur. Test veri seti üzerinde yapılan değerlendirmede, 38 farklı sınıfın tamamında %99 ve üzeri F1-skoru elde edilmiştir.

Özellikle birbirine görsel olarak çok benzeyen hastalık sınıflarında (örneğin Domates Erken Yanıklık ve Geç Yanıklık) modelin ayırt etme başarısı oldukça yüksektir. Aşağıdaki Şekil 4.3'te modelin test veri seti üzerindeki karışıklık matrisi verilmiştir.

> **[BURAYA ŞEKİL EKLENECEK]**
>
> **Şekil 4.3:** Karışıklık Matrisi (Confusion Matrix). (Dosya adı: `confusion_matrix.png` olması önerilir)

Elde edilen sonuçlar, önerilen EfficientNet-B3 modelinin bitki hastalıklarını tespit etmede oldukça güvenilir ve yüksek başarımlı olduğunu kanıtlamaktadır.

## 4.3. Mobil Uygulama Performans Testleri

Eğitilen PyTorch modeli, mobil cihazlarda çalışabilmesi için ONNX formatına ve ardından TensorFlow Lite (TFLite) formatına dönüştürülmüştür. Geliştirilen "Plant Disease Detector" Flutter uygulaması, Samsung Galaxy M34 5G cihazı üzerinde test edilmiştir.

Yapılan testlerde aşağıdaki performans kriterleri ölçülmüştür:

1.  **Model Boyutu:** Kuantizasyon ve optimizasyon işlemleri sonrası model boyutu yaklaşık **11 MB** seviyesine indirilmiştir. Bu, mobil uygulama boyutunun düşük tutulmasını sağlamıştır.
2.  **Çıkarım Süresi (Inference Time):** Arka plan temizleme işlemi dahil edilmeden, sadece sınıflandırma modelinin bir görüntüyü analiz etme süresi ortalama **50 ms** olarak ölçülmüştür. Arka plan temizleme (U-2-Net) aktif edildiğinde bu süre artmakla birlikte, kullanıcı deneyimini olumsuz etkilemeyecek seviyelerdedir.
3.  **Kaynak Tüketimi:** Uygulama çalışırken CPU ve RAM kullanımı, standart bir mobil kullanım senaryosu sınırları içerisinde kalmıştır.

---

# 5. TARTIŞMA VE SONUÇ

## 5.1. Tartışma

Bu çalışmada, bitki hastalıklarının erken teşhisi ve yönetimi için derin öğrenme tabanlı kapsamlı bir mobil sistem önerilmiştir. Elde edilen bulgular, Literatür Taraması (Bölüm 2) kısmında incelenen benzer çalışmalarla karşılaştırıldığında, önerilen sistemin rekabetçi ve birçok açıdan üstün sonuçlar verdiği görülmüştür.

Özellikle EfficientNet-B3 mimarisinin kullanılması, modelin parametre sayısı ve işlem gücü dengesi açısından mobil cihazlar için uygun bir tercih olduğunu göstermiştir. Birçok çalışmada kullanılan ResNet veya VGG modellerine kıyasla daha hızlı ve yüksek doğruluklu sonuçlar alınmıştır. %99.85'lik test doğruluğu, modelin saha koşullarında da güvenle kullanılabileceğine işaret etmektedir.

Ayrıca, sadece hastalık tespiti yapmakla kalmayıp, kullanıcıya tedavi önerileri sunan, hava durumu takibi sağlayan ve Gemini API destekli bir AI asistanı içeren bütünleşik bir yapı sunulması, bu çalışmayı sadece bir sınıflandırma problemi çözümünden öteye taşıyıp tam bir tarımsal yönetim aracı haline getirmiştir.

## 5.2. Sonuç

Tez kapsamında, tarımsal verimliliği artırmak ve ürün kayıplarını en aza indirmek amacıyla yapay zeka destekli bir bitki hastalık tespit sistemi geliştirilmiştir. PyTorch kütüphanesi kullanılarak eğitilen EfficientNet-B3 modeli, 38 farklı bitki-hastalık sınıfını yüksek doğrulukla tespit edebilmektedir. Geliştirilen model, Flutter tabanlı bir mobil uygulamaya entegre edilerek çiftçilerin ve hobi amaçlı bitki yetiştiricilerinin kullanımına sunulmuştur.

Çalışmanın temel çıktıları şunlardır:
1.  PlantVillage veri seti üzerinde **%99.85** test doğruluğuna sahip yüksek performanslı bir sınıflandırma modeli geliştirilmiştir.
2.  Model, mobil cihazlarda çevrimdışı (offline) çalışabilecek şekilde optimize edilmiştir.
3.  Tarımsal yönetimi kolaylaştıran, kullanıcı dostu arayüze sahip bir mobil uygulama prototipi ortaya konulmuştur.

## 5.3. Gelecek Çalışmalar

Gelecekte bu çalışmanın kapsamını genişletmek adına aşağıdaki geliştirmeler planlanmaktadır:
*   **Veri Setinin Genişletilmesi:** PlantVillage veri setinde bulunmayan yerel bitki hastalıklarının ve farklı ürün çeşitlerinin veri setine eklenmesi.
*   **Gerçek Zamanlı Video Analizi:** Hastalık tespitinin sadece fotoğraflar üzerinden değil, kamera görüntüsü üzerinden gerçek zamanlı olarak yapılabilmesi.
*   **Çoklu Dil Desteği:** Uygulamanın küresel ölçekte kullanılabilmesi için farklı dil seçeneklerinin eklenmesi.
*   **Topluluk Özellikleri:** Çiftçilerin birbirleriyle bilgi paylaşabileceği sosyal bir platform özelliğinin entegre edilmesi.

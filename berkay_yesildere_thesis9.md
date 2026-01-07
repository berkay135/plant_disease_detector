|     |     |
| --- | --- |
|     | **T.C.**<br><br>**KIRŞEHİR AHİ EVRAN ÜNİVERSİTESİ**<br><br>**MÜHENDİSLİK -MİMARLIK FAKÜLTESİ**<br><br>**BİLGİSAYAR MÜHENDİSLİĞİ** |

**GÖRÜNTÜ İŞLEME VE DERİN ÖĞRENME TABANLI AKILLI TARIM UYGULAMASI**

**BERKAY YEŞİLDERE**

**LİSANS TEZİ**

**DANIŞMAN**

**Dr.Öğr.Üyesi Volkan Güneş**

**KIRŞEHİR / 2025-2026 AKADEMİK YILI**

|     |     |
| --- | --- |
| **İÇİNDEKİLER** |     |     |
| **Sayfa No** |     |     |
|     |     |     |
| **İÇİNDEKİLER……………………………………………………………….......** |     | **1** |
| **ŞEKİL LİSTESİ……………………………………………………………….…** |     | **2** |
| **TABLO LİSTESİ………………………………………………………………...** |     | **3** |
| **SİMGE VE KISALTMA LİSTESİ……………………………………………..** |     | **4** |
| **ÖZET……………………………………………………………………………...** |     | **5** |
|     |     |     |
| **1\. GİRİŞ…………………………………………………………………………** |     | **6** |
| 1.1. Amaç…………………………………………………………………. |     | **7** |
| 1.2. Önem………………………………………………………………… |     | **8** |
|     |     |     |
|     |     |     |
| **2\. İLGİLİ ÇALIŞMALAR…………………………………………………..** |     | **8** |
|     |     |     |
| **3\. ÖNERİLEN SİSTEM…………………………………………** |     | **15** |
| 3.1. ……………………………………………………………… |     | **16** |
| **4\. BULGULAR…………………………………………………………………** |     |     |
| **5\. TARTIŞMA VE SONUÇ…………………………………………………..** |     |     |
| **KAYNAKLAR………………………………………………………………….** | **18** |     |

|     |     |     |
| --- | --- | --- |
| ŞEKİL LİSTESİ |     |     |
| **Sayfa No** |     |     |
| **Şekil 2.1.** | Önceden eğitilmiş bilgiden yararlanan modelin çalışma prensibi. | **8** |
| **Şekil 2.2.** | Çalışmada kullanılan hibrit öğrenme modelinin akış şeması. | **9** |
| **Şekil 2.3.** | Modellerinin karar mekanizmalarını karşılaştıran açıklanabilirlik ısı haritaları. | **11** |
| **Şekil 2.4.** | Nesne tespiti modeli ile bitki hastalıklarının tespiti ve yerinin belirlenmesi. | **14** |
| **Şekil 3.2.** | PlantVillage veri setinden örnek sağlıklı ve hastalıklı yaprak görüntüleri_._ | **18** |
| **Şekil 3.3.** | Önerilen transfer öğrenme tabanlı model mimarisi. | **20** |
| **Şekil 3.4.** | Eğitim ve doğrulama setleri üzerindeki Loss ve Accuracy değişim grafikleri. | **21** |
| **Şekil 3.5.** | 38 farklı sınıf için oluşturulan Karışıklık Matrisi Koyu renkli köşegenler, modelin doğru sınıflandırma başarısını göstermektedir. | **22** |
| **Şekil 3.6.** | Modelin mobil platforma uygun hale getirilmesi için uygulanan dönüşüm adımları | **23** |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |

|     |     |     |
| --- | --- | --- |
| TABLO LİSTESİ |     |     |
| **Sayfa No** |     |     |
| **Tablo 2.1** | Çalışmalarda kullanılan yöntemler ve performansları. | **14** |
| **Tablo 3.1** | Sınıflandırma adları ve örnek sayısı | **16** |
| **Tablo 3.1** | Eğitim sürecinde kullanılan temel hiperparametreler. | **20** |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |

SİMGE VE KISALTMA LİSTESİ

Kısaltmalar Açıklama

**AI** : Artificial Intelligence

**FAO** : Food and Agriculture Organization

**CNN** : Convolutional Neural Network

**DNN** : Deep Neural Network

**VGG16** : Visual Geometry Group 16-layer

**SVM** : Support Vector Machines

**KNN** : K-Nearest Neighbor

**MÖ** : Makine Öğrenmesi

**LR**  : Learning Rate 

**ReLU**  : Rectified Linear Unit 

**RGB**  : Red Green Blue 

**GPU**  : Graphics Processing Unit 

**CUDA**  : Compute Unified Device Architecture 

**ONNX** : Open Neural Network Exchange

**ÖZET**

**LİSANS TEZİ**

**GÖRÜNTÜ İŞLEME VE DERİN ÖĞRENME TABANLI AKILLI TARIM UYGULAMASI**

**BERKAY YEŞİLDERE**

**Kırşehir Ahi Evran Üniversitesi**

**Mühendislik Mimarlık Fakültesi**

**Bilgisayar Mühendisliği Bölümü**

**Danışman: Dr.Öğr.Üyesi Volkan Güneş**

Tarım, dünya nüfusunun beslenmesi için hayati bir öneme sahiptir. Ancak bitki hastalıkları, her yıl küresel ölçekte büyük ürün kayıplarına yol açarak gıda güvenliğini tehdit etmektedir. Geleneksel yöntemlerle hastalıkların teşhisi genellikle uzmanlık gerektiren, zaman alıcı ve maliyetli bir süreçtir. Ayrıca, yanlış teşhisler sonucu gereksiz veya hatalı pestisit kullanımı hem çevreye zarar vermekte hem de çiftçilerin maliyetlerini artırmaktadır. Bu projenin temel motivasyonu, derin öğrenme ve görüntü işleme teknolojilerinden yararlanarak, mobil cihazlar üzerinden herkesin kolayca kullanabileceği bir akıllı tarım asistanı geliştirmektir. Bu sayede, bitki hastalıklarının erken ve doğru bir şekilde teşhis edilmesi, doğru tedavi yöntemlerinin önerilmesi ve hatta toprak ve mahsul verilerine dayalı olarak verimliliğin artırılması hedeflenmektedir. Geliştirilecek olan bu uygulama ile tarımsal üretimin daha sürdürülebilir, verimli ve çevre dostu bir hale getirilmesine katkı sağlanması amaçlanmaktadır.

**Anahtar Kelimeler:** Derin Öğrenme, Görüntü İşleme, Bitki Hastalıkları Tanıma

1.  GİRİŞ

Tarım, küresel gıda güvenliğinin sağlanması ve dünya ekonomilerinin sürdürülebilirliği için hayati bir role sahiptir. Ancak hızla artan dünya nüfusunun gıda talebini karşılama hedefi, ciddi zorluklarla yüzleşmektedir. Bu zorlukların başında, tarımsal verimliliği büyük ölçüde düşüren bitki hastalıkları gelmektedir. Birleşmiş Milletler Gıda ve Tarım Örgütü (FAO), her yıl bitki hastalıkları ve zararlıları nedeniyle küresel ürün rekoltesinin %40'a varan oranlarda kaybedildiğini, bu durumun hem gıda güvenliğini tehdit ettiğini hem de yıllık 220 milyar doları aşan ekonomik kayıplara yol açtığını bildirmektedir \[[1](https://www.global-agriculture.com/global-agriculture/up-to-40-percent-of-global-crop-production-is-lost-due-to-pests-and-diseases-every-year-fao/),[2](https://www.fao.org/one-health/highlights/how-plant-diseases-threaten-global-food-security)\]. Geleneksel teşhis yöntemlerinin yavaş, maliyetli ve uzmanlık gerektirmesi, özellikle kaynaklara erişimi kısıtlı olan küçük çiftçiler için büyük bir engel teşkil etmektedir. Bu sorunlara çözüm olarak, "Akıllı Tarım" veya "Tarım 4.0" olarak bilinen teknolojik devrim, yapay zekâ (AI) ve görüntü işleme gibi yenilikçi yaklaşımlar sunmaktadır. Özellikle Evrişimli Sinir Ağları (CNN) gibi derin öğrenme tabanlı akıllı sistemler, tarımsal görüntü analizinde devrim yaratmıştır. Mobil cihazların yaygınlaşmasıyla birlikte, bu güçlü yapay zekâ modelleri artık doğrudan çiftçinin kullanımına sunulabilmektedir. Akıllı telefon kameraları aracılığıyla çekilen bir bitki yaprağı fotoğrafı, eğitilmiş bir model tarafından saniyeler içinde analiz edilerek hastalık teşhisi konulabilmekte ve anında müdahale imkânı sağlanabilmektedir. Bu çalışmanın temel amacı, söz konusu teknolojik potansiyeli kullanarak çiftçiler ve bitki yetiştiricileri için pratik ve erişilebilir bir çözüm sunmaktır. Bu doğrultuda, mobil cihazlar aracılığıyla çekilen bitki fotoğraflarını derin öğrenme algoritmalarıyla analiz ederek hastalıkları yüksek doğrulukla teşhis eden akıllı bir mobil uygulama geliştirilmesi hedeflenmektedir. Proje, yalnızca hastalık tespiti ile sınırlı kalmayıp, aynı zamanda toprak tipi analizi ve bu veriler ışığında kullanıcıya özel mahsul ve gübreleme önerileri sunarak kapsamlı bir tarım danışmanlığı aracı olmayı amaçlamaktadır.

- 1.  Amaç

Bitki hastalıkları, tarımsal üretimde ciddi verim kayıplarına neden olmakta, bu durum gıda güvenliğini ve çiftçilerin gelirini tehdit etmektedir. Bu sebeple, hastalıkları erken evrede, doğru bir şekilde teşhis edebilen ve anında çözüm önerileri sunan akıllı bir sisteme ihtiyaç duyulmaktadır. Yapılan bu uygulama, mobil cihazlar aracılığıyla çekilen bitki yaprağı ve toprak fotoğraflarını, görüntü işleme ve derin öğrenme algoritmalarından biri olan evrişimsel sinir ağları ile kullanarak bitki hastalığının gerçek zamanlı olarak tespit edilmesini ve bu verilere dayalı olarak kullanıcı için tedavi ve mahsul önerilerinin sunulmasını amaçlamaktadır. Bu sayede, hastalıkların yol açtığı ürün kayıplarının önüne geçilerek tarımsal verimliliğin artırılması ve çiftçilerin daha bilinçli ve sürdürülebilir tarım yapmaları hedeflenmektedir.

- 1.  Önem

Bitki hastalıklarının zamanında ve doğru bir şekilde teşhis edilememesi, tarımsal üretimde büyük verim kayıplarına ve dolayısıyla çiftçiler için ciddi ekonomik zararlara yol açmaktadır. Yapılan bu çalışma, mobil cihazlar aracılığıyla bitki hastalıklarının ve toprak türünün anında tespit edilip, çiftçinin doğru adımları atması için bilgilendirilmesi işlevini gerçekleştirmektedir. Hastalıkların erken evrede ve doğru bir şekilde tespit edilip uygun müdahalenin yapılması, ürün kayıplarını en aza indirmek ve tarımsal sürdürülebilirliği sağlamak için oldukça önemlidir. Uygulamada yer alan akıllı öneri sistemi, doğru teşhise dayalı olarak çalışacak, çiftçinin yanlış veya gereksiz pestisit kullanımını engelleyerek hem maliyetleri düşürecek hem de çevre kirliliğinin azaltılmasına katkı sağlayacaktır.

1.  İLGİLİ ÇALIŞMALAR

Fatemeh Sadat Seyed Khamoushi tarafından 2025 yılında yapılan çalışmada, gelişmiş derin öğrenme yöntemleri kullanılarak bitki hastalıklarının tespiti üzerine bir yüksek lisans tezi sunulmuştur. Bu araştırmada, yaprak görüntülerinden yola çıkarak hastalıkları sınıflandıran bir derin öğrenme modeli önerilmiştir. Yüksek doğruluk elde etmek amacıyla ResNet50, Inception-ResNet, VGG16 gibi modern Evrişimli Sinir Ağı (CNN) mimarileri ve özel bir model karşılaştırılmıştır. Çalışmada kullanılan veri seti üzerinde ön işleme adımları uygulanmış ve tüm modeller bu veri setinin eğitim, doğrulama ve test alt kümeleri ile eğitilip test edilmiştir. Deneysel sonuçlar, test setinde %97,22'lik bir doğruluk oranı ile en iyi performansı VGG16 modelinin gösterdiğini ortaya koymuştur. Diğer mimariler olan özel CNN, Inception-ResNet ve ResNet50 ise daha değişken performans sergilemiştir. Model karşılaştırmaları, VGG16 ve Inception-ResNet gibi önceden eğitilmiş mimarilerin, daha derin ve karmaşık özellik setlerini çıkarma yetenekleri sayesinde özel olarak tasarlanmış mimarilere göre çoğu senaryoda daha üstün performans gösterdiğini ortaya koymaktadır\[3\].

Şekil 2.1. Önceden eğitilmiş bilgiden yararlanan modelin çalışma prensibi \[3[13](https://www.geeksforgeeks.org/machine-learning/ml-introduction-to-transfer-learning/)\].

Zainab Fadhil Abbas ISHKAYYIR tarafından yapılan çalışmada, derin öğrenmeye dayalı hibrit bir model ile bitki hastalıklarının tespiti amaçlanmıştır. Bu çalışmada, bitki hastalıklarının sınıflandırılması için PlantVillage veri seti kullanılmıştır. Yöntem olarak, ilk aşamada ResNet50, VGG16, VGG19, MobileNet, DenseNet121, InceptionV3 ve ConvNext gibi çeşitli derin öğrenme modelleri transfer öğrenme tekniği ile eğitilmiştir. Bu modeller arasından en iyi performansı gösteren MobileNet'in (%97,70 doğruluk) özellik çıkarma yeteneği kullanılarak; SVM, KNN, Random Forest, Logistic Regression ve Decision Tree gibi klasik makine öğrenmesi sınıflandırıcıları ile hibrit modeller oluşturulmuştur. Geliştirilen hibrit modeller arasında en yüksek performansı %98,46 doğruluk oranı ile MobileNet ve SVM birleşimiyle oluşturulan model göstermiştir. Sonuç olarak, önerilen hibrit modelin yüksek doğrulukla birden fazla bitki hastalığını etkili bir şekilde tespit edebildiği gözlemlenmiştir \[4\].

Şekil 2.2. Çalışmada kullanılan hibrit öğrenme modelinin akış şeması \[4\].

Elif Genç tarafından 2025 yılında yapılan çalışmada, bitki hastalıklarının yapay zeka ile erken tespiti üzerine çok yönlü bir yaklaşım geliştirilmiştir. Bu tez kapsamında, sağlıklı ve hastalıklı bitkilerden veri toplamak amacıyla iki özel iklim odası kurulmuştur. Çalışmada üç ana yöntem kullanılmıştır: Birincisi, topraktan alınan sıcaklık, nem, pH gibi zaman serisi verilerinin Uzun-Kısa Vadeli Bellek (LSTM) modeli ile analiz edilerek hastalıkların erken teşhisi hedeflenmiştir. İkincisi, bitki fotoğrafları kullanılarak renklerin yeniden yapılandırılmasına dayalı bir Pix2Pix derin öğrenme modeli ile bitkilerdeki anomaliler tespit edilmiştir. Son olarak, iklim odalarından elde edilen bitki fotoğraflarının sınıflandırılması için AlexNet, ResNet50, VGG16 ve SqueezeNet gibi önceden eğitilmiş derin öğrenme modelleri transfer öğrenme tekniği ile kullanılmıştır. Sonuçlar, hem zamansal verilerin (LSTM ile %99,94 doğruluk) hem de görüntü tabanlı analizlerin (AlexNet ile %99,53 doğruluk) bitki hastalıklarının erken teşhisinde başarılı ve etkili olduğunu göstermiştir \[5\].

Elif Ünal Çayır tarafından 2024 yılında yapılan çalışmada, bitki hastalıklarının derin öğrenme ile sınıflandırılması için çeşitli görüntü işleme modellerinin performansları karşılaştırılmıştır. Bu amaçla, PlantVillage veri seti kullanılarak VGG16, ResNet, EfficientNet, Xception v3, Inception v3 ve bu modellerden oluşturulan yeni bir topluluk öğrenimi modeli eğitilmiştir. Her model 40 adım boyunca eğitilerek test edilmiştir. Yapılan değerlendirmeler sonucunda, önerilen topluluk öğrenimi modeli %94,23'lük test doğruluğu ile diğer tüm modellere kıyasla en yüksek başarıyı elde etmiştir. Bu sonuç, önerilen modelin bitki hastalıkları sınıflandırmasında etkili bir seçenek olduğunu ve gelecekteki tarım uygulamaları için önemli bir potansiyel taşıdığını göstermektedir \[6\].

Ahmet Enes Kılıç tarafından 2024 yılında yapılan çalışmada, transfer öğrenme tabanlı açıklanabilir derin öğrenme yöntemleri kullanılarak bitki hastalıklarının sınıflandırılması incelenmiştir. Çalışmada, PlantVillage veri seti üzerinde ResNet152, VGG16, EfficientNet-B0, EfficientNet-B1, DenseNet201, GoogLeNet ve Vision Transformers gibi yedi farklı derin öğrenme modeli eğitilmiştir. Modellerin performansları karşılaştırılmış ve karar mekanizmaları, açıklanabilir yapay zekâ (XAI) yöntemleriyle analiz edilmiştir. PlantVillage veri setinde en yüksek başarıyı %99,81 doğruluk oranı ile DenseNet201 modeli göstermiştir. Ayrıca, modellerin laboratuvar ortamı başarısının gerçek dünya verilerindeki (Kaggle Plant Pathology yarışma verileri) performansını yansıtmadığı, bu veri setlerinde başarı oranlarının düştüğü tespit edilmiştir. Bu durum, veri seti çeşitliliğinin model performansı üzerindeki kritik etkisini ve laboratuvar ile gerçek dünya verileri arasındaki farkların önemini vurgulamaktadır \[7\].

Şekil 2.3 Modellerinin karar mekanizmalarını karşılaştıran açıklanabilirlik (XAI) ısı haritaları.

Kadambari Raghuram ve Malaya Dutta Borah tarafından 2025 yılında yapılan çalışmada, domates bitkisi hastalıklarının tespiti için Derin Pekiştirmeli Öğrenme ve Transfer Öğrenme (DRL-TL) tabanlı hibrit bir model önerilmiştir. Bu yaklaşımda, öncelikle yüksek çözünürlüklü bitki yaprağı görüntüleri gelişmiş bir ön işleme tekniği ile iyileştirilmiştir. Ardından, önceden eğitilmiş MobileNetV2 modelini temel alan DRL-TL mimarisi, yaprakların uzamsal bilgilerini dikkate alarak üç boyutlu bir şekilde özellik çıkarmak için kullanılmıştır. Model, etiketlenmiş domates hastalığı görüntülerinden oluşan bir veri seti üzerinde eğitilmiştir. Elde edilen sonuçlar, önerilen hibrit öğrenme modelinin (DRL-TL) %99,23 doğruluk oranıyla mevcut yöntemlerden daha üstün bir performans sergilediğini göstermiştir. Çalışma, bu yaklaşımın farklı bitki türleri ve çevresel koşullarda hastalıkları doğru bir şekilde tespit ederek sağlamlık ve soyutlama yeteneği gösterdiğini ortaya koymaktadır.\[8\]

Argüeso ve arkadaşları tarafından 2020 yılında yapılan çalışmada, derin öğrenme yöntemlerinin büyük veri setlerine olan bağımlılığını azaltmak amacıyla, tarlada çekilmiş görüntüler kullanılarak bitki hastalıklarının sınıflandırılması için Az-Örnekle Öğrenme (Few-Shot Learning - FSL) yaklaşımı sunulmuştur. Bu çalışma için 38 farklı bitki yaprağı ve/veya hastalık türünü içeren PlantVillage veri setindeki 54.303 etiketli görüntü kullanılmıştır. Yöntem olarak, genel bitki yaprağı özelliklerini öğrenmek amacıyla Inception V3 ağı, veri setinin bir kaynak alanı (32 sınıf) üzerinde ince ayarlanmıştır. Ardından bu bilgi, Triplet kaybı (Triplet loss) kullanan Siyam ağları (Siamese networks) tabanlı bir FSL yöntemiyle hedef alandaki (6 sınıf) yeni hastalık türlerini çok az sayıda görüntü ile öğrenmek için kullanılmıştır. Sonuçlar, önerilen FSL yönteminin, sınıf başına yalnızca 80 görüntü kullanarak %90,0 medyan doğruluğa ulaştığını göstermiştir. Bu, tam veri setiyle elde edilen doğruluğa kıyasla sadece %4'lük bir düşüşle, eğitim verisi ihtiyacında yaklaşık %90'lık bir azalma anlamına gelmektedir. Ayrıca, bu yaklaşımın, özellikle çok az sayıda örnekle çalışıldığında, klasik ince ayar transfer öğrenme yöntemlerinden önemli ölçüde daha iyi performans gösterdiği ortaya konmuştur \[9\].

Mamta Gehlot ve Geeta Chhabra Gandhi tarafından 2023 yılında yapılan çalışmada, bitki hastalığı tespiti ve görselleştirilmesi için "EffiNet-TS" adında derinlemesine yorumlanabilir bir mimari önerilmiştir. Bu mimari, EfficientNetV2 tabanlı bir Öğretmen/Öğrenci (Teacher/Student) yapısı üzerine kurulmuştur ve mevcut ResTS mimarisindeki aşırı öğrenme (overfitting) sorunlarını çözmeyi ve görselleştirme sonuçlarını iyileştirmeyi hedeflemiştir. Çalışmada, ResTS'in Xception tabanlı yapısı yerine EfficientNetV2S kullanılmış ve kod çözücü ağına (decoder network) "DscDF" (Dual skip connection deconv fusion) adında yeni bir blok eklenmiştir. Modelin eğitimi ve testi için 38 kategori içeren PlantVillage veri seti kullanılmıştır. Deneysel sonuçlar, önerilen EffiNet-TS mimarisinin, 0.989 F1 skoru ve 0.990 doğruluk oranı ile ResTS mimarisini geride bıraktığını göstermiştir. Bu çalışma, hastalıkları sınıflandırmanın yanı sıra, hastalığın temel belirtilerini görselleştirerek yorumlanabilir sonuçlar sunan bir model ortaya koymaktadır \[10\].

Meenakshi Srivastava ve Jasraj Meena tarafından 2024 yılında yapılan çalışmada, bitki yapraklarındaki hastalıkların tespiti ve sınıflandırılması için modifiye edilmiş transfer öğrenme modelleri önerilmiştir. Bu amaçla VGG16, MobileNetV2, Xception, InceptionV3 ve DenseNet121 gibi beş farklı Derin Evrişimli Sinir Ağı modeli, aşırı öğrenme (overfitting) sorununu gidermek amacıyla veri artırımı, yeniden boyutlandırma gibi ön işleme teknikleri kullanılarak iki farklı veri seti üzerinde test edilmiştir. Çalışmada kullanılan ilk veri seti Mendeley'den alınmış olup 22 sınıfa ayrılmış 4590 yaprak görüntüsü içermektedir. İkinci veri seti ise PlantVillage'dan alınan ve 2 sınıfa ayrılmış 2052 kiraz yaprağı görüntüsünden oluşmaktadır. Sonuçlar, Mendeley veri setinde modifiye edilmiş MobileNetV2 modelinin %98.9 doğruluk oranıyla en iyi performansı gösterdiğini ortaya koymuştur. Kiraz veri setinde ise modifiye edilmiş DenseNet121 modeli %99.9 doğruluk oranı ile en başarılı model olmuştur \[11\].

Marriam Nawaz ve arkadaşları tarafından 2022 yılında yapılan çalışmada, domates bitkisi yapraklarındaki hastalıkların tespiti ve sınıflandırılması için ResNet-34 tabanlı Faster-RCNN mimarisine dayanan sağlam bir derin öğrenme yaklaşımı sunulmuştur. Bu yöntemde, ilk olarak hastalıklı bölgelerin (Region of Interest - RoI) etiketlenmesi yapılmış, ardından Evrişimli Blok Dikkat Modülü (Convolutional Block Attention Module - CBAM) ile güçlendirilmiş ResNet-34, özellik çıkarıcı olarak kullanılmıştır. Bu yapı, Faster-RCNN modeli içinde hem hastalıkları tespit etmek (lokalizasyon) hem de sınıflandırmak için eğitilmiştir. Model, PlantVillage Kaggle veri seti üzerinde test edilmiş ve %99,97 doğruluk ile 0.981 mAP (mean Average Precision) değeri elde etmiştir. Çalışma, önerilen yaklaşımın bulanıklık, gürültü, renk ve boyut değişimleri gibi çeşitli görüntü bozulmalarına karşı dayanıklı olduğunu ve düşük maliyetli, etkili bir çözüm sunduğunu göstermektedir \[12\].

Şekil 2.4 Nesne tespiti modeli ile bitki hastalıklarının tespiti ve yerinin belirlenmesi.

|     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- |
| **Referans** | **Bitki Türü/Türleri** | **Veri Seti** | **Sınıf Sayısı** | **Model** | **Model Performansı** |
| \[3\] | Çeşitli | New Plant Disease (Kaggle) - 87,867 görüntü | 38  | VGG16 | %97,22 |
| \[4\] | Çeşitli | PlantVillage - 20,6k+ görüntü | 15  | MobileNet SVM | %98,46 |
| \[5\] | Salatalık | Özel oluşturulmuş iklim odası veri seti | 2   | AlexNet | %99,53 |
| \[6\] | Çeşitli | PlantVillage | 15  | Topluluk Öğrenimi | %94,23 |
| \[7\] | Çeşitli | PlantVillage | Belirtilmemiş | DenseNet201 | %99,81 |
| \[8\] | Domates | Etiketlenmiş domates hastalığı görüntüleri | Belirtilmemiş | DRL-TL | %99,23 |
| \[9\] | Çeşitli | PlantVillage - 54,303 etiketli görüntü | 38  | Inception V3 Siyam Ağları (FSL) | %90,0 |
| \[10\] | Çeşitli | PlantVillage | 38  | EffiNet-TS | %99,0 |
| \[11\] | Çeşitli / Kiraz | Mendeley (4590) / PlantVillage (2052) | 22 / 2 | MobileNetV2 DenseNet121 | %98,9 |
| \[12\] | Domates | PlantVillage Kaggle veri seti | Belirtilmemiş | Faster-RCNN | %99,97 |

Tablo 2.1. Çalışmalarda kullanılan yöntemler ve performansları

1.  ÖNERİLEN SİSTEM

Literatürdeki çalışmalar, transfer öğrenme tabanlı modellerin bitki hastalığı sınıflandırmasında yüksek başarı sergilediğini göstermektedir. Bu doğrultuda, bu çalışmada da önceden eğitilmiş çeşitli derin öğrenme mimarileri kullanılmıştır. Modellerin eğitimi için temel kaynak olarak PlantVillage \[[14](https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset/data),15\] veri seti kullanılırken, modellerin gerçek dünya koşullarındaki performansını ve genelleme yeteneğini test etmek amacıyla ise Plant Pathology veri seti tercih edilmiştir. Bu bölümde, ilk olarak kullanılan veri setlerinin özellikleri ve uygulanan veri artırma (augmentation) gibi ön işleme adımları ele alınacaktır. Ardından, kullanılan modellerin mimari yapıları, eğitim süreçleri ve hiper parametreleri detaylandırılacaktır. Son olarak, eğitilen modelin entegre edildiği uygulamanın işleyişi ve mimarisi açıklanacaktır.

**3.1. Veri Setleri**

Çalışmada modellerin eğitileceği veri seti olarak Hughes ve Salathe (2015) tarafından oluşturulan ve Kaggle platformu üzerinden erişilen PlantVillage veri seti (Alidev, 2022) kullanılmıştır. Modelin gerçek dünya koşullarındaki performansının ölçülmesi için ise Plant Pathology \[[16](https://www.kaggle.com/competitions/plant-pathology-2021-fgvc8),[17](https://www.kaggle.com/competitions/plant-pathology-2020-fgvc7)\] veri setleri kullanılmıştır.

**PlantVillage**

Veri seti, 14 farklı bitki türünü kapsayan, 24 hastalıklı bitki sınıfı ve 14 sağlıklı bitki sınıfı olmak üzere toplam 38 sınıfı içeren 54,303 adet renkli (RGB) görüntüden oluşmaktadır. Veri setindeki görüntüler, kontrollü koşullar altında ve tek tip bir arka plan önünde çekilmiş yaprak örneklerinden oluşmaktadır, bu da modellerin öncelikle yaprak morfolojisi ve hastalık belirtileri üzerine odaklanmasını sağlamaktadır. Çalışmanın ilerleyen aşamalarında, modelin genelleme kabiliyetini artırmak ve aşırı öğrenmeyi (overfitting) önlemek amacıyla bu ham görüntülere veri artırma (data augmentation) teknikleri uygulanacaktır. Veri setinin bitki türlerine ve sınıflara göre dağılımına ilişkin istatistiki bilgiler Tablo 3.1’de sunulmuştur.

|     |     |
| --- | --- |
| **Sınıf Adı** | **Örnek Sayısı** |
| Apple_\__Apple_scab | 630 |
| Apple_\__Black_rot | 621 |
| Apple_\__Cedar_apple_rust | 275 |
| Apple_\__healthy | 1645 |
| Blueberry_\__healthy | 1502 |
| Cherry_(including_sour)\___Powdery_mildew | 1052 |
| Cherry_(including_sour)\___healthy | 854 |
| Corn_(maize)\___Cercospora_leaf_spot | 513 |
| Corn_(maize)\___Common_rust_ | 1192 |
| Corn_(maize)\___Northern_Leaf_Blight | 985 |
| Corn_(maize)\___healthy | 1162 |
| Grape_\__Black_rot | 1180 |
| Grape_\__Esca_(Black_Measles) | 1383 |
| Grape_\__Leaf_blight_(Isariopsis_Leaf_Spot) | 1076 |
| Grape_\__healthy | 423 |
| Orange_\__Haunglongbing_(Citrus_greening) | 5507 |
| Peach_\__Bacterial_spot | 2297 |
| Peach_\__healthy | 360 |
| Pepper,\_bell_\__Bacterial_spot | 997 |
| Pepper,\_bell_\__healthy | 1478 |
| Potato_\__Early_blight | 1000 |
| Potato_\__Late_blight | 1000 |
| Potato_\__healthy | 152 |
| Raspberry_\__healthy | 371 |
| Soybean_\__healthy | 5090 |
| Squash_\__Powdery_mildew | 1835 |
| Strawberry_\__Leaf_scorch | 1109 |
| Strawberry_\__healthy | 456 |
| Tomato_\__Bacterial_spot | 2127 |
| Tomato_\__Early_blight | 1000 |
| Tomato_\__Late_blight | 1909 |
| Tomato_\__Leaf_Mold | 952 |
| Tomato_\__Septoria_leaf_spot | 1771 |
| Tomato_\__Spider_mites Two-spotted_spider_mite | 1676 |
| Tomato_\__Target_Spot | 1404 |
| Tomato_\__Tomato_Yellow_Leaf_Curl_Virus | 5357 |
| Tomato_\__Tomato_mosaic_virus | 337 |
| Tomato_\__healthy | 1591 |
|     |     |

Tablo 3.1. Sınıflandırma adları ve örnek sayısı \[14\].

Veri setinin hazırlanması aşamasında, modelin genelleme yeteneğini artırmak ve aşırı öğrenmenin (overfitting) önüne geçmek amacıyla veri kümesi üç ana parçaya ayrılmıştır:

- Eğitim Seti (Training Set): Verinin %80'i modelin ağırlıklarını güncellemek ve öğrenme sürecini gerçekleştirmek için kullanılmıştır.
- Doğrulama Seti (Validation Set): Verinin %10'u, eğitim sırasında modelin performansını izlemek, hiperparametre optimizasyonu yapmak ve "early stopping" (erken durdurma) mekanizmasını işletmek için ayrılmıştır.
- Test Seti (Test Set): Verinin kalan %10'u, eğitilen modelin daha önce hiç görmediği veriler üzerindeki nihai performansını ölçmek için kullanılmıştır.

Veri bölme işlemi sırasında stratified sampling (tabakalı örnekleme) yöntemi kullanılarak, her bir sınıfın eğitim, doğrulama ve test setlerinde dengeli bir şekilde temsil edilmesi sağlanmıştır.

Görüntü ön işleme (preprocessing) adımlarında, tüm görüntüler EfficientNetB3 modelinin giriş boyutuna uygun olarak 224x224 piksel boyutlarına yeniden boyutlandırılmıştır. Ayrıca, modelin daha hızlı ve kararlı öğrenmesini sağlamak amacıyla görüntüler, ImageNet veri setinin istatistiksel değerleri (ortalama: \[0.485, 0.456, 0.406\], standart sapma: \[0.229, 0.224, 0.225\]) kullanılarak normalize edilmiştir. Eğitim setindeki veri çeşitliliğini artırmak için RandomHorizontalFlip (rastgele yatay çevirme) gibi veri artırma (data augmentation) teknikleri uygulanmıştır.

Şekil 3.1: PlantVillage veri setinden örnek sağlıklı ve hastalıklı yaprak görüntüleri.

**3.2. Model Mimarisi**

Geliştirilen sistemde, derin öğrenme tabanlı sınıflandırma işlemi için EfficientNet-B3 mimarisi temel alınmıştır. EfficientNet ailesi, modelin derinliğini, genişliğini ve çözünürlüğünü dengeli bir şekilde ölçeklendirerek (compound scaling), daha az parametre ile yüksek doğruluk oranlarına ulaşabilen modern bir konvolüsyonel sinir ağı (CNN) mimarisidir. B3 varyasyonu, mobil cihazlarda çalışabilecek kadar hafif, ancak karmaşık bitki hastalıklarını ayırt edebilecek kadar güçlü olduğu için tercih edilmiştir.

Çalışmada Transfer Learning (Transfer Öğrenme) tekniği uygulanmıştır. Bu yöntem, modelin sıfırdan eğitilmesi yerine, daha önce ImageNet gibi büyük bir veri seti üzerinde eğitilmiş ağırlıkların başlangıç noktası olarak kullanılmasını sağlar. Bu sayede, model temel görsel özellikleri (kenarlar, dokular vb.) zaten öğrenmiş olarak başlar ve eğitim süresi kısalırken başarı oranı artar.

Modelin sınıflandırma katmanı (classifier), projeye özgü olarak yeniden tasarlanmıştır. EfficientNet-B3'ün orijinal son katmanı çıkarılarak yerine aşağıdaki katmanlardan oluşan özelleştirilmiş bir blok eklenmiştir:

1.  Batch Normalization: Eğitim sürecini hızlandırmak ve kararlı hale getirmek için.
2.  Linear Layer (Dense): 1536 giriş özelliğini 256 özelliğe indiren tam bağlantılı katman.
3.  ReLU Aktivasyon Fonksiyonu: Doğrusal olmayan ilişkileri öğrenmek için.
4.  Dropout (0.45): Nöronların %45'ini rastgele kapatarak aşırı öğrenmeyi engellemek için.
5.  Output Layer: 256 özelliği 38 sınıfa dönüştüren son sınıflandırma katmanı.

Ayrıca modelin genelleme yeteneğini artırmak için L1 ve L2 regülasyon teknikleri de kayıp fonksiyonuna entegre edilmiştir.

Şekil 3.3: Önerilen transfer öğrenme tabanlı model mimarisi.

**3.4. Eğitim Süreci**

Modelin eğitimi, önerilen EfficientNet-B3 mimarisi üzerinde, PyTorch derin öğrenme kütüphanesi kullanılarak gerçekleştirilmiştir. Eğitim stratejisi, sadece modelin ağırlıklarını güncellemeyi değil, aynı zamanda aşırı öğrenmeyi (overfitting) engellemeyi ve en iyi genelleme yeteneğine sahip modeli elde etmeyi hedefleyen dinamik bir yapı üzerine kurulmuştur.

**3.4.1. Eğitim Parametreleri ve Konfigürasyon**

Eğitim sürecinde kullanılan hiperparametreler, literatür taraması ve deneysel çalışmalar sonucunda belirlenmiştir. Optimizasyon algoritması olarak, özellikle gömülü (embedding) katmanları olan veya seyrek gradyanlara sahip modellerde kararlı sonuçlar veren Adamax tercih edilmiştir. Adamax, Adam algoritmasının bir varyasyonu olup, sonsuz norm () tabanlı güncelleme kuralı sayesinde parametre güncellemelerinde daha stabil bir davranış sergilemektedir.

Ayrıca, modelin karmaşıklığını kontrol altında tutmak için kayıp fonksiyonuna (Loss Function) ek olarak L1 ve L2 regülasyonu (Elastic Net yaklaşımı) uygulanmıştır. Bu, modelin ağırlıklarının çok büyümesini engelleyerek (L2) ve gereksiz ağırlıkları sıfıra yaklaştırarak (L1) modelin daha sade ve gürbüz olmasını sağlar.

|     |     |
| --- | --- |
| **Parametre** | **Değer/Açıklama** |
| Optimizer | Adamax |
| Başlangıç Öğrenme Oranı (LR) | 0.001 |
| Batch Size (Demet Boyutu) | 40  |
| Epoch Sayısı | 40 (Maksimum) |
| Kayıp Fonksiyonu | CrossEntropyLoss |
| L1 Regülasyon Katsayısı | 0.006 |
| L2 Regülasyon Katsayısı | 0.016 |
| Dropout Oranı | 0.45 |

Tablo 3.2: Eğitim sürecinde kullanılan temel hiperparametreler.

**3.4.2. Eğitim Dinamikleri ve Geri Çağırma (Callback) Sistemi**

Eğitim sürecini otomatize etmek ve en iyi sonucu garanti altına almak için özel bir TrainingCallback mekanizması geliştirilmiştir. Bu mekanizma eğitim boyunca şu adımları izler:

Dinamik Öğrenme Oranı (LR Scheduling), eğitim sırasında modelin doğrulama başarısı (validation accuracy) veya kaybı (validation loss) belirli bir süre (patience=3 epoch) iyileşmezse, öğrenme oranı 0.5 faktörü ile çarpılarak yarıya düşürülür. Bu, modelin yerel minimumlara sıkışmasını engeller ve daha hassas ağırlık güncellemeleri yapılmasını sağlar. Erken Durdurma (Early Stopping), öğrenme oranı düşürülmesine rağmen model performansında iyileşme gözlemlenmezse (stop_patience=3), eğitim süreci 40 epoch tamamlanmadan sonlandırılır. Bu yöntem, gereksiz hesaplama maliyetini önler ve aşırı öğrenmeyi engeller. En İyi Modelin Kaydedilmesi (Checkpointing), her epoch sonunda, modelin doğrulama setindeki performansı ölçülür. Eğer mevcut epoch'taki başarı, o ana kadarki en yüksek başarıdan daha iyiyse, model ağırlıkları [best_model.pth](vscode-file://vscode-app/c:/Users/Admin/AppData/Local/Programs/Microsoft%20VS%20Code/resources/app/out/vs/code/electron-browser/workbench/workbench.html) olarak diske kaydedilir. Böylece eğitim bittiğinde elimizde her zaman en başarılı model bulunur.

**3.5. Model Dönüşümü ve Mobil Optimizasyon**

Eğitilen PyTorch modelinin mobil uygulamada verimli bir şekilde çalışabilmesi için, modelin mobil cihazlara uygun bir formata dönüştürülmesi gerekmektedir. Bu amaçla, model TensorFlow Lite formatına dönüştürülmüştür. Bu dönüşüm süreci iki aşamada gerçekleştirilmiştir:

1.  ONNX (Open Neural Network Exchange) Dönüşümü: İlk olarak, eğitilen PyTorch modeli platformlar arası model paylaşım standardı olan ONNX formatına export edilmiştir. ONNX, farklı derin öğrenme çerçeveleri arasında bir köprü görevi görerek modelin taşınabilirliğini sağlar.
2.  TFLite Dönüşümü: Elde edilen ONNX modeli, onnx2tf aracı kullanılarak TensorFlow Lite formatına çevrilmiştir. TFLite, mobil ve gömülü cihazlar için optimize edilmiş, düşük gecikme süresi ve küçük dosya boyutu sunan bir formattır.

Dönüşüm sırasında, modelin boyutunu küçültmek ve işlem hızını artırmak amacıyla Float32 veya Float16 hassasiyetinde optimizasyonlar yapılmıştır. Sonuç olarak elde edilen [plant_model.tflite](vscode-file://vscode-app/c:/Users/Admin/AppData/Local/Programs/Microsoft%20VS%20Code/resources/app/out/vs/code/electron-browser/workbench/workbench.html) dosyası, mobil uygulama içerisine gömülerek internet bağlantısına ihtiyaç duymadan cihaz üzerinde sınıflandırma yapılmasına olanak tanımıştır.

Şekil 3.6: Modelin mobil platforma uygun hale getirilmesi için uygulanan dönüşüm adımları

**3.6. Mobil Uygulama İçin Arka Plan Kaldırma**

Bitki hastalığı teşhisinde modelin başarısını etkileyen en önemli faktörlerden biri, giriş görüntüsünün kalitesi ve içerdiği gürültü miktarıdır. Kullanıcıların mobil cihazlarıyla çektikleri fotoğraflarda yaprak dışında toprak, gökyüzü, eller veya diğer bitkiler gibi arka plan öğeleri bulunabilmektedir. Bu istenmeyen öğeler, modelin dikkatini dağıtarak sınıflandırma başarısını olumsuz etkileyebilir. Bu sorunu çözmek amacıyla, görüntü sınıflandırma modeline gönderilmeden önce yaprak görüntüsünün arka planını otomatik olarak kaldıran bir ön işleme adımı entegre edilmiştir.

**3.6.1. U²-Net Modeli ve Tercih Sebebi**

Arka plan kaldırma işlemi için U²-Net (U-Square Net) mimarisi tercih edilmiştir. U²-Net, Qin ve arkadaşları tarafından 2020 yılında önerilen, öne çıkan nesne tespiti (Salient Object Detection - SOD) için tasarlanmış derin bir sinir ağı mimarisidir \[18\].

U²-Net'in bu çalışmada tercih edilmesinin başlıca nedenleri şunlardır:

1\. Yüksek Doğruluk: U²-Net, iç içe geçmiş U-yapıları (Residual U-blocks - RSU) sayesinde hem yerel hem de küresel bağlamsal bilgileri etkili bir şekilde yakalayabilmektedir. Bu sayede karmaşık şekillere sahip yaprakların kenarlarını bile hassas bir şekilde tespit edebilmektedir.

2\. Hafif Versiyon (U²-Net-P): Orijinal U²-Net modelinin yanı sıra, mobil cihazlarda verimli çalışabilmesi için tasarlanmış daha küçük bir versiyonu olan U²-Net-P (Portable) sunulmaktadır. Bu çalışmada, mobil uygulama için U²-Net-P modeli tercih edilmiştir. U²-Net-P, orijinal modele kıyasla önemli ölçüde daha az parametre içermesine rağmen, tatmin edici segmentasyon sonuçları üretebilmektedir.

3\. Önceden Eğitilmiş Ağırlıklar: U²-Net, geniş bir veri seti üzerinde önceden eğitilmiş olarak sunulmaktadır. Bu sayede, ek eğitim gerektirmeden doğrudan kullanılabilmektedir (Transfer Learning).

**3.6.2. U²-Net Mimarisi**

U²-Net'in temel yapı taşı, RSU (Residual U-block) bloklarıdır. Klasik U-Net mimarisindeki encoder-decoder yapısından farklı olarak, U²-Net her bir encoder ve decoder aşamasında ayrı birer U-yapısı (RSU bloğu) kullanır. Bu iç içe geçmiş yapı, modelin farklı ölçeklerdeki özellikleri daha iyi öğrenmesini sağlar.

Model, giriş olarak RGB formatında bir görüntü alır ve çıkış olarak her piksel için 0 ile 1 arasında bir olasılık değeri içeren tek kanallı bir maske (mask) üretir. Bu maskede yüksek değerler (1'e yakın) ön plan nesnesini (yaprak), düşük değerler (0'a yakın) ise arka planı temsil eder.

Şekil 3.7: U²-Net mimarisinin genel yapısı. Her bir En (Encoder) ve De (Decoder) bloğu, kendi içinde bir RSU yapısı barındırmaktadır.

**3.6.3. Uygulama Akışı**

Arka plan kaldırma işlemi, mobil uygulama içerisinde aşağıdaki adımlarla gerçekleştirilmektedir:

1\. Görüntü Yükleme: Kullanıcı, kamera veya galeriden bir yaprak görüntüsü seçer.

2\. Ön İşleme (Preprocessing): Görüntü, U²-Net-P modelinin beklediği giriş boyutuna (320x320 piksel) yeniden boyutlandırılır ve ImageNet normalizasyon değerleri (ortalama: \[0.485, 0.456, 0.406\], standart sapma: \[0.229, 0.224, 0.225\]) kullanılarak normalize edilir.

3\. Maske Üretimi (Inference): Normalize edilmiş görüntü, TensorFlow Lite formatına dönüştürülmüş U²-Net-P modeline (\`u2netp_float32.tflite\`) beslenir. Model, çıkış olarak bir segmentasyon maskesi üretir.

4\. Son İşleme (Postprocessing): Üretilen maske, orijinal görüntü boyutlarına yeniden ölçeklenir. Sigmoid fonksiyonu uygulanarak piksel değerleri 0-1 aralığına normalize edilir.

5\. Arka Plan Kaldırma: Orijinal görüntü RGBA formatına dönüştürülür ve üretilen maske, alfa (şeffaflık) kanalı olarak uygulanır. Bu işlem sonucunda arka plan şeffaf hale gelir ve sadece yaprak görüntüsü kalır.

6\. Hastalık Tespiti: Arka planı kaldırılmış görüntü, bitki hastalığı sınıflandırma modeline (EfficientNet-B3 tabanlı TFLite modeli) gönderilerek teşhis işlemi gerçekleştirilir.

Şekil 3.8: Arka plan kaldırma işlemi örneği. (a) Orijinal görüntü, (b) U²-Net-P tarafından üretilen maske, (c) Arka planı kaldırılmış sonuç görüntüsü.

**3.6.4. TensorFlow Lite Dönüşümü**

U²-Net-P modelinin mobil cihazlarda verimli çalışabilmesi için, PyTorch formatındaki orijinal model ağırlıkları (\`.pth\`) önceden de bitki hastalığı tespit etme modelinde yaptığımız gibi önce ONNX formatına, ardından TensorFlow Lite (\`.tflite\`) formatına dönüştürülmüştür.

**3.7 Mobil Uygulama**

Eğitilen derin öğrenme modellerinin son kullanıcıya ulaştırılması için bir mobil uygulama geliştirilmiştir. Bu bölümde, uygulamanın geliştirilmesinde kullanılan teknolojiler, mimari yapısı, model entegrasyonu ve sunulan özellikler detaylı olarak açıklanmaktadır.

**3.7.1 Geliştirme Ortamı ve Teknolojiler**

Mobil uygulama, Google tarafından geliştirilen açık kaynaklı bir kullanıcı arayüzü (UI) geliştirme kiti olan Flutter framework'ü ve Dart programlama dili kullanılarak geliştirilmiştir. Flutter'ın bu çalışmada tercih edilmesinin başlıca nedenleri şunlardır:

1\. Çapraz Platform Desteği: Tek bir kod tabanı ile hem Android hem de iOS platformlarında çalışabilen uygulamalar geliştirilebilmektedir. Bu sayede geliştirme süresi ve maliyeti önemli ölçüde azaltılmıştır.

2\. Yüksek Performans: Flutter, uygulamaları doğrudan native ARM koduna derlediğinden, JavaScript köprüsü kullanan diğer çapraz platform çözümlerine kıyasla daha yüksek performans sunmaktadır.

3\. TensorFlow Lite Entegrasyonu: Flutter, tflite_flutter paketi aracılığıyla TensorFlow Lite modellerinin mobil cihazlarda verimli bir şekilde çalıştırılmasına olanak tanımaktadır.

|     |     |     |
| --- | --- | --- |
| Teknoloji/Kütüphane | Versiyon | Kullanım Amacı |
| Flutter SDK | 3.10.1 | Çapraz platform mobil uygulama geliştirme |
| Dart | 3.x | Programlama dili |
| tflite_flutter | 0.12.1 | TensorFlow Lite model çıkarımı (inference) |
| image | 4.5.4 | Görüntü işleme ve manipülasyonu |
| Supabase | 2.8.4 | Bulut veritabanı ve kullanıcı kimlik doğrulama |
| Hive | 2.2.3 | Yerel veri depolama |
| Google Generative AI | 0.4.6 | Gemini tabanlı AI sohbet asistanı |
| Riverpod | 3.0.3 | Durum yönetimi |

Tablo 3.3: Mobil uygulamada kullanılan temel teknolojiler ve kütüphaneler.

**3.7.2 Uygulama Mimarisi**

Uygulama, sürdürülebilir ve ölçeklenebilir bir yapı için katmanlı mimari (Layered Architecture) prensiplerine uygun olarak tasarlanmıştır. Bu mimari yaklaşım, kodun modüler olmasını, test edilebilirliğini ve bakım kolaylığını sağlamaktadır. Uygulama mimarisi üç ana katmandan oluşmaktadır:

1\. Sunum Katmanı (Presentation Layer): Kullanıcı arayüzü bileşenlerini ve ekranları içermektedir. Flutter widget'ları kullanılarak Material Design 3 tasarım prensiplerine uygun arayüzler oluşturulmuştur.

2\. İş Mantığı Katmanı (Domain Layer): Riverpod kütüphanesi ile durum yönetimi (state management) ve iş kuralları bu katmanda yer almaktadır. Provider'lar aracılığıyla veri akışı ve uygulama durumu yönetilmektedir.

3\. Veri Katmanı (Data Layer): Yerel depolama (Hive), bulut servisleri (Supabase) ve model çıkarımı (TFLite) işlemleri bu katmanda gerçekleştirilmektedir.

**3.7.3 Model Entegrasyonu ve Görüntü İşleme**

Bölüm 3.5 ve 3.6'da açıklanan TensorFlow Lite formatındaki modeller (bitki hastalığı sınıflandırma ve arka plan kaldırma), mobil uygulamaya entegre edilmiştir. Kullanıcının çektiği veya galeriden seçtiği bir görüntü, hastalık teşhisi için aşağıdaki işlem hattından (pipeline) geçirilmektedir:

1\. Görüntü Alımı: Kullanıcı, cihaz kamerası veya galeri aracılığıyla bir yaprak görüntüsü seçer.

2\. Arka Plan Kaldırma: Görüntü, U²-Net-P modeline (u2netp_float32.tflite) beslenerek yaprak segmentasyonu gerçekleştirilir. Bu adım, arka plandaki gürültüyü ortadan kaldırarak sınıflandırma başarısını artırmaktadır.

3\. Ön İşleme (Preprocessing): Segmente edilmiş görüntü, EfficientNet-B3 modelinin beklediği formata dönüştürülür:

\- 224×224 piksel boyutuna yeniden boyutlandırma

\- ImageNet normalizasyon değerleri ile normalize etme (ortalama: \[0.485, 0.456, 0.406\], standart sapma: \[0.229, 0.224, 0.225\])

\- Tensor formatına dönüştürme

4\. Sınıflandırma (Classification): Ön işlemden geçen görüntü, bitki hastalığı sınıflandırma modeline (plant_model.tflite) beslenir ve 38 sınıf arasından en yüksek olasılığa sahip hastalık tespit edilir.

5\. Sonuç Gösterimi: Tespit edilen hastalık adı, güven skoru ve tedavi önerileri kullanıcıya sunulur.

Şekil 3.10: Mobil uygulamada görüntü işleme akış diyagramı.

**3.7.4 Uygulama Özellikleri**

Geliştirilen mobil uygulama, bitki hastalığı teşhisinin yanı sıra çiftçilere kapsamlı bir tarım asistanlığı sunmak amacıyla çeşitli özellikler içermektedir.

**3.7.4.1 Hastalık Teşhisi**

Uygulamanın ana işlevi olan hastalık teşhisi modülü, kullanıcının kamera veya galeriden seçtiği bitki yaprağı görüntüsünü analiz ederek hastalık tespiti yapmaktadır. Teşhis sonucunda kullanıcıya şu bilgiler sunulmaktadır:

\- Tespit edilen hastalık adı ve güven skoru (confidence score)

\- Hastalığın detaylı açıklaması ve belirtileri

\- Hastalığa neden olan patojen türü (mantar, bakteri, virüs)

\- Şiddet seviyesi (düşük, orta, yüksek, kritik)

\- Tedavi önerileri ve uygulama yöntemleri

\- Önleme yöntemleri ve bakım ipuçları

Şekil 3.11: Hastalık teşhisi ekran görüntüleri. (a) Görüntü seçim ekranı, (b) Analiz süreci, (c) Teşhis sonucu ve tedavi önerileri.

**3.7.4.2 Bahçe Yönetimi (Sanal Bahçe)**

Kullanıcılar, tespit edilen hastalıklı bitkilerini uygulamadaki sanal bahçelerine ekleyerek takip edebilmektedir. Bu modül şu özellikleri içermektedir:

\- Bitki ekleme, düzenleme ve silme

\- Her bitki için teşhis geçmişi görüntüleme

\- Bakım notları ve hatırlatıcılar ekleme

\- Tedavi sürecinin takibi

Şekil 3.12: Bahçe yönetimi ekran görüntüleri. (a) Bahçem listesi, (b) Bitki detay sayfası.

**3.7.4.3 Yapay Zeka Sohbet Asistanı**

Uygulama, Google Gemini API kullanılarak geliştirilmiş bir yapay zeka sohbet asistanı (chatbot) içermektedir. "PlantDoc Asistan" olarak adlandırılan bu chatbot, yalnızca bitkiler, bitki bakımı ve bitki hastalıkları konularında sorulara yanıt vermek üzere özelleştirilmiştir. Sistem yönergesi (system prompt) aracılığıyla chatbot'un uzmanlık alanı sınırlandırılmış ve konu dışı sorulara nazikçe yönlendirme yapması sağlanmıştır.

Chatbot'un sunduğu özellikler:

\- Bitki hastalıkları hakkında detaylı bilgi

\- Tedavi yöntemleri ve ilaç önerileri

\- Mevsimsel bakım tavsiyeleri

\- Gübreleme ve sulama rehberliği

\- Zararlılarla mücadele yöntemleri

Şekil 3.13: Yapay zeka sohbet asistanı ekran görüntüsü.

\*\*3.7.4.4 Çevrimdışı Çalışma ve Bulut Senkronizasyonu\*\*

Uygulama, internet bağlantısı olmadan da temel işlevlerini yerine getirebilecek şekilde tasarlanmıştır. TensorFlow Lite modelleri cihaz üzerinde çalıştığından, hastalık teşhisi işlemi tamamen çevrimdışı (offline) olarak gerçekleştirilebilmektedir.

Kullanıcı verileri, Hive yerel veritabanında saklanmakta ve internet bağlantısı mevcut olduğunda Supabase bulut servisi ile senkronize edilmektedir. Bu hibrit yaklaşım şu avantajları sağlamaktadır:

\- İnternet bağlantısı olmadan kesintisiz kullanım

\- Verinin birden fazla cihaz arasında senkronizasyonu

\- Otomatik yedekleme ve veri güvenliği

**3.7.5 Kullanıcı Arayüzü Tasarımı**

Uygulama arayüzü, Google'ın Material Design 3 tasarım sistemine uygun olarak geliştirilmiştir. Kullanıcı deneyimini iyileştirmek amacıyla koyu tema (dark mode) desteği eklenmiş olup, kullanıcılar tercihlerine göre tema değiştirebilmektedir.

Ana navigasyon yapısı, alt navigasyon çubuğu (bottom navigation bar) aracılığıyla üç ana sekmeden oluşmaktadır:

1\. Teşhislerim: Yapılan teşhislerin kronolojik geçmişi, arama ve filtreleme özellikleri

2\. Bahçem: Eklenen bitkilerin listesi ve yönetimi

3\. Ayarlar: Kullanıcı profili, tema tercihleri ve senkronizasyon ayarları

Ayrıca, sayfalar arasında parmak kaydırma (swipe gesture) ile geçiş yapılabilmektedir. Bu özellik, kullanıcı deneyimini daha akıcı hale getirmektedir.

Şekil 3.14: Uygulama ana ekran görüntüleri. (a) Teşhislerim sekmesi, (b) Bahçem sekmesi, (c) Koyu tema görünümü.

3.7.6 Performans ve Optimizasyon

Mobil cihazlarda verimli çalışma sağlamak amacıyla çeşitli optimizasyon teknikleri uygulanmıştır:

1\. Model Optimizasyonu: TensorFlow Lite modellerinde Float16 kuantizasyon uygulanarak model boyutu küçültülmüş ve çıkarım (inference) süresi azaltılmıştır.

2\. Görüntü Sıkıştırma: Buluta yüklenen görüntüler, kalite kaybı minimize edilerek sıkıştırılmaktadır. Bu sayede depolama alanı ve bant genişliği kullanımı optimize edilmiştir.

3\. Önbellekleme (Caching): Sık erişilen veriler ve görüntüler yerel olarak önbelleğe alınarak tekrar tekrar indirilmesi önlenmiştir.

4\. Lazy Loading: Teşhis geçmişindeki görüntüler, ekranda görünür hale geldiklerinde yüklenmektedir (on-demand loading).

Uygulama performans metrikleri Tablo 3.4'te sunulmuştur.

|     |     |     |
| --- | --- | --- |
| Metrik | EfficientNet-B3 (Sınıflandırma) | U²-Net-P (Segmentasyon) |
| Model Boyutu | ~48 MB | ~4.7 MB |
| Ortalama Çıkarım Süresi | ~200 ms | ~150 ms |
| RAM Kullanımı | ~80 MB | ~60 MB |

Tablo 3.4: Mobil uygulama model performans metrikleri. Ölçümler Samsung Galaxy M34 (Android 16, 6GB RAM) cihazında gerçekleştirilmiştir.

Sonuç olarak, geliştirilen mobil uygulama, eğitilen derin öğrenme modellerini son kullanıcıya pratik ve erişilebilir bir şekilde sunmaktadır. Çevrimdışı çalışma desteği, kullanıcı dostu arayüzü ve yapay zeka asistanı ile uygulama, çiftçilerin bitki hastalıklarını hızlı ve doğru bir şekilde teşhis etmelerine yardımcı olmayı amaçlamaktadır.

<div class="joplin-table-wrapper"><table><tbody><tr><td><p></p><p></p></td><td><p>KAYNAKLAR</p><p></p></td></tr><tr><td><p></p><p>[1].</p></td><td><p><a href="http://www.global-agriculture.com">global-agriculture.com</a>, “Upto 40 percent of Global Crop Production is lost due to Pests and Diseases every year: FAO”, [Online]. <a href="https://www.global-agriculture.com/global-agriculture/up-to-40-percent-of-global-crop-production-is-lost-due-to-pests-and-diseases-every-year-fao/">https://www.global-agriculture.com/global-agriculture/up-to-40-percent-of-global-crop-production-is-lost-due-to-pests-and-diseases-every-year-fao/</a></p></td></tr><tr><td><p>[2].</p></td><td><p>FAO , “The hidden health crisis: How plant diseases threaten global food security”, [Online]. <a href="https://www.fao.org/one-health/highlights/how-plant-diseases-threaten-global-food-security">https://www.fao.org/one-health/highlights/how-plant-diseases-threaten-global-food-security</a></p><p></p></td></tr><tr><td><p>[3].</p></td><td><h1>F. S. Seyed Khamoushi, "Plant Disease Detection Using Advanced Deep Learning Methods", Yüksek Lisans Tezi, Bilgisayar Mühendisliği Bölümü, İstanbul Aydın Üniversitesi, 2025.</h1><p></p></td></tr><tr><td><p>[4].</p></td><td><h1>Z. F. A. Ishkayyir, "Derin Öğrenmeye Dayalı Bitki Hastalıkları Tespiti İçin Hibrit Bir Model", Yüksek Lisans Tezi, Bilgisayar Mühendisliği Bölümü, Atatürk Üniversitesi, Erzurum, 2025.</h1><p></p></td></tr><tr><td><p>[5].</p></td><td><h1>Elif Genç, "Bitki Hastalıklarının Yapay Zeka ile Erken Tespiti", Yüksek Lisans Tezi, Bilgisayar Mühendisliği Anabilim Dalı, Eskişehir Osmangazi Üniversitesi, 2025.</h1><p></p></td></tr><tr><td><p>[6].</p></td><td><p>E. Ünal Çayır, "Bitki Hastalıklarının Derin Öğrenme ile Sınıflandırılması", Yüksek Lisans Tezi, Bilgisayar Mühendisliği Ana Bilim Dalı, Gazi Üniversitesi, 2024.</p><p></p></td></tr><tr><td><p>[7].</p></td><td><h1>A. E. Kılıç, "Transfer Öğrenme Tabanlı Açıklanabilir Derin Öğrenme Yöntemleri Kullanılarak Bitki Hastalıklarının Sınıflandırılması", Yüksek Lisans Tezi, Bilgisayar Mühendisliği Anabilim Dalı, Necmettin Erbakan Üniversitesi, 2024.</h1><p></p></td></tr><tr><td><p>[8].</p></td><td><p>K. Raghuram ve M. D. Borah, “A Hybrid Learning Model for Tomato Plant Disease Detection using Deep Reinforcement Learning with Transfer Learning”,&nbsp;<em>Procedia Computer Science</em>, c. 252, s. 341–354, 2025.</p><p></p></td></tr><tr><td><p>[9].</p></td><td><p>D. Argüeso, A. Picon, U. Irusta, A. Medela, M. G. San-Emeterio, A. Bereciartua, ve A. Alvarez-Gila, “Few-Shot Learning approach for plant disease classification using images taken in the field”,&nbsp;<em>Computers and Electronics in Agriculture</em>, c. 175, 105542, 2020.</p><p></p></td></tr><tr><td><p>[10].</p></td><td><p>M. Gehlot ve G. C. Gandhi, ““EffiNet-TS”: A deep interpretable architecture using EfficientNet for plant disease detection and visualization”,&nbsp;<em>Journal of Plant Diseases and Protection</em>, c. 130, s. 413–430, 2023.</p><p></p></td></tr><tr><td><p>[11].</p></td><td><p>M. Srivastava ve J. Meena, “Plant leaf disease detection and classification using modified transfer learning models”,&nbsp;<em>Multimedia Tools and Applications</em>, c. 83, s. 38411–38441, 2024.</p></td></tr><tr><td><p>[12].</p></td><td><p>M. Nawaz, T. Nazir, A. Javed, M. Masood, J. Rashid, J. Kim, ve A. Hussain, “A robust deep learning approach for tomato plant leaf disease localization and classification”,&nbsp;<em>Scientific Reports</em>, c. 12, sy. 1, 18568, 2022.</p></td></tr><tr><td><p>[13].</p></td><td><p>GeeksforGeeks, "ML | Introduction to Transfer Learning", GeeksforGeeks, 8 Ekim 2025. [Çevrimiçi]. Erişim Adresi: <a href="https://www.geeksforgeeks.org/machine-learning/ml-introduction-to-transfer-learning">https://www.geeksforgeeks.org/machine-learning/ml-introduction-to-transfer-learning</a>. [Erişim Tarihi: 17 Kasım 2025].</p><p></p></td></tr><tr><td><p>[14].</p></td><td><p>A. Alidev, "PlantVillage dataset", Kaggle, 2022. [Çevrimiçi]. Available: <a href="https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset">https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset</a>. [Erişim Tarihi: 15.11.2025].</p></td></tr><tr><td><p>[15].</p></td><td><p>Hughes, D. P., &amp; Salathe, M. (2015). An open access repository of images on plant health to enable the development of mobile disease diagnostics. arXiv preprint arXiv:1511.08060.</p></td></tr><tr><td><p>[16].</p></td><td><p>Cornell University, "Plant Pathology 2021 - FGVC8," Kaggle, 2021. [Çevrimiçi]. Available: <a href="https://www.kaggle.com/competitions/plant-pathology-2021-fgvc8">https://www.kaggle.com/competitions/plant-pathology-2021-fgvc8</a>. [Erişim Tarihi: 15.11.2025].</p><p></p></td></tr><tr><td><p>[17].</p></td><td><h1>Cornell University, "Plant Pathology 2020 - FGVC7," Kaggle, 2020. [Çevrimiçi]. Available:&nbsp;<a href="https://www.google.com/url?sa=E&amp;q=https%3A%2F%2Fwww.kaggle.com%2Fcompetitions%2Fplant-pathology-2020-fgvc7" target="_blank">https://www.kaggle.com/competitions/plant-pathology-2020-fgvc7</a>. [Erişim Tarihi: 15.11.2025].</h1><p></p></td></tr><tr><td><p>[18].</p></td><td><h1>Qin, X., Zhang, Z., Huang, C., Dehghan, M., Zaiane, O. R., &amp; Jagersand, M. (2020). U2-Net: Going deeper with nested U-structure for salient object detection. *Pattern Recognition*, 106, 107404.</h1></td></tr></tbody></table></div>

|     |     |
| --- | --- |
| \[19\]. |     |
| \[20\]. |     |
|     |     |

|     |     |
| --- | --- |
| \[21\]. |     |

<div class="joplin-table-wrapper"><table><tbody><tr><td><p>[22].</p></td><td><p></p><p></p><p></p></td></tr><tr><td><p>[23].</p></td><td><p></p><p></p></td></tr><tr><td><p>[24].</p></td><td><h1></h1></td></tr><tr><td><p></p></td><td><h1></h1></td></tr></tbody></table></div>

|     |     |
| --- | --- |
| \[25\]. |     |

<div class="joplin-table-wrapper"><table><tbody><tr><td><p></p></td><td><h1></h1></td></tr><tr><td><p></p></td><td><h1></h1></td></tr></tbody></table></div>

|     |     |
| --- | --- |
| \[26\]. |     |

|     |     |
| --- | --- |
| \[27\]. |     |

<div class="joplin-table-wrapper"><table><tbody><tr><td><p>[28].</p></td><td><p></p><p></p><p></p></td></tr><tr><td><p>[29].</p></td><td><h1></h1></td></tr></tbody></table></div>

|     |     |
| --- | --- |
| \[30\]. |     |

|     |     |
| --- | --- |
| \[31\]. |     |
| \[32\]. |     |
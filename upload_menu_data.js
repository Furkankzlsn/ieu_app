const admin = require('firebase-admin');

// Firebase Admin SDK'yı başlat - IEU_APP projesi için
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://ieu-app0-default-rtdb.firebaseio.com/"
});

const db = admin.database();

async function uploadCompleteMenuData() {
  try {
    console.log('Firebase\'e kapsamlı menü verisi yükleniyor...');
    
    // Kapsamlı menü verisi
    const completeMenuData = {
      universite: {
        rektorumuzden: {
          baslik: "Rektörümüzden",
          icerik: `<article><div class="rector-message"><h1>Rektörümüzden</h1><div class="rector-photo"><img src="https://www.ieu.edu.tr/images/tarihce/rektorden2.jpg" alt="Prof. Dr. Yusuf Hakan Abacıoğlu" style="width:200px;height:250px;object-fit:cover;border-radius:8px;"></div><div class="message-content"><h2>Prof. Dr. Yusuf Hakan ABACIOĞLU</h2><p><strong>İzmir Ekonomi Üniversitesi Rektörü</strong></p><p>Sevgili Gençler,</p><p>Kurduğunuz hayalleri, sizi başkalarından ayıran çok değerli yeteneklerinizi, bir an önce ulaşmak istediğiniz başarı dolu kariyer hedeflerinizi önemsiyor, yakından takip ediyoruz.</p><blockquote><p>Bizler; kendinizi keşfetmeniz için size yardımcı oluyor, heyecanınızı paylaşıyor, açık denizlere ulaşmanız noktasında size kılavuzluk ediyor, 23 yıllık tecrübemizle yeni kariyer rotaları oluşturuyoruz.</p></blockquote><h3>Eğitim Yaklaşımımız</h3><ul><li>🎓 Nitelikli akademisyen kadrosu</li><li>🔬 Araştırma odaklı eğitim</li><li>🌍 Uluslararası perspektif</li><li>💼 Sektörel iş birliği</li><li>🚀 Yenilik ve girişimcilik</li></ul><p>Bizim için üniversitemizde eğitim gören yaklaşık 11 bin öğrencimizin her biri, ülkemiz ve geleceğimiz için çok değerli birer proje.</p><h3>Öne Çıkan Projelerimiz</h3><p>🤝 <strong>Garantili Staj</strong> - İzmir Ticaret Odası desteğiyle</p><p>💰 <strong>Kesintisiz Burs</strong> - Başarılı öğrenciler için</p><p>🌐 <strong>Küresel Bağlantı</strong> - Uluslararası değişim programları</p><p>👥 <strong>Üç Kuşak Usta-Çırak</strong> - Sektör temsilcileriyle buluşma</p><p>İyi ki bizimlesiniz. İzmir Ekonomi Üniversitesi Ailesi'ne hoş geldiniz.</p><p>Sevgilerimle,</p><p><strong>Prof. Dr. Yusuf Hakan ABACIOĞLU</strong><br>Rektör</p></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/rektorumuzden",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        baskanimizdan: {
          baslik: "Başkanımızdan",
          icerik: `<article><div class="chairman-message"><h1>Yönetim Kurulu Başkanımızdan</h1><div class="chairman-photo"><img src="https://phoenix.ieu.edu.tr/images/tarihce/baskandan.jpg" alt="Mahmut Özgener" style="width:200px;height:250px;object-fit:cover;border-radius:8px;"></div><div class="message-content"><h2>Mahmut ÖZGENER</h2><p><strong>İzmir Ticaret Odası Yönetim Kurulu ve İzmir Ekonomi Üniversitesi Mütevelli Heyet Başkanı</strong></p><p>Sevgili Gençler,</p><p>Rekabetin her geçen gün arttığı, teknolojinin hızla geliştiği, bilginin sürekli yenilendiği bir çağdayız.</p><blockquote><p>Ülkemiz ve İzmir'in gelişmesi için en önemli değer olarak gördüğümüz sizleri; özgüveni yüksek, entelektüel, iyi derecede yabancı dil bilen, öğrendiğiyle yetinmeyip sürekli sorgulayan, her alanda farkını gösteren, donanımlı bireyler olarak yetiştiriyoruz.</p></blockquote><h3>Kampüsİzmir Modeli</h3><p>Size, üniversite-şehir bütünleşmesinde Türkiye'ye örnek olan <strong>Kampüsİzmir</strong> modelinden bahsetmek istiyorum:</p><ul><li>🏭 Yüksek teknoloji üsleri</li><li>🏢 Organize sanayi bölgeleri</li><li>📦 Lojistik merkezleri</li><li>🏭 Fabrikalar ve üretim tesisleri</li><li>🤝 İzmir'in üreten tüm aktörleri</li></ul><p>İzmir Ekonomi Üniversitesi diplomasının dünyanın her köşesinde size kapılar açacağını; <strong>100 bin üyesi bulunan İzmir Ticaret Odası'nın</strong> bütün gücünün de elinizin altında olduğunu unutmayın.</p><p>Sevgilerimle…</p><p><strong>Mahmut ÖZGENER</strong><br>İzmir Ticaret Odası Yönetim Kurulu ve<br>İzmir Ekonomi Üniversitesi Mütevelli Heyet Başkanı</p></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/baskanimizdan",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        misyonvevizyon: {
          baslik: "Misyon ve Vizyon",
          icerik: `<article><div class="mission-vision"><h1>Misyon ve Vizyonumuz</h1><div class="mission-section"><h2>🎯 MİSYONUMUZ</h2><p>Üniversitemiz; <strong>yenilikçi ve dönüştürücü eğitim, nitelikli bilgi üretimi ve güçlü toplumsal katkı faaliyetleriyle</strong> toplumun refahını artırmayı; sosyal, ekonomik ve çevresel sürdürülebilirliği desteklemeyi misyon edinmiştir.</p></div><div class="vision-section"><h2>🚀 VİZYONUMUZ</h2><p><strong>Sürdürülebilir yaşam için yaratıcı ve dönüştürücü çözümler üreten bir üniversite olmak</strong>tır.</p></div><div class="values-section"><h2>💎 KURUMUMUZUN TEMEL DEĞERLERİ</h2><div class="value-item"><h3>1. Akademik Özgürlük</h3><p>Akademik özgürlük, eleştirel düşünebilen bireylerin yetişmesi ve bilgi üretiminin sürdürülebilmesi için hayati öneme sahiptir.</p></div><div class="value-item"><h3>2. Hakkaniyet</h3><p>Üniversitemiz; cinsiyet, etnik köken, yaş, din, engellilik durumu ya da cinsel kimlik gözetmeksizin, <strong>tüm bireylere eşit fırsatlar sunmayı</strong> taahhüt eder.</p></div><div class="value-item"><h3>3. Güvenilirlik</h3><p>Bilginin, araştırmanın ve akademik süreçlerin güvenilirliği, üniversitemiz için önceliklidir.</p></div><div class="value-item"><h3>4. Hesap Verebilirlik ve Şeffaflık</h3><p>Üniversitemiz için iç ve dış paydaşlara karşı sorumlu olmak esastır.</p></div><div class="value-item"><h3>5. Yaratıcılık ve Yenilikçilik</h3><p>Yaratıcılık, özgün fikirlerin geliştirilmesini ve geleneksel sınırların ötesinde düşünmeyi teşvik eder.</p></div><div class="value-item"><h3>6. Sağlık, İyi Oluş ve Dayanışma</h3><p>Üniversitemiz; sağlık, refah ve duyarlı bir topluluğa öncelik verir.</p></div></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/misyon-ve-vizyon",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        tarihce: {
          baslik: "Tarihçe",
          icerik: `<article><div class="history"><h1>İzmir Ekonomi Üniversitesi Tarihçesi</h1><h2>2001 - Kuruluş</h2><p>İzmir Ekonomi Üniversitesi, <strong>İzmir Ticaret Odası Eğitim ve Sağlık Vakfı</strong> tarafından 2001 yılında kurulmuştur.</p><h2>2023 - 22. Yıl</h2><p>22 yıllık güç ve deneyimini toplumsal çalışmalara aktaran bir kurum haline gelmiştir.</p><h2>Günümüz</h2><ul><li>11.000+ aktif öğrenci</li><li>500+ mezun 50+ ülkede</li><li>AACSB akreditasyonu</li><li>Uluslararası tanınırlık</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/tarihce",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      akademik: {
        lisans_programlari: {
          baslik: "Lisans Programları",
          icerik: `<article><div class="programs"><h1>Lisans Programları</h1><h2>📊 İşletme Fakültesi</h2><ul><li>İşletme</li><li>Uluslararası İlişkiler</li><li>Siyaset Bilimi</li><li>Ekonomi</li></ul><h2>🔧 Mühendislik Fakültesi</h2><ul><li>Bilgisayar Mühendisliği</li><li>Endüstri Mühendisliği</li><li>Elektrik-Elektronik Mühendisliği</li><li>Makine Mühendisliği</li></ul><h2>🎨 Güzel Sanatlar ve Tasarım Fakültesi</h2><ul><li>Grafik Tasarım</li><li>Endüstriyel Tasarım</li><li>İç Mimarlık</li><li>Moda ve Tekstil Tasarımı</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/akademik/lisans",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        yuksek_lisans: {
          baslik: "Yüksek Lisans Programları",
          icerik: `<article><div class="graduate"><h1>Yüksek Lisans Programları</h1><h2>Tezli Yüksek Lisans</h2><ul><li>MBA (Master of Business Administration)</li><li>Bilgisayar Mühendisliği</li><li>Endüstri Mühendisliği</li><li>Uluslararası İlişkiler</li></ul><h2>Tezsiz Yüksek Lisans</h2><ul><li>İşletme</li><li>Proje Yönetimi</li><li>Dijital Pazarlama</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/akademik/yuksek-lisans",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        doktora: {
          baslik: "Doktora Programları",
          icerik: `<article><div class="phd"><h1>Doktora Programları</h1><ul><li>İşletme Doktora</li><li>Bilgisayar Mühendisliği Doktora</li><li>Endüstri Mühendisliği Doktora</li><li>Uluslararası İlişkiler Doktora</li></ul><h2>Araştırma Alanları</h2><ul><li>Yapay Zeka</li><li>Sürdürülebilirlik</li><li>Dijital Dönüşüm</li><li>Küresel Politika</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/akademik/doktora",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      arastirma: {
        arastirma_merkezleri: {
          baslik: "Araştırma Merkezleri",
          icerik: `<article><div class="research-centers"><h1>Araştırma Merkezleri</h1><h2>🔬 YAEM - Yaratıcı Ekonomi Araştırmaları Merkezi</h2><p>Şehrimizdeki ekonomik, kültürel ve ticari faaliyetlerin daha yüksek katma değer yaratması için bilimsel katkı vermektedir.</p><h2>🤖 Yapay Zeka Araştırma Merkezi</h2><p>Makine öğrenmesi, derin öğrenme ve yapay zeka uygulamaları üzerine araştırmalar yürütmektedir.</p><h2>🌱 Sürdürülebilirlik Araştırma Merkezi</h2><p>Çevresel ve sosyal sürdürülebilirlik projelerinde öncü rol almaktadır.</p></div></article>`,
          link: "https://www.ieu.edu.tr/tr/arastirma/merkezler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        projeler: {
          baslik: "Araştırma Projeleri",
          icerik: `<article><div class="projects"><h1>Araştırma Projeleri</h1><h2>🚀 TÜBİTAK Projeleri</h2><ul><li>Akıllı Üretim Sistemleri (7.5M TL)</li><li>Yapay Zeka Destekli Sağlık</li><li>Sürdürülebilir Enerji</li></ul><h2>🌍 AB Projeleri</h2><ul><li>Horizon Europe</li><li>Erasmus+ KA2</li><li>Digital Europe</li></ul><h2>🏭 Sanayi İşbirlikleri</h2><ul><li>AR-GE merkezleri</li><li>Teknoloji transfer</li><li>Patent çalışmaları</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/arastirma/projeler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      kampus: {
        kampus_yasami: {
          baslik: "Kampüs Yaşamı",
          icerik: `<article><div class="campus-life"><h1>Kampüs Yaşamı</h1><h2>🏠 Yurt ve Konaklama</h2><p>Modern yurt tesisleri ve güvenli konaklama imkanları.</p><h2>🍽️ Yemek ve Kafeterya</h2><p>Çeşitli yemek seçenekleri ve sosyal alanlar.</p><h2>🏃‍♂️ Spor Tesisleri</h2><ul><li>Fitness merkezi</li><li>Basketbol sahası</li><li>Tenis kortu</li><li>Yüzme havuzu</li></ul><h2>📚 Kütüphane</h2><p>24/7 çalışma imkanı, sessiz ve grup çalışma alanları.</p></div></article>`,
          link: "https://www.ieu.edu.tr/tr/kampus/yasam",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        ogrenci_kulupleri: {
          baslik: "Öğrenci Kulüpleri",
          icerik: `<article><div class="clubs"><h1>Öğrenci Kulüpleri</h1><h2>🎭 Kültür ve Sanat</h2><ul><li>Tiyatro Kulübü</li><li>Müzik Kulübü</li><li>Dans Kulübü</li><li>Fotoğrafçılık</li></ul><h2>🎯 Kariyer ve Akademik</h2><ul><li>IEEE Öğrenci Kolu</li><li>Girişimcilik Kulübü</li><li>Debate Kulübü</li><li>Model UN</li></ul><h2>⚽ Spor</h2><ul><li>Futbol Takımı</li><li>Basketbol</li><li>Voleybol</li><li>Yüzme</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/kampus/kulupler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      international: {
        degisim_programlari: {
          baslik: "Değişim Programları",
          icerik: `<article><div class="exchange"><h1>Uluslararası Değişim Programları</h1><h2>🇪🇺 Erasmus+</h2><p>50+ Avrupa üniversitesi ile değişim anlaşmaları.</p><h2>🌎 Küresel Partnerler</h2><ul><li>Amerika Birleşik Devletleri</li><li>Kanada</li><li>Avustralya</li><li>Güney Kore</li><li>Japonya</li></ul><h2>📋 Başvuru Şartları</h2><ul><li>Minimum 2.50 GPA</li><li>Yabancı dil yeterlilik</li><li>Motivasyon mektubu</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/international/exchange",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        uluslararasi_ogrenciler: {
          baslik: "Uluslararası Öğrenciler",
          icerik: `<article><div class="international-students"><h1>Uluslararası Öğrenciler</h1><h2>🌍 40+ Ülkeden Öğrenci</h2><p>Çok kültürlü kampüs ortamında eğitim.</p><h2>🏠 Destek Hizmetleri</h2><ul><li>Vize işlemleri desteği</li><li>Konaklama yardımı</li><li>Türkçe kursu</li><li>Kültürel oryantasyon</li></ul><h2>💰 Burs İmkanları</h2><ul><li>Akademik başarı bursu</li><li>Spor bursu</li><li>Kültürel aktivite bursu</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/international/students",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      iletisim: {
        iletisim_bilgileri: {
          baslik: "İletişim Bilgileri",
          icerik: `<article><div class="contact"><h1>İletişim Bilgileri</h1><h2>📍 Adres</h2><p><strong>İzmir Ekonomi Üniversitesi</strong><br>Sakarya Caddesi No: 156<br>35330 Balçova - İzmir / TÜRKİYE</p><h2>📞 Telefon</h2><ul><li>Santral: +90 232 488 9000</li><li>Öğrenci İşleri: +90 232 488 9100</li><li>Uluslararası Ofis: +90 232 488 9200</li></ul><h2>📧 E-posta</h2><ul><li>info@ieu.edu.tr</li><li>ogrenci@ieu.edu.tr</li><li>international@ieu.edu.tr</li></ul><h2>🕐 Çalışma Saatleri</h2><p>Pazartesi - Cuma: 08:30 - 17:30</p></div></article>`,
          link: "https://www.ieu.edu.tr/tr/iletisim",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        kampus_haritasi: {
          baslik: "Kampüs Haritası",
          icerik: `<article><div class="campus-map"><h1>Kampüs Haritası</h1><h2>🗺️ Ana Binalar</h2><ul><li>A Blok - İdari Binalar</li><li>B Blok - İşletme Fakültesi</li><li>C Blok - Mühendislik Fakültesi</li><li>D Blok - Güzel Sanatlar</li></ul><h2>🏢 Diğer Tesisler</h2><ul><li>Merkez Kütüphane</li><li>Spor Kompleksi</li><li>Yemekhane</li><li>Öğrenci Merkezi</li></ul><h2>🚌 Ulaşım</h2><ul><li>İzmir Metro - Üçyol İstasyonu</li><li>Kampüs servis hatları</li><li>Özel araç park alanları</li></ul></div></article>`,
          link: "https://www.ieu.edu.tr/tr/kampus-haritasi",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      }
    };
    
    // Firebase'e yükle
    const ref = db.ref('menuler');
    await ref.set(completeMenuData);
    
    console.log('✅ Kapsamlı menü verisi başarıyla Firebase\'e yüklendi!');
    console.log('Yüklenen kategoriler:');
    console.log('- Üniversite: 4 sayfa');
    console.log('- Akademik: 3 sayfa'); 
    console.log('- Araştırma: 2 sayfa');
    console.log('- Kampüs: 2 sayfa');
    console.log('- International: 2 sayfa');
    console.log('- İletişim: 2 sayfa');
    console.log('📝 Toplam: 15 içerik sayfası');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

uploadCompleteMenuData();

const admin = require('firebase-admin');

// Firebase Admin SDK'yı başlat - IEU_APP projesi için
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://ieu-app0-default-rtdb.firebaseio.com/"
});

const db = admin.database();

async function uploadRealIeuData() {
  try {
    console.log('Firebase\'e gerçek İEU verisi yükleniyor...');
    
    // Gerçek İEU haberlerini web sitesinden alınan verilerle doldur
    const realNewsData = {
      news: {
        "1": {
          id: "9956",
          baslik: "'Gen'lerinde Başarı Var",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ) Genetik ve Biyomühendislik Bölümü'nde eğitim gören gençler, başarılı çalışmalarıyla dünyaca ünlü üniversitelerin ilk tercihi oldu.",
          icerik: `<article><div class="news-content"><h1>'Gen'lerinde Başarı Var</h1><p>İzmir Ekonomi Üniversitesi (İEÜ) Genetik ve Biyomühendislik Bölümü'nde eğitim gören gençler, başarılı çalışmalarıyla dünyaca ünlü üniversitelerin ilk tercihi oldu.</p><p>Genetik ve Biyomühendislik alanında gerçekleştirdikleri çalışmalarla dikkat çeken öğrenciler, uluslararası düzeyde tanınırlık kazandı.</p><p>Bu başarı, İzmir Ekonomi Üniversitesi'nin bilimsel çalışmalardaki gücünü bir kez daha ortaya koyuyor.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/genetik-basari.jpg",
          kategori: "Akademik",
          yayinTarihi: "2025-01-28T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9956",
          skalar: ["4", "17"]
        },
        "2": {
          id: "9949",
          baslik: "Akıllı Üretim için Örnek Proje",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ) Elektrik-Elektronik Mühendisliği Bölümü Dr. Öğretim Üyesi Ayça Kumluca Topallı, TÜBİTAK'ın 7.5 milyon liralık desteğiyle hayata geçen 'Yapay zeka destekli akıllı üretim asistanı' projesinin paydaşı oldu.",
          icerik: `<article><div class="news-content"><h1>Akıllı Üretim için Örnek Proje</h1><p>İzmir Ekonomi Üniversitesi (İEÜ) Elektrik-Elektronik Mühendisliği Bölümü Dr. Öğretim Üyesi Ayça Kumluca Topallı, TÜBİTAK'ın 7.5 milyon liralık desteğiyle hayata geçen 'Yapay zeka destekli akıllı üretim asistanı' projesinin paydaşı oldu.</p><p>Proje kapsamında, yapay zeka teknolojileri kullanılarak üretim süreçlerinde verimliliği artırmayı hedefleyen yenilikçi çözümler geliştirilecek.</p><p>Bu proje, Türkiye'nin Endüstri 4.0 dönüşümüne katkı sağlayacak önemli adımlardan biri olacak.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/akilli-uretim.jpg",
          kategori: "Araştırma",
          yayinTarihi: "2025-01-27T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9949",
          skalar: ["4", "9", "11", "12", "17"]
        },
        "3": {
          id: "9941",
          baslik: "İtalya'ya 'Tasarım' Çıkarması",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ) Güzel Sanatlar ve Tasarım Fakültesi, İtalya'nın Matera kentinde düzenlenen 'Italian Design Agorà 2025' etkinliğinde Türkiye'yi başarıyla temsil etti.",
          icerik: `<article><div class="news-content"><h1>İtalya'ya 'Tasarım' Çıkarması</h1><p>İzmir Ekonomi Üniversitesi (İEÜ) Güzel Sanatlar ve Tasarım Fakültesi, İtalya'nın Matera kentinde düzenlenen 'Italian Design Agorà 2025' etkinliğinde Türkiye'yi başarıyla temsil etti.</p><p>Uluslararası tasarım arenasında İzmir Ekonomi Üniversitesi'nin adını duyuran bu etkinlik, öğrencilerin yaratıcılıklarını sergiledikleri önemli bir platform oldu.</p><p>Etkinlikte sergilenen projeler, İtalyan tasarım dünyasından büyük ilgi gördü.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/italya-tasarim.jpg",
          kategori: "Uluslararası",
          yayinTarihi: "2025-01-26T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9941",
          skalar: ["4", "9", "12", "17"]
        },
        "4": {
          id: "9939",
          baslik: "Eğitim Kalitesine 'YÖKAK' Tescili",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ), Yükseköğretim Kalite Kurulu (YÖKAK) tarafından eğitim-öğretim, toplumsal katkı, liderlik, yönetim sistemi ve araştırma gibi birçok alanda yapılan incelemeleri başarıyla geçerek 'tam akreditasyonun' sahibi oldu.",
          icerik: `<article><div class="news-content"><h1>Eğitim Kalitesine 'YÖKAK' Tescili</h1><p>İzmir Ekonomi Üniversitesi (İEÜ), Yükseköğretim Kalite Kurulu (YÖKAK) tarafından eğitim-öğretim, toplumsal katkı, liderlik, yönetim sistemi ve araştırma gibi birçok alanda yapılan incelemeleri başarıyla geçerek 'tam akreditasyonun' sahibi oldu.</p><p>Bu başarı, üniversitemizin eğitim kalitesinin uluslararası standartlarda olduğunu gösteren önemli bir kanıttır.</p><p>YÖKAK akreditasyonu, eğitim kurumlarının kalite güvencesi sistemlerinin değerlendirildiği kapsamlı bir süreçtir.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/yokak-akreditasyon.jpg",
          kategori: "Eğitim",
          yayinTarihi: "2025-01-25T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9939",
          skalar: ["4", "8", "10", "12", "16", "17"]
        },
        "5": {
          id: "9932",
          baslik: "Güney Kore'ye 'İzmir Ekonomi' İmzası",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ) İngilizce Mütercim ve Tercümanlık Bölümü'nden mezun olduktan sonra yüksek lisans için Güney Kore'yi tercih eden Aybüke Cihan (25), başarılarıyla yıldızlaştı.",
          icerik: `<article><div class="news-content"><h1>Güney Kore'ye 'İzmir Ekonomi' İmzası</h1><p>İzmir Ekonomi Üniversitesi (İEÜ) İngilizce Mütercim ve Tercümanlık Bölümü'nden mezun olduktan sonra yüksek lisans için Güney Kore'yi tercih eden Aybüke Cihan (25), başarılarıyla yıldızlaştı.</p><p>Güney Kore'de eğitimine devam eden mezunumuz, İzmir Ekonomi Üniversitesi'nin küresel başarı hikayelerinden birine imza attı.</p><p>Bu başarı, üniversitemizin uluslararası tanınırlığının ve mezunlarımızın kalitesinin göstergesidir.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/guney-kore.jpg",
          kategori: "Mezun Başarısı",
          yayinTarihi: "2025-01-24T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9932",
          skalar: ["4", "10", "12", "17"]
        },
        "6": {
          id: "9928",
          baslik: "İzmir Ekonomi'den Avrupa'ya",
          ozet: "İzmir Ekonomi Üniversitesi (İEÜ) İşletme Fakültesi Siyaset Bilimi ve Uluslararası İlişkiler Bölümü'nden bu yıl mezun olan Can Arıkan ve Cenker Karagöz, Avrupa Birliği tarafından sayılı gence verilen 'Jean Monnet' bursunu almaya hak kazandı.",
          icerik: `<article><div class="news-content"><h1>İzmir Ekonomi'den Avrupa'ya</h1><p>İzmir Ekonomi Üniversitesi (İEÜ) İşletme Fakültesi Siyaset Bilimi ve Uluslararası İlişkiler Bölümü'nden bu yıl mezun olan Can Arıkan ve Cenker Karagöz, Avrupa Birliği tarafından sayılı gence verilen 'Jean Monnet' bursunu almaya hak kazandı.</p><p>Jean Monnet bursu, Avrupa entegrasyonu konusunda çalışmak isteyen gençlere verilen prestijli bir destektir.</p><p>Bu başarı, üniversitemizin Avrupa Birliği ilişkilerindeki gücünü göstermektedir.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/avrupa-bursu.jpg",
          kategori: "Uluslararası",
          yayinTarihi: "2025-01-23T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9928",
          skalar: ["4", "8", "10", "17"]
        },
        "7": {
          id: "9933",
          baslik: "'Eğitimde Yapay Zekâ' Çalıştayı",
          ozet: "İzmir Ekonomi Üniversitesi, eğitim teknolojilerine yönelik dönüşüm vizyonu doğrultusunda önemli bir adım daha attı.",
          icerik: `<article><div class="news-content"><h1>'Eğitimde Yapay Zekâ' Çalıştayı</h1><p>İzmir Ekonomi Üniversitesi, eğitim teknolojilerine yönelik dönüşüm vizyonu doğrultusunda önemli bir adım daha attı.</p><p>Düzenlenen çalıştayda, yapay zeka teknolojilerinin eğitim alanındaki uygulamaları ve potansiyeli masaya yatırıldı.</p><p>Çalıştay, akademisyenler ve sektör temsilcilerinin bir araya geldiği verimli bir platform oldu.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/yapay-zeka.jpg",
          kategori: "Eğitim",
          yayinTarihi: "2025-01-22T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9933",
          skalar: ["3", "4", "8", "9"]
        },
        "8": {
          id: "9858",
          baslik: "İzmir Ekonomili Hukukçular Geleceği Belirliyor",
          ozet: "Bir kişinin yüzünü, sesini ya da hareketlerini taklit ederek sahte görüntü ve ses kayıtları üretmek için kullanılan yapay zeka destekli 'Deepfake' teknolojisi, 'kitaba' konu oldu.",
          icerik: `<article><div class="news-content"><h1>İzmir Ekonomili Hukukçular Geleceği Belirliyor</h1><p>Bir kişinin yüzünü, sesini ya da hareketlerini taklit ederek sahte görüntü ve ses kayıtları üretmek için kullanılan yapay zeka destekli 'Deepfake' teknolojisi, 'kitaba' konu oldu.</p><p>İzmir Ekonomi Üniversitesi Hukuk Fakültesi öğretim üyeleri, bu konuda öncü çalışmalar yürüterek hukuk literatürüne önemli katkılar sağlıyor.</p><p>Bu çalışma, teknolojinin hukuki boyutlarını ele alan kapsamlı bir araştırma niteliğinde.</p></div></article>`,
          resimUrl: "https://www.ieu.edu.tr/images/news/hukuk-deepfake.jpg",
          kategori: "Hukuk",
          yayinTarihi: "2025-01-21T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/news/type/read/id/9858",
          skalar: ["4", "10", "12", "16", "17"]
        }
      }
    };

    // Gerçek İEU duyurularını ekle
    const realAnnouncementsData = {
      announcements: {
        "1": {
          id: "13119",
          baslik: "2025-2026 Akademik yılı devam eden öğrenciler için öğretim ücretleri",
          ozet: "2025-2026 akademik yılı için devam eden öğrencilerin öğretim ücretleri açıklandı.",
          icerik: `<article><div class="announcement-content"><h1>2025-2026 Akademik Yılı Öğretim Ücretleri</h1><p>2025-2026 akademik yılı için devam eden öğrencilerin öğretim ücretleri belirlendi.</p><p>Detaylı bilgi için Öğrenci İşleri Müdürlüğü ile iletişime geçebilirsiniz.</p></div></article>`,
          kategori: "Akademik",
          yayinTarihi: "2025-07-25T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/announcements/type/read/id/13119",
          oncelik: "yuksek"
        },
        "2": {
          id: "13113",
          baslik: "Milli Sporcu Bursu, Sporcu İndirimi ve Kültür-Sanat İndirimi Başvuru Duyurusu",
          ozet: "Milli sporcu bursu, sporcu indirimi ve kültür-sanat indirimi başvuruları için güncellenmiş duyuru.",
          icerik: `<article><div class="announcement-content"><h1>Burs ve İndirim Başvuruları</h1><p>Milli sporcu bursu, sporcu indirimi ve kültür-sanat indirimi için başvurular alınmaktadır.</p><p>Başvuru şartları ve detaylar için ilgili birimler ile iletişime geçiniz.</p></div></article>`,
          kategori: "Burs",
          yayinTarihi: "2025-07-21T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/announcements/type/read/id/13113",
          oncelik: "orta"
        },
        "3": {
          id: "13109",
          baslik: "2025-2026 Öğretim Yılı Güz Dönemi Kurumlararası Yatay Geçiş Başvuruları",
          ozet: "2025-2026 öğretim yılı güz dönemi için kurumlararası yatay geçiş başvuruları güncellendi.",
          icerik: `<article><div class="announcement-content"><h1>Yatay Geçiş Başvuruları</h1><p>2025-2026 öğretim yılı güz dönemi için kurumlararası yatay geçiş başvuruları alınmaktadır.</p><p>Başvuru tarihleri ve gerekli belgeler için duyuru metnini inceleyiniz.</p></div></article>`,
          kategori: "Kayıt",
          yayinTarihi: "2025-07-11T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/announcements/type/read/id/13109",
          oncelik: "yuksek"
        },
        "4": {
          id: "13090",
          baslik: "Tekstil ve Moda Tasarımı Bölümü Dr. Öğretim Görevlisi Kadro Atama Sonuçları",
          ozet: "Tekstil ve Moda Tasarımı Bölümü Dr. Öğretim Görevlisi kadro atama sonuçları açıklandı.",
          icerik: `<article><div class="announcement-content"><h1>Kadro Atama Sonuçları</h1><p>Tekstil ve Moda Tasarımı Bölümü Dr. Öğretim Görevlisi kadro atama sonuçları ilan edilmiştir.</p><p>Sonuçlar için ilgili bölüm sekreterliği ile iletişime geçebilirsiniz.</p></div></article>`,
          kategori: "Personel",
          yayinTarihi: "2025-06-20T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/announcements/type/read/id/13090",
          oncelik: "dusuk"
        },
        "5": {
          id: "12902",
          baslik: "10-16 Şubat Haftası Ortak Dersler Bölümü Ders İşleyişi",
          ozet: "10-16 Şubat haftası için Ortak Dersler Bölümü ders işleyişi hakkında duyuru.",
          icerik: `<article><div class="announcement-content"><h1>Ders İşleyişi Duyurusu</h1><p>10-16 Şubat haftası için Ortak Dersler Bölümü ders işleyişi hakkında önemli bilgiler.</p><p>Ders programı değişiklikleri ve güncel durumlar için duyuru metnini inceleyiniz.</p></div></article>`,
          kategori: "Akademik",
          yayinTarihi: "2025-02-10T10:00:00Z",
          link: "https://www.ieu.edu.tr/tr/announcements/type/read/id/12902",
          oncelik: "orta"
        }
      }
    };

    // Slider verilerini gerçek verilerle güncelle
    const realSliderData = {
      slider: {
        "1": {
          baslik: "Küresel Kariyer Yolculuğunda Tüm Gücümüzle Yanınızdayız!",
          aciklama: "İzmir Ekonomi Üniversitesi olarak öğrencilerimizin küresel kariyerlerinde onlara rehberlik ediyoruz.",
          resimUrl: "https://www.ieu.edu.tr/images/slider/kuresel-kariyer.jpg",
          link: "https://youtu.be/HJNJvJrLFTI",
          aktif: true,
          sira: 1
        },
        "2": {
          baslik: "Türkiye'nin Seçkin Akademisyenleri İzmir Ekonomi'de",
          aciklama: "Alanında uzman, deneyimli akademisyen kadromuzla nitelikli eğitim sunuyoruz.",
          resimUrl: "https://www.ieu.edu.tr/images/slider/akademisyenler.jpg",
          link: "https://youtu.be/Vq9Gvh2nIDw",
          aktif: true,
          sira: 2
        },
        "3": {
          baslik: "İzmir Ekonomili'yiz Dünya'nın Her Yerindeyiz",
          aciklama: "Mezunlarımız dünya çapında başarılarıyla İzmir Ekonomi Üniversitesi'ni temsil ediyor.",
          resimUrl: "https://www.ieu.edu.tr/images/slider/dunya-geneli.jpg",  
          link: "https://youtu.be/qKpcg0n7OmY",
          aktif: true,
          sira: 3
        },
        "4": {
          baslik: "İzmir Ekonomi Üniversitesi - Tanıtım",
          aciklama: "Üniversitemizi daha yakından tanıyın, öğrenci yaşamımızı keşfedin.",
          resimUrl: "https://www.ieu.edu.tr/images/slider/tanitim.jpg",
          link: "https://youtu.be/I4rjisLnokY", 
          aktif: true,
          sira: 4
        }
      }
    };

    // Menü verilerini güncel İEU web sitesi yapısıyla güncelle
    const realMenuData = {
      menu: {
        universite: {
          baslik: "Üniversite",
          ikon: "school",
          altKategoriler: {
            rektorumuzden: {
              baslik: "Rektörümüzden",
              icerik: `<article><div class="rector-message"><h1>Rektörümüzden</h1><p>Sevgili Gençler,</p><p>Kurduğunuz hayalleri, sizi başkalarından ayıran çok değerli yeteneklerinizi, bir an önce ulaşmak istediğiniz başarı dolu kariyer hedeflerinizi önemsiyor, yakından takip ediyoruz.</p><p>Bizler; kendinizi keşfetmeniz için size yardımcı oluyor, heyecanınızı paylaşıyor, açık denizlere ulaşmanız noktasında size kılavuzluk ediyor, 23 yıllık tecrübemizle yeni kariyer rotaları oluşturuyoruz.</p><p>Prof. Dr. Yusuf Hakan ABACIOĞLU<br>Rektör</p></div></article>`,
              link: "https://www.ieu.edu.tr/tr/rektorumuzden"
            },
            tarihce: {
              baslik: "Tarihçe",
              icerik: `<article><h1>İzmir Ekonomi Üniversitesi Tarihçesi</h1><p>İzmir Ekonomi Üniversitesi, 14 Nisan 2001 tarih ve 24373 sayılı Resmi Gazete'de yayınlanan 4633 sayılı kanun ile 2 fakülte, 5 yüksekokul, 2 enstitü olarak kuruldu.</p><p>288 öğrenci ile eğitim serüvenine başlayan, Ege Bölgesi'nin ilk vakıf üniversitesi olma özelliğini de taşıyan İzmir Ekonomi Üniversitesi, bugün 8 fakülte, 2 yüksekokul, 3 meslek yüksekokulu ve lisansüstü eğitim enstitüsü ile gelişimini sürdürüyor.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/tarihce"
            },
            misyonvizyon: {
              baslik: "Misyon ve Vizyon",
              icerik: `<article><h1>Misyon ve Vizyonumuz</h1><h2>Misyonumuz</h2><p>Üniversitemiz; yenilikçi ve dönüştürücü eğitim, nitelikli bilgi üretimi ve güçlü toplumsal katkı faaliyetleriyle toplumun refahını artırmayı misyon edinmiştir.</p><h2>Vizyonumuz</h2><p>Sürdürülebilir yaşam için yaratıcı ve dönüştürücü çözümler üreten bir üniversite olmaktır.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/misyon-vizyon"
            }
          }
        },
        akademik: {
          baslik: "Akademik",
          ikon: "book",
          altKategoriler: {
            lisans: {
              baslik: "Lisans Programları",
              icerik: `<article><h1>Lisans Programları</h1><h2>İşletme Fakültesi</h2><ul><li>İşletme</li><li>Ekonomi</li><li>Uluslararası İlişkiler</li><li>Siyaset Bilimi</li></ul><h2>Mühendislik Fakültesi</h2><ul><li>Bilgisayar Mühendisliği</li><li>Endüstri Mühendisliği</li><li>Elektrik-Elektronik Mühendisliği</li></ul></article>`,
              link: "https://www.ieu.edu.tr/tr/lisans-programlari"
            },
            yukseklisans: {
              baslik: "Yüksek Lisans Programları", 
              icerik: `<article><h1>Yüksek Lisans Programları</h1><p>İzmir Ekonomi Üniversitesi'nde çeşitli alanlarda yüksek lisans programları sunulmaktadır.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/yukseklisans-programlari"
            },
            doktora: {
              baslik: "Doktora Programları",
              icerik: `<article><h1>Doktora Programları</h1><p>Araştırma odaklı doktora programlarımızla akademik kariyerinizi şekillendirin.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/doktora-programlari"
            }
          }
        },
        arastirma: {
          baslik: "Araştırma",
          ikon: "science",
          altKategoriler: {
            projeler: {
              baslik: "Araştırma Projeleri",
              icerik: `<article><h1>Araştırma Projeleri</h1><p>Üniversitemizde yürütülen araştırma projeleri hakkında bilgi edinin.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/arastirma-projeleri"
            },
            merkezler: {
              baslik: "Araştırma Merkezleri",
              icerik: `<article><h1>Araştırma Merkezleri</h1><p>Üniversitemizdeki araştırma merkezleri ve faaliyetleri.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/arastirma-merkezleri"
            }
          }
        },
        kampus: {
          baslik: "Kampüs",
          ikon: "location_city",
          altKategoriler: {
            yasam: {
              baslik: "Kampüs Yaşamı",
              icerik: `<article><h1>Kampüs Yaşamı</h1><p>İzmir Ekonomi Üniversitesi kampüsünde öğrenci yaşamı ve sosyal aktiviteler.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/kampus-yasami"
            },
            tesisler: {
              baslik: "Kampüs Tesisleri",
              icerik: `<article><h1>Kampüs Tesisleri</h1><p>Modern tesislerimiz ve imkanlarımız hakkında bilgi edinin.</p></article>`,
              link: "https://www.ieu.edu.tr/tr/kampus-tesisleri"
            }
          }
        }
      }
    };

    // Tüm verileri Firebase'e yükle
    await db.ref('/').update({
      ...realNewsData,
      ...realAnnouncementsData,
      ...realSliderData,
      ...realMenuData
    });

    console.log('✅ Gerçek İEU verisi başarıyla Firebase\'e yüklendi!');
    console.log('📊 Yüklenen veriler:');
    console.log(`   - ${Object.keys(realNewsData.news).length} haber`);
    console.log(`   - ${Object.keys(realAnnouncementsData.announcements).length} duyuru`);
    console.log(`   - ${Object.keys(realSliderData.slider).length} slider`);
    console.log(`   - ${Object.keys(realMenuData.menu).length} menü kategorisi`);

  } catch (error) {
    console.error('❌ Hata:', error);
  } finally {
    process.exit(0);
  }
}

// Scripti çalıştır
uploadRealIeuData();

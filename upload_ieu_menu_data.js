const admin = require('firebase-admin');
const fs = require('fs');

// Firebase Admin SDK'yı başlat
const serviceAccount = require('../Gerekenler/ieu-app0-firebase-adminsdk-fbsvc-3459cd2494.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://ieu-app0-default-rtdb.firebaseio.com'
});

const db = admin.database();

// İEU Gerçek Menü Yapısı
const ieuMenuData = {
  universite: {
    baskanimizdan: {
      baslik: "Başkanımızdan",
      link: "https://www.ieu.edu.tr/tr/baskanimizdan",
      sira: 1
    },
    rektorumuzden: {
      baslik: "Rektörümüzden", 
      link: "https://www.ieu.edu.tr/tr/rektorumuzden",
      sira: 2
    },
    tarihce: {
      baslik: "Tarihçe",
      link: "https://www.ieu.edu.tr/tr/tarihce", 
      sira: 3
    },
    mutevelli_heyeti: {
      baslik: "Mütevelli Heyeti",
      link: "https://www.ieu.edu.tr/tr/mutevelli-heyeti",
      sira: 4
    },
    idari_birimler: {
      baslik: "İdari Birimler",
      link: "https://www.ieu.edu.tr/tr/idari-birimler",
      sira: 5
    },
    rektorluk: {
      baslik: "Rektörlük",
      link: "https://www.ieu.edu.tr/tr/rektorluk",
      sira: 6
    },
    misyon_vizyon: {
      baslik: "Misyon ve Vizyon",
      link: "https://www.ieu.edu.tr/tr/misyon-ve-vizyon",
      sira: 7
    },
    burslar: {
      baslik: "Burslar",
      link: "https://www.ieu.edu.tr/tercih/tr/burslar.php",
      sira: 8
    },
    is_birligi: {
      baslik: "İş Birliği",
      link: "https://www.ieu.edu.tr/tr/is-birligi",
      sira: 9
    },
    kalite_yapilanmasi: {
      baslik: "İEÜ'de Kalite Yapılanması",
      link: "https://kalite.ieu.edu.tr/tr",
      sira: 10
    },
    yonetmelik_yonerge: {
      baslik: "Yönetmelik / Yönerge",
      link: "https://www.ieu.edu.tr/tr/bylaws/type/all",
      sira: 11
    },
    odullerimiz: {
      baslik: "Ödüllerimiz",
      link: "https://www.ieu.edu.tr/tr/odullerimiz",
      sira: 12
    },
    kisisel_verilerin_korunmasi: {
      baslik: "Kişisel Verilerin Korunması",
      link: "https://www.ieu.edu.tr/tr/kisisel-verilerin-korunmasi",
      sira: 13
    },
    cinsiyet_esitligi: {
      baslik: "Toplumsal Cinsiyet Eşitliği Planı",
      link: "https://www.ieu.edu.tr/tr/toplumsal-cinsiyet-esitligi-plani-2022-2025",
      sira: 14
    },
    ilke_politikalar: {
      baslik: "İlke ve Politikalarımız",
      link: "https://www.ieu.edu.tr/tr/ilke-ve-politikalarimiz",
      sira: 15
    }
  },

  akademik: {
    yuksekokul_genel: {
      baslik: "Yüksekokullar",
      aciklama: "Meslek Yüksekokulları ve programları",
      link: "https://www.ieu.edu.tr/tr/akademik/yuksekokul",
      sira: 1
    },
    adalet_meslek: {
      baslik: "Adalet Meslek Yüksekokulu",
      link: "https://adl.ieu.edu.tr",
      sira: 2
    },
    meslek_yuksekokulu: {
      baslik: "Meslek Yüksekokulu", 
      link: "https://vs.ieu.edu.tr/tr",
      sira: 3
    },
    saglik_hizmetleri: {
      baslik: "Sağlık Hizmetleri Meslek Yüksekokulu",
      link: "https://shs.ieu.edu.tr/tr",
      sira: 4
    },
    uygulamali_yonetim: {
      baslik: "Uygulamalı Yönetim Bilimleri Yüksekokulu",
      link: "https://sams.ieu.edu.tr/tr",
      sira: 5
    },
    yabanci_diller: {
      baslik: "Yabancı Diller Yüksekokulu",
      link: "https://sfl.ieu.edu.tr/tr",
      sira: 6
    },
    fen_edebiyat: {
      baslik: "Fen-Edebiyat Fakültesi",
      link: "https://fas.ieu.edu.tr/tr",
      sira: 7
    },
    guzel_sanatlar: {
      baslik: "Güzel Sanatlar ve Tasarım Fakültesi",
      link: "https://fadf.ieu.edu.tr/tr",
      sira: 8
    },
    hukuk: {
      baslik: "Hukuk Fakültesi",
      link: "https://law.ieu.edu.tr/tr",
      sira: 9
    },
    iletisim: {
      baslik: "İletişim Fakültesi",
      link: "https://fc.ieu.edu.tr/tr",
      sira: 10
    },
    isletme: {
      baslik: "İşletme Fakültesi",
      link: "https://isl.ieu.edu.tr/tr",
      sira: 11
    },
    muhendislik: {
      baslik: "Mühendislik Fakültesi",
      link: "https://fecs.ieu.edu.tr/tr",
      sira: 12
    },
    saglik_bilimleri: {
      baslik: "Sağlık Bilimleri Fakültesi",
      link: "https://fhs.ieu.edu.tr/tr",
      sira: 13
    },
    tip: {
      baslik: "Tıp Fakültesi",
      link: "https://tip.ieu.edu.tr",
      sira: 14
    },
    lisansustu: {
      baslik: "Lisansüstü Eğitim Enstitüsü",
      link: "https://lisansustu.ieu.edu.tr/tr",
      sira: 15
    },
    ortak_dersler: {
      baslik: "Ortak Dersler",
      link: "https://ortakdersler.ieu.edu.tr/tr",
      sira: 16
    }
  },

  arastirma: {
    arastirma_merkezleri: {
      baslik: "Araştırma Merkezleri",
      link: "https://www.ieu.edu.tr/tr/arastirma-merkezleri",
      sira: 1
    },
    kutuphane: {
      baslik: "Kütüphane",
      link: "https://kutuphane.ieu.edu.tr/tr",
      sira: 2
    },
    akilli_kampus: {
      baslik: "Akıllı Kampüs",
      link: "https://ieu.edu.tr/tlc/tr/akilli-kampus-hakkinda",
      sira: 3
    },
    proje_gelistirme: {
      baslik: "Proje Geliştirme ve Teknoloji Transfer Ofisi",
      link: "https://ieutto.izmirekonomi.edu.tr/",
      sira: 4
    },
    izmir_bilimpark: {
      baslik: "İzmir Bilimpark",
      link: "https://izmirbilimpark.com.tr/",
      sira: 5
    },
    ekosem: {
      baslik: "Sürekli Eğitim Merkezi (EKOSEM)",
      link: "https://ekosem.ieu.edu.tr/tr/",
      sira: 6
    },
    cocuk_universitesi: {
      baslik: "Çocuk Üniversitesi",
      link: "https://cocukuniversitesi.ieu.edu.tr/",
      sira: 7
    },
    arastirmaci_egitimleri: {
      baslik: "Araştırmacı Eğitimleri Koordinatörlüğü",
      link: "https://www.ieu.edu.tr/tr/arastirmaci-egitimleri-koordinatorlugu",
      sira: 8
    },
    etik_kurul: {
      baslik: "Etik Kurul",
      link: "https://etikkurul.ieu.edu.tr/tr",
      sira: 9
    },
    ogretme_ogrenme: {
      baslik: "Öğretme ve Öğrenme Merkezi (EKOEĞİTİM)",
      link: "https://www.ieu.edu.tr/tlc/tr",
      sira: 10
    },
    puam: {
      baslik: "Psikolojik Uygulama ve Araştırma Merkezi (PUAM)",
      link: "https://puam.ieu.edu.tr/tr",
      sira: 11
    },
    arastirma_is_birlikleri: {
      baslik: "Araştırma İş Birlikleri ve İnovasyon Koordinatörlüğü",
      link: "https://www.ieu.edu.tr/tr/arastirma-birlikleri-ve-inovasyon-koordinatorlugu",
      sira: 12
    }
  },

  kampus: {
    ieude_hayat: {
      baslik: "İEÜ'de Hayat",
      link: "https://www.ieu.edu.tr/tr/ieude-hayat",
      sira: 1
    },
    izmir: {
      baslik: "İzmir",
      link: "https://www.ieu.edu.tr/tr/izmir",
      sira: 2
    },
    kutuphane: {
      baslik: "Kütüphane",
      link: "https://kutuphane.ieu.edu.tr/tr",
      sira: 3
    },
    yurtlar: {
      baslik: "Yurtlar ve Barınma",
      link: "https://yurt.ieu.edu.tr/tr",
      sira: 4
    },
    kafe_restoran: {
      baslik: "Kafe ve Restoran",
      link: "https://www.ieu.edu.tr/tr/kafe-ve-restoran",
      sira: 5
    },
    ogrenci_kulupleri: {
      baslik: "Öğrenci Kulüpleri",
      link: "https://club.ieu.edu.tr/",
      sira: 6
    },
    ieu_yayinevi: {
      baslik: "İEÜ Yayınevi",
      link: "https://yayin.ieu.edu.tr/tr",
      sira: 7
    },
    engelli_destek: {
      baslik: "Engelli Destek Birimi",
      link: "https://engelsiz.ieu.edu.tr/",
      sira: 8
    },
    saglik_psikolojik: {
      baslik: "Sağlık ve Psikolojik Danışma",
      link: "https://www.ieu.edu.tr/tr/saglik-ve-psikolojik-danisma",
      sira: 9
    }
  },

  international: {
    ana_sayfa: {
      baslik: "International",
      link: "https://www.ieu.edu.tr/international/en",
      sira: 1
    }
  },

  iletisim: {
    iletisim_bilgileri: {
      baslik: "İletişim",
      link: "https://www.ieu.edu.tr/tr/iletisim",
      sira: 1
    }
  }
};

async function uploadMenuData() {
  try {
    console.log('🔄 İEU menü verileri Firebase\'e yükleniyor...');
    
    // Mevcut menuler node'unu sil
    await db.ref('menuler').remove();
    
    // Yeni veriyi yükle
    await db.ref('menuler').set(ieuMenuData);
    
    console.log('✅ İEU menü verileri başarıyla yüklendi!');
    
    // Veri kontrolü
    const snapshot = await db.ref('menuler').once('value');
    const data = snapshot.val();
    
    console.log('📊 Yüklenen kategoriler:');
    Object.keys(data).forEach(category => {
      const items = Object.keys(data[category]).length;
      console.log(`   - ${category}: ${items} öğe`);
    });
    
  } catch (error) {
    console.error('❌ Yükleme hatası:', error);
  } finally {
    process.exit(0);
  }
}

uploadMenuData();

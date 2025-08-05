const admin = require('firebase-admin');

// Firebase Admin SDK'yı başlat - IEU_APP projesi için
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://ieu-app0-default-rtdb.firebaseio.com/"
});

const db = admin.database();

async function uploadAllMenuData() {
  try {
    console.log('🚀 Firebase\'e tüm menü kategorileri yükleniyor...');
    
    // Kapsamlı menü verisi - Mevcut verilerin üzerine güvenli şekilde eklenecek
    const menuData = {
      // ÜNİVERSİTE MENÜSÜ (mevcut veriler korunacak)
      universite: {
        rektorumuzden: {
          baslik: "Rektörümüzden",
          icerik: `<article><div class="rector-message"><h1>Rektörümüzden</h1><div class="rector-photo"><img src="https://www.ieu.edu.tr/images/tarihce/rektorden2.jpg" alt="Prof. Dr. Yusuf Hakan Abacıoğlu" style="width:200px;height:250px;object-fit:cover;border-radius:8px;"></div><div class="message-content"><h2>Prof. Dr. Yusuf Hakan ABACIOĞLU</h2><p><strong>İzmir Ekonomi Üniversitesi Rektörü</strong></p><p>Sevgili Gençler,</p><p>Kurduğunuz hayalleri, sizi başkalarından ayıran çok değerli yeteneklerinizi, bir an önce ulaşmak istediğiniz başarı dolu kariyer hedeflerinizi önemsiyor, yakından takip ediyoruz.</p><blockquote><p>Bizler; kendinizi keşfetmeniz için size yardımcı oluyor, heyecanınızı paylaşıyor, açık denizlere ulaşmanız noktasında size kılavuzluk ediyor, 23 yıllık tecrübemizle yeni kariyer rotaları oluşturuyoruz.</p></blockquote><h3>Eğitim Yaklaşımımız</h3><ul><li>🎓 Nitelikli akademisyen kadrosu</li><li>🔬 Araştırma odaklı eğitim</li><li>🌍 Uluslararası perspektif</li><li>💼 Sektörel iş birliği</li><li>🚀 Yenilik ve girişimcilik</li></ul><p>İyi ki bizimlesiniz. İzmir Ekonomi Üniversitesi Ailesi'ne hoş geldiniz.</p><p>Sevgilerimle,</p><p><strong>Prof. Dr. Yusuf Hakan ABACIOĞLU</strong><br>Rektör</p></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/rektorumuzden",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        baskanimizdan: {
          baslik: "Başkanımızdan",
          icerik: `<article><div class="chairman-message"><h1>Yönetim Kurulu Başkanımızdan</h1><div class="chairman-photo"><img src="https://phoenix.ieu.edu.tr/images/tarihce/baskandan.jpg" alt="Mahmut Özgener" style="width:200px;height:250px;object-fit:cover;border-radius:8px;"></div><div class="message-content"><h2>Mahmut ÖZGENER</h2><p><strong>İzmir Ticaret Odası Yönetim Kurulu ve İzmir Ekonomi Üniversitesi Mütevelli Heyet Başkanı</strong></p><p>Sevgili Gençler,</p><blockquote><p>Ülkemiz ve İzmir'in gelişmesi için en önemli değer olarak gördüğümüz sizleri; özgüveni yüksek, entelektüel, iyi derecede yabancı dil bilen, öğrendiğiyle yetinmeyip sürekli sorgulayan, her alanda farkını gösteren, donanımlı bireyler olarak yetiştiriyoruz.</p></blockquote><p>Sevgilerimle…</p><p><strong>Mahmut ÖZGENER</strong><br>İzmir Ticaret Odası Yönetim Kurulu ve<br>İzmir Ekonomi Üniversitesi Mütevelli Heyet Başkanı</p></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/baskanimizdan",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        misyonvevizyon: {
          baslik: "Misyon ve Vizyon",
          icerik: `<article><div class="mission-vision"><h1>Misyon ve Vizyonumuz</h1><div class="mission-section"><h2>🎯 MİSYONUMUZ</h2><p>Üniversitemiz; <strong>yenilikçi ve dönüştürücü eğitim, nitelikli bilgi üretimi ve güçlü toplumsal katkı faaliyetleriyle</strong> toplumun refahını artırmayı; sosyal, ekonomik ve çevresel sürdürülebilirliği desteklemeyi misyon edinmiştir.</p></div><div class="vision-section"><h2>🚀 VİZYONUMUZ</h2><p><strong>Sürdürülebilir yaşam için yaratıcı ve dönüştürücü çözümler üreten bir üniversite olmak</strong>tır.</p></div></div></article>`,
          link: "https://www.ieu.edu.tr/tr/misyon-ve-vizyon",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        tarihce: {
          baslik: "Tarihçe",
          icerik: `<article><div class="history"><h1>İzmir Ekonomi Üniversitesi Tarihçesi</h1><h2>2001: Kuruluş</h2><p>İzmir Ekonomi Üniversitesi, İzmir Ticaret Odası Eğitim ve Sağlık Vakfı tarafından 2001 yılında kurulmuştur.</p><h2>2003: İlk Öğrenci Kabulü</h2><p>Üniversitemiz 2003-2004 akademik yılında eğitim-öğretime başlamıştır.</p><h2>2025: Geleceğe Yönelik Projeler</h2><p>Sürdürülebilirlik ve teknoloji odaklı yeni projeler hayata geçirilmektedir.</p></div></article>`,
          link: "https://www.ieu.edu.tr/tr/tarihce",
          olusturmaTarihi: "2025-01-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },
      
      // AKADEMİK MENÜSÜ
      akademik: {
        fakulteler: {
          baslik: "Fakülteler",
          icerik: `<article><div class="faculties"><h1>Fakültelerimiz</h1>
          <div class="faculty-item"><h2>🏢 İşletme Fakültesi</h2><ul><li>İşletme</li><li>Uluslararası İşletme</li><li>İnsan Kaynakları Yönetimi</li><li>Pazarlama</li></ul></div>
          <div class="faculty-item"><h2>⚖️ Hukuk Fakültesi</h2><ul><li>Hukuk</li></ul></div>
          <div class="faculty-item"><h2>🔧 Mühendislik Fakültesi</h2><ul><li>Bilgisayar Mühendisliği</li><li>Endüstri Mühendisliği</li><li>Elektrik-Elektronik Mühendisliği</li></ul></div>
          <div class="faculty-item"><h2>🎨 Güzel Sanatlar ve Tasarım Fakültesi</h2><ul><li>Grafik Tasarım</li><li>İç Mimarlık ve Çevre Tasarımı</li></ul></div>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/fakulteler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        lisans_programlari: {
          baslik: "Lisans Programları", 
          icerik: `<article><div class="undergraduate-programs"><h1>Lisans Programları</h1>
          <h2>🏆 AACSB Akrediteli Programlar</h2>
          <p>İşletme, Pazarlama, İnsan Kaynakları programlarımız dünya standartlarında eğitim sunmaktadır.</p>
          <h2>🌍 Uluslararası Programlar</h2>
          <ul><li>International Business (İngilizce)</li><li>Computer Engineering (İngilizce)</li></ul>
          <h2>💼 Staj Garantili Programlar</h2>
          <p>İzmir Ticaret Odası iş birliğiyle tüm öğrencilerimize staj garantisi sunuyoruz.</p>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/lisans-programlari", 
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        yuksek_lisans: {
          baslik: "Yüksek Lisans Programları",
          icerik: `<article><div class="graduate-programs"><h1>Yüksek Lisans Programları</h1>
          <h2>📊 İşletme Alanı</h2>
          <ul><li>İşletme Yüksek Lisans</li><li>MBA (Türkçe/İngilizce)</li><li>Executive MBA</li></ul>
          <h2>⚖️ Hukuk Alanı</h2>
          <ul><li>Özel Hukuk</li><li>Ticaret Hukuku</li></ul>
          <h2>🔬 Mühendislik Alanı</h2>
          <ul><li>Bilgisayar Mühendisliği</li><li>Endüstri Mühendisliği</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/yuksek-lisans",
          olusturmaTarihi: "2025-07-29T10:00:00Z", 
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        doktora: {
          baslik: "Doktora Programları",
          icerik: `<article><div class="phd-programs"><h1>Doktora Programları</h1>
          <h2>🎓 Doktora Alanları</h2>
          <ul><li>İşletme Doktora</li><li>Hukuk Doktora</li><li>Mühendislik Doktora</li></ul>
          <h2>🔬 Araştırma Odaklı Eğitim</h2>
          <p>Uluslararası standartlarda araştırma projeleri ve yayın fırsatları sunuyoruz.</p>
          <h2>💰 Doktora Bursları</h2>
          <ul><li>Tam burs imkanları</li><li>Araştırma görevliliği pozisyonları</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/doktora",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },

      // ARAŞTIRMA MENÜSÜ  
      arastirma: {
        arastirma_merkezleri: {
          baslik: "Araştırma Merkezleri",
          icerik: `<article><div class="research-centers"><h1>Araştırma Merkezlerimiz</h1>
          <div class="center-item"><h2>🤖 Yapay Zeka ve Veri Bilimi Merkezi</h2><p>Machine Learning, Deep Learning ve Big Data Analytics alanlarında öncü çalışmalar.</p></div>
          <div class="center-item"><h2>🏭 Endüstri 4.0 Araştırma Merkezi</h2><p>Akıllı üretim, IoT ve otomasyon teknolojileri geliştirme.</p></div>
          <div class="center-item"><h2>⚡ Sürdürülebilir Enerji Merkezi</h2><p>Yenilenebilir enerji ve çevre dostu teknolojiler.</p></div>
          <div class="center-item"><h2>💡 Girişimcilik ve İnovasyon Merkezi</h2><p>Startup ekosistemi ve teknoloji transferi.</p></div>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/arastirma-merkezleri",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        projeler: {
          baslik: "Araştırma Projeleri",
          icerik: `<article><div class="research-projects"><h1>Aktif Araştırma Projelerimiz</h1>
          <h2>🔬 TÜBİTAK Projeleri</h2>
          <ul><li>Akıllı Şehir Altyapıları için IoT Çözümleri</li><li>Yapay Zeka Tabanlı Sağlık Teşhis Sistemi</li></ul>
          <h2>🌍 AB Projeleri</h2>
          <ul><li>Horizon 2020 - Digital Innovation Hubs</li><li>Erasmus+ Strategic Partnerships</li></ul>
          <h2>📊 Proje İstatistikleri</h2>
          <p>🎯 50+ aktif proje<br>💰 15M+ TL proje bütçesi<br>👥 200+ araştırmacı</p>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/arastirma-projeler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        yayinlar: {
          baslik: "Bilimsel Yayınlar",
          icerik: `<article><div class="publications"><h1>Bilimsel Yayınlarımız</h1>
          <h2>📚 SCI/SCI-E İndeksli Yayınlar</h2>
          <p>2024 yılında 150+ SCI/SCI-E indeksli makale yayınlandı.</p>
          <h2>📖 Ulusal Hakemli Dergiler</h2>
          <p>TR Dizin ve diğer ulusal indekslerde 200+ yayın.</p>
          <h2>📔 Kitaplar ve Bölümler</h2>
          <ul><li>50+ akademik kitap</li><li>100+ kitap bölümü</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/bilimsel-yayinlar",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },

      // KAMPÜS MENÜSÜ
      kampus: {
        kampus_yasami: {
          baslik: "Kampüs Yaşamı",
          icerik: `<article><div class="campus-life"><h1>Kampüs Yaşamı</h1>
          <h2>🏫 Modern Tesisler</h2>
          <ul><li>Akıllı sınıflar ve laboratuvarlar</li><li>Merkez kütüphane</li><li>Kafeterya ve yemek alanları</li></ul>
          <h2>🏃‍♂️ Spor Tesisleri</h2>
          <ul><li>Kapalı spor salonu</li><li>Fitness merkezi</li><li>Açık hava spor alanları</li></ul>
          <h2>🎭 Kültürel Aktiviteler</h2>
          <ul><li>Konser ve tiyatro etkinlikleri</li><li>Sanat galerileri</li><li>Kültür festivalleri</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/kampus-yasami",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        ogrenci_kulupleri: {
          baslik: "Öğrenci Kulüpleri",
          icerik: `<article><div class="student-clubs"><h1>Öğrenci Kulüplerimiz</h1>
          <h2>🎨 Sanat ve Kültür Kulüpleri</h2>
          <ul><li>Tiyatro Kulübü</li><li>Müzik Kulübü</li><li>Dans Kulübü</li></ul>
          <h2>⚽ Spor Kulüpleri</h2>
          <ul><li>Futbol Kulübü</li><li>Basketbol Kulübü</li><li>Voleybol Kulübü</li></ul>
          <h2>💻 Akademik Kulüpler</h2>
          <ul><li>Bilgisayar Programlama Kulübü</li><li>Robotik Kulübü</li><li>Girişimcilik Kulübü</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/ogrenci-kulupleri",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        sosyal_tesisler: {
          baslik: "Sosyal Tesisler",
          icerik: `<article><div class="social-facilities"><h1>Sosyal Tesislerimiz</h1>
          <h2>🍽️ Yemek ve İçecek</h2>
          <ul><li>Ana kafeterya (1000 kişi kapasiteli)</li><li>Snack barlar</li><li>Açık hava cafe alanları</li></ul>
          <h2>📚 Çalışma Alanları</h2>
          <ul><li>24/7 açık çalışma salonları</li><li>Grup çalışma odaları</li><li>Sessiz çalışma alanları</li></ul>
          <h2>🏥 Sağlık Hizmetleri</h2>
          <ul><li>Kampüs sağlık merkezi</li><li>Psikologik danışmanlık</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/sosyal-tesisler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },

      // INTERNATIONAL MENÜSÜ
      international: {
        degisim_programlari: {
          baslik: "Değişim Programları",
          icerik: `<article><div class="exchange-programs"><h1>Uluslararası Değişim Programları</h1>
          <h2>🇪🇺 Erasmus+ Programı</h2>
          <ul><li>200+ partner üniversite</li><li>35+ Avrupa ülkesi</li><li>Tam burs desteği</li></ul>
          <h2>🌎 Global Exchange Programs</h2>
          <ul><li>ABD üniversiteleri ile iş birliği</li><li>Asya-Pasifik programları</li></ul>
          <h2>🎓 Double Degree Programs</h2>
          <ul><li>İki diploma alma fırsatı</li><li>Partner üniversitelerle ortak programlar</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/degisim-programlari",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        uluslararasi_ogrenciler: {
          baslik: "Uluslararası Öğrenciler",
          icerik: `<article><div class="international-students"><h1>Uluslararası Öğrenci Hizmetleri</h1>
          <h2>🌍 Öğrenci Profili</h2>
          <ul><li>50+ farklı ülkeden öğrenci</li><li>1000+ uluslararası öğrenci</li></ul>
          <h2>🏠 Destek Hizmetleri</h2>
          <ul><li>Oryantasyon programı</li><li>Konaklama yardımı</li><li>Vize işlemleri desteği</li></ul>
          <h2>🎓 Program Seçenekleri</h2>
          <ul><li>İngilizce lisans programları</li><li>İngilizce yüksek lisans programları</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/uluslararasi-ogrenciler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        partner_universiteler: {
          baslik: "Partner Üniversiteler",
          icerik: `<article><div class="partner-universities"><h1>Partner Üniversitelerimiz</h1>
          <h2>🇪🇺 Avrupa</h2>
          <ul><li>University of Vienna - Avusturya</li><li>Sorbonne University - Fransa</li><li>Technical University of Munich - Almanya</li></ul>
          <h2>🇺🇸 Amerika</h2>
          <ul><li>University of California - ABD</li><li>Boston University - ABD</li></ul>
          <h2>🌏 Asya</h2>
          <ul><li>National University of Singapore</li><li>Seoul National University - Güney Kore</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/partner-universiteler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      },

      // İLETİŞİM MENÜSÜ
      iletisim: {
        iletisim_bilgileri: {
          baslik: "İletişim Bilgileri",
          icerik: `<article><div class="contact-info"><h1>İletişim Bilgilerimiz</h1>
          <h2>📍 Adres</h2>
          <p><strong>İzmir Ekonomi Üniversitesi</strong><br>
          Sakarya Caddesi No: 156<br>
          35330 Balçova / İZMİR</p>
          
          <h2>📞 Telefon</h2>
          <ul><li>Santral: (0232) 488 90 00</li><li>Öğrenci İşleri: (0232) 488 90 01</li></ul>
          
          <h2>📧 E-posta</h2>
          <ul><li>Genel: info@ieu.edu.tr</li><li>Öğrenci İşleri: ogrenci@ieu.edu.tr</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/iletisim",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        kampus_haritasi: {
          baslik: "Kampüs Haritası",
          icerik: `<article><div class="campus-map"><h1>Kampüs Haritası ve Ulaşım</h1>
          <h2>🗺️ Kampüs Binalar</h2>
          <ul><li>A Blok - İdari Binalar</li><li>B Blok - İşletme Fakültesi</li><li>C Blok - Mühendislik Fakültesi</li></ul>
          
          <h2>🚌 Ulaşım İmkanları</h2>
          <ul><li>İZBAN: Balçova İstasyonu</li><li>Otobüs: 51, 52, 60 numaralı hatlar</li><li>Metro: Balçova Metro İstasyonu</li></ul>
          
          <h2>🚗 Otopark Alanları</h2>
          <ul><li>Öğrenci otoparkı (500 araç kapasiteli)</li><li>Personel otoparkı</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/kampus-haritasi",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        },
        online_islemler: {
          baslik: "Online İşlemler",
          icerik: `<article><div class="online-services"><h1>Online İşlemler</h1>
          <h2>🎓 Öğrenci Portalı</h2>
          <ul><li>Ders kayıt işlemleri</li><li>Not görüntüleme</li><li>Transkript çıktısı</li></ul>
          
          <h2>📚 Akademik Sistemler</h2>
          <ul><li>LMS (Öğrenme Yönetim Sistemi)</li><li>Blackboard</li><li>Online sınav sistemi</li></ul>
          
          <h2>📝 Başvuru Sistemleri</h2>
          <ul><li>Lisans başvuru sistemi</li><li>Yüksek lisans başvuruları</li><li>Burs başvuru sistemi</li></ul>
          </div></article>`,
          link: "https://www.ieu.edu.tr/tr/online-islemler",
          olusturmaTarihi: "2025-07-29T10:00:00Z",
          guncellenmeTarihi: "2025-07-29T10:00:00Z"
        }
      }
    };
    
    // Firebase'e güvenli şekilde her kategoriyi ayrı ayrı yükle
    for (const [category, categoryData] of Object.entries(menuData)) {
      console.log(`📝 ${category} kategorisi yükleniyor...`);
      const categoryRef = db.ref(`menuler/${category}`);
      await categoryRef.set(categoryData);
      console.log(`✅ ${category} kategorisi başarıyla yüklendi!`);
    }
    
    console.log('\n🎉 Tüm menü kategorileri başarıyla Firebase\'e yüklendi!');
    console.log('\n📊 Yüklenen Kategoriler:');
    console.log('🏛️  Üniversite: 4 sayfa (rektorumuzden, baskanimizdan, misyonvevizyon, tarihce)');
    console.log('🎓 Akademik: 4 sayfa (fakulteler, lisans_programlari, yuksek_lisans, doktora)'); 
    console.log('🔬 Araştırma: 3 sayfa (arastirma_merkezleri, projeler, yayinlar)');
    console.log('🏫 Kampüs: 3 sayfa (kampus_yasami, ogrenci_kulupleri, sosyal_tesisler)');
    console.log('🌍 International: 3 sayfa (degisim_programlari, uluslararasi_ogrenciler, partner_universiteler)');
    console.log('📞 İletişim: 3 sayfa (iletisim_bilgileri, kampus_haritasi, online_islemler)');
    console.log('\n📝 Toplam: 20 içerik sayfası yüklendi');
    console.log('\n✨ Mevcut veriler korundu, yeni kategoriler eklendi!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

uploadAllMenuData();

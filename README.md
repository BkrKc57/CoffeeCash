# CoffeeCash
Mobil Ödeme Modülü
Uygulama Firebase push notification a register olmalı
Uygulama açılışında iki butonun yer aldığı bir ekran gelecek, bu ekranda
“Kasiyerim”,”Müşteriyim” butonları bulunacaktır.
Müşteri
Müşteriyim ekranında bir qr kod generate edilecektir.
Ve Ekranda “Ödeme durumu: “ texti bulunacaktır.
Kasiyer
Kullanıcı “Kasiyerim” butonuna bastığında bir qr kod reader ekranı açılacak ve Kasiyer’den
Müşterinin ekranındaki qr kod okutulması istenecektir.
Senaryo
Kasiyer Müşterinin ekranındaki Qr kodu okuttuğunda,
Kasiyer önünde fiş formu açılacaktır,
Bu formda;
Ödeme Tutarı: 50 – 100 – 200 ve Diğer seçenekleri olacaktır. Kullanıcı Diğer seçerse bir textbox
ile 200 den büyük istediği tutarı girebilecektir.
Ödemeyi Gönder butonu olacaktır, Kasiyer bu butona bastığında Müşteri ekranı güncellenecek
ve QR kod yerine “Ödeme Tutarı : XXX” yazacak altında “Kredi Kartı ile öde”,”Nakit Öde”,”İptal
Et” butonları buluncaktır.
Müşteri bu butonlardan herhangi birine bastığında “Teşekkürler” diyip ana sayfaya
gönderilecektir ayrıca Kasiyer ekranı güncellenecek ve “Müşteri ödeme yapmıştır. Ödeme
Bilgisi: Kredi Kartı / Nakit” veya “Müşteri siparişi iptal etmiştir” şeklinde mesaj yazılacaktır.

Bu ekranda “Yeni Fiş Oluştur” butonu olacaktır. Bu butona basınca Kasiyer ekranından ana
sayfaya dönülecektir.
Uygulamada crashlytics entegrasyonu olmalı ve bir butona bastığımızda crash reporta düşmeli
Uygulamada qr kod generate edildiğinde, qr kod kasiyer tarafında okutulduğunda firebase e
event atılmalı.
Bu uygulama 2 farklı cihaza yüklenerek Müşteri ve Kasiyer olarak test edilecektir.

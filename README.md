# Arduino-Russian-Roulette

### Anggota Kelompok:
* Evandita Wiratama Putra 2206059572
* Muhammad Billie Elian   2206059446
* Valentino Farish Adrian 2206825896

## Deskripsi Proyek

Arduino Russian Roulette adalah permainan sederhana yang menggunakan Arduino Uno dan bahasa Assembly untuk mensimulasikan permainan Russian Roulette. Dalam permainan ini, pemain secara bergantian "menembak" diri mereka sendiri dengan revolver yang memiliki satu peluru. Pemain yang terkena peluru akan kalah.

## Cara Kerja Permainan

1. **Penentuan Slot Peluru:**
   - Pada awal permainan, juri memutar potentiometer yang berfungsi sebagai Cylinder Revolver.
   - Nilai dari potentiometer ini akan menentukan slot peluru pada Cylinder, dengan 4 slot yang tersedia, dimulai dari slot 1.
   - Konversi nilai ADC untuk penentuan Slot Peluru adalah sebagai berikut:
     - 0 - 255   => Slot 1
     - 256 - 511 => Slot 2
     - 512 - 767 => Slot 3
     - 768 - 1024 => Slot 4

2. **Mekanisme Permainan:**
   - Setiap ronde, pemain akan menekan sebuah tombol untuk menembak diri mereka sendiri.
   - Jika slot saat ini tidak berisi peluru, pemain selamat dan permainan berlanjut ke ronde berikutnya.
   - Jika slot saat ini berisi peluru, pemain kalah dan permainan berakhir.
   - Sebuah LED dan buzzer akan menyala untuk menandakan bahwa peluru telah ditembakkan.
   - Hasil setiap ronde akan ditampilkan melalui Serial Monitor.

3. **Pergantian Slot:**
   - Sebelum melanjutkan ke ronde berikutnya, pemain harus menekan photoresistor yang berfungsi sebagai Hammer Revolver untuk mengganti revolver ke slot berikutnya.
   - Setelah itu, Arduino (Revolver) akan diserahkan ke pemain berikutnya.

## Kriteria Implementasi

1. **ADC (Analog-to-Digital Converter):**
   - Digunakan untuk input dari potentiometer sebagai Cylinder Revolver.
   - Digunakan untuk input dari photoresistor sebagai Hammer Revolver.

2. **Serial Communication:**
   - Menampilkan hasil apakah pemain mati atau hidup melalui Serial Monitor.

3. **Arithmetic:**
   - Menentukan lokasi peluru pada cylinder melalui proses pembagian.

4. **Interrupt:**
   - Digunakan untuk mereset permainan.

5. **Sensor Interfacing:**
   - Menggunakan photoresistor untuk input sebagai Hammer Revolver.
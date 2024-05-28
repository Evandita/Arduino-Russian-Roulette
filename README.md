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
```assembly
init_ADC0:
; Input di pin PC0
    SBI   DDRC, 0          ; set pin PC0 sebagai input untuk ADC0
    LDI   R20, 0x40        ; internal 2.56V, data right-justified, ADC0
    STS   ADMUX, R20
    LDI   R20, 0x87        ; aktifkan ADC, prescaler ADC CLK/128
    STS   ADCSRA, R20
    RET
```

2. **Serial Communication:**
   - Menampilkan hasil apakah pemain mati atau hidup melalui Serial Monitor.
```assembly
init_serial:
    CLR   R24
    STS   UCSR0A, R24                   ; bersihkan register UCSR0A
    STS   UBRR0H, R24                   ; bersihkan register UBRR0H
    LDI   R24, 51                       ; simpan nilai 51 di UBRR0L untuk baud rate 19200
    STS   UBRR0L, R24                   ; atur baud rate 19200
    LDI   R24, 1<<RXEN0 | 1<<TXEN0      ; aktifkan RX dan TX
    STS   UCSR0B, R24
    LDI   R24, 1<<UCSZ00 | 1<<UCSZ01    ; mode asinkron, no parity, 1 stop, 8 bits
    STS   UCSR0C, R24
    RET
```

3. **Arithmetic:**
   - Menentukan lokasi peluru pada cylinder melalui proses pembagian.
```assembly
get_counter:
    LDI   R25, 1
counter_loop:
    SUBI  R19, 1
    BRLO  done_counter
    INC   R25
    RJMP  counter_loop
done_counter: RET
```

4. **Interrupt:**
   - Digunakan untuk mereset permainan.
```assembly
.org 0x0000             ; Reset Interrupt Handler
    rjmp main_loop
```

5. **Sensor Interfacing:**
   - Menggunakan photoresistor untuk input sebagai Hammer Revolver.
```assembly
init_ADC1:
; Input di pin PC1
    SBI   DDRC, 1          ; set pin PC1 sebagai input untuk ADC1
    LDI   R20, 0x41        ; internal 2.56V, data right-justified, ADC1
    STS   ADMUX, R20
    LDI   R20, 0x87        ; aktifkan ADC, prescaler ADC CLK/128
    STS   ADCSRA, R20
    RET
```
## Rangkaian

### Rangkaian Proteus
![alt text](https://cdn.discordapp.com/attachments/861583157441724450/1244987588625043497/Screenshot_2024-05-27_141028.png?ex=66571c8b&is=6655cb0b&hm=7a4373b758db5c1db71203bc528983d1517616ecb2843cef297fec1cec541aa1&)

### Rangkaian Asli
![alt text](https://cdn.discordapp.com/attachments/861583157441724450/1244988148631474226/image.png?ex=66571d11&is=6655cb91&hm=e872272242c7b7fbca107e7fb060a30c55c7386cd26ac8afb5724ccc2d095eff&)
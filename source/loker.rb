class Slot
  attr_reader :jenis_identitas, :nomor_identitas
  
  def initialize
    @jenis_identitas = nil
    @nomor_identitas = nil
  end
  def pakai(jenis_id, no_id)
    @jenis_identitas = jenis_id.upcase
    @nomor_identitas = no_id
  end
  def kosong?
    @nomor_identitas.nil?
  end
  def kosongkan
    @jenis_identitas = nil
    @nomor_identitas = nil
  end
end


class Loker
  attr_reader :slots
  
  def initialize(jml_slot)
    @slots = (0...jml_slot).map{|x|Slot.new}
  end
  def kosong?
    @slots.select{|x|!x.kosong?}.empty?
  end
  def penuh?
    @slots.select{|x|x.kosong?}.empty?
  end
  def where_are?(options)
    # options => jenis_id: xxx, nomor_id: xxx
    # return array of slot numbers
    
    if !options.is_a?(Hash)
      raise "#{self.class}.where? parameter must be a Hash."
    elsif options.empty?
      raise "#{self.class}.where? parameters cannnot be empty."
    elsif !(io = (options.keys - [:jenis_id, :nomor_id])).empty?
      raise "Invalid where? options: #{io.map{|x|x.inspect}}."
    else
      (0...@slots.count).select do |s|
        cv = {jenis_id: :jenis_identitas, nomor_id: :nomor_identitas}
        sx = @slots[s]
        v1 = options.keys.map{|x|sx.__send__(cv[x])}.join("|").upcase
        v2 = options.values.join("|").upcase
        v1 == v2
      end
    end
  end
  def where_is?(options)
    if !(list = where_are?(options)).empty?
      list.first
    else
      nil
    end
  end
end


class App
  def initialize
    @loker = nil
    @m_jenis_id = ["KTP", "SIM"]
  end
  def prompt(msg)
    print msg
    gets.strip
  end
  def format(teks, panjang)
    ss = "#{teks}"
    
    if ss.length < panjang
      sl = " " * ((panjang - ss.length) / 2)
      sr = " " * (panjang - ss.length - sl.length)
      "#{sl}#{ss}#{sr}"
    else
      ss
    end
  end
  def valid_types_info
    @m_jenis_id.map{|x|"'#{x}'"}.join("|")
  end
  def valid_type?(jenis_id)
    @m_jenis_id.include?(jenis_id.upcase)
  end
  def display_slots(slot_numbers)
    info = 
      slot_numbers.map do |x|
        a = format(x + 1, 9)
        b = format(@loker.slots[x].jenis_identitas, 17)
        c = format(@loker.slots[x].nomor_identitas, 19)
        "|#{a}|#{b}|#{c}|"
      end
    
    puts
    puts "| No Slot | Tipe  Identitas |  Nomor Identitas  |"
    puts info.join("\n")
    puts
    puts "Total #{slot_numbers.count} data"
  end
  def say_thanks
    messages = 
      [
        "Thank you. I like this technical test... ;)", 
        "Well done, thank you", 
        "Thank you. See you later", 
        "Thank you. Nice to help", 
        "Terimakasih telah menggunakan software ini"
      ]
    
    puts messages[Random.new.rand(0...messages.count)]
  end
  def h_help(args)
    info = <<EOS
HELP atau INFO
  Menampilkan bantuan atau informasi cara penggunaan program ini
INIT <jumlah_slot>
  Membuat loker yang terdiri atas <jumlah_slot> slot
STATUS
  Menampilkan informasi semua slot
INPUT <jenis_identitas> <nomor_identitas>
  Menyimpan kartu identitas ke loker pada slot yang tersedia
LEAVE <nomor_loker>
  Mengosongkan loker pada slot nomor <nomor_loker>
FIND <nomor_identitas>
  Mencari kartu identitas di loker
SEARCH <jenis_identitas>
  Menampilkan semua kartu identitas dari jenis <jenis_identitas>
EXIT, QUIT, BYE, DONE, atau KELUAR
  Keluar dari program ini
EOS
    
    puts info
  end
  def h_init(args)
    # INIT <jml_loker>
    
    if args.count != 1
      puts "Sintaks salah. Sintaks: INIT <jumlah_loker>."
    elsif (jumlah = Integer(args.first) rescue nil).nil?
      puts "Jumlah loker harus integer."
    elsif jumlah <= 0
      puts "Jumlah loker harus lebih besar dari nol."
    elsif !@loker.nil? && (prompt("Loker sudah diinisialisasi dengan #{@loker.slots.count} slot. Inisialisasi ulang? (y/n) ").downcase != "y")
      puts "Inisialisasi loker dibatalkan."
    else
      @loker = Loker.new(jumlah)
      puts "Loker berhasil dibuat, jumlah slot: #{jumlah}"
    end
  end
  def h_input(args)
    # INPUT <tipe_identitas> <nomor_identitas>
    
    if args.count != 2
      puts "Sintaks salah. Sintaks: INPUT #{valid_types_info} <no_identitas>"
    elsif @loker.nil?
      puts "Maaf, loker belum dibuat. Jalankan INIT dulu."
    elsif !valid_type?(jenis_id = args[0])
      puts "Jenis identitas '#{jenis_id}' tidak valid. Pilih salah satu: #{valid_types_info}."
    elsif @loker.penuh?
      puts "Maaf, loker sudah penuh."
    elsif !(no_slot = @loker.where_is?(jenis_id: jenis_id, nomor_id: no_identitas = args[1].upcase)).nil?
      puts "#{jenis_id.upcase} dengan nomor '#{no_identitas}' sudah ada sebelumnya di slot ##{no_slot + 1}."
    elsif (no_slot = @loker.slots.index{|x|x.kosong?}).nil?
      puts "Gagal mendapatkan slot kosong."
    else
      @loker.slots[no_slot].pakai jenis_id, no_identitas
      
      if @loker.slots[no_slot].kosong?
        puts "Gagal menyimpan ke loker pada slot ##{no_slot + 1}."
      else
        puts "#{jenis_id.upcase} dengan nomor '#{no_identitas}' berhasil disimpan di loker ##{no_slot + 1}."
      end
    end
  end
  def h_leave(args)
    # LEAVE <nomor_slot>
    
    if args.count != 1
      puts "Sintaks salah. Sintaks: LEAVE <nomor_slot>"
    elsif @loker.nil?
      puts "Maaf, loker belum dibuat. Jalankan INIT dulu."
    elsif (no_slot = Integer(args.first) rescue nil).nil?
      puts "Nomor slot '#{args.first}' tidak valid (harus integer)."
    elsif !(1..@loker.slots.count).include?(no_slot)
      puts "Nomor slot harus antara 1 dan #{@loker.slots.count}."
    elsif @loker.slots[no_slot].kosong?
      puts "Maaf, slot nomor '#{no_slot}' belum terisi."
    else
      @loker.slots[no_slot - 1].kosongkan
      if @loker.slots[no_slot - 1].kosong?
        puts "Loker pada slot ##{no_slot} berhasil dikosongkan."
      else
        puts "Gagal mengosongkan loker pada slot ##{no_slot}."
      end
    end
  end
  def h_find(args)
    # FIND <no_identitas>
    
    if args.count != 1
      puts "Sintaks salah. Sintaks: FIND <no_identitas>"
    elsif @loker.nil?
      puts "Maaf, loker belum dibuat. Jalankan INIT dulu."
    elsif (no_slot = @loker.where_is?(nomor_id: nomor_id = args.first)).nil?
      puts "No identitas '#{nomor_id.upcase}' tidak ditemukan."
    else
      puts "No identitas '#{nomor_id.upcase}' berada pada slot ##{no_slot + 1}."
    end
  end
  def h_search(args)
    # SEARCH <jenis_identitas>
    
    if args.count != 1
      puts "Sintaks salah. Sintaks: SEARCH #{valid_types_info}"
    elsif !valid_type?(jenis_id = args.first.upcase)
      puts "Jenis ID tidak valid. Pilih salah satu: #{valid_types_info}."
    elsif @loker.nil?
      puts "Maaf, loker belum dibuat. Jalankan INIT dulu."
    elsif @loker.kosong?
      puts "Loker masih kosong."
    elsif (no_slots = @loker.where_are?(jenis_id: jenis_id)).empty?
      puts "Tidak ada satupun kartu identitas dari jenis '#{jenis_id}' di loker."
    else
      display_slots no_slots
    end
  end
  def h_status(args)
    # STATUS
    
    if !args.empty?
      puts "Sintaks salah. Sintaks: STATUS (tanpa parameter)"
    elsif @loker.nil?
      puts "Maaf, loker belum dibuat. Jalankan INIT dulu."
    elsif @loker.kosong?
      puts "Loker terdiri atas #{@loker.slots.count} slot, semua masih kosong."
    else
      display_slots (0...@loker.slots.count).map{|x|x}
    end
  end
  def handle(cmd)
    if !cmd.empty?
      args = cmd.split(" ")
      cmd = args.shift
      
      case cmd.downcase
      when "help", "info"
        h_help args
      when "init"
        h_init args
      when "status"
        h_status args
      when "input"
        h_input args
      when "leave"
        h_leave args
      when "find"
        h_find args
      when "search"
        h_search args
      else
        puts "Perintah tidak dikenal: '#{cmd}'."
        puts "Ketik 'help' atau 'info' untuk informasi perintah yang tersedia."
      end
    end
  end
  def start
    puts "== APLIKASI SIMULASI LOKER =="
    puts "By Heryudi Praja, 190626"
    puts "E-mail: mr_orche@yahoo.com"
    puts "Phone : 082211407298"
    puts "github: github.com/masdjab"
    puts
    puts "Ketik 'exit', 'quit', 'done', 'bye' atau 'keluar' jika sudah selesai"
    puts "Ketik 'help' atau 'info' untuk informasi perintah yang tersedia"
    puts "Catatan: Perintah bersifat case-insensitive."
    puts
    
    loop do
      if !(cmd = prompt("Command: ")).empty?
        lwrcmd = cmd.downcase
        
        if ["exit", "quit", "bye", "done", "keluar"].include?(lwrcmd)
          break
        else
          handle cmd
          puts
        end
      end
    end
    
    puts
    say_thanks
  end
end

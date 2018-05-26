#==============================================================================
# ҉ Ligni Core
#==============================================================================
# Authors: (Dax Soft & Alisson) -> ligni 
# Version: 1.0
# Credits: 
#   - Gab! (register mode)
#   - Gotoken : benchmark module
# Support:
#   - Dax Soft   : https://www.dax-soft.weebly.com
#   - Alisson    : https://prismengine.wordpress.com/ 
#   - Help File  : <download link>
#==============================================================================
# A core with several modules and methods that will make easiest on the time
# of programmer your scripts, good look.
#==============================================================================
# Contents : • TAGS : Use CTRL+F to locate the code.
#   - Marshal :marshal
#   - File :file
#   - Array :array 
#   - Hash :hash 
#   - String :string
#   - Integer :integer 
#   - Numeric :numeric
#   - API :api
#   - API::MessageBox :messagebox
#   - API::PNG :png
#   - API::Find :find
#   - API::FindPlus :findplus
#   - API::Network :network
#   - API::Powershell :powershell
#   - Ligni::Key :key
#   - Ligni::Behaviour :behaviour
#   - Ligni::Invoke :invoke
#   - Ligni::InvokeRepeating :invoke_repeating
#   - Ligni::Mathf :mathf
#   - Ligni::Vector :vector
#   - Ligni::Color :ligni_color 
#   - Ligni::Position :position
#   - Ligni::Axis :axis
#   - Ligni::Collision :collision
#   - Ligni::Advanced_Sprite
#   - Ligni::Advanced_Sprite_Component
#   - Rect :rect 
#   - Sprite :sprite 
#   - Bitmap :bitmap
#   - Window_Base :window_base
#   - Ligni::Backup :backup
#   - Opacity :opacity
#   - Ligni::Mouse :mouse
#   - Benchmark :benchmark
#   - Object :object
#   - Kernel :kernel
#   - SceneManager :scenemanager
#   - Graphics :graphic
#==============================================================================
module Ligni; extend self 
  #----------------------------------------------------------------------------
  # • Constants 
  #----------------------------------------------------------------------------
  STANDALONE = Module.new     # Módulo para a criação de scripts standalone.
  NOTE_SEPARATOR      = "<>"  # Separador de notas do Database.
  FIXED_UPDATE_COUNT  = 15    # Tempo de espera para o fixed update.
  SECOND_UPDATE_COUNT = 60    # Tempo de espera para o update de segundos.
  VERSION = '1.0'             # Versão do Core
  # If you don't wanna that mouse system was a picture, don't set anything
  # on the constant bellow... If you wanna, set the name of the picture...
  # the picture has to be on the directory System.
  MOUSE_NAME = ""
  #----------------------------------------------------------------------------
  # • Variables
  #----------------------------------------------------------------------------
  @fx_up_count = 15 # Contagem inicial do fixed update.
  @sc_up_count = 60 # Contagem inicial do second update.
  @@data = {}       # registro dos scripts
  @@_data = {}      # garbage dos registros
  @@setup = {}      # registrar configurações de scripts, moldável 
  #----------------------------------------------------------------------------
  # • [Boolean] : Register the script
  #     [symbol] : name : name of your script
  #     [string] : author : author of the script
  #     [numeric] : version : version
  #     [array] : requires : requires to exec your script
  #     [proc] : &block : block that will content all script
  #    requires : Set inside on array, another array, that contents
  # the name of the script, author e if you wanna, the version.
  #----------------------------------------------------------------------------
  def register(name, author, version, requires=[], &block)
    need = []
    requires.each { |data| need << data unless self.registered?(*data) }
    if need.empty?
      @@data[[name, author]] = version
      @@setup[[name, author]] = {}
      block.call
      @@_data.each_pair { |(cache_name, cache_author, cache_version), (_need, _block)|
        _need.delete_if { |_n_| self.registered?(*_n_) }
        next unless _need.empty?
        @@_data.delete([cache_name, cache_author, cache_version])
        self.register(cache_name, cache_author, cache_version, &_block)
      }
    else
      @@_data[[name, author, version]] = [need, block]
    end
    return true
  end
  #----------------------------------------------------------------------------
  # • [Boolean] : Check out if has been registered
  #     [symbol] : name : script's name
  #     [string] : author : author's name
  #     [numeric] : version : version's name
  #----------------------------------------------------------------------------
  def registered?(name, author, version=nil)
    if @@data.has_key?([name, author])
      return true if version.nil?
      _version = @@data[[name, author]]
      return _version >= version
    else
    return false
    end
  end
  #----------------------------------------------------------------------------
  # • [Boolean] Set a script as requirement, if don't have this script, you will be
  # take a warnin' about it
  #     [symbol] : name : script's name
  #     [string] : author : author's name
  #     [numeric] : version : version's script
  #----------------------------------------------------------------------------
  def required(name, author, version=nil)
    if @@data.has_key?([name, author])
      return true if version.nil?
      _version = @@data[[name, author]]
      if _version >= version
        return true
      else
        msgbox("Script off update: #{String(name)} v#{String(_version)} por #{String(author)}\nVersion of requirement: #{version}")
        exit
      end
    else
      msgbox("Script don't found: #{String(name)} v#{String(version)} por #{String(author)}")
      exit
    end
    return true
  end
  #----------------------------------------------------------------------------
  # • [Hash] Return to @@data
  #----------------------------------------------------------------------------
  def data
    @@data
  end
  #----------------------------------------------------------------------------
  # • [Hash] Return to @@setup | return to setup[[name, author]] = {}
  #----------------------------------------------------------------------------
  def setup
    @@setup 
  end 
  #----------------------------------------------------------------------------
  # • [Object] setup param
  #   rkey = [script, author]
  #   key 
  #----------------------------------------------------------------------------
  def param(rkey, key, value=nil, &block)
    setup[rkey][key] = {} if setup[rkey][key].nil?
    if block_given?
      setup[rkey][key][:param] = block.call
    else
      setup[rkey][key][:param] = value
    end
  end
  #----------------------------------------------------------------------------
  # • [Object] setup help
  #   rkey = [script, author]
  #   key 
  #----------------------------------------------------------------------------
  def help(rkey, key, value=nil, &block)
    setup[rkey][key] = {} if setup[rkey][key].nil?
    if block_given?
      setup[rkey][key][:help] = block.call
    else
      setup[rkey][key][:help] = value
    end
  end
  #----------------------------------------------------------------------------
  # • getParam
  #   rkey = [script, author]
  #   key
  #----------------------------------------------------------------------------
  def getParam(rkey, key)
    setup[rkey][key] = {} if setup[rkey][key].nil?
    setup[rkey][key][:param] = "" unless setup[rkey][key].has_key?(:param)
    setup[rkey][key][:param]
  end
  #----------------------------------------------------------------------------
  # • getHelp
  #   rkey = [script, author]
  #   key
  #----------------------------------------------------------------------------
  def getHelp(rkey, key)
    setup[rkey][key] = {} if setup[rkey][key].nil?
    setup[rkey][key][:help] = "" unless setup[rkey][key].has_key?(:help)
    setup[rkey][key][:help]
  end
  #----------------------------------------------------------------------------
  # • [Boolean] Remove a scene (your "use" on $RGSS)
  #----------------------------------------------------------------------------
  def remove(symbol_name)
    Object.send(:remove_const, symbol_name)
  end 
  #----------------------------------------------------------------------------
  # • [Output] Print a list that contain all registred script on Core.
  #----------------------------------------------------------------------------
  def list_string
    puts "List of registered scripts on Core: ~ Total: %d" % self.data.size 
    self.data.each_pair { |key, value|
      puts sprintf("\t- script: (%s) from %s [%s]", key[0].to_s, key[1].to_s, value.to_s)
    }
    puts "..."
  end
  #----------------------------------------------------------------------------
  # • export(data, ext)
  #----------------------------------------------------------------------------
  def export(data, ext)
    save_data(Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION), ext)
  end
  #----------------------------------------------------------------------------
  # • import(data, ext)
  #----------------------------------------------------------------------------
  def import(data)
    return Zlib::Inflate.inflate(load_data(data)).force_encoding("UTF-8")
  end
  #----------------------------------------------------------------------------
  # • update
  #----------------------------------------------------------------------------
  def update
    fixed_update
    second_update
    Ligni::Key.update
    Ligni::Behaviour.main_update
    Ligni::Mouse.update
  end
  #----------------------------------------------------------------------------
  # • fixed_update
  #----------------------------------------------------------------------------
  def fixed_update
    next_count = @fx_up_count + 1
    next_count > FIXED_UPDATE_COUNT ? @fx_up_count = 0 : @fx_up_count += 1
  end
  #----------------------------------------------------------------------------
  # • second_update
  #----------------------------------------------------------------------------
  def second_update
    next_count = @sc_up_count + 1
    next_count > SECOND_UPDATE_COUNT ? @sc_up_count = 0 : @sc_up_count += 1
  end
  #----------------------------------------------------------------------------
  # • folder_name_check
  #----------------------------------------------------------------------------
  def folder_name_check(string)
    result = string
    result.gsub!(/\\\//) {"_"}
    result.gsub!(/:/) {"-"}
    result.gsub!(/\*\?<>\|/) {""}
    return result
  end
  #----------------------------------------------------------------------------
  # • run_fixed_update?
  #----------------------------------------------------------------------------
  def run_fixed_update?
    @fx_up_count == 15
  end
  #----------------------------------------------------------------------------
  # • run_second_update?
  #----------------------------------------------------------------------------
  def run_second_update?
    @sc_up_count == 60
  end
  #----------------------------------------------------------------------------
  # • load_tags
  #----------------------------------------------------------------------------
  def load_tags
    [$data_actors, $data_classes, $data_skills, $data_items,
    $data_weapons, $data_armors, $data_enemies, $data_states].each do |object|
      object.each do |item|
        next unless item 
        item.start_note_container
      end
    end
  end
  #----------------------------------------------------------------------------
  # • extract_scripts
  #----------------------------------------------------------------------------
  def extract_scripts(folder)
    Dir.mkdir(folder) unless Dir.exists?(folder)
    c = 0
    $RGSS_SCRIPTS.each {|sc|
      n = folder_name_check(folder + sprintf("%d - #{sc[1]}.rb", c))
      t = sc[3]
      next if t.empty?
      begin
        f = File.open(n, "w")
        f.write(t)
      ensure
        f.close
      end
      c += 1
    }
  end
  #----------------------------------------------------------------------------
  # • 
  #----------------------------------------------------------------------------
  
end
#==============================================================================
# ҉ Marshal
#==============================================================================
Ligni.register(:marshal, "ligni", 1.0) {
class << Marshal
	
 #┌───────────────┬──────┬────────────────────────────────────────────────────┐
 #│ ♦ prism_load  │ load │ Permite a leitura de arquivos que não sejam do RM. │
 #└───────────────┴──────┴────────────────────────────────────────────────────┘
	alias :ligni_load :load
	def load(port, proc = nil)
		ligni_load(port, proc)
	rescue TypeError
		if port.kind_of?(File)
			port.rewind
			port.read
		else
			port
		end
	end
	
end unless Marshal.respond_to?(:ligni_load) # ▫ ▫ ▫ ▫ ▫ ▫ ▫ ▫ ▫ ▫ ▫ ▫  Marshal ◄
}
#==============================================================================
# • File
#==============================================================================
Ligni.register(:file, "ligni", 1.0) {
class << File
  #----------------------------------------------------------------------------
  # • [BooleanClass] : Execute a file script
  #----------------------------------------------------------------------------
  def eval(filename)
    return unless filename.match(/.rb|.rvdata2/) or FileTest.exist?(filename)
    script = ""
    nilcommand = false
    IO.readlines(filename).each { |i|
      if i.match(/^=begin/)
        nilcommand = true
      elsif i.match(/^=end/) and nilcommand
        nilcommand = false
      elsif !nilcommand
        script += i.gsub(/#(.*)/, "").to_s + "\n"
      end
    }
    Kernel.eval(script)
    return true
  end
  #----------------------------------------------------------------------------
  # • [String] : Get the most recent file on dir
  #----------------------------------------------------------------------------
  def recent(dir="*")
    return Dir.glob(dir).sort {|a,b| File.ctime(a) <=> File.ctime(b)}.last
  end
end
}
#==============================================================================
# • Array
#==============================================================================
Ligni.register(:array, "ligni", 1.0) {
class Array
  #----------------------------------------------------------------------------
  # • instance variables of the class
  #----------------------------------------------------------------------------
  attr_reader   :next
  attr_reader   :pred
  #----------------------------------------------------------------------------
  # • [Hash] : Turn on the array to hash
  #     Set ou a value for all keys
  #     [1, 2].to_hash_keys { :default_value }
  #     { 1 => :default_value, 2 => :default_value }
  #----------------------------------------------------------------------------
  def to_hash_keys(&block)
    Hash[*self.collect { |v|
        [v, block.call(v)]
      }.flatten]
  end
  #----------------------------------------------------------------------------
  # • [Array] : Sortin' all objects on crescent ordem
  #----------------------------------------------------------------------------
  def crescent
    sort! { |a, b| a <=> b }
  end
  #----------------------------------------------------------------------------
  # • [Array] : Sortin' all objects on decrescent ordem
  #----------------------------------------------------------------------------
  def decrescent
    sort! { |a, b| b <=> a }
  end
  #----------------------------------------------------------------------------
  # • [Object] : Return to the next value available
  #       x = [1, 8]
  #       x.next # 1
  #       x.next # 8
  #----------------------------------------------------------------------------
  def next(x=0)
    @next = (@next.nil? ? 0 : @next == self.size - 1 ? 0 : @next.next + x)
    return self[@next]
  end
  alias :+@ :next
  #----------------------------------------------------------------------------
  # • [Object] : Return to the previous value available
  #       x = [1, 8]
  #       x.prev # 8
  #       x.prev # 1
  #----------------------------------------------------------------------------
  def pred(x = 0)
    @prev = (@prev.nil? ? self.size-1 : @prev == 0 ? self.size-1 : @prev.pred + x)
    return self[@prev]
  end
  alias :-@ :pred
  #----------------------------------------------------------------------------
  # • [Mixed] : Return to the first value available follow by the rule fixed
  # msgbox [2, 3, 4, 5, 6].first! { |n| n.is_evan? } #> 2
  # msgbox [2, 3, 4, 5, 6].first! { |n| n.is_odd? } #> 3
  #----------------------------------------------------------------------------
  def first!
    return unless block_given?
    return self.each { |element| return element if yield(element) }.at(0)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Return a numeric value, all avaiable, that can be:
  #    v : :+ # add
  #        :- # decrease
  #        :* # multiple
  #        nil # avarage
  #----------------------------------------------------------------------------
  def alln?(v=nil)
    n = v == :* ? 1 : 0
    self.if {|i| i.is_a?(Numeric) }.each { |content|
      if v == :+
        n += content; next
      elsif v == :-
        n -= content; next
      elsif v == :*
        n *= content; next
      else
        n += content; next
      end
    }
    return (v == nil ? (n/self.size) : n)
  end
 #┌──────────────┬────────────────────────────────────────────────────────────┐
 #│ ♦ array_nil? │ Checa se todos os elementos de um array é nil.             │
 #├──────────────┴────────────────────────────────────────────────────────────┤
 #│     → array: a array em questão.                                          │
 #└───────────────────────────────────────────────────────────────────────────┘
  def array_nil?(array)
    return array.compact.size.zero?
  end
  
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ array_compact_sample                                                    │
 #├───────────────────────────────────────────────────────────────────────────┤
 #│ Obtém um item aleatório de uma array, exceto os itens nil.                │
 #│ Caso ela possua apenas nil, retorna false.                                │
 #│     → array: A array em questão.                                          │
 #└───────────────────────────────────────────────────────────────────────────┘
  def array_compact_sample(array)
    return false if array_nil?(array)
    result = array.compact.sample
  end
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ num_to_string                                                           │
 #├───────────────────────────────────────────────────────────────────────────┤
 #│ Converte uma array de códigos de caracteres em UTF-8 em uma string.       │
 #│ O formato precisa ser o mesmo gerado pelo Prism.string_to_num.            │
 #│ Ex: "Heya" seria [72, 101, 121, 97].                                      │
 #│     → array: uma array no formato mostrado acima.                         │
 #└───────────────────────────────────────────────────────────────────────────┘
  def num_to_string(array)
    result = ""
    array.each do |n|
      result << [n].pack("C")[0]
    end
    return result
  end
end
}
#==============================================================================
# • Hash
#==============================================================================
Ligni.register(:hash, "ligni", 1.0) {
class Hash
  #----------------------------------------------------------------------------
  # • [NilClass or Mixed] : Get the value of the specific key
  #     key : Chave.
  #     block(proc) : Condition to return the value of the key
  #     {1 => 12}.get(1) #=> 12
  #     {1 => 12}.get(1) { |k| k.is_a?(String) } #=> nil
  #----------------------------------------------------------------------------
  def get(key)
    if block_given?
      self.keys.each { |data|
        next unless key == data
        return self[data] if yield(self[data])
      }
    else
      self.keys.each { |data| return self[data] if key == data }
    end
    return nil
  end
  #----------------------------------------------------------------------------
  # • [Mix] : Return to the last key of the variable
  #----------------------------------------------------------------------------
  def last_key
    return self.keys.last
  end
end
}
#==============================================================================
# * String
#==============================================================================
Ligni.register(:string, "ligni", 1.0) {
class String
  #----------------------------------------------------------------------------
  # • [String] : Remove and added a extension on the string
  #      filename : filename
  #      extension : new extension
  #   "Hello.rb".extn(".rvdata2") # "Hello.rvdata2"
  #----------------------------------------------------------------------------
  def extn(extension)
    ext = extension.include?(".") ? extension : "." + extension
    if self.include?(".")
      self.gsub(/\.(\w+)/, ext)
    else
      return self + ext
    end
  end
  #--------------------------------------------------------------------------
  # • [String] : convert the string to UTF-8
  #--------------------------------------------------------------------------
  def to_utf8
    API.textUTF(self)
  end
  #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ string_to_num                                                           │
 #├───────────────────────────────────────────────────────────────────────────┤
 #│ Usado para transformar uma string em uma array de códigos dos caracteres  │
 #│ em UTF-8 (basicamente, transformar letras em números)                     │
 #│     → string: uma string qualquer.                                        │
 #└───────────────────────────────────────────────────────────────────────────┘
  def string_to_num
    result = []
    for i in 0...self.size
      result.push(string[i].unpack("U")[0])
    end
    return result
  end
 #┌────────────────┬──────────────────────────────────────────────────────────┐
 #│ ♦ only_spaces? │ Checa se uma string possui apenas espaços.               │
 #├────────────────┴──────────────────────────────────────────────────────────┤
 #│     → string: a string em questão.                                        │
 #└───────────────────────────────────────────────────────────────────────────┘
  def only_spaces?
    return self =~ /^\s*$/
  end
  #----------------------------------------------------------------------------
  # • [String] : convert to w_char
  #----------------------------------------------------------------------------
  def w_char
    wstr = ""
    self.size.times { |i| wstr += self[i, 1] + "\0" }
    wstr += "\0"
    return wstr
  end
  #--------------------------------------------------------------------------
  # • [Array] : Extract just the numeric values (integers) and return to a array
  # Exemplo: "João89".number # [8, 9]
  #--------------------------------------------------------------------------
  def number
    self.scan(/-*\d+/).collect{|n|n.to_i}
  end
  alias :num :number
  #----------------------------------------------------------------------------
  # • [String] : Aplly case sensitive, underline
  #   "Exemplo 2" => "Exemplo_2"
  #----------------------------------------------------------------------------
  def case_sensitive
    return self.gsub(" ", "_")
  end
  #----------------------------------------------------------------------------
  # • [Symbol] : turn on a string to symbol
  #     "Ola Meu Nome É" #:ola_menu_nome_é
  #----------------------------------------------------------------------------
  def symbol
    return self.case_sensitive.downcase.to_sym
  end
  #----------------------------------------------------------------------------
  # • [String] : remove the last character /alternativa to chomp/
  #----------------------------------------------------------------------------
  def backslash
    return String(self[0, self.split(//).size-1])
  end
  #----------------------------------------------------------------------------
  # • [String] : Limited of the string
  #----------------------------------------------------------------------------
  def trunca(start=0, length=20, ellipsis='')
    if self.length > length
      self[start..length].gsub(/\s*\S*\z/, '').rstrip+ellipsis 
    else 
      self.rstrip
    end
  end
  #----------------------------------------------------------------------------
  # • Xor's method
  #----------------------------------------------------------------------------
  def ^(string)
    bytes.map.with_index{|byte, index| byte ^ other[index % other.size].ord }.pack("C*")
  end
  alias xor ^
end
}
#==============================================================================
# * Integer
#==============================================================================
Ligni.register(:integer, "ligni", 1.0) {
class Integer
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Check out if it is evan
  #----------------------------------------------------------------------------
  def is_evan?
    return (self & 1) == 0
  end
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Check out if it is odd
  #----------------------------------------------------------------------------
  def is_odd?
    return (self & 1) == 1
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Crescent the value until came to maximum (setting), when it's comming
  # at the maximun, return to zero (can be set)
  #     back : return value
  #     max : maximum value
  #     compare : condition method | :> :< :>= :<=
  #----------------------------------------------------------------------------
  def up(back, max, compare=:>)
    return (self.method(compare).call(max) ? back : (self + 1))
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Decrease the value until came to zero(setting), when it's comming
  # at the zero, return to maximum (can be set)
  #     back : return value
  #     max : maximum value
  #     compare : condition method | :> :< :>= :<=
  #----------------------------------------------------------------------------
  def down(back, r=0, compare=:<)
    return (self.method(compare).call(back) ? r : (self - 1))
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Get out a random number
  #----------------------------------------------------------------------------
  def aleatory
    return ((1..(self.abs)).to_a).shuffle[rand(self).to_i].to_i
  end
end
}
#==============================================================================
# • Numeric
#==============================================================================
Ligni.register(:numeric, "ligni", 1.0) {
class Numeric
  #----------------------------------------------------------------------------
  # * [Numeric] : Bring to percent value
  #    a : actual value
  #    b : maximum value
  #----------------------------------------------------------------------------
  def to_p(a, b)
    self * a / b
  end
  alias :percent :to_p
  #----------------------------------------------------------------------------
  # • [Numeric] : Get out a percent
  #     max : maximum value
  #----------------------------------------------------------------------------
  def p_to(max)
    (self * max) / 100
  end
  alias :proportion :p_to
  #----------------------------------------------------------------------------
  # * [Numeric] : randomic numeric
  #     x : total variation. [-x, x]
  #----------------------------------------------------------------------------
  def randomic(x=4)
    return ( (self+rand(2)) + (self + (rand(2) == 0 ? rand(x) : -rand(x)) ) ) / 2
  end
  #----------------------------------------------------------------------------
  # * [Boolean] : Check out if the numeber is equal to a specified number setup
  #     1.equal?(2, 3) # false
  #----------------------------------------------------------------------------
  def equal?(*args)
    args.each { |i|
      self == i ? (return true) : next
    }
    return false
  end
end
}
#==============================================================================
# • API :
#==============================================================================
Ligni.register(:api, "ligni", 1.0) {
module API
  extend self
  #----------------------------------------------------------------------------
  # • [String] : unknow artisit : type of pointers
  #----------------------------------------------------------------------------
  TYPES = {
            struct: "p",
            int: "i",
            long: "l",
            INTERNET_PORT: "l",
            SOCKET: "p",
            C:  "p", #– 8-bit unsigned character (byte)
            c:  "p", # 8-bit character (byte)
            #   "i"8       – 8-bit signed integer
            #   "i"8      – 8-bit unsigned integer
            S:  "N", # – 16-bit unsigned integer (Win32/API: S used for string params)
            s:  "n", # – 16-bit signed integer
            #   "i"16     – 16-bit unsigned integer
            #   "i"16      – 16-bit signed integer
            I:  "I", # 32-bit unsigned integer
            i:  "i", # 32-bit signed integer
            #   "i"32     – 32-bit unsigned integer
            #   "i"32      – 32-bit signed integer
            L:  "L", # unsigned long int – platform-specific size
            l:  "l", # long int – platform-specific size. For discussion of platforms, see:
            #                (http://groups.google.com/group/ruby-ffi/browse_thread/thread/4762fc77130339b1)
            #   "i"64      – 64-bit signed integer
            #   "i"64     – 64-bit unsigned integer
            #   "l"_long  – 64-bit signed integer
            #   "l"_long – 64-bit unsigned integer
            F:  "L", # 32-bit floating point
            D:  "L", # 64-bit floating point (double-precision)
            P:  "P", # pointer – platform-specific size
            p:  "p", # C-style (NULL-terminated) character string (Win32API: S)
            B:  "i", # (?? 1 byte in C++)
            V:  "V", # For functions that return nothing (return type void).
            v:  "v", # For functions that return nothing (return type void).
            LPPOINT: "p",
            # Windows-specific type defs (ms-help://MS.MSDNQTR.v90.en/winprog/winprog/windows_data_types.htm):
            ATOM:      "I", # Atom ~= Symbol: Atom table stores strings and corresponding identifiers. Application
            # places a string in an atom table and receives a 16-bit integer, called an atom, that
            # can be used to access the string. Placed string is called an atom name.
            # See: http://msdn.microsoft.com/en-us/library/ms648708%28VS.85%29.aspx
            BOOL:      "i",
            BOOLEAN:   "i",
            BYTE:      "p", # Byte (8 bits). Declared as unsigned char
            #CALLBACK:  K,       # Win32.API gem-specific ?? MSDN: #define CALLBACK __stdcall
            CHAR:      "p", # 8-bit Windows (ANSI) character. See http://msdn.microsoft.com/en-us/library/dd183415%28VS.85%29.aspx
            COLORREF:  "i", # Red, green, blue (RGB) color value (32 bits). See COLORREF for more info.
            DWORD:     "i", # 32-bit unsigned integer. The range is 0 through 4,294,967,295 decimal.
            DWORDLONG: "i", # 64-bit unsigned integer. The range is 0 through 18,446,744,073,709,551,615 decimal.
            DWORD_PTR: "l", # Unsigned long type for pointer precision. Use when casting a pointer to a long type
            # to perform pointer arithmetic. (Also commonly used for general 32-bit parameters that have
            # been extended to 64 bits in 64-bit Windows.)  BaseTsd.h: #typedef ULONG_PTR DWORD_PTR;
            DWORD32:   "I",
            DWORD64:   "I",
            HALF_PTR:  "i", # Half the size of a pointer. Use within a structure that contains a pointer and two small fields.
            # BaseTsd.h: #ifdef (_WIN64) typedef int HALF_PTR; #else typedef short HALF_PTR;
            HACCEL:    "i", # (L) Handle to an accelerator table. WinDef.h: #typedef HANDLE HACCEL;
            # See http://msdn.microsoft.com/en-us/library/ms645526%28VS.85%29.aspx
            HANDLE:    "l", # (L) Handle to an object. WinNT.h: #typedef PVOID HANDLE;
            # todo: Platform-dependent! Need to change to "i"64 for Win64
            HBITMAP:   "l", # (L) Handle to a bitmap: http://msdn.microsoft.com/en-us/library/dd183377%28VS.85%29.aspx
            HBRUSH:    "l", # (L) Handle to a brush. http://msdn.microsoft.com/en-us/library/dd183394%28VS.85%29.aspx
            HCOLORSPACE: "l", # (L) Handle to a color space. http://msdn.microsoft.com/en-us/library/ms536546%28VS.85%29.aspx
            HCURSOR:   "l", # (L) Handle to a cursor. http://msdn.microsoft.com/en-us/library/ms646970%28VS.85%29.aspx
            HCONV:     "l", # (L) Handle to a dynamic data exchange (DDE) conversation.
            HCONVLIST: "l", # (L) Handle to a DDE conversation list. HANDLE - L ?
            HDDEDATA:  "l", # (L) Handle to DDE data (structure?)
            HDC:       "l", # (L) Handle to a device context (DC). http://msdn.microsoft.com/en-us/library/dd183560%28VS.85%29.aspx
            HDESK:     "l", # (L) Handle to a desktop. http://msdn.microsoft.com/en-us/library/ms682573%28VS.85%29.aspx
            HDROP:     "l", # (L) Handle to an internal drop structure.
            HDWP:      "l", # (L) Handle to a deferred window position structure.
            HENHMETAFILE: "l", #(L) Handle to an enhanced metafile. http://msdn.microsoft.com/en-us/library/dd145051%28VS.85%29.aspx
            HFILE:     "i", # (I) Special file handle to a file opened by OpenFile, not CreateFile.
            # WinDef.h: #typedef int HFILE;
            REGSAM:    "i",
            HFONT:     "l", # (L) Handle to a font. http://msdn.microsoft.com/en-us/library/dd162470%28VS.85%29.aspx
            HGDIOBJ:   "l", # (L) Handle to a GDI object.
            HGLOBAL:   "l", # (L) Handle to a global memory block.
            HHOOK:     "l", # (L) Handle to a hook. http://msdn.microsoft.com/en-us/library/ms632589%28VS.85%29.aspx
            HICON:     "l", # (L) Handle to an icon. http://msdn.microsoft.com/en-us/library/ms646973%28VS.85%29.aspx
            HINSTANCE: "l", # (L) Handle to an instance. This is the base address of the module in memory.
            # HMODULE and HINSTANCE are the same today, but were different in 16-bit Windows.
            HKEY:      "l", # (L) Handle to a registry key.
            HKL:       "l", # (L) Input locale identifier.
            HLOCAL:    "l", # (L) Handle to a local memory block.
            HMENU:     "l", # (L) Handle to a menu. http://msdn.microsoft.com/en-us/library/ms646977%28VS.85%29.aspx
            HMETAFILE: "l", # (L) Handle to a metafile. http://msdn.microsoft.com/en-us/library/dd145051%28VS.85%29.aspx
            HMODULE:   "l", # (L) Handle to an instance. Same as HINSTANCE today, but was different in 16-bit Windows.
            HMONITOR:  "l", # (L) ?andle to a display monitor. WinDef.h: if(WINVER >= 0x0500) typedef HANDLE HMONITOR;
            HPALETTE:  "l", # (L) Handle to a palette.
            HPEN:      "l", # (L) Handle to a pen. http://msdn.microsoft.com/en-us/library/dd162786%28VS.85%29.aspx
            HRESULT:   "l", # Return code used by COM interfaces. For more info, Structure of the COM Error Codes.
            # To test an HRESULT value, use the FAILED and SUCCEEDED macros.
            HRGN:      "l", # (L) Handle to a region. http://msdn.microsoft.com/en-us/library/dd162913%28VS.85%29.aspx
            HRSRC:     "l", # (L) Handle to a resource.
            HSZ:       "l", # (L) Handle to a DDE string.
            HWINSTA:   "l", # (L) Handle to a window station. http://msdn.microsoft.com/en-us/library/ms687096%28VS.85%29.aspx
            HWND:      "l", # (L) Handle to a window. http://msdn.microsoft.com/en-us/library/ms632595%28VS.85%29.aspx
            INT:       "i", # 32-bit signed integer. The range is -2147483648 through 2147483647 decimal.
            INT_PTR:   "i", # Signed integer type for pointer precision. Use when casting a pointer to an integer
            # to perform pointer arithmetic. BaseTsd.h:
            #if defined(_WIN64) typedef __int64 INT_PTR; #else typedef int INT_PTR;
            INT32:    "i", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            INT64:    "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            LANGID:   "n", # Language identifier. For more information, see Locales. WinNT.h: #typedef WORD LANGID;
            # See http://msdn.microsoft.com/en-us/library/dd318716%28VS.85%29.aspx
            LCID:     "i", # Locale identifier. For more information, see Locales.
            LCTYPE:   "i", # Locale information type. For a list, see Locale Information Constants.
            LGRPID:   "i", # Language group identifier. For a list, see EnumLanguageGroupLocales.
            LONG:     "l", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            LONG32:   "i", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            LONG64:   "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            LONGLONG: "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            LONG_PTR: "l", # Signed long type for pointer precision. Use when casting a pointer to a long to
            # perform pointer arithmetic. BaseTsd.h:
            #if defined(_WIN64) typedef __int64 LONG_PTR; #else typedef long LONG_PTR;
            LPARAM:   "l", # Message parameter. WinDef.h as follows: #typedef LONG_PTR LPARAM;
            LPBOOL:   "i", # Pointer to a BOOL. WinDef.h as follows: #typedef BOOL far *LPBOOL;
            LPBYTE:   "i", # Pointer to a BYTE. WinDef.h as follows: #typedef BYTE far *LPBYTE;
            LPCSTR:   "p", # Pointer to a constant null-terminated string of 8-bit Windows (ANSI) characters.
            # See Character Sets Used By Fonts. http://msdn.microsoft.com/en-us/library/dd183415%28VS.85%29.aspx
            LPCTSTR:  "p", # An LPCWSTR if UNICODE is defined, an LPCSTR otherwise.
            LPCVOID:  "v", # Pointer to a constant of any type. WinDef.h as follows: typedef CONST void *LPCVOID;
            LPCWSTR:  "P", # Pointer to a constant null-terminated string of 16-bit Unicode characters.
            LPDWORD:  "p", # Pointer to a DWORD. WinDef.h as follows: typedef DWORD *LPDWORD;
            LPHANDLE: "l", # Pointer to a HANDLE. WinDef.h as follows: typedef HANDLE *LPHANDLE;
            LPINT:    "I", # Pointer to an INT.
            LPLONG:   "L", # Pointer to an LONG.
            LPSTR:    "p", # Pointer to a null-terminated string of 8-bit Windows (ANSI) characters.
            LPTSTR:   "p", # An LPWSTR if UNICODE is defined, an LPSTR otherwise.
            LPVOID:   "v", # Pointer to any type.
            LPWORD:   "p", # Pointer to a WORD.
            LPWSTR:   "p", # Pointer to a null-terminated string of 16-bit Unicode characters.
            LRESULT:  "l", # Signed result of message processing. WinDef.h: typedef LONG_PTR LRESULT;
            PBOOL:    "i", # Pointer to a BOOL.
            PBOOLEAN: "i", # Pointer to a BOOL.
            PBYTE:    "i", # Pointer to a BYTE.
            PCHAR:    "p", # Pointer to a CHAR.
            PCSTR:    "p", # Pointer to a constant null-terminated string of 8-bit Windows (ANSI) characters.
            PCTSTR:   "p", # A PCWSTR if UNICODE is defined, a PCSTR otherwise.
            PCWSTR:    "p", # Pointer to a constant null-terminated string of 16-bit Unicode characters.
            PDWORD:    "p", # Pointer to a DWORD.
            PDWORDLONG: "L", # Pointer to a DWORDLONG.
            PDWORD_PTR: "L", # Pointer to a DWORD_PTR.
            PDWORD32:  "L", # Pointer to a DWORD32.
            PDWORD64:  "L", # Pointer to a DWORD64.
            PFLOAT:    "L", # Pointer to a FLOAT.
            PHALF_PTR: "L", # Pointer to a HALF_PTR.
            PHANDLE:   "L", # Pointer to a HANDLE.
            PHKEY:     "L", # Pointer to an HKEY.
            PINT:      "i", # Pointer to an INT.
            PINT_PTR:  "i", # Pointer to an INT_PTR.
            PINT32:    "i", # Pointer to an INT32.
            PINT64:    "i", # Pointer to an INT64.
            PLCID:     "l", # Pointer to an LCID.
            PLONG:     "l", # Pointer to a LONG.
            PLONGLONG: "l", # Pointer to a LONGLONG.
            PLONG_PTR: "l", # Pointer to a LONG_PTR.
            PLONG32:   "l", # Pointer to a LONG32.
            PLONG64:   "l", # Pointer to a LONG64.
            POINTER_32: "l", # 32-bit pointer. On a 32-bit system, this is a native pointer. On a 64-bit system, this is a truncated 64-bit pointer.
            POINTER_64: "l", # 64-bit pointer. On a 64-bit system, this is a native pointer. On a 32-bit system, this is a sign-extended 32-bit pointer.
            POINTER_SIGNED:   "l", # A signed pointer.
            HPSS: "l",
            POINTER_UNSIGNED: "l", # An unsigned pointer.
            PSHORT:     "l", # Pointer to a SHORT.
            PSIZE_T:    "l", # Pointer to a SIZE_T.
            PSSIZE_T:   "l", # Pointer to a SSIZE_T.
            PSS_CAPTURE_FLAGS: "l",
            PSTR:       "p", # Pointer to a null-terminated string of 8-bit Windows (ANSI) characters. For more information, see Character Sets Used By Fonts.
            PTBYTE:     "p", # Pointer to a TBYTE.
            PTCHAR:     "p", # Pointer to a TCHAR.
            PTSTR:      "p", # A PWSTR if UNICODE is defined, a PSTR otherwise.
            PUCHAR:     "p", # Pointer to a UCHAR.
            PUINT:      "i", # Pointer to a UINT.
            PUINT_PTR:  "i", # Pointer to a UINT_PTR.
            PUINT32:    "i", # Pointer to a UINT32.
            PUINT64:    "i", # Pointer to a UINT64.
            PULONG:     "l", # Pointer to a ULONG.
            PULONGLONG: "l", # Pointer to a ULONGLONG.
            PULONG_PTR: "l", # Pointer to a ULONG_PTR.
            PULONG32:   "l", # Pointer to a ULONG32.
            PULONG64:   "l", # Pointer to a ULONG64.
            PUSHORT:    "l", # Pointer to a USHORT.
            PVOID:      "v", # Pointer to any type.
            PWCHAR:     "p", # Pointer to a WCHAR.
            PWORD:      "p", # Pointer to a WORD.
            PWSTR:      "p", # Pointer to a null- terminated string of 16-bit Unicode characters.
            # For more information, see Character Sets Used By Fonts.
            SC_HANDLE:  "l", # (L) Handle to a service control manager database.
            SERVICE_STATUS_HANDLE: "l", # (L) Handle to a service status value. See SCM Handles.
            SHORT:     "i", # A 16-bit integer. The range is –32768 through 32767 decimal.
            SIZE_T:    "l", #  The maximum number of bytes to which a pointer can point. Use for a count that must span the full range of a pointer.
            SSIZE_T:   "l", # Signed SIZE_T.
            TBYTE:     "p", # A WCHAR if UNICODE is defined, a CHAR otherwise.TCHAR:
            # http://msdn.microsoft.com/en-us/library/c426s321%28VS.80%29.aspx
            TCHAR:     "p", # A WCHAR if UNICODE is defined, a CHAR otherwise.TCHAR:
            UCHAR:     "p", # Unsigned CHAR (8 bit)
            UHALF_PTR: "i", # Unsigned HALF_PTR. Use within a structure that contains a pointer and two small fields.
            UINT:      "i", # Unsigned INT. The range is 0 through 4294967295 decimal.
            UINT_PTR:  "i", # Unsigned INT_PTR.
            UINT32:    "i", # Unsigned INT32. The range is 0 through 4294967295 decimal.
            UINT64:    "i", # Unsigned INT64. The range is 0 through 18446744073709551615 decimal.
            ULONG:     "l", # Unsigned LONG. The range is 0 through 4294967295 decimal.
            ULONGLONG: "l", # 64-bit unsigned integer. The range is 0 through 18446744073709551615 decimal.
            ULONG_PTR: "l", # Unsigned LONG_PTR.
            ULONG32:   "i", # Unsigned INT32. The range is 0 through 4294967295 decimal.
            ULONG64:   "i", # Unsigned LONG64. The range is 0 through 18446744073709551615 decimal.
            UNICODE_STRING: "P", # Pointer to some string structure??
            USHORT:    "i", # Unsigned SHORT. The range is 0 through 65535 decimal.
            USN:    "l", # Update sequence number (USN).
            WCHAR:  "i", # 16-bit Unicode character. For more information, see Character Sets Used By Fonts.
            # In WinNT.h: typedef wchar_t WCHAR;
            #WINAPI: K,      # Calling convention for system functions. WinDef.h: define WINAPI __stdcall
            WORD: "i", # 16-bit unsigned integer. The range is 0 through 65535 decimal.
            WPARAM: "i",    # Message parameter. WinDef.h as follows: typedef UINT_PTR WPARAM;
            VOID:   "v", # Any type ? Only use it to indicate no arguments or no return value
            vKey: "i",
            LPRECT: "p",
            char: "p",
  }
  #----------------------------------------------------------------------------
  # • [Array] : Get the specified values on method. After, check out each one if is
  # String or Symbol.... If was Symbol will return at the specified value on
  # the constant TYPES;
  #  Exemplo: types([:BOOL, :WCHAR]) # ["i", "i"]
  #----------------------------------------------------------------------------
  def types(import)
    import2 = []
    import.each { |i|
     next if i.is_a?(NilClass) or i.is_a?(String)
     import2 <<  TYPES[i]
    }
    return import2
  end
  #----------------------------------------------------------------------------
  # • [INT] : Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #----------------------------------------------------------------------------
  def int(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "i") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value|
        define_method(key) { |*vls|
          vls = vls.is_a?(Array) ? vls : [vls]
          value.collect! { |i| i = i.nil? ? vls.shift : i }
          api.call(*value)
        }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  alias :bool :int
  #----------------------------------------------------------------------------
  # • [LONG] : Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #----------------------------------------------------------------------------
  def long(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "l") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value|
        define_method(key) { |*vls|
          vls = vls.is_a?(Array) ? vls : [vls]
          value.collect! { |i| i = i.nil? ? vls.shift : i }
          api.call(*value)
        }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [VOID] : Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #----------------------------------------------------------------------------
  def void(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "v") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value|
        define_method(key) { |*vls|
          vls = vls.is_a?(Array) ? vls : [vls]
          value.collect! { |i| i = i.nil? ? vls.shift : i }
          api.call(*value)
        }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [CHAR] : Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #----------------------------------------------------------------------------
  def char(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "p") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value|
        define_method(key) { |*vls|
          vls = vls.is_a?(Array) ? vls : [vls]
          value.collect! { |i| i = i.nil? ? vls.shift : i }
          api.call(*value)
        }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [Dll]// : You can specified a dll function
  #   function(export, function, import, dll)
  #    export : exportation value. Format [Symbol]
  #    function : dll function
  #    import : importation value
  #    dll : dll, for default is 'user32'
  # Exemplo: function(:int, "ShowCursor", [:BOOL]).call(0) # hide the mouse
  #----------------------------------------------------------------------------
  def function(export, function, import, dll="user32")
    eval("#{export}(function, import, dll)")
  end
  #----------------------------------------------------------------------------
  # • Especificando o método protegido.
  #----------------------------------------------------------------------------
  # Métodos privados.
  private :long, :int, :char, :void, :types
  #----------------------------------------------------------------------------
  # • [CopyFile]/Dll : Função da DLL Kernel32 que permite copiar arquivos.
  #    CopyFile.call(filename_to_copy, filename_copied, replace)
  #      filename_to_copy : Formato [String]
  #      filename_copied : Formato [String]
  #      replace : Formato [Integer] 0 - false 1 - true
  #   Exemplo: CopyFile.call("System/RGSS300.dll", "./RGSS300.dll", 1)
  #----------------------------------------------------------------------------
  CopyFile = long("CopyFile", [:LPCTSTR, :LPCTSTR, :BOOL], "kernel32")
  #----------------------------------------------------------------------------
  # • [Beep]/Dll : Emitir uma frequência de um som do sistema com duração.
  #    Beep.call(freq, duration)
  #      freq : Formato [Integer\Hexadécimal]
  #      duration : Formato [Integer\Hexadécimal]
  #    Exemplo: Beep.call(2145, 51)
  #----------------------------------------------------------------------------
  Beep = long('Beep', [:DWORD, :DWORD], 'kernel32')
  #----------------------------------------------------------------------------
  # • [keybd_event]/Dll : Ela é usada para sintentizar uma combinação de teclas.
  #    KEYBD_EVENT.call(vk, scan, fdwFlags, dwExtraInfo)
  #      vk : Formato [Integer/Hexadécimal].
  #      scan : Formato [Integer]
  #      fdwFlags : Formato [Integer]
  #      dwExtraInfo : Formato [Integer]
  #    Exemplo: KEYBD_EVENT.call(0x01, 0, 0, 0)
  #----------------------------------------------------------------------------
  KEYBD_EVENT = void('keybd_event', [:BYTE, :BYTE, :DWORD, :ULONG_PTR])
  #----------------------------------------------------------------------------
  # • Função de limpar memória.
  #    Permite definir por um comando eval algo que aconteça antes.
  #    Permite definir com um bloco, algo que aconteça no processo.
  #----------------------------------------------------------------------------
  def clearMemory(deval="", &block)
    eval(deval) unless deval.empty? and !deval.is_a?(String)
    KEYBD_EVENT.call(0x7B, 0, 0, 0)
    block.call if block_given?
    sleep(0.1)
    KEYBD_EVENT.call(0x7B, 0, 2, 0)
  end
  #----------------------------------------------------------------------------
  # • Full screen
  #----------------------------------------------------------------------------
  def full_screen
    KEYBD_EVENT.(18, 0, 0, 0)
    KEYBD_EVENT.(18, 0, 0, 0)
    KEYBD_EVENT.(13, 0, 0, 0)
    KEYBD_EVENT.(13, 0, 2, 0)
    KEYBD_EVENT.(18, 0, 2, 0)
  end
  #----------------------------------------------------------------------------
  # • [GetKeyState]/Dll : Pega o status da chave.
  #    GetKeyState.call(vk)
  #      vk : Formato [Integer/Hexadécimal].
  #   Exemplo: GetKeyState.call(0x01)
  #----------------------------------------------------------------------------
  GetKeyState    = int('GetAsyncKeyState', [:int])
  #----------------------------------------------------------------------------
  # • [MapVirtualKey] : Traduz (maps) o código de uma key para um código
  # escaneado ou o valor de um character.
  #----------------------------------------------------------------------------
  MapVirtualKey = int("MapVirtualKey", [:UINT, :UINT])
  #----------------------------------------------------------------------------
  # • [MouseShowCursor]/Dll : Mostrar ou desativar o cusor do Mouse.
  #    MouseShowCursor.call(value)
  #     value : Formato [Integer] 0 - false 1 - true
  #   Exemplo: MouseShowCursor.call(0)
  #----------------------------------------------------------------------------
  MouseShowCursor = int("ShowCursor", [:int])
  #----------------------------------------------------------------------------
  # • [CursorPosition]/Dll : Obtem a posição do cursor do Mouse na tela.
  #     CursorPosition.call(lpPoint)
  #      lpPoint : Formato [Array]
  #   Ex: CursorPosition.call([0, 0].pack('ll'))
  #----------------------------------------------------------------------------
  CursorPosition = int('GetCursorPos', [:LPPOINT])
  #----------------------------------------------------------------------------
  # • [ScreenToClient]/Dll : Converte as coordenadas da tela para um ponto
  # em especifico da área da tela do cliente.
  #     ScreenToClient.call(hWnd, lpPoint)
  #----------------------------------------------------------------------------
  ScreenToClient = int('ScreenToClient', [:HWND, :LPPOINT])
  #----------------------------------------------------------------------------
  # • [GetPrivateProfileString]/Dll : */Ainda não explicado./*
  #----------------------------------------------------------------------------
  GetPrivateProfileString = long('GetPrivateProfileStringA', [:LPCTSTR, :LPCTSTR, :LPCTSTR, :LPTSTR, :DWORD, :LPCTSTR], 'kernel32')
  #----------------------------------------------------------------------------
  # • [FindWindow]/Dll : Recupera o identificador da janela superior. Cujo
  # o nome da janela é o nome da classe da janela se combina com as cadeias
  # especificas.
  #    FindWindow.call(lpClassName,  lpWindowName)
  #      lpClassName : Formato [String]
  #      lpWindowName : Formato [String]
  #----------------------------------------------------------------------------
  FindWindow = long('FindWindowA', [:LPCTSTR, :LPCTSTR])
  #----------------------------------------------------------------------------
  # • [Handle]/Dll : Retorna ao Handle da janela.
  #----------------------------------------------------------------------------
  def hWND(game_title=nil)
    return API::FindWindow.call('RGSS Player', game_title || load_data("Data/System.rvdata2").game_title.to_s) rescue nil
  end
  #----------------------------------------------------------------------------
  # • [Handle]/Dll : Retorna ao Handle da janela. Método protegido.
  #----------------------------------------------------------------------------
  def hwnd(*args)
    hWND(*args)
  end
  #----------------------------------------------------------------------------
  # • [ReadIni]/Dll : */Ainda não explicado./*
  #----------------------------------------------------------------------------
  ReadIni = GetPrivateProfileString
  #----------------------------------------------------------------------------
  # • [SetWindowPos]/Dll : Modifica os elementos da janela como, posição, tamanho.
  #----------------------------------------------------------------------------
  SetWindowPos = int("SetWindowPos", [:HWND, :HWND, :int, :int, :int, :int, :UINT])
  #----------------------------------------------------------------------------
  # • [GetWindowRect]/Dll : Obtem as dimensões do retângulo da janela.
  #    GetWindowRect.call(hWnd, lpRect)
  #----------------------------------------------------------------------------
  GetWindowRect = int('GetWindowRect', [:HWND, :LPRECT])
  #----------------------------------------------------------------------------
  # • [StateKey]/Dll : Retorna ao status específico da chave.
  #    StateKey.call(VK)
  #      VK : Formato [Integer/Hexadécimal].
  #----------------------------------------------------------------------------
  StateKey = int("GetKeyState", [:int])
  #----------------------------------------------------------------------------
  # • [SetCursorPos]/Dll : Move o cursor do Mouse para um ponto específico
  # da tela.
  #    SetCursorPos.call(x, y)
  #     x, y : Formato [Integer/Float]
  #----------------------------------------------------------------------------
  SetCursorPos  = int("SetCursorPos", [:long, :long])
  #----------------------------------------------------------------------------
  # • [GetKeyboardState]/Dll : Cópia o status das 256 chaves para um
  # buffer especificado.
  #----------------------------------------------------------------------------
  GetKeyboardState =  Win32API.new('user32', 'GetKeyboardState', ['P'], 'V')
  #----------------------------------------------------------------------------
  # • [GetAsyncKeyState]/Dll : Determina o estado da chave no momento em que a
  # função é chamada.
  #    GetAsyncKeyState.call(Vk)
  #     VK : Formato [Integer/Hexadécimal].
  #----------------------------------------------------------------------------
  GetAsyncKeyState = int('GetAsyncKeyState', [:int])
  #----------------------------------------------------------------------------
  # • [WideCharToMultiByte] : [MultiByteToWideChar] // Comentários
  # não adicionados.
  #----------------------------------------------------------------------------
  WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
  #----------------------------------------------------------------------------
  # • [AdjustWindowRect] : Calcula o tamanho requerido do retângulo da Janela.
  #----------------------------------------------------------------------------
  AdjustWindowRect = int("AdjustWindowRect", [:LPRECT, :DWORD, :BOOL])
  #----------------------------------------------------------------------------
  # • Constantes [SetWindowPos]
  #----------------------------------------------------------------------------
  SWP_ASYNCWINDOWPOS = 0x4000
  # Desenha os frames (definidos na classe da janela descrita) em torno na janela.
  SWP_DRAWFRAME = 0x0020
  # Esconde a janela.
  SWP_HIDEWINDOW = 0x0080
  # Não pode ser ativada nem movida
  SWP_NOACTIVATE = 0x0010
  # Não permite mover
  SWP_NOMOVE = 0x0002
  # Não permite redimensionar
  SWP_NOSIZE = 0x0001
  # Mostra a Janela
  SWP_SHOWWINDOW = 0x0040
  # Coloca a janela na parte inferior na ordem de Z. Se identificar uma janela
  # superior ela perde os seus status.
  HWND_BOTTOM = 1
  # Coloca a janela acima de todas as janelas que não estão em primeiro plano.
  HWND_NOTOPMOST = -2
  # Poem a janela no Topo na ordem de Z.
  HWND_TOP = 0
  # Poem a janela acima de todas que não estão em primeiro plano. Mantendo a
  # posição.
  HWND_TOPMOST = -1
  #----------------------------------------------------------------------------
  # • [SetActiveWindow]/ Dll : Ativa a Window.
  #----------------------------------------------------------------------------
  SetActiveWindow = long("SetActiveWindow", [:HWND])
  #----------------------------------------------------------------------------
  # • WindowFromPoint : Retorna ao handle da janela, que contém um ponto
  # específico.
  #----------------------------------------------------------------------------
  WindowFromPoint = long("WindowFromPoint", [:HWND])
  #----------------------------------------------------------------------------
  # • ShowWindow : Mostra a janela em um estado específico.
  #----------------------------------------------------------------------------
  ShowWindow = long("ShowWindow", [:HWND, :LONG])
  # Força a janela a minimizar
  SW_FORCEMINIMIZE = 11
  # Esconde a janela, ativa outra.
  SW_HIDE = 0
  # Maximiza a janela.
  SW_MAXIMIZE = 3
  # Minimiza a janela
  SW_MINIMIZE = 6
  # Restaura o estado da janela.
  SW_RESTORE = 9
  # Ativa a janela a mostrando na posição original.
  SW_SHOW = 5
  #----------------------------------------------------------------------------
  # • [SetWindowText] : Permite modificar o título da janela.
  #----------------------------------------------------------------------------
  SetWindowText = int("SetWindowText", [:HWND, :LPCTSTR])
  #----------------------------------------------------------------------------
  # • [GetDesktopWindow] : Retorna ao handle da janela em relação ao Desktop.
  #----------------------------------------------------------------------------
  GetDesktopWindow = long("GetDesktopWindow", [:HWND])
  #----------------------------------------------------------------------------
  # • [GetSystemMetric] : Obtem um sistema métrico específico ou a configuração
  # do sistema. As dimensões retornadas são em pixel.
  #----------------------------------------------------------------------------
  GetSystemMetric = int("GetSystemMetric", [:int])
  #----------------------------------------------------------------------------
  # • [GetSystemMetric]/Constantes:
  #----------------------------------------------------------------------------
  #  Obtem a flag que especifica como o sistema está organizando as janelas
  # minimizadas.
  SM_ARRANGE = 56
  # Obtem o tamanho da borda da Janela em pixel.
  SM_CXBORDER = 5
  # Valor do tamanho da área do cliente pra uma Janela em modo de tela-chéia.
  # em pixel.
  SM_CXFULLSCREEN = 16
  # Para mais informações dos valores, visite :
  #  http://msdn.microsoft.com/en-us/library/windows/desktop/ms724385(v=vs.85).aspx
  #----------------------------------------------------------------------------
  # • [GetClientRect] : Retorna ao rect da área da Janela.
  # Uses :
  #   lpRect = [0,0,0,0].pack("L*")
  #   GetClientRect.(hwnd, lpRect)
  #   lpRect = lpRect.unpack("L*")
  #----------------------------------------------------------------------------
  GetClientRect = int("GetClientRect", [:HWND, :LPRECT])
  #----------------------------------------------------------------------------
  # • [GetModuleHandle] : Retorna ao Handle do módulo, do módulo específicado.
  # Pode ser aquivo '.dll' ou '.exe'. Exemplo:
  #  GetModuleHandle.call('System/RGSS300.dll')
  #----------------------------------------------------------------------------
  GetModuleHandle = long("GetModuleHandle", [:LPCTSTR], "kerne32")
  #----------------------------------------------------------------------------
  # • [FreeLibrary] : Libera o módulo que está carregado na DLL específica.
  #----------------------------------------------------------------------------
  FreeLibrary = long("FreeLibrary", [:HMODULE], "kernel32")
  #----------------------------------------------------------------------------
  # • [LoadLibrary] : Carrega um endereço de um módulo em específico.
  # LoadLibrary.call(Nome da Libraria(dll/exe))
  #   [Handle] : Retorna ao valor do Handle do módulo caso der certo.
  #----------------------------------------------------------------------------
  LoadLibrary = long("LoadLibrary", [:LPCTSTR], "kernel32")
  #----------------------------------------------------------------------------
  # • [GetProcAddress] : Retorna ao endereço da função exportada ou a variável
  # de uma DLL específica.
  #  GetProcAddress.call(hModule, lpProcName)
  #   hModule : É o valor do handle. Você pode pega-lo usando o LoadLibrary
  #   lpProcName : A função ou o nome da variável.
  #----------------------------------------------------------------------------
  GetProcAddress = long("GetProcAddress", [:HMODULE, :LPCSTR], "kernel32")
  #----------------------------------------------------------------------------
  # • [GetSystemMetrics] : Retorna á uma configuração específica do sistema
  # métrico.
  #----------------------------------------------------------------------------
  GetSystemMetrics = int("GetSystemMetrics", [:int])
  #----------------------------------------------------------------------------
  # • [GetSystemMetrics]::Constantes. #Para mais visite:
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724385(v=vs.85).aspx
  #----------------------------------------------------------------------------
  SM_CXSCREEN = 0 # O tamanho(width/largura) da janela em pixel.
  SM_CYSCREEN = 1 # O tamanho(height/comprimento) da janela em pixel.
  SM_CXFULLSCREEN = 16 # O tamanho da largura da tela chéia da janela.
  SM_CYFULLSCREEN = 17 # O tamanho do comprimento da tela chéia da janela.
  #----------------------------------------------------------------------------
  # • [SetPriorityClass] : Definir a classe prioritária para um processo
  # específico.
  #   Para ver os processo e tal : Link abaixo.
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms686219(v=vs.85).aspx
  #----------------------------------------------------------------------------
  SetPriorityClass = int("SetPriorityClass", [:HANDLE, :DWORD], "kernel32")
  #----------------------------------------------------------------------------
  # • [InternetOpenA] : Inicializa o uso de uma aplicação, de uma função da
  # WinINet.
  #----------------------------------------------------------------------------
  InternetOpenA = function(:int, "InternetOpenA", [:LPCTSTR, :DWORD, :LPCTSTR, :LPCTSTR, :DWORD], "wininet")
  #----------------------------------------------------------------------------
  # • [RtlMoveMemory] : Movimenta um bloco de memoria para outra locação.
  #----------------------------------------------------------------------------
  RtlMoveMemory = function(:int, "RtlMoveMemory", [:char, :char, :int], "kernel32")
  #----------------------------------------------------------------------------
  # • [ShellExecute] :
  #----------------------------------------------------------------------------
  ShellExecute = long("ShellExecute", [:LPCTSTR, :LPCTSTR, :LPCTSTR,
                                      :LPCTSTR, :LPCTSTR, :LONG], "Shell32.dll")
  #----------------------------------------------------------------------------
  # • [Método protegido] : Método usado para chamar a função LoadLibrary.
  #----------------------------------------------------------------------------
  def dlopen(name, fA=nil)
    l = LoadLibrary.(String(name))
    return l if fA.nil?
    return GetProcAddress.(l, String(fA))
  end
  #----------------------------------------------------------------------------
  # • Converte um texto para o formato UTF-8
  #    textUTF(text)
  #      * text : Texto.
  #----------------------------------------------------------------------------
  def textUTF(text)
    wC = MultiByteToWideChar.call(65001, 0, text, -1, "", 0)
    MultiByteToWideChar.call(65001, 0, text, -1, text = "\0\0" * wC, wC)
    return text
  end
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Retorna verdadeiro caso o Caps Lock esteja
  # ativo e retorna Falso caso não esteja ativo.
  #----------------------------------------------------------------------------
  def get_caps_lock
    return int("GetKeyState", [:vKey]).call(20) == 1
  end
  #----------------------------------------------------------------------------
  # • Abre a URL de um site o direcionado para o navegador padrão do usuário.
  #----------------------------------------------------------------------------
  def open_site(url)
    c = Win32API.new("Shell32", "ShellExecute", "pppppl", "l")
    c.call(nil, "open", url, nil, nil, 0)
  end
  #----------------------------------------------------------------------------
  # • Valor dá base é o endereço. Pegar a variável.
  # base = 0x10000000
  # adr_loc_ram(0x25EB00 + 0x214, val, base)
  #----------------------------------------------------------------------------
  def adr_loc_ram(adr, val, base)
    return DL::CPtr.new(base + adr)[0, val.size] = size
  end
  #----------------------------------------------------------------------------
  # • protected methods
  #----------------------------------------------------------------------------
  protected :hwnd, :open, :function
end
}
#==============================================================================
# • API::MessageBox
#==============================================================================
Ligni.register(:messagebox, "ligni", 1.0, [[:api, "ligni"]]) {
module API::MessageBox; extend self;
    MessageBoxW =  Win32API.new("user32", "MessageBoxW", "lppl", "l")
    #--------------------------------------------------------------------------
    # • [Constantes] Buttons:
    #--------------------------------------------------------------------------
    # added three button : Annull, repeat e ignore
    ABORTRETRYIGNORE = 0x00000002
    # Cancel, try and continue
    CANCELTRYCONTINUE = 0x00000006
    # help's button
    HELP = 0x00004000
    # ok's button
    SOK = 0x00000000
    # cancel and ok buttons
    OKCANCEL = 0x00000001
    # repeat and cancel buttons
    RETRYCANCEL = 0x00000005
    # yes and no buttons
    YESNO = 0x00000004
    # yes, no and cancel buttons
    YESNOCANCEL = 0x00000003
    #--------------------------------------------------------------------------
    # • [Constantes] Icons:
    #--------------------------------------------------------------------------
    # exclamation's icon
    ICONEXCLAMATION = 0x00000030
    # information's icon
    ICONINFORMATION = 0x00000040
    # interrogation point's button
    ICONQUESTION = 0x00000020
    # stop's button
    ICONSTOP = 0x00000010
    #--------------------------------------------------------------------------
    # • [Constantes] Values of the button return
    #--------------------------------------------------------------------------
    ABORT = 3 # to annull
    CANCEL = 2 # to cancel
    CONTINUE = 11 # to continue
    IGNORE = 5 # to ignore
    NO = 7 # to no
    OK = 1 # to ok
    RETRY = 4 # to repeat
    TRYAGAIN = 10 # to try again
    YES = 6 # to yes
    #--------------------------------------------------------------------------
    # • [Constantes] Additional values
    #--------------------------------------------------------------------------
    RIGHT = 0x00080000 # the texts will be align on the right side
    TOPMOST = 0x00040000 # style as WB_EX_TOPMOST
    #--------------------------------------------------------------------------
    # • [call] : Return to the button's values. For be used as condition, if it was clicked
    #   API::MessageBox.call(title, string, format)
    #    title -> box's title
    #    string -> box's content
    #    format -> format box
    #--------------------------------------------------------------------------
    def call(title, string, format)
      return MessageBoxW.call(API.hWND, API.textUTF(string), API.textUTF(title), format)
    end
end 
}
#==============================================================================
# • API::PNG
#==============================================================================
Ligni.register(:png, "ligni", 1.0, [[:api, "ligni"]]) {
module API::PNG; extend self 
    private
    #--------------------------------------------------------------------------
    # • Criar o header do arquivo
    #--------------------------------------------------------------------------
    def make_header(file)
      # Número mágico
      file.write([0x89].pack('C'))
      # PNG
      file.write([0x50, 0x4E, 0x47].pack('CCC'))
      # Fim de linha estilo DOS para verificação de conversão DOS - UNIX
      file.write([0x0D, 0x0A].pack('CC'))
      # Caractere de fim de linha (DOS)
      file.write([0x1A].pack('C'))
      # Caractere de fim de linha (UNIX)
      file.write([0x0A].pack('C'))
    end
    #--------------------------------------------------------------------------
    # • Aquisição da soma mágica
    #--------------------------------------------------------------------------
    def checksum(string)
      Zlib.crc32(string)
    end
    #--------------------------------------------------------------------------
    # • Criação do chunk de cabeçalho
    #--------------------------------------------------------------------------
    def make_ihdr(bitmap, file)
      data = ''
      # Largura
      data += [bitmap.width, bitmap.height].pack('NN')
      # Bit depth (???)
      data += [0x8].pack('C')
      # Tipo de cor
      data += [0x6].pack('C')
      data += [0x0, 0x0, 0x0].pack('CCC')
      # Tamanho do chunk
      file.write([data.size].pack('N'))
      # Tipo de chunk
      file.write('IHDR')
      file.write(data)
      # Soma mágica
      file.write([checksum('IHDR' + data)].pack('N'))
    end
    #--------------------------------------------------------------------------
    # • Criação do chunk de dados
    #--------------------------------------------------------------------------
    def make_idat(bitmap, file)
      data = ''
      for y in 0...bitmap.height
        data << "\0"
        for x in 0...bitmap.width
          color = bitmap.get_pixel(x, y)
          data << [color.red, color.green, color.blue, color.alpha].pack('C*')
        end
      end
      # Desinflamento (jeito legal de dizer compressão...) dos dados
      data = Zlib::Deflate.deflate(data)
      # Tamanho do chunk
      file.write([data.size].pack('N'))
      # Tipo de chunk
      file.write('IDAT')
      # Dados (a imagem)
      file.write(data)
      # Soma mágica
      file.write([checksum('IDAT' + data)].pack('N'))
    end
    #--------------------------------------------------------------------------
    # • Criação do chunk final.
    #--------------------------------------------------------------------------
    def make_iend(file)
      # Tamanho do chunk
      file.write([0].pack('N'))
      # Tipo de chunk
      file.write('IEND')
      # Soma mágica
      file.write([checksum('IEND')].pack('N'))
    end
    public
    #--------------------------------------------------------------------------
    # • Salvar :
    #     bitmap : Bitmap.
    #     filename : Nome do arquivo.
    #--------------------------------------------------------------------------
    def save(bitmap, filename)
      # Verificar se tem a extenção .png
      filename = filename.include?(".png") ? filename : filename << ".png"
      # Criação do arquivo
      file = File.open(filename, 'wb')
      # Criação do cabeçalho
      make_header(file)
      # Criação do primeiro chunk
      make_ihdr(bitmap, file)
      # Criação dos dados
      make_idat(bitmap, file)
      # Criação do final
      make_iend(file)
      file.close
    end
end
}
#==============================================================================
# • API::Find
#==============================================================================
Ligni.register(:find, "ligni", 1.0, [[:api, "ligni"]]) {
class API::Find 
    #--------------------------------------------------------------------------
    # • instance variables
    #--------------------------------------------------------------------------
    attr_accessor :dir
    attr_accessor :files
    attr_accessor :folders
    attr_accessor :type
    #--------------------------------------------------------------------------
    # • Main direction
    #--------------------------------------------------------------------------
    def self.env
      env = ENV['USERPROFILE'].gsub("\\", "/")
      return {
        desktop:      env + "/Desktop", # Desktop diretório.
        recent:       env + "/Recent", # Recent diretório.
        drive:        ENV["HOMEDRIVE"], # Diretório do Drive.
        doc:          env + "/Documents", # Diretório dos documento.
        current:      Dir.getwd,          # Diretório da atual.
      }
    end
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize(direction=Dir.getwd)
      @dir = String(direction)
      @files = []
      @folders = []
      setup
    end
    #--------------------------------------------------------------------------
    # • Configuração.
    #--------------------------------------------------------------------------
    def setup
      @files = []
      @folders = []
      for data in Dir[@dir+"/*"]
        if FileTest.directory?(data)
          @folders << data
        else
          @files << data
        end
      end
    end
    #--------------------------------------------------------------------------
    # • [Array] return to all files
    #--------------------------------------------------------------------------
    def all_files
      @folders + @files
    end
    #--------------------------------------------------------------------------
    # • Move to another dir
    #--------------------------------------------------------------------------
    def move_to(dir)
      @dir = File.expand_path(@dir + "/#{dir}")
      setup
    end
    #--------------------------------------------------------------------------
    # • Move to main dir.
    #--------------------------------------------------------------------------
    def move_to_dir(sym)
      @dir = API::FindDir.env.get(sym)
      setup
    end
    # condition if is it not the drive folder
    def ret
      @dir != API::FindDir.env.get(:drive)
    end
end 
}
#==============================================================================
# • API::FindPlus
#==============================================================================
Ligni.register(:findplus, "ligni", 1.0, [[:api, "ligni"]]) {
class API::FindPlus
  #----------------------------------------------------------------------------
  # • [Array] : Irá retornar a todos os nomes dos arquivos da pasta, dentro de
  # uma Array em formato de String.
  #----------------------------------------------------------------------------
  attr_accessor :file
  #----------------------------------------------------------------------------
  # • [Integer] : Retorna a quantidade total de arquivos que têm na pasta.
  #----------------------------------------------------------------------------
  attr_reader   :size
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #     directory : Nome da pasta. Não ponha '/' no final do nome. Ex: 'Data/'
  #     typefile : Nome da extensão do arquivo. Não ponha '.' no começo. Ex: '.txt'
  #----------------------------------------------------------------------------
  def initialize(directory, typefile)
    return unless FileTest.directory?(directory)
    @file = Dir.glob(directory + "/*.{" + typefile + "}")
    @file.each_index { |i| @size = i.to_i }
    @name = split @file[0]
  end
  #----------------------------------------------------------------------------
  # • [String] : Separar o nome do arquivo do nome da pasta.
  #----------------------------------------------------------------------------
  def split(file)
    file.to_s.split('/').last
  end
  #----------------------------------------------------------------------------
  # • [String] : Obtêm o nome do arquivo correspondente ao id configurado,
  # separado do nome da pasta.
  #----------------------------------------------------------------------------
  def name(id)
    return if @file.nil?
    return split(@file[id])
  end
end
}
#==============================================================================
# • API::Network
#==============================================================================
Ligni.register(:network, "ligni", 1.0, [[:api, "ligni"]]) {
module API::Network 
    include API
    extend self
    #--------------------------------------------------------------------------
    # • [InternetGetConnectedState] : Verifica o estado de conexão da internet.
    #--------------------------------------------------------------------------
    InternetGetConnectedState = int("InternetGetConnectedState", [:LPDWORD, :DWORD], "wininet.dll")
    #--------------------------------------------------------------------------
    # • [URLDownloadToFile] : Baixa um arquivo direto de um link da internet.
    #--------------------------------------------------------------------------
    URLDownloadToFile = int("URLDownloadToFile", [:LPCTSTR, :LPCTSTR, :LPCTSTR,
                                                :int, :int], "urlmon.dll")
    #--------------------------------------------------------------------------
    # • Check out if is it connected with web
    #--------------------------------------------------------------------------
    def connected?
      InternetGetConnectedState.call(' ', 0) == 0x01
    end
    #--------------------------------------------------------------------------
    # • Download a file by the url link
    #     url : file's link
    #     dest : destiny direction
    #     open : open the file after download
    #
    # • Example:
    #     url = "http://www.news2news.com/vfp/downloads/w32data.zip"
    #     dstfile = "w32data.zip"
    #     URLDownloadToFile.run(url, dstfile)
    #--------------------------------------------------------------------------
    def link_download(url, dest, open = false)
      return unless connected?
      hresult = URLDownloadToFile.call(NIL, url, dest, 0, 0)
      if (hresult == 0)
        return true unless open
        Shellxecute.call(nil, "open", dest, nil, nil, 1)
        return true
      else
        raise("URLDownloadToFile call failed: %X\n", hresult)
      end
    end
end 
}
#==============================================================================
# • API::Powershell
#==============================================================================
Ligni.register(:powershell, "ligni", 1.0) {
module API::Powershell; extend self
  #----------------------------------------------------------------------------
  # • Command
  #----------------------------------------------------------------------------
  def run(cmd)
    system("powershell.exe " << cmd)
  end
  #----------------------------------------------------------------------------
  # • Baixar arquivos da internet com a função wget
  #     link : url
  #     output : filename and dest
  #     ext : commands
  #       -v : show progress.
  #       -c : continuar;
  #       -b : in background
  #----------------------------------------------------------------------------
  def wget(link, output, ext="-v")
    cmd = "wget #{ext} #{link} -OutFile #{output}"
    self.run(cmd)
  end
end
}
#==============================================================================
# • Ligni::Key
#==============================================================================
Ligni.register(:key, "ligni", 1.0) {
module Ligni::Key; extend self 
  attr_accessor :_cacheText # Armazena os textos.
  #----------------------------------------------------------------------------
  # • Texto do cache
  #----------------------------------------------------------------------------
  def text; return @_cacheText; end
  alias :to_s :text
    KEY = {
    # Chaves diversas.
    CANCEL: 0x03, BACKSPACE: 0x08, TAB: 0x09, CLEAR: 0x0C,
    ENTER: 0x0D, SHIFT: 0x10, CONTROL: 0x11, MENU: 0x12,
    PAUSE: 0x13, ESC: 0x1B, CONVERT: 0x1C, NONCONVERT: 0x1D,
    ACCEPT: 0x1E, SPACE: 0x20, PRIOR: 0x21, NEXT: 0x22,
    ENDS: 0x23, HOME: 0x24, LEFT: 0x25, UP: 0x26, RIGHT: 0x27,
    DOWN: 0x28, SELECT: 0x29, PRINT: 0x2A, EXECUTE: 0x2B,
    SNAPSHOT: 0x2C, DELETE: 0x2E, HELP: 0x2F, LSHIFT: 0xA0, RSHIFT: 0xA1,
    LCONTROL: 0xA2, RCONTROL: 0xA3, LALT: 0xA4, RALT: 0xA5, PACKET: 0xE7,
    # MOUSE
    MOUSE_RIGHT: 0x01, MOUSE_LEFT: 0x02, MOUSE_MIDDLE: 0x04, X1: 0x05, X2: 0x06,
    # Chaves de números.
    N0: 0x30, N1: 0x31, N2: 0x32, N3: 0x33, N4: 0x34, N5: 0x35, N6: 0x36,
    N7: 0x37, N8: 0x38, N9: 0x39,
    # Chaves de letras.
    A: 0x41, B: 0x42, C: 0x43, D: 0x44, E: 0x45,
    F: 0x46, G: 0x47, H: 0x48, I: 0x49, J: 0x4A,
    K: 0x4B, L: 0x4C, M: 0x4D, N: 0x4E, O: 0x4F,
    P: 0x50, Q: 0x51, R: 0x52, S: 0x53, T: 0x54,
    U: 0x55, V: 0x56, W: 0x57, X: 0x58, Y: 0x59,
    Z: 0x5A, Ç: 0xBA,
    # Chaves do window.
    LWIN: 0x5B, RWIN: 0x5C, APPS: 0x5D, SLEEP: 0x5F, BROWSER_BACK: 0xA6,
    BROWSER_FORWARD: 0xA7, BROWSER_REFRESH: 0xA8, BROWSER_STOP: 0xA9,
    BROWSER_SEARCH: 0xAA, BROWSER_FAVORITES: 0xAB, BROWSER_HOME: 0xAC,
    VOLUME_MUTE: 0xAD, VOLUME_DOWN: 0xAE, VOLUME_UP: 0xAF,
    MEDIA_NEXT_TRACK: 0xB0, MEDIA_PREV_TRACK: 0xB1, MEDIA_STOP: 0xB2,
    MEDIA_PLAY_PAUSE: 0xB3, LAUNCH_MAIL: 0xB4, LAUNCH_MEDIA_SELECT: 0xB5,
    LAUNCH_APP1: 0xB6, LAUNCH_APP2: 0xB7, PROCESSKEY: 0xE5, ATIN: 0xF6,
    CRSEL: 0xF7, EXSEL: 0xF8, EREOF: 0xF9, PLAY: 0xFA, ZOOM: 0xFB,
    PA1: 0xFD,
    # Chaves do NUMPAD
    NUMPAD0: 0x60, NUMPAD1: 0x61, NUMPAD2: 0x62,
    NUMPAD3: 0x63, NUMPAD4: 0x64, NUMPAD5: 0x65,
    NUMPAD6: 0x66, NUMPAD7: 0x67, NUMPAD8: 0x68, NUMPAD9: 0x69,
    MULTIPLY: 0x6A, ADD: 0x6B, SEPARATOR: 0x6C,
    SUBTRACT: 0x6D, DECIMAL: 0x6E, DIVIDE: 0x6F,
    # Caches de função.
    F1: 0x70, F2: 0x71, F3: 0x72, F4: 0x73, F5: 0x74, F6: 0x75,
    F7: 0x76, F8: 0x77, F9: 0x78, F10: 0x79, F11: 0x7A, F12: 0x7B,
    F13: 0x7C, F14: 0x7D, F15: 0x7E, F16: 0x7F, F17: 0x80, F18: 0x81,
    F19: 0x82, F20: 0x83, F21: 0x84, F22: 0x85, F23: 0x86, F24: 0x87,
    # Chaves alternativas.
    CAPS: 0x14, INSERT: 0x2D, NUMLOCK: 0x90, SCROLL: 0x91,
    # Chaves OEM, variadas.
    OEM_1: 0xC1, OEM_PLUS: 0xBB, OEM_COMMA: 0xBC,
    OEM_MINUS: 0xBD,  OEM_PERIOD: 0xBE,
    OEM_2: 0xBF, QUOTE: 0xC0,
    ACCUTE: 0xDB, OEM_6: 0xDD, OEM_7: 0xDC, TIL: 0xDE,
    OEM_102: 0xE2, OEM_CLEAR: 0xFE,
  }
  #----------------------------------------------------------------------------
  # • Chave dos números. (Símbolos)
  #----------------------------------------------------------------------------
  KEY_NUMBER = %W(NUMPAD0 NUMPAD1 NUMPAD2 NUMPAD3 NUMPAD4 NUMPAD5 NUMPAD6
  NUMPAD7 NUMPAD8 NUMPAD9 N0 N1 N2 N3 N4 N5 N6 N7 N8 N9 MULTIPLY OEM_PERIOD
  OEM_COMMA ADD SEPARATOR DIVIDE SUBTRACT DECIMAL).collect!(&:intern)
  SPECIAL_CHAR_NUMBER = {
    N1: %w(! ¹), N2: %w(@ ²), N3: %w(# ³), N4: %w($ £),
    N5: %w(% ¢), N6: %w(¨ ¬), N7: %w(&), N8: %w(*),
    N9: ["("], N0: [")"], OEM_PERIOD: %w(>), OEM_COMMA: %w(<)
  }
  #----------------------------------------------------------------------------
  # • Chave das letras. (Símbolos)
  #----------------------------------------------------------------------------
  KEY_CHAR = %W(A B C D E F G H I J L K M N O P Q R S T U V W X Y Z Ç).collect!(&:intern)
  KEY_CHAR_ACCUTE = %W(A E I O U Y).collect!(&:intern)
  KEY_CHAR_ACCUTE_STR = {
   UPCASE: {
    A: %w(Â Ã À Á), E: %w(Ê ~E È É), I: %w(Î ~I Ì Í), O: %w(Ô Õ Ò Ó),
    Y: %w(^Y ~Y `Y Ý), U: %w(Û ~U Ù Ú)
   },
   DOWNCASE: {
    A: %w(â ã à á), E: %w(ê ~e è é), I: %w(î ~i ì í), O: %w(ô õ ò ó),
    Y: %w(^y ~y `y ý), U: %w(û ~u ù ú)
   }
  }
  #----------------------------------------------------------------------------
  # • Chaves especiais.
  #----------------------------------------------------------------------------
  KEY_SPECIAL = %w(SPACE OEM_1 OEM_PLUS OEM_MINUS OEM_2
  OEM_6 OEM_7 OEM_102).collect!(&:intern)
  SKEY_SPECIAL = {
    OEM_1: %w(? °), OEM_2: %w(:), OEM_7: %w(} º), OEM_6: %w({ ª),
    OEM_PLUS: %w(+ §), OEM_MINUS: %w(_), OEM_102: %w(|)
  }
  #----------------------------------------------------------------------------
  # • Chaves especiais. [^~ ´` '"]
  #----------------------------------------------------------------------------
  KEY_SPECIAL2 = %w(ACCUTE TIL QUOTE N6).collect!(&:intern)
  #----------------------------------------------------------------------------
  # • Variáveis do módulo.
  #----------------------------------------------------------------------------
  @_cacheText = ""
  @til = 0
  @tils = false
  @accute = 0
  @accutes = false
  @unpack_string = 'b'*256
  @last_array = '0'*256
  @press = Array.new(256, false)
  @trigger = Array.new(256, false)
  @repeat = Array.new(256, false)
  @release = Array.new(256, false)
  @repeat_counter = Array.new(256, 0)
  @getKeyboardState = API::GetKeyboardState
  @getAsyncKeyState = API::GetAsyncKeyState
  @getKeyboardState.call(@last_array)
  @last_array = @last_array.unpack(@unpack_string)
  for i in 0...@last_array.size
    @press[i] = @getAsyncKeyState.call(i) == 0 ? false : true
  end
  #----------------------------------------------------------------------------
  # • Atualização.
  #----------------------------------------------------------------------------
  def update
    @trigger = Array.new(256, false)
    @repeat = Array.new(256, false)
    @release = Array.new(256, false)
    array = '0'*256
    @getKeyboardState.call(array)
    array = array.unpack(@unpack_string)
    for i in 0...array.size
      if array[i] != @last_array[i]
        @press[i] = @getAsyncKeyState.call(i) == 0 ? false : true
        if @repeat_counter[i] <= 0 && @press[i]
          @repeat[i] = true
          @repeat_counter[i] = 15
        end
        if !@press[i]
          @release[i] = true
        else
          @trigger[i] = true
        end
      else
        if @press[i] == true
          @press[i] = @getAsyncKeyState.call(i) == 0 ? false : true
          @release[i] = true if !@press[i]
        end
        if @repeat_counter[i] > 0 && @press[i] == true
          @repeat_counter[i] -= 1
        elsif @repeat_counter[i] <= 0 && @press[i] == true
          @repeat[i] = true
          @repeat_counter[i] = 3
        elsif @repeat_counter[i] != 0
          @repeat_counter[i] = 0
        end
      end
    end
    @last_array = array
  end
  #--------------------------------------------------------------------------
  # * [TrueClass/FalseClass] Obter o estado quando a chave for pressionada.
  #     key : key index
  #--------------------------------------------------------------------------
  def press?(key)
    return @press[ key.is_a?(Symbol) ?  KEY.get(key) : key ]
  end
  #--------------------------------------------------------------------------
  # * [TrueClass/FalseClass] Obter o estado quando a chave for teclada.
  #     key : key index
  #--------------------------------------------------------------------------
  def trigger?(key)
    return @trigger[ key.is_a?(Symbol) ?  KEY.get(key) : key ]
  end
  #--------------------------------------------------------------------------
  # * [TrueClass/FalseClass] Obter o estado quando a chave for teclada repetidamente.
  #     key : key index
  #--------------------------------------------------------------------------
  def repeat?(key)
    return @repeat[ key.is_a?(Symbol) ?  KEY.get(key) : key ]
  end
  #--------------------------------------------------------------------------
  # * [TrueClass/FalseClass] Obter o estado quando a chave for "lançada"
  #     key : key index
  #--------------------------------------------------------------------------
  def release?(key)
    return @release[ key.is_a?(Symbol) ?  KEY.get(key) : key ]
  end
  #----------------------------------------------------------------------------
  # • [String] Obtêm a string correspondente à tecla do número. Às Strings ficará
  # armazenada na varíavel _cacheText
  #----------------------------------------------------------------------------
  def get_number(special=false)
    KEY_NUMBER.each { |key|
      unless special
        next @_cacheText.concat(API::MapVirtualKey.call(KEY.get(key), 2)) if trigger?(key)
      else
        if shift?
          next @_cacheText += SPECIAL_CHAR_NUMBER[key][0] || ""  if trigger?(key)
        elsif ctrl_alt?
          next @_cacheText += SPECIAL_CHAR_NUMBER[key][1] || ""  if trigger?(key)
        else
          next @_cacheText.concat(API::MapVirtualKey.call(KEY.get(key), 2)) if trigger?(key)
        end
      end
    }
  end
  #----------------------------------------------------------------------------
  # • [String] Obtêm a string correspondente à tecla do teclado pressionado.
  # Às Strings ficará armazenada na varíavel _cacheText
  #----------------------------------------------------------------------------
  def get_string(backslash=:trigger)
    get_number(true)
    KEY_CHAR.each { |key|
      next unless trigger?(key)
      x = "".concat(API::MapVirtualKey.call(KEY.get(key), 2))
      if @tils
        n = shift? ? 0 : 1 if @tils
        x = KEY_CHAR_ACCUTE_STR[caps? ? :UPCASE : :DOWNCASE][key][n] || "" if KEY_CHAR_ACCUTE.include?(key) and !n.nil?
        @tils = false
        @accutes = false
      elsif @accutes
        n = shift? ? 2 : 3 if @accutes
        x = KEY_CHAR_ACCUTE_STR[caps? ? :UPCASE : :DOWNCASE][key][n] || "" if KEY_CHAR_ACCUTE.include?(key) and !n.nil?
        @tils = false
        @accutes = false
      end
      @_cacheText += (caps? ? x : x.downcase)
    }
    KEY_SPECIAL.each { |key|
      if shift?
        next @_cacheText += SKEY_SPECIAL[key][0] || ""  if trigger?(key)
      elsif ctrl_alt?
        next @_cacheText += SKEY_SPECIAL[key][1] || ""  if trigger?(key)
      else
        next @_cacheText.concat(API::MapVirtualKey.call(KEY.get(key), 2)) if trigger?(key)
      end
    }
    KEY_SPECIAL2.each { |key|
      if trigger?(key)
        if key == :TIL
          @tils = !@tils
          @accutes = false  if @tils
        elsif key == :ACCUTE
          @accutes = !@accutes
          @tils = false if @accutes
        end
        @til = @til == 3 ? @til : @til + 1 if key == :TIL
        @accute = @accute == 3 ? @accute : @accute + 1 if key == :ACCUTE
        if shift?
          next @_cacheText += '"' if key == :QUOTE
          next unless @til == 3 or @accute == 3
          @_cacheText += "^" if key == :TIL
          @_cacheText += "`" if key == :ACCUTE
          next @til = 0 if key == :TIL
          next @accute = 0 if key == :ACCUTE
        else
          next @_cacheText.concat(API::MapVirtualKey.call(KEY.get(key), 2)) if key == :QUOTE
          next unless @til == 3 or @accute == 3
          @_cacheText += "~" if key == :TIL
          @_cacheText += "´" if key == :ACCUTE
          next @til = 0 if key == :TIL
          next @accute = 0 if key == :ACCUTE
        end
      end
    }
    if backslash == :press
      @_cacheText = @_cacheText.backslash if press?(:BACKSPACE)
    else
      @_cacheText = @_cacheText.backslash if repeat?(:BACKSPACE)
    end
    @_cacheText += " " * 4 if trigger?(:TAB)
  end
  #----------------------------------------------------------------------------
  # • Verificar se o CAPS LOCK está ativado ou desativado.
  #----------------------------------------------------------------------------
  def caps?
    API.get_caps_lock
  end
  #----------------------------------------------------------------------------
  # • Verificar se o Shift está pressionado
  #----------------------------------------------------------------------------
  def shift?
    press?(:SHIFT)
  end
  #----------------------------------------------------------------------------
  # • Verificar se o CTRL + ALT está pressionado.
  #----------------------------------------------------------------------------
  def ctrl_alt?
    (press?(:LCONTROL) and press?(:LALT)) or press?(:RALT)
  end
  #----------------------------------------------------------------------------
  # • [Boolean] : Retorna true caso alguma tecla foi teclada.
  #----------------------------------------------------------------------------
  def any?
    Ligni::Key::KEY.each_value  { |i|
      next if i == 25
      return true if trigger?(i)
    }
    return false
  end
  #----------------------------------------------------------------------------
  # • Para movimento WSAD
  #----------------------------------------------------------------------------
  def wsad
    return 8 if press?(:W)
    return 4 if press?(:A)
    return 6 if press?(:D)
    return 2 if press?(:S)
    return 0
  end
end
}
#==============================================================================
# ҉ Behaviour
#==============================================================================
# Módulo com o intuito de ser incluído dentro de classes para que seus
# métodos sejam utilizados com facilidade.
#==============================================================================
Ligni.register(:behaviour, "ligni", 1.0) {
module Ligni::Behaviour
  extend self
  #----------------------------------------------------------------------------
  # • Constantes
  #----------------------------------------------------------------------------
	InvokeData = {
		list: [],
		identifier: [],
		repeating_list: [],
		repeating_identifier: []
	}
  #----------------------------------------------------------------------------
  # • main_update
  #----------------------------------------------------------------------------
	def main_update
		for i in 0...InvokeData[:list].size
			if InvokeData[:list][i].done?
				InvokeData[:list].delete_at(i)
				InvokeData[:identifier].delete_at(i)
			else
				InvokeData[:list][i].update
			end
		end
		for i in 0...InvokeData[:repeating_list].size
			InvokeData[:repeating_list][i].update
		end
	end
  #----------------------------------------------------------------------------
  # • invoke
  #----------------------------------------------------------------------------
	def invoke(main_class, met, time, *args)
		m = main_class.method(met)
		InvokeData[:identifier].push(met)
		InvokeData[:list].push(Ligni::Invoke.new(m, time, *args))
	end
	#----------------------------------------------------------------------------
  # • invoke_repeating
  #----------------------------------------------------------------------------
	def invoke_repeating(main_class, met, time, repeat, *args)
		m = main_class.method(met)
		InvokeData[:repeating_identifier].push(met)
		InvokeData[:repeating_list].push(Ligni::InvokeRepeating.new(m, time, repeat, *args))
	end
	#----------------------------------------------------------------------------
  # • cancel_invoke
  #----------------------------------------------------------------------------
	def cancel_invoke(identifier)
		index = InvokeData[:identifier].index(identifier)
		return if index.nil?
		InvokeData[:list].delete_at(index)
		InvokeData[:identifier].delete_at(index)
	end
	#----------------------------------------------------------------------------
  # • cancel_invoking
  #----------------------------------------------------------------------------
	def cancel_invoking(identifier)
		index = InvokeData[:repeating_identifier].index(identifier)
		return if index.nil?
		InvokeData[:repeating_list].delete_at(index)
		InvokeData[:repeating_identifier].delete_at(index)
	end
	#----------------------------------------------------------------------------
  # • cancel_invoke_all
  #----------------------------------------------------------------------------
	def cancel_invoke_all
		InvokeData[:list].clear
		InvokeData[:identifier].clear
		InvokeData[:repeating_list].clear
		InvokeData[:repeating_identifier].clear
	end
  #----------------------------------------------------------------------------
  # • Rápidas chamadas de métodos.
  #----------------------------------------------------------------------------
  def abs(num); return num.abs; end
  def sqr(num); return Math.sqrt(num); end
  def sin(num); return Math.sin(num); end
  def cos(num); return Math.cos(num); end
  def deg(num); return num * Ligni::Mathf::Rad2Deg; end
  def rad(num); return num * Ligni::Mathf::Deg2Rad; end
  def vec(x, y); return Ligni::Vector.new(x, y); end
  def neg(num); return num.is_a?(Ligni::Vector) ? num.neg : -num; end

end
}
#==============================================================================
# ҉ Invoke
#==============================================================================
# Classe responsável pela invocação de um método em determinados segundos.
#==============================================================================
Ligni.register(:invoke, "ligni", 1.0) {
class Ligni::Invoke

  #----------------------------------------------------------------------------
  # • initialize
  #----------------------------------------------------------------------------
	def initialize(met, time, *args)
		@met = met
		@args = *args
		@time = time
		@done = false
	end
	#----------------------------------------------------------------------------
  # • update
  #----------------------------------------------------------------------------
	def update
		return if done?
		@time = Ligni::Mathf.move_towards(@time, 0, 0.016667)
		if can_invoke?
			@met.call(*@args)
			@done = true
		end
	end
	#----------------------------------------------------------------------------
  # • can_invoke?
  #----------------------------------------------------------------------------
	def can_invoke?
		return @time <= 0
	end
	#----------------------------------------------------------------------------
  # • done?
  #----------------------------------------------------------------------------
	def done?
		return @done == true
	end

end
}
#==============================================================================
# ҉ InvokeRepeating
#==============================================================================
# Classe responsável pela invocação de um método repetidamente em
# determinados segundos.
#==============================================================================
Ligni.register(:invoke_repeating, "ligni", 1.0) {
class Ligni::InvokeRepeating

  #----------------------------------------------------------------------------
  # • initialize
  #----------------------------------------------------------------------------
	def initialize(met, time, repeat, *args)
		@met = met
		@time = time
		@max_repeat = repeat
		@repeat_count = 0
		@args = *args
	end
	#----------------------------------------------------------------------------
  # • update
  #----------------------------------------------------------------------------
	def update
		@time = Ligni::Mathf.move_towards(@time, 0, 0.016667)
		if can_start_invoking? && @repeat_count <= 0
			@met.call(*@args)
			@repeat_count = @max_repeat
		end
		if @repeat_count > 0
			@repeat_count = Ligni::Mathf.move_towards(@repeat_count, 0, 0.016667)
		end
	end
	#----------------------------------------------------------------------------
  # • can_start_invoking?
  #----------------------------------------------------------------------------
	def can_start_invoking?
		return @time <= 0
	end

end
}
#==============================================================================
# ҉ Mathf
#==============================================================================
# Uma coleção de cálculos matemáticos comuns.
#==============================================================================
Ligni.register(:mathf, "ligni", 1.0) {
module Ligni::Mathf
	extend self
  #----------------------------------------------------------------------------
  # • Constantes
  #----------------------------------------------------------------------------
	Deg2Rad           = 0.0174532924
	Rad2Deg           = 57.29578
	Epsilon           = Float::EPSILON
	Infinity          = Float::INFINITY
	Negative_Infinity = -Float::INFINITY
	#----------------------------------------------------------------------------
  # • approximately
  #----------------------------------------------------------------------------
	def approximately(a, b)
		return (b - a).abs * [10 - 6.0 * [a.abs, b.abs].max, Epsilon * 8.0].max
	end
	#----------------------------------------------------------------------------
  # • clamp
  #----------------------------------------------------------------------------
	def clamp(value, min, max)
		return value < min ? min : value > max ? max : value
	end
	#----------------------------------------------------------------------------
  # • clamp01
  #----------------------------------------------------------------------------
	def clamp01(value)
		return value < 0.0 ? 0.0 : value > 1.0 ? 1.0 : value
	end
	#----------------------------------------------------------------------------
  # • clamp_reset
  #----------------------------------------------------------------------------
	def clamp_reset(value, min, max)
		return value < min ? max : value > max ? min : value
	end
	#----------------------------------------------------------------------------
  # • closest_power_of_two
  #----------------------------------------------------------------------------
	def closest_power_of_two(int)
		return 0 if int <= 0
		exp = Math.log2(int)
		hp = 2 ** exp.ceil
		lp = 2 ** exp.floor
		return (hp - int) <= (int - lp) ? hp : lp
	end
	#----------------------------------------------------------------------------
  # • repeat
  #----------------------------------------------------------------------------
	def repeat(t, length)
		return t - (t / length).floor * length
	end
	#----------------------------------------------------------------------------
  # • lerp
  #----------------------------------------------------------------------------
	def lerp(a, b, t)
		return a + (b - a) * clamp01(t)
	end
	#----------------------------------------------------------------------------
  # • lerp_unclamped
  #----------------------------------------------------------------------------
	def lerp_unclamped(a, b, t)
		return a + (b - a) * t
	end
	#----------------------------------------------------------------------------
  # • lerp_angle
  #----------------------------------------------------------------------------
	def lerp_angle(a, b, t)
		num = repeat(b - a, 360.0)
		if num > 180.0
			num -= 360.0
		end
		return a + num * clamp01(t)
	end
	#----------------------------------------------------------------------------
  # • sign
  #----------------------------------------------------------------------------
	def sign(f)
		return (f < 0.0) ? -1.0 : 1.0
	end
	#----------------------------------------------------------------------------
  # • delta_angle
  #----------------------------------------------------------------------------
	def delta_angle(current, target)
		num = repeat(target - current, 360.0)
		num -= 360.0 if num > 180.0
		return num
	end
	#----------------------------------------------------------------------------
  # • move_towards
  #----------------------------------------------------------------------------
	def move_towards(current, target, max_delta)
		result = 0
		if (target - current).abs <= max_delta
			result = target
		else
			result = current + sign(target - current) * max_delta
		end
		return result
	end
	#----------------------------------------------------------------------------
  # • move_towards_angle
  #----------------------------------------------------------------------------
	def move_towards_angle(current, target, max_delta)
		num = delta_angle(current, target)
		result = 0
		if -max_delta < num && num < max_delta
			result = target
		else
			target = current + num
			result = move_towards(current, target, max_delta)
		end
		return result
	end
  #----------------------------------------------------------------------------
  # • smooth_step
  #----------------------------------------------------------------------------
	def smooth_step(from, to, t)
		t = clamp01(t)
		t = -2.0 * t * t * t + 3.0 * t * t
		return to * t + from * (1.0 - t)
	end
	#----------------------------------------------------------------------------
  # • [Boolean] : Verifica se a posição é igual.
  #----------------------------------------------------------------------------
  def equal_pos?(a, b)
    (a.x == b.x) && (a.y == b.y)
  end
  #----------------------------------------------------------------------------
  # • [Float] : Cálcula a raíz quadrada que qualquer grau.
  #       n : Número que será calculado.
  #       g : Grau da raíz.
  # Dmath.sqrt(27, 3) # Cálculo da raíz cúbica de 27 => 3.0
  #----------------------------------------------------------------------------
  def sqrt(n, g)
    raise(ArgumentError) if n < 0 && n.is_evan?
    x, count, num = 1.0, 0.0, 0.0
    while
      num = x - ( ( x ** g - n ) / ( g * ( x ** g.pred ) ) )
      (x == num) || (count > 20) ? break : eval("x = num; count += 1")
    end
    return num
  end
   #----------------------------------------------------------------------------
  # • [Array] : Centralizar um objeto n'outro.
  #    object : Objeto, tem que ser do tipo [Sprite] ou [Window_Base]
  #    object_for_centralize : Objeto que irá se centralizar no 'object', tem
  # que ser do tipo [Sprite] ou [Window_Base]
  # * Retorna a uma Array contendo as informações das novas posições em X e Y.
  #----------------------------------------------------------------------------
  def centralize_object(object, object_for_centralize)
    x = object.x + (object.width - object_for_centralize.width) / 2
    y = object.y + (object.height - object_for_centralize.height) / 2
    return x, y
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Centralizar um objeto n'outro, obtendo somente a posição X.
  #    objectx : Valor da posição X do objeto número 1.
  #    objectwidth : Valor da largura do objeto número 1.
  #    object_for_centralizewidth : Valor da largura do objeto que irá se
  # centralizar no objeto número 1.
  # * Retorna ao valor da posição X.
  #----------------------------------------------------------------------------
  def centralize_x(objectx, objectwidth, object_for_centralizewidth)
    return objectx + (objectwidth - object_for_centralizewidth) / 2
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Centralizar um objeto n'outro, obtendo somente a posição Y.
  #    objecty : Valor da posição Y do objeto número 1.
  #    objectheight : Valor da altura do objeto número 1.
  #    object_for_centralizeheight : Valor da altura do objeto que irá se
  # centralizar no objeto número 1.
  # * Retorna ao valor da posição Y.
  #----------------------------------------------------------------------------
  def centralize_y(objecty, objectheight, object_for_centralizeheight)
    return objecty + (objectheight - object_for_centralizeheight) / 2
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Obter a posição X do centro da tela referente a largura do objeto X.
  # Exemplo: get_x_center_screen(sprite.width) : Irá retornar ao valor da posição
  # X para que o objeto fique no centro da tela.
  # Exemplo: sprite.x = get_x_center_screen(sprite.width)
  #----------------------------------------------------------------------------
  def get_x_center_screen(width)
    return (Graphics.width - width) / 2
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Obter a posição Y do centro da tela referente a altura do objeto X.
  # Exemplo: get_y_center_screen(sprite.height) : Irá retornar ao valor da posição
  # Y para que o objeto fique no centro da tela.
  # Exemplo: sprite.y = get_y_center_screen(sprite.height)
  #----------------------------------------------------------------------------
  def get_y_center_screen(height)
    return (Graphics.height - height) / 2
  end
  #--------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : check out if it is a inside of circle area
  #    object : Objeto do tipo da classe [Sprite].
  #    object2 : Objeto do tipo da classe [Sprite].
  #    size : Tamanho geral do círculo.
  #--------------------------------------------------------------------------
  def circle(object, object2, size)
    ( (object.x - object2.x) ** 2) + ( (object.y - object2.y) ** 2) <= (size ** 2)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : grau expression
  #----------------------------------------------------------------------------
  def graus
    360 / (2 * Math::PI)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : triangle area
  # x : x  : Posição x do ponto 1
  #     y  : Posição y do ponto 1
  #     x2 : Posição x do ponto 2
  #     y2 : Posição y do ponto 2
  #     x3 : Posição x do ponto 3
  #     y3 : Posição y do ponto 3
  #----------------------------------------------------------------------------
  def triangle_area(*args)
    x, y, x2, y2, x3, y3 = *args
    return (x2 - x) * (y3 - y) - (x3 - x) * (y2 - y)
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Eucledian method 1d
  #   p : Ponto A. [x, y]
  #   q : Ponto B. [x, y]
  #   euclidean_distance_1d(5, 1) #4
  #----------------------------------------------------------------------------
  def euclidean_distance_1d(p, q)
    return sqrt( (p - q) ** 2, 2 ).floor
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Eucledian method 2d
  #   p : Ponto A. [x, y]
  #   q : Ponto B. [x, y]
  #   euclidean_distance_2d([1, 3], [1, 5]) #2
  #----------------------------------------------------------------------------
  def euclidean_distance_2d(p, q)
    p = p.position unless p.is_a?(Position)
    q = q.position unless q.is_a?(Position)
    return sqrt( ((p.x - q.x) ** 2) + ((p.y - q.y) ** 2), 2 ).floor
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : on of the circle area
  #----------------------------------------------------------------------------
  def circle_in(t, b, c, d)
    return -c * (Math.sqrt(1 - (t /= d.to_f) * t) - 1) + b
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : out of the circle area
  #----------------------------------------------------------------------------
  def circle_out(t, b, c, d)
    return c * Math.sqrt(1 - (t=t/d.to_f-1)*t) + b
  end
  #----------------------------------------------------------------------------
  # • [Numeric] :
  # Return at the minimum value, from maximum value of 'min' & v, with
  # the maximum value
  #----------------------------------------------------------------------------
  def force_range(v, min, max)
    [[min, v].max, max].min
  end
  #----------------------------------------------------------------------------
  # • variation calculete number
  #----------------------------------------------------------------------------
  def random
    (1 + 2.aleatory) ** 0.125
  end
end
}
#==============================================================================
# ҉ Vector
#==============================================================================
# Representação de pontos e vectors 2D.
#==============================================================================
Ligni.register(:vector, "ligni", 1.0) {
class Ligni::Vector
  #----------------------------------------------------------------------------
  # • Variáveis de Instância Públicas
  #----------------------------------------------------------------------------
	attr_accessor :x
	attr_accessor :y
	#----------------------------------------------------------------------------
  # • Atalhos
  #----------------------------------------------------------------------------
	def self.up;    return Ligni::Vector.new(0, -1); end
	def self.left;  return Ligni::Vector.new(-1, 0); end
	def self.right; return Ligni::Vector.new(1, 0);  end
	def self.down;  return Ligni::Vector.new(0, 1);  end
	def self.one;   return Ligni::Vector.new(1, 1);  end
	def self.zero;  return Ligni::Vector.new(0, 0);  end
	#----------------------------------------------------------------------------
  # • angle
  #----------------------------------------------------------------------------
	def self.angle(from, to)
		return Math.atan2(to.y - from.y, to.x - from.x) * Ligni::Mathf::Rad2Deg
	end
	#----------------------------------------------------------------------------
  # • clamp_magnitude
  #----------------------------------------------------------------------------
	def self.clamp_magnitude(vector, max_length)
		if vector.sqr_magnitude > max_length * max_length
			result = vector.normalized * max_length
		else
			result = vector
		end
		return result
	end
	#----------------------------------------------------------------------------
  # • distance
  #----------------------------------------------------------------------------
	def self.distance(a, b)
		return (a - b).magnitude
	end
	#----------------------------------------------------------------------------
  # • scale
  #----------------------------------------------------------------------------
	def self.scale(a, b)
		return Ligni::Vector.new(a.x * b.x, a.y * b.y)
	end
	#----------------------------------------------------------------------------
  # • move_towards
  #----------------------------------------------------------------------------
	def self.move_towards(current, target, max_distance_delta)
		a = target - current
		magnitude = a.magnitude
		if magnitude <= max_distance_delta || magnitude == 0.0
			result = target
		else
			result = current + a / magnitude * max_distance_delta
		end
		return result
	end
	#----------------------------------------------------------------------------
  # • lerp
  #----------------------------------------------------------------------------
	def self.lerp(a, b, t)
		t = Ligni::Mathf.clamp01(t)
		return Ligni::Vector.new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
	end
	#----------------------------------------------------------------------------
  # • lerp_unclamped
  #----------------------------------------------------------------------------
	def self.lerp_unclamped(a, b, t)
		return Ligni::Vector.new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
	end
	#----------------------------------------------------------------------------
  # • move_by_bezier2
  #----------------------------------------------------------------------------
	def self.move_by_bezier2(start, control, ending, t)
		return (start * ((1 - t) * (1 - t))) + (control * (2 * t * (1 - t))) + ending * ((t * t))
	end
	#----------------------------------------------------------------------------
  # • move_by_bezier3
  #----------------------------------------------------------------------------
	def self.move_by_bezier3(start, control1, control2, ending, t)
		s = start
		st = control1
		et = control2
		e = ending
		return (((s.neg + ((st-et)*3) + e)* t + ((s+et)*3 - st*6))* t + (st-s)*3)* t + s
	end
	#----------------------------------------------------------------------------
  # • reflect
  #----------------------------------------------------------------------------
	def self.reflect(in_direction, in_normal)
		return in_direction + in_normal * -2.0 * Ligni::Vector.dot(in_normal, in_direction)
	end
	#----------------------------------------------------------------------------
  # • dot
  #----------------------------------------------------------------------------
	def self.dot(lhs, rhs)
		return lhs.x * rhs.x + lhs.y * rhs.y
	end
	#----------------------------------------------------------------------------
  # • min
  #----------------------------------------------------------------------------
	def self.min(lhs, rhs)
		return Ligni::Vector.new([lhs.x, rhs.x].min, [lhs.y, rhs.y].min)
	end
	#----------------------------------------------------------------------------
  # • max
  #----------------------------------------------------------------------------
	def self.max(lhs, rhs)
		return Ligni::Vector.new([lhs.x, rhs.x].max, [lhs.y, rhs.y].max)
	end
	#----------------------------------------------------------------------------
  # • initialize
  #----------------------------------------------------------------------------
	def initialize(x, y)
		@x = x
		@y = y
	end
	#----------------------------------------------------------------------------
  # • equals?
  #----------------------------------------------------------------------------
	def equals?(vector)
		if vector.is_a?(Ligni::Vector)
			return true if vector.x == @x && vector.y == @y
		end
		return false
	end
	#----------------------------------------------------------------------------
  # • normalize
  #----------------------------------------------------------------------------
	def normalize
		return if @x.zero? || @y.zero?
		len = magnitude
		@x /= len
		@y /= len
	end
	#----------------------------------------------------------------------------
  # • magnitude
  #----------------------------------------------------------------------------
	def magnitude
		return Math.sqrt((@x * @x) + (@y * @y))
	end
	#----------------------------------------------------------------------------
  # • sqr_magnitude
  #----------------------------------------------------------------------------
	def sqr_magnitude
		return @x * @x + @y * @y
	end
	#----------------------------------------------------------------------------
  # • normalized
  #----------------------------------------------------------------------------
	def normalized
		return Ligni::Vector.new(@x, @y).normalize
	end
	#----------------------------------------------------------------------------
  # • scale
  #----------------------------------------------------------------------------
	def scale(scale)
		@x *= scale.x
		@y *= scale.y
	end
	#----------------------------------------------------------------------------
  # • []
  #----------------------------------------------------------------------------
	def [](int)
		return int == 0 ? @x : int == 1 ? @y : nil
	end
	#----------------------------------------------------------------------------
  # • set
  #----------------------------------------------------------------------------
	def set(*args)
		if args.size == 1
			@x = args.x
			@y = args.y
		else
			@x = args[0]
			@y = args[1].nil? ? args[0] : args[1]
		end
	end
	#----------------------------------------------------------------------------
  # • to_string
  #----------------------------------------------------------------------------
	def to_string
		return "(#{@x.round(2)}, #{@y.round(2)})"
	end
	#----------------------------------------------------------------------------
  # • -
  #----------------------------------------------------------------------------
	def -(v)
		if v.respond_to?(:x) && v.respond_to?(:y)
			return Ligni::Vector.new(@x - v.x, @y - v.y)
		end
		return Ligni::Vector.new(@x - v, @y - v)
	end
	#----------------------------------------------------------------------------
  # • +
  #----------------------------------------------------------------------------
	def +(v)
		if v.respond_to?(:x) && v.respond_to?(:y)
			return Ligni::Vector.new(@x + v.x, @y + v.y)
		end
		return Ligni::Vector.new(@x + v, @y + v)
	end
	#----------------------------------------------------------------------------
  # • *
  #----------------------------------------------------------------------------
	def *(v)
		if v.respond_to?(:x) && v.respond_to?(:y)
			return Ligni::Vector.new(@x * v.x, @y * v.y)
		end
		return Ligni::Vector.new(@x * v, @y * v)
	end
	#----------------------------------------------------------------------------
  # • /
  #----------------------------------------------------------------------------
	def /(v)
		if v.respond_to?(:x) && v.respond_to?(:y)
			return Ligni::Vector.new(@x / v.x, @y / v.y)
		end
		return Ligni::Vector.new(@x / v, @y / v)
	end
	#----------------------------------------------------------------------------
  # • neg
  #----------------------------------------------------------------------------
	def neg
		return Ligni::Vector.new(-@x, -@y)
	end
	#----------------------------------------------------------------------------
  # • clone
  #----------------------------------------------------------------------------
	def clone
		return Ligni::Vector.new(@x, @y)
	end
	#----------------------------------------------------------------------------
  # • perpendicular
  #----------------------------------------------------------------------------
	def perpendicular
		x = @x
		return Ligni::Vector.new(@y, -x)
	end
	
end
}
#==============================================================================
# ҉ Color
#==============================================================================
# Representação de cores em RGB.
#==============================================================================
Ligni.register(:ligni_color, "ligni", 1.0) {
class Ligni::Color < Color
  #----------------------------------------------------------------------------
  # • Atalhos
  #----------------------------------------------------------------------------
  def self.red;     return per(1, 0, 0, 1); end
  def self.green;   return per(0, 1, 0, 1); end
  def self.blue;    return per(0, 0, 1, 1); end
  def self.white;   return per(1, 1, 1, 1); end
  def self.black;   return per(0, 0, 0, 1); end
  def self.yellow;  return per(1, 0.921568632, 0.0156862754, 1); end
  def self.cyan;    return per(0, 1, 1, 1); end
  def self.magenta; return per(1, 0, 1, 1); end
  def self.gray;    return per(0.5, 0.5, 0.5, 1); end
  def self.grey;    return per(0.5, 0.5, 0.5, 1); end
  def self.clear;   return per(0, 0, 0, 0); end
  #----------------------------------------------------------------------------
  # • per
  #----------------------------------------------------------------------------
  def self.per(r, g, b, a = 1.0)
    m = 255.0
    return Ligni::Color.new(r*m, g*m, b*m, a*m)
  end
  #----------------------------------------------------------------------------
  # • hex
  #----------------------------------------------------------------------------
	def self.hex(color)
    a = [0, 0, 0, 255]
    i = 0
    color.scan(/../).map { |color| color.to_i(16) }.collect {|c|
      a[i] = c
      i += 1
    }
    return Ligni::Color.new(*a)
  end
	#----------------------------------------------------------------------------
  # • lerp
  #----------------------------------------------------------------------------
	def self.lerp(a, b, t)
    t = Ligni::Mathf.clamp01(t)
    return Ligni::Color.new(a.red + (b.red - a.red) * t, a.green + (b.green - a.green) * t, a.blue + (b.blue - a.blue) * t, a.alpha + (b.alpha - a.alpha) * t)
  end
	#----------------------------------------------------------------------------
  # • lerp_unclamped
  #----------------------------------------------------------------------------
	def self.lerp_unclamped(a, b, t)
    return Ligni::Color.new(a.red + (b.red - a.red) * t, a.green + (b.green - a.green) * t, a.b + (b.blue - a.blue) * t, a.alpha + (b.alpha - a.alpha) * t)
  end
	#----------------------------------------------------------------------------
  # • in_percentage
  #----------------------------------------------------------------------------
	def r; return self.red/255.0; end
  def g; return self.green/255.0; end
  def b; return self.blue/255.0; end
  def a; return self.alpha/255.0; end
	#----------------------------------------------------------------------------
  # • rgb_multiplied
  #----------------------------------------------------------------------------
	def rgb_multiplied(multiplier)
    return Ligni::Color.new(self.red * multiplier, self.green * multiplier, self.blue * multiplier, self.alpha)
  end
	#----------------------------------------------------------------------------
  # • alpha_multiplied
  #----------------------------------------------------------------------------
	def alpha_multiplied(multiplier)
    return Ligni::Color.new(self.red, self.green, self.blue, self.alpha * multiplier)
  end
	#----------------------------------------------------------------------------
  # • color_multiplied
  #----------------------------------------------------------------------------
	def color_multiplied(multiplier)
    return Ligni::Color.new(self.red * multiplier.red, self.green * multiplier.green, self.blue * multiplier.blue, self.alpha);
  end
	#----------------------------------------------------------------------------
  # • rgb_to_hsv
  #----------------------------------------------------------------------------
	def self.rgb_to_hsv(rgb_color, hsv)
    #hsv must be an array
    if rgb_color.b > rgb_color.g && rgb_color.b > rgb_color.r
      Ligni::Color.rgb_to_hsv_helper(4.0, rgb_color.b, rgb_color.r, rgb_color.g, hsv)
    elsif rgb_color.g > rgb_color.r
      Ligni::Color.rgb_to_hsv_helper(2.0, rgb_color.g, rgb_color.b, rgb_color.r, hsv)
    else
      Ligni::Color.rgb_to_hsv_helper(0.0, rgb_color.r, rgb_color.g, rgb_color.b, hsv)
    end
  end
	#----------------------------------------------------------------------------
  # • -> Private | rgb_to_hsv_helper
  #----------------------------------------------------------------------------
	def self.rgb_to_hsv_helper(offset, dominantcolor, colorone, colortwo, hsv)
    # hsv must be an array
    h = hsv[0]
    s = hsv[1]
    v = hsv[2]
    v = dominantcolor
    if v != 0.0
      num = 0.0
      if colorone > colortwo
        num = colortwo
      else
        num = colorone
      end
      num2 = v - num
      if num2 != 0
        s = num2 / v
        h = offset + (colorone - colortwo) / num2
      else
        s = 0.0
        h = offset + (colorone - colortwo)
      end
      if h < 0.0
        h += 1.0
      end
    else
      s = 0.0
      h = 0.0
    end
    hsv[0] = h
    hsv[1] = s
    hsv[2] = v
  end
	#----------------------------------------------------------------------------
  # • hsv_to_rgb
  #----------------------------------------------------------------------------
	def self.hsv_to_rgb(hsv, hdr = false)
    white = {red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0}
    h = hsv[0]
    s = hsv[1]
    v = hsv[2]
    if s == 0.0
      white[:red] = v
      white[:green] = v
      white[:blue] = v
    elsif v == 0.0
      white[:red] = 0.0
      white[:green] = 0.0
      white[:blue] = 0.0
    else
      white[:red] = 0.0
      white[:green] = 0.0
      white[:blue] = 0.0
      num = h * 6.0
      num2 = num.floor.to_i
      num3 = num - num2.to_f
      num4 = v * (1.0 - s)
      num5 = v * (1.0 - s * num3)
      num6 = v * (1.0 - s * (1.0 - num3))
      case num2 + 1
      when 0; white[:red] = v; white[:green] = num4; white[:blue] = num5
      when 1; white[:red] = v; white[:green] = num6; white[:blue] = num4
      when 2; white[:red] = num5; white[:green] = v; white[:blue] = num4
      when 3; white[:red] = num4; white[:green] = v; white[:blue] = num6
      when 4; white[:red] = num4; white[:green] = num5; white[:blue] = v
      when 5; white[:red] = num6; white[:green] = num4; white[:blue] = v
      when 6; white[:red] = v; white[:green] = num4; white[:blue] = num5
      when 7; white[:red] = v; white[:green] = num6; white[:blue] = num4
      end
      if !hdr
        white[:red] = Ligni::Mathf.clamp(white[:red], 0.0, 1.0)
        white[:green] = Ligni::Mathf.clamp(white[:green], 0.0, 1.0)
        white[:blue] = Ligni::Mathf.clamp(white[:blue], 0.0, 1.0)
      end
    end
    return Ligni::Color.per(white[:red], white[:green], white[:blue], white[:alpha])
  end
  #----------------------------------------------------------------------------
  # • correlated_color_temperature_to_rgb
  #----------------------------------------------------------------------------
  def correlated_color_temperature_to_rgb(kelvin)
    kelvin = Ligni::Mathf.clamp(kelvin, 1000, 40000) / 100
    r = 0
    g = 0
    b = 0
    calc = 0
    if kelvin <= 66
      r = 255
    else
      calc = kelvin - 60
      calc = 329.698727446 * (calc ** -0.1332047592)
      r = Ligni::Mathf.clamp(calc.to_i, 0, 255)
    end
    if kelvin <= 66
      calc = kelvin
      calc = 99.4708025861 * Math.log(calc) - 161.1195681661
      g = Ligni::Mathf.clamp(calc.to_i, 0, 255)
    else
      calc = kelvin - 60
      calc = 288.1221695283 * (calc ** -0.0755148492)
      g = Ligni::Mathf.clamp(calc.to_i, 0, 255)
    end
    if kelvin >= 66
      b = 255
    elsif kelvin <= 19
      b = 0
    else
      calc = kelvin - 10
      calc = 138.5177312231 * Math.log(calc) - 305.0447927307
      b = Ligni::Mathf.clamp(calc.to_i, 0, 255)
    end
    return Ligni::Color.new(r, g, b)
  end
  #----------------------------------------------------------------------------
  # • Retorna para Array 
  #----------------------------------------------------------------------------
  def to_a(includeAlpha=true)
    array = [self.red, self.green, self.blue]
    array += [self.alpha] if includeAlpha
    return array
  end
  #----------------------------------------------------------------------------
  # • Retorna para Hash 
  #----------------------------------------------------------------------------
  def to_h 
    return {
      red: self.red, green: self.green, blue: self.blue, alpha: self.alpha,
    }
  end
  #----------------------------------------------------------------------------
  # • Inverter cores
  #----------------------------------------------------------------------------
  def invert 
      return Ligni::Color.new(255 - self.red, 255 - self.green, 255 - self.blue)
  end
  #----------------------------------------------------------------------------
  # • Reverter valores das cores 
  #----------------------------------------------------------------------------
  def revert 
      return Ligni::Color.new(self.to_a.reverse)
  end
  #----------------------------------------------------------------------------
  # • [Color] : Sort the values on crescent ordem
  #    includeAlpha
  #----------------------------------------------------------------------------
  def crescent(includeAlpha=false)
    set(*to_a(includeAlpha).crescent)
  end
  #----------------------------------------------------------------------------
  # • [Color] : Sort the values on decrescent ordem
  #    includeAlpha
  #----------------------------------------------------------------------------
  def decrescent(includeAlpha=false)
    set(*to_a(includeAlpha).decrescent)
  end
  #----------------------------------------------------------------------------
  # • [Color] : add/less the percent of all values
  #     value : 0~100
  #     includeAlpha :
  #----------------------------------------------------------------------------
  def percent(value, includeAlpha=true)
    value = Ligni::Mathf.clamp(value, 0, 100)
    Ligni::Color.new(
      *to_a(includeAlpha).collect! { |i| i.to_p(value * 2.55, 255) }
    )
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : return the luminosity color
  #----------------------------------------------------------------------------
  def luminosity
    return to_a(false).each_with_index { |i, n| i * [0.21, 0.71, 0.07][n] }.alln?
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : return the media of all values
  #     includeAlpha
  #----------------------------------------------------------------------------
  def avarange(includeAlpha=true)
    n = includeAlpha ? 4 : 3
    return (to_a(includeAlpha).alln?) / n
  end
  #----------------------------------------------------------------------------
  # • [Color] : set out a random color
  #----------------------------------------------------------------------------
  def self.random
    return Ligni::Color.new(rand(256), rand(256), rand(256))
  end
end
}
#==============================================================================
# • Position.
#==============================================================================
Ligni.register(:position, "ligni", 1.0) {
class Ligni::Position
  #----------------------------------------------------------------------------
  # • Transform the position of a object, that must contain the variables:
  # x, y, width, height.
  #     pos : Set up here a tag.. follow bellow
  #     object : Object that need contain the variables x, y, width, height.
  # tags:
  # 0/:ul : Will be on upper-left corner
  # 1/:cx : Set up the X to the center screen
  # 2/:ur : Will be on upper-right corner
  # 3/:dl : Will be on the down-left corner
  # 4/:cy : Set up the Y to the center screen
  # 5/:dr : Will be on down-right corner
  # :center : Change the position to the center of screen
  # :center_left : Centralization at the left corner
  # :center_right : Centralization at the right corner
  # :center_up : Centralization at the up corner
  # :center_down : Centralization at the down corner
  #----------------------------------------------------------------------------
  def self.[](pos, object)
    return if object.nil? or pos.nil?
    return object.x, object.y = pos[0], pos[1] if pos.is_a?(Array)
    return object.x, object.y = pos.x, pos.y if pos.is_a?(Ligni::Position)
    case pos
    when 0 || :ul then object.x, object.y = 0, 0
    when 1 || :cx then object.x = Ligni::Mathf.get_x_center_screen(object.width)
    when 2 || :ur then object.x, object.y = Graphics.width - object.width, 0
    when 3 || :dl then object.x, object.y = 0, Graphics.height - object.height
    when 4 || :cy then object.y = Ligni::Mathf.get_y_center_screen(object.height)
    when 5 || :dr then object.x, object.y = Graphics.width - object.width, Graphics.height - object.height
    when :center
      object.x = (Graphics.width - object.width) / 2
      object.y = (Graphics.height - object.height) / 2
    when :center_left
      object.x = 0
      object.y = (Graphics.height - object.height) / 2
    when :center_right
      object.x = Graphics.width - object.width
      object.y = (Graphics.height - object.height) / 2
    when :center_up
      object.x = (Graphics.width - object.width) / 2
      object.y = 0
    when :center_down
      object.x = (Graphics.width - object.width) / 2
      object.y = Graphics.height - object.height
    end
  end
  #----------------------------------------------------------------------------
  # • Variáveis públicas da instância.
  #----------------------------------------------------------------------------
  attr_accessor :x  # Variável que retorna ao valor que indica a posição X.
  attr_accessor :y  # Variável que retorna ao valor que indica a posição Y.
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize(x, y)
    @x = x || 0
    @y = y || 0
  end
  #----------------------------------------------------------------------------
  # • Somar com outra posição.
  #----------------------------------------------------------------------------
  def +(position)
    position = position.position unless position.is_a?(Position)
    Position.new(self.x + position.x, self.y + position.y)
  end
  #----------------------------------------------------------------------------
  # • Subtrair com outra posição.
  #----------------------------------------------------------------------------
  def -(position)
    position = position.position unless position.is_a?(Position)
    Position.new(self.x - position.x, self.y - position.y)
  end
  #----------------------------------------------------------------------------
  # • Multiplicar com outra posição.
  #----------------------------------------------------------------------------
  def *(position)
    position = position.position unless position.is_a?(Position)
    Position.new(self.x * position.x, self.y * position.y)
  end
  #----------------------------------------------------------------------------
  # • Dividir com outra posição.
  #----------------------------------------------------------------------------
  def /(position)
    position = position.position unless position.is_a?(Position)
    return if (self.x or position.x or self.y or position.y) <= 0
    Position.new(self.x / position.x, self.y / position.y)
  end
  #----------------------------------------------------------------------------
  # • Comparar com outra posição.
  #----------------------------------------------------------------------------
  def ==(position)
    position = position.position unless position.is_a?(Position)
    return Ligni::Mathf.equal_pos?(self, position)
  end
  #----------------------------------------------------------------------------
  # • Distância de um ponto de posição com relação a outro.
  #     other : Outro ponto de posição.
  #----------------------------------------------------------------------------
  def distance(other)
    other = other.position unless other.is_a?(Position)
    (self.x - other.x).abs + (self.y - other.y).abs
  end
  #----------------------------------------------------------------------------
  # • Converter em string.
  #----------------------------------------------------------------------------
  def to_s(broken="\n")
    return "position x: #{self.x}#{broken}position y: #{self.y}"
  end
  #----------------------------------------------------------------------------
  # • Converter em array.
  #----------------------------------------------------------------------------
  def to_a
    return [@x, @y]
  end
  #----------------------------------------------------------------------------
  # • Converter em hash.
  #----------------------------------------------------------------------------
  def to_h
    return {x: @x, y: @y}
  end
  #----------------------------------------------------------------------------
  # • Clonar
  #----------------------------------------------------------------------------
  def clone
    return Ligni::Position.new(@x, @y)
  end
end
}
#==============================================================================
# • Rect
#==============================================================================
Ligni.register(:rect, "dax & gab!", 1.0) {
class Rect
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Check out if is anythin' on
  #----------------------------------------------------------------------------
  def in?(x, y)
    x.between?(self.x, self.x + self.width) &&
    y.between?(self.y, self.y + self.height)
  end
  #----------------------------------------------------------------------------
  # • [BooleanClass] : Each point by each point set out by you
  #     p : Point A.
  #     q : Point B.
  #  Rect.new(0, 0, 1, 1).step(1.0, 1.0) { |i, j| p [i, j] }
  #  [0.0, 0.0]
  #  [0.0, 1.0]
  #  [1.0, 0.0]
  #  [1.0, 1.0]
  #----------------------------------------------------------------------------
  def step(p=1, q=1)
    (self.x..(self.x + self.width)).step(p) { |i|
      (self.y..(self.y + self.height)).step(q) { |j|
        yield(i, j)
      }
    }
    return true
  end
  #----------------------------------------------------------------------------
  # • [Array] : To array values
  #----------------------------------------------------------------------------
  def to_a
    return [self.x, self.y, self.width, self.height]
  end
  #----------------------------------------------------------------------------
  # • [Hash] : To hash values
  #----------------------------------------------------------------------------
  def to_h
    return {x: self.x, y: self.y, width: self.width, height: self.height}
  end
  #----------------------------------------------------------------------------
  # • intercept rect with another rect class
  #----------------------------------------------------------------------------
  def intercept(rect)
    x = [self.x, rect.x].max
    y = [self.y, rect.y].max
    w = [self.x + self.width,  rect.x + rect.width ].min - x
    h = [self.y + self.height, rect.y + rect.height].min - y
    return Rect.new(x, y, w, h)
  end
  alias & intercept
end
}
#==============================================================================
# • Sprite
#==============================================================================
Ligni.register(:sprite, "ligni", 1.0) {
class Sprite
  #----------------------------------------------------------------------------
  # • Variáveis públicas da instância.
  #----------------------------------------------------------------------------
  attr_accessor :clone_sprite
  attr_accessor :outline_fill_rect
  #----------------------------------------------------------------------------
  # • Novo método. Modos de usos abaixo:
  #  * [normal] : É o método normal, na qual você não define nada. Sprite.new
  #  * [viewport] : É o método na qual você define um viewport.
  # Sprite.new(Viewport)
  #  * [system] : É o método na qual você já define um bitmap que irá carregar
  # uma imagem já direto da pasta System, através do Cache.
  # Sprite.new("S: Nome do Arquivo")
  #  * [picture] : É o método na qual você já define um bitmap que irá carregar
  # uma imagem já direito da pasta Pictures, através do Cache.
  # Sprite.new("P: Nome do Arquivo")
  #  * [graphics] : É o método na qual você já define um bitmap com uma imagem
  # que está dentro da pasta Graphics, através do Cache.
  # Sprite.new("G: Nome do Arquivo.")
  #  * [width, height] : É o método na qual você já define a largura e altura
  # do bitmap. Sprite.new([width, height])
  #  * [elements] : É o método na qual você já define a largura, altura,
  # posição X, posição Y e Prioridade do bitmap.
  # Sprite.new([width, height, x, y, z])
  #----------------------------------------------------------------------------
  alias new_initialize initialize
  def initialize(viewport=nil)
    @clone_sprite = []
    @outline_fill_rect = nil
    if viewport.is_a?(String)
      new_initialize(nil)
      if viewport.match(/S: ([^>]*)/)
        self.bitmap = Cache.system($1.to_s)
      elsif viewport.match(/P: ([^>]*)/)
        self.bitmap = Cache.picture($1.to_s)
      elsif viewport.match(/G: ([^>]*)/)
        self.bitmap = Cache.load_bitmap("Graphics/", $1.to_s)
      else
        self.bitmap = Bitmap.new(viewport)
      end
    elsif viewport.is_a?(Array)
      if viewport.size == 2
        new_initialize(nil)
        self.bitmap = Bitmap.new(viewport[0], viewport[1])
      elsif viewport.size == 5
        new_initialize(nil)
        self.bitmap = Bitmap.new(viewport[0], viewport[1])
        self.x, self.y, self.z = viewport[2], viewport[3], viewport[4]
      end
    elsif viewport.is_a?(Viewport) or viewport.nil?
      new_initialize(viewport)
    end
  end
  #----------------------------------------------------------------------------
  # • Renovação do Sprite.
  #----------------------------------------------------------------------------
  alias :ligniCoreDispose :dispose
  def dispose(*args)
    ligniCoreDispose(*args)
    @outline_fill_rect.dispose unless @outline_fill_rect.nil? or @outline_fill_rect.disposed?
  end
  #----------------------------------------------------------------------------
  # • Definir um contorno no Sprite em forma de retângulo.
  #     color : Cor do contorno.
  #     size : Tamanho da linha do contorno.
  #     vis : Visibilidade. true - visível | false - invisível.
  #----------------------------------------------------------------------------
  def set_outline(color=Color.new.default, size=2, vis=true)
    @outline_fill_rect = Sprite.new([self.width, self.height, self.x, self.y, self.z+2])
    @outline_fill_rect.bitmap.fill_rect(0, 0, self.width, size, color)
    @outline_fill_rect.bitmap.fill_rect(0, self.height-size, self.width, size, color)
    @outline_fill_rect.bitmap.fill_rect(0, 0, size, self.height, color)
    @outline_fill_rect.bitmap.fill_rect(self.width-size, 0, size, self.height, color)
    @outline_fill_rect.visible = vis
  end
  #----------------------------------------------------------------------------
  # • Atualização do contorno.
  #     vis : Visibilidade. true - visível | false - invisível.
  #----------------------------------------------------------------------------
  def update_outline(vis=true)
    @outline_fill_rect.visible = vis
    @outline_fill_rect.x, @outline_fill_rect.y = self.x, self.y
  end
  #----------------------------------------------------------------------------
  # • Slide pela direita.
  #   * speed : Velocidade | point : Ponto da coordenada X que irá chegar.
  #----------------------------------------------------------------------------
  def slide_right(speed, point)
    self.x += speed unless self.x >= point
  end
  #----------------------------------------------------------------------------
  # • Slide pela esquerda.
  #   * speed : Velocidade | point : Ponto da coordenada X que irá chegar.
  #----------------------------------------------------------------------------
  def slide_left(speed, point)
    self.x -= speed unless self.x <= point
  end
  #----------------------------------------------------------------------------
  # • Slide por cima.
  #   * speed : Velocidade | point : Ponto da coordenada Y que irá chegar.
  #----------------------------------------------------------------------------
  def slide_up(speed, point)
    self.y -= speed unless self.y <= point
  end
  #----------------------------------------------------------------------------
  # • Slide por baixo.
  #   * speed : Velocidade | point : Ponto da coordenada Y que irá chegar.
  #----------------------------------------------------------------------------
  def slide_down(speed, point)
    self.y += speed unless self.y >= point
  end
  #----------------------------------------------------------------------------
  # • Define aqui uma posição fixa para um objeto.
  #   command : Veja na classe Position.
  #----------------------------------------------------------------------------
  def position(command=0)
    return if command.nil?
    Ligni::Position[command, self]
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Tamanho geral
  #----------------------------------------------------------------------------
  def size
    return self.width + self.height
  end
  #----------------------------------------------------------------------------
  # • [Rect] : Retorna ao Rect do Bitmap.
  #----------------------------------------------------------------------------
  def rect
    return self.bitmap.rect
  end
  #----------------------------------------------------------------------------
  # • Base para clonar um Sprite.
  #    * depht : Prioridade no mapa.
  #    * clone_bitmap : Se irá clonar o bitmap.
  # Exemplo: sprite = sprite2.clone
  #----------------------------------------------------------------------------
  def clone(depht=0, clone_bitmap=false)
    @clone_sprite.delete_if { |bitmap| bitmap.disposed? }
    cloned = Sprite.new(self.viewport)
    cloned.x, cloned.y = self.x, self.y
    cloned.bitmap = self.bitmap
    cloned.bitmap = self.bitmap.clone if clone_bitmap
    unless depht == 0
      cloned.z = self.z + depht
    else
      @clone_sprite.each { |sprite| sprite.z -= 1 }
      cloned.z = self.z - 1
    end
    cloned.src_rect.set(self.src_rect)
    ["zoom_x", "zoom_y", "angle", "mirror", "opacity", "blend_type", "visible",
     "ox", "oy"].each { |meth|
      eval("cloned.#{meth} = self.#{meth}")
    }
    cloned.color.set(color)
    cloned.tone.set(tone)
    after_clone(cloned)
    @clone_sprite.push(cloned)
    return cloned
  end
  #----------------------------------------------------------------------------
  # • Efeito após ter clonado o Sprite.
  #----------------------------------------------------------------------------
  def after_clone(clone)
  end
  #----------------------------------------------------------------------------
  # • O que irá acontecer sê o mouse estiver em cima do sprite?
  #----------------------------------------------------------------------------
  def mouse_over
  end
  #----------------------------------------------------------------------------
  # • O que irá acontecer sê o mouse não estiver em cima do sprite?
  #----------------------------------------------------------------------------
  def mouse_no_over
  end
  #----------------------------------------------------------------------------
  # • O que irá acontecer sê o mouse clicar no objeto
  #----------------------------------------------------------------------------
  def mouse_click
  end
  #----------------------------------------------------------------------------
  # • Atualização dos sprites.
  #----------------------------------------------------------------------------
  alias :ligniUpdate :update
  def update(*args, &block)
    ligniUpdate(*args, &block)
    unless Ligni::Mouse.cursor.nil?
      self.if_mouse_over { |over| over ? mouse_over : mouse_no_over }
      self.if_mouse_click { mouse_click }
    end
  end
  #----------------------------------------------------------------------------
  # • Inverter o lado do sprite.
  #----------------------------------------------------------------------------
  def mirror!
    self.mirror = !self.mirror
  end
  #----------------------------------------------------------------------------
  # • Inverter o ângulo do sprite em 180°(Pode ser mudado.).
  #----------------------------------------------------------------------------
  def angle!(ang=180)
    self.ox, self.oy = self.bitmap.width, self.bitmap.height
    self.angle += ang
    self.angle += 360 while self.angle < 0
    self.angle %= 360
  end
end
}
#==============================================================================
# • Bitmap
#==============================================================================
Ligni.register(:bitmap, "ligni", 1.0) {
class Bitmap
  #--------------------------------------------------------------------------
  # • Constantes.
  #--------------------------------------------------------------------------
  Directory = 'Data/Bitmaps/'
  #--------------------------------------------------------------------------
  # • Bitmap do tamanho da tela.
  #--------------------------------------------------------------------------
  def self.screen
    return Bitmap.new(Graphics.width, Graphics.height)
  end
  #--------------------------------------------------------------------------
  # • Bitmap com as mesmas dimensões.
  #--------------------------------------------------------------------------
  def self.box(size)
    return Bitmap.new(size, size)
  end
  #--------------------------------------------------------------------------
  # • Salvar as informações do bitmap em um arquivo.
  #--------------------------------------------------------------------------
  def self.saveInfo(bitmap, filename)
    return unless bitmap.is_a?(Bitmap)
    red = Table.new(bitmap.width, bitmap.height)
    green = Table.new(bitmap.width, bitmap.height)
    blue = Table.new(bitmap.width, bitmap.height)
    alpha = Table.new(bitmap.width, bitmap.height)
    bitmap.rect.step(1, 1) { |i, j|
      color = bitmap.get_pixel(i, j)
      red[i, j] = color.red
      green[i, j] = color.green
      blue[i, j] = color.blue
      alpha[i, j] = color.alpha
    }
    Dir.mkdir(Directory) unless File.directory?(Directory)
    file = File.open(Directory + filename + '.rvdata2', 'wb')
    Marshal.dump([red, green, blue, alpha], file)
    file.close
    msgbox "bitmap saved"
  end
  #--------------------------------------------------------------------------
  # * Abrir o arquivo.
  #--------------------------------------------------------------------------
  def self.readInfo(filename)
    return unless FileTest.exist?(Directory + filename + '.rvdata2')
    file = File.open(Directory + filename + '.rvdata2', "rb")
    colors = Marshal.load(file).compact
    file.close
    red, green, blue, alpha = *colors
    bitmap = Bitmap.new(red.xsize, red.ysize)
    for i in 0...bitmap.width
      for j in 0...bitmap.height
        bitmap.set_pixel(i, j, Color.new(red[i, j], green[i, j], blue[i, j], alpha[i, j]))
      end
    end
    return bitmap
  end
  #----------------------------------------------------------------------------
  # • Modifica o sprite para ficar do tamanho definido.
  #----------------------------------------------------------------------------
  def resize(width=Graphics.width, height=Graphics.height)
    self.stretch_blt(Rect.new(0, 0, width, height), self, self.rect)
  end
  #----------------------------------------------------------------------------
  # • Criar uma barra.
  #    color : Objeto de Cor [Color]
  #    actual : Valor atual da barra.
  #    max : Valor máximo da barra.
  #    borda : Tamanho da borda da barra.
  #----------------------------------------------------------------------------
  def bar(color, actual, max, borda=1)
    rate = self.width.to_p(actual, max)
    self.fill_rect(borda, borda, rate-(borda*2), self.height-(borda*2),
    color)
  end
  #----------------------------------------------------------------------------
  # • Barra em forma de gradient.
  #    color : Objeto de Cor, em forma de [Array] para conter 2 [Color]
  # exemplo -> [Color.new(x), Color.new(y)]
  #    actual : Valor atual da barra.
  #    max : Valor máximo da barra.
  #    borda : Tamanho da borda da barra.
  #----------------------------------------------------------------------------
  def gradient_bar(color, actual, max, borda=1)
    rate = self.width.to_p(actual, max)
    self.gradient_fill_rect(borda, borda, rate-(borda*2), self.height-(borda*2),
    color[0], color[1], 2)
  end
  #----------------------------------------------------------------------------
  # • Limpar uma área num formato de um círculo.
  #----------------------------------------------------------------------------
  def clear_rect_circle(x, y, r)
    rr = r*r
    for i in 0...r
      adj = Math.sqrt(rr - (i*i)).ceil
      xd = x - adj
      wd = 2 * adj
      self.clear_rect(xd, y-i, wd, 1)
      self.clear_rect(xd, y+i, wd, 1)
    end
  end
  #----------------------------------------------------------------------------
  # • Novo modo de desenhar textos. Configurações já especificadas.
  #----------------------------------------------------------------------------
  def draw_text_rect(*args)
    self.draw_text(self.rect, *args)
  end
  #----------------------------------------------------------------------------
  # • Permite salvar várias imagens em cima de outra.
  #    Exemplo de comando:
  # Bitmap.overSave("Pictures/Nova", "Pictures/1", "Characters/2",
  #                          "Pictures/3", "Characters/4", "Pictures/5")
  # NÃO ESQUEÇA DE ESPECIFICAR ÀS PASTAS.
  #----------------------------------------------------------------------------
  def self.overSave(newfile, first, *args)
    return if first.empty? || first.nil? || args.empty? || args.nil?
    firstB = Bitmap.new("Graphics/"+first)
    args.each { |outhers|
      firstB.stretch_blt(firstB.rect, Bitmap.new("Graphics/"+outhers), firstB.rect)
    }
    firstB.save("Graphics/"+newfile)
  end
  #----------------------------------------------------------------------------
  # • Modificar as cores do [Bitmap] para ficarem Negativas.
  #----------------------------------------------------------------------------
  def negative
    self.rect.step(1.0, 1.0) { |i, j|
      pix = self.get_pixel(i, j)
      pix.red = (pix.red - 255) * -1
      pix.blue = (pix.blue - 255) * -1
      pix.green = (pix.green - 255) * -1
      self.set_pixel(i, j, pix)
    }
  end
  #----------------------------------------------------------------------------
  # • Grayscale : Modificar as cores do [Bitmap] para cor cinza. Efeito cinza.
  #----------------------------------------------------------------------------
  def grayscale(rect = Rect.new(0, 0, self.width, self.height))
    self.rect.step(1, 1) { |i, j|
      colour = self.get_pixel(i,j)
      grey_pixel = (colour.red*0.3 + colour.green*0.59 + colour.blue*0.11)
      colour.red = colour.green = colour.blue = grey_pixel
      self.set_pixel(i,j,colour)
    }
  end
  #----------------------------------------------------------------------------
  # • Converter as cores para sepia.
  #----------------------------------------------------------------------------
  def sepia2
    self.rect.step(1, 1) { |w, h|
      nrow = row = get_pixel(w, h)
      row.red = [(0.393 * nrow.red) + (0.769 * nrow.green) + (0.189 * nrow.blue), 255].min
      row.green = [(0.349 * nrow.red) + (0.689 * nrow.green) + (0.168 * nrow.blue), 255].min
      row.blue = [(0.272 * nrow.red) + (0.534 * nrow.green) + (0.131 * nrow.blue), 255].min
      set_pixel(w, h, row)
    }
  end
  #----------------------------------------------------------------------------
  # • Suavidade nas cores do bitmap. Converte as cores em preto e branco.
  #     crlz : Controle da iluminidade.
  #----------------------------------------------------------------------------
  def black_whiteness(ctlz=2.0)
    self.rect.step(1, 1) { |w, h|
      row = get_pixel(w, h)
      getArray__row = row.to_a(false)
      lightCalc_ = (getArray__row.max + getArray__row.min) / ctlz
      row.red = row.green = row.blue = lightCalc_
      set_pixel(w, h, row)
    }
  end
  #----------------------------------------------------------------------------
  # • Novo fornecedor de pixel.
  #----------------------------------------------------------------------------
  def set_pixel_s(x, y, color, size)
    for i in 0...size
      self.set_pixel(x+i, y, color)
      self.set_pixel(x-i, y, color)
      self.set_pixel(x, y+i, color)
      self.set_pixel(x, y-i, color)
      self.set_pixel(x+i, y+i, color)
      self.set_pixel(x-i, y-i, color)
      self.set_pixel(x+i, y-i, color)
      self.set_pixel(x-i, y+i, color)
    end
  end
  #----------------------------------------------------------------------------
  # • Desenhar uma linha.
  #    start_x : Início da linha em X.
  #    start_y : Início da linha em Y.
  #    end_x : Finalização da linha em X.
  #    end_y : Finalização da linha em Y.
  #----------------------------------------------------------------------------
  def draw_line(start_x, start_y, end_x, end_y, color, size=1)
    set_pixel_s(start_x, start_y, color, size)
    distance = (start_x - end_x).abs + (start_y - end_y).abs
    for i in 1..distance
      x = (start_x + 1.0 * (end_x - start_x) * i / distance).to_i
      y = (start_y + 1.0 * (end_y - start_y) * i / distance).to_i
      set_pixel_s(x, y, color, size)
    end
    set_pixel_s(end_x, end_y, color, size)
  end
  #----------------------------------------------------------------------------
  # • draw_bar_gauge(x, y, current, current_max, border, colors)
  #   x : Coordenadas X.
  #   y : Coordenadas Y.
  #   current : Valor atual da barra.
  #   current_max : Valor maxímo da barra.
  #   border : Expressura da borda.
  #   colors : Cores. [0, 1]
  #----------------------------------------------------------------------------
  #  Permite adicionar uma barra.
  #----------------------------------------------------------------------------
  def draw_bar_gauge(x, y, current, current_max, colors=[])
    cw = self.width.to_p(current, current_max)
    ch = self.height
    self.gradient_fill_rect(x, y, self.width, self.height, colors[0], colors[1])
    src_rect = Rect.new(0, 0, cw, ch)
    self.blt(x, y, self, src_rect)
  end
  #----------------------------------------------------------------------------
  # • draw_icon(icon_index, x, y, enabled)
  #   icon_index : ID do ícone.
  #   x : Coordenadas X.
  #   y : Coordenadas Y.
  #   enabled : Habilitar flag, translucido quando false
  #   filename : Podes definir uma imagem: Basta
  # por o nome da imagem, ela deve estar na pasta System.
  #----------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true, filename="IconSet")
    icon_index = icon_index.nil? ? 0 : icon_index
    bitmap = Cache.system(filename)
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end
  #----------------------------------------------------------------------------
  # • draw_gradation_gauge(x, y, width, height, current, current_max, border, colors, align)
  #   x : Coordenadas X.
  #   y : Coordenadas Y.
  #   width : Largura da barra.
  #   height : Altura da barra.
  #   current : Valor atual da barra.
  #   current_max : Valor maxímo da barra.
  #   border : Expressura da borda.
  #   colors : Cores. [0, 1]
  #   align : Alinhamento.
  #----------------------------------------------------------------------------
  #  Permite adicionar uma barra.
  #----------------------------------------------------------------------------
  def draw_gradation_gauge(x, y, current, current_max, border, colors=[])
    cw = self.width.to_p(current, current_max)
    ch = self.height
    self.fill_rect(x, y, self.width, self.height, colors[0])
    self.gradient_fill_rect(x+border, y+border, self.width-(border/2), self.height-(border/2), colors[1], colors[2])
    src_rect = Rect.new(0, 0, cw, ch)
    self.blt(x, y, self, src_rect)
  end
  #----------------------------------------------------------------------------
  # • Desenhar um círuclo preenchido.
  #----------------------------------------------------------------------------
  def fill_circle(x, y, r, c)
    rr = r*r
    for i in 0...r
      adj = Math.sqrt(rr - (i*i)).ceil
      xd = x - adj
      wd = 2 * adj
      self.fill_rect(xd, y-i, wd, 1, c)
      self.fill_rect(xd, y+i, wd, 1, c)
    end
  end
  #----------------------------------------------------------------------------
  # • [Brilho] : Aumentar/Diminuir o brilho do sprite.
  #----------------------------------------------------------------------------
  def brightness(vl = 100)
    self.rect.step(1.0, 1.0) { |i, j|
      pix = self.get_pixel(i, j)
      pix = pix.percent(vl)
      self.set_pixel(i, j, pix)
    }
  end
  # save 
  def save(filename)
    API::PNG.save(self, filename)
  end
end
}
#==============================================================================
# * Window_Base
#==============================================================================
Ligni.register(:window_base, "ligni", 1.0) {
if defined?("Window_Base")
class Window_Base < Window
  #----------------------------------------------------------------------------
  # • Slide pela direita.
  #   * speed : Velocidade | point : Ponto da coordenada X que irá chegar.
  #----------------------------------------------------------------------------
  def slide_right(speed, point)
    self.x += speed unless self.x >= point
  end
  #----------------------------------------------------------------------------
  # • Slide pela esquerda.
  #   * speed : Velocidade | point : Ponto da coordenada X que irá chegar.
  #----------------------------------------------------------------------------
  def slide_left(speed, point)
    self.x -= speed unless self.x <= point
  end
  #----------------------------------------------------------------------------
  # • Slide por cima.
  #   * speed : Velocidade | point : Ponto da coordenada Y que irá chegar.
  #----------------------------------------------------------------------------
  def slide_up(speed, point)
    self.y -= speed unless self.y <= point
  end
  #----------------------------------------------------------------------------
  # • Slide por baixo.
  #   * speed : Velocidade | point : Ponto da coordenada Y que irá chegar.
  #----------------------------------------------------------------------------
  def slide_down(speed, point)
    self.y += speed unless self.y >= point
  end
  #----------------------------------------------------------------------------
  # • Define aqui uma posição fixa para um objeto.
  #   command : Retorna a uma base padrão.
  #----------------------------------------------------------------------------
  def position(command=0)
    return if command.nil?
    Ligni::Position[command, self]
  end
end; end
}
#==============================================================================
# • Backup 
#==============================================================================
Ligni.register(:backup, "ligni", 1.0) {
module Ligni::Backup
  extend self
  #----------------------------------------------------------------------------
  # • Const.
  #----------------------------------------------------------------------------
  DIR = "./Backup"
  COPYFILE = ->(*args) {  API::CopyFile.call(*args) }
  #----------------------------------------------------------------------------
  # • Call.
  #----------------------------------------------------------------------------
  def run(complete=false)
    return unless $TEST
    Dir.mkdir(DIR) unless FileTest.directory? DIR
    complete ? call_complete : call_data
  end
  private
  #----------------------------------------------------------------------------
  # • Call of the Data.
  #----------------------------------------------------------------------------
  def call_data
    Dir.mkdir(DIR + "/Data") unless FileTest.directory? DIR + "/Data"
    Dir.glob("./Data/*").each { |_data| COPYFILE[_data, DIR + _data, 1] }
  end
  #----------------------------------------------------------------------------
  # • Call Complete.
  #----------------------------------------------------------------------------
  def call_complete
    Dir.glob(File.join("**", "**")).each { |_backup|
      next if _backup.match(/Backup/im)
      _dir = FileTest.directory?(_backup) ? _backup : _backup.gsub!(/\/\.(\w+)/, "")
      Dir.mkdir(DIR + "/#{_dir}") unless FileTest.directory? DIR + "/#{_dir}"
      COPYFILE[_backup, DIR + "/" + _backup, 1]
    }
  end
end
}
#==============================================================================
# • Opacity
#==============================================================================
Ligni.register(:opacity, "ligni", 1.0) {
module Opacity
  extend self
  @key ||= {}
  #----------------------------------------------------------------------------
  # • Efeito de opacidade que vai aumentando e diminuindo.
  # sprite : Objeto na qual sofrerá o efeito. [Sprite]
  # speed : Velocidade na qual o efeito irá acontencer.
  # max : Valor máximo na qual irá ser atingido.
  # min : Valor minímo na qual irá ser atingido.
  #----------------------------------------------------------------------------
  def sprite_opacity(sprite, speed, max, min, hash=nil)
    @key[hash.nil? ? hash.__id__ : hash] || false
    unless @key[hash]
      sprite.opacity += speed unless sprite.opacity >= max
      @key[hash] = sprite.opacity >= max
    else
      sprite.opacity -= speed unless sprite.opacity <= min
      @key[hash] = false if sprite.opacity <= min
    end
  end
  #----------------------------------------------------------------------------
  # • Efeito de opacidade por fora.
  # sprite : Objeto na qual sofrerá o efeito. [Sprite]
  # speed : Velocidade na qual o efeito irá acontencer.
  # max : Valor máximo na qual irá ser atingido.
  #----------------------------------------------------------------------------
  def sprite_opacity_out(sprite, speed, max)
    return if sprite.nil?
    sprite.opacity += speed unless sprite.opacity >= max
  end
  #----------------------------------------------------------------------------
  # • Efeito de opacidade por dentro.
  # sprite : Objeto na qual sofrerá o efeito. [Sprite]
  # speed : Velocidade na qual o efeito irá acontencer.
  #  min : Valor minímo na qual irá ser atingido.
  #----------------------------------------------------------------------------
  def sprite_opacity_in(sprite, speed, min)
    sprite.opacity -= speed unless sprite.opacity <= min
  end
  #----------------------------------------------------------------------------
  # • Limpar variável.
  #----------------------------------------------------------------------------
  def clear
    @key.clear
  end
end
}
#==============================================================================
# • Mouse
#==============================================================================
Ligni.register(:mouse, "ligni", 1.0) {
module Ligni::Mouse
  extend self
  #--------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #--------------------------------------------------------------------------
  def start
    @cursor = Sprite_Mouse.new(Ligni::MOUSE_NAME, -128, -128, 100000)
    @graphic = Ligni::MOUSE_NAME
    x = Ligni::MOUSE_NAME == "" ? 1 : 0
    API::MouseShowCursor.call(x)
    @visible = true
  end
  #----------------------------------------------------------------------------
  # • visible = (boolean)
  #  * boolean : true ou false
  # Tornar vísivel ou não o cursor do Mouse.
  #----------------------------------------------------------------------------
  def visible=(boolean)
    @visible = boolean
  end
  #--------------------------------------------------------------------------
  # • graphic(graphic_set)
  #   graphic_set : Se for número é um ícone; Se for string é uma imagem.
  #--------------------------------------------------------------------------
  def graphic(graphic_set)
    visible = false
    @graphic = graphic_set
    @cursor.set_graphic = graphic_set
  end
  #--------------------------------------------------------------------------
  # • show(visible)
  #   visible : True - para mostrar o mouse | False - para esconder o mouse.
  #--------------------------------------------------------------------------
  def show(vis=true)
    @cursor.visible = vis
  end
  #--------------------------------------------------------------------------
  # • update (Atualização das coordenadas)
  #--------------------------------------------------------------------------
  def update
    return if @cursor.nil?
    API::MouseShowCursor.call(@visible.boolean)
    if @cursor.disposed?
      @cursor = Sprite_Mouse.new(@graphic, 0, 0, 100000)
    end
    @cursor.update
    @cursor.x, @cursor.y = position
  end
  #--------------------------------------------------------------------------
  # • Retorna a variável '@cursor' que tem como valor a classe [Sprite].
  #--------------------------------------------------------------------------
  def cursor
    @cursor
  end
  #--------------------------------------------------------------------------
  # • Clear.
  #--------------------------------------------------------------------------
  def clear
    @cursor.dispose
  end
  #--------------------------------------------------------------------------
  # • x (Coordenada X do Mouse)
  #--------------------------------------------------------------------------
  def x
    @cursor.x rescue 0
  end
  #--------------------------------------------------------------------------
  # • y (Coordenada Y do Mouse)
  #--------------------------------------------------------------------------
  def y
    @cursor.y rescue 0
  end
  #--------------------------------------------------------------------------
  # • position (Posição do Mouse!)
  #--------------------------------------------------------------------------
  def position
    x, y = get_client_position
    return x, y
  end
  #--------------------------------------------------------------------------
  # • get_client_position (Posição original do Mouse!)
  #--------------------------------------------------------------------------
  def get_client_position
    pos = [0, 0].pack('ll')
    API::CursorPosition.call(pos)
    API::ScreenToClient.call(WINDOW, pos)
    return pos.unpack('ll')
  end
  #--------------------------------------------------------------------------
  # • Verificação se o mouse está na área de um determinado objeto.
  #--------------------------------------------------------------------------
  def in_area?(x)
    return false if @cursor.disposed?
    return false unless x.is_a?(Sprite) or x.is_a?(Window)
    return @cursor.x.between?(x.x, (x.x - x.ox + (x.viewport ? x.viewport.rect.x : 0)) + x.width) &&
    @cursor.y.between?(x.y, (x.y - x.oy + (x.viewport ? x.viewport.rect.y : 0)) + x.height)
  end
  #----------------------------------------------------------------------------
  # • Verificar se o mouse está em determinada área
  #----------------------------------------------------------------------------
  def area?(x, y, width, height)
    return false if @cursor.nil? or @cursor.disposed?
    return @cursor.x.between?(x, x + width) &&
      @cursor.y.between?(y, y + height)
  end
  #----------------------------------------------------------------------------
  # • Mudar posição do cursor.
  #----------------------------------------------------------------------------
  def set_pos(pos)
    pos = pos.position unless pos.is_a? Position
    API::SetCursorPos.call(pos.x, pos.y)
    update
    @cursor.x = pos.x
    @cursor.y = pos.y
  end
  #----------------------------------------------------------------------------
  # • Verifica se clicou com o botão esquerdo do Mouse.
  #----------------------------------------------------------------------------
  def left?
    return Ligni::Key.trigger?(0x01)
  end
  #----------------------------------------------------------------------------
  # • Verifica se clicou com o botão direito do Mouse.
  #----------------------------------------------------------------------------
  def right?
    return Ligni::Key.trigger?(0x02)
  end
  WINDOW = API.hWND
end
#==============================================================================
# • Sprite_Mouse
#==============================================================================
class Sprite_Mouse < Sprite
  #----------------------------------------------------------------------------
  # • Variáveis públicas da instância.
  #----------------------------------------------------------------------------
  attr_accessor :set_graphic # definir o gráfico.
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize(graphic, x, y, z)
    super(nil)
    @set_graphic = graphic
    if @set_graphic.is_a?(Fixnum)
      self.bitmap = Bitmap.new(24, 24)
      self.bitmap.draw_icon(@set_graphic, 0, 0)
    elsif @set_graphic.is_a?(NilClass) or @set_graphic == ""
      self.bitmap = Bitmap.new(1, 1)
    elsif @set_graphic.is_a?(String)
      self.bitmap = Cache.system(@set_graphic)
    end
    self.x, self.y, self.z = x, y, z
    @older = @set_graphic
  end
  #----------------------------------------------------------------------------
  # • Renovação dos objetos.
  #----------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #----------------------------------------------------------------------------
  # • Atualização dos objetos.
  #----------------------------------------------------------------------------
  def update
    super
    unless @older == @set_graphic
      if @set_graphic.is_a?(Fixnum)
        self.bitmap = Bitmap.new(24, 24)
        self.bitmap.draw_icon(@set_graphic, 0, 0)
      elsif @set_graphic.is_a?(NilClass) or @set_graphic == ""
        self.bitmap = Bitmap.new(1, 1)
      elsif @set_graphic.is_a?(String)
        self.bitmap = Cache.system(@set_graphic)
      end
      @older = @set_graphic
    end
  end
end
Ligni::Mouse.start
}
#==============================================================================
# • Benchmark
#==============================================================================
Ligni.register(:benchmark, "Gotoken", 1.0) {
module Benchmark
  extend self
  #----------------------------------------------------------------------------
  # • Constantes.
  #----------------------------------------------------------------------------
  CAPTION = "      user     system      total        real\n"
  FMTSTR = "%10.6u %10.6y %10.6t %10.6r\n"
  def Benchmark::times() # :nodoc:
    Process::times()
  end
  #----------------------------------------------------------------------------
  # • Método do benchmark.:.
  # ** Exemplo:.:
  #     n = 50000
  #     Benchmark.benchmark(" "*7 + CAPTION, 7, FMTSTR, ">total:", ">avg:") do |x|
  #       tf = x.report("for:")   { for i in 1..n; a = "1"; end }
  #       tt = x.report("times:") { n.times do   ; a = "1"; end }
  #       tu = x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
  #       [tf+tt+tu, (tf+tt+tu)/3]
  #     end
  #  ** Gera:.:
  #                     user     system      total        real
  #        for:     1.016667   0.016667   1.033333 (  0.485749)
  #        times:   1.450000   0.016667   1.466667 (  0.681367)
  #        upto:    1.533333   0.000000   1.533333 (  0.722166)
  #        >total:  4.000000   0.033333   4.033333 (  1.889282)
  #        >avg:    1.333333   0.011111   1.344444 (  0.629761)
  #----------------------------------------------------------------------------
  def benchmark(caption = "", label_width = nil, fmtstr = nil, *labels) # :yield: report
    sync = STDOUT.sync
    STDOUT.sync = true
    label_width ||= 0
    fmtstr ||= FMTSTR
    raise ArgumentError, "no block" unless iterator?
    print caption
    results = yield(Report.new(label_width, fmtstr))
    Array === results and results.grep(Tms).each {|t|
      print((labels.shift || t.label || "").ljust(label_width),
            t.format(fmtstr))
    }
    STDOUT.sync = sync
  end
  #----------------------------------------------------------------------------
  # • Versão simplificada para benchmark.
  #  ** Exemplo:.:
  #     n = 50000
  #     Benchmark.bm(7) do |x|
  #       x.report("for:")   { for i in 1..n; a = "1"; end }
  #       x.report("times:") { n.times do   ; a = "1"; end }
  #       x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
  #     end
  #  ** Gera:.:
  #                     user     system      total        real
  #        for:     1.050000   0.000000   1.050000 (  0.503462)
  #        times:   1.533333   0.016667   1.550000 (  0.735473)
  #        upto:    1.500000   0.016667   1.516667 (  0.711239)
  #----------------------------------------------------------------------------
  def bm(label_width = 0, *labels, &blk) # :yield: report
    benchmark(" "*label_width + CAPTION, label_width, FMTSTR, *labels, &blk)
  end
  #----------------------------------------------------------------------------
  # • Retorna ao tempo usado para executar o bloco como um objeto Benchmark::Tms
  #----------------------------------------------------------------------------
  def measure(label = "") # :yield:
    t0, r0 = Benchmark.times, Time.now
    yield
    t1, r1 = Benchmark.times, Time.now
    Benchmark::Tms.new(t1.utime  - t0.utime,
                       t1.stime  - t0.stime,
                       t1.cutime - t0.cutime,
                       t1.cstime - t0.cstime,
                       r1.to_f - r0.to_f,
    label)
  end
  #----------------------------------------------------------------------------
  # • Retorna ao tempo real decorrido, o tempo usado para executar o bloco.
  #----------------------------------------------------------------------------
  def realtime(&blk) # :yield:
    r0 = Time.now
    yield
    r1 = Time.now
    r1.to_f - r0.to_f
  end
  #============================================================================
  # • Report ::
  #============================================================================
  class Report
    #--------------------------------------------------------------------------
    # • Retorna uma instância inicializada.
    #  Usualmente não é bom chamar esse método diretamente.
    #--------------------------------------------------------------------------
    def initialize(width = 0, fmtstr = nil)
      @width, @fmtstr = width, fmtstr
    end
    #--------------------------------------------------------------------------
    # • Imprime o _label_ e o tempo marcado pelo bloco, formatado por _fmt_.
    #--------------------------------------------------------------------------
    def item(label = "", *fmt, &blk) # :yield:
      print label.ljust(@width)
      res = Benchmark::measure(&blk)
      print res.format(@fmtstr, *fmt)
      res
    end
    #--------------------------------------------------------------------------
    # • Método :alias:
    #--------------------------------------------------------------------------
    alias :report :item
  end
  #============================================================================
  # • Tms
  #============================================================================
  class Tms
    #--------------------------------------------------------------------------
    # • Constantes
    #--------------------------------------------------------------------------
    CAPTION = "      user     system      total        real\n"
    FMTSTR = "%10.6u %10.6y %10.6t %10.6r\n"
    #--------------------------------------------------------------------------
    # • Variáveis da instância.
    #--------------------------------------------------------------------------
    attr_reader :utime # Tempo da CPU do Usuário.
    attr_reader :stime # Tempo da CPU do Sistema.
    attr_reader :cutime # Tempo da CPU do usuário-criança.
    attr_reader :cstime # Tempo da CPU do sistema-criança.
    attr_reader :real # Tempo real corrido.
    attr_reader :total # Tempo total, que é _utime_ + _stime_ + _cutime_ + _cstime_
    attr_reader :label # Label.
    #--------------------------------------------------------------------------
    # • Retorna ao objeto inicializado na qual tem _u_ como tempo dá CPU do
    # usuário, _s_ como o tempo da CPU do sistema, _cu_ como tempo dá CPU
    # do usuário-criança, _cs_ como o tempo dá CPU sistema-criança, _real_
    # como o tempo real corrido e _l_ como label.
    #--------------------------------------------------------------------------
    def initialize(u = 0.0, s = 0.0, cu = 0.0, cs = 0.0, real = 0.0, l = nil)
      @utime, @stime, @cutime, @cstime, @real, @label = u, s, cu, cs, real, l
      @total = @utime + @stime + @cutime + @cstime
    end
    #--------------------------------------------------------------------------
    # • Retorna a um novo objeto Tms, na qual os tempos são somados num todo
    # pelo objeto Tms.
    #--------------------------------------------------------------------------
    def add(&blk) # :yield:
      self + Benchmark::measure(&blk)
    end
    #--------------------------------------------------------------------------
    # • Uma versão no lugar do método #add
    #--------------------------------------------------------------------------
    def add!
      t = Benchmark::measure(&blk)
      @utime  = utime + t.utime
      @stime  = stime + t.stime
      @cutime = cutime + t.cutime
      @cstime = cstime + t.cstime
      @real   = real + t.real
      self
    end
    #--------------------------------------------------------------------------
    # • Soma com outro objeto do mesmo.
    #--------------------------------------------------------------------------
    def +(other); memberwise(:+, other) end
    #--------------------------------------------------------------------------
    # • Subtrai com outro objeto do mesmo.
    #--------------------------------------------------------------------------
    def -(other); memberwise(:-, other) end
    #--------------------------------------------------------------------------
    # • Multiplica com outro objeto do mesmo.
    #--------------------------------------------------------------------------
    def *(x); memberwise(:*, x) end
    #--------------------------------------------------------------------------
    # • Divide com outro objeto do mesmo.
    #--------------------------------------------------------------------------
    def /(x); memberwise(:/, x) end
    #--------------------------------------------------------------------------
    # • Retorna ao conteudo dos objetos formatados como uma string.
    #--------------------------------------------------------------------------
    def format(arg0 = nil, *args)
      fmtstr = (arg0 || FMTSTR).dup
      fmtstr.gsub!(/(%[-+\.\d]*)n/){"#{$1}s" % label}
      fmtstr.gsub!(/(%[-+\.\d]*)u/){"#{$1}f" % utime}
      fmtstr.gsub!(/(%[-+\.\d]*)y/){"#{$1}f" % stime}
      fmtstr.gsub!(/(%[-+\.\d]*)U/){"#{$1}f" % cutime}
      fmtstr.gsub!(/(%[-+\.\d]*)Y/){"#{$1}f" % cstime}
      fmtstr.gsub!(/(%[-+\.\d]*)t/){"#{$1}f" % total}
      fmtstr.gsub!(/(%[-+\.\d]*)r/){"(#{$1}f)" % real}
      arg0 ? Kernel::format(fmtstr, *args) : fmtstr
    end
    #--------------------------------------------------------------------------
    # • Mesmo que o método formato.
    #--------------------------------------------------------------------------
    def to_s
      format
    end
    #--------------------------------------------------------------------------
    # • Retorna a uma array contendo os elementos:
    #     @label, @utime, @stime, @cutime, @cstime, @real
    #--------------------------------------------------------------------------
    def to_a
      [@label, @utime, @stime, @cutime, @cstime, @real]
    end
    protected
    def memberwise(op, x)
      case x
      when Benchmark::Tms
        Benchmark::Tms.new(utime.__send__(op, x.utime),
                           stime.__send__(op, x.stime),
                           cutime.__send__(op, x.cutime),
                           cstime.__send__(op, x.cstime),
                           real.__send__(op, x.real)
                           )
      else
        Benchmark::Tms.new(utime.__send__(op, x),
                           stime.__send__(op, x),
                           cutime.__send__(op, x),
                           cstime.__send__(op, x),
                           real.__send__(op, x)
                           )
      end
    end
  CAPTION = Benchmark::Tms::CAPTION
  FMTSTR = Benchmark::Tms::FMTSTR
  end
end
}
#==============================================================================
# * Object
#==============================================================================
Ligni.register(:object, "ligni", 1.0) {
class Object 
  #----------------------------------------------------------------------------
  # • [Hex] : Retorna ao id do objeto em hexadécimal.
  #----------------------------------------------------------------------------
  def __hexid__
    "0x" + ('%.X' % (self.__id__ * 2))
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite.
  # Tem que ser um objeto Sprite.
  #----------------------------------------------------------------------------
  def if_mouse_over(&block)
    return if Ligni::Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    over ||= false
    if Ligni::Mouse.in_area?(self)
      block.call
      over = true
    else
      over = false
    end
    yield over
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite, e ao clicar.
  # Tem que ser um objeto Sprite.
  #  * button : Button : (:right - botão direito do mouse | :left - botão esq.)
  # EXPLICAÇÕES NO FINAL DO SCRIPT.
  #----------------------------------------------------------------------------
  def if_mouse_click(button=:left, &block)
    return if Ligni::Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Ligni::Mouse.in_area?(self) and trigger?(button)
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite, e ao pressionar.
  # Tem que ser um objeto Sprite.
  #  * button : Button : (:right - botão direito do mouse | :left - botão esq.)
  #----------------------------------------------------------------------------
  def if_mouse_press(button=:left, &block)
    return if Ligni::Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Ligni::Mouse.in_area?(self) and press?(button)
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite, e ao ficar clicando.
  # Tem que ser um objeto Sprite.
  #  * button : Button : (:right - botão direito do mouse | :left - botão esq.)
  #----------------------------------------------------------------------------
  def if_mouse_repeat(button=:left, &block)
    return if Ligni::Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Ligni::Mouse.in_area?(self)  and repeat?(button)
  end
  #----------------------------------------------------------------------------
  # • Trigger
  #  * key : Chave.
  # Você também pode usá-lo como condição para executar tal bloco;
  #----------------------------------------------------------------------------
  # trigger?(key) { bloco que irá executar }
  #----------------------------------------------------------------------------
  def trigger?(key, &block)
    if key == :C or key == :B
      ckey = Input.trigger?(key)
    else
      ckey = Ligni::Key.trigger?(key)
    end
    return ckey unless block_given?
    block.call if ckey
  end
  #----------------------------------------------------------------------------
  # • Press
  #  * key : Chave.
  # Você também pode usá-lo como condição para executar tal bloco;
  #----------------------------------------------------------------------------
  # press?(key) { bloco que irá executar. }
  #----------------------------------------------------------------------------
  def press?(key, &block)
    if key == :C or key == :B
      ckey = Input.press?(key)
    else
      ckey = Ligni::Key.press?(key)
    end
    return ckey unless block_given?
    block.call if ckey
  end
  #----------------------------------------------------------------------------
  # • Repeat
  #  * key : Chave.
  # Você também pode usá-lo como condição para executar tal bloco;
  #----------------------------------------------------------------------------
  # repeat?(key) { bloco que irá executar. }
  #----------------------------------------------------------------------------
  def repeat?(key, &block)
    if key == :C or key == :B
      ckey = Input.repeat?(key)
    else
      ckey = Ligni::Key.repeat?(key)
    end
    return ckey unless block_given?
    block.call if ckey
  end
  #----------------------------------------------------------------------------
  # • Retorna em forma de número os valores true ou false. E caso seja
  # 0 ou 1.. retorna a true ou false.
  # Se for true, retorna a 1.
  # Se for false, retorna a 0.
  # Se for 1, retorna a true.
  # Se for 0, retorna a false.
  #----------------------------------------------------------------------------
  def boolean
    return self.is_a?(Integer) ? self == 0 ? false : 1  : self ? 1 : 0
  end
  #----------------------------------------------------------------------------
  # • Converte para a classe Position.
  #----------------------------------------------------------------------------
  def position
    return Ligni::Position.new(self, self) if self.is_a?(Numeric)
    return Ligni::Position.new(self.x, self.y) if self.is_a?(Sprite) or self.is_a?(Window_Base) or self.is_a?(Rect)
    return Ligni::Position.new(self[0], self[1]) if self.is_a?(Array)
    return Ligni::Position.new(self[:x], self[:y]) if self.is_a?(Hash)
    return Ligni::Position.new(self.x, self.y) if defined?(self.x) and defined?(self.y)
    return Ligni::Position.new(0, 0)
  end
  #----------------------------------------------------------------------------
  # • Transforma em cor.
  #  Se for uma Array. Exemplo: [128, 174, 111].color =># Color.new(128, 174, 111)
  #  Se for uma String. Exemplo: "ffffff".color =># Color.new(255,255,255)
  #----------------------------------------------------------------------------
  def color
    return Ligni::Color.new(*self) if self.is_a?(Array)
    return Ligni::Color.hex(self) if self.is_a?(String)
  end
end
}
#==============================================================================
# • Axis
# Simulação dos eixos entre dois botões.
#==============================================================================
Ligni.register(:axis, "ligni", 1.0) {
class Ligni::Axis
	#----------------------------------------------------------------------------
  # • Variáveis de Instância Públicas
  #----------------------------------------------------------------------------
	attr_accessor :limit
	attr_accessor :inc
	attr_accessor :dec
	attr_accessor :positive_input
	attr_accessor :negative_input
	attr_accessor :axis
	attr_accessor :double_tap_wait
	#----------------------------------------------------------------------------
  # • initialize
  #----------------------------------------------------------------------------
	def initialize(pos_input, neg_input)
		@axis = 0.0
		@inc = 0.1
		@dec = 0.1
		@limit = 1.0
		@positive_input = pos_input
		@negative_input = neg_input
		@tap = false
		@double_tap_wait = 0.3
		@tap_wait_count = 0.0
		@current_direction = 0.0
		@double_tapped = false
		@caxis = 0.0	
	end
	#----------------------------------------------------------------------------
  # • set_input
  #----------------------------------------------------------------------------
	def set_input(pos, neg)
		@positive_input = pos
		@negative_input = neg
	end
	#----------------------------------------------------------------------------
  # • update
  #----------------------------------------------------------------------------
	def update
		increase if Ligni::Key.press?(@positive_input)
		decrease if Ligni::Key.press?(@negative_input)
    @current_direction = 1 if Ligni::Key.press?(@positive_input)
    @current_direction = -1 if Ligni::Key.press?(@negative_input)
		if @axis > 0 && !Ligni::Key.press?(@positive_input)
			@axis - @dec < 0 ? @axis = 0.0 : @axis -= @dec
		end
		if @axis < 0 && !Ligni::Key.press?(@negative_input)
			@axis + @dec > 0 ? @axis = 0.0 : @axis += @dec
		end
		update_tap
		update_double_tap
	end
	#----------------------------------------------------------------------------
  # • update_tap
  #----------------------------------------------------------------------------
	def update_tap
		@double_tapped = false
    if Ligni::Key.trigger?(@positive_input) && @current_direction == 1
      @tap = true
    elsif Ligni::Key.trigger?(@negative_input) && @current_direction == -1
      @tap = true
    else
      @tap = false
    end
	end
	#----------------------------------------------------------------------------
  # • update_double_tap
  #----------------------------------------------------------------------------
	def update_double_tap
		if @tap_wait_count > 0.0
			@tap_wait_count = Ligni::Mathf.move_towards(@tap_wait_count, 0, 0.016667)
		end
		if self.raw != 0 && self.tapped?
			if @current_direction != self.raw
				@current_direction = self.raw
				@tap_wait_count = @double_tap_wait
			elsif @current_direction == self.raw && @tap_wait_count <= 0
				@tap_wait_count = @double_tap_wait
			elsif @current_direction == self.raw && @tap_wait_count > 0
				@double_tapped = true
				@tap_wait_count = 0
			end
		end
	end
	#----------------------------------------------------------------------------
  # • increase
  #----------------------------------------------------------------------------
	def increase
		@axis += @inc
		@axis = Ligni::Mathf.clamp(@axis, -@limit, @limit)
	end
	#----------------------------------------------------------------------------
  # • decrease
  #----------------------------------------------------------------------------
	def decrease
		@axis -= @inc
		@axis = Ligni::Mathf.clamp(@axis, -@limit, @limit)
	end
	#----------------------------------------------------------------------------
  # • raw
  #----------------------------------------------------------------------------
	def raw
    if Ligni::Key.press?(@positive_input)
      return 1
    elsif Ligni::Key.press?(@negative_input)
      return -1
    end
		return 0
	end
	#----------------------------------------------------------------------------
  # • tapped?
  #----------------------------------------------------------------------------
	def tapped?
		return @tap
	end
	#----------------------------------------------------------------------------
  # • double_tapped?
  #----------------------------------------------------------------------------
	def double_tapped?
		return @double_tapped
	end
end
}
Ligni.register(:datamanager, "ligni", 1.0) {
#╔═════════════════════════════════════════════════════════════════════════════╗
#║ ҉ DataManager                                                               ║
#╚═════════════════════════════════════════════════════════════════════════════╝
class << DataManager
	
 #┌──────────────────────────────────────────────────────────────────────────┐
 #│ ♦ load_database                                                          │
 #└──────────────────────────────────────────────────────────────────────────┘
	alias :ligni_load_database :load_database
	def load_database
		ligni_load_database
		Ligni.load_tags
	end
	
end
}
Ligni.register(:rpg_base_item, "ligni", 1.0) {
#╔═════════════════════════════════════════════════════════════════════════════╗
#║ ҉ RPG::BaseItem                                                             ║
#╚═════════════════════════════════════════════════════════════════════════════╝
class RPG::BaseItem
	
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ Variáveis de Instância Públicas                                         │
 #└───────────────────────────────────────────────────────────────────────────┘
	attr_accessor :note_container
	
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ start_note_container                                                    │
 #└───────────────────────────────────────────────────────────────────────────┘
	def start_note_container
		sp = Ligni::NOTE_SEPARATOR
		@note_container = []
		self.note.scan(/#{sp[0]}[^>]*#{sp[1]}/).collect {|tag|
			@note_container.push(tag)
		}
	end
	
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ in_container?                                                           │
 #└───────────────────────────────────────────────────────────────────────────┘
	def in_container?(expr)
		@note_container.find {|tag| tag =~ expr}
	end
  
 #┌───────────────────────────────────────────────────────────────────────────┐
 #│ ♦ get_tag                                                                 │
 #└───────────────────────────────────────────────────────────────────────────┘
  def get_tag(expr)
    tag = in_container?(expr)
    if tag && tag =~ expr
      return $1
    else
      return ""
    end
  end
	
end
}
#==============================================================================
# * Collision
#==============================================================================
Ligni.register(:collision, "ligni", 1.0) {
module Ligni::Collision
  
  #=============================================================================
  # * Point
  #=============================================================================
  class Point
    #---------------------------------------------------------------------------
    # • Public Instance Variables
    #---------------------------------------------------------------------------
    attr_accessor :x, :y
    #---------------------------------------------------------------------------
    # • Initialize
    #---------------------------------------------------------------------------
    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end
    #---------------------------------------------------------------------------
    # • Stroke
    #---------------------------------------------------------------------------
    def stroke(bitmap, size, color = Color.new(0, 200, 255))
      x = size
      y = 0
      err = 0
      while x >= y
        bitmap.set_pixel(@x + x, @y + y, color)
        bitmap.set_pixel(@x + y, @y + x, color)
        bitmap.set_pixel(@x - y, @y + x, color)
        bitmap.set_pixel(@x - x, @y + y, color)
        bitmap.set_pixel(@x - x, @y - y, color)
        bitmap.set_pixel(@x - y, @y - x, color)
        bitmap.set_pixel(@x + y, @y - x, color)
        bitmap.set_pixel(@x + x, @y - y, color)
        y += 1
        err += 2*y+1 if err <= 0
        if err > 0; x -= 1; err -= 2*x+1; end
      end
    end
    #---------------------------------------------------------------------------
    # • Fill
    #---------------------------------------------------------------------------
    def fill(bitmap, size, color = Color.new(0, 200, 255))
      ss = size * size
      for i in 0...size
        a = Math.sqrt(ss - (i * i)).ceil
        bitmap.fill_rect(@x-a, @y-i, 2*a, 1, color)
        bitmap.fill_rect(@x-a, @y+i, 2*a, 1, color)
      end
    end
  end
  #=============================================================================
  # * Segment
  #=============================================================================
  class Segment
    #---------------------------------------------------------------------------
    # • Intersection Data
    #---------------------------------------------------------------------------
    Intersection_Data = {
      int_x: 0,
      int_y: 0,
      no_intersect: 0,
      collinear: 1,
      do_intersect: 2,
      same_sign: ->(a, b) {
        return a * b >= 0
      }
    }
    #---------------------------------------------------------------------------
    # • Pointing From
    #---------------------------------------------------------------------------
    def self.pointing_from(seg, pt, bounded_to_segment = false)    
      cs = Segment.new(seg.x, seg.y, pt.x - seg.x, pt.y - seg.y)
      pj = cs.project(seg)
      ps = Segment.new(seg.x, seg.y, pj.x, pj.y)
      ds = Segment.new(pt.x, pt.y, (ps.x + ps.vx) - pt.x, (ps.y + ps.vy) - pt.y)
      if bounded_to_segment
        if ps.magnitude > seg.magnitude
          ds.x = seg.x + seg.vx
          ds.y = seg.y + seg.vy
          ds.vx = pt.x - (seg.x + seg.vx)
          ds.vy = pt.y - (seg.y + seg.vy)
        elsif ps.vx < 0 || ps.vy < 0
          ds.x = seg.x
          ds.y = seg.y
          ds.vx = pt.x - seg.x
          ds.vy = pt.y - seg.y
        end
      end
      return {distance: ds, casted: cs, projected: ps, point: pj}
    end
    #---------------------------------------------------------------------------
    # • Public Instance Variables
    #---------------------------------------------------------------------------
    attr_accessor :x
    attr_accessor :y
    attr_accessor :vx
    attr_accessor :vy
    #---------------------------------------------------------------------------
    # • Initialize
    #---------------------------------------------------------------------------
    def initialize(x, y, vx, vy)
      @x = x
      @y = y
      @vx = vx
      @vy = vy
    end
    #---------------------------------------------------------------------------
    # • Draw
    #---------------------------------------------------------------------------
    def draw(bitmap, size = 1, color = Color.new(0, 200, 255))
      start_x = @x
      start_y = @y
      end_x = @x + @vx
      end_y = @y + @vy
      set_pixel_s(start_x, start_y, color, size, bitmap)
      distance = (start_x - end_x).abs + (start_y - end_y).abs
      for i in 1..distance
        x = (start_x + 1.0 * (end_x - start_x) * i / distance).to_i
        y = (start_y + 1.0 * (end_y - start_y) * i / distance).to_i
        set_pixel_s(x, y, color, size, bitmap)
      end
      set_pixel_s(end_x, end_y, color, size, bitmap)
    end
    #---------------------------------------------------------------------------
    # • Set Pixel S
    #---------------------------------------------------------------------------
    def set_pixel_s(x, y, color, size, bitmap)
      for i in 0...size
        bitmap.set_pixel(x+i, y, color)
        bitmap.set_pixel(x-i, y, color)
        bitmap.set_pixel(x, y+i, color)
        bitmap.set_pixel(x, y-i, color)
        bitmap.set_pixel(x+i, y+i, color)
        bitmap.set_pixel(x-i, y-i, color)
        bitmap.set_pixel(x+i, y-i, color)
        bitmap.set_pixel(x-i, y+i, color)
      end
    end
    #---------------------------------------------------------------------------
    # • Magnitude
    #---------------------------------------------------------------------------
    def magnitude
      return Math.sqrt(@vx * @vx + @vy * @vy)
    end
    #---------------------------------------------------------------------------
    # • Normal
    #---------------------------------------------------------------------------
    def normal
      x1 = @y
      y1 = @x + @vx
      y2 = @x
      x2 = @y + @vy
      return Segment.new(x1, y1, x2 - x1, y2 - y1)
    end
    #---------------------------------------------------------------------------
    # • Center
    #---------------------------------------------------------------------------
    def center
      _x = @x + @x + @vx
      _y = @y + @y + @vy
      _x /= 2 unless _x.zero?
      _y /= 2 unless _x.zero?
      return Point.new(_x, _y)
    end
    #---------------------------------------------------------------------------
    # • Unit
    #---------------------------------------------------------------------------
    def unit
      mag = magnitude
      return Segment.new(0, 0, @vx / mag, @vy / mag)
    end
    #---------------------------------------------------------------------------
    # • Scale
    #---------------------------------------------------------------------------
    def scale(multiplier)
      @vx *= multiplier
      @vy *= multiplier
    end
    #---------------------------------------------------------------------------
    # • Project
    #---------------------------------------------------------------------------
    def project(on_normal)
      normal = Ligni::Vector.new(on_normal.vx, on_normal.vy)
      vec = Ligni::Vector.new(@vx, @vy)
      num = normal.dot(normal)
      if num < Float::EPSILON
        result = Point.new(0, 0)
        return result
      else
        result = normal * vec.dot(normal) / num
      end
      return Point.new(result.x, result.y)
    end
    #---------------------------------------------------------------------------
    # • Intersect
    #---------------------------------------------------------------------------
    def intersect(segment)
      x1 = @x
      y1 = @y
      x2 = @x + @vx
      y2 = @y + @vy
      x3 = segment.x
      y3 = segment.y
      x4 = segment.x + segment.vx
      y4 = segment.y + segment.vy
      a1 = y2 - y1
      b1 = x1 - x2
      c1 = (x2 * y1) - (x1 * y2)
      r3 = ((a1 * x3) + (b1 * y3) + c1)
      r4 = ((a1 * x4) + (b1 * y4) + c1)
      if r3 != 0 && r4 != 0 && Intersection_Data[:same_sign].call(r3, r4)
        return Intersection_Data[:no_intersect]
      end
      a2 = y4 - y3
      b2 = x3 - x4
      c2 = (x4 * y3) - (x3 * y4)
      r1 = (a2 * x1) + (b2 * y1) + c2
      r2 = (a2 * x2) + (b2 * y2) + c2
      if r1 != 0 && r2 != 0 && Intersection_Data[:same_sign].call(r1, r2)
        return Intersection_Data[:no_intersect]
      end
      denom = (a1 * b2) - (a2 * b1)
      if denom == 0
        return Intersection_Data[:collinear]
      end
      if denom < 0
        offset = -denom / 2
      else
        offset = denom / 2
      end
      num = (b1 * c2) - (b2 * c1)
      if num < 0
        Intersection_Data[:int_x] = (num - offset) / denom
      else
        Intersection_Data[:int_x] = (num + offset) / denom
      end
      num = (a2 * c1) - (a1 * c2)
      if num < 0
        Intersection_Data[:int_y] = (num - offset) / denom
      else
        Intersection_Data[:int_y] = (num + offset) / denom
      end
      return Intersection_Data[:do_intersect]
    end
    #---------------------------------------------------------------------------
    # • Point Inside?
    #---------------------------------------------------------------------------
    def point_inside?(x, y)
      ps = Segment.pointing_from(self, Point.new(x, y), true)
      distance_segment = ps[:distance]
      return distance_segment.magnitude <= 1
    end
  end
  #=============================================================================
  # * Circle
  #=============================================================================
  class Circle
    #---------------------------------------------------------------------------
    # • Public Instance Variables
    #---------------------------------------------------------------------------
    attr_accessor :x
    attr_accessor :y
    attr_accessor :radius
    #---------------------------------------------------------------------------
    # • Initialize
    #---------------------------------------------------------------------------
    def initialize(x, y, radius)
      @x = x
      @y = y
      @radius = radius
      @radius_line = Segment.new(@x, @y, @radius, 0)
    end
    #---------------------------------------------------------------------------
    # • Stroke
    #---------------------------------------------------------------------------
    def stroke(bitmap, color = Color.new(0, 200, 255))
      x = @radius
      y = 0
      err = 0
      while x >= y
        bitmap.set_pixel(@x + x, @y + y, color)
        bitmap.set_pixel(@x + y, @y + x, color)
        bitmap.set_pixel(@x - y, @y + x, color)
        bitmap.set_pixel(@x - x, @y + y, color)
        bitmap.set_pixel(@x - x, @y - y, color)
        bitmap.set_pixel(@x - y, @y - x, color)
        bitmap.set_pixel(@x + y, @y - x, color)
        bitmap.set_pixel(@x + x, @y - y, color)
        y += 1
        err += 2*y+1 if err <= 0
        if err > 0; x -= 1; err -= 2*x+1; end
      end
    end
    #---------------------------------------------------------------------------
    # • Fill
    #---------------------------------------------------------------------------
    def fill(bitmap, color = Color.new(0, 200, 255))
      ss = @radius * @radius
      for i in 0...@radius
        a = Math.sqrt(ss - (i * i)).round
        bitmap.fill_rect(@x-a, @y-i, 2*a, 1, color)
        bitmap.fill_rect(@x-a, @y+i, 2*a, 1, color)
      end
    end
    #---------------------------------------------------------------------------
    # • Draw Radius
    #---------------------------------------------------------------------------
    def draw_radius(bitmap, color = Color.new(255, 22, 43))
      @radius_line.draw(bitmap, color)
    end
    #---------------------------------------------------------------------------
    # • Point Inside?
    #---------------------------------------------------------------------------
    def point_inside?(px, py)
      seg = Segment.new(@x, @y, px - @x, py - @y)
      return seg.magnitude <= @radius
    end
    #---------------------------------------------------------------------------
    # • Line Inside?
    #---------------------------------------------------------------------------
    def line_inside?(startx, starty, endx, endy)
      seg = Segment.new(startx, starty, endx, endy)
      seg2 = Segment.new(startx, starty, @x - startx, @y - starty)
      point = seg2.project(seg)
      seg3 = Segment.new(startx, starty, point.x, point.y)
      seg4 = Segment.new(@x, @y, seg3.x + seg3.vx - @x, seg3.y + seg3.vy - @y)
      if point_inside?(seg.x + seg.vx, seg.y + seg.vy)
        return true
      elsif point_inside?(seg.x, seg.y)
        return true
      else
        if seg4.magnitude <= @radius
          if seg.magnitude >= seg3.magnitude
            a = Ligni::Vector.new(seg.vx, seg.vy)
            b = Ligni::Vector.new(seg3.vx, seg3.vy)
            if b.dot(a) <= 0
              return false
            else
              return true
            end
          else
            return false
          end
        else
          return false
        end
      end
    end
    #---------------------------------------------------------------------------
    # • In Circle?
    #---------------------------------------------------------------------------
    def in_circle?(circle)
      seg = Segment.new(@x, @y, circle.x - @x, circle.y - @y)
      return seg.magnitude <= @radius + circle.radius
    end
    #---------------------------------------------------------------------------
    # • In Rectangle?
    #---------------------------------------------------------------------------
    def in_rectangle?(rect)
      intersected = false
      for seg in rect.segments
        if line_inside?(seg.x, seg.y, seg.vx, seg.vy)
          intersected = true
          break
        end
      end
      if !intersected
        intersected = true if rect.point_inside?(@x, @y)
      end
      return intersected
    end
  end
  #=============================================================================
  # * Rectangle
  #=============================================================================
  class Rectangle
    #---------------------------------------------------------------------------
    # • Public Instance Variables
    #---------------------------------------------------------------------------
    attr_accessor :x
    attr_accessor :y
    attr_accessor :width
    attr_accessor :height
    #---------------------------------------------------------------------------
    # • Initialize
    #---------------------------------------------------------------------------
    def initialize(x, y, width, height)
      @x = x
      @y = y
      @width = width
      @height = height
    end
    #---------------------------------------------------------------------------
    # • Fill
    #---------------------------------------------------------------------------
    def fill(bitmap, color = Color.new(0, 200, 255))
      bitmap.fill_rect(@x, @y, @width, @height, color)
    end
    #---------------------------------------------------------------------------
    # • Stroke
    #---------------------------------------------------------------------------
    def stroke(bitmap, size = 1, color = Color.new(0, 200, 255))
      bitmap.fill_rect(@x, @y, @width, size, color)
      bitmap.fill_rect(@x + @width - size, @y, size, @height, color)
      bitmap.fill_rect(@x, @y + @height - size, @width, size, color)
      bitmap.fill_rect(@x, @y, size, @height, color)
    end
    #---------------------------------------------------------------------------
    # • Point Inside?
    #---------------------------------------------------------------------------
    def point_inside?(x, y)
      c1 = x >= @x && x <= @x + @width
      c2 = y >= @y && y <= @y + @height
      return c1 && c2
    end
    #---------------------------------------------------------------------------
    # • Rect Inside?
    #---------------------------------------------------------------------------
    def rect_inside?(rect)
      if @x < rect.x + rect.width && @x + @width > rect.x
        if @y < rect.y + rect.height && @y + @height > rect.y
          return true
        end
      end
      return false
    end
    #---------------------------------------------------------------------------
    # • Line Inside?
    #---------------------------------------------------------------------------
    def line_inside?(segment)
      intersected = false
      for seg in segments
        if seg.intersect(segment) == Segment::Intersection_Data[:do_intersect]
          intersected = true
          break
        end
      end
      return intersected
    end
    #---------------------------------------------------------------------------
    # • Center
    #---------------------------------------------------------------------------
    def center
      return Point.new(@x + @width * 0.5, @y + @height * 0.5)
    end
    #---------------------------------------------------------------------------
    # • Bounds
    #---------------------------------------------------------------------------
    def bounds
      min_x = @x
      min_y = @y
      max_x = @x + @width
      max_y = @y + @height
      return {
        :top_left => [min_x, min_y],
        :top_right => [max_x, min_y],
        :bottom_left => [min_x, max_y],
        :bottom_right => [max_x, max_y]
      }
    end
    #---------------------------------------------------------------------------
    # • Left Segment
    #---------------------------------------------------------------------------
    def left_segment
      return Segment.new(@x, @y, 0, @height)
    end
    #---------------------------------------------------------------------------
    # • Right Segment
    #---------------------------------------------------------------------------
    def right_segment
      return Segment.new(@x + @width, @y, 0, @height)
    end
    #---------------------------------------------------------------------------
    # • Top Segment
    #---------------------------------------------------------------------------
    def top_segment
      return Segment.new(@x, @y, @width, 0)
    end
    #---------------------------------------------------------------------------
    # • Bottom Segment
    #---------------------------------------------------------------------------
    def bottom_segment
      return Segment.new(@x, @y + @height, @width, 0)
    end
    #---------------------------------------------------------------------------
    # • Segments
    #---------------------------------------------------------------------------
    def segments
      return [left_segment, right_segment, top_segment, bottom_segment]
    end
  end
  #=============================================================================
  # * Polygon
  #=============================================================================
  class Polygon
    #---------------------------------------------------------------------------
    # • Public Instance Variables
    #---------------------------------------------------------------------------
    attr_reader :points
    attr_reader :edges
    attr_reader :segments
    #---------------------------------------------------------------------------
    # • Rect
    #---------------------------------------------------------------------------
    def self.rect(x, y, width, height)
      pol = Polygon.new
      pol.points.push(Ligni::Vector.new(x, y), Ligni::Vector.new(x + width, y),
        Ligni::Vector.new(x + width, y + height), Ligni::Vector.new(x, y + height))
      pol.build_edges
      return pol
    end
    #---------------------------------------------------------------------------
    # • Initialize
    #---------------------------------------------------------------------------
    def initialize
      @points = []
      @edges = []
      @segments = []
    end
    #---------------------------------------------------------------------------
    # • Build Edges
    #---------------------------------------------------------------------------
    def build_edges
      @edges.clear
      @segments.clear
      for i in 0...@points.size
        p1 = @points[i]
        p2 = @points[i + 1 >= @points.size ? 0 : i + 1]
        @segments.push(Segment.new(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y))
        @edges.push(p2 - p1)
      end
    end
    #---------------------------------------------------------------------------
    # • Draw Segments
    #---------------------------------------------------------------------------
    def draw_segments(bitmap, size = 1, color = Color.new(0, 200, 255))
      for i in 0...@segments.size
        @segments[i].draw(bitmap, size, color)
      end
    end
    #---------------------------------------------------------------------------
    # • Center
    #---------------------------------------------------------------------------
    def center
      total_x = 0
      total_y = 0
      for i in 0...@points.size
        total_x += @points[i].x
        total_y += @points[i].y
      end
      return Ligni::Vector.new(total_x / @points.size.to_f, total_y / @points.size.to_f)
    end
    #---------------------------------------------------------------------------
    # • Offset
    #---------------------------------------------------------------------------
    def offset(*args)
      if args.size == 1
        x = args.x
        y = args.y
      else
        x = args[0]
        y = args[1]
      end
      for i in 0...@points.size
        pt = @points[i]
        pt.x += x
        pt.y += y
      end
    end
    #---------------------------------------------------------------------------
    # • Get Rect
    #---------------------------------------------------------------------------
    def get_rect
      return if @points.size == 0
      min_x = @points[0].x
      min_y = @points[0].y
      max_x = @points[0].x
      max_y = @points[0].y
      for i in 0...@points.size
        if min_x > @points[i].x
          min_x = @points[i].x
        elsif max_x < @points[i].x
          max_x = @points[i].x
        end
        if min_y > @points[i].y
          min_y = @points[i].y
        elsif max_y < @points[i].y
          max_y = @points[i].y
        end
      end
      return Rectangle.new(min_x, min_y, max_x - min_x, max_y - min_y)
    end
    #---------------------------------------------------------------------------
    # • Point Inside?
    #---------------------------------------------------------------------------
    def point_inside?(x, y, ird = Vector.new(30, -40))
      return false if @points.size < 3
      rect = get_rect
      return false if !rect.point_inside?(x, y)
      ray_point = Point.new(rect.x - ird.x, rect.y - ird.y)
      ray = Segment.new(ray_point.x, ray_point.y, x - ray_point.x, y - ray_point.y)
      hit_count = 0
      for segment in @segments
        pi = segment.point_inside?(x, y)
        if pi
          hit_count += 1
          next
        end
        ia = segment.intersect(ray)
        if ia != Segment::Intersection_Data[:no_intersect]
          hit_count += 1
        end
      end
      return hit_count.odd?
    end
    #---------------------------------------------------------------------------
    # • Circle Inside?
    #---------------------------------------------------------------------------
    def circle_inside?(x, y, radius)
      return false if @points.size < 3
      rect = get_rect
      rect.x -= radius
      rect.y -= radius
      rect.width += radius + radius
      rect.height += radius + radius
      return false if !rect.point_inside?(x, y)
      return true if point_inside?(x, y)
      circle = Circle.new(x, y, radius)
      for segment in @segments
        if circle.line_inside?(segment.x, segment.y, segment.vx, segment.vy)
          return true
        end
      end
      return false
    end
    #---------------------------------------------------------------------------
    # • Rect Inside?
    #---------------------------------------------------------------------------
    def rect_inside?(rect)
      return false if @points.size < 3
      r = get_rect
      return false if !r.rect_inside?(rect)
      intersected = false
      for segment in @segments
        if rect.line_inside?(segment)
          intersected = true
          break
        end
      end
      if !intersected
        intersected = true if point_inside?(rect.x, rect.y)
      end
      return intersected
    end
    #---------------------------------------------------------------------------
    # • Polygon Inside?
    #---------------------------------------------------------------------------
    def polygon_inside?(poly)
      return false if @points.size < 3
      r = get_rect
      return false if !r.rect_inside?(poly.get_rect)
      intersected = false
      for segment in @segments
        for seg in poly.segments
          if segment.intersect(seg) == Segment::Intersection_Data[:do_intersect]
            intersected = true
            break
          end
        end
      end
      if !intersected
        intersected = true if point_inside?(poly.segments[0].x, poly.segments[0].y)
      end
      return intersected
    end
  end
end
}
#==============================================================================
# * Advanced Sprite
#==============================================================================
Ligni.register(:advanced_sprite, "ligni", 1.0) {
class Ligni::Advanced_Sprite < Sprite
  #---------------------------------------------------------------------------
  # • Public Instance Variables
  #---------------------------------------------------------------------------
  attr_accessor :mass
  #---------------------------------------------------------------------------
  # • initialize
  #---------------------------------------------------------------------------
  def initialize(vp = nil)
    super
    @position = Ligni::Vector.new(self.x, self.y)
    @velocity = Ligni::Vector.zero
    @mass = 1
    @components = []
    @added_components = []
    @initialized = true
  end
  #---------------------------------------------------------------------------
  # • x
  #---------------------------------------------------------------------------
  def x
    return @position.x if @initialized
    super
  end
  #---------------------------------------------------------------------------
  # • x=
  #---------------------------------------------------------------------------
  def x=(v)
    @position.x = v if @initialized
    super
  end
  #---------------------------------------------------------------------------
  # • y
  #---------------------------------------------------------------------------
  def y
    return @position.y if @initialized
    super
  end
  #---------------------------------------------------------------------------
  # • y=
  #---------------------------------------------------------------------------
  def y=(v)
    @position.y = v if @initialized
    super
  end
  #---------------------------------------------------------------------------
  # • velocity
  #---------------------------------------------------------------------------
  def velocity
    return @velocity
  end
  #---------------------------------------------------------------------------
  # • velocity=
  #---------------------------------------------------------------------------
  def velocity=(v)
    return unless v.is_a?(Ligni::Vector)
    @velocity.set(v.x, v.y)
  end
  #---------------------------------------------------------------------------
  # • position
  #---------------------------------------------------------------------------
  def position
    return @position
  end
  #---------------------------------------------------------------------------
  # • position=
  #---------------------------------------------------------------------------
  def position=(v)
    return unless v.is_a?(Ligni::Vector)
    self.x = v.x
    self.y = v.y
  end
  #---------------------------------------------------------------------------
  # • add_force
  #---------------------------------------------------------------------------
  def add_force(force)
    x = force[0] if force.is_a?(Array)
    y = force[1] if force.is_a?(Array)
    x = force.x if force.is_a?(Ligni::Vector)
    y = force.y if force.is_a?(Ligni::Vector)
    if !x.nil? && !x.zero?
      @velocity.x += x.to_f / @mass
    end
    if !y.nil? && !y.zero?
      @velocity.y += y.to_f / @mass
    end
  end
  #---------------------------------------------------------------------------
  # • add_component
  #---------------------------------------------------------------------------
  def add_component(component)
    verify_dup_component(component)
    @components.push(Ligni::Advanced_Sprite_Component.new(self, component))
    @added_components.push(component)
  end
  #---------------------------------------------------------------------------
  # • add_components
  #---------------------------------------------------------------------------
  def add_components(*components)
    for c in components
      verify_dup_component(c)
      @components.push(Ligni::Advanced_Sprite_Component.new(self, c))
      @added_components.push(c)
    end
  end
  #---------------------------------------------------------------------------
  # • verify_dup_component
  #---------------------------------------------------------------------------
  def verify_dup_component(type)
    if @added_components.include?(type)
      raise("Já existe um componente do tipo #{type} no sprite.")
    end
  end
  #---------------------------------------------------------------------------
  # • get_component
  #---------------------------------------------------------------------------
  def get_component(type)
    if @added_components.include?(type)
      return @components[@added_components.index(type)]
    end
    return nil
  end
  #---------------------------------------------------------------------------
  # • gravity
  #---------------------------------------------------------------------------
  def gravity
    return get_component(:gravity)
  end
  #---------------------------------------------------------------------------
  # • anchor
  #---------------------------------------------------------------------------
  def anchor
    return get_component(:anchor)
  end
  #---------------------------------------------------------------------------
  # • movement_2d
  #---------------------------------------------------------------------------
  def movement_2d
    return get_component(:movement_2d)
  end
  #---------------------------------------------------------------------------
  # • after_effect
  #---------------------------------------------------------------------------
  def after_effect
    return get_component(:after_effect)
  end
  #---------------------------------------------------------------------------
  # • size
  #---------------------------------------------------------------------------
  def size
    return get_component(:size)
  end
  #---------------------------------------------------------------------------
  # • update
  #---------------------------------------------------------------------------
  def update
    super
    update_velocity
    update_components
  end
  #---------------------------------------------------------------------------
  # • update_components
  #---------------------------------------------------------------------------
  def update_components
    @components.each { |c| c.update }
  end
  #---------------------------------------------------------------------------
  # • update_velocity
  #---------------------------------------------------------------------------
  def update_velocity
    self.x += @velocity.x
    self.y += @velocity.y
    @velocity = Ligni::Vector.move_towards(@velocity, Ligni::Vector.zero, 0.01 * @mass)
  end
  
end
}
#==============================================================================
# * Advanced_Sprite_Component
#==============================================================================
Ligni.register(:advanced_sprite_component, "ligni", 1.0) {
class Ligni::Advanced_Sprite_Component
  #---------------------------------------------------------------------------
  # • initialize
  #---------------------------------------------------------------------------
  def initialize(main, type)
    @main = main
    @type = type
    @gravity = Ligni::Vector.new(0, 0.3) if type == :gravity
    @anchor = Ligni::Vector.new(0, 0) if type == :anchor
    @haxis = Ligni::Axis.new(:RIGHT, :LEFT) if type == :movement_2d
    @vaxis = Ligni::Axis.new(:DOWN, :UP) if type == :movement_2d
    @haxis.limit = 4.0 if type == :movement_2d
    @vaxis.limit = 4.0 if type == :movement_2d
    @ae_sprites = [] if type == :after_effect
    @ae_settings = {
      lifetime: 0.05,
      max_sprites: 6,
      opacity_modifier: 0.1
    } if type == :after_effect
    @ae_timer = 0
    @size = Ligni::Vector.new(1.0, 1.0) if type == :size
  end
  #---------------------------------------------------------------------------
  # • access
  #---------------------------------------------------------------------------
  def access
    return @gravity if @type == :gravity
    return @anchor if @type == :anchor
    return [@haxis, @vaxis] if @type == :movement_2d
    return [@ae_sprites, @ar_settings, @ae_timer] if @type == :after_effect
    return @size if @type == :size
    return raise("Componente não implementado.")
  end
  #---------------------------------------------------------------------------
  # • update
  #---------------------------------------------------------------------------
  def update
    update_gravity if @type == :gravity
    update_anchor if @type == :anchor
    update_2d_movement if @type == :movement_2d
    update_after_effect if @type == :after_effect
    update_size if @type == :size
  end
  #---------------------------------------------------------------------------
  # • update_gravity
  #---------------------------------------------------------------------------
  def update_gravity
    @main.velocity.x += @gravity.x * (@main.mass.to_f * 0.1)
    @main.velocity.y += @gravity.y * (@main.mass.to_f * 0.1)
  end
  #---------------------------------------------------------------------------
  # • update_anchor
  #---------------------------------------------------------------------------
  def update_anchor
    bw = @main.bitmap.width rescue 0
    bh = @main.bitmap.height rescue 0
    @main.ox = bw * @anchor.x
    @main.oy = bh * @anchor.y
  end
  #---------------------------------------------------------------------------
  # • update_2d_movement
  #---------------------------------------------------------------------------
  def update_2d_movement
    @main.x += @haxis.axis
    @main.y += @vaxis.axis
    @haxis.update
    @vaxis.update
  end
  #---------------------------------------------------------------------------
  # • update_after_effect
  #---------------------------------------------------------------------------
  def update_after_effect
    if @ae_timer <= 0
      spawn_after_effect
      @ae_timer =  @ae_settings[:lifetime]
    end
    if @ae_sprites.size > @ae_settings[:max_sprites]
      @ae_sprites[0].bitmap.dispose
      @ae_sprites.delete_at(0)
    end
    for i in 0...@ae_sprites.size
      @ae_sprites[i].opacity = @main.opacity * (i * @ae_settings[:opacity_modifier])
    end
    @ae_timer = Ligni::Mathf.move_towards(@ae_timer, 0, 0.016667)
  end
  #---------------------------------------------------------------------------
  # • spawn_after_effect
  #---------------------------------------------------------------------------
  def spawn_after_effect
    @ae_sprites.push(Sprite.new)
    spr = @ae_sprites[-1]
    spr.bitmap = @main.bitmap.clone
    spr.x = @main.x
    spr.y = @main.y
    spr.z = @main.z - 1
    spr.ox = @main.ox
    spr.oy = @main.oy
  end
  #---------------------------------------------------------------------------
  # • update_size
  #---------------------------------------------------------------------------
  def update_size
    @main.zoom_x = @size.x
    @main.zoom_y = @size.y
  end
  
end
}
#==============================================================================
# * SceneManager
#==============================================================================
Ligni.register(:scenemanager, "ligni", 1.0) {
if defined?("SceneManager")
  class  << SceneManager
    #--------------------------------------------------------------------------
    # • Chama uma outra scene.
    #     scene_symbol : Nome da scene, podendo ser em símbolo ou string.
    #--------------------------------------------------------------------------
    def symbol(scene_symbol)
      eval("self.call(#{scene_symbol.to_s})")
    end
    alias :eval :symbol
  end
end
}
#==============================================================================
# ҉ Graphics
#==============================================================================
Ligni.register(:graphic, "ligni", 1.0) {
class << Graphics
  #----------------------------------------------------------------------------
  # • update
  #----------------------------------------------------------------------------
  alias :_ligni_graphics_update :update
  def update
    Ligni.update
    _ligni_graphics_update
  end
end
} 
#==============================================================================
# • Desativar scripts : Para fazer, basta por no nome do script da lista,
# [D].
# • Salvar script em arquivo de texto : Para fazer, basta por no nome do script da lista,
# [S].
#==============================================================================
$RGSS_SCRIPTS.each_with_index { |data, index|
 if data.at(1).include?("[S]")
   File.open("#{rgss.at(1)}.txt", "wb") { |file|
      file.write(String($RGSS_SCRIPTS.at(index)[3]))
      file.close
    }
 end
 $RGSS_SCRIPTS.at(index)[2] = $RGSS_SCRIPTS.at(index)[3] = "" if data.at(1).include?("[D]")
}
#==============================================================================
# * Object
#==============================================================================
Ligni.register(:kernel, "ligni", 1.0) {
  class << Kernel 
    #-----------------------------------------------------------------------------
    # • Carregar arquivo e executar.
    #     path : Nome do arquivo.
    #-----------------------------------------------------------------------------
    def load_script(path)
      raise("Arquivo não encontrado %s" % path) unless FileTest.exist?(path)
      return eval(load_data(path)) if File.extname(path) == ".rvdata2"
      return eval(File.open(path).read) rescue nil
    end
    #----------------------------------------------------------------------------
    # • powershell exec command
    #     cmd : Command
    #----------------------------------------------------------------------------
    def powershell(cmd)
      API::Powershell.run(cmd)
    end
    alias :ps :powershell
  end
}

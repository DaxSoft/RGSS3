#==============================================================================
# * Dax Core
#==============================================================================
# Autor : Dax Aquatic X
# Coadjuvantes : 
#     Gab!(Método de registrar scripts)
#     Gotoken : Módulo de Benchmark.
#     Module PNG&RTP : Autor desconhecido.
# Versão : Core i8.5
# Site : www.dax-soft.weebly.com
# Suporte : dax-soft@live.com
#==============================================================================
#  Um Core com vários módulos e métodos que facilitará na hora de programar os
# seus scripts, bom proveito.
#==============================================================================
# Conteúdo : • TAGS : Para facilitar a localização dos códigos e explicações. Para acessar
# o comando para localizar, basta apertar Ctrl+F.
#==============================================================================
# i :
#   - Array :array
#   - Hash :hash
#   - API :api
#   - String :string
#   - Integer :integer
#   - Numeric :numeric
#   - Position :position
#   - File :file
#   - Dir :dir
#   - Rect :rect
#   - Color :color
#   - DMath :dmath
#   - Key :key
#   - Mouse :mouse
#   - Object :object
#   - Entries :entries
#   - DRGSS :drgss
#   - Backup :backup
#   - SceneManager :scenemanager
#   - Sprite_Text :sprite_text
#   - Opacity :opacity
#   - Read :read
#   - Window_Base :window_base
#   - SoundBase :soundbase
#   - Benchmark :benchmark
#   - Input :input
#   - Graphics :graphics
#   - Powershell :powershell
#==============================================================================
# • Adicionado comentário padrão. Veja o modo que agora os comentários dos 
# métodos estão.
#==============================================================================
# • [Classe do Retorno] : Explicação.
#   * Exemplo.(Se possível.)
#==============================================================================
module Dax
  extend self
  #----------------------------------------------------------------------------
  # • Constantes : 
  #----------------------------------------------------------------------------
  #  A imagem do ícone do Mouse tem que estar na pasta [System]. Basta você
  # por o nome da imagem dentro das áspas. Caso você queira usar um ícone
  # do Rpg Maker no lugar de uma imagem, basta você por o id do ícone no lugar
  # das áspas.
  MOUSE_NAME = ""
  #----------------------------------------------------------------------------
  # • Variáveis.
  #----------------------------------------------------------------------------
  @@data                   = {} # Variável que irá cuidar do registro.
  @@__data                 = {} # Variável cache do registro.
  #----------------------------------------------------------------------------
  # • [NilClas] : Registrar o script, caso já exista ele atualiza.
  #     [symbol] : name : Nome do script.
  #     [string] : author : Autor(es) do script.
  #     [numeric] : version : Versão do script.
  #     [array] : requires : Requerimento para o script ser executado. OPCIONAL
  #     [proc] : &block : Bloco do script que será executado.
  #
  #    requires : Defina dentro da array, uma outra array, que contenha
  # o nome do script, o nome do autor e caso deseja, a versão do mesmo.
  #   
  #   * Script registrado.
  #   
  #   Dax.register(:test, "dax", 1.0) {
  #     Test = Class.new { def initialize; msgbox("ok"); end; }
  #     Test.new
  #   }
  #   
  #   * Script registrado com requerimentos.
  #
  #   Dax.register(:test2, "dax", 1.0, [[:test, "dax", 1.0]]) {
  #     Test.new
  #   }
  #----------------------------------------------------------------------------
  def register(name, author, version, requires=[], &block)
    need = []
    requires.each { |data| need << data unless self.registred?(*data) }
    if need.empty?
      @@data[[name, author]] = version
      block.call
      @@__data.each_pair { |(cache_name, cache_author, cache_version), (_need, _block)|
        _need.delete_if { |_n_| self.registred?(*_n_) }
        next unless _need.empty?
        @@__data.delete([cache_name, cache_author, cache_version])
        self.register(cache_name, cache_author, cache_version, &_block)
      }
    else
      @@__data[[name, author, version]] = [need, block]
    end
    return nil
  end
  #----------------------------------------------------------------------------
  # • [Boolean] : Verificar se está registrado.
  #     [symbol] : name : Nome do script.
  #     [string] : author : Autor(es) do script.
  #     [numeric] : version : Versão do script.
  #     [array] : requires : Requerimento para o script ser executado. OPCIONAL
  #----------------------------------------------------------------------------
  def registred?(name, author, version=nil)
    if @@data.has_key?([name, author])
      return true if version.nil?
      _version = @@data[[name, author]]
      return _version >= version
    else
      return false
    end
  end
  #----------------------------------------------------------------------------
  # • Definir um script como requisição. Caso o script não exista, uma mensagem
  # de erro será executado.
  #     [symbol] : name : Nome do script.
  #     [string] : author : Autor(es) do script.
  #     [numeric] : version : Versão do script.
  #----------------------------------------------------------------------------
  def required(name, author, version=nil)
    if @@data.has_key?([name, author])
      return true if version.nil?
      _version = @@data[[name, author]]
      if _version >= version
        return true
      else
        msgbox("Script desatualizado: #{String(name)} v#{String(_version)} por #{String(author)}\nVersão requerida: #{version}")
        exit
      end
    else
      msgbox("Script não encontrado: #{String(name)} v#{String(version)} por #{String(author)}") 
      exit
    end
  end
  
  #----------------------------------------------------------------------------
  # • Retorna a variável @@data.
  #----------------------------------------------------------------------------
  def data
    @@data
  end
  #----------------------------------------------------------------------------
  # * Remove uma [Classe], exemplo: Dax.remove(:Scene_Menu)
  #----------------------------------------------------------------------------
  def remove(symbol_name)
    Object.send(:remove_const, symbol_name)
  end
end
#==============================================================================
# • Array
#==============================================================================
Dax.register(:array, "dax", 2.0) {
class Array
  attr_reader   :next
  attr_reader   :pred
  #----------------------------------------------------------------------------
  # • [Hash] : Transforma a Array para uma Hash.
  #     Define um valor padrão para todas as chaves.
  #     [1, 2].to_hash_keys { :default_value }
  #     { 1 => :default_value, 2 => :default_value }
  #----------------------------------------------------------------------------
  def to_hash_keys(&block)
    Hash[*self.collect { |v|
        [v, block.call(v)]
      }.flatten]
  end
  #----------------------------------------------------------------------------
  # • [Array] : Sorteia os objetos em ordem crescente.
  #----------------------------------------------------------------------------
  def crescent
    sort! { |a, b| a <=> b }
  end
  #----------------------------------------------------------------------------
  # • [Array] : Sorteia os objetos em ordem decrescente.
  #----------------------------------------------------------------------------
  def decrescent
    sort! { |a, b| b <=> a }
  end
  #----------------------------------------------------------------------------
  # • [Object] : Retorna para o próximo objeto da id da Array.
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
  # • [Object] : Retorna para o objeto anterior da id da Array.
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
  # • [Array] Retorna ao elemento da array que condiz com a condição 
  # definida no bloco.
  # Exemplo: 
  #   [2, 4, 5, 6, 8].if { |element| element >= 4 }
  #    # 5, 6, 8
  #----------------------------------------------------------------------------
  def if
    return unless block_given?
    getResult = []
    self.each_with_index{ |arrays| getResult << arrays if yield(arrays) } 
    return getResult
  end
  #----------------------------------------------------------------------------
  # • [Mixed] : Retorna ao primeiro valor da array, que obedeça a 
  # condição posta.
  # msgbox [2, 3, 4, 5, 6].first! { |n| n.is_evan? } #> 2
  # msgbox [2, 3, 4, 5, 6].first! { |n| n.is_odd? } #> 3
  #----------------------------------------------------------------------------
  def first!
    return unless block_given?
    return self.each { |element| return element if yield(element) }.at(0)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna ao valor de todos os conteúdos, desde que seja números,
  # somados, ou subtraidos, ou multiplicado. Por padrão é soma.
  #    v : :+ # Somar
  #        :- # Subtrair
  #        :* # Multiplicar.
  #----------------------------------------------------------------------------
  def alln?(v=:+)
    n = v == :* ? 1 : 0
    self.if {|i| i.is_a?(Numeric) }.each { |content| 
      n += content if v == :+
      n -= content if v == :-
      n *= content if v == :*
    }
    return n
  end
end
}
#==============================================================================
# • Hash
#==============================================================================
Dax.register(:hash, "dax", 1.3) {
class Hash
  #----------------------------------------------------------------------------
  # • [NilClass or Mixed] : Pega o valor da chave específicada.
  #     key : Chave.
  #     block(proc) : Condição para que retorna ao valor da chave. Opcional.
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
  # • [Mix] : Retorna a última chave adicionada.
  #----------------------------------------------------------------------------
  def last_key
    return self.keys.last
  end
end
}
#==============================================================================
# • API : Módulo que armazena informações de algumas APIS.
#==============================================================================
Dax.register(:api, "dax", 3.0) {
module API
  extend self
  #----------------------------------------------------------------------------
  # • [String] : Tipos e seus retornos.. Pegado da internet.. Autor desconhecido
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
  # • [Array] : Pega os valores especificados no método.. depois verifica
  # cada um se é String ou Symbol. Se for Symbol retorna ao valor especificado
  # na Constante TYPES.
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
  # • [Dll]// : Especifica uma função, com o valor da importação é a DLL..
  # Por padrão a DLL é a "user32". O valor de exportação será "i"
  #----------------------------------------------------------------------------
  def int(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "i") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value| 
        define_method(key) { return value.is_a?(Array) ? api.call(*value) : value }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  alias :bool :int
  #----------------------------------------------------------------------------
  # • [Dll]// : Especifica uma função, com o valor da importação é a DLL..
  # Por padrão a DLL é a "user32". O valor de exportação será "l"
  #----------------------------------------------------------------------------
  def long(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "l") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value| 
        define_method(key) { return value.is_a?(Array) ? api.call(*value) : value }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [Dll]// : Especifica uma função, com o valor da importação é a DLL..
  # Por padrão a DLL é a "user32". O valor de exportação será "v"
  #----------------------------------------------------------------------------
  def void(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "v") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value| 
        define_method(key) { return value.is_a?(Array) ? api.call(*value) : value }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [Dll]// : Especifica uma função, com o valor da importação é a DLL..
  # Por padrão a DLL é a "user32". O valor de exportação será "p"
  #----------------------------------------------------------------------------
  def char(function, import, dll="user32")
    api = Win32API.new(dll, function, types(import), "p") rescue nil
    return api unless block_given?
    return Module.new {
      yield.each { |key, value| 
        define_method(key) { return value.is_a?(Array) ? api.call(*value) : value }
        module_function key
      } if yield.is_a?(Hash)
      define_method(:call) { |*args| api.call(*args) }
      module_function(:call)
    }
  end
  #----------------------------------------------------------------------------
  # • [Dll]// : Com esse método você pode especificar uma função de uma Dll.
  #   function(export, function, import, dll)
  #    export : Valor da exportação. Formato [Symbol]
  #    function : Função da Dll.
  #    import : Valor da importação.
  #    dll : Dll. Por padrão é a User32
  #          Esconder o Mouse.
  # Exemplo: function(:int, "ShowCursor", [:BOOL]).call(0)
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
  # • Tela chéia
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
    return API::FindWindow.call('RGSS Player', game_title || load_data("./Data/System.rvdata2").game_title.to_s)
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
  Shellxecute = long("ShellExecute", [:LPCTSTR, :LPCTSTR, :LPCTSTR,
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
  #============================================================================
  # • MessageBox
  #============================================================================
  module MessageBox
    extend self
    # handle, string, title, format.
    FunctionMessageBox = Win32API.new("user32", "MessageBoxW", "lppl", "l")
    #--------------------------------------------------------------------------
    # • [Constantes] Botões:
    #--------------------------------------------------------------------------
    # Adiciona três botões a mensagem: Anular, Repetir e Ignorar.
    ABORTRETRYIGNORE = 0x00000002
    # Adiciona três botões a mensagem: Cancelar, Tentar e Continuar.
    CANCELTRYCONTINUE = 0x00000006
    # Adiciona o botão de ajuda.
    HELP = 0x00004000
    # Adiciona o botão Ok.
    SOK = 0x00000000
    # Adiciona o botão OK e Cancelar.
    OKCANCEL = 0x00000001
    # Adiciona os botões: Repetir e Cancelar.
    RETRYCANCEL = 0x00000005
    # Adiciona os botões: Sim e Não
    YESNO = 0x00000004
    # Adiciona os botões: Sim, Não e Cancelar
    YESNOCANCEL = 0x00000003
    #--------------------------------------------------------------------------
    # • [Constantes] Ícones:
    #--------------------------------------------------------------------------
    # Adiciona um ícone de exclamação
    ICONEXCLAMATION = 0x00000030
    # Adiciona um ícone de informação.
    ICONINFORMATION = 0x00000040
    # Adiciona um ícone de um círculo com um ponto de interrogação.
    ICONQUESTION = 0x00000020
    # Adiciona um íconde parar na mensagem.
    ICONSTOP = 0x00000010
    #--------------------------------------------------------------------------
    # • [Constantes] Valores de retorno dos botões:
    #--------------------------------------------------------------------------
    ABORT = 3 # Retorno do valor do botão de Anular
    CANCEL = 2 # Retorno do valor do botão de Cancelar.
    CONTINUE = 11 # Retorno do valor do botão de Continuar.
    IGNORE = 5 # Retorno do valor de ignonar.
    NO = 7 # Retorno do valor do botão de Não.
    OK = 1 # Retorno do valor do botão de Ok.
    RETRY = 4 # Retorno do valor de repetir.
    TRYAGAIN = 10 # Retorno do valor de Repetir.
    YES = 6 # Retorno do valor do botão de Sim.
    #--------------------------------------------------------------------------
    # • [Constantes] Valores adicionais.
    #--------------------------------------------------------------------------
    RIGHT = 0x00080000 # Os textos ficarão justificados a direita.
    TOPMOST = 0x00040000 # O estilo da mensagem é criado como WB_EX_TOPMOST 
    #--------------------------------------------------------------------------
    # • [call] : Retorna aos valores dos botões. Para serem usados 
    # como condição, de que se ao clicar.
    #   API::MessageBox.call(title, string, format)
    #    title -> Título da caixa.
    #    string -> Conteúdo da caixa.
    #    format -> Formato, no caso seria os botões e ícones.
    #--------------------------------------------------------------------------
    def call(title, string, format)
      return FunctionMessageBox.call(API.hWND, API.textUTF(string), API.textUTF(title), format)
    end
    #--------------------------------------------------------------------------
    # • [messageBox] : Mesma função do Call a diferença é que e protegido.
    #--------------------------------------------------------------------------
    def messageBox(*args)
      self.call(*args)
    end
    protected :messageBox
  end
  #============================================================================
  # • RTP
  #============================================================================
  module RTP
    extend self
    extend API
    #--------------------------------------------------------------------------
    # • Variável & Constante
    #--------------------------------------------------------------------------
    @@rtp = nil
    DPATH = 'Software\Enterbrain\RGSS3\RTP'
    DLL = 'Advapi32.dll'
    #--------------------------------------------------------------------------
    # • Retorna ao caminho do diretório do RTP.
    #--------------------------------------------------------------------------
    def path
      unless @@rtp
        read_ini = ->(val) { File.foreach("Game.ini") { |line| break($1) if line =~ /^#{val}=(.*)$/ }
                            }
        key = type = size = [].pack("x4")
        long("RegOpenKeyEx", [:HKEY, :LPCTST, :DWORD, :REGSAM, :PHKEY], DLL).call(
              2147483650, DPATH, 0, 131097, key)
        key = key.unpack('l').first
        rtp_data = read_ini["RTP"]
        long("RegQueryValueEx", [:HKEY, :LPCTSTR, :LPDWORD, :LPDWORD, :LPBYTE, :LPDWORD], DLL).call(
              key, rtp_data, 0, type, 0, size)
        buffer = ' '*size.unpack('l').first
        long("RegQueryValueEx", [:HKEY, :LPCTSTR, :LPDWORD, :LPDWORD, :LPBYTE, :LPDWORD], DLL).call(
              key, rtp_data, 0, type, buffer, size)
        long("RegCloseKey", [:HKEY], DLL).call(key)
        @@rtp = (buffer.gsub(/\\/, '/')).delete!(0.chr)
        @@rtp += "/" if @@rtp[-1] != "/"
      end
      return @@rtp
    end
  end
  #============================================================================
  # • ::PNG
  #============================================================================
  module PNG
    extend self
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
  #============================================================================
  # • FindDir
  #============================================================================
  class FindDir
    #--------------------------------------------------------------------------
    # • Variáveis públicas da instâncias.
    #--------------------------------------------------------------------------
    attr_accessor :dir
    attr_accessor :files
    attr_accessor :folders
    attr_accessor :type
    #--------------------------------------------------------------------------
    # • Diretórios principais.
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
    # • Todos os arquivos.
    #--------------------------------------------------------------------------
    def all_files
      @folders + @files
    end
    #--------------------------------------------------------------------------
    # • Mover para outro diretório.
    #--------------------------------------------------------------------------
    def move_to(dir)
      @dir = File.expand_path(@dir + "/#{dir}")
      setup
    end
    #--------------------------------------------------------------------------
    # • Mover para os diretórios principais.
    #--------------------------------------------------------------------------
    def move_to_dir(sym)
      @dir = API::FindDir.env.get(sym)
      setup
    end
    
    def ret
      @dir != API::FindDir.env.get(:drive)
    end
  end
  #============================================================================
  # • Network
  #============================================================================
  module Network
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
    # • Verificar a conexão com internet.
    #--------------------------------------------------------------------------
    def connected? 
      InternetGetConnectedState.call(' ', 0) == 0x01
    end
    #--------------------------------------------------------------------------
    # • Baixar um arquivo direto de um link.
    #     url : Link do arquivo.
    #     dest : Pasta de destino.
    #     open : Abrir o arquivo ao terminar de baixar.
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
  protected :hwnd, :open, :function
end
}
#==============================================================================
# * String
#==============================================================================
Dax.register(:string, "dax", 2.0) {
class String
  #----------------------------------------------------------------------------
  # • [String] : Remove a extensão do nome do arquivo e assume por outra.
  #      filename : Nome do aquivo.
  #      extension : Nova extensão.
  #   "Hello.rb".extn(".rvdata2") # "Hello.rvdata2"
  #----------------------------------------------------------------------------
  def extn(extension)
    return self.gsub(/\.(\w+)/, extension.include?(".") ? extension : "." + extension)
  end
  #--------------------------------------------------------------------------
  # • [String] : converter à String em UTF8
  #--------------------------------------------------------------------------
  def to_utf8
    API.textUTF(self)
  end
  #----------------------------------------------------------------------------
  # • [String] : Converter a String para w_char. Pra chamadas WinAPI.
  #----------------------------------------------------------------------------
  def w_char
    wstr = ""
    self.size.times { |i| wstr += self[i, 1] + "\0" }
    wstr += "\0"
    return wstr
  end
  #--------------------------------------------------------------------------
  # • [Array] : Extrai somente os números da String, e retorna a uma Array.
  # Exemplo: "João89".numbers # [8, 9]
  #--------------------------------------------------------------------------
  def numbers
    self.scan(/-*\d+/).collect{|n|n.to_i}
  end
  alias :num :numbers
  #----------------------------------------------------------------------------
  # • [String] : Aplicando Case Sensitive
  #   "Exemplo 2" => "Exemplo_2"
  #----------------------------------------------------------------------------
  def case_sensitive
    return self.gsub(" ", "_")
  end 
  #----------------------------------------------------------------------------
  # • [Symbol] : Transforma em símbolo a string. 
  #     "Ola Meu Nome É" #:ola_menu_nome_é
  #----------------------------------------------------------------------------
  def symbol
    return self.case_sensitive.downcase.to_sym
  end
  #----------------------------------------------------------------------------
  # • [String] : Remove o último caractere da String.
  #----------------------------------------------------------------------------
  def backslash
    return String(self[0, self.split(//).size-1])
  end
  #----------------------------------------------------------------------------
  # • Método xor.
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
Dax.register(:integer, "dax", 2.5) {
class Integer
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Verifica-se e par.
  #----------------------------------------------------------------------------
  def is_evan?
    return (self & 1) == 0
  end
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Verifica-se e impar.
  #----------------------------------------------------------------------------
  def is_odd?
    return (self & 1) == 1
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Aumenta o valor até chegar ao máximo(definido), quando
  # chegar ao máximo(definido) retorna a zero(pode definir).
  #     back : Valor de retorno.
  #     max : Valor máximo.
  #     compare : Método de comparação
  #----------------------------------------------------------------------------
  def up(back, max, compare=:>)
    return (self.method(compare).call(max) ? back : (self + 1))
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Diminui o valor até chegar a zero, quando chegar a zero(pode definir)
  # retorna ao valor máximo(defindo).
  #     back : Valor de retorno.
  #     max : Valor máximo.
  #     compare : Método de comparação
  #----------------------------------------------------------------------------
  def down(max, r=0, compare=:<)
    return (self.method(compare).call(back) ? max : (self - 1))
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Formula de número randômico.
  #----------------------------------------------------------------------------
  def aleatory
    return ((1..(self.abs)).to_a).shuffle[rand(self).to_i].to_i
  end
end
}
#==============================================================================
# • Numeric
#==============================================================================
Dax.register(:numeric, "dax", 2.0) {
class Numeric
  #----------------------------------------------------------------------------
  # * [Numeric] : Transformar em porcentagem 
  #    a : Valor atual.
  #    b : Valor máximo.
  #----------------------------------------------------------------------------
  def to_p(a, b)
    self * a / b
  end
  alias :percent :to_p
  #----------------------------------------------------------------------------
  # • [Numeric] : Pega um do porcento.
  #     max : Valor máximo.
  #----------------------------------------------------------------------------
  def p_to(max)
    (self * max) / 100
  end
  alias :proportion :p_to
  #----------------------------------------------------------------------------
  # * [Numeric] : Variação do número.
  #     x : Variação total. [-x, x]
  #----------------------------------------------------------------------------
  def randomic(x=4)
    return ( (self+rand(2)) + (self + (rand(2) == 0 ? rand(x) : -rand(x)) ) ) / 2 
  end
  #----------------------------------------------------------------------------
  # * [Boolean] : Verifica se o número é igual a um dos especificados.
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
# • Position.
#==============================================================================
Dax.register(:position, "dax", 3.0) {
class Position
  #----------------------------------------------------------------------------
  # • Modificar a posição de um objeto, que deve de conter as variáveis
  # x, y, width, height.
  #     pos : Defina aqui o valor que definirá a posição da escola. Veja abaixo
  #     object : Objeto que contenha as variáveis x, y, width, height.
  # os valores.
  # 0 : Ficará no canto esquerdo superior.
  # 1 : Posição X mudará para o centro da tela.
  # 2 : Ficará no canto direito superior.
  # 3 : Ficará no canto esquerdo inferior.
  # 4 : Posição Y mudará para o centro da tela.
  # 5 : Ficará no canto direito inferior.
  # :center : Mudar a posição para o centro da tela.
  # :center_left : Centralizar à esquerda da tela.
  # :center_right : Centralizar à direita da tela.
  # :center_up : Centralizar no centro superior.
  # :center_down : Centralizar no centro inferior.
  #----------------------------------------------------------------------------
  def self.[](pos, object)
    return if object.nil? or pos.nil?
    return object.x, object.y = pos[0], pos[1] if pos.is_a?(Array)
    return object.x, object.y = pos.x, pos.y if pos.is_a?(Position)
    case pos
    when 0 then object.x, object.y = 0, 0
    when 1 then object.x = DMath.get_x_center_screen(object.width)
    when 2 then object.x, object.y = Graphics.width - object.width, 0
    when 3 then object.x, object.y = 0, Graphics.height - object.height
    when 4 then object.y = DMath.get_y_center_screen(object.height)
    when 5 then object.x, object.y = Graphics.width - object.width, Graphics.height - object.height
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
    return self.x == position.x && self.y == position.y
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
    return Position.new(@x, @y)
  end
end
}
#==============================================================================
# • File
#==============================================================================
Dax.register(:file, "dax", 1.0) {
class << File
  #----------------------------------------------------------------------------
  # • [NilClass] : Executa o script que está no arquivo. 
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
    return nil
  end
end
}
#==============================================================================
# • Dir
#==============================================================================
Dax.register(:dir, "dax", 1.0) {
class << Dir
  #----------------------------------------------------------------------------
  # • [NilClass] Cria pasta e subpasta em conjunto.
  #     Separe todo com vírgulas. A primeira que você definir será a pasta,
  # o resto será as subpasta.
  #   Dir.mksdir("Pasta", "Subpasta1, Subpasta2")
  #----------------------------------------------------------------------------
  def mksdir(dir="", subdir="")
    self.mkdir(dir) unless File.directory?(dir)
    subdir = subdir.split(/,/)
    subdir.each { |data| self.mkdir(dir + "/" + data.strip) unless File.directory?(dir + "/" + data.gsub(" ", "")) }
    return nil
  end
end
}
#==============================================================================
# * Color
#==============================================================================
Dax.register(:color, "dax", 3.5) {
class Color
  #----------------------------------------------------------------------------
  # • [Color] : Permite você modificar a opacidade da cor.
  #     Color.new(r, g, b).opacity([alpha]) 
  #  O valor padrão do alpha e 128.. não é preciso espeficar.
  #----------------------------------------------------------------------------
  def opacity(alpha=nil)
    self.set(self.red, self.green, self.blue, alpha || 128)
  end
  #----------------------------------------------------------------------------
  # • [Color] : Inverte as cores.
  #     Color.new(r, g, b[, a).invert!
  #----------------------------------------------------------------------------
  def invert!
    self.set(255-self.red, 255-self.green, 255-self.blue, self.alpha)
  end
  #----------------------------------------------------------------------------
  # • [Color] : Reverte as cores.
  #     Color.new(r, g, b[, a).revert
  #----------------------------------------------------------------------------
  def revert
    self.set(*[self.red, self.green, self.blue, self.alpha].reverse!)
  end
  #----------------------------------------------------------------------------
  # • [String] : Converte para string as informações dos valores das cores.
  #      Color.new(0, 0, 0).to_s
  #       red: 0
  #       blue: 0
  #       green: 0
  #       alpha: 255
  #----------------------------------------------------------------------------
  def to_s
    "red: #{self.red}\nblue: #{self.blue}\ngreen: #{self.green}\nalpha: #{self.alpha}"
  end
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Comparar cores, retorna a [true] se for igual.. 
  # retorna a [false] se não for igual.
  #----------------------------------------------------------------------------
  def ==(color)
    return (self.red == color.red and self.green == color.green and self.blue == color.blue and
      self.alpha == color.alpha) ? true : false
  end
  #----------------------------------------------------------------------------
  # • [Hash] : Retorna aos valores das cores em formato de Hash.
  #      Color.new(0, 0, 0).to_h
  #      {:red => 0, :green => 0, :blue => 0, :alpha => 255}
  #----------------------------------------------------------------------------
  def to_h
    return {
      red: self.red, green: self.green, blue: self.blue, alpha: self.alpha,
    }
  end
  #----------------------------------------------------------------------------
  # • [Array] : Retorna aos valores das cores em formato de Array.
  #     includeAlpha : Incluir o valor alpha?
  #     Color.new(0, 0, 0).to_a
  #     [0, 0, 0, 255]
  #----------------------------------------------------------------------------
  def to_a(includeAlpha=false)
    array = [self.red, self.green, self.blue]
    array += [self.alpha] if includeAlpha
    return array
  end
  #----------------------------------------------------------------------------
  # • [Color] : Dispoem os valores das cores em ordem crescente e cria uma
  # nova cor.
  #    includeAlpha : Incluir o valor alpha?
  #----------------------------------------------------------------------------
  def crescent(includeAlpha=false)
    set(*to_a(includeAlpha).crescent)
  end
  #----------------------------------------------------------------------------
  # • [Color] : Dispoem os valores das cores em ordem decrescente e cria uma
  # nova cor.
  #    includeAlpha : Incluir o valor alpha?
  #----------------------------------------------------------------------------
  def decrescent(includeAlpha=false)
    set(*to_a(includeAlpha).decrescent)
  end
  #----------------------------------------------------------------------------
  # • [Color] Soma os valores das cores com os valores de outras cores.
  # Ex: color + Color.new(21,54,255)
  #----------------------------------------------------------------------------
  def +(color)
    return unless color.is_a?(Color)
     self.set(
       *color.to_a(false).each_with_index { |i, n| i + to_a[n]  }
     )
  end
  #----------------------------------------------------------------------------
  # • [Color] Subtrai os valores das cores com os valores de outras cores.
  # Ex: color - Color.new(21,54,255)
  #----------------------------------------------------------------------------
  def -(color)
    return unless color.is_a?(Color)
    self.set(
       *color.to_a(false).each_with_index { |i, n| i - to_a[n]  }
     )
  end
  #----------------------------------------------------------------------------
  # • [Color] Multiplica os valores das cores com os valores de outras cores.
  # Ex: color * Color.new(21,54,255)
  #----------------------------------------------------------------------------
  def *(color)
    return unless color.is_a?(Color)
    self.set(
       *color.to_a(false).each_with_index { |i, n| (i * to_a[n]) / 255.0  }
     )
  end
  #----------------------------------------------------------------------------
  # • [Color] Divide os valores das cores com os valores de outras cores.
  # Ex: color / Color.new(21,54,255)
  #----------------------------------------------------------------------------
  def /(color)
    return unless color.is_a?(Color)
    self.set(
      *color.to_a(false).each_with_index { |i, n| i.zero? ? 0 : to_a[n] / i }
    )
  end
  #----------------------------------------------------------------------------
  # • [Color] : Aumentar/Diminuir as cores em porcento.
  #     value : Valor da porcentagem. Vai de 0~100
  #     includeAlpha : Incluir o valor alpha?
  #----------------------------------------------------------------------------
  def percent(value, includeAlpha=true)
    value = DMath.clamp(value, 0, 100)
    Color.new(
      *to_a(includeAlpha).collect! { |i| i.to_p(value * 2.55, 255) }
    )
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna a lumonisidade das cores.
  #----------------------------------------------------------------------------
  def luminosity
    return to_a(false).each_with_index { |i, n| i * [0.21, 0.71, 0.07][n] }.alln?
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna a media entre os valores(canais).
  #     includeAlpha : Incluir o valor alpha?
  #----------------------------------------------------------------------------
  def avarange(includeAlpha=true)
    n = includeAlpha ? 4 : 3
    return to_a(includeAlpha).alln? / n
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna ao valor mais alto que tiver, dentre os valores
  # especificados das cores.
  #----------------------------------------------------------------------------
  def max
    [red, green, blue].max
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna ao valor menor que tiver, dentre os valores
  # especificados das cores.
  #----------------------------------------------------------------------------
  def min
    [red, green, blue].min
  end
  #----------------------------------------------------------------------------
  # • [Color] : Define uma cor aleatória: 
  #   Exemplo: Color.new.random
  #----------------------------------------------------------------------------
  def random
    return Color.new(rand(256), rand(256), rand(256))
  end
  #----------------------------------------------------------------------------
  # • [Color] : Define uma cor em hexadécimal.
  #   Exemplo : Color.new.hex("ffffff")
  #----------------------------------------------------------------------------
  def hex(string)
    self.set(*string.scan(/../).map { |color| color.to_i(16)})
  end
  #----------------------------------------------------------------------------
  # • [Color] : Retorna a cor padrão.
  #    Exemplo : Color.new.default
  #----------------------------------------------------------------------------
  def default
    self.hex("ffffff")
  end
end
}
#==============================================================================
# • Rect
#==============================================================================
Dax.register(:rect, "dax & gab!", 1.5) {
class Rect
  #----------------------------------------------------------------------------
  # • [TrueClass/FalseClass] : Verificar se algo está na área.
  #----------------------------------------------------------------------------
  def in?(x, y)
    x.between?(self.x, self.x + self.width) &&
    y.between?(self.y, self.y + self.height)
  end
  #----------------------------------------------------------------------------
  # • [NilClass] : Retorna a cada parte do rect definida por ti, ponto-a-ponto.
  #     p : Ponto A.
  #     q : Ponto B.
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
    return nil
  end
  #----------------------------------------------------------------------------
  # • [Array] : Retorna aos valores do Rect em uma Array.
  #----------------------------------------------------------------------------
  def to_a
    return [self.x, self.y, self.width, self.height]
  end
  #----------------------------------------------------------------------------
  # • Retorna interseção com o argumento, que deve ser também do tipo Rect
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
# • DMath
#==============================================================================
Dax.register(:dmath, 'Dax', 4.0) {
module DMath
  extend self
  #----------------------------------------------------------------------------
  # • Constantes para fórmula de dano.
  #----------------------------------------------------------------------------
  MAX_VALUE_PARAM = 256 
  MAX_VALUE_PARAM_AXE = 128 
  MAX_VALUE_PARAM_DAGGER = 218
  MAX_VALUE_PARAM_GUN = 99
  MAX_VALUE_MAGIC = 218
  #----------------------------------------------------------------------------
  # • [Numeric] : Calcula o ângulo entre dóis pontos.
  #----------------------------------------------------------------------------
  def angle(pA, pB, quad4=false)
    pA = pA.position unless pA.is_a?(Position)
    pB = pB.position unless pB.is_a?(Position)
    x = pB.x - pA.x
    y = pB.y - pA.y
    y *= -1 if quad4
    radian = Math.atan2(y, x)
    angle = (radian * 180 / Math::PI)
    angle = 360 + angle if angle < 0 
    return angle
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
  # • [Numeric] : Clamp | Delimitar o inteiro
  #    num : Número.
  #    low : Número minímo. Sê o 'num' for menor que min retorna a low.
  #    high : Número máximo. Sê o 'num' for maior que hight retorna a high, caso
  # não retorna ao próprio número(num).
  #----------------------------------------------------------------------------
  def clamp(num, low, high)
    num, low, high = num.to_i, low.to_i, high.to_i
    num = num < low ? low : num > high ? high : num
    num
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
  # • [TrueClass/FalseClass] : Verifica se um objeto está na área de um círculo.
  #    object : Objeto do tipo da classe [Sprite].
  #    object2 : Objeto do tipo da classe [Sprite].
  #    size : Tamanho geral do círculo.
  #--------------------------------------------------------------------------
  def circle(object, object2, size)
    ( (object.x - object2.x) ** 2) + ( (object.y - object2.y) ** 2) <= (size ** 2)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Converter o valor em graus.
  #----------------------------------------------------------------------------
  def graus
    360 / (2 * Math::PI)
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Converte o valor em radiano.
  #----------------------------------------------------------------------------
  def radian(degree)
    return (degree.to_f/180) * Math::PI
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Converte o valor em grau.
  #----------------------------------------------------------------------------
  def degree(radian)
    return (radian.to_f/Math::PI) * 180
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna pra base de 4 decimais.
  #----------------------------------------------------------------------------
  def to_4_dec(n)
    ((n * 1000).ceil) / 1000
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna a área do triângulo.
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
  # • [Numeric] : Método para calcular a distância de um objeto para com outro.
  #----------------------------------------------------------------------------
  def distance_sensor(target, target2)
    return (target.x - target2.x).abs + (target.y - target2.y).abs
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Método euclidiano para mediar a distância de um ponto
  # para outro ponto. Primeira dimensão.
  #   p : Ponto A. [x, y]
  #   q : Ponto B. [x, y]
  #   euclidean_distance_1d(5, 1) #4
  #----------------------------------------------------------------------------
  def euclidean_distance_1d(p, q)
    return sqrt( (p - q) ** 2, 2 ).floor
  end
  #----------------------------------------------------------------------------
  # • [Integer] : Método euclidiano para mediar a distância de um ponto
  # para outro ponto. Segunda dimensão.
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
  # • [Numeric] : Dentro do círculo.
  #----------------------------------------------------------------------------
  def circle_in(t, b, c, d)
    return -c * (Math.sqrt(1 - (t /= d.to_f) * t) - 1) + b
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Fora do círculo
  #----------------------------------------------------------------------------
  def circle_out(t, b, c, d)
    return c * Math.sqrt(1 - (t=t/d.to_f-1)*t) + b
  end
  #----------------------------------------------------------------------------
  # • [Numeric] : Retorna ao valor minímo, do valor máximo de min & v, com o 
  # valor de max.
  #----------------------------------------------------------------------------
  def force_range(v, min, max)
    [[min, v].max, max].min
  end
  #----------------------------------------------------------------------------
  # • Cálculo de variação para o dano. Para equilibrar.
  #----------------------------------------------------------------------------
  def random
    (1 + 2.aleatory) ** 0.125
  end
  #----------------------------------------------------------------------------
  # • Resultado final.
  #----------------------------------------------------------------------------
  def lastResult(x)
    return x <= 0 ? 0 : x.round
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Espadas(1 & 2 mão), lanças, bestas, cajado.
  #----------------------------------------------------------------------------
  def sword(attack, strength, defense, level)
    str = strength.randomic
    return lastResult((attack.randomic * random - defense.randomic) * (1 + str * (level + str) / MAX_VALUE_PARAM))
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Desarmado.
  #----------------------------------------------------------------------------
  def unarmed(strength, defense, level)
    str = strength.randomic
    lastResult((11 * random - defense.randomic) * str * (level + str) / MAX_VALUE_PARAM)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Desarmado com luva.
  #----------------------------------------------------------------------------
  def unarmed_brawler(strength, defense, level)
    str = strength.randomic
    lastResult(((level + str) / 2 * random - defense.randomic) * str * (level + str) / MAX_VALUE_PARAM)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Cajado de mágia.
  #----------------------------------------------------------------------------
  def pole(attack, strength, defense, level, magicDefense)
    str = strength.randomic
    lastResult((attack.randomic * random - magicDefense.randomic) * (1 + str * (level + str))/ MAX_VALUE_PARAM)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Maças..
  #----------------------------------------------------------------------------
  def mace(attack, defense, magic, level)
    mag = magic.randomic
    lastResult((attack.randomic * random - defense.randomic) * (1 + mag * (level + mag)) / MAX_VALUE_PARAM)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Katanas, staves..
  #----------------------------------------------------------------------------
  def katana(attack, defense, strength, magic, level)
     lastResult((attack.randomic * random - defense.randomic) * (1 + strength.randomic * (level + magic.randomic) / MAX_VALUE_PARAM))
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Machados, marretas..
  #----------------------------------------------------------------------------
  def axe(attack, strength, defense, level, vitality)
    lastResult((attack.randomic * random - defense.randomic) * (1 + strength.randomic * (level+vitality.randomic)/MAX_VALUE_PARAM_AXE))
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Adagas, espadas ninjas e arco..
  #----------------------------------------------------------------------------
  def dagger(attack, defense, strength, level, speed)
    lastResult ((attack.randomic * random) - defense.randomic) * (1 + strength.randomic * (level + speed.randomic) / 218)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Revolvers
  #----------------------------------------------------------------------------
  def gun(attack,defense,strength, level)
    str = strength.randomic
    lastResult ( (((attack.randomic * random) - defense.randomic) ** 2) / 64 ) * (1 + str * (level + str) / MAX_VALUE_PARAM_GUN)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Mágicas de ataques.
  #----------------------------------------------------------------------------
  def magicAttack(magicDefense, level, magicAttack, attackMagic)
    mag = magicAttack.randomic
    lastResult ( (attackMagic.randomic * random) - magicDefense.randomic ) * (2 + mag.randomic * (level + mag) / MAX_VALUE_MAGIC)
  end
  #----------------------------------------------------------------------------
  # • [Formula de dano] : Mágicas de cura;
  #----------------------------------------------------------------------------
  def magicHeal(strengthMagic, magicAttack, level)
    mag = magicAttack.randomic
    lastResult (strengthMagic * random) * (2 + mag * (level + mag) / MAX_VALUE_MAGIC)
  end
  #----------------------------------------------------------------------------
  # • [Formula de EXP] : Gerador de curva de exp.
  #     minlv : Level minimo.
  #     maxlv : Level máximo.
  #     stvalue : Valor inicial.
  #     infl : Inflação.
  #----------------------------------------------------------------------------
  def generate_curve_exp(minlv, maxlv, stvalue, infl)
    table = []
    (minlv..maxlv).each { |i| table[i] = (stvalue + (infl + (Random.new.rand(infl..(infl+i)).to_i % i )) * i).to_i.round}
    table
  end
end
}
#==============================================================================
# • Keyboard | Método para usar todas as teclas do teclado.
#==============================================================================
Dax.register(:key, "Dax", 2.0) {
module Key
  #----------------------------------------------------------------------------
  # • Extensão & Variáveis da instância do módulo.
  #----------------------------------------------------------------------------
  extend self
  attr_accessor :_cacheText # Armazena os textos.
  #----------------------------------------------------------------------------
  # • Texto do cache
  #----------------------------------------------------------------------------
  def text
    return @_cacheText
  end
  alias :to_s :text
  #----------------------------------------------------------------------------
  # • Chaves.
  #----------------------------------------------------------------------------
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
      @_cacheText = @_cacheText.backslash if trigger?(:BACKSPACE)
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
    Key::KEY.each_value  { |i| 
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
# • Sprite
#==============================================================================
Dax.register(:sprite, "dax", 3.0) {
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
  alias :dax_core_dispose :dispose
  def dispose
    dax_core_dispose
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
    Position[command, self]
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
  alias :dax_update :update
  def update(*args, &block)
    dax_update(*args, &block)
    unless Mouse.cursor.nil?
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
Dax.register(:bitmap, "dax", 3.0) {
class Bitmap
  #--------------------------------------------------------------------------
  # • Constantes.
  #--------------------------------------------------------------------------
  Directory = 'Data/Bitmaps/'
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
    puts "bitmap saved"
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
end
}
#==============================================================================
# • Mouse
#==============================================================================
Dax.register(:mouse, "dax", 2.5) {
module Mouse
  extend self
  #--------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #--------------------------------------------------------------------------
  def start
    @cursor = Sprite_Mouse.new(Dax::MOUSE_NAME, -128, -128, 100000)
    @graphic = Dax::MOUSE_NAME
    x = Dax::MOUSE_NAME == "" ? 1 : 0
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
  # • Grid do mapa.
  #--------------------------------------------------------------------------
  def map_grid
    return unless defined?($game_map)
    return nil if x == nil or y == nil 
    rx = ($game_map.display_x).to_i + (x / 32)
    ry = ($game_map.display_y).to_i + (y / 32)
    return [rx.to_i, ry.to_i]
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
    return if @cursor.disposed?
    return unless x.is_a?(Sprite) or x.is_a?(Window)
    #return @cursor.x.between?(object_sprite.x, object_sprite.x + object_sprite.width) &&
    #  @cursor.y.between?(object_sprite.y, object_sprite.y + object_sprite.height)
    @cursor.x.between?(x.x, (x.x - x.ox + (x.viewport ? x.viewport.rect.x : 0)) + x.width) &&
    @cursor.y.between?(x.y, (x.y - x.oy + (x.viewport ? x.viewport.rect.y : 0)) + x.height)
  end 
  #----------------------------------------------------------------------------
  # • Verificar se o mouse está em determinada área
  #----------------------------------------------------------------------------
  def area?(x, y, width, height)
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
    return Key.trigger?(0x01)
  end
  #----------------------------------------------------------------------------
  # • Verifica se clicou com o botão direito do Mouse.
  #----------------------------------------------------------------------------
  def right?
    return Key.trigger?(0x02)
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
Mouse.start
}
#==============================================================================
# • Powershell
#==============================================================================
Dax.register(:powershell, "dax", 1.0) {
module Powershell
  extend self
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
# • Object
#==============================================================================
Dax.register(:object, "dax", 2.0) {
class Object
  #----------------------------------------------------------------------------
  # • powershell exec command
  #     cmd : Command
  #----------------------------------------------------------------------------
  def powershell(cmd)
    Powershell.run(cmd)
  end
  alias :ps :powershell
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
    return if Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    over ||= false
    if Mouse.in_area?(self)
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
    return if Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Mouse.in_area?(self)  and trigger?(button)
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite, e ao pressionar.
  # Tem que ser um objeto Sprite.
  #  * button : Button : (:right - botão direito do mouse | :left - botão esq.)
  #----------------------------------------------------------------------------
  def if_mouse_press(button=:left, &block)
    return if Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Mouse.in_area?(self)  and press?(button)
  end
  #----------------------------------------------------------------------------
  # • O que irá ocorrer caso o mouse esteja sobre uma sprite, e ao ficar clicando.
  # Tem que ser um objeto Sprite.
  #  * button : Button : (:right - botão direito do mouse | :left - botão esq.)
  #----------------------------------------------------------------------------
  def if_mouse_repeat(button=:left, &block)
    return if Mouse.cursor.nil?
    return unless self.is_a?(Sprite) or self.is_a?(Window_Base) or block_given?
    button = button == :left ? 0x01 : button == :right ? 0x02 : 0x01
    block.call if Mouse.in_area?(self)  and repeat?(button)
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
      ckey = Key.trigger?(key)
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
      ckey = Key.press?(key)
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
      ckey = Key.repeat?(key)
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
    return Position.new(self, self) if self.is_a?(Numeric)
    return Position.new(self.x, self.y) if self.is_a?(Sprite) or self.is_a?(Window_Base) or self.is_a?(Rect)
    return Position.new(self[0], self[1]) if self.is_a?(Array)
    return Position.new(self[:x], self[:y]) if self.is_a?(Hash)
    return Position.new(self.x, self.y) if defined?(self.x) and defined?(self.y)
    return Position.new(0, 0)
  end
  #----------------------------------------------------------------------------
  # • Transforma em cor.
  #  Se for uma Array. Exemplo: [128, 174, 111].color =># Color.new(128, 174, 111)
  #  Se for uma String. Exemplo: "ffffff".color =># Color.new(255,255,255)
  #----------------------------------------------------------------------------
  def color
    return Color.new(*self) if self.is_a?(Array) 
    return Color.new.hex(self) if self.is_a?(String)
  end
end
}
#==============================================================================
# • Entries
#==============================================================================
Dax.register(:entries, "dax", 2.0) {
class Entries
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
# • DRGSS | Comandos do RGSS...
#==============================================================================
Dax.register(:drgss, "dax", 1.0) {
module DRGSS
  extend self
  #----------------------------------------------------------------------------
  # • Extrair scripts do Database para um arquivo de extensão de texto.
  # options : Caso você deixe assim: {folder: "NM"}
  #  NM => Nome da pasta na qual os arquivos irão.
  #----------------------------------------------------------------------------
  def extract_scripts(type=".txt",options={})
    except = options[:except] || []
    folder = options[:folder] || ""
    id = 0 #
    $RGSS_SCRIPTS.each do |script|
      name = script[1]
      data = script[3]
      next if except.include? name or name.empty? or data.empty?
      filename = sprintf("%03d", id) + "_" + name
      puts "Writing: #{filename}"
      File.open(folder+filename+"#{type}", "wb") do |file|
        file.write data
      end
      id += 1
    end
  end
end
}
#==============================================================================
# • Backup Complete
#==============================================================================
Dax.register(:backup, "dax", 3.0) {
module Backup
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
# * SceneManager
#==============================================================================
Dax.register(:scenemanager, "dax", 1.0) {
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
# • Sprite_Text
#==============================================================================
Dax.register(:sprite_text, "dax", 2.0) {
class Sprite_Text < Sprite
  #----------------------------------------------------------------------------
  # • Variáveis públicas da instância.
  #----------------------------------------------------------------------------
  attr_accessor :text # Mudar de texto...
  attr_accessor :align
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize(x, y, width, height, text, align=0)
    super([width, height])
    self.x, self.y = x, y
    @text = text
    @align = align
    self.bitmap.draw_text_rect(@text, align)
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
    self.bitmap.clear unless self.bitmap.disposed?
    super
    self.bitmap.draw_text_rect(@text, @align)
  end
  
  def size=(value=18)
    self.bitmap.font.size = value 
  end
  def name=(value=nil)
    self.bitmap.font.name = value || "Arial"
  end
  #----------------------------------------------------------------------------
  # • Negrito na fonte?
  #----------------------------------------------------------------------------
  def bold=(value=nil)
    self.bitmap.font.bold = value || true
  end
  #----------------------------------------------------------------------------
  # • Itálico na fonte?
  #----------------------------------------------------------------------------
  def italic=(value=nil)
    self.bitmap.font.italic = value || true
  end
  #----------------------------------------------------------------------------
  # • Sombra na fonte?
  #----------------------------------------------------------------------------
  def shadow=(value=nil)
    self.bitmap.font.shadow = value || true
  end
  #----------------------------------------------------------------------------
  # • Borda na fonte?
  #----------------------------------------------------------------------------
  def outline=(value=nil)
    self.bitmap.font.outline = value || true
  end
  #----------------------------------------------------------------------------
  # • Mudar a cor da fonte:
  #----------------------------------------------------------------------------
  def color=(color=nil)
    self.bitmap.font.color = color || Color.new.default
  end
  #----------------------------------------------------------------------------
  # • Mudar a cor da borda da fonte.
  #----------------------------------------------------------------------------
  def out_color=(out_color=nil)
    self.bitmap.font.out_color = out_color || Color.new.hex("000000")
  end
end
}
#==============================================================================
# • Opacity
#==============================================================================
Dax.register(:opacity, "dax", 2.0) {
module Opacity
  extend self
  @key ||= {}
  @time ||= {}
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
# • Read
#==============================================================================
Dax.register(:read, "dax", 1.0) {
module Read
  extend self
  #----------------------------------------------------------------------------
  # • Verificar valor numérico após uma palavra em um arquivo.
  #----------------------------------------------------------------------------
  def numeric(file, tag)
    IO.readlines(file).each do |line|
      return $1.to_i if line.match(/#{tag}(\d+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Verificar valor de uma palavra(string única) após uma palavra em um arquivo
  #----------------------------------------------------------------------------
  def string(file, tag)
    IO.readlines(file).each do |line|
      return $1.to_s if line.match(/#{tag}(\w+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Verificar um conteúdo após uma palavra de um arquivo.
  #----------------------------------------------------------------------------
  def content(file, tag)
    IO.readlines(file).each do |line|
      return $1 if line.match(/#{tag}([^>]*)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Multiplo número..
  #----------------------------------------------------------------------------
  def multiple_numeric(file, tag)
    IO.readlines(file).each do |line|
      return [$1.to_i, $2.to_i] if line.match(/#{tag}(\d+), (\d+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Multiplo string..
  #----------------------------------------------------------------------------
  def multiple_string(file, tag)
    IO.readlines(file).each do |line|
      return [$1.to_s, $2.to_s] if line.match(/#{tag}(\w+), (\w+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Triplo número.
  #----------------------------------------------------------------------------
  def triple_numeric(file, tag)
    IO.readlines(file).each do |line|
      return [$1.to_i, $2.to_i, $3.to_i] if line.match(/#{tag}(\d+), (\d+), (\d+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Triplo string.
  #----------------------------------------------------------------------------
  def triple_string(file, tag)
    IO.readlines(file).each do |line|
      return [$1.to_s, $2.to_s, $3.to_s] if line.match(/#{tag}(\w+), (\w+), (\w+)/)
    end
  end
  #----------------------------------------------------------------------------
  # • Se é verdairo ou falo.
  #----------------------------------------------------------------------------
  def of(file, tag)
    IO.readlines(file).each do |line|
      return $1.to_s == "true" ? true : false if line.match(/#{tag}([^>]*)/)
    end
  end
end
}
#==============================================================================
# * Window_Base
#==============================================================================
Dax.register(:window_base, "dax", 1.5) {
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
    Position[command, self]
  end
end
end
}
#==============================================================================
# • Sound Base
#==============================================================================
Dax.register(:soundbase, "dax", 1.0) {
module SoundBase
  #----------------------------------------------------------------------------
  # • Função do módulo.
  #----------------------------------------------------------------------------
  module_function
  #----------------------------------------------------------------------------
  # • Executar um som.
  #     name : Nome do som.
  #     volume : Volume.
  #     pitch : Pitch;
  #----------------------------------------------------------------------------
  def play(name, volume, pitch, type = :se)
    case type
    when :se  ; RPG::SE.new(name, volume, pitch).play rescue valid?(name)
    when :me  ; RPG::ME.new(name, volume, pitch).play rescue valid?(name)
    when :bgm ; RPG::BGM.new(name, volume, pitch).play rescue valid?(name)
    when :bgs ; RPG::BGS.new(name, volume, pitch).play rescue valid?(name)
    end
  end
  #----------------------------------------------------------------------------
  # • Validar som.
  #----------------------------------------------------------------------------
  def valid?(name)
    raise("Arquivo de som não encontrado: #{name}")
    exit
  end
end
}
#==============================================================================
# • Benchmark
#==============================================================================
Dax.register(:benchmark, "Gotoken", 1.0) {
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
#-----------------------------------------------------------------------------
# • Carregar arquivo e executar.
#     path : Nome do arquivo.
#-----------------------------------------------------------------------------
def load_script(path)
  raise("Arquivo não encontrado %s" % path) unless FileTest.exist?(path)
  return eval(load_data(path)) if File.extname(path) == ".rvdata2"
  return eval(File.open(path).read) rescue nil
end
#==============================================================================
# * Input
#==============================================================================
Dax.register(:input, "dax", 1.0) {
class << Input
  alias :upft :update
  def update
    upft
    Key.update
  end
end
}
#==============================================================================
# • Graphics
#==============================================================================
Dax.register(:graphics, "dax", 1.0) {
class << Graphics
  attr_reader :fps
  alias :uptf :update
  def update
    @fps ||= 0
    @fps_temp ||= []
    time = Time.now
    uptf
    Mouse.update
    @fps_temp[frame_count % frame_rate] = Time.now != time
    @fps = 0
    frame_rate.times { |i| @fps.next if @fps_temp[i] }
  end
end
}

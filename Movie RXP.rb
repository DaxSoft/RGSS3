=begin
 [Movie] by Dax Soft
 0.5.1 version
 Made to Vorum project
 To use: Movie.new(filename, duration, directory)
   filename -> the name of the movie file, put the extension also
   duration -> duration in seconds of the movie. [IMPORTANT]
   directory -> for default is "./Movies/%s", you just need a
Movies folder at the main folder of the project.
 If triggered the [Space/C] will end up the movie
----------------------------------------------------------------
 [API] - XP version from Ligni Core | 
 https://dax-soft.weebly.com/ligni-core.html
=end
module API
  extend self
  #---------------------------------------------------------------
  # • [String] => unknow artisit => type of pointers
  #---------------------------------------------------------------
  TYPES = {
            :struct=> "p",
            :int=> "i",
            :long=> "l",
            :INTERNET_PORT=> "l",
            :SOCKET=> "p",
            :C=>  "p", #– 8-bit unsigned character (byte)
            :c=>  "p", # 8-bit character (byte)
            #   "i"8       – 8-bit signed integer
            #   "i"8      – 8-bit unsigned integer
            :S=>  "N", # – 16-bit unsigned integer (Win32/API=> S used for string params)
            :s=>  "n", # – 16-bit signed integer
            #   "i"16     – 16-bit unsigned integer
            #   "i"16      – 16-bit signed integer
            :I=>  "I", # 32-bit unsigned integer
            :i=>  "i", # 32-bit signed integer
            #   "i"32     – 32-bit unsigned integer
            #   "i"32      – 32-bit signed integer
            :L=>  "L", # unsigned long int – platform-specific size
            :l=>  "l", # long int – platform-specific size. For discussion of platforms, see=>
            #                (http=>//groups.google.com/group/ruby-ffi/browse_thread/thread/4762fc77130339b1)
            #   "i"64      – 64-bit signed integer
            #   "i"64     – 64-bit unsigned integer
            #   "l"_long  – 64-bit signed integer
            #   "l"_long – 64-bit unsigned integer
            :F=>  "L", # 32-bit floating point
            :D=>  "L", # 64-bit floating point (double-precision)
            :P=>  "P", # pointer – platform-specific size
            :p=>  "p", # C-style (NULL-terminated) character string (Win32API=> S)
            :B=>  "i", # (?? 1 byte in C++)
            :V=>  "V", # For functions that return nothing (return type void).
            :v=>  "v", # For functions that return nothing (return type void).
            :LPPOINT=> "p",
            # Windows-specific type defs (ms-help=>//MS.MSDNQTR.v90.en/winprog/winprog/windows_data_types.htm)=>
            :ATOM=>      "I", # Atom ~= Symbol=> Atom table stores strings and corresponding identifiers. Application
            # places a string in an atom table and receives a 16-bit integer, called an atom, that
            # can be used to access the string. Placed string is called an atom name.
            # See=> http=>//msdn.microsoft.com/en-us/library/ms648708%28VS.85%29.aspx
            :BOOL=>      "i",
            :BOOLEAN=>   "i",
            :BYTE=>      "p", # Byte (8 bits). Declared as unsigned char
            #CALLBACK=>  K,       # Win32.API gem-specific ?? MSDN=> #define CALLBACK __stdcall
            :CHAR=>      "p", # 8-bit Windows (ANSI) character. See http=>//msdn.microsoft.com/en-us/library/dd183415%28VS.85%29.aspx
            :COLORREF=>  "i", # Red, green, blue (RGB) color value (32 bits). See COLORREF for more info.
            :DWORD=>     "i", # 32-bit unsigned integer. The range is 0 through 4,294,967,295 decimal.
            :DWORDLONG=> "i", # 64-bit unsigned integer. The range is 0 through 18,446,744,073,709,551,615 decimal.
            :DWORD_PTR=> "l", # Unsigned long type for pointer precision. Use when casting a pointer to a long type
            # to perform pointer arithmetic. (Also commonly used for general 32-bit parameters that have
            # been extended to 64 bits in 64-bit Windows.)  BaseTsd.h=> #typedef ULONG_PTR DWORD_PTR;
            :DWORD32=>   "I",
            :DWORD64=>   "I",
            :HALF_PTR=>  "i", # Half the size of a pointer. Use within a structure that contains a pointer and two small fields.
            # BaseTsd.h=> #ifdef (_WIN64) typedef int HALF_PTR; #else typedef short HALF_PTR;
            :HACCEL=>    "i", # (L) Handle to an accelerator table. WinDef.h=> #typedef HANDLE HACCEL;
            # See http=>//msdn.microsoft.com/en-us/library/ms645526%28VS.85%29.aspx
            :HANDLE=>    "l", # (L) Handle to an object. WinNT.h=> #typedef PVOID HANDLE;
            # todo=> Platform-dependent! Need to change to "i"64 for Win64
            :HBITMAP=>   "l", # (L) Handle to a bitmap=> http=>//msdn.microsoft.com/en-us/library/dd183377%28VS.85%29.aspx
            :HBRUSH=>    "l", # (L) Handle to a brush. http=>//msdn.microsoft.com/en-us/library/dd183394%28VS.85%29.aspx
            :HCOLORSPACE=> "l", # (L) Handle to a color space. http=>//msdn.microsoft.com/en-us/library/ms536546%28VS.85%29.aspx
            :HCURSOR=>   "l", # (L) Handle to a cursor. http=>//msdn.microsoft.com/en-us/library/ms646970%28VS.85%29.aspx
            :HCONV=>     "l", # (L) Handle to a dynamic data exchange (DDE) conversation.
            :HCONVLIST=> "l", # (L) Handle to a DDE conversation list. HANDLE - L ?
            :HDDEDATA=>  "l", # (L) Handle to DDE data (structure?)
            :HDC=>       "l", # (L) Handle to a device context (DC). http=>//msdn.microsoft.com/en-us/library/dd183560%28VS.85%29.aspx
            :HDESK=>     "l", # (L) Handle to a desktop. http=>//msdn.microsoft.com/en-us/library/ms682573%28VS.85%29.aspx
            :HDROP=>     "l", # (L) Handle to an internal drop structure.
            :HDWP=>      "l", # (L) Handle to a deferred window position structure.
            :HENHMETAFILE=> "l", #(L) Handle to an enhanced metafile. http=>//msdn.microsoft.com/en-us/library/dd145051%28VS.85%29.aspx
            :HFILE=>     "i", # (I) Special file handle to a file opened by OpenFile, not CreateFile.
            # WinDef.h=> #typedef int HFILE;
            :REGSAM=>    "i",
            :HFONT=>     "l", # (L) Handle to a font. http=>//msdn.microsoft.com/en-us/library/dd162470%28VS.85%29.aspx
            :HGDIOBJ=>   "l", # (L) Handle to a GDI object.
            :HGLOBAL=>   "l", # (L) Handle to a global memory block.
            :HHOOK=>     "l", # (L) Handle to a hook. http=>//msdn.microsoft.com/en-us/library/ms632589%28VS.85%29.aspx
            :HICON=>     "l", # (L) Handle to an icon. http=>//msdn.microsoft.com/en-us/library/ms646973%28VS.85%29.aspx
            :HINSTANCE=> "l", # (L) Handle to an instance. This is the base address of the module in memory.
            # HMODULE and HINSTANCE are the same today, but were different in 16-bit Windows.
            :HKEY=>      "l", # (L) Handle to a registry key.
            :HKL=>       "l", # (L) Input locale identifier.
            :HLOCAL=>    "l", # (L) Handle to a local memory block.
            :HMENU=>     "l", # (L) Handle to a menu. http=>//msdn.microsoft.com/en-us/library/ms646977%28VS.85%29.aspx
            :HMETAFILE=> "l", # (L) Handle to a metafile. http=>//msdn.microsoft.com/en-us/library/dd145051%28VS.85%29.aspx
            :HMODULE=>   "l", # (L) Handle to an instance. Same as HINSTANCE today, but was different in 16-bit Windows.
            :HMONITOR=>  "l", # (L) ?andle to a display monitor. WinDef.h=> if(WINVER >= 0x0500) typedef HANDLE HMONITOR;
            :HPALETTE=>  "l", # (L) Handle to a palette.
            :HPEN=>      "l", # (L) Handle to a pen. http=>//msdn.microsoft.com/en-us/library/dd162786%28VS.85%29.aspx
            :HRESULT=>   "l", # Return code used by COM interfaces. For more info, Structure of the COM Error Codes.
            # To test an HRESULT value, use the FAILED and SUCCEEDED macros.
            :HRGN=>      "l", # (L) Handle to a region. http=>//msdn.microsoft.com/en-us/library/dd162913%28VS.85%29.aspx
            :HRSRC=>     "l", # (L) Handle to a resource.
            :HSZ=>       "l", # (L) Handle to a DDE string.
            :HWINSTA=>   "l", # (L) Handle to a window station. http=>//msdn.microsoft.com/en-us/library/ms687096%28VS.85%29.aspx
            :HWND=>      "l", # (L) Handle to a window. http=>//msdn.microsoft.com/en-us/library/ms632595%28VS.85%29.aspx
            :INT=>       "i", # 32-bit signed integer. The range is -2147483648 through 2147483647 decimal.
            :INT_PTR=>   "i", # Signed integer type for pointer precision. Use when casting a pointer to an integer
            # to perform pointer arithmetic. BaseTsd.h=>
            #if defined(_WIN64) typedef __int64 INT_PTR; #else typedef int INT_PTR;
            :INT32=>    "i", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            :INT64=>    "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            :LANGID=>   "n", # Language identifier. For more information, see Locales. WinNT.h=> #typedef WORD LANGID;
            # See http=>//msdn.microsoft.com/en-us/library/dd318716%28VS.85%29.aspx
            :LCID=>     "i", # Locale identifier. For more information, see Locales.
            :LCTYPE=>   "i", # Locale information type. For a list, see Locale Information Constants.
            :LGRPID=>   "i", # Language group identifier. For a list, see EnumLanguageGroupLocales.
            :LONG=>     "l", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            :LONG32=>   "i", # 32-bit signed integer. The range is -2,147,483,648 through +...647 decimal.
            :LONG64=>   "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            :LONGLONG=> "i", # 64-bit signed integer. The range is –9,223,372,036,854,775,808 through +...807
            :LONG_PTR=> "l", # Signed long type for pointer precision. Use when casting a pointer to a long to
            # perform pointer arithmetic. BaseTsd.h=>
            #if defined(_WIN64) typedef __int64 LONG_PTR; #else typedef long LONG_PTR;
            :LPARAM=>   "l", # Message parameter. WinDef.h as follows=> #typedef LONG_PTR LPARAM;
            :LPBOOL=>   "i", # Pointer to a BOOL. WinDef.h as follows=> #typedef BOOL far *LPBOOL;
            :LPBYTE=>   "i", # Pointer to a BYTE. WinDef.h as follows=> #typedef BYTE far *LPBYTE;
            :LPCSTR=>   "p", # Pointer to a constant null-terminated string of 8-bit Windows (ANSI) characters.
            # See Character Sets Used By Fonts. http=>//msdn.microsoft.com/en-us/library/dd183415%28VS.85%29.aspx
            :LPCTSTR=>  "p", # An LPCWSTR if UNICODE is defined, an LPCSTR otherwise.
            :LPCVOID=>  "v", # Pointer to a constant of any type. WinDef.h as follows=> typedef CONST void *LPCVOID;
            :LPCWSTR=>  "P", # Pointer to a constant null-terminated string of 16-bit Unicode characters.
            :LPDWORD=>  "p", # Pointer to a DWORD. WinDef.h as follows=> typedef DWORD *LPDWORD;
            :LPHANDLE=> "l", # Pointer to a HANDLE. WinDef.h as follows=> typedef HANDLE *LPHANDLE;
            :LPINT=>    "I", # Pointer to an INT.
            :LPLONG=>   "L", # Pointer to an LONG.
            :LPSTR=>    "p", # Pointer to a null-terminated string of 8-bit Windows (ANSI) characters.
            :LPTSTR=>   "p", # An LPWSTR if UNICODE is defined, an LPSTR otherwise.
            :LPVOID=>   "v", # Pointer to any type.
            :LPWORD=>   "p", # Pointer to a WORD.
            :LPWSTR=>   "p", # Pointer to a null-terminated string of 16-bit Unicode characters.
            :LRESULT=>  "l", # Signed result of message processing. WinDef.h=> typedef LONG_PTR LRESULT;
            :PBOOL=>    "i", # Pointer to a BOOL.
            :PBOOLEAN=> "i", # Pointer to a BOOL.
            :PBYTE=>    "i", # Pointer to a BYTE.
            :PCHAR=>    "p", # Pointer to a CHAR.
            :PCSTR=>    "p", # Pointer to a constant null-terminated string of 8-bit Windows (ANSI) characters.
            :PCTSTR=>   "p", # A PCWSTR if UNICODE is defined, a PCSTR otherwise.
            :PCWSTR=>    "p", # Pointer to a constant null-terminated string of 16-bit Unicode characters.
            :PDWORD=>    "p", # Pointer to a DWORD.
            :PDWORDLONG=> "L", # Pointer to a DWORDLONG.
            :PDWORD_PTR=> "L", # Pointer to a DWORD_PTR.
            :PDWORD32=>  "L", # Pointer to a DWORD32.
            :PDWORD64=>  "L", # Pointer to a DWORD64.
            :PFLOAT=>    "L", # Pointer to a FLOAT.
            :PHALF_PTR=> "L", # Pointer to a HALF_PTR.
            :PHANDLE=>   "L", # Pointer to a HANDLE.
            :PHKEY=>     "L", # Pointer to an HKEY.
            :PINT=>      "i", # Pointer to an INT.
            :PINT_PTR=>  "i", # Pointer to an INT_PTR.
            :PINT32=>    "i", # Pointer to an INT32.
            :PINT64=>    "i", # Pointer to an INT64.
            :PLCID=>     "l", # Pointer to an LCID.
            :PLONG=>     "l", # Pointer to a LONG.
            :PLONGLONG=> "l", # Pointer to a LONGLONG.
            :PLONG_PTR=> "l", # Pointer to a LONG_PTR.
            :PLONG32=>   "l", # Pointer to a LONG32.
            :PLONG64=>   "l", # Pointer to a LONG64.
            :POINTER_32=> "l", # 32-bit pointer. On a 32-bit system, this is a native pointer. On a 64-bit system, this is a truncated 64-bit pointer.
            :POINTER_64=> "l", # 64-bit pointer. On a 64-bit system, this is a native pointer. On a 32-bit system, this is a sign-extended 32-bit pointer.
            :POINTER_SIGNED=>   "l", # A signed pointer.
            :HPSS=> "l",
            :POINTER_UNSIGNED=> "l", # An unsigned pointer.
            :PSHORT=>     "l", # Pointer to a SHORT.
            :PSIZE_T=>    "l", # Pointer to a SIZE_T.
            :PSSIZE_T=>   "l", # Pointer to a SSIZE_T.
            :PSS_CAPTURE_FLAGS=> "l",
            :PSTR=>       "p", # Pointer to a null-terminated string of 8-bit Windows (ANSI) characters. For more information, see Character Sets Used By Fonts.
            :PTBYTE=>     "p", # Pointer to a TBYTE.
            :PTCHAR=>     "p", # Pointer to a TCHAR.
            :PTSTR=>      "p", # A PWSTR if UNICODE is defined, a PSTR otherwise.
            :PUCHAR=>     "p", # Pointer to a UCHAR.
            :PUINT=>      "i", # Pointer to a UINT.
            :PUINT_PTR=>  "i", # Pointer to a UINT_PTR.
            :PUINT32=>    "i", # Pointer to a UINT32.
            :PUINT64=>    "i", # Pointer to a UINT64.
            :PULONG=>     "l", # Pointer to a ULONG.
            :PULONGLONG=> "l", # Pointer to a ULONGLONG.
            :PULONG_PTR=> "l", # Pointer to a ULONG_PTR.
            :PULONG32=>   "l", # Pointer to a ULONG32.
            :PULONG64=>   "l", # Pointer to a ULONG64.
            :PUSHORT=>    "l", # Pointer to a USHORT.
            :PVOID=>      "v", # Pointer to any type.
            :PWCHAR=>     "p", # Pointer to a WCHAR.
            :PWORD=>      "p", # Pointer to a WORD.
            :PWSTR=>      "p", # Pointer to a null- terminated string of 16-bit Unicode characters.
            # For more information, see Character Sets Used By Fonts.
            :SC_HANDLE=>  "l", # (L) Handle to a service control manager database.
            :SERVICE_STATUS_HANDLE=> "l", # (L) Handle to a service status value. See SCM Handles.
            :SHORT=>     "i", # A 16-bit integer. The range is –32768 through 32767 decimal.
            :SIZE_T=>    "l", #  The maximum number of bytes to which a pointer can point. Use for a count that must span the full range of a pointer.
            :SSIZE_T=>   "l", # Signed SIZE_T.
            :TBYTE=>     "p", # A WCHAR if UNICODE is defined, a CHAR otherwise.TCHAR=>
            # http=>//msdn.microsoft.com/en-us/library/c426s321%28VS.80%29.aspx
            :TCHAR=>     "p", # A WCHAR if UNICODE is defined, a CHAR otherwise.TCHAR=>
            :UCHAR=>     "p", # Unsigned CHAR (8 bit)
            :UHALF_PTR=> "i", # Unsigned HALF_PTR. Use within a structure that contains a pointer and two small fields.
            :UINT=>      "i", # Unsigned INT. The range is 0 through 4294967295 decimal.
            :UINT_PTR=>  "i", # Unsigned INT_PTR.
            :UINT32=>    "i", # Unsigned INT32. The range is 0 through 4294967295 decimal.
            :UINT64=>    "i", # Unsigned INT64. The range is 0 through 18446744073709551615 decimal.
            :ULONG=>     "l", # Unsigned LONG. The range is 0 through 4294967295 decimal.
            :ULONGLONG=> "l", # 64-bit unsigned integer. The range is 0 through 18446744073709551615 decimal.
            :ULONG_PTR=> "l", # Unsigned LONG_PTR.
            :ULONG32=>   "i", # Unsigned INT32. The range is 0 through 4294967295 decimal.
            :ULONG64=>   "i", # Unsigned LONG64. The range is 0 through 18446744073709551615 decimal.
            :UNICODE_STRING=> "P", # Pointer to some string structure??
            :USHORT=>    "i", # Unsigned SHORT. The range is 0 through 65535 decimal.
            :USN=>    "l", # Update sequence number (USN).
            :WCHAR=>  "i", # 16-bit Unicode character. For more information, see Character Sets Used By Fonts.
            # In WinNT.h=> typedef wchar_t WCHAR;
            #WINAPI=> K,      # Calling convention for system functions. WinDef.h=> define WINAPI __stdcall
            :WORD=> "i", # 16-bit unsigned integer. The range is 0 through 65535 decimal.
            :WPARAM=> "i",    # Message parameter. WinDef.h as follows=> typedef UINT_PTR WPARAM;
            :VOID=>   "v", # Any type ? Only use it to indicate no arguments or no return value
            :vKey=> "i",
            :LPRECT=> "p",
            :char=> "p",
  }
  #---------------------------------------------------------------
  # • [Array] => Get the specified values on method. After, check out each one if is
  # String or Symbol.... If was Symbol will return at the specified value on
  # the constant TYPES;
  #  Exemplo=> types([=>BOOL, =>WCHAR]) # ["i", "i"]
  #---------------------------------------------------------------
  def types(import)
    import2 = []
    import.each { |i|
     next if i.is_a?(NilClass) or i.is_a?(String)
     import2 <<  TYPES[i]
    }
    return import2
  end
  #---------------------------------------------------------------
  # • [INT] => Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #---------------------------------------------------------------
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
  #---------------------------------------------------------------
  # • [LONG] => Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #---------------------------------------------------------------
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
  #---------------------------------------------------------------
  # • [VOID] => Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #---------------------------------------------------------------
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
  #---------------------------------------------------------------
  # • [CHAR] => Specific a function, with the value of importation and the DLL.
  # For default, the DLL is the "user32".
  #---------------------------------------------------------------
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
  #---------------------------------------------------------------
  # • [Dll]// => You can specified a dll function
  #   function(export, function, import, dll)
  #    export => exportation value. Format [Symbol]
  #    function => dll function
  #    import => importation value
  #    dll => dll, for default is 'user32'
  # Exemplo=> function(=>int, "ShowCursor", [=>BOOL]).call(0) # hide the mouse
  #---------------------------------------------------------------
  def function(export, function, import, dll="user32")
    eval("#{export}(function, import, dll)")
  end
  #---------------------------------------------------------------
  # • Especificando o método protegido.
  #---------------------------------------------------------------
  # Métodos privados.
  private :long, :int, :char, :void, :types
  #---------------------------------------------------------------
  # • [FindWindow]/Dll : Recupera o identificador da janela superior. Cujo
  # o nome da janela é o nome da classe da janela se combina com as cadeias
  # especificas.
  #    FindWindow.call(lpClassName,  lpWindowName)
  #      lpClassName : Formato [String]
  #      lpWindowName : Formato [String]
  #---------------------------------------------------------------
  FindWindow = long('FindWindowA', [:LPCTSTR, :LPCTSTR])
  #---------------------------------------------------------------
  # • [Handle]/Dll : Retorna ao Handle da janela.
  #---------------------------------------------------------------
  def hwnd(game_title=load_data("Data/System.rxdata").game_title.to_s, window='RGSS Player')
    return API::FindWindow.call(window, game_title)
  end
end
#=================================================================
# [ Movie ] :movie
#=================================================================
class Movie
  #--------------------------------------------------------------
  # constants
  #--------------------------------------------------------------
  REFRESHTIME = Integer((60 * 60) * 3) # each '3' secs will update the screen
  MCI = API.function(:void, "mciSendString", [:LPCTSTR, :LPTSTR, :UINT, :HANDLE], "winmm")
  SMESSAGE = API.function(:void, "SendMessage", [:HWND, :UINT, :WPARAM, :LPARAM])
  GSYSTEMM = API.function(:long, "GetSystemMetrics", [:long])
  #--------------------------------------------------------------
  # initialize | for default is on ./Movies, just type the filename
  #--------------------------------------------------------------
  def initialize(filename, time, directory="./Movies/%s")
    @hwnd = API.hwnd(nil)
    @filename = directory % filename
    @time = time
    @_ntime = Time.now
    @refreshTime = 0
    @test = Sprite.new()
    @test.bitmap = Bitmap.new(64,48)
    @test.z = 5000
    @test.visible = false
    sleep(1.0)
    main
  end
  #--------------------------------------------------------------
  # main method
  #--------------------------------------------------------------
  def main
    MCI.call("open \""+@filename+"\" alias FILE style 1073741824 parent " + @hwnd.to_s,0,0,0)
    gmsystem
    @status = " " * 255
    MCI.call("play FILE",0,0,0)
    update 
  end
  #--------------------------------------------------------------
  # update and run the movie
  #--------------------------------------------------------------
  def update
    loop do
      if (Time.now.to_f - @_ntime.to_f) >= @time.to_f
        Graphics.update 
        terminate
        break 
        return
      end
      Input.update
      if Input.trigger?(Input::C)
        terminate
        break 
        return
      end
      if @refreshTime >= REFRESHTIME
        Graphics.update 
        @refreshTime = 0
      end
      @refreshTime += 1
      @test.bitmap.clear
      @test.bitmap.draw_text(0,0,64,48,@refreshTime.to_s)
    end
  end
  #--------------------------------------------------------------
  # end up
  #--------------------------------------------------------------
  def terminate
    MCI.call("close FILE",0,0,0)
    @test.dispose
  end
  #--------------------------------------------------------------
  # check if the window is with the right size
  #--------------------------------------------------------------
  def gmsystem
    if GSYSTEMM.call(0) == 640
      Graphics.update
      sleep(1)
      Graphics.update
      sleep(1)
      Graphics.update
      sleep(1)
    end
  end
  #--------------------------------------------------------------
  # unpack the @status
  #--------------------------------------------------------------
  def tstatus
    @status.unpack("aaaa")
  end
end

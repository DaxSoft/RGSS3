#==============================================================================
# • Plugin
#==============================================================================
# Autor: Dax
# Versão: 2.5
# Site: www.dax-soft.weebly.com
# Requerimento: Dax Core
# tiagoms : Ajudou dando feedback.
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Este script irá permitir que você possa adicionar 'plugins' a seu projeto e 
# atualiza-los diretamente do mesmo. Plugin que digo, são scripts. 
# A vantagem deste script é o update automático dos scripts, direto do projeto. 
#==============================================================================
# • Como usar: 
#------------------------------------------------------------------------------
# • Para adicionar um Plugin, você deve registrá-lo. Veja abaixo como fazer
# e um exemplo. Se tiver aprendido, e não tiver necessidade do tutorial.
# Recomendo apagar o tutorial e o exemplo xD.
=begin
** Para registrar é muito simples. 
Plugin.register(name, author, version, link)
        Você deve de definir o nome de registro do plugin.
        name:             :nome_de_registro, # Deste modo.
        Você deve de definir o autor do plugin.
        author:           "Autor", # Desta maneira.
        Você deve de definir a versão do plugin. Para fazer baixar, caso não tenha o
        mesmo, basta por a versão 0.0.
        version:          1.0,
        Você deve de definir o link do plugin, onde o mesmo será baixado.
        link:             "url do link"
** Agora, no LINK em que você definir, deve conter o seguinte:

<plugin>
  <version>VERSÃO DO PLUGIN</version>
  <info>Informações da versão atual.</info>
</plugin>


<tag HEADER>
  <output>TIPO DE EXTENSÃO DO ARQUIVO PADRÃO</output>
  {
    NOME DO ARQUIVO <l> URL DO LINK <f> PASTA, OPICIONAL DEFINIR
  }
</tag>

tipos de tags:
  files : Todos os arquivos postos aqui, serão executados.
  graphic
  audio 
  movies 
  system
  project

tipos do HEADER: PASTA PARA:
  ROOTPATH : Data/Plugins/
  GRAPHICS : Graphics/
  AUDIO : Audio/
  MOVIE : Movies/
  SYSTEM : System/
  PROJECT : /
  CASO NÃO SEJA DEFINIDO : Data/Plugins/
=end
#==============================================================================
# • Versões:
#------------------------------------------------------------------------------
# [2.0]
#    Sistema funcional.
#    Novo método de registrar o plugin para o download.
# [2.1]
#    Novo método de baixar.
# [2.2]
#    Add da tag de informação.
# [2.3]
#    Novo método de registrar os arquivos do plugin.
# [2.5]
#    Correção de pequenos bugs.
#    Funçao de deletar plugins.
#==============================================================================
Dax.register(:plugin, "dax", 2.5, [[:powershell, "dax"]]) {
  Dir.mkdir("#{Dir.pwd}/Data/Plugins") unless FileTest.directory?("#{Dir.pwd}/Data/Plugins")
  $ROOT_PATH = ->(filename, dir="") { "#{Dir.pwd}/Data/Plugins/#{dir}#{filename}" }
  #============================================================================
  # • Plugin
  #============================================================================
  module Plugin
    #--------------------------------------------------------------------------
    # • Extend: self
    #   Include: API
    #--------------------------------------------------------------------------
    include API
    extend self
    #--------------------------------------------------------------------------
    # • Constants
    #--------------------------------------------------------------------------
    KEY = :F8
    VERSION = "2.5"
    TEMP = "./temp.txt"
    ERROR = true # mostrar erros.
    MSG = {
      CONF: "Deseja verificar/baixar novas versões dos plugins?\nCaso seja a primeira vez executando, irá ocorrer um pequeno delay, só aguardar...\nPressione #{KEY} para acessar ao menu.",
      DOWN_PLUGIN: "Você deseja baixar o plugin: <%s>\nDo autor: <%s>\nversão: <%03s>\n",
      NEW_UPDATE: "Uma nova atualização está disponível, do plugin: <%s>\ndo autor: <%s>\nversão: <%03s>\n",
      NO_INTERNET: "Sem conexão com à internet",
      FORMAT: MessageBox::ICONINFORMATION|MessageBox::YESNO,
      TITLE: "Plugin Manager #{VERSION}",
      PLMS: "Plugin Manager #{VERSION} < Plugins Instalados: %02d >",
      BACK: "Retornar",
      CL: "<%s> de <%s> versão <%.3f>",
      DELETE: "Deletar",
      RF: "Saia do projeto para atualizar o registro.\nDeseja sair agora?",
    }
    RKEY = [:files, :graphic, :system, :audio, :movie, :project]
    #--------------------------------------------------------------------------
    # • Variables
    #--------------------------------------------------------------------------
    @@register = {}
    @@download = {}
    @@root_path = {}
    #--------------------------------------------------------------------------
    # • Run plugin
    #--------------------------------------------------------------------------
    def run()
      File.delete(TEMP) if FileTest.exist?(TEMP)
      check()
      ps("exit")
    end
    #--------------------------------------------------------------------------
    # • Load all plugin files
    #--------------------------------------------------------------------------
    def start()
      loadRegister() if FileTest.exist?("#{Dir.pwd}/Data/register.rvdata2")
      @@register.each_value { |value|
        value[:path].each { |i|
          load_script(i) rescue next
        } rescue next
      }
    end
    #--------------------------------------------------------------------------
    # • Register the plugins
    # => hash
    #    {
    #       name: :name,
    #       author: :author,
    #       version: 0.0,
    #       link: ""
    #    }
    #--------------------------------------------------------------------------
    def register(name, author, version, link)
      hash = { 
        name: name,
        author: author, 
        version: version,
        link: link
      }
      registerError(hash)
      return if registred?(hash[:name], hash[:author], hash[:version])
      @@register[[hash[:name], hash[:author]]] = hash
      @@download[[hash[:name], hash[:author]]] = []
      @@register[[hash[:name], hash[:author]]][:path] = []
      @@register[[hash[:name], hash[:author]]][:_path] = []
      @@root_path[[hash[:name], hash[:author]]] = []
    end
    #--------------------------------------------------------------------------
    # • Check the registers plugin
    #--------------------------------------------------------------------------
    def registred?(name, author, version=nil, compare=:>=)
      if @@register.has_key?([name, author])
        return true if version.nil?
        return !(@@register[[name, author]].get(:version) { |_version| version.method(compare).call(_version) } ).nil?
      else
        return false
      end
    end
    #--------------------------------------------------------------------------
    # • Check error register
    #--------------------------------------------------------------------------
    def registerError(hash)
      return unless hash.is_a?(Hash)
      raise("Error Plugin Register : name not defined") if hash[:name].nil?
      raise("Error Plugin Register : author not defined") if hash[:author].nil?
      raise("Error Plugin Register : version not defined") if hash[:version].nil?
      raise("Error Plugin Register : link not defined") if hash[:link].nil?
    end
    #--------------------------------------------------------------------------
    # • Get register information
    #--------------------------------------------------------------------------
    def registerInfo(key, author, version=nil)
      return unless registred?(key, author, version)
      @@register[[key, author]]
    end
    #--------------------------------------------------------------------------
    # • Get the total of the registers
    #--------------------------------------------------------------------------
    def size
      n = 0
      @@register.each_value { |v| v[:version] > 0.0 ? n += 1 : next }
      return n
    end
    #--------------------------------------------------------------------------
    # • Data
    #--------------------------------------------------------------------------
    def data
      @@register
    end
    #--------------------------------------------------------------------------
    # • check file downlaod
    #--------------------------------------------------------------------------
    def check()
      # => check the internet, state of the project, load register
      return unless $TEST
      return msgbox(MSG[:NO_INTERNET]) unless Network.connected?
      loadRegister if FileTest.exist?("#{Dir.pwd}/Data/register.rvdata2")
      # => register infos
      @@register.each_pair { |key, value|
        # => generator temp file
        @@download.delete([*key])
        #Network.link_download(value.get(:link), TEMP)
        Powershell.wget(value.get(:link), TEMP)
        tempFile = File.open(TEMP, "rb") 
        @@download[[*key]] = Plugin::Parse.start(tempFile.read)
        version = @@download[[*key]][:version]
        information = @@download[[*key]][:info] 
        puts "#{value[:name]}::\r\n\t temp version -> #{version}\r\n\t register version -> #{value[:version]}\r\n"
        MessageBox.call("#{value[:name]} #{version}", information, 0)
        # => check version
        if value[:version] == 0.0
          msg = sprintf(MSG[:DOWN_PLUGIN], value.get(:name), value.get(:author), version)
          hresult = MessageBox.call(MSG[:TITLE], msg, MSG[:FORMAT])
        elsif version > value.get(:version)
          @@register[[*key]][:path] = []
          msg = sprintf(MSG[:NEW_UPDATE], value.get(:name), value.get(:author), version)
          hresult = MessageBox.call(MSG[:TITLE], msg, MSG[:FORMAT])
        end
        # => download
        if hresult == MessageBox::YES
          RKEY.each { |rkey|
            next unless @@download[[*key]].has_key?(rkey)
            Powershell.run("Clear-Host")
            download(@@download[[*key]][rkey], key, rkey)
            @@register[[*key]][:version] = version
          }
        end
        # => register new version and save
        tempFile.close
        File.delete(TEMP) if FileTest.exist?(TEMP)
        Graphics.wait(30)
      }
      saveRegister()
    end
    #--------------------------------------------------------------------------
    # • headerFilter
    #--------------------------------------------------------------------------
    def headerFilter(header)
      dot = "."
      if header == "ROOTPATH"
        return "#{dot}/Data/Plugins/"
      elsif header == "GRAPHICS"
        return "#{dot}/Graphics/"
      elsif header == "AUDIO"
        return "#{dot}/Audio/"
      elsif header == "MOVIE"
        return "#{dot}/Movies/"
      elsif header == "SYSTEM"
        return "#{dot}/System/"
      elsif header == "PROJECT"
        return "#{dot}/"
      else
        return "#{dot}/Data/Plugins/"
      end
    end
    #--------------------------------------------------------------------------
    # • Download
    #--------------------------------------------------------------------------
    def download(kd, key, rkey)
      # => get hash
      files = kd.get(:filename)
      header = kd.get(:header)
      links = kd.get(:link)
      folder = kd.get(:folder)
      # => files
      return if files.nil? or files.empty? or !files.is_a?(Array)
      files.each_with_index { |fname, n|
        path = header + folder[n] rescue header
        Dir.mkdir(path) unless FileTest.directory?(path)
        fpath = path + fname 
        nfname = "./" + fname.gsub(" ", "_")
        Powershell.wget(links[n], nfname, "-v") 
        Graphics.wait(30)
        if rkey == :files
          @@register[[*key]][:path] << fpath
        else
          @@register[[*key]][:_path] << fpath
        end
        File.delete(fpath) if FileTest.exist?(fpath)
        File.rename(nfname, fpath) if FileTest.exist?(nfname)
      }
      Graphics.wait(30)
    end
    #--------------------------------------------------------------------------
    # • saveRegister
    #--------------------------------------------------------------------------
    def saveRegister()
      File.open("#{Dir.pwd}/Data/register.rvdata2", "wb") { |file|
        export = ->() {
          content = {}
          content[:register] = @@register
          content
        }
        Marshal.dump(export.call, file)
      }
    end
    #--------------------------------------------------------------------------
    # • loadRegister
    #--------------------------------------------------------------------------
    def loadRegister()
      File.open("#{Dir.pwd}/Data/register.rvdata2", "rb") { |file|
        import = ->(content) {
          @@register.merge!(content[:register]) rescue {}
          @@root_path.merge!(content[:root_path]) rescue {}
        }
        import[Marshal.load(file)]
      }
    end
  end
  #============================================================================
  # • Plugin Parse
  #============================================================================
  module Plugin::Parse
    #--------------------------------------------------------------------------
    # • Extend self
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # • Constant
    #--------------------------------------------------------------------------
    REG = ->(tag) { return (/<#{tag}>(.*?)<\/#{tag}>/im) }
    HEADER = ->(header) { 
      if header == "ROOTPATH"
        return "./Data/Plugins/"
      elsif header == "GRAPHICS"
        return "./Graphics/"
      elsif header == "AUDIO"
        return "./Audio/"
      elsif header == "MOVIE"
        return "./Movies/"
      elsif header == "SYSTEM"
        return "./System/"
      elsif header == "PROJECT"
        return "./"
      else
        return "./Data/Plugins/"
      end
    }
    #--------------------------------------------------------------------------
    # • read
    # => output is as Hash.
    #--------------------------------------------------------------------------
    def start(str, gA=true)
      str.gsub!(/<!--(.*?)-->/im, "")
      @@hash = {}
      general(str)
      ["files","graphic","system","audio","movie","project"].each { |tags| tag(str, tags) }
      @@hash
    end
    #--------------------------------------------------------------------------
    # • Checks the general setup
    #--------------------------------------------------------------------------
    def general(str)
      str.match(/<plugin>(.*?)<\/plugin>/im)
      content = $1
      @@hash[:version] = content.scan(REG["version"]).shift.shift.to_f rescue ""
      @@hash[:info] = content.scan(REG["info"]).shift.shift.to_s rescue ""
    end
    #--------------------------------------------------------------------------
    # • Checks the files setup
    #--------------------------------------------------------------------------
    def tag(str, tag)
      return unless str.include?(tag)
      @@hash[tag.symbol] = {}
      hash = {}
      str.match(/<#{tag} (.*?)>(.*?)<\/#{tag}>/im)
      hash[:header] = HEADER[$1] rescue "./Data/Plugins/"
      content = $2
      hash[:output] = content.scan(REG["output"]).shift.shift.to_s rescue "rb"
      hash[:filename] = []
      hash[:link] = []
      hash[:folder] = []
      content.match(/\{(.*?)\}/im) rescue return
      list = $1.split(/\n/).if{|i|!i.empty?}.collect!(&:lstrip)
      list.each { |l|
        if l.include?("<f>")
          l.match(/(.*?)<l>(.*?)<f>(.*)/i)
          fname = $1.strip rescue ""
          next if fname.nil? or fname.empty?
          unless fname.include?(".")
            fname << ".#{hash[:output]}"
          end
          hash[:filename] << fname
          link = $2.strip rescue ""
          next if link.nil? or link.empty?
          hash[:link] << link
          folder = $3.strip rescue ""
          next if folder.nil? or folder.empty?
          hash[:folder] << folder + "/"
          next
        else
          l.match(/(.*?)<l>(.*)/i)
          fname = $1.strip rescue ""
          next if fname.nil? or fname.empty?
          unless fname.include?(".")
            fname << ".#{hash[:output]}"
          end
          hash[:filename] << fname
          link = $2.strip rescue ""
          next if link.nil? or link.empty?
          hash[:link] << link
          next
        end
      }
      @@hash[tag.symbol].merge!(hash)
    end
  end
  #============================================================================
  # • Window_PluginManager
  #============================================================================
  class Window_PluginManager < Window_Command
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize
      super(0, 0)
      self.y += 20
      self.openness = 0
      self.opacity = 0
      self.back_opacity = 0
      open
    end
    #--------------------------------------------------------------------------
    # • Largura da janela
    #--------------------------------------------------------------------------
    def window_width
      return Graphics.width
    end
    #--------------------------------------------------------------------------
    # • Lista dos comandos
    #--------------------------------------------------------------------------
    def make_command_list
      #add_command(Vocab::to_title, :to_title)
      add_command(Plugin::MSG[:BACK], :back)
      Plugin.data.each_pair { |key, value|
          next if value[:version] <= 0.0
          str = sprintf(Plugin::MSG[:CL], key[0], key[1], value.get(:version).round(3))
          skey = ("#{key[0]}_#{key[1]}").symbol
          add_command(str, skey)
      } 
    end
  end
  #============================================================================
  # • Window_PluginManager
  #============================================================================
  class Window_PluginManagerConfirm < Window_Command
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize
      super(0, 0)
      Position[:center, self]
      self.openness = 0
      self.opacity = 0
      self.back_opacity = 0
    end
    #--------------------------------------------------------------------------
    # • Largura da janela
    #--------------------------------------------------------------------------
    def window_width
      return 164
    end
    #--------------------------------------------------------------------------
    # • Lista dos comandos
    #--------------------------------------------------------------------------
    def make_command_list
      add_command(Plugin::MSG[:DELETE], :delete) 
      add_command(Plugin::MSG[:BACK], :back)
    end
  end
  #============================================================================
  # • Scene_PluginManager
  #============================================================================
  class Scene_PluginManager < Scene_Base
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def start
      super
      @index = []
      @info = Sprite_Text.new(16, 0, Graphics.width-16, 20, "")
      @info.size = 18
      create_window
      @cwindow = Window_PluginManagerConfirm.new
      @cwindow.set_handler(:delete, method(:deletePlugin))
      @cwindow.set_handler(:back, method(:back))
    end
    #--------------------------------------------------------------------------
    # • Criar window
    #--------------------------------------------------------------------------
    def create_window
      oldSize = Font.default_size
      Font.default_size = 18
      @window = Window_PluginManager.new
      @window.set_handler(:back, method(:return_scene))
      Plugin.data.each_pair { |key, value|
        next if value[:version] <= 0.0
        skey = ("#{key[0]}_#{key[1]}").symbol
        @window.set_handler(skey, method(:open))
        @index << key
      }
      Font.default_size = oldSize
    end
    #--------------------------------------------------------------------------
    # • Open
    #--------------------------------------------------------------------------
    def open
      @cwindow.open
      @cwindow.active = true
      @cwindow.visible = true
      @window.active = false
    end
    #--------------------------------------------------------------------------
    # • Delete
    #--------------------------------------------------------------------------
    def deletePlugin
      current = @index[@window.index.pred]
      back unless Plugin.registred?(*current)
      Plugin.registerInfo(*current)[:path].each { |file|
        puts "Deleting file... #{file}"
        File.delete(file) if FileTest.exist?(file)
        puts "File deleted!"
      }
      Plugin.registerInfo(*current)[:_path].each { |file|
        puts "Deleting file... #{file}"
        File.delete(file) if FileTest.exist?(file)
        puts "File deleted!"
      }
      Plugin.data.delete(current)
      Plugin.saveRegister()
      hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:RF], Plugin::MSG[:FORMAT])
      SceneManager.exit if hresult == API::MessageBox::YES
      @window.refresh
      back
    end
    #--------------------------------------------------------------------------
    # • Back
    #--------------------------------------------------------------------------
    def back
      @cwindow.active = false
      @cwindow.visible = false
      @window.active = true
    end
    #--------------------------------------------------------------------------
    # • Terminação dos objetos. 
    #--------------------------------------------------------------------------
    def terminate 
      super
      @window.dispose
      @cwindow.dispose
      @info.dispose
    end
    #--------------------------------------------------------------------------
    # • Atualização dos objetos.
    #--------------------------------------------------------------------------
    def update
      super
      [:B].each { |key| trigger?(key) {return_scene}  }
      @info.update
      @info.text = Plugin::MSG[:PLMS] % Plugin.size
    end
  end
  #============================================================================
  # • Scene_Base
  #============================================================================
  class Scene_Base
    #--------------------------------------------------------------------------
    # • Atualização dos objetos.
    #--------------------------------------------------------------------------
    alias :pluginManagerScene_update :update
    def update(*args, &block)
      SceneManager.call(Scene_PluginManager) if trigger?(Plugin::KEY)
      pluginManagerScene_update(*args, &block)
    end
  end
  #============================================================================
  # • Insira aqui: Os registros dos plugin.
  #============================================================================
  
  #============================================================================
  # • Run
  #============================================================================
  hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:CONF], Plugin::MSG[:FORMAT])
  Plugin.run() if hresult == API::MessageBox::YES
  Plugin.start()
}

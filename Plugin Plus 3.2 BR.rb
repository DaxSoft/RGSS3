#==============================================================================
# • Plugin
#==============================================================================
# Author: Dax
# Version: 3.2
# Site: www.dax-soft.weebly.com
# Requeriment: Dax Core
# tiagoms : Feedback that helped improve more on the project
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  Esse script irá permitir que você possa adicionar 'plugins' ao seu projeto e
# atualizá-los, direto do mesmo.
#==============================================================================
# • Como usar: http://tutorial-dax.weebly.com/plugin.html
#==============================================================================
# • Version:
#------------------------------------------------------------------------------
# [2.0]
#    Functional system.
#    New method to register the plugin to download.
# [2.1]
#    New method to download.
# [2.2]
#    Add the tag of the <info>
# [2.3]
#    New method to register the files of the plugin.
# [2.5]
#    Fix little bugs.
#    Function of del the plugins.
# [2.6]
#    Tag of the info the total size.
# [2.7]
#    Optional requirements to install a plugin register.
# [3.0]
#    New parser to register plugin's file
#    New PluginManager
#    New tag command to parser.
# [3.1]
#    New PluginManager, better.
# [3.2]
#    Fix PLuginManager menu
#    Disable/Enable plugin
#==============================================================================
Dax.register(:plugin, "dax", 3.2, [[:powershell, "dax"]]) {
  #============================================================================
  # • Default Folders and Global Variable $ROOT_PATH
  #============================================================================
  ["#{Dir.pwd}/Data/Plugins", "#{Dir.pwd}/Data/Plugins/About"].each { |_dir|
    Dir.mkdir(_dir) unless FileTest.directory?(_dir)
  }
  $ROOT_PATH = ->(filename, dir="") { "#{Dir.pwd}/Data/Plugins/#{dir}#{filename}" }
  #============================================================================
  # • Plugin
  #============================================================================
  module Plugin
    #--------------------------------------------------------------------------
    # • Extend: self/class
    #   Include: API/Module
    #--------------------------------------------------------------------------
    include API
    extend self
    #--------------------------------------------------------------------------
    # • Constants: Setup
    #--------------------------------------------------------------------------
    # Iniciar o script com o PluginManager?
    BEGIN_WITH_SCENEMANAGER = true
    # Tecla para ativar o plugin
    KEY = :F8
    # Versão do plugin
    VERSION = "3.2"
    # Temp file
    TEMP = "./temp.tmp"
    # Setup of the all message.
    MSG = {
      CONF: "Você deseja verificar/baixar novas versões dos plugins?\nSe for a primeira vez executando, irá acontecer um pequeno delay, apenas espere...\nPressione #{KEY} para acessar ao PluginManager.",
      DOWN_PLUGIN: "Você quer baixar esse plugin? %s\nDo autor: %s\nVersão: %03s\nTamanho total: %s\n",
      NEW_UPDATE: "Uma nova atualização está disponível para download, do plugin: %s\nDo autor: %s\nVersão: %s\nTamanho total: %s\n",
      NO_INTERNET: "Sem conexão com à internet.",
      FORMAT: MessageBox::ICONINFORMATION|MessageBox::YESNO,
      TITLE: "Plugin Manager #{VERSION}",
      PLMS: "Plugin Manager #{VERSION} [ instalados: %02d ]",
      BACK: "Retornar",
      CL: "%s [%.2f] [%s]",
      DELETE: "Deletar",
      RF: "Saia do projeto para atualizar o registro.\nVocê deseja fazer isso agora?",
      REQUIRE: "O plugin %s do autor %s.\nRequer o plugin %s do autor %s para funcionar.",
      DPBD: "Enquanto o download funciona, é necessário que você mantenha o projeto aberto e permaneça nele.",
      SURE: "Você tem certeza que deseja baixar esse plugin? %s",
      ABOUT: "...",
      INFO: "Info",
      FILE: "Arquivo",
      WEBSITE: "Contato",
      RESET: "Resetar",
      WEBGO: "Você tem certeza que quer ir até o website?",
      DELGO: "Você tem certeza que deseja deletar esse plugin?",
      RESGO: "Você tem certeza que deseja resetar os plugins?",
      NEXT: "Próximo",
      PRED: "Anterior",
      AD: "O plugin foi desativado",
      AD2: "O plugin foi ativado"
    }
    # Setup of the all tag
    RDIR = {
      files: "./Data/Plugins/",
      graphic: "./Graphics/",
      system: "./System/",
      audio: "./Audio/",
      movie: "./Movies/",
      data: "./Data/",
      project: "./",
    }
    # Register file
    PLUGIN_REGISTER_FILE = "#{Dir.pwd}/Data/Plugin.rvdata2"
    # Start with all plugin disabled
    DISABLED = false
    #----------------------------------------------------------------------------
    # • Configuração das fontes usadas.
    #----------------------------------------------------------------------------
    FONT = {
      # Fonte usada nos menus.
      base: {
        NAME: "Trebuchet MS", 
        SIZE: 16,
        BOLD: false,
        ITALIC: false,
        OUTLINE: false,
        COLOR: "FFFFFF",
        OUTCOLOR: "000000",
        SHADOW: false
      },
      # small
      small: {
        NAME: "Trebuchet MS", 
        SIZE: 16,
        BOLD: false,
        ITALIC: false,
        OUTLINE: false,
        COLOR: "FFFFFF",
        OUTCOLOR: "000000",
        SHADOW: false
      },
      # title
      title: {
        NAME: "Trebuchet MS", 
        SIZE: 18,
        BOLD: false,
        ITALIC: false,
        OUTLINE: false,
        COLOR: "FFFFFF",
        OUTCOLOR: "000000",
        SHADOW: false
      },
    }
    # Font proc
    FONT_PROC = ->(bitmap, sym=:base) {
      bitmap.font.name = FONT[sym][:NAME] || "Trebuchet MS"
      bitmap.font.size = FONT[sym][:SIZE] || 14
      bitmap.font.bold = FONT[sym][:BOLD] || false
      bitmap.font.italic = FONT[sym][:ITALIC] || false
      bitmap.font.shadow = FONT[sym][:SHADOW] || false
      bitmap.font.outline = FONT[sym][:OUTLINE] || false
      bitmap.font.out_color = FONT[sym][:OUTCOLOR].color || Color.new.hex("000000")
      bitmap.font.color = FONT[sym][:COLOR].color || Color.new.default
    }
    #--------------------------------------------------------------------------
    # • Back
    #--------------------------------------------------------------------------
    def backing
      if Plugin::BEGIN_WITH_SCENEMANAGER
        if SceneManager.stack.empty? or SceneManager.stack.first.is_a?(Scene_PluginManager)
          SceneManager.goto(SceneManager.first_scene_class)
        else
          SceneManager.return
        end
      else
        SceneManager.return
      end
    end
    #--------------------------------------------------------------------------
    # • Variables
    #--------------------------------------------------------------------------
    @@register = {}
    @@download = {}
    class << self; attr_accessor :buttonGeral; attr_accessor :currentPlugin end;
    @buttonGeral = true
    @currentPlugin = nil
    #--------------------------------------------------------------------------
    # • Run plugin
    #--------------------------------------------------------------------------
    def run()
      (File.delete(TEMP) if FileTest.exist?(TEMP)) rescue nil
      msgbox(MSG[:DPBD])
      self.check()
      (ps("exit")) rescue nil
    end
    #--------------------------------------------------------------------------
    # • Load all the plugin files
    #--------------------------------------------------------------------------
    def start()
      loadRegister()
      if DISABLED
        Plugin.data.each_pair { |n,i|
          i[:disabled] = true unless i[:disabled]
        }
      end
      @@register.each_value { |value|
        value[:path].each { |i|
          next if value[:disabled]
          i.gsub!(/\/\/|\/\/\//, "/")
          puts "Running: %s" % i
          load_script(i) rescue next
        } rescue next
      }
    end
    #--------------------------------------------------------------------------
    # • Delete
    #--------------------------------------------------------------------------
    def delete(key, author, ask=true)
      return unless registred?(key, author)
      registerInfo(key, author)[:path].each { |file|
        puts "Deleting file... #{file}"
        File.delete(file) if FileTest.exist?(file)
        puts "File deleted!"
      } rescue nil
      registerInfo(key, author)[:_path].each { |file|
        puts "Deleting file... #{file}"
        File.delete(file) if FileTest.exist?(file)
        puts "File deleted!"
      } rescue nil
      Plugin.data.delete([key, author])
      Plugin.saveRegister()
      if ask
        hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:RF], Plugin::MSG[:FORMAT])
        if hresult == API::MessageBox::YES
          SceneManager.exit 
        else
          return
        end
      end
    end
    #--------------------------------------------------------------------------
    # • Reset
    #--------------------------------------------------------------------------
    def reset
      Plugin.data.each_pair { |key, value|
        delete(key[0], key[1], false)
      }
      hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:RF], Plugin::MSG[:FORMAT])
      if hresult == API::MessageBox::YES
        SceneManager.exit 
      else
        backing
      end
    end
    #--------------------------------------------------------------------------
    # • Data
    #--------------------------------------------------------------------------
    def data
      @@register
    end
    #--------------------------------------------------------------------------
    # • Register method
    #     name: register name
    #     author: author(s)
    #     version: version
    #     url: url
    #     [optional]requires: [[register name, author], ...]
    #--------------------------------------------------------------------------
    def register(name, author, version, url, requires=[])
      need = []
      requires.each { |needed| need << needed unless registred?(needed) }
      if need.empty?
        hash = { name: name, author: author, version: version, url: url }
        registerError(hash)
        return if registred?(hash[:name], hash[:author], hash[:version])
        @@register[[hash[:name], hash[:author]]] = hash
        @@download[[hash[:name], hash[:author]]] = []
        @@register[[hash[:name], hash[:author]]][:path] = []
        @@register[[hash[:name], hash[:author]]][:_path] = []
        @@register[[hash[:name], hash[:author]]][:thumbnail] = ""
        @@register[[hash[:name], hash[:author]]][:disabled] = false
      else
        need.each { |needed|
          msg = sprintf(MSG[:REQUIRE], name, author, needed[0], needed[1])
          API::MessageBox.call(MSG[:TITLE], msg, API::MessageBox::ICONEXCLAMATION)
        }
      end
      return nil
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
      raise("Error Plugin Register : link not defined") if hash[:url].nil?
    end
    #--------------------------------------------------------------------------
    # • Get register information
    #--------------------------------------------------------------------------
    def registerInfo(key, author, version=nil)
      return unless registred?(key, author, version)
      @@register[[key, author]]
    end
    #--------------------------------------------------------------------------
    # • Get the total of the registers(installed)
    #--------------------------------------------------------------------------
    def size
      n = 0
      @@register.each_value { |v| v[:version] > 0.0 ? n += 1 : next }
      return n
    end
    #--------------------------------------------------------------------------
    # • saveRegister
    #--------------------------------------------------------------------------
    def saveRegister()
      File.open(PLUGIN_REGISTER_FILE, "wb") { |file|
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
      return unless FileTest.exist?(PLUGIN_REGISTER_FILE)
      File.open(PLUGIN_REGISTER_FILE, "rb") { |file|
        import = ->(content) {
          @@register.merge!(content[:register]) rescue {}
        }
        import[Marshal.load(file)]
      }
    end
    #--------------------------------------------------------------------------
    # • check file downlaod
    #--------------------------------------------------------------------------
    def check()
      # => check the internet, state of the project, load register
      return unless $TEST
      return msgbox(MSG[:NO_INTERNET]) unless Network.connected?
      loadRegister 
      # => register infos
      @@register.each_pair { |key, value|
        # => generator temp file
        @@download.delete([*key])
        #Network.link_download(value.get(:link), TEMP)
        Powershell.wget(value.get(:url), TEMP)
        tempFile = File.open(TEMP, "rb")
        @@download[[*key]] = Plugin::Parse.get(tempFile.read)
        _size = @@download[[*key]][:size]
        version = @@download[[*key]][:version]
        information = @@download[[*key]][:new] 
        puts "#{value[:name]}::\r\n\t temp version -> #{version}\r\n\t register version -> #{value[:version]}\r\n"
        #MessageBox.call("#{value[:name]} #{version}", information, 0)
        nameOf = @@download[[*key]][:name]
        @@register[[*key]][:title] = nameOf rescue key[0]
        @@register[[*key]][:date] = @@download[[*key]][:date] rescue "--"
        @@register[[*key]][:website] = @@download[[*key]][:website] rescue nil
        @@register[[*key]][:about] = @@download[[*key]][:info] rescue nil
        # => check version
        if value[:version] == 0.0
          msg = sprintf(MSG[:DOWN_PLUGIN], nameOf, value.get(:author), version, _size)
          hresult = MessageBox.call(MSG[:TITLE], msg+"\n\r#{information}", MSG[:FORMAT])
        elsif version > value.get(:version)
          @@register[[*key]][:path] = []
          @@register[[*key]][:_path] = []
          msg = sprintf(MSG[:NEW_UPDATE], nameOf, value.get(:author), version, _size)
          hresult = MessageBox.call(MSG[:TITLE], msg+"\n\r#{information}", MSG[:FORMAT])
        end
        # => download
        if hresult == MessageBox::YES
          loop do
            Graphics.update
            RDIR.each_key { |rkey|
              next unless @@download[[*key]].has_key?(rkey)
              Powershell.run("Clear-Host")
              download(@@download[[*key]][rkey], key, rkey)
              @@register[[*key]][:version] = version
            }
            Graphics.wait(5)
            break
          end
        end
        # => register new version and save
        tempFile.close
        File.delete(TEMP) if FileTest.exist?(TEMP) rescue nil
        Graphics.wait(30)
      }
      saveRegister()
    end
    #--------------------------------------------------------------------------
    # • Download
    #--------------------------------------------------------------------------
    def download(kd, key, rkey)
      # get the values
      files = kd.get(:filename)
      link = kd.get(:url)
      folder = kd.get(:folder)
      nreplace = kd.get(:dont_replace)
      ask = kd.get(:ask)
      # files
      return if files.nil? or files.empty? or !files.is_a?(Array)
      files.each_with_index { |basename, n|
        path = folder[n]
        checkPath = path.chop
        Dir.mkdir(checkPath) unless File.directory?(checkPath)
        fpath = path + basename
        next if nreplace[n] and FileTest.exist?(fpath)
        nfname = "./" + basename.gsub(" ", "_")
        if ask[n]
          hresult = MessageBox.call(MSG[:TITLE], MSG[:SURE] % basename, MSG[:FORMAT])
          hresult == MessageBox::YES ? Powershell.wget(link[n], nfname, "-v")  : next
        else
          Powershell.wget(link[n], nfname, "-v") 
        end
        Graphics.wait(30)
        @@register[[*key]][rkey == :files ? :path : :_path] << fpath
        File.delete(fpath) if FileTest.exist?(fpath)
        File.rename(nfname, fpath) if FileTest.exist?(nfname)
        @@download[[*key]][rkey][:progress].current += 1
        current = @@download[[*key]][rkey][:progress].current
      }
      Graphics.wait(30)
      return true
    end
  end
  #============================================================================
  # • Plugin::Parse
  #============================================================================
  module Plugin::Parse
    #--------------------------------------------------------------------------
    # • Extend: self/class
    #   Include: API/Module
    #--------------------------------------------------------------------------
    include Plugin
    extend self
    #--------------------------------------------------------------------------
    # • Regex setup/Other
    #--------------------------------------------------------------------------
    GEN = ->(tag) { return (/^?(?:#{tag})\:\s*(.*?)\n/im) }
    UTF_8 = ->(str) { return (str.encoding.to_s == "ASCII-8BIT" ? str.unpack("C*").pack("U*") : str) }
    RXML = ->(tag) { return (/<(?:#{tag})>(.*?)<\/(?:#{tag})>/im) }
    GENT = ->(tag) { return (/(?:#{tag})\:\s*(.*?)\n/im) }
    REFR = ->() { return (/(.*?)\s*\<l\:(.*?)>\s*(?:\<f\:(.*?)>)?/i) }
    #--------------------------------------------------------------------------
    # • Tag setup
    #--------------------------------------------------------------------------
    # General tag setup
    GENERAL_TAG = [
      ["Name|name|N|n", :name],
      ["Version|version|V|v|ver|Ver", :version],
      ["Size|size|S|s", :size],
      ["Date|date|D|d", :date],
      ["Website|website|Web|web|Site|site|Contact|contact", :website]
    ]
    # General tag setting
    TAG_SETTING = [
      ["Output|output|Ext|ext|O|o|E|e", :output],
      ["Folder|folder|Dir|dir", :default_folder]
    ]
    #--------------------------------------------------------------------------
    # • [Hash] Get all content from the file
    #          filename : File
    #--------------------------------------------------------------------------
    def get(strParse)
      # delete all commentary
      strParse.gsub!(/\#\*(.*?)\*\#/im, "")
      @@data = {}
      general(strParse)
      manager(strParse)
      Plugin::RDIR.each_pair { |key, folder| generalTag(strParse, key, folder) }
      setupData
      Plugin::RDIR.each_key { |key|
        next unless @@data.has_key?(key)
        @@data[key][:progress] = Struct.new("ProgressPluginRegister", :current, :total).new
        @@data[key][:progress].current = 0
        @@data[key][:progress].total = @@data[key][:filename].size rescue 1
      }
      @@data
    end
    #--------------------------------------------------------------------------
    # • [Print] Log of get
    #--------------------------------------------------------------------------
    def log(filename)
      get(filename).each_pair { |key, value|
        if value.is_a?(Hash)
          value.each_pair { |skey, svalue|
            puts "\t-@ the sub key: [#{skey}] contains: #{svalue}\n\r"
          }
        else
          puts "@ the key: [#{key}] contains: #{value}\n\r"
        end
      }
    end
    #--------------------------------------------------------------------------
    # • Get the General Register
    #--------------------------------------------------------------------------
    def general(str)
      data = {}
      GENERAL_TAG.each { |tag|
        if tag[1] == :version
          data[tag[1]] = str.scan(GEN[tag[0]]).shift.shift.to_f rescue 0.0
        elsif tag[1] == :date or tag[1] == :size or tag[1] == :website
          data[tag[1]] = str.scan(GEN[tag[0]]).shift.shift.to_s rescue "--"
        else
          data[tag[1]] = str.scan(GEN[tag[0]]).shift.shift.to_s rescue ""
        end
      }
      # Getting the new
      data[:new] = UTF_8[str.scan(RXML["new|newest|about"]).shift.shift.to_s] rescue ""
      # merge
      @@data.merge!(data)
    end
    #--------------------------------------------------------------------------
    # • Get the plugin manager setting
    #--------------------------------------------------------------------------
    def manager(str)
      data = {}
      # Getting the info.
      str.gsub(/^\/\*(.*?)\*\//im) { 
        data[:info] = UTF_8[$1] rescue "--"
      }
      # merge
      @@data.merge!(data)
    end
    #--------------------------------------------------------------------------
    # • Get the general tags
    #--------------------------------------------------------------------------
    def generalTag(str, key, tfolder)
      (data ||= {})[key] = {}
      # get all content
      content = str.scan(RXML[key.to_s]).shift.shift.to_s rescue return
      # get the setting general
      TAG_SETTING.each { |_tag|
        if _tag[1] == :default_folder
          dfolder = (content.scan(GENT[_tag[0]]).shift.shift.to_s).gsub(/\r/, "") rescue ""
          data[key][_tag[1]] = dfolder.empty? ? dfolder : dfolder[dfolder.size.pred] == "/" ? dfolder : dfolder + "/"
        else
          data[key][_tag[1]] = (content.scan(GENT[_tag[0]]).shift.shift.to_s).gsub(/\r/, "") rescue ""
        end
      }
      # delete this information[tag general]
      TAG_SETTING.each { |_tag| content.gsub!(/(?:#{_tag[0]})\:\s*(.*?)\n/im, "") }
      # create each var to file register
      data[key][:dont_replace] = []
      data[key][:ask] = []
      data[key][:filename] = []
      data[key][:folder] = []
      data[key][:url] = []
      # read each line to file register
      (content.split("\n")).each { |line|
        # get the content
        line = line.scan(REFR[]).shift rescue next
        next if line.nil? or line.empty? 
        # filename
        filename = line.first.strip
        data[key][:filename] << filename
        # url
        url = line[1].strip
        data[key][:url] << url
        # folder(?exist?)
        if line[2].nil? or line[2].empty?
          dfolder = data[key][:default_folder]
          data[key][:folder] << (tfolder + dfolder) 
          next
        else
          lfolder = line[2][line[2].size.pred] == "/" ? line[2] : line[2] + "/"
          data[key][:folder] << (tfolder + lfolder.strip)
          next
        end
      }
      # setup filename
      data[key][:filename].each_with_index { |value, index|
        data[key][:dont_replace][index] = value.include?("#")
        data[key][:ask][index] = value.include?("!")
        value = value.include?(".") ? value : value << "." + data[key][:output]
        data[key][:filename][index] = (value.gsub!(/(?:\#|\!|\\t)*/im, "")).strip
      }
      # merge
      @@data.merge!(data)
    end
    #--------------------------------------------------------------------------
    # • setupData
    #--------------------------------------------------------------------------
    def setupData
      @@data.each_value { |value|
        value.strip if value.is_a?(String)
      }
    end
  end
  #============================================================================
  # • Plugin::Button
  #============================================================================
  class Plugin::Button < Sprite
    attr_accessor :clicked
    attr_accessor :active
    #--------------------------------------------------------------------------
    # • Inicialização.
    #--------------------------------------------------------------------------
    def initialize(pos, text, w=96, h=32, z=200, &block)
      pos = pos.position
      @action = block 
      @clicked = false
      @active = true
      super([w, h, pos.x, pos.y, z])
      self.opacity = 127.5
      Plugin::FONT_PROC[self.bitmap]
      self.bitmap.fill_rect(self.rect, "14181f".color)
      self.bitmap.draw_text_rect(text, 1)
    end
    #--------------------------------------------------------------------------
    # • Terminate
    #--------------------------------------------------------------------------
    def dispose
      self.bitmap.dispose
      super
    end
    #--------------------------------------------------------------------------
    # • Update
    #--------------------------------------------------------------------------
    def update
      super
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse estiver em cima do sprite?
    #----------------------------------------------------------------------------
    def mouse_over
      self.opacity = 255
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse não estiver em cima do sprite?
    #----------------------------------------------------------------------------
    def mouse_no_over
      self.opacity = 127.5
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse clicar no objeto
    #----------------------------------------------------------------------------
    def mouse_click
      return unless Plugin.buttonGeral
      return unless @active
      return unless self.visible
      @clicked = true
      @action.call rescue msgbox("error in action call")
    end
  end
  #============================================================================
  # • Plugin::Button_Plugin
  #============================================================================
  class Plugin::Button_Plugin < Sprite
    attr_accessor :clicked
    attr_accessor :delete
    attr_accessor :about
    #--------------------------------------------------------------------------
    # • Inicialização.
    #--------------------------------------------------------------------------
    def initialize(pos, key, author)
      @clicked = false
      @info = Plugin.registerInfo(key, author)
      @kea = [key, author]
      pos = pos.position
      super([Graphics.width, 48, pos.x, pos.y, 100])
      self.bitmap.fill_rect(self.rect, "131d22".color)
      thumbn = @info[:_path].select { |i| i.include?("/Thumbnail/") }
      thumbp = Bitmap.new(thumbn.shift) rescue Bitmap.new(32,32)
      src_rect = Rect.new(0, 0, thumbp.width, thumbp.height)
      self.bitmap.stretch_blt(Rect.new(3.5, 3, 43, 43), thumbp, src_rect)
      thumbp.dispose
      Plugin::FONT_PROC[self.bitmap, :title]
      self.bitmap.draw_text(52, 6, 314, 20, @info[:title].chop)
      Plugin::FONT_PROC[self.bitmap, :small]
      cl = [@info[:author], @info[:version], @info[:date].chop]
      self.bitmap.draw_text(52, 28, 314, 18, Plugin::MSG[:CL] % cl)
      @delete = Plugin::Button.new([Graphics.width + 100, self.y + 8], Plugin::MSG[:DELETE]) {
        hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:DELGO], Plugin::MSG[:FORMAT])
        if hresult == API::MessageBox::YES
          Plugin.delete(key, author)
        end
      }
      @about = Plugin::Button.new([Graphics.width + 100, self.y + 8], Plugin::MSG[:ABOUT]) {
        Plugin.currentPlugin = @kea
        SceneManager.call(Scene_PluginAbout)
      }
      update
    end
    #--------------------------------------------------------------------------
    # • Terminate
    #--------------------------------------------------------------------------
    def dispose
      self.bitmap.dispose
      super
      @delete.dispose
      @about.dispose
    end
    #--------------------------------------------------------------------------
    # • Update
    #--------------------------------------------------------------------------
    def update
      super
      @delete.update
      @about.update
      @delete.y = self.y + 8
      @about.y = @delete.y
      @delete.slide_left(10, Graphics.width - 100)
      @about.slide_left(10, Graphics.width - 196)
      [self, @delete, @about].each { |i| 
        i.opacity = 64 if Plugin.data[@kea][:disabled]
        i.visible = self.visible
      } rescue return
      if Mouse.area?(*Rect.new(self.x+4, self.y+3, 43, 43).to_a)  
        trigger?(0x01) { disableEnable }
      end
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse estiver em cima do sprite?
    #----------------------------------------------------------------------------
    def mouse_over
      self.opacity = 255
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse não estiver em cima do sprite?
    #----------------------------------------------------------------------------
    def mouse_no_over
      self.opacity = 127.5
    end
    #----------------------------------------------------------------------------
    # • O que irá acontecer sê o mouse clicar no objeto
    #----------------------------------------------------------------------------
    def mouse_click
      return unless self.visible
      @clicked = !@clicked
    end
    
    def disableEnable
      Plugin.buttonGeral = false
      Plugin.data[@kea][:disabled] = !Plugin.data[@kea][:disabled]
      Plugin.saveRegister
      msgbox(Plugin.data[@kea][:disabled] ? Plugin::MSG[:AD] : Plugin::MSG[:AD2])
      Graphics.wait(30)
      Plugin.buttonGeral = true
    end
  end
  #============================================================================
  # • Scene_PluginManager
  #============================================================================
  class Scene_PluginManager < Scene_Base
    #--------------------------------------------------------------------------
    # • start
    #--------------------------------------------------------------------------
    def start
      super
      @data = []
      @title = Sprite.new([316, 24, 8, 12, 200])
      Plugin::FONT_PROC[@title.bitmap, :small]
      @title.bitmap.draw_text_rect(Plugin::MSG[:PLMS] % Plugin.size)
      @reset = Plugin::Button.new([0, 8], Plugin::MSG[:RESET]) {
        hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:RESGO], Plugin::MSG[:FORMAT])
        if hresult == API::MessageBox::YES
          return Plugin.size < 1
          Plugin.reset
          exit
        end
        
      }
      @reset.position 1
      @reset.x += 108
      @back = Plugin::Button.new([0, 8], Plugin::MSG[:BACK]) {
        Plugin.backing
      }
      @back.position 1
      @back.x += 212
      @index = 0
      create_list
    end
    
    def create_list
      return if Plugin.size < 1
      @data.clear
      Plugin.data.each_pair { |key, value|
        next if value[:version] <= 0.0
        @data.push(Plugin::Button_Plugin.new([0,48],*key))
      } 
      posdata
    end
    
    def posdata
      @data.each_with_index { |i, n|
        i.y = 48 + ( (48) * ( ( (@index + n) ) % @data.size ) )
      }
      Graphics.wait(10)
    end
    
    def nexto
      return if @data.size < 8
      @index = @index.next % @data.size
      posdata
    end
  
    def predo
      return if @data.size < 8
      @index = @index.pred % @data.size
      posdata
    end
    #--------------------------------------------------------------------------
    # • terminate
    #--------------------------------------------------------------------------
    def terminate
      super
      [@reset, @back].each(&:dispose)
      @data.each(&:dispose) unless @data.empty?
    end
    #--------------------------------------------------------------------------
    # • update 
    #--------------------------------------------------------------------------
    def update
      super
      [@reset, @back].each { |i|
        i.update
      }
      @data.each(&:update) unless @data.empty?
      @data.each_with_index { |i, n|
        create_list if i.delete.clicked
      }
      create_list if @reset.clicked
      if Mouse.area?(0, 48, Graphics.width, 8)
        nexto
      elsif Mouse.area?(0, Graphics.height-8, Graphics.width, 8)
        predo
      end
    end
  end
  #============================================================================
  # • Scene_PluginAbout
  #============================================================================
  class Scene_PluginAbout < Scene_Base
    #--------------------------------------------------------------------------
    # • start
    #--------------------------------------------------------------------------
    def start
      @plugin = Plugin.registerInfo(*Plugin.currentPlugin)
      super
      @title = Sprite.new([Graphics.width-32, 32, 16, 16, 200])
      Plugin::FONT_PROC[@title.bitmap, :title]
      @title.bitmap.draw_text_rect(@plugin[:title].chop, 0)
      @back = Plugin::Button.new([0, 8], Plugin::MSG[:BACK]) {
        SceneManager.return
      }
      @web = Plugin::Button.new([0,8], Plugin::MSG[:WEBSITE]) {
        method(:website).call
      }
      @info = Plugin::Button.new([0,0], Plugin::MSG[:INFO]) {
        msgbox @plugin[:about]
      }
      @current = Plugin::Button.new([0,0], Plugin::MSG[:FILE]) {
        method(:current).call
      }
      [@back, @current, @web, @info].each_with_index { |i, n|
        i.position 1
        i.y = ( (Graphics.height - (48*4)) / 2 ) + 48 * n
      }
    end
    
    def website
      msgbox @plugin[:website]
    end
    
    def current
      file = @plugin[:_path].select { |i| i.include?("/Plugins/About/") }
      return if file.empty? or file.nil?
      system(`start #{file.shift}`)
    end
    #--------------------------------------------------------------------------
    # • terminate
    #--------------------------------------------------------------------------
    def terminate
      super
      [@title, @back, @web, @info, @current].each(&:dispose)
    end
    #--------------------------------------------------------------------------
    # • update 
    #--------------------------------------------------------------------------
    def update
      super
      [@back, @web, @info, @current].each(&:update)
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
      if trigger?(Plugin::KEY)
        SceneManager.call(Scene_PluginManager) unless SceneManager.is_a?(Scene_PluginManager)
      end
      pluginManagerScene_update(*args, &block)
    end
  end
  #============================================================================
  # • SceneManager
  #============================================================================
  class << SceneManager
    attr_accessor :stack
    #--------------------------------------------------------------------------
    # * Execução
    #--------------------------------------------------------------------------
    def run
      DataManager.init
      Audio.setup_midi if use_midi?
      unless Plugin::BEGIN_WITH_SCENEMANAGER
        @scene = first_scene_class.new
      else
        @scene = Scene_PluginManager.new
      end
      @scene.main while @scene
    end
    #--------------------------------------------------------------------------
    # * Cena da primeira classe
    #--------------------------------------------------------------------------
    def first_scene_class
      $BTEST ? Scene_Battle : Scene_Title
    end
  end
  #============================================================================
  # • Insert here: The registers of the plugins.
  #============================================================================
  Plugin.register(:ulse, :dax, 0.0, "http://pastebin.com/raw/eWxBengr")
  Plugin.register(:steampunk_hud, :dax, 0.0, "http://pastebin.com/raw/mGjQMB95")
  Plugin.register(:event_bar, :dax, 0.0, "http://pastebin.com/raw/ZRLKKGA7")
  Plugin.register(:sao_hud, :dax, 0.0, "http://pastebin.com/raw/XwcMq73M")
  #============================================================================
  # • Run
  #============================================================================
  if $TEST
    hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:CONF], Plugin::MSG[:FORMAT])
    if hresult == API::MessageBox::YES
      Plugin.run()
    end
  end
  Plugin.start()
}

#==============================================================================
# • Plugin
#==============================================================================
# Author: Dax
# Version: 3.0
# Site: www.dax-soft.weebly.com
# Requeriment: Dax Core
# tiagoms : Feedback that helped improve more on the project
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  This script will permit that you can add 'plugins' at your project and update
# them directly of your project.
#==============================================================================
# • How to use: http://tutorial-dax.weebly.com/plugin.html
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
#    Progress bar to download.
#    New PluginManager
#    New tag command to parser.
#==============================================================================
Dax.register(:plugin, "dax", 3.0, [[:powershell, "dax"]]) {
  #============================================================================
  # • Default Folders and Global Variable $ROOT_PATH
  #============================================================================
  _dir = "#{Dir.pwd}/Data/Plugins"
  Dir.mkdir(_dir) unless FileTest.directory?(_dir)
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
    # Begin with the PluginManager
    BEGIN_WITH_SCENEMANAGER = false
    # Key to active the menu
    KEY = :F8
    # Version of the Plugin
    VERSION = "3.0"
    # Temp file
    TEMP = "./temp.tmp"
    # Setup of the all message.
    MSG = {
      CONF: "Do you wish check/download new versions of the plugins?\nIf be the first time running, will happens a little delay, just wait...\nPress #{KEY} to access the menu.",
      DOWN_PLUGIN: "Do you wish download the plugin: <%s>\nFrom the author: %s\nVersion: %03s\nTotal size: %s\n",
      NEW_UPDATE: "A new update is available to download, of the plugin: %s\nFrom the author: %s\nVersion: %s\nTotal size: %s\n",
      NO_INTERNET: "No connection to Internet",
      FORMAT: MessageBox::ICONINFORMATION|MessageBox::YESNO,
      TITLE: "Plugin Manager #{VERSION}",
      PLMS: "Plugin Manager #{VERSION} [ installed: %02d ]",
      BACK: "Go back",
      CL: "%s: from: [%s] version: [%.2f] [%s]",
      DELETE: "Delete",
      RF: "Exit from the project to update the register.\nDo you wish make this now?",
      REQUIRE: "The plugin %s from the author %s.\nRequires the plugin %s from the author %s to work.",
      DPBD: "While the download works, it's necessary that you keep the project open and stay in him.",
      SURE: "Are you sure that you want to download this file? %s",
      ABOUT: "About",
      WEBSITE: "Go to website",
    }
    # Setup of the all tag
    RDIR = {
      files: "./Data/Plugins/",
      graphic: "./Graphics/",
      system: "./System/",
      audio: "./Audio/",
      movie: "./Movies/",
      data: "./Data/",
      project: "./"
    }
    # Register file
    PLUGIN_REGISTER_FILE = "#{Dir.pwd}/Data/Plugin.rvdata2"
    #--------------------------------------------------------------------------
    # • Variables
    #--------------------------------------------------------------------------
    @@register = {}
    @@download = {}
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
      @@register.each_value { |value|
        value[:path].each { |i|
          i.gsub!(/\/\/|\/\/\//, "/")
          puts "Running: %s" % i
          load_script(i) rescue next
        } rescue next
      }
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
      ["Website|website|Web|web|Site|site", :website]
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
  # • Window_PluginManager
  #============================================================================
  class Window_PluginManager < Window_Command
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize
      super(0, 8)
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
      add_command(Plugin::MSG[:BACK], :back)
      Plugin.data.each_pair { |key, value|
          next if value[:version] <= 0.0
          date = value[:date].chop
          title = value[:title].chop
          str = sprintf(Plugin::MSG[:CL], title, key[1], value.get(:version).round(3), date)
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
#~       self.opacity = 0
#~       self.back_opacity = 0
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
      add_command(Plugin::MSG[:ABOUT], :about)
      add_command(Plugin::MSG[:DELETE], :delete) 
      add_command(Plugin::MSG[:BACK], :back)
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
      @index = []
      @keep = [Font.default_name, Font.default_size, Font.default_bold, Font.default_outline]
      changeFont()
      @title = Sprite_Text.new(8, 8, Graphics.width - 8, 18, "", 0)
      create_window
      @cwindow = Window_PluginManagerConfirm.new
      @cwindow.set_handler(:about, method(:about))
      @cwindow.set_handler(:delete, method(:deletePlugin))
      @cwindow.set_handler(:back, method(:back))
      @cwindow.active = false
      @cwindow.visible = false
      Graphics.wait(30)
    end
    #--------------------------------------------------------------------------
    # • ChangeFont
    #--------------------------------------------------------------------------
    def changeFont(name="Gotham", size=16, bold=true, outline=false)
      Font.default_name = name
      Font.default_size = size
      Font.default_bold = bold
      Font.default_outline = outline
    end
    #--------------------------------------------------------------------------
    # • Criar window
    #--------------------------------------------------------------------------
    def create_window
      @window = Window_PluginManager.new
      @window.set_handler(:back, method(:backing))
      Plugin.data.each_pair { |key, value|
        next if value[:version] <= 0.0
        skey = ("#{key[0]}_#{key[1]}").symbol
        @window.set_handler(skey, method(:open))
        @index << key
      }
    end
    #--------------------------------------------------------------------------
    # • Back
    #--------------------------------------------------------------------------
    def backing
      changeFont(*@keep)
      if Plugin::BEGIN_WITH_SCENEMANAGER
        if SceneManager.stack.empty? or SceneManager.stack.first.is_a?(Scene_PluginManager)
          SceneManager.goto(SceneManager.first_scene_class)
        else
          return_scene
        end
      else
        return_scene
      end
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
    # • about
    #--------------------------------------------------------------------------
    def about
      current = @index[@window.index.pred]
      back unless Plugin.registred?(*current)
      msgbox(Plugin.registerInfo(*current)[:about])
      back
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
      } rescue nil
      Plugin.registerInfo(*current)[:_path].each { |file|
        puts "Deleting file... #{file}"
        File.delete(file) if FileTest.exist?(file)
        puts "File deleted!"
      } rescue nil
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
    # • terminate
    #--------------------------------------------------------------------------
    def terminate
      super
      [@title, @window].each(&:dispose)
    end
    #--------------------------------------------------------------------------
    # • update 
    #--------------------------------------------------------------------------
    def update
      super
      [@title].each(&:update)
      @title.text = Plugin::MSG[:PLMS] % Plugin.size
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
#~   Plugin.register(:ulse, :dax, 0.0, "http://pastebin.com/raw/eWxBengr")
#~   Plugin.register(:steampunk_hud, :dax, 0.0, "http://pastebin.com/raw/mGjQMB95")
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

#==============================================================================
# • Plugin
#==============================================================================
# Author: Dax
# Version: 2.7
# Site: www.dax-soft.weebly.com
# Requeriment: Dax Core
# tiagoms : Feedback that helped improve more on the project
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  This script will permit that you can add 'plugins' at your project and update
# them directly of your project.
#==============================================================================
# • How to use: 
#------------------------------------------------------------------------------
# • To add a Plugin at your project, you must register them. Look below how to 
# do and a example.
=begin
** To register a plugin is very easy.
Plugin.register(name, author, version, link, requires)
        You must to set the name of register of the plugin.
        name:             :name_of, # Like this.
        You must to set the author of the plugin.
        author:           "Me", # Like this.
        You must to set the version of the plugin. Set 0 to download, case you
        don't have any version.
        version:          0.0,
        You must to set the link of the plugin.
        link:             "url"
        You must define the requirements for the registration work. It's optional.
        Isn't necessary. Case you set the requirements, it's necessary that the 
        same be installed in your project to be installed.
        requires: [ [:name, "author"], ... ]
** Like:
  Plugin.register(:test, "dax", 0.0, "link")
  Plugin.register(:hello, "dax", 0.0, "link", [[:test, "dax"]])
        
Now, on the link which you set, it must contain the follow:       

<plugin>
  <version>version of the plugin.</version>
  <size>set the info of the size of all file.</size>
  <info>Set the information of the actual version.</info>
</plugin>


<tag HEADER>
  <output>default extension to end file</output>
  {
    NOME DO ARQUIVO <l> URL DO LINK <f> PASTA, OPICIONAL DEFINIR
    FILENAME <l> URL <f> Folder, it's optional.
  }
</tag>

types of the tag:
  files : All files posted here will run.
  graphic
  audio 
  movies 
  system
  project

types of the HEADER: Folder to:
  ROOTPATH : Data/Plugins/
  GRAPHICS : Graphics/
  AUDIO : Audio/
  MOVIE : Movies/
  SYSTEM : System/
  PROJECT : /
  Data/Plugins/
  
Example:

<!-- General setup -->
<plugin>
    <version>1.1</version>
    <info>Now this is the version 1.1</info>
</plugin>
 
<!-- Files -->
<files ROOTPATH>
    <output>rb</output>
    {
        Hello World <l> http://pastebin.com/raw/zXDtQV65
    }
</files>

Plugin.register(:hello_world, "dax", 0.0, http://pastebin.com/raw/N2kusL0N)
=end
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
#==============================================================================
Dax.register(:plugin, "dax", 2.7, [[:powershell, "dax"]]) {
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
    # Begin with the menu
    BEGIN_WITH_SCENEMANAGER = false
    KEY = :F8
    VERSION = "2.7"
    TEMP = "./temp.txt"
    MSG = {
      CONF: "Do you wish check/download new versions of the plugins?\nIf be the first time running, will happens a little delay, just wait...\nPress #{KEY} to access the menu.",
      DOWN_PLUGIN: "Do you wish download the plugin: <%s>\nFrom the author: %s\nVersion: %03s\nTotal size: %s\n",
      NEW_UPDATE: "A new update is available to download, of the plugin: %s\nFrom the author: %s\nVersion: %s\nTotal size: %s\n",
      NO_INTERNET: "No connection to Internet",
      FORMAT: MessageBox::ICONINFORMATION|MessageBox::YESNO,
      TITLE: "Plugin Manager #{VERSION}",
      PLMS: "Plugin Manager #{VERSION} < Plugins installed: %02d >",
      BACK: "Go back",
      CL: "<%s> from <%s> version <%.3f>",
      DELETE: "Delete",
      RF: "Exit from the project to update the register.\nDo you wish make this now?",
    }
    RKEY = [:files, :graphic, :system, :audio, :movie, :project]
    PLUGIN_REGISTER_FILE = "#{Dir.pwd}/Data/PluginRegister.rvdata2"
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
      check()
      ps("exit")
    end
    #--------------------------------------------------------------------------
    # • Load all plugin files
    #--------------------------------------------------------------------------
    def start()
      loadRegister() if FileTest.exist?(PLUGIN_REGISTER_FILE)
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
    def register(name, author, version, link, requires=[])
      need = []
      requires.each { |needed| need << needed unless registred?(*needed) }
      if need.empty?
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
      else
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
      loadRegister 
      # => register infos
      @@register.each_pair { |key, value|
        # => generator temp file
        @@download.delete([*key])
        #Network.link_download(value.get(:link), TEMP)
        Powershell.wget(value.get(:link), TEMP)
        tempFile = File.open(TEMP, "rb") 
        @@download[[*key]] = Plugin::Parse.start(tempFile.read)
        _size = @@download[[*key]][:size]
        version = @@download[[*key]][:version]
        information = @@download[[*key]][:info] 
        puts "#{value[:name]}::\r\n\t temp version -> #{version}\r\n\t register version -> #{value[:version]}\r\n"
        MessageBox.call("#{value[:name]} #{version}", information, 0)
        # => check version
        if value[:version] == 0.0
          msg = sprintf(MSG[:DOWN_PLUGIN], value.get(:name), value.get(:author), version, _size)
          hresult = MessageBox.call(MSG[:TITLE], msg, MSG[:FORMAT])
        elsif version > value.get(:version)
          @@register[[*key]][:path] = []
          msg = sprintf(MSG[:NEW_UPDATE], value.get(:name), value.get(:author), version, _size)
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
      @@hash[:version] = content.scan(REG["version"]).shift.shift.to_f rescue 0.0
      @@hash[:info] = content.scan(REG["info"]).shift.shift.to_s rescue ""
      @@hash[:size] = content.scan(REG["size"]).shift.shift.to_s rescue "--"
      @@hash[:thumb] = content.scan(REG["thumb"]).shift.shift.to_s rescue ""
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
      @cwindow.active = false
      @cwindow.visible = false
      Graphics.wait(60)
    end
    #--------------------------------------------------------------------------
    # • Criar window
    #--------------------------------------------------------------------------
    def create_window
      oldSize = Font.default_size
      Font.default_size = 18
      @window = Window_PluginManager.new
      @window.set_handler(:back, method(:backing))
      Plugin.data.each_pair { |key, value|
        next if value[:version] <= 0.0
        skey = ("#{key[0]}_#{key[1]}").symbol
        @window.set_handler(skey, method(:open))
        @index << key
      }
      Font.default_size = oldSize
    end
    #--------------------------------------------------------------------------
    # • Back
    #--------------------------------------------------------------------------
    def backing
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
  
  
  #============================================================================
  # • Run
  #============================================================================
  hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:CONF], Plugin::MSG[:FORMAT])
  Plugin.run() if hresult == API::MessageBox::YES
  Plugin.start()
}

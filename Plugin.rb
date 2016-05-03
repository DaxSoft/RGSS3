#==============================================================================
# • Plugin
#==============================================================================
# Autor: Dax
# Versão: 2.2
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
** Para registrar é muito simples. Você chama o método register do Plugin,
e defini nele, dentro de uma hash {} as informações.
Plugin.register({
        Você deve de definir o nome de registro do plugin.
        name:             :nome_de_registro, # Deste modo.
        Você deve de definir o autor do plugin.
        author:           "Autor", # Desta maneira.
        Você deve de definir a versão do plugin. Para fazer baixar, caso não tenha o
        mesmo, basta por a versão 0.0.
        version:          1.0,
        Você deve de definir o link do plugin, onde o mesmo será baixado.
        link:             "url do link"
})
** Agora, no LINK em que você definir, deve conter o seguinte:

<plugin>
  <version>VERSÃO DO PLUGIN</version>
  <register>REGISTRAR OS ARQUIVOS QUE SERÃO BAIXADO</register>
  <info>Informações da versão atual.</info>
</plugin>

<NOME DO REGISTRO DO ARQUIVO PASTA[POR PADRÃO É ROOTPATH]>
  <folder>PASTA DENTRO DA PASTA PADRÃO, NÃO PRECISA DEFINIR, CASO NÃO TIVER</folder>
  <link>URL DO ARQUIVO</link>
  <output>TIPO DO ARQUIVO</output>
  <filename>
    NOME DO ARQUIVO, SE DEFINIR O TIPO DO ARQUIVO AQUI, 
    NÃO PRECISA DEFINIR <output>; CASO NÃO DEFINIR <filename>, O NOME DO ARQUIVO
    SERÁ O NOME DO REGISTRO, MAS AÍ É PRECISO DEFINIR O <output>
  </filename>
</NOME DO REGISTRO DO ARQUIVO>

• Veja um exemplo.
<!-- General setup -->
<plugin>
	<version>1.0</version>
	<register>hello_word</register>
</plugin>

<!-- Plugin Download : Hello World -->
<hello_word ROOTPATH>
  <link>http://pastebin.com/raw/zXDtQV65</link>
  <filename>Hello World.rb</filename>
  <folder><folder>
</hello_word>
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
#==============================================================================
Dax.register(:plugin, "dax", 2.2, [[:powershell, "dax"]]) {
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
    VERSION = "2.2"
    TEMP = "./temp.txt"
    ERROR = true # mostrar erros.
    MSG = {
      CONF: "Deseja verificar novas versões dos plugins?",
      INFO: "Informações da versão atual:",
      DOWN_PLUGIN: "Você deseja baixar o plugin: <%s>, do autor: <%s>, versão: <%03s>",
      NEW_UPDATE: "Uma nova atualização está disponível, do plugin: <%s>, do autor: <%s>, versão: <%03s>\n Você deseja baixá-la?",
      NO_INTERNET: "Sem conexão com à internet",
      FORMAT: MessageBox::ICONINFORMATION|MessageBox::YESNO,
      TITLE: "Plugin Manager #{VERSION}",
      clear: "Para o sistema de verificação de novas versão funcionar, você deve limpar o cache do seu navegador. Quer fazer isso agora? (Automático)"
    }
    #--------------------------------------------------------------------------
    # • Variables
    #--------------------------------------------------------------------------
    @@register = {}
    @@download = {}
    @@root_path = {}
    @@checkExist = false
    #--------------------------------------------------------------------------
    # • Run plugin
    #--------------------------------------------------------------------------
    def run()
      check()
    end
    #--------------------------------------------------------------------------
    # • Load all plugin files
    #--------------------------------------------------------------------------
    def start()
      loadRegister() if FileTest.exist?("#{Dir.pwd}/Data/register.rvdata2")
      @@root_path.each_value { |value|
        if value.is_a?(String)
          load_script(value.strip) rescue next
        elsif value.is_a?(Array)
          value.each { |path| load_script(path) rescue next } rescue next
        end
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
        @@download[[*key]] = Plugin::Parse.read(tempFile.read)
        version = @@download[[*key]][:version]
        puts "#{value[:name]}::\r\n\t temp version -> #{version}\r\n\t register version -> #{value[:version]}\r\n"
        puts("#{MSG[:INFO]}\n\r#{value.get(:info)}")
        # => check version
        if value[:version] == 0.0
          msg = sprintf(MSG[:DOWN_PLUGIN], value.get(:name), value.get(:author), version)
          hresult = MessageBox.call(MSG[:TITLE], msg, MSG[:FORMAT])
        elsif version > value.get(:version)
          @@root_path[[*key]].clear
          @@root_path.delete([*key])
          msg = sprintf(MSG[:NEW_UPDATE], value.get(:name), value.get(:author), version)
          hresult = MessageBox.call(MSG[:TITLE], msg, MSG[:FORMAT])
        end
        # => download
        if hresult == MessageBox::YES
          catch(:loop) {
            @@download[[*key]][:register].each { |kregister|
              download(@@download[[*key]][kregister], key)
              @@register[[*key]][:version] = version
            }
            throw(:loop)
          }
        end
        # => register new version and save
        tempFile.close
        File.delete(TEMP) if FileTest.exist?(TEMP)
        saveRegister()
        Graphics.wait(30)
      }
    end
    #--------------------------------------------------------------------------
    # • headerFilter
    #--------------------------------------------------------------------------
    def headerFilter(header)
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
    end
    #--------------------------------------------------------------------------
    # • Download
    #--------------------------------------------------------------------------
    def download(kd, key)
      filename = kd[:filename]
      header = kd[:header]
      folder = kd[:folder]
      link = kd[:link]
      path = headerFilter(header)
      path << folder
      path << "/" unless path[path.size.pred] == "/"
      Dir.mkdir(path) unless FileTest.directory?(path)
      unless @@root_path[[*key]].is_a?(Array)
        @@root_path[[*key]] << path + filename rescue @@root_path[[*key]] = path + filename
      else
        @@root_path[[*key]] = path + filename
      end
      nfilename = filename.gsub(" ", "_")
      Powershell.wget(link, "./" + nfilename, "-v") 
      Graphics.wait(30)
      File.rename("./" + nfilename, path + filename) rescue nil
    end
    #--------------------------------------------------------------------------
    # • saveRegister
    #--------------------------------------------------------------------------
    def saveRegister()
      File.open("#{Dir.pwd}/Data/register.rvdata2", "wb") { |file|
        export = ->() {
          content = {}
          content[:register] = @@register
          content[:root_path] = @@root_path
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
    #--------------------------------------------------------------------------
    # • read
    # => output is as Hash.
    #--------------------------------------------------------------------------
    def read(str, gA=true)
      @@hash = {}
      general(str)
      getAll(str) if gA
      @@hash
    end
    #--------------------------------------------------------------------------
    # • Checks the general setup
    #--------------------------------------------------------------------------
    def general(str)
      str.match(/<plugin>(.*?)<\/plugin>/im)
      content = $1
      @@hash[:version] = content.scan(REG["version"]).shift.shift.to_f rescue ""
      @@hash[:register] = content.scan(REG["register"]).shift.shift.to_s.split(/,/).collect! { |r|  r.to_s.lstrip.symbol } rescue ""
      @@hash[:info] = content.scan(REG["info"]).shift.shift.to_s rescue ""
    end
    #--------------------------------------------------------------------------
    # • Checks all regexs
    #--------------------------------------------------------------------------
    def getAll(str)
      @@hash[:register].each { |key|
        next unless key.is_a?(Symbol)
        @@hash[key] = {}
        hash = {}
        str.match(/<#{key}(.*?)>(.*?)<\/#{key}>/im)
        header = $1.to_s
        content = $2
        hash[:header] = header.lstrip
        hash[:output] = content.scan(REG["output"]).shift.shift.to_s rescue ""
        hash[:filename] = content.scan(REG["filename"]).shift.shift.to_s rescue "#{key}"
        hash[:filename] = hash[:filename].include?(".") ? hash[:filename] : "#{hash[:filename]}.#{hash[:output]}" rescue "#{key}.#{hash[:output]}"
        hash[:folder] = content.scan(REG["folder"]).shift.shift.to_s rescue ""
        hash[:link] = content.scan(REG["link"]).shift.shift.to_s rescue ""
        @@hash[key].merge!(hash)
      }
    end
  end
  #============================================================================
  # • Insira aqui: Os registros dos plugin.
  #============================================================================
  Plugin.register(:hello_world, :dax, 0.0, "http://pastebin.com/raw/N2kusL0N")
  
  #============================================================================
  # • Run
  #============================================================================
  hresult = API::MessageBox.call(Plugin::MSG[:TITLE], Plugin::MSG[:CONF], Plugin::MSG[:FORMAT])
  Plugin.run() if hresult == API::MessageBox::YES
  Plugin.start()
}

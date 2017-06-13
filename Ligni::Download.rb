#==============================================================================
# • Ligni Download by cmd
#==============================================================================
# Author: Dax
# Version: 1.0
# Site: www.dax-soft.weebly.com
# Requeriments: Ligni Core | ldufcmd.exe (download at my website, just there)
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  Allow you download files from web, direct by your rpg maker project.
#==============================================================================
# • How to Use:
#------------------------------------------------------------------------------
#~ data = Ligni::Download.new({
#~   url: "set up the url link here",
#~   type: "-file to download files; -text to download string content",
#~   filename: "personal filename, for default is -f, original filename",
#~   ext: "personal extension, for default is -e, original extension",
#~   path: "personal directory path, for default is -path, original position of the app"
#~ }) 
#~ * to rename the file
#~ data.rename({
#~   name: "new name",
#~   path: "new directory path", optional
#~   ext: "new extension", optional
#~ })
#~ * to delete
#~ data.delete
#~ * to save on registr file
#~ data.save
#~ * to load the register file
#~ data.load // Ligni::Download.load
#~ * to open the file
#~ data.open
#~ * to run the file, if it is possible
#~ data.run
#~ * get information 
#~ data.get
#    data.get.absolutePath => [string] all path and the filename
#    data.get.extension => [string] extension of the file
#    data.get.filename => [string] filename with extension
#    data.get.path => [string] path without filename
#==============================================================================
# • Example: 
#------------------------------------------------------------------------------
#~ Ligni::Download.new({
#~   url: "https://raw.githubusercontent.com/DaxSoft/RGSS3/master/ULSE_EN.rb",
#~   type: "-text"
#~ }, true) { |data|
#~   data.rename({
#~     name: "ulse en"
#~   })
#~ } 
#==============================================================================
Ligni.register(:lducmd, "dax", 1.0) {
#==============================================================================
# • Ligni::DownloadURL
#==============================================================================
class Ligni::Download
  #----------------------------------------------------------------------------
  # • Variable of instance
  #----------------------------------------------------------------------------
  attr_accessor   :data
  #----------------------------------------------------------------------------
  # • initialize :
  #     hash : {:url, :filename, :ext, :path, :type}
  #       :url => [string] url link from web
  #       :filename => [string] for default is '-f', that is mean your original
  # name. 
  #       :ext => [string] for default is '-e', that is mean your original 
  # type file.
  #       :path => [string] for default is '-p' that is mean the same directory
  # position where the app is.
  #       :type => [string] for default is '-file'.
  #                -file : download files from web, like pictures, exectuable.
  #                -text : download string contain on url from web.
  #     yield : return to self instance of class
  #     message : show a message saying that the download is complete. For
  # default is false.
  #----------------------------------------------------------------------------
  def initialize(hash={}, message=false)
    raise("Don't found ldufcmd.exe") unless FileTest.exist?("./ldufcmd.exe")
    @downloaded = false
    @data = {}
    @data[:get] = Struct.new(:Get, :absolutePath, :path, :filename, :extension)
    @data[:get] = @data[:get].new("", "", "", "")
    hash[:filename] = "-f" unless hash.has_key?(:filename)
    hash[:ext] = "-e" unless hash.has_key?(:ext)
    hash[:path] = "-p" unless hash.has_key?(:path)
    hash[:type] = "-file" unless hash.has_key?(:type)
    @data[:main] = hash
    @path = ->(file) {
      x = File.absolute_path(file).split("/")
      ext = File.extname(x.last)
      x.delete_at(x.size.pred)
      str = ""
      x.each { |i| str += i + "/" }
      return [str, ext]
    }
    @message = message
    startDownload()
    yield(self) if block_given?
  end
  #----------------------------------------------------------------------------
  # • startDownload()
  #----------------------------------------------------------------------------
  def startDownload()
    # case senstive on filename 
    @data[:main][:filename].gsub!(" ", "_") unless @data[:filename] == "-f"
    # download system call out
    system(sprintf("start ./ldufcmd.exe %s %s %s %s %s", @data[:main][:type],
      @data[:main][:url], @data[:main][:path],
      @data[:main][:filename], @data[:main][:ext] 
    ))
    # forcedDownload
    forcedDownload()
    # message
    msgbox("Download complete!") if @message
    # downloaded
    @downloaded = true
  end
  #----------------------------------------------------------------------------
  # • rename(hash)
  #      hash { :name, :ext, :path }
  #        :name => [string] new filename
  #        :ext => [string] for default is the standard file extension
  #        :path => [string] for default is the standard directory path
  #----------------------------------------------------------------------------
  def rename(hash)
    return false unless @downloaded
    hash[:ext] = get.extension unless hash.has_key?(:ext)
    hash[:path] = get.path unless hash.has_key?(:path)
    unless hash.has_key?(:name)
      puts "name don't defined"
      return false
    end
    oldName = get.absolutePath
    name = File.basename(hash[:name], get.extension)
    name = hash[:path] + (name + hash[:ext])
    File.rename(oldName, name)
    get.absolutePath = File.absolute_path(name)
    get.path = @path[name][0]
    get.extension = hash[:ext]
    get.filename = File.basename(get.absolutePath, get.extension)
    return true
  end
  #----------------------------------------------------------------------------
  # • open() : open file after download 
  #----------------------------------------------------------------------------
  def open()
    return false unless @downloaded
    `start #{get.absolutePath}` rescue return false
    return true
  end
  #----------------------------------------------------------------------------
  # • forcedDownload()
  #----------------------------------------------------------------------------
  def forcedDownload()
    loop {
      # downloading?
      status = `tasklist | find "ldufcmd.exe"`
      # end download?
      if status.empty?
        # getRecent
        getRecent
        # break 
        break
      end
    }
    return true
  end
  #----------------------------------------------------------------------------
  # • get
  #----------------------------------------------------------------------------
  def get
    @data[:get]
  end
  #----------------------------------------------------------------------------
  # • getSetup(filename)
  #----------------------------------------------------------------------------
  def getRecent()
    # get the recent file 
    recent = File.recent()
    # absolutePath
    get.absolutePath = File.absolute_path(recent)
    # extension
    get.extension = @path[recent][1]
    # filename
    get.filename = File.basename(recent, get.extension)
    # path
    get.path = @path[recent][0]
    # return
    return true
  end
  #----------------------------------------------------------------------------
  # • delete the file
  #----------------------------------------------------------------------------
  def delete()
    return false unless @downloaded
    File.delete(get.absolutePath) rescue return false
    return true
  end
  #----------------------------------------------------------------------------
  # • run the file, if it is possible
  #----------------------------------------------------------------------------
  def run()
    return false unless @downloaded
    load(get.absolutePath) rescue return false
    return true
  end
  #----------------------------------------------------------------------------
  # • register's file : register all download on file rvdata2
  #----------------------------------------------------------------------------
  def save()
    file = File.open("./lducmd_register.rvdata2", "wb")
    export = ->() {
      ((content ||= {})[:data] = {})
      content[:data][self.__id__] = @data
      content
    }
    Marshal.dump(export.call, file)
    file.close
    return true
  end
  #----------------------------------------------------------------------------
  # • register's file : load all registered file | retorn to hash
  #----------------------------------------------------------------------------
  def self.load()
    return {} unless FileTest.exist?("./lducmd_register.rvdata2")
    file = File.open("./lducmd_register.rvdata2", "rb")
    import = ->(content) {
      return content[:data]
    }
    hash = import[Marshal.load(file)] rescue {}
    file.close
    return hash
  end
  #----------------------------------------------------------------------------
  # • Private methods
  #----------------------------------------------------------------------------
  private :startDownload, :forcedDownload
end
}

#==============================================================================
# • Ligni Crypto by cmd
#==============================================================================
# Author: Dax
# Version: 1.0
# Site: www.dax-soft.weebly.com
# Requeriments: Ligni Core | cmd_encryptDec_file.exe (download at my website, just there)
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  Allow you encrypt and decrypt files on rpg maker 
#==============================================================================
# • How to Use:
#------------------------------------------------------------------------------
#~ * start
#~ data = Ligni::Crypto.new({
#~   file: put the filepath here (and the filename, of course)
#~   hidden: to decrypt was hide file or show it. For default is empty:
#~           "-hidden" or "-show"
#~   message: display a message box, alert that was encrypted/decrypted
#~   key: your personal key to open/close the file. Default key is "admin"
#~ }, delete)
#~  - delete : to delete the older file. Default is false
#~ * to delete the file
#~ data.delete
#~ * to run the file, if was possibilty
#~ data.run
#==============================================================================
# • Example: 
#------------------------------------------------------------------------------
#~ Ligni::Crypto.new({
#~   file: "./file.txt",
#~   message: true
#~ }, true)
#==============================================================================
Ligni.register(:ligni_crypto, "dax", 1.0) {
#==============================================================================
# • Ligni::Crypto
#==============================================================================
class Ligni::Crypto
  #----------------------------------------------------------------------------
  # • Variable of instance
  #----------------------------------------------------------------------------
  attr_accessor   :data
  #----------------------------------------------------------------------------
  # • init 
  #     :type : [string] for default is "-encrypt"
  #            "-encrypt" : encrypt the file
  #            "-decrypt" : decrypt the file
  #     :key  : [string] for default is "admin". Your password to crypt
  #     :file : [string] the path and filename that will be crypted
  #     :hidden : [string] hidden the file or show he. For default is empty
  #             "-hidden" & "-show"
  #     :message : for default is false. Alert the end of encrypt/decrypt
  #   del : [boolean] delete the older file. For default is false.
  #----------------------------------------------------------------------------
  def initialize(hash={}, del=false)
    raise("Don't found cmd_encryptDec_file.exe") unless FileTest.exist?("./cmd_encryptDec_file.exe")
    @crypted = false
    @del = del
    @data = {}
    @data[:get] = Struct.new(:CryptoGet, :absolutePath, :path, :filename, :extension)
    @data[:get] = @data[:get].new("", "", "", "")
    hash[:key] = "admin" unless hash.has_key?(:key)
    hash[:type] = "-encrypt" unless hash.has_key?(:type)
    hash[:hidden] = "" unless hash.has_key?(:hidden)
    unless hash.has_key?(:file)
      raise("file don't defined")
    else
      hash[:file] = hash[:file].gsub(" ", "_")
    end
    @data[:main] = hash
    puts @data[:main]
    @path = ->(file) {
      x = File.absolute_path(file).split("/")
      ext = File.extname(x.last)
      x.delete_at(x.size.pred)
      str = ""
      x.each { |i| str += i + "/" }
      return [str, ext]
    }
    startCrypto()
    yield(self) if block_given?
  end
  #----------------------------------------------------------------------------
  # • startCrypto
  #----------------------------------------------------------------------------
  def startCrypto()
    # get the spec
    _getSpecSystem = sprintf("start cmd_encryptDec_file.exe %s %s %s %s",
                            @data[:main][:type], @data[:main][:key], 
                            @data[:main][:file], @data[:main][:hidden])
    # call
    `#{_getSpecSystem}`
    # forced waiting
    forcedWaiting
    # completed
    @crypted = true
    puts "<#{@data[:main][:file]}> File was #{@data[:main][:type]}"
    deleteOlder() if @del
    msgbox("<@#{@data[:main][:file]}> File was #{@data[:main][:type]}") if @data[:main][:message]
  end
  #----------------------------------------------------------------------------
  # • forcedDownload()
  #----------------------------------------------------------------------------
  def forcedWaiting()
    loop {
      # downloading?
      status = `tasklist | find "cmd_encryptDec_file.exe"`
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
  # • deleteOlder()
  #----------------------------------------------------------------------------
  def deleteOlder()
    return false unless @crypted 
    if @data[:main][:type] == "-encrypt"
      File.delete(File.absolute_path(get.filename)) rescue return false
    elsif @data[:main][:type] == "-decrypt"
      File.delete(File.absolute_path(get.filename + get.extension + ".bak")) rescue return false
    end
    puts "<#{get.filename}> the older file was deleted <Crypto>"
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
    return false unless @crypted
    File.delete(get.absolutePath) rescue return false
    return true
  end
  #----------------------------------------------------------------------------
  # • run the file, if it is possible
  #----------------------------------------------------------------------------
  def run()
    return false unless @crypted
    load(get.absolutePath) rescue return false
    return true
  end
  #----------------------------------------------------------------------------
  # • private methods
  #----------------------------------------------------------------------------
  private :startCrypto, :forcedWaiting, :deleteOlder
end
}

#==============================================================================
# • Event Bar
#==============================================================================
# Author: Dax
# Version: 3.6
# Site: www.dax-soft.weebly.com
# Requeriments: Ligni Core
#==============================================================================
# • Description:
#------------------------------------------------------------------------------
#   Allow to make/create bars who stay in the head of the events..
# Helpful to make bars of life..To system of battle.
#==============================================================================
# • Como usar: NO COMANDO CHAMAR SCRIPT
#------------------------------------------------------------------------------
# ebar(eID, vID, m, vm, x, y, w, h, color2, color)
#------------------------------------------------------------------------------
# ► Requered.
#   eID : ID of the event of the map. If case nil's the id of the local event.
#   vID : ID of the variable who will show the value actual of the bar.
#   m : Value max of the bar.
#------------------------------------------------------------------------------
# ► Optional.
#   vm : Want control the max value of the bar through of a variable? So,
# set the ID of the variable. Case no, set nil.
#   x : Position X add. Case no, set nil.
#   y : Position Y add. Case no, set nil.
#   w : Modify the width of the size of the HUD.. Case no, set nil.
# The default value is defined.
#   h : Modify the height of the size of the HUD.. Case no, set nil.
# The default value is defined.
#   i : Modify the first color of the bar. Case no, set nil.
#   j : Modify the second color of the bar. Case no, set nil.
#------------------------------------------------------------------------------
# ► Tip:
# Set nil(nothing), is equal the put: nil
#------------------------------------------------------------------------------
# Example:
#       ebar(1,1,100,nil,0,0,25,5,"f2e341".color, "fdef57".color)
#       ebar(1,2,100,nil,0,-5,32)
#==============================================================================
Ligni.register(:event_bar, "dax", 3.6) {
#==============================================================================
# • Módulo de configuração.
#==============================================================================
module EventBar
  extend self
  #----------------------------------------------------------------------------
  # • Configuração.
  #----------------------------------------------------------------------------
  Z = 199 # ► Propriedade no mapa.
  COLOR_DEFAULT_BAR2 = "920120".color # ► Cor padrão da barra 2.
  COLOR_DEFAULT_BAR = "d3002d".color # ► Cor padrão da barra.
  COLOR_BACKGROUND = "000000".color # ► Cor do fundo.
  WIDTH = 24 # ► Largura padrão da barra.
  HEIGHT = 5 # ► Altura padrão da barra.
  @data = []
  #----------------------------------------------------------------------------
  # • Criar uma barra.
  #----------------------------------------------------------------------------
  def do(*args)
    @data << Sprite_Event_Bar.new(*args)
  end
  #----------------------------------------------------------------------------
  # • Esconder.
  #----------------------------------------------------------------------------
  def hide
    @data.each { |each| each.opacity = 0 unless each.nil? }
  end
  #----------------------------------------------------------------------------
  # • Dispose
  #----------------------------------------------------------------------------
  def dispose
    return if @data.nil?
    @data.each_with_index { |bar, index|
        unless bar.nil?
          bar.dispose
          @data.delete_at(index)
        end
    }
  end
  #----------------------------------------------------------------------------
  # • Atualizar.
  #----------------------------------------------------------------------------
  def update
    return if @data.nil?
    @data.each_with_index { |bar, index|
      unless bar.nil?
        bar.update
        bar.opacity = 255 if bar.opacity == 0
        unless bar.visible
          bar.dispose
          @data.delete_at(index)
        end
      end
    }
  end
end
#==============================================================================
# • Sprite_Event_Bar
#==============================================================================
class Sprite_Event_Bar < Sprite
  include EventBar
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize(eID, vID, m, vm=nil, x=nil, y=nil, w=nil, h=nil, color2=nil, color=nil)
    @x, @y = x || 0, y || 0
    @eID = eID
    @m, @vm, @vID = m, vm || 0, vID
    super([w || WIDTH, h || HEIGHT])
    self.x = $game_map.events[@eID].screen_x - (self.width / 2) + @x
    self.y = $game_map.events[@eID].screen_y - (33+self.height) + @y
    self.z = Z
    @color2, @color = color2 || COLOR_DEFAULT_BAR2, color || COLOR_DEFAULT_BAR
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
    return if self.bitmap.nil?
    self.x = $game_map.events[@eID].screen_x - (self.width / 2) + @x
    self.y = $game_map.events[@eID].screen_y - (33+self.height) + @y
    self.bitmap.clear
    @actual = $game_variables[@vID] = $game_variables[@vID] == 0 ? 1 : $game_variables[@vID]
    @max = @vm.nil? ? @m : $game_variables[@vm] == 0 ? ($game_variables[@vm] = @m) : $game_variables[@vm]
    self.bitmap.fill_rect(self.rect, COLOR_BACKGROUND)
    self.bitmap.gradient_bar([@color, @color2], @actual, @max, 1)
    self.visible = false if @actual <= 1
  end
end
#==============================================================================
# • Spriteset_Map
#==============================================================================
class Spriteset_Map
  alias :event_bar_dispose :dispose
  def dispose
    EventBar.hide
    event_bar_dispose
  end
  alias :event_bar_update :update
  def update
    event_bar_update
    EventBar.update
  end
end
#==============================================================================
# • Game_Player
#==============================================================================
class Game_Player < Game_Character
  alias :eb_perform_transfer :perform_transfer
  def perform_transfer
    eb_perform_transfer
    EventBar.dispose
  end
end
#==============================================================================
# • Interpretador;
#==============================================================================
class Game_Interpreter
  #----------------------------------------------------------------------------
  # • Barra no evento.
  #----------------------------------------------------------------------------
  def ebar(*args)
    EventBar.do(*args)
  end
end

}

#==============================================================================
# • Steampunk Hud
#==============================================================================
# Autor: Dax
# Versão: 2.5
# Site: www.dax-soft.weebly.com
# Requerimento: Dax Core
#==============================================================================
# • Descrição: TODAS AS IMAGENS NA PASTA 'SYSTEM'
#   Description: All the pictures in the paste 'System'
#------------------------------------------------------------------------------
#  Sistema de HUD com Design Steampunk, onde mostra o HP mais o MP. 
#  System of HUD with design Steampunk, where show the hp and the mp.
# **** Para ativar desativar HUD ****
# **** To active/desactive HUD ***
# Aperte a tecla do teclado 'D' — pode se mudar na linha 47
# Press the key of keyboard 'D' - you can change in the line 47.
# Use o comando (No chamar script) : 
# Use the command (In the call script) : 
#  $game_system.steam_hud = true # Ativa a HUD | Active the HUD.
#  $game_system.steam_hud = false # Desativa a HUD | Desactive the HUD.
#==============================================================================
Dax.register(:steampunk_hud, "dax", 2.5) {
#==============================================================================
# • Game_System
#==============================================================================
class Game_System
  attr_accessor :steam_hud
  alias :steam_hud_initialize :initialize
  def initialize
    steam_hud_initialize
    @steam_hud = true
  end
end
#==============================================================================
# • Steampunk_HUD
#==============================================================================
module Steampunk_HUD
  module_function
  #----------------------------------------------------------------------------
  # • Configuração da HUD. Settings of HUD.
  #----------------------------------------------------------------------------
  def steampunk_hud
    return {
      # First layout of HUD.
      layout0: "S: Layout 0 - Back HUD",  # Primeiro layout da HUD.
      # Second layout of HUD.
      layout1: "S: Layout 1 - Icon HUD",  # Segundo layout da HUD.
      # Layout of effect of the HUD.
      layout_effect: "S: Efeito HUD",    # Layout de efeito da HUD.
      # Bar of the HP of the HUD.
      hp_meter: "Hp Meter HUD",       # Barra de HP da HUD.
      # Bar of the MP of the HUD.
      mp_meter: "Mp Meter HUD",       # Barra de MP da HUD.
      # What the kind of 'lend' to the effect?
      blend_type: 1,                    # Qual o tipo de 'blend' para o efeito?
      # Speed in the what the HUD will hide/active.
      speed: 4,                       # Velocidade na qual a HUD irá esconder/ativar
      # The HUD is destined to what Character?
      actor_id: 1,                    # A HUD é destinada a qual Actor?
      # Key to hide/show HUD.
      key: :D                     # Chave para esconder/ativar HUD.
    }
  end
end
#==============================================================================
# • Sprite_Steampunk_Hud
#==============================================================================
class Sprite_Steampunk_Hud
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize
    @addon_x = 0
    @addon_y = 0
    @actor = $game_actors[Steampunk_HUD.steampunk_hud[:actor_id]]
    @layout0 = Sprite.new(Steampunk_HUD.steampunk_hud[:layout0])
    @layout0.z = 200
    @layout0.x = 30 + @addon_x
    @layout0.y = 16 + @addon_y
    @layout1 = Sprite.new(Steampunk_HUD.steampunk_hud[:layout1])
    @layout1.z = 203
    @layout1.x = 19 + @addon_x
    @layout1.y = 10 + @addon_y
    @hp = Cache.system(Steampunk_HUD.steampunk_hud[:hp_meter])
    @mp = Cache.system(Steampunk_HUD.steampunk_hud[:mp_meter])
    @shp = Sprite.new([@hp.width, @hp.height])
    @shp.bitmap.blt(0,0,@hp,Rect.new(0,0,@hp.width.to_p(@actor.hp, @actor.mhp),@hp.height))
    @shp.z = 200
    @shp.x = 42 + @addon_x
    @shp.y = 22 + @addon_y
    @smp = Sprite.new([@mp.width, @mp.height])
    @smp.bitmap.blt(0,0,@mp,Rect.new(0,0,@mp.width.to_p(@actor.mp, @actor.mmp),@mp.height))
    @smp.z = 200
    @smp.x = 44 + @addon_x
    @smp.y = 43 + @addon_y
    @efeito = Sprite.new(Steampunk_HUD.steampunk_hud[:layout_effect])
    @efeito.opacity = 128
    @efeito.z = 202
    @efeito.blend_type = Steampunk_HUD.steampunk_hud[:blend_type]
    @efeito.x = 42 + @addon_x
    @efeito.y = 22 + @addon_y
  end
  #----------------------------------------------------------------------------
  # • Renovação dos objetos.
  #----------------------------------------------------------------------------
  def dispose
    @layout0.dispose
    @layout1.dispose
    @shp.dispose
    @smp.dispose
    @efeito.dispose
  end
  #----------------------------------------------------------------------------
  # • Atualização dos objetos.
  #----------------------------------------------------------------------------
  def update
    @shp.bitmap.clear
    @smp.bitmap.clear
    @shp.bitmap.blt(0,0,@hp,Rect.new(0,0,@hp.width.to_p(@actor.hp, @actor.mhp),@hp.height))
    @smp.bitmap.blt(0,0,@mp,Rect.new(0,0,@mp.width.to_p(@actor.mp, @actor.mmp),@mp.height))
    trigger?(Steampunk_HUD.steampunk_hud[:key]) { $game_system.steam_hud = !$game_system.steam_hud }
    if $game_system.steam_hud
      Opacity.sprite_opacity(@efeito, 2, 122, 62, :efeito_steampunk_hud)
      [@layout0, @layout1, @shp, @smp].each do |variables|0
        Opacity.sprite_opacity_out(variables, Steampunk_HUD.steampunk_hud[:speed], 255) 
      end
    else
      [@layout0, @layout1, @shp, @smp, @efeito].each do |variables|
        Opacity.sprite_opacity_in(variables, Steampunk_HUD.steampunk_hud[:speed], 0) 
      end
    end
  end
end
#==============================================================================
# • Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  alias :steampunk_hud_main :main
  def main
    @steampunk_hud = Sprite_Steampunk_Hud.new
    steampunk_hud_main
    @steampunk_hud.dispose
  end
  alias :steampunk_hud_update :update
  def update
    steampunk_hud_update
    @steampunk_hud.update
  end
end

}
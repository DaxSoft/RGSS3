#==============================================================================
# • Ultimate Sensor Event [EN]
#==============================================================================
# Author: Dax
# Requeris: Ligni Core
# Version: 5.2
# Site: www.dax-soft.weebly.com
#==============================================================================
# @tiagoms : Feedback that helped improve more on the project
#==============================================================================
# • Desc:
#------------------------------------------------------------------------------
#  System of the sensor event.
#==============================================================================
# • How to use: Use the commands with Call Scripts.
#------------------------------------------------------------------------------
#  a : area in squares(tiles) in which the sensor will be activated. Default is 1
#  b : ID of the event. If you set nothing, is the local event. Default is nothing.
#  c : (Optional) set what switch that will be used.
#------------------------------------------------------------------------------
# • [1.0]
# 1 * Sensor by area. sarea?(a, b, c) 
# 2 * Checks if is below of the event. sfront?(a, b, c)
# 3 * Checks if is on the top of the event. sago?(a, b, c)
# 4 * Checks if is on the left of the event. sleft?(a, b, c)
# 5 * Checks if is one the right of the event. sright?(a, b, c)
# 6 * Verification in the form of the cross. scross?(a, b, c)
# 7 * Just on the vision of the event. svision?(a, b, c)
# 8 * Checks if is above of the event. sabout?(b, c)
# • [2.5]
# 9 * Checks if is behind of the event. Just by behind: sbehind?(a, b, c)
# 10 * Checks if is on the left of the event. Just on the left: vleft?(a, b, c)
# 11 * Checks if is on the right of the event. Just on the right. vright?(a, b, c)
# • [3.0]
# 12 * Checks if is on the top-left on the diagonal. dsleft?(a, b, c)
# 13 * Checks if is on the lower-left on the diagonal.dileft?(a, b, c)
# 14 * Checks if is on the top-right on the diagonal. dsright?(a, b, c)
# 15 * Checks if is on the lower-right on the diagonal. diright?(a, b, c)
# 16 * Checks if is in all sides on the diagonal. diagonal?(a, b, c)
# 17 * Verification in the form of the circle. scircle?(a, b, c)
# 18 * Notes diagonally according to the vision of the event. vdiagonal?(a, b, c)
# • [3.5] 
# 19 * Verification in the form of rectangle on the vision of the event. scubic?(a, b, c)
# • [4.0]
# Update to the new version of the Core.
# • [5.1]
# Option to set which switch will be activated...
# • [5.2] 
# Removed the UlseSound
#------------------------------------------------------------------------------
# * The item 2, 3, 4 and 5 are statics, would fix independent of the direction 
# that the event is.
# * The items 7, 9, 10, 11: In straight line
#==============================================================================
Ligni.register(:ultimate_sensor_event, "dax", 5.2) {
  #============================================================================
  # • Game_Interpreter
  #============================================================================
  class Game_Interpreter
    #--------------------------------------------------------------------------
    # • Inicialização do objeto
    #--------------------------------------------------------------------------
    alias :_sensorEvent_init :initialize
    def initialize(*args)
      _sensorEvent_init
      @_nozero = ->(number) { return (number < 0 || number.nil? ? 1 : number.to_i) }
    end
    #--------------------------------------------------------------------------
    # • Pega as coordenadas do evento é do player.
    #--------------------------------------------------------------------------
    def block_sensor(b=nil)
      event = $game_map.events[b.nil? ? @event_id : Integer(b)]
      yield(event.x, event.y, $game_player.x, $game_player.y)
    end
    #--------------------------------------------------------------------------
    # • Sensor por área.
    #--------------------------------------------------------------------------
    def sarea?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      distance = Ligni::Mathf.euclidian_distance2d($game_player, $game_map.events[b.nil? ? @event_id : Integer(b)])
      $game_switches[c] = (distance <= a) unless c.nil?
      return (distance <= a)
    end
    #--------------------------------------------------------------------------
    # • Sensor na frente do evento.
    #--------------------------------------------------------------------------
    def sfront?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) { |ex, ey, px, py|
        return unless px == ex
        (ey..(ey + a)).each { |y|
          break unless $game_map.passable?(ex, y, 2)
          $game_switches[c] = true if py == y and !c.nil?
          return true if py == y
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor atrás do evento.
    #--------------------------------------------------------------------------
    def sago?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) { |ex, ey, px, py|
        return unless px == ex
        ey.downto(ey - a).each { |y|
          break unless $game_map.passable?(ex, y, 8)
          $game_switches[c] = true if py == y and !c.nil?
          return true if py == y

        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver sobre o evento.
    #--------------------------------------------------------------------------
    def sabout?(b=nil, c=nil)
      b = nil if b == 0
      block_sensor(b) { |ex, ey, px, py|
        if px == ex && py == ey
          $game_switches[c] = true unless c.nil?
          return true
        end
     }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver a direita do evento.
    #--------------------------------------------------------------------------
    def sright?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        return unless py == ey
        (ex..(ex + a)).each { |x|
          break unless $game_map.passable?(x, ey, 6)
          $game_switches[c] = true if !c.nil? and px == x
          return true if px == x
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver a esquerda do evento.
    #--------------------------------------------------------------------------
    def sleft?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        return unless py == ey
        ex.downto(ex - a).each { |x|
          break unless $game_map.passable?(x, ey, 4)
          $game_switches[c] = true if !c.nil? and px == x
          return true if px == x
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor em forma de cruz.
    #--------------------------------------------------------------------------
    def scross?(a=1, b=nil, c=nil)
      b = nil if b == 0
      sfront?(a, b, c) || sago?(a, b, c) || sright?(a, b, c) || sleft?(a, b, c)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica somente a visão do evento.
    #--------------------------------------------------------------------------
    def svision?(a=1, b=nil, c=nil)
      b = nil if b == 0
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 then sfront?(a, b, c)
      when 4 then sleft?(a, b, c)
      when 6 then sright?(a, b, c)
      when 8 then sago?(a, b, c)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente atrás do evento.
    #--------------------------------------------------------------------------
    def sbehind?(a=1, b=nil, c=nil)
      b = nil if b == 0
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 then sago?(a, b, c)
      when 4 then sright?(a, b, c)
      when 6 then sleft?(a, b, c)
      when 8 then sfront?(a, b, c)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente a esquerda do evento.
    #--------------------------------------------------------------------------
    def vleft?(a=1, b=nil, c=nil)
      b = nil if b == 0
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 then sright?(a, b, c)
      when 4 then sfront?(a, b, c)
      when 6 then sago?(a, b, c)
      when 8 then sleft?(a, b, c)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente a direita do evento.
    #--------------------------------------------------------------------------
    def vright?(a=1, b=nil, c=nil)
      b = nil if b == 0
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 then sleft?(a, b, c)
      when 4 then sfront?(a, b, c)
      when 6 then sago?(a, b, c)
      when 8 then sright?(a, b, c)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado esquerdo-superior na diagonal.
    #--------------------------------------------------------------------------
    def dsleft?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        0.upto(a) { |i|
          if px == (ex - i) and py == (ey - i)
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado direito-superior na diagonal.
    #--------------------------------------------------------------------------
    def dsright?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        0.upto(a) { |i|
          if px == (ex + i) and py == (ey - i)
              $game_switches[c] = true unless c.nil?
            return true
          end
         }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado esquerdo-inferior na diagonal.
    #--------------------------------------------------------------------------
    def dileft?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        0.upto(a) { |i|
          if px == (ex - i) and py == (ey + i)
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado direito-inferior na diagonal.
    #--------------------------------------------------------------------------
    def diright?(a=1, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      block_sensor(b) {|ex, ey, px, py|
        0.upto(a) { |i|
          if px == (ex + i) and py == (ey + i)
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
      }
      $game_switches[c] = false unless c.nil?
      return false
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica a diagonal em todos os lados.
    #--------------------------------------------------------------------------
    def diagonal?(a=1, b=nil, c=nil)
      dsleft?(a, b, c) || dsright?(a, b, c) || dileft?(a, b, c) || diright?(a, b, c)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica a diagonal de acordo com a visão do evento.
    #--------------------------------------------------------------------------
    def vdiagonal?(a=1, b=nil, c=nil)
      b = nil if b == 0
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 then dileft?(a, b, c) || diright?(a, b, c)
      when 4 then dsleft?(a, b, c) || dileft?(a, b, c)
      when 6 then dsright?(a, b, c) || diright?(a, b, c)
      when 8 then dsleft?(a, b, c) || dsright?(a, b, c)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica em forma de círculo.
    #--------------------------------------------------------------------------
    def scircle?(a=2, b=nil, c=nil)
      b = nil if b == 0
      a = a < 2 ? 2 : a
      diagonal?(a-1, b, c) || scross?(a, b, c)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica em retângulo/quadrado na visão do npc.
    #--------------------------------------------------------------------------
    def scubic?(a=3, b=nil, c=nil)
      b = nil if b == 0
      a = @_nozero[a]
      case $game_map.events[b.nil? ? @event_id : Integer(b)].direction
      when 2 #back
        block_sensor(b) {|ex, ey, px, py|
          (ex - (a - 2)).upto(ex + (a - 2)).each { |x|
            (ey).upto(ey+a).each { |y|
              if px == x and py == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 4 #left
        block_sensor(b) {|ex, ey, px, py|
          a.next.times { |i|
            ( ey - (a - 2) ).upto(ey+(a - 2)).each { |y|
              if px == ex - i and py == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 6 #right
        block_sensor(b) {|ex, ey, px, py|
          a.next.times { |i|
            ( ey - (a - 2) ).upto(ey+(a - 2)).each { |y|
              if px == ex + i and py == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 8 #up
        block_sensor(b) {|ex, ey, px, py|
          (ex - (a - 2)).upto(ex + (a - 2)).each { |x|
            (ey).downto(ey-a).each { |y|
              if px == x and py == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      end
      $game_switches[c] = false unless c.nil?
      return false
    end
  end
}

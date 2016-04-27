#==============================================================================
# • Ultimate Sensor Event
#==============================================================================
# Autor: Dax
# Requerimento: Dax Core
# Versão: 5.1
# Site: www.dax-soft.weebly.com
#==============================================================================
# @tiagoms : Feedback que ajudou a incrementar mais.
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Um sistema de sensor, onde permite diferentes tipos de formas dos eventos
# "sentir" a presença do jogador.
#==============================================================================
# • Como usar: Utilze os comandos em condições.
#------------------------------------------------------------------------------
#  a : área em quadrados(tiles) em que o sensor será ativado. Por padrão é 1
#  b : ID do evento. Se definir nada, é o evento local. Por padrão é o evento local.
#  c : (opcional) definir qual switch será usada.
#------------------------------------------------------------------------------
# • [1.0]
# 1 * Primeiro tipo de sensor, e o sensor de área. O comando para usar esse
# tipo de sensor é o : sarea?(a, b, c) :
# 2 * Sensor que verifica se está em baixo do evento..: sfront?(a, b, c)
# 3 * Sensor que verifica se está em cima do evento..: sago?(a, b, c)
# 4 * Sensor que verifica se está a esquerda do evento: sleft?(a, b, c)
# 5 * Sensor que verifica se está a direita do evento: sright?(a, b, c)
# 6 * Sensor que faz uma verificação em forma de cruz: scross?(a, b, c)
# 7 * Sensor que verifica se está somente na visão do evento: svision?(a, b, c)
# 8 * Sensor que verifica se está sobre o evento.. sabout?(b, c)
# • [2.0~2.5] :
# 9 * Sensor que verifica se está somente atrás do evento. sbehind?(a, b, c)
# 10 * Sensor que verifica se está somente a esquerda do evento. vleft?(a, b, c)
# 11 * Sensor que verifica se está somente a direita do evento. vright?(a, b, c)
# • [3.0] :
# 14 * Sensor que verifica a esquerda-superior na diagonal. dsleft?(a, b, c)
# 15 * Sensor que verifica a esquerda-inferior na diagonal. dileft?(a, b, c)
# 16 * Sensor que verifica a direita-superior na diagonal. dsright?(a, b, c)
# 17 * Sensor que verifica a direita-inferior na diagonal. diright?(a, b, c)
# 18 * Sensor que verifica em todos os lados na diagonal. diagonal?(a, b, c)
# 19 * Sensor que verifica em forma de círculo. scircle?(a, b, c)
# 20 * Sensor que verifica a diagonal de acordo com a visão do evento. vdiagonal?(a, b, c)
# • [3.5] :
# 21 * Sensor que verifica em retângulo/quadrado na visão do npc.
# De acordo com a visão do jogador. scubic?(a, b, c)
# • [4.0] :
# Atualizado para a nova versão do core.
# • [5.1] :
# Adicionado a opção de definir qual switch será ativada...
# Adicionado a opção de controlar o som emitido pelo evento, de acordo com
# sua distância.
# A : Nome do arquivo
# B : ID do evento. Ponha 0 para o evento local
# C : Tipo do arquivo
#   :bgm
#   :bgs
#   :me
#   :se
# D : Controle da distância por tile. Opcional, caso não definir é o da variável.
# T : Esperar uma certa quantidade de tempo para retomar ao som. Opcional.
#     Defina em segundos.
# P : Porcentagem do volume final, por padrão é 100%/1.0
# Quanto maior, menor o volume do som.
# variável $ulsound = X
# Comando: ulse_sound(B, A, C, D, T, P)
#------------------------------------------------------------------------------
# * Atenção, o item 2 á 5 são estáticos, ou seja,
# serão fixos independente da direção em que o evento esteja
# * Os itens 7, 9, 10, 11: Em uma linha reta
#==============================================================================
Dax.register(:ultimate_sensor_event, "Dax", 5.0) {
  #============================================================================
  # • TimeUlseSound
  #============================================================================
  class TimeUlseSound
    #--------------------------------------------------------------------------
    # • Variables
    #--------------------------------------------------------------------------
    attr_accessor :timeMax
    attr_accessor :timeCurrent
    #--------------------------------------------------------------------------
    # • initialize
    #--------------------------------------------------------------------------
    def initialize
      @timeMax = {}
      @timeCurrent = {}
    end
    #--------------------------------------------------------------------------
    # • Definir tempo máximo
    #--------------------------------------------------------------------------
    def tM(tm, id)
      @timeMax[id] = tm.abs * 60 rescue 60
    end
    #--------------------------------------------------------------------------
    # • update
    #--------------------------------------------------------------------------
    def update(id)
      @timeCurrent[id] = DMath.clamp(@timeMax[id], 0, @timeMax[id]) if @timeCurrent[id].nil?
      if @timeCurrent[id] <= 0
        @timeCurrent[id] = @timeMax[id]
      else
        @timeCurrent[id] -= 1
      end
    end
    #--------------------------------------------------------------------------
    # • ok?
    #--------------------------------------------------------------------------
    def ok?(id)
      return false unless @timeCurrent.has_key?(id)
      return @timeCurrent[id] <= 0
    end
  end
  #--------------------------------------------------------------------------
  # • Variavel Global
  #--------------------------------------------------------------------------
  $ulsound = 10
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
      @timeUlseSound = TimeUlseSound.new
    end
    #--------------------------------------------------------------------------
    # • Ulse Sound
    #--------------------------------------------------------------------------
    def ulse_sound(b, a, c, d=$ulsound, time=nil, p=1.0)
      b = b == 0 ? nil : b
      eve = $game_map.events[b.nil? ? @event_id : Integer(b)]
      dist = DMath.distance_sensor($game_player, eve)
      # r = r1 * sqrt(L1/L2)
      dist =  DMath.to_4_dec(dist * Math.log2(d))
      vol = (dist) * Math.sqrt( (  (d-dist)/(100)  ).abs )
      vol = 100 - DMath.clamp(vol, 1, 100)
      vol = DMath.to_4_dec(vol) * p
      if time.nil?
        SoundBase.play(a, vol, 100, c)
      else
        @timeUlseSound.tM(time, eve.id)
        @timeUlseSound.update(eve.id)
        SoundBase.play(a, vol, 100, c) if @timeUlseSound.ok?(eve.id)
      end
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
      a = @_nozero[a]
      distance = DMath.distance_sensor($game_player, $game_map.events[b.nil? ? @event_id : Integer(b)])
      $game_switches[c] = (distance <= a) unless c.nil?
      return (distance <= a)
    end
    #--------------------------------------------------------------------------
    # • Sensor na frente do evento.
    #--------------------------------------------------------------------------
    def sfront?(a=1, b=nil, c=nil)
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
      sfront?(a, b, c) || sago?(a, b, c) || sright?(a, b, c) || sleft?(a, b, c)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica somente a visão do evento.
    #--------------------------------------------------------------------------
    def svision?(a=1, b=nil, c=nil)
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
    def scircle?(a=2, b=nil)
      a = a < 2 ? 2 : a
      diagonal?(a-1, b, c) || scross?(a, b, c)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica em retângulo/quadrado na visão do npc.
    #--------------------------------------------------------------------------
    def scubic?(a=3, b=nil, c=nil)
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

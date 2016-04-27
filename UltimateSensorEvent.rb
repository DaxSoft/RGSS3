#==============================================================================
# • Ultimate Sensor Event ++
#==============================================================================
# Autor: Dax
# Requerimento: Dax Core
# Versão: 6.0
# Site: www.dax-soft.weebly.com
#==============================================================================
# @tiagoms : Feedback que ajudou a incrementar mais.
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Um sistema de sensor, onde permite diferentes tipos de formas dos eventos
# "sentir" a presença do jogador.
#  Permite que um evento, sinta a presença de outro evento também.
#==============================================================================
# • Como usar: Utilze os comandos em condições.
#------------------------------------------------------------------------------
#  a : área em quadrados(tiles) em que o sensor será ativado. Por padrão é 1
#  b : ID do evento. Se definir nada, é o evento local. Por padrão é o evento local.
#  c : (opcional) definir qual switch será validade após o sensor estiver ativado.
#  d : Se for nil/-1, será o jogador. Se for 0, será o evento local, se for mais de
# um, será outro evento. Que irá ser o causador do alarme do sensor. Por padrão
# é nil/-1
#------------------------------------------------------------------------------
# • [1.0]
# 1 * Primeiro tipo de sensor, e o sensor de área. O comando para usar esse
# tipo de sensor é o : sarea?(a, b, c, d) :
# 2 * Sensor que verifica se está em baixo do evento..: sfront?(a, b, c, d)
# 3 * Sensor que verifica se está em cima do evento..: sago?(a, b, c, d)
# 4 * Sensor que verifica se está a esquerda do evento: sleft?(a, b, c, d)
# 5 * Sensor que verifica se está a direita do evento: sright?(a, b, c, d)
# 6 * Sensor que faz uma verificação em forma de cruz: scross?(a, b, c, d)
# 7 * Sensor que verifica se está somente na visão do evento: svision?(a, b, c, d)
# 8 * Sensor que verifica se está sobre o evento.. sabout?(b, c, d)
# • [2.0~2.5] :
# 9 * Sensor que verifica se está somente atrás do evento. sbehind?(a, b, c, d)
# 10 * Sensor que verifica se está somente a esquerda do evento. vleft?(a, b, c, d)
# 11 * Sensor que verifica se está somente a direita do evento. vright?(a, b, c, d)
# • [3.0] :
# 14 * Sensor que verifica a esquerda-superior na diagonal. dsleft?(a, b, c, d)
# 15 * Sensor que verifica a esquerda-inferior na diagonal. dileft?(a, b, c, d)
# 16 * Sensor que verifica a direita-superior na diagonal. dsright?(a, b, c, d)
# 17 * Sensor que verifica a direita-inferior na diagonal. diright?(a, b, c, d)
# 18 * Sensor que verifica em todos os lados na diagonal. diagonal?(a, b, c, d)
# 19 * Sensor que verifica em forma de círculo. scircle?(a, b, c, d)
# 20 * Sensor que verifica a diagonal de acordo com a visão do evento. vdiagonal?(a, b, c, d)
# • [3.5] :
# 21 * Sensor que verifica em retângulo/quadrado na visão do npc.
# De acordo com a visão do jogador. scubic?(a, b, c, d)
# • [4.0] :
# Atualizado para a nova versão do core.
# • [5.1] :
# Adicionado a opção de definir qual switch será ativada...
# Adicionado a opção de controlar o som emitido pelo evento, de acordo com
# A : Nome do arquivo
# B : ID do evento-fonte. Ponha 0 para o evento local
# C : Tipo do arquivo
#   :bgm
#   :bgs
#   :me
#   :se
# D : ID do evento que irá ouvir a fonte. -1/nil para jogador, mais de 1 para
# outro evento.
# DS : Controle da distância por tile. Opcional, caso não definir é o da variável.
# T : Esperar uma certa quantidade de tempo para retomar ao som. Opcional.
#     Defina em segundos.
# Quanto maior, menor o volume do som.
# variável $ulsound = X
# Comando: ulse_sound(B, A, C, D, T, DS)
# [6.0] :
#   Agora permite que o sensor do evento, possa ser ativa por outro evento. 
#------------------------------------------------------------------------------
# * Atenção, o item 2 á 5 são estáticos, ou seja,
# serão fixos independente da direção em que o evento esteja
# * Os itens 7, 9, 10, 11: Em uma linha reta
#==============================================================================
Dax.register(:ultimate_sensor_event, "Dax", 6.0) {
  #============================================================================
  # • ULSE
  #============================================================================
  module ULSE
    #--------------------------------------------------------------------------
    # • Extend
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # • Constantes
    #--------------------------------------------------------------------------
    USOUND = 10
    UNOZERO = ->(number) { return (number < 0 || number.nil? ? 1 : number.to_i) }
    #--------------------------------------------------------------------------
    # • Obter constante do som ou defini-lá.
    #--------------------------------------------------------------------------
    def sound(n=USOUND)
      n.abs rescue USOUND
    end
    #==========================================================================
    # • TimeUlseSound
    #==========================================================================
    class TimeUlseSound
      #------------------------------------------------------------------------
      # • Variables
      #------------------------------------------------------------------------
      attr_accessor :timeMax
      attr_accessor :timeCurrent
      #------------------------------------------------------------------------
      # • initialize
      #------------------------------------------------------------------------
      def initialize
        @timeMax = {}
        @timeCurrent = {}
      end
      #------------------------------------------------------------------------
      # • Definir tempo máximo
      #------------------------------------------------------------------------
      def tM(tm, id)
        @timeMax[id] = tm.abs * 60 rescue 60
      end
      #------------------------------------------------------------------------
      # • update
      #------------------------------------------------------------------------
      def update(id)
        @timeCurrent[id] = DMath.clamp(@timeMax[id], 0, @timeMax[id]) if @timeCurrent[id].nil?
        if @timeCurrent[id] <= 0
          @timeCurrent[id] = @timeMax[id]
        else
          @timeCurrent[id] -= 1
        end
      end
      #------------------------------------------------------------------------
      # • ok?
      #------------------------------------------------------------------------
      def ok?(id)
        return false unless @timeCurrent.has_key?(id)
        return @timeCurrent[id] <= 0
      end
    end
  end
  #============================================================================
  # • Game_Interpreter
  #============================================================================
  class Game_Interpreter
    #--------------------------------------------------------------------------
    # • Includes
    #--------------------------------------------------------------------------
    include ULSE
    #--------------------------------------------------------------------------
    # • Inicialização do objeto
    #--------------------------------------------------------------------------
    alias :_sensorEvent_init :initialize
    def initialize(*args)
      _sensorEvent_init
      @timeUlseSound = TimeUlseSound.new
    end
    #--------------------------------------------------------------------------
    # • Obter coordenadas dos pontos.
    #     -1 : player | 0 - local event | 1> - event
    #     pIDa : event
    #     pIDb : player or event
    #--------------------------------------------------------------------------
    def ulseCoords(pIDa, pIDb=nil)
      getA = get_character(pIDa.nil? ? 0 : pIDa.abs)
      getB = get_character(pIDb.nil? ? -1 : pIDb.abs)
      yield(getA, getB)
    end

    #--------------------------------------------------------------------------
    # • Ulse Sound
    #     b : ID do evento-fonte.
    #     a : Nome do arquivo.
    #     c : Tipo do arquivo.
    #     d : ID do evento/jogador que "ouve" a fonte
    #     t : Esperar certa quantia para repetir o som. Opcional. Defina em segundos.
    #     dS : Controle do volume/distância per tile. Não precisa definir, é
    # opcional.
    #--------------------------------------------------------------------------
    def ulse_sound(b, a, c, d, t=nil, dS=ULSE.sound)
      ulseCoords(b, d) { |e, pe|
        # distance
        distance = DMath.to_4_dec( DMath.distance_sensor(pe, e) * Math.log2(dS))
        # r = r1 * sqrt(L1/L2)
        volume = (distance) * Math.sqrt( ( (dS-distance)/(100) ).abs )
        volume = 100 - DMath.clamp(volume, 0, 100)
        volume = DMath.to_4_dec(volume)
        # time
        if t.nil?
          SoundBase.play(a, volume, 100, c)
        else
          @timeUlseSound.tM(t, e.id)
          @timeUlseSound.update(e.id)
          SoundBase.play(a, volume, 100, c) if @timeUlseSound.ok?(e.id)
        end
      }
    end
    #--------------------------------------------------------------------------
    # • sarea? : Sensor por área quadrada.
    #--------------------------------------------------------------------------
    def sarea?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        distance = DMath.distance_sensor(pe, e)
        $game_switches[c] = (distance <= a) unless c.nil?
        return (distance <= a)
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor na frente do evento.
    #--------------------------------------------------------------------------
    def sfront?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
       ulseCoords(b, d) { |e, pe|
        return unless pe.x == e.x
        ((e.y)..(e.y + a)).each { |y|
          # break
          $game_switches[c] = true if pe.y == y and !c.nil?
          return true if pe.y == y
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor atrás do evento.
    #--------------------------------------------------------------------------
    def sago?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        return unless pe.x == e.x
        e.y.downto(e.y - a).each { |y|
          # break
          $game_switches[c] = true if pe.y == y and !c.nil?
          return true if pe.y == y
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver sobre o evento.
    #--------------------------------------------------------------------------
    def sabout?(b=nil, c=nil, d=nil)
      ulseCoords(b, d) { |e, pe|
        if pe.x == e.x && pe.y == e.y
          $game_switches[c] = true unless c.nil?
          return true
        end
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver a direita do evento.
    #--------------------------------------------------------------------------
    def sright?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        return unless pe.y == e.y
        ((e.x)..(e.x + a)).each { |x|
          # break
          $game_switches[c] = true if !c.nil? and pe.x == x
          return true if pe.x == x
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor quando estiver a esquerda do evento.
    #--------------------------------------------------------------------------
    def sleft?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        return unless pe.y == e.y
        e.x.downto(e.x - a).each { |x|
          # break
          $game_switches[c] = true if !c.nil? and pe.x == x
          return true if pe.x == x
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor em forma de cruz.
    #--------------------------------------------------------------------------
    def scross?(a=1, b=nil, c=nil, d=nil)
      sfront?(a, b, c, d) || sago?(a, b, c, d) || sright?(a, b, c, d) || sleft?(a, b, c, d)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica somente a visão do evento.
    #--------------------------------------------------------------------------
    def svision?(a=1, b=nil, c=nil, d=nil)
      case get_character(b).direction
      when 2 then sfront?(a, b, c, d)
      when 4 then sleft?(a, b, c, d)
      when 6 then sright?(a, b, c, d)
      when 8 then sago?(a, b, c, d)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente atrás do evento.
    #--------------------------------------------------------------------------
    def sbehind?(a=1, b=nil, c=nil)
      case get_character(b).direction
      when 2 then sago?(a, b, c, d)
      when 4 then sright?(a, b, c, d)
      when 6 then sleft?(a, b, c, d)
      when 8 then sfront?(a, b, c, d)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente a esquerda do evento.
    #--------------------------------------------------------------------------
    def vleft?(a=1, b=nil, c=nil)
      case get_character(b).direction
      when 2 then sright?(a, b, c, d)
      when 4 then sfront?(a, b, c, d)
      when 6 then sago?(a, b, c, d)
      when 8 then sleft?(a, b, c, d)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica se está somente a direita do evento.
    #--------------------------------------------------------------------------
    def vright?(a=1, b=nil, c=nil)
      case get_character(b).direction
      when 2 then sleft?(a, b, c, d)
      when 4 then sfront?(a, b, c, d)
      when 6 then sago?(a, b, c, d)
      when 8 then sright?(a, b, c, d)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado esquerdo-superior na diagonal.
    #--------------------------------------------------------------------------
    def dsleft?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        0.upto(a) { |i|
          if pe.x == (e.x - i) and pe.y == (e.y - i)
            # break
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado direito-superior na diagonal.
    #--------------------------------------------------------------------------
    def dsright?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        0.upto(a) { |i|
          if pe.x == (e.x + i) and pe.y == (e.y - i)
            # break
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado esquerdo-inferior na diagonal.
    #--------------------------------------------------------------------------
    def dileft?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        0.upto(a) { |i|
          if pe.x == (e.x - i) and pe.y == (e.y + i)
            # break
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica o lado direito-inferior na diagonal.
    #--------------------------------------------------------------------------
    def diright?(a=2, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      ulseCoords(b, d) { |e, pe|
        0.upto(a) { |i|
          if pe.x == (e.x + i) and pe.y == (e.y + i)
            $game_switches[c] = true unless c.nil?
            return true
          end
        }
        $game_switches[c] = false unless c.nil?
        return false
      }
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica a diagonal em todos os lados.
    #--------------------------------------------------------------------------
    def diagonal?(a=1, b=0, c=nil, d=nil)
      dsleft?(a, b, c, d) || dsright?(a, b, c, d) || dileft?(a, b, c, d) || diright?(a, b, c, d)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica a diagonal de acordo com a visão do evento.
    #--------------------------------------------------------------------------
    def vdiagonal?(a=1, b=0, c=nil, d=nil)
      case get_character(b).direction
      when 2 then dileft?(a, b, c, d) || diright?(a, b, c, d)
      when 4 then dsleft?(a, b, c, d) || dileft?(a, b, c, d)
      when 6 then dsright?(a, b, c, d) || diright?(a, b, c, d)
      when 8 then dsleft?(a, b, c, d) || dsright?(a, b, c, d)
      end
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica em forma de círculo.
    #--------------------------------------------------------------------------
    def scircle?(a=2, b=0, c=nil, d=nil)
      a = a < 2 ? 2 : a
      diagonal?(a-1, b, c, d) || scross?(a, b, c, d)
    end
    #--------------------------------------------------------------------------
    # • Sensor que verifica em retângulo/quadrado na visão do npc.
    #--------------------------------------------------------------------------
    def scubic?(a=3, b=nil, c=nil, d=nil)
      a = UNOZERO[a]
      case get_character(b).direction
      when 2 #back
        ulseCoords(b, d) { |e, pe|
          (e.x - (a - 2)).upto(e.x + (a - 2)).each { |x|
            (e.y).upto(e.y+a).each { |y|
              if pe.x == x and pe.y == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 4 #left
        ulseCoords(b, d) { |e, pe|
          a.next.times { |i|
            ( e.y - (a - 2) ).upto(e.y+(a - 2)).each { |y|
              if pe.x == e.x - i and pe.y == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 6 #right
        ulseCoords(b, d) { |e, pe|
          a.next.times { |i|
            ( e.y - (a - 2) ).upto(e.y+(a - 2)).each { |y|
              if pe.x == e.x + i and pe.y == y
                $game_switches[c] = true unless c.nil?
                return true
              end
            }
          }
        }
      when 8 #up
        ulseCoords(b, d) { |e, pe|
          (e.x - (a - 2)).upto(e.x + (a - 2)).each { |x|
            (e.y).downto(e.y-a).each { |y|
              if pe.x == x and pe.y == y
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

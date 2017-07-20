=begin
 [General]
    Author: Dax Soft
    Version: 4.0
    Site: www.dax-soft.weebly.com
    Requirement: Ligni Core
 [Description]
    Allow to make/create bars who stay in the head of the events..
    Helpful to make bars of life..To system of battle.
 [How to Use]
    Check out in: 
      Web: http://tutorial-dax.weebly.com/event-bar.html
 [Version]
    @4.0:
        - Script updated
        - Code improved
=end
Ligni.register(:event_bar, "dax", 4.0) {
    # module
    module Ligni::Event_Bar; extend self
        # performace: 
        #   perfect: 1-5
        #   best: 5-15
        #   medium: 15-35
        #   bad: 35-60
        UPDATE = 5
        # Basic Setup 
        Z = 200 # ► Propriedade no mapa.
        COLOR_DEFAULT_BAR2 = "920120".color # ► Cor padrão da barra 2.
        COLOR_DEFAULT_BAR = "d3002d".color # ► Cor padrão da barra.
        COLOR_BACKGROUND = "000000".color # ► Cor do fundo.
        WIDTH = 24 # ► Largura padrão da barra.
        HEIGHT = 5 # ► Altura padrão da barra.
        # Variable
        @data = []
        # create a bar
        def create(*args); @data << Sprite_EBar.new(*args); end;
        # hide
        def hide; @data.each { |bar| bar.opacity = 0 unless bar.nil? }; end; 
        # dispose 
        def dispose 
            return if @data.nil? 
            @data.each_with_index { |bar, index|
                unless bar.nil?
                    bar.dispose
                    @data.delete_at(index)
                end
            }
        end 
        # update 
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
        # Sprite EBar
        class ::Sprite_EBar < Sprite 
            # initialize
            def initialize(eID, vID, m, vm=nil, x=nil, y=nil, w=nil, h=nil, color2=nil, color=nil)
                @x, @y = x || 0, y || 0
                @eID = eID
                @m, @vm, @vID = m, vm || 0, vID
                super([w || WIDTH, h || HEIGHT])
                self.x = $game_map.events[@eID].screen_x - (self.width / 2) + @x
                self.y = $game_map.events[@eID].screen_y - (33+self.height) + @y
                self.z = Z
                 @max = @vm.nil? ? @m : $game_variables[@vm] == 0 ? ($game_variables[@vm] = @m) : $game_variables[@vm]
                @actual = $game_variables[@vID] = $game_variables[@vID] == 0 ? @max : $game_variables[@vID]
                @color2, @color = color2 || COLOR_DEFAULT_BAR2, color || COLOR_DEFAULT_BAR
            end
            # dispose
            def dispose
                self.bitmap.dispose
                super
            end
            # update
            def update
                return if self.bitmap.nil?
                self.x = $game_map.events[@eID].screen_x - (self.width / 2) + @x
                self.y = $game_map.events[@eID].screen_y - (33+self.height) + @y
                self.bitmap.clear
                @max = @vm.nil? ? @m : $game_variables[@vm] == 0 ? ($game_variables[@vm] = @m) : $game_variables[@vm]
                @actual = $game_variables[@vID] = $game_variables[@vID] == 0 ? 0 : $game_variables[@vID]
                self.bitmap.fill_rect(self.rect, COLOR_BACKGROUND)
                self.bitmap.gradient_bar([@color, @color2], @actual, @max, 1)
                self.visible = false if @actual < 1
            end
        end # end
    end # end
    # Spriteset_Map
    class Spriteset_Map
        alias :event_bar_dispose :dispose
        def dispose
            Ligni::Event_Bar.hide
            event_bar_dispose
        end
        alias :event_bar_update :update
        def update
            event_bar_update
            Ligni::Event_Bar.update if (Graphics.frame_count %= Ligni::Event_Bar::UPDATE)
        end
    end
    # Game Player
    class Game_Player < Game_Character
        alias :eb_perform_transfer :perform_transfer
        def perform_transfer
            eb_perform_transfer
            Ligni::Event_Bar.dispose
        end
    end
    # Interpreter
    class Game_Interpreter
        # create
        def ebar(eID, vID, m, hash={})
            array = [
                hash.has_key?(:vm) ? hash[:vm] : nil,
                hash.has_key?(:x) ? hash[:x] : nil,
                hash.has_key?(:y) ? hash[:y] : nil,
                hash.has_key?(:w) ? hash[:w] : nil,
                hash.has_key?(:h) ? hash[:h] : nil,
                hash.has_key?(:color2) ? hash[:color2] : nil,
                hash.has_key?(:color) ? hash[:color] : nil,
            ]
            Ligni::Event_Bar.create(eID, vID, m, *array)
        end
    end
}

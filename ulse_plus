=begin
 [General]
    Author: Dax Soft
    Version: 6.0
    Site: www.dax-soft.weebly.com
    Requirement: Ligni Core
    @tiagoms : Feedback that helped improve more on the project
 [Description]
    System of the sensor event. Useful to stealth games and whatever.
 [How to Use]
    Check out in: 
 [Version]
    @1.0
        - Sensor by area
        - Check if is below/top/left/right/above of the event
        - Verification in the form of cross
        - Just on vision of event
    @2.5
        - Check if is behind of event. Just from behind
        - Check if is on left of event. Just on left
        - Check if is on right of event. Just on right
    @3.0
        - Check if is on top-left/lower-left/top-right/lower-right on diagonal
        - Check if is in all sides on diagonal
        - Verification in the form of the circle
        - Check diagonally according to the vision of the event
    @3.5
        - Verification in the form of rectangle on vision of event
    @4.0
        - Update to new version of the Core
    @5.1
        - Option to set which switch will be activated
    @5.2
        - Removed the UlseSound
    @6.0
        - Code improved
        - Sensor works between events 
=end
Ligni.register(:ulse, "dax", 6.0) {
    # -- class:Game_Interpreter
    class Game_Interpreter
        # performace: 
        #   perfect: 1-5
        #   best: 5-15
        #   medium: 15-35
        #   bad: 35-60
        ULSE_UPDATE = 25
        # get the coord of player and event
        def getCoordPE(id=nil) # id event 
            event = $game_map.events[id.nil? ? @event_id : Integer(id.abs)]
            yield(event.x, event.y, $game_player.x, $game_player.y)
        end
        # get the coord of two event
        def getCoordEE(id, id2=nil)
            event = get_character(id)
            event2 = get_character(id2)
            yield(event2.x, event2.y, event.x, event.y)
        end 
        # by area? 
        def uArea?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil? 
            if eid.is_a?(Array)
                distance = Ligni::Mathf.euclidean_distance_2d( get_character(eid[0]), get_character(eid[1]) )
            else
                distance = Ligni::Mathf.euclidean_distance_2d($game_player, get_character(eid))
            end
            $game_switches[sid] = (distance <= tile) unless sid.nil?
            return (distance <= tile) if (Graphics.frame_count %= ULSE_UPDATE)
        end 
        # front?
        def uFront?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil? 
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    return unless e2x == ex 
                    (e2y..(e2y + tile)).each { |y|
                        break unless $game_map.passable?(e2x, y, 2)
                        $game_switches[sid] = true if ey == y and !sid.nil?
                        return true if ey == y
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else 
                getCoordPE(eid) { |ex, ey, px, py|
                    return unless px == ex 
                    (ey..(ey + tile)).each { |y|
                        break unless $game_map.passable?(ex, y, 2)
                        $game_switches[sid] = true if py == y and !sid.nil?
                        return true if py == y 
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end 
            $game_switches[sid] = false unless sid.nil?
            return false 
        end 
        # uAgo?
        def uAgo?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil? 
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                   return unless e2x == ex
                   ey.downto(ey - tile).each { |y|
                        break unless $game_map.passable?(ex, y, 8)
                        $game_switches[sid] = true if e2y == y and !sid.nil?
                        return true if e2y == y
                    } 
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else 
                getCoordPE(eid) { |ex, ey, px, py|
                   return unless px == ex
                   ey.downto(ey - tile).each { |y|
                        break unless $game_map.passable?(ex, y, 8)
                        $game_switches[sid] = true if py == y and !sid.nil?
                        return true if py == y
                    } 
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end 
            $game_switches[sid] = false unless sid.nil?
            return false 
        end
        # uAbout?
        def uAbout?(eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    if e2x == ex && e2y == ey 
                        $game_switches[sid] = true unless sid.nil?
                        return true 
                    end 
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else 
                getCoordPE(eid) { |ex, ey, px, py|
                    if px == ex && py == ey 
                        $game_switches[sid] = true unless sid.nil?
                        return true 
                    end 
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end 
            $game_switches[sid] = false unless sid.nil?
            return false 
        end
        # uRight?
        def uRight?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil? 
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    return unless e2y == ey
                    (ex..(ex + tile)).each { |x|
                        break unless $game_map.passable?(x, ey, 6)
                        $game_switches[sid] = true if !sid.nil? and e2x == x
                        return true if e2x == x
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else
                getCoordPE(eid) { |ex, ey, px, py|
                    return unless py == ey
                    (ex..(ex + tile)).each { |x|
                        break unless $game_map.passable?(x, ey, 6)
                        $game_switches[sid] = true if !sid.nil? and px == x
                        return true if px == x
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end 
            $game_switches[sid] = false unless sid.nil?
            return false 
        end
        # uLeft?
        def uLeft?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    return unless e2y == ey
                    ex.downto(ex - tile).each { |x|
                        break unless $game_map.passable?(x, ey, 4)
                        $game_switches[sid] = true if !sid.nil? and e2x == x
                        return true if e2x == x
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else 
                getCoordPE(eid) { |ex, ey, px, py|
                    return unless py == ey
                    ex.downto(ex - tile).each { |x|
                        break unless $game_map.passable?(x, ey, 4)
                        $game_switches[sid] = true if !sid.nil? and px == x
                        return true if px == x
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end 
            $game_switches[sid] = false unless sid.nil?
            return false 
        end
        # uCross?
        def uCross?(tile, eid, sid=nil)
            uFront?(tile, eid, sid) || uAgo?(tile, eid, sid) || uLeft?(tile, eid, sid) || uRight?(tile, eid, sid)
        end
        # uVision?
        def uVision?(tile=1, eid=0, sid=nil)
            case get_character(eid.is_a?(Array) ? eid.last : eid)
            when 2 then uFront?(tile, eid, sid)
            when 4 then uLeft?(tile, eid, sid)
            when 6 then uRight?(tile, eid, sid)
            when 8 then uAgo?(tile, eid, sid)
            end
        end
        # uBehind?
        def uBehind?(tile=1, eid=0, sid=nil)
            case get_character(eid.is_a?(Array) ? eid.last : eid)
            when 8 then uFront?(tile, eid, sid)
            when 6 then uLeft?(tile, eid, sid)
            when 4 then uRight?(tile, eid, sid)
            when 2 then uAgo?(tile, eid, sid)
            end
        end
        # vLeft?
        def vLeft?(tile=1, eid=0, sid=nil)
            case get_character(eid.is_a?(Array) ? eid.last : eid)
            when 4 then uFront?(tile, eid, sid)
            when 8 then uLeft?(tile, eid, sid)
            when 2 then uRight?(tile, eid, sid)
            when 6 then uAgo?(tile, eid, sid)
            end
        end
        # vRight?
        def vRight?(tile=1, eid=0, sid=nil)
            case get_character(eid.is_a?(Array) ? eid.last : eid)
            when 4 then uFront?(tile, eid, sid)
            when 2 then uLeft?(tile, eid, sid)
            when 8 then uRight?(tile, eid, sid)
            when 6 then uAgo?(tile, eid, sid)
            end
        end
        # dLeft?
        def dLeft?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    0.upto(tile) { |i|
                        if e2x == (ex - i) and e2y == (ey - i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else
                getCoordPE(eid) { |ex, ey, px, py|
                    0.upto(tile) { |i|
                        if px == (ex - i) and py == (ey - i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end
            $game_switches[sid] = false unless sid.nil?
            return false
        end 
        # dRight?
        def dRight?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    0.upto(tile) { |i|
                        if e2x == (ex + i) and e2y == (ey - i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else
                getCoordPE(eid) { |ex, ey, px, py|
                    0.upto(tile) { |i|
                        if px == (ex + i) and py == (ey - i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end
            $game_switches[sid] = false unless sid.nil?
            return false
        end
        # diLeft?
        def diLeft?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    0.upto(tile) { |i|
                        if e2x == (ex - i) and e2y == (ey + i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else
                getCoordPE(eid) { |ex, ey, px, py|
                    0.upto(tile) { |i|
                        if px == (ex - i) and py == (ey + i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end
            $game_switches[sid] = false unless sid.nil?
            return false
        end
        # diRight?
        def diRight?(tile=1, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                getCoordEE(*eid) { |e2x, e2y, ex, ey|
                    0.upto(tile) { |i|
                        if e2x == (ex + i) and e2y == (ey + i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            else
                getCoordPE(eid) { |ex, ey, px, py|
                    0.upto(tile) { |i|
                        if px == (ex + i) and py == (ey + i)
                            $game_switches[sid] = true unless sid.nil?
                            return true
                        end
                    }
                } if (Graphics.frame_count %= ULSE_UPDATE)
            end
            $game_switches[sid] = false unless sid.nil?
            return false
        end
        # uDiagonal?
        def uDiagonal?(tile=1, eid=0, sid=nil)
            dLeft?(tile, eid, sid) || dRight?(tile, eid, sid) || diLeft?(tile, eid, sid) || diRight?(tile, eid, sid)
        end
        # vDiagonal?
        def vDiagonal?(tile=1, eid=0, sid=nil)
            case get_character(eid.is_a?(Array) ? eid.last : eid)
            when 2 then diLeft?(tile, eid, sid) || diRight?(tile, eid, sid)
            when 4 then dLeft?(tile, eid, sid) || diLeft?(tile, eid, sid)
            when 6 then dRight?(tile, eid, sid) || diRight?(tile, eid, sid)
            when 8 then dLeft?(tile, eid, sid) || dRight?(tile, eid, sid)
            end
        end
        # uCircle?
        def uCircle?(tile=2, eid=0, sid=nil)
            tile = tile < 2 ? 2 : tile 
            uDiagonal?(tile-1, eid, sid) || uCross?(tile, eid, sid)
        end
        # uCubic?
        def uCubic?(tile=3, eid=0, sid=nil)
            eid = 0 if eid.nil?
            if eid.is_a?(Array)
                case get_character(eid.last)
                when 2
                    getCoordEE(*eid) { |ex, ey, px, py|
                        (ex - (tile - 2)).upto(ex + (tile - 2)).each { |x|
                            (ey).upto(ey + tile).each { |y|
                                if e2x == x and e2y == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 4
                    getCoordEE(*eid) { |ex, ey, px, py|
                        tile.next.times { |i|
                            ( ey - (tile - 2) ).upto(ey + (tile - 2)).each { |y|
                                if e2x == ex - i and e2y == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 6
                    getCoordEE(*eid) { |ex, ey, px, py|
                        tile.next.times { |i|
                            ( ey - (tile - 2) ).upto(ey + (tile - 2)).each { |y|
                                if e2x == ex + i and e2y == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 8
                    getCoordEE(*eid) { |ex, ey, px, py|
                        (ex - (tile - 2)).upto(ex + (tile - 2)).each { |x|
                            (ey).downto(ey-tile).each { |y|
                                if e2x == x and e2y == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                end
            else 
                case get_character(eid)
                when 2
                    getCoordPE(eid) { |ex, ey, px, py|
                        (ex - (tile - 2)).upto(ex + (tile - 2)).each { |x|
                            (ey).upto(ey + tile).each { |y|
                                if px == x and py == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 4
                    getCoordPE(eid) { |ex, ey, px, py|
                        tile.next.times { |i|
                            ( ey - (tile - 2) ).upto(ey + (tile - 2)).each { |y|
                                if px == ex - i and py == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 6
                    getCoordPE(eid) { |ex, ey, px, py|
                        tile.next.times { |i|
                            ( ey - (tile - 2) ).upto(ey + (tile - 2)).each { |y|
                                if px == ex + i and py == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                when 8
                    getCoordPE(eid) { |ex, ey, px, py|
                        (ex - (tile - 2)).upto(ex + (tile - 2)).each { |x|
                            (ey).downto(ey-tile).each { |y|
                                if px == x and py == y
                                    $game_switches[sid] = true unless sid.nil?
                                    return true
                                end
                            }
                        }
                    } if (Graphics.frame_count %= ULSE_UPDATE)
                end
            end 
            $game_switches[sid] = false unless sid.nil?
            return false
        end
    end # end 
} #px = e2x

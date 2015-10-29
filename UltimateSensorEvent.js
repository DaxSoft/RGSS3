//=============================================================================
// Ultimate Sensor Event
// By Kvothe
// UltimateSensorEvent.js
// Version: 1.0.0
// Free for commercial and non commercial use.
//=============================================================================
var Imported = Imported || {};
var Kvothe = Kvothe || {};
Kvothe.UltimateSensorEvent = {};
/*:
  * @author Kvothe
  * @plugindesc Adicionar sistema de sensor nos eventos.
  *
  * @help
  * Caso tenha dúvidas, contate os seguintes meios.
  *     email dax-soft@live.com
  *     website http://www.dax-soft.weebly.com
  * ===========================================================================
  * Comandos . Use os comandos nas condições; utilizando o comando Script.
  *   Caso queira somente usar no evento em que a condição está, não precisa
  * definir o segundo valor. Exemplo: this.sArea(2)
  * ===========================================================================
  * Values .
  *     distance . Distância em tiles, da visão.
  *     id . ID do Evento. Não precisa definir caso queira usar no evento
  * onde está sendo chamado o comando.
  * ===========================================================================
  * this.sArea(distance, id)  Verifica em forma de área.
  * this.sFront(distance, id) Verifica se está em baixo do evento.
  * this.sAgo(distance, id) Verifica se está em cima do evento.
  * this.sLeft(distance, id) Verifica se está à esquerda do evento.
  * this.sRight(distance, id) Verifica se está à direita do evento.
  * this.sAbout(id) Verifica se está sobre o evento.
  * this.sCross(distance, id) Verifica em forma de cruz.
  * this.sVision(distance, id) Verifica se está somente na visão do evento.
  * this.sBehind(distance, id) Verifica se está somente atrás do evento.
  * this.vLeft(distance, id) Verifica se está somente à esquerda do evento.
  * this.vRight(distance, id) Verifica se está somente à direita do evento.
  * this.dRight(distance, id) Verifica se está na direita-superior do evento.
  * this.dLeft(distance, id) Verifica se está na esquerda-superior do evento.
  * this.iRight(distance, id) Verifica se está na direita-inferior do evento.
  * this.iLeft(distance, id) Verifica se está na esquerda-inferior do evento.
  * this.sDiagonal(distance, id) Verifica de todos os lados na diagonal.
  * this.vDiagonal(distance, id) Verifica se está na visão do evento, na diagonal.
  * this.sCircle(distance, id) Verifica em forma de círculos.

  * ===========================================================================
*/
//=============================================================================
// English:Plugin
//=============================================================================
/*:en-US
* @author Kvothe
* @plugindesc  Add system of sensor in the events.
*
* @help
* Contact:
*     email dax-soft@live.com
*     website http://www.dax-soft.weebly.com
* ===========================================================================
* Commands: Use the commands in the conditions; using the command of the Script.
* ===========================================================================
* Values .
*     distance : Distance in tiles.
*     id : Event ID. No need to set if you want to use in the event
* which is being called the command.
* ===========================================================================
* this.sArea(distance, id)  Check in form of the area
* this.sFront(distance, id) Sensor who checks if it's in down of the event
* this.sAgo(distance, id) Sensor who checks if it's in up of the event
* this.sLeft(distance, id) Sensor who checks if it's in left of the event
* this.sRight(distance, id) Sensor who checks if it's in right of the event
* this.sAbout(id) Sensor who checks if it's about the event
* this.sCross(distance, id) Sensor who checks in form of the cross
* this.sVision(distance, id) Sensor who checks if it's only in vision of the event
* this.sBehind(distance, id) Sensor who checks if it's just behind of the event
* this.vLeft(distance, id) Sensor who checks if it's just the left of event
* this.vRight(distance, id) Sensor who checks if it's just the right of event
* this.dRight(distance, id) Sensor who checks if it's in the right-upper of event.
* this.dLeft(distance, id) Sensor who checks if it's in the left-upper of event.
* this.iRight(distance, id) Sensor who checks if it's in the right-bottom of event.
* this.iLeft(distance, id) Sensor who checks if it's in the left-bottom of event
* this.sDiagonal(distance, id) Sensor who checks if it's in all side on diagonal
* this.vDiagonal(distance, id) Sensor who checks if it's vision diagonal according with event.
* this.sCircle(distance, id) Sensor who checks if it's in form of circle

* ===========================================================================
*/
(function($) {
  'use strict';
  /**
   * Retorna ao setting do evento.
   *
   * @method eventMap
   * @param eventId {Number} O ID do evento.
   * @param defaultEventID {Number} ID do evento padrão.
   * @return {Object} : Retorna ao objeto da classe do Evento.
   */
  $.eventMap = function(eventId, defaultEventID) {
    return $gameMap.event(eventId == null ? Number(defaultEventID) : Number(eventId));
  }
  /**
   * Verifica em forma de área(bloco).
   *
   * @method sArea
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sArea = function(distance, eventId) {
    var _event = $.eventMap(eventId, this._eventId);
    return ( ( Math.abs($gamePlayer.x - _event.x) + Math.abs($gamePlayer.y - _event.y) ) <= Math.abs(distance) );
  };
  /**
   * Verifica se está em cima do evento.
   *
   * @method sAbout
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sAbout = function(eventId) {
    // body...
    var _event = $.eventMap(eventId, this._eventId);
    if ( $gamePlayer.x == _event.x && $gamePlayer.y == _event.y ) return true;
    return false;
  };
  /**
   * Verifica se está ao lado direito do evento.
   *
   * @method sRight
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sRight = function (distance, eventId) {
    // body...
    var _event = $.eventMap(eventId, this._eventId);
    if ($gamePlayer.y == _event.y) {
      for (var i = _event.x + 1; i < _event.x + Math.abs(distance); i++) {
        if (!$gameMap.isPassable(i, _event.y, 6)) break;
        if ($gamePlayer.x == i) return true;
      }
    }
    return false;
  };
  /**
   * Verifica se está ao lado esquerdo do evento.
   *
   * @method sLeft
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sLeft = function (distance, eventId) {
    // body...
    var _event = $.eventMap(eventId, this._eventId);
    if ($gamePlayer.y == _event.y) {
      for (var i = _event.x + 1; i < _event.x + Math.abs(distance); i++) {
        if (!$gameMap.isPassable(i, _event.y, 6)) break;
        if ($gamePlayer.x == i - distance) return true;
      }
    }
    return false;
  };
  /**
   * Verifica se está atrás do evento.
   *
   * @method sAgo
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sAgo = function (distance, eventId) {
    // body...
    var _event = $.eventMap(eventId, this._eventId);
    if (($gamePlayer.x == _event.x)) {
      for (var i = _event.y; i > _event.y - distance-1; i--) {
        if ($gameMap.isPassable(_event.x, i, 8))
          if ($gamePlayer.y == i) return true;
      }
    }
    return false;
  };
  /**
   * Verifica se está em frente ao evento.
   *
   * @method sFront
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sFront = function (distance, eventId) {
    // body...
    var _event = $.eventMap(eventId, this._eventId);
    if (($gamePlayer.x == _event.x)) {
      for (var i = _event.y; i > _event.y - distance-1; i--) {
        if ($gameMap.isPassable(_event.x, i, 8))
          if ($gamePlayer.y == i+distance) return true;
      }
    }
    return false;
  };
  /**
   * Verifica em forma de cruz.
   *
   * @method sCross.
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
  Game_Interpreter.prototype.sCross = function (distance, eventId) {
    // body...
    return ( this.sFront(distance, eventId) || this.sAgo(distance, eventId) ||
             this.sRight(distance, eventId) || this.sLeft(distance, eventId))
  };
  /**
   * Verifica de acordo com a visão do evento.
   *
   * @method sVision
   * @param distance {Number} Distância.
   * @param eventId {Number} ID do evento.
   * @return {Boolean}
   */
   Game_Interpreter.prototype.sVision = function (distance, eventId) {
     // body...
     switch  ( ($.eventMap(eventId, this._eventId)).direction() ) {
       case 2:
         return this.sFront(distance, eventId);
       case 4:
         return this.sLeft(distance, eventId);
       case 6:
         return this.sRight(distance, eventId);
       case 8:
         return this.sAgo(distance, eventId);
       default:
         break;
     }
   };
   /**
    * Verifica se está somente atrás do evento
    *
    * @method sBehind
    * @param distance {Number} Distância.
    * @param eventId {Number} ID do evento.
    * @return {Boolean}
    */
    Game_Interpreter.prototype.sBehind = function (distance, eventId) {
      // body...
      switch  ( ($.eventMap(eventId, this._eventId)).direction() ) {
        case 8:
          return this.sFront(distance, eventId);
        case 6:
          return this.sLeft(distance+1, eventId);
        case 4:
          return this.sRight(distance+1, eventId);
        case 2:
          return this.sAgo(distance, eventId);
        default:
          break;
      }
    };
    /**
     * Verifica se está somente à esquerda do evento.
     *
     * @method vLeft
     * @param distance {Number} Distância.
     * @param eventId {Number} ID do evento.
     * @return {Boolean}
     */
     Game_Interpreter.prototype.vLeft = function (distance, eventId) {
       // body...
       switch  ( ($.eventMap(eventId, this._eventId)).direction() ) {
         case 4:
           return this.sFront(distance, eventId);
         case 8:
           return this.sLeft(distance+1, eventId);
         case 2:
           return this.sRight(distance+1, eventId);
         case 6:
           return this.sAgo(distance, eventId);
         default:
           break;
       }
     };
     /**
      * Verifica se está somente à direita do evento.
      *
      * @method vRight
      * @param distance {Number} Distância.
      * @param eventId {Number} ID do evento.
      * @return {Boolean}
      */
      Game_Interpreter.prototype.vRight = function (distance, eventId) {
        // body...
        switch  ( ($.eventMap(eventId, this._eventId)).direction() ) {
          case 4:
            return this.sFront(distance, eventId);
          case 2:
            return this.sLeft(distance+1, eventId);
          case 8:
            return this.sRight(distance+1, eventId);
          case 6:
            return this.sAgo(distance, eventId);
          default:
            break;
        }
      };
      /**
       * Verifica se está ao lado esquerdo-superior na diagonal.
       *
       * @method dLeft
       * @param distance {Number} Distância.
       * @param eventId {Number} ID do evento.
       * @return {Boolean}
       */
       Game_Interpreter.prototype.dLeft = function (distance, eventId) {
         var _event = $.eventMap(eventId, this._eventId);
         for (var i = 0; i < distance+1; i++) {
           if ( ($gamePlayer.x == (_event.x - i) ) && ($gamePlayer.y == (_event.y - i) ) )
            return true;
         }
         return false;
       };

       /**
        * Verifica se está ao lado direito-superior na diagonal.
        *
        * @method dRight
        * @param distance {Number} Distância.
        * @param eventId {Number} ID do evento.
        * @return {Boolean}
        */
        Game_Interpreter.prototype.dRight = function (distance, eventId) {
          var _event = $.eventMap(eventId, this._eventId);
          for (var i = 0; i < distance+1; i++) {
            if ( ($gamePlayer.x == (_event.x + i) ) && ($gamePlayer.y == (_event.y - i) ) )
             return true;
          }
          return false;
        };
        /**
         * Verifica se está ao lado esquerdo-inferior na diagonal.
         *
         * @method iLeft
         * @param distance {Number} Distância.
         * @param eventId {Number} ID do evento.
         * @return {Boolean}
         */
         Game_Interpreter.prototype.iLeft = function (distance, eventId) {
           var _event = $.eventMap(eventId, this._eventId);
           for (var i = 0; i < distance+1; i++) {
             if ( ($gamePlayer.x == (_event.x - i) ) && ($gamePlayer.y == (_event.y + i) ) )
              return true;
           }
           return false;
         };
         /**
          * Verifica se está ao lado direito-inferior na diagonal.
          *
          * @method iRight
          * @param distance {Number} Distância.
          * @param eventId {Number} ID do evento.
          * @return {Boolean}
          */
          Game_Interpreter.prototype.iRight = function (distance, eventId) {
            var _event = $.eventMap(eventId, this._eventId);
            for (var i = 0; i < distance+1; i++) {
              if ( ($gamePlayer.x == (_event.x + i) ) && ($gamePlayer.y == (_event.y + i) ) )
               return true;
            }
            return false;
          };
          /**
           * Verifica se a diagonal em todos os lados
           *
           * @method sDiagonal
           * @param distance {Number} Distância.
           * @param eventId {Number} ID do evento.
           * @return {Boolean}
           */
           Game_Interpreter.prototype.sDiagonal = function (distance, eventId) {
             return ( this.dLeft(distance, eventId) || this.dRight(distance, eventId) ||
                      this.iLeft(distance, eventId) || this.iRight(distance, eventId));
           };
           /**
            * Verifica a diagonal de acordo com a visão do evento.
            *
            * @method vDiagonal
            * @param distance {Number} Distância.
            * @param eventId {Number} ID do evento.
            * @return {Boolean}
            */
            Game_Interpreter.prototype.vDiagonal = function (distance, eventId) {
              // body...
              switch  ( ($.eventMap(eventId, this._eventId)).direction() ) {
                case 2:
                  return (this.iLeft(distance, eventId) || this.iRight(distance, eventId));
                case 4:
                  return (this.dLeft(distance, eventId) || this.iLeft(distance, eventId));
                case 6:
                  return (this.dRight(distance, eventId) || this.iRight(distance, eventId));
                case 8:
                  return (this.dLeft(distance, eventId) || this.dRight(distance, eventId));
                default:
                  break;
              }
            };
            /**
             * Verifica em forma de círculo.
             *
             * @method sCircle
             * @param distance {Number} Distância.
             * @param eventId {Number} ID do evento.
             * @return {Boolean}
             */
             Game_Interpreter.prototype.sCircle = function (distance, eventId) {
               var _distance = distance < 2 ? 2 : distance;
               return ( this.sDiagonal(_distance - 1, eventId) || this.sCross(_distance, eventId) );
             };
})(Kvothe.UltimateSensorEvent);
Imported["UltimateSensorEvent"] = true;

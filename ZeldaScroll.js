//=============================================================================
// ZeldaScroll
// Author: Kvothe
// Original Author: Gab!
// Version: 1.0.0
//=============================================================================
var Imported = Imported || {};
var Kvothe = Kvothe || {};
Kvothe.ZeldaScroll = {};
'use strict';
/*:
  * @plugindesc Permite fazer com que o scroll do mapa fique igual ao de Zelda, onde deve-se
chegar ao fim da tela para que ela role e mostre a próxima parte do mapa.
  * @author Kvothe & Gab!
  *
  * @param Speed
  * @desc Velocidade do scroll
  * @default 7
  *
  * @param Stop Layer
  * @desc Parar player enquanto o scroll da tela ocorre? 0 - false; 1 - true
  * @default 1
  *
  * @help
  *   Caso tenha dúvidas, contate os seguintes meios:
  *     email: dax-soft@live.com
  *     website: http://www.dax-soft.weebly.com
*/
(function($) {
  // parameters variables
  $.Parameters = PluginManager.parameters('ZeldaScroll');
  $.Param = $.Param || {};
  // setup of variables
  $.Param.Speed = Number($.Parameters["Speed"] || 7);
  $.Param.StopLayer = Number($.Parameters['Stop Layer'] || 1)
  // Game_Player:centerX
  var oldGamePlayerCenterX = Game_Player.prototype.centerX;
  Game_Player.prototype.centerX = function() {
    oldGamePlayerCenterX.call(this);
    return (Graphics.width / $gameMap.tileWidth() - 1);
  }
  // GamePlayer:centerY
  var oldGamePlayerCenterY = Game_Player.prototype.centerY;
  Game_Player.prototype.centerY = function() {
    oldGamePlayerCenterY.call(this);
    return (Graphics.height / $gameMap.tileHeight() - 1);
  }
  // GamePlayer::updateScroll
  Game_Player.prototype.updateScroll = function(lastScrolledX, lastScrolledY) {
    var x1 = lastScrolledX;
    var y1 = lastScrolledY;
    var x2 = this.scrolledX();
    var y2 = this.scrolledY();
    if (y2 < y1) {
      if (y2 < 0)  $gameMap.startScroll(8, Graphics.height / 1, $.Param.Speed);
    } else if (y2 > this.centerY()) {
      $gameMap.startScroll(2, Graphics.height / $gameMap.tileHeight(), $.Param.Speed);
    }
    if (x2 < x1) {
      if (x2 < 0) $gameMap.startScroll(4, Graphics.width / $gameMap.tileWidth(), $.Param.Speed);
    } else if (x2 > this.centerX()) {
      $gameMap.startScroll(6, Graphics.width / $gameMap.tileWidth(), $.Param.Speed);
    }
  }
  // GamePlayer:canMove
  if ( ($.Param.StopLayer & 1) == 1 ) {
    var oldGamePlayerCanMove = Game_Player.prototype.canMove;
    Game_Player.prototype.canMove = function() {
      return oldGamePlayerCanMove.call(this) && !($gameMap.isScrolling())
    }
  }
} )(Kvothe.ZeldaScroll);

Imported['ZeldaScroll'] = true;

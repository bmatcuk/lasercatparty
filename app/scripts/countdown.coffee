"use strict"

class Countdown
  constructor: (@element) ->
    @paused = false

  start: (count, timestamp, length) ->
    @element.style.display = 'block'
    @element.textContent = ''
    @animate =
      count: count
      timestamp: timestamp
      length: length

  play: (timestamp) ->
    @animate.timestamp += (timestamp - @paused) if @animate?

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @animate? and !@paused
      if timestamp >= @animate.timestamp
        @element.classList.remove 'animate'
        if @animate.count > 0
          if @animate.count > 4
            fontFactor = 0.05
            top = 80
          else
            fontFactor = 0.2 + (1 - @animate.count) * 0.05
            top = 50 + (@animate.count - 1) * 10
          @element.style.fontSize = (@element.parentNode.clientHeight * fontFactor).toString() + 'px'
          @element.style.top = top.toString() + '%'
          @element.textContent = @animate.count.toString()
          @element.style.marginTop = (0 - @element.offsetHeight / 2.0) + 'px'
          @element.style.marginLeft = (0 - @element.offsetWidth / 2.0) + 'px'
          @element.classList.add 'animate'
          while timestamp >= @animate.timestamp
            @animate.timestamp += @animate.length
            @animate.count--
        else
          @element.style.display = 'none'
          @animate = null

module.exports = Countdown


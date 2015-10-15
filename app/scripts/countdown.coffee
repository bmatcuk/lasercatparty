"use strict"

class Countdown
  constructor: (@element) ->
    @paused = false

  start: (count, timestamp) ->
    @element.style.display = 'block'
    @animate =
      count: count
      timestamp: timestamp

  play: (timestamp) ->
    @animate.timestamp += (timestamp - @paused) if @animate?

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @animate? and !@paused
      if timestamp >= @animate.timestamp
        @element.classList.remove 'animate'
        if @animate.count >= 0
          if @animate.count is 0
            @element.textContent = 'party!'
          else
            @element.textContent = @animate.count.toString()
          @element.style.marginTop = (0 - @element.offsetHeight / 2.0) + 'px'
          @element.style.marginLeft = (0 - @element.offsetWidth / 2.0) + 'px'
          @element.classList.add 'animate'
          @animate.timestamp += 1000
          @animate.count--
        else
          @element.style.display = 'none'
          @animate = null

module.exports = Countdown


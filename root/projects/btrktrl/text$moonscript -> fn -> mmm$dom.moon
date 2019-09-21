import div, h3, p, a from require 'mmm.dom'
import link_to from (require 'mmm.mmmfs.util') require 'mmm.dom'

=>
  text = (...) ->
    div with for text in *{...}
        p text
      .style = { 'max-width': '900px' }

  filtered_block = (pattern) ->
    div with for child in *@children
        continue unless (child\gett 'name: alpha')\match pattern

        div {
          style: {
             display: 'inline-block'
             width: '500px'
             margin: '0.5em'
             padding: '0.4em 1em'
             background: 'var(--gray-bright)'
          }
          div (link_to child), style: { 'margin-bottom': '0.2em' }
          child\gett 'mmm/dom'
          (child\get 'description: mmm/dom')
        }

      .style = {
        display: 'flex'
        'flex-wrap': 'wrap'
        'align-items': 'flex-start'
        margin: '-0.5em'
      }

  div {
    h3 @gett 'name: alpha'
    text "For this project I am builiding a modular, FPGA powered MIDI/OSC Control Surface.",
         "The setup consists of an arduino MCU as a master controller, that communicates to the PC over
          SLIP-encoded Serial OSC messages. The controller talks to daughterboards over SPI.
          Each daugherboard contains a rotary encoder, 8 RGB LEDs and does capacitive sensing on the knob.",
         "This was the first time I worked with an FPGA, and the first time I designed my own PCBs as well.
          The FPGA I used is an ICE40UP5k, it was targeted using the icestorm open toolchain and Verilog.
          I started by prototyping using an UPduino v2 Prototyping board (orange), and my failed rev1 PCBs (green).
          On the FPGAs I implemented capacitive sensing, the SPI slave and control logic before moving on."

    filtered_block '^proto_'

    text "Once I got everything working there I designed my custom boards with the FPGA integrated directly,
          including power conditioning and configuration.
          There is also a busboard that manages SPI addressing / multiplexing as well as latching the power state
          for each daughterboard, so that they can be started and configured individually."

    filtered_block '^pcb_glamour'
    filtered_block '^pcb_dev'

    text "The daughterboards and controller communicate over a custom SPI protocol I designed.
          The controller configures the daughterboards on boot or request from the PC.
          It sends and receives OSC messages over SLIP-encoded Serial.
          On the PC a small nodejs application relays the OSC messages over UDP or WebSocket,
          so that native and web applications can consume them and interact with the control surface."

    filtered_block '^pcb_osc'
  }

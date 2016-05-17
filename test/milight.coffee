should = require 'should'
{ env } = require './app_stub/env'
{ loadPluginWithEnvAndConfig } = require './app_stub/framework'
{ DriverStub } = require './driver_stubs/milight'
nodeMilight = require 'node-milight-promise'

describe 'Milight', ->
  device = null

  config =
    id: 'some_id'
    name: 'some_name'
    class: 'Milight'
    addr: '127.0.0.1'
    zone: 1

  beforeEach ->
    device = loadPluginWithEnvAndConfig env, 'Milight', config
    DriverStub.reset()

    # set default state
    device.mode = false
    device.color = ''
    device.power = false
    device.brightness = 100


  describe '#getPower', ->
    it 'should return the current power state (off by default)', (done) ->
      device.getPower().then (power) ->
        power.should.equal false
        done()

  describe '#getMode', ->
    it 'should return the current power state (white (false) by default)', (done) ->
      device.getMode().then (mode) ->
        mode.should.equal false
        done()

  describe '#turnOn', ->
    it 'should send the corresponding driver commands', ->
      device.turnOn()

      DriverStub.sendCommands.calledThrice.should.equal true
      # switch on the device
      DriverStub.sendCommands.firstCall.args[0].should.eql nodeMilight.commands.rgbw.on(config.zone)
      # set device into white mode
      DriverStub.sendCommands.secondCall.args[0].should.eql nodeMilight.commands.rgbw.whiteMode(config.zone)
      # set brightness
      DriverStub.sendCommands.thirdCall.args[0].should.eql nodeMilight.commands.rgbw.brightness(device.brightness)

  describe '#turnOff', ->
    it 'should send the corresponding driver commands', ->
      device.turnOff()
      DriverStub.sendCommands.calledOnce.should.equal true
      DriverStub.sendCommands.firstCall.args[0].should.eql nodeMilight.commands.rgbw.off(config.zone)

  describe '#toggle', ->
    it 'should switch the power state to ON when it is OFF before', ->
      device.power = false
      device.toggle()

      DriverStub.sendCommands.calledThrice.should.equal true
      # just check that switch ON command is fired
      DriverStub.sendCommands.firstCall.args[0].should.eql nodeMilight.commands.rgbw.on(config.zone)

    it 'should switch the power state to OFF when it is ON before', ->
      device.power = true
      device.toggle()

      DriverStub.sendCommands.calledOnce.should.equal true
      DriverStub.sendCommands.firstCall.args[0].should.eql nodeMilight.commands.rgbw.off(config.zone)

  describe '#setWhite', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setWhite()

      DriverStub.sendCommands.calledTwice.should.equal true
      # first switch device to white mode
      DriverStub.sendCommands.firstCall.args[0].should.eql nodeMilight.commands.rgbw.whiteMode(config.zone)
      # second switch on (first argument) and set brightness (second argument)
      DriverStub.sendCommands.secondCall.args[0].should.eql nodeMilight.commands.rgbw.on(config.zone)
      DriverStub.sendCommands.secondCall.args[1].should.eql nodeMilight.commands.rgbw.brightness(device.brightness)

  describe '#setColor', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setColor('#AAAAAA')

      DriverStub.sendCommands.calledOnce.should.equal true
      DriverStub.sendCommands.firstCall.args.should.eql [
        nodeMilight.commands.rgbw.on(config.zone)
        nodeMilight.commands.rgbw.rgb255(Number('0xAA'), Number('0xAA'), Number('0xAA'))
      ]

    context 'device power is "off"', ->
      # Command will be ignored when device is off
      # TODO: clarify if this behavior is intended
      it.skip 'should call the corresponding driver method', ->
        device.power = false
        device.setColor('#AAAAAA')

        DriverStub.sendCommands.calledOnce.should.equal true
        DriverStub.sendCommands.firstCall.args.should.eql [
          nodeMilight.commands.rgbw.on(config.zone)
          nodeMilight.commands.rgbw.rgb255(Number('0xAA'), Number('0xAA'), Number('0xAA'))
        ]

  describe '#setBrightness', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setBrightness(50)

      DriverStub.sendCommands.calledOnce.should.equal true
      DriverStub.sendCommands.firstCall.args.should.eql [
        nodeMilight.commands.rgbw.on(config.zone)
        nodeMilight.commands.rgbw.brightness(50)
      ]

  describe '#changeDimlevelTo', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.changeDimlevelTo(50)

      DriverStub.sendCommands.calledOnce.should.equal true
      DriverStub.sendCommands.firstCall.args.should.eql [
        nodeMilight.commands.rgbw.on(config.zone)
        nodeMilight.commands.rgbw.brightness(50)
      ]

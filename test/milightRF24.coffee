should = require 'should'
{ env } = require './app_stub/env'
{ loadPluginWithEnvAndConfig } = require './app_stub/framework'
{ DriverStub } = require './driver_stubs/milightRF24'

describe 'MilightRF24', ->
  device = null

  config =
    id: 'some_id'
    name: 'some_name'
    class: 'MilightRF24'
    port: '/dev/ttyUSB1'
    zones: [
      {
        addr: '5927'
        zone: 0
        send: true
        receive: true
      },
      {
        addr: '485D'
        zone: 0
        send: true
        receive: true
      },
      {
        addr: '1111'
        zone: 0
        send: false
        receive: true
      }
    ]

  beforeEach ->
    device = loadPluginWithEnvAndConfig env, 'MilightRF24', config
    DriverStub.reset()

    # set default state
    device.mode = 'WHITE'
    device.color = ''
    device.power = false
    device.brightness = 100

  describe '#getPower', ->
    it 'should return the current power state (off by default)', (done) ->
      device.getPower().then (power) ->
        console.log power
        power.should.equal false
        done()

  describe '#getMode', ->
    it 'should return the current power state (white (false) by default)', (done) ->
      device.getMode().then (mode) ->
        mode.should.equal 'WHITE'
        done()

  describe '#turnOn', ->
    it 'should send the corresponding driver commands', ->
      device.turnOn()

      DriverStub.sendButton.calledTwice.should.equal true

      DriverStub.sendButton.firstCall.args.should.eql [ '5927', 0, 1, false ]
      DriverStub.sendButton.secondCall.args.should.eql [ '485D', 0, 1, false ]

  describe '#turnOff', ->
    it 'should send the corresponding driver commands', ->
      device.turnOff()

      DriverStub.sendButton.calledTwice.should.equal true

      DriverStub.sendButton.firstCall.args.should.eql [ '5927', 0, 2, false ]
      DriverStub.sendButton.secondCall.args.should.eql [ '485D', 0, 2, false ]

  describe '#toggle', ->
    it 'should switch the power state to ON when it is OFF before', ->
      device.power = false
      device.toggle()

      DriverStub.sendButton.calledTwice.should.equal true

      DriverStub.sendButton.firstCall.args.should.eql [ '5927', 0, 1, false ]
      DriverStub.sendButton.secondCall.args.should.eql [ '485D', 0, 1, false ]

    it 'should switch the power state to OFF when it is ON before', ->
      device.power = true
      device.toggle()

      DriverStub.sendButton.calledTwice.should.equal true

      DriverStub.sendButton.firstCall.args.should.eql [ '5927', 0, 2, false ]
      DriverStub.sendButton.secondCall.args.should.eql [ '485D', 0, 2, false ]

  describe '#setWhite', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setWhite()

      DriverStub.sendButton.calledTwice.should.equal true

      DriverStub.sendButton.firstCall.args.should.eql [ '5927', 0, 1, true ]
      DriverStub.sendButton.secondCall.args.should.eql [ '485D', 0, 1, true ]

  describe '#setColor', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setColor('#AAAAAA')

      DriverStub.setColor.calledTwice.should.equal true

      DriverStub.setColor.firstCall.args.should.eql [ '5927', 0, 170, 170, 170 ]
      DriverStub.setColor.secondCall.args.should.eql [ '485D', 0, 170, 170, 170 ]

    context 'device power is "off"', ->
      # Command will be ignored when device is off
      # TODO: clarify if this behavior is intended
      it.skip 'should call the corresponding driver method', ->
        device.power = false
        device.setColor('#AAAAAA')

        DriverStub.setColor.calledTwice.should.equal true

        DriverStub.setColor.firstCall.args.should.eql [ '5927', 0, 170, 170, 170 ]
        DriverStub.setColor.secondCall.args.should.eql [ '485D', 0, 170, 170, 170 ]

  describe '#setBrightness', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.setBrightness(50)

      DriverStub.setBrightness.calledTwice.should.equal true

      DriverStub.setBrightness.firstCall.args.should.eql [ '5927', 0, 50 ]
      DriverStub.setBrightness.secondCall.args.should.eql [ '485D', 0, 50 ]

    context 'device power is "off"', ->
      # Command will be ignored when device is off
      # TODO: clarify if this behavior is intended
      it.skip 'should call the corresponding driver method', ->
        device.power = false
        device.setBrightness(50)

        DriverStub.setBrightness.calledTwice.should.equal true

        DriverStub.setBrightness.firstCall.args.should.eql [ '5927', 0, 50 ]
        DriverStub.setBrightness.secondCall.args.should.eql [ '485D', 0, 50 ]

  describe '#changeDimlevelTo', ->
    it 'should call the corresponding driver method', ->
      device.power = true
      device.changeDimlevelTo(50)

      DriverStub.setBrightness.calledTwice.should.equal true

      DriverStub.setBrightness.firstCall.args.should.eql [ '5927', 0, 50 ]
      DriverStub.setBrightness.secondCall.args.should.eql [ '485D', 0, 50 ]

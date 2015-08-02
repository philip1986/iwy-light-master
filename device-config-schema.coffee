# #led-light-plugin configuration options
module.exports = {
  title: "Led light device config schemas"
  LedLight: {
    title: "LedLight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
  },
  Milight: {
    title: "Milight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
      zone:
        description: "Zone [0 - 4], 0 = switches all zones"
        type: "number"
  },
  MilightRF24: {
    title: "Milight"
    type: "object"
    properties:
      zones:
        description: "The switch protocols to use."
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            addr:
              description: "Address of light device"
              type: "string"
            zone:
              description: "Zone [0 - 4], 0 = switches all zones"
              type: "number"
            send:
              description: "Send commands using this address and zone"
              type: "boolean"
              default: true
            receive:
              description: "Respond on received commands using this address and zone"
              type: "boolean"
              default: true
  },
  Wifi370: {
    title: "LedLight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
  },
  Blinkstick: {
    title: "BlinkStick"
    type: "object"
    properties:
      serial:
        description: "serial of Blinkstick"
        type: "string"
        default: ""
  }
}

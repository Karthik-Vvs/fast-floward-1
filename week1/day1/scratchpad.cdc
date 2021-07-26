pub struct Canvas {

  pub let width: UInt8
  pub let height: UInt8
  pub let pixels: String

  init(width: UInt8, height: UInt8, pixels: String) {
    self.width = width
    self.height = height
    // The following pixels
    // 123
    // 456
    // 789
    // should be serialized as
    // 123456789
    self.pixels = pixels
  }
}

pub fun serializeStringArray(_ lines: [String]): String {
  var buffer = ""
  for line in lines {
    buffer = buffer.concat(line)
  }

  return buffer
}

pub resource Picture {

  pub let canvas: Canvas
  
  init(canvas: Canvas) {
    self.canvas = canvas
  }
}

pub fun main() {
  let pixelsX = [
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]
  let canvasX = Canvas(
    width: 5,
    height: 5,
    pixels: serializeStringArray(pixelsX)
  )
  let canvasY = Canvas(
    width: 5,
    height: 5,
    pixels: serializeStringArray(pixelsX)
  )

  let letterX <- create Picture(canvas: canvasX)
  destroy letterX

  let printer <- create Printer()
  let printerX <- printer.print(canvas: canvasX)
  let printerY <- printer.print(canvas: canvasY)
  let printerZ <- printer.print(canvas: canvasX)

  destroy printerX 
  destroy printerY 
  destroy printerZ 
  destroy printer
}

pub fun display(canvas: Canvas) {
  let n = canvas.pixels.length
  let offset = 5
  var i = 0
  log("+-----+");
  while i < n {
    log("|".concat(canvas.pixels.slice(from: i, upTo: i + offset)).concat("|"))
    i = i + offset
  }
  log("+-----+");
}

pub resource Printer {
  priv var resourceCreated:{String:Bool}
  priv var printCount:UInt8
  pub fun print(canvas: Canvas): @Picture? {
    self.printCount = self.printCount + 1
    if(self.resourceCreated.containsKey(canvas.pixels)){  
      // log(self.printCount)
      display(canvas: canvas)
      return nil
    }
    self.resourceCreated[canvas.pixels] = true
    return <- create Picture(canvas: canvas)
  }

  init() {
    self.resourceCreated = {}
    self.printCount = 0
  }
}
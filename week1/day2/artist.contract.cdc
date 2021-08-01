pub contract Artist {
  pub struct Canvas {

    pub let width: Int
    pub let height: Int
    pub let pixels: String

    init(width: Int, height: Int, pixels: String) {
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

  pub resource Picture {

    pub let canvas: Canvas
    pub let id: String    
    init(canvas: Canvas) {
      self.canvas = canvas
      self.id = canvas.pixels
    }
  }

  pub resource Printer {

    pub let width: Int
    pub let height: Int
    pub let prints: {String: Canvas}

    init(width: Int, height: Int) {
      self.width = width;
      self.height = height;
      self.prints = {}
    }

    pub fun print(canvas: Canvas): @Picture? {
      // Canvas needs to fit Printer's dimensions.
      if canvas.pixels.length != Int(self.width * self.height) {
        return nil
      }

      // Canvas can only use visible ASCII characters.
      for symbol in canvas.pixels.utf8 {
        if symbol < 32 || symbol > 126 {
          return nil
        }
      }

      // Printer is only allowed to print unique canvases.
      if self.prints.containsKey(canvas.pixels) == false {
        let picture <- create Picture(canvas: canvas)
        self.prints[canvas.pixels] = canvas

        return <- picture
      } else {
        return nil
      }
    }
  }

  // Quest W1Q3
  pub resource Collection {
    pub let pictures: @[Picture]

    pub fun deposit(picture: @Picture) {
      self.pictures.append(<-picture)
    }

    pub fun getCanvases(): [Canvas] {
        let canvases: [Canvas] = []
        var index = 0
        while(index < self.pictures.length) {
            canvases.append(self.pictures[index].canvas)
            index = index + 1
        }
        return canvases
    }

    init() {
      self.pictures <- []
    }

    destroy() {
      destroy self.pictures
    }
  }
  pub fun createCollection(): @Collection {
    return <- create Collection()
  }

  init() {
    self.account.save(
      <- create Printer(width: 5, height: 5),
      to: /storage/ArtistPicturePrinter
    )
    self.account.link<&Printer>(
      /public/ArtistPicturePrinter,
      target: /storage/ArtistPicturePrinter
    )
  }
}

import Artist from 0x02

transaction() {
  
  let pixels: String
  let picture: @Artist.Picture?

  prepare(account: AuthAccount) {
    let printerRef = getAccount(0x02)
      .getCapability<&Artist.Printer>(/public/ArtistPicturePrinter)
      .borrow()
      ?? panic("Couldn't borrow printer reference.")
    
    // Replace with your own drawings.
    self.pixels = "*   * * *   *   * * *   *"
    let canvas = Artist.Canvas(
      width: printerRef.width,
      height: printerRef.height,
      pixels: self.pixels
    )
    
    self.picture <- printerRef.print(canvas: canvas)
  }

  execute {
   let collectionRef = getAccount(0x02)
      .getCapability<&Artist.Collection>(/public/ArtistPictureCollection)
      .borrow()
      ?? panic("Couldn't borrow collection reference.")
    if (self.picture == nil) {
      log("Collection with ".concat(self.pixels).concat(" already exists!"))
      destroy self.picture
    } else {
      collectionRef.deposit(picture: <-self.picture!)
      log("Picture printed!")
    }

  }
}

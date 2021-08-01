import Artist from "./contract.cdc"

// Print a Picture and store it in the authorizing account's Picture Collection.
transaction(width: Int, height: Int, pixels: String) {
    prepare(account: AuthAccount) {
        let printerRef = account
        .getCapability<&Artist.Printer>(/public/ArtistPicturePrinter)
        .borrow() 
        ?? panic("Couldn't borrow printer reference.")

        let canvas = Artist.Canvas(
            width: width,
            height: height,
            pixels: pixels
        )
        
        let picture <- printerRef.print(canvas: canvas)

        let collectionRef = account
        .getCapability<&Artist.Collection>(/public/ArtistPictureCollection)
        .borrow()
        ?? panic("Couldn't borrow collection reference.")
        if (picture == nil) {
        log("Collection with ".concat(pixels).concat(" already exists!"))
        destroy picture
        } else {
        collectionRef.deposit(picture: <-picture!)
        log("Picture printed!")
        }
    }

}


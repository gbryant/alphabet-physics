# alphabet-physics
iOS Tech demo coded in 2013

The main focus was taking an arbitrary font and turning the glyphs into physics objects that could be rendered with OpenGL.  
On Apple's iOS it turned out to be rather complicated to get the set of points that define a font.  
The solution was to use CTFontCreatePathForGlyph and then provide a callback function to interpolate the points generated by CGPathApply.  

This is the only version to survive a hard drive crash. The newer lost one had the letters exploding and word joints being breakable.  

The following screenshot has debug drawing turned on which shows the underlying polygons of the letters.

![Screenshot 1](/screenshots/alphabet.png)

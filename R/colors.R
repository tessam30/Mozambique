# Purpose: Create custom color palettes for ArcMap
# By; Tim Essam
# Date: 2016/12/30


### Backing out RGB values for Viridis or media colors
library(viridis)
library(grDevices)

# Set the number of colors
  n = 16
  
  # The viridis library has four functions to return hex colors
  col2rgb(viridis(5, alpha = 1, begin = 0, end = 1))
  

  # to print w/out quotes
  ramp <- substr(viridis(n, alpha = 1, begin = 0, end = 1), 2, 7)
  cat(ramp, sep = "\n")

  # Collected color palettes
  nprGr <- c("#C94825",	"#ECB374",	"#EBE1BD",	"#61BDAB",	"#367C79")
  nprContU <- c("#EBE1BD",	"#61BDAB",	"#367C79")
  nprContL <- c("#C94825",	"#ECB374",	"#EBE1BD")
  waPoPrGr <- c("#B43093",	"#B13897",	"#C96DB6",	"#DCA9D4",	"#F6E4F2",
                "#FBFBF9",	"#FFFFFF",	"#D9E0CE",	"#BAC7A9",	"#98B072",
                "#7A9A4F",	"#4F781A",	"#527A19")
  nytYellow <- c("#F1F0EE", "#FEE7C2", "#FFDF95", "#FFD66D", "#FFCC42")
  wapOrange <- c("#FF830D", "#FFC487", "#F3EDBA", "#F2F2EB")
  propubBuGr <- c("#DBD8D3", "#B8CCDF", "#3AACCC", "#008EBA", "#005F86")
  fdPur   <- c("#DCE5EB", "#D7D6D9", "#D4B9BD", "#CD909B", "#C25F73", "#A7054C")
  
    # To interpolate colors in R, use the colorRampPalette function 
  npr_pal <- colorRampPalette(nprGr, space = "rgb")
  npr_pal(n)
  cat(npr_pal(n), sep = "\n")
  
  nytPink <- c("#FFF7F5",	"#FFDEDD",	"#FCC6BC",	"#F8A0B6",	"#FA66A0",	"#DE3497",	"#AD0084",	"#7C0175")

  # Call colors as rgb using 16 breaks
  col2rgb(npr_pal(n))
  
  # Use example code to show what full interpolations would look like
  # n = 200
  # image(
  #   1:n, 1, as.matrix(1:n),
  #   col = nyt_pal(n),
  #   xlab = "nytimes", ylab = "", xaxt = "n", yaxt = "n", bty = "n"
  # )
  
  
 # Function to preview color ramps
  # x = length of interpolation
  # y = vector of colors to be interpolated and viewed
  preview_color <- function(y, x = 7) {
    
    # First, create a function based on the color palette input vector
    cust_pal <- colorRampPalette(y)
   
    title = deparse(substitute(y))
    
        # Plot the results
    image(
      1:x, 1, as.matrix(1:x),
      col = cust_pal(x),
      xlab = title, ylab = "", yaxt = "n", bty = "n")
    
    # Return the rbg values
    col2rgb(cust_pal(x))
    
    }
  
  preview_color(nprGr, 20)
  preview_color(plasma(5, alpha = 1, begin = 0, end = 1), 20)
  preview_color(waPoPrGr, 20)
  preview_color(nytYellow, 10)
  
  # Call numbers as hsv, converting from rgb (pry a more direct way of doing this)
  rgb2hsv(col2rgb(magma(8, alpha = 0.6)))
  
library(shiny)

# Define UI for dataset viewer app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("Gaussian Process playground"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Text for providing a caption ----
            # Note: Changes made to the caption in the textInput control
            # are updated in the output area immediately as you type

            # Input: Selector for choosing dataset ----
            selectInput(inputId = "dataset",
                        label = "Choose a dataset:",
                        choices = c( "motor", "boston", "longley")),
            
            # Input: Slider for GP parameters
            sliderInput(inputId = 'sigma',
                        label = 'GP excess standard deviation parameter',
                        min = 0, max = 5, value = 1, step = 0.05),
            sliderInput(inputId = 'tau',
                        label = 'GP standard deviation parameter',
                        min = 0, max = 5, value = 1, step = 0.05),
            sliderInput(inputId = 'theta',
                        label = 'GP smoothness parameter',
                        min = 0, max = 5, value = 1, step = 0.05),
            checkboxInput("checkbox", label = " 50% Confidence intervals", 
                          value = TRUE)
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Formatted text for caption ----
            h3(textOutput("caption", container = span)),
            
            # Output: HTML table with requested number of observations ----
            plotOutput("plot"),
            
            # Output: Verbatim text for data summary ----
            verbatimTextOutput("summary"),
            
            # Output: HTML table with requested number of observations ----
            tableOutput("view")
            
        )
    )
)
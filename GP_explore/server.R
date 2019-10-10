# Define server logic to summarize and view selected dataset ----
library(tidyverse)
library(boot)
library(fields)
library(MASS)
theme_set(theme_bw())

server <- function(input, output) {
    
    # Return the requested dataset ----
    # By declaring datasetInput as a reactive expression we ensure
    # that:
    #
    # 1. It is only called when the inputs it depends on changes
    # 2. The computation and result are shared by all the callers,
    #    i.e. it only executes a single time
    datasetInput <- reactive({
        ds = switch(input$dataset,
               "motor" = motor[,1:2],
               "boston" = Boston[,c('lstat', 'medv')],
               "longley" = longley[,c('Year', 'Employed')])
        scale2 = function(x) (x - mean(x))/sd(x)
        ds2 = ds %>% mutate_all(scale2)
        colnames(ds2) = c('x','y')
        return(ds2)
    })

    # Generate a plot of the dataset ----
    output$plot <- renderPlot({
        dataset <- datasetInput()
        tau = input$tau
        sigma = input$sigma
        theta = input$theta
        
        x_new = pretty(dataset$x, n = 100)
        Sigma_new = tau^2 * Exp.cov(dataset$x, x_new,
                                    theta = theta, p = 2)
        Sigma = diag(sigma^2,nrow(dataset)) + 
            tau^2 * Exp.cov(dataset$x, dataset$x,theta = theta,
                            p = 2)
        GP_pred = tibble(
            x_new = x_new, 
            mu_pred = t(Sigma_new)%*%solve(Sigma)%*%dataset$y
        )
        
        p = ggplot(dataset, aes(x = x, y = y)) + 
                geom_point() +
                labs(title = input$dataset) + 
                geom_line(data = GP_pred, aes(x = x_new, y = mu_pred),
                          colour = 'red')
        
        if(input$checkbox) {
            Sigma_new_new = tau^2 * Exp.cov(x_new, x_new,
                                        theta = theta, p = 2)
            Sigma_pred = Sigma_new_new - 
                t(Sigma_new)%*%solve(Sigma)%*%Sigma_new
            se = sqrt(diag(Sigma_pred))
            GP_pred$lower = GP_pred$mu_pred - qnorm(0.75)*se
            GP_pred$higher = GP_pred$mu_pred + qnorm(0.75)*se
            p = p + 
                geom_line(data = GP_pred, aes(x = x_new, y = lower), 
                          linetype = 2, colour = 'red') +
                geom_line(data = GP_pred, aes(x = x_new, y = higher), 
                          linetype = 2, colour = 'red')
        }
        
        print(p)
        
    })
    
    # Show the first "n" observations ----
    # The output$view depends on both the databaseInput reactive
    # expression and input$obs, so it will be re-executed whenever
    # input$dataset or input$obs is changed

}
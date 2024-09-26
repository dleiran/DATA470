

library(shiny)
library(tibble)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()

ui <- fluidPage(
  titlePanel("FM Housing Price Predictor"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "Total.SqFt.",
        "Total Square Feet",
        min = 480,
        max = 10693,
        value = 3000,
        step = 100
      ),
      sliderInput(
        "Year.Built",
        "Year Built",
        min = 1900,
        max = 2024,
        value = 1980,
        step = 1
      ),
      actionButton(
        "predict",
        "Predict"
      )
    ),
    
    mainPanel(
      h2("House Qualities"),
      verbatimTextOutput("vals"),
      h2("Predicted House Price (USD)"),
      textOutput("pred")
    )
  )
)

server <- function(input, output) {
  log4r::info(log, "App Started")
  
  vals <- reactive(
    tibble(
      Total.SqFt. = input$Total.SqFt.,
      Year.Built = input$Year.Built,
    )
  )
  
  pred <- eventReactive(
    input$predict,
    {
      log4r::info(log, "Prediction Requested")
      r <- httr2::request(api_url) |>
        httr2::req_body_json(vals()) |>
        httr2::req_error(is_error = \(resp) FALSE) |>
        httr2::req_perform()
      log4r::info(log, "Prediction Returned")
      
      if (httr2::resp_is_error(r)) {
        log4r::error(log, paste("HTTP Error",
                                httr2::resp_status(r),
                                httr2::resp_status_desc(r)))
      }
      
      httr2::resp_body_json(r)
    },
    ignoreInit = TRUE
  )
  
  output$pred <- renderText(pred()$.pred[[1]])
  output$vals <- renderPrint(vals())
}

shinyApp(ui = ui, server = server)

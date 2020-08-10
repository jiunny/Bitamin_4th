library(ggplot2); library(dplyr)

server <- function(input, output) {
  
  #second tab(practice)----------------
  output$selected_species <- renderText({ 
    paste("You have selected", input$species, "species from iris Data")
  })
  
  #third tab(database)----------------
  df <- reactive({
    if(is.null(input$data)){
      read.csv("iris.csv")
    } else
    read.csv(input$data$datapath)
    })
  
  output$iris_df <- renderDataTable({
    df()
  })
  
  #fourth tab(EDA)-------------------
  output$xvar <- renderUI({
    selectInput('xvar','X axis',
                choices = colnames(df()),
                selected = colnames(df())[1])
  })
  output$yvar <- renderUI({
    selectInput('yvar','Y axis',choices = colnames(df()),
                selected = colnames(df())[2])
  })
  
  output$species_chk <- renderUI({
    checkboxGroupInput(inputId = "species_chk",
                       label = "Choose Species you want to see..",
                       choices = as.character(unique(df()$Species)))
  })
  
  plot <- eventReactive(input$draw,{
    
      ggplot(df() %>% filter(Species == input$species_chk),
             aes(!!sym(input$xvar),!!sym(input$yvar),
                      group=Species, col=Species))+
        geom_point()+
        theme_bw()
  })
  
  output$plot_iris <- renderPlot({
    plot()
  })
  
  #fifth tab(Modeling)----------------------------
  
  # traning_set, test_set
  
  val <- reactiveValues()
  
  ## 설명: log_model까지는 코딩해서 카페에 올려줬음. multi_logit_m을 활성화한 것이 log_model
  log_model <- reactive({
    
    set.seed(0921)
    train_idx <- sample(1:nrow(df()), nrow(df()) * 0.7 )
    test_idx <- setdiff(1:nrow(df()),train_idx)
    train <- df()[train_idx,]
    
    multi_logit_m <- multinom(Species ~ Petal.Length + Petal.Width + Sepal.Length + Sepal.Width, data = train)
   
    })
  ## 설명: 위에서 활성화한 모델을 활용하여 새로운 데이터에 대한 Species를 예측해 볼것.
  ##       이때 새로운 데이터는 사용자가 각 변수별로 input하는 값(ui에서 numericInput으로 생성)
  ##       numericInput의 값들을 학습한 데이터와 같은 형태로 만들기 위해 data.frame으로 묶음
  ##       이때 예측 모델을 앞서 활성화 시킨 log_model이기 때문에 log_model()로 적어주어야함.
  ##       predict에서 확률값으로 뽑아야 하기 때문에 type은 prob으로 지정
  ##       ui에서 지정해 주었던 각 numericInput의 inputId를 꼭 맞춰주어야함(ex. input$Petal.Length)
  
  multi_logit_p <- reactive({
    answer <- predict(log_model(), 
                      newdata = data.frame(Petal.Length= input$Petal.Length,
                                           Petal.Width = input$Petal.Width,
                                           Sepal.Length = input$Sepal.Length,
                                           Sepal.Width = input$Sepal.Width), 
                      type = "prob")
  })
  
  output$pred_species <- renderText({
    
    
    
    # multi_logit_p <- predict(log_model(), 
    #                          newdata = data.frame(Petal.Length= input$Petal.Length,
    #                                               Petal.Width = input$Petal.Width,
    #                                               Sepal.Length = input$Sepal.Length,
    #                                               Sepal.Width = input$Sepal.Width), 
    #                          type = "prob")
    
    ## 설명: 예측한 값중에서 가장 높은 확률과 그때의 Species를 뽑아야 하기 때문에 which.max함수를 이용함
    ##       확률의 가독성을 위하여 소수점 둘째자리에서 반올림 round()
    paste(round(max(multi_logit_p()),3)*100,"%  ",
           as.character(names(which.max(multi_logit_p()))))
    
  })
}






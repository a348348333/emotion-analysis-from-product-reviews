shinyServer(server <- function(input, output){
  output$caption <- renderText ({
    input$action
    print("START")
    str1 = paste('python3 project.py "', isolate(input$txt),'"',sep = "")
    print(str1)
    system(str1)
    #session$reload()
    print("END")
  })
  
  output$wordCloud <- renderPlot({
    
    input$action
    
    path = paste(isolate(lowerCase(input$txt)),"/KEY.csv",sep = "")
    kw = read.table(path, header=T, sep=",")
    
    ggplot(kw, aes(label = kw$keywords, size = as.numeric(kw$count))) +
      geom_text_wordcloud_area(rm_outside = TRUE) +
      scale_size_area(max_size = 50) +
      theme_minimal()
    
  })
  
  output$bubbles<-renderBubbles({
    
    input$action
    
    path = paste(isolate(lowerCase(input$txt)),"/KEY.csv",sep = "")
    kw = read.table(path, header=T, sep=",")
    
    tmp = head(kw, n = nrow(kw)/2)
    bubbles(value = as.numeric(tmp$relevance), label = tmp$keywords)
  })
  
  output$gauge<-renderGauge({
    
    input$action
    
    path = paste(isolate(lowerCase(input$txt)),"/NLU.csv",sep = "")
    NLU = read.table(path, header=T, sep=",")
    sum = 0
    count = 0
    for(i in 1:nrow(NLU)){
      sum = NLU$sentiment[i] * (NLU$score[i] + 1) + sum
      count = count + NLU$score[i] + 1
    }
    ans = sum / count
    
    g <- gauge(ans, min = -1, max = 1, label = NULL, sectors = gaugeSectors(success = c(0, 1), danger = c(-1, 0)))
    g
  })
  
  output$emotion<-renderPlotly({
    
    input$action
    
    path = paste(isolate(lowerCase(input$txt)),"/NLU.csv",sep = "")
    NLU = read.table(path, header=T, sep=",")
    
    p <- plot_ly(NLU, x = ~sadness, y = ~time, name = "sadness", type = 'scatter',
                 mode = "markers", marker = list(color = "pink")) %>%
      add_trace(x = ~joy, y = ~time, name = "joy",type = 'scatter',
                mode = "markers", marker = list(color = "blue")) %>%
    add_trace(x = ~fear, y = ~time, name = "fear",type = 'scatter',
              mode = "markers", marker = list(color = "yellow")) %>%
      add_trace(x = ~disgust, y = ~time, name = "disgust",type = 'scatter',
                mode = "markers", marker = list(color = "green")) %>%
      add_trace(x = ~anger, y = ~time, name = "anger",type = 'scatter',
                mode = "markers", marker = list(color = "red"))
      
  })
    
  
  output$raw <- renderTable({
    
    input$action
    
    path = paste(isolate(lowerCase(input$txt)),"/KEY.csv",sep = "")
    kw = read.table(path, header=T, sep=",")
    
    head(kw)
  })
})
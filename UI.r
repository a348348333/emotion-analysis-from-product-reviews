
shinyServer(ui <- dashboardPage(
  #skin設定顏色版顏色；dashboardHeader設定標題與標題寬度；#dashboardSidebar設定頁面側邊攔
  dashboardHeader(title = "Buyer"),
  dashboardSidebar(
    textInput("txt", "Text input:", "g502"),
    actionButton("action", "Search"),
    
    sidebarMenu(
      menuItem("Search", tabName = "Search", icon = icon("dashboard")),
      menuItem("RawData", tabName = "RawData", icon = icon("th"))
    )
    
  ),

  #dashboardBody設置頁面主文；
  #fluidRow設定輸入物件為浮動佈局，較不會因為每個仁電腦螢幕的尺寸不同，導致物件錯位；box(title,status,solidHeader,collapsible)產生方塊物件的標題、顏色、格式及是否可摺疊；
  #selectInput()設定輸入的方式為選擇勾選方式，ID是date、標籤是Date:、可勾選的選項是ETCdata中date欄位的所有資料(不重複計)

  dashboardBody(
      tabItems(
        #First tab
          tabItem(tabName = "Search",
                  fluidRow(
                    box(title = "Status",status = "primary",
                      h3(textOutput("caption", container = span))
                    )
                  ),
                  fluidRow(
                    box(title = "Word Cloud",
                        plotOutput("wordCloud", height = 500)
                    ),
                    box(title = "Bubble",
                        bubblesOutput("bubbles", width = "100%", height = 500)
                    ),
                    
                    box(title = "Pie", gaugeOutput("gauge")),
                    box(title = "Emotion", plotlyOutput("emotion"))
                  )
                  
          ),
          tabItem(tabName = "RawData",
                  fluidRow(
                    box(title = "Keywords",
                        tableOutput("raw"))
                  )
          )
      )
      
      
    )
)
)

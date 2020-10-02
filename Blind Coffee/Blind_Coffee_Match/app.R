#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


#Defining Function
do_matching <- function(record,for_matching){
    option_list <- lapply(for_matching$Serial_Number,function(x){
        already_met <- na.omit(as.numeric(record[which(record$Serial_Number==x),c(7:ncol(record))]))
        plausible_options <- setdiff(for_matching$Serial_Number,already_met)
        if(length(plausible_options)<=0){
            ouptut$selected_var <- print(paste(x,': No plausible option. Returning - all options - need intervention'))
            return(for_matching$Serial_Number)}
        team_members <- as.numeric(record$Serial_Number[which(record$Team==record$Team[which(record$Serial_Number==x)])])
        actual_options <- setdiff(plausible_options,team_members)
        if(length(actual_options)<=0){
            output$selected_var <- print(paste(x,': No action option. Returning - plausible options - need intervention'))
            return(plausible_options)}
        return(actual_options)
    })
    
    option_list <- setNames(option_list,for_matching$Serial_Number)
    
    len <- sapply(option_list, length)
    option_list<- option_list[order(len)]
    
    for(i in 1:length(option_list)){
        if(length(option_list[[i]])>1){
            match_for_i <- sample(option_list[[i]],1)
            for(j in i:length(option_list)){
                option_list[[j]]<-setdiff(option_list[[j]],c(match_for_i,as.numeric(names(option_list)[i])))
            }
            option_list[[i]] <- match_for_i
            option_list[[as.character(match_for_i)]] <- as.numeric(names(option_list)[i])
        }
    }
    
    df <- data.frame(Sr_No=names(option_list),match = unlist(option_list))
    df$match <- as.character(df$match)
    df$Email_1 <- record$Email[match(df$Sr_No,record$Serial_Number)]
    df$Email_2 <- record$Email[match(df$match,record$Serial_Number)]
    return(df)
}


ui <- fluidPage(
    titlePanel("Blind Coffee Matcher"),
    sidebarLayout(
        sidebarPanel( fileInput("Coffee_Record", "Choose CSV File with historical Record of matches for blind coffee",
                                multiple = FALSE,
                                accept = c("text/csv",
                                           "text/comma-separated-values,text/plain",
                                           ".csv")),
                      fileInput("to_be_matched", "Choose CSV file with list of people who agreed to this week blind coffee match",
                                multiple = FALSE,
                                accept = c("text/csv",
                                           "text/comma-separated-values,text/plain",
                                           ".csv")),
                      actionButton("runmatch", "Run Matcher"),
                      
        )
        ,
        mainPanel(
            dataTableOutput("contents"),
            textOutput("selected_var")
        ) ,
    )
)

server <- function(input, output, session) {
    
    datasetInput <- reactive({
        req(input$Coffee_Record,output$contents)
        
        Coffee_Record <- read.csv(input$Coffee_Record$datapath,stringsAsFactors = FALSE)
        return(datasetInput(record = Coffee_Record,df = output$contents))
    })
    
    observeEvent(input$runmatch, {
        output$contents <- renderDataTable(expr = {
            
            # input$file1 will be NULL initially. After the user selects
            # and uploads a file, head of that data file by default,
            # or all rows if selected, will be shown.
            
            req(input$Coffee_Record,input$to_be_matched)
            
            Coffee_Record <- read.csv(input$Coffee_Record$datapath,stringsAsFactors = FALSE)
            To_be_matched <- read.csv(input$to_be_matched$datapath,stringsAsFactors = FALSE)
            
            #data_print <- datasetInput(record = Coffee_Record,df = output$contents)
            return(do_matching(record = Coffee_Record,for_matching = To_be_matched))
        })
        
    })
    
    
}

shinyApp(ui = ui,server =  server)

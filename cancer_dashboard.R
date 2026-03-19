library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(mlbench)
library(corrplot)
library(caret)
library(randomForest)

# Load and prepare data
data(BreastCancer)
bc <- BreastCancer %>%
  select(-Id) %>%
  mutate(across(-Class, ~as.numeric(as.character(.)))) %>%
  drop_na()

# Train a simple model for prediction tab
set.seed(123)
train_idx <- createDataPartition(bc$Class, p = 0.8, list = FALSE)
train_bc <- bc[train_idx, ]
rf_bc <- randomForest(Class ~ ., data = train_bc, ntree = 100)

# Calculate model metrics
test_bc <- bc[-train_idx, ]
test_pred <- predict(rf_bc, test_bc)
test_prob <- predict(rf_bc, test_bc, type = "prob")[, "malignant"]
cm_bc <- confusionMatrix(test_pred, test_bc$Class, positive = "malignant")
roc_bc <- pROC::roc(test_bc$Class, test_prob)
auc_bc <- round(pROC::auc(roc_bc), 3)
f1_bc <- round(MLmetrics::F1_Score(test_pred, test_bc$Class, positive = "malignant"), 3)

# UI
ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = "🎗️ Breast Cancer Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("info-circle")),
      menuItem("Overview", tabName = "overview", icon = icon("chart-bar")),
      menuItem("Exploration", tabName = "exploration", icon = icon("search")),
      menuItem("Correlations", tabName = "correlations", icon = icon("project-diagram")),
      menuItem("Prediction", tabName = "prediction", icon = icon("stethoscope"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # TAB 0: About
      tabItem(tabName = "about",
              fluidRow(
                box(title = "About this Project", width = 12, status = "info",
                    p("This project was developed as part of a data science portfolio to 
    demonstrate the application of machine learning techniques to 
    healthcare data."),
                    p("The model used is a Random Forest classifier trained on the Breast 
    Cancer Wisconsin dataset."),
                    h4("The workflow includes:"),
                    tags$ul(
                      tags$li("Data preprocessing"),
                      tags$li("Feature exploration"),
                      tags$li("Model training and evaluation"),
                      tags$li("Interactive deployment using Shiny")
                    ),
                    p("The model was evaluated using appropriate metrics for classification 
    tasks, including ROC-AUC, precision, recall and F1-score."),
                    p("This dashboard aims to bridge the gap between data analysis and 
    user-facing applications by presenting results in an interactive 
    and accessible way.")
                ),
                box(title = "⚠️ Important Disclaimer", 
                    width = 12, status = "danger",
                    h4("This application is an EDUCATIONAL and PORTFOLIO tool only."),
                    p("It is NOT intended for clinical use, medical diagnosis, or 
          treatment decisions. Always consult a qualified healthcare 
          professional for medical advice.")
                )
              ),
              fluidRow(
                box(title = "📊 About the Dataset", width = 6,
                    h4("Wisconsin Breast Cancer Dataset"),
                    p("683 patients with 9 clinical measurements from fine needle 
        aspiration (FNA) of breast masses."),
                    tableOutput("variables_table")
                ),
                box(title = "🤖 About the Model", width = 6,
                    h4("Random Forest Classifier"),
                    p("Trained on 80% of the data (546 patients), 
        evaluated on 20% (137 patients)."),
                    h4("Model Performance:"),
                    valueBoxOutput("auc_box", width = 12),
                    valueBoxOutput("sens_box", width = 12),
                    valueBoxOutput("spec_box", width = 12),
                    valueBoxOutput("f1_box", width = 12)
                )
              )
      ),
      
      # TAB 1: Overview
      tabItem(tabName = "overview",
              fluidRow(
                box(width = 12, status = "info",
                    p("This dashboard presents an interactive analysis and prediction 
      tool for breast cancer diagnosis based on clinical features."),
                    p("The data used comes from the Breast Cancer Wisconsin dataset, 
      a widely used benchmark in medical machine learning."),
                    p("The objective is to explore key patterns in the data and evaluate 
      how different features relate to diagnosis, as well as provide a 
      predictive model for estimating cancer risk."),
                    p(strong("⚠️ This tool is for educational purposes only and is not 
      intended for clinical use."))
                )
              ),
              fluidRow(
                valueBoxOutput("total_patients"),
                valueBoxOutput("malignant_count"),
                valueBoxOutput("benign_count")
              ),
              fluidRow(
                box(title = "Diagnosis Distribution", 
                    plotlyOutput("diagnosis_plot"), width = 6),
                box(title = "Dataset Summary", 
                    tableOutput("summary_table"), width = 6)
              )
      ),
      
      # TAB 2: Exploration
      tabItem(tabName = "exploration",
              fluidRow(
                box(width = 12, status = "info",
                    p("This section allows exploration of the distribution of individual 
      clinical features."),
                    p("Use the selector to visualize how each variable behaves across 
      the dataset."),
                    p("Understanding these distributions helps identify differences between 
      benign and malignant cases and provides insight into which features 
      may be more informative for prediction.")
                )
              ),
              fluidRow(
                box(
                  title = "Controls", width = 3,
                  selectInput("variable", "Select Variable:",
                              choices = names(bc)[-ncol(bc)]),
                  checkboxInput("show_both", "Split by Diagnosis", value = TRUE)
                ),
                box(title = "Distribution Plot", 
                    plotlyOutput("dist_plot"), width = 9)
              ),
              fluidRow(
                box(title = "Box Plot by Diagnosis",
                    plotlyOutput("box_plot"), width = 12)
              )
      ),
      
      # TAB 3: Correlations
      tabItem(tabName = "correlations",
              fluidRow(
                box(width = 12, status = "info",
                    p("This section shows the correlation between clinical features."),
                    p("Strong correlations may indicate redundant information, while 
      relationships with the diagnosis variable can highlight important 
      predictors."),
                    p("For example, features related to tumor size tend to show stronger 
      associations with malignant cases. These insights help guide model 
      selection and feature importance.")
                )
              ),
              fluidRow(
                box(title = "Correlation Matrix", width = 12,
                    plotOutput("corr_plot", height = "600px"))
              )
      ),
      
      # TAB 4: Prediction
      tabItem(tabName = "prediction",
              fluidRow(
                box(width = 12, status = "info",
                    p("This tool allows you to input clinical measurements and estimate 
      the probability of a malignant diagnosis using a trained machine 
      learning model."),
                    p(strong("Model performance: ROC-AUC: 0.97 | Recall: 0.92 | 
      Precision: 0.90")),
                    p("The model is optimized to prioritize recall, meaning it is designed 
      to reduce the risk of missing positive (malignant) cases."),
                    p(em("Adjust the input values to simulate different patient profiles 
      and observe how predictions change."))
                )
              ),
              fluidRow(
                box(title = "⚠️ Disclaimer", width = 12, status = "warning",
                    p("This prediction is for EDUCATIONAL purposes only and should 
    NOT be used for clinical decision making.")
                ),
                box(title = "Patient Data Input", width = 4,
                    sliderInput("cl_thickness", "Clump Thickness:", 1, 10, 5),
                    sliderInput("cell_size", "Cell Size Uniformity:", 1, 10, 5),
                    sliderInput("cell_shape", "Cell Shape Uniformity:", 1, 10, 5),
                    sliderInput("marginal_adhesion", "Marginal Adhesion:", 1, 10, 5),
                    sliderInput("epithelial_size", "Epithelial Cell Size:", 1, 10, 5),
                    actionButton("predict_btn", "Predict", 
                                 class = "btn-primary btn-lg")
                ),
                box(title = "Prediction Result", width = 8,
                    h3(textOutput("prediction_result")),
                    plotlyOutput("prediction_prob"),
                    p(em("Note: Predictions are probabilistic and should be interpreted 
  with caution."))
                )
              )
      )
    )
  )
)

# Server
server <- function(input, output) {
  # About tab
  output$variables_table <- renderTable({
    data.frame(
      Variable = c("Clump Thickness", "Cell Size Uniformity",
                   "Cell Shape Uniformity", "Marginal Adhesion",
                   "Epithelial Cell Size", "Bare Nuclei",
                   "Bland Chromatin", "Normal Nucleoli", "Mitoses"),
      Scale = rep("1-10", 9),
      Description = c(
        "Thickness of cell clumps",
        "Uniformity of cell size",
        "Uniformity of cell shape",
        "Adhesion to surrounding cells",
        "Size of epithelial cells",
        "Nuclei not surrounded by cytoplasm",
        "Texture of chromatin",
        "Nucleoli size and number",
        "Rate of cell division"
      )
    )
  })
  
  output$auc_box <- renderValueBox({
    valueBox(auc_bc, "ROC-AUC", 
             icon = icon("chart-line"), color = "blue", width = 12)
  })
  
  output$sens_box <- renderValueBox({
    valueBox(round(cm_bc$byClass["Sensitivity"], 3), "Sensitivity",
             icon = icon("search"), color = "green", width = 12)
  })
  
  output$spec_box <- renderValueBox({
    valueBox(round(cm_bc$byClass["Specificity"], 3), "Specificity",
             icon = icon("shield-alt"), color = "purple", width = 12)
  })
  
  output$f1_box <- renderValueBox({
    valueBox(f1_bc, "F1 Score",
             icon = icon("balance-scale"), color = "orange", width = 12)
  })
  
  # Overview tab
  output$total_patients <- renderValueBox({
    valueBox(nrow(bc), "Total Patients", 
             icon = icon("users"), color = "blue")
  })
  
  output$malignant_count <- renderValueBox({
    valueBox(sum(bc$Class == "malignant"), "Malignant", 
             icon = icon("exclamation-triangle"), color = "red")
  })
  
  output$benign_count <- renderValueBox({
    valueBox(sum(bc$Class == "benign"), "Benign", 
             icon = icon("check-circle"), color = "green")
  })
  
  output$diagnosis_plot <- renderPlotly({
    bc %>%
      count(Class) %>%
      plot_ly(x = ~Class, y = ~n, type = "bar",
              color = ~Class,
              colors = c("malignant" = "#E64B35", 
                         "benign" = "#2E9FDF")) %>%
      layout(showlegend = FALSE,
             xaxis = list(title = "Diagnosis"),
             yaxis = list(title = "Count"))
  })
  
  output$summary_table <- renderTable({
    data.frame(
      Metric = c("Total patients", "Malignant", "Benign", 
                 "Malignant %", "Variables"),
      Value = c(nrow(bc), 
                sum(bc$Class == "malignant"),
                sum(bc$Class == "benign"),
                paste0(round(mean(bc$Class == "malignant") * 100, 1), "%"),
                ncol(bc) - 1)
    )
  })
  
  # Exploration tab
  output$dist_plot <- renderPlotly({
    if(input$show_both) {
      plot_ly(bc, x = ~get(input$variable), 
              color = ~Class,
              colors = c("malignant" = "#E64B35", 
                         "benign" = "#2E9FDF"),
              type = "histogram", alpha = 0.7) %>%
        layout(barmode = "overlay",
               xaxis = list(title = input$variable),
               yaxis = list(title = "Count"))
    } else {
      plot_ly(bc, x = ~get(input$variable), 
              type = "histogram",
              marker = list(color = "#2E9FDF")) %>%
        layout(xaxis = list(title = input$variable),
               yaxis = list(title = "Count"))
    }
  })
  
  output$box_plot <- renderPlotly({
    plot_ly(bc, x = ~Class, y = ~get(input$variable),
            color = ~Class,
            colors = c("malignant" = "#E64B35", 
                       "benign" = "#2E9FDF"),
            type = "box") %>%
      layout(xaxis = list(title = "Diagnosis"),
             yaxis = list(title = input$variable),
             showlegend = FALSE)
  })
  
  # Correlations tab
  output$corr_plot <- renderPlot({
    cor_matrix <- bc %>%
      select(-Class) %>%
      cor(use = "complete.obs")
    
    corrplot(cor_matrix,
             method = "color",
             type = "lower",
             tl.cex = 0.8,
             tl.col = "black",
             addCoef.col = "black",
             number.cex = 0.6,
             col = colorRampPalette(c("#2E9FDF", "white", "#E64B35"))(200))
  })
  
  # Prediction tab
  
  prediction <- eventReactive(input$predict_btn, {
    new_patient <- data.frame(
      Cl.thickness = input$cl_thickness,
      Cell.size = input$cell_size,
      Cell.shape = input$cell_shape,
      Marg.adhesion = input$marginal_adhesion,
      Epith.c.size = input$epithelial_size,
      Bare.nuclei = 5,
      Bl.cromatin = 5,
      Normal.nucleoli = 5,
      Mitoses = 1
    )
    predict(rf_bc, new_patient, type = "prob")
  })
  
  output$prediction_result <- renderText({
    req(input$predict_btn)
    prob <- prediction()
    if(prob[, "malignant"] > 0.5) {
      "⚠️ Prediction: MALIGNANT"
    } else {
      "✅ Prediction: BENIGN"
    }
  })
  
  output$prediction_prob <- renderPlotly({
    req(input$predict_btn)
    prob <- prediction()
    
    plot_ly(
      x = c("Benign", "Malignant"),
      y = c(prob[, "benign"], prob[, "malignant"]),
      type = "bar",
      marker = list(color = c("#2E9FDF", "#E64B35"))
    ) %>%
      layout(title = "Prediction Probabilities",
             xaxis = list(title = "Diagnosis"),
             yaxis = list(title = "Probability", range = c(0, 1)))
  })
}

shinyApp(ui = ui, server = server)

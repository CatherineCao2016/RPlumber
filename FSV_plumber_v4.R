library(plumber)
library(caret)
library(jsonlite)

#* return the input
#*
#* @get /patrol

function(messg = ""){
  list(messg = paste0("Hi I am listening '", messg, "'"))
}

## Load the model
#df_processed <-readRDS("dtTrain.Rds")
modelobject <- readRDS("logisticReg1.rds")



## Lets make the predictions

#* @post /predict
#* @serializer unboxedJSON
predictions <- function(req, res){
  data <- tryCatch(jsonlite::parse_json(req$postBody, simplifyVector = TRUE),error = function(e) NULL)
  print(data)
  col_names <- unlist(data$fields)
  X.new <- as.data.frame(data$values)
  names(X.new) <- col_names
  names(X.new)[names(X.new) == 'OCCUPATION_TYPEWaiters_barmen_staff'] <- "OCCUPATION_TYPEWaiters/barmen staff"
  
  #predict based on input
  ##predict(iris_rf, new_data= X.new, type ="class")
  pred <- predict(object = modelobject, newdata = X.new)
  prob <- predict(object = modelobject, newdata = X.new, type = "prob")
  outter_lists <- list()
  for (z in 1:nrow(data$values)){
    inner_lists <- list()
    for (i in 1:12){
      inner_lists[i] <- data$values[z,i]
    }
    inner_lists <- append(inner_lists, as.character(pred[z]))
    inner_lists <- append(inner_lists, list(c(prob[z, 1], prob[z, 2])))
    
    outter_lists <- append(outter_lists, list(inner_lists))
    
  }
  
  output  <- list(fields  = c(names(X.new), "prediction", "probability"),
                  labels = c('No', 'Yes'),
                  values = outter_lists
  )
  
  return(output)
}

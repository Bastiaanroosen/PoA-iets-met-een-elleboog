library(DBI)
library(RMySQL)
library(rvest)
library(dplyr)
library(sentimentr)
library(e1071)
library(caret)
library(tm)
library(corpus)
library(wordcloud)
library(MIAmaxent)

getwd()
setwd("D:/Jacques/OneDrive/HVA/jaar2/Semester 2/Big Data/DATA ENGINEER AND DATA SCIENTIST/Individuele opdracht 2")
getwd()

# ============================= kaggle file import ================================================

kaggle_Filename<-"Hotel_Reviews.csv"
kaggle_df_reviews<-read.csv(kaggle_Filename, head=TRUE, sep=',', stringsAsFactors = FALSE)

#test
#View(kaggle_df_reviews)
#names(kaggle_df_reviews)



# ============================= First hotel reviews scraping ======================================

#tripadvisor.nl webpage html for Hotel H10 Madison
tripadvisor_review <- read_html("https://www.tripadvisor.com/Hotel_Review-g187497-d13223478-Reviews-H10_Madison-Barcelona_Catalonia.html#REVIEWS")


#scrape review_body H10 Madison
tripadvisor_review_body <- tripadvisor_review %>%
  html_nodes(".hotels-review-list-parts-ExpandableReview__reviewText--3oMkH span") %>%
  html_text()
tripadvisor_review_df_body <- as.data.frame(tripadvisor_review_body) 
#names(tripadvisor_review_df_body)
colnames(tripadvisor_review_df_body)[colnames(tripadvisor_review_df_body)=="tripadvisor_review_body"] <- "Alles_Van_Kaggle"
#names(tripadvisor_review_df_body)


#test
#View(tripadvisor_review_body)
#names(tripadvisor_review_body)
#write data frame to a csv file for Hotel H10 Madison
write.csv(tripadvisor_review_body, "scraped.csv")

# ============================= Second hotel reviews scraping =====================================

#tripadvisor.com webpage html for Hotel Berna
tripadvisor_review2 <- read_html("https://www.tripadvisor.com/Hotel_Review-g187849-d229090-Reviews-Hotel_Berna-Milan_Lombardy.html#REVIEWS")

#scrape review_body Hotel Berna
tripadvisor_review_body2 <- tripadvisor_review2 %>%
  html_nodes(".hotels-review-list-parts-ExpandableReview__reviewText--3oMkH span") %>%
  html_text()
tripadvisor_review_df_body2 <- as.data.frame(tripadvisor_review_body2) 
#names(tripadvisor_review_df_body2)
colnames(tripadvisor_review_df_body2)[colnames(tripadvisor_review_df_body2)=="tripadvisor_review_body2"] <- "Alles_Van_Kaggle"
#names(tripadvisor_review_df_body2)

#test
#View(tripadvisor_review_body2)
#names(tripadvisor_review_body2)
#write data frame to a second csv file for Hotel Berna
write.csv(tripadvisor_review_body2, "scraped2.csv")


# ============================= Own scraping file import ==========================================

#own_scraping_Filename <- "own scraping.csv"
#own_scraping_df_reviews<-read.csv(own_scraping_Filename, head=TRUE, sep=',', stringsAsFactors = FALSE)
#View(own_scraping_df_reviews)



#============================== Bind all reviews ==================================================

kaggle_df_reviews_after <- select(kaggle_df_reviews, c(Negative_Review, Positive_Review))

x <- select(kaggle_df_reviews, c(Negative_Review))
x$type_review <- c("neg")

y <- select(kaggle_df_reviews, c(Positive_Review))
y$type_review <- c("pos")

#test
#View(x)
#View(y)
#glimpse(review_total)

colnames(y)[colnames(y)=="Positive_Review"] <- "Negative_Review"

review_total_withlabel <- rbind(x,y)
colnames(review_total_withlabel)[colnames(review_total_withlabel)=="Negative_Review"] <- "Alles_Van_Kaggle"
review_total_full <- review_total_withlabel


#review_total_full$Alles_Van_Kaggle <- as.factor(review_total_full$Alles_Van_Kaggle)

#add binary label column
#review_total_full$value <- (review_total_full$type_review)
review_total_full$type_review <- gsub("pos", "1", review_total_full$type_review)
review_total_full$type_review <- gsub("neg", "0", review_total_full$type_review)

View(review_total_full)
write.csv(review_total_full, "review_total_full.csv")


#============================== Writing to Database ===============================================

balanced_con <- mongo(collection="review_total_full", db="Reviews",url="mongodb://localhost")
balanced_reviews <- balanced_con$find('{}')

sc <- spark_connect(master = "local")

review_tbl <- copy_to(sc, balanced_reviews, overwrite=TRUE)

glimpse(review_tbl)

#Split into training and test sets
partitions <- review_tbl %>% sdf_partition(training= 0.7,testing= 0.3,seed = 11)

#Create pipeline with transformers and estimators by choice
bayes_pipeline <- ml_pipeline(sc) %>%
  ft_tokenizer(input_col = "Alles_Van_Kaggle", output_col = "words") %>%
  ft_stop_words_remover(input_col = "words", output_col = "filtered_words") %>%
  ft_count_vectorizer(input_col = 'filtered_words', output_col = 'vocab', binary=TRUE) %>%
  ml_naive_bayes(sc, label_col = "type_review", 
                 features_col = "vocab", 
                 prediction_col = "pcol",
                 probability_col = "prcol", 
                 raw_prediction_col = "rpcol",
                 model_type = "multinomial", 
                 uid = "nb")

#Fit the pipeline to create a pipline model, pass training set to train model
bayes_model <- ml_fit(bayes_pipeline, partitions$training)

#Equal to base predict function, pass pipeline model and test set, or any piece of text for new predictions
bayes_predictions <- ml_transform(bayes_model, partitions$testing)
#glimpse(bayes_predictions)

#Display accuracy using evaluator function from mllib
ml_multiclass_classification_evaluator(bayes_predictions, label_col = "type_review", prediction_col = "pcol", metric = "accuracy")

#Collect predictions from spark cluster to calculate accuracy and create confusion matrix
collected_bayes <- bayes_predictions  %>% select(type_review, pcol) %>% collect()

#Create confusion matrix and calculate accuracy
confBayes <- table("Predictions" = collected_bayes$pcol, "Actual" = collected_bayes$type_review)
confBayes
sum(diag(confBayes))/sum(confBayes)

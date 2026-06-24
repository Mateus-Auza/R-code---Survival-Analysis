#---------------------------------------
#Libraries used
#---------------------------------------
library(readxl)     # To import the dataset
library(FactoMineR) # For the PCA
library(factoextra) # For the PCA
library(corrplot)   # For the correlation matrix
library(psych)      # For the describe in summaries
library(survival)   # For survival analysis
library(survminer)  # For survival analysis
library(KMsurv)     # For survival analysis
library(car)        # For coefficient test
library(dplyr)
library(tidyr)



#----------------------------
# Data Analysis Project
#----------------------------
germin = read_excel("data/germination_data.xlsx")
germin= as.data.frame(germin)
str(germin)

#---------------------------------
# Variable specification
#---------------------------------
#seed= Seed number

#Range= Native origin of the seed: U.S or CHINA

#Population= Specific population within a range

#Replicate= Batch or experimental replicate the seed belongs to

#Germination_day= The day the seed was germinated 

#Status (censoring variable)= 1- The seed was germinated, 0 - the seed did not germinate

#Temperature_treatment = Numeric code for treatment : 20C (moderate temperature) or 30C (warm temperature)

# Turn variables into proper types
#germin$range = factor(germin$range)
#germin$population = factor(germin$population)
#germin$replicate = factor(germin$replicate)
#germin$temperature_treatment = factor(germin$temperature_treatment,labels = c("20C", "30C"))


#------------------------------------
#Part A- Descriptive statistics
#------------------------------------

AF2=germin[which(germin$population=="AF2"),]
table(AF2$temperature_treatment)
head(AF2[AF2$seed == 1, c("replicate", "temperature_treatment")], 18)


# Exploration of our dataset
# Exploring the range and population
table(germin$range, germin$population)
table(germin$range)

# Summaries with respect to range and temperature
# ------------------------------------------------------------
print(aggregate(germination_day ~ range+temperature_treatment, data = germin, summary),digits=2)

boxplot(germination_day~temperature_treatment+range,data=germin, main = "Germination day by treatment and range")

boxplot(germination_day~range,data=germin, main = "Germination day by range")

boxplot(germination_day~status,data=germin, main = "Germination day by germination status")


#=====================================================================
# Part B - Non parametric estimator and testing+ fitting the Cox model
#=====================================================================
#(a)

# Global
plot(survfit(Surv(germination_day, status)~1, data=germin,conf.type="log-log"), col=c("red", "blue"), mark.time=T,main="Global Kaplan Meier", ylab="Survival Probability", xlab="Duration")

# Individual- wrt to range
germin.native= germin[which(germin$range=="CHINA"),]
germin.non.native=germin[which(germin$range=="U.S."),]

plot(survfit(Surv(germination_day,status)~1, data=germin.native, conf.type="log-log"),mark.time=T, col="red", main="Biased survival estimation", ylab="Survival Probability", xlab="Duration")
lines(survfit(Surv(germination_day,status)~1, data=germin.non.native, conf.type="log-log"), col="blue", mark.time=T)
legend("topright",legend=c("Native", "Non native"),col=c("red", "blue"), lty=1)

# For better visualisation
ggsurvplot(
  survfit(Surv(germination_day,status)~1, data=germin, conf.type="log-log"),
  data = germin,
  censor = TRUE,
  pval=T,
  risk.table=T,
  title = "Global Kaplan-Meier",
  xlab = "Duration",
  ylab = "Survival Probability"
)

fit= survfit(Surv(germination_day,status)~range, data=germin, conf.type="log-log")

ggsurvplot(fit, data=germin,
           conf.int = TRUE,           # show confidence intervals
           risk.table = TRUE,         # optional: shows number at risk
           pval = TRUE,               # optional: log-rank test
           palette = c("red","blue"),
           xlab = "Germination Day",
           ylab = "Survival Probability",
           legend.title = "Range")

#(b) 
#-----------------------------------------------------------
quantile(fit, probs= c(0.25,0.5,0.75))


#(c) Log-rank test
#---------------------------------------------------------------
survdiff(Surv(germination_day, status)~range, data=germin, rho=1)
survdiff(Surv(germination_day, status)~range, data=germin, rho=0)

#(d) Cox semi parametric model
#---------------------------------

cox=coxph(Surv(germination_day,status)~range, data= germin)
summary(cox)


#ggforest(cox, data=germin)

ggsurvplot(
  survfit(cox, newdata = data.frame(range = c("CHINA", "U.S."))),
  data = germin,
  conf.int = TRUE,
  legend.labs = c("China", "U.S."),
  legend.title = "Range",
  xlab = "Duration",
  ylab = "Survival probability (not germinated)"
)

#========================================================
# Part C ------------------------------------------------
#========================================================

#(a)
#--------------------------------------

#1 - Choosing the best model
coxfull= coxph(Surv(germination_day, status)~range+temperature_treatment+ strata(replicate) + temperature_treatment*range , data=germin)
m1=coxph(Surv(germination_day, status)~range+temperature_treatment + temperature_treatment*range , data=germin)
m2= coxph(Surv(germination_day, status)~range+temperature_treatment +strata(replicate) , data=germin)
t(AIC(coxfull,m1,m2))

#2
summary(coxfull)

#3
cox.reduced= update(coxfull, .~. - range)

# Likelihood Ratio Test
anova(cox.reduced, coxfull, test= "Chisq")


#4 
# Diagnostic plots
#======================================

#log(H_China(t)), log(H_U.S.(t)) vs time
#***************************************
plot(fit, fun = "cloglog",
     xlab = "Time",
     ylab = "log(H(t))", col=c("red", "blue"), main="log(H(t)) vs time")
legend("topleft", legend=c("20C","30C"),lty=1, col=c("red", "blue"))

# fit3= survfit(Surv(germination_day, status) ~ temperature_treatment, data = germin)
# plot(fit3, fun = "cloglog",
#      xlab = "Time",
#      ylab = "log(H(t))", col=c("red", "blue"), main="log(H(t)) vs time - temperature_treatment")
# legend("topleft", levels(germin$temperature_treatment),lty=1, col=c("red", "blue"))


#log(H2)-log(H1) vs time
#***************************************
# Identify rows belonging to each group
idx1 = rep(names(fit$strata), fit$strata)

# Create a data frame
df1 = data.frame(
  time = fit$time,
  cumhaz = fit$cumhaz,
  range = idx1
)

df_wide1 = df1 %>%
  pivot_wider(names_from = range, values_from = cumhaz) %>%
  drop_na()

df_wide1 = df_wide1 %>%
  mutate(log_diff = log(`range=CHINA`) - log(`range=U.S.`))

plot(
  df_wide1$time,
  df_wide1$log_diff,
  type = "l",
  lwd = 2,
  xlab = "Time",
  ylab = expression(log(H[CHINA](t)) - log(H[U.S.](t))),
  main = "Log cumulative hazard difference vs time", col="darkblue"
)
abline(h = 0, lty = 2, col = "gray")


# H_China(t) vs H_U.S(t)
#********************************
plot(
  df_wide1$`range=CHINA`,
  df_wide1$`range=U.S.`,
  type = "l",
  lwd = 2,
  xlab = expression(H[China](t)),
  ylab = expression(H[U.S.](t)),
  main = "Cumulative hazard plot", col="darkblue"
)
abline(a = 0, b = 1, lty = 2, col = "gray")


# Test on time-by-covariates diagnostic
#===========================================
cox.test.PH= coxph(
  Surv(germination_day, status) ~ range+temperature_treatment+strata(replicate) +temperature_treatment:range+
    tt(as.numeric(as.factor(range))),
  data = germin,
  tt = function(x, t, ...) x * (t<=5)
)
cox.test.PH
# We can see that now that range is smaller than 0.05, thus our hypothesis holds

# Schoenfeld residuals
#===========================================
schoenfeld= cox.zph(coxfull)
schoenfeld

survminer::ggcoxzph(schoenfeld)


#(b)
#----------------------------------------------

#(1)
model.param1= survreg(Surv(germination_day, status)~range+ temperature_treatment+ replicate+ temperature_treatment*range,data=germin, dist="loglogistic" )
model.param2= survreg(Surv(germination_day, status)~range+ temperature_treatment+ replicate+ temperature_treatment*range,data=germin, dist="lognormal" )


AIC(model.param1, model.param2)

#(2)
summary(model.param1)
# Confidence intervals 
confint(model.param1)
# Parameters
# Coefficients for our log-linear model
gamma=coef(model.param1)
# Coefficients for AFT
theta=-coef(model.param1)

#(3)
# Comparison between cox and AFT results
model.param1
coxfull






library(GuardianR)
library(lubridate)
results <- get_guardian(query,
                        section="business",
                        from.date = as.character(ymd(Sys.Date() - 6*30)),
                        to.date = Sys.Date(),
                        api.key="Yourkeyhere")



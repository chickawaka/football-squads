
# session ----------------------------------------------------

# load packages
library(tidyverse)
library(lubridate)
library(hrbrthemes)
library(ewen)
library(ggalt)
library(forcats)

# load  ----------------------------------------------------

# load raw squad data
squads <- read_csv(file = "https://raw.githubusercontent.com/ewenme/football-squads/master/data/2017_squads.csv")

# clean  ----------------------------------------------------

# make month of birth col
squads[['month']] <- month(squads[['date_of_birth']], label = TRUE)
squads[['days_in_month']] <- days_in_month(squads[['date_of_birth']])

# remove missing dobs
squads <- filter(squads, !is.na(month))

# make english players bday summary
eng_player_bdays <- squads %>% 
  # filter for same nationalities as in leagues
  filter(nationality %in% c("England"),
         league_name %in% c("Premier League", "Championship", "League One", "League Two")) %>%
  # get monthly bday props
  group_by(nationality, month, days_in_month) %>%
  summarise(count=n()) %>%
  mutate(count_per_day=count/days_in_month) %>%
  group_by(nationality, month) %>%
  summarise(count_per_day=sum(count_per_day)) %>%
  mutate(prop=count_per_day/sum(count_per_day)) 

# reorder months
eng_player_bdays$month <- fct_relevel(as_factor(eng_player_bdays$month),
                                     "Sep", "Oct", "Nov", "Dec", "Jan", "Feb",
                                     "Mar", "Apr", "May", "Jun", "Jul", "Aug")

# make english players bday summary by league
eng_league_bdays <- squads %>% 
  # filter for same nationalities as in leagues
  filter(nationality %in% c("England"),
         league_name %in% c("Premier League", "Championship", "League One", "League Two")) %>%
  # get monthly bday props
  group_by(league_name, nationality, month, days_in_month) %>%
  summarise(count=n()) %>%
  mutate(count_per_day=count/days_in_month) %>%
  group_by(league_name, nationality, month) %>%
  summarise(count_per_day=sum(count_per_day)) %>%
  mutate(prop=count_per_day/sum(count_per_day)) 

# reorder months
eng_league_bdays$month <- fct_relevel(as_factor(eng_league_bdays$month),
                                      "Sep", "Oct", "Nov", "Dec", "Jan", "Feb",
                                      "Mar", "Apr", "May", "Jun", "Jul", "Aug")

# reorder leagues
eng_league_bdays$league_name <- fct_relevel(as_factor(eng_league_bdays$league_name),
                                      "Premier League", "Championship", 
                                      "League One", "League Two")


# make homegrown players bday summary by euro league
euro_league_bdays <- squads %>% 
  # filter for same nationalities as in leagues
  filter((nationality == "Spain" & league_name == "LaLiga") |
           (nationality == "Italy" & league_name == "Serie A") |
           (nationality == "Germany" & league_name == "1.Bundesliga") |
           (nationality == "France" & league_name == "Ligue 1")) %>%
  # get monthly bday props
  group_by(league_name, month, days_in_month) %>%
  summarise(count=n()) %>%
  mutate(count_per_day=count/days_in_month) %>%
  group_by(league_name, month) %>%
  summarise(count_per_day=sum(count_per_day)) %>%
  mutate(prop=count_per_day/sum(count_per_day)) 

# plot  ----------------------------------------------------

# plot eng player bdays
ggplot(data = eng_player_bdays) +
  # histogram layer
  geom_histogram(aes(x=month, y=prop), stat = "identity") +
  # set as radial chart
  coord_polar() +
  # add personal chart theme
  theme_work(plot_title_size = 12) + 
  # remove x axis labels
  labs(x=NULL, y="Proportion of birthdays", caption="data from Transfermarkt | made by @ewen_", 
       title="Born to Play? Relative Age Effect in English Footballers",
       subtitle="English-born participation (2017/18 season) in the top four English\nfootball divisions is skewed towards those born early after the\ncut-off date (31st August) for age group competition.") +
  # set colour of gridlines
  theme(panel.grid.major = element_line(linetype = "dashed", colour = "white"),
        plot.subtitle = element_text(size = 10),
        axis.text.y = element_text(colour = "black", size = 9),
        axis.title.y = element_text(hjust=0.8, size = 9),
        plot.caption = element_text(hjust=2.5)) +
  # create percent-based y axis
  scale_y_percent() +
  geom_hline(yintercept = seq(from=0, to=0.12, by=0.03), colour="white", linetype="dotted") +
  geom_vline(aes(xintercept = 0.5), colour="black")

# plot eng player bdays by league
ggplot(data = eng_league_bdays) +
  # histogram layer
  geom_histogram(aes(x=month, y=prop), stat = "identity") +
  # set as radial chart
  coord_polar() +
  # add personal chart theme
  theme_work(plot_title_size = 12) + 
  # remove x axis labels
  labs(x=NULL, y="Proportion of birthdays", caption="data from Transfermarkt | made by @ewen_") +
  # set colour of gridlines
  theme(panel.grid.major = element_line(linetype = "dashed", colour = "white"),
        plot.subtitle = element_text(size = 10),
        axis.text.y = element_text(colour = "black", size = 9),
        axis.title.y = element_text(hjust=0.65, size = 9),
        plot.caption = element_text(hjust=1.6),
        strip.text = element_text(size = 10)) +
  # create percent-based y axis
  scale_y_percent() +
  geom_hline(yintercept = seq(from=0, to=0.125, by=0.025), colour="white", linetype="dotted") +
  geom_vline(aes(xintercept = 0.5), colour="black") +
  facet_wrap( ~ league_name)


# plot euro player bdays by league
ggplot(data = euro_league_bdays) +
  # histogram layer
  geom_histogram(aes(x=month, y=prop), stat = "identity") +
  # set as radial chart
  coord_polar() +
  # add personal chart theme
  theme_work(plot_title_size = 12) + 
  # remove x axis labels
  labs(x=NULL, y="Proportion of birthdays", caption="data from Transfermarkt | made by @ewen_") +
  # set colour of gridlines
  theme(panel.grid.major = element_line(linetype = "dashed", colour = "white"),
        plot.subtitle = element_text(size = 10),
        axis.text.y = element_text(colour = "black", size = 9),
        axis.title.y = element_text(hjust=0.65, size = 9),
        plot.caption = element_text(hjust=1.6),
        strip.text = element_text(size = 10)) +
  # create percent-based y axis
  scale_y_percent() +
  geom_hline(yintercept = seq(from=0, to=0.125, by=0.025), colour="white", linetype="dotted") +
  geom_vline(aes(xintercept = 0.5), colour="black") +
  facet_wrap( ~ league_name)

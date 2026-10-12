#install.packages("ggplot2")
library(ggplot2)
diamonds |> ggplot(aes(x = carat, y = price)) + 
  geom_point(alpha = 0.05)

diamonds |>
  ggplot(aes(x = price)) + geom_histogram()

diamonds |>
  ggplot(aes(x = price)) + geom_histogram(binwidth=200)

diamonds |>
  ggplot(aes(x = price)) + geom_histogram(binwidth=100)

diamonds |> ggplot(aes(x = carat, y = price)) + 
  geom_point(aes(colour = cut)) + facet_wrap(~clarity)

diamonds |> ggplot(aes(x = carat, y = price)) + 
  geom_point(aes(colour = color)) + facet_wrap(~clarity)

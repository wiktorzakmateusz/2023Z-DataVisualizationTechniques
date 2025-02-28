library(dplyr)
library(DescTools) 


df <- read.csv("house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie
View(df)
# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i po�o�onych na wsch�d od po�udnika 122W?
df %>% 
  filter(bathrooms > median(bathrooms), long > -122) %>% 
  summarise(mean_price = mean(price))


# Odp: 625499.4

# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?
df %>% 
  group_by(yr_built) %>% 
  summarise(n = n()) %>% 
  arrange(-n) %>% 
  select(yr_built) %>% 
  head(1)


# Odp: 2014

# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w por�wnaniu z tymi po�o�onymi nie nad wod�?
df %>% 
  group_by(waterfront) %>% 
  summarise(median_price = median(price)) 
(1400000 - 450000)/450000 * 100
  
  

# Odp: 211.1111%

# 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?
df %>% 
  filter(floors == 1) %>% 
  group_by(yr_built) %>% 
  filter(price == min(price)) %>% 
  ungroup() %>% 
  summarise(mean_sqft = mean(sqft_living))


# Odp: 1030

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?
df %>% 
  filter(bathrooms %in% c(1, 2)) %>% 
  group_by(bathrooms) %>% 
  summarise(first = quantile(grade,0.25), third = quantile(grade,0.75))

# Odp: Jest Q1 r�ni si� o 1 i Q3 r�wnie� o 1

# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)

df %>% 
  mutate(north = ifelse(lat > (max(df$lat)+min(df$lat))/2, T, F)) %>% 
  group_by(north) %>% 
  summarise(interquartile_range = IQR(price))
  

# Odp: Po�udnie: 122500, P�noc: 321000 

# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach niepo�o�onych nad wod�, kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?
df %>% 
  filter(waterfront == 0, sqft_living/floors <= 1800) %>% 
  group_by(bathrooms) %>% 
  summarise(n = n()) %>% 
  arrange(n) %>% 
  View()

# Odp: Najrzadziej: 4.75, Najcz�sciej: 2.5

# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz najpopularniejsz� liczb� �azienek


df %>% 
  group_by(zipcode) %>% 
  summarise(n = n(),
            standard_deviation = sd(sqft_lot),
            mode_bathrooms = Mode(bathrooms)) %>% 
  filter(n > 550) %>% 
  arrange(n) %>% 
  select(-n) %>% 
  View()
  

# Odp: zipcode  odchylenie  moda 
#   1   98117   2318.662    1.0
#   2   98052   10276.188   2.5
#   3   98115   2675.302    1.0
#   4   98038   63111.112   2.5
#   5   98103   1832.009    1.0

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.
df %>% 
  filter(waterfront == 0) %>% 
  mutate(size = case_when(sqft_living <= 2000 ~"small",
                          sqft_living <= 4000 ~"medium",
                          TRUE ~"big")) %>% 
  group_by(size) %>% 
  summarise(mean_price = mean(price), median_price = median(price)) %>% 
  View()

# Odp:  Rozmiar   �rednia     Mediana
#   1   Du�e      1448118.8   1262750
#   2   �rednie   645419.0    595000
#   3   Ma�e      385084.3    359000

# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? (bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)
df %>% 
  summarise(min_price = min(price/(sqft_living * 0.09290304)))

# Odp: 942.7919

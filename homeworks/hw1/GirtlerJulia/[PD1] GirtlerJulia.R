install.packages("PogromcyDanych")
library(PogromcyDanych)
library(dplyr)
library(stringr)
data(auta2012)

# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?

auta2012 %>% 
  filter(Waluta == "PLN", Rodzaj.paliwa == "naped elektryczny") %>% 
  arrange(Cena.w.PLN) %>% 
  select(Cena.w.PLN, Rodzaj.paliwa) %>% 
  summarise(median(Cena.w.PLN))

# Odp: Mediana ceny samochod�w, kt�re maj� nap�d elektryczny wynosi 18900.

# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.

auta2012 %>% 
  mutate(rok = ifelse(Rok.produkcji >= 2001, "po 2001", "przed 2001")) %>%
  select(rok,  Marka, KM) %>% 
  group_by(Marka, rok) %>% 
  summarise(mediana = median(KM, na.rm = TRUE)) %>% 
  arrange(desc(mediana)) %>% 
  head(1)

# Odp: Bugatti po 2001



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
# UWAGA: Nie rozpatrujemy obserwacji z NA w kraju aktualnej rejestracji


auta2012 %>% 
  filter(Kolor == "szary-metallic") %>% 
  select(Kolor, Cena.w.PLN, Kraj.aktualnej.rejestracji,Kraj.pochodzenia) %>% 
  filter(as.character(Kraj.pochodzenia)!= as.character(Kraj.aktualnej.rejestracji)) %>% 
  filter((Cena.w.PLN >= median(Cena.w.PLN) & Cena.w.PLN <= mean(Cena.w.PLN)) | (Cena.w.PLN <= median(Cena.w.PLN) & Cena.w.PLN >= mean(Cena.w.PLN))) %>%
  nrow()


# Odp: 1114



# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012 %>% 
  filter(Marka == "Volkswagen" & Wersja == "B6" & Rodzaj.paliwa == "benzyna") %>% 
  summarise(IQR(Przebieg.w.km, na.rm = TRUE)) 
  

# Odp: 75977.5



# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(cena_ostatecnza = ifelse(Brutto.netto == "brutto", Cena, Cena*1.02)) %>% 
  select(Waluta, cena_ostatecnza) %>%
  summarise(mean(cena_ostatecnza))

# Odp: 210678.3 CZK



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.


auta2012 %>% 
  filter(Marka == "Chevrolet", Przebieg.w.km > 50000, Skrzynia.biegow!= "") %>% 
  select(Marka, Przebieg.w.km, Skrzynia.biegow, Model) %>% 
  count(Skrzynia.biegow, Model) %>% 
  arrange(-n) %>% 
  head(10)
  

# Odp: z manualn�, manualna - Lacetti, automatyczna - Corvette



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  filter(Marka == "Mercedes-Benz") %>% 
  
  mutate(rok = ifelse(Rok.produkcji >= 2003, "po 2003", "przed 2003")) %>% 
  select(Marka, rok, Pojemnosc.skokowa) %>% 
  group_by(rok) %>% 
  count(rok, median(Pojemnosc.skokowa, na.rm = TRUE)) %>% 
  head()

  
# Odp: Nie zmienia si� i wynosi 2200.



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?
auta2012 %>% 
  filter(Kraj.aktualnej.rejestracji == "Polska" & Kraj.pochodzenia == "Niemcy" & !is.na(Przebieg.w.km)) %>% 
  select(Kraj.aktualnej.rejestracji, Kraj.pochodzenia, Przebieg.w.km) %>% 
  arrange(-Przebieg.w.km) %>% 
  head(1)


# Odp: 1e+09 (okoko�o biliona)



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?

x <- filter(auta2012, Marka == "Mitsubishi"& Kolor != "" & Kraj.pochodzenia == "Wlochy") %>% select(Kolor, Marka, Kraj.pochodzenia)
x <- count(x, Kolor) %>% arrange(n)
x

# Odp: Granatowy- metaliic


# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen"& !is.na(Pojemnosc.skokowa)) %>% 
  mutate(lusterka = str_detect(Wyposazenie.dodatkowe, "el. lusterka")) %>% 
  group_by(lusterka) %>% summarise(kwantyl25 = quantile(Pojemnosc.skokowa)[2],kwantyl75 = quantile(Pojemnosc.skokowa)[4]) 
  

# Odp: Gdy maj� lusterka - 1400, 1900, gdy nie maj� 1892,1968
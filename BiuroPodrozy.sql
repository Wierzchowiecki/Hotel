-- Tworzenie bazy danych
CREATE DATABASE BiuroPodrozy;
-- IF NOT EXISTS pozwala nam utworzyć bazę danych lub tabelę, jeśli jeszcze nie istnieje

-- DROP DATABASE BiuroPodrozy; -- usuwanie bazy danych (dodałam tylko na moje potrzeby testów)

-- Nadawanie uprawnień użytkownikom
GRANT ALL ON BiuroPodrozy.* TO 'trener'@'localhost';
/*Przyznaje użytkownikowi o nazwie 'trener' wszystkie uprawnienia (takie jak SELECT, INSERT, UPDATE, DELETE itd.) 
 dla wszystkich tabel w bazie danych o nazwie 'BiuroPodrozy', ale tylko z lokalnego hosta ('localhost').*/
GRANT ALL ON BiuroPodrozy.* TO 'trener'@'%';
/*'trener' otrzymuje uprawnienia ALL dla wszystkich tabel w bazie danych 'BiuroPodrozy'z dowolnego hosta ('%'), 
 co oznacza, że może łączyć się z bazą danych zarówno z lokalnego hosta, jak i z zewnętrznych hostów.*/

GRANT SELECT ON BiuroPodrozy.* TO 'student'@'localhost';
GRANT SELECT ON BiuroPodrozy.* TO 'student'@'%';
/*Przyznaje użytkownikowi o nazwie 'student' uprawnienie SELECT (tylko odczyt danych)*/
GRANT INSERT ON BiuroPodrozy.* TO 'student'@'%';
/*Przyznaje użytkownikowi o nazwie 'student' uprawnienie INSERT (wstawianie danych)*/

GRANT SELECT ON BiuroPodrozy.* TO 'api'@'localhost';
GRANT SELECT ON BiuroPodrozy.* TO 'api'@'%';
GRANT INSERT ON BiuroPodrozy.* TO 'api'@'%';

FLUSH PRIVILEGES;
/*Komenda jest używana w systemie zarządzania bazą danych MySQL w celu przeładowania i odświeżenia uprawnień użytkowników. 
 Po wykonaniu tej komendy, serwer MySQL przeładowuje pliki konfiguracyjne uprawnień i aktualizuje wewnętrzną pamięć podręczną 
 zawierającą informacje o uprawnieniach.*/

-- Używanie bazy danych
USE BiuroPodrozy;

-- Tworzenie tabeli Klienci
CREATE TABLE IF NOT EXISTS Klienci (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Imie VARCHAR(30) NOT NULL,
    Nazwisko VARCHAR(60) NOT NULL,
    DataUrodzenia DATE NOT NULL,
    AdresZamieszkania VARCHAR(255),
    Email VARCHAR(30) NOT NULL,
    Telefon VARCHAR(15) NOT null,
    Status_rekordu CHAR(1) DEFAULT 'A',
    CONSTRAINT chk_stat_kli CHECK (Status_rekordu in ('A', 'H'))
);

-- Tworzenie tabeli Destynacje
CREATE TABLE IF NOT EXISTS Destynacje (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Kraj VARCHAR(30) NOT NULL,
    Region VARCHAR(60) NOT NULL,
    Miasto VARCHAR(30),
    Status_rekordu CHAR(1) DEFAULT 'A',
    CONSTRAINT chk_stat_des CHECK (Status_rekordu in ('A', 'H'))
);

-- Tworzenie tabeli Hotele
CREATE TABLE IF NOT EXISTS Hotele (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nazwa VARCHAR(30) NOT NULL,
    DestynacjaID INT NOT NULL,
    Adres VARCHAR(255),
    IloscGwiazdek ENUM('1', '2', '3', '4', '5') NOT NULL COMMENT 'Może przyjmować wartości: 1, 2, 3, 4, 5',
    Wyzywienie ENUM('AI', 'FB', 'HB', 'BB') NOT NULL COMMENT 'Może przyjmować wartości: AI (All Inclusive), FB (Full Board), HB (Half Board), BB (Bed and Breakfast)',
    Cena DECIMAL(10, 2) NOT NULL,
    Status_rekordu CHAR(1) DEFAULT 'A',
    FOREIGN KEY (DestynacjaID) REFERENCES Destynacje(ID),
    CONSTRAINT chk_stat_hot CHECK (Status_rekordu in ('A', 'H'))
);

/*
 Komentarze dla kolumn IloscGwiazdek i Wyzywienie można dodać na etapie tworzenia tabeli Hotele (jak powyżej)
 lub poprzez modyfikowanie tabeli (jak poniżej):
 
-- Dodawanie komentarzy do kolumn w tabeli Hotele
ALTER TABLE Hotele
MODIFY COLUMN IloscGwiazdek ENUM('1', '2', '3', '4', '5') NOT NULL COMMENT 'Może przyjmować wartości: 1,2,3,4,5',
MODIFY COLUMN Wyzywienie ENUM('AI', 'FB', 'HB', 'BB') NOT NULL COMMENT 'Może przyjmować wartości: AI, FB, HB, BB';
*/

-- Tworzenie tabeli Rezerwacje
CREATE TABLE IF NOT EXISTS Rezerwacje (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    KlientID INT NOT NULL,
    HotelID INT NOT NULL,
    DataRezerwacji DATE NOT NULL,
    DataPoczatku DATE NOT NULL,
    DataKonca DATE NOT NULL,
    Status_rekordu CHAR(1) DEFAULT 'A',
    FOREIGN KEY (KlientID) REFERENCES Klienci(ID),
    FOREIGN KEY (HotelID) REFERENCES Hotele(ID),
    CONSTRAINT chk_stat_rez CHECK (Status_rekordu in ('A', 'H')),
    CHECK (DataRezerwacji < DataPoczatku AND DataPoczatku < DataKonca)
);


/* 
Podobnie jest z kluczami obcymi FOREIGN KEY (FK)

-- Dodawanie kluczy do tabeli Rezerwacje
ALTER TABLE Rezerwacje
ADD FOREIGN KEY (KlientID) REFERENCES Klienci(ID),
ADD FOREIGN KEY (HotelID) REFERENCES Hotele(ID);

*Klucz główny jest unikalnym identyfikatorem dla każdego rekordu w tabeli.
Każda tabela powinna mieć jeden (lub więcej) klucz główny.

Klucz główny w naszym wypadku nie może być dodany na etapie modyfikacji tabeli, 
ponieważ kolumna auto musi być zdefiniowana jako klucz główny.

*Klucz obcy ustanawia relację między dwiema tabelami w bazie danych, 
która jest tworzona poprzez dopasowanie wartości klucza obcego w jednej tabeli 
do odpowiadającej wartości klucza głównego w innej tabeli. 
Umożliwia odwoływanie się do danych z innych tabel np w zapytaniach z JOIN'ami

-- dodawanie warunków:
ALTER TABLE Rezerwacje
ADD CHECK (DataRezerwacji < DataPoczatku AND DataPoczatku < DataKonca);
*/

-- Tworzenie tabeli Udogodnienia
CREATE TABLE IF NOT EXISTS Udogodnienia (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nazwa VARCHAR(60) NOT null,
    Status_rekordu CHAR(1) DEFAULT 'A',
    CONSTRAINT chk_stat_udo CHECK (Status_rekordu in ('A', 'H'))
);

-- Tworzenie tabeli UdogodnieniaHotelu
CREATE TABLE IF NOT EXISTS UdogodnieniaHotelu (
    HotelID INT NOT NULL,
    UdogodnienieID INT NOT NULL,
    Opis VARCHAR(255),
    PRIMARY KEY (HotelID, UdogodnienieID),
    FOREIGN KEY (HotelID) REFERENCES Hotele(ID),
    FOREIGN KEY (UdogodnienieID) REFERENCES Udogodnienia(ID)
);

/*
RELACJA MIĘDZY TABELAMI:
Tabela Klienci (KlientID) -> Tabela Rezerwacje (KlientID):
Relacja jeden do wielu. Jeden klient może dokonać wielu rezerwacji, ale jedna rezerwacja może być przypisana tylko do jednego klienta.

Tabela Hotele (DestynacjaID) -> Tabela Destynacje (ID):
Relacja jeden do wielu. Jeden kraj/region/miasto może mieć wiele hoteli, ale jeden hotel jest przypisany tylko do jednej destynacji.

Tabela Hotele (HotelID) -> Tabela Rezerwacje (HotelID):
Relacja jeden do wielu. Jeden hotel może mieć wiele rezerwacji, ale jedna rezerwacja jest przypisana tylko do jednego hotelu.
 
Tabela Hotele (ID) ma relację wiele do wielu z tabelą Udogodnienia (ID) poprzez tabelę pośredniczącą UdogodnieniaHotelu (HotelID, UdogodnienieID). 
Oznacza to, że jeden hotel może mieć wiele udogodnień, a jedno udogodnienie może być dostępne w wielu hotelach.
*/

-- 
-- ORACLE application database and associated users creation script for CST2355-Assignment02
--
-- should be run while connected as 'sys as sysdba'
--
CONNECT sqlplus / as sysdba;

-- Create STORAGE
CREATE TABLESPACE cst2355_Assignment02
  DATAFILE 'cst2355_Assignment02.dat' SIZE 40M 
  ONLINE; 
  
-- Create Users
CREATE USER Assign02 IDENTIFIED BY Assign02 ACCOUNT UNLOCK
	DEFAULT TABLESPACE cst2355_Assignment02
	QUOTA 20M ON cst2355_Assignment02;
	
CREATE USER testUser IDENTIFIED BY testPassword ACCOUNT UNLOCK
	DEFAULT TABLESPACE cst2355_Assignment02
	QUOTA 5M ON cst2355_Assignment02;
	
-- Create ROLES
CREATE ROLE applicationAdmin;
CREATE ROLE applicationUser;

-- Grant PRIVILEGES
GRANT ALL PRIVILEGES TO applicationAdmin;
GRANT CONNECT, RESOURCE TO applicationUser;

GRANT applicationAdmin TO Assign02;
GRANT applicationUser TO testUser;

-- NOW we can connect as the applicationAdmin and create the stored procedures, tables, and triggers
CONNECT Assign02/Assign02;

-- Procedure to drop a table if it exists
CREATE OR REPLACE PROCEDURE drop_if_exists(table_name IN VARCHAR2) IS
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || table_name || ' CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Drop all tables if they exist
BEGIN
    drop_if_exists('VinylRecordsRecordLabels');
    drop_if_exists('RecordLabels');
    drop_if_exists('VinylRecords');
    drop_if_exists('TracksTitles');
    drop_if_exists('Titles');
    drop_if_exists('Tracks');
    drop_if_exists('Relationships');
    drop_if_exists('LineItems');
    drop_if_exists('Invoices');
    drop_if_exists('ArtistsFirstNames');
    drop_if_exists('ArtistsLastNames');
    drop_if_exists('FirstNames');
    drop_if_exists('LastNames');
    drop_if_exists('Producer');
    drop_if_exists('Musician');
    drop_if_exists('SongWriter');
    drop_if_exists('Artists');
END;
/

-- Create Vinyl Records Table
CREATE TABLE VinylRecords (
    RecordID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate Key
    Title NVARCHAR2(50) NOT NULL,
    Genre NVARCHAR2(20) NOT NULL,
    ReleaseDate DATE
    -- RecordLabel NVARCHAR2(255)
);

-- Create Artists Table
CREATE TABLE Artists (
    ArtistID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate Key
    -- FirstName NVARCHAR2(30) NOT NULL,
    -- LastName NVARCHAR2(30) NOT NULL,
    Nationality NVARCHAR2(30) NOT NULL
);

-- Create Producer Table
CREATE TABLE Producer (
    ProducerID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate Key
    ArtistID INT,
    Type NVARCHAR2(20),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE
);

-- Create Musician Table
CREATE TABLE Musician (
    MusicianID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate Key
    ArtistID INT,
    Instrument NVARCHAR2(50),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE
);

-- Create SongWriter Table
CREATE TABLE SongWriter (
    SongWriterID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate Key
    ArtistID INT,
    GenreSpecialization NVARCHAR2(50),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE
);

-- Create Tracks Table
CREATE TABLE Tracks (
    TrackID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- Title NVARCHAR2(50) NOT NULL,
    Length NVARCHAR2(30),
    RecordID INT NOT NULL,
    RecordingDate DATE,
    FOREIGN KEY (RecordID) REFERENCES VinylRecords(RecordID) ON DELETE CASCADE
);

-- Create Relationships Table
CREATE TABLE Relationships (
    RelationshipID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RecordID INT NOT NULL,
    ArtistID INT NOT NULL,
    Role NVARCHAR2(20),
    FOREIGN KEY (RecordID) REFERENCES VinylRecords(RecordID) ON DELETE CASCADE,
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE
);

-- Create Invoices Table
CREATE TABLE Invoices (
    InvoiceID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerName NVARCHAR2(50) NOT NULL
);

-- Create Line Items Table
CREATE TABLE LineItems (
    LineItemID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InvoiceID INT NOT NULL,
    RecordID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID) ON DELETE CASCADE,
    FOREIGN KEY (RecordID) REFERENCES VinylRecords(RecordID) ON DELETE CASCADE
);

-- New tables for Artists multi-valued fields
CREATE TABLE FirstNames (
    FirstNameID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName NVARCHAR2(30) NOT NULL
);

CREATE TABLE LastNames (
    LastNameID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    LastName NVARCHAR2(30) NOT NULL
);

CREATE TABLE ArtistsFirstNames (
    ArtistID INT,
    FirstNameID INT,
    STARTTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ENDTIME TIMESTAMP DEFAULT NULL,
    Notes NVARCHAR2(255) DEFAULT NULL,
    PRIMARY KEY (ArtistID, FirstNameID, STARTTIME),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE,
    FOREIGN KEY (FirstNameID) REFERENCES FirstNames(FirstNameID) ON DELETE CASCADE
);

CREATE TABLE ArtistsLastNames (
    ArtistID INT,
    LastNameID INT,
    STARTTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ENDTIME TIMESTAMP DEFAULT NULL,
    Notes NVARCHAR2(255) DEFAULT NULL,
    PRIMARY KEY (ArtistID, LastNameID, STARTTIME),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID) ON DELETE CASCADE,
    FOREIGN KEY (LastNameID) REFERENCES LastNames(LastNameID) ON DELETE CASCADE
);

-- New tables for Tracks multi-valued fields
CREATE TABLE Titles (
    TitleID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Title NVARCHAR2(50) NOT NULL
);

CREATE TABLE TracksTitles (
    TrackID INT,
    TitleID INT,
    STARTTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ENDTIME TIMESTAMP DEFAULT NULL,
    Notes NVARCHAR2(255) DEFAULT NULL,
    PRIMARY KEY (TrackID, TitleID, STARTTIME),
    FOREIGN KEY (TrackID) REFERENCES Tracks(TrackID) ON DELETE CASCADE,
    FOREIGN KEY (TitleID) REFERENCES Titles(TitleID) ON DELETE CASCADE
);

-- New tables for Vinyl Records multi-valued fields
CREATE TABLE RecordLabels (
    RecordLabelID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RecordLabel NVARCHAR2(255) NOT NULL
);

CREATE TABLE VinylRecordsRecordLabels (
    RecordID INT,
    RecordLabelID INT,
    STARTTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ENDTIME TIMESTAMP DEFAULT NULL,
    Notes NVARCHAR2(255) DEFAULT NULL,
    PRIMARY KEY (RecordID, RecordLabelID, STARTTIME),
    FOREIGN KEY (RecordID) REFERENCES VinylRecords(RecordID) ON DELETE CASCADE,
    FOREIGN KEY (RecordLabelID) REFERENCES RecordLabels(RecordLabelID) ON DELETE CASCADE
);

-- View for Artists
CREATE OR REPLACE VIEW ARTISTS_VIEW AS 
SELECT 
    a.ArtistID, 
    fn.FirstName, 
    ln.LastName,
    a.Nationality
    -- afn.Notes AS AFNotes
    -- aln.Notes AS ALNotes
FROM Artists a
LEFT JOIN ArtistsFirstNames afn ON a.ArtistID = afn.ArtistID AND afn.ENDTIME IS NULL
LEFT JOIN FirstNames fn ON afn.FirstNameID = fn.FirstNameID
LEFT JOIN ArtistsLastNames aln ON a.ArtistID = aln.ArtistID AND aln.ENDTIME IS NULL
LEFT JOIN LastNames ln ON aln.LastNameID = ln.LastNameID;

-- View for Tracks
CREATE OR REPLACE VIEW TRACKS_VIEW AS 
SELECT 
    t.TrackID,
    ti.Title,
    t.Length,
    t.RecordID,
    t.RecordingDate
    --tt.Notes AS TTNotes
FROM Tracks t
LEFT JOIN TracksTitles tt ON t.TrackID = tt.TrackID AND tt.ENDTIME IS NULL
LEFT JOIN Titles ti ON tt.TitleID = ti.TitleID;

-- View for Vinyl Records
CREATE OR REPLACE VIEW VINYL_RECORDS_VIEW AS 
SELECT 
    vr.RecordID, 
    vr.Title, 
    vr.Genre, 
    vr.ReleaseDate, 
    rl.RecordLabel
    --vrrl.Notes AS VLNotes
FROM VinylRecords vr
LEFT JOIN VinylRecordsRecordLabels vrrl ON vr.RecordID = vrrl.RecordID AND vrrl.ENDTIME IS NULL
LEFT JOIN RecordLabels rl ON vrrl.RecordLabelID = rl.RecordLabelID;

-- Trigger for INSERT on ARTISTS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_INSERT_ARTISTS_VIEW
INSTEAD OF INSERT ON ARTISTS_VIEW
DECLARE
    artist_id INT;
    fname_id INT;
    lname_id INT;
BEGIN
    -- Insert into Artists table
    INSERT INTO Artists (Nationality) VALUES (:NEW.Nationality);
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    
    -- Insert into FirstNames table and ArtistsFirstNames association table
    INSERT INTO FirstNames (FirstName) VALUES (:NEW.FirstName);
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID, Notes) VALUES (artist_id, fname_id, NULL); -- Adjusted to NULL as Notes are commented out
    
    -- Insert into LastNames table and ArtistsLastNames association table
    INSERT INTO LastNames (LastName) VALUES (:NEW.LastName);
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID, Notes) VALUES (artist_id, lname_id, NULL); -- Adjusted to NULL as Notes are commented out
END;
/

-- Trigger for UPDATE on ARTISTS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_UPDATE_ARTISTS_VIEW
INSTEAD OF UPDATE ON ARTISTS_VIEW
DECLARE
    fname_id INT;
    lname_id INT;
BEGIN
    -- Update Artists table
    UPDATE Artists SET Nationality = :NEW.Nationality WHERE ArtistID = :OLD.ArtistID;
    
    -- Update FirstNames table and ArtistsFirstNames association table
	IF :OLD.FirstName != :NEW.FirstName THEN
		UPDATE ArtistsFirstNames SET ENDTIME = CURRENT_TIMESTAMP WHERE ArtistID = :OLD.ArtistID AND ENDTIME IS NULL;
		INSERT INTO FirstNames (FirstName) VALUES (:NEW.FirstName);
		SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
		INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID, Notes) VALUES (:OLD.ArtistID, fname_id, NULL); -- Adjusted to NULL as Notes are commented out
    END IF;
	
    -- Update LastNames table and ArtistsLastNames association table
	IF :OLD.LastName != :NEW.LastName THEN
		UPDATE ArtistsLastNames SET ENDTIME = CURRENT_TIMESTAMP WHERE ArtistID = :OLD.ArtistID AND ENDTIME IS NULL;
		INSERT INTO LastNames (LastName) VALUES (:NEW.LastName);
		SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
		INSERT INTO ArtistsLastNames (ArtistID, LastNameID, Notes) VALUES (:OLD.ArtistID, lname_id, NULL); -- Adjusted to NULL as Notes are commented out
	END IF;
END;
/

-- Trigger for DELETE on ARTISTS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_DELETE_ARTISTS_VIEW
INSTEAD OF DELETE ON ARTISTS_VIEW
BEGIN

    -- Delete FirstNames table
    DELETE FROM FirstNames WHERE FirstNameID IN (
        SELECT FirstNameID FROM ArtistsFirstNames WHERE ArtistID = :OLD.ArtistID
    );

    -- Delete LastNames table
	DELETE FROM LastNames WHERE LastNameID IN (
    SELECT LastNameID FROM ArtistsLastNames WHERE ArtistID = :OLD.ArtistID
    );
	
    -- Delete associations in ArtistsFirstNames and ArtistsLastNames
    DELETE FROM ArtistsFirstNames WHERE ArtistID = :OLD.ArtistID;
    DELETE FROM ArtistsLastNames WHERE ArtistID = :OLD.ArtistID;

    -- Delete from Artists table
    DELETE FROM Artists WHERE ArtistID = :OLD.ArtistID;
END;
/

-- Trigger for INSERT on TRACKS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_INSERT_TRACKS_VIEW
INSTEAD OF INSERT ON TRACKS_VIEW
DECLARE
    track_id INT;
    title_id INT;
BEGIN
    -- Insert into Tracks table
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES (:NEW.Length, :NEW.RecordID, :NEW.RecordingDate);
    SELECT MAX(TrackID) INTO track_id FROM Tracks;

    -- Insert into Titles table and TracksTitles association table
    INSERT INTO Titles (Title) VALUES (:NEW.Title);
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO TracksTitles (TrackID, TitleID, Notes) VALUES (track_id, title_id, NULL); -- Adjusted to NULL as Notes are commented out
END;
/

-- Trigger for UPDATE on TRACKS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_UPDATE_TRACKS_VIEW
INSTEAD OF UPDATE ON TRACKS_VIEW
DECLARE
    title_id INT;
BEGIN
    -- Update Tracks table
    UPDATE Tracks SET Length = :NEW.Length, RecordID = :NEW.RecordID, RecordingDate = :NEW.RecordingDate WHERE TrackID = :OLD.TrackID;

    -- Update Titles table and TracksTitles association table
	IF :OLD.Title != :NEW.Title THEN
		UPDATE TracksTitles SET ENDTIME = CURRENT_TIMESTAMP WHERE TrackID = :OLD.TrackID AND ENDTIME IS NULL;
		INSERT INTO Titles (Title) VALUES (:NEW.Title);
		SELECT MAX(TitleID) INTO title_id FROM Titles;
		INSERT INTO TracksTitles (TrackID, TitleID, Notes) VALUES (:OLD.TrackID, title_id, NULL); -- Adjusted to NULL as Notes are commented out
	END IF;		
END;
/

-- Trigger for DELETE on TRACKS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_DELETE_TRACKS_VIEW
INSTEAD OF DELETE ON TRACKS_VIEW
BEGIN

    -- Delete from Titles table
    DELETE FROM Titles WHERE TitleID IN (
        SELECT TitleID FROM TracksTitles WHERE TrackID = :OLD.TrackID
    );
    -- Delete from TracksTitles table
    DELETE FROM TracksTitles WHERE TrackID = :OLD.TrackID;

    -- Delete from Tracks table
    DELETE FROM Tracks WHERE TrackID = :OLD.TrackID;
END;
/


-- Trigger for INSERT on VINYL_RECORDS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_INSERT_VINYL_RECORDS_VIEW
INSTEAD OF INSERT ON VINYL_RECORDS_VIEW
DECLARE
    record_id INT;
    label_id INT;
BEGIN
    -- Insert into VinylRecords table
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES (:NEW.Title, :NEW.Genre, :NEW.ReleaseDate);
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;

    -- Insert into RecordLabels table and VinylRecordsRecordLabels association table
    INSERT INTO RecordLabels (RecordLabel) VALUES (:NEW.RecordLabel);
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID, Notes) VALUES (record_id, label_id, NULL); -- Adjusted to NULL as Notes are commented out
END;
/

-- Trigger for UPDATE on VINYL_RECORDS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_UPDATE_VINYL_RECORDS_VIEW
INSTEAD OF UPDATE ON VINYL_RECORDS_VIEW
DECLARE
    label_id INT;
BEGIN
    -- Update VinylRecords table
    UPDATE VinylRecords SET Title = :NEW.Title, Genre = :NEW.Genre, ReleaseDate = :NEW.ReleaseDate WHERE RecordID = :OLD.RecordID;

    -- Check if the RecordLabel is being updated
    IF :OLD.RecordLabel != :NEW.RecordLabel THEN
        -- Update RecordLabels table and VinylRecordsRecordLabels association table
        UPDATE VinylRecordsRecordLabels SET ENDTIME = CURRENT_TIMESTAMP WHERE RecordID = :OLD.RecordID AND ENDTIME IS NULL;
        INSERT INTO RecordLabels (RecordLabel) VALUES (:NEW.RecordLabel);
        SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
        INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID, Notes) VALUES (:OLD.RecordID, label_id, NULL); -- Adjusted to NULL as Notes are commented out
    END IF;
END;
/

-- Trigger for DELETE on VINYL_RECORDS_VIEW
CREATE OR REPLACE TRIGGER INSTEAD_OF_DELETE_VINYL_RECORDS_VIEW
INSTEAD OF DELETE ON VINYL_RECORDS_VIEW
BEGIN

    -- Delete from RecordLabels table
    DELETE FROM RecordLabels WHERE RecordLabelID IN (
        SELECT RecordLabelID FROM VinylRecordsRecordLabels WHERE RecordID = :OLD.RecordID
    );
  
    -- Delete from VinylRecordsRecordLabels table
    DELETE FROM VinylRecordsRecordLabels WHERE RecordID = :OLD.RecordID;

    -- Delete from VinylRecords table
    DELETE FROM VinylRecords WHERE RecordID = :OLD.RecordID;
END;
/

-- Insert into VinylRecords and RecordLabels
DECLARE
    record_id INT;
    label_id INT;
BEGIN
    INSERT INTO RecordLabels (RecordLabel) VALUES ('Apple Records');
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES ('Abbey Road', 'Rock', TO_DATE('1969-09-26', 'YYYY-MM-DD'));
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID) VALUES (record_id, label_id);

    INSERT INTO RecordLabels (RecordLabel) VALUES ('Columbia Records');
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES ('Kind of Blue', 'Jazz', TO_DATE('1959-08-17', 'YYYY-MM-DD'));
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID) VALUES (record_id, label_id);

    INSERT INTO RecordLabels (RecordLabel) VALUES ('Harvest Records');
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES ('The Dark Side of the Moon', 'Rock', TO_DATE('1973-03-01', 'YYYY-MM-DD'));
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID) VALUES (record_id, label_id);

    INSERT INTO RecordLabels (RecordLabel) VALUES ('Warner Bros. Records');
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES ('Rumours', 'Rock', TO_DATE('1977-02-04', 'YYYY-MM-DD'));
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID) VALUES (record_id, label_id);

    INSERT INTO RecordLabels (RecordLabel) VALUES ('Epic Records');
    SELECT MAX(RecordLabelID) INTO label_id FROM RecordLabels;
    INSERT INTO VinylRecords (Title, Genre, ReleaseDate) VALUES ('Thriller', 'Pop', TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(RecordID) INTO record_id FROM VinylRecords;
    INSERT INTO VinylRecordsRecordLabels (RecordID, RecordLabelID) VALUES (record_id, label_id);
END;
/


-- Insert into Artists, FirstNames, and LastNames
DECLARE
    artist_id INT;
    fname_id INT;
    lname_id INT;
BEGIN
    INSERT INTO FirstNames (FirstName) VALUES ('John');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Williams');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Canadian');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Emily');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Davis');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Canadian');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('David');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Johnson');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('American');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Chris');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('King');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('American');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Alex');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Davis');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('American');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Paul');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('McCartney');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Canadian');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('George');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Harrison');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Chinese');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Jane');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Miller');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Chinese');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Mick');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Wilson');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Chinese');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Ringo');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Starr');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('British');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Katie');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Taylor');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('British');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Sarah');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Smith');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('British');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Freddie');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Mercury');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('German');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);

    INSERT INTO FirstNames (FirstName) VALUES ('Bill');
    SELECT MAX(FirstNameID) INTO fname_id FROM FirstNames;
    INSERT INTO LastNames (LastName) VALUES ('Evans');
    SELECT MAX(LastNameID) INTO lname_id FROM LastNames;
    INSERT INTO Artists (Nationality) VALUES ('Irish');
    SELECT MAX(ArtistID) INTO artist_id FROM Artists;
    INSERT INTO ArtistsFirstNames (ArtistID, FirstNameID) VALUES (artist_id, fname_id);
    INSERT INTO ArtistsLastNames (ArtistID, LastNameID) VALUES (artist_id, lname_id);
END;
/

-- Insert into Producer
INSERT INTO Producer (ArtistID, Type) VALUES (1, 'Line');
INSERT INTO Producer (ArtistID, Type) VALUES (2, 'Executive');
INSERT INTO Producer (ArtistID, Type) VALUES (6, 'Development');
INSERT INTO Producer (ArtistID, Type) VALUES (10, 'Digital');
INSERT INTO Producer (ArtistID, Type) VALUES (12, 'Creative');
INSERT INTO Producer (ArtistID, Type) VALUES (13, 'Creative');
INSERT INTO Producer (ArtistID, Type) VALUES (14, 'Digital');

-- Insert into Musician
INSERT INTO Musician (ArtistID, Instrument) VALUES (3, 'Piano');

-- Insert into SongWriter
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (4, 'Pop');
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (5, 'Pop');
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (7, 'Rock');
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (8, 'Rock');
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (9, 'Hip-Hop');
INSERT INTO SongWriter (ArtistID, GenreSpecialization) VALUES (11, 'Jazz');

-- Insert into Tracks and Titles
DECLARE
    track_id INT;
    title_id INT;
BEGIN
    INSERT INTO Titles (Title) VALUES ('Come Together');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:19', 1, TO_DATE('1969-07-21', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Something');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:03', 1, TO_DATE('1969-07-22', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Maxwells Silver Hammer');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:27', 1, TO_DATE('1969-07-23', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Oh! Darling');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:26', 1, TO_DATE('1969-07-24', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Octopuss Garden');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:51', 1, TO_DATE('1969-07-25', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('I Want You (Shes So Heavy)');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('07:47', 1, TO_DATE('1969-07-26', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Here Comes the Sun');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:05', 1, TO_DATE('1969-07-27', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Because');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:45', 1, TO_DATE('1969-07-28', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('You Never Give Me Your Money');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:02', 1, TO_DATE('1969-07-29', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Sun King');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:26', 1, TO_DATE('1969-07-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Mean Mr. Mustard');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:06', 1, TO_DATE('1969-07-31', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Polythene Pam');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:12', 1, TO_DATE('1969-08-01', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('She Came In Through the Bathroom Window');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:57', 1, TO_DATE('1969-08-02', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Golden Slumbers');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:31', 1, TO_DATE('1969-08-03', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Carry That Weight');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:36', 1, TO_DATE('1969-08-04', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('The End');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:19', 1, TO_DATE('1969-08-05', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Her Majesty');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('00:23', 1, TO_DATE('1969-08-06', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('So What');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('09:22', 2, TO_DATE('1959-03-02', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Freddie Freeloader');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('09:46', 2, TO_DATE('1959-03-03', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Blue in Green');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('05:37', 2, TO_DATE('1959-03-04', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('All Blues');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('11:33', 2, TO_DATE('1959-03-05', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Flamenco Sketches');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('09:26', 2, TO_DATE('1959-03-06', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Speak to Me');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('01:30', 3, TO_DATE('1973-01-01', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Breathe');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:43', 3, TO_DATE('1973-01-02', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('On the Run');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:45', 3, TO_DATE('1973-01-03', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Time');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('06:53', 3, TO_DATE('1973-01-04', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('The Great Gig in the Sky');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:44', 3, TO_DATE('1973-01-05', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Money');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('06:23', 3, TO_DATE('1973-01-06', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Us and Them');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('07:48', 3, TO_DATE('1973-01-07', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Any Colour You Like');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:26', 3, TO_DATE('1973-01-08', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Brain Damage');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:50', 3, TO_DATE('1973-01-09', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Eclipse');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:06', 3, TO_DATE('1973-01-10', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Dreams');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:17', 4, TO_DATE('1977-02-04', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Never Going Back Again');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('02:14', 4, TO_DATE('1977-02-05', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Dont Stop');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:11', 4, TO_DATE('1977-02-06', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Go Your Own Way');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:43', 4, TO_DATE('1977-02-07', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Songbird');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:20', 4, TO_DATE('1977-02-08', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('The Chain');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:28', 4, TO_DATE('1977-02-09', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('You Make Loving Fun');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:36', 4, TO_DATE('1977-02-10', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('I Dont Want to Know');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:11', 4, TO_DATE('1977-02-11', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Oh Daddy');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:58', 4, TO_DATE('1977-02-12', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Gold Dust Woman');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:51', 4, TO_DATE('1977-02-13', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Wanna Be Startin Somethin');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('06:03', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Baby Be Mine');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:20', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('The Girl Is Mine');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('03:42', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Thriller');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('05:57', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Beat It');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:18', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);

    INSERT INTO Titles (Title) VALUES ('Billie Jean');
    SELECT MAX(TitleID) INTO title_id FROM Titles;
    INSERT INTO Tracks (Length, RecordID, RecordingDate) VALUES ('04:54', 5, TO_DATE('1982-11-30', 'YYYY-MM-DD'));
    SELECT MAX(TrackID) INTO track_id FROM Tracks;
    INSERT INTO TracksTitles (TrackID, TitleID) VALUES (track_id, title_id);
END;
/

-- Insert into Relationships
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (1, 1, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (1, 2, 'Bassist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (1, 3, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (1, 4, 'Drummer');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (2, 5, 'Trumpeter');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (2, 6, 'Pianist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (3, 7, 'Vocalist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (3, 8, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 9, 'Vocalist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 10, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 11, 'Drummer');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (5, 12, 'Pianist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (5, 13, 'Vocalist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (3, 14, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (3, 14, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 9, 'Vocalist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 10, 'Guitarist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (4, 11, 'Drummer');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (5, 12, 'Pianist');
INSERT INTO Relationships (RecordID, ArtistID, Role) VALUES (5, 13, 'Vocalist');

-- Insert into Invoices
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-01-15', 'YYYY-MM-DD'), 'Mark Johnson');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-02-20', 'YYYY-MM-DD'), 'Alice Smith');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-03-10', 'YYYY-MM-DD'), 'Bob Brown');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-04-05', 'YYYY-MM-DD'), 'Catherine Wilson');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-05-15', 'YYYY-MM-DD'), 'David Lee');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-06-20', 'YYYY-MM-DD'), 'Emily Clark');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-07-25', 'YYYY-MM-DD'), 'Frank Miller');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-08-30', 'YYYY-MM-DD'), 'Grace Davis');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-09-10', 'YYYY-MM-DD'), 'Harry Johnson');
INSERT INTO Invoices (OrderDate, CustomerName) VALUES (TO_DATE('2023-10-15', 'YYYY-MM-DD'), 'Ivy Moore');


-- Insert into LineItems
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (1, 1, 1, 19.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (1, 2, 1, 17.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (2, 3, 1, 25.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (2, 4, 1, 22.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (3, 5, 1, 21.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (3, 4, 1, 18.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (4, 3, 1, 20.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (4, 2, 1, 23.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (5, 1, 1, 19.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (5, 2, 1, 17.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (6, 3, 1, 25.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (6, 4, 1, 22.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (7, 5, 1, 21.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (7, 4, 1, 18.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (8, 3, 1, 20.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (8, 2, 1, 23.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (9, 1, 1, 19.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (9, 2, 1, 17.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 3, 1, 25.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 4, 1, 22.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 5, 1, 21.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 1, 1, 18.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 2, 1, 20.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (10, 3, 1, 23.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (9, 4, 1, 19.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (9, 5, 1, 17.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (8, 1, 1, 25.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (8, 2, 1, 22.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (7, 3, 1, 21.99);
INSERT INTO LineItems (InvoiceID, RecordID, Quantity, Price) VALUES (7, 4, 1, 18.99);

COMMIT;
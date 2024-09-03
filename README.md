# Vinyl Recording Collection Management

## Overview
**Vinyl Recording Collection Management** is a database application designed to help users efficiently manage and organize their vinyl record collections. This project uses **Microsoft Access** as the front-end interface and **Oracle 19c** as the back-end database, ensuring robust data management and scalability. The application enhances functionality by implementing multi-valued historical data fields and creating a historical data framework, allowing users to track changes over time.

## Author
**Shoujun Zhao**  
- Email: zhao0282@algonquinlive.com

## Key Features
- **Hierarchical Grouping**: Vinyl records and artists are grouped by categories such as genre and nationality.
- **Complex Relationships**: The database supports is-a relationships (e.g., 'Musician' as a type of 'Artist'), contains relationships (e.g., a vinyl record containing tracks), and related-to relationships (e.g., many-to-many relationships between artists and records).
- **Multi-Valued Historical Data**: Introduces tables to store multi-valued historical data with timestamps, replacing single-valued fields to track changes over time.
- **Enhanced Data Integrity**: Oracle 19c back-end ensures data integrity and supports complex queries and relationships.

## Database Schema and Relationships

### Artists
- **Old Schema**: 
  - `Artists`: Artist ID (PK), First Name, Last Name, Nationality
- **New Schema**: 
  - `Artists`: Artist ID (PK), Nationality
  - `FirstNames`: FirstName ID (PK), FirstName
  - `LastNames`: LastName ID (PK), LastName
  - `ArtistsFirstNames`: Artist ID (FK), FirstName ID (FK), STARTTIME, ENDTIME, Notes
  - `ArtistsLastNames`: Artist ID (FK), LastName ID (FK), STARTTIME, ENDTIME, Notes

### Tracks
- **Old Schema**: 
  - `Tracks`: Track ID (PK), Title, Length, Record ID (FK), Recording Date
- **New Schema**: 
  - `Tracks`: Track ID (PK), Length, Record ID (FK), Recording Date
  - `Titles`: Title ID (PK), Title
  - `TracksTitles`: Title ID (FK), Track ID (FK), STARTTIME, ENDTIME, Notes

### Vinyl Records
- **Old Schema**: 
  - `VinylRecords`: Record ID (PK), Title, Genre, Release Date, Record Label
- **New Schema**: 
  - `VinylRecords`: Record ID (PK), Title, Genre, Release Date
  - `RecordLabels`: Record Labels ID (PK), Record Label
  - `VinylRecordsRecordLabels`: Record ID (FK), Record Labels ID (FK), STARTTIME, ENDTIME, Notes

### Other Tables
- **Producer**: Producer ID (PK), Artist ID (FK), Type
- **Musician**: Musician ID (PK), Artist ID (FK), Instrument
- **Songwriter**: Songwriter ID (PK), Artist ID (FK), Genre Specialization
- **Relationships**: Record ID (FK), Artist ID (FK), Role (e.g., guitarist, vocalist)
- **Invoices**: Invoice ID (PK), Order Date, Customer Name
- **Line Items**: Line Item ID (PK), Invoice ID (FK), Record ID (FK), Quantity, Price

## Benefits
- **Centralized Management**: Comprehensive database for managing vinyl record collections, ensuring easy retrieval and organization of records, artists, and tracks.
- **Detailed Tracking**: Track purchases and sales with invoice management, ensuring an accurate and up-to-date record of all transactions.
- **Enhanced Data Integrity**: Using Oracle's robust back-end ensures data consistency and supports complex relationships and historical tracking.

## How to Use
1. **Database Setup**:
    - Import the provided SQL schema into Oracle 19c.
    - Set up Microsoft Access as the front-end to interact with the Oracle database.
  
2. **Adding Records**:
    - Use the front-end interface to add new vinyl records, artists, tracks, and related information.
  
3. **Viewing Historical Data**:
    - Utilize the views created in the database to see historical data for artists, tracks, and records over time.
  
4. **Managing Invoices**:
    - Track sales and purchases of vinyl records by managing invoices and line items.

## Contact
For any questions or collaboration requests, feel free to reach out via email at zhao0282@algonquinlive.com.

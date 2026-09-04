CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NULL,
    Role VARCHAR(20) NOT NULL,
    ProfilePictureUrl VARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Users
        PRIMARY KEY (UserID),

    CONSTRAINT UQ_Users_Email
        UNIQUE (Email),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    EventName VARCHAR(100) NOT NULL,
    Description VARCHAR(500) NULL,
    EventDate DATE NOT NULL,
    Location VARCHAR(150) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,
    EventType VARCHAR(20) NOT NULL,
    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Events_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Events
        PRIMARY KEY (EventID),

    CONSTRAINT FK_Events_Organiser
        FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID),

    CONSTRAINT CK_Events_Distance
        CHECK (Distance > 0),

    CONSTRAINT CK_Events_EventType
        CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    MinAge INT NULL,
    MaxAge INT NULL,
    Distance DECIMAL(6,2) NULL,

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryID),

    CONSTRAINT FK_Categories_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
        ON DELETE CASCADE,

    CONSTRAINT CK_Categories_Age
        CHECK
        (
            (MinAge IS NULL AND MaxAge IS NULL)
            OR
            (MinAge >= 0 AND MaxAge >= MinAge)
        ),

    CONSTRAINT CK_Categories_Distance
        CHECK
        (
            Distance IS NULL OR Distance > 0
        )
);

CREATE TABLE Enrolments
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL
        CONSTRAINT DF_Enrolments_Date DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status DEFAULT 'Confirmed',

    CONSTRAINT PK_Enrolments
        PRIMARY KEY (EnrolmentID),

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Enrolments_Participant_Event
        UNIQUE (ParticipantID, EventID),

    CONSTRAINT CK_Enrolments_Status
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled'))
);

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,
    FinishTime TIME NOT NULL,
    FinishingPosition INT NOT NULL,
    RecordedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Results_RecordedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Results
        PRIMARY KEY (ResultID),

    CONSTRAINT FK_Results_Enrolment
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Results_Enrolment
        UNIQUE (EnrolmentID),

    CONSTRAINT CK_Results_Position
        CHECK (FinishingPosition > 0)
);

CREATE TABLE EventImages
(
    EventImageID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    ImageUrl VARCHAR(500) NOT NULL,
    ImageType VARCHAR(30) NOT NULL
        CONSTRAINT DF_EventImages_Type DEFAULT 'Banner',
    UploadedAt DATETIME2 NOT NULL
        CONSTRAINT DF_EventImages_UploadedAt DEFAULT GETDATE(),

    CONSTRAINT PK_EventImages
        PRIMARY KEY (EventImageID),

    CONSTRAINT FK_EventImages_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
        ON DELETE CASCADE
);

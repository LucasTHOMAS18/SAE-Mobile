CREATE TABLE IF NOT EXISTS User (
    idUser INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS FoodType (
    type TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS Restaurant (
    idRestau INTEGER PRIMARY KEY AUTOINCREMENT,
    city TEXT,
    nameR TEXT NOT NULL,
    schedule TEXT,
    website TEXT,
    phone TEXT,
    typeR TEXT,
    latitude REAL,
    longitude REAL,
    accessibl INTEGER NOT NULL DEFAULT 0, 
    delivery INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Photo (
    idPhoto INTEGER PRIMARY KEY AUTOINCREMENT,
    image TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Serves (
    idRestau INTEGER,
    type TEXT,
    PRIMARY KEY (idRestau, type),
    FOREIGN KEY (idRestau) REFERENCES Restaurant(idRestau) ON DELETE CASCADE,
    FOREIGN KEY (type) REFERENCES FoodType(type) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Prefers (
    idUser INTEGER,
    type TEXT,
    PRIMARY KEY (idUser, type),
    FOREIGN KEY (idUser) REFERENCES User(idUser) ON DELETE CASCADE,
    FOREIGN KEY (type) REFERENCES FoodType(type) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Illustrates (
    idPhoto INTEGER,
    idRestau INTEGER,
    PRIMARY KEY (idPhoto, idRestau),
    FOREIGN KEY (idPhoto) REFERENCES Photo(idPhoto) ON DELETE CASCADE,
    FOREIGN KEY (idRestau) REFERENCES Restaurant(idRestau) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Reviewed (
    idUser INTEGER,
    idRestau INTEGER,
    note INTEGER CHECK (note BETWEEN 0 AND 5),
    comment TEXT,
    PRIMARY KEY (idUser, idRestau),
    FOREIGN KEY (idUser) REFERENCES User(idUser) ON DELETE CASCADE,
    FOREIGN KEY (idRestau) REFERENCES Restaurant(idRestau) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Likes (
    idUser INTEGER,
    idRestau INTEGER,
    PRIMARY KEY (idUser, idRestau),
    FOREIGN KEY (idUser) REFERENCES User(idUser) ON DELETE CASCADE,
    FOREIGN KEY (idRestau) REFERENCES Restaurant(idRestau) ON DELETE CASCADE
);

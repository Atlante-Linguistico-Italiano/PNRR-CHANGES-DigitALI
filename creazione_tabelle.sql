--dati
CREATE TABLE volumi_dati (
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	alicode TEXT,
	normali TEXT,
	risposta TEXT,
	tag VARCHAR(1000),
	sigla VARCHAR(20),
	legenda VARCHAR(20),
	simbolo VARCHAR(20),
	nota VARCHAR(1),
	rifo VARCHAR(1),
	unicode TEXT,
	html TEXT,
	voce VARCHAR(12) NOT NULL,
	volume INTEGER NOT NULL
);

--note
CREATE TABLE volumi_note (
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	note_alicode TEXT,
	note_normali TEXT,
	note_unicode TEXT,
	note_html TEXT,
	nota VARCHAR(1),
	voce VARCHAR(12),
	volume INTEGER NOT NULL
);

--rifo
CREATE TABLE volumi_rifo (
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	rifo_alicode TEXT,
	rifo_normali TEXT,
	rifo_unicode TEXT,
	rifo_html TEXT,
	rifo TEXT,
	voce VARCHAR(12),
	volume INTEGER NOT NULL
);

--informatori
CREATE TABLE informatori (
	inf_id VARCHAR(13) NOT NULL PRIMARY KEY,
	loc TEXT NOT NULL,
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	sigla VARCHAR(10),
	num_inf INTEGER NOT NULL,
	nome_cognome TEXT NOT NULL,
	eta VARCHAR(10),
	eta_c INTEGER
	genere VARCHAR(1),
	anno_nascita VARCHAR(10),
	dimora_breve TEXT,
	dimora_lunga TEXT,
	dimora_padre TEXT,
	dimora_madre TEXT,
	grado_cultura TEXT,
	note TEXT,
	inchiesta VARCHAR(7) NOT NULL,
	lng NUMERIC NOT NULL,
	lat NUMERIC NOT NULL
);

--geometria
ALTER TABLE informatori ADD COLUMN geom geometry(Point, 4326);

UPDATE informatori SET geom = ST_SetSRID(ST_MakePoint(lat,lng), 4326);

--punti
CREATE TABLE punti (
	punto_or INTEGER NOT NULL,
	punto INTEGER NOT NULL,
	codice_or VARCHAR(6) NOT NULL,
	codice VARCHAR(5) NOT NULL,
	loc_or TEXT NOT NULL,
	loc TEXT NOT NULL,
	comune TEXT,
	provincia TEXT NOT NULL,	
	regione TEXT NOT NULL,
);

--inchieste
CREATE TABLE inchieste (
	inchiesta_id VARCHAR(8) NOT NULL,
	inchiesta_or VARCHAR(6) NOT NULL,
	inchiesta_c INTEGER NOT NULL,
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	raccoglitore VARCHAR(12) NOT NULL,
	anno INTEGER NOT NULL
);

--informatori_voci
CREATE TABLE inf_voci (
	inf_id VARCHAR(13),
	punto INTEGER,
	codice VARCHAR(5),
	sigla TEXT,
	voci TEXT
);

--questionario
CREATE TABLE questionario (
	voce VARCHAR(10) NOT NULL,
	voce_id INTEGER NOT NULL PRIMARY KEY,
	testo_domanda TEXT NOT NULL,
	titolo_carta TEXT,
	carta VARCHAR(10),
	parte VARCHAR(7),
	volume VARCHAR(7)
);

--fotografie
CREATE TABLE fotografie (
	id_foto INTEGER NOT NULL PRIMARY KEY,
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	link_sff TEXT,
	titolo_sff TEXT
);

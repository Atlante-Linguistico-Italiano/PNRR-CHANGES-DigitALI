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
	doppia VARCHAR(2),
	unicode TEXT,
	html TEXT,
	voce VARCHAR(12) NOT NULL,
	volume INTEGER NOT NULL
);

--note
CREATE TABLE volumi_note (
	punto INTEGER NOT NULL,
	codice VARCHAR(5) NOT NULL,
	alicode TEXT,
	normali TEXT,
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
	alicode TEXT,
	normali TEXT,
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
	sigla VARCHAR(10), --forse non serve
	num_inf INTEGER NOT NULL,
	nome_cognome TEXT NOT NULL,
	eta VARCHAR(10),
	eta_c INTEGER
	genere VARCHAR(1),
	anno_nascita VARCHAR(10),
	anno_nascita_c INTEGER,
	dimora_breve TEXT,
	dimora_lunga TEXT,
	dimora_padre TEXT,
	dimora_madre TEXT,
	professione TEXT,
	professione_c TEXT,
	grado_cultura TEXT,
	grado_cultura_c TEXT,
	note TEXT,
	inchiesta VARCHAR(7) NOT NULL,
	inchiesta_c INTEGER NOT NULL,
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
	comunicazioni TEXT,
	scuole TEXT,
	giur_eccl TEXT,
	loc_vill TEXT,
	staz_sport TEXT,
	tassa_sogg TEXT,
	alberghi TEXT,
	fiere TEXT,
	mercati TEXT,
	note TEXT
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
create table inf_voci (
	inf_id VARCHAR(13),
	punto INTEGER,
	codice VARCHAR(5),
	sigla TEXT,
	voci json
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

);

--indici
CREATE INDEX vol_voci_index on volumi_dati(voce);
CREATE INDEX inf_voci_index on inf_voci_np(inf_id);
CREATE INDEX ON inf_voci USING gin (voci_or jsonb_path_ops);

--VISUALIZZAZIONI

--db completo
 SELECT v.punto,
    v.codice,
    v.testo,
    v.normali,
    v.norm,
    v.tag,
    v.sigla,
    v.legenda,
    v.simbolo,
    v.nota,
    v.rifo,
    v.doppia,
    v.unicode,
    v.html,
    v.voce,
    v.vol,
    n.note_unicode,
    n.note_html,
    f.rifo_unicode,
    f.rifo_html,
    i.inf_id,
    i.nomecognome,
    i.annonascita,
    i.eta,
    i.genere,
    i.professione,
    i.gradocultura
   FROM volumi_dati v
     LEFT JOIN volumi_note n ON n.punto = v.punto AND n.codice::text = v.codice::text AND n.voce::text = v.voce::text AND n.nota::text = v.nota::text
     LEFT JOIN volumi_rifo f ON f.punto = v.punto AND f.codice::text = v.codice::text AND f.voce::text = v.voce::text AND f.rifo::text = v.rifo::text
     LEFT JOIN inf_voci iv ON v.codice::text = iv.codice::text AND v.punto = iv.punto AND (iv.voci_or @> to_jsonb(ARRAY[v.voce]) OR COALESCE(jsonb_array_length(iv.voci_or), 0) = 0) AND NOT v.sigla::text IS DISTINCT FROM iv.sigla::text
     LEFT JOIN informatori i ON i.inf_id::text = iv.inf_id::text;
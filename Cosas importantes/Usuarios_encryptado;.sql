CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE Usuarios (
    id INT8 PRIMARY KEY,
    nombre_usuario VARCHAR(30) NOT NULL unique,
    correo BYTEA NOT NULL,
    contrasena BYTEA NOT NULL, 
    edad INT4,
    especie varchar NOT NULL,
    credenciales varchar NOT NULL
);

INSERT INTO Usuarios (id, nombre_usuario, correo, contrasena, edad, especie, credenciales) 
VALUES  (1, 'Cosmo', 'cs@gmail.com', 'Cosmo', 23, 'Dalmata', 'Administrador'),
        (2, 'Yami', 'ym@gmail.com', 'Yami', 23, 'Humano', 'Cliente'),
        (3, 'Neuro', 'nr@gmail.com', 'Neuro', 25, 'Gato', 'Vendedor');

CREATE OR REPLACE FUNCTION encrypt_user_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.correo IS DISTINCT FROM OLD.correo) THEN
        NEW.correo = pgcrypto.pgp_sym_encrypt(
            NEW.correo::text, 
            'COSMO' -- Clave de encriptación
        );
    END IF;

    -- Encriptar el campo 'contrasena'
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.contrasena IS DISTINCT FROM OLD.contrasena) THEN
        NEW.contrasena = pgcrypto.pgp_sym_encrypt(
            NEW.contrasena::text, 
            'COSMO' -- Misma clave (simétrica)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_encrypt_user_fields
BEFORE INSERT OR UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION encrypt_user_fields();
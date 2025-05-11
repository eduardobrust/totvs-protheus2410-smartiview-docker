CREATE USER userprotheus WITH PASSWORD 'a12345';
ALTER USER userprotheus WITH SUPERUSER;

CREATE DATABASE dbprotheus
    ENCODING 'WIN1252'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
	OWNER userprotheus
    TEMPLATE template1;

-- Criar o usuário
CREATE USER usersmartview WITH PASSWORD 'a12345';
ALTER USER usersmartview WITH SUPERUSER;

-- Permitir acesso ao banco 'postgres' para verificar os acessos
GRANT CONNECT ON DATABASE postgres TO usersmartview;
GRANT USAGE ON SCHEMA public TO usersmartview;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usersmartview;

CREATE DATABASE dbsmartview
  ENCODING 'WIN1252'
  LC_COLLATE = 'C'
  LC_CTYPE = 'C'
  OWNER usersmartview
  TEMPLATE template1;
 





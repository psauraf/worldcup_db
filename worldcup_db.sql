PGDMP      
                |           mundial    16.0    16.0 6    ]           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ^           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            _           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            `           1262    16749    mundial    DATABASE     �   CREATE DATABASE mundial WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';
    DROP DATABASE mundial;
             
   pedrosaura    false            a           0    0    DATABASE mundial    ACL     -   GRANT ALL ON DATABASE mundial TO admin_user;
                
   pedrosaura    false    3680            n           1247    17428    mundial_record    TYPE     �   CREATE TYPE public.mundial_record AS (
	nombre_jugador character varying(100),
	puesto_habitual character varying(50),
	equipo character varying(100),
	minutos_jugados numeric,
	cantidad_partidos numeric,
	goles_marcados numeric
);
 !   DROP TYPE public.mundial_record;
       public       
   pedrosaura    false            �            1255    17421    actualizar_alumno()    FUNCTION     �  CREATE FUNCTION public.actualizar_alumno() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_secuencia INT;
BEGIN
    -- Insertar el alumno y obtener la secuencia
    INSERT INTO ALUMNOS (DNI, NOMBRE, TELEFONO)
    VALUES ('DNI'||nextval('secuencia_alumnos'), 'Pedro', 645969595)
    RETURNING currval('secuencia_alumnos') INTO v_secuencia;

    -- Actualizar la fila del alumno insertado cambiando su nombre y teléfono
    UPDATE ALUMNOS
    SET NOMBRE = 'Maikel', TELEFONO = 696969696
    WHERE DNI = 'DNI' || v_secuencia;

    -- Imprimir la información del alumno actualizado
    RAISE NOTICE 'Alumno actualizado. DNI: %, Nuevo nombre: %, Nuevo teléfono: %', 'DNI' || v_secuencia, 'Maikel', 696969696;
END;
$$;
 *   DROP FUNCTION public.actualizar_alumno();
       public       
   pedrosaura    false            �            1255    17434 !   calcular_record(integer, integer)    FUNCTION     �  CREATE FUNCTION public.calcular_record(mundial integer DEFAULT NULL::integer, anio integer DEFAULT NULL::integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    record_result RECORD;
BEGIN
    record_result := ROW(0, 0, 0, 0, 0, 0, 0, '', 0, 0);

    SELECT COUNT(*) INTO record_result.partidos_jugados FROM partido;

    SELECT COUNT(*) INTO record_result.partidos_ganados FROM partido WHERE resultado_l > resultado_v;

    SELECT COUNT(*) INTO record_result.partidos_perdidos FROM partido WHERE resultado_l < resultado_v;

    SELECT COUNT(*) INTO record_result.partidos_empatados FROM partido WHERE resultado_l = resultado_v;

    SELECT SUM(resultado_l) INTO record_result.goles_a_favor FROM partido;

    SELECT SUM(resultado_v) INTO record_result.goles_en_contra FROM partido;

    record_result.goles_totales := record_result.goles_a_favor + record_result.goles_en_contra;

    SELECT equipo_jugador, COUNT(*) INTO record_result.max_goleador, record_result.goles_max_goleador
    FROM gol g
    JOIN jugador j ON g.jugador_gol = j.nombre
    GROUP BY equipo_jugador
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    record_result.puntos_obtenidos := (record_result.partidos_ganados * 3) + (record_result.partidos_empatados * 1);

    RETURN record_result;
END;
$$;
 E   DROP FUNCTION public.calcular_record(mundial integer, anio integer);
       public       
   pedrosaura    false            �            1255    17424    imprimir_cambios_alumno()    FUNCTION     �   CREATE FUNCTION public.imprimir_cambios_alumno() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_secuencia INT;
BEGIN
    DELETE FROM ALUMNOS WHERE DNI = 'DNI' || v_secuencia;
END;
$$;
 0   DROP FUNCTION public.imprimir_cambios_alumno();
       public       
   pedrosaura    false            �            1255    17409 "   imprimir_numeros(integer, integer)    FUNCTION     �  CREATE FUNCTION public.imprimir_numeros(numero1 integer, numero2 integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    output TEXT := '';
    contador INT;
    suma INT := 0;
    cantidad_pares INT := 0;
    cantidad_impares INT := 0;
    cantidad_positivos INT := 0;
    cantidad_negativos INT := 0;
    inicio INT;
    fin INT;
BEGIN
    IF numero1 IS NULL THEN
        numero1 := -5;
    END IF;
    IF numero2 IS NULL THEN
        numero2 := -5;
    END IF;
    IF numero1 IS NULL AND numero2 IS NULL THEN
        numero1 := -5;
        numero2 := 5;
    END IF;

    IF numero1 > numero2 THEN
        inicio := numero1;
        fin := numero2;
    ELSE
        inicio := numero2;
        fin := numero1;
    END IF;

    output := 'Números de mayor a menor:' || CHR(13);

    FOR contador IN inicio..fin LOOP
        output := output || contador::TEXT || ', ';
        suma := suma + contador;
        IF contador % 2 = 0 THEN
            cantidad_pares := cantidad_pares + 1;
        ELSE
            cantidad_impares := cantidad_impares + 1;
        END IF;

        IF contador >= 0 THEN
            cantidad_positivos := cantidad_positivos + 1;
        ELSE
            cantidad_negativos := cantidad_negativos + 1;
        END IF;
    END LOOP;

    output := LEFT(output, LENGTH(output) - 2) || CHR(13);

    output := output || 'Cantidad total de números: ' || CAST(ABS(inicio - fin) + 1 AS TEXT) || CHR(13);
    output := output || 'Suma de los números: ' || CAST(suma AS TEXT) || CHR(13);
    output := output || 'Cantidad de números pares: ' || CAST(cantidad_pares AS TEXT) || CHR(13);
    output := output || 'Cantidad de números impares: ' || CAST(cantidad_impares AS TEXT) || CHR(13);
    output := output || 'Cantidad de números positivos: ' || CAST(cantidad_positivos AS TEXT) || CHR(13);
    output := output || 'Cantidad de números negativos: ' || CAST(cantidad_negativos AS TEXT) || CHR(13);

    RETURN output;
END;
$$;
 I   DROP FUNCTION public.imprimir_numeros(numero1 integer, numero2 integer);
       public       
   pedrosaura    false            �            1255    17423    insertar_alumno()    FUNCTION     z  CREATE FUNCTION public.insertar_alumno() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_secuencia INT;
    v_dni_insertado VARCHAR;
BEGIN
    -- Insertar el alumno y obtener la secuencia
    INSERT INTO ALUMNOS (DNI, NOMBRE, TELEFONO)
    VALUES ('DNI'||nextval('secuencia_alumnos'), 'Pedro', 645969595)
    RETURNING DNI INTO v_dni_insertado;

    -- Imprimir la secuencia del alumno insertado
    SELECT currval('secuencia_alumnos') INTO v_secuencia;

    -- Imprimir la información del alumno insertado
    RAISE NOTICE 'Alumno insertado. DNI: %, Nombre: %, Teléfono: %', v_dni_insertado, 'Pedro', 645969595;
END;
$$;
 (   DROP FUNCTION public.insertar_alumno();
       public       
   pedrosaura    false            �            1255    17425 b   insertar_jugador(character varying, character varying, character varying, date, character varying)    FUNCTION     7  CREATE FUNCTION public.insertar_jugador(p_nombre character varying, p_direccion character varying, p_puesto_hab character varying, p_fecha_nac date, p_equipo_jugador character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_error VARCHAR(200);
BEGIN
    BEGIN
        -- Comprobar si el jugador ya existe en la tabla
        SELECT 'El jugador ya existe' INTO v_error FROM JUGADOR WHERE nombre = p_nombre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- El jugador no existe, continuar con la inserción o actualización
            NULL;
    END;
    
    BEGIN
        -- Comprobar si el equipo del jugador existe en la tabla EQUIPOS
        SELECT 'El equipo no existe' INTO v_error FROM EQUIPOS WHERE equipo = p_equipo_jugador;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- El equipo no existe, mostrar el error y salir
            RETURN 'Error: El equipo especificado no existe en la tabla EQUIPOS';
    END;
    
    BEGIN
        -- Comprobar si la fecha de nacimiento es válida
        IF p_fecha_nac > CURRENT_DATE THEN
            RETURN 'Error: La fecha de nacimiento es posterior a la fecha actual';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: Se ha producido un error al validar la fecha de nacimiento';
    END;
END;
$$;
 �   DROP FUNCTION public.insertar_jugador(p_nombre character varying, p_direccion character varying, p_puesto_hab character varying, p_fecha_nac date, p_equipo_jugador character varying);
       public       
   pedrosaura    false            �            1255    17422    insertar_y_actualizar_alumno()    FUNCTION       CREATE FUNCTION public.insertar_y_actualizar_alumno() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_secuencia INT;
    v_nombre_anterior ALUMNOS.NOMBRE%TYPE;
    v_telefono_anterior ALUMNOS.TELEFONO%TYPE;
BEGIN
    -- Insertar el alumno y obtener la secuencia
    INSERT INTO ALUMNOS (DNI, NOMBRE, TELEFONO)
    VALUES ('DNI'||nextval('secuencia_alumnos'), 'Maikel', 685271094)
    RETURNING currval('secuencia_alumnos') INTO v_secuencia;

    -- Obtener el nombre y el teléfono anterior
    SELECT NOMBRE, TELEFONO INTO v_nombre_anterior, v_telefono_anterior
    FROM ALUMNOS 
    WHERE DNI = 'DNI' || v_secuencia;

    -- Actualizar la fila del alumno insertado cambiando su nombre y teléfono
    UPDATE ALUMNOS
    SET NOMBRE = 'Nuevo Nombre', TELEFONO = 987654321
    WHERE DNI = 'DNI' || v_secuencia;

    -- Imprimir la información
    RAISE NOTICE 'Nombre anterior: %, Teléfono anterior: %', v_nombre_anterior, v_telefono_anterior;
    RAISE NOTICE 'Nombre nuevo: %, Teléfono nuevo: %', 'Nuevo Nombre', 987654321;
END;
$$;
 5   DROP FUNCTION public.insertar_y_actualizar_alumno();
       public       
   pedrosaura    false            �            1255    17435 0   obtener_estadisticas(character varying, integer)    FUNCTION     >  CREATE FUNCTION public.obtener_estadisticas(equipo_nombre character varying, anio integer DEFAULT NULL::integer) RETURNS TABLE(partidos_jugados integer, partidos_ganados integer, partidos_perdidos integer, partidos_empatados integer, goles_a_favor integer, goles_en_contra integer, goles_totales integer, maximo_goleador character varying, goles_maximo_goleador integer, puntos integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST(COUNT(*) AS INTEGER) AS partidos_jugados,
        CAST(COUNT(*) FILTER (WHERE resultado_l > resultado_v AND equipo_l = equipo_nombre OR resultado_v < resultado_l AND equipo_v = equipo_nombre) AS INTEGER) AS partidos_ganados,
        CAST(COUNT(*) FILTER (WHERE resultado_l < resultado_v AND equipo_l = equipo_nombre OR resultado_v > resultado_l AND equipo_v = equipo_nombre) AS INTEGER) AS partidos_perdidos,
        CAST(COUNT(*) FILTER (WHERE resultado_l = resultado_v) AS INTEGER) AS partidos_empatados,
        CAST(SUM(CASE WHEN equipo_l = equipo_nombre THEN resultado_l ELSE resultado_v END) AS INTEGER) AS goles_a_favor,
        CAST(SUM(CASE WHEN equipo_l = equipo_nombre THEN resultado_v ELSE resultado_l END) AS INTEGER) AS goles_en_contra,
        CAST(SUM(resultado_l + resultado_v) AS INTEGER) AS goles_totales,
        (SELECT jugador_gol FROM gol WHERE equipo_l_gol = equipo_nombre OR equipo_v_gol = equipo_nombre GROUP BY jugador_gol ORDER BY COUNT(*) DESC LIMIT 1) AS maximo_goleador,
        CAST((SELECT COUNT(*) FROM gol WHERE jugador_gol = maximo_goleador) AS INTEGER) AS goles_maximo_goleador,
        3 * partidos_ganados + partidos_empatados AS puntos
    FROM partido
    WHERE (equipo_l = equipo_nombre OR equipo_v = equipo_nombre) AND (fecha BETWEEN TO_DATE('01-01-' || anio, 'DD-MM-YYYY') AND TO_DATE('31-12-' || anio, 'DD-MM-YYYY') OR anio IS NULL);
END; $$;
 Z   DROP FUNCTION public.obtener_estadisticas(equipo_nombre character varying, anio integer);
       public       
   pedrosaura    false            �            1255    17429 7   obtener_informacion_jugador(character varying, integer)    FUNCTION       CREATE FUNCTION public.obtener_informacion_jugador(nombre_jugador character varying, anio_mundial integer) RETURNS public.mundial_record
    LANGUAGE plpgsql
    AS $$
DECLARE
    jugador_info mundial_record;
BEGIN
    SELECT jugador.nombre, jugador.puesto_hab, jugador.equipo_jugador,
           COALESCE(SUM(jugar.min_jugar), 0), COUNT(jugar.nombre_jug), COUNT(gol.jugador_gol)
    INTO jugador_info
    FROM jugador
    LEFT JOIN jugar ON jugador.nombre = jugar.nombre_jug
    LEFT JOIN gol ON jugador.nombre = gol.jugador_gol
    WHERE jugador.nombre = nombre_jugador
    AND EXTRACT(YEAR FROM jugar.fecha_part) = anio_mundial
    GROUP BY jugador.nombre, jugador.puesto_hab, jugador.equipo_jugador;

    RAISE NOTICE 'Información del jugador: %, %, %, %, %, %',
                 jugador_info.nombre_jugador, jugador_info.puesto_habitual,
                 jugador_info.equipo, jugador_info.minutos_jugados,
                 jugador_info.cantidad_partidos, jugador_info.goles_marcados;

    RETURN jugador_info;
END;
$$;
 j   DROP FUNCTION public.obtener_informacion_jugador(nombre_jugador character varying, anio_mundial integer);
       public       
   pedrosaura    false    878            �            1259    17410    alumnos    TABLE        CREATE TABLE public.alumnos (
    dni character varying(9) NOT NULL,
    nombre character varying(60),
    telefono numeric
);
    DROP TABLE public.alumnos;
       public         heap 
   pedrosaura    false            b           0    0    TABLE alumnos    ACL     3   GRANT SELECT ON TABLE public.alumnos TO read_user;
          public       
   pedrosaura    false    220            �            1259    17219    equipos    TABLE     �   CREATE TABLE public.equipos (
    equipo character varying(255) NOT NULL,
    pais character varying(255),
    seleccionador character varying(255)
);
    DROP TABLE public.equipos;
       public         heap 
   pedrosaura    false            c           0    0    TABLE equipos    ACL     3   GRANT SELECT ON TABLE public.equipos TO read_user;
          public       
   pedrosaura    false    215            �            1259    17239    gol    TABLE     �   CREATE TABLE public.gol (
    minuto integer NOT NULL,
    jugador_gol character varying(50) NOT NULL,
    equipo_l_gol character varying(50) NOT NULL,
    equipo_v_gol character varying(50) NOT NULL,
    fecha_gol date NOT NULL
);
    DROP TABLE public.gol;
       public         heap 
   pedrosaura    false            d           0    0 	   TABLE gol    ACL     /   GRANT SELECT ON TABLE public.gol TO read_user;
          public       
   pedrosaura    false    219            �            1259    17224    jugador    TABLE     �   CREATE TABLE public.jugador (
    nombre character varying(255) NOT NULL,
    direccion character varying(255),
    puesto_hab character varying(255),
    fecha_nac date,
    equipo_jugador character varying(255)
);
    DROP TABLE public.jugador;
       public         heap 
   pedrosaura    false            e           0    0    TABLE jugador    ACL     3   GRANT SELECT ON TABLE public.jugador TO read_user;
          public       
   pedrosaura    false    216            �            1259    17234    jugar    TABLE     %  CREATE TABLE public.jugar (
    nombre_jug character varying(255) NOT NULL,
    equipo_l_part character varying(255) NOT NULL,
    equipo_v_part character varying(255) NOT NULL,
    fecha_part date NOT NULL,
    min_jugar integer,
    puesto_jugar character varying(50),
    dorsal integer
);
    DROP TABLE public.jugar;
       public         heap 
   pedrosaura    false            f           0    0    TABLE jugar    ACL     1   GRANT SELECT ON TABLE public.jugar TO read_user;
          public       
   pedrosaura    false    218            �            1259    17229    partido    TABLE     R  CREATE TABLE public.partido (
    equipo_l character varying(255) NOT NULL,
    equipo_v character varying(255) NOT NULL,
    fecha date NOT NULL,
    hora time without time zone,
    sede character varying(255),
    resultado_l integer,
    resultado_v integer,
    asistencia integer,
    fecha_ejercicio timestamp without time zone
);
    DROP TABLE public.partido;
       public         heap 
   pedrosaura    false            g           0    0    TABLE partido    ACL     3   GRANT SELECT ON TABLE public.partido TO read_user;
          public       
   pedrosaura    false    217            �            1259    17417    secuencia_alumnos    SEQUENCE     {   CREATE SEQUENCE public.secuencia_alumnos
    START WITH 10
    INCREMENT BY 5
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.secuencia_alumnos;
       public       
   pedrosaura    false            �            1259    17418    v_secuencia    TABLE     8   CREATE TABLE public.v_secuencia (
    currval bigint
);
    DROP TABLE public.v_secuencia;
       public         heap 
   pedrosaura    false            h           0    0    TABLE v_secuencia    ACL     7   GRANT SELECT ON TABLE public.v_secuencia TO read_user;
          public       
   pedrosaura    false    222            X          0    17410    alumnos 
   TABLE DATA           8   COPY public.alumnos (dni, nombre, telefono) FROM stdin;
    public       
   pedrosaura    false    220   Jb       S          0    17219    equipos 
   TABLE DATA           >   COPY public.equipos (equipo, pais, seleccionador) FROM stdin;
    public       
   pedrosaura    false    215   c       W          0    17239    gol 
   TABLE DATA           Y   COPY public.gol (minuto, jugador_gol, equipo_l_gol, equipo_v_gol, fecha_gol) FROM stdin;
    public       
   pedrosaura    false    219   Uc       T          0    17224    jugador 
   TABLE DATA           [   COPY public.jugador (nombre, direccion, puesto_hab, fecha_nac, equipo_jugador) FROM stdin;
    public       
   pedrosaura    false    216   �c       V          0    17234    jugar 
   TABLE DATA           v   COPY public.jugar (nombre_jug, equipo_l_part, equipo_v_part, fecha_part, min_jugar, puesto_jugar, dorsal) FROM stdin;
    public       
   pedrosaura    false    218   d       U          0    17229    partido 
   TABLE DATA              COPY public.partido (equipo_l, equipo_v, fecha, hora, sede, resultado_l, resultado_v, asistencia, fecha_ejercicio) FROM stdin;
    public       
   pedrosaura    false    217   zd       Z          0    17418    v_secuencia 
   TABLE DATA           .   COPY public.v_secuencia (currval) FROM stdin;
    public       
   pedrosaura    false    222   Ce       i           0    0    secuencia_alumnos    SEQUENCE SET     A   SELECT pg_catalog.setval('public.secuencia_alumnos', 155, true);
          public       
   pedrosaura    false    221            �           2606    17416    alumnos pk_alumnos 
   CONSTRAINT     Q   ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT pk_alumnos PRIMARY KEY (dni);
 <   ALTER TABLE ONLY public.alumnos DROP CONSTRAINT pk_alumnos;
       public         
   pedrosaura    false    220            �           2606    17243    equipos pk_equipos 
   CONSTRAINT     T   ALTER TABLE ONLY public.equipos
    ADD CONSTRAINT pk_equipos PRIMARY KEY (equipo);
 <   ALTER TABLE ONLY public.equipos DROP CONSTRAINT pk_equipos;
       public         
   pedrosaura    false    215            �           2606    17251 
   gol pk_gol 
   CONSTRAINT     �   ALTER TABLE ONLY public.gol
    ADD CONSTRAINT pk_gol PRIMARY KEY (minuto, jugador_gol, equipo_l_gol, equipo_v_gol, fecha_gol);
 4   ALTER TABLE ONLY public.gol DROP CONSTRAINT pk_gol;
       public         
   pedrosaura    false    219    219    219    219    219            �           2606    17245    jugador pk_jugador 
   CONSTRAINT     T   ALTER TABLE ONLY public.jugador
    ADD CONSTRAINT pk_jugador PRIMARY KEY (nombre);
 <   ALTER TABLE ONLY public.jugador DROP CONSTRAINT pk_jugador;
       public         
   pedrosaura    false    216            �           2606    17249    jugar pk_jugar 
   CONSTRAINT     ~   ALTER TABLE ONLY public.jugar
    ADD CONSTRAINT pk_jugar PRIMARY KEY (nombre_jug, equipo_l_part, equipo_v_part, fecha_part);
 8   ALTER TABLE ONLY public.jugar DROP CONSTRAINT pk_jugar;
       public         
   pedrosaura    false    218    218    218    218            �           2606    17247    partido pk_partido 
   CONSTRAINT     g   ALTER TABLE ONLY public.partido
    ADD CONSTRAINT pk_partido PRIMARY KEY (equipo_l, equipo_v, fecha);
 <   ALTER TABLE ONLY public.partido DROP CONSTRAINT pk_partido;
       public         
   pedrosaura    false    217    217    217            �           1259    17874    idx_fecha_gol    INDEX     B   CREATE INDEX idx_fecha_gol ON public.gol USING btree (fecha_gol);
 !   DROP INDEX public.idx_fecha_gol;
       public         
   pedrosaura    false    219            �           1259    17875    idx_jugar_equipo_fecha    INDEX     l   CREATE INDEX idx_jugar_equipo_fecha ON public.jugar USING btree (equipo_l_part, equipo_v_part, fecha_part);
 *   DROP INDEX public.idx_jugar_equipo_fecha;
       public         
   pedrosaura    false    218    218    218            �           1259    17872    idx_nombre_jugador    INDEX     H   CREATE INDEX idx_nombre_jugador ON public.jugador USING btree (nombre);
 &   DROP INDEX public.idx_nombre_jugador;
       public         
   pedrosaura    false    216            �           1259    17873    idx_partido_equipo_fecha    INDEX     a   CREATE INDEX idx_partido_equipo_fecha ON public.partido USING btree (equipo_l, equipo_v, fecha);
 ,   DROP INDEX public.idx_partido_equipo_fecha;
       public         
   pedrosaura    false    217    217    217            �           2606    17282    gol fk_gol_jugar    FK CONSTRAINT     �   ALTER TABLE ONLY public.gol
    ADD CONSTRAINT fk_gol_jugar FOREIGN KEY (jugador_gol, equipo_l_gol, equipo_v_gol, fecha_gol) REFERENCES public.jugar(nombre_jug, equipo_l_part, equipo_v_part, fecha_part);
 :   ALTER TABLE ONLY public.gol DROP CONSTRAINT fk_gol_jugar;
       public       
   pedrosaura    false    218    219    219    218    219    218    218    3512    219            �           2606    17257    jugador fk_jugador_equipo    FK CONSTRAINT     �   ALTER TABLE ONLY public.jugador
    ADD CONSTRAINT fk_jugador_equipo FOREIGN KEY (equipo_jugador) REFERENCES public.equipos(equipo);
 C   ALTER TABLE ONLY public.jugador DROP CONSTRAINT fk_jugador_equipo;
       public       
   pedrosaura    false    215    216    3503            �           2606    17272    jugar fk_jugar_jugador    FK CONSTRAINT     ~   ALTER TABLE ONLY public.jugar
    ADD CONSTRAINT fk_jugar_jugador FOREIGN KEY (nombre_jug) REFERENCES public.jugador(nombre);
 @   ALTER TABLE ONLY public.jugar DROP CONSTRAINT fk_jugar_jugador;
       public       
   pedrosaura    false    218    3506    216            �           2606    17277    jugar fk_jugar_partido    FK CONSTRAINT     �   ALTER TABLE ONLY public.jugar
    ADD CONSTRAINT fk_jugar_partido FOREIGN KEY (equipo_l_part, equipo_v_part, fecha_part) REFERENCES public.partido(equipo_l, equipo_v, fecha);
 @   ALTER TABLE ONLY public.jugar DROP CONSTRAINT fk_jugar_partido;
       public       
   pedrosaura    false    3509    217    217    218    218    218    217            �           2606    17262    partido fk_partido_equipo_l    FK CONSTRAINT     �   ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_equipo_l FOREIGN KEY (equipo_l) REFERENCES public.equipos(equipo);
 E   ALTER TABLE ONLY public.partido DROP CONSTRAINT fk_partido_equipo_l;
       public       
   pedrosaura    false    3503    217    215            �           2606    17267    partido fk_partido_equipo_v    FK CONSTRAINT     �   ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_equipo_v FOREIGN KEY (equipo_v) REFERENCES public.equipos(equipo);
 E   ALTER TABLE ONLY public.partido DROP CONSTRAINT fk_partido_equipo_v;
       public       
   pedrosaura    false    215    3503    217            X   �   x�}���0Dg�+��Kb7޻0�, 2 @�*������v�����v@�6��s'�\X��a��L�ݗi���%'��)zG�̶[����o�DRXEYyU=�M��R�+#&2D:^��$���2�r��WC�jfB4?#z�������l(����aOw{�����}����#      S   C   x�
uu���"��Р�POG(��������q�s=�]������B��~0�=... B;I      W   =   x�342�t�qv�s	�Wpq�Q�t�	�:�y:rz�8� )#3]s]�=... �)�      T   Q   x�s���t�S�utw����"�GOG.G��`G?� W� O� LE�
��~~�IgO?G�=... ]�Y      V   g   x��A
�0���S�)���L�ql����9�}�>�-[��V[q��n*X65��<z�~�"�����K�p)��\t��z�K��_�<{�+��� �Y��      U   �   x�e���0F������1rW��`����9�?$$^�I���J���&v�O��5$�TRA���6�"�X�h{��4�uu8�h\h5K��c�.n�L���4@�ח� w�����N&L3['Cn'�LM�U��b�<f��ٻ����P�.3�6��AF�%'w��$�4<�U.5�UJ� /.?�      Z      x�34������ �     
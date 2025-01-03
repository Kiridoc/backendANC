toc.dat                                                                                             0000600 0004000 0002000 00000070440 14735553414 0014457 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP                        }            bd_acuarioNC    16.3    16.3 F    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         �           1262    65548    bd_acuarioNC    DATABASE     �   CREATE DATABASE "bd_acuarioNC" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Cuba.1252';
    DROP DATABASE "bd_acuarioNC";
                postgres    false         �            1255    65637 G   agregar_evento(character varying, character varying, text, date, bytea)    FUNCTION     n  CREATE FUNCTION public.agregar_evento(p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.evento (nombre_evento, titulo, descripcion, fecha, imagen)
    VALUES (p_nombre_evento, p_titulo, p_descripcion, p_fecha, p_imagen);
END;
$$;
 �   DROP FUNCTION public.agregar_evento(p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea);
       public          postgres    false         �            1255    65633 "   agregar_pregunta_buzon(text, text)    FUNCTION     �   CREATE FUNCTION public.agregar_pregunta_buzon(p_pregunta text, p_correo text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.buzon (pregunta, correo)
    VALUES (p_pregunta, p_correo);
END;
$$;
 M   DROP FUNCTION public.agregar_pregunta_buzon(p_pregunta text, p_correo text);
       public          postgres    false         �            1255    65641 &   agregar_pregunta_frecuente(text, text)    FUNCTION       CREATE FUNCTION public.agregar_pregunta_frecuente(nueva_pregunta text, nueva_respuesta text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.pregunta_frecuente (pregunta, respuesta)
    VALUES (nueva_pregunta, nueva_respuesta);
END;
$$;
 \   DROP FUNCTION public.agregar_pregunta_frecuente(nueva_pregunta text, nueva_respuesta text);
       public          postgres    false                     1255    65652 M   agregar_usuario(character varying, text, character varying, boolean, integer)    FUNCTION     �  CREATE FUNCTION public.agregar_usuario(p_nombre character varying, "p_contraseña" text, p_telefono character varying, p_is_asignado boolean, p_id_rol_usuario integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar que siempre quede al menos un administrador
    IF p_id_rol_usuario = 1 AND p_is_asignado THEN
        -- Si es administrador con is_asignado true, asegurarse de que no haya otro
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = 1;
    END IF;

    INSERT INTO public.usuario (nombre, contraseña, telefono, is_asignado, id_rol_usuario)
    VALUES (p_nombre, p_contraseña, p_telefono, p_is_asignado, p_id_rol_usuario);
END;
$$;
 �   DROP FUNCTION public.agregar_usuario(p_nombre character varying, "p_contraseña" text, p_telefono character varying, p_is_asignado boolean, p_id_rol_usuario integer);
       public          postgres    false         �            1255    65638    eliminar_evento(integer)    FUNCTION     �   CREATE FUNCTION public.eliminar_evento(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.evento
    WHERE id = p_id;
END;
$$;
 4   DROP FUNCTION public.eliminar_evento(p_id integer);
       public          postgres    false         �            1255    65634     eliminar_pregunta_buzon(integer)    FUNCTION     �   CREATE FUNCTION public.eliminar_pregunta_buzon(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.buzon
    WHERE id = p_id;
END;
$$;
 <   DROP FUNCTION public.eliminar_pregunta_buzon(p_id integer);
       public          postgres    false         �            1255    65642 $   eliminar_pregunta_frecuente(integer)    FUNCTION     i  CREATE FUNCTION public.eliminar_pregunta_frecuente(id_pregunta integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.pregunta_frecuente
    WHERE id = id_pregunta;

    -- Verificar si se eliminó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró una pregunta frecuente con el ID %', id_pregunta;
    END IF;
END;
$$;
 G   DROP FUNCTION public.eliminar_pregunta_frecuente(id_pregunta integer);
       public          postgres    false                    1255    65664    eliminar_todos_los_eventos()    FUNCTION     �   CREATE FUNCTION public.eliminar_todos_los_eventos() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.evento;

    RAISE NOTICE 'Todos los eventos han sido eliminados.';
END;
$$;
 3   DROP FUNCTION public.eliminar_todos_los_eventos();
       public          postgres    false                    1255    65663    eliminar_usuario(integer)    FUNCTION     /  CREATE FUNCTION public.eliminar_usuario(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_rol_usuario INT;
    v_is_asignado BOOLEAN;
BEGIN
    -- Obtener el rol y estado de asignación del usuario a eliminar
    SELECT id_rol_usuario, is_asignado INTO v_id_rol_usuario, v_is_asignado
    FROM public.usuario
    WHERE id = p_id;

    -- Validar que siempre quede al menos un administrador
    IF v_id_rol_usuario = 1 THEN
        IF (SELECT COUNT(*) FROM public.usuario WHERE id_rol_usuario = 1) = 1 THEN
            RAISE EXCEPTION 'No se puede eliminar el único administrador.';
        END IF;
    END IF;

    -- Eliminar el usuario
    DELETE FROM public.usuario WHERE id = p_id;

    -- Si se elimina un técnico con is_asignado = true, asignar un administrador
    IF v_id_rol_usuario = 2 AND v_is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = true
        WHERE id = (
            SELECT id
            FROM public.usuario
            WHERE id_rol_usuario = 1
            LIMIT 1
        );
    END IF;
END;
$$;
 5   DROP FUNCTION public.eliminar_usuario(p_id integer);
       public          postgres    false         �            1255    65639 R   modificar_evento(integer, character varying, character varying, text, date, bytea)    FUNCTION     �  CREATE FUNCTION public.modificar_evento(p_id integer, p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.evento
    SET nombre_evento = p_nombre_evento,
        titulo = p_titulo,
        descripcion = p_descripcion,
        fecha = p_fecha,
        imagen = p_imagen
    WHERE id = p_id;
END;
$$;
 �   DROP FUNCTION public.modificar_evento(p_id integer, p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea);
       public          postgres    false         �            1255    65657 '   modificar_is_asignado(integer, boolean)    FUNCTION       CREATE FUNCTION public.modificar_is_asignado(p_id integer, p_is_asignado boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_rol_usuario INT;
BEGIN
    SELECT id_rol_usuario INTO v_id_rol_usuario
    FROM public.usuario
    WHERE id = p_id;

    -- Solo permitir un usuario asignado
    IF p_is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = v_id_rol_usuario;
    END IF;

    UPDATE public.usuario
    SET is_asignado = p_is_asignado
    WHERE id = p_id;
END;
$$;
 Q   DROP FUNCTION public.modificar_is_asignado(p_id integer, p_is_asignado boolean);
       public          postgres    false         �            1255    65643 1   modificar_pregunta_frecuente(integer, text, text)    FUNCTION     �  CREATE FUNCTION public.modificar_pregunta_frecuente(id_pregunta integer, nueva_pregunta text, nueva_respuesta text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.pregunta_frecuente
    SET pregunta = nueva_pregunta,
        respuesta = nueva_respuesta
    WHERE id = id_pregunta;

    -- Verificar si se actualizó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró una pregunta frecuente con el ID %', id_pregunta;
    END IF;
END;
$$;
 s   DROP FUNCTION public.modificar_pregunta_frecuente(id_pregunta integer, nueva_pregunta text, nueva_respuesta text);
       public          postgres    false         �            1255    65649 >   modificar_show(integer, boolean, text, text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.modificar_show(id_show integer, nuevo_is_disponible boolean, nuevo_horario text, nuevo_costo text, "nueva_interaccion_niños" text, nueva_interaccion_adultos text, nueva_ubicacion text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    nombre_show TEXT;
BEGIN
    -- Obtener el nombre del show
    SELECT nombre INTO nombre_show
    FROM public.show
    WHERE id = id_show;

    -- Validar el tipo de show y aplicar reglas
    IF nombre_show = 'Show de Payasos y Magos' THEN
        -- Modificar para Payasos y Magos
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo),
            ubicacion = COALESCE(nueva_ubicacion, ubicacion),
            "interaccion_niños" = NULL,
            interaccion_adultos = NULL
        WHERE id = id_show;

    ELSIF nombre_show = 'Show de Delfines' OR nombre_show = 'Show de Lobos Marinos' THEN
        -- Modificar para Delfines y Lobos Marinos
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo),
            "interaccion_niños" = COALESCE(nueva_interaccion_niños, "interaccion_niños"),
            interaccion_adultos = COALESCE(nueva_interaccion_adultos, interaccion_adultos)
        WHERE id = id_show;
    ELSE
        -- Modificar para otros shows
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo)
        WHERE id = id_show;
    END IF;

    -- Verificar si se actualizó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró un show con el ID %', id_show;
    END IF;
END;
$$;
 �   DROP FUNCTION public.modificar_show(id_show integer, nuevo_is_disponible boolean, nuevo_horario text, nuevo_costo text, "nueva_interaccion_niños" text, nueva_interaccion_adultos text, nueva_ubicacion text);
       public          postgres    false         �            1255    65640    mostrar_eventos()    FUNCTION     W  CREATE FUNCTION public.mostrar_eventos() RETURNS TABLE(id_evento integer, nombre_evento character varying, titulo character varying, descripcion text, fecha date, imagen bytea)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.nombre_evento, e.titulo, e.descripcion, e.fecha, e.imagen
    FROM public.evento e;
END;
$$;
 (   DROP FUNCTION public.mostrar_eventos();
       public          postgres    false         �            1255    65632    mostrar_preguntas_buzon()    FUNCTION     �   CREATE FUNCTION public.mostrar_preguntas_buzon() RETURNS TABLE(id_buzon integer, pregunta text, correo text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT b.id, b.pregunta, b.correo
    FROM public.buzon b;
END;
$$;
 0   DROP FUNCTION public.mostrar_preguntas_buzon();
       public          postgres    false         �            1255    65644    mostrar_preguntas_frecuentes()    FUNCTION     
  CREATE FUNCTION public.mostrar_preguntas_frecuentes() RETURNS TABLE(id_pregunta integer, pregunta text, respuesta text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT pf.id, pf.pregunta, pf.respuesta
    FROM public.pregunta_frecuente pf;
END;
$$;
 5   DROP FUNCTION public.mostrar_preguntas_frecuentes();
       public          postgres    false         �            1255    65648    mostrar_shows()    FUNCTION     �  CREATE FUNCTION public.mostrar_shows() RETURNS TABLE(id_show integer, nombre character varying, is_disponible boolean, horario_tipo text, horario text, ubicacion text, costo text, "interaccion_niños" text, interaccion_adultos text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.nombre, s.is_disponible, s.horario_tipo, s.horario,
           s.ubicacion, s.costo, s."interaccion_niños", s.interaccion_adultos
    FROM public.show s;
END;
$$;
 &   DROP FUNCTION public.mostrar_shows();
       public          postgres    false         �            1255    65656    mostrar_usuarios()    FUNCTION     p  CREATE FUNCTION public.mostrar_usuarios() RETURNS TABLE(id_usuario integer, nombre character varying, telefono character varying, is_asignado boolean, rol_usuario text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.nombre, u.telefono, u.is_asignado, r.rol
    FROM public.usuario u
    JOIN public.rol r ON u.id_rol_usuario = r.id;
END;
$$;
 )   DROP FUNCTION public.mostrar_usuarios();
       public          postgres    false         �            1255    65650    validar_modificaciones_show()    FUNCTION     2  CREATE FUNCTION public.validar_modificaciones_show() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Restricción para Show de Delfines y Lobos Marinos
    IF (NEW.nombre = 'Show de Delfines' OR NEW.nombre = 'Show de Lobos Marinos') AND
       (NEW.ubicacion IS DISTINCT FROM OLD.ubicacion OR NEW.horario_tipo IS DISTINCT FROM OLD.horario_tipo) THEN
        RAISE EXCEPTION 'No se permite modificar la ubicación ni el tipo de horario para el show de %', NEW.nombre;
    END IF;

    -- Restricción para Show de Payasos y Magos
    IF NEW.nombre = 'Show de Payasos y Magos' AND
       (NEW."interaccion_niños" IS NOT NULL OR NEW.interaccion_adultos IS NOT NULL) THEN
        RAISE EXCEPTION 'El show de Payasos y Magos no tiene interacciones con niños ni adultos';
    END IF;

    RETURN NEW;
END;
$$;
 4   DROP FUNCTION public.validar_modificaciones_show();
       public          postgres    false         �            1255    65635    validar_unica_pregunta()    FUNCTION     c  CREATE FUNCTION public.validar_unica_pregunta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si el correo ya existe en la tabla buzon
    IF EXISTS (SELECT 1 FROM public.buzon WHERE correo = NEW.correo) THEN
        RAISE EXCEPTION 'El correo % ya tiene una pregunta registrada.', NEW.correo;
    END IF;
    RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.validar_unica_pregunta();
       public          postgres    false         �            1255    65658    validar_unico_administrador()    FUNCTION     �  CREATE FUNCTION public.validar_unico_administrador() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar que siempre quede al menos un administrador
    IF OLD.id_rol_usuario = 1 AND
       (SELECT COUNT(*) FROM public.usuario WHERE id_rol_usuario = 1) = 1 THEN
        RAISE EXCEPTION 'No se puede eliminar el único administrador.';
    END IF;

    RETURN OLD;
END;
$$;
 4   DROP FUNCTION public.validar_unico_administrador();
       public          postgres    false         �            1255    65660    validar_unico_asignado()    FUNCTION     i  CREATE FUNCTION public.validar_unico_asignado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Asegurar que no haya más de un usuario asignado por rol
    IF NEW.is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = NEW.id_rol_usuario AND id <> NEW.id;
    END IF;

    RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.validar_unico_asignado();
       public          postgres    false         �            1259    65550    buzon    TABLE     [   CREATE TABLE public.buzon (
    id integer NOT NULL,
    pregunta text,
    correo text
);
    DROP TABLE public.buzon;
       public         heap    postgres    false         �            1259    65549    buzon_id_seq    SEQUENCE     �   CREATE SEQUENCE public.buzon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.buzon_id_seq;
       public          postgres    false    216         �           0    0    buzon_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.buzon_id_seq OWNED BY public.buzon.id;
          public          postgres    false    215         �            1259    65559    evento    TABLE     �   CREATE TABLE public.evento (
    id integer NOT NULL,
    nombre_evento character varying(50),
    titulo character varying(50),
    descripcion text,
    fecha date,
    imagen bytea
);
    DROP TABLE public.evento;
       public         heap    postgres    false         �            1259    65558    evento_id_seq    SEQUENCE     �   CREATE SEQUENCE public.evento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.evento_id_seq;
       public          postgres    false    218                     0    0    evento_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.evento_id_seq OWNED BY public.evento.id;
          public          postgres    false    217         �            1259    65568    pregunta_frecuente    TABLE     k   CREATE TABLE public.pregunta_frecuente (
    id integer NOT NULL,
    pregunta text,
    respuesta text
);
 &   DROP TABLE public.pregunta_frecuente;
       public         heap    postgres    false         �            1259    65567    pregunta_frecuente_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pregunta_frecuente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.pregunta_frecuente_id_seq;
       public          postgres    false    220                    0    0    pregunta_frecuente_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.pregunta_frecuente_id_seq OWNED BY public.pregunta_frecuente.id;
          public          postgres    false    219         �            1259    65576    rol    TABLE     C   CREATE TABLE public.rol (
    id integer NOT NULL,
    rol text
);
    DROP TABLE public.rol;
       public         heap    postgres    false         �            1259    65584    show    TABLE     �   CREATE TABLE public.show (
    id integer NOT NULL,
    nombre character varying(50),
    is_disponible boolean,
    horario_tipo text,
    horario text,
    ubicacion text,
    costo text,
    "interaccion_niños" text,
    interaccion_adultos text
);
    DROP TABLE public.show;
       public         heap    postgres    false         �            1259    65583    show_id_seq    SEQUENCE     �   CREATE SEQUENCE public.show_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.show_id_seq;
       public          postgres    false    223                    0    0    show_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.show_id_seq OWNED BY public.show.id;
          public          postgres    false    222         �            1259    65593    usuario    TABLE     �   CREATE TABLE public.usuario (
    id integer NOT NULL,
    nombre character varying(50),
    "contraseña" text,
    telefono character varying(8),
    is_asignado boolean,
    id_rol_usuario integer
);
    DROP TABLE public.usuario;
       public         heap    postgres    false         �            1259    65592    usuario_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.usuario_id_seq;
       public          postgres    false    225                    0    0    usuario_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;
          public          postgres    false    224         H           2604    65553    buzon id    DEFAULT     d   ALTER TABLE ONLY public.buzon ALTER COLUMN id SET DEFAULT nextval('public.buzon_id_seq'::regclass);
 7   ALTER TABLE public.buzon ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215    216         I           2604    65562 	   evento id    DEFAULT     f   ALTER TABLE ONLY public.evento ALTER COLUMN id SET DEFAULT nextval('public.evento_id_seq'::regclass);
 8   ALTER TABLE public.evento ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    217    218    218         J           2604    65571    pregunta_frecuente id    DEFAULT     ~   ALTER TABLE ONLY public.pregunta_frecuente ALTER COLUMN id SET DEFAULT nextval('public.pregunta_frecuente_id_seq'::regclass);
 D   ALTER TABLE public.pregunta_frecuente ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219    220         K           2604    65587    show id    DEFAULT     b   ALTER TABLE ONLY public.show ALTER COLUMN id SET DEFAULT nextval('public.show_id_seq'::regclass);
 6   ALTER TABLE public.show ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223         L           2604    65596 
   usuario id    DEFAULT     h   ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);
 9   ALTER TABLE public.usuario ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    225    225         �          0    65550    buzon 
   TABLE DATA           5   COPY public.buzon (id, pregunta, correo) FROM stdin;
    public          postgres    false    216       4847.dat �          0    65559    evento 
   TABLE DATA           W   COPY public.evento (id, nombre_evento, titulo, descripcion, fecha, imagen) FROM stdin;
    public          postgres    false    218       4849.dat �          0    65568    pregunta_frecuente 
   TABLE DATA           E   COPY public.pregunta_frecuente (id, pregunta, respuesta) FROM stdin;
    public          postgres    false    220       4851.dat �          0    65576    rol 
   TABLE DATA           &   COPY public.rol (id, rol) FROM stdin;
    public          postgres    false    221       4852.dat �          0    65584    show 
   TABLE DATA           �   COPY public.show (id, nombre, is_disponible, horario_tipo, horario, ubicacion, costo, "interaccion_niños", interaccion_adultos) FROM stdin;
    public          postgres    false    223       4854.dat �          0    65593    usuario 
   TABLE DATA           c   COPY public.usuario (id, nombre, "contraseña", telefono, is_asignado, id_rol_usuario) FROM stdin;
    public          postgres    false    225       4856.dat            0    0    buzon_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.buzon_id_seq', 2, true);
          public          postgres    false    215                    0    0    evento_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.evento_id_seq', 3, true);
          public          postgres    false    217                    0    0    pregunta_frecuente_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.pregunta_frecuente_id_seq', 1, true);
          public          postgres    false    219                    0    0    show_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.show_id_seq', 1, false);
          public          postgres    false    222                    0    0    usuario_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.usuario_id_seq', 6, true);
          public          postgres    false    224         P           2606    65566    evento evento_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.evento DROP CONSTRAINT evento_pkey;
       public            postgres    false    218         N           2606    65557    buzon id_buzon_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.buzon
    ADD CONSTRAINT id_buzon_pkey PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.buzon DROP CONSTRAINT id_buzon_pkey;
       public            postgres    false    216         R           2606    65575 *   pregunta_frecuente pregunta_frecuente_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.pregunta_frecuente
    ADD CONSTRAINT pregunta_frecuente_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.pregunta_frecuente DROP CONSTRAINT pregunta_frecuente_pkey;
       public            postgres    false    220         T           2606    65582    rol rol_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.rol DROP CONSTRAINT rol_pkey;
       public            postgres    false    221         V           2606    65591    show show_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.show
    ADD CONSTRAINT show_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.show DROP CONSTRAINT show_pkey;
       public            postgres    false    223         Y           2606    65600    usuario usuario_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    225         W           1259    65606    fki_id_rol_usuario_fkey    INDEX     U   CREATE INDEX fki_id_rol_usuario_fkey ON public.usuario USING btree (id_rol_usuario);
 +   DROP INDEX public.fki_id_rol_usuario_fkey;
       public            postgres    false    225         ]           2620    65659 '   usuario trg_validar_unico_administrador    TRIGGER     �   CREATE TRIGGER trg_validar_unico_administrador BEFORE DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.validar_unico_administrador();
 @   DROP TRIGGER trg_validar_unico_administrador ON public.usuario;
       public          postgres    false    228    225         ^           2620    65661 "   usuario trg_validar_unico_asignado    TRIGGER     �   CREATE TRIGGER trg_validar_unico_asignado BEFORE INSERT OR UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.validar_unico_asignado();
 ;   DROP TRIGGER trg_validar_unico_asignado ON public.usuario;
       public          postgres    false    225    238         \           2620    65651 (   show trigger_validar_modificaciones_show    TRIGGER     �   CREATE TRIGGER trigger_validar_modificaciones_show BEFORE UPDATE ON public.show FOR EACH ROW EXECUTE FUNCTION public.validar_modificaciones_show();
 A   DROP TRIGGER trigger_validar_modificaciones_show ON public.show;
       public          postgres    false    255    223         [           2620    65636    buzon validar_pregunta_unica    TRIGGER     �   CREATE TRIGGER validar_pregunta_unica BEFORE INSERT ON public.buzon FOR EACH ROW EXECUTE FUNCTION public.validar_unica_pregunta();
 5   DROP TRIGGER validar_pregunta_unica ON public.buzon;
       public          postgres    false    216    231         Z           2606    65601    usuario id_rol_usuario_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT id_rol_usuario_fkey FOREIGN KEY (id_rol_usuario) REFERENCES public.rol(id);
 E   ALTER TABLE ONLY public.usuario DROP CONSTRAINT id_rol_usuario_fkey;
       public          postgres    false    221    225    4692                                                                                                                                                                                                                                        4847.dat                                                                                            0000600 0004000 0002000 00000000364 14735553414 0014276 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	usuario1@example.com	¿Cuáles son los horarios del acuario?
2	usuario2@example.com	¿Hay espectáculos con delfines?
3	usuario3@example.com	¿El acuario está abierto los domingos?
4	usuario4@example.com	¿Tienen descuento para grupos?
\.


                                                                                                                                                                                                                                                                            4849.dat                                                                                            0000600 0004000 0002000 00000000733 14735553414 0014300 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Siembra de Corales	Restauración de Arrecifes	Participa en la siembra de corales para restaurar los arrecifes dañados.	2024-12-11	\N
2	Introducción Buceo	Curso de Buceo	Aprende los conceptos básicos del buceo en un ambiente seguro.	2025-05-20	\N
3	Origami y Naturaleza	Taller de Origami	Explora el arte del origami inspirado en la naturaleza.	2025-01-20	\N
4	Biodiversidad Marina	Seminario	Un seminario sobre la biodiversidad marina y su importancia.	2024-02-12	\N
\.


                                     4851.dat                                                                                            0000600 0004000 0002000 00000003166 14735553414 0014274 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	¿Dónde está ubicado el Acuario Nacional de Cuba?	El Acuario Nacional de Cuba se encuentra en la provincia de La Habana, municipio Playa, calle 3ra entre 60 y 62.
2	¿Cuánto cuesta la entrada al centro?	El precio del boleto de entrada al centro es de $50 para los adultos y $25 para los niños. Los menores de 5 años no pagan entrada.
3	¿Qué es la interacción con mamíferos marinos?	La interacción con mamíferos marinos es un servicio adicional que es posible adquirir en el buró de información junto a la entrada. Dicho servicio se realiza justo después del show y permite pasar a la plataforma del delfinario o lobario junto al entrenador para poder tocar, acariciar y sacarse fotos con los animales (con sus propios teléfonos o cámaras).
4	¿A partir de qué edad se puede hacer la interacción?	La interacción puede realizarla cualquier visitante mayor a 5 años. Los menores de 5 años no pagan interacción, no pueden tocar a los animales ya que podrían hacerles daño tocándoles los ojos y vías respiratorias. Si algún adulto realiza la interacción y toma fotos, puede llevar al menor de 5 años para que salga en la foto.
5	¿Hasta qué edad se considera niño a un visitante?	Se considera niño a cualquier visitante cuya edad esté comprendida entre 5 y 12 años. Los mayores de 12 y menores de 18 años, a pesar de ser menores de edad, pagan precios como adultos.
6	¿Si necesito ayuda o indicaciones en la instalación, a quién debo dirigirme?	Nuestro centro cuenta con técnicos capacitados para atender sus necesidades e inquietudes. Puede encontrarlos en el buró de información junto a la entrada principal.
\.


                                                                                                                                                                                                                                                                                                                                                                                                          4852.dat                                                                                            0000600 0004000 0002000 00000000040 14735553414 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Administrador
2	Técnico
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                4854.dat                                                                                            0000600 0004000 0002000 00000000750 14735553414 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2	Show de Delfines	t	Show de la tarde	3:00 - 3:45	Delfinario	$120	$1200	$1500
3	Show de Lobos Marinos	t	Show de la mañana	11:30 - 12:15	Lobario	$100	$1000	$1300
4	Show de Lobos Marinos	t	Show de la tarde	3:50 - 4:35	Lobario	$100	$1000	$1300
6	Show de Payasos y Magos	t	Show de la tarde	4:00 - 4:45	Lobario	$120	\N	\N
1	Show de Delfines	t	Show de la mañana	10:00 - 10:45	Delfinario	$120	$1200	$1200
5	Show de Payasos y Magos	t	Show de la mañana	10:00 - 10:45	Delfinario	$120	\N	\N
\.


                        4856.dat                                                                                            0000600 0004000 0002000 00000000135 14735553414 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        4	Tech2	pass4	87654321	f	2
5	Admin	admin123	12345678	t	1
6	Tecnico	tech123	87654321	f	2
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                   restore.sql                                                                                         0000600 0004000 0002000 00000062402 14735553414 0015403 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "bd_acuarioNC";
--
-- Name: bd_acuarioNC; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "bd_acuarioNC" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Cuba.1252';


ALTER DATABASE "bd_acuarioNC" OWNER TO postgres;

\connect "bd_acuarioNC"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: agregar_evento(character varying, character varying, text, date, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.agregar_evento(p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.evento (nombre_evento, titulo, descripcion, fecha, imagen)
    VALUES (p_nombre_evento, p_titulo, p_descripcion, p_fecha, p_imagen);
END;
$$;


ALTER FUNCTION public.agregar_evento(p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) OWNER TO postgres;

--
-- Name: agregar_pregunta_buzon(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.agregar_pregunta_buzon(p_pregunta text, p_correo text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.buzon (pregunta, correo)
    VALUES (p_pregunta, p_correo);
END;
$$;


ALTER FUNCTION public.agregar_pregunta_buzon(p_pregunta text, p_correo text) OWNER TO postgres;

--
-- Name: agregar_pregunta_frecuente(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.agregar_pregunta_frecuente(nueva_pregunta text, nueva_respuesta text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.pregunta_frecuente (pregunta, respuesta)
    VALUES (nueva_pregunta, nueva_respuesta);
END;
$$;


ALTER FUNCTION public.agregar_pregunta_frecuente(nueva_pregunta text, nueva_respuesta text) OWNER TO postgres;

--
-- Name: agregar_usuario(character varying, text, character varying, boolean, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.agregar_usuario(p_nombre character varying, "p_contraseña" text, p_telefono character varying, p_is_asignado boolean, p_id_rol_usuario integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar que siempre quede al menos un administrador
    IF p_id_rol_usuario = 1 AND p_is_asignado THEN
        -- Si es administrador con is_asignado true, asegurarse de que no haya otro
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = 1;
    END IF;

    INSERT INTO public.usuario (nombre, contraseña, telefono, is_asignado, id_rol_usuario)
    VALUES (p_nombre, p_contraseña, p_telefono, p_is_asignado, p_id_rol_usuario);
END;
$$;


ALTER FUNCTION public.agregar_usuario(p_nombre character varying, "p_contraseña" text, p_telefono character varying, p_is_asignado boolean, p_id_rol_usuario integer) OWNER TO postgres;

--
-- Name: eliminar_evento(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eliminar_evento(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.evento
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION public.eliminar_evento(p_id integer) OWNER TO postgres;

--
-- Name: eliminar_pregunta_buzon(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eliminar_pregunta_buzon(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.buzon
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION public.eliminar_pregunta_buzon(p_id integer) OWNER TO postgres;

--
-- Name: eliminar_pregunta_frecuente(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eliminar_pregunta_frecuente(id_pregunta integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.pregunta_frecuente
    WHERE id = id_pregunta;

    -- Verificar si se eliminó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró una pregunta frecuente con el ID %', id_pregunta;
    END IF;
END;
$$;


ALTER FUNCTION public.eliminar_pregunta_frecuente(id_pregunta integer) OWNER TO postgres;

--
-- Name: eliminar_todos_los_eventos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eliminar_todos_los_eventos() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.evento;

    RAISE NOTICE 'Todos los eventos han sido eliminados.';
END;
$$;


ALTER FUNCTION public.eliminar_todos_los_eventos() OWNER TO postgres;

--
-- Name: eliminar_usuario(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eliminar_usuario(p_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_rol_usuario INT;
    v_is_asignado BOOLEAN;
BEGIN
    -- Obtener el rol y estado de asignación del usuario a eliminar
    SELECT id_rol_usuario, is_asignado INTO v_id_rol_usuario, v_is_asignado
    FROM public.usuario
    WHERE id = p_id;

    -- Validar que siempre quede al menos un administrador
    IF v_id_rol_usuario = 1 THEN
        IF (SELECT COUNT(*) FROM public.usuario WHERE id_rol_usuario = 1) = 1 THEN
            RAISE EXCEPTION 'No se puede eliminar el único administrador.';
        END IF;
    END IF;

    -- Eliminar el usuario
    DELETE FROM public.usuario WHERE id = p_id;

    -- Si se elimina un técnico con is_asignado = true, asignar un administrador
    IF v_id_rol_usuario = 2 AND v_is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = true
        WHERE id = (
            SELECT id
            FROM public.usuario
            WHERE id_rol_usuario = 1
            LIMIT 1
        );
    END IF;
END;
$$;


ALTER FUNCTION public.eliminar_usuario(p_id integer) OWNER TO postgres;

--
-- Name: modificar_evento(integer, character varying, character varying, text, date, bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.modificar_evento(p_id integer, p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.evento
    SET nombre_evento = p_nombre_evento,
        titulo = p_titulo,
        descripcion = p_descripcion,
        fecha = p_fecha,
        imagen = p_imagen
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION public.modificar_evento(p_id integer, p_nombre_evento character varying, p_titulo character varying, p_descripcion text, p_fecha date, p_imagen bytea) OWNER TO postgres;

--
-- Name: modificar_is_asignado(integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.modificar_is_asignado(p_id integer, p_is_asignado boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_rol_usuario INT;
BEGIN
    SELECT id_rol_usuario INTO v_id_rol_usuario
    FROM public.usuario
    WHERE id = p_id;

    -- Solo permitir un usuario asignado
    IF p_is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = v_id_rol_usuario;
    END IF;

    UPDATE public.usuario
    SET is_asignado = p_is_asignado
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION public.modificar_is_asignado(p_id integer, p_is_asignado boolean) OWNER TO postgres;

--
-- Name: modificar_pregunta_frecuente(integer, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.modificar_pregunta_frecuente(id_pregunta integer, nueva_pregunta text, nueva_respuesta text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.pregunta_frecuente
    SET pregunta = nueva_pregunta,
        respuesta = nueva_respuesta
    WHERE id = id_pregunta;

    -- Verificar si se actualizó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró una pregunta frecuente con el ID %', id_pregunta;
    END IF;
END;
$$;


ALTER FUNCTION public.modificar_pregunta_frecuente(id_pregunta integer, nueva_pregunta text, nueva_respuesta text) OWNER TO postgres;

--
-- Name: modificar_show(integer, boolean, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.modificar_show(id_show integer, nuevo_is_disponible boolean, nuevo_horario text, nuevo_costo text, "nueva_interaccion_niños" text, nueva_interaccion_adultos text, nueva_ubicacion text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    nombre_show TEXT;
BEGIN
    -- Obtener el nombre del show
    SELECT nombre INTO nombre_show
    FROM public.show
    WHERE id = id_show;

    -- Validar el tipo de show y aplicar reglas
    IF nombre_show = 'Show de Payasos y Magos' THEN
        -- Modificar para Payasos y Magos
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo),
            ubicacion = COALESCE(nueva_ubicacion, ubicacion),
            "interaccion_niños" = NULL,
            interaccion_adultos = NULL
        WHERE id = id_show;

    ELSIF nombre_show = 'Show de Delfines' OR nombre_show = 'Show de Lobos Marinos' THEN
        -- Modificar para Delfines y Lobos Marinos
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo),
            "interaccion_niños" = COALESCE(nueva_interaccion_niños, "interaccion_niños"),
            interaccion_adultos = COALESCE(nueva_interaccion_adultos, interaccion_adultos)
        WHERE id = id_show;
    ELSE
        -- Modificar para otros shows
        UPDATE public.show
        SET is_disponible = COALESCE(nuevo_is_disponible, is_disponible),
            horario = COALESCE(nuevo_horario, horario),
            costo = COALESCE(nuevo_costo, costo)
        WHERE id = id_show;
    END IF;

    -- Verificar si se actualizó algo
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró un show con el ID %', id_show;
    END IF;
END;
$$;


ALTER FUNCTION public.modificar_show(id_show integer, nuevo_is_disponible boolean, nuevo_horario text, nuevo_costo text, "nueva_interaccion_niños" text, nueva_interaccion_adultos text, nueva_ubicacion text) OWNER TO postgres;

--
-- Name: mostrar_eventos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mostrar_eventos() RETURNS TABLE(id_evento integer, nombre_evento character varying, titulo character varying, descripcion text, fecha date, imagen bytea)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.nombre_evento, e.titulo, e.descripcion, e.fecha, e.imagen
    FROM public.evento e;
END;
$$;


ALTER FUNCTION public.mostrar_eventos() OWNER TO postgres;

--
-- Name: mostrar_preguntas_buzon(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mostrar_preguntas_buzon() RETURNS TABLE(id_buzon integer, pregunta text, correo text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT b.id, b.pregunta, b.correo
    FROM public.buzon b;
END;
$$;


ALTER FUNCTION public.mostrar_preguntas_buzon() OWNER TO postgres;

--
-- Name: mostrar_preguntas_frecuentes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mostrar_preguntas_frecuentes() RETURNS TABLE(id_pregunta integer, pregunta text, respuesta text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT pf.id, pf.pregunta, pf.respuesta
    FROM public.pregunta_frecuente pf;
END;
$$;


ALTER FUNCTION public.mostrar_preguntas_frecuentes() OWNER TO postgres;

--
-- Name: mostrar_shows(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mostrar_shows() RETURNS TABLE(id_show integer, nombre character varying, is_disponible boolean, horario_tipo text, horario text, ubicacion text, costo text, "interaccion_niños" text, interaccion_adultos text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.nombre, s.is_disponible, s.horario_tipo, s.horario,
           s.ubicacion, s.costo, s."interaccion_niños", s.interaccion_adultos
    FROM public.show s;
END;
$$;


ALTER FUNCTION public.mostrar_shows() OWNER TO postgres;

--
-- Name: mostrar_usuarios(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mostrar_usuarios() RETURNS TABLE(id_usuario integer, nombre character varying, telefono character varying, is_asignado boolean, rol_usuario text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.nombre, u.telefono, u.is_asignado, r.rol
    FROM public.usuario u
    JOIN public.rol r ON u.id_rol_usuario = r.id;
END;
$$;


ALTER FUNCTION public.mostrar_usuarios() OWNER TO postgres;

--
-- Name: validar_modificaciones_show(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_modificaciones_show() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Restricción para Show de Delfines y Lobos Marinos
    IF (NEW.nombre = 'Show de Delfines' OR NEW.nombre = 'Show de Lobos Marinos') AND
       (NEW.ubicacion IS DISTINCT FROM OLD.ubicacion OR NEW.horario_tipo IS DISTINCT FROM OLD.horario_tipo) THEN
        RAISE EXCEPTION 'No se permite modificar la ubicación ni el tipo de horario para el show de %', NEW.nombre;
    END IF;

    -- Restricción para Show de Payasos y Magos
    IF NEW.nombre = 'Show de Payasos y Magos' AND
       (NEW."interaccion_niños" IS NOT NULL OR NEW.interaccion_adultos IS NOT NULL) THEN
        RAISE EXCEPTION 'El show de Payasos y Magos no tiene interacciones con niños ni adultos';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validar_modificaciones_show() OWNER TO postgres;

--
-- Name: validar_unica_pregunta(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_unica_pregunta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si el correo ya existe en la tabla buzon
    IF EXISTS (SELECT 1 FROM public.buzon WHERE correo = NEW.correo) THEN
        RAISE EXCEPTION 'El correo % ya tiene una pregunta registrada.', NEW.correo;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validar_unica_pregunta() OWNER TO postgres;

--
-- Name: validar_unico_administrador(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_unico_administrador() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar que siempre quede al menos un administrador
    IF OLD.id_rol_usuario = 1 AND
       (SELECT COUNT(*) FROM public.usuario WHERE id_rol_usuario = 1) = 1 THEN
        RAISE EXCEPTION 'No se puede eliminar el único administrador.';
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.validar_unico_administrador() OWNER TO postgres;

--
-- Name: validar_unico_asignado(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_unico_asignado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Asegurar que no haya más de un usuario asignado por rol
    IF NEW.is_asignado THEN
        UPDATE public.usuario
        SET is_asignado = false
        WHERE id_rol_usuario = NEW.id_rol_usuario AND id <> NEW.id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validar_unico_asignado() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: buzon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buzon (
    id integer NOT NULL,
    pregunta text,
    correo text
);


ALTER TABLE public.buzon OWNER TO postgres;

--
-- Name: buzon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.buzon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.buzon_id_seq OWNER TO postgres;

--
-- Name: buzon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.buzon_id_seq OWNED BY public.buzon.id;


--
-- Name: evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evento (
    id integer NOT NULL,
    nombre_evento character varying(50),
    titulo character varying(50),
    descripcion text,
    fecha date,
    imagen bytea
);


ALTER TABLE public.evento OWNER TO postgres;

--
-- Name: evento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.evento_id_seq OWNER TO postgres;

--
-- Name: evento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.evento_id_seq OWNED BY public.evento.id;


--
-- Name: pregunta_frecuente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pregunta_frecuente (
    id integer NOT NULL,
    pregunta text,
    respuesta text
);


ALTER TABLE public.pregunta_frecuente OWNER TO postgres;

--
-- Name: pregunta_frecuente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pregunta_frecuente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pregunta_frecuente_id_seq OWNER TO postgres;

--
-- Name: pregunta_frecuente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pregunta_frecuente_id_seq OWNED BY public.pregunta_frecuente.id;


--
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol (
    id integer NOT NULL,
    rol text
);


ALTER TABLE public.rol OWNER TO postgres;

--
-- Name: show; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.show (
    id integer NOT NULL,
    nombre character varying(50),
    is_disponible boolean,
    horario_tipo text,
    horario text,
    ubicacion text,
    costo text,
    "interaccion_niños" text,
    interaccion_adultos text
);


ALTER TABLE public.show OWNER TO postgres;

--
-- Name: show_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.show_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.show_id_seq OWNER TO postgres;

--
-- Name: show_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.show_id_seq OWNED BY public.show.id;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    nombre character varying(50),
    "contraseña" text,
    telefono character varying(8),
    is_asignado boolean,
    id_rol_usuario integer
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_seq OWNER TO postgres;

--
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- Name: buzon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buzon ALTER COLUMN id SET DEFAULT nextval('public.buzon_id_seq'::regclass);


--
-- Name: evento id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento ALTER COLUMN id SET DEFAULT nextval('public.evento_id_seq'::regclass);


--
-- Name: pregunta_frecuente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregunta_frecuente ALTER COLUMN id SET DEFAULT nextval('public.pregunta_frecuente_id_seq'::regclass);


--
-- Name: show id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.show ALTER COLUMN id SET DEFAULT nextval('public.show_id_seq'::regclass);


--
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- Data for Name: buzon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.buzon (id, pregunta, correo) FROM stdin;
\.
COPY public.buzon (id, pregunta, correo) FROM '$$PATH$$/4847.dat';

--
-- Data for Name: evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evento (id, nombre_evento, titulo, descripcion, fecha, imagen) FROM stdin;
\.
COPY public.evento (id, nombre_evento, titulo, descripcion, fecha, imagen) FROM '$$PATH$$/4849.dat';

--
-- Data for Name: pregunta_frecuente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pregunta_frecuente (id, pregunta, respuesta) FROM stdin;
\.
COPY public.pregunta_frecuente (id, pregunta, respuesta) FROM '$$PATH$$/4851.dat';

--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rol (id, rol) FROM stdin;
\.
COPY public.rol (id, rol) FROM '$$PATH$$/4852.dat';

--
-- Data for Name: show; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.show (id, nombre, is_disponible, horario_tipo, horario, ubicacion, costo, "interaccion_niños", interaccion_adultos) FROM stdin;
\.
COPY public.show (id, nombre, is_disponible, horario_tipo, horario, ubicacion, costo, "interaccion_niños", interaccion_adultos) FROM '$$PATH$$/4854.dat';

--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id, nombre, "contraseña", telefono, is_asignado, id_rol_usuario) FROM stdin;
\.
COPY public.usuario (id, nombre, "contraseña", telefono, is_asignado, id_rol_usuario) FROM '$$PATH$$/4856.dat';

--
-- Name: buzon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.buzon_id_seq', 2, true);


--
-- Name: evento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evento_id_seq', 3, true);


--
-- Name: pregunta_frecuente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pregunta_frecuente_id_seq', 1, true);


--
-- Name: show_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.show_id_seq', 1, false);


--
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_seq', 6, true);


--
-- Name: evento evento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);


--
-- Name: buzon id_buzon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buzon
    ADD CONSTRAINT id_buzon_pkey PRIMARY KEY (id);


--
-- Name: pregunta_frecuente pregunta_frecuente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregunta_frecuente
    ADD CONSTRAINT pregunta_frecuente_pkey PRIMARY KEY (id);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id);


--
-- Name: show show_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.show
    ADD CONSTRAINT show_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: fki_id_rol_usuario_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_id_rol_usuario_fkey ON public.usuario USING btree (id_rol_usuario);


--
-- Name: usuario trg_validar_unico_administrador; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_unico_administrador BEFORE DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.validar_unico_administrador();


--
-- Name: usuario trg_validar_unico_asignado; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_unico_asignado BEFORE INSERT OR UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.validar_unico_asignado();


--
-- Name: show trigger_validar_modificaciones_show; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_validar_modificaciones_show BEFORE UPDATE ON public.show FOR EACH ROW EXECUTE FUNCTION public.validar_modificaciones_show();


--
-- Name: buzon validar_pregunta_unica; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validar_pregunta_unica BEFORE INSERT ON public.buzon FOR EACH ROW EXECUTE FUNCTION public.validar_unica_pregunta();


--
-- Name: usuario id_rol_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT id_rol_usuario_fkey FOREIGN KEY (id_rol_usuario) REFERENCES public.rol(id);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
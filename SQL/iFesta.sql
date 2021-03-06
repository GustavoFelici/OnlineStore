PGDMP     ;    ;                w            iFesta    11.5    11.5 L    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    66026    iFesta    DATABASE     �   CREATE DATABASE "iFesta" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Portuguese_Brazil.1252' LC_CTYPE = 'Portuguese_Brazil.1252';
    DROP DATABASE "iFesta";
             postgres    false            �            1255    66436    casc_cliente()    FUNCTION     �  CREATE FUNCTION public.casc_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
		 DELETE FROM telefone as t
		 where t.id_cliente=old.id_cliente;
	
		 DELETE FROM card as c
		 where c.id_cliente=old.id_cliente;	
	
		 DELETE FROM item_pedido as ip
		 where ip.id_pedido in (select id_pedido from pedido where id_cli = old.id_cliente); 
	
		 DELETE FROM pedido as p
		 where p.id_cli=old.id_cliente;

		 DELETE FROM endereco as e
		 where e.id_cliente=old.id_cliente;
	 
return old;
COMMIT;
END; $$;
 %   DROP FUNCTION public.casc_cliente();
       public       postgres    false            �            1255    66398    registrahistcli()    FUNCTION     e  CREATE FUNCTION public.registrahistcli() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
	if (TG_OP = 'INSERT') THEN
	INSERT INTO public.historico_cliente(
	id_cliente, nome, cpf, email, senha, cli_datainse, alteracao, data_alt)
	VALUES (new.id_cliente, new.nome, new.cpf, new.email, new.senha, new.cli_datainse,'INSERT', now());

	elsif (TG_OP = 'DELETE') THEN 
	INSERT INTO public.historico_cliente(
	id_cliente, nome, cpf, email, senha, cli_datainse, alteracao, data_alt)
	VALUES (old.id_cliente, old.nome, old.cpf, old.email, old.senha, old.cli_datainse,'DELETE', now());

	elsif (TG_OP = 'UPDATE') THEN
	INSERT INTO public.historico_cliente(
	id_cliente, nome, cpf, email, senha, cli_datainse, alteracao, data_alt)
	VALUES (old.id_cliente, old.nome, old.cpf, old.email, old.senha, old.cli_datainse,'UPDATE', now());
end if; 
return NULL;
 COMMIT; 

END; $$;
 (   DROP FUNCTION public.registrahistcli();
       public       postgres    false            �            1255    66400    registrahistprod()    FUNCTION     �  CREATE FUNCTION public.registrahistprod() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
	if (TG_OP = 'INSERT') THEN
	INSERT INTO public.historico_produto(
	id_produto, id_categoria, nome, quantidade, preco, id_fornecedor, alteracao, data_alt)
	VALUES (new.id_produto, new.id_categoria, new.nome, new.quantidade, new.quantidade, new.preco, 'INSERT', now());


	elsif (TG_OP = 'DELETE') THEN 
	INSERT INTO public.historico_produto(
	id_produto, id_categoria, nome, quantidade, preco, id_fornecedor, alteracao, data_alt)
	VALUES (old.id_produto, old.id_categoria, old.nome, old.quantidade, old.quantidade, old.preco, 'DELETE', now());


	elsif (TG_OP = 'UPDATE') THEN
	INSERT INTO public.historico_produto(
	id_produto, id_categoria, nome, quantidade, preco, id_fornecedor, alteracao, data_alt)
	VALUES (old.id_produto, old.id_categoria, old.nome, old.quantidade, old.quantidade, old.preco, 'UPDATE', now());

end if; 
return NULL;
 COMMIT; 

END; $$;
 )   DROP FUNCTION public.registrahistprod();
       public       postgres    false            �            1255    66451    verifica_compras() 	   PROCEDURE     >  CREATE PROCEDURE public.verifica_compras()
    LANGUAGE plpgsql
    AS $$
BEGIN
		UPDATE Cliente
		SET compras = 0
		WHERE id_cliente in (select c.id_cliente 
							from cliente as c
							EXCEPT
							select c.id_cliente 
							from pedido as p, cliente c
							where c.id_cliente = p.id_cli);
 COMMIT;
END;
$$;
 *   DROP PROCEDURE public.verifica_compras();
       public       postgres    false            �            1255    66416    verifica_finalizado() 	   PROCEDURE     �   CREATE PROCEDURE public.verifica_finalizado()
    LANGUAGE plpgsql
    AS $$
BEGIN
		UPDATE pedido
		SET finalizado = true
		WHERE data_entrega >= current_date;
 COMMIT;
END;
$$;
 -   DROP PROCEDURE public.verifica_finalizado();
       public       postgres    false            �            1259    66250    card    TABLE     �   CREATE TABLE public.card (
    id_card integer NOT NULL,
    id_cliente integer,
    numero character varying,
    data_vali character varying,
    codseg character varying,
    flag character varying
);
    DROP TABLE public.card;
       public         postgres    false            �            1259    66282 	   categoria    TABLE     �   CREATE TABLE public.categoria (
    id_categoria integer NOT NULL,
    nome character varying,
    descricao character varying
);
    DROP TABLE public.categoria;
       public         postgres    false            �            1259    66363    cidades    TABLE     �   CREATE TABLE public.cidades (
    id integer NOT NULL,
    nome character varying,
    codigo_ibge integer,
    estado_id integer,
    populacao_2010 integer,
    densidade_demo numeric,
    gentilico character varying(250),
    area numeric
);
    DROP TABLE public.cidades;
       public         postgres    false            �            1259    66369    cidades_id_seq    SEQUENCE     v   CREATE SEQUENCE public.cidades_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.cidades_id_seq;
       public       postgres    false    207            �           0    0    cidades_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.cidades_id_seq OWNED BY public.cidades.id;
            public       postgres    false    208            �            1259    66232    cliente    TABLE     9  CREATE TABLE public.cliente (
    id_cliente integer NOT NULL,
    nome character varying,
    cpf character varying,
    email character varying,
    senha character varying,
    compras integer DEFAULT 0,
    cli_datainse timestamp with time zone,
    CONSTRAINT cliente_compras_check CHECK ((compras >= 0))
);
    DROP TABLE public.cliente;
       public         postgres    false            �            1259    66242    endereco    TABLE       CREATE TABLE public.endereco (
    id_endereco integer NOT NULL,
    id_cliente integer,
    rua character varying,
    numero character varying,
    bairro character varying,
    cep character varying,
    id_cidade integer,
    complemento character varying
);
    DROP TABLE public.endereco;
       public         postgres    false            �            1259    66371    estados    TABLE     r   CREATE TABLE public.estados (
    id integer NOT NULL,
    nome character varying,
    sigla character varying
);
    DROP TABLE public.estados;
       public         postgres    false            �            1259    66377    estados_id_seq    SEQUENCE     v   CREATE SEQUENCE public.estados_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.estados_id_seq;
       public       postgres    false    209            �           0    0    estados_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.estados_id_seq OWNED BY public.estados.id;
            public       postgres    false    210            �            1259    66290 
   fornecedor    TABLE     c   CREATE TABLE public.fornecedor (
    id_fornecedor integer NOT NULL,
    nome character varying
);
    DROP TABLE public.fornecedor;
       public         postgres    false            �            1259    66266    historico_cliente    TABLE       CREATE TABLE public.historico_cliente (
    id_cliente integer,
    nome character varying,
    cpf character varying,
    email character varying,
    senha character varying,
    cli_datainse timestamp with time zone,
    alteracao character varying,
    data_alt date
);
 %   DROP TABLE public.historico_cliente;
       public         postgres    false            �            1259    66312    item_pedido    TABLE     9  CREATE TABLE public.item_pedido (
    id_pedido integer,
    id_produto integer,
    quantidade integer,
    preco_total double precision DEFAULT 0,
    CONSTRAINT item_pedido_preco_total_check CHECK ((preco_total > (0)::double precision)),
    CONSTRAINT item_pedido_quantidade_check CHECK ((quantidade > 0))
);
    DROP TABLE public.item_pedido;
       public         postgres    false            �            1259    66305    pedido    TABLE     �   CREATE TABLE public.pedido (
    id_pedido integer NOT NULL,
    id_cli integer,
    id_endereco integer,
    frete double precision DEFAULT 0,
    data_envio date,
    data_entrega date,
    finalizado boolean DEFAULT false
);
    DROP TABLE public.pedido;
       public         postgres    false            �            1259    66272    produto    TABLE     T  CREATE TABLE public.produto (
    id_produto integer NOT NULL,
    id_categoria integer,
    nome character varying,
    quantidade integer,
    preco double precision,
    id_fornecedor integer,
    CONSTRAINT produto_preco_check CHECK ((preco > (0)::double precision)),
    CONSTRAINT produto_quantidade_check CHECK ((quantidade > 0))
);
    DROP TABLE public.produto;
       public         postgres    false            �            1259    66464    historico_compras    VIEW     �  CREATE VIEW public.historico_compras AS
 SELECT row_number() OVER (ORDER BY pe.id_cli) AS "row",
    pe.id_cli,
    pe.id_pedido AS codigo_pedido,
    p.nome,
    i.quantidade,
    i.preco_total,
    (pe.data_envio - 1) AS data_da_compra
   FROM public.item_pedido i,
    public.pedido pe,
    public.produto p
  WHERE ((pe.id_pedido = i.id_pedido) AND (i.id_produto = p.id_produto));
 $   DROP VIEW public.historico_compras;
       public       postgres    false    205    201    201    205    205    206    206    206    206            �            1259    66298    historico_produto    TABLE       CREATE TABLE public.historico_produto (
    id_produto integer,
    id_categoria integer,
    nome character varying,
    quantidade integer,
    preco double precision DEFAULT 0,
    id_fornecedor integer,
    alteracao character varying,
    data_alt date
);
 %   DROP TABLE public.historico_produto;
       public         postgres    false            �            1259    66472    nome_estado    VIEW     �   CREATE VIEW public.nome_estado AS
 SELECT ed.id_endereco,
    e.nome
   FROM public.estados e,
    public.cidades cid,
    public.endereco ed
  WHERE ((ed.id_cidade = cid.id) AND (cid.estado_id = e.id));
    DROP VIEW public.nome_estado;
       public       postgres    false    209    197    207    207    209    197            �            1259    66452    pedido_total    VIEW     �  CREATE VIEW public.pedido_total AS
 SELECT p.id_cli,
    c.nome,
    count(p.id_pedido) AS num_pedido,
    ( SELECT sum(i.preco_total) AS sum
           FROM public.item_pedido i,
            public.pedido p_1
          WHERE (i.id_pedido = p_1.id_pedido)) AS valor_total
   FROM public.pedido p,
    public.cliente c
  WHERE (p.id_cli = c.id_cliente)
  GROUP BY p.id_cli, c.nome, p.frete
  ORDER BY (count(p.id_pedido));
    DROP VIEW public.pedido_total;
       public       postgres    false    206    206    205    205    205    196    196            �            1259    66447    produto_categoria    VIEW     �   CREATE VIEW public.produto_categoria AS
SELECT
    NULL::integer AS id_categoria,
    NULL::character varying AS nome,
    NULL::bigint AS produtos_na_categoria;
 $   DROP VIEW public.produto_categoria;
       public       postgres    false            �            1259    66443    produto_fornecedor    VIEW     �   CREATE VIEW public.produto_fornecedor AS
SELECT
    NULL::integer AS id_fornecedor,
    NULL::character varying AS nome,
    NULL::bigint AS produtos_no_fornecedor;
 %   DROP VIEW public.produto_fornecedor;
       public       postgres    false            �            1259    66258    telefone    TABLE     y   CREATE TABLE public.telefone (
    id_telefone integer NOT NULL,
    id_cliente integer,
    numero character varying
);
    DROP TABLE public.telefone;
       public         postgres    false            �            1259    66429    valor_pedido    VIEW     �   CREATE VIEW public.valor_pedido AS
SELECT
    NULL::integer AS id_cli,
    NULL::character varying AS nome,
    NULL::integer AS id_pedido,
    NULL::double precision AS valor_total;
    DROP VIEW public.valor_pedido;
       public       postgres    false            �
           2604    66379 
   cidades id    DEFAULT     h   ALTER TABLE ONLY public.cidades ALTER COLUMN id SET DEFAULT nextval('public.cidades_id_seq'::regclass);
 9   ALTER TABLE public.cidades ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    208    207            �
           2604    66380 
   estados id    DEFAULT     h   ALTER TABLE ONLY public.estados ALTER COLUMN id SET DEFAULT nextval('public.estados_id_seq'::regclass);
 9   ALTER TABLE public.estados ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    210    209            �          0    66250    card 
   TABLE DATA               T   COPY public.card (id_card, id_cliente, numero, data_vali, codseg, flag) FROM stdin;
    public       postgres    false    198   �k       �          0    66282 	   categoria 
   TABLE DATA               B   COPY public.categoria (id_categoria, nome, descricao) FROM stdin;
    public       postgres    false    202   �k       �          0    66363    cidades 
   TABLE DATA               t   COPY public.cidades (id, nome, codigo_ibge, estado_id, populacao_2010, densidade_demo, gentilico, area) FROM stdin;
    public       postgres    false    207   �l       �          0    66232    cliente 
   TABLE DATA               ]   COPY public.cliente (id_cliente, nome, cpf, email, senha, compras, cli_datainse) FROM stdin;
    public       postgres    false    196   ٺ      �          0    66242    endereco 
   TABLE DATA               m   COPY public.endereco (id_endereco, id_cliente, rua, numero, bairro, cep, id_cidade, complemento) FROM stdin;
    public       postgres    false    197   �      �          0    66371    estados 
   TABLE DATA               2   COPY public.estados (id, nome, sigla) FROM stdin;
    public       postgres    false    209   �      �          0    66290 
   fornecedor 
   TABLE DATA               9   COPY public.fornecedor (id_fornecedor, nome) FROM stdin;
    public       postgres    false    203   <�      �          0    66266    historico_cliente 
   TABLE DATA               s   COPY public.historico_cliente (id_cliente, nome, cpf, email, senha, cli_datainse, alteracao, data_alt) FROM stdin;
    public       postgres    false    200   ��      �          0    66298    historico_produto 
   TABLE DATA               �   COPY public.historico_produto (id_produto, id_categoria, nome, quantidade, preco, id_fornecedor, alteracao, data_alt) FROM stdin;
    public       postgres    false    204   ��      �          0    66312    item_pedido 
   TABLE DATA               U   COPY public.item_pedido (id_pedido, id_produto, quantidade, preco_total) FROM stdin;
    public       postgres    false    206   ]�      �          0    66305    pedido 
   TABLE DATA               m   COPY public.pedido (id_pedido, id_cli, id_endereco, frete, data_envio, data_entrega, finalizado) FROM stdin;
    public       postgres    false    205   5�      �          0    66272    produto 
   TABLE DATA               c   COPY public.produto (id_produto, id_categoria, nome, quantidade, preco, id_fornecedor) FROM stdin;
    public       postgres    false    201   ��      �          0    66258    telefone 
   TABLE DATA               C   COPY public.telefone (id_telefone, id_cliente, numero) FROM stdin;
    public       postgres    false    199   ��      �           0    0    cidades_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.cidades_id_seq', 5565, true);
            public       postgres    false    208            �           0    0    estados_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.estados_id_seq', 27, true);
            public       postgres    false    210            �
           2606    66257    card card_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id_card);
 8   ALTER TABLE ONLY public.card DROP CONSTRAINT card_pkey;
       public         postgres    false    198            �
           2606    66289    categoria categoria_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_categoria);
 B   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_pkey;
       public         postgres    false    202            �
           2606    66241    cliente cliente_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);
 >   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_pkey;
       public         postgres    false    196            �
           2606    66249    endereco endereco_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT endereco_pkey PRIMARY KEY (id_endereco);
 @   ALTER TABLE ONLY public.endereco DROP CONSTRAINT endereco_pkey;
       public         postgres    false    197            �
           2606    66297    fornecedor fornecedor_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.fornecedor
    ADD CONSTRAINT fornecedor_pkey PRIMARY KEY (id_fornecedor);
 D   ALTER TABLE ONLY public.fornecedor DROP CONSTRAINT fornecedor_pkey;
       public         postgres    false    203            �
           2606    66311    pedido pedido_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);
 <   ALTER TABLE ONLY public.pedido DROP CONSTRAINT pedido_pkey;
       public         postgres    false    205            �
           2606    66382    cidades pk_cidade_id 
   CONSTRAINT     R   ALTER TABLE ONLY public.cidades
    ADD CONSTRAINT pk_cidade_id PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.cidades DROP CONSTRAINT pk_cidade_id;
       public         postgres    false    207            �
           2606    66384    estados pk_estados_id 
   CONSTRAINT     S   ALTER TABLE ONLY public.estados
    ADD CONSTRAINT pk_estados_id PRIMARY KEY (id);
 ?   ALTER TABLE ONLY public.estados DROP CONSTRAINT pk_estados_id;
       public         postgres    false    209            �
           2606    66281    produto produto_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.produto
    ADD CONSTRAINT produto_pkey PRIMARY KEY (id_produto);
 >   ALTER TABLE ONLY public.produto DROP CONSTRAINT produto_pkey;
       public         postgres    false    201            �
           2606    66265    telefone telefone_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.telefone
    ADD CONSTRAINT telefone_pkey PRIMARY KEY (id_telefone);
 @   ALTER TABLE ONLY public.telefone DROP CONSTRAINT telefone_pkey;
       public         postgres    false    199            ~           2618    66432    valor_pedido _RETURN    RULE     O  CREATE OR REPLACE VIEW public.valor_pedido AS
 SELECT p.id_cli,
    c.nome,
    p.id_pedido,
    (sum(i.preco_total) + p.frete) AS valor_total
   FROM public.item_pedido i,
    public.pedido p,
    public.cliente c
  WHERE ((i.id_pedido = p.id_pedido) AND (p.id_cli = c.id_cliente))
  GROUP BY p.id_pedido, c.nome
  ORDER BY p.id_cli;
 �   CREATE OR REPLACE VIEW public.valor_pedido AS
SELECT
    NULL::integer AS id_cli,
    NULL::character varying AS nome,
    NULL::integer AS id_pedido,
    NULL::double precision AS valor_total;
       public       postgres    false    2802    206    206    205    205    205    196    196    211                       2618    66446    produto_fornecedor _RETURN    RULE       CREATE OR REPLACE VIEW public.produto_fornecedor AS
 SELECT f.id_fornecedor,
    f.nome,
    count(p.id_fornecedor) AS produtos_no_fornecedor
   FROM public.produto p,
    public.fornecedor f
  WHERE (p.id_fornecedor = f.id_fornecedor)
  GROUP BY f.id_fornecedor;
 �   CREATE OR REPLACE VIEW public.produto_fornecedor AS
SELECT
    NULL::integer AS id_fornecedor,
    NULL::character varying AS nome,
    NULL::bigint AS produtos_no_fornecedor;
       public       postgres    false    2800    203    203    201    212            �           2618    66450    produto_categoria _RETURN    RULE        CREATE OR REPLACE VIEW public.produto_categoria AS
 SELECT c.id_categoria,
    c.nome,
    count(p.id_categoria) AS produtos_na_categoria
   FROM public.produto p,
    public.categoria c
  WHERE (p.id_categoria = c.id_categoria)
  GROUP BY c.id_categoria;
 �   CREATE OR REPLACE VIEW public.produto_categoria AS
SELECT
    NULL::integer AS id_categoria,
    NULL::character varying AS nome,
    NULL::bigint AS produtos_na_categoria;
       public       postgres    false    2798    202    202    201    213                       2620    66442    cliente trigger_casc_cliente    TRIGGER     z   CREATE TRIGGER trigger_casc_cliente BEFORE DELETE ON public.cliente FOR EACH ROW EXECUTE PROCEDURE public.casc_cliente();
 5   DROP TRIGGER trigger_casc_cliente ON public.cliente;
       public       postgres    false    232    196                       2620    66399    cliente trigger_registrahistcli    TRIGGER     �   CREATE TRIGGER trigger_registrahistcli AFTER INSERT OR DELETE OR UPDATE ON public.cliente FOR EACH ROW EXECUTE PROCEDURE public.registrahistcli();
 8   DROP TRIGGER trigger_registrahistcli ON public.cliente;
       public       postgres    false    218    196                       2620    66402     produto trigger_registrahistprod    TRIGGER     �   CREATE TRIGGER trigger_registrahistprod AFTER INSERT OR DELETE OR UPDATE ON public.produto FOR EACH ROW EXECUTE PROCEDURE public.registrahistprod();
 9   DROP TRIGGER trigger_registrahistprod ON public.produto;
       public       postgres    false    231    201            �
           2606    66358    card card_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);
 C   ALTER TABLE ONLY public.card DROP CONSTRAINT card_id_cliente_fkey;
       public       postgres    false    2788    198    196            �
           2606    66390     endereco endereco_id_cidade_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT endereco_id_cidade_fkey FOREIGN KEY (id_cidade) REFERENCES public.cidades(id);
 J   ALTER TABLE ONLY public.endereco DROP CONSTRAINT endereco_id_cidade_fkey;
       public       postgres    false    197    2804    207            �
           2606    66343 !   endereco endereco_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT endereco_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);
 K   ALTER TABLE ONLY public.endereco DROP CONSTRAINT endereco_id_cliente_fkey;
       public       postgres    false    2788    197    196                       2606    66385    cidades fk_estado_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.cidades
    ADD CONSTRAINT fk_estado_id FOREIGN KEY (estado_id) REFERENCES public.estados(id) ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.cidades DROP CONSTRAINT fk_estado_id;
       public       postgres    false    209    207    2806            �
           2606    66323 &   item_pedido item_pedido_id_pedido_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.item_pedido
    ADD CONSTRAINT item_pedido_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);
 P   ALTER TABLE ONLY public.item_pedido DROP CONSTRAINT item_pedido_id_pedido_fkey;
       public       postgres    false    205    206    2802                        2606    66338 '   item_pedido item_pedido_id_produto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.item_pedido
    ADD CONSTRAINT item_pedido_id_produto_fkey FOREIGN KEY (id_produto) REFERENCES public.produto(id_produto);
 Q   ALTER TABLE ONLY public.item_pedido DROP CONSTRAINT item_pedido_id_produto_fkey;
       public       postgres    false    2796    206    201            �
           2606    66318    pedido pedido_id_cli_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_id_cli_fkey FOREIGN KEY (id_cli) REFERENCES public.cliente(id_cliente);
 C   ALTER TABLE ONLY public.pedido DROP CONSTRAINT pedido_id_cli_fkey;
       public       postgres    false    2788    196    205            �
           2606    66353    pedido pedido_id_endereco_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_id_endereco_fkey FOREIGN KEY (id_endereco) REFERENCES public.endereco(id_endereco);
 H   ALTER TABLE ONLY public.pedido DROP CONSTRAINT pedido_id_endereco_fkey;
       public       postgres    false    197    2790    205            �
           2606    66333 !   produto produto_id_categoria_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.produto
    ADD CONSTRAINT produto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria);
 K   ALTER TABLE ONLY public.produto DROP CONSTRAINT produto_id_categoria_fkey;
       public       postgres    false    2798    202    201            �
           2606    66328 "   produto produto_id_fornecedor_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.produto
    ADD CONSTRAINT produto_id_fornecedor_fkey FOREIGN KEY (id_fornecedor) REFERENCES public.fornecedor(id_fornecedor);
 L   ALTER TABLE ONLY public.produto DROP CONSTRAINT produto_id_fornecedor_fkey;
       public       postgres    false    203    201    2800            �
           2606    66348 !   telefone telefone_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.telefone
    ADD CONSTRAINT telefone_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);
 K   ALTER TABLE ONLY public.telefone DROP CONSTRAINT telefone_id_cliente_fkey;
       public       postgres    false    196    2788    199            �   >   x�3�4�4426153� 2�,A��9�\�I(elbl��M,.I-rN,J����� ���      �   �   x�m��1D�v� �Vܐ(`/��YEJ0�����]���h��z�.�e҂$��C�q2�;
�^�ǒ�������N�zV`Mɨ���Ή#�xO'+�`�?_�Έ.��|x����l=Ê�_�QE�      �      x�l��r�F�-:��?@���!�S&U�S*�6�d"-��G�N���GTנLm�Q�;)�3��]k�DPu��:�t�`���~���~<L��_��	�mCۄ&�TK�o�����z�=��TC���*7oƧ���a��A �	$m��%\�WO�q\M���o��i12�жM��Y�{��������tU���ӧ�,�%S�Bl�m�X�i������!��I����G{\Jz\l�&��y�~�����n�.^�w�����qs�����8O�����^��};t�qY?�GJ��{,W�k~�폻�W��Z��h���v��G����_�U�����q���V@�0�xf�LȾ��m�'����~�_m>� �Jm�۾4�yψ-:�v�ok�
��q����O���7�e!���p�7�y���i��6��*��q?����_�6��Y}s����@8��*��?Ƨ�~� 4�m(��_�d'���6�t���v$�d�6�ơ�_���7#׌�J��x���q܌�xÓ��Q���X�x�Ҽ������������'�6��	?d�-��L�!_Y����q�� ��O���h؏�m��*���z���ǵ��Bj��S��a��˂K�m���wx��Ӵ���������O�}�%�u�S�->�*u�ƫ��A"q$�I�-H}�~��m�U����>�z̀m��3�����V�Zu�aoY���fϻ-�̧�6E"���<�ϗ��pV`7�}܂����a�ް�@�p� 췠ϝ}V!L����� Ѫ=$���pե��n:>�z�vw�������
�	1�v@	v��v��a�����|��\�v*s&\��-�Ӷ8'�U�мُϿ���0c� Uv]�ڏӌ�p���ڼ�M���Ӹ�h���#��0��\���Z�w�-_�D6��W��a���Y��9��d��#4�={��� �����Kx�$��w��k��qK�W�k�/9�?��pǭ���;�}�c	�X�+ض8�r��{���~8�q(�y� <��64Ӽ�L4�U�U�w���������)V�
%D3i��vgL����C�k�-8�^�p���e�~A<#wS�ܶ���m�/<v
���]��Ox��}������ނ�|Z�]^��ڕ+��o׸���~;^��wF���侸����K� �
��U�5��F���������>ƌ_2������g{h׊O�oO[#]u�a���c�?��_�p�k�A��D�$��w������4�gT ���
����i��~w��w�da7�R�O:&-�ـ?��� 3!��^�כ��Tť�	2}��6���x5$���'g�]o�&���m3��"1�o����n����	�!���C�%��]���+����^�l���{���0<��+{U�Q[��R��~}8LvE�q��>y 
�G�.�@k�{IpL��<�6�A
�}_)�-H��J��U����d�2^"%�khpA�"m]փ/��
X�#N���>�?ʻ�f<���l��� ǥ�d�Xra!�uW���g��u�]͢���]
�`L��O�?�>c��˽$P��6ܘ�s���d��&�øy���K���@#5f�'���3��muJ�����~ *W;��=�,��"�;�l��(�9vW��z:I�XG� �8'�	�i�q�27^U��	�XӴ5�g�jzȽ
H�����<\A!�a��>ޝ��~����� X�O�~�[�^����q/(�k)�5!�3�� �l ���Y���[ȉ�B�6yZ����L�}�T_7����"YXM�Y](��5t�M�~u���ׇ�~�dc����[bx�~�vV!�t�?�I(@�������|�?/��U'͌J�qf��������lM#�A>�4?��#�T�q�~9���ҚDK���A[��e ��%�������O��7 ���摋~���-�V�췻��x���IW�Ρ��Tm�f��_h�A��~wz������i:�����̲B��٪�<�0���B����f(r)�	�&hU��i��F��l�{��?��:'�������ؖ�
��@ .҇/�L�۝�\4  �!��v\t�ට%f����ի�J�Ug���R��{6Ã�`����zw|�?[X�?Ì6�
�.��=���g-�M����	J���k��e����r���4l�������ﻃ=�3������	\1L�^Ln�F�lW�kP�@˩�]O��xԚk� 6@Q�"����+���0�ae(�@:�+�<�j	�d����<~��WO =� �d?4��SK��.&^W�5T�W�����l�폓��::��Qk2�2폌g���r[�\2��0@_(x��/.�Y�6>`,����qڂ�l8ѣ�{=3��`��a��f�L�P5:�U��׻�E^��㣿-���E@m�v��gl��Ζ����ݞޕ$�I�w�5��Sg�C@&��x4�J����e���Y��<f(�T
F7��r	4����; ����4�M��G>�u�e����	�j�7��8�n��3�)@q�[�n�?=�U�	:Z��-� �ǃ��C���� C��~�{"Ɉħ�	�oq�k.=t���+ߜ�SN���,�w�P�8:AN����;=��	j��:���V>jqtc��,6鶴���B��p	Kh(�c3٪3� *�ӧk��)�,h�Ck�	���yя#B��=$ͷt��K���nvK��'.�+f|^�w�j�q�K��0Pg����tOH_3(����~��׻�uԍJ�00�6㝛��*"��*��ַ4K��hj�|c��������qZ=U�-�'�`�3����à�<ڪ����6�A�=���󯢦�;�cL�&0�G�AR-�dF0p��q��4�%݀P"4p 5[[ݖ����%\1���m�BFAvX��R�G��Sa�Є��=T�0��I؄���r�U���vrZ',@R�<M[�3�~Ek�*�+�>s�S05�!~~د���_}�w�H� �r?�n���Y�T8X@T6�[d�Y�����Į#uSfP_�9g����A�K\��菛	ZN��N*ѧ�HhS��L��� t*Z8���|�ɟ ���f��k�TO�����9<�珓9F��]\��:8�`s�f�rB��x��N�+T��$G�\3��-�`O?���r��d�_-iR}՝�	,��ڟV3���ZB�7t�4'-������M��2��@������j%����2��Q��@Xoׂ���:��9��h4c���m��z/��{��	ji�����N��_�Y�ëCjJA�V����x顦���M��W\��
/P���e|�]�%�;��j�-��� n�q (�=�{��LDIbb
��p��+8L�{j���N{��Uz1�[:ϸ:=��\���	"�BF��h���ɠ��h����-�.h�]^g�o.�s��^��?=��/���}� `��B����	���W��^݁��Ĭ"	��	*s�h������#�-"�S@�� ���P'�N����{���@��팮m��4��Ҽ��l��*t �=A�|�Z�e|4}ʳW���֩�<��90�q�>jy5�#p�7����~�`}�z�{
�mѥ)Ο����L��G!p
��a�#@?�7���|���$*�h�XO���Ga��43X�������o_�H�.�ї����	�@��a�EX��ݝ\i�5�ct���z?�A�\�Y��Y����,��Y��&�u�	սL=o�7�F�)�w���'�}f�g��Wڨ@�h��� �L �s�C�3!E��>u�Q��@dF��	`V� tf��Ύ��p�rȸ�!�4F�T�+�J�\���G7��'�Y�=���oa����A����KH��>#�cV�Ԍ�/go u)���y��.�c��+�a���    /����a��X�$�-�Z	��I��cX�����C�Qx�b�_q���P���`���J:�I��
xh�E����z�����KY��~�2BO�.#=�Еz����5���mo��b�(鹰���A�P�6G�/���o�]r@)=�Lzd��Rrp�w`��&�I�$
��#!��Oŝ��=�c��X[���/�i(����r��Zҕ��Bs��'W��ۖ4ؕ���O���Q�`�yh O�#�a�@
_��{�{��v}8x�?B����2]6�1�����'�s�L�=���z��K�]3�3T��|�kf�#��@�j���o��ȏ
�-:=~��R%��������k�%CTw�/�<��h.$����O�$�nCC/C��-�m!b�|:��C-
64���>��c���&�i�/	>��:v�>�p���n"*cS��n^v��@��AA�f����b?���g����A��ڕ��7�o�u��5~bc�#��S�^�Ȕ��������3	��WQJ�!sZy9GW�2yl������p
D
�I�V�5��v�(>��U�M{}M6.���ƒ[����[�� �"]<�^���$��3D����Ż�E���Xi]P���#F�!}&h���׻���C��A@�.�+��e:䡬ǁ����_=dRD�`�A�8�}�#V,T�+�� ?O:w�����x�;��W�g�d��$F�(Mr��i)U�P�4њ{x _)9J�t'�썵$���Xi�?�ـ�B7��%L��^��b��+vz�y���q��}%{�]J���f��_�ϸ,��-_D�!��|�A�%m��B�WE+h�̡(��}��4ُ��`��&������>���D[����~I�rMj0�T�A�*t�����<�J�;%c\���n�����p3�5�C|�J�|&��0#�S{�G�2)��ӻLM��t��rttI�Q��E��<�
͛��=���?6؝����+_vwL�[j  �7ӓ�T��|$�M ����;K@�6e���8�Q�xQ[���N�]��&%����f�c1Q}�v	QL�D
4_t!}�?���|r��Gʙ�Uj�HۯB�n�VTE�|:�B�_0ժ�j�z:�;�bVs�E!a�`�e�Ɛ
j-��;�qgP�sO5P����1b��X胁^���{���ﯨ� ���S�"	 ���#+[u-˾��j�]o����B�X0s�'�i��7㱅�3�S�`��ӓ�S]c�)c�Z�G��R��A���Rܬ�B߁
F����CBC����A/Ag[���Z'A�l�Zp�<( �$��Vc[�OV4�t��񼪔=�7o'���|��牁�Z�3�Ct��TI���=���U� �����B�z=��0t`�P�I���{hPwL�t�($z���`�|�y��0QG�ߛ�Z��^#�S�57qe�C��j{ܯ��+�(�Ԭ��񯹾w"���D��Of�ٷ���e��׾<˟('`m�:�6ty��7'c����b���]ӵm3Mt�����_�ӣ�����~X�ƣ�S���`K&�=_[�}}=�C+y[��s��mb&�,/!kk���k��=���=�-�:P�nXo>ؕ�Y@.���h׌ׯ��(oC0�E2B ����܌_\Ǌ,�?P�o���Yj��0�\}���K�\��U |�x$A���V�;������atA����f�������LA���<���ϐ���D�7���=w���q��6�m]���2��~��فO�Y���̠l�T���`��1�+pr �Z� g�d$|��q�pz���M-�;W�C0>�b����f\*rl�*���V�#d6=�Bz�Zj��d�.��� �`�pr��R�)7�!�iΟ�-� �� zZK��Z �fҢ'�j*?m��im�7k�+`ř����܎���cnL�����7�Y���q��\(X��J��d���8l��(��83���۷t#fv���������2�S�y���S2�9�z�h=a�i�|/����;=��n5��%����~r{$�
���w��Ͽ����Z.��5�򔙋�O��[�h�iMSſ��I�����ɖϗ�3�ؤ,	������2�%�4gI(�ȃ��	�c���J͸P�lm�Q�6��B���^g�٭�@	�}\����S����tb�q�z��A�����������+����=#�U�'��j�x�l�8$ȮwGp��h�݉��>J��J�.jկ�Y��9@%C
�.m��Z(�{­f����&�F=P{n�&X�4�� ����0�Jg ��^���nݮ�f�4��F�tڌ�z �	�\*o�����]��<=���)�i�i�7��Y"�$�����2��;��#�,DLy�8�*��hX?�`U��~4#=��IG�	�����z��Z��'�wo�4�,�^��Þ��g�S �za�fQ�F�`�y�4�� *iUt���֮aR�Q�e��f>}ss�E{����"��䝉:��9�h��KK���y�r4�E<�.�,�5��8��N�LQ�˷�N��>Юi�+���gOS��~!�O�������+�ʼ;M�'���LP�*?�����ʊLu�g���Y���v�%	/�gjQ}�@ڀ��Yx"٨0��S"k�d�~!qص�� ��%`�z�d9I���|y��=�r�����D17[2N|<.�'.��Ѓp`��o�� {܍wRi�.4xP�����Uw�q0- 74�N�����ȅ>�O�q��.����i��jN�P��ђ�}�e{U�pp0N~��$�2�O�q�� ��	��������ї�}�5�i�-W,5!�4�1c���f��~�����N+���c�Rf�s��.p�Re���gPaB?o �}��ݻjivf"���-6�f(�O�C�l�p�2��%���8�4��������ė|GN��&��ϓu��E�u�JJ:��w���¿ޯ'87R{����G29������k�nZ=��L�*<�'�p�d����>���ܯo��k�P��Nߥ��Dů�q'���Ǉ:����Rvа�ޛ�tXk���e`�C�{\�O'c@fC�gM���mu�H�h8��ٖ=��ϕ�0��`s&P��Y<��g��	��M?br�ɪ ���܃O�,@d�؎�rެ-uO������)����� ��߳dI�7X��<DC9@��3��zs��td�r'X�IRF���&��|�=nRf�\�$���i;�vo��&w�W]�� \V5 ��4��c��]�X|]n��uf��jV0�d�_��;}�O6!&|���Ѷ���`a ���4:�+���/�y	g�W_ޫ��,|:��q�<��\� ���8�́	QPE;�'˾��4�Z�H�w���ks4��E��{��=��ݼ�鄮L�y�UW�5F�;�nq�6��ha�ρ�gշmA�����\��f�7��Qk���^��[��񴼟 ��@ɞ�egl�����{2s2�]h�^��9gb�C���N[pfn	��I�ʂ\���-A�w-���2@�/�s��u=],�z��h�� ���;�4[4��*EI�G_��J�m�Z��q�k���8\�D��Y�M
K��0mv�?�!Pͥ��MJ
 � ��͓mq�gv,E��6^3�!�4Fw�2�7��0�a,6'%�v�#A�δs����
+������|�d��~��bg�P�(mRT�%���-�I��
WF^޽�ɭ��2Rk���L	�Ȁ���+��s�e~�A)x9Z�G�C�ַ�&�O����f�znILNGJ.�Ζ<�F�%Ha�
uܶ���]VM�X�bˮ�d�~�a�Ĭs9G i��*e�˹d��Cެ"+s�GJ�,T>�����-=���q6ƢY�dl����P��l�@�f��T��~z2�"`s,P����[���C,-���ZJ|�a�U /v�+4r����5.#��H�    25D�vQ���Y�}���2�Zn��RYٲ,�h���P)%[՛hͩ�~#�Q�Ð���ֹ�9�,�ᆛ�fQ:�jg��<��t���Y+ЩF�iYw���m��`a��o*P[\�@�l ?a�hTy�\�LX ����n���eQQ�O\�\�TX�c�z�-��`�������i^�˥| ����� �w�7�a��*�d(<V�;��Μ9G�&�*� gfi��̙�J{l $k��8��Y���L��U[}���-U���������C�S�̷��J~�6����qUz��S���������u�,uמ%(K6��������ٍ�v?��@ٖYf4-	
-L��mX&�,{rM��A.��/�s.59 �R�~M�I�i��TXYWH){���1R��*-�(����挈�BGI��޷�l�v*�#��^12l��/=��\�큥�qwP!���@�yq���G����I#��0�#����`ep��kl�A�nd�B˿]������Wqu�G��yovǛ�'����V,R�'8)Sz�;k@`l$�d��L�lu ��o�������(l���~w�Q�h�k��Lv�ٯayT"�d�����~=��T�(;�Z�ӕ�؟��;m0`v[� rb���3������Y��V�9��=#s���XB�{����:�������0�C�Af�4G��zs��f���S������E$�q�~ġ�7s`� ��������eIy�_y�}�C�����fI�ΝX��o\v8l�xsnt-ûQ2���־Ws�����d�oQh��#��4���1��I�*��*���`�z��B�p;��2k��ufG��T��Ԉ�ͪ���:��{d	U9���_[�~Hd^��z%Y.���WĞ��e�^���,��׽"�у�C��*��@�p/��WD�LԪ��s�>60=�\0b[rpU���6?d���^O�5�u��
]K�,��p>Gv��]	��L�+�2���hn��h��.w�ߨ�<&*P8�^A鉱�E���J���!���xz��d۪ӹ/�1U⻨�d���ce#~�Y���^������l�֩��Y|-���zQO��#1��1>�g���}.���f&����:{�_������.F�����%�l��j&�?�����t��d��d|#���R� ��?��`VlS�"�6��>�V/��T)0Ł)0�׼?�Þ�Ǒ�ґ��7�+�.���s�H?�NЁ"%�>Y��J��;�PLÀ~q;���:
��t���Lp�sN�QIՃ�3���I� 0��W�2hP��KO�j����j���������b�aϢm��0w>�*
�
��oG�hP?Tv�����	���K�SE�<W���ލ&�{X2�_F����3�y�����X#�<z������Vg�:�;��0μV׵��>�6��J�R�E�dȠP=����|��2����ꎡw�`�u:\��; ���z�eNp8{=�'�wA��x��m�kĨ_��i��,V^
͢��w��G��<X�P@P{	y�y�<�B�3}��}N�`����'���2��SK��U�٨8%ס��h�v2��4��4��䵐mb���U�?-�(��-��&_���R���b���T��Q��[K�ch|�;w�Ey����?=ޝ��ќUy�/f��g�ʧ��b��$ gx���jNZ3��+�� ����fK�^���
S��!6p��R���Ak)9��E���泭��N:�R/��~�~g�/j�@b���q�>����Yi�U�7�Z��cuHP���p�n�PI��=���뽩f�u�H6��=(���~��A3I8<dV��S�c���q:st@�gZD�[�IuZ��XUY�����Ƈ�z/(ˋ�4RUm�_\��cȯWl���a_��{���*�L��n�_������L�����~R������^OKp(�W &4��{ZL&Lf�P͂�E�2��=``vO˃����0%`vKA�t����Y��Y�B3�z`�7 '�X�DEoN��[CӄU���<�@�fڐ�.��DJm��ʂhz�U�V�� (�ȎEI�Eu�Uk�>�z:ML���zh���Y%IZ^�)0����uX�����V��JV��\��'lTG(|7Kv	�^PtP�>\vf�1�r�4GV�(��T3�+���Nų��RI�VD��'���������|m6{5U�Se}��N<���=yG����+�֫�e;�Y��J�{{T�@�՝-����jpd?��XW�C��D�a�7K�V��1���Yq���М��ԍX<��h�����,�a���f.�&�g�M���ݲ�9ZR@�o|��[��)�5$Se/);��W��@,�M��ƌ�G��r���]���O����a��88VŰ��|�ή�ҲW�%U��/B�h�o�VQp �f-z�v�=i�I���3WY���(s�֘��^����Jύ� ���Z�[oaM^��f�Rm�J� V�HN e�ϙ6BD�� �eJ"n=�"�t��|��7�R��nB?tDϭ�l���G!g�Y�pd�����jD��-3�h�},z�g��i�t(�g�p�0U���bc.�ge�&K[>�����2&KG_i�m[p/�]�3=�i�I)9)��+7ޝ���Ԣ7���]9��{z��Q+��9�kO	S�]���o�%t�]��b����n}s�l͉z��H�����Fjӳ�e��Q�r$���_��E����d^cina@��r��	����oUH�=	d��7����f�t������tc�!w~;5��0z}���"�U�)o0�]~�?< ����4��x;����Fu=�g�љ$�,j��S�;�mm�tlw����~כ�m��/1��a�E��i��d6$�:�6U�D�~'���(Ji��"@�!���kGE��&�Ʒf�4��Uᅼ̢�$�/]��Xn�f�-ʷ�ͿM�����,��D�����qVE!C�Ꙑƪlu|dohe}M���ɗ��4���2c�:E@&]���<vZ6̵�d@��LN[�j�#�l,��$��L��OG;�	0=큽�ï=Q\ue&��΁A!��iiO����H���Js�L�y��X�!�+f��{�g�����S6��3�1�w֋M4W;�ҳm�Z���(L���*ǓiDF/�X5�WT�q}�3Ŗ]��6�1ߋ!��;!����`}	�RR�����v+t�I��DG�d�s*0 ����	Բsj���+�b)�Krn���'��r�LE�ٗ�pC���疛r�؛q�M#�\1�5��g��Ni��- U���Ӹt�=�EVY,��׍��s�h�T�v��W�(�E�טԶ_b��B]%HY��^��!��V+s��E�Y���dÔoO+6-"�΂����ΟN^�X��9@�=w˼|�К�h�U̩�h�ɞʅ��J��3������7���l�U�D2�q��Svn�[,��!��2آ��!U6!,ST���h6h�m��[����%�{�A�!2)Hi-:�����j�̺lQ�<�����^�&�ąG.���Aq���|?1�K0Ə�2��ѓ��eV�M 9�{���`�b�7�8�[��繇(3�2L�!1_�13�J�;���D1�L�q��.�2���낳r�<�ڌ�y��
D�a1�#�Aō�����;�]�qD�b#t��n���vڜp���T2{�>�Gm�Vf8c�����G=��b��^u �'u칁zE�v�����_;���L���j�[d㞐!b����3�)`L��ŉͬ�e�ͱ��������*��z���"`��/ӈc�,{�v���:}2kQ�� t�Ƞ�'�y�^itO��T7)�'*t^D��z�bF�2ْ&�^*�/ý�m�r&��n:0��+��Π́᧐�
`���2���a/�������׊5���}�I�M��)�g�;�����j�$P�+2,e/,z�J�$O��JE}Zv�g�����E��    �TN<��U����K4�Ⱟ��~Xtr�6~�U�Cs��J��1C`�e=BR��G���[��]/J�`A����VK���R�j�d����]�E��jQ��*h��<�'W`�г��U'r�qQ��_���*3���IA��_�@��\fR%y��;��W�F��f�c��VΑ��e�� 4�BQ��!sa˩���CS02�1B�EV�X�Pe3��EqE�u:���E/T9�d��`��v:�R/z%���nF�J�,���+
���^-�J�(z�<�m� ��ly9pj�C�׀{Eyd
�y��Vi6]s�+�����Q�8C�& bRcז9|7`!6%S�4}�}?����f/����9�&�"(��]�����~3T��E�1�Q�|�;m~���=(��E�L��ka�@e��F�;�|��I�l��a!FY�h�v���R� sX�<XA�p���u����k� :�w���W�Zt��-��� v��ѓ�
��@˲9j̓]�2ְ� @�`a� ��jsZ "��d��lx��	���e9s�Rbr.,u���4�7avjF�}5��z��X��+���Ο�/�`��T:!6�� 7��=2��=�;�wa���n_tt�#K��u#�6��ۮ��ܫ��ϝ�W�3y0��*d*`U�t��b#��ʽ?���+j���iT��wt�C�d�����BLu��%@���惲��b�{������@��87���-���]}�j%PG��G���!K�Nk��@
8쫧I�K��=)T�#�Ҍ\�k����Y���6N�N6�Ϫ�AKro<��*���x.��w�E�t�F�ot-���K/�jb%N(���?��9�׃) ��
�^�#]K�Tֱ�91|6��e��Gk��3Ș�D��$u�:*۶�K���tWCH�5ovK}'�0@H�D�02�-l���@`��i1B5�Yt��WzGxZ�K,�l`8�������m�f���a��tt[�Et�����.����-�ƕ0���oPh1ӕCZ2�M5�������nvp.�Ơ�S܋��>7廬 ݤ�}�ʵ��)�CH�²z����M{a���F�*��
Lwzc,�N�G���ifuY�qS�ze�	y>6�ij���%_i���͉�H_�>���d���c%Xi��OO����${���f�bɽ�,� ����J���{+T²ǟX�6C��")���ȶ
��lf���ۓ�(��%�Rb�~P�{�
�{�W�g�^X�����@���λul��l�E����wt���1�Ԧ�'F[[�r�B����m��␠^PƼb�>#;|�$$~특k��+�M��X��^W45�:&̹5q�#���-�x)~<mj�7Wk�U�|4�`*�Mr* Y��X��Y����� ��fgG^c�UX�P�,q�4�G��/ �.��O�^��3������mϪ=S�qkP����p١ ��"��BOBJg��� ��O�_�NE�О�������	B�$M*b��tr#�S�<z-���7
;�W)U�}7�ç�����2OD܎�<}��16*�^���eAe}1��5�{g̝�p՝�%�l�u{Y�4gx��2	�`uz1��'�*S��5��<	���q�>�^J�N��Ь3w��v͖3�g��%ͩ�-��F�8�H���	��i˚�,�#`5@6Hd� 'Uo��m->ʜF Չ�62I�RU�*�������ʻ�dP鐡tJP9�.�e�%j����0��Ej���N
[Cc��M89�U����}N�(T6�µ�yڌ�?��iV��08[ޗ���\]�$r d>2z�D�`Ū������#�rO���&KR-M?`n/�秸���EE�g����RQ�1�U����ߪk�<�
��`�A���'� ����6�9��*Y,���~7=>\��˰vv�v3y�G})�g0�yผ{6Z�d��
�6͐/]�o�t
���,	�Sa�I܁�����W��
9�L������n�{!k���:�v�{|�_�m�TF\"%zЃ4y�7)���~to>�/r�zٔ׊������6��*��7�Ј5X����O�)I����mv���1��IT6����e�\+��LEJY=J����/hE��7l��QN
�o��e�6�����m�1E
�W�XM�햰���̱��L�xX�l��/uWl��I��i����u�gHjm�p�!<Xh�j?>@i`'�l�jeԬ�sB���9}��� 8���g~�B�(�XNc�z}ѯ}̕��~�08��& ������R�s��a�����_���E�QR�HP\�I1s��8ac3}D�cc'Z7�ͬ[fC�������%��@�3��u�=[�^��Pߣ.��h7�M����g����l��������ô��lȅ��S�b�S��9��c	J�i�"k��6H�wM�ҸT�`�	6� F�5��l�Gm�US*���v<Up|�05�o�c�e�j9�uvE2e��x�LJ�[[�R�҇�N�]=.m��$钴�����zFw'�������6��B�� x��l �9('��L�~Ol��Ą�kt|��Q���:�	KPYf*���v,�"��6��~��,�D]R������
[u7GQ���5�l�O!W�v�Wݺa�=�sșyvv��?* ��/uB4{p�>@Ssi�~��;�О���ک)�h�D�]̜�5��<p޽���t�,�R�K�=���vc7�U�bhA�/=��ݞɞ���,;9���V�,���͇"�4�h�M�JˡDKt�����,Z�LF=󪩉ق�4��ڣ`���Ǧ�j jU5;U1�LO�`������ד�$�V
Hd��Ӭ���	ӁV�o��d��Z@���m�q�q�8.�Ao����z<�v/ʈ�w�_a���J���Ň�7���� _<]B��M�s0�I���}PWY���-��nu���(�SA�TW�;�z�pHW ����k^�G}`��s�`dpЈ#��@�#>��j��Yq.��o�ǋX
��t�҉p�3�e ��F,Dy;~~����R�PC�n�g@&񒁋���/qZD�7ev���.~�p|���蚯؊���o�[��;���~�$��ս�i�p����]�����7`h��'�+Sm;����8-,,`�$��|=�_ d0
	�8����,���4���x듬Ǖ�(Kz3�bs�#9��8�7�b3wW&��|W�ǡ�A�9KEcE9X	�/u�b����J�.qǬܑ��Bt��!B�I�����B���;�/��y���P�3I�e�����f� 4a��Ta��Q��D5� '�}�|��ov�ϗ��J1�j�� g�Y�7:*�ر/���LuPBp+���e���k-o�vzI�U8���\�El�F�j�������h�m	eJ
K�,磭zH#��Ώ+����XEVL���9mv�9Pm�1��Ϊ
�A*��'���R���;�o��Ք�RGF�I�K��u��ykO2' �<�I���]�'[#���4�w�QU�� ���if� ���H�3�
߬o�����*(_ٰ��x�]�}hxA���2����u��J�Ң�J����v����3���F�ae���*�����\.o	�`z]�lg�\\��v��&d�}�&���L@3x�`���c�֗��ļ^Tik'S�Ԡ���Q����̬�,�.hh�}�]�1��`JpT�狎�͟8��U?5/�'��`�}�Jg���٨�Js����؅-G��kcU���l�"��0ik���><�s�O!J��$U�H����4y3t�*L�2�c!d�d���m
���7�a�f��������d'Ȯ=s���4ƽ�}L�b��ݑ~>ي_���eyq�Sa��!|�޸�ڍ��c�\4��1{��J�gN}�묁#~������K��uq��u�2�_�	
��y���|�(�L�ҥf"�e�uq�ۀ6F��|���˞L�0aD��qw��t�C��4Yʎ�    z�da�<�-�>�y�<N.ϵC�7��䇚�|�~��������8PNF��gs��j�[*�U���^ck����t�t��G�}d,\�G���z����[�\b������w/R��3K�؇|�I)^X���A���G���~\�!�2ͼăN���j�øK�g>۹�Rfo)�.l���VJ1�������#�@�] �1������"��~]qX��J�Z��Y�t��f�����0p��7�`'��k
y̪t�b�t��Y��+��PFpPo��(�,�1W���{IK6݂Y��Z�>f��Br/ϧ���X{����ܓ�gQ����v���:��Q���$���4Zݥ�g.���M2�N��u8����	��	�[��Z�oU�0$o ���ē���r�.}��f�uj�$��܋}ʹ?COQ^;�f����=�8�����~R�;������#7�>��K��'�q"p��R`s�����`?���cs�[�eKz 3��1��5���]��KL�����)⣂�q�HH=��
J�q����z)\{�\� 5��e?�����Sü_b��a �T�̬j;�ھ?O��ϖT�˙���&pڭ����U�f��F%FNn�s��-�rx��zH�7��K��bv���C�aA�V�a�<J���(�os�,��� �[k��Y�1◺��:Pj�k ����Ϊ�����fY��Ky�r���4�hi��s��}�iz��l��.�I�*��0���;Ve�����i��I��*N��)�ₒ�L���2aa��%��[�
����ng�Ì%��Ƴ4{_��f3'���U�k�|V�$�*C�T��8w��wKm+��ܼ�k��^��XSG�RJ�����(Ez
�2wm��5��E@��&�u�Ak�.���d���Co�b�YO_��1���4�в��:�����w�a2�^|�I�,�Y�DX�F�������g�A=?��ϙ5��d���/-a�k�&����ձ?.[���,Y�l�oS�o#b߮���	���s !�@���E�y�j�22,Pwo��b
��N�yJ�l�rn��9�^���C�����AW,���n��$�U�iP]fp��]�{�Y�������L��w��KdN^�O��O}�T)�>P�*�6���Lؘ�����e_F���]��i<ʵ�`�|R�mV+�a���\w���|����#x����V���/Uݪ3���	�tv��y x�$����\b�t����z6^�Հ-�;;g�*��4�g��#&�����B�EJP۾�F��^r�٢专��QsF7/.F4�9�N�zضYtAk$�{j���߼��J��һ��]�k�AfV�}L��i�8��m.�;6�������Vs� { ��F{�����%�`� hJD�-�N�K�4k�:��Z_�JrH�N6*/�M�<�W��q��Գ��f@%��`� �h.�hv:��8.�0\����H���y�2c2��AF��;�m��`U��4?��n�h�=��P���m��i�����;!�u��4���w�م΄;�O���\3�3!�?aq��nuS�Am+�q:A)lxR��tmԴrw�:���Nre#��߃`�`�����v,��@�)��5��ڨ�LP�,���G�;3ڞ�E]��BN�fU��|7���O�Z
��Xq��Y�V�,.�W�)���au~kX����_�z*=��o������jVH%P�m������h^j���lkwQ0�ڎ��F(��EP�[���V�x�Q7���I����^;�02*�L�9q���9d: A�0�.����l���ֹךvg��)9�q-���Kl���7u��AJ��Ӥ�h^�B[�0�H��=4�k�_f;4���)���;�P��h��∦���������
����[f�&�g���+&�wo�����WN9�1��V��x��|դ3!uv�����#ΒW�Z�w���2[����̶e��H�Ϭӕ�C@/�n:�����^��|?Ώ�FD-'&E�D���Ƈ�r�2@$�����I������@A�����K�&��)�B��iJ)&aTU�3T�̆s]kϲ���񝀿;=�{�5duL�$Q�p�C�Y���{���߯'��Y'�a�A�-�a�'[��ÖZ��3��kP��BtwQ�	6l�+(��:�h����g����[6���a� Z�F��y�2C]:k2Z���	�Mv�����'}��U�~^imI�i��7*{���2#`��{O��w]Efx� ���j�����)��0���zi��m����aAB���C�R%Z��(Mϐ.�X��8���A:U3qLs8��7�� ��J+��Q���$�:-gR&��J������^ή��E`;���dd�Y�Bp���&c�gh��K����5��i?l�R=����Q� Q	���t��=>�f��ϛ�t�'ة�/#��֛�L�>�$�]�*Q�@�v�l=���7���/�8����:�e�rvI�q4�cV��d�,�����hl?��|��!�ڭeg�,R���n^D�	≮Th�v�����媁��-�߰W��XJ�~�rưq��-��}O�O@_��'��7L.��
��m��y��b}km��G��寡�8f./-/&ƨ������
���2g�`$�i=|���RǪ��xwb�L�8D�:���u.03MLvfU���~9&5W�!�ov�;+Y��j�i�W�N��~�ۦ���P�W��ǵ0��
w0}n�M��[�#(9��W�����*%|�)�A���Y{�^��o�Q�'�����W/�����O+xc����j��V[;�?�jkh��/o5Iܯ����S���M���� <���JD��y"�S6��eN��`7@��eҸ�ם1�42��"P���S�0���O���9�.�Y(4���%,�Fh$�XI���T�NE�H0�L���a�X�;��K����V��1��CfZ��^&ƾI�ѫbXez��*%Q	a�a�`�1�ZԎ=�S��o����x�!)T�g�Mcc󉋮�Ea:�w�n:@�`��'h��i7\7��$�B\G�.u�I�c�<��3���M���`%�y��zpVMdR�,��+�猉�q.��c�������QJ��$�<�D��7����Э&�)��_1����o6$_��u�n��FC���ޛko\ �I�䣢��3�#�H����$��n�3X��f#P�G�,L��3	���v{w�la��Y���+3ǸD�+T��l�c��&���梪8F����@=�OX��'3�~\o��N-r��S#�z��`�x"#X��kT]R�J�"6Ļ�-gŢϳ��I$���xG��w����,�]�\9�(I2͂�b,B��7��l>�N3\��f�	{P>����s@�h�L|��w��<������zþZ���2n�U}Z��E��_@PR���I��5y������Z���ȩK�Y�NK�mҺ�̳�0��"`b���|q��@�����9�h�*���C��H�/��:�-zFl�����i�$��!-L��O�cr�<�͞�Rz/4�͎j���]�StDf@+3��8�"4�b9stG�$�7X��Q��>�Ρ�3gf�a��kȼ!�&���5r�ش��d?��ᴊ���;A[��MIvO�c��:_�^�k�����i�q �e}H��2���������~to=J��VPCY��w���d�l(.wz�'�x�%�\VXu�JyҪ���V��!��~:K��ǫ�����N7K]>������>Cg�A.4�NS[���)���A9c��Y�1Ɉ,�lS+�d��\Dr��to X�`�~���YO6I��#G�8ޒ���Q�x?Y�¢�1�t��a��/5�t���&�".�|{:�,��_�U���T2�I�����D����G~dc��m�`���á�ݱ9h�%:u�x��y�?��Yw    �!�f�ӼO�~j�@t��y?>�SP�!b�g�YǡM͞�n�,����t�!��_-�.Ռ��#n���|�5�0:�����RX�;m��;�(���;(�)u�%��o덋�극ʕ�4K��}\����	�~ ��z�p)��8dm�2�g�I�d��:Gb�;}�F'��X#(EP���Ǖ�����`�,C�l{��ykc�Q��_���Π�8|��m���/��2^o��5~`���T�%$k�׸����ݓ�UpG8;tZ��t1���*-�U\�Ԟ����t-�v-cp�˞9 �k�B�0�z�
��$8�O�Ƞ_^� �$Js���%2�����@�!�0�˲����:�����J7�]��}�]��?�Ș�Q�Ub��S2^��lA�N���Y��2����R�el��{�p<k�5���a�e7�S[hZ����G��1x�0��<��ל]c�!;�-�N�/~��8�T��Nt(Dl��Ssz�>�f�R�n�E��xUc��)Y��&~ܝ����M��#�EtY`3�cZ��hq��`��g3�Y�/���DB��ĸ�L���e���Ϡ�)��bu�0�LE����ǒȎ��F-�'�d`ڰ�%x5��qRҟ��TI�� a�,B����r�":�Q���A됳zG������9� �Dk�{U���J�D�ƌTf��UY�-��I�5l}ؑT�ӫ��(d{N�:�C�Θ�^�-�l}��0��7�m|���_o�ZR�9��I�9�h0,���16�"()Z�dFxf8�0q ǜl����0%-���xZ��|�ֹYx�wO�1;R��FS?�N��C�4=������v�o�Z>&)��s`UB�hY�8D�@�i1Ю�ꚟNC0�{ �Z��x�����]Rc� �lZHP�.1MV����3�=ϝ�:� j��]w��F-L����h����O{0�i����~�n�Q]:N�s�q�G��{���~���|��>��2�&�Ԏ�I�t1h�!��T�g���N�Rlخ�@�o�!�yP��g�ӄfOq��4��z�Τ&�so���x��݉F�52
x��,���y)�/%8#������	A%A��4'r��~}vLt�"��H_?}�+�N���>R����7���#3��;����3�p��e� 7�z�9! �#(�|����``���A�l��4�%U�s�����0g2�fŞ�IO����ǹ���ۡ��C�j:Yϰ�۠�=� r�E�Y�k���J~!An��j�T��k�
.쁎W��_�����rAo���3� {�O�{4u�����Ҫ����K��@��ֲ����<o�	��Գ'L4֏
Ґ�?�:T�Y[���I�X(��6Vw\t,'���Gky�T�S�
oF}�?����5ɖ�p��9Y$�$贈/���Af�kOu`J��H 63�{l q���]ȴ��8���|Qȗ���{����,S?b� 9h���)Κ�m�[�#� �4�2y�'=0	��kF���csE�\�Wۇ�9K�"dZ��aa���?��z>�3�RU�Oc/G�r��}�� bo�Wj�vW���	mL��:7���~`�r�ȤtU��Uh�D$��lU�l�BN��9�&+���xLe��Nå��Rͅ�\osK�%�Zs3�ё�Y��i!�y����P֭�M@C�N��=	���B��Xt�f��~�;��\`�&�j���;*��c���j}w�8��(�Q�'	�JZ�[�3��7�rL�Z�u<���ŀ�� �����^*���^���dw�5DFe-&X<`�����.��
h�Wu���3�e���Av���6�Q�O�\���!��0��1��e�e���j�ũ)�!4�N��r�/�s��W�?���v��4�^��ڼאR����΁)�����Η�%Y�<����l�k��S���?��'�:'Kd;#�]˹-�]�˩Ŗǅp�U��>��b��i�����lC&�1�z�٨����1mv�A�,q�<���4FOR⏨}!�F��%j��!kƧ��w�P�˄-6G�`�t�U��E5��)2vM� `��z��>���,��}p�R}���8[5��̨w��H5�(&�;#H���V����d� 8g�R�A38'x	��X�BX7P��2+��Mz.���O_FQ�,0I�*����֌�ҷ@�{i�^s�F�h �ra�,}����2��0L�*���ʘj��k����e��1�=��r�~=�AƊ#�����|:ֶ0X�E�%�F��L[��.p����M�OeqӒޮO����$���03�޶��s��h��.��0��xMr?:𤡷F�m_XQ�.Ü��Y�O�O�3�G����E���a�Ū�x�~ڝ�z�8��@o�5��k�36C��`mgt��5efeY��5�1+����(h2��h�{S5%�z��8ᷤ]�,��{�A|�:Uq�=0_8k����G ���Ff����ɛ*�G<P�d�D�A�MnC�f6���X��i
/�<��IMt�s��Ŝ�0�zş�Z�\{V��#�M(X�Uzэ��Y0�Ӆ^[Q��Q~=$	���*�4����z+��W���~�:_���
y�f쪙�#�J���Ο�ڇ�vD�
��,O�Ӈzw�f��4K~�[ִ�b��߼�u�$0~�4���;�y@��)b���>-{��'�Iɹ����:��%ΰb���2o���NX�.��0~Z?�S*�]�Rm�\)��^�A?��9�A��]�2�@�}�)[�y��Ѧ�j�B��`'ΠRz�e�ٺ欽o_f�Z{��t��;sTJz'��Jk�r�cH���<��CB�ʑu	VZ�����N���6�*�/9X�L�[i;�|9A������;6���0Wz{�����u�^��Ҭ�7��6x��u�^ٲQ.�=��� y�Br�h�("uu�s'�s�;���~��y���V�xxGY�}dڒ��ݱ�`�s���;g�X��B���sˀ�Se:���5���]y�����&����-zqfe���t�[Υ�u�����fu�t�ɠ���4�h���;����>�(�P%�7�J��ˡ��>�~�xZs��V��b��7�CCTE ��n�֢s�h�V�X�%W�դ���[��=ޤ-��iv���Ѹ�Y�!�ʱ�n����&8g�cWlޑꦙ�Bpt}H\r�So5�0=�����1�S�����Ec�5�B?`5 �$���*��O��_�h�Z)8ߜ\B�n:�C��V�츝}!
?_#�,�(;�za1`TJCB���:�#�]j�a������#�$½�A�+s�{�����(��I��D��w�xx�И5�^����K�d���cQ�P)��c ��ziiU���H�݅R�~�f"�$ił�d�>ΐ�R�.�O��OX��[�����}�s�d�P�g����G��h���a۹��pμť���d_{��u��ؙ��g�2��B�'�Qn��M���ibdA���b���Y��?3Cjy�}�:�U���-��Դ����o�Å�niF�!�λ�]f�q���"i\�y���O�m�0(�7Y�E���ċ��5y�or�u#��j��yg<ߡ�u�H,O�&�ۑ�%�Z{�a�y`JE ����0���6z�Jk�b`�~�㠔t��q���)J_�x�����T�3�%�[q�B	yp�5�L�Ļ��d�I4����_4�`~C�|>��Z�E�aP��~���1-avF������tjE�6+Q�i�Y�JHN$�mZ���k�p���4l���}a�����n ��3��L}c��O�D=3�C��Ģ��翫e�n���������]����p�7�����6�@�9�j+��MΦ�N��ѻW ���=�����kR߲� D�^���2�~�^���{1!)��a��9	�$����Ď�u��0�T �~��x��DW�����_Q�����?Ψ��0����B�VBf�ǗE`�4Y0��XU���>
��~<��N��������/��~V�$���9
r��&�-e;S�^��A���\j�����I��<���`�:�]z�Ƥ    ���i1�����$�vPd6[�^�ZM�u������zxq��y�)�m�[�0l��f5�ğ650����"�	��q54���Z�`vf��W쁦_��`������N�U��8 u{r���5
�@.�Y��M�V�<;-b/0�y?�!���p��Q�V��۟'Qs��hij����������CY��4.�[4Ts�g�5fQ>��uL�\!Yiq�᪜1O�5g�eK���Nz6��-e���u7g�e(�"��������޴�:+T̞�@?�<w@�B	�^���i�_&��T��f�����-�{M�s2'/-@�lq��$f�̾��~iz�ٯKo�Ͽ�5�)��"S$�<�>�&�NK�|���ޝ�i�"){u�C�'<�k�"��e^va�I m��t��Q��^7���Ԗ�x�߮$LՏ��/����Q���b�֏�Π�T��&c��(��UZ���-۩�؎`��,�,���;��/�~t����e��ſht,���7,�@��Xe�<����4[��
wX��wuba̱5��� ��1�u?���i���ގG;��������sL�cmN���v��p;�st���c��^;.�'tv�\�Yx;�=�W�&"�<.B��2츷��q�Nc�į��kF>���g2
����뜏�'�#��C��|��w��"����`��^�
r�-���oY���2�8��: �`;���u�`�W|�5�u3'�m��ŌZ��00��	�=O
b����F��Y`$b@l�o̞��r��һ�Ex7��;v�3�Z�G�[��&{�������_�c��^]?�;�s�_�=�6��p�|�������9��Q����:4ow��w�HE�����[�߂ջ����RF�!෻����O9Ye�`�z�Q������L|B����C�-}N�/���6�s ���<�i=׽h���}	T]�����^�`dgHN����`�J"�w;Y6�L�ϣ�؂C��Go���3~סn0���I��%���6\�?ن@o4���U��R�ê�?�ͽV=Y��*,���-4�`�1�<�L��J�[/�nV�f�֘��g�]�I�u�1�SpֽLC��{D��.�:YR���z"Y�$(�)�l�#t?��d�Y�d=Ѱ�b��-�̚���c9"����Oʘ��"��M����.ゃp�qW�Y�'�<[B��٭�������KZ}���@���Be����f?AD�˒|~���7��JB�ҫ&
,��E�p $A���MP�5�`�D8ി�{�����S'H���M��7�Ƌ`�xڷ!�2�a����DUC���3��kķ�uﮚe�;x8V"��86!��^����;����s�6k�Cp:L���`�2����$��_��[�
�m`�무QVs|6 Zz�a�-(��6��Á��#�<L��<p�YӜ_�=X��n(�D�6,��Z&Z��Sl��m$��ISmè'L���H���SB5l��`�EㅫeAZ�Nڏs&͒���������X>�]��mD3>����OJd�bj#׆C�8܉��eo���<�9a�wT(��T��sq���)���e/�T���)$���^լ)��5��v橃�d9�aط� #ԚN�c8s;g�j�/ ���ՃY��� LE�P����F����G�J���n���l��q'�qtq��k�n��+��(=n��+�u���1� ,�FʷW�����Z�o�FP�E�Q���ځ����<r���ֺ���ʪ��K�A�$�9a��p/��V���;ؿ[m�����8(	8�nh=�	��G ��긞�6B�C�=6��{�_�&�#�+{�E��'���,`�9w۬W�̆Y��Mm��L�����'�*� %`�x�R����MGVg.;���,�S����j��yIJ�᛽�w��}�$N!��~��:ȫ�	�xc�Z���L��]�n8���2����M�x���%(����S4��]߈jî��^c�n[�/9�A|�m�ڌ�N8�!"P��R��iû� ��&���7��
��&�˱~Z?�D�8&�mߨ���J��G
BT����FS�g|��Ye}��0بW�|uP�[���T��TsM��I�Q�ī���R�4���B�iH1��2�LF�-��N�C��Ռ ��v�j���O�F���^M�x�Ft�� ���}'���WQe�5cc����6©��0�Z���E������s=b���M�}��"�_Z<� v�[�a�z.����J��^l�M<�~�u�~�X ��Y���v�9VA�Ӭ�[NlG)��P�����yk�ހc������O��?:U�������n��*,H���}p ��-(ڿ1���6ofdO�G�fr���b&�ۻ땝\~���ƧG['�y��q�/��3�����BH��8kY6��e>K���S��l�:�#�Ó�M�Fk=�Ԧ��L�����J\A���܁#�骸��E�f1���&~�Ոf��%	�sRk�� �E��)B�)���J*��M��,�d���,,�"Y�S]]�Ŵ�k�r����2zB�bu�I�������M���x �&��%ӣ`bp�,�&����jfv/�{Gj�4?� �a�,L�jJv�w�g���a�3�B�Xp�]O>�)���H?:?��ar0�^��bB�_9��v���e憎����[ﬡ���E��J�~����:�'=�}o���<52���@Jw������D��B5��-�T�[�^�d��VM�]p�7� nhS�`r�+yRM�n�˴��Z��^H h%��� �%[3j@�o�1-�	�pr�c�#l�;��������KP� \�1��TLZC�4�&~��Q��+\ F�) �-�M����.9%=i�f� ��Mv��#����(�r��B-f��M5�M�ϭ�BF������Kt���䭵���/��[���6��%4�q�0��5�ҾN�*�=T�%����#��Oj3VB�X`J��'<�j�fw��P�^��͆�S�ٖ�96�߉8N�p��� �+DA����}��PӗKn01�*���r���l�}���kJ�R4.�׼[E|Uȟ	?]���H2Uw��#~�l�U#m�L����b��ϡ���X���F7EZ3�[��hB��~JD�6�ᠰD6)�ƑH'�=��t�[,��A, �������%�:&fT���qg�\�vO�Y�x���� �o��T������nU��`E�8;>�@����v���B)��>�$3���=����Ex/��lↃr3�ۂ�-C����a�M��~����s��I��O�;���fS6zRwz3D�&���_�Ww.[��<�����f�8([W��IWI��m�Rh'���WJ���������۝k3a���Mdp�G3}���S*�Ш|zii�}�[#3����#�t#��b���q�vF�9�I���\q�5$X;��Y�i��w�!��������zߌ�Rx[;W���p�R5.�BDZ��t���Z`Y������t��]�\G0
o		.�SD�R��Y��=�g���6E�=�c�V��ኳr�{�	~����o2�ނI=�ь���ZT�%��{ݓ���c��N�dE�B��4,����ں�Fk([v�]���#ihc=(/юU;l��f�Y;�v��yg����^�w3��I��p���I}y)L�ٯﰺ�c����KDYڶ�����[��3SG�V_���ZKD�q,A��k���y@t~T)����=.���@�u[�"�a�R�'��x�N0�k8E7��A���B����D����Y"����1��i-����!��m7B���!��0���S;fo���w�AH�po��"KQ���̧���Zv�Ƽi���X�Z/v�G ��\9�R��1]��Z��ʋ)0��~>�;:k{%BL������
T�=+S���2�:X&��>�v/5�0#j�sk�-�d��i������S�3cN x��Z|�����zA+�V���Q�]$�    ]��N5��H�ʽD�%��%S��ƃ����|~�eM��U*.�k�C��6�v��h%���m��L���l`��$74��:��t��u��n���cn�S�5�p���Mrp��!�-�~ie����N	�mo�yF��)�

���{!�c�h�� Ɇ��dh��� ���]��o��*Y
|�UTa��>z�p_�����-=<5��HJЙ�؍n�J;�N:�l�!�J?xN���v���(G����VR~�m<ǌ�2�0��������ƴ��V�� PD�A���/ޣH�&�� `� m��z�P,%n�}� �Or����h[��Z���%�U�=�E�8����H( i{��(lB0�X�a`����\���d	��9��v��v '͵k��v��#�ۓہ�5�-X�6��C�[pX%����6s���f��vw�v^�ޅ��&Ձ��F?�2Y$�bp[Ur���Cqw��#�Wud��	�J�%��v0D��ԅft��Z�Yc�-0�J<�&:���.�CK�Ts�(��h�b1C�B���{�:Q`��X��!�Q����ɳٺb��õ����ή�����3&=���/�**��k� �K�Ό�y��ٵ$�a8	l�@�	��n�C gl)F�p=���$Z��H�q���_g�r&���G��%��U�0���[��a�\�c6�G���j�%�����Ɋ����ߛQ}�/�H��B$��x"�OS�*s��~u��+�zc�3�lz獾&�m&�4d�� ��J�Iz��ٛ���+<��
J��!�ۈ/��)P�;�_T'`�t�C����s�l���@ȟOq&8��J�B~b��z�	@�N���^	��I.���pE�����h?%Y��M�q�"�}޲.׻�η��%z_�eQ9P�`��3�QQ�WKM���1$��{o�A �7}���.vX*a���iK�����"T>a)����8�l��5
ހ�$�gq��uV .x��O�����Ѝ%��n~�!�WT���o>T N	w�Q�s�V�����[݄�n6�M���c]�0d��a��n����V��]�UNi��t� �2V��
�x�/8�ڌ�?�
ʎJٵ��:ۘv1�I2��� ���j�.�%)k	�mr���K	�E�Ӕ�;�.
�IR&E8مk^t�y��g[�9��|���(�v����iܧ0C�.:���Y���)ⴋx�jq*qE������D�\W=/df���[�M��Rl<���\$m�I��\�9���6�jU�ӣ�����Q�2e�í4���~u��Y�l�B��<Q0�����=� ��:�j�U��>�}P�}� ɛju5�I^'2������N��J�Fxw��S��(zے]�� �W��"yX��2_/>l^��� �ֽ3�6]I��-���^=�]���!��F�Hvѫ8���A)�E·vN�/!zU�!a��z`;�H��k��\.����K L�H�!��َ �\|]�⇖R,����ob�	�1��ʇC��Sx<zo�6`m�Ǯ��%`q�qy�zm'���Tb�lNB6�����o��fjW�R#E�{����+^����Z���j]`7B�w�� ����@�U�ZG�s]���=�Ѕc!yO�~����y/��،.�9k]-�g�-�=��n+�o/� �o���S�ú���N"��Y���]����E�pP�J�-�H�	f5�Ɖ���-�ŕ�om)�>�.�
`�1�v�ޟ�������ၐ�D�*D��d�� �kX	-#���>�S���Q2= �V�	��C̱�����<��'��NH�'�˖��6&��W'yYS�:��GuU+Z�B�������2}����ֿC�9�B���:Ȓs��0?��XWsb�.��ɺ=�!���&�c1A�g�J�'C�����:'1[P��)76��� ��EqK�f.�(�6<A�j��5? ̚��T��L��%�o{�R�i,?q�����5C.v���.�����6�~~ ޕ��u���0\�U�K�вP ��'��.��vN����T��^���=�5��F��o�$S����� ��c�D�9I�!��N�(��F�X�PB�<q9��tb�`BL�{�[� $ɚ��7�~�[4�#��E�������Z�m��5έ�f}�H��/]_vd��M��yr�"sW��rq��?WT���i�':��f�R��fH}�m.pR��=U��ftʲ�x������u6��I��B��u�پŁ�a�H�S���w�Q�^w�������Az�8���pPm��r�j�37;c����X��֫[���M��y����:sM��Hh��z�zLӇ��S��x5�?o�S}Ԓ�,e{���۵�M�n�g�3��?ظ<��^�@���3�%S�77՗���.���$l/�#[\�s�W�o�[�ٟ��D[� �}�3cp�jS�͞�$'b ��?��֠U?@Ie�k���pv���= ������EV.����ُ�V�y����<����3�X� �������ߡ��f|�&��r�(I�B�7(����o_�I8#����zm���@�90�ZS��~�1���h'ҏI�B�u�L���>���~��Q;��9����z�zX����}�M
�p׫ZĒ���(d��yX+�Z	B�����y_����0H��Ѭ!Y��~)H�N���ʲ�Y�oM��Ǌ�`�{���)��?��5C�F>CH���}n��0�a�VZu�W�����WR���=(3q����7߉&l�{LD�&j��~/�D#ץU��UCUKa��`�� �q:?�JU�9���<�a�ޔ�-��ux4r�g�C3��g����=y2��D 7��Orإ��g�W�͑S�L��i�<�D�c>ս��
����<6J�$~�~݆Гos��{`���a��VS�h�� 2\���G�V����g����j|[��~Zm뼇�j��Bn��V���.z�1��t�y��K����Q�,$�����^��EӼ�B���3k%��9\�q��4 |}��FG�7O�����Y������񦖔۬��'��h�fr�·%�V�{�����K�� #�:����|�Ď�̩��,��c��.7�t=�T1d=����O}T_N!����՛�-�z�s��q+�h�cM	����\����C'�F�]�s>H~����k�,rMW�\�-[V[�$�ͅgc������,���%�m�A L�{��Lx=�ɑk�t�{J��^�TZg����nBoD6���#�n�A��-N�\x,f#X?��~HN���6;F���s
�ʦM-���Y?fg���F�mcU-���@24�KJ'"���OT��'as)t{�Gڪ���x��O��������k����[ v�6��j��g4_o��|�V$i��9�x*�u;����ZEӣ���"<�4>�_�A�`��ɟ���vq�R�q����tl�"H�>��\��TX�6����QLo ^���
�8d�)f[�MB-�/[f�˿��w{��Rs�A'���T�&@��Y�.�otQk��$���3��I��*� w�s~��Od��Dۛ�{�	Qj�����LM^�Fg\���V�/;�X���)�������&���t/8�"��g=��=�<�Ϙ��귨@:Ѵ���aC�ăm[E���1`��U�d�����mEh ���e�, R����;�Y)K!sZ?�K֖��Vj�@�;fP���� ;�l���cE��0lpލ�7xU�@K@e�O�.=���".��s�uEm^���W�U�=C�е��\m����9��m�
�陸��)��«� �S��=e����d/`�J�W��L�ޓ?�.~0�G�|�W��)s55�IX&������/{:�}���M,���/��˼V���D���������������U.P�����a&ߊBVT�( �\�lwg�� �[O�;Ό�V*b�魢�z�O;?�/:v��Ym�[��we�����Q%H|��-�[k���'����˳n�<�q3���պ    ��,���+9{�k0�K֡����B�lX�S�YLj��W8�/ɇ��T�R�و�_P4�r��L �ٗ̷\��<��!�<��r��_�Bbz���7��[�.��0�&-�ɋA����c�3���}8����X���<��<��|���EO�L���|�G��F�D�U%�1�.���=uf�5���j�5����{��WM�ϸ|N�t��/�ޤ>4��2�'/��;p"��}�V��%�;��Q[�ҡ��(����ꛪ}W*A@6+��A���ϝ qZ�$�}�8s�sН��`N�$���|�6�6��ӜOPjm����p����3-���8<�Į��`��kH���9�w�YeQ��*jw?�,N�BL�v������ah*��O����a���+���;���;���_	�}u�8=T��{:K_vv�.����jn��va�A�[����ޛ��6T�_���p$ԫ������S?*Bt:"%gz~�'�j���و� b�3s2�BG]�D}��f��9xT�T�����=�nk�|�����aZ	ʡ��j,"���:L5�~�y��uf=�Ha�TF�hi���4b��`��{կ�Jn �N���qe4Mo)�4����O��M�L[j�ԔI�'�0�x��}x�7���J��l�[k��,K� ���ܿ���>�1�qyՍL8Ti!���%��U��Z��ŻF.�?��m��2�	��^|�wS"%"DI�#gi7���d���6�{�D{c���.J���qn+ܧ���uu9��Y�CliS��K���]�v5>Ds�=�C���{�Y�x���ճ����FG������6�#Z'ct��beƇb1�T1SwJ�\=�]+L�[̊kR|o�~��� �����F�GJNM*U�8�r-���:�=t"���UC*��z	<	��UM|%���d���{8^�k6��k�|�%o��H������?M�G�0�O� �^^r�Ĝ�ڋ������}]V�Fk�N6@{"��Ji`V��wW�
!W*U�ശ� Z�2�,��SM.->��l~�����Ǹ��c
��iW�մ��	L%�\iI:E���!���5YT�s.��(��+{)}��jܞ���S�1�vG|X��$�R�b��抭�x�P�Z������%e�R��5��?D{�iOD0�l>l�_N�Z���/+6���7χ�ٳȉ��韇��v�	F02iЋۯUw"h�T�	�e�m��>��\����������V��0��m��!���*���c��n'x�d��:�.Mj[3�EB-���?.)3����߀�w��~?	�R@$��$�p��\� �fE���̬�%����CE�6�
����}���^��&�%t|��kLjT�2q+?�d�;<�FC��C�ǂ�v�,Y<���+�g�� ���p�Z��-�қ���>H��`?���Ӳ��H����
*�5ke��Ɋ���j�2%�ۑ�,�x{uܛQ�3�]�0±6�;���møj{~�B�%��+*Ü-�B��ov�?�7�2���'tAed�_����{���8��:e��p@���L�Wcb���rg�)��gXo�R8d�x�k��r����X�g~���	 ��cn/U[PUY��n����H*�y�O�$�T�������)3�����e
��O$p�MG�Й��;"��!{1=s+?�U�#�Rp��4�����&J��&�|�VWj�Y[\5`\é}S�L��(Y<c]$PIX�����g����~>�R�+{`�ɳ�}@j�#$q���-	����sC��V����A �T�zm��T��V"�;���XQ��I�ܝxu��o�u��O���L��,
Pw��34y 9�(o���Ӵ7�Ց,��� b���ց���τ�"�ad�ޮO��v�-���+�/+���4Bl��Mѯm���JY7��WK�4Q- ��+7�QxA�LH��"<Hx ������i}�40-�pB��o�^$>��)�����P��_���q�^q� .7����	�rm��v���3�@o�/T+���-b�Y\H�*�*�����7'��=$�����8�Z�O��	�M9G	e�/,�n��B�7�$��$�Ə�p��?����������J@D��T�f׷��	* 1"�eikc)�^�;�ǧ�%��?� @Ĥ��}�`Ҵ!�m�� �X��5�hp䉮�-�� ��x1���d�G�d����@�i����l[�LG ��X�ӯF��m[�v�n[��M��z��cP�	D�F�����m�>�8ea�z���TD��&*M��v�ښ���(��_ov�O�w*0~N
=�k{����rl,���/��cXK�)���g�Y�:��f{�S�b�������o�Sr�q��y)UH���[�]@�'R����%��?ys�/6)y�ZPa�������ڸ�K���6���}\=E;+��u�7��]������y_t&��v��������k@Fr�̇"0�e� a��}���iw��A3�����Q��'W��B�7�
Ŵ]��죃G�(���~��viz8�<���P 6�Ti<��>�=H����깞�������D8��H)� US�`����`���p[��M���A� ~��X� KF�p1��N4�s�~g�� ����q%Z"w獮t��1�Pr�9Rl���@iX�^ĵ�gb*4��o)aT-��j-���S����d3Q�u��(��>P ��>
^٢ZezH��٫#+���4��#}ʨ$[��b-�k)@���K�\�� q���?�q3�`���eIV3��d5�6LAMo�'�}e���%�u�o,�ּ����(�|��C�S�+D�w�.]l+��o�3�5jRJy��q����1?��m�&���.�����׽��*����S$�Z+�)�b	�1�d?ml���d���=l.mA֬��&<E.?����ANV&��<�7���~����<�������ё�^����ٖ�L���~�,Ur}�~��+��m�aS�C�$a�%fX�8���s��$,���h�g)�y�H�I�g�$t�$E?�|�3�>��N���4ГK�:����W�
�N�M}_h��_�ZҤl�!D �l ��_�#��Ԓ⭜�jڣ~lR������X<*�*8<�t`
���Z?��A��dx! �Y�hX^�eG�Q�XY�O��k�H��zD0�>9t��^EG}<�z�6�h�<`���^���@H��X��{�{9NL���>簇�����vY���-��x���Ļ����;��3v���v��u���2س�n��D�!^��s:X���l�9b��wb�At�UB��M"(���K����I����`{�>Y��v�R.����2�85�1H=�#�޿�R��9윉gP`֣���2&����/h��ŠO�Y��W���K���Z�&�c��}L�_�sv�͠��v���.	23�uz���O�5�}���}O�v+�g6=v����O��]Y �:FT!q�Q�B��fr�4��5�PJ�RVE���̤����g�ۻ����k��m��h�4���G�!	�����ΔU��8=\>���^��)���?75���SԍJ��EA>|#���?�	b�o k��qZ�@ �ѿ37�7mFV�9��wj^/�����ٻxn�2�a_o�&�(]���ha�5�皦�!���
�A�ظw�ž��x�ZWXN�-�S@���0Uw��|�����?�쌊��Gtv#gom�w����u"wRz�RE�u�:z�åT<���Wl7�O:�g/2f�\)��7gѨ��� ���Q`Ox'�D���i�����Mm��4�Hf~�������'>32��4S�{1�Y��sZ�/�N8vQΈ�8Es��8ع�o'��&�E0�$Q�6�B�����qI	�E����� ����'���isH�	b��_ʾ'��M�n�cx���OKXO�ޅ��ʈv,�Ӽ�
��[v��Ǉ    �t[O��֯� ���.Obu����:�����&�T�mE�H���ѳ!v4;e=;M��:e��/�-��3;Z�;#�?M9=��4�zA�vd}3�$9���ช1�K�r���h�#����t��Q8~��^��k=��S��p:-���>c���le��9�W>�]�f۽��N|����Z7���z�`����rM���~�lN903ޭ� �������8��z��~��	
�8�9'�'a����Qup�e�]��U�!���49�F�E/��	�@z��2f�Z뇋�	J�����~��l��ى��/���>�gc�׫�Q�t*8���|Q`����s�$��BO��z�&}�_�c�T��D����4�ҋ������.��Ϟ�	����mԌ>��Lza*�E���T�g�Y���"�|��yZ���3Fצ��]����]70��d-�'��E�:ν0��NV!�����&��|3�myK���������J^;K�f*��=����v'��~���Ŋ�U�%��zv7.�e1���k�G�?zP�m��ݜ��@6��T/i��T绰�Q0Sy���k[O��i�T�H5qӵ���dhC{cF!���r0���Aw���qA?��I^��N�S"��4����t+�e�i�F�q%bQ�C������ީǨʤr�\9w�Պ����Og�PS�z.���u��
?W��ij�u��#>�}2C�A� �Ǩ�5#�pwu�3����hY����w���t�!c���v�^O��Cg�,���'_���Tc#�ǝ�|�<TFuЗ<y���Â����Z��8|8���d�xȳX���|�V���m��""����m[l�h���A����\��BMa�#2�{�i�+w����w[#7��zB��oU?��m�?��Z�w��#�O�T̠u�/EE���*7����	gP��q��M9g����^l�8pY�z��Zz��̱�fU�i�o�{m��m�6X�f� cP܁�`�T��o>�n�P��땓�5ۂ�Nr���mr����qd��Q'�ř�5�4��^lvv{�'%�4$r[����Wc`�8���ݒD���O}v*����V�r�x���	��F=�8�N�:�j��#�1���5��v{$������PL����7
�EL8��5�!���S��T�.�O�d`�n5�1�n񧧿�?o��/�>�p���(�]O���Yx�_Qv�����P�R��"kU�X����~�'��l/�4��(�BG���}�d�B^�王�W��E���0�R��X*�-@���X�V/:�l9��x4Qƪ����N����p��U�%ц��s	��J��H�ש���J؋��k�[��bQL����ˉP�Ԗ����c�g�y�"Y�V�{�`/������H���-x��c3�L��(�X�N�X�3fuW9qа��Y6�m����:�ht�c2��X�S~��(kka�G��	�F/IT%����y�hO$�Eog�W+���>$e���j!H�3T�����O|�+����`�`{{4��[4������&@��N8���W3�v�+;�L�n�8�i��O]�����U��ӕ4nf���x72%~��t`L�Y�;EX5-��n$y0
AEQ^�ݢa��4!G�r���j�9V�@҃^�%��A��ԫ)��qRw~��c|����^�"��j��Xқ�\����{L����|�[Su�!"���U�|#��Җ7f/|�)� ��%�퉰3�FS�]����j
�w�mK����k, ��J�x+遼n:pj$�b^��ʤ���ɾſ�/�-�
I_���E�7�)fG��?[^��ώfz���t[��b
��X��.����$>۫�F^d s̖N��d(���R�?BQ<�TAI���~�̯���]3f��Qg�h�q��~�4
m��wMR�?Ƿ������r�KJgd��tR^���ÅQ�X��ە.�W������Ҳ�,�`��	Y�_�3.g޶���v�d�<� �,D�#�zg~6�IXW�&<�v�Q�}p�㶪�$��^�}��#�v3BnV=7����#��*�����tXBu#
�)��<!��7h�z�;�r�{��]��_2��T&=#/��B��)�l�u���N�V
4;�0x{8��R�}l0��h�R��ci�L	�:=��u��������sw]�Vf&	ڃ�۝�~۴C[A]�J��њ��-�(�ǽ6��5�ZFob�5{~$�J��F@��HG �E>g��K`�#����Mo�%x��s=��k�-Ŏ��ʏ�h�1C�'� �N�����Lf��?1+q-x(����I��i�J��R1n�5�v�$��:G��h�V�%��p��`�aք����>ͳ�� ȷ"' i�X��.{4�#"V�K����KQ��Qg+�P�g�ucq_����0�N��L�B(\Y�&}��m � �ԍ�������B�׆m�$��,vW�\���3ٽ�)PB�]��Xy$QŦ�tU������R�54��KIJ��5�벰;$ $ꚋ�%�$�����j�������U=��Â�Z��4�$u;�=,F��Е��6�5h/�V>>9��.�������p��3@��.���˾�!�=$Dk��څS/;�	����7ծJ��nCn�h��M��2N6���V��*%:v��ݧ��R+ Mmς�@�I���e�FB K�7춢����m���B����+�}�s?	�,�lvԏ7�%\T��{B�ǲ~ֱ�j��)8� 	}��_��M�H'��F`�̎����3�And[�v ��f/�?��q�?��,���J�$�@\�F�D�]<
xr�D��I�RvIqÜ�3��:"�R{N�ڥ^��C�<[ϪT$�����O�悢�b����լt5�=�[�>~��vH��l�pa+,�+<��:I����6Ytg�$��A�ǉG��:��AB��<���x`��H:تl�������*��~Y�J!�\V�ő����}	tq�%}��Iv��T6~��A��j�@��7����ۧ�o�_N�+z#�Q���S�t�Z����걗 g����)�D��G�6A>�4��?�!�=��L!�Vk.��oEz�p�\�Gu/k��V���& þ /h��Q�������6����DN� ������X;%���u�y72%-���o��Ѱ�`iײRw-ډ��5�;�ꍼtv�}��.��@�ZVM۹~һo����e��L ��=���]lN�%Q��˨��	t�̬[f�/ơ�����_�C!0��m�q��B?��匽���O�o���W�J,Y?9��)�8�#=
��7������ĚP��V���2,�k��P��rxSu+v��d�6e*�)����F�n�����Ƈup��dLHd����&Β̹ڳ����t�܆�ͦ�Q&����۞��XM��#���I-�8e�����ur�]���';�>rE�UZu>���x���+�S;y�j��fۃ�A�@m8��f�F�gV�;0ʫ��o������:*����t���8�_^�讦�j;}�`]���\I���=��Ss,�V��-��k ��ӵ����@�'���p�f�
*���ŅF�5;�~o�H�&��"��{H��!}nZ�4�d�Y��J�+Xh_\b+�V"8@M��T�X�%c����}؆G�o[��#��۟�Z;ʨ����W����\�i�7��LnB����h�������	t*V����C"ˬ�K���i�����]X�0p��
"r���H�G�wg��X}x}o�Ek�߯��9t�a�A"��/�qZJu�.H���̀R��$o���YN#���0*Z�Wj�߬� ���;}���r�U�f�ە��G=P���J7�9�FJ��D�Im�`W�y>$�%�0o�Or��<ҢU��^�#��N�3g(��I�1ٔ���nrw�1{�F���B�����r�n�C_�7�<N	�<�C�dK��3���<'p�];J����*�#�    p8QO���);Rs�AىhGZQ�)�[����(��mzjC���(��ˈ�\O�WZU�M>NI�J�Z�)�#^Ǔ�~ጜ|y1�ﬧ�m>��&q2��A�����WZ`�����f%��_�O8��z�먵j*�M����;[�F�;���t��Ώ�kfZ��/l��ӿ$:� b�*�f�ָ����N�A{~�8/�Li��\��E� #״��<��%{��	�_��r�Do�@ga�`ǀ}j�[R����m�I�v[���[�%��+� x���R��g)q�ٶ�t�]E`�� O���yS��W.G
�]w�Z�/�¹F�����R,_�T��Lݗ��î����i�+��_ƳM*1�e����u=U��ko��+dZ��Z[sG�0�|�l5�����j YU@��Ð��|@�n��>�A�Ɲ�v.Jfs�?���7vA��5B%^�����ԇ��[��9�+;���k=a�i����6 _�����v�[.ǄQ��X\{c(TlvH����JPd�mXX?$��h�y�W�_�l/��{�ǃG(���s �븰M�b%�7�����w@����θ+I��QO�oM��u�c!$ב��Go��Ւ���l��7>j(�G��چ����گ*:��)�n��{�&�F��˷E��t��x �,{���u���{=)q����R�$��q%�����.�w���?(�S�4���Awz��6ls�B�j6��|s��HRZ�C��2�Ƹ`;�pv�\�i{{;}����Y��PGR�{���� 5-t@0�U+��i}8:Ruu?؜�������^n�ۧ_o&��ĥ�v#LV!������+���ÿ��Պc|�5ݴ~=tTb9�c���۬N2����Н䋿~q��]�n&L֏�]��oV�+���gj c>)u�_ 6�sx?@'�u�A|���\�@�wrc�<;T�{��A��mYֳ��~%�ԍC7y�\�m͐�ƀD��gOTh5M�t�ҏ5���X�� ������$?����k<m3̬N�m��CF#�cV����Q�IUd���M��C�iM��&E��>�3���NVVTw�5{��Δ��a�_PU�"����wf.�S�ǂ>䔿u��u�$��t��h�����ή��յ$�YO��3d	�,.]s���p{vy_]J�~3S8�驫��|��ZZ::G�զ�~���.>�Q]:���կ��Qlz�:�foT�5����h�XbE�9�gY�Mҋ�>LD��u:_�])N�ٻph��Pi����9���%��&�!!&��7�sVߘ�dI��]��Q��ل�c��ҙH�Q�������E'���7�9(guv�ߧ�C�Vy��!�Ĝ|i�4b�D��	�ɹ'j!�� f�{�iuu���TL��]`8ޜ@�F����o����խ�v�rmڀ�k.���#��I_�+�%�K��AɿL����p���o�n.���c���٪�A�c��!��f�K��s��>�$������A�,�:���L!lt�L ��w�x���=t�D�q��@��}����	u7�9�D�p�]���m<=�bE*Y6�/><��q��J������L
b
�5��T�T�H�J�W��0�>�O��_�X�ߛ�_��H��a	�@�*��i~�F޽4����	���$g���i�s��[BČ�n�<�'ks�[�'�O4�Y�^������X�l}�\W�$V����Nh�K�g��n@i8��oNMg�O^l��1����h�H�7ӈ�m��=qy=��ύ0�V[��Cu�"`�0}[}���ZMeO����X�1J����<N��QΠ�#�$���5�<��ٝ(�܉�$�xx�h� >�mU���6��H9�^���H�l����O�xʭ��C�<�M��y��D�y�S\�:��&cq�,I^y�e�F	��Uŕ���9���BɢdH�P���l�\��K(v�Q��YMn�qY�`UJ��\_on�pJ�Ӻ��v��{PY��աi�I{�	~W���\jև ��GT�7QS�0�T�B�Uי{q��wz�9��C�;�]mu?��Hxfr��m��y��}��S�
c+��J�S�6�Q��£��'�q���뺳[��i:E(��(\N���Boj�l|�^��T�&��!��ѝ�9v�+�@���w�G���ob��`Ѐ5�8[=;��,��rd�?>��frſoݽd���6)�ֽ�W̺~)�E����q�d��w6�.��ܓ��S�#�H8X������ז���}�7*�[Vײℍ�D��G|���c{��t�n���]���`�T��E�Ȫ�I��5~�]VAEy~�fW�Z�&��T�DQ�������MN4|1��.j"%��dȬ�'���0�֑�Z"ƹ����e��N�>��o7�{���P��Yɥ�0�+S�&�a�EId)>��~5�?X�uL"����M8SZx3�8�\�,?>�* Ҥ��n:�W��n1:��������@�"/�	�q�RL��ju!2j���n��*�.E�5�ڠ@�"�:iDt���O���w�@������ӻB5�C�a4�x�X�a��Ch�G�����a���w�4Ⴡ�U\�'�9����
sR���{7�JD�:P���V���Q  ����w����YbΝsPc�m��]P@���(�>� ��8��8Fs܄M� `0z��Ě�$�J�V0������H�"�����'�Q��4��&��wu�������ds_|�����J���Ζ�ŊGf�z���KA��(�ޝ$�zE~�9����X	���Ijz^��
P��AI66������y!�Һ�� �,�N�"��4���py1�A�,�$�p��?�K4��۬7�Pp��o��p�$6���vT.��[#�֚�9�V������ƆA�4wp��\��Z��/��@���1B�� &#�s�W�^ݢ�H�Mt8��;��y�}�(�e��N°??o��5h�`�)�Ձ4X��#�\�@=�˰��MB�BЇ��%�,���Y�'��B̏�d��������ڶLL�(�J�E�v�6�R���z���x��f�bM�ָ&��t�Z���e�6�6�M���3\2ᛵH�>���vc��C� <$q`лaV<��@�">�+o�;�x�� l����ד����"����J�ր-Mf`|u|��1�|Ds�-D����Z)���]HN ���v��ʇ4Ő.���(D�h�^ڂ�-��+����L>�X���}n�Ch�� ӭ��k�K��
u��*�Ps̼�\!؉o��n�+}���ɰ���oͼQ�.��n�8#� l��6@�-���<�I �g CvFd\+ F���P�1�dP64����r7�D�=&�o���	��] �i���6�+�1��z"t>}7dnp\���Ba|2��
{�xzY�7�U����}��{U�ʦ�9����-�JDQa������m������H��]�t�*4��č����c38�;\*s`�x9c�R�׋"�,�R'�(C�&f�K�x�~lg`Xj�j�2-�l@��udbzrIa�^���_G`FG�������Y9Ɠ:c�M����$�,��<�eo�EI������<*X=��𭊣D����ى�@G�A}䉹�b��1/ R� �z|;���W?nN9�6�I���e/��)�vK.�W��|A�ĭ1�~��uy,uK��[ ���PP��1{��{-�LD���N?]�$u�	'Ѝ?���,�jk4F���if�yA��>q�x������.~���d�Q��A&/�*�\<�ǮU=	Y����K��n�ҋ�ܰ*�@*�BR`�ʕ�h�Ûy�'�%6(�X���U$�9t�~�@� Q�[Uz*�9�p���?�Z�IF��iF�&�������h_�uΩ2E���*ʫ6�����J/ه7���.�h�7,x�[��̧_��v�K 2M�x,��C�pBZ�k���/��w�D{s    E$e���~z0c���� �ĨD��e���2���ۡ��j�:xt��B���΃g������Ue��i<�`J�X�=��� :��dH�Z��?Ys-��7	��?~���bed��Y>�#�����`�2����˽#� y��@���L��,Yꦎ�.wp�U����'k���{ƍ�[E����q	�d�$�;��wk=X�ǒ�Zw������o�N)*���r7���2�AT���c�[��[���4І�<���[}��W*�x�8��?m�R�G��Z�W������8D�O7����u�R,��Fzl|�� Hr��|Y���$Q*���z�e4�ٙ.�"|���m��:�$�_b~���T<K���n�v���@����~H���f�c��됅d����1�#����t���*FEj�~q�Ji�hTbu��B�*�y�58
�Ԡ/)<�u�L��1K�K���kL)����{��&��a�0�LBw5ٮ'u@H~λ��� Wof �{���������8�V���J���i���V�v�i���߲�V����+������n� ��n{���1y����&�X`�%�(u����N�k�0js��� -���T}��!u�G�e��+����"/��I`�H��轷��R�54R5W5!*d�H5�F5�Gߨ̔�7|���w>']rX�Y��~,=5z�G~ܬ�����c��>=�􋽚g?�:� ّ���2��`F�qY�^�����҄��(�&K��Kɨ��
%��}l�[J��.Y��j����l�5+M���>G��*W$|f-	����6?K)M�z��2�s�sQ@�Z4��L�n��Sk�VZv�����q؟gy')������SgX��峕��y���S�k���Ą�9e�7�긎q�Z�J|�F�^ω�a���L�ʱ��3|
݄�<~���!��Gcj�A(t�7+K�R�����!��`�G�N0}�svL�쨒�3�<�*ދ�>'�>OzXAVt~�z�N�䳶�����r��g�i��eL/Q���qE�	;5T$E�77��C-E��H�Xk�*Y�l��z��ق:��z��ڼ[2���\����B�Wwo{�ե2����g��Øl}򮭋�#�T#:98���3[�i�����c^�63�?��ƚ�B���2Q�{ӛu�t�O�@�@KZ��95�ͻu��5x�l�����)r���i`������^:��$o�_��H���f$��J19��cB�#V�h�+yY�=/�4aR����=�� )�:�hw�x$I_�#0�09�/��
6%�v{��]��ݒ6�����G���>u4ra�r�kɘ�z�v���#�����*�C�&�V�;3���p;�f-��u� g~�y���$�v���Q*i!x�O��[���;6$*�u�87����T�t؈���x�BF�b�*�&J_�Jb,�YI��-�Wq���q쩳qןw�fa/����?6���X�˝�T�_6�l���->A���70���F�a���vwSS�	��n��i���©�s)+mZQ>G/@��?�';��Ƨ����V������`���"��f���I�و�!(�K都���;YN����4ˊ�'ѷT�H5����p�����4Ҍ�aS����4�I!Sp$�K~d�<k}5�*�(�4y;�?;4��@H1�QZUV��'�A��εY)P�.�N�_�j��1D�̠��ajN�ߙ� a@ë���ǥF`�q1��ʍ���Hz��x�r�����~��N�����۵-��*Q��	�N1�V������Zm�Q�� �_g���%�/>��G�Fd���f ;żQ��%#)�nJߨ�0�J�qPR�H9�HT�c��j�/hϑ��ϴziP�]��|eJ��U2����>�W�0$r�*1/~� @OB�
�kH&�=�[��:����.��뚦*�R���n?�O9J�K8�k��:n��Y�X���vD�#�qz9N���Ԭ�����J1��.^r�,��Z�ʲLG�y.+���/��Ů@��N�b�?;�[:�q�j=ؚ�$jcL}�$�ҋ������ܯ�T�HU�$ć�L��Tڄ�|r����RBno2�>�Hڕ����	��@�J��f�8�ެ�d��L���8�q�Fpb.��Չ�,-U0�	�[ӈ�$�4�����/:u�	�����*����j�{�*�������G�<w&{K79��a5��n�]f�r���ӮY}���&�r��CP7~�͝��	�zsI�>1X������w����_9�geu�}}��Vx�l9�6�!��֤���m��:��u"AQ����x����~��JN�c�z,�<�#
��
�tRĲ��^.�
BZc"��i
)r��J��6q`B1���'�	��a����b����M�+�#�|� ]��^�1~2����[)�9�͟j��d��dI#5 �٩��g�	�p$�9��mw��V�g�� ������� ��b1'�ި�u���0�J98��Z��$v�p����f?9_��ȇ�`�{�����g.ק�XX^�\��ޫ�&�pR	��rP�S]���䨖�5���ث=�uV2���"��>?hC��斥��+�JJf��_4.�����[�W砑�5�����ލ�YKH��
�����ͪi;��ZO�E]�g�M:��*+";sq]ޒ;'ZP�H/e��t8D4L�Y�b�_X�O�S�a�8<�'�!T�HG��ԓ�Չ�`3?�*%e���#�=߮��{2?��3{ăxZ׻�{:��eF���'�l=D���q(b�9fs	�/[�Δl���}2:_����v�:YS
E�~S�O�?��rŷ^	��4un��Vv�<��"6�����=��\+���'x����<ݾ��M�<,���WG�-������������wh�g �Vvg$�x'�Y�R��v���xW��������xb�u�ε"v��g{���zv��<]F�n�w?+��zM-ߨ؋((&}����0ж�> � 5�W�����J
����.��c���3��X�j���N����TE#&��U���d�����,��� �dk�������8
��8bpa*B���c�vc-*h���7{�b38�IFk���	�������z�-���N�Y�*b$T�m���Z��?���l���2qe���BI<���/�ݜ����r�����?���/��=:h��T��U��´��x��'A�	fI�� �;Y�iy��H��K������zw1�[4��G����~��0�|S��sa/�����]�)�K�݁p��濜C�pYа6�g�?�/K�B�xg�mw�֫�9���b,f1ny�R�p��j�;���Eo�~�����@ߪ1���f�F�t9�z�J�	�t9���G.�ɶ.� HU��=������Nc�ֽ?�M��[cj�`Z�i�O����W/u���� f5B�
zF�4–zWϰg�4L�I9��V�$�h�C�������SWR��"dT�3v�u9ة��9�g=�n���v��	��O��Y�<��H%EKk��N�RA�x�~HS5MaW��vKq�� ����YK��Hi��H7�@��("�Z��r0��Ƀ�r��d{
��/����JF��FW��j�L�Ht���f&{Qo�u:��s�|:�����	��cU� �(��������Oң�a��ӈ�}��-��Fj��U�/t:��,�1�����
NR���'\Kj��Zg2�b��JT]��ٻ�V���$�jO\�NZR{�(,��+S���K�W���a�;q���r6���>�G�,j����}1w�����͎B%@+��gy׸�PR/�f�=*S/��#�7G�Q����y���X�LnQ�����m����{��ҩ�6��ۏ'�-H� |�����~�{���zL�h�[�h��W*��`��&q�����
�Q�����|��E^��v    �Z	KT�x�%%���v ���O{?�Z����nc7�����-fK���o�H~Z��1k��ݮfOtv�wR�I�JR/9�IҐ��	,�>�cv�T�$Tb�$�h�^�gm����1e/�y>C������:��3��Q���������ЉqY(�v�?��J�ht9�XQ����1��Q4(E��p�q_��\�l�nQ��o?�a|�)ns��c1,�dv:g�=���F�ނ�A+�F��yJ�\��[�<pm��U=�:t�5�ڟf��9fMذp�7]�;mw����8��5����O_�Dk����ËQm$*$Y�O�ɻ�j�	x��/p:7驪���H�ť��pНXf"�����ܛ��)Ի�~��<��.�h~���߯>����{#ϤF��ϳEpjj���������¶ç _�����cK�ʫ4�Ţ���e �/��؇�Id�_�7�x��Rc�ކ(��
 :�]��t��J	_͐4ݰT	� d��2۰ދ�yY��R����)P�n�Ҽ��O������c��0O4B�S�~5���������{jU/��!�7�#�f3D�z���E"��ӣ�� :�R���״�s	�(��R^tp����+z�f"0if�Tj��q��Im1��v�*ޅ��"'��T5l�~w|�����F�X�X'V�#��1���y	�z�s7r�bTrsk����lQ���حV���{���T"�N�_bBs��>&���tt�wnM{�BX��R�����'�r*��@�m�z�74OW�����vs�6��kn��t�Qb��.�7�x����Ӂ��xʏ�R�����ޛɲ�z�Rm�����H{����5N�^�!���LM�0z��m�=�js8��׵7P��b�ba��0����>U"ORV��5���?���S��}�:�BtP^e����d���������wB���7u�Wk���NUӜ3�0�5U�նiܧэb]z5z�����#�>�������l�ks�K�˂��:��O�;K�qҦ�pu��*)�؁̚��i&�jUlXi��6�x�"RV��
�tkuu2O�Up?��x}s�v���]0��K��aKQ.�
��q{�X\��F`^drV�oQ��UV�6|+0.P�\��p"_W�f�(��dX�b�$;�,ms,����d��8r'�p����\E}��'ݎ2��#/�xT��d�_�ˬ,,"7��9CL)�7�BڥJ�1��3�<�0�Wj�O��Y��}}���/�(�O*Ĳ�����Vf����yws�J�h�x>�Ɲ���q!�e��|-&�;}�V��@jt+`'ʋ��ahE�H��Z��]��s}�J7*�`z�*��<�Q����}�ց,:�ߝ ��:���T�y�_�)K���3Y��g�R=V؇L�|ĽϗJ���� ��/�>e����\���O�]�GQڪ4����[��'�E�������Z�R���f��CXCzɖ<��C�nu^8���HȎaq�5w�c�s��d�����F�g�^�N�^��W�G�}�Xx�Ց�A��Z>�.�⇅��0��	7��u*�LV���7��~w��k���${Q�b,����k�/_M�c��6:�j@�\W� pïi� ��]BBDw�A��|)�,h"�E���	�~	8��s�������%ӈ��ssR��	���MI�	|��v���ˏ�8Sg��ٍtaOc�~��S��3yI���jw7gkPP;���"�k���;h�d�
.�p��>�1���
vB;:~RO��F7:v�Hg�Wt��l]y��G�Ih\�SI��>:�N�Q0j��)w��8�1l߬>�<�]P�3��y���'� 1�Z��������8�������M�{�WZ�n��Y��7qr�}�'_�v]/%;,���&ΕNȶ&T$�E��*=�Щxj�ƈB��q8t����L���]0�ۚ�\V�D+�=h�i}l^F^ETK��C'�\�#��T2�ũ[%�����c��� �x�'�#�Z�"<~��q�����(���)����z��ȱS��f��,ݎ.�)"�JY�s���"��X�:uD��7+��X,�hHm�b�~��s�q�e������u9�<*[:�E����f���Q�� ��V��	��Ii=��Ph��E�z�TMk%�cMZ��|�����x1�?*����&xj"�@@��,=1��ӐjҁMJ���DR�%���ς�� h�RKM�ΓM��f�A',~M��+�t�{��|��lLwR&����7�1�D���5���]�
�u4�A֨�1���f�y<��9���;�]�k=R�~I�!�ӷr��^�W%ƸQ��-�~�[�6
!G�
Y*��ߪ� 5�(5�Q����3�NۄJp�/�F�"�z���{�4�����7�)g;;�3ɦ��4*����?	х� ��N�ݡi�Z�*Xy���jB̟�ď�E��ۖ��L��\>N�
�(���@��oI�|��l�h�q�l�>:Y��oa}����*��y��]��@K�� Z
 �l�!?롾B_�p�>��x����/�Y'E���Z����rZ��:��hnꓠU�t�[�~z%>��)���Z�W-�d() ��>��ﰜU���	Z�u����:�h3=��T����;<�vqm���� �ȸ�.�n�s9�����)(���h�Qu&�45��ۿ<���)�-���;�M[l C��6⛻�̗�~�}�`}��FHw$����8&)��]������S�;��J�;�u��D�t���C�3�o��j���%R�6S_�T6� �%��oI�[i�����0&)���[}0���n���?�_$+�@o��G�W�O� ���z0���ƅ}�)��8�ܽ?Q2;��W.�L�}�qz_���5�Sf|�60�)3ba�R�h���)gx�l	�@n��J?r�0oo��g1�`[�NBi�����R�Rl� ������b/�g����~���7�]�Q\ I����'{�V��a��Y*������+|ٟ����Wm��ۨ+XG�w���7���̄��f������C@1�����!��yGR\�cY�eM(��0�fz�AE���
 �f�\z��rf�o��6��|��{X��p�.J*��f�yԦ��M<RבF?�� O!�f�Pj�+s~�b�`7������Qb�WDޔ�X!c(�&;:��? n�W�]��(i3��S�sL.0�U�>�Q㥧}ۯ/~�.ʒm�{�w�.����%�s}����yZ�� ��z{{U?ڍ߲$9���tU� ���a��۫i��C Js/"Л�^�禱 ��e�P>P=�ta�IQ���z�F����.��X*�ʎ�Bp��S Ξ���x����	���p[�Zv�)p���H�� ��ɚ�R7s�I�;v���X<���K8��e��� ]D����P�3�ܱ%���2C��~���9�d�%��C��"��
��L}	&�UfȄ��T�6��S�����:�F{%Jz�'E�Y��7����*����`�^٬����4Y��&;���Ļ:�L4Bv�	�C�j	�I������8���O
t)�P֦�m‚���h����Bm1>��u��k�tj�T�C���r��ё\��#1	V��2~��\U3�����r�aN�8]j�2{GB��J��!�1<Lmۊ:�����_���ג���b";�i4կ���q
낧�;��^�׉4��u\J:��V1�d�g�B��D���	�HƲoS���.�4/Ϙ|��1��I���ʤ`J<��((����%��(6^�l���~=�\0V/ �E���\١���	��GV��AфCώ �C����Cn��1�}(2���+�Wɥj�f��B3����T�1�r� �m�Ok�r�?��ǅ�I�_�|�%�����zk��G����g9��J�\��/ Z���GĒ��#ʊR5�U�vW� �`r�H(��[�ݝ���	��bLm�U��h�������K#ɨ*z��H�����    ��q}��r(1�:Q�ܭg��l�6���vM�D`��`s���l��Y��|�|?�}��ќ<�	����n��S��Y&s�wנ���(M����_GDuY������6.�o�9Ϸ	��1���:M�������M6�[���V��Y@���ޙ:۹aԕ��bbDx��p�"��M��{�W��t�"�aUv;_
���a�3�?گ?��%�Ϙ�/�s��8"�Q:NE�4�o����=ҢH���ۺ�r�`��Z���G>�F%���U�z}����܄X���V�ZM�\t�;�F.��G]���dY�&vӞ��������7s�cvJ?1�|�+<�*��"x+:er5�RQԾ<Ll뛳	�R��?	��ͳ�žhn�.؄��p��%��˥��5=~A��o;�A�d��+-�>X��U�{l!:�1��oA��Y�ɛ�1Ŗ�0��Xw}:����l��Ŏ��~s�/��\�����m�	�"�t̢�_݇+�E�ʜ|�ە�ڶ+�m%'��]t��K2��Tn`��`�n��b�R�Z%����Sc��>M��m�/2Q��7��\�˸d#��� ��0�@�{to�B</Q_�绣�C_���V��!�	x��[�K� D�a��kiԬ\�'��u�Y���l;���|�H>i��q���IX��i�C��+�h&��ĝ^�wq�Ͳ�j����Q���$�M��qa˕��$�������e�f|5��f���>[��%�B�����>l�B��@�w�����|�pd�t��NהD�W��RQۘۇ9�	N g��F���.BPdQ(`j|��t*��ʋ���c<^i��8�������b���B�X�o_��:0�+� ��,u�C��66�}����r{l�n�`�N��]�k�a�+��\(��."�£�D�S
�t��.'��S�X�ߺ�4�R�*ѽo��uF��n73 5�or�V��k��Y*�c��"0�E���L���v-,Z����)��x�~u�9��Ɩ��Mo�a�"5�1Dv�w-�^4U�C�rA�1{｀�؅����(g�1���y�	�T*={�y-��ط��խ��6>+���6k��뻝�n�u�����G��}0\��6����eM�c�o��'�`��Q�f�I~z�8_���$/Y�0�H
ٮ�������?�~SK�D�Q�������բ	���7 �1fq�pN�Ń�t��L{�ݥ&��g]�f����Ġ|��u�mЃ![ؿt�����?�E��N|�
�¡��Sm�`ڥ��pW+�0�i?�9�逗5F�.��q0�ڕ����{)�;���A82}]�B�_ȦF�Bȫ^�1,�w_��k��^F�~��٠uf��U�~�z������H����.���˕�	'���2����I��M�1���K7��B8͕�O1��'�����]�9�7��x&E�5�з��g|,�Sb3~�B:�E�ag�����.ff�V�y���$��rt�)����*�v���/f���>˃��)#V���_���ҠTZhLMڝ{oË/q�i�4��md:�J�c�o0���&�^��2E	��c���c����<��_
6F�-f�s#s��=ѲN�3��Q��݊Z�:�
?��3�_�L����H�@�H�8��§�	�����Z�SH"� aR*��ũ��̬W� ���)X���l�~;p��{��$��Am����jw4�I��Q�AY&����]���&�H������D+c'�^���@�M�	z���NZ1���&Q���:�b@a1�Lw��;i����)�����9m� ��o�ov[��.W`�c���U��Ј�I�Ko����0N��P�^}�"�<;�����#cｼ���ꩭ�Byz���%�ϒ^�f|w�R�����2=�vfi��7��M���fw/)W�#P9T��\i,l�j�ۈ�W��~l�#�&T >�Z�մ�������;��R
���9'�$�������y9�MU�.�-X;T�^�'4� U�P��匾�>������h��gj�-�[��ӑ�zjߛ�-j�Q�+E���Ӈ|���V�|u�dk��#�Œ��>�8?O!�A�?I73���z����"�4!Z����Ҙj��M�̥����HtL:$�B��Իc#�n��p�n���)��)���诠&Gɰn��>�;�x��%�T΂��|�n��Sl �|�D�Ğ��ۢ���6Q�EwZ;����}�)�S���E�<�JH�R	&hl�YGQ�Fl��Η�:��.a�!����n�2��cwKq�����ZzE�q3�����N\q$��7�?�ae/��͹jݩ�ު�,��f��Θ�Hl��@�H6]�O*����F���^-%;|�m3�־�� ��������TB�y��M5ȋ�M��YX.�h���4-�2ef�߮_�Hn�"������m��wǤ?Q���	���0�M���@k�&/��O�~�Ǚ�����; w-u���!����T!��m��fݒ���*��G�{�-�q�����5E������ ´Q)��C�7��4����/e_�[��v�#�Q��w9�=�2s�E�e��zzU��֡�a�u�2�SԮI���6�Or�L�a���r�R�:�G��[� ��9M���W?�z$��)gW�ǆ�فvF����[�Y�|����D�/�����KO���Yן�]�W�R��cV�;��x�|՟7��݀����}YT��7=CF����x�a�Tk�\L�{�\Ǚ�	�޴�J����j��Ao�q��9-� �y����S�2J5����q2�,e��>���s���d�WB3E)X�F�;{U��Uf��OX�ɫ�(YwW�޺C+)�ɼk��T�_�:I}���e��9_Z�]���v^���(e��aw��.luPU
r���"GMP�Z�D�L;��W_��cXSE�uKn3BO��ǆuw�r�N*S �K��C��M��6����7[�UM�`�9x^�����L|��s��|�WO�����DƇ�!��l)��-:�Ö���,�>Q);Z	��/�
�$���*�e�8��?�Xd��} #C� �It����~>qs���⤑,\��r�L�Ĥ[��_7{�yn$;̹	��N�s�AG�\o��ª��6��E�Ec:����pUUB�����(/d�ۦ�Š[��`�Ɠc�t�=���2�J��ĉ�u^�e>�J��6������!�rl*��-�ثO�/�Ď3��$�q�Uk�����_���m����6J�����E���t���D���0�D��`*�\J�0���^MxF�I�>��7���~2 �Px�f� )�y[�v��Ιؐ��X�;r��R�1/���;�lL�eoVW�=����f�\�B���v�eC(���S��.��%�[�\�5�Y���_U�rH~*8/�����T7g���w�,}������wb�U����\�#M�H�jMJv�M�$4?���$���]���W_��k�%��T��f!*oc@ڿ.V��������UF��7����&�a.�R�I�oՁ�Y;�[2���3[Ђ~+�FN!Y��U?��~���W��ޑ�݋Z^{�+��7w�N�r�!��������K�n�RA��)��47��b�m栩o����1������[Y�R%��t"��j&��b�H4-������"+*Ö`��m�䎥 ��*ʓ^6�Ƈ㉝�|�*��PW�~',��;��@��~� 6\3��5X�2�#H�^�8.9yc2qRVEĪ�3"�:�!���#7��BL�w���m�:��1Rٷ��?��_Y�P�607 ����`k�"!fof�C�,�AsB�A��]��)�h[�_�1s���=Mabٿ^��[��V������i���z�YKҿ^Ž������	r�������Kj)������ f:���Z�3�������f^#�3jv�͌}�ٮ��&�LI;�)F@��f1eU���<v=��D�    �V���C5���DۼY�����A�l�ɉ�+�j.���4ى;xwO��E-��A*���|H��A����Y��_��P����כ��_��)K|�R�\q����I!�]�<>����ᢾ�����hN,�a_tn	`0��x�T�oH��4���<�-`ں�@��YA� Y����C޿��{��$�f�Q@ϼ���]��U��O���
u���h���ؔ��V�Ks�֗l)���$�-�ަ��~�ٓ[�P+!|>r7���-D�������}s�n��T\>�=�a�H֗�4M(���98�} �g���((:u�G�ŌIμ�6͗1��WK���҈��r���Ȯ86�qq�j:6z��+�_�����Z�R��EdKa"����@��ï:b�nw��񭷒�6���q�I�ʸT�Ƣ�������B_b�Gh	��
�Ȯ�c��{x���GD}#P�	�x����O��l�����=�������H�����xa���f8\�Lc�=`��Fʨ�Z�W����_ɣ��~廦�δ����[���893�2|*�h��@��c;�}���Þ��P�#&5��WL���W��r��Gqx�^�B�˪��-.�"\,�Γ����ݗ0����F@�#�$�g�N=WӛR���׷�%��`\)"�@�b~)>gτ+D��G�# ��V`�`ﯨ|H�Ed�.h��}}�)�+X�;�j���=�F�4s�"���6�̡�Y��Zbe�eP��*�:�뇠�WU��zs�?)��`z:׉ŀ�`��'�2�I��\��-���5��Y����T���k.׍�l���Uw�T�.a h�臘�`�
�G�װD&�O\��v!��@/yh |x�U�H����M��� U�Ck�YB����Au�Y��H�ro 4�2t� 7�|�����=����6���,�B�~���7d��yr��y]� ?ks������6k{]��Gr�~RE�
��(w���y�rr�l���� .��w���/�[�A-��f���l{�	ؕQ��-��8�m�^���❓����v8v��8j��rv5ZX���[k���@<ٸ���'��e��
ph��`Gަ���w>�%̛3��偱�\9��`�G]��ӳo���^[�f���m7��a��P�?�遰�c������VjW|�ףjD����q��5e�\mB<Ɇ����_ow_$�l_B�a�c<TbT��d�ǈ��QB�ƾ,����FߵH�Œ���N%�<�FX�g�z7�o�w�D��3�~�U�4�p�x{��rFhr�cg�*�E���G�u��v�$���P�P<�gz�"eB��@�#�7�C��R-2A����.���mg����K�V���8�J��LUU�i��/��x�sa?��4Eڞ챊�%��;l�st�Јb���ltқ�3ĵ���@
��rl1 6y������ʾ�ͺT��F�L󱣭v(P������Z˽����#ܤ�-v?�"���|}����AI� ����1R��f�fu��#�M!�	 ��M(����`�f�����Y�3[?a�s�(2����D��2
�v�c���|?�c�el�:��N�0�S�E99=�j�񏋭���}r�^�<�R c�iC_k��k������4z�yo�$|:�g�_��w�0�ӓ\j���+�Ul�2����d�/u=Ѹ��C��d�c�<��>�����d-�S;����S/tM��l�k
� &�a�uj𙞰N{юJ~���~��tj���6�b��/W�0����$Bt��n����Cj	�'��Z���U	� �vf�>�cR�<g�!��/T+Q�G �?�����,jng� ���W\tELUq��*H��zƯ7q��$|� !�֧�3y��B�
q�g\�Y8��Iy��.hE��}]mcs��s��\m�Kis��_͵��FDr��Y���\�+����E�3�yT�a;�T�e�H���&g�轖�̂ż��CTJ��k�"���[�r8��?�d��O�n�PKA�M*հ�S���w�7t�����wc{j�!r��(��ˏ�m��MMG)Z�h�bS�Y���КB'��& �0�5UkZ���$X�s�R�t�kH���ֶ� �!�c�S4*���T��N�Q����D_)u�B�~j��Y<,���+��x��fx��T�T��A�,ׁ��o�6�N5̮ښ��(Ϫb�z��]�-��L�1�(��]�wC�������v;W.玓�)�l��e��ԅ39F���	�,�K�����ʬ�ZB���Mhr3����K�rz�t��!M;�.��,�p�8���51���Q��6x��'	,@S�	]=!{l�F50P�­�~w�o��$,��J��]s`ņ�h^�?��+HR�����<��S�
r�v������a8��m�*ӸN_׎QjՓ<�QI�ҳy@�/��Au�J�MW㿏�iq*�?U�&ucy�``�I���\RG�qA1��ч=��׭��A�N����qѧ赅	�kH�;�&�bbp�bZ����u��U��ϫ��-q5I��'w7cl־��/��6���n.愎T}���K�ݡ��eP�쓄oY𒒀��Ȗ���Y���/5��װ�f!<v�Zڀ��)�&��oɈx������9�(���<�Hw��6Y������K.��0[W���ND~D6S�c{�W.)�SyA��|w_uA˹ �y�c"8�9QǤ� |ǋ�;���{���z�N|����j�(%�(5/O�C��X���Ŝ5�j~����b�������Ŧ	�vPGT�����&�Pd}M^y9ڻr��q#R&l���"��Iq��^����.��)��RG^�n��_:2MO	\��wM9�.�����\O���%�
ńC\z�8n	EIDsW�Pﴟ��@�NM��Z!�j��L�ѽ�E~\��l������&�!Ѿz��/��Ů��Pl�>l�����҅��u*�=�[6\�[�c��7���wB%�u"T(�-�=ґH��¼�iw҉�5l�6����a�Pt7�M��% ����M� �̰=�  G@6u�؎�ǌ�?�y`C���_<1|ق�C��%��v'�9ÜYJ���/��[򘢂y&W�h�߉��JbI��s���A���W�����L��_e]<�bEz���QQ�Mڊ���'(	����A�(��y�yuV~U��M2K�k5�i	����ys~t<����hC�-A<^m~۸EE�
��}#�Ol$�Q���{�>�w�=HD�h�,��K'����@�Mk�X)� "����D�ş9���"�+�ۯu��jG�W���Q��*���9�;'Y!���	�k��X��Y�o>�9'�$AM��0}؝����(x�l�������HH,��6ߤrl2��;��6�IzԏU�G0����x~�4�4�N6i�_;_K�7�<h�/a�
�1�A�����YH�s�DHZ1�
��5�QA����W16�7���8�.]�I��tn��->�fK�2����̅�z�f�,1���e����̅��b�@��l΋��v|��|�G蒯�%H>]r�m�G�f`���ͱ��hqQ<;p�¿�0sRSjQ����Q�K�ݳ����.b�����~a)�Q��˽���iX�K��ǈz�	��h�L��r�/> �y,�(K��S�г�g�����qT�CSL������Z��D9����*�-�� �%��C�0r~$ӵ�p4!��i�N�X��W��E
�  �֐BcL�;0y������%�p����'��%�FOPj�����1vp�엔c��ƩͶ�#���*g�j���&{X�{@P�KՍ¸%;�.l�hQ��o}e�:~���\�k?�nLR�u],�%��������Y�)���D^���vE�K��k�<��ֻ��n�������08�p��/£`����w���N�3�C�G��K��Bԃ&��'�lO��=�U�z��e����\xv&*@ao��ʟ������    R��f�H�� �E�5��|:;��搶�|Pi���W�p��KBq�N�]d�)��O+�֏���z��%3Sz�~��3!%�z�5������������>
o���]�+�YKÞ��	8�#�����*b+d![����Bj�U4u@K�A����+��/�Z�G}�[2`_L�B�)��|$�����0�{]r*|�(�;�:S�|�tգ+1�B$Y��F[2��FArX��p�.���҂M"�r��>?.+��HNQ>�p��Zy�m�5
[�t�ɶ�^�Qh�^�l��Tս�b8�k�x��/��J)5�Ώ>;5�*F=B��	���Ƽ�w['����R�,�_ �|g�&.���BW������f"�	Ë���QLk���_o�N���i6P%Y��̕��C&�0M�U��-��f�>,��oYd�f��tQ��H��ƙ����k��?ų���dV�"X�˽]��x��ǧ���,���<�e��"&5�=��S��iW���4�c�;��h��`�����ԤGUZ^8�%t�*xf��L����w���ƿN���=H�Q��D��TQ�Lfߟ��a߷K�Ku��m>bs>�$j=�t�}�x���F�sa�{�!͔{�
�)�ٽOSb��;��R)e�v�"S�l13"�����.�QEp��X��v0����FU��˰yPW!�#iX+�%�����U���1{5I&"���!�(љMA
M}"/:Mz���S�^�3颢@���%�_�w	�
�6���c	$FуϸB�Sޟ;�w�����,=$�>dk�~��M
�Ȝ��mQ�̑m�X�o�\��M�o���n��(�Fq�@�A��f}o��������p���2�`�L[iWqu��ċX��;���}�y||�_k�D(f��"x���#��Z��T��m���YǮ��E��s��k��.��K%Y��o��+�.ns_�#du1����b�+{J�p��<���9�+�ޅ�Q��4��a�(t2�ɟ�;����P|���~�KZ�[�nf�K���p����zڜHw"*��sa��@���2����{Wdx��ȕ��4� ������&����J��פ1]ت�1k:�4�f�w}�Bf�6�A=�r�� TD<�Θ`�����0d�Q�2̑%����$[�g�@��l��Zit�_�eaQ�SMĆl��a�<jWwҷ��m==Op�/��r�i)QB!vB\�e_��߉��Z��*��b��(J��_�`�z�<�$�a�<�ᖶ�}FG��8��5�&۔}���s�Cr"(ufB����°v(����HU<K�{55��Ie+�8͎+�i��L�����]R�����;P��s�W��,�)y��.X����� �a��+Z�b*��';N���f�E1�;7{|�]J�/�b���w.�{��&�b�x����k�}�$�a�҄��/ɗ��8h���0[sb>�Wm��7C�0?���p�F��.����5	����`x��Q^o��f�[�'QgP�h9)�19�zX��J��8�&	ѫ�!�P�S.������+C�C8w�U͸���XT��\��\Y��"߁!%�}�U�2$)��n��V�LVm����s�ʈ�����\b��.�p���k����^�72ެ��?H����'�廨�<�7ۉa'I�,^ /Q��yI��;=�K�%���,��6�4������7�lǶ�i��c`��RF}mȟ�c���_u��K�ש�ݔ(ձ�7�L=�����უV�Ϭ�	��	u/UY�}�{!��L��u�$Hڴ���a}����N���A|�}4"�UVd!X������*���0��"�6�t=!��}������_ XmJ�H_�ZW=�}+0�=s�RJ�N�s�s��V-���(қ��������u�G5WZp����N��X I�Ҽ�Vy��k�ws5�kǫqݜך�1)`�����4�n0��Y�0u���a�@�:���ށ`����#�tREYn��!)9F����ގ��q��"���&/�m�Q�/��j/nv��Y�p ��*��x���NI�oQ�tl���<�gA�E�bi
�G�w;��#k��oWO�g^f�%f ��d�^�'{�������~�
��U�c�71���e6﷛��<�P{{����n^�?3`ԉ��<�Y��LQ��×��;��~<M��Ts8��FW��(��V�{Qe�L���W��M݀"��aY������VIѳe/n̴[N�N��j��K:�z�y�WsA��s�]& g�������}&�~SP��3��i|���ٹ��h��w�/�%H%t8h��ww7b ?_wC����\�q���".B�yD���oS��M�>V\2.�y�q���FOr+�BzJ�&CQ��Y����,�z���M�O��A��Ʉ.7��3�z�G�������!ι��
.�Xk�y��@�&v�~t�U�X�����8X)5c���n�d{��s�ﱁ�EH�S�|\�8N��m6�����>�0/Q1�٫��e�������v�w�7�}.YqT��]-��%t�l,;��L� Mp����st�WhD���GP�&�#��sOhY�)\	�5�O�ô��75����%��F��\�Q�V�E���(H��|x���Ĳ0�{���T������mB{�4��>_s�={�^6��4ѻ�q��}�TЫ�6�x�`?��Wm�ߓ���s�ʥ]�U��͸�/8�! և�CTU�w�0���B�_�5߉�bʩ.�s����=%��5��.���W���8�[�e��n�ud��,^:@�-���!l���ل�A��
����s%:�
-d��m��\��K� +����W�����j[34�QI[�q�<�N��&�?^�G�� Ū�n}4����4���a}�&���nWZ}��f�@zO4�.ʥ�9l?�����������1Bc՜,8Hm�oׇc j%`Z5׶��9+>��*��9i�>:��I R�
9�6��ԅ�����~�j�lL���l���ٲ���h�t���o�&���U���-�,ueZT��]�ޡ&�=0x�8,f���"b��R��pKp�C��D�R��@sܻ��@�Dy�&`�����M�Cj\�Q�S�ݧ�Ҹ�q�>i��rmf8>�)����� 0�a��dm}���y���<���"5��j'������\��MEKG�P��*�������Pi��������NR��Zm�����J$rs5�웛g'����䱊>Jɒ�+�-7�ʌ�^�3-t�J&�M#˦s<��D�x��=�f��-È삯'-6wgdO�Z�m��e�\�M����R޴��ĳ^1��[�B�j�C���	�)0a�b�ó��i&��x ��� $�j�zp�G�bgB�6��^i��Q��	�z��uo����G�ԍ�f�h�R�L>�|xmثY'=�X�!�a�n�#a�,�D�6�qJ\���`J�59D�g�H�ّ��U�4O�1m�p2`��6k�Y=�S� ��"��r�bj	�N~��h'�>���u1_�v�L�Y>�(���e����:>7X��AF@dgu�P��ީ���a��a��eh��I�|�(��2��f���ڄ�Gٲ=I=>�P��q�[��Ӥ�יU�u���!�����A�Lz���u��'x���;�-5���f��KM�d��N��Q.i��v���F#����g漒��vL���w~���1TW�c�[@lte�&ܫ�/�{����M=�hпM�:�h$����#}�wICX��i�'�S�ɮ���Uq���Q�Q��x���^�;x�ܾ��|j���|������OP�~�x\�E`E�K>�Ξx6ѱ� ��i����@�#2�iQ�<-�iY��w$[}�A��=j�7w�����b�&#���Qc�4��b҉�ZX��?#;K���Q(�q=�Q�8(���(a�զ6�2P�ۻ���ș�{ɔ�xm��n�
!��Ё�:���}� �y���y;�Q�壓���n��.2k����<:wvA�%�ӓV3�з    ��M@T����i�IH��i0������6E���]�M4��0�)j\�� �dV��drCE$��i�1g>\�P���}��;�2ve1,���G`@)��	a���*D�DY0:e��Ԯ@_rJ���^������a:�+�~UXؽ�6�Շ�����x�	��N��o��C�s��A��Bex�VR�&
@���'��	i�u�����lf{������roc8�B�Vq����En�j�e�Ž�eח���g�����߭�����&�i��TUbBQ�����.r�l����Չu�Jz٬vzM'|�[�t��*����	b�Sjՠ�{��3+҅��#�!���V���<��Pt����;H7 ��v"@E�wq���1s����k3��p����,���A�$fɆ͞�V�Z��L����^Jt:�$�hn����8�d[����h�$�~�}�#fO��zܠU v��)y��:;D�ɝ�~�KIG��l��1�p P��A��Y]��w�Q�(Jw�`L7��HV���+��"�'��'��KfT�
�I�+����H�)�6.~�M�q��'���4�ˣ8p%�Ǣ���*`�{�5`��N �*�q��؇K*`bqޣU+����P �Dzsh�s��T!O)cc>j��8�*r�y�02G��À=�ࣾw���λyݸ��n�O��vm�v��˗[&�s2P���ըav?�*�5(�Mn'�Wd�����A�c���g�ꇥ�.��*i�qQ5��RH�ޝ�i�:�	M��(���� @�4V<0�ڰ��|���T����ȷЭX�~A�;ty �?"=���m$�#=Pz����Aք��w���H]�1��&�B��8�pڴVs�<r���:ՙF<#9��V6"��$E3�$�0�x~}��|�y�*�7��^wk(�L~�}��څs�)&9�B��wW�UL�r�+ ዬ��A����x�4�%D��C�9���-ݤ9r���v`�q�C	���"%�����K?�n�nɍ�9���i}��B��_�*O0�"6�~�i�9vF��ҳ�	�����wx�:���G�Vr��h�>�3�s�&�%;����k3ez��]�<���t����q.��"1->]��M؆�J����ѩb����(5-"�8��J=P�v�a���W�Öť5��ә�l�����H,N�}]d��j�&@z��Bdd�P@�_�맵����3w�1/���U���˜��~�_v���S�e|���>�#�<�v�{�&]����4������K0�L(��l}��(t�Wmՙ]6p;�fw-QFK(1Uo8�����"�6 HM0ܻ5V��o	n;�s��w�3�eW��P�΄3F=ڌ߁kQ������	��)�cri�~�k]e�kH�A��3ǃ`-q<Q�UG�:�2NԬ9R0�D,�����J*�Ωsb#I��l&��v�tJ�V)d���b�~�;� ��U� !ުA���V�6.�K�|���"�۹
�03{4�F�Ch�Wmd[��SA���j0�Tm��@D\i-���>��@䁕��~�hVK.-N���'���0ZG�t��s�(�
���s���{���Ԗ���,�3�dJK�c/��{^gQ��Wh�2����Q�8�f���j$�ŇtƢiV��pD�s*��I�������qa*��3�|$v��SL*��`.o�.��XZ<D9���g������eZRt�¦h�$-����\5�����he�"���-'U5�t7��)�;^�_N�犞��w\:/	��y:<58��Lg79�x*�����<bD����a�'D?��=����T�����<�z�o���ph��@�MC��Т�z�� >wB3\�Esdg��A���nkgϋ ����,�����ѕI�P�q�|b- r-���\�?Q�\�E�B�$������GoE~�.E�+6�[��Kf�����+8�_ }����*@ё��G'��O��i�����?2	����]f�~��5������?�p���(�C�}���/�h֋�ov~�1<���v���: {��WNVn̂Y���h�Zx���@S���Hd�m���B�i���*V�9�j+��R�܋�#އO�G{�"!�MVS���J�=7���g?�Gߥ�R�a�a&|����~8u���e� ��UNR��W}`:vGM�����n�L��X�-�U_��c��A�(}@:-g��3a�ݨ��S��;�W����,6��?o��,�K?��/
1\z=��/���W?���H�o���)Ӓ��$���vH��[�\�S�X �N�v��t�m�
�lL�\"_l63��q�� � k�F���&�)uG�y�� ْo���9�����
}��ݓ~D �9��x�#�M��o/m�i�l�eq�PX�F��p�[�9Z|�J�+������״��R�5���rą��^�``T�pԹ&��7��xg5i�U�G�U`��t���{��&��8)�dk�Q��t��3ޞ�nR5�l*RG��5�?@�Ȥ��+^G�C8/��,xw[�~�?�м��H���~���+�!V��#��m�/�HC~�F���oK�P��`ԥd6��̦@����[Pt�w���u-WP�J$�������4���j�&�k��xa2^�|ʟ7�����Ţ*��N���G�mI�K�����P��<YZm���D�&ۮ��D����7`j�b�۪}:�Pktx5H����fF R�ݒ6�^��1����0d%�}�ݏD<�I�k�6χްkK�VJ�@���4꫕��qc���M�O�Ď"�Ҙ�3Hm��5$AfKҫ&*������������[e=�\3Di(=�3�sX�I�,n�q�ï��V��KV/�2w��6ԣ�Ňݾ��>D�9�Z��r7\�`�AF�_=��x��n��f��|����"��̶�����O���%8z�,���E�dI�-����a��ra�5�=G2}Tkv�w�ſ��Y�P#���C�q�vM�Z�� �ҊӺd8u���Q�6aZ�&���K`������>������,͸�I�9D�?��͗M-�:�*C� ��'����;�Gכ����#{=e�Ś���T�f:*����66�
����GM�M c�.�|��}��- ��pT�2C6�\m�\�nv'1���1V�,fs3�W��M�6B\f�c46�������2��"��ٖ����L( :�y�;�EC��;���c��Y��������t���%��z�@t"�'+P��6>���i%ʯm��Q��?�.^ob��PG[�-s3���U��y�&`r���S�V�f�ݠR~� )���ɯ������S�/{\�C�DNXk�"�!��8t�ĥm�UG-r�؜{��V�ɞ���gF揣I���+p,�V��E[�ET�II�1�%y
���bj �=��lؓ��gՈ~2"�1��w�#-m�r;�S��׷�:��-�c���~�����e����	>��Ӱ��&��֏����~0DC��u&��g|��
��i҃����������>�q+`4�&l�VW���tT�u��vb	OZQ�����!�n�X����M�RƷ���+���}L��.Ҥ�)���I��١Ó�J� j�>4M%���cAZ�l�d����!\�ܾwH�i
���n�o���J
��o�wsl��0�㙲N��W6~Bl1_Ѧ���*U�&k���$�Y���F~d�^��ƽ-��}�)��
����9� ����'8
o2�����^�ӟA�3���PRz���+��H�R���R�=\gPT>@f���د�AM�d|a/X���ŉ�&�cy@8�����߶���)����-�a�_�V�}�C�s$_�_N�����U��_hl'�C�$�"(��	)mƬ��L�.�Y�ݯ=�~��ys������	&O�s<��G��ݬRfA����螶���n#BZGJ���*���.��0_��    �Xm�v�c�5ܬq4��g	�8��(�Ep��Q���W�\�H��� ��*I�����{!}�x���	���aq�N���`O	(�^TP־�8!!e(k��0!<��i��\&�Z�����sy�)SR�߸;�aD�%9p6�7�P�����L	!�����ydIa`;��Kf�)GY-�g��u�'�g�a�M�z� 9We# +���l�k��W$���EKռ>N
���z m�2}�"�3�c�}��Rq�t���3�clM��7�Ǔ���h�O����{?�{/m��aԫ�=�P�i�w����j��D�Ն�-���ְ�=%��1~���_lÜB
O��!��.���Ex�����09Yzw�w 50����6_��$��9Չe���A~�;��ػ���X:G��ar�6$���G'l �~㩹��=M?�(z79���O� ���z5ڛ�����`��kA��L���Q=�O�
�I"�(Z�a	>��Y�%�H@�&�kB	�d��w�E	jQ��y$����O���N�Z���'!��v��V���u�{��*Q�����Nޤ��'��zœ��7D��7��op3���F�Y��6��$��vUL9�ql���ݨ$�C	S�([<�/R�y6�Uve�5���sq}�	f6S��h��
d��j�r�/����U��z]s�q;��
�;J��vP��D�r��Q�Ev�Í\���eJ����-�G��n7��fE-o|4��C��St�~��7��l�2��n���K�;��p�^_�Œ��vEe�ͩ}�,�A:y�t���6�Y�����Q�"�a�"�E�3�.Mqd�i<u4a7'jz�����|�����ҫ{��,�Hy$�I҇&����l�B2)s�~d���H�7��G�Jt���p9m���[��R*�vb����ի�%,P�����mDW�X�b�Fb�d��mQ֮5s�K����u�$�*(*q��X���p�X	&g������J�FV� ,�vj�j4��j&��TZ� L����Muf;9���C�v�lEk̄�%�i�{�	���9����ሳE��e��<כ����(k�����/�g.��,d���pw���Sβ��m�[]�;j�Gx��uY�a�8����윜�t���y�.�Kq*rU�g�9�S���v0�|cV�$f�祘֣ͭQΙ�^�H��[�)�,����0{,��VLv]�Vo͐9}:Ր�A��!�i]l|<�7L��n�Pb��b�ױI$���F��@`Z��m�{��L�w�fP����i�`δ����0ԣ�\�2DE3���A}9�Z�ą�E\o�*�Uꕾiۺ��7'�0X��gؤ��1����I�{>:'d��|(��f��r�Л��9�@�j����3��������E�D������'�b�b���|Ín�U�	`��Ŏ��.X���H�㛀q�x�(�Z���E��3��h�{�QBDtz�.6�y4�;�-���=�®�B�U�z�v�q����Ȯv�T�؟�l����F��9u��0������q�=C8�W������/�s���ܣ[e�R�V�3>��Q��X($Sr�m�6wwR	�o���#�)t�qA[��KCA����7;����\\.���	I9s�ծA=R��20��Ǖm7g�=��GӤ2|:����[�I��h��5���$:ѐ�<2�(=q'Hʿ�P�Qx��;�S�![���h��Sf
�����j���6�)Q�
=�����z�V)?0�� �S��;��e'��4ټ�qwػ7�mFM���6z�h,%�|R�t�E��{"���_X����7Qq��0E�qԻ��n�=�a������OR �j�,֑��On���/��ѹ�f��Q��Tw-zC�"�D�����ѭ���iU��w�=9<D�^�'��0�w�=͹cx�t���EC�p?5�e��81yR�钰������n}�i��-��Q�ǹ�����1Ҋ�:,��nT얺
���-=[���:�6o�l��b�����(����1=���L�|���[�;��̺A(�
E�a��6�1ؑ.a4'�^��K�7:b�U�D�vahZ���̦�^j�Lw� �?�f��2��$�a�&~�2r$�;?�[y�B��ё���^ՑɛZqz�
�I���xd�X��<�I\���^R�\�v,�[��h��Ԡ���f*uSȅ��s�N�
n�)9�~����� �����١�����c�t�2�ud�"t4~l��o�H�kS��rX��2��\o�9�0<��1zw��6PV�R;8�g�;zl驉Ƙ�V�������=�x�쉯���xo̷t�y�:y���+�e�9fN\O�)Ȋxk��q��n��0�{c.�v^IP�+�hzc<��E0/���sFه��:k��� �dn��1�.rirn������Y�ޠЁ���S*��d��-��jg����l�kX�`2���ٮ-���:6���"��V��T�^��IKn�`�.�WxO^��`�Y8sdC���C[ꒊ�޸pX[^-�.WMh�$خWb���Bn�Lx +��}���o4BqV��i�XmVg*+ǖLNiע��ć��eܷ3N	0��ww'8���hű�Ru�N.jګ�֊J���F6��E�+Q�Mmΰ�g(��d��cs��^�-Te����~�94�?yl��65ϯE��p�Ɣ��ՠ6��ϐ\�`���"���U0��Æ��-�w;P����N.9G�ޱ{�d��t�m����!�Ẉ��R��6�����!�$�?�G�7U�
� /��E�ۨ?E>htへ�{Pt���=�R �2[��`�L]�Q��(����)�E4�ǆ8�����	���W�ɻz��jV�D�W�*w�GM�]�������,�	�*�Z��|3~Y�jn�l�=>k����T�@Nk�g�	(�7[�C(:�I|��Sry�	~	c��^�'D|��=IEܓU��:�]�j�_�{�}n��^cX"u�~��^H3z���(�73P���-�i������iT��KQ��Z3!Zj��I	����Q~�H��|#��C%#�x�j�>����*�N]ĩ`�!!JJɠ}���B�������6���n����R��t��*�Ga�C����{��v�O�^���;�-,�ߏ_�H����ďn���D�~u������h.�kÅ��N�G�5:Sr�������]�m��ke�ՌL�n�?�I��n�Z�We��6niֈ$���J)�|&AN���	D����ڭ���WӤz7�sx�9��Q���Z���=/Zq�f]��(����;�6L	&�f|y��O0��Uiw��ٌFg��	�p�j�,%>Ѝs�*M�F�&Д\�>��otH�F�Ǯ?�w����Ђ+�PZV��>�[.�N!�M���y!��1x�8S��Ac�lf�)�3��1;�<��E|+U��,�(5La�Pڷ�(��sPe�8�6����@�S��8j�Aм�j4B�@gQ������|���7B[�GF����3���*�Z��o�����wS3�8�O�Fn��hV��=U+*-��-Vn�W�H�j���|s�}T��׶�v.���;B}�L�A�SHեG
$�L���cşvB�H�s��a>Z�Z[�����*`���y�"D��]kع��䳌/J�����T��]t�SY�=�	��!�f��1�bk��sM���T?�V�yrY�nPDT��#0"j���@�?(��d�(�u���e��va�m�f@�<I�m](|m�m]$���.iZ�I�Y�]�_m�S�Z�zZ��\�({��9�rO���)�|�O�
z�I��� �r��x�@U�y���"�E��Q�p�z�x�Q�,���~sM?����k�{�	jH`��	���F{������&Q��*�B��l��yb2�ⵝ7����`��U�UU#��6�:y_ )��{u�#W$�-)r!��r�c�&/��4S�P��ُ�A��%�P�P�v�-V�č    �4�A(�A�=q}�S'*6�E<e=��b��t���j��DFY�Eh�곒~�6�7����8��b�l��.��`sߪ�0�XW�����E(K(/;�	��* VRA9��z��o[��_=�{��f�"[亄�
��ͬ◓�ϵ8��F:"��U�ev���v�D�O���owH>w%�W�G^���[G�8���v��J�v��OV���)������c,����d����ˡ$��+UzI�"B�Kw3��l���V��ͩ��%����W\m�[g�y�� B!����Q���Ϝ`3�O�EOp�T�kvD%?5�iR�}0HN.i�o��Gn���̈�D��1"����O7Ԋ^�<���?(���4��#��i��o��ן�4�]R,�����<�s��!8&�i���nup��c�'𦉃�.�ÑA����"6ΏĄ?{�±ūX�j�@qI(��$Q�V�m|�e��J)uB�6�]�|�� �[�}RUrS���2|{��9�;iG���5��=V$�w�O�)�k�r��Y��H�����q��Z_��/Ё�+���j4�� ��ظ���lK���zǅ�#�`��?�)�3�~�.��T0�����)Y�hks@?J?��뛘�;�o|���t �v�;*���	���A7�5o�c��Vń ��p�U%<��޹xg?�~�^)����6����1(h��X����K�6z^Ha�(>���4�!�c?��Y �U��UVq��t���P��qi$C�t0��?p�)8]�Db�*���~�gf��k��9�t����U�nM1�����ڕ_�z"��y��>���Rȏ���Dfg��q7 �Q�{';�Y?:�!��<��O-��=��J4�Yr���:���7�E�Ak��_7��G�q�'���?9e�o��F�li8aP��5��@��=�
�>��(6A@�Y���6�f(���	2Y��%�/# # Ř��Xh_߭�	�;��뤈Z�e���Ȓ��`��ϛ��W"�!���m��56��~���+(�������Sg��=��]+�\�����W�l�V���җBu���{*��h�-�N���x}{���,�!W�|Z�+q�`��HmmZ(fYI�x/q�O�@�BI����{��np��-�n�(TӤ�F���b$n1���!4�k��&�p���X-
3�_�}���;��Q�H�.�9�A�j�Ç�hBy3Iۘ&��k/������%m_���j�!7�d�w�t��~MwO�,^�`����Sw猭��s��ى�F��Ԝ�9���Ń��
�O~����6'���.����B�����]C�z�/���2���+���� Ny���L&I��u�����O�/���T7�p<�Pa���- tb�~�58��t۪�Jq6������ꍓ�:~�P�:V1�8ud��B�9��X���W>�W�RO|Z:nU����d�VX�?EYinh}4��v4��_:�>���Z q�O_�EK��joʊ�4����"����|vQ(��*g�C�[��;�p�)v$ +D���o�Kտջ�?v����9"�}�����_x���/gDF��kW@9
�ȉ��C�a��(��,���9���P�"��W�4iw�7�v���%	��1�'O�Gd��E�;	+B�4F����ߤ[���[3^�zs������-�?��;9	����� }�����݉��6i�H���V-���#�)l�y ��V�\9Q��W�_���ߴ�n2ӳ(���>cz�ͮ��=ʬ܏w�n���BJ�C�M��!���� ��"/q��Y-%>�p�Iï��S"��'�A�	�f���a;�f�� D����"b5 D��ݕ�W�������@_\i�y�Uk%��z��D��|*�����|4��g����U&��R����-��AV���S}g"�H�,���E$�v������)�rA��ߴwTmʆ:({򉾖ܽ����ܷ��F�o�!(�]��6t��y���S�B���w������2�m������|{ž�RP춎�T7M
�x��G�e��"}�mۉM�F}�9����f�8F�W����MD�G�s���b|N�扇�Ҵ�6�[��꓉M�S�F,��%�لn�V�
	{&cC3���}9#=L/�0Kq/�w�XfJɠ�3Y��(2��|�=��׫8��+s��B�ŕF���슥��7��k?!�/�ҸTثW�}���Q\�џ�(�OT%�/�~_��+GЃVII��Qq�(��k���gk�qv��$M�+0��s�pp-$@Z{�\���2�x���V�QX��}�jh�l&�]��{�0��4)˄x�i*ފhm�߮t��C=eK�K��_>��?;�t@Lw�Tޝ5=��Q8�������������vz]"k��_xIE�`���][�aF��Cv�Լj��{R|d�8l��2�3����NR3�E���x��k�1l��^�he��>�/e�jh��l�5� DJ��	_�JZ-N��-����,88g	n6(头�yc�ƕ��8ŏN���X؄f/��⎾,�0�`8�Di���6�:|�Qܾ�ɁK�g������Ї�z5�E]���w�6'_���}�x�g�l�=1i���Q{�����x /�b�_[�n��H�o��v/��T�(1��c&�ۄ��jYS~ё��>a����<~ݘgǡ �����z��4%fÙem��k��%�oTW���S�h�����>��u\s�ݵ�z۷Z�Ө(�A��8W��~A�\��K��M�3�ػ�~�I6�Ł����,rO-�er�_u�I(�������>�]� ��
ێ�>l ��_���^���(��5q(�G��A�ݛ���+�\8�@_n���s���e�f�>6��u�=5�"kg����dxI�{�ޚ7�C�7"�5c%�Fc��p�p������]��0ߝ}v�c�M�b�XD�Gezms�Y���H6tvO1��l��G���;]EL��$�`zZ	��֓�[EzO�-M�Os�7औ�Lp�ޑ�<��ۅ#9P�S:���x,��]��5���k^�$�+9�~-��xMb�'�@*��������.�Ȯ�}�G�5��	��LJ�\y�ë7��s�S��Q���ۆ~��w("&2)3��I��q�cx�7�����q�{�H����%sp�0^��0�Dd����z���� ���y�B�L�ס��Xs%���M����3`������ Q��xL�Hd[�D�" �����hs�f/�,�1��Z�Z0̍��o:24�1�)W迼�s��+�0����ۭ�j5U���7W�F�a��X�>V�nF&Avj[�6k���_3�{bHa$N��E�������.>�v@�A�@'�X�o[s~@M���>~p�9��V�iD��?��ɼM�{T7�^9�:������Ƈ�B��Y2���#���r50R�9 <mB��M(��״��a%46{����U"�Z�&����i���͕o��&��F��' ߩ��Խ���dBڄ[bX:v���.��w�!�d�����j�\ޞ���[����`�W���:�{�g��"�"q�N�C��w�Y�O�/���Ǉ翓F���A +������V:3eX0��Տ�&oS���YЪ�w��B�g4���q��x�mH�V��N�	/�i�a;V�O��h��t��(&?j�5*m~����{��o�T\��U�-�}i�ѯ��\O�-��Ɍsn���1�a�w���V˥�>��Fzu�~�'z��V�@Ș��RE���{���!R�ڏ��@�a �G�=h\Ǳ�+�x��#���6�^�]�L���K¨[9�N����&�8��R�q"�F^S�)�S?������]�oQ}�9�A 5g�G�Tyw�~��z����q�l%�6��{E�]�~0�F����ͭOU8����(b0����L��:��4C��j��z�ϓf��IO��6��
nr�JVF�r�[n�C��`m�.�8�b�=������xH��`B�6����2�d,�X#������    QN7�iadӤ��RO{��Ԓ�=�z���[�؎`<���6�� �ugf��7�Z�y�V+l��X"��N!K�R�(�-'Z��6�R�5QLIr���'Jft4���eJ�̐I��{?w��v����9ݯ�o���GN�ܩ.�!\��<c�y�e�z�-4������vBv,���6�g��IG�~8~9���<�$���r��e�ޤ����i���~{�K@\��$�胞����8"��XZ�]]�C�p	�K�R'��h��d�l�DD�����=�>���T���4�̲�I 2�Kji��Qg>R��t �J�����B���E�4��
�������?�B����U��&wl��������k������b��jsA:3��U�����̇�����&��ӛ��G'1�ƕnp�t���p�
s�b�}c��@���Y�ÿ�C�s�ʧ7���D�웉*�f�z2�@W�Αm1�GɃS��{B�4�r��s��r6��7��7s!�7'�֥Z��u�Dq��U֧4��-K���pX���8-���;	T���������x�`(�L|�j���K���K�f�a��/��K��^z�*X��
�Pa��5o6�lJ]� �tr���SqӘ�R��o����9�D���Pm������~5K�\�荢�e0���<�3�Q�=�+=�'������4�{���_�D���Ky�U5f3�}���	��a�Y�I�O��d���f�L1 *�C�K�OJ>q�w
JA���Ph�,�⇵9�@���Ex��j~6qͭ����:��Q�O.�yt >\��,&��b��*0���SJn�eT�L��م~a�t5�@��Њ7��1�e�.�n\��N��l��u�G�0���(���J��w  0�q�33���^���ko) �cp���ed-���I���<Vʳ�7t�Ct�caӌ����s|��[Sۥޡ�����G�����i��g݃glw`�p�P�Ȋ�Y��M�X�IX���q;Ę�lK�e�¼�%�Ѣ�
�l��c[	�]۾��BH���������<)%#Y!y�n�E��(��D�{Yz�uAX_ �J�N�u��{ ��6�5$��y��y��v!]j�s)2�E���C#���:����!��^��"cڋAR�P�}4�~�~��J�Ɇ��ڙ����0�h����7�����E�v�'� �P~]6�k�&�lS8�Y�/��;��_�٨��u�_m�&ET����^c�]�*��4��q������k����� 7m]~�E�[�(,rB��cX���y櫢yu�校L���uA���^�i���ģ����wI,�d�>3�8�f��\r)5u#��q Kc�˵�n�7�l	!���ܣsM���昵Y����.�E��o�@y�;N#����t|:#�u�2M��r��/���e������ F ������6�,Rm%+�^�/�N����]�'Ⱦ�n�]Q�zO�^������?R���<h3-�uT�˦����)~����E64�NTS&}��qY0)�ŏ����|OaY���)\}�KNQY��:��N�l�c����� S�WJ�kI3{z-��f��`>����~_����Yw�$��s�
�ZRA*�n�N��*�x��>|
qpNS�`r��@2*'jjj'�������l|$��	e#E���]$��_��B$~���4F�q���aA���g;
Þ������m�[� 	�б\.dV����v^b�ԣE�++:Q�+��S��m@�����0Ti{齤S�1�Nga�1�f�9����	_,�敲��=����Hcy��=ԕ�)*����y�J��>��߭��Sǂ�/��}�װ tHk����M����E#�-iz�����%������jGz�eMͫ�ؘ��~�Յa�)��	yGsK�"@f6g�ƨ;�	���<I"-w�'��G�2��IMʭouͩ$W})�"���ݝD��0X�N���H�d����%�p@n9�4)v1��t�t��eI&�zn7�g�LY��ז-�B�J���3ZLۤ����y3���Q�lEЬ!�2�K��T;�[�y	��;H����|uY�tQd���iߚ�&&�&w�
�+��ٚT��P��/�>�F(�Ḥo�w2s8a��ّy�ξu��B5'�4�&�����]�p��b����|9���K�.c���n/�P��M�z�C�lG�'��^!`������Zŏ��%l[���1}Jn3Z�&�h�"���]��l�23t㱵p@$��q���@�Z�2;S�m\���%d�P��[n6�˗�����#t�¶'�c�M����
Ps�}���y�un��S�ӓ�~Qؐ#m:�����	�n��}�?S��^��Z}�IZ�1֘-5=���װ���s�t�MHN",����"���TT�t530*�)����6�V��.�&XTGPC%a�2��C�h(���$��>`���Y)P�s�Ѳ>��ZV@>��M��>�.��f�n{#n?�C�ݢm�"�kɊ^(p��F�M�r�~|taW_�Ŵ���/x��M� ��D�'������sx�m��q��ܩ?�`��J�J޿�:�C��[M�=��wk���1-�pXL�R�3�H�����{���!&$���R�˴6��͉�7���n6_��V�<G��b��:c���r+T�_�g�?r�y�� �M�n?õ��90;GZ'6��l ��0U�U�ܓ:(���b�^�y|Z����?��eɍ#[�#�"_ ip��)�RT�UڒJǬG�	R`�2��欆g��m�U��hwOj����ky  ��Rz������u��zv�ˉ)���ޯ�!��(,Or@���	�����;e����1 mV�a�EZ�t^�7����oa��Fw FY�@�����M�1���ws�Ӊej��0����%����v+5���3�OS��)-UZz3�?)�m,'b��u4�uXyB�B7D����.�bY���7
��L�E���\���D,���A�D�]��$��b2���#j\M=�1>��C 9J�ɵ��R��Z�Vs�P�<!61�J��I�n*��(�c\)@Є$�M������χ�E�\iIK7�C��KۇƁ$ʓBw�r�l%�L`���Ɲ[[H�|��.���2��c5fD�㺈�`Kw�%�WN��?�0���ȶ��&P ��i�+\	��8��ڪ3�4�0P:���lS܉����IK�]&�Ώ��}<,1[�8������m࿓�6Z�g�\פ'w�ҝ¢%��:/�A͝a^����ΎO7OV��X�\��|h =�Y>P����:(r����x�?�� �ȏ�5����lC�N�T�9f�t´��Mo���,��V���b�-��	̰{��n����p�r��=����^��z���`l��>qU5�4q_��l��g7���z\��Z�l%5�T���E��͹-ԧf�\o�U>���X����`��|����p����D/���(<��'Ĳ����>-h&AL��+�Z#Q�E�OOǇcXͫ].MMO��|<]1UYq��̬>�Dh�/�[��@zl��풰�/�"q[��U;��V?f�[�ڏ�G�b�6��g����|�Z6�]5�H8�K����1�s�e�覾���ǵ�sD�O�o�3�[��r���|⸈-�W�0B�sLħ���OM�eݓ��C">ݼ�%'x�c{0�-�E�p,�)��UUS�"HS��\�P`]$͢�G/�E��he�$��ܷ'�-��	D5��>]��\��$� b���n��9Lм�G��Ӆ-i���$���g!��/ ��|X��g��|�M���)n�yL���Ybg��<��屽���	�hZ_�b�
�� �lˑ�c���?��a�v�@
�;=_��Dyl�98���~<�w����?=l�*f�*��/�G��n��o�ս�i8��c���XD����@�o��(���(?�(b�(6a����T�)��֤�[v�&A���W{����?�(�=���-�>��9q�Mmߦ�����    ;M���{壻HV��E�D���/j� I�����y���w�����\qjN�8J	�ٺ3駖��"5�1�i�9�`����v�<A �)ѝR��gJ 4̿H����I���>�-�*ҕu0Y����u-�(=E�[�����1�G��nq���S�R

���.ڠ�tv��&�r�o)��e�O�T2& �n����KIph�����F7�Ђ�ګ�����6w�OJ� :T}�	?�5(1���o�PC_m�C�k�c�v ߻s�ԻmfL��L���*�R�׵����AG�^�1Y�<��,ٵ6�%=pt#9"{�mXĶ3��x!�NԀ�Z���h�Q��g�ğ��Sckl�N^l8@&AC�s�B�X�^�:9����M7 ֺW��M:��	@���ԋcX��Ӫ���y��9 ���_���������=pv`<�3�%5?
ug^l|�ȠvcR5�Z���z�� 5 D�0���H^K�'��'
Ϭ�a�ڔ��&��S�%aW��~�8Y�f����{s�ݮ��9-෍����#�M�3K|jH�/�j��8��p�s��U\	�쑌<q��>���vu�w���,o3��X�ӷ;�U&UHr�kۢ�?�cҼ��c�mO����'6�k������O j���q��8�Q/�̹U{�3e:9�N�[��L���ʍ�ů��?�W���-|Ij��s��o2��l�_�1�v��q��7�e�`�aR%UJV�G�����Z3�aPS߇�����o���	�~��(&_M������آ\=���� 27*7�_�$����-8�]��zNw��&A�%q�o̵n��.��G�C���(���F7i��;[��<R1��Q������m��eڄ�����1n�çy�/~��J�<���٣&�����b>��w��o�oq�hD [������Z�P�, g��4|���S>���.9�꓄�m��X����3� bt��0,�~�����/86)8-g`�`Ic�:������"����>�R��\�]w hhG�440��ɛ}�r'z+',V\2]��4[p��گ�N�?�`%,�,��7b��@8ȓ|q�Y��Vy/�(˗��[�pļ܄��|���Gt�V�;�b��/�	v>/�3���]���Q죒-͞V��6��G}ew����vE�!�4aV�����dT��Р��;����12��ؒ3]��.@���>|��8R+�V�Vײ���dZ��ۛ;]�K
dD�]D=�t������D5��� j�
�|"}�l���걀������tM�hՄUs~���k��w~�П�
'��aO����^f�b�A� �NbO=G��iP�m)����I���e���ϙ�����e���B�O͗'2Ȋ� ���)(�P�K���n�,��ټ3Q����p1��*R�]|�t��#�L�*jG�J��[m���:�4s�[��z�z8�Yu5���c�HXW�;]�6q]
8��/��^l��י�l�"خt,�]t�o>杵�ŧj�Zu9�Ǚ.����l͛�b�g������ښ����Gq�C�۵��۠�^��q3�FpƬNr�c��x�+ ؟#��~��t���H���t�Ӧu�	�i�T���r|� 5�,�E,
��)w�����+����p|^ym�*Cd���U��5��3p�<����(�RS��թ���=W��E¼��y���������'��q�`f���+��N�٢�5����(@]w��� ��F�����C�s��~��Lul?q����kmÈ4��(=�����s�HXՖ�0��a灶��:�} ��6�q^��S��.��jDD2��$�1{Ñ~��V1[�Ǐ������g�C����`��`�bJl�~��GҪ��T���1w���.$�l�����[}W�Ǜ: ��܎:�L�3醼W˜+3�/�v�j�U�u;�{w$��v�R��f�ޣ?�pE͋ý�T(]K�Jʧắ�����=�������B���aIM����N�����_V���n(}�}��j�y�Ѩ(x1⼚R�M�֖j�yJd��3�%K�����y�����|D�d��q�kLz��οy	��<� �%<T趑�<�V����ͳ�҆���֊�PG�w�e����n���q%�v-��@[��~F��5R3��,�ڶ�54,��md*��_Ǆ�c.�)Y�k������,K �mjV�CR[�&�q׈xLŋF��{ޟ�0^{��`A��������D:N�����UMDP�@����;���I�ų������)���qs��F�ļm�v�&��Q��`�,hRS�v��}�ER_-h���a��) �+���U�["��2%Ɏ��N�iB�7!�`^dT[�^W�c��3��.�|�M���w����u���y��6�:#V�_�Tk�VQ��E���0
��������!�66X"OU<&���6�O8� �<m����T��;Ѕ�7�[]�����u�����H�FFz����Q?�/9I;5`T䇅��Z����Pg��JG-yM����L�VƥJR;�DI��ݦB	"���j�Tm��&�f~���N�4d���!�E��1�(2	��HB�ʰ��H�,?ӫ��yH/r"��H�n�:c<�H�l^�.^�E���s�+�i��E��${�`м�6f�@�Z�rQ�4L2�{�*~�[%J���Զ+S>��E0���2�$$��m����r�%�C��M��)��ّ�c/j��L{{��쟗�wǧ�
h��j�6��Ӭ�*�H�&�~$<�x���碾X٧kݣ�Wva8�5:�([���������e,d��qMs�@P�#u�	P,���I�a:��N�HgpF�'οcG#�}�t���S��;d}8�@�>������?@k����ޮla�,>B�BU�B���꣌9�0,��>rq����;a�VJ:���W}�y�2bc_���k3%�B� ��(އl��JY-�(u�md���$MXG17��?���M�P��$ކ�)4y-�p�VO*)E̗�� ��y�1��=@�|23�^)���$&��~ΐ�&bFrk����$�`G���T�UM�h(0Qd�E�ݬ��c��`�lwJ��!���F�#j�nOq[��K���[����{\���	4AZ�.�O�a�� �t|�=~�����?��4�ouh���.j	S��S'��X�}���i�$��ί���#���hb�z��RP�מK֭Ps�+�BH=P9Ħ������d����R��hő.!���̶ ��N��j�9P���2��k��BO���/"|��5�~�L�[ jK��e7KB�m�o?����u���R����s��Au2�'��f������[��!V�������m8֥���4�i�����Ǫ�@w���8���]0U�R���w�ͪM����p�y��G]
��JH�s�y/����*O4r9Ħ�0�E�4xGyr�gX �����d�%�Dv7���no��>?���nڰ�e"���M� �������gy�-���7�EuBQ]�_����r�N��>I�9�|���0�W�������ɿM
s 	+{IDqk���]�i*�;�����o��@��Δ��0Z�&O=�6=;	�grg��5so5�v У�ܼ����l����b�ھ< 	#�|߬���1�4�j0���j���X������/&6�P[����4��[s0?v5	����"7'�ܵq�Ysʀb�l,�9A4]�B�
j��+�;rhZNY$n4��T ���O*��Z�^��oXj����v�~5�"dQ\?��\�^U�壟~�@'��Y|c{i��O&8!�0e��D�-Ĝ��f�=�3�Z�q�j�IK�s�t�<���u��u�u�(y��Au>i�7�-n�1ܟ^��B�C�A�m.�B���R*�y��{1P @)8[�.��8�:�m�rn�Wi��T����2m��Nm�j�a��    a��y����6�o�Oڻq��0U'ȕG]��
��%uC8j0,�������q�����b���݆���\�KL?~���Lb+���Ҝ�[R�"����w��7�)�\�~>^K�bD1U�M6��/&x��UP�L�(Fuõ���ս�W[b���_^s����f���j�z�H�������M��N.�����M�����`T�7+�<F�i����n����#�	8��F�giָ$zg�Qp����H�<rڙhQM��@п��?�w�ͧ�g��_5�G�V�~�Qh�]���?�\r�dO�I�f�>��}!M�BuF��3; ��P=y��ή���=�F���O=��pmV��阝A(tgֺ�"�ō&�@�T��uK��LF�</sV�3�2g"Qu".\{��'�t�JHW�a�[�D���͈ ��T��7����sDLs�ރS��L 4�՘�3z��˒Sw��3�PiQi$��ə1:��q��#e!i�����Z&�r4'v`���>�]0x��*����_o��z�H����<\�<�t�͑b/�H/�����4�����ׁ}!_=nm_�{~f�����9Rt&@׆8t��<��M��fZ��a���p|�0�%j$�|)�tH����*���5:\w��wP�I��j�t�ܵz�A������l2E��P��lQ���� j�>-�٫w��f?�vb���E��].U�
���/h�;3Z셮��B��h��O�+t�`8Y]���v�δO!�'N@J�0��O7�OQ��z�<�cf��V�/)F�����/��U��
x%�Ͼ-Y�΁�ߟ5���g���؟vp�[�R�@�>�g�We���FB��a�Θ��¼���J���l9M��vJ�Cl	�łWmç,4Ogkv�#?�2�Ar��Ƀ��`�؄�7-�m<�k4	|�� >l�/[8�h� ̨l^�j���z�ݡ��?R�Ӎ�H�S��E��y]H�5����ިf!w�堈<�k���,�ݮ��AՊ1!�k�O�և#��{n��F���(>-j=*A�Cq}��d+���o��d�g�p�_d��p���_
~��?}��Z�T��
��wb
�R�&������$���<�TUa��m���/�teG��``��H�B�+J2L�����s�3�ʹ��չv��$8��>4���9`������c�&�/ ��hs]�N2C��N3��}P��;x��l/�|e���ο���G������ �M�ud��*�>��y���b��:1�ّ�28_I�-C��� (�ۯ=$.��Y*�GgX<��/�C�@�z��#{��������"5�c,�n������yF�$_/ �D�`oW�ܯޝ0�̺�{�ZT�# F�#ŉ���a��D�Y��uIyY!]����1uW�WF��K3��u�:HX�;�1�`�~$�t��! }�����DG��S#���on���8@�@=F�Ƹ�HG;p��S������b�v9�i� {��E�i?z�m�I���o|)�b*���p�� /rz8�#���������ς	Dq��>j�i4k&6��[��5Q#Y" �����2xX�+�^�����N?r�9	��z������frEo^�?n�0����7�$����݄I����h�@:	�]����.j�nG<�B��Z�_V�%�\���I��u���;_��rI��d���By�1��G��X�v>(�6X^a������rݙ�8�C��A�ڰ8�
>벦�ڎju���7���Lڤ]u'Zr�fWdQf�'=}/��!$��Pw"?x԰�i2.�x
�K��<�M��M3�J.Ũ��h�z��Ê����,�G�{���7����c�>�F�Y�T�����Y�m`��I�|)!�%+�	��V�&>I�&l�k��x�6^��uE����R����wT��0t�10$F�ʣ�8�M3���m�b"C�f���=*ds�b�p"��VU>�Qd[FV٪A�!5�qK0��m8��;�����3� �EySJ}@��"9X�]���i�}6�f+�a��7{�"���W�o |�9��z�lǇ�#q�"sS��W>�[�}�1-��'�5m��m:����HH� 1�/*��K�b�޴���V�����o7|yK�%��r���o3ʴ� _�����Q/��BQR{=)��J�L��?ֹ�o���~���R��_V���9؏\���mw-����j��IW���G�ͤ�~���g��#�x��<�6�� ]W7��B9�h�^���u�S}R �[��"+���ɵR{eo.��Y@�B"Q⃱��Q�����>�)��'�@�����|��$
Z^TM��*�yr�	�/y�A��IsV3p��������.��?.�o��1mh��1��*H��^���t@DͻBD��9h] m7}a���q�����F#�$4���Z��L����
�ն�p����Q�G���a7OYi�$��sEC�� �\]׀`OE)�NC�
���}�\�.aB]�qhU���+��,��3�Α|����(&p��nho�ϒ=�0ʚO���t��[�6�	H��G����GY�	5�����߂����c���΁�C���))��D�B'#6�u[��<s�h�y�QR�ѩB��W>�
������ϛ���x���t9E��TIg�Yo7�n�Lo�h@ �q��	8��ji�h>�=�8�Ѷ�y����<�ǁ9Dm}c>�kv��^�7Ӥ��;q����9g����r�P���&��x�،1|l�5�M�����5����;�6�0����_�h6.�cl�U,e���%]�0�	��A��������u�`���	���0Q)��x���G�^O�P���-D��Ŝ~O�R��x�k�Sn]�"!f�!�'xY�yG�!�"�G6\��ek#�#�2`P>���ŉ���_@��1j��-'���b�_/�0e!�E�B���- �ƥc���0��O�;:�˿�<��|��vdږ�"���F]z��-�����n��^!�N�k#��%w���H�d�f�"",���(��Xp����@vਸ��-mMv�CIx"*�6���O�j$J����"9�#x�lq����jV�W��x�C��G��e�*e�X�>�Z�/bBÜ�i��"�6��zQ�Pv��7g|F�P@�Kw� ��T �1��蹌��FR/4��/ٜb��P�*�%��wP�$CNܺ�^Q�������h*�$��`�,�[W�_>���I_��о�|�0��ƊD^��:��r����V:N�[���A�	e�U�'	�v�k0T�Y���n���側I��jg�4)��r��IK"�/NTxuVg��Ϣ�l:'�=��-��=Y��VS�5{�~ᵔ|���G ��t�	x�
�L��٨���v7���By�*��N��D&Ur�M%͈/��ɲ
��x������b?$�{���\k�ȶ��������	~��T�m����1�8�%�Jž���_�f�G��^��t^������55}QO�����ǰ{��ʪ|ؐ#��X_��f�]��'#j��q��yq���D���x��l��r�lG����E��Rj������xQR�-j�Ͼ:��ޯ�99(���bۚ!��;B�1�$ ���+��(H��y{Й�*ό�8y�j��T��VM�2���J3���US��a��U�dR �4CJ1�P�k�*b���e#: ����?o8T�����N%;��wQ��zK��q')W{ʵea��Ű	;2:��@����Dy���9(��_�e�����qIƝ�S��A�8��V��8%Ͷ1��"��礍��l��2�vR�W�2���Y\�J�_t٫�Fܛ�����g:Dd��+6�vz�ޱ �IJo$�`�a���$�n%��"$�%��&Y�����E$�*z\ܷ�{��@��YLe��>���
8����b5}`��gL?�y��Ä� �)�� �)�6��lmRW2q�f��H;���I5�:��N�;��Y<�O'-4hj{5�x嬦M    Mh�	�A��~T�ت}i�Ji[�Er�X�%��=������]h2�.��N��.C.��wk2������W^�d��Q��澕Z����@8x���ij �3��w&7Y
�����
-��v�޸�2Ɔ��WU��"��cow���ᔲ�D�\�DH�.�6��V
��K��U'ƽ�0��L�f��L��_�Vt[t����{E�S�N"�tcKT��jwb@ �l|�M���Pr����R[Q`|=�>�k��WĲ����.8�]g�]o�O�ޥ��~^5}-�3QL�E7�Y#	�h��L�کj߄�y1:m$�2�SW���i��@���k;H�rԑz��Z�"f�9�a��&ha���ox%H��]ʏ|58�E�8_Ǿ��]�k�9���m�M�el��$)��,K�-�-���g��8#5��!��'B�������1%��+*�<1<��'�[:& M�_�������|�vs�m��q���w�r���̥�7ꌯ�e�9Po����S#��$i]��q��.y:�̪� ��u���.����T30�,��0�1ۚ6{����J����C@����B���h�����ݭ�H�ۦ/J��N�˚z�n�����vs����	vr�����LYM%�u��݀px��H��\��LTf1��3��`�����0��d���gpA��X����
�>��Dt�nߐD"(����(�_A��ƣw~�s�!��$��Z���\�3EM|����=o���0�z��ƇgWj��+��L��V2钛�č:Qn�&��-�a^j��5��ݪY���c��M�EOY���_f[�HU�:�w)>b�5,����
>G� �ef�Z���Qz>�-�m/HU3h�MW�~ܸZOn�W3��?�������P`t����NY���qz�H^B�#P^�T��g�$�*��E�mQ�I`�4�~v�9��*c?C(a�zZ�͎5�Ѡ����e���Ҏ*�pmJ(��mΝ	�
(�i�5��k_��@�K���B��l����on}�|�
r+*.]�����FW� ����"��U��x>S#���bkѬ�1�� �@�: ����ᚾ6A��=	�n�%ӻ϶�5g��ڴ�0҆N ��{���kY����k��]���&�L[lA�w]+}�e���i\g��@�'��]���d�*�(ӣ�����r�0��#<��:�*/�+�p�� �8��`G���6�&�rN�C����a�ɠ�����"�^�d3�`��{���~��?�a4����	R��W'��Y�^�@�k¦�M͈�f9��?���Pt�g�d�b}����t���l��R|q����2�<	5Qu�x�Z$��,�]�U���v��Bi���}֖�F狶��{*�}i���G$�Mk������[l˴@�k����eDd�X�*	���Ԉ7��Q��PN0�K��遍	o���^�.���đ4tW�=~|z��q[:���E�4�B�2"C7����״���i�Г)A��۸H_q�]D�h�����2 ��bi���A��I߷'L5����Λ�9�:А2\�o���QUQ&�@�9�#Bg��)�[�@iҧ�r#c�ZzX8R^l���@��������ѫh�l^$���>�n�w�BILk�&�T��)�`	����$��,b��p"̩J˰ə8�R��iǥ��*�3�泣?C��ʙ$]���+""/H�OI�T<s,h�	��b�A��4�T�x�| u�Yɚ?/1����Gz#Q��ƺ�TdT�}�|�.��J�>Sv�>w=��j�p��y ��U/���/��TN�os�H@��(�+i����B�ٍ�$�=vU��5���C`r�wB�?�����D@t������-�n*�{�xh���Ƭq�ҳ�<v2��=듒����&�$"W�ՙ��
E�ئiO�l<�k;��G�a�x���,�]�� ���l�כ���L��e�e^��X!-��|�7�-��<N�E��D~� #w~U�{��Q��������w��V	Gch�mr�Ð�$�~�۸@���
*���͍]�����s�����Z�p`l����{"iᬋ��.��;F��b<r0I���<1�Yۃ�K��������4�z?F#,��x�t� �qS��j�y�+�����Lsp���1դ���7�ٵ�B6�'���W!�=5�X=-���o�.^C�۱8Q$I�ͳ����i���`8u��i���w���$���z�{��T�F*���hDSD��[��0�Sj^� ���M$���TYv_1�a��s/׆��ˢu� :�hA�4�p��B���@h�ŏ��Ʉ;��"Ntq��&��t���	�-���zҶ�?�Z9H�D@�	(������En_���T#ț�����\����"/i?X��PQ �}�Z�}S;B)�5�ۑ���Il���p>2&f#B>
�/��h8'��V�1��ȝJ���G#�I9���?��eWgw=
dB雀�gP�>KǤ�cFI���<~�#~o'�I�E��W��2o���Dt^[����?�;I����	��W�<	~��Z�����i V�0���ɽ�9���x�D|�����d��S|�%���a߿(�N,��̼Zo�g[���G�-	/���q��N���?���2�V�7{`�~ɩ���rA�{�ݗ���M)T�����H,�մ��A��F�ݭb�"M�F�U�����a�q�°���w޴c�n�wP�$u����i�6@�O��Z�C=�o:����I�n��Q�º����#}�w������r�8�I
|��y�
��gΒ��;��_�y���Z�tw+�juk���?��*���7M_ �� в��O������q���3���͜)ӊ����A3��({��t�
JY��?�Z�3��45[�Eʉ9�M�e1k6����'v��5>��6�V%�!g�z7c�c��^�pa�yz�������Jz�{�/�3��h�+/��*����=j�a(�В����)��xE?�gE�s��T�f&sD�mZ	�7��_^\I�m�1 �J��Y"%&�����VK�;�Q��Ds&�uغ����w���H�q���@v���e-�xTz��m�S�L2�DדgU��?>P:��D�;/�Y/5˄�X���G\0���������9���W"7�6�(1ǎUn��*�Z!M���Q�'���7���T��H�gzUL�2"m�u��tŜ����3#�TT�b8�tz��O�|�P����	ӕ��T�u���f�9��sY��?�?�'�d��w��x�y1�\����m���������4_���~�H�0�.�Ш�9'�1�/Qs�j؋��"A%����Y�~�hD-�څ�^��@��{Ȑ=Z��e�RUm+���F����G�x�E-�/�2�pNL�<�4#��7MΨ��,��g0dۚ7C鯷+"�z�'�ڔ�;�p|Lj��a�nnݾ���	��m,j�+@��I����/Y%�P�.Z�05X��P��W���\"|d
�0/�m=��W�L���F�T<�0����*��h�$���'cT4�~��� \|}���N J ����&/)}����+��3Y21�:��������ů��ڷn���9)ĳF��s�����.�η�Q�r���Ɣ1UHx�q�?�Ǯ���E|w��7�{�Ȕ��ab7iW޼kWj-���ȶ�������@���k�)�AbXf��f½�����EA�
V�!Ca��j_�Z�-ǫ򺴬 ӏ�W�r�XŨ�~��+|��x_R����|ڊ�r��a��Ѷ�&A����/m�V�����ㄻ�W+��z̢�#�j��&~U�D�Qo��)$W1��W�!��[��{���t�j��@3�V�9Dk�gr_F�<>�%�b�v��t7��b
�W��t����f.�w��l(l�^M�׾��ȤO+��I��>�y��S��R��+�AN�"��ھ�.r�����:���V_2m�T�i<b����A��\ܦj�lxmf��-9�Yg^��g���w�^��LPd^    ר�#c�(�\ڜWʝ�9���ڙ<�>Q-�h�'����pd�\,�^z�Y'w1��V���Ș��|FQ�� ��g������r�-��h���[}��*j�e�V�A��w1�A��@�S������m���pgH*߉���f&�+a�g���̫�Q1�W���v�+�l���P�n�²h�q�&^093>��	�.��S��;F#H�Y��lo��_�h�l��A���r�;�X���5C���������{��ij�{�^|o�$�1)�>��zh˦�,�o9!�bZ���X�\~�+nn0	��}���D�6�p��D��v�M�m�~�~XVۓIQ�-��6J����Xx)`����vX=��'����$�J��G
�}L{��l?�Sq�:GP�q��J'�;n�;��A�f	�m=:D��1;�W[�yrȷ�Y�N
���=�O�|��Z�7�"�-����q��UHlN����QqѢ2IQ��yB��R<�
��(�}}GZ�$�z!U��;,6��g��/�K�w�;/y�t�\+V���v�>M4�i����~�����@�Y &-61ܬ4�հT� bsQs:�CV�m�3�34�t&C�s�1c��^�e 0�;�71&�$�A����ꝫ�^3ٍ((K�r��!մ�41et��N�pyU��U�4��WC�y�2>���<I���͓�^f���VI��i����Z��anFz�'ڛ����g]���D�#�C.������a��߯��ZE�MQB�wd�4y�ޮ�k�������ph�g�u3Hk�Tm��څ�ZC.V� �z�2ax��$�������fد����w�C(��l/�À�;ě��$@2�,�G2)v�j��J|�r��F�s6�<�+�J�TQQ�$A���y�ȑ����}#4{��jV�o�lVv�8�{�!dH� �u�yKy4�(�O���hw~��h}�y5#	7�P:iu|*���` �i^��V"��0ۋ�w�˖��d�>���\v9*�͜���Lũ�Ny��ޱ+��h���y0�al"�ºb�uJF+�U����4��i4m�飆"��)| ĈI�}L������S�`3D_���:o:�O���LMi�O��xJ�L��1TO|�>�u)����Hz��~
]v8������1�� ��T�b�����GĠ�~X�u���d�Yv���Q�~�llS(�a���OH�nv�4p���0 ��a��ҙR·Y�G���A�����}�F�1�N��hU)*�Dzi7�������D�E�����LIǣ���_���;�2��
t�;n�X��RJ6I�e��`e4�K�f��El͌��ȢW��F�I�\��� ��&XSpg��<>�"H�⧮R(Lsۡ�5=j��ĺ�OTu�Ը3Q��	3�s�@o�Y����o�����P�W�����Zk���gJo��9�r��)�_��≯3KpB(?����W�&��r���[���^Ž\9��T�M�xILE��t��J�' F���j��1�/f�w����}�^�B�r��:�X�0cB[��U=���4 �@^h�����6U��L3y 5YR�.�+O�x��XPtT� ������N�M�1q�1�r*����nS�&�-~9�b���1�3�$T�é�o�_8A��D��~�����j,�|��a�������Ig/}��֎��)� ��uux�vAw}L�*��~ߢ������E�\�h�:��s`_ʦd/��j>�"9���ׯ�����.��&:ʲHX�̄*��Fx>�->���`+�R`��L��J�T:*Ȃ{���K��8bZ<�N;R�7$�Z��2�� �#��;�`�G��$����pN6Y*������v�ԇ���Ǖ��'�!�hX際~�v�$����.��>�:�&ճ��}��[�I��/'|�ҭx�i3WȔ	�h� �X^/�mө8���fU
��Y�%�.�`�������eo�����tvu=�	�#?,Zr����3��|��x�lV3���@xY�ݷ��L���t�a��[k!e��)��ξ�����xnׇw~���{�h;�7��Ix�c�^�;��̹�8	xis;w��.	�S���^\9Y1(��B&"�B#��ob.���P��.J�+�nfo��ʗ�z&�EutnK�	EE�3���;f��L�0/�t�n��$�W&^R�ۑ����|4RM4�د3s|x!D�c`lKZ��XnW�7��4�6��
�f��,��{��;*���K���L����J!�)��*���%��`#�ZA�2��W{��t~�*>��54v�c����h�:�\+W �9>l>^+L��q�"Ahp���B��ӱb�>��[��^G� ��(|<a�BhXlk�biQ �7�E�W����6�oh�1����X?<���]�>�K�T����49�3ѥ�c�5|�bfŃ�X%g	-���d׈.Z7\B��>�:���*�$���^�̭�ŝf�P�9fƏ
s�!�����i\����Q{�R���0&�a�u"N�<�-��
m����g�1�@����H��2�̭8�H5�����n��t}�W�vv6�Υ}��e�2W[����������e�7���./oW�>���7VG	��;�t.�Es�}@�U�Ī���m��N즩
��e�j_���}�z������Y��]b>���=U*�\����7N��+��"Q��(�����t؟br�V~h4�Љ�Z~�#�i��{���$G�L�	�����E��P��j:m�4���2����'��BV�9�@�|b__��	Ї��P���D3�VmX�Jg���ˇ���A�J>9�\��EZ����枕+J��؟�����`g�j�0�)��'x�m��=:l!������\�L�;"�4�3-�-��Y���D]��� �hE�aV�a}>��3������
M��\�%ُ���^|����9{���G�
љ�����b�Ċ>�H�P�T�����"���:�oyw�֋�u$��a���w7���qZJJl�Ѱ�������� � ��<���RƖ?��l���3[�Ca<]�'�@�\�Na-����0���]'�lZg���"E܈p�����\�U?xX��ɔ��N���N�{���ZI7�|�Q@\�*\أ��9)�G7`�'������d������C��L������~z�6����|1;w����uN	RthL��D
8����ۭ�?�	�(����fh�R_���FX�[J�D�ֻ�0]���}kR�u}����(�B�����e�i̶��d2�ә.�<�&hD��;�(sv`�J� �&��W� ;�Q�n�?IL5w>8G'�d?Ռ�WJ$^�Eڄp��'-UvO�Z�۰{ق��^��@�����2fr��~�ȃiU;��H�dM�>w�4��%�~���Sd�䋞5b+P$Qg2&ݻ�e%���53m�9��a���q���@���߮���!�&�U�^���s���UtPޯ����N�\ }�٫��d��n@�н���4�Jͩ����	u�z��D� �9�5>��4R>��G=�@p�lC�``*S���nf�ٲL����M�����BZ���,�q-����Rv�� ��'�r��s2�ͅ�ַۆ=`ћ�I?�w6���r���UǊY��a�Ⲩ�Iޖ�}6��>��ɧl�[�^�8����
��Jj��d����>�ڹ��Et.��K�=�P���]u��;�Ö�}����GC���;�3u�*W��lOj�Wxlꪨ��+r	P�Z��t��I;�I(d�d�uh!S����,�`�2�x�4�o�b�&:�,]������Gz6~A���!_ڇ k���q'�/���z�8L�]�./�����{�T�ŧOK}z�L���9#.z6�y���8����gu����-����b@��釣�|� ����K�6S3��f �N�˼�H�
 	O§�Az s��F    {���M�m���(�.r�g6⮘b�#R���
�1�bJy��x��^AzFi�p1}��L9y{��[��(�<u�9�/�y��B��3���("+	���~�a6���ϡމ��{���q�12��½�L	J�%,�L�8qO�_���g>�-������˹�����MX{b>V�$��:h$�bv�M]��VXh?Y�#�T/|q�fy���Q���� ���k���n�f��;��i)yr�wN/��fx�b�� �)�z�y�x2����z�fN��پ4�og��u}a�(�m��*$msSQ3y�l�0�f<�:���D������{m��Lo�W��u��xuiQ��^&������5��Dy���*9i�L�nK1���'r�҉WZ�_o���3+ ��[�	
x�x� �Z� ,�gri珕0O����x���GHg�!�eO;<��3ݮ̠l�Ah+��ṕo�L��m�]�=�N6�B�}��;�<x~j����(�9�5i+�ʙq��7��p6\`�߹���L�ԥ��q�=���& ��8f��E.��Im��Ce��Yw�C���7�#�/G[$�����U��!�[�},lP�F��R�A|p��)��v���d�LW�+�������%\ӎ���f�Nx	�g��Z[mt�"��$@@�苛�ێ'�ǻ�[?d_��[��P�B�Z�#�k^ 7��M�[=�wk"53����y<t�Y��\�������Ů�Z(H���`���TL���XJ�@HYXēs��5�@�<8A�l&�O���?y�j�s�=���gQH��a�v���?�õ��(�f��@j�@c=+�H��3j$Ї?O�9�p�mC#��b\p��;�=Ɣ��IՉ�w<�~�ө6�yK�������	�.|��*XDu���n�UWe��y��ł����*E�|�Z�B���@�f��=��w�ٲ��ǭ`˥�'��n~k�K�|�6���g�҇s[�$uϗ�j���0P��;C���}�3WK��׉�\���]kjjH��7�J*(*�����N�D\x�;��&���4���u��J=���&��4]�ȉOVE�x�
}{�t���W�z�3�|�?߸�>t�cҹ��>C�� �ܧ�mv�����8ʣj/��t�Bq F��v��el��t��C��Ƈ�Ѧ����x������ĵ�3Խ�/���R�/�l;�����]KJ���WE���9'���O�?�'q[!Ght��
]g���
Y�s&:,~9>4�/�9ܡ<(���6:�� t�l���*������v4,p�t�c���:�"	�� ]r�X�S�h�P�@0�,���u�}��?/fg�z*yQ�����H��KŚ!�\���8�ٗ�Z���}�qA��Cq���1����^�95y`�T��A�:/V����:BS3��̒Σ���[��[��&B|�U���@V�.����g��Nm��u��	K����)��j�c%"�)�'
�Y��V����f�$海P��ɴ��D���%������z�29����JMl�Bb���~	�����9��1ĆH8��7s�� ϡ����}�P�&E�#����4�`�MO����$zk��Q=���M�t�KA<�̴�ʌ��
5�\�=��*����PEUUyr0�<�W�;�Tte��j�?���d�^͐����[Bľ]�#�� T1?��ju����*IM����)q�߮ah�L�&�;k=�Ѵ�Qyt�	n��ʆ��> }_�I��5��z�,�7��r�V��4�VbC�PF��P!@UԒZ�T����eQ�I�Z�.���O�h �M:�_~��y��࿂�&��U��h�vi܃�#,�d?P��K��K��9�!�����c�.|��$�S�i5a��� "�WY�zs�c���w$%~���X2]|�.@�����|��W���T��A�צ��D*Ay���厪�N)�#/��6ݧ��s�sr`^�4�(�܇���	�*�${���,�\�����="0�?6���o����O$�Gcߥ�n!����w�9���P�c�@�-��k����)���m�3�bi�Y���kF�z������Mn?��Qq���G&����E3�Q~I�- (�����^_)vҼ���(�Y|w�H�0��.�#���*ui{P��Q()q�J�J��{�3zR�p� .����T1A��#PI4g�0�e�e6(c?"�M�u>۝ʛq����}�sy����ҩ/G�1ދ���K1�4��:�j-�I���@�^k���c�>n���˜�yٟ�N}s�y�?\���m?%�NUU
9��Z��l�|�Z�/��2�����O��ߤ@kb��jo���|�9�ݐ�^��T?�٫b2?����^���~�K����g'�n��Δ�s#+|�kFj�=˕���-.�ԵiE�,�^��$x ��j.j�7/O|��zZ�B�GA"'8 �y\��8;�jӅy��!W�/����x-�/VW�4����w��B�"`3������3����WVu�(�N��x0qe�ўp��MzJ��(^0QpeT����\��{5�G�
�Ęa	���t�T�I�.T�L�`:m����E�<W7*�a��Z>�ȣ�Nբ�|��^�$��֠k��^B��?�:l��ct1!\���`�\toA��x��F�y;�E�cG6IYz�[���N��Z��n���i���:�AIhܻ���L�̯nA���/^?X���9�r��f:2un���S�c)uF�^��g=6pu�2�~XR��I��ROcԴ�bxNh��@�"�O*��K�W'�&{��]�]���������3�E�Q���X���4P���W��9���b���d 7�;j��@���;	���E��S&��^g۩3G��"z�H�7�!�j��a%u"Ҹ��aD�,������LE��A�0�� `�𣮸�mQY{�iA�L/�����1ţ��%1<r�͌~��^�o�2
��������u��yPm
���i�L�E�WJ���������蓖uN������bK��SCmRrWF�hUf�y-e���K�Sl�q��3Ƣ�#sѐ��ssp�*���N�#5��4x����_w�F(�J7���VR�����SU������0��R����|������YNB*3���M8ⶒz��jҍXW��=�LK�B�O�c\r��T`OƝ�c���$]c�d1��y���POz6�7����a�
xZ��;̭=���巛�~�~�r�Mn��6%�� }�P�B�5�<_"@%e��B6�A@u��ᤍ7u�w�|�>J�2' �*:�/�{��-�i8v��>�O�Bw���!O�� A�$�ϔ[�rv`/�SjQ����h���/S1fC�ڂ�sU?�̏���s[��)l��K����}l���g�Y��i���ҙP/7�-��/4.gگVς��D/cN���D�����j{Z)��M�uC�1:�Y�e���v����ܩ|F�������9B%e	J�Z�w��ӌ�T���!f�\}i�#Ώ�5���ti��Q�ל6~����l��)ĳG�SZFY5��/��*��J��fw|����4)eΈ��,E�Nw;�H��qq? Ȟ��7����ϙĒJS�S�G�0�9h(Oo=g?�p. ��z_���8������ξ�~�M��Nt���j<
�A�����Nᑎ�P�g��[�^}��P4%j��V3#]��f�e��a��4�W_$iW� a��I��s\-�QL�#��ae"��|�Q��J��!�p���h��������fˮ�k�٬�����=�sT���5���S���r1�,����'�4	��;d�vk��>������݅HT�>׌�	8��|���v�_~z]���"'����В�8�Ɨ���oƯӁ"�T �MT��Ye���B���neg�JR��
��2�ܡ����cnR��=0�j�{"?Rܕ�~�T��/��`r2r�2t��� 1y�-&݂�)����    M�n�LF�|��l����~���S�P���Ŋ�8»QT��x��-~0y^��G�/A�,��1� [�W�������)O
��c/IF�+^ej�#X�$�STFj����C�Y�!��=\돧���Ԑ[:���y�~�HGo:z�@ �t���nP_���{{��1U;5�P,bz_�.Bc���e�L��E8�7+rs�>����f��c]�!9�Ȯ�*߾``���&�%H�sTR1<?�D>�rx]2�A�2�5�y%�T�1qJ��ҙh6����f�I��9L������)���8D��^����N���K�LF��V�,���2�p��I�A�a���� ŗ͘<R8�u���t�Lz� �����	a��	��[	�'�L�Y�&��H�$3�z��c#���v��v�����g������3d�XPO�6&r>�b�?�W�Ų.�����n����l��+�}��i߀�gR���_s3��@֡���3�H��:����S<hE���Pׁ�`.�Zm�iB�x��xԄH{�����4��� �=��f��C*���}=̐��ΰS�u���2�﻾�n�laaմ�cп{��� ��z�ЖL��ا�ƾ�znO�f��J0]�+&��r��7�"�� �Rh`�R�,fKw�uaؠ7ଏ�D(	�}�K0ؾ�J�n��9of*����Æ�ݤ*t�{�
�Zp�Z�;(���L�����PV��1a
y�-���lO@�����X"�����7c~���"��麜�hvN*g�v�R\���槻I��W|�O��@�/��U�+�k����n�bb�^v���j�������e��s�x�/�,�F-@��#�m-}����2�V'rȬ{ana�%�K�8V	�e�}���Pjű=�pY�w�CF_5����\�\z��0���0����j�N��v��1`��_e8��N|�������tM��K��x^���?�n�M�d�+D@���vs�YF_y�SA�/:~7���>�:��+���U�&.[(�����mD$�d�;ru\��S�]�s/�����4_�T�L�LMPrx���FG �:����Z��k�ޛf����S"���+bWi����9K �x��:���m
m�)��Ϛ�MË�J��_6cq�8�(����"����e�]��@5��x/R���t��k��޺%�?�J�g][@1�E���ۣN}�Sj~1ܨi�ǩ�u�vb��=�:���e��rd6�n�������^I�S:X9�eX�tH�9~� ���@Mh?����tFc#U?�G"���+�Ӽ
�5Q��-a�p�N�FÜ�~���]�N�<��q7��Q����g]
�:�:�:�,�ܼ[�殡���S
�;�SJm��1J����-���/�l�ϫw+1Itu	?�ǔ���C玒����p�$�:`J]�]>�/<:st0{�>C��)��6P���1��"��|ձxv���1�~ƨ�2╘o�O=�+1�c�0!��o>���on�yP��=��U7�D ��Z4���?��*�9�"�s��|�T�eB�RBNM�\�
�K����{��]z�^�LH�L��R�~�:�s*�i������A�D|~�/�[�?
\e�.���m5ôS1轇֧h^�L>�m�� ����t*^�J�X�ϘO:N��R��з�~�v��V����E��+�:�%-�̤�m���D4{�cܨ�WXz�͐R��f~��&۝F�O�>�χ�}X�Q�*~�8L2�*(v�%d�L�3ͻ�J59{�;�m����G]��+n��I`���դ�NQ�>�++kX'j��J����3 5*#\΅�v��k_@a<��YF��}��eUa��2'ǔ���P�б
n��In.���L��ZT�x,A�~�ݗ�X���t�⶚	iku�pM
C���{�6�J����P�y��w�O��� Y�ٜի��tQ<J	�?^��!�(�ؗ [y��3+�Z|[o�}z�u�,:/��9��0�0T�Lyl?��!�R
�<�ٓ_��$����)����x��}6��h#��;����ƅ��Iz�[�J�O�ӵ���4���߄��s�q���(��$r�i%x�bs�Crq���k;����b�0A�T�H"��Ԅ_�������3�]Bg����?{�bd�������>��)�>ύ�f�,��ck%�٭�@���G�h�~��J
�?cd�˩�̶���\���G�)���d�a��ŰlLژ�Z��O[�7��|h��Yy�Ο�e7����z�zWK��/���m�޹ʛ�(f%^���yMOf�Ӥ�~�^@��n���r�WI�{:"�&�MsN�<���%ƹ$�Ib������8�#w�fi_������]��B~r���h�����{�|�ws>288�yO=V�O�u8���evu�)\c۠T��Z>���|ݣ?���˒�O�1[�i����^Fo��/�T�hd��cB�ƙz�doU`K�U!UG���_蓐��^�h��>~{?^[���xw�_�T�yy5�J]q�[��پ��ՑD�$}�u�/JAL��a�^ċ��� ���#�=tT����N�s&3u�]9a�^oߚ��f#%G�{�<.I�=ׄ�ߕV�4���^!�T�7��\���b<Ξ"Ny�e�#l~��ge����i�k4bu�4���J�"E�X��s@����F�-I�b)-o���F�|��Ua�Ha�f���p��
��r����=�?p����-�Ȯ �cm�!�m�f�?�_A��v٧����0�<P�E��+;"��$��M��x�v�N�|j��=� ��7��d�>]��NGOC��.9eׁ֖���������ӧ�����XxO��(�����:
���2���>*�^c�+4�Ò'ήs��%Wpw�R��\��:�.r�e.�C���t�0 \�WB����mly�G�g*�pqʒD֚K̩�{�l��@Y�����+c��lSz���#>�,�R�$��;z�&bH}s���o[���E��N �y�>4C�����	�!Jl��5s��[�f�AyGB�i��w��g�$!�SA��'2_n�l�,@���`�A���u>û8�r���Q#�"L��S�D�9�;�,�.|š����\2'�(`Z̤�ŷ+�:�6��*�mF��(����zZ�l}��������zd� �r̛�9;#5�������[�oY*׿ؔ����
o��o�u7�~]��w@�f
ڭ>��X��F5�<
�]pz���	r�9�Г�c'��ET�u�G�L��7������R/���q>�`Q����vP`&�⬦�H����ТX��:���H��0��-(�$ӛ7��s����zd����Q؁�[��ItM�ْ>��O`)Y7#uv�6��O�N�o���d�,�	O^$I1�,�!�-�>
��Y��~i��{�8��:N��~���?	y��!�/�����ù0���C"�`��}��d�l�Ǘ��3��P-i�t�*����o.6�dN��8��r��"!��U.#�8S���H7^Ȁ�R(t`q����L�+y�يh�-g����t��
�E0���^�-���8xxڂ�w
\����h�{,��;� :�YX�6i����W�a��l�� �qp��. c��q���,n�qȚ��F�o�`}_�dH.x��i�t��E"����~���9K�A�j�>8��k6�13����7/d��� ��p��[��>���<X�\0<'�0��K~��x"���M0t�*��|�c���#�e'ƒD��IP��|��`��p�b��H�p�"���	��6�S���`K�����3�o�\E��xp�,[��W���������zZt��c0Az	�j�愳@*%Qn*`^�w��4� ��Z�6�7D&?%��ݭW�5�\�e`v:;(Kt��6��yp�Ex��8;E˲�b'zL[nt�|�����E�?�m���s	���I���h4N��ʔ,9�������T����	�f��͝䜩��<��4��\&1���7h�xp������Q�8���&�Z�Y�ǰ�c��    ���"%�[��%l@��0���F9;��&Q�'�LB2��n��SHH�Go��%P�\.���-�"Z��5����8;П�����Δ0��%j���G����>,��U��r��y�Dྣ��Sz�]�1wr@z���|�y#�݆�5�dlf%���V�q�'���p���Х��t	����pҰPxr.�J��]Kua�rlڰWI,�t������kT�^a�2�=
��1HU��I�	}���,�:R'��>Ϊ@M�D ^�k���5�`�\�W���yf+�~>n�-&���C��Q3QB��_�j�Q^.�s�R&�j1�;�=�� $0�pn�ϛ;���絒���
5a.ޟ�i� B�%3�U>��PvRg0n�Q��g�P4� ����:s���V*����̼�H3p :{�p$��b-\GZRl"�m86J�C�M����)E2oJb�W�5g�Ҩ�!���^q<k�:[�k�l��v ��,�D���f�]T���<���q�g�m n-�z��"D�[d�I����� v�$�>�~�X���~2CJ����,H?���h*B"M���z��@2�/� �ɋƍ%��B�R���ǳys�q�5*�L_\�
"y��`���Q�O��E��`����{:�*�)�	v�}�k���>RD	�e����/dW�q;d���E%tߠ�4"���o���c�ׁ�Otũ��Ģ�F�a�do},l㎦n k� ������飻f��ޱ�(�t�(FPSj
MKc�&���Y0u{Lxw@raM���ݶ��SdM/K��Ώ�!����Ym
&��G�8�y8�yC˝^p�Ӿ1�l�lc02����٠A�aM����|�:,aD�j��'�X󶅗�k��k�Ľ'����t��j�n�q��G���C4�ؙ����C�%�\�NT�;1�ЂUX���p<��˨��Eo�R���g����T��L,t�Vzd *�&v�ۏ�r���p�^�ʛ��o~)�6g��{��bԥ���U�ÿ1���Z9�Ң��0h���.8�_	{�g-�2��[3���s�;�M�]�� Cq�j�I�*��i�5��e�KB�BsŇ��S:%�oZ���v1g��ݕ0�����ua�WE��s�4��0d<oX�QAKkMF62���x[�H�S�=��3�Ѿ?���2�'��-[�v�.�
w��:K����-�����}��ݲF��sK	j����gv��X
�'�+�ÖS���	{v��ڴ���|{���p�r����5�,z�Zh�7
��y���$q���Q/xd�9�����4���K��P�ܥtlu��,MD= @y��oB1��_$lҩ�n�<�/�$[���ݧh>�r��(`{=]�D
Zv� t�?J?vQ�8����F�5y�>d'�ٵ�\�ST��.�#"I���>+����h��)F�`�A�h�K��G�0�����:�u���n��(<BkpΫ�T�a	�^f?��tNP=�o�J/��"BnW'j�n5X[�su�r��Տ|X�]�T��e�H?!/�u!!�5ѵ��ىvV�K�A�:Q|�,w�����'������;����8� �fɾ�o F���߭^B۵h?��^+vh�Yg+�edg������,9r$ٚk�)b7s77�e2��M
��&��#�jD"�sw`6�����v��|��祥��%�Jw5������9���C5D-�F�;����N25X/���ߟ>�%z�8GM�s�Еk+��y3*���L��^�n�vmn$�-��;�s]�aE�ڗ^��@R�5��3%	N�i�( ���6O������S�D�0�����8��d��_���ǃ������gL<f�������y�]���d���XC���Þ�<V_<�d����֭�.���A�����馘+S?�����|��͵�6�TK����M�B/ʜ��b�7�˨X�`A�WN��'0�1Y��_w+wrd! ��^ҿ~n�6�Fxvп�>���$��þ��
߬þ��]@�G_������X��f�ޟ��F)���.e��Cvl�H:)8�x�&m)[��$�GrjnX����t���-ժ��� �M���~�M���6Kņ�2��V�I>E� �V QO����*ޱ��7x�]m�i��Q��N=�i�=�N01ErW� ��=;�|�� �u�?;���f����������:E,^�h�����^,��;L�
RB�XO��(����fp��j_M9��
-i�O{N��B�|'o1ܯ���O��o*��Ԁip\]��["� X�|�?o��"��;v.�q[1>�I���z�bI�sV�2�0W��U6.Y	�/��v ���8cG^d�l~��e���Px1�Y����dk-���I�Vd�޳�s
'-���аp����)�:�k���s/���p	���������8��֍K%�N��H����3㢞�	�a���h�"�$O5�,�A)����%�9|
��FZL�t�yA*:Y���w������ZN��?<G�x�[�N^ 7&��p��;5��F�J0z *����ģ��@N�,��M�\B�a�\I�7f(^���q�%�LX��4%�3�I���nD�!��s����ы�U��'���E��c|�������e=��V�׈���i��?R��ojn�������� l�w57'��/T�2� ���턳�.G8S��	�(o�@�zM	G�b��.-���a��R��f�Y~�,S	g��,;�����/�yEU[(��9U��PZ�%h?O~��G$�A��[�N�s��0(�b3����%�7����?n�a�����X��pG(���� DJ�,�(�)�C�Q��h�˞d����̪�z�N)Eu�7�i�y�l���O���gn�I�0B,,W§�XN_	���sEF*
���v:�R��Tw�-	ٮO��r���E��z�W��1�^j1���3$dH"�~o�%d�������L��ԉ��H�L����|{:�7%NM��0*�ׁy�WC���D��=��&�m_w\8#�y=�������"7K�ԏ�F�{
_�Џ�<��>�$d�Ȕ換���VJ��Q�3�Z��7IG�ۛ#EGW��^�Zr�^�)T���z��W��ڧvL8 %`�!@t�dc�YBy	�?no[\И?l>�
�΁}p�"��f�W�JpE��Y�߯���ZT=.'*B�^���\˛��7:V���0c�E�t�eF�U�[�%%���H�߯�XJ*�h�r�� ��9;��"h��^�0�٭C��P���b��/K�z�5ۂ�W�d�A.O���@�F���ƍ�R_[
�POAL�P�	G8&Y�����l/��^���	�/��ƛ�L_@/� BJ2�#P*�h�N0*�~� �9%���\�x�U���elS)���w��=.�?�y������
��n�;���̪)�i�p{X/�D>,�N�$��U+�U	IP�������ʭ��"\z�"�Ζ{/�j��\ٍ��)�ִ/0�I������D�3!9��ɘ5�gf#쯾�A�G|K-և�ǋ~����va���h���D9.;�G�.��)��a�9/��3���*�5J_��R~�M��M�Hf����^R�RSGHd

�a�-���4��<!�9R���t>Sܯ0��S.���b�ij���&0v7�;Mct��D�%b�O����{�Jļ۾vW���J)�Ѵ>,�u$Q�G�A�DydJ��Dl�M)ǶeF�
������J��3�ӳ� ~�#�mѥo{\�	�+�	�Q�]��Zճ�I�͕hn��zk��4nT, ۯ�2�f.�ѷ���\�t�/��L����B���@n���f#�e�?i�~O�49_������$>���C��t��hW
�p�ﯦ���e}��O��ʩg����A���y;��\
,Xj�`5���~�<���C(�k\
�ީ3rB�x�����Ԍ�	�M���MK�ڽ���L����i�waݷ��y��QW'�s�wz�J	�������    5����4�ܪ��S�=?#�B*���� �fJ��Y����nl-�`f�����0\�%�Bi�G���Q���!@R�0W]�~��q��\m�Y�5�|[�d�/n�6%h`nI`E��-�:�^q��3F���I�z�H���R��p�u���)�.
�RK�%wv�|4s�TX��N��5Nd2p��PNN'�V49}~I��]�<6h�Z\�}uX�B�u��/`��ʢK%"� ��y-�;U=PU��P�K���j��P�Q;��}.Σ���4\L��ͻ�좱��A�ڇV�Q�� ~ O�	�9Y����_n�O�;A�B_[:*��������b��Þe�� p{�[�S��G��6����0&٣�x!_�$_���
�řÁ<�Ȳ��o�� �
B�a���p�)0W���|�1��;���s�l�����ޛ��Mv�˳�9 �D<3a��UUxUEu9��ܞ�0�.�Q +�3�ϔUv��	ƀ��K^s{�A�i��is�:>oc�Od�ufs�y�H�����gx�:O8\�id����ϵ]xb�y� W��:w`-5N�g㜱*+�s��*���x���$�5������+[�r���ȾI���ڶ���EUQW ?H4G�!���y{�=U�vȷ�i2��WM��ŅW$���xx�����c
h�l����t��u�,�s��杖Hc���˨J��GvJ@�r[�=#�WLf�����`I:�!-x ΒF�o��4e�e��5PTq�����ѯƙڹ9�eٜ�-N�%^�ĸ,�}�St}䖚%(�@����}30f�w]�Y�
�Qv��p�9��N�4I�-���Ie�0I82��B�">m�獟L��no���1��溞Q�dx�<�����Z�竓{!ѣ�sq��mo��ds0��u5c�D~�jee<�̗����j�x��Șj��R���U#�Սi�w0�{��¨jZ�z��g�bv�<�_cbqJ�3�!�R��y5p6�y��)ʃ����T�ųֺ-���xL6@�ѧ)1��a�����<u�vC�O˽PZ�w]�k;9���S�y�n�El��|t�*i����\��ά9��~�(���?��ǘ�љ�'x���}�e�j+�4��n���3���k�R�`6ZvZ-y�.��f�!-�=���ߛ:r��o��k�ଭU�]���� {)�"Z��)7D���k.��E�Կ���uG-${9��o�
�{��_�ys�����P	GG�i���o���>�#�c�`V���v���Њ�����ۣ[�}d:�[�ThR��6�hG.>�uM<��2�P)��6�d�WY� �B8/�~����IEU�:�g�UX�+��������xHcu�)�R�j�RC=��5A ��=�B����y��Y9����_�b.Ku[��}���]?M��$S��e!t���^�&𦨥Y7L�f���ŭ4�Ͽ�Q�����	;H�0�mi;���Vǀ	����I�	��r�9�����Pœ?s��pp)>�&��^�gǩ���H� � b_32b�Mb���{f�{$�u
�����}��_���E�EB�%�zx7	�ޞAk��j�i����T�t�[:G�ҁ������>f�����+'<�h'�VI��m���!�$��X^�z�Ƿ^�o�KM�����u��\Ԫ .�|e��f�u��w��=!GC�]D~Z�����N7�i���3��N���H��'�� �s�f�z�tt;��p������M���̔����Ȋ�6����U�a�\����e�D�E){������\�*��jP�ySo%�����	�3tq���f����Ƣ.�^�����j�A��y��&�g�֟׫���>�K��޻��8�����B̜��
��Ʋ����S��a�s9�+ɽ"ypT�
c������u�����l�k�'�����f��9@����1�4P��5|p����U�)�l�:Zʏ��Ď�,҅Y�9,f��`Z���o�vX������Hw˛�x��\����߮��s6���a���y����J��OS���u���K|7��b0U���pF���kL��x����^_wYW�m��_��jk}p��oW�0=h���U�%���z�%G�ٱ��Ic����L�>q��K�!<g�2�̉
��-��[��B��ij���{�:����N/X\��Bqr�i?	p�P?�LC��1}^�z�� $l+�[�	[2���Ϝa��5х�����Q�7z�YՆ��Y��N��O���c�[�H���CT�|��h)�(D6�O�%-����ŅD�=
���#q���7�Œ ߃_�Dl���(A:�Y��Z܁��g.K��jn���>���X��J#A()_��*�U�iA|Lc�Ykd����pCt�/c�E@�~W���a�z�#������u��Am���I:��&hf�;:�\�#��(���XOT��@m/۷ᰜ���u��fp��y�ZҜ���7�Ý,����P?���>s���
�ί^�z��-^�U�h+��%�C�����"�I�V����~��'��#��k1;h0�,R���~�Tہz曌�W1%����(l��ޯѕӃ���<d��I�J���@ �f:&,���EG��}C�L�F��4~U�EF�_���I��{����`�zS=p��F�H���z���x�X�g���7���������i]8����A]%�Pg�b�dB��ST�-|m��]-ƥ�q`+��L���UYa��C��(̌���a-�Fp������5�l,JZ`
�~x�ݚ�%Ac�SE{��FأЁ�x54ƨuӓt ���j�5���Fh�W���l�/�f�FH��/����X�  U�v
C	��Vt�6��3@3Z�(� {���$櫦5�8�Y�P��d&��s�j�{|o�'����*���HAc{������1�a��pா���a��g��wZ��������u��Aؑ�u�;��U��,�fY�`sO�Yz~sM
U�	i@�VAe\������v���n;&��Y6v�-��s�8���V�7_:�(5��@&;��(Rg 3M�1���>���2��W��8ٽ�D���i�زjR����q��+:�i�!`0�+]��4�O��Lm|��߸1EE�i������)��UVM�a�v�R� )�#���p�-�!�IK#�)������?�l��Z�֣sp�|�ұ�����C��N���|Rӷ�k�R�
'�U��.FH<^�j��|a���G�W Ag�wmՂu3R"A��w����o�z�U( �a�N��e\�%5 �X��q���U�!��В�Dt5M�l� ��}��&�|�l������3�Y��Y�y�� (P$����P���vu{�M
�[��)J�l��~d�u�(����W2�#���$�='vq�&y1	�}6�HVȔ3� P�h���AT���2?=�%�At�K^�2�EZ�J���R_�����������?�Y�ׇ���3�;�b$�z��OqG,%3�:!&�et$M�	�p-�wo�~&0���
�U�s]���NCe����\�23��j��ƹ�R#����L���t��CD����a�o�{S٫O���|i�N~�ЕI��°I��]�oTr���a��ct�����&P�EB��#�/j���	6�6K�� ?d���Hf�:��W]�f�B[q���qv��M�B��ln3�k$��G�9��JrFo�ף���Iu?qu#t�n��\"f?�/��ٷ�Z]P��i:�3�f?m�T,��6�"ۋ2�@d������04����z�L�L7Ò�����n?ۖ`��l�,��P7��߻~Y��Eeļ�t[�eDR�!f�)����/���֗��}�-Y~m~Q�Gyȯ~/�^�U0��	�Tmd�80R9��^c���?c��!��V��k��+)>��_��"k�)b��7�{�,׋ڜ�޻d����C�ƌ�_�ж�h`(z��E�[W�s�h `
��Q�u��Ṟ�3g�����b�3�x	z> �^    ��^�R������:�1����k�E��*�K���>�ڙ�	>L1Sr#�' �,I7�h"�g���ҕ�pn�";8/ɳ�ր���9��Q����!ڊ-!G���tX�����,%:��u-^���!�7�Lk�k�nP�%X��o~5�D�߲;@�CE^�Mj7�[jɚ�a��	&�����:���R˶Z�S���������G{''���H�nk��8���r*��5ԝʑ&2$j�Ay�U�#���u�{�Wf�~�M�I��-�Y�(�ֵw.Ӎ�S�#�+{��Ĳ��PC!oK̣�>�5�\�b�l5�;�$;I�#�k%���XH�ms�/z̻��e��^���p��a~�iG�X��N���i�����la����=_~ӵ��Ø#�Q)����W����»u+�t��~�btڌA/��Z�"��%�U�[��4�(d\�����Y��e�5]��LG���_3e%��9Qл�Z�Q�p,d�Q��s��42��6����)9'JB���"WO+��n�A�Lb��F�����,�7�K���� @w�< \���m�n������
�;�5�G!6t���E`�&5\P�@���mCw�ePe�XAT��r ,_A8	׃o��ԡY�NpqF��T��Z��Q�];I��hz�����D}]�Q��f����5��}��չ��žj�n頇I�7'Sȧ�!�0�мm6���,�}ֈJ/sU5o�+欋����D}o������.l&��-����ɞ>��>�ɿU+��T`C�}�	@��@�zj�]�������7m�Z�P��������J�����O�8kzy(x�f����n�؜����ܮ�
��|E�$����Bu��6J6��� (@�����ON�2���z=\�ƶ So�hfZe
s���J� 3�O���Ԣ�L�}�j�����������T��q�:U�?Sg^��?q�B[d�lZ?�Z�˨ր �{s���X���w����c7%�`w\�&�n�r"K�ͭ���B���$�i9�l&~K�� �K��z��-k��b����z��L��D��ęB�����/Q�]1�X�}�$����:Ȯ��#0��߀'�!x��c�K‖Ky旻�=9tϒ�^ejg�c����X|�w�X���S@%��\��c�x��>�fy|��wG����8�����Dч2��F��b�9F�!N��_��Ƥ�W��1��ht�@�k�W��)�_OS��bK���p��f���h&N���K���g��,B�¬7�P�(�����.�7H/]X_��/S���j��~�؍8�$ ߂��?��wk�;`M��:U� �J&��Hٗ!L!�t�7�r-쭩ܡ�T��S���u����u��|:L� �@Nh���ۧ��u�dus����^� Z�IE�����J����mBU1ʐ��]�A�܉,�:��U$H���AXH�V��v�e� kzh���ߦ���S���z�^��x˅�z��2��I��s�z��q��\���BԦS.F��dp��.�渺�l��I|���CsH �luW��7����-55n���B��T��aW;�j�1\��J�t2���I8��q�t�?�R���`U�b�O@���_�D������alt���^��U�|�t�Q.]�^�pm$������S��Mב'"�J�������׻�
�'�
�{�i�0�/�)?oC i�s��)���$,M�dQ�k~(+!hMh�?�0�T���U;,ʢ/���,5��|6U���5���]R�S��?��7����*���q��� �΂=��_��a0$6^(�<�ֶ�� NZ��1���~���4�;�Ov���v����i�y�j<E�̷���ݬ�Y�� �bR���n^�kw��+�������'E1����ټ�c5��@)����p��]�!�#F9�^^��#����i��ތ����ղ�e��t-�wY,Ud0��� R8��{ ��tKg��3' 4o����j'Oj'YZ5�G�k��1I��1�8�O�C�zx"*�T�XZ꒣d�k�[�|VZ�8	��~+����'M`f�P����J�خmx� �:&��V��׾�PW�n0�zzuH�:l�k�K��/�������*��թ�&�uΫ���(�+ɴ�iM�=�s5]��G;NX4\��;�>�EL�&e��۸!�+D�H����u����s��K�pt%*�@O]>�5��7�_%�<�,Z`>������k���rt4]�rQ�v 1F���E����=w�����@���#> M�Y'1��z��B���TҤ� >-��(���"��VX
bÜ��t�͐=lm'�	�J+�[�F|pp���z��3�P��w�h@R8}�t��,��OtD�)�(�[�5��~xA�ŃS�W��k~���-/i��?��f`�Ϸ��#�:��u��x��ߝo�o^�O��� )�Ɠ��A0��׺:-]�;�%�V��o��-p>D��w���`�됭��*����o}،�ߊ�vuTm���G����lN�^�����q��p0��Hfw�\���A7�|ʕ��Q1��f��T��HUa׹���/,�q=ru���0,g�x��;P����xgQ�Z����5E��B;@��TT��O���3"B��a���%��,�]̳���<i	��3����co��K��~�M�wZ�W��z�)��'�Tv� ��I5{��^|�vg6^��Gd�{�D{?zl�;e~=*�jfs%������4q�I�'���:�y�F���$V_�l�BN���,>�����xg�\ot�+�N�=�E<#ZO�ۘ0��j��K�u���<ű�c�����|�%J7l򡥹v��@��w��$���FlA *��� �(Ut�!�A��2�k��xs��;e�m#��^d���25,:o�
�qER���	m��m\�֭��.�Q����2�#ŔY/�@6��.�c�9qa��ڥ�X�#92n��O���ޔ9*�XP$%�m_T�Gk����n��ʧ�-�[z�>�SR��0��
�?pq^G�v}�Z�ӝ���r�i'+K�[���Jn�K=���������ŏ�J�}h�/[|���� Sg*ͻ���+,L= �gH����p�8��O������l;r�8Q1.�0�se���c�ZG��9@�g�����,�$I��,e�V�L�)�����j7��o�*ep%�U��R#����0 Ǽi/���jR���*�K���g��%<H��Y��O�Q@:,��G
;��49
�B�g\Y̤��R����El��Z���Kd��H6�x�r�Q
����|�L�i��M�IU^��Ìs;mL���P���;��F(�B���5��&Z�xB�e?�>�<�E�S�z�����xʣ�E���P>��{��Z�R{$"��O�WX�+x¾14���j��^WF�K0�V�g!(���h�$<FDA�X�O��d`�%)�8am���HN^S1$3T�2Y�39������៴=4 ��oH������`����7q.�@�t�������6͖j	@��v����j�$�S@��E_�"��e�	�8F��
�=mw{?J��%�������F���|���O�-��@3�/��w�~�~6���¡���;r��dX�7	���i�$�:��h���']E2��)�����(i"�ԏ �����ٜ5�J���ya����d�������ֺ�E� ea0�\3�~��Y���񄈽I�B�M���?Lw1�s��fzƧ`ZU^�����_$�E��eqŗ������0C�d�0�%=V�֦�΃��EM��Ԑ�S�%E֨���m�U���ʽٺ7�t��)���j���rw�D�r������P2K��Y���o��O*pe�T_���2���M�-B��L����wu	G2��g��m���4�w�������ۇ�C�[T��I#tOu���I v� �����-c�+*+Tk�_�ԣ%y="����.̨&�
�7���%*?���?)�Єm
�A���8�%_OlV}8��    p��6��Aby>c��Nت	�	�~
l�yk��{� k�6�z����ٻ��[SD&��Xy�`O�o��m=�#��w���2F�ⴝb?pg�1;c�"�L�&�I�l���4���&���3�C��?	��O���$��o����a{ۆye���8����?�u^�ҙMIt�&��J���y�b�T�;\0�`�o�%"ށ
����u	�
#*g�l'Y8gF�E��O�ę�Q='�F;ꁮ�*p�Z�j{.x衱x(p/�E j�5	����}e_�7O.K��z�Z�&���G�Q�U��C�u�aK|-����%��M�n�[��ߒ�����!�*�	BJ�tV���3�{X�z|��m�Ox������Ё҈��V�}�F{pRw��GL,����ɗ�-�v����4���G��dw^���1i���ѬJr8z�@g���H�����ة����7;���N�-�4�^��k,s���i�$�f D'J�V�1q���MC�M���4�&$aKfUa��<5y���z�;=�n%�o_�j�8&ŵ�{g{���׫��z;��*���ߜSR%ĥ**�gT�
*���F$��@k5^�Խ��Han���������vS_d(�0(��byĭ�R���w'ʲ:�W�-sSbGӡ�Fh�8��D�9y-L|�Z�%��Sg�B�7D�-3^���?jC4b%�0$�Iiʱ[��Д=�[j�X�t  ���fr�4��EkPj��0�T=����б]mU�[Ort}
�+��VFR1_�ӏ���nt廸�A�0|˜_�z��OH+���b�m~�*XZg�Nl����������Iu�E��G]�9��@��.@�|Rpa�{�� (̅0|Ԅ�w��|����zT��/P���HL�z����Ͽ1B��/�l B���]�$C3�yCi�=hU��Y�Q����ֽ�U57�C�%s�}���H;��ic}��v�/��2��a����^KA��-�f^�d7(]�N��~���eY�#s��ǯ�n�Zk��&uG�x"Hqߚ�x�C_-���ګ���疄�dFLE|�au{��c���w,K9��Vߞ�
��9�5Q���O1!`TK�y��"TG�(C31���:��Eawn��Hdu9��ޏ�ah'yz���b��N-^�<]�xd��L�k{7�;���-�s�b���ä���,�nr�3��:�57߆��s�|&�e<��k��S4��XAt*�~𫱘F��$8=aQ;�訚��P9ҰM��X�t�� ���/;�(ȷ�f��9��E��g�_���dbݶ������H���u�����U8��w|�����"<�d�-4���oF�?)�����̎A��E��ڤYƒh����']�Ì6�����/$�K�]�T�>�nΈA=1AD9$f�r�Ե
t}�b!�Hh�E�v�|`�%�Tee�0)n1���(�ظH�
�愠O	5�:]E�q�s��-�8;���v}�Ą�F��0/����-���I�;�㦿�)�c#�6��NC���#^� �@���iOJ�C�R�)�����ß�N�/o2�!l�&LǱթ���c�P��¬���Ak�	�15B�m��.�}���L�t�"���PW����0d0|��_�cӡ7r��S1�_�;��������+�]���Ǩ�&j2N@���d�QA�.�?�Q�K�R�맸�?B�FG�L����L ����m��s%�ޒ��a�D���1KC�ؾl�1��aʗ�mD(7N�����X�c-B� 7�������$E����6�ao��2k�����غt^�uN�-�x�qԾK�k[	��On�+��y(W��zL;z�~G�~
uD�ޘ�PJ��P���,D��v�)�8��w��x>I����h\����q~ڀ����%���gU��z���p	ſB$L�W�c�ء�mC��.#��螠��S	�j����E��©�|��B�0/��	��� 1�����{m�ROn��ɤ�����S��h�B�YHת@�.>lG+��8f�|����B}������&ZG����ll�1�M�Au�F���d���u��h'ZG"����:QI��� ���Gu�zu��|b���� �I`���T�}���q4E���K^����a�Ȱ�+B����BaAG���~�])&�(��C���w���q=��ͱl��H֓Ci)����n ��h6�t��{�z�߮�cu��ޤ#E���^�m1q�Mkd�0|�=q�??H��]�쫸�ZFGXaT^QF2�k���^�'I98���p6�:^_zĞ�O�9�ޭ���k�(!�J�Q܂�'���s���a	�<�~RUG��3g�_�*�	o6NH�!cJ���c�J^G���+E(��4M�����/@�.S�'�r�[n�:@��|CӺ_ھ �ѿ���m�2��[]��^J�@���J�P��/{߶~`�⊋��ɸ�/Zrz�ޚ�]���{Kg>6��K55�����ۨ�)�5T��_�&k �)?|Y�E	��:�b �0��b����7e��9��y�vH�ĝ6^�u��5��M�(]��;Í�Ph1��e��8/��P�f�땏̝ʚB`�U82d{��b4����O��b@G|��Ry�z�����>� �{NjZ�։ˡ���|ej	�6�[ͫ�;� ������V^��z�4{�m����b2������o�RL&������}_d�^�����q�H�"��[�BI��ub��W�W]f'�W?��]�8B1L�.�|��wQ���&�z�|I���(tSs�� D��y�tʯv��!��磷ˋ!fo��L�Y�r7f�c���h�y��� i�����싅�Jg�fa��a�dS����f�+�i}g����N��ܻ�L��ky��'�j�I�L֫M�a�P���U��:k*�Z�5!��O�<������ү�Z��C���0��a�9]�r �1�t���ך' ��2{�E�]|e������
�����"�G���
S�:+Z��w��-����N�X�p0u�E�uF��O�S�YOf��eu0�����q���R��H7c�޵�����S&&�a����AލL��m���j���/_H�B�2�-���Ƿ}z�ͨ��k&����>ޙ�c*��v`۹���a��2���dq����rddI�2�f���֏�Z#/�y�*��� h1�~�lX�jd��:���ד��.]�{�kf�g,|1�ٷ��V5t�l�!�/�:��.���f�m[n����������vEY��6T����ê֥j�}S����\bA���΂��+���t���o�W��MZtUwn�R�P\W���6�nF}��������+����kT�8E٩�e��a����ځ��?���W� �d@2>���\3A���ρ�?f�HS`n�rө�UʁG���X�|��a�|ց�l&�$�aSk9	t�:l���G�bk(�1n���������C;������9 ��,�m�2"��v�Pj��jUh��y>�7���>�~�*M�~��ht˵m��z4�nX�8WO����Żp��.jʇ�o2�(eS~9J7�S���
�/�N�x�-���mڱI������qV:��o��25l���6�Qz�`���`/��ŻtqN��3N
�����(#
� �����O/��4�h�A��{0�6�1�"���
5t���vn|�ьq�s�[(9~�Û|��8^��y��oH��0q�U�� �بpN�b"��K�1��TL�ꃾ��?���-c�����W].XR'�ة��Z��Hf�L@CM݇���z1��V��x������U�*o�Jc����զ�8]J!,?�+b}=����'����;^�d�d���ƚ���}&�[�fR����|�Cx+������r��I���CO@YԺ
X)�cn�՛\��}-��2.�z��6ޡ�����zC��)�X�6V�k��K6���xI�������KᗴT#9P՟    m���H�-y�U]]]�����m�ޘyW;�\Þ�v��t���&��1!?,~�8xaT'���F�ڃ�gTS�t�F̡g�:\�v�"�Fk�|Ye+������E�y:F�(b���%�cGy+�9$>�w4b����Z&o㒻)d>�����z���]��G��?3�~��C^�hS�+S���h>F7�E�F$�c�{���^�nȐ����<~�m�2�0�q@E���Q�+\0�w8���� ����EtJEן����dff��B����@�(:`d�M��7�å�xpa��`m6R�f r�T�Ȯ֐'ƴ�x� �� &��FN�:KZkG��^T��p�0�lJ�۠��0E^H�V\W^�x�N)%�7ʈ# Y��J��N��������lf�e,A����^ ���
��eIhM!M�<|�Z�w��( ����f0���;��a�y�M�n� [|	B[����K <j�N'z���R�4c񚢋�N�~�!z����QN&�&6|&	��`^r�����$������J-�{�{��*���@�ƃ����K�*�X1��f�m�0������ue�I�ӗ���=���G9"k��(�J�C�65ܤ���;*V�9�;�J1�8���G,6�WhC����Qq��l�O������/l�O����U�������{b�A�˩��J����a�;���d
�]�t��T�(v�v�W��-�zG��H'kag�گ=�-��s�u���s+�o�P`n����1UK�4�ޞɏ�/Zz�^b�3�O���4՛�9����(��/����>P��!}�΢��B���%{sg��Z8ЩQSdK�掋5Pԉǭ%�:�:�V<�%�JجF�8Чn���0�xzT3�"� [7�]My�A���{��+��̧/V���(�#1<�v�x�jR�j�Ȍ����������A��"E��n����Lx�]�@j;�q;�99ݲ��*�����B�����z=��ӀUI�V���� �y�+��X�X�b���k�B/b��b��49@�!� � H�[��*Rh�=�œ-kTb�HGl} �z�Q_We��&��eք��ߏ>H�S`&dj(�=ò���}[o8�D*zs�L� G�F�k�0����v�R��6k�I����y��g"���Y�X�4\�k$j
|�r�ʞ���+*a��leo�2��I ���3���6��;t&�-�h]��t~<����IW8�q�Vc��5����c@�'CO ���)��H�=a����ԻO����oo>������Ҹ�x�-���W^d��:��� $�}
Y����s}�r?�Sa��>R�9gX�rl��PB���J�U�ط���H��3H���^v�uH����.̪�4��ߛa;!�wze�@
)���PVz3Re��H��?��Z�M&�
�䚪R~0}dFu�?��ڠ=i��^0PZ99���[2��p�Ǌ����SH"n��Tu.��`��U�|��ο�A#i&�r鏮�˲9KŊ�"��5	�����P%�������A\����z��4��R�ǁg��_��y�u�8nG��z�h�Ó.e4-�7|�y*G\�r,1}2�TY�X�3沽��/��}&qc��/^�ݖ�����=J-.�'���R�� k��Y�_��`K�1�S�Aru�u\�������oI/е1�}��șL�����E���*�Ԅ���^���]�A����w����d.��)�7�8%�|��nlC�׳2N�����y���7� �V�YE?1H�X����BI�Z��[�P'}!}X���!"@I�߬�`g�L��S\/�	�,Lg\O<� ���c3bRB}�ܘ�O��RI�ɡ�񗁖�jz�����{M^��"����NjǙ􀙜_?~�����}�S��3
���SiD���	�C�B�E+��n:Ga�Ͳ	���/���_�����"��rj[no�v���V{cY��u{��I����a#3*:F���r��A�IB�x�=�xPb�݁�JJ-���ק�؀�<Z5�(/ �F�I��fjq���v��I�Y-w��hف^ʹ�Xۃ븞�n��9�srH��$�3�4$�@�G��է�r�ò�öh��R�D��U"��s��U�.��1���_�����ӊ�����l�������~��4���Kڑ�ʹ�T��2K���5��8ɍa٬�c�#�0����У��щ�d��t�.X��_��NR���!b È��N+_�c�]o
 �*�;<�ةk���Q�j�F�U���_ɓ���1����=��vE]�~֚*+j$����b�z�ʷx�oֲ��]�C��9T[.G'�m%sD�p�ٓ<c7K�i�S~фt-><�zv�cE�y��>�4/���:���/�M�	^�� �WR��T�ըͬ����K�<��MGd2_@�P��Y!ݕ ��k����VB>��Kn��	֋���O��v�{���=�X9�L��k�)7��g;ڈ,ڵ�V8�-�-t��z=|\(I��	��惠"�C���1� N̪*��}�Y��EȰ�m&�L�`��[p��3k�%�%�2������E1������Pl���V;���D&hr1�?Lw�&/� ����s�r�N�����1��Cܲ�3�\e����|�zܞ�l����ޤ�s߇� �A��侈׭ۆ ����p��oH�'k�q?�m*f�uݑ�_����-���|���p5���o�R4B���D_�}^}�Ne���gI�|?9y"B�� �/��L�`�X�l�O��2��&i����r��f �ؚq��Sq�'M8��r]YD��z��I"@��N�����Et�~_=�A��;�r�D��K���w�ە�;Mx�^΁-��q-��R=�&�-�;m?mɰ!�F| ��W;���{9���H�?m�:��Ė�N��:�+u]+��Z'��H�pI�5�s�L>�10LL�[IW��C��֦��p� C��'���߯L�H�f�)'�d������b$�	\��A�ڂ����j����6YJm�9B���	q�g�H�e��Q���EP�"�|����#�>��`��t��ceRG�X ��z��}N`[z[��ݕwz��8,|
��mw`p�bz� �t�-5Yt]��+����iH�����ž����Z[%��1�7c{�ʅ3�O�&ǜ��թI��
p�8M��-f�7��v�i5������m���pRl�ӫi��W��Yzhn(�8W������Y�Ըx��0��Z�q)��<�OuqT�^k�����}l�o�Y1�Լ,j0��>}����4���q)tZ89������BE���!���D�:��,�z ��&7���W�溽@4�c��:����4����'/���j��#f�>|��L�o�\�/l�eT6�_���)���c;�C$�	�����-�%*F5�%�ơ �KP>s��U��v�_��M�!f�Pv��u��M9/k+�L�˵`�&��f�AA�����(�:���~5�����Z����NZ�/��鏂a���#nY[����o���}�5�Z����n\vۘ�<���X��ύ;;&6 L���&���l���J��I�}�Qޟ\�����48�;d�����R����SVr%�EC�!�ː��e�\�{��"��>H<��d5�!�k�@�"0)U����ʺ+x�ńk���]Q��p���E�� �>�U_�4��]{e�o�݅�:V3��Wb���or�C��N`�6E)vv��;zE�e �6�S�񢍷�W��y��	��KB|q���/r�?]=՛}��FA�AQ��O�AF_rf"�%'x,�!D{;ا0�a�xP�޽\![P|�l�#t\�����Ip�pR���R�r�~�8cr�����}���E�I��A��q9�pQ��♣��H�'[)B7J��NZ�N)������gh�U��=��D4�q�<a @�$���as��ж41��޻��y\Q�}��8ftϬ��J՘=��l�N�v��R8�    vҏ�s�[<�M�HKK#&#5Ѣ�M��%�)�Vm�3
ܟjӜ�mҲC^_��I؏�D$�QR	�����ǒ�F�!�|�
?z>�'��Rd@�C�fa
x��複�!y����z��AN�0���κ]��qJz7ڶf��hs�˹kڼ�ic��i��^B�Em�y���qu\o�L��~'������3f�~��l���W>�Hå�-����A�M)�{�v�k1�@=��:�	��@�CQ��2��T�uV�8؊��R������?n�	f�X)TS�&���W���p��f^��׳��.��EU���"ABXb���΀�#�ԈzQ
��.G<;���Ù�p�b�;k���Z�9�!��	�،Uz�㥟�KW  %��B]�}��:.WK�۸�Jƣ�%Ԟ��-�Ʌ�FV��az�����nk�͆`�(��[j�	Y�%���ѽv5������<���S�3��f�g����̂��ә,?~D�~��i���!+�|�LW��6�e��UƣOG,K��9`�?��HlW^d"�P��EH8eOY��M�#���3�1��y���3G��%M�w
ӲP�3�����Օ�d�n��p|��	�����U�҄p�*��%[�O����^�������W� $�g���r�ya���}���Mj�U�	�8͋�m��X��8-$�	*q*m�,RRW�����
5|�Q��J��0��N�˱/��[R�Q��$���i3��iP�B�:<T�)��t��/ &m���V*%|��CRU�����ђ�˂��X}�B�U����~��A�!ZP*��To7}�Rca�-d�)Ry�ʇ����?!8y��+Z�5�Jz�����+<j	 g[I�Hq��߳�*r-f�E�טы����(B,H~��0W��Z$j��q��Ʉt-��q�M��G�3� ��@GV��=9�zW-`,�6��O����f��0K�:Le���r��n�f<�|S?��U��^�FL�b\&O����0?��-�H=;c1�(4t��m%��t���#����c�F�Y���Y�����^��|���N
&%�U�+W�@�]����w;:��A��y�� 5��!�,�����l ��4̰xwz��ǣ?s�M�T�����bj�!�o�{L$ݙ�﯆^#3-��3t/���j'��b�%��Ps[T[���9�ƹ�ޛ�O��)�a���&���2'�G�y�Qtu-L!?�
-�nV�$`����]T��fٴ�R^uܭN�����ê�z��,�/��� K>�Om0�w���0�ncӤ�*)�	�:[��<�&7f&"��d�H�͌���(�7a�
YRU�~D��]��H@����t���eQ-�u��^Z;��\�'�{0J	���.���s��z�n�.�M�1��i,�F��S�֢o��éD�Nа^�OD�M["���&��/�����W���f��9�	Iޠ��2�"a@�2����H��kk�k]m'��]���#t]�@q�@��W�m>���7�㓌&���q�P��Y���)I	ͨ�C�����?yV��/wg�qJ;G��Wt���b��v�%��ᑐ�b�7�8P~����z�J��N�ʈ�~Z {��Fy��!ے0�	��}��G͖@
F�J�gQ��Z�>R�B��E��T�C�e�Ԫ�c��*/��|^;3�����z�ˣ�;2\\�@���K��5�u�d=aI�k���٥��{ϡw��& ��X�].�%㹋���?Ԝ�����y��!v��W@�l�}N�1gr�.o7�ғ�1C!�>�Y�~��?l�B7JR|>��C��P�x��f���=}��
���D�ұ�M)ӕ=b�.���جuӲSl�V��Ya_tT;@ѩ^��N��[O�"�"��⿫�c�~s�YS_8]0R�50"�94�^'�Ij������-�M�7�f�$AM�~5�eA�P%�fzb��Iז�W�ա���]?'޲����o�_�L�5lbYbfVӃqC(5:����>�n�"bO���f	���(Q��fli�il�����*�5!��K��&
$H�������e����(ư�[�p�Y�]�?zP�����;iY�X�2h�&~Zݝ�B�[x���C���Ź��{VY����/W=Opdd*M��{A^��F "6R�3"��#-۪��a3!�̦N�ʢ�w ��ib=M�/c�D�J�3W}����zx��}p9W��UT�2��:����J��9[S�W�间��D㆘$m�q˵g�c�R���U���LU�PO]L?�Ќ�l7���Y�7�6\?����֗�|{�vq�&L�C����K��&�yu����S��eƱ�}'��_��Fc=��������������W��n؃�i�Fo��&K?�x�~�xq�w��%�a�a	�-%Mn7]�@��	u;�j�1��Ci�NCd;eD(B��\k���b��g����h��2gԘ��I�L+�;���Q^=���3	
tL����'Qt���-U��d;TB&����������.�3���_F�����OZ�����;.0ž����^0P�7��>9f�Q,-����o��XR�00�̂�t/���O�y��Ȯִ�2ɻ��vY�+6 ��*�Z[��P���D5�}T��:�V�a)R�S�F�eF�� 3z����wH���-Q��0_h"�F��b�
6q���y�9��XQ�|8����PT��ן6?m7;���*���Z��M�t�Ng�y��>{��%:��k���k�m2"4�2ߟ6�79 J����c��dq9^ypS�\�(ݲ�h4�hv��67$sSjqз7��/���is�ͩn���-[xoT��[��O���j!�����VY�9��A�:xmx��ͣ�ގ��N�'|�o��ח�>w��c���{�����J��*|�ϣ������D>=�1ӗ^�œ(��⭻���G�k[�=��)�+Sa\��f�LH�A9�4�m�Ga���l�~��i)W&�,�}ɾ����,OH!��z����%�ѧ���/-|�UBZ5���%?��w�W��R���W�� �u�T��,9~%	���PiH�ݟk%\;�|�Yɔ(�Ap�S�4�8Wdr������zX����6�rd�t�a��[�\�4~{e �ά�A�t�)��˓�b8�d����h�Ov����Bk~М����Q1H��w3�,�l�*}7bX� ѵ�M���_�]ۏ�8J[�E'F0��žP��>|���wL�^NO�`�;���X�y2�u�Zdap�nc�����4?̼��-�<շ�TD��@^~����w�@)��m��DJJS�L���_W���̈́'5c�&Qm�Ϸ��5�A]do�'ʲ�����&s�����☩�'�E%C����9K�(r�F��ݞN/���x�`;fk����Uo�?-	i���ţh�T��`� Q*PQ�4��Kl8�'��/t,�K���{=������\6��R��1�0�ƣ��HD>U5a<��W�_������C	�}���)���+W���JI ���dǘ5��{��>�UEC�4`F߮N���%�N����E����V'�Z�l' ��"ʫ�Z��I�Q��u�C�^}��v1�'�*[�Ym�?Hi����c]mQ�~l��,*���C�V�\�[��`|�Ҳ�^f�ߞ����MX�p���;N{���(?3#\�_�=����WI�czz�AB\t����1��|��ƃD<��h�@�Ӫ�ZH�nLEr�2P71�1���n�{i�6aB�">��o��Wb�Ц������~���Q��@�搯��,�����&k�x����(&�����)�]���������#F��	hp܅2���n�6r��Iϩ���@B^)�#[�.:u����!��6�nB�s�́�E��3�:|]��deoj`A���Tr�4�d너Z<	��Er���^��)p9(H�j���Iݕ��S���qWn@���x�bf���w��,Mp��$��D�GO�l6�    oRju0{��i�&�׻���j��O���[߯"�n�^l���nsmn�i�uK=�m�-��V�zJu�n�ƚ�[tȘ&�:7����&,�؉O_�'�0�hʚ�|~MK���D��ا%X�e�x&sѴ�ʌ��0�Y��h]��O�G;'���z@3F��>�����ؠ}�\���}qe����;S&RBF�y�7�����s�t�l�"p3�s<���B(�o�Y]��ji�S�@?���D��+�3:/D������l�W\#:�D���y��7a��\�������Q��L�W�R�`�Q�n\�റ jR�pEDE��9�^L%-��	�CP���P��S�%��	�c[Q�)/�
���=�(�?�z�x
l�
* K{�Ǉ�}m�7*��1�B�Jr�vn� 1��>8u3$���w׍Z	�n�qz|q�W�~5�[/��B@��70�ɜ��s@wt���aɘ��
~_�q(�f����fA�w@�ͻ	"x֛%���[3����
F__���RT���_8�^�1�6��0KP`��>��\�i������h͘'�t+N-FS�=R+��8k<�`M��C�/�2�p�?�)0���qh1���;�wE���`�<���Z���[�vJ��'����T�f	3hf�V�߫8�[��oQb��7�7j�K܍e���H=J	���՗6S�y�?�]XHf�;֝�ާ ���JDA��}�ծ��k���sJB}-v�ޢ�#�����h��������;A- �vڌ���)n����$�����$��4l� ��t�z���?X��'�fߜ`I���d��t��B��q�&��1��Z�bm�(7�m�5=��Og�r',Cu8�O�tMQK���Hӗg��E4�MyVɹV��eSA$�R���:q4�ֱBGa�>�G�0z[
����ʯEV�Z�D��(rE��"E����r<g&܁Ԑ�}Z,����7S@�8,D���(��X���M.+����l��3���u$.h�2lHz�K�xPB�A͓�u��o�)����Kt�/W;;>5F�3aU�y�\�絍`g�����z�%����E6��I�ע~�dg1hq_ݟ���J/�>������) ޡp�#8U�5>*2�dzORe+]|�e��>���ʜ�ci}Vx8N⌵���J��m�va>#U�[�����F�͌gu��?�	�~rA��w���Nl�nm���IW��S���@�$�����_���?ٚ��y��H껣$krZ�|q릈�	�""a�}�|vz�g�T�B*�~(��(����Y������q�d�B�+���Q��-�,����j��7[}z���*�It�u�����C���y��V;��o�D>�N��	��x[�+�D�?�9�$H����Y��.@-_��OG첍#�f��Jա��𛮟6��`�Y�Ƒ���K�k�:��6�,8YX�κXT���G���!��́��>����+�Ei	����-���ɏ3!qI/	�Q���k_7Pi�r�<�����\��+���1� <��@�X�x���0c
h7��1�VD*G*����2��LDW�b3(VF	e���g��О�`�a��L����fX^�|�v]�RLi����17G�"ۢ�Z.ƈ}��;uR��O�c��"2A�+�m��F?���'%�.�U���%�uI���F�Q^���$ힴ�v����r��5أ1�=S��o��zxu�/U��5!����y��+�NXEU�f���$A�@ٙ���V2������"��3���J�͙~s+�_�Р/-��~3:�Wq(���͒-`��:�]*e�t��r�*�9���(;$�	�@U4�_fݻ�cH�Ռ��(y՞|`e��jR�̞��#��Qʀ���Z��X�Ϲ6?L�NS���[΁gX3�5?��z���;�X��2�˲#�y��������Q�d��$䪱��~���.�x�Lҭ#��x��~= �y)ʺ%pb����	[�"4�~����,�l��!�QYnՊ�r��m�"
�� �����_b����4ex[�a(	^������������'b�I��T*,�{!�%��N[+�Q�2��iQ�.�{i�|JԻt��84��Y�+ŋ�G-�>r��"�5�x.bl`���p���y�bR���P�x�Z����مWHpm烗v^/n^5��k;�� ���0��wu�:4.��Ɛޝ7#��}g�0�b��ISTZ�&�R6�m]�b�2�o/پ�@ZD�P��#%
6\UO���!��ۻh@hE��&��'����ܾA?dScJ������7L��|����:}�֜��8�9$���V�Sr��spK=u<�a�xˎ'��H�1��f=��(A[3~b�/��_�ЫGhh~�PJ�;:���(�ܮ��Z5�M�iv��ڵx�;}��A��r�2�N$]�DX�	T.#D�0U$*� /rkG�Xe9��I�wD'�wZ��iD��H?<b�Ģ���b��V��Ht�b-�e'�W�O�{n���q�p{�un�Jv����[5��|��N(>	,���@o���;?��k�鞝j���z���<5�P1 $<�/3�/�&�1�*�XOa�Ж*�,�݃icm'�s��]=>�p�L/�a�x�n����j˸OQC���;`o�2�7�`�\�L2�
3Q˯�s���*�|��������F?�ڌ���7���G�q��.���k�wn����x:�_e����[;��b�ˎ���/V��V]����r3����*�ǂ���a��'���������R;u�M\�L�����D&�X|������6~9��C2Q3`r���mm(r���)'��t��u�@��kl��\Xx^�[&�z�a��[��[bk�{��O�"̀�&��U׋��@��K�SV� $᯦wfՊ�]�bs�Mp�!�����ă�I�����y<'���O�����E)����O�!<������{�w�A<�R'�F �&���2�RP��	�O7T�_Ɗ���6w����զ�IN���/�c+�>�!W!�(�
���t�4A���@ۙ��Ž��	b���ζe�Wh𳣡dV=��������_|�=Dhi�_�.�b�{���@v?���7<��>"O�<�[,�ބ�w$��t.�(�� Ǐ��q��r#`La��dJQ8��精6��;�;�᭦ft���n��T8��6�F��:�|ܪ��'(�v�2IpT�~gd�3��B���O��sLWƄ�*��_tu5���0_M^����bnd�� ��� f��nx^���Ѓ�tڪK�]%R�d�zC��,�o!��a�!o�VX=�;ܶqÔ XD ˽y�U�Q��Aa? �=�F��Ƃ���m����]�#꺰�0u�q���cf��ژs��	�E��P+�ᛁL*;;𲦺�<����O�x��rm
@��H�JѽsZ������x��Ԏ�
6+A"�:�X�؎��sϱ��E�ɜ,����=���W��^�O��|�\tK�ݡ����R�����c�OMN���/Ǚ���AU���bM��A)��q����X�R�2�ۻ=d]f�L������\��r;ݥ�¤U���'k�N@r(��N�{;^yU�k'6�0����4�}�g�^��h�׳�*tc��SZJ�I0�3|�ˮ��jQ̍
?�q�ڦ��S�����q����e�Udc:/أ�U-���ק̫}S�X���l���X�,邖 �x�r=��[=-�hOc��"�G��k�5W��1PN|;�Ӧ=9.���P58��w��g:�4�X�q��cè�N�],�w����d8���I"�;4���at��LO:%F�H��@�ı+�X?��L�_j�̖B۱��Yd�ک�C�J�6ܗQC�[����2a��$-��K�O�<8�*M5~�7,��m��%�����D>��Ŝ{B�z�~G����'�Yc��g?O�˥�L�     m�MK��2���K�����
m�O4y������m���f4�V��a�&��:-�\y���e���7}�ôIR��Zq�� eMG�(30����7a8�Cw�GY=�m��ɿ�2l� ��+�1�P@pt3���4�N��q�)����mF���Q�1+x�aҖ,l��s��r_r�e%����zt���9/��$?���'�"͊�Fצ�v�����%F��^,��X?�d�� �F�"l��/5̏�s��m��Ѵ΃� ���|��+�� �B����������ϪDsF#�Dy�������LϭW'��;y��r"�n{�o͋����$<�����n����ˑCݟ�r��^���ۣ(����9�c��^��~`������3͌��6�xmxaX6ma�VX�(oZŪ�d?$�4>��a�E����(�m��=Z����d/�2b��Q
�#c��o��a�/����!�7.׹��c�B����M��6�6#�H�r��Fd��8��I � n>�n��!R[I���p�˱����|2I�'�����.���z~��~O�(~l�N6�:$�F����,^���ɘ]�TF}�x��$rj+,�<�`���bTf�hfYE�D*�Ugd���Ϥm����H��G��G5N��u�˖ǲ���S�ȅ������˖,m���x`t7���hm��'~�/��4���������3)VF�.��q��L��Ͼ���K�!��I~�aX�m>b���U�,M��Z���x�w*�n��6KNҔ���i�.�����<g.��^�Ib
RzC���C��/ڒ_�2"r��O�"��Ga���5��
u���gc�u�)Q)�!��H� t9��
�Ӈo�����\��fF�G��0���:2�^�is���(�e��&����nc�y�7�0c��_��"���U�fPK���5�<\Ii�ۤzm�7��k�v�m������DG�Y���gʉO� L���1%HH�_ג�*�)�!<>�	���0Fa��{��j�o�s���;��fBSD�l�a�/v~-�r[�K	���]�Zl�+-E-����������|�)H��WQG#�/�R�%�;Ɛߞ��rM^Nꆾ��X�^c�U�r�`ը�D���:���Pݳ�t �i�,	�#ch3D�،m�h�'�@�#��49{�W���j�A�8��kF����9�ª�ƙ3un����'O��w��P[*Ỳ`�>o;�������vco���^"�kj�R^�)gi���'ߥ�!�1�_��I�4&X@��������	ط�)Џ����O2��7�8��͔<����{�z���惎4�#�=��!�R�i3���R�R�?��3r�Hna`3g�\�Mp5,GSp��<����,�C�z)������v� X��Ц�B	���I���iG�����dp�T��v�^�[��(�֔8�&��t!�P�'�
���L��'��F�T��s����$���z�[��C����ށ�����TGT�M�m�Ia�;��~{���{;K|���zUv ,�oU�hDh����g�B!M�T��Oh��*Q�q>�W�����]`�)&Q$�4��/G��(& ��g��N����"z�������m3���fʟ�ζ�"�IdI�������"���i�*�����G[������8,8t}�מ���M�\t�z��h��lm��������WpbC�:��Y�L.��G�-�"�g�9�;J<�"���ό�/�׆ʥ�����o���"UK�;ex)�j�L����i������Tµ'U��ݯ���ёZ�t$&�G���:y�*uŉ��?����P��,Q�#l�'�\}��*�|��oN�T"��A���^v�ԍWr��p��0W�Uu/& ������_��+*{����������������[� Pd:���I5�T񸿃۳�u�m�o����1jαQ�i�Ex�nu�(�-��m��0��$�O���Q�"���Z\��ӧ��j����D}T��ȃ�}��x��-�/���ޞ�Ȃ���������Ĵl�n�Y_����n��KÜ�$B�4k�9�x5g�;=��LַU�6|dl3&߯�%k����B�٢w1�N>N�{�m*�ҠMF6��=h��Յ���g���	�E���s\H���[;n�rP|#u��GG8��+n_�t�I�3�����n��q)��ԙB$����@�4GV/(�;�3V S��JT������1F��0�%/M���@*���{�{vPj�ԧ��U��U �����M�R�*��Zz/�&F��l����p�z�¥Ϣ),f��7��w��z ��p��G�p��Y�����,u�c�P����-�u�ͺ|{x��ح==�����aI������뷒ˇL��a�|)�쁅��!��\Ɨ`<�R0S�?�B����z�uA	�B޷�n���:����;��
��b�ԋ����F�*��8H��ED�c�՚��=eXj���k�f�qu�ы���E/��l�|�����PxÓ�.�@jů1b����@"��4���a�W�5�(����Fa������#�h>����:<�[�r�A��y��>Da� ��\�5�5�߽�\
}gh�냆�J���͏;4�y��`�i��Q���f���{�xIB���$�h�Q��ё�+,Lo�Ў��l�Iwn���3�*ȭ�iR��⃌��r��h�3��tc���D�HY�`�ʒ_4��>�qj��.���]4��K�[��8ݨYň����_��7����ōY�O��N��ɛW���f?�� ���;?� ���4��찹z��&p���<5qR�]Å�5�J��,R��=��ʋY�ܯw�f�4���*~�1��&a	�l^\�_�����?�w8�cï�A�v����'������m4�S�o��|P�Gv�q�+��x�<��^?-ne�aES����"d=�29��w����{<8��
�rT~�3̦ꄠ�Y
�!b
��V�}�a)*�.���]P˫�� ✋��AZ/y?Fk,Vd��Jc+�֮�����n2���`�Q�n��kqxF���I�܊����b���]��*b��y���P �-��N+��*��i�Ԁ�Uq�e��(�JހA�3��k���dʙG�+��J6��n]�)��.��ƞ1ч�-0���,C~Ka<�f������ %B���L�����7������t�!�A*t���7�M+7�!�钸�QԀ?�\���lὔ�U�4 ��U31]�2��M�.L=g�m�.�4g3T�+��PZ!�d�=� W��[�ir�(��/3���*��1��a.����c��z�'@���c�0嶸ҕ(! �ʢ*��͒��ܱ����`�S]Z�,��?�tr̲Ƣ��0�p��B
=j���x�o�R;y�D�ڞ"���ʯ76�?*CmF�>�S	��1ϺL
�*ݟ��	��X9c0O�O�Q���i8'0��|�Z�׷��|�j_���)����XEg&#����uk�Y�xi	�L>	ex���I���,�]��j�{;Jv"�q�c4�)e��Y}eZ��8�~�}�c)�L6��{��D1DV�בgj{x��q�3XVU����+Z����X���Y���Z���Ӣ��>���9`�@Ou��یx��(��:W��|=�{�#�Z�U�nk���G��6	�"-4�A�	������+�D`�' ��{�@\=���O��%�I��K���x7cW�"�݃_�:UUp|ypn?��oO�W�\�^��9α(<����a߲?��I�$Qyz�˗��J��F姛۟��/y�CV�<�4x�1#�y]2ٲ/W�DH޼����S]���掻
l��!!f��}Z,DE�p�Ű��u��Np�m��+M�؁��Mb���=�^4��9!@��o�x�:a���Tѩn��)i�Q���Z�aNP�C�iW���nnƣ$ъ(�O��d���*���&��P�K*    xOH�K��\���*Y���L8y�>/�1�T�U��A�Gj�T���{i�����;H*���7�&ns��*��Tm+U��q�D�SD��I��A�T�g�X��Y�P����S�oI�&��P�+9N��AL���6���v���5LF���I���T<�E�p"��D�9�\5�%�7x�anf6�y^����;�m��]�p��5����O�.H�颷nY���h!&�s��6�L�O�d'g���
�{L�'/�YN
�Q��Q/7$�!0s��l�~�ډ��Ĥ�a_��LKzzR�i~�=l�,;�_o)*��5��3�H F��~=�Q���w��><l���.�070l#��k�[�%Ts���b�Q{��OJVMI ]�l���m�Ifm�wR�`��ܾ8v`�mEQ$�훵ك/�<�~�a�ܙ�!���e����&����a2�.�l�i�<5W�z���L\�-��.������(>��0l;��r�s1�"��<�����E�0�����k�~��	�ߛj�H�p{����w�x�a3�@L��*��Ŏ-���Rz*)s�p.�.::(c\��o�b�ԅ���R�;œ��Wۖԃx��j'�'�ZK4�3�e#��7��^őY�P��p�v��ԅk֎�a)h���DYN�9ӻ�(̒;g��
/���)����,f��u�a}��Z1�3�^U�ړ�q#<+|_�^�����[f��sv���Ⱦ����3z�t���@MQ�JC���t�hD�����qu��U����\�v�<�ይ�\�T| ��'��rg���a �ے[�,KNT����a����q�6 �.�+��-�+��]��Y�����m"cDf�]4#� �,�"+.�ğ�J�n�h�"�@��v�]m��'i�`��ٶ�q.�@��i6'F�w�O�j� �Ӑ�F0w�5p���|���l�.H�U�y��Ʈ!��A0��}�[�X�z��jI��ՅQ�A궘�ՈN��`�7/H�D`$�N�G�$��d�Z������q���]�.'�W.���n��%��í�
�[���P�V��ѫU��"����?�^N^:�>���c�i�r?LbE̸U'__�՚�<y�p��r|�~�P�i7beB�X���fg:�Ĥ��[�e5�gL��r�ԅ���tԝ��/O�a��z�)�*�����:2)qoJ��(!��O��zu�2�Mc�$�ҝ=�Ts4߈'��
xlv�Y���9�C�P�;�X[��$�;4�T�D��#���S��x풾ꪬ�nۈ#�jJ��[X0=����FޢTl/���B�91�C����f�p�:�:2��i�͒tEs|{��_Xn��C�}�v^H���-fts�54�m�aӈKi�"�]�j��s֯{I�fu�=��|1���AA�Ӌ�:�y���pEdT��B�KQK��Ji��`��-���h���<^�$���
:O�70�y	'l�H��4��-Yh�g,�4� [�Q7?x������">ua�^��[�P��IAM Wj��ME�E ��9���㳒�g�Ȼ�J�5%���4�|�?�D�'0����[,96%qjA>��*�֢� S�SJz����/�b�2}ޓ�C�0(%�I!ͬJ��:�� ����E�N+k��) ��c��5ɋψ�.ݔ�>.�I��tJ=�9�=��<q�a��Fǖ�i�y���A��	�#
�Ax��u#S��'�Ic���>�ԅ[Kh��t��r��`'܈��}C`��}�pN��֤-[��P��[{,i�O	x��QI����g�K0��z3C���H�T�a=)�J]��U_�j�_�FJ`d�S�����u�_�H{d.��;d����/�<_{ٰ'ޓ״{��HQ�G��x����E�m��?��<���.a��i\ Mxc�ü=�>�������.H�� ����v����F2-j^&5*�������3����uԜ�eR9ѫA]�����o�Z~\�n�wNB����f
�1�!G��4Uo�#l��溙����6$¿����pde���/�G�W�Ý���R�`�,��]udol��h;���C�I^��U���0�◸�w
51h�`.��Nv�rI@��~�
)F'��X1:�*;�u�������Dz�cGJO6z�WESWe6��\(�, ��D�v��q팺+E�O���fH2���n�~�
0èF�4m�KF�Z�tNH�O�K�v�OjghQ#i.�	�$/�����S���+�#c��I����)��!��o
�
v���4b!�m�>������r�(�����4Р�~��J�X�Jp^��Ƞr�Pf\~	��_�?VH�f���b��U����e'����p{$�P�v�1/O�$A0\M�������o�l瀩�.���M\]O�K�Fi�7H���شT����b��d��O�P����m��9Ǌ�_�+��q�^£���U:e*_'���{+e�mf	~�j�'��A{T=6�0�a��Όx"l�	au� �����V��F�tgڳW��<�-��o'\B&I>I_�`���)L�c�O�-�����n���6�n��]��֫�c�E��I��5ky�A����L=��2���� �}�:,Z����d�^@Sm�,O�t��Vp�����d/ ��4������9���Ǟx��X�vT{�L�U='C�vu��e	v�S6���*��g����g�xؑb�Vꍏ�nY�
��[�"���V��b��	}�Kun���h )u3X�#�q<ҴgS��|�a.I���b9ː_���D���� 6M�`'���j�S�j����|����nSJ�2��
L_�q����9����U@2^�2��].gB�S��K3�U�����1}帅��:�xs����&������?y���)3�Z��K�z�n�a��vu:ƙ��H�|v�ܬC��$9х{��5U�:�M����9��C�ت�U/����{H.�Asʶ;��<��R����i��{�x��Y��P嵚��Kqh���1�X
u�M�9���ޕ>o��}D�A�T��rq+��dE'	t���
��~5�苹�oW���&�
{��']���͌I~q{�{�~�KA����A>ܵ�H�%W�yo?�%�\�@I>�3(�p8)���(?BRh�	V����c����F�:��R�A�Ł?~q������=i�(^�T��ȪbP����d,<��4*T/����P�+F�$�Xޠ]����8C�ra���1b���5(�����0�A����x���Ɠ�͝�7�"d�aV��aC�9Z�
��;[�Vy*�	�t ���o�.=0�	k�7�>�e_��
⎫���3P[I�i��ʗ���E�9r�z�O������Xq�a
� �l_��� +5�ޗ��!��D��sj:{f}��./|r6B'�9��/n�3�I�_�9_#�=�߻�(Nh�0�	����Kv��"9"����_':8V3�Yi ~�O�hg!�D��-sGB��u��{3�W��)�X���*�S��XN��Q�.Q޼;�L	��Ww���?wž�M����3�'G��
�'���BLpy�y\���^r>"�},줢����EwG/P�	#���/��#f��£�t�3C~���jxU�n@5����!6�q�J��.�iY�}�܏ fi��@�Գ��Ȭ���PBv�s��I����l��N7Z�8.�W��mpq�aDØ��Sr���O���X�R h4셵��-�.YN��mv����!Xq_Tva����B��Q�П�ֶ�m��ރS�XĖ������^E��<��D8̌���d�P��С���k]�r�yYb��9_8\��� ~�*C�Ə�~pd,!���ͼU�Sp���:���P�l�����2�G�gv���X��חF0'*8�*}�z�7+њL��?}w���L�J��;6�z
(HaW���C�W���;�:f[�;��2v��*g�VC�����t��sI�"U��;S ��    E��f�CGYR��fo�5�u䏐���K;�!�YfG����A���w�C�ƑSH��B��h��D����׫�����䋪
?�ڢ�"�m?9���J��{*bJZB����<�&����!��&@�������k'�4�@�*4C] ᶆ�-�y�-�x��>�@��`kT�=˞�>G����ǎJI��+�zR�O��dwݺ_l���������6�-��^���f������l��kd���A����r�V��g�OS��f�j?�s�dhE-��#G�^2ވ���L��4�Y!ݲ��`�iy�:�/�
�'jJh��CQu�a�S��1�~G��Iy���~����9b#�>�:ge�����@�-���܈G�d���Yk��v����Ѵ��	z�V�������VJ<�8P��9]�j1�$�\^�:�9cnǨ��)$�:�4�}<��ӊIW�/���m
V� `�6 �y����}�����K������9\	�H^11������7 #����ݙ2���D$�Z�#a����q)��:V�QB�}"��߮���%42NWQ`�ka���&-I���{`���a}1��S�'E�q�7L�oN�ٟ��.,ܑN�3D��.�u�2K��7K�.ў"2�b]�g��>���(K�$A0�|��8����^wjv�g���g�r���	t���5�e������a�����ɾ�Mr�M�H��6�����l{{��?���Y��%6���̟Q0�N�Ϩs�U�sS��p�׺��:|o��^�Bk�|���S��u�}c�_ =b������
�Sl����+�6��Ua��)Z���?�@���&��E�>V �yD3�>�3�su���Sρ*ZP��d̜H�;0�<cN��3�h����M��4�w��J���wL$<�͇1�ˍb#���LS3a�VuÍ �R�`O~��݀d����lgaXLz�Ny����-@�����ҝ���KC�[�b{�AO�}�0�z��s�eG��W��W{t���{��D3��w�0�N��DuK����q/+�>��)��������������A(B�3̍�4M��
l`���KH��7�+��%����j��Q��4�j���zuvF}i���v�0 �d�2Wa�r������9#�@�|^0wc�����=�=���%U?q��ߩƹ�֋�Z*-/���SP$N���%��k�
pcZ��j�V�A:Ta�ۨ�
��FLn�y;�z3zT���s���"�� n/
���S q��W�_m$���m�N��j��[�e�$�[=�����E�%O7m��� I3�$�Q�~�5>~G����)~:�9jT�4M���#Q�a��j�Dm%+K���F/�ho���/��-��W�'���")���є�f�|*р��F��⨠:�BX�Lx�@N�(()?i�\�l���⯋�V�taЗ�?�_�9|
(ce�#?��1oV��e7�P���t"��81!}I*4Po�����/� ��	���W�_�S�[ld�@���~�YÇ�\��L�A�����U�,&(�z��PO�Z@1��pd����6%At�խ�����J�#�f�����f9p�X�����w�����:O>6�m����D���sg��,���C�����>i�xX�#�:'e١L�	���=�%��<�s�����i"�CO�_lXTz�):-�~k�o
S<�������-V��)r �Y$ky�fQ�h��^��q�U������z��1���E'H�W��_۟D���B9����wB7�WSG�IL�����z,�I���$*ߺEu;`�&N�v�2���𱪐���m�t���-�:�W�I~��6�rDL��!\X�v�PPMӶ�5G���s@��Od��-<��n\����?��1'Hr��N�^�	�A�7S�4E����R�T�P������u�0��~��a�K��� ɧt�cޓc�$G+��~���߻aPA ��>�ܺ�X	�45��5{W���+��|�� 5캢��t_�����������_�.���.eQ��Q�{�R��������Ը#�!B��\G5��`ǫ�_9�_`iGv@�6
�{��h�B͂� ��C�F*`��/���0�~`��^/q����+j��z��a�HdBv�=������|0��p%�v!�fނ�Fr�E��K�=�v�[
��O���O	��P�
mfu������yH�I�F��3���К�Ȇ��D�h�x�%^P���f�c���E�S�*�q3E Za��:���ܤL��u����7:E���H��fX��ԨD���7�h>��܇N���(�2��U1g���91�f�sra�����+O��G��TEFT�^��#H�=�*B�9� ~h��;\=�~?��yY�yM`�떁�g^_d�����(���=�5���2��JٖP�U��6�=��������VQ�5�n�� CQ=��4}z����1�
o�.�����͹�˟"L��b�u�&L;��1� �vek�yߩƇ_�`Lav���a�F�Pʳ�|�����pfjֻ��;�^9>�ntJ��1^#�=ul^���?���'S�`�	h�d�La���a�wG�$B1�����z0�i��(�
�*:�C��ʾ�����M*luAq���-'���r����\���]xP��uۯ&������Y��iZB�-Jwq�m�f��4��d}o���U���#�D}��:��%'$�$�n��W.�k�:Q)��k���Á���f�{~}���#u�M���2ﳒЭ�vO7���!~0�B��l�/bި��"�?���W?w�@.J5</	���n���a����k���/)?�#��`��C4� ,A�s�t��I��^q�����
+;`?!D$N\�x|�)2��3}u�W\ ���W�Iu�ɞv3n��Q� ���/�ו��/]�ᵑC��e���j�	����:��}�|;sU�lg�=����ӕ�xQ���j�Dꦏ�GӠ]��Ô��D!�����SUȭ���������7H:7igiq�0�.�S�����Fu�{�l����?��xƹi�H�~~�9�:��u�3�r�Y���W�M�-��Jz�&�p+��� ��q��$׋�e��;;,bGFiD�[�ѵ��a[/>&&��P��v�"�2&J��B���3�����~pZ|G����2^�� RNؑ[]?I(�?@�ݞ��rh��am�5����g�Q��{ޑy���V���֔��톷#���r\�-`�=#;,�;�'���(D^��)8y�2
:���8צ�$v}�t�q�=�e���`a�V�(��3��"3�����T�p�C���y��0��+�X�?��ض��Y�5��tsy�=qZs��*��a=���J�/� ���I2��9��16������G����_�g�A���ǃ_��@^���n��H(�<|���~��|5�g�3���^�Yz��".[�@tu������d*���]���C����@��i:c^�k�{# v,]�j���E�TO��^��vn��ql��v��]�B;��젿$��vn�eF�_�-Io��	�_��ܩI�޵����!��Z��B�Z?�p�|�r��ܸQ���i���%@��~�,��UQ�*Fe�^���"x3�ln��4�f(8z�_?l�:L�]�d�_�z^�s=��*��!��67�}CB���)���q�f �"��ЮF����F0��/K2\����%�Ͷ!�R`��z�'I�?�b�;@G��|�=��\1�K�z%��$S{�.{h�z�Ҍtu%U&�3qF�]-��P�����e\
�Qo���i��)�u���誎L��U���6~�@(�e!jJ�0L���+@&N����^Mn���;�W���.n�S�3��Z�W8�+��b�@L��yb��	��	I�5Z$GapNB�����#�!��v�Kߝ��Q��o�"MQ�sm$n�Y�~)�T G-��)SD�Ww��v�}&� �  �k1[������9䰈I�«�	ҙ9nA�'m �#=��cp�TKe}�'ߪ^��f��I�xԴɻ�aJ��<:uEn�lsJ�r�c:��GJ������{edٚa�->��1Iq/��M1�h��Mb.h�!�A���bf��gs��2-426������ai�ɂ�N�A�Y��F��eaau��t-��N	���D��8E�e��$���oL��3=�QE��/S:����{�V���0��~����$J�8�7f�o��"$O����NW����$�W��Ґ��-�󇭅n
qU����4*U6�]d�hVֹ�ZE�#.��<�'8��w������/����V�R3|2K0OD}�F�w�ػy���;uH�k���rO�?�oN#�Nd{�؎��1N���k}��	��ٷ�H,��߻)I`���{\��E�����<��>�]�ӝ��	���߅�fj��v�>{�q'�1��jr9R���>�4�_n��Qh�#̬�����Y�-EZ48ч�psؿ
Ek�%�eyë?y�-�;��P���~~�9�����*yhv� ��-�~�1\z����|DG$�9�fh�9�%w�I)��cv�^\\� `n�o��-���[:V�s�o/hj�C��j�܂��p���丅ৗ�1=�������F.��O榣�X�3�b�A�'�2�'e�"M�������g�2d��T�*�Ou�5�L���-�����85�j��Z�8�z3A5M�|`���-�����`�3r�l�=_�9���y�
�]����n�k�����jG�ت?�.H\����"�m�D�b��6t�9s���Aj���z��M��˪='�|�3R�6FK�Y�%����e!D���66mόu橹�����/�]���r��[��WP��)n ��K�庌EG����%f־!x�>�$�Oxr��K�!V�0e�(~�m�j~"R�'/�)��B�n��j3�F��Μ�IC��R�4�7=����A�)��2N_Q�GC���Q߽�z�m�(�H��/3F�;�s�S������J]c���k	N�x��gb:2MaTL�?��Igu0q�`�b3vK�G:�����M�?gӑC�ŉ����G��꽘+U�x
�8w�s��9"��Ԃ�%�g$��-�:M����Ƴ&��+3�eK�a ?ϋ�C`Y@�r9!��X3�@{�Zg�%�in���kL�A"�=�?�CkN{�B>!�c.	���ex�C�D�el�=���f��5{X�	4*A���(bZ:-:@��U��_��朳<*Vɱy��ܣkM>�Ԛj�_$��KC3�kE�AP�R�z���Y:'S�Ա��ǵ3H��}�������FEbQt<��hޕi���H���ac��r�6~�R�ysz�����p��^0xc�\yc4�~��5'��佚=$D�M�W�R��S ?I<��ռ6#�	H���x��£��, no�ٿt��4"�'X% �<f^T��c������!�C�@c���X�k�*�M�v�"UI�6H��L�� p/J�~)�uW����:�\�9���>�u��l(g�9����W�çF0sRQ5LQ[�۶�	�Gn�jeJ[�	�jZ�J�Rr+&�{&�e��'���Q�k  N<��N�����y�C�՝I���p1*�&��q�ZX�/�l�SF����drt�����!cE���ԟ6��mVB���G��r�Fl�������e�_�Uӻ�i/<�`��q����f{T�d����R�P�٪���C�e��4��`>�����o�-�WA�a�na�!��:�H=L���	��Y�lm!Ck�������l�8�\\�s��oW?m]���:oڒ�bͣ~fZ�mׂCġ+͒@ O�îeQ�1'�a8f�/�C
5�o�96�jt�F��Ѩx�I�V���6U�l�q!R�"��S������������1�R�Ί^�kE�}���h.v�Z����fb2����.X��� ~D����KE7F �_)�H��ia';�_ebU��i�w�I�>dgȝ[
��1�ae�U���v��lݱ��?!���B��J@ .�/�'��=RUt��2ٜ�O��<���h����]撮�y�ۻ����T��V�"W��͑۱O�v�˱��N��Iwя�h���M�B`�\)��O��an�S���HF�.���F=,��c���l>�qR�#eMvfx��b�`�1 hG򭵇Ix�p�^�FW1(�[����5�r��j���F�h��k�1�UZ}��a�(����񖥏?���h�����s�d��JG�CqC��g�ϐI�"�v���j�����,���n���oߋ�Pl'KI]]��(o��+�}𙽁S#�l��_I�j�mq�hy>�c0�	��2%��a����L����!JU{�+5��LKAMɱ��2�J^.d���!G��<�WK}S�_lww[�6wu����2�*�2-�4� �\�c�~�ƦK�/U��*��C����M��� 8�nr��awx� 5�
���ō��0Iy���5Ց^�ޛ1 �_�Q��ʍ.6���߫N��5�����Xtw3_�K� t_c�H�v2�I~�a�E��k�R�^-����@��G���&�X`��r����S�	l������"������m��P�	�<y	��?Z�]򗗝kxY� �J�X���%Yf�����~�� �z!�gEJ%��^C#�ޖҡ=�fb6t��UkQwҀhY|k�^m�����]
゘؝��#�����Q��g�L8���e?�B/JLZR�
���΋4.hp�=7�SJ�K@}�B
�� �	D{��
��_*���G�4�"�pӀG��^������?��i��B���k�G=�<�#d����u�'1�q�RL��ɴq�R�����s�_\����U�wz�&q��Ew]J�
8�X���嚦N8	�u���GKL�r~z�V�ӳ� O/���)��1��45��.'�s�l[./��=����gg�S�~@;��F~�X��&���c��?������p�QSP�mm���l����W����p��Жy�q��m�/c��yO3���ܐ�E�Bg���o\��](	P�%�{ f�����!���ٻL�#ÌJ!�ӥ�n��A= S��=���X]��|O|����p�
Kcg��p�4~ss׿~<�ߐ��=��GF�7��9�g�çy�i
ӡY)q{7���2նs�)��?�*��
 f��}wE%#����@'m5A�\�!ġ	p{vNF��I<�����1.�a'����l�{	�%m̻Z4����N���T�hGZ;U@LqCd("=��)| X.�C=N��Jf��8������le��u8@
}�����)`��'���'�|���*��      �   %  x����r�8���S���|�Y	�;�I������:64�%"�t��t�zv������˟t�:�u� ׻��K�i�Qkg�TU��$�!Ks�b..��~]uo��֠+Vښ��O�IH�E�0��|��A�2�=_�dT�W0K��]Y��z�*zg��!�G,yd��e7[yt�͗f�#�{�O���P���|�,�Y�	o 8�;����F����]�'�ZK���	<rA*�������:Tfiu�� {����-�f3q��z���V�^k��h:V������>�R��K&d���]���sA�ѯD%�;l�oʈ����:��v�N�;pKK�v%4'�K��J; ��,K$Kd����������?�����J/��mg�͇{���TN�L��	�g�]%�9�ga{�U��2v�պ�?{�?۫��>[?"w;0@�1%�dd�ÿ�\�X�%Q��<�1�i RR�5x���/���-^�Vm�r�jߊ�n_�y�%!#~,>�g߉[�uU������Ò8��%��,�)�#�:�����0��4��J<�?�����GF�	�ۢZ�͙��jo(.�m�����Iy�d΃��c8��`ձKp��x�V��=����2W����KP8_+P�E�㠗�b��"dRā�Hsd�m:�s��Xw�{�����x��zyVB���{��_&�#���cض�&����8�bȔ�V�7�H{����0����#��������'������eq��L"�	�V�E��z�"``���������_��      �   �  x�=R���@��|�K(@�~��(�Qv��l<
�O')���
Z��c\;(�-��s�y\lN�y�k��As�U�m�7w�Ϻ˥Y���O��q�@)o�$$���66oR�ϵ4mj����)Uz��u�ے��5���)M SP����8@8��4j̱-p.X����3�v��a�\�[��C��S%W6pš'W�2�;���lʐ(��Xǯ��9қ�^��s��Ό�:�ș�bWK_�9"�`9����͸���'|�������sA�y�k7��%ɾ%�����6v͋�i8�~�}(]^R��H�{���Y�-��DT.��.��.S ��� ���}S�@0���Q �ݦ��h�����t�ۜ�i�������S9G�v9]~�-$�e�}��BPu��NGm���^�:�N���L�Ikr�*�����<oCi{���~�K�vn��A8�ϯc� �úI      �   C  x�]Q�N�0<�~E� a�}LC�@����,��R�r��8������yvgvg�
�19�i�-�G���?c�PM�	]�/���glsZ�p��\�������=��K����(���U-�>���A��աړ�G͉���Q�j/K�J&�uEJE�U�]��LZԖ��o������Ȥ������0[RK��߆c�)I�`<����F��!�A�e�˞98�"�g���b%,i��]L�C�#���p����Ik���,�!=����7��S"��s��a��.����-I/a%����FXCz�C<�ʇ�=���/Z��      �   f   x�-��	�PE���*�1��O��2*���T��=���i^�u:�����;�%X�i���LGZ���m�q$z���.������-�7�� � �<       �   �  x��X�n�8}f�B? ��(����6�&vRl[,�d��F&Iv��M��}�?ȏ�H��`���@�(��������ʜ8��ڀӇ!���Re�շ�H$ʹG%��I���KhQ#�
�NmQ��楥���$'G����0���]��wk���Ϣ �x��y{��_>�xd��Nw0�|`��Y
���Li�=�J�@b�hHH�2IҴ���S�jFRMH��A1�G�H~̧����S�ic�>9�����s�jp:������=�C��)5��AL}�<$Y5a�-��Gl��f:UF�+n���.��重�	���-�A��}0:��͓�ʜ;Ua�GN>��F>X�5���Ymc?�%��� ys
�ƌҩ��Jg7�c��,[8�F�_,�G��Tđ�BKt^���X���jCQXLa�V�����=���7���L�U�j;c�����IHIC&)���bk��Y��T87��s�L��#���2��(��9Ed�{@.eU�ݹ����2iET���YJ��j�`Y�n,�#�c���_�g��O7�%����RO�J>��p.��`���R���K�2�\���	�����<���ѳ�\�X�����>��Ӌ�A&�Ej�S0����Ä��Q/�UW�I�[9�+�6�#�^����o�~��ޘg���/��s��4|����&	g�J���"7���������M�����L3��5O��.�f���7�� �w�߹�>e��e�oq�AHp���.�H���z"���qr���9J�b����9P謚̣a̩`u�-�W�z�=��t]'$��
�xz����������f��:�6�u����uZ���uz/k��|�a�뼚s|\���o�#�E�֏��3{�����"h$q�=CF�!�63?"�~���*f�eM�IM��WqTlڡ�ɇ����4Խy�i�;�&m�{-.Z(��o蟩�������,Ž�F�n�ӻ��y��N�p��h�w����r��>�y���d&��������bS�      �   �  x��W�n�0��>E^`(v�|�dk��6�� !���,)�G��></Ƶ[*6��q��r�&m�\�/k�qvu�6�tr�~#cY����}�q�a�D��..�l!X�.U�L�Yotwo��r�\xӘNQ|b��vЌ��2�(��'���
��L�+�h�u����1��V�D"�#�+'w*���p�w(Y�ֺ�5�Jn۾oI}a+&�C��?�b�	��~�_��;ݫAH@�*��4�]��G��r����f!�'����z��96�>�Ov':B�1��|�t���)�'�������N��#�ّ���H�td1:��:B���A���WQ���vGRb*W�Q4*���͈���~�{/=8X��p?zE��f%���J?�|j��Ud�n�9<�<�ɯ�Q&u��7i�̄��Xc{5�x��_*��i��y䅳��K��������IF*$Ám;O��DCI���$����Y��.����:8`����љ/�ն	�Vn�m�`��(�~5\7EU#��!J E�����jHkލ��iZ9GL�a�B�9C`T�y1�3 �4w�#�=k��_����{+�г_~�$��e*&�OZ�Q���;�Pf�sx( ~r�@�e�Z2e_T���KTc�"|�e�Y�1��Z,�1�      �   �   x�uP�1{�b<�G/鿎��d&���Z��@(�Ȗ��+�P �A���IQ��s^J�����	p���Hk㉸;��Ԋ�ڀ֨0+iAx�<O��#��:�\�c�a�c��JyC�q�M���QϦ�e��4�-�\�U��@�1��և�f��z�(�=E��)�;���xNi�sY��rC4�f�e�����Zoa&D      �   m   x����� ��3�R������G��mh�iH<xx�DX�)dⶱllW�p 3�'UMծ2��(�O%���<��
����טV�	����س�RC��� �J�      �     x�u�Mj�0�ףS�F���&��4�E)����'8N�ӳ�bS���C�y- �K�c�/��@���P�״�	z0�'��D�JX�d�����#��a	+��@��ŊUK�I^Ҽ@߂b�D�>C*�����y�	P�V,��H%��I��0s�wa���Y��/hο)c�=QL�vOɦ]e=��|"޷R���ܾ��x��x��L�Y�-"P���0�lJ�%]S���F��8��to�����#����!~ �-c�      �   o   x���CA�ji��yMp�}�����	B��5�a����á�1k��������0��Q*�P���4�F=�� ��Q�ǘ�C	o��r��yP�O�k����~H� �J     
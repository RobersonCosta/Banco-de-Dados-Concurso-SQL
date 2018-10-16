-- CREATE TABLE orgao(
-- 	codigo int primary key,
-- 	nome varchar(50)
-- );
-- 
-- CREATE TABLE concurso(
-- 	codigo int primary key,
-- 	descricao varchar(50),
-- 	data date,
-- 	edital varchar(500),
--  cargo varchar(50),
--  codigo_orgao int references orgao
-- );
-- 
-- CREATE TABLE prova(
-- 	codigo int primary key,
-- 	descricao varchar(50),
-- 	disciplina varchar(50),
--	codigo_concurso int references concurso
-- );
-- 
-- CREATE TABLE questao(
-- 	codigo int primary key,
-- 	resposta_gabarito varchar(400),
-- 	enunciado varchar(50),
--  codigo_prova int references prova
-- );
-- 
-- CREATE TABLE candidato(
-- 	cpf varchar(40) primary key,
-- 	num_inscricao int,
-- 	telefone varchar(40),
-- 	endereco varchar(40),
-- 	nome varchar(50)
-- );

-- CREATE TABLE candidato_questao (
-- 	codigo int primary key,
-- 	cod_questao int references questao,
-- 	cod_candidato varchar references candidato,
-- 	resposta_do_candidato varchar(50)
-- );







-- 1) create or replace function proximoVal(nomeTable varchar) returns integer as $$
-- 	Declare
-- 		queryResult integer;
-- 		queryString text;
-- 	Begin			
-- 		if nomeTable = 'candidato' then
-- 			queryString := 'select max(num_inscricao)+1 from ' ||  nomeTable;
-- 		else
-- 			queryString := 'select max(codigo)+1 from ' || nomeTable; // porque todas as tabelas sem ser a tabela candidato apresentam o mesmo nome de primary key (codigo)
-- 		end if;
-- 		
-- 		Execute queryString into queryResult;
-- 
-- 		return queryResult;
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select proximoVal('candidato');



-- 2) Create type gabarito as (enunciado varchar(255), resposta_certa varchar(255))


-- Create or replace function recuperarGabarito (concurso_codigo integer, cargo varchar) returns setof gabarito as $$
-- 	Begin			
-- 		return query(select questao.enunciado, questao.resposta_gabarito from questao
-- 		join prova on prova.codigo = questao.codigo_prova
-- 		join concurso on prova.codigo_concurso = concurso.codigo
-- 		where concurso.codigo = concurso_codigo and concurso.cargo = cargo);
-- 		
-- 		return;
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select * from recuperarGabarito(1,'cargo');



-- 3) select candidato.cpf, candidato.telefone, candidato.nome from candidato
-- join questao on candidato_questao.cod_questao = questao.codigo
-- join candidato_questao on candidato_questao.cod_candidato = candidato.num_inscricao
-- join prova on prova.codigo = questao.codigo_prova
-- join concurso on prova.codigo_concurso = concurso.codigo



-- 4) select candidato.telefone, candidato.cpf, candidato.nome, candidato.num_inscricao from candidato
-- join prova on prova.codigo = questao.codigo_prova
-- join questao on candidato_questao.cod_questao = questao.codigo
-- join candidato_questao on candidato_questao.cod_candidato = candidato.num_inscricao
-- join concurso on prova.codigo_concurso = concurso.codigo



-- 5) select concurso.data, orgao.nome from concurso
-- join orgao on concurso.codigo_orgao = orgao.codigo
-- where extract(year from concurso.data) = 2014




-- 6) Create or replace function candidatosNotInConcurso(concurso_codigo integer) returns setof candidato as $$
-- 	Begin			
-- 		return query(select candidato.* from candidato where candidato.num_inscricao not in(select candidato.num_inscricao from concurso 
-- 													join prova on prova.codigo_concurso = concurso.codigo
-- 													join questao on prova.codigo = questao.codigo_prova
-- 													join candidato_questao on candidato_questao.cod_questao = questao.codigo
-- 													join candidato on candidato_questao.cod_candidato = candidato.num_inscricao
-- 													where concurso.codigo = concurso_codigo)
-- 				);
-- --		return;
-- 		
-- 		
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select * from candidatosNotInConcurso(1);



-- 7) select count(orgao.*) as num_concursos, orgao.nome from orgao
-- join concurso on concurso.codigo_orgao = orgao.codigo
-- group by orgao.nome
-- order by num_concursos desc limit 1



-- 8) select count(questao.*) as num_questoes from questao
-- join prova on prova.codigo = questao.codigo_prova
-- where prova.disciplina = 'Legislação Trabalhista'




-- 9) Create or replace function respostasDeterminadoCandidato(num_insc integer) returns setof varchar as $$
-- 	Begin			
-- 		return query(select candidato_questao.resposta_candidato from candidato_questao
-- 				join candidato on candidato_questao.cod_candidato = candidato.num_inscricao
-- 				where candidato.num_inscricao = num_insc);
--		return;
-- 		
-- 		
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select * from respostasDeterminadoCandidato(5);



-- 10) Create or replace function questoesDeterminadoConcursoCandidato(concurso_codigo integer, num_insc integer) returns integer as $$
-- 	Declare
-- 		numeroDeAcertos integer;
-- 	Begin			
-- 		select count(candidato_questao.*) into numeroDeAcertos from concurso
-- 				join prova on prova.codigo_concurso = concurso.codigo
-- 				join questao on prova.codigo = questao.codigo_prova
-- 				join candidato_questao on candidato_questao.cod_questao = questao.codigo
-- 				join candidato on candidato_questao.cod_candidato = candidato.num_inscricao
-- 				where concurso.codigo = concurso_codigo and candidato.num_inscricao = num_insc  and candidato_questao.resposta_candidato = questao.resposta_certa;
-- 		
-- 		return numeroDeAcertos;
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select questoesDeterminadoConcursoCandidato(1,2);



-- 11) Create type pontos_candidato as (pontos bigint, nome varchar)

-- Create or replace function classificacaoConcurso(concurso_codigo integer) returns setof pontos_candidato as $$
-- 	Declare
-- 		classificacao varchar;
-- 	Begin			
-- 		Return query (select count(candidato_questao.*) as pontos, candidato.nome from concurso
--				join concurso on concurso_codigo = concurso.codigo
-- 				join prova on prova.codigo_concurso = concurso.codigo
-- 				join questao on prova.codigo = questao.codigo_prova
-- 				join candidato_questao on candidato_questao.cod_questao = questao.codigo
-- 				join candidato on candidato_questao.cod_candidato = candidato.num_inscricao
-- 				where candidato_questao.resposta_candidato = questao.resposta_certa
-- 				group by nome
-- 				order by pontos desc);
-- 		
-- 		return;
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select * from classificacaoConcurso(1);


-- 12) Create or replace function primeiroColocado(concurso_codigo integer) returns candidato as $$
-- 	Declare
-- 		primeiro_colocado candidato;
-- 	Begin			
-- 		select candidato.* into primeiro_colocado from concurso
--              join concurso on concurso_codigo = concurso.codigo
-- 				join prova on prova.codigo_concurso = concurso.codigo
-- 				join questao on prova.codigo = questao.codigo_prova
-- 				join candidato_questao on candidato_questao.cod_questao = questao.codigo
-- 				join candidato on candidato_questao.cod_candidato = candidato.num_inscricao
-- 				where candidato_questao.resposta_candidato = questao.resposta_certa
-- 				group by candidato.num_inscricao, candidato.nome, candidato.telefone, candidato.endereco, candidato.cpf
-- 				order by count(candidato_questao.*) desc limit 1;
-- 		
-- 		return primeiro_colocado;
-- 		
-- 			
-- 	End
-- 
-- $$ language plpgsql;

-- select * from primeiroColocado(1);
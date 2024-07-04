#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} PdAudit
Fun��o para carga do HashMap contendo as informa��es de rotinas e tabelas com dados sens�veis.
@author Gisele Nuncherino
@since 05/12/2019
@version 1.0
@param oHash, objeto, vari�vel a ser alimentada com o nome da rotina e as tabelas com dados sens�veis acessadas pela rotina.
/*/

function PdAudit(oHash)
//Aten��o! Ordenar os fontes em ordem alfab�tica para n�o ocorrer duplicidade de informa��es.

//Rotinas RH
oHash:Set('ANOA001','RHO|SPW|RHP|SRQ|SRL|RHM|SRB|SQG|SRA|RBW|REY|RGC|RIE|SM8|RCS|RCU|RD0|RFI|RI6|REZ|SR4|RH3' ) //Rotina Anonimizacao RH

//Rotinas M�dulo APD
oHash:Set('APDA020','SRA|RD0' ) //Cadastro Participantes
oHash:Set('APDA070','RD0' ) 	//Aloca��o Participantes x Vis�es
oHash:Set('APDA100','RDV|RD0' ) //Cadastro Participantes  x Objetivos
oHash:Set('APDA170','SRA|RD0' ) //Cadastro Participantes x Vis�es
oHash:Set('APDA210','RBP|RBQ|RD0' ) //Cadastro de Participantes/Pessoas vs Mapa de Conhecimento
oHash:Set('APDA240','RDC|RDA|RD6|RD9|RD0' ) //Visualizacao e grafico relacionado ao Cabecalho Montagem Avaliacoes (RD6)
oHash:Set('APDA250','RD6|RD0' ) //Resultados de Participantes por Avalia��es
oHash:Set('APDA260','RD6|RD0' ) //Resposta, refinamento e resultados de Avalia��es por Participantes
oHash:Set('APDA270','RDA|RD6|RDC|RD9|RD0' ) //Cadastro de Avaliacoes
oHash:Set('APDM010','RD6|RDC|RD0' ) //Calculo do Resultado da Avaliacao a partir das Avaliacoes e/ou Avaliados selecionados (Miscelanea).
oHash:Set('APDM020','RBP|RD0|SRA' ) //Geracao Automatica do Mapa de Conhecimento
oHash:Set('APDM030','RDV|RD0' ) //Geracao Automatica: PDP ou Plano de Metas
oHash:Set('APDM040','RDV|RD0' ) //Resultados de Metas
oHash:Set('APDM050','RDV|RD6|RD0' ) //Resultados de Pol�tica de Consolida��o
oHash:Set('APDPGONL','RD6|RDC' ) //PAINEL Modulo APD
oHash:Set('APDR010','RD6|RD0' ) //Relatorio Resultado Global
oHash:Set('APDR020','RD6|RD0' ) //Relatorio Comparativo Global
oHash:Set('APDR030','RD6|SRA|CTT|RD0' ) //Ranking Performance por Avaliado
oHash:Set('APDR040','RD6|SRA|CTT|RD0' ) //Ranking Performance por Visao
oHash:Set('APDR050','RD6|RDC|RD0' ) //Relatorio de Pendencia de Avaliacoes
oHash:Set('APDSNDAV','RD6|RDC|RD0' ) //Automacao do Processo de Envio de Avaliacoes
oHash:Set('APIGETSTRUCTURE','SRA|CTT|SR8|RD0|RCX|RH3' ) //Metodo Portal RH

//Rotinas M�dulo APT
oHash:Set('APTA060','RE0' ) //Cadastro de Varas
oHash:Set('APTA080','RE0' ) //Cadastro de Tipos
oHash:Set('APTA100','RE9|REL|RE0|SE2|SA2|RD0' ) //Cadastro dos Processos Trabalhistas
oHash:Set('APTA120','RD0' ) //Cadastro de Registros de Classe
oHash:Set('APTC010','REL|RE0|RD0' ) //Agenda de acompanhamento do processo
oHash:Set('APTM010','RGB|SRA' ) //Integracao APT com GPE
oHash:Set('APTPGONL','RE0' ) //PAINEL Modulo APT
oHash:Set('APTR010','RE0|RD0' ) //Resumo dos Processos.
oHash:Set('APTR020','RE9|SA1|REL|SRA|RE0|SE2|RD0' ) //Historico dos Processos.
oHash:Set('APTR030','RE0' ) //Pauta das audiencias
oHash:Set('APTR040','REL|RE0' ) //Demonstrativo de Resultados dos Pleitos

//Rotinas M�dulo ATF
oHash:Set('ATFA003','FNL' ) //Cadastro de Al�adas de aprova�?o por opera�?o
oHash:Set('ATFA004','FNM' ) //Cadastro de Opera�?es com controle de aprova�?o

//Rotinas M�dulo CEN - TOTVS Sa�de Central de Obriga��es (93 - SIGACEN)
//WSRESTFUL
oHash:Set('HEALTHCARE','BEJ|B3R|B3X|B3K') //

oHash:Set('PLSCENTOBR','BA1' ) // Painel de Obriga��es - FWmBrowse Inferior Compromissos
oHash:Set('CenValOpc','BTC' ) // Movimen. SIB

//Rotinas M�dulo CSA
oHash:Set('CSAA070','SRA' ) //Cadastro das Tabelas Salariais
oHash:Set('CSAA080','SRA' ) //Cadastro de Aumento Programado
oHash:Set('CSAA090','SRA|RBE' ) //Cadastro de Quadro de Funcionarios
oHash:Set('CSAA100','SRA|RH3' ) //Cadastro dos Departamentos
oHash:Set('CSAM010','SRA' ) //Atualiza o salario do funcionario conforme Tabela Salarial
oHash:Set('CSAM020','SRA' ) //Atualiza as referencias das graduacoes dos funcionarios
oHash:Set('CSAM030','SRA' ) //Adequacao da Tabela Salarial para o funcionario
oHash:Set('CSAM080','SRA' ) //Atualiza aumento programado do funcionario
oHash:Set('CSAM090','RA2|SQS|RBE' ) //Aprovavao de Novas Vagas.
oHash:Set('CSAPGONL','SRA' ) //PAINEL Modulo CSA
oHash:Set('CSAR020','SRA|CTT' ) //Relatorio de Graduacao de Fatores X Funcionarios
oHash:Set('CSAR030','SRA' ) //Relatorio de Aumento Salarial conforme Tabela
oHash:Set('CSAR040','SRA' ) //Relatorio de Pontuacao de Funcionarios
oHash:Set('CSAR050','SRA|CTT' ) //Relatorio de Aumento Programado dos funcionarios

//Rotinas M�dulo CTB
oHash:Set('CTBA015','CVB') //Cadastro de Contabilistas
oHash:Set('CTBA016','CVC') //Cadastro do Participante
oHash:Set('CTBA018','CVR') //Cadastro de Auditores
oHash:Set('CTBA750','CQH') //Apuracao Contabil Projeto
oHash:Set('CTBS001','CS8|CS9|CSP|CVB|CVC|CVR|CVV|CQO') //Exporta�?o ECD
oHash:Set('CTBS410','CS8|CQO|CVV') //Cadastro do Bloco W
oHash:Set('CTBS450','CVV') //Cadastro do Bloco V=ECF=DEREX

//Rotinas M�dulo FIN
oHash:Set('CDAA010','SA2' ) // Cadastro de Contratos
oHash:Set('CDAA020','SA2' ) // Atual. de Movimentacao
oHash:Set('FINA040','SA6|SA1|SE1|SE5|SEF' ) //Contas a Receber
oHash:Set('FINA045',"SA1") //Renegocia��o de T�tulos a Receber
oHash:Set('FINA050','SA6|SA2|SE2|SE5|SEF' ) //Contas a Pagar
oHash:Set('FINA060',"SA1|SA6") //Transfer�ncias
oHash:Set('FINA061',"SA1|SA6|SE1") //Border� de Cobran�as
oHash:Set('FINA069',"SA1") // Bordero de Distribuicao de Cobrancas
oHash:Set('FINA070',"SA1|SA6|SE1|SE3|SEF") //Baixas a Receber
oHash:Set('FINA080',"SA2|SA6|SE2|SE9|SEF") //Baixas a Pagar
oHash:Set('FINA087a',"SA1|SA6|SE1|SEF|SEL") //Recebimentos Diversos
oHash:Set('FINA090',"SE2|SEF|SA2|SA6") //Baixas a Pagar Autom�tica
oHash:Set('FINA091',"SE2|SEF|SA2|SA6") //Baixas a Pagar Autom�tica Multi Filial
oHash:Set('FINA100',"SE5|SA6") //Movimento Banc�rio
oHash:Set('FINA110',"SE1|SA1|SA6") //Baixas a Receber Autom�tica
oHash:Set('FINA120',"SA6") //Contrato Banc�rio
oHash:Set('FINA130',"SA6|SEE") //Par�metros Bancos
oHash:Set('FINA140',"SA6") //Ocorr�ncia CNAB
oHash:Set('FINA150',"SA6") //Arquivo de Cobran�a
oHash:Set('FINA151',"SA6") //Instru��o de Cobran�a
oHash:Set('FINA160',"SE5") //Border� de Cheques
oHash:Set('FINA171',"SE9|SEH|SA2|SA6") //Aplica��o e Empr�stimo
oHash:Set('FINA181',"SE9|SEH|SA6") //Resgate, Pagamentos Empr�stimos
oHash:Set('FINA183',"SE9|SEH|SA2|SA6") //Apropria��o Aplica��o por Cotas
oHash:Set('FINA190',"SEF|SA1|SA2|SE1|SE2") //Gera��o de Cheques
oHash:Set('FINA191',"SA1|SA2|SA6|SEF") //Cheques Recebidos
oHash:Set('FINA200',"SA6") //Retorno de Cobran�as
oHash:Set('FINA210',"SA6") //Rec�lculo de Saldos Banc�rios
oHash:Set('FINA240',"SA2|SE2") //Border� de Pagamentos
oHash:Set('FINA241',"SA2|SE2") //Border� de Pagamentos com Impostos
oHash:Set('FINA250',"SA1|SA2|SA3|SA6|SE1|SE2") //Rastreamento
oHash:Set('FINA260',"SE2|SA2|FIG") //Concilia��o DDA
oHash:Set('FINA290',"SA2|SE2") //Faturas a Pagar
oHash:Set('FINA300',"SA2|SE2") //SISPAG
oHash:Set('FINA330',"SA1|SE1") //Compensa��o de Contas a Receber
oHash:Set('FINA340',"SA2|SE2") //Compensa��o de Contas a Pagar
oHash:Set('FINA373',"SA2|SE2") //Controle de DARF
oHash:Set('FINA374',"SA2|SE2") //Apura��o PIS, COFINS e CSLL a Pagar
oHash:Set('FINA376',"SA2|SE2") //Apura��o Impostos
oHash:Set('FINA377',"SA2|SE2") //Apura�ao INSS
oHash:Set('FINA377a',"SA1|SE1") //Acertos INSS Contas a Receber
oHash:Set('FINA378',"SA2|SE2") //Aglutina��o de Impostos - PIS, COFINS e  CSLL
oHash:Set('FINA380',"SA6|SE5") //Concilia��o Banc�ria
oHash:Set('FINA381',"SA2|SE2") //Aglutina��o de Impostos - IRRF, PIS, COFINS e  CSLL
oHash:Set('FINA390',"SEF|SA2") //Cheques Sobre T�tulos
oHash:Set('FINA401',"SA2") //Gera Dados para DIRF
oHash:Set('FINA402a',"SA2") //Dados SEFIP
oHash:Set('FINA403',"SA2") //Gera DIRF Empresas P�blicas
oHash:Set('FINA404',"SA1|SA2") //Fornecedores Aut�nomos
oHash:Set('FINA405',"SA2") //Cadastro de repasse IRPJ
oHash:Set('FINA410',"SA1|SA2")
oHash:Set('FINA415',"SA1") //Elimina��o de Res�duos
oHash:Set('FINA420',"SA2|SA6|SE2") //Arquivo de Pagamentos
oHash:Set('FINA430',"SA2|SA6|SE2") //Retorno de Pagamentos
oHash:Set('FINA440',"SA3")
oHash:Set('FINA450',"SA1|SA2|SE1|SE2") //Compensa��o Entre Carteiras
oHash:Set('FINA460',"SA1|SE1") //Liquida��o
oHash:Set('FINA460A',"SA1|SE1") //Simula��o da Liquida��o
oHash:Set('FINA473',"SA6|SE5") //Concilia��o Autom�tica
oHash:Set('FINA480',"SA6") //Ocorr�ncia de Extrato
oHash:Set('FINA540',"SA1|SA2|SA6") //Negocia��o de CDCI
oHash:Set('FINA550',"SA6") //Manuten��o do Caixinha
oHash:Set('FINA560',"SA2") //Movimento do Caixinha
oHash:Set('FINA565',"SA2|SE2") //Liquida��o
oHash:Set('FINA580',"SE2") //Libera��o para Baixa
oHash:Set('FINA585',"SA2|SE2") //Libera��o para Baixa
oHash:Set('FINA590',"SE2|SA2|FIL|SE1|SA1") //Manuten��o de Border�
oHash:Set('FINA620',"SA1|SE1") //Solicita��o de Transfer�ncia
oHash:Set('FINA621',"SA1|SE1") //Aprova��o e Rejei��o da Transfer�ncia
oHash:Set('FINA630',"SA2|SE2") //Solicita��o de Transfer�ncia
oHash:Set('FINA631',"SA2|SE2") //Aprova��o e Rejei��o da Transfer�ncia
oHash:Set('FINA650',"SE1")
oHash:Set('FINA645',"SA1|SE1") //Provis�o de Devedores Duvidosos
oHash:Set('FINA665',"FLC|FLD|FLU|FLJ|FL5|FL6|RD0|") //Viagens
oHash:Set('FINA666',"FW3|FW5") //Solicita��o de Viagens
oHash:Set('FINA667',"FLD") //Adiantamentos
oHash:Set('FINA675',"RD0") //Transfer�ncia Participante
oHash:Set('FINA677',"FLF") //Presta��o de Contas
oHash:Set('FINA683',"FLI|RD0") //Grupos de Acesso
oHash:Set('FINA685',"FLQ") //Confer�ncia de Servi�os
oHash:Set('FINA686',"FLQ") //Confer�ncia de Servi�os II
oHash:Set('FINA692',"FWN") //Concilia��o de Viagens
oHash:Set('FINA693',"FWN") //Concilia��o de Viagens
oHash:Set('FINA694',"FWN") //Concilia��o de Viagens
oHash:Set('FINA720',"SA1|SE1") //Gera��o de NF
oHash:Set('FINA740',"SA1|SA3|SE1") //Fun��es Contas a Receber
oHash:Set('FINA750',"SA2|SE2") //Fun��es Contas a Pagar
oHash:Set('FINA770',"SA1|SE1") //Lotes Serasa
oHash:Set('FINA771',"SA1|SE1") //Serasa - Retirada Manual
oHash:Set('FINA811',"SA1|SE1") //Envio de Carta de Cobran�a
oHash:Set('FINA870',"SA2|SE2") //Emiss�o de GPS
oHash:Set('FINA910',"SE1|FIF") //Conciliador TEF
oHash:Set('FINA940',"SA1|SA6") //C�lculo AVP CR
oHash:Set('FINA950',"SA2|SA6") //C�lculo AVP CP
oHash:Set('FINA994',"FOD") //Cadastro de S�cios SCP
oHash:Set('FINA791',"FO8") // Fatura de Hotel
oHash:Set('FINA960',"FR5") // Apura��o de IRPJ/CSLL lucro real
oHash:Set('FINC010',"SE1") //Posi��o de Cliente
oHash:Set('FINC021',"SE1|SE2") //Fluxo de Caixa
oHash:Set('FINC025',"SE1|SE2") //Hist�rico de Fluxo de Caixa
oHash:Set('FINC030',"SE2") //Posi��o de Fornecedor
oHash:Set('FINC040',"SA1|SA3|SE1") //Posi��o de T�tulos a Receber
oHash:Set('FINC040VA',"FKD") //Posi��o de T�tulos a Receber Valores Acessorios
oHash:Set('FINC050',"SA2|SE2") //Posi��o de T�tulos a Pagar
oHash:Set('FINC050VA',"FKD") //Posi��o de T�tulos a Pagar Valores Acessorios
oHash:Set('FINR020','SA1|SE1' ) // Livro de Duplicatas
oHash:Set('FINR087','SA1|SEL|SE5' ) // Recebimento Diversos
oHash:Set('FINR120','SA6|SE8|SE5' ) // Movimento Caixa Di�rio
oHash:Set('FINR127','SA1|SE1|SE5' ) // Quita��o de D�bitos
oHash:Set('FINR130','SA6|SA1|SE1' ) // T�tulos a Receber
oHash:Set('FINR133','SA1|SE1' ) // Aging Receber
oHash:Set('FINR134','SA2|SE2' ) // Aging Pagar
oHash:Set('FINR137','SE1|SE5' ) // T�tulos a Receber Por Vendedor
oHash:Set('FINR138','SA1|SE1' ) // T�tulos a Receber Por Natureza
oHash:Set('FINR139','SA1|SE1' ) // T�tulos a Receber Nf-e
oHash:Set('FINR140','SA6|SEH|SA2|SA1|SE1|SEF|SE8|SE2|FJA|SE5|SE9|SEG' ) // Fluxo Caixa Anal�tico
oHash:Set('FINR150','SA2|SE2' ) // T�tulos a Pagar
oHash:Set('FINR158','SA2|SE2' ) // T�tulos a Pagar Por Natureza
oHash:Set('FINR170','SA6|SA2|SA1|SE1|SEA|SE2' ) // Emiss�o Border�s
oHash:Set('FINR180','SA6|SA2|SA1|SE1|SE2|SE5' ) // Baixas Por Lote
oHash:Set('FINR190','SA6|SEH|SA2|SA1|SE1|SE2|SEI|SE5' ) // Rela��o de Baixas
oHash:Set('FINR195','SA2|CTT|SE2|SE5' ) // Mapa de Rateio
oHash:Set('FINR198','SA2|SE1|SE2|SE5' ) // Rela��o de Baixa Por Natureza
oHash:Set('FINR200','SA6|SEH|SA2|SA1' ) // Di�rio Sint�tico Por Natureza
oHash:Set('FINR270','SA1' ) // Hist�rico Clientes
oHash:Set('FINR280','SA6|SA1|SE1|SE5' ) // Juros Recebidos
oHash:Set('FINR290','SA6|SA1|SE1|SE5' ) // Juros Devidos N�o Pagos
oHash:Set('FINR295','SE2|SE5' ) // Detalhe de Faturas
oHash:Set('FINR300','SA1|SE1' ) // Maiores Devedores
oHash:Set('FINR320','SA6|SE1|SE5' ) // Posi��o Geral Cobran�a
oHash:Set('FINR330','SA6|SE2|SE5' ) // Posi��o Geral Contas a Pagar
oHash:Set('FINR340','SA1|SE1|SE5' ) // Posi��o Clientes
oHash:Set('FINR350','SA2|SE2|SE5' ) // Posi��o Fornecedores
oHash:Set('FINR355','SA2|SE2|SE5' ) // Impostos Por Fornecedores
oHash:Set('FINR400','SA6|SEF' ) // Rela��o de Cheques
oHash:Set('FINR405','SA2' ) // Repasse Imposto de Renda Pessoa Jur�dica
oHash:Set('FINR450','SA1|SE1' ) // Sugest�o de Bloqueio
oHash:Set('FINR460','SA6|SA2|SEF|FK5|SE2|SE5' ) // Cheques Especiais
oHash:Set('FINR460A','SA1|SE1|FO2' ) // Acordos de Liquida��o
oHash:Set('FINR470','SA6|SE1|SE8|SE2|SE5' ) // Extrato Banc�rio
oHash:Set('FINR480','SA6|SE1|SEF|FK5|SE2|SE5' ) //Impress�o de Cheques
oHash:Set('FINR490','SA2|SA1|SE1|SEF|SE2' ) // C�pia de Cheques
oHash:Set('FINR500','SE1|SE2|SE5' ) // Liquida��o
oHash:Set('FINR501','SE1|SE5' ) // Liquida��o (cr)
oHash:Set('FINR502','SE1|SE2|SE5' ) // Liquida��es (cp)
oHash:Set('FINR510','SA2|SA1|SE1|SE2|SE5' ) // Di�rio Auxiliar
oHash:Set('FINR520','SA2|SA1|SE1|SE2|SE5' ) // Compensa��o Entre Carteiras
oHash:Set('FINR530','SA6|SE8|SE5' ) // Movimento Financeiro Di�rio
oHash:Set('FINR540','SA6|SEF' ) // Cheques Cancelados
oHash:Set('FINR550','SA2|SA1|SE1|SS2|SE2|SE5' ) // Razonete
oHash:Set('FINR560','SEU|SET' ) // Movimentos
oHash:Set('FINR565','SA6|SEU|SET' )  // Recibo de Caixa
oHash:Set('FINR580','SEU|SET' ) // Baixa de Caixa
oHash:Set('FINR585','SE2' ) // Libera��o de Documento
oHash:Set('FINR590','SE1|CTT|SE2|SE5' ) // Mapa de Distribui��o de M�ltiplas Naturezas
oHash:Set('FINR600','SA6|SA1|SE1' ) // Boleto Gen�rico
oHash:Set('FINR610','SA1|SE1|SE5' ) // Previs�o de Comiss�es
oHash:Set('FINR620','SA6|SE1|SEF|SE2|SE5|SE8' ) // Movimento Banc�ria
oHash:Set('FINR645','SA1|FJY|SE1' ) // Provis Dev Duvidos
oHash:Set('FINR650','SA2|SE1|SEE|SE2|SEB' ) // Relat�rio de Retorno Cnab
oHash:Set('FINR660','SA6|SE1|SE5|SEB' ) // T�tulos Enviados Ao Banco
oHash:Set('FINR665','SA2|SA1|FL5|FLD|FLJ|FLF|RD0|FL6|FLQ' ) // Viagens
oHash:Set('FINR677','SA2|SA1|SE2|FLF|FLD' ) // Prestacao de Contas
oHash:Set('FINR678','SA1|FLF|RD0' ) // Status Presta��o de Contas
oHash:Set('FINR680','SA6|SEE|SEJ' ) // Relat�rio de Extrato Cnab
oHash:Set('FINR694','SEA|SE2|FWN|FL6|FLQ' ) // Concilia��o de Viagens
oHash:Set('FINR710','SA6|SA2|SEF|SEA|SE2|SE5' ) // Border� Pagamentos
oHash:Set('FINR720','SA6|SE7|SEH|SE1|SEF|SE2|SEI|SE5' ) // Or�ados X Reais M�s
oHash:Set('FINR721','SA6|SE1|SEF|CTT|SE2|SE5' ) // Or�ados X Reais M�s Por Centro de Custo
oHash:Set('FINR730','SA6|SE7|SE1|SEF|SE2|SE5|CTT' )  // Or�ados X Reais Ano
oHash:Set('FINR731','SA6|SE1|SEF|CTT|SE2|SE5' )  // Or�amentos X Reais Ano Por Centro de Custo
oHash:Set('FINR740','SE1' )  // Boleto - Rdmake
oHash:Set('FINR750','SA6|SE1|SE5' ) // Efici�ncia Cobran�a
oHash:Set('FINR760','SA6|SE2|SE5' )  // Efici�ncia Contas a Pagar
oHash:Set('FINR770','SA6|SE1|SE2|SE5' ) // Fluxo Caixa Realizado
oHash:Set('FINR801','SA6|SA1|SE1|SEF|SE5' ) // Movimento M�s a M�s
oHash:Set('FINR811','SA1|SE1' )  // Carta de Cobran�a
oHash:Set('FINR820','SEH|SE0|SE9' ) // Demonstrativo Aplica��o
oHash:Set('FINR830','SEH|SEI' ) // Hist�ria de Aplica��o
oHash:Set('FINR840','SA6|SEH|SE1|SE2|SE5|SEG' )  // Resumo Financeiro
oHash:Set('FINR850','SA6|SEE|SE2|SE5|SEB' )  // Relat�rio de Retorno Sispag
oHash:Set('FINR855','SA2|SE2' ) //T�tulos a Pagar Com Reten��o de Impostos
oHash:Set('FINR860','SA1|SE1' ) // Reten��o Inss
oHash:Set('FINR865','SA2|SE2' ) // Reten��o Impostos
oHash:Set('FINR870','SEH' ) // Demonstrativo Empr�stimo
oHash:Set('FINR875','SA2|SE2' )  // Relat�rio de Aglutinadores
oHash:Set('FINR895','SE2|SE5' ) // Demonstrativo Pis, Cofins e Csl
oHash:Set('FINR898','SA1|SE1|SEL|SAQ' ) // Recebimento Diversos X Clientes
oHash:Set('FINR899','SA1|SEL' ) // Relat�rio de Recibos Por Cliente
oHash:Set('FINR905','SA1|SE1' ) // T�tulo Avp Cr
oHash:Set('FINR907','SA2|SE2' ) // T�tulos Avp Cp
oHash:Set('FINR915','FJP' ) // Minha Casa Minha Vida
oHash:Set('FINR930','SA2|SE2|SE5' ) // Relat�rio de Aglutina��o de Imposto
oHash:Set('FINR940','SA1|SE1|SE2' ) // T�tulos a Receber Com Reten��o de Impostos
oHash:Set('FINR960','SA1|SE1|FK5' ) // Dme - Declara��o de Moedas Em Esp�cie
oHash:Set('FINRGPS','SA2|SE2' ) // Emiss�o de Gps
oHash:Set('FINRSRF','SA2|SE2' ) // Emiss�o de Darf


//Rotinas M�dulo GPE
oHash:Set('GPEA001','RHL|RHM|SRB|SRA|RHN|SRC' ) //Controle de Planos Ativos - Ass. Medica e Odontologica
oHash:Set('GPEA002','SRA|RHN' ) //Historico de Alteracoes dos Planos Ativos
oHash:Set('GPEA003','RHL|RHO|RHM|SRA|RHN' ) //Lancamento de Co-Participacao e Reembolso
oHash:Set('GPEA004','RHO|RHP|SRA' ) //Corre��o fechamento co-participa��o para a DIRF
oHash:Set('GPEA005','SRA' ) //Corre��o fechamento co-participa��o para a DIRF
oHash:Set('GPEA010',"SRA|RD0|SQS|RCX|RGE|SQG|SRC|RID|SRF|RGB|SV7" ) //Cadastro de Funcionarios
oHash:Set('GPEA011','SRA' ) //Gestao de Funcionarios
oHash:Set('GPEA016','SRA' ) //Cadastro de Per�odo de Gesta��o
oHash:Set('GPEA020','RHL|SRB|SRA' ) //Cadastro de Dependentes
oHash:Set('GPEA050','SRA|RHI|SRF|SR8' ) //Controle de Dias de Direito
oHash:Set('GPEA051','RI8|SRH|RIA|SRA|SR8|SRF|RI6' ) //Controle de Dias de Direito - GFP
oHash:Set('GPEA052','SRA' ) //Solicita��o de f�rias via Fluig
oHash:Set('GPEA053','SRF' ) //F�rias Programadas em Lote
oHash:Set('GPEA056','SRA' ) //Cadastro de Programa��o de Rateio (RHQ)
oHash:Set('GPEA056A','SI3|SRA|CTT' ) //Rotina de Programacao de Rateio em Lote.
oHash:Set('GPEA060','RC8|SRA' ) //Cadastro de Resultados de Exames
oHash:Set('GPEA065','SRA' ) //Cadastro de Outros Benef�cios
oHash:Set('GPEA066','SRA' ) //Calculo de outros beneficios
oHash:Set('GPEA067','SRA' ) //Definicao de Beneficios
oHash:Set('GPEA068','SRA' ) //Dados do Calculo de outros beneficios
oHash:Set('GPEA070','SRA' ) //Provisao
oHash:Set('GPEA071','SRA' ) //Manuten��o Provisao Rateada (RHT)
oHash:Set('GPEA080','SRA' ) //Cadastro de Turno de Trabalho
oHash:Set('GPEA090','RGB|SRA|SRC' ) //Cadastro Valores Variaveis
oHash:Set('GPEA091','RFV|SRA' ) //Consulta de Mem�ria de C�lculo do Funcion�rio.
oHash:Set('GPEA100','RGB|SRA|SRC' ) //Cadastro Valores Variaveis por Codigo
oHash:Set('GPEA110','SRA|RGB' ) //Cadastro Valores Futuros
oHash:Set('GPEA120','SRA' ) //Manutencao Acumulados Anuais
oHash:Set('GPEA131','SRA' ) //Cadastro de Beneficios - VT/VR/VA
oHash:Set('GPEA132','SRA' ) //Historico de Beneficios - VT/VR/VA
oHash:Set('GPEA133','SRA' ) //Cadastro de Beneficios - VT/VR/VA
oHash:Set('GPEA180','SRA|SRG|SRH|RGB|SRC|SR8|RI6|RD0|C1E' ) //Transferencias
oHash:Set('GPEA190','SRA|SRC' ) //Cadastro Valores de Tarefas
oHash:Set('GPEA240','SA1|SRA|RI8|SRF|SR8|RH3|RCX' ) //Cadastro de Ausencias
oHash:Set('GPEA250','SA1|SRA' ) //Historico Salarial
oHash:Set('GPEA260','SRH|SRB|SRA|SR8' ) //Cadastro de Salarios
oHash:Set('GPEA261','SRA|RA4' ) //Consulta dos Treinamentos dos Funcion�rios
oHash:Set('GPEA265','SRA|RD0|RCX|SA2|C9V' ) //
oHash:Set('GPEA270','SRW' ) //Cadastro de Controle de Acessos
oHash:Set('GPEA280','SRA|SRQ' ) //Beneficiarios
oHash:Set('GPEA281','SM3' ) //Cadastro de plano de sa�de para c�lculo por agrupamento
oHash:Set('GPEA350','SRA|RC9' ) //Cadastro de Comunicado de Acidente do Trabalho
oHash:Set('GPEA360','SRA' ) //Cadastro de PPP
oHash:Set('GPEA370','SRA' ) //Cadastro de Cargos vers�o MVC
oHash:Set('GPEA400','SRC' ) //Cadastro do Calendario
oHash:Set('GPEA415','SRA' ) //Amortizaciones
oHash:Set('GPEA430','SR8' ) //Cadastro de Tipo de Afastamentos (Ausencias)
oHash:Set('GPEA470','RG7' ) //Cadastro dos Criterios de acumulacao
oHash:Set('GPEA480','SRA|RG7' ) //Cadastro dos Acumuladores
oHash:Set('GPEA550','SRA|RAZ' ) //Lancamentos Fixos
oHash:Set('GPEA551','SRA|RCS' ) //Previdencia Complementar
oHash:Set('GPEA580','RGB|SRA' ) //Lancamentos por Periodo - RGB
oHash:Set('GPEA590','RGB' ) //Lancamentos por Verba - RGB
oHash:Set('GPEA630','SRA|SRC' ) //Consulta Lancamentos (Recibo de Pagamento)
oHash:Set('GPEA642','SRA|TIT' ) //Cadastro de Pontua��o
oHash:Set('GPEA643','TIT|SRA|SR8' ) //Gest�o de Disciplina
oHash:Set('GPEA644','TIT|SRA' ) //Gest�o de Disciplina
oHash:Set('GPEA660','SRA|RGC' ) //Manutencao Localidade de Pagamento
oHash:Set('GPEA710','RGB|SRA|RG3|SRC' ) //Cadastro do Controle de Restricao de Acesso a Rotinas.
oHash:Set('GPEA810','SRG|SRA|SRF|RE0' ) //Reintegracao de funcionarios
oHash:Set('GPEA840','SRA' ) //Cadastro de RRA
oHash:Set('GPEA900','RGE|SRA' ) //Historico de Contratos
oHash:Set('GPEA920','SRA' ) //Informacoes Exclusivas Estagio
oHash:Set('GPEA923','SRA' ) //Cadastro de Estabilidades (RFX)
oHash:Set('GPEA924','SRA|RAZ' ) //Multiplos Vinculos
oHash:Set('GPEA925','SRA|SRG' ) //Cadastro de Aviso Pr�vio (RFX)
oHash:Set('GPEA926','SRA' ) //Cadastro de Sucess�o de V�nculos (RFZ)
oHash:Set('GPEA927','SRA|RBW|SR8' ) //Informacoes de Funcionarios Temporarios (RBW)
oHash:Set('GPEA927A','SRA' ) //Prorroga��es do Contrato de Trabalho, Funcion�rios Tempor�rios
oHash:Set('GPEA928','RFS|SRA|RBW' ) //Informacoes eSocial
oHash:Set('GPEA931','SRA' ) //Agentes Publicos
oHash:Set('GPEA933','SRA' ) //Observa��es contratuais para envio do esocial
oHash:Set('GPEA937','SRA' ) //eSocial - Troca de CPF
oHash:Set('GERA2299','SRA' ) //eSocial - evento S-2299/S-2399 na Troca de CPF
oHash:Set('GERA2200','SRA' ) //(GPEA937B) eSocial - evento S-2299/S-2200 na Troca de CPF
oHash:Set('GPEM008','SRA' ) //Calculo do Plano de Saude
oHash:Set('GPEM009','SRG|SRA|RGB' ) //Integracao do calculo de Plano de Saude com a Folha de Pagamento
oHash:Set('GPEM011','SRA' ) //Cancelamento do Calculo de Plano de Saude
oHash:Set('GPEM012','SRA|RG7' ) //Recriacao de Acumuladores
oHash:Set('GPEM013','SRA|SRC' ) //Desoneracao Folha
oHash:Set('GPEM015','SRA|RGB' ) //Integracao Folha - Vale Refeicao, Alimentacao e Transporte
oHash:Set('GPEM016','RHL|SRA|RHM|RHN' ) //Calculo do Plano de Saude
oHash:Set('GPEM017','C9V|CUP|CUU|SRB|RFS|SRA|RBW|SR8|CTT|RE0|SRC' ) //eSocial
oHash:Set('GPEM017A','SRG|SRA' ) //eSocial
oHash:Set('GPEM017B','CTT|C1E|CRM|C92|C99' ) //eSocial
oHash:Set('GPEM018','RHL|RHO|RHP|RHM|SRA|SRC|RHN|RGB' ) //Fechamento de periodo de beneficios.
oHash:Set('GPEM020','SRG|RGB|SRA|SRC' ) //Calculo por Roteiros
oHash:Set('GPEM020A','SRA' ) //Calculo Unificado
oHash:Set('GPEM023','C1E|CTT|SR8' ) //eSocial - Envio de eventos
oHash:Set('GPEM023C','SRA' ) //eSocial
oHash:Set('GPEM023D','CTT' ) //eSocial
oHash:Set('GPEM023E','SRB|SRA|SR8' ) //eSocial
oHash:Set('GPEM024','SRA' ) //CNIS - Exportacao
oHash:Set('GPEM025','SRA' ) //CNIS - importacao
oHash:Set('GPEM026','C9V|SRA|CM6|CUP|SR8|CUU|CM8|RBW|C9Y|CTT' ) //eSocial
oHash:Set('GPEM026A','SRG|SRA|RAZ|CTT|RFS|RD0|RBW' ) //eSocial
oHash:Set('GPEM026B','SR8|SRA|RBW' ) //eSocial
oHash:Set('GPEM026C','SRG|SRA|RAZ|CTT|SRC|SRB|RHN|RHM|RHP|RHH' ) //eSocial
oHash:Set('GPEM027','RHL|RHM|SRB|SRA' ) //Processamento Plano Saude - Hierarquia
oHash:Set('GPEM030','SRH|SRA|CM6|SR8|RGB|SRF|RHH' ) //Ferias
oHash:Set('GPEM034','C91|RHP|SRQ|CI1|CTT|SRC' ) //eSocial
oHash:Set('GPEM035','SRB|SRA|CTT|RE0|RBW' ) //Processamento das inconsist�ncias do e-social
oHash:Set('GPEM036A','SR8|RHP|RHM|SRB|SRA|SRG|S9V|T3P|C91|RAZ|CTT|SRC|RHH' ) //eSocial
oHash:Set('GPEM036B','SRG|SRH|SRA|T3P|SRC|SRQ|RGE' ) //eSocial
oHash:Set('FNEW1299','CMR|T1M|T3P|C91' ) //GPEM036F - eSocial
oHash:Set('GPEM039','SRA|C1E|CTT' ) //eSocial
oHash:Set('GPEM040','SRG|SRA|SRC|RID|RI6' ) //Rescisao
oHash:Set('GPEM040B','SRG|SRA' ) //Rescisao Coletiva
oHash:Set('GPEM044','SRA|RGE' ) //Atualizacao PPE
oHash:Set('GPEM045','SRA' ) //Qualificacao cadastral do eSocial.
oHash:Set('GPEM047','SRA' ) //eSocial
oHash:Set('GPEM060','SRG|SRH|SRA|SRC|SR8|SRF' ) //Ferias Coletivas/Programadas
oHash:Set('GPEM070','SRG|SRH|SRA|SRC|SRF|CTT' ) //Calculo Provisao
oHash:Set('GPEM080','SRQ|SRA' ) //Geracao de Liquidos em disquete
oHash:Set('GPEM090','SRG|SRA|SRC' ) // Gera arquivo magnetico de seguro desemprego
oHash:Set('GPEM110','SRA|SRC' ) //Contabilizacao Folha
oHash:Set('GPEM110A','SRA' ) //Contabilizacao Folha
oHash:Set('GPEM120','SRA' ) //Fechamento Mensal
oHash:Set('GPEM150','SRA' ) //Instrucao Normativa 65
oHash:Set('GPEM160','SRA|RGB|SRC' ) //Cancelamento de Calculos
oHash:Set('GPEM170','RGB|SRA' ) //Calculo geral de verbas
oHash:Set('GPEM240','SRG|SRC|RHH|CTT|SRA' ) //Gera arquivo com os dados do INSS - GPS
oHash:Set('GPEM360','SRA' ) //Manuten��o Saldos FGTS
oHash:Set('GPEM370','SRA' ) //Atualizacao de Saldos FGTS
oHash:Set('GPEM380','SRA' ) //Limpeza Saldos FGTS
oHash:Set('GPEM390','SRA|SRC' ) //Gera Disquete da Contribuicao Sindical
oHash:Set('GPEM400','SRG|SRA|CTT' ) //Gerar disquete do CAGED.
oHash:Set('GPEM500','SRG|RHH|SRA|SR2|RCU|CTT' ) //Gera Arquivo da RAIS (RA2)
oHash:Set('GPEM510','SR2|RCU' ) //Manutencao RAIS
oHash:Set('GPEM520','SR2|RCU|SRA' ) //Relacao Anual de Informacoes Sociais - RAIS
oHash:Set('GPEM530','SRA|SR2|RCU|SR8' ) //Gera disquete da RAIS
oHash:Set('GPEM550','RHP|SRB|SRA|SRC|SRH|SRQ|RGE|RCS|SRL|SR4|RFI|SM9|SM8|RHM|RHN' ) //Gera Arquivo da DIRF (SR4)
oHash:Set('GPEM551','SRA' ) //Previd�ncia Complementar por funcion�rio
oHash:Set('GPEM560','SM9|SRL|SM8|RCS|RFI|SR4|SRQ' ) //Manuten��o DIRF
oHash:Set('GPEM561','SRQ|SRL|SM8|SRA' ) //Manuten��o de Pensao - DIRF
oHash:Set('GPEM562','SRQ|SM9|SRL|SRA|SM8' ) //Manuten��o de Previdencia Complementar - DIRF
oHash:Set('GPEM570','SRQ|SM9|SRL|SM8|SR4|RCS' ) //Relatorio da DIRF
oHash:Set('GPEM580','SRQ|SM9|SRL|SRA|SM8|RCS|RFI|SR4' ) //Informe de rendimentos
oHash:Set('GPEM590','RFI|SRQ|SM9|SRL|SRB|SRA|SM8|SR4|RHN|RHM|RCS' ) //Gera disquete da DIRF
oHash:Set('GPEM600','SRG|SRH|SRA|SRF|SR8' ) //Gera os Dados HomologNet
oHash:Set('GPEM601','SRG|SRA' ) //Manutencao das Tabelas de Dados do Homolognet
oHash:Set('GPEM602','SRG|SRQ|SRA' ) //GERA XML - HOMOLOGNET
oHash:Set('GPEM610','SRG|SRA|SR8|SRC|RHH|CTT' ) //Gera arquivo com os dados do FGTS e INSS - SEFIP
oHash:Set('GPEM620','SRA|SRC' ) //Calculo da pesquisa gerencial.
oHash:Set('GPEM630','SRG|SRA|SRC|SRF' ) //C�lculo de M�ltiplas Rescis�es
oHash:Set('GPEM640','SA2' ) //Cadastro de definicoes de Titulos
oHash:Set('GPEM650','SRG|SRH|SA2|SRQ|SRA|SRC|RD0' ) //Gera Movimentacao de Titulos no arquivo RC1
oHash:Set('GPEM660','SE2' ) //Cadastro de movimentacao dos Titulos
oHash:Set('GPEM670','SA2|SE2' ) //Grava os titulos contidos no RC1 no SE2
oHash:Set('GPEM671','SA2' ) //Integra��o de T�tulos - Protheus GPE x CMNET
oHash:Set('GPEM680','SRG|SRA' ) //Gera o arquivo GRRF.RE
oHash:Set('GPEM690','SRG|RHH|SRA|RGB' ) //Calculo de dissidio retroativo
oHash:Set('GPEM691','RGB|RHH|SRA' ) //Calculo de dissidio retroativo - GFP
oHash:Set('GPEM695','SRA|RHH' ) //Pagamento Retroativo Gestao Publica.
oHash:Set('GPEM696','RHH|SRA' ) //Lan�amentos retroativos de verbas avulsas para serem integradas � folha de pagamento.
oHash:Set('GPEM700','RGB|SRA|SRC' ) //Consignacao em folha de pagamento (Generico)
oHash:Set('GPEM760','RGB|SRA' ) //Transferencia e Cancelamento de Calculo
oHash:Set('GPEM840','SRG|SRH|SRA|SRF|SRC' ) //Ferramenta de Diagn�stico de Base
oHash:Set('GPEM910','SRL|SRA|RFI|SR4' ) //Manuten��o de RRA - Dissidio
oHash:Set('GPEM920','SRA|CTT|SR8|RI6' ) //GERA XML - AUDESP
oHash:Set('GPEPGONL','SRA|SR8' ) //PAINEL Modulo GPE
oHash:Set('GPER008','RHM|SRB|SRA|CTT|RHN' ) //Relatorio de Conferencia do Calculo de Planos de Saude
oHash:Set('GPER009','SRA' ) //Impressao do Mapa de Beneficios
oHash:Set('GPER010','SA1|CTT|SRA' ) //Relat�rio de Beneficios por Entidade
oHash:Set('GPER011','RHL|RHM|SRB|SRA' ) //Relat�rio de benef�cios por funcion�rio
oHash:Set('GPER012','RHL|RHM|SRB|SRA' ) //Relat�rio de diverg�ncias de plano de sa�de
oHash:Set('GPER014','RHP|SRA|RHM|SRB|RHN' ) //Relatorio para conferencia dos valores acumulados de PLA
oHash:Set('GPER016','SRA' ) //Relatorio para compara��o de valores onerados/desonerados
oHash:Set('GPER020','SRG|SRQ|SRH|SRA|SRC|RGC' ) //Relacao de Liquidos
oHash:Set('GPER030','SI3|SRA|SRH|CTT|RGC|SRC|SR8' ) //Emissao de Recibos de Pagamento
oHash:Set('GPER040','SI3|SRH|SRA|CTT|SRC' ) //Folha de Pagamento
oHash:Set('GPER044','SRA|SRC' ) //PPE - Programa de Protecao ao Emprego.
oHash:Set('GPER045','SRH|RHH|SRA|SR8|SRG|SI3|SRC|CTT' ) //Folha de Pagamento - Diss�dio
oHash:Set('GPER050','SRG|SRA|SRH' ) //Relatorio de Imposto de Renda
oHash:Set('GPER055','SRA|CTT' ) //Darf do PIS
oHash:Set('GPER060','SRG|RHH|SRA|SRC|CTT' ) //Mapa de Obrigacoes Sociais
oHash:Set('GPER065','SRA' ) //Relatorio de Outros Beneficios
oHash:Set('GPER070','SRA' ) //Impressao da Provisao de Ferias
oHash:Set('GPER071','SRA|CTT' ) //Relat�rio de diverg�ncias de provis�o
oHash:Set('GPER080','SRH|SRA|SRF' ) //Demonstrativo de Medias
oHash:Set('GPER090','SRA' ) //Provisao de 13� Salario
oHash:Set('GPER091','RFV|SRA' ) //Relat�rio para impress�o da Mem�ria de C�lculo do Funcion�rio.
oHash:Set('GPER102','SRA|CTT|RGC' ) //Relatorio Mensal Vertical
oHash:Set('GPER103','SRA|SRC|RGC' ) //Relatorio Mensal Horizontal
oHash:Set('GPER104','RGB|SRA|CTT|RGC' ) //Relatorio de Incidencias por Funcionario.
oHash:Set('GPER105','SRA|RGB' ) //Relatorio de Incidencias Horizontal
oHash:Set('GPER106','SRA|CTT|SRC' ) //Relatorio Folha de Pagamento
oHash:Set('GPER110','SRA|CTT' ) //Extrato FGTS
oHash:Set('GPER130','SRH|SRA|SRF' ) //Recibo de Ferias
oHash:Set('GPER135','SRH|SRA|CTT|SRC' ) //Relatorio Conciliacao de Ferias
oHash:Set('GPER140','SRG|SA2|SRQ|SRA|SRC|SRF' ) //Impressao de Rescisao
oHash:Set('GPER150','SRA' ) //Relacao Liquidos ITAU
oHash:Set('GPER160','SI3|SRA' ) //Extrato de Tarefas
oHash:Set('GPER170','SRA|CTT|SRC' ) //Relatorio de Contribuicoes Sindicais
oHash:Set('GPER180','SRA' ) //Relacao Nominal do INSS Retido
oHash:Set('GPER190','SRA' ) //Relatorio Contrato Experiencia / Exame Medico
oHash:Set('GPER200','SRA' ) //Aumento Salarial
oHash:Set('GPER220','SRA' ) //Recibo Vale Transporte
oHash:Set('GPER241','SRG|RHH|SRA|CTT|SRC' ) //Relat�rio de confer�ncia GPS.
oHash:Set('GPER260','SRA|CTT' ) //Relacao de Aniversariantes do Mes
oHash:Set('GPER270','SRA|CTT' ) //Ficha Financeira
oHash:Set('GPER280','SRQ|SEF|SRA|SM3' ) //Impressao de Cheques
oHash:Set('GPER290','SRA|SRH|SRC' ) //Relatorio de Troco
oHash:Set('GPER310','SRA' ) //Emissao Etiqueta / Cartao do Ponto
oHash:Set('GPER330','SRA' ) //Demonstrativo de Horas Trabalhadas
oHash:Set('GPER340','SRA|CTT' ) //Relacao de Cargos e Salarios
oHash:Set('GPER350','SRA|CTT' ) //Classificacao por Cargos
oHash:Set('GPER370','SRA|SRC' ) //Boletim de Valores / Horas
oHash:Set('GPER380','SRA' ) //Planilha para Cadastro de Funcionarios
oHash:Set('GPER390','SRA|SRF' ) //Relacao Ferias Vencidas Mes
oHash:Set('GPER400','SRA|CTT|SRF' ) //Relacao de Programacao de Ferias
oHash:Set('GPER420','SRB|SRA' ) //Termo de Responsabilidade
oHash:Set('GPER430','SA1|SRB|SRA' ) //Declaracao de Encargos de Familia para fins de I.R.
oHash:Set('GPER440','SA1|SRB|SRA' ) //Ficha de Salario-Familia
oHash:Set('GPER450','SRA' ) //Relacao dos Salarios de Contribuicao
oHash:Set('GPER460','SRH|SRA|SRQ|SRB|CTT|SRC|SR8|RA4' ) //Impressao Ficha Registro
oHash:Set('GPER470','SRA' ) //Descriminacao Das Parcelas do Salario Contribuicao
oHash:Set('GPER490','SRA' ) //Relatorio de Admitidos e Demitidos
oHash:Set('GPER500','SRA' ) //Relacao de Movimentacoes de Funcionarios  (TURN-OVER)
oHash:Set('GPER510','SRA' ) //Relatorio de Acumulados por Codigos
oHash:Set('GPER520','SRA|SRC' ) //Relatorio Seguro de Vida
oHash:Set('GPER530','SRA|SRC' ) //Relatorio de Deducao do Salario Maternidade do 13� Salario
oHash:Set('GPER540','SI3|SRA|CTT' ) //GFIP - Guia de Recolhimento do FGTS
oHash:Set('GPER550','SRH|SRA|CTT' ) //Relatorio de Valores de Ferias
oHash:Set('GPER570','SRA|CTT' ) //Relaciona os Lancamento Futuros do SRK
oHash:Set('GPER580','SRA|SR8' ) //Afastamentos e Ausencias
oHash:Set('GPER620','SRA|CTT' ) //Impressao da pesquisa gerencial.
oHash:Set('GPER630','SRG|SRA|CTT|SRC' ) //Relatorio de Valores de Rescisoes
oHash:Set('GPER930','SRG|SRA|SRC' ) //Relatorio de Imposto de Renda sobre RRA
oHash:Set('GPER950','SRA' ) //Relat�rio de Historico Salarial
oHash:Set('GPER970','SRA' ) //Relat�rio de Estabilidade do Funcion�rio
oHash:Set('GPER980','SRA|CTT|SR8' ) //Relat�rio de Hist�rico de Afastamentos
oHash:Set('GPEW010','RH3' ) //Workflow FLUIG - Solicita��o Aumento
oHash:Set('GPEW011','SQG|SRA|SR8|RBT|RH3' ) //Workflow FLUIG - Solicita��o Desligamento
oHash:Set('GPEW012','RH3' ) //Workflow FLUIG - Justificativa Horario
oHash:Set('GPEW013','RBT|RH3' ) //Workflow FLUIG - Postos
oHash:Set('GPEW014','RBT|RH3' ) //Workflow FLUIG - Admissao
oHash:Set('GPEW015','RH3' ) //Workflow FLUIG - Transferencia
oHash:Set('GPEW017','RH3' ) //Workflow FLUIG - Subsidio
oHash:Set('GPEW018','RH3' ) //Workflow FLUIG - Reserva Treinamento
oHash:Set('GPEW020','SRQ|SRB|SRA|SR8' ) //WorkArea - Admissao
oHash:Set('GPEW030','SRH|SRF|SRA' ) //JOB para email de f�rias em dobro
oHash:Set('GPEW050','SRA' ) //Workflow Vencimento per�odo de experi�ncia

//Rotinas dos m�dulos de Qualidade - SIGAICE SIGAMQT SIGAQAD SIGAQDO SIGAQNC SIGAQIE SIGAQIP SIGAPPAP
oHash:Set('ICEA010','QAA|IC2')
oHash:Set('ICEA200','QAA')
oHash:Set('ICEA201','QAA|IC2')
oHash:Set('ICEA202','QAA|IC2')
oHash:Set('ICEA203','QAA|IC2')
oHash:Set('ICEA300','QAA')
oHash:Set('ICEC010','QAA')
oHash:Set('ICEC030','QAA')
oHash:Set('ICER010','QAA')
oHash:Set('ICER050','IC5')
oHash:Set('ICER070','QAA')
oHash:Set('ICER090','QAA')
oHash:Set('ICER130','QAA')
oHash:Set('ICEXFUN','QAA')
oHash:Set('ICEXWF','QAA')
oHash:Set('QADA015','QAA')
oHash:Set('QADA040','QU5')
oHash:Set('QADA100','QAA|QUB|QUC|QUH|QUI')
oHash:Set('QADA130','QAA')
oHash:Set('QADA140','QAA|QUC|QUH|QUI')
oHash:Set('QADA150','QAA|QUA|QUH|QUM')
oHash:Set('QADA201','QAA|QUH|QUM')
oHash:Set('QADA250','QAA|QUB|QUC|QUH|QUI')
oHash:Set('QADA280','QAA|QUC|QUH|QUI')
oHash:Set('QADC010','QAA|QUB')
oHash:Set('QADR060','QAA|QUB')
oHash:Set('QADR110','QAA')
oHash:Set('QADR150','QUM')
oHash:Set('QADXFUN','QAA')
oHash:Set('QAXA010','QAA|QD0')
oHash:Set('QAXA020','QAA')
oHash:Set('QAXA040','QAA|QAE|QAF')
oHash:Set('QAXFUN','QAA')
oHash:Set('QAXFUNA','QAA')
oHash:Set('QDOA050','QAA|QD0|QD4|QDZ')
oHash:Set('QDOA052','QAA')
oHash:Set('QDOA053','QAA')
oHash:Set('QDOA060','QDU')
oHash:Set('QDOA080','QAA')
oHash:Set('QDOA090','QAA')
oHash:Set('QDOA110','QAA')
oHash:Set('QDOA120','QAA')
oHash:Set('QDOA151','QAD')
oHash:Set('QDOA030','QAA')
oHash:Set('QDOC030','QAA')
oHash:Set('QDOC040','QAA')
oHash:Set('QDOM020','QAA')
oHash:Set('QDOR080','QAA')
oHash:Set('QDOR081','QAA')
oHash:Set('QDOR200','QAA')
oHash:Set('QDOXDOC','QAA')
oHash:Set('QDOXFUN','QAA|QD0|QE5|QEP|QE5|QM1|QM2|QM5|QMD|QME|QML|QMU|QN4|QN5')
oHash:Set('QIEA050','QM2|QM5|QME|QML|QMU')
oHash:Set('QIEA070','QAA|QE5')
oHash:Set('QIEA182','QEP')
oHash:Set('QIEA183','QEP')
oHash:Set('QIEA200','QAA')
oHash:Set('QIEA215','QEL|QER')
oHash:Set('QIEA220','QE5')
oHash:Set('QIEA310','QAA')
oHash:Set('QIEC050','QEK')
oHash:Set('QIEM030','QAA')
oHash:Set('QIEM070','QAA|QE5')
oHash:Set('QIEM100','QEP')
oHash:Set('QIER040','QER')
oHash:Set('QIER210','QAA')
oHash:Set('QIER260','QAA|QE5')
oHash:Set('QIEXFUN','QE5|QEP')
oHash:Set('QIEXFUNA','QEP')
oHash:Set('QIPA010','QP6')
oHash:Set('QIPA012','QP6')
oHash:Set('QIPA020','QP1')
oHash:Set('QIPA060','QP5')
oHash:Set('QIPA215','QPR|QQJ|QQL')
oHash:Set('QIPA216','QPR')
oHash:Set('QIPXFUN','QP6|QQL')
oHash:Set('QMTA010','QAA|QM2|QMD')
oHash:Set('QMTA020','QM2')
oHash:Set('QMTA030','QM1')
oHash:Set('QMTA050','QAA|QA5')
oHash:Set('QMTA070','QAA')
oHash:Set('QMTA140','QAA|QM2|QM6')
oHash:Set('QMTA150','QAA|QM2|QM4|QM5')
oHash:Set('QMTA160','QAA|QM1|QM2|QML')
oHash:Set('QMTA170','QME')
oHash:Set('QMTA180','QMU')
oHash:Set('QMTA230','QAA|QM1|QM2|QML|QN4|QN5')
oHash:Set('QMTC020','QAA|QM1|QM2')
oHash:Set('QMTM010','QM2')
oHash:Set('QMTM060','QM2')
oHash:Set('QMTM400','QM2')
oHash:Set('QMTP030','QML')
oHash:Set('QMTR010','QAA|QM2')
oHash:Set('QMTR020','QAA|QM2')
oHash:Set('QMTR030','QAA|QM2')
oHash:Set('QMTR030','QAA|QM2')
oHash:Set('QMTR040','QAA|QM2')
oHash:Set('QMTR050','QM2')
oHash:Set('QMTR070','QAA|QM2')
oHash:Set('QMTR071','QM2')
oHash:Set('QMTR080','QAA|QM2')
oHash:Set('QMTR090','QM2')
oHash:Set('QMTR100','QM2')
oHash:Set('QMTR110','QM2')
oHash:Set('QMTR120','QM2')
oHash:Set('QMTR130','QM2')
oHash:Set('QMTR140','QAA|QM2|QME')
oHash:Set('QMTR150','QAA|QM4|QM5')
oHash:Set('QMTR160','QAA|QM2')
oHash:Set('QMTR180','QAA|QE5|QM2')
oHash:Set('QMTR190','QAA|QM4|QM5')
oHash:Set('QMTR210','QM2')
oHash:Set('QMTR220','QAA|QM2|QM5')
oHash:Set('QMTR240','QM2')
oHash:Set('QMTR250','QM2')
oHash:Set('QMTR270','QAA|QM4|QM5')
oHash:Set('QMTR280','QAA|QM2')
oHash:Set('QMTR310','QAA|QN4')
oHash:Set('QMTR320','QAA|QN4')
oHash:Set('QMTXFUN','QM2|QN4')
oHash:Set('QNCA030','QAA|QI3|QI4|QI5|QIE')
oHash:Set('QNCA040','QAA|QF7|QI2|QIF')
oHash:Set('QNCA050','QAA|QI5')
oHash:Set('QNCA060','QI5')
oHash:Set('QNCA070','QAA')
oHash:Set('QNCA100','QAA')
oHash:Set('QNCA120','QAA|QUP')
oHash:Set('QNCA330','QAA')
oHash:Set('QNCA330EVDEF','QAA')
oHash:Set('QNCA340','QAA|QI2')
oHash:Set('QNCA340EVDEF','QAA')
oHash:Set('QNCR010','QAA')
oHash:Set('QNCR020','QAA')
oHash:Set('QNCR040','QAA')
oHash:Set('QNCR050','QAA')
oHash:Set('QNCR060','QAA')
oHash:Set('QNCR080','QAA')
oHash:Set('QNCR100','QAA')
oHash:Set('QNCR110','QAA')
oHash:Set('QNCXFUN','QAA|QI3')
oHash:Set('QPPA010','QP6')
oHash:Set('QPPA040','QKE')
oHash:Set('QPPA110','QAA|QKG|QKP')
oHash:Set('QPPA120','QAA|QK5|QK6')
oHash:Set('QPPA121','QAA|QK5|QK6')
oHash:Set('QPPA130','QAA|QK7|QK8')
oHash:Set('QPPA131','QAA|QK7|QK8')
oHash:Set('QPPA140','QKF')
oHash:Set('QPPA150','QKN')
oHash:Set('QPPA160','QKL')
oHash:Set('QPPA170','QK9')
oHash:Set('QPPA210','QKR')
oHash:Set('QPPA220','QAA|QKI')
oHash:Set('QPPA230','QAA|QKI')
oHash:Set('QPPA240','QKH')
oHash:Set('QPPA250','QKQ')
oHash:Set('QPPA260','QKR')
oHash:Set('QPPA270','QKS')
oHash:Set('QPPA280','QKT')
oHash:Set('QPPA290','QKU')
oHash:Set('QPPA300','QKV')
oHash:Set('QPPA310','QKW')
oHash:Set('QPPA320','QKX')
oHash:Set('QPPA340','QL0')
oHash:Set('QPPA350','QL1')
oHash:Set('QPPA360','QL2')
oHash:Set('QPPM010','QK5|QK7|QKL|QKN')
oHash:Set('QPPM020','QK5|QK7')
oHash:Set('QPPR040','QAA|QKE')
oHash:Set('QPPR110','QAA')
oHash:Set('QPPR111','QAA')
oHash:Set('QPPR120','QK5')
oHash:Set('QPPR130','QK7|QK8')
oHash:Set('QPPR140','QKF')
oHash:Set('QPPR150','QKN')
oHash:Set('QPPR160','QKL')
oHash:Set('QPPR170','QK9')
oHash:Set('QPPR180V','QAA|QL1')
oHash:Set('QPPR190V','QAA|QL1')
oHash:Set('QPPR200V','QAA|QL1')
oHash:Set('QPPR210','QKR')
oHash:Set('QPPR220','QKI')
oHash:Set('QPPR230','QKJ')
oHash:Set('QPPR231','QKJ')
oHash:Set('QPPR232','QKJ')
oHash:Set('QPPR233','QKJ')
oHash:Set('QPPR234','QKJ')
oHash:Set('QPPR240','QKH')
oHash:Set('QPPR250','QAA|QKQ')
oHash:Set('QPPR260','QAA|QKQ')
oHash:Set('QPPR270','QAA|QKS')
oHash:Set('QPPR280','QAA|QKT')
oHash:Set('QPPR290','QAA|QKU')
oHash:Set('QPPR300','QAA|QKV')
oHash:Set('QPPR310','QAA|QKW')
oHash:Set('QPPR320','QAA|QKX')
oHash:Set('QPPR320','QKX')
oHash:Set('QPPR330','QAA|QKY')
oHash:Set('QPPR330','QAA|QKY')
oHash:Set('QPPR340','QAA|QL0')
oHash:Set('QPPR340','QAA|QL0')
oHash:Set('QPPR350','QAA|QL1')
oHash:Set('QPPR350','QAA|QL1')
oHash:Set('QPPR360','QL2')
oHash:Set('QPPR370','QK5|QK6')
oHash:Set('QPPR380','QK7|QK8')
oHash:Set('QPRR120','QK5|QK6')
oHash:Set('QPRR190V','QAA')
oHash:Set('RHTOQUA','QAA|QE5|QEP|QM1|QM2|QM5|QME|QML|QMU|QN4')

//Rotinas modulo MDT
oHash:Set('MDTA640','TNC') //Acidentes
oHash:Set('MDTA275','TM0') //Gera��o de Exames para Funcion�rios
oHash:Set('MDTA880','TIL') //CNES
oHash:Set('MDTA660','TNQ') //Componentes
oHash:Set('MDTA155','TMT|TM2') //Diagnostico M�dico
oHash:Set('MDTA005','TKE|TM0') //Atestado M�dico
oHash:Set('MDTA275','TM5') //Gera��o de Exames para Funcion�rios Admitidos - Exames
oHash:Set('MDTA685','TNY') //Atestado M�dico
oHash:Set('MDTA240','TO8') //Ocorr�ncias Funcion�rio
oHash:Set('MDTA920','TOF') //Licen�as Maternidade
oHash:Set('MDTA615','TAA|TC9') //Plano de A��o
oHash:Set('MDTA805','TBB|TBP') //Plano Emergencial
oHash:Set('MDTR485','TYB') //Ortho Rater
oHash:Set('MDTR481','TYC' ) //Snellen
oHash:Set('MDTA070','TMK') //Sesmt/usuar.aten.
oHash:Set('MDTA520','TKH') //Vacinas
oHash:Set('MDTA530','TL9') //Vacinas do Funcion�rio

//Rotinas M�dulo MNT
oHash:Set( 'MNTA020', 'ST1' ) // Funcion�rios
oHash:Set( 'MNTA080', 'ST9' ) // Bens
oHash:Set( 'MNTA083', 'ST9' ) // Pneus
oHash:Set( 'MNTA084', 'ST9' ) // Ve�culos
oHash:Set( 'MNTA160', 'ST1' ) // Funcion�rios
oHash:Set( 'MNTA170', 'TP9' ) // Bens Padr�o
oHash:Set( 'MNTA185', 'TP3' ) // Contratos
oHash:Set( 'MNTA230', 'ST9' ) // Monta o esquema GET
oHash:Set( 'MNTA235', 'TPT' ) // Grupo Contas de E-mail/Funcion�rio
oHash:Set( 'MNTA280', 'TQ4|TQB' ) // Solicita��o
oHash:Set( 'MNTA285', 'TQ3' ) // Tipo de Servi�os
oHash:Set( 'MNTA290', 'TQB' ) // Fechamento
oHash:Set( 'MNTA291', 'ST1|TQB|TUM' ) // Atendimento
oHash:Set( 'MNTA295', 'TQB' ) // Distribui��o de S.S.
oHash:Set( 'MNTA296', 'TQB|TUR|TP4|' ) // Distribui��o
oHash:Set( 'MNTA298', 'TUD' ) // Crit�rios de Distribui��o
oHash:Set( 'MNTA300', 'TQ4' ) // Executantes de S.S.
oHash:Set( 'MNTA315', 'TQB|TQ4' ) // Distribui��o em Lote
oHash:Set( 'MNTA400', 'ST1' ) // Retorno
oHash:Set( 'MNTA430', 'ST9|STS' ) // Hist�rico
oHash:Set( 'MNTA435', 'ST1' ) // Retorno Mod. 2
oHash:Set( 'MNTA470', 'ST9' ) // Movimenta��o de Bem
oHash:Set( 'MNTA471', 'ST9' ) // Movimenta��o de Bem
oHash:Set( 'MNTA480', 'ST1' ) // Retorno por Etapas
oHash:Set( 'MNTA525', 'TS3' ) // Penhora
oHash:Set( 'MNTA540', 'TRH' ) // Sinistro
oHash:Set( 'MNTA545', 'TRO|TRS|TRH|TRL|TRM|TRN|TU4|' ) // Complemento de Sinistro
oHash:Set( 'MNTA610', 'TQF|TQG' ) // Postos
oHash:Set( 'MNTA615', 'TQF' ) // Posto Interno
oHash:Set( 'MNTA616', 'TQF' ) // Terminal x Bomba
oHash:Set( 'MNTA625', 'TQK' )  // Medi��es do Tanque
oHash:Set( 'MNTA630', 'TQL' ) // Aferi��o de Bombas
oHash:Set( 'MNTA645', 'TQN' ) // Concilia��o Autom�tica
oHash:Set( 'MNTA650', 'TQN' ) // Concilia��o Manual
oHash:Set( 'MNTA651', 'TUI|TQF' ) // Transfer�ncias
oHash:Set( 'MNTA655', 'TQN' ) // Abastecimento Manual
oHash:Set( 'MNTA656', 'TQL' ) // Abastecimento Lote Posto
oHash:Set( 'MNTA657', 'TTH' ) // Sa�da Combust�vel
oHash:Set( 'MNTA660', 'TQN' ) // Reprocessamento
oHash:Set( 'MNTA681', 'TQF|TQN' ) // Controle de Abastecimento
oHash:Set( 'MNTA692', 'TVX|TVY' ) // Planejamento Obra
oHash:Set( 'MNTA693', 'TQ2' ) // Transfer�ncia de Bens
oHash:Set( 'MNTA700', 'TQF|TUI' ) // An�lise Consist�ncia
oHash:Set( 'MNTA755', 'TSJ' ) // Leasing Ve�culos
oHash:Set( 'MNTA765', 'TRX' ) // Multa
oHash:Set( 'MNTA766', 'TRX' ) // Notifica��es
oHash:Set( 'MNTA800', 'TP4|ST1' ) // Equipes
oHash:Set( 'MNTA805', 'ST9' ) // Cadastro de Documentos Obrigat�rios por Ve�culo
oHash:Set( 'MNTA806', 'ST9' ) // Documentos Obrigat�rios/Ve�culo
oHash:Set( 'MNTA830', 'ST9' ) // Informa
oHash:Set( 'MNTA840', 'ST9' ) // Quebra
oHash:Set( 'MNTA845', 'TRX' ) // Inconsist�ncias
oHash:Set( 'MNTA855', 'TRW|ST1' ) // Filiais
oHash:Set( 'MNTA902', 'ST9' ) // �rvore
oHash:Set( 'MNTA909', 'TUF' ) // Complemento de Usu�rios
oHash:Set( 'MNTA970', 'TRS' ) // APD
oHash:Set( 'MNTA975', 'TSX' ) // Solicita��o de OS
oHash:Set( 'MNTA985', 'TTI|TTK' ) // Portaria
oHash:Set( 'MNTA990', 'ST1|TT1|TTQ' ) // Programa��o de OS
oHash:Set( 'MNTA992', 'TTL' ) // Reporte de Horas
oHash:Set( 'MNTA995', 'ST1|TTO' ) // Calibragem/Medi��o Sulco
oHash:Set( 'MNTC050', 'ST9' ) // Pend�ncias
oHash:Set( 'MNTC070', 'ST9' ) // Bens do Fabricante
oHash:Set( 'MNTC080', 'TQB' ) // Solicitacao de Servicos Pendentes
oHash:Set( 'MNTC140', 'TQB' ) // Atendimento
oHash:Set( 'MNTC280', 'TQB|ST1' ) // Consulta Gerencial do Modulo de Solicitacao de Servicos.
oHash:Set( 'MNTC286', 'TQB|TUM' ) // Consulta Gerencial de S.S.
oHash:Set( 'MNTC315', 'TRX' ) // Multas
oHash:Set( 'MNTC335', 'ST9' ) // Hrs Disp. x Ind. Bem
oHash:Set( 'MNTC415', 'ST1' ) // Consulta de Disponibilidade de Funcion�rios.
oHash:Set( 'MNTC450', 'STS' ) // Custo
oHash:Set( 'MNTC510', 'ST9' ) // Hist�rico
oHash:Set( 'MNTC600', 'ST9' ) // Bem
oHash:Set( 'MNTC605', 'ST9' ) // Manuten��es do Bem
oHash:Set( 'MNTC630', 'ST1' ) // Ordens Funcion�rio
oHash:Set( 'MNTC657', 'TQN|TTH|TQF' ) // Aferi��o de Bombas
oHash:Set( 'MNTC681', 'TVZ' ) // Hist�rico de Mob/Desmob
oHash:Set( 'MNTC730', 'ST9' ) // Ordens do Bem
oHash:Set( 'MNTC740', 'ST9' ) // Movimenta��o 
oHash:Set( 'MNTC755', 'ST1' ) // Consulta de OS
oHash:Set( 'MNTC780', 'ST9' ) // Etapas do Bem
oHash:Set( 'MNTC795', 'STS|STZ' ) // Consulta de bem
oHash:Set( 'MNTC805', 'TQF' ) // Evolu��o dos Pre�os
oHash:Set( 'MNTC810', 'TQG' ) // Negocia��o Postos
oHash:Set( 'MNTC830', 'TQN|TQF' ) // Por Data e Posto
oHash:Set( 'MNTC840', 'ST9' ) // Custo Bem Manuten��o
oHash:Set( 'MNTC841', 'TQN' ) // Concilia��o
oHash:Set( 'MNTC845', 'TQN|TQF' ) // Posto Interno
oHash:Set( 'MNTC850', 'TQK' ) // Diverg�ncias Estoque
oHash:Set( 'MNTC860', 'ST9' ) // Pneus por Status
oHash:Set( 'MNTR020', 'ST1' ) // MDO de Terceiros
oHash:Set( 'MNTR050', 'ST1' ) // OS Gr�fica
oHash:Set( 'MNTR120', 'TQ4|TUF|ST1' ) // Solicita��o de Servi�o
oHash:Set( 'MNTR220', 'ST1' ) // Atividade
oHash:Set( 'MNTR240', 'ST1' ) // Apropria��o Horas
oHash:Set( 'MNTR355', 'TQF' ) // Por Motorista
oHash:Set( 'MNTR375', 'TQF|TQN' ) // Por Unidade de Neg�cio
oHash:Set( 'MNTR580', 'TRH|TRM|TRN|TRO|' ) // Sinistro
oHash:Set( 'MNTR585', 'TRH|TRM|TRN|TRO|TU4' ) // RAV
oHash:Set( 'MNTR605', 'ST1' ) // Manuten��o do Bem
oHash:Set( 'MNTR630', 'ST1' ) // OS Usa Funcion�rio
oHash:Set( 'MNTR650', 'ST1' ) // Manuten��o
oHash:Set( 'MNTR680', 'ST1' ) // Proje��o Consumo OS
oHash:Set( 'MNTR685', 'ST1' ) // Proje��o COnsumo Insumo
oHash:Set( 'MNTR715', 'ST1' ) // Hrs Trabalhadas Contrato
oHash:Set( 'MNTR750', 'ST1' ) // Centros de Custos
oHash:Set( 'MNTR790', 'ST1' ) // Utiliza��o
oHash:Set( 'MNTR915', 'TS3' ) // Bens Penhorados
oHash:Set( 'MNTR930', 'TQN|TQF' ) // Por Filial
oHash:Set( 'MNTR935', 'TQN' ) // Indicadores de Rendimento
oHash:Set( 'MNTR941', 'TQF' ) // Por Conv�nio e Posto
oHash:Set( 'MNTR945', 'TQF' ) // Postos
oHash:Set( 'MNTR985', 'TRX' ) // Multas a Pagar
oHash:Set( 'NGIND001', 'TZE' ) // Consulta Indicadores
oHash:Set( 'NGIND008', 'TZB' ) // Cadastro de Pain�is de Indicadores.
oHash:Set( 'NGIND012', 'TZB' ) // Cadastro de Permiss�o de Acesso aos Paineis de Indicadores Gr�ficos.

//Rotinas modulo ORG
oHash:Set('ORGA030','SRA|RBU|RCX|CTT|SQS|RD0|RCX|RBT' ) //Movimento de Postos
oHash:Set('ORGA060','SRA|CTT' ) //Cadastro de Visoes
oHash:Set('ORGA070','SRA|RCX|RBT' ) //Gerenciamento de Visoes
oHash:Set('ORGM010','CTT|RBT|RBU|RBX|RGC' ) //Cadastro de Movimento Departamento
oHash:Set('ORGM020','SRA|RBT|RBU|RBX|RCX|CTT|SQS' ) //Carga dos departamento a partir do Centro de Custo
oHash:Set('ORGR020','CTT' ) //Relacao de Postos
oHash:Set('ORGR030','CTT|RBU' ) //Relacao de Movimentacao de Postos
oHash:Set('ORGR040','CTT' ) //Relatorio de Departamentos
oHash:Set('ORGR050','SRA|RD0|RCX' ) //Relacao de Ocupantes X Postos
oHash:Set('ORGR060','SRA|RD0|RCX' ) //Relacao de Postos x Ocupantes
oHash:Set('ORGR080','SRA|CTT' ) //Relatorio de Controle Orcamentario

//Rotinas m�dulo PCO
oHash:Set('PCOA111','ALC' ) // Usu�rios do Grupo PCO
oHash:Set('PCOA520','ALM' ) // Grupos de Aprova�ao Pco
oHash:Set('PCOA530','ALI' ) // Solicita�ao de Contingencia
oHash:Set('WFPCOA530','ALI' ) // Solicita�ao de Contingencia

//Rotinas m�dulo PLS - TOTVS Sa�de Planos (33 - SIGAPLS)
// Sub-rotinas da Rotina Principal: PLSA090.PRW
oHash:Set('PLSAINTE','BBR' )  //Intera��o  (PLSXFUN)
oHash:Set('PLS090BCO','BEA|BE2' )  //Banco de conhecimento-Guia|Item  (PLSA090)
oHash:Set('PLS09AMO1','B4A' )  //Inc. Anexo-Radioterapia  (PLSA09A)
oHash:Set('PLS09AMO2','B4A' )  //Inc. Anexo-Quimioterapia  (PLSA09A)
oHash:Set('PLS09AMO3','B4A' )  //Inc. Anexo-OPME  (PLSA09A)
oHash:Set('PLSA090MOV','BEA|BE1|BD5|BE4|B53' )  //Incluir|Excluir|Copiar  (PLSA090)
    // Sub-rotinas PLSA090MOV
    oHash:Set('PLSBENEF','BA1' )  //Benef  (PLSA09A)
    oHash:Set('A090VLRCPP','BE2' )  //Co-Part  (PLSA090)
    oHash:Set('PLPOSFIN','BA1|BA3|BI3' )  //Financeiro  (PLSM020)
    oHash:Set('PLALTCLI','BA1|BA3|SA1' )  //Cliente  (PLSMLIB)
    oHash:Set('PLSVLRCOB','BA1|BA3' )  //Cobranca  (PLSMCOB2)
    oHash:Set('PLHISMOV','BE4|BD6|BA1|BA3' )  //Historico  (PLSM020)
    oHash:Set('PLSA235','BA1|BA3|BER|BT5|BQC' )  //Usuarios  (PLSA235)
    oHash:Set('PLSA090CPR','BE2' )  //Comprar  (PLSA090)
    oHash:Set('PLSA086','BXE' )  //Mov. Neg  (PLSA086)
    oHash:Set('PLS090FOR','BDS' )  //Crit. For�adas  (PLSA090)
oHash:Set('PLSA090IMA','BEA|BB0|BAU|BA0|BA1|BD7' )  //Imp.Guia  (PLSA090)
oHash:Set('PLSA090REC','BEA' )  //Imp. Recibo  (PLSA090)
oHash:Set('PLSA090BXT','BEA|BB0|BAU|BA0|BA1|BD7' )  //Baixar Titulo  (PLSA090)
oHash:Set('PLSA090IMG','BEA|BB0|BAU|BA0|BA1|BD7' )  //Imp.Varias Guias  (PLSA090)
oHash:Set('PLSA090CAN','BEA|BE2|BE4' )  //Cancelar Guia  (PLSA090)
oHash:Set('PLSA090RAS','BEA|BD5' )  //Rastrear  (PLSA090)
oHash:Set('PL090IEVSA','BA0|BID|BEA|BA1|BG9|BI3|BB8|BQV' )  //Imprime Evolu��o SADT  (PLSA090->PLSR432)
oHash:Set('PLSA090INS','BEA|BE4' )  //Insist�ncia  (PLSA090)
oHash:Set('PL90INFPRO','BEA|BE4' )  //Informar Protoc.  (PLSA090)
// Sub-rotinas da Rotina Principal: PLSA001.PRW
oHash:Set('PLBOWAPR','B44' )  //Aprova��o Reemb.  (PLSA001A)
oHash:Set('PL001MOV','B44' )  //Visualizar / Excluir  (PLSA001)
oHash:Set('PLBOWHIS','BOW' )  //Hist. Protoc. Reemb.  (PLSA001A)
oHash:Set('PLSRGLOREE','B44' )  //Recurso de Glosa  (PLSA001)
// Sub-rotinas da Rotina Principal: PLSA001A.PRW
oHash:Set('PLBOWMOV','BOW' )  //Visualizar, Incluir, Alterar, Excluir  (PLSA001A)
    // Sub-rotinas PLBOWMOV
    oHash:Set('P001ACONH','BOW' )  //Anexos  (PLSA001A)
        // Sub-rotinas PLCONSREC (Receitas)
        oHash:Set('PLSCADREC','B4F' )  //Receitas->Visualizar  (PLSCADREC)
            // Sub-rotinas PLSCADREC (Receitas)
            oHash:Set('PLSANRCTANEXO','B4F' )  //Anexos da Receita  (PLSANRCT)
oHash:Set('PLSR998','BOW|BA1|BI3' )  //Imp. Protocolo  (PLSR998)
oHash:Set('PLGRVBK6','B1N' )  //Verifica rede cadastro  (PLSA001A)
// Sub-rotinas da Rotina Principal: PLSA092.PRW
oHash:Set('PLSA092MOV','BQV' )  //Visualizar|Incluir|Excluir|Prorrogacao de Internacao|Auto. On-Line  (PLSA092)
oHash:Set('PLSGINT','BA0|BE4|BA1|BI3|BTS|BAU|BB8|BB0|BAQ|BDR|BQR|BD6|BEJ|BR8|BF8|BN5|BQV|' )  //Imprimir GIH. (Guia Solicita��o e Resumo Interna��o)  (PLSTISS)
oHash:Set('PLSR470','BE4|BA1|BG9|BA3|BI3|BB0|BAU|BB8|BID|BQV' )  //Imprimir Evo.  (PLSR470)
oHash:Set('PLSA092RAS','BEA|BD5' )  //Rastrear  (PLSA092)
oHash:Set('PLSA092VTM','BEA|BD6|BOZ' )  //Visita Profissional  (PLSA092)
    // Sub-rotinas PLSA092VTM
    oHash:Set('PLSRVTM','BEA|BD6|BOZ' )  //Imprimir a Lista  (PLSA092)
    oHash:Set('PLSHGIH','BOZ' )  //Listar Visitas da GHI  (PLSA092)
    oHash:Set('PLSA092AVM','BOZ' )  //Agendar Visita  (PLSA092)
// Sub-rotinas da Rotina Principal: PLSA090.PRW
oHash:Set('PLSA260MOV','BA1|BA3' )  //Visualizar|Alterar|Excluir  (PLSA260)
    // Sub-rotinas PLSA260MOV
    oHash:Set('PLS260ALC','SA1|BA3' )  //Alterar Cliente da Familia  (PLSA260)
    oHash:Set('A260HIST','BA1|BQY' )  //Historico Transferencia  (PLSA260)
    oHash:Set('PLSC005','BR8' )  //Consultar Cobertura/Carencia  (PLSC005)
        // Sub-rotinas PLSC005
        oHash:Set('PLSCCPT','BF3|BA9|BA1' )  //Visualizar Doen�as Pr�-Existentes CID  (PLSC005)
    oHash:Set('PL260CONHEC','BA1' )  //Bco  Conhec  (PLSA260)
oHash:Set('PLBLQUMENU','BCA|BA1|BA3|BC3' )  //(Des)Bloqu. &Usu  (PLSA260)
oHash:Set('PLBLQFMENU','BCA|BA1|BA3|BC3' )  //(Des)Bloqu. &Fam  (PLSA260)
oHash:Set('PLSA272','B5F|BA1' )  //Intercambio Habitual  (PLSA272)
oHash:Set('PLHISTCSB','BQT' )  //Hist. Transf. Cont. e Subcon.  (PLHISTCSB)
// Sub-rotinas da Rotina Principal: PLSA360.PRW
oHash:Set('PLSA360MNT','BAU|BBF|BC8|BBE|BBC|BLJ|BYV|BCF|B25|B26|B29' )  //Visualizar|Incluir|Alterar|Excluir  (PLSA360)
    // Sub-rotinas PLSA360MNT
    oHash:Set('PLSRATA400','B0G' )  //Rd. Atend.  (PLSA360)
    oHash:Set('PLS360CONH','BAU' )  //Anexos  (PLSA360)
oHash:Set('PLSA360BLO','BAU|BC4' )  //(Des)Bloquear  (PLSA360)
oHash:Set('PLSA365MNT','BAU|BAW|BHU|BY5|BY6|BB8|BPI|BZA|BCK|BIN|B58|B24|B7P|BAX|BC1|BBG|BBI|BE9|BBK|BBN|BYZ|B30|B59|B75|B62' )  //Complemento  (PLSA365)
    // Sub-rotinas PLSA365MNT
    oHash:Set('PLSA365FCP','BZ2' )  //Faixa x Condicao de Pagamento  (PLSA365)
oHash:Set('PLSVALPAG','BA1|BAU' )  //Valor Producao  (PLSMPAG)
oHash:Set('PLS360GCON','B2G|BAU' )  //Gerar Contrato  (PLSA360)
oHash:Set('PLSEXCEUS','B4R|BAU' )  //Exce��o de pagamento U.S  (PLSEXCEUS)
oHash:Set('PLSINFSBRDA','B7O' )  //Informar Substituto RDA  (PLSA360)
// Sub-rotinas da Rotina Principal: PLSA470.PRW
oHash:Set('PLSA470MOV','BAF|SE2|BGQ|BEM|SC7|RGB|SRC|SRD|SM0|SRA|SE1|BRJ|BAU' )  //Visualizar|Excluir Lote  (PLSA470))
    // Sub-rotinas PLSA470MOV
    oHash:Set('PLSHISCON','B03|BAU' )  //Consulta Historico  (PLSXFUN)
oHash:Set('PLSA470NEW','BAU|BD6' )  //Novo Lote Pagto  (PLSA470)
oHash:Set('PLSA470EXC','BAF|SE2|BGQ|BEM|SC7|RGB|SRC|SRD|SM0|SRA|SE1|BRJ|BAU' )  //Exclusao Individual  (PLSA470)
oHash:Set('PLSA470IMP','BAU|SX3' )  //Calculo Impostos  (PLSA470)
// Sub-rotinas da Rotina Principal: PLSA498
oHash:Set('PLSA498PRC','BCI|BAU' )  //Processar  (PLSA498)
oHash:Set('PLSA498VIS','BCI|BAU' )  //Visualizar  (PLSA498)
oHash:Set('PLSA175MOV','BCI' )  //Incluir  (PLSA175)
oHash:Set('PLSA499VIN','BCI' )  //Vinc / Desv PEG  (PLSA499)
oHash:Set('PLSA498AUX','BCI' )  //Selecionar  (PLSA498)
    // Sub-rotinas PLSA498AUX
    oHash:Set('PLSA500MOV','BCI|BAU|BD6|BX6|BYT|B11' )  //Visualizar|Incluir|Alterar|Cancelar  (PLSA500)
        // Sub-rotinas PLSA500MOV
        oHash:Set('MSGCOMINT','BZC' )  //Msgs Interc.  (PLSA090)
        oHash:Set('PLSA093VIS','BET|B4Q' )  //Visualizar as Prorroga��es para esta interna��o  (PLSA093)
        oHash:Set('PLSBUSPROD','BD6' )  //Busca Produto  (PLSA500)
        oHash:Set('PLS500GLM','B11' )  //Glosas Manuais  (PLSA500)
    oHash:Set('PLSA500ACT','BDX' )  //Analisar Glosas  (PLSA500)
    oHash:Set('PLSA500GML','BDX|BD6' )  //Incluir glosa manual  (PLSA500)
    oHash:Set('PLSR673','BA1|BD7|BD6|BAU|BDX|SE2|BN4|BID|BB8|BAQ|BGQ|BBB|BCE|BR8|BA0|B18|SA2|BAG|BBC' )  //Conf. Intern. Pag.  (PLSR673)
    oHash:Set('PLSA500CLO','BD6|BD7' )  //Clonar Guia  (PLSA500)
    oHash:Set('PLSA500AND','BD6|BD7' )  //Analisar Diverg�ncias  (PLSA500)
    oHash:Set('PLSA500VID','BD6|BD7' )  //Visualizar Diverg�ncias  (PLSA500)
    oHash:Set('PLSA500BCO','BD5|BD6|BE2' )  //Conhecimento  (PLSA500)
oHash:Set('PLSA498TRA','BD5|BE4' )  //Transfer�ncia Guia  (PLSA498)
oHash:Set('PLSA498IMP','BAU|BA0|BB8|BCI|BXX' )  //Imp. Capa PEG  (PLSA498)
// Sub-rotinas da Rotina Principal: PLSA627
oHash:Set('PL627MEN','BDC|BDW|BDF|BDG|BTV' )  //Visualizar|Novo|Excluir  (PLSA627)
// Sub-rotinas da Rotina Principal: PLSA790V
oHash:Set('PLS790ANA','B53|B4Q|B4A|BYS|B47|BE2' )  //Analisar  (PLSA790V)
oHash:Set('PLSEXGUAX','B53' )  //Anexos Clin. Vinc.  (PLSA790V)
oHash:Set('PLANEXRADI','B4A|B53' )  //Anexo Radioterapia  (PLSA790V)
oHash:Set('PLS790ICO','B53|B72|B73' )  //Inconsist�ncia  (PLSA790V)
oHash:Set('PLS790BAN','BEA|B4A|B4C|BE2|B68' )  //Banco de conhecimento Guia-Item  (PLSA790V)
oHash:Set('PLSA960MOV','BB0' )  //Solicitante/Executante  (PLSA960)
oHash:Set('PLSA790GUIA','BEA|BE4|B4A|B4Q|B44' )  //Guia  (PLSA790)
oHash:Set('PL790NMAUD','B72|BR8|BRW' )  //Hist. Aud. Guia  (PLSMFUN)

// rotinas menus
oHash:Set('PLSA010',"BA0|SA2|SA1|BAU|BIM|BIF|B07") // operadora de sa�de
oHash:Set('PLSA980',"BT5|BQC") // operadores do sistema
oHash:Set('PLSA040',"BI4") // tipos de acomoda��o
oHash:Set('PLSA700',"BK5") // contatos ans
oHash:Set('PLSA070',"BA9|BAA") // cid - doen�as
oHash:Set('PLSA370',"BAQ|BBM") // cadastro de especialidades
oHash:Set('PLSA245',"BFN|BFP") // subespecialidades
oHash:Set('PLSA202',"BJE") // classes de procedimentos
oHash:Set('PLSA586',"BLE") // pacotes
oHash:Set('PLSA320',"BC9") // cadastro de cep
oHash:Set('PLSA170',"BY7") // regi�es
oHash:Set('PLSA120',"BD1") // ambulatorios
oHash:Set('PLSA131',"BDI") // local x procedimentos x rda
oHash:Set('PLSA401',"BA9") // grupos de quantidade
oHash:Set('PLSA800',"BT4|BAU|BQP") // produtos de sa�de
oHash:Set('PLSA230',"BAG") // classe rede de atendimento
oHash:Set('PLSA035',"BK6") // rede n�o-referenciada
oHash:Set('PLSA960',"BB0") // profissionais de sa�de
oHash:Set('PLSA360',"BAU|BAQ|BBF|BBE|BBC|BYV|B25|B26") // rede de atendimento
oHash:Set('PLSA570',"BC4") // rda - historico de bloqueio
oHash:Set('PLSA366',"BAU") // rda - forma de pagamento
oHash:Set('PLSA105',"BAU") // rda x tabela de pre�os
oHash:Set('PLSA587',"BAU") // rda x pacotes
oHash:Set('PLSA006',"BAU|BB8") // c�pia de local de atendimento
oHash:Set('PLSA728',"B9H|B9K") // agente x cidades de atendimento
oHash:Set('PLSA807',"B9W|BAU|B9V") // visita de relacionamento
oHash:Set('PLSA809',"B9Y|B9V") // indica��o de prestador via callcenter
oHash:Set('PLSA725',"B99") // passos do crendeciamento
oHash:Set('PLSA743',"B9S") // dimensionamento de rede
oHash:Set('PLSA806',"B9P|B9V") // visitas de capta��o
oHash:Set('PLSA814',"B98") // an�lise de altera��es cadastrais
oHash:Set('PLSCADFE',"B4T") // cadastro de feriados
oHash:Set('PLSRPS',"BAU") // prestador x rps
oHash:Set('PLSA813',"B9Y|B9V") // candidatos
oHash:Set('PLSA816',"B4G") // passos da an�lise
oHash:Set('PLSA903',"BXL|BXM|BXJ") // equipe de vendedores
oHash:Set('PLSA907',"BXN|SA3") // metas de venda
oHash:Set('PLSA904',"BXJ|SA3|BXN") // regras de comiss�o
oHash:Set('PLSA911',"BXS|SA3|BXL") // regras de composi��o p base de c�lculo de comiss�o
oHash:Set('PLSA908',"BXO|SA3") // consulta de programa��o
oHash:Set('PLSA909',"BXQ") // consulta de comiss�o
oHash:Set('PLSA930',"BLA") // concorrentes do plano de saude
oHash:Set('PLSA910',"SUS|BL4|BL8|BLA") // simula��o de venda
oHash:Set('PLSM153',"SE2") // exclus�o de t�tulos de pagamento comiss�o
oHash:Set('PLSA990',"BRP") // grau de parentesco
oHash:Set('PLSA955',"BTS") // vidas
oHash:Set('PLSA660',"BG9") // grupos empresa
oHash:Set('PLSA174',"BG9") // grupo familiar / benefici�rios
oHash:Set('PLSA169',"BG9|BT5") // transfer�ncia de benefici�rio
oHash:Set('PLSA530',"BXA|BXC|BA1") // entrevista qualificada
oHash:Set('PLSALTUEVE',"BA1|SA3") // benefici�rios eventuais
oHash:Set('PLSA038',"BQC|SA3|BC9") // valor unidade de servi�o p subcontrato e unidade
oHash:Set('PLSA032',"BQC") // coparticipa��o subcontrato por hor�rio
oHash:Set('PLSA119',"SA1") // salario x compet�ncia
oHash:Set('PLSA977AB',"BBA|BQC") // an�lise de benefici�rios
oHash:Set('PLSA99B',"B5J|B5K") // solicita��o de cancelamento de planos
oHash:Set('PLSA262',"BDE|BED") // lotes de cart�o de identifica��o
oHash:Set('PLSA261',"BED") // lan�amentos avulsos cart�o de identifica��o
oHash:Set('PLSA094B',"BEA|BE2|BAU|BA9|B4B|BB0") // libera��o sadt
oHash:Set('PLSA094D',"BEA|BE2|BAU|BA9|BB0") // libera��o odontol�gica
oHash:Set('PLSA460',"BEA|BE2|BAU|BA9|B4B|BB0") // libera��o especial
oHash:Set('PLSA094A',"BEA|BE2|BAU|BA9|BB0") // autoriza��o sadt
oHash:Set('PLSA09U',"BEA|BKU|BAU|BA9|BB0|B4B") // an�lise de solicita��es de autoriza��o
oHash:Set('PLSA094C',"BEA|BE2|BAU|BA9|BB0") // autoriza��o odontol�gica
oHash:Set('PLSA001A',"BOW|BAU|B1N|BOX") // protocolo de reembolso
oHash:Set('PLSA001',"B44|BAU|B45|SA1|BB0|BA9") // autoriza��o de reembolso
oHash:Set('PLSA195',"BA5") // visualizar libera��es especiais
oHash:Set('PLSA09A',"B4A|B4C") // anexos clinicos
oHash:Set('PLSA092',"BE4|BEJ|B4Q|BA9|BB0") // autoriza��o de interna��o
oHash:Set('PLSA09P',"B4Q|BQV|BB0") // prorroga��o de interna��o
oHash:Set('PLSA773',"B00") // protocolo de negativas
oHash:Set('PLSA031',"BDS") // consultar historico de autoriza��es for�adas
oHash:Set('PLSA790V',"BE2|B53") // auditoria por guia
oHash:Set('PLSA790',"BA1") // movimenta��o de auditoria
oHash:Set('PLS790MOV',"BE2") // auditoria por procedimento
oHash:Set('PLSANRCT',"B4F|BB0") // analise de receitas
oHash:Set('PLSA097',"BAU|BEP") // confirma��o de libera��o
oHash:Set('PLSAGHI',"B0D|B4B") // guia de honorario individual
oHash:Set('PLSA499',"BAU") // processo agrupamento de pegs
oHash:Set('PLSA175',"BAU|BCI") // pegs
oHash:Set('PLSA746',"BAU") // calend�rio para envio/entrega de fatura
oHash:Set('PLSA498',"BAU|BCI") // digita��o de contas
oHash:Set('PLSA600',"BAU|BCI") // an�lise de contas m�dicas
oHash:Set('PLSA298',"B19") // cadastro de nf's entrada x guias
oHash:Set('PLSRECGLO2',"B4D") // recurso de glosa
oHash:Set('PLSA508',"BAU|BD7") // protocolo de entrega de lote de guias
oHash:Set('PLSA101',"BA3|BA1|BPB|BPV") // reajuste de contrato
oHash:Set('PLSM220',"BDH") // reconsolida��o individual
oHash:Set('PLSA118',"BA1|B79|B80") // parcelamento de co-participa��o
oHash:Set('PLSA756',"BSQ|BA1") // d�bitos/cr�ditos para composi��o cobran�a
oHash:Set('PLSA627',"BDF") // cabe�alho de cobran�a
oHash:Set('PLSA628',"SE1|BTV") // lotes de interc�mbio
oHash:Set('PLSBAIXA',"SA1|SE1|SA3") // recebimento de titulos no caixa
oHash:Set('PLSA629',"SE1") // cancelamento de titulos
oHash:Set('PLSA631',"BBT") // cabe�alho de cobran�a
oHash:Set('PLSA220',"BA3|SA1|SA2|SE1|BC3|BED|BA1") // baixa de titulos
oHash:Set('PLSA1X',"B1I") // tabela de reembolso patronal
oHash:Set('PLSA755',"BGQ|BAU") // d�bitos/cr�ditos redes de atendimento
oHash:Set('PLSA367',"BAU") // rede de atendimento
oHash:Set('PLSA470',"SE2|BGQ") // lotes de pagamento da rede de atendimento
oHash:Set('PLSCTB06',"BAU") // contabiliza��o off-line de despesa
oHash:Set('PLSCTB11',"SA1") // contabiliza��o off-line de receita
oHash:Set('PLSA610',"BF0") // naturezas de sa�de
oHash:Set('PLSA281',"BAU|BBF") // ficha de matricula e controle do capital social
oHash:Set('PLSA282',"BAU|BBF") // lan�amentos na ficha de matricula e controle do capital social
oHash:Set('PLSA283',"BAU|BBF") // ficha de matricula e controle do capital social
oHash:Set('PLSA226',"BSW|BSO|BAU|B49|BX1") // usuarios do portal
oHash:Set('PLSEVNOT',"BAU") // cadastro de noticias
oHash:Set('PLSA730',"BA3|SA1|SA2|SE1|BC3|BED|BA1") // consulta posi��o do usu�rio
oHash:Set('PLSC010',"BQC|SA1|SA2") // sinistralidade
oHash:Set('PLSR999',"BD6") // limite por beneficiario
oHash:Set('PLSR096',"BB3|BRY") // valor produto x faixa etaria x adesao
oHash:Set('PLSR606',"BAU|SXA|SX3") // lista de rda
oHash:Set('PLSR210',"BAU|BID") // etiquetas de credenciados
oHash:Set('PLSR820',"BAU|BAX|BAQ") // rda por especialidade
oHash:Set('PLSR098',"BB0") // profissionais da saude
oHash:Set('PLSR951',"BAU") // documentos pendentes
oHash:Set('PLSR953',"B9V") // capta��es
oHash:Set('PLSR954',"B9V") // visitas
oHash:Set('PLSR014',"BAU") // rda a vencer
oHash:Set('PLSR921',"SA3|BA1") // calculo de comiss�es
oHash:Set('PLSR922',"BXQ|SA3|BA1") // calculo de comiss�es
oHash:Set('PLSR257',"SA3") // usuarios / vendedor por cliente
oHash:Set('PLSR258',"SA3") // vendas por regi�o
oHash:Set('PLSR259',"SA3") // usuarios / vendedor por produto
oHash:Set('PLSR501',"SA3") // clientes inadimplentes por vendedor
oHash:Set('PLSR502',"SA3|BA9") // preexistencia de doen�as por vendedor
oHash:Set('PLSR910',"SUS|") // proposta comercial 
oHash:Set('PLSR660',"BTN|BT6|BI3|BR6|BG9|BT5|BQB") // grupo/empresa pessoa juridica
oHash:Set('PLSR612',"BA3|BA1|BG9|BII|BQC") // cadastro de familias
oHash:Set('PLSR198',"BQC|BA1|BA0|BG9") // vidas por operadora/empresa/contrato/subcontrato
oHash:Set('PLSR613',"BA1|BG9|BQC|SXA") // cadastro de usuarios
oHash:Set('PLSR615',"BA1|BG9|BT5|BQC") // familias/usuarios
oHash:Set('PLSR614',"BA1") // etiquetas de usuarios
oHash:Set('PLSR616',"BTS|SXA") // cadastro de vidas
oHash:Set('PLSR711',"BTS|BA1|BA0|BG9|BA3|BI3|BG1") // vidas x usuarios x familias
oHash:Set('PLSR101',"BA3|BA1") // familia/usuario por empresa
oHash:Set('PLSR161',"BF1|BA0|BI3|BA1|BRP|BA0") // usuarios por opcional
oHash:Set('PLSR166',"BA1") // usuarios por opcional
oHash:Set('PLSR618',"BA1|BG9|BQC") // totais de usuarios por grupo/empresa e por tipo
oHash:Set('PLSR453',"BA3") // usuarios por idade
oHash:Set('PLSR740',"BA3|BA1|BG9|BI3") // movimenta��o dos beneficiarios
oHash:Set('PLSR743',"BA0|BI3") // inclus�o e exclus�o de usuarios por produto
oHash:Set('PLSR252',"BA1") // declara��o de uso do plano de saude
oHash:Set('PLSR039',"SE1|BD6|BG9|SA1|BDH|BA1|BAU|BD7|BWT") // movimenta��o de familia
oHash:Set('PLSR097',"BQC|BG9|BTN|BI3|BR6|BA1") // valores por subcontrato x faixa etaria x ades�o
oHash:Set('PLSR994',"BA1") // carta maioridade
oHash:Set('PLSR267',"BA1") // documentos a vencer
oHash:Set('PLSR993',"BA1|BA0") // carta de portabilidade
oHash:Set('PLSR038',"BED|BQC|BA1|BA3") // cart�es de identifica��o emitidos
oHash:Set('PLSR044',"BA1") // cart�es de identifica��o a vencer
oHash:Set('PLSR015',"BE4|BA0|BAU|BQV|BR8") // interna��es
oHash:Set('PLSR026',"BDX|BE4|BD5|BD6|BCI|BD7|BCL") // listagem da peg
oHash:Set('PLSR661',"BE4") // controle de diarias por rda
oHash:Set('PLSR958',"BCI") // faturas liberadas
oHash:Set('PLSR062',"BAU|BSU|BKD") // atividades de prestadores
oHash:Set('PLSR063',"BAU") // curva de gauss por especialidade
oHash:Set('PLSR064',"BAU") // curva de gauss por localidade
oHash:Set('PLSR982',"BAU|BA1") // acompanhamento mensal dos auto-gerados
oHash:Set('PLSR983',"BAU|BA1") // saldo de auto-gerados
oHash:Set('PLSR233',"BK6|BA0|BA1|BKD") // recibo de reembolso
oHash:Set('PLSR987',"B44|BA1|B45|BKD") // rela��o de reembolso
oHash:Set('PLSR991',"BOW|BA1|BOX|B44") // protocolo de reembolso
oHash:Set('U_PLSR788',"BA1|BK6") // reembolso anal�tico
oHash:Set('PLSR992',"BB0|B44|B45|BR4|BR8|SE1|BD6") // reembolso por solicita��o
oHash:Set('PLSR510',"BA3|BA1") // empresas para reajustar
oHash:Set('PLSR511',"BA0|BPE|BG9|BPF|BYC|BI3|BG9|BQC|AAD|BT6|BYF|BHL|BK2|BA1|BFQ") // empresas reajustadas
oHash:Set('PLSR199',"BQC|BT6|BI3|BIL|BHS|BTN|BFT|BR6|BFV|BBX|BGW") // valor produto x subcontrato
oHash:Set('PLSR256',"BA1|BA3|BI3|BD6") // valor de cobran�a
oHash:Set('PLSR595',"SE1") // confer�ncia de lote de cobran�a
oHash:Set('PLSR266',"BG9|BT5|BQC|BA3|BA1") // empresa / familia n�o faturada
oHash:Set('PLSR580',"BM1|SA6|SA1|BA0|BA1") // emiss�o de boleto
oHash:Set('PLSR591',"BA1") // resumo de interc�mbio eventual
oHash:Set('PLSR450',"BD6") // faturamento de interc�mbio
oHash:Set('PLSR761',"SE1") // mapa de faturamento 
oHash:Set('PLSR250',"BA3|SE1|BA1|SA1") // posi��o financeira de cobran�a
oHash:Set('PLSR671',"BA3|SA1") // carta de cobran�a
oHash:Set('PLSR451',"BD6|BA1") // stop loss
oHash:Set('PLSR196',"SE1|BA1|BI3") // rela��o de inadimplencia por periodo
oHash:Set('PLSR674',"BA0|SE1|BRJ|BAG|BAU") // confer�ncia de pagamento de interc�mbio
oHash:Set('PLSR180',"BAU") // previs�o de pagamento
oHash:Set('PLSR454',"SA2|BD1|BG9|BR8|BAQ") // mapa de previs�o de pagamento
oHash:Set('PLSRELDAC',"BAU|BD7|BA1") // demonstrativo de an�lise de conta
oHash:Set('PLSRELDPM',"BAU|SA2") // demonstrativo de pagamento
oHash:Set('PLSR023',"BA0|BAU") // resumo d�bito/cr�dito
oHash:Set('PLSR181',"BD7|BD6") // glosas
oHash:Set('PLSR025',"BD6|BA0|BA1") // servi�os prestados por beneficiarios
oHash:Set('PLSR732',"BD7") // ranking por rda
oHash:Set('PLSR733',"BD6") // ranking por beneficiarios
oHash:Set('PLSR754',"BD5|BEA|BD6|BEJ") // rela��o de autoriza��es
oHash:Set('PLSR734',"BD6") // receita x despesa p/ contr./fam./usuario
oHash:Set('PLSR022',"BA0|BD6|BTS|BIH|BI3|BII|BA1|BF7|BI6|BI4|BAT|BG9|BQC") // extrado de utiliza��o do usu�rio
oHash:Set('PLSR017',"BE4") // relatorio de prorroga��o de di�rias para lote
oHash:Set('PLSR997',"BA1|BM1|BB0") // demonstrativo de imposto de renda
oHash:Set('PLSR996',"BA3|BA1|BQC|BG9") // sinistralidade
oHash:Set('PLSR018O',"BAU|BA1|BD7|SA2") // demonstrativo de pagamento
oHash:Set('PLSR401',"SE1|BBT|BA1|BA0|BQB|BCA|BI3|BM1|BII|BI6") // contratos e contrapresta��es
oHash:Set('PLSR415',"BA1") // resumo para taxa de saude
oHash:Set('PLSR249',"BE4|BA1") // analitico sip
oHash:Set('PLSR402',"BA1|BM1") // contrapresta��es recebidas
oHash:Set('PLSR403',"BA1|SA1|BD6") // registro de eventos conhecidos
oHash:Set('PLSR404',"BA1|SA1|BD6") // eventos de pegs e rdas
oHash:Set('PLSR405',"BA1|SA3|BXQ") // registro de comiss�es de vendedores
oHash:Set('PLSR406',"BA1|SA1|BD5") // eventos ressarcidos e recuperados
oHash:Set('PLSR442',"BA1|BK6|BAU|BOW") // registro de eventos conhecidos ou avisados
oHash:Set('PLSR444',"BA1|BK6|BAU|BOW") // registro de eventos ressarcidos ou recuperados
oHash:Set('PLSR441',"BA1|BK6|BAU|BOW") // registro de contratos e contrapresta��es
oHash:Set('PLSR407',"SA1|BA3") // provis�o de perdas sobre cr�ditos
oHash:Set('PLSR261',"BAU") // ficha de matricula de capital social
oHash:Set('PLSR262',"BAU") // capital social
oHash:Set('PLSR263',"BAU") // tabela de pagamento para cota do capital social
oHash:Set('PLSR264',"BAU") // juros do capital social
oHash:Set('PLSR446',"BAU") // confer�ncia cont�bil
oHash:Set('PLSR447',"BD6|BD7") // guias a contabilizar
oHash:Set('PLSM240',"SRA") // esocial plano de saude
oHash:Set('PLSUARPC',"BA1") // gera��o rpc
oHash:Set('PLSA782',"BA1|BTS|SA1") // sib xml
oHash:Set('PLSM270',"B4N|B4O|B4M|B8Q|B8R") // monitoramento tiss
oHash:Set('PLSM270ZTC',"B4V") // conferencia monitoramento
oHash:Set('PLSRPS4',"B5B") // lote rps
oHash:Set('PLSRELEP',"BAU") // estatistica partos
oHash:Set('PLSPRO02',"BOU") // sinalizadores / alerta
oHash:Set('PLSA770',"BA1") // bloqueio autom�tico
oHash:Set('PLSA771',"BA1") // aviso de cobran�a
oHash:Set('PLSA772',"SA1") // declara��o anual de d�bitos
oHash:Set('PLSA553',"B0R") // importa��o xml sus
oHash:Set('PLSA552',"B0R|B0W") // transf�rencia processamento de contas
oHash:Set('PLSR552',"B0R") // ressarcimento sus
oHash:Set('PLSA086',"BXE") // autoriza��es negadas
oHash:Set('PLSA267',"B5A|SA1") // cadastro da dmed
oHash:Set('PLSMVCPRO',"B3F") // manutencao de produtos no nucleo de informacoes e obrigacoes
oHash:Set('PLSMVCBENE',"B3K|B3X|B4W") // manutencao de beneficiarios no nucleo de informacoes e obrigacoes
oHash:Set('PLSMVCDESP',"B3L|B3F") // manutencao de eventos X despesas no nucleo de informacoes e obrigacoes
oHash:Set('PLSBENANS',"B3W") // benefici�rios ans


//Rotinas m�dulo PON
oHash:Set('PONA010','SRA' ) //Cadastro de Marcacoes
oHash:Set('PONA030','RFE|SRA' ) //Cadastro de Relogio de Ponto
oHash:Set('PONA040','SRA|ALI' ) //Manuten��o no Arquivo de Marca��es
oHash:Set('PONA060','SRA' ) //Cadastro Regras de Apontamento
oHash:Set('PONA080','SRA' ) //Cadastro de tabela de Horario Padrao
oHash:Set('PONA090','SRA' ) //Cadastro de Excecoes
oHash:Set('PONA130','SRA' ) //Manutencao dos Apontamentos
oHash:Set('PONA140','SRA' ) //Manutencao das Exce��es Diarias
oHash:Set('PONA150','SRA' ) //Manutencao das Refei��es
oHash:Set('PONA160','SRA' ) //Manuten��o de Transferencias de Turnos
oHash:Set('PONA161','SRA' ) //Manuten��o de Transferencias de Turnos B
oHash:Set('PONA170','SRA' ) //Manutencao de Resultados/Acumulado de Resultados
oHash:Set('PONA200','SRA' ) //Manutencao do Banco de Horas
oHash:Set('PONA210','SRA' ) //Manutencao dos abonos
oHash:Set('PONA230','SRA|ALI' ) //Manutencao de Marca��es Diarias por Centro de Custo
oHash:Set('PONA260','SRA' ) //Cadastro Tipos de Refeicoes
oHash:Set('PONA280','SRA' ) //Manutencao Integrada de Lancamentos
oHash:Set('PONA300','SRA' ) //Manutencao de HE Autorizadas
oHash:Set('PONA330','SPW|SPY' ) //Cadastro de Visitantes
oHash:Set('PONA340','SPW|SPY|CTT|SRA' ) //Cadastro de Visitas
oHash:Set('PONA350','SRA' ) //Manutencao de Pre-Abonos
oHash:Set('PONA420','SRA' ) //Cadastro Tabela de Horario Padrao
oHash:Set('PONA450','SRA' ) //Controle de Espelhos de Ponto
oHash:Set('PONM010','RFE|SRA|SPY' ) //Classificacao de Marcacoes
oHash:Set('PONM020','SRA' ) //Graficos
oHash:Set('PONM030','SRA' ) //Geracao de Marcacoes
oHash:Set('PONM040','RGB|SRA|SRC|SR8' ) //Integracao Folha de Pagamento
oHash:Set('PONM050','SRA' ) //Exclusao de Informacoes Apontadas pelo SIGAPON
oHash:Set('PONM060','SRA' ) //Abono Coletivo
oHash:Set('PONM070','SRA' ) //Calculo Mensal
oHash:Set('PONM080','SRA' ) //Fechamento Banco de Horas
oHash:Set('PONM081','RGB|SRA' ) //Apuracao Banco de Horas para o eSocial
oHash:Set('PONM090','RFE|SRA|RFH' ) //Fechamento Mensal
oHash:Set('PONM310','SRA' ) //Processa Registro Coletivo de Autorizacao de HE
oHash:Set('PONM330','CSP|SRA' ) //Grafico de Eventos
oHash:Set('PONM410','CSP|RFE|SRA|RFH' ) //Gera arquivo AFDT - SREP
oHash:Set('PONM420','CSP|SRA' ) //Gera arquivo ACJEF - SREP
oHash:Set('PONM440','RA2|SRA|RA4' ) //Gera��o de pr�-abonos baseado nos treinamentos (SIGATRM)
oHash:Set('PONPGONL','SRA' ) //PAINEL Modulo PON
oHash:Set('PONR010','SRA' ) //Espelho do Ponto
oHash:Set('PONR020','SRA' ) //Totais dos codigos do ponto
oHash:Set('PONR030','SRA|CTT' ) //Relatorio de Presentes/ Ausentes
oHash:Set('PONR040','SRA|CTT' ) //Divergencias nas marcacoes
oHash:Set('PONR050','SRA|CTT' ) //Relatorio para Abono
oHash:Set('PONR060','SRA|CTT' ) //Autorizacao do Pagamento de Horas Extras
oHash:Set('PONR070','SRA|CTT' ) //Controle de Refeicoes
oHash:Set('PONR080','SRA|CTT' ) //Relatorio de Apuracoes Percentuais
oHash:Set('PONR090','SI3|SRA|CTT' ) //Relatorio por Codigos
oHash:Set('PONR100','SRA|CTT' ) //Relatorio de Banco de Horas
oHash:Set('PONR110','SRA' ) //Relatorio para Autorizacoes
oHash:Set('PONR120','SPW|SRA|SPY|CTT' ) //Controle de Visitantes
oHash:Set('PONR130','SPW|SI3|SRA|SPY' ) //Relatorio de visita - Ponto Eletronico
oHash:Set('PONR140','SRA|RFE' ) //Espelho do Ponto (De acordo com Portaria 1510/2009)
oHash:Set('PONR150','SRA|CTT' ) //Relat�rio de Espelhos N�o Baixados
oHash:Set('PONR160','SRA' ) //Relatorio Faltas

//Rotinas modulo RSP
oHash:Set('RSPA010','SQG|SQD|SRA|SQL|SQS' ) //Cadastro de Curriculos
oHash:Set('RSPA040','SQD' ) //Programa de Montagem de Avaliacoes.
oHash:Set('RSPA090','SQS|SQG' ) //Pesquisa de Curriculos
oHash:Set('RSPA100','SRA|SQG|SQS|SQD' ) //Cadastro de Vagas
oHash:Set('RSPA130','SQG|SQD' ) //Rotina de Realizacao de Testes.
oHash:Set('RSPA150','SQG|SQS|SQD' ) //Agenda os candidatos para os processos
oHash:Set('RSPA170','SQG' ) //Importacao de Curriculo atraves de arquivo XML.
oHash:Set('RSPA220','SQG' ) //Cadastro de Config. Campos Portal (RS1)
oHash:Set('RSPG010','SQG|SQS|SQD' ) //Grafico comparativo Cargo x Candidatos.
oHash:Set('RSPM001','SQG|SRA|SQS|SQD' ) //Admissao de Funcioario atraves do Curriculo
oHash:Set('RSPM002','SQG|SRA|RA4' ) //Processo de Selecao interna (Funcionarios)
oHash:Set('RSPPGONL','SQG|SRA|SQS' ) //PAINEL modulo RSP
oHash:Set('RSPR004','SRA|SQS' ) //Relacao de Vagas
oHash:Set('RSPXCAPA','RA2|RAJ|SRA|RAI|RA4|SQG|SQD' ) //Rotinas para Realizacao de Avaliacoes.

//Rotinas Modulo TCF
oHash:Set('TCFA003','SRA' ) //Geracao de senhas para o Terminal de Consultas
oHash:Set('TCFA011','SRA' ) //Cadastrar mensagens para o funcionario
oHash:Set('TCFA030','SRA|RH3' ) //Poupa Tempo
oHash:Set('TCFA040','SRG|RA2|RIA|SRB|SQG|SRA|SR8|RBT|RHI|SRF|SQS|RBX|RH3' ) //Atendimento de Solicitacoes do Portal
oHash:Set('TCFA050','SRA|RH3' ) //Solicitacao de Alteracao cadastral
oHash:Set('TCFA060','SRA' ) //Consulta de Saldo de FGTS
oHash:Set('TCFA070','SRA' ) //Consulta de Saldo do banco de horas
oHash:Set('TCFA080','SRA' ) //Consulta da Tabela de Horarios
oHash:Set('TCFA090','SRA' ) //Consulta do Espelho de Ponto
oHash:Set('TCFA110','RBA' ) //Cadastro de Responsaveis e Responsabilidades.
oHash:Set('TCFA130','SRA|RD0' ) //Manutencao senhas portal

//Rotinas modulo TRM
oHash:Set('TRMA010','RA2|RA4' ) //Cadastro das Entidades dos Cursos
oHash:Set('TRMA020','SRA' ) //Controle dos programas do Cargo
oHash:Set('TRMA040','RA2' ) //Cadastro de Cursos
oHash:Set('TRMA050','RA2|RA8|CTT|RA7|RA4|SRA' ) //Cadastro dos Treinamentos
oHash:Set('TRMA060','RA2|SRA|RAI|RA7|RA4|CTT' )//Reserva de Treinamentos
oHash:Set('TRMA090','RA2|SRA|CTT|RA4' ) //Controle das Despesas do Curso
oHash:Set('TRMA100','RA2|RFS|SRA|RBW|RAI|RA4|SRF' ) //Controle dos programas do funcionario
oHash:Set('TRMA110','RA4' ) //Cadastro de Categorias de Cursos (AIQ)
oHash:Set('TRMA130','RA8|SRA|CTT|RA4' ) //Cadastro dos Planejamentos dos Treinamentos
oHash:Set('TRMA140','RA7' ) //Cadastro dos Instrutores dos Cursos
oHash:Set('TRMA190','RAJ|SRA' ) //Realizar Avaliacoes
oHash:Set('TRMA200','RA2|SRA|CTT' ) //Agenda de Funcionarios para Realizacao de Testes.
oHash:Set('TRMA250','A11' ) //Cadastro de Conjunto de Etapas
oHash:Set('TRMA260','A11|SRA|RA4' ) //Manuten��o de CheckList(Tabela A11)
oHash:Set('TRMM010','SRA|RA4' ) //Processamento de Necessidades de Treinamento
oHash:Set('TRMM020','SI3|SRA|RA4|CTT' ) //Registro de Treinamento Coletivo
oHash:Set('TRMM030','SI3|SRA|CTT' ) //Solicitacao Coletiva de Treinamento.
oHash:Set('TRMM060','RA2' ) //E-mail de Aviso de Treinamento.
oHash:Set('TRMM080','SRA' ) //Sugest�o de treinamento de acordo com as habilidades
oHash:Set('TRMM090','SRA' ) //Carga de dados no EPM/AMS
oHash:Set('TRMM100','RA2' ) //Sugest�o de turmas para treinamento
oHash:Set('TRMPGONL','RA2|RA8|RA4|SRA' ) //PAINEL modulo TRM
oHash:Set('TRMR020','RA2|SI3|RAJ|SRA|RAI|RA4' ) //Relatorio de Cargos do Treinamento
oHash:Set('TRMR030','RA8|SRA|RA4|CTT' ) //Planejado x Realizado
oHash:Set('TRMR080','RA8' ) //Relatorio de Planejamentos.
oHash:Set('TRMR090','RA2|RA7' ) //Relatorio de Calendario de Cursos.
oHash:Set('TRMR100','RA2|SRA|CTT|RA4' ) //Relat�rio de Vencimento de Cursos
oHash:Set('TRMW010','RA2|SRA|CTT|RA4' ) //WorkFlow de vencimento de cursos

//Rotinas do modulo VDF
oHash:Set('VDFA040','SQG|REY|REZ' ) //Cadastro de Candidato x Concurso / Controle de Requisitos.
oHash:Set('VDFA060','SQG|REY|SRA' ) //Geracao dos Itens de Atos/Portarias.
oHash:Set('VDFA070','RI8|SRA' ) //Manuten��o de Substitui��es
oHash:Set('VDFA090','SRA|RIP' ) //Cadastro de Pericias de Pensionistas
oHash:Set('VDFA100','SRA|RII|RI6' ) //Averba��es de Tempo de Contribui��o
oHash:Set('VDFA110','RIJ|SRA' ) //Abono Perman�ncia Cadastro do Direito.
oHash:Set('VDFA120','SRA' ) //Cadastro de Lan�amentos Automaticos
oHash:Set('VDFA150','SRA|RIM' ) //Controle de Promotores Eleitorais
oHash:Set('VDFA170','SRA' ) //Manuten��o de Aposentados e Pensionistas
oHash:Set('VDFA210','SRA|RI6|SR8' ) //Historico de Atos/Portarias
oHash:Set('VDFA220','SRA|RIL|RI6' ) //Manuten��o do hist�rico de designa��es
oHash:Set('VDFC010','SRA|SR8|RI6' ) //Processo de Est�gio Probat�rio e Vitaliciamento.
oHash:Set('VDFC020','RID' ) //Historico de Adidos/Cedidos
oHash:Set('VDFM010','SQG|REY|REZ' ) //IMPORTA��O de candidatos
oHash:Set('VDFM020','SRA|RI6|REY' ) //Rotina para sele��o dos atos.
oHash:Set('VDFM040','SQG|SRA|REY|RI6|REZ' ) //Inclus�o de Candidato na Folha de Pagamento.(Admissao)
oHash:Set('VDFM050','SRA' ) //Email Aviso de Prazos para Vitaliciamento
oHash:Set('VDFM060','SRA|RIE|RI6|RII' ) //Certid�o de Tempo de Contribui��o
oHash:Set('VDFM090','RIP|SRA' ) //E-Mail de Alerta de Per�cia de Aposentados e Pensionistas
oHash:Set('VDFM180','SRA|RID' ) //Altera��o de Cragos e Subsidios
oHash:Set('VDFM210','SRA|REY|SQG|RI6' ) //Editor Itens de Atos/Portarias
oHash:Set('VDFR010','SRA' ) //Relatorio de Vitaliciamento de Membros.
oHash:Set('VDFR020','SRA' ) //Relat�rio de Jornada dos Servidores
oHash:Set('VDFR030','SRA' ) //Relat�rio de Servidores em Hor�rio Especial
oHash:Set('VDFR040','SRA|SR8' ) //Relatorio de periodo de afastamento
oHash:Set('VDFR050','SRA|RI6' ) //Relatorio Certidao
oHash:Set('VDFR060','RIE|RIG' ) //Certid�o de Tempo de Contribui��o
oHash:Set('VDFR070','SRA|SRF' ) //Relat�rio de Periodo Aquisitivo de F�rias
oHash:Set('VDFR080','RIA|SRA|SRF' ) //Relat�rio de f�rias j� usufru�das membros e servidores
oHash:Set('VDFR090','SRA|SRF' ) //Rela��o de Prazos de F�rias
oHash:Set('VDFR100','SRA|SR8' ) //Rela��o de Servidores Afastamentos
oHash:Set('VDFR110','SRA|RID' ) //Rela��o de Servidores Cedidos
oHash:Set('VDFR120','SRA|RID' ) //Rela��o de Servidores Adidos
oHash:Set('VDFR130','SRA|RI6' ) //Relat�rio de Controle de Nomea��es
oHash:Set('VDFR140','SRA|RI6' ) //Relat�rio de Controle de Exonera��es
oHash:Set('VDFR150','SRA|RI6' ) //Relat�rio de Controle de Relota��es
oHash:Set('VDFR160','SRA' ) //Relat�rio de Remo��es
oHash:Set('VDFR170','SRA|RI6' ) //Relat�rio de Afastamentos
oHash:Set('VDFR180','SRA|SR8|RI6' ) //Relat�rio de Retorno de Afastamentos
oHash:Set('VDFR190','SRA|RI6' ) //Relat�rio de Aposentadorias
oHash:Set('VDFR200','SRA|RIM|RII' ) //Controle de Promotores Eleitorais
oHash:Set('VDFR210','SRA|SRC|SR8' ) //Relat�rio por Verba x Dias de Afastamentos
oHash:Set('VDFR220','RIA|SRA|SRF' ) //Relat�rio de F�rias Indenizadas
oHash:Set('VDFR230','SRA|SRC' ) //Verbas Indenizat�rias para Diligencias
oHash:Set('VDFR240','RIA|SRA|SRF' ) //Relat�rio de Controle de Recesso Remunerado de Estagi�rios
oHash:Set('VDFR250','SRA' ) //Quadro do Grupo de Provimento em Cargo Efetivo por Categoria
oHash:Set('VDFR260','SRA' ) //Quadro do Grupo de Provimento em Comiss�o por Categoria
oHash:Set('VDFR270','SRA' ) //Quadro Porcentagem Cargo em Comiss�o Reservado para Efetivos
oHash:Set('VDFR280','SRA' ) //Quadro de Provimento de Membros por Categoria
oHash:Set('VDFR290','SRA|SR8' ) //Relatorio de Licen�as e Afastamentos
oHash:Set('VDFR300','SRA' ) //Rela��o de Cargos em Comiss�o e Ocupando Cargos Efetivos
oHash:Set('VDFR320','SRA|RII|RI6' ) //Relat�rio de Antiguidade dos Membros
oHash:Set('VDFR330','SRA' ) //Relat�rio de Estagi�rios Ativos
oHash:Set('VDFR340','SRA' ) //Relat�rio de Admitidos
oHash:Set('VDFR350','SRA' ) //Relat�rio de Exonerados
oHash:Set('VDFR360','SRA' ) //Demonstrativo Anal�tico do Lotacionograma
oHash:Set('VDFR370','SRA|SRC|SR8' ) //Relat�rio de progress�o funcional Vertical
oHash:Set('VDFR380','SRA|RI8' ) //Relat�rio de Exerc�cio Cumulativo de Fun��o
oHash:Set('VDFR390','SRA|RI8' ) //Relat�rio por exerc�cio de Dif�cil Provimento.
oHash:Set('VDFR400','SRA' ) //Relat�rio de Quadro de Estagi�rios Existentes
oHash:Set('VDFR410','SRA|RI6' ) //Declara��o, Certid�o e Certificado de Estagi�rios
oHash:Set('VDFR420','SRA|RIL' ) //Rela��o de Promotores de Justi�a
oHash:Set('VDFR430','SRA|RIL' ) //Relat�rios de Membros designados pelo ATO N� 365/2011
oHash:Set('VDFR440','SRA|RIL' ) //Relat�rio da Lotacionograma
oHash:Set('VDFR450','SRA' ) //Relat�rio da Lotacionograma Word
oHash:Set('VDFR460','SRA' ) //Calculo do tempo de aposentadoria

//Integracoes
oHash:Set('APDI020','RD0' ) //EAI - People
oHash:Set('GPEI010','SRA|CTT|SRF' ) //EAI - Employee
oHash:Set('GPEI041','SRG|SRH|SRA|SR8' ) //EAI - EmployeeSituations
oHash:Set('GPEI050','SRA|SRF' ) //EAI - VacationSchedule
oHash:Set('GPEI056','SRA|CTT' ) //EAI - Programacao de Rateios
oHash:Set('GPEI090','SA2|RGB|SRA|CTT' ) //EAI - MonthlyPayrrol
oHash:Set('GPEI250','RHH|SRA' ) //EAI - EmployeeHistorySalaryPosition
oHash:Set('GPEI281','SM3' ) //EAI - BankTransactions
oHash:Set('GPEICAL2','SRA' ) //Calcula o custo do funcionario
oHash:Set('GPEM810','SRA|RGB' ) //integracao RM - Movimento do Periodo
oHash:Set('GPEY240','SRG|SRA|SR8' ) //EAI - ReturnEmployeeSituations
oHash:Set('GPEYGIF','SRA|SRC' ) //EAI - RequestApportionmentPayroll
oHash:Set('PONI090','SRA|CTT' ) //EAI - EmployeeException
oHash:Set('PONI160','SRA' ) //EAI - EmployeeHistoryWorkShift
oHash:Set('PONN010','SRA' ) //EAI - MarkingPoint
oHash:Set('PONY010','SRA' ) //EAI - ReturnWorkedHours
oHash:Set('PONY040','SRA' ) //EAI - ReturnTimeSheet
oHash:Set('WFPROGFERIAS','RH3' ) //GPEWF010 - Programacao de Ferias
oHash:Set('WFALTVAGAS','CTT|RBU|SQS' ) //ORGWF010 - Envio de WF para para integracao entre SIGAORG e SIGARSP
oHash:Set('WFCANCONVAGAS','CTT|RBU|SQS' ) //ORGWF010 - Envio de WF para para integracao entre SIGAORG e SIGARSP

//Rotinas Importa��o/Conversao de Dados
oHash:Set('COMPATMUNI','SRA|RGC' ) //Compatibilizador de Municipios
oHash:Set('GPECONV','SRG|RA2|SRH|RGE|RGB|RHM|SRB|RC8|SRA|CTT|RE0|RG3|SRC|SR8|RD0|RA4|SRF|SQD' ) //Conversor P12
oHash:Set('RHIMP01','SRA|SRC' )
oHash:Set('RHIMP08','SRA' )
oHash:Set('RHIMP09','SRB|SRA' )
oHash:Set('RHIMP10','SRA|SR8' )
oHash:Set('RHIMP11','SRA' )
oHash:Set('RHIMP12','SRA|SRC' )
oHash:Set('RHIMP13','SRA|CTT' )
oHash:Set('RHIMP14','SRG|SRA' )
oHash:Set('RHIMP15','SRH|SRA|SRF' )
oHash:Set('RHIMP16','SRH|SRA|SRF' )
oHash:Set('RHIMP19','SRA' )
oHash:Set('RHIMP20','SRA' )
oHash:Set('RHIMP25','SRQ|SRA' )
oHash:Set('RHIMP26','SRA' )
oHash:Set('RHIMP27','RHL|SRA' )
oHash:Set('RHIMP28','RHL|RHM|SRB|SRA' )
oHash:Set('RHIMPDP','SRG|SR8|SRA' )
oHash:Set('RHIMPGEN','RHL|SRG|SRH|SRQ|RHM|SRB|SRA|SR8' )
oHash:Set('UPDBINRES','SRA' )
oHash:Set('UPDBIRFER','SRA' )
oHash:Set('UPDCODUNIC','C9V|SRA' )
oHash:Set('UPDDEP','C9V|SRB|SRA|C9Y' )
oHash:Set('UPDDPGSR8','SR8' )
oHash:Set('UPDDTFER','SRH|SRA' )
oHash:Set('UPDFASRF','SRA|SRF' )
oHash:Set('UPDPERSRF','SRA|SR8|SRF' )
oHash:Set('UPDSRF','SRA|SRF' )

/* ----- INICIO ROTINAS DO PRODUTO MEURH -------- */

//RHNP01
/*
oHash:Set('GET','SRA|SRJ|CTT|SQ3|SQB|RDZ|RD0|RH3|RH4|RD4|RJ2|SR8|SRF')
oHash:Set('GETEAM','SRA|AI8|SR3|')
oHash:Set('GETBALANCETEAMSUM', 'SPI|SP9')
oHash:Set('FEMPLOYEEBIRTHDATE','SRA' )
oHash:Set('FINDEMPLOYEE', 'SRA|SQB|SQ3')
oHash:Set('TEAMSTRUCTURE', 'SRA|SQ3')
oHash:Set('TYPEDEMISSION', 'RCB|RCC')
*/
oHash:Set('TEAM', 'SRA|SRJ|CTT|SQ3|SQB|RDZ|RD0|RH3|RH4|RD4|RJ2|SR8|SRF|AI8|SR3|SPI|SP9|RCB|RCC')

//RHNP02
/*
oHash:Set('DATAIMAGE','SRA|RD0' )
oHash:Set('DATAPROFILE','SRA|SRJ|SQ3|SQB' )
oHash:Set('CHKTEAMMANAGET', 'SQB')
*/
oHash:Set('DATA','SRA|RD0|SRJ|SQ3|SQB')

//RHNP03
/*
oHash:Set('GETPAYMENT','SRA|SRE|SRC|SRD' )
oHash:Set('GETRESUME','SRA|SRC|SRD|SRV|SRQ' )
oHash:Set('GETANNUALREC','SR4|RHX' )
oHash:Set('GETPAYMREC','SRA|RCH|SRC|SRV|SRD|SRQ|SRY|RCA|' )
oHash:Set('GETPAYAVAILABLE', 'SRA|SRC|RCH')
oHash:Set('GTYPESALARYCHANGES', 'SX5')
oHash:Set('SALARYCHANGES', 'SR7|SR3')
*/
oHash:Set('PAYMENT','SRA|SRE|SRC|SRD|SRV|SRQ|SR4|RHX|RCH|SRY|RCA|SX5|SR7|SR3')

//RHNP04
/*
oHash:Set('GETCOUNT', 'SRA|RJ2|RH3')
oHash:Set('GETREQUESTCOUNT', 'SRA|RJ2|RH3')
oHash:Set('GETNOTIFICATIONS', 'SRA|RJ2|RH3')
oHash:Set('REQUISITIONS', 'SRA|RH3')
*/
oHash:Set('REQUEST','SRA|RJ2|RH3')

//RHNP05
/*
oHash:Set('ISFIRSTLOGIN', 'RD0')
oHash:Set('GETALLCONTEXT', 'RDZ|RD0|SRA|SQB')
oHash:Set('GETCONTEXT', 'RDZ|RD0|SRA|SQB')
oHash:Set('GETPERMISSIONS','SQB|RD0|RJD')
*/
oHash:Set('AUTH','RDZ|RD0|SRA|SQB|RJD')

//RHNP06
/*
oHash:Set('GETALLOWANCES', 'SP6')
oHash:Set('CLOCKINGS', 'RS3|RH3|SP8|SPG|')
oHash:Set('GETPERIODS', 'SPO')
oHash:Set('GETBALANCESUMMARY', 'SPI|SP9')
oHash:Set('GETTOTSUMMPERIOD', 'SPH|SP9|SPC')
oHash:Set('GETOCCURRENCES', 'SPH|SP9|SPC')
oHash:Set('GETCLOCKTYPES', 'RFD')
oHash:Set('GFILECLOCKING', 'SP5|SPN|SP8|SPG|SPB|SPL|SPC|SPH|SPF|SRA|SPJ|SP9')
oHash:Set('GEOLOCATION', 'RS3|RH3')
oHash:Set('TODAYCLOCKINGS', 'RS3')
oHash:Set('DISCONSIDER', 'RFD')
oHash:Set('GETLISTALLOWANCE', 'RH3|RH4|RGK')
*/
oHash:Set('TIMESHEET','SP6|RS3|RH3|RH4|RGK|SP8|SPG|SPO|SPI|SP9|SPH|SPC|SP5|SPN|SPB|SPL|SPF|SRA|RFD')

//RHNP08
/*
oHash:Set('GETINFOVACATION', 'SRF|RH3|RH4|SRH')
oHash:Set('GETHISTORYVACATION', 'SRH|RH3|RH4')
oHash:Set('NEXTDAYSVACATION', 'SRF|SRH')
oHash:Set('NOTICEVACATION', 'SRA|SRH|SRF')
oHash:Set('REPORTVACATION', 'SRH|SRR')
oHash:Set('GETDETAILVACATION', 'SRH|SRR')
*/
oHash:Set('VACATION','SRA|SRF|RH3|RH4|SRH|SRR')

//RHNP09
/*
oHash:Set('FRETREGSMED', 'SRA|RCH|RH3|RH4')
oHash:Set('FINFARQMED', 'RH3')
oHash:Set('FDOWNARQMED','RH3')
oHash:Set('FGTREASONS','RCM')
oHash:Set('FGTCODCID','TMR')
oHash:Set('BYIDMED','SRA|RCH|RH3|RH4')
*/
oHash:Set('HEALTH','SRA|RCH|RH3|RH4|RCM|TMR')

/* ----- FIM ROTINAS DO PRODUTO MEURH -------- */

//WEBSERVICES
oHash:Set('ANONIMIZA','SRA|RH3' ) //WSANONIMIZA
oHash:Set('BENEFICIARIESDATACONTENT','RHL|SRB|SRA' ) //GPEA001API
oHash:Set('BENEFICIARIESCOPARTICIPATION','RHO|RHP|SRB|SRA' ) //GPEA003API
oHash:Set('CANDIDATES','SQG' ) //RSPA010API
oHash:Set('EMPLOYEEDATACONTENT','SRA|CTT' ) //GPEA010API
oHash:Set('ORGSTRUCTURE','SRA|CTT|RBT|RD0|RCX|RH3' ) //WSORG010
oHash:Set('PAYROLLCONTROL','SRA' ) //GPEA011API
oHash:Set('RHABILITIES','SRA|CTT' ) //WSCSA020
oHash:Set('RHABSENCES','SR8' ) //WSGPE060
oHash:Set('RHANNUALRECEIPTS','SRA|SR4' ) //WSGPE080
oHash:Set('RHANOTATIONS','SRA|CTT' ) //WSPON030
oHash:Set('RHAPDCONSOLIDATED','RD6|SRA|CTT|RD0|RCX' ) //WSAPD018
oHash:Set('RHARTIFACT','SRA|RD0' ) //WSTCF010
oHash:Set('RHATTENDCONTROL','SRA|SR8' ) //WSPON040
oHash:Set('RHCURRICULUM','SQG|SQS|SQD' ) //WSRSP010
oHash:Set('RHDEPENDENTS','RHL|SRB|SRA|CTT' ) //WSGPE050
oHash:Set('RHEMPLOYEEREGISTRATION','SRA|CTT' ) //WSGPE070
oHash:Set('RHEMPLOYEETRANSF','SRA|CTT' ) //WSGPE100
oHash:Set('RHEMPLOYEDCURRICULUM','SRA|RD0|RA4' ) //WSAPD014
oHash:Set('RHEVALUATE','RD6|RDC|RD0' ) //WSAPD017
oHash:Set('RHEVALUATIONFACTORS','SRA|CTT' ) //WSCSA010
oHash:Set('RHHOURSBANK','SRA' ) //WSPON010
oHash:Set('RHIDENTIFY','RDV|SRA|CTT|RD0' ) //WSAPD011
oHash:Set('RHKNOWLEDGE','RBP|RBQ|SRA|RD0' ) //WSAPD012
oHash:Set('RHMONITORING','RD6|RDC' ) //WSAPD016
oHash:Set('RHPAYMENTRECEIPTS','SRA|SRC' ) //WSGPE030
oHash:Set('RHPERFORMANCEEVALUATE','RDV|RDA|SA1|RD6|RDC|RD9|SRA|RD0' ) //WSAPD010
oHash:Set('RHPERSONALDESENVPLAN','RDV|SRA|RD0' ) //WSAPD013
oHash:Set('RHPROJECTEVALUATE','RDA|SA1|RD6|RDC|RD0' ) //WSAPD015
oHash:Set('RHSCHEDULECHART','SRA|CTT' ) //WSPON020
oHash:Set('RHREQUEST','RIA|SRA|RI6|SRB|SQG|RBT|RH3|CTT|SR8|RD0' ) //WSGPE020
oHash:Set('RHTRAININGEVALUATION','RA2|SRA|RAI|RA4' ) //WSTRM040
oHash:Set('RHTRAININGS','RA2|RA7|RA4|RH3' ) //WSTRM010
oHash:Set('RHTRAININGTEST','RAJ|SRA|RAI|RA4' ) //WSTRM050
oHash:Set('RHVACATION','SRH|SRA|SR8|RD0|RHI|SRF' ) //WSGPE010
oHash:Set('RHVACATIONNOTICE','SRH|SRA|SRF' ) //WSGPE120
oHash:Set('RHVACATIONRECEIPTS','SRH|SRA' ) //WSGPE040
oHash:Set('RHVDFBALANCEVACATION','RIA|SRA|RI6|RH3' ) //WSVDF020
oHash:Set('RHVDFCERTIFICATE','RH3' ) //WSVDF060
oHash:Set('RHVDFDAILY','RH3' ) //WSVDF040
oHash:Set('RHVDFDAYSOFF','RH3' ) //WSVDF070
oHash:Set('RHVDFJOURNEY','SRA|RH3' ) //WSVDF010
oHash:Set('RHVDFLICENCE','RH3' ) //WSVDF050
oHash:Set('RHVDFVACATION','SRA|RH3' ) //WSVDF030

//RdMakes RH
oHash:Set('ABSENT','SRA' ) //Relatorio Absenteismo
oHash:Set('BENEFARQ','SRA|RGC' ) //Exportacao dos arquivos de beneficios
oHash:Set('CAPFOTO','SRA' ) //Captura de fotos
oHash:Set('CERT','RA2|SRA|RA7|RA4' ) //Certificados dos cursos realizados
oHash:Set('CONVIT','RA2|SRA|CTT' ) //Convites dos cursos realizados
oHash:Set('CSA010','RBE|CTT' ) //Relatorio de Aprovacao de Vagas (Quadro de Funcionario)
oHash:Set('ETIQAS','SRA' ) //Etiqueta de Aumento Salarial
oHash:Set('ETIQCT','SRA' ) //Etiqueta de Contrato de Trabalho
oHash:Set('ETIQFER','SRH|SRA' ) //Etiqueta de Anotacoes de Ferias
oHash:Set('ETIQMD','SRA' ) //Etiqueta para Mala Direta
oHash:Set('ETIQOPC','SRA' ) //Etiquetas da data de Opcao do FGTS
oHash:Set('GERABC','SRA' ) //Gera disquete para Vale transporte no padr�o do conv�nio BLUE CARDS.
oHash:Set('GERATT','SRA' ) //Gera disquete para Vale transporte no padr�o do conv�nio TICKET TRANSPORTE.
oHash:Set('GERAVT','SRA' ) //Gera disquete para Vale transporte no padr�o do conv�nio V.T. - Vale Trasnporte
oHash:Set('GETIMPCOOP','SRA|SRC' ) //Calcula o INSS / IRRF / Pensao Alimenticia para Cooperados
oHash:Set('GPENCEMP','SRG|SRA' ) //Gera encargos empresa analiticamente
oHash:Set('GPER023','SRA' ) //Gera��o arquivo Transpar�ncia - Lei Federal 12.115
oHash:Set('GPERPPP','RC8|SRA|RC9|CTT|SR8' ) //Perfil Profissiografico Previdenciario
oHash:Set('GPEWORD','SRA|RGC|SRB' ) //Impressao de Documentos tipo Word
oHash:Set('GPESCHEDULER','SRA' ) //Agendamento de calculo em workflow
oHash:Set('IMPCAT','SRA|CTT' ) //Relatorio CAT (Comunicacao de Acidente do Trabalho)
oHash:Set('IMPESP','SRA' ) //Espelho do Ponto
oHash:Set('IMPETIQ','SRA' ) //Etiqueta / Cartao de Ponto
oHash:Set('IMPFER','SRH|SRA|SRF' ) //Recibo de Ferias
oHash:Set('IMPGREC','SRG|SRA|CTT|SRC|SI3' ) //Emissao da Guia de Recolhimento Rescisorio do FGTS
oHash:Set('IMPGRFC','SRG|SRA|CTT' ) //Guia de Recolhimento Rescisorio do FGTS e da Contr.Social
oHash:Set('IMPIRPF','SRL' ) //Impressao da DIRF em Formulario Continuo
oHash:Set('IMPIRPJ','SRL|SR4' ) //Impressao do comprovante de rendimentos pessoa juridica
oHash:Set('IMPLIFIN','SRG|SI3|SRA' ) //Impressao da Rescisao em Papel Zebrado
oHash:Set('IMPMODEL','SRA' ) //Imprime modelos de Documentos
oHash:Set('IMPRCAN','SQG|SQS|SQD' ) //Impressao Ficha do Candidato
oHash:Set('IMPRESC','SRG|SRA|SRC' ) //Impressao da Rescisao em Formulario Continuo
oHash:Set('IMPRESG','SRG|SI3|SRA|SRC' ) //Impressao da Rescisao em modo Grafico
oHash:Set('IMPRESH','SRG|SRA|SRC|CTT' ) //Impressao da Rescisao em modo Grafico Homolognet
oHash:Set('IMPRESZ','SRG|SI3|SRA|SRC' ) //Impressao da Rescisao em Papel Zebrado
oHash:Set('IMPRPA','SI3|SA1|SRA' ) //RPA - RECIBO DE PAGAMENTO DE AUTONOMOS
oHash:Set('RAUMSAL','SRA' ) //Imprime Aumentos Salariais de Acordo com os Tipos Definidos
oHash:Set('REAEST','SRA' ) //Termo de Realizacao de Estagio
oHash:Set('REAJTAR','SRA' ) //Aumento Para Tarefas
oHash:Set('RECBRAD','SRA|CTT' ) //Emissao do Recibos de Pagamento Eletronico BCO BRADESCO
oHash:Set('RECIBO','SI3|SRA|SRH|SA1|CTT|SRC|SR8' ) //Emiss�o de Recibos de Pagamento
oHash:Set('RECITAU','SRH|SRA|SRF' ) //Emissao do Recibos de Pagamento Eletronico BCO Ita�
oHash:Set('RECSANTAND','SRA' ) //Emissao do Recibos de Pagamento Eletronico BCO Santander
oHash:Set('REQBENEF','SRA' ) //Requerimento de Beneficio por Incapacidade
oHash:Set('RS150ML','SQG|SQD' ) //Envia e-mail de Agenda para Candidatos.
oHash:Set('RSR001','SQG' ) //Imprime os curriculos conforme parametros selecionados
oHash:Set('RSR003','SQG|SQD' ) //Imprime os teste conforme parametros selecionados
oHash:Set('RSR004','SQG' ) //Relatorio de Avaliacoes Realizadas Pelo Candidato
oHash:Set('SEGDES','SRA|SRC' ) //Requerimento de Seguro-Desemprego - S.D.
oHash:Set('TRM010','RA2|SRA|RA7' ) //Lista de Presenca
oHash:Set('TRM020','RA2|SRA|CTT' ) //Relatorio de Treinamentos (Solicitacao)
oHash:Set('TRM030','RA2|SRA|RA7|RA4' ) //Custo dos Treinamentos
oHash:Set('TRM040','SRA|CTT|RA4' ) //Custo do Treinamento Anual
oHash:Set('TRM060','RA2|SRA|RA4' ) //Treinamentos Solicitados ou Baixados
oHash:Set('TRM080','RA2|SRA|RAI' ) //Relatorio de Avaliacoes Realizadas
oHash:Set('UPAVALIA','RAJ|RAI' ) //Tela atualiza��o de avalia��o - percentual de alternativa
oHash:Set('UPCATCURSO','RA4' ) //Tela atualiza��o de avalia��o - categoria de cursos baixados

//Rotinas m�dulo TAF
//Aten��o! Ordenar os fontes em ordem alfab�tica para n�o ocorrer duplicidade de informa��es.
oHash:Set('FLAYT002', 'CVB' ) //TAF Fiscal \ Extrator Fiscal \ Layout de integra��o T002 - Contabilistas
oHash:Set('FLAYT003', 'SA1|SA2|SA4|DHT' ) //TAF Fiscal \ Extrator Fiscal \ Layout de integra��o T003 - Participantes
oHash:Set('TAFA102', 'C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Federais \ GNRE Online
oHash:Set('TAFA117', 'C2J|C6I|C5R|C2B|C40|C1H|C20|C26|C37|C24|C38|C2V|C3M|LEQ|T86|C4U|C5B|T19|LEY|C4H|C32|C2K|C5K' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ EFD ICMS IPI
oHash:Set('TAFA118', 'C2J|C1H|C40|C5R|C85|C6I|C4P|C2B|C2V|C5G|C26|C20|C3B|C32|C59' ) //TAF Fiscal \ Central de Obrigacoes \ Federais \ EFD Contribuicoes
oHash:Set('TAFA119', 'C0R|C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ RS \ GIA
oHash:Set('TAFNFESF', 'C1H' ) //TAF Fiscal \ TAFNfesf
oHash:Set('TAFXDAPI', 'C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais  \ MG \ DAPI
oHash:Set('TAFXDBH', 'C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Municipais \ DES-BH
oHash:Set('TAFXDERJ', 'C2J' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais  \ RJ \ DECLAN-IPM
oHash:Set('TAFXDES', 'C1H|C2J' ) //TAF Fiscal \ Central de Obrigacoes \ Municipais \ DES-Contagem
oHash:Set('TAFXDFCE', 'C1H|C2J' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais  \ CE \ DIEF
oHash:Set('TAFXDFPR', 'C2J' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ PR \ DFC-GI
oHash:Set('TAFXDMA', 'C2J|C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ BA \ DMA
oHash:Set('TAFXDPMP', 'C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Federais \ DPMP
oHash:Set('TAFXECF', 'C2J|V1R|V3T|V1S|CAZ|CFX|CGM|CEM|CGO' ) //TAF Fiscal \ Central de Obrigacoes \ Federais \ ECF
oHash:Set('TAFXGIRJ', 'C2J|C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ RJ \ GIA
oHash:Set('TAFXGISS', 'C1H' ) //TAF Fiscal \ Central de Obrigacoes \ Municipais \ GISS Online
oHash:Set('TAFXGSP', 'C1H|C20' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ SP \ NOVA GIA
oHash:Set('TAFXGST', 'C1H|C2J' ) //TAF Fiscal \ Central de Obrigacoes \ Estaduais \ GIA ST


//Rotinas m�dulo SIGATSS
oHash:Set('SPEDNFE','SA1|SA2|SD7|SE1|SE2|CD5|CD6' ) //campos:A2_CGC utilizacao: composi��o do ID do arquivo TXT gerado no TSS
oHash:Set('FISA022','SA1|SA2|SA4|SE1|SE2|' ) //campos:A2_CGC utilizacao: composi��o do ID do arquivo TXT gerado no TSS
oHash:Set('SPEDMDFE','SA1|SA2|DA4|SA4' ) //campos:A2_CGC utilizacao: composi��o do ID do arquivo TXT gerado no TSS
oHash:Set('SPEDMANIFE','SA1|SA2' ) //campos:A2_CGC utilizacao: composi��o do ID do arquivo TXT gerado no TSS

//Rotinas no SIGATAF eSocial
oHash:Set('TAFPNFUNC'   ,'C9V' )                                                                //Painel do Trabalhador
oHash:Set('TAFA050'     ,'C1E|C1F|CR9|CRM|CUW|CZR' )                                            // S-1000
oHash:Set('TAFA253'     ,'C92|T0Z' )                                                            // S-1005
oHash:Set('TAFA246'     ,'C99|T03' )                                                            // S-1020
oHash:Set('TAFA467'     ,'T5K' )                                                                // S-1035
oHash:Set('TAFA236'     ,'C8X' )                                                                // S-1040
oHash:Set('TAFA238'     ,'C90|CRL' )                                                            // S-1050
oHash:Set('TAFA389'     ,'T04' )                                                                // S-1060
oHash:Set('TAFA051'     ,'C1G|T5L' )                                                            // S-1070
oHash:Set('TAFA248'     ,'C8W' )                                                                // S-1080
oHash:Set('TAFA250'     ,'C91|C9K|C9L|C9M|C9N|C9O|C9P|C9Q|C9R|CRN|T14|T6W|T6Y|T6Z|V1B|V1C' )    // S-1200
oHash:Set('TAFA413'     ,'C91|CRN|T14|T61|T6C|T6D|T6E|T6F|T6G|T6H|T6I|T6J|T6K' )                // S-1202
oHash:Set('TAFA470'     ,'T60|T62|T63' )                                                        // S-1207
oHash:Set('TAFA407'     ,'LE2|LE3|LE4|T3P|T3Q|T3R|T5U|T5V|T5X|T5Y|T5Z|T6P|T6Q|T6R' )            // S-1210
oHash:Set('TAFA272'     ,'CMR|CMT|CMU|T1Z|V2O' )                                                // S-1250
oHash:Set('TAFA414'     ,'T1M|T1N|T1O|T1P|T6B' )                                                // S-1260
oHash:Set('TAFA408'     ,'T1Y|T2A' )                                                            // S-1270
oHash:Set('TAFA410'     ,'T3V|T3X' )                                                            // S-1280
oHash:Set('TAFA477'     ,'T72' )                                                                // S-1295
oHash:Set('TAFA416'     ,'T1S' )                                                                // S-1298
oHash:Set('TAFA303'     ,'CUO' )                                                                // S-1299
oHash:Set('TAFA412'     ,'T2L|T3Z' )                                                            // S-1300
oHash:Set('TAFA403'     ,'T3A' )                                                                // S-2190
oHash:Set('TAFA421'     ,'C9V|C9Y|CRQ|CRQ|CUP|T3L|T80|T90|T3T|T1U|T1V|T3U|T79|T91|CUU|T2F|T0F' )// S-2200
oHash:Set('TAFA278'     ,'C9V|C9Y|CRQ|CRQ|CUP|T3L|T80|T90' )                                    // S-2200
oHash:Set('TAFA257'     ,'CM0|CM1|CM2' )                                                        // S-2210
oHash:Set('TAFA258'     ,'C8B|C9W|CRP' )                                                        // S-2220
oHash:Set('TAFA528'     ,'V3B' )                                                                // S-2221
oHash:Set('TAFA261'     ,'CM6|T6M' )                                                            // S-2230
oHash:Set('TAFA264'     ,'CM9|CMA|CMB|LEA|LEB|T0Q|T3S|V3E' )                                    // S-2240
oHash:Set('TAFA404'     ,'T3B|T3C|T3D|T3N|T3O' )                                                // S-2241
oHash:Set('TAFA529'     ,'V3C|V3G' )                                                            // S-2245
oHash:Set('TAFA263'     ,'CM8' )                                                                // S-2250
oHash:Set('TAFA484'     ,'T87' )                                                                // S-2260
oHash:Set('TAFA267'     ,'CMF' )                                                                // S-2298
oHash:Set('TAFA266'     ,'C9J|CMD|T05|T06|T15|T16|T3G|T3H|T5I|T5J|T5Q|T5S|T88|V1M|V1N' )        // S-2299
oHash:Set('TAFA280'     ,'C9J|CMK|T15|T16|T3H|T3I|T3J|T92' )                                    // S-2399
oHash:Set('TAFA469'     ,'T5T' )                                                                // S-2400
oHash:Set('TAFA269'     ,'CMJ' )                                                                // S-3000
oHash:Set('TAFA423'     ,'T2M|T2N|T2O|T2P|T2Q|T2R|T2S' )                                        // S-5001
oHash:Set('TAFA422'     ,'T2G|T2H|T2I|T2J' )                                                    // S-5002
oHash:Set('TAFA520'     ,'V2P|V2Q|V2R|V2S|V2T|V2U|V2V|V2W|V2X|V2Y' )                            // S-5003
oHash:Set('TAFA425'     ,'T0A|T0B|T0C|T0D|T0E|T2V|T2X|T2Y|T2Z|T70' )                            // S-5011
oHash:Set('TAFA521'     ,'V20|V21|V22|V23|V24|V25|V2Z' )                                        // S-5013
oHash:Set('TAFA549'     ,'C91')                                                                 // S-1200
oHash:Set('TAFA550'     ,'T3P')                                                                 // S-1210
oHash:Set('XNEWHISALT' ,'CM8' )
oHash:Set('XFUNHISALT' ,'CM8' )
oHash:Set('TAFXMLLOTE' ,'CM8' )  
oHash:Set('TAF250XML'  ,'C91|C9K|C9L|C9M|C9N|C9O|C9P|C9Q|C9R|CRN|T14|T6W|T6Y|T6Z|V1B|V1C' )
oHash:Set('TAF261XML'  ,'CM6|T6M' )
oHash:Set('TAF263XML'  ,'CM8' ) 
oHash:Set('TAF266XML'  ,'C9J|CMD|T05|T06|T15|T16|T3G|T3H|T5I|T5J|T5Q|T5S|T88|V1M|V1N' ) 
oHash:Set('TAF267XML'  ,'CMF' )
oHash:Set('TAF280XML'  ,'C9J|CMK|T15|T16|T3H|T3I|T3J|T92' )
oHash:Set('TAF407XML'  ,'LE2|LE3|LE4|T3P|T3Q|T3R|T5U|T5V|T5X|T5Y|T5Z|T6P|T6Q|T6R' )
oHash:Set('TAF253XML'  ,'C92|T0Z' )
oHash:Set('TAF246XML'  ,'C99|T03' )
oHash:Set('TAF413XML'  ,'C91|CRN|T14|T61|T6C|T6D|T6E|T6F|T6G|T6H|T6I|T6J|T6K' )
oHash:Set('TAF470XML'  ,'T60|T62|T63' )
oHash:Set('TAF272XML'  ,'CMR|CMT|CMU|T1Z|V2O' )
oHash:Set('TAF414XML'  ,'T1M|T1N|T1O|T1P|T6B' )
oHash:Set('TAF477XML'  ,'T72' )
oHash:Set('TAF403XML'  ,'T3A' )
oHash:Set('TAF257XML'  ,'CM0|CM1|CM2' )
oHash:Set('TAF258XML'  ,'C8B|C9W|CRP' )
oHash:Set('TAF528XML'  ,'V3B' )
oHash:Set('TAF264XML'  ,'CM9|CMA|CMB|LEA|LEB|T0Q|T3S|V3E' )
oHash:Set('TAF404XML'  ,'T3B|T3C|T3D|T3N|T3O' )
oHash:Set('TAF529XML'  ,'V3C|V3G' )
oHash:Set('TAF484XML'  ,'T87' )
oHash:Set('TAF469XML'  ,'T5T' )
oHash:Set('TAF269XML'  ,'CMJ' )
oHash:Set('TAF423XML'  ,'T2M|T2N|T2O|T2P|T2Q|T2R|T2S' )
oHash:Set('TAF422XML'  ,'T2G|T2H|T2I|T2J' )
oHash:Set('TAF520XML'  ,'V2P|V2Q|V2R|V2S|V2T|V2U|V2V|V2W|V2X|V2Y' )
oHash:Set('TAF421XMLVLD','C9V|C9Y|CRQ|CRQ|CUP|T3L|T80|T90|T3T|T1U|T1V|T3U|T79|T91|CUU|T2F|T0F' )
oHash:Set('TAF050XML'  ,'C1E|C1F|CR9|CRM|CUW|CZR' )
oHash:Set('TAF303XML'  ,'CUO' )  
oHash:Set('TAF389XML'  ,'T04' )
oHash:Set('TAF408XML'  ,'T1Y|T2A' )
oHash:Set('TAF425XML'  ,'T0A|T0B|T0C|T0D|T0E|T2V|T2X|T2Y|T2Z|T70' )  

//Rotinas Modulo GTP
oHash:Set('GTPA116' ,'G9Z' ) //Passe Livre
oHash:Set('GTPA008' ,'GYG' ) //Colaboradores
oHash:Set('GTPA600' ,'G6R' ) //Or�amento de Viagens
oHash:Set('GTPA303' ,'GYQ' ) //Aloca��o de Colaboradores
oHash:Set('GTPA106' ,'GQH' ) //Aloca��o de Documentos                                                               
oHash:Set('GTPA425' ,'GQE' ) //Apura��o Escala de Colaboradores                 
oHash:Set('GTPA115' ,'GYQ' ) //Bilhetes                                                             
oHash:Set('GTPA801' ,'G99' ) //Entrada de Documentos                            
oHash:Set('GTPA287' ,'GQV' ) //Par�metros do cliente                            
oHash:Set('GTPA283' ,'GQW' ) //Requisi��es                                      
oHash:Set('GTPA802' ,'GZN' ) //Tabela de Frete                                  
oHash:Set('GTPA110' ,'GQP' ) //Vale de Funcion�rios                             
oHash:Set('GTPA113' ,'G96' ) //Vale de Funcion�rios - Autoriza��o de Desconto   
oHash:Set('GTPA111' ,'GQQ' ) //Vale de Funcion�rios - Presta��o de Contas       
oHash:Set('GTPA112' ,'GYQ' ) //Vale de Funcion�rios - prorroga��o de  vales
oHash:Set('GTPA901' ,'GQB' ) //Lista de passageiros - Itens

//Rotinas Modulo SIGAJURI
oHash:Set('JURA095','NT9' ) // Processo
oHash:Set('JURA184','NZ2' ) // Parte contr�ria

//Rotinas Modulo SIGAPFS
oHash:Set('CTBA030','CTT') // Cadastro de Centro de Custo
oHash:Set('FINA010','SED') // Cadastro de Naturezas
oHash:Set('FINA040','SE1') // Contas a Receber
oHash:Set('FINA050','SE2') // Contas a Pagar
oHash:Set('FINA740','SE1') // Fun��es Contas a Receber
oHash:Set('FINA750','SE2') // Fun��es Contas a Pagar
oHash:Set('JURA027','NV4|NW4') // Lan�amento Tabelado
oHash:Set('JURA033','NVV|NXG') // Cadastro de Fatura Adicional
oHash:Set('JURA035','NR8') // Conf. Usu�rio Envio de Email
oHash:Set('JURA049','NVY|NVZ') // Despesas
oHash:Set('JURA056','NW2|NXP') // Cadastro de Jun��o de Contratos
oHash:Set('JURA064','NRU') // Conf. Envio de Email
oHash:Set('JURA068','NS7') // Cadastro de Escrit�rios
oHash:Set('JURA069','NWF') // Controle de Adiantamentos
oHash:Set('JURA070','NVE|NWL') // Cadastro de Casos
oHash:Set('JURA074','NXH|NXJ') // Cadastro de Protocolos
oHash:Set('JURA074B','NXA') // Gera��o autom�tica de Protocolos
oHash:Set('JURA082','NSM') // Cadastro de Dep�sitos
oHash:Set('JURA096','NT0|NT5|NXP') // Cadastro de Contratos
oHash:Set('JURA104','NVE') // Posi��o de Faturamento por Caso
oHash:Set('JURA109','NWM') // Lan�amentos Tabelados Recorrentes
oHash:Set('JURA141','NXA') // WO de Faturas
oHash:Set('JURA142','NV4') // WO de Lan�amento Tabelado
oHash:Set('JURA143','NVY') // WO de Despesas
oHash:Set('JURA144','NUE|NW0') // WO de Despesas
oHash:Set('JURA148','AC8|SA1|NUH') // Cadastro de Clientes
oHash:Set('JURA159','FIL|RD0|NUR') // Cadastro de Participantes
oHash:Set('JURA161','NVE') // Consulta de Dados de Faturamento do Caso
oHash:Set('JURA174','NYT|NYV') // Tarifador
oHash:Set('JURA176','NYX') // Arquivos importados - Tarifador
oHash:Set('JURA202','NV4|NVV|NVY|NX4|NXG') // Opera��es de Pr�-fatura
oHash:Set('JURA202C','NVY') // Associa��o de Despesas na Pr�-fatura
oHash:Set('JURA202D','NV4') // Associa��o de Lan�amento Tabelado na Pr�-fatura
oHash:Set('JURA202E','NX4') // Modelo simplificado da Pr�-fatura
oHash:Set('JURA203','NXG') // Emiss�o de Faturas
oHash:Set('JURA203D','NVV') // Inclus�o de Fatura Adicional na Fila de Impress�o
oHash:Set('JURA204','NV4|NVV|NVY|NX4|NXA') // Opera��es de Fatura
oHash:Set('JURA232','AGA|AGB') // Contatos (Legal Desk)
oHash:Set('JURA235','NZQ') // Solicita��o de Despesas
oHash:Set('JURA235A','NZQ') // Aprova��o de Despesas
oHash:Set('JURA241','OHB') // Lan�amentos entre Naturezas
oHash:Set('JURA242','OHC') // Eventos Financeiros
oHash:Set('JURA245','CTT') // Cadastro de Respons�veis x C. Custo
oHash:Set('JURA246','OHF') // Itens de Desdobramentos
oHash:Set('JURA247','OHF|OHG') // Itens de Desdobramentos P�s Pagamento
oHash:Set('JURA255','OHH') // Posi��o Hist�rica do Contas a Receber
oHash:Set('JURA266','OHP') // Classifica��o de Naturezas
oHash:Set('MATA070','SA6') // Cadastro de Bancos
oHash:Set('TMKA070','SU5') // Cadastro de Contatos
oHash:Set('JURA069A','NXA|SE1') // T�tulos do Adiantamento
oHash:Set('JURA109A','NV4') // Lan�amentos Tabelados em Lote
oHash:Set('JURA145' ,'NUE|NW0') // WO Time Sheet
oHash:Set('JURA176A','NUE|NW0') // Aprova��o de lan�amentos do tarifador
oHash:Set('JURA202B','NUE') // Associa��o de Time Sheet na Pr�-fatura
oHash:Set('JURA202F','RD0') // Altera��o do Revisor da pr�-fatura
oHash:Set('JURA203B','NX0') // Selecionar Pr�-fatura para a fila de gera��o de Fatura
oHash:Set('JURA203C','NT0|NT1') // Selecionar Fixo para a fila de gera��o de Fatura
oHash:Set('JURA203E','NUI') // Selecionar parcelas de �xito para incluir na fila de gera��o de Fatura
oHash:Set('JURA204B','NXA|NUE') // Associa��o de Time Sheet na Fatura
oHash:Set('J204PDF', 'SE1|NXA|NXM') // Documentos Relacionados
oHash:Set('JURA205' ,'NXA') // Documentos Fiscais
oHash:Set('JURA206' ,'NXA') // Opera��o de Documentos Fiscais
oHash:Set('JURA235B','NZQ') // Aprova��o de Despesas em Lote
oHash:Set('JURA235C','NZQ') // Altera��o em lote de solicita��o de despesas
oHash:Set('JURA243' ,'NXA|SU5|SE1') // Cobran�as
oHash:Set('JURA263' ,'NXA|SE1|NUH') // Cobran�a em Lote
oHash:Set('JURA284' ,'OHW|OHB') // Fechamento de Conta Corrente do Participante
// Relat�rios M�dulo SIGAPFS
oHash:Set('JURAPAD018', 'NVY|RD0|NUS') // Relatorio  de Detalhes de Despesas
oHash:Set('JURAPAD024', 'NXA') // Relatorio de Faturas Canceladas
oHash:Set('JURAPAD025', 'NXA') // Relatorio de Faturas Emitidas
oHash:Set('JURAPAD026', 'OHO|OH1|OHP|NT0|SA1') // Relat�rio de Previs�o de Faturamento Anal�tico
oHash:Set('JURAPAD031', 'NUF|RD0') // Relatorio de WO
oHash:Set('JURAPAD032', 'NS7|OHB|SED') // Relat�rio de Resultado Financeiro
oHash:Set('JURAPAD033', 'SED|OHB') // Relat�rio de Resultado Financeiro por Moeda
oHash:Set('JURAPAD034', 'NS7|OHB|SED') // Relat�rio de Extrato por Natureza/Centro de Custo
oHash:Set('JURAPAD035', 'FIV|SED|SE1|SE2|FK1|FK5|FK7|OHB') // Relat�rio de Cash-Flow
oHash:Set('JURAPAD036', 'NXA|SE1') // Relat�rio de Aviso de Cobran�a
oHash:Set('JURAPAD037', 'NS7|RD0|SA1|OHH|NUH') // Relat�rio de Aging por S�cio
oHash:Set('JURAPAD038', 'RD0|SA1|OHH|OHD|NXA') // Relat�rio de Faturas Pendentes
oHash:Set('JURAPAD039', 'NS7|OHI|SA1|SE1|NXA') // Relat�rio de Faturas Pagas
oHash:Set('JURR069', 'NS7|SA1|NWF|CC2|SYA') // Recibo do Adiantamento
oHash:Set('JURR074A', 'NXH|NXI') // Relat�rio de Protocolos
oHash:Set('JURR074B', 'NXH|NXI|NXJ') // Relat�rio de Listagem de Protocolos
oHash:Set('JURR201A', 'NVE|NRN|NUE|NUU|NRF|RD0|NUS|NW0') // Relat�rio de Participantes sem valor na tabela de honor�rios
oHash:Set('JA201END', 'NX0') // Relat�rios de Emiss�o da Pr�-Fatura
oHash:Set('J202REFPRE', 'NX0') // Relat�rios de Refazer da Pr�-Fatura
oHash:Set('JA203EMI', 'NXA') // Relat�rios de Emiss�o da Fatura
oHash:Set('JA204REIMP', 'NXA') // Relat�rios Refazer da Fatura

//Rotinas m�dulo SIGACOM
oHash:Set('COMA001','CPW|CPX|SA2') 		// Cadastro de Grupo de Fornecedores
oHash:Set('COMA010','AIA') 		        // Tabela de Pre�o
oHash:Set('COMR043','SA5')				// Relatorio Lista fornecedores de item ou familia de itens
oHash:Set('COMR100','SA1|SA2')			// Relatorio dos documentos de cobertura
oHash:Set('COMXCOL','SA1|SA2|SDS|SDT')	// TOTVS Colabora��o
oHash:Set('CTBANFE','SA2')			    // Contabiliza��o Off-Line
oHash:Set('MATA020','SA2') 				// Cadastro de Fornecedores
oHash:Set('MATA061','SA2')				// Cadastro amarra��o Produto x Fornecedor
oHash:Set('MATA065','SA2')				// Cadastro amarra��o Gr.Produto x Fornecedor
oHash:Set('MATA094','CNC|SA2')			// Libera��o de Documentos
oHash:Set('MATA103','SA2|SE2|SF1')		// Documento de Entrada
oHash:Set('MATA116','SA2')				// Conhecimento de Transporte
oHash:Set('MATA119','SA2')				// Despesas de Importa��o
oHash:Set('MATA120','SA2')				// Pedido de Compras
oHash:Set('MATA125','SA2')				// Contrato de Parceria
oHash:Set('MATA128','SA2|SDU')			// Matriz de Abastecimento
oHash:Set('MATA131','SA2|SAD|SC8')		// Gera Cota��o
oHash:Set('MATA140','SA2|SF1')			// Pre Nota de Entrada
oHash:Set('MATA145','SA2')				// Cadastro de Aviso de Recebimento
oHash:Set('MATA150','SA2|SC8')			// Atualiza Cota��o
oHash:Set('MATA160','SA2|SC8')			// Analise de Cota��o
oHash:Set('MATA161','SA2|SC8')			// Analise de Cota��o (nova)
oHash:Set('MATA178','SA2')				// Aglutina��o de Pedidos
oHash:Set('MATR030','SA2') 				// Relat�rio de Cadastro de Fornecedores
oHash:Set('MATR040','SA1|SA2')			// Ficha Cadastral fornecedores
oHash:Set('MATR080','SA2')				// Relatorio de Notas Fiscais
oHash:Set('MATR090','SA2')				// Relatorio dos Tipo de Entrada e Sa�da
oHash:Set('MATR100','SA2')				// Relatorio de Solicitacoes de Compra
oHash:Set('MATR110','SA2')				// Relatorio de Pedidos de Compra
oHash:Set('MATR110A','SA2')				// Relatorio de Pedidos de Compra Layout A
oHash:Set('MATR110B','SA2')				// Relatorio de Pedidos de Compra Layout B
oHash:Set('MATR120','SA2')				// Relatorio de Pedido de Compras
oHash:Set('MATR125','SA2')				// Relatorio de Contrato de Parceria
oHash:Set('MATR126','SA2')				// Relatorio de Mapa de rastreamento do contrato de Parceria
oHash:Set('MATR130','SA2')				// Relatorio de Divergencias de Pedido de Compras
oHash:Set('MATR140','SA2')				// Relatorio de Emissao das Solicitacoes de Compra
oHash:Set('MATR150','SA2|SC8')			// Relatorio de Emissao das Cotacoes
oHash:Set('MATR170','SA2')				// Relatorio de Emissao do Boletim de Entrada
oHash:Set('MATR180','SA2')				// Relatorio de Devolu��es
oHash:Set('MATR190','SA2')				// Relat�rio de Amarra��o Produto x Fornecedor
oHash:Set('MATR195','SA2')				// Relat�rio de Amarra��o Gr.Produto x Fornecedor
oHash:Set('MATR200','SA2')				// Relatorio de Divergencias entre SC e Pedidos de Compra
oHash:Set('MATR210','SA2')				// Relatorio de Analise de Cota��es
oHash:Set('MATR441','SA2')				// Relatorio de itens que gerarao Autorizacao de Entrega
oHash:Set('MATR952','SA2')				// Relatorio de Contratos de Parceria

//Rotinas m�dulo SIGAGCT
oHash:Set('CNTA090','CN8|CNC|SA2')		// Cadastro de Cau��o
oHash:Set('CNTA121','CNC|SA2')		    // Medi��o de Contrato
oHash:Set('CNTA220','CNM|SA2')			// Avalia��o Contrato X Fornecedor
oHash:Set('CNTA300','CN8|CNC|CXI|SA2')	// Manuten��o de Contratos
oHash:Set('CNTA301','CNC|CN8')			// Contratos de Venda
oHash:Set('CNTR010','SA2')				// Relatorio de Contratos convertidos
oHash:Set('CNTR030','SA2')				// Relat�rio de detalhamento das medi��es
oHash:Set('CNTR031','SA2')				// Relat�rio de detalhamento das medi��es (CNTA121)
oHash:Set('CNTR040','SA2')				// Relat�rio de boletim de medi��o
oHash:Set('CNTR121','SA2') 				// Relatorio de medi��es n�o efetuadas

//Rotinas m�dulo SIGAGCP
oHash:Set('GCPA003','CO6')				        // Cadastro de Participantes
oHash:Set('GCPA008','CO6|SA1|SA2')				// Saldo dos itens
oHash:Set('GCPA009','CO6|SA1|SA2')				// Gera dados de vencedores do edital
oHash:Set('GCPA100','CO6|COP|SA2')				// Cadastro de Analise de Mercado
oHash:Set('GCPA103','COP')						// Manuten��o de Analise de Mercado
oHash:Set('GCPA130','COR')						// Habilita��o de fornecedores - Fornecedores X Edital
oHash:Set('GCPA180','CO6|SA2')					// Consulta SICAF x Inclusao de Fornecedor
oHash:Set('GCPA200','CO3|CO6|COP|CPZ|SA1|SA2')	// Cadastro de processo licitat�rio
oHash:Set('GCPA210','CO6|SA2')					// Integra�ao com o portal ComprasNet
oHash:Set('GCPA300','CPZ')						// Manuten��o da Ata
oHash:Set('GCPA310','CPZ')						// Reajuste de Pre�os
oHash:Set('GCPA311','CO3')						// Reajuste de Pre�os por Lote
oHash:Set('GCPA321','CO3')						// Controle de Saldos
oHash:Set('GCPR002','CO6|SA2')					// Relatorio de Quadro de Licita��es
oHash:Set('GCPR004','CO3')						// Relatorio do Termo de Homologacao
oHash:Set('GCPR007','CO6|SA2')					// Relatorio de rela��o de licita��o por modalidade

//Rotinas m�dulo GS
//Aten��o! Ordenar os fontes em ordem alfab�tica para n�o ocorrer duplicidade de informa��es.
oHash:Set('TECA020','AA1' )            //Materiais \ Cadastro de T�cnicos
oHash:Set('TECA202','TGS')              // �rea de Supervis�o
oHash:Set('TECA770','TFN')              // Cadastro de Local Interno
oHash:Set('TECA011A','AA1')             // Atendente x Caracter�stica
oHash:Set('TECA380','ABU')              // Atendente x Regi�o
oHash:Set('TECA090','AA2')              // Habilidades de Atendente
oHash:Set('TECA012','AA1')              // Cadastro de Restri��es
oHash:Set('TECA201B','AAY')             // Equipe x Atendente
oHash:Set('TECA201C','AA1')             // Atendente x Equipe
oHash:Set('TECA300','AB1')              // Chamados T�cnicos
oHash:Set('TECA450','AB6')              // Ordem de Servi�o
oHash:Set('TECA470','ABF')              // Requisi��o da OS
oHash:Set('TECA160','ABS')              // Cadastro de Local de Atendimento
oHash:Set('TECA740','TFL')              // Or�amento de Servi�os
oHash:Set('TECA660','TW9')              // Processo de Indeniza��o
oHash:Set('TECA803','TGQ')              // Requisi��o a Atendentes
oHash:Set('TECA510','AA1')              // Controle do Aloca��es
oHash:Set('TECA580B','TGY')             // Gest�o de Escalas
oHash:Set('TECA580E','TGZ')             // Gest�o de Escalas
oHash:Set('TECA550','ABR')              // Gest�o de Escalas
oHash:Set('TECA760','ABB')              // Confirma��o de Chegada
oHash:Set('TECA894','TXC')              // Gest�o de Uniformes
oHash:Set('TECA581','TW0')              // Rota de Cobertura
oHash:Set('TECA581','TW1')              // Rota de Cobertura
oHash:Set('TECA780','TEU')              // Manuten��o de Armamento
oHash:Set('TECA880','TFQ')              // Movimenta��o de Armamento
oHash:Set('TECA880','TFR')              // Movimenta��o de Armamento
oHash:Set('TECA750','TE4|TE5|TE7')      // Ocorr�ncias Operacionais

// Rotinas M�dulo Fiscal
oHash:Set('AUDITFIS',"CD6|SA1|SA2|SA4")
oHash:Set('CAT153',"SA1|SA2|SA4")
oHash:Set('CAT156',"SA1")
oHash:Set('CAT207',"SA1|SA2")
oHash:Set('CAT85',"SA1|SA2")
oHash:Set('CAT95',"SA1|SA2|SA4")
oHash:Set('COTEPE35',"SA1")
oHash:Set('DAC',"SA1|SA2")
oHash:Set('DCIMENSAL',"SA1|SA2")
oHash:Set('DDSRN',"SA1|SA2")
oHash:Set('DE',"SA1|SA2")
oHash:Set('DEISS',"SA1|SA2")
oHash:Set('DESAG',"SA1|SA2")
oHash:Set('DESCAN',"SA1|SA2")
oHash:Set('DESSM',"SA1|SA2")
oHash:Set('DFCGI',"SA1|SA2")
oHash:Set('DIEFCE',"SA1|SA2")
oHash:Set('DIEFES',"SA1|SA2")
oHash:Set('DIEFPA',"SA1|SA2")
oHash:Set('DIEFRJ',"SA1|SA2")
oHash:Set('DIEFSC',"SA1|SA2")
oHash:Set('DIFTO',"SA1|SA2")
oHash:Set('DIMESC',"SA1|SA2")
oHash:Set('DMESA',"SA1|SA2")
oHash:Set('DMSCX',"SA1|SA2")
oHash:Set('DNF2004',"SA1|SA2")
oHash:Set('EDICE',"SA1|SA4")
oHash:Set('EDIMS',"SA1")
oHash:Set('EDIPE',"SA1")
oHash:Set('EDIPI',"SA1")
oHash:Set('EDISC',"SA1")
oHash:Set('FISA001',"SA1|SA2")
oHash:Set('FISA002',"SA2")
oHash:Set('FISA007',"SA1|SA2")
oHash:Set('FISA008',"CVB|SA1|SA2")
oHash:Set('FISA010',"SA1|SA4")
oHash:Set('FISA055',"SA2")
oHash:Set('FISA063',"SA1|SA2")
oHash:Set('FISA073',"SA1|SA2")
oHash:Set('FISA103',"SA1|SA2")
oHash:Set('FISA108',"SA1|SA2")
oHash:Set('FISA153',"SA1")
oHash:Set('FISA153A',"SA1")
oHash:Set('FISA164',"SA1|SA2")
oHash:Set('FISA171',"SA1|SA2")
oHash:Set('FISA194',"SA1|SA2")
oHash:Set('FISA205',"SA1|SA2")
oHash:Set('FISA230A',"SA1|SA2")
oHash:Set('FISA231',"SA1|SA2")
oHash:Set('FISA234',"CVB|SA2")
oHash:Set('FISA300',"SA1")
oHash:Set('FISR002',"CVB|SA1|SA2")
oHash:Set('FISR003',"SA1|SA2")
oHash:Set('FISR004',"SA2")
oHash:Set('FISR017',"SA1|SA2")
oHash:Set('FISR021',"SA1|SA2")
oHash:Set('FISR022',"SA2")
oHash:Set('FISR026',"SA1")
oHash:Set('FISR031',"SA2")
oHash:Set('FISR045',"SA1")
oHash:Set('FISR050',"SA2")
oHash:Set('FISR060',"SA1")
oHash:Set('FISR070',"SA2")
oHash:Set('FISR080',"SA1")
oHash:Set('FISR154',"SA1|SA4")
oHash:Set('FISR160',"SA1|SA2")
oHash:Set('FISRIE',"SA1|SA2")
oHash:Set('FISX001',"SA2")
oHash:Set('FISXAPUR',"SA1|SA2|SF6")
oHash:Set('FISXAPURA',"SA1|SA2")
oHash:Set('FISXFUN',"CVB|SA1|SA2")
oHash:Set('GIAMTO',"SA1|SA2")
oHash:Set('GIARJ',"SA1|SA2")
oHash:Set('GIASTBR',"SA1|SA2")
oHash:Set('GNREON',"SA1|SA2|SF6")
oHash:Set('GNRESP',"SA1")
oHash:Set('GNREXMLENV',"SA1|SA2|SF6")
oHash:Set('IMPXFIS',"SA1")
oHash:Set('INDEAMT',"SA1|SA2")
oHash:Set('ISISS',"SA1|SA2")
oHash:Set('ISSCAC',"SA1|SA2")
oHash:Set('ISSJABO',"SA1|SA2")
oHash:Set('ISSJAC',"SA1|SA2")
oHash:Set('ISSSJ2',"SA1|SA2")
oHash:Set('ISSVG',"SA1|SA2")
oHash:Set('MATA089',"SA1|SA2")
oHash:Set('MATA905',"SA2")
oHash:Set('MATA906',"SA2")
oHash:Set('MATA909',"SA1|SA2")
oHash:Set('MATA910',"SA1|SA2")
oHash:Set('MATA916',"SA1|SA2")
oHash:Set('MATA920',"SA1|SA2")
oHash:Set('MATA926',"CD6")
oHash:Set('MATA936',"SA1|SA2")
oHash:Set('MATA940',"SA1|SA2|SA4")
oHash:Set('MATA940A',"SA1|SA2")
oHash:Set('MATA940B',"SA1|SA2")
oHash:Set('MATA941',"SA1|SA2")
oHash:Set('MATA945',"SA1|SA2")
oHash:Set('MATA950',"SA1|SA2")
oHash:Set('MATA954',"SA1|SA2")
oHash:Set('MATA960','SF6')
oHash:Set('MATA967','CCF')
oHash:Set('MATA968',"SA1|SA2")
oHash:Set('MATA977',"SA1|SA2")
oHash:Set('MATA978',"CCF|SA2")
oHash:Set('MATA981',"SA1|SA2")
oHash:Set('MATA982',"SA2")
oHash:Set('MATA983',"SA2")
oHash:Set('MATR907',"SA1|SA2")
oHash:Set('MATR909',"CVB")
oHash:Set('MATR912',"SA1|SA2")
oHash:Set('MATR915',"SA1|SA2")
oHash:Set('MATR916',"SA1|SA2")
oHash:Set('MATR921',"SA1|SA2")
oHash:Set('MATR922',"SA1|SA2")
oHash:Set('MATR926',"SA2")
oHash:Set('MATR928',"SA1")
oHash:Set('MATR929',"SA2")
oHash:Set('MATR930',"CVB|SA1|SA2")
oHash:Set('MATR931',"SA1|SA2")
oHash:Set('MATR932',"SA1|SA2")
oHash:Set('MATR933',"SA1|SA2")
oHash:Set('MATR934',"SA1|SA2")
oHash:Set('MATR935',"SA1|SA2")
oHash:Set('MATR937',"SA1|SA2")
oHash:Set('MATR938',"SA1|SA2")
oHash:Set('MATR939',"SA1|SA2")
oHash:Set('MATR945',"SA1|SA2")
oHash:Set('MATR948',"SA1|SA2")
oHash:Set('MATR955',"SA1|SA2")
oHash:Set('MATR962',"SA1")
oHash:Set('MATR967',"SA1|SA2")
oHash:Set('MATR968',"SA1")
oHash:Set('MATR970',"SA1|SA2")
oHash:Set('MATR973',"SA2")
oHash:Set('MATR975',"SA1|SA2")
oHash:Set('MATR980',"SA1")
oHash:Set('MATR981',"SA1")
oHash:Set('MATR990',"CVB|SA1|SA2")
oHash:Set('MATR995',"CVB|SA2")
oHash:Set('MATR997',"SA1|SA2")
oHash:Set('MATR998',"SA1|SA2")
oHash:Set('MATXFIS','SA1|SA2|SS2|SS3')
oHash:Set('MATXMAG','SA1|SA2|SRA')
oHash:Set('NFA',"SA1")
oHash:Set('NFAII',"SA1|SA4")
oHash:Set('NFEBA',"SA4")
oHash:Set('NFEITA',"SA1")
oHash:Set('NFEVRSIMP',"SA1")
oHash:Set('NFSEXml002',"SA1|SA2|SA4")
oHash:Set('NFSEXml003',"SA1|SA2|SA4")
oHash:Set('NFSEXml102',"SA1|SA2|SA4")
oHash:Set('NORMA071',"SA1|SA2")
oHash:Set('NOVAGISS',"SA1|SA2")
oHash:Set('PERDREINT',"SA1")
oHash:Set('PORT35SC',"SA1|SA2")
oHash:Set('RIEX',"SA1|SA2")
oHash:Set('SCANC',"SA1|SA2|SA4")
oHash:Set('SEFII',"SA1|SA2")
oHash:Set('SEFINSC',"SA1|SA2")
oHash:Set('SISCRED',"SA1|SA2")
oHash:Set('SPEDFISCAL',"CD6|CVB|SA1|SA2")
oHash:Set('SPEDXFUN',"CVB|SA1|SA2|SA4")
oHash:Set('VVISS',"SA1|SA2")

//Rotinas dos M�dulos CRM, TMK, FAT, PMS
// Funcoes do fonte: TMKA260.PRW
oHash:Set('TMKA260','SUS|AO4|SA3|SUO')
oHash:Set('CRMA700','SUS|AO4|SA3|SUO')

// Funcoes do fonte: CRMA070.PRW
oHash:Set('CRMA070','SA1')

// Funcoes do fonte: CRMA470.PRW
oHash:Set('CRMA470','SU5')


// Funcoes do fonte: TMKC040.PRW
oHash:Set('TMKC040','ACH|SA1|SUS|AO4')
oHash:Set('CRMA390','ACH|SA1|SUS|AO4')
oHash:Set('TKC40VISUA','SA1|SUS|ACH')

// Funcoes do fonte: TMKR049.PRW
oHash:Set('TMKR049','AC8|SUS')

// Funcoes do fonte: CRMM080.PRW
oHash:Set('CRMMENTITIES','AO3|AO4|SA1|SUS')

// Funcoes do fonte: CRMS700.PRW
oHash:Set('PROSPECTS','SUS')

// Funcoes do fonte: TMKA061.PRW
oHash:Set('TMKA061','SU4|SU6|ACH|AO4|SA1|SU5|SUS')

// Funcoes do fonte: TMKA061A.PRW REVER
oHash:Set('TK061ENTCO','AC8|SU5|SU6')
oHash:Set('TK061COPY','SU4|SU7')
oHash:Set('TK061SELOP','SU4|SU7')

// Funcoes do fonte: TMKA061B.PRW
oHash:Set('TK061WIZAR','SU4|SU7')

// Funcoes do fonte: TMKA061C.PRW
oHash:Set('TK061TRANS','SU4|SU7')

// Funcoes do fonte: TMKA061D.PRW
oHash:Set('TK061CONTD','SU5')

// Funcoes do fonte: TMKA062.PRW
oHash:Set('TK062LISTA','SU4|SU6|SA1|SU5')
oHash:Set('TMKA062','SU4|SU6')

// Funcoes do fonte: TMKA062A.PRW
oHash:Set('TK062ARQOU','SU4|SU6|SU7')
oHash:Set('TK062CONTD','SU5')
oHash:Set('TK062ITENS','SU6')
oHash:Set('TK062SELOP','SU7')

// Funcoes do fonte: TMKA090.PRX
oHash:Set('TK090FILTG','AG9|SU7')
oHash:Set('TK090OPFIL','AG9|SU7')
oHash:Set('TK090VISUA','SU7')
oHash:Set('TMKA090','SU7')

// Funcoes do fonte: TMKA091.PRW
oHash:Set('TMKA091','SU7')

// Funcoes do fonte: TMKA380.PRW
oHash:Set('TMKA380','ACF|SA1|SU5|SU6|SU7|SUA|SUC|SUS|SUO')

// Funcoes do fonte: TMKA380A.PRW
oHash:Set('TK380PCADA','SU5|SU4|SU6')

//Funcoes do fonte: TMKXFUNE.PRW
oHash:Set('TKLISTAS','SU4|SU6')

// Funcoes do fonte: TMKA380D.PRW
oHash:Set('TK380PPEND','ACF|SA1|SU5|SU6|SUA|SUC|SUS')

// Funcoes do fonte: TMKC030.PRW
oHash:Set('TKC030CHAN','SU7')

// Funcoes do fonte: TMKR009.PRX
oHash:Set('TMKR009','SU7')

// Funcoes do fonte: TMKR030.PRW
oHash:Set('TMKR030','SU7')

// Funcoes do fonte: TMKR041.PRW
oHash:Set('TMKR041','ACF|ACG|SA1|SU4|SU5|SU6|SU7')

// Funcoes do fonte: TMKR047.PRW
oHash:Set('TMKR047','SU7')

// Funcoes do fonte: TMKA341.PRW
oHash:Set('TK341MILE','ACH')
oHash:Set('TMKA341','ACH')
oHash:Set('TK341EXECO','AD1|AD2|AO3|ACH|AO3|SA3')

// Funcoes do fonte: TMKA342.PRW
oHash:Set('TMKA342','ACH|SA1|SA3|SUS')

// Funcoes do fonte: CRMA320.PRW
oHash:Set('CRMA320','ACH')

// Funcoes do fonte: CRMS320.PRW
oHash:Set('SUSPECTS','ACH')

// Funcoes do fonte: TMKA070.PRX
oHash:Set('TMKA070', 'SU5|AGA|AGB|SU7')

// Funcoes do fonte: TMKA210.PRW
oHash:Set('TMKA210', 'SU5|SUM')

// Funcoes do fonte: CRMA150.PRW
oHash:Set('CRMA150', 'SU5')

// Funcoes do fonte: TMKC010.PRW
oHash:Set('TMKC010', 'SU5')
oHash:Set('TKC010CON','AD1|AD9|SU5|AC3|AD3|AC4|AD2|AD4|ADK|SA3|AC8|ACH|SUS|SUO|SA1|AGA|AGB|SUA|SUC|ACF|ACG|SC5|SF2|SU4|SU6|SU7|SU8|SUD')

// Funcoes do fonte: TMKA700.PRW
oHash:Set('TMKA700', 'AIK')

// Funcoes do fonte: TMKR010.PRX
oHash:Set('TMKR010', 'SU5|AC8')

// Funcoes do fonte: CRMA060.PRW
oHash:Set('CRMA060','AC3|AC4|ACH|SA1|SU2|SUS|AC8')

// Funcoes do fonte: CRMS040.PRW
oHash:Set('CONTACTRELATIONSHIP', 'AC8')

// Funcoes do fonte: CRMM030.PRW
oHash:Set('CRMMCONTACTS', 'AGB|SU5')

// Funcoes do fonte: TMKS070.PRW
oHash:Set('CONTACT', 'SU5')

// Funcoes do fonte: CRMM040.PRW
oHash:Set('CRMMENTITYXCONTACTS','AC8|SU5')

// Funcoes do fonte: CRMA440.PRW
oHash:Set('CRMA440','SU5')

// Funcoes do fonte: TMKR020.PRX
oHash:Set('TMKR020','SU4|SU5|SU6')

// Funcoes do fonte: MATS040.PRW
oHash:Set('SELLERS','SA3')

// Funcoes do fonte: FATA070.PRX
oHash:Set('FATA070','ACA|ADK|SA3')

// Funcoes do fonte: FATA050.PRX
oHash:Set('FT050CONS','SA3')

// Funcoes do fonte: FATA571.PRW
oHash:Set('FATA571','ADG')

// Funcoes do fonte: TMKR032.PRW
oHash:Set('TMKR032','SA3')

// Funcoes do fonte: MATR540.PRX
oHash:Set('MATR540','SA1|SA3')

// Funcoes do fonte: FATA520B.PRW
oHash:Set('FT520PROCE','SA3')

// Funcoes do fonte: FATA520.PRW
oHash:Set('FATA520','ADL')
oHash:Set('FT520PROC','SA3')

// Funcoes do fonte: FATA510.PRW
oHash:Set('FATA510','ADK')

// Funcoes do fonte: MATA040.PRX
oHash:Set('MATA040','SA3')

// Funcoes do fonte: CRMA020.PRW
oHash:Set('CRMA020','AO3|SA3|ACH|SA1|SUS|AIM|AIN')

// Funcoes do fonte: CRMA020B.PRW
oHash:Set('CRMA020B','|SA1|SUS|ACH|AIM')

// Funcoes do fonte: CRMA030.PRW
oHash:Set('CRMA030','AIN|ACH|SUS')

// Funcoes do fonte: CRMA120.PRW
oHash:Set('CRM120INCO','AD1|SA1')
oHash:Set('CRM120INCA','AD5|SA1')
oHash:Set('CRM120MTREE','SA1')

// Funcoes do fonte: CRM980EVENTDEF.PRW
oHash:Set('AFTERTTS','SA1')

// Funcoes do fonte: MATA030.PRX
oHash:Set('MATA030','SA1')
oHash:Set('MATA030REF','SA1|SAO')

// Funcoes do fonte: CRMA980.PRW
oHash:Set('CRMA980','SA1')

// Funcoes do fonte: MATR020.PRX
oHash:Set('MATR020','SA1')

// Funcoes do fonte: MATN030A.PRX
oHash:Set('MA030MILE','SA1')

// Funcoes do fonte: MATS030.PRW
oHash:Set('CUSTOMERVENDOR','SA1')

// Funcoes do fonte: FATA120.PRW
oHash:Set('FATA120','SA1')

// Funcoes do fonte: FATA330.PRW
oHash:Set('FATA330','AO3|AC8|ADL|AO4|SA1|SU5|SUS')

// Funcoes do fonte: MATR640.PRX
oHash:Set('MATR640','SA1|SA3|SF2')

// Funcoes do fonte: MATR785.PRX
oHash:Set('MATR785','SA1')

// Funcoes do fonte: TMKR033.PRW
oHash:Set('TMKR033','SA1')

// Funcoes do fonte: CRMA240.PRW
oHash:Set('CRMA240','AO5')

// Funcoes do fonte: TMKA503A.PRW
oHash:Set('TK503TRSP','ADE')

// Funcoes do fonte: TMKA510.PRW
oHash:Set('TK510TRANS','SU7')
oHash:Set('TK510USRLO','SU7')

// Funcoes do fonte: TMKA510A.PRW
oHash:Set('ACOES_LOTE','SU7')
oHash:Set('TK510GERXL','SU7')

// Funcoes do fonte: CRMA330.PRW
oHash:Set('CRMA330','AD5|SA1|ACH|SUS')

// Funcoes do fonte: FATA310.PRX
oHash:Set('FATA310','AD5')

// Funcoes do fonte: FATR040.PRX
oHash:Set('FATR040','SA2|SA3')

// Funcoes do fonte: TMKA020.PRX
oHash:Set('TMKA020','SU2')

// Funcoes do fonte: TMKA120.PRW
oHash:Set('TMKA120','SUF')

// Funcoes do fonte: TMKA240.PRX
oHash:Set('TMKA240','SUQ')

// Funcoes do fonte: TMKA272.PRW
oHash:Set('TK272SURFI','SUQ')
oHash:Set('TK272LIGPE','SU7|SUC|SUD|SUQ')

// Funcoes do fonte: TMKA272A.PRW
oHash:Set('TK272HTMK','SU7|SUC|SUD|SUQ')
oHash:Set('TK272SELOP','SU7')
oHash:Set('TK272ENVTM','SU5|SU7|SUC|SUD')

// Funcoes do fonte: TMKA340.PRW
oHash:Set('TMKA340','ACE')

// Funcoes do fonte: TMKC020.PRW
oHash:Set('TK020LISTB','ACF|ACG|SU7')

// Funcoes do fonte: TMKR001.PRX
oHash:Set('TMKR001', 'SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR002.PRX
oHash:Set('TMKR002', 'SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR018.PRX
oHash:Set('TMKR018', 'SU5|SU7|SUC|SUD|SUQ')

// Funcoes do fonte: TMKR019.PRX
oHash:Set('TMKR019', 'SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR022.PRX
oHash:Set('TMKR022', 'SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR023.PRX
oHash:Set('TMKR023', 'SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR029.PRW
oHash:Set('TMKR029','AC4|ACH|BA1|BAU|SA1|SA2|SA4|SU2|SUS|SU5')

// Funcoes do fonte: TMKR034.PRW
oHash:Set('TMKR034', 'SU5|SU7|SUC|SUD|SUO')

// Funcoes do fonte: TMKR035.PRW
oHash:Set('TMKR035', 'ACE')

// Funcoes do fonte: TMKR036.PRW
oHash:Set('TMKR036', 'SUO')

// Funcoes do fonte: TMKR050.PRW
oHash:Set('TMKR050', 'AGL|SU7')

// Funcoes do fonte: TMKR070.PRW
oHash:Set('TMKR070', 'SU7|SUC|SUD|SUQ')

// Funcoes do fonte: MATA430.PRX
oHash:Set('MATA430','SC0')

// Funcoes do fonte: TMKR501.PRW
oHash:Set('TMKR501','ADE|SU7')

// Funcoes do fonte: TMKR502.PRW
oHash:Set('TMKR502','ADE|ADF|SU7')

// Funcoes do fonte: TMKR503.PRW
oHash:Set('TMKR503','ADE|SK8|SU5|SU7')

// Funcoes do fonte: TMKR504.PRW
oHash:Set('TMKR504','ADE|SU5|SU7')

// Funcoes do fonte: TMKR505.PRW
oHash:Set('TMKR505','ADE|SU5|SU7')

// Funcoes do fonte: TMKR506.PRW
oHash:Set('TMKR506','ADE|ADF|SU5|SU7|SUO|SUQ')

// Funcoes do fonte: TMKR507.PRW
oHash:Set('TMKR507','ADE|SA1|SU7')

// Funcoes do fonte: TMKR508.PRW
oHash:Set('TMKR508','ADE|SU7')

// Funcoes do fonte: TMKR509.PRW
oHash:Set('TMKR509','SU7')

// Funcoes do fonte: CRMA930.PRW
oHash:Set('CRMA930EXV','AZ4|AZ7')

// Funcoes do fonte: CRMA950.PRW
oHash:Set('CRMA950','AZ4')

// Funcoes do fonte: TMKA274.PRW
oHash:Set('TK274HTLC','ACF|ACG')
oHash:Set('TK274SIMUL','ACF|ACG|SA1')

// Funcoes do fonte: TMKA280.PRW
oHash:Set('TMKA280','ACF')
oHash:Set('TK280COBRA','ACF|ACG|SA1|SU4|SU5|SU6|SUC|SUD|SUA')

// Funcoes do fonte: TMKA290.PRW
oHash:Set('TMKA290','SA1')

// Funcoes do fonte: TMKA300.PRW
oHash:Set('TK300ATU','SU7')
oHash:Set('TMKA300','SA1')

// Funcoes do fonte: TMKA350.PRW
oHash:Set('TMKA350','ACF|ACG')

// Funcoes do fonte: TMKR037.PRW
oHash:Set('TMKR037', 'SU5|SA1')

// Funcoes do fonte: TMKR038.PRW
oHash:Set('TMKR038', 'SA1|SU5|SU7')

// Funcoes do fonte: TMKR042.PRW
oHash:Set('TMKR042','ACF|SA1|SU7')

// Funcoes do fonte: TMKR043.PRW
oHash:Set('TMKR043', 'SU7')
  
// Funcoes do fonte: FATA400.PRX
oHash:Set('FT400BCTR','SA1')
oHash:Set('FATA400','ADA')

// Funcoes do fonte: FATR030.PRX
oHash:Set('FATR030','SA1')

// Funcoes do fonte: FATA600.PRW
oHash:Set('FATA600','ADZ|ADY')
oHash:Set('A600TIMEV','SA3')
oHash:Set('A600CRMDPC','SA1|SUS|ACH')

// Funcoes do fonte: CRMA490.PRW
oHash:Set('CRMA490','AC3') 

// Funcoes do fonte: FATR070.PRW
oHash:Set('FATR070','ADY|SA1|ADZ|SUS')

// Funcoes do fonte: FATA101.PRX
oHash:Set('FATA101','AIH')

// Funcoes do fonte: MATA851.PRW
oHash:Set('MATA851','AIH')

// Funcoes do fonte: MATA853.PRW
oHash:Set('MATA853','AIH|SA3')

// Funcoes do fonte: TMKXFUN.PRW
oHash:Set('TKENTCONTA','AC8|SU2|SA1|SUS|ACH|SA2|AC4|SA4')

// Funcoes do fonte: TMKXFUNA.PRW
oHash:Set('TKCONTATOS','AC8|SU5')

// Funcoes do fonte: TMKXFUNB.PRW
oHash:Set('TKVISITA','SA3')
oHash:Set('TKGRVSU4','SU5')
oHash:Set('TKAGENDA','AD7|SA1|SA3|SU5|SUS')

// Funcoes do fonte: TMKXFUNC.PRW
oHash:Set('TK271COPIA','SA1|SU7|SUA|SUS')

// Funcoes do fonte: TMKXFUND.PRW
oHash:Set('TKHISTLOJ','SA1|SA3')

// Funcoes do fonte: TMKXFUNE.PRW
oHash:Set('TKCONTDIRE','AC8|SU2|SA1|SUS|ACH|SA2|AC4|SA4')
oHash:Set('TKSELENT','AC8|SA1|SU5|SUS|SU2|ACH|SA2|AC4|SA4')

// Funcoes do fonte: TMKXFUNF.PRW
oHash:Set('TKDLGSCR','AC8|SU5|SA1|SUS|ACH')

// Funcoes do fonte: MATA440.PRX
oHash:Set('MATA440','SC5')

// Funcoes do fonte: MATA450.PRX
oHash:Set('MATA450','SC5')
oHash:Set('A450TELA','SA1')

// Funcoes do fonte: MATA450A.PRX
oHash:Set('MATA450A','SA1')
oHash:Set('MA450CLMAN','SC5')

// Funcoes do fonte: MATA455.PRX
oHash:Set('MATA455','SC5')
oHash:Set('A455LIBMAN','SA1')
oHash:Set('A455LIBALT','SA1')

// Funcoes do fonte: MATA456.PRX
oHash:Set('MATA456','SC5')

// Funcoes do fonte: CRMA250.PRW
oHash:Set('CRMA250','SU4')

// Funcoes do fonte: CRMA260.PRW
oHash:Set('CRM260CVSUS','ACH|AOD')
oHash:Set('CRM260NWOPP','AD1|AOD|SA1|SUS')
oHash:Set('CRMA260INC','AOD|SUO')
oHash:Set('CRMA260CONV','AOD')
oHash:Set('CRMA260ALT','AOD')

// Funcoes do fonte: CRMS340.PRW
oHash:Set('EVENTS','ACE')

// Funcoes do fonte: TMKA310.PRW
oHash:Set('TMKA310','SUO')

// Funcoes do fonte: TMKA310B.PRW
oHash:Set('TMKA130B','AOG|SU4|SUO')

// Funcoes do fonte: TMKR026.PRW
oHash:Set('TMKR026','ACE|SUO')

// Funcoes do fonte: TMKR027.PRW
oHash:Set('TMKR027','ACE|SUO')

// Funcoes do fonte: TMKA150.PRW
oHash:Set('TK150EXCLU','SA1|SU7|SUA|SUS')
oHash:Set('TMKA150','SUA')

// Funcoes do fonte: TMKA273.PRW
oHash:Set('TMKA273','SUA|SUS|SA1')

// Funcoes do fonte: TMKA273A.PRW
oHash:Set('TK273HTLV','SA3|SU5|SUA|SUC|SUO')

// Funcoes do fonte: TMKA273C.PRW
oHash:Set('TK273PAGAM','SUA')

// Funcoes do fonte: TMKR004.PRX
oHash:Set('TMKR004', 'SA3|SU7|SUA')

// Funcoes do fonte: TMKR005.PRX
oHash:Set('TMKR005', 'SA3|SUA|SUO')

// Funcoes do fonte: TMKR014.PRX
oHash:Set('TMKR014', 'SUA|SUO|SA3|SA1|SU5|SU7|SUA|SUS')

// Funcoes do fonte: TMKR016.PRX
oHash:Set('TMKR016', 'SA3|SU7|SUA|SUO')

// Funcoes do fonte: TMKR017.PRX
oHash:Set('TMKR017', 'SA3|SU7|SUA|SUO')

// Funcoes do fonte: TMKR024.PRX
oHash:Set('TMKR024', 'SA1|SA3|SU7|SUA|SUO|SUS')

// Funcoes do fonte: TMKR025.PRX
oHash:Set('TMKR025', 'SA1|SA3|SU7|SUA|SUO|SUS')

// Funcoes do fonte: TMKR039.PRW
oHash:Set('TMKR039', 'SA1|SU5|SUA|SUC|SUS')

// Funcoes do fonte: TMKR044A.PRW
oHash:Set('TMKR044A','AC8|ACE|SU5|SU7|SUC|SUD|SUO|SUQ')

// Funcoes do fonte: TMKR044B.PRW
oHash:Set('TMKR044B','ACF|ACG|SA1|SA3|SU5|SU7|SUA|SUO')

// Funcoes do fonte: TMKR044C.PRW
oHash:Set('TMKR044C','ACE|SU4|SU7|SUO')

// Funcoes do fonte: TMKR044D.PRW
oHash:Set('TMKR044D','SA1')

// Funcoes do fonte: TMKA271.PRW
oHash:Set('TMKA271','ACF|ACG|SUA|SUC|SUD')

// Funcoes do fonte: TMKA271A.PRW
oHash:Set('Tk271DlCmp','SU5')
oHash:Set('TK271TEL','SU0|SU5')

// Funcoes do fonte: PMSA050.PRW
oHash:Set('PMSA050','AE8')

// Funcoes do fonte: PMSA710.PRW
oHash:Set('PMSA710','AJK')
oHash:Set('PMS710DLG','AJK')

// Funcoes do fonte: PMSC110.PRW
oHash:Set('PMSC110','AE8')

// Funcoes do fonte: PMSC112.PRW
oHash:Set('AUXC112VIEW','AE8')

// Funcoes do fonte: PMSC120.PRW
oHash:Set('PMSC120','AE8')

// Funcoes do fonte: PMSLPGL.PRW
oHash:Set('PMSLONL01','AE8')
oHash:Set('PMSLONL05','AE8')

// Funcoes do fonte: PMSR090.PRW
oHash:Set('PMSR090', 'AE8')

// Funcoes do fonte: PMSR210.PRW
oHash:Set('PMSR210', 'AE8')

// Funcoes do fonte: PMSR240.PRW
oHash:Set('PMSR240', 'AE8')

// Funcoes do fonte: PMSR250.PRW
oHash:Set('PMSR250','AE8')

// Funcoes do fonte: PMSR380.PRW
oHash:Set('PMSR380','AE8')

// Funcoes do fonte: TMKA520H.PRW
oHash:Set('TMKA520H','SKW')

// Funcoes do fonte: TMKA520I.PRW
oHash:Set('TMKA520I','SKY|AGZ')

// Funcoes do fonte: CRMA010.PRW
oHash:Set('CRMA010','AO3')

// Funcoes do fonte: CRMA080.PRW
oHash:Set('CRMA080','AO3')

// Funcoes do fonte: CRMA110.PRW
oHash:Set('CRMA110','AD1|AO4|SA1|SUS')

// Funcoes do fonte: CRMA910.PRW
oHash:Set('CRMA910','AOL|ACA|AO3|AZ2')

// Funcoes do fonte: CRMM020.PRW
oHash:Set('CRMMOPPORTUNITIES','AD1|AO3|AD9|AO4|SA1|SU5|SUS')

// Funcoes do fonte: FATA020.PRX
oHash:Set('FATA020','AC3')

// Funcoes do fonte: FATA030.PRX
oHash:Set('FATA030','AC4')

// Funcoes do fonte: FATA060.PRX
oHash:Set('FATA060','A0A|ACA')

// Funcoes do fonte: FATA300.PRX
oHash:Set('FT300F3U5','AC8|AD1|SU5')
oHash:Set('FT300CMP','AD2|AD3|AD4|AD9|ADJ|AIJ')
oHash:Set('FT300SPWF','AD1|SA1')
oHash:Set('FT300BRWRAT','AGU')
oHash:Set('FT300GRUPO','SA1')

// Funcoes do fonte: FATC020.PRW
oHash:Set('FATC020','AD1')

// Funcoes do fonte: FATN300.PRX
oHash:Set('FT300PENDF','AD1|SA1|AGU|AC2')

// Funcoes do fonte: FATR010.PRX
oHash:Set('FATR010','AC3|AC4|AD1|AD2|AD3|AD4|AD9|AO4|SA3|SU5')

// Funcoes do fonte: FATR060.PRW
oHash:Set('FATR060','AD1|SA1|SA3|SUS')

// Funcoes do fonte: FATS300.PRW
oHash:Set('OPPORTUNITY','AD1|SA1|SA3|SU5|SUS')

// Funcoes do fonte: FATV300.PRX
oHash:Set('FT300AFINC','AD1|ADY|SA1|SUS')

// Funcoes do fonte: FATV300A.PRX
oHash:Set('F300VU5ALL','AC8|AD1|AD9|SU5')

// Funcoes do fonte: MATA521.PRX
oHash:Set('MATA521A','SA1|SF2')

// Funcoes do fonte: CRMA190.PRW
oHash:Set('CRMA190','AO7')

// Funcoes do fonte: CRMA210.PRW
oHash:Set('CRMA210','AO3')

// Funcoes do fonte: CRMM010.PRW
oHash:Set('CRMMUSERROLES','AO3|SA3')

// Funcoes do fonte: CRMA180.PRW
oHash:Set('CRMA180','AOF')

// Funcoes do fonte: CRMM110.PRW
oHash:Set('CRMMACTIVITIES','AD1|AOF|SA1|SUS')

// Funcoes do fonte: CRMS180.PRW
oHash:Set('SELLERACTIVITY','AOF')

// Funcoes do fonte: FATR080.PRW
oHash:Set('FATR080','ACA|ADK|CTT|SA1|SF2')

// Funcoes do fonte: FATR120.PRW
oHash:Set('FATR120','SA1|SF2')

// Funcoes do fonte: MATA511.PRX
oHash:Set('MATA511A','SF2')
oHash:Set('MATA511B','SF2')

// Funcoes do fonte: MATC090.PRX
oHash:Set('MC090VISUAL','SA1|SA2|SF2')
oHash:Set('MATC090','SF2')

// Funcoes do fonte: MATR185.PRW
oHash:Set('MATR185','SA1|SF1|SF2')

// Funcoes do fonte: MATR550.PRX
oHash:Set('MATR550','SA1|SF2')

// Funcoes do fonte: MATR560.PRX
oHash:Set('MATR560','SF2')

// Funcoes do fonte: MATR570.PRX
oHash:Set('MATR570','SF2')

// Funcoes do fonte: MATR580.PRX
oHash:Set('MATR580','SA3|SF2')

// Funcoes do fonte: MATR590.PRX
oHash:Set('MATR590','SA1|SF2')

// Funcoes do fonte: MATR650.PRX
oHash:Set('MATR650','SA1|SF2')

// Funcoes do fonte: MATR660.PRX
oHash:Set('MATR660','SF2')

// Funcoes do fonte: MATR710.PRX
oHash:Set('MATR710','SA1|SF2')

// Funcoes do fonte: MATR720.PRX
oHash:Set('MATR720','SA1|SF2')

// Funcoes do fonte: MATR730.PRX
oHash:Set('MATR730','SA1|SA3|SC5|SF2')

// Funcoes do fonte: MATR760.PRX
oHash:Set('MATR760','SA1|SF2')

// Funcoes do fonte: MATR765.PRX
oHash:Set('MATR765','SA1')

// Funcoes do fonte: MATR770.PRX
oHash:Set('MATR770','SA1')

// Funcoes do fonte: MATR780.PRX
oHash:Set('MATR780','SA1|SF2')

// Funcoes do fonte: FATA080.PRX
oHash:Set('FATA080','ACO')
oHash:Set('FT080RDES','ACO|SA1')

// Funcoes do fonte: FATA090.PRX
oHash:Set('FATA090','ACQ')
oHash:Set('FT080RDES','ACQ|SA1')

// Funcoes do fonte: FATA100.PRX
oHash:Set('FATA100','ACS')
oHash:Set('FT100RNEG','ACS|SA1')

// Funcoes do fonte: FATA180.PRX
oHash:Set('FATA180','AI1')
oHash:Set('FT180RBNF','AI1|SA1')

// Funcoes do fonte: FATA210.PRW
oHash:Set('FATA210','SC5')

// Funcoes do fonte: FATA502.PRW
oHash:Set('FATA502','ADL|SCJ')

// Funcoes do fonte: MATA415.PRX
oHash:Set('MATA415','SCJ|SA1|SUS')

// Funcoes do fonte: MATA416.PRX
oHash:Set('MATA416','SCJ|SA1|SUS')

// Funcoes do fonte: MATR605.PRX
oHash:Set('MATR605', 'SCJ|SA1|SUS')

// Funcoes do fonte: CRMA310.PRW
oHash:Set('CRMA310','SA1|ACH|SUS|SC5')

// Funcoes do fonte: MATA410.PRX
oHash:Set('MATA410','SC5')

// Funcoes do fonte: MATN410.PRW
oHash:Set('MA410RODAP','SA1|SA2')

// Funcoes do fonte: MATN410A.PRW
oHash:Set('MA410NFVP3','SA1|SA2|SC5|SF2')

// Funcoes do fonte: MATR012.PRW
oHash:Set('MATR012', 'SD9|SF2')

// Funcoes do fonte: MATR600.PRX
oHash:Set('MATR600', 'SA1|SA3|SC5')

// Funcoes do fonte: MATR610.PRX
oHash:Set('MATR610', 'SA1|SA3|SC5')

// Funcoes do fonte: MATR680.PRX
oHash:Set('MATR680', 'SA1|SA3|SC5')

// Funcoes do fonte: MATR700.PRX
oHash:Set('MATR700', 'SA1|SC5')

// Funcoes do fonte: MATR790.PRX
oHash:Set('MATR790', 'SA1|SC5|SF2')

// Funcoes do fonte: PMSA103.PRW
oHash:Set('PMS103DLG','AF3')

// Funcoes do fonte: PMSR040.PRW
oHash:Set('PMSR040','AE8|AF3')

// Funcoes do fonte: PMSR050.PRW
oHash:Set('PMSR050','AE8|AF3')

// Funcoes do fonte: FATA160.PRW
oHash:Set('FT160VLD','SA1')

// Funcoes do fonte: FATA320B.PRX
oHash:Set('FATA320','SA3')

// Funcoes do fonte: FATR320.PRW
oHash:Set('FATR320', 'AD7|SA1|SA3|SU5|SUS')

// Funcoes do fonte: MATR530.PRX
oHash:Set('MATR530', 'SA1')

// Funcoes do fonte: FATA530.PRW
oHash:Set('FTADLGAF1','AF3')

// Funcoes do fonte: PMSA010.PRW
oHash:Set('PA010DIALO','AE2')

// Funcoes do fonte: PMSA200.PRW
oHash:Set('PMS200SBLT','AE8')
oHash:Set('PMS200DLG','AFA')

// Funcoes do fonte: PMSA203.PRW
oHash:Set('PMS203VIS','AFA')
oHash:Set('PMSRECOFF','AE8|AFA')

// Funcoes do fonte: PMSA210.PRW
oHash:Set('PMS210HST','AFE')
oHash:Set('PMS210ADDT','AE8|AFA')
oHash:Set('PMS210RVS','AFE')
oHash:Set('PMS210FRV','AFE')
oHash:Set('PMS210DET','AFE')
oHash:Set('AUXDLGAF81','AFX')
oHash:Set('AUXDLGAF82','AFX')

// Funcoes do fonte: PMSA300.PRW
oHash:Set('PMS300DLG','AFA')
oHash:Set('PMS300REC','AFU')

// Funcoes do fonte: PMSA310.PRW
oHash:Set('PMS310DLG','AFA|')
oHash:Set('A310ViewBr','AFF')
oHash:Set('A310CONFED','AFF')

// Funcoes do fonte: PMSA311.PRW
oHash:Set('PMS311DLG','AFF')

// Funcoes do fonte: PMSC010.PRW
oHash:Set('PMSREADREC','AFA|AE8')

// Funcoes do fonte: PMSMONIT.PRW
oHash:Set('AUXUSRGTT','AE8|AFA|AFF')

// Funcoes do fonte: PMSR010.PRW
oHash:Set('PMSR010','AE2|AE8')

// Funcoes do fonte: PMSR017.PRW
oHash:Set('PMSR017','AE8')

// Funcoes do fonte: PMSR030.PRW
oHash:Set('PMSR030','AF3|SA1')

// Funcoes do fonte: PMSR060.PRW
oHash:Set('PMSR060','AFE|SA1')

// Funcoes do fonte: PMSR080.PRW
oHash:Set('PMSR080','AFE|SA1')

// Funcoes do fonte: PMSR100.PRW
oHash:Set('PMSR100','AFE|SA1')

// Funcoes do fonte: PMSR106.PRW
oHash:Set('PMSR106','AE8|AFA')

// Funcoes do fonte: PMSR120.PRW
oHash:Set('PMSR120','AFE|SA1')

// Funcoes do fonte: PMSR130.PRW
oHash:Set('PMSR130','AFE')

// Funcoes do fonte: PMSR140.PRW
oHash:Set('PMSR140','AE8|AFA')

// Funcoes do fonte: PMSR150.PRW
oHash:Set('PMSR150','AE8|AFA|SA1')

// Funcoes do fonte: PMSR160.PRW
oHash:Set('PMSR160','SA1')

// Funcoes do fonte: PMSR170.PRW
oHash:Set('PMSR170','AE8|AFA|SA1')

// Funcoes do fonte: PMSR270.PRW
oHash:Set('PMSR270','AFE|SA1')

// Funcoes do fonte: PMSR360.PRW
oHash:Set('PMSR360','SA1')

// Funcoes do fonte: PMSR390.PRW
oHash:Set('PMSR390','ADE')

//Rotinas do VAREJO (M�dulo Controle de Lojas) - SIGALOJA
oHash:Set('LOJA701','SLQ|SL1|SL4')  // Venda Assistida
oHash:Set('LOJA720','SL1|SA1')      // Rotina de Troca
oHash:Set('LOJC020','SA3')          // Consulta de Vendas Por Vendedor
oHash:Set('LOJC040','SA1|SA3')      // Consulta de Vendas
oHash:Set('LOJR075','SA1|SL1')      // Relat�rio Mapa de Vendas
oHash:Set('LOJR170','SA1|SA6|SE1')  // Relat�rio Emiss�o de Border�s
oHash:Set('LOJR190','SA1|SEF')      // Relat�rio de Cheques Devolvidos
oHash:Set('LOJR590','SA1|SL1')      // Relat�rio de Or�amentos X Solicita��es de Compras
oHash:Set('LOJR740','SA1|SA3')      // Relat�rio de Vendas Perdidas
oHash:Set('LOJR810','SA1|SL1')      // Relat�rio de Vendas x M�dia
oHash:Set('LOJA845','MEE')          // Cadastro de Lista de Presentes
oHash:Set('LOJR847','SA1|MEE')      // Relat�rio de Acompanhamento de Listas de Presentes
oHash:Set('LOJR848','SA1|MEE')      // Relat�rio de Conta Correntes (Lista de Presente)
oHash:Set('LOJR850','SA1')          // Relat�rio de Vendas Anal�tico (Lista de Presentes)
oHash:Set('LOJR851','SA1')          // Relat�rio de Status da Lista (Lista de Presentes)

//Rotinas do VAREJO (M�dulo Fideliza��o e An�lise de Cr�dito) - SIGACRD
oHash:Set('CRDA010','MA7|MA8|MAB|MAC|MAD|MAQ')  // Cadastro de Clientes
oHash:Set('CRDR020','SA1|MA7|MA8|MAB|MAA')      // Relat�rio Fichas de Clientes
oHash:Set('CRDR030','SA1')                      // Relat�rio Clientes X Cart�es
oHash:Set('CRDR310','SA1')                      // Relat�rio Saldo Fidelidade do Cliente

//--Rotinas do m�dulo TMS
//Aten��o! Ordenar os fontes em ordem alfabetica para n�o ocorrer duplicidade de informa��es.
oHash:Set('TMSA011',"SA1")                          //-- Ajuste Tabela de Frete
oHash:Set('TMSA019',"SA1|DDD")                      //-- Tela Gera��o de Agd/Sol.Coletas a partir do MRP
oHash:Set('TMSA050',"SA1")	                        //-- Entrada Dc. Cliente
oHash:Set('TMSA141',"SA1")                          //-- Viagem Coleta/Entrega
oHash:Set('TMSA144',"SA1|DFT|DT6|DUE|SA2|DJN")      //-- Manutencao Viagem Mod.2
oHash:Set('TMSA145',"SA1")                          //-- Painel de Gest�o de Viagens
oHash:Set('TMSA146',"SA1")	                        //-- Programa��o de Carregamento
oHash:Set('TMSA147',"SA1")                          //-- Cadastro de Romaneios
oHash:Set('TMSA152',"SA1")                          //-- Gera��o de Documentos Complementares 
oHash:Set('TMSA153',"SA1")                          //-- Estrutura Tela Gest�o de Demandas
oHash:Set('TMSA153A',"DL8|DLA")                     //-- Cadastro de Demanda
oHash:Set('TMSA153B',"DL8|DL9|DLA")                 //-- Cadastro de Planejamento de demanda
oHash:Set('TMSA153C',"DL7")                         //-- Contrato de demandas 
oHash:Set('TMSA153D',"DD5")                         //-- Controle Detalhado de Metas
oHash:Set('TMSA153E',"DLA|DL7")                     //-- Estrutura da tela inclus�o de demandas autom�ticas
oHash:Set('TMSA155',"DA4|DA3|SA2")                  //-- Tela de Recursos
oHash:Set('TMSA157',"DA4|DA3")                      //-- Tela que sera exibida para a alteracao dos campos e DA3_GSTDMD e DA3_FILATU
oHash:Set('TMSA190',"SA1")                          //-- Manifesto da carga
oHash:Set('TMSA200B',"SA1")                         //-- Preview do frete a receber   
oHash:Set('TMSA240',"DA4|DT5|DUM|DT6|DY4|DTC")      //-- Complemento da Viagem
oHash:Set('TMSA250',"DTY|SA2|DTR|DA3|SE5|SEF|SE2")  //-- Contrato de Carreteiro
oHash:Set('TMSA251',"DTY|SA2|DTR|SE2")              //-- Libera��o Contrato de Carreteiro
oHash:Set('TMSA310',"SA1")                          //-- Fechamento da Viagem
oHash:Set('TMSA320',"SA2")                          //-- Gera��o AWB
oHash:Set('TMSA340',"SA1|DUE")	                    //-- Encerramento da Viagem
oHash:Set('TMSA430',"DA4")                          //-- Movimento Veiculos
oHash:Set('TMSA440',"SA1")                          //-- Cadastro de Solicitante
oHash:Set('TMSA450',"SA1")                          //-- Cadastro de Sequencia de Endereco
oHash:Set('TMSA460',"SA1")	                        //-- Solicita��o de Coleta
oHash:Set('TMSA491',"SA1")	                        //-- Gera��o Fatura Automatica
oHash:Set('TMSA500',"SA1")                          //-- Manuten��o de Documentos
oHash:Set('TMSA590',"SA1")                          //-- Enderecamento por documento de transporte 
oHash:Set('TMSA670',"SA1")	                        //-- C�pia Ajustes
oHash:Set('TMSA680',"SA1|DVC")                      //-- Exclusao de ajustes
oHash:Set('TMSA750',"SA1")                          //-- Reajuste de Precos por Cliente.   
oHash:Set('TMSA780',"SA1")                          //-- Transfer�ncia de Endere�os
oHash:Set('TMSA850',"SA1|DT6")                      //-- Gera��o Fatura a Receber
oHash:Set('TMSA854',"SA1")                          //-- Seleciona Documentos Aleatorios para Faturamento
oHash:Set('TMSA890',"SA1")                          //-- Incluir solicitacoes de transferencia de debito  
oHash:Set('TMSA960',"SA1")                          //-- Simulado Clientes
oHash:Set('TMSA980',"SA1")                          //-- Clientes preservados
oHash:Set('TMSA990',"SA1")                          //-- Encerramento de contrato de clientes sem movimento 
oHash:Set('TMSAD30',"DD2")                          //-- Cadastro de Documentos Exigidos X Motoristas   
oHash:Set('TMSAD40',"DD5|DD6")                      //-- Manutencao de Documentos Exigidos X Fornecedores / Motoristas
oHash:Set('TMSAE45A',"DEB")                         //-- Painel Pre-Fatura
oHash:Set('TMSAF05',"SA1")                          //-- Agendamento
oHash:Set('TMSAF11',"SA1")                          //-- Tela de Distancia entre clientes
oHash:Set('TMSAF12',"SA1")                          //-- Tela de Roteiro da Viagem
oHash:Set('TMSAF15',"DA4")                          //-- Retirada de Reboques
oHash:Set('TMSAF74',"DF0|DF1")                      //-- Tela De Preview Da Inclus�o De Agendamentos MRP
oHash:Set('TMSAF76',"SA1")                          //-- Painel de Agendamento
oHash:Set('TMSAF79',"DF1")                          //-- Mais de Um pagador de Frete           
oHash:Set('TMSAI45',"SA1")                          //-- Geracao MIC/DTA     
oHash:Set('TMSAI50',"DIE|SA2")                      //-- Permisso por veiculo 
oHash:Set('TMSAO45',"SA2|SA1")                      //-- Rentabilidade Pr�via
oHash:Set('TMSAR05',"SA1")                          //-- Redespachante X Documentos
oHash:Set('TMSAW10',"SA1")                          //-- Proposta Comercial - Wizard
oHash:Set('TMSC030',"DT6")                          //-- Consulta Documentos Complementares
oHash:Set('TMSC070',"DA4")                          //-- Consulta km de Entrada e Saida dos Veiculos/Motorista  
oHash:Set('TMSC080',"SA1")                          //-- Consulta de documentos
oHash:Set('TMSR070',"DUE")                          //-- Emissao da Relacao do Cadastro de Solicitantes  
oHash:Set('TMSR080',"DUE|DUL")                      //-- Emissao da Relacao dos Enderecos do Solicitante   
oHash:Set('TMSR110',"DTY|SA2|DA4")                  //-- Emissao da Relacao de Contratos Emitidos
oHash:Set('TMSR120',"DUE")                          //-- Imprime a relacao das coletas nao efetuadas por ocorrencia
oHash:Set('TMSR147',"DA4")                          //-- Romaneio de Entrega
oHash:Set('TMSR260',"DA4|DUP")                      //-- Imprime relacao de motoristas (telerisco).
oHash:Set('TMSR280',"DA3|DUP")                      //-- Relacao de Viagens
oHash:Set('TMSR290',"DUE|DT5|DT6")                  //-- Relacao de Coletas por Rota 
oHash:Set('TMSR330',"DA3|DA4|DUP")                  //-- Posicao de Veiculos
oHash:Set('TMSR340',"DT6|DA3|DA4|DTC|DUP")          //-- Relacao de Entregas sem Ocorrencia   
oHash:Set('TMSR360',"SA1")                          //-- Relacao de Entregas sem Ocorrencia    
oHash:Set('TMSR370',"SA1")                          //-- Imprime a Relacao Datas de Entrega em Aberto  
oHash:Set('TMSR390',"DT6|SA1")                      //-- Imprime a relacao das ocorrencias. 
oHash:Set('TMSR400',"SA2|DTY|DA3")                  //-- Contas Corrente Carreteiro
oHash:Set('TMSR430',"SA2|DTY")                      //-- Relacao de Retencao de ISS 
oHash:Set('TMSR450',"DA3|SA2|DTC|DT5")              //-- Rentabilidade x km rodado
oHash:Set('TMSR410',"SA1")                          //-- Relatorio Programacao Diaria  
oHash:Set('TMSR440',"SA1")                          //-- Comparativo de Rentabilidade de Viagem   
oHash:Set('TMSR500',"SA1")                          //-- Emissao da Relacao de Agrupamento de Clientes  
oHash:Set('TMSR510',"SA1")                          //-- Emissao Simulado por Filial de Negociacao e Cliente  
oHash:Set('TMSR511',"SA1")                          //-- Emissao Simulado Resumo de Cliente     
oHash:Set('TMSR512',"SA1")                          //-- Emissao Simulado Composicao por Faixa   
oHash:Set('TMSR513',"SA1")                          //-- Emissao Simulado Filial Negociacao e UF Calculo  
oHash:Set('TMSR520',"SA1")                          //-- Relatorio de Clientes Preservados  
oHash:Set('TMSR530',"DA3|SA2")                      //-- Movimento de Custo de Transporte   
oHash:Set('TMSR541',"SA1")                          //-- Relacao de Conciliacao de Sobras e Faltas 
oHash:Set('TMSR560',"SA1")                          //-- Impressao do Romaneio de Entrega  
oHash:Set('TMSR570',"DUE")                          //-- Impressao do Romaneio de Coleta   
oHash:Set('TMSR580',"DUE|DUL")                      //-- Impressao da Ordem de Coleta 
oHash:Set('TMSR590',"SA1")                          //-- Impressao do Manifesto de Carga  
oHash:Set('TMSR600',"DTY|SA2")                      //-- Impressao do Contrato de Carreteiro por Periodo  
oHash:Set('TMSR610',"SA1")                          //-- Impressao da Relacao de Agendamentos               
oHash:Set('TMSR640',"SA1|DA4")                      //-- Impressao de produtos perigosos
oHash:Set('TMSR645',"SA1")                          //-- Impressao do Picking List de Carregamento
oHash:Set('TMSR650',"SA1|DRT|DTR|SE1")              //-- Realiza a impress�o de faturas
oHash:Set('TMSRB10',"DA4")                          //-- Recibo Controle de di�rias
oHash:Set('TMSRB11',"DA4")                          //-- Relat�rio Controle de di�rias.
oHash:Set('TMSRD10',"SA2|DD1|DD3")                  //-- Impressao de Documentos Exigidos X Fornecedores 
oHash:Set('TMSRD20',"SA2|DD4")                      //-- Impressao de Documentos Exigidos X Motoristas 
oHash:Set('TMSRD30',"SA2|DD1")                      //-- Impressao de Fornecedores X Periodo de Atividade/Inatividade
oHash:Set('TMSRD40',"DA3|DA4")                      //-- Impressao da Carta de Autorizacao de Veiculos
oHash:Set('TMSRE10',"SA1")                          //-- EDI - Relatorio de divergencias de valores de componentes
oHash:Set('TMSRF50',"SA1")                          //-- Analise de Rentabilidade por Cliente 
oHash:Set('TMSRO41',"DA4")                          //-- Relat�rio de Apontamentos de Justificativas          
oHash:Set('TMSRO42',"DA4")                          //-- Relat�rio de Apontamento de Jornada
oHash:Set('TMSRO43',"DA4")                          //-- Relat�rio Saldo de Horas Motorista
oHash:Set('TMSRR05',"SA1|SA2|DFV|DT6")              //-- Romaneio de entrega por redespachante	
oHash:Set('TMSRR10',"SA2|DFV|DY4|DUA|SA1")          //-- Mercadoria em poder de redespachante
oHash:Set('TMSXFUNB',"SA1")                         //-- Fun��es Gen�ricas TMS
oHash:Set('TMSXFUNC',"SA2|SRA|SA1")                 //-- Fun��es Gen�ricas TMS

return oHash

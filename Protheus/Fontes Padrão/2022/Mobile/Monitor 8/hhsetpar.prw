#INCLUDE "hhsetparam.ch"
#INCLUDE "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SFAllPar ³ Autor ³ Liber De Esteban      ³ Data ³ 17/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta um array contendo todos os parametros do SFA         ³±±
±±³          ³ Essa mesma fun‡ao ira retornar os arrays para as rotinas   ³±±
±±³          ³ de auditor, wizard e exporta‡ao de parametros              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nParam: Define o tipo do retorno, podendo ser:              ³±±
±±³          ³       0 - Todos os Parametros (Default)                    ³±±
±±³          ³       1 - Parametros Retaguarda                            ³±±
±±³          ³       2 - Parametros Aplicação                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aParam: Array com os parametro no seguinte formato:         ³±±
±±³          ³       {Nome_par,Desc_par,Default_par,Tipo_par}             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SFAllPar(nParam,aParam)

DEFAULT nParam := 0
DEFAULT aParam := {}

//Definicao dos Parametros
If nParam == 0 .Or. nParam == 1
	aadd(aParam,{"MV_CRIASCR"	,STR0001,"1"				,"C"}) //"Indica se o script deve ser recriado apos o JOB (0=Nao gera;1=Gera quando nao encontrar;2=Sempre Gera)"
	aadd(aParam,{"MV_SFDSC5"	,STR0003,"180"				,"N"}) //"Define quantidade de dias retroativos para filtro de exportacao de pedidos"
	aadd(aParam,{"MV_QTPEDPM"	,STR0004,"1"				,"N"}) //"Define quantidade de pedidos por cliente a serem exportados para o SFA"
	aadd(aParam,{"MV_PLMTPPR"	,STR0005,"PA"				,"C"}) //"Define o tipo de produto (B1_TIPO) a ser filtrado na exportacao de produtos para o SFA"
	aadd(aParam,{"MV_SFCPOPR"	,STR0006,"B1_TIPO"			,"C"}) //"Define campo para filtro no SB1. Substituindo o campo B1_TIPO no filtro feito com o parametro MV_PLMTPPR"
	aadd(aParam,{"MV_SFB1BLQ"	,STR0007,"S"				,"C"}) //"Define se os produtos bloqueados devem ser exportados para o SFA. (S=Exporta;N=Não exporta)"
	aadd(aParam,{"MV_SFA1BLQ"	,STR0008,"S"				,"C"}) //"Define se os clientes bloqueados devem ser exportados para o SFA. (S=Exporta;N=Não exporta)"
	aadd(aParam,{"MV_TBLMSG"	,STR0009,""					,"C"}) //"Define a tabela de mensagens"
	aadd(aParam,{"MV_HHCONS"	,STR0010,"F"				,"C"}) //"Indica se sera utilizado o servico de geracao de consumo. (T=Utiliza;F=Não Utiliza)"
	aadd(aParam,{"MV_HHMAIL"	,STR0011,"1"				,"N"}) //"Define a opcao do servico de e-mail.(1=Nao Envia;2=Envia quando ocorrer erro;3=Sempre Envia)"
	aadd(aParam,{"MV_HHMAIL2"	,STR0012,""					,"C"}) //"Define e-mail de administrador para copiar os informativos de sincronizacao"
	aadd(aParam,{"MV_HHADMIN"	,STR0013,""					,"C"}) //"Define e-mail de administrador para copiar os emails com informativos de erro"
	aadd(aParam,{"MV_PLLCEST"	,STR0014,"T"				,"C"}) //"Indica saldo do local padrao ou todos os locais(T=Todos;P=Local Padrao)"
	aadd(aParam,{"MV_HHVRJOB"	,STR0015,"S"				,"C"}) //"Define a utilizacao dos avisos de status no monitor Mobile (S=Utiliza, N=Nao Utiliza)"
	aadd(aParam,{"MV_HHSRGEN"	,STR0016,""					,"C"}) //"Ativa tratamento para processar serviços genericos somente 1 vez por dia, através do JOB (Em branco=desativa)"
	aadd(aParam,{"MV_HHGENEX"	,STR0017,""					,"C"}) //"Define tabelas genericas que devem ser atualizadas em toda execução de JOB, ignorando o parametro MV_HHSRGEN"
	aadd(aParam,{"MV_SFSTAR"	,STR0018,"F"				,"L"}) //"Define a utilização do status intermediario R, assumido quando o pedido passar para rotina automatica"
	aadd(aParam,{"MV_HHDTSC5"	,STR0019,"F"				,"L"}) //"Se configurado com .T. ira trocar a data de emissao do pedido pela data de entrada no Protheus"
	aadd(aParam,{"MV_HHSUFIX"	,STR0020,"N"				,"C"}) //"Indica se o usuário ira determinar o sufixo das tabelas do SFA (S=Sim, N=Nao)"
    aadd(aParam,{"MV_MCSDIR"	,STR0021,"C:\MCS\"			,"C"}) //"Define o diretório em que está instalado o MCS Server"
    aadd(aParam,{"MV_MCSSCR"	,STR0022,""					,"C"}) //"Define o nome do arquivo de script (se informado em branco, o nome sera montado com cFil+cEmp+cCodVend)"
    aadd(aParam,{"MV_MSCRUSR"	,STR0023,"S"				,"C"}) //"Indica se deve ser criado um arquivo de script para cada usuário (S=Sim,N=Nao)"
    aadd(aParam,{"MV_MCSCON"	,STR0024,"ODBC"				,"C"}) //"Define o tipo de conexão utilizada pelo MCS. (DBASE, ODBC, TOPCONN)"
	aadd(aParam,{"MV_MCSDSN"	,STR0025,"SFA,siga,siga"	,"C"}) //"Define as variaveis de acesso a fonte de dados ODBC, no seguinte formato: Nome da Fonte, Usuario, Senha"
	aadd(aParam,{"MV_SFANTRG"	,STR0026,""					,"C"}) //"Define as tabelas para as quais não deve ser executado gatilho (separar com /), caso gatilhos estejam ativos"
    aadd(aParam,{"MV_RELSERV"	,STR0027,""					,"C"}) //"Servidor SMTP para envio de e-mails"
    aadd(aParam,{"MV_RELACNT"	,STR0028,""					,"C"}) //"Define o e-mail que será utilizado no envio"
    aadd(aParam,{"MV_RELPSW"	,STR0029,""					,"C"}) //"Define a senha que será utilizada para envio de e-mails"
	//aadd(aParam,{"MV_DELHC5X"	,"Indica se os registros devem ser deletados do HC5/HC6 quando encontrado com status X (apos serem importados)"	,"T"				,"L"})
	//aadd(aParam,{"MV_HHOPT"	,"Indica se deve processar serviços de exportação utilizando query"										   		,"T"				,"L"})
	//aadd(aParam,{"MV_MCSIP"	,"Define o IP do MCS Server"																			  		,""					,"C"})
    //aadd(aParam,{"MV_MCSPRT"	,"Define o  do MCS Server"																				  		,""					,"C"})
    //aadd(aParam,{"MV_MCSTO"	,"Define o  do MCS Server"																				  		,""					,"C"})

EndIf

If nParam == 0 .Or. nParam == 2
    aadd(aParam,{"MV_DTSYNC"	,STR0030,"0"				,"C"}) //"Parametro que determina a quantidade maxima de dias sem sincronismo"
    aadd(aParam,{"MV_SFLDDES"	,STR0031,"T"				,"C"}) //"Indica uso do folder de desconto (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_SFBLPED"	,STR0032,"F"				,"C"}) //"Indica se usa bloqueio de pedido no SFA (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_SFAIND"	,STR0033,"F"				,"C"}) //"Indica se utiliza ou nao indenizacao (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_SFAFRE"	,STR0034,"F"				,"C"}) //"Indica se o Tipo de Frete sera informado (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_SFAMTES"	,STR0035,"N"				,"C"}) //"Indice se o vendedor tem permissao para manipular a TES (S=Permite,N=Nao Permite)"
    aadd(aParam,{"MV_BLOQPRC"	,STR0036,"1"				,"C"}) //"Indica se o preco podera ser alterado (1=Bloqueia,2=Libera somente para acrescimo,3=Libera Preço)"
    aadd(aParam,{"MV_SFAFPG"	,STR0037,"F"				,"C"}) //"Indica se utiliza Forma de Pagamento no SFA (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_SFAMDTE"	,STR0038,"S"				,"C"}) //"Indica se permite ao vendedor manipular a data de entrega do pedido (S=Permite,N=Nao Permite)"
    aadd(aParam,{"MV_SFAPESO"	,STR0039,"F"				,"C"}) //"Indica o uso do campo 'Peso' no cabecalho/item do pedido (T=Utiliza,F=Nao Utiliza)"
    aadd(aParam,{"MV_BLOQDSC"	,STR0040,"N"				,"C"}) //"Indica se o o campo de desconto estara bloqueado para o vendedor (S=Bloqueia,N=Nao Bloqueia)"
    aadd(aParam,{"MV_SFAPRSI"	,STR0041,"N"				,"C"}) //"Define a utilização da consulta de produtos similares (S=Utiliza,N=Nao Utiliza)"
    aadd(aParam,{"MV_SFAVIEW"	,STR0042,"C"				,"C"}) //"View da Visita de Negocios (C = Cliente, R = Roteiro)"
    aadd(aParam,{"MV_SFTPTIT"	,STR0043,"NCC"				,"C"}) //"Define os tipos de titulos desconsiderados na verificação de Débitos"
	aadd(aParam,{"MV_SFABLOQ"	,STR0044,"1"				,"C"}) //"Indica se deve prosseguir se não passar pelo avaliação de limite de credito. 1-Libera,2-Bloqueia,3-Pergunta"
    aadd(aParam,{"MV_SFCADCN"	,STR0045,"1"				,"C"}) //"Indice se o vendedor tem permissao para cadastrar contatos (1=Completo; 2=Alteracao; 3= Apenas Consulta)"
    aadd(aParam,{"MV_SFCADCL"	,STR0046,"1"				,"C"}) //"Parametro para restricoes no cadastro de clientes (1=Completo; 2=Alteracao; 3= Apenas Consulta)"
    aadd(aParam,{"MV_SFNREDU"	,STR0047,"N"				,"C"}) //"Indica se deve exibir o nome do cliente por Nome Fantasia (T=Usa Nome Fantasia,F=Usa Nome)"
    aadd(aParam,{"MV_SFATPRO"	,STR0048,"1"				,"C"}) //"Define a tela de consulta de produto (1=Tela Padrao,2=Tela Simplificada-sem grupo)"
    aadd(aParam,{"MV_SEMPREC"	,STR0049,"N"				,"C"}) //"Permite ou nao ao vendedor digitar o preco quando nao houver (S=Permite,N=Nao Permite)"
    aadd(aParam,{"MV_PLVLEST"	,STR0050,"T"				,"C"}) //"Indica se mostra a quantidade de produto em estoque ou se o produto não está disponível(T=Mostra quantidade)"
    aadd(aParam,{"MV_SFAMSG"	,STR0051,"F"				,"C"}) //"Define a utilização do cadastro de mensagens na abertura do sistema (T=Inicia Mensagens,F=Utiliza Aviso)"
    aadd(aParam,{"MV_SFPAGIN"	,STR0052,"50"				,"C"}) //"Define o numero de produtos a serem carregados na tela 2 de produtos"
    aadd(aParam,{"MV_PRODUPL"	,STR0053,"F"				,"C"}) //"Indica a possibilidade da repeticao de um produto em um pedido (T=Permite,F=Nao Permite)"
    aadd(aParam,{"MV_SFAQTDE"	,STR0054,"T"				,"C"}) //"Indica utilizacao de decimais no campo Quantidade do Pedido de Venda (T=Permite,F=Nao Permite)"
    aadd(aParam,{"MV_SFPROR"	,STR0055,"1"				,"C"}) //"Define a ordem padrao para pesquisa de produtos na Tela 2 de pedido"
    aadd(aParam,{"MV_SFFTCON"	,STR0056,"F"				,"C"}) //"Habilita a validação de quantidade do produto (Para conversão)"
    aadd(aParam,{"MV_VALMIN"	,STR0057,"0.00"		   		,"C"}) //"Define a utilização de valor minimo de emissao de pedido"
    aadd(aParam,{"MV_BONUSTS"	,STR0058,"502"				,"C"}) //"Parametro do Mod. Faturamento, o Tes do Item de Bonificacao"
    aadd(aParam,{"MV_SFPROPR"	,STR0059,""					,"C"}) //"Prefixo de Busca do Produto (<Prefixo>, <Vezes>, <Tamanho>)"
    aadd(aParam,{"MV_SFAPLC"	,STR0060,"9999"		  		,"C"}) //"Limite de Credito. Utilizado para Clientes cadastrados no SFA"
    aadd(aParam,{"MV_SFVLDIE"	,STR0061,"F"				,"C"}) //"Obriga a digitação da IE no cadastro de cliente."
    aadd(aParam,{"MV_SFBLOQH"	,STR0062,"N"				,"C"}) //"Indica se deve bloquear o acesso ao historico de fechamento do dia. (S=Bloqueia,N=Libera)"
    aadd(aParam,{"MV_PRINTER"	,STR0063,"1"				,"C"}) //"Define qua a impressora utilizada (1=Sipix, 2=Monarch)"
    aadd(aParam,{"MV_SFACPRF"	,STR0064,"N"				,"C"}) //"Define a utilização da consulta de produtos pelo código do produto no fabricante (S=Habilita,N=Desabilita)"
    aadd(aParam,{"MV_SFBRMIN"	,STR0065,"1"				,"C"}) //"Define se o browse de produtos exibira as descricoes em letras minusculas (1=Maiuscula,2=Minuscula)"
    aadd(aParam,{"MV_SFCONDI"	,STR0066,"F"				,"C"}) //"T = A condição sera determinada pela regra de negocio. F = A Regra de Negocio sera validada na confirmacao"
    aadd(aParam,{"MV_SFACFG"	,STR0118,"2"				,"C"}) //"Indica o uso da opcao Config no menu do SFA (1=Utiliza, 2=Nao Utiliza)"
	aadd(aParam,{"MV_SFBLTBP"	,STR0119,"N"				,"C"}) //"Indica se a tabela de preço do pedido de venda será bloqueada para açteracao (S = Bloqueia, N = Libera)"
	aadd(aParam,{"MV_VALCPF"	,STR0121,"N"				,"C"}) //"Define validacao do CPF (1=Informa se o CPF ja esta sendo utilizado e permite inclusao, 2=Nao inclui CPFs duplicados)"
	aadd(aParam,{"MV_VALCNPJ"	,STR0122,"N"				,"C"}) //"Define validacao do CNPJ (1=Informa se o CNPJ ja esta sendo utilizado e permite inclusao, 2=Nao inclui CNPJs duplicados)"
	aadd(aParam,{"MV_SFASENH"	,STR0124,"F"				,"C"}) //"Desabilita a utilizacao da tela inicial de senha (T/F))" 
	aadd(aParam,{"MV_SFABONU"	,STR0125,"F"				,"C"}) //"Limita valores associados a bonificação nos resultados do Resumo do Dia (Fechamento do Dia )? (T/F))" 
	aadd(aParam,{"MV_SFTROCA"	,STR0126,""             	,"C"}) //"TES utilizado para identificar pedidos de troca de mercadoria no SFA que não serão considerados no Fechamento do Dia." 
    //aadd(aParam,{"MV_SFAPEGR"	,"Define a utilização da pesquisa por grupo na tela 2 do pedido"												,"S"				,"C"})
    //aadd(aParam,{"MV_SFACON"	,"Define as configurações para automação da conexão durante o sincronismo, devendo-se preencher o parâmentro da seguinte forma Nome da con,Usuário,Senha(separados por virgula).
    //aadd(aParam,{"MV_SFAVPN"	,"Define as configurações para automação da conexão durante o sincronismo(quando for necessário conexão VPN), devendo-se preencher o parâmentro da seguinte forma Nome da con,Usuário,Senha(separados por virgula).	
    //aadd(aParam,{"MV_RISCOB"	,"Indica o valor maximo de duplicatas em atrase que um cliente do risco B pode ter para que seja possivel emitir um pedido para esse cliente	0
    //aadd(aParam,{"MV_RISCOC"	,"Indica o valor maximo de duplicatas em atrase que um cliente do risco C pode ter para que seja possivel emitir um pedido para esse cliente	0
    //aadd(aParam,{"MV_RISCOD"	,"Indica o valor maximo de duplicatas em atrase que um cliente do risco D pode ter para que seja possivel emitir um pedido para esse cliente	0
    //aadd(aParam,{"MV_SFATPED"	,"Define a tela pedido de venda	"1"
    //aadd(aParam,{"MV_SFADEB"	,"Indica como será feita a verificação do limite de crédito	
    //aadd(aParam,{"MV_SFADRT"	,"Parametro para opcao DirtyTable	"2"

EndIf

Return (aParam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SFAllServ ³ Autor ³ Liber De Esteban      ³ Data ³ 17/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta um array contendo todos os serviços e tabelas do SFA ³±±
±±³          ³ Essa mesma fun‡ao ira retornar os arrays para as rotinas   ³±±
±±³          ³ de auditor, wizard e CFGX061a                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet: Array contendo os arrays dos cadastros do HHTRG:      ³±±
±±³          ³       {aIniSys,aIniServ,aIniTbl,aTblSrv}                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SFAllServ(aAllServ)

Local aIniSys	 := {}
Local aIniTbl	 := {}
Local aIniServ	 := {}
Local aTblSrv	 := {}

DEFAULT aAllServ := {}

//Tabela de sistemas
aAdd(aIniSys, {"000001", STR0067, "SA3"}) //"Sales Force Automation - SFA"
aAdd(aIniSys, {"000002", STR0068, "SA3"}) //"Fast Delivery Automation - FDA"
aAdd(aIniSys, {"000003", STR0069, "AA1"}) //"Technical Force Automation - TFA"

//Tabela de Servicos
//Tabela de servicos x tabelas
aAdd(aIniServ, {"000000",STR0070, "HHEXPSM0", "SM0", "HM0", "2", "1",.T.,.F.}) //"Empresa"
aAdd(aTblSrv , {"000000","000000"})

aAdd(aIniServ, {"000001",STR0071, "HHEXPSA3", "SA3", "HA3", "2", "1",.T.,.F.}) //"Vendedor"
aAdd(aTblSrv , {"000001","000001"})	
aAdd(aTblSrv , {"000001","000002"})

aAdd(aIniServ, {"000002",STR0072, "HHEXPAD7", "AD7,SA1", "HRT,HD7", "2", "1",.F.,.T.}) //"Rotas"
aAdd(aTblSrv , {"000002","000003"})
aAdd(aTblSrv , {"000002","000004"})

aAdd(aIniServ, {"000003",STR0073, "HHEXPSA1", "SA1", "HA1", "2", "1",.T.,.F.}) //"Clientes"
aAdd(aTblSrv , {"000003","000005"})
aAdd(aTblSrv , {"000003","000006"})
aAdd(aTblSrv , {"000003","000007"})
aAdd(aTblSrv , {"000003","000008"})
aAdd(aTblSrv , {"000003","000009"})
aAdd(aTblSrv , {"000003","000010"})	

aAdd(aIniServ, {"000004",STR0074, "HHEXPSB1", "SB1", "HB1", "2", "1",.T.,.F.}) //"Produtos"
aAdd(aTblSrv , {"000004","000011"})
aAdd(aTblSrv , {"000004","000012"})
aAdd(aTblSrv , {"000004","000013"})
aAdd(aTblSrv , {"000004","000014"})
aAdd(aTblSrv , {"000004","000015"})

aAdd(aIniServ, {"000005",STR0075, "HHEXPSA4", "SA4", "HA4", "2", "1",.F.,.T.}) //"Transportadoras"
aAdd(aTblSrv , {"000005","000016"})

aAdd(aIniServ, {"000006",STR0076, "HHEXPSE4", "SE4", "HE4", "2", "1",.T.,.F.}) //"Condições de Pagamento"
aAdd(aTblSrv , {"000006","000017"})
aAdd(aTblSrv , {"000006","000018"})
aAdd(aTblSrv , {"000006","000019"})

aAdd(aIniServ, {"000007",STR0077, "HHEXPSC5", "SC5,SC6", "HC5,HC6", "2", "1",.T.,.F.}) //"Pedidos de Venda"
aAdd(aTblSrv , {"000007","000020"})
aAdd(aTblSrv , {"000007","000021"})
aAdd(aTblSrv , {"000007","000022"})

aAdd(aIniServ, {"000008",STR0078, "XEXPHCF", "", "HCF,HX5", "2", "1",.T.,.F.}) //"Configurações"
aAdd(aTblSrv , {"000008","000030"})
aAdd(aTblSrv , {"000008","000031"})

aAdd(aIniServ, {"000009",STR0079, "XEXPHMV", GetMv("MV_TBLMSG",,""), "HMV", "2", "1",.F.,.T.}) //"Mensagens"
aAdd(aTblSrv , {"000009","000032"})

aAdd(aIniServ, {"000010",STR0080, "HHIMPHA1", "SA1,SU5,AC8","", "1", "1",.F.,.T.}) //"Importação de Clientes"
aAdd(aTblSrv , {"000010","000005"})

aAdd(aIniServ, {"000011",STR0081, "HHIMPHC5", "SA1,SC5,SC6,SC9,SB1,SF2,AD5" ,"", "1", "1",.T.,.F.}) //"Importação de Pedidos de Venda"
aAdd(aTblSrv , {"000011","000020"})
aAdd(aTblSrv , {"000011","000021"})

aAdd(aIniServ, {"000012",STR0082, "HHIMPHU5", "SA1,SU5,AC8" , "", "1", "1",.F.,.T.}) //"Importação de Contatos"
aAdd(aTblSrv , {"000012","000006"})

aAdd(aIniServ, {"000013",STR0083, "HHIMPHMV", GetMv("MV_TBLMSG",,""),"", "1", "1",.F.,.T.}) //"Importação de Mensagens"
aAdd(aTblSrv , {"000013","000032"})	

aAdd(aIniServ, {"000014","TES", "HHEXPSF4", "SF4" , "HF4", "2", "1",.T.,.F.})
aAdd(aTblSrv , {"000014","000018"}) 

aAdd(aIniServ, {"000015",STR0084, "HHEXPSBM", "SBM" , "HBM", "2", "1",.T.,.F.}) //"Grupo de Produtos"
aAdd(aTblSrv , {"000015","000011"}) 

aAdd(aIniServ, {"000016",STR0085, "HHEXPSB2", "SB1,SB2" , "HB1,HB2", "2", "1",.F.,.T.}) //"Estoque de Produtos"
aAdd(aTblSrv , {"000016","000012"}) 
aAdd(aTblSrv , {"000016","000015"})

aAdd(aIniServ, {"000017",STR0086, "HHEXPDA0", "DA0,DA1" , "HTC,HPR", "2", "1",.T.,.F.}) //"Tabela de preços"
aAdd(aTblSrv , {"000017","000013"}) 
aAdd(aTblSrv , {"000017","000014"})

aAdd(aIniServ, {"000018",STR0087, "HHEXPSE1", "SE1" , "HE1", "2", "1",.F.,.T.}) //"Duplicatas"
aAdd(aTblSrv , {"000018","000007"})

aAdd(aIniServ, {"000019",STR0088, "HHEXPSX5", "SX5" , "HTP", "2", "1",.F.,.T.}) //"Tipos de Pagamento"
aAdd(aTblSrv , {"000019","000019"}) 
	 		
aAdd(aIniServ, {"000020",STR0089, "HHEXPACO", "ACO,ACP" , "HCO,HCP", "2", "1",.F.,.T.}) //"Regras de Descontos"
aAdd(aTblSrv , {"000020","000024"})
aAdd(aTblSrv , {"000020","000025"})	

aAdd(aIniServ, {"000021",STR0090, "HHEXPACQ", "ACQ,ACR" , "HCQ,HCR", "2", "1",.F.,.T.}) //"Regras de Bonificacoes"
aAdd(aTblSrv , {"000021","000026"})
aAdd(aTblSrv , {"000021","000027"}) 

aAdd(aIniServ, {"000022",STR0091, "HHEXPACS", "ACS,ACT" , "HCS,HCT", "2", "1",.F.,.T.}) //"Regras de Negocios"
aAdd(aTblSrv , {"000022","000028"}) 
aAdd(aTblSrv , {"000022","000029"})	

aAdd(aIniServ, {"000023",STR0092, "HHEXPSA5", "SA5" , "HA5", "2", "1",.F.,.T.}) //"Forn x Prod"
aAdd(aTblSrv , {"000023","000036"}) 

aAdd(aIniServ, {"000024",STR0093, "HHEXPACU", "ACU,ACV" , "HCU,HCV", "2", "1",.F.,.T.}) //"Categorias"
aAdd(aTblSrv , {"000024","000037"}) 
aAdd(aTblSrv , {"000024","000038"})	

aAdd(aIniServ, {"000025",STR0094, "HHEXPSU5", "SA1,AC8,SU5" , "HU5", "2", "1",.F.,.T.}) //"Contatos"
aAdd(aTblSrv , {"000025","000006"})

aAdd(aIniServ, {"000026",STR0095, "HHIMPHD5", "AD5" , "HD5", "1", "1",.F.,.T.}) //"Importação de Apontamentos"
aAdd(aTblSrv , {"000026","000022"})

aAdd(aIniServ, {"000027",STR0096, "XEXPHCN", "SF2" , "HCN", "2", "1",.F.,.T.}) //"Consumo"
aAdd(aTblSrv , {"000027","000008"})

aAdd(aIniServ, {"000028",STR0097, "HHEXPSCT", "SCT" , "HMT", "2", "1",.F.,.T.}) //"Metas"
aAdd(aTblSrv , {"000028","000002"})

//Tabela de tabelas
aAdd(aIniTbl, {"000000",STR0070		,"HM0"		,"2",  "F",""			, 0, "T"}) //"Empresa"
aAdd(aIniTbl, {"000001",STR0071		,"HA3"		,"2",  "F","A3_COD"		, 0, "F","SA3"}) //"Vendedor"
aAdd(aIniTbl, {"000002",STR0097		,"HMT"		,"2",  "F","CT_VEND"	, 0, "F","SCT"}) //"Metas"
aAdd(aIniTbl, {"000003",STR0072		,"HRT"		,"2",  "F","AD7_VEND"	, 0, "F","AD7"}) //"Rotas"
aAdd(aIniTbl, {"000004",STR0098		,"HD7"		,"2",  "F","AD7_VEND"	, 0, "F","AD7"}) //"Roteiro"
aAdd(aIniTbl, {"000005",STR0073		,"HA1"		,"2",  "T","A1_VEND"	, 0, "F","SA1"}) //"Clientes"
aAdd(aIniTbl, {"000006",STR0094		,"HU5"		,"2",  "T","A1_VEND"	, 0, "F","SU5"}) //"Contatos"
aAdd(aIniTbl, {"000007",STR0099		,"HE1"		,"2",  "F","E1_VEND1"	, 0, "F","SE1"}) //"Titulos"
aAdd(aIniTbl, {"000008",STR0096		,"HCN"		,"2",  "F","A3_COD"		, 0, "F","SF2"}) //"Consumo"
aAdd(aIniTbl, {"000009",STR0100		,"HIN"		,"2",  "F",""			, 0, "F"}) //"Inventario"
aAdd(aIniTbl, {"000010",STR0101		,"HAT"		,"2",  "F",""			, 0, "F"}) //"Atendimento"
aAdd(aIniTbl, {"000011",STR0117		,"HBM"		,"1",  "F",""			, 0, "F","SBM"}) // "Grupos"
aAdd(aIniTbl, {"000012",STR0074		,"HB1"		,"1",  "F",""			, 0, "F","SB1"}) //"Produtos"
aAdd(aIniTbl, {"000013",STR0102		,"HTC"		,"1",  "F",""			, 0, "F","DA0"}) //"Cab. Tabela de Preco"
aAdd(aIniTbl, {"000014",STR0103		,"HPR"		,"1",  "F",""			, 0, "F","DA1"}) //"It. Tabela de Preco"
aAdd(aIniTbl, {"000015",STR0085		,"HB2"		,"1",  "F",""			, 0, "F","SB2"}) //"Estoque de Produtos"
aAdd(aIniTbl, {"000016",STR0075		,"HA4"		,"1",  "F",""			, 0, "F","SA4"}) //"Transportadoras"
aAdd(aIniTbl, {"000017",STR0104		,"HE4"		,"1",  "F",""			, 0, "F","SE4"}) //"Condicao"
aAdd(aIniTbl, {"000018","TES"		,"HF4"		,"1",  "F",""			, 0, "F","SF4"}) // TES
aAdd(aIniTbl, {"000019",STR0105		,"HTP"		,"1",  "F",""			, 0, "F"}) //"Tabelas Genericas"
aAdd(aIniTbl, {"000020",STR0106		,"HC5"		,"2",  "T","C5_VEND1"	, 0, "F","SC5"}) //"Cab. Pedidos de Venda"
aAdd(aIniTbl, {"000021",STR0107		,"HC6"		,"2",  "T","C5_VEND1"	, 0, "F","SC6"}) //"It. Pedidos de Venda"
aAdd(aIniTbl, {"000022",STR0108		,"HD5"		,"2",  "T",""			, 0, "F","AD5"}) //"Apontamentos"
aAdd(aIniTbl, {"000023","Ind"		,"IND"		,"2",  "F",""			, 0, "F"})
aAdd(aIniTbl, {"000024",STR0109		,"HCO"		,"1",  "F",""			, 0, "F","ACO"}) //"Cab. Regra de Descontos"
aAdd(aIniTbl, {"000025",STR0110		,"HCP"		,"1",  "F",""			, 0, "F","ACP"}) //"It. Regra de Descontos"
aAdd(aIniTbl, {"000026",STR0111		,"HCQ"		,"1",  "F",""			, 0, "F","ACQ"}) //"Cab. Regra de Bonificacao"
aAdd(aIniTbl, {"000027",STR0112		,"HCR"		,"1",  "F",""			, 0, "F","ACR"}) //"It. Regra de Bonificacao"
aAdd(aIniTbl, {"000028",STR0113		,"HCS"		,"1",  "F",""			, 0, "F","ACS"}) //"Cab. Regra de Negocios"
aAdd(aIniTbl, {"000029",STR0114		,"HCT"		,"1",  "F",""			, 0, "F","SA3"}) //"It. Regra de Negocio"
aAdd(aIniTbl, {"000030",STR0078		,"HCF"		,"1",  "F",""			, 0, "F","ACT"}) //"Configurações"
aAdd(aIniTbl, {"000031",STR0115		,"HX5"		,"1",  "F",""			, 0, "F"}) //"Tabelas"
aAdd(aIniTbl, {"000032",STR0079		,"HMV"		,"2",  "T",""			, 0, "F",GetMv("MV_TBLMSG",,"")}) //"Mensagens"
aAdd(aIniTbl, {"000033","ADV_TBL"	,"ADVTBL"	,"1",  "F",""			, 0, "T"})
aAdd(aIniTbl, {"000034","ADV_IND"	,"ADVIND"	,"1",  "F",""			, 0, "T"})
aAdd(aIniTbl, {"000035","ADV_COLS"	,"ADVCOL"	,"1",  "F",""			, 0, "T"})
aAdd(aIniTbl, {"000036",STR0092		,"HA5"		,"1",  "F",""			, 0, "F","SA5"}) //"Forn x Prod"
aAdd(aIniTbl, {"000037",STR0093		,"HCU"		,"1",  "F",""			, 0, "F","ACU"}) //"Categorias"
aAdd(aIniTbl, {"000038",STR0116		,"HCV"		,"1",  "F",""			, 0, "F","ACV"}) //"Categ x Prod"

aAllServ := {aIniSys,aIniServ,aTblSrv,aIniTbl}

Return aAllServ

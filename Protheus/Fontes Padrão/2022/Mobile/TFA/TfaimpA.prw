#include "Inkey.Ch"
#include "FiveWin.ch"
//#include "AFVM020.CH"
#INCLUDE "Siga.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PImpOS    ºAutor  ³Cleber Martinez     º Data ³  25/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importacao dos apontamentos de OS do Palm                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PImpOS()

Local cOSTec      := ""
Local cOSApo	  := ""
//Local cOSItens    := ""
//Local cOSDesp	  := ""
//Local cOSReq	  := ""	
//Local cProxOS 	  := 0
//Local cEmissao 	  := ""
Local aAA1 := {} // contem os campos do arquivo AA1 (Cad. de Tecnicos)
Local aAB9 := {} // contem os campos do arquivo AB9 (Atendimento de OS)
Local aABA := {} // contem os campos do arquivo ABA (Itens do Atendimento)
Local aABC := {} // contem os campos do arquivo ABC (Despesas)
//Local aABD := {} // contem os campos do arquivo ABD (Pendencias)
Local aABF := {} // contem os campos do arquivo ABF (Requisicoes da OS)
Local aABG := {} // contem os campos do arquivo ABG (Itens Requisicoes)
Local aAB6 := {} // contem os campos do arquivo AB6 (Ord. de Servico)
Local aAB7 := {} // contem os campos do arquivo AB7 (Itens da Ord. de Servico)
Local aABB := {} // contem os campos do arquivo ABB (Agenda)
Local aArquivos := {}
Local cPathPalm := "\handheld\P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
//Local cPath := ""
Local cTecnico :=  PALMUSER->P_CODVEND

Local cFileTec    := "AA1" + cEmpAnt + "0"
Local cFileAponta := "AB9" + cEmpAnt + "0"
Local cFileItens  := "ABA" + cEmpAnt + "0"
Local cFileDesp	  := "ABC" + cEmpAnt + "0"
Local cFileReq	  := "ABF" + cEmpAnt + "0"
Local cFileItReq  := "ABG" + cEmpAnt + "0"
Local cFileOS	  := "AB6" + cEmpAnt + "0"
Local cFileItOS   := "AB7" + cEmpAnt + "0"
Local cFileAge    := "ABB" + cEmpAnt + "0"

//Local aAponta      := {}
//Local aItens       := {}
//Local aDespesas    := {}
//Local aPendencias  := {}
//Local aRequisicoes := {}
//Local aItensReq    := {}
//Local aAgenda      := {}
//Local aOS		   := {}

aAdd(aArquivos, {cFileTec  		, "TEC", "AA1_CODTEC"}) 			// Cod. do tecnico
aAdd(aArquivos, {cFileAponta    , "APO", "AB9_NUMOS"})  			// Numero da OS + Item OS (8)
aAdd(aArquivos, {cFileItens     , "ITS", "ABA_NUMOS+ABA_ITEM"})    // Nr. da OS + Item OS + Item (10)
aAdd(aArquivos, {cFileDesp  	, "DES", "ABC_NUMOS+ABC_ITEM"})  	// Nr. da OS + Item OS + Item despesa (10)
aAdd(aArquivos, {cFileReq   	, "REQ", "ABF_NUMOS+ABF_ITEMOS"})  // Nr. da OS + Item OS (8)
aAdd(aArquivos, {cFileItReq 	, "IRQ", "ABG_NUMOS+ABG_ITEMOS+ABG_ITEM"})  // Nr. da OS + Item OS + Item req. (10)
aAdd(aArquivos, {cFileOS  		, "ORD", "AB6_NUMOS"})  					// Nr. da ord. de serv. (6)
aAdd(aArquivos, {cFileItOS	    , "ITE", "AB7_NUMOS+AB7_ITEM"}) 			// Nr. da OS + Item OS (8)
aAdd(aArquivos, {cFileAge    	, "AGE", "ABB_CODTEC+ABB_NUMOS"}) 			// Cod. do tecnico + Nr. da OS (6+6)

aAdd(aAA1, {"AA1_CODTEC"	, "C", 06, 0}) 
aAdd(aAA1, {"AA1_NOMTEC"	, "C", 30, 0})
aAdd(aAA1, {"AA1_SENHA"		, "C", 04, 0}) //Precisa ser criado
aAdd(aAA1, {"AA1_PROXOS"	, "C", 06, 0}) //Precisa ser criado

aAdd(aAB9, {"AB9_FILIAL"      , "C", 02, 0}) // Filial
aAdd(aAB9, {"AB9_NUMOS"       , "C", 08, 0}) // Nr. da OS + Item OS
aAdd(aAB9, {"AB9_CODTEC"      , "C", 06, 0}) // Cod. do tecnico
aAdd(aAB9, {"AB9_SEQ"         , "C", 03, 0}) // Sequencia
aAdd(aAB9, {"AB9_DTCHEG"      , "D", 08, 0}) // Data de Chegada
aAdd(aAB9, {"AB9_HRCHEG"      , "C", 05, 0}) // Hora de Chegada
aAdd(aAB9, {"AB9_DTSAID"      , "D", 08, 0}) // Data de Saida
aAdd(aAB9, {"AB9_HRSAID"      , "C", 05, 0}) // Hora de Saida
aAdd(aAB9, {"AB9_DTINI"       , "D", 08, 0}) // Data Inicio
aAdd(aAB9, {"AB9_HRINI"       , "C", 05, 0}) // Hora Inicio
aAdd(aAB9, {"AB9_DTFIM"       , "D", 08, 0}) // Data Fim
aAdd(aAB9, {"AB9_HRFIM"       , "C", 05, 0}) // Hora Fim
aAdd(aAB9, {"AB9_TRASLA"      , "C", 05, 0}) // Translado
aAdd(aAB9, {"AB9_CODPRB"      , "C", 06, 0}) // Codigo da Ocor./Prob.
aAdd(aAB9, {"AB9_GARANT"      , "C", 01, 0}) // Garantia
aAdd(aAB9, {"AB9_OBSOL"       , "C", 01, 0}) // Obsolescencia
aAdd(aAB9, {"AB9_ACUMUL"      , "N", 12, 2}) // Acumulador (?)
aAdd(aAB9, {"AB9_TIPO"        , "C", 01, 0}) // Status do atendimento (em aberto/encerrada)
aAdd(aAB9, {"AB9_ATUPRE"      , "C", 01, 0}) // Atualizar preventiva
aAdd(aAB9, {"AB9_ATUOBS"      , "C", 01, 0}) // Atualizar obsolescencia
aAdd(aAB9, {"AB9_NUMSER"      , "C", 20, 0}) // Nr. de serie
aAdd(aAB9, {"AB9_CODCLI"      , "C", 06, 0}) // Cod. do Cliente
aAdd(aAB9, {"AB9_LOJA"        , "C", 02, 0}) // Loja do Cliente
aAdd(aAB9, {"AB9_CODPRO"      , "C", 15, 0}) // Cod. do Produto
aAdd(aAB9, {"AB9_MEMO1"       , "C", 06, 0}) // Laudo
aAdd(aAB9, {"AB9_MEMO2"       , "C", 80, 0}) // Laudo do Tecnico
aAdd(aAB9, {"AB9_TOTFAT"      , "C", 05, 0}) // Horas Faturadas
aAdd(aAB9, {"AB9_NUMORC"      , "C", 06, 0}) // Nr. do Orcamento
aAdd(aAB9, {"AB9_CUSTO"       , "N", 12, 2}) // Custo da mao-de-obra

aAdd(aABA, {"ABA_FILIAL"      , "C", 02, 0}) // Filial
aAdd(aABA, {"ABA_ITEM"        , "C", 02, 0}) // Item 
aAdd(aABA, {"ABA_CODFAB"      , "C", 06, 0}) // Cod. do Fabricante
aAdd(aABA, {"ABA_LOJAFA"      , "C", 02, 0}) // Loja do Fabricante
aAdd(aABA, {"ABA_CODPRO"      , "C", 15, 0}) // Cod. do Produto
aAdd(aABA, {"ABA_NUMSER"      , "C", 20, 0}) // Num. de Serie
aAdd(aABA, {"ABA_QUANT"       , "N", 12, 2}) // Quantidade usada
aAdd(aABA, {"ABA_LOCAL"       , "C", 02, 0}) // Cod. do almoxarifado
aAdd(aABA, {"ABA_LOCALI"      , "C", 15, 0}) // Cod. da localizacao fisica do produto
aAdd(aABA, {"ABA_CODSER"      , "C", 06, 0}) // Cod. do servico
aAdd(aABA, {"ABA_FABANT"      , "C", 06, 0}) // Cod. do fabricante anterior (trocas) 
aAdd(aABA, {"ABA_LOJANT"      , "C", 02, 0}) // Loja do fabric. anterior
aAdd(aABA, {"ABA_ANTPRO"      , "C", 15, 0}) // Cod. do produto anterior
aAdd(aABA, {"ABA_ANTSER"      , "C", 20, 0}) // Nr. de serie do prod. anterior
aAdd(aABA, {"ABA_NUMOS"       , "C", 08, 0}) // Nr. da OS + Item OS
aAdd(aABA, {"ABA_CUSTO"       , "N", 12, 2}) // Custo
aAdd(aABA, {"ABA_CODTEC"      , "C", 06, 0}) // Cod. do tecnico
aAdd(aABA, {"ABA_SEQ"         , "C", 02, 0}) // Sequencia
aAdd(aABA, {"ABA_SUBOS"       , "C", 02, 0}) // Sub-item da OS
aAdd(aABA, {"ABA_DESCRI"      , "C", 30, 0}) // Descr. do produto
aAdd(aABA, {"ABA_LOCALD"      , "C", 02, 0}) // Cod. do almoxarifado destino
aAdd(aABA, {"ABA_LOCLZD"      , "C", 15, 0}) // Localizacao fisica destino
aAdd(aABA, {"ABA_SEQRC"       , "C", 02, 0}) // Seq. da solicitacao ao almoxarifado
aAdd(aABA, {"ABA_ITEMRC"      , "C", 02, 0}) // Item da solicitacao ao almoxarifado

aAdd(aABC, {"ABC_FILIAL"        , "C", 02, 0}) // Filial
aAdd(aABC, {"ABC_NUMOS"         , "C", 08, 0}) // Nr. da OS + Item OS
aAdd(aABC, {"ABC_SUBOS"         , "C", 02, 0}) // Sub-item da OS
aAdd(aABC, {"ABC_CODTEC"        , "C", 06, 0}) // Cod. do tecnico
aAdd(aABC, {"ABC_SEQ"           , "C", 02, 0}) // Seq. do atendimento
aAdd(aABC, {"ABC_ITEM"          , "C", 02, 0}) // Item da despesa 
aAdd(aABC, {"ABC_CODPRO"        , "C", 15, 0}) // Cod. do produto
aAdd(aABC, {"ABC_DESCRI"        , "C", 30, 0}) // Descr. do produto
aAdd(aABC, {"ABC_QUANT"         , "N", 12, 0}) // Quantidade
aAdd(aABC, {"ABC_VLUNIT"        , "N", 12, 2}) // Valor unit. da despesa
aAdd(aABC, {"ABC_VALOR"         , "N", 12, 2}) // Valor total da despesa
aAdd(aABC, {"ABC_CODSER"        , "C", 06, 0}) // Cod. de servico
aAdd(aABC, {"ABC_CUSTO"         , "N", 12, 2}) // Custo da despesa financeira de atendimento

/*
aAdd(aABD, {"ABD_FILIAL"        , "C", 02, 0}) // Filial
aAdd(aABD, {"ABD_CODPRO"        , "C", 06, 0}) // Codigo do produto
aAdd(aABD, {"ABD_NUMSER"        , "C", 20, 0}) // Nr. de Serie
aAdd(aABD, {"ABD_STATUS"        , "C", 01, 0}) // Status da pendencia
aAdd(aABD, {"ABD_MEMO1"         , "C", 80, 0}) // Comentarios
aAdd(aABD, {"ABD_CODPRB"        , "C", 06, 0}) // Ocorrencia
aAdd(aABD, {"ABD_DESCRI"        , "C", 30, 0}) // Descricao da pendencia
aAdd(aABD, {"ABD_DATA"          , "D", 08, 0}) // Data de Inclusao
*/  

aAdd(aABF, {"ABF_FILIAL"  , "C", 02, 0}) // Filial
aAdd(aABF, {"ABF_EMISSA"  , "C", 08, 0}) // Data de Emissao da Req.
aAdd(aABF, {"ABF_NUMOS"   , "C", 06, 0}) // Nr. da OS
aAdd(aABF, {"ABF_ITEMOS"  , "C", 02, 0}) // Item OS
aAdd(aABF, {"ABF_SEQRC"   , "C", 02, 0}) // Sequencia da solicitacao
aAdd(aABF, {"ABF_CODTEC"  , "C", 06, 0}) // Tecnico
aAdd(aABF, {"ABF_SOLIC"   , "C", 10, 0}) // Solicitante

aAdd(aABG, {"ABG_FILIAL"  , "C", 02, 0}) // Filial
aAdd(aABG, {"ABG_NUMOS"   , "C", 06, 0}) // Nr. da OS
aAdd(aABG, {"ABG_ITEMOS"  , "C", 02, 0}) // Item da OS
aAdd(aABG, {"ABG_ITEM"    , "C", 02, 0}) // Item requisitado
aAdd(aABG, {"ABG_SEQRC"   , "C", 02, 0}) // Seq. da solicitacao ao almoxarifado
aAdd(aABG, {"ABG_CODPRO"  , "C", 15, 0}) // Cod. do produto
aAdd(aABG, {"ABG_DESCRI"  , "C", 30, 0}) // Descricao do produto
aAdd(aABG, {"ABG_QUANT"   , "N", 09, 0}) // Quantidade
aAdd(aABG, {"ABG_CODSER"  , "C", 06, 0}) // Cod. de servico
aAdd(aABG, {"ABG_CODTEC"  , "C", 06, 0}) // Cod. do tecnico

aAdd(aAB6,{"AB6_FILIAL"   , "C", 02, 0}) // Filial
aAdd(aAB6,{"AB6_NUMOS"    , "C", 06, 0}) // Nr. da OS
aAdd(aAB6,{"AB6_CODCLI"   , "C", 06, 0}) // Cod. do cliente
aadd(aAB6,{"AB6_LOJA"     , "C",  2, 0}) // Loja do cliente
aAdd(aAB6,{"AB6_EMISSA"   , "C", 10, 0}) // Data de Emissao
aadd(aAB6,{"AB6_ATEND"    , "C", 20, 0}) // Atendente
aadd(aAB6,{"AB6_STATUS"   , "C",  1, 0}) // Status (?)
aadd(aAB6,{"AB6_CONPAG"   , "C",  3, 0})
aadd(aAB6,{"AB6_DESC1"    , "N",  5, 2})
aadd(aAB6,{"AB6_DESC2"    , "N",  5, 2})
aadd(aAB6,{"AB6_DESC3"    , "N",  5, 2})
aadd(aAB6,{"AB6_DESC4"    , "N",  5, 2})
aadd(aAB6,{"AB6_TABELA"   , "C",  1, 0})
aadd(aAB6,{"AB6_PARC1"    , "N", 12, 2})
aadd(aAB6,{"AB6_DATA1"    , "D", 10, 0})
aadd(aAB6,{"AB6_PARC2"    , "N", 12, 2})
aadd(aAB6,{"AB6_DATA2"    , "D", 10, 0})
aadd(aAB6,{"AB6_PARC3"	  , "N", 12, 2})
aadd(aAB6,{"AB6_DATA3"    , "D", 10, 0})
aadd(aAB6,{"AB6_PARC4"	  , "N", 12, 2})
aadd(aAB6,{"AB6_DATA4"	  , "D", 10, 0})
aadd(aAB6,{"AB6_OK"		  , "C",  2, 0})
aadd(aAB6,{"AB6_HORA"	  , "C",  5, 0})
aadd(aAB6,{"AB6_REGIAO"	  , "C",  3, 0})
aadd(aAB6,{"AB6_MSG"	  , "C", 60, 0})

aadd(aAB7,{"AB7_NUMOS"  , "C",  6, 0}) // Numero da OS
aadd(aAB7,{"AB7_ITEM"   , "C",  2, 0}) // Item da OS
aadd(aAB7,{"AB7_TIPO"   , "C",  1, 0}) // Situacao da OS (1-OS, 2-Pedido Gerado, 3-Em atendimento, 4-Atendida)
aadd(aAB7,{"AB7_CODPRO" , "C", 15, 0}) // Codigo do Prod./Eqpto 
aadd(aAB7,{"AB7_NUMSER" , "C", 20, 0}) // Numero de Serie
aadd(aAB7,{"AB7_CODPRB" , "C",  6, 0}) // Cod. da Ocorrenc./Problema
aadd(aAB7,{"AB7_NRCHAM" , "C", 10, 0}) // Numero do chamado
aadd(aAB7,{"AB7_NUMORC" , "C",  8, 0}) // Numero do Orcamento
aadd(aAB7,{"AB7_MEMO1"  , "C",  6, 0}) // Codigo Memo
aadd(aAB7,{"AB7_MEMO3"  , "C",  6, 0}) // Cod. da Solucao
aadd(aAB7,{"AB7_CODFAB" , "C",  6, 0}) // Cod. do Fabricante
aadd(aAB7,{"AB7_LOJAFA" , "C",  2, 0}) // Loja do Fabricante
aadd(aAB7,{"AB7_CODCLI" , "C",  6, 0}) // Cod. do Cliente
aadd(aAB7,{"AB7_LOJA"   , "C",  2, 0}) // Loja do Cliente
aadd(aAB7,{"AB7_EMISSA" , "D",  8, 0}) // Emissao da OS
aadd(aAB7,{"AB7_NUMHDE" , "C", 10, 0}) // Numero do He

//Campo de controle p/ nao voltar para o Palm as OSs incluidas em campo (ABB_OBSERV = "OS INCLUIDA EM CAMPO")
aAdd(aABB, {"ABB_FILIAL" , "C", 02, 0}) // Filial
aAdd(aABB, {"ABB_CODTEC" , "C", 06, 0}) // Cod. do tecnico
//aadd(aABB, {"ABB_NOMTEC",  "C", 30, 0})// Nome do tecnico (?)
aAdd(aABB, {"ABB_NUMOS"  , "C", 06, 0}) // Nr. da OS
aAdd(aABB, {"ABB_DTINI"  , "C", 08, 0}) // Data Inicio
aAdd(aABB, {"ABB_HRINI"  , "C", 05, 0}) // Hora Inicio
aAdd(aABB, {"ABB_DTFIM"  , "C", 08, 0}) // Data Fim
aAdd(aABB, {"ABB_HRFIM"  , "C", 05, 0}) // Hora Fim
aAdd(aABB, {"ABB_HRTOT"  , "C", 05, 0}) // Horas faturadas
aAdd(aABB, {"ABB_OBSERV" , "C", 30, 0}) // Observacoes

ConOut("PALMJOB: Importando OS para " + Trim(PALMUSER->P_USER)) 
If PChkFile(cPathPalm, aArquivos)
// ********************* Import. de novas OS **************************
dbSelectArea("ORD")
dbGoTop()
While !Eof()

	cOSTec := ORD->AB6_NUMOS  
	If AllTrim(ORD->AB6_MSG) = "OS NOVA"  //Verificar se a OS e nova

		cNovaOS := GetSxeNum("AB6", "AB6_NUMOS") //Gerar o prox. nr. de OS
		dbSelectArea("AB6")
		dbSetOrder(1)
		While dbSeek(xFilial("AB6") + cNovaOS)
			ConfirmSX8()
			cNovaOS := GetSxeNum("AB6","AB6_NUMOS")
			dbSkip()
		EndDo
  	    
  	  	If PNovaOS(cNovaOS,aAB6)
  	  		PNovoItem(cNovaOS,cOSTec,aAB7)
	  	  	PNovaAge(cNovaOS,cOSTec,aABB)
	  	  	PNovoApont(cNovaOS,cOSTec,@cOSApo,aAB9)
	  	  	PNovaPeca(cNovaOS,cOSApo,aABA)
	  	  	PNovaDesp(cNovaOS,cOSApo,aABC)
	  	  	PNovaReq(cNovaOS,cOSApo,aABF,aABG)
	  	  	PAtuTec(cTecnico,cOSTec)
	  	  	
			RecLock("ORD", .F.)  // Mudar o flag para OS ja importada (processada)
			ORD->AB6_MSG := "P"
			MsUnlock()	
		Endif

	EndIf

	dbSelectArea("ORD")
	dbSkip() 
EndDo

dbSelectArea("ORD")
ORD->(dbCloseArea())
dbSelectArea("ITE") 
ITE->(dbCloseArea())
dbSelectArea("AGE")
AGE->(dbCloseArea())
dbSelectArea("TEC")
TEC->(dbCloseArea())

/*
dbSelectArea("APO")
APO->(dbCloseArea())
dbSelectArea("ITS")
ITS->(dbCloseArea())
dbSelectArea("DES")
DES->(dbCloseArea())
dbSelectArea("REQ")
REQ->(dbCloseArea())
dbSelectArea("IRQ")
IRQ->(dbCloseArea())
*/

/******************************************************************************************************/
	//Importacao das tabelas apontadas na Ordem de Servico (AB9, ABA, ABC, ABD, ABF, ABG, AB6 e ABB)
/******************************************************************************************************/	

	//Importa Apontamento da OS
	PImpAB9(aAB9)	

    //Import. de Itens
	PImpABA(aABA)
	
	// Import. de Despesas
	PImpABC(aABC)
	
	// Import. de Requisicoes
	PImpABF(aABF)

	//Import. de itens de requisicoes
	PImpABG(aABG)

Else
	ConOut("PALMJOB: Arquivo(s) de OS nao encontrado(s)")
EndIf

Return


Function PIOrdTab()
Return{"AB9", "ABA", "ABC", "ABF", "ABG", "AB6", "AB7", "ABB", "AA1"}

Function PIOrdArq()
Local cFileTec    := "AA1" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileAponta := "AB9" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItens  := "ABA" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileDesp	  := "ABC" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileReq	  := "ABF" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItReq  := "ABG" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileOS	  := "AB6" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItOS   := "AB7" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileAge    := "ABB" + Left(PALMSERV->P_EMPFI,2) + "0"
Return{cFileAponta, cFileItens, cFileDesp, cFileReq, cFileItReq, cFileOS, cFileItOS, cFileAge, cFileTec}

Function PIOrdInd()
Return{"AB9_NUMOS", "ABA_NUMOS+ABA_ITEM", "ABC_NUMOS+ABC_ITEM", "ABF_NUMOS+ABF_ITEMOS", "ABG_NUMOS+ABG_ITEMOS+ABG_ITEM", "AB6_NUMOS", "AB7_NUMOS+AB7_ITEM", "ABB_CODTEC+ABB_NUMOS", "AA1_CODTEC"}


//Importa nova OS (AB6)
Function PNovaOS(cNovaOS,aAB6)
Local i
Local lRet := .T.
	  //ConOut("Nova OS: " + cNovaOS)
	dbSelectArea("AB6")
	dbSetOrder(1)
	If Empty(ORD->AB6_NUMOS)
  		ConOut("Nova OS nao importada - existem campos obrigatorios em branco")
  		lRet := .F.
 	Else
  	  	dbSelectArea("AB6") //Atualiza Ordens de Servico
  		ConOut("Importando nova OS: " + cNovaOS)
  		RecLock("AB6", .t.)
   	For i:=1 to len(aAB6)
   		If aAB6[i,1] = "AB6_FILIAL"
   		    Replace AB6->AB6_FILIAL With xFilial("AB6")
   		ElseIf aAB6[i,1] = "AB6_NUMOS"
   			Replace AB6->AB6_NUMOS With cNovaOS
   		Else
   			Replace &(aAB6[i,1]) With &("ORD->" + aAB6[i,1])
   		EndIf
   	Next
   	MsUnlock()
	EndIf
Return lRet


//Importa itens (AB7) da OS nova
Function PNovoItem(cNovaOS,cOSTec,aAB7)
Local i
	dbSelectArea("ITE") //Atualiza itens da Nova OS
	dbSeek(cOSTec)
   While !Eof() .And. ITE->AB7_NUMOS == cOSTec
   	If AllTrim(ITE->AB7_MEMO3) = "NOVO" .And. cOSTec = ITE->AB7_NUMOS
   		ConOut("Importando novo item AB7 da OS: " + cNovaOS)
   		RecLock("AB7", .t.)
   		For i:=1 to len(aAB7)
   	    	If aAB7[i,1] = "AB7_FILIAL"
					Replace AB7->AB7_FILIAL With xFilial("AB7")
				ElseIf aAB7[i,1] = "AB7_NUMOS"
					Replace AB7->AB7_NUMOS With cNovaOS 
				Else
				 	Replace &(aAB7[i,1]) With &("ITE->" + aAB7[i,1])
				EndIf
   		Next
   	 	MsUnlock()
   	EndIf
   	dbSelectArea("ITE")
   	dbSkip()
	EndDo
Return nil


//Importa agenda da OS nova (ABB)
Function PNovaAge(cNovaOS,cOSTec,aABB)
Local cDataini := ""
Local cDatafim := ""
Local i

dbSelectArea("AGE") //Atualiza Agenda
dbGoTop()
   	  //ConOut(Eof())
While !Eof()
	dbSelectArea("ABB")
	dbSetOrder(1)
	If !dbseek(xFilial() + AGE->ABB_CODTEC + AGE->ABB_DTINI + AGE->ABB_HRINI, .t.)
 		If AllTrim(AGE->ABB_OBSERV) = "OS INCLUIDA EM CAMPO" .And. cOSTec = AGE->ABB_NUMOS
   		ConOut("Importando nova agenda para tecnico: " + AGE->ABB_CODTEC)
			RecLock("ABB", .t.)
	  		For i:=1 to len(aABB)
	  			If aABB[i,1] = "ABB_FILIAL"
	  			    Replace ABB->ABB_FILIAL With xFilial("ABB")
	  			ElseIf aABB[i,1] = "ABB_NUMOS"
	  				Replace ABB->ABB_NUMOS With cNovaOS
				ElseIf aABB[i,1] = "ABB_DTINI"
					cDataini := Substr(AGE->ABB_DTINI,7,2) + "/" + Substr(AGE->ABB_DTINI,5,2) + "/" + Substr(AGE->ABB_DTINI,3,2)
					//cDataini := AGE->ABB_DTINI
	  				Replace ABB->ABB_DTINI With CTOD(cDataini)
				ElseIf aABB[i,1] = "ABB_DTFIM" 
					cDatafim := Substr(AGE->ABB_DTFIM,7,2) + "/" + Substr(AGE->ABB_DTFIM,5,2) + "/" + Substr(AGE->ABB_DTFIM,3,2)
					//cDatafim := AGE->ABB_DTFIM
	  				Replace ABB->ABB_DTFIM With CTOD(cDatafim)
	  			Else
	  				Replace &(aABB[i,1]) With &("AGE->" + aABB[i,1])
	  			EndIf
	  		Next
	  		MsUnlock()
		EndIf
	EndIf
	dbSelectArea("AGE") 
   dbSkip()	    
EndDo
Return nil       


//Importa apontamento da OS nova (AB9)
Function PNovoApont(cNovaOS,cOSTec,cOSApo,aAB9)
Local i, cMemo

dbSelectArea("APO") //Atualiza apontamentos c/ Nova OS
//dbGoTop()
cOSApo := cOSTec + "01" 	// OS + Item OS
dbSeek(cOSApo)
While !Eof() .And. Substr(APO->AB9_NUMOS,1,6) = cOSTec
	If AllTrim(APO->AB9_MEMO1) = "NOVA" .And. cOSTec = Substr(APO->AB9_NUMOS,1,6)
 		ConOut("Importando novo Apont. da OS: " + cNovaOS)
   	RecLock("AB9", .t.)
   	cMemo := APO->AB9_MEMO2
   	For i:=1 to len(aAB9)
   		If aAB9[i,1] = "AB9_FILIAL"
				Replace AB9->AB9_FILIAL With xFilial("AB9")
			ElseIf aAB9[i,1] = "AB9_NUMOS"
				Replace AB9->AB9_NUMOS With cNovaOS + SubStr(APO->AB9_NUMOS,7,2)
			ElseIf aAB9[i,1] = "AB9_SEQ"
				Replace AB9->AB9_SEQ With APO->AB9_SEQ
				//Testar
			ElseIf aAB9[i,1] = "AB9_MEMO1"
			
			ElseIf aAB9[i,1] = "AB9_MEMO2"
				//MSMM(cCodMen,,,APO->AB9_MEMO2,1,,,"AB9","AB9_MEMO1")					
			Else
			 	Replace &(aAB9[i,1]) With &("APO->" + aAB9[i,1])
			EndIf
   	Next
   	MSMM(,TamSx3("AB9_MEMO2")[1],,cMemo,1,,,"AB9","AB9_MEMO1")
   	AB9->(MsUnlock())
   	cOSApo := APO->AB9_NUMOS
	EndIf
	dbSelectArea("APO")
	dbSkip()
EndDo
Return nil


//Importa pecas da OS nova (ABA) 
Function PNovaPeca(cNovaOS,cOSApo,aABA)
Local cOSItens, i, cLocalPad, cDescri

dbSelectArea("ITS") //Atualiza novos itens
cOSItens := cOSApo
dbSeek(cOSItens)
While !Eof() .And. ITS->ABA_NUMOS = cOSItens 
	If cOSItens = ITS->ABA_NUMOS //.And. AllTrim(ITS->ABA_LOCLZD) = "NOVO"
		ConOut("Importando novo item: " + cNovaOS + Substr(ITS->ABA_NUMOS,7,2) + " - " + ITS->ABA_ITEM ) 
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial("SB1") + ITS->ABA_CODPRO,.T. ))
		cLocalPad	:= SB1->B1_LOCPAD
		cDescri		:= SB1->B1_DESC
		
		RecLock("ABA", .t.)
  		For i:=1 to len(aABA)
	   	If aABA[i,1] = "ABA_ITEM"
				Replace ABA->ABA_ITEM With ITS->ABA_ITEM
			ElseIf aABA[i,1] = "ABA_FILIAL"
				Replace ABA->ABA_FILIAL With xFilial("ABA")
			ElseIf aABA[i,1] = "ABA_NUMOS"
				Replace ABA->ABA_NUMOS With cNovaOS + Substr(ITS->ABA_NUMOS,7,2)
			ElseIf aABA[i,1] = "ABA_LOCAL" //almox. padrao
				Replace ABA->ABA_LOCAL With cLocalPad
			ElseIf aABA[i,1] = "ABA_SEQ" 
			   Replace ABA->ABA_SEQ With "01"
			ElseIf aABA[i,1] = "ABA_DESCRI"
				Replace ABA->ABA_DESCRI With cDescri
			Else
			 	Replace &(aABA[i,1]) With &("ITS->" + aABA[i,1])
			EndIf
  		Next
   	MsUnlock()
	EndIf
	RecLock("ITS", .F.)
	ITS->ABA_LOCLZD := "P"
	MsUnlock()
	dbSelectArea("ITS")
	dbSkip()
EndDo
Return nil


//Importa despesas da OS nova (ABC) 
Function PNovaDesp(cNovaOS,cOSApo,aABC)
Local cOSDesp := cOSApo                            
Local i
dbSelectArea("DES") //Atualiza novas despesas
dbSeek(cOSDesp)
While !Eof() .And. DES->ABC_NUMOS = cOSDesp
	If cOSDesp = DES->ABC_NUMOS //.And. AllTrim(DES->ABC_SUBOS) = "NW"
		ConOut("Importando nova despesa: " + cNovaOS + Substr(DES->ABC_NUMOS, 7, 2) + " - " + DES->ABC_ITEM)
		RecLock("ABC", .T.)
		For i:= 1 To Len(aABC)
				If aABC[i,1] = "ABC_NUMOS"
		    		Replace ABC->ABC_NUMOS With cNovaOS + Substr(DES->ABC_NUMOS, 7, 2)
		    	ElseIf aABC[i,1] = "ABC_ITEM"
		    	    Replace ABC->ABC_ITEM With DES->ABC_ITEM
		    	ElseIf aABC[i,1] = "ABC_FILIAL"
		    		Replace ABC->ABC_FILIAL With xFilial("ABC")
		    	Else
		 	   	Replace &(aABC[i,1]) With &("DES->" + aABC[i,1])
				EndIf	
		Next
		MsUnlock()
	EndIf
	RecLock("DES", .F.)
	DES->ABC_SUBOS := "P"
	MsUnlock()
	dbSelectArea("DES")
	dbSkip()
EndDo
Return nil


//Importa requisicoes da OS nova (ABF e ABG)
Function PNovaReq(cNovaOS,cOSApo,aABF,aABG)
Local cEmissao := ""
Local cOSReq   := ""
Local i

dbSelectArea("REQ")
dbSeek(cOSApo) //OS + Item

While !Eof() .And. REQ->ABF_NUMOS = Substr(cOSApo,1,6) .And. REQ->ABF_ITEMOS = Substr(cOSApo,7,2)

	If REQ->ABF_NUMOS = Substr(cOSApo,1,6) .And. REQ->ABF_ITEMOS = Substr(cOSApo,7,2)
		ConOut("Importando nova requisicao: " + cNovaOS + REQ->ABF_ITEMOS)
		RecLock("ABF", .T.)
		For i:= 1 To Len(aABF)
				If aABF[i,1] = "ABF_FILIAL"
					Replace ABF->ABF_FILIAL With xFilial("ABF")
				ElseIf aABF[i,1] = "ABF_NUMOS"
					Replace ABF->ABF_NUMOS With cNovaOS
				ElseIf aABF[i,1] = "ABF_ITEMOS"
					Replace ABF->ABF_ITEMOS With REQ->ABF_ITEMOS
				ElseIf aABF[i,1] = "ABF_EMISSA"
					cEmissao := Substr(REQ->ABF_EMISSA,7,2)+ "/" + Substr(REQ->ABF_EMISSA,5,2)+ "/" + Substr(REQ->ABF_EMISSA,3,2)
					//cEmissao := REQ->ABF_EMISSA
					Replace ABF->ABF_EMISSA With CtoD(cEmissao)
				Else
					Replace &(aABF[i,1]) With &("REQ->" + aABF[i,1])
				EndIf
		Next
		MsUnlock()
 	EndIf
	RecLock("REQ", .F.)
	REQ->ABF_SOLIC := "P"
	MsUnlock()
	dbSelectArea("REQ")
	dbSkip()
EndDo
   	  
dbSelectArea("IRQ")
cOSReq := cOSApo + IRQ->ABG_ITEM
dbSeek(cOSReq)
While !Eof() .And. IRQ->ABG_NUMOS = Substr(cOSApo,1,6) .And. IRQ->ABG_ITEMOS = Substr(cOSApo,7,2)
	If IRQ->ABG_NUMOS = Substr(cOSApo,1,6) .And. IRQ->ABG_ITEMOS = Substr(cOSApo,7,2)
			ConOut("Importando novo item de req.: " + cNovaOS + IRQ->ABG_ITEMOS + " - " + IRQ->ABG_ITEM)
			RecLock("ABG", .T.)
			For i:= 1 To Len(aABG)
				If aABG[i,1] = "ABG_FILIAL"
					Replace ABG->ABG_FILIAL With xFilial("ABG")
				ElseIf aABG[i,1] = "ABG_NUMOS"
					Replace ABG->ABG_NUMOS With cNovaOS
				ElseIf aABG[i,1] = "ABG_ITEMOS"
					Replace ABG->ABG_ITEMOS With IRQ->ABG_ITEMOS
				Else
					Replace &(aABG[i,1]) With &("IRQ->" + aABG[i,1])
				EndIf
			Next
			MsUnlock()   	  	
	EndIf
	RecLock("IRQ", .F.)
	IRQ->ABG_CODTEC := "P"
	MsUnlock()
	dbSelectArea("IRQ")
	dbSkip()
EndDo
   
Return nil


//Atualiza dados do tecnico (AA1) 
Function PAtuTec(cTecnico,cOSTec)
Local cProxOS
//Atualizar cad. de tecnicos c/ o nr. da proxima OS
dbSelectArea("AA1")
dbSetOrder(1)
dbSeek(xFilial() + cTecnico)
While !Eof() .And. AA1->AA1_CODTEC = cTecnico
	//If dbSeek(xFilial() + TEC->AA1_CODTEC)
	cProxOS := val(cOSTec) + 1
	ConOut("Atualizando dados do Tecnico: " + cTecnico)
	If AA1->(FieldPos("AA1_PROXOS")) <> 0
		RecLock("AA1", .F.)
  		AA1->AA1_PROXOS := Strzero(cProxOS, 6, 0)
		MsUnlock()
	Else
		ConOut("Alerta: Criar o campo AA1_PROXOS (C,6)")
	Endif
	//EndIf
	dbSelectArea("AA1")
	dbSkip()
EndDo
Return nil


//Importa Apontamento da OS
Function PImpAB9(aAB9)
Local cNumOSPalm:="", cNumOS:="", i, cMemo

dbSelectArea("APO")
dbGoTop()
While !Eof()
	cNumOSPalm := Substr(APO->AB9_NUMOS, 1, 6)
	cNumOS     := APO->AB9_NUMOS
    
	dbSelectArea("AB9")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cNumOS, .T.) .And. APO->AB9_MEMO1 <> "NOVA"
		ConOut("Importando Apontam. da OS: " + cNumOS) // Mensagem de nr. de OS
		
		If Empty(APO->AB9_NUMOS) .Or. Empty(APO->AB9_CODTEC) .Or. Empty(APO->AB9_SEQ) .Or. Empty(APO->AB9_DTCHEG) .Or. Empty(APO->AB9_HRCHEG) .Or. Empty(APO->AB9_DTSAID) .Or. Empty(APO->AB9_HRSAID) .Or. Empty(APO->AB9_DTINI) .Or. Empty(APO->AB9_HRINI) .Or. Empty(APO->AB9_DTFIM) .Or. Empty(APO->AB9_HRFIM) .Or. Empty(APO->AB9_CODPRB) .Or. Empty(APO->AB9_TOTFAT)
		   ConOut("O.S. nao importada - Existem campos obrigatorios em branco")
		Else
			RecLock("AB9", .T.)
			cMemo := APO->AB9_MEMO2
			For i:=1 to Len(aAB9)
				If aAB9[i,1] = "AB9_FILIAL"
					Replace AB9->AB9_FILIAL With xFilial("AB9")
				ElseIf aAB9[i,1] = "AB9_NUMOS"
					Replace AB9->AB9_NUMOS With APO->AB9_NUMOS
				ElseIf aAB9[i,1] = "AB9_SEQ"
					Replace AB9->AB9_SEQ With APO->AB9_SEQ
				ElseIf aAB9[i,1] = "AB9_MEMO1"
					
				ElseIf aAB9[i,1] = "AB9_MEMO2"
					//MSMM(cCodMen,,,APO->AB9_MEMO2,1,,,"AB9","AB9_MEMO1")
				Else
				 	Replace &(aAB9[i,1]) With &("APO->" + aAB9[i,1])
				EndIf
			Next    
			MSMM(,TamSx3("AB9_MEMO2")[1],,cMemo,1,,,"AB9","AB9_MEMO1")
			AB9->(MsUnlock())
		EndIf
	EndIf
	dbSelectArea("APO")
	dbSkip()
EndDo
Return nil


//Importa Pecas (itens) da OS
Function PImpABA(aABA)
Local cNrItem := "", i, cLocalPad, cDescri

dbSelectArea("ITS")
dbGoTop()
While !Eof()
	cNrItem := ITS->ABA_NUMOS
	dbSelectArea("ABA")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cNrItem + ITS->ABA_CODTEC + ITS->ABA_SEQ + ITS->ABA_ITEM, .T.) .And. Alltrim(ITS->ABA_LOCLZD) <> "P"
		If Empty(ITS->ABA_CODPRO) .Or. Empty(ITS->ABA_QUANT)
			ConOut("Item nao importado - Existem campos obrigatorios em branco")
		Else
			ConOut("Importando item: " + ITS->ABA_NUMOS + " - " + ITS->ABA_ITEM)
			SB1->(dbSetOrder(1))
			SB1->(dbSeek( xFilial("SB1") + ITS->ABA_CODPRO,.T. ))
			cLocalPad	:= SB1->B1_LOCPAD
			cDescri		:= SB1->B1_DESC
			
			RecLock("ABA", .T.)
			For i:=1 To Len(aABA)
				If aABA[i,1] = "ABA_ITEM"
					Replace ABA->ABA_ITEM With ITS->ABA_ITEM
				ElseIf aABA[i,1] = "ABA_FILIAL"
					Replace ABA->ABA_FILIAL With xFilial("ABA")
				ElseIf aABA[i,1] = "ABA_NUMOS"
					Replace ABA->ABA_NUMOS With ITS->ABA_NUMOS
				ElseIf aABA[i,1] = "ABA_LOCAL" //almox. padrao
					Replace ABA->ABA_LOCAL With cLocalPad
				ElseIf aABA[i,1] = "ABA_SEQ" 
				   Replace ABA->ABA_SEQ With "01"
				ElseIf aABA[i,1] = "ABA_DESCRI"
					Replace ABA->ABA_DESCRI With cDescri				
				Else
				 	Replace &(aABA[i,1]) With &("ITS->" + aABA[i,1])
				EndIf
			Next        
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("ITS")
	dbSkip()
EndDo
Return nil      


//Importa despesas da OS
Function PImpABC(aABC)
Local cNrDespesa := "", i

dbSelectArea("DES")
dbGoTop()
While !Eof()    
	cNrDespesa := DES->ABC_NUMOS
	dbSelectArea("ABC")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cNrDespesa + DES->ABC_CODTEC + DES->ABC_SEQ + DES->ABC_ITEM, .T.) .And. AllTrim(DES->ABC_SUBOS) <> "P"
		If Empty(DES->ABC_CODPRO) .Or. Empty(DES->ABC_DESCRI) .Or. Empty(DES->ABC_QUANT) .Or. Empty(DES->ABC_VLUNIT) .Or. Empty(DES->ABC_VALOR) .Or. Empty(DES->ABC_CODSER)
			ConOut("Despesa nao importada - Existem campos obrigatorios em branco")
		Else
			ConOut("Importando despesa: " + DES->ABC_NUMOS + " - " + DES->ABC_ITEM)
			RecLock("ABC", .T.)
		 	For i:= 1 To Len(aABC)
		    	If aABC[i,1] = "ABC_NUMOS"
		    		Replace ABC->ABC_NUMOS With DES->ABC_NUMOS
		    	ElseIf aABC[i,1] = "ABC_ITEM"
		    		Replace ABC->ABC_ITEM With DES->ABC_ITEM
		    	ElseIf aABC[i,1] = "ABC_FILIAL"
		    		Replace ABC->ABC_FILIAL With xFilial("ABC")
		    	Else
		 	   	Replace &(aABC[i,1]) With &("DES->" + aABC[i,1])
		 		EndIf	
		  	Next
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("DES")
	dbSkip()
EndDo
Return nil      


//Importa requisicoes (cabec) da OS
Function PImpABF(aABF)
Local cNrReq := "", i

dbSelectArea("REQ")
dbGoTop()
While !Eof()
	cNrReq := REQ->ABF_NUMOS + REQ->ABF_ITEMOS
	dbSelectArea("ABF")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cNrReq + REQ->ABF_SEQRC, .T.) .And. AllTrim(REQ->ABF_SOLIC) <> "P"
		If Empty(REQ->ABF_EMISSA) .Or. Empty(REQ->ABF_NUMOS) .Or. Empty(REQ->ABF_ITEMOS) .Or. Empty(REQ->ABF_SEQRC) .Or. Empty(REQ->ABF_CODTEC)
			ConOut("Requisicao nao importada - Existem campos obrigatorios em branco")
		Else
			ConOut("Importando requisicao da OS: " + cNrReq)
			RecLock("ABF", .T.)
			For i:= 1 To Len(aABF)
				If aABF[i,1] = "ABF_FILIAL"
					Replace ABF->ABF_FILIAL With xFilial("ABF")
				ElseIf aABF[i,1] = "ABF_ITEMOS"
					Replace ABF->ABF_ITEMOS With REQ->ABF_ITEMOS
				ElseIf aABF[i,1] = "ABF_EMISSA"
					cEmissao := Substr(REQ->ABF_EMISSA,7,2)+ "/" + Substr(REQ->ABF_EMISSA,5,2)+ "/" + Substr(REQ->ABF_EMISSA,3,2)
					//cEmissao := REQ->ABF_EMISSA
					Replace ABF->ABF_EMISSA With CtoD(cEmissao)
				Else
					Replace &(aABF[i,1]) With &("REQ->" + aABF[i,1])
				EndIf
			Next
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("REQ")
	dbSkip()
EndDo
Return nil      
   

//Importa requisicoes (itens) da OS
Function PImpABG(aABG)
Local cItemReq := "", i

dbSelectArea("IRQ")
dbGoTop()
While !Eof()
	cItemReq := IRQ->ABG_NUMOS + IRQ->ABG_ITEMOS
	dbSelectArea("ABG")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cItemReq + IRQ->ABG_SEQRC + IRQ->ABG_ITEM, .T.) .And. AllTrim(IRQ->ABG_CODTEC) <> "P"
		If Empty(IRQ->ABG_ITEM) .Or. Empty(IRQ->ABG_CODPRO) .Or. Empty(IRQ->ABG_QUANT) .Or. Empty(IRQ->ABG_CODSER)
			ConOut("Item de req. nao importado - Existem campos obrigatorios em branco")
		Else
			ConOut("Importando item de req.: " + IRQ->ABG_NUMOS + IRQ->ABG_ITEMOS + " - " + IRQ->ABG_ITEM)
			RecLock("ABG", .T.)
			For i:= 1 To Len(aABG)
				If aABG[i,1] = "ABG_FILIAL"
					Replace ABG->ABG_FILIAL With xFilial("ABG")
				ElseIf aABG[i,1] = "ABG_NUMOS"
					Replace ABG->ABG_NUMOS With IRQ->ABG_NUMOS
				ElseIf aABG[i,1] = "ABG_ITEMOS"
					Replace ABG->ABG_ITEMOS With IRQ->ABG_ITEMOS
				Else
					Replace &(aABG[i,1]) With &("IRQ->" + aABG[i,1])
				EndIf
			Next
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("IRQ")
	dbSkip()
EndDo
Return nil
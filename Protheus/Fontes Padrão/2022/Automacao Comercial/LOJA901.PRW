#INCLUDE "LOJA901.ch"
#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample U_ECOM001
/*/
//-------------------------------------------------------------------

User Function ECOM009 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja901(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901
Função de teste integracao Protheus e-commerce CiaShop recebimento de Clientes 
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA901()
/*/
//-------------------------------------------------------------------
Function LOJA901(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA901" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf

If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	Lj901Pr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" )
	EndIf

	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901Pr
Função de teste integracao Protheus e-commerce recebimento de Clientes
@param   	lAJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj901Pr(lAJob)
/*/
//-------------------------------------------------------------------
Function Lj901Pr(lAJob, lCallStack)
Local cXML     		:= "" //XML recewbido
Local oWS			:= NIL //Objeto WS
Local cError   		:= "" //Erro do Parser
Local cWarning 		:= "" //Alerta do Parser
Local oRetXML		:= NIL //Retorno Parseado
Local lErro    		:= .F. //Erro do WS
Local cRetorno 		:= "" //XML de Retorno
Local cSeq     		:= "" //Sequencia da Rotina
local nInd			:= 0 //Contador
local aCliOK   		:= {} //Clientes ok
Local dDataIni 		:= Date() //Data Inicial do Job
Local cHoraIni 		:= Time() //Hora Inicial do Job
Local oNodeRet  	:= NIL //Node com retorno de Erro
Local oNodeMsg 		:= NIL //Node com mensagem de Erro
Local oNodeRes 		:= NIL //Node com mensagem de Erro
Local oNodeComp 	:= NIL //Node com retorno dos compradores
Local oNodeShopp	:= NIL //Node de compradores
Local aShopper 		:= {} //Array de Compradores
Local lTesteXML 	:= .F. //Teste de rotina
Local cTesteXML 	:= "0" //Conteudo do ini do Teste de Rotina configurado
Local lUsrAdm 		:= .F. //usuário administrador
Local lContinua 	:= .T.
Local cXMLConf := "" //XML confirmado

Default lAJob := .F.
Default lCallStack := .F.

//Cria classe do WebService
oWS := Lj904WS( )

dbSelectArea("SA1")
SA1->(DbSetOrder(1))

dbSelectArea("SA3")
SA3->(DBSetOrder(1))

dbSelectArea("MGS")

//Resultado da sincronização
cSeq := GETSXENUM("MGM","MGM_SEQ")
CONFIRMSX8()

If SuperGetMV("TT_WSDLXML",,.F.)  
	Lj900XLg(STR0011)//"Habilitando o Log WSDLXML"
	WSDLSaveXML(.T.)
EndIf

//Consome método
If !oWs:Compradores(, , @cXML) .OR. Empty(oWs:cXml) //tratamento do xml em branco
	lErro := .T.
	cRetorno := STR0007 //"Erro ao consumir o método 'Compradores' do WebService!"
Else
	IIF(!lAJob, MemoWrit('retornoCompradores.xml', oWs:cXml), )
	
	//Verifique se deve executar a rotina de Teste
	lTesteXML := !lAJob .AND. !lCallStack .and. !IsBlind() .AND. !IsInCallStack("LOJA901A")
	cRetorno := oWs:cXml
	
	If lTesteXML
		//Verifica se o arquivo SIGALOJA.INI está com a chave
		
   		cTesteXML := GetPvProfString("teste_xml_ciashop", "loja901", "0", GetClientDir() +"SIGALOJA.INI")
   		lUsrAdm := FWIsAdmin()
   		lTesteXML := .F.
   		
   		If cTesteXML == "1" 
   			If lUsrAdm
	   			lTesteXML := .T.
				///Rotina para teste de xml	
	   			MsgAlert(STR0027 + CRLF+; //"Arquivo SIGALOJA.INI da pasta smarclient configurado para realização de captura de XML de testes na integração clientes CiaShop "
	   					STR0028 + CRLF + ; //"Seção: [teste_xml_ciashop] Chave: loja901=1"
	   					STR0029 ) //"Após o término dos testes, desabilite dessa configuração. Seção: [teste_xml_ciashop] Chave: loja901=0"
				cRetorno := Lj901Tst()
				If Empty(cRetorno)
					MsgStop(STR0032) //"XML sem conteúdo. Este teste será interrompido"
					lContinua := .F.		
				EndIf
  			Else 
   				MsgAlert(STR0027 + CRLF+; //"Arquivo SIGALOJA.INI da pasta smarclient configurado para realização de captura de XML de testes na integração clientes CiaShop "
   					STR0028 + ; //"Seção: [teste_xml_ciashop] Chave: loja901=1"
   					STR0030 + CRLF+; //", porém este teste só poderá ser realizado se o usuário possuir privilégios de Administrador de Sistema."
   					STR0031 ) //"Dessa forma, não será capturado o XML de testes. A rotina rotina continuára o processamento padrão que é a leitura do XML de compradores"
   			EndIf
   		EndIf
   		
	EndIf


	If lContinua
	
		oRetXML := XmlParser(cRetorno, "_", @cError, @cWarning)
		
		If !Empty(cError) 
			cRetorno += Chr(13)  + STR0008 + Chr(13) + cError //"Erro no método XmlParser: "
			cRetorno += Chr(13) + "XML: " + oWs:cXml
			lErro := .T.
		Else
			
	
			aShopper := {}
			oNodeRes := XmlChildEx ( oRetXML, "_RESULT" ) 
			
			If ValType(oNodeRes) == "O"
				oNodeRet  := XmlChildEx ( oNodeRes, "_RESULTCODE" )  //Node com retorno de Erro
				oNodeMsg := XmlChildEx ( oNodeRes, "_RESULTTEXT" )  //Node com mensagem de Erro
			EndIf
			
			oNodeComp := XmlChildEx ( oRetXML, "_SHOPPERLIST" )   
				
			If ValType(oNodeComp) ==  "O"
				oNodeComp := XmlChildEx ( oNodeComp, "_RESULTCODE" )			
				oNodeShopp := XmlChildEx ( oRetXML, "_SHOPPERLIST" ) 
				If ValType(oNodeShopp) == "O"
					oNodeShopp := XmlChildEx ( oNodeShopp, "_SHOPPER" ) 
				EndIf
				If ValType(oNodeShopp) == "O"
					aAdd( aShopper, oRetXML:_SHOPPERLIST:_SHOPPER)
				ElseIf ValType(oNodeShopp) == "A"
					aShopper := AClone( oRetXML:_SHOPPERLIST:_SHOPPER) 
				EndIf
	   		
			EndIf  
			
		
			If ValType(oNodeRet) == "O" .AND. Val(oNodeRet:TEXT) <> 0
				//Deu erro WebService retornou uma mensagem de erro genérica na tag XML  sem a estrutura do serviço
				lErro := .T.
				If ValType(oNodeMsg) == "O" .AND. !Empty(oNodeMsg:TEXT) 
					cRetorno += Chr(13) + "XML: " + oNodeMsg:TEXT
				EndIf
			ElseIf ValType(oNodeComp) <>  "O"
				lErro := .T.
				cRetorno += Chr(13) + "XML: " + STR0012 //"Erro na Estrutura do XML de retorno"
			Else
	    
		
				If Val(oRetXML:_SHOPPERLIST:_RESULTCODE:TEXT) <> 0
					lErro := .T.
					cRetorno += Chr(13) + "XML: " + oRetXML:_SHOPPERLIST:_RESULTTEXT
				Else
					For nInd := 1 to Len(aShopper)
						If Lj906ClGrv(aShopper[nInd], cSeq, aShopper[nInd]:_CAMPOS_EXTRAS)
							aAdd(aCliOK, aShopper[nInd]:_SHOPPER_ID:TEXT)
						Endif
					Next nInd
				Endif
			Endif
			If ValType(oNodeRes) == "O"
				FreeObj(oNodeRes)
			EndIf
			If ValType(oNodeRet) == "O"
				FreeObj(oNodeRet)
			EndIf
			If ValType(oNodeMsg) == "O"
				FreeObj(oNodeMsg)
			EndIf	
			If ValType(oNodeComp) == "O"
				FreeObj(oNodeComp)
			EndIf	
			If ValType(oNodeShopp) == "O"
				FreeObj(oNodeShopp)
			Else
				oNodeShopp := NIl
			EndIf	
			If ValType(oRetXML) == "O"
				FreeObj(oRetXML)
			EndIf
	
		
		EndIf
	EndIf
	
EndIf

//** Realiza a gravação dos dados recebidos e a confirmação do cadastro
if lContinua .AND. Len(aShopper) > 0 .AND. !lErro
	dbSelectArea("MGM")
	RECLOCK("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC := "LOJA901"
	MGM->MGM_SEQ     := cSeq
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni
	
	MGM->MGM_XMLRET  := cRetorno
	MGM->MGM_HORAFI := Time()
	If !lErro
		MGM->MGM_RESULT := "1"
	Else
		MGM->MGM_RESULT  := "2"
	Endif
	MGM->(msUnLock())

	If  len(aCliOK) > 0
		cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>'
		cXML += '<shopper_resultList xmlns="dsReceipt.xsd">'
		
		For nInd := 1 to len(aCliOK)
			cXML += '<shopper_result'
			
			//Reservado
			cXML += ' xmlns=""'
			
			//Código do cliente na loja virtual
			cXML += ' shopper_id="' + aCliOK[nInd] + '"'
			
			//Processado OK
			cXML += ' processed="1"'
			
			cXML += '/>'
		Next nInd
		
		cXML += '</shopper_resultList>'
		
		IIF(!lAJob, Memowrit('envioConfComp.xml', cXML), )
		
		//Cria classe do WebService
		
		//Consome método
		cXMLConf := cXML
		If !oWs:ConfirmaCompradores(, , @cXML)
			lErro := .T.
			cRetorno :=  STR0013 //"Erro ao consumir o método 'ConfirmaCompradores' do WebService!"
		Else
			IIF(!lAJob, MemoWrit('retornoConfComp.xml', oWs:cXml), )
			
			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )
			
			If !Empty(cError)
				cRetorno := STR0014 + Chr(13) + cError //"Erro no método XmlParser: "##
				cRetorno += Chr(13) + "XML: " + oWs:cXml
				lErro := .T.
			Else
				cRetorno := oWs:cXml
				lErro := !oWs:lConfirmaCompradoresResult
				If !lErro
					//Seta como confirmado os compradores
					MGS->(DbSetOrder(1))
					For nInd := 1 to Len(aCliOK)
						If MGS->(DbSeek(xFilial("MGS") + cSeq + StrZero(Val(aCliOK[nInd]), TAMSX3("A1_COD")[1])))
							RecLock("MGS", .F.)
							MGS->MGS_CONFIR := "1"
							MsUnLock()
						Endif
					Next nInd
					//Grava o xml enviado
					RECLOCK("MGM", .F.)
					MGM->MGM_XMLENV  := cXMLConf
					MGM->(MsUnLock())
				Endif
			Endif
		Endif
	EndIf
Endif

If ValType(oWs) == "O"
	FreeObj(oWs)
EndIf

If SuperGetMV("TT_WSDLXML",,.F.)  
	Lj900XLg(STR0015) //"Desabilitando o Log WSDLXML"
	WSDLSaveXML(.F.)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906ClGrv
Função de Gravação dos Dados dos clientes
@param   	oAComp - Dados do Cliente
@param   	cASeq - Sequencia de Gravação
@param   	oExtra - Campos Extras
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample  Lj906ClGrv(oAComp, cASeq, oExtra)
/*/
//-------------------------------------------------------------------
Static Function Lj906ClGrv(oAComp, cASeq, oExtra)

local lRes      := .F. //retorno da Rotina
local aCli      := {} //Dados de inserção 
local cCodCli   := StrZero(Val(oAComp:_SHOPPER_ID:TEXT), TAMSX3("A1_COD")[1]) //Codigo do Cliente Site
local cCodLoj   := "" //Codigo da Loja
local nOperCli  := 3 //Operação do ExecAuto
local dData		:= NIL //Data
local cNomeCid 	:= "" //Nome da Cidade
local cEstado	:= "" //Estado
local cAliasCid := GetNextAlias() //Alias da Consulta da Cidade
local cSQL		:= "" //Query da Cidade
Local rs 		:= 0 //Contador
Local cBusca 	:= "" //Busca
Local aAreaAnt 	:= {} //WorkArea Anterior
Local nC 		:= 0	//Contador
Local lLJ901SA1	:= ExistBlock("LJ901SA1") // p.e. de inclusão de dados adicionais de cliente
Local aAreaAnt 	:= {} //workArea do PE
Local cInscr 	:= "" //inscrição
Local aCliPE 	:= {} //Dados do Cliente do PE
Local oNodeCompl := NIL //Node do complemento
Local aLog      := {}
Local lMailErr  := !Empty(SuperGetMv("MV_LJECO01",,""))	
Local cRG_CNPJ	:= "" //Conteudo da tag RG/CNPJ
Local lContinua := .T. //Continua o processamento da venda
Local oNodeNasc := NIl //Node de Nascimento
Local cCliente	:= "" //Codigo do Cliente
Local cFilSA1	:= xFilial("SA1")
Local oNodeRG   := NIl //Node do RG
Local oNodeIBGE := Nil
Local lUsaIBGE  := .T.
Local cCodMun   := ""
Local cCodUF    := ""
Local lIniPadCod := ""
Local lIniPadCod := ""

Private lmsErroAuto := .F.
Private lAutoErrNoFile 	:= .T.
Private lMsHelpAuto		:= .T.


RecLock("MGS", .T.)
MGS->MGS_FILIAL  := xFilial("MGS")
MGS->MGS_SEQ     := cASeq
MGS->MGS_CLIENT := cCodCli
MGS->MGS_NOME    := oAComp:_NOME:TEXT

oNodeRG := XmlChildEx ( oAComp, "_RG_CNPJ" )

If ValType(oNodeRG) == "O"	
	cRG_CNPJ := oAComp:_RG_CNPJ:TEXT
Else
	Lj900XLg(STR0016, MGS->MGS_CLIENT ) //"Cliente sem tag RG_CNPJ"
EndIf

If Upper(oAComp:_TIPO:TEXT) == 'F'
	MGS->MGS_CPF := oAComp:_CPF:TEXT
Else
	MGS->MGS_CPF := cRG_CNPJ
EndIf
MGS->MGS_CONFIR := "0"
MGS->(MsUnlock())

If Empty(MGS->MGS_CPF)
	Lj900XLg(STR0017, MGS->MGS_CLIENT )//"Cliente sem CPF/CNPJ"
	lContinua := .F.
EndIf

If lContinua

	Lj900XLg(STR0018 + MGS->MGS_CPF , MGS->MGS_CLIENT)//"Processando o Cliente "
	
	//verifica se é alteração ou inclusão pelo CPF/CNPJ      
	
	aCli := {} 
	
	cBusca := MGS->MGS_CPF
	
	SA1->( dbSetOrder(3) )
	
	
	//se encontrar é alteração
	IF SA1->( dbSeek( cFilSA1 + cBusca ) )
		Lj900XLg("Localizado o cliente  " + SA1->A1_COD + "/" + SA1->A1_LOJA , cValTochar(MGS->MGS_CLIENT))
		cCliente	:=  SA1->A1_COD  //Codigo do Cliente
		cCodLoj		:= SA1->A1_LOJA //Loja do cliente
		nOperCli := 4
		
		aAdd(aCli, {"A1_COD"    , cCliente , ".T."})
		aAdd(aCli, {"A1_LOJA"   , cCodLoj, ".T."})
	Else
	
		lIniPadCod := Empty(GetSX3Cache("A1_COD"	, "X3_RELACAO"))
		lIniPadLoj := Empty(GetSX3Cache("A1_LOJA"	, "X3_RELACAO"))
		
		If lIniPadCod
			Lj901CliCod(@cCliente, @cCodLoj)
			aAdd( aCli, { "A1_COD" 		, cCliente	, Nil })
			aAdd( aCli, { "A1_LOJA"		, cCodLoj	, Nil })
		ElseIf lIniPadLoj
			cCodLoj := StrZero(1, TAMSX3("A1_LOJA")[1])
			aAdd( aCli, { "A1_LOJA"		, cCodLoj	, Nil })
		Endif
	
		nOperCli := 3
		
	EndIF
	
	
	aAdd(aCli, {"A1_NOME"   , Alltrim(Upper(oAComp:_NOME:TEXT)), Nil})
	aAdd(aCli, {"A1_CODPAIS", "01058", ".T."})
	aAdd(aCli, {"A1_NREDUZ" , Upper(oAComp:_NOME:TEXT), Nil})
	aAdd(aCli, {"A1_BAIRRO" , Upper(oAComp:_BAIRRO:TEXT), Nil})
	aAdd(aCli, {"A1_END"    , Upper(oAComp:_ENDERECO:TEXT + ", " + oAComp:_NUMERO:TEXT), Nil})
	
	oNodeCompl := XmlChildEx ( oAComp, "_COMPLEMENTO" )
	
	If ValType(oNodeCompl) == "O"
		Lj900XLg(STR0021 + Upper(oAComp:_COMPLEMENTO:TEXT), MGS->MGS_CLIENT ) //"Cliente com complemento cadastrado "
		
		aAdd(aCli, {"A1_COMPLEM", Upper(oAComp:_COMPLEMENTO:TEXT), Nil})
	Else
		Lj900XLg(STR0022, MGS->MGS_CLIENT ) //"Cliente sem complemento cadastrado "
		
	EndIf
	

	
	//******************************************************************
	//Procura o codigo da cidade pelo nome no cadastro de cidades (IBGE)
	//Se não encontrar deixa em branco, gravando somente o nome da cidade
	
	cNomeCid := STRTRAN(AllTrim(Upper(FwNoAccent(oAComp:_CIDADE:TEXT))),"'","")
	Lj900XLg(STR0023 + cNomeCid , MGS->MGS_CLIENT ) //"Cidade  " 
	
	cEstado  := AllTrim(NoAcento(Upper(oAComp:_ESTADO:TEXT)))
	aAdd(aCli, {"A1_EST", cEstado, NIL}) 
	
//Validação do campo do IBGE
oNodeIBGE := XmlChildEx ( oAComp, "_CODIGO_IBGE_CIDADE" )
If ValType(oNodeIBGE) <> "O" 
	lUsaIBGE := .F.
	Lj900XLg("Sem a Tag do Codigo IBGE." )
EndIf 
	
If lUsaIBGE
	Lj900XLg("Utilização do Codigo IBGE:" + oAComp:_CODIGO_IBGE_CIDADE:TEXT )
	cCodMun := oAComp:_CODIGO_IBGE_CIDADE:TEXT
	cCodUF  := Padr(If( !Empty(cCodMun),SubStr(cCodMun,1,2),""),TamSx3("CC2_EST")[1])
	cCodMun := Padr(If( !Empty(cCodMun),SubStr(cCodMun,3,7),""),TamSx3("CC2_CODMUN")[1])
	
	If FindFunction("Lj901AUF") .And.  cEstado <> Lj901AUF(cCodUF)
		cEstado :=	Lj901AUF(cCodUF)			
	EndIf
	
	CC2->(DbSetOrder(1))
	If !Empty(cCodMun) .And. CC2->(DbSeek(xFilial("CC2") + cEstado +  cCodMun ))
		cNomeCid := AllTrim(CC2->CC2_MUN)	
	Else
		cCodMun := ""
	EndIf
EndIf	

If lUsaIBGE .And. !Empty(cCodMun) 
	aAdd(aCli, {"A1_COD_MUN", cCodMun,nil})
Else	
	cSQL := " SELECT CC2_CODMUN "
	cSQL += " FROM " + RetSqlName("CC2") + " CC2 "
	cSQL += " WHERE CC2_FILIAL = '" + xFilial("CC2") + "' "
	cSQL += " AND CC2_EST = '" + cEstado + "' "
	cSQL += " AND LTRIM(RTRIM(CC2_MUN)) = '" + cNomeCid + "' "
	cSQL += " AND D_E_L_E_T_ <> '*' "
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL),cAliasCid, .F., .T.)
	
	(cAliasCid)->(DBGoTop())
	if !(cAliasCid)->(Eof())
		aAdd(aCli, {"A1_COD_MUN", (cAliasCid)->CC2_CODMUN, Nil})
	else
		aAdd(aCli, {"A1_MUN", cNomeCid, Nil})
	endif
	
	dbSelectArea(cAliasCid)
	dbCloseArea()
EndIf	
	//******************************************************************
	
	aAdd(aCli, {"A1_CEP"    , Upper(oAComp:_CEP:TEXT), Nil})
	aAdd(aCli, {"A1_TIPO"   , "F", Nil})
	
	if Empty(AllTrim(oAComp:_DATA_CADASTRO:TEXT))
		dData := Date()
	else
		dData := Lj901DtWS(oAComp:_DATA_CADASTRO:TEXT)
	endif
	aAdd(aCli, {"A1_DDD"    , oAComp:_DDD:TEXT, Nil})
	aAdd(aCli, {"A1_TEL"    , oAComp:_TELEFONE:TEXT, Nil})
	aAdd(aCli, {"A1_EMAIL"  , Upper(oAComp:_EMAIL:TEXT), Nil})
	
	oNodeNasc := XmlChildEx ( oAComp, "_NASCIMENTO" )
	
	IF  (Upper(oAComp:_TIPO:TEXT) == 'F' .AND. ( ValType(oNodeNasc) <> "O" .OR. Empty(AllTrim(oAComp:_NASCIMENTO:TEXT))) )  .OR.  ;
		( ValType(oNodeNasc) <> "O" .OR. Empty(AllTrim(oAComp:_NASCIMENTO:TEXT)))
		dData := CTOD("//")
	Else
		dData := Lj901DtWS(oAComp:_NASCIMENTO:TEXT)
	EndIf

	

	
	aAdd(aCli, {"A1_DTNASC" , dData, Nil})
	aAdd(aCli, {"A1_PESSOA" , Upper(oAComp:_TIPO:TEXT), Nil})
	
	IF Upper(oAComp:_TIPO:TEXT) == 'F'
		aAdd(aCli, {"A1_PFISICA" , cRG_CNPJ, Nil})
		aAdd(aCli, {"A1_CGC"     , oAComp:_CPF:TEXT, Nil})
		aAdd(aCli, {"A1_INSCR"  , "ISENTO", ".T."})
		cBusca := RetNum(oAComp:_CPF:TEXT)
	Else
		aAdd(aCli, {"A1_CGC"     , cRG_CNPJ, Nil})
		cInscr := Upper(AllTrim(oAComp:_CPF:TEXT))
		
		//Verifica se IE em branco para jogar isento
		If Empty(cInscr)
			Lj900XLg(STR0024, MGS->MGS_CLIENT ) //"Inscrição em branco para pessoa juridica, considerado ISENTO"
			cInscr := "ISENTO"
		EndIf
		
		aAdd(aCli, {"A1_INSCR"  ,  cInscr, ".T."})
		cBusca := RetNum(cRG_CNPJ)
	EndIF
	
	aAdd(aCli, {"A1_MSBLQL"  , "2", Nil})
	
	If lLJ901SA1 // p.e. de inclusão de dados adicionais de cliente
	
		Lj900XLg(STR0025 + "LJ901SA1" , MGS->MGS_CLIENT, aCli ) //"Executando p.E. "
		aAreaAnt := GetArea()
		//Retorno dos dados adicionais de pedido, onde o retorno deve ser
		//Array contendo a seguinte estrutura
		//aCli[n] , onde
		//aCli[n] [nLin, 01] // Nome do campo
		//aCli[n] [nLin, 02] // Valor do Campo
		//aCli[n] [nLin, 03] // Nil
		aCliPE := ExecBlock("LJ901SA1",.f., .f., { 1, aCli, oAComp, NIL })
		
		If Len(aCliPE) > 0
			aCli := aClone(aCliPE)
		EndIf
	
		Lj900XLg(STR0026 + "LJ901SA1", MGS->MGS_CLIENT, aCliPE ) //"Executado p.E. "
			
		RestArea(aAreaAnt)
	EndIf
	
	//volta para ordem 1
	SA1->( dbSetOrder(1) )
	
	Begin Transaction
	
	MsExecAuto({|x,y| Mata030(x,y)}, aCli, nOperCli)
	

	
	IF lMsErroAuto	
		For rs := 1 to len(aCli)
			AutoGrLog( " " + aCli[rs,1] + ": " + cValToChar(aCli[rs,2]) )
		Next rs	
		DisarmTransaction()	
		RollBackSX8()
		aLog := GetAutoGrLog()
		If lMailErr			
			If ExistFunc("Ljx904ErrE")
				Ljx904ErrE(aLog,1,"CLIE")
			EndIf		
		EndIf
		Lj900XLg("Problemas na rotina automatica MATA030 " +  GeraErro(aLog),  MGU->MGU_PEDECO)			
	Else
		ConfirmSX8()
		lRes := .T.
		Lj900XLg("Gerando o cliente  " + SA1->A1_COD + "/" + SA1->A1_LOJA, cValTochar(MGS->MGS_CLIENT))
	EndIF
	
	End Transaction

	If ValType(oNodeCompl) == "O"
		FreeObj(oNodeCompl)
	EndIf

	If ValType(oNodeNasc) == "O"
		FreeObj(oNodeNasc)
	EndIf
EndIf

If ValType(oNodeRG) == "O"
	FreeObj(oNodeRG)
EndIf

Return lRes
	
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901DtWS
Converte a Data recebida do WS
@param   	cAData - Data
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj901DtWS(cAData)
/*/
//-------------------------------------------------------------------

Static function Lj901DtWS(cAData)

local cData := "" //Data

cData += SubStr(cAData, 1, 4)
cData += SubStr(cAData, 6, 2)
cData += SubStr(cAData, 9, 2)

return SToD(cData)

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ClDes()
Método para desconfirmar compradores (Clientes) 
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj901ClDes()
/*/
//-------------------------------------------------------------------
Function Lj901ClDes()

Local cXML     := "" //XML Envio
Local oWS		:= NIL //WS
Local oRetXML := NIL //Retorno parseado          
Local cError   := "" //Erro
Local cWarning := "" //Alterta
Local cRetorno := "" //Retorno
Local cSeq     := "" //Sequencia
local nInd		:= 0 //Indice
local aCliOK   := {} //Cliente executado
local cConCont  := "" //Contato
oWS := Lj904WS( )

aAdd(aCliOK, '1')

cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>'
cXML += '<shopper_resultList xmlns="dsReceipt.xsd">'

for nInd := 1 to len(aCliOK)
	cXML += '<shopper_result'
	
	//Reservado
	cXML += ' xmlns=""'
	
	//Código do cliente na loja virtual
	cXML += ' shopper_id="' + aCliOK[nInd] + '"'
	
	//Processado OK
	cXML += ' processed="0"'
	
	cXML += '/>'
next nInd

cXML += '</shopper_resultList>'

Memowrit('envioDesconfirmaComp.xml', cXML)

//Cria classe do WebService

//Consome método
if !oWs:ConfirmaCompradores(, , @cXML)
	cRetorno := STR0009 // "Erro ao consumir o método 'ConfirmaCompradores' do WebService!"
else
	MemoWrit('retornoDesconfirmaComp.xml', cXML)
	
	//Retorna o XML parseado em um objeto com as tags em variáveis
	oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )
	
	if !Empty(cError)
		cRetorno := STR0010 + Chr(13) + cError // "Erro no método XmlParser: "
	else
		cRetorno := oWs:cXml
		oWs:lConfirmaCompradoresResult	
	endif
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901Tst
Função de retorno do XML de Teste
@return cXMLTeste - XML de Teste
@author  Varejo
@version 	P11.8
@since   	13/04/2017
@obs     
@sample  Lj901Tst()
/*/
//-------------------------------------------------------------------
Static Function Lj901Tst()
Local cXMLTeste := "" //XML de Teste
Local cFile 	:= "" //Arquivo de Teste

cFile :=  cGetFile(STR0033 + " | *.xml",STR0034,,'C:\',.F.) //"Arquivo XML"##"Abrir Arquivo XML"

If !Empty(cFile) .AND. File(cFile)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faco a abertura do arquivo TXT.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUSE( cFile )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avanco para a primeira linha.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FGOTOP()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrego todos os registros do TXT para o aCols.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !FT_FEOF()
		cXMLTeste += FT_FREADLN() //Leitura da linha
		
		FT_FSKIP()
	EndDo
	FT_FUSE()
EndIf

Return cXMLTeste

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901CliCod()
Gera o código do cliente
@param cCliente - Codigo do Cliente
@param cCodLoj - Loja do Cliente
@author  Varejo
@version 	P11.8
@since   	10/05/2017
@obs     
@sample  Lj901CliCod(@cCliente, @cCodLoj)
/*/
//-------------------------------------------------------------------
Function Lj901CliCod(cCliente, cCodLoj)
Local aAreaSA1  := {}
Local cFilSA1	:= xFilial("SA1")

Default cCliente:= ""
Default cCodLoj := ""

cCliente	 :=  CriaVar("A1_COD")
cCodLoj		 :=  CriaVar("A1_LOJA")  //Loja do cliente
If Empty(cCliente)
	cCliente := GETSX8NUM("SA1","A1_COD")    
EndIf
If Empty(cCodLoj)
	cCodLoj := StrZero(1, TAMSX3("A1_LOJA")[1])
EndIf
aAreaSA1 := SA1->(GetArea())
//Verifica se não existe a chave duplicada no banco de dados

SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

Do While  SA1->(DbSeek(cFilSA1 + cCliente + cCodLoj))
	cCliente	:=  CriaVar("A1_COD")  //Codigo do Cliente
	If Empty(cCliente)
		//confirma a numeração anterior
		ConfirmSX8()
		cCliente := GETSX8NUM("SA1","A1_COD")    
	EndIf
	If Empty(cCodLoj)
		cCodLoj := StrZero(1, TAMSX3("A1_LOJA")[1])
	EndIf
EndDo

RestArea(aAreaSA1)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraErro
Converte o Erro de String
@param aErro	Array de Erro
@param cValue		Tabela

@author  Varejo
@version P11.8
@since   05/05/2015
@return  cErro 	Mensagem de Erro
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function GeraErro(aErro)

Local cErro := ""
Local nX := 1

For nX := 1 to Len(aErro)

	cErro += aErro[nX] + CRLF
Next nx
	
Return cErro

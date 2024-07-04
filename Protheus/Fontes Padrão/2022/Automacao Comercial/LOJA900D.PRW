#INCLUDE "LOJA900D.ch"
#Include 'Protheus.ch'
#include 'protheus.ch'

/*
	DESCRICAO
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ECOM007
Função de teste integracao Protheus e-commerce CiaShop envio de deparamentos 
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM007 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja900D(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900D
Função de teste integracao Protheus e-commerce CiaShop envio de Descricao de Produtos
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900D(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900D" //Rotina
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

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	LJ900DPr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]")
	EndIf

	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900DPr(lAJob, lCallStack)
Função de teste integracao Protheus e-commerce CiaShop envio de Descrição de Produtos
@param   	lAJob- Execução em Job - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------

Function LJ900DPr(lAJob, lCallStack)

	local cXML     := "" //XML de Envio
	Local cError   := "" //Erro do Parser
	Local cWarning := "" //Alerta do Parser
	local oRetXML	:= NIL //Retorno Parseado
	local cAlias	:= ""	//Alias da Consulta
	local cSeq     := "" //Sequencia de Execução da Rotina
	local lErro    := .F. //Erro de Execução da Rotina
	local cRetorno := "" //XML de Retorno
	local cCarac   := "" //Característica
	local cApres 		:= "" //Apresentação
	local cBenef  	:= "" //Benefícios
	local cIndic  	:= "" //Indicação
	Local cVar      := "" //Descrição
	Local cTitulo := "" //Titulo
	Local i 		:= 0		//Contador
	Local oWS 		:= NIL //Objeto WebService
	Local aRecSB5 	:= {} //Registros atualizados
	Local dDataIni 	:= Date() //Data Inicial do Job
	Local cHoraIni 	:= Time() //Hora Inicial do Job
	Local nTotRecSB5:= 0 //Contador de Registros enviados
	Local nI 		:= 0 //Contador
	Local cOper 	:= "" //Operação do registro
	Local lLock 	:= .F. //Registro bloqueado
	Local lEnvCampo := .F. //Envia compo
	Local lPe900DGP := ExistBlock("Lj900DGP") //Ponto de Entrada de Envido da descrição do produto
	Local lProcProd := .T. //Produto a ser processado
	Local lNoProdPE := .F. //Produto não enviado devido a Ponto de Entrada
	Local lEnviaDesc :=  SuperGetMV( "MV_LJECDES",, "2" ) == "1"
	Local cTitulo1 := STR0010 //"Característica"
	Local cTitulo2 := STR0011 //"Apresentação"
	Local cTitulo3 := STR0012 //"Benefícios"
	Local cTitulo4 := STR0013 //"Indicação"

	
	Default lAJob := .F.
	Default lCallStack := .F.
	
	oWS := Lj904WS( )
	cAlias  := GetNextAlias()

	//Consulta as caracteristicas de produtos que deverão ser enviadas
	Lj900DCE(cAlias, lCallStack)

	//Resultado da sincronização
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()

	
	If lEnviaDesc
		cTitulo1 := GetSx3Cache("B5_ECCARAC","X3_DESCRIC")
		cTitulo2 := GetSx3Cache("B5_ECAPRES","X3_DESCRIC")
		cTitulo3 := GetSx3Cache("B5_ECBENFI","X3_DESCRIC")
		cTitulo4 := GetSx3Cache("B5_ECINDIC","X3_DESCRIC")
	 EndIf

	//Log de registros enviados
	dbSelectArea("MGQ")

	//Cadastro de produtos
	dbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())

	while !(cAlias)->(EOF())
	
		lProcProd := .T.
	
		If lPe900DGP
			lProcProd := ExecBlock("Lj900DGP",.F.,.F., { SB5->B5_COD })
		EndIf

		aAdd(aRecSB5, { (cAlias)->B5_REC, lProcProd} )
		SB5->(DbGoTo((cAlias)->B5_REC))
		
				


		If lProcProd
		
			cCarac := ""
			cApres := ""
			cBenef := ""
			cIndic := ""
			cOper := ""
			/*cCarac := _Notags(StrTran( Alltrim(Left(SB5->B5_ECCARAC, 2500)),  CRLF, "</br>"))
			cApres := _Notags(StrTran( Alltrim( Left(SB5->B5_ECAPRES,2500)),  CRLF, "</br>"))
			cBenef := _Notags(StrTran( Alltrim( Left(SB5->B5_ECBENFI,2500)),  CRLF, "</br>"))
			cIndic := _Notags(StrTran( Alltrim(Left(SB5->B5_ECINDIC,2500)),  CRLF, "</br>"))*/
			cCarac := _Notags(StrTran( Alltrim(Left(SB5->B5_ECCARAC, 8000)),  CRLF, "<br>"))
			cApres := _Notags(StrTran( Alltrim( Left(SB5->B5_ECAPRES,8000)),  CRLF, "<br>"))
			cBenef := _Notags(StrTran( Alltrim( Left(SB5->B5_ECBENFI,8000)),  CRLF, "<br>"))
			cIndic := _Notags(StrTran( Alltrim(Left(SB5->B5_ECINDIC,8000)),  CRLF, "<br>"))
	
			lEnvCampo := .F.
			For i :=1  To  4
	
				If i == 1	
					cVar := cCarac
					cTitulo := cTitulo1
				Elseif i == 2 
					cVar := cApres
					cTitulo := cTitulo2
				Elseif i == 3 
					cVar := cBenef
					cTitulo := cTitulo3
				elseif i == 4  
					cVar := cIndic
					cTitulo := cTitulo4
				Endif
	 
	 			cVar := alltrim(cVar)

				cOper := "U"
				Lj900XLg(" Campo " + cTitulo + " Operacao " + cOper, "LOJA900D - Consultando o produto " + SB5->B5_COD)
								
				If !Empty(cOper)
					//Montagem do XML
					lEnvCampo := .T.
					
					cXML += '<descricao'
		
					//Reservado
					cXML += ' xmlns=""'
		
		 			//Código do produto
		           If ((cAlias)->B5_COD == (cAlias)->B1_PRODPAI)
						cXML += ' pf_id="' + "VAR"+alltrim((cAlias)->B5_COD) + '"'
					else
						cXML += ' pf_id="' + alltrim((cAlias)->B5_COD) + '"'
					Endif
		
					//Título
					cXML += ' title="' + alltrim(cTitulo) + '"'
		
					//Descrição (Texto)
					cXML += ' description="' + cVar + '"'
		
					//Bloqueado
					cXML += ' bloqueado="N"'
		
					//Operação: I - Incluir
					//          D - Deletar
					//          U - Atualizar
					cXML += ' op="' + cOper  + '"'
		
					cXML += '/>'
				EndIf
	
			Next i
		
	
			//Insere no final pois esta dando problemas na verificação de atualização
			//Inclui na tabela MGQ (Log)
			//So grava se houve alteração no campo
			If lEnvCampo
				RecLock("MGQ", .T.)
				MGQ->MGQ_FILIAL  := xFilial("MGQ")
				MGQ->MGQ_SEQ     := cSeq
				MGQ->MGQ_PRODUT := SB5->B5_COD
				MGQ->MGQ_CARAC   := cCarac
				MGQ->MGQ_APRESE := cApres
				MGQ->MGQ_BENEFI := cBenef
				MGQ->MGQ_INDICA := cIndic
				MGQ->(MsUnLock())
			EndIf
			
		Else
			Lj900XLg( "Produto não enviado para integração em virtude do P.E. Lj900DGP", AllTrim(SB5->B5_COD))
			lNoProdPE := .T.
		EndIf
		(cAlias)->(DBSkip())
		
		IF LEN(cXML) > 50000 //50 mil
			Exit
		EndIF

	EnDdo

	(cAlias)->(DbCloseArea())

	if !Empty(cXML)
		cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>' +;
			'<descricaoList xmlns="dsReceipt.xsd">' +;
			cXML +;
			'</descricaoList>'
	endif

	//Somente comunica se há descrições para enviar
	if !Empty(cXML)
		iif(!lAJob, Memowrit('envioDescr.xml', cXML), )

		//Consome método
		if !oWs:Descricao(, , cXML)
			lNoProdPE := .F.
			lErro := .T.
			cRetorno := STR0008 //"Erro ao consumir o método 'Descricao' do WebService!"
		else
			iif(!lAJob, MemoWrit('retornoDescr.xml', oWs:cXml), )

			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )

			if !Empty(cError)
				cRetorno := STR0009 + Chr(13) + cError //"Erro no método XmlParser: "
				cRetorno += Chr(13) + "XML: " + oWs:cXml
				lErro := .T.
				lNoProdPE := .F.
			else
				cRetorno := oWs:cXml
				lErro := !oWs:lDescricaoResult
				If !lErro
					lNoProdPE := .F.
				EndIf
			endif
		endif
	
		dbSelectArea("MGM")
		RECLOCK("MGM", .T.)
		MGM->MGM_FILIAL  := xFilial("MGM")
		MGM->MGM_SERVIC := "LOJA900D"
		MGM->MGM_SEQ     := cSeq
		MGM->MGM_DATA    := dDataIni
		MGM->MGM_HORAIN  := cHoraIni
		MGM->MGM_XMLENV := cXML
		
		MGM->MGM_XMLRET  := cRetorno
		MGM->MGM_HORAFI := Time()
		if !lErro
			MGM->MGM_RESULT := "1"
		Else
			MGM->MGM_RESULT  := "2"
		endif
		MGM->(msUnLock())
	endif


    
    //Atualiza os registros selecionados
	IF !lErro  .or. lNoProdPE
		nTotRecSB5 := len(aRecSB5)
		For nI := 1 to nTotRecSB5
			SB5->(DbGoTo(aRecSB5[nI, 01])) 
			lLock := .F.
			lLock := 	Lj900XRL("SB5", .F., "LOJA900D")
			
			If lLock
				SB5->B5_ECDTEX2 := Dtos(Date())
				If aRecSB5[nI, 02]
					SB5->B5_ECSEQ2 := cSeq
				EndIf
				SB5->(MsUnLock() )
			EndIf
		Next nI
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900DCE
Seleciona os registros a serem enviados a descrição 
@param   	cAAlias - Alias da Consulta
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900DCE(cAAlias
/*/
//-------------------------------------------------------------------
Static Function Lj900DCE(cAAlias, lCallStack)

	local cQuery := "" //String de Consulta
	Default lCallStack := .F.

	cQuery += " SELECT B5_COD, SB1.B1_PRODPAI, SB5.R_E_C_N_O_ AS B5_REC "
	cQuery += " FROM " + RetSqlName("SB5") + " SB5,  "  + RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE B5_COD = B1_COD "
	cQuery += " AND B5_FILIAL = '" + xFilial("SB5") + "' "
	cQuery += " AND B5_ECFLAG <> ' ' AND B5_ECDTEX2 = ' ' AND B5_ECSEQ <> ' ' "
	cQuery += " AND SB5.D_E_L_E_T_ <> '*' "
	cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAAlias, .F., .T.)
	
If lCallStack 
	 Lj900XRC( cAAlias, "LOJA900D")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900DGO
Retorna a operação a ser enviada para o XML I, U,D
@param   	cAProd - Codigo do Produto
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
static function Lj900DGO(cAProd, cVar, i)

	local cQuery   := "" //String de Consulta
	local cAliaLoc := GetNextAlias() //Alias da Query
	local cRet     := "I" //Retorno da Rotina
	Local cCampo := ""
	Local aAreaMGQ := MGQ->(GetArea())
	Local cValor   := ""
	
	Do Case
		Case i == 1
			cCampo := "MGQ_CARAC"
		Case i == 2
			cCampo := "MGQ_APRESE"
		Case i == 3
			cCampo := "MGQ_BENEFI"
		Case i == 4
			cCampo := "MGQ_INDICA"
	EndCase
	
	
	Default cVar := ""
	Default i := 1

	cQuery += " SELECT  MGQ.R_E_C_N_O_ AS MGQREG "
	cQuery += " FROM  " + RetSqlName("MGQ") + " MGQ "
	cQuery += " INNER JOIN " + RetSqlName("MGM") + " MGM "
	cQuery += " ON MGM.MGM_FILIAL = MGQ.MGQ_FILIAL "
	cQuery += " AND MGM.MGM_SEQ = MGQ.MGQ_SEQ "
	cQuery += " AND MGM.D_E_L_E_T_ <> '*' "
	cQuery += " AND MGM.MGM_RESULT = '1' "
	cQuery += " WHERE MGQ.MGQ_FILIAL = '" + xFilial("MGQ") + "' "
	cQuery += " AND MGQ.MGQ_PRODUT = '" + cAProd + "' "
	cQuery += " AND MGQ.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY MGQREG DESC "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliaLoc, .F., .T.)

	if !(cAliaLoc)->(Eof())
		aAreaMGQ := MGQ->(GetArea())
		
		MGQ->(DbGoTo((cAliaLoc)->MGQREG))
		
		cValor := AllTrim(MGQ->(FieldGet(FieldPos(cCampo))))
		If !Empty(cValor) //Se for vazio o campo é inclusão
			If !Empty(cVar)
				If cVar <> cValor 
					cRet := "U"
				Else
					cRet := ""
				EndIf
			Else
				If cVar <> cValor 
					cRet := "D"
				Else
					cRet := ""
				EndIf
			EndIf
		Else
			If Empty(cVar)
				cRet := ""
			EndIf
		EndIf
		RestArea(aAreaMGQ)
	Else
		If Empty(cVar)
			cRet := ""
		EndIf
	endif

	(cAliaLoc)->(DbCloseArea())

return cRet
 
 
 
 
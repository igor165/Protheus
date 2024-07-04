#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA900I.CH"
#INCLUDE "FWCOMMAND.CH"
/*
	Job de envio
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900I
Função de teste integracao Protheus e-commerce CiaShop envio de cadastros de Filiais e Armazéns
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900I(uParam, cFil)
local _lJob 		:= .F. //Execução em Job
Local _cEmp 		:= nil //Empresa
Local _cFil 		:= nil //Filial
Local cFunction 	:= "LOJA900I" //Rotina
Local lLock 		:= .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack 	:= .T. 							//Se esta rotina estiver configurada, independente de job ou scheduler, será considerada uma pilha de chamadas
Local cName := "" //Chave de travamento
Local cMessage := ""

DEFAULT uParam := nil
DEFAULT cFil := NIL

If Valtype(uParam) != "A" 
	If ValType(uParam) <> "C" .AND. !Empty(cEmpAnt)
		_cEmp := cEmpAnt
		_cFil := cFilant
	Else
		_cEmp := uParam
		_cFil := cFil
		_lJob  := .T.
	EndIf
Else

	_lJob :=  .T.
	_cEmp := uParam[1]
	_cFil := uParam[2]
EndIf

//Aguarda para evitar erro de __CInternet
Sleep(5000)

If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf


//Gera SEMAFORO - para não dar erro de execução simultanea
cName := cFunction+cEmpAnt+cFilAnt
oLJCLocker  := LJCGlobalLocker():New()	
lLock := oLJCLocker:GetLock( cName )


If lLock  

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.F., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf
	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + STR0002 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" + ###" - EM: "
	
	LJ900IPr(_lJob, lCallStack)
	
	Lj900XLg( STR0003 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + STR0002 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###  "###" - EM: "###" - "
	
Else
	If !IsBlind()
		MsgAlert( STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]") //"Já existe execução da Rotina " 
	EndIf

	Lj900XLg(STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  )	 //"Já existe execução da Rotina " 
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900IPr(_lJob, lCallStack)
Função de integracao Protheus e-commerce CiaShop envio de filiais e armazéns
@param   	lAJob- Execução em Job - Default .f.
@param		lCallStack - Execução em pilha de chamadas default .F.
@author  Varejo
@version 	P11.8
@since   	13/12/2016
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Function LJ900IPr(lAJob, lCallStack) 

	Local cSeq      	:= "" //Sequencia de Execução
	Local lErro     	:= .F. //Erro WS
	Local dDataIni 	:= Date() //Data Inicial do Job
	Local cHoraIni 	:= Time() //Hora Inicial do Job
	Local bFiltro 	:= {}//Filtro das Lojas
	Local aLojas 		:= {} //Array de Lojas
	Local aConnJson	:= IIF(ExistFunc("LOJX904CUT"), LOJX904CUT(), Array(2))  //Dados Json da Conexão
	Local nC 			:= 0 //Contador
	Local cCond 		:= "" //Condição de filtro
	Local oObjFil 	:= NIL //Objeto de Filiais
	Local aObjFil 	:= {} //Array de Filiais
	Local oObjArm 	:= NIL //Objeto de Armazens
	Local aObjArm 	:= {} //Aray de Armazens
	Local cMensagem	:= ""
	Local aAreaSLJ   := {}
		
	Default lAJob := .F.
	Default lCallStack := .F.
	
	
	
If !Empty(aConnJson[1]) .AND. !Empty(aConnJson[2])

	If SLJ->(ColumnPos("LJ_ECFLAG") > 0  .AND. ColumnPos("LJ_ECDTEX") > 0) 
		bCond := { || LJ_FILIAL == xFilial("SLJ") .AND. LJ_ECFLAG = "1" .AND. ( LJ_ECDTEX = "        "  .OR. LJ_ECDTEX = " " .OR. LJ_ECDTEX = "" ) }
		cCond := "LJ_FILIAL == '" + xFilial("SLJ") + "' .AND. LJ_ECFLAG = '1' .AND. ( LJ_ECDTEX = '        '  .OR. LJ_ECDTEX = ' ' .OR. LJ_ECDTEX = ''  ) "
		
		aAreaSLJ := SLJ->(GetArea())
		SLJ->(DbSetOrder(3))	//LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL - Cod.Empresa + Cod.Filial  
	
		
		SLJ->(DbSetFilter(bCond, cCond))
	
		SLJ->(DbGoTop())
	
			While !SLJ->(Eof())
				aLocais := {}
			
				aLocais := StrTokArr ( StrTran(SLJ->LJ_LOCAL, " ", ""), ",") //Ja retira espaços em branco para não dar alltrim toda hora
				
				aAdd(aLojas, { SLJ->LJ_CODIGO, .T., SLJ->LJ_ECIDFIL,  SLJ->LJ_RPCFIL, aClone(aLocais)} )
			
				SLJ->(DbSkip())
			
			End
		
		SLJ->(DbClearFilter())
		RestArea(aAreaSLJ)
	EndIf	
	If Len(aLojas) > 0
		//Retorna as filiais cadastradas
		 oObjFil := Ljx904JsOb("branches/", "Get", , aConnJson, )
		//Filiais Incluídas
		If ValType(oObjFil) == "A"
			aObjFil := aClone(oObjFil)
		ElseIf  ValType(oObjFil) == "O" 
			aAdd(aObjFil, oObjFil)
		EndIf		

		//Retorna os armazens cadastrados
		 oObjArm := Ljx904JsOb("warehouses/", "Get", , aConnJson,)
		//Filiais Incluídas
		If ValType(oObjArm) == "A"
			aObjArm := aClone(oObjArm)
		ElseIf  ValType(oObjArm) == "O" 
			aAdd(aObjArm, oObjArm)
		EndIf			
	EndIf
	
	SLJ->(DbSetOrder(1)) //Filial + Loja
	For nC := 1 To Len(aLojas)
		Lj900IFArm(@aLojas[nC], aConnJson, aObjFil, aObjArm)

	Next nC 
	
	If oObjFil <> NIL
		oObjFil := NIL
	EndIf
	
	If oObjArm <> NIL
		oObjArm := NIL
	EndIf
Else
	cMensagem := STR0007 + CRLF + STR0008 + cEmpAnt  + STR0009 + cFilAnt + "]" ////"Token não encontrado no Cadastro de Lojas (LOJA080)."##"Verifique se está cadastrado para Empresa LJ_RPCEMP["##"] e Filial LJ_RPCFIL["
	Lj900IInc( "", "", cMensagem, "", "")
	Lj900XLg( cMensagem ) 
EndIf
	

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900IFArm(aLoja, aConnJson, aObjFil, aObjArm)
Realiza o envio de filiais e armazéns por API
@param   	aLoja -  Array com os dados da loja onde [01] - Filial, [02] - Array de armazéns
@param		aConnJson - Dados da Conexão Json (api)
@param		aObjFil - Objetos com as filiais cadastradas
@param		aObjArm - Objetos com os armazéns cadastrados
@author  Varejo
@version 	P11.8
@since   	13/12/2016
@obs     
@sample Lj900IFArm(aLoja, aConnJson, aObjFil, aObjArm)
/*/
//-------------------------------------------------------------------
Static Function Lj900IFArm(aLoja, aConnJson, aObjFil, aObjArm)
Local nC  			:= 0 //contador de armazém
Local oObj 		:= "" //Objeto Json de retorno
Local cMsgErro 	:= "" //mensagem de erro 
Local lIncFil 	:= .F. //Filial a ser incluída
Local cJson 		:= "" //String Json de cadastro
Local cRetorno 	:= "" //Retorno do método de envio
Local aArmEnd 	:= {} //Array de dados do armazem da filial
Local nPosArm 	:= 0 //Posição do armazém cadastrado
Local cCodArmz 	:= "" // código do armazém
Local nIdFilial 	:= 0 //Codigo da Filial
Local cNomeArmz 	:= "" //Nome do armazém
Local aDados		:= {} //Cria os dados Json
Local aDados2		:= {} //Cria Dados Json
Local aAreaNNR 	:= NNR->(GetArea()) //WorkArea do Armazém

	nIdFilial := aLoja[03]
	//Busca dados da filial
	aFilial := FWArrFilAtu(, aLoja[04])	
	//Verifica se o armazém deve ser incluído
	
	
	//Verifica se a loja foi Incluída
	lIncFil := ( nC := aScan(aObjFil, { |o| RTrim(o:erpId) = RTrim(aLoja[04])}) ) = 0
	If !lIncFil .AND. aLoja[03] = 0
		nIdFilial := aObjFil[nC]:Id
		If ValType(nIdFilial) = "C"
			nIdFilial := Val(nIdFilial)
		EndIf
	

	EndIf

	If lIncFil

		Ljx904JCria(@aDados)
		Ljx904JAdd("name", "ATT", RTrim(aFilial[SM0_NOMRED]), @aDados)
		Ljx904JAdd("erpId", "ATT", RTrim(aLoja[04]), @aDados)
		Ljx904JAdd("documentId", "ATT", StrTran(StrTran(StrTran(aFilial[SM0_CGC], "."), "-"), "/"), @aDados)

		
		cJson := Ljx904JBuild(@aDados)
		cMsgErro := ""
		cRetorno := ""
		oObj := Ljx904JsOb("branches/", "Post", cJson, aConnJson, @cMsgErro, @cRetorno )
		
		If !Empty(cMsgErro)
			cRetorno := cMsgErro
			aLoja[02] := .F. //Erro na rotina
		Else
			nIdFilial := oObj:Id
			If ValType(nIdFilial) = "C"
				nIdFilial := Val(nIdFilial)
			EndIf
		EndIf	
	EndIf
	
	If aLoja[03] = 0 .AND. nIdFilial > 0  .AND. ;
		SLJ->(DbSeek(xFilial("SLJ") + aLoja[01]))
				RecLock("SLJ", .F.)
				SLJ->LJ_ECIDFIL := nIdFilial
				SLJ->(MsUnLock())
	EndIf
	
	If lIncFil .OR. !Empty(cMsgErro)
	
		Lj900IInc( cJson, cRetorno, cMsgErro, "branches/", "Post")
		//Resultado da sincronização

	EndIf
	
	If aLoja[02]
		If !Empty(cMsgErro)
			cRetorno := cMsgErro
			aLoja[02] := .F. //Erro na rotina
		Else
			aArmEnd := LjxArmEnd(aFilial[SM0_RECNO])
			For nC := 1 to Len(aLoja[5])
			//Verifica se existe o armazen
				cCodArmz := Ljx904Arm(aLoja[04],aLoja[05][nC] )
				NNR->(DbSetOrder(1)) //NNR_FILIAL + NNR_CODIGO
				
				nPosArm := aScan(aObjArm, { |a| RTrim(a:erpId) = cCodArmz})
				If nPosArm = 0  
				
					If NNR->(DbSeek(xFilial("NNR", aLoja[04])+aLoja[05][nC]))
						//Inclui o armazem
						cNomeArmz := NNR->NNR_DESCRI
						Ljx904JCria(@aDados)
						
					
						Ljx904JAdd("erpId","ATT", cCodArmz, @aDados)
						Ljx904JAdd("name", "ATT", RTrim(cNomeArmz), @aDados)
						
						Ljx904JCria(@aDados2)
						Ljx904JAdd("erpId", "ATT", RTrim(aLoja[04]), @aDados2)
						Ljx904JAdd("branch", "OBJ", aDados2, @aDados)
						
						Ljx904JCria(@aDados2)
						
					   Ljx904JAdd("street", "ATT",aArmEnd[01], @aDados2)
					   If Valtype(aArmEnd[02]) = "N"
					   		aArmEnd[02] := AllTrim(PadL(AllTRim(Str(aArmEnd[02])),10))
					   	EndIf
					   If Empty(aArmEnd[02])
					   		aArmEnd[02] := "SN"
					   EndIf
						Ljx904JAdd("streetNumber", "ATT",aArmEnd[02], @aDados2)
						Ljx904JAdd("streetComplement", "ATT",RTrim(PadR(aArmEnd[03],20)), @aDados2)
						Ljx904JAdd("district", "ATT",aArmEnd[04], @aDados2)
						Ljx904JAdd("city", "ATT",aArmEnd[05], @aDados2)
						Ljx904JAdd("state", "ATT",aArmEnd[06], @aDados2)
						Ljx904JAdd("zipCode", "ATT",aArmEnd[07], @aDados2)
						
						Ljx904JAdd("address","OBJ", aDados2, @aDados)
						
						cJson := Ljx904JBuild(@aDados)
						cMsgErro := ""
						cRetorno := ""
						oObj := Ljx904JsOb("warehouses/", "Post", cJson, aConnJson, @cMsgErro, @cRetorno )
					Else
						cMsgErro := STR0005 + aLoja[05][nC] + STR0005 + aLoja[04] + "]"//"Armazém["##"] não cadastrado para a filial ["
					EndIf
					If !Empty(cMsgErro)
						cRetorno := cMsgErro
						aLoja[02] := .F. //Erro na rotina
					EndIf
					
					Lj900IInc( cJson, cRetorno, cMsgErro, "warehouses/", "Post")
					If !aLoja[02]
						Exit
					EndIf
					

				EndIf
			Next nC
		EndIf
	EndIf
	
	If aLoja[02]
		If SLJ->(DbSeek(xFilial("SLJ") + aLoja[01]))
				RecLock("SLJ", .F.)
				SLJ->LJ_ECDTEX := DtoS(Date())
				SLJ->(MsUnLock())
		EndIf
	EndIf
	
	If Valtype(oObj) = "O"
		FreeObj(oObj)
	EndIf
	
	RestArea(aAreaNNR)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900IInc(cJson, cRetorno, cMsgErro)
Função de Inclusão do Log de envio dos dados
@param   	cJson -  Texto Json envio
@param		cRetorno - Mensagem de Retorno
@param		cMsgErro - Mensagem de erro
@param		cMetodo - Método da API
@param		cTipo - Tipo da Mensagem
@author  Varejo
@version 	P11.8
@since   	13/12/2016
@obs     
@sample Lj900IInc(cJson, cRetorno, cMsgErro)
/*/
//-------------------------------------------------------------------
Static Function Lj900IInc( cJson, cRetorno, cMsgErro, cMetodo, cTipo)	

Local cSeq := ""

		cSeq := GETSXENUM("MGM","MGM_SEQ")
		CONFIRMSX8()
		RECLOCK("MGM", .T.)
		MGM->MGM_FILIAL  := xFilial("MGM")
		MGM->MGM_SERVIC := "LOJA900I"
		MGM->MGM_SEQ     := cSeq
		MGM->MGM_DATA    := Date()
		MGM->MGM_HORAIN  := Time()
		MGM->MGM_XMLENV := cMetodo + cTipo + CRLF + cJson
		MGM->MGM_XMLRET  := cMetodo + cTipo + CRLF + cRetorno + CRLF + cMsgErro
		MGM->MGM_HORAFI := Time()
		MGM->MGM_RESULT := IIF(Empty(cMsgErro), "1", "2")
		MGM->( msUnLock() )
 
 Return
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} LjxArmEnd(nRecnoSM0)
Função de Retorno do endereço do armazém
@param   	nRecnoSM0 -  Recno do cadastro de empresas da filial 
@return	aRet - dados do armazém onde
			[01] - Logradouro
			[02] - Numero
			[03] - Complemento
			[04] - Bairro
			[05] - Cidade
			[06]- UF
			[07] - CEP
@author  Varejo
@version 	P11.8
@since   	13/12/2016
@obs     
@sample LjxArmEnd(nRecnoSM0)
/*/
//-------------------------------------------------------------------
Static Function LjxArmEnd(nRecnoSM0)
Local lEndFis   	:= GetNewPar("MV_SPEDEND",.F.) 
Local nRecSm0Atu 	:= SM0->(Recno())
Local aRet 		:= {} //Retorno da rotina
Local cEndereco 	:= "" //Endereço
Local cUF 			:= "" //UF
Local cCep 		:= "" //Cep
Local cCompl 		:= "" //Complemento
Local cBairro 	:= "" //Bairro
Local cCidade 	:= "" //Cidade
Local cNumero 	:= "" //Numero
Local cLogra 		:= "" //Logradouro]

If nRecnoSM0 <> nRecSm0Atu
	SM0->(DbGoTo(nRecnoSM0))
EndIf

If 	!lEndFis
	cUF := SM0->M0_ESTCOB
	cEndereco := SM0->M0_ENDCOB
	cCep := SM0->M0_CEPCOB
	cBairro := SM0->M0_BAIRCOB
	cCidade := SM0->M0_CIDCOB
Else
	cUF := SM0->M0_ESTENT
	cEndereco := SM0->M0_ENDENT
	cCep := SM0->M0_CEPENT
	cBairro := SM0->M0_BAIRENT
	cCidade := SM0->M0_CIDENT
EndIf

If FindFunction("LjFiGetEnd")
	aRet := LjFiGetEnd(cEndereco, cUF, .F.)
Else
	aRet := FisGetEnd(cEndereco, cUF, .F.)
EndIf

cNumero := aRet[2]
cLogra := aRet[1]

//tratamento para Complemento
If lEndFis
	If !Empty( SM0->M0_COMPENT )
		cCompl := SM0->M0_COMPENT
	Else
		cCompl := aRet[4]
	EndIf
Else
	If !Empty( SM0->M0_COMPCOB )
		cCompl := SM0->M0_COMPCOB
	Else
		cCompl := aRet[4]
	EndIf
EndIf
cCompl := AllTrim( cCompl )

aRet := {cLogra,; //1
			cNumero,;//2
			cCompl,;//3
			cBairro,;//4
			cCidade,;//5
			cUF,;//6
			cCep;//7
		}

//Volta para a Filial Atual
If nRecnoSM0 <> nRecSm0Atu
	SM0->(DbGoTo(nRecSm0Atu))
EndIf

Return aRet

#INCLUDE "LOJA900.ch"
#include 'protheus.ch'

/*
	DEPARTAMENTOS
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900
Função de teste integracao Protheus e-commerce CiaShop envio de deparamentos 
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM001 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja900(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900
Função de teste integracao Protheus e-commerce CiaShop envio de deparamentos 
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900" //Rotina
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
	
	LJ900Pr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + STR0006 + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "###" - "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction)
	EndIf
	Lj900XLg(STR0007 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900Pr
Função de teste integracao Protheus e-commerce CiaShop envio de deparamentos 
@param   	lAJob- Execução em Job - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Function LJ900Pr(lAJob, lCallStack) 

	Local cXML      := "" //String XML
	Local oWS		  := NIL //WebService
	Local cError    := "" //Erro Parser
	Local cWarning  := "" //Alerta Parser
	Local oRetXML		:= NIL //Retorno XML
	Local cSeq      := "" //Sequencia de Execução
	Local lErro     := .F. //Erro WS
	Local cRetorno  := "" //Retorno WS
	Local cAlias		:= "" //Alias da Consulta
	Local aCategDel := {} //Categorias a Excluir
	Local aRet      := {} //Retorno
	Local nInd		  := 0 //Indice
	Local aAtuACU := {} //Array de Atualização do ACU
	Local dDataIni := Date() //Data Inicial do Job
	Local cHoraIni := Time() //Hora Inicial do Job
	Local nC := 0 //Contador de Categorias
	Local lFunRec := FindFunction("Lj900XRL") //Função que realiza o travamento do registro
	Local lLock := .F. 	//verifica se o registro está bloqueado
	
	Default lAJob := .F.
	Default lCallStack := .F.
	
	cAlias  := GetNextAlias()

	//mandar com macrosubstituição
	oWS := Lj904WS()

	//Consulta as categorias que deverão ser enviadas
	Lj900CE(cAlias, lCallStack)
	
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()

	//Log de registros enviados
	dbSelectArea("MGO")

	While !(cAlias)->(EOF())

		//Ignora caso a categoria esteja na lista de exclusão
		IF aScan(aCategDel, { |x| x == (cAlias)->ACU_COD }) > 0
			(cAlias)->( dbSkip() )
			Loop
		EndIF
		
		//Resultado da sincronização		
		//Inclui na tabela MGO (Log)
		RecLock("MGO", .T.)
		MGO->MGO_FILIAL  := xFilial("MGO")
		MGO->MGO_SEQ     := cSeq
		MGO->MGO_CODIGO  := (cAlias)->ACU_COD
		MGO->MGO_DESC    := (cAlias)->ACU_DESC
		MGO->MGO_CODPAI  := (cAlias)->ACU_CODPAI
		MGO->MGO_SIT     := (cAlias)->ACU_ECFLAG
		MGO->( MsUnLock() )

		IF (cAlias)->ACU_ECFLAG == '2'
			//Consulta filhas
			aRet := Lj900CF((cAlias)->ACU_COD)

			For nInd := 1 to Len(aRet)
				IF aScan(aCategDel, { |x| x == aRet[nInd] }) == 0
					aAdd(aCategDel, aRet[nInd])
					cXML += Lj900GXML(aRet[nInd], "D", "0", "")
				EndIF
			Next nInd

			aAdd(aCategDel, (cAlias)->ACU_COD)
		EndIF

		cXML += Lj900GXML((cAlias)->ACU_COD,;
			iif((cAlias)->ACU_ECFLAG <> '2', 'I', 'D'),;
			iif(Empty((cAlias)->ACU_CODPAI), "0", (cAlias)->ACU_CODPAI),;
			AllTrim((cAlias)->ACU_DESC))
		
		aAdd(aAtuACU, (cAlias)->ACU_REC)

		(cAlias)->(DBSkip())
	EndDO

	dbSelectArea(cAlias)
	dbCloseArea()

	IF !Empty(cXML)
		cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
			'<deptList xmlns="dsReceipt.xsd">' +;
			cXML +;
			'</deptList>'
	EndIF

	//Somente comunica se há categorias para enviar
	IF !Empty(cXML)
		iif(!lAJob, Memowrit('envioCateg.xml', cXML), )

		//Consome método
		IF !oWs:Departamentos(, , cXML)
			lErro := .T.
			cRetorno := STR0009 //"Erro ao consumir o método Departamentos do WebService!"
			//MsgStop(cRetorno)
		Else
			iif(!lAJob, MemoWrit('retornoCateg.xml', oWs:cXml), )

			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )

			IF !Empty(cError)
				cRetorno := STR0010 + Chr(13) + cError //"Erro no método XmlParser: "
				cRetorno += Chr(13) + "XML: " + oWs:cXml
				lErro := .T.
			Else
				cRetorno := oWs:cXml
				lErro := !oWs:lDepartamentosResult
			endif
		endif
		
		dbSelectArea("MGM")
		RECLOCK("MGM", .T.)
		MGM->MGM_FILIAL  := xFilial("MGM")
		MGM->MGM_SERVIC := "LOJA900"
		MGM->MGM_SEQ     := cSeq
		MGM->MGM_DATA    := dDataIni
		MGM->MGM_HORAIN  := cHoraIni
		MGM->MGM_XMLENV := cXML
		MGM->MGM_XMLRET  := cRetorno
		MGM->MGM_HORAFI := Time()
		IF !lErro
			MGM->MGM_RESULT := "1"
		Else
			MGM->MGM_RESULT := "2"
		EndIF
		MGM->( msUnLock() )
		
	endif


	
	If !lErro //Atualiza o ACU
	
		For nC := 1 to Len(aAtuACU)
			ACU->(DbGoTo(aAtuACU[nC])) 
			lLock := .F.
			//Verifica o travamento para não ocorrer concorrência
			If lFunRec	 
				lLock := 	Lj900XRL("ACU", .F., "LOJA900")
				
			Else
				lLock :=  RecLock("ACV", .F.)
			EndIf			
			If lLock
				ACU->ACU_ECDTEX := Dtos(Date())
				ACU->ACU_ECSEQ := cSeq
				ACU->(MsUnLock() )
			EndIf
		Next nC 
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CE
Consulta as categorias que deverão ser enviadas
@param cAAlias - Alias da Query
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CE(cAAlias)
/*/
//-------------------------------------------------------------------
Static Function Lj900CE(cAAlias, lCallStack)

	local cQuery := "" //Consulta
	
	Default lCallStack := .F.
	
	

	cQuery += " SELECT ACU_COD, ACU_DESC, ACU_CODPAI, ACU_ECFLAG, R_E_C_N_O_ AS ACU_REC "
	cQuery += " FROM " + RetSqlName("ACU") + " ACU "
	cQuery += " WHERE ACU.ACU_ECFLAG <> ' ' AND ACU.D_E_L_E_T_ <> '*' AND ACU_ECDTEX = ' ' "
	cQuery += " ORDER BY ACU_ECFLAG DESC,ACU_CODPAI, ACU_COD "

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAAlias, .F., .T.)
	
	
	If lCallStack .AND. FindFunction("Lj900XRC")
		 Lj900XRC( cAAlias, "LOJA900")
	EndIf

return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CF
Retorna as Categorias-Filhas
@param   	cACateg- Codigo da Categoria
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CF(cACateg)
/*/
//-------------------------------------------------------------------
Static Function Lj900CF(cACateg)

	local aFilhas   := {} //Lista Categorias Filhas
	local aRec		  := {} //Array das Categorias-Netas
	local cAliasLoc := GetNextAlias() //Alias da Consulta
	local cSQL      := "" //Consulta
	local nInd		  := 0 //Variavel contadora

	cSQL := " SELECT * "
	cSQL += " FROM " + RetSqlName("ACU") + " ACU "
	cSQL += " WHERE ACU_FILIAL = '" + xFilial("ACU") + "' "
	cSQL += " AND ACU_CODPAI = '" + cACateg + "' "
	cSQL += " AND D_E_L_E_T_ <> '*' "

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL),cAliasLoc, .F., .T.)

	while !(cAliasLoc)->(Eof())
		aRec := aClone(Lj900CF((cAliasLoc)->ACU_COD))

		for nInd := 1 to len(aRec)
			if aScan(aFilhas, { |x| x == aRec[nInd] }) == 0
				aAdd(aFilhas, aRec[nInd])
			endif
		next nInd

		aAdd(aFilhas, (cAliasLoc)->ACU_COD)

		(cAliasLoc)->(DbSkip())
	enddo

	dbSelectArea(cAliasLoc)
	DBCLOSEAREA()

return aFilhas

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900GXML
Gera o XML dos Deparamentos
@param   	cACod - Execução em Job - Default .f.
@param   	cAOp - Execução em Job - Default .f.
@param   	cAPai- Execução em Job - Default .f.
@param   	cADesc- Execução em Job - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900GXML((cAlias)->ACU_COD,iif((cAlias)->ACU_ECFLAG <> '2', 'I', 'D'),iif(Empty((cAlias)->ACU_CODPAI), "0", (cAlias)->ACU_CODPAI),AllTrim((cAlias)->ACU_DESC))
/*/
//-------------------------------------------------------------------
Static Function Lj900GXML(cACod, cAOp, cAPai, cADesc)

	Local cXML := ""

//Montagem do XML
	cXML += '<dept'

//Reservado
	cXML += ' xmlns=""'

//Código
	cXML += ' dept_id="' + cACod + '"'

//Operação: I - Incluir
//          D - Deletar
//          U - Atualizar
	cXML += ' op="' + cAOp + '"'

//Código do departamento pai
	cXML += ' parent_id="' + cAPai + '"'

//Nome do departamento
	cXML += ' dept_name="' + _NoTags(cADesc) + '"'

	cXML += '/>'

return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900VP
Verifica se existem produtos vinculados a categoria, se não existir inativa a mesma
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900VP()
/*/
//-------------------------------------------------------------------
Static Function Lj900VP()

	Local lBloqueia := .F. //Bloqueia a Categoria?
	Local cFlag := "" //Falg da Categoria
	Local cAcuCod := "" // Armazena codigo ACu corrente.
	Local aAreaAcu := {} //WorkArea Tabela ACU
	//Cadastro de categorias
	DBSelectArea("ACU")

	//Vinculos entre as categorias e os produtos
	DBSelectArea("ACV")
	ACV->(DbSetOrder(1))

	//Cadastro de produtos
	DBSelectArea("SB5")
	SB5->(DbSetOrder(1))

	ACU->(DbGoTop())
	While !ACU->( Eof() )

		//nunca mexe nas categorias pai
		IF Empty(ACU->ACU_CODPAI)
			ACU->( dbSkip())
			Loop
		EndIF

		lBloqueia := .T.

		Lj900XLg("Processando categoria" , ACU->ACU_COD)
		
		cAcuCod := 	ACU->ACU_COD 
		aAreaBk := 	GetArea() 
		aAreaAcu := 	ACU->(GetArea())
		DbSelectArea("ACU")
		DbSetOrder(2)
		If ACU->(DbSeek(xFilial("ACU") +  cAcuCod ))
			Lj900XLg("Localizado categoria Filha " + ACU->ACU_COD, cAcuCod )
			lBloqueia := .F.
			RestArea(aAreaAcu) 
			RestArea(aAreaBk) 
			ACU->( dbSkip())
			Loop
		Else
			Lj900XLg("Categoria sem filho", cAcuCod)
		EndIf 
		RestArea(aAreaAcu) 
		RestArea(aAreaBk) 
		
		//procura a categoria na amarração com os produtos
		ACV->( dbSeek(xFilial("ACV") + ACU->ACU_COD ) )

		While !ACV->( Eof() ) .AND. ACV->(ACV_FILIAL + ACV_CATEGO) == xFilial("ACV") + ACU->ACU_COD

			//posiciona no produto			
			//se existir
			IF SB5->( dbSeek(xFilial("SB5") + ACV->ACV_CODPRO ) )
				//verifica se esta bloqueado ou não
				lBloqueia := SB5->B5_ECFLAG <> "1"
				Lj900XLg("Localizado Produto vinculado a categoria " + ACV->ACV_CODPRO + " da categoria ECFLAG " + SB5->B5_ECFLAG, ACU->ACU_COD)
			EndIF

			//caso algum não estejá
			IF !lBloqueia
				//sai fora
				Exit
			EndIF

			ACV->( dbSkip() )
		EndDO
		
		cFlag := iif(lBloqueia, "2", "1")
		//atualiza situação (Ativo/Inativo) da categoria e sinaliza para reenvio
		IF ACU->ACU_ECFLAG <>  cFlag
			RecLock("ACU", .F.)
			Lj900XLg("Categoria Atualizando Flag e-commerce [ " +cFlag  + "]" , ACU->ACU_COD)
			ACU->ACU_ECFLAG := cFlag
			ACU->ACU_ECDTEX := ""
			ACU->(MsUnLock())
		EndIf
		ACU->(DbSkip())

	EndDO

Return
 
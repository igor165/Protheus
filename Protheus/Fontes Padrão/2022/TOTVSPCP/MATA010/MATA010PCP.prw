#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#Include "MATA010PCP.CH"

/*/{Protheus.doc} MATA010PCP
Classe de eventos relacionados com o produto x SIGAPCP
@author Carlos Alexandre da Silveira
@since 25/02/2019
@version 1.0
/*/
CLASS MATA010PCP FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()

ENDCLASS

METHOD New(oModel) CLASS MATA010PCP

	If FindClass("MATA010API")
		oModel:InstallEvent("MATA010API",,MATA010API():New())
	EndIf

	If FindClass("MATA010NET")
		oModel:InstallEvent("MATA010NET",,MATA010NET():New())
	EndIf

Return

/*/{Protheus.doc} ModelPosVld
P�s valida��o do modelo
@author Carlos Alexandre da Silveira
@since 25/02/2019
@version 1.0
@param 01 oModel  , Object   , Modelo de dados que ser� validado
@param 02 cModelId, Character, ID do modelo de dados que est� sendo validado
@return   lRet    , Logical  , Indica se o modelo foi validado com sucesso
/*/
METHOD ModelPosVld(oModel, cModelId) Class MATA010PCP
	Local aRet    := {}
	Local lRet    := .T.
	Local lVldAlt := .T.
	Local lAltern := .F.
	Local nX      := 0
	Local oMdlSVK := oModel:GetModel("SVKDETAIL")
	Local oMdlSGI := oModel:GetModel("SGIDETAIL")
	Local oMdlSB1 := oModel:GetModel("SB1MASTER")

	lVldAlt := oMdlSGI == Nil

	//Caso o campo horizonte fixo seja maior que zero, o campo tipo de horizonte fixo ser� obrigat�rio.
	If oMdlSVK != Nil .And. Empty(oMdlSVK:GetValue("VK_TPHOFIX"))
		If oMdlSVK:GetValue("VK_HORFIX") > 0
			Help(,,'Help',,STR0002,1,0) //STR0002 - Quando � preenchido o campo Horizonte Fixo, � obrigat�rio o preenchimento do campo Tipo de Horizonte Fixo.
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		//Verifica se poder� excluir o produto. (Valida��o de alternativos)
		aRet := PCPAltVlDe(oModel:GetModel("SB1MASTER"):GetValue("B1_COD"), lVldAlt)
		If !aRet[1]
			HELP(' ',1,"Help" ,,aRet[2],2,0,,,,,,)
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oMdlSB1:GetValue("B1_FANTASM") == "S"
			If oMdlSGI  != Nil
				If !oMdlSGI:IsEmpty()
					For nX := 1 To oMdlSGI:Length()
						If !oMdlSGI:IsDeleted(nX)
							lAltern := .T.
							Exit
						EndIf
					Next nX
				EndIf
			Else
				SGI->(dbSetOrder(1))
				If SGI->(dbSeek(xFilial("SGI")+oMdlSB1:GetValue("B1_COD")))
					lAltern := .T.
				EndIf
			EndIf
			If !lAltern
				SGI->(dbSetOrder(2))
				If SGI->(dbSeek(xFilial("SGI")+oMdlSB1:GetValue("B1_COD")))
					lAltern := .T.
				EndIf
			EndIf

			If lAltern
				Help(" ",1,"ALTERFAN")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ValidPrdOri
Fun��o para complementar os submodelos do Model.
� necessario obter a opera��o do modelo, para verificar
se o usuario tem acesso a rotina nessa opera��o.

Foi definido para ser executado antes do activate, pois
no momento da execu��o da fun��o ModelDef, n�o existe opera��o
ainda.
@author Renan Roeder
@since 26/09/2018
@version 1.0
/*/
Function ValidPrdOri()
	Local lRet    := .T.
	Local lPrdOri := &(ReadVar())
	Local lPrdRet := M->B1_COD

	If lPrdOri == lPrdRet
		Help(" ",1,"A010PCPRET")
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ExisteSFCPcp
Valida Integra��o com SFC - Parametro/Compartilhamento tabela
Fun��o migrada do MATA010 - ExisteSFC
@author Michele Girardi
@since 11/01/2019
@version 1.1
/*/
Function ExisteSFCPcp(cTabela)
	Local aArea     := GetArea()
	Local aSM0      := {}
	Local cFilVer   := ""
	Local lExistSfc := .F.
	Local lRet      := .F.
	Local nI        := 0
	Local nTamanho  := FWSizeFilial() //https://tdn.totvs.com/x/hf1n
	Local xIntSFC   := SuperGetMV("MV_INTSFC",.F.,0) //Define se existe integra��o entre o M�dulo SIGASFC e outros m�dulos (0=N�o Integra, 1=Protheus, 2=Datasul).

	//Verificar se a filial corrente possui integra��o
	If ValType(xIntSFC) # "N"
		lRet := xIntSFC
	Else
		lRet := xIntSFC == 1
	EndIf

	//Se a filial corrente possuir integra��o, processar a integra��o.
	if lRet
		return lRet
	EndIf

	//Se a filial corrente n�o possuir integra��o verificar se outra filial possui integra��o
	//Carrega todas as filiais no array
	lExistSfc = .F.
	aSM0 := FwLoadSM0()
	If Len(aSM0)<= 0
		Final(STR0001)//"SIGAMAT.EMP com problemas!"
	Else
		For nI := 1 To Len(aSM0)
			cFilVer := substr(aSM0[nI,2],1,nTamanho) 

			//Busca na SX6 se o par�metro est� marcado para alguma outra filial
			If SUPERGETMV( "MV_INTSFC", .F., 0, cFilVer) == 1
				lExistSfc = .T.
				exit
			EndIf

		Next nI
	EndIf

	//Se nenhuma filial possuir integra��o n�o processar a integra��o.
	if !lExistSfc
		RestArea(aArea)
		return .F.
	EndIf

	//Se a filial corrente n�o possuir integra��o e outra filial possuir
	//Verificar se a tabela em quest�o � compartilhada
	//Se n�o for compartilhada n�o processar a integra��o.
	if FWModeAccess(cTabela, 1) == 'E' .Or. FWModeAccess(cTabela, 3) == 'E'/*(1=Empresa, 2=Unidade de Neg�cio e 3=Filial)*/
		lRet = .F.
	Else
		lRet = .T. //Se for compartilhada, processa a integra��o
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} MTA010IEST
Fun��o para executar a integra��o da estrutura.
Produtos alternativos / Altera��o do campo B1_FANTASM

@type  Function
@author marcelo.neumann
@since 20/08/2019
@version P12
@param cEmp     , Character, C�digo da empresa para conex�o
@param cFil     , Character, C�digo da filial para conex�o
@param cProduto , Character, C�digo do produto a ser integrado
@param lFantasma, Logical  , Altera��o da propriedade B1_FANTASM
@return Nil
/*/
Function MTA010IEST(cEmp, cFil, cProduto, lFantasma)

	ErrorBlock({|oDetErro| MTA010PCPE(oDetErro) })

	Begin Sequence
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		SetFunName("MATA010") //Seta a fun��o inicial para MATA010

		If LockIntMrp(.T., "MTA010IEST")
			IntegSG1(cProduto, lFantasma)
			LockIntMrp(.F., "MTA010IEST")
		Else
			GravaErrIn("MRPBILLOFMATERIAL")
		EndIf

		//Caso ocorra algum erro
		RECOVER
			GravaErrIn("MRPBILLOFMATERIAL")

	End Sequence

Return Nil

/*/{Protheus.doc} MTA010G1PA
Faz a integra��o da estrutura do produto, considerando a informa��o de produto bloqueado.
Se o produto estiver bloqueado (B1_MSBLQL), a estrutura do produto ser� eliminada das tabelas do MRP.

@type  Function
@author lucas.franca
@since 23/09/2021
@version P12
@param cProduto, Character, C�digo do produto a ser integrado
@param cMSBLQL , Character, Conte�do atual de bloqueio do produto
@param cFilAux , Character, Utilizado para integrar a estrutura de uma filial espec�fica
@return Nil
/*/
Function MTA010G1PA(cProduto, cMSBLQL, cFilAux)
	Local aFilInt   := {}
	Local cAliasSG1 := GetNextAlias()
	Local cOperacao := ""
	Local cQuery    := ""
	Local nTotFil   := Len(aFilInt)
	Local nIndex    := 0
	Local oIntegra  := JsonObject():New()

	Default cFilAux := ""

	If Empty(cFilAux)
		aFilInt := getFilInt()
	Else
		aFilInt := {cFilAux}
	EndIf

	If cMSBLQL == '1'
		cOperacao := "DELETE"
	Else
		cOperacao := "INSERT"
	EndIf
	
	nTotFil := Len(aFilInt)
	cFilAux := cFilAnt

	For nIndex := 1 To nTotFil
		cQuery := "SELECT DISTINCT SG1.G1_FILIAL,"
		cQuery +=                " SG1.G1_COD "
		cQuery +=  " FROM " + RetSqlName("SG1") + " SG1 "
		cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1", aFilInt[nIndex]) + "'"
		cQuery += "   AND SG1.G1_COD     = '" + cProduto + "' "
		cQuery += "   AND SG1.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG1,.T.,.T.)

		If (cAliasSG1)->(!Eof())
			//Carrega o array aDadosInc com os registros a serem integrados
			oIntegra[(cAliasSG1)->G1_FILIAL+(cAliasSG1)->G1_COD] := 1

			cFilAnt := aFilInt[nIndex]
			//Chama a fun��o do PCPA200API para integrar os registros
			PCPA200MRP(Nil, Nil, oIntegra, cOperacao, {}, {})

			oIntegra:delName((cAliasSG1)->G1_FILIAL+(cAliasSG1)->G1_COD)
		EndIf
		(cAliasSG1)->(dbCloseArea())
		
	Next nIndex

	cFilAnt := cFilAux
	FreeObj(oIntegra)
	oIntegra := Nil
	aSize(aFilInt, 0)
Return Nil

/*/{Protheus.doc} MTA010PCPE
Fun��o para tratativa de erros de execu��o

@type  Function
@author marcelo.neumann
@since 20/08/2019
@version P12
@param oDetErro, Object, Objeto com os detalhes do erro ocorrido
/*/
Function MTA010PCPE(oDetErro)

	LogMsg('MTA010IMRP', 0, 0, 1, '', '', ;
	       Replicate("-",70) + CHR(10) + AllTrim(oDetErro:description) + CHR(10) + AllTrim(oDetErro:ErrorStack) + CHR(10) + Replicate("-",70))
	BREAK
Return

/*/{Protheus.doc} GravaErrIn
Fun��o para setar a falha na integra��o e obrigar rodar a Sincroniza��o de Estruturas

@type  Function
@author marcelo.neumann
@since 22/08/2019
@version P12
@param cApiFalha, Character, Nome da API que ser� atualizada como falha na execu��o
/*/
Function GravaErrIn(cApiFalha)

	TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + AllTrim(cApiFalha) + "'")

Return

/*/{Protheus.doc} IntegraSG1
Fun��o para buscar e integrar as estruturas

@type  Function
@author marcelo.neumann
@since 20/08/2019
@version P12
@param cProduto , Character, C�digo do produto a ser integrado
@param lFantasma, Logical  , Altera��o da propriedade B1_FANTASM
/*/
Static Function IntegSG1(cProduto,lFantasma)

	Local aError    := {}
	Local aSuccess  := {}
	Local aFilInt   := getFilInt()
	Local cAliasSG1 := GetNextAlias()
	Local cQuery    := ""
	Local cFilBkp   := cFilAnt
	Local nTotFil   := Len(aFilInt)
	Local nIndex    := 0
	Local oIntegra  := Nil

	For nIndex := 1 To nTotFil

		cFilAnt := aFilInt[nIndex]

		cQuery := "SELECT DISTINCT SG1.G1_FILIAL,SG1.G1_COD FROM " + RetSqlName("SG1") + " SG1 "
		cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
		cQuery += "   AND SG1.G1_COMP    = '" + cProduto + "' "
		cQuery += "   AND SG1.D_E_L_E_T_ = ' ' "

		If lFantasma
			cQuery += "   AND SG1.G1_FANTASM = ' ' "
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG1,.T.,.T.)

		If !(cAliasSG1)->(Eof())
			oIntegra := JsonObject():New()

			//Carrega o array aDadosInc com os registros a serem integrados
			While (cAliasSG1)->(!Eof())
				oIntegra[(cAliasSG1)->G1_FILIAL+(cAliasSG1)->G1_COD] := 1

				(cAliasSG1)->(dbSkip())
			End

			//Chama a fun��o do PCPA200API para integrar os registros
			PCPA200MRP(Nil, Nil, oIntegra, "INSERT", @aSuccess, @aError)

			FreeObj(oIntegra)
			oIntegra := Nil
		EndIf
		(cAliasSG1)->(dbCloseArea())
	Next nIndex

	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	aSize(aFilInt, 0)
Return

/*/{Protheus.doc} getFilInt
Identifica quais filiais devem ser consideradas para realizar a integra��o de estruturas

@type  Static Function
@author lucas.franca
@since 31/08/2020
@version P12
@return aFilInt, Array, Array com as filiais que ter�o a estrutura integrada
/*/
Static Function getFilInt()
	Local aFilInt  := {}
	Local cCompEmp := FWModeAccess("SB1", 1) //Compartilhamento Empresa
	Local cCompUN  := FWModeAccess("SB1", 2) //Compartilhamento unidade de neg�cio
	Local cCompFil := FWModeAccess("SB1", 3) //Compartilhamento filial
	Local lUsaEmp  := !Empty(FWSM0Layout(cEmpAnt, 1))
	Local lUsaUN   := !Empty(FWSM0Layout(cEmpAnt, 2))

	If cCompEmp+cCompUN+cCompFil == "EEE" .Or. ; //SB1 Exclusiva OU
	   ( !lUsaEmp .And. !lUsaUN .And. cCompFil == "E") .Or. ; //N�o usa unidade de neg�cio/empresa e Filial exclusiva OU
	   ( !lUsaEmp .And. lUsaUN .And. cCompUN+cCompFil == "EE") //N�o usa empresa, usa unidade de neg�cio e Unidade de neg�cio + filial exclusiva
		//Processa somente filial atual
		aAdd(aFilInt, cFilAnt)
	ElseIf cCompEmp+cCompUN+cCompFil == "EEC"
		//Processa todas as filiais vinculadas a Empresa + Unidade de neg�cio
		aFilInt := FwAllFilial(FWCompany(),FWUnitBusiness(),cEmpAnt,.F.)
	ElseIf cCompEmp+cCompUN+cCompFil == "ECC"
		//Processa todas as filiais vinculadas a Empresa
		aFilInt := FwAllFilial(FWCompany(),,cEmpAnt,.F.)
	ElseIf cCompEmp+cCompUN+cCompFil == "CCC"
		//Processa todas as filiais
		aFilInt := FwAllFilial(,,cEmpAnt,.F.)
	Else
		//Nenhuma das anteriores, ir� processar somente a filial atual.
		aAdd(aFilInt, cFilAnt)
	EndIf

Return aFilInt

/*/{Protheus.doc} UpdGCDescP
Abre thread para atualizar a descri��o do grupo de compras nos produtos vinculados (tabela HWA)

@type   Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, C�digo do grupo de compras que foi alterado
@param cGCDesc, Character, Descri��o do grupo de compras que foi alterado
@return Nil
/*/
Function UpdGCDescP(cGrCom, cGCDesc)

	//Abre uma thread para fazer a integra��o do produto com o MRP (HWA).
	StartJob("MTA010IGRC", GetEnvServer(), .F., cEmpAnt, cFilAnt, cGrCom, cGCDesc)

Return

/*/{Protheus.doc} MTA010IGRC
Fun��o para executar a integra��o dos produtos vinculados a um grupo de compras.
Altera��o do campo AJ_DESC

@type   Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, C�digo do grupo de compras que foi alterado
@param cGCDesc, Character, Descri��o do grupo de compras que foi alterado
@return Nil
/*/
Function MTA010IGRC(cEmp, cFil, cGrCom, cGCDesc)

	ErrorBlock({|oDetErro| MTA010PCPE(oDetErro) })

	Begin Sequence
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		SetFunName("MATA010") //Seta a fun��o inicial para MATA010

		If LockIntMrp(.T., "MTA010IGRC")
			IntegSB1GC(cGrCom, cGCDesc)
			LockIntMrp(.F., "MTA010IGRC")
		Else
			GravaErrIn("MRPPRODUCT")
		EndIf

		//Caso ocorra algum erro
		RECOVER
			GravaErrIn("MRPPRODUCT")

	End Sequence

Return Nil

/*/{Protheus.doc} IntegSB1GC
Fun��o para buscar e integrar os produtos vinculados a um grupo de compras

@type  Static Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, C�digo do grupo de compras que foi alterado
@param cGCDesc, Character, Descri��o do grupo de compras que foi alterado
/*/
Static Function IntegSB1GC(cGrCom, cGCDesc)
	Local cAliasSB1      := GetNextAlias()
	Local cIdReg         := ""
	Local cQuery         := ""
	Local lIntegraMRP    := .F.
	Local lIntegraOnline := .F.

	If FindFunction("IntNewMRP")
		lIntegraMRP := IntNewMRP("MRPPRODUCT", @lIntegraOnline)
	EndIf

	If lIntegraMRP == .F.
		Return
	EndIf

	cQuery :=  " SELECT SB1.R_E_C_N_O_ REC  "
	cQuery +=    " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery +=   " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=     " AND SB1.B1_GRUPCOM = '" + cGrCom + "' "
	cQuery +=     " AND SB1.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSB1,.T.,.T.)

	While (cAliasSB1)->(!Eof())
		SB1->(dbGoTo((cAliasSB1)->(REC)))

		If lIntegraOnline == .F.
			cIdReg := SB1->B1_FILIAL+SB1->B1_COD

			dbSelectArea("T4R")
			T4R->(dbSetOrder(1))
			If !T4R->(dbSeek(xFilial("T4R") + cIdReg))
				//Inclui um registro na T4R para a integra��o
				RecLock("T4R", .T.)
					T4R->T4R_FILIAL := xFilial("T4R")
					T4R->T4R_API    := "MRPPRODUCT"
					T4R->T4R_STATUS := "3"
					T4R->T4R_IDREG  := cIdReg
					T4R->T4R_DTENV  := Date()
					T4R->T4R_HRENV  := Time()
					T4R->T4R_PROG   := "MATA010PCP"
					T4R->T4R_TIPO   := "1"
				MsUnlock()
			EndIf
		Else
			A010IntPrd( , , "INSERT", "SB1", cGCDesc)
		EndIf
		(cAliasSB1)->(dbSkip())
	EndDo

	(cAliasSB1)->(dbCloseArea())

Return

/*/{Protheus.doc} LockIntMrp
Cria sem�foro para processamento paralelo da integra��o com o MRP

@type  Static Function
@author lucas.franca
@since 09/06/2021
@version P12
@param lLock  , Logical  , Se verdadeiro, ir� tentar fazer o LOCK. Se falso, ir� liberar o lock.
@param cPrefix, Character, Prefixo de controle de lock
@return lRet , Logical  , Se verdadeiro, conseguiu fazer o lock.
/*/
Static Function LockIntMrp(lLock, cPrefix)
	Local nTry := 0

	If lLock
		While !LockByName(cPrefix+cEmpAnt,.T.,.T.)
			nTry++
			If nTry > 500
				Return .F.
			EndIf
			Sleep(1000)
		End
	Else
		UnLockByName(cPrefix+cEmpAnt,.T.,.T.)
	EndIf
Return .T.

/*/{Protheus.doc} PCPMdSVK
Fun��o chamada pelo MATA010M para complementar os submodelos do Model.

@type  Function
@author Lucas Fagundes
@since 22/08/2022
@version P12
@param 01 oModel  , Object, Objeto model do mata010
@param 02 oStruSVK, Object, Objeto que representa estrutura da tabela SVK
@return Nil
/*/
Function PCPMdSVK(oModel, oStruSVK)
	oStruSVK := trataRFID(oStruSVK)
Return Nil

/*/{Protheus.doc} PCPViewSVK
Fun��o chamada pelo MATA010M para complementar os formul�rios da View.

@type  Function
@author Lucas Fagundes
@since 22/08/2022
@version P12
@param oView, Object, View do mata010
@return Nil
/*/
Function PCPViewSVK(oView)
	Local oStruSVK := Nil

	oStruSVK := oView:GetViewStruct("FORMSVK")
	oStruSVK := trataRFID(oStruSVK)

Return Nil

/*/{Protheus.doc} trataRFID
Remove os campos do RFID caso presentes na estrutura do modelo e/ou da view.
@type  Static Function
@author Lucas Fagundes
@since 23/08/2022
@version P12
@param oStruSVK, Object, Objeto que representa estrutura da tabela SVK.
@return oStruSVK, Object, Estrutura da tabela SVK com os campos do RFID removidos.
/*/
Static Function trataRFID(oStruSVK)
	Local aCampos := {"VK_RFID", "VK_RFIDKEY", "VK_RFIDFAT", "VK_GTIN", "VK_GTINTAM", "VK_GTINKEY", "VK_COMPANY", "VK_FILTER"}
	Local nIndex  := 0
	Local nTotal  := 0

	nTotal := Len(aCampos)

	For nIndex := 1 To nTotal
		If oStruSVK:HasField(aCampos[nIndex])
			oStruSVK:RemoveField(aCampos[nIndex])
		EndIf
	Next

	aSize(aCampos, 0)
Return oStruSVK

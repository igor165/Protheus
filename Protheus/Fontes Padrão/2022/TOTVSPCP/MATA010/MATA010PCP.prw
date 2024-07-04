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
Pós validação do modelo
@author Carlos Alexandre da Silveira
@since 25/02/2019
@version 1.0
@param 01 oModel  , Object   , Modelo de dados que será validado
@param 02 cModelId, Character, ID do modelo de dados que está sendo validado
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

	//Caso o campo horizonte fixo seja maior que zero, o campo tipo de horizonte fixo será obrigatório.
	If oMdlSVK != Nil .And. Empty(oMdlSVK:GetValue("VK_TPHOFIX"))
		If oMdlSVK:GetValue("VK_HORFIX") > 0
			Help(,,'Help',,STR0002,1,0) //STR0002 - Quando é preenchido o campo Horizonte Fixo, é obrigatório o preenchimento do campo Tipo de Horizonte Fixo.
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		//Verifica se poderá excluir o produto. (Validação de alternativos)
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
Função para complementar os submodelos do Model.
É necessario obter a operação do modelo, para verificar
se o usuario tem acesso a rotina nessa operação.

Foi definido para ser executado antes do activate, pois
no momento da execução da função ModelDef, não existe operação
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
Valida Integração com SFC - Parametro/Compartilhamento tabela
Função migrada do MATA010 - ExisteSFC
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
	Local xIntSFC   := SuperGetMV("MV_INTSFC",.F.,0) //Define se existe integração entre o Módulo SIGASFC e outros módulos (0=Não Integra, 1=Protheus, 2=Datasul).

	//Verificar se a filial corrente possui integração
	If ValType(xIntSFC) # "N"
		lRet := xIntSFC
	Else
		lRet := xIntSFC == 1
	EndIf

	//Se a filial corrente possuir integração, processar a integração.
	if lRet
		return lRet
	EndIf

	//Se a filial corrente não possuir integração verificar se outra filial possui integração
	//Carrega todas as filiais no array
	lExistSfc = .F.
	aSM0 := FwLoadSM0()
	If Len(aSM0)<= 0
		Final(STR0001)//"SIGAMAT.EMP com problemas!"
	Else
		For nI := 1 To Len(aSM0)
			cFilVer := substr(aSM0[nI,2],1,nTamanho) 

			//Busca na SX6 se o parâmetro está marcado para alguma outra filial
			If SUPERGETMV( "MV_INTSFC", .F., 0, cFilVer) == 1
				lExistSfc = .T.
				exit
			EndIf

		Next nI
	EndIf

	//Se nenhuma filial possuir integração não processar a integração.
	if !lExistSfc
		RestArea(aArea)
		return .F.
	EndIf

	//Se a filial corrente não possuir integração e outra filial possuir
	//Verificar se a tabela em questão é compartilhada
	//Se não for compartilhada não processar a integração.
	if FWModeAccess(cTabela, 1) == 'E' .Or. FWModeAccess(cTabela, 3) == 'E'/*(1=Empresa, 2=Unidade de Negócio e 3=Filial)*/
		lRet = .F.
	Else
		lRet = .T. //Se for compartilhada, processa a integração
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} MTA010IEST
Função para executar a integração da estrutura.
Produtos alternativos / Alteração do campo B1_FANTASM

@type  Function
@author marcelo.neumann
@since 20/08/2019
@version P12
@param cEmp     , Character, Código da empresa para conexão
@param cFil     , Character, Código da filial para conexão
@param cProduto , Character, Código do produto a ser integrado
@param lFantasma, Logical  , Alteração da propriedade B1_FANTASM
@return Nil
/*/
Function MTA010IEST(cEmp, cFil, cProduto, lFantasma)

	ErrorBlock({|oDetErro| MTA010PCPE(oDetErro) })

	Begin Sequence
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		SetFunName("MATA010") //Seta a função inicial para MATA010

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
Faz a integração da estrutura do produto, considerando a informação de produto bloqueado.
Se o produto estiver bloqueado (B1_MSBLQL), a estrutura do produto será eliminada das tabelas do MRP.

@type  Function
@author lucas.franca
@since 23/09/2021
@version P12
@param cProduto, Character, Código do produto a ser integrado
@param cMSBLQL , Character, Conteúdo atual de bloqueio do produto
@param cFilAux , Character, Utilizado para integrar a estrutura de uma filial específica
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
			//Chama a função do PCPA200API para integrar os registros
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
Função para tratativa de erros de execução

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
Função para setar a falha na integração e obrigar rodar a Sincronização de Estruturas

@type  Function
@author marcelo.neumann
@since 22/08/2019
@version P12
@param cApiFalha, Character, Nome da API que será atualizada como falha na execução
/*/
Function GravaErrIn(cApiFalha)

	TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + AllTrim(cApiFalha) + "'")

Return

/*/{Protheus.doc} IntegraSG1
Função para buscar e integrar as estruturas

@type  Function
@author marcelo.neumann
@since 20/08/2019
@version P12
@param cProduto , Character, Código do produto a ser integrado
@param lFantasma, Logical  , Alteração da propriedade B1_FANTASM
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

			//Chama a função do PCPA200API para integrar os registros
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
Identifica quais filiais devem ser consideradas para realizar a integração de estruturas

@type  Static Function
@author lucas.franca
@since 31/08/2020
@version P12
@return aFilInt, Array, Array com as filiais que terão a estrutura integrada
/*/
Static Function getFilInt()
	Local aFilInt  := {}
	Local cCompEmp := FWModeAccess("SB1", 1) //Compartilhamento Empresa
	Local cCompUN  := FWModeAccess("SB1", 2) //Compartilhamento unidade de negócio
	Local cCompFil := FWModeAccess("SB1", 3) //Compartilhamento filial
	Local lUsaEmp  := !Empty(FWSM0Layout(cEmpAnt, 1))
	Local lUsaUN   := !Empty(FWSM0Layout(cEmpAnt, 2))

	If cCompEmp+cCompUN+cCompFil == "EEE" .Or. ; //SB1 Exclusiva OU
	   ( !lUsaEmp .And. !lUsaUN .And. cCompFil == "E") .Or. ; //Não usa unidade de negócio/empresa e Filial exclusiva OU
	   ( !lUsaEmp .And. lUsaUN .And. cCompUN+cCompFil == "EE") //Não usa empresa, usa unidade de negócio e Unidade de negócio + filial exclusiva
		//Processa somente filial atual
		aAdd(aFilInt, cFilAnt)
	ElseIf cCompEmp+cCompUN+cCompFil == "EEC"
		//Processa todas as filiais vinculadas a Empresa + Unidade de negócio
		aFilInt := FwAllFilial(FWCompany(),FWUnitBusiness(),cEmpAnt,.F.)
	ElseIf cCompEmp+cCompUN+cCompFil == "ECC"
		//Processa todas as filiais vinculadas a Empresa
		aFilInt := FwAllFilial(FWCompany(),,cEmpAnt,.F.)
	ElseIf cCompEmp+cCompUN+cCompFil == "CCC"
		//Processa todas as filiais
		aFilInt := FwAllFilial(,,cEmpAnt,.F.)
	Else
		//Nenhuma das anteriores, irá processar somente a filial atual.
		aAdd(aFilInt, cFilAnt)
	EndIf

Return aFilInt

/*/{Protheus.doc} UpdGCDescP
Abre thread para atualizar a descrição do grupo de compras nos produtos vinculados (tabela HWA)

@type   Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, Código do grupo de compras que foi alterado
@param cGCDesc, Character, Descrição do grupo de compras que foi alterado
@return Nil
/*/
Function UpdGCDescP(cGrCom, cGCDesc)

	//Abre uma thread para fazer a integração do produto com o MRP (HWA).
	StartJob("MTA010IGRC", GetEnvServer(), .F., cEmpAnt, cFilAnt, cGrCom, cGCDesc)

Return

/*/{Protheus.doc} MTA010IGRC
Função para executar a integração dos produtos vinculados a um grupo de compras.
Alteração do campo AJ_DESC

@type   Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, Código do grupo de compras que foi alterado
@param cGCDesc, Character, Descrição do grupo de compras que foi alterado
@return Nil
/*/
Function MTA010IGRC(cEmp, cFil, cGrCom, cGCDesc)

	ErrorBlock({|oDetErro| MTA010PCPE(oDetErro) })

	Begin Sequence
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		SetFunName("MATA010") //Seta a função inicial para MATA010

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
Função para buscar e integrar os produtos vinculados a um grupo de compras

@type  Static Function
@author parffit.silva
@since 20/04/2021
@version P12
@param cGrCom , Character, Código do grupo de compras que foi alterado
@param cGCDesc, Character, Descrição do grupo de compras que foi alterado
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
				//Inclui um registro na T4R para a integração
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
Cria semáforo para processamento paralelo da integração com o MRP

@type  Static Function
@author lucas.franca
@since 09/06/2021
@version P12
@param lLock  , Logical  , Se verdadeiro, irá tentar fazer o LOCK. Se falso, irá liberar o lock.
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
Função chamada pelo MATA010M para complementar os submodelos do Model.

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
Função chamada pelo MATA010M para complementar os formulários da View.

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

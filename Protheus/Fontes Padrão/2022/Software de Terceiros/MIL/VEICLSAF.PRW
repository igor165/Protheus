////////////////
// Versao 008 //
////////////////

#include "protheus.ch"
#include "VEICLSAF.CH"

Function VEICLSAF()
Return()

/*/{Protheus.doc} DMS_FilialHelper

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de filiais no protheus
/*/
Class DMS_FilialHelper
	Data cLayout
	Data aNivel

	Method New() CONSTRUCTOR
	Method GetFiliais()
	Method GetFilial()
	Method CompareAccess()
	Method GetAllFil()
	Method GetAllEmp()
	Method GetAllFilEmpresa()
	Method GetAllFilGrupoEmpresa()
	Method GetAllFilPermis()
	Method FiltroFilial()
	Method GetFornecedor()
	Method LoadLayout()
	Method GetCliente()
	Method GetCodCli()
	Method GetCodFor()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_FilialHelper
	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class DMS_FilialHelper
	self:cLayout := ""
	self:aNivel  := {}
Return SELF

/*/{Protheus.doc} GetCliente
	Retorna recno do cliente da filial(SA1)

	@author Vinicius Gati
	@since 05/05/2014
	@param cFil, character, Filial

/*/
Method GetCliente(cFili) class DMS_FilialHelper
	Local nInd := ASCAN(FWLoadSM0(), {|i| i[1] == cEmpAnt .AND. i[2] == cFili })
	Local cDoc := FWLoadSM0()[nInd][18]
	if GetNewPar("MV_XMIL001", .F.) == .T. // para voltar o comportamento antigo
		return FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('SA1') + " WHERE A1_CGC like '"+cDoc+"' AND D_E_L_E_T_ = ' ' ")
	endif
Return FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('SA1') + " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_CGC like '"+cDoc+"' AND D_E_L_E_T_ = ' ' ")

/*/{Protheus.doc} GetFornecedor
	Retorna recno do cliente da filial(SA1)

	@author Vinicius Gati
	@since 11/10/2016
	@param cFil, character, Filial

/*/
Method GetFornecedor(cFili) class DMS_FilialHelper
	Local nInd := ASCAN(FWLoadSM0(), {|i| i[1] == cEmpAnt .AND. i[2] == cFili })
	Local cDoc := FWLoadSM0()[nInd][18]
	if GetNewPar("MV_XMIL001", .F.) == .T. // para voltar o comportamento antigo
		Return FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('SA2') + " WHERE A2_CGC like '"+cDoc+"' AND D_E_L_E_T_ = ' ' ")
	endif
Return FM_SQL(" SELECT R_E_C_N_O_ FROM " + RetSqlName('SA2') + " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_CGC like '"+cDoc+"' AND D_E_L_E_T_ = ' ' ")

/*/{Protheus.doc} GetCodCli
	Retorna array com Codigo e Loja de Cliente da FILIAL e Recno no 3 elemento

	@author Manoel Filho
	@since 25/01/2019
	@param 1o Filial a ser consultada

/*/
Method GetCodCli(cFili, lVerParam) class DMS_FilialHelper
	Local aSM0       := {}
	Local cCGC       := ""
	Local aRetCliLoj := {}
	Local cSql       := ""
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local lMV_FILTRF := .f.

	Default cFili     := cFilAnt
	Default lVerParam := .f.
	//
	aSM0             := FWArrFilAtu(cEmpAnt,cFili)
	cCGC             := aSM0[18]
	//
	If lVerParam
		lMV_FILTRF := GetNewPar("MV_FILTRF", .F.)
	EndIf

	cSql := "SELECT A1_COD, A1_LOJA, R_E_C_N_O_ AS RECSA1 "
	cSql += "FROM " + RetSqlName('SA1') + " "
	cSql += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
	cSql += "  AND A1_CGC = '" + cCGC + "' "
	cSql += Iif(lVerParam .And. lMV_FILTRF, "  AND A1_FILTRF = '" + cFili +"' ", "")
	cSql += "  AND A1_MSBLQL <> '1' "
	cSql += "  AND D_E_L_E_T_ = ' '"

	aRetCliLoj := oSqlHlp:GetSelectArray(cSql, 3)
	If  Len(aRetCliLoj) == 0
		Help(1," ","REGNOIS",,CRLF + "SA1" + CRLF + RetTitle("A1_CGC")+": "+cCGC,4,1)
		return { "", "" }
	Endif
	//
Return ( { aRetCliLoj[1,1] , aRetCliLoj[1,2] , aRetCliLoj[1,3] } )

/*/{Protheus.doc} GetCodFor
	Retorna array com Codigo e Loja de Fornecedor da FILIAL e Recno no 3 elemento

	@author Manoel Filho
	@since 15/02/2019
	@param 1o Filial a ser consultada

/*/
Method GetCodFor(cFili, lVerParam) class DMS_FilialHelper
	Local aSM0       := {}
	Local cCGC       := ""
	Local aRetForLoj := {}
	Local cSql       := ""
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local lMV_FILTRF := .f.

	Default cFili     := cFilAnt
	Default lVerParam := .f.
	//
	aSM0             := FWArrFilAtu(cEmpAnt,cFili)
	cCGC             := aSM0[18]
	//
	If lVerParam
		lMV_FILTRF := GetNewPar("MV_FILTRF", .F.)
	EndIf

	cSql := "SELECT A2_COD, A2_LOJA, R_E_C_N_O_ AS RECSA2 "
	cSql += "FROM " + RetSqlName('SA2') + " "
	cSql += "WHERE A2_FILIAL = '" + xFilial("SA2") + "' "
	cSql += "  AND A2_CGC = '" + cCGC + "' "
	cSql += Iif(lVerParam .And. lMV_FILTRF, "  AND A2_FILTRF = '" + cFili +"' ", "")
	cSql += "  AND A2_MSBLQL <> '1' "
	cSql += "  AND D_E_L_E_T_ = ' '"

	aRetForLoj := oSqlHlp:GetSelectArray(cSql, 3)
	If  Len(aRetForLoj) == 0
		Help(1," ","REGNOIS",,CRLF + "SA2" + CRLF + RetTitle("A2_CGC")+": "+cCGC,4,1)
		return { "" , "" , 0 }
	Endif
	//
Return ( { aRetForLoj[1,1] , aRetForLoj[1,2] , aRetForLoj[1,3] } )

/*/{Protheus.doc} GetFilial
	Retorna as filiais(formato xFilial) para as empresas do parametro aEmpresas

	@author Vinicius Gati
	@since 05/05/2014
	@param aEmpresas, character, Empresas para retornar filiais no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@example
		oDMS_FilialHelper:GetFiliais({'E04', 'E03'}, 'VEC') => {'E04F01    ', 'E03F01    '}
/*/
Method GetFiliais(aEmpresas, cTabela) Class DMS_FilialHelper
	Local cFilSALVA  := cFilAnt //Salva para retornar o cache
	Local aFiliais   := {}
	Local nIdx       := {}

	For nIdx := 1 to Len(aEmpresas)
		cEmpresa := aEmpresas[nIdx]
		cFilAnt  := cEmpresa // Usada internamente para determinar a empresa atual do sistema e retornar filiais(xFilial)
		AADD( aFiliais, xFilial(cTabela) )
	Next

	cFilAnt := cFilSALVA //Retorna Cache
Return aFiliais

/*/{Protheus.doc} GetFilial
	Retorna as filial(formato xFilial) para a empresa do parametro cEmpresa

	@author Vinicius Gati
	@since 05/05/2014
	@param cEmpresa, character, Empresa atual para retornar filial no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@example
		oDMS_FilialHelper:GetFilial('E04', 'VEC') => 'E04F01    '
/*/
Method GetFilial(cEmpresa, cTabela) Class DMS_FilialHelper
	Local cFilSALVA := cFilAnt
	Local cFil      := ''

	cFilAnt := cEmpresa
	cFil    := xFilial(cTabela)
	cFilAnt := cFilSALVA // Retorna Cache
Return cFil

Method CompareAccess(cFilBase, cFil) Class DMS_FilialHelper
	Local nBaseSize := LEN(ALLTRIM(cFilBase))
	Local nCompSize := LEN(ALLTRIM(cFil    ))
	Local cRet := Nil

	If nBaseSize == 0
		cRet := 'LIBERAL'
	ElseIf nBaseSize == nCompSize .OR. nBaseSize < nCompSize
		// o == acima é avaliado como cortar, pois precisa entrar no where da query, pois pode
		// ser que o B1 tenha E01 e o registro E02 por exemplo, eles tem o mesmo tamanho mas precisa entrar na query pois são diferentes
		cRet := 'CORTAR'
	ElseIf nBaseSize > nCompSize
		cRet := 'FECHADO'
	EndIf
Return cRet


/*/{Protheus.doc} GetAllFilEmpresa
Retorna todas as filiais do mesmo grupo de empresa logado
@type method
@author Rubens
@since 25/11/2015
@version 1.0
@param lAllFil, booleano, Indica se deve retornar todas as filiais
/*/
Method GetAllFilEmpresa(lAllFil) Class DMS_FilialHelper
	Local aRetorno
	Local aFilAtu
	If !lAllFil
		aRetorno := { cFilAnt }
	Else
		aFilAtu  := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial )
		aRetorno := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
	EndIf
Return aRetorno

/*/{Protheus.doc} GetAllFilGrupoEmpresa
Retorna todas as filiais do mesmo grupo de empresa logado.
O metodo GetAllFilEmpresa retorna todas as filiais do mesmo grupo de empresa/unidade de negocio.
@type method
@author Rubens
@since 25/11/2015
@version 1.0
/*/
Method GetAllFilGrupoEmpresa() Class DMS_FilialHelper
	Local aFilAtu  := FWArrFilAtu()
	Local aSM0     := FWLoadSM0()
	Local aRetorno := {}
	aEval(aSM0,{ |x| IIF( x[SM0_GRPEMP] == aFilAtu[SM0_GRPEMP] , AADD( aRetorno , x[SM0_CODFIL] ) , NIL ) })
Return aRetorno

/*/{Protheus.doc} FiltroFilial
Metodo utilizado para filtrar as filiais que o usuario pode ter acesso. ( Permissao no VAI )
Filtro executado de acordo com a configuracao de gestao corporativa
@type method
@author Rubens
@since 25/11/2015
@version 1.0
@param cAtuFilial, character, Filial que o usuario esta logado
@param aPesqFilial, array, Matriz com as filiais do sistema
@param cNivelFiltro, character, Nivel considerado no filtro (1=Filtro pelo primeiro nivel da Gestao Corporativa, 2=Filtro pelo segundo nivel, 3=Filtro pelo terceiro nivel)
/*/
Method FiltroFilial(cAtuFilial, aPesqFilial, cNivelFiltro) Class DMS_FilialHelper
	Local aAuxRetorno := {}
	Local nCont
	Local cFilFilial
	Local nNivelFiltro
	If Empty(self:cLayout)
		self:LoadLayout()
	EndIf
	nNivelFiltro := Val(cNivelFiltro)
	If nNivelFiltro == 0
		aAuxRetorno := aClone(aPesqFilial)
	Else
		cFilFilial := Left(cAtuFilial, Self:aNivel[nNivelFiltro,2] )
		aEval(aPesqFilial,{ |x| IIf( Left( x , Self:aNivel[nNivelFiltro,2] ) == cFilFilial , AADD( aAuxRetorno , x ) , NIL ) })
	EndIf
Return aClone(aAuxRetorno)


/*/{Protheus.doc} LoadLayout
Carrega o layout de Gestao Corporativa configurado.
@type method
@author Rubens
@since 25/11/2015
@version 1.0
/*/
Method LoadLayout() Class DMS_FilialHelper
	Local nPos
	Local nAuxTam2 := 0
	self:cLayout := AllTrim(FWSM0Layout())
	If Empty(self:cLayout)
		self:cLayout := "FF"
	EndIf
	self:aNivel := {{0,0,""},{0,0,""},{0,0,""}}

	nAuxNivel := 1
	nAuxTam := 0
	For nPos := 1 to Len(self:cLayout)
		nAuxTam++
		nAuxTam2++
		If nPos == Len(self:cLayout) .or. (SubStr(self:cLayout,nPos,1) <> SubStr(self:cLayout,nPos + 1,1))
			self:aNivel[nAuxNivel][1] := nAuxTam
			self:aNivel[nAuxNivel][2] := nAuxTam2
			nAuxTam := 0
			nAuxNivel++
		EndIf
	Next nPos
Return

/*/{Protheus.doc} DMS_FaseFinanciamento
	Representa tabela do VX5

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class DMS_FaseFinanciamento
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class DMS_FaseFinanciamento
Return Self

Method GetTbCode() Class DMS_FaseFinanciamento
Return '031'

/*/{Protheus.doc} DMS_FasesOrcamento

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class DMS_FasesOrcamento
	Data oData

	Method New() CONSTRUCTOR
	Method All()
	Method Get()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class DMS_FasesOrcamento
	aStatus := {;
		{"0", STR0004 },; // "ORÇAMENTO DIGITADO"
		{"X", STR0005 },; // "ORÇAMENTO FECHADO"
		{"C", STR0006 },; // "ORÇAMENTO CANCELADO"
		{"2", STR0007 },; // "MARGEM DE LUCRO"
		{"3", STR0008 },; // "LIMITE DE CREDITO"
		{"4", STR0009 },; // "SEPARACAO E CONFERENCIA"
		{"5", STR0010 },; // "LIBERACAO DE DIVERGENCIA"
		{"E", STR0011 },; // "ORCAMENTO ENVIO DE EMAIL"
		{"R", STR0012 },; // "RESERVA O ITEM"
		{"O", STR0013 },; // "IMPRIME ORDEM DE BUSCA"
		{"B", STR0014 },; // "GRAVAÇÃO DO VQH (BACKORDER)"
		{"T", STR0001 },; // "Aguard. Transf./Reserva"
		{"I", STR0002 },; // Exportado para OS
		{"F", STR0003 } ; // Pronto para faturar
	}
	If ( ExistBlock("VXFNB001") )
		aStatus := ExecBlock("VXFNB001",.f.,.f.,{aStatus})
	EndIf
	::oData := DMS_DataContainer():New(aStatus)
Return Self

Method All(cNumOrc) Class DMS_FasesOrcamento
Return Self:oData

Method Get(cStats) Class DMS_FasesOrcamento
	cVal := Self:oData:GetValue(cStats)
Return cVal

/*/{Protheus.doc} GetAllFilPermis
Retorna todas as filiais permitidas para o usuario do mesmo grupo de empresa logado
@type method
@author Andre Luis Almeida
@since 28/04/2016
@version 1.0
@param lAllFil, booleano, Indica se deve retornar todas as filiais ou somente as permitidas para o usuario
/*/
Method GetAllFilPermis(lAllFil) Class DMS_FilialHelper
	Local nCnt := 0
	Local aRet := {}
	Local aAux := FWLoadSM0(.t.,.t.) // FWLoadSM0( lForce , lChkUser )
	For nCnt := 1 to len(aAux)
		If aAux[nCnt,1] == cEmpAnt // Empresa Logada
			If lAllFil .or. aAux[nCnt,11] // Todas as Filiais ou Filial Permitida para o Usuario Logado
				aAdd(aRet,aAux[nCnt,2])
			EndIf
		EndIf
	Next
Return aRet

/*/{Protheus.doc} GetAllFil
Retorna todas as filiais de todas Empresas e Unidades de Negócios
@param lAllFil, booleano, Indica se deve retornar todas as FILIAIS ou somente as permitidas para o usuario
@param cEmpSel, caracter, Indica de qual Empresa sera retornada as Filiais
@type method
@author Andre Luis Almeida 
@since 03/04/2018
@version 1.0
/*/
Method GetAllFil(lAllFil,cEmpSel) Class DMS_FilialHelper
Local aRetorno  := {}
Local aFiliais  := FWLoadSM0()
Local nCntFor   := 0
Default lAllFil := .f. // Default Retornar somente as Filiais PERMITIDAS para o usuario
Default cEmpSel := cEmpAnt // Default Retornar somente as Filiais da Empresa Logada
For nCntFor := 1 to len(aFiliais)
	If cEmpSel == aFiliais[nCntFor,1] // Empresa
		If lAllFil .or. aFiliais[nCntFor,11] // Permissao da Filial
			aAdd(aRetorno,aFiliais[nCntFor,2]) // Filial
		EndIf
	EndIf
Next
Return aRetorno

/*/{Protheus.doc} GetAllEmp
Retorna todas as Empresas do SM0
@param lAllEmp, booleano, Indica se deve retornar todas as EMPRESAS ou somente as permitidas para o usuario
@type method
@author Andre Luis Almeida 
@since 03/04/2018
@version 1.0
/*/
Method GetAllEmp(lAllEmp) Class DMS_FilialHelper
Local aRetorno  := {}
Local aEmpresas := FWLoadSM0()
Local nCntFor   := 0
Local cEmpresas := "INICIAL"
Default lAllEmp := .f. // Default Retornar somente as Empresas PERMITIDAS para o usuario
aSort(aEmpresas,1,,{|x,y| x[1] < y[1] })
For nCntFor := 1 to len(aEmpresas)
	If lAllEmp .or. aEmpresas[nCntFor,11] // Permissao da Filial
		If cEmpresas <> aEmpresas[nCntFor,1] // Controle para retornar um vez a Empresa
			cEmpresas := aEmpresas[nCntFor,1]
			aAdd(aRetorno,aEmpresas[nCntFor,1]) // Retornar Empresa
		EndIf
	EndIf
Next
Return aRetorno

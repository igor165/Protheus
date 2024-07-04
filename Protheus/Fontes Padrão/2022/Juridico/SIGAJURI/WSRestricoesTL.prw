#INCLUDE "WSRESTRICOESTL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRESTRICOES
Métodos WS REST do Jurídico para restrições do TOTVS Legal

@author SIGAJURI
@since 12/03/2021

/*/
//-------------------------------------------------------------------
WSRESTFUL JURRESTRICOES DESCRIPTION STR0001 // "WS Jurídico Restrições"

	WSDATA filial       AS STRING
	WSDATA cajuri       AS STRING
	WSDATA rotina       AS STRING
	WSDATA codPesq      AS STRING

	WSMETHOD GET restricRot      DESCRIPTION STR0002 PATH 'restricRot'        PRODUCES APPLICATION_JSON // 'Restrições de Rotinas do TOTVS Legal'
	WSMETHOD GET assJurxPesq     DESCRIPTION STR0003 PATH 'assJurxPesq'       PRODUCES APPLICATION_JSON // 'Busca o assunto jurídico correspondente ao código da pesquisa'

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} restricRot
Busca as restrições do usuário para as rotinas do TOTVS Legal

@param filial: Filial do assunto jurídico
@param cajuri: Código do assunto jurídico
@param rotina: Rotina

@since 12/03/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/restricRot?filial=D MG 01 &cajuri=0000000247
/*/
//-------------------------------------------------------------------
WSMETHOD GET restricRot WSRECEIVE filial, cajuri, rotina WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cFilPro    := self:filial
Local cCajuri    := self:cajuri
Local cRotina    := IIF( VALTYPE(self:rotina) <> "U", self:rotina, "")
Local cAssJur    := ""
Local cResult    := ""
Local aRestric   := {}
Local nX         := 0

	Self:SetContentType("application/json")
	oResponse['restricoes'] := {}

	If !Empty(cCajuri)
		cAssJur  := JurGetDados("NSZ", 1, cFilPro + cCajuri, "NSZ_TIPOAS")
		cResult  := JPermissTL(cAssJur, cRotina)
		aRestric := JURSQL(cResult,"*")

		For nX := 1 To Len(aRestric)
			Aadd(oResponse['restricoes'], JsonObject():New())
			oResponse['restricoes'][nX]['visualizar'] := aRestric[nX][1] == '1'
			oResponse['restricoes'][nX]['incluir']    := aRestric[nX][2] == '1'
			oResponse['restricoes'][nX]['alterar']    := aRestric[nX][3] == '1'
			oResponse['restricoes'][nX]['excluir']    := aRestric[nX][4] == '1'
			oResponse['restricoes'][nX]['rotina']     := aRestric[nX][5]
		Next nX
	EndIf

	aSize(aRestric, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldRestri
Valida a restrição de acessos do usuário

@param cTpAssJur, string, Código do tipo de assunto jurídico
@param cRotina,   string, Código da rotina
@param nOpc,      string, Operaçãoexecutada

@return lRet,     boolean, Retorna .F. caso o usuário não possua acesso

@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JVldRestri(cTpAssJur, cRotina, nOpc)

Local cAlias      := ""
Local cQuery      := ""
Local lRet        := .F.

Default cTpAssJur := '001'
Default cRotina   := '14'
Default nOpc      := 2
	
	// Se o usuário é do grupo de subsídio,for da rotina de anexo ou solicitação de subsídio, permite a manipulação.
	If cRotina $ "'03'/'19'"
		aEval(J218RetGru( __cUserId ), {|cGrupo| lRet := lRet .or. Posicione('NZX',1,xFilial('NZX')+cGrupo,'NZX_TIPOA') == '4' })
	Endif

	If !lRet
		cAlias      := GetNextAlias()
		cQuery := JPermissTL(cTpAssJur, cRotina)
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

		lRet := (cAlias)->(! Eof())

		While lRet .And. (cAlias)->(! Eof()) 
			Do case 
				Case nOpc == 2
					If (cAlias)->NWP_CVISU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 3
					If (cAlias)->NWP_CINCLU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 4
					If (cAlias)->NWP_CALTER == '2'
						lRet := .F.
					EndIf
				Case nOpc == 5
					If (cAlias)->NWP_CEXCLU == '2'
						lRet := .F.
					EndIf
			End Case

			(cAlias)->(dbSkip())
		End

		(cAlias)->(DbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPermissTL
Busca as permissoes de acessos do usuário para o TOTVS Legal

@param cTpAssJur, string, Código do tipo de assunto jurídico
@param cRotina,   string, Código da rotina

@return cQuery,   string, retorno da query com acessos do usuário
@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JPermissTL(cTpAssJur, cRotina)

Local cQuery      := ""
Local cUser       :=  __CUSERID 
Local cGrupos     := ArrTokStr(J218RetGru(cUser),"','")
Local lNVKCasJur  := .F.

Default cRotina := ""

	// Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	cQuery := " SELECT NWP_CVISU, "
	cQuery +=        " NWP_CINCLU, "
	cQuery +=        " NWP_CALTER, "
	cQuery +=        " NWP_CEXCLU, "
	cQuery +=        " NWP_CROT, "
	cQuery +=        " NVK_CGRUP "
	cQuery += " FROM   " + RetSqlname("NVK") + " NVK "
	cQuery +=        " LEFT JOIN " + RetSqlname("NWP") + " NWP "
	cQuery +=                " ON ( NWP_CCONF = NVK_COD "
	cQuery +=                     " AND NWP_FILIAL = '" + xFilial("NWP") + "'"
	If !Empty(cRotina)
		cQuery +=                 " AND NWP_CROT IN ( " + cRotina + " ) "
	EndIf
	cQuery +=                     " AND NWP.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " LEFT JOIN " + RetSqlname("NVJ") + " NVJ "
	cQuery +=               " ON ( NVJ_FILIAL = '" + xFilial("NVJ") + "'"
	cQuery +=                    " AND NVK_CPESQ = NVJ_CPESQ "
	cQuery +=                    " AND NVJ.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE ( NVK_CUSER = '" + cUser + "' "
	cQuery +=               " OR NVK_CGRUP IN ( '" + cGrupos + "' ) ) "

	If lNVKCasJur
		cQuery +=       " AND ( NVK_CASJUR = '" + cTpAssJur + "' "
		cQuery +=               " OR NVJ_CASJUR = '" + cTpAssJur + "' ) "
	Else
		cQuery +=               " AND NVJ_CASJUR = '" + cTpAssJur + "' "
	EndIf

	cQuery +=       " AND NVK.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET assJurxPesq
Busca o assunto jurídico correspondente ao código da pesquisa

@param codPesq: Código da pesquisa

@since 29/04/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/assJurxPesq?codPesq=002
/*/
//-------------------------------------------------------------------
WSMETHOD GET assJurxPesq WSRECEIVE codPesq WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := Nil
Local cCodPesq   := self:codPesq
Local cQuery     := ""
Local aListAss   := {}
Local nX         := 0

Default codPesq := ""

	Self:SetContentType("application/json")

	If !Empty(cCodPesq)
		oResponse := JsonObject():New()
		oResponse['assuntos'] := {}

		cQuery := " SELECT NVJ_CASJUR ASSUNTO "
		cQuery += " FROM " + RetSqlname("NVJ") + " NVJ "
		cQuery += " WHERE NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "' "
		cQuery +=   " AND NVJ.NVJ_CPESQ = '" + cCodPesq + "' "
		cQuery +=   " AND NVJ.D_E_L_E_T_ = ' ' "

		aListAss := JURSQL(cQuery,"*")

		For nX := 1 To Len(aListAss)
			Aadd(oResponse['assuntos'], JsonObject():New())
			oResponse['assuntos'][nX]['codAssJur'] := aListAss[nX][1]
		Next nX
	EndIf

	aSize(aListAss, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

#Include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FUNGENMON
Descricao: 	Fonte com as funções Genericas Utilizadas no Projeto 
				Monitoramento TISS

@author Hermiro Júnior
@since 24/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
function ArrayPop(aArray,nPos)
    if len(aArray) == 1
        aSize(aArray,0)
	    aArray := Nil
	    aArray := {}
    else
        aDel(aArray,nPos)
        aSize(aArray,len(aArray)-1)
    endif
return

function ArrToJson(aArray)
    local nLenArr := Len(aArray)
    local nPos    := 1
    local cJson   := ""
    local cKey    := ""
    local cValue  := ""

    cJson += "{"
    for nPos := 1 to nLenArr
        cKey    := Lower(aArray[nPos][1])
        cValue  := aArray[nPos][2]
        cValue  := iif(ValType(cValue) == "C",'"' + cValue + '"',Str(cValue))
        
        cJson += '"' + cKey + '": '
        cJson += cValue
        cJson += iif(nPos < nLenArr,',','')
    next
    cJson += "}"

return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCdMun
Descricao 

@author Hermiro Júnior
@Param: Codigo do Municipio 
@Return: .T. = Valido | .F. = Invalido
/*/
//-------------------------------------------------------------------
Function GetCdMun(cCodMun)

	Local lRet		:= .T.
	Local cQuery 	:= ''
	Local cArea		:= GetNextAlias()

	If !Empty(cCodMun) .AND. Val(cCodMun) > 0
	
		cQuery := " SELECT BID_CODMUN FROM " + RetSqlName("BID") 
		cQuery += " WHERE BID_FILIAL = '" + xFilial("BID") + "' " 
		cQuery += " AND BID_CODMUN like '" + AllTrim(cCodMun) + "%' "
		cQuery += " AND D_E_L_E_T_ = ' '" 	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cArea,.F.,.T.)
		
		lRet := !(cArea)->(Eof())
		(cArea)->(dbCloseArea())
	Else
		lRet	:= .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ExisTabTiss
Descricao: 	Funcao que verifica se o codigo existe na Tabela de 
				Terminologia da TISS

@author Hermiro Júnior
@Param: Codigo do Municipio 
@Return: .T. = Valido | .F. = Invalido
/*/
//-------------------------------------------------------------------
//-> Validar se o Codigo do Procedimento existe na Tabela de Terminologia da TISS 
Function ExisTabTiss(cInf,cTab,lIsProcedure)

	Local lRet		:= .F.
	Local cQuery 	:= ''
	Local cAliasQry:= GetNextAlias()
	default lIsprocedure := .F.

	If !(lIsprocedure)
		cQuery	:= "SELECT "
		cQuery	+= "		B2R_CODTAB, B2R_CDTERM, B2R_VIGDE, B2R_VIGATE "
		cQuery	+= " FROM "+RetSqlName('B2R')+" B2R " 
		cQuery 	+= " WHERE  "
		cQuery 	+= "		B2R_CODTAB = '"+cTab+"'	AND	"
		cQuery 	+= "		B2R_CDTERM = '"+cInf+"'	AND	"
		cQuery 	+= "		B2R.D_E_L_E_T_= ' '				"
	Else
		cQuery	:= "SELECT "
		cQuery	+= "		B7Z_CODTAB, B7Z_CODPRO "
		cQuery	+= " FROM "+RetSqlName('B7Z')+" B7Z " 
		cQuery 	+= " WHERE  "
		cQuery 	+= "		B7Z_CODTAB = '"+cTab+"'	AND	"
		cQuery 	+= "		B7Z_CODPRO = '"+cInf+"'	AND	"
		cQuery 	+= "		B7Z.D_E_L_E_T_= ' '				"
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(Eof())
		Return lRet
	Else
		If !(lIsprocedure)
			//-> Verifica se o Codigo do Procedimento está vigente 
			If StoD((cAliasQry)->B2R_VIGDE) <= Date() .And. (Empty((cAliasQry)->B2R_VIGATE) .Or. StoD((cAliasQry)->B2R_VIGATE) >= Date())
				lRet 	:= .T.
			EndIf 
		Else
			lRet := .T.
		EndIf
	EndIf

	// Fecha a Area 
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbCloseArea())

Return lRet




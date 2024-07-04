#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"


Static oRevisao := Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JADGFTMP
Revisão de Pré Fatura

@author David Fernandes
@since 01/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA207REVPF( oPanel, oView )
private cPreFt   := FwFldGet("NX0_COD")
private cClien   := FwFldGet("NX1_CCLIEN")
private cLoja    := FwFldGet("NX1_CLOJA")
private cCaso    := FwFldGet("NX1_CCASO")


If oRevisao == Nil
	oRevisao := TJURREVPREFAT():New( oPanel, oView, cPreFt, cClien, cLoja, cCaso )
Else
	oRevisao:Refresh()
Endif

oRevisao:Primeiro(oPanel)

Return Nil


//-------------------------------------------------------------------
/*/ { Protheus.doc } JA207GetRev
Rotina para obter o objeto da tela de revisão

@author David Fernandes
@since 01/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA207GetRev()
Return oRevisao



//-------------------------------------------------------------------
/*/ { Protheus.doc } JA207SetNew()
Rotina para liberar o objeto da tela de revisão

@author Luciano Pereira dos Santos
@since 12/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA207SetNil()
	oRevisao := Nil
Return 



//-------------------------------------------------------------------
/*/ { Protheus.doc } JA207NVE01()
Consulta padrão de casos na tela de revisão

@author Luciano Pereira dos Santos
@since 12/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA207NVE01()
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := ""
Local cAlias   := "NVE"

cQuery   := " SELECT	NVE_CCLIEN, NVE_LCLIEN, NVE_NUMCAS, SA1.A1_NOME, NVE.NVE_TITULO, "+CRLF
cQuery   += " NT0_COD, NT0_NOME, NVE.R_E_C_N_O_ NVERECNO "+CRLF
cQuery   += " FROM " + RetSqlName("NX1") + " NX1,  "+CRLF
cQuery   +=			" " + RetSqlName("SA1") + " SA1, "+CRLF
cQuery   +=			" " + RetSqlName("NVE") + " NVE, "+CRLF
cQuery   +=			" " + RetSqlName("NT0") + " NT0 "+CRLF
cQuery   += "	WHERE	NX1.NX1_FILIAL 	= '" + xFilial("NX1") +"' "+CRLF
cQuery   += "	AND		SA1.A1_FILIAL 	= '" + xFilial("SA1") +"' "+CRLF
cQuery   += "	AND		NVE.NVE_FILIAL 	= '" + xFilial("NVE") +"' "+CRLF
cQuery   += "	AND		NT0.NT0_FILIAL 	= '" + xFilial("NT0") +"' "+CRLF
cQuery   += "	AND		NX1.NX1_CPREFT 	= '" + FWFldGet("NX0_COD") +"' "+CRLF
cQuery   += "	AND		NX1.NX1_CCLIEN 	= SA1.A1_COD "+CRLF
cQuery   += "	AND		NX1.NX1_CLOJA 	= SA1.A1_LOJA "+CRLF
cQuery   += "	AND		NX1.NX1_CCLIEN 	= NVE.NVE_CCLIEN "+CRLF
cQuery   += "	AND		NX1.NX1_CLOJA 	= NVE.NVE_LCLIEN "+CRLF
cQuery   += "	AND		NX1.NX1_CCASO 	= NVE.NVE_NUMCAS "+CRLF
cQuery   += "	AND		NX1.NX1_CCONTR 	= NT0.NT0_COD "+CRLF
cQuery   += "	AND		NX1.D_E_L_E_T_ = ' ' "+CRLF
cQuery   += "	AND		SA1.D_E_L_E_T_ = ' ' "+CRLF
cQuery   += "	AND		NVE.D_E_L_E_T_ = ' ' "+CRLF

cQuery := ChangeQuery(cQuery, .F.)

uRetorno := ''

RestArea( aArea )

If JurF3Qry( cQuery, 'JURREVCAS', cAlias+'RECNO', @uRetorno, { 0, 0, 400, 600 }  )
	(cAlias)->( dbGoto( uRetorno ) )
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{ Protheus.doc } JA207TitCamp()
Rotina para retornar o titulo do campo da tela de revisão

@Params	cCampo	Nome do campo na tabela

@Return	Titulo do campo

@author Totvs
@since 12/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA207TitCamp(cCampo)
Local cRet := AVSX3(cCampo)[5]
Return cRet
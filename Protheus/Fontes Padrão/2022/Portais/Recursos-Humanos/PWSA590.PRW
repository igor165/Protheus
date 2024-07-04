#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA590.CH"

Web Function PWSA590()

Local cHtml   		:= ""

HttpCTType("text/html; charset=ISO-8859-1")

WEB EXTENDED INIT cHtml START "InSite"

	HttpGet->titulo             := STR0001 //"Descritivo de Cargos"
	HttpSession->aStructure	   	:= {}
	HttpSession->cHierarquia	    := ""
	HttpSession->aCargos 		:= {}
	HttpSession->cDescCargo   	:= ""
	HttpSession->cRespCargo		:= ""
	HttpSession->cSkillCargo	    := ""
	HttpSession->cRelacCargo	    := ""

	fGetInfRotina("W_PWSA590.APW")
	GetMat()	//Pega a Matricula e a filial do participante logado

	cHtml := ExecInPage("PWSA590")

WEB EXTENDED END

Return cHtml 

Web Function PWSA590A()

Local oWSCargos
Local cHtml	:= ""

cDescCargo 	:= ""
cRespCargo	    := ""
cSkillCargo	:= ""
cRelacCargo	:= ""

HttpCTType("text/html; charset=ISO-8859-1")
HttpGet->titulo := STR0001 //"Descritivo de Cargos"

WEB EXTENDED INIT cHtml START "InSite"

DEFAULT HttpGet->Page		:= "1"
DEFAULT HttpGet->FilterField:= ""
DEFAULT HttpGet->FilterValue:= ""
DEFAULT HttpGet->Position	:= "0"
DEFAULT HttpGet->PageTotal	:= "1"

HttpSession->cDescCargo 	    := " "
HttpSession->cRespCargo		:= " "
HttpSession->cSkillCargo	    := " "
HttpSession->cRelacCargo	    := " "
HttpSession->nPageTotal 	    := Val(HttpGet->PageTotal)
HttpSession->nCurrentPage	:= Val(HttpGet->Page)
HttpSession->nVar			    := Val(HttpGet->Position)

HttpGet->FilterValue := DecodeUTF8(HttpGet->FilterValue)

oWSCargos := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPost"), WSRHPost():New())
WsChgURL(@oWSCargos, "RHPost.APW")

oWSCargos:cFilterField		:= HttpGet->FilterField
oWSCargos:cFilterValue		:= HttpGet->FilterValue
oWSCargos:nCurrentPage		:= HttpSession->nCurrentPage

//Busca cargos
If HttpSession->nVar == 0 //.and. !Empty(oWSCargos:cFilterValue)
	If oWSCargos:BrowsePost()
		aCargos					:= oWSCargos:oWSBrowsePostResult:oWSItens:oWSTPostList
		aSIXFilt				    := oWSCargos:oWSBrowsePostResult:oWSFiltInd:oWSTPostSIX
		HttpSession->aHead		:= oWSCargos:oWSBrowsePostResult:oWSHEAD:cSTRING
		HttpSession->nPageTotal	:= oWSCargos:oWSBrowsePostResult:nPagesTotal
		HttpSession->aCargos 	:= aClone(aCargos)
		HttpSession->aSIXFilt	:= aClone(aSIXFilt)
	Else
		HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA590A.APW" }
		Return ExecInPage("PWSAMSG" )
	EndIf
	HttpSession->nVar := 0
Else
	aCargos := aClone(HttpSession->aCargos)
	aSIXFilt	:= aClone(HttpSession->aSIXFilt)
	If Len(aCargos) == 0
		HttpSession->nPageTotal := 1
	EndIf

	If HttpSession->nVar > 0  .and. Len(aCargos) > 0
		HttpSession->cDescCargo 	:= aCargos[HttpSession->nVar]:cDescDet
		HttpSession->cRespCargo	:= aCargos[HttpSession->nVar]:cResp
		HttpSession->cSkillCargo	:= aCargos[HttpSession->nVar]:cSkills
		HttpSession->cRelacCargo	:= aCargos[HttpSession->nVar]:cRelac
	EndIf
EndIf

cHtml := ExecInPage("PWSA590A")
WEB EXTENDED END


Return cHtml

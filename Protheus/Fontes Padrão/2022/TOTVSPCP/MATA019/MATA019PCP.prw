#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'MATA019PCP.ch'

/*---------------------------------------------------------------------------------------------/
{Protheus.doc} MATA019PCP
Eventos relacionadas às regras de negócio do SIGAPCP.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe

@author Ricardo Prandi
@since 27/08/2019
@version P12.1.27
/---------------------------------------------------------------------------------------------*/
CLASS MATA019PCP FROM FWModelEvent

	DATA cIDSBZ

	METHOD New() CONSTRUCTOR

	METHOD GridLinePosVld()

ENDCLASS

/*----------------------------------------/
{Protheus.doc} New
Método construtor da classe.

@type metodo

@author Ricardo Prandi
@since 27/08/2019
@version P12.1.27
/-----------------------------------------*/
METHOD New(oModel,cIDSBZ) CLASS MATA019PCP

	Default cIDSBZ := "SBZDETAIL"

	::cIDSBZ := cIDSBZ

	oModel:InstallEvent("MATA019API",,MATA019API():New())
	oModel:InstallEvent("MATA019API",,MATA019NET():New())

Return

/*----------------------------------------------------------------/
{Protheus.doc} GridLinePosVld
Validações do MVC quando ocorrer as ações de pos validação da linha
do Grid

@type metodo

@author Ricardo Prandi
@since 27/08/2019
@version P12.1.27
/----------------------------------------------------------------*/
METHOD GridLinePosVld(oSubModel, cID, nLine) CLASS MATA019PCP

	Local lRet    := .T.
	Local nOpc    := oSubModel:GetOperation()

	If lRet .And. cID == ::cIDSBZ .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
		If oSubModel:HasField("BZ_HORFIX") .And. oSubModel:HasField("BZ_TPHOFIX")
			If oSubModel:GetValue("BZ_HORFIX") <> 0 .And. Alltrim(oSubModel:GetValue("BZ_TPHOFIX")) == ""
				Help(" ",1,"M010HORFIX")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

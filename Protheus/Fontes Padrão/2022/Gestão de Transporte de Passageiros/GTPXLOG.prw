#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPXLOG.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPLog
Classe responsavel para criação de log
@type Class
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
CLASS GTPLog From FWSerialize
	
	DATA cTitulo    as CHARACTER
	DATA lSalva     as LOGICAL
	DATA lShow      as LOGICAL
	DATA cText      as CHARACTER
	DATA lHasInfo   as LOGICAL
	DATA cClassName as CHARACTER
    Data cFunName   as Character
    Data oModel     as Object
    Data dDtIni     as Date
    Data cHrIni     as Character
	
	//DSERGTP-6567: Novo Log Rest RJ
	Data nNewLog	as Numeric
	Data oRJLog		as Object
	
	METHOD New(cTitulo,lSalva,lShow,cFunName) CONSTRUCTOR
	METHOD Destroy()
	
    METHOD ClassName()

	METHOD SetText(cText)
	METHOD GetText()
	METHOD HasInfo()
	METHOD ShowLog()
    Method ShowView()
    Method SaveLog()
	
	//DSERGTP-6567: Novo Log Rest RJ
	Method SetNewLog(lOnly)
	Method Attach(aData)
	Method ResetText()

ENDCLASS

//------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsavel pela construção da classe
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
METHOD New(cTitulo,lSalva,lShow,cFunName) Class GTPLog
Default cTitulo     := ""
Default lSalva      := .F.
Default lShow       := !IsBlind()
Default cFunName    := FunName()

Self:cTitulo    := cTitulo
Self:lSalva     := lSalva
Self:lShow      := lShow
Self:cText      := ''
Self:lHasInfo   := .F.
Self:cClassName := "GTPLog"
Self:cFunName   := cFunName
Self:oModel     := nil
Self:dDtIni     := dDataBase
Self:cHrIni     := Time()

Self:nNewLog	:= 0 //DSERGTP-6567: Novo Log Rest RJ, 0 - Log original, 1 - Somente Log Novo, 2 - Ambos

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsavel pela destruição da classe
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
METHOD Destroy() Class GTPLog

Self:cTitulo    := ''
Self:lSalva     := .F.
Self:lShow      := .F.
Self:cText      := ''
Self:lHasInfo   := .F.
Self:cFunName   := ''

//DSERGTP-6567: Novo Log Rest RJ
If ( Self:nNewLog > 0 .And. ValType(Self:oRJLog) == "O" )
	Self:oRJLog:Destroy()
	GtpDestroy(Self:oRJLog)	//DSERGTP-6567: Novo Log Rest RJ
EndIf

GtpDestroy(Self:oModel)
GtpDestroy(Self)
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetText
Metodo responsavel retornar o nome da classe
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
METHOD ClassName() Class GTPLog
Return Self:cClassName

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetText
Metodo responsavel para gravar o texto no log
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
METHOD SetText(cText) Class GTPLog
Default cText := ""

Self:lHasInfo:= .T.

Self:cText	 += cText + Chr(13)+Chr(10)

Return Self:cText

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetText
Metodo responsavel para retornar o texto preenchido no log
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:cText
/*/
//------------------------------------------------------------------------------
METHOD GetText() Class GTPLog
Return Self:cText

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasInfo
Metodo responsavel para verificar se foi preenchido algum dado no log
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:lHasInfo
/*/
//------------------------------------------------------------------------------
METHOD HasInfo() Class GTPLog

//DSERGTP-6567: Novo Log Rest RJ
Return(Self:lHasInfo .Or. (Self:nNewLog > 0 .And. Self:oRJLog:ExistLog())) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ShowLog
Metodo responsavel pela visualização do log para o usuário
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return Self:GetText()
/*/
//------------------------------------------------------------------------------
METHOD ShowLog() Class GTPLog

If ( Self:lShow .and. Self:nNewLog == 0 )
	Self:ShowView()
Endif

If Self:lSalva
    Self:SaveLog()
Endif 

Return Self:GetText()

//------------------------------------------------------------------------------
/*/{Protheus.doc} ShowView
Metodo responsavel pela visualização do log para o usuário
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
METHOD ShowView() Class GTPLog
Local oMdlLog       := FwLoadModel('GTPXLOG')
Local oViewExec     := FWViewExec():New()
Local aButtons      := GtpBtnView(.F.,"",.T.,STR0001)//"Fechar"

oMdlLog:SetOperation(MODEL_OPERATION_INSERT)
oMdlLog:Activate()
oMdlLog:GetModel("GZIMASTER"):LoadValue('GZI_PARAME',Self:cText)
oMdlLog:lModify := .F.

oViewExec:setSource("GTPXLOG")
oViewExec:setModel(oMdlLog)
oViewExec:setReduction(75)
oViewExec:SetTitle(Self:cTitulo)
oViewExec:SetButtons(aButtons)

oViewExec:openView()

oMdlLog:Destroy()

GtpDestroy(oMdlLog)
GtpDestroy(oViewExec)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SaveLog
Metodo responsavel pela persisistencia dos dados na tabela GZI
@type method
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
METHOD SaveLog() Class GTPLog

	Local oSubModel     := nil

	If ( Self:nNewLog == 0 .Or. Self:nNewLog == 2 )	//DSERGTP-6567: Novo Log Rest RJ

		Self:oModel := FwLoadModel('GTPA038')
		oSubModel     := Self:oModel:GetModel('GZIMASTER')

		Self:oModel:SetOperation(MODEL_OPERATION_INSERT)

		If Self:oModel:Activate()
			oSubModel:LoadValue('GZI_DESCRI' ,Self:cTitulo    )
			oSubModel:LoadValue('GZI_DTINI'  ,Self:dDtIni     )
			oSubModel:LoadValue('GZI_HRINI'  ,Self:cHrIni     )
			oSubModel:LoadValue('GZI_PARAME' ,Self:cText      )
		Endif

		If Self:oModel:VldData()
			Self:oModel:CommitData()
		Endif

		Self:oModel:DeActivate()
		Self:oModel:Destroy()

	EndIf
	
	//DSERGTP-6567: Novo Log Rest RJ
	If ( Self:nNewLog > 0 )
		Self:oRJLog:CommitData()
		Self:oRJLog:FinishModel()
	EndIf

Return

//DSERGTP-6567: Novo Log Rest RJ
Method SetNewLog(lOnly,lSingle,cUrl,cFunName) Class GTPLog

	Default lOnly 	:= .T.
	Default lSingle := .F.
	Default cUrl	:= ""
	Default cFunName:= Self:cFunName
	
	If ( lOnly )
		Self:nNewLog := 1
	Else
		Self:nNewLog := 2
	EndIf

	If ( findclass("GTPRJLOG") .And. ( AliasInDic("GYS") .And. GYS->(FieldPos("GYS_ROTINA")) > 0 ) ) //verificar uma função que verifica se a classe está compilada
		Self:oRJLog := GTPRJLog():New(cFunName,lSingle,cUrl)
	Else
		Self:nNewLog := 0
	EndIf	

Return()

//DSERGTP-6567: Novo Log Rest RJ
Method Attach(aData) Class GTPLog

	Default aData := {}

	If ( Self:nNewLog > 0 .And. Self:oRJLog:cModelType == "Relacional" )

		If ( !Self:oRJLog:IsActive() )
			Self:oRJLog:SetOperation(MODEL_OPERATION_INSERT)
			Self:oRJLog:Activate()
		EndIf	

		Self:oRJLog:AddLine()
		Self:oRJLog:FillData(aData,.T.)
		
	EndIf

Return()

//DSERGTP-6567: Novo Log Rest RJ
Method ResetText() Class GTPLog
	
	Self:cText 		:= ""
	Self:lHasInfo	:= .F.
	
Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrGZI	:= FWFormModelStruct():New()

GTPxCriaCpo(oStrGZI,{"GZI_PARAME"},.T.)

oModel := MPFormModel():New('GTPXLOG', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('GZIMASTER',/*cOwner*/,oStrGZI,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0002)//'Log de Processamento'

oModel:GetModel('GZIMASTER'):SetDescription(STR0002)//'Log de Processamento' 

oModel:GetModel('GZIMASTER'):SetOnlyQuery(.T.)

oModel:SetPrimaryKey({''})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()

oView:CreateHorizontalBox('LOG', 100)	

oView:AddOtherObject("MEMO_PANEL", {|oPanel| ShowMemoPanel(oPanel,oView)})

oView:SetOwnerView("MEMO_PANEL",'LOG')

oView:AddUserButton( STR0003, "", {|oView| SaveMemo(oView)} )//"Salvar Log"

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} ShowMemoPanel
Função responsavel para salvar o memo do campo GZI_PARAME
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@param oPanel, object, (Descrição do parâmetro)
@param oView, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------

Static Function ShowMemoPanel(oPanel,oView)
Local cMemo         := oView:GetModel('GZIMASTER'):GetValue('GZI_PARAME')
Local oFont         := TFont():New('Courier new',,-16,.F.)
Local aClientRect   := oPanel:GetClientRect()
Local n1            := aClientRect[1]+2
Local n2            := aClientRect[2]+2
Local n3            := Round(aClientRect[3]*0.493,0)
Local n4            := Round(aClientRect[4]*0.485,0)

	@ n1,n2 GET oMemo  VAR cMemo MEMO SIZE n3,n4 OF oPanel PIXEL 
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	oMemo:EnableVSCroll(.T.)
	oMemo:Disable(.T.)

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} SaveMemo
Função responsavel para salvar o memo do campo GZI_PARAME
@type Static Function
@author jacomo.fernandes
@since 24/01/2020
@version 1.0
@param oView, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SaveMemo(oView)
Local cMask	:= STR0004+" (*.TXT) |*.txt|"//"Arquivos Texto"
Local cFile	:= cGetFile(cMask,OemToAnsi(STR0005))//"Salvar Como..."
Local cMemo	:= oView:GetModel('GZIMASTER'):GetValue('GZI_PARAME')

If !Empty(cFile)
	If At('.TXT',Upper(cFile)) == 0
		cFile+= ".txt"
	Endif
	MemoWrite(cFile,cMemo)
Endif

Return 

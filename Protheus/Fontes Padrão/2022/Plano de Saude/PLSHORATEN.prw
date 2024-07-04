#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'PLSHORATEN.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSHORATEN
Tela de Cadastro de Horários de Atendimento - Totvs Guia
@since  01/01/2020
//-------------------------------------------------------------------*/
function PLSHORATEN(lAutoma)
local cFiltro   := "@(BAU_FILIAL = '" + xFilial("BAU") + "') "
private cCodInt := PlsIntPad() //inicializador da BB8
private cDado   := '' //Pesquisa F3
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BAU')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetOnlyFields( { 'BAU_FILIAL', 'BAU_CODIGO', 'BAU_NOME', 'BAU_NREDUZ', 'BAU_CPFCGC', 'BAU_NFANTA'} )
oBrowse:AddLegend("BAU->BAU_CODBLO==Space(03) .Or. BAU->BAU_DATBLO > DDATABASE", "GREEN", STR0002 ) //Autorizado
oBrowse:AddLegend("BAU->BAU_CODBLO<>Space(03) .AND. BAU->BAU_DATBLO <= DDATABASE", "RED", STR0003 ) //Negado
oBrowse:SetDescription(STR0001) //Cadastro de Horário de Atendimento - Totvs Guia
iif(!lAutoma, oBrowse:Activate(), '')
return 


/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    01/2020
//-------------------------------------------------------------------*/
static function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0004 Action 'VIEWDEF.PLSHORATEN' Operation 2 Access 0 //'Visualizar'
Add Option aRotina Title STR0005 Action 'VIEWDEF.PLSHORATEN' Operation 4 Access 0 //'Alterar'

return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    01/2020
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel    := nil     
Local oStrBAU   := FWFormStruct(1,'BAU')
Local oStrBB8   := FWFormStruct(1,'BB8')
Local oStrB5H   := FWFormStruct(1,'B5H')

oModel := MPFormModel():New('PLSHORATEN')

oModel:addFields('MASTERBAU',,oStrBAU) 
oModel:AddGrid('BB8Detail', 'MASTERBAU', oStrBB8)
oModel:AddGrid('B5HDetail', 'BB8Detail', oStrB5H,,{|| ValidHorGr(oModel)})

oStrB5H:SetProperty( "B5H_DIASEM" , MODEL_FIELD_VALID,  { || ChkVlrIns(alltrim(oModel:getModel("B5HDetail"):getValue("B5H_DIASEM")), oModel) } )
oStrB5H:setProperty( "B5H_CODOPE" , MODEL_FIELD_INIT, { || PlsIntPad()} )
oStrB5H:setProperty( "B5H_CODRDA" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrB5H:setProperty( "B5H_CGCCPF" , MODEL_FIELD_INIT, { || BAU->BAU_CPFCGC} )
oStrB5H:setProperty( "B5H_CODLOC" , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_CODLOC")} )
oStrB5H:setProperty( "B5H_LOCAL"  , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_LOCAL")} )
oStrB5H:setProperty( "B5H_DESCRI" , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_DESLOC")} )

oModel:SetRelation( 'BB8Detail', { { 'BB8_FILIAL', 'xFilial( "BB8" ) ' } , ;
								   { 'BB8_CODIGO', 'BAU_CODIGO' } }      , ;
								   BB8->( IndexKey( 1 ) ) )

oModel:SetRelation( 'B5HDetail', { { 'B5H_FILIAL', 'xFilial( "B5H" ) ' } , ;
								   { 'B5H_CODOPE', 'BB8_CODINT' }        , ;
								   { 'B5H_CODRDA', 'BB8_CODIGO' } 		 , ;
								   { 'B5H_CODLOC', 'BB8_CODLOC' } 		 , ;
								   { 'B5H_LOCAL' , 'BB8_LOCAL'  }  }     , ;
								   B5H->( IndexKey( 1 ) ) )

oModel:GetModel('B5HDetail'):setOptional(.T.)
oModel:GetModel('BB8Detail'):SetOnlyView( .T. )

oModel:GetModel('MASTERBAU'):SetDescription(STR0006) // Horários e Dias de Atendimentos
return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    01/2020
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView     := nil
Local oModel  	:= FWLoadModel( 'PLSHORATEN' )
Local oStrBAU   := FWFormStruct(2, 'BAU', { |cCampo| CmpViewBAU(cCampo) } )
Local oStrBB8   := FWFormStruct(2, 'BB8')
Local oStrB5H   := FWFormStruct(2, 'B5H', { |cCampo| CmpViewB5H(cCampo) })

oView := FWFormView():New()
oView:SetModel(oModel)

oStrBAU:SetProperty( '*' , MVC_VIEW_CANCHANGE, .f. ) 
oStrBAU:SetNoFolder()

oView:AddField('ViewBAU' , oStrBAU,'MASTERBAU' )
oView:AddGrid( 'ViewBB8' , oStrBB8,'BB8Detail' )
oView:AddGrid( 'ViewB5H' , oStrB5H,'B5HDetail' )

oView:CreateHorizontalBox( 'SUPERIOR' , 15 )
oView:CreateHorizontalBox( 'MEIO'     , 35 )
oView:CreateHorizontalBox( 'INFERIOR' , 50 )

oView:SetOwnerView('ViewBAU','SUPERIOR')
oView:SetOwnerView('ViewBB8','MEIO')
oView:SetOwnerView('ViewB5H','INFERIOR')

oView:SetViewProperty("ViewB5H", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewB5H", "GRIDSEEK", {.T.})
oView:SetCloseOnOK( { || .T. } )

oView:SetDescription(STR0006) //'Horários e Dias de Atendimentos'
oView:EnableTitleView('ViewBB8',STR0007) //Locais de Atendimento do Prestador
oView:EnableTitleView('ViewB5H',STR0008) //Dias e horários de atendimento ao público

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} CmpViewBAU
Campos que devem ser exibidos na view BAU
@since    01/2020
//-------------------------------------------------------------------*/
static function CmpViewBAU(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ 'BAU_CODIGO,BAU_NOME,BAU_NFANTA,BAU_CPFCGC'
	lRet := .t.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} CmpViewB5H
Campos que devem ser exibidos na view BB8
@since    01/2020
//-------------------------------------------------------------------*/
static function CmpViewB5H(cCampo)
Local lRet := .f.

if !alltrim(cCampo) $ 'B5H_CODOPE,B5H_CODRDA,B5H_CGCCPF,B5H_SEQUEN'
	lRet := .t.
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSDIHRRG
F3  específico de consulta: Dias da Semana
@since   01/2020
//-------------------------------------------------------------------*/
Function PLSDIHRRG(cDado, lAutoma)
Local oDlg		:= nil
local aGridDad	:= Separa(GetNewPar("MV_PLTMGDH","SEG/TER/QUA/QUI/SEX/SAB/DOM/FER"), '/') 
Local nFor		:= 0
Local nOpc		:= 0
Local bOK		:= { || nOpc := 1, oDlg:End() }
Local bCancel	:= { || oDlg:End() }
local oWinBrw   := nil
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

for nFor := 1 to Len(aGridDad)
	aGridDad[nFor] := {aGridDad[nFor], .f.}
next

cDado := ""

if !lAutoma
	oDlg 	:= MSDialog():New(3,0,340,450,STR0009,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //'Dias da Semana'
	oWinBrw := TcBrowse():New( 035, 006, 215, 125,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oWinBrw:AddColumn(TcColumn():New(" ",{ ||if(aGridDad[oWinBrw:nAt,2],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oWinBrw:AddColumn(TcColumn():New(STR0010,{ || OemToAnsi(aGridDad[oWinBrw:nAt,1]) },"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil)) //Dias
	oWinBrw:SetArray(aGridDad)         
	oWinBrw:bLDblClick := { || aGridDad[oWinBrw:nAt,2] := Eval( { || nIteMar := 0, aEval(aGridDad, {|x| Iif(x[2], nIteMar++, )}), Iif(nIteMar < 50 .Or. aGridDad[oWinBrw:nAt, 2],if(aGridDad[oWinBrw:nAt,2],.F.,.T.),.F.) })}
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
endif

if nOpc == 1 .or. lAutoma                
	For nFor := 1 To Len(aGridDad)
		if aGridDad[nFor,2]
			cDado += Subs(aGridDad[nFor,1], 1, 3) + "/"
		endif 
	Next
endif
                                  
cDado := AjsDiasSem(cDado)

return .t.


/*//-------------------------------------------------------------------
{Protheus.doc} ChkVlrIns
Valida campo de dias da semana: valida valores imputados e corrige duplicidade de dados.
@since   01/2020
//-------------------------------------------------------------------*/
static function ChkVlrIns(cVlrCmp, oModel)
local aVlrAct	:= Separa(GetNewPar("MV_PLTMGDH","SEG/TER/QUA/QUI/SEX/SAB/DOM/FER"), '/') //{'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM', 'FER'}
local lRet 		:= .t.
local aTemp		:= {}
local aHelp		:= {'','',''} //1ª Título da janela / 2ª Texto do problema encontrado / 3ª Solução do problema (opcional)
local nI		:= 0

if !empty(cVlrCmp)
	if ( !('/' $ cVlrCmp) .and. (len(alltrim(cVlrCmp)) > 3) )
		aHelp := {STR0015, STR0011 , STR0012} //'Os dias da semana devem ser separados por barra "/"'
		lRet := .f.
	elseif ( len(alltrim(cVlrCmp)) ) > 3
		aTemp := Separa(AjsDiasSem(cVlrCmp), '/')
		cVlrCmp := ''
	else
		aadd(aTemp, cVlrCmp)
	endif

	for nI := 1 to len(aTemp)
		if aScan(aVlrAct, {|x| Upper(alltrim(x)) == alltrim(aTemp[nI])}) == 0
			aHelp := {STR0015,STR0012,STR0013 + CRLF + STR0014} //'Os dias devem ser informados conforme layout de exportação.'
			lRet := .f.
			exit
		endif
		cVlrCmp	+= iif ( !alltrim(aTemp[nI]) $ cVlrCmp, alltrim(aTemp[nI]) + "/",'' )
	next
endif	

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
endif

if lRet
	oModel:getModel("B5HDetail"):LoadValue("B5H_DIASEM", AjsDiasSem(cVlrCmp))
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} AjsDiasSem
Tira barra final do campo de dias da semana
@since   01/2020
//-------------------------------------------------------------------*/
static function AjsDiasSem(cValor)

if Subs(cValor, Len(cValor), 1) == "/"
	cValor := Subs(cValor, 1, Len(cValor)-1)
endif

return cValor


/*//-------------------------------------------------------------------
{Protheus.doc} ValidHorGr
Inserir o sequencial na gravação dos itens
@since   01/2020
//-------------------------------------------------------------------*/
static function ValidHorGr(oModel)
local lRet 	:= .t.
Local oB5H 	:= oModel:getmodel("B5HDetail")

if empty(oB5H:getValue("B5H_SEQUEN"))
	oB5H:loadValue("B5H_SEQUEN", GETSX8NUM("B5H","B5H_SEQUEN"))
endif
return lRet

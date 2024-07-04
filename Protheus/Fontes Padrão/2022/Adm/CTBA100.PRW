#INCLUDE "CTBA100.CH"
#INCLUDE "PROTHEUS.CH"
#Include 'FWMVCDEF.ch'

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static __cProcPrinc :="CTBA100"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA100
Manutencao do Cadastro de Rateio 
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//--------------------------------------------------------------------
Function CTBA100()
Local oBrowse		:= NIL

//Analise da existencia dos campos das novas entidades  
Ctb100IniVar()

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'CT9' )
oBrowse:SetDescription(OemToAnsi(STR0006)) //Cadastro de Eventos
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Utilizacao de menu Funcional
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//--------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local lCTB100MNU := ExistBlock("CTB100MNU")

ADD OPTION aRotina Title STR0001	Action 'VIEWDEF.CTBA100'	OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.CTBA100'	OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.CTBA100'	OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.CTBA100'	OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.CTBA100'	OPERATION 5 ACCESS 0 //Excluir
ADD OPTION aRotina Title STR0021	Action 'CT100IMP'	OPERATION 3 ACCESS 0 //"Importar"
ADD OPTION aRotina TITLE STR0022	ACTION 'CT100LOG'OPERATION 6 ACCESS 0 //"Log Proc"

If lCTB100MNU
	aRotina := ExecBlock("CTB100MNU",.F.,.F.,{aRotina})
Endif

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados da rotina 
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ModelDef
Local oStruCAB := FWFormStruct( 1, 'CT9', {|x|  Alltrim(x)+"|" $ "CT9_RAT_ON|CT9_DESC|CT9_PERBAS|CT9_MOEDLC|CT9_TPSALD|"})
Local oStruCT9 := FWFormStruct( 1, 'CT9', {|x|  !Alltrim(x)+"|" $ "CT9_RAT_ON|CT9_DESC|CT9_PERBAS|CT9_MOEDLC|CT9_TPSALD|"})
Local oModel

oModel := MPFormModel():New( 'CTBA100',/*bPreValidacao*/, {|oModel| Ctb100TOk(oModel)}/*bPosValidacao*/, {|oModel| Ctb100Grava(oModel)}/*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'CT9MASTER', /*cOwner*/, oStruCAB )
oModel:AddGrid( 'CT9DETAIL', 'CT9MASTER', oStruCT9, /*bLinePre*/, {|oModel| CTB100LOK(oModel)}/*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'CT9DETAIL', { { 'CT9_FILIAL', 'xFilial( "CT9" )' },{ 'CT9_RAT_ON', 'CT9_RAT_ON' } }, CT9->( IndexKey( 1 ) ) )
                                                                                                                           
//Campos totalizadores de debito
oModel:AddCalc( 'TOTCT9', 'CT9MASTER', 'CT9DETAIL', 'CT9_PERCEN', 'DEBTOT', 'SUM',{ | oFW | CT100CALC( oFW, .T. ) }/*{|oModel| Ct100TpRat("1",,,oModel)}*/ ,,("% " + STR0012) ) //"% Total Debito"
//Campos totalizadores de credito
oModel:AddCalc( 'TOTCT9', 'CT9MASTER', 'CT9DETAIL', 'CT9_PERCEN', 'CRETOT', 'SUM',{ | oFW | CT100CALC( oFW, .F. ) }/*{|oModel| Ct100TpRat("2",,,oModel)}*/,,("% " + STR0013) ) //"% Total Crédito"

oModel:SetPrimaryKey({'xFilial("CT9")','CT9_RAT_ON','CT9_SEQUEN'})

//Linha duplicada
oModel:GetModel( 'CT9DETAIL' ):SetUniqueLine( { 'CT9_SEQUEN' } )

//Validação de campo
oStruCT9:SetProperty( 'CT9_PERCEN' , MODEL_FIELD_VALID,{|| CT100VlPer()})
oStruCAB:SetProperty( 'CT9_MOEDLC' , MODEL_FIELD_VALID,{|| Ct100MoedLC()})
oStruCAB:SetProperty( 'CT9_RAT_ON' , MODEL_FIELD_VALID,{|| Ctb100Rat()})

//Modo de edição
oStruCAB:SetProperty( 'CT9_RAT_ON' , MODEL_FIELD_WHEN,{|| INCLUI})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 ) //"Criterios de Rateio"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view de dados da rotina 
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function Viewdef()
Local oStruCAB := FWFormStruct( 2, 'CT9', {|x|  Alltrim(x)+"|" $ "CT9_RAT_ON|CT9_DESC|CT9_PERBAS|CT9_MOEDLC|CT9_TPSALD|"})
Local oStruCT9 := FWFormStruct( 2, 'CT9', {|x|  !Alltrim(x)+"|" $ "CT9_RAT_ON|CT9_DESC|CT9_PERBAS|CT9_MOEDLC|CT9_TPSALD|CT9_EVENTO|"})
Local oModel   := FWLoadModel( 'CTBA100' )
Local oView
Local oCalc  

oStruCT9:SetProperty( 'CT9_SEQUEN' , MVC_VIEW_CANCHANGE,.F.)

oCalc := FWCalcStruct( oModel:GetModel('TOTCT9') )

oView := FWFormView():New()
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CAB',		oStruCAB	, 'CT9MASTER' )
oView:AddField( 'VIEW_CALC',	oCalc		, 'TOTCT9' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CT9', oStruCT9, 'CT9DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 10 )
oView:CreateHorizontalBox( 'MEIO'		, 75 )
oView:CreateHorizontalBox( 'INFERIOR'	, 15 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CT9'	, 'MEIO' )
oView:SetOwnerView( 'VIEW_CALC'	, 'INFERIOR' )

oView:AddIncrementField('VIEW_CT9','CT9_SEQUEN')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB100RAT
Verifica a existência do Rateio 
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function Ctb100Rat()
Local aSaveArea		:= GetArea()
Local aAreaCT9		:= CT9->(GetArea())
Local lRet			:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB		:= oModel:GetModel('CT9MASTER')
Local cRateio		:= oModelCab:GetValue("CT9_RAT_ON") 

lRet := FreeForUse("CT9", cRateio)

If lRet .And. Empty(cRateio) 
	lRet := .F.
ElseIf lRet 
	dbSelectArea("CT9")
	dbSetOrder(1)
	
	If CT9->(dbSeek(xFilial("CT9") + cRateio))
		oModel:SetErrorMessage("","","","","CT9_RATEIO","","")
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaCT9)
RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct100MoedLC
Valida moeda do lancamento
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function Ct100MoedLC()
Local aCtbMoeda	:= {}
Local lRet			:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB	:= oModel:GetModel('CT9MASTER')
Local cMoeda		:= FWFLDGET("CT9_MOEDLC")

aCtbMoeda  	:= CtbMoeda(cMoeda)

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
   lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT100CHG
Valida alteracao do tipo do lancamento
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function CT100CHG()
Local lRet 		:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB	:= oModel:GetModel('CT9MASTER')
Local oModelCT9	:= oModel:GetModel('CT9DETAIL')
Local nPercentual	:= oModelCT9:GetValue("CT9_PERCEN")
Local cTipo		:= oModelCT9:GetValue("CT9_DC")
Local cMoeda		:= FWFLDGET("CT9_MOEDAS")

If cTipo != NIL
	If cTipo == "4"
		Help("",1,"NOTIPODC4")
		lRet	:= .F.
	EndIf
EndIf

If nPercentual != NIL
	If cTipo == "4" .And. nPercentual != 0
		Help("",1,"CT9NOVAL")
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ctb100Moeda
Valida CT9_MOEDAS
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function ctb100Moeda()
Local aSaveArea	:= GetArea()
Local lRet			:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB	:= oModel:GetModel('CT9MASTER')
Local cMoedas		:= FWFLDGET("CT9_MOEDAS")
Local nTam			:= TAMSX3("CT9_MOEDAS")
Local nCont

IF !Empty(cMoedas)
	For nCont := 1 To nTam
		If !SubStr(cMoedas,nCont,1) $ "12"
			Help(" ",1,"CT9MOEDA")
			lRet := .F.
			Exit
		EndIF
	Next nCont
Else
	lRet := .f.
EndIf

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb100IniVar
Analise da existência dos campos das novas entidades
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function Ctb100IniVar()

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CT9->(FieldPos("CT9_EC05CR")>0 .And. FieldPos("CT9_EC05DB")>0)
EndIf

If _lCpoEnt06 == Nil
	_lCpoEnt06 := CT9->(FieldPos("CT9_EC06CR")>0 .And. FieldPos("CT9_EC06DB")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CT9->(FieldPos("CT9_EC07CR")>0 .And. FieldPos("CT9_EC07DB")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CT9->(FieldPos("CT9_EC08CR")>0 .And. FieldPos("CT9_EC08DB")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CT9->(FieldPos("CT9_EC09CR")>0 .And. FieldPos("CT9_EC09DB")>0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb100LOK
Valida Linha da Getdados -> Linha OK
@author Thiago Murakami
@since 19/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function CTB100LOK(oModel)
Local lRet 		:= .T.
Local lCpoVazio 	:= .F.

If INCLUI .Or. ALTERA

		lCpoVazio :=  (	Empty(oModel:GetValue('CT9_DC'))	.And.							  							; //Tipo Lanc
						Empty(oModel:GetValue('CT9_CREDIT'))	.And. Empty(oModel:GetValue('CT9_DEBITO'))	.And.	; //Conta Contabil
						Empty(oModel:GetValue('CT9_CCC'))		.And. Empty(oModel:GetValue('CT9_CCD'))		.And.	; //Centro Custo
						Empty(oModel:GetValue('CT9_ITEMC'))	.And. Empty(oModel:GetValue('CT9_ITEMD'))		.And.	; //Item Contabil
						Empty(oModel:GetValue('CT9_CLVLCR'))	.And. Empty(oModel:GetValue('CT9_CLVLDB'))			) //Classe Valor

		lCpoVazio := If(_lCpoEnt05 .And. lCpoVazio, (Empty(oModel:GetValue('CT9_EC05CR')) .And. Empty(oModel:GetValue('CT9_EC05DB'))), lCpoVazio) //Entidade 05		
		lCpoVazio := If(_lCpoEnt06 .And. lCpoVazio, (Empty(oModel:GetValue('CT9_EC06CR')) .And. Empty(oModel:GetValue('CT9_EC06DB'))), lCpoVazio) //Entidade 06
		lCpoVazio := If(_lCpoEnt07 .And. lCpoVazio, (Empty(oModel:GetValue('CT9_EC07CR')) .And. Empty(oModel:GetValue('CT9_EC07DB'))), lCpoVazio) //Entidade 07		
		lCpoVazio := If(_lCpoEnt08 .And. lCpoVazio, (Empty(oModel:GetValue('CT9_EC08CR')) .And. Empty(oModel:GetValue('CT9_EC08DB'))), lCpoVazio) //Entidade 08
		lCpoVazio := If(_lCpoEnt09 .And. lCpoVazio, (Empty(oModel:GetValue('CT9_EC09CR')) .And. Empty(oModel:GetValue('CT9_EC09DB'))), lCpoVazio) //Entidade 09
		
		//Verifica amarrações permitidas
		lRet := CtbAmarra(oModel:GetValue('CT9_DEBITO'),oModel:GetValue('CT9_CCD'),oModel:GetValue('CT9_ITEMD'),oModel:GetValue('CT9_CLVLDB'),.T.)
	
		If lRet
			lRet := CtbAmarra(oModel:GetValue('CT9_CREDIT'),oModel:GetValue('CT9_CCC'),oModel:GetValue('CT9_ITEMC'),oModel:GetValue('CT9_CLVLCR'),.T.)	
		EndIf
		
		If lCpoVazio
			Help(" ",1,"CT9DCVAZIO")
			lRet := .F.
		EndIf
		
		If ! Ctb100RtIg(oModel)
			Help(" ",1,"CT9DCRATIG")
			lRet := .F.
		Endif
				
		If lRet
			If oModel:GetValue('CT9_DC') $"123" .And. oModel:GetValue('CT9_PERCEN') == 0
				Help(" ",1,"NOPERCENT")
				lRet	:= .F.
			EndIf
		EndIf
		
		If lRet
			If oModel:GetValue('CT9_PERCEN') <= 0 .or. oModel:GetValue('CT9_PERCEN') > 100
				Help(" ",1,"NOPERCENT")
				lRet	:= .F.
		    EndIf
		EndIf
		
		If lRet
			If Empty(oModel:GetValue('CT9_DEBITO'))
				ValidaConta(oModel:GetValue('CT9_DEBITO'),"1",,,.t.)
			ElseIf lRet
				lRet := CTB105EntC(,oModel:GetValue('CT9_DEBITO'),,'01')
			Endif
			
			If Empty(oModel:GetValue('CT9_CREDIT'))
				ValidaConta(oModel:GetValue('CT9_CREDIT'),"2",,,.t.)
			ElseIf lRet
				lRet := CTB105EntC(,oModel:GetValue('CT9_CREDIT'),,'01')
			Endif
		EndIf

		If lRet //Verifica o tipo de lancamento e os campos preenchidos

			If oModel:GetValue('CT9_DC') == "1" //Debito
				If !Empty(oModel:GetValue('CT9_CREDIT'))							.Or.;
					!Empty(oModel:GetValue('CT9_CCC'))								.Or.;
					!Empty(oModel:GetValue('CT9_ITEMC'))							.Or.;
					!Empty(oModel:GetValue('CT9_CLVLCR'))							.Or.;
					(_lCpoEnt05 .And. !Empty(oModel:GetValue('CT9_EC05CR')))	.Or.;
					(_lCpoEnt06 .And. !Empty(oModel:GetValue('CT9_EC06CR')))	.Or.;
					(_lCpoEnt07 .And. !Empty(oModel:GetValue('CT9_EC07CR')))	.Or.;
					(_lCpoEnt08 .And. !Empty(oModel:GetValue('CT9_EC08CR')))	.Or.;
					(_lCpoEnt09 .And. !Empty(oModel:GetValue('CT9_EC09CR')))

					lRet := .F.
					Help(" ",1,"CTB100LOK",,STR0018,1,0) //"Para lançamentos do tipo débito,não preencher campos de crédito."

				EndIf

			ElseIf oModel:GetValue('CT9_DC') == "2" //Credito
				If !Empty(oModel:GetValue('CT9_DEBITO'))							.Or.;
					!Empty(oModel:GetValue('CT9_CCD'))								.Or.;
					!Empty(oModel:GetValue('CT9_ITEMD'))							.Or.;
					!Empty(oModel:GetValue('CT9_CLVLDB'))							.Or.;
					(_lCpoEnt05 .And. !Empty(oModel:GetValue('CT9_EC05DB')))	.Or.;
					(_lCpoEnt06 .And. !Empty(oModel:GetValue('CT9_EC06DB')))	.Or.;
					(_lCpoEnt07 .And. !Empty(oModel:GetValue('CT9_EC07DB')))	.Or.;
					(_lCpoEnt08 .And. !Empty(oModel:GetValue('CT9_EC08DB')))	.Or.;
					(_lCpoEnt09 .And. !Empty(oModel:GetValue('CT9_EC09DB')))

					lRet := .F.
					Help(" ",1,"CTB100LOK",,STR0019,1,0) //"Para lançamentos do tipo crédito,não preencher campos de débito."

				EndIf
			EndIf
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Ct100TpRat
Retorna se é lancamento do tipo solicitado de acordo  com o tipo
ou as entidades digitadas
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function Ct100TpRat(cTipo,cTpEntida,cAlias,oModel)
Local oModelCT9	:= Nil
Local lRet 		:= .F.
Local lModel		:= ValType(oModel) == 'O'
Local bExec		:= {|cCampo| If(lModel,oModelCT9:GetValue(cCampo),&(cAlias+"->"+cCampo))}

Default cTpEntida	:= ""
Default cAlias	:= "CT9"

//Adequação da avaliação pois a funcao Ct100TpRat também é executada pela CTBA102
If lModel
	oModelCT9 := oModel:GetModel('CT9DETAIL')
EndIf

If cTipo == "1"
	Do Case
		//DEBITO
	Case !Empty(Eval(bExec,"CT9_DEBITO"))
		lRet := .T.
		cTpEntida 	:= "0"
	Case !Empty(Eval(bExec,"CT9_CCD")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "1")
		lRet := .T.	
		cTpEntida := "1"
	Case !Empty(Eval(bExec,"CT9_ITEMD")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "2")
		lRet := .T.
		cTpEntida := "2"
	Case !Empty(Eval(bExec,"CT9_CLVLDB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "3")
		lRet := .T.
		cTpEntida := "3"
	Case _lCpoEnt05 .And. !Empty(Eval(bExec,"CT9_EC05DB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "4")
		lRet := .T.
		cTpEntida := "4"
	Case _lCpoEnt06 .And. !Empty(Eval(bExec,"CT9_EC06DB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "5")
		lRet := .T.
		cTpEntida := "5"
	Case _lCpoEnt07 .And. !Empty(Eval(bExec,"CT9_EC07DB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "6")
		lRet := .T.
		cTpEntida := "6"
	Case _lCpoEnt08 .And. !Empty(Eval(bExec,"CT9_EC08DB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "7")
		lRet := .T.
		cTpEntida := "7"
	Case _lCpoEnt09 .And. !Empty(Eval(bExec,"CT9_EC09DB")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "8")
		lRet := .T.			
		cTpEntida := "8"
	EndCase	
ElseIf cTipo == "2"
	Do Case
		//CREDITO
	Case !Empty(Eval(bExec,"CT9_CREDIT"))
		lRet := .T.
		cTpEntida 	:= "0"
	Case !Empty(Eval(bExec,"CT9_CCC")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "1")
		lRet := .T.	
		cTpEntida := "1"
	Case !Empty(Eval(bExec,"CT9_ITEMC")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "2")
		lRet := .T.
		cTpEntida := "2"
	Case !Empty(Eval(bExec,"CT9_CLVLCR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "3")
		lRet := .T.
		cTpEntida := "3"
	Case _lCpoEnt05 .And. !Empty(Eval(bExec,"CT9_EC05CR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "4")
		lRet := .T.
		cTpEntida := "4"
	Case _lCpoEnt06 .And. !Empty(Eval(bExec,"CT9_EC06CR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "5")
		lRet := .T.
		cTpEntida := "5"
	Case _lCpoEnt07 .And. !Empty(Eval(bExec,"CT9_EC07CR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "6")
		lRet := .T.
		cTpEntida := "6"
	Case _lCpoEnt08 .And. !Empty(Eval(bExec,"CT9_EC08CR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "7")
		lRet := .T.
		cTpEntida := "7"
	Case _lCpoEnt09 .And. !Empty(Eval(bExec,"CT9_EC09CR")) .And.;
		(Empty(cTpEntida) .Or. cTpEntida = "8")
		lRet := .T.			
		cTpEntida := "8"
	EndCase

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb100RtIg
Retorna se a linha atual tem o mesmo tipo de partida da 1o
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function Ctb100RtIg (oModel)
Local lRet 		:= .T.
Local cTpEntida 	:= ""		// Tipo da entidade que esta sendo validada
Local lDebito 	:= .F.
Local lCredito	:= .F.

If Empty(oModel:GetValue('CT9_DC'))
		
	lDebito  := Ct100TpRat("1", @cTpEntida)
	lCredito := Ct100TpRat("2", @cTpEntida)
	
	If cTpEntida = "1"			// Centro de custo
		If Empty(oModel:GetValue('CT9_CCC')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_CCD')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "2"		// Item contabil
		If Empty(oModel:GetValue('CT9_ITEMC')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_ITEMD')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "3"		// Classe de Valor
		If Empty(oModel:GetValue('CT9_CLVLCR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_CLVLDB')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "4"	.And. _lCpoEnt05	// Entidade 05
		If Empty(oModel:GetValue('CT9_EC05CR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_EC05DB')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "5" .And. _lCpoEnt06		// Entidade 06
		If Empty(oModel:GetValue('CT9_EC06CR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_EC06DB')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "6" .And. _lCpoEnt07		// Entidade 07
		If Empty(oModel:GetValue('CT9_EC07CR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_EC07DB')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "7" .And. _lCpoEnt08		// Entidade 08
		If Empty(oModel:GetValue('CT9_EC08CR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_EC08DB')) .And. lDebito
			lRet := .F.
		Endif
	ElseIf cTpEntida = "8" .And. _lCpoEnt09 	// Entidade 09
		If Empty(oModel:GetValue('CT9_EC09CR')) .And. lCredito
			lRet := .F.
		Endif
		If Empty(oModel:GetValue('CT9_EC09DB')) .And. lDebito
			lRet := .F.
		Endif
	Endif
Endif


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb100TOk
Valida Getdados -> TUDO OK
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function Ctb100TOk(oModel)
Local nDebito		:= oModel:GetValue('TOTCT9','DEBTOT')
Local nCredito	:= oModel:GetValue('TOTCT9','CRETOT')
Local oModelCT9	:= oModel:GetModel('CT9DETAIL') 
Local nPerBase	:= oModelCT9:GetValue('CT9_PERCEN')
Local aSaveLine 	:= FWSaveRows()
Local lRet  		:= .T.
Local cTpEntida := ""		// Tipo da entidade que esta sendo validada
Local nX			:= 0

If INCLUI .Or. ALTERA
	For nx := 1 To oModelCT9:Length( .T. )
		oModelCT9:GoLine(nX)
		If !Ctb100LOK(oModelCT9)
			lRet := .F.
			Exit
		EndiF
	Next
	
	nCredito 	:= Round(nCredito,2)
	nDebito	:= Round(nDebito,2)
	
	If lRet
		IF nCredito != 0 .and. nCredito != 100
			Help ( " ", 1, "CT9100%CR" )
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF nDebito != 0 .and. nDebito != 100
			Help ( " ", 1, "CT9100%DB" )
			lRet := .F.
		EndIF
	EndIf
	If lREt
		IF nCredito == 0 .and. nDebito == 0
			lRet := .T.
		EndIF
	EndIf  
	
	If lRet
		lRet := CT100VlPer(nPerBase) 
	EndIf
EndIf

FWRestRows( aSaveLine )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT100VlPer
Valida o valor de percentual base do rateio
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function CT100VlPer()
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCT9	:= oModel:GetModel('CT9DETAIL')
Local nPerBase	:= oModelCT9:GetValue("CT9_PERCEN") 		//Processo
Local aSaveLine 	:= FWSaveRows()


If nPerBase <= 0 .Or. nPerBase > 100.00
	Help(" ",1,"CT9PERCBASE",,STR0020,1,0) //"Percentual base deve ser maior que 0% ou menor ou igual a 100%"
	lRet := .F.
EndIf

FWRestRows( aSaveLine )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb100Grava
Grava registros
@author Thiago Murakami
@since 17/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function Ctb100Grava(oModel)
Local cSeq		:= STRZERO(0,TamSX3('CT9_SEQUEN')[1])
Local oStruCAB	:= oModel:GetModel("CT9MASTER")
Local cRateio 	:= oStruCAB:GetValue("CT9_RAT_ON")
Local cDesc		:= oStruCAB:GetValue("CT9_DESC")
Local cPercBase	:= oStruCAB:GetValue("CT9_PERBAS")

FWFormCommit( oModel )

dbSelectArea("CT9")
CT9->(dbSetOrder(1)) //CT9_FILIAL+CT9_RAT_ON+CT9_SEQUEN                                                                                                                                

If CT9->(dbSeek(xFilial("CT9") + cRateio ) )

	While CT9->(!Eof()) .And. CT9->(CT9_FILIAL + CT9_RAT_ON) == xFilial("CT9") + cRateio

		cSeq := Soma1(cSeq)

		RecLock("CT9",.F.)
		CT9->CT9_SEQUEN	:= cSeq
		CT9->CT9_DESC	:= cDesc
		CT9->CT9_PERBAS	:= cPercBase
		CT9->(MsUnlock())

		CT9->(DbSkip())
	EndDo

EndIf
Return .T.




/*{Protheus.doc}CT100IMP
Importa o arquivo de rateio
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT100IMP()
Local aHeader		:= {}	//Array com o cabecalho do arquivo CSV
Local aCols		:= {}	//Array com os intens do arquivo CSV	
Local lVld			:= .F.
Local nRegrava		:= 2 
Local lRegrava		:= .F.

//Le o arquivo de importacao
lVld := CTBArqRat(@aHeader,@aCols,@nRegrava) 

lRegrava:= IIf(nRegrava == 1,.T.,.F.)

//Gravação da importação
If lVld 
	C100GRVRAT(@aHeader,@aCols,lRegrava)
EndIf

Return



/*{Protheus.doc}CTBArqRat
Importa o arquivo de rateio
@author Mayara Alves da silva
@since 05/07/2015
@param aHeader	- Cabeçalho do arquivo de importação
@param aCols		- Itens do arquivo de importação
@param nRegrava	- Sobresqueve arquivo sim ou não
@version P12
@project Inovação Controladoria
*/
Function CTBArqRat(aHeader,aCols,nRegrava)      
Local aPar			:=	{}  //Array parambox  
Local aRet			:=	{} 	//Array retorno parambox  
Local aRetAux		:=  {}  
Local cLinha		:=	"" //linha de leitura do arquivo
Local aCampo		:=	{} //CVN->(DbStruct())
//Local aHeader		:= {}	//Array com o cabecalho do arquivo CSV
//Local aCols		:= {}	//Array com os intens do arquivo CSV
Local cAli			:= ""	//Tabela de importação
Local lRet			:= .T.
Local cMensIni 	:= ""
Local cLogErro	:= ""
Local cId			:= ""
Local lponto		:= ExistBlock("CTARQRAT") //Ponto de entrada para manupular a linha de leitura do arquivo
Local nX			:= 0
Local nY			:= 0
Local aErros		:= {}
Local nErros		:= 0

DEFAULT	nRegrava	:= 2

If FWIsInCallStack( "CTBA100" )
	aCampo	:=	CT9->(DbStruct())
	cAli		:= "CT9"
	__cProcPrinc:="CTBA100"
ElseIf FWIsInCallStack( "CTBA120" )
	aCampo	:=	CTJ->(DbStruct())
	cAli		:= "CTJ"
	__cProcPrinc := "CTBA120"
ElseIf FWIsInCallStack( "CTBA270" )
	aCampo	:=	CTQ->(DbStruct())
	cAli		:= "CTQ"
	__cProcPrinc := "CTBA270"
EndIf

//Define o valor do array conforme estrutura
aPosCampos:= Array(Len(aCampo))

aAdd(aPar,{6,STR0023,padr('',150),"",,"",90 ,.T.,"Arquivo .CSV |*.CSV",'',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Arquivo para Importação"
aAdd(aPar,{2,STR0024,2,{STR0025,STR0026},30,,.T.}) //"sobrescreve regra existente" #"Sim"#"Não"

//"Exportar para arquivo plano referencial"
If ParamBox(aPar,STR0027,@aRetAux)//"Rateio Online - Importação CSV" 
	
	aRet		 := AjRetParam(aRetAux,aPar)
	nRegrava	:= 	aRet[2]
	//Começa o log de processamento
	ProcLogIni( {},__cProcPrinc,STR0028,@cId ) //	"Importação do Rateio"
	
	cMensIni := STR0029 //"Importação do arquivo: "
	ProcLogAtu( STR0030 , cMensIni ,,,.T. ) //"INICIO"
	
	//Valida se o arquivo exite	
	If FT_FUse(AllTrim(aRet[1]))== -1 
		Help(" ",1,"NOFILEIMPOR",,STR0031,3,1) //"Arquivo não encontrado."
		lRet := .F.
		cLogErro := STR0031+AllTrim(aRet[1])//"Arquivo não encontrado."
		ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
	EndIf
	
	//Vai para o começo do arquivo
	FT_FGOTOP()
	
	//Valida se o arquivo não está vazio
	If lRet .And. FT_FLastRec() < 2
		Help(" ",1,"ARQVAZIO",,STR0033,3,1) //"Arquivo Vazio."
		lRet := .F.
		cLogErro := STR0033
		ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
	EndIf
	
	
	//Pega o cabecalho
	cLinha := FT_FREADLN()
		
	//Valida se o cabeçalho do arquivo pertece a tabela certa
	If lRet .And. !(cAli $ cLinha)
		Help(" ",1,"CABINCORRETO",,STR0034,3,1) //"Arquivo incorreto"
		lRet := .F.
		cLogErro := STR0035//"Arquivo  com cabeçalho incorreto"
		ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
	EndIf
	
	//Valida se todos os campos existem na tabela para não gerar erro na leitura do arquivo
	If lRet 
		aHeader := StrTokArr( cLinha, ";" )
		
		For nY := 1 to Len(aHeader)
			If	FieldPos(aHeader[nY])== 0
				lRet := .F.
				cLogErro += aHeader[nY] + CRLF
			EndIf
		Next nY

		If !lRet
			ProcLogAtu(STR0032,cMensIni,STR0041 + CRLF + cLogErro,,.T. ) //"ERRO"###"Exite campo no cabeçalho do arquivo que não existe no dicionario."
			Help(" ",1,"CAMPOINCORRETO",,STR0041,3,1) //"Exite campo no cabeçalho do arquivo que não existe no dicionario."
		EndIf

	EndIf
	
	//Le o arquivo
	If lRet
		
		nPos	:=	0
	
		FT_FSKIP()
		//Le o primeiro item do arquivo
		While !FT_FEOF()
			cLinha := FT_FREADLN()

			aColsAux := CT100ARRAY(cLinha,";",Len(aHeader))

			If lponto
				aColsAux := ExecBlock("CTARQRAT",.F.,.F.,{__cProcPrinc,aHeader,aColsAux})
			EndIf

			//Array com as linhas do arquivo
			Aadd(aCols,aColsAux)
	
			FT_FSKIP()
		End
		FT_FUSE()

		//Verifica se o tamanho de coluna dos arquivos estão iguais
		If lRet
			nHeader:= Len(aHeader)
			For nx := 1 to Len(aCols)
				If nHeader <> Len(aCols[nx])
					lRet:= .F.
				EndIf
			End
			If !lRet
				Help(" ",1,"NOITENS",,STR0036,3,1) //"As colunas dos itens não bate com o numero das colunas"
				cLogErro := STR0036//"As colunas dos itens não bate com o numero das colunas do cabeçalho"
				ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
			EndIF
		Endif
		
		//Verificar se o tamanho de cada dado não extrapola a capacidade do campo 
		If lRet .And. CT100TAMSX3(aHeader,aCols,@aErros)
			lRet := .F.
			Help(" ",1,"DADOSINC",,STR0037,3,1) //"Inconsistencia nos dados"
			//cLogErro := STR0038//"Inconsistência nos campos."
			cLogErro := "Há dados que extrapolam a capacidade do campo: " + CRLF

			For nErros := 1 To Len(aErros)
				cLogErro += "Linha: " + aErros[nErros,1] + " Campo: " + aErros[nErros,2] + CRLF
			Next nErros

			ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
		EndIf
		
	EndIf
EndIf

ASize(aErros,0)
aErros	:= Nil

Return lRet


/*{Protheus.doc}CT100ARRAY
Cria array com os itens do arquivo
@author Mayara Alves da silva
@since 08/07/2015
@param cLinha	- conteudo da linah do arquivo
@param cSep		- separador
@param nCab	- numero de colunas do cabeçalho
@version P12
@project Inovação Controladoria
*/
Static Function CT100ARRAY(cLinha,cSep,nCab)
Local aRet := {}
Local aAux	:= {}
Local nPos := 0
Local nLinha	:= 0
While At( cSep, cLinha ) > 0 .Or. !Empty(cLinha)
 
	  nPos := At( cSep, cLinha )

	If nPos <> 0
		Aadd( aRet, SubStr( cLinha, 1, nPos-1 ) )
		cLinha := SubStr( cLinha, nPos+1 )
	Else
		Aadd( aRet, cLinha)
		cLinha:=""
	EndIf

	If Empty(cLinha) .And. (Len(aRet) <> nCab)
		Aadd( aRet, cLinha)
	EndIf

End

Return aRet 



/*{Protheus.doc}CT100TAMSX3
Verificar se o tamanho de cada dado não extrapola a capacidade do campo admin
@author Mayara Alves da silva
@since 08/07/2015
@param aHeader	- cabeçalho do arquivo
@param aCols		- itens do arquivo
@version P12
@project Inovação Controladoria
*/
Static Function CT100TAMSX3(aHeader,aCols,aErros)
Local lRet		:= .F.
Local nHead		:= 0
Local nCols		:= 0
Local cCampo	:= ""
Local aAliasSX3	:= SX3->(GetArea())

Default aErros	:= {}

For nCols := 1 To Len(aCols)
	For nHead := 1 To Len(aHeader)
		cCampo	:= Alltrim(aHeader[nHead])
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cCampo))		
			If Len(aCols[nCols][nHead]) > (TamSX3(cCampo)[1])
				lRet := .T.
				Aadd(aErros,{AllTrim(Str(nCols+1)),cCampo}) 
			EndIf
		EndIf
	Next nHead
Next nCols

RestArea(aAliasSX3)
Return lRet


/*{Protheus.doc}C100GRVRAT
Grava importação
Grava importação
@since 08/07/2015
@param aHeader	- Cabeçalho do arquivo de importação
@param aCols		- Itens do arquivo de importação
@param nRegrava	- Sobresqueve arquivo sim ou não
@version P12
@project Inovação Controladoria
*/
Static Function C100GRVRAT(aHeader,aCols,lRegrava)
Local nX			:= 0
Local nDadArq		:= 0
Local nHeaArq		:= 0
Local nPosEv		:= ASCAN(aHeader, "CT9_EVENTO" ) 
Local cAlias		:= GetNextAlias()
Local aCampo		:= {}
Local nHeaArq		:= 0
Local aInd			:= {}
Local oModel		:= FWLoadModel('CTBA100') 
Local oModelCAB	
Local oModelCT9	
Local cSeq			:= STRZERO(0,TamSX3('CT9_SEQUEN')[1])
Local aErro		:= {}
Local lExiCpoEve	:= nPosEv > 0
Local nPosCodR	:= ASCAN(aHeader, "CT9_RAT_ON" )
Local cMensIni	:= STR0029//"Importação do arquivo: "
Local cLogErro	:= ""
Local lErro		:= .F.
Local lGrvCab		:= .T.
Local nDadArq		:= 0
Local lSetValue	:= .T.

oModel:SetOperation(MODEL_OPERATION_INSERT)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão

oModel:Activate()

oModelCAB	:= oModel:GetModel('CT9MASTER')
oModelCT9	:= oModel:GetModel('CT9DETAIL')

For nX := 1 To Len(aCols)
	If lExiCpoEve .And. !Empty(aCols[nX][nPosEv])

		lErro := C100GRVEV(aCols[nX][nPosEv],aHeader,aCols,oModel, @nX,lRegrava)

		Loop

	Else
		cCodRat:= aCols[nX][nPosCodR]

		//Se for sobrescrever arquivo, deleta para posterior inclusão
		If lRegrava
			CTBA100Del(cCodRat)
		EndIf

		For nDadArq := nX To Len(aCols)

			//Validação para gravar cabeçalho 
			If nDadArq > 1 .And. cCodRat == aCols[nDadArq-1][nPosCodR]
				lGrvCab := .F.

				nLinha := oModelCT9:AddLine()

				oModelCT9:goline(nLinha)
			EndIf

			For nHeaArq := 1 To Len(aHeader)

				If "PERCEN" $ aHeader[nHeaArq] .Or. "QTDDIS" $ aHeader[nHeaArq] .Or. "VLR01" $ aHeader[nHeaArq]

					lSetValue := oModelCT9:SetValue(aHeader[nHeaArq],Val(StrTran(aCols[nDadArq,nHeaArq],",",".")))
				ElseIf lGrvCab .And. "CT9_RAT_ON" $ aHeader[nHeaArq]
					lSetValue := oModelCAB:SetValue("CT9_RAT_ON",aCols[nDadArq,nHeaArq])
				ElseIf lGrvCab .And."CT9_DESC"$ aHeader[nHeaArq]
					lSetValue := oModelCAB:SetValue("CT9_DESC",aCols[nDadArq,nHeaArq])
				ElseIf lGrvCab .And."CT9_PERBAS"$ aHeader[nHeaArq]
					lSetValue := oModelCAB:SetValue("CT9_PERBAS",Val(StrTran(aCols[nX,nHeaArq],",",".")))
				ElseIf lGrvCab .And."CT9_MOEDLC"$ aHeader[nHeaArq]
					lSetValue := oModelCAB:SetValue("CT9_MOEDLC",aCols[nDadArq,nHeaArq])
				ElseIf "CT9_TPSALD"$ aHeader[nHeaArq]
					lSetValue := oModelCAB:SetValue("CT9_TPSALD",aCols[nDadArq,nHeaArq])
				//Tratamento para qndo for cabeçalho	
				ElseIf "CT9_RAT_ON" $ aHeader[nHeaArq] .Or. "CT9_DESC"$ aHeader[nHeaArq].Or. "CT9_MOEDLC"$ aHeader[nHeaArq];
					.Or. "CT9_PERBAS"$ aHeader[nHeaArq] .Or. "CT9_TPSALD"$ aHeader[nHeaArq]
						Loop
				Else
					lSetValue := oModelCT9:SetValue(aHeader[nHeaArq],aCols[nDadArq,nHeaArq])

				EndIf

				//Caso identifique ocorrência na atribuição realiza a identificação 
				If !lSetValue
					aErro := oModel:GetErrorMessage()
					cLogErro += aErro[4] + " - " + aErro[6] + " - Linha: " + AllTrim(Str(nDadArq+1)) + CRLF //A linha tem a soma de mais 1 devido o cabeçalho
					lErro := .T.
				EndIf

			Next nHeaArq

			cSeq	:= Soma1(cSeq)

			oModelCT9:SetValue("CT9_SEQUEN",cSeq)
		Next nDadArq

		If lErro .And. !Empty(cLogErro)
			ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
			cLogErro := ""
		
		ElseIf oModel:VldData()
	
			oModel:CommitData()

			oModel:DeActivate()

			oModel:Activate()

		Else
			aErro   := oModel:GetErrorMessage()

			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior

			cLogErro:= aErro[4] + " - " + aErro[6] + " - " + STR0008 + " " + AllTrim(oModelCAB:GetValue("CT9_RAT_ON")) //"Rateio:"
			ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"

			lErro := .T.

		EndIf

		nX := nDadArq -1 

	EndIf
Next nX

ProcLogAtu(STR0039,cMensIni,,,.T.) //"FIM"

//Se teve algum erro, mostra o log de erros.
If lErro
	ProcLogView(,__cProcPrinc)
Endif

Return

/*{Protheus.doc}C100GRVEV
grava arquivo de importação com evento
@since 08/07/2015
@param cEvento	- Cod do evento
@param aHeader	- Cabeçalho do arquivo de importação
@param aCols		- Itens do arquivo de importação
@param oModel		- modelo ativo
@param nX			- linha q está percorendo o acols
@param lRegrava	- Define se o rateio sera sobrescrito
@version P12
@project Inovação Controladoria
*/
Static function C100GRVEV(cEvento,aHeader, aCols,oModel,nX,lRegrava)
Local aArea		:= GetArea()
Local aAreaCQK 	:= CQK->(GetArea())
Local oTabTemp	
Local nPosEv		:= ASCAN(aHeader, "CT9_EVENTO" ) 
Local cSeq			:= STRZERO(0,TamSX3('CT9_SEQUEN')[1])
Local oModelCAB	:= oModel:GetModel('CT9MASTER')
Local oModelCT9	:= oModel:GetModel('CT9DETAIL')
Local nLinha		:= 0
Local aErro		:= {}
Local lRet:= .F. //Retorna se teve erro na gravação
Local cMensIni	:= STR0029//"Importação do arquivo: "
Local nHeaArq		:= 0
Local nDadArq		:= 0
Local lSetValue	:= .T.
Local cLogErro	:= ""

DbSelectArea("CQK")
CQK->(DbSetOrder(1)) //CQK_FILIAL+CQK_CODEVE+CQK_ITEM

If CQK->(dbSeek(xFilial("CQK")+cEvento))

	While CQK->(!EOF()) .And. Alltrim(CQK->CQK_CODEVE) == cEVENTO

		//Se definido para sobrescrever, deleta o arquivo para posterior inclusao
		If lRegrava
			CTBA100Del(CQK->CQK_CODRAT)
		EndIf

		cSeq:= "001"

		//Grava cabeçalho
		oModelCAB:SetValue("CT9_RAT_ON",CQK->CQK_CODRAT)
		oModelCAB:SetValue("CT9_DESC",CQK->CQK_DESC)
		oModelCAB:SetValue("CT9_PERBAS",100)
	//--------------------------------------
	// Inclusao da partida originada da CQK
	//--------------------------------------
		//cSeq	:= Soma1(cSeq)
				
		oModelCT9:SetValue("CT9_SEQUEN",cSeq)
		oModelCT9:SetValue("CT9_PERCEN",100)
		
		If CQK->CQK_ENTBAS == "2"
			oModelCT9:SetValue("CT9_CREDIT",CQK->CQK_CREDIT)
			oModelCT9:SetValue("CT9_CCC",CQK->CQK_CCC)
			oModelCT9:SetValue("CT9_ITEMC",CQK->CQK_ITEMC)
			oModelCT9:SetValue("CT9_CLVLCR",CQK->CQK_CLVLCR)
			oModelCT9:SetValue("CT9_DC","2")
		Else //Debito
			oModelCT9:SetValue("CT9_DEBITO",CQK->CQK_DEBITO)
			oModelCT9:SetValue("CT9_CCD",CQK->CQK_CCD)
			oModelCT9:SetValue("CT9_ITEMD",CQK->CQK_ITEMD)
			oModelCT9:SetValue("CT9_CLVLDB",CQK->CQK_CLVLDB)
			oModelCT9:SetValue("CT9_DC","1")
		EndIf

	//----------------------------------------------
	// Inclusao da partida destino do arquivo + cqk
	//----------------------------------------------
		For nDadArq := nX To Len(aCols)
			
			If cEvento == aCols[nDadArq][nPosEv]
				
				nLinha := oModelCT9:AddLine()
				
				oModelCT9:goline(nLinha)
				
				For nHeaArq := 1 To Len(aHeader)
				
					If "PERCEN" $ aHeader[nHeaArq] .Or. "QTDDIS" $ aHeader[nHeaArq] .Or. "VLR01" $ aHeader[nHeaArq]
		
						lSetValue := oModelCT9:SetValue(aHeader[nHeaArq],Val(StrTran(aCols[nDadArq,nHeaArq],",",".")))
					ElseIf "CT9_RAT_ON" $ aHeader[nHeaArq] .Or. "CT9_DESC"$ aHeader[nHeaArq].Or. "CT9_MOEDLC"$ aHeader[nHeaArq];
					.Or. "CT9_PERBAS"$ aHeader[nHeaArq] .Or. "CT9_TPSALD"$ aHeader[nHeaArq]
						Loop
					Else 
						lSetValue := oModelCT9:SetValue(aHeader[nHeaArq],aCols[nDadArq,nHeaArq])

					EndIf

					//Caso identifique ocorrência na atribuição realiza a identificação
					If !lSetValue
						aErro := oModel:GetErrorMessage()
						cLogErro += aErro[4] + " - " + aErro[6] + " - Linha: " + AllTrim(Str(nDadArq+1)) + CRLF //A linha tem a soma de mais 1 devido o cabeçalho
						lRet := .T.
					EndIf

				Next nHeaArq
				
				If oModelCT9:GetValue("CT9_DC") == '2'
					lSetValue := oModelCT9:SetValue("CT9_CREDIT",CQK->CQK_CREDITO)
				Else
					lSetValue := oModelCT9:SetValue("CT9_DEBITO",CQK->CQK_DEBITO)
				EndIf

				//Caso identifique ocorrência na atribuição realiza a identificação 
				If !lSetValue
					aErro := oModel:GetErrorMessage()
					cLogErro += aErro[4] + " - " + aErro[6] + " - Linha: " + AllTrim(Str(nDadArq+1)) + CRLF //A linha tem a soma de mais 1 devido o cabeçalho
					lRet := .T.
				EndIf

				cSeq	:= Soma1(cSeq)

				lSetValue := oModelCT9:SetValue("CT9_SEQUEN",cSeq)

			Else
				Exit
			EndIf
		Next nDadArq

		If lRet .And. !Empty(cLogErro)
			ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
			cLogErro := ""
		ElseIf oModel:VldData()
		
			oModel:CommitData()
			
			oModel:DeActivate()

			oModel:Activate()

		Else
			aErro   := oModel:GetErrorMessage()
			
			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior

			cLogErro :=	aErro[4] + " - " + aErro[6] + " - " + STR0042 + " " + AllTrim(oModelCT9:GetValue("CT9_EVENTO"))+;  //"Evento:"
							" - " + STR0008 + " " + AllTrim(oModelCAB:GetValue("CT9_RAT_ON")) //"Rateio:"
			ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"

			lRet:= .T.
		EndIf

		CQK->(DBSKIP())
	ENDDO

	nX := nDadArq - 1 

Else

	cLogErro:= STR0040 + "CT9_EVENTO" + "." //"Arquivo com valor inválido. Coluna: " 
	ProcLogAtu(STR0032,cMensIni,cLogErro,,.T. ) //"ERRO"
	lRet:= .T.

EndIf 

RestArea(aAreaCQK)
RestArea(aArea)

Return lRet
/*{Protheus.doc}CT100LOG
Mostra log da rotina de importação
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT100LOG()

ProcLogView(,__cProcPrinc)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} AjRetParam  
Ajusta o retorno da Parambox.
 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   18/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet

/*{Protheus.doc}CTBA100Del
Deleta o rateio para o processo de sobrescrita de importação
@since 29/07/2015
@param cCodRat - Codigo do rateio para exclusao
@version P12
*/
Static Function CTBA100Del(cCodRat)
Local aArea		:= GetArea()
Local aAreaCT9	:= CT9->(GetArea())

//Posiciona no rateio
DbSelectArea("CT9")
CT9->(DbSetOrder(1))
If CT9->(DbSeek(FwXFilial("CT9")+cCodRat))

	While CT9->(!Eof()) .And. FwXFilial("CT9")+cCodRat == CT9->CT9_FILIAL+CT9->CT9_RAT_ON

		RecLock("CT9")
		CT9->(DbDelete())
		CT9->(MsUnLock())

	CT9->(DBSKIP())
	EndDo

EndIf

RestArea(aAreaCT9)
RestArea(aArea)

Return

/*{Protheus.doc}CT100CALC
Verifica se vai atualizar totatilazador debito ou credito
@since 18/03/2018
@param oFW - Model
@param lDebt - linha debito = .T. e credito = .F.
@version P12
*/
Static Function CT100CALC( oFW, lDebt )
Local lRet := .T.

If lDebt
	lRet := ((  oFw:GetValue( 'CT9DETAIL', 'CT9_DC' )  == "1")  .OR. ( oFw:GetValue( 'CT9DETAIL', 'CT9_DC' )  == "3" ))
Else
	lRet := (( oFw:GetValue( 'CT9DETAIL', 'CT9_DC' )   == "2") .OR. ( oFw:GetValue( 'CT9DETAIL', 'CT9_DC' )  == "3" ))
EndIf
Return lRet
#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#INCLUDE "CTBA120.CH"

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static __cProcPrinc  	:= "CTBA120"

/*{Protheus.doc}CTBA120
Cadastro de Criterios de Rateio -> Compras / Financeiro 
@author Mayara Alves da silva
@since 12/06/2015
@version P12
@return aRotina - Vetor com as opções da Rotina do Vetor
@project Inovação Controladoria
*/
Function CTBA120()

Local oBrowse := BrowseDef()

Private aRotina := MenuDef()

//Analise da existencia dos campos das novas entidades  
Ctb120IniVar()

oBrowse:Activate()

Return

/*/{Protheus.doc} BrowseDef
	Definição do Browse
	@type  Function
	@author Alison Kaique
	@since Jan/2019
	@version P12

/*/
Static Function BrowseDef()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("CTJ")
oBrowse:SetDescription(OemToAnsi(STR0006)) //Rateio Externo

Return oBrowse

/*{Protheus.doc}MenuDef
Crição dos menus
@author Mayara Alves da silva
@since 12/06/2015
@version P12
@return aRotina - Vetor com as opções da Rotina do Vetor
@project Inovação Controladoria
*/
Static Function MenuDef()
Local aRotina := {}
Local lCTB120MDF := ExistBlock("CTB120MDF")

ADD OPTION aRotina Title OemToAnsi(STR0001)	Action 'VIEWDEF.CTBA120' OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0002)	Action 'VIEWDEF.CTBA120' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0003)	Action 'VIEWDEF.CTBA120' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0004)	Action 'VIEWDEF.CTBA120' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0005)	Action 'VIEWDEF.CTBA120' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title STR0025	Action 'CT120IMP'	OPERATION 3 ACCESS 0 //"Importar"
ADD OPTION aRotina TITLE STR0026	ACTION 'CT120LOG'OPERATION 6 ACCESS 0 //"Log Proc"

If lCTB120MDF
	aRotina := ExecBlock("CTB120MDF", .F., .F.,{aRotina})
EndIf

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCAB 	:= FWFormStruct( 1, 'CTJ', {|x|  Alltrim(x)+"|" $ "CTJ_RATEIO|CTJ_DESC|CTJ_MOEDLC|CTJ_TPSALD|CTJ_QTDTOT|"}) 
Local oStruCTJ 	:= FWFormStruct( 1, 'CTJ', {|x|  !Alltrim(x)+"|" $ "CTJ_RATEIO|CTJ_DESC|CTJ_MOEDLC|CTJ_TPSALD|CTJ_QTDTOT|"})
Local oModel		

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CTBA120',/*bPreValidacao*/, {|oModel| Ctb120TOk(oModel)}/*bPosValidacao*/, {|oModel| Ctb120Grava(oModel)}/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CTJMASTER', /*cOwner*/, oStruCAB )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CTJDETAIL', 'CTJMASTER', oStruCTJ, /*bLinePre*/, {|oModel| CTB120LOK(oModel)}/*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CTJDETAIL', { { 'CTJ_FILIAL', 'xFilial( "CTJ" )' },{ 'CTJ_RATEIO', 'CTJ_RATEIO' } }, CTJ->( IndexKey( 1 ) ) )
                                                                                                                           
//Campos totalizadores de debito
oModel:AddCalc( 'TOTCTJ', 'CTJMASTER', 'CTJDETAIL', 'CTJ_PERCEN', 'DEBPORC', 'SUM',{|oModel| CT120CALC(oModel,.T.)} ,,("% "+STR0011) ,,6,2) //"% Debito"
oModel:AddCalc( 'TOTCTJ', 'CTJMASTER', 'CTJDETAIL', 'CTJ_QTDDIS', 'DEBQTD', 'SUM',{|oModel| CT120CALC(oModel,.T.)} ,,STR0016 ) // "Qtd.Debito"

//Campos totalizadores de credito
oModel:AddCalc( 'TOTCTJ', 'CTJMASTER', 'CTJDETAIL', 'CTJ_PERCEN', 'CREPORC', 'SUM',{|oModel| CT120CALC(oModel,.F.)},,("% "+STR0012),,6,2) //"% Debito"
oModel:AddCalc( 'TOTCTJ', 'CTJMASTER', 'CTJDETAIL', 'CTJ_QTDDIS', 'CREQTD', 'SUM',{|oModel| CT120CALC(oModel,.F.)},,STR0017 ) // "Qtd.Debito"

oModel:SetPrimaryKey({'xFilial("CTJ")','CTJ_RATEIO','CTG_EXERC','CTJ_SEQUEN'})

//Linha duplicada
oModel:GetModel( 'CTJDETAIL' ):SetUniqueLine( { 'CTJ_SEQUEN' } )

//Validação de campo
oStruCTJ:SetProperty( 'CTJ_PERCEN' , MODEL_FIELD_VALID,{|| CT120PERCEN()	})
oStruCTJ:SetProperty( 'CTJ_QTDDIS' , MODEL_FIELD_VALID,{|oModel, cId, xValue, nLine, xCurrentValue| CT120QTVAL(oModel, cId, xValue, nLine, xCurrentValue)		})

oStruCAB:SetProperty( 'CTJ_MOEDLC' , MODEL_FIELD_VALID,{|| Ct120MoedLC()	})
oStruCAB:SetProperty( 'CTJ_RATEIO' , MODEL_FIELD_VALID,{|| Ctb120Rat()		})

//Gatilhos
oStruCTJ:AddTrigger('CTJ_PERCEN','CTJ_QTDDIS',/*bPre*/, { |oModel, cId, xValue, nLine, xCurrentValue | Ctb120Gat(oModel, cId, xValue, nLine, xCurrentValue) } )
oStruCTJ:AddTrigger('CTJ_QTDDIS','CTJ_PERCEN',/*bPre*/, { |oModel, cId, xValue, nLine, xCurrentValue | Ctb120Gat(oModel, cId, xValue, nLine, xCurrentValue) } )

//Modo de edição
oStruCAB:SetProperty( 'CTJ_RATEIO' , MODEL_FIELD_WHEN,{|| INCLUI})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 ) //"Criterios de Rateio"

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCAB := FWFormStruct( 2, 'CTJ',{|x| Alltrim(x)+"|" $ "CTJ_RATEIO|CTJ_DESC|CTJ_MOEDLC|CTJ_TPSALD|CTJ_QTDTOT|"})
Local oStruCTJ := FWFormStruct( 2, 'CTJ',{|x| !Alltrim(x)+"|" $ "CTJ_RATEIO|CTJ_DESC|CTJ_MOEDLC|CTJ_TPSALD|CTJ_QTDTOT|CTJ_EVENTO|CTJ_VALOR|"})

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'CTBA120' )

Local oView
Local oCalc

oStruCTJ:SetProperty( 'CTJ_SEQUEN' , MVC_VIEW_CANCHANGE,.F.)

oCalc := FWCalcStruct( oModel:GetModel('TOTCTJ') )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CAB', oStruCAB, 'CTJMASTER' )
oView:AddField( 'VIEW_CALC', oCalc	, 'TOTCTJ' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CTJ', oStruCTJ, 'CTJDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 25 )
oView:CreateHorizontalBox( 'MEIO'		, 60 )
oView:CreateHorizontalBox( 'INFERIOR'	, 15 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CTJ', 'MEIO' )
oView:SetOwnerView( 'VIEW_CALC', 'INFERIOR' )

oView:AddIncrementField('VIEW_CTJ','CTJ_SEQUEN')

oView:EnableTitleView( 'VIEW_CALC', OemToAnsi(STR0013) , RGB( 224, 30, 43 )  )// Totais Rateados

Return oView

/*{Protheus.doc}CT120PERCEN
Valida o percentual digitadO   
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Static Function CT120PERCEN()
Local lRet := .T.
Local oModel		:= FWModelActive()
Local oModelCTJ	:= oModel:GetModel('CTJDETAIL')
Local nPercen		:= oModelCTJ:GetValue("CTJ_PERCEN") 		//Processo
Local aSaveLine := FWSaveRows()

If nPercen > 100.00
	oModel:SetErrorMessage("","","","","CT120PERC",STR0018,STR0019)//"Percentual Inválido."##"Percentual Máximo 100.00%"
   	lRet := .F.
EndIf
	
If lRet .And. nPercen < 0.00
	oModel:SetErrorMessage("","","","","CT120PERCNEG",STR0018,STR0020)//"Percentual Inválido."##"Percentual deve ser positivo"
	lRet := .F.
EndIf

FWRestRows( aSaveLine )

Return lRet

/*{Protheus.doc}CT120QTVAL
Valida quantidade digitada   
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Function CT120QTVAL(oModGrid, cId, xValue, nLine, xCurrentValue)
Local lRet 		:= .T.  
Local oModel		:= oModGrid:GetModel()
Local oModelCAB	:= oModel:GetModel('CTJMASTER')
Local oModelCTJ	:= oModel:GetModel('CTJDETAIL')

If xValue > oModelCAB:GetValue("CTJ_QTDTOT")
	oModel:SetErrorMessage("","","","","CT120QTDDIS",STR0021,STR0022)//"Quantidade Inválida."##"Quantidade não deve ultrapassar o valor a distribuir"
	lRet := .F.
EndIf

If xValue < 0.00
	oModel:SetErrorMessage("","","","","CT120QTDDIS",STR0021,STR0023)//"Quantidade Inválida."##"Quantidade deve ser positiva"
	lRet := .F.
EndIf

Return lRet

/*{Protheus.doc}Ct120MoedLC
Valida moeda do lancamento   
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Function Ct120MoedLC()

Local aCtbMoeda	:= {}
Local lRet			:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB	:= oModel:GetModel('CTJMASTER')
Local cMoeda		:= FWFLDGET("CTJ_MOEDLC")

aCtbMoeda  	:= CtbMoeda(cMoeda)

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
   lRet := .F.
Endif

Return lRet


/*{Protheus.doc}CTB120LOK
Valida Linha da Getdados -> Linha OK    
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@param oModel - modelo
@project Inovação Controladoria
*/
Function CTB120LOK(oModel)
Local lRet		:= .T.
Local nPercen		:= oModel:GetValue("CTJ_PERCEN")
Local nLinha		:= 0
Local nLinPos		:= oModel:GetLine()
Local cChaveDeb	:= oModel:GetValue("CTJ_DEBITO") + oModel:GetValue("CTJ_CCD") + oModel:GetValue("CTJ_ITEMD") + oModel:GetValue("CTJ_CLVLDB")
Local cChaveCred	:= oModel:GetValue("CTJ_CREDIT") + oModel:GetValue("CTJ_CCC") + oModel:GetValue("CTJ_ITEMC") + oModel:GetValue("CTJ_CLVLCR")
Local cChvAuxDeb	:= ""
Local cChvAuxCrd	:= ""

If Empty(nPercen)
	Help(" ",1,"CTJVLZERO")
	lRet := .F.
EndIf

If _lCpoEnt05
	cChaveDeb  += oModel:GetValue("CTJ_EC05DB")
	cChaveCred += oModel:GetValue("CTJ_EC05CR")
EndIf

If _lCpoEnt06
	cChaveDeb  += oModel:GetValue("CTJ_EC06DB")
	cChaveCred += oModel:GetValue("CTJ_EC06CR")
EndIf

If _lCpoEnt07
	cChaveDeb  += oModel:GetValue("CTJ_EC07DB")
	cChaveCred += oModel:GetValue("CTJ_EC07CR")
EndIf

If _lCpoEnt08
	cChaveDeb  += oModel:GetValue("CTJ_EC08DB")
	cChaveCred += oModel:GetValue("CTJ_EC08CR")
EndIf

If _lCpoEnt09
	cChaveDeb  += oModel:GetValue("CTJ_EC09DB")
	cChaveCred += oModel:GetValue("CTJ_EC09CR")
EndIf

//--------------------------------------------------------------
// Não permite duplicar a chave da entidade a credito ou debito
//--------------------------------------------------------------
For nLinha := 1 To oModel:Length()

	oModel:GoLine(nLinha)

	//Ignora a linha editada na comparacao
	If nLinha != nLinPos .And. !oModel:IsDeleted()

		cChvAuxDeb	:= oModel:GetValue("CTJ_DEBITO") + oModel:GetValue("CTJ_CCD") + oModel:GetValue("CTJ_ITEMD") + oModel:GetValue("CTJ_CLVLDB")
		cChvAuxCrd	:= oModel:GetValue("CTJ_CREDIT") + oModel:GetValue("CTJ_CCC") + oModel:GetValue("CTJ_ITEMC") + oModel:GetValue("CTJ_CLVLCR")

		If _lCpoEnt05
			cChvAuxDeb += oModel:GetValue("CTJ_EC05DB")
			cChvAuxCrd += oModel:GetValue("CTJ_EC05CR")
		EndIf
		
		If _lCpoEnt06
			cChvAuxDeb += oModel:GetValue("CTJ_EC06DB")
			cChvAuxCrd += oModel:GetValue("CTJ_EC06CR")
		EndIf
		
		If _lCpoEnt07
			cChvAuxDeb += oModel:GetValue("CTJ_EC07DB")
			cChvAuxCrd += oModel:GetValue("CTJ_EC07CR")
		EndIf
		
		If _lCpoEnt08
			cChvAuxDeb += oModel:GetValue("CTJ_EC08DB")
			cChvAuxCrd += oModel:GetValue("CTJ_EC08CR")
		EndIf
		
		If _lCpoEnt09
			cChvAuxDeb += oModel:GetValue("CTJ_EC09DB")
			cChvAuxCrd += oModel:GetValue("CTJ_EC09CR")
		EndIf

		//Avalia chave duplicada de debito e credito
		If cChaveDeb + cChaveCred == cChvAuxDeb + cChvAuxCrd
			lRet := .F.
			Help('',1,'CT120VDENT',,STR0024,1,0)	//"Contas invalidas"
			Exit
		EndIf  

	EndIf

Next nLinha

oModel:GoLine(nLinPos) //Restaura a linha posicionada

Return lRet


/*{Protheus.doc}Ctb120TOk
Valida Getdados -> TUDO OK     
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@param oModel - modelo
@project Inovação Controladoria
*/
Function Ctb120TOk(oModel)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local nQtdTot		:= oModel:GetValue("CTJMASTER","CTJ_QTDTOT") 
Local nQtdDeb		:= oModel:GetValue("TOTCTJ","DEBQTD")
Local nQtdCrd		:= oModel:GetValue("TOTCTJ","CREQTD")
Local nTotalD		:= oModel:GetValue("TOTCTJ","DEBPORC")
Local nTotalC		:= oModel:GetValue("TOTCTJ","CREPORC")

nTotalD	:= Round(nTotalD,2)
nTotalC	:= Round(nTotalC,2)

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If  nQtdTot > 0 //se quantidade for informada validar somente a quantidade
		If nQtdDeb > 0 .And. Abs(nQtdDeb-nQtdTot) > 0.01
			Help(" ",1,"CTJQTD")
			lRet	:= .F.
		Else
			If nQtdCrd > 0 .And. Abs(nQtdCrd-nQtdTot) > 0.01
				Help(" ",1,"CTJQTD")
				lRet	:= .F.
			Endif		 
		EndIf	
	EndIf

	IF lRet .AND. (( nTotalD > 0 .And. nTotalD != 100 ) .Or. ( nTotalC > 0 .And. nTotalC != 100 ))
		Help(" ",1,"CTJ100%")
		lRet := .F.
	EndIF
EndIf

RestArea(aSaveArea)

Return lRet

/*{Protheus.doc}Ctb120Rat
Verifica existencia do Rateio     
@author Mayara Alves da silva
@since 15/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Static Function Ctb120Rat()

Local aSaveArea:= GetArea()
Local aAreaCTJ:= CTJ->(GetArea())
Local lRet		:= .T.
Local oModel		:= FWModelActive() 
Local oModelCAB	:= oModel:GetModel('CTJMASTER')
Local cRateio		:= AllTrim(oModelCab:GetValue("CTJ_RATEIO"))

lRet := FreeForUse("CTJ",cRateio) 

If lRet .And. Empty(cRateio) 
	lRet := .F.
ElseIf lRet 
	dbSelectArea("CTJ")
	dbSetOrder(1)

	If CTJ->(dbSeek(xFilial("CTJ")+cRateio))
		oModel:SetErrorMessage("","","","","CTJNRATEIO","","")//"Quantidade Inválida."##"Quantidade deve ser positiva"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaCTJ)
RestArea(aSaveArea)
Return lRet

/*{Protheus.doc}CT120CALC
Verifica se o campo debito ou credito está preenchido para somar no totalizador    
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@param oModel - modelo
@param lDeb - Campo Debito se Verdadeiro ou Crédito, caso contrário Falso
@project Inovação Controladoria
*/
Static Function CT120CALC(oModel,lDeb)
Local lRet := .F.
Local oModelCTJ	:= oModel:GetModel('CTJDETAIL')
Local cConta := ""

If lDeb
	Do Case
		//DEBITO
	Case !Empty(oModelCTJ:GetValue("CTJ_DEBITO"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_CCD"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_ITEMD"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_CLVLDB"))
		lRet:= .T.
	Case _lCpoEnt05 .And. !Empty(oModelCTJ:GetValue("CTJ_EC05DB"))  //Entidade 05
		lRet:= .T.
	Case _lCpoEnt06 .And. !Empty(oModelCTJ:GetValue("CTJ_EC06DB"))  //Entidade 06
		lRet:= .T.
	Case _lCpoEnt07 .And. !Empty(oModelCTJ:GetValue("CTJ_EC07DB"))  //Entidade 07
		lRet:= .T.
	Case _lCpoEnt08 .And. !Empty(oModelCTJ:GetValue("CTJ_EC08DB"))  //Entidade 08
		lRet:= .T.
	Case _lCpoEnt09 .And. !Empty(oModelCTJ:GetValue("CTJ_EC09DB"))  //Entidade 09
		lRet:= .T.
	Endcase
Else
	Do Case
		//CREDITO
	Case !Empty(oModelCTJ:GetValue("CTJ_CREDIT"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_CCC"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_ITEMC"))
		lRet:= .T.
	Case !Empty(oModelCTJ:GetValue("CTJ_CLVLCR"))
		lRet:= .T.
	Case _lCpoEnt05 .And. !Empty(oModelCTJ:GetValue("CTJ_EC05CR")) //Entidade 05
		lRet:= .T.
	Case _lCpoEnt06 .And. !Empty(oModelCTJ:GetValue("CTJ_EC06CR")) //Entidade 06
		lRet:= .T.
	Case _lCpoEnt07 .And. !Empty(oModelCTJ:GetValue("CTJ_EC07CR")) //Entidade 07
		lRet:= .T.
	Case _lCpoEnt08 .And. !Empty(oModelCTJ:GetValue("CTJ_EC08CR")) //Entidade 08
		lRet:= .T.
	Case _lCpoEnt09 .And. !Empty(oModelCTJ:GetValue("CTJ_EC09CR")) //Entidade 09
		lRet:= .T.
	Endcase
EndiF

Return lRet


/*{Protheus.doc}Ctb120Inc
Rotina de via consulta SXB para inclusao de rateio externo   
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@param cAlias - Alias do arquivo 
@param nReg - Numero do Registro 
@project Inovação Controladoria
*/
Function Ctb120Inc(cAlias,nReg)

SaveInter()

FWExecView (OemToAnsi(STR0006), "CTBA120", MODEL_OPERATION_INSERT, /*oDlg*/, { || .T. } )

RestInter()

Return .T.


/*{Protheus.doc}Ctb120Vis
Rotina de via consulta SXB para visualizacao rateio externo
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@param cAlias - Alias do arquivo 
@param nReg - Numero do Registro 
@project Inovação Controladoria
*/
Function Ctb120Vis(cAlias,nReg)

FWExecView (OemToAnsi(STR0006), "CTBA120", MODEL_OPERATION_VIEW, /*oDlg*/, { || .T. } )

Return .T.

/*{Protheus.doc}Ctb120Form
Verifica se a formula digitada esta OK 
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Function Ctb120Form()

Local cEntidade := Alltrim(ReadVar())
Local lRet      := .T.

Do Case
	Case cEntidade == "M->CTJ_CCC" .Or. cEntidade == "M->CTJ_CCD"
		lRet := ValidaCusto(&(cEntidade))
	Case cEntidade == "M->CTJ_ITEMD" .OR. cEntidade == "M->CTJ_ITEMC"
		lRet := ValidItem(&(cEntidade))
	Case cEntidade =="M->CTJ_CLVLDB" .OR. cEntidade == "M->CTJ_CLVLCR"
		lRet := ValidaCLVL(&(cEntidade))
	Case _lCpoEnt05 .And. (cEntidade =="M->CTJ_EC05DB" .OR. cEntidade == "M->CTJ_EC05CR") //Entidade 05
		lRet := CTB105EntC(,&(cEntidade),,"05")
	Case _lCpoEnt06 .And. (cEntidade =="M->CTJ_EC06DB" .OR. cEntidade == "M->CTJ_EC06CR") //Entidade 06
		lRet := CTB105EntC(,&(cEntidade),,"06")
	Case _lCpoEnt07 .And. (cEntidade =="M->CTJ_EC07DB" .OR. cEntidade == "M->CTJ_EC07CR") //Entidade 07
		lRet := CTB105EntC(,&(cEntidade),,"07")
	Case _lCpoEnt08 .And. (cEntidade =="M->CTJ_EC08DB" .OR. cEntidade == "M->CTJ_EC08CR") //Entidade 08
		lRet := CTB105EntC(,&(cEntidade),,"08")
	Case _lCpoEnt09 .And. (cEntidade =="M->CTJ_EC09DB" .OR. cEntidade == "M->CTJ_EC09CR") //Entidade 09
		lRet := CTB105EntC(,&(cEntidade),,"09")
EndCase

Return lRet

/*{Protheus.doc}Ctb120IniVar
Analise da existencia dos campos das novas entidades 
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
*/
Function Ctb120IniVar()

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CTJ->(FieldPos("CTJ_EC05CR")>0 .And. FieldPos("CTJ_EC05DB")>0)
EndIf

If _lCpoEnt06 == Nil
	_lCpoEnt06 := CTJ->(FieldPos("CTJ_EC06CR")>0 .And. FieldPos("CTJ_EC06DB")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CTJ->(FieldPos("CTJ_EC07CR")>0 .And. FieldPos("CTJ_EC07DB")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CTJ->(FieldPos("CTJ_EC08CR")>0 .And. FieldPos("CTJ_EC08DB")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CTJ->(FieldPos("CTJ_EC09CR")>0 .And. FieldPos("CTJ_EC09DB")>0)
EndIf

Return

/*{Protheus.doc}Ctb120Grava
Grava registros
@author Mayara Alves da silva
@since 16/06/2015
@version P12
@return lRet - Retorno logico
@project Inovação Controladoria
@param	oModel Modelo de Dados que será utilizado para gravação dos dados do Rateio
*/
Static Function Ctb120Grava(oModel)
Local cSeq		:= STRZERO(0,TamSX3('CTJ_SEQUEN')[1])
Local oStruCAB	:= oModel:GetModel("CTJMASTER")
Local cRateio 	:= oStruCAB:GetValue("CTJ_RATEIO")
Local cDesc		:= oStruCAB:GetValue("CTJ_DESC")
Local cMoedLC	:= oStruCAB:GetValue("CTJ_MOEDLC")
Local cTpSald	:= oStruCAB:GetValue("CTJ_TPSALD")
Local nQtdTot	:= oStruCAB:GetValue("CTJ_QTDTOT")

FWFormCommit( oModel )

dbSelectArea("CTJ")
CTJ->(dbSetOrder(1)) //CTJ_FILIAL+CTJ_RATEIO+CTJ_SEQUEN                                                                                                                                

If CTJ->(dbSeek(xFilial("CTJ") + cRateio ) )

	While CTJ->(!Eof()) .And. CTJ->(CTJ_FILIAL + CTJ_RATEIO) == xFilial("CTJ") + cRateio

		cSeq := Soma1(cSeq)

		RecLock("CTJ",.F.)
		CTJ->CTJ_SEQUEN		:= cSeq
		CTJ->CTJ_DESC		:= cDesc
		CTJ->CTJ_MOEDLC		:= cMoedLC
		CTJ->CTJ_TPSALD		:= cTpSald
		CTJ->CTJ_QTDTOT		:= nQtdTot
		CTJ->(MsUnlock())

	CTJ->(DbSkip())
	EndDo

EndIf

Return .T.

/*{Protheus.doc}CT120IMP
Importa o arquivo de rateio
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT120IMP()
Local aHeader		:= {}	//Array com o cabecalho do arquivo CSV
Local aCols		:= {}	//Array com os intens do arquivo CSV	
Local lVld			:= .F.
Local lRegrava	:= .F.
Local nRegrava	:= 0
Local nX		:= 0
Local nPosCodR	:= ""
Local cCodFil 	:= ""
Local aQtdRat	:= {}
Local aColsExp	:= {}
Local nZ		:= 0
Local nTotArr	:= 0
Local lErro		:= .F.

//Le o arquivo de importação, e realiza as validações no arquvio
lVld := CTBArqRat(@aHeader,@aCols,@nRegrava) 

lRegrava		:= IIf(nRegrava == 1,.T.,.F.)

//Recebe posição código do Rateio
cCodFil		:= ASCAN(@aHeader, "CTJ_FILIAL" )
nPosCodR	:= ASCAN(@aHeader, "CTJ_RATEIO" )


//Verifica se trata do mesmo código de rateio para todas as linhas, caso contrario não deixa seguir
For nX := 1 To Len(@aCols)
	
	//Armazena quantidade do Array
	nTotArr := Len(aQtdRat)

	//Verifica se aQtRat já foi preenchida
	If nTotArr== 0
		Aadd(aQtdRat, {@aCols[nX][cCodFil],@aCols[nX][nPosCodR]})	
	ElseIf aScan(aQtdRat[nTotArr],@aCols[nX][cCodFil] ) == 0 .Or. aScan(aQtdRat[nTotArr], @aCols[nX][nPosCodR] ) == 0
		Aadd(aQtdRat, {@aCols[nX][cCodFil],@aCols[nX][nPosCodR]})	
	EndIf	

Next nX

For nX := 1 To Len(aQtdRat)	
	If Len(aQtdRat) > 1

		For nZ := 1 To Len(@aCols)

			If aQtdRat[nX][cCodFil] == @aCols[nZ][cCodFil] .And. aQtdRat[nX][nPosCodR] == @aCols[nZ][nPosCodR] 
				aAdd(aColsExp, @aCols[nZ])
			EndiF	

		Next nZ
		
		//Gravação da importação
		If lVld 
			lErro := C120GRVRAT(@aHeader,@aColsExp,lRegrava)
		EndIf
		
		aColsExp := {}

	else
		
		//Gravação da importação
		If lVld 
			lErro := C120GRVRAT(@aHeader,@aCols,lRegrava)
		EndIf

	EndIf
Next nX

	//Se teve algum erro, mostra o log de erros.
	If lErro
		ProcLogView(,__cProcPrinc)
	Endif

Return

/*{Protheus.doc}CT120LOG
Mostra log da rotina de importação
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT120LOG()

ProcLogView(,__cProcPrinc)

Return


/*{Protheus.doc}C120GRVRAT
Grava importação
@author Mayara Alves da silva
@since 10/07/2015
@param aHeader	- Cabeçalho do arquivo de importação
@param aCols		- Itens do arquivo de importação
@param nRegrava	- Sobresqueve arquivo sim ou não
@version P12
@project Inovação Controladoria
*/
Static Function C120GRVRAT(aHeader,aCols,lRegrava)
Local nX			:= 0
Local nDadArq		:= 0
Local nHeaArq		:= 0
Local nPosEv		:= ASCAN(aHeader, "CTJ_EVENTO" ) 
Local cEventAnt	:= ""
Local cAlias		:= GetNextAlias()
Local aCampo		:= {}
Local aInd			:= {}
Local oModel		:= FWLoadModel('CTBA120') 
Local oModelCAB	
Local oModelCTJ	
//Local cSeq			:= STRZERO(0,TamSX3('CTJ_SEQUEN')[1])
Local aErro		:= {}
Local lExiCpoEve	:= nPosEv > 0
Local nPosCodR	:= ASCAN(aHeader, "CTJ_RATEIO" )
Local nPosSeq		:= ASCAN(aHeader, "CTJ_SEQUEN" )
Local cMensIni	:= STR0027 //"Importação do arquivo: "
Local cLogErro	:= ""
Local lErro		:= .F.
Local lGrvCab		:= .T.
Local cCodRat		:= ""
Local cSeq		:= ""
Local nTamCodR	:= TamSX3('CTJ_SEQUEN')[1]

oModel:SetOperation(MODEL_OPERATION_INSERT)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão

oModel:Activate()

oModelCAB	:= oModel:GetModel('CTJMASTER')
oModelCTJ	:= oModel:GetModel('CTJDETAIL')

For nX := 1 To Len(aCols)
	If lExiCpoEve .And. !Empty(aCols[nX][nPosEv])

		cEventAnt := aCols[nX][nPosEv]

		lErro := C120GRVEV(aCols[nX][nPosEv],aHeader,aCols,oModel, @nX,lRegrava)

		Loop
	Else
		cCodRat	:= aCols[nX][nPosCodR]
		
		//Se for sobrescrever arquivo, deleta o arquivo para posterior inclusao	
		If lRegrava
			CTBA120Del(cCodRat)
		EndIf
		
		For nDadArq := nX To Len(aCols)
		
			cCodRat:= aCols[nDadArq][nPosCodR]
			
			If EMPTY(aCols[nDadArq][nPosSeq])
				cSeq	 := STRZERO(0,TamSX3('CTJ_SEQUEN')[1])
			Else
				cSeq	 := PADL(aCols[nDadArq][nPosSeq],nTamCodR,"0")
			EndIf			
		
			//Validação para gravar cabeçalho 
			If nDadArq > 1 .And. AllTrim(cCodRat) == AllTrim(aCols[nDadArq-1][nPosCodR])
				lGrvCab := .F.
		
				nLinha := oModelCTJ:AddLine()
			
				oModelCTJ:goline(nLinha)
			EndIf
		
			For nHeaArq := 1 To Len(aHeader)
				
				If "PERCEN" $ aHeader[nHeaArq] .Or. "QTDDIS" $ aHeader[nHeaArq] .Or. ("VALOR" $ aHeader[nHeaArq])
					oModelCTJ:SetValue(aHeader[nHeaArq],Val(StrTran(aCols[nDadArq,nHeaArq],",",".")))
				ElseIf lGrvCab .And. "CTJ_RATEIO" $ aHeader[nHeaArq]
					oModelCAB:SetValue("CTJ_RATEIO",AllTrim(cCodRat))
				ElseIf lGrvCab .And. "CTJ_DESC"$ aHeader[nHeaArq]
					oModelCAB:SetValue("CTJ_DESC",aCols[nDadArq,nHeaArq])
				ElseIf lGrvCab .And. "CTJ_MOEDLC"$ aHeader[nHeaArq]
					oModelCAB:SetValue("CTJ_MOEDLC",aCols[nDadArq,nHeaArq])
				ElseIf lGrvCab .And. "CTJ_TPSALD"$ aHeader[nHeaArq]
					oModelCAB:SetValue("CTJ_TPSALD",aCols[nDadArq,nHeaArq])
				ElseIf lGrvCab .And. "CTJ_QTDTOT"$ aHeader[nHeaArq]	
					oModelCAB:SetValue("CTJ_QTDTOT",Val(StrTran(aCols[nX,nHeaArq],",",".")))
				ElseIf "CTJ_RATEIO" $ aHeader[nHeaArq] .Or. "CTJ_DESC"$ aHeader[nHeaArq].Or. "CTJ_MOEDLC"$ aHeader[nHeaArq];
						.Or. "CTJ_TPSALD"$ aHeader[nHeaArq] .Or. "CTJ_QTDTOT"$ aHeader[nHeaArq]
					Loop
				ElseIf !lGrvCab .AND. "CTJ_SEQUEN" $ aHeader[nHeaArq] .AND. !EMPTY(aCols[nDadArq,nHeaArq])
					oModelCTJ:SetValue(aHeader[nHeaArq],cSeq)
				Else
					oModelCTJ:SetValue(aHeader[nHeaArq],aCols[nDadArq,nHeaArq])
				EndIf
			Next nHeaArq
			
			If EMPTY(aCols[nX][nPosSeq])
				cSeq	:= Soma1(cSeq)
			EndIf
				
			oModelCTJ:SetValue("CTJ_SEQUEN",cSeq)
		
		Next nDadArq
		
		nX := nDadArq
		
		If oModel:VldData()
		
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

			cLogErro:= aErro[4] + " - " + aErro[6]
			ProcLogAtu(STR0028,cMensIni,cLogErro,,.T. ) //"ERRO"
			
			lErro := .T.
			
		EndIf
		
		nX := nDadArq -1 
		
	EndIf
Next nX


ProcLogAtu(STR0029,cMensIni,,,.T.) //"FIM"

Return (lErro)

/*{Protheus.doc}C120GRVEV
grava arquivo de importação com evento
@author Mayara Alves da silva
@since 10/07/2015
@version P12
@project Inovação Controladoria
*/
Static function C120GRVEV(cEvento,aHeader, aCols,oModel,nX,lRegrava)
Local aArea		:= GetArea()
Local aAreaCQK 	:= CQK->(GetArea())
Local oTabTemp	
Local nPosEv		:= ASCAN(aHeader, "CTJ_EVENTO" ) 
Local nPosMoe		:= ASCAN(aHeader, "CTJ_MOEDLC" )
Local nPotp		:= ASCAN(aHeader, "CTJ_TPSALD" )
Local nPoQT		:= ASCAN(aHeader, "CTJ_QTDTOT" )
Local cSeq		:= ""
Local oModelCAB	:= oModel:GetModel('CTJMASTER')
Local oModelCTJ	:= oModel:GetModel('CTJDETAIL')
Local nLinha		:= 0
Local aErro		:= {}
Local lRet		:= .F. //Retorna se teve erro na gravação
Local cMensIni	:= STR0027 //"Importação do arquivo: "
Local nQTDDIS		:= 0
Local nHeaArq		:= 0
Local nDadArq		:= 0

DbSelectArea("CQK")
CQK->(DbSetOrder(1)) //CQK_FILIAL+CQK_CODEVE+CQK_ITEM

If CQK->(dbSeek(xFilial("CQK")+cEvento))

	While CQK->(!EOF()) .And. Alltrim(CQK->CQK_CODEVE) == cEVENTO

		cSeq:= "001"
		
		//Se definido para sobrescrever, deleta o arquivo para posterior inclusao
		If lRegrava
			CTBA120Del(CQK->CQK_CODRAT)
		EndIf

		//Grava cabeçalho
		oModelCAB:SetValue("CTJ_RATEIO",CQK->CQK_CODRAT)
		oModelCAB:SetValue("CTJ_DESC",CQK->CQK_DESC)
			
		//CARREGA DADOS DA PRIMEIRA LINAH NO CABEÇALHO
		If nPoQT > 0
			oModelCAB:SetValue("CTJ_QTDTOT",Val(StrTran(aCols[nX,nPoQT],",",".")))
		EndIf
		If nPosMoe > 0
			oModelCAB:SetValue("CTJ_MOEDLC",aCols[nX,nPosMoe])
		EndIf
		If nPotp > 0
			oModelCAB:SetValue("CTJ_TPSALD",aCols[nX,nPotp])
		EndIf
		
		//--------------------------------------
		// Inclusao da partida originada da CQK
		//--------------------------------------
		oModelCTJ:SetValue("CTJ_PERCEN",100)		
		oModelCTJ:SetValue("CTJ_SEQUEN",cSeq)
		
		//oModelCTJ:SetValue("CTJ_QTDDIS",100)
		If CQK->CQK_ENTBAS == "2"
			oModelCTJ:SetValue("CTJ_CREDIT",CQK->CQK_CREDIT)
			oModelCTJ:SetValue("CTJ_CCC",CQK->CQK_CCC)
			oModelCTJ:SetValue("CTJ_ITEMC",CQK->CQK_ITEMC)
			oModelCTJ:SetValue("CTJ_CLVLCR",CQK->CQK_CLVLCR)
		Else //Debito
			oModelCTJ:SetValue("CTJ_DEBITO",CQK->CQK_DEBITO)
			oModelCTJ:SetValue("CTJ_CCD",CQK->CQK_CCD)
			oModelCTJ:SetValue("CTJ_ITEMD",CQK->CQK_ITEMD)
			oModelCTJ:SetValue("CTJ_CLVLDB",CQK->CQK_CLVLDB)
		EndIf

	//----------------------------------------------
	// Inclusao da partida destino do arquivo + cqk
	//----------------------------------------------
		For nDadArq := nX To Len(aCols)
			
			If cEvento == aCols[nDadArq][nPosEv]
				
				nLinha := oModelCTJ:AddLine()
				
				oModelCTJ:goline(nLinha)
				
				For nHeaArq := 1 To Len(aHeader)
				
					If ("PERCEN" $ aHeader[nHeaArq]) .Or. ("QTDDIS" $ aHeader[nHeaArq]) .Or. ("VALOR" $ aHeader[nHeaArq])
						oModelCTJ:SetValue(aHeader[nHeaArq],Val(StrTran(aCols[nDadArq,nHeaArq],",",".")))
					ElseIf "CTJ_RATEIO" $ aHeader[nHeaArq] .Or. "CTJ_DESC"$ aHeader[nHeaArq].Or. "CTJ_MOEDLC"$ aHeader[nHeaArq];
					.Or. "CTJ_QTDTOT"$ aHeader[nHeaArq] .Or. "CTJ_TPSALD"$ aHeader[nHeaArq]
						Loop
					Else 
						oModelCTJ:SetValue(aHeader[nHeaArq],aCols[nDadArq,nHeaArq])

					EndIf

				Next nHeaArq
				
				If CQK->CQK_ENTBAS == '2'
					oModelCTJ:SetValue("CTJ_DEBITO",CQK->CQK_DEBITO)
				Else
					oModelCTJ:SetValue("CTJ_CREDIT",CQK->CQK_CREDITO)
				EndIf
				
				cSeq	:= Soma1(cSeq)
				
				oModelCTJ:SetValue("CTJ_SEQUEN",cSeq)
				
				
			Else
				Exit
			EndIf
		Next nDadArq
		
		If oModel:VldData()
		
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

			cLogErro:= aErro[4] + " - " + aErro[6]
			ProcLogAtu(STR0028,cMensIni,cLogErro,,.T. ) //"ERRO"
			
			lRet:= .T.
		EndIf

		CQK->(DBSKIP())
	ENDDO
	

	nX := nDadArq - 1 
Else

	cLogErro:= STR0030 + "CTJ_EVENTO" + "." //"Arquivo com valor inválido. Coluna: " 
	ProcLogAtu(STR0028,cMensIni,cLogErro,,.T. ) //"ERRO"
	lRet:= .T.

EndIf 

RestArea(aAreaCQK)
RestArea(aArea)

Return lRet

/*{Protheus.doc}CTBA120Del
Deleta o rateio para o processo de sobrescrita de importação
@since 29/07/2015
@param cCodRat - Codigo do rateio para exclusao
@version P12
*/
Static Function CTBA120Del(cCodRat)
Local aArea		:= GetArea()
Local aAreaCTJ	:= CTJ->(GetArea())

//Posiciona no rateio
DbSelectArea("CTJ")
CTJ->(DbSetOrder(1))
If CTJ->(DbSeek(FwXFilial("CTJ")+cCodRat))
	While CTJ->(!Eof()) .And. AllTrim(FwXFilial("CTJ")+cCodRat) == AllTrim(CTJ->CTJ_FILIAL+CTJ->CTJ_RATEIO) 
		RecLock("CTJ")
		CTJ->(DbDelete())
		CTJ->(MsUnLock())
		CTJ->(DBSKIP())
	EndDo
EndIf

RestArea(aAreaCTJ)
RestArea(aArea)

Return

/*{Protheus.doc} Ctb120Gat

Calcula os valores de quantidade e percentual para o rateio para o item digitado.
   
@author	Marylly Araújo Silva
@since	04/12/2015
@version	P12.1.07
@return	nRet - Retorno numerico
@project Inovação Controladoria - Sistêmico 12.1.07
@param	oModGrid Modelo de Dados do campo que está chamando o gatilho
@param	cIdCpo	ID do campo que disparou o gatilho
@param	xValue	Valor digitado no campo que disparou o gatilho
@param	nLine	Linha do Grid que o campo disparou o gatilho
@param	xCurrentValue Valor do campo quando da digitação do valor que disparou o gatilho
*/
Function Ctb120Gat(oModGrid, cIdCpo, xValue, nLine, xCurrentValue)

Local aSaveArea	:= GetArea()
Local nRet		:= 0
Local oModel		:= oModGrid:GetModel()
Local oModFld		:= oModel:GetModel("CTJMASTER")
Local nPerc		:= 0
Local nQuant		:= 0
Local aTamQtd		:= TAMSX3("CTJ_QTDTOT")
Local nDecQtd		:= aTamQtd[2]

If !FWIsInCallStack("FINA050")
	nQtdTot := oModFld:GetValue("CTJ_QTDTOT")
	/*
	 * Calculando a quantidade distribuida
	 */
	If AllTrim(cIdCpo) == "CTJ_PERCEN"
		nPerc	:= xValue
		nQuant	:= 0
		nRet		:= (nPerc*nQtdTot) / 100
		nRet		:= Round(nRet, 2)
	/*
	 * Calculando o percentual distribuído
	 */
	ElseIf AllTrim(cIdCpo) == "CTJ_QTDDIS"
		nQuant	:= xValue
		nRet		:= (nQuant/nQtdTot) * 100
		If FwIsInCallStack("CTBA120")
			nRet := Round(nRet, nDecQtd + 3)		
		EndIf
	EndIf	
EndIf

RestArea(aSaveArea)

Return(nRet)


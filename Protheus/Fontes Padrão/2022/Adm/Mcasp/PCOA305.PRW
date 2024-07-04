#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA305.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA305
Cadastro de Despesa e Receita metas aunias
@author TOTVS
@since 22/10/2020 
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA305()
Local oBrowser 
Local aRotina := {}

dbSelectArea("A25")
dbSetOrder(1)

aRotina := MenuDef()

oBrowser := FWmBrowse():New()


oBrowser:SetAlias( 'A25' )

oBrowser:SetDescription(STR0001) //"Cdastro de Despesa e Receita Metas anuais"

oBrowser:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA305' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA305' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA305' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA305' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA305' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.PCOA305' OPERATION 9 ACCESS 0 //'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCAB := FWFormStruct( 1, 'A25', {|x|  Alltrim(x)+"|" $ "A25_CATEGO|A25_CTGECO|A25_DESCCE|A25_ANO|"})
Local oStruA25 := FWFormStruct( 1, 'A25', {|x| !Alltrim(x)+"|" $ "A25_CATEGO|A25_CTGECO|A25_DESCCE|A25_ANO|"})
Local oModel

oStruCAB:AddTrigger("A25_CTGECO","A25_DESCCE",{|| .T. },{|| P305GATILHO("A25_CTGECO")})
oStruA25:AddTrigger("A25_ORIGP","A25_DESCRI",{|| .T. },{|| P305GATILHO("A25_ORIGP")})


oModel := MPFormModel():New( 'PCOA305',/*bPreValidacao*/, {|oModel| P305VDLPOS(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'A25MASTER', /*cOwner*/, oStruCAB )
oModel:AddGrid( 'A25DETAIL', 'A25MASTER', oStruA25, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'A25DETAIL', { { 'A25_FILIAL', 'xFilial( "A25" )' },{ 'A25_CATEGO', 'A25_CATEGO' },{'A25_ANO','A25_ANO'},{'A25_CTGECO','A25_CTGECO'}}, A25->( IndexKey( 1 ) ) )
                                                                                                                           
oModel:SetPrimaryKey({'xFilial("A25")','A25_CATEGO','A25_ANO','A25_CTGECO'})

//Linha duplicada
oModel:GetModel( 'A25DETAIL' ):SetUniqueLine( { 'A25_ORIGP' } )

oModel:SetDescription( STR0001 )  //"Cdastro de Despesa e Receita Metas anuais"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCAB := FWFormStruct( 2, 'A25', {|x|  Alltrim(x)+"|" $ "A25_CATEGO|A25_CTGECO|A25_DESCCE|A25_ANO|"})
Local oStruA25 := FWFormStruct( 2, 'A25', {|x|  !Alltrim(x)+"|" $ "A25_CATEGO|A25_CTGECO|A25_DESCCE|A25_ANO|"})
Local oModel   := FWLoadModel( 'PCOA305' )
Local oView
oView := FWFormView():New()

oView:SetModel(oModel)


//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CAB',		oStruCAB	, 'A25MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_A25', oStruA25, 'A25DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 30 )
oView:CreateHorizontalBox( 'MEIO'		, 70 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_A25'	, 'MEIO' )

Return oView

Function PCO305XB()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""

// Não realizar a consulta se o campo A25_CATEGO
If AllTrim(M->A25_CATEGO) <> ""
	If M->A25_CATEGO == '2' .And. cVar == 'M->A25_CTGECO'  //Categoria Economica Receita
		cCodTab := "'CE'"
		cRadical := "'CE'"  
		aTabRecDes := Pco305Tbl(cCodTab, cRadical) //Origem da receita
	ElseIf M->A25_CATEGO == '2' .And. cVar == 'M->A25_ORIGP'
		cCodTab := "'O1','O2'"
		cRadical := "'R','C'"
		aTabRecDes := Pco305Tbl(cCodTab, cRadical)
	ElseIf M->A25_CATEGO == '1' .And. cVar == 'M->A25_CTGECO' //Categoria Economica despesa 
		cCodTab := "'DE'"
		cRadical := "'DE'"
		aTabRecDes := Pco305Tbl(cCodTab, cRadical) //gruoo de despesa
	ElseIf M->A25_CATEGO == '1' .And. cVar == 'M->A25_ORIGP'
		cCodTab := "'GD'"
		cRadical := "'GD'"
		aTabRecDes := Pco305Tbl(cCodTab, cRadical)
	Else
		aAdd( aTabRecDes, { "NO_APLY", STR0008}) //"Nao se Aplica"
	EndIf

	Define MsDialog oDlgCons Title STR0009 From 000, 000 To 450, 800 PIXEL //"Consulta de Tabelas Rec.Desp."

		Define Font oFont Name 'Courier New' Size 0, -12		
		oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0010, STR0011 },,;    //"Codigo"##"Descrição"
									oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

		oGetCons:SetArray(aTabRecDes)
		oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } } 	                            
		oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

		@208,310 BUTTON STR0012 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
		@208,360 BUTTON STR0013 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

	Activate MsDialog oDlgCons Centered

	If nOpcA == 1 
		&cVar := aTabRecDes[nAt,1]
		&cVar += Space(nTam-Len(&cVar))
		A1H->( dbGoto(aTabRecDes[nAt,3]) )
	Else
		//recupera o que estava anteriormente
		&cVar := cCpoAnt
		lRet := .F.
	EndIf

Else

	HELP(' ',1,"NCATEG" ,,STR0015,1,0) // Categoria não informada, preencha o campo Categoria

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Pco305Tbl
Retorna um array com codigo/descricao da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Pco305Tbl(cCodTab, cRadical)
Local aArea := GetArea()
Local cQuery := ""
Local aRetorno := {}
Local cAliasTmp := CriaTrab(,.F.)

cQuery += " SELECT A1H_ITECHV, A1H_CHVCNT, R_E_C_N_O_ RECTAB "
cQuery += " FROM " + RetSqlName("A1H")
cQuery += " WHERE "
cQuery +=  "      A1H_FILIAL = '"+xFilial("A1H")+"' " 
cQuery += "   AND A1H_CODTAB IN ("+cCodTab+") " 
cQuery += "   AND A1H_RADCHV IN  ("+cRadical+") " 
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY A1H_ITECHV "

cQuery := ChangeQuery( cQuery )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
While (cAliasTmp)->( ! Eof() )
	aAdd( aRetorno, { (cAliasTmp)->A1H_ITECHV, (cAliasTmp)->A1H_CHVCNT, (cAliasTmp)->RECTAB } )
	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->( DBCloseArea() )

RestArea(aArea)

Return(aRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} P305VDLPOS
Validação pata ter apena uma categoria economica de despera ou receita por ano

@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P305VDLPOS(oModel)
Local lRet := .T.
Local oMdlCab 	:= oModel:GetModel("A25MASTER")
// Local oMdlA25	:= oModel:GetModel( 'A25DETAIL' )
Local cCategori	:= oMdlCAB:getValue("A25_CATEGO")
Local cCateEco	:= oMdlCAB:getValue("A25_CTGECO")
Local cAno	:= oMdlCAB:getValue("A25_ANO") 
// Local cOrigp	:= oMdlA25:getValue("A25_ORIGP")
Local aArea		:= GetArea()
Local aAreaA25	:= A25->(GetArea())
Local nOper		:= oModel:GetOperation()

//Validar chave dulicada apenas na inclusão
If nOper == MODEL_OPERATION_INSERT


	dbSelectArea("A25")
	A25->(dbSetOrder(1)) //A25_FILIAL+A25_CATEGO+A25_ANO+A25_CTGECO+A25_ORIGP                                                                                                              

	If A25->(dbSeek(xFilial("A25")+cCategori+cAno+cCateEco))
		lRet := .F.
		HELP(' ',1,"METAJACADASTRADA" ,,STR0014,1,0)
	EndIf 

EndIf

RestArea(aAreaA25)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} P305GATILHO
Gatilho para os capos de descrição

@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P305GATILHO(cCampo)
Local cRet := ""
Local oModel    := FWModelActive()
Local oMdlCAB   := oModel:GetModel( 'A25MASTER' )
Local oMdlA25	:= oModel:GetModel( 'A25DETAIL' )
Local cCodTab 	:= ""
Local cRadchv 	:= ""
Local cItechv 	:= ""
Local cClass	:= oMdlCAB:getValue("A25_CATEGO")
Local cCateEco	:= alltrim(oMdlCAB:getValue("A25_CTGECO"))


Default cCampo := ""

If cCampo ==  "A25_CTGECO"
	If cClass == '1'
		cCodTab 	:= "DE"
		cRadchv 	:= PADR("DE",Tamsx3("A1H_RADCHV")[1])
	ElseIf cClass == '2'
		cCodTab 	:= "CE"
		cRadchv 	:= PADR("CE",Tamsx3("A1H_RADCHV")[1])
	EndIf
	cItechv 	:= oMdlCAB:getValue("A25_CTGECO")
	cRet := ALLTRIM(POSICIONE("A1H",2,XFILIAL("A1H")+cCodTab+cRadchv+cItechv,"A1H_CHVCNT"))  
ElseIf cCampo == "A25_ORIGP"
	If cClass == '1'
		cCodTab 	:= "GD"
		cRadchv 	:= PADR("GD",Tamsx3("A1H_RADCHV")[1])
	ElseIf cClass == '2'
		If cCateEco == "1"
			cCodTab 	:= "O1"
			cRadchv 	:= PADR("R",Tamsx3("A1H_RADCHV")[1])
		ElseIf cCateEco == "2"
			cCodTab 	:= "O2"
			cRadchv 	:= PADR("C",Tamsx3("A1H_RADCHV")[1])
		EndIF
	EndIf
	cItechv 	:= oMdlA25:getValue("A25_ORIGP")
	cRet := ALLTRIM(POSICIONE("A1H",2,XFILIAL("A1H")+cCodTab+cRadchv+cItechv,"A1H_CHVCNT"))  
EndIf

Return cRet
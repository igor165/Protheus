#INCLUDE "OGA540.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} OGA540()

Chamada para rotina Modelos de Email

@param	   ExpU1 = Variavel que recebera um array contendo os dados, somente por ExecAuto
		   ExpN1 = Variavel que recebera a operação que ira realizar o model, somente por ExecAuto
		   ExpL1 = Variavel que indica se é uma chamada automatica

@return   Nenhum

@author   Daniel Maniglia A. Silva
@since    21/0/2014
@version  12.0
/*/
//----------------------------------------------------------
Function OGA540(cAlias,nOper,uRotAuto, nOpcAuto)

Local oMBrowse        := Nil
Local oDlgOwner       := Nil

Local oTableAtt       := TableAttDef()

Private aRotina  	  := MenuDef()
Private nOGA230MOp    := 0   // Operação que o Model está executando
Private oOGA230EHT    := Nil //Variavel guardará o objeto do editor html
Private lMsErroAuto	  := .F.
Private oCombo		  := Nil 

If .Not. TableInDic('N7L')
	MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
	Return()
Endif	

If uRotAuto == Nil .AND. nOpcAuto == Nil
	If FunName() == "OGA540"

		oMBrowse := FWMBrowse():New()

		oMBrowse:SetAlias("N7L")
		oMBrowse:SetDescription(STR0001)//"Modelo de Email"

		oMBrowse:SetAttach( .T. )
		oMBrowse:SetViewsDefault( oTableAtt:aViews )

		oMBrowse:DisableDetails()

		oMBrowse:SetTotalDefault('N7L_FILIAL','COUNT',STR0019) // "Total de Registro"

		oMBrowse:Activate()

	ElseIf nOper > 0
		Do Case
			Case nOper == 3
				OGA540INC(cAlias)
			Case nOper == 4
				OGA540ALT()
		EndCase
	EndIf
Else
	FWMVCRotAuto(ModelDef(),"N7L",nOpcAuto,{{"N7LMASTER",uRotAuto}},/*lSeek*/,.T.)
  	If lMsErroAuto
  		MostraErro()
  		lMsErroAuto := .F. //Setando valor padrão para variavel
  	Endif
EndIf

Return


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Especificações Ativas
Local oInativos	:= Nil // Especificações Inativas
Local oTableAtt 	:= FWTableAtt():New()

oTableAtt:SetAlias("N7L")

// Modelos de E-mail Ativos
oAtivos := FWDSView():New()
oAtivos:SetName(STR0017) // "Modelos de E-mail Ativos"
oAtivos:SetOrder(1) 
oAtivos:SetCollumns({"N7L_CODIGO","N7L_PROCES","N7L_TITULO","N7L_ASSUNT"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0017, "N7L_STATUS == '2'") // "Modelos de E-mail Ativos"

oTableAtt:AddView(oAtivos)
oAtivos:SetID("Ativos")

// Modelos de E-mail Inativos
oInativos := FWDSView():New()
oInativos:SetName(STR0018) // "Modelos de E-mail Inativos"
oInativos:SetOrder(1) 
oInativos:SetCollumns({"N7L_CODIGO","N7L_PROCES","N7L_TITULO","N7L_ASSUNT"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0018, "N7L_STATUS == '1'") // "Modelos de E-mail Inativos"

oTableAtt:AddView(oInativos)
oInativos:SetID("Inativos")

Return (oTableAtt)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados da atividade

@param	  Nenhum

@return  oModel - objeto contendo o modelo de dados

@author   Daniel Maniglia A. Silva
@since    10/08/2017
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructN7L  := FWFormStruct(1,"N7L")

oModel := MPFormModel():New("OGA540",/*bPosValidacao*/,/*bPreValidacao*/, { |oModel| ModelCommit(oModel) },/*bCancel*/)
oModel:SetDescription(STR0001)//"Modelo de Email"

oStructN7L:SetProperty( "N7L_PROCES" , MODEL_FIELD_VALID,  {|oModelN7L, cCampo, xNewValue, xOldValue|OGA540VLPR(oModelN7L, cCampo, xNewValue, xOldValue) }) 

oModel:AddFields("N7LMASTER",/*cOwner*/,oStructN7L,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"N7L_FILIAL" ,"N7L_CODIGO"})

oModel:GetModel("N7LMASTER"):SetDescription(STR0001)//"Modelo de Email"

return (oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

ViewDef - Visão do model de modelos de email

@param	  Nenhum

@return  oView - objeto contendo a visão criada

@author   Daniel Maniglia A. Silva
@since    10/08/2017
@version  12.0
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	      	:= FWFormView():New()

Local oModel	      := FwLoadModel("OGA540")
Local cCpoN7L       := "N7L_CODIGO|N7L_PROCES|N7L_DESCPR|N7L_TITULO|N7L_DESCRI|N7L_ASSUNT|N7L_STATUS|N7L_MENSAG|"
Local bAvCpoEMA     := {|cCampo| AllTrim(cCampo)+"|" $ cCpoN7L}

Local oModel 		:= ModelDef()
Local oStructN7L    := FWFormStruct(2,"N7L", {|x| ALLTRIM(x) $ "N7L_CODIGO|N7L_PROCES|N7L_DESCPR|N7L_TITULO|N7L_DESCRI|N7L_ASSUNT|N7L_STATUS|N7L_PWORKF|N7L_DPWORF"})

oView:AddUserButton( 'Formulário Workflow', 'LinkWorkFlow', {|oView| OGA540LK(oView) } )

oView:AddField("VIEW_MODEMA_GRID", oStructN7L, "N7LMASTER" )///,,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)


ASORT(oView:AUSERBUTTONS,,,{ | x,y | y[1] > x[1] } )
//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model
oView:SetDescription(STR0001) //"Modelo De Email"

//--------------------------------------
//		Montagem dos Objetos da Tela
//--------------------------------------
oView:AddOtherObject("VIEW_HTML" , {|oPanel,oModel| OGA540Html(oPanel,oModel)})//Adiciona um objeto externo ao View do MVC
oView:AddOtherObject("VIEW_OUTROS" , {|oPanel| MntOutros(oPanel)},{|oPanel| oPanel:FreeChildren()})//Adiciona um objeto externo ao View do MVC

//--------------------------------------
//		Montagem da tela Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 32 )// Primeira Linha da Tela
oView:CreateHorizontalBox( "LINETWO", 68 )// Segunda  Linha da Tela

oView:CreateVerticalBox( "LINETWO_COLLONE", 70, "LINETWO")// Primeira Coluna dentro da Segunda Linha da Tela
oView:CreateVerticalBox( "LINETWO_COLLTWO", 30, "LINETWO")// Segunda Coluna dentro da Segunda Linha da Tela



oView:SetOwnerView( "VIEW_MODEMA_GRID","LINEONE"  )
oView:SetOwnerView( "VIEW_HTML","LINETWO_COLLONE" )
oView:SetOwnerView( "VIEW_OUTROS","LINETWO_COLLTWO" )

oView:SetAfterViewActivate({|oView| OGA540POSM(oView)})

Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis para a tela de atividades

@param		Nenhum

@return	aRotina - array contendo as opções disponiveis

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

   ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGA540"   OPERATION 2 ACCESS 0 //"Visualizar"
   ADD OPTION aRotina TITLE STR0004   ACTION "OGA540INC()"      OPERATION 3 ACCESS 0 //"Incluir"
   ADD OPTION aRotina TITLE STR0005   ACTION "OGA540ALT()"      OPERATION 4 ACCESS 0 //"Alterar"
   ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGA540"   OPERATION 5 ACCESS 0 //"Excluir"


Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AGA540bcam()

Retorna array com as tabelas do processo do template

@param Tabela

@return	aStatus - array contendo as tabelas do processo do template

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function AGA540bcam()

Local aCampoComb := {}

AAdd( aCampoComb,"Filial",{"DXP_filial"} )
AAdd( aCampoComb,"Nome do Cliente",{"DXP_CODCLI"})
AAdd( aCampoComb,"Número do Contrato",{"DXP_CODCON"} )

Return(aCampoComb)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntOutros()

Rotina para montar em uma janela determinada o Editor de Html

@param	  	ExpO1 = Objeto da janela onde será criado o Markbrowse

@return   	Nil

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function MntOutros( oPanel )

Local  nX         := 0

Local cCapital    := ""
Local cTGet 	  := Space(100)
Local cTGetCol	  := Space(100)
Local cComboSTA   := ""

Local lMark       := .F.

Local aEntConex   := {}
Local aCampos     := {}
//Local aStatus     := AGA540Ntab()
Local aStatus 	  := {}

Local oView 	    := FWViewActive()
Local oBrwMark    := Nil
Local oTGet       := Nil
Local oTGetCol	  := Nil
Local oColEnt     := Nil
Local oLINEONE    := Nil
Local oCOLLMARK   := Nil
Local oFwLayer    := Nil
Local oLayerInte  := Nil
Local oLayerMark  := Nil
Local oLINEONE    := Nil
Local oLINETWO    := Nil
Local oLINETHE    := Nil


oFwLayer   := FwLayer():New()// Layer do ComboBox
oLayerInte := FwLayer():New()// Layer onde acontece a divisão em 3 partes, para adicionar os tres componentes.
oLayerMark := FwLayer():New()// Layer do FwBrose

oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .F. ,"LINHA" )
oFWLayer:addWindow( "COL1", "WIN1", STR0011, 100, .F., .F.,,"LINHA")//"Filtros"

oCOLLONE := oFwLayer:getColPanel("COL1","LINHA")
oLayerInte:init(oCOLLONE,.F.)

oLayerInte:AddLine("LINEONE" ,20,.F.)
oLayerInte:AddLine("LINETWO" ,65,.F.)
oLayerInte:AddLine("LINETHE" ,5, .F.)
oLayerInte:AddLine("LINECOL" ,10, .F.)

oLINEONE := oLayerInte:GetLinePanel("LINEONE")
oLINETWO := oLayerInte:GetLinePanel("LINETWO")
oLINETHE := oLayerInte:GetLinePanel("LINETHE")
oLINECOL := oLayerInte:GetLinePanel("LINECOL")

oLayerMark:init(oLINETWO,.F.)
oLayerMark:addCollumn( "COL2",100, .F. ,"LINHA2" )
oCOLLMARK := oLayerMark:getColPanel("COL2","LINHA2")
oLayerMark:addWindow( "COL2", "WIN2", STR0012, 100, .F., .F.,,"LINHA2")//"Mascara"

oPanel    := oFWLayer:GetWinPanel("COL1","WIN1","LINHA")
oCOLLMARK := oLayerMark:GetWinPanel("COL2","WIN2","LINHA2")

@ 019, 06 SAY oTitulo2 PROMPT STR0013 SIZE 120,009  OF oLINEONE PIXEL //"Funcionalidade (tabela):"
@ 028,06 MSCOMBOBOX oCombo VAR cComboSTA ITEMS aStatus  SIZE 085, 009 OF oLINEONE ON CHANGE OGA540Mark(aCampos,oBrwMark,cComboSTA) PIXEL


DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oCOLLMARK
		ADD MARKCOLUMN oColEnt DATA {|| IIF(aCampos[oBrwMark:At()][1],"LBOK","LBNO") } DOUBLECLICK {|| OGA540Marc(@aCampos,oBrwMark,oTGet,@cTGet,cComboSTA, @cTGetCol)} OF oBrwMark
		ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][3] }") TITLE STR0014 TYPE "C" SIZE 30 DOUBLECLICK {|| OGA540Marc(@aCampos,oBrwMark,oTGet,@cTGet,cComboSTA, @cTGetCol)} OF oBrwMark//"Masks"
		oBrwMark:DisableReport()
		oBrwMark:bGotFocus := {|tGrid| tGrid:GoColumn(1)}
ACTIVATE FWBROWSE oBrwMark

@ 000, 10 SAY oTsCamp PROMPT STR0027 SIZE 60,009  OF oLINETHE PIXEL // # Campo
@ 000, 10 SAY oTsCol PROMPT STR0028 SIZE 60,009  OF oLINECOL PIXEL // # Coluna

oTGet 		:= TGet():New( 00,30,{||cTGet},oLINETHE,0100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet,,,, )
oTGetCol 	:= TGet():New( 00,30,{||cTGetCol},oLINECOL,0100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGetCol,,,, )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} OGA540INC()

Rotina para chamar a tela de inclusão de Modelos de email

@param		ExpC1 = Alias da entidade que deverá começar pre carregada na inclusão..quando existir a necessidade.

@return	Nenhum

@author    Daniel Maniglia A. Silva
@since		27/02/2014
@version	1
/*/
//------------------------------------------------------------------------------
Function OGA540INC(cAlias)

Local oView       := Nil
Local oModel      := Nil
Local aSize	    := FWGetDialogSize( oMainWnd )
Local bCloseOnOk  := {|| }
Local lCadastro   := .F.

Default cAlias    := ""

oModel := FWLoadModel("OGA540")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
If !Empty(cAlias)
	oModel:GetModel("N7LMASTER"):SetValue("N7L_PROCES",cAlias)
EndIf
oModel:lModify := .T.
nOGA230MOp := MODEL_OPERATION_INSERT // Setando a operação do model

oView := FWLoadView("OGA540")

oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT)
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)

oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0004)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()

Validação dos Dados , após dar o Commit no model.. verifica qual a operação
que estava sendo realizada , para poder enviar os dados para o exchange

@param	  ExpO1 = oModel .. objeto do modelo de dados corrente.

@return  .T.

@author   Daniel Maniglia A. Silva
@since    25/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Local nOperation   := oModel:GetModel("N7LMASTER"):GetOperation()
Local cBody := ""

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	If Type("oOGA230EHT") == "O"
		cBody := oOGA230EHT:GetText()
	ElseIf !Empty(oModel:GetModel("N7LMASTER"):GetValue("N7L_MENSAG")) 	
		cBody := oModel:GetModel("N7LMASTER"):GetValue("N7L_MENSAG")
	EndIf
	oModel:GetModel("N7LMASTER"):SetValue("N7L_MENSAG",cBody)
EndIf

FWFormCommit(oModel)//Salvando o formulario.


Return (.T.)

//----------------------------------------------------------
/*/{Protheus.doc} OGA540Mark()

Rotina para carregar os dados conforme a escolha do usuario Campo/Complemento

@param	  ExpA1 = Array contendo os dados dos registros que o Browse carrega na tela
		  ExpO1 = Objeto Browse que deverá ser manipulado
		  ExpC1 = Opção escolhida pelo usuario para ser carregado 1=Campo/2=Complemento

@return  Nenhum

@author  Daniel Maniglia A. Silva
@since   26/03/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function OGA540Mark(aCampos,oBrwMark,cOpcao)

	Local aAreaSX3   := {}
	Local lMark      := .F.
	Local aTabelas 	 := {}
	Local nInt 		 := 1 
	Local nX		 := 0 
	Local aMatixTab	 := AGA540btab()
	Local aCpSX3Tab	:= {} //armazena os campo da tabela no SX3
	Local aCpSX3Str	:= {} //armazena a estrutura do campo da sx3

	Default cOpcao   := ""
	Default oBrwMark := Nil


	Asize( aCampos, 0)
	For nInt := 1 to len(aMatixTab) //inclui no aTabelas as tabelas escolhidas na tela 
		If cOpcao == 'TODAS'
			AADD (aTabelas, aMatixTab[nInt,1] ) //pega a tabela que está na primeira posição
		Else 
			If AScan(aMatixTab[nInt],cOpcao) > 0    //Se for a opção escolhida
				AADD (aTabelas, aMatixTab[nInt,1] ) //pega a tabela que está na primeira posição 
			EndIf
		EndIf 	 
	next 
	
	For nInt := 1 to len(aTabelas) 

		aCpSX3Tab  := {}
		aCpSX3Tab := FWSX3Util():GetAllFields( aTabelas[nInt] , .F. ) //retorna todos campos sx3, exceto os virtual(.F.)
		
		For nX := 1 To Len(aCpSX3Tab)
			aCpSX3Str := {}
			aCpSX3Str := FWSX3Util():GetFieldStruct( aCpSX3Tab[nX] )
			If GetSX3Cache(aCpSX3Str[1], "X3_CONTEXT") <> "V"
				AAdd( aCampos,{lMark, aCpSX3Str[1], AGRDESCRI(aCpSX3Str[1])} )
			EndIf
		Next nX

	Next 
	
	If ValType(oBrwMark) == "O"
		oBrwMark:SetArray(aCampos)
		oBrwMark:Refresh(.T.)
	EndIf

	If !Empty(aAreaSX3)
		RestArea(aAreaSX3)
	EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} OGAGraTag()

Rotina para gerar o codigo de mesclagem do campo/Complemento para ser inserido no email

@param	  ExpO1 = objeto do Browse que será manipulado
		  ExpA1 = Array contendo os dados dos registros que o Browse utiliza
		  ExpO2 = Objeto do campo Get que será manipulado
		  ExpC1 = Variavel onde será atribuido o Codigo Gerado
		  ExpC2 = Opção escolhida pelo usuario 1=Campo/2=Complemento

@return  Nenhum

@author   Daniel Maniglia A. Silva
@since    26/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function OGAGraTag(oBrwMark,aCampos,oTGet,cTGet,cOpcao, cTGetCol)

Default cOpcao   := ""
Default aCampos  := {}
Default oTGet    := Nil
Default oBrwMark := Nil

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos)
	If aCampos[oBrwMark:At()][1] == .T.
		cTGet 		:= "$!"+AllTrim(aCampos[oBrwMark:At()][2])+"$!"
		cTGetCol 	:= "##"+AllTrim(aCampos[oBrwMark:At()][2])+"##"
	Else
		cTGet 		:= ""
		cTGetCol	:= ""
	EndIf
	If ValType(oTGet) == "O"
		oTGet:CtrlRefresh()
	EndIf
EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} OGA540Marc()

Rotina para Marcar no browse o registro escolhido e chamar a rotina de mesclagem do
campo/Complemento para ser inserido no email

@param	   ExpA1 = Array contendo os dados dos registros que o Browse utiliza
		   ExpO1 = objeto do Browse que será manipulado
           ExpO2 = Objeto do campo Get que será manipulado
		   ExpC1 = Variavel onde será atribuido o Codigo Gerado
		   ExpC2 = Opção escolhida pelo usuario 1=Campo/2=Complemento

@return   Nenhum

@author   Daniel Maniglia A. Silva
@since    26/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function OGA540Marc(aCampos,oBrwMark,oTGet,cTGet,cComboSTA, cTGetCol) 

Local nPosAnt    := 0
Local nPos       := 0
Local oView		 := FwViewActive()

Local aDados     := {}

Default aCampos  := {}
Default oBrwMark := Nil

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos)

   aDados  := Aclone(aCampos)
   nPosAnt := Ascan(aDados,{|x|  x[1] == .T.})
   nPos	   := oBrwMark:At()

   If nPosAnt > 0 .AND. nPosAnt <> nPos
   		aCampos[nPosAnt][1] := !aCampos[nPosAnt][1]
   EndIf

   aCampos[nPos][1] := !aCampos[nPos][1]
   OGAGraTag(oBrwMark,aCampos,oTGet,@cTGet,cComboSTA, @cTGetCol)

   oBrwMark:SetArray(aCampos)
   oBrwMark:GoColumn(1)
   oBrwMark:Refresh()
   
   If ValType(oView) != "U"
   		oView:Refresh("VIEW_OUTROS")
   EndIf
   
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} OGA540ALT()

Rotina para chamar a tela de alteração do modelo de email

@param		Nenhum

@return	Nenhum

@author	Daniel Maniglia A. Silva
@since		03/04/2014
@version	1
/*/
//------------------------------------------------------------------------------
Function OGA540ALT()

Local oView      := Nil
Local oModel     := Nil
Local aSize	   := FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local bCloseOnOk := {|| }

nOGA230MOp := MODEL_OPERATION_UPDATE // Setando a o tipo de operação do model

oModel := FWLoadModel("OGA540")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModel:lModify := .T.

oView := FWLoadView("OGA540")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_UPDATE)

oFWMVCWin := FWMVCWindow():New()

oFWMVCWin:SetUseControlBar(.T.)
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0005)//"Alterar"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} OGA540Html()

Rotina para montar em uma janela determinada o Editor de Html

@param	  	ExpO1 = Objeto da janela onde será criado o Editor de Html
			ExpO2 = Objeto do Modelo de dados 

@return   	Nenhum

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function OGA540Html( oPanel, oModel )

Local   oFwLayer    := Nil

Default oPanel := Nil
Default oModel := Nil

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", STR0007, 100, .F., .F., , "LINHA2")//Calendário//"Calendário"//"Editor de Email"

oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2")

oOGA230EHT := FWSimpEdit():New( 0, 0, 500,600, STR0008,,,.F.,.F. , oPanel)//"Editor HTML"

If oModel <> Nil .AND. oModel:GetModel("N7LMASTER"):GetOperation() <> MODEL_OPERATION_INSERT // Verificando a operação do model para carregar o conteudo do Html
	oOGA230EHT:SetText(CRMA170CRG(N7L->N7L_MENSAG, .F.))//Carregando o email no objeto
EndIf

Return


/*/{Protheus.doc} OGA540POSM() 

Atualizar Combobox de tabelas 

@param	  Nenhum

@return  .T.

@author   Daniel Maniglia A. Silva
@since    10/08/2017
@version  1.0
/*/
//----------------------------------------------------------

Static Function OGA540POSM(oView)

	oCombo:SetItems(AGA540Ntab(oView:GetModel():GetModel("N7LMASTER")))

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} OGA540VLPR() 

Valide do campo de processo

@param	  Nenhum

@return  .T. ou .F. 

@author   Daniel Maniglia A. Silva
@since    10/08/2017
@version  1.0
/*/
//----------------------------------------------------------
Function OGA540VLPR(oModelN7L, cCampo, xNewValue, xOldValue)

	oCombo:SetItems(AGA540Ntab(oModelN7L))

return .T. 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AGA540btab()

Retorna array com as tabelas do processo do template

@param		Nenhum
@return	aStatus - array contendo as tabelas do processo do template

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function AGA540btab()

Local aStatus 	:= {}
Local cNome		:= " "
Local aArea		:= GetArea()
Local oView		:= FwViewActive()
Local oModelN7L	:= Nil
	
	If ValType(oView) != "U"
		oModelN7L := oView:GetModel():GetModel("N7LMASTER")
	EndIf

    //AAdd( aStatus,'TODAS') 
	DbSelectArea("N7Z")//busca as tabelas do processo 
	N7Z->(DbSetOrder(1)) 

	If N7Z->(DbSeek(xFilial("N7Z") + AllTrim(oModelN7L:GetValue("N7L_PROCES"))))
		Do While N7Z->(!EOF()) .AND. AllTrim(N7Z->N7Z_PROCES) == AllTrim(oModelN7L:GetValue("N7L_PROCES"))
			cNome := AGA540Nomc()
			AAdd( aStatus,{N7Z->N7Z_TABELA,cNome} )
			N7Z->(DbSkip())
		EndDo
	EndIf
	
RestArea(aArea)

Return(aStatus)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AGA540Ntab()

Retorna array com os NOMES das tabelas do processo do template

@param		Nenhum
@return	aStatus - array contendo as tabelas do processo do template

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function AGA540Ntab(oModelN7L)

Local 	aStatus 	:= {}
Local 	cNome		:= ""
Local	aArea		:= GetArea()

	    AAdd( aStatus,'TODAS') 
		DbSelectArea("N7Z")//busca as tabelas do processo 
		N7Z->(DbSetOrder(1)) 
	
		//If N7Z->(DbSeek(xFilial("N7Z") + AllTrim(oModelN7L:GetValue("N7L_PROCES"))))
		If N7Z->(DbSeek(xFilial("N7Z") + AllTrim(oModelN7L:GetValue("N7L_PROCES"))))
			Do While N7Z->(!EOF()) .AND. AllTrim(N7Z->N7Z_PROCES) == AllTrim(oModelN7L:GetValue("N7L_PROCES"))
				cNome := AGA540Nomc()
				AAdd( aStatus,cNome )
				N7Z->(DbSkip())
			EndDo
		EndIf
	//EndIf  	
RestArea(aArea)

Return(aStatus)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AGA540Nomc()

Retorna array com as tabelas do processo do template

@param Tabela

@return	Nome da tabela da SX2

@author	Daniel Maniglia A. Silva
@since		10/08/2017
@version	1
/*/
//------------------------------------------------------------------------------
Static Function AGA540Nomc()

	Local cTabela   := " "
	Local cNome 	:= " "
	
	DBSelectArea( "SX2" )
	DBSetOrder( 1 )
	If DBSeek( N7Z->N7Z_TABELA )
		cNome := AllTrim( X2Nome() )
	EndIf

Return cNome

/*{Protheus.doc} OGA540LK
Função para copiar e gerar link do formulário de workflow
@author rafael.voltz
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static function OGA540LK(oView)

	Local nRet as numeric
	Local cBarras 	:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cBarrasIn := If(!isSRVunix(),"\","/") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cWfDir 	:= SuperGetMv("MV_WFDIRWF", .F., cBarras + "workflow") 
	
    If !(cBarras $ cWfDir) // Validação de auxilio, caso receber um caminho no servidor no qual o caminho possa ser diferente devido ao sistema operacional.
		cWfDir :=  StrTran(cWfDir, cBarrasIn, cBarras)
	EndIf
	
	If Empty(FWFLDGET("N7L_PWORKF"))
		MsgInfo(STR0029, STR0030) //Para utilizar essa opção é necessário informar o processo de Workflow.
		Return
	EndIf	
	
	cFile := cGetFile('Arquivo HTML|*.html',STR0031,0,'C:\Dir\',.F.,GETF_LOCALHARD,.F.) //Selecione o arquivo
	
	//se nao informou arquivo ou clicou no cancelar.
	If Empty(cFile)
		Return
	EndIf 

	nSmartSO := GetRemoteType()
	If nSmartSO == 2 	//LINUX
		aPath		:= Str2Arr(cFile,"/")
	Else
		aPath	 	:= Str2Arr(cFile,"\")
	EndIf
	
	If (!ExistDir(cWfDir))
	 	nRet := MakeDir( cWfDir )
	 	if nRet != 0
	 		Alert(STR0032) //Não foi possível criar o diretório workflow.
	 		Return
	 	EndIf
	EndIf
	
	If (!ExistDir(cWfDir + cBarras + "templates"))
	 	nRet := MakeDir( cWfDir + cBarras + "templates" )
	 	if nRet != 0
	 		Alert(STR0033) //Não foi possível criar o diretório templates.
	 		Return
	 	EndIf
	EndIf
	
	If (File( cWfDir + cBarras + "templates" + cBarras + aTail( aPath ), 0 , .T.))
		If !MSGYESNO( STR0034, STR0030 ) //
			Return
		EndIf
	EndIf	
	
	nRet := CpyT2S( cFile, cWfDir + cBarras + "templates", .F., .T. )
	
	IF FERROR() <> 0
 		MsgAlert(STR0035+STR(FERROR())) //"Não foi possível copiar o arquivo. Erro: "
 		Return
 	EndIf
	
	cTexto := oOGA230EHT:GetText()		
	cTexto := Alltrim(cTexto) + "$!LINKFORM #!TITULO!# "+aTail( aPath )+ "$!"
	
	oOGA230EHT:SetText(cTexto)
	cMsg := STR0036 + CRLF + CRLF //Formulário copiado com sucesso. Foi gerado link no corpo do template. Por favor, substitua apenas a palavra TITULO pela a descrição que deverá aparecer no link de resposta.
	cMsg += STR0037 +CRLF //Exemplo de texto no template: 
	cMsg += "<i>'"+STR0038+"  $!LINKFORM$! |#AQUI#| formulario.html '</i>" //Para responder clique
	
	MsgInfo(cMsg,STR0030)
	
Return

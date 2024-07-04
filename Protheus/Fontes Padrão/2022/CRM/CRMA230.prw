#include "CRMA230.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"


//----------------------------------------------------------
/*/{Protheus.doc} CRMA230()

Chamada para rotina Modelos de Email

@param	   ExpU1 = Variavel que recebera um array contendo os dados, somente por ExecAuto
		   ExpN1 = Variavel que recebera a operação que ira realizar o model, somente por ExecAuto
		   ExpL1 = Variavel que indica se é uma chamada automatica

@return   Nenhum

@author   Victor Bitencourt
@since    21/0/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMA230(cAlias,nOper,uRotAuto, nOpcAuto)

Local oMBrowse        := Nil
Local oDlgOwner       := Nil

Local oTableAtt       := TableAttDef()

Private aRotina  	  := MenuDef()
Private nCRM230MOp    := 0   // Operação que o Model está executando
Private oCRM230EHT    := Nil //Variavel guardará o objeto do editor html
Private lMsErroAuto	  := .F.


If uRotAuto == Nil .AND. nOpcAuto == Nil
	If FunName() == "CRMA230"

		oMBrowse := FWMBrowse():New()

		oMBrowse:SetAlias("AO6")
		oMBrowse:SetDescription(STR0002)//"Modelo de Email"

		oMBrowse:SetAttach( .T. )
		oMBrowse:SetViewsDefault( oTableAtt:aViews )

		oMBrowse:DisableDetails()

		oMBrowse:SetTotalDefault('AO6_FILIAL','COUNT',STR0026) // "Total de Registro"

		oMBrowse:Activate()

	ElseIf nOper > 0
		Do Case
			Case nOper == 3
				CRMA230INC(cAlias)
			Case nOper == 4
				CRMA230ALT()
		EndCase
	EndIf
Else
	FWMVCRotAuto(ModelDef(),"AO6",nOpcAuto,{{"AO6MASTER",uRotAuto}},/*lSeek*/,.T.)
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

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Especificações Ativas
Local oInativos	:= Nil // Especificações Inativas
Local oTableAtt 	:= FWTableAtt():New()

oTableAtt:SetAlias("AO6")

// Modelos de E-mail Ativos
oAtivos := FWDSView():New()
oAtivos:SetName(STR0024) // "Modelos de E-mail Ativos"
oAtivos:SetOrder(1) // AO6_FILIAL+AO6_CODMOD
oAtivos:SetCollumns({"AO6_CODMOD","AO6_ENTMOD","AO6_TITULO","AO6_ASSUNT"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0024, "AO6_MSBLQL == '2'") // "Modelos de E-mail Ativos"

oTableAtt:AddView(oAtivos)
oAtivos:SetID("Ativos")

// Modelos de E-mail Inativos
oInativos := FWDSView():New()
oInativos:SetName(STR0025) // "Modelos de E-mail Inativos"
oInativos:SetOrder(1) // AO6_FILIAL+AO6_CODMOD
oInativos:SetCollumns({"AO6_CODMOD","AO6_ENTMOD","AO6_TITULO","AO6_ASSUNT"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0025, "AO6_MSBLQL == '1'") // "Modelos de E-mail Inativos"

oTableAtt:AddView(oInativos)
oInativos:SetID("Inativos")

Return (oTableAtt)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados da atividade

@param	  Nenhum

@return  oModel - objeto contendo o modelo de dados

@author   Victor Bitencourt
@since    24/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructAOF  := FWFormStruct(1,"AO6")

oModel := MPFormModel():New("CRMA230",/*bPosValidacao*/,/*bPreValidacao*/, { |oModel| ModelCommit(oModel) },/*bCancel*/)
oModel:SetDescription(STR0003)//"Modelo de Email"

oModel:AddFields("AO6MASTER",/*cOwner*/,oStructAOF,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"AO6_FILIAL" ,"AO6_CODMOD"})

oModel:GetModel("AO6MASTER"):SetDescription(STR0004)//"Modelo de Email"

return (oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

ViewDef - Visão do model de modelos de email

@param	  Nenhum

@return  oView - objeto contendo a visão criada

@author   Victor Bitencourt
@since    24/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	      := FWFormView():New()
Local oModel	      := FwLoadModel("CRMA230")
Local cCpoAO6       := "AO6_CODMOD|AO6_CODMOD|AO6_ASSUNT|AO6_ENTMOD|AO6_TITULO|AO6_DESCRI|AO6_ANEXO|AO6_MSBLQL|"
Local bAvCpoEMA     := {|cCampo| AllTrim(cCampo)+"|" $ cCpoAO6}

Local oStructAO6    :=  FWFormStruct(2,"AO6",bAvCpoEMA)


If Type("nCRM230MOp") == "N"
   If nCRM230MOp <> MODEL_OPERATION_INSERT // Operação que o Model está executando
 		oStructAO6:SetProperty("AO6_ANEXO" , MVC_VIEW_CANCHANGE, .F. )
   EndIf
EndIf

oView:AddUserButton(STR0005,"",{ || MsDocument("AO6",AO6->(RecNo()),3),CRMA180VRA("AO6",AO6->AO6_CODMOD,(xFilial("AO6")+AO6->AO6_CODMOD)) } ,,,{MODEL_OPERATION_UPDATE}  )//"Anexar"
oView:AddUserButton(STR0030,"",{ || CRMA170StR() } ,,,{MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT}  )//"Diretório de Imagem"
oView:AddUserButton(STR0028,"",{ || Processa( { || AlteraMapHTML() },STR0027,STR0029) } ,,,{MODEL_OPERATION_UPDATE}  )//"Alterar Map. HTML"//Aguarde//"Alterando Mapemaneto de e-mail ..."

ASORT(oView:AUSERBUTTONS,,,{ | x,y | y[1] > x[1] } )
//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model
oView:SetDescription(STR0006) //"Modelo De Email"

//--------------------------------------
//		Montagem dos Objetos da Tela
//--------------------------------------
oView:AddOtherObject("VIEW_HTML" , {|oPanel,oModel| MntEdHTML(oPanel,oModel)})//Adiciona um objeto externo ao View do MVC
oView:AddOtherObject("VIEW_OUTROS" , {|oPanel| MntOutros(oPanel)},{|oPanel| oPanel:FreeChildren()})//Adiciona um objeto externo ao View do MVC

//--------------------------------------
//		Montagem da tela Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 32 )// Primeira Linha da Tela
oView:CreateHorizontalBox( "LINETWO", 68 )// Segunda  Linha da Tela

oView:CreateVerticalBox( "LINETWO_COLLONE", 70, "LINETWO")// Primeira Coluna dentro da Segunda Linha da Tela
oView:CreateVerticalBox( "LINETWO_COLLTWO", 30, "LINETWO")// Segunda Coluna dentro da Segunda Linha da Tela

oView:AddField("VIEW_MODEMA_GRID", oStructAO6, "AO6MASTER" )///,,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oView:SetOwnerView( "VIEW_MODEMA_GRID","LINEONE"  )
oView:SetOwnerView( "VIEW_HTML","LINETWO_COLLONE" )
oView:SetOwnerView( "VIEW_OUTROS","LINETWO_COLLTWO" )

Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis para a tela de atividades

@param		Nenhum

@return	aRotina - array contendo as opções disponiveis

@author	Victor Bitencourt
@since		24/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

   ADD OPTION aRotina TITLE STR0008   ACTION "VIEWDEF.CRMA230"   OPERATION 2 ACCESS 0 //"Visualizar"
   ADD OPTION aRotina TITLE STR0009   ACTION "CRMA230INC()"      OPERATION 3 ACCESS 0 //"Incluir"
   ADD OPTION aRotina TITLE STR0010   ACTION "CRMA230ALT()"      OPERATION 4 ACCESS 0 //"Alterar"
   ADD OPTION aRotina TITLE STR0011   ACTION "VIEWDEF.CRMA230"   OPERATION 5 ACCESS 0 //"Excluir"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntMark()

Rotina para montar em uma janela determinada o Editor de Html

@param	  	ExpO1 = Objeto da janela onde será criado o Markbrowse

@return   	Nil

@author	Victor Bitencourt
@since		24/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function MntOutros( oPanel )

Local  nX         := 0

Local cCapital    := ""
Local cTGet 	    := ""
Local cComboSTA   := ""

Local lMark       := .F.

Local aEntConex   := {}
Local aCampos     := {}
Local aStatus     := {"",STR0014,STR0015,STR0031}//"1=Campo"//"2=Complementos de Email"//"3=Função"

Local oView 	    := FWViewActive()
Local oBrwMark    := Nil
Local oTGet       := Nil
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
oFWLayer:addWindow( "COL1", "WIN1", STR0016, 100, .F., .F.,,"LINHA")//"Mesclagem"

oCOLLONE := oFwLayer:getColPanel("COL1","LINHA")
oLayerInte:init(oCOLLONE,.F.)

oLayerInte:AddLine("LINEONE" ,25,.F.)
oLayerInte:AddLine("LINETWO" ,65,.F.)
oLayerInte:AddLine("LINETHE" ,10,.F.)

oLINEONE := oLayerInte:GetLinePanel("LINEONE")
oLINETWO := oLayerInte:GetLinePanel("LINETWO")
oLINETHE := oLayerInte:GetLinePanel("LINETHE")

oLayerMark:init(oLINETWO,.F.)
oLayerMark:addCollumn( "COL2",100, .F. ,"LINHA2" )
oCOLLMARK := oLayerMark:getColPanel("COL2","LINHA2")
oLayerMark:addWindow( "COL2", "WIN2", STR0017, 100, .F., .F.,,"LINHA2")//"Mascara"

oPanel    := oFWLayer:GetWinPanel("COL1","WIN1","LINHA")
oCOLLMARK := oLayerMark:GetWinPanel("COL2","WIN2","LINHA2")

@ 019, 06 SAY oTitulo2 PROMPT STR0018 SIZE 120,009  OF oLINEONE PIXEL //"Campo / Complemento"
@ 028,06 MSCOMBOBOX oComboSTA VAR cComboSTA ITEMS aStatus  SIZE 085, 009 OF oLINEONE ON CHANGE CarregaMark(aCampos,oBrwMark,cComboSTA) PIXEL

DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oCOLLMARK
		ADD MARKCOLUMN oColEnt DATA {|| IIF(aCampos[oBrwMark:At()][1],"LBOK","LBNO") } DOUBLECLICK {|| MarcaReg(@aCampos,oBrwMark,oTGet,@cTGet,cComboSTA)} OF oBrwMark
		ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][3] }") TITLE STR0019 TYPE "C" SIZE 30 OF oBrwMark//"Masks"
		oBrwMark:DisableReport()
ACTIVATE FWBROWSE oBrwMark

oTGet := TGet():New( 00,06,{||cTGet},oLINETHE,0179,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet,,,, )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA230INC()

Rotina para chamar a tela de inclusão de Modelos de email

@param		ExpC1 = Alias da entidade que deverá começar pre carregada na inclusão..quando existir a necessidade.

@return	Nenhum

@author    Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA230INC(cAlias)

Local oView       := Nil
Local oModel      := Nil
Local aSize	    := FWGetDialogSize( oMainWnd )
Local bCloseOnOk  := {|| }
Local lCadastro   := .F.

Default cAlias    := ""

oModel := FWLoadModel("CRMA230")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
If !Empty(cAlias)
	oModel:GetModel("AO6MASTER"):SetValue("AO6_ENTMOD",cAlias)
EndIf
oModel:lModify := .T.
nCRM230MOp := MODEL_OPERATION_INSERT // Setando a operação do model

oView := FWLoadView("CRMA230")

oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT)
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)

oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0020)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()

Validação dos Dados , após dar o Commit no model.. verifica qual a operação
que estava sendo realizada , para poder enviar os dados para o exchange

@param	  ExpO1 = oModel .. objeto do modelo de dados corrente.

@return  .T.

@author   Victor Bitencourt
@since    25/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Local nOperation   := oModel:GetModel("AO6MASTER"):GetOperation()
Local cBody := ""

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	If Type("oCRM230EHT") == "O"
		cBody := oCRM230EHT:GetText()
	ElseIf !Empty(oModel:GetModel("AO6MASTER"):GetValue("AO6_MENSAG")) 	
		cBody := oModel:GetModel("AO6MASTER"):GetValue("AO6_MENSAG")
	EndIf
	//---------------------------------------
	//		Tratando as imagens do e-mail
	//---------------------------------------
	
	If !Empty(cBody)
	
		If Empty(oModel:GetModel("AO6MASTER"):GetValue("AO6_LNKIMG")) // Verificando se já existe mapeamento de links para este e-mail, senão for rotina automatica.
			//cXml :=  // Rotina para Ler e retornar o xml de mapeamento
			oModel:GetModel("AO6MASTER"):SetValue("AO6_LNKIMG",CRMA170LMG(cBody,.T.) )
		EndIf
	
	   If nOperation == MODEL_OPERATION_INSERT
	   		cBody := CRMA170Lnk( cBody, .T., /*lEnvia*/, .F., .F.) //fazendo a troca dos endereços locais por codigos rastreaveis
	   	Else
	   		cBody := CRMA170Lnk( cBody, .T., /*lEnvia*/, .F., .T.) //fazendo a troca dos endereços locais por codigos rastreaveis
	   EndIf
	   oModel:GetModel("AO6MASTER"):SetValue("AO6_MENSAG",cBody)
	EndIf   

EndIf

FWFormCommit(oModel)//Salvando o formulario.

If  nOperation == MODEL_OPERATION_INSERT .AND. AO6->AO6_ANEXO == "1"
	 MsDocument("AO6",AO6->(RecNo()),2 , , 1, {}, .F. )
EndIf

Return (.T.)

//----------------------------------------------------------
/*/{Protheus.doc} CarregaMark()

Rotina para carregar os dados conforme a escolha do usuario Campo/Complemento

@param	  ExpA1 = Array contendo os dados dos registros que o Browse carrega na tela
		  ExpO1 = Objeto Browse que deverá ser manipulado
		  ExpC1 = Opção escolhida pelo usuario para ser carregado 1=Campo/2=Complemento

@return  Nenhum

@author  Victor Bitencourt
@since   26/03/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function CarregaMark(aCampos,oBrwMark,cOpcao)

Local aAreaSX3   := {}
Local aAreaAOE   := {}
Local aAreaAZB   := {}
Local lMark      := .F.

Default cOpcao   := ""
Default oBrwMark := Nil

Asize( aCampos, 0)

If cOpcao == "1"
	If Select("SX3") > 0
		aAreaSX3 := SX3->(GetArea())
	Else
		DbSelectArea("SX3")//Arquivo de Campos
	EndIf
	SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM

	If SX3->(DbSeek(FwFldGet("AO6_ENTMOD")))
		Do While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == FwFldGet("AO6_ENTMOD")
			If	SX3->X3_CONTEXT <> "V"
				AAdd( aCampos,{lMark,SX3->X3_CAMPO,SX3->X3_DESCRIC} )
			EndIf
			SX3->( DbSkip())
		EndDo
	EndIf
ElseIf cOpcao == "2"
	If Select("AOE") > 0
		aAreaAOE := AOE->(GetArea())
	Else
		DbSelectArea("AOE")//Cadastro Complementos de email
	EndIf
	AOE->(DbSetOrder(1))//AOE_FILIAL+AOE_ENTIDA

	If AOE->(DbSeek(xFilial("AOE")+FwFldGet("AO6_ENTMOD")))
		Do While AOE->(!EOF()) .AND. AOE->AOE_ENTIDA == FwFldGet("AO6_ENTMOD")
			AAdd( aCampos,{lMark,"",AOE->AOE_CMPCOM} )
			AOE->( DbSkip())
		EndDo
	EndIF
ElseIf cOpcao == "3"
	aAreaAZB := AZB->(GetArea())
	AZB->(DbSetOrder(1))//AZB_FILIAL+AZB_ENTIDA

	If AZB->(DbSeek(xFilial("AZB")+FwFldGet("AO6_ENTMOD")))
		Do While AZB->(!EOF()) .AND. AZB->AZB_ENTIDA == FwFldGet("AO6_ENTMOD")
			AAdd( aCampos,{lMark,AZB->AZB_ENTIDA,AZB->AZB_CMPCOM} )
			AZB->( DbSkip())
		EndDo
	EndIF
	RestArea(aAreaAZB)
EndIf
If ValType(oBrwMark) == "O"
	oBrwMark:SetArray(aCampos)
	oBrwMark:Refresh(.T.)
EndIf

If !Empty(aAreaSX3)
	RestArea(aAreaSX3)
ElseIf !Empty(aAreaAOE)
	RestArea(aAreaAOE)
EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} GeraMescla()

Rotina para gerar o codigo de mesclagem do campo/Complemento para ser inserido no email

@param	  ExpO1 = objeto do Browse que será manipulado
		  ExpA1 = Array contendo os dados dos registros que o Browse utiliza
		  ExpO2 = Objeto do campo Get que será manipulado
		  ExpC1 = Variavel onde será atribuido o Codigo Gerado
		  ExpC2 = Opção escolhida pelo usuario 1=Campo/2=Complemento

@return  Nenhum

@author   Victor Bitencourt
@since    26/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function GeraMescla(oBrwMark,aCampos,oTGet,cTGet,cOpcao)

Default cOpcao   := ""
Default aCampos  := {}
Default oTGet    := Nil
Default oBrwMark := Nil

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos)
	If cOpcao == "1"
		If aCampos[oBrwMark:At()][1] == .T.
			cTGet := "$!"+AllTrim(aCampos[oBrwMark:At()][2])+"$!"
		Else
			cTGet := ""
		EndIf
	ElseIf cOpcao == "2"
		If aCampos[oBrwMark:At()][1] == .T.
			cTGet := "##"+AllTrim(aCampos[oBrwMark:At()][3])+"##"
		Else
			cTGet := ""
		EndIf
	ElseIf cOpcao == "3"
		If aCampos[oBrwMark:At()][1] == .T.
			cTGet := "#!"+AllTrim(aCampos[oBrwMark:At()][3])+"#!"
		Else
			cTGet := ""
		EndIf
	EndIf
	If ValType(oTGet) == "O"
		oTGet:CtrlRefresh()
	EndIf
EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} MarcaReg()

Rotina para Marcar no browse o registro escolhido e chamar a rotina de mesclagem do
campo/Complemento para ser inserido no email

@param	   ExpA1 = Array contendo os dados dos registros que o Browse utiliza
		   ExpO1 = objeto do Browse que será manipulado
           ExpO2 = Objeto do campo Get que será manipulado
		   ExpC1 = Variavel onde será atribuido o Codigo Gerado
		   ExpC2 = Opção escolhida pelo usuario 1=Campo/2=Complemento

@return   Nenhum

@author   Victor Bitencourt
@since    26/03/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function MarcaReg(aCampos,oBrwMark,oTGet,cTGet,cComboSTA)

Local nPosAnt    := 0
Local nPos       := 0

Local aDados     := {}

Default aCampos  := {}
Default oBrwMark := Nil

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos)

   aDados  := Aclone(aCampos)
   nPosAnt := Ascan(aDados,{|x|  x[1] == .T.})
   nPos    := oBrwMark:At()

   If nPosAnt > 0 .AND. nPosAnt <> nPos
   		aCampos[nPosAnt][1] := !aCampos[nPosAnt][1]
   EndIf

   aCampos[nPos][1] := !aCampos[nPos][1]
   GeraMescla(oBrwMark,aCampos,oTGet,@cTGet,cComboSTA)

   oBrwMark:SetArray(aCampos)
   oBrwMark:Refresh(.T.)
   oBrwMark:Goto(nPos)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA230ALT()

Rotina para chamar a tela de alteração do modelo de email

@param		Nenhum

@return	Nenhum

@author	Victor Bitencourt
@since		03/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA230ALT()

Local oView      := Nil
Local oModel     := Nil
Local aSize	   := FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local bCloseOnOk := {|| }

nCRM230MOp := MODEL_OPERATION_UPDATE // Setando a o tipo de operação do model

oModel := FWLoadModel("CRMA230")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModel:lModify := .T.

oView := FWLoadView("CRMA230")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_UPDATE)

oFWMVCWin := FWMVCWindow():New()

oFWMVCWin:SetUseControlBar(.T.)
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0021)//"Alterar"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntEdHTML()

Rotina para montar em uma janela determinada o Editor de Html

@param	  	ExpO1 = Objeto da janela onde será criado o Editor de Html
			ExpO2 = Objeto do Modelo de dados 

@return   	Nenhum

@author	Victor Bitencourt
@since		24/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function MntEdHTML( oPanel, oModel )

Local   oFwLayer    := Nil

Default oPanel := Nil
Default oModel := Nil

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", STR0012, 100, .F., .F., , "LINHA2")//Calendário//"Calendário"//"Editor de Email"

oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2")

oCRM230EHT := FWSimpEdit():New( 0, 0, 500,600, STR0013,,,.F.,.F. , oPanel)//"Editor HTML"

If oModel <> Nil .AND. oModel:GetModel("AO6MASTER"):GetOperation() <> MODEL_OPERATION_INSERT // Verificando a operação do model para carregar o conteudo do Html
	oCRM230EHT:SetText(CRMA170CRG(AO6->AO6_MENSAG, .F.))//Carregando o email no objeto
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AlteraMapHTML()

Rotina para alterar o mapeamento do HTML

@param	  	Nenhum

@return   	Nenhum

@author	Victor Bitencourt
@since		23/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function AlteraMapHTML()

Local cXml := ""
Private lMsErroAuto := .F.

cXml := CRMA170LMG(Nil, Nil, .T.)

If !Empty(cXml)

	aExecAuto := {{"AO6_FILIAL",xFilial("AOF")	,Nil},;
	   			 	{"AO6_CODMOD" ,AO6->AO6_CODMOD ,Nil},;
				 	{"AO6_LNKIMG" ,cXml			   ,Nil}}
	CRMA230(,,aExecAuto, 4) // Importar agenda por rotina automatica

EndIf

Return

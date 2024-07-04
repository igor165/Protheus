#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM940.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM940
Integração com Swile
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Function GPEM940()

Local oNewPag   		:= Nil
Local oStepWiz  		:= Nil

Private aLogErr       	:= {}
Private aLogFiltro     	:= {}
Private aLogImp       	:= {}
Private aLogProc       	:= {}
Private aTitle         	:= { OemToAnsi(STR0004), OemToAnsi(STR0005), OemToAnsi(STR0045), OemToAnsi(STR0046)}//"Processamento"##"Filtros realizados: "##"Erro na integração com Swile"##"Registros Integrados"
Private cAliasTmp		:= GetNextAlias()
Private cTimeIni		:= ""
Private lInExec			:= .F.
Private lIntegrou		:= .F.
Private nQtdSel 		:= 0
Private nRemoteType		:= GetRemoteType()
Private nTotInteg 		:= 0
Private nTotProc 		:= 0
Private oArqTmp			:= Nil

//Parametrização
Private cSWURL			:= SuperGetMv( 'MV_APISWI1', Nil, "" )
Private cSWUser			:= SuperGetMv( 'MV_APISWI2', Nil, "" )
Private cSWPsw			:= SuperGetMv( 'MV_APISWI3', Nil, "" )

//Tela Opções
Private lIntFil 		:= .F.
Private lIntGrp 		:= .F.
Private lIntFunc 		:= .F.
Private lIntPed 		:= .F.
Private oChkFil			:= Nil
Private oChkGrp			:= Nil
Private oChkFunc		:= Nil
Private oChkPed			:= Nil

//Tela Filtro
Private aArrayFil		:= {}
Private cFltGrp			:= ""
Private cFltFunc		:= ""
Private cFltPed			:= ""
Private oButFil			:= Nil
Private oButGrp			:= Nil
Private oButFunc		:= Nil
Private oButPed			:= Nil

//Tela Processamento
Private oButtonProc		:= Nil
Private oSayProc		:= Nil
Private oSaySep			:= Nil

If Empty(cSWURL) .Or. Empty(cSWUser) .Or. Empty(cSWPsw)
	//"Atenção"###"Os parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APISWI1 MV_APISWI2 e/ou MV_APISWI3 no módulo Configurador"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

fCriaTmp()//Criação de tabela temporária para a MarkBrowse de seleção de filiais

oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep( "1" )
oNewPag:SetStepDescription( STR0006 )//"Observações"
oNewPag:SetConstruction( { |Panel1| fPag1(Panel1) } )
oNewPag:SetNextAction( { || !PrcExec() } )
oNewPag:SetCancelAction( { || .T.} )

oNewPag := oStepWiz:AddStep( "2" )
oNewPag:SetStepDescription( STR0007 )//"Opções"
oNewPag:SetConstruction( { |Panel2| fPag2(Panel2) } )
oNewPag:SetNextAction( { || fVldOpc() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "3" )
oNewPag:SetStepDescription( STR0008 )//"Filtro"
oNewPag:SetConstruction( { |Panel3| fPag3(Panel3) } )
oNewPag:SetNextAction( { || fVldOpc() .And. fVldFil() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "4" )
oNewPag:SetStepDescription( STR0009 )//"Processamento"
oNewPag:SetConstruction( { |Panel4| fPag4(Panel4) } )
oNewPag:SetPrevAction( { || PrcConcl() } )
oNewPag:SetNextAction( { || !PrcInt() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag:SetPrevWhen( { || !PrcExec() } )
oNewPag:SetCancelWhen( { || !PrcExec() } )

oStepWiz:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaTmp
Criação da tabela temporária da SM0
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fCriaTmp()

Local aLstIndices	:= {}
Local aSM0 			:= FWLoadSM0(.T., Nil, .T.)
Local aStru			:= {}
Local nCont			:= 0

aAdd( aStru, { "OK"		, "C", 2			  , 0 } )
aAdd( aStru, { "FILIAL"	, "C", FwGetTamFilial , 0 } )
aAdd( aStru, { "NOME"  	, "C", 100			  , 0 } )
aAdd( aStru, { "CNPJ"  	, "C", 14 			  , 0 } )
aAdd( aLstIndices, { "FILIAL" } )

oArqTmp := RhCriaTrab(cAliasTmp, aStru, aLstIndices)

For nCont := 1 To Len(aSM0)
	If aSM0[nCont, 1] == cEmpAnt
		If (cAliasTmp)->( RecLock(cAliasTmp, .T.) )
			(cAliasTmp)->FILIAL	:= aSM0[nCont, 2]
			(cAliasTmp)->NOME  	:= aSM0[nCont, 7]
			(cAliasTmp)->CNPJ 	:= aSM0[nCont, 18]
			(cAliasTmp)->(MsUnlock())
		EndIf
	EndIf
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag1
Painel com os descritivos do assistente
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag1(oPanel)

Local oButtonProc	:= Nil

TSay():New( 25, 20, { || fText("BEMVINDO") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )
TSay():New( 45, 20, { || fText("ASSIST") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 120, 25, OemToAnsi(STR0010), oPanel, { || ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=707370134", "", "", 1 ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F. )//"Clique para abrir a documentação no TDN"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag2
Painel com as opções para integração
@author  Allyson L Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag2(oPanel)

Local lTabSel	    := .F.
Local nLin			:= 45
Local oSayExec		:= Nil

oSayExec := TSay():New( 20, 10, { || STR0007 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Opções"

oChkFil := TcheckBox():New( nLin, 10, STR0011, { || lIntFil }, oPanel, 300, 10, Nil, { || lIntFil := !lIntFil }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Filiais"
nLin += 10
oChkGrp := TcheckBox():New( nLin, 10, STR0012, { || lIntGrp }, oPanel, 300, 10, Nil, { || lIntGrp := !lIntGrp }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Grupos de benefícios"
nLin += 10
oChkFunc := TcheckBox():New( nLin, 10, STR0013, { || lIntFunc }, oPanel, 300, 10, Nil, { || lIntFunc := !lIntFunc }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Funcionários"
nLin += 10
oChkPed := TcheckBox():New( nLin, 10, STR0014, { || lIntPed }, oPanel, 300, 10, Nil, { || lIntPed := !lIntPed }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Pedidos"

nLin += 20
oChkInv := TcheckBox():New( nLin, 10, STR0015, { || lTabSel }, oPanel, 300, 10, Nil, { || fInverte(@lTabSel) }, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, Nil )//"Inverte seleção"

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag3
Painel com os filtros
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag3(oPanel)

Local nLin			:= 45
Local oSayExec		:= Nil

oSayExec := TSay():New( 20, 10, { || STR0016 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Filtros"

oButFil  := TButton():New( nLin, 25, OemToAnsi(STR0017), oPanel, { || fSelFil() }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Filiais"
nLin += 20
oButGrp  := TButton():New( nLin, 25, OemToAnsi(STR0018), oPanel, { || GpFltBldExp( "SRA", Nil, @cFltGrp, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Grupos de benefícios"
nLin += 20
oButFunc := TButton():New( nLin, 25, OemToAnsi(STR0019), oPanel, { || GpFltBldExp( "SRA", Nil, @cFltFunc, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Funcionários"
nLin += 20
oButPed := TButton():New( nLin, 25, OemToAnsi(STR0020), oPanel, { || GpFltBldExp( "SRA", Nil, @cFltPed, Nil ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Pedidos"

oButGrp:lActive 	:= lIntGrp
oButFunc:lActive 	:= lIntFunc
oButPed:lActive 	:= lIntPed

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag4
Painel com o processamento da integração
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fPag4(oPanel)

TSay():New( 45, 20, { || fText("PROC") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 100, 25, OemToAnsi(STR0021), oPanel, { || fBarra(oPanel, oButtonProc ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Clique para efetuar a integração"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fText
Formatação do textos dos descritivos do assistente
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fText(cInfo)

Local cRet 		:= ""

If cInfo == "BEMVINDO"
	cRet := '<font size="6" color="#0c9abe"><b>'+STR0022+'</b></font>'//"Bem-vindo..."
	cRet += '<br/>'
ElseIf cInfo == "ASSIST"
	cRet += '<font size="5" color="#888">'+STR0023//"Este é um processo para a integração de registros para Swile"
ElseIf cInfo == "PROC"
	cRet += '<font size="5" color="#888">'+STR0024//"Ao clicar no botão abaixo, será iniciado o processo de"
	cRet += '<br/>'
	cRet += STR0025//"integração com Swile."
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fCSS(cIDCSS)

Local cCSS := ""

Do Case
	Case cIDCSS == "TEXTTITLE"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "BTPROC"
		cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;"
		cCSS += "padding: 2px 5px;"
		cCSS += "text-align: center; "
		cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS += "QPushButton:hover { "
		cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
		cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;"
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
EndCase

Return(cCSS)

//-------------------------------------------------------------------
/*/{Protheus.doc} fInverte
Função para inverter a seleção dos itens a serem integrados
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fInverte(lRet)

lIntFil 	:= !lIntFil
lIntGrp 	:= !lIntGrp
lIntFunc 	:= !lIntFunc
lIntPed 	:= !lIntPed

oChkFil:Refresh()
oChkGrp:Refresh()
oChkFunc:Refresh()
oChkPed:Refresh()

Return !lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOpc
Valida a seleção de opções
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fVldOpc()

Local lRet := .T.

fContSel()

If Empty(nQtdSel)
	lRet := .F.
	MsgInfo(STR0026, STR0001)//"Certifique-se ao menos de selecionar uma opção para integração"##"Atenção"
EndIf

If ValType(oButFil) != "U"
	oButFil:lActive 	:= .T.
	oButGrp:lActive 	:= lIntGrp
	oButFunc:lActive 	:= lIntFunc
	oButPed:lActive 	:= lIntPed
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fContSel
Verifica quantas opções foram selecionadas
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fContSel()

nQtdSel := 0

If lIntFil
	nQtdSel++
EndIf
If lIntGrp
	nQtdSel++
EndIf
If lIntFunc
	nQtdSel++
EndIf
If lIntPed
	nQtdSel++
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcConcl
Retorna se o processamento já foi concluído
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcConcl()

If oArqTmp == Nil
	fCriaTmp()
	oButtonProc:Enable()
	oSayProc:setText("")
	oSaySep:setText("")	
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcExec
Retorna se o processamento está em execução de acordo com o semáforo
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcInt
Retorna se o processamento foi realizado
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function PrcInt()

Local lRet	:= .F.

If !lIntegrou
	lRet := !MsgNoYes(STR0027, STR0001)//"Deseja fechar a rotina sem efetuar a importação?"##"Atenção"
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fSelFil
Retorna as filiais que serão processadas
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fSelFil()

Local aButtons 		:= {}
Local aColumns 		:= {}
Local bOK2			:= { || ( oDlgGrid:End(), nOpcB := 1 ) }
Local bFecha 		:= { || oDlgGrid:End() }
Local lMArcar 		:= .F.
Local nOpcB 		:= 0
Local oFont 		:= Nil

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->FILIAL }") )
aColumns[Len(aColumns)]:SetTitle( STR0028 )//"Filial"
aColumns[Len(aColumns)]:SetSize( FwGetTamFilial )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->NOME }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0029 )//"Nome"
aColumns[Len(aColumns)]:SetSize( Len(SM0->M0_NOME) )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->CNPJ }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0030 )//"CNPJ"
aColumns[Len(aColumns)]:SetSize( 14 )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@R 99.999.999/9999-99" )

//Tela
oSize := FwDefSize():New(.F.)
oSize:AddObject( "CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4) , .F., .F. )
oSize:aMargins 	:= { 0, 0, 0, 0 }
oSize:lProp 	:= .F. 
oSize:Process()

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(STR0031) From 0, 0 TO 380, 930 OF oMainWnd PIXEL//"Filiais"

oTela2	:= FWFormContainer():New( oDlgGrid )
cIdGrid	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension( "CABECALHO","LININI" )+1, oSize:GetDimension( "CABECALHO", "COLINI" )+4 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090, oSize:GetDimension("CABECALHO","COLEND") * 0.431 OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension( "CABECALHO","LININI" )+9, oSize:GetDimension( "CABECALHO", "COLINI" )+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()
oMark:SetAlias( cAliasTmp )
oMark:SetTemporary( .T. )
oMark:SetColumns( aColumns )

//Indica o container onde sera criado o browse
oMark:SetOwner( oPanel4 )
oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTmp ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')

oMark:SetMenuDef("GPEM034")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha, NIL, aButtons)

If nOpcB == 1
	aArrayFil		:= {}
	(cAliasTmp)->(dbGoTop())
	While (cAliasTmp)->( !EoF() )
		If !Empty( (cAliasTmp)->OK )
			aAdd(aArrayFil, { (cAliasTmp)->FILIAL, (cAliasTmp)->NOME })
		EndIf
		(cAliasTmp)->( dbSkip() )
	EndDo
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Marca/desmarca todos os itens
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca, lMarcar, cAliasTmp)

Local aAreaMark  := (cAliasTmp)->( GetArea() )

dbSelectArea(cAliasTmp)
(cAliasTmp)->( dbGoTop() )

While (cAliasTmp)->( !Eof() )
	If RecLock( (cAliasTmp), .F. )
		(cAliasTmp)->OK := Iif( lMarcar, cMarca, '  ' )
		MsUnLock()
	EndIf
	(cAliasTmp)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFil
Valida a seleção de filiais
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFil()

Local lRet := .T.

If Empty(aArrayFil)
	lRet := .F.
	MsgInfo(STR0032, STR0001)//"Certifique-se de selecionar a(s) filial(is) para processamento no botão de Filtro de Filiais"##"Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fBarra
Monta a barra de progresso na parte de baixo do painel 3 do wizard
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fBarra(oPanel, oButtonProc)

Local nMeter	:= 0
Local nMeter2	:= 0
Local oMeter	:= Nil
Local oMeter2	:= Nil
Local oSayProc2	:= Nil
Local oSayProc3	:= Nil

lInExec := .T.

aAdd( aLogProc, STR0033 + dToC( Date() ) )//"Data de início: "
aAdd( aLogProc, STR0034 + Time() )//"Hora de início: "

// Desabilita os botões
oButtonProc:Disable()

oSaySep := TSay():New( 115, 02, { || Replicate("_", 150) }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )
oSaySep:setCSS( fCSS("LINESEPARADOR") )

oSayProc := TSay():New( 130, 80, { || STR0035 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Efetuando Processamento -> "
oSayProc:setCSS( fCSS("TEXTTITLE") )

oSayProc2 := TSay():New( 145, 115, { || STR0036 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Opções importadas: "
oSayProc2:setCSS( fCSS("TEXTTITLE") )
oMeter2 := TMeter():New( 155, 25, { |u| Iif( Pcount() > 0, nMeter2 := u, nMeter2) }, 100, oPanel, 250, 16,, .T.)
oMeter2:setCSS("METER")
oMeter2:SetTotal(0)
oMeter2:Set(0)

oSayProc3 := TSay():New( 175, 115, { || STR0037 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300,20 )//"Registros importados: "
oSayProc3:setCSS( fCSS("TEXTTITLE") )
oMeter := TMeter():New( 185, 25, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 250, 16, Nil, .T. )
oMeter:setCSS("METER")
oMeter:SetTotal(0)
oMeter:Set(0)

// Chama as funções de processamento
fProc(oSayProc, oMeter, oMeter2, oSayProc2, oSayProc3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fProc
Encapsula as funções de processamento
@author  Allyson Luiz Mesashi
@since   01/09/2022
/*/
//-------------------------------------------------------------------
Static Function fProc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local cFilSelec	:= ""
Local cCookie	:= ""
Local cToken	:= ""
Local lTokOk	:= .F.
Local nContFil	:= 0

cTimeIni := Time()
oMeter2:SetTotal( nQtdSel )

fLogout()
lTokOk := fGetToken( @cToken, @cCookie )

If !lTokOk
	aAdd(aLogErr, STR0047)//"Houve falha ao tentar obter o token de acesso. Solicite ao administrador uma revisão dos parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3"
Else
	For nContFil := 1 To Len(aArrayFil)
		cFilSelec += aArrayFil[nContFil, 1] + "|"
	Next nContFil
	FiltraLog( aLogFiltro, STR0038 + cFilSelec)//"Filiais selecionadas: "

	If lIntFil//Filial
		fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken, cCookie)
	EndIf
EndIf

aAdd( aLogProc, STR0039 + dToC( Date() ) )//"Data de término: "
aAdd( aLogProc, STR0040 + Time() )//"Hora de término: "
aAdd( aLogProc, STR0041 + ElapTime( cTimeIni, Time() ) )//"Tempo de processamento: "
aAdd( aLogProc, "")
aAdd( aLogProc, STR0042 + cValToChar(nTotInteg) )//"Total de registros integrados: "
fMakeLog( { aLogProc, aLogFiltro, aLogErr, aLogImp }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0043), "G", "L", Nil, .F.) //"Log de Ocorrências"

MsgAlert(STR0044, STR0001)//"Processamento Finalizado"##"Atenção"
lInExec 	:= .F.
lIntegrou  	:= .T.

If ValType(oMeter2) <> "U"
	oSay:setText(Space(20)+STR0044)//"Processamento Finalizado."
	oMeter:Free()
	oMeter2:Free()
	oSayProc2:setText("")
	oSayProc3:setText("")
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->( dbCloseArea() )
EndIf

If oArqTmp != Nil
	oArqTmp:Delete()
	Freeobj(oArqTmp)
EndIf

///Reinicialização das variáveis de integração
aArrayFil 	:= {}
aLogErr		:= {}
aLogFiltro	:= {}
aLogImp 	:= {}
aLogProc 	:= {}
aTitle    	:= { OemToAnsi(STR0004), OemToAnsi(STR0005), OemToAnsi(STR0045), OemToAnsi(STR0046)}//"Processamento"##"Filtros realizados: "##"Erro na integração com Swile"##"Registros Integrados"
cFltGrp 	:= cFltFunc := cFltPed 	:= ""
lIntFil 	:= lIntGrp 	:= lIntFunc := lIntPed := .F.
nTotInteg	:= nTotProc	:= 0
oButFil:lActive 	:= .F.
oButGrp:lActive 	:= .F.
oButFunc:lActive 	:= .F.
oButPed:lActive 	:= .F.

Return

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} fLogout()
Função que efetua o logout no Swile
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Static Function fLogout()

Local aHeader	:= {}
Local oClient 	:= Nil

oClient := FwRest():New(cSWURL+"/logout")
oClient:SetPath("")
oClient:Post(aHeader)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetToken()
Função que gera o token de acesso no Swile
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Static Function fGetToken( cToken, cCookie )

Local aHeader		:= {}
Local cBody			:= ""
Local lRet 			:= .F.
Local nPosCookie	:= ""
Local oClient 		:= Nil
Local oJson 		:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Content-Type: application/x-authc-username-password+json" )

cBody := "{"
cBody += '"userId": "' + cSWUser + '",'
cBody += '"password": "' + cSWPsw + '"'
cBody += "}"

oClient:SetPostParams(cBody)
oClient:SetPath("/authenticate")

If oClient:Post(aHeader)
	oJson:fromJson( oClient:GetResult() )
	cToken 	:= oJson["token"]
	lRet 	:= .T.
	If ( nPosCookie := aScan(oClient:oResponseH:aHeaderFields, { |x| Upper(AllTrim(x[1])) == "SET-COOKIE" }) ) > 0
		cCookie := oClient:oResponseH:aHeaderFields[nPosCookie, 2]
	EndIf	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFil
Realiza a integração da tabela SM0 de filiais
@author  Allyson Luiz Mesashi
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken, cCookie)

Local aArea 		:= GetArea()
Local aInfoFil		:= {}
Local aRegErr		:= {}
Local aRegInt		:= {}
Local cAliasQRY 	:= "IMPSM0"
Local cErrInt		:= ""
Local cFilQry		:= ""
Local cNomeTmp 		:= oArqTmp:GetRealName()
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0049 + STR0050 )//"Iniciando Processamento..."##"Importação filiais"
oSayProc2:SetText( STR0051 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT FILIAL "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	+= "ORDER BY 1"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	cErrInt := ""
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0052 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

	If fInfo( @aInfoFil, (cAliasQRY)->FILIAL, cEmpAnt )
		oJson := JsonObject():New()
		oJson['name'] 			:= AllTrim( aInfoFil[03] )//M0_NOMECOM
		oJson['document'] 		:= AllTrim( aInfoFil[08] )//M0_CGC
		oJson['street'] 		:= AllTrim( SubStr( aInfoFil[04], 1, At(",", aInfoFil[04])-1) )//M0_ENDENT
		oJson['number'] 		:= AllTrim( SubStr( aInfoFil[04], At(",",aInfoFil[04])+1) )//M0_ENDENT
		oJson['complement'] 	:= AllTrim( aInfoFil[14] )//M0_COMPENT
		oJson['neighborhood'] 	:= AllTrim( aInfoFil[13] )//M0_BAIRENT
		oJson['city'] 			:= AllTrim( aInfoFil[05] )//M0_CIDENT
		oJson['state'] 			:= AllTrim( aInfoFil[06] )//M0_ESTENT
		oJson['country'] 		:= Iif( cPaisLoc == "BRA", "Brasil", "")
		oJson['zipCode'] 		:= AllTrim( SubStr(aInfoFil[07], 1, 5) + "-" + SubStr(aInfoFil[07], 6) )//M0_CEPENT
		
		If fEnvFil(oJson, cToken, cCookie, @cErrInt)
			aAdd(aRegInt, oJson['document'] + " - " + oJson['name'])
		Else
			aAdd(aRegErr, oJson['document'] + " - " + oJson['name'])
			aAdd(aRegErr, cErrInt )
		EndIf
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

If !Empty(aRegInt)
	aAdd(aLogImp, STR0053)//"Registros integrados de filiais: "
	For nRegs := 1 To Len(aRegInt)
		aAdd(aLogImp, aRegInt[nRegs])
	Next nRegs
	nTotInteg += Len(aRegInt)
EndIf

If !Empty(aRegErr)
	aAdd(aLogErr, STR0054)//"Erro na integração das filiais: "
	aAdd(aLogErr, STR0048)//"Obs.: erro completo retornado:"
	For nErrInt := 1 To Len(aRegErr)
		FiltraLog( aLogErr, aRegErr[nErrInt])
	Next nErrInt	
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEnvFil()
Função que efetua a integração para Swile das filiais
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fEnvFil( oJson, cToken, cCookie, cErrInt )

Local aHeader	:= {}
Local cBody		:= ""
Local cPath		:= ""
Local lAchou	:= .F.
Local lRet 		:= .F.
Local oClient 	:= Nil
Local oResult 	:= JsonObject():New()

oClient := FwRest():New(cSWURL)

aAdd( aHeader, "apiVersion: 3" )
aAdd( aHeader, "Authorization: Bearer " + cToken )
aAdd( aHeader, "Content-Type: application/json" )
aAdd( aHeader, "Cookie: " + cCookie )

oClient:SetPath("/private/corporate/branch/find")

cBody := '{'
cBody += 	'"document": "' + oJson['document'] + '"'
cBody += '}'
oClient:SetPostParams(cBody)

If oClient:Post(aHeader)
	oResult:fromJson( oClient:GetResult() )
	lAchou := ValType( oResult["branchIdentify"] ) == "C"
EndIf

cPath := Iif( lAchou, "/private/corporate/branch/update", "/private/corporate/branch/add" )
oClient:SetPath(cPath)

cBody := '{'
cBody += 	'"name": "' + oJson['name'] + '",'
cBody += 	'"document": "' + oJson['document'] + '",'
cBody += 	'"address": {'
cBody += 		'"street": "' + oJson['street'] + '",'
cBody += 		'"number": ' + oJson['number'] + ','
cBody += 		'"complement": "' + oJson['complement'] + '",'
cBody += 		'"neighborhood": "' + oJson['neighborhood'] + '",'
cBody += 		'"city": "' + oJson['city'] + '",'
cBody += 		'"state": "' + oJson['state'] + '",'
cBody += 		'"country": "' + oJson['country'] + '",'
cBody += 		'"zipCode": "' + oJson['zipCode'] + '"'
cBody += 		'}'
cBody += '}'
oClient:SetPostParams(cBody)	

If oClient:Post(aHeader)
	lRet 	:= .T.
Else
	cErrInt := oClient:GetResult()
EndIf

Return lRet

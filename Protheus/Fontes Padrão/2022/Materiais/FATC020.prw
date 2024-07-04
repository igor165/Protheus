#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FATC020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATC020   บAutor  ณVendas CRM          บ Data ณ  17/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para visualizacao dos processos de venda e a dis- บฑฑ
ฑฑบ          ณtribuicao das oportunidades por estagio.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAFAT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATC020(cVend)          

Local aCoors 				:= FWGetDialogSize(oMainWnd)
Local aCbxResA 			:= {STR0032,STR0001,STR0002} //"Funil"###"Pizza"###"Barras"
Local aCbxResB 			:= {STR0004, STR0003, STR0005 }//"Valor Total"###"Valor M้dio"###"Quantidade"
Local aSerieSeg			:= {}
Local aSeek				:= {}	
Local aIndex				:= {} 
Local aColsAD1				:= {}	
Local aColumns				:= {}	  
Local oDlg					:= Nil
Local oLayer				:= Nil
Local oPanelCombo			:= Nil
Local oPanelChart			:= Nil
Local oPanelRight			:= Nil 
Local oPanelLeft			:= Nil 
Local oPanelMaster		:= Nil
Local oFWChart				:= Nil
Local oBrowseUp			:= Nil
Local oBrowseRight		:= Nil
Local oFWChartFactory		:= Nil 
Local oColumn				:= Nil

Local cCbxResA 	    	:= ""
Local cCbxResB 	    	:= ""
Local cQueryAD1			:= "" 
Local cCposAD1				:= ""

Local nCpo					:= 0
Local nX					:= 0

Local cFiltro 				:= ""

Private aRotina 		:= FWLoadMenuDef("FATA010")
Private cCadastro		:= STR0008
	
Default cVend				:= ""

#IFNDEF TOP
	MsgAlert(STR0006) //"Rotina desenvolvida especificamente para ambiente com suporte a banco de dados."
	Return
#ENDIF

Aadd( aSeek, { STR0017, {{"","C",06,0,STR0017,,}} } )	//"C๓digo"
Aadd( aSeek, { STR0018, {{"","C",30,0,STR0018,,}} } )	//"Descri็ใo"

Aadd( aIndex, "AD1_NROPOR" )
Aadd( aIndex, "AD1_DESCRI" )  

//Le colunas utilizadas no browse da tabela AD1
aColsAD1 := FT020Cols("AD1")

//Separa as colunas em uma string para utilizar na SELECT
For nCpo := 1 to Len(aColsAD1)
	cCposAD1 += aColsAD1[nCpo][1]+","
Next nCpo
cCposAD1 := SubStr(cCposAD1,1,Len(cCposAD1)-1) 

DEFINE MSDIALOG oDlg FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL TITLE STR0007 //"Pipeline"

oFWChartFactory := FWChartFactory():New()

//Inicializa o FWLayer
oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

//Adicionando coluna เ primeira linha
oLayer:AddLine('LIN1',40,.F.)
oLayer:addCollumn('COL1',100, .T. ,'LIN1')

//Adicionando colunas เ segunda linha
oLayer:AddLine('LIN2',60,.F.)
oLayer:addCollumn('COL1',50, .F. ,'LIN2')
oLayer:addCollumn('COL2',50, .F. ,'LIN2')

//painel
oPanelMaster	:= oLayer:getColPanel('COL1','LIN1') // Janela de cima - FWMrowse
oPanelLeft		:= oLayer:getColPanel('COL1','LIN2') // Janela de Baixo - Grแfico
oPanelRight	:= oLayer:getColPanel('COL2','LIN2') // Janela de Baixo - Grแfico

DbSelectArea("AC1")
AC1->(DbSetOrder(1))
AC1->(DbSeek(xFilial("AC1")))

cFiltro := " AC1_FILIAL == '" + xFilial("AC1") + "'"

//Criacao do browse de processos de venda
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelMaster )
oBrowseUp:SetDescription( STR0008 ) //"Processos de Venda"
oBrowseUp:DisableDetails()
oBrowseUp:SetAlias( 'AC1' )
oBrowseUp:SetFilterDefault(cFiltro)
oBrowseUp:SetMenuDef('FATA010')
oBrowseUp:bChange := ({||	GerGraf(oFWChartFactory, @oFwChart			, oPanelChart	, cCbxResA		,;
									cCbxResB	   	, AC1->AC1_PROVEN	, @aSerieSeg	, @oBrowseRight	,;
									cVend			, cCposAD1			, oDlg			),;
							Iif(oBrowseRight<>Nil,;
							(oBrowseRight:Deactivate(.T.),;
							oBrowseRight:SetQuery(GetQryAD1(cCposAD1,cVend,AC1->AC1_PROVEN)),;
							oBrowseRight:AddButton(STR0013	,{||FATC020Opo("AD1",2)},,2,,.F.),;
							oBrowseRight:AddButton(STR0014	,{||FATC020Opo("AD1",4)},,4,,.F.),;  
							oBrowseRight:AddButton(STR0015	,{||oDlg:End()},,,,.F.),;
							oBrowseRight:AddButton(STR0019,{||FtC020Leg()},,,,.F.),;  	
							oBrowseRight:Activate()),.T.),;
							.T.})
oBrowseUp:Activate()

//Criacao do browse de oportunidades
cQueryAD1 := GetQryAD1(cCposAD1,cVend,AC1->AC1_PROVEN)

oBrowseRight := FWFormBrowse():New()
oBrowseRight:SetOwner(oPanelRight)
oBrowseRight:SetDataQuery(.T.)
oBrowseRight:SetAlias("AD1TMP") 
oBrowseRight:SetQueryIndex(aIndex)
oBrowseRight:SetQuery(cQueryAD1)
oBrowseRight:SetSeek(,aSeek) 
oBrowseRight:SetDescription( STR0009 ) //"Oportunidades de Venda"
oBrowseRight:SetMenuDef("")
oBrowseRight:DisableDetails()

//Adiciona as bot๕es do Browse                                                   
oBrowseRight:AddButton(STR0013	,{||FATC020Opo("AD1",2)},,2,,.F.)	//"Visualizar"
oBrowseRight:AddButton(STR0014	,{||FATC020Opo("AD1",4)},,4,,.F.)	//"Alterar" 
oBrowseRight:AddButton(STR0015	,{||oDlg:End()},,,,.F.)	   		//"Sair" 

oBrowseRight:AddButton(STR0019,{||FtC020Leg()},,,,.F.) 			//"Legenda"

         

AAdd(aColumns,FWBrwColumn():New())
aColumns[1]:SetData( &("{|| FtC020LPVB(AD1TMP->AD1_NROPOR, AD1TMP->AD1_REVISA)}") ) 
aColumns[1]:SetTitle("") 
aColumns[1]:SetPicture("@BMP")  
aColumns[1]:SetType("C")
aColumns[1]:SetDoubleClick({|| FtR020LPV() })
aColumns[1]:SetSize(1) 
aColumns[1]:SetDecimal(0)
aColumns[1]:SetImage(.T.) 

AAdd(aColumns,FWBrwColumn():New())
aColumns[2]:SetData( &("{|| FtC020LEVB(AD1TMP->AD1_NROPOR, AD1TMP->AD1_REVISA) }") ) 
aColumns[2]:SetTitle("") 
aColumns[2]:SetPicture("@BMP")  
aColumns[2]:SetType("C")  
aColumns[2]:SetDoubleClick({|| FtR020LEV() })
aColumns[2]:SetSize(1) 
aColumns[2]:SetDecimal(0)
aColumns[2]:SetImage(.T.) 

//Adiciona colunas
nX := 2
	
For nCpo := 1 to Len(aColsAD1)
	If aColsAD1[nCpo][1] == "AD1_FILIAL"
		Loop   
	ElseIf aColsAD1[nCpo][1] == "AD1_DTINI"
		AAdd(aColumns,FWBrwColumn():New())
   		nX++ 
		aColumns[nX]:SetData( &("{|| sTod(AD1_DTINI) }") ) 
   		aColumns[nX]:SetTitle(aColsAD1[nCpo][2]) 
		aColumns[nX]:SetSize(aColsAD1[nCpo][3]) 
		aColumns[nX]:SetDecimal(aColsAD1[nCpo][4]) 
		Loop				
	ElseIf aColsAD1[nCpo][1] == "AD1_STATUS"
		AAdd(aColumns,FWBrwColumn():New())
   		nX++ 
		aColumns[nX]:SetData( &("{|| X3Combo('AD1_STATUS',AD1TMP->AD1_STATUS)}") ) 
   		aColumns[nX]:SetTitle(aColsAD1[nCpo][2]) 
		aColumns[nX]:SetSize(aColsAD1[nCpo][3]) 
		aColumns[nX]:SetDecimal(aColsAD1[nCpo][4]) 
		Loop
	EndIf 
	
	AAdd(aColumns,FWBrwColumn():New())
	nX++
	aColumns[nX]:SetData( &("{||"+aColsAD1[nCpo][1]+"}") ) 
	aColumns[nX]:SetTitle(aColsAD1[nCpo][2]) 
	aColumns[nX]:SetSize(aColsAD1[nCpo][3]) 
	aColumns[nX]:SetDecimal(aColsAD1[nCpo][4]) 
Next nCpo

oBrowseRight:SetColumns(aColumns)

//Ativa็ใo do Browse
oBrowseRight:Activate()

//Painel das combos 
oPanelCombo	:= tPanel():New(00,00,"",oPanelLeft,,,,,,0,14)
oPanelCombo:Align := CONTROL_ALIGN_TOP

//Painel do grafico
oPanelChart	:= tPanel():New(10,00,"",oPanelLeft,,,,,,0,(oPanelLeft:nClientHeight - oPanelCombo:nClientHeight)/2 )
oPanelChart:Align := CONTROL_ALIGN_BOTTOM

//Cria็ใo do Combo Box
@ 04, 05 Say STR0010 Size 050, 008 Pixel Of oPanelCombo //"Tipo de Grแfico"
@ 02, 55 ComboBox cCbxResA Items aCbxResA Size 055, 010 Pixel Of oPanelCombo;
	On Change (	cCbxResA := cValToChar( aScan( aCbxResA, cCbxResA ) ),;
				GerGraf(oFWChartFactory, @oFwChart			, oPanelChart 	, cCbxResA		,;
						cCbxResB		, AC1->AC1_PROVEN 	, @aSerieSeg	, @oBrowseRight	,;
						cVend			, cCposAD1			, oDlg			))

//Cria็ใo do Combo Box
//Tipo de Valor
@ 04, 160 Say STR0011 Size 060, 008 Pixel Of oPanelCombo //"Crit้rio"
@ 02, 195 ComboBox cCbxResB Items aCbxResB Size 065, 010 Pixel Of oPanelCombo;
	On Change (	cCbxResB := cValToChar( aScan( aCbxResB, cCbxResB ) ),;
				GerGraf( oFWChartFactory, @oFwChart 		, oPanelChart 	, cCbxResA		,;
						 cCbxResB		, AC1->AC1_PROVEN 	, @aSerieSeg	, @oBrowseRight	,;
						 cVend			, cCposAD1			, oDlg			))

cCbxResA := cValTochar( aScan( aCbxResA, cCbxResA ) )
cCbxResB := cValToChar( aScan( aCbxResB, cCbxResB ) )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( GerGraf( 	oFWChartFactory	, @oFwChart 		, oPanelChart	, cCbxResA		,;
													cCbxResB		, AC1->AC1_PROVEN 	, @aSerieSeg	, @oBrowseRight	,;
													cVend			, cCposAD1			, oDlg			))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerGraf   บAutor  ณVendas CRM          บ Data ณ  17/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do grafico referente a distribuicao de oportunidadesบฑฑ
ฑฑบ          ณpor estagio do processo de vendas.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GerGraf(oFWChartFactory	, oFwChart	, oPanelChart 	, cTpGraf		,;
						cTpValor		, cProcesso , aSerieSeg		, oBrowseRight	,;
						cVend			, cCposAD1	, oDlg			)

Local nX 		:= 0
Local aSeries 	:= {} 
Local cDesc		:= ""  
Local aArea		:= GetArea()
Local lFunil		:= .F.
Local lRet			:= .T.

If oPanelChart == Nil
	Return Nil
EndIf
	
If oFwChart <> NIL
	FreeObj(oFwChart)
Endif       

If cTpGraf == '2'
	oFwChart := oFWChartFactory:getInstance( PIECHART )
ElseIf cTpGraf == '3' 
	oFwChart := oFWChartFactory:getInstance( BARCHART )
ElseIf FindFunction("__FWCFunnel")
	oFwChart := oFWChartFactory:getInstance( FUNNELCHART )
	lFunil := .T.	
Else
	Help("",1, STR0033, , STR0034, 1, )//"Aten็ใo"###"Grแfico de Funil de Vendas indisponํvel. Atualize a LIB com data superior a 14/11/2013."
	lRet :=  .F.
EndIf  

If lRet
	aSeries 	:= Query(cVend,cProcesso,cTpValor)   
	aSerieSeg	:= {}
	
	cDesc := Iif( cTpValor=="1", STR0004, Iif( cTpValor=="2", STR0003, STR0005 ) ) //"Valor Total"###"Valor M้dio"###"Quantidade"
	
	If !lFunil
		oFWChart:init( oPanelChart )
	EndIf
	
	oFWChart:setTitle( STR0016 + " (" + cDesc + ")", CONTROL_ALIGN_CENTER ) //"Oportunidades por fase"
	oFWChart:setLegend( CONTROL_ALIGN_BOTTOM )
	oFWChart:setMask( " *@* " )
	oFWChart:setPicture( "" )
	
	For nX := 1 to Len(aSeries)	
		oFWChart:addSerie( aSeries[nX][1],aSeries[nX][2] )
		aadd(aSerieSeg,{nX,aSeries[nX][3]})
	Next nX
	
	oFwChart:SetSerieAction({ |nSerie| FtC020Refr(	cProcesso	, nSerie	, aSerieSeg	, @oBrowseRight,;
													cVend		, cCposAD1	, oDlg		, oFwChart)})
																								
	If !lFunil
		oFWChart:build()
	Else
	
		oFWChart:oChart:lLabelDesc := .T.  //Exibe descricao no label
		oFWChart:oChart:lLabelValue := .T. //Exibe valor e percentual no label	
		oFWChart:oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
	
		oFWChart:Activate( oPanelChart )
		
	EndIf
EndIf
	
RestArea(aArea)

Return lRet
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFtC020RefrบAutor  ณVendas CRM          บ Data ณ  17/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao do conteudo do FormBrowse, executado ao selecio-บฑฑ
ฑฑบ          ณnar uma serie do grafico                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FtC020Refr(	cProcesso	, nSerie	, aSerieSeg	, oBrowseRight,;
							cVend		, cCposAD1	, oDlg	, oFwChart	)

Local nPos 		:= 0 
Local cQuery	:= ""

If oBrowseRight == Nil
	Return
EndIf

If nSerie <> 0 
	If GetClassName(oFwChart) $ 'FWNCHART|FWCHART' //Se o grแfico for funil
 		nPos := aScan(oFwChart:aSeries,{|x|x:cID == cValToChar(nSerie)})
 	Else 
		nPos := aScan(aSerieSeg,{|x|x[1] == nSerie})
	EndIf
EndIf

If 	nPos > 0	
	cQueryAD1 := GetQryAD1(cCposAD1,cVend,cProcesso,aSerieSeg[nPos][2])
Else
	cQueryAD1 := GetQryAD1(cCposAD1,cVend,cProcesso)
EndIf
                                                   
oBrowseRight:Deactivate(.T.)
oBrowseRight:SetQuery(cQueryAD1)
oBrowseRight:AddButton(STR0013	,{||FATC020Opo("AD1",2)},,2,,.F.)	//"Visualizar"
oBrowseRight:AddButton(STR0014	,{||FATC020Opo("AD1",4)},,4,,.F.)	//"Alterar"
oBrowseRight:AddButton(STR0015	,{||oDlg:End()},,,,.F.)	  	 	//"Sair" 
oBrowseRight:AddButton(STR0019,{||FtC020Leg()},,,,.F.)  

oBrowseRight:Activate()
                                                   
Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQuery     บAutor  ณVendas CRM          บ Data ณ  17/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os valores sintetizados para a construcao do graficoบฑฑ
ฑฑบ          ณFWChart, calculando total, media e quantidade.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Query(cVend,cProcesso,cTipo)

Local cQuery 		:= ""
Local cAliTmp		:= GetNextAlias()
Local aRet			:= {}
Local lFtc20SGRA	:= ExistBlock("FATC20SGRA")
Local lRetorno 	:= .T.
 
DbSelectArea("AC2")
DbSetOrder(1)

If !lFtc20SGRA

	Do Case
		Case cTipo == "1"
			//Por valor (1)
			cQuery := "SELECT AD1_STAGE,SUM(AD1_VERBA) AS VALOR"
		Case cTipo == "2"
			//Pela media (2)
			cQuery := "SELECT AD1_STAGE,AVG(AD1_VERBA) AS VALOR"
		Case cTipo == "3"
			//Por quantidade (3)
			cQuery := "SELECT AD1_STAGE,COUNT(*) AS VALOR"
	EndCase 
	
	cQuery += " FROM " + RetSqlName("AD1") + " AD1"  
	cQuery += " INNER JOIN " + RetSqlName("AIJ") + " AIJ ON AIJ_FILIAL = AD1_FILIAL "  
	cQuery += "	AND AIJ_NROPOR = AD1_NROPOR AND AIJ_REVISA = AD1_REVISA	" 
	cQuery += "	AND AIJ_PROVEN = AD1_PROVEN AND AIJ_STAGE = AD1_STAGE	" 
	cQuery += " AND AIJ.D_E_L_E_T_ = ' ' "
	
	If !Empty(cVend)  
		cQuery += " INNER JOIN " + RetSqlName("ADL") + " ADL ON ADL_FILIAL = '"+xFilial("ADL")+"' "
		cQuery += "	AND ADL_VEND = '" + cVend + "' "
		cQuery += "	AND ((ADL_ENTIDA = 'SA1' AND AD1_CODCLI = ADL_CODENT AND AD1_LOJCLI = ADL_LOJENT) OR "
		cQuery += 		" (ADL_ENTIDA = 'SUS' AND AD1_PROSPE = ADL_CODENT AND AD1_LOJPRO = ADL_LOJENT)) AND"
		cQuery += " (ADL_CODOPO = '' AND ADL_CODORC = '' AND ADL_CODPRO = ' ') And"
		cQuery += " ADL.D_E_L_E_T_ = ''"
	EndIf
	
	cQuery += " WHERE AD1_FILIAL = '" + xFilial("AD1") + "' AND AD1_PROVEN = '" + cProcesso + "'  AND AD1.AD1_STATUS NOT IN ('2','9') AND AD1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY AD1_STAGE"
	cQuery += " ORDER BY AD1_STAGE"

Else

	cQuery := Execblock("FATC20SGRA",.F.,.F.,{cVend,cProcesso,cTipo})
	
	If ValType(cQuery) <> "C"
		lRetorno := .F.
	EndIf
	
EndIf

If lRetorno 
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp,.T.,.T.)
	
	While !(cAliTmp)->(Eof())
		AC2->(DbSeek( xFilial("AC2") + cProcesso + (cAliTmp)->AD1_STAGE ))
		AAdd(aRet, { AllTrim(Capital(AC2->AC2_DESCRI)), (cAliTmp)->VALOR, (cAliTmp)->AD1_STAGE } )
		(cAliTmp)->(DbSkip())
	End
	
	(cAliTmp)->(DbCloseArea())
	
EndIf
	
Return aRet
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetQryAD1 บAutor  ณVendas CRM          บ Data ณ  20/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna uma query para selecao dos campos da tabela AD1,    บฑฑ
ฑฑบ          ณrespeitando as contas visiveis ao representante, de acordo  บฑฑ
ฑฑบ          ณcom o estagio/processo selecionado na consulta.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetQryAD1(cCposAD1,cVend,cProcesso,cEstagio)

Local cQuery 		:= "" 
Local lFtc20AD1	:= ExistBlock("FATC20AD1")

Default cProcesso	:= ""                                                                                        
Default cEstagio	:= ""

If !lFtc20AD1

	cQuery += "SELECT DISTINCT " + cCposAD1 + ", AD1_DTPENC, AD1_HRPENC "
	cQuery += " FROM " + RetSqlName("AD1") + " AD1"
	cQuery += " INNER JOIN " + RetSqlName("AIJ") + " AIJ ON AIJ_FILIAL = AD1_FILIAL "  
	cQuery += "	AND AIJ_NROPOR = AD1_NROPOR AND AIJ_REVISA = AD1_REVISA	" 
	cQuery += "	AND AIJ_PROVEN = AD1_PROVEN AND AIJ_STAGE = AD1_STAGE	" 
	cQuery += " AND AIJ.D_E_L_E_T_ = ' ' "
	         
	If !Empty(cVend)
		cQuery += " INNER JOIN " + RetSqlName("ADL") + " ADL ON ADL_FILIAL = '"+xFilial("ADL")+"' "
		cQuery += "	AND ADL_VEND = '" + cVend + "' "
		cQuery += "	AND ((ADL_ENTIDA = 'SA1' AND AD1_CODCLI = ADL_CODENT AND AD1_LOJCLI = ADL_LOJENT) OR "
		cQuery += 		" (ADL_ENTIDA = 'SUS' AND AD1_PROSPE = ADL_CODENT AND AD1_LOJPRO = ADL_LOJENT)) AND"
		cQuery += " ADL.D_E_L_E_T_ = ''"	
	EndIf
	 
	cQuery += " WHERE AD1_FILIAL = '" + xFilial("AD1") + "'"
	
	If !Empty(cProcesso)
		cQuery += " AND AD1_PROVEN = '" + cProcesso + "'" 
		If !Empty(cEstagio)
			cQuery += " AND AD1_STAGE = '" + cEstagio + "'" 
		EndIf
	EndIf
	
	cQuery += " AND AD1.D_E_L_E_T_ = '' AND AD1_STATUS NOT IN ('2','9')"
	cQuery += " ORDER BY AD1_NROPOR"

Else
	
	cQuery := Execblock("FATC20AD1",.F.,.F.,{cCposAD1,cVend,cProcesso,cEstagio}) 
	
	If ValType(cQuery) <> "C"
		cQuery := ""
	EndIf	
	
EndIf  
	
Return cQuery  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATC020OpoบAutor  ณVendas CRM          บ Data ณ  17/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a rotina de manutencao de oportunidades, preparando บฑฑ
ฑฑบ          ณas variaveis private e posicionando a tabela AD1            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATC020Opo(cAlias,nOpcX)

DbSelectArea("AD1")
DbSetOrder(1)

If DbSeek(xFilial("AD1")+AD1TMP->AD1_NROPOR+AD1TMP->AD1_REVISA)
	If nOpcX == 2
		FWExecView(Upper(STR0014),"VIEWDEF.FATA300",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)                      
	ElseIf nOpcX == 4
		FWExecView(Upper(STR0014),"VIEWDEF.FATA300",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	EndIf                      
EndIf 

Return Nil         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFT020Cols บAutor  ณVendas CRM          บ Data ณ  21/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os nomes das colunas utilizadas pelo Browse da tabe-บฑฑ
ฑฑบ          ณla informada                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FT020Cols(cTab)

Local aArea		:= GetArea()
Local aCampos 	:= {}
Local cCampo	:= ""

DbSelectArea("SX3")
DbSetOrder(1)
Dbseek(cTab)

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cTab 
	cCampo := AllTrim(SX3->X3_CAMPO)
	If (X3USO(SX3->X3_USADO) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M") .OR. (cCampo $ "AD1_FILIAL/AD1_NROPOR/AD1_VEND/AD1_PROVEN/AD1_STAGE")
		AAdd(aCampos,{ cCampo, X3Titulo(), SX3->X3_TAMANHO, SX3->X3_DECIMAL })
	EndIf
	SX3->(DbSkip())
End

RestArea(aArea)

Return aCampos 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FtC020LPVB

Legenda do processo de venda.

@sample 	FtC020LPVB(cOportu,cRevisa) 

@param		ExpC1 - Oportunidade	
			ExpC2 - Revisao
			
@return	ExpC - Legenda 

@author	Anderson Silva
@since		21/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function FtC020LPVB(cOportu,cRevisa) 

Local aArea	 := GetArea()     		// Area da tabela atual
Local aAreaAD1 := AD1->(GetArea())	// Area	da tabela AD1 
Local cLegenda := "BR_VERDE"   		// Legenda.   

DbSelectArea("AD1")
DbSetOrder(1)

If DbSeek(xFilial("AD1")+cOportu+cRevisa)
	If AD1->AD1_STATUS $ "1|3"
   		cLegenda := Ft300LPVBr() 
   	EndIf	
EndIf

RestArea(aAreaAD1)
RestArea(aArea)
                    
Return(cLegenda) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FtC020LEVB

Legenda da Evolucao da Venda

@sample 	FtC020LEVB(cOportu,cRevisa)

@param		ExpC1 - Oportunidade	
			ExpC2 - Revisao
			
@return	ExpC - Legenda

@author	Anderson Silva
@since		21/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function FtC020LEVB(cOportu,cRevisa)

Local aArea	 := GetArea()     		// Area da tabela atual
Local aAreaAD1 := AD1->(GetArea())	// Area da tabela AD1 
Local cLegenda := "BR_VERDE"   		// Legenda.   

DbSelectArea("AD1")
DbSetOrder(1)

If DbSeek(xFilial("AD1")+cOportu+cRevisa)
	cLegenda := Ft300LEVBr() 
EndIf

RestArea(aAreaAD1)
RestArea(aArea)

Return(cLegenda)

//------------------------------------------------------------------------------
/*/{Protheus.doc} FtC020Leg

Legenda da evolucao da venda (Interface).

@sample 	FtC020Leg()

@param		Nenhum

@return		ExpL Verdadeiro 

@author		Anderson Silva
@since		21/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function FtC020Leg()

Local aLegendas	:= {}
Local aCores 	:= {	{"BR_VERDE"	  	,STR0020}	,;		// "Em dia"
						{"BR_AMARELO" 	,STR0021}	,;	 	// "Em alerta" 		
						{"BR_VERMELHO"	,STR0022}  	}   	// "Em atraso"
		   				
AAdd(aLegendas,{STR0023,aCores})  			 				// "Processo de Venda"
AAdd(aLegendas,{STR0024,aCores})							// "Evolu็ใo de Venda"

FtC020BrwL(STR0025,aLegendas)  						   		// "Legendas"

Return( .T. )



//------------------------------------------------------------------------------
/*/{Protheus.doc} FtR020LPV

Legenda do processo de venda (Interface).

@sample 	FtR020LPV()

@param		Nenhum

@return		ExpL Verdadeiro 

@author		Anderson Silva
@since		21/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function FtR020LPV()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add("","BR_VERDE"   ,STR0026) 		// "Processo de vendas em dia."
oLegenda:Add("","BR_AMARELO" ,STR0027)  	// "Processo de vendas em alerta."
oLegenda:Add("","BR_VERMELHO",STR0028) 		// "Processo de vendas em atraso." 

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} FtR020LE

Legenda da evolucao da venda (Interface).

@sample 	FtR020LE()

@param		Nenhum

@return		ExpL Verdadeiro 

@author		Anderson Silva
@since		21/05/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function FtR020LEV()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add("","BR_VERDE"   ,STR0029) 	   	// "Evolu็ใo da venda em dia."
oLegenda:Add("","BR_AMARELO" ,STR0030)  	// "Evolu็ใo da venda em alerta."
oLegenda:Add("","BR_VERMELHO",STR0031) 		// "Evolu็ใo da venda em atraso." 
                                                             
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBrwLegendaบAutor  ณVendas CRM          บ Data ณ  21/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibicao de legendas especifica, para exibir 2 tipos de     บฑฑ
ฑฑบ          ณlegendas na mesma tela                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATC020                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FtC020BrwL(cTitulo,aLegendas)

Local nY       				:= 0
Local nX       				:= 0
Local nZ       				:= 0
Local nGrupo				:= 0
Local nSizeAdic				:= 5
Local nQtdLegs				:= 0
Local nLinha				:= 0
Local aBmp
Local oDlgLeg               

For nX := 1 to Len(aLegendas)
	nQtdLegs := Len(aLegendas[nX][2])
	nSizeAdic += 50 + (nQtdLegs * 20)
Next nX

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO nSizeAdic + 10,320 TITLE cTitulo OF oMainWnd PIXEL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNo onclick do usuario a tela sera fechadaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlgLeg:bLClicked:= {||oDlgLeg:End()}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFonte especifico para a descricao das legendasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesenho de fundoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
	
	nLinha := 3

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTitulo da legendaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nGrupo := 1 to Len(aLegendas)
		
		aBmp  := Array(Len(aLegendas[nGrupo][2]))

		@nLinha,37 SAY If((nZ+=1)==nZ,aLegendas[nZ][1]+If(nY==Len(aLegendas),If((nZ:=0)==nZ,"",""),""),"") SIZE 100,9 FONT oBold OF oDlgLeg PIXEL		
		nLinha += 8
		@nLinha,35 TO nLinha+2,400 LABEL '' OF oDlgLeg PIXEL
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณItens da legendaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	   	For nX := 1 to Len(aLegendas[nGrupo][2])   
		                         
			nLinha += 10

			@ nLinha,43 BITMAP aBmp[nX] RESNAME aLegendas[nGrupo][2][nX][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER 
			@ nLinha,53 SAY If((nY+=1)==nY,aLegendas[nZ][2][nY][2]+If(nY==Len(aLegendas[nZ][2]),If((nY:=0)==nY,"",""),""),"") SIZE 100,9 OF oDlgLeg PIXEL

		Next nX

		nY := 0		
		nLinha += 15
		
	Next nGrupo
	nZ := 0

ACTIVATE MSDIALOG oDlgLeg CENTERED

Return(NIL)


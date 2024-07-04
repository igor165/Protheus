#INCLUDE "PLSMPROM.ch"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBROWSE.CH'

/*/{Protheus.doc} PLSMPROM
Tela de Movimentação da Promoção da Saude

@author Rogério Tabosa
@since 20/09/2012
@version P11
/*/
//-------------------------------------------------------------------
Function PLSMPROM()

Local aSize		:= {}										//Array com o tamnho da tela
Local oFWLayer   											//Layer
Local oPLUp													// Painel Superior da Esquerda
Local oPRUp													// Painel Superior da Direita
Local oPMiddle												// Painel Central

Static oBrwBOA												//Browse dos programas
Static oBrwBOS												//Browse dos alertas
Static oMBrwBOM												//Mark Browse dos Elegiveis

Local cTitulo 	:= ""									//Variavel com o Titulo da Dialog
Local oDlgPRO
Local aHeadBOA	:= {}
Local aStruct	:= {}
Local oChart
Local aTitles   := {}

Local cAno		:= Substr(DTOC(dDataBase),7,4)
Local cMes		:= StrZero(Month(dDataBase),2)
Local dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Local dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nHRes	:=	oMainWnd:nClientWidth
Private cCodProg	:= ""										//Variavel com o codigo do programa selecionado
Private cVidaSel	:= ""
Private nLinAtu		:= 0
Private aColsBOA	:= {}
Private cCadastro 	:= STR0001 //"Movimentação Promoção da Saúde"
Private lOutModel	:= .T. 									//Variavel utilizada na consulta de RISCO
Private cRetRis		:= ""
Private cIndInd		:= "" 
Private cFilBOA		:= ""										// Indicador Individual do programa										

aSize := FWGetDialogSize( oMainWnd )

DEFINE MSDIALOG oDlgPRO TITLE STR0001	FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL  //"Movimentação Promoção à Saúde"

// Layer Auxiliar
oFwLayerAux := FwLayer():New()
oFwLayerAux:Init(oDlgPRO,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Inicializa o FWLayer		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFwLayer := FwLayer():New()
oFwLayer:Init(oDlgPRO,.F.)


oFwLayerAux:addLine("LinAux1", 43, .F.) 
oFwLayerAux:addLine("LinAux2", 30, .F.) 
oFwLayerAux:addLine("LinAux3", 27, .F.) 
oFwLayerAux:addCollumn( "ColAux1",33, .T. , "LinAux2")
oFwLayerAux:addCollumn( "ColAux2",34, .T. , "LinAux2")
oFwLayerAux:addCollumn( "ColAux3",33, .T. , "LinAux2")
oPnlPainel := oFwLayerAux:GetColPanel( 'ColAux2', "LinAux2" ) 
// Fim Layer Auxiliar

 /*
oChart := FWChartLine():New()
oChart:init( oPnlPainel, .t. ) 
oChart:addSerie( "Votos PT", { {"Jan",50}, {"Fev",55}, {"Mar",60} })
oChart:addSerie( "Votos PMDB", { {"Jan",30}, {"Fev",35}, {"Mar",40} } )
oChart:addSerie( "Votos PV", { {"Jan",20}, {"Fev",10}, {"Mar",10} } ) 
oChart:setLegend( CONTROL_ALIGN_LEFT ) 
oChart:Build()*/
 


//oTButton1 := TButton():New( 002, 001, "TESTE" ,oPnlPainel,{||},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )																			
//Button2 := TButton():New( 050, 001, "TESTE2" ,oPMiddle,{||},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Cria o Layer Superior	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ //If lR7
oFWLayer:addLine("UpProgramas", If(nHRes<=1152, 50,40), .F.) //layer superior Programas e Alertas
oFWLayer:addCollumn( "GridLeft",75, .T. , "UpProgramas") 	//Coluna Grid dos Programas
oFWLayer:addCollumn( "GridRight",25, .T. , "UpProgramas") 	//Coluna Grid dos Alertas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Cria o Layer Central		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFWLayer:addLine("MidElegiveis", If(nHRes<=1152, 50,60), .F.) //layer do meio Folders e Browse de Elegiveis

oPLUp 	 	:= oFWLayer:GetColPanel( 'GridLeft', "UpProgramas" ) // Obj Panel GRID Programas
oPRUp  	:= oFWLayer:GetColPanel( 'GridRight', "UpProgramas" )// Obj Panel GRID Alertas
oPMiddle	:= oFWLayer:GetLinePanel( 'MidElegiveis' ) // Objeto Panel central

oDlgPRO:lMaximized := .T. //Janela maximizada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	MBrowse da dos programas cadastrados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

cAlias 	:= "BOA"
cFilBOA 	:= "BOA_FILIAL == '" + xFilial("BOA") + "' .AND. BOA_ATIVO == '1' "

aCampos :={ "BOA_CODPRO", "BOA_DESPRO"}
dbselectarea("SX3")
nI :=1
cTitulo := Alltrim(RetTitle(aCampos[nI]))
aadd(aHeadBOA,{cTitulo,{ |X| BOA->BOA_CODPRO },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
nI :=2
cTitulo := Alltrim(RetTitle(aCampos[nI]))
aadd(aHeadBOA,{cTitulo,{ |X| BOA->BOA_DESPRO },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})

oBrwBOA := FWMBrowse():New()
oBrwBOA:SetOwner(oPLUp)
oBrwBOA:SetDescription("Programas de Saúde") //oBrwBOA:SetFieldMark( 'BOA_IDMARK' ) //"Programas de Saúde"
oBrwBOA:SetAlias(cAlias)
oBrwBOA:SetFilterDefault("BOA_FILIAL == '" + xFilial("BOA") + "' .AND. BOA_ATIVO == '1' ")
oBrwBOA:DisableDetails()
oBrwBOA:DisableConfig()
//oBrwBOA:DisableFilter()
oBrwBOA:DisableLocate()
///oBrwBOA:DisableSeek()
oBrwBOA:DisableReport()
oBrwBOA:SetAmbiente(.F.)
oBrwBOA:SetWalkThru(.F.)
oBrwBOA:SetMenuDef("PLSPRO01")
oBrwBOA:SetBlkBackColor( {|| CLR_WHITE } )//"#D6E4EA"
//oBrwBOA:SetChange({|| Conout("Programa Selecionado: " + BOA->BOA_CODPRO)}) //cOnOUT("Registro: " + Alltrim(Str(oBrwBOA:At()))) nLinAtu := oBrwBOA:At() 
oBrwBOA:SetDoubleClick ( {|| PProLoadPrg()} )
oBrwBOA:Activate()

/*
@ 010,05  REPOSITORY oBmp SIZE 105,105  of oPRUp Pixel
oBmp:lAutoSize := .T. // Para permitir stretch
oBmp:LoadBmp(BOA->BOA_BITMAP)*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ALERTAS                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilter := "BOS_FILIAL == '" + xFilial("BOS") + "' .AND. BOS_STATUS == '0' "
cFilter += " .AND. BOS_DATSIN >= " + PPrMenosDT(dDataBase,30) + " " // 1 mês
//	oMBrwBOM:SetFilter ( "BOM_DTELEG", DTOC(MV_PAR02), DTOC(MV_PAR01 ))

oBrwBOS := FWMBrowse():New()
oBrwBOS:SetOwner(oPRUp)
oBrwBOS:SetDescription(STR0002) //oBrwBOA:SetFieldMark( 'BOA_IDMARK' ) // *Alertas Gerais"
oBrwBOS:SetAlias("BOS")
oBrwBOS:SetFilterDefault(cFilter)
oBrwBOS:DisableDetails()
//oBrwBOS:DisableConfig()
//oBrwBOS:DisableFilter()
oBrwBOS:DisableLocate()
//oBrwBOS:DisableSeek()
oBrwBOS:DisableReport()
oBrwBOS:SetAmbiente(.F.)
oBrwBOS:SetWalkThru(.F.)
oBrwBOS:SetMenuDef("")
oBrwBOS:SetBlkBackColor( {|| CLR_WHITE } )//"#D6E4EA"
oBrwBOS:AddLegend( "BOS_STATUS == '0' ", "RED"		, STR0003	,,.F. ) //"Pendente"
oBrwBOS:AddLegend( "BOS_STATUS == '1' ", "GREEN"		, STR0004,,.F. ) //"Processado"
//oBrwBOS:SetChange({|| Conout("Programa Selecionado: " + BOA->BOA_CODPRO)}) //cOnOUT("Registro: " + Alltrim(Str(oBrwBOA:At()))) nLinAtu := oBrwBOA:At()
oBrwBOS:SetDoubleClick ( {|| IIf(AxVisual("BOS", BOS->(Recno()),2)==1,PProcAlert(BOS->(Recno())),Nil)} )
oBrwBOS:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	MBrowse da dos pacientes elegiveis/inscritos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
DbSelectArea("BOM")
cAlias := "BOM"
cFilter := "BOM_FILIAL == '" + xFilial("BOM") + "' .AND. BOM_CODPRO == '" + cCodProg + "'"

oMBrwBOM:= FWMarkBrowse():New()
oMBrwBOM:SetAlias(cAlias)
oMBrwBOM:SetMenuDef("PLSMPROM")
oMBrwBOM:SetFieldMark( 'BOM_IDMARK' )
oMBrwBOM:SetDescription(STR0005) //"Elegiveis/Inscritos"
oMBrwBOM:SetFilterDefault(cFilter)
oMBrwBOM:SetOwner(oPMiddle)
//oMBrwBOM:DisableDetails()
//oMBrwBOM:DisableLocate()
oMBrwBOM:SetWalkThru(.F.) 
oMBrwBOM:SetAmbiente(.F.)
oMBrwBOM:ForceQuitButton()
oMBrwBOM:AddLegend( "BOM_STATUS == '0' ", "BLUE"	, STR0006	,,.F. ) //"Paciente Elegivel"
oMBrwBOM:AddLegend( "BOM_STATUS == '1' ", "YELLOW"	, STR0007	,,.F. ) //"Paciente Inscrito"
oMBrwBOM:AddLegend( "BOM_STATUS == '2' ", "GREEN"	, STR0008	,,.F. ) //"Programa concluído"
oMBrwBOM:AddLegend( "BOM_STATUS == '3' ", "RED"		, STR0009	,,.F. ) //"Possui Pendencias"
oMBrwBOM:AddLegend( "BOM_STATUS == '4' ", "GRAY"	, STR0010	,,.F. )     //"Cadastro Bloqueado"
oMBrwBOM:Activate()

oMBrwBOM:Disable()

oTimer := TTimer():New(30000, {|| PProRefresh() }, oDlgPRO ) // Disparo será de 30 segundos   
oTimer:Activate()

Activate MsDialog oDlgPRO Centered

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ MenuDef ³ Autor ³ Totvs                  ³ Data ³ 21/09/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ MenuDef													  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotRel :=		{{OemtoAnsi(STR0046), "PMPROCALL(14)", 0, 02}}//"Docs/Relat"
PRIVATE aRotina := {}      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Opcoes de menu															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

AaDd( aRotina, { STR0011, 			"VIEWDEF.PLSMPROM", 0, MODEL_OPERATION_VIEW } ) //"Visualizar"
AaDd( aRotina, { STR0040,	"VIEWDEF.PLSMPROM", 0, MODEL_OPERATION_INSERT} ) //"Incluir Eleg."
AaDd( aRotina, { STR0012, 			"VIEWDEF.PLSMPROM", 0, MODEL_OPERATION_UPDATE} ) //"Alterar"
AaDd( aRotina, { STR0041,			"PLSMOVDEL()" , 0, 9, 0, NIL } ) //"Excluir"
AaDd( aRotina, { STR0013,			"PMPROCALL(10)" , 0, 9, 0, NIL } ) //"Incluir Prog."
aAdd( aRotina, { STR0014,			"PMPROCALL(1)"	, 0, 9, 0, NIL } ) //"Dados Cadastrais"
aAdd( aRotina, { STR0015,			"PMPROCALL(2)"	, 0, 9, 0, NIL } ) //"E-mail/SMS"
aAdd( aRotina, { STR0016,			"PMPROCALL(3)"	, 0, 9, 0, NIL } ) //"Contato Tel."
aAdd( aRotina, { STR0017,			"PMPROCALL(4)"	, 0, 9, 0, NIL } ) //"Alta do Prog."
aAdd( aRotina, { STR0018,			"PMPROCALL(5)"	, 0, 9, 0, NIL } ) //"Planejamento"
//aAdd( aRotina, { "Mov. Auditoria","PMPROCALL(6)"	, 0, 9, 0, NIL } )
aAdd( aRotina, { STR0019,			"PMPROCALL(7)"	, 0, 9, 0, NIL } ) //"Alertas"
aAdd( aRotina, { STR0020,  			"PMPROCALL(8)"	, 0, 9, 0, NIL } ) //"Ind. Individual"
aAdd( aRotina, { STR0042,	"PMPROCALL(11)"	, 0, 9, 0, NIL } ) //"Transf. Local"
aAdd( aRotina, { STR0043,	"PMPROCALL(12)"	, 0, 9, 0, NIL } ) //"Historico de Risco/Setor."
aAdd( aRotina, { STR0044,	"PMPROCALL(13)"	, 0, 9, 0, NIL } ) //"Brindes da Campanha"
aAdd( aRotina, { STR0045,			aRotRel	, 0, 9, 0, NIL } )
aAdd( aRotina, { STR0048,	"PMPROCALL(15)"	, 0, 9, 0, NIL } ) //"Anal.Sinistro"
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novos itens no menu aRotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLSPROM1")
	aRotinaNew := ExecBlock("PLSPROM1",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aRotina  

//---------------------------------------------------------------------------
//ModelDef de inclusão de pacientes no programa									|
//---------------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBOM := FWFormStruct( 1, 'BOM', /*bAvalCampo*/, /*lViewUsado*/ )
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0038, /*bPreValidacao*/, {|oModel|PMGRVBOK(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) //'Elegiveis/Inscritos'
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BOMMASTER', NIL, oStruBOM )
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0038 ) //'Elegiveis/Inscritos'
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BOMMASTER' ):SetDescription( STR0038 ) //'Elegiveis/Inscritos'
Return oModel

//---------------------------------------------------------------------------
//ViewDef de inclusão de pacientes no programa									|
//---------------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruBOM := FWFormStruct( 2, 'BOM' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'PLSMPROM' )
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BOM' , oStruBOM, 'BOMMASTER'   )
oView:EnableTitleView( 'VIEW_BOM' )
// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_BOM', 'BOM_NROSEQ' )
 Return oView  


//---------------------------------------------------------------------------
//ProLoadPrg - Carrega os dados do programa selecionado							|
//Alimenta Lista de Pacientes, Indicadores, Campanhas							|
//---------------------------------------------------------------------------
Function PProLoadPrg()
Local aArea	:= getArea()
Local nRecP1  := 0
Local aPnl1	  := {}
Local nI		:= 0
local 	oGraph
Local aStPerg := {".AND. BOM_STATUS == '0'",; 							//Elegiveis
				  ".AND. (BOM_STATUS == '3' .OR. BOM_STATUS == '4')",;	//Pendencia/Bloq
				  ".AND. BOM_STATUS == '1'",; 							//Inscritos
				  ".AND. BOM_STATUS == '2'",; 							//Concluido
				  ""} 													//Todos

// Variaveis de APOIO para utilização nas expressões dos indicadores
Private cAno		:= Substr(DTOC(dDataBase),7,4)
Private cMes		:= StrZero(Month(dDataBase),2)
Private cMesAnt  	:= IIf(cMes == "01", "12", StrZero(Val(cMes)-1,2))
Private cAnoAnt	    := Iif(cMesAnt == "12",Str(Val(cAno)-1),cAno)                           
Private dDtIniDAn	:= CTOD("01/"+cMesAnt+"/"+cAnoAnt)
Private dDtFimDAn	:= CTOD(StrZero(F_ULTDIA(dDtIniDAn),2)+"/"+cMesAnt+"/"+cAnoAnt)
Private cDatIniAn	:= DTOS(dDtIniDAn)
Private cDatFimAn	:= DTOS(dDtFimDAn)
Private dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Private dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Private dDataIniA	:= CTOD("01/01/"+cAno)
Private dDataFimA   := CTOD("31/12/"+cAno)


If !Pergunte("PMPRO01",.T.)
	Return()
EndIf

If cCodProg <> BOA->BOA_CODPRO
	oMBrwBOM:Enable()
EndIf
cCodProg:= BOA->BOA_CODPRO
cIndInd	:= BOA->BOA_INDIND	
cFilter := "BOM_FILIAL == '" + xFilial("BOM") + "' .AND. BOM_CODPRO == '" + cCodProg + "'"
If oGraph <> Nil
	FreeObj(oGraph)
EndIf
If !Empty(BOA->BOA_INDPRI)
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA")  + BOA->BOA_INDPRI) .AND. Alltrim(GTA->GTA_TIPOIN) $ "23"		
		nRecP1 := GTA->(Recno())
		aPnl1 := HSPPO020(nRecP1, .F.)                      
		If GTA->GTA_TIPOIN == "2"
		   	oGraph := FWChartPie():New()
		Else
		   	oGraph := FWChartBar():New()		   	
		EndIf
	   	oGraph:init( oPnlPainel, .T. ,.T.)  
	   	
		For nI := 1 to Len(aPnl1[3,1])			
			oGraph:addSerie( Substr(Alltrim(aPnl1[3,1,nI]),1,12), aPnl1[5,1,nI] )  
			oGraph:SetTitle(Alltrim(GTA->GTA_TITULO),1 )
		Next nI
		oGraph:setLegend( CONTROL_ALIGN_LEFT ) 
		oGraph:Build()			
	EndIf
EndIf

If !Empty(MV_PAR01)
	cFilter += " .AND. BOM_DTELEG >= '" + DTOS(MV_PAR01) + "' "
//	oMBrwBOM:SetFilter ( "BOM_DTELEG", DTOC(MV_PAR02), DTOC(MV_PAR01 ))
EndIf 
If !Empty(MV_PAR02)
	cFilter += " .AND. BOM_DTELEG <= '" + DTOS(MV_PAR02) + "' "
EndIf
If !Empty(MV_PAR03)
	cFilter += " .AND. BOM_DTINSC >= '" + DTOS(MV_PAR03) + "' "
EndIf
If !Empty(MV_PAR04)
	cFilter += " .AND. BOM_DTINSC <= '" + DTOS(MV_PAR04) + "' "
EndIf
cFilter += aStPerg[MV_PAR05]
cFilter += " .AND. BOM_VIP == '" + Alltrim(Str(MV_PAR06-1)) + "'"
If !Empty(MV_PAR07)
	cFilter += " .AND. BOM_CODLOC == '" + MV_PAR07 + "' "
EndIf   
If !Empty(MV_PAR08)
	cFilter += " .AND. BOM_GRARIS == '" + MV_PAR08 + "' "
EndIf 

oMBrwBOM:CleanFilter()
oMBrwBOM:SetFilterDefault(cFilter)
oMBrwBOM:Refresh()
oBrwBOS:Refresh()         
oBrwBOA:SetFilterDefault("BOA_FILIAL == '" + xFilial("BOA") + "' .AND. BOA_ATIVO == '1' ")   
oBrwBOA:Refresh()
//oMBrwBOM:SetFocus()

RestArea(aArea)
BOM->(DbGotop())
Return()

//---------------------------------------------------------------------------
//PMPROCALL - Chamadas externas do MenuDef										|
//---------------------------------------------------------------------------
Function PMPROCALL(nCall) // 1=Dados Cadastrais
// Chamada da visualização do Cadastro da VIDA PLSA955
If nCall == 1 
	BTS->(DbSetOrder(1))	
	BTS->(MsSeek(xFilial("BTS") + BOM->BOM_VIDA))	
	//PLSA955VIS("BTS",BTS->(Recno()),2)
	FWExecView('Vizualizar'	,'PLSA955', MODEL_OPERATION_VIEW	,, { || .T. } )
ElseIf nCall == 2 // EMAIL E WF 
	PMPROSIN()
ElseIf nCall == 3 // CONTATO 
	PMPROCONT(BOM->BOM_VIDA)
ElseIf nCall == 4 // ALTA NO PROGRAMA 
If BOM->BOM_STATUS $ "13" 
	PLSPROALT(BOM->BOM_NROSEQ)
	Else
		HELP('PLSMPROM',, 'PLSMPROM',, "Só é permitida a Alta de Pacientes com Status de Inscritos/Pendencia no Programa!", 1, 0)
	Endif
	
ElseIf nCall == 5 // PLANEJAMENTO
	If BOM->BOM_STATUS $ "13" 
	PLSPRO05(BOM->BOM_VIDA,BOM->BOM_NROSEQ,BOM->BOM_CODPRO,"",BOM->BOM_STATUS)
	Else
		HELP('PLSMPROM',, 'PLSMPROM',, "Só é permitido o Planejamento de Pacientes com Status de Inscritos/Pendencia no Programa!", 1, 0)
	Endif
ElseIf nCall == 7	 // ALERTAS
	PLSPROEXAL(,BOM->BOM_CODPRO, BOM->BOM_VIDA,,BOM->BOM_GRARIS)
ElseIf nCall == 8 // INDICADOR INDIVIDUAL
	cVidaSel := BOM->BOM_VIDA
	If !Empty(cIndInd)
		PProMntGraf(cIndInd)
	Else
		HELP('PLSMPROM',, 'PLSMPROM',, STR0022, 1, 0) //"O Programa não possui indicador individual cadastrado!"
	EndIf	
ElseIf nCall == 10 // INDICADOR INDIVIDUAL
	PPROINCPRO(BOM->BOM_NROSEQ,,,,,,BOM->BOM_STATUS)
ElseIf nCall == 11 // Transferencia de local
	PPTRANSF(BOM->BOM_VIDA,BOM->BOM_NROSEQ,"0")
ElseIf nCall == 12 // Historico alteraçoes
	PMPROHIST(BOM->BOM_NROSEQ)  
ElseIf nCall == 13 //Brindes das Campanhas
//If PLSALIASEX("BO7")
	PMHISTBRIN(BOM->BOM_VIDA,BOM->BOM_CODPRO)
//Else  
//	HELP('PLSMPROM',, 'PLSMPROM',, STR0047, 1, 0)
//Endif
	
ElseIf nCall == 14 // Docs/Relat.
	PLSRPRO04("",BOM->BOM_VIDA)
ElseIf nCall == 15 // Docs/Relat.
	PMHISTSIN(BOM->BOM_VIDA,BOM->BOM_CODPRO,BOM->BOM_DATINI,BOM->BOM_DATFIM,.F.)
EndIf

//aAdd( aRotina, { "Contato Tel.",		"PMPROCALL(3)"	, 0, 9, 0, NIL } )
/*aAdd( aRotina, { "Mov. Auditoria",		"PMPROCALL(6)"	, 0, 9, 0, NIL } )
aAdd( aRotina, { "Docs/Relat.",			"PMPROCALL(8)"	, 0, 9, 0, NIL } )
*/

Return()
//---------------------------------------------------------------------------
//PMPROSIN - Mensagem de sinalização e-mail/SMS para os participantes selec. |
// selecionados no MarkBrowse BOM ou Vindos da função de JOB				   |
//---------------------------------------------------------------------------
Function PMPROSIN(cMatVid, cCodSin, cProgram)
Local aArea 		:= GetArea()
Local cMarca 		:= oMBrwBOM:Mark()
Local aTables		:= {"BTS","BOM","BOA"} // Tabelas com os campos disponiveis
Local aDest		    := {}
Local cMsgErr		:= ""
Local lEnv			:= .F.
Local cTipSin		:= ""    
Local cHtmPad		:= ""
Local cTxtBody	    := ""
Local cMailCP		:= ""
Local aCposEData	:= {}
Local aCposAux	    := {}
Local cTO			:= ""
Local cCC			:= ""
Local cBcc			:= ""
Local lMlBrw		:= .T.
Local lAll			:= .F. // Variavel que indica se o email sera um unico para todos ou um para cada destinatario
Local nI			:= 0

Default cMatVid	    := ""
Default cCodSin	    := ""

lMlBrw := Empty(cMatVid) //Se for chamada de um processo não varre a MarkBrowse 
Default cProgram 	:= If(lMlBrw,cCodProg,"") 

If Empty(cCodSin) // Sinaliza
	If !Pergunte("PMPRO02",.T.)
		Return()
	Else
		cCodSin := MV_PAR01
	EndIf
EndIf


BOJ->(DbSetOrder(1))
If !BOJ->(MsSeek(xFilial("BOJ") + cCodSin))
	If lMlBrw
		ApMsgInfo(STR0023) //"Sinalizador não encontrado!"
	Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0023 , 0, 0, {}) //"Sinalizador não encontrado!"
	EndIf
	Return()
Else
	If (cTipSin := BOJ->BOJ_TIPO) == "1" //0=Workflow;1=Sistema;2=SMS
		If lMlBrw
			ApMsgInfo(STR0024) //"Informe um sinalizador do tipo Workflow ou SMS!"
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0024 , 0, 0, {}) //"Informe um sinalizador do tipo Workflow ou SMS!"
		EndIf
		Return()
	Else
		dbselectArea("BOU")
		dbSetOrder(1)//BOU_FILIAL, BOU_CODSIN, BOU_EMAIL
		If BOU->(MsSeek(xFilial("BOU") + cCodSin))
			While !BOU->(EOF()) .And. BOU->BOU_CODSIN == cCodSin
				If BOU_TIPENV == '0'
					cCC += IIf(!Empty(cCC),";","") + Alltrim(BOU->BOU_EMAIL) 
				Else
					cMailCP += IIf(!Empty(cMailCP),";","") + Alltrim(BOU->BOU_EMAIL) 
				EndIf
				BOU->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

BOA->(DbSetOrder(1))
BOA->(MsSeek(xFilial("BOA") + cCodProg))
//cHtmPad := Alltrim(BOA->BOA_HTMPAD)

If !Empty(BOJ->BOJ_TEXTO) // CORPO DA MENSAGEM Caso não esteja no HTML para WF
	cTxtBody := BOJ->BOJ_TEXTO
	If At("[",cTxtBody) > 0 .AND. At("]",cTxtBody) > 0
		aCposEData := PPROGETCPO(cTxtBody)
	EndIf
	If Len(aCposEData) > 0
// Verifica se são utilizadas tabelas individuais, caso contrário manda o mesmo WF pra todos os contatos
		If 	aScan(aCposEData, {| aVet | "BTS_" $ AllTrim(aVet[1])}) == 0 .AND.;
				aScan(aCposEData, {| aVet | "BOM_" $ AllTrim(aVet[1])}) == 0 .AND.;
				aScan(aCposEData, {| aVet | "GBH_" $ AllTrim(aVet[1])}) == 0 .AND.;
				aScan(aCposEData, {| aVet | "BA1_" $ AllTrim(aVet[1])}) == 0
			lAll := .T.
			PPROSETCPO(@cTxtBody, @aCposEData)
		Else
			lAll := .F.			
		EndIf
	EndIf
Else
	For nI := 1 To Len(aTables)
		DbSelectArea("SX3")
		DbGoTop()
		DbSetOrder(1)
		If DbSeek(aTables[nI])
			While !SX3->(EoF()) .And. SX3->X3_ARQUIVO == aTables[nI]
				If X3USO(SX3->X3_USADO)  .AND. SX3->X3_TIPO <> "M" .AND. SX3->X3_CONTEXT <> "V"
					AADD(aCposEData, {aTables[nI] + "->" + SX3->X3_CAMPO , ""}) //"Nome do Beneficiario"			
				EndIF
				DbSkip()
			End
		EndIf
	Next nI
	lAll := .F.
EndIf
aCposAux := aClone(aCposEData)
If lMlBrw
	BOM->(dbGoTop())
	While !BOM->(Eof())
		If oMBrwBOM:IsMark(cMarca)
			If !lAll // Limpa o destinatario caso seja enviado um por vez
				cTo		:= ""
				cCC		:= ""
				cBcc 	:= ""
				cMailCP	:= ""
				aCposEData := aClone(aCposAux)
			EndIf
			If BOJ->(MsSeek(xFilial("BOJ") + cCodSin))
				If (cTipSin := BOJ->BOJ_TIPO) == "1" //0=Workflow;1=Sistema;2=SMS
					If lMlBrw
						ApMsgInfo(STR0024) //"Informe um sinalizador do tipo Workflow ou SMS!"
					Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0024 , 0, 0, {}) //"Informe um sinalizador do tipo Workflow ou SMS!"
					EndIf
					Return()
				Else
					dbselectArea("BOU")
					dbSetOrder(1)//BOU_FILIAL, BOU_CODSIN, BOU_EMAIL
					If BOU->(MsSeek(xFilial("BOU") + cCodSin))
						While !BOU->(EOF()) .And. BOU->BOU_CODSIN == cCodSin
							If BOU_TIPENV == '0'
								cCC += IIf(!Empty(cCC),";","") + Alltrim(BOU->BOU_EMAIL)
							Else
								cMailCP += IIf(!Empty(cMailCP),";","") + Alltrim(BOU->BOU_EMAIL)
							EndIf
							BOU->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
			BTS->(DbSetOrder(1))
			If BTS->(MsSeek(xFilial("BTS")+BOM->BOM_VIDA))
				If !Empty(BTS->BTS_COMUNI)
					cTipSin := BTS->BTS_COMUNI
				Endif
				
				If cTipSin == "2" //AMBOS
					If !Empty(BTS->BTS_EMAIL)
						lEnv := .T.
						//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
						cBcc += IIf(!Empty(cBcc),";","") + Alltrim(BTS->BTS_EMAIL)
					Else
						If Empty(cMsgErr)
							cMsgErr += STR0025 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) email cadastrado:"
						EndIf
						cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
					EndIf
					
					If !Empty(BTS->BTS_TELEFO)
						lEnv := .T.
						//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
						cTo += IIf(!Empty(cTo),";","") + Alltrim(BTS->BTS_DDD) + Alltrim(BTS->BTS_TELEFO)
					Else
						If Empty(cMsgErr)
							cMsgErr += STR0026 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) telefone cadastrado:"
						EndIf
						cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
					EndIf
					
				ElseIf cTipSin == "0" //e-mail para o WF
					If !Empty(BTS->BTS_EMAIL)
						lEnv := .T.
						//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
						cBcc += IIf(!Empty(cBcc),";","") + Alltrim(BTS->BTS_EMAIL)
					Else
						If Empty(cMsgErr)
							cMsgErr += STR0025 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) email cadastrado:"
						EndIf
						cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
					EndIf
				ElseIf cTipSin == "1"
					If !Empty(BTS->BTS_TELEFO)
						lEnv := .T.
						//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
						cTo += IIf(!Empty(cTo),";","") + Alltrim(BTS->BTS_DDD) + Alltrim(BTS->BTS_TELEFO)
					Else
						If Empty(cMsgErr)
							cMsgErr += STR0026 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) telefone cadastrado:"
						EndIf
						cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
					EndIf
				EndIf
			EndIf
			If !lAll
				// Atribui o valor dos campos do HTML e processa WorkFLow por elegivel selecionado
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "COPIA OCULTA" + cBcc , 0, 0, {})
				If lEnv
					cTxtBody := BOJ->BOJ_TEXTO
					If !Empty(cMailCP)
						cBcc += IIf(!Empty(cBcc),";","") + Alltrim(cMailCP) //cMailCP
					EndIf
					PPROSETCPO(@cTxtBody, @aCposEData)
					
					If cTipSin == "2" .AND. !Empty(BOJ->BOJ_DIRECT)// Workflow
						If !Empty(BOJ->BOJ_TEXTO)
							aCposEData := {{"TEXTO",cTxtBody}} // HTML PARA O CORPO DA MENSAGEM
						EndIf
						PlsWFProc("000001", STR0027, Alltrim(BOJ->BOJ_ASSUNT), cTxtBody, cTO, cCC, cBcc, BOJ->BOJ_DIRECT, aCposEData,.F.,,@lEnv) //"WF Informativo"
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0028 , 0, 0, {}) //"Sinalizador do tipo SMS!"
					ElseIf cTipSin == "0" .AND. !Empty(BOJ->BOJ_DIRECT)// Workflow
						If !Empty(BOJ->BOJ_TEXTO)
							aCposEData := {{"TEXTO",cTxtBody}} // HTML PARA O CORPO DA MENSAGEM
						EndIf
						PlsWFProc("000001", STR0027, Alltrim(BOJ->BOJ_ASSUNT), cTxtBody, cTO, cCC, cBcc, BOJ->BOJ_DIRECT, aCposEData,.F.,,@lEnv) //"WF Informativo"
					Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0028 , 0, 0, {}) //"Sinalizador do tipo SMS!"
					EndIf
				EndIf
			Else
				aCposEData := {{"TEXTO",cTxtBody}}
			EndIf
		EndIf
		BOM->(dbSkip())
	End
Else
	lAll := .T.
	BTS->(DbSetOrder(1))
	If BTS->(MsSeek(xFilial("BTS")+cMatVid))
		PPROSETCPO(@cTxtBody, @aCposEData)
		If !Empty(BOJ->BOJ_TEXTO)
			aCposEData := {{"TEXTO",cTxtBody}} // HTML PARA O CORPO DA MENSAGEM
		EndIf
		
		If cTipSin == "2" //e-mail para o WF
			If !Empty(BTS->BTS_EMAIL)
				lEnv := .T.
				//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
				cBcc += IIf(!Empty(cBcc),";","") + Alltrim(BTS->BTS_EMAIL)
			Else
				If Empty(cMsgErr)
					cMsgErr += STR0025 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) email cadastrado:"
				EndIf
				cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
			EndIf
			
			If !Empty(BTS->BTS_TELEFO)
				lEnv := .T.
				//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
				cTo += IIf(!Empty(cTo),";","") + Alltrim(BTS->BTS_DDD) + Alltrim(BTS->BTS_TELEFO)
			Else
				If Empty(cMsgErr)
					cMsgErr += STR0026 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) telefone cadastrado:"
				EndIf
				cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
			EndIf
			
		ElseIf cTipSin == "0" //e-mail para o WF
			If !Empty(BTS->BTS_EMAIL)
				lEnv := .T.
				//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
				cBcc += IIf(!Empty(cBcc),";","") + Alltrim(BTS->BTS_EMAIL)
			Else
				If Empty(cMsgErr)
					cMsgErr += STR0025 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) email cadastrado:"
				EndIf
				cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
			EndIf
		ElseIf cTipSin == "1"
			If !Empty(BTS->BTS_TELEFO)
				lEnv := .T.
				//aadd(aDest, {"cBCC", Alltrim(BTS->BTS_EMAIL)}) // Envia com copia oculta para preservar a informação confidencial
				cTo += IIf(!Empty(cTo),";","") + Alltrim(BTS->BTS_DDD) + Alltrim(BTS->BTS_TELEFO)
			Else
				If Empty(cMsgErr)
					cMsgErr += STR0026 + Chr(10)+Chr(13) //"O(s) seguinte(s) destinatário(s) não possui(em) telefone cadastrado:"
				EndIf
				cMsgErr += Alltrim(BTS->BTS_NOMUSR) + Chr(10)+Chr(13)
			EndIf
		EndIf
	EndIf
EndIf 

If lAll	
	If cTipSin == "0" .AND. !Empty(BOJ->BOJ_DIRECT)// Workflow 0=Workflow;1=Sistema;2=SMS
		PlsWFProc("000001", STR0027, Alltrim(BOJ->BOJ_ASSUNT), cTxtBody, cTo, cCC, cBcc, BOJ->BOJ_DIRECT, aCposEData,,,@lEnv) //"WF Informativo"
	Else //SMS
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0028 , 0, 0, {}) //"Sinalizador do tipo SMS!"
	EndIf
EndIf  

ApMsgInfo( If(lEnv,STR0029 + Chr(10)+Chr(13) + cMsgErr, "Sinalizador nao enviado!") ) //"Transmitido!"
RestArea( aArea )  

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsWFProc  ºAutor  ³Rogerio Tabosa     º Data ³  01/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função para processamento de WorkFlow                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//aDestinatarios["cTo", fulano@totvs.com.br",aCposEData]
//aCposEData["XXX_NOME","FULANO"]
Function PlsWFProc(cCodProcess, cDescProcess, cSubject, cBody, cToWF, cCCWF, cBccWF, cHtmlFile, aCposEDataWF, xAttach, lPrcCpo,lEnv)
//Variaveis locais
Local cMsgTrk			:= ""
Local oProcess		:= nil		
Local cTo				:= ""
Local cCC				:= ""
Local cBCC 		   	:= ""
Local cWFID		   	:= ""
Local nL				:= 0
Local nI				:= 0
Local oHtml 			
Local lRetArq := .F. 			

Default aCposEDataWF	:= {}
//Valores padrões
Default cCodProcess	:= "000001"
Default cDescProcess	:= STR0027 //"WF Informativo"
Default cSubject		:= STR0027 //"WF Informativo"
Default cBody			:= ""
Default cToWF			:= ""
Default cCCWF			:= ""
Default cBccWF		:= ""
Default cHtmlFile		:= ""//\workflow\testeWF.htm"
Default xAttach		:= ""
Default lPrcCpo		:= .F.

Begin Sequence
	//For nL := 1 To Len(aDestinatarios)		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza o componente padrao TWFProcess  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oProcess	:= TWFProcess():New(/*cCodProcess*/,/*cDescrProcess*/)
	oProcess	:= TWFProcess():New(cCodProcess, cDescProcess) 
	
	If !Empty(cHtmlFile)
	
		If FILE(cHtmlFile)
			lRetArq := .T.
		Else
			MsgInfo("O Arquivo informado no cadastro de sinalizadores nao existe!")	  
			lEnv := .F.
			Return
		EndIf	
		//aArquivos   := directory(cHtmlFile) //directory(cDirOri+"*.html")
		//cDirOri+"*.html" é o caminho completo do arquivo...
		//len(aArquivos) = 0 
	EndIf

	If !Empty(cHtmlFile)
		oProcess:NewTask(STR0030 + cDescProcess, cHtmlFile)		//"Preparando WorkFlow de Autorizacao" //"Preparando "
		//oHtml 		:= oProcess:oHTML
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0031 + oProcess:fProcessID + " - Task: " + oProcess:fTaskID , 0, 0, {}) //"(INICIO)Processo: " //"(INICIO)Processo: "
	EndIf
	// Arquivo Anexo
	If Valtype(xAttach) == "C" // Caracter com arquivo pra anexar ou array com mais de um anexo
		If !Empty(xAttach)
			oProcess:AttachFile(xAttach)
	EndIf
	ElseIf Valtype(xAttach) == "A"
		For nI := 1 To Len(xAttach)
			If !Empty(xAttach[nI])
				oProcess:AttachFile(xAttach[nI])
			EndIf
		Next nI 
	EndIf
	oProcess:cSubject	:= cSubject
	oProcess:cBody		:= cBody
	oProcess:UserSiga	:= __cUserId
	cWFID				:= oProcess:fProcessID + oProcess:fTaskId
		
	If Empty(cToWF) .AND. Empty(cCCWF) .AND. Empty(cBccWF) 
		cMsgTrk	:= STR0032 + cCodProcess+"|"+cDescProcess + "]" //"Endereço do destinatário não informado! ["
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsgTrk , 0, 0, {})
		oProcess:Track( cCodProcess, cMsgTrk)
	Else
		If !Empty(cToWF)
			oProcess:cTo := cToWF
		EndIf
		If !Empty(cCCWF)
			oProcess:cCC := cCCWF
		EndIf
		If !Empty(cBccWF)
			oProcess:cBcc := cBccWF
		EndIf
	EndIf
	//aCposEData := aClone(aDestinatarios[nL,3])
	If Len(aCposEDataWF) > 0
		For nI := 1 To Len(aCposEDataWF)
			If oProcess:oHTML:ExistField(1, aCposEDataWF[nI,1])
				oProcess:oHTML:ValByName( aCposEDataWF[nI,1],If(lPrcCpo,&(aCposEDataWF[nI,2]),aCposEDataWF[nI,2]))
			EndIf
		Next nI
	EndIf
	oProcess:Start()
	//Next nL               
End Sequence
Return(cWFID)

//---------------------------------------------------------------------------
//PPROGETCPO - extrai todos os campos utilizados na montagem do texto entre  |
// [] e/ou expressões dentro do Colchete										   |
//---------------------------------------------------------------------------
Static Function PPROGETCPO(cTxtBody)
Local aCposEmp	:= {}
Local cTxtAux		:= cTxtBody
Local nAt1, nAt2
While At("]",cTxtAux) > 0
	nAt1 := At("[",cTxtAux)
	nAt2 := At("]",cTxtAux)
	If !Empty( SubStr(cTxtAux, nAt1 +1, (nAt2-nAt1)-1))
		AADD(aCposEmp, {SubStr(cTxtAux, nAt1 +1, (nAt2-nAt1)-1), ""})
	EndIf
	cTxtAux := SubStr(cTxtAux, nAt2 + 1, Len(cTxtAux))
EndDo 
Return(aCposEmp)

//---------------------------------------------------------------------------
//PPROSETCPO - atribui o valor no array com os campos extraidos do texto     |
// chamada no momento do(s) Alias posicionados nos registros desejados	   |
// a atualiza o texto com os valroes											   |
//---------------------------------------------------------------------------
Static Function PPROSETCPO(cTexto,aData)
Local cTxtAux		:= ""
Local nAt1, nAt2, nPos
Local nI := 0
Default cTexto := ""

For nI := 1 To Len(aData)
	If Alltrim(aData[nI, 1]) != "TEXTO"
		aData[nI, 2] := &(aData[nI, 1])
		// Substitui a sintaxe no texto pelo dado propriamente dito
		If !Empty(cTexto)	
			cTexto := StrTran(cTexto, "["+aData[nI, 1]+"]", aData[nI, 2])  
		EndIf
	EndIf 
Next nI
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMPROMBUS  ºAutor  ³Rogerio Tabosa     º Data ³  01/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função de que chama a Busca Ativa a elegiveis de todos os º±±
±±º          ³  programas/programa selecionado	     					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMPROMBUS(cCodProg)
Local aRet	 := {}
Local aRegra := {}

Private _oProcess	:= nil
Private _lEnd		:= .F.

If !MsgYesNO(STR0033) //"A busca pode levar alguns instantes, deseja continuar?"
	Return()
EndIf

If FunName() == "PLSMPROM"
	Default cCodProg := BOA->BOA_CODPRO
EndIf 

MsgRun("Verificando regras...",, { || aRegra := FS_ListPro()}) //"Aguarde, verificando  ..."

_oProcess := msNewProcess():new( {|_lEnd| aRet := PLSELEG(,,cCodProg,,,, .T.,,aRegra,.F.,_oProcess) },"Buscando","Buscando elegiveis...",.T.)
_oProcess:activate()
//MsgRun(STR0034,, { || aRet := PLSELEG(,,cCodProg,,,, .T.,,aRegra)}) //"Aguarde, verificando  ..."

If Len(aRet) > 0
	If MsgYesNO(STR0035 + Alltrim(Str(aRet[1])) + STR0036) //"A busca incluiu "###" pacientes como elegiveis, deseja filtra-los!"
		oMBrwBOM:Enable()
		cFilter := "BOM_FILIAL == '" + xFilial("BOM") + "' .AND. BOM_CODPRO == '" + cCodProg + "'"
		cFilter += " .AND. BOM_DTELEG >= '" + DTOS(dDataBase) + "' "
		oMBrwBOM:CleanFilter()
		oMBrwBOM:SetFilterDefault(cFilter)
		oMBrwBOM:Refresh()																												
		BOM->(DbGotop())
	EndIf
Else
	HELP('PMPROMBUS',, 'PMPROMBUS',, STR0037, 1, 0)	 //"Não foram encontrados novos elegiveis!"
EndIf
Return()
//---------------------------------------------------------------------------
//PProcAlert - atribui o alerta com status de vissualizado					    |
//---------------------------------------------------------------------------
Static Function PProcAlert(nReg)
BOS->(DbGoTo(nReg))
RecLock("BOS",.F.)
	BOS->BOS_STATUS = "1" // processado
MsUnlock()
oBrwBOS:Refresh()
Return()

Static Function PProRefresh()

oMBrwBOM:Refresh()
oBrwBOS:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSMPROM  ºAutor  ³Microsiga          º Data ³  02/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para validar a exclusão da movimentação.            º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSMOVDEL()
Local cVida   := BOM->BOM_VIDA
Local cCodPro := BOM->BOM_CODPRO  
Local cNome   := Posicione("BTS", 1, xFilial("BTS")+cVida, "BTS_NOMUSR")
Local cDesPro := Posicione("BOA", 1, xFilial("BOA")+cCodPro, "BOA_DESPRO")

If BOM->BOM_STATUS == '0'  
	If MsgYesNo("Tem Certeza que deseja deletar do programa "+cCodPro+ " - " +cDesPro+ " o paciente " +cVida+ " - " +cNome+ " ?")
		RecLock("BOM", .F.)
		DbDelete()
		MsUnLock()
	EndIf
Else
	MsgInfo("Só é permitida a Exclusão de Pacientes com Status de Elegível!")
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMGRVBOK  ºAutor  ³Microsiga         º Data ³  23/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao para Gravar Historico de Mudança do Risco do Paciente º±±
±±º          ³ 			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function PMGRVBOK(oMdl)
Local aArea := GetArea()
Local cRisco:=""
Local oModelBOM	:= oMdl:GetModel("BOMMASTER")
Local nOpc			:= oMdl:GetOperation()
Local cProgram		:=""
Local cMatVid		:=""
Local cSeqPro		:=""
Local lRet			:=.T.
cRisco 				:= oModelBOM:GetValue( 'BOM_GRARIS')
cProgram := oModelBOM:GetValue( 'BOM_CODPRO')
cMatVid := oModelBOM:GetValue( 'BOM_VIDA')
cSeqPro := oModelBOM:GetValue( 'BOM_NROSEQ')

If nOpc == MODEL_OPERATION_UPDATE
dbSelectArea("BOM")
dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
If BOM->(MsSeek(xFilial("BOM") + cProgram+cMatVid ) )
	If cRisco<>BOM->BOM_GRARIS
		BOM->(DbSetOrder(2))
		If BOM->(MsSeek(xFilial("BOM") + cSeqPro))
			If BOM->BOM_STATUS == '1' .Or. BOM->BOM_STATUS == '3'
				cRiscoI	:=BOM->BOM_GRARIS
				BOM->(RecLock("BOM",.F.))
				BOM->BOM_GRARIS	 := cRisco
				BOM->(MsUnLock())
				
				BOQ->(DbSetOrder(2))
				If BOQ->(MsSeek(xFilial("BOQ") + cMatVid+cSeqPro))
					While !BOQ->(EOF()) .And. BOQ->(BOQ_VIDA+BOQ_ELEGIB) == cMatVid+cSeqPro
						If BOQ->BOQ_DATSUG >= dDataBase .And. (BOQ->BOQ_STATUS == '0' .Or. BOQ->BOQ_STATUS == '1')//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
							RecLock("BOQ",.F.)
							BOQ->BOQ_RISCO := cRisco
							BOQ->(MsUnlock())

						Endif
						BOQ->(dbSkip())
					EndDo
				EndIf
				
				BOK->(RECLOCK("BOK",.T.))
				BOK->BOK_FILIAL		:=	XFILIAL("BOK")
				BOK->BOK_SEQNRO		:= GETSXENUM('BOK','BOK_SEQNRO',, 1)
				BOK->BOK_NROSEQ		:= cSeqPro
				BOK->BOK_CODPRO		:= BOM->BOM_CODPRO
				BOK->BOK_TPHIST		:="1"
				BOK->BOK_GRARII		:=cRiscoI
				BOK->BOK_GRARIF		:=cRisco
				BOK->BOK_DATA			:=dDataBase
				BOK->BOK_HORA			:=Time()
				BOK->BOK_USUARI		:=cUserName
				BOK->BOK_LOGARQ		:=Hs_LogArq()
				BOK->(MSUNLOCK())
				ConfirmSx8()
			
			EndIf
		EndIf
			
	Endif
Endif
RestArea(aArea)
Endif
Return lRet

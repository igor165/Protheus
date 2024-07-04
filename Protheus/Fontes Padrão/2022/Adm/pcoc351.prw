#INCLUDE "PCOC351.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC351  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 26.11.2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta ao arquivo de saldos mensais dos Cubos  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC351                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOC351(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC351(nCallOpcx)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Consulta Saldos na Data - Visoes"
Private aRotina := MenuDef()

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
			Eval( bBlock,Alias(),AKN->(Recno()),nPos)
		EndIf
	Else
		mBrowse(6,1,22,75,"AKN")
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco_350View บAutor  ณEdson Maricate      บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que solicita parametros para utilizacao na montagem    บฑฑ
ฑฑบ          ณda grade e grafico ref. saldo gerencial do pco                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_350View(cAlias,nRecno,nOpcx)
Local aProcessa
Local nTpGraph
Local nDetalhe
Local aCfgAuxCube := {}
Local aAuxCube := {} 
Local lContinua := .T.
Local nDirAcesso 	:= 0
Local aListArq := {}
Local cPicture := PadR("@E 999,999,999,999.99",25)

Local aTpGrafico:= {STR0004,; //"1=Linha"
							STR0005,; //"2=Area"
							STR0006,; //"3=Pontos"
							STR0007   ,; //"4=Barra"
							STR0008  ,; //"5=Piramide"
							STR0009    ,; //"6=Cilindro"
							STR0010,; //"7=Barra Horizontal"
							STR0011,; //"8=Piramide Horizontal"
							STR0012,; //"9=Cilindro Horizontal"
							STR0013,; //"10=Pizza"
							STR0014,; //"11=Forma"
							STR0015,; //"12=Linha Rapida"
							STR0016,; //"13=Flechas"
							STR0017,; //"14=Gantt"
							STR0018 } //"15=Bolha"

Private aConfig := {}
Private dData	 := dDataBase

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0026,STR0037,{STR0028},2)//"Aten็ใo"###"Usuario sem acesso a esta configura็ใo de visao gerencial. "###"Fechar"
		lContinua := .F.
	Else
	    lContinua := .T.
	EndIf
EndIf

If lContinua
	If ParamBox({ { 1 ,STR0019,Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL3" ,"" ,25 ,.F. },; //"Config Cubo"
						{3,STR0020,1,{STR0021,STR0022},40,,.F.},; //"Exibe Configura็๕es"###"Sim"###"Nao"
						{ 1 ,STR0023,dData,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Saldo em"
						{2,STR0038,2,{"1="+STR0021,"2="+STR0022},80,"",.F.},;//"Detalhar Cubos"###"Sim"###"Nao"
						{2,STR0024,4,aTpGrafico,80,"",.F.},;
						{3,STR0042,2,{STR0043,STR0044,STR0045},40,,.F.},; //"Mostrar valores"##"Unidade"##"Milhar"##"Milhao"
						{ 1,"Picture",cPicture,"@!" 	 ,""  ,"" ,"" ,75 ,.F. };
						},STR0025,aConfig,,,,,,, "PCOC351",,.T.) //"Tipo do Grafico"###"Parametros"
	
		nDetalhe  := If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4]))
		dData := aConfig[3]

		aProcessa := PcoCub_Vis(AKN->AKN_CODIGO,1,"Pco_350Sld",aConfig[1],aConfig[2],nDetalhe,.T.)

		aAdd(aCfgAuxCube, aClone(aAuxCube))
	
		If !Empty(aProcessa)
			nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
			PCOC_350PFI(aProcessa,nTpGraph,aCfgAuxCube,If(nDetalhe==1,STR0039,STR0040),aConfig[6],,aListArq,aConfig[7])//"Conta Gerencial / Detalhes"###"Conta Gerencial"
		Else
			Aviso(STR0026,STR0027,{STR0028},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
		EndIf
						
	EndIf
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC_350PFI บAutor  ณEdson Maricate      บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que processa o cubo gerencial do pco e exibe uma       บฑฑ
ฑฑบ          ณgrade com o grafico                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC_350PFI(aProcessa,nTpGrafico,aCfgAuxCube,cDescri,nCasas, lShowGraph, aListArq, cPicture)

Local oDlg,oPanel,oPanel1,oPanel2
Local oView
Local oGraphic
Local aArea    := GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local nSerie
Local cTexto
Local aSize    := {}
Local aPosObj  := {}
Local aObjects := {}
Local aInfo    := {}
Local aView    := {}
Local nNivCub  := 0
Local nx
Local aButtons := {}
Local bEncerra := {|| If(Aviso(STR0029,STR0030, {STR0021, STR0022},2)==1, ( PcoArqSave(aListArq), oDlg:End() ), NIL) } //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail :=	{}
Local nDivisor :=	1
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local aTitle	:= {cDescri,STR0035,STR0036}
Local lPCOC3502 := ExistBlock("PCOC3502") 

DEFAULT lShowGraph := .T.
DEFAULT aListArq := {}
DEFAULT cPicture := PadR("@E 999,999,999,999.99",25)

nCasas    := Iif(nCasas==1,0,IIf(nCasas==2,-3,-6))
nDivisor  := 10**(Abs(nCasas))
//cPicture  := If(nCasas==-6,"@E 999,999,999,999.99","@E 999,999,999,999")
cCadastro += IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047))//" - (Valores em milhares)"##" - (Valores em milhoes)"

aButtons := { 	{"BMPPOST"	, {|| PmsGrafMail(oGraphic,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0033,STR0034 }, ; //"Enviar Email"##"Email"
               	{"GRAF2D"	, {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0048,STR0049 },;//"Exibir/Esconder Grafico"###"Grafico"
				{"SALVAR"	, {|| PcoSaveGraf(oGraphic, lPergNome, .T., .F., aListArq) },STR0050,STR0051 } ; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
			}

aadd(aTabMail, aClone(aTitle) )

For nx := 1 to Len(aProcessa)
	aAdd(aView,{Substr(aProcessa[nx,1],1),aProcessa[nx,6],TransForm(Round(aProcessa[nx,2,1],2)/nDivisor* If(aProcessa[nx, 18] == "1",1,-1),cPicture)})
	aadd(aTabMail,{Substr(aProcessa[nx,1],1),aProcessa[nx,6],Alltrim(Transform(Round(aProcessa[nx,2,1],2)/nDivisor, cPicture) ) } )
Next


If !Empty(aView) 

	If lPCOC3502 
		ExecBlock( "PCOC3502",.F.,.F.,{ aView, aTabMail, aProcessa }) 
	EndIf 
	
	aSize := MsAdvSize(,.F.,400)                                            	'
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro  From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,22,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	If !lShowGraph
		oPanel2:Hide()
	EndIf	

	@ 2,4 SAY AKN->AKN_DESCRI  of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(@oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2 SAY STR0041+DTOC(mv_par03) + IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047)) Of oPanel PIXEL SIZE 640 ,79 FONT oBold //"Saldo em : "
	
	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	nSerie	:= oGraphic:CreateSerie( nTpGrafico )
	oGraphic:l3D := .F.
	
	For nx := 1 to Len(aProcessa)
		oGraphic:Add(nSerie,aProcessa[nx,2,1],Substr(aProcessa[nx,1],1),CLR_BLUE)
	Next

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,) //"Descricao"###"Valor"
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
	oView:bLine := { || aView[oView:nAT]}

	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0041+DTOC(mv_par03)+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0046,STR0047)),{cDescri,STR0035,STR0036},aView} } ))//"Saldo em : "

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)
EndIf

RestArea(aArea)

Return

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ STR0003, 	"Pco_350View" , 0 , 2} }  //"Visualizar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3511" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC351                             ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3511", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)


//============================================================================================================//
Function Pco_350Sld( cCodCube, nQtdVal, cConfig, nViewCFG, lZerado, aNiveis, aFilIni, aFilFim, aFiltros, lForceNoSint, nNivel)
Local aProcCub := {}
Local oStructCube
Local nX
Local cWhereTpSld
Local cArquivo
Local cArqTmp
Local nZ, lAuxSint
Local aQueryDim
Local aFilesErased := {}
Local cArqAS400 := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))

DEFAULT nNivel := 1

oStructCube := PcoStructCube( cCodCube, cConfig )
			
If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
	Return aProcCub
EndIf

For nX := 1 To Len(aFilIni)
	oStructCube:aIni[nX] := PadR(aFilIni[nX], Len(oStructCube:aIni[nX]))
Next

For nX := 1 To Len(aFilFim)
	oStructCube:aFim[nX] := PadR(aFilFim[nX], Len(oStructCube:aFim[nX]))
Next

For nX := 1 To Len(aFilFim)
	oStructCube:aFiltros[nX] := aFiltros[nX]
Next

cWhereTpSld := ""
If oStructCube:nNivTpSld > 0 .And. ;
	oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
	Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
		cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
EndIf								

aAdd(aNiveis, nNivel)

If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, 1/*nQtdVal*/)
	aAdd(aFilesErased, cArqAS400)
EndIf

//cria arquivo para popular
PcoCriaTemp(oStructCube, @cArquivo, 1/*nQtdVal*/)
aAdd(aFilesErased, cArquivo)

aQryDim 	:= {}
For nZ := 1 TO oStructCube:nMaxNiveis
	aQueryDim := PcoCriaQueryDim(oStructCube, nZ, .F./*lSintetica*/, .T. /*lForceNoSint*/)
	//aqui fazer tratamento quando expressao de filtro e expressao sintetica nao for resolvida
	If (aQueryDim[2] .And. aQueryDim[3])  //neste caso foi resolvida
		
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
		
	Else  //se filtro ou condicao de sintetica nao foi resolvida pela query
	
		aQueryDim := PcoQueryDim(oStructCube, nZ, @cArqTmp, aQueryDim[1] )
		aAdd(aFilesErased, cArqTmp)
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
		
	EndIf	
Next

aQuery := PcoCriaQry( cCodCube, nNivel, 1/*nMoeda*/, cArqAS400, 1/*nQtdVal*/, { dData }/*aDtSld*/, aQryDim, ""/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, .F., NIL )

PcoPopulaTemp(oStructCube, cArquivo, aQuery, 1/*nQtdVal*/, lZerado, cArqAS400)

dbSelectArea(cArquivo)
(cArquivo)->(dbGoTop())

While (cArquivo)->( ! Eof() )

	cChave := (cArquivo)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2))))
	nTamNiv := oStructCube:aTam[nNivel]
	nPai := 0
	cChavOri := ""
	//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
	dbSelectArea(oStructCube:aAlias[nNivel])
	If dbSeek(xFilial()+cChave)
		cDescrAux := &(oStructCube:aDescRel[nNivel])
		If ! Empty(oStructCube:aCondSint[nNivel])
			lAuxSint := &(oStructCube:aCondSint[nNivel])
		Else	
			lAuxSint := .F.	
		EndIf
	Else
		cDescrAux := STR0052 //"Outros"
		lAuxSint := .F.		
	EndIf	
	
  	aAdd(aProcCub, {	PadR(cChave, nTamNiv), ;
  						{ (cArquivo)->(FieldGet(FieldPos("AKT_SLD001")))}, ;
	  					oStructCube:aConcat[nNivel], ;
	  					oStructCube:aAlias[nNivel], ;
  						oStructCube:aDescri[nNivel], ;
  						cDescrAux,;
	  					0,;
	  					nNivel,;
  						cChavOri,;
  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
  						nPai,;
	  					.T.,;
	  					oStructCube:aDescCfg[nNivel],;
						PadR(cChave, nTamNiv),;
						( nNivel  == oStructCube:nMaxNiveis ) })

	dbSelectArea(cArquivo)
	(cArquivo)->(dbSkip())

EndDo	

dbSelectArea(cArquivo)
dbCloseArea()

If ! Empty(aFilesErased)
	//apaga os arquivos temporarios criado no banco de dados
	For nZ := 1 TO Len(aFilesErased)
		If Select(Alltrim(aFilesErased[nZ])) > 0
			dbSelectArea(Alltrim(aFilesErased[nZ]))
			dbCloseArea()
		EndIf	
		MsErase(Alltrim(aFilesErased[nZ]))
	Next
EndIf

Return aProcCub

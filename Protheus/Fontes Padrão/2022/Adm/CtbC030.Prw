#INCLUDE "CTBC030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
// 17/08/2009 -- Filial com mais de 2 caracteres


//-------------------------------------------------------------------
/*{Protheus.doc} CTBC030
Consulta comparativa entre saldos 

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTBC030(lBar)

Local aTamCta		:= TAMSX3("CT1_CONTA")
Local aTamCC		:= TAMSX3("CTT_CUSTO")                                                 
Local aTamItem	:= TAMSX3("CTD_ITEM")
Local aTamClVl	:= TAMSX3("CTH_CLVL")                    
Local aTamGrp		:= TAMSX3("CTR_GRUPO")
Local cMascCta	:= GetMV("MV_MASCARA")
Local cMascCC		:= GetMv("MV_MASCCUS") 
Local aSize		:= {}
Local aObjects	:= {}
Local aPages	:= {}
Local nTree, oDlg
Local lSayGrupo := GetNewPar("MV_CTBNATC","1") == "1"
Local aTitles	:= { STR0002, STR0003, STR0004, STR0005, If(lSayGrupo,STR0043,STR0044) }, aTitFolder := {} //"Grupos contabeis"
  					  
Local aTrees	:= {	{ "CT1", "CQ1", "_CONTA"	, 2,cMascCta,aTamCta[1]  },;
				  		{ "CTT", "CQ3", "_CUSTO"	, 2,cMascCC ,aTamCC[1]   },;
						{ "CTD", "CQ5", "_ITEM"	    , 2,""      ,aTamItem[1] },;
						{ "CTH", "CQ7", "_CLVL"	    , 2,""      ,aTamClVl[1] },;
  						{ "CTR", "CQ1", "_GRUPO"		 , 2,""      ,aTamGrp[1]  };
  				   }
Local aCbx 		:= { STR0019, STR0020, STR0021, STR0022, STR0023, STR0024,; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
					 STR0025, STR0026, STR0027,; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
					 STR0028, STR0029, STR0030, STR0031, STR0032, STR0033 } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
Local aRet		:= {}
Local nI
Local cFilIni	:= cFilAnt
Local lPerbar		:= .F.

Private aRotina := {{"Visualizar", "AxVisual", 0, 2}}
Private nFolder := 1

Private cTpBase 	:= cTpCompara := ""
Private oGraphic, oTpBase, oTpCompara
Private nSerie, cTitulo, aSaldosMP := {}, mv_pargf := 1
Private cCadastro := STR0001 
Default lBar := .F.

// Caso a função tenha sido chamada por ela mesma a variavel nao pode ser reiniciada
If Type("aSelFil") != "A"
	Private aSelFil := {} 
EndIf

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

oMainWnd:ReadClientCoors()

nTop    := oMainWnd:nTop+23
nLeft	:= oMainWnd:nLeft+5
nBottom	:= oMainWnd:nBottom-60
nRight	:= oMainWnd:nRight-10

If !lBar      
	If ! Sx1C020()
		Return
	Endif       
Endif	

dbSelectarea("CTO")
dbSetOrder(1)
If Empty( mv_par03 ) .OR. !MsSeek(xFilial()+mv_par03,.F.)
    Help(" ",1,"NOMOEDA")
	Return
Endif
       
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize			:= MsAdvSize(,.F.,430)
aObjects		:= {{ 100, 157 , .T., .T. }}
aInfo			:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj			:= MsObjSize( aInfo, aObjects )
oTdTree	   		:= {}
                  
DEFINE  MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 	nTop,nLeft TO;
																nBottom,nRight;
		STYLE nOR(WS_VISIBLE,WS_POPUP)

@00,00 BITMAP oBmp1 RESNAME "FAIXASUPERIOR" SIZE 1200,50 NOBORDER PIXEL OF oDlg
oBmp1:align:= CONTROL_ALIGN_TOP

@ 75,10 BTNBMP oBtn RESOURCE "S4WB005N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0010  //"Recortar"
@ 75,38 BTNBMP oBtn RESOURCE "S4WB006N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0011  //"Copiar"
@ 75,66 BTNBMP oBtn RESOURCE "S4WB007N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0012  //"Colar"
@ 75,94 BTNBMP oBtn RESOURCE "S4WB008N" 	SIZE 25,25 ACTION Calculadora() MESSAGE STR0013  //"Calculadora..."
@ 75,122 BTNBMP oBtn RESOURCE "S4WB009N" 	SIZE 25,25 ACTION Agenda() MESSAGE STR0014  //"Agenda..."
@ 75,150 BTNBMP oBtn RESOURCE "S4WB010N" 	SIZE 25,25 ACTION OurSpool() MESSAGE STR0015  //"Gerenciador de ImpressÆo..."
@ 75,178 BTNBMP oBtn RESOURCE "S4WB016N" 	SIZE 25,25 ACTION HelProg() MESSAGE STR0016  //"Help de Programa..."
@ 75,206 BTNBMP oBtn RESOURCE "SDUPROP"  SIZE 25,25;
 	  	ACTION If(Sx1C020(),(lPerBar := .T.,oDlg:End()),lPerBar := .F.) MESSAGE STR0017        //"Parƒmetros..."

@ 75, 234 	BTNBMP oBtnGrap		RESOURCE "AREA" SIZE 25,25;
			ACTION (ParamBox( {	{3,STR0034,mv_pargf,aCbx,50,"",.F.}},STR0035,@aRet),; //"Tipo de grafico"###"Parametros"
					Sx1C020(.F.), If(Len(aRet) > 0, mv_pargf := aRet[1],)) MESSAGE STR0034  //"Tipo de grafico"
oBtnGrap:Disable()
@ 75, 262 BTNBMP oBtn3D RESOURCE "GRAF3D" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "EFEITO", oBtn3D, oBtn2D) MESSAGE "3D" 
@ 75, 262 BTNBMP oBtn2D RESOURCE "GRAF2D" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "EFEITO", oBtn3D, oBtn2D) MESSAGE "2D" 
oBtn2d:Hide()
@ 75, 290 BTNBMP oBtnSav	RESOURCE "SALVAR" 	SIZE 25,25 ACTION GrafSavBmp( oGraphic ) MESSAGE STR0036  //"Salva BMP"
oBtnSav:Disable()
@ 75, 318 BTNBMP oBtnPrev 	RESOURCE "PGPREV" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "ROTACAO-", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0037  //"Rotacao -"
// oBtnPrev:Disable()
@ 75, 346 BTNBMP oBtnNext 	RESOURCE "PGNEXT" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "ROTACAO+", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0038  //"Rotacao +"
@ 75, 374 BTNBMP oBtnPrn 	RESOURCE "IMPRESSAO" 	SIZE 25,25 ACTION CtbGrafPrint(oGraphic,STR0039,{ cTitulo },aSaldosMP, .F.) MESSAGE STR0040 //"Comparacao de saldos"###"Imprimir grafico"
oBtnPrn:Disable()
@ 75, 402 BTNBMP oBtnMail 	RESOURCE "BMPPOST" 	SIZE 25,25 ACTION PmsGrafMail(oGraphic,cTitulo,{cTitulo },aSaldosMP) MESSAGE STR0041 //"Enviar por E-Mail"
oBtnMail:Disable()

@ 75,430 BTNBMP oBtn RESOURCE "FINAL" SIZE 25,25 ACTION oDlg:End() MESSAGE STR0042 //"Fechar"

For nTree := 1 To Len(aTrees)
	DbSelectArea(aTrees[nTree][1])
	dbSetOrder(1)
	MsSeek(xFilial())
	If !Eof() .And. Mv_PAR14 == 2
		Aadd(aTitFolder, aTitles[nTree]) 
	else	
		Aadd(aTitFolder, aTitles[nTree])// carrega sempre os folders quando for consulta por filial
	Endif
Next	

oFolder := TFolder():New(50,0,aTitFolder,aPages,oDlg,,,,.T., .F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],)

For ni := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
Next
	
For nTree := 1 To Len(aTrees)
	CTBCMontaTree(	oDlg, @nFolder,;
					aTrees[nTree][1], aTrees[nTree][2], aTrees[nTree][3],;
					aTrees[nTree][4], aTrees[nTree][5], aTrees[nTree][6],;
					.T., { 2, 2,((nBottom-nTop)/2)-50, 150 })
Next	

ACTIVATE MSDIALOG oDlg

cFilAnt := cFilIni 

If lPerBar
	CTBC030(.T.)
Endif	

Return .T.

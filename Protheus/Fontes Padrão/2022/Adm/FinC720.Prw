#INCLUDE "FINC720.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#include "MSGRAPHI.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINC720  ³ Autor ³ Wagner Mobile         ³ Data ³ 29-07-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta comparativa entre Valores Orcados X Reais Mensal    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Finc720(lAnual As Logical) As Logical
Local lPanelFin As Logical
Local lPergunte As Logical
Local aSize		As Array
Local aObjects	As Array
Local aPages	As Array
Local oDlg		As Object
Local aTitles	As Array
Local aCbx 		As Array
Local aRet		As Array
Local mv_pargf 	As Numeric
Local aTrees 	As Array
Local cPerg 	As Character
Local lIncTree	As Logical
Local lTree		As Logical
Local aEntradas	As Array
Local aSaidas 	As Array
Local nFolder 	As Numeric
Local nI 		As Numeric
Local nLin 		As Numeric
Local cLoad 	As Character
Local aButtons 	As Array
Local oPanel	As Object

lPanelFin 	:= IsPanelFin()
lPergunte 	:= .F.
aSize		:= {}
aObjects	:= {}
aPages		:= {}
aTitles		:= { STR0043, STR0044, STR0045, STR0046 } //"Entradas"###"Saidas"###"Entradas X Saidas"###"Resumo"
aRet		:= {}
aTrees 		:= {}
cPerg 		:= "FIC720"
aEntradas	:= {}
aSaidas 	:= {}
nFolder 	:= 0
nI	 		:= 0
cLoad 		:= ProcName(1)
aButtons 	:= {}

DEFAULT lAnual	:= .F.

Private aRotina 	As Array
Private oGraphic	As Object
Private nSerie		As Numeric
Private oResumo		As Object
Private aResumo		As Array
Private oQuebras	As Object
Private aQuebras	As Array
Private cArqTmp 	As Character
Private cIndex1 	As Character
Private cIndex2 	As Character
Private cIndex3 	As Character
Private nDecs		As Numeric
Private aTotais		As Array
Private aGraficos 	As Array
Private cCadastro 	As Character
Private aSelFil		As Array

aRotina 	:= {{STR0062, "AxVisual", 0, 2}} // "Visualizar"
cArqTmp 	:= cIndex1 := cIndex2 := cIndex3 := ""
aGraficos 	:= { {,,},{,,},{,,} }
cCadastro 	:= STR0001
aSelFil		:= {}

cCadastro += IIf(lAnual, STR0050, STR0051) //" - Anual"###" - Mes"

cPerg:= IIf( lAnual, "FIC730", "FIC720" ) // Define o Pergunte se Orçamento Mensal ou Anual

If lAnual
	cPerg	 := "FIC730"
	mv_pargf := 1
Endif

If lPanelFin
	lPergunte := PergInPanel(cPerg,.T.)
Else
   lPergunte := pergunte(cPerg,.T.)
Endif	

If !lPergunte
	Return .F.
Endif

Do Case
	Case mv_par02 < mv_par01
		HELP (" ",1,"R720NAT")
		Return
	Case mv_par04 < mv_par03
		HELP (" ",1,"R720NAT")
		Return
		
// Retiradas as validacoes de Range. Pois podem causar problemas se o 
// Cliente nao tiver um codigo de naturezas estruturado 

EndCase	
//Seleciona Filiais
#IFDEF TOP
	If mv_par11 == 1 
		nRegSM0 := SM0->(Recno())
		aSelFil := FwSelectGC()
		SM0->(DbGoTo(nRegSM0))
		nConsFil:= .F.
	Endif
	If Empty(aSelFil)
		Aadd(aSelFil,cFilAnt)
	Endif
#ELSE
	aSelFil := {}
#ENDIF

oMainWnd:ReadClientCoors()

nDecs 	:= MsDecimais(mv_par06)

nTop    := oMainWnd:nTop
nLeft	:= oMainWnd:nLeft
nBottom	:= oMainWnd:nBottom
nRight	:= oMainWnd:nRight

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize		:= MsAdvSize(,.F.,430)
aObjects	:= {{ 100, 157 , .T., .T. }}
aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj		:= MsObjSize( aInfo, aObjects )
oTdTree	 	:= {}

Aadd(aButtons ,{ "SDUPROP", {|| If(Pergunte(cPerg, .T.),Finc720Tmp(lAnual, oDlg, mv_pargf), .T.)} , STR0017})

 
DEFINE  MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL ; 
		STYLE nOR(WS_VISIBLE,WS_POPUP)
EnchoiceBar(oDlg,	{|| oDlg:End()},;
														{|| oDlg:End()},,@aButtons )
nLin := 0
oPanel :=  TPanel():New(  0 , 0, /*[ cText]*/,oDlg , /*[ oFont]*/, /*[ lCentered]*/, /*[ uParam7]*/, /*[ nClrText]*/,/**/,200 , 20,.t. , /*[ lRaised]*/ ) 
oPanel:align :=CONTROL_ALIGN_BOTTOM  

oFolder := TFolder():New(	nLin,0,aTitles,aPages,oDlg,,,,.T., .F.,((nRight-nLeft)/2)+5,;
							nBottom-nTop-nLin-100,)
oFolder:align 	 := CONTROL_ALIGN_ALLCLIENT

@ nLin, 402 BTNBMP oBtnMail 	RESOURCE "BMPPOST" 	SIZE 25,25 ACTION PmsGrafMail(aGraficos[oFolder:nOption][1],cCadastro,{cCadastro},aGraficos[oFolder:nOption][2]) MESSAGE STR0041 OF oPanel//"Enviar por E-Mail"
oBtnMail:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 374 BTNBMP oBtnPrn 	RESOURCE "IMPRESSAO" 	SIZE 25,25 ACTION CtbGrafPrint(aGraficos[oFolder:nOption][1],cCadastro,{ cCadastro },aGraficos[oFolder:nOption][2], .F.,;
							{ 360, 0900, 1500, 2100 },;
							aGraficos[oFolder:nOption][3]) MESSAGE STR0040 OF oPanel//"Comparacao de saldos"###"Imprimir grafico"
oBtnPrn:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 346 BTNBMP oBtnNext 	RESOURCE "PGNEXT" 	SIZE 25,25 ACTION Ctb020Graph(aGraficos[oFolder:nOption][1], STR0064+"+", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0038 OF oPanel //"Rotacao +"
oBtnNext:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 318 BTNBMP oBtnPrev 	RESOURCE "PGPREV" 	SIZE 25,25 ACTION Ctb020Graph(aGraficos[oFolder:nOption][1], "ROTACAO-", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0037 OF oPanel //"Rotacao -"
oBtnPrev:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 290 BTNBMP oBtnSav	RESOURCE "SALVAR" 	SIZE 25,25 ACTION GrafSavBmp( aGraficos[oFolder:nOption][1] ) MESSAGE STR0036 OF oPanel //"Salva BMP"
oBtnSav:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 262 BTNBMP oBtn2D RESOURCE "GRAF2D" 		SIZE 25,25;
			ACTION If(oFolder:nOption < 4 .And. aGraficos[oFolder:nOption][1] <> Nil,;
			(Ctb020Graph(aGraficos[oFolder:nOption][1],;
			STR0063, oBtn3D, oBtn2D),(oBtn2D:Hide(),oBtn3D:Show(),oBtnNext:Enable(),oBtnPrev:Enable())),.T.);
			MESSAGE "2D" OF oPanel
oBtn2D:Align:= CONTROL_ALIGN_RIGHT 

@ nLin, 262 BTNBMP oBtn3D RESOURCE "GRAF3D" 		SIZE 25,25;
			ACTION If(oFolder:nOption < 4 .And. aGraficos[oFolder:nOption][1] <> Nil,;
			(Ctb020Graph(aGraficos[oFolder:nOption][1],;
			STR0063, oBtn3D, oBtn2D),(oBtn2D:Show(),oBtn3D:Hide(),oBtnNext:Disable(),oBtnPrev:Disable())), .T.);
			MESSAGE "3D" OF oPanel
oBtn3D:Align:= CONTROL_ALIGN_RIGHT 

If !lAnual .And. MV_PAR07 == 1 
//           "Linha"   "Area"  "Pontos" "Barras"
	aCbx := { STR0019, STR0020, STR0021, STR0022 }
	mv_pargf := 4
Else
//           "Barras" "Pizza"
	aCbx := { STR0022, STR0028 }
	mv_pargf := 1
Endif

@ nLin, 234 	BTNBMP oBtnGrap		RESOURCE "AREA"	SIZE 25,25 OF oPanel;
			ACTION (ParamBox( {	{3,STR0034,mv_pargf,aCbx,50,"",.F.}},STR0035,@aRet,,,,,,,cLoad),; //"Tipo de grafico"###"Parametros"
					If(Len(aRet) > 0, mv_pargf := aRet[1],),;
					If(oFolder:nOption == 3, Finc720Res(oDlg,aTotais,lAnual,mv_pargf),;
					If(oFolder:nOption < 3,;
					FinC720Grap(,,,,, mv_pargf, aTrees[oFolder:nOption]:GetCargo(),lAnual),.T.)));
 			MESSAGE STR0034  //"Tipo de grafico" 
oBtnGrap:Align:= CONTROL_ALIGN_RIGHT 

Finc720Tmp(lAnual, oDlg, mv_pargf)

For nFolder := 1 To 2
	oFolder:aDialogs[nFolder]:oFont := oDlg:oFont
	oTree  := DbTree():New( 2, 2,((nBottom-nTop)/2)-50, 150,oFolder:aDialogs[nFolder],,,.T.)
	oTree:lShowHint:= .F. 
	oTree:ALIGN := CONTROL_ALIGN_LEFT
	Aadd(aTrees, oTree)

	oTree:bChange := {|x| FinC720Grap(,,,,, mv_pargf, x:GetCargo(), lAnual) }
	oTree:BeginUpdate()

	cArqTmp->(DbGoTop())
	lTree := .F.

	While ! cArqTmp->(Eof())

		lIncTree := .F.
		If nFolder = 1 .And. (cArqTmp->rEntr > 0 .Or. cArqTmp->aEntr > 0 .Or.;
							 (If(! lAnual, cArqTmp->aEAcm + cArqTmp->rEAcm > 0, .F.)))
            If lAnual
            	If Ascan(aEntradas, cArqTmp->NATUR) == 0
		       		Aadd(aEntradas, cArqTmp->NATUR)
		       		lIncTree := .T.
		      	Endif
	       	Else
				lIncTree := .T.
			Endif
		ElseIf nFolder = 2 .And. (cArqTmp->rSaid > 0 .Or. cArqTmp->aSaid > 0 .Or.;
							 (If(! lAnual, cArqTmp->aSAcm + cArqTmp->rSAcm > 0, .F.)))
            If lAnual
            	If Ascan(aSaidas, cArqTmp->NATUR) == 0
		       		Aadd(aSaidas, cArqTmp->NATUR)
		       		lIncTree := .T.
		      	Endif
	       	Else
				lIncTree := .T.
			Endif
		Endif

		If 	lIncTree
			lTree := .T.
			DBADDITEM oTree PROMPT MascNat(cArqTmp->NATUR) + " - " + cArqTmp->DESCR;
					  		RESOURCE "BMPTRG" CARGO StrZero(cArqTmp->(Recno()),12)
		Endif
		cArqTmp->(dbSkip())
	EndDo

    If lTree
		DBENDTREE oTree
	Endif

	oTree:EndUpdate()
	oTree:Refresh()	
Next

oFolder:bChange := { |x| If(x < 3, FinC720Grap(,,,,, mv_pargf, aTrees[x]:GetCargo(), lAnual), If(x == 3, Finc720Res(oDlg,aTotais,lAnual,mv_pargf),)) }

oFolder:bSetOption := { |x| (If(X > 3 .Or. aGraficos[x][1] = Nil,;
 									   (oBtnGrap:Disable(),;
										oBtnSav:Disable(),;
										oBtnPrn:Disable(),;
										oBtnPrev:Disable(),;
										oBtnNext:Disable(),;
										oBtnMail:Disable()),;
										(oBtnGrap:Enable(),;
										oBtnSav:Enable(),;
										oBtnPrn:Enable(),;
										oBtnPrev:Enable(),;
										oBtnNext:Enable(),;
										oBtnMail:Enable()))),;
							(If(X > 3 .Or. aGraficos[x][1] == Nil,;
							(oBtn2D:Hide(), oBtn3D:Hide()),;
							(If(aGraficos[x][1]:l3D,;
								(oBtn3D:Hide(),oBtn2D:Show(),oBtnPrev:Disable(),oBtnNext:Disable()),;
								(oBtn3D:Show(),oBtn2D:Hide(),oBtnPrev:Enable(),oBtnNext:Enable()))))) }

// Botoes desabilitados pois a funcionalidade de rotacao nao esta desenvolvida
// Assim que a fncionalidade estiver disponivel favor retirar as duas proximas linhas
// Consultar a funcao Ctb020Graph para verificar se esta habitado
oBtnPrev:Hide()
oBtnNext:Hide()

ACTIVATE MSDIALOG oDlg ON INIT (oBtnGrap:Disable(),;
								oBtn2d:Hide(),;
								oBtnPrev:Disable(),;
								oBtnNext:Disable(),;
								oBtnSav:Disable(),;
								oBtnPrn:Disable(),;
								oBtnMail:Disable(),;
								FinC720Grap(,,,,, mv_pargf, aTrees[1]:GetCargo(), lAnual),;
								)   

If !Empty(cArqTmp)
	dbSelectarea("cArqTmp")
	cArqTmp->( dbCloseArea() )
	Ferase(cArqTmp+GetDBExtension())
	Ferase(cArqTmp+OrdBagExt())

	#IFDEF TOP
		If TcSrvType() == "AS/400"
			Ferase(cIndex1+OrdBagExt())
			Ferase(cIndex2+OrdBagExt())
		EndIf
	#ELSE
		Ferase(cIndex1+OrdBagExt())
		Ferase(cIndex2+OrdBagExt())
		Ferase(cIndex3+OrdBagExt())
	#ENDIF
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720Grap ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 29.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta grafico de comparacao previsto X Realizado X Orcado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720Grap                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Grap(oDlg, nTop, nLeft, nBottom, nRight, nGrafico, cRecTmp, lAnual)

Local oBold
Local nSerie 		:= 0
Local nSerie2 		:= 0
Local nSerie3 		:= 0
Local nPrevisto		:= 0
Local nRealizado	:= 0
Local nOrcado 		:= 0
Local nPrevAcm 		:= 0 
Local nRealAcm 		:= 0
Local nOrcAcm		:= 0 
Local nMeses
Local aColuna 		:= {}
Local l3d	   		:= .F.   
Local nMaxVal1 		:= 0
Local nMaxVal2 		:= 0
Local nDivisor 		:= 1
Local cDivisor 		:= ""
Local nVezes
Local lAcumul  		:= (!lAnual .And. MV_PAR07 == 1)

DEFAULT oDlg		:= oFolder:aDialogs[oFolder:nOption]
DEFAULT nTop		:= 1 
DEFAULT nLeft		:= 155
DEFAULT nBottom		:= aPosObj[1][4]-155
DEFAULT nRight 		:= aPosObj[1,3]-35

cArqTmp->(DbGoto(Val(cRecTmp)))

If !lAcumul
	If nGrafico == 1
		nGrafico := 4
	Elseif nGrafico == 2
		nGrafico := 10
	EndIf
EndIf
	
If lAnual
	nMeses	:= Val(cArqTmp->MES)
	For nMeses := nMeses To 12
		If oFolder:nOption == 1
			nPrevisto	:= cArqTmp->aEntr
			nRealizado	:= cArqTmp->rEntr
		Else
			nPrevisto	:= cArqTmp->aSaid
			nRealizado	:= cArqTmp->rSaid
		Endif		
		nMaxVal1 := MAX(nMaxVal1, nPrevisto)
		nMaxVal2 := MAX(nMaxVal2, nRealizado)		
		cArqTmp->(DbSkip())		
	Next
	nMax := MAX( nMaxVal1, nMaxVal2 )
	cArqTmp->(DbGoto(Val(cRecTmp)))
Else
	If oFolder:nOption == 1
		nPrevisto	:= cArqTmp->aEntr
		nRealizado	:= cArqTmp->rEntr
		nPrevAcm 	:= cArqTmp->aEAcm
		nRealAcm 	:= cArqTmp->rEAcm
	Else
		nPrevisto	:= cArqTmp->aSaid
		nRealizado	:= cArqTmp->rSaid
		nPrevAcm 	:= cArqTmp->aSAcm
		nRealAcm 	:= cArqTmp->rSAcm
	Endif

	nMaxVal1 := MAX(nPrevisto, nRealizado)
	nMaxVal2 := MAX(nPrevAcm, nRealAcm)

	nMax := MAX( nMaxVal1, nMaxVal2 )
EndIf
	
If nMax > 999999999999 // Trilhão
	nDivisor := 1000000000000
	cDivisor := "Valores exibidos em Trilhões"
ElseIf nMax > 999999999 // Bilhão
	nDivisor := 1000000000
	cDivisor := "Valores exibidos em Bilhões"
ElseIf nMax > 999999 // Milhão
	nDivisor := 1000000
	cDivisor := "Valores exibidos em Milhões"
EndIf	

nSerie 	:= 0 

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD  
				
@ -04, nLeft MSGRAPHIC oGraphic SIZE nBottom,nRight OF oDlg PIXEL

oBtnGrap:Enable()
oBtnSav:Enable()
oBtnPrn:Enable()
oBtnPrev:Enable()
oBtnNext:Enable()
oBtnMail:Enable()

oGraphic:SetMargins( 2, 8, 8, 8 ) 
oGraphic:Align := CONTROL_ALIGN_ALLCLIENT

oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )

If lAnual	
	oGraphic:SetTitle( 	STR0052 + Trim(cArqTmp->DESCR) + " - 01/01/" + Str(Year(MV_PAR07), 4) + " a " +; //"Natureza "
						"31/12/" + Str(Year(MV_PAR07), 4) + " em " +;
	GetMv("MV_MOEDA"+Str(mv_par06,1)), cDivisor, CLR_HRED , A_LEFTJUST , GRP_TITLE )
Else
	oGraphic:SetTitle( STR0052 + Trim(cArqTmp->DESCR) + STR0053 + StrZero(Month(mv_par08), 2) + "/" +; //"Natureza "###" - Mes "
	Str(Year(mv_par08), 4) + " em " +;
	GetMv("MV_MOEDA"+Str(mv_par06,1)), cDivisor, CLR_HRED , A_LEFTJUST , GRP_TITLE )
Endif

oGraphic:SetTitle( 	STR0001 + If(lAnual, STR0050, STR0051), "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //" - Anual"###" - Mes"

oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO, .T.)

nSerie   := oGraphic:CreateSerie(nGrafico, STR0047) // Previsto
nSerie2  := oGraphic:CreateSerie(nGrafico, STR0048) // Realizado
nSerie3  := oGraphic:CreateSerie(nGrafico, STR0049) // Orçado

If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR 
	If lAnual
		aColuna  	:= {{ STR0054, STR0049, STR0048, STR0047 }} //"Data de Referencia", "Orçado", "Realizado", "Previsto"
		nMeses 	 	:= Val(cArqTmp->MES)

		For nMeses := nMeses To 12
			If oFolder:nOption == 1
				nPrevisto	:= cArqTmp->aEntr / nDivisor
				nRealizado	:= cArqTmp->rEntr / nDivisor
			Else
				nPrevisto	:= cArqTmp->aSaid / nDivisor
				nRealizado	:= cArqTmp->rSaid / nDivisor
			Endif

			SE7->(dbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(MV_PAR07),4)))
			nOrcado	:= GetOrcado(nMeses)

			Aadd(aColuna, { 	"31/" + StrZero(nMeses, 2) + "/" + Str(Year(MV_PAR07), 4),;
								Trans(nOrcado, TM(nOrcado,18,nDecs)),;
								Trans(nRealizado, TM(nRealizado,18,nDecs)),;
								Trans(nPrevisto, TM(nPrevisto,18,nDecs)) } )
							
			oGraphic:Add(nSerie, 	nPrevisto, 	STR0055 + StrZero(nMeses, 2), CLR_HGREEN) // "Mes "
			oGraphic:Add(nSerie2, 	nRealizado, STR0055 + StrZero(nMeses, 2), CLR_HRED)
			oGraphic:Add(nSerie3, 	nOrcado, 	STR0055 + StrZero(nMeses, 2), CLR_HBLUE)
			
			cArqTmp->(DbSkip())
		Next

	Else
		If oFolder:nOption == 1
			nPrevisto	:= cArqTmp->aEntr / nDivisor
			nRealizado	:= cArqTmp->rEntr / nDivisor
			nPrevAcm 	:= cArqTmp->aEAcm / nDivisor
			nRealAcm 	:= cArqTmp->rEAcm / nDivisor
		Else
			nPrevisto	:= cArqTmp->aSaid / nDivisor
			nRealizado	:= cArqTmp->rSaid / nDivisor
			nPrevAcm 	:= cArqTmp->aSAcm / nDivisor
			nRealAcm 	:= cArqTmp->rSAcm / nDivisor 
		Endif
		
		nOrcado	:= Iif(SE7->(dbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(mv_par08), 4))), GetOrcado(month(mv_par08)), 0)

		//"Data de Referencia", "Previsto", "Realizado", "Orçado"
		aColuna := {{ STR0054, STR0047, STR0048, STR0049},;  
						{ STR0055 + StrZero(Month(mv_par08), 2) + "/" +; //"Mes "
							Str(Year(mv_par08), 4),;
							Trans(nPrevisto, TM(nPrevisto,18,nDecs)),; 
							Trans(nRealizado, TM(nRealizado,18,nDecs)),;
							Trans(nOrcado, TM(nOrcado,18,nDecs)) }}	
		
		If lAcumul
			oGraphic:Add(nSerie, 	nPrevisto, 		STR0055 + StrZero(Month(mv_par08), 2), 	CLR_HGREEN) // Previsto
			oGraphic:Add(nSerie, nPrevAcm, "Acumulado", CLR_HGREEN) // Previsto Acumulado


			oGraphic:Add(nSerie2, 	nRealizado, 	STR0055 + StrZero(Month(mv_par08), 2),	CLR_HRED) // Realizado
			oGraphic:Add(nSerie2, nRealAcm, "Acumulado", CLR_HRED) // Realizado Acumulado

			oGraphic:Add(nSerie3, 	nOrcado, 		STR0055 + StrZero(Month(mv_par08), 2), 	CLR_HBLUE) // Orçado 

			
			For nVezes := 1 To 12
				nOrcAcm += Iif(SE7->(DbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(mv_par08), 4))), GetOrcado(nVezes), 0)
			Next 	
			
			oGraphic:Add(nSerie3, nOrcAcm, "Acumulado", CLR_HBLUE)  // Orçado Acumulado 	
		Elseif nGrafico == 10
			oGraphic:Add(nSerie, 	nPrevisto, 		STR0047, 	CLR_HGREEN) 	// Previsto
			oGraphic:Add(nSerie2, 	nRealizado, 	STR0048,	CLR_HRED) 		// Realizado
			oGraphic:Add(nSerie3, 	nOrcado, 		STR0049, 	CLR_HBLUE) 		// Orçado
		Else
			oGraphic:Add(nSerie, 	nPrevisto, 		STR0055 + StrZero(Month(mv_par08), 2), 	CLR_HGREEN) 	// Previsto
			oGraphic:Add(nSerie2, 	nRealizado, 	STR0055 + StrZero(Month(mv_par08), 2),	CLR_HRED) 		// Realizado
			oGraphic:Add(nSerie3, 	nOrcado, 		STR0055 + StrZero(Month(mv_par08), 2), 	CLR_HBLUE) 		// Orçado   
		Endif	
	Endif
Else
	ApMsgAlert(STR0057) //"Não foi possível criar a série."
Endif

oGraphic:l3d := l3d

aGraficos[oFolder:nOption] := { oGraphic, 	aColuna, { 360, 2100, 1420 } }

If oGraphic:l3D	
	oBtn2D:Show()
	oBtn3D:Hide()
	oBtnPrev:Enable()
	oBtnNext:Enable()
Else	
	oBtn3D:Show()
	oBtn2D:Hide()	
	oBtnPrev:Disable()
	oBtnNext:Disable()	
Endif	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720GRes ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 31.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta grafico do resumo das operacoes das naturezas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720GRes                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Res(oDlg,aTotais,lAnual,mv_pargf)
Local nMeses  
Local nDireito := 0
Local nRodape  := 0
Local lAcumul  := (!lAnual .And. MV_PAR07 == 1)
Local l3d	   := .F.  

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

If !lAcumul
	If mv_pargf == 1
		mv_pargf := 4
	Elseif mv_pargf == 2
		mv_pargf := 10
	EndIf
EndIf

If SetMDIChild()
	nDireito := (oDlg:nRight * 10) / 2.1 
	nRodape  := ((oDlg:nBottom * 230) / 2.1) - 110
Else
	nDireito := (oDlg:nRight) / 2.1 
	nRodape  := ((oDlg:nBottom) / 2.1) - 110	
EndIf

@ 02, 04 MSGRAPHIC oGraphic SIZE nDireito ,	 nRodape OF oFolder:aDialogs[3] PIXEL
	
oBtnGrap:Enable()
oBtnSav:Enable()
oBtnPrn:Enable()
oBtnPrev:Enable()
oBtnNext:Enable()
oBtnMail:Enable()

oGraphic:SetMargins( 2, 8, 8, 8 )
oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )

If lAnual
	oGraphic:SetTitle( 	STR0058 + Str(Year(MV_PAR07), 4) +; //"Resumo Entradas X Saidas - 01/01/"
						" a " + "31/12/" + Str(Year(MV_PAR07), 4) + " em " +;
	GetMv("MV_MOEDA"+Str(mv_par06,1)), "", CLR_HRED , A_LEFTJUST , GRP_TITLE )
Else
	oGraphic:SetTitle( 	STR0059 + StrZero(Month(mv_par08), 2) + "/" +; //"Resumo Entradas X Saidas  - Mes "
	Str(Year(mv_par08), 4) + STR0060 +; //" em "
	GetMv("MV_MOEDA"+Str(mv_par06,1)), "", CLR_HRED , A_LEFTJUST , GRP_TITLE )
Endif
oGraphic:SetTitle( 	STR0001 + If(lAnual, STR0050, STR0051), "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //" - Anual"###" - Mes"

If lAnual
	aColuna := { { STR0054, STR0049, STR0048, STR0047 } } //"Data de Referencia"
	nSerie  := oGraphic:CreateSerie(mv_pargf, STR0047)
	nSerie2 := oGraphic:CreateSerie(mv_pargf, STR0048)
	nSerie3 := oGraphic:CreateSerie(mv_pargf, STR0049)
	For nMeses := 2 To 13
		Aadd(aColuna, { 	"31/" + StrZero(nMeses - 1, 2) + "/" + Str(Year(MV_PAR07), 4),;
							Trans(aTotais[3][5,nMeses] - aTotais[3][6,nMeses], TM(0,18,nDecs)),;
							Trans(aTotais[3][2,nMeses] - aTotais[3][4,nMeses], TM(0,18,nDecs)),;
							Trans(aTotais[3][1,nMeses] - aTotais[3][3,nMeses], TM(0,18,nDecs)) } )

		oGraphic:Add(nSerie, 	aTotais[3][1,nMeses] - aTotais[3][3,nMeses], STR0055 + StrZero(nMeses - 1, 2), CLR_HGREEN)
		oGraphic:Add(nSerie2, 	aTotais[3][2,nMeses] - aTotais[3][4,nMeses], STR0055 + StrZero(nMeses - 1, 2), CLR_HRED)
		oGraphic:Add(nSerie3, 	aTotais[3][5,nMeses] - aTotais[3][6,nMeses], STR0055 + StrZero(nMeses - 1, 2), CLR_HBLUE)
	
	Next
Else
	aColuna  := {{ STR0054, STR0047, STR0048, STR0049 },; //"Data de Referencia", "Previsto", "Realizado", "Orçado"
					{ STR0055 + StrZero(Month(mv_par08), 2) + "/" +; //"Mes "
						Str(Year(mv_par08), 4),;
						Trans(aTotais[1,1] - aTotais[1,2], TM(0,18,nDecs)),; 
						Trans(aTotais[1,3] - aTotais[1,4], TM(0,18,nDecs)),;
						Trans(aTotais[1,5] - aTotais[1,6], TM(0,18,nDecs)) }}

	If 	(aTotais[1,1] - aTotais[1,2] # 0) .Or.;
		(aTotais[1,7] - aTotais[1,8] # 0)	

		nSerie := oGraphic:CreateSerie(mv_pargf, StrZero(Month(mv_par08), 2))
		
		If lAcumul
			oGraphic:Add(nSerie, aTotais[1,1] - aTotais[1,2], STR0055 + StrZero(Month(mv_par08), 2), CLR_HGREEN) // Previsto
			oGraphic:Add(nSerie, aTotais[1,7] - aTotais[1,8], "Acumulado", CLR_HGREEN)  //"Acumulado - Previsto"
		Elseif mv_pargf == 10
			oGraphic:Add(nSerie, aTotais[1,1] - aTotais[1,2], STR0047, CLR_HGREEN) // Previsto
		Else
			oGraphic:Add(nSerie, aTotais[1,1] - aTotais[1,2], STR0055 + StrZero(Month(mv_par08), 2), CLR_HGREEN) // Previsto
		Endif
	Endif
		
	If 	(aTotais[1,3] - aTotais[1,4] # 0) .Or.;
		(aTotais[1,9] - aTotais[1,10] # 0)
		
		nSerie2 := oGraphic:CreateSerie(mv_pargf, StrZero(Month(mv_par08), 2))

		If lAcumul	
			oGraphic:Add(nSerie2, aTotais[1,3] - aTotais[1,4], STR0055 + StrZero(Month(mv_par08), 2), CLR_HRED)
			oGraphic:Add(nSerie2, aTotais[1,9] - aTotais[1,10], "Acumulado", CLR_HRED) //"Acumulado - Realizado"
		Elseif mv_pargf == 10
			oGraphic:Add(nSerie2, aTotais[1,3] - aTotais[1,4], STR0048, CLR_HRED)
		Else
			oGraphic:Add(nSerie2, aTotais[1,3] - aTotais[1,4], STR0055 + StrZero(Month(mv_par08), 2), CLR_HRED)
		Endif
	Endif
	
	If 	(aTotais[1,5] - aTotais[1,6] # 0) .Or.;
		(aTotais[1,11] - aTotais[1,12] # 0)
	
		nSerie3 := oGraphic:CreateSerie(mv_pargf, StrZero(Month(mv_par08), 2))	
					
		If lAcumul
			oGraphic:Add(nSerie3, aTotais[1,5] - aTotais[1,6], STR0055 + StrZero(Month(mv_par08), 2), CLR_HBLUE)
			oGraphic:Add(nSerie3, aTotais[1,11] - aTotais[1,12],  "Acumulado", CLR_HBLUE)	 //"Acumulado - "		
		Elseif mv_pargf == 10
			oGraphic:Add(nSerie3, aTotais[1,5] - aTotais[1,6], STR0049, CLR_HBLUE)	
		Else
			oGraphic:Add(nSerie3, aTotais[1,5] - aTotais[1,6], STR0055 + StrZero(Month(mv_par08), 2), CLR_HBLUE)	
		Endif
	Endif
Endif

oGraphic:l3d := l3d

aGraficos[3] := { oGraphic, 	aColuna, { 360, 2100, 1420 } }

If oGraphic:l3D
	oBtn2D:Show()
	oBtn3D:Hide()	
	oBtnPrev:Enable()
	oBtnNext:Enable()		
Else		
	oBtn3D:Show()
	oBtn2D:Hide()
	oBtnPrev:Disable()
	oBtnNext:Disable()
Endif	

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720Tmp  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 29.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta temporario para apresentacao dos valores por natureza   ³±±
±±³          ³ E o resumo de entradas e saidas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720Tmp                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Tmp(lAnual, oDlg, mv_pargf)

Local aArray
Local lRefresh
Local nTotais 	:= 0
Local nLaco 	:= 0

nDecs := MsDecimais(mv_par06)

If ! Empty(cArqTmp)
	dbSelectarea("cArqTmp")
	cArqTmp->( dbCloseArea() )
	Ferase(cArqTmp+GetDBExtension())
	Ferase(cArqTmp+OrdBagExt())

	#IFDEF TOP
		If TcSrvType() == "AS/400"
			Ferase(cIndex1+OrdBagExt())
			Ferase(cIndex2+OrdBagExt())
		Endif
	#ELSE
		Ferase(cIndex1+OrdBagExt())
		Ferase(cIndex2+OrdBagExt())
		Ferase(cIndex3+OrdBagExt())
	#ENDIF
Endif

If lAnual
	Finc730Tmp(oDlg, mv_pargf)
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ a formata‡„o do c¢digo das naturezas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMascNat := GetMV("MV_MASCNAT")
cMapa    := "123456789"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta matriz informa em que posicoes seao feitas as quebras.   ³
//³ 1-Byte inicial da quebra, 2-Quantidade de caracteres.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNiveis  := {}
    	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta matriz armazena as chaves de quebra e os totalizadores parciais.  ³
//³ 1-Chave, 2-A Realizar, 3-Realizado e 4-Or‡ado                          ³
//³ 5-A Realizar Acum. 6-Realizado Acumulado e 7-Orcado acumulado 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQuebras := {}
For nLaco := 1 to len( cMascNat )
	nByte := Val( Substr( cMascNat,nLaco,1 ) )
	If nByte > 0
		AAdd( aNiveis  , { Val(Left(cMapa,1)) , nByte} )
		AAdd( aQuebras , { "", 0, 0, 0 ,0 ,0 ,0} )
		cMapa := Subst(cMapa,nByte+1,Len(cMapa)-nByte)
	Endif
End

Processa( { || aTotais := Fin720Cria(@cArqTmp, @cIndex1, @cIndex2, @cIndex3, .F., aNiveis, aQuebras, , , aSelFil) })

Finc720Res(oDlg,aTotais,lAnual,mv_pargf)

aResumo		:= aTotais[3]
aQuebras	:= aTotais[2]

lRefresh := .F.
If !lAnual .And. MV_PAR07 == 1
	If oResumo == Nil
		oResumo	:= TWBrowse():New( 2,2,aPosObj[1,4],080,,{aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]},{30,38,38,30,38,38,30,65,65},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oResumo:aHeaders := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]}
		oResumo:aColumns := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]}
		oResumo:aColSizes := {30,38,38,30,38,38,30,65,65}
		lRefresh := .T.
	Endif
Else
	If oResumo = Nil
		oResumo	:= TWBrowse():New( 2,2,aPosObj[1,4],080,,{aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]},{31,85,31,85,31,85},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oResumo:aHeaders := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]}
		oResumo:aColumns := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]}
		oResumo:aColSizes := {31,85,31,85,31,85}
		lRefresh := .T.
	Endif
Endif
aArray := AClone(aResumo)

aResumo	:= {}
For nTotais := 2 To Len(aArray)
	Aadd(aResumo, aArray[nTotais])
Next

oResumo:SetArray(aResumo)
If !lAnual .And. MV_PAR07 == 1
	oResumo:bLine := { || { 	aResumo[oResumo:nAT][1], aResumo[oResumo:nAT][2],;
								aResumo[oResumo:nAT][3], aResumo[oResumo:nAT][4],;
								aResumo[oResumo:nAT][5], aResumo[oResumo:nAT][6],;
								aResumo[oResumo:nAT][7], aResumo[oResumo:nAT][8],;
								aResumo[oResumo:nAT][9]} }
Else
	oResumo:bLine := { || { 	aResumo[oResumo:nAT][1], Space(15) + aResumo[oResumo:nAT][2],;
								aResumo[oResumo:nAT][3], Space(15) + aResumo[oResumo:nAT][4],;
								aResumo[oResumo:nAT][5], Space(15) + aResumo[oResumo:nAT][6]} }
Endif
oResumo:lColDrag := .T.
oResumo:lMChange := .T.
If lRefresh
	oResumo:Refresh()
Endif

@ 082, 002 	To aPosObj[1,3],aPosObj[1,4] LABEL STR0061 OF oFolder:aDialogs[4]; //"Quebras por Natureza"
			COLOR CLR_HBLUE PIXEL

If Len(aQuebras) = 0
	HELP (" ",1,"SEMDADOS")
	Return
Endif

lRefresh := .F.
If !lAnual .And. MV_PAR07 == 1
	If oQuebras = Nil
		oQuebras := TWBrowse():New( 090,4,aPosObj[1,4] - 8,aPosObj[1,3]-aPosObj[1,1]-130,,;		
		{"",AllTrim(aResumo[1][1]) + " Mes",AllTrim(aResumo[1][1]) + " Acumulado",;
			AllTrim(aResumo[2][1]) + " Mes",AllTrim(aResumo[2][1]) + " Acumulado",;
			AllTrim(aResumo[4][1]) + " Mes",AllTrim(aResumo[4][1]) + " Acumulado"},;
			{75,48,55,48,55,48,55},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oQuebras:aHeaders := {"",	AllTrim(aResumo[1][1]) + " Mes",;
									AllTrim(aResumo[1][1]) + " Acumulado",;
									AllTrim(aResumo[2][1]) + " Mes",;
									AllTrim(aResumo[2][1]) + " Acumulado",;
									AllTrim(aResumo[4][1]) + " Mes",;
									AllTrim(aResumo[4][1]) + " Acumulado"}
		oQuebras:aColumns := {"",	AllTrim(aResumo[1][1]) + " Mes",;
									AllTrim(aResumo[1][1]) + " Acumulado",;
									AllTrim(aResumo[2][1]) + " Mes",;
									AllTrim(aResumo[2][1]) + " Acumulado",;
									AllTrim(aResumo[4][1]) + " Mes",;
									AllTrim(aResumo[4][1]) + " Acumulado"}
		oQuebras:aColSizes := {75,48,55,48,55,48,55}
		lRefresh := .T.
	Endif
Else	
	If oQuebras = Nil
		oQuebras := TWBrowse():New( 090,4,aPosObj[1,4] - 8,aPosObj[1,3]-aPosObj[1,1]-130,,{"",aResumo[1][1],aResumo[2][1],aResumo[4][1]},{105,85,85,85},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		lRefresh := .T.
		oQuebras:aHeaders := {"",aResumo[1][1],aResumo[2][1],aResumo[4][1]}
		oQuebras:aColumns := {"",aResumo[1][1],aResumo[2][1],aResumo[4][1]}
		oQuebras:aColSizes := {105,85,85,85}
	Endif
Endif
oQuebras:lColDrag := .T.
oQuebras:lMChange := .T.
oQuebras:SetArray(aQuebras)

If !lAnual .And. MV_PAR07 == 1
	oQuebras:bLine := { || { 	aQuebras[oQuebras:nAT][1],;
								Trans(aQuebras[oQuebras:nAT][2],;
								TM(aQuebras[oQuebras:nAT][2],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][5],;
								TM(aQuebras[oQuebras:nAT][5],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][3],;
								TM(aQuebras[oQuebras:nAT][3],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][6],;
								TM(aQuebras[oQuebras:nAT][6],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][4],;
								TM(aQuebras[oQuebras:nAT][4],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][7],;
								TM(aQuebras[oQuebras:nAT][7],18,nDecs)) } }
Else
	oQuebras:bLine := { || { 	aQuebras[oQuebras:nAT][1], Space(15) +;
								Trans(	aQuebras[oQuebras:nAT][2],;
										TM(aQuebras[oQuebras:nAT][2],18,nDecs)),;
								Space(15) + Trans(aQuebras[oQuebras:nAT][3],;
											TM(aQuebras[oQuebras:nAT][3],18,nDecs)),;
								Space(15) + Trans(aQuebras[oQuebras:nAT][4],;
											TM(aQuebras[oQuebras:nAT][4],18,nDecs))} }
Endif										

If lRefresh
	oQuebras:Refresh()
Endif

Return

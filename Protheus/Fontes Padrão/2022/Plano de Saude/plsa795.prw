
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSC130.CH"
#INCLUDE "DBTREE.CH"
#include "MSGRAPHI.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSA795  ³ Autor ³ Geraldo Felix Junior  ³ Data ³ 21-06-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta grafica para axilio a auditoria...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA795()                                                    ³±±
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
Function PLSA795(aDados, aCab, cTipo, aPropriedades )

LOCAL aSize		:= {}
LOCAL aObjects	:= {}
LOCAL aPages	:= {}
LOCAL cCadastro := "Consulta Custo / Receita"
LOCAL nTree
LOCAL oDlg,ni
LOCAL lAnual	:= .F.
LOCAL aCbx 		:= { STR0019, STR0020, STR0021, STR0022, STR0023, STR0024,; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
					 STR0025, STR0026, STR0027,; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
					 STR0028, STR0029, STR0030, STR0031, STR0032, STR0033 } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
LOCAL aRet		:= {}
LOCAL mv_pargf 	:= 4
LOCAL aTrees 	:= {}
LOCAL cPerg 	:= "PLC130"
LOCAL lTree
LOCAL aNaturezas:= {}
LOCAL cCodigo

Private aRotina :=	MenuDef()
Private oGraphic
PRIVATE nSerie
PRIVATE oNaturezas
Private cColuna1	:= STR0047
PRIVATE cColuna2 	:= STR0048
PRIVATE cColuna3 	:= STR0049 //"Item"###"Sub-Grupo"###"Grupo"

Private cArqTmp 	:= ""
PRIVATE cIndex1 	:= "" 
PRIVATE cIndex2 	:= "" 
PRIVATE cIndex3 	:= ""
Private aTotais     := {}
PRIVATE aGraficos 	:= { {,,},{,,}, {,,} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Data de ?                                        ³
//³ mv_par02 // Data Ate ?                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMainWnd:ReadClientCoors()

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

DEFINE  MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 	nTop,nLeft TO;
																nBottom,nRight;
																STYLE nOR(WS_VISIBLE,WS_POPUP)

@00,00 BITMAP oBmp1 RESNAME "FAIXASUPERIOR" 	SIZE 1200,50 NOBORDER PIXEL OF oDlg
oBmp1:align:= CONTROL_ALIGN_TOP

oFolder := TFolder():New(	50,0,{"Niveis"},aPages,oDlg,,,,.T., .F.,	nRight-nLeft,;
							nBottom-nTop-50,)
							
For ni := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
Next

@ 75,10 	BTNBMP oBtn RESOURCE "S4WB005N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0010  //"Recortar"
@ 75,38 	BTNBMP oBtn RESOURCE "S4WB006N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0011  //"Copiar"
@ 75,66 	BTNBMP oBtn RESOURCE "S4WB007N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0012  //"Colar"
@ 75,94 	BTNBMP oBtn RESOURCE "S4WB008N" 	SIZE 25,25 ACTION Calculadora() MESSAGE STR0013  //"Calculadora..."
@ 75,122 	BTNBMP oBtn RESOURCE "S4WB009N" 	SIZE 25,25 ACTION Agenda() MESSAGE STR0014  //"Agenda..."
@ 75,150 	BTNBMP oBtn RESOURCE "S4WB010N" 	SIZE 25,25 ACTION OurSpool() MESSAGE STR0015  //"Gerenciador de ImpressÆo..."
@ 75,178 	BTNBMP oBtn RESOURCE "S4WB016N" 	SIZE 25,25 ACTION HelProg() MESSAGE STR0016  //"Help de Programa..."

@ 75, 234 	BTNBMP oBtnGrap		RESOURCE "AREA"	SIZE 25,25;
			ACTION (ParamBox( {	{3,STR0034,mv_pargf,aCbx,50,"",.F.}},STR0035,@aRet),; //"Tipo de grafico"###"Parametros"
					If(Len(aRet) > 0, mv_pargf := aRet[1],),;
					If(oFolder:nOption < 2,; // nOption sempre será 1: Folder = {"Niveis"} 
					PLS795Grap(aDados, aCab,,mv_pargf, cTipo, aPropriedades),.T.));
			MESSAGE STR0034  //"Tipo de grafico"
			
@ 75, 262 	BTNBMP oBtn3D RESOURCE "GRAF3D" 		SIZE 25,25;
			ACTION If(oFolder:nOption < 4 .And. aGraficos[oFolder:nOption][1] <> Nil,;
			(Ctb020Graph(aGraficos[oFolder:nOption][1],;
			"EFEITO", oBtn3D, oBtn2D),(oBtnNext:Disable(),oBtnPrev:Disable())), .T.);
			MESSAGE "3D" 
			
@ 75, 262 	BTNBMP oBtn2D RESOURCE "GRAF2D" 		SIZE 25,25;
			ACTION If(oFolder:nOption < 4 .And. aGraficos[oFolder:nOption][1] <> Nil,;
			(Ctb020Graph(aGraficos[oFolder:nOption][1],;
			"EFEITO", oBtn3D, oBtn2D),(oBtnNext:Enable(),oBtnPrev:Enable())),.T.);
			MESSAGE "2D" 
			
@ 75, 290 BTNBMP oBtnSav	RESOURCE "SALVAR" 	SIZE 25,25 ACTION GrafSavBmp( aGraficos[oFolder:nOption][1] ) MESSAGE STR0036  //"Salva BMP"
@ 75, 318 BTNBMP oBtnPrev 	RESOURCE "PGPREV" 	SIZE 25,25 ACTION Ctb020Graph(aGraficos[oFolder:nOption][1], "ROTACAO-", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0037  //"Rotacao -"
@ 75, 346 BTNBMP oBtnNext 	RESOURCE "PGNEXT" 	SIZE 25,25 ACTION Ctb020Graph(aGraficos[oFolder:nOption][1], "ROTACAO+", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0038  //"Rotacao +"

@ 75, 374 BTNBMP oBtnPrn 	RESOURCE "PRINT03" 	SIZE 25,25 ACTION CtbGrafPrint(aGraficos[oFolder:nOption][1],cCadastro,{ cCadastro },aGraficos[oFolder:nOption][2], .F.,;
							{ 360, 0900, 1500, 2100 },;
							aGraficos[oFolder:nOption][3]) MESSAGE STR0040 //"Comparacao de saldos"###"Imprimir grafico"

@ 75, 402 BTNBMP oBtnMail 	RESOURCE "BMPPOST" 	SIZE 25,25 ACTION PmsGrafMail(aGraficos[oFolder:nOption][1],cCadastro,{cCadastro},aGraficos[oFolder:nOption][2]) MESSAGE STR0041 //"Enviar por E-Mail"

@ 75,430 BTNBMP oBtn RESOURCE "FINAL" SIZE 25,25 ACTION oDlg:End() MESSAGE STR0042 //"Fechar"

//PLS795Tmp(lAnual, oDlg, mv_pargf, aNaturezas)

nFolder := 1
oFolder:aDialogs[nFolder]:oFont := oDlg:oFont
oTree  := DbTree():New( 2, 2,((nBottom-nTop)/2)-50, 090,oFolder:aDialogs[nFolder],,,.T.)
oTree:lShowHint:= .F. 
oTree:BuildTrb(100, 2)
//oTree:currentnodeid := 
	
Aadd(aTrees, oTree)

oTree:bChange := {|x| PLS795Grap(aDados, aCab, Val(x:currentnodeid),mv_pargf, cTipo, aPropriedades ) }
oTree:BeginUpdate()   
oTree:SetEnable()

DbSelectArea("BF0")		// Naturezas de Saude
DbSetOrder(1)
If lAnual
	cCodigo := mv_par02
Else
	cCodigo := mv_par05
Endif	         
     
If cTipo == '6'
	oTree:AddTree("Empresa"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	oTree:EndTree()                                   

	oTree:AddTree("Contrato"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	oTree:EndTree()
	
	oTree:AddTree("Subcontrato"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	oTree:EndTree()
	
	oTree:AddTree("Familia"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	oTree:EndTree()
	
	oTree:AddTree("Usuario"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	oTree:EndTree()
Else
		oTree:AddTree(aPropriedades[2]+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")

			oTree:AddTreeItem("Quantidade"+Space(100),"LJPRECO","LJPRECO","VLR")
	//		oTree:AddTree("Quantidade"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	//		oTree:EndTree()
			
			oTree:AddTreeItem("Custo"+Space(100),"LJPRECO","LJPRECO","VLR")
	//		oTree:AddTree("Custo"+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
	//		oTree:EndTree()
		
	oTree:EndTree()
Endif

//oTree:EndTree()
oTree:EndUpdate()
oTree:Refresh()

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
							(If(X > 3 .Or. aGraficos[x][1] = Nil,;
							(oBtn2D:Hide(), oBtn3D:Hide()),;
							(If(aGraficos[x][1]:l3D, (oBtn3D:Show(),;
							  oBtn2D:Hide(),oBtnPrev:Enable(),oBtnNext:Enable()),;
							 (oBtn2D:Show(),oBtn3D:Hide(),oBtnPrev:Disable(),;
							 oBtnNext:Disable()))))) }

ACTIVATE MSDIALOG oDlg ON INIT (oBtnGrap:Disable(),;
								oBtn2d:Hide(),;
								oBtnPrev:Disable(),;
								oBtnNext:Disable(),;
								oBtnSav:Disable(),;
								oBtnPrn:Disable(),;
								oBtnMail:Disable(),;
								PLS795Grap(aDados, aCab,,mv_pargf, cTipo, aPropriedades))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PLS795Grap  ³ Autor ³ Geraldo Felix Junior. ³ Data ³ 21.06.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta grafico de comparacao entre as naturezas de saude       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLS795Grap                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS795Grap(aDados, aCab, nNivel, nGrafico, cTipo, aPropriedades)

Local oBold
LOCAL nSerie2 		:= 0
LOCAL nCnt			:= 0
LOCAL nPos			:= 0
Local cPicCusto 	:= "@E 999,999,999.99"
LOCAL aNomMes		:= {'JAN',;
						'FEV',;
						'MAR',;
						'ABR',;
						'MAI',;
						'JUN',;
						'JUL',;
						'AGO',;
						'SET',;
						'OUT',;
						'NOV',;
						'DEZ'}

LOCAL oDlg		:= oFolder:aDialogs[oFolder:nOption]
LOCAL nTop		:= 6
LOCAL nLeft		:= 100
LOCAL nBottom	:= aPosObj[1][4]-100
LOCAL nRight 	:= aPosObj[1,3]-35  
LOCAL cNivel 	:= ''	
LOCAL nOrdem 	:= aPropriedades[1]
LOCAL cTxtFunc  := aPropriedades[2]
LOCAL nChave	:= aPropriedades[3]
LOCAL cConteudo := aPropriedades[4]
LOCAL lFirst	:= .T. ,i
DEFAULT nNivel	:= 1

nSerie 	:= 0
     
If nNivel == 1
	cNivel := "Empresa"                
Elseif nNivel == 2
	cNivel := "Contrato"
Elseif nNivel == 3
	cNivel := "Subcontrato"
Elseif nNivel == 4
	cNivel := "Familia"
Elseif nNivel == 5
	cNivel := "Usuario"
Endif

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ nTop, nLeft MSGRAPHIC oGraphic SIZE nBottom,nRight OF oDlg PIXEL

If cTipo == '6'
	nCol1 := 150
	nCol2 := aPosObj[1][4]-(Len(cColuna3) * 15)
	@ aPosObj[1,3]-25,  240	SAY oTpColuna1 Var "CUSTOS" OF oDlg;
	COLOR CLR_HRED FONT oBold PIXEL
	
	@ aPosObj[1,3]-25,  aPosObj[1][4]-(Len(cColuna3) * 37)	SAY oTpColuna3;
	Var "RECEITAS" OF oDlg COLOR CLR_HBLUE;
	FONT oBold PIXEL
Else
//	@ aPosObj[1,3]-25,  aPosObj[1][4]-(Len(cColuna3) * 47)	SAY oTpColuna3;
//	Var Iif(nNivel <> 3, "QUANTIDADE","CUSTO" ) OF oDlg COLOR CLR_HBLUE;
//	FONT oBold PIXEL
Endif
	
oBtnGrap:Enable()
oBtnSav:Enable()
oBtnPrn:Enable()
oBtnPrev:Enable()
oBtnNext:Enable()
oBtnMail:Enable()
oBtn3D:Show()

oGraphic:SetMargins( 2, 8, 8, 8 )
oGraphic:L3D := .F.

oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )

If cTipo == '6'
	oGraphic:SetTitle("Custos / Receitas     -    "+cNivel,"", CLR_HBLUE , A_LEFTJUST , GRP_TITLE )
Else
	oGraphic:SetTitle("Utilizacao Mensal "+Iif(nNivel<>3,"(QTD)","(Custo)")+" - "+aPropriedades[2]+": "+Alltrim(aPropriedades[4]),"", CLR_HBLUE , A_LEFTJUST , GRP_TITLE )
Endif

oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)

nSerie   := oGraphic:CreateSerie(nGrafico)
If cTipo == '6'
	nSerie2  := oGraphic:CreateSerie(nGrafico)
Endif

If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR
	If cTipo == '6'
		For nCnt := 1 To Len(aDados)
			
			If aDados[nCnt][3] == nNivel .and. !Empty(aDados[nCnt][2]) .and.;
				aDados[nCnt][2] $ 'Custos, Receitas'
				
				For i := 4 To (Len(aDados[nCnt]))
					If 	aDados[nCnt][2] == 'Custos'
						oGraphic:Add(nSerie,  Iif(aDados[nCnt][i]==NIL,0,;
						aDados[nCnt][i]), aCab[i][1], CLR_HRED)
					Else
						oGraphic:Add(nSerie2, Iif(aDados[nCnt][i]==NIL,0,;
 						aDados[nCnt][i]), aCab[i][1], CLR_HBLUE)         
					Endif
				Next
				
			Endif
			
		Next
	Else
		If nNivel <> 1 .or. lFirst
			lFirst := .F.
			aAuxDados := {}
			For nCnt := 1 To Len(aDados)
				cAnoMes := Substr(dTos(cTod(aDados[nCnt][nChave])),1,6)
				If (nPos := Ascan(aAuxDados, {|x| x[1] == cAnoMes}) ) == 0
					Aadd(aAuxDados, {cAnoMes, Iif(nNivel<>3,Val(aDados[nCnt][5]),Val(aDados[nCnt][6])) })
				Else
					aAuxDados[nPos][2] += Iif(nNivel<>3,Val(aDados[nCnt][5]),Val(aDados[nCnt][6]))
				Endif
			Next
			//		aSort(aAuxDados,,,{|x| x[1] <= x[1]})
			For nCnt := 1 To Len(aAuxDados)
				oGraphic:Add(nSerie,  aAuxDados[nCnt][2], aNomMes[Val(Substr(aAuxDados[nCnt][1],5,2))]+"/"+;
				Substr(aAuxDados[nCnt][1],1,4), CLR_HBLUE)
			Next
		Endif
	Endif
ElseIf nSerie = GRP_CREATE_ERR .Or. nSerie2 = GRP_CREATE_ERR
	ApMsgAlert(STR0057) //"Não foi possível criar a série."
Endif

aGraficos[oFolder:nOption] := { oGraphic, {}, { 360, 2100, 1420 } }

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³ 	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := { { "aRotina para Visual", "AxVisual",	0, 2 , 0, Nil} }
Return(aRotina)

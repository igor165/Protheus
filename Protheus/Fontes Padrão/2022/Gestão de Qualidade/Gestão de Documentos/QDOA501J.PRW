#INCLUDE "FIVEWIN.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOA5010 ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 23/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Solicitacoes de Documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA5010()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QDOA501J()

Local oDlg
Local oBtn01
Local lFecha := .f.

Private oRad01
Private nRad01
Private oRad02
Private nRad02
Private cCadastro  := "Cadastro de Solicita‡äes"
Private cTpCopia   := "C¢pia Controlada"
Private cObjetivo  := " "
Private cMotRevi   := " "
Private cApElabo   := " "
Private cApRevis   := " "
Private cApAprov   := " "
Private cApHomol   := " "
Private cElabora   := " "
Private cRevisor   := " "
Private cAprovad   := " "
Private cHomolog   := " "
Private cSumario   := " "
Private cRodape    := " "
Private cNomRece   := " "
Private cNomFilial := Space( 40 )
Private cFilApSol  := Space( 02 )
Private cCodApSol  := Space( 06 )
Private cFilApDes  := Space( 02 )
Private cCodApDes  := Space( 06 )
Private cDtEmiss   := CtoD( "  /  /  " )
Private lPendencia := .f.
Private lCritica   := .f.
Private lIncDepois := .f.
Private lGeraRev   := .f.
Private lAltDoc    := .t.
Private Inclui     := .t.

DEFINE MSDIALOG oDlg;
       FROM     0, 0;
       TO       17.8, 44.8;
       TITLE    "Solicita‡äes";
       OF       oMainWnd 

@ 025, 005 BITMAP;
           RESOURCE "LAUDO";
           SIZE     052, 066;
           OF       oDlg;
           PIXEL

@ 002, 062 TO    060, 172;
           LABEL " Formato ";
           OF    oDlg; 
           PIXEL

@ 020, 067 RADIO oRad01;
           VAR   nRad01;
           ITEMS "Produtos",;
           		  "Sistemas";
			  3D;
           SIZE  100, 15; 
           OF    oDlg;
           PIXEL

@ 062, 062 TO    105, 172;
           OF    oDlg;
           PIXEL

DEFINE SBUTTON oBtn01;
       FROM    110, 105;
       TYPE    1;
       ENABLE;
       OF      oDlg;
       ACTION  ( lFecha:=.t., QDOA5012(), oDlg:End() )

DEFINE SBUTTON oBtn02;
       FROM    110, 142;
       TYPE    2;
       ENABLE;
       OF      oDlg;
       ACTION  ( lFecha:=.t., oDlg:End() )

ACTIVATE MSDIALOG oDlg;
         VALID    lFecha;
         CENTERED

Return Nil


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
/*/

 
As rotinas abaixo sao destinadas a utilizacao do cliente Jonhsons,


/*/	
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOA5012 ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 30/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Solicitacao de Especificacao( MDP ou MDS )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA5012()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                      				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QDOA5012

Local		aCores
Local		cIndTmp
Local		cCvTmp
Local		cFilTmp


Private 	cCadastro	:= "Solicitacoes"
Private 	aListID		:= {} 
Private 	aListWD		:= {}
Private 	aRotina 		:= {	{ "Pesquisar",	"AxPesqui",		0, 1},;	
									{ "Visualizar","SolVis5020",	0, 2},;	
									{ "Incluir",	"SolInc5020",	0, 3},;	
									{ "Alterar" ,	"SolAlt5020",	0, 4},;	
									{ "Excluir",	"SolVis5020",	0, 5},;
									{ "Baixar",		"SolBai5020",	0, 6};
								}	
Private 	bCampo 		:= { |nCPO| Field( nCPO ) }

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DbSelectArea( "QDP" )


cIndTmp					:= CriaTrab( Nil,.F. )
cCvTmp					:= "QDP->QDP_FILIAL + QDP->QDP_NUMSEQ"

If nRad01 == 1
	
	cFilTmp				:= "QDP->QDP_TPSOL=='MDP'" 

Elseif nRad01 == 2
	
	cFilTmp				:= "QDP->QDP_TPSOL=='MDS'" 

EndIf

IndRegua( "QDP", cIndTmp, cCvTmp, , cFilTmp, "Selecionando Solicitacoes" ) 

aCores					:= {	{ "QDP->QDP_PENDEN#'P'", 'ENABLE'	},;
									{ "QDP->QDP_PENDEN='P'", 'BR_AMARELO'};
								}

mBrowse( 6, 1, 22, 75, "QDP", , , , , , aCores )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SOLINC5020³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 30/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 																		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SOLINC5020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 							                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function SolInc5020( cAlias, nReg, nOpc )

Local		oDlg
Local 	oGet 
Local		oBtn01 
Local		oBtn02 
Local		oBtn03
Local		oBtn10
Local		oBtn11
Local		oChk01
Local		oCkh02 
Local		oRazao
Local		oNumSol
Local		oDocBase
Local		oDescSol
Local 	bCampo 		:= { |nCPO| Field( nCPO ) }

Local		lChk01 
Local		lChk02
Local 	lFecha		:= .f.
Local 	lInit 		:= .f.

Local 	cTitulo
Local		cCampo 

Local		nC
Local 	aFiles		:= {}
Local 	GetList		:= {}

Private 	oRadTipo

Private 	nUsado		:= 0
Private 	nCnt			:= 0
Private 	nRadTipo

Private 	cNumSol		:= Space( 20 )
Private 	cDocBase		:= Space( 50 )
Private 	cDescSol		:= Space( 30 )
Private 	cTpTXT		:= ""

Private 	aTELA[0][0]
Private 	aGETS[0]
Private 	aHeader[0]
Private 	aCols[0]
Private 	axTextos 	:= {}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DbselectArea("QDP")

For nC := 1 TO QDP->( FCount() )
	
	cCampo 					:= Eval( bCampo,nC )
	lInit 					:= .f.
	
	If ExistIni(cCampo)
		
		lInit 				:= .t.
		M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
		
	    If ValType( M->&( cCampo ) ) = "C"
	      
	        M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
		
		Endif
		
		If M->&( cCampo ) == NIL
			
			lInit 			:= .f.
		
		Endif
	
	Endif
	
	If !lInit
		
		M->&( cCampo ) 	:= FieldGet( nC )
		
		Do Case
		
			Case ValType( M->&( cCampo ) ) == "C"
			
				M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
		
			Case ValType( M->&( cCampo ) ) == "N"
			
				M->&( cCampo ) := 0
		
			Case ValType( M->&( cCampo ) ) == "D"
			
				M->&( cCampo ) := CtoD("  /  /  ")
		
			Case ValType( M->&( cCampo ) ) == "L"
			
				M->&( cCampo ) := .F.
		
		EndCase
		
	EndIf
	
Next nC



DbSelectArea( "QDP" )

If nRad01 == 1
	
	cNumSol			:= "MP" + qCodSol()

Elseif nRad01 == 2
	
	cNumSol			:= "MS" + qCodSol()

EndIf

M->QDP_NUMSEQ		:= cNumSol

If nRad01 == 1
	
	M->QDP_TPSOL	:= Alltrim( "MDP" )
	
Elseif nRad01 == 2
	
	M->QDP_TPSOL	:= Alltrim( "MDS" )

EndIf

SETAPILHA()

cTitulo:="Solicitacao de Modificacao de " + If(	nRad01 == 1,;
																"Produto ",;
																"Sistemas ";
															 )

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DEFINE 		MSDIALOG oDlg;
				FROM 		0, 0;
				TO 		20.2, 80;
				TITLE 	cTitulo;
				OF 		oMainWnd 

@ 003, 005 	TO 		45, 185;
				LABEL		" Solicitacao ";
				OF 		oDlg;
				PIXEL 

@ 013, 011 	SAY 		"Nr Solicitacao";
				SIZE 		60, 10;
				OF 		oDlg;
				PIXEL

@ 012, 055 	GET 		oNumSol;
				VAR		cNumSol;
				SIZE 		85, 10;
				WHEN 		.F.;
				OF 		oDlg;
				PIXEL

@ 029, 011 	SAY 		"Descricao";
				SIZE 		30, 10;
				OF 		oDlg;
				PIXEL

@ 028, 055 	GET 		oDescSol;
				VAR 		cDescSol;
				SIZE 		125, 10;
				OF			oDlg;
				PIXEL

@ 003, 190 	TO 		45, 305;
				LABEL		" Tipo ";
				OF 		oDlg;
				PIXEL 

@ 012, 200 	RADIO 	oRadTipo;
				VAR 		nRadTipo;
				ITEMS 	"Inclusao ",;
							"Alteracao",;
							"Cancelamento";
				3D;
				SIZE 		100, 10; 
				OF   		oDlg;
				PIXEL

@ 047, 005 	TO 		085, 102;
				LABEL		" Razao ";
				OF 		oDlg;
				PIXEL

@ 087, 005 	TO 		124, 102;
				LABEL 	" Observacoes ";
				OF 		oDlg;
				PIXEL

If !Empty( M->QDP_CHAVE )
	
	lchk01:=.t.
	lchk02:=.t.

Else
	
	lchk01:=.f.
	lchk02:=.f.

EndIf

@ 055, 010 	CHECKBOX 	oChk01;
				VAR			lChk01;
				PROMPT		"Editar Razao";
				SIZE 			90, 15;
				ON CLICK		If(	lChk01,;
										oBtn10:Enable(),;
										oBtn10:Disable();
								  );
				OF 			oDlg;
				PIXEL

@ 094, 010	CHECKBOX		oChk02;
				VAR			lChk02;
				PROMPT		"Editar Observacoes";
				SIZE 			90, 15;
				ON CLICK 	If( 	lChk02,;
										oBtn11:Enable(),;
										oBtn11:Disable();
								  );
				OF 			oDlg;
				PIXEL

@ 071, 080	BUTTON		oBtn10;
				PROMPT 		">>";
				SIZE 			15, 10;
				ACTION 		A5020Razao( nOpc );
				OF 			oDlg;
				PIXEL

oBtn10:Disable()

@ 110, 080	BUTTON		oBtn11;
				PROMPT 		">>";
				SIZE 			15, 10;
				ACTION 		A5020Obs( nOpc );
				OF 			oDlg;
				PIXEL

oBtn11:Disable()

oGet 			:= MSGetDados():New( 050, 107, 124, 305, 3, "A5020LinOk()", "", "", .t., , )

DbSelectArea( "QDP" )

DEFINE		SBUTTON	oBtn01;
				FROM 		130, 240;
				TYPE 		1;
				ENABLE;
				OF 		oDlg;
				ACTION 	( 	A5020gRVs( nOpc ),;
								lFecha:=.t.,;
								oDlg:End();
							)

DEFINE		SBUTTON	oBtn02;
				FROM 		130, 275;
				TYPE 		2;
				ENABLE;
				OF 		oDlg;
				ACTION 	(	lFecha := .t.,;
								oDlg:End();
							)

ACTIVATE 	MSDIALOG oDlg;
				VALID lFecha;
				CENTERED

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				
SETAPILHA()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SOLVIS5020³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 30/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 				  					 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SOLVIS5020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 							                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function	SolVis5020( cAlias, nReg, nOpc )

Local		oDlg
Local 	oGet 
Local		oBtn01 
Local		oBtn02 
Local		oBtn03
Local		oBtn10
Local		oBtn11
Local		oChk01
Local		oCkh02 
Local		oRazao
Local		oNumSol
Local		oDocBase
Local		oDescSol
Local 	bCampo 		:= { |nCPO| Field( nCPO ) }

Local		lChk01 
Local		lChk02
Local 	lFecha		:= .f.
Local 	lInit 		:= .f.

Local 	cTitulo
Local		cCampo 

Local		nC
Local 	aFiles		:= {}
Local 	GetList		:= {}

Private 	oRadTipo

Private 	nUsado		:= 0
Private 	nCnt			:= 0
Private 	nRadTipo

Private 	cNumSol		:= Space( 20 )
Private 	cDocBase		:= Space( 50 )
Private 	cDescSol		:= Space( 30 )
Private 	cTpTXT		:= ""

Private 	aTELA[0][0]
Private 	aGETS[0]
Private 	aHeader[0]
Private 	aCols[0]
Private 	axTextos 	:= {}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DbselectArea("QDP")

For nC := 1 To QDP->( FCount() )
	
	cCampo 		:= Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
	M->&cCampo	:= QDP->( FieldGet( FieldPos( cCampo ) ) )

Next

cNumSol			:= M->QDP_NUMSEQ
cDescSol			:= M->QDP_DESSOL
nRadTipo			:= M->QDP_TIPMD

DbSelectArea( "QDP" )

SETAPILHA()

cTitulo:="Solicitacao de Modificacao de " + If(	nRad01 == 1,;
																"Produto ",;
																"Sistemas ";
															 )

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DEFINE 		MSDIALOG oDlg;
				FROM 		0, 0;
				TO 		20.2, 80;
				TITLE 	cTitulo;
				OF 		oMainWnd 

@ 003, 005 	TO 		45, 185;
				LABEL		" Solicitacao ";
				OF 		oDlg;
				PIXEL 

@ 013, 011 	SAY 		"Nr Solicitacao";
				SIZE 		60, 10;
				OF 		oDlg;
				PIXEL

@ 012, 055 	GET 		oNumSol;
				VAR		cNumSol;
				SIZE 		85, 10;
				WHEN 		.F.;
				OF 		oDlg;
				PIXEL

@ 029, 011 	SAY 		"Descricao";
				SIZE 		30, 10;
				OF 		oDlg;
				PIXEL

@ 028, 055 	GET 		oDescSol;
				VAR 		cDescSol;
				SIZE 		125, 10;
				WHEN		.F.;
				OF			oDlg;
				PIXEL

@ 003, 190 	TO 		45, 305;
				LABEL		" Tipo ";
				OF 		oDlg;
				PIXEL 

@ 012, 200 	RADIO 	oRadTipo;
				VAR 		nRadTipo;
				ITEMS 	"Inclusao",;
							"Alteracao",;
							"Cancelamento";
				3D;
				SIZE 		100, 10; 
				OF   		oDlg;
				WHEN		.F.;				
				PIXEL

@ 047, 005 	TO 		085, 102;
				LABEL		" Razao ";
				OF 		oDlg;
				PIXEL

@ 087, 005 	TO 		124, 102;
				LABEL 	" Observacoes ";
				OF 		oDlg;
				PIXEL

If !Empty( M->QDP_CHAVE )
	
	lchk01:=.t.
	@ 055, 010 	CHECKBOX oChk01;
					VAR 		lChk01;
					PROMPT 	"Ver Razao";
					SIZE 		90, 15;
					WHEN 		.F.;
					OF 		oDlg;
					PIXEL

Else
	
	lchk01:=.f.
	@ 055, 010	CHECKBOX oChk01;
					VAR		lChk01;
					PROMPT	"Ver Razao";
					SIZE 		90, 15;
					WHEN 		.F.;
					OF 		oDlg;
					PIXEL

EndIf

If !Empty( M->QDP_CHAVE )
	
	@ 071, 080 	BUTTON 	oBtn10;
					PROMPT 	">>";
					SIZE 		15, 10;
					ACTION 	A5020Razao( nOpc );
					OF 		oDlg;
					PIXEL
	
	oBtn10:Enable()

Else
	
	@ 071, 080 	BUTTON 	oBtn10;
					PROMPT 	">>";
					SIZE 		15, 10;
					OF 		oDlg;
					PIXEL
	
	oBtn10:Disable()

EndIf

If !Empty( M->QDP_CHAVE )
	
	lchk02:=.t.
	@ 094, 010 	CHECKBOX oChk02;
					VAR 		lChk02;
					PROMPT 	"Ver Observacoes";
					SIZE 		90, 15;
					WHEN 		.F.;
					OF 		oDlg;
					PIXEL

Else
	
	lchk02:=.f.
	@ 094, 010	CHECKBOX oChk02;
					VAR		lChk02;
					PROMPT	"Ver Observacoes";
					SIZE 		90, 15;
					WHEN 		.F.;
					OF 		oDlg;
					PIXEL

EndIf

If !Empty( M->QDP_CHAVE )
	
	@ 110, 080 	BUTTON 	oBtn11;
					PROMPT 	">>";
					SIZE 		15, 10;
					ACTION 	A5020Obs( nOpc );
					OF 		oDlg;
					PIXEL
	
	oBtn11:Enable()

Else
	
	@ 110, 080 	BUTTON 	oBtn11;
					PROMPT 	">>";
					SIZE 		15, 10;
					OF 		oDlg;
					PIXEL
	
	oBtn11:Disable()

EndIf

oGet 			:= MSGetDados():New( 050, 107, 124, 305, 2 )

DbSelectArea( "QDP" )

DEFINE		SBUTTON	oBtn02;
				FROM 		130, 275;
				TYPE 		2;
				ENABLE;
				OF 		oDlg;
				ACTION 	(	lFecha:= .t.,;	
								If	(	nOpc == 5,;
										SolExc5020(),;
										.f.;
									),;
								oDlg:End();
							)

ACTIVATE 	MSDIALOG oDlg;
				VALID		lFecha;
				CENTERED

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SETAPILHA()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SOLALT5020³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 30/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SOLALT5020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 							                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function SolAlt5020(cAlias,nReg,nOpc)

Local		oDlg
Local 	oGet 
Local		oBtn01 
Local		oBtn02 
Local		oBtn03
Local		oBtn10
Local		oBtn11
Local		oChk01
Local		oCkh02 
Local		oRazao
Local		oNumSol
Local		oDocBase
Local		oDescSol
Local 	bCampo 		:= { |nCPO| Field( nCPO ) }

Local		lChk01 
Local		lChk02
Local 	lFecha		:= .f.
Local 	lInit 		:= .f.

Local 	cTitulo
Local		cCampo 

Local		nC
Local 	aFiles		:= {}
Local 	GetList		:= {}

Private 	oRadTipo

Private 	nUsado		:= 0
Private 	nCnt			:= 0
Private 	nRadTipo

Private 	cNumSol		:= Space( 20 )
Private 	cDocBase		:= Space( 50 )
Private 	cDescSol		:= Space( 30 )
Private 	cTpTXT		:= ""

Private 	aTELA[0][0]
Private 	aGETS[0]
Private 	aHeader[0]
Private 	aCols[0]
Private 	axTextos 	:= {}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DbselectArea( "QDP" )

For nC := 1 To QDP->( FCount() )
	
	cCampo := Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
	M->&cCampo := QDP->( FieldGet( FieldPos( cCampo ) ) )

Next

cNumSol			:= M->QDP_NUMSEQ
cDescSol			:= M->QDP_DESSOL
nRadTipo			:= M->QDP_TIPMD

DbSelectArea( "QDP" )

If M->QDP_PENDEN # "P"
	
	MsgAlert("Solicitacao ja processada", "Atencao" )
	Return .t.

EndIf

SETAPILHA()

cTitulo:="Solicitacao de Modificacao de " + If(	nRad01 == 1,;
																"Produto ",;
																"Sistemas ";
															 )

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

DEFINE 		MSDIALOG oDlg;
				FROM 		0, 0;
				TO 		20.2, 80;
				TITLE 	cTitulo;
				OF 		oMainWnd 

@ 003, 005 	TO 		45, 185;
				LABEL		" Solicitacao ";
				OF 		oDlg;
				PIXEL 

@ 013, 011 	SAY 		"Nr Solicitacao";
				SIZE 		60, 10;
				OF 		oDlg;
				PIXEL

@ 012, 055 	GET 		oNumSol;
				VAR		cNumSol;
				SIZE 		85, 10;
				WHEN 		.F.;
				OF 		oDlg;
				PIXEL

@ 029, 011 	SAY 		"Descricao";
				SIZE 		30, 10;
				OF 		oDlg;
				PIXEL

@ 028, 055 	GET 		oDescSol;
				VAR 		cDescSol;
				SIZE 		125, 10;
				OF			oDlg;
				PIXEL

@ 003, 190 	TO 		45, 305;
				LABEL		" Tipo ";
				OF 		oDlg;
				PIXEL 

@ 012, 200 	RADIO 	oRadTipo;
				VAR 		nRadTipo;
				ITEMS 	"Inclusao",;
							"Alteracao",;
							"Cancelamento";
				3D;
				SIZE 		100, 10; 
				OF   		oDlg;
				PIXEL

@ 047, 005 	TO 		085, 102;
				LABEL		" Razao ";
				OF 		oDlg;
				PIXEL

@ 087, 005 	TO 		124, 102;
				LABEL 	" Observacoes ";
				OF 		oDlg;
				PIXEL

If !Empty( M->QDP_CHAVE )
	
	lchk01:=.t.
	lchk02:=.t.

Else
	
	lchk01:=.f.
	lchk02:=.f.

EndIf

@ 055, 010 	CHECKBOX 	oChk01;
				VAR			lChk01;
				PROMPT		"Editar Razao";
				SIZE 			90, 15;
				ON CLICK		If(	lChk01,;
										oBtn10:Enable(),;
										oBtn10:Disable();
								  );
				OF 			oDlg;
				PIXEL

@ 094, 010	CHECKBOX		oChk02;
				VAR			lChk02;
				PROMPT		"Editar Observacoes";
				SIZE 			90, 15;
				ON CLICK 	If( 	lChk02,;
										oBtn11:Enable(),;
										oBtn11:Disable();
								  );
				OF 			oDlg;
				PIXEL

@ 071, 080	BUTTON		oBtn10;
				PROMPT 		">>";
				SIZE 			15, 10;
				ACTION 		A5020Razao( nOpc );
				OF 			oDlg;
				PIXEL

@ 110, 080	BUTTON		oBtn11;
				PROMPT 		">>";
				SIZE 			15, 10;
				ACTION 		A5020Obs( nOpc );
				OF 			oDlg;
				PIXEL

oGet 			:= MSGetDados():New( 050, 107, 124, 305, 3, "A5020LinOk()", "", "", .t., , )

DbSelectArea( "QDP" )

DEFINE		SBUTTON	oBtn01;
				FROM 		130, 240;
				TYPE 		1;
				ENABLE;
				OF 		oDlg;
				ACTION 	( 	A5020gRVs( nOpc ),;
								lFecha:=.t.,;
								oDlg:End();
							)

DEFINE		SBUTTON	oBtn02;
				FROM 		130, 275;
				TYPE 		2;
				ENABLE;
				OF 		oDlg;
				ACTION 	(	lFecha := .t.,;
								oDlg:End();
							)

ACTIVATE 	MSDIALOG oDlg;
				VALID lFecha;
				CENTERED

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				
SETAPILHA()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SOLEXC5020³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 30/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 															  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SOLEXC5020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 						                                         ³±±	
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function SolExc5020( )

If M->QDP_PENDEN != "P"
	
	MsgAlert( "Solicitacao ja atendida. Impossivel de ser excluida", "Atencao" )
	Return

EndIf

If MsgYesNo( "Deseja excluir esta solicitacao ?", "Atencao" )
	
	If MsgYesNo( "Confirma ?", "Atencao" )
		
		DbSelectArea( "QDP" )
		
		Begin Transaction
			
			Reclock( "QDP", .f. )
			QDP->( DbDelete() )
			MsUnlock()
		
		End Transaction
	
	Endif			

Endif

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SOLBAI5020³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 				  					 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SOLBAI5020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 					                                       	  ³±±		
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function	SolBai5020( cAlias, nReg, nOpc )

Local 	nC
Local 	cRev
Local		cChave
Local 	lImprimir	:= .F.
Local 	lResult 		:= .F.
Local		nRegQDH		:= 0
Local		dDataLimite	:= ctod("  /  /  ")
Local 	cNSeqSol

Private	cCadastro 	:= "Solicitacao de Modificacao"
Private	cFilMat 		:= cFilAnt
Private	lIncDepois	:= .F.
Private	lAltDoc		:= .T.
Private	lGeraRev		:= .F.
Private	aListID		:= {}
Private	aListWD		:= {}
Private 	bCampo 		:= {|nCPO| Field( nCPO ) }
Private 	cSolDocto	:=" "
Private lSolicitacao

If !QA_NivAces( 92, "Nao tem permissao para baixar solicitacoes" )
	
	Return .t.

Endif

DbselectArea( "QDP" )

For nC := 1 To QDP->( FCount() )
	
	cCampo 		:= Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
	M->&cCampo 	:= QDP->( FieldGet( FieldPos( cCampo ) ) )

Next
			
cNSeqSol			:= M->QDP_NUMSEQ

If nRad01 == 1
	
	cTipo		:= "MDP"

Elseif nRad01 == 2
	
	cTipo	:= "MDS"

Endif
			
If M->QDP_PENDEN # "P"
	
	MsgAlert( "Solicitacao ja processada", "Atencao" )
	Return .t.

EndIf

If MsgYesNo( "Baixar Pendecia sem gerar Modificacao", "Atencao" )
	
	If MsgYesNo( "Confirma ?", "Atencao" )
		
		Begin Transaction
			
			RecLock( "QDP", .f. )
				
			If cTipo == "MDP"
				
				QDP->QDP_DTOORI	:= "SOL_MOD_MDP"
				
			Elseif cTipo == "MDS"
				
				QDP->QDP_DTOORI	:= "SOL_MOD_MDS"
				
			EndIf
	
			QDP->QDP_RV				:= "00 "	
			QDP->QDP_PENDEN	 	:= "B"
			QDP->QDP_DTBAIX		:= dDataBase
			QDP->QDP_HRBAIX		:= Left( Time(), 5 )
				
			If cTipo == "MDP"
				
				QDP->QDP_TITULO	:= "Solicitacao de Modificacao de Produto"
				
			Elseif cTipo == "MDS"
					
				QDP->QDP_TITULO	:= "Solicitacao de Modificacao de Sistemas"
				
			EndIf
	
			QDP->QDP_FMATBX 		:= cFilAnt
			QDP->QDP_MATBX  		:= cMatCod	
			QDP->QDP_DEPBX 		:= cMatDep

			MsUnlock()
				
		End Transaction
	
	Endif			
	
Else
	
	cSolDocto		:= cTipo+QCreateSeq( cTipo, 6, "N" )

	Dbselectarea( "QDP" )
	
	Begin Transaction
		
		RecLock( "QDP", .f. )
	
		If cTipo == "MDP"
			
			QDP->QDP_DTOORI	:= "SOL_MOD_MDP"
		
		Elseif cTipo == "MDS"
			
			QDP->QDP_DTOORI	:= "SOL_MOD_MDS"
		
		EndIf
	
		QDP->QDP_RV				:= "00 "	
		QDP->QDP_PENDEN	 	:= "B"
		QDP->QDP_DTBAIX		:= dDataBase
		QDP->QDP_HRBAIX		:= Left( Time(), 5)
	
		If cTipo == "MDP"
		
			QDP->QDP_TITULO	:= "Solicitacao de Modificacao de Produto"
		
		Elseif cTipo == "MDS"
			
			QDP->QDP_TITULO	:= "Solicitacao de Modificacao de Sistemas"
		
		EndIf
	
		QDP->QDP_FMATBX 		:= cFilAnt
		QDP->QDP_MATBX  		:= cMatCod	
		QDP->QDP_DEPBX 		:= cMatDep
		QDP->QDP_DOCTO	 		:= cSolDocto
		MsUnlock()


	lSolicitacao	:= .t.
	
	QD050Telas( "QDH", , 3 )
	
	lSolicitacao 	:= .f.


	End Transaction

Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A5020Razao³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 		  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A5020Razao( nOpc )

Local		lFlag
Local 	nTamLin		:= TamSX3("QA2_TEXTO")[1]
Local 	cTexto 		:= "Nr da Solicitacao"
Local 	cTitulo 		:= "Razao"
Local 	cSol 			:= Space( 06 )
Local 	nOrder 		:= QDP->( IndexOrd() )

Private 	axTextos 	:= {}	

If ( nOpc # 2, lFlag:=.t., lFlag:=.f. ) 

If nOpc == 2
	
	cSol		:= Alltrim( M->QDP_TPSOL ) + "RAZ"

Else
	
	If nRad01 == 1
		
		cSol	:= "MDPRAZ"
	
	Elseif nRad01 == 2
		
		cSol	:= "MDSRAZ"	
	
	EndIf

EndIf

If Empty( M->QDP_CHAVE )
	
	M->QDP_CHAVE	:= Left( cSol + Space( 8 ),8 ) + QDP->QDP_NUMSEQ
	M->QDP_CHAVE	:= QA_CvKey( M->QDP_CHAVE,"QDP", 2 )
	QDP->( DbSetOrder( nOrder ) )

EndIf

QA_TEXTO(  M->QDP_CHAVE, Left( cSol + Space( 8 ), 8 ), nTamlin, "Nr da Solicitacao", cNumSol, @axTextos, 1, cTitulo, lflag )
QA_GrvTxt( M->QDP_CHAVE, Left( cSol + Space( 8 ), 8 ), 1, @axtextos)

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A5020Obs  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 		 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A5020Obs( nOpc )

Local		lFlag
Local 	nTamLin 		:= TamSX3("QA2_TEXTO")[1]
Local 	cTexto		:= "Nr da Solicitacao"
Local 	cTitulo 		:= "Observacoes"
Local 	cSol 			:= Space( 06 )
Local 	nOrder 		:= QDP->( IndexOrd() )
Private 	axTextos 	:= {}	

If ( nOpc # 2, lFlag:=.t., lFlag:=.f. ) 

If nOpc == 2
	
	cSol		:= Alltrim( M->QDP_TPSOL ) + "OBS"

Else
	
	If nRad01 == 1
		
		cSol	:= "MDPOBS"
	
	Elseif nRad01 == 2
		
		cSol	:= "MDSOBS"	
	
	EndIf

EndIf

If Empty( M->QDP_CHAVE )
	
	M->QDP_CHAVE	:= Left( cSol + Space( 8 ),8 ) + QDP->QDP_NUMSEQ
	M->QDP_CHAVE	:= QA_CvKey( M->QDP_CHAVE,"QDP", 2 )
	QDP->( DbSetOrder( nOrder ) )

Endif

QA_TEXTO(  M->QDP_CHAVE, Left( cSol + Space( 8 ), 8 ), nTamlin, "Nr da Especificacao", cNumSol, @axTextos, 1, cTitulo, lflag )
QA_GrvTxt( M->QDP_CHAVE, Left( cSol + Space( 8 ), 8 ), 1, @axtextos)

Return .t.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A5020LinOk³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 		 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A5020LinOk()

Return .t.



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A5020GrvS ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 06.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava o conteudo das variaveis de memoria no arquivo de    ³±±
±±³          ³ solicitacao.                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A5020GrvS( nOpc )

Local		nC
Local 	nPos
Local 	nTamLin 		:= TamSX3("QA2_TEXTO")[1]

Local 	cChave
Local		cCod

Local 	lLock 		:= .t.  
Local 	lAprova 		:= .t.
Local		lGravaTxt 	:= .f.
Local 	lRet 			:= .f.

Local 	bCampo 		:= {|nCPO| Field(nCPO) }
																  

M->QDP_DESSOL	:= cDescSol
M->QDP_MAT		:= cMatCod
M->QDP_PENDEN	:= "P"
M->QDP_TIPMD	:= nRadTipo

If ( nOpc==3, lLock:=.t., lLock:=.f. )

Begin Transaction
	
	DbSelectArea( "QDP" )    
	
	RecLock( "QDP", lLock, lLock )
	
	For nC := 1 TO FCount()
		
		FieldPut( nC,M->&( Eval( bCampo,nC ) ) )
	
	Next
	
	MsUnlock()

				
End Transaction

lRet	:= .t.

DbSelectArea( "QDP" )

Return lRet


Function A5020Pesquisa( )

Local oDlgPesq
Local oRad01
Local	oPesq
Local oQDH
Local cPesq
Local nRad01

DEFINE 		MSDIALOG oDlgPesq;
				FROM 		0, 0;
				TO 		20.2, 80;
				TITLE 	"Pesquisa de Codigo em MDP / MDS";
				OF 		oMainWnd
            
@ 002, 005 	TO 		040, 050;
				OF 		oDlgPesq; 
				PIXEL

@ 010, 010 	RADIO 	oRad01;
				VAR 		nRad01;
				ITEMS 	"MDP",;
							"MDS";
				3D;
				SIZE 		30, 12; 
				OF   		oDlgPesq;
				PIXEL

@ 002, 055 	TO 		040, 155;
				OF oDlgPesq; 
				PIXEL

@ 010, 060 	SAY 		"Codigo";
				SIZE 		70, 10;
				OF 		oDlgPesq;
				PIXEL

@ 022, 060 	GET 		oPesq;
				VAR		cPesq;
				SIZE 		85, 10;
				OF 		oDlgPesq;
				PIXEL


ACTIVATE 	MSDIALOG oDlgPesq;
				CENTERED


Return



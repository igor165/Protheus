#INCLUDE "ctba355.ch"
#INCLUDE "protheus.ch"
#define CONFST    	 	'1'
#define CONFST_DET     	'2'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA355   º Autor ³ Bruno Sobieski     º Data ³  22/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de conferencia de lançamentos                       º±±                    
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA355

Local aCores := {	{ "CT2_CONFST == ' '" , "BR_VERDE"		},; // nao conferido  
					{ "CT2_CONFST == '1'" , "BR_PRETO"		},; // CONFERIDO
					{ "CT2_CONFST == '2'" , "BR_VERMELHO"	}}  // CONFERIR DETALHADO 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro := STR0001 //"Conferencia de lancamentos"
/*Para Compatibilidade com a CTBA102*/
Private dDataLanc
Private cLote
Private cSubLote 
Private cDoc	 
Private lSubLote := Empty( cSubLote )
/*Fim Compatibilidade com a CTBA102*/

Private cFunName  	:= "CTBA355"
Private cProfChave	:= "CTBA355"
Private cString 	:= "CT2"
Private aRotina 	:= MenuDef()

Private abLineEmpty:={}

dbSelectArea("CT2")
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

Static Function MenuDef()

Local nX 		:= 0
Local aCTBA355 	:= {}
Local aRotina := { {STR0002,"AxPesqui",0,1} ,; //"Pesquisar"
{STR0003	,"Ctba102Cal"	, 0 , 2},;  //"Vis. Lancamento"
{STR0004	,"CTBA3551"	,0	, 2},; //"Conf. Colunas"
{STR0005	,"CTBA3552"	,0	, 3},; //"Conferir"
{STR0006	,"CTBA3552"	,0	, 5},; //"Estornar"
{STR0007  	,"CTBA3554"	,0	, 2},; //"Legenda"
{STR0008	,"CTBR355"	,0	, 2}} //"Imprimir"

//Ponto de entrada para adicionar botoes na rotina
If ExistBlock( "CT355BUT" )
	aCTBA355 := ExecBlock( "CT355BUT",.F.,.F.,aRotina)
	
	If ValType(aCTBA355) == "A" .AND. Len(aCTBA355) > 0
		aRotina := {}
		For nX := 1 to Len(aCTBA355)
			aAdd(aRotina, aCTBA355[nX])
		Next
	EndIf
EndIf


Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA3552()   ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conferencia de lancamentos                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA3552(cAlais,nRecno,nOpcx)    
Local cQuery	:=	""
Local aCpos	:=	{}
Local aTam 	:=	{}
Local aHead :=  {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}    
Local aButtons	:=	{}         
Local lAsc		:= .T.                                      
Local lJa		:= .F.
Local  oLBCT2
Local cHist := ""
Local oSay1
Local oSay2
Local oSay3
Local aSays		:=	{Nil,Nil,Nil}
Local cExpFil 	:= ""
Local cTxtFil	:= ""
Local aObs := {}
Local cObs := ""
Local cPerg	:=	'CT355A'
Local nOpcao	:=	IIf(aRotina[nOpcx,4] == 3, 1,2) //1=Conferencia;2=Estorno
Local cDlgTitle	:=	STR0001 //"Conferencia de lancamentos"
Local nI
Local oSize	
 
If nOpcao == 1 
	cPerg	:=	'CT355A'	 
Else
	cPerg	:=	'CT355B'	 
Endif	
Private cOrdCT2	:=	""
Private oDet	:= LoadBitMap(GetResources(), "BR_CANCEL")
Private oOk		:= LoadBitMap(GetResources(), "LBOK")
Private oNo		:= LoadBitMap(GetResources(), "LBNO")
Private cBLinCt2:=	""
Private aLinCt2 :=	{}

oSize := FwDefSize():New(.T.,,,)
oSize:AddObject( "CABECALHO",  100, 15, .T., .T. ) 
oSize:AddObject( "GETDADOS" ,  100, 70, .T., .T. ) 
oSize:AddObject( "RODAPE" ,  100, 15, .T., .T. ) 
oSize:lProp 	:= .T. 
//oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	

AAdd( aPosObj, {  oSize:GetDimension("CABECALHO","LININI") ,    oSize:GetDimension("CABECALHO","COLINI") , ;
	oSize:GetDimension("CABECALHO","LINEND") ,  oSize:GetDimension("CABECALHO","COLEND")  } )
AAdd( aPosObj, {  oSize:GetDimension("GETDADOS","LININI") ,    oSize:GetDimension("GETDADOS","COLINI") , ;
	 oSize:GetDimension("GETDADOS","YSIZE"), oSize:GetDimension("GETDADOS","XSIZE")  } )
AAdd( aPosObj, {  oSize:GetDimension("RODAPE","LININI") ,    oSize:GetDimension("RODAPE","COLINI") , ;
	oSize:GetDimension("RODAPE","LINEND") ,  oSize:GetDimension("RODAPE","COLEND")  } )

/* PARAMETROS
mv_par02	"Da Data            ?"
mv_par03	"Ate a Data         ?"
mv_par04	"Valor minimo       ?"
mv_par05	"Valor maximo       ?"
mv_par06	"Do Lote            ?"
mv_par07	"Ate o Lote         ?"
mv_par08	"Do SubLote         ?"
mv_par09	"Ate o Sublote      ?"
mv_par10	"Do Documento       ?"
mv_par11	"Ate o Documento    ?"
mv_par12	"Moeda              ?"
mv_par13	"Tipo de saldo      ?"
mv_par14	"Conta              ?"
mv_par15	"Centro de custo    ?"
mv_par16	"Item contabil      ?"
mv_par17	"Classe de valor    ?"
mv_par01	"Mostrar            ?"
*/

A355CFG(/*aCposObrig*/,aCpos,@aTam,@aHead,.T.)

If Pergunte(cPerg)
	If nOpcao == 2	
		cDlgTitle := Iif(mv_par01==1,STR0009,STR0010) //"Estorno de conferencia de lancamentos"###"Estorno de re-analise"
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
	//³Carrega dados do CT2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	cAliasQry	:=	GetNextAlias()
	aLinCt2		:=	CarregaCt2(@aTam,@aHead,cAliasQry,oLBCT2,aCpos,.F.,cHist,oSay1,oSay2,oSay3,aObs,nOpcao)
	If (Ascan(aCpos,{|x| x[5] == 'TMP_VLCRED' }) * Ascan(aCpos,{|x| x[5] == 'TMP_VLDEB' })) +  (Ascan(aCpos,{|x| Alltrim(x[5]) == 'CT2_VALOR' })*Ascan(aCpos,{|x| Alltrim(x[5]) == 'CT2_DC' })) == 0
		Aviso(STR0039,STR0040+CRLF+STR0011+CRLF+STR0012+CRLF+STR0013,{'Ok'},2) //"  1) Valor crédito e valor débito"###" ou "###"  2) Valor e Tipo"
		Return			
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define as teclas de atalho e botoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(VK_F4,{|a,b|	ConfirmaMarca(.F.,oLBCT2:nAt,aCpos,oLbct2,aSays,aObs,nOpcao)})
	SetKey(VK_F5,{|a,b| IIf(Len(aLinCT2)>0,IIf(aLinCT2[oLBCT2:nAt,1]==1,  aLinCT2[oLBCT2:nAt,1]:= -1, aLinCT2[oLBCT2:nAt,1]:= 1                   	 ),/*nao fazer nada*/)}) 
	If nOpcao == 1
	SetKey(VK_F6,{|a,b| IIf(Len(aLinCT2)>0,IIf(aLinCT2[oLBCT2:nAt,1]==2,  aLinCT2[oLBCT2:nAt,1]:=  0,(aLinCT2[oLBCT2:nAt,1]:= 2,oGetObs:SetFocus())),/*nao fazer nada*/)})
	Endif
	SetKey(VK_F7,{|a,b| Ctb355Lcto(oLBCT2) })
	SetKey(VK_F8,{|a,b| CTB355FtBs(oLBCt2,@cExpFil,@cTxtFil,aCpos     )})
	SetKey(VK_F9,{|a,b| CTB355Rast(oLBCt2)})
	SetKey(VK_F10,{|a,b|	Eval(oGetObs:bValid),ConfirmaMarca(.T.,,aCpos,oLbct2,aSays,aObs,nOpcao)})
	Aadd( aButtons, {"CTBLANC"   ,{ || Ctb355Lcto(oLBCT2)}, STR0014+" <F7>",STR0015 } )  //"Detalhes do lançamento posicionado "###"Detalhes"
	Aadd( aButtons, {"PMSPESQ"   ,{ || CTB355FtBs(oLBCt2,@cExpFil,@cTxtFil,aCpos     )}, STR0016+" <F8>" 	} ) // //"Localizar"
	Aadd( aButtons, {"ORDEM" 	 ,{ || CTB355Rast(oLBCt2)}, STR0017+" <F9>" 	} ) // //"Rastrear"

	Aadd( aButtons, {"SALVAR" 	 ,{ || Eval(oGetObs:bValid),ConfirmaMarca(.T.,,aCpos,oLbct2,aSays,aObs,nOpcao) }, STR0041+' <F10>',STR0042} ) 

	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0001,aHead,aLinCT2} } )) //"Conferencia de lancamentos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define o Dialog³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE DIALOG oDlg  TITLE cDlgTitle FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //"Documentos de Origem"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os dados do cabecalho   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBox	:=	{Nil,Nil,Nil}
	aBox[1]	:=	{aPosObj[1,2],Int(aPosObj[1,4]+1)*0.60}
	aBox[2]	:=	{(Int(aPosObj[1,4]+1)*0.6)+2,aPosObj[1,4]+1}
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD	
	@aPosObj[1,1]+10,aBox[1,1] To aPosObj[1,3],aBox[1,2] LABEL 'Operacao'   of Odlg PIXEL
	If nOpcao == 1 
		@aPosObj[1,1]+19,10 BITMAP oBmp RESNAME "LBTIK" SIZE 16,16 NOBORDER PIXEL
		@aPosObj[1,1]+19,20 SAY "Conferir"+' <F4>' of oDlg PIXEL 
		@aPosObj[1,1]+27,10 BITMAP oBmp RESNAME "LBOK" SIZE 16,16 NOBORDER PIXEL
		@aPosObj[1,1]+27,20 SAY STR0044+' <F5>' of oDlg PIXEL  //"Marcar para conferencia"
		@aPosObj[1,1]+35,10 BITMAP oBmp RESNAME "BR_CANCEL" SIZE 16,16 NOBORDER PIXEL
		@aPosObj[1,1]+35,20 SAY STR0045+" <F6> (digite a observacao na parte inferior da tela)" of oDlg PIXEL //"EDT nao iniciada/atrasada" //"Marcar para re-analise"
	Else
		If mv_par01 == 1
			@aPosObj[1,1]+19,10 BITMAP oBmp RESNAME "LBTIK" SIZE 16,16 NOBORDER PIXEL
			@aPosObj[1,1]+19,20 SAY STR0046+' <F4>' of oDlg PIXEL  //"Estornar conferencia"
			@aPosObj[1,1]+27,10 BITMAP oBmp RESNAME "LBOK" SIZE 16,16 NOBORDER PIXEL
			@aPosObj[1,1]+27,20 SAY STR0047+' <F5>' of oDlg PIXEL  //"Marcar para estornar conferencia"
		Else
			@aPosObj[1,1]+19,10 BITMAP oBmp RESNAME "LBTIK" SIZE 16,16 NOBORDER PIXEL
			@aPosObj[1,1]+19,20 SAY STR0048+' <F4>' of oDlg PIXEL  //"Estornar re-analise"
			@aPosObj[1,1]+27,10 BITMAP oBmp RESNAME "LBOK" SIZE 16,16 NOBORDER PIXEL
			@aPosObj[1,1]+27,20 SAY STR0049+' <F5>' of oDlg PIXEL  //"Marcar para estornar analsie detalhada"
		Endif	
	Endif
		
	@aPosObj[1,1]+10,aBox[2,1]   To aPosObj[1,3],aBox[2,2] LABEL STR0050 	   of Odlg PIXEL //"Saldos"
	aObjDeb	:=	{aPosObj[1,1]+16,aBox[2,1]+3,aPosObj[1,3]-2,aBox[2,1]+((aBox[2,2]-aBox[2,1])/3) - 1}
	@aObjDeb[1],aObjDeb[2] To aObjDeb[3],aObjDeb[4] LABEL STR0051	   of Odlg PIXEL //"Debito"
	aObjCrd	:=	{aPosObj[1,1]+16,aObjDeb[4]+1,aPosObj[1,3]-2,aObjDeb[4]+((aBox[2,2]-aBox[2,1])/3) - 1 }
	@aObjCrd[1],aObjCrd[2] To aObjCrd[3],aObjCrd[4] LABEL STR0052	   of Odlg PIXEL //"Credito"
	aObjSld	:=	{aPosObj[1,1]+16,aObjCrd[4]+1,aPosObj[1,3]-2,aBox[2,2]-2}
	@aObjSld[1],aObjSld[2] To aObjSld[3],aObjSld[4] LABEL STR0053 of Odlg PIXEL //"Saldo total"
	DEFINE FONT oBold1 NAME "Arial" SIZE 0, -14 BOLD	
	If oMainWnd:nClientWidth==800
		@ aObjDeb[1]+((aObjDeb[3]-aObjDeb[1])/4),aObjDeb[2]+2 SAY aSays[1] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold SIZE (aObjDeb[4]-aObjDeb[2])-3,20 Of oDlg PIXEL 
		@ aObjCrd[1]+((aObjCrd[3]-aObjCrd[1])/4),aObjCrd[2]+2 SAY aSays[2] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold SIZE(aObjCrd[4]-aObjCrd[2])-3,20 Of oDlg PIXEL 
		@ aObjSld[1]+((aObjSld[3]-aObjSld[1])/4),aObjSld[2]+2 SAY aSays[3] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold SIZE (aObjSld[4]-aObjSld[2])-3,20 Of oDlg PIXEL 
    Else
		@ aObjDeb[1]+((aObjDeb[3]-aObjDeb[1])/2),aObjDeb[2]+2 SAY aSays[1] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold1 SIZE (aObjDeb[4]-aObjDeb[2])-3,20 Of oDlg PIXEL 
		@ aObjCrd[1]+((aObjCrd[3]-aObjCrd[1])/2),aObjCrd[2]+2 SAY aSays[2] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold1 SIZE (aObjCrd[4]-aObjCrd[2])-3,20 Of oDlg PIXEL 
		@ aObjSld[1]+((aObjSld[3]-aObjSld[1])/2),aObjSld[2]+2 SAY aSays[3] PROMPT TransForm(0,PesqPict('CT2','CT2_VALOR')) COLOR CLR_BLUE RIGHT FONT oBold1 SIZE (aObjSld[4]-aObjSld[2])-3,20 Of oDlg PIXEL 
    Endif
	AtuTotais(aLinCt2,aSays,aCpos)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄUÊS¿
	//³Define o GRID onde ficarao os dados para a conferencia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄUÊSÙ
	oLBCT2	:= TwBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],,aHead,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	oLBCT2:bHeaderClick := {|x,y,z| IIf(.T.,(BrwSetOrder(oLBCT2,y,@lAsc,@aLinCT2),lJa	:=	.F.),lJa:=.T.) }
	cBLinCT2:= "{If(aLinCT2[oLBCT2:nAt,1]==1,oOk,If(aLinCT2[oLBCT2:nAt,1]==2,oDet,oNo))"
	If nOpcao == 1
		If mv_par18 == 1
			oLBCT2:bLDblClick :={||  ConfirmaMarca(.F.,oLBCT2:nAt,aCpos,oLBCT2,aSays,aObs,nOpcao) }
		ElseIf mv_par18 == 2
			oLBCT2:bLDblClick :={ || IIf(Len(aLinCT2)>0,IIf(aLinCT2[oLBCT2:nAt,1]==1,  aLinCT2[oLBCT2:nAt,1]:= -1, aLinCT2[oLBCT2:nAt,1]:= 1                    	),/*nao fazer nada*/)}
		ElseIf mv_par18 == 3
			oLBCT2:bLDblClick :={ || IIf(Len(aLinCT2)>0,IIf(aLinCT2[oLBCT2:nAt,1]==2,  aLinCT2[oLBCT2:nAt,1]:=  0,(aLinCT2[oLBCT2:nAt,1]:= 2,oGetObs:SetFocus())),/*nao fazer nada*/)}
		Endif
	Else
		If mv_par18 == 1
			oLBCT2:bLDblClick :={||  ConfirmaMarca(.F.,oLBCT2:nAt,aCpos,oLBCT2,aSays,aObs) }
		ElseIf mv_par18 == 2
			oLBCT2:bLDblClick :={ || IIf(Len(aLinCT2)>0,IIf(aLinCT2[oLBCT2:nAt,1]==1,  aLinCT2[oLBCT2:nAt,1]:= -1,aLinCT2[oLBCT2:nAt,1]:= 1),/*nao fazer nada*/)}
		Endif
	Endif
	nI:=2
	SX3->(DbSetorder(2))
	For nI:= 1 to Len(aCpos)
		SX3->(DbSeek(If(Substr(aCpos[nI,5],1,3) <> 'TMP',aCpos[nI,5],'CT2_VALOR')))
		If SX3->X3_TIPO == 'N' 
			If Empty(SX3->X3_CBOX)
				cBLinCT2:= cBLinCT2 + ", Transform(aLinCT2[oLBCT2:nAT][" + alltrim(Str(nI+1))+ "], '" + Alltrim(SX3->X3_PICTURE) + "')"
			Else 
				cBLinCT2:= cBLinCT2 + ", AcaX3Combo('"+SX3->X3_CAMPO+"',Alltrim(Str(aLinCT2[oLBCT2:nAT][" + alltrim(Str(nI+1))+ "])))"
			Endif
		ElseIf SX3->X3_TIPO == 'D'
			cBLinCT2:= cBLinCT2 + ", Dtoc(aLinCT2[oLBCT2:nAT][" + alltrim(Str(nI+1))+ "])"
		Else
			If Empty(SX3->X3_CBOX)
				cBLinCT2:= cBLinCT2 + ", aLinCT2[oLBCT2:nAT][" + alltrim(Str(nI+1))+ "]"
			Else
				cBLinCT2:= cBLinCT2 + ", AcaX3Combo('"+SX3->X3_CAMPO+"',Alltrim(aLinCT2[oLBCT2:nAT][" + alltrim(Str(nI+1))+ "]))"
			Endif
		Endif
	Next nI
	oLBCT2:lColDrag	:= .T.
	oLBCT2:nFreeze	:= 1
	oLBCT2:SetArray(aLinCT2)
	oLBCT2:bChange	:= {|| AtuHist(@oSay1,@oSay2,@oSay3,@cHist,@oGetHist,@oLBCT2,aLinCt2,@cObs,aObs,oGetObs)}
	If Len(aLinCt2) > 0  
		oLBCT2:nAT	:= 1
		oLBCT2:bLine:= &("{ || "+ cBLinCT2 + "} }")
	Else                   
		abLineEmpty	:=	Array(Len(oLBCT2:aHeaders))
		aFill(abLineEmpty,"")
		oLBCT2:bLine:= {|| abLineEmpty }
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os dados do rodape³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosIni	:=	aPosObj[3,1]
	aBox	:=	{Nil,Nil,Nil}
	aBox[1]	:=	{aPosObj[3,2],Int(aPosObj[3,4]+1)/3}
	aBox[2]	:=	{(Int(aPosObj[3,4]+1)/3)+2,(Int(aPosObj[3,4]+1)/3)*2}
	aBox[3]	:=	{((Int(aPosObj[3,4]+1)/3)*2)+2,aPosObj[3,4]+1}
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD	
	@nPosIni,aBox[1,1] To aPosObj[3,3]-12,aBox[1,2] LABEL STR0015   of Odlg PIXEL //"Detalhes"
	@nPosIni,aBox[2,1] To aPosObj[3,3]-12,aBox[2,2] LABEL STR0018  of Odlg PIXEL //"Historico"
	@nPosIni,aBox[3,1] To aPosObj[3,3]-12,aBox[3,2] LABEL STR0019 of Odlg PIXEL //"Observacao"

	@nPosIni+06,aBox[1,1]+1  SAY oSay1 PROMPT STR0020  COLOR CLR_BLUE FONT oBOLD Size aBox[2,1],9 PIXEL Of oDlg //"Tipo lancamento : "
	@nPosIni+13,aBox[1,1]+1  SAY oSay2 PROMPT STR0021  COLOR CLR_BLUE FONT oBOLD Size aBox[2,1],9 PIXEL Of oDlg //"Conta debito    : "
	@nPosIni+20,aBox[1,1]+1  SAY oSay3 PROMPT STR0022  COLOR CLR_BLUE FONT oBOLD Size aBox[2,1],9 PIXEL Of oDlg //"Conta credito   : "
	@nPosIni+08,aBox[2,1]+1  GET oGetHist Var cHist Size aBox[2,2]-aBox[2,1]-2,21 READONLY MEMO PIXEL Of oDlg 
	@nPosIni+08,aBox[3,1]+1  GET oGetObs Var cObs Size aBox[3,2]-aBox[3,1]-2,21 MEMO VALID ADDCT2Obs(@cObs,aObs,oLBCt2) When (nOpcao == 1 .And. Len(aLinCT2)>0 .And. aLinCT2[oLBCt2:nAt][1] == 2 ) PIXEL Of oDlg 

	ACTIVATE DIALOG oDlg  ON INIT EnchoiceBar(oDlg,{|| IIf((nOpc:=Ctb355Ok())==3,;
																				Nil,;
																				(IIf(nOpc==1, (Eval(oGetObs:bValid),ConfirmaMarca(.T.,,aCpos,oLbct2,aSays,aObs,nOpcao)),Nil),oDlg:End()) )  },;
																				{|| oDlg:End()},,aButtons) //CENTERED
	SetKey(VK_F4,Nil)
	SetKey(VK_F5,Nil)
	SetKey(VK_F6,Nil)
	SetKey(VK_F7,Nil)
	SetKey(VK_F8,Nil)
	SetKey(VK_F9,Nil)
	SetKey(VK_F10,Nil)

Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTB355ok()   ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Configurador da ordem das colunas no profile do usuario    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB355Ok()
Local nOpc	:=	2
If Len(aLinCt2) > 0
	If Ascan(aLinCt2,{|x| x[1] <> -1}) > 0
		nOpc	:=	Aviso(STR0054,STR0055,{STR0056,STR0057,STR0058}) //"Confirmacao"###"Deseja confirmar os registros marcados?"###"Sim"###"Nao"###"Cancela"
	Endif
EndIf
Return nOpc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA3551()   ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Configurador da ordem das colunas no profile do usuario    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA3551()

///////
// Var:
Local oGet1, oGet2
Local lConfirm		:= .F.
Local aButtons		:= {}
Local aArea			:= GetArea()
Local oDlg
Local   lCancel			:= .F.
Private cAlias			:= "CT2"
Private aCpos			:= {}
Private aCposTMP		:= {}
Private aCols           := {}
Private aHeader 		:= {}

////////////////
// Monta aHeader
Aadd(aHeader,{""     		,"CHECKBOL","@BMP"    , 07, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{""     		,"CHECK"   ,"@BMP"    , 05, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{"Ordem"		,"ORDEM"   ,"@E 9,999", 04, 00, , ,"N", ,"V", , , , "A", , , }) 
Aadd(aHeader,{STR0059	,"NOMCAMPO", ""       , 12, 00, , ,"C", ,"V", , , , "V", , , })  //"Nome Campo"
Aadd(aHeader,{STR0023		,"CAMPO"   , ""       , 10, 00, , ,"C", ,"V", , , , "V", , , })  //"Campo"


//////////////////////
// Campos Obrigatorios
aCposObrig	:= { "CT2_DATA"  , "CT2_HIST",  "CT2_TIPO" }

///////
// Tela
DEFINE MSDIALOG oDlg TITLE STR0024 FROM 0,0 TO 400,500 OF oMainWnd PIXEL  //"Configurador de campos para conferencia"
	
	////////////////////////////////////////////////////////////
	// Alimenta pastas com os campos conforme Profile do Usuario
	A355CFG(aCposObrig,aCpos)
	/////////////
	// Monta Tela              
	nGetd := GD_UPDATE

	aCols :=  Aclone(aCpos)
	oGet1 := MsNewGetDados():New(15, 3, 198, 248 ,nGetd,,,,,,9999,,,,oDlg,aHeader,aCols)       
 	oGet1:oBrowse:bEditCol   := {|| A355CFGOrd(oGet1:oBrowse:nAt,@oGet1,.T.,oDlg) }
 	oGet1:oBrowse:blDblClick := {|| If( oGet1:oBrowse:nColPos == 3 , A355CFGOrd(oGet1:oBrowse:nAt,@oGet1,.F.,oDlg), A355CFGbmp(oGet1:oBrowse:nAt,@oGet1) ) }

	aCols :=  Aclone(aCpos)

	/////////
	// Botoes
	Aadd( aButtons, {"NOVACELULA",{ || A355CFGlst(@oGet1,aCposObrig,oDlg)		},STR0025,STR0026} )  //"Refaz lista de campos."###"Refaz"
	Aadd( aButtons, {"PARAMETROS",{ || A355CFGleg()                    		},STR0007} )  //"Legenda"
	Aadd( aButtons, {"CHECKED"   ,{ || A355CFGsel(@oGet1,1)	},STR0027,STR0028} )  //"Todos campos selecionados"###"Td.Cp.Sel"
	Aadd( aButtons, {"UNCHECKED" ,{ || A355CFGsel(@oGet1,2)	},STR0029,STR0030}) //"Todos campos nao selecionados"###"Td.Cp.N.Sel"
	

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg,{|| lConfirm:=.T.,oDlg:End()} , {|| If(MsgYesNo(STR0031),oDlg:End(),) }, , aButtons )) CENTERED // //"Deseja cancelar?"


///////////////////
// Grava em Profile
If lConfirm
	A355CFGgrv(oGet1)
EndIf

RestArea(aArea)
                                                                          
RETURN Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFG() ³Autor ³Bruno Sobieski           ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Profile e monta lista de campos                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static FUNCTION A355CFG(aCposObrig,aCpos,atam,aHead,lSoProfile)
DEFAULT aCposObrig	:= { "CT2_DATA"  , "CT2_HIST", "CT2_TIPO" }
// Var:
If FindProfDef( cUserName, cFunName, cProfChave, 'CT2' )
	// Resgata a lista do profile e mescla com campos de SX3
	A355aCFGPR(aCposObrig,aCpos,aTam,aHead,lSoProfile)
Else                
	// Cria Array com Lista nova de campos
	A355aCFGNR(aCposObrig,aCpos,aTam,aHead)
Endif

RETURN Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355aCFGNR() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria a lista nova de campos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION A355aCFGNR(aCposObrig,aCpos,aTam,aHead)
// Var:
Local aArea 	:= GetArea()
Local nOrdem	:= 0
Local lEnable	:= .F.
Local cBMP      := ""
// Pega a Lista de Campos de SX3
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek('CT2',.F.)
cBMP	:= "LBTIK"
Do While !EOF() .And. X3_ARQUIVO == 'CT2'
	If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .AND. X3_CONTEXT <> 'V'.And. X3_CAMPO <> "CT2_CONFST"
		If Alltrim(X3_CAMPO) == 'CT2_VALOR'
			nOrdem++
			lEnable := If((AScan(aCposObrig,'TMP_VLCRED')==0),.T.,.F.) 
			cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
			AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0052,'TMP_VLCRED',.F.}) //"Credito"
			Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(STR0052),X3_TAMANHO*4.1,len(STR0052)*4.1)),Nil) //"Credito"###"Credito"
			Iif(aHead <> Nil,AADD(aHead,STR0052),Nil) //"Credito"
	
			nOrdem++
			lEnable := If((AScan(aCposObrig,'TMP_VLDEB')==0),.T.,.F.) 
			cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
			AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0051 ,'TMP_VLDEB',.F.}) //"Debito"
			Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(STR0051),X3_TAMANHO*4.1,len(STR0051)*4.1)),Nil) //"Debito"###"Debito"
			Iif(aHead <> Nil,AADD(aHead,STR0051),Nil) //"Debito"
		Endif
		nOrdem++
		lEnable := If((AScan(aCposObrig,Alltrim(X3_CAMPO))==0),.T.,.F.) 
		cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
		AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(Trim(X3Titulo())),X3_TAMANHO*4.1,len(Trim(X3Titulo()))*4.1)),Nil)
		Iif(aHead <> Nil,AADD(aHead,Trim(X3Titulo())),Nil)
	Endif
	DbSkip()
Enddo
RestArea(aArea)
RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355aCFGPR() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resgata a lista do profile e mescla com campos de SX3      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION A355aCFGPR(aCposObrig,aCpos,aTam,aHead,lSoProfile)

///////
// Var:
Local aCposPro	:= {} // Campos que estao gravados no Profile
Local nTamLin	:= 10
Local aArea 	:= GetArea()
Local nOrdem	:= 0
Local lEnable	:= .F.
Local cBMP      := ""
Local cBMPBOL   := ""
Local cMemoProf	:= ""                                    
Local nTamMemo	:= 0
Local nA		:= 0

DEFAULT lSoProfile	:=	.F.
cMemoProf := RetProfDef(cUserName,cFunName,cProfChave,'CT2')
nTamMemo  := MLCount(cMemoProf,nTamLin)  

////////////////
// Cria aCposPro
For nA := 1 to nTamMemo
	Aadd( aCposPro, Alltrim(MemoLine(cMemoProf,nTamLin,nA)) )
Next nA
         

////////////////////////////////
// Pega a Lista de Campos de SX3
DbSelectArea("SX3")
DbSetOrder(2) // X3_CAMPO

////////////////////
// Rastreia aCposPro
For nA := 1 to nTamMemo
	lEnable := If( (AScan(aCposObrig,Alltrim(aCposPro[nA]))==0), .T., .F. ) 
	cBMP	:= "LBTIK"
	cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
	If DbSeek( Alltrim(aCposPro[nA]), .F. )	
		nOrdem++
		Aadd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(Trim(X3Titulo())),X3_TAMANHO*4.1,len(Trim(X3Titulo()))*4.1)),Nil)
		Iif(aHead <> Nil,AADD(aHead,Trim(X3Titulo())),Nil)
	ElseIf Alltrim(aCposPro[nA]) == 'TMP_VLCRED'  .Or. Alltrim(aCposPro[nA]) == 'TMP_VLDEB' 
		DbSeek('CT2_VALOR', .F. )		
		nOrdem++
		AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,IIf(Alltrim(aCposPro[nA])=='TMP_VLCRED',STR0052,STR0051),aCposPro[nA],.F.}) //"Credito"###"Debito"
		Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(IIf(Alltrim(aCposPro[nA])=='TMP_VLCRED',STR0052,STR0051)),X3_TAMANHO*4.1,len(IIf(Alltrim(aCposPro[nA])=='TMP_VLCRED',STR0052,STR0051))*4.1)),Nil) //"Credito"###"Debito"###"Credito"###"Debito"
		Iif(aHead <> Nil,AADD(aHead,IIf(Alltrim(aCposPro[nA])=='TMP_VLCRED',STR0052,STR0051)),Nil) //"Credito"###"Debito"
	Endif
Next nA       

cBMPBOL	:= "ENABLE"
cBMP	:= "LBNO"
If !lSoProfile
	///////////////////////////
	// Mescla com campos do SX3
	DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
	DbSeek('CT2',.F.)
	Do While !EOF() .And. X3_ARQUIVO == 'CT2'
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .And. ( AScan(aCposPro,Alltrim(X3_CAMPO))==0 ).AND. X3_CONTEXT <> 'V'.And. X3_CAMPO <> "CT2_CONFST"
			nOrdem++
			AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
			Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(Trim(X3Titulo())),X3_TAMANHO*4.1,len(Trim(X3Titulo()))*4.1)),Nil)
			Iif(aHead <> Nil,AADD(aHead,Trim(X3Titulo())),Nil)
		Endif
		DbSkip()
	Enddo
	If Ascan(aCpos,{|x| x[5] == 'TMP_VLCRED'}) == 0
	    DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('CT2_VALOR')		
		nOrdem++
		AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0052,'TMP_VLCRED',.F.}) //"Credito"
		Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(STR0052),X3_TAMANHO*4.1,len(STR0052)*4.1)),Nil) //"Credito"###"Credito"
		Iif(aHead <> Nil,AADD(aHead,STR0052),Nil) //"Credito"
	Endif
	If Ascan(aCpos,{|x| x[5] == 'TMP_VLDEB'}) == 0
	    DbSelectArea('SX3')
		DbSetOrder(2)
		DbSeek('CT2_VALOR')		
		nOrdem++
		AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0051,'TMP_VLDEB',.F.}) //"Debito"
		Iif(aTam <> Nil,AADD(aTam,iif(X3_TAMANHO > len(STR0051),X3_TAMANHO*4.1,len(STR0051)*4.1)),Nil) //"Debito"###"Debito"
		Iif(aHead <> Nil,AADD(aHead,STR0051),Nil) //"Debito"
	Endif
	
Endif                             

RestArea(aArea)

RETURN Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGOrd() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Organiza aCols qdo e trocado a ordem de um campo           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A355CFGOrd(nLin,oGet,lVld,oDlg)

///////
// Var:
Local nPosNovo 	:= 0
Local nValNovo 	:= 0
Local nValAnti 	:= 0
Local nValMaior := Len(oGet:aCols)
Local nFor		:= 0
Local nA		:= 0
Local nOrdem	:= 0


If lVld
	nValNovo := M->ORDEM	
	nValAnti := nLin
Else
	nValAnti := oGet:aCols[nLin][3] 
	oGet:EditCell()
	nValNovo := oGet:aCols[nLin][3]
Endif


If ( nValNovo <= nValMaior ) .And. ( nValNovo > 0 ) 

	////////////////////////////////////////
	// Somente processa se valor for trocado
	If ( nValAnti <> nValNovo )
	
		If lVld
			nPosNovo := nValNovo
		Else
			nPosNovo := Ascan( oGet:aCols, {|aVal| aVal[3] == nValNovo } )
		Endif
		
		If ( nLin < nPosNovo )
			nFor := nPosNovo
			nLin++
			For nA := nLin to nFor
				nOrdem := nA
				nOrdem--
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Else
			nFor := ( (nLin-nPosNovo) + nPosNovo ) - 1
			For nA := nPosNovo to nFor
				nOrdem := nA
				nOrdem++
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Endif
		
		oGet:aCols := Asort( oGet:aCols,,, { |x,y| x[3] < y[3] } )
		
	Endif

Else
	oGet:aCols[nLin][3] := nValAnti
	If ( nValNovo <= 0 )
		Alert(STR0032)  //"Valor nao pode ser menor ou igual a Zero"
	Else
		Alert(STR0033) //"Valor nao pode ser maior do que o numero maximo de campos"
	Endif
Endif   

oGet:oBrowse:Refresh()
oGet:ForceRefresh()
oDlg:Refresh()

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGbmp() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a troca do BMP de aCOls                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A355CFGbmp(nLin,oGet)


If ( oGet:aCols[nLin][1] = "ENABLE" )
	If     ( oGet:aCols[nLin][2] = "LBTIK" )
		oGet:aCols[nLin][2] := "LBNO"		
	ElseIf ( oGet:aCols[nLin][2] = "LBNO" )
		oGet:aCols[nLin][2] := "LBTIK"
	Endif
Endif


RETURN Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGlst() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desconsidera a lista atual e restaura a config. inicial    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION A355CFGlst(oGet1,aCposObrig,oDlg)

///////
// Var:
Local aArea 		:= GetArea()
Local nOrdem		:= 0
Local lEnable		:= .F.
Local cBMP      	:= ""


If MsgYesNo(STR0034)  //"Deseja refazer a lista de campos baseada no dicionario de dados?"
	aCpos	:=	{}
	////////////////////////////////
	// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek('CT2',.F.)
	cBMP	:= "LBTIK"
	Do While !EOF() .And. X3_ARQUIVO == 'CT2'
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .AND. X3_CONTEXT <> 'V' .And. X3_CAMPO <> "CT2_CONFST"
			If Alltrim(X3_CAMPO) == 'CT2_VALOR'
				nOrdem++
				lEnable := If((AScan(aCposObrig,'TMP_VLCRED')==0),.T.,.F.) 
				cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
				AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0052,'TMP_VLCRED',.F.}) //"Credito"
				nOrdem++
				lEnable := If((AScan(aCposObrig,'TMP_VLDEB')==0),.T.,.F.) 
				cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
				AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,STR0051 ,'TMP_VLDEB',.F.}) //"Debito"
			Endif

			nOrdem++
			lEnable := If((AScan(aCposObrig,Alltrim(X3_CAMPO))==0),.T.,.F.) 
			cBMPBOL	:= If(lEnable,"ENABLE","DISABLE")
			AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	Enddo
 
	oGet1:aCols := Aclone( aCpos )
	oGet1:oBrowse:Refresh()
	oGet1:ForceRefresh()
	
	oDlg:Refresh()
	
	RestArea(aArea)
Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGleg() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A355CFGleg()

BrwLegenda(STR0007, STR0060,{	{"DISABLE", STR0035} ,;  //" Campo obrigatorio" //"Legenda"###"Status"
								{"ENABLE" , STR0036} ,;  //" Campo opcional"
								{""		  , " ------------------------ "} ,;
								{"LBTIK"  , STR0037} ,;  //" Selecionado"
								{"LBNO"	  , STR0038}  ;  //" Nao selecionado"
							} )

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGsel() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca a selecao de campos para NAO SELECIONADOS            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A355CFGsel(oGet1,nOpcBMP)

///////
// Var:
Local nFor 	:= 0
Local nA	:= 0


nFor := Len(oGet1:aCols)
For nA := 1 to nFor
	If ( oGet1:aCols[nA][1] = "ENABLE" )
		If     ( nOpcBMP = 1 )
			oGet1:aCols[nA][2] := "LBTIK"
		ElseIf ( nOpcBMP = 2 )
			oGet1:aCols[nA][2] := "LBNO"
		Endif
	Endif
Next nA

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A355CFGgrv() ³Autor ³Bruno Sobieski        ³Data³ 22.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava lista de campos no profile do usuario corrente	      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A355CFGgrv(oGet1)

///////
// Var:
Local cList := ""
Local nA	:= 0

/////////////////////////////
// Atualiza Arrays auxiliares
aCpos := Aclone(oGet1:aCols)

cList := ""
For nA := 1 to Len(aCpos)
	If ( aCpos[nA][2] == "LBTIK" )
		cList := cList + Alltrim( aCpos[nA][5] ) + CRLF
	Endif
Next nA
If FindProfDef( cUserName, cFunName, cProfChave, 'CT2' )
	WriteProfDef( cUserName, cFunName, cProfChave, 'CT2', cUserName, cFunName, cProfChave, 'CT2', cList )
Else                
	WriteNewProf( cUserName, cFunName, cProfChave, 'CT2', cList )
Endif     

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ConfirmaMarca() ³Autor ³Bruno Sobieski     ³Data³ 11.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confirma as marcas ou o registro posicionado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaCt2(aTam,aHead,cAliasQry,oLBCT2,aCpos,lPergunta,cHist,oSay1,oSay2,oSay3,aObs,nOpcao)
Local aLinCt2	:=	{}                
Local cWhere	:=	{}
Local cQuery	:=	""
Local nX
If Select(cAliasQry) > 0
	DbSelectArea(cAliasQry)
	DbCloseArea()
Endif	
//Monta condicao padrão para ambas querys
cWhere	:=	" WHERE CT2_FILIAL = '"+xFilial('CT2')+"' "
If	mv_par02 == mv_par03
	cWhere	+=	" AND CT2_DATA    = '"+Dtos(mv_par02)+"' "
Else
	cWhere	+=	" AND CT2_DATA BETWEEN '"+Dtos(mv_par02)+"' AND '"+Dtos(mv_par03)+"' "
Endif	
cWhere	+=	" AND CT2_VALOR BETWEEN "+STR(mv_par04)+" AND "+STR(mv_par05)+" "
If	mv_par06 == mv_par07
	cWhere	+=	" AND CT2_LOTE    = '"+(mv_par06)+"' "
Else
	cWhere	+=	" AND CT2_LOTE BETWEEN '"+(mv_par06)+"' AND '"+(mv_par07)+"' "
Endif	
If	mv_par08 == mv_par09
	cWhere	+=	" AND CT2_SBLOTE    = '"+(mv_par08)+"' "
Else
	cWhere	+=	" AND CT2_SBLOTE BETWEEN '"+(mv_par08)+"' AND '"+(mv_par09)+"' "
Endif	
If	mv_par10 == mv_par11
	cWhere	+=	" AND CT2_DOC    = '"+(mv_par10)+"' "
Else
	cWhere	+=	" AND CT2_DOC BETWEEN '"+(mv_par10)+"' AND '"+(mv_par11)+"' "
Endif	                     
//MARCADOS PARA DETALHE
If mv_par01 == 2
	cWhere	+=	" AND CT2_CONFST   = '"+CONFST_DET+"' "
Else
	If nOpcao == 1
	//NAO CONFERIDOS
		cWhere	+=	" AND CT2_CONFST   = ' ' "
	Else
	//CONFERIDOS
		cWhere	+=	" AND CT2_CONFST   = '"+CONFST+"'
	Endif
Endif
cWhere	+=	" AND CT2_MOEDLC     = '"+(mv_par12)+"' "
cWhere	+=	" AND CT2_TPSALD    = '"+(mv_par13)+"' "
cWhere	+=	" AND D_E_L_E_T_ = ' ' "

//Monta a query para o credito

cQuery	:= " SELECT CT2_VALOR TMP_VLCRED, 0 TMP_VLDEB, '2' CT2_DC, CT2_DC DCORI, CT2_CONFST, CT2_OBSCNF,"
For nX:=1 To Len(aCpos)                               
	If !Empty(aCpos[nx,5]) .And. Substr(aCpos[nx,5],1,3) <> 'TMP'
		cQuery	+=	aCpos[nX,5] + ","
	Endif
Next
cQuery	+=	" R_E_C_N_O_ RECCT2 "
cQuery	+=	" FROM "+RetSqlName('CT2') +" CT2 "
cQuery	+=	cWhere
cQuery	+=	" AND CT2_CREDIT    = '"+(mv_par14)+"' "
If !Empty(mv_par15)
	cQuery	+=	" AND CT2_CCC    = '"+(mv_par15)+"' "
Endif	
If !Empty(mv_par16)
	cQuery	+=	" AND CT2_ITEMC    = '"+(mv_par16)+"' "
Endif	
If !Empty(mv_par17)
	cQuery	+=	" AND CT2_CLVLCR   = '"+(mv_par17)+"' "
Endif	
cQuery	+=	" AND CT2_DC   IN ('2', '3') "
cQuery	+= " UNION ALL "	

//Monta a query para o debito
cQuery	+= " SELECT 0 TMP_VLCRED, CT2_VALOR TMP_VLDEB, '1' CT2_DC,  CT2_DC DCORI, CT2_CONFST, CT2_OBSCNF,"
For nX:=1 To Len(aCpos)
	If !Empty(aCpos[nx,5]).And. Substr(aCpos[nx,5],1,3) <> 'TMP'
		cQuery	+=	aCpos[nX,5] + ","
	Endif
Next
cQuery	+=	" R_E_C_N_O_ RECCT2 "
cQuery	+=	" FROM "+RetSqlName('CT2') +" CT2 "
cQuery	+=	cWhere
cQuery	+=	" AND CT2_DEBITO    = '"+(mv_par14)+"' "
If !Empty(mv_par15)
	cQuery	+=	" AND CT2_CCD    = '"+(mv_par15)+"' "
Endif	
If !Empty(mv_par16)
	cQuery	+=	" AND CT2_ITEMD    = '"+(mv_par16)+"' "
Endif	
If !Empty(mv_par17)
	cQuery	+=	" AND CT2_CLVLDB   = '"+(mv_par17)+"' "
Endif	
cQuery	+=	" AND CT2_DC   IN ('1', '3') "

cQuery		:=	ChangeQuery(cQuery)
//Obtem os dados
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
For nX := 1 To Len(aCpos)
	SX3->(DbSetOrder(2))
	If SX3->(MsSeek(aCpos[nX,5])) .And. SX3->X3_TIPO <> 'C'
		TCSetField(cAliasQry, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	ElseIf Alltrim(aCpos[nX,5]) == 'TMP_VLCRED' .Or. Alltrim(aCpos[nX,5]) == 'TMP_VLDEB'
		SX3->(MsSeek('CT2_VALOR'))			
		TCSetField(cAliasQry, aCpos[nX,5], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	Endif
Next nA
DbGotop()
//Inclui os dados da marca, se nao vier do refresh
If !lPergunta
	aHead	:=	aSize(aHead,Len(aHead)+1)
	aHead	:=	aIns(aHead,1)
	aHead[1]:=""	
	aTam 	:=	aSize(aTam,Len(aTam)+1)
	aTam 	:=	aIns(aTam,1)
	aTam[1]	:=	6	
Endif
//Carrega os dados em um array
aLinCT2	:={}
While !Eof()                 
	Aadd(aLinCT2,Array(Len(aHead)+3))
	aLinCT2[Len(aLinCT2),1] :=	-1
	For nX:= 1 To Len(aCpos)
		aLinCT2[Len(aLinCT2),nX+1] :=	&(aCpos[nX,5])
	Next
	
	aLinCT2[Len(aLinCT2),nX+1]	:=	RECCT2
	aLinCT2[Len(aLinCT2),nX+2]	:=	CT2_CONFST
	aLinCT2[Len(aLinCT2),nX+3]	:=	DCORI
	If !Empty(CT2_OBSCNF)
		AAdd(aObs, {RECCT2,CT2_OBSCNF})
	Endif
	dBSKIP()			
EndDo
If oLbCt2 <> Nil
	oLBCT2:lColDrag	:= .T.
	oLBCT2:nFreeze	:= 1
	oLBCT2:SetArray(aLinCT2)
	If Len(aLinCt2) > 0  
		oLBCT2:nAT	:= Min(oLBCT2:nAT,Len(aLinCT2))
		oLBCT2:bLine:= &("{ || "+ cBLinCT2 + "} }")
	Else	
		abLineEmpty	:=	Array(Len(oLBCT2:aHeaders))
		aFill(abLineEmpty,"")
		oLBCT2:bLine:= {|| abLineEmpty }
	Endif
	oLBCT2:Refresh()                                                                     
	cHist	:=	""
	oSay1:SetText(STR0020) //'Tipo lancamento :
	oSay2:SetText(STR0021) //'Conta debito    : ' )
	oSay3:SetText(STR0022) //'Conta credito   : ')
Endif

Return aLinCt2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ConfirmaMarca() ³Autor ³Bruno Sobieski     ³Data³ 11.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confirma as marcas ou o registro posicionado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConfirmaMarca(lAll,nPos,aCpos,oLbCt2,aSays,aObs,nOpcao)
Local aLog         := {}
Local aNewDados	:=	{}           
Local aDeleta	:=	{}
Local nX			:=	0
Local lAny		:=	.F.
If Len(aLinCt2) > 0
	If lAll
		For nX:= 1 To Len(aLinCt2)
			If aLinCt2[nX,1] <> -1
				CT2->(MsGoTo(aLinCt2[nX,Len(aLinCt2[nX])-2]))
				If CT2->CT2_CONFST == aLinCt2[nX,Len(aLinCt2[nX])-1]
					GravaCT2(aLinCt2[nX,1],aLinCt2[nX,Len(aLinCt2[nX])],aObs,nOpcao)
					aadd(aDeleta,nX)
					lAny	:=	.T.
				Else
					AAdd(aLog,aClone(aLinCt2[nX]))
				Endif
			Endif
		Next
		For nX:= 1 To Len(aLinCt2)
			If Ascan(aDeleta,nX) == 0
				AAdd(aNewDados,aLinCt2[nX])
			Endif
		Next
		aLinCt2	:=	aClone(aNewDados)
	Else
		CT2->(MsGoTo(aLinCt2[nPos,Len(aLinCt2[nPos])-2]))
		lAny	:=	aLinCt2[nPos,1] <> -1
		If CT2->CT2_CONFST == aLinCt2[nPos,Len(aLinCt2[nPos])-1]
			GravaCT2(aLinCt2[nPos,1],aLinCt2[nPos,Len(aLinCt2[nPos])],aObs,nOpcao)
			aDel(aLinCt2,nPos)
			aSize(aLinCt2,Len(aLinCt2)-1)
		Else
			AAdd(aLog,aClone(aLinCt2[nPos]))
		Endif
	Endif
	If !Empty(aLog)
		Aviso(STR0060,STR0061,{"Ok"}) //'Alguns registros nao puderam ser confirmados'
	Endif
	If oLbCt2 <> Nil
		oLBCT2:lColDrag	:= .T.
		oLBCT2:nFreeze	:= 1
		oLBCT2:SetArray(aLinCT2)
		If Len(aLinCt2) > 0
			oLBCT2:nAT	:= Min(oLBCT2:nAT,Len(aLinCT2))
			oLBCT2:bLine:= &("{ || "+ cBLinCT2 + "} }")
		Else
			abLineEmpty	:=	Array(Len(oLBCT2:aHeaders))
			aFill(abLineEmpty,"")
			oLBCT2:bLine:= {|| abLineEmpty }
		Endif
		oLBCT2:Refresh()
		If lAny
			AtuTotais(aLinCt2,aSays,aCpos)
		Endif
	Endif
EndIf
Return aLog
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaCt2        ³Autor ³Bruno Sobieski     ³Data³ 11.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no CT2 a marca                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaCT2(nMarca,cDC,aObs,nOpcao) 
Local cMarca	:=	''
Local cObs		:=	''
If nOpcao == 1
	//Marca para analise detalhada
	If nMarca == 2
		cMarca	:=	CONFST_DET                                    
		nPosObs	:=	Ascan(aObs,{ |x| x[1] == CT2->(Recno()) } )
		If nPosObs > 0
			cObs	:=	aObs[nPosObs][2]
		Endif
	Else
		cMarca	:=	CONFST
	Endif
	
	RecLock('CT2',.F.)
	Replace CT2_CONFST	With cMarca
	Replace CT2_OBSCNF	With cObs
	Replace CT2_USRCNF	With cUserName
	Replace CT2_DTCONF	With MSDate()
	Replace CT2_HRCONF	With Time()
	MsUnLock()	
	If &(cMarca) > 0
  		 CfContHist(aLinCt2,cMarca,cObs,cUserName,CT2->(Recno()),nOpcao)
	EndIf
Else
	RecLock('CT2',.F.)
	Replace CT2_CONFST	With ' '
	Replace CT2_OBSCNF	With ' '
	Replace CT2_USRCNF	With ' '
	Replace CT2_DTCONF	With Ctod('')
	Replace CT2_HRCONF	With ' '
	MsUnLock()	
	CfContHist(aLinCt2,,,,CT2->(Recno()),nOpcao)
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BrwSetOrderºAutor ³Microsiga           º Data ³  09/21/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BrwSetOrder(o,y,lAsc,aItems)


If y > 1 .And. Len(aItems) > 0
	If lAsc == Nil  
		lAsc	:=	.T.
	Endif	                               
	If ValType(aItems[o:nAt][y]) == 'C'
		Asort(aItems,,,IIf(lAsc,{|a,b| Upper(a[y]) < Upper(b[y])},{|a,b| Upper(a[y])> Upper(b[y])} ))
		cPos	:=	Upper(aItems[o:nAt][y])
		o:nAt	:=	Ascan(aItems,{|x| Upper(x[y]) == cPos})
	ElseIf ValType(aItems[o:nAt][y]) == 'D'
		Asort(aItems,,,IIf(lAsc,{|a,b| DTOS(a[y]) < DTOS(b[y])},{|a,b| DTOS(a[y])> DTOS(b[y])} ))
		cPos	:=	DTOS(aItems[o:nAt][y])        
		o:nAt	:=	Ascan(aItems,{|x| DTOS(x[y]) == cPos})
	ElseIf ValType(aItems[o:nAt][y]) == 'N'
		Asort(aItems,,,IIf(lAsc,{|a,b| a[y] < b[y]},{|a,b| a[y]>b[y]} ))
		cPos	:=	aItems[o:nAt][y]
		o:nAt	:=	Ascan(aItems,{|x| x[y] == cPos})
	Endif
	lAsc	:=	!lAsc
	If lAsc
		lAsc	:=	Nil
	Endif	
	o:Refresh()
Endif
Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuHist           ³Microsiga           º Data ³  09/21/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o historico quando muda de registro                º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function AtuHist(oSay1,oSay2,oSay3,cHist,oHist,oLBCT2,aLinCt2,cObs,aObs,oGetObs)
Local cAliasQry	:=	GetNextAlias()
Local cQuery
Local nRecno	:=	0
If Len(aLinCT2)>0
	CT2->(MsGoto(aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2]))
//	aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2]	
	oSay1:SetText(STR0020+ AcaX3Combo('CT2_DC',CT2->CT2_DC))
	oSay2:SetText(STR0021+ CT2->CT2_DEBITO)
	oSay3:SetText(STR0022+ CT2->CT2_CREDIT)
	nPosObs	:=	Ascan(aObs,{|x| x[1] == CT2->(RECNO())})
	If nPosObs > 0
		cObs	:=	aObs[nPosObs][2]
	Else
		cObs	:=	""
	Endif	
	cHist	:= CT2->CT2_HIST
	cQuery	:=	"SELECT CT2_HIST FROM "+RetSqlName('CT2') +" CT2 "
	cQuery	+=	" WHERE CT2_FILIAL = '"+CT2->CT2_FILIAL+"' "
	cQuery	+=	" AND CT2_DATA     = '"+Dtos(CT2->CT2_DATA)+"' "
	cQuery	+=	" AND CT2_LOTE     = '"+CT2->CT2_LOTE+"' "
	cQuery	+=	" AND CT2_SBLOTE   = '"+CT2->CT2_SBLOTE+"' "
	cQuery	+=	" AND CT2_DOC      = '"+CT2->CT2_DOC +"' "
	cQuery	+=	" AND CT2_SEQLAN   = '"+CT2->CT2_SEQLAN +"' "
	cQuery	+=	" AND CT2_EMPORI   = '"+CT2->CT2_EMPORI +"' "
	cQuery	+=	" AND CT2_FILORI   = '"+CT2->CT2_FILORI +"' "
	cQuery	+=	" AND CT2_DC = '4' "
	cQuery	+=	" AND D_E_L_E_T_ = ' ' "
	cQuery	+=	" ORDER BY CT2_SEQHIS  "
	cQuery		:=	ChangeQuery(cQuery)
	//Obtem os dados
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	While !Eof() 
		cHist += CRLF+CT2_HIST
		dbSkip()
	Enddo
	DbCloseArea()                                                                                                            
	DbSelecTArea('CT2')
Else
	oSay1:SetText(STR0020)
	oSay2:SetText(STR0021)
	oSay3:SetText(STR0022)
	cHist 	:= ""
	cObs	:=	""
Endif
oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()
oHist:Refresh()                   
oGetObs:Refresh()                   
oGetObs:SetFocus()
oLBCt2:SetFocus()

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Atutotais   ³ Autor ³ Bruno Sobieski       ³ Data ³ 17.06.2007        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama a função de atualziacao de totais na tela                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaCtb 			                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function	AtuTotais(aLinCt2,aSays,aCpos)
Local nPosCrd	:=	Ascan(aCpos,{|x| x[5] == 'TMP_VLCRED' })+1
Local nPosDeb	:=	Ascan(aCpos,{|x| x[5] == 'TMP_VLDEB' })+1
Local nPosVlr	:=	Ascan(aCpos,{|x| Alltrim(x[5]) == 'CT2_VALOR' })+1
Local nPosTipo	:=	Ascan(aCpos,{|x| Alltrim(x[5]) == 'CT2_DC' })+1
Local nTotDeb 	:= 0
Local nTotCrd	:= 0                                   
If (nPosDeb > 1 .And. nPosCrd>1) 
	If Len(aLinCT2) > 0
		AEval(aLinCt2,{|x| nTotDeb += x[nPosDeb],nTotCrd += x[nPosCrd]})
	Endif
Else
	If Len(aLinCT2) > 0
		AEval(aLinCt2,{|x| nTotDeb += IIf(x[nPosTipo]$'13',x[nPosVlr],0),nTotCrd +=  IIf(x[nPosTipo]$'23',x[nPosVlr],0)})
	Endif
Endif	
aSays[1]:SetText(Alltrim(TransForm(nTotDeb,PesqPict('CT2','CT2_VALOR'))))
aSays[2]:SetText(Alltrim(TransForm(nTotCrd,PesqPict('CT2','CT2_VALOR'))))
aSays[3]:SetText(Alltrim(TransForm(nTotDeb-nTotCrd,PesqPict('CT2','CT2_VALOR'))))
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb355Lcto  ³ Autor ³ Bruno Sobieski       ³ Data ³ 17.06.2007        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama a função de visualização do lançamento posicionado na GetDB     ³±±
±±³          ³utilizando a tela de visualização do CTBA101.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaCtb 			                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb355Lcto(oLbCT2)
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())
If Len(aLinCT2)>0
	dbSelectArea("CT2")
	dbSetOrder(1)
	MsGoto(aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2])
	CTBA101(2)			// Chama o CTBA101 para visualização
Endif

RestArea(aAreaCT2)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FtBs³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro generico para posicionar o cursor no registro exato ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTB355FtBs(oLBCt2,cFiltro,cTexto,aCposOri)

Local nRowPos	 := oLBCT2:nAt
Local nMaxPos	 := oLBCT2:nLen   
Local cMsg		 := ""
Local cCampo 	 :=	""                                       
Local lFind		 := .F.
Local nOpc		 :=	1
Local aOpcoes	 :=	{"Nova","Anterior","Proxima","Cancela"}
Local nSkip		 := 0
Local nLimite	 := nMaxPos
Local nX					 
If !Empty(cFiltro)
	nOpc	:=	Aviso(STR0062,cTexto,aOpcoes) //Pesquisa
Endif
If nOpc <> 4 .And. Len(aLinCt2) > 0
	If Empty(cFiltro).Or. nOpc == 1
		cFiltro	:= strtran( cFiltro, "M->", "" )
		aFiltro := CTB355FlTl(aCposOri,@cFiltro,@cTexto)
		cFiltro	:=	aFiltro[1]
		cTexto	:=	aFiltro[2]
		nOpc		:=	aFiltro[3]
	Endif
	If nOpc == 1
		nSkip	:=	1
	ElseIf nOpc == 2
		nSkip	:=	-1
	ElseIf nOpc == 3
		nSkip	:=	1
	Else
		Return
	Endif		
	
	If !Empty( cFiltro )
		If AllTrim(Str(nOpc)) $ "2/3" .And. oLBCT2:nAt+nSkip >= 1 .And. oLBCT2:nAt+nSkip <= nLimite
			oLBCT2:nAt := oLBCT2:nAt+nSkip
		EndIf
		While  !(lFind)
			For nX := 1 To Len(aCposOri)
				&("M->"+aCposOri[nX,5])	:=	aLinCt2[oLBCt2:nAt,nX+1]
			Next
			lFind := &(cFiltro)
			oLBCT2:Refresh()
			If !(lFind)
				If oLBCT2:nAt+nSkip < 1 .Or. oLBCT2:nAt+nSkip > nLimite
					Exit
				Endif
				oLBCT2:nAt:=oLBCT2:nAt+nSkip
			EndIf
		Enddo
	
		If !lFind    
			cMsg := "Nenhum lancamento encontrado "
			If nOpc == 2
				cMsg += "acima" 
			ElseIf nOpc == 3
				cMsg += "abaixo"
			Endif
			MsgInfo( cMsg ) 
			oLBCt2:nAt := nRowPos
		Endif
		oLBCt2:SetFocus()
		oLBCT2:Refresh()
	Endif
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FlTl³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro parecido com BuildExpr()							  ³±±
±±³          ³ Criado pela necessidade de se trabalhar com o Arq. TMP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105 e CTBA102                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB355FlTl(aCposOri,cExpFil,cTxtFil)

Local oDlgPesq
Local oBtna , oBtn  , oBtnOp, oBtne, oBtnOu
Local oMatch, oCampo, oOper , oExpr, oTxtFil
Local aCpos		:= {}
Local aCampo	:= {}
Local aStrOp	:= {}
Local aStru		:= {}
Local cTitulo	:= ""
Local cCampo	:= ""
Local cExpr		:= ""
Local cOper		:= ""
Local nMatch 	:= 0
Local nA		:= 0
Local nOpc		:= 4

Private cAlias2	:= ""
Private cAlias	:= ""

Default cTxtFil := ""
Default cExpFil := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos do Localizador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetorder(2))
For nA:= 1 to Len(aCposOri)
	SX3->(DbSeek(If(Substr(aCposOri[nA,5],1,3) <> 'TMP',aCposOri[nA,5],'CT2_VALOR')))
	AADD( aCpos , aCposOri[nA,4] )
	AADD( aCampo,{aCposOri[nA,5],aCposOri[nA,4],.T.,"01",SX3->X3_TAMANHO,If(Empty(SX3->X3_PICTURE),Space(45),SX3->X3_PICTURE),SX3->X3_TIPO,SX3->X3_DECIMAL})
Next nA

cTitulo := "Localizar"

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL

	aStrOp := { STR0063, STR0064, STR0065, STR0066, STR0067, STR0068, STR0069, STR0070, STR0071, STR0072 }
//"Igual a","Diferente de","Menor que","Menor ou igual a","Maior que","Maior ou igual a","Contem a expressao","Nao contem","Esta contido em","Nao esta contido em"}
	
	@ 05,005 SAY OemToAnsi(STR0023+":"    ) SIZE 20,8 PIXEL OF oDlgPesq //campo:
	@ 05,060 SAY OemToAnsi(STR0073 ) SIZE 30,8 PIXEL OF oDlgPesq //OPERADOR:
	@ 05,115 SAY OemToAnsi(STR0074) SIZE 30,8 PIXEL OF oDlgPesq //expressao:
	@ 50,005 SAY OemToAnsi(STR0075) SIZE 20,8 PIXEL OF oDlgPesq //filtro:
	
	@ 35,005 BUTTON oBtna PROMPT OemToAnsi("&Adiciona") SIZE 35,10 OF oDlgPesq PIXEL ; //
		ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,cExpr,.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
		FONT oDlgPesq:oFont
	
	@ 35,45 BUTTON oBtn PROMPT OemToAnsi("&Limpa Filtro") SIZE 35,10 OF oDlgPesq PIXEL ; //
		ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
		FONT oDlgPesq:oFont
	
	@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
		ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;
	
	@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
		ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;
	
	@ 45,175 BUTTON oBtne PROMPT OemToAnsi(" E ") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //
		ACTION (cTxtFil+=" e ",cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //
	
	@ 45,190 BUTTON oBtnOu PROMPT OemToAnsi(" OU ") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //
		ACTION (cTxtFil+=" ou ",cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //
	oMatch:Disable()
	
	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	cExpr := CalcField(oCampo:nAt,aCampo)
	cOper := aStrOp[1]
	
	@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	
`	@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont
	
	@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
	oTxtFil:bRClicked := {||AlwaysTrue()}
	
	If Empty(cExpFil) .And. Empty(cTxtFil)
		oBtne:Disable()
		oBtnou:Disable() 
	Else
		oBtna:Disable()
		oBtnOp:Disable()
		oMatch:Disable()
	Endif
	
	DEFINE SBUTTON o1 FROM 113,115  TYPE 20  ACTION (nOpc:=2,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o2 FROM 113,145  TYPE 19  ACTION (nOpc:=3,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o3 FROM 113,175  TYPE 02  ACTION (nOpc:=4                             ,oDlgPesq:End()) OF oDlgPesq When .T.
	
	o1:cToolTip := "Localizar Anterior"
	o2:cToolTip := "Localizar Proximo"

ACTIVATE MSDIALOG oDlgPesq CENTERED
cExpFil	:=	STRTRAN(cExpFIL,"CT2_","M->CT2_")
cExpFil	:=	STRTRAN(cExpFIL,"TMP_","M->TMP_")
Return {cExpFil,cTxtFil,nOpc }
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³BuildTxt  ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+cValToChar(xExpr)+If(cType=="C",cChar,"")

If cType == "C"
	If aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ AllTrim('+aCampo[nCpo,1]+'))'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!(AllTrim('+aCampo[nCpo,1]+") $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ AllTrim("+aCampo[nCpo,1] +" )"   // Inverte Posicoes
	Else
		If (aOper[nOper]=="==")
			cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
			cExpFil += '"'+cValToChar(xExpr)+'"'
		Else
			cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
		EndIf
	EndIf
ElseIf cType == "D"
	// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
	// 						 
	cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CalcField ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcField(nAt,aCampo)

Local cRet

If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidText ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta experessao de busca para que nao gere error.log     ³±±
±±³          ³ de Invalid Macro por inconsistencia.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidText(cExp,cTxt)

Local lValid := .F.	

Default cExp := ""
Default cTxt := ""

If !Empty(cExp) .And. !Empty(cTxt)
	While !lValid
		Do Case
			Case Right(cTxt,2) == "( "  
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,2) == "E "
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,3) == "OU "
				cTxt := Left( cTxt, Len(cTxt)-4 )
			Case Right(cExp,1) == "("
				cExp := Left( cExp, Len(cExp)-1 )
			Case Right(cExp,5) == ".and."	
				cExp := Left( cExp, Len(cExp)-5 )
			Case Right(cExp,4) == ".or."	
				cExp := Left( cExp, Len(cExp)-4 )
			Otherwise
				lValid := .T.
		End Case
	EndDo
Endif

Return

Static Function ADDCT2Obs(cObs,aObs,oLBCt2)
If Len(aLinCt2) > 0
	nPosObs	:=	Ascan(aObs,{ |x| x[1] == aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2] } )
	If nPosObs > 0
		aObs[nPosObs][2] := cObs
	Else
		AAdd(aObs,{aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2],cObs})
	Endif	
Endif
Return .T.

Static Function CTB355Rast(oLBCt2)
If Len(aLinCT2)>0
	CT2->(MsGoto(aLinCt2[oLBCT2:nAt][Len(aLinCt2[oLBCT2:nAt])-2]))
	CtbC010Rot()
Endif
Return

Function CTBA3554()
Local aCores := {	{  "BR_VERDE", STR0076},;  //"Nao conferido"
					{  "BR_PRETO", STR0077},;  //"Conferido"
					{  "BR_VERMELHO", STR0078}} //"Re-analisar"

BrwLegenda(cCadastro,STR0007,aCores) //"Legenda"

Return

Static Function AcaX3Combo(cCampo,cConteudo)
Local aSx3Box   := RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
If cConteudo == ""
	cConteudo := " " 
EndIf
REturn Upper(AllTrim( aSx3Box[Ascan( aSx3Box, { |aBox| aBox[2] = cConteudo } )][3] ))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CfContHist ³ Autor ³ Igor S. Nascimento   ³ Data ³ 27.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca como conferido a continuacao do historico do lcto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GravaCT2                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CfContHist(aLinCt2,cMarca,cObs,cUserName,nReg,nOpcao)

Default cMarca := "1"

dbSelectArea("CT2")
dbSetOrder(10)
If MsSeek(xFilial("CT2")+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQHIS,.F.)
	CT2->(dbSkip())
		While !CT2->(Eof())	.And.;	
					CT2->CT2_FILIAL == xFilial("CT2")		.And.;
					CT2->CT2_DATA   == aLinCt2[1][2]		.And.;
					CT2->CT2_LOTE   == aLinCt2[1][3]		.And.;
					CT2->CT2_SBLOTE == aLinCt2[1][4]		.And.;
					CT2->CT2_DOC    == aLinCt2[1][5]		.And.;
					CT2->CT2_DC	  == "4"
					If nOpcao == 1			
					// grava cont. hist.
					 	RecLock('CT2',.F.)
						Replace CT2_CONFST	With cMarca
						Replace CT2_OBSCNF	With cObs
						Replace CT2_USRCNF	With cUserName
						Replace CT2_DTCONF	With MSDate()
						Replace CT2_HRCONF	With Time()
						MsUnLock()
					Else
					// desmarca Lcto quando Estorno
						RecLock('CT2',.F.)
						Replace CT2_CONFST	With ' '
						Replace CT2_OBSCNF	With ' '
						Replace CT2_USRCNF	With ' '
						Replace CT2_DTCONF	With Ctod('')
						Replace CT2_HRCONF	With ' '
						MsUnLock()
					EndIf
					CT2->(dbSkip())
		EndDo		
EndIf
CT2->(dbGoTo(nReg))

Return

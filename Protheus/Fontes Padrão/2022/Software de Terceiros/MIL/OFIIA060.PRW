// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 15     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "Ofiia060.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA060 ³ Autor ³  Renata               ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exportacao dos dados da garantia VW p/arq integracao(VI6/VIC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³INTEGRACAO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIIA060(cMrcBrow,nOpcBrow)

Local cChave, cCond
Private aCampos := {} , Inclui := .f.

Private aRotina := { { STR0001 ,"axPesqui", 0 , 1},;
{ STR0002 ,"IA060V", 0 , 2},;    //VISUALIZAR
{ STR0003 ,"IA060E", 0 , 3}}  //

Private cCadastro := OemToAnsi(STR0004)   //"Exportacao dos Dados da Garantia  p/ Fabrica
Private cPerg := "OIA060" 	// TODO -Pergunte
Private nIndex := 0
Private lAbortPrint := .f.
Private cMarca

If ( ValType(cMrcBrow) == "U" .Or. ValType(nOpcBrow) == "U" )
	
	cMarca := GetMark()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("VGA")
	dbSetOrder(1)
	
	cIndex := CriaTrab(nil,.f.)
	cChave  := IndexKey()   //"VO1_FILIAL+VO1_NUMOSV"
	cCond   := 'VGA->VGA_TRANSM == "N" .and. VGA->VGA_EXPGAR == "S" .and. (VGA->VGA_ESPGAR == "S" .And. VGA->VGA_CODGAR # space(5) .or. VGA->VGA_ESPGAR == "R" .And. VGA->VGA_CODREV # space(2))'
	IndRegua("VGA",cIndex,cChave,,cCond,STR0005)
	
	DbSelectArea("VGA")
	nIndex := RetIndex("VGA")
	#IFNDEF TOP
		dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	
	&&mBrowse( 6, 1,22,75,"VGA")
	Markbrow("VGA","VGA_OK",,,,cMarca)
	
	dbSelectArea("VGA")
	RetIndex("VGA")
	DbsetOrder(1)
	#IFNDEF TOP
		If File(cIndex+OrdBagExt())
			fErase(cIndex+OrdBagExt())
		Endif
	#ENDIF
	
Else
	
	cMarca := cMrcBrow
	
	If nOpcBrow == 2
		IA060V("VGA",VGA->(Recno()),nOpcBrow)
	ElseIf nOpcBrow == 3
		IA060E("VGA",VGA->(Recno()),nOpcBrow)
	EndIf
	
EndIf

Volta_EXPVGA()     //Volta o VGA_EXPGAR P/ "S"

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA060V    ³ Autor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ visualiza os dados dos arquivos                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IA060V(cAlias,nReg,nOpc)  - MODELO 3                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA060V(cAlias,nReg,nOpc)

if EMPTY(VGA->VGA_CODGAR) .and. !empty(VGA->VGA_CODREV)
	
	CPOIA060()
	AxVisual(cAlias,nReg,nOpc,aCampos)
	
else
	
	FS_IA060M3(cAlias,nReg,nOpc)
	
endif

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IA060M3ºAutor  ³Microsiga           º Data ³  09/11/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza no formata modelo3                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IA060M3(cAlias,nReg,nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aCols := {} , aHeader := {} , aCpoEnchoice:={}
Private aRotina := { { "" ,"", 0 , 1   },;
{ "" ,"", 0 , 2   },;    //VIZUALIZAR
{ "" ,"", 0 , 4, 2},;   //ALTERAR
{ "","",  0,  4, 2}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VGA",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VGA")

While !Eof().and.(x3_arquivo=="VGA")
	
	if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VGA_ESPGAR/VGA_CODREV/VGA_GRUREV/VGA_DNRESP/VGA_IMPOSV/VGA_NUMNFI/VGA_SERIEN/VGA_TRANSM/VGA_ARQFAB/VGA_DATRET/VGA_DATTRA/VGA_DATCRE/VGA_VALCRE/VGA_LANCRE/VGA_DATDEB/VGA_VALDEB/VGA_LANDEB/VGA_CODEST/VGA_DIFPGT/VGA_SITOSV/VGA_TRANSM/VGA_NUMNFI/VGA_SERIEN/VGA_SITUAC/VGA_EXPGAR])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	
	&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	dbSkip()
End

If !(Inclui)
	DbSelectArea("VGA")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

if nOpc == 3   //ALTERAR
	nOpcE := 4
	nOpcG := 4
elseif nOpc == 2  //VIZUALIZAR
	nOpcE := 2
	nOpcG := 2
else
	nOpcE := 5      //EXCLUIR
	nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0

dbSelectArea("SX3")
dbSeek("VG5")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG5")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VG5_NUMOSV/VG5_CODMAR/VG5_DESMAR/VG5_DESGRU/VG5_TRANSM/VG5_NUMNFI/VG5_SERIEN])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		
		&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	Endif
	
	dbSkip()
	
End

If Inclui
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
Else
	
	aCols:={}
	
	dbSelectArea("VG5")
	dbgotop()
	
	if !empty(M->VGA_NUMOSV)
		dbSetOrder(3)
		dbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMOSV)
		
		While !eof() .and. M->VGA_CODMAR+M->VGA_NUMOSV == VG5->VG5_CODMAR+VG5->VG5_NUMOSV .And. VG5->VG5_FILIAL == xFilial("VG5")
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
		
	else
		
		dbSetOrder(4)
		dbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMNFI)
		
		While !eof() .and. M->VGA_CODMAR+M->VGA_NUMNFI == VG5->VG5_CODMAR+VG5->VG5_NUMNFI .And. VG5->VG5_FILIAL == xFilial("VG5")
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
		
	endif
	
Endif

If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cTitulo       :=STR0004    //"Garantia Solicitada"
	cAliasEnchoice:="VGA"
	cAliasGetD    :="VG5"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :="FS_TudOk()"   //"FS_OrdGaVw('M->VG5_ORDITE','VGA->VGA_NUMOSV'),FS_GarOk()"
	cFieldOk      :="FG_MEMVAR(),FS_CODINT(),FS_ITEEXT()"
	
	If !(Inclui)
		DbSelectArea("VGA")
		dbgotop()
		DbSetOrder(1)
		dbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMOSV)
	Endif
	
	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	
Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA060e    ³ Autor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ chama a funcao fs_expvga, feito dessa forma por causa do   ³±±
±±³          ³ termometro                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IA060E(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA060E(cAlias,nReg,nOpc)

Processa( {|| if(nOpc == 3,FS_EXPVGA(),FS_EXPARQ()) },OemToAnsi(STR0006),"",.t. ) //Aguarde a exportacao de dados

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_EXPARQ ³ Autor ³Thiago                 ³ Data ³ 29/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exporta arquivo de integracao.			                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_EXPARQ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXPARQ()

Local lAchou := .t. , cCGCCPF , cNOMCLI , cENDCLI , cCIDCLI , cESTCLI , cENDPOS , cDDDFON , cNumero , cTELEFO
Local cEmaCli, cNumCli, cComCli, cBaiCli, cSexCli, cPesCli, cCPFCli, cDDDCel, cNumCel
Local cRecons , cNfiFec , lRet := .t. , nCpo:=0 , nFoundCpo:=0
Local i
Local aLayCHI    := {}
Local aLayCHF    := {}
Local aLayCGI    := {}
Local aLayCGF    := {}
Local aLayCG1    := {}
Local aLayCG2    := {}
Local aLayCG3    := {}
Local aLayCG4    := {}
Local aLayCG5    := {}
Local aLayCG7    := {}
Local aValCG1    := {}
Local aValCG2    := {}
Local aValCG3    := {}
Local aValCG4    := {}
Local aValCG5    := {}
Local aValCG7    := {}
Private aLinhasRel := {}
Private lMsHelpAuto := .t.

CriaSX1()
if !Pergunte(cPerg,.T. )
	Return(.f.)
Endif


cArquivo := "OFIIA060.TXT"
nHnd := FCREATE(Alltrim(MV_PAR01)+Alltrim(cArquivo),0)

aAdd(aLayCHI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CHI)
aAdd(aLayCHI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCHI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCHI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCHI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHI, { "N", 12, 0,	14})    // DATA DA GERAÇÃO (0000ddmmaaaa)
aAdd(aLayCHI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
aAdd(aLayCHI, { "N", 14, 0,	40})    // IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCHI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
aAdd(aLayCHI, { "C",110, 0,	84})    // BRANCOS

aAdd(aLayCHF, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CHF)
aAdd(aLayCHF, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCHF, { "N", 5,	0,	5})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHF, { "N", 9,	0, 10})     // TOTAL DE REGISTROS TRANSMITIDOS
aAdd(aLayCHF, { "C",175,0, 19})     // BRANCOS


// CGI - LAYOUT DO REGISTRO DE INICIO DE TRANSMISSÃO DO PROCESSO

aAdd(aLayCGI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CGI)
aAdd(aLayCGI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCGI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCGI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCGI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCGI, { "N", 12, 0,	14})    // DATA DO MOVIMENTO (0000ddmmaaaa)
aAdd(aLayCGI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
aAdd(aLayCGI, { "N", 14, 0,	40})    // IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCGI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
aAdd(aLayCGI, { "C", 110, 0,	84})    // BRANCOS


// CGF - LAYOUT DO REGISTRO DE FIM DE TRANSMISSÃO DO PROCESSO
aAdd(aLayCGF, { "C", 3, 0, 1})		// TIPO DE REGISTRO (CGF)
aAdd(aLayCGF, { "N", 1, 0, 4})		// VERSÃO DO LAYOUT (1)
aAdd(aLayCGF, { "N", 5, 0, 5})		// CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCGF, { "N", 9, 0, 10})		// TOTAL DE REGISTROS TRANSMITIDOS
// "  Quantidade total de registros de uma transmissão, incluindo os registros CGI e CGF."
aAdd(aLayCGF, { "C", 175, 0, 19}) 	// BRANCOS


// CG1 - SOLICITAÇÃO DE GARANTIA - CABEÇALHO

aAdd(aLayCG1, { "C", 3, 0,  1} )     // TIPO DE REGISTRO (CG1)
aAdd(aLayCG1, { "N", 6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG1, { "N", 5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG1, { "C", 1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG1, { "C", 1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG1, { "C", 3, 0, 17} )     // TMA (Modelo)
aAdd(aLayCG1, { "C",17, 0, 20} )     // NÚMERO DO CHASSIS
aAdd(aLayCG1, { "N", 6, 0, 37} )     // DATA DA VENDA (mmaaaa)
aAdd(aLayCG1, { "N", 8, 0, 43} )     // DATA DO REPARO (ddmmaaaa)
aAdd(aLayCG1, { "N", 6, 0, 51} )     // QUILOMETRAGEM
aAdd(aLayCG1, { "C", 1, 0, 57} )     // TIPO DE GARANTIA
aAdd(aLayCG1, { "N", 6, 0, 58} )     // NÚMERO DA NOTA FISCAL
aAdd(aLayCG1, { "N", 6, 0, 64} )     // NÚMERO DA AUTORIZAÇÃO
aAdd(aLayCG1, { "C", 6, 0, 70} )     // RESERVA 1
aAdd(aLayCG1, { "C", 6, 0, 76} )     // RESERVA 2
aAdd(aLayCG1, { "C", 6, 0, 82} )     // RESERVA 3
aAdd(aLayCG1, { "C", 6, 0, 88} )     // RESERVA 4
aAdd(aLayCG1, { "N",15, 3, 94} )     // VALOR TOTAL DE PEÇAS
aAdd(aLayCG1, { "N", 5, 2,113} )     // VALOR TOTAL UNIDADE DE TEMPO
aAdd(aLayCG1, { "C", 1, 0,114} )     // LOCAL DE ATENDIMENTO
aAdd(aLayCG1, { "C",79, 0,115} )     // BRANCOS

// CG2 - SOLICITAÇÃO DE GARANTIA - ITENS NORMAIS

aAdd(aLayCG2, { "C", 3, 0,  1} )     // TIPO DE REGISTRO (CG2)
aAdd(aLayCG2, { "N", 6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG2, { "N", 5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG2, { "C", 1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG2, { "C", 1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG2, { "N", 2, 0, 17} )     // LINHA (De 01 a 99)
aAdd(aLayCG2, { "C", 2, 0, 19} )     // DEFEITO
aAdd(aLayCG2, { "C", 3, 0, 21} )     // FORNECEDOR / LOCAL
aAdd(aLayCG2, { "N", 2, 0, 24} )     // QUANTIDADE
aAdd(aLayCG2, { "C",20, 0, 26} )     // NÚMERO DA PEÇA
aAdd(aLayCG2, { "C", 8, 0, 46} )     // CÓDIGO OPERAÇÃO DE SERVIÇO
aAdd(aLayCG2, { "N", 2, 0, 54} )     // LINHA
aAdd(aLayCG2, { "C", 2, 0, 56} )     // DEFEITO
aAdd(aLayCG2, { "C", 3, 0, 58} )     // FORNECEDOR / LOCAL
aAdd(aLayCG2, { "N", 2, 0, 61} )     // QUANTIDADE
aAdd(aLayCG2, { "C",20, 0, 63} )     // NÚMERO DA PEÇA
aAdd(aLayCG2, { "C", 8, 0, 83} )     // CÓDIGO OPERAÇÃO DE SERVIÇO
aAdd(aLayCG2, { "N", 2, 0, 91} )     // LINHA
aAdd(aLayCG2, { "C", 2, 0, 93} )     // DEFEITO
aAdd(aLayCG2, { "C", 3, 0, 95} )     // FORNECEDOR / LOCAL
aAdd(aLayCG2, { "N", 2, 0, 98} )     // QUANTIDADE
aAdd(aLayCG2, { "C",20, 0,100} )     // NÚMERO DA PEÇA
aAdd(aLayCG2, { "C", 8, 0,120} )     // CÓDIGO OPERAÇÃO DE SERVIÇO
aAdd(aLayCG2, { "N", 2, 0,128} )     // LINHA
aAdd(aLayCG2, { "C", 2, 0,130} )     // DEFEITO
aAdd(aLayCG2, { "C", 3, 0,132} )     // FORNECEDOR / LOCAL
aAdd(aLayCG2, { "N", 2, 0,135} )     // QUANTIDADE
aAdd(aLayCG2, { "C",20, 0,137} )     // NÚMERO DA PEÇA
aAdd(aLayCG2, { "C", 8, 0,157} )     // CÓDIGO OPERAÇÃO DE SERVIÇO
aAdd(aLayCG2, { "C",29, 0,165} )     // BRANCOS

// CG3 - CG3 - SOLICITAÇÃO DE GARANTIA - ITENS ADICIONAIS

aAdd(aLayCG3, { "C", 3, 0,  1} )     // TIPO DE REGISTRO (CG3)
aAdd(aLayCG3, { "N", 6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG3, { "N", 5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG3, { "C", 1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG3, { "C", 1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG3, { "N", 2, 0, 17} )     // LINHA (De 01 a 99)
aAdd(aLayCG3, { "C", 2, 0, 19} )     // DEFEITO
aAdd(aLayCG3, { "C", 3, 0, 21} )     // FORNECEDOR / LOCAL
aAdd(aLayCG3, { "N",15, 3, 24} )     // VALOR DO MATERIAL
aAdd(aLayCG3, { "N", 4, 2, 39} )     // MÃO DE OBRA (UT)
aAdd(aLayCG3, { "C",20, 0, 43} )     // DESCRIÇÃO
aAdd(aLayCG3, { "N", 2, 0, 63} )     // LINHA
aAdd(aLayCG3, { "C", 2, 0, 65} )     // DEFEITO
aAdd(aLayCG3, { "C", 3, 0, 67} )     // FORNECEDOR / LOCAL
aAdd(aLayCG3, { "N",15, 3, 70} )     // VALOR DO MATERIAL
aAdd(aLayCG3, { "N", 4, 2, 85} )     // MÃO DE OBRA (UT)
aAdd(aLayCG3, { "C",20, 0, 89} )     // DESCRIÇÃO
aAdd(aLayCG3, { "N", 2, 0,109} )     // LINHA
aAdd(aLayCG3, { "C", 2, 0,111} )     // DEFEITO
aAdd(aLayCG3, { "C", 3, 0,113} )     // FORNECEDOR / LOCAL
aAdd(aLayCG3, { "N",15, 3,116} )     // VALOR DO MATERIAL
aAdd(aLayCG3, { "N", 4, 2,131} )     // MÃO DE OBRA (UT)
aAdd(aLayCG3, { "C",20, 0,135} )     // DESCRIÇÃO
aAdd(aLayCG3, { "C",39, 0,155} )     // BRANCOS

// CG4 - SOLICITAÇÃO DE GARANTIA - IDENTIFICAÇÃO DO CLIENTE

aAdd(aLayCG4, { "C", 3, 0,  1} )     // TIPO DE REGISTRO (CG4)
aAdd(aLayCG4, { "N", 6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG4, { "N", 5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG4, { "C", 1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG4, { "C", 1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG4, { "C",30, 0, 17} )     // NOME DO CLIENTE
aAdd(aLayCG4, { "C",30, 0, 47} )     // ENDEREÇO
aAdd(aLayCG4, { "C",20, 0, 77} )     // CIDADE
aAdd(aLayCG4, { "C", 2, 0, 97} )     // ESTADO
aAdd(aLayCG4, { "C", 8, 0, 99} )     // CEP (CÓDIGO DE ENDEREÇAMENTO POSTAL)
aAdd(aLayCG4, { "C", 4, 0,107} )     // CÓDIGO DDDD TELEFONE
aAdd(aLayCG4, { "C", 8, 0,111} )     // NÚMERO DO TELEFONE
aAdd(aLayCG4, { "C",75, 0,119} )     // BRANCOS


// CG5 - SOLICITAÇÃO DE GARANTIA - EXTENSÃO DE DADOS DA IDENTIFICAÇÃO DO CLIENTE

aAdd(aLayCG5, { "C", 3, 0,  1} )     // TIPO DE REGISTRO (CG5)
aAdd(aLayCG5, { "N", 6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG5, { "N", 5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG5, { "C", 1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG5, { "C", 1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG5, { "C", 2, 0, 16} )     // CODIGO DO REGISTRO
aAdd(aLayCG5, { "C",50, 0, 19} )     // EMAIL (Endereço Eletrônico)
aAdd(aLayCG5, { "C", 6, 0, 69} )     // NUMERO DO ENDEREÇO
aAdd(aLayCG5, { "C",20, 0, 75} )     // COMPLEMENTO DE ENDEREÇO
aAdd(aLayCG5, { "C",30, 0, 95} )     // BAIRRO (Nome do Bairro)
aAdd(aLayCG5, { "N", 9, 0,125} )     // CAIXA POSTAL
aAdd(aLayCG5, { "C", 1, 0,134} )     // IDENTIFICAÇÃO DO SEXO
aAdd(aLayCG5, { "C", 1, 0,135} )     // INDICADOR DE PESSOA
aAdd(aLayCG5, { "C",20, 0,136} )     // CPF / CNPJ
aAdd(aLayCG5, { "N", 4, 0,156} )     // CÓDIGO DDDD TELEFONE CELULAR
aAdd(aLayCG5, { "N", 9, 0,160} )     // NÚMERO DO TELEFONE CELULAR
aAdd(aLayCG5, { "C",25, 0,169} )     // BRANCOS

// CG7 - SOLICITAÇÃO DE GARANTIA - COMPLEMENTO DE INFORMAÇÕES

aAdd(aLayCG7, { "C",  3, 0,  1} )     // TIPO DE REGISTRO (CG7)
aAdd(aLayCG7, { "N",  6, 0,  4} )     // NÚMERO DO DEALER EXECUTANTE
aAdd(aLayCG7, { "N",  5, 0, 10} )     // NÚMERO DA ORDEM DE SERVIÇO
aAdd(aLayCG7, { "C",  1, 0, 15} )     // SEQUÊNCIA
aAdd(aLayCG7, { "C",  1, 0, 16} )     // RECONSIDERAÇÃO
aAdd(aLayCG7, { "N",  2, 0, 17} )     // LINHA (de 01 a 99)
aAdd(aLayCG7, { "C",175, 0, 19} )     // OBSERVAÇÃO


// Monta CHI
aValCHI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCHI,{"CHI",1, 0,0,0,nData,"0"+Alltrim(strzero(MV_PAR02,4)),51,STR0010," " } )
cLinhaCHI := MontaEDI(aLayCHI,aValCHI[1])
fwrite(nHnd,cLinhaCHI)


// Monta CGI
aValCGI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCGI,{"CGI",1, 0,0,0,nData,"0"+Alltrim(strzero(MV_PAR02,4)),51,STR0010," " } )
cLinhaCGI := MontaEDI(aLayCGI,aValCGI[1])
fwrite(nHnd,cLinhaCGI)


Begin Transaction

dbselectArea("VGA")
dbSeek(xFilial("VGA"))
&&dbgotop()

ProcRegua( reccount() )

while !eof() .And. VGA->VGA_FILIAL == xFilial("VGA")
	
	IncProc( OemtoAnsi(STR0006) )
	If lAbortPrint
		If MsgYesNo(OemToAnsi(STR0008),OemToAnsi(STR0009)) //Tem certeza que deseja abortar esta operacao? # Atencao
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .f.
		EndIf
	EndIf
	
	If !IsMark("VGA_OK",ThisMark(),ThisInv()) && Se Nao Marcado
		dbskip()
		Loop
	EndIf
	
	If VGA->VGA_TRANSM == "S"
		dbskip()
		loop
	endif
	
	if (VGA->VGA_CODGAR = space(5) .AND. VGA->VGA_CODREV = space(2))
		IncProc(OemtoAnsi(STR0006))
		dbskip()
		loop
	endif
	
	If !RecLock("VGA",.f.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	VGA->VGA_EXPGAR := "S"
	MsUnlock()
	
	If empty(VGA->VGA_NUMOSV)
		
		dbselectarea("SF2")  //SAIDA
		dbgotop()
		dbsetorder(1)
		lAchou := dbseek(xFilial("SF2")+VGA->VGA_NUMNFI+VGA->VGA_SERIEN)          //NOTAS SAIDAS
		
		cCGCCPF := ""
		cNOMCLI := ""
		cENDCLI := ""
		cCIDCLI := ""
		cESTCLI := ""
		cENDPOS := ""
		cDDDFON := ""
		cTELEFO := ""
		cNumero := ""
		cEmaCli := ""
		cNumCli := ""
		cComCli := ""
		cBaiCli := ""
		cSexCli := ""
		cPesCli := ""
		cCPFCli := ""
		cDDDCel := ""
		cNumCel := ""
		
		if lAchou = .t.
			
			FG_SEEK("SA1","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //CLIENTE
			cCGCCPF := SA1->A1_CGC
			cNOMCLI := SA1->A1_NOME
			cENDCLI := SA1->A1_END
			cCIDCLI := SA1->A1_MUN
			cESTCLI := SA1->A1_EST
			cENDPOS := SA1->A1_CEP
			cNumero := strzero(val(VGA->VGA_NUMNFI),8)
			cDDDFON := alltrim(SA1->A1_DDD)
			cTELEFO := alltrim(SA1->A1_TEL)
			
			c_tel     := ""
			if AT("-",SA1->A1_TEL) # 0
				c_Tel := Left(STUFF(SA1->A1_TEL,AT("-",SA1->A1_TEL),1,""),8)
			elseif AT(".",SA1->A1_TEL) # 0
				c_Tel := Left(STUFF(SA1->A1_TEL,AT(".",SA1->A1_TEL),1,""),8)
			elseif AT(" ",left(SA1->A1_TEL,9)) # 0
				ntotfor := len(Alltrim(SA1->A1_TEL))
				cA1Tel  := Alltrim(SA1->A1_TEL)
				c_Tel   := cA1Tel
				for i = 1 to ntotfor
					if AT(" ",left(cA1Tel,9)) # 0
						c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
						cA1Tel := c_Tel
					Endif
				Next
			else
				c_Tel := SA1->A1_TEL
			endif
			
			cTELEFO := left(c_tel,8)
			
			If SA1->(FieldPos("A1_EMAIL")) > 0
				cEmaCli := SA1->A1_EMAIL
			EndIf
			If SA1->(FieldPos("A1_NUMERO")) > 0
				cNumCli := SA1->A1_NUMERO    //FNC 4821/2010 - boby
			EndIf
			If SA1->(FieldPos("A1_BAIRRO")) > 0
				cBaiCli := SA1->A1_BAIRRO
			EndIf
			If SA1->(FieldPos("A1_SEXO")) > 0
				cSexCli := SA1->A1_SEXO
			EndIf
			
			cPesCli := RETPESSOA(SA1->A1_CGC)
			cCPFCli := SA1->A1_CGC
			
			If SA1->(FieldPos("A1_CELULAR")) > 0
				
				cDDDCel := alltrim(SA1->A1_DDD)
				cNumCel := alltrim(SA1->A1_CELULAR)
				c_Tel := ""
				
				if AT("-",SA1->A1_CELULAR) # 0
					c_Tel := Left(STUFF(SA1->A1_CELULAR,AT("-",SA1->A1_CELULAR),1,""),8)
				elseif AT(".",SA1->A1_CELULAR) # 0
					c_Tel := Left(STUFF(SA1->A1_CELULAR,AT(".",SA1->A1_CELULAR),1,""),8)
				elseif AT(" ",left(SA1->A1_CELULAR,9)) # 0
					ntotfor := len(Alltrim(SA1->A1_CELULAR))
					cA1Tel  := Alltrim(SA1->A1_CELULAR)
					c_Tel   := cA1Tel
					for i = 1 to ntotfor
						if AT(" ",left(cA1Tel,9)) # 0
							c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
							cA1Tel := c_Tel
						Endif
					Next
				else
					c_Tel := SA1->A1_CELULAR
				endif
				
				cNumCel := left(c_tel,8)
				
			EndIf
			
		else
			
			dbselectarea("SF1")  //ENTRADA
			dbgotop()
			dbsetorder(1)
			lAchou := dbseek(xFilial("SF1")+VGA->VGA_NUMNFI+VGA->VGA_SERIEN)          //NOTAS ENTRADA
			
			FG_SEEK("SA2","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //FORNECEDOR
			cCGCCPF := SA2->A2_CGC
			cNOMCLI := SA2->A2_NOME
			cENDCLI := SA2->A2_END
			cCIDCLI := SA2->A2_MUN
			cESTCLI := SA2->A2_EST
			cENDPOS := SA2->A2_CEP
			cDDDFON := alltrim(SA2->A2_DDD)
			cTELEFO := alltrim(SA2->A2_TEL)
			cNumero := strzero(val(VGA->VGA_NUMNFI),8)
			
		endif
		
	else
		
		FG_SEEK("SA1","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //CLIENTE
		cCGCCPF := SA1->A1_CGC
		cNOMCLI := SA1->A1_NOME
		cENDCLI := SA1->A1_END
		cCIDCLI := SA1->A1_MUN
		cESTCLI := SA1->A1_EST
		cENDPOS := SA1->A1_CEP
		cNumero := VGA->VGA_NUMOSV
		cComCli := ""
		cBaiCli := SA1->A1_BAIRRO
		cPesCli := RETPESSOA(SA1->A1_CGC)
		cCPFCli := SA1->A1_CGC
		cDDDFON := alltrim(SA1->A1_DDD)
		cTELEFO := alltrim(SA1->A1_TEL)
		
		c_tel     := ""
		if AT("-",SA1->A1_TEL) # 0
			c_Tel := Left(STUFF(SA1->A1_TEL,AT("-",SA1->A1_TEL),1,""),8)
		elseif AT(".",SA1->A1_TEL) # 0
			c_Tel := Left(STUFF(SA1->A1_TEL,AT(".",SA1->A1_TEL),1,""),8)
		elseif AT(" ",left(SA1->A1_TEL,9)) # 0
			ntotfor := len(Alltrim(SA1->A1_TEL))
			cA1Tel  := Alltrim(SA1->A1_TEL)
			c_Tel   := cA1Tel
			for i = 1 to ntotfor
				if AT(" ",left(cA1Tel,9)) # 0
					c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
					cA1Tel := c_Tel
				Endif
			Next
		else
			c_Tel := SA1->A1_TEL
		endif
		
		cTELEFO := left(c_tel,8)
		
		
		If SA1->(FieldPos("A1_EMAIL")) > 0
			cEmaCli := SA1->A1_EMAIL
		EndIf
		If SA1->(FieldPos("A1_NUMERO")) > 0
			cNumCli := SA1->A1_NUMERO    //FNC 4821/2010 - boby
		EndIf
		If SA1->(FieldPos("A1_SEXO")) > 0
			cSexCli := SA1->A1_SEXO
		EndIf
		
		If SA1->(FieldPos("A1_CELULAR")) > 0
			
			cDDDCel := alltrim(SA1->A1_DDD)
			cNumCel := alltrim(SA1->A1_CELULAR)
			c_Tel := ""
			
			if AT("-",SA1->A1_CELULAR) # 0
				c_Tel := Left(STUFF(SA1->A1_CELULAR,AT("-",SA1->A1_CELULAR),1,""),8)
			elseif AT(".",SA1->A1_CELULAR) # 0
				c_Tel := Left(STUFF(SA1->A1_CELULAR,AT(".",SA1->A1_CELULAR),1,""),8)
			elseif AT(" ",left(SA1->A1_CELULAR,9)) # 0
				ntotfor := len(Alltrim(SA1->A1_CELULAR))
				cA1Tel  := Alltrim(SA1->A1_CELULAR)
				c_Tel   := cA1Tel
				for i = 1 to ntotfor
					if AT(" ",left(cA1Tel,9)) # 0
						c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
						cA1Tel := c_Tel
					Endif
				Next
			else
				c_Tel := SA1->A1_CELULAR
			endif
			
			cNumCel := left(c_tel,8)
			
		EndIf
		
		FG_SEEK("VV1","VGA->VGA_CHAINT",1,.f.)  //VEICULO
		FG_SEEK("VO5","VGA->VGA_CHAINT",1,.f.)  //VEICULO
		FG_SEEK("VV0","VV1->VV1_NUMTRA",1,.f.)
		
	endif
	
	FG_SEEK("VV1","VGA->VGA_CHAINT",1,.f.)  //VEICULO
	FG_SEEK("VV0","VV1->VV1_NUMTRA",1,.f.)
	
	dbselectArea("VE4")                     //FABRICANTE
	dbgotop()
	dbsetorder(1)
	dbseek(xFilial("VE4")+VV1->VV1_CODMAR)   //
	
	cRecons := " "
	
	if VGA->VGA_RECONS = "1"
		cRecons := space(1)
	elseif VGA->VGA_RECONS = "2"
		cRecons := "R"
	elseif VGA->VGA_RECONS = "3"
		cRecons := "C"
	endif
	
	dbselectArea("VI6")
	dbgotop()
	dbsetorder(1)
	If dbseek(xFilial("VI6")+VGA->VGA_CODMAR+cNumero)
		
		dbselectArea("VIC")
		dbsetorder(1)
		dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNumero)
		Do While !Eof() .And. VIC->VIC_FILIAL+VIC->VIC_CODMAR+VIC->VIC_NUMOSV == xFilial("VIC")+VGA->VGA_CODMAR+cNumero
			
			RecLock("VIC",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VIC")
			
			DbSkip()
			
		EndDo
		
	EndIf
	
	dbselectArea("VI6")
	
	
	cNfiFec := ""
	
	if !empty(VGA->VGA_NFIFEC)
		cNfiFec := VGA->VGA_NFIFEC
	elseif !empty(VGA->VGA_NUMNFI)
		CnFiFec := VGA->VGA_NUMNFI
	endif
	
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+VGA->VGA_CHAINT)
	
	nAno := Year(VV1->VV1_DATVEN)
	nMes := Month(VV1->VV1_DATVEN)
	dDtVda := Alltrim(strzero(nMes,2))+Alltrim(strzero(nAno,4))
	
	nAno := Year(VGA->VGA_ABEGAR)
	nMes := Month(VGA->VGA_ABEGAR)
	nDia := Day(VGA->VGA_ABEGAR)
	dDtRep := Alltrim(strzero(nDia,2))+Alltrim(strzero(nMes,2))+Alltrim(strzero(nAno,4))
	
	aAdd(aValCG1,{"CG1",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,VGA->VGA_SEGMOD,VV1->VV1_CHASSI,dDtVda,dDtRep,VGA->VGA_KILGAR,VGA->VGA_ESPGAR,VGA->VGA_NFIFEC,VGA->VGA_AUTFAB,VGA->VGA_RESER1,VGA->VGA_RESER2,VGA->VGA_RESER3,VGA->VGA_RESER4,VGA->VGA_VALPEC,VGA->VGA_TEMPAD/100,"",""} )
	aAdd(aLinhasRel,"CG1"+" "+VV1->VV1_CHASSI+" "+transform(VGA->VGA_DTAVDA,"@D") +" "+transform(VGA->VGA_VALPEC,"@E 999,999,999.99"))
	
	dBSelectArea("VG5")
	dBGotop()
	
	If !Empty(VGA->VGA_NUMOSV)
		cNumero := VGA->VGA_NUMOSV
		dBSetOrder(1)
	Else
		cNumero := VGA->VGA_NUMNFI
		dbsetorder(2)
	EndIf
	
	dBSeek(xFilial("VG5")+VGA->VGA_CODMAR+cNumero)
	nLinha := 1
	nAchou := 1
	nAch := 1
	nCont := 1
	nLinhaCG2 := 1
	nLinhaCG3 := 1
	Do While !Eof() .and. VGA->VGA_CODMAR+cNumero == VG5->VG5_CODMAR + if(!empty(VG5->VG5_NUMOSV),VG5->VG5_NUMOSV,VGA->VGA_NUMNFI) .And. VGA->VGA_FILIAL == xFilial("VGA")
		
		If VG5->VG5_TRANSM == "S"
			dbskip()
			loop
		EndIf
		
		If !Empty(VGA->VGA_NUMOSV)
			cNum := VGA->VGA_NUMOSV
		Else
			cNum := strzero(val(VGA->VGA_NUMNFI),8)
		EndIf
		
		dbselectArea("VIC")
		If !empty( VG5->VG5_CODITE )
			dbgotop()
			dbsetorder(4)
			dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNum+space(11)+VG5->VG5_ORDITE+if(VG5->VG5_ITEEXT=="1","S","N")+VG5->VG5_CODITE)
		Else
			dbgotop()
			dbsetorder(5)
			dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNum+space(11)+VG5->VG5_ORDITE+if(VG5->VG5_SEREXT=="1","S","N")+VG5->VG5_CODSER)
		endif
		
		If !RecLock("VIC", !Found() )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VIC->VIC_FILIAL := VG5->VG5_FILIAL
		
		&& Grava campos relacionado do arquivos VGA/VI6
		For nCpo:=1 to VIC->(FCount())
			
			nFoundCpo := VG5->(FieldPos( "VG5"+Substr(VIC->(FieldName(nCpo)),4) ))
			
			If nFoundCpo # 0 .And. ( Valtype(VIC->(FieldGet(nCpo))) == Valtype(VG5->(FieldGet(nFoundCpo))) )
				
				&( "VIC->"+VIC->(FieldName(nCpo)) ) := VG5->(FieldGet(nFoundCpo))
				
			EndIf
			
		Next
		// Itens normais
		if VG5->VG5_SEREXT == "0" .or. VG5->VG5_ITEEXT == "0"
			nPos := aScan(aValCG2,{|x| x[1]+x[3]+x[10] == "CG2"+cNumero+VG5->VG5_CODITE })
			if nPos ==0
				nAchou := 1
			Endif
			if nAchou == 1 .or. nAchou == 5
				aAdd(aValCG2,{"CG2",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,Alltrim(str(nLinhaCG2)),VG5->VG5_CODDEF,VG5->VG5_CODFOR,VG5->VG5_QTDITE,VG5->VG5_CODITE,VG5->VG5_CODSER,0,"","",0,"","",0,"","",0,"","",0,"","",0,"","",""} )
				nLinhaCG2 += 1
				nAchou := 2
			Elseif nAchou == 2
				aValCG2[len(aValCG2),12] := Alltrim(str(nLinhaCG2))
				aValCG2[len(aValCG2),13] := VG5->VG5_CODDEF
				aValCG2[len(aValCG2),14] := VG5->VG5_CODFOR
				aValCG2[len(aValCG2),15] := VG5->VG5_QTDITE
				aValCG2[len(aValCG2),16] := VG5->VG5_CODITE
				aValCG2[len(aValCG2),17] := VG5->VG5_CODSER
				nLinhaCG2 += 1
				nAchou := 3
			Elseif nAchou == 3
				aValCG2[len(aValCG2),18] := Alltrim(str(nLinhaCG2))
				aValCG2[len(aValCG2),19] := VG5->VG5_CODDEF
				aValCG2[len(aValCG2),20] := VG5->VG5_CODFOR
				aValCG2[len(aValCG2),21] := VG5->VG5_QTDITE
				aValCG2[len(aValCG2),22] := VG5->VG5_CODITE
				aValCG2[len(aValCG2),23] := VG5->VG5_CODSER
				nLinhaCG2 += 1
				nAchou := 4
			Else
				aValCG2[len(aValCG2),24] := Alltrim(str(nLinhaCG2))
				aValCG2[len(aValCG2),25] := VG5->VG5_CODDEF
				aValCG2[len(aValCG2),26] := VG5->VG5_CODFOR
				aValCG2[len(aValCG2),27] := VG5->VG5_QTDITE
				aValCG2[len(aValCG2),28] := VG5->VG5_CODITE
				aValCG2[len(aValCG2),29] := VG5->VG5_CODSER
				nLinhaCG2 += 1
				nAchou := 5
			Endif
		Else // Itens adicionais
			nPos := aScan(aValCG3,{|x| x[1]+x[3] == "CG3"+cNumero })
			if nPos ==0
				nAchou := 1
			Endif
			if nAch == 1 .or. nAch == 5
				aAdd(aValCG3,{"CG3",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,Alltrim(str(nLinhaCG3)),VG5->VG5_CODDEF,VG5->VG5_CODFOR,VG5->VG5_VALPEC,VG5->VG5_TEMPAD/100,VG5->VG5_DESITE,0,"","",0,0,"",0,"","",0,0,"",""} )
				nLinhaCG3 += 1
				nAch := 2
			Elseif nAch == 2
				aValCG3[len(aValCG3),12] := Alltrim(str(nLinhaCG3))
				aValCG3[len(aValCG3),13] := VG5->VG5_CODDEF
				aValCG3[len(aValCG3),14] := VG5->VG5_CODFOR
				aValCG3[len(aValCG3),15] := VG5->VG5_VALPEC
				aValCG3[len(aValCG3),16] := VG5->VG5_TEMPAD/100
				aValCG3[len(aValCG3),17] := VG5->VG5_DESITE
				nLinhaCG3 += 1
				nAch := 3
			Elseif nAch == 3
				aValCG3[len(aValCG3),18] := Alltrim(str(nLinhaCG3))
				aValCG3[len(aValCG3),19] := VG5->VG5_CODDEF
				aValCG3[len(aValCG3),20] := VG5->VG5_CODFOR
				aValCG3[len(aValCG3),21] := VG5->VG5_VALPEC
				aValCG3[len(aValCG3),22] := VG5->VG5_TEMPAD/100
				aValCG3[len(aValCG3),23] := VG5->VG5_DESITE
				nLinhaCG3 += 1
				nAch := 4
			Endif
		Endif
		
		if !Empty(VG5->VG5_OBSERV)
			aAdd(aValCG7,{"CG7",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,nCont,VG5->VG5_OBSERV} )
			nCont += 1
		Elseif !Empty(VG5->VG5_CODITE+ VG5->VG5_CODSER)
			aAdd(aValCG7,{"CG7",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,nCont,VG5->VG5_CODITE+ VG5->VG5_CODSER} )
			nCont += 1
		Endif
		
		nLinha += 1
		dbSelectArea("VG5")
		dbskip()
		
	enddo
	
	// CG4 - SOLICITAÇÃO DE GARANTIA - IDENTIFICAÇÃO DO CLIENTE
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+VGA->VGA_CODCLI+VGA->VGA_LOJA)
	aAdd(aValCG4,{"CG4",MV_PAR02,cNumero,"",cRecons,substr(SA1->A1_NOME,1,30),substr(SA1->A1_END,1,30),substr(SA1->A1_MUN,1,20),SA1->A1_EST,SA1->A1_CEP,SA1->A1_DDD,substr(SA1->A1_TEL,1,8),""} )
	
	aAdd(aValCG5,{"CG5",Alltrim(strzero(MV_PAR02,4)),cNumero,"",cRecons,"01",substr(SA1->A1_EMAIL,1,50),"",substr(SA1->A1_COMPLEM,1,20),substr(SA1->A1_BAIRRO,1,30),"","",SA1->A1_PESSOA,Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99999999/9999-99","@R 999999999-99")),"","",""} )
	
	IncProc(OemtoAnsi(STR0006))
	
	dbselectArea("VGA")
	
	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VGA->VGA_TRANSM := "S"
	VGA->VGA_DATTRA := dDataBase
	MsUnlock()
	
	dbskip()
	
enddo

End Transaction


nLinhArq := 0
For i:= 1 to Len(aValCG1)
	cLinhaCG1 := MontaEDI(aLayCG1,aValCG1[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG1)
Next
For i:= 1 to Len(aValCG2)
	cLinhaCG2 := MontaEDI(aLayCG2,aValCG2[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG2)
Next
For i:= 1 to Len(aValCG3)
	cLinhaCG3 := MontaEDI(aLayCG3,aValCG3[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG3)
Next
For i:= 1 to Len(aValCG4)
	cLinhaCG4 := MontaEDI(aLayCG4,aValCG4[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG4)
Next
For i:= 1 to Len(aValCG5)
	cLinhaCG5 := MontaEDI(aLayCG5,aValCG5[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG5)
Next
For i:= 1 to Len(aValCG7)
	cLinhaCG7 := MontaEDI(aLayCG7,aValCG7[i])
	nLinhArq += 1
	fwrite(nHnd,cLinhaCG7)
Next


// Monta CGF
aValCGF := {}
aAdd(aValCGF,{"CGF",1, 0,nLinhArq+2," " } )
cLinhaCGF := MontaEDI(aLayCGF,aValCGF[1])
fwrite(nHnd,cLinhaCGF)


// Monta CHF
aValCHF := {}
aAdd(aValCHF,{"CHF",1, 0,nLinhArq+2," " } )
cLinhaCHF := MontaEDI(aLayCHF,aValCHF[1])
fwrite(nHnd,cLinhaCHF)

If !lRet
	MostraErro()
EndIf
fClose(nHnd)
MsgInfo(STR0011,STR0009)
//RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0003, STR0005, .T. )

return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_EXPVGA ³ Autor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava dados no VI6/VIC dos arquivos VGA/VG5                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_EXPVGA()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXPVGA()

Local lAchou := .t. , cCGCCPF , cNOMCLI , cENDCLI , cCIDCLI , cESTCLI , cENDPOS , cDDDFON , cNumero
Local cEmaCli, cNumCli, cComCli, cBaiCli, cSexCli, cPesCli, cCPFCli, cDDDCel, cNumCel
Local cRecons , cNfiFec , lRet := .t. , nCpo:=0 , nFoundCpo:=0, i
Private lMsHelpAuto := .t.


Begin Transaction

dbselectArea("VGA")
dbSeek(xFilial("VGA"))
&&dbgotop()

ProcRegua( reccount() )

while !eof() .And. VGA->VGA_FILIAL == xFilial("VGA")
	
	IncProc( OemtoAnsi(STR0006) )
	If lAbortPrint
		If MsgYesNo(OemToAnsi(STR0008),OemToAnsi(STR0009)) //Tem certeza que deseja abortar esta operacao? # Atencao
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .f.
		EndIf
	EndIf
	
	If !IsMark("VGA_OK",ThisMark(),ThisInv()) && Se Nao Marcado
		dbskip()
		Loop
	EndIf
	
	If VGA->VGA_TRANSM == "S"
		dbskip()
		loop
	endif
	
	if (VGA->VGA_CODGAR = space(5) .AND. VGA->VGA_CODREV = space(2))
		IncProc(OemtoAnsi(STR0006))
		dbskip()
		loop
	endif
	
	If !RecLock("VGA",.f.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	VGA->VGA_EXPGAR := "S"
	MsUnlock()
	
	If empty(VGA->VGA_NUMOSV)
		
		dbselectarea("SF2")  //SAIDA
		dbgotop()
		dbsetorder(1)
		lAchou := dbseek(xFilial("SF2")+VGA->VGA_NUMNFI+VGA->VGA_SERIEN)          //NOTAS SAIDAS
		
		cCGCCPF := ""
		cNOMCLI := ""
		cENDCLI := ""
		cCIDCLI := ""
		cESTCLI := ""
		cENDPOS := ""
		cDDDFON := ""
		cNumero := ""
		cEmaCli := ""
		cNumCli := ""
		cComCli := ""
		cBaiCli := ""
		cSexCli := ""
		cPesCli := ""
		cCPFCli := ""
		cDDDCel := ""
		cNumCel := ""
		
		if lAchou = .t.
			
			FG_SEEK("SA1","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //CLIENTE
			cCGCCPF := SA1->A1_CGC
			cNOMCLI := SA1->A1_NOME
			cENDCLI := SA1->A1_END
			cCIDCLI := SA1->A1_MUN
			cESTCLI := SA1->A1_EST
			cENDPOS := SA1->A1_CEP
			cDDDFON := SA1->A1_TEL
			cNumero := strzero(val(VGA->VGA_NUMNFI),8)
			
			c_tel     := ""
			if AT("-",SA1->A1_TEL) # 0
				c_Tel := Left(STUFF(SA1->A1_TEL,AT("-",SA1->A1_TEL),1,""),8)
			elseif AT(".",SA1->A1_TEL) # 0
				c_Tel := Left(STUFF(SA1->A1_TEL,AT(".",SA1->A1_TEL),1,""),8)
			elseif AT(" ",left(SA1->A1_TEL,9)) # 0
				ntotfor := len(Alltrim(SA1->A1_TEL))
				cA1Tel  := Alltrim(SA1->A1_TEL)
				c_Tel   := cA1Tel
				for i = 1 to ntotfor
					if AT(" ",left(cA1Tel,9)) # 0
						c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
						cA1Tel := c_Tel
					Endif
				Next
			else
				c_Tel := SA1->A1_TEL
			endif
			
			cTELEFO := left(c_tel,8)
			
			If SA1->(FieldPos("A1_EMAIL")) > 0
				cEmaCli := SA1->A1_EMAIL
			EndIf
			If SA1->(FieldPos("A1_NUMERO")) > 0
				cNumCli := SA1->A1_NUMERO    //FNC 4821/2010 - boby
			EndIf
			If SA1->(FieldPos("A1_BAIRRO")) > 0
				cBaiCli := SA1->A1_BAIRRO
			EndIf
			If SA1->(FieldPos("A1_SEXO")) > 0
				cSexCli := SA1->A1_SEXO
			EndIf
			
			cPesCli := RETPESSOA(SA1->A1_CGC)
			cCPFCli := SA1->A1_CGC
			
			If SA1->(FieldPos("A1_CELULAR")) > 0
				
				cDDDCel := alltrim(SA1->A1_DDD)
				cNumCel := alltrim(SA1->A1_CELULAR)
				c_Tel := ""
				
				if AT("-",SA1->A1_CELULAR) # 0
					c_Tel := Left(STUFF(SA1->A1_CELULAR,AT("-",SA1->A1_CELULAR),1,""),8)
				elseif AT(".",SA1->A1_CELULAR) # 0
					c_Tel := Left(STUFF(SA1->A1_CELULAR,AT(".",SA1->A1_CELULAR),1,""),8)
				elseif AT(" ",left(SA1->A1_CELULAR,9)) # 0
					ntotfor := len(Alltrim(SA1->A1_CELULAR))
					cA1Tel  := Alltrim(SA1->A1_CELULAR)
					c_Tel   := cA1Tel
					for i = 1 to ntotfor
						if AT(" ",left(cA1Tel,9)) # 0
							c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
							cA1Tel := c_Tel
						Endif
					Next
				else
					c_Tel := SA1->A1_CELULAR
				endif
				
				cNumCel := left(c_tel,8)
				
				//				cDDDCel := Left(SA1->A1_CELULAR,4)
				//				cNumCel := Subs(SA1->A1_CELULAR,5,9)
			EndIf
			
		else
			
			dbselectarea("SF1")  //ENTRADA
			dbgotop()
			dbsetorder(1)
			lAchou := dbseek(xFilial("SF1")+VGA->VGA_NUMNFI+VGA->VGA_SERIEN)          //NOTAS ENTRADA
			
			FG_SEEK("SA2","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //FORNECEDOR
			cCGCCPF := SA2->A2_CGC
			cNOMCLI := SA2->A2_NOME
			cENDCLI := SA2->A2_END
			cCIDCLI := SA2->A2_MUN
			cESTCLI := SA2->A2_EST
			cENDPOS := SA2->A2_CEP
			cDDDFON := SA2->A2_TEL
			cNumero := strzero(val(VGA->VGA_NUMNFI),8)
			/*
			cEmaCli := SA1->A1_EMAIL
			cNumCli := SA1->A1_NUMERO
			cComCli := ""
			cBaiCli := SA1->A1_BAIRRO
			cSexCli := SA1->A1_SEXO
			cPesCli := SA1->A1_PESSOA
			cCPFCli := SA1->A1_CGC
			cDDDCel := Left(SA1->A1_CELULAR,4)
			cNumCel := Subs(SA1->A1_CELULAR,5,9)
			*/
			
		endif
		
	else
		
		FG_SEEK("SA1","VGA->VGA_CODCLI+VGA->VGA_LOJA",1,.F.)  //CLIENTE
		cCGCCPF := SA1->A1_CGC
		cNOMCLI := SA1->A1_NOME
		cENDCLI := SA1->A1_END
		cCIDCLI := SA1->A1_MUN
		cESTCLI := SA1->A1_EST
		cENDPOS := SA1->A1_CEP
		cNumero := VGA->VGA_NUMOSV
		cComCli := ""
		cBaiCli := SA1->A1_BAIRRO
		cPesCli := RETPESSOA(SA1->A1_CGC)
		cCPFCli := SA1->A1_CGC
		cDDDFON := alltrim(SA1->A1_DDD)
		cTELEFO := alltrim(SA1->A1_TEL)
		
		c_tel     := ""
		if AT("-",SA1->A1_TEL) # 0
			c_Tel := Left(STUFF(SA1->A1_TEL,AT("-",SA1->A1_TEL),1,""),8)
		elseif AT(".",SA1->A1_TEL) # 0
			c_Tel := Left(STUFF(SA1->A1_TEL,AT(".",SA1->A1_TEL),1,""),8)
		elseif AT(" ",left(SA1->A1_TEL,9)) # 0
			ntotfor := len(Alltrim(SA1->A1_TEL))
			cA1Tel  := Alltrim(SA1->A1_TEL)
			c_Tel   := cA1Tel
			for i = 1 to ntotfor
				if AT(" ",left(cA1Tel,9)) # 0
					c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
					cA1Tel := c_Tel
				Endif
			Next
		else
			c_Tel := SA1->A1_TEL
		endif
		
		cTELEFO := left(c_tel,8)
		
		If SA1->(FieldPos("A1_EMAIL")) > 0
			cEmaCli := SA1->A1_EMAIL
		EndIf
		If SA1->(FieldPos("A1_NUMERO")) > 0
			cNumCli := SA1->A1_NUMERO    //FNC 4821/2010 - boby
		EndIf
		If SA1->(FieldPos("A1_SEXO")) > 0
			cSexCli := SA1->A1_SEXO
		EndIf
		
		If SA1->(FieldPos("A1_CELULAR")) > 0
			
			cDDDCel := alltrim(SA1->A1_DDD)
			cNumCel := alltrim(SA1->A1_CELULAR)
			c_Tel := ""
			
			if AT("-",SA1->A1_CELULAR) # 0
				c_Tel := Left(STUFF(SA1->A1_CELULAR,AT("-",SA1->A1_CELULAR),1,""),8)
			elseif AT(".",SA1->A1_CELULAR) # 0
				c_Tel := Left(STUFF(SA1->A1_CELULAR,AT(".",SA1->A1_CELULAR),1,""),8)
			elseif AT(" ",left(SA1->A1_CELULAR,9)) # 0
				ntotfor := len(Alltrim(SA1->A1_CELULAR))
				cA1Tel  := Alltrim(SA1->A1_CELULAR)
				c_Tel   := cA1Tel
				for i = 1 to ntotfor
					if AT(" ",left(cA1Tel,9)) # 0
						c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
						cA1Tel := c_Tel
					Endif
				Next
			else
				c_Tel := SA1->A1_CELULAR
			endif
			
			cNumCel := left(c_tel,8)
			
			//			cDDDCel := SA1->A1_DDD  //Left(SA1->A1_CELULAR,4)
			//			cNumCel := Subs(SA1->A1_CELULAR,5,9)
		EndIf
		
		FG_SEEK("VV1","VGA->VGA_CHAINT",1,.f.)  //VEICULO
		FG_SEEK("VO5","VGA->VGA_CHAINT",1,.f.)  //VEICULO
		FG_SEEK("VV0","VV1->VV1_NUMTRA",1,.f.)
		
	endif
	
	FG_SEEK("VV1","VGA->VGA_CHAINT",1,.f.)  //VEICULO
	FG_SEEK("VV0","VV1->VV1_NUMTRA",1,.f.)
	
	dbselectArea("VE4")                     //FABRICANTE
	dbgotop()
	dbsetorder(1)
	dbseek(xFilial("VE4")+VV1->VV1_CODMAR)   //
	
	cRecons := " "
	
	if VGA->VGA_RECONS = "1"
		cRecons := space(1)
	elseif VGA->VGA_RECONS = "2"
		cRecons := "R"
	elseif VGA->VGA_RECONS = "3"
		cRecons := "C"
	endif
	
	dbselectArea("VI6")
	dbgotop()
	dbsetorder(1)
	If dbseek(xFilial("VI6")+VGA->VGA_CODMAR+cNumero)
		
		dbselectArea("VIC")
		dbsetorder(1)
		dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNumero)
		Do While !Eof() .And. VIC->VIC_FILIAL+VIC->VIC_CODMAR+VIC->VIC_NUMOSV == xFilial("VIC")+VGA->VGA_CODMAR+cNumero
			
			RecLock("VIC",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VIC")
			
			DbSkip()
			
		EndDo
		
	EndIf
	
	dbselectArea("VI6")
	If !RecLock("VI6", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	cNfiFec := ""
	
	if !empty(VGA->VGA_NFIFEC)
		cNfiFec := VGA->VGA_NFIFEC
	elseif !empty(VGA->VGA_NUMNFI)
		CnFiFec := VGA->VGA_NUMNFI
	endif
	
	VI6->VI6_FILIAL := xFilial("VI6")
	
	&& Grava campos relacionado do arquivos VGA/VI6
	For nCpo:=1 to VI6->(FCount())
		
		nFoundCpo := VGA->(FieldPos( "VGA"+Substr(VI6->(FieldName(nCpo)),4) ))
		
		If nFoundCpo # 0 .And. ( Valtype(VI6->(FieldGet(nCpo))) == Valtype(VGA->(FieldGet(nFoundCpo))) )
			
			&( "VI6->"+VI6->(FieldName(nCpo)) ) := VGA->(FieldGet(nFoundCpo))
			
		EndIf
		
	Next
	
	&& Grava campo internos
	VI6->VI6_CODMAR := VGA->VGA_CODMAR
	VI6->VI6_TIPREG := "GAR"
	///////// Alteracao necessaria devido a garantia so transmitir OS c/ 5 digitos //////////////
	////////  Passaremos a mandar VGA->CONTRA com o nro da OS //////////////////////////////////
	////////  Renata - 22/04/08 ////////////////////////////////////////////////////////////////
	
	if SM0->M0_CODIGO = "05"
		VI6->VI6_NUMOSV := strzero(val(VGA->VGA_CONTRA),8)
	else
		VI6->VI6_NUMOSV := cNumero
	endif
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	VI6->VI6_CODCON := VE4->VE4_CODCON
	VI6->VI6_TIPGAR := VGA->VGA_ESPGAR
	VI6->VI6_CODGAR := VGA->VGA_CODGAR
	VI6->VI6_DTAFIM := VGA->VGA_DATFEC
	VI6->VI6_KILATU := VGA->VGA_KILGAR
	VI6->VI6_DTAGAR := VGA->VGA_ABEGAR
	VI6->VI6_RECONS := cRecons
	VI6->VI6_CGCCPF := cCGCCPF
	VI6->VI6_NOMCLI := left(cNOMCLI,35)
	VI6->VI6_ENDCLI := left(cENDCLI,30)
	VI6->VI6_CIDCLI := cCIDCLI
	VI6->VI6_ESTCLI := cESTCLI
	VI6->VI6_ENDPOS := cENDPOS
	VI6->VI6_DDDFON := cDDDFON  //left(cDDDFON,12)
	VI6->VI6_NROAUT := val(VGA->VGA_AUTFAB)
	VI6->VI6_CODTMA := VGA->VGA_SEGMOD
	VI6->VI6_NFIFEC := cNfiFec    //if(!empty(VGA->VGA_NFIPEC),VGA->VGA_NFIPEC,VGA->VGA_NFISER)
	VI6->VI6_RESER1 := VGA->VGA_RESER1
	VI6->VI6_RESER2 := VGA->VGA_RESER2
	VI6->VI6_RESER3 := VGA->VGA_RESER3
	VI6->VI6_RESER4 := VGA->VGA_RESER4
	VI6->VI6_VLTPEC := VGA->VGA_VALPEC
	VI6->VI6_VLTTPO := VGA->VGA_TEMPAD
	VI6->VI6_DNEXEC := VE4->VE4_CODCON
	VI6->VI6_DTAVDA := VGA->VGA_DTAVDA
	VI6->VI6_CODREV := val(VGA->VGA_CODREV)
	VI6->VI6_GRUREV := val(VGA->VGA_GRUREV)
	VI6->VI6_CHASSI := VV1->VV1_CHASSI
	VI6->VI6_DNRESP := VGA->VGA_DNRESP
	
	If VI6->(FieldPos("VI6_EMACLI")) > 0
		VI6->VI6_EMACLI := cEmaCli
	EndIf
	If VI6->(FieldPos("VI6_NUMCLI")) > 0
		VI6->VI6_NUMCLI := cNumCli
	EndIf
	If VI6->(FieldPos("VI6_COMCLI")) > 0
		VI6->VI6_COMCLI := cComCli
	EndIf
	If VI6->(FieldPos("VI6_BAICLI")) > 0
		VI6->VI6_BAICLI := cBaiCli
	EndIf
	If VI6->(FieldPos("VI6_SEXCLI")) > 0
		VI6->VI6_SEXCLI := cSexCli
	EndIf
	If VI6->(FieldPos("VI6_PESCLI")) > 0
		VI6->VI6_PESCLI := cPesCli
	EndIf
	If VI6->(FieldPos("VI6_CPFCLI")) > 0
		VI6->VI6_CPFCLI := cCPFCli
	EndIf
	If VI6->(FieldPos("VI6_DDDCEL")) > 0
		VI6->VI6_DDDCEL := cDDDCel
	EndIf
	If VI6->(FieldPos("VI6_NUMCEL")) > 0
		VI6->VI6_NUMCEL := cNumCel
	EndIf
	If VI6->(fieldpos("VI6_VOLKSB")) > 0
		VI6->VI6_VOLKSB := VGA->VGA_VOLKSB
	EndIf
	If VI6->(fieldpos("VI6_CONTRA")) > 0
		VI6->VI6_CONTRA := VGA->VGA_CONTRA
	EndIf
	
	If VI6->(fieldpos("VI6_TELFON")) > 0
		VI6->VI6_TELFON := cTELEFO
	Endif
	
	MsUnlock()
	
	dBSelectArea("VG5")
	dBGotop()
	
	If !Empty(VGA->VGA_NUMOSV)
		cNumero := VGA->VGA_NUMOSV
		dBSetOrder(1)
	Else
		cNumero := VGA->VGA_NUMNFI
		dbsetorder(2)
	EndIf
	
	dBSeek(xFilial("VG5")+VGA->VGA_CODMAR+cNumero)
	
	Do While !Eof() .and. VGA->VGA_CODMAR+cNumero == VG5->VG5_CODMAR + if(!empty(VG5->VG5_NUMOSV),VG5->VG5_NUMOSV,VG5->VG5_NUMNFI) .And. VGA->VGA_FILIAL == xFilial("VGA")
		
		If VG5->VG5_TRANSM == "S"
			dbskip()
			loop
		EndIf
		
		If !Empty(VGA->VGA_NUMOSV)
			cNum := VGA->VGA_NUMOSV
		Else
			cNum := strzero(val(VGA->VGA_NUMNFI),8)
		EndIf
		
		dbselectArea("VIC")
		If !empty( VG5->VG5_CODITE )
			dbgotop()
			dbsetorder(4)
			dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNum+space(11)+VG5->VG5_ORDITE+if(VG5->VG5_ITEEXT=="1","S","N")+VG5->VG5_CODITE)
		Else
			dbgotop()
			dbsetorder(5)
			dbseek(xFilial("VIC")+VGA->VGA_CODMAR+cNum+space(11)+VG5->VG5_ORDITE+if(VG5->VG5_SEREXT=="1","S","N")+VG5->VG5_CODSER)
		endif
		
		If !RecLock("VIC", !Found() )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VIC->VIC_FILIAL := VG5->VG5_FILIAL
		
		&& Grava campos relacionado do arquivos VGA/VI6
		For nCpo:=1 to VIC->(FCount())
			
			nFoundCpo := VG5->(FieldPos( "VG5"+Substr(VIC->(FieldName(nCpo)),4) ))
			
			If nFoundCpo # 0 .And. ( Valtype(VIC->(FieldGet(nCpo))) == Valtype(VG5->(FieldGet(nFoundCpo))) )
				
				&( "VIC->"+VIC->(FieldName(nCpo)) ) := VG5->(FieldGet(nFoundCpo))
				
			EndIf
			
		Next
		
		&& Grava campo internos
		VIC->VIC_CODMAR := VG5->VG5_CODMAR
		
		///////// Alteracao necessaria devido a garantia so transmitir OS c/ 5 digitos //////////////
		////////  Passaremos a mandar VGA->CONTRA com o nro da OS //////////////////////////////////
		////////  Renata - 22/04/08 ////////////////////////////////////////////////////////////////
		
		if SM0->M0_CODIGO = "05"
			VIC->VIC_NUMOSV := if(!empty(VG5->VG5_NUMOSV),strzero(val(VGA->VGA_CONTRA),8),strzero(val(VG5->VG5_NUMNFI),8))
		else
			VIC->VIC_NUMOSV := if(!empty(VG5->VG5_NUMOSV),VG5->VG5_NUMOSV,strzero(val(VG5->VG5_NUMNFI),8))
		endif
		/////////////////////////////////////////////////////////////////////////////////////////////
		
		VIC->VIC_CODSER := VG5->VG5_CODSER
		VIC->VIC_TPOGAR := VG5->VG5_TEMPAD
		VIC->VIC_SERESP := if(VG5->VG5_SEREXT=="1","S","N")
		VIC->VIC_GRUITE := VG5->VG5_GRUITE
		VIC->VIC_CODITE := VG5->VG5_CODITE
		VIC->VIC_QTDITE := VG5->VG5_QTDITE
		VIC->VIC_VALMAT := VG5->VG5_VALPEC
		VIC->VIC_ITEESP := if(VG5->VG5_ITEEXT=="1","S","N")
		VIC->VIC_ORDENS := VG5->VG5_ORDITE
		VIC->VIC_FORNEC := VG5->VG5_CODFOR
		VIC->VIC_OBSERV := VG5->VG5_OBSERV
		VIC->VIC_CODDEF := VG5->VG5_CODDEF
		VIC->VIC_TIPGAR := VGA->VGA_ESPGAR
		
		MsUnlock()
		
		dbselectArea("VG5")
		
		If !RecLock("VG5",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VG5->VG5_TRANSM := "S"
		MsUnlock()
		
		dbskip()
		
	enddo
	
	IncProc(OemtoAnsi(STR0006))
	
	dbselectArea("VGA")
	
	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VGA->VGA_TRANSM := "S"
	VGA->VGA_DATTRA := dDataBase
	MsUnlock()
	
	dbskip()
	
enddo

End Transaction

If !lRet
	MostraErro()
EndIf

return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VOLTA_EXPVGAAutor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ volta a situacao do flag de "N" para "S" no arquivo VGA     ±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IA010I(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Volta_EXPVGA()

Local lRet := .t.

Begin Transaction

DbSelectArea("VGA")
dbgotop()

do while !eof() .And. VGA->VGA_FILIAL == xFilial("VGA")
	
	if VGA->VGA_EXPGAR = "N"
		
		If !RecLock("VGA",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VGA->VGA_EXPGAR := "S"   //OS GARANTIA P/ SER EXPORTADA
		MsUnlock()
		
	endif
	
	DbSelectArea("VGA")
	dbskip()
	
enddo

End Transaction

If !lRet
	MostraErro()
EndIf

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CPOIA060  ³ Autor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega os campos no SX3 para serem mostrados na visualizacao  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CPOIA060()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOIA060()

DbSelectArea("SX3")
dbgotop()
dbseek("VGA")
aCampos := {}

do While !eof() .and. x3_arquivo == "VGA"
	
	if X3USO(x3_usado) .And. cNivel>=x3_nivel .And. x3_campo $ [VGA_NUMOSV/VGA_NUMNFI/VGA_SERIEN/VGA_CHASSI/VGA_CODGAR/VGA_DESGAR/VGA_DESMAR/VGA_CODCLI/VGA_NOMCLI/VGA_ABEGAR/VGA_DATFEC/]
		aadd(aCampos,x3_campo)
	endif
	
	dbskip()
	
Enddo

DbSelectArea("VGA")

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaSX1   ³ Autor ³Renata                 ³ Data ³ 22/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criacao das perguntes.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME","X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}


aAdd(aSX1,{cPerg,"01",STR0018,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"02",STR0019,"","","MV_CH2","N",4,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","9999"})


ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc(STR0012)
		EndIf
	EndIf
Next i

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | MontaEDI   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Monta layout.                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aLayout, aInfo)
Local nCntFor
Local cLinha := ""
for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	ncValor := ""
	if Alltrim(cTipo) == "N"
		if valType(aInfo[nCntFor]) == "C"
			aInfo[nCntFor] = val(aInfo[nCntFor])
		endif
		//		if nDecimal > 0 .and. nTamanho <= 4
		//			ncValor = STRZERO(Round((aInfo[nCntFor]/100) * (10 ^ nDecimal),0),nTamanho)
		//		Else
		ncValor = STRZERO(Round((aInfo[nCntFor]) * (10 ^ nDecimal),0),nTamanho)
		//		Endif
	else
		ncValor := LEFT(aInfo[nCntFor]+SPACE(nTamanho),nTamanho)
	endif
	cLinha += ncValor
next
cLinha += CHR(13) + CHR(10)
return cLinha

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0013
Local cDesc2  := STR0014
Local cDesc3  := ""

Private cString  := "VGA" // TODO
Private Tamanho  := "M"
Private aReturn  := { STR0015,2,STR0016,2,2,1,"",1 }
Private wnrel    := "GARANTIAVW" // TODO
Private NomeProg := "GARANTIAVW" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := STR0020
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "  // TODO
Private Cabec2   := " "  // TODO
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------
for nCntFor = 1 to Len(aLinhasRel)

If Li > 55
li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
li++
Endif
//
@ Li++, 1   PSay aLinhasRel[nCntFor]
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
@ Li++ , 1 psay STR0011
exit
Endif
next
//
If Li <> 80
Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
Set Printer TO
dbCommitAll()
OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
return

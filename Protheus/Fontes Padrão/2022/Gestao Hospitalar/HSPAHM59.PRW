#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHM59.CH"
#include "msgraphi.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHM59 ³ Autor ³ Rogerio Tabosa		³ data ³ 28/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Atendimento Clinicas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHM59()      

Local nOpcA := 0, nGDOpc := 0 
Local aValores		:= {}
Local nI			:= 0  
Local aButtons		:= {}

Local nFontePac     := 0
Local nExibBox      := 0
LOCAL nLinha        := 0
local nSalto        := 0 
local nQtdPix       := 0
local nColNome      := 0
local nColMedico    := 0
local nColSala      := 0
local nLarNome      := 0
local nLarMedico    := 0
local nLarSala      := 0
local nAltNome      := 0
local lDestaq       := .F.  
local nColDestaq    := 0 
local nLinBoxDes    := 0
local nLinNome      := 0
local nLinProf      := 0
local nAltHead      := 0
local nLarHead      := 0
Private aLegGM8   := {}  
Private cCadastro := STR0001  //"Painel Gestão de Atendimento"
Private aTela  := {}, aGets := {}
Private aCpoGM8  := {"GM8_DATAGE","GM8_HORAGE","GM8_CODCRM","GM8_NOMCRM","GM8_REGGER","GM8_NOMPAC","GM8_CODLOC", "GM8_LOCDES","GM8_CODDIS","GM8_DESDIS", "GM8_CODREC", "GM8_CODSAL","GM8_NOMSAL", "GCY_DINIPE","GCY_HINIPE"}
Private aJoinGGM8 := {{" LEFT JOIN " + RetSqlName("GCY") + " GCY", "GCY_DINIPE", "GCY.GCY_REGATE=GM8.GM8_REGATE ", "GCY_DINIPE"},;
					  {"", "GCY_HINIPE", "", "GCY_HINIPE"},;
					  {" JOIN " + RetSqlName("GM6") + " GM6", "GM6.GM6_INTMAR", "GM6.GM6_CODDIS=GM8.GM8_CODDIS ", ""}}
Private oGDGM8, oSay1,oSay2, oSay3
Private oSay4,oSay5, oSay6
Private oSay7,oSay8, oSay9
Private oSay10, oSay11, oSay12, oSay13
Private aHeadGM8 := {}, aColsGM8 := {}, nUGM8 := 0
Private oTimer1 // Timer de Atualização dos Status do Orçamento  
Private aObjects, aInfo, aSize, aPPanel , aPInfo, aPImag , aPPainel
Private oTFont
Private dDatOpen 	:= dDataBase
Private cHorOpen	:= Time()   
Private aPacs		:= {}
Private oGraphEsq	:= Nil
Private oGraphDir	:= Nil
Private oTBitmap1	:= Nil
Private n1, n2, n3, n4

Private cApoio := "" 
Private cInd1 := ""
Private cInd2 := ""
Private nSerie1 := 0
Private nSerie2 := 0 
Private nRecP1
Private nRecP2 
Private aPnl1 := {}
Private aPnl2 := {}
Private aFiles := {}
Private nImgAtu := 1
Private cDiretorio := ""
Private nFontClr   := 0
Private nTpPainel  := 1
Private cCodAval	:= SuperGetMV("MV_CODAVAL", NIL, "") 
Private nQtdPacIn	:= 0 //Quantidade de paciente no painel

If !HS_ExisDic({{"C", "GCY_DINIPE"}},.T.)
	Return()
EndIf

AADD(aLegGM8 , {"GM8_HORAGE > Substr(Time(),1,5)", "BR_VERDE"}) //Sem atraso
AADD(aLegGM8 , {"GM8_HORAGE < Substr(Time(),1,5)", "BR_VERMELHO"}) //Atrasado
AADD(aLegGM8 , {"(HS_SOMAHOR(GM8_HORAGE,GM6_INTMAR) > Substr(Time(),1,5)) .AND. GM8_HORAGE < Substr(Time(),1,5)", "BR_AMARELO"}) //No horário
AADD(aLegGM8 , {"!Empty(GCY_DINIPE)", "BR_AZUL"}) //Atendido

//================================================================¿
//³ Pergunta (Setor de Atendimento)		                         ³
//================================================================Ù 
If Pergunte("HSPM59", .T.) 
	cInd1		:= MV_PAR01    
	nUniCor1 	:= IIf(MV_PAR02 == 1, CLR_RED,IIf(MV_PAR02 == 2, CLR_GREEN,IIf(MV_PAR02 == 3, CLR_HBLUE,CLR_YELLOW)))
	nMais1  	:= IIf(MV_PAR02 == 1, 50,IIf(MV_PAR02 == 2, 60,IIf(MV_PAR02 == 3, 0,0)))		
	nMenos1 	:= IIf(MV_PAR02 == 1, 0,IIf(MV_PAR02 == 2, 0,IIf(MV_PAR02 == 3, 65,40)))					
	cInd2		:= MV_PAR03
	nUniCor2 	:= IIf(MV_PAR04 == 1, CLR_RED,IIf(MV_PAR04 == 2, CLR_GREEN,IIf(MV_PAR04 == 3, CLR_HBLUE,CLR_YELLOW)))	
	nMais2  	:= IIf(MV_PAR04 == 1, 50,IIf(MV_PAR04 == 2, 60,IIf(MV_PAR04 == 3, 0,0)))		
	nMenos2 	:= IIf(MV_PAR04 == 1, 0,IIf(MV_PAR04 == 2, 0,IIf(MV_PAR04 == 3, 65,40)))						
	cDiretorio	:= MV_PAR05  
	If type("MV_PAR06") # "U"  
		nFontePac	:= -(IIf(Empty(MV_PAR06),20,MV_PAR06))
		nExibBox    := MV_PAR07		
		nFontClr    := MV_PAR08				
		nTpPainel	:= MV_PAR09
	Else
		nFontePac := -20
		nExibBox  := 1
		nFontClr  := 1
		nTpPainel := 1
	Endif
	if type("MV_PAR10") # "U"
		//lDestaq := iIf(MV_PAR10 == 1, .F., .T.)
		if empty(MV_PAR10)
			lDestaq := .F.
		else
			lDestaq := iIf(MV_PAR10 == 1, .F., .T.)
		endif
	endif
	
Else
	Return()
EndIf  
If !Empty(cDiretorio) .and. !lDestaq
	aFiles := HS_RETFDIR(cDiretorio, ".JPG|.PNG|.BMP|.JPEG" )
EndIf

If nTpPainel ==  2
	cCadastro := "Painel Comercial"
	If Empty(cCodAval)
		Hs_MsgInf(STR0020 + " MV_CODAVAL!",STR0021,STR0022)//"Necessário definir o parametro" ## "Atenção" ### "Validação Painel"
		Return()
	EndIf
EndIf

AADD(aPacs,{"","","","01","000000", 65280, "1"})
AADD(aPacs,{"","","","02","000000", 65280, "1"})
AADD(aPacs,{"","","","03","000000", 65280, "1"})
AADD(aPacs,{"","","","04","000000", 65280, "1"})
AADD(aPacs,{"","","","05","000000", 65280, "1"})
AADD(aPacs,{"","","","06","000000", 65280, "1"})
AADD(aPacs,{"","","","07","000000", 65280, "1"})
AADD(aPacs,{"","","","08","000000", 65280, "1"})
AADD(aPacs,{"","","","09","000000", 65280, "1"})
AADD(aPacs,{"","","","10","000000", 65280, "1"})
	
Define  FONT oFontNew NAME "Arial,60," BOLD 
//oTFont := TFont():New('Arial',,-20,.T.)
//tamanho do fonte a ser utilizado na exibicao do nome do paciente
oTFont := TFont():New('Arial',,nFontePac,.T.)
oTFont:Bold := .T.

oTFontTit := TFont():New('Arial',,-14,.T.)
oTFontTit:Bold := .T.

Inclui	:= .F.
aSize	:= MsAdvSize(.T.)
 
aObjects := {}
If (!Empty(cInd1) .AND. !lDestaq) .OR. (!Empty(cInd2) .AND. !lDestaq) //Se nao vai destacar o paciente atual
	aAdd( aObjects, { 100, 020, .T., .T.} ) 
	aAdd( aObjects, { 100, 025, .T., .T.} )
	aAdd( aObjects, { 100, 055, .T., .T.} )
Else
	aAdd( aObjects, { 100, 001, .T., .T.} ) 
	aAdd( aObjects, { 100, 025, .T., .T.} )
	aAdd( aObjects, { 100, 074, .T., .T.} )
EndIf
//aAdd( aObjects, { 100, 040, .T., .T.,.T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)  
 
aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0,  0 }
aPInfo := MsObjSize( aInfo, aObjects, .T.)

aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.} )	
aInfo  := { aPPanel[2, 2], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0, 0 }
aPImag := MsObjSize( aInfo, aObjects, .T.)

aObjects := {}	
aAdd( aObjects, { 050, 100, .T., .T.} )	
//aAdd( aObjects, { 050, 100, .T., .T.} )	
aAdd( aObjects, { 050, 100, .T., .T.} )	
//aAdd( aObjects, { 050, 100, .T., .T.} )	

aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
aPPainel := MsObjSize( aInfo, aObjects, .T.) 

DEFINE MSDIALOG oDlgM59 TITLE OemToAnsi(cCadastro) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  

//HS_BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg 17, 
HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_DATAGE = '" + DTOS(dDataBase) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.GM8_STATUS IN ('1','3') ",,"GM8_STATUS",/*"GM8_DATAGE/GM8_HORAGE/GM8_CODCRM/GM8_NOMCRM/GM8_CODLOC/GM8_LOCDES/GM8_CODDIS/GM8_DESDIS/GM8_CODREC/GM8_CODSAL/GM8_NOMSAL"*/,,,,,,.F.,aLegGM8,,.T.,,, aCpoGM8, aJoinGGM8,,"GM8_HORAGE")
nCodCrm := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_CODCRM"}) 
nHorAge := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) 

//@aPInfo[1, 1]+10,aPInfo[1, 2]+7  SAY oSay4 PROMPT OemToAnsi("Agendas do Dia:") SIZE 100,012 OF oDlgM59 PIXEL COLOR CLR_HBLUE
oGDGM8 := MsNewGetDados():New(aPInfo[1, 1]+33, aPInfo[1, 2], 	aPInfo[1, 3], aPInfo[1, 4],0,,,,,,,,,, oDlgM59, aHeadGM8, aColsGM8)    // 000 000 300 500
/*oGDGM8:oBrowse:lUseDefaultColors := .F.
oGDGM8:oBrowse:SetBlkBackColor({|| 16776960 })*/

nQtdPix    := aPPanel[2, 4] - aPPanel[2, 2] //largura

if nFontePac < -20                             
	// 40% Nome Paciente / 40% Nome Medico / 20% Sala
	nColNome   := aPPanel[2, 2] + 10
	nColMedico := (nQtdPix * 0.5) + 20
	nColSala   := (nQtdPix * 0.8)
	nLarNome   := nQtdPix * 0.50
	nLarMedico := nQtdPix * 0.25
	nLarSala   := nQtdPix * 0.20
	nAltNome   := (-(oTFont:nHeight) /2 )
else
	nColNome   := aPPanel[2, 2]+15
	nColMedico := aPPanel[2, 2]+195
	nColSala   := aPPanel[2, 2]+360
	nLarNome   := 600
	nLarMedico := 600
	nLarSala   := 600
	nAltNome   := 012
endif

//Salto PARA fonte maior que 34

nLinha := aPPanel[2, 1] + 3
nSalto := IIf (nFontePac < -34, 30, 20 )

if !lDestaq //Nao exibe o primeiro nome destacado
	/*
	if nExibBox == 1
		@aPPanel[2, 1], aPPanel[2, 2]+3 TO aPPanel[2, 3], aPPanel[2, 4]-5 Label "" OF oDlgM59 PIXEL 
	endif                   */
	
	//obtem a linha inicial do box	
	nLinBoxDes := nLinha - 5
	
	@nLinha,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0002) SIZE 100,012 OF oDlgM59 PIXEL FONT oTFontTit //"Nome:"
	@nLinha,nColMedico  SAY oSay10 PROMPT OemToAnsi(STR0010 + ":") SIZE 100,012 OF oDlgM59 PIXEL FONT oTFontTit //"Profissional:"
	@nLinha,nColSala  SAY oSay10 PROMPT OemToAnsi(STR0004) SIZE 50,012 OF oDlgM59 PIXEL FONT oTFontTit  //"Sala:"
	
	nLinha += 10
	
	@nLinha,nColNome SAY oSay1 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont
	@nLinha,nColMedico SAY oSay2 PROMPT OemToAnsi("") SIZE nLarMedico,nAltNome OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont
	@nLinha,nColSala SAY oSay3 PROMPT OemToAnsi("") SIZE nLarSala,nAltNome OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont
	
	nLinha += nSalto
	@nLinha,nColNome SAY oSay4 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	@nLinha,nColMedico SAY oSay5 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	@nLinha,nColSala SAY oSay6 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	
	nLinha += nSalto
	@nLinha,nColNome SAY oSay7 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	@nLinha,nColMedico SAY oSay8 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	@nLinha,nColSala SAY oSay9 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	
	nLinha += nSalto
	@nLinha,nColNome SAY oSay11 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont
	@nLinha,nColMedico SAY oSay12 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont
	@nLinha,nColSala SAY oSay13 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont
	nLinha += nSalto
	
	if nExibBox == 1
		@nLinBoxDes, aPPanel[2, 2]+3 TO nLinha + 5, aPPanel[2, 4]-5 Label "" OF oDlgM59 PIXEL 
	endif
	
else
	cInd1 := ""
	cInd2 := ""	
	//Aumentando a fonte para exibicao do paciente que sera exibido em destaque 
	oTFont := TFont():New('Arial',,nFontePac * 1.5,.T.)
	oTFont:Bold := .T.
	//obtem a linha inicial do box	
	nLinBoxDes := nLinha - 5
	//Linha onde o nome do paciente sera exibido
	nLinNome := nLinha
	nLinha += nSalto*1.5
	//Linha onde o nome da sala sera exibido
	nLinSala := nLinha
	nLinha += nSalto * 1.5
	//Linha onde o nome do profissional sera exibido	
	nLinProf := nLinha
	//Cabecalho
	//Obtendo Width e Height 
	@nLinProf,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0010 + ":") OF oDlgM59 PIXEL FONT oTFont //"Profissional:"
	nAltHead      := oSay10:nHeight
	nLarHead      := oSay10:nWidth
	//Cabecalho: Nome, Profissional e Sala
	@nLinProf,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0010 + ":") size nLarHead,nAltHead OF oDlgM59 PIXEL FONT oTFont //"Profissional:"
	@nLinNome,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0002) size nLarHead,nAltHead  OF oDlgM59 PIXEL FONT oTFont //"Nome:"
	@nLinSala,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0004) size nLarHead,nAltHead  OF oDlgM59 PIXEL FONT oTFont  //"Sala:"
	
	//Coluna onde os dados serao exibidos	
	nColDestaq := nColNome + nLarHead* .9
	
	//Nomes dos pacientes
	@nLinNome,nColDestaq SAY oSay1 PROMPT OemToAnsi("") SIZE nLarNome*1.5,nAltNome*1.5 OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont
	@nLinProf,nColDestaq SAY oSay2 PROMPT OemToAnsi("") SIZE nLarMedico*1.5,nAltNome*1.5 OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont
	@nLinSala,nColDestaq SAY oSay3 PROMPT OemToAnsi("") SIZE nLarSala*1.5,nAltNome*1.5 OF oDlgM59 PIXEL COLOR CLR_HGREEN FONT oTFont	
	
	if nExibBox == 1
		@nLinBoxDes, aPPanel[2, 2]+3 TO nLinha + (nAltNome*1.5) + 5, aPPanel[2, 4]-5 Label "" OF oDlgM59 PIXEL 
		nLinha += (nSalto/3)
	else
		nLinha += nSalto
	endif

	nLinha += nSalto*1.5
	
	@nLinha,nColNome  SAY oSay10 PROMPT OemToAnsi(STR0002) SIZE 100,012 OF oDlgM59 PIXEL FONT oTFontTit //"Nome:"
	@nLinha,nColMedico  SAY oSay10 PROMPT OemToAnsi(STR0010 + ":") SIZE 100,012 OF oDlgM59 PIXEL FONT oTFontTit //"Profissional:"
	@nLinha,nColSala  SAY oSay10 PROMPT OemToAnsi(STR0004) SIZE 50,012 OF oDlgM59 PIXEL FONT oTFontTit  //"Sala:"
    
	oTFont := TFont():New('Arial',,nFontePac,.T.)
	oTFont:Bold := .T.
	nLinha += nSalto
	
	@nLinha,nColNome SAY oSay4 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	@nLinha,nColMedico SAY oSay5 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	@nLinha,nColSala SAY oSay6 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_YELLOW FONT oTFont
	
	nLinha += nSalto
	@nLinha,nColNome SAY oSay7 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	@nLinha,nColMedico SAY oSay8 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	@nLinha,nColSala SAY oSay9 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_HRED FONT oTFont
	
	nLinha += nSalto
	@nLinha,nColNome SAY oSay11 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont
	@nLinha,nColMedico SAY oSay12 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont
	@nLinha,nColSala SAY oSay13 PROMPT OemToAnsi("") SIZE nLarNome,nAltNome OF oDlgM59 PIXEL COLOR CLR_BLUE FONT oTFont	
		
		
endif


If !Empty(cInd1)
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA")  + cInd1) .AND. Alltrim(GTA->GTA_TIPOIN) $ "23"
		nRecP1 := GTA->(Recno())
		aPnl1 := HSPPO020(nRecP1, .F.)
		If aPnl1 <> Nil .AND. Len(aPnl1) > 0  		
			
			oGraphEsq := TMSGraphic():New( aPPanel[3,1],aPPanel[3,2],oDlgM59,,,,250,170)
			oGraphEsq:SetTitle(Alltrim(GTA->GTA_TITULO),"", CLR_BLACK, A_LEFTJUST, GRP_TITLE  )
			oGraphEsq:SetMargins(2,6,6,6)
			oGraphEsq:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)

			// Itens do Gráfico   //oGraphic:DelSerie(nSerie)
			nSerie1 := oGraphEsq:CreateSerie( aPnl1[1] )						
			For nI := 1 to Len(aPnl1[3,1])
				oGraphEsq:Add(nSerie1, aPnl1[5,1,nI], Substr(Alltrim(aPnl1[3,1,nI]),1,12), nUniCor1 )
				If GTA->GTA_TIPOIN == "2"
					nUniCor1 += nMais1
					nUniCor1 -= nMenos1		 
				EndIf		
			Next
		Else
			cInd1 := ""						
		EndIf
	Else
		cInd1 := ""
	EndIf
EndIf 

If !Empty(cInd2)
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA")  + cInd2) .AND. Alltrim(GTA->GTA_TIPOIN) $ "23"
		nRecP2 := GTA->(Recno())
		aPnl2 := HSPPO020(nRecP2, .F.)
		If aPnl2 <> Nil .AND. Len(aPnl2) > 0  		
			
			oGraphDir := TMSGraphic():New( aPPanel[3,1],aPPanel[3,4]/2,oDlgM59,,,,250,170)
			oGraphDir:SetTitle(Alltrim(GTA->GTA_TITULO),"", CLR_BLACK, A_LEFTJUST, GRP_TITLE  )
			oGraphDir:SetMargins(2,6,6,6)
			oGraphDir:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
			// Itens do Gráfico
			nSerie2 := oGraphDir:CreateSerie( aPnl2[1] )						
			For nI := 1 to Len(aPnl2[3,1])
				oGraphDir:Add(nSerie2, aPnl2[5,1,nI], Substr(Alltrim(aPnl2[3,1,nI]),1,12), nUniCor2 )
				If GTA->GTA_TIPOIN == "2"				
					nUniCor2 += nMais2
					nUniCor2 -= nMenos2
				EndIf
			Next
		Else
			cInd2 := ""			
		EndIf
	Else
		cInd2 := ""
	EndIf
EndIf

//================================================================¿'
//³ Timer para atualização automatica do Paciente                 ³
//================================================================Ù		

oTimer1 := TTimer():New(1000, {|| FS_ATUCOR() }, oDlgM59 )  //Muda as cores
oTimer1:Activate()

oTimer2 := TTimer():New(3000, {|| FS_VERPAC() }, oDlgM59 )  //Chama paciente
oTimer2:Activate() 

oTimer5 := TTimer():New(10000, {|| FS_ROLAGEM() }, oDlgM59 )  //Rolagem dos pacientes na tela
oTimer5:DeActivate() 

If !Empty(cInd2) .OR. !Empty(cInd1)

	oTimer3 := TTimer():New(30000, {|| FS_ATUGRID() }, oDlgM59 )   //Atualiza e posiciona grid de pacientes
	oTimer3:Activate() 
	
	oTimer4 := TTimer():New(60000, {|| FS_ATUPNL() }, oDlgM59 )   //Atualiza dados do painel
	oTimer4:Activate()                
Else
	If Len(aFiles) > 0
		if nExibBox == 1
			@aPPanel[3,1]+3, aPPanel[3, 2]+3 TO aPPanel[3, 3], aPPanel[3, 4]-5 Label "" OF oDlgM59 PIXEL
		else
			@aPPanel[3,1]+3, aPPanel[3, 2]+3 TO aPPanel[3, 3], aPPanel[3, 4]-5 Label "" OF oDlgM59 PIXEL 
			//@aPPanel[3,1]+3, aPPanel[3, 2]+3 TO nLinha + 10, aPPanel[3, 4]-5 Label "" OF oDlgM59 PIXEL
		endif  

	    oTBitmap1 := TBitmap():New(aPPanel[3,1] + 5,aPPanel[3,2] + 5, aPPanel[3, 4] - 13,aPPanel[3, 3] - aPPanel[2, 3] - 10,,aFiles[1],.T.,oDlgM59,,,.F.,.F.,,,.F.,,.T.,,.F.)  
		//oTBitmap1:lTransparent := .T.		//oTBitmap1:lStretch := .T.	    //oTBitmap1:lAutoSize := .T.  //		oTBitmap1:align := 5
	    If Len(aFiles) > 1
	   		oTimer4 := TTimer():New(10000, {|| FS_TROCAIMG() }, oDlgM59 )   //Atualiza dados do painel
			oTimer4:Activate()
		EndIf
	EndIf         
EndIf  


aAdd(aButtons, {"SAM", {|| HS_LEGM59()}, STR0005, STR0005}) //"Legenda"


ACTIVATE MSDIALOG oDlgM59 ON INIT EnchoiceBar (	oDlgM59,	{|| nOpcA := 1, oDlgM59:End()},;
												{|| nOpcA := 0, oDlgM59:End() },,aButtons)

Return()
           
Static Function FS_ATUCOR() 
local aCores := {65280,Rgb(255,205,0),255,Rgb(255,100,0)}//65535 // RGB( 255, 255, 0 ) chAmarelo2 13434879 //RGB(255,255,204)
local nI     := 0

If nTpPainel == 2 // Painel Comercial são cores automaticas
	Return()
EndIf

if nFontClr == 2
	for nI:=1 to len(aCores)
		aCores[nI] := 0	
	next nI
endif


oSay1:nClrText := Iif(oSay1:nClrText > 0 , 0,aCores[1])
oSay1:Refresh() 

oSay2:nClrText := oSay1:nClrText
oSay2:Refresh()

oSay3:nClrText := oSay1:nClrText
oSay3:Refresh() 


oSay4:nClrText := Iif(oSay4:nClrText > 0 , 0,aCores[2]) //65535 // RGB( 255, 255, 0 )
oSay4:Refresh() 

oSay5:nClrText := oSay4:nClrText
oSay5:Refresh()

oSay6:nClrText := oSay4:nClrText
oSay6:Refresh() 


oSay7:nClrText := Iif(oSay7:nClrText > 0 , 0,aCores[3])
oSay7:Refresh() 

oSay8:nClrText := oSay7:nClrText
oSay8:Refresh()

oSay9:nClrText := oSay7:nClrText
oSay9:Refresh() 

oSay11:nClrText := Iif(oSay11:nClrText > 0 , 0,aCores[4])
oSay11:Refresh() 

oSay12:nClrText := oSay11:nClrText
oSay12:Refresh()

oSay13:nClrText := oSay11:nClrText
oSay13:Refresh() 
Return
          
Static Function FS_VERPAC() 
Local aArea 	:= GetArea()
Local cSql 		:= ""
Local cTop 		:= IIf("DB2" $ TCGetDB() .or. "ORACLE" $ TCGetDB() , "", " TOP 10 ")
Local nLimit	:= 0
Local nPos		:= 0
Local lAtu		:= .F.
Local cAux		:= ""
Local lGcyCodSal:= HS_ExisDic({{"C", "GCY_CODSAL"}},.F.)
Local lExDIniAc	:= HS_ExisDic({{"C", "GCY_DINIAC"}},.F.) 
Local cCondP	:= "" 
Local cCpoChg	:= ""
Local cCondA	:= ""
Local lSom 		:= .F.  
Local nLi		:= 0  
Local nQtdIn	:= 0

If lExDIniAc
	cCpoChg := ",GCY_DINIAC, GCY_HINIAC "
	If nTpPainel == 1
		cCondA := "' AND GM8_STATUS IN ('3') "	
		cCondP := " GCY.GCY_DATALT ='" + SPACE(TAMSX3("GCY_DATALT")[1]) + "' AND GCY_DINIPE = '" + DTOS(dDataBase) + "'" // "' AND GCY_HINIPE >= '" + cHorOpen + "'"	
		cCondP += " AND GCY_DINIAC = '" + SPACE(TAMSX3("GCY_DATALT")[1]) + "' "		
	Else
		cCondP += " GCY_DINIAC = '" + DTOS(dDataBase) + "' "		
		cCondA := "' AND GM8_STATUS IN ('1','3') AND GM8.GM8_CODPRO IN (" + HS_InSql(cCodAval,TamSx3("GA7_CODPRO")[1]) +") "
	EndIf
Else
	cCondA := "' AND GM8_STATUS IN ('3') "
	cCpoChg := ",'' AS GCY_DINIAC,'' AS GCY_HINIAC "
	cCondP := "' AND GCY_DINIPE = '" + DTOS(dDataBase) + "' AND GCY_HINIPE >= '" + cHorOpen + "'"
EndIf

cSql := " SELECT " + cTop + " GCY_REGATE,GCY_DATALT,GCY_NOME, "+iIf(lGcyCodSal,"GCY_CODSAL, ","")+"RA_NOME, GF3_DESCRI, GCY_DINIPE, GCY_HINIPE " + cCpoChg
cSql += " FROM " + RetSqlName("GCY") + " GCY LEFT JOIN " + RetSqlName("GM8") + " GM8 ON GCY.GCY_REGATE = GM8.GM8_REGATE "
cSql += "  AND GM8_CODAGE = GM8_AGDPRC"
cSql += " AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8_DATAGE = '" + DTOS(dDataBase) + cCondA
cSql += " JOIN " + RetSqlName("SRA") + " SRA ON GCY.GCY_CODCRM = SRA.RA_CODIGO
cSql += " AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'
cSql += " LEFT JOIN " + RetSqlName("GF3") + " GF3 ON GF3.GF3_CODIGO = GM8.GM8_CODSAL
cSql += " AND GF3.GF3_FILIAL = '" + xFilial("GF3") + "' AND GF3.D_E_L_E_T_ <> '*'
cSql += " WHERE " + cCondP
cSql += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*'
cSql += " ORDER BY GCY_HINIPE, GCY_HINIAC, GM8_HORAGE  DESC"

//cSql += " WHERE GCY.GCY_DATALT ='" + IIf(nTpPainel == 1,SPACE(TAMSX3("GCY_DATALT")[1]), DTOS(dDataBase)) + cCondP

cSql := ChangeQuery(cSql)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPATU", .F., .F.)

DbSelectArea("TMPATU")

For nLi := 1 To Len(aPacs)
	aPacs[nLi,7]	:= "1"
Next nLi  

aInsere := {}
lSom 	:= .F.

If !Eof()
	While !Eof() .AND. nLimit < 10
		cAux := ""
		nLimit ++
		nPos := Ascan(aPacs,{|x|AllTrim(x[5]) == TMPATU->GCY_REGATE}) //CRM 
		If nPos > 0
			 aPacs[nPos, 7] := "0"
			 aPacs[nPos, 6] := IIf(Empty(TMPATU->GCY_DATALT), 65280, IIf(lExDIniAc, 255,65280))
		Else
			lSom := .T.
			AADD(aInsere, {PadR(AllTrim(TMPATU->GCY_NOME), 29),PadR(AllTrim(TMPATU->RA_NOME), 22) , iIf( lGcyCodSal .and. !empty(TMPATU->GCY_CODSAL), PadR(Posicione("GF3", 1, xFilial("GF3") + TMPATU->GCY_CODSAL, "GF3_DESCRI"), 20),PadR(AllTrim(TMPATU->GF3_DESCRI), 20)), TMPATU->GCY_REGATE, IIf(Empty(TMPATU->GCY_DATALT), 65280, IIf(lExDIniAc, 255,65280))})
		EndIf

/*		lAtu := .T.
		aPacs[nLimit,1] := PadR(AllTrim(TMPATU->GCY_NOME), 29)
		aPacs[nLimit,2] := PadR(AllTrim(TMPATU->RA_NOME), 22) 			
		aPacs[nLimit,3] := iIf( lGcyCodSal .and. !empty(TMPATU->GCY_CODSAL), PadR(Posicione("GF3", 1, xFilial("GF3") + TMPATU->GCY_CODSAL, "GF3_DESCRI"), 20),PadR(AllTrim(TMPATU->GF3_DESCRI), 20))
		aPacs[nLimit,5] := TMPATU->GCY_REGATE		
		If lExDIniAc
			aPacs[nLimit,6]	:= 
		EndIf*/
		DbSkip()
	EndDo
/*Else
	If nTpPainel == 2
		lAtu := .T.
		For nLi := 1 To Len(aPacs)
			aPacs[nLi,1] := PadR(AllTrim(""), 29)
			aPacs[nLi,2] := PadR(AllTrim(""), 22) 			
			aPacs[nLi,3] := ""
			aPacs[nLi,5] := ""
			aPacs[nLi,6]	:= 65280	
		Next nLi		
	EndIf	*/	
EndIf 
DbSelectArea("TMPATU")
DbCloseArea()
aSort(aPacs,,,{|x,y| x[7] + x[4] < y[7] + y[4]}) 

For nLi := 1 To Len(aPacs)
	If aPacs[nLi,7] <> "0"
		aPacs[nLi,1] := PadR(AllTrim(""), 29)
		aPacs[nLi,2] := PadR(AllTrim(""), 22)
		aPacs[nLi,3] := ""
		aPacs[nLi,5] := ""
		aPacs[nLi,6] := 65280
	EndIf
Next nLi

nQtdIn := Len(aInsere)

If nQtdIn > 0
	For nLi := 1 To nQtdIn
		nPos := (11-nLi)
		aPacs[nPos,1] := PadR(AllTrim(aInsere[nLi,1]), 29)
		aPacs[nPos,2] := PadR(AllTrim(aInsere[nLi,2]), 22)
		aPacs[nPos,3] := aInsere[nLi,3]
		aPacs[nPos,5] := aInsere[nLi,4]
		aPacs[nPos,6] := aInsere[nLi,5]
		aPacs[nPos,7] := "0"
		aPacs[nPos,4] := "00"				
	Next nLi
EndIf  

nQtdPacIn := (Ascan(aPacs,{|x|AllTrim(x[5]) == ""})) - 1 // Quantidade de paciente é igual a primeira posição vazia menos 1 do array
If (nQtdPacIn + 1) == 0  .AND. !Empty(aPacs[1,5])
	nQtdPacIn := 10
EndIf

aSort(aPacs,,,{|x,y| x[7] + x[4] < y[7] + y[4]}) 
                                                           
For nLi := 1 To Len(aPacs)
	aPacs[nLi,4] := StrZero(nLi, 2)
Next nLi

If lSom
	FS_ExecSom()
EndIf 

oSay1:SetText(aPacs[1,1])
If nTpPainel == 2
	oSay1:nClrText := aPacs[1,6]
EndIf
oSay1:Refresh()

oSay2:SetText(aPacs[1,2])
If nTpPainel == 2
	oSay2:nClrText := aPacs[1,6]
EndIf
oSay2:Refresh()

oSay3:SetText(aPacs[1,3])
If nTpPainel == 2
	oSay3:nClrText := aPacs[1,6]
EndIf
oSay3:Refresh()

oSay4:SetText(aPacs[2,1])
If nTpPainel == 2
	oSay4:nClrText := aPacs[2,6]
EndIf
oSay4:Refresh()

oSay5:SetText(aPacs[2,2])
If nTpPainel == 2
	oSay5:nClrText := aPacs[2,6]
EndIf
oSay5:Refresh()

oSay6:SetText(aPacs[2,3])
If nTpPainel == 2
	oSay6:nClrText := aPacs[2,6]
EndIf
oSay6:Refresh()

oSay7:SetText(aPacs[3,1])
If nTpPainel == 2
	oSay7:nClrText := aPacs[3,6]
EndIf
oSay7:Refresh()

oSay8:SetText(aPacs[3,2])
If nTpPainel == 2
	oSay8:nClrText := aPacs[3,6]
EndIf
oSay8:Refresh()

oSay9:SetText(aPacs[3,3])
If nTpPainel == 2
	oSay9:nClrText := aPacs[3,6]
EndIf
oSay9:Refresh()

oSay11:SetText(aPacs[4,1])
If nTpPainel == 2
	oSay11:nClrText := aPacs[4,6]
EndIf
oSay11:Refresh()

oSay12:SetText(aPacs[4,2])
If nTpPainel == 2
	oSay12:nClrText := aPacs[4,6]
EndIf
oSay12:Refresh()

oSay13:SetText(aPacs[4,3])
If nTpPainel == 2
	oSay13:nClrText := aPacs[4,6]
EndIf
oSay13:Refresh()

If nQtdPacIn > 4 
	oTimer5:Activate() 	
Else
	oTimer5:DeActivate() 
EndIf

//HS_BDados("GCY", @aHGTD, @aCGTD,, 1,, " GTD.GTD_REGATE = '000000' "              ,,,"/",,,,,,.T.,,,   ,,, aCpoGTD,,,"GTD_DENREG")	
RestArea(aArea)
Return

Static Function FS_ATUGRID()
Local aArea 	:= GetArea()
Local cHorAtu 	:= Substr(Time(),1,5)
Local nAtAtu	:= 0
Local nI		:= 0
aColsGM8 := {}
HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_DATAGE = '" + DTOS(dDataBase) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.GM8_STATUS IN ('1','3') ",,"GM8_STATUS",/*"GM8_DATAGE/GM8_HORAGE/GM8_CODCRM/GM8_NOMCRM/GM8_CODLOC/GM8_LOCDES/GM8_CODDIS/GM8_DESDIS/GM8_CODREC/GM8_CODSAL/GM8_NOMSAL"*/,,,,,,.F.,aLegGM8,,.T.,,, aCpoGM8, aJoinGGM8,,"GM8_HORAGE")
oGDGM8:setArray(aColsGM8)
If Len(aColsGM8) > 3
	For nI := 1 To Len(aColsGM8)
		If aColsGM8[nI,nHorAge] > cHorAtu 
			nAtAtu := IIf(nI > 1, nI-1, nI)
			Exit
		EndIf		
	Next nI
	If nAtAtu > 0 
		oGDGM8:oBrowse:nAt := nAtAtu	
	Else
		oGDGM8:oBrowse:nAt := Len(aColsGM8)
	EndIf
EndIf

oGDGM8:oBrowse:Refresh()
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExecSom    ºAutor  ³Rogério Tabosa        º Data ³18/02/11        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que utiliza programas auxiliares para execucao de arquivos º±±
±±º          ³de som WAV.                                                       º±±
±±º          ³1. Exista uma pasta MEDIA no RootPath                             º±±
±±º          ³2. O arquivo de som a ser executado precisa estar nesta pasta     º±±
±±º          ³3. O programa RunProcess.exe precisa estar na pasta               º±±
±±º          ³4. O programa SndRec32.exe precisa estar na pasta                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Nome do arquivo WAV a ser executado                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_ExecSom(cArquivo)

Local cDirCli 			:= GetClientDir()
Local cDirSrv 			:= "\Media\"
Local lOk				:= .T.

Default cArquivo  		:= "NOTIFY.WAV"

If ValType(cArquivo) # "C"
	Return Nil
Endif
If Empty(cArquivo)
	cArquivo := "NOTIFY.WAV"
Endif
//Verifica a existencia dos arquivos necessário localmente // 
If !File(cDirCli + "SndRec32.exe")
	//Tenta copiar do servidor
	If !CpyS2T(cDirSrv + "SndRec32.exe",cDirCli,.F.)
		lOk := .F.
	Endif
EndIF
//Verifica se existe o programa para execucao de som
If !File(cDirCli + "RunProcess.exe")
	//Tenta copiar do servidor
	If !CpyS2T(cDirSrv + "RunProcess.exe",cDirCli,.F.)
		lOk := .F.
	Endif
EndIF
//Verifica a existencia do som solicitado
If !File(cDirCli + cArquivo)
	//Tenta copiar do servidor
	If !CpyS2T(cDirSrv + cArquivo,cDirCli,.F.)
		lOk := .F.
	Endif
EndIF
If lOk
	WinExec(cDirCli + "Runprocess.exe /k:30s SndRec32.exe /play /close /embedding " + cDirCli + cArquivo,0)
Endif

Return Nil


Static Function FS_ATUPNL()                                                                  
Local aArea := GetArea() 
Local nI	:= 0  

If !Empty(cInd1) 
	oGraphEsq:DelSerie(nSerie1)
	DbSelectArea("GTA")
	DbSetOrder(1)
	DbGoTo(nRecP1)
	aPnl1 := HSPPO020(nRecP1, .F.)
	If aPnl1 <> Nil .AND. Len(aPnl1) > 0 
	
		oGraphEsq := TMSGraphic():New( aPPanel[3,1],aPPanel[3,2],oDlgM59,,,,250,170)
		oGraphEsq:SetTitle(Alltrim(GTA->GTA_TITULO),"", CLR_BLACK, A_LEFTJUST, GRP_TITLE  )
		oGraphEsq:SetMargins(2,6,6,6)
		oGraphEsq:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)	
	
		// Itens do Gráfico
		nSerie1 := oGraphEsq:CreateSerie( aPnl1[1],,,.T. )
		For nI := 1 to Len(aPnl1[3,1])
			oGraphEsq:Add(nSerie1, aPnl1[5,1,nI], Substr(Alltrim(aPnl1[3,1,nI]),1,12), nUniCor1 )
			If GTA->GTA_TIPOIN == "2"
				nUniCor1 += nMais1
				nUniCor1 -= nMenos1
			EndIf
		Next
	EndIf
EndIf

If !Empty(cInd2) 
	oGraphDir:DelSerie(nSerie2)
	DbSelectArea("GTA")
	DbSetOrder(1)
	DbGoTo(nRecP2)
	aPnl2 := HSPPO020(nRecP2, .F.)
	If aPnl2 <> Nil .AND. Len(aPnl2) > 0
		oGraphDir := TMSGraphic():New( aPPanel[3,1],aPPanel[3,4]/2,oDlgM59,,,,250,170)
		oGraphDir:SetTitle(Alltrim(GTA->GTA_TITULO),"", CLR_BLACK, A_LEFTJUST, GRP_TITLE  )
		oGraphDir:SetMargins(2,6,6,6)
		oGraphDir:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)	
	
		// Itens do Gráfico
		nSerie2 := oGraphDir:CreateSerie( aPnl2[1] )
		For nI := 1 to Len(aPnl2[3,1])
			oGraphDir:Add(nSerie2, aPnl2[5,1,nI], Substr(Alltrim(aPnl2[3,1,nI]),1,12), nUniCor2 )
			If GTA->GTA_TIPOIN == "2"
				nUniCor2 += nMais2
				nUniCor2 -= nMenos2
			EndIf
		Next
	EndIf
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HS_LEGM59 ³ Autor ³Saúde                  ³ Data ³22/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no Painel de Atendimento  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ NIL				                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_LEGM59()
 Local aLegenda := {{"BR_VERDE"  , OemToAnsi(STR0006)}, ; //"Sem atraso"
                    {"BR_VERMELHO"   , OemToAnsi(STR0007)}, ; //"Atrasado"
                    {"BR_AMARELO" , OemToAnsi(STR0008)}, ; //""Dentro do horário""
                    {"BR_AZUL", OemToAnsi(STR0009)}}  //Atendido
 
 BrwLegenda(cCadastro, cCadastro, aLegenda) 
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HS_RETFDIR³ Autor ³Saúde                  ³ Data ³10/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna arquivos de um diretorio especifico 	  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ NIL				                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RETFDIR(cDiretorio, cTipFiles)
Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio
Local aRet	 := {} 
Local nX
       
Default cTipFiles :=  ""        

cDiretorio := Alltrim(cDiretorio)
cDiretorio += IIf(Substr(cDiretorio, Len(cDiretorio),1) $ "/\","","\") //Verifica se a barra esta no final do nome do diretorio

ADir(cDiretorio + "*.*", aFiles, aSizes) //Retorna arquivos para o diretorio 
// Exibe dados dos arquivos
If !Empty(cTipFiles)
	For nX := 1 to Len( aFiles )
		If Substr(aFiles[nX], At(".",aFiles[nX]), Len(aFiles[nX]))  $ cTipFiles   //Caso cTipFiles seja diferente de vazio adiciona no vetor somente arquivos de extensoes mencionadas
			AADD(aRet,  cDiretorio + aFiles[nX])
		EndIf
	Next nX
Else
	aRet := aClone(aFiles)
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_TROCAIMG³ Autor ³Saúde                 ³ Data ³10/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Função para troca da imagem na tela atráves do Timer       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ NIL				                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_TROCAIMG()
nImgAtu ++                                                                
If nImgAtu > Len(aFiles)
	nImgAtu := 1
EndIf
oTBitmap1:SetEmpty()
oTBitmap1:Load( , aFiles[nImgAtu] )
oTBitmap1:Refresh()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HS_PLATAUT ³ Autor ³Saúde                 ³ Data ³10/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ PAINEL DE AUTO ATENDIMENTO GESTÃO DE CLINICAS              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ NIL				                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_PLATAUT()

Local nOpcA   

Private cGetFile		:= ""
Private cFotoPac		:= ""
Private cEnvServ 		:= GetEnvServer()                                            
Private cPathFile 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
Private nSize1
Private nSize2	 
Private nSize3	

Private cPsqAge 		:= Space(TamSx3("GM8_CODAGE")[1])
Private oTBitmap, oSaySit, oSayPac, oSayDen, oGetAge, oDlgAte

oTFont := TFont():New('Arial',,-15,.T.)
oTFont:Bold := .T.

oTFont2 := TFont():New('Arial',,-11,.T.)
oTFont2:Bold := .T.

oTFont3 := TFont():New('Arial',,-20,.T.)
oTFont3:Bold := .T.
oTFont3:Italic := .T.
                                        
Private cCadastro := STR0011 //"Auto-Atendimento"

If SubString (cPathFile,Len(cPathFile),Len(cPathFile)) <> "\"
	cPathFile += "\"
EndIf 

aSize	:= MsAdvSize(.T.)

nSize1		:= aSize[7]*0.75 
nSize2		:= aSize[6]*0.75
nSize3		:= aSize[5]*0.75

//DEFINE MSDIALOG oDlgAte TITLE OemToAnsi(cCadastro) From (12.75), 0 To (589.5), (911.25)	PIXEL Of oMainWnd  
DEFINE MSDIALOG oDlgAte TITLE OemToAnsi(cCadastro) From (nSize1), 0 To (nSize2), (nSize3)	PIXEL Of oMainWnd  


@nSize1 *2.5, nSize3 * 0.03 TO nSize2 *0.45, nSize3 * 0.47  Label "" OF oDlgAte PIXEL 

@nSize1 * 1.2, nSize3 * 0.03 SAY oSay1 PROMPT OemToAnsi(STR0012) SIZE 600,012 OF oDlgAte PIXEL FONT oTFont COLOR CLR_BLUE 	//"Bem vindo..."

@nSize1 * 1.4, (nSize3 * 0.47) - 135 SAY oSay1 PROMPT OemToAnsi(STR0013) SIZE 600,012 OF oDlgAte PIXEL FONT oTFont2 COLOR CLR_BLUE //"Cod. Agend."
@nSize1 * 1.2, (nSize3 * 0.47) - 100 MSGet oGetAge Var cPsqAge Picture "@!" /*Valid (FS_PESQPAC(@cPsqAge, cPathFile)) */ Size 80, 010 Of oDlgAte Pixel Color CLR_BLACK  

oBtnPsq := tButton():New(nSize1 * 1.2, (nSize3 * 0.47) - 15, "?", oDlgAte, {|| FS_PESQPAC(cPsqAge, cPathFile)}, 015, 012,,,, .T.)   

@ (nSize2 *0.30)/2, (nSize3 *0.40)/2  SAY oSayPac PROMPT OemToAnsi(STR0014 + ": ") SIZE 600,012 OF oDlgAte PIXEL FONT oTFont COLOR CLR_BLUE //"Paciente"
@ ((nSize2 *0.30)/2)+15, (nSize3 *0.40)/2  SAY oSayDen PROMPT OemToAnsi(STR0010 + ": ") SIZE 600,012 OF oDlgAte PIXEL FONT oTFont COLOR CLR_BLUE //Profissional


@ ((nSize2 *0.45))- 15, ((nSize3 *0.40)/2)-15  SAY oSaySit PROMPT OemToAnsi("") SIZE 600,012 OF oDlgAte PIXEL FONT oTFont3 COLOR CLR_RED

/*FS_MTNARQ(cPathFile, .T.)     
RepExtract("PACIENTE",cPathFile + "M59FOTO.bmp",.T.,.T.) //Extrai a imagem do repositorio de imagens para a exibição
cGetFile := FS_MTNARQ(cPathFile)     */

oTBitmap := TBitmap():New((nSize2 *0.30)/2, (nSize3 *0.40)/5, 72,95,,cPathFile + cGetFile,.T.,oDlgAte,,,.F.,.T.,,,.F.,,.T.,,.F.)  
//oTBitmap:lAutoSize := .T.  

ACTIVATE MSDIALOG oDlgAte //ON INIT EnchoiceBar (	oDlgAte,	{|| nOpcA := 1, oDlgAte:End()},;
//												{|| nOpcA := 0, oDlgAte:End() })

Return   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_DELARQ ³ Autor ³Saúde                  ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui os arquivos de imagem da pasta			     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MTNARQ(cPath, lDel)     
Local cRet := ""
Default lDel := .F.

If File(cPath + "M59FOTO.bmp")
	If lDel
		FErase(cPath + "M59FOTO.bmp")
	Else
		cRet := "M59FOTO.bmp"
	EndIf
EndIf 
If File(cPath + "M59FOTO.jpg")
	If lDel
		FErase(cPath + "M59FOTO.jpg")
	Else
		cRet := "M59FOTO.jpg"	
	EndIf	
EndIf 
If File(cPath + "M59FOTO.jpeg")
	If lDel
		FErase(cPath + "M59FOTO.jpeg")
	Else
		cRet := "M59FOTO.jpeg"		
	EndIf		
EndIf 
If File(cPath + "M59FOTO.png")
	If lDel
		FErase(cPath + "M59FOTO.png")
	Else
		cRet := "M59FOTO.png"			
	EndIf		
EndIf 

Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_PESQPAC ³ Autor ³Saúde                 ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui os arquivos de imagem da pasta			     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_PESQPAC(cCodAge, cPath)  
Local cBitmap	:= ""
Local cGetFile	:= "" 
Local cCodCli	:= ""
Local cRegAte	:= ""
Local lOk		:= .F.

oTBitmap:setEmpty()
oTBitmap:Refresh()
oTBitmap:=NIL
//Recria o objeto
oTBitmap := TBitmap():New((nSize2 *0.30)/2, (nSize3 *0.40)/5, 72,95,,cPathFile + cGetFile,.T.,oDlgAte,,,.F.,.T.,,,.F.,,.T.,,.F.)  

oSayPac:SetText(STR0014 + ": ") //Paciente
oSayDen:SetText(STR0010 + ": ") //Profissional
oSaySit:SetText("")
oSayPac:Refresh()	
oSayDen:Refresh()	
oSaySit:Refresh()	

DbSelectArea("GM8")
DbSetOrder(1)
If !Dbseek(xFilial("GM8") + cCodAge)
	oSaySit:SetText(STR0015) //"Codigo de agendamento inválido!"
	oSaySit:Refresh()
	cPsqAge := Space(TamSx3("GM8_CODAGE")[1])	
	Return()
EndIf

If !Empty(GM8->GM8_NOMPAC)
	oSayPac:SetText(STR0014 + ": " + Alltrim(GM8->GM8_NOMPAC)) //Paciente
	oSayPac:Refresh()

	oSayDen:SetText(STR0010 + ": " + Alltrim(Posicione("SRA", 11, xFilial("SRA") + GM8->GM8_CODCRM, "RA_NOME"))) //Profissional
	oSayDen:Refresh()	
EndIf

DbSelectArea("GBH")
DbSetOrder(1)
If DbSeek(xFilial("GBH") + GM8->GM8_REGGER)
	cBitmap := GBH->GBH_BITMAP  
	cCodCli := GBH->GBH_CODCLI
Endif

lOk := FS_SITUACAO(cCodAge, cCodCli, GBH->GBH_LOJA)

If lOk .AND. GM8->GM8_STATUS == '1' .AND. Empty(GM8->GM8_REGATE) //0=liberado;1=Ocupado;2=Bloqueado;3=Atendido;4=Ocupado/Bloqueado;5=Confirmado;6=Retorno
	cRegAte:= HS_GATEAGE(	GM8->GM8_REGGER, GM8->GM8_CODCRM, Posicione("GCM", 2, xFilial("GCM") + GM8->GM8_CODPLA, "GCM_CODCON"),;
	 						GM8->GM8_CODPLA,"1" , GM8->GM8_CODLOC, Posicione("GD4", 1, xFilial("GD4") + GM8->GM8_REGGER + GM8->GM8_CODPLA,;
	 						"GD4_MATRIC"), , , cCodAge, .T.)	
EndIf

If !Empty(cBitmap)
	// Exclui arquivo já existente
	FS_MTNARQ(cPath, .T.)
	RepExtract(cBitmap,cPath + "M59FOTO.bmp",.T.,.T.) //Extrai a imagem do repositorio de imagens para a exibição	
	// Pega nome do arquivo com extensão correta
	cGetFile := FS_MTNARQ(cPath)  
	If !Empty(cGetFile)
		//oTBitmap:SetEmpty()
		oTBitmap:Load( , cPath + cGetFile )		
		//oTBitmap:SetBmp(cPath + cGetFile )		
	EndIf                                   
EndIf
oTBitmap:Refresh()
FS_MTNARQ(cPath, .T.)
cPsqAge := Space(TamSx3("GM8_CODAGE")[1])	
oGetAge:SetFocus()
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_PESQPAC ³ Autor ³Saúde                 ³ Data ³19/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui os arquivos de imagem da pasta			     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSPAHM59                                          		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_SITUACAO(cCodAge, cCodCli, cLoja)  
Local aArea  := GetArea() 
Local lRet	 := .T. 
Local cTime  := Substr(Time(), 1,5)
Local nMaxTit:= SuperGetMV("MV_MAXATE",, 0)

DbSelectArea("GM8")
DbSetOrder(1)
If !Dbseek(xFilial("GM8") + cCodAge)
	Return(.F.)
EndIf 

If Empty(GM8->GM8_REGGER) 
	oSaySit:SetText(STR0016 + "!!!") //Dirija-se a Recepção
	oSaySit:Refresh()
	Return(.F.)	
EndIf

If HS_VLDPFIN(cCodCli, cLoja)[1]  > nMaxTit
	oSaySit:SetText(STR0017 + "!!!") // "Dirija-se a Administração"
	oSaySit:Refresh() 
	Return(.F.)	
EndIf 
If GM8->GM8_DATAGE == dDataBase
	If !Empty(GM8->GM8_REGATE) // Atendido
		DbSelectArea("GCY")
		DbSetOrder(1)	
		If DbSeek(xFilial("GCY") + GM8->GM8_REGATE)
			If !Empty(GCY->GCY_DINIPE)
				oSaySit:SetText(STR0018 + "!!!") //O profissional já chamou
				oSaySit:Refresh() 
				Return(.F.)	
			Else
				oSaySit:SetText(STR0019 + "!!!") //Aguarde ser chamado
				oSaySit:Refresh() 
				Return(.T.)				
			EndIf
		EndIf
	EndIf
	If cTime > GM8->GM8_HORAGE //Atrasado
		oSaySit:SetText(STR0016 + "!!!") // "Dirija-se a Recepção "
		oSaySit:Refresh()
		Return(.F.)	
	EndIf
	If HS_SUBAHOR(cTime, "01:00") > cTime //Adiantado mais que 1 hora
		oSaySit:SetText(STR0016 + "!!!") //Dirija-se a Recepção
		oSaySit:Refresh()
		Return(.F.)			
	EndIf  
Else // Agendamento em outro dia
	oSaySit:SetText(STR0016 + "!!!") //Dirija-se a Recepção
	oSaySit:Refresh()
	Return(.F.)		
EndIf
If GM8->GM8_STATUS == '3'
	oSaySit:SetText(STR0016 + "!!!") //Dirija-se a Recepção
	oSaySit:Refresh()
	Return(.F.)		
EndIf

oSaySit:SetText(STR0019 + "!!!") //Aguarde ser chamado
oSaySit:Refresh()                               

RestArea(aArea)
Return(lRet)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para executar a rolagem dos pacientes na tela de acordo com os chamadsos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function FS_ROLAGEM()
Local nL := 0

For nL := 1 To nQtdPacIn
	aPacs[nL, 4] := StrZero(nL + 1, 2)
Next nL
aPacs[nQtdPacIn, 4] := "01"

aSort(aPacs,,,{|x,y| x[4] < y[4]})

Return

// ษออออออออหออออออออป
// บ Versao บ 37     บ
// ศออออออออสออออออออผ

#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFIOM070.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM070  บAutor  ณFabio               บ Data ณ  05/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApontamento eletronico do mecanico.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias (SIGAOFI)                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION OFIOM070

Local nTecla := 0
Local OXverde
Local OXazul
Local aSM0     := {}
Local oFontS12 := TFont():New( "System", 8, 12 )
Local nTmpTpr := GetNewPar("MV_TEMPTPR",3)
Local nTmpBox := GetNewPar("MV_TEMPBOX",5)

Private oSrv,oProdutivo,aOsSemApont := {},cObjeto:="oProdutivo",lFechaStatus := .t.
Private cTitulo := STR0001 //Apontamento Eletronico
Private aVerPad := {}
Private cOS := Space(len(VO1->VO1_NUMOSV))
Private cNumOsv , cTipTem , cFatPar , cLoja , cNomFat , cTipSer , cCodSer , cDesSer , cCodPro , cNomPro , cFuncao , dData , nHora := 0
Private oNumOsv , oTipTem , oFatPar , oLoja , oNomFat , oTipSer , oCodSer , oDesSer , oCodPro , oNomPro , oFuncao
Private oTime2
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oAzul := LoadBitmap( GetResources() , "BR_AZUL" )
Private lFinAuto := .f.
Private cPAR01 := "1"
    
SetKey(VK_F12,{ || FS_PARAMETRO(cPAR01)})


// Inicializa variaveis Get`s
M->VO4_NOSSEQ := Space(Len(VO4->VO4_NOSNUM))+Space(Len(VO4->VO4_SEQUEN))
M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))

// Inicializa variaveis Visuais
M->VO4_CODSER := Space(Len(VO4->VO4_CODSER))
cNumOsv := Space(Len(VO1->VO1_NUMOSV))
cTipTem := Space(Len(VO4->VO4_TIPTEM))
cFatPar := Space(Len(VO4->VO4_FATPAR))
cLoja   := Space(Len(VO4->VO4_LOJA  ))
cNomFat := Space(25)
cTipSer := Space(Len(VO4->VO4_TIPSER))
cCodSer := Space(Len(VO4->VO4_CODSER))
cDesSer := Space(25)
cCodPro := Space(Len(VAI->VAI_CODTEC))
cNomPro := Space(Len(VAI->VAI_NOMTEC))
cFuncao := Space(25)
dData   := Date()
nHora   := Val(Substr(time(),1,2)+Substr(time(),4,2))

aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
Do While nTecla == 0
	
	DEFINE MSDIALOG oDlgEletronic TITLE cTitulo From 3,0 to 36,90 of oMainWnd

	DEFINE TIMER oTime INTERVAL (nTmpTpr*1000) ACTION FS_TIMETELA1() OF oDlgEletronic
	oTime:lActive := .f.
	
	DEFINE TIMER oTime1 INTERVAL (nTmpBox*1000) ACTION If(Empty(M->VO4_CODPRO).And.Empty(M->VO4_NOSSEQ),FS_CHAMASTATUS(),.t.) OF oDlgEletronic
	oTime1:lActive := .t.
	
	DEFINE TIMER oTime2 INTERVAL 50000 ACTION FS_FECHAPERAUT() OF oDlgEletronic
	oTime2:lActive := .t.
	
	DEFINE TIMER oTAtuHora INTERVAL 5000 ACTION FS_TIMEPER() OF oDlgEletronic
	oTAtuHora:lActive := .t.
	
	@ 003,060 SAY Alltrim(aSM0[6]) Font TFont():New( "System", 020, 028 ) SIZE 205,30 OF oDlgEletronic PIXEL COLOR CLR_BLUE CENTER
	@ 020,060 SAY STR0032 Font TFont():New( "System", 015, 020 ) SIZE 205,25 OF oDlgEletronic PIXEL COLOR CLR_BLUE CENTER
	//O.S.
	@ 222,003 SAY OemToAnsi(STR0019) Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 222,030 MSGET oOS VAR cOS PICTURE "@!" Font oFontS12 VALID (cOS:=strzero(val(cOS),len(VO1->VO1_NUMOSV)),FS_POSIC()) SIZE 45,4 OF oDlgEletronic COLOR CLR_BLUE PIXEL
	oOS:bLostFocus := {|| cObjeto:="oOS"}
	
	//produtico
	@ 038,003 TO 118,155 LABEL STR0004 OF oDlgEletronic PIXEL
	
	@ 048,007 SAY STR0005 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 048,050 SAY oCodPro VAR cCodPro  Font oFontS12 PICTURE "@!" SIZE 40,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 063,007 SAY STR0006 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 063,050 SAY oNomPro VAR cNomPro  Font oFontS12 PICTURE "@!" SIZE 100,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 078,007 SAY STR0007 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 078,050 SAY oFuncao VAR cFuncao  Font oFontS12 PICTURE "@!" SIZE 100,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 093,007 SAY STR0008 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 093,050 SAY oData VAR dData  Font oFontS12 PICTURE "@D" SIZE 40,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 107,007 SAY STR0009 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 107,050 SAY oHora VAR nHora  Font oFontS12 PICTURE "@R 99:99" SIZE 40,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	
	@ 222,100 SAY STR0005 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 222,135 MSGET oProdutivo VAR M->VO4_CODPRO PICTURE "@!"  Font oFontS12 VALID FS_VALPRO() F3 "A1B" SIZE 45,4 OF oDlgEletronic COLOR CLR_BLUE PIXEL
	oProdutivo:bLostFocus := {|| cObjeto:="oProdutivo"}
	
	//servico
	@ 038,158 TO 118,355 LABEL STR0002 OF oDlgEletronic PIXEL
	
	@ 048,162 SAY STR0010 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 048,205 SAY oNumOsv VAR cNumOsv Font oFontS12 PICTURE "@!" SIZE 35,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 058,162 SAY STR0011 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 058,205 SAY oTipTem VAR cTipTem Font oFontS12 PICTURE "@!" SIZE 35,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 068,162 SAY STR0012 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 068,205 SAY oFatPar VAR cFatPar Font oFontS12 PICTURE "@!" SIZE 35,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 068,255 SAY STR0017 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 068,275 SAY oLoja   VAR cLoja   Font oFontS12 PICTURE "@!" SIZE 15,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 078,162 SAY STR0015 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 078,205 SAY oNomFat VAR cNomFat Font oFontS12 PICTURE "@!" SIZE 130,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 088,162 SAY STR0013 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 088,205 SAY oTipSer VAR cTipSer Font oFontS12 PICTURE "@!" SIZE 35,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 098,162 SAY STR0014 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 098,205 SAY oCodSer VAR cCodSer Font oFontS12 PICTURE "@!" SIZE 130,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	@ 108,162 SAY STR0016 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 108,205 SAY oDesSer VAR cDesSer Font oFontS12 PICTURE "@!" SIZE 130,15 OF oDlgEletronic PIXEL COLOR CLR_RED
	
	@ 222,187 SAY STR0003 Font oFontS12 OF oDlgEletronic PIXEL COLOR CLR_BLUE
	@ 222,215 MSGET oSrv VAR M->VO4_NOSSEQ PICTURE "@!"  Font oFontS12 VALID FS_VALSRV() SIZE 100,4 OF oDlgEletronic PIXEL  COLOR CLR_BLUE When FS_WHENNOSSEQ()
	oSrv:bLostFocus := {|| cObjeto:="oSrv"}
	
	//label do grid
	@ 120,003 TO 220,356 LABEL STR0018 OF oDlgEletronic PIXEL
	
	@ 128,006 LISTBOX oLbOsSemApont FIELDS HEADER " ",;
		OemToAnsi(STR0019),;
		OemToAnsi(STR0020),;
		OemToAnsi(STR0021),;
		OemToAnsi(STR0022),;
		OemToAnsi(STR0023);
		COLSIZES 5,40,30,50,50,60;
		SIZE 348,89 OF oDlgEletronic PIXEL ON CHANGE (cOs:=aOsSemApont[oLbOsSemApont:nAt,1],oOS:refresh());
		ON DBLCLICK FS_CLICKVAL() PIXEL
	
	FS_OSSEMAPONT()
	oLbOsSemApont:bLostFocus := {|| cObjeto:="oLbOsSemApont"}
                
    If ExistBlock("O070BOT")
       ExecBlock("O070BOT",.f.,.f.,)
    Endif
	
//	@ 234, 157 BUTTON oLibOsv  PROMPT OemToAnsi(STR0041) OF oDlgEletronic SIZE 30,11 PIXEL ACTION FS_SENHA("1") //Libera OS
//	@ 234, 198 BUTTON oReqPec  PROMPT OemToAnsi(STR0042) OF oDlgEletronic SIZE 30,11 PIXEL ACTION FS_SENHA("2") //Req.Pecas
	If ExistBlock("O070RQPC")
		@ 234, 198 BUTTON oReqPec  PROMPT OemToAnsi(STR0042) OF oDlgEletronic SIZE 30,11 PIXEL ACTION ExecBlock("O070RQPC",.f.,.f.,) //Req.Pecas
	Endif
	@ 234, 239 BUTTON oOficina PROMPT OemToAnsi(STR0043) OF oDlgEletronic SIZE 30,11 PIXEL ACTION (lFechaStatus := .f.,FS_CHAMASTATUS(),lFechaStatus := .t.) //Mapa Ofic.
	@ 234, 281 BUTTON oFecha   PROMPT OemToAnsi(STR0044) OF oDlgEletronic SIZE 30,11 PIXEL ACTION (nTecla := 1,oDlgEletronic:End()) //cancelar.
	
	@ 240,010 BITMAP OXverde RESOURCE "BR_verde"  OF oDlgEletronic PIXEL NOBORDER SIZE 10,10 when .f.
	@ 240,020 SAY STR0039 SIZE 80,08 OF oDlgEletronic PIXEL COLOR CLR_GREEN//servicos a realizar
	@ 240,075 BITMAP OXazul RESOURCE "BR_azul" OF oDlgEletronic PIXEL NOBORDER SIZE 10,10 when .f.
	@ 240,085 SAY STR0040 SIZE 80,08 OF oDlgEletronic PIXEL COLOR CLR_BLUE//servicos iniciados
	
	ACTIVATE MSDIALOG oDlgEletronic CENTER ON INIT (FS_ENADISOBJ(.T.),FS_LIMPA070())
	
	If Empty(M->VO4_CODPRO) .And. Empty(M->VO4_NOSSEQ)
		Exit
	EndIf
	
EndDo
SetKey(VK_F12,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LIMPA07บAutor  ณFabio               บ Data ณ  04/26/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia ou limpa variaveis                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias (SIGAOFI)                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LIMPA070(cObj)

Default cObj := "TODOS"

If cObj == "TODOS"
	// Inicializa variaveis Get`s
	M->VO4_NOSSEQ := Space(Len(VO4->VO4_NOSNUM))+Space(Len(VO4->VO4_SEQUEN))
	M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
	//
	dData := Date()
	nHora := Val(Substr(time(),1,2)+Substr(time(),4,2))
	// Enable obejct's
	FS_ENADISOBJ(.t.)
	//
Endif

// Inicializa variaveis Visuais
If cObj == "SRV" .or. cObj == "TODOS"
	M->VO4_CODSER := Space(Len(VO4->VO4_CODSER))
	cNumOsv := Space(Len(VO1->VO1_NUMOSV))
	cTipTem := Space(Len(VO4->VO4_TIPTEM))
	cFatPar := Space(Len(VO4->VO4_FATPAR))
	cLoja   := Space(Len(VO4->VO4_LOJA  ))
	cNomFat := Space(25)
	cTipSer := Space(Len(VO4->VO4_TIPSER))
	cCodSer := Space(Len(VO4->VO4_CODSER))
	cDesSer := Space(25)
	
	oNumOsv:Refresh()
	oTipTem:Refresh()
	oFatPar:Refresh()
	oLoja:Refresh()
	oNomFat:Refresh()
	oTipSer:Refresh()
	oCodSer:Refresh()
	oDesSer:Refresh()
EndIf

If cObj == "MECANICO" .or. cObj == "TODOS"
	//
	cCodPro := Space(Len(VAI->VAI_CODTEC))
	cNomPro := Space(Len(VAI->VAI_NOMTEC))
	cFuncao := Space(25)
	//
	oCodPro:Refresh()
	oNomPro:Refresh()
	oFuncao:Refresh()
	//
EndIf

If cObj == "TODOS"
	oSrv:Refresh()
	oProdutivo:Refresh()
	oProdutivo:SetFocus()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ENADISOBJบAutor  ณFabio               บ Data ณ  05/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Enable And Disable Object's                                  บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ENADISOBJ(lOperacao)

if Type("oLbOsSemApont") != "O" .or. Type("oOficina") != "O" .or. Type("oFecha") != "O"
	return
endif
If lOperacao
	oLbOsSemApont:Enable()
	oOficina:Enable()
	oFecha:Enable()
Else
	oLbOsSemApont:Disable()
	oOficina:Disable()
	oFecha:Disable()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALPRO บAutor  ณFabio               บ Data ณ  04/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a situacao do produtivo                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALPRO(lAtuTimer)

Local cSQL := ""
Local cAliasAPO := "TAPOABE"
Local cMsg := ""

Local lSTime	:= oTime:lActive
Local lSTime1	:= oTime1:lActive

Default lAtuTimer := .t.

oTime:lActive := .f.
oTime1:lActive := .f.

If Empty(M->VO4_CODPRO)
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1
	FS_LIMPA070("MECANICO")
	Return(.t.)
EndIf

DbSelectArea("VAI")
DbSetOrder(1)
DbSeek(xFilial("VAI")+M->VO4_CODPRO)

if VAI->(FieldPos("VAI_PROFIL")) > 0
	if VAI->VAI_PROFIL <> "1"
		if !Empty(M->VO4_CODPRO) .and. VAI->VAI_FILPRO <> FWCODFIL()
			MsgInfo(STR0051+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC+STR0052,STR0038)
			M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
			oTime:lActive := lSTime
			oTime1:lActive := lSTime1	
			Return .f.
		Endif
	Endif
Else
	if !Empty(M->VO4_CODPRO) .and. VAI->VAI_FILPRO <> FWCODFIL()
		MsgInfo(STR0051+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC+STR0052,STR0038)
		M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
		oTime:lActive := lSTime
		oTime1:lActive := lSTime1	
		Return .f.
	Endif
Endif
If !Empty(M->VO4_CODPRO) .And. !Empty(M->VO4_NOSSEQ)
	
	If !Empty(VAI->VAI_DATDEM) .And. Date() >= VAI->VAI_DATDEM
		M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
		Help("  ",1,"FUNCJADEM",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
		oTime:lActive := lSTime
		oTime1:lActive := lSTime1
		Return( .f. )
	EndIf
	
	If VAI->VAI_FUNPRO # "1"
		M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
		Help("  ",1,"FUNCNPROD")
		oTime:lActive := lSTime
		oTime1:lActive := lSTime1
		Return( .f. )
	EndIf
	
EndIf

DbSelectArea("VO1")
DbSetOrder(1)
DbSeek(xFilial("VO1")+cNumOsv)
DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

If VAI->VAI_FUNPRO == "1" .Or. VAI->VAI_REQPEC == "1" .Or. VAI->VAI_LIBOSV == "1"
	
	DbSelectArea("VO4")
	DbSetOrder(3)
	
	If !lFinAuto .and. VAI->VAI_FUNPRO == "1"
	
		If Empty(M->VO4_NOSSEQ)
		
			DbSeek(xFilial("VO4")+M->VO4_CODPRO)
			Do While !Eof() .And. VO4->VO4_FILIAL + VO4->VO4_CODPRO == xFilial("VO4")+VAI->VAI_CODTEC .And. Empty(VO4->VO4_DATFIN)
				
				If (VO4->VO4_DATINI+1) >= Date() .And. Empty(VO4->VO4_DATDIS) .And. Empty(VO4->VO4_DATFEC) .And. Empty(VO4->VO4_DATCAN);
					.And. !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)
					
					M->VO4_NOSSEQ := VO4->VO4_NOSNUM+VO4->VO4_SEQUEN
					//FS_VALSRV(M->VO4_NOSSEQ)
					
				EndIf
				
				DbSelectArea("VO4")
				DbSkip()
				
			EndDo
		
		Else
		
			VO4->(DbSetOrder(8))
			VO4->(DbSeek(xFilial("VO4")+M->VO4_NOSSEQ))
		
			// Verifica se o Mecanico Com hora aberta em outra Servico 
			cSQL := "SELECT VO4.VO4_NUMOSV, VO4.VO4_GRUSER, VO4.VO4_CODSER, VO4.VO4_DATINI, VO4.VO4_HORINI, VO4.VO4_DATFIN , VO4.VO4_HORFIN "
			cSQL += " FROM " + RetSQLName("VO4") + " VO4 "
			cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=   " AND VO4.VO4_CODPRO = '" + M->VO4_CODPRO + "'"
			cSQL +=   " AND (VO4.VO4_NOSNUM <> '" + Left(M->VO4_NOSSEQ,TamSX3("VO4_NOSNUM")[1]) + "'"
			cSQL +=        " OR (VO4.VO4_NOSNUM = '" + Left(M->VO4_NOSSEQ,TamSX3("VO4_NOSNUM")[1]) + "'"
			cSQL +=            " AND VO4.VO4_CODSER <> '" + VO4->VO4_CODSER + "' )"
			cSQL +=       " )"
			cSQL +=   " AND VO4.VO4_DATCAN = '  '"
			cSQL +=   " AND ( "
			cSQL +=			" ( VO4.VO4_DATINI <> '  ' AND VO4.VO4_DATFIN = '  ' ) "	// Hora aberta em outro servico 
			cSQL +=			" OR "
			cSQL +=			" ( VO4.VO4_DATINI = '" + DtoS(Date()) + "' AND VO4.VO4_HORINI = " + Substr(time(),1,2)+Substr(time(),4,2) + " )" // Mesma hora inicial 
			cSQL +=			" ) "
			cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasAPO, .F., .T. )
			
			If !(cAliasAPO)->(Eof())
			
				If Empty((cAliasAPO)->VO4_DATFIN)
					cMsg := STR0053 + CHR(13) + CHR(13) // "Produtivo com hora aberta em outro servi็o"
				Else
					cMsg := STR0054 + CHR(13) + CHR(13)	// "Produtivo trabalhando em outro servi็o"
				EndIf
				
				cMsg += AllTrim(RetTitle("VO1_NUMOSV")) + ": " + (cAliasAPO)->VO4_NUMOSV + CHR(13) + ;
						AllTrim(RetTitle("VO4_CODSER")) + ": " + (cAliasAPO)->VO4_GRUSER + " - " + (cAliasAPO)->VO4_CODSER + CHR(13) + ;
						AllTrim(RetTitle("VO4_DATINI")) + ": " + Transform(StoD((cAliasAPO)->VO4_DATINI),"@D") + CHR(13) + ;
						AllTrim(RetTitle("VO4_HORINI")) + ": " + Transform((cAliasAPO)->VO4_HORINI,"@R 99:99")
				
				If !Empty((cAliasAPO)->VO4_DATFIN)
					cMsg += chr(13) + AllTrim(RetTitle("VO4_DATFIN")) + ": " + Transform(StoD((cAliasAPO)->VO4_DATFIN),"@D") + CHR(13) + ;
							AllTrim(RetTitle("VO4_HORFIN")) + ": " + Transform((cAliasAPO)->VO4_HORFIN,"@R 99:99")
				EndIf

			
				MsgInfo(cMsg,STR0038)
					
				(cAliasAPO)->(dbCloseArea())
				dbSelectArea("VO4")
				
				M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
				
				oTime:lActive := lSTime
				oTime1:lActive := lSTime1
				Return .f.
				
			EndIf
			(cAliasAPO)->(dbCloseArea())
			dbSelectArea("VO4")
		
		EndIf
		
		
	EndIf
	
	cCodPro := VAI->VAI_CODTEC
	cNomPro := VAI->VAI_NOMTEC
	cFuncao := Substr(Posicione("SRJ",1,xFilial("SRJ")+Alltrim(VAI->VAI_FUNCAO),"RJ_DESC"),1,25)
	
	oCodPro:Refresh()
	oNomPro:Refresh()
	oFuncao:Refresh()

	If !lFinAuto	
		If lAtuTimer .and. (!Empty(M->VO4_NOSSEQ) .or. !Empty(M->VO4_CODPRO))
			oTime:lActive := .f.
			oTime:lActive := .t.
		EndIf
		
		If lAtuTimer
			oSrv:SetFocus()
			FS_ENADISOBJ(.f.)
		EndIf
	EndIf
		
	oLbOsSemApont:Enable()

//	oTime:lActive := lSTime
//	oTime1:lActive := lSTime1
	Return(.t.)
Else
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1
Endif

Return(.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALSRV บAutor  ณFabio               บ Data ณ  04/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Servico                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALSRV(lAtuTimer)

Local cSele := Alias(),nPosAlias
Local cQuery

Local lSTime	:= oTime:lActive
Local lSTime1	:= oTime1:lActive

Default lAtuTimer := .t.

oTime:lActive := .f.
oTime1:lActive := .f.

nPosAlias   := Recno()
nIndAlias   := IndexOrd()

If Empty(M->VO4_NOSSEQ)
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1
	FS_LIMPA070("SRV")
	Return(.t.)
EndIf

If ExistBlock("OM070VLD") 
	lRet := ExecBlock("OM070VLD ",.f.,.f.) 
	If !lRet
		Return(.f.)
	Endif
Endif

DbSelectArea("VO4")
DbSetOrder(8)
DbSeek(xFilial("VO4")+M->VO4_NOSSEQ)

cOS := VO4->VO4_NUMOSV
oOS:Refresh()

If !Empty(VO4->VO4_DATDIS)
	Help("  ",1,"SRVDISP")
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1	
	Return(.f.)
EndIf

If !Empty(VO4->VO4_DATFEC)
	Help("  ",1,"SRVFECH")
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1	
	Return(.f.)
EndIf

If !Empty(VO4->VO4_DATCAN)
	Help("  ",1,"SRVCANC")
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1	
	Return(.f.)
EndIf

// Verifica o tipo de servico 
cQuery := "SELECT VOK_INCMOB"
cQuery +=  " FROM " + RetSQLName("VOK") + " VOK " 
cQuery += " WHERE VOK.VOK_FILIAL='" + xFilial("VOK") + "'"
cQuery +=   " AND VOK.VOK_TIPSER='" + VO4->VO4_TIPSER + "'"
cQuery +=   " AND VOK.D_E_L_E_T_= ' ' "
If FM_SQL(cQuery) $ "2/5/6"
	MsgInfo(STR0055)	// "Servi็o nใo necessita de apontamento"
	oTime:lActive := lSTime
	oTime1:lActive := lSTime1	
	Return(.f.)
EndIf
//

DbSelectArea("VAI")
DbSetOrder(1)
MsSeek(xFilial("VAI")+M->VO4_CODPRO)

If !Empty(M->VO4_CODPRO) .And. !Empty(M->VO4_NOSSEQ)
	
	If !Empty(VAI->VAI_DATDEM) .And. Date() >= VAI->VAI_DATDEM
		Help("  ",1,"FUNCJADEM",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
		oTime:lActive := lSTime
		oTime1:lActive := lSTime1
		Return( .f. )
	EndIf
	
	If VAI->VAI_FUNPRO # "1"
		Help("  ",1,"FUNCNPROD")
		oTime:lActive := lSTime
		oTime1:lActive := lSTime1	
		Return( .f. )
	EndIf
	
EndIf

DbSelectArea("VO2")
DbSetOrder(2)
DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM)
DbSelectArea("VO1")
DbSetOrder(1)
DbSeek(xFilial("VO1")+VO2->VO2_NUMOSV)
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+VO4->VO4_FATPAR+VO4->VO4_LOJA)
DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)
DbSelectArea("VO6")
DbSetOrder(2)
DbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,VO4->VO4_CODSER)+VO4->VO4_CODSER )

If VO2->VO2_TIPREQ == "S"
	
	If IIf(!Empty(M->VO4_CODPRO),FG_HABPRO(M->VO4_CODPRO,VV1->VV1_CODMAR,VO4->VO4_CODSER),.T.)
		
	
		cNumOsv := VO1->VO1_NUMOSV
		cTipTem := VO4->VO4_TIPTEM
		cFatPar := VO4->VO4_FATPAR
		cLoja   := VO4->VO4_LOJA
		cNomFat := Substr(SA1->A1_NOME,1,25)
		cTipSer := VO4->VO4_TIPSER
		cCodSer := VO4->VO4_CODSER
		cDesSer := VO6->VO6_DESSER
		
		oNumOsv:Refresh()
		oTipTem:Refresh()
		oFatPar:Refresh()
		oLoja:Refresh()
		oNomFat:Refresh()
		oTipSer:Refresh()
		oCodSer:Refresh()
		oDesSer:Refresh()
		
		DbSelectArea(cSele)
		DbSetOrder(nIndAlias)
		DbGoto(nPosAlias)
		            
		If !lFinAuto
			If lAtuTimer .and. (!Empty(M->VO4_NOSSEQ) .or. !Empty(M->VO4_CODPRO))
				oTime:lActive := .f.
				oTime:lActive := .t.
			EndIf
			
			If lAtuTimer
				oProdutivo:SetFocus()
			EndIf
			
			FS_ENADISOBJ(.f.)
		EndIf
		
//		oTime:lActive := lSTime
//		oTime1:lActive := lSTime1
		Return(.t.)
		
	EndIf
	
EndIf

oTime:lActive := lSTime
oTime1:lActive := lSTime1

DbSelectArea(cSele)
DbSetOrder(nIndAlias)
DbGoto(nPosAlias)

Return (.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM070  บAutor  ณMicrosiga           บ Data ณ  05/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSe o mecanico estiver trabalhando nao permite alterar o Srv บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_WHENNOSSEQ()

Local cSQL 

If !Empty(M->VO4_CODPRO) .and. VAI->VAI_FUNPRO == "1"

	cSQL := "SELECT COUNT(*) "
	cSQL +=  " FROM " + RetSQLName("VO4") 
	cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
	cSQL +=   " AND VO4_CODPRO = '" + M->VO4_CODPRO + "'"
	cSQL +=   " AND VO4_DATCAN = '        '"
	cSQL +=   " AND VO4_DATINI <> '        '"
	cSQL +=   " AND VO4_DATFIN = '        '"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	
	If FM_SQL(cSQL) > 0
		Return .f.
	EndIf
	
//	DbSelectArea("VO4")
//	DbSetOrder(3)
//	
//	If(VAI->VAI_FUNPRO == "1" .And. VO4->(DbSeek(xFilial("VO4")+M->VO4_CODPRO)) )
//		
//		Do While !Eof() .And. VO4->VO4_FILIAL + VO4->VO4_CODPRO == xFilial("VO4")+VAI->VAI_CODTEC .And. Empty(VO4->VO4_DATFIN)
//			
//			If (VO4->VO4_DATINI+1) >= Date() .And. Empty(VO4->VO4_DATDIS) .And. Empty(VO4->VO4_DATFEC) .And. Empty(VO4->VO4_DATCAN);
//				.And. !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)
//				
//				Return(.f.)
//				
//			EndIf
//			
//			DbSelectArea("VO4")
//			DbSkip()
//			
//		EndDo
//		
//	EndIf
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIMETELบAutor  ณFabio               บ Data ณ  05/16/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama funcao de gravacao do apontamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIMETELA1(nHorMarca)

Local lSTime1 := oTime1:lActive

oTime:lActive := .f.
oTime1:lActive := .f.

// Atualiza Timer da Tela 
FS_TIMEPER(nHorMarca)

// Realiza Apontamento 
If FS_APONTAMENTO()
	oTime:lActive := .f.
EndIf

If Empty(M->VO4_NOSSEQ) .and. Empty(M->VO4_CODPRO)
	oTime:lActive := .f.
Else
	oTime:lActive := .t.
EndIf

FS_OSSEMAPONT()

oTime1:lActive := lSTime1

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIMEPERบAutor  ณFabio               บ Data ณ  06/29/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza time da tela                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIMEPER(nHorMarca1)

Default nHorMarca1 := Val(Substr(time(),1,2)+Substr(time(),4,2))

dData := Date()
nHora := nHorMarca1
oData:Refresh()
oHora:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CHAMASTATUSบAutor  ณFabio               บ Data ณ  05/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama o Mapa da oficina                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CHAMASTATUS()

oTime1:lActive := .F.
oProdutivo:Disable()
oSrv:Disable()
oLbOsSemApont:Disable()

OFIOC140()

FS_TIMETELA1()

oTime1:lActive := .T.
oProdutivo:Enable()
oSrv:Enable()
oLbOsSemApont:Enable()
oProdutivo:SetFocus()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OSSEMAPบAutor  ณFabio               บ Data ณ  05/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra no list Box as OS que nao foram apontadas por nenhum บฑฑ
ฑฑบ          ณprodutivo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OSSEMAPONT()
Local cQuery := ""
Local cQAlSQL := "SQLALIAS"
Local lAddItem := .t.
Local cNosSerInt
Local aOSAux := {}
aOsSemApont := {}
if val(cOS)<=0
	cOS:= space(len(VO1->VO1_NUMOSV))
EndIf

cQuery := "SELECT VO1.VO1_NUMOSV , VO4.VO4_CODSER , VO4.VO4_NOSNUM , VO4.VO4_SERINT , VO4.VO4_DATINI , VO4.VO4_DATFIN , VO4.VO4_SEQUEN , VO4.VO4_CODPRO , VO6.VO6_DESSER , VV1.VV1_CODMAR , VV1.VV1_MODVEI "
cQuery += "FROM "+RetSqlName("VO1")+" VO1 "
cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON ( VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV=VO1.VO1_NUMOSV AND VO2.VO2_TIPREQ='S' AND VO2.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("VO4")+" VO4 ON ( VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NOSNUM=VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("VOK")+" VOK ON ( VOK.VOK_FILIAL='"+xFilial("VOK")+"' AND VOK.VOK_TIPSER=VO4.VO4_TIPSER AND VOK.VOK_INCMOB IN ('0','1','3','4') AND VOK.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("VO6")+" VO6 ON ( VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_SERINT=VO4.VO4_SERINT AND VO6.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VO1.VO1_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_STATUS='A' AND VO1.D_E_L_E_T_=' ' ORDER BY VO4.VO4_NOSNUM , VO4.VO4_TIPTEM , VO4.VO4_CODSER"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	
	aOSAux := {}
	Aadd(aOSAux,{( cQAlSQL )->( VO1_NUMOSV ),( cQAlSQL )->( VV1_CODMAR ),( cQAlSQL )->( VV1_MODVEI ),( cQAlSQL )->( VO4_CODSER ),( cQAlSQL )->( VO6_DESSER ),( cQAlSQL )->( VO4_NOSNUM ),( cQAlSQL )->( VO4_SEQUEN ),( cQAlSQL )->( VO4_CODPRO ),.t.})
	
	dDatIni    := ( cQAlSQL )->( VO4_DATINI )
	dDatFin    := ( cQAlSQL )->( VO4_DATFIN )
	cNosSerInt := ( cQAlSQL )->( VO4_NOSNUM ) + ( cQAlSQL )->( VO4_SERINT )
	
	( cQAlSQL )->( DbSkip() )
	
	If !Empty(dDatIni)
		
		lAddItem := .f.
		
	Elseif ( cQAlSQL )->( VO4_NOSNUM )+( cQAlSQL )->( VO4_SERINT ) # cNosSerInt .And. Empty(dDatIni)
		
		lAddItem := .t.
		
	EndIf
	
	If ( cQAlSQL )->( VO4_NOSNUM )+( cQAlSQL )->( VO4_SERINT ) # cNosSerInt .and. Empty(dDatFin)
		
		Aadd(aOsSemApont,aClone(aOSAux[1]))
		aOsSemApont[len(aOsSemApont),9] := lAddItem
		
	EndIf
	
EndDo
( cQAlSQL )->( DbCloseArea() )

DbSelectArea("VO1")

oLbOsSemApont:Enable()

If Len(aOsSemApont) == 0
	
	Aadd(aOsSemApont,{" "," "," "," "," "," "," "," ",.f.})
	
EndIf

if oLbOsSemApont:nAt > Len(aOsSemApont)
	oLbOsSemApont:nAt := 1
endif

oLbOsSemApont:SetArray(aOsSemApont)
oLbOsSemApont:bLine := { || { 	IIf(aOsSemApont[oLbOsSemApont:nAt,9]==.t.,oVerd,oAzul) ,;
aOsSemApont[oLbOsSemApont:nAt,1] ,;
aOsSemApont[oLbOsSemApont:nAt,2] ,;
aOsSemApont[oLbOsSemApont:nAt,3] ,;
aOsSemApont[oLbOsSemApont:nAt,4] ,;
aOsSemApont[oLbOsSemApont:nAt,5]}}

//oLbOsSemApont:SetFocus()
oLbOsSemApont:refresh()
//&(cObjeto+":SetFocus()")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CLICKVAบAutor  ณFabio               บ Data ณ  05/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJoga servico sem apontamento para o get.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias (SIGAOFI)                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/
Static Function FS_CLICKVAL()

Local cNosNumSeq := M->VO4_NOSSEQ
Local lSTime	:= oTime:lActive
Local lSTime1	:= oTime1:lActive

If !FS_WHENNOSSEQ()
	Return 
EndIf

DbSelectArea("VO4")
DbSetOrder(3)

oTime:lActive := .f.
oTime1:lActive := .f.

M->VO4_NOSSEQ:=aOsSemApont[oLbOsSemApont:nAt,6]+aOsSemApont[oLbOsSemApont:nAt,7]

If !FS_VALSRV()
	M->VO4_NOSSEQ := cNosNumSeq
	// Fica neste ponto, pois se validar corretamente a validacao manipula o timer 
	oTime:lActive := lSTime
EndIf
oTime1:lActive := lSTime1

if val(cOS) > 0
	cOs := aOsSemApont[oLbOsSemApont:nAt,1]
	oOS:refresh()
//	oOS:SetFocus()
EndIf

//oSrv:SetFocus()
oProdutivo:refresh()
oProdutivo:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_APONTAMENTOบAutor ณFabio               บ Data ณ  04/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Mecanico Eletronico                                      บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_APONTAMENTO()

Local nPosVAI := VAI->(Recno()) , nIndVAI := VAI->(IndexOrd()) ,;
	nPosVO1 := VO1->(Recno()) , nIndVO1 := VO1->(IndexOrd()),;
	nPosVO2 := VO2->(Recno()) , nIndVO2 := VO2->(IndexOrd()),;
	nPosVV1 := VV1->(Recno()) , nIndVV1 := VV1->(IndexOrd()),;
	nPosVO4 := VO4->(Recno()) , nIndVO4 := VO4->(IndexOrd())

Local dDataIni,nHoraIni,dDataFin,nHoraFin,lOperacao:=.T.,aSalvaReg:={},aTempTra := {} , cSrvFin := ""
Local lctrSrv := .t. // variavel que controla gravacao no VO4
Local x := 0 , i := 0
Local cLogTexto := ""
Local lOk := .f.
Local cMotPausa := ""
Local lRetorno := .t.
Local cAuxNosNum

Private aMotCancel := {}
Private lMsHelpAuto := .t. , lMsErroAuto := .f.

If Empty(M->VO4_CODPRO) .or. Empty(M->VO4_NOSSEQ)
	Return(.f.)
EndIf

// Valida o Servico e Produtivo
If !lFinAuto
	If !FS_VALSRV(.f.)
		Return .f.
	EndIf
	If !FS_VALPRO(.f.)
		Return .f.
	EndIf
EndIf

VAI->(DbSetOrder(1))
VAI->(DbSeek(xFilial("VAI")+M->VO4_CODPRO))

VO1->(DbSetOrder(1))
VO1->(DbSeek(xFilial("VO1")+cNumOsv))

VO2->(DbSetOrder(1))
VO2->(DbSeek(xFilial("VO2")+cNumOsv+"S"))
cAuxNosNum := VO2->VO2_NOSNUM

VV1->(DbSetOrder(1))
VV1->(DbSeek(xFilial("VV1")+VO1->VO1_CHAINT))

DbSelectArea("VO4")
DbSetOrder(8)
If !DbSeek(xFilial("VO4")+M->VO4_NOSSEQ)
	VO4->(DbSetOrder(nIndVO4))
	VO4->(DbGoto(nPosVO4))
	Return(.f.)
EndIf

&& Marca Produtivo
If VAI->VAI_FUNPRO # "1" .Or. ( !Empty(VAI->VAI_DATDEM) .And. Date() >= VAI->VAI_DATDEM )
	
	VAI->( DbSetOrder(nIndVAI) )
	VAI->( DbGoto(nPosVAI) )
	VO1->( DbSetOrder(nIndVO1) )
	VO1->( DbGoto(nPosVO1) )
	VO2->( DbSetOrder(nIndVO2) )
	VO2->( DbGoto(nPosVO2) )
	VV1->( DbSetOrder(nIndVV1) )
	VV1->( DbGoto(nPosVV1) )
	VO4->(DbSetOrder(nIndVO4))
	VO4->(DbGoto(nPosVO4))
	Return(.f.)
	
EndIf

cTipTSer := VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER

DbSelectArea("VO4")

Aadd(aSalvaReg,Array(FCount()))

if VO4->(FieldPos("VO4_PERRAT")) > 0
	nPerRat := 0
	DbSetOrder(1)
	DbSeek(xFilial("VO4")+cTipTSer)
	Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER == cTipTSer
		If VO4->VO4_CODPRO == M->VO4_CODPRO
			nPerRat := VO4->VO4_PERRAT
			exit
		endif
		DbSkip()
	EndDo
endif
	
DbSetOrder(1)
DbSeek(xFilial("VO4")+cTipTSer)
Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER == cTipTSer
	For i:=1 to FCount()
		aSalvaReg[Len(aSalvaReg),i] := FieldGet(i)
	Next
	If Empty(VO4->VO4_CODPRO) .Or. VO4->VO4_CODPRO == M->VO4_CODPRO
		If (!Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)) .Or. (Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN))
			lOperacao := .f.
			Exit
		EndIf
	EndIf
	DbSkip()
EndDo

If (!Empty(M->VO4_CODPRO) .And. !Empty(M->VO4_NOSSEQ))
	
	If lOperacao .Or. ( Empty(aSalvaReg[Len(aSalvaReg), VO4->(FieldPos("VO4_DATINI")) ] ) .And. Empty(aSalvaReg[Len(aSalvaReg),VO4->(FieldPos("VO4_DATFIN")) ] ) )
		dDataIni := dData
		nHoraIni := nHora
		dDataFin := Ctod("  /  /  ")
		nHoraFin := 0
	Else
		dDataIni := VO4->VO4_DATINI
		nHoraIni := VO4->VO4_HORINI
		dDataFin := dData
		nHoraFin := nHora
		
	EndIf
	
	If FG_QTDMEC( VO1->VO1_NUMOSV , aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_SERINT")) ] , aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_CODPRO")) ] , dDataIni , nHoraIni , dDataFin , nHoraFin ) ;
		.And. FG_HABPRO(M->VO4_CODPRO,VV1->VV1_CODMAR,aSalvaReg[Len(aSalvaReg) , VO4->(FieldPos("VO4_CODSER")) ] )
		
		// Finaliza/Inicializa servico
		DbSelectArea("VOK")
		DbSetOrder(1)
		DbSeek(xFilial("VOK")+aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_TIPSER")) ])
		
		If !(VOK->VOK_INCMOB $ "2/5/6")
			If aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_SRVFIN")) ] # "0"  ;  // Sim Finalizado
				.And.	Empty(dDataFin)
				lctrSrv := .f.
				cSrvFin:="0"
				lctrSrv := .t.
			EndIf
			
			If aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_SRVFIN")) ] # "1"  ;  // Nao Finalizado
				.And.	!Empty(dDataIni).And.!Empty(dDataFin)
				lctrSrv := .f.
				//Finaliza o servico
				cSrvFin:="1"
				lctrSrv := .t.
				
				//verifica se nao eh finalizacao por final do period o de trabalho
				If !lFinAuto//finalizacao automatica
					//selecionar se eh uma pausa ou finalizacao do servico
					if cPAR01 == "1"
						If MsgYesNo(STR0049,OemToAnsi(STR0038) )//ษ uma pausa do servico
							aMotCancel := OFA210MOT("000006","2","","",.f.) // Filtro da consulta do motivo 
							cMotPausa := aMotCancel[1]
							VS0->(dbSeek(xFilial("VS0")+"000006"+cMotPausa))
							cLogTexto:= STR0045 + VO4->VO4_NUMOSV + STR0046 + VO4->VO4_TIPTEM + STR0047 + Left(VO4->VO4_CODSER,11) + STR0048 + cMotPausa+":"+Left(VS0->VS0_DESMOT,19)+" "+STR0050+" "+M->VO4_CODPRO+"-"+Left(VAI->VAI_NOMTEC,19)
							FM_GerLog("P",,cLogTexto)
							M->VO4_MPAUSA := cMotPausa  
							aSalvaReg[ Len(aSalvaReg),VO4->(FieldPos("VO4_MPAUSA")) ] := M->VO4_MPAUSA
						EndIF
					Endif	
				EndIF
				
			EndIf
		EndIf
		
		If FG_TEMPTRA(M->VO4_CODPRO,dDataIni,nHoraIni,dDataFin,nHoraFin ,,,, )

			// Inicializa gravacao
			Begin Transaction
			
			// Grava Tempo trabalhado
			aTempTra := FG_TEMPTRA(M->VO4_CODPRO,dDataIni,nHoraIni,dDataFin,nHoraFin,"A",.f.)

			
			// Movimenta a Conta Corrente do Produtivo
			For i:=1 to Len(aTempTra)
				dDataIni := aTempTra[i,1]
				nHoraIni := aTempTra[i,2]
				dDataFin := aTempTra[i,3]
				nHoraFin := aTempTra[i,4]
				RecLock("VO4",lOperacao)
				For x:=1 to FCount()
					FieldPut(x,aSalvaReg[Len(aSalvaReg),x])
				Next
				if lctrSrv // criado variavel pq estava dando erro qdo selecionada para nao iniciar
					VO4->VO4_CODPRO := M->VO4_CODPRO
					VO4->VO4_DATINI := dDataIni
					VO4->VO4_HORINI := nHoraIni
					VO4->VO4_DATFIN := dDataFin
					VO4->VO4_HORFIN := nHoraFin
				EndIf
				If lOperacao
					M->VO2_NOSNUM := cAuxNosNum
					VO4->VO4_SEQUEN := FS_030SEQUEN(.f.)

					// Nao criar registro novo com movito de pausa 
					VO4->VO4_MPAUSA := M->VO4_MPAUSA := Space(TamSX3("VO4_MPAUSA")[1])

				EndIf
				If aTempTra[i,5] $ " /D/O/F/E"
					VO4->VO4_HOREXT := If( (Empty(aTempTra[i,5]) .Or. aTempTra[i,5] $ "D/O") , "O" , "E" )
					VO4->VO4_TEMTRA := aTempTra[i,6]
				EndIf
				if VO4->(FieldPos("VO4_PERRAT")) > 0
					VO4->VO4_PERRAT := nPerRat
				endif
				MsUnLock()
				if !lOperacao
					lOperacao := .t.
				Endif
			Next
			
			// Marca Movimento de Box
			FG_MARCABOX(VO1->VO1_NUMBOX,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV)
			
			// Finaliza/Inicializa servico
			If !Empty(cSrvFin)
				FS_SRVFIN(VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER,VO4->VO4_TIPSER,cSrvFin)
			EndIf
			
			// Limpa variaveis de Memoria
			FS_LIMPA070()
			
			///////////////////////////////////
			// Gravar Motivo de Cancelamento //
			///////////////////////////////////
			If !Empty(VO4->VO4_MPAUSA) .AND. Len(aMotCancel) > 0 
				OFA210VDT("000006",aMotCancel[1],"2",VO1->VO1_FILIAL,VO1->VO1_NUMOSV,aMotCancel[4])
			EndIf

			//////////////////////
			// Ponto de Entrada //
			//////////////////////
			If ExistBlock("OM070DGR")
				ExecBlock("OM070DGR", .f., .f.)
			EndIf

			End Transaction
		
		Else
			M->VO4_CODPRO := Space(Len(VO4->VO4_CODPRO))
			oProdutivo:Refresh()
			lRetorno := .f.
		EndIf
	EndIf
	
EndIf

If lMsErroAuto
	lRetorno := .f.
	MostraErro()
EndIf

lMsHelpAuto := .f.

VAI->( DbSetOrder(nIndVAI) )
VAI->( DbGoto(nPosVAI) )
VO1->( DbSetOrder(nIndVO1) )
VO1->( DbGoto(nPosVO1) )
VO2->( DbSetOrder(nIndVO2) )
VO2->( DbGoto(nPosVO2) )
VV1->( DbSetOrder(nIndVV1) )
VV1->( DbGoto(nPosVV1) )


Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FECHAPERAUTบAutor  ณFabio               บ Data ณ  06/28/00   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFecha periodo de trabalho do produtivo "Automatico"             บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_FECHAPERAUT()

Local nPosVAI := VAI->(Recno()), nIndVAI := VAI->(IndexOrd()) ,;
nPosVOE := VOE->(Recno()), nIndVOE := VOE->(IndexOrd()) ,;
nPosVOH := VOH->(Recno()), nIndVOH := VOH->(IndexOrd()) ,;
nPosVO4 := VO4->(Recno()), nIndVO4 := VO4->(IndexOrd()) ,;
nPVAIAt := 0

Local lSTime  := oTime:lActive
Local lSTime1 := oTime1:lActive
Local lSTime2 := oTime2:lActive
Local aArea   := {}

oTime:lActive  := .F.
oTime1:lActive := .F.
oTime2:lActive := .F.

DbSelectArea("VAI")
DbSetOrder(1)
DbSeek( xFilial("VAI") )
lFinAuto := .f.
Do While !Eof() .And. VAI->VAI_FILIAL == xFilial("VAI")
	
	If VAI->VAI_FUNPRO == "1" .And. ( Empty(VAI->VAI_DATDEM) .Or. Date() < VAI->VAI_DATDEM )
		
		DbSelectArea("VOE")
		DbSetOrder(1)
		
		iIf(DbSeek(xFilial("VOE")+VAI->VAI_CODTEC+Dtos(Date()),.t.),.t.,DbSkip(-1))
		
		If VOE->VOE_CODPRO == VAI->VAI_CODTEC
			
			DbSelectArea("VOH")
			DbSetOrder(1)
			DbSeek(xFilial("VOH")+VOE->VOE_CODPER)
			
			If VOH->VOH_FINPER <= Val( Substr(Time(),1,2) + Substr(Time(),4,2) )
				
				DbSelectArea("VAI")
				nPVAIAt := Recno()
				
				DbSelectArea("VO4")
				DbSetOrder(3)
				DbSeek(xFilial("VO4")+VAI->VAI_CODTEC)
				
				Do While !Eof() .And. VO4->VO4_FILIAL + VO4->VO4_CODPRO == xFilial("VO4")+VAI->VAI_CODTEC .And. Empty(VO4->VO4_DATFIN)
					
					If (VO4->VO4_DATINI+1) >= Date() .And. Empty(VO4->VO4_DATDIS) .And. Empty(VO4->VO4_DATFEC) .And. Empty(VO4->VO4_DATCAN);
						.And. !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN);
						.And. VO4->VO4_HOREXT # "E"
						
						aArea := sGetArea(aArea , "VAI")
						
						lFinAuto := .t.//variavel para controlar se exibe mensagem de pausa do servico
						cNumOsv := VO4->VO4_NUMOSV
						M->VO4_NOSSEQ := VO4->VO4_NOSNUM+VO4->VO4_SEQUEN
						M->VO4_CODPRO := VAI->VAI_CODTEC
						FS_VALPRO(.f.)
						FS_VALSRV(.f.)
						
						FS_TIMETELA1(VOH->VOH_FINPER)
						FS_LIMPA070()
						
						sRestArea(aArea)
						
						Exit
						
					EndIf
					
					DbSelectArea("VO4")
					DbSkip()
					
				EndDo
				
				DbSelectArea("VAI")
				DbGoTo(nPVAIAt)
				
			EndIf
			
		EndIf
		
	EndIf
	
	DbSelectArea("VAI")
	DbSkip()
	
EndDo

VAI->(DbSetOrder(nIndVAI))
VAI->(DbGoto(nPosVAI))

VOE->(DbSetOrder(nIndVOE))
VOE->(DbGoto(nPosVOE))

VOH->(DbSetOrder(nIndVOH))
VOH->(DbGoto(nPosVOH))

VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoto(nPosVO4))

oTime:lActive  := lSTime
oTime1:lActive := lSTime1
oTime2:lActive := lSTime2

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SENHA  บAutor  ณFabio               บ Data ณ  08/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o usuario pode requisitar peca ou servico       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function FS_SENHA(cButton)

Local cSSenha   := Substr(cUsuario,1,06)
Local OGetSenha
Local oDlgSenha
Local lRet      := .f.
Local cSenhaSup := Space(6)
Local cBitMap   := "LOGIN"
Private cNome := Space(10)

DEFINE DIALOG oDlgSenha TITLE OemToAnsi(STR0033) FROM 20, 20 TO 225,310 PIXEL // Autorizacao de superior

@ 10,55 SAY OemToAnsi(STR0034)	PIXEL						                   // Caixa Atual
@ 20,55 MSGET cNome WHEN .F. PIXEL SIZE 80,08

@ 50,55 SAY OemToAnsi(STR0035) PIXEL                                          // Senha Superior
@ 60,55 MSGET oGetSenha VAR cSenhaSup PASSWORD PIXEL SIZE 40,08 VALID FS_VALSENHA(cSenhaSup)

DEFINE SBUTTON FROM 85,75  TYPE 1 ACTION If(FS_VALUSUARIO(cSenhaSup,cButton),(lRet := .t.,oDlgSenha:End()),.f.) ENABLE OF oDlgSenha
DEFINE SBUTTON FROM 85,105 TYPE 2 ACTION oDlgSenha:End() ENABLE OF oDlgSenha

ACTIVATE MSDIALOG oDlgSenha CENTERED

// Restaura usuario de login.
PswOrder(3)
PswSeek(cSSenha)

Return(lRet)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALSENHAบAutor  ณFabio               บ Data ณ  08/18/00   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida senha do usuario						     	       บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function FS_VALSENHA(cSenhax)

// Senha
PswOrder(3)

If PswSeek(cSenhax)
	
	cNome := PswRet(1)[1][2]
	
	Return(.t.)
	
EndIf

Help("  ",1,"NOSENHA")

Return(.f.)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALUSUARIOบAutor  ณFabio               บ Data ณ  08/18/00   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do usuario              	   		     	         บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function FS_VALUSUARIO(cSenhax , cButton)

oDlgEletronic:Hide()

If cButton == "1"
	
	If !FG_MNU( cSenhax , 3 , "OFIOM140" )
		
		Help("  ",1,"VOPCINVAL")
		
		Return( .f. )
		
	EndIf
	
	&& Libera Tipo de Tempo
	OFIOM140()
	FS_LIMPA070()
	
Else
	
	If !FG_MNU( cSenhax , 3 , "OFIOM020" )
		
		Help("  ",1,"VOPCINVAL")
		
		Return( .f. )
		
	EndIf
	
	&& Requisita peca
	OFIOM020()
	FS_LIMPA070()
EndIf
oDlgEletronic:Show()
Return( .t. )
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SRVFIN บAutor  ณFabio               บ Data ณ  09/25/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFlag final do servico                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SRVFIN(cNosNum,cTipTem,cCodSer,cTipSer,cSrvFin)
Local aArea:={} , cSele := Alias()

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO4")

DbSelectArea("VO4")
DbSetOrder(1)
DbSeek(xFilial("VO4")+cNosNum+cTipTem+cCodSer)

Do While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER == xFilial("VO4")+cNosNum+cTipTem+cCodSer
	If VO4->VO4_TIPSER == cTipSer
		
		RecLock("VO4",.f.)
		VO4->VO4_SRVFIN := cSrvFin
		MsUnLock()
		
	EndIf
	
	DbSelectArea("VO4")
	DbSkip()
EndDo

sRestArea(aArea)

DbSelectArea(cSele)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_POSIC  บAutor  ณRafael Goncalves    บ Data ณ  20/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona na Os informada                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_POSIC()
Local ni := 0
ni := aScan(aOsSemApont, {|x| Alltrim(cOs) $ x[1] })	// Ordem de servico
If ni > 0
	oLbOsSemApont:nAt := ni
	oLbOsSemApont:refresh()	
	
	oProdutivo:SetFocus()
Else
	cOS := Space(len(VO1->VO1_NUMOSV))
	oOS:refresh()
//	oLbOsSemApont:nAt := 1

EndIf

M->VO4_NOSSEQ := Space(Len(VO4->VO4_NOSNUM))+Space(Len(VO4->VO4_SEQUEN))
FS_LIMPA070("SRV")
oSrv:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_PARAMETRO | Autor ณ Thiago				  ณ Data ณ 27/07/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Criacao da parambox.							                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PARAMETRO()
Local aPausa    := {STR0056,STR0057}
Local aParamBox := {}
Local aRet      := {}
       
aAdd(aParamBox,{2,STR0058,"",aPausa,80,"",.f.}) 
	
If !ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
	Return .f.
EndIf

cPAR01 := aRet[1]        

Return()
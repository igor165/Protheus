#INCLUDE "termanu.ch" 
#include "PROTHEUS.CH"               
#INCLUDE "TCBROWSE.CH"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³06/02/2006    |00000092853       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³Erike Yuri da Silva       ³06/02/2006    |00000092853       ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³                          ³              |                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static cComutadora
Static cPorta
Static cIP
Static aTerm := {}
Static cIniFile
Static lGerTime := .f.

Function TerManu()
Local oFont  
Local oBar                  
Local oAni, oLogo,oUserBar
Local	aSize	:={}
Local cMenuBmp := GetMenuBmp() 

Local aStatus := {STR0001,STR0002,STR0003,STR0004,STR0005} //"Desabilitado"###"Off-Line"###"On-Line"###"Finalizando"###"Finalizado"
Local aSimula := {STR0006,STR0007} //"Nao"###"Sim"

PUBLIC oMainWnd
PUBLIC lLeft := .F.
PUBLIC lMSFinalAuto:=.f.
Private oTerm
Private lAtiva :=.f.
Private lSai := .f.
PRIVATE AdvFont
PRIVATE __cInterNet := Nil                            
Private nModulo := 99
Private cModulo := ""
Private cVersao := GetVersao()
Private tInicio   := TIME()  
Private cUserName :=""
// variaveis par a nova versao
Private dDataBase := MsDate()
PRIVATE oShortList
Private oMsgItem0,oMsgItem1,oMsgItem2,oMsgItem3,oMsgItem4


PswOrder(1)
PswSeek("000000")
__Ap5NoMv(.T.)
aUser := PswRet()
__Ap5NoMv(.F.)

Private aEmpresas  := Aclone(aUser[2][6])
Private __RELDIR   := Trim(aUser[2][3])
Private __DRIVER   := AllTrim(aUser[2][4])
Private __IDIOMA   := aUser[2][2]
Private __GRPUSER  := ""
Private __VLDUSER  := aUser[1][6]
Private __ALTPSW   := aUser[1][8]
Private __CUSERID  := aUser[1][1]
Private __NUSERACS := aUser[1][15]
Private __AIMPRESS := {aUser[2][8],aUser[2][9],aUser[2][10],aUser[2][12]}
Private __LDIRACS  := aUser[2][13] 
Private __CRDD     := RDDSetDefault() 
Private oTimer     
Public cArqEmp       := "SIGAMAT.EMP"

If ! MsLogin()
   Return .f.
EndIf

cComutadora:="00"
If ! MsgGet2(STR0008,STR0009,@cComutadora,,, "99" )    //"Gerenciador de Microterminais"###"Comutadora"
   Return .f.
EndIf                                                    
cIniFile := "TERGER"+cComutadora+".INI"
cPorta   := Alltrim(GetPvProfString( "SETUP","Portalpt" , "LPT1",cIniFile  ))
cIP      := Alltrim(GetPvProfString( "SETUP","TcpIP" , "",cIniFile  ))
RPCSetType(3)
RpcSetEnv ("99","01", , , , , , , , .F., .F. )
SetsDefault()                                  
PtInternal(1,STR0010) //"Manutencao de Microterminais"
DEFINE FONT AdvFont NAME "MS Sans Serif" SIZE 0, -9
DEFINE WINDOW oMainWnd FROM 1, 1 TO 22, 75  TITLE  STR0011 //"Manutencao de Micro-Terminais - Aguarde..."

MENU oMenu IMAGE cMenuBmp 
  MENUITEM OemToAnsi(STR0012)	ACTION  Ativa()  //'Ativar Comutadora'
  MENUITEM OemToAnsi(STR0013)	ACTION  Desativa() //'Desativar Comut.'
  MENUITEM OemToAnsi(STR0014)	ACTION  (Parametros(),CargaIni(),AtuTela(.t.))    //'Parametros'
  MENUITEM OemToAnsi(STR0015)	ACTION  (AlteraTer(),CargaIni(),AtuTela(.t.))    //'Alterar'
  MENUITEM OemToAnsi(STR0016)	ACTION  (TrataBut(1),CargaIni(),AtuTela(.t.))    //'Habilitar'
  MENUITEM OemToAnsi(STR0017)	ACTION  (TrataBut(2),CargaIni(),AtuTela(.t.))    //'Desabilitar'
  MENUITEM OemToAnsi(STR0018)	ACTION  (TrataBut(3),CargaIni(),AtuTela(.t.))    //'Finalizar'
  MENUITEM OemToAnsi(STR0019)	ACTION  Monitor() //'Monitorar'
  MENUITEM OemToAnsi(STR0020)	ACTION  (lSai:=.t.,__cInternet:=NIL,Final(STR0021)) //'Sair'###"Termino Normal"
ENDMENU 

oMenu:align			:= CONTROL_ALIGN_LEFT 
oMainWnd:SetMenu( oMenu ) 
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
oMainWnd:Cargo		:= oShortList
oMainWnd:oFont		:= AdvFont
oMainWnd:nClrText	:= 0
oMainWnd:lEscClose	:= .F.
MainToolBar(@oBar)

CargaIni()                            
oMainWnd:ReadClientCoors()
aSize := MsAdvSize(,.F., 380)

oTerm := TCBrowse():New(50,65,200,200,,,,oMainWnd,,,,,,,,,,,,.t.,,.t.,) 
oTerm:Align			:= CONTROL_ALIGN_ALLCLIENT
oTerm:nClrBackFocus	:= GetSysColor( 13 )
oTerm:nClrForeFocus	:= GetSysColor( 14 )                                 
oTerm:SetArray( aTerm )

ADD COLUMN TO oTerm HEADER STR0022	OEM DATA {|| aTerm[oTerm:nAt,01] }	ALIGN LEFT SIZE 25 	PIXELS  //"Terminal"
ADD COLUMN TO oTerm HEADER STR0023	OEM DATA {|| aStatus[aTerm[oTerm:nAt,2]+1] } ALIGN LEFT SIZE 40  	PIXELS //"Status"
ADD COLUMN TO oTerm HEADER STR0024	OEM DATA {|| aTerm[oTerm:nAt,03] } ALIGN LEFT SIZE 25		PIXELS //"Paralela"
ADD COLUMN TO oTerm HEADER STR0025	OEM DATA {|| aTerm[oTerm:nAt,04] } ALIGN LEFT SIZE 25		PIXELS //"Serial"
ADD COLUMN TO oTerm HEADER STR0026	OEM DATA {|| aTerm[oTerm:nAt,05] } ALIGN LEFT SIZE 40		PIXELS //"Rotina"
ADD COLUMN TO oTerm HEADER STR0027 	OEM DATA {|| aTerm[oTerm:nAt,06] } ALIGN LEFT SIZE 25		PIXELS  //"Empresa"
ADD COLUMN TO oTerm HEADER STR0028	OEM DATA {|| aTerm[oTerm:nAt,07] } ALIGN LEFT SIZE 25		PIXELS //"Filial"
ADD COLUMN TO oTerm HEADER STR0029	OEM DATA {|| aTerm[oTerm:nAt,08] } ALIGN LEFT SIZE 50		PIXELS //"Parametros"
//ADD COLUMN TO oTerm HEADER "Simula"	   OEM DATA {|| aSimula[aTerm[oTerm:nAt,9]+1] } ALIGN LEFT SIZE 40		PIXELS
ADD COLUMN TO oTerm HEADER STR0030	OEM DATA {|| aTerm[oTerm:nAt,10] } ALIGN LEFT SIZE 25		PIXELS                  //"Modulo"
ADD COLUMN TO oTerm HEADER STR0031	OEM DATA {|| aTerm[oTerm:nAt,11] } ALIGN LEFT SIZE 25		PIXELS                  //"Modelo"

oTerm:bLDblClick	:= {|| CargaIni(),AtuTela()}
oTerm:bChange		:= {|| CargaIni(),AtuTela()}

SET MESSAGE OF oMainWnd TO STR0010 NOINSET FONT oFont //"Manutencao de Micro-Terminais "
DEFINE MSGITEM oMsgItem0 OF oMainWnd:oMsgBar PROMPT dDataBase SIZE 60  
DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT STR0032 SIZE 150   //"Desativado"
DEFINE MSGITEM oMsgItem2 OF oMainWnd:oMsgBar PROMPT STR0033 SIZE 180   //'Porta: '
DEFINE MSGITEM oMsgItem3 OF oMainWnd:oMsgBar PROMPT STR0009+': '+cComutadora SIZE 170   //'Comutadora: '
DEFINE TIMER oTimer INTERVAL 1000 ACTION (GerTime()) OF oMainWnd
ACTIVATE WINDOW oMainWnd MAXIMIZED valid (lSai   := .t.,__cInternet:=NIL,Final(STR0021)) ON INIT (AtuTela(),oTimer:Activate()) //"Termino Normal"
RELEASE OBJECTS oFont 
Return nil
         

Static Function GerTime()
Local nSeg := Seconds()        
oMainWnd:cCaption	:=STR0010 //"Manutencao de Micro-Terminais"
lGerTime			:= .t.
oTimer:Deactivate()
lSai				:= .F.                                                                                   
While !lSai .and. !KillApp()       
   lAtiva:= File("TERGER"+cComutadora+".ATV") 
   If Seconds()-nSeg > 5 .or. len(aTerm) ==0 
      nSeg:=Seconds()
      CargaIni()      
      AtuTela()
   EndIf             
   ProcessMessage()
   Sleep(50)
End                  
Return   
     
Static Function CargaIni()
Local cEstTer           
Local cConteudo
Local cAnt
Local nI
Compatibiliza()
cIniFile := "TERGER"+cComutadora+".INI"
nQtdTer  := Val(GetPvProfString( "SETUP", "QTDTER" , "32", cIniFile ))
cPorta   := Alltrim(GetPvProfString( "SETUP","Portalpt" , "LPT1", cIniFile ))
cIP      := Alltrim(GetPvProfString( "SETUP","TcpIP" , "",cIniFile  ))
nTimeOut := Val(GetPvProfString( "SETUP", "Timeout" , "130", cIniFile ))   
PutGlbValue(Left(cIniFile,8),StrZero(nQtdTer,2)+Left(cPorta,4)+Padr(cIP,20)+Strzero(nTimeOut,5))
aTerm := {}
For nI := 1 to nQtdTer
   cEstTer		:= "TER"+StrZero(nI-1,2)
   cConteudo	:=""
   cConteudo	:= StrZero(val(GetPvProfString( cEstTer, "Terminal"	, StrZero(nI-1,2)	, cIniFile )),2)
   cConteudo	+=             GetPvProfString( cEstTer, "Status"		, "0"            	, cIniFile )
   cConteudo	+= StrZero(Val(GetPvProfString( cEstTer, "Paralela" 	, StrZero(nI-1,2)	, cIniFile )),2)
   cConteudo	+= StrZero(Val(GetPvProfString( cEstTer, "Serial" 	, StrZero(nI-1,2)	, cIniFile )),2)   
   cConteudo	+= Padr(       GetPvProfString( cEstTer, "Rotina" 	, "" 	           	, cIniFile ),20)   
   cConteudo	+=             GetPvProfString( cEstTer, "Empresa" 	, "99"           	, cIniFile )
   cConteudo	+=             GetPvProfString( cEstTer, "Filial" 	, "01"           	, cIniFile )
   cConteudo	+= Padr(       GetPvProfString( cEstTer, "Parametros", ""           	, cIniFile ),20)
   cConteudo	+=             GetPvProfString( cEstTer, "Simula" 	, "0"           	, cIniFile )
   cConteudo	+= Padr(       GetPvProfString( cEstTer, "Modulo" 	, ""           	, cIniFile ),3)
   cConteudo	+=             GetPvProfString( cEstTer, "Modelo" 	, "MT44"        	, cIniFile )   
   cAnt			:=  GetGlbValue("INI"+cComutadora+StrZero(nI-1,2))
   If ! Empty(cAnt)
      cConteudo := Stuff(cConteudo,3,1,Subs(cAnt,3,1))
   EndIf
   PutGlbValue("INI"+cComutadora+StrZero(nI-1,2),cConteudo)            
   
   aadd(aTerm,{})
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Terminal"	, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],Subs(cConteudo,3,1))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Paralela"	, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Serial"	, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Rotina"	, ""				, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Empresa"	, "99"				, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Filial" 	, "01"				, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Parametros", ""				, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Simula"    , "0"	  			, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Modulo"    , ""   				, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Modelo"    , "MT44" 			, cIniFile ))   
  
   aTerm[nI,01] := StrZero(Val(aTerm[nI,1]),2)
   aTerm[nI,02] := Val(aTerm[nI,2])
   aTerm[nI,03] := StrZero(Val(aTerm[nI,3]),2)
   aTerm[nI,04] := StrZero(Val(aTerm[nI,4]),2)
   aTerm[nI,05] := PadR(aTerm[nI,5],150)
   aTerm[nI,06] := PadR(aTerm[nI,6],2)
   aTerm[nI,07] := PadR(aTerm[nI,7],2)
   aTerm[nI,08] := PadR(aTerm[nI,8],150)
   aTerm[nI,09] := Val(aTerm[nI,9])
   aTerm[nI,10] := PadR(aTerm[nI,10],3)
   aTerm[nI,11] := PadR(aTerm[nI,11],4)   
Next
If Len(aTerm) == 0
   aadd(aTerm,{} )
   aadd(aTerm[1],"")
   aadd(aTerm[1],0)
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")
   aadd(aTerm[1],0)
   aadd(aTerm[1],"")
   aadd(aTerm[1],"")   
EndIf
Return .t.
                                                           
Static Function Ativa()
If ! lGerTime
   Return .t.
EndIf   
If lAtiva
   Return .f.
EndIf
If Empty(cIP)
   Alert(STR0034) //"Opcao disponivel apenas para conexao TCPIP!!!"
   Return
Else
   StartJob("TerCtrl",GetEnvServer(),.F.,cComutadora)      
   AtuTela()
EndIf
lAtiva:= .t.
Return

Static Function Desativa()                          
If ! lGerTime
   Return .t.
EndIf   

If lAtiva .and. MsgYesNo(STR0035+Chr(13)+Chr(10)+STR0036)  //"Voce ira desativar todos os microterminais On-Line."###"Confirma a operacao?"
   FErase("TERGER"+cComutadora+".ATV")
   lAtiva:= .f.
EndIf
Return     

Static Function TrataBut(nOpcao)
If ! lGerTime
   Return .t.
EndIf   
If nOpcao == 1 // Habilitar
   If aTerm[oTerm:nAt,2] <> 0 .and. aTerm[oTerm:nAt,2] <> 4
  	   MsgInfo(STR0037) //'Para Habitar necessario que o terminal esteja desabilitado'
      Return 
   EndIf                     
   aTerm[oTerm:nAt,2] := 1
   GravaCol(oTerm:nAt,"Status","1")
ElseIf nOpcao == 2 // Desabilitar                             
   If aTerm[oTerm:nAt,2] ==0
  	   MsgInfo(STR0038) //'Este Terminal ja esta Desabilitado!!!'
      Return 
   EndIf
   If MsgYesNo(STR0039)  //"Confirma a desconexao deste terminal?"
      WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Status"			, Str(0,1)	, cIniFile )   
      aTerm[oTerm:nAt,2] := 0     
      GravaCol(oTerm:nAt,"Status","0")      
   EndIf   
ElseIf nOpcao == 3 // Finalizar
   If aTerm[oTerm:nAt,2] <> 2
  	   MsgInfo(STR0040) //'Para finalizar necessario que o terminal esteja On-Line !!!'
      Return 
   EndIf
   If MsgYesNo(STR0041)     //"Confirma a finalizacao deste terminal?"
      aTerm[oTerm:nAt,2] := 3
      GravaCol(oTerm:nAt,"Status","3")      
      PutGlbValue("AGU"+cComutadora+StrZero(oTerm:nAt-1,2),"1")            
   EndIf      
EndIf
Return


Static Function AlteraTer()
Local oDlgPar
Local oSBr
Local nOpcao := 0
Local cEstTer := "TER"+StrZero(oTerm:nAt-1,2)

Local oParalela                                
Local oSerial
Local oRotina
Local oEmpresa
Local oFil
Local oParam
Local oSimula
Local oModulo                
Local oModelo

Local aSimula	:= {STR0006,STR0007} //"Nao"###"Sim"
Local aModelo	:= {"MT16","MT44"}

Local cParalela	:= GetPvProfString( cEstTer, "Paralela"		, StrZero(oTerm:nAt-1,2)	, cIniFile )
Local cSerial   := GetPvProfString( cEstTer, "Serial" 			, StrZero(oTerm:nAt-1,2)	, cIniFile )
Local cRotina   := Padr(GetPvProfString( cEstTer, "Rotina"	, ""                    	, cIniFile ),40)
Local cEmpresa  := GetPvProfString( cEstTer, "Empresa" 	 	, "99"	, cIniFile )
Local cFil      := GetPvProfString( cEstTer, "Filial"   	 	, "01"	, cIniFile )
Local cParam    := Padr(GetPvProfString( cEstTer, "Parametros",""	, cIniFile ),40)
Local cModulo   := Padr(GetPvProfString( cEstTer, "Modulo"  	, ""	, cIniFile ),3)
Local cModelo   := Padr(GetPvProfString( cEstTer, "Modelo"  	, "MT44"	, cIniFile ),4)

If ! lGerTime
   Return .t.
EndIf                 
If aTerm[oTerm:nAt,2] == 2 .or. aTerm[oTerm:nAt,2] == 3
   MsgAlert(STR0042) //"Necessario desativar este Microterminal para altera-lo!!!"
   Return 
Endif


DEFINE MSDIALOG oDlgPar TITLE STR0022+" ("+StrZero(oTerm:nAt-1,2)+")" FROM 26,43 TO 273,482 PIXEL  //"Terminal "

	@ 6,7 SCROLLBOX oSbr VERTICAL SIZE 94,206 OF oDlgPar BORDER
	oDlgPar:SetWallPaper("FUNDOBARRA")

 	@ 06,10 Say STR0043 PIXEL of oSbr  //"Porta Paralela"
	@ 05,70 MsGet oParalela Var cParalela Picture "99"  PIXEL of oSbr SIZE 120,09 VALID (Val(cParalela) <32 .and. Val(cParalela) >-1)
	
 	@ 21,10 Say STR0044 PIXEL of oSbr  //"Porta Serial"
	@ 20,70 MsGet oSerial Var cSerial Picture "99"  PIXEL of oSbr SIZE 120,09 VALID (Val(cSerial) <32 .and. Val(cSerial) >-1)

 	@ 36,10 Say STR0026 PIXEL of oSbr  //"Rotina"
	@ 35,70 MsGet oRotina Var cRotina Picture "@!"  PIXEL of oSbr SIZE 120,09 

 	@ 51,10 Say STR0027 PIXEL of oSbr  //"Empresa"
	@ 50,70 MsGet oEmpresa Var cEmpresa Picture "99"  PIXEL of oSbr SIZE 120,09 

 	@ 66,10 Say STR0028 PIXEL of oSbr  //"Filial"
	@ 65,70 MsGet oFil Var cFil Picture "99"  PIXEL of oSbr SIZE 120,09 

	@ 81,10 Say STR0029 PIXEL of oSbr  //"Parametros"
	@ 80,70 MsGet oParam Var cParam Picture "@!"  PIXEL of oSbr SIZE 120,09 

	@ 96,10 Say STR0030 PIXEL of oSbr  //"Modulo"
	@ 95,70 MsGet oModulo Var cModulo Picture "@!"  PIXEL of oSbr SIZE 120,09  

	@ 111,10 Say STR0031 PIXEL of oSbr  //"Modelo"
	@ 110,70 MSCOMBOBOX oModelo  VAR cModelo    ITEMS aModelo    SIZE 120,09 PIXEL OF oSbr  
	
DEFINE SBUTTON FROM 105,147 TYPE 1 ACTION (nOpcao:=1,oDlgPar:End()) OF oDlgPar ENABLE
DEFINE SBUTTON FROM 105,180 TYPE 2 ACTION (nOpcao:=0,oDlgPar:End()) OF oDlgPar ENABLE
ACTIVATE MSDIALOG oDlgPar CENTERED
If nOpcao ==1                                                                             
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Serial"		, cSerial, cIniFile )   
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Paralela"	, cParalela, cIniFile )   
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Rotina"		, cRotina, cIniFile )   
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Empresa"	, cEmpresa, cIniFile )      
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Filial"		, cFil, cIniFile )         
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Parametros", cParam, cIniFile )         
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Simula"		, "0", cIniFile )         
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Modulo"		, cModulo, cIniFile )         
   WritePPros("TER"+StrZero(oTerm:nAt-1,2), "Modelo"		, cModelo, cIniFile )                       
EndIf   
Return

Static Function Parametros()
Local oDlgPar
Local oSBr
Local nOpcao := 0

Local cPorta   	:= Padr(Alltrim(GetPvProfString( "SETUP","Portalpt" , "LPT1", cIniFile )),20)
Local oPorta               

Local cIP         := Padr(Alltrim(GetPvProfString( "SETUP","TcpIP" , "",cIniFile  )),20)
Local oIP

Local cQtde       := Padr(Alltrim(GetPvProfString( "SETUP", "QTDTER" , "32", cIniFile )),3)
Local oQtde

Local cTimeout    := Padr(Alltrim(GetPvProfString( "SETUP", "Timeout" , "130", cIniFile )),4)
Local otimeout      

If ! lGerTime
   Return .t.
EndIf   

If lAtiva                                  
	MsgInfo(STR0045) //'Para modificar os parametros e necessario desativar o processo'
   Return 
EndIf

DEFINE MSDIALOG oDlgPar TITLE STR0029 FROM 26,43 TO 273,482 PIXEL  //"Parametros "

	@ 6,7 SCROLLBOX oSbr VERTICAL SIZE 94,206 OF oDlgPar BORDER
	oDlgPar:SetWallPaper("FUNDOBARRA")

	@ 06,10 Say STR0046 PIXEL of oSbr  //"Porta LPT/TCPIP"
	@ 05,70 MsGet oPorta Var cPorta Picture "@!"  PIXEL of oSbr SIZE 120,09 Valid(if("LPT" $ cPorta,cIP:=Space(20),.t.),.t.)

	@ 21,10 Say STR0047 PIXEL of oSbr  //"TCPIP"
	@ 20,70 MsGet oIP Var cIP Picture "@ 99"  PIXEL of oSbr SIZE 120,09 when ! "LPT" $ cPorta

	@ 36,10 Say STR0048 PIXEL of oSbr  //"Qtde. de Terminais"
	@ 35,70 MsGet oQtde Var cQtde Picture "@ 99"  PIXEL of oSbr SIZE 120,09 Valid (Val(cQtde) <=32 .and. VAL(cQtde) >0)

	@ 51,10 Say STR0049 PIXEL of oSbr  //"Time Out"
	@ 50,70 MsGet oTimeout Var cTimeOut Picture "@ 9999"  PIXEL of oSbr SIZE 120,09 Valid (Val(cTimeOut) >0)

DEFINE SBUTTON FROM 105,147 TYPE 1 ACTION (nOpcao:=1,oDlgPar:End()) OF oDlgPar ENABLE
DEFINE SBUTTON FROM 105,180 TYPE 2 ACTION (nOpcao:=0,oDlgPar:End()) OF oDlgPar ENABLE
ACTIVATE MSDIALOG oDlgPar CENTERED
If nOpcao ==1           
   WritePPros( "SETUP","QTDTER"		,Alltrim(cQtde)		, cIniFile )
   WritePPros( "SETUP","Portalpt"	,Alltrim(cPorta)	, cIniFile )
   WritePPros( "SETUP","TcpIP"		,Alltrim(cIP)		, cIniFile )   
   WritePPros( "SETUP","Timeout"	,Alltrim(cTimeout)	, cIniFile )
EndIf   
Return                     


Static Function AtuTela(lForce)     
lAtiva:= File("TERGER"+cComutadora+".ATV") 
oMsgItem1:SetText(If(lAtiva,STR0050,STR0032)) //"Ativado"###"Desativado"
If Empty(cIP)                                             
   oMsgItem2:SetText( STR0033+cPorta )  //'Porta: '
Else
	oMsgItem2:SetText( STR0047+": "+AllTrim(cIP)+" "+cPorta )  //'TCPIP'
EndIf	
oMsgItem3:SetText( STR0009+': '+cComutadora )  //'Comutadora: '
oMsgItem1:refresh()     
oMsgItem2:refresh()
oMsgItem3:refresh()    
If lForce<>NIL
   oTerm:SetArray(aTerm)
EndIf
oTerm:Refresh()
Return .t.


Static Function MsgGet2( cTitle, cText, uVar, cIcoFile, bValidGet, cPict )
Local oDlg
Local lOk	:= .f.
Local oGet
DEFAULT uVar		:= ""
DEFAULT cText		:= ""
DEFAULT cTitle		:= STR0051 //"Atencao"
DEFAULT bValidGet	:= {||.T.}
DEFAULT cIcoFile	:= "WATCH"
DEFAULT cPict		:= ""
DEFINE MSDIALOG oDlg FROM 10, 20 TO 18, 49.5 TITLE cTitle //OF GetWndDefault()
@ 1, 5 SAY cText OF oDlg SIZE 30, 20
@ 2, 6 MSGET oGet VAR uVar SIZE 15, 10 OF oDlg PICTURE cPict valid len(Alltrim(uVar)) ==2
oGet:bGotFocus := {|| oGet:SetPos(0)}
oGet:Set3dLook()
oGet:bValid := bValidGet
@ 0.5, 1 ICON RESOURCE cIcoFile OF oDlg                                    
@ 4, 5 BUTTON STR0052 OF oDlg SIZE 35, 12 	ACTION If(len(Alltrim(uVar))#2,(alert(STR0053),.f.),( oDlg:End(), lOk := .T. )) //"&Ok"###"Comutadora invalida"
@ 4, 15 BUTTON STR0054 OF oDlg SIZE 35, 12 ACTION ( oDlg:End(), lOk := .F. ) CANCEL //"&Cancela"
ACTIVATE MSDIALOG oDlg CENTERED
Return lOk

Static Function GravaCol(ni,cColuna,uconteudo)
Local cString := GetGlbValue("INI"+cComutadora+StrZero(nI-1,2))
cString := Stuff(cString,3,1,uConteudo)
PutGlbValue("INI"+cComutadora+StrZero(nI-1,2),cString)
WritePPros("TER"+StrZero(nI-1,2),cColuna,uconteudo, cIniFile )   
Return                                                                        

Static Function Monitor()
Private lSaiMonitor := .f.
Private oMemo
Private cMemo:=""
Private cFile := "MON"+cComutadora+StrZero(oTerm:nAt-1,2)
If ! lGerTime
   Return .t.
EndIf   
If ! lAtiva
   MsgAlert(STR0055) //"Gerenciador destivado!!!"
   Return 
EndIf
If aTerm[oTerm:nAt,2] <> 2 .and. aTerm[oTerm:nAt,2] <> 3
   MsgAlert(STR0056) //"Microterminal destivado!!!"
   Return 
Endif
oFont  := TFont():New( "Mono AS", 14, 32, .F.,.T.,,,,,,,,,,, ) 
                    
PutGlbValue(cFile,"Load")

DEFINE MSDIALOG oDlg FROM 0,0 TO 130,700  Pixel TITLE OemToAnsi(STR0057+StrZero(oTerm:nAt-1,2)) //"Monitor Microterminal "
oDlg:lEscClose := .F.
@ 0,0 GET oMemo  VAR cMemo MEMO SIZE 380,50 OF oDlg PIXEL FONT oFont
oMemo:lReadOnly := .T.


TButton():New( 055, 005,STR0058, oDlg, {|| lSaiMonitor := .t.}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) //"Sair"

ACTIVATE MSDIALOG oDlg CENTERED ON INIT GerMonitor(oDlg) 
PutGlbValue(cFile,"")
Return .t.
Return

Static Function GerMonitor(oDlg)
lSaiMonitor   := .F.
While !lSaiMonitor
   ProcessMessage() 
   cMemo:= GetGlbValue(cFile)
   oMemo:Refresh() 
   sleep(100)
EndDo
oDlg:End()                        
Return .T.
                                                       
Static Function Compatibiliza()
Local cIniFile := "TERGER"+cComutadora+".INI"
Local cIniAnt  := "TERMINAL.INI"
Local uAux
Local nVersao
Local cEstTer
Local cEstTerAnt
Local nI

nVersao     := Val(GetPvProfString( "SETUP", "Versao" , "1", cIniAnt ))
If nVersao == 1
   uAux      := PadR(GetPvProfString( "SETUP", "Portalpt" , "LPT1", cIniAnt ),4)
   WritePPros( "SETUP", "Portalpt" , uAux, cIniFile )

   uAux     := GetPvProfString( "SETUP", "QTDTER" , "0", cIniAnt )
   WritePPros( "SETUP", "QTDTER" , uAux, cIniFile )

   uAux     := GetPvProfString( "SETUP", "Timeout" , "130", cIniAnt )
   WritePPros( "SETUP", "Timeout" , uAux, cIniFile )

   WritePPros( "SETUP", "Versao" , "2", cIniAnt )
   WritePPros( "SETUP", "Versao",  "2",cIniFile)

   For nI := 1 to 32
      cEstTer := "TER"+StrZero(nI-1,2)
      cEstTerAnt := "TER"+cComutadora+StrZero(nI-1,2)
      uAux := GetPvProfString( cEstTerAnt, "Terminal"	, StrZero(nI-1,2)	, cIniAnt )
      WritePPros( cEstTer, "Terminal" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Status"		, "0"            	   , cIniAnt )
      uAux := If(Upper(AllTrim(uAux))==STR0001,"0","1") //"DESABILITADO"
      WritePPros( cEstTer, "Status" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Serial"		, StrZero(nI-1,2)	, cIniAnt )
      WritePPros( cEstTer, "Serial" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Paralela"	, StrZero(nI-1,2)	, cIniAnt )
      WritePPros( cEstTer, "Paralela" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Rotina"		, ""						, cIniAnt )
      WritePPros( cEstTer, "Rotina" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Empresa"		, "99"					, cIniAnt )
      WritePPros( cEstTer, "Empresa" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Filial"   	, "01"					, cIniAnt )
      WritePPros( cEstTer, "Filial" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Parametros"	, ""						, cIniAnt )
      WritePPros( cEstTer, "Parametros" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Simula"    	, "0"	  				   , cIniAnt )
      uAux := If(Upper(AllTrim(uAux))=="SIM","1","0")
      WritePPros( cEstTer, "Simula" , uAux, cIniFile )
      uAux := GetPvProfString( cEstTerAnt, "Modulo"   	, ""   					, cIniAnt )
      WritePPros( cEstTer, "Modulo" , uAux, cIniFile )
   Next
EndIf

Return


Static Function MsLogin()
Local oBmp, oDlgLogin, oUsuario, oSenha, oBtnOk, oBtnCancel
Local cUserName := Padr("Administrador",25)
Local cSenha    := Space(20)
Local lOk       := .f.
DEFINE MSDIALOG oDlgLogin FROM  0,0 TO 150,280  Pixel TITLE OemToAnsi(STR0059) //"Login "
	oDlgLogin:lEscClose := .F.
	@ 000,000 BITMAP oBmp RESNAME "LOGIN" oF oDlgLogin SIZE 95,oDlgLogin:nBottom  NOBORDER WHEN .F. PIXEL
	@ 010,050 Say STR0060 PIXEL of oDlgLogin   FONT (TFont():New('Arial',, -11, .T., .T.) ) //"Usuario:"
	@ 018,050 GET oUsuario  VAR cUserName  SIZE 80, 8 OF oDlgLogin PIXEL FONT (TFont():New('Arial',, -11, .T., .T.) )
	@ 034,050 Say STR0061 PIXEL of oDlgLogin  FONT (TFont():New('Arial',, -11, .T., .T.) ) //"Senha:"
	@ 042,050 GET oSenha VAR cSenha PASSWORD  SIZE 80, 8 OF oDlgLogin PIXEL FONT (TFont():New('Arial',, -11, .T., .T.) )
	TButton():New( 060, 50,STR0052, oDlgLogin, {|| aUser := getUser(cUserName, cSenha),  IF(Empty(aUser),(lOk := .F.,  IW_Msgbox(STR0062) ), (lOk := .T.  ,oDlgLogin:End()) )	},38, 11,,, .F., .t., .F.,, .F.,,, .F. ) //"&Ok"###"Usuario Invalido!"
	TButton():New( 060, 90,STR0063, oDlgLogin, {|| lOk := .F. , oDlgLogin:End() }, 38, 11,,, .F., .t., .F.,, .F.,,, .F. ) //"&Cancelar"
ACTIVATE MSDIALOG oDlgLogin CENTERED   
Return lOk

Static Function getUser(cUserName, cSenha)
PswOrder(3)
PswSeek(cSenha)
__Ap5NoMv(.T.)
aUser			:= PswRet()
If Len(aUser) > 0
	If aUser[1,2]<>AllTrim(cUserName)
		aUser := {}
	EndIf
EndIf
Return aUser
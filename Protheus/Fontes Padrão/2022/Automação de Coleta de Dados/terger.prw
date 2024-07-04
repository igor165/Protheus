#INCLUDE "terger.ch" 
#include "PROTHEUS.CH"               
#INCLUDE "TCBROWSE.CH"
                       



STATIC aEstado    := Array(32)
STATIC aParametro := Array(32)
STATIC aTeclado   := Array(32)
STATIC aLin       := Array(32)
STATIC aCol       := Array(32)
STATIC aLinha1    := Array(32)
STATIC aLinha2    := Array(32)
STATIC aPicture   := Array(32)
STATIC aPosPic    := Array(32)
STATIC aWaitKbd   := Array(32)
STATIC aPPrinter  := Array(32)
STATIC aSPrinter  := Array(32)
STATIC aTerImp    := Array(32)
STATIC aTipImp    := Array(32)
STATIC aVelImp    := Array(32)
STATIC aImpLib    := Array(32)

STATIC lSai        := .T.
STATIC nTerminal   := 0
STATIC cComutadora := "00"
STATIC lConfig     := .F.
STATIC nHDll       := -1
STATIC cPorta      := "LPT1"
STATIC nTimeOut    := 0
STATIC oMemoSim
STATIC cMemoSim := Space(40)+Chr(13)+Chr(10)+Space(40)
STATIC oTerm
STATIC aTerm := {}
STATIC aBufferSimu := Array(32)

STATIC nHdlTer := -1

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerGer() ³ Autor ³ Eduardo Motta         ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gerenciador de Microterminais                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerGer()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerGer()
Local oPorta
Local aPorta      := {"LPT1","LPT2"}
Local oFont,oFont2,oFont3
Local cTerminal 	:= Space(002)
Local cStatus   	:= Space(010)
Local cParalela 	:= Space(002)
Local cSerial   	:= Space(002)
Local cRotina   	:= Space(150)
Local cEmpresa  	:= Space(002)
Local cFil      	:= Space(002)
Local cParametros := Space(150)
Local cModuloi    := Space(003)
Local oSimula
Local cSimula     := Space(005)
Local aSimula     := {STR0001,STR0002} //"Nao"###"Sim"
Local oTerminal
Local oStatus
Local oParalela
Local oSerial
Local oRotina
Local oEmpresa
Local oFil
Local oParametros
Local oModulo
Local cEstTer
Local bBlock := '{|x,w,cObj|Eval( &("{|y|"+x+":=y,"+cObj+":Refresh() }"),w,cObj )}'
Local bBlock2 := '{|x|Eval( &("{|y| "+y+" }"),x )}'
Local nQtdTer := 0
Local aStatus := {STR0003,STR0004,STR0005,STR0006,STR0007} //"Desabilitado"###"Off-Line"###"On-Line"###"Finalizando"###"Finalizado"
Local nI
Local oAtiva
Local oDesativa
Local oHabilitar
Local oDesabilitar
Local oFinalizar
Local oTestaConexao
Local oComutadora
Local oEnter
Local oUp,oDown
Local bBlockBut
Local cCar
Local oEspaco

PUBLIC oMainwnd 

nHDll := ExecInDLLOpen("TerGer.DLL")
If nHDll == -1
	MsgStop(STR0008) //"Falha ao carregar a DLL 'TERGER.DLL'. Ela deve estar junto as DLLs da Wilbor-Gradual"
   Return ""
EndIf

PRIVATE AdvFont
PRIVATE __cInterNet := Nil
Private nModulo := 99
Private cModulo := ""
Private cVersao := GetVersao()
Private tInicio   := TIME()  
Private cUserName :=""
SetsDefault()
DEFINE FONT AdvFont Name "MS Sans Serif" SIZE 0, -9
DEFINE FONT oFont		Name "Arial"			Size 0,-16 BOLD
DEFINE FONT oFont2	Name "Arial"			Size 0,-12 BOLD
DEFINE FONT oFont3	Name "Courier New"	Size 0,-25 BOLD

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
For nI := 1 to 32
   aLinha1[nI]   := Space(20)
   aLinha2[nI]   := Space(20)
Next

DEFINE WINDOW oMainWnd FROM 0, 0 TO 240,310 PIXEL TITLE  OemToAnsi(STR0009)  NOMAXIMIZE //"Gerenciador de Microterminais"
oMainWnd:oFont := AdvFont
oMainWnd:nClrText := 0
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)                 


oMainWnd:lEscClose := .F.

@ 07,05 Say STR0010 PIXEL of oMainWnd FONT oFont //"Comutadora"
@ 06,55 MsGet oComutadora Var cComutadora Picture "@!" Valid CargaIni(@nQtdTer) PIXEL of oMainWnd FONT oFont SIZE 10,10
@ 07,105 Say STR0011      PIXEL of oMainWnd FONT oFont //"Porta"
@ 05,135 MSCOMBOBOX oPorta    VAR cPorta    ITEMS aPorta    SIZE 40,09 PIXEL OF oMainWnd FONT oFont
oPorta:bChange := {||GravaIni(nQtdTer)}

@ 20,00 GET oMemoSim  VAR cMemoSim MEMO SIZE 305,35 OF oMainWnd PIXEL FONT oFont3
oMemoSim:lReadOnly := .T.
oMemoSim:bGotFocus := {|| oEnter:SetFocus()}

@ 57,00 LISTBOX oTerm FIELDS HEADER STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021 SIZE 305,100 of oMainWnd PIXEL //"Terminal"###"Status"###"Paralela"###"Serial"###"Rotina"###"Empresa"###"Filial"###"Parametros"###"Simula"###"Modulo"
oTerm:SetArray(aTerm)
oTerm:bLine := {|| {aTerm[oTerm:nAt,1],aStatus[aTerm[oTerm:nAt,2]+1],aTerm[oTerm:nAt,3],aTerm[oTerm:nAt,4],aTerm[oTerm:nAt,5],aTerm[oTerm:nAt,6],aTerm[oTerm:nAt,7],aTerm[oTerm:nAt,8],aSimula[aTerm[oTerm:nAt,9]+1],aTerm[oTerm:nAt,10] }}
oTerm:bChange := {||AtuTel(&bBlock,aStatus,aSimula,oHabilitar,oDesabilitar,oFinalizar,oTestaConexao,oEspaco),AtuSimu()}

ADD COLUMN TO oTerm HEADER STR0012 	OEM DATA {|| aTerm[oTerm:nAt,01] }	ALIGN LEFT SIZE 25 	PIXELS  //"Terminal"
ADD COLUMN TO oTerm HEADER STR0013	OEM DATA {|| aStatus[aTerm[oTerm:nAt,2]+1] } ALIGN LEFT SIZE 40  	PIXELS //"Status"
ADD COLUMN TO oTerm HEADER STR0014	OEM DATA {|| aTerm[oTerm:nAt,03] } ALIGN LEFT SIZE 25		PIXELS  //"Paralela"
ADD COLUMN TO oTerm HEADER STR0015	OEM DATA {|| aTerm[oTerm:nAt,04] } ALIGN LEFT SIZE 40		PIXELS  //"Serial"
ADD COLUMN TO oTerm HEADER STR0016	OEM DATA {|| aTerm[oTerm:nAt,05] } ALIGN LEFT SIZE 40		PIXELS  //"Rotina"
ADD COLUMN TO oTerm HEADER STR0017 	OEM DATA {|| aTerm[oTerm:nAt,06] } ALIGN LEFT SIZE 40		PIXELS  //"Empresa"
ADD COLUMN TO oTerm HEADER STR0018	OEM DATA {|| aTerm[oTerm:nAt,07] } ALIGN LEFT SIZE 25		PIXELS  //"Filial"
ADD COLUMN TO oTerm HEADER STR0019	OEM DATA {|| aTerm[oTerm:nAt,08] } ALIGN LEFT SIZE 40		PIXELS  //"Parametros"
ADD COLUMN TO oTerm HEADER STR0020	OEM DATA {|| aSimula[aTerm[oTerm:nAt,9]+1] } ALIGN LEFT SIZE 40		PIXELS  //"Simula"
ADD COLUMN TO oTerm HEADER STR0021	OEM DATA {|| aTerm[oTerm:nAt,10] } ALIGN LEFT SIZE 40		PIXELS  //"Modulo"                 

@ 160,005 Say STR0012 	PIXEL FONT oFont2 //"Terminal"
@ 160,130 Say STR0013   	PIXEL FONT oFont2 //"Status"
@ 171,005 Say STR0014 	PIXEL FONT oFont2 //"Paralela"
@ 171,130 Say STR0015   	PIXEL FONT oFont2 //"Serial"
@ 182,005 Say STR0016   	PIXEL FONT oFont2 //"Rotina"
@ 193,005 Say STR0017  	PIXEL FONT oFont2 //"Empresa"
@ 193,130 Say STR0018   	PIXEL FONT oFont2 //"Filial"
@ 204,005 Say STR0019	PIXEL FONT oFont2 //"Parametros"
@ 215,005 Say STR0021    	PIXEL FONT oFont2 //"Modulo"
@ 215,130 Say STR0020		PIXEL FONT oFont2 //"Simula"

@ 158,045 MsGet oTerminal    VAR cTerminal 		Picture "@!" 	PIXEL SIZE 10,08 When .F.
@ 158,160 MsGet oStatus      VAR cStatus   		Picture "@!" 	PIXEL SIZE 30,08 When .F.
@ 169,045 MsGet oParalela    VAR cParalela 		Picture "@!" 	PIXEL SIZE 10,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,3]:=cParalela,GravaIni(nQtdTer))
@ 169,160 MsGet oSerial      VAR cSerial   		Picture "@!" 	PIXEL SIZE 10,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,4]:=cSerial,GravaIni(nQtdTer))
@ 180,045 MsGet oRotina      VAR cRotina   		Picture "@!" 	PIXEL SIZE 80,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,5]:=cRotina,GravaIni(nQtdTer))
@ 191,045 MsGet oEmpresa     VAR cEmpresa  		Picture "@!" 	PIXEL SIZE 10,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,6]:=cEmpresa,GravaIni(nQtdTer))
@ 191,160 MsGet oFil         VAR cFil      		Picture "@!" 	PIXEL SIZE 10,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,7]:=cFil,GravaIni(nQtdTer))
@ 202,045 MsGet oParametros  VAR cParametros            		   PIXEL SIZE 80,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,8]:=cParametros,GravaIni(nQtdTer))
@ 213,045 MsGet oModulo      VAR cModuloi   		Picture "@!" 	PIXEL SIZE 15,08 When Str(aTerm[oTerm:nAt,2],1)$"0_1_4" Valid (aTerm[oTerm:nAt,10]:=cModuloi,GravaIni(nQtdTer))
@ 213,160 MSCOMBOBOX oSimula VAR cSimula   ITEMS aSimula   SIZE 40,09 PIXEL OF oMainWnd
oSimula:bChange := {|| aTerm[oTerm:nAt,9]:=oSimula:nAt-1,GravaIni(nQtdTer),ChkSimu()}

oAtiva    := TButton():New( 005, 265, STR0022   		, oMainWnd, {|| Gerencia(nQtdTer,oAtiva,oDesativa,oComutadora,oPorta)}, 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Ativar"
oDesativa := TButton():New( 005, 265, STR0023   	, oMainWnd, {|| Desativa(oAtiva,oDesativa,oComutadora,oPorta)}      , 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Desativar"
oDesativa:Hide()

oHabilitar    :=TButton():New( 159, 265, STR0024		, oMainWnd, {|| TrataBut(1)}, 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Habilitar"
oDesabilitar  :=TButton():New( 176, 265, STR0025		, oMainWnd, {|| TrataBut(2)}, 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Desabilitar"
oFinalizar    :=TButton():New( 193, 265, STR0026		, oMainWnd, {|| TrataBut(3)}, 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Finalizar"
oFinalizar:Hide()
oTestaConexao :=TButton():New( 210, 265, STR0034	, oMainWnd, {|| ChkConexao()}, 40, 12,,, .F., .T., .F.,, .F., {|| .T.},, .F. ) //"Testar conexao"
oEspaco := TButton():New( 210, 265, STR0027, oMainWnd, {|| TerTec(Chr(32),oEnter)}, 40, 12,,, .F., .T., .F.,, .F.,,, .F. ) //"ESPACO"
oEspaco:Hide()



/// OS BOTOES ABAIXO NAO APARECEM NO DIALOGO
oUp    := TButton():New( 065, 1205, "UP", oMainWnd, , 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
oUp:bGotFocus := {|| oEnter:SetFocus()}

oEnter  := TButton():New( 065, 1205, "ENTER", oMainWnd, {|| TerTec(Chr(13),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

oDown  := TButton():New( 065, 1205, "DOWN", oMainWnd, , 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
oDown:bGotFocus := {|| oEnter:SetFocus()}

TButton():New( 095, 1205, "&"+Chr(27)+"ESC", oMainWnd, {|| TerTec(Chr(27),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
TButton():New( 125, 1205, "&"+Chr(08)+"BACKSPACE", oMainWnd, {|| TerTec(Chr(08),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

For nI := 0 to 9
   cCar := Str(nI,1)
   bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
   TButton():New( 135+(nI*10), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next   
For nI := 65 to 90
   cCar := Chr(nI)
   bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
   TButton():New( 135+(nI*100), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next   
For nI := 97 to 122
   cCar := Chr(nI)
   bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
   TButton():New( 135+(nI*100), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next   

cCar := Chr(23)
bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

cCar := "."
bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

cCar := ","
bBlockBut := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oMainWnd, bBlockBut, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )


ACTIVATE WINDOW oMainWnd valid (ExecInDLLClose(nHDll),Final(STR0037))//"Termino Normal"
RELEASE OBJECTS oFont 
Return

Static Function ChkSimu()
Local nLinAtu
Local nColAtu
Local nTerm := oTerm:nAt

If aTerm[nTerm,9] == 1 .and. lConfig
   aTerm[nTerm,9] := 0
   aBufferSimu[nTerm] := ""   
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C000")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+PadC(STR0028,40)) //"Aguarde... Microterminal"
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C100")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+PadC(STR0029,40)) //"sob controle do gerenciador."
   aTerm[oTerm:nAt,9] := 1    
ElseIf aTerm[nTerm,9] == 0 .and. ! lSai
   nLinAtu := aLin[nTerm]
   nColAtu := aCol[nTerm]-1
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C000")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+aLinha1[nTerm])
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C100")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+aLinha2[nTerm])
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C"+Str(nLinAtu,1)+StrZero(nColAtu,2))
   While Acesso(StrZero(nTerm-1,2),3) # 0
   EndDo
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerTec     ³ Autor ³ Eduardo Motta        ³ Data ³ 30/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Envia as teclas digitadas para o processamento             ³±±
±±³          ³ ela e' parecida com a mesma do DEBUG com a diferenca que   ³±±
±±³          ³ retorna o valor numerico do caracter na tabela ASCII       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerTec(cGet,oGet)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TerTec(cGet,oGet)
If cGet == Chr(27)
   cGet := Chr(127)
EndIf   
If aTerm[oTerm:nAt,9] == 1   // somente acrescenta se estiver em modo simulacao
   aBufferSimu[oTerm:nAt]+=cGet
EndIf   
oGet:SetFocus()
Return .f.



Static Function TrataBut(nOpcao)
If nOpcao == 1 // Habilitar
   aTerm[oTerm:nAt,2] := 1
ElseIf nOpcao == 2 // Desabilitar
   aTerm[oTerm:nAt,2] := 0
   GeraFim(oTerm:nAt)
ElseIf nOpcao == 3 // Finalizar
   aTerm[oTerm:nAt,2] := 3
   GeraFim(oTerm:nAt,.f.)   
EndIf
oTerm:Refresh()
Eval(oTerm:bChange)
Return

Static Function AtuSimu()
cMemoSim := aLinha1[oTerm:nAt]+Chr(13)+Chr(10)+aLinha2[oTerm:nAt]
oMemoSim:Refresh()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ChkConexao³ Autor ³ Eduardo Motta         ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao que efetua um teste de conexao no microterminal     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerGer()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChkConexao()
Local nTerm := oTerm:nAt
If aTerm[nTerm,9] == 1   // se microterminal estiver em modo simulacao
   MsgStop(STR0030) //" Este microterminal esta em modo simulacao !!! "
   Return
EndIf
Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
Acesso(Chr(254)+StrZero(nTerm-1,2)+"C000")
Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+Padc("MICROSIGA SOFTWARE S/A",40))
Acesso(Chr(254)+StrZero(nTerm-1,2)+"C100")
Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+Padc(STR0031,40)) //"TESTE DE CONEXAO. OK"
aLinha1[nTerm] := PadC("MICROSIGA SOFTWARE S/A",40)
aLinha2[nTerm] := PadC(STR0031,40) //"TESTE DE CONEXAO. OK"
Acesso(Chr(254)+StrZero(nTerm-1,2)+"A"+Chr(15))
Sleep(100)
Acesso(Chr(254)+StrZero(nTerm-1,2)+"A"+Chr(0))
Eval(oTerm:bChange)
oTerm:Refresh()
Return

Static Function AtuTel(bBlock,aStatus,aSimula,oHabilitar,oDesabilitar,oFinalizar,oTestaConexao,oEspaco)
Local nPos := oTerm:nAt
Eval(bBlock,"cTerminal"		,aTerm[nPos,01],"oTerminal")
Eval(bBlock,"cStatus"		,aStatus[aTerm[nPos,02]+1],"oStatus")
Eval(bBlock,"cParalela"		,aTerm[nPos,03],"oParalela")
Eval(bBlock,"cSerial"		,aTerm[nPos,04],"oSerial")
Eval(bBlock,"cRotina"		,aTerm[nPos,05],"oRotina")
Eval(bBlock,"cEmpresa"		,aTerm[nPos,06],"oEmpresa")
Eval(bBlock,"cFil"			,aTerm[nPos,07],"oFil")
Eval(bBlock,"cParametros"	,aTerm[nPos,08],"oParametros")
Eval(bBlock,"cSimula"    	,aSimula[aTerm[nPos,09]+1],"oSimula")
Eval(bBlock,"cModuloi"    	,aTerm[nPos,10],"oModulo")

If aTerm[nPos,2] == 0         // Desabilitado
   oHabilitar:Show()
   oDesabilitar:Hide()
   oFinalizar:Hide()
   oTestaConexao:Show()
   oEspaco:Hide()   
ElseIf aTerm[nPos,2] == 1  // Off-Line
   oHabilitar:Hide()
   oDesabilitar:Show()
   oFinalizar:Hide()
   oTestaConexao:Show()
   oEspaco:Hide()   
ElseIf aTerm[nPos,2] == 2  // On-Lineo
   oHabilitar:Hide()
   oDesabilitar:Show()
   oFinalizar:Show()
   oTestaConexao:Hide()
   If aTerm[nPos,9] == 1
      oEspaco:Show()
   Else   
      oEspaco:Hide()
   EndIf   
ElseIf aTerm[nPos,2] == 3  // Finalizando
   oHabilitar:Hide()
   oDesabilitar:Show()
   oFinalizar:Hide()
   oTestaConexao:Hide()
   If aTerm[nPos,9] == 1
      oEspaco:Show()
   Else   
      oEspaco:Hide()
   EndIf   
ElseIf aTerm[nPos,2] == 4  // Finalizado
   oHabilitar:Show()
   oDesabilitar:Show()
   oFinalizar:Hide()
   oTestaConexao:Show()
   oEspaco:Hide()
EndIf

Return

Static Function CargaIni(nQtdTer)
Local nI
Local bLine
Local cIniFile := "TERGER"+cComutadora+".INI"

If nHdlTer # -1
   FClose(nHdlTer)
EndIf
nHdlTer := FCreate("TERGER"+cComutadora+".LCK")
If nHdlTer == -1
   MsgStop(STR0032) //" Esta comutadora ja esta sendo gerenciada. "
   Return .F.
EndIf

Compatibiliza()

cPorta      := PadR(GetPvProfString( "SETUP", "Portalpt" , "LPT1", cIniFile ),4)
nQtdTer     := Val(GetPvProfString( "SETUP", "QTDTER" , "32", cIniFile ))
nTimeOut    := Val(GetPvProfString( "SETUP", "Timeout" , "130", cIniFile ))

If nQtdTer < 1
   nQtdTer := 32
EndIf

aTerm := {}
For nI := 1 to nQtdTer
   cEstTer := "TER"+StrZero(nI-1,2)
   aadd(aTerm,{})
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Terminal"	, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Status"		, "0"            	   , cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Serial" 		, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Paralela"	, StrZero(nI-1,2)	, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Rotina"		, ""						, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Empresa"		, "99"					, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Filial" 		, "01"					, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Parametros", ""						, cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Simula"    , "0"	  				   , cIniFile ))
   aadd(aTerm[nI],GetPvProfString( cEstTer, "Modulo"    , ""   					, cIniFile ))
  
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
EndIf

GravaIni(nQtdTer)

bLine := oTerm:bLine
oTerm:SetArray(aTerm)
oTerm:bLine := bLine
oTerm:Refresh()
Eval(oTerm:bChange)

Return

Static Function GravaIni(nQtdTer)
Local cIniFile := "TERGER"+cComutadora+".INI"
Local bLine
Local nI

WritePPros( "SETUP", "Portalpt" , cPorta, cIniFile )
WritePPros( "SETUP", "QTDTER" , AllTrim(Str(nQtdTer,5)), cIniFile )
WritePPros( "SETUP", "Timeout" , AllTrim(Str(nTimeOut,5)), cIniFile )

For nI := 1 to Len(aTerm)
   cEstTer := "TER"+StrZero(nI-1,2)
   WritePPros( cEstTer, "Terminal"		, aTerm[nI,01]  			, cIniFile )
   WritePPros( cEstTer, "Status"			, Str(aTerm[nI,02],1)	, cIniFile )
   WritePPros( cEstTer, "Serial" 		, aTerm[nI,03]			, cIniFile )
   WritePPros( cEstTer, "Paralela"		, aTerm[nI,04]			, cIniFile )
   WritePPros( cEstTer, "Rotina"			, aTerm[nI,05]			, cIniFile )
   WritePPros( cEstTer, "Empresa"		, aTerm[nI,06]			, cIniFile )
   WritePPros( cEstTer, "Filial"			, aTerm[nI,07]			, cIniFile )
   WritePPros( cEstTer, "Parametros"	, aTerm[nI,08]			, cIniFile )
   WritePPros( cEstTer, "Simula"    	, Str(aTerm[nI,09],1)	, cIniFile )
   WritePPros( cEstTer, "Modulo"    	, aTerm[nI,10]			, cIniFile )
Next

If ValType(oTerm) == "O"
   bLine := oTerm:bLine
   oTerm:SetArray(aTerm)
   oTerm:bLine := bLine
   oTerm:Refresh()
EndIf

Return


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
      uAux := If(Upper(AllTrim(uAux))=="DESABILITADO","0","1")
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

Static Function Gerencia(nQtdTer,oAtiva,oDesativa,oComutadora,oPorta)
Local nI := 0
nI := 0
oAtiva:Hide()
oDesativa:Show()

oComutadora:bWhen := {||.F.}
oPorta:lReadOnly := .t.
TerIsVarGbl(.f.)

If lSai
   aBufferSimu := Array(32)
   For nI := 1 to 32
      aBufferSimu[nI] := ""
      aEstado[nI]   := 1
      aTeclado[nI]  := ""
      aLin[nI]      := 0
      aCol[nI]      := 0
      aLinha1[nI]   := Space(20)
	   aLinha2[nI]   := Space(20)
	   aPicture[nI]  := ""
	   aPosPic[nI]   := 1
	   aWaitKbd[nI]  := .f.
	   aPPrinter[nI] := ""
	   aSPrinter[nI] := ""
	   aTerImp[nI]   := 0
	   aTipImp[nI]   := ""
	   aVelImp[nI]   := 3
	   aImpLib[nI]   := .T.
	Next
	lSai   := .F.
	While !lSai
  	   ProcessMessage()
	   Trata(nQtdTer)
      sleep(10)
	EndDo
	For nI := 1 to nQtdTer
	   If aTerm[nI,02] == 2 .or. aTerm[nI,02] == 4
   	   GeraFim(nI)
         aTerm[nI,02] := 1
         Eval(oTerm:bChange)
         oTerm:Refresh()
      EndIf
	Next
	GravaIni(nQtdTer)
Else
   lSai := .T.
EndIf	

Return .T.

Static Function Desativa(oAtiva,oDesativa,oComutadora,oPorta)
If MsgYesNo(STR0035+Chr(13)+Chr(10)+STR0036) //"Voce ira desativar todos os microterminais On-Line."###"Confirma a operacao?"
   lSai := .T.
   oAtiva:Show()
   oDesativa:Hide()
   oComutadora:bWhen := {||.T.}
   oPorta:lReadOnly := .F.
EndIf
Return

Static Function GeraFim(nTerm,lAbort)
DEFAULT lAbort := .T.
If lAbort
   TerAbort("TER"+cComutadora+StrZero(nTerm-1,2)+".FIM")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"L")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C000")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+Padc("MICROSIGA SOFTWARE S/A",40))
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"C100")
   Acesso(Chr(254)+StrZero(nTerm-1,2)+"D"+Padc(STR0033,40)) //"MICROTERMINAL FINALIZADO"
   aLinha1[nTerm] := PadC("MICROSIGA SOFTWARE S/A",40)
   aLinha2[nTerm] := PadC(STR0033,40) //"MICROTERMINAL FINALIZADO"
Else
   TerAbort("TER"+cComutadora+StrZero(nTerm-1,2)+".AGU")
EndIf
Eval(oTerm:bChange)
oTerm:Refresh()
Return

Static Function Trata(nQtdTer)
Local nI
Local cResult
Local nL1,nC1
Local nL2,nC2

AtuSimu()

For nI := 1 to nQtdTer
   nTerminal := nI-1
   If aTerm[nI,2] == 1 .and. !Empty(aTerm[nI,5])
      TerInicio("TER"+cComutadora+StrZero(nTerminal,2))
      aTerm[nI,2] := 2
      Eval(oTerm:bChange)
      oTerm:Refresh()
      StartJob("TERJOB",GetEnvServer(),.F.,aTerm[nI,6],aTerm[nI,7],cComutadora,aTerm[nI,1],AllTrim(aTerm[nI,5]),aTerm[nI,10],aTerm[nI,8])
   EndIf
   
   GFlushprn()
   GFlushcom()

   If aTerm[nI,2] # 2 .and. aTerm[nI,2] # 3
      Loop
   EndIf
   
   If aEstado[nI] == 1    // Leitura de solicitacoes
      cResult := TerRet(cComutadora+StrZero(nTerminal,2))
      If SubStr(cResult,1,1) == "E"
         aEstado[nI] := Val(SubStr(cResult,2,2))
         aParametro[nI] := SubStr(cResult,4)
      EndIf      
   ElseIf aEstado[nI] == 2    // Retorno de solicitacoes
      TerCria(cComutadora+StrZero(nTerminal,2)+"R"+aTeclado[nI])
      aEstado[nI] := 1
   ElseIf aEstado[nI] == 3    // Funcao Limpa Tela
      GClear()
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 4    // Posiciona o Cursor
      GPosCursor(Val(SubStr(aParametro[nI],1,2)),Val(SubStr(aParametro[nI],3,2)))
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 5    // Display
      GDisplay(aParametro[nI])
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 6    // Carrega picture
      GGet(aParametro[nI])
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 7    // GET
      If GTrataTecla()  
         aEstado[nI]  := 2
      EndIf   
   ElseIf aEstado[nI] == 8    // Inkey
      aTeclado[nI]:=Chr(GPedeTecla())
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 9    // Setup
      If Empty(SubStr(aParametro[nTerminal+1],1,2))
         If SubStr(aParametro[nTerminal+1],3,1) == "P"
            aTerImp[nTerminal+1] := Val(aTerm[nTerminal+1,3])+1
         Else
            aTerImp[nTerminal+1] := Val(aTerm[nTerminal+1,4])+1
         EndIf
      Else
         aTerImp[nTerminal+1] := Val(SubStr(aParametro[nTerminal+1],1,2))
      EndIf
      aTipImp[nTerminal+1] := SubStr(aParametro[nTerminal+1],3,1)
      If aImpLib[aTerImp[nTerminal+1]]
         If !Empty(SubStr(aParametro[nTerminal+1],4,2))
            aVelImp[aTerImp[nTerminal+1]] := Val(SubStr(aParametro[nTerminal+1],4,2))
         EndIf
         aImpLib[aTerImp[nTerminal+1]] := .F.
         aEstado[nI]  := 2
      EndIf
   ElseIf aEstado[nI] == 10    // TerPrint
      If !Empty(aTipImp[nTerminal+1]) .and. (aTerImp[nTerminal+1] > 0)
         If aTipImp[nTerminal+1] == "P"
            If Empty(aPPrinter[aTerImp[nTerminal+1]])
               aPPrinter[aTerImp[nTerminal+1]] += aParametro[nTerminal+1]
               aEstado[nTerminal+1] := 2
            EndIf   
         Else
            If Empty(aSPrinter[aTerImp[nTerminal+1]])
               aSPrinter[aTerImp[nTerminal+1]] += aParametro[nTerminal+1]
               aEstado[nTerminal+1] := 2
            EndIf   
         EndIf
      EndIf
   ElseIf aEstado[nI] == 11    // TerPEnd()
      aImpLib[aTerImp[nTerminal+1]] := .T.
      aTerImp[nTerminal+1] := 0
      aTipImp[nTerminal+1] := ""
      aEstado[nTerminal+1]   := 2
   ElseIf aEstado[nI] == 12    // Finalizando
      aTerm[nI,2] := 4
      GeraFim(nI)
      aEstado[nI]  := 1
   ElseIf aEstado[nI] == 13    // Beep
      GBeep()
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 14    // SaveScreen
      nL1 := Val(SubStr(aParametro[nI] ,1,1))
      nC1  := Val(SubStr(aParametro[nI],2,2))
      nL2 := Val(SubStr(aParametro[nI] ,4,1))
      nC2  := Val(SubStr(aParametro[nI],5,2))
      aTeclado[nI] := ""
      If nL1 == 0
         aTeclado[nI] += SubStr(aLinha1[nI],nC1,nC2-nC1+1)
      EndIf
      If nL2 == 1
         aTeclado[nI] += SubStr(aLinha2[nI],nC1,nC2-nC1+1)
      EndIf      
      aEstado[nI]  := 2
   ElseIf aEstado[nI] == 15    // Carrega Get
      ValueGet(aParametro[nI])
      aEstado[nI]  := 2
   EndIf
Next

Return


////---------------
// funcoes de controle interno ref. ao microterminal
////---------------


Static Function GFlushPrn()
Local cAux := ""
Local nX := 0
Local nY := 0

If aVelImp[nTerminal+1] == 0
   aVelImp[nTerminal+1] := 3
EndIf

nX := 1
While nX <= Len(aPPrinter[nTerminal+1]) .and. nX <= (aVelImp[nTerminal+1]*25)
   cAux := SubStr(aPPrinter[nTerminal+1],nX,1)
   If Acesso(Chr(254)+StrZero(nTerminal,2)+"I"+cAux)#0
      nY := 0
      nX++
   Else
      nY++
   EndIf
   If nY > 3
      Exit
   EndIf
EndDo
aPPrinter[nTerminal+1] := SubStr(aPPrinter[nTerminal+1],nX)

Return

Static Function GFlushCom()
Local cAux := ""
Local nX := 0
Local nY := 0
If aVelImp[nTerminal+1] == 0
   aVelImp[nTerminal+1] := 3
EndIf
nX := 1
While nX <= Len(aSPrinter[nTerminal+1]) .and. nX <= (aVelImp[nTerminal+1]*25)
   cAux := SubStr(aSPrinter[nTerminal+1],nX,1)
   If Acesso(Chr(254)+StrZero(nTerminal,2)+"R"+cAux)#0
      nY := 0
      nX++
   Else
      nY++
   EndIf
   If nY > 3
      Exit
   EndIf
EndDo
aSPrinter[nTerminal+1] := SubStr(aSPrinter[nTerminal+1],nX)
Return

Static Function GClear()
Acesso(Chr(254)+StrZero(nTerminal,2)+"L")
Acesso(Chr(254)+StrZero(nTerminal,2)+"L")
aLinha1[nTerminal+1] := Space(40)
aLinha2[nTerminal+1] := Space(40)
aLin[nTerminal+1]    := 0
aCol[nTerminal+1]    := 0
Return

Static Function GPosCursor(nLin,nCol)
Acesso(Chr(254)+StrZero(nTerminal,2)+"C"+Str(nLin,1)+StrZero(nCol,2))
aLin[nTerminal+1]    := nLin
aCol[nTerminal+1]    := nCol+1
Return

Static Function GDisplay(cStr)
Local cLinha1,cLinha2
Local nCol
Local cStrAnt
cLinha1 := aLinha1[nTerminal+1]
cLinha2 := aLinha2[nTerminal+1]
nCol    := aCol[nTerminal+1]
cStrAnt := cStr
Acesso(Chr(254)+StrZero(nTerminal,2)+"D"+cStr)
If cStr == Chr(08)
   cStr := " "
   nCol := If(nCol#0,nCol-1,nCol)
EndIf
If aLin[nTerminal+1] == 0
   aLinha1[nTerminal+1] := Stuff(cLinha1,nCol,Len(cStr),cStr)
EndIf
If aLin[nTerminal+1] == 1
   aLinha2[nTerminal+1] := Stuff(cLinha2,nCol,Len(cStr),cStr)
EndIf
If cStrAnt == Chr(08)   // se for backspace
   aCol[nTerminal+1] -= 1
Else   
   aCol[nTerminal+1] += Len(cStr)
EndIf
Return

Static Function GBeep(nVezes)
Acesso(Chr(254)+StrZero(nTerminal,2)+"A"+Chr(15))
Sleep(100)
Acesso(Chr(254)+StrZero(nTerminal,2)+"A"+Chr(0))
Return

Static Function GPedeTecla()
Local nTecla := 0
If aTerm[nTerminal+1,9] == 0
   nTecla := Acesso(StrZero(nTerminal,2),3)
Else
   If Len(aBufferSimu[nTerminal+1]) >= 1
      nTecla      := Asc(SubStr(aBufferSimu[nTerminal+1],1,1))
      aBufferSimu[nTerminal+1] := SubStr(aBufferSimu[nTerminal+1],2)
   EndIf   
EndIf   
Return nTecla

Static Function Acesso(cStr,nTipo)
Local cPar,nRet
Local nTerm := Val(SubStr(cStr,2,3))
DEFAULT nTipo := 2
If aTerm[nTerm+1,9] == 1   // se microterminal estiver em simulacao
   Return 0
EndIf
If !lConfig
   cPar := SubStr(cPorta,4,1)+StrZero(nTimeOut,5)
   nRet := ExeDLLRun2(nHDll, 1, cPar )
   lConfig := .T.
EndIf
Return ExeDLLRun2(nHDll, nTipo, cStr)

Static Function GGet(cPicture)
If !aWaitKbd[nTerminal+1]
   aWaitKbd[nTerminal+1] := .f. 
   aPosPic[nTerminal+1]  := 1
   aPicture[nTerminal+1] := cPicture
EndIf
Return
                                          	
Static Function ValueGet(cValor) 
If !aWaitKbd[nTerminal+1]
   aWaitKbd[nTerminal+1] := .t. 
   aTeclado[nTerminal+1] := cValor
EndIf
Return


Static Function GTrataTecla()
Local cPic,cTecla,nTamanho
Local lRet := .F.                              
Local nPosPonto
Local nDec     
Local nCol,nLin
While .t.
   cTecla := Chr(GPedeTecla())
   cPic := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1],1)
	If cTecla == Chr(0) .or. cTecla == "*"
	   Return .F.
	ElseIf cTecla =="." 
		If cPic=="9" .and. At(".",aPicture[nTerminal+1]) ==0
		   Return .f.
		EndIf	   
	ElseIf cTecla == Chr(13)  // enter                               
	   aWaitKbd[nTerminal+1] := .F.
	   Return .T.
	ElseIf cTecla == Chr(127) // DEL (no microterminal consideramos esta tecla como o ESC)
	   aTeclado[nTerminal+1] := Chr(127)
	   aWaitKbd[nTerminal+1] := .F.
	   Return .T.
	ElseIf cTecla == Chr(08) // backspace
	   If aPosPic[nTerminal+1] > 1
	      cPic := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1]-1,1)
	      If cPic $ "/.-"
            nCol := aCol[nTerminal+1]-1
            nLin := aLin[nTerminal+1]
	         GPosCursor(nLin,nCol-1)
	         aPosPic[nTerminal+1]--
	      EndIf                     
	      aPosPic[nTerminal+1]--                                                           
		   aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1," ")
	   	GDisplay(Chr(08))
	   EndIf
	   Return .F.
	ElseIf cPic == "@"
	   Return .F.
	EndIf
	nPosPonto := At(".",aPicture[nTerminal+1])
	nDec :=0
	If nPosPonto >0
		nDec:= Len(aPicture[nTerminal+1])-nPosPonto
	EndIf                                                                      
	If cPic == "X"
	   aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)
	   aPosPic[nTerminal+1]++
	   GDisplay(cTecla)
	ElseIf cPic == "9"
	   If cTecla $ "0123456789."
	      If cTecla == "." .and. nDec >0
            nCol := aCol[nTerminal+1]-1
            nLin := aLin[nTerminal+1]                               
            aTeclado[nTerminal+1]:= Padl(Alltrim(Left(aTeclado[nTerminal+1],nPosPonto-1)),nPosPonto-1)+Subs(aTeclado[nTerminal+1],nPosPonto)
            GPosCursor(nLin,nCol-aPosPic[nTerminal+1]+1)
            GDisplay(aTeclado[nTerminal+1])
	         GPosCursor(nLin,nCol+(nPosPonto-aPosPic[nTerminal+1])+1)
	         aPosPic[nTerminal+1]+=nPosPonto-aPosPic[nTerminal+1]+1
	      Else                
	         If aPosPic[nTerminal+1] == 1 
	            If nDec > 0                                                   
	               aTeclado[nTerminal+1] := Stuff(Space(len(aPicture[nTerminal+1])),nPosPonto,1,".")
	            Else
	               aTeclado[nTerminal+1] := Space(len(aPicture[nTerminal+1]))
	            EndIF
	            nCol := aCol[nTerminal+1]-1
	            nLin := aLin[nTerminal+1]
	            GDisplay(aTeclado[nTerminal+1])
	            GPosCursor(nLin,nCol)          
	            aTeclado[nTerminal+1] := cTecla+Subs(aTeclado[nTerminal+1],2)
	         Else
				   aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)
	         EndIf                        
	         aPosPic[nTerminal+1]++
	         GDisplay(cTecla)
	      EndIf      
	   EndIf
	ElseIf cPic == "A"
	   If Upper(cTecla) >= "A" .and. Upper(cTecla) <= "Z"
		   aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)	   
	      aPosPic[nTerminal+1]++
	      GDisplay(cTecla)
	   EndIf
	ElseIf cPic == "*"
	   aTeclado[nTerminal+1] := Stuff(aTeclado[nTerminal+1],aPosPic[nTerminal+1],1,cTecla)	
	   aPosPic[nTerminal+1]++
	   GDisplay("*")
	EndIf
	nTamanho := Len(aPicture[nTerminal+1])
	If "@" $ aPicture[nTerminal+1]
	   nTamanho--      
	EndIf
	cPic     := SubStr(aPicture[nTerminal+1],aPosPic[nTerminal+1],1)
   If cPic == "@"
      Return .f.
   ElseIf cPic ==""   
	   aWaitKbd[nTerminal+1] := .F. 
	   Return .T.
	ElseIf cPic $ "/.-" 
	   cTecla := cPic
	   aPosPic[nTerminal+1]++
	   GDisplay(cTecla)
	   Return .F.
	Else
	   Return .F.
	EndIf
EndDo
Return lRet


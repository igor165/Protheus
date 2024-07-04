#INCLUDE "HSPAHP06.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP06  º Autor ³ Paulo              º Data ³  22/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento Alta                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP06()
 Local cIDMaq := HS_NUMID(2, "C:\") // Retorna o Numero de Serie do Volume do Drive C
 Local cCCuInt := HS_RetCCM(cIdMaq) // Retorna o Centro de Custo que a Maquina esta localizada
 Private cFiltro
 Private cAltaAdm := Alltrim(GetMV("MV_ALTAADM"))
 
 aRotina := {{OemtoAnsi(STR0001), "axPesqui"   , 0, 1}, ; // "Pesquisar //"Pesquisar"
             {OemtoAnsi(STR0002), "HSPAHP61(4)", 0, 2}}   // "Cancelamento de Alta" //"Cancela Alta"

 cCadastro := OemToAnsi(STR0003) //"Cancelamento Alta"

 dbSelectArea("GAD")
 DbSetOrder(1)

	cFiltro := "GAD_ATERPD != '1' .And. !Empty(GAD_TPALTA) .And. GAD_TPALTA != '99'"

 If !Empty(AllTrim(cCCuInt))
				cFiltro += " .And. GAD_CCUINT $ '" + cCCuInt + "'"  
	Else
				
 EndIf

 HS_AtvFilt("GAD", cFiltro)
 
 mBrowse( 6, 1,22,75,"GAD",,"GAD_TPALTA")
 
 HS_DtvFilt("GAD")
 
Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP061 º Autor ³ Paulo              º Data ³  22/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento Alta                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao HSPpitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP61()

Private cOcup := SPACE(01)

Private M->GAD_CCUINT 	:= GAD->GAD_CCUINT
Private M->GAD_DESCCU 	:= SPACE(30)
Private M->GAD_QUAINT 	:= GAD->GAD_QUAINT
Private M->GAD_LEIINT 	:= GAD->GAD_LEIINT
Private cSexo			:= ""             
Private M->DESCCU       := Space(30)

//RetIndex()

if Empty(GAD->GAD_TPALTA)
	MsgStop(STR0004,STR0005) //"Paciente nao teve alta..."###"Atenção"
	Return .F.
endif

If GAD->GAD_FECBOL = "1"
	MsgStop(STR0006,STR0005) //"Boletim fechado, não é permitido cancelamento da alta..."###"Atenção"
	Return .F.
endif

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5") + "T0" + GAD->GAD_TPALTA)

DbSelectArea("GAV")
DBSetOrder(1)
DbSeek(xFilial("GAV")+GAD->GAD_CCUINT+GAD->GAD_QUAINT+GAD->GAD_LEIINT)

M->DESCCU := HS_RDescCC(GAD->GAD_CCUINT)

If GAD->GAD_TPALTA $ cAltaAdm .And. FS_Chk_Altas()
	Return(.F.)
EndIf			

if !Empty(GAV->GAV_REGATE)
	MsgStop(STR0007+GAV->GAV_QUARTO+STR0008+GAV->GAV_LEITO+STR0009,STR0005) //"Quarto/Local "###" Leito "###" está ocupado por outro paciente..."###"Atenção"
	cOcup := "S"
endif

dbSelectArea("GAD")

Private aTELA[0][0],aGETS[0]
Private AHEADER  := {}, ACOLS := {}
Private cFieldOk := cTudOk := cLinOk := "Allwaystrue()"

cSexo := posicione("GBH",1,Xfilial("GBH")+GAD->GAD_REGGER,"GBH_SEXO")
nOpca := 0
IF cOcup = "S"
	
	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0010) From 9,14 to 28,93 of oMainWnd	 //"Cancelamento de Alta"
	
	@ 022,008 Say OemToAnsi(STR0011) Size 40,0  PIXEL COLOR CLR_BLUE OF oDlg1 //"Nro Registro"
	@ 022,053 MSGet o01 var GAD->GAD_REGATE Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 033,008 Say OemToAnsi(STR0012) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Nome"
	@ 033,053 MSGet o02 var GAD->GAD_NOME Picture "@!" Size 130,7 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 044,008 Say OemToAnsi(STR0013) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Quarto/Leito"
	@ 044,053 MSGet o03 var GAD->GAD_QUAINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 044,167 Say OemToAnsi(STR0014)  Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Leito"
	@ 044,205 MSGet o04 var GAD->GAD_LEIINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 055,008 Say OemToAnsi(STR0015) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Setor"
	@ 055,053 MSGet o05 var GAD->GAD_CCUINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 055,167 Say OemToAnsi(STR0016) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Descr.Setor"
	@ 055,205 MSGet o06 var M->DESCCU Picture "@!" Size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 066,008 SAY OemToAnsi(STR0017) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Data Alta"
	@ 066,053 MSGet o07 var GAD->GAD_DATALT Picture "@D" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 066,167 Say OemToAnsi(STR0018) Size 34,7 PIXEL COLOR CLR_BLACK OF oDlg1 //"Hora Alta"
	@ 066,205 MSGet o08 var GAD->GAD_HORALT Picture "99:99" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 077,008 SAY OemToAnsi(STR0019) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Tipo Alta"
	@ 077,053 MSGet o09 var GAD->GAD_TPALTA Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 077,167 Say OemToAnsi(STR0020) Size 40,0 PIXEL COLOR CLR_BLACK OF oDlg1  //"Desc.Alta"
	@ 077,205 MSGet o10 var X5DESCRI() Picture "@!" Size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 095,009 Say OemToAnsi(STR0021) Size 100,7 PIXEL COLOR CLR_RED OF oDlg1 //"Informe outro leito para o paciente"
	
	M->GAD_CCUINT := SPACE(09)
	M->GAD_DESCCU := SPACE(30)
	M->GAD_QUAINT := SPACE(03)
	M->GAD_LEIINT := SPACE(03)
	
	@ 0111,010 SAY OemToAnsi(STR0022) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Setor "
	@ 0111,053 MSGet o07 var M->GAD_CCUINT F3 "CTT" Picture "@!" Valid FS_Gets(01) Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1
	@ 0111,167 Say OemToAnsi(STR0016) Size 34,7 PIXEL COLOR CLR_BLACK OF oDlg1 //"Descr.Setor"
	@ 0111,205 MSGet o08 var M->GAD_DESCCU size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1 when .f.
	
	@ 0121,010 SAY OemToAnsi(STR0023) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Quarto/Local"
	@ 0121,053 MSGet o09 var M->GAD_QUAINT F3 "GAV" Picture "@!" Valid FS_Gets(02) Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1
	
	@ 0121,167 Say OemToAnsi(STR0014) Size 40,0 PIXEL COLOR CLR_BLACK OF oDlg1 //"Leito"
	
	@ 0121,205 MSGet o10 var M->GAD_LEIINT Valid FS_Gets(03) size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1
	
	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnChoiceBar(oDlg1,{||IF(FS_VALTUDO(),nOpca:=1,.F.),IF(nOpca==1,oDlg1:End(),.F.)} , {|| oDlg1:End()})
	
	if nOpca == 1
		Grav06()
	Endif
	
ELSE
	
	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0010) From 9,14 to 22,93 of oMainWnd	 //"Cancelamento de Alta"
	
	@ 022,008 Say OemToAnsi(STR0011) Size 40,0  PIXEL COLOR CLR_BLUE OF oDlg1 //"Nro Registro"
	@ 022,053 MSGet o01 var GAD->GAD_REGATE Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 033,008 Say OemToAnsi(STR0012) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Nome"
	@ 033,053 MSGet o02 var GAD->GAD_NOME Picture "@!" Size 130,7 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 044,008 Say OemToAnsi(STR0013) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Quarto/Leito"
	@ 044,053 MSGet o03 var GAD->GAD_QUAINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 044,167 Say OemToAnsi(STR0014)  Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Leito"
	@ 044,205 MSGet o04 var GAD->GAD_LEIINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 055,008 Say OemToAnsi(STR0015) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Setor"
	@ 055,053 MSGet o05 var GAD->GAD_CCUINT Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 055,167 Say OemToAnsi(STR0016) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Descr.Setor"
	@ 055,205 MSGet o06 var M->DESCCU Picture "@!" Size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 066,008 SAY OemToAnsi(STR0017) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1  //"Data Alta"
	@ 066,053 MSGet o07 var GAD->GAD_DATALT Picture "@D" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	@ 066,167 Say OemToAnsi(STR0018) Size 34,7 PIXEL COLOR CLR_BLACK OF oDlg1 //"Hora Alta"
	@ 066,205 MSGet o08 var GAD->GAD_HORALT Picture "99:99" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1  When .f.
	
	@ 077,008 SAY OemToAnsi(STR0019) Size 40,0 PIXEL COLOR CLR_BLUE OF oDlg1 //"Tipo Alta"
	@ 077,053 MSGet o09 var GAD->GAD_TPALTA Picture "@!" Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	@ 077,167 Say OemToAnsi(STR0020) Size 40,0 PIXEL COLOR CLR_BLACK OF oDlg1  //"Desc.Alta"
	@ 077,205 MSGet o10 var X5DESCRI() Picture "@!" Size 100,7 PIXEL COLOR CLR_BLACK OF oDlg1 When .f.
	
	M->GAD_CCUINT := GAD->GAD_CCUINT
	M->GAD_QUAINT := GAD->GAD_QUAINT
	M->GAD_LEIINT := GAD->GAD_LEIINT
	
	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnChoiceBar(oDlg1,{||IF(FS_VALTUDO(),nOpca:=1,.F.),IF(nOpca==1,oDlg1:End(),.F.)} , {|| oDlg1:End()})
	
	if nOpca == 1
		Grav06()
	Endif
	
ENDIF

Return

// Valida Tudo
///////////////////////////////
Static Function FS_VALTUDO()
if Empty(M->GAD_CCUINT)
	MsgStop(STR0024,STR0005) //"Centro de Custo Invalido!"###"Atenção"
	Return .f.
endif
if empty(M->GAD_QUAINT)
	MsgStop(STR0025,STR0005) //"Quarto Invalido!"###"Atenção"
	Return .f.
endif
if empty(M->GAD_LEIINT)
	MsgStop(STR0026,STR0005) //"Leito Invalido!"###"Atenção"
	Return .f.
endif
DBSelectArea("GAV")
DBSetOrder(1)
DBGoTop()
Dbseek(xfilial("GAV")+M->GAD_CCUINT+M->GAD_QUAINT+M->GAD_LEIINT)
IF !FOUND()
	MSGSTOP(STR0027,STR0005) //"Este Leito Não Existe !"###"Atenção"
	Return .f.
ENDIF
IF !EMPTY(GAV->GAV_REGATE)
	MSGSTOP(STR0028,STR0005) //"Este Leito está ocupado por Outro paciente "###"Atenção"
	Return .f.
ENDIF
Return .t.

// Validacao dos Gets
///////////////////////////////
Static Function FS_Gets(nPar)

if nPar == 01  //Centro de Custo                 
 M->GAD_DESCCU := HS_RDescCC(M->GAD_CCUINT)
 if Empty(AllTrim(M->GAD_DESCCU)) .or. Vazio()
  MsgStop(STR0024,STR0005) //"Centro de Custo Invalido!"###"Atenção"
  Return .f.
 endif
Elseif nPar == 02
	if empty(M->GAD_QUAINT)
		MsgStop(STR0025,STR0005) //"Quarto Invalido!"###"Atenção"
		Return .f.
	endif
Elseif nPar == 03
	//Verificando se o Usuário Informou o Leito
	if empty(M->GAD_LEIINT)
		MsgStop(STR0026,STR0005) //"Leito Invalido!"###"Atenção"
		Return .f.
	endif
	//Verificando o Leito Atual
	DBSelectArea("GAV")
	DBSetOrder(1)
	DBGoTop()
	Dbseek(xfilial("GAV")+M->GAD_CCUINT+M->GAD_QUAINT+M->GAD_LEIINT)
	IF !FOUND()
		MSGSTOP(STR0027,STR0005) //"Este Leito Não Existe !"###"Atenção"
		Return .f.
	ENDIF
	IF !EMPTY(GAV->GAV_REGATE)
		MSGSTOP(STR0028,STR0005) //"Este Leito está ocupado por outro paciente "###"Atenção"
		Return .f.
	ENDIF
Endif
Return .t.

Function Grav06()

DbSelectArea("GAV")
DBSetOrder(1)

If cOcup=="S"
	DbSelectArea("GAV")
	DBSetOrder(1)
	IF !Dbseek(xfilial("GAV")+M->GAD_CCUINT+M->GAD_QUAINT+M->GAD_LEIINT)
		MsgStop(STR0029,STR0005) //"Leito não cadastrado..."###"Atenção"
		DbSelectArea("GAD")
		Return .F.
	ENDIF
	
	If EMPTY(M->GAD_CCUINT)
		MsgStop(STR0030,STR0005) //"Necessário informar setor..."###"Atenção"
		DbSelectArea("GAD")
		Return .F.
	Endif
	
	If EMPTY(M->GAD_QUAINT)
		MsgStop(STR0031,STR0005) //"Necessário informar quarto..."###"Atenção"
		DbSelectArea("GAD")
		Return .F.
	Endif
	
	If EMPTY(M->GAD_LEIINT)
		MsgStop(STR0032,STR0005) //"Necessário informar leito..."###"Atenção"
		DbSelectArea("GAD")
		Return .F.
	Endif
	
	// Grava Movimentação de Leitos
	DbSelectArea("GB1")
	RecLock("GB1",.T.)
	//       GB1->GB1_DATA   := DATE()
	//       GB1->GB1_HORA   := TIME()
	//       GB1->GB1_TIPO   := "0"
	//       GB1->GB1_LOGARQ  := subs(cUsuario,7,15)+" - "+strzero(day(dDataBase),2)+"/"+StrZero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
	
	GB1->GB1_FILIAL := xFilial("GB1")
	GB1->GB1_REGATE := GAD->GAD_REGATE
	GB1->GB1_DATAE  := DATE()
	GB1->GB1_HORAE  := TIME()
	GB1->GB1_CCUSTO := M->GAD_CCUINT
	GB1->GB1_QUARTO := M->GAD_QUAINT
	GB1->GB1_LEITO  := M->GAD_LEIINT
	GB1->GB1_LOGENT := cUserName+" - "+strzero(day(dDataBase),2)+"/"+StrZero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
	MsUnlock()
	// ------------
	
	Begin Transaction 
   	 DbSelectArea("GAV")
	 RecLock("GAV",.f.)
	  GAV->GAV_REGATE  := GAD->GAD_REGATE
	  GAV->GAV_NOME    := GAD->GAD_NOME
	  GAV->GAV_OBSERV  := STR0033 //"LEITO OCUPADO"
	 MsUnlock()

	 DbSelectArea("GAD")
	 RecLock("GAD",.f.)
	  GAD->GAD_CCUINT := M->GAD_CCUINT
	  GAD->GAD_QUAINT := M->GAD_QUAINT
	  GAD->GAD_LEIINT := M->GAD_LEIINT
	 MsUnlock()
	End Transaction
ELSE

	// Grava Movimentação de Leitos
	DbSelectArea("GB1")
	RecLock("GB1",.T.)
	// Grava Movimentação de Leitos
	//       GB1->GB1_DATA   := DATE()
	//       GB1->GB1_HORA   := TIME()
	//       GB1->GB1_TIPO   := "0"
	//       GB1->GB1_LOGARQ  := subs(cUsuario,7,15)+" - "+strzero(day(dDataBase),2)+"/"+StrZero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
	
	GB1->GB1_FILIAL := xFilial("GB1")
	GB1->GB1_REGATE := GAD->GAD_REGATE
	GB1->GB1_DATAE  := DATE()
	GB1->GB1_HORAE  := TIME()
	GB1->GB1_CCUSTO := GAD->GAD_CCUINT
	GB1->GB1_QUARTO := GAD->GAD_QUAINT
	GB1->GB1_LEITO  := GAD->GAD_LEIINT
	GB1->GB1_LOGENT := cUserName+" - "+strzero(day(dDataBase),2)+"/"+StrZero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
	MsUnlock()
	// ---------------------
	
	DbSelectArea("GAV")
	RecLock("GAV",.f.)
	GAV->GAV_REGATE  := GAD->GAD_REGATE
	GAV->GAV_NOME    := GAD->GAD_NOME
	GAV->GAV_OBSERV  := STR0033 //"LEITO OCUPADO"
	MsUnlock()
Endif

DbSelectArea("GAD")
RecLock("GAD",.f.)
GAD->GAD_DATALT := CTOD("")
GAD->GAD_HORALT := SPACE(05)
GAD->GAD_TPALTA := SPACE(02)
GAD->GAD_LOGALT := HS_LogArq()
MsUnlock()

Return(.t.)

Static Function FS_Chk_Altas()
Local lRet :=.T.

Local cAlias := ALIAS()
Local aAreaGAD := GAD->(GetArea())

Local cAuxRegAte := If(Empty(GAD->GAD_REGANT), GAD->GAD_REGATE, GAD->GAD_REGANT)
Local cRegAte := GAD->GAD_REGATE
Local oDlg, oFont,oBtLege,oBrwAte, aRegAtd := {}
Local aCorBrw := {  {"GAD->(Empty(GAD_TPALTA))"  , 'BR_VERDE'   }, ;	    
                    {"GAD->GAD_TPALTA == '16'"			, 'BR_AMARELO' }, ;
                    {"GAD->GAD_TPALTA == '99'"			, 'BR_VERMELHO'}}

Define  FONT oFont NAME "Arial" BOLD

//desativar filtro para processar GAD
HS_DtvFilt("GAD")

dbSelectArea("GAD")
dbSetOrder(29)

If dbSeek(xFilial("GAD")+cAuxRegAte)
 While GAD->(!Eof().And.GAD_FILIAL+GAD_REGANT==xFilial("GAD")+cAuxRegAte)
  If GAD->GAD_TPALTA != "99"
   aAdd(aRegAtd, GAD->GAD_REGATE)
  EndIf
  GAD->(dbSkip())
 End
 If Len(aRegAtd) > 0 .And. aRegAtd[Len(aRegAtd)] != cRegAte
 	DEFINE MSDIALOG oDlg TITLE STR0034 FROM 0,0 TO 500,794 PIXEL //"Cancelamento Nao Efetuado - Altas Administrativas"
   
	 oBrwAte := HS_MBrow(oDlg, "GAD", {015, 000, 398, 190}, "'" + cAuxRegAte + "'", "'" + cAuxRegAte+ "'", ;
                       /*cCpoSta*/, aCorBrw, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .F., /*cFunMB*/, .F., /*aColsBrw*/)
  @ 207, 001 TO 247,390 LABEL STR0005 OF oDlg  PIXEL//TGroup():New(33,1,34,119,'',oDlg,,,.T.)//"Atenção"
	 @ 220, 030 Say OemToAnsi(STR0035) Size 300,40 OF oDlg PIXEL COLOR CLR_HRED FONT oFont //"Cancelamento nao pode ser efetuado, pois existem altas administrativas ou atendimento em aberto gerados a partir deste atendimento !   Cancele primeiros as altas ou os atendimentos listados. "
  oBtLege := tButton():New(225, 315, STR0036, oDlg, {|| FS_MyLege()          }, 60,,,,, .T.) //"Legenda"
	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()})
 Else
  lRet := .F.
 EndIf
Else
 lRet := .F.
EndIf
  
RestArea(aAreaGAD)
dbSelectArea(cAlias)

//voltar filtro para mbrowse 
HS_AtvFilt("GAD", cFiltro)

Return(lRet)

Static Function FS_MyLege()
BrwLegenda(STR0037, STR0036, {{"BR_VERDE"   , STR0038}, ;   //"Cancelamento nao Efetuado"###"Legenda"###"Atendimento em Aberto"
                                   {"BR_AMARELO" , STR0039}, ; //"Alta Administrativa"
                                   {"BR_VERMELHO", STR0040}}) //"Cancelado Atendimento"
Return(Nil)

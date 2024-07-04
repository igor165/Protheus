// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "OFIOM460.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOM460 º Autor ³ Thiago º Data ³  21/08/13   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programação da Oficina.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM460()

Private cCadastro:= STR0001
Private aRotina  := MenuDef()

mBrowse( 6, 1,22,75,"VSO",,,,,,OM460L())

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OM460P º Autor ³ Thiago º Data ³  21/08/13   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programação da Oficina.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM460P(cAlias,nReg,nOpc)

Local _ni     := {}
Local cAliasEnchoice := "VSO"
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aNewBot  := {}
Local cLinOk
Local cTudOk
Local cFieldOk

Private aHeader := {}
Private aCols   := {}

Private nVDORECNO := 0

if VSO->VSO_STATUS == "3"
	MsgStop(STR0002)
	Return(.f.)
Endif
if VSO->VSO_STATUS == "4"
	MsgStop(STR0003)
	Return(.f.)
Endif

INCLUI := .T.
nOpc   := 3

cLinOk   := "FG_OBRIGAT()"
cFieldOk := "OM460FOK()"
//cFieldOk   := "FG_MEMVAR()"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDO")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. (X3_ARQUIVO == "VDO")
	//	nPos := Ascan(aCpoGetDados,X3_CAMPO)
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(x3_campo $ [VDO_NUMAGE/VDO_NUMBOX/VDO_CODCON/VDO_NOMCON])
		AADD(aHeader,{ Trim(X3Titulo()),;
						X3_CAMPO,;
						X3_PICTURE,;
						X3_TAMANHO,;
						X3_DECIMAL,;
						X3_VALID,;
						X3_USADO,;
						X3_TIPO,;
						X3_ARQUIVO,;
						X3_CONTEXT,;
						X3_RELACAO,;
						X3_RESERV  } )
	EndIF
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()
Enddo
dbSelectArea("VDO")
ADHeadRec("VDO",aHeader)

M->VDO_NUMAGE := VSO->VSO_NUMIDE
M->VDO_NUMBOX := VSO->VSO_NUMBOX
dbSelectArea("VON")
dbSetOrder(1)
dbSeek(xFilial("VON")+M->VDO_NUMBOX)
dbSelectArea("VAI")
dbSetOrder(1)
dbSeek(xFilial("VAI")+VON->VON_CODPRO)
M->VDO_CODCON := VON->VON_CODPRO
M->VDO_NOMCON := VAI->VAI_NOMTEC           
aCols       := {}
VDO->(dbSetOrder(1)) // Nro.Agendamento+Seq. Inconv.
DbSelectArea("VST")
DbSetOrder(1)
DbSeek( xFilial("VST")+"3"+VSO->VSO_NUMIDE)
While !Eof() .And. VST->VST_TIPO == "3" .and. VST->VST_CODIGO ==VSO->VSO_NUMIDE .and. xFilial("VSO")==VSO->VSO_FILIAL

	Aadd(aCols, Array(Len(aHeader)+1) )
	nReg := Len(aCols)
	aCols[nReg,Len(aCols[nReg])] := .f.
	For _ni:=1 to Len(aHeader)
		If IsHeadRec(aHeader[_ni,2])
			nVDORECNO := _ni
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[nReg,_ni] := "VDO"
		Else
			aCols[nReg,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
	
	M->VDO_SEQINC := VST->VST_SEQINC
	aCols[nReg,FG_POSVAR("VDO_SEQINC")] := VST->VST_SEQINC
	M->VDO_GRUINC := VST->VST_GRUINC
	aCols[nReg,FG_POSVAR("VDO_GRUINC")] := VST->VST_GRUINC
	M->VDO_CODINC := VST->VST_CODINC
	aCols[nReg,FG_POSVAR("VDO_CODINC")] := VST->VST_CODINC
	M->VDO_DESINC := VST->VST_DESINC
	aCols[nReg,FG_POSVAR("VDO_DESINC")] := VST->VST_DESINC

	if !VDO->(dbSeek(xFilial("VDO")+VSO->VSO_NUMIDE+VST->VST_SEQINC))
		aCols[nReg,nVDORECNO] := 0
	Else
	
		aCols[nReg,nVDORECNO] := VDO->(Recno())
	
		M->VDO_GRUSER := VDO->VDO_GRUSER
		aCols[nReg,FG_POSVAR("VDO_GRUSER")] := VDO->VDO_GRUSER
		M->VDO_CODSER := VDO->VDO_CODSER
		aCols[nReg,FG_POSVAR("VDO_CODSER")] := VDO->VDO_CODSER
        dbSelectArea("VO6")
        dbSetOrder(4)
        dbSeek(xFilial("VO6")+VDO->VDO_CODSER)
		M->VDO_DESSER := VO6->VO6_DESSER
		aCols[nReg,FG_POSVAR("VDO_DESSER")] := VO6->VO6_DESSER
		M->VDO_TEMPAD := VDO->VDO_TEMPAD //FS_CALCTP() // TO DO
		aCols[nReg,FG_POSVAR("VDO_TEMPAD")] := VDO->VDO_TEMPAD //FS_CALCTP() // TO DO
		
		M->VDO_CODPRO := VDO->VDO_CODPRO
		aCols[nReg,FG_POSVAR("VDO_CODPRO")] := VDO->VDO_CODPRO
		
		If VAI->(dbSeek(xFilial("VAI")+VDO->VDO_CODPRO))
			M->VDO_NOMPRO := VAI->VAI_NOMTEC
			aCols[nReg,FG_POSVAR("VDO_NOMPRO")] := VAI->VAI_NOMTEC
		EndIf
		
	    M->VDO_DATINI := VDO->VDO_DATINI
		aCols[nReg,FG_POSVAR("VDO_DATINI")] := VDO->VDO_DATINI
		M->VDO_HORINI := VDO->VDO_HORINI
		aCols[nReg,FG_POSVAR("VDO_HORINI")] := VDO->VDO_HORINI
		M->VDO_DATFIN := VDO->VDO_DATFIN
		aCols[nReg,FG_POSVAR("VDO_DATFIN")] := VDO->VDO_DATFIN
		M->VDO_HORFIN := VDO->VDO_HORFIN
		aCols[nReg,FG_POSVAR("VDO_HORFIN")] := VDO->VDO_HORFIN
	Endif
	dbSelectArea("VST")
	dbSkip()
EndDo

nOpcE := 3
nOpcG := 3
aCpoEnchoice  :={"VDO_NUMAGE","VDO_NUMBOX","VDO_CODCON","VDO_NOMCON"}

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 35 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 20 , .T. , .T. } )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1") + VSO->VSO_CODMAR)

DEFINE MSDIALOG oOfm460 TITLE STR0004 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

EnChoice("VDO",nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
//oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,cLinOk,cTudOk,"",.T.,{"VDO_GRUSER","VDO_CODSER","VDO_TEMPAD","VDO_CODPRO","VDO_DATINI","VDO_HORINI"},,,,cFieldOk)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,cLinOk,cTudOk,"",.F.,,,,Len(aCols),cFieldOk)
//oGetDados:oBrowse:bChange := {|| FG_MEMVAR()}

ACTIVATE MSDIALOG oOfm460 CENTER ON INIT EnchoiceBar(oOfm460, {|| IIf(FS_OK(),(oOfm460:End(),nOpca := 1),.f.) } , {|| oOfm460:End(),nOpca := 2},,)


Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Thiago  ³				  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do menu aRotina							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Private aRotina := {{ STR0005,"axPesqui"  , 0 , 1},;	// Pesquisar
					{ STR0006,"OM460PROG" , 0 , 2},;	// Consulta
					{ STR0007,"OM460P"    , 0 , 4},;	// Programação
					{ STR0008,"OM350L"    , 0 , 9}}		// Legenda
Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM460L  ³ Autor ³ Thiago  ³				  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda.												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM460L(nReg)

Local uRetorno := .t.
Local aLegenda := {	{'BR_VERDE'    ,STR0009},; // Agendado
					{'BR_LARANJA'  ,STR0010},; // Orcamento Aberto
					{'BR_AZUL'     ,STR0011},; // OS Aberta
					{'BR_PRETO'    ,STR0012},; // Finalizado
					{'BR_VERMELHO' ,STR0013}}  // Cancelado
If nReg == NIL 	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	AADD( uRetorno , {'VSO->VSO_STATUS=="1"',aLegenda[1,1],aLegenda[1,2]} ) // 1 = Agendado
	AADD( uRetorno , {'VSO->VSO_STATUS=="5"',aLegenda[2,1],aLegenda[2,2]} ) // 5 = Orcamento Aberto
	AADD( uRetorno , {'VSO->VSO_STATUS=="2"',aLegenda[3,1],aLegenda[3,2]} ) // 2 = OS Aberta
	AADD( uRetorno , {'VSO->VSO_STATUS=="3"',aLegenda[4,1],aLegenda[4,2]} ) // 3 = Finalizado
	AADD( uRetorno , {'VSO->VSO_STATUS=="4"',aLegenda[5,1],aLegenda[5,2]} ) // 4 = Cancelado
Else
	BrwLegenda(cCadastro,STR0008,aLegenda) //Legenda
EndIf
Return uRetorno


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM460FOK ³ Autor ³ Rubens                ³ Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fieldok da GetDados									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM460FOK(cReadVar)

Local lRetorno := .t.

Default cReadVar := ReadVar()

If cReadVar == "M->VDO_DATINI"
	If Empty(M->VDO_DATFIN)
		M->VDO_DATFIN := M->VDO_DATINI
	EndIf
EndIf

Return lRetorno
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM460PROG ³ Autor ³ Thiago  ³			  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta programaçao.    							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM460PROG()

Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Private aProgram := {{"","","","","","",0,"","",ctod(""),0,ctod(""),0,"","","",""}}
Private cAgend   := space(TamSx3("VDO_NUMAGE")[1])
Private cConsult := space(TamSx3("VDO_CODCON")[1])
Private cNomCon  := space(TamSx3("VDO_NOMCON")[1])
Private cProdut  := space(TamSx3("VDO_CODPRO")[1])
Private cNomPro  := space(TamSx3("VDO_NOMPRO")[1])  
Private cVeic    := space(TamSx3("VV1_CHASSI")[1])  
Private cMVeic   := space(TamSx3("VV2_DESMOD")[1])  
Private dDtIni   := ctod("  /  /  ")
Private dDtFin   := ctod("  /  /  ")

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 78 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 01, 20, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oCProg TITLE STR0015 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0016 OF oCProg PIXEL
@ aPosObj[1,1]+012,aPosObj[1,2]+010 SAY STR0017 SIZE 40,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+012,aPosObj[1,2]+060 MSGET oAgend VAR cAgend PICTURE "@!" F3 "VSOAGE" SIZE 45,08 OF oCProg PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+025,aPosObj[1,2]+010 SAY STR0018 SIZE 50,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+025,aPosObj[1,2]+060 MSGET oConsut VAR cConsult VALID FS_NOMCON() PICTURE "@!" F3 "VAI" SIZE 45,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+025,aPosObj[1,2]+110 MSGET oNomCon VAR cNomCon PICTURE "@!" SIZE 160,08 OF oCProg PIXEL COLOR CLR_BLUE When .f.

@ aPosObj[1,1]+038,aPosObj[1,2]+010 SAY STR0019 SIZE 50,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,aPosObj[1,2]+060 MSGET oProdut VAR cProdut VALID FS_NOMPRO() PICTURE "@!" F3 "VAI" SIZE 45,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,aPosObj[1,2]+110 MSGET oNomPro VAR cNomPro PICTURE "@!" SIZE 160,08 OF oCProg PIXEL COLOR CLR_BLUE When .f.
                                     
@ aPosObj[1,1]+051,aPosObj[1,2]+010 SAY STR0044 SIZE 50,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+051,aPosObj[1,2]+060 MSGET oVeic VAR cVeic PICTURE "@!" F3 "VV1" VALID FG_POSVEI("cVeic",) SIZE 85,08 OF oCProg PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+064,aPosObj[1,2]+010 SAY STR0020 SIZE 50,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+064,aPosObj[1,2]+060 MSGET oDtIni VAR dDtIni PICTURE "@D" SIZE 55,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+064,aPosObj[1,2]+120 SAY STR0021 SIZE 50,08 OF oCProg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+064,aPosObj[1,2]+138 MSGET oDtFin VAR dDtFin PICTURE "@D" SIZE 55,08 OF oCProg PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+025,aPosObj[1,2]+320 BUTTON oFiltro    PROMPT OemToAnsi(STR0022) OF oCProg SIZE 65,10 PIXEL ACTION (FS_FILTRAR())
@ aPosObj[1,1]+037,aPosObj[1,2]+320 BUTTON oFiltro    PROMPT OemToAnsi(STR0023) OF oCProg SIZE 65,10 PIXEL ACTION (FS_IMPRIMIR())
@ aPosObj[1,1]+049,aPosObj[1,2]+320 BUTTON oFiltro    PROMPT OemToAnsi(STR0024) OF oCProg SIZE 65,10 PIXEL ACTION (oCProg:End())


@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbl FIELDS HEADER  ;
	STR0025,; // "Agendamento"
	STR0026,; // "Box"
	STR0027,; // "Consultor"
	STR0028,; // "Nome"
	RetTitle("VDO_GRUINC"),;
	RetTitle("VDO_CODINC"),;
	RetTitle("VDO_DESINC"),;
	RetTitle("VDO_GRUSER"),;
	STR0029,; // "Cód.Serviço"
	STR0030,; // "Descrição do Serviço"
	RetTitle("VDO_TEMPAD"),; // "Tpo Prev"
	STR0032,; // "Produtivo"
	STR0033,; // "Nome Produtivo"
	STR0034,; // "Data Inicio"
	STR0035,; // "Hora Inicio"
	STR0036,; // "Data Final"
	STR0037 ; // "Hora Final"
	COLSIZES 40,20,40,80,40,40,80,40,80,30,40,80,40,30,40,30 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oCProg PIXEL
oLbl:SetArray(aProgram)
oLbl:bLine := { || { aProgram[oLbl:nAt,1],;                        // "Agendamento"
					 aProgram[oLbl:nAt,2],;                        // "Box"
					 aProgram[oLbl:nAt,3],;                        // "Consultor"
					 aProgram[oLbl:nAt,4],;                        // "Nome"
					 aProgram[oLbl:nAt,14],;                       // "Grupo Inconv"
					 aProgram[oLbl:nAt,15],;                       // "Cod. Inconv"
					 aProgram[oLbl:nAt,16],;                       // "Descr. Inconv"
					 aProgram[oLbl:nAt,17],;                       // "Grupo de Srvc."
					 aProgram[oLbl:nAt,5],;                        // "Cód.Serviço"
					 aProgram[oLbl:nAt,6],;                        // "Descrição do Serviço"
					 Transform(aProgram[oLbl:nAt,7],"@E 99:99"),;  // "Tpo Prev."
					 aProgram[oLbl:nAt,8],;                        // "Produtivo"
					 aProgram[oLbl:nAt,9],;                        // "Nome Produtivo"
					 Transform(aProgram[oLbl:nAt,10],"@D"),;       // "Data Inicio"
					 Transform(aProgram[oLbl:nAt,11],"@E 99:99"),; // "Hora Inicio"
					 Transform(aProgram[oLbl:nAt,12],"@D"),;       // "Data Final"
					 Transform(aProgram[oLbl:nAt,13],"@E 99:99")}} // "Hora Final"


ACTIVATE MSDIALOG oCProg CENTER


Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRAR ³ Autor ³ Thiago  ³			  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro programaçao.   	 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR()

Local nCont
Local cAliasVDO := "SQLVDO"

cQuery := "SELECT VDO.VDO_NUMAGE,VDO.VDO_NUMBOX,VDO.VDO_CODCON,VDO.VDO_GRUSER,VDO.VDO_CODSER,VDO.VDO_TEMPAD,VDO.VDO_CODPRO,VDO.VDO_DATINI,VDO.VDO_HORINI,VDO.VDO_DATFIN,VDO.VDO_HORFIN "
cQuery += " , VST.VST_GRUINC, VST.VST_CODINC, VST.VST_SEQINC, VST.VST_DESINC "
cQuery += " , VAICON.VAI_NOMTEC NOMCON"
cQuery += " , VAIPRO.VAI_NOMTEC NOMPRO"
cQuery += " , VO6.VO6_DESSER "
cQuery += "FROM "
cQuery += RetSqlName( "VDO" ) + " VDO "  
if !Empty(cVeic)
	cQuery    += "INNER JOIN "+RetSqlName("VSO")+" VSO ON (VSO.VSO_FILIAL='"+xFilial("VSO")+"' AND VSO.VSO_NUMIDE = VDO.VDO_NUMAGE AND VSO.VSO_GETKEY = '"+cVeic+"' AND VSO.D_E_L_E_T_=' ') "
Endif
cQuery += " JOIN " + RetSQLName("VST") + " VST ON VST.VST_FILIAL = '" + xFilial("VST") + "' AND VST_TIPO = '3' AND VST_CODIGO = VDO.VDO_NUMAGE AND VST_SEQINC = VDO.VDO_SEQINC AND VST.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN " + RetSQLName("VAI") + " VAICON ON VAICON.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAICON.VAI_CODTEC = VDO.VDO_CODCON AND VAICON.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN " + RetSQLName("VAI") + " VAIPRO ON VAIPRO.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAIPRO.VAI_CODTEC = VDO.VDO_CODPRO AND VAIPRO.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN " + RetSQLName("VO6") + " VO6 ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "' AND VO6.VO6_SERINT = VDO.VDO_SERINT AND VO6.D_E_L_E_T_ = ' '"
cQuery += "WHERE "
cQuery += "VDO.VDO_FILIAL='"+ xFilial("VDO")+ "' AND "
if !Empty(cAgend)
	cQuery += "VDO.VDO_NUMAGE = '"+cAgend+"' AND "
Endif
if !Empty(cConsult)
	cQuery += "VDO.VDO_CODCON = '"+cConsult+"' AND "
Endif
if !Empty(cProdut)
	cQuery += "VDO.VDO_CODPRO = '"+cProdut+"' AND "
Endif
if !Empty(dDtIni)
	cQuery += "VDO.VDO_DATINI >= '"+dtos(dDtIni)+"' AND VDO.VDO_DATFIN <= '"+dtos(dDtFin)+"' AND "
Endif
cQuery += "VDO.D_E_L_E_T_=' '"
cQuery += " ORDER BY VDO_NUMAGE "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVDO, .T., .T. )  
aProgram := {}
Do While !( cAliasVDO )->( Eof() )
	
	aAdd(aProgram,Array(17))
	nCont := Len(aProgram)
	aProgram[nCont, 01 ] := ( cAliasVDO )->(VDO_NUMAGE)
	aProgram[nCont, 02 ] := ( cAliasVDO )->(VDO_NUMBOX)
	aProgram[nCont, 03 ] := ( cAliasVDO )->(VDO_CODCON)
	aProgram[nCont, 04 ] := SubStr( (cAliasVDO)->NOMCON ,1,20)
	aProgram[nCont, 05 ] := ( cAliasVDO )->(VDO_CODSER)  
	dbSelectArea("VO6")
	dbSetOrder(4)      
	dbSeek(xFilial("VO6")+( cAliasVDO )->(VDO_CODSER))
	
	aProgram[nCont, 06 ] := SubStr(VO6->VO6_DESSER,1,20)
	aProgram[nCont, 07 ] := ( cAliasVDO )->(VDO_TEMPAD)
	aProgram[nCont, 08 ] := ( cAliasVDO )->(VDO_CODPRO)
	aProgram[nCont, 09 ] := SubStr( (cAliasVDO)->NOMPRO ,1,20)
	aProgram[nCont, 10 ] := StoD(( cAliasVDO )->(VDO_DATINI))
	aProgram[nCont, 11 ] := ( cAliasVDO )->(VDO_HORINI)
	aProgram[nCont, 12 ] := StoD(( cAliasVDO )->(VDO_DATFIN))
	aProgram[nCont, 13 ] := ( cAliasVDO )->(VDO_HORFIN)
	
	aProgram[nCont, 14 ] := ( cAliasVDO )->(VST_GRUINC)
	aProgram[nCont, 15 ] := ( cAliasVDO )->(VST_CODINC)
	aProgram[nCont, 16 ] := ( cAliasVDO )->(VST_DESINC)
	
	aProgram[nCont, 17 ] := ( cAliasVDO )->(VDO_GRUSER)
	
	( cAliasVDO )->(dbSkip())
	
Enddo
( cAliasVDO )->( dbCloseArea() )

if Len(aProgram) == 0
	MsgInfo(STR0038)
	aProgram := {{"","","","","","",0,"","",ctod(""),0,ctod(""),0,"","","",""}} 
Endif

oLbl:SetArray(aProgram)
oLbl:bLine := { || { aProgram[oLbl:nAt,1],;                        // "Agendamento"
					 aProgram[oLbl:nAt,2],;                        // "Box"
					 aProgram[oLbl:nAt,3],;                        // "Consultor"
					 aProgram[oLbl:nAt,4],;                        // "Nome"
					 aProgram[oLbl:nAt,14],;                       // "Grupo Inconv"
					 aProgram[oLbl:nAt,15],;                       // "Cod. Inconv"
					 aProgram[oLbl:nAt,16],;                       // "Descr. Inconv"
					 aProgram[oLbl:nAt,17],;                       // "Grupo de Srvc."
					 aProgram[oLbl:nAt,5],;                        // "Cód.Serviço"
					 aProgram[oLbl:nAt,6],;                        // "Descrição do Serviço"
					 Transform(aProgram[oLbl:nAt,7],"@E 99:99"),;  // "Tpo Prev."
					 aProgram[oLbl:nAt,8],;                        // "Produtivo"
					 aProgram[oLbl:nAt,9],;                        // "Nome Produtivo"
					 Transform(aProgram[oLbl:nAt,10],"@D"),;       // "Data Inicio"
					 Transform(aProgram[oLbl:nAt,11],"@E 99:99"),; // "Hora Inicio"
					 Transform(aProgram[oLbl:nAt,12],"@D"),;       // "Data Final"
					 Transform(aProgram[oLbl:nAt,13],"@E 99:99")}} // "Hora Final"
					 
oLbl:refresh()




Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OK ³ Autor ³ Thiago  ³	 			  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Botao OK.			   	 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OK()

Local nCont := 0
Local nCntHead
//Local cAliasVDO := "SQLVDO"

For nCont := 1 to Len(aCols)
	For nCntHead:=1 to Len(aHeader)
		If X3Obrigat(aHeader[nCntHead,2]) .and. Empty(aCols[nPosaCols,nCntHead])
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aHeader[nCntHead,2]))+ " (" + aCpoVVA[nCntHead] + ")",4,1)
			Return .f.
		EndIf
	Next nCntHead
Next nCont

For nCont := 1 to Len(aCols)
	
	dbSelectArea("VDO")
	If aCols[nCont,nVDORECNO] <> 0
		VDO->(dbGoTo(aCols[nCont,nVDORECNO]))
		RecLock("VDO",.f.)
	Else
		RecLock("VDO",.t.)
	EndIf
	FG_GRAVAR("VDO",aCols,aHeader,nCont)
	VDO->VDO_NUMAGE := VSO->VSO_NUMIDE
	VDO->VDO_NUMBOX := VSO->VSO_NUMBOX
	VDO->VDO_CODCON := M->VDO_CODCON
	MsUnlock()
	
Next              

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IMPRIMIR ³ Autor ³ Thiago  ³	 		  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao.			   	 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()

Local cDesc1	:= STR0004
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local aCabec := {}
Local cAuxNumAge

Local cAuxLinha := ""
Local i := 0

Private nPosRes
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0004
Private cNomProg:= "OFIOM460"
Private cNomeRel:= "OFIOM460"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1

If Len(aProgram) == 0 .or. Empty(aProgram[1,1])
	Return .f.
EndIf

cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

AADD( aCabec , { STR0025 , 11 , "aProgram[nPosRes,01]" } )
AADD( aCabec , { STR0026 , 03 , "aProgram[nPosRes,02]" } )
AADD( aCabec , { STR0046 , 59 , "aProgram[nPosRes,14] + '-' + aProgram[nPosRes,15] + '-' + aProgram[nPosRes,16]" } )
AADD( aCabec , { STR0027 , 27 , "aProgram[nPosRes,03] + '-' + aProgram[nPosRes,04]" } )
AADD( aCabec , { STR0047 , 05 , "Transform(aProgram[nPosRes,07],'@E 99:99')" } )
AADD( aCabec , { STR0032 , 27 , "aProgram[nPosRes,08] + '-' + aProgram[nPosRes,09]" } )
AADD( aCabec , { STR0034 , 16 , "DtoC(aProgram[nPosRes,10]) + ' ' + Transform(aProgram[nPosRes,11],'@E 99:99')" } )
AADD( aCabec , { STR0036 , 16 , "DtoC(aProgram[nPosRes,12]) + ' ' + Transform(aProgram[nPosRes,13],'@E 99:99')" } )
AADD( aCabec , { STR0048 , 40 , "aProgram[nPosRes,17] + '-' + aProgram[nPosRes,05] + '-' + aProgram[nPosRes,06]" } )

aEval( aCabec , { |x| cAuxLinha += "PadR(" + x[3] + "," +Str(x[2],3) + ") + '  ' + " } )
cAuxLinha := Left(cAuxLinha,Len(cAuxLinha)-10)

//cabec1 := STR0043
aEval( aCabec , { |x| cabec1 += PadR(x[1],x[2]) + "  "} )
cabec1 := Left(cabec1,Limite)
cabec2 := ""
nLin := 999

cNumAge := aProgram[1,1]

For i := 1 to Len(aProgram)
	If cNumAge <> aProgram[i,1]
		nLin++
		cNumAge := aProgram[i,1]
	EndIf
	If nLin > 75
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter)+1
	EndIf
	nPosRes := i
	@ nLin++ , 00 PSay &(cAuxLinha)
Next

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()


Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_NOMPRO º Autor ³ Thiago º 		Data ³  01/11/13  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao no nome do produtivo.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NOMPRO()
           
dbSelectArea("VAI")
dbSetOrder(1)
dbSeek(xFilial("VAI")+cProdut)
if !Empty(cProdut)
	cNomPro := VAI->VAI_NOMTEC           
Else
	cNomPro  := space(TamSx3("VDO_NOMPRO")[1])           
Endif
Return(.t.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_NOMCON º Autor ³ Thiago º 		Data ³  01/11/13  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao no nome do consultor.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NOMCON()
           
dbSelectArea("VAI")
dbSetOrder(1)
dbSeek(xFilial("VAI")+cConsult)
if !Empty(cConsult)
	cNomCon := VAI->VAI_NOMTEC           
Else
	cNomCon  := space(TamSx3("VDO_NOMCON")[1])
Endif	

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM460VAL ³ Autor ³ Thiago  ³	 	 		  Data ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo VDO_CODSER.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM460VAL()

dbSelectArea("VO6")                                       
dbSetOrder(4)
if dbSeek(xFilial("VO6")+M->VDO_CODSER)
	M->VDO_DESSER := VO6->VO6_DESSER
Else
	MsgInfo(STR0045)
	Return(.f.)
Endif		
aCols[n,FG_POSVAR("VDO_DESSER")] := VO6->VO6_DESSER

Return(.t.)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CALCTP ³ Autor ³ Manoel  ³	 		  Data ³ 01/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula tempo Padrao dos Serviços do Agendamento			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OM460LIM()

if M->VDO_GRUSER <>  aCols[n,FG_POSVAR("VDO_GRUSER")]
	M->VDO_CODSER := space(TamSx3("VDO_CODSER")[1])
	M->VDO_DESSER := space(TamSx3("VDO_DESSER")[1])
	aCols[n,FG_POSVAR("VDO_CODSER")] := space(TamSx3("VDO_CODSER")[1])
	aCols[n,FG_POSVAR("VDO_DESSER")] := space(TamSx3("VDO_DESSER")[1])
Endif

Return(.t.)

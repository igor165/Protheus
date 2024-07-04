// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 76     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEICC500.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007230_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICC500³ Autor ³ Andre Luis Almeida       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contatos CEV                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC500(cPCodCli,cPLojCli,dPDtAgeI,dPDtAgeF)
Local OXverme
Local OXverde
Local OXazull
Local OXcinza
Local oXLbNO
Local oXLbOK
Local oXLbCa
Local oXLbTIK
Local oXlaranja
Local nTam         := 0
Local aObjects     := {}, aInfo := {}, aPos := {}
Local aSizeHalf    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lCEVOUT      := ( VAI->(FieldPos("VAI_CEVOUT")) <> 0 )
Local nTCdCli      := TamSX3("A1_COD")[1]
Local nTLjCli      := TamSX3("A1_LOJA")[1]
Local aFilAtu      := FWArrFilAtu()
Private aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private lMarcarFil := .f.
Private aEmpr      := {} // Filiais
Private aBotVCC500 := {}
Private oLbNO      := LoadBitmap( GetResources(), "LBNO" )
Private oLbOK      := LoadBitmap( GetResources(), "LBOK" )
Private oLbCa      := LoadBitmap( GetResources(), "AVGOIC1" )
Private oLbTIK     := LoadBitmap( GetResources(), "LBTIK" )
Private aVetor     := {}
Private cTipAge    := " "
Private cCodVen    := space(TamSX3("A3_COD")[1])
Private cCodCli    := space(TamSX3("A1_COD")[1])
Private cLojCli    := space(TamSX3("A1_LOJA")[1])
Private cCdPros    := space(TamSX3("US_COD")[1])
Private cLjPros    := space(TamSX3("US_LOJA")[1])
Private cIBGE      := ""
Private cFiltro    := ""
Private cNomAge    := ""
Private cNomVen    := ""
Private cNomCli    := ""
Private oBmp1 := oBmp2 := oBmp3 := oBmp4 := oBmp5 := ""
Private aContat    := {;
	STR0013,; // Todos
	STR0021+" - "+STR0008,; // Não vencidos
	STR0021+" - "+STR0007,; // Vencidos
	STR0022+" - "+STR0016,; // Na data agendada
	STR0022+" - "+STR0017,; // Fora da data agendada
	STR0022+" - "+STR0117,; // Até a Data Agendada
	STR0022+" - "+STR0118,; // Após a Data Agendada
	STR0022 ;
}
Private cContat    := STR0013
Private aPesSat    := {"","0="+STR0060,"1="+STR0061,"2="+STR0062,"3="+STR0064}
Private cPesSat    := ""
Private aInsati    := {"","0="+STR0084,"1="+STR0063,"2="+STR0095,"3="+STR0096}
Private cInsati    := ""
Private aMotEnc    := {"",STR0087,STR0088}
Private cMotEnc    := ""
Private aIntCEV    := {"",STR0100,STR0101}
Private cIntCEV    := ""
Private aProdut    := {"","0="+STR0092,"1="+STR0093}
Private cProdut    := ""
Private aCliPros   := {"","1="+STR0006,"2="+STR0012} // Cliente / Prospect
Private cCliPros   := "1"
Private cObjetiv   := ""
Private cObserv    := ""
Private cDesCid    := ""
Private dDtAgeI    := dDataBase
Private dDtAgeF    := ctod("01/"+IIf(month(dDatabase)<12,strzero(month(dDatabase)+1,2)+"/"+substr(strzero(year(dDatabase),4),3,2),"01/"+substr(strzero(year(dDatabase)+1,4),3,2)))-1
Private dDtVisI    := ctod("")
Private dDtVisF    := dDtAgeF
Private lCheck     := .f.
Private lTodos     := .t.
Private lDtVis     := .t.
Private l2Via      := .t.
Private cTot1      := ""
Private cTot2      := ""
Private cverd      := ""
Private cverm      := ""
Private cazul      := ""
Private clara      := ""
Private ccinz      := ""
Private cTitTela   := ""
Private cTipCon    := SPACE(TamSx3('VC1_TIPCON')[1])
Private M->VCF_CODSEG := SPACE(TamSx3('VCF_CODSEG')[1])
Private cTipAbor   := SPACE(TamSx3('VC1_CODABO')[1])
Private nQtdVisPer := 99
Private lAgend     := .t.
Private lMOTPNR    := ( VC1->(FieldPos("VC1_MOTPNR")) > 0 )
Private lMotEnc    := ( VC1->(FieldPos("VC1_MOTIVO")) > 0 )
Private lProdut    := ( VC1->(FieldPos("VC1_CONPRO")) > 0 )
//
Private cSQLVDM    := ""
//
Private aCposInter := { "VDM_CODMAR" , "VV2_DESMOD" , "VDM_DATINT" , "VDM_DATLIM" , "VDK_DESFAS" } // VDL / VDM / VDK / VV2 / VVC
//
Private M->VCF_NIVIMP := SPACE(TamSx3('VCF_NIVIMP')[1]) // Nivel de Importancia do Cliente
//
Default cPCodCli   := cCodCli
Default cPLojCli   := cLojCli
Default dPDtAgeI   := CtoD("")
Default dPDtAgeF   := CtoD("")
//
If ExistBlock("VC500INT")
	aCposInter := ExecBlock("VC500INT",.f.,.f.,{aCposInter}) // Retorna vetor com os campos/colunas dos Interesses (Oportunidade) - Podem ser utilizados todos os campos REAIS das tabelas VDL / VDM / VDK / VV2 / VVC
EndIf
//
aAdd(aEmpr,{ cFilAnt , aFilAtu[SM0_FILIAL] })
//
///////////////////////////////////////////////////////////////////////
// Carrega VETOR com todos os Motivos de Encerramento do Contato CEV //
///////////////////////////////////////////////////////////////////////
DbSelectArea("VS0")
DbSetOrder(1)
DbSeek(xFilial("VS0")+"000010")
While !Eof() .and. VS0->VS0_FILIAL == xFilial("VS0") .and. VS0->VS0_TIPASS == "000010"
	aadd(aMotEnc,"- "+VS0->VS0_CODMOT+": "+left(VS0->VS0_DESMOT,25)+IIf(len(VS0->VS0_DESMOT)>22,"...",""))
	DbSelectArea("VS0")
	DbSkip()
EndDo
///////////////////////////////////////////////////////////////////////
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
cCodCli := cPCodCli
cLojCli := cPLojCli
If !Empty(dPDtAgeI)
	dDtAgeI := dPDtAgeI
	dDtAgeF := dPDtAgeF
EndIf
If Empty(cCodCli)
	cCodVen := VAI->VAI_CODVEN
	If !FS_VAL_VCC500("VD",.f.)
		cCodVen := space(6)
	EndIf
Else
	If lCEVOUT .and. VAI->VAI_CEVOUT<>"1"
		cCodVen := VAI->VAI_CODVEN
	EndIf
	lAgend  := .f.
	If Empty(dPDtAgeI)
		dDtAgeI := dDtVisI
	EndIf
	FS_VAL_VCC500("CL",.f.)
EndIf

//////////////////////////////
/// Carregar OPCOES/BOTOES ///
//////////////////////////////
AADD(aBotVCC500, {"PENDENTE"    ,{|| IIf((aVetor[oLbTexto:nAt,17] <> 0),(FS_PESQSAT(aVetor[oLbTexto:nAt,2],aVetor[oLbTexto:nAt,16],aVetor[oLbTexto:nAt,15],aVetor[oLbTexto:nAt,10],aVetor[oLbTexto:nAt,4]),FS_FILTRAR(1,oLbTexto:nAt),FS_OBSVC500()), MsgStop(STR0077,STR0040)) }, STR0058 } ) // Pesq.Satisfacao / Pesquisa de Satisfacao nao existente! / Atencao
If lMOTPNR
	AADD(aBotVCC500, {"afastamento" ,{|| (FS_MOTPNR(),FS_FILTRAR(1,oLbTexto:nAt),FS_OBSVC500()) }, STR0065 } ) // Registra Pesq. nao realizada
EndIf
AADD(aBotVCC500, {"BMPVISUAL"   ,{|| IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,FS_POSFIL(1),.t.) }, STR0020 } ) // Visualiza Ficha
AADD(aBotVCC500, {"watch"       ,{|| IIf((aVetor[oLbTexto:nAt,16] <> "C"),FS_VERORIG(oLbTexto:nAt),MsgStop(STR0078,STR0040)) }, STR0053 } ) // Impossível visualizar a origem! / Atencao
AADD(aBotVCC500, {"alt_cad"     ,{|| (FS_REGABO(aVetor[oLbTexto:nAt,10],2),FS_FILTRAR(1,oLbTexto:nAt),FS_OBSVC500()) }, STR0039 } ) // Reg.Abordagem/Visita
AADD(aBotVCC500, {"critica"     ,{|| IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,FS_POSFIL(2),.t.) }, STR0042 } ) // Satisfação/Insatisfação
AADD(aBotVCC500, {"PMSUSER"     ,{|| IIf(len(Alltrim(aVetor[oLbTexto:nAt,22]))>1,FS_POSFIL(3),.t.) },( STR0113 )} ) // Converter Prospect em Cliente
AADD(aBotVCC500, {"BMPGROUP"    ,{|| IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,FS_CADCLI(aVetor[oLbTexto:nAt,7]),.t.) }, STR0043 } )
//AADD(aBotVCC500, {"analitico"   ,{|| IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,FS_POSFIL(4),.t.) }, STR0112 } ) // Visualiza Potencial do Cliente
AADD(aBotVCC500, {"print02"     ,{|| FS_IMPRIMIR(1,oLbTexto:nAt) }, STR0057 } ) // Imprimir Selecionado
AADD(aBotVCC500, {"print02"     ,{|| FS_IMPRIMIR(2,0) }, STR0027 } ) // Imprimir Relacionados
AADD(aBotVCC500, {"textjustify" ,{|| IIf(l2Via,FS_2VIA(oLbTexto:nAt),.t.) }, STR0044 } ) // Liberar 2ª.Via da Ficha'
If ( VV1->(FieldPos("VV1_BLQPRO")) > 0 )
	AADD(aBotVCC500, {"BPMSDOCE" ,{|| FS_BLQVEI(oLbTexto:nAt) }, STR0074 } ) // Bloqueia Prospeccao do Veiculo
EndIf
If FindFunction("VEICM660")
	AADD(aBotVCC500, {"cargaseq" ,{|| VEICM660() }, STR0090 } ) // Roteiro de Visitas
EndIf
AADD(aBotVCC500, {"EDIT" ,{|| FS_BCCONHEC() }, STR0104 } ) // Bco de conhecimento
AADD(aBotVCC500, {"critica" ,{|| VCC500LEG() }, STR0119 } ) // Legenda Pesq.Satisfacao
//////////////////////////////

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  78 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox
aAdd( aObjects, { 0 , 132 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )

If ExistBlock("VC500AFI")
	ExecBlock("VC500AFI",.f.,.f.)
EndIf

FS_FILTRAR(0,1)

cIBGE := IIf(SA1->(FieldPos("A1_IBGE")) > 0,SPACE(TamSx3('A1_IBGE')[1]),"")
DbSelectArea("VC1")
DEFINE MSDIALOG oDlgContCEV TITLE cTitTela From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oDlgContCEV:lEscClose := .F.
//
nTam := Int((aPos[1,4]/3))
//
@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[1,3], aPos[1,4] LABEL "" OF oDlgContCEV PIXEL // TODO: deveria ter diminuido o tamanho do listbox de resultados
@ aPos[1,1]+005,aPos[1,2]+004+(nTam*0) SAY STR0010 SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+033+(nTam*0) MSGET oTipAge VAR cTipAge F3 "VC5" VALID FS_VAL_VCC500("TP",.t.) PICTURE X3Picture("VC1_TIPAGE") SIZE 20,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+057+(nTam*0) MSGET oNomAge VAR cNomAge SIZE (nTam*1)-74,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[1,1]+017,aPos[1,2]+004+(nTam*0) SAY (STR0004+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+016,aPos[1,2]+033+(nTam*0) MSGET oCodVen VAR cCodVen F3 "SA3" VALID FS_VAL_VCC500("VD",.t.) PICTURE X3Picture("A3_COD") SIZE 30,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN ( !lCEVOUT .or. VAI->VAI_CEVOUT=="1" )
@ aPos[1,1]+016,aPos[1,2]+069+(nTam*0) MSGET oNomVen VAR cNomVen SIZE (nTam*1)-86,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[1,1]+028,aPos[1,2]+004+(nTam*0) MSCOMBOBOX oCliPros VAR cCliPros ITEMS aCliPros ON CHANGE FS_CLIPROS() SIZE 38,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+043+(nTam*0) MSGET oCodCli VAR cCodCli F3 "SA1" VALID FS_VAL_VCC500("CL",.t.) PICTURE X3Picture("A1_COD") SIZE 30,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+076+(nTam*0) MSGET oLojCli VAR cLojCli VALID FS_VAL_VCC500("CL",.t.) PICTURE X3Picture("A1_LOJA") SIZE 10,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+043+(nTam*0) MSGET oCdPros VAR cCdPros F3 "SUS" VALID FS_VAL_VCC500("PR",.t.) PICTURE X3Picture("US_COD") SIZE 30,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+076+(nTam*0) MSGET oLjPros VAR cLjPros VALID FS_VAL_VCC500("PR",.t.) PICTURE X3Picture("US_LOJA") SIZE 10,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+103+(nTam*0) MSGET oNomCli VAR cNomCli SIZE (nTam*1)-120,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[1,1]+028,aPos[1,2]+043+(nTam*0) MSGET oTodCli VAR STR0011 PICTURE "@!" SIZE (nTam*1)-60,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
oTodCli:lVisible := .f.
//
@ aPos[1,1]+041,aPos[1,2]+004+(nTam*0) SAY STR0110 SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+040,aPos[1,2]+033+(nTam*0) MSGET oIBGE VAR cIBGE F3 "AM1" VALID FS_VAL_VCC500("IBGE",.t.) PICTURE X3Picture("A1_IBGE") SIZE 50,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN ( cCliPros <> "2" )
@ aPos[1,1]+040,aPos[1,2]+085+(nTam*0) MSGET oDesCid VAR cDesCid SIZE (nTam*1)-102,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[1,1]+053,aPos[1,2]+004+(nTam*0) SAY (STR0015+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+052,aPos[1,2]+033+(nTam*0) MSCOMBOBOX oContat VAR cContat ITEMS aContat VALID FS_CONTATOS() SIZE (nTam*1)-50,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+065,aPos[1,2]+004+(nTam*0) SAY (STR0091+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+064,aPos[1,2]+033+(nTam*0) MSCOMBOBOX oProdut VAR cProdut ITEMS aProdut SIZE (nTam*1)-50,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN lProdut
////
@ aPos[1,1]+005,aPos[1,2]+001+(nTam*1) SAY (STR0107 + ':') SIZE 45, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+030+(nTam*1) MSGET oGetTipAbor VAR cTipAbor F3 "VCA" PICTURE "@!" SIZE 50, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .T.
@ aPos[1,1]+017,aPos[1,2]+001+(nTam*1) SAY (STR0003+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+016,aPos[1,2]+030+(nTam*1) MSGET oDtAgeI VAR dDtAgeI VALID FS_CONTATOS() PICTURE "@D" SIZE 40,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+017,aPos[1,2]+073+(nTam*1) SAY STR0024 SIZE 20,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+016,aPos[1,2]+084+(nTam*1) MSGET oDtAgeF VAR dDtAgeF VALID(dDtAgeF>=dDtAgeI .and. FS_CONTATOS()) PICTURE "@D" SIZE 40,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+029,aPos[1,2]+001+(nTam*1) SAY (STR0023+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+030+(nTam*1) MSGET oDtVisI VAR dDtVisI PICTURE "@D" SIZE 40,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN lDtVis
@ aPos[1,1]+029,aPos[1,2]+073+(nTam*1) SAY STR0024 SIZE 20,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+084+(nTam*1) MSGET oDtVisF VAR dDtVisF VALID(dDtVisF>=dDtVisI) PICTURE "@D" SIZE 40,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN lDtVis
@ aPos[1,1]+041,aPos[1,2]+001+(nTam*1) CHECKBOX oCheck VAR lCheck PROMPT STR0025 OF oDlgContCEV SIZE 180,08 PIXEL COLOR CLR_BLUE WHEN lTodos
@ aPos[1,1]+053,aPos[1,2]+001+(nTam*1) SAY (STR0058+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+052,aPos[1,2]+045+(nTam*1) MSCOMBOBOX oPesSat VAR cPesSat ITEMS aPesSat SIZE 105,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+065,aPos[1,2]+001+(nTam*1) SAY (STR0085+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+064,aPos[1,2]+045+(nTam*1) MSCOMBOBOX oInsati VAR cInsati ITEMS aInsati SIZE 105,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE

//
@ aPos[1,1]+005,aPos[1,2]+001+(nTam*2) SAY (STR0086+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,aPos[1,2]+038+(nTam*2) MSCOMBOBOX oMotEnc VAR cMotEnc ITEMS aMotEnc SIZE 115,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN lMotEnc
@ aPos[1,1]+017,aPos[1,2]+001+(nTam*2) SAY (STR0099+":") SIZE 45,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+016,aPos[1,2]+038+(nTam*2) MSCOMBOBOX oIntCEV VAR cIntCEV ITEMS aIntCEV SIZE 115,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+030,aPos[1,2]+001+(nTam*2) SAY (STR0106 + ':') SIZE 45, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+038+(nTam*2) MSGET oGetTipCon VAR cTipCon F3 "VC0" PICTURE "@!" SIZE 50, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .T.
@ aPos[1,1]+042,aPos[1,2]+001+(nTam*2) SAY (STR0108 + ':') SIZE 60, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+040,aPos[1,2]+060+(nTam*2) MSGET oGetQtdVis VAR nQtdVisPer VALID POSITIVO(nQtdVisPer) PICTURE "@ 9" SIZE 50, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .T.
@ aPos[1,1]+054,aPos[1,2]+001+(nTam*2) SAY (STR0109 +':') SIZE 45, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+052,aPos[1,2]+038+(nTam*2) MSGET oGetSegCli VAR M->VCF_CODSEG F3 "VX5" PICTURE "@!" SIZE 50, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .T.

@ aPos[1,1]+065,aPos[1,2]+001+(nTam*2) SAY (RetTitle("VCF_NIVIMP") + ':') SIZE 60,08 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+064,aPos[1,2]+038+(nTam*2) MSGET oGetNivImp VAR M->VCF_NIVIMP PICTURE "@!" SIZE 20, 08 OF oDlgContCEV PIXEL COLOR CLR_BLUE WHEN .T.
//
//@ aPos[1,1]+065,aPos[1,2]+000+(nTam*2.2) BUTTON oFiltrar PROMPT UPPER(STR0009) OF oDlgContCEV SIZE 35,10 PIXEL ACTION (FS_FILTRAR(1,1),FS_OBSVC500())
@ aPos[1,1]+065,aPos[1,2]+080+(nTam*2.2) BUTTON oFiltrar PROMPT UPPER(STR0009) OF oDlgContCEV SIZE 35,10 PIXEL ACTION (FS_FILTRAR(1,1),FS_OBSVC500())

if TYPE("aSelFil") == "U" 
	//@ aPos[1,1]+065,aPos[1,2]+040+(nTam*2.2) BUTTON oFiliais PROMPT UPPER(STR0114) OF oDlgContCEV SIZE 35,10 PIXEL ACTION (FS_FILIAIS(),FS_FILTRAR(1,1),FS_OBSVC500()) // Filiais
	@ aPos[1,1]+065,aPos[1,2]+120+(nTam*2.2) BUTTON oFiliais PROMPT UPPER(STR0114) OF oDlgContCEV SIZE 35,10 PIXEL ACTION (FS_FILIAIS(),FS_FILTRAR(1,1),FS_OBSVC500()) // Filiais
Endif	
//
@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbTexto FIELDS HEADER "",;  // Status 1
						"",;      // Pesq.Satisfacao 17
						STR0115,; // Filial 23
						STR0002,; // Tp Agenda 2
						STR0003,; // Dt Agenda 3
						STR0023,; // Dt Visita 4
						STR0004,; // Vendedor  5 6
						STR0097,; // Vendedor NF"  
						STR0006+"/"+STR0012,;  // Cliente / Prospect 7 8
						STR0098,; // Proprietário 
						STR0045,; // Fone
						STR0103,; // Contato
						STR0014,; // Cidade-UF
						STR0028,; // Tipo de Abordagem
						STR0029,; // Tipo de Contato
						RetTitle("VCF_NIVIMP") ; // Nivel de Importancia do Cliente
						COLSIZES 10,10,40,18,30,30,65,65,110,110,105,110,100,80,80,40 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1] OF oDlgContCEV PIXEL ON CHANGE FS_OBSVC500()

oLbTexto:SetArray(aVetor)
oLbTexto:bLine := { || { VEICC500001_ConvStrToSemaforo(aVetor[oLbTexto:nAt,1]),;
						IIf(aVetor[oLbTexto:nAt,17]==1,oLbOK,IIf(aVetor[oLbTexto:nAt,17]==2,oLbTIK,IIf(aVetor[oLbTexto:nAt,17]==3,oLbCa,oLbNO))) ,;
						aVetor[oLbTexto:nAt,23] ,;
						aVetor[oLbTexto:nAt,2] ,;
						aVetor[oLbTexto:nAt,3] ,;
						aVetor[oLbTexto:nAt,4] ,;
						aVetor[oLbTexto:nAt,5]+" "+left(aVetor[oLbTexto:nAt,6],15) ,;
						aVetor[oLbTexto:nAt,19] ,;
						IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,aVetor[oLbTexto:nAt,7],aVetor[oLbTexto:nAt,22])+" "+FG_Alinvlrs( left(aVetor[oLbTexto:nAt,8],15), "E")+" "+FG_Alinvlrs( right(aVetor[oLbTexto:nAt,8],20), "E") ,;
						aVetor[oLbTexto:nAt,20] ,;
						aVetor[oLbTexto:nAt,14] ,;
						aVetor[oLbTexto:nAt,21] ,;
						aVetor[oLbTexto:nAt,9] ,;
						aVetor[oLbTexto:nAt,12] ,;
						aVetor[oLbTexto:nAt,13] ,;
						aVetor[oLbTexto:nAt,24] }}

@ aPos[3,1]-002,aPos[3,2]+000 TO aPos[3,1]+050,(aPos[3,4]/2)-2 LABEL STR0081 OF oDlgContCEV PIXEL // Objetivo
@ aPos[3,1]+005,aPos[3,2]+001 GET oCEVObjetiv VAR cObjetiv OF oDlgContCEV MEMO SIZE (aPos[3,4]/2)-7,043 PIXEL READONLY MEMO

@ aPos[3,1]-002,(aPos[3,4]/2)+000 TO aPos[3,1]+050,aPos[3,4] LABEL STR0082 OF oDlgContCEV PIXEL // Ocorrencia
@ aPos[3,1]+005,(aPos[3,4]/2)+001 GET oCEVObserv VAR cObserv OF oDlgContCEV MEMO SIZE (aPos[3,4]/2)-2,043 PIXEL READONLY MEMO

nTam := Int((aPos[3,4]/3))

//@ aPos[3,1]+050,aPos[3,2]+(nTam*0)-000 TO aPos[3,3],aPos[3,2]+((nTam*2)-2) LABEL STR0030 OF oDlgContCEV PIXEL
oTPanelInt := TPanel():New( aPos[3,1]+050 ,aPos[3,2]+(nTam*0) ,"",oDlgContCEV,NIL,.T.,.F.,NIL,NIL,aPos[3,2]+((nTam*2)-5),aPos[3,3]-aPos[3,1]-50,.T.,.F.)
oLbInterC := FWBrowse():New()
oLbInterC:SetOwner(oTPanelInt)
oLbInterC:SetDataQuery()
oLbInterC:SetDescription(STR0030)
oLbInterC:SetAlias("SQLVDM")
oLbInterC:SetColumns(VDMColunas())
oLbInterC:SetQuery(FS_SQLVDM("","","",""))
oLbInterC:Activate() // Ativação do Browse
oLbInterC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oLbInterC:SetDoubleClick( { || IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,(VEICM680(left(aVetor[oLbTexto:nAt,7],nTCdCli),right(aVetor[oLbTexto:nAt,7],nTLjCli)),FS_OBSVC500()),.t.) } )
oLbInterC:Refresh()
oLbInterC:GoTop()

@ aPos[3,1]+053,aPos[3,2]+(nTam*2)+001 TO aPos[3,1]+086,aPos[3,2]+((nTam*3)-2) LABEL "" OF oDlgContCEV PIXEL
@ aPos[3,1]+056,aPos[3,2]+(nTam*2)+004 SAY STR0021 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[3,1]+055,aPos[3,2]+(nTam*3)-075 MSGET oTot1 VAR cTot1 SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.
@ aPos[3,1]+066,aPos[3,2]+(nTam*2)+004 BITMAP OXverde RESOURCE "BR_verde"  OF oDlgContCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+066,aPos[3,2]+(nTam*2)+013 SAY STR0008 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[3,1]+065,aPos[3,2]+(nTam*3)-075 MSGET overd VAR cverd SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.
@ aPos[3,1]+076,aPos[3,2]+(nTam*2)+004 BITMAP OXverme RESOURCE "BR_vermelho" OF oDlgContCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+076,aPos[3,2]+(nTam*2)+013 SAY STR0007 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[3,1]+075,aPos[3,2]+(nTam*3)-075 MSGET overm VAR cverm SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.

@ aPos[3,1]+089,aPos[3,2]+(nTam*2)+001 TO aPos[3,1]+132,aPos[3,2]+((nTam*3)-2) LABEL "" OF oDlgContCEV PIXEL
@ aPos[3,1]+092,aPos[3,2]+(nTam*2)+004 SAY STR0022 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[3,1]+091,aPos[3,2]+(nTam*3)-075 MSGET oTot2 VAR cTot2 SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.
@ aPos[3,1]+102,aPos[3,2]+(nTam*2)+004 BITMAP OXazull RESOURCE "BR_azul" OF oDlgContCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+102,aPos[3,2]+(nTam*2)+013 SAY STR0016 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE
@ aPos[3,1]+101,aPos[3,2]+(nTam*3)-075 MSGET oazul VAR cazul SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.
@ aPos[3,1]+112,aPos[3,2]+(nTam*2)+004 BITMAP oXlaranja RESOURCE "BR_LARANJA" OF oDlgContCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+112,aPos[3,2]+(nTam*2)+013 SAY STR0116 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE // "Antes da data agendada"
@ aPos[3,1]+111,aPos[3,2]+(nTam*3)-075 MSGET olara VAR clara SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.
@ aPos[3,1]+122,aPos[3,2]+(nTam*2)+004 BITMAP OXcinza RESOURCE "BR_cinza" OF oDlgContCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+122,aPos[3,2]+(nTam*2)+013 SAY STR0118 SIZE 80,10 OF oDlgContCEV  PIXEL COLOR CLR_BLUE // "Após data agendada"
@ aPos[3,1]+121,aPos[3,2]+(nTam*3)-075 MSGET ocinz VAR ccinz SIZE 72,08 OF oDlgContCEV PIXEL COLOR CLR_BLUE when .f.

ACTIVATE MSDIALOG oDlgContCEV ON INIT (EnchoiceBar(oDlgContCEV,{|| oDlgContCEV:End() }, {|| oDlgContCEV:End() },,aBotVCC500),)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_CLIPROS³ Autor ³ Andre Luis Almeida     ³ Data ³ 14/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cliente ou Prospect                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLIPROS()
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
oTodCli:lVisible := .f.
If cCliPros == "1" // Cliente
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
	FS_VAL_VCC500("CL",.t.)
	oCodCli:SetFocus()
ElseIf cCliPros == "2" // Prospect
	cIBGE := IIf(SA1->(FieldPos("A1_IBGE")) > 0,SPACE(TamSx3('A1_IBGE')[1]),"")
	oIBGE:Refresh()
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
	FS_VAL_VCC500("PR",.t.)
	oCdPros:SetFocus()
Else // Todos Cliente e Prospect
	oTodCli:lVisible := .t.
EndIf
oCodCli:Refresh()
oLojCli:Refresh()
oCdPros:Refresh()
oLjPros:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Filtra Contatos CEV                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp,nPosLinha) // Filtra Contatos
Local cQAlias     := "SQLVC1"
Local cQuery      := ""
Local ni          := 0
Local cTpPesq     := ""
Local aVetAux     := {}
Local lObjeti     := ( VC1->(FieldPos("VC1_OBSOBJ")) > 0 )
Local lA1_IBGE    := ( SA1->(FieldPos("A1_IBGE"))    > 0 )
Local lA1_CELULAR := ( SA1->(FieldPos("A1_CELULAR")) > 0 )
Local lA1_RESPST  := ( SA1->(FieldPos("A1_RESPST"))  > 0 )
Local lCEVTPA     := ( VAI->(FieldPos("VAI_CEVTPA")) > 0 )
Local lVC1ESTVEI  := ( VC1->(FieldPos("VC1_ESTVEI")) > 0 )
Local lVAQ_TIPOSI := ( VAQ->(FieldPos("VAQ_TIPOSI")) > 0 )
Local cCEVTPA     := ""
Local cAux        := ""
Local nverd       := 0
Local nverm       := 0
Local nazul       := 0
Local nlara       := 0
Local ncinz       := 0
Local cXCodCli    := ""
Local cXLojCli    := ""
Local cXCdPros    := ""
Local cXLjPros    := ""
Local cFilVDL     := xFilial("VDL")
Local cNomVDL     := RetSqlName("VDL")
Local cNomVDM     := RetSqlName("VDM")
Local aQtdVisPer  := {}
Local nTCdCli     := TamSX3("A1_COD")[1]
Local nTLjCli     := TamSX3("A1_LOJA")[1] 
Local cCidade     := ""
Local lAchou      := .t.
Local cFone       := ""
Local cBkpFilAnt  := cFilAnt
Local nCont       := 0
Default nPosLinha := 1
aVetor   := {}
cObjetiv := ""
cObserv  := ""
If nTp > 0
	oCEVObjetiv:Refresh()
	oCEVObserv:Refresh()
EndIf

if TYPE("aSelFil") == "U"  
	lAchou := .f.
	aSelFil := aClone(aEmpr)
Endif 

//
For nCont := 1 to Len(aSelFil)
	if !lAchou
		cFilAnt := aSelFil[nCont,1]
	Else
		cFilAnt := aSelFil[nCont]
	Endif	
	//
	cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_DATVIS , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_CDPROS , VC1.VC1_LJPROS , VC1.VC1_CODVEN , VC1.R_E_C_N_O_ AS RECVC1 , VC1.VC1_OCOMEM , A1_SATIV5 , "
	If lMOTPNR
		cQuery += "VC1.VC1_MOTPNR , "
	EndIf
	If lObjeti
		cQuery += "VC1.VC1_OBSOBJ , "
	EndIf
	cQuery += "VC1.VC1_CODABO , VC1.VC1_TIPCON , VC1.VC1_ORIGEM , VC1.VC1_TIPORI , VC1.VC1_NOMCON , "
	If lVC1ESTVEI
		cQuery += "VC1.VC1_ESTVEI , "
	EndIf
	cQuery += "SA1.A1_NOME , SA1.A1_MUN , SA1.A1_EST , SA1.A1_TEL , "
	cQuery += "SUS.US_NOME , SUS.US_MUN , SUS.US_EST , SUS.US_TEL , "
	If lA1_CELULAR
		cQuery += "SA1.A1_CELULAR , "
	EndIf
	If lA1_RESPST
		cQuery += "SA1.A1_RESPST , "
	EndIf
	If lA1_IBGE
		cQuery += "VAM.VAM_DESCID , VAM.VAM_ESTADO , VAM.VAM_DDD ,  "
	EndIf
	cQuery += "SA3.A3_NOME , VCA.VCA_DESABO , VC0.VC0_DESCON , VCF.VCF_NIVIMP  "
	cQuery += "FROM "+RetSqlName("VC1")+" VC1 "
	cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC1.VC1_CODCLI AND SA1.A1_LOJA=VC1.VC1_LOJA AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SUS")+" SUS ON ( SUS.US_FILIAL='"+xFilial("SUS")+"' AND SUS.US_COD=VC1.VC1_CDPROS AND SUS.US_LOJA=VC1.VC1_LJPROS AND SUS.D_E_L_E_T_=' ' ) "
	If lA1_IBGE
		cQuery += "LEFT JOIN "+RetSqlName("VAM")+" VAM ON ( VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' ) "
	EndIf
	cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VC1.VC1_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VCA")+" VCA ON ( VCA.VCA_FILIAL='"+xFilial("VCA")+"' AND VCA.VCA_CODABO=VC1.VC1_CODABO AND VCA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VC0")+" VC0 ON ( VC0.VC0_FILIAL='"+xFilial("VC0")+"' AND VC0.VC0_TIPCON=VC1.VC1_TIPCON AND VC0.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VCF")+" VCF ON ( VCF.VCF_FILIAL='"+xFilial("VCF")+"' AND VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI = SA1.A1_LOJA AND VCF.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
	If !Empty(cTipAge)
		cQuery += "VC1.VC1_TIPAGE='"+cTipAge+"' AND "
	EndIf
	If lCEVTPA
		VAI->(DbSetOrder(4))
		VAI->(DbSeek(xFilial("VAI")+__cUserID))
		If !Empty(VAI->VAI_CEVTPA)
			cCEVTPA := ""
			cAux    := Alltrim(VAI->VAI_CEVTPA)
			While len(cAux) > 0
				cCEVTPA += "'"+substr(cAux,1,TamSX3("VC1_TIPAGE")[1])+"',"
				cAux := substr(cAux,TamSX3("VC1_TIPAGE")[1]+1)
			EndDo
			cCEVTPA := left(cCEVTPA,len(cCEVTPA)-1)
			cQuery += "VC1.VC1_TIPAGE IN ("+cCEVTPA+") AND "
		EndIf
	EndIf
	If !Empty(cCodVen)
		cQuery += "VC1.VC1_CODVEN='"+cCodVen+"' AND "
	EndIf
	//
	Do Case
		Case !Empty(cCodCli) .and. !Empty(cCdPros) // Trazer Cliente e Prospect
			cQuery += "( ( VC1.VC1_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND VC1.VC1_LOJA='"+cLojCli+"'","")+" )"
			cQuery += " OR "
			cQuery += "( VC1.VC1_CDPROS='"+cCdPros+"' "+IIf(!Empty(cLjPros),"AND VC1.VC1_LJPROS='"+cLjPros+"'","")+" ) ) AND "
		Case !Empty(cCodCli) // Trazer somente o Cliente
			cQuery += "( VC1.VC1_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND VC1.VC1_LOJA='"+cLojCli+"'","")+" ) AND "
		Case !Empty(cCdPros) // Trazer somente o Prospect
			cQuery += "( VC1.VC1_CDPROS='"+cCdPros+"' "+IIf(!Empty(cLjPros),"AND VC1.VC1_LJPROS='"+cLjPros+"'","")+" ) AND "
		Case cCliPros == "1" // Trazer todos os Clientes
			cQuery += "VC1.VC1_CODCLI<>' ' AND "
		Case cCliPros == "2" // Trazer todos os Prospects
			cQuery += "VC1.VC1_CDPROS<>' ' AND "
	EndCase
	//
	If lA1_IBGE .and. !Empty(cIBGE)
		cQuery += "SA1.A1_IBGE='"+cIBGE+"' AND "
	EndIf
	If lCheck // Mostrar TODOS os contatos atrasados
		cQuery += "( "
		cQuery += "( VC1.VC1_DATVIS=' ' AND VC1.VC1_DATAGE<'"+dtos(dDataBase)+"' ) "
		cQuery += "OR "
		cQuery += "( VC1.VC1_DATAGE>='"+dtos(dDtAgeI)+"' AND VC1.VC1_DATAGE<='"+dtos(dDtAgeF)+"' AND VC1.VC1_DATVIS>='"+dtos(dDtVisI)+"' AND VC1.VC1_DATVIS<='"+dtos(dDtVisF)+"' ) "
		cQuery += ") AND "
	Else // Filtrar pelas Datas da Agenda e Visita/Abordagem
		cQuery += "VC1.VC1_DATAGE>='"+dtos(dDtAgeI)+"' AND VC1.VC1_DATAGE<='"+dtos(dDtAgeF)+"' AND "
		cQuery += "VC1.VC1_DATVIS>='"+dtos(dDtVisI)+"' AND VC1.VC1_DATVIS<='"+dtos(dDtVisF)+"' AND "
	EndIf
	If cContat <> STR0013
		If (cContat == (STR0021+" - "+STR0008))
			cQuery += "VC1.VC1_DATAGE>='"+dtos(dDataBase)+"' AND VC1.VC1_DATVIS=' ' AND "
		ElseIf (cContat == (STR0021+" - "+STR0007))
			cQuery += "VC1.VC1_DATAGE<'"+dtos(dDataBase)+"' AND VC1.VC1_DATVIS=' ' AND "
		ElseIf (cContat == (STR0022+" - "+STR0016))
			cQuery += "VC1.VC1_DATAGE=VC1.VC1_DATVIS AND VC1.VC1_DATVIS<>' ' AND "
		ElseIf (cContat == (STR0022+" - "+STR0017))
			cQuery += "VC1.VC1_DATVIS <> VC1.VC1_DATAGE AND VC1.VC1_DATVIS <> ' ' AND "
		ElseIf (cContat == STR0022+" - "+STR0117) //Até a Data Agendada
			cQuery += "VC1.VC1_DATVIS <= VC1.VC1_DATAGE AND VC1.VC1_DATVIS <> ' ' AND "
		ElseIf (cContat == STR0022+" - "+STR0118) // Após a Data Agendada
			cQuery += "VC1.VC1_DATVIS >  VC1.VC1_DATAGE AND VC1.VC1_DATVIS <> ' ' AND "
		ElseIf cContat == STR0022
			cQuery += "VC1.VC1_DATVIS != ' ' AND "
		EndIf
	EndIf
	If lMotEnc
		If !Empty(cMotEnc)
			If cMotEnc == STR0088 // Possui qualquer motivo de encerramento
				cQuery += "VC1.VC1_MOTIVO<>' ' AND "
			ElseIf cMotEnc == STR0087 // Não possui motivo de encerramento
				cQuery += "VC1.VC1_MOTIVO=' ' AND "
			Else
				cQuery += "VC1.VC1_MOTIVO='"+substr(cMotEnc,3,6)+"' AND "
			EndIf
		EndIf
	EndIf
	If lProdut
		If !Empty(cProdut)
			If cProdut == "0" // Contatos nao produtivos
				cQuery += "VC1.VC1_DATVIS<>' ' AND VC1.VC1_CONPRO='0' AND "
			Else // Contatos produtivos
				cQuery += "VC1.VC1_DATVIS<>' ' AND VC1.VC1_CONPRO<>'0' AND "
			EndIf
		EndIf
	EndIf
	// cTipCon(VC1_TIPCON)
	If !Empty(cTipCon)
		cQuery += " VC1.VC1_TIPCON = '" +cTipCon+ "' AND "
	EndIf
	// Segmento do Cliente
	If !Empty(M->VCF_CODSEG)
		cQuery += " VCF.VCF_CODSEG = '" +M->VCF_CODSEG+ "' AND "
	EndIf
	// Nivel de Importancia do Cliente
	If !Empty(M->VCF_NIVIMP)
		cQuery += " VCF.VCF_NIVIMP = '" +M->VCF_NIVIMP+ "' AND "
	EndIf
	//cTipAbor
	If !Empty(cTipAbor)
		cQuery += " VC1_CODABO = '" +cTipAbor+ "' AND "
	EndIf
	cQuery += "VC1.D_E_L_E_T_=' ' ORDER BY VC1.VC1_DATVIS DESC, VC1.VC1_DATAGE , VC1.VC1_TIPAGE , VC1.VC1_CODVEN , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_CDPROS , VC1.VC1_LJPROS "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		// Validando numero max. de registros no periodo
		If !Empty(( cQAlias )->( VC1_CODCLI ))
			nIdx := ASCAN( aQtdVisPer, { |el| el[1]+el[3] == ( cQAlias )->VC1_CODCLI+( cQAlias )->VC1_LOJA+"SA1" } )
			If nIdx > 0
				If aQtdVisPer[nIdx][2] == nQtdVisPer //Qtd
					( cQAlias )->( DbSkip() )
					LOOP
				EndIf
				aQtdVisPer[nIdx][2] += 1
			Else
				aAdd( aQtdVisPer, {( cQAlias )->VC1_CODCLI+( cQAlias )->VC1_LOJA,1,"SA1"} )
			EndIf
		ElseIf !Empty(( cQAlias )->( VC1_CDPROS ))
			nIdx := ASCAN( aQtdVisPer, { |el| el[1]+el[3] == ( cQAlias )->VC1_CDPROS+( cQAlias )->VC1_LJPROS+"SUS" } )
			If nIdx > 0
				If aQtdVisPer[nIdx][2] == nQtdVisPer //Qtd
					( cQAlias )->( DbSkip() )
					LOOP
				EndIf
				aQtdVisPer[nIdx][2] += 1
			Else
				aAdd( aQtdVisPer, {( cQAlias )->VC1_CDPROS+( cQAlias )->VC1_LJPROS,1,"SUS"} )
			EndIf
		EndIf
		If !Empty(cInsati) .and. !Empty(( cQAlias )->( VC1_CODCLI )) // Filtrar se o Cliente possui ou nao Registro de Satisfacao / Insatisfacao
			Do Case
				Case cInsati == "0" // usuario escolheu: Cliente sem Registro de Insatisfacao
					cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
					If lVAQ_TIPOSI
						cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI<>'1' AND VAQ.D_E_L_E_T_=' ' ) "
					EndIf
					cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+( cQAlias )->( VC1_CODCLI )+"' AND "
					cQuery += "VAO.VAO_LOJCLI='"+( cQAlias )->( VC1_LOJA )+"' AND VAO.D_E_L_E_T_=' '"
					If FM_SQL(cQuery) > 0 // Encontrou registro
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case cInsati == "1" // usuario escolheu: Cliente com Registro de Insatisfacao
					cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
					If lVAQ_TIPOSI
						cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI<>'1' AND VAQ.D_E_L_E_T_=' ' ) "
					EndIf
					cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+( cQAlias )->( VC1_CODCLI )+"' AND "
					cQuery += "VAO.VAO_LOJCLI='"+( cQAlias )->( VC1_LOJA )+"' AND VAO.D_E_L_E_T_=' '"
					If FM_SQL(cQuery) <= 0 // Nao encontrou registro
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case cInsati == "2" // usuario escolheu: Cliente sem Registro de Satisfacao
					cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
					If lVAQ_TIPOSI
						cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI='1' AND VAQ.D_E_L_E_T_=' ' ) "
					EndIf
					cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+( cQAlias )->( VC1_CODCLI )+"' AND "
					cQuery += "VAO.VAO_LOJCLI='"+( cQAlias )->( VC1_LOJA )+"' AND VAO.D_E_L_E_T_=' '"
					If FM_SQL(cQuery) > 0 // Encontrou registro
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case cInsati == "3" // usuario escolheu: Cliente com Registro de Satisfacao
					cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
					If lVAQ_TIPOSI
						cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI='1' AND VAQ.D_E_L_E_T_=' ' ) "
					EndIf
					cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+( cQAlias )->( VC1_CODCLI )+"' AND "
					cQuery += "VAO.VAO_LOJCLI='"+( cQAlias )->( VC1_LOJA )+"' AND VAO.D_E_L_E_T_=' '"
					If FM_SQL(cQuery) <= 0 // Nao Encontrou registro
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
			EndCase
		EndIf	
		//
		nPosVC1  := ( cQAlias )->( RECVC1 )
		cCidade  := ""
		cFone    := ""
		cValIdx8 := ""
		cPropVei := ""
		cVendNF  := ""
		//		
		If  ( cQAlias )->( VC1_TIPORI ) == "B" // Balcao      
			DbSelectArea("VS1")
			DbSetOrder(1)
			DbSeek(xFilial("VS1")+Right( Alltrim ( ( cQAlias )->( VC1_ORIGEM )) ,8))
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
			cQuery := "SELECT A1_NOME FROM "+RetSqlName("SA1")+" "
			cQuery += "WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VV1->VV1_PROATU+"' AND "
			cQuery += "A1_LOJA='"+VV1->VV1_LJPATU+"' AND D_E_L_E_T_=' '"
			cPropVei := Left(FM_SQL(cQuery),30)
			cQuery := "SELECT A3_NOME FROM "+RetSqlName("SA3")+" "
			cQuery += "WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VS1->VS1_CODVEN+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cVendNF := Left(FM_SQL(cQuery),30)
		ElseIf  ( cQAlias )->( VC1_TIPORI ) == "O" // Oficina
			DbSelectArea("VO1")
			DbSetOrder(1)
			DbSeek(xFilial("VO1")+Right( Alltrim( ( cQAlias )->( VC1_ORIGEM )) ,8))
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)
			cQuery := "SELECT A1_NOME FROM "+RetSqlName("SA1")+" "
			cQuery += "WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VV1->VV1_PROATU+"' AND "
			cQuery += "A1_LOJA='"+VV1->VV1_LJPATU+"' AND D_E_L_E_T_=' '"
			cPropVei := Left(FM_SQL(cQuery),30)
			cQuery := "SELECT A3_NOME FROM "+RetSqlName("SA3")+" "
			cQuery += "WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VO1->VO1_FUNABE+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cVendNF := Left(FM_SQL(cQuery),30)
		ElseIf  ( cQAlias )->( VC1_TIPORI ) == "V" // Veiculos
			DbSelectArea("VV0")
			DbSetOrder(1)
			DbSeek(xFilial("VV0")+( cQAlias )->( VC1_ORIGEM ))
			cQuery := "SELECT A1_NOME FROM "+RetSqlName("SA1")+" "
			cQuery += "WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VV0->VV0_CODCLI+"' AND "
			cQuery += "A1_LOJA='"+VV0->VV0_LOJA+"' AND D_E_L_E_T_=' '"
			cPropVei := Left(FM_SQL(cQuery),30)
			cQuery := "SELECT A3_NOME FROM "+RetSqlName("SA3")+" "
			cQuery += "WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VV0->VV0_CODVEN+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cVendNF := Left(FM_SQL(cQuery),30)
		Else
			If !Empty(( cQAlias )->( VC1_CODCLI ))
				cPropVei := Left(( cQAlias )->( A1_NOME )+space(30),30)
			ElseIf !Empty(( cQAlias )->( VC1_CDPROS ))
				cPropVei := Left("( "+UPPER(STR0012)+" )"+space(30),30) // Prospect
			EndIf
			cVendNF := Left(( cQAlias )->( A3_NOME )+space(30),30)
		Endif
		//
		If !Empty(( cQAlias )->( VC1_CODCLI ))
			cCidade := Alltrim(left(IIf(lA1_IBGE,( cQAlias )->( VAM_DESCID ),( cQAlias )->( A1_MUN )),22))+"-"+IIf(lA1_IBGE,( cQAlias )->( VAM_ESTADO ),( cQAlias )->( A1_EST ))
			cFone   := IIf(lA1_IBGE,"("+( cQAlias )->( VAM_DDD )+") ","")+Alltrim(( cQAlias )->( A1_TEL ))+IIf(lA1_CELULAR," / "+Alltrim(( cQAlias )->( A1_CELULAR )),"")
			// Caso exista o campo vamos formatar em 2 partes a coluna, caso contrario usamos tamanho total
			If( lA1_RESPST ) 
				cValIdx8 := PADR( ALLTRIM( (cQAlias)->(A1_RESPST) ) , 15 )
				cValIdx8 += PADR( ' ' + (cQAlias)->(A1_NOME), 20 )
			Else
				cValIdx8 := PADR( (cQAlias)->(A1_NOME), 35 )
			EndIf
		ElseIf !Empty(( cQAlias )->( VC1_CDPROS ))
			cCidade := Alltrim(left(( cQAlias )->( US_MUN ),22))+"-"+( cQAlias )->( US_EST )
			cFone   := Alltrim(( cQAlias )->( US_TEL ))
			cValIdx8 := PADR( (cQAlias)->(US_NOME), 35 )
		EndIf
		
		Aadd(aVetor,{"",;                                                          // 01
					( cQAlias )->( VC1_TIPAGE ),;                                  // 02
					stod(( cQAlias )->( VC1_DATAGE )),;                            // 03
					stod(( cQAlias )->( VC1_DATVIS )),;                            // 04
					( cQAlias )->( VC1_CODVEN ),;                                  // 05
					( cQAlias )->( A3_NOME ),;                                     // 06
					( cQAlias )->( VC1_CODCLI )+"-"+( cQAlias )->( VC1_LOJA ),;    // 07
					cValIdx8,;                                                     // 08
					cCidade,;                                                      // 09
					nPosVC1,;                                                      // 10
					( cQAlias )->( VC1_OCOMEM ),;                                  // 11
					( cQAlias )->( VCA_DESABO ),;                                  // 12
					( cQAlias )->( VC0_DESCON ),;                                  // 13
					cFone,;                                                        // 14
					( cQAlias )->( VC1_ORIGEM ),;                                  // 15
					( cQAlias )->( VC1_TIPORI ),;                                  // 16
					0,;                                                            // 17
					IIf(lObjeti,( cQAlias )->( VC1_OBSOBJ ),"") ,;                 // 18
					cVendNF,;                                                      // 19
					cPropVei,;                                                     // 20
					( cQAlias )->( VC1_NOMCON ),;                                  // 21
					( cQAlias )->( VC1_CDPROS )+"-"+( cQAlias )->( VC1_LJPROS ),;  // 22
					cFilAnt,;                                                      // 23
					( cQAlias )->( VCF_NIVIMP ) })                                 // 24  
	
		//// Acerta ORIGEM / TIPORI dos registros VC1 antigos ////
		If Empty(aVetor[len(aVetor),16]) .and. Empty(aVetor[len(aVetor),15])
			aVetor[len(aVetor),15] := strzero(nPosVC1,10)
			aVetor[len(aVetor),16] := "C" // CEV
			DbSelectArea("VC1")
			DbGoTo(nPosVC1)
			RecLock("VC1",.f.)
			VC1->VC1_ORIGEM := aVetor[len(aVetor),15]
			VC1->VC1_TIPORI := aVetor[len(aVetor),16]
			MsUnLock()
		EndIf
		////////////////////////////////////////////////////////////////////////
		Do Case
			Case aVetor[len(aVetor),16] == "V" // Veiculos
				cTpPesq := "001"
				If Empty( ( cQAlias )->( VC1_CODCLI ) + ( cQAlias )->( VC1_LOJA ) + ( cQAlias )->( VC1_CDPROS ) + ( cQAlias )->( VC1_LJPROS ) ) // CEV gerado SEM cliente ( Codigo / Loja )
					VV9->(DbSetOrder(1))
					VV9->(MsSeek(xFilial("VV9")+left(aVetor[len(aVetor),15],10)))
					aVetor[len(aVetor),8]  := VV9->VV9_NOMVIS // Nome
					aVetor[len(aVetor),14] := VV9->VV9_TELVIS // Fone
				EndIf
			Case aVetor[len(aVetor),16] == "O" // Oficina
				cTpPesq := "002"
			Case aVetor[len(aVetor),16] == "B" // Balcao
				cTpPesq := "003"
			Case aVetor[len(aVetor),16] == "C" // CEV
				cTpPesq := "004"
		EndCase
		aVetor[len(aVetor),17] := VCA100EXIS(cTpPesq,aVetor[len(aVetor),02],aVetor[len(aVetor),15],,) // Existencia da Pesquisa de Satisfacao
		If lMOTPNR // Existe campo MOTIVO da Pesquisa nao realizada
			If aVetor[len(aVetor),17] == 1 .and. !Empty(( cQAlias )->( VC1_MOTPNR ))
				aVetor[len(aVetor),17] := 3 // Pesquisa nao realizada com motivo
			EndIf
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
//
///////////////////////////////////
// Filtra Pesquisa de Satisfacao //
///////////////////////////////////
If !Empty(cPesSat)
	For ni := 1 to len(aVetor)
		If aVetor[ni,17] == val(cPesSat)
			aAdd(aVetAux,aClone(aVetor[ni]))
		EndIf
	Next
	aVetor := aClone(aVetAux)
EndIf
///////////////////////////////////
// Filtra Interesses             //
///////////////////////////////////
If !Empty(cIntCEV)
	aVetAux := {} 
	For ni := 1 to len(aVetor)
		cXCodCli := left(aVetor[ni,7],nTCdCli)
		cXLojCli := right(aVetor[ni,7],nTLjCli)
		cXCdPros := left(aVetor[ni,22],nTCdCli)
		cXLjPros := right(aVetor[ni,22],nTLjCli)
		//
		cFilAnt  := aVetor[ni,23]
		//
		cQuery := "SELECT COUNT(*) "
		cQuery += "FROM "+cNomVDL+" VDL "
		cQuery += "JOIN "+cNomVDM+" VDM ON ( VDM.VDM_FILIAL=VDL.VDL_FILIAL AND VDM.VDM_CODOPO=VDL.VDL_CODOPO AND VDM.VDM_MOTCAN=' ' AND VDM.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VDL.VDL_FILIAL='"+cFilVDL+"' AND "
		Do Case
			Case !Empty(cXCodCli) .and. !Empty(cXCdPros) // Trazer todos do Cliente e do Prospect
				cQuery += "( ( VDL.VDL_CODCLI='"+cXCodCli+"' AND VDL.VDL_LOJCLI='"+cXLojCli+"' ) OR ( VDL.VDL_CDPROS='"+cXCdPros+"' AND VDL.VDL_LJPROS='"+cXLjPros+"' ) ) AND "
			Case !Empty(cXCodCli) // Trazer somente do Cliente
				cQuery += "VDL.VDL_CODCLI='"+cXCodCli+"' AND VDL.VDL_LOJCLI='"+cXLojCli+"' AND "
			Case !Empty(cXCdPros) // Trazer somente do Prospect
				cQuery += "VDL.VDL_CDPROS='"+cXCdPros+"' AND VDL.VDL_LJPROS='"+cXLjPros+"' AND "
		EndCase
		cQuery += "VDL.D_E_L_E_T_=' ' "
		If cIntCEV==STR0100 // Cliente com interesse
			If !Empty(cXCodCli+cXCdPros) .and. FM_SQL(cQuery) >= 1
				aAdd(aVetAux,aClone(aVetor[ni]))
			EndIf
		ElseIf cIntCEV==STR0101 // Cliente sem interesse
			If Empty(cXCodCli+cXCdPros) .or. FM_SQL(cQuery) <= 0
				aAdd(aVetAux,aClone(aVetor[ni]))
			EndIf
		EndIf
	Next
	aVetor := aClone(aVetAux)
EndIf
//
cFilAnt := cBkpFilAnt
//
///////////////////////////////////
// Totalizadores rodape TELA     //
///////////////////////////////////
For ni := 1 to len(aVetor)
	If Empty(aVetor[ni,4])
		If aVetor[ni,3] < ddatabase
			nverm++
			aVetor[ni,1] := "verm"
		Else
			nverd++
			aVetor[ni,1] := "verd"
		EndIf
	Else
		If aVetor[ni,4] == aVetor[ni,3] // na data
			nazul++
			aVetor[ni,1] := "azul"
		ElseIf aVetor[ni, 4] > aVetor[ni, 3] // (data visita > data agenda) atrasada
			ncinz++
			aVetor[ni,1] := "cinz"
		Else
			nlara++
			aVetor[ni,1] := "lara" // antecipada
		EndIf
	EndIf
Next      
//
cTot1 := FG_AlinVlrs(Transform(nverd+nverm,"@E 9999999"))      +FG_AlinVlrs(Transform(100,"@E 99999")+"%")                            +FG_AlinVlrs(Transform(((nverd+nverm)/(nverd+nverm+nazul+nlara+ncinz)*100),"@E 99999")+"%")
cverd := FG_AlinVlrs(Transform(nverd,"@E 9999999"))            +FG_AlinVlrs(Transform((nverd/(nverd+nverm)*100),"@E 99999")+"%")      +FG_AlinVlrs(Transform((nverd/(nverd+nverm+nazul+ncinz+nlara)*100),"@E 99999")+"%")
cverm := FG_AlinVlrs(Transform(nverm,"@E 9999999"))            +FG_AlinVlrs(Transform((nverm/(nverd+nverm)*100),"@E 99999")+"%")      +FG_AlinVlrs(Transform((nverm/(nverd+nverm+nazul+ncinz+nlara)*100),"@E 99999")+"%")
//
cTot2 := FG_AlinVlrs(Transform(nlara+nazul+ncinz,"@E 9999999"))+FG_AlinVlrs(Transform(100,"@E 99999")+"%")                            +FG_AlinVlrs(Transform(((nazul+ncinz+nlara)/(nverd+nverm+nazul+nlara+ncinz)*100),"@E 99999")+"%")
cazul := FG_AlinVlrs(Transform(nazul,"@E 9999999"))            +FG_AlinVlrs(Transform((nazul/(nazul+ncinz+nlara)*100),"@E 99999")+"%")+FG_AlinVlrs(Transform((nazul/(nverd+nverm+nazul+ncinz+nlara)*100),"@E 99999")+"%")
clara := FG_AlinVlrs(Transform(nlara,"@E 9999999"))            +FG_AlinVlrs(Transform((nlara/(nazul+ncinz+nlara)*100),"@E 99999")+"%")+FG_AlinVlrs(Transform((nlara/(nverd+nverm+nazul+ncinz+nlara)*100),"@E 99999")+"%")
ccinz := FG_AlinVlrs(Transform(ncinz,"@E 9999999"))            +FG_AlinVlrs(Transform((ncinz/(nazul+ncinz+nlara)*100),"@E 99999")+"%")+FG_AlinVlrs(Transform((ncinz/(nverd+nverm+nazul+ncinz+nlara)*100),"@E 99999")+"%")
//
cTitTela := STR0001+" ( "+Alltrim(Transform(nverd+nverm+nazul+ncinz+nlara,"@E 9999999999"))+" "+LOWER(STR0015)+" )"
//
If len(aVetor) <= 0
	Aadd(aVetor,{"","",cTod(""),cTod(""),"","","","","",0,"","","","","","",0,"","","","","","",""})
EndIf
cFiltro := STR0010+IIf(!Empty(cTipAge),cTipAge,STR0013)+"     "+STR0004+": "+IIf(!Empty(cCodVen),cCodVen,STR0013)+"     "
If cCliPros == "1" // Cliente
	cFiltro += STR0006+": "+IIf(!Empty(cCodCli+cLojCli),cCodCli+"-"+cLojCli,STR0013)
ElseIf cCliPros == "2" // Prospect
	cFiltro += STR0012+": "+IIf(!Empty(cCdPros+cLjPros),cCdPros+"-"+cLjPros,STR0013)
EndIf
If nTp > 0
	oDlgContCEV:cTitle := cTitTela
	If len(aVetor) < nPosLinha
		nPosLinha := len(aVetor)
	EndIf
	oLbTexto:nAt := nPosLinha
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || { VEICC500001_ConvStrToSemaforo(aVetor[oLbTexto:nAt,1]),;
						IIf(aVetor[oLbTexto:nAt,17]==1,oLbOK,IIf(aVetor[oLbTexto:nAt,17]==2,oLbTIK,IIf(aVetor[oLbTexto:nAt,17]==3,oLbCa,oLbNO))) ,;
						aVetor[oLbTexto:nAt,23] ,;
						aVetor[oLbTexto:nAt,2] ,;
						aVetor[oLbTexto:nAt,3] ,;
						aVetor[oLbTexto:nAt,4] ,;
						aVetor[oLbTexto:nAt,5]+" "+left(aVetor[oLbTexto:nAt,6],15) ,;
						aVetor[oLbTexto:nAt,19] ,;
						IIf(len(Alltrim(aVetor[oLbTexto:nAt,7]))>1,aVetor[oLbTexto:nAt,7],aVetor[oLbTexto:nAt,22])+" "+FG_Alinvlrs( left(aVetor[oLbTexto:nAt,8],15), "E")+" "+FG_Alinvlrs( right(aVetor[oLbTexto:nAt,8],20), "E") ,;
						aVetor[oLbTexto:nAt,20] ,;
						aVetor[oLbTexto:nAt,14] ,;
						aVetor[oLbTexto:nAt,21] ,;
						aVetor[oLbTexto:nAt,9] ,;
						aVetor[oLbTexto:nAt,12] ,;
						aVetor[oLbTexto:nAt,13] ,;
						aVetor[oLbTexto:nAt,24] }}
	oLbTexto:SetFocus()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VAL_VCC500³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao dos campos na TELA                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_VCC500(cTipo,lRefresh) // Validacao Campos TELA
Local lRet      := .f.
Local lA1_IBGE  := ( SA1->(FieldPos("A1_IBGE"))    > 0 )
Local lCEVTPA   := ( VAI->(FieldPos("VAI_CEVTPA")) <> 0 )
Local cQuery    := ""
Local nRecAux   := 0
Do Case
	Case cTipo == "TP"    // Verifica Tipo de Agenda
		cNomAge := space(100)
		If lCEVTPA .and. !Empty(VAI->VAI_CEVTPA) .and. !( cTipAge $ VAI->VAI_CEVTPA )
			Return(.f.)
		EndIf
		If !Empty(cTipAge)
			cQuery  := "SELECT VC5_DTPAGE FROM "+RetSqlName("VC5")+" WHERE VC5_FILIAL='"+xFilial("VC5")+"' AND VC5_TIPAGE='"+cTipAge+"' AND D_E_L_E_T_=' '"
			cNomAge := FM_SQL(cQuery)
			If !Empty(cNomAge)
				lRet := .t.
			EndIf
		Else
			lRet := .t.
		EndIf
		If lRefresh
			oNomAge:Refresh()
		EndIf
	Case cTipo == "VD"  // Verifica Vendedor para Agenda
		cNomVen := space(100)
		If !Empty(cCodVen)
			cQuery  := "SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+cCodVen+"' AND D_E_L_E_T_=' '"
			cNomVen := FM_SQL(cQuery)
			If !Empty(cNomVen)
				lRet := .t.
			EndIf
		Else
			lRet := .t.
		EndIf
		If lRefresh
			oNomVen:Refresh()
		EndIf
	Case cTipo == "CL"  // Verifica Cliente+Loja
		cNomCli := space(100)
		If !Empty(cCodCli)
			cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND A1_LOJA='"+cLojCli+"' ","")+"AND D_E_L_E_T_=' '"
			nRecAux := FM_SQL(cQuery)
			If nRecAux > 0
				lRet := .t.
				DbSelectArea("SA1")
				DbGoTo(nRecAux)
				cNomCli := SA1->A1_NOME
				cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND US_LOJACLI='"+cLojCli+"' ","")+"AND D_E_L_E_T_=' '"
				nRecAux := FM_SQL(cQuery)
				If nRecAux > 0
					DbSelectArea("SUS")
					DbGoTo(nRecAux)
					cCdPros := SUS->US_COD
					If !Empty(cLojCli)
						cLjPros := SUS->US_LOJA
					EndIf
				Else
					cCdPros := space(TamSX3("US_COD")[1])
					cLjPros := space(TamSX3("US_LOJA")[1])
				EndIf
			EndIf
		Else
			cLojCli := space(TamSX3("A1_LOJA")[1])
			cCdPros := space(TamSX3("US_COD")[1])
			cLjPros := space(TamSX3("US_LOJA")[1])
			lRet := .t.
		EndIf
		If lRefresh
			oNomCli:Refresh()
		EndIf
	Case cTipo == "PR"  // Verifica Prospect+Loja
		cNomCli := space(100)
		If !Empty(cCdPros)
			cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+cCdPros+"' "+IIf(!Empty(cLjPros),"AND US_LOJA='"+cLjPros+"' ","")+"AND D_E_L_E_T_=' '"
			nRecAux := FM_SQL(cQuery)
			If nRecAux > 0
				lRet := .t.
				DbSelectArea("SUS")
				DbGoTo(nRecAux)
				cNomCli := SUS->US_NOME
				cCodCli := SUS->US_CODCLI
				If !Empty(cLjPros)
					cLojCli := SUS->US_LOJACLI
				EndIf
			Else
				cCodCli := space(TamSX3("A1_COD")[1])
				cLojCli := space(TamSX3("A1_LOJA")[1])
			EndIf
		Else
			cLjPros := space(TamSX3("US_LOJA")[1])
			cCodCli := space(TamSX3("A1_COD")[1])
			cLojCli := space(TamSX3("A1_LOJA")[1])
			lRet := .t.
		EndIf
		If lRefresh
			oNomCli:Refresh()
		EndIf
	Case cTipo == "IBGE"
		cDesCid := space(100)
		If lA1_IBGE
			If !Empty(cIBGE)
				cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("VAM")+" WHERE VAM_FILIAL='"+xFilial("VAM")+"' AND VAM_IBGE='"+cIBGE+"' AND D_E_L_E_T_=' '"
				nRecAux := FM_SQL(cQuery)
				If nRecAux > 0
					lRet := .t.
					DbSelectArea("VAM")
					DbGoTo(nRecAux)
					cDesCid := Alltrim(VAM->VAM_DESCID)+" - "+Alltrim(VAM->VAM_ESTADO)
				EndIf
			Else
				lRet := .t.
			EndIf
		Else
			MsgInfo(STR0111)   
			lRet := .t.
		EndIf
		If lRefresh
			oDesCid:Refresh()
		EndIf
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_IMPRIMIR ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao do Selecionado/Relacionados no ListBox (Contatos) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR(nTp,nLinha) // Impressao do ListBox
Local cBkpFilAnt := cFilAnt
Local cDesc1     := ""
Local cDesc2     := ""
Local cDesc3     := ""
Local cAlias     := "VC1"
Local aImpr      := aClone(aVetor)
Local cQuebra    := "INICIAL"
Local cAux       := ""
Local ni         := nLinha
Private nLin     := 60
Private aReturn  := { STR0036 , 1 , STR0037 , 1 , 2 , 1 , "" , 1 }
Private cTamanho := "M"           // P/M/G
Private Limite   := 132            // 80/132/220
Private aOrdem   := {}            // Ordem do Relatorio
Private cTitulo  := STR0001
Private cNomProg := "VEICC500"
Private cNomeRel := "VEICC500"
Private nLastKey := 0
Private cabec1   := ""
Private cabec2   := ""
Private nCaracter:=15
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "VC1"
Private Li       := 132
Private m_Pag    := 1
Private lAbortPrint := .f.
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
If nTp == 1 .and. ni > 0 // Selecionado // nLinha
	If !Empty(aImpr[ni,23])
		cFilAnt := aImpr[ni,23]
	EndIf
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
If ExistBlock("VC500IMP") // IMPRESSAO CUSTOMIZADA
	ExecBlock("VC500IMP",.f.,.f.,{ aImpr , nTp , nLinha })
Else
	If nTp == 1 // Selecionado
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter)
		nLin++
		@ nLin++ , 00 psay STR0038
		@ nLin++ , 00 psay aImpr[ni,2]+" "+left(Transform(aImpr[ni,3],"@D"),6)+right(Transform(aImpr[ni,3],"@D"),2)+" "+left(Transform(aImpr[ni,4],"@D"),6)+right(Transform(aImpr[ni,4],"@D"),2)+" "+aImpr[ni,7]+" "+aImpr[ni,8]+" "+left(aImpr[ni,9]+space(19),19)+" "+left(aImpr[ni,14]+space(18),18)+" "+left(aImpr[ni,12]+space(14),14)+" "+left(aImpr[ni,13]+space(14),14)
		cAux := FM_SQL("SELECT A1_CGC FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+left(aImpr[ni,7],6)+"' AND A1_LOJA='"+right(aImpr[ni,7],2)+"' AND D_E_L_E_T_=' '")
		@ nLin++ , 20 psay STR0102 + left(Transform(cAux,IIf(Len(Alltrim(cAux))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18)
		nLin++
		@ nLin++ , 00 psay STR0004+": "+aImpr[ni,5]+" - "+aImpr[ni,6]+" - "+ STR0115+": "+aImpr[ni,23]
		If len(cObjetiv) > 0
			@ nLin++ , 00 psay repl("_",132)
			nLin++
			@ nLin++ , 00 psay "*** "+STR0081+" ***" // Objetivo
			nLin++
			For ni := 1 to len(cObjetiv) step 132
				If nLin >= 58
					nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
				EndIf
				@ nLin++ , 00 psay substr(cObjetiv,ni,132)
			Next
		EndIf
		If len(cObserv) > 0
			@ nLin++ , 00 psay repl("_",132)
			nLin++
			@ nLin++ , 00 psay "*** "+STR0082+" ***" // Ocorrencia
			nLin++
			For ni := 1 to len(cObserv) step 132
				If nLin >= 58
					nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
				EndIf
				@ nLin++ , 00 psay substr(cObserv,ni,132)
			Next  
		EndIf
	ElseIf nTp == 2 // Relacionados
		cabec1 := cFiltro
		cabec2 := STR0038
		Asort(aImpr,1,,{|x,y| x[5]+x[23]+Dtos(x[3])+Dtos(x[4])+x[2]+x[7] > y[5]+y[23]+Dtos(y[3])+Dtos(y[4])+y[2]+y[7]})
		For ni:=1 to Len(aImpr)
			If nLin >= 58
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			If cQuebra # aImpr[ni,5]+aImpr[ni,23]
				cQuebra := aImpr[ni,5]+aImpr[ni,23]
				nLin++
				@ nLin++ , 00 psay STR0004+": "+aImpr[ni,5]+" - "+aImpr[ni,6] +" - "+ STR0115+": "+aImpr[ni,23]
			EndIf
			@ nLin++ , 00 psay aImpr[ni,2]+" "+left(Transform(aImpr[ni,3],"@D"),6)+right(Transform(aImpr[ni,3],"@D"),2)+" "+left(Transform(aImpr[ni,4],"@D"),6)+right(Transform(aImpr[ni,4],"@D"),2)+" "+aImpr[ni,7]+" "+aImpr[ni,8]+" "+left(aImpr[ni,9]+space(19),19)+" "+left(aImpr[ni,14]+space(18),18)+" "+left(aImpr[ni,12]+space(14),14)+" "+left(aImpr[ni,13]+space(14),14)
		Next
	EndIf
	Ms_Flush()
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
		OurSpool( cNomeRel )
	EndIf
EndIf
cFilAnt := cBkpFilAnt
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³   FS_2VIA   ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Seta que pode ser impressa a 2a.Via da Ficha Modular CEV    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_2VIA(ni) // Cria 2a.Via da Ficha
Local cBkpFilAnt := cFilAnt
Local nOk        := 0
Local nT         := 0
If aVetor[ni,10] # 0
	If !Empty(aVetor[ni,23])
		cFilAnt := aVetor[ni,23]
	EndIf
	nT := Aviso(STR0040,STR0046,{STR0047,STR0048}) // Marcar Impressão da 2a.Via da ficha CEV do:' para 'Esta opção irá liberar a impressão da segunda via da ficha modular CEV por meio da rotina Agenda do Vendedor (VEICR500). Deseja liberar esta impressão para a(s) agenda(s): / Selecionada / Relacionadas.
	If nT == 1
		DbSelectArea("VC1")
		DbGoTo(aVetor[ni,10])
		ML5002("VC1",aVetor[ni,10],2)
	ElseIf nT == 2
		For ni := 1 to len(aVetor)
			If Empty(aVetor[ni,4])
				DbSelectArea("VC1")
				DbGoTo(aVetor[ni,10])
				ML5002("VC1",aVetor[ni,10],1)
				nOk := aVetor[ni,10]
			EndIf
		Next
		If nOk # 0
			DbSelectArea("VC1")
			DbGoTo(nOK)
			ML5002("VC1",nOK,2)
		EndIf
	EndIf
	cFilAnt := cBkpFilAnt
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_CONTATOS ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao do ComboBox de Contatos CEV                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONTATOS() // Validacao do ComboBox de Contatos
If cContat == STR0013
	lTodos := .t.
	lDtVis := .t.
	l2Via  := .t.
Else
	lTodos := .f.
	lDtVis := .t.
	l2Via  := .t.
	If ( cContat == STR0021+" - "+STR0008 ) .or. ( cContat == STR0021+" - "+STR0007 )
		lDtVis := .f.
		dDtVisI := ctod("  /  /  ")
		dDtVisF := ctod("  /  /  ")
	ElseIf ( cContat == STR0022+" - "+STR0016 )
		lDtVis := .f.
		dDtVisI := dDtAgeI
		dDtVisF := dDtAgeF
		l2Via := .f.
	ElseIf ( cContat == STR0022+" - "+STR0017 )
		l2Via := .f.
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_OBSVC500 ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ MEMOS com Objetivo e Observacao / ListBox Interesses        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSVC500()
Local cBkpFilAnt  := cFilAnt
Local cMsg        := ""
Local cQuery      := ""
Local cQAlias     := "SQLVCKVCJ"
Local cTpPesq     := ""
Local nTCdCli     := TamSx3("A1_COD")[1]
Local nTLjCli     := TamSx3("A1_LOJA")[1]
Local cXCodCli    := left(aVetor[oLbTexto:nAt,7],nTCdCli)
Local cXLojCli    := right(aVetor[oLbTexto:nAt,7],nTLjCli)
Local cXCdPros    := left(aVetor[oLbTexto:nAt,22],nTCdCli)
Local cXLjPros    := right(aVetor[oLbTexto:nAt,22],nTLjCli)
Local lVAQ_TIPOSI := ( VAQ->(FieldPos("VAQ_TIPOSI")) > 0 )
//
If !Empty(aVetor[oLbTexto:nAt,23])
	cFilAnt := aVetor[oLbTexto:nAt,23]
EndIf
//
cObjetiv := ""
DbSelectArea("VC1")
DbSetOrder(1)
DbGoTo(aVetor[oLbTexto:nAt,10])
If !Empty(aVetor[oLbTexto:nAt,18])
	cObjetiv += MSMM(aVetor[oLbTexto:nAt,18],47)
EndIf
//
cObserv := ""
If !Empty(aVetor[oLbTexto:nAt,11])
	cObserv += MSMM(aVetor[oLbTexto:nAt,11],47)+CHR(13)+CHR(10)
EndIf
If lProdut
	If !Empty(VC1->VC1_DATVIS) .and. VC1->VC1_CONPRO <> "0"
		cObserv += STR0094+CHR(13)+CHR(10) // Contato produtivo!
	EndIf
EndIf
If lMotEnc
	If !Empty(VC1->VC1_MOTIVO)
		VS0->(DbSetOrder(1))
		VS0->(DbSeek(xFilial("VS0")+"000010"+VC1->VC1_MOTIVO))
		cObserv += STR0089+" "+VC1->VC1_MOTIVO+" - "+left(VS0->VS0_DESMOT,35)
	EndIf
EndIf
///////////////////////////////////////////////////
// Mensagem no momento da Pesquisa de Satisfacao //
///////////////////////////////////////////////////
If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA) .and. VCF->(FieldPos("VCF_MSGSAT")) > 0
	cMsg := FM_SQL("SELECT VCF_MSGSAT FROM "+RetSQLName("VCF")+" WHERE VCF_FILIAL='"+xFilial("VCF")+"' AND VCF_CODCLI='"+VC1->VC1_CODCLI+"' AND VCF_LOJCLI='"+VC1->VC1_LOJA+"' AND D_E_L_E_T_=' '")
	If !Empty(cMsg)
		cObserv += CHR(13)+CHR(10)+cMsg
	EndIf
EndIf
If aVetor[oLbTexto:nAt,17] == 2 // Possui Pesquisa de Satisfacao ja realizada
	If !Empty(aVetor[oLbTexto:nAt,15])
		Do Case
			Case aVetor[oLbTexto:nAt,16] == "V" // Veiculos
				cTpPesq := "001"
			Case aVetor[oLbTexto:nAt,16] == "O" // Oficina
				cTpPesq := "002"
			Case aVetor[oLbTexto:nAt,16] == "B" // Balcao
				cTpPesq := "003"
			Case aVetor[oLbTexto:nAt,16] == "C" // CEV
				cTpPesq := "004"
		EndCase
		cQuery := "SELECT VCK.VCK_DATPES FROM "+RetSqlName("VCK")+" VCK , "+RetSqlName("VCJ")+" VCJ WHERE "
		cQuery += "VCK.VCK_FILIAL='"+xFilial("VCK")+"' AND VCK.VCK_ORIGEM='"+aVetor[oLbTexto:nAt,15]+"' AND "
		cQuery += "VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCK.VCK_CODPER=VCK.VCK_CODPER AND VCJ_TIPPES='"+cTpPesq+"' AND VCK.D_E_L_E_T_=' ' AND VCJ.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			cObserv += CHR(13)+CHR(10)+Transform(stod(( cQAlias )->( VCK_DATPES )),"@D")+" - "+STR0059 // 99/99/99 - Pesquisa de Satisfacao
		EndIf
		( cQAlias )->( DbCloseArea() )
	EndIf
ElseIf aVetor[oLbTexto:nAt,17] == 3 // Possui Pesquisa de Satisfacao nao realizada com motivo
	If lMOTPNR
		If !Empty(VC1->VC1_MOTPNR)
			VS0->(DbSetOrder(1))
			VS0->(DbSeek(xFilial("VS0")+"000007"+VC1->VC1_MOTPNR))
			cObserv += CHR(13)+CHR(10)+STR0066+" "+VC1->VC1_MOTPNR+" - "+left(VS0->VS0_DESMOT,35)
		EndIf
	EndIf
EndIf
If !Empty(cXCodCli+cXCdPros)
	If cInsati == "1" // Filtrou todos os Clientes que possuem Registro de Insatisfacao
		cObserv += CHR(13)+CHR(10)+STR0063 // Cliente com Registro de Insatisfacao
	ElseIf cInsati == "3" // Filtrou todos os Clientes que possuem Registro de Satisfacao
		cObserv += CHR(13)+CHR(10)+STR0096 // Cliente com Registro de Satisfacao
	Else
		cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
		If lVAQ_TIPOSI
			cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI<>'1' AND VAQ.D_E_L_E_T_=' ' ) "
		EndIf
		cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+cXCodCli+"' AND VAO.VAO_LOJCLI='"+cXLojCli+"' AND VAO.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			cObserv += CHR(13)+CHR(10)+STR0063 // Cliente com Registro de Insatisfacao
		EndIf
		If lVAQ_TIPOSI
			cQuery := "SELECT VAO.R_E_C_N_O_ AS RECVAO FROM "+RetSqlName("VAO")+" VAO "
			cQuery += "JOIN "+RetSqlName("VAQ")+" VAQ ON ( VAQ.VAQ_FILIAL='"+xFilial("VAQ")+"' AND VAQ.VAQ_TIPREC=VAO.VAO_TIPREC AND VAQ.VAQ_TIPOSI='1' AND VAQ.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND VAO.VAO_CODCLI='"+cXCodCli+"' AND VAO.VAO_LOJCLI='"+cXLojCli+"' AND VAO.D_E_L_E_T_=' '"
			If FM_SQL(cQuery) > 0
				cObserv += CHR(13)+CHR(10)+STR0096 // Cliente com Registro de Satisfacao
			EndIf
		EndIf
	EndIf
	oLbInterC:SetQuery(FS_SQLVDM(cXCodCli,cXLojCli,cXCdPros,cXLjPros))
	oLbInterC:Refresh()
	oLbInterC:GoTop()
EndIf
cFilAnt := cBkpFilAnt
//
DbSelectArea("VC1")
oCEVObjetiv:Refresh()
oCEVObserv:Refresh()
oLbTexto:SetFocus()
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_REGABO  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Chama o registro de Abordagem CEV                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REGABO(nRec,nTp) // Registro da Abordagem do CEV
Local cBkpFilAnt := cFilAnt
Local nPosicao   := 0
Local nDiasOFI   := 0
Local cTpAgOFI   := ""
Local cNumIde    := ""
Private aMemos   := {{"VC1_OCOMEM","VC1_OCORRE"}}
Private aObser   := {{"VC1_OCOMEM","VC1_OCORRE"}}
Private aMemObj  := {{"VC1_OBSOBJ","VC1_OBJETI"}}
Private aCampos  := {}
Private cCadastro := STR0039
Private lRefresh := .t.
Private aRotina  := {  { " " ," " , 0, 1},;  // Pesquisar
						{ " " ," " , 0, 2},;  // Visualizar
						{ " " ," " , 0, 3},;  // Incluir
						{ " " ," " , 0, 4},;  // Alterar
						{ " " ," " , 0, 5} }  // Excluir
Default nTp := 1 // AXCADASTRO
If nTp == 2 // TELA VEICC500
	If !Empty(aVetor[oLbTexto:nAt,23])
		cFilAnt := aVetor[oLbTexto:nAt,23]
	EndIf
EndIf
If nRec > 0
	CAMPOM510()
	DbSelectArea("VC1")
	DbSetOrder(1)
	DbGoTo(nRec)
	If Empty(VC1->VC1_DATVIS)
		Inclui := .f.
		Altera := .t.
		ML510A("VC1",nRec,4)
		If lAgend
			DbSelectArea("VC1")
			nPosicao := VC1->(RecNo())
			DbSelectArea("VC5")
			DbSetOrder(1)
			DbSeek( xFilial("VC5") + VC1->VC1_TIPAGE )
			If VC5->VC5_AGEOFI == "1"
				If MsgYesNo(STR0049 ,STR0040 )
					cNumIde := OFIOM350(.t.)
					If !Empty(cNumIde)
						DbSelectArea("VSO")
						DbSetOrder(1)
						If DbSeek( xFilial("VSO") + cNumIde )
							cTpAgOFI := VC1->VC1_TIPAGE
							cTpAgOFI := VC5->VC5_AGCTOF
							nDiasOFI := VC5->VC5_DCNTOF
							FS_AGENDA(cTpAgOFI,(VSO->VSO_DATAGE-nDiasOFI),VC1->VC1_CODVEN,VSO->VSO_PROVEI,VSO->VSO_LOJPRO,,VSO->VSO_NUMOSV,,,"","")
						EndIf
					EndIf
				EndIf
			EndIf
			DbSelectArea("VC1")
			DbGoto(nPosicao)
		EndIf
	Else
		MsgAlert(STR0041,STR0040)
	EndIf
EndIf
cFilAnt := cBkpFilAnt
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_CADCLI  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Chama o cadastro de Clientes                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CADCLI(cCliente) // Cadastro de Clientes
Local cBkpFilAnt := cFilAnt
Local nT         := Aviso(STR0040,STR0050 ,{STR0051 ,STR0052 })
Local acBroSlv   := acBrowse
If !Empty(aVetor[oLbTexto:nAt,23])
	cFilAnt := aVetor[oLbTexto:nAt,23]
EndIf
If nT == 1
	If FindFunction("ChkUserRules")
		If !ChkUserRules("MATA030",cAcesso,STR0083) // Usuário sem acesso!
			Return()
		EndIf
	EndIf
	acBrowse := NgAcBrowse("MATA030")
	MATA030() // SA1
	acBrowse := acBroSlv
ElseIf nT == 2
	If FindFunction("ChkUserRules")
		If !ChkUserRules("VEICM560",cAcesso,STR0083) // Usuário sem acesso!
			Return()
		EndIf
	EndIf
	acBrowse := NgAcBrowse("VEICM560")
	VEICM560() // VCF
	acBrowse := acBroSlv
EndIf
cFilAnt := cBkpFilAnt
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_VERORIG ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Visualiza a Origem do CEV ( Atendimento / OS / Orcamento )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERORIG(ni)  // Ver origem do CEV (Atendimento/OS/Orcamento)
Local cBkpFilAnt := cFilAnt
Private Inclui  := .f. // Variavel utilizada na Visualizacao
Private Altera  := .f. // Variavel utilizada na Visualizacao
Private cCampo := ""
Private nOpc := 2
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := STR0054
Private aNewBot := {}
Private aRotina := {{"","", 0, 1},;
					{"","", 0, 2},;
					{"","", 0, 3},;
					{"","", 0, 4},;
					{"","", 0, 5}}
If !Empty(aVetor[ni,23])
	cFilAnt := aVetor[ni,23]
EndIf
If !Empty(aVetor[ni,2])
	If aVetor[ni,16] == "O" // Oficina
		aRotina := {{ "" ,"axPesqui", 0 , 1},;   // Pesquisar
					{ "" ,"OC060"   , 0 , 2}}    // Visualizar
		cCadastro := STR0055
		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek(xFilial("VO1") + left(aVetor[ni,15],8) )
			OC060("VO1",VO1->(Recno()),2)
		EndIf
	ElseIf aVetor[ni,16] == "B" // Balcao
		cCadastro := STR0056
		DbSelectArea("VS1")
		DbSetOrder(1)
		If DbSeek(xFilial("VS1") + left(aVetor[ni,15],8) )
			OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
		EndIf
	ElseIf aVetor[ni,16] == "V" // Veiculos
		DbSelectArea("VV9")
		DbSetOrder(1)
		If DbSeek( xFilial("VV9") + left(aVetor[ni,15],10) )
			If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
				VEIXX002(NIL,NIL,NIL,2,)
			EndIf
		EndIf
	EndIf
EndIf
cFilAnt := cBkpFilAnt
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_PESQSAT ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Pesquisa de Satisfacao ( Cria / Visualiza )                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQSAT(_cTpAg,_cTpOri,_cOrig,_nPosVC1,_dDtAbord) // Pesq.Satisfacao
Local cBkpFilAnt := cFilAnt
Local lAlt       := Empty(_dDtAbord)
Local cTpPesq    := ""
If _cTpOri == "V" // Veiculos
	cTpPesq := "001"
ElseIf _cTpOri == "O" // Oficina
	cTpPesq := "002"
ElseIf _cTpOri == "B" // Balcao
	cTpPesq := "003"
ElseIf _cTpOri == "C" // CEV
	cTpPesq := "004"
EndIf
If !Empty(aVetor[oLbTexto:nAt,23])
	cFilAnt := aVetor[oLbTexto:nAt,23]
EndIf
DbSelectArea("VC1")
DbSetOrder(1)
DbGoTo(_nPosVC1)
If !Empty(cTpPesq)
	If lMOTPNR
		If !Empty(VC1->VC1_MOTPNR)
			VS0->(DbSetOrder(1))
			VS0->(DbSeek(xFilial("VS0")+"000007"+VC1->VC1_MOTPNR))
			If lAlt
				If !MsgYesNo(STR0066+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VC1->VC1_MOTPNR+" - "+left(VS0->VS0_DESMOT,35)+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0067,STR0040)
					Return()
				Else
					DbSelectArea("VC1")
					RecLock("VC1",.f.)
					VC1->VC1_MOTPNR := ""
					MsUnLock()
				EndIf
			Else
				MsgInfo(STR0066+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VC1->VC1_MOTPNR+" - "+left(VS0->VS0_DESMOT,35),STR0040)
				Return()
			EndIf
		EndIf
	EndIf
	If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA)
		If lAlt
			If VCA100PESQ(cTpPesq,_cTpAg,_cOrig,STR0059,"A",VC1->VC1_CODCLI,VC1->VC1_LOJA) // Pesquisa de Satisfacao
				DbSelectArea("VCK")
				DbSetOrder(1)
				If DbSeek(xFilial("VCK")+_cOrig)
					DbSelectArea("VC1")
					FS_REGABO(_nPosVC1,1)
				Else
					DbSelectArea("VC1")
				EndIf
			EndIf
		Else
			VCA100PESQ(cTpPesq,_cTpAg,_cOrig,STR0059,"V",VC1->VC1_CODCLI,VC1->VC1_LOJA) // Pesquisa de Satisfacao
		EndIf
	EndIf
EndIf
cFilAnt := cBkpFilAnt
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_MOTPNR  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 18/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Registrar MOTIVO para Pesquisa de Satisfacao nao realizada  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MOTPNR()
Local cBkpFilAnt := cFilAnt
Local ni         := 0
Local lPesqSNR   := .f.
Local aPesqSNR   := {}
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTipOri    := ""
Local cOrigem    := ""
For ni := 1 to len(aVetor)
	If aVetor[ni,17] == 1 // Pesquisa nao realizada
		If !Empty(aVetor[ni,23])
			cFilAnt := aVetor[ni,23]
		EndIf
		aadd(aPesqSNR,aClone(aVetor[ni]))
		aPesqSNR[len(aPesqSNR),1] := .f.
		cTipOri := aPesqSNR[len(aPesqSNR),16]
		cOrigem := aPesqSNR[len(aPesqSNR),15]
		If cTipOri == "V" // Veiculos
			VV0->(dbSetOrder(1))
			VV0->(MsSeek(xFilial("VV0")+cOrigem))
			VV2->(dbSetOrder(1))
			VV2->(MsSeek(xFilial("VV2")+VV0->VV0_CODMAR+VV0->VV0_MODVEI))
			VV8->(dbSetOrder(1))
			VV8->(MsSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
			aPesqSNR[len(aPesqSNR),11] := VV8->VV8_DESCRI
		Else
			aPesqSNR[len(aPesqSNR),11] := IIf(cTipOri=="O",STR0071,IIf(cTipOri=="B",STR0072,IIf(cTipOri=="C",STR0073,""))) // Oficina / Balcao / CEV
		EndIf
	EndIf
Next
cFilAnt := cBkpFilAnt
If len(aPesqSNR) <= 0
	MsgStop(STR0068,STR0040)
	Return()
EndIf
for ni := 1 to Len(aSizeHalf)
	aSizeHalf[ni] := INT(aSizeHalf[ni] * 0.9)
next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
aPos := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlgMOTPNR From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0070 OF oMainWnd PIXEL
@ aPos[1,1]+000,aPos[1,2]+000 LISTBOX oLbMOTPNR FIELDS HEADER "",;  // selecionar 1
			STR0002,;  // Tp Agenda  2
			STR0003,;  // Dt Agenda  3
			STR0023,;  // Dt Visita  4
			STR0069,;  // Tipo      11
			STR0004,;  // Vendedor   5  6
			STR0097,;  // Vendedor NF  
			STR0006,;  // Cliente"   7  8
			STR0098,;  // Proprietário"
			STR0045,;  // Fone
			STR0014,;  // Cidade-UF
			STR0028,;  // Tipo de Abordagem
			STR0029 ;  // Tipo de Contato
			COLSIZES 10,18,30,30,65,65,65,110,110,55,100,80,80 SIZE aPos[1,4]-3,aPos[1,3]-10 OF oDlgMOTPNR PIXEL ON DBLCLICK ( aPesqSNR[oLbMOTPNR:nAt,1] := !aPesqSNR[oLbMOTPNR:nAt,1] )
oLbMOTPNR:bHeaderClick := {|oObj,nCol| IIf( nCol==1, ( ( lPesqSNR:=!lPesqSNR ) , FS_TIK(@aPesqSNR,lPesqSNR) ) ,Nil) }
oLbMOTPNR:SetArray(aPesqSNR)
oLbMOTPNR:bLine := { || {IIf(aPesqSNR[oLbMOTPNR:nAt,1],VEICC500001_ConvStrToSemaforo('verd'), VEICC500001_ConvStrToSemaforo('verm')),;
			aPesqSNR[oLbMOTPNR:nAt,2]  ,;
			aPesqSNR[oLbMOTPNR:nAt,3]  ,;
			aPesqSNR[oLbMOTPNR:nAt,4]  ,;
			aPesqSNR[oLbMOTPNR:nAt,11] ,;
			aPesqSNR[oLbMOTPNR:nAt,5]+" "+left(aPesqSNR[oLbMOTPNR:nAt,6],15) ,;
			aPesqSNR[oLbMOTPNR:nAt,19] ,;
			aPesqSNR[oLbMOTPNR:nAt,7]+" "+left(aPesqSNR[oLbMOTPNR:nAt,8],25) ,;
			aPesqSNR[oLbMOTPNR:nAt,20] ,;
			aPesqSNR[oLbMOTPNR:nAt,14] ,;
			aPesqSNR[oLbMOTPNR:nAt,9]  ,;
			aPesqSNR[oLbMOTPNR:nAt,12] ,;
			aPesqSNR[oLbMOTPNR:nAt,13] }}
ACTIVATE MSDIALOG oDlgMOTPNR CENTER ON INIT EnchoiceBar(oDlgMOTPNR,{|| IIf(FS_PNROK(aPesqSNR),oDlgMOTPNR:End(),.t.) },{ || oDlgMOTPNR:End() },,)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_PNROK    ³ Autor ³ Andre Luis Almeida  ³ Data ³ 18/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ OK - Pesquisa de Satisfacao nao realizada (Preencher MOTIVO)³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PNROK(aPesqSNR)
Local cBkpFilAnt := cFilAnt
Local lRet       := .f.
Local ni         := 0
Local aMotCancel := {}
Private cMotivo  := "000007"  //Filtro da consulta do motivo da Pesquisa de Satisfacao nao realizada
For ni := 1 to len(aPesqSNR)
	If aPesqSNR[ni,1] // CEV selecionado
		lRet := .t.
		Exit
	EndIf
Next
If lRet
	aMotCancel := OFA210MOT("000007","5","","",.f.) // Filtro da consulta do motivo ( 000007 = Pesquisa de Satisfacao nao realizada )
	If len(aMotCancel) <= 0
		lRet := .f.
	Else
		For ni := 1 to len(aPesqSNR)
			If aPesqSNR[ni,1] // CEV selecionado
				If !Empty(aPesqSNR[ni,23])
					cFilAnt := aPesqSNR[ni,23]
				EndIf
				DbSelectArea("VC1")
				DbSetOrder(1)
				DbGoTo(aPesqSNR[ni,10])
				RecLock("VC1",.f.)
				VC1->VC1_MOTPNR := aMotCancel[1] // Motivo da Pesquisa de Satisfacao nao realizada
				MsUnLock()
				OFA210VDT("000007",aMotCancel[1],"5",VC1->VC1_FILIAL,strzero(aPesqSNR[ni,10],15),aMotCancel[4])
			EndIf
		Next
		cFilAnt := cBkpFilAnt
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³   FS_TIK    ³ Autor ³ Andre Luis Almeida  ³ Data ³ 18/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik TOTAL das Pesquisas de Satisfacao nao realizadas        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(aPesqSNR,lPesqSNR)
Local ni := 0
For ni := 1 to len(aPesqSNR)
	aPesqSNR[ni,1] := lPesqSNR
Next
oLbMOTPNR:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_BLQVEI  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 29/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Bloqueia Prospeccao do Veiculo                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BLQVEI(nLinha)
Local cBkpFilAnt := cFilAnt
Local lOk        := .f.
Default nLinha   := 0
If nLinha > 0
	If !Empty(aVetor[nLinha,23])
		cFilAnt := aVetor[nLinha,23]
	EndIf
	If aVetor[nLinha,16] == "V" // Origem: Veiculos
		VV9->(DbSetOrder(1))
		VV9->(DbSeek(xFilial("VV9")+left(aVetor[nLinha,15],10)))
		VVA->(DbSetOrder(1))
		VVA->(DbSeek(xFilial("VVA")+left(aVetor[nLinha,15],10)))
		DbSelectArea("VV1")
		DbSetOrder(2)
		If DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)
			lOk := .t.
		EndIf
	ElseIf aVetor[nLinha,16] == "O" // Origem: Oficina
		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+left(aVetor[nLinha,15],8)))
		DbSelectArea("VV1")
		DbSetOrder(1)
		If DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)
			lOk := .t.
		EndIf
	ElseIf aVetor[nLinha,16] == "B" // Origem: Balcao
		VS1->(DbSetOrder(1))
		VS1->(DbSeek(xFilial("VS1")+left(aVetor[nLinha,15],8)))
		DbSelectArea("VV1")
		DbSetOrder(1)
		If DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
			lOk := .t.
		EndIf
	EndIf
	If lOk
		If VV1->VV1_BLQPRO == "1" // Veiculo ja Bloqueado
			MsgInfo(STR0080,STR0040) // Veiculo ja esta Bloqueado para Listas de Prospeccao! / Atencao
		Else
			If MsgYesNo(STR0075+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI,STR0040) // Confirma o Bloqueio do Veiculo para Listas de Prospeccao? / Atencao
				DbSelectArea("VV1")
				RecLock("VV1",.f.)
				VV1->VV1_BLQPRO := "1" // 1=Sim
				MsUnLock()
				MsgInfo(STR0079,STR0040) // Veiculo Bloqueado com sucesso! / Atencao
			EndIf
		EndIf
	EndIf
	cFilAnt := cBkpFilAnt
EndIf
If !lOk
	MsgStop(STR0076,STR0040) // Nenhum Veiculo relacionado com a Agenda! / Atencao
EndIf
Return()
					 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_BCCONHEC ³ Autor ³ Thiago             ³ Data ³ 05/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Banco de conhecimento.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BCCONHEC()
Local cBkpFilAnt := cFilAnt
Local lRet       := .t.
If !Empty(aVetor[oLbTexto:nAt,23])
	cFilAnt := aVetor[oLbTexto:nAt,23]
EndIf
If aVetor[oLbTexto:nAt,2] <> ""
	VC500BCO()
Else
	MsgStop(STR0105)
	lRet := .f.
Endif
cFilAnt := cBkpFilAnt
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Programa  ³ VC500BCO | Autor ³ Thiago           | Data ³    05/05/14   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descricao ³ Chamada da funcao Banco de conhecimento.                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VC500BCO()
Private cBcTpAgen  := aVetor[oLbTexto:nAt,2]
Private dBcDtAgen  := aVetor[oLbTexto:nAt,3]     
Private	aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
					{ " " ," " , 0, 2},;	// Visualizar
					{ " " ," " , 0, 3},;	// Incluir
					{ " " ," " , 0, 4},;	// Alterar
					{ " " ," " , 0, 5} }	// Excluir
nOpc := 4
DbSelectArea("VC1")
DbGoTo(aVetor[oLbTexto:nAt,10])
cAlias := "VC1"
nReg := VC1->(RecNo())
FGX_MSDOC(cAlias,nReg,nOpc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 16/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux    := {}
Local ni         := {}
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aFilAtu    := {}
Local aVetEmp    := {}
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0114 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER  (""),STR0115,STR0005 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) , aVetEmp[oLbEmp:nAt,3] , aVetEmp[oLbEmp:nAt,4] }}
	oLbEmp:bHeaderClick := {|oObj,nCol| ( lMarcarFil := !lMarcarFil , aEval( aVetEmp , {|x| x[1] := lMarcarFil } ) , oLbEmp:Refresh() ) , }
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
    //	@ 002, 002 CHECKBOX oMacTod VAR lMarcarFil PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcarFil) , .t. , ( lMarcarFil:=!lMarcarFil , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
	EndIf
Next
aEmpr := aClone(aVetAux)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSFIL³ Autor ³  Andre Luis Almeida   ³ Data ³ 16/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicionamento na Filial antes de executar funcao do BOTAO ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSFIL(nTp)
Local cBkpFilAnt := cFilAnt
Local nTCdCli    := TamSX3("A1_COD")[1]
Local nTLjCli    := TamSX3("A1_LOJA")[1]
If !Empty(aVetor[oLbTexto:nAt,23])
	cFilAnt := aVetor[oLbTexto:nAt,23]
EndIf
Do Case
	Case nTp == 1 // Visualiza Ficha do Cliente
		VEICR501V(left(aVetor[oLbTexto:nAt,7],nTCdCli),right(aVetor[oLbTexto:nAt,7],nTLjCli),aVetor[oLbTexto:nAt,2])
	Case nTp == 2 // Satisfação/Insatisfação
		VEICC590(left(aVetor[oLbTexto:nAt,7],nTCdCli),right(aVetor[oLbTexto:nAt,7],nTLjCli))
	Case nTp == 3 // Converter Prospect em Cliente
		FGX_SUSSA1(left(aVetor[oLbTexto:nAt,22],nTCdCli),right(aVetor[oLbTexto:nAt,22],nTLjCli),.f.)
	Case nTp == 4 // Visualiza Potencial do Cliente
		OFIOC570(left(aVetor[oLbTexto:nAt,7],nTCdCli),right(aVetor[oLbTexto:nAt,7],nTLjCli))
EndCase
cFilAnt := cBkpFilAnt
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEICC500001 ³ Autor ³ Vinicius Gati       ³ Data ³ 03/03/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ converte string para cor evitando logica dificil nos listbox³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VEICC500001_ConvStrToSemaforo(cString) // Validacao Campos TELA
	if Empty(oBmp1)
		oBmp1 := LoadBitmap( GetResources(), "BR_VERMELHO" )
		oBmp2 := LoadBitmap( GetResources(), "BR_VERDE" )
		oBmp3 := LoadBitmap( GetResources(), "BR_AZUL" )
		oBmp4 := LoadBitmap( GetResources(), "BR_CINZA" )
		oBmp5 := LoadBitmap( GetResources(), "BR_LARANJA" )
	end
	Do Case
		Case cString == "verm"
			return oBmp1
		Case cString == "verd"
			return oBmp2
		Case cString == "azul"
			return oBmp3
		Case cString == "cinz"
			return oBmp4
		Case cString == "lara"
			return oBmp5
	End Case
return oBmp5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VCC500LEG ³ Autor ³ Andre Luis Almeida    ³ Data ³ 24/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Legenda da Pesquisa de Satisfação                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCC500LEG()
Local aLegenda := 	{;
					{"LbNO",STR0060},;
					{"LbOK",STR0061},;
					{"AVGOIC1",STR0064},;
					{"LbTIK",STR0062}}
//
BrwLegenda(STR0058,STR0119,aLegenda) // Legenda Pesq.Satisfacao
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VDMColunas  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 20/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Colunas apresentadas no ListBox do Interesse/Oportunidade   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VDMColunas()
Local nI	   := 0
Local aColumns := {}
Local cCampo   := ""
Local cAux     := ""
//
cSQLVDM := "SELECT "
//
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nI:=1 To Len(aCposInter)
	If SX3->(dbSeek(aCposInter[nI]))
		//
		If SX3->X3_TIPO == "N"
			cAux := "0"
		Else
			cAux := "''"
		EndIf
		cSQLVDM += "COALESCE("+left(aCposInter[ni],3)+"."+aCposInter[ni]+","+cAux+") AS "+aCposInter[ni]+" , "
		//	
		cCampo := AllTrim(SX3->X3_CAMPO)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetType(SX3->X3_TIPO)
		aColumns[Len(aColumns)]:SetTitle(X3Titulo())
		aColumns[Len(aColumns)]:SetSize(SX3->X3_TAMANHO)
		aColumns[Len(aColumns)]:SetDecimal(SX3->X3_DECIMAL)
		aColumns[Len(aColumns)]:SetPicture(SX3->X3_PICTURE)
		If SX3->X3_TIPO == "D"
			aColumns[Len(aColumns)]:SetData(&("{|| sTod(" + cCampo + ")}"))
		Else
			aColumns[Len(aColumns)]:SetData(&("{||" + cCampo + "}"))
		EndIf
	EndIf
Next nI
//
cSQLVDM := left(cSQLVDM,len(cSQLVDM)-2)
cSQLVDM += "FROM "+RetSqlName("VDL")+" VDL "
cSQLVDM += "JOIN "+RetSqlName("VDM")+" VDM ON ( VDM.VDM_FILIAL=VDL.VDL_FILIAL AND VDM.VDM_CODOPO=VDL.VDL_CODOPO AND VDM.VDM_MOTCAN=' ' AND VDM.D_E_L_E_T_=' ' ) "
cSQLVDM += "LEFT JOIN "+RetSqlName("VDK")+" VDK ON ( VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_CODFAS=VDM.VDM_CODFAS AND VDK.D_E_L_E_T_=' ' ) "
cSQLVDM += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VDM.VDM_CODMAR AND VV2.VV2_MODVEI=VDM.VDM_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
cSQLVDM += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VDM.VDM_CODMAR AND VVC.VVC_CORVEI=VDM.VDM_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
//
SX3->(dbCloseArea())
Return aColumns

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_SQLVDM   ³ Autor ³ Andre Luis Almeida  ³ Data ³ 24/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ SQL referente ao ListBox do Interesse/Oportunidade          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SQLVDM(cXCodCli,cXLojCli,cXCdPros,cXLjPros)
Local cQuery := cSQLVDM // cSQLVDM - Campos do SQL
If Empty(cXCodCli+cXLojCli+cXCdPros+cXLjPros)
	cQuery += "WHERE VDL.VDL_FILIAL='NAO_LEVANTAR_REGISTROS'"
Else
	cQuery += "WHERE VDL.VDL_FILIAL='"+xFilial("VDL")+"' AND "
	Do Case
		Case !Empty(cXCodCli) .and. !Empty(cXCdPros)
			cQuery += "( ( VDL.VDL_CODCLI='"+cXCodCli+"' AND VDL.VDL_LOJCLI='"+cXLojCli+"' ) OR ( VDL.VDL_CDPROS='"+cXCdPros+"' AND VDL.VDL_LJPROS='"+cXLjPros+"' ) ) AND "
		Case !Empty(cXCodCli)
			cQuery += "VDL.VDL_CODCLI='"+cXCodCli+"' AND VDL.VDL_LOJCLI='"+cXLojCli+"' AND "
		Case !Empty(cXCdPros)
			cQuery += "VDL.VDL_CDPROS='"+cXCdPros+"' AND VDL.VDL_LJPROS='"+cXLjPros+"' AND "
	EndCase
	cQuery += "VDL.D_E_L_E_T_=' ' ORDER BY VDM.VDM_DATINT DESC "
EndIf
Return cQuery

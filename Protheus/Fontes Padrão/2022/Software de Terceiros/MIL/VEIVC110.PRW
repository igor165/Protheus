// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 28     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVC110.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEIVC110 ³ Autor ³ Andre Luis Almeida / Luis ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta Atendimentos Reservados (VV9/VV0)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC110(cPEmp,aPEmp,dPDtVI,dPDtVF,dPDtRI,dPDtRF,cPCod,cPLoj,cPNom,cPTip,cPSit1,cPSit2,cPMar,cPMod)
Local lDClik  := .f.
Local ni      := 0
Local nTam    := 0
Local OXbranco
Local OXlaranja
Local OXvermelho
Local OXverde
Local OXazull
Local OXcinza
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private lMarcar  := .f.
Private obranco  := LoadBitmap( GetResources() , "BR_BRANCO" )		// 1 Col 3
Private olaranja := LoadBitmap( GetResources() , "BR_LARANJA" )		// 1 Col 5
Private ocinza   := LoadBitmap( GetResources() , "BR_CINZA" )		// 1 Col 7
Private oazull   := LoadBitmap( GetResources() , "BR_AZUL" )		// 1 Col 9
Private overde   := LoadBitmap( GetResources() , "BR_VERDE" )		// 2 Col 2
Private overmelho:= LoadBitmap( GetResources() , "BR_VERMELHO" )	// 2 Col 4
Private oP       := LoadBitmap( GetResources() , "SHORTCUTPLUS" )
Private oM       := LoadBitmap( GetResources() , "TRIRIGHT" )
Private aEmpr := {} // Empresas Consolidadas
Private aVetEmp := {}
Private cEmpr := "" // Nome da Empresa
Private aNVei := {} // VV9 / VV0 - ATENDIMENTOS
Private aAte  := {} // Atendimento
Private cTpPgSin:= GetNewPar("MV_TPPGSIN","")
Private cObserv := ""
Private cFiltro1:= ""
Private cFiltro2:= ""
Private cCodCli := space(TamSX3("A1_COD")[1])
Private cLojCli := space(TamSX3("A1_LOJA")[1])
Private cNomCli := space(TamSX3("A1_NOME")[1])
Private cDesCli := ""
Private cDesFon := ""
Private cDesTip := ""
Private dDtVIni := ctod("01/"+strzero(month(dDataBase),2)+"/"+right(strzero(year(dDataBase),4),2))
Private dDtVFin := dDataBase
Private dDtRIni := ctod("")
Private dDtRFin := ( dDataBase + 30 )
Private aAteTip := { "" , "0-"+STR0002 , "2-"+STR0003 , "3-"+STR0004 } // Tipo Atendimento
Private cAteTip := ""
Private aAteSit1:= { "" , STR0050 , STR0006 , STR0005 , STR0040 , STR0009 } // Propostas: Nao Faturadas / Nao Faturadas com Sinal / Nao Faturadas sem Sinal / Nao Faturadas e Quitadas total / Faturadas sem Quitacao
Private cAteSit1:= ""
Private aAteSit2:= { "" , STR0007 , STR0008 , STR0046 } // Situcao: Vencidos / Nao Vencidos / Sem Reserva
Private cAteSit2:= ""
Private aAteSit3:= { "" }
Private cMarVei := space(TamSX3("VV1_CODMAR")[1])
Private cModVei := space(TamSX3("VV1_MODVEI")[1])
Private lImprimir := .t.
Private cFinanc := ""
Private aFinanc := {}
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := (STR0010)
Default dPDtVI:= dDtVIni
Default dPDtVF:= dDtVFin
Default dPDtRI:= dDtRIni
Default dPDtRF:= dDtRFin
Default cPCod := cCodCli
Default cPLoj := cLojCli
Default cPNom := cNomCli
Default cPTip := cAteTip
Default cPSit1:= cAteSit1
Default cPSit2:= cAteSit2
Default cPMar := cMarVei
Default cPMod := cModVei
Default aPEmp := aEmpr
Default cPEmp := ""
aEmpr := aPEmp
If !Empty(cPEmp)
	cEmpr := " - "+STR0013+":"
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0014,STR0015)
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf
dDtVIni := dPDtVI
dDtVFin := dPDtVF
dDtRIni := dPDtRI
dDtRFin := dPDtRF
cCodCli := cPCod
cLojCli := cPLoj
cNomCli := cPNom
cAteTip := cPTip
cAteSit1:= cPSit1
cAteSit2:= cPSit2
cMarVei := cPMar
cModVei := cPMod
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VV9_XFINAN")
	cFinanc := X3CBOX()
	While len(cFinanc) > 1
		ni := IIf(at(";",cFinanc)==0,len(cFinanc)+1,at(";",cFinanc))
		aAdd(aFinanc,{substr(cFinanc,1,1),substr(cFinanc,3,ni-3)})
		cFinanc := Alltrim(substr(cFinanc,ni+1,len(cFinanc)))
	EndDo
	cFinanc := Alltrim(SX3->X3_DESCRIC)+": "
EndIf
DbSetOrder(1)
Processa( {|| FS_FILTRAR(0) } )

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  33 , .T. , .F. } ) // Filtro
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox
aAdd( aObjects, { 0 ,  40 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oAteVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) PIXEL OF oMainWnd

nTam := ( ( aPos[3,4] - 80 ) / 3 )

@ 000,002 TO 037,(aPos[3,4]-78) LABEL (" "+STR0018+" ") OF oAteVei PIXEL

@ 006,(nTam*0.0)+004 SAY (STR0019+":") SIZE 30,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 005,(nTam*0.0)+044 MSCOMBOBOX oAteTip VAR cAteTip ITEMS aAteTip VALID (FS_REFRIMP(.F.)) SIZE 90,07 OF oAteVei PIXEL COLOR CLR_BLUE

@ 006,(nTam*1)+004 SAY (STR0020+":") SIZE 30,08 OF oAteVei PIXEL COLOR CLR_BLUE
@ 005,(nTam*1)+044 MSGET oCodCli VAR cCodCli VALID (FS_NOMCLI().AND.(FS_REFRIMP(.F.))) F3 "SA1" SIZE 31,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 005,(nTam*1)+077 MSGET oLojCli VAR cLojCli VALID (FS_NOMCLI().AND.(FS_REFRIMP(.F.))) SIZE 10,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 006,(nTam*1)+104 SAY cNomCli SIZE 150,08 OF oAteVei PIXEL COLOR CLR_BLUE

@ 016,(nTam*0)+004 SAY (STR0021+":") SIZE 30,08 OF oAteVei PIXEL COLOR CLR_BLUE
@ 015,(nTam*0)+044 MSGET oDtVIni VAR dDtVIni VALID( (dDtVIni <= dDataBase ).AND.(FS_REFRIMP(.F.)) ) SIZE 40,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 016,(nTam*0)+087 SAY STR0022  SIZE 10,08 OF oAteVei PIXEL COLOR CLR_BLUE
@ 015,(nTam*0)+093 MSGET oDtVFin VAR dDtVFin VALID( (dDtVIni <= dDtVFin .and. dDtVFin <= dDataBase).AND.(FS_REFRIMP(.F.)) ) SIZE 40,06 OF oAteVei PIXEL COLOR CLR_BLUE

@ 016,(nTam*1)+004 SAY (STR0023+":") SIZE 45,08 OF oAteVei PIXEL COLOR CLR_BLUE
@ 015,(nTam*1)+044 MSGET oDtRIni VAR dDtRIni VALID( (dDtRIni <= dDataBase).AND.(FS_REFRIMP(.F.)) ) SIZE 40,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 016,(nTam*1)+087 SAY STR0022  SIZE 10,08 OF oAteVei PIXEL COLOR CLR_BLUE
@ 015,(nTam*1)+093 MSGET oDtRFin VAR dDtRFin VALID( (dDtRIni <= dDtRFin).AND.(FS_REFRIMP(.F.)) ) SIZE 40,06 OF oAteVei PIXEL COLOR CLR_BLUE

@ 026,(nTam*0)+004 SAY ("1-"+STR0024+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 025,(nTam*0)+044 MSCOMBOBOX oAteSit1 VAR cAteSit1 ITEMS aAteSit1 VALID (FS_COMBO().AND.(FS_REFRIMP(.F.))) SIZE 90,07 OF oAteVei PIXEL COLOR CLR_BLUE

@ 026,(nTam*1)+004 SAY ("2-"+STR0025+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 025,(nTam*1)+044 MSCOMBOBOX oAteSit2 VAR cAteSit2 ITEMS aAteSit2 VALID (FS_REFRIMP(.F.)) SIZE 90,07 OF oAteVei PIXEL COLOR CLR_BLUE
@ 025,(nTam*1)+044 MSCOMBOBOX oAteSit3 VAR cAteSit2 ITEMS aAteSit3 SIZE 90,07 OF oAteVei PIXEL COLOR CLR_BLUE WHEN .f.

@ 016,(nTam*2)+004 SAY (STR0041+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 015,(nTam*2)+044 MSGET oMarVei VAR cMarVei VALID( FS_REFRIMP(.F.) ) F3 "VE1" SIZE 25,06 OF oAteVei PIXEL COLOR CLR_BLUE

@ 026,(nTam*2)+004 SAY (STR0043+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ 025,(nTam*2)+044 MSGET oModVei VAR cModVei VALID( FS_REFRIMP(.F.) ) F3 "VV2" SIZE 70,06 OF oAteVei PIXEL COLOR CLR_BLUE

oAteSit3:lVisible:=.f.

@ 001,aPos[1,4]-074 BUTTON oOk PROMPT STR0026  OF oAteVei SIZE 73,09 PIXEL ACTION (Processa( {|| FS_FILTRAR(1) } ),FS_OBSVC110())

@ 010,aPos[1,4]-074 BUTTON oImp PROMPT STR0027  OF oAteVei SIZE 73,09 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir

@ 019,aPos[1,4]-074 BUTTON oEmpr PROMPT UPPER(STR0028) OF oAteVei SIZE 73,09 PIXEL ACTION (lDClik:=.t.,oAteVei:End())

@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbAte FIELDS HEADER ("1"),("2"),(STR0029),(STR0042),(STR0041+" / "+STR0043),(STR0044),(STR0021),(STR0023),(STR0030),(STR0048) COLSIZES 10,10,75,80,85,33,25,42,40,40 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oAteVei PIXEL ON CHANGE FS_OBSVC110() ON DBLCLICK FS_ANALIT(left(aAte[oLbAte:nAt,4],10),aAte[oLbAte:nAt,3])

oLbAte:SetArray(aAte)
oLbAte:bLine := { || { IIF(aAte[oLbAte:nAt,1]+aAte[oLbAte:nAt,2]==" P",oM,IIF(aAte[oLbAte:nAt,1]=="P",oP,IIF(aAte[oLbAte:nAt,1]=="5",olaranja,IIF(aAte[oLbAte:nAt,1]=="3",obranco,IIF(aAte[oLbAte:nAt,1]=="9",oazull,IIF(aAte[oLbAte:nAt,1]=="7",ocinza,"")))))) ,;
IIF(aAte[oLbAte:nAt,1]=="P",oP,IIF(aAte[oLbAte:nAt,1]==" ",oM,IIF(aAte[oLbAte:nAt,2]=="2",overde,IIF(aAte[oLbAte:nAt,2]=="4",overmelho,"")))) ,;
IIF(!(aAte[oLbAte:nAt,1]+aAte[oLbAte:nAt,2]$" X/PM/ P"),Alltrim(aAte[oLbAte:nAt,3])+" "+aAte[oLbAte:nAt,4],aAte[oLbAte:nAt,4]) ,;
aAte[oLbAte:nAt,13] ,;
aAte[oLbAte:nAt,14] ,;
aAte[oLbAte:nAt,15] ,;
aAte[oLbAte:nAt,8]  ,;
aAte[oLbAte:nAt,10] ,;
FG_AlinVlrs(Transform(aAte[oLbAte:nAt,9],"@E 9999,999")) ,;
FG_AlinVlrs(Transform(aAte[oLbAte:nAt,16],"@E 99999,999")) }}

@ aPos[3,1]+001,003 SAY (STR0020+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+012,003 SAY (STR0017+":") SIZE 50,06 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+000,022 MSGET oDesCli VAR cDesCli SIZE 169,06 OF oAteVei PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[3,1]+011,022 MSGET oDesFon VAR cDesFon SIZE  94,06 OF oAteVei PIXEL COLOR CLR_BLUE WHEN .f.
@ aPos[3,1]+011,116 MSGET oDesTip VAR cDesTip SIZE  75,06 OF oAteVei PIXEL COLOR CLR_BLUE WHEN .f.

@ aPos[3,1]+000,191 GET oObserv VAR cObserv OF oAteVei MEMO SIZE (aPos[3,4]-191),021 PIXEL READONLY MEMO

nTam := ( aPos[3,4] / 6 )

@ aPos[3,1]+023,002 TO aPos[3,1]+043,(nTam*4.4) LABEL (" "+"1-"+STR0024+" ") OF oAteVei PIXEL
@ aPos[3,1]+023,(nTam*4.4)+002 TO aPos[3,1]+043,aPos[3,4] LABEL (" "+"2-"+STR0025+" ") OF oAteVei PIXEL

@ aPos[3,1]+032,(nTam*0.0)+006 BITMAP OXbranco RESOURCE "BR_BRANCO" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*0.0)+014 SAY STR0006 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+032,(nTam*1.1)+006 BITMAP OXlaranja RESOURCE "BR_LARANJA" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*1.1)+014 SAY STR0005 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+032,(nTam*2.2)+006 BITMAP OXcinza RESOURCE "BR_CINZA" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*2.2)+014 SAY STR0040 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+032,(nTam*3.3)+006 BITMAP OXazull RESOURCE "BR_AZUL" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*3.3)+014 SAY STR0009 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE

@ aPos[3,1]+032,(nTam*4.4)+006 BITMAP OXverde RESOURCE "BR_VERDE" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*4.4)+014 SAY STR0007 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE
@ aPos[3,1]+032,(nTam*5.2)+006 BITMAP OXvermelho RESOURCE "BR_VERMELHO" OF oAteVei PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+032,(nTam*5.2)+014 SAY STR0008 SIZE 80,10 OF oAteVei PIXEL COLOR CLR_BLUE

@ 028,aPos[1,4]-074 BUTTON oAteSair PROMPT STR0031 OF oAteVei SIZE 73,09 PIXEL ACTION oAteVei:End()

oLbAte:SetFocus()

ACTIVATE MSDIALOG oAteVei CENTER
If lDClik
	VEIVC110(cEmpr,aEmpr,dDtVIni,dDtVFin,dDtRIni,dDtRFin,cCodCli,cLojCli,cNomCli,cAteTip,cAteSit1,cAteSit2,cMarVei,cModVei)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_NOMCLI³ Autor ³ Andre Luis Almeida        ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento do Nome do Cliente                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NOMCLI()
Local lRet := .f.
Local cQuery  := ""
Local cQAlSA1 := "SQLSA1"
cNomCli := space(TamSX3("A1_NOME")[1])
If Empty(cCodCli)
	lRet := .t.
	cLojCli := space(TamSX3("A1_LOJA")[1])
Else
	// Posiciona no SA1
	cQuery := "SELECT SA1.A1_NOME , SA1.A1_COD , SA1.A1_LOJA FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
	cQuery += "SA1.A1_COD='"+cCodCli+"' AND "+IIf(!Empty(cLojCli),"SA1.A1_LOJA='"+cLojCli+"' AND ","")+"SA1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )
	If ( cQAlSA1 )->( A1_COD ) == cCodCli .and. ( Empty(cLojCli) .or. ( cQAlSA1 )->( A1_LOJA ) == cLojCli )
		lRet := .t.
		cNomCli := ( cQAlSA1 )->( A1_NOME )
		cLojCli := ( cQAlSA1 )->( A1_LOJA )
	EndIf
	( cQAlSA1 )->( dbCloseArea() )
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_ATEND ³ Autor ³ Andre Luis Almeida        ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento dos Atendimentos conforme o Filtro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATEND()
Local nEmpr    := 0
Local cQuery   := ""
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cFilSALVA:= cFilAnt
aNVei := {}
For nEmpr := 1 to len(aEmpr)
	cFilAnt := aEmpr[nEmpr,1]
	// Levanta os Atendimentos VV9 / VV0
	cQuery := FS_ABRESQL("VV09_1",,)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
	Do While !( cQAlVV09 )->( Eof() )
		If !Empty( ( cQAlVV09 )->( VV9_NUMATE ) )
			Aadd(aNVei,{ ( cQAlVV09 )->( VV9_NUMATE ) , aEmpr[nEmpr,1] , aEmpr[nEmpr,2] })
		EndIf
		( cQAlVV09 )->( DbSkip() )
	EndDo
	( cQAlVV09 )->( dbCloseArea() )
Next
aSort(aNVei,1,,{|x,y| x[2]+x[3]+x[1] < y[2]+y[3]+y[1] })
cFilAnt := cFilSALVA
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida        ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento pela Marca / Grupos de Modelo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nx)
Local lOk     := .t.
Local nNVei   := 0
Local cTipFat := ""
Local cCor1   := "3"
Local cCor2   := "2"
Local nVlr1   := 0
Local nVlr2   := 0
Local nTot1   := 0
Local nTot2   := 0
Local cQuery  := ""
Local cQAlVV09:= "SQLVV09" // VV0 / VV9
Local cQAlSA1 := "SQLSA1" // SA1
Local cQAlVS9 := "SQLVS9" // VS9
Local cQAlVEIC:= "SQLVEIC" // VEICULO (VVA/VV1/VV2/VVC)
Local cHorVal := left(Time(),2)+substr(Time(),4,2)
Local cMDtHr  := ""
Local ni      := 0
Local nt      := 0
Local cFilSALVA:= cFilAnt
aAte := {}
cFiltro1 := STR0021+": "+Transform(dDtVIni,"@D")+" "+STR0022+" "+Transform(dDtVFin,"@D")+" - "+STR0023+": "+Transform(dDtRIni,"@D")+" "+STR0022+" "+Transform(dDtRFin,"@D")+IIf(!Empty(cCodCli+cLojCli)," - "+STR0020+": "+cCodCli+"-"+cLojCli+" "+cNomCli,"")
cFiltro2 := IIf(!Empty(cAteTip),STR0019+":"+cAteTip+" ","")+IIf(!Empty(cAteSit1),"1-"+STR0024+": "+cAteSit1+" ","")+IIf(!Empty(cAteSit2),"2-"+STR0025+": "+cAteSit2,"")
FS_ATEND()
For nNVei := 1 to len(aNVei)
	cFilAnt := aNVei[nNVei,2]
	lOk  := .t.
	// Posiciona no VV9/VV0 com NRO.ATENDIMENTO
	cQuery := FS_ABRESQL("VV09_2",aNVei[nNVei,1],)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVV09, .F., .T. )
	cTipFat := space(22)
	If ( cQAlVV09 )->( VV0_TIPFAT ) == "0"
		cTipFat := left(STR0002+space(22),22)
	ElseIf  ( cQAlVV09 )->( VV0_TIPFAT ) =="2"
		cTipFat := left(STR0003+space(22),22)
	Else
		cTipFat := left(STR0004+space(22),22)
	EndIf
	cMDtHr := Transform(stod(( cQAlVV09 )->( VV0_DATVAL )),"@D")+" "+Transform(( cQAlVV09 )->( VV0_HORVAL ),"@R 99:99")
	nVlr2 := ( cQAlVV09 )->( VV0_VALTOT )
	If ( cQAlVV09 )->( VV9_STATUS ) == "F"
		cCor1 := " "
		nVlr1 := 0
		lOk   := .f.
		cQuery := FS_ABRESQL("VS9",( cQAlVV09 )->( VV0_NUMTRA ),)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVS9, .F., .T. )
		While !( cQAlVS9 )->(Eof())
			if Empty(( cQAlVS9 )->( VS9_DATBAI ))
				cCor1 := "9"
			Else
				nVlr2 -= ( cQAlVS9 )->( VS9_VALPAG )
			EndIf
			( cQAlVS9 )->( DbSkip() )
		EndDo
		( cQAlVS9 )->( dbCloseArea() )
		If !Empty(cCor1)
			cCor2 := " "
			lOk   := .t.
			cMDtHr:= STR0047+" "+Transform(stod(( cQAlVV09 )->( VV0_DATMOV )),"@D")
		EndIf
		If !Empty(cAteSit1) .and. cAteSit1<>STR0009
			lOk := .f.
		Else
			If ( cQAlVV09 )->( VV0_DATMOV ) < dtos(dDtRIni) .or. ( cQAlVV09 )->( VV0_DATMOV ) > dtos(dDtRFin)
				lOk := .f.
			EndIf
		EndIf
	Else
		cCor1 := "3"
		cCor2 := "2"
		If Empty( ( cQAlVV09 )->( VV0_RESERV ) ) .or. ( cQAlVV09 )->( VV0_RESERV ) == "0" // Sem Reserva
			cCor2  := " "
			cMDtHr := ""
		Else
			// cor 2 = vencimento da data da reserva
			If dDataBase > stod(( cQAlVV09 )->( VV0_DATVAL ))
				cCor2 := "4"
				If !Empty(cAteSit2) .and. cAteSit2<>STR0008
					lOk := .f.
				EndIf
			ElseIf dDataBase == stod(( cQAlVV09 )->( VV0_DATVAL ))
				If cHorVal > ( cQAlVV09 )->( VV0_HORVAL )
					cCor2 := "4"
					If !Empty(cAteSit2) .and. cAteSit2<>STR0008
						lOk := .f.
					EndIf
				EndIf
			ElseIf !Empty(cAteSit2) .and. cAteSit2<>STR0007
				lOk := .f.
			EndIf
		EndIf
		If ( cQAlVV09 )->( VV0_DATVAL ) < dtos(dDtRIni) .or. ( cQAlVV09 )->( VV0_DATVAL ) > dtos(dDtRFin)
			lOk := .f.
		EndIf
		If lOk
			// cor 1
			lQuitTot := .t.
			nVlr1 := 0
			cQuery := FS_ABRESQL("VS9",( cQAlVV09 )->( VV0_NUMTRA ),)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVS9, .F., .T. )
			If ( cQAlVS9 )->(Eof())
				lQuitTot := .f.
			EndIf
			While !( cQAlVS9 )->(Eof())
				If Empty(( cQAlVS9 )->( VS9_DATBAI))
					lQuitTot := .f.
				Else
					nVlr2 -= ( cQAlVS9 )->( VS9_VALPAG )
					If ( cQAlVS9 )->( VS9_TIPPAG ) $ cTpPgSin
						cCor1 := "5"
						nVlr1 += ( cQAlVS9 )->( VS9_VALPAG )
					EndIf
				EndIf
				( cQAlVS9 )->( DbSkip() )
			EndDo
			( cQAlVS9 )->( dbCloseArea() )
			If lQuitTot
				cCor1 := "7"
				nVlr1 := 0
				If !Empty(cAteSit1) .and. cAteSit1<>STR0040
					If cAteSit1<>STR0050
						lOk := .f.
					EndIf
				EndIf
			ElseIf cCor1 == "5"
				If !Empty(cAteSit1) .and. cAteSit1<>STR0005
					If cAteSit1<>STR0050
						lOk := .f.
					EndIf
				EndIf
			Else
				If !Empty(cAteSit1) .and. cAteSit1<>STR0006
					If cAteSit1<>STR0050
						lOk := .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If lOk
		If Empty(cCor2)
			lOk := .f.
			If Empty(cAteSit2) .or. ( cAteSit2 == STR0046 )
				lOk := .t.
			EndIf
		EndIf
	EndIf
	If lOk
		cQuery := FS_ABRESQL("VEIC",( cQAlVV09 )->( VV0_NUMTRA ),)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVEIC, .F., .T. )
		If ( Empty(cMarVei) .or. cMarVei == ( cQAlVEIC )->( VV1_CODMAR ) ) .and. ( Empty(cModVei) .or. cModVei == ( cQAlVEIC )->( VV1_MODVEI ) )
			nTot1 += nVlr1
			nTot2 += nVlr2
			cQuery := FS_ABRESQL("SA1",( cQAlVV09 )->( VV9_CODCLI ),( cQAlVV09 )->( VV9_LOJA ))
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlSA1, .F., .T. )
			aadd(aAte,{cCor1,cCor2,aNVei[nNVei,2],( cQAlVV09 )->( VV0_NUMTRA ), cTipFat ,( cQAlVV09 )->( VV9_CODCLI )+"-"+( cQAlVV09 )->( VV9_LOJA )+" "+left(( cQAlSA1 )->( A1_NOME ),35),Alltrim(( cQAlVV09 )->( VV9_TELVIS ))+IIf(Alltrim(( cQAlVV09 )->( VV9_TELVIS ))#Alltrim(( cQAlSA1 )->( A1_TEL ))," / "+Alltrim(( cQAlSA1 )->( A1_TEL )),""),Transform(stod(( cQAlVV09 )->( VV9_DATVIS )),"@D"),nVlr1,cMDtHr,( cQAlVV09 )->( VV9_OBSMEM ),IIf(!Empty(cFinanc),( cQAlVV09 )->( VV9_XFINAN ),""),( cQAlVEIC )->( VV1_CHASSI ),( cQAlVEIC )->( VV1_CODMAR )+" "+left(( cQAlVEIC )->( VV2_DESMOD ),20),left(( cQAlVEIC )->( VVC_DESCRI ),10),nVlr2,"3"})
			nt++
			ni := aScan(aAte,{|x| x[3]+x[17] == aNVei[nNVei,2]+"1" })
			If ni > 0
				aAte[ni,9]  += nVlr1
				aAte[ni,16] += nVlr2
				aAte[ni,13] := Transform(val(left(aAte[ni,13],7))+1,"@E 999,999")+" "+STR0045
			Else
				aadd(aAte,{" ","P",aNVei[nNVei,2],Alltrim(FWFilialName())+" ("+cFilAnt+")","","","","",nVlr1,"","","","      1 "+STR0045,space(50),"",nVlr2,"1"})
			EndIf
			ni := aScan(aAte,{|x| x[3]+x[17]+x[14] == aNVei[nNVei,2]+"2"+( cQAlVEIC )->( VV1_CODMAR )+" "+left(( cQAlVEIC )->( VV2_DESMOD ),20) })
			If ni > 0
				aAte[ni,9]  += nVlr1
				aAte[ni,16] += nVlr2
				aAte[ni,13] := Transform(val(left(aAte[ni,13],7))+1,"@E 999,999")+" "+STR0045
			Else
				aadd(aAte,{" ","X",aNVei[nNVei,2],STR0041+" / "+STR0043,"","","","",nVlr1,"","","","      1 "+STR0045,( cQAlVEIC )->( VV1_CODMAR )+" "+left(( cQAlVEIC )->( VV2_DESMOD ),20),"",nVlr2,"2"})
			EndIf
			( cQAlSA1 )->( dbCloseArea() )
		EndIf
		( cQAlVEIC )->( dbCloseArea() )
	EndIf
	( cQAlVV09 )->( dbCloseArea() )
Next
If len(aAte) > 0
	aadd(aAte,{"P","P"," "+STR0049,"","","","","",nTot1,"","","",Transform(nt,"@E 999,999")+" "+STR0045,"","",nTot2,"0"})
	aSort(aAte,1,,{|x,y| x[3]+x[14]+x[17]+x[1]+x[2]+x[4] < y[3]+y[14]+y[17]+y[1]+y[2]+y[4] })
Else
	aadd(aAte,{"P","P","","","","","","",0,"","","","","","",0,"0"})
EndIf
If nx # 0
	FS_REFRIMP(.T.)
	If oLbAte:nAt > len(aAte)
		oLbAte:nAt := 1
	EndIf
	oLbAte:SetArray(aAte)
	oLbAte:bLine := { || { IIF(aAte[oLbAte:nAt,1]+aAte[oLbAte:nAt,2]==" P",oM,IIF(aAte[oLbAte:nAt,1]=="P",oP,IIF(aAte[oLbAte:nAt,1]=="5",olaranja,IIF(aAte[oLbAte:nAt,1]=="3",obranco,IIF(aAte[oLbAte:nAt,1]=="9",oazull,IIF(aAte[oLbAte:nAt,1]=="7",ocinza,"")))))) ,;
	IIF(aAte[oLbAte:nAt,1]=="P",oP,IIF(aAte[oLbAte:nAt,1]==" ",oM,IIF(aAte[oLbAte:nAt,2]=="2",overde,IIF(aAte[oLbAte:nAt,2]=="4",overmelho,"")))) ,;
	IIF(!(aAte[oLbAte:nAt,1]+aAte[oLbAte:nAt,2]$" X/PM/ P"),Alltrim(aAte[oLbAte:nAt,3])+" "+aAte[oLbAte:nAt,4],aAte[oLbAte:nAt,4]) ,;
	aAte[oLbAte:nAt,13] ,;
	aAte[oLbAte:nAt,14] ,;
	aAte[oLbAte:nAt,15] ,;
	aAte[oLbAte:nAt,8]  ,;
	aAte[oLbAte:nAt,10] ,;
	FG_AlinVlrs(Transform(aAte[oLbAte:nAt,9],"@E 9999,999")) ,;
	FG_AlinVlrs(Transform(aAte[oLbAte:nAt,16],"@E 99999,999")) }}
	oLbAte:SetFocus()
	oLbAte:Refresh()
EndIf
cFilAnt := cFilSALVA
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_ANALIT³ Autor ³ Andre Luis Almeida        ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento por Modelo / Atendimento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ANALIT(cNroAte,cEmpF)
Local cSlvFil := cFilAnt
Default cEmpF := cFilAnt
If left(cNroAte,1)<="9" .and. !Empty(cNroAte)
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( xFilial("VV9") + cNroAte )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
	EndIf
EndIf
cFilAnt := cSlvFil
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_OBSVC110³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento da Observacao do Atendimento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSVC110()
Local ni := 0
cObserv := ""
cDesTip := aAte[oLbAte:nAt,5]
cDesCli := aAte[oLbAte:nAt,6]
cDesFon := aAte[oLbAte:nAt,7]
oDesTip:Refresh()
oDesCli:Refresh()
oDesFon:Refresh()
If !Empty(aAte[oLbAte:nAt,12])
	ni := aScan(aFinanc,{|x| x[1] == aAte[oLbAte:nAt,12] })
	If ni > 0
		cObserv := cFinanc+aFinanc[ni,2]+CHR(13)+CHR(10)
	EndIf
EndIf
If !Empty(aAte[oLbAte:nAt,11])
	DBSelectArea("VV9")
	cObserv += MSMM(aAte[oLbAte:nAt,11],70)
EndIf
oObserv:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_FILIAIS³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento das Filiais                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0028 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0034,STR0035 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIK    ³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik Total das Filiais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_ABRESQL³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Gera cQuery do SQL                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ABRESQL(cTp,cAux1,cAux2)
Local cQuery  := ""
IF cTp == "SA1" // Cliente
	cQuery := "SELECT SA1.A1_NOME , SA1.A1_TEL FROM "+RetSqlName("SA1")+" SA1 WHERE "
	cQuery += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+cAux1+"' AND SA1.A1_LOJA='"+cAux2+"' AND SA1.D_E_L_E_T_=' '"
ElseIf cTp == "VS9"
	cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_DATBAI , VS9.VS9_VALPAG FROM "+RetSqlName("VS9")+" VS9 WHERE "
	cQuery += "VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+cAux1+"' AND VS9.D_E_L_E_T_=' '"
ElseIf cTp == "VEIC"
	cQuery := "SELECT VV1.VV1_CODMAR , VV1.VV1_CHASSI , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VVC.VVC_DESCRI "
	cQuery += "FROM "+RetSqlName("VVA")+" VVA , "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 , "+RetSqlName("VVC")+" VVC WHERE "
	cQuery += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND VVA.VVA_NUMTRA='"+cAux1+"' AND VVA.D_E_L_E_T_=' ' AND "
	cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVA.VVA_CHAINT AND VV1.D_E_L_E_T_=' ' AND "
	cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' AND "
	cQuery += "VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' '"
Else
	If cTp == "VV09_1"
		cQuery := "SELECT VV9.VV9_NUMATE FROM "+RetSqlName("VV9")+" VV9 INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV9.VV9_NUMATE=VV0.VV0_NUMTRA WHERE VV9.VV9_STATUS<>'C' AND VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
	ElseIf cTp == "VV09_2"
		cQuery := "SELECT VV0.VV0_TIPFAT , VV0.VV0_DATVAL , VV0.VV0_HORVAL , VV0.VV0_VALTOT , VV9.VV9_STATUS , VV0.VV0_NUMTRA , VV0.VV0_DATMOV , VV0.VV0_RESERV , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_TELVIS , VV9.VV9_DATVIS , VV9.VV9_OBSMEM "
		If !Empty(cFinanc)
			cQuery += " , VV9.VV9_XFINAN "
		EndIf
		cQuery += "FROM "+RetSqlName("VV9")+" VV9 INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV9.VV9_NUMATE=VV0.VV0_NUMTRA "
		cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE='"+cAux1+"' AND VV9.VV9_STATUS<>'C' AND VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
	EndIf
	If left(cAteTip,1) == "0"
		cQuery += "VV0.VV0_TIPFAT IN ('0','1') AND "
	Else
		If left(cAteTip,1)<>"3" .and. !Empty(cAteTip)
			cQuery += "VV0.VV0_TIPFAT='"+left(cAteTip,1)+"' AND "
		Else
			If !Empty(cAteTip)
				cQuery += "VV0.VV0_TIPFAT<>'0' AND VV0.VV0_TIPFAT<>'1' AND VV0.VV0_TIPFAT<>'2' AND "
			EndIf
		EndIf
	EndIf
	cQuery += "VV9.VV9_DATVIS>='"+dtos(dDtVIni)+"' AND VV9.VV9_DATVIS<='"+dtos(dDtVFin)+"' AND "
	cQuery += "VV9.VV9_STATUS IN ('F','T','O','R','L','A','P') AND "
	If !Empty(cCodCli+cLojCli)
		cQuery += "VV9.VV9_CODCLI='"+cCodCli+"' AND VV9.VV9_LOJA='"+cLojCli+"' AND "
	EndIf
	cQuery += "VV9.D_E_L_E_T_=' ' AND VV0.D_E_L_E_T_=' '"
endif
Return( cQuery )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao da Listagem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= "VV9"
Local aImpr     := {}
Local ni        := 0
Local cQuebra   := ""
Local cCont     := ""
Private nLin    := 1
Private aReturn := { STR0036  , 1 ,STR0037  , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "M"           // P/M/G
Private Limite  := 132            // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0001+" "+cEmpr
Private cNomProg:= "VEIVC110"
Private cNomeRel:= "VEIVC110"
Private nLastKey:= 0
Private cabec1  := cFiltro1
Private cabec2  := cFiltro2
Private nCaracter:=15
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "VV9"
Private Li      := 132
Private m_Pag   := 1
Private lAbortPrint := .f.
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
aImpr := aClone(aAte)
If len(aImpr) > 0
	nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	@ nLin++ , 00 psay space(108)+STR0051 // Vlr.Sinal Vlr.Restant
	@ nLin++ , 00 psay left(aImpr[1,3]+" ( "+aImpr[1,13]+" )"+space(106),106)+Transform(aImpr[1,9],"@E 9999,999.99")+Transform(aImpr[1,16],"@E 99999,999.99")
	nLin++
	nLin++
	For ni:=2 to Len(aImpr)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			cCont := STR0038
			cQuebra := ""
		EndIf
		If cQuebra <> left(aImpr[ni,1]+space(5),5)+left(aImpr[ni,2]+space(5),5)
			If !Empty(cQuebra)
				nLin++
				nLin++
			EndIf
			cQuebra := left(aImpr[ni,1]+space(5),5)+left(aImpr[ni,2]+space(5),5)
			If !Empty(aImpr[ni,1])
				@ nLin++ , 00 psay "<<< " + IIF(aImpr[ni,1]=="3",STR0006,IIF(aImpr[ni,1]=="5",STR0005,IIF(aImpr[ni,1]=="7",STR0040,STR0009))) + IIF(!Empty(aImpr[ni,2])," - "+IIF(aImpr[ni,2]=="2",STR0007,STR0008),"") + " >>> "+cCont
			EndIf
			nLin++
			If !Empty(aImpr[ni,5])
				@ nLin++ , 00 psay STR0039
			EndIf
			cCont := ""
		EndIf
		If Empty(aImpr[ni,5])
			@ nLin++ , 00 psay space(108)+STR0051 // Vlr.Sinal Vlr.Restant
			@ nLin++ , 00 psay Left(aImpr[ni,3]+" "+aImpr[ni,4]+space(106),106)+Transform(aImpr[ni,9],"@E 9999,999.99")+Transform(aImpr[ni,16],"@E 99999,999.99")
		Else
			@ nLin++ , 00 psay left(aImpr[ni,3]+space(14),14)+" "+aImpr[ni,4]+"  "+Left(aImpr[ni,5]+" "+left(aImpr[ni,6],27)+" "+left(aImpr[ni,8]+space(10),10)+" "+aImpr[ni,10]+space(79),79)+Transform(aImpr[ni,9],"@E 9999,999.99")+Transform(aImpr[ni,16],"@E 99999,999.99")
		EndIf
		If !Empty(aImpr[ni,14])
			@ nLin++ , 18 psay STR0041+"/"+STR0043+"/"+STR0044+":  "+aImpr[ni,14]+" "+aImpr[ni,15]+" - "+STR0042+": "+aImpr[ni,13]
		EndIf
	Next
EndIf
Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_COMBO  ³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Habilita/Desabilita na tela o campo/combo da SITUACAO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBO()
if cAteSit1 == STR0009
	oAteSit2:lVisible:=.f.
	oAteSit3:lVisible:=.t.
	cAteSit2 := ""
else
	oAteSit2:lVisible:=.t.
	oAteSit3:lVisible:=.f.
endif
return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_REFRIMP³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Habilita/Desabilita na tela o botao Imprimir                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRIMP(lTipo)
lImprimir := lTipo
oImp:Refresh()
return(.t.)

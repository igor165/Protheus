#include "OFIIA290.CH"
#include "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA290 ³ Autor ³  Luis / Manoel Filho  ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Levantamento da Demanda Diaria SCANIA                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Manoel - 30/06/2008 - conversado com o Mauricio p/ trata-  ³±±
±±³          ³ mento do SCW da mesma forma que tratamos SCG / SCA e SCR   ³±±
±±³          ³ (conversamos por telefone e o Mauricio concordou c/ a alt) ³±±
±±³          ³ 15/07/08 - Nao enviar grupo SCL (problema de balde X litro)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA290(cParChamada)

Local cFilBottom := xFilial("VES")

// Levanta Movimentacoes diarias ate 20:00h. Ou seja, apos 20:00 sera considerada no
// dia Posterior

// Manoel / Silvania  -  19/11/2008
// Conforme email do Pilon e do Mauricio, foi pedido para que o dia inicial da Demanda semanal seja
// a Quinta-feira e nao mais a Sexta-feira (mesma solucao da PB Lopes)

Private lAuto := .f.
Private cPerg := "OFI290"
Private dIniDem := Ctod("01/01/"+strzero(year(dDataBase)))-dow(Ctod("01/01/"+strzero(year(dDataBase))))//Ctod(GetMv("MV_PRSEDEM"))
Private cChamada := cParChamada

If valtype(cChamada) != "U" .and. Upper(cChamada) == "ATUALIZAEGERA"
	dIniDem := Ctod("01/01/"+strzero(year(dDataBase)))-dow(Ctod("01/01/"+strzero(year(dDataBase))))//Ctod(GetMv("MV_PRSEDEM"))
	lAuto    := .t.
	DbSelectArea("VES")
	DbSetOrder(2)
	//	dbgobottom()
	cFilBottom := Soma1( cFilBottom, Len(cFilBottom) )
	DbSeek( cFilBottom , .T. )
	DbSkip(-1)
	
	Mv_Par01 := VES->VES_DATDEM
	DbSelectArea("VES")
	DbSetOrder(1)
	Mv_Par02 := dDataBase
	If Mv_Par01 > Mv_Par02
		Mv_Par01 := Mv_Par02 - 6
	Endif
	FS_LvDemDia()
	FS_CriTotDem() // Cria Totais da Demanda
	
	Pergunte("INTVH6", .F. ) // Restaura os MV_PARs do OFIIA200
	
	Return
Endif

Private aRotina := { { STR0002,"axPesqui", 0 , 1},;     //Pesquisar
{ STR0003,"OFIIA2901", 0 , 2},;    	//Visualizar
{ STR0007,"OFIIA2901", 0 , 3},;     //Levantar
{ STR0008,"OFIIA2901", 0 , 4},;     //Totalizar
{ STR0009,"OFIIA2901", 0 , 5}}     	//Tot/Gera Tudo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0010)    //Demanda Diaria
Private cAlias    := "VES"
Private nOPC      := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(06,01,22,75,"VES")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA2901³ Autor ³  Luis / Manoel Filho  ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Consulta ou Levantamento da Demanda Diaria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA2901(cAlias,nReg,nOpc)
Local bCampo       := { |nCPO| Field(nCPO) }
Local oDlg
Local nCntFor := 0
Local _ni := 0
nOpcE := 2
nOpcG := 2

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VES")
While !Eof().and.(x3_arquivo=="VES")
	If X3USO(x3_usado).and. cNivel >= x3_nivel .and. Alltrim(X3_Campo) $ "VES_GRUITE#VES_CODITE"
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	DbSkip()
End

if !Inclui
	DbSelectArea("VES")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VES")
aHeader:={}
While !Eof().And.(x3_arquivo=="VES")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !Alltrim(X3_Campo) $ "VES_GRUITE#VES_CODITE"
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	DbSkip()
End

DbSelectArea("VES")
DbSetOrder(1)

if nOpc == 3
	aCols:={}
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	While VES->VES_FILIAL+VES->VES_GRUITE+VES->VES_CODITE == xFilial("VES")+M->VES_GRUITE+M->VES_CODITE .and. !eof()
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	Enddo
Endif

If Len(aCols)>0 .and. Len(aHeader)>0 .and. nOpc == 2
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo    :=OemToAnsi(STR0010) //Demanda Diaria
	cAliasEnch :="VES"
	cLinOk     :="AllwaysTrue()"
	cTudoOk    :="AllwaysTrue()"
	cFieldOk   :="AllwaysTrue()"
	nOpca      := 0
	nReg       := 0
	
	aAltEnchoice := {}
	Private Altera:=.f.
	Private Inclui:=.f.
	Private lRefresh:=.t.
	Private aTELA:=Array(0,0),aGets:=Array(0)
	
	lVirtual := .f. //Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas:= 740
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
	EnChoice("VES",nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},aCpoEnchoice,2,,,,,,)
	oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
	
Else
	
	If nOpc == 3
		Processa({|| FS_LvDemDia()})
	ElseIf nOpc == 4
		If MsgYesno(STR0012,STR0013) //Tem certeza que deseja Totalizar Arquivo neste Momento? # Atencao
			Processa({|| FS_CriTotDem()}) // Cria Totais da Demanda
		Endif
	ElseIf nOpc == 5
		If MsgYesno(STR0014,STR0013)// Esta opcao ira gerar todos os Arquivos de Demanda, desde o inicio do DSM. Tem certeza que quer fazer isso? # Atencao
			Processa({|| FS_CriTot()}) // Cria Totais da Demanda
		Endif
	Endif
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_LVDEMDIA³ Autor ³ Luis / Manoel Filho  ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Levantamento da Demanda Diaria                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LVDEMDIA()
Local lPE        := ExistBlock("OFA290DD")

Local cFilSD2    := xFilial("SD2")
Local cFilSF2    := xFilial("SF2")
Local cFilSB1    := xFilial("SB1")
Local cFilSF4    := xFilial("SF4")
Local cFilVS1    := xFilial("VS1")
Local cFilVS3    := xFilial("VS3")
Local cFilV09    := xFilial("V09")
Local cFilSD1    := xFilial("SD1")
Local cFilSF1    := xFilial("SF1")
Local cFilVE6    := xFilial("VE6")
Local cFilVE7    := xFilial("VE7")
Local cFilVO2    := xFilial("VO2")
Local cFilVO3    := xFilial("VO3")

Private cSQLSD2  := "SQLSD2" // utilizado dentro do Ponto de Entrada OFA310DD  quando o parametro for SD2
Private cSQLSF1  := "SQLSF1" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for SF1
Private cSQLVE6  := "SQLVE6" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for VE6
Private cSQLVO2  := "SQLVO2" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for VO2


ValidPerg()

If !lAuto
	pergunte(cPerg,.t.)
Endif
// Mv_Par01 - Data Inicial do Levantamento
// Mv_Par02 - Data Final do Levantamento

// Zeramento das Demandas do Periodo
FS_ZeraSem()
If !(valtype(cChamada) != "U" .and. Upper(cChamada) == "ATUALIZAEGERA")
	dIniDem := Ctod("01/01/"+strzero(year(Mv_Par01)))-dow(Ctod("01/01/"+strzero(year(Mv_Par01),4)))//Ctod(GetMv("MV_PRSEDEM"))
Endif
dIniDem := dIniDem - 1


// Levantamento das Vendas
If !lAuto
	ProcRegua(7400)
Endif
cNumNfi := ""

cQuery := "SELECT SB1.* , SD2.*  , SF2.* , VS3.* , V09.V09_LEVDEM , VS3.R_E_C_N_O_ VS3RECNO "
cQuery += "FROM "+RetSQLName("SD2")+" SD2 "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+cFilSB1+"' AND SB1.B1_COD     = SD2.D2_COD     AND SB1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SF4")+" SF4 ON  SF4.F4_FILIAL  = '"+cFilSF4+"' AND SF4.F4_CODIGO  = SD2.D2_TES     AND SF4.F4_ESTOQUE <> 'N'         AND SF4.F4_DUPLIC  <> 'N'                      AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SF2")+" SF2 ON  SF2.F2_FILIAL  = '"+cFilSF2+"' AND SF2.F2_DOC     = SD2.D2_DOC     AND SF2.F2_SERIE   = SD2.D2_SERIE AND SF2.F2_PREFORI = '"+Getmv("MV_PREFBAL")+"' AND SF2.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("VS1")+" VS1 ON  VS1.VS1_FILIAL = '"+cFilVS1+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC     AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("VS3")+" VS3 ON  VS3.VS3_FILIAL = '"+cFilVS3+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.VS3_CODITE = SB1.B1_CODITE AND VS3.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("V09")+" V09 ON  V09.V09_FILIAL = '"+cFilV09+"' AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' ' "
cQuery += "WHERE SD2.D2_FILIAL = '"+cFilSD2+"' AND SD2.D2_EMISSAO >= '"+Dtos(Mv_Par01)+"' AND SD2.D2_EMISSAO <= '"+Dtos(Mv_Par02)+"' AND "
cQuery += "SD2.D_E_L_E_T_=' ' "

If Select(cSQLSD2) > 0
	(cSQLSD2)->(DbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2 , .F. , .T. )


While (cSQLSD2)->(!Eof())
	
	If !lAuto
		IncProc(STR0015)   //Aguarde... Levantando as Vendas...
	Endif
	
	If cNumNfi != (cSQLSD2)->D2_DOC
		cNumNfi := (cSQLSD2)->D2_DOC
	Endif
	
	If (cSQLSD2)->VS3_CODSIT $ "03/06" // Escrape ou Recompra
		(cSQLSD2)->(DbSkip())
		Loop
	Endif
	
	If lPE
		If !ExecBlock("OFA290DD",.f.,.f.,{"SD2"})
			(cSQLSD2)->(DbSkip())
			Loop
		Endif
	Endif
	
	cDataLog := DtoC(dDataBase)
	cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
	
	DbSelectArea("VES")
	DbSetOrder(1)
	If (cSQLSD2)->F2_HORA > "20:00"
		DbSeek(xFilial("VES")+(cSQLSD2)->B1_GRUPO+(cSQLSD2)->B1_CODITE+dTos( sTod( (cSQLSD2)->D2_EMISSAO)+1 ))
		
	Else
		DbSeek(xFilial("VES")+(cSQLSD2)->B1_GRUPO+(cSQLSD2)->B1_CODITE+(cSQLSD2)->D2_EMISSAO)
	Endif
	RecLock("VES",!Found())
	VES->VES_FILIAL := xFilial("VES")
	VES->VES_GRUITE := (cSQLSD2)->B1_GRUPO
	VES->VES_CODITE := (cSQLSD2)->B1_CODITE
	If (cSQLSD2)->F2_HORA > "20:00"
		VES->VES_DATDEM := sTod((cSQLSD2)->D2_EMISSAO) + 1
		VES->VES_SEMANA := strzero(Int(((sTod((cSQLSD2)->D2_EMISSAO)+1) - dIniDem) / 7 ) + 1,2)
	Else
		VES->VES_DATDEM := sTod((cSQLSD2)->D2_EMISSAO)
		VES->VES_SEMANA := strzero(Int(( sTod((cSQLSD2)->D2_EMISSAO) - dIniDem) / 7 ) + 1,2)
	Endif
	
	VES->VES_LOGDEM := cLog
	
	If (cSQLSD2)->V09_LEVDEM == "1"
		VES->VES_DEMBAL := VES->VES_DEMBAL + (cSQLSD2)->D2_QUANT
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Else
		VES->VES_DEMEXP := VES->VES_DEMEXP + (cSQLSD2)->D2_QUANT
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Endif
	
	MsUnLock()
	
	(cSQLSD2)->(DbSkip())
	
Enddo

If Select(cSQLSD2) > 0
	(cSQLSD2)->(DbCloseArea())
EndIf
//
DBSelectArea("VES")

// Levantamento das Devolucoes
If !lAuto
	ProcRegua(740)
Endif

cQuery := "SELECT SB1.* , SD2.*  , SF2.* , SF1.* , SD1.* , VS3.* , V09.V09_LEVDEM , VS3.R_E_C_N_O_ VS3RECNO "
cQuery += "FROM "+RetSQLName("SF1")+" SF1 "
cQuery += "INNER JOIN "+RetSQLName("SD1")+" SD1 ON  SD1.D1_FILIAL      = '"+cFilSD1+"' AND SD1.D1_DOC     = SF1.F1_DOC AND SD1.D1_SERIE         = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SD1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL      = '"+cFilSB1+"' AND SB1.B1_COD     = SD1.D1_COD AND SB1.D_E_L_E_T_       =' ' "
cQuery += "INNER JOIN "+RetSQLName("SF4")+" SF4D1 ON  SF4D1.F4_FILIAL  = '"+cFilSF4+"' AND SF4D1.F4_CODIGO= SD1.D1_TES AND SF4D1.F4_ESTOQUE     = 'S' AND SF4D1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SF2")+" SF2 ON  SF2.F2_FILIAL      = '"+cFilSF2+"' AND SF2.F2_DOC     = SD1.D1_NFORI   AND SF2.F2_SERIE     = SD1.D1_SERIORI AND SF2.F2_PREFORI = '"+Getmv("MV_PREFBAL")+"' AND SF2.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SD2")+" SD2 ON  SD2.D2_FILIAL      = '"+cFilSD2+"' AND SD2.D2_DOC     = SD1.D1_NFORI   AND SD2.D2_SERIE     = SD1.D1_SERIORI AND SD2.D2_COD     = SD1.D1_COD AND SD2.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SF4")+" SF4D2 ON  SF4D2.F4_FILIAL  = '"+cFilSF4+"' AND SF4D2.F4_CODIGO= SD2.D2_TES AND SF4D2.F4_ESTOQUE     <> 'N' AND SF4D2.F4_DUPLIC <> 'N' AND SF4D2.F4_OPEMOV = '05' AND SF4D2.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("VS1")+" VS1 ON  VS1.VS1_FILIAL = '"+cFilVS1+"' AND VS1.VS1_NUMNFI = SD2.D2_DOC     AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("VS3")+" VS3 ON  VS3.VS3_FILIAL = '"+cFilVS3+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.VS3_CODITE = SB1.B1_CODITE AND VS3.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("V09")+" V09 ON  V09.V09_FILIAL = '"+cFilV09+"' AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' ' "
cQuery += "WHERE SF1.F1_FILIAL = '"+cFilSF1+"' AND SF1.F1_DTDIGIT >= '"+Dtos(Mv_Par01)+"' AND SF1.F1_DTDIGIT <= '"+Dtos(Mv_Par02)+"' AND SF1.F1_TIPO = 'D' AND "
cQuery += "SF1.D_E_L_E_T_=' ' "

If Select(cSQLSF1) > 0
	(cSQLSF1)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSF1 , .F. , .T. )

While (cSQLSF1)->(!Eof())
	
	If !lAuto
		IncProc(STR0016) //Aguarde... Levantando as Devolucoes...
	Endif
	
	If lPE
		If !ExecBlock("OFA290DD",.f.,.f.,{"SF1"})
			(cSQLSF1)->(DbSkip())
			Loop
		Endif
	Endif
	
	cDataLog := DtoC(dDataBase)
	cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
	
	DbSelectArea("VES")
	DbSetOrder(1)
	If (cSQLSF1)->F2_HORA > "20:00"
		DbSeek(xFilial("VES")+(cSQLSF1)->B1_GRUPO+(cSQLSF1)->B1_CODITE+dTos( sTod( (cSQLSF1)->D1_DTDIGIT)+1 ))
		
	Else
		DbSeek(xFilial("VES")+(cSQLSF1)->B1_GRUPO+(cSQLSF1)->B1_CODITE+(cSQLSF1)->D1_DTDIGIT)
	Endif
	RecLock("VES",!Found())
	VES->VES_FILIAL := xFilial("VES")
	VES->VES_GRUITE := (cSQLSF1)->B1_GRUPO
	VES->VES_CODITE := (cSQLSF1)->B1_CODITE
	If (cSQLSF1)->F2_HORA > "20:00"
		VES->VES_DATDEM := sTod((cSQLSF1)->D1_DTDIGIT) + 1
		VES->VES_SEMANA := strzero(Int(((sTod((cSQLSF1)->D1_DTDIGIT)+1) - dIniDem) / 7 ) + 1,2)
	Else
		VES->VES_DATDEM := sTod((cSQLSF1)->D1_DTDIGIT)
		VES->VES_SEMANA := strzero(Int(( sTod((cSQLSF1)->D1_DTDIGIT) - dIniDem) / 7 ) + 1,2)
	Endif
	
	VES->VES_LOGDEM := cLog
	
	If (cSQLSF1)->V09_LEVDEM == "1"
		VES->VES_DEMBAL := VES->VES_DEMBAL - (cSQLSF1)->D1_QUANT
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Else
		VES->VES_DEMEXP := VES->VES_DEMEXP - (cSQLSF1)->D1_QUANT
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Endif
	
	MsUnLock()
	
	(cSQLSF1)->(DbSkip())
	
EndDo

If Select(cSQLSF1) > 0
	(cSQLSF1)->(DbCloseArea())
EndIf
//
DBSelectArea("VES")
// Levantamento das Vendas Perdidas
If !lAuto
	ProcRegua(RecCount())
Endif

cQuery := "SELECT SB1.* , VE6.* , VE7.*  "
cQuery += "FROM "+RetSQLName("VE6")+" VE6 "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL   = '"+cFilSB1+"' AND SB1.B1_GRUPO   = VE6.VE6_GRUITE AND SB1.B1_CODITE  = VE6.VE6_CODITE AND SB1.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("VE7")+" VE7 ON  VE7.VE7_FILIAL  = '"+cFilVE7+"' AND VE7.VE7_INDREG = VE6.VE6_INDREG AND VE7.VE7_CODMOT = VE6.VE6_CODMOT AND VE7.D_E_L_E_T_=' ' "
cQuery += "WHERE VE6.VE6_FILIAL = '"+cFilVE6+"' AND VE6.VE6_DATREG >= '"+Dtos(Mv_Par01)+"' AND VE6.VE6_DATREG <= '"+Dtos(Mv_Par02)+"' AND VE6.VE6_INDREG = '1' AND "
cQuery += "VE6.D_E_L_E_T_=' ' "

If Select(cSQLVE6) > 0
	(cSQLVE6)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVE6 , .F. , .T. )

While (cSQLVE6)->(!Eof())
	
	If !lAuto
		IncProc(STR0017) //Aguarde... Levantando as Vendas Perdidas...
	Endif
	
	If lPE
		If !ExecBlock("OFA290DD",.f.,.f.,{"VE6"})
			(cSQLVE6)->(DbSkip())
			Loop
		Endif
	Endif
	
	cDataLog := DtoC(dDataBase)
	cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
	DbSelectArea("VES")
	DbSetOrder(1)
	If  (cSQLVE6)->VE6_HORREG > "2000" // 20:00 horas
		DbSeek(xFilial("VES")+(cSQLVE6)->B1_GRUPO+(cSQLVE6)->B1_CODITE+DTOS( sTod((cSQLVE6)->VE6_DATREG )+1))
	Else
		DbSeek(xFilial("VES")+(cSQLVE6)->B1_GRUPO+(cSQLVE6)->B1_CODITE+(cSQLVE6)->VE6_DATREG)
	Endif
	RecLock("VES",!Found())
	VES->VES_FILIAL := xFilial("VES")
	VES->VES_GRUITE := (cSQLVE6)->B1_GRUPO
	VES->VES_CODITE := (cSQLVE6)->B1_CODITE
	If VE6->VE6_HORREG > "2000" // 20:00 horas
		VES->VES_DATDEM := sTod((cSQLVE6)->VE6_DATREG) + 1
		VES->VES_SEMANA := strzero(Int(((sTod((cSQLVE6)->VE6_DATREG)+1) - dIniDem) / 7 ) + 1,2)
	Else
		VES->VES_DATDEM := sTod((cSQLVE6)->VE6_DATREG)
		VES->VES_SEMANA := strzero(Int((sTod((cSQLVE6)->VE6_DATREG) - dIniDem) / 7 ) + 1,2)
	Endif
	
	VES->VES_LOGDEM := cLog
	
	If  (cSQLVE6)->VE7_INDMOT $ "1/0" // Considera na Demanda
		VES->VES_DEMVDP := VES->VES_DEMVDP + (cSQLVE6)->VE6_QTDITE
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Else
		VES->VES_DEMEXP := VES->VES_DEMEXP + (cSQLVE6)->VE6_QTDITE
		VES->VES_DEMTOT := VES->VES_DEMBAL + VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Endif
	
	MsUnLock()
	
	(cSQLVE6)->(DbSkip())
	
Enddo

If Select(cSQLVE6) > 0
	(cSQLVE6)->(DbCloseArea())
EndIf
//
DBSelectArea("VES")
// Levantamento das Requisicoes
If !lAuto
	ProcRegua(RecCount())
Endif

cQuery := "SELECT SB1.* , VO2.*  ,  VO3.* , V09.V09_LEVDEM , VO3.R_E_C_N_O_ VO3RECNO "
cQuery += "FROM "+RetSQLName("VO2")+" VO2 "
cQuery += "INNER JOIN "+RetSQLName("VO3")+" VO3 ON  VO3.VO3_FILIAL = '"+cFilVO3+"' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("V09")+" V09 ON  V09.V09_FILIAL = '"+cFilV09+"' AND V09.V09_CODSIT = VO3.VO3_CODSIT AND V09.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+cFilSB1+"' AND SB1.B1_GRUPO   = VO3.VO3_GRUITE AND SB1.B1_CODITE = VO3.VO3_CODITE AND SB1.D_E_L_E_T_ =' ' "
cQuery += "WHERE VO2.VO2_FILIAL = '"+cFilVO2+"' AND VO2.VO2_DATREQ >= '"+Dtos(Mv_Par01)+"' AND VO2.VO2_DATREQ <= '"+Dtos(Mv_Par02)+"' AND "
cQuery += "VO2.D_E_L_E_T_=' ' "

If Select(cSQLVO2) > 0
	(cSQLVO2)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVO2 , .F. , .T. )

While (cSQLVO2)->(!Eof())
	       
	If !lAuto
		IncProc(STR0018)  //Aguarde... Levantando as Requisicoes...
	Endif
	
	If (cSQLVO2)->VO3_CODSIT $ "03/06" // Escrape ou Recompra ou Pecas Scania Fora
		DbSelectArea(cSQLVO2)
		(cSQLVO2)->(DbSkip())
		Loop
	Endif
	
	If lPE
		If !ExecBlock("OFA290DD",.f.,.f.,{"VO2"})
			DbSelectArea(cSQLVO2)
			(cSQLVO2)->(DbSkip())
			Loop
		Endif
	Endif	
	
	cDataLog := DtoC(dDataBase)
	cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
	DbSelectArea("VES")
	DbSetOrder(1)
	If  Strzero((cSQLVO2)->VO2_HORREQ,4) > "2000" // 20:00 horas
		DbSeek(xFilial("VES")+(cSQLVO2)->B1_GRUPO+(cSQLVO2)->B1_CODITE+DTOS(sTod((cSQLVO2)->VO2_DATREQ)+1))
	Else
		DbSeek(xFilial("VES")+(cSQLVO2)->B1_GRUPO+(cSQLVO2)->B1_CODITE+(cSQLVO2)->VO2_DATREQ)
	Endif
	RecLock("VES",!Found())
	VES->VES_FILIAL := xFilial("VES")
	VES->VES_GRUITE := (cSQLVO2)->B1_GRUPO
	VES->VES_CODITE := (cSQLVO2)->B1_CODITE
	If Strzero((cSQLVO2)->VO2_HORREQ,4) > "2000" // 20:00 horas
		VES->VES_DATDEM := sTod((cSQLVO2)->VO2_DATREQ) + 1
		VES->VES_SEMANA := strzero(Int(((sTod((cSQLVO2)->VO2_DATREQ)+1) - dIniDem) / 7 ) + 1,2)
	Else
		VES->VES_DATDEM := sTod((cSQLVO2)->VO2_DATREQ)
		VES->VES_SEMANA := strzero(Int((sTod((cSQLVO2)->VO2_DATREQ) - dIniDem) / 7 ) + 1,2)
	Endif
	VES->VES_LOGDEM := cLog
	
	If  (cSQLVO2)->V09_LEVDEM == "1"
		If (cSQLVO2)->VO2_DEVOLU == "0"
			VES->VES_DEMOFI := VES->VES_DEMOFI - (cSQLVO2)->VO3_QTDREQ
		Else
			VES->VES_DEMOFI := VES->VES_DEMOFI + (cSQLVO2)->VO3_QTDREQ
		EndIf
		VES->VES_DEMTOT := VES->VES_DEMBAL+VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	Else
		If (cSQLVO2)->VO2_DEVOLU == "0"
			VES->VES_DEMEXP := VES->VES_DEMEXP - (cSQLVO2)->VO3_QTDREQ
		Else
			VES->VES_DEMEXP := VES->VES_DEMEXP + (cSQLVO2)->VO3_QTDREQ
		EndIf
		VES->VES_DEMTOT := VES->VES_DEMBAL+VES->VES_DEMOFI+VES->VES_DEMVDP+VES->VES_DEMEXP
	EndIf
	
	MsUnLock()
	
	DbSelectArea(cSQLVO2)
	(cSQLVO2)->(DbSkip())
	
Enddo

If Select(cSQLVO2) > 0
	(cSQLVO2)->(DbCloseArea())
EndIf
      
DBSelectArea("VES")
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CriTotDem³ Autor ³ Luis / Manoel Filho  ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que cria Totais da Demanda no VES (Demanda Diaria)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga Veiculos                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CriTotDem()
                 
Local cSQLVES  := "SQLVES" // utilizado dentro do Ponto de Entrada OFA310SD  quando o parametro for VO2

If !lAuto
	pergunte(cPerg,.t.)
Else
	Mv_Par01 := Mv_Par02 - 6 // 1o dia da Semana
Endif

// Deleta semana 88/99 do arquivo VES.
If TCCanOpen(RetSqlName("VES"))
	
	cQuery := "DELETE FROM " + RetSqlName( "VES" ) + " VES "
	cQuery += "WHERE VES.VES_FILIAL = '"+xFilial("VES")+"' AND VES.VES_SEMANA IN( '99', '88') "
	TCSqlExec(cQuery)
	
EndIf

dIniDem := Ctod("01/01/"+strzero(year(dDataBase)))-dow(Ctod("01/01/"+strzero(year(dDataBase))))//Ctod(GetMv("MV_PRSEDEM"))
dIniDem := dIniDem - 1
If Dow(Mv_Par02) != 5 // Caso nao seja Sexta-Feira, nao monta o Arquivo
	If !lAuto
		If !MsgYesNo(STR0019,STR0013)
			Return
		Endif
	Else
		Return
	Endif
Endif

cSemana := strzero(Int((Mv_Par02 - dIniDem) / 7 ) + 1,2)

&& Levanta dados para processamento
cQuery := " SELECT * FROM "+RetSQLName("VES")+" VES "
cQuery += " WHERE VES.VES_FILIAL = '"+xFilial("VES")+"' AND VES.VES_DATDEM >= '"+Dtos(Mv_Par01)+"' AND VES.VES_DATDEM <= '"+Dtos(Mv_Par02)+"' "
cQuery += "      AND VES.D_E_L_E_T_=' ' AND VES.VES_SEMANA NOT IN( '99', '88') "
cQuery += " ORDER BY VES.VES_FILIAL, VES.VES_GRUITE, VES.VES_CODITE, VES.VES_DATDEM "  

If Select(cSQLVES) > 0
	(cSQLVES)->(DbCloseArea())
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVES , .F. , .T. )

cGrupo   := VES->VES_GRUITE
cProduto := VES->VES_CODITE
nQtd     := 0
nQtdExp  := 0

If !lAuto
	ProcRegua(RecCount())
Endif
cSemDem := space(4)
                          
While (cSQLVES)->(!Eof())

	If !lAuto
		IncProc(STR0020) //Aguarde... Totalizando Quantidades...
	Endif
	
	// Acumula dados do produto anterior
	nQtd     := nQtd + ((cSQLVES)->VES_DEMBAL + (cSQLVES)->VES_DEMOFI + (cSQLVES)->VES_DEMVDP + (cSQLVES)->VES_DEMEXP)
	nQtdExp  := nQtdExp + ((cSQLVES)->VES_DEMEXP)
	
	cGrupo   := (cSQLVES)->VES_GRUITE
	cProduto := (cSQLVES)->VES_CODITE
	
	DbSelectArea(cSQLVES)
	DbSkip()
	
	// Se o produto atual for diferente do produto anterior grava dados do produto anterior
	If ( (cSQLVES)->(eof()) .Or. xFilial("VES")+cGrupo+cProduto != (cSQLVES)->VES_FILIAL+(cSQLVES)->VES_GRUITE+(cSQLVES)->VES_CODITE )
		
		cDataLog := DtoC(dDataBase)
		cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
		
		DbSelectArea("SBM")
		DbSetOrder(1)
		DbSeek(xFilial("SBM")+cGrupo)
		if SBM->BM_PROORI == "1"
			cSemDem := "99"
		else
			cSemDem := "88"
		endif    
		
		&& Para o registro 99/88 sera gravado o grupo em banco ja que ira totalizar todos os grupos do item
		DbSelectArea("VES")
		DbSetOrder(3)
		DbSeek(xFilial("VES")+cSemDem+Space(Len(cGrupo))+cProduto)
		RecLock("VES",!Found())
		VES_FILIAL := xFilial("VES")
		VES_GRUITE := Space(Len(cGrupo))
		VES_CODITE := cProduto
		VES_DATDEM := Mv_Par02
		VES_SEMANA := cSemDem
		VES_LOGDEM := cLog
		VES_DEMEXP := VES_DEMEXP + nQtdExp
		VES_DEMTOT := VES_DEMTOT + nQtd
		MsUnlock()
		
		cGrupo   := (cSQLVES)->VES_GRUITE
		cProduto := (cSQLVES)->VES_CODITE
		nQtd     := 0
		nQtdExp  := 0
		
	Endif
	
Enddo

(cSQLVES)->(DbCloseArea())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

local _sAlias := Alias()
local aRegs := {}
local i,j

dbSelectArea("SX1")
dbSetOrder(1)  
dbgotop()
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",STR0011,"","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02",STR0021,"","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return




// ESTA FUNCAO SERA CHAMADA APENAS UMA VEZ E SEU OBJETIVO E'
// GERAR TODAS AS SEMANAS DO PASSADO

Static Function FS_CriTot()
Local s := 0
cFilAtu  := xFilial("VES")

dDataDe1   := Ctod("28/12/02")
dDataDe2   := Ctod("03/01/03")
dDataAte   := Ctod("15/08/03")

nSemanas := Int((dDataAte - dIniDem) / 7 ) + 1

For s := 1 to nSemanas
	
	DbSelectArea("VES")
	DbSetOrder(3)
	DbSeek(xFilial("VES")+"88",.t.)
	While !eof() .and. VES->VES_SEMANA $ "88/99" .And. VES->VES_FILIAL == xFilial("VES")
		RecLock("VES",.f.)
		Delete
		MsUnlock()
		dbskip()
	Enddo
	
	DbSelectArea("VES")
	VES->(DbCloseArea())
	if ChkFile("VES",.T.)
		DbSelectArea("VES")
		pack
		VES->(DbCloseArea())
	Endif
	
	ChkFile("VES",.F.)
	
	cSemana := strzero(Int((dDataDe2 - dIniDem) / 7 ) + 1,2)
	
	DbSelectArea("VES")
	DbSetOrder(3)
	DbSeek(xFilial("VES")+cSemana)
	cGrupo   := VES->VES_GRUITE
	cProduto := VES->VES_CODITE
	nQtd     := 0
	nQtdExp  := 0
	
	If !lAuto
		ProcRegua(RecCount())
	Endif
	
	While !eof() .and. VES->VES_FILIAL+VES->VES_SEMANA == xFilial("VES")+cSemana
		
		If !lAuto
			IncProc(STR0020)  //Aguarde... Totalizando Quantidades...
		Endif
		
		If VES->VES_SEMANA+STRZERO(YEAR(VES->VES_DATDEM),4) != cSemana+STRZERO(YEAR(dDataDe2),4)
			If VES->VES_DATDEM < dIniDem
				DbSkip()
				Loop
			Endif
		Endif
		
		If cGrupo+cProduto != VES->VES_GRUITE+VES->VES_CODITE
			nSavRec := Recno()
			cDataLog := DtoC(dDataBase)
			cLog     := Subs(cUsuario,7,13)+Subs(cDataLog,1,2)+Subs(cDataLog,4,2)+Subs(cDataLog,7,2)+time()
			DbSelectArea("SBM")
			DbSetOrder(1)
			DbSeek(xFilial("SBM")+cGrupo)
			if SBM->BM_PROORI == "1"
				cSemDem := "99"
			else
				cSemDem := "88"
			endif
			DbSelectArea("VES")
			DbSetOrder(3)
			DbSeek(xFilial("VES")+"99"+cGrupo+cProduto)
			RecLock("VES",!Found())
			VES_FILIAL := xFilial("VES")
			VES_GRUITE := cGrupo
			VES_CODITE := cProduto
			VES_DATDEM := dDataDe2
			VES_SEMANA := "99"
			VES_LOGDEM := cLog
			VES_DEMEXP := nQtdExp
			VES_DEMTOT := nQtd
			MsUnlock()
			DbGoTo(nSavRec)
			cGrupo   := VES->VES_GRUITE
			cProduto := VES->VES_CODITE
			nQtd     := (VES->VES_DEMBAL + VES->VES_DEMOFI + VES->VES_DEMVDP + VES_DEMEXP)
			nQtdExp  := (VES_DEMEXP)
		Else
			nQtd     := nQtd + (VES->VES_DEMBAL + VES->VES_DEMOFI + VES->VES_DEMVDP + VES_DEMEXP)
			nQtdExp  := nQtdExp + (VES_DEMEXP)
		Endif
		
		DbSelectArea("VES")
		DbSkip()
		
	Enddo
	
	//OFIIA200(2,"SC ","006",".T."," ","09",cFilAtu)
	//OFIIA200(2,"SC ","008",".T."," ","09",cFilAtu)
	
	dDataDe1 := dDataDe1 + 7
	dDataDe2 := dDataDe2 + 7
	
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ZeraSem  ³ Autor ³ Manoel Filho         ³ Data ³ 09/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera registros da semana a ser rodada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga Veiculos                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ZeraSem()

DbSelectArea("VES")
DbSetOrder(2)
DbSeek(xFilial("VES")+DTOS(Mv_Par01),.t.)

while !eof() .and. VES->VES_FILIAL == xFilial("VES") .and. ;
	VES->VES_DATDEM >= Mv_Par01 .and. VES->VES_DATDEM <= Mv_Par02
	
	RecLock("VES",.f.)
	VES_DEMBAL := 0
	VES_DEMOFI := 0
	VES_DEMVDP := 0
	VES_DEMEXP := 0
	VES_DEMTOT := 0
	MsUnLock()
	
	DbSkip()
	
Enddo

Return

//////////////////////////////////
Function F_NOMDEM(cPar)
dIniDem := Ctod("01/01/"+strzero(year(dDataBase)))-dow(Ctod("01/01/"+strzero(year(dDataBase))))//Ctod(GetMv("MV_PRSEDEM"))
Return("D"+cPar+"S"+subs(DTos(AITEM[1,4]),3,2)+STRZERO(INT((AITEM[1,4]-dIniDem) / 7 ) + 1,2)+".EXP" )

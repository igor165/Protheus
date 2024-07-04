// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIOC510.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC510³ Autor  ³ Thiago    			³ Data ³15/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Meta de Venda.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC510()
Local cQuery       := ""
Local cQAlSF2      := "SQLSF2"
Local cTitulo      := STR0001 // Consulta Meta de Venda
Local aSizeAut	   := MsAdvSize(.t.)
Local aObjects     := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Private cPrefixo   := space(TamSX3("VER_PREFIX")[1])
Private M->VER_AGRUPA  := space(TamSX3("VER_AGRUPA")[1])
Private cTipoNF    := ""
Private cMesIni    := strzero(month(dDataBase),2)
Private cAnoIni    := strzero(year(dDataBase),4)
Private cMesFin    := strzero(month(dDataBase),2)
Private cAnoFin    := strzero(year(dDataBase),4)
Private cFili      := " "
Private cVend      := space(TamSX3("VER_CODVEN")[1])
Private cMarc      := space(TamSX3("VER_CODMAR")[1])
Private cModVei    := space(TamSX3("VER_MODVEI")[1])
Private cDevolu    := " "
Private lAutom     := .f.
Private aPrefixo   := X3CBOXAVET("VER_PREFIX","1")
Private aDevolu    := {"1="+STR0027,"2="+STR0028,"3="+STR0029} // Não deduzir / Do período / Referente às Vendas
Private aAgr       := {{"","",0,{},0,0,0,0}}
Private aMet       := {{"","",0,0,"","","","",0,0,0,0}}
Private aNF        := {}
Private aFilSF2    := {}
Private cFilSF2    := "("
//
aAdd(aFilSF2, " " )
cQuery := "SELECT DISTINCT F2_FILIAL FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlSF2, .T., .T. )
Do While !( cQAlSF2 )->( Eof() )
	aAdd(aFilSF2, ( cQAlSF2 )->( F2_FILIAL ) )
	cFilSF2 += "'"+( cQAlSF2 )->( F2_FILIAL )+"',"
	( cQAlSF2 )->( DbSkip() )
EndDo
( cQAlSF2 )->( dbCloseArea() )
cFilSF2 := left(cFilSF2,len(cFilSF2)-1)+")"
//
DbSelectArea("VER")
//
AAdd( aObjects, { 0 , 030 , .T. , .F. } ) // Cabecalho
AAdd( aObjects, { 0 , 015 , .T. , .F. } ) // Observacao
AAdd( aObjects, { 0 , 000 , .T. , .T. } ) // List box superior
AAdd( aObjects, { 0 , 000 , .T. , .T. } ) // List box inferior
//
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//
DEFINE MSDIALOG oDlgMetas TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0002 OF oDlgMetas PIXEL // Filtros
@ aPosObj[1,1]+006,aPosObj[1,2]+005 SAY STR0003 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Prefixo
@ aPosObj[1,1]+013,aPosObj[1,2]+005 MSCOMBOBOX oPrefixo VAR cPrefixo SIZE 62,08 COLOR CLR_BLACK ITEMS aPrefixo ON CHANGE FS_FILTRAR(0) OF oDlgMetas PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+070 SAY STR0004 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Agrupador
@ aPosObj[1,1]+013,aPosObj[1,2]+070 MSGET oCodAgr VAR M->VER_AGRUPA PICTURE "@!" F3 "VX5" SIZE 45,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+118 SAY (STR0031+" "+STR0005+"/"+STR0006) SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // de / Mês / Ano
@ aPosObj[1,1]+013,aPosObj[1,2]+118 MSGET oMesIni VAR cMesIni VALID ( cMesIni >= "01" .and. cMesIni <= "12" ) PICTURE "@!" SIZE 15,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE
@ aPosObj[1,1]+013,aPosObj[1,2]+134 MSGET oAnoIni VAR cAnoIni VALID ( cAnoIni >= "1950" .and. cAnoIni <= "2200" ) PICTURE "@!" SIZE 20,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+161 SAY (STR0032+" "+STR0005+"/"+STR0006) SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // ate / Mês / Ano
@ aPosObj[1,1]+013,aPosObj[1,2]+161 MSGET oMesFin VAR cMesFin VALID ( cMesFin >= "01" .and. cMesFin <= "12" ) PICTURE "@!" SIZE 15,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE
@ aPosObj[1,1]+013,aPosObj[1,2]+177 MSGET oAnoFin VAR cAnoFin VALID ( cAnoFin >= "1950" .and. cAnoFin <= "2200" ) PICTURE "@!" SIZE 20,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+204 SAY STR0007 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Filial Meta
@ aPosObj[1,1]+013,aPosObj[1,2]+204 MSCOMBOBOX oFilial VAR cFili SIZE 60,08 COLOR CLR_BLACK ITEMS aFilSF2 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+267 SAY STR0008 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Vendedor
@ aPosObj[1,1]+013,aPosObj[1,2]+267 MSGET oVend VAR cVend PICTURE "@!" F3 "SA3" SIZE 35,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+305 SAY STR0009 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Marca
@ aPosObj[1,1]+013,aPosObj[1,2]+305 MSGET oMarc VAR cMarc PICTURE "@!" F3 "VE1" SIZE 25,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+337 SAY STR0010 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Modelo
@ aPosObj[1,1]+013,aPosObj[1,2]+337 MSGET oModVei VAR cModVei PICTURE "@!" F3 "VX3" SIZE 80,08 OF oDlgMetas When !Empty(cPrefixo) PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+006,aPosObj[1,2]+420 SAY STR0030 SIZE 60,08 OF oDlgMetas PIXEL COLOR CLR_BLUE // Devoluções
@ aPosObj[1,1]+013,aPosObj[1,2]+420 MSCOMBOBOX oDevol VAR cDevolu SIZE 80,08 COLOR CLR_BLACK ITEMS aDevolu OF oDlgMetas PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+013,aPosObj[1,4]-058 BUTTON oFiltra PROMPT STR0011 OF oDlgMetas SIZE 50,10 PIXEL ACTION (FS_FILTRAR(1)) When !Empty(cPrefixo) // << FILTRAR >>
@ aPosObj[2,1]+003,aPosObj[2,4]-058 BUTTON oImprim PROMPT STR0014 OF oDlgMetas SIZE 50,10 PIXEL ACTION (FS_IMPRIMIR(oAgr:nAt)) When !Empty(cPrefixo) // << IMPRIMIR >>

@ aPosObj[2,1]+004,aPosObj[2,2]+005 SAY STR0025 SIZE 280,08 OF oDlgMetas PIXEL COLOR CLR_RED // Para visualizar o valor do Realizado é necessário clicar sobre a linha do Agrupador
@ aPosObj[2,1]+004,aPosObj[2,2]+289 CHECKBOX oAutom VAR lAutom PROMPT STR0026 OF oDlgMetas ON CLICK IIf(!Empty(cPrefixo),FS_FILTRAR(1),.t.) SIZE 100,08 PIXEL // Visualizar automaticamente

@ aPosObj[3,1],aPosObj[3,2] LISTBOX oAgr FIELDS HEADER STR0004,STR0012,STR0013,STR0022,STR0015,STR0019,STR0016; // Agrupador / Descrição / Meta / Realizado / Meta x Realizado / Ponto Equilibrio / PEqu x Realizado
	COLSIZES 50,255,50,50,50,60,50 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[3,1] OF oDlgMetas PIXEL;
	ON CHANGE IIf(lAutom.and.!Empty(cPrefixo),FS_LEVVDA(aAgr[oAgr:nAt,4],oAgr:nAt),(aMet:={},FS_REFRESH("aMet",1,.t.))) ON DBLCLICK FS_LEVVDA(aAgr[oAgr:nAt,4],oAgr:nAt)
FS_REFRESH("aAgr",0,.f.)

@ aPosObj[4,1],aPosObj[4,2] LISTBOX oMet FIELDS HEADER STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0013,STR0022,STR0015,STR0019,STR0016; // Mês / Ano / Filial Meta / Vendedor / Marca / Modelo / Meta / Realizado / Meta x Realizado / Ponto Equilibrio / PEqu x Realizado
	COLSIZES 20,25,50,95,20,95,50,50,50,60,50 SIZE aPosObj[4,4]-2,aPosObj[4,3]-aPosObj[4,1] OF oDlgMetas PIXEL ON DBLCLICK FS_NOTAS(oMet:nAt)
FS_REFRESH("aMet",0,.f.)

ACTIVATE MSDIALOG oDlgMetas ON INIT EnchoiceBar(oDlgMetas,{|| oDlgMetas:End() },{|| oDlgMetas:End() })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRAR  ³ Autor  ³ Thiago         ³ Data ³ 15/07/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra as metas de vendas.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp)
Local cQuery    := ""
Local cAliasVER := "SQLVER"
Local ni        := 0
Local nj        := 0
Local nAux      := 0
Local aMesAno   := {}
//
For ni := val(cMesIni) to 12
	If cAnoIni <> cAnoFin .or. ni <= val(cMesFin)
		aAdd(aMesAno,strzero(ni,2)+cAnoIni)
	EndIf
Next
nAux := val(cAnoFin)-val(cAnoIni)
If nAux > 1 // Ano Inteiro
	For ni := 1 to (nAux-1)
		For nj := 1 to 12
			aAdd(aMesAno,strzero(nj,2)+strzero(val(cAnoIni)+ni,4))
		Next
	Next
EndIf
If nAux > 0 // Ultimo Ano
	For ni := 1 to val(cMesFin)
		If cAnoIni <> cAnoFin .or. ni >= val(cMesIni)
			aAdd(aMesAno,strzero(ni,2)+cAnoFin)
		EndIf
	Next
EndIf
//
aAgr := {}
aMet := {}
aNF  := {}
If nTp > 0
	cQuery := "SELECT VER.R_E_C_N_O_ RECNOVER , VER.VER_ANO , VER.VER_MES , VER.VER_VALOR , VER.VER_PE , VER.VER_AGRUPA , VX5.VX5_DESCRI "
	cQuery += "FROM "+RetSqlName("VER")+" VER "
	cQuery += "JOIN "+RetSqlName("VX5")+" VX5 ON (VX5.VX5_FILIAL='"+xFilial("VX5")+"' AND VX5.VX5_CHAVE='035' AND VX5.VX5_CODIGO=VER.VER_AGRUPA AND VX5.D_E_L_E_T_=' ') "
	cQuery += "WHERE "
	cQuery += "VER.VER_FILIAL='"+ xFilial("VER")+ "' "
	if !Empty(cPrefixo)
		cQuery += "AND VER.VER_PREFIX = '"+cPrefixo+"' "
	Endif
	if !Empty(M->VER_AGRUPA)
		cQuery += "AND VER.VER_AGRUPA = '"+M->VER_AGRUPA+"' "
	Endif
	cQuery += "AND VER.VER_ANO >= '"+cAnoIni+"' AND VER.VER_ANO <= '"+cAnoFin+"' "
	if !Empty(cFili)
		cQuery += "AND VER.VER_CODFIL = '"+cFili+"' "
	Endif
	if !Empty(cVend)
		cQuery += "AND VER.VER_CODVEN = '"+cVend+"' "
	Endif
	if !Empty(cMarc)
		cQuery += "AND VER.VER_CODMAR = '"+cMarc+"' "
	Endif
	if !Empty(cModVei)
		cQuery += "AND VER.VER_MODVEI = '"+cModVei+"' "
	Endif
	cQuery += "AND VER.D_E_L_E_T_=' ' ORDER BY VER.VER_MES , VER.VER_ANO , VER.VER_CODFIL , VER.VER_CODVEN , VER.VER_CODMAR , VER.VER_MODVEI "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVER, .T., .T. )
	Do While !( cAliasVER )->( Eof() )
		If ascan(aMesAno,( cAliasVER )->VER_MES+( cAliasVER )->VER_ANO) > 0
			nPos := Ascan(aAgr,{ |x| x[1] == ( cAliasVER )->VER_AGRUPA })
			if nPos == 0
				Aadd(aAgr,{( cAliasVER )->VER_AGRUPA,left(( cAliasVER )->VX5_DESCRI,70),0,{},0,0,0,0})
				nPos := len(aAgr)
			EndIf
			aAgr[nPos,3] += (cAliasVER )->VER_VALOR
			aAgr[nPos,6] += ( cAliasVER )->VER_VALOR*(( cAliasVER )->VER_PE/100)
			Aadd(aAgr[nPos,4],(cAliasVER )->RECNOVER)
		EndIf
		( cAliasVER )->(dbSkip())
	Enddo
	( cAliasVER )->( dbCloseArea() )
	If lAutom .and. len(aAgr) > 0
		For ni := 2 to len(aAgr)
			FS_LEVVDA(aAgr[ni,4],ni)
		Next
		FS_LEVVDA(aAgr[1,4],1)
	EndIf
EndIf
FS_REFRESH("aAgr",1,.t.)
FS_REFRESH("aMet",1,.t.)
//
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_LEVVDA º Autor ³ Andre Luis Almeida º Data ³ 15/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Levanta as vendas referentes as metas de vendas            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVVDA(aVetorVER,nLinha)
Local nCont      := 0
Local nTot       := 0
Local cQuery     := ""
Local cNamSD2     := RetSQLName("SD2")
Local cNamSF2     := RetSQLName("SF2")
Local cNamSD1     := RetSQLName("SD1")
Local cNamSF4     := RetSQLName("SF4")
Local cQAlSF2    := "SQLSF2"
Local cSQLSD1    := "SQLSD1"
Local cSQLSD1Dev := "SQLSD1"
Local cPrefVEI   := GetNewPar("MV_PREFVEI","VEI")
Local cPrefBAL   := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOFI   := GetNewPar("MV_PREFOFI","OFI")
Local cFilSF4    := xFilial("SF4")
Local cFilSA1    := xFilial("SA1")
Local cFilSA3    := xFilial("SA3")
Local cFilSD1    := xFilial("SD1")
Local nSomTotD2  := 0
Local nPonEqui   := 0
Local i          := 0

aNF  := {}
aMet := {}
aAgr[nLinha,5] := 0
aAgr[nLinha,6] := 0
aAgr[nLinha,7] := 0
aAgr[nLinha,8] := 0

//
For nCont := 1 to len(aVetorVER)
	//
	nSomTotD2 := 0
	//
	VER->(DbGoTo(aVetorVER[nCont]))
	//
	cQuery := "SELECT SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_DOC , SF2.F2_SERIE , SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_PREFORI , SF2.F2_EMISSAO , SF2.F2_VALBRUT , SF2.F2_COND , SF2.F2_VEND1 , SD2.D2_TOTAL , SD2.D2_LOCAL , SF4.F4_ESTOQUE , SA1.A1_NOME , SA3.A3_NOME "
	cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
	cQuery += "JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_CLIENTE=SF2.F2_CLIENTE AND SD2.D2_LOJA=SF2.F2_LOJA AND SD2.D2_TIPO='N' AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL='"+cFilSF4+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_DUPLIC='S' AND SF4.F4_ATUATF<>'S' AND SF4.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+cFilSA3+"' AND SA3.A3_COD=SF2.F2_VEND1 AND SA3.D_E_L_E_T_=' ' ) "
	If VER->VER_PREFIX == "VEN" // Novo ou Fat.Direto
		cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=SF2.F2_FILIAL AND VV0.VV0_NUMNFI=SF2.F2_DOC AND VV0.VV0_SERNFI=SF2.F2_SERIE AND VV0.VV0_TIPFAT<>'1' AND VV0.D_E_L_E_T_=' ' ) "
	ElseIf VER->VER_PREFIX == "VEU" // Usado
		cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=SF2.F2_FILIAL AND VV0.VV0_NUMNFI=SF2.F2_DOC AND VV0.VV0_SERNFI=SF2.F2_SERIE AND VV0.VV0_TIPFAT='1' AND VV0.D_E_L_E_T_=' ' ) "
	EndIf
	cQuery += "WHERE "
	If !Empty(VER->VER_CODFIL)
		cQuery += "SF2.F2_FILIAL='"+VER->VER_CODFIL+"' AND "
	Else
		cQuery += "SF2.F2_FILIAL IN "+cFilSF2+" AND "
	EndIf
	cQuery += "left(SF2.F2_EMISSAO,6)='"+VER->VER_ANO+VER->VER_MES+"' AND "
	If !Empty(VER->VER_CODVEN)
		cQuery += "SF2.F2_VEND1='"+VER->VER_CODVEN+"' AND "
	EndIf
	Do Case
		Case VER->VER_PREFIX $ "VEI/VEN/VEU"
			cQuery += "SF2.F2_PREFORI='"+cPrefVEI+"' AND "
			cQuery += "SF4.F4_ESTOQUE='S' AND "
		Case VER->VER_PREFIX == "BAL"
			cQuery += "SF2.F2_PREFORI='"+cPrefBAL+"' AND "
			cQuery += "SF4.F4_ESTOQUE='S' AND "
		Case VER->VER_PREFIX $ "OFI/PCO/SRV"
			cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
			If VER->VER_PREFIX == "PCO"
				cQuery += "SF4.F4_ESTOQUE='S' AND "
			EndIf
		Case VER->VER_PREFIX == "PEC"
			cQuery += "( SF2.F2_PREFORI='"+cPrefBAL+"' OR SF2.F2_PREFORI='"+cPrefOFI+"' ) AND "
			cQuery += "SF4.F4_ESTOQUE='S' AND "
		Case VER->VER_PREFIX == "EMP"
			cQuery += "( ( SF2.F2_PREFORI='"+cPrefVEI+"' AND SF4.F4_ESTOQUE='S' ) OR ( SF2.F2_PREFORI='"+cPrefBAL+"' AND SF4.F4_ESTOQUE='S' ) OR SF2.F2_PREFORI='"+cPrefOFI+"' ) AND "
	EndCase
	cQuery += "SF2.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF2 , .F., .T. )
	While !( cQAlSF2 )->( Eof() )
		
		nSomTotD2 += ( cQAlSF2 )->D2_TOTAL
		
		nPos := Ascan(aNF,{ |x| strzero(x[1],6)+x[2] == strzero(nCont,6)+( cQAlSF2 )->F2_DOC+"-"+ FGX_UFSNF( ( cQAlSF2 )->F2_SERIE ) })
		If nPos == 0
			Aadd(aNF,{nCont,( cQAlSF2 )->F2_DOC+"-"+ FGX_UFSNF( ( cQAlSF2 )->F2_SERIE ),( cQAlSF2 )->F2_CLIENTE+"-"+( cQAlSF2 )->F2_LOJA+" - "+( cQAlSF2 )->A1_NOME,Transform(stod(( cQAlSF2 )->F2_EMISSAO),"@D"),( cQAlSF2 )->F2_VEND1+" - "+( cQAlSF2 )->A3_NOME,( cQAlSF2 )->F2_VALBRUT} )
		EndIf
		( cQAlSF2 )->( DbSkip() )
	EndDo
	( cQAlSF2 )->( dbCloseArea() )
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VER->VER_CODVEN)
	dbSelectArea("VV2")
	dbSetOrder(1)
	dbSeek(xFilial("VV2")+VER->VER_CODMAR+VER->VER_MODVEI)
	nPonEqui := VER->VER_VALOR*(VER->VER_PE/100)
	//Devoluções de Venda (Deduz as devoluções das próprias vendas, quando houver)
	if cDevolu == "3"
		For i := 1 to Len(aNF)
			cQuery := "SELECT SD1.D1_TOTAL "
			cQuery += "FROM "+cNamSD1+" SD1 "
			cQuery += "JOIN "+cNamSF4+" SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_=' ' ) " // F4_OPEMOV='09' -> Devolucao
			cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_NFORI='"+left(aNF[i,2],TamSX3("F2_DOC")[1])+"' AND SD1.D1_SERIORI = '"+right(aNF[i,2],TamSX3("F2_SERIE")[1])+"' AND "
			cQuery += "SD1.D_E_L_E_T_=' ' "
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD1Dev, .F., .T. )
			While !(cSQLSD1Dev)->(Eof())
				
				nSomTotD2 -= (cSQLSD1Dev)->D1_TOTAL
				
				dbSelectArea(cSQLSD1Dev)
				(cSQLSD1Dev)->(dbSkip())
			Enddo
			(cSQLSD1Dev)->(dbCloseArea())
			
		Next
	//Devoluções de Venda do período
	Elseif cDevolu == "2"
		cQuery := "SELECT SD1.D1_TOTAL "
		cQuery += "FROM "+cNamSD1+" SD1 "
		cQuery += "JOIN "+cNamSF2+" SF2 ON "
		cQuery += "( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI AND SF2.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+cNamSD2+" SD2 ON "
		cQuery += "( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_COD=SD1.D1_COD AND SD2.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+cNamSF4+" SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_=' ' ) " // F4_OPEMOV='09' -> Devolucao
		If VER->VER_PREFIX == "VEN" // Novo ou Fat.Direto
			cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=SF2.F2_FILIAL AND VV0.VV0_NUMNFI=SF2.F2_DOC AND VV0.VV0_SERNFI=SF2.F2_SERIE AND VV0.VV0_TIPFAT<>'1' AND VV0.D_E_L_E_T_=' ' ) "
		ElseIf VER->VER_PREFIX == "VEU" // Usado
			cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=SF2.F2_FILIAL AND VV0.VV0_NUMNFI=SF2.F2_DOC AND VV0.VV0_SERNFI=SF2.F2_SERIE AND VV0.VV0_TIPFAT='1' AND VV0.D_E_L_E_T_=' ' ) "
		EndIf
		cQuery += "WHERE "
		If !Empty(VER->VER_CODVEN)
			cQuery += "SF2.F2_VEND1='"+VER->VER_CODVEN+"' AND "
		EndIf
		Do Case
			Case VER->VER_PREFIX $ "VEI/VEN/VEU"
				cQuery += "SF2.F2_PREFORI='"+cPrefVEI+"' AND "
			Case VER->VER_PREFIX == "BAL"
				cQuery += "SF2.F2_PREFORI='"+cPrefBAL+"' AND "
			Case VER->VER_PREFIX $ "OFI/PCO/SRV"
				cQuery += "SF2.F2_PREFORI='"+cPrefOFI+"' AND "
			Case VER->VER_PREFIX == "PEC"
				cQuery += "( SF2.F2_PREFORI='"+cPrefBAL+"' OR SF2.F2_PREFORI='"+cPrefOFI+"' ) AND "
			Case VER->VER_PREFIX == "EMP"
				cQuery += "( ( SF2.F2_PREFORI='"+cPrefVEI+"' ) OR ( SF2.F2_PREFORI='"+cPrefBAL+"' ) OR SF2.F2_PREFORI='"+cPrefOFI+"' ) AND "
		EndCase
		cQuery += "SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery += "Left(SD1.D1_DTDIGIT,6)='"+VER->VER_ANO+VER->VER_MES+"' AND "
		cQuery += "SD1.D_E_L_E_T_=' ' "
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD1, .F., .T. )
		While !(cSQLSD1)->(Eof())
			
			nSomTotD2 -= ( cSQLSD1 )->D1_TOTAL
			
			dbSelectArea(cSQLSD1)
			(cSQLSD1)->(dbSkip())
		Enddo
		(cSQLSD1)->(dbCloseArea())
	Endif
	Aadd(aMet, {VER->VER_MES,VER->VER_ANO,VER->VER_QTDVEI,VER->VER_VALOR,VER->VER_CODFIL,VER->VER_CODVEN+" - "+substr(SA3->A3_NOME,1,20),VER->VER_CODMAR,substr(VER->VER_MODVEI,1,15)+" - "+substr(VV2->VV2_DESMOD,1,20),nSomTotD2,nPonEqui,0,0 } )
	nPos := Ascan(aAgr,{ |x| x[1] == VER->VER_AGRUPA })
	if nPos > 0
		aAgr[nPos,5] += nSomTotD2
		aAgr[nPos,6] += nPonEqui
	Endif
Next
For nCont := 1 to Len(aAgr)
	aAgr[nCont,07] := ((aAgr[nCont,05]/aAgr[nCont,03])*100)
	aAgr[nCont,08] := ((aAgr[nCont,05]/aAgr[nCont,06])*100)
Next
For nCont := 1 to Len(aMet)
	aMet[nCont,11] := ((aMet[nCont,09]/aMet[nCont,04])*100)
	aMet[nCont,12] := ((aMet[nCont,09]/aMet[nCont,10])*100)
Next
FS_REFRESH("aAgr",0,.t.)
FS_REFRESH("aMet",1,.t.)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_NOTAS  º Autor ³ Thiago			  º Data ³ 23/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualizar notas fiscais de vendas						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NOTAS(nLinhaVER)
Local ni     := 0
Local aNFVer := {}
For ni := 1 to len(aNF)
	If aNF[ni,1] == nLinhaVER
		aAdd(aNFVer,aClone(aNF[ni]))
	EndIf
Next
If len(aNFVer) > 0
	DEFINE MSDIALOG oDlgNF TITLE STR0024 FROM  08,10 TO 30,120 OF oMainWnd // NFs referente as Metas de Vendas
	@ 001,001 LISTBOX oNF FIELDS HEADER STR0023,STR0021,STR0020,STR0008,STR0018 COLSIZES 50,100,40,100,50 SIZE 433,145 OF oDlgNF PIXEL ON DBLCLICK FS_CONSNF(aNFVer[oNF:nAt,2]) // Nro.NF / Cliente / Emissão / Vendedor / Impressão das Metas de Vendas
	oNF:SetArray(aNFVer)
	oNF:bLine := { || {	aNFVer[oNF:nAt,2],aNFVer[oNF:nAt,3],aNFVer[oNF:nAt,4],	aNFVer[oNF:nAt,5],FG_AlinVlrs(transform(aNFVer[oNF:nAt,6],"@E 999,999.99"))}}
	ACTIVATE MSDIALOG oDlgNF CENTER ON INIT EnchoiceBar(oDlgNF,{|| oDlgNF:End() },{|| oDlgNF:End() })
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor  ³ Andre Luis Almeida    ³ Data ³12/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao das Metas de Vendas                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR(nLinAgr)
Local lCabMet := .t.
Local ni := 0
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "G"
Private limite := 220
Private cString:= "VER"
Private titulo := STR0017 // Impressão das Metas de Vendas
Private cabec1 := ""
Private cabec2 := ""
Private aReturn:= {"",1,"",1,2,1,"",1}
Private nomeprog:= "OFIOC510"
Private nLastKey:= 0
If Empty(aMet[1,1])
	Return()
EndIf
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer

cabec1 := left(STR0003+": "+cPrefixo+space(25),25)+; // Prefixo
left(STR0004+": "+M->VER_AGRUPA+space(32),32)+; // Agrupador
left(cMesIni+"/"+cAnoIni+" "+STR0032+" "+cMesFin+"/"+cAnoFin+space(25),25)+; // ate
left(STR0007+": "+cFili+space(30),30)+; // Filial Meta
left(STR0008+": "+cVend+space(30),30)+; // Vendedor
left(STR0009+": "+cMarc+space(15),15)+; // Marca
STR0010+": "+cModVei // Modelo

nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1

@ nLin++, 00 PSAY left(STR0004+space(15),15)+" "+; // Agrupador
left(STR0012+space(95),95)+" "+; // Descrição
right(space(18)+STR0013,18)+" "+; // Meta
right(space(18)+STR0022,18)+" "+; // Realizado
right(space(20)+STR0015,20)+" "+; // Meta x Realizado
right(space(25)+STR0019,25)+" "+; // Ponto Equilibrio
right(space(20)+STR0016,20) // PEqu x Realizado
@ nLin++, 00 PSAY left(aAgr[nLinAgr,01]+space(15),15)+" "+;
left(aAgr[nLinAgr,02]+space(95),95)+" "+;
transform(aAgr[nLinAgr,3],"@E 999,999,999,999.99")+" "+;
transform(aAgr[nLinAgr,5],"@E 999,999,999,999.99")+" "+;
transform(aAgr[nLinAgr,7],"@E 9999,999,999,999.99")+"%"+" "+;
transform(aAgr[nLinAgr,6],"@E 999,999,999.99")+transform((aAgr[nLinAgr,6]/aAgr[nLinAgr,3])*100,"@E 999,999.99")+"%"+" "+;
transform(aAgr[nLinAgr,8],"@E 9999,999,999,999.99")+"%"
nLin++
For ni := 1 to len(aMet)
	If nLin >= 60
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		lCabMet := .t.
	EndIf
	If lCabMet
		@ nLin++, 00 PSAY left(STR0005+space(3),3)+" "+; // Mês
		left(STR0006+space(5),5)+" "+; // Ano
		left(STR0007+space(15),15)+" "+; // Filial Meta
		left(STR0008+space(25),25)+" "+; // Vendedor
		left(STR0009+space(7),7)+" "+; // Marca
		left(STR0010+space(51),51)+" "+; // Modelo
		right(space(18)+STR0013,18)+" "+; // Meta
		right(space(18)+STR0022,18)+" "+; // Realizado
		right(space(20)+STR0015,20)+" "+; // Meta x Realizado
		right(space(25)+STR0019,25)+" "+; // Ponto Equilibrio
		right(space(20)+STR0016,20) // PEqu x Realizado
		lCabMet := .f.
	EndIf
	@ nLin++, 00 PSAY left(aMet[ni,1]+space(3),3)+" "+;
	left(aMet[ni,2]+space(5),5)+" "+;
	left(aMet[ni,5]+space(15),15)+" "+;
	left(aMet[ni,6]+space(25),25)+" "+;
	left(aMet[ni,7]+space(7),7)+" "+;
	left(aMet[ni,8]+space(51),51)+" "+;
	transform(aMet[ni,4],"@E 999,999,999,999.99")+" "+;
	transform(aMet[ni,9],"@E 999,999,999,999.99")+" "+;
	transform(aMet[ni,11],"@E 9999,999,999,999.99")+"%"+" "+;
	transform(aMet[ni,10],"@E 999,999,999.99")+transform((aMet[ni,10]/aMet[ni,4])*100,"@E 999,999.99")+"%"+" "+;
	transform(aMet[ni,12],"@E 9999,999,999,999.99")+"%"
Next

Set Filter To
Set Device to Screen
If aReturn[5] = 1
	OurSpool(nomeprog)
Endif

MS_FLUSH()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_REFRESH³ Autor  ³ Andre Luis Almeida    ³ Data ³08/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ SetArray e Refresh nos ListBox da Tela                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRESH(cVet,nLinAt,lRefresh)
If cVet == "aAgr" // Agrupador
	If len(aAgr) <= 0
		aAgr := {{"","",0,{},0,0,0,0}}
	EndIf
	If nLinAt <> 0
		oAgr:nAt := nLinAt
	EndIf
	oAgr:SetArray(aAgr)
	oAgr:bLine := { || {aAgr[oAgr:nAt,1],;
	aAgr[oAgr:nAt,2] ,;
	FG_AlinVlrs(transform(aAgr[oAgr:nAt,3],"@E 99,999,999.99")),;
	FG_AlinVlrs(transform(aAgr[oAgr:nAt,5],"@E 99,999,999.99")),;
	FG_AlinVlrs(transform(aAgr[oAgr:nAt,7],"@E 999,999.99")+"%"),;
	FG_AlinVlrs(transform(aAgr[oAgr:nAt,6],"@E 99,999,999.99")+transform((aAgr[oAgr:nAt,6]/aAgr[oAgr:nAt,3])*100,"@E 999,999.99")+"%"),;
	FG_AlinVlrs(transform(aAgr[oAgr:nAt,8],"@E 999,999.99")+"%")}}
	If lRefresh
		oAgr:refresh()
	EndIf
ElseIf cVet == "aMet" // Metas
	If len(aMet) <= 0
		aMet := {{"","",0,0,"","","","",0,0,0,0}}
	EndIf
	If nLinAt <> 0
		oMet:nAt := nLinAt
	EndIf
	oMet:SetArray(aMet)
	oMet:bLine := { || {aMet[oMet:nAt,1] ,;
	aMet[oMet:nAt,2] ,;
	aMet[oMet:nAt,5],;
	aMet[oMet:nAt,6],;
	aMet[oMet:nAt,7],;
	aMet[oMet:nAt,8],;
	FG_AlinVlrs(transform(aMet[oMet:nAt,4],"@E 99,999,999.99")),;
	FG_AlinVlrs(transform(aMet[oMet:nAt,9],"@E 99,999,999.99")),;
	FG_AlinVlrs(transform(aMet[oMet:nAt,11],"@E 999,999.99")+"%"),;
	FG_AlinVlrs(transform(aMet[oMet:nAt,10],"@E 99,999,999.99")+transform((aMet[oMet:nAt,10]/aMet[oMet:nAt,4])*100,"@E 999,999.99")+"%"),;
	FG_AlinVlrs(transform(aMet[oMet:nAt,12],"@E 999,999.99")+"%")}}
	If lRefresh
		oMet:refresh()
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONSNF  ³ Autor  ³ Thiago    	     	  ³ Data ³15/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta nota fiscal.		                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONSNF(cNF)
Local nTamNro := TamSX3("F2_DOC")[1]
Local nTamSer := TamSX3("F2_SERIE")[1]
dbSelectArea("SF2")
dbSetOrder(1)
If dbSeek(xFilial("SF2")+substr(cNF,1,nTamNro)+substr(cNF,nTamNro+2,nTamSer))
	cTipoNF := "T"
	cAlias := "SF2"
	nReg   := SF2->(Recno())
	nOpc   := 2
	Mc090Visual(cAlias,nReg,nOpc)
EndIf
Return(.t.)

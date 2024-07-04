// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 35     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "VEIVC060.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVC060 ³ Autor ³  Manoel               ³ Data ³ 15/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Estoque de Veiculos                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIVC060
Local aArea := GetArea()
FS_VC060Imp()
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VC060Imp³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Relatorio.	                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VC060Imp()

SetPrvt("aDriver,cTitulo,cNomProg,cPerg,Limite,cCabec1,cCabec2,cNomeImp,lServer,cTamanho,m_Pag,nLin,cAlias,aReturn,cTipFat,aVetCampos")
nTotCUSCo := 0
DbSelectArea("SX1")
cPergSX1 := PADR("CONEST",Len(SX1->X1_GRUPO))

cTamanho := "G"        	// P/M/G
nCaracter:= 15
Limite   := 220        	// 80/132/220
aOrdem   := {}         	// Ordem do Relatorio
cTitulo  := STR0001		//"Estoque de Veiculos"
nLastKey := 0
aReturn  := { STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
cNomProg := "VEIVC060"
cNomeRel := "VEIVC060"
cPerg   := "CONEST"
aDriver := LeDriver()
cCompac := aDriver[1]
cNormal := aDriver[2]
cDrive   := "Epson.drv"
cNomeImp := "LPT1"
cAlias   := "VV1"
cCabec1  := STR0074
cCabec2  := ""
lHabil   := .f.
Inclui   := .f.
m_Pag    := 1

lc_depto  := GetNewpar("MV_DEPTO",.F.)  //.T.  faz a quebra na parte de remessa por deptos (pontos de venda)

/*
[1] Reservado para Formulario
[2] Reservado para nro de Vias
[3] Destinatario
[4] Formato => 1-Comprimido 2-Normal
[5] Midia   => 1-Disco 2-Impressora
[6] Porta ou Arquivo 1-LPT1... 4-COM1...
[7] Expressao do Filtro
[8] Ordem a ser selecionada
[9]..[10]..[n] Campos a Processar (se houver)
*/

ValidPerg()
cNomeRel := SetPrint(cAlias,cNomeRel,cPerg ,@cTitulo,"","","",.F.,"",.F.,cTamanho,nil    ,nil    ,nil)
If nLastKey == 27
	Return
Endif
Pergunte(cPerg,.F.)
SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| Imp_VEIVC060(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Imp_VEIVC060³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Relatorio.	                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imp_VEIVC060

Local cSQL, cAliasTMP := "TFILMOV", cHoraEnt, cHoraSai, cPoder3, cSGBD := Upper(TcGetDb())
Local cCHAINT := ""

Local aFilAtu   := FWArrFilAtu()
Local cFilBkp   := cFilAnt
Local nCont 	:= 0

Local cNamVV1   := RetSQLName("VV1")
Local cNamVVH   := RetSQLName("VVH")
Local cNamVVC   := RetSQLName("VVC")
Local cNamVV0   := RetSQLName("VV0")
Local cNamVVA   := RetSQLName("VVA")
Local cNamVVF   := RetSQLName("VVF")
Local cNamVVG   := RetSQLName("VVG")
Local cNamSF4   := RetSQLName("SF4")
Local cNamSA2   := RetSQLName("SA2")
Local cNamSA1   := RetSQLName("SA1")
Local cNamVVP   := RetSQLName("VVP")
Local cNamSB2   := RetSQLName("SB2")
Local cSitVei   := ""

Local cFilVV1   := ""
Local cFilVV2   := ""
Local cFilVVH   := ""
Local cFilVVC   := ""
Local cFilVV0   := ""
Local cFilVVF   := ""
Local cFilSF4   := ""
Local cFilSA2   := ""
Local cFilSA1   := ""
Local cFilVVP   := ""
Local cFilSB1   := ""
Local cFilSB2   := ""
Local cFornece  := ""

Local cVVFDTH   := Str(( 8 + 1 + TamSX3("VVF_DTHEMI")[1] ),2)
Local cVV0DTH   := Str(( 8 + 1 + TamSX3("VV0_DTHEMI")[1] ),2)

Private aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

&& Cria Arquivo de Trabalho
aVetCampos := {}
aadd(aVetCampos,{ "TRB_FILIAL" , "C" , FWSizeFilial()  , 0 })
aadd(aVetCampos,{ "TRB_FILENT" , "C" , FWSizeFilial()  , 0 })
aadd(aVetCampos,{ "TRB_TIPOVV" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_PROVVV" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_DIAEST" , "N" , 6  , 0 })
aadd(aVetCampos,{ "TRB_NUMNFI" , "C" , 9  , 0 })
aadd(aVetCampos,{ "TRB_DTDIGI" , "D" , 8  , 0 })
aadd(aVetCampos,{ "TRB_FORNEC" , "C" , 10  , 0 })
aadd(aVetCampos,{ "TRB_DATEMI" , "D" , 8  , 0 })
aadd(aVetCampos,{ "TRB_MODELO" , "C" , 24 , 0 })
aadd(aVetCampos,{ "TRB_MARMOD" , "C" , 25 , 0 })
aadd(aVetCampos,{ "TRB_CHASSI" , "C" , 25 , 0 })
aadd(aVetCampos,{ "TRB_CORVEI" , "C" , 10 , 2 })
aadd(aVetCampos,{ "TRB_VALNFI" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_ICMRET" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_PICRET" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_VALFRE" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_VALTAB" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_CODIND" , "C" , 2  , 0 })
aadd(aVetCampos,{ "TRB_DESIND" , "C" , 12 , 0 })
aadd(aVetCampos,{ "TRB_TIPFAT" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_CUSTOV" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_CUSATU" , "N" , 12 , 2 })
aadd(aVetCampos,{ "TRB_SITVEI" , "C" , 1  , 0 })
aadd(aVetCampos,{ "TRB_PLAVEI" , "C" , 10 , 0 })
aadd(aVetCampos,{ "TRB_ANOMOD" , "C" , 8  , 0 })
aadd(aVetCampos,{ "TRB_DEPTO " , "C" , 2  , 0 })
aadd(aVetCampos,{ "TRB_NFSAI " , "C" , 9  , 0 })
aadd(aVetCampos,{ "TRB_MODVEI" , "C" , 30 , 0 })
aadd(aVetCampos,{ "TRB_POSIPI" , "C" , 8 , 0 })
aadd(aVetCampos,{ "TRB_DISEIX" , "N" , 6 , 0 })

oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetCampos
If lc_depto
	oObjTempTable:AddIndex(, {"TRB_TIPOVV","TRB_SITVEI","TRB_PROVVV","TRB_DEPTO","TRB_MODELO","TRB_CORVEI","TRB_CHASSI"} )
Else
	oObjTempTable:AddIndex(, {"TRB_TIPOVV","TRB_SITVEI","TRB_PROVVV","TRB_MODELO","TRB_CORVEI","TRB_CHASSI"} )
EndIf
oObjTempTable:CreateTable()

dbSelectArea("VVF")
dbSetOrder(1)

dbSelectArea("VVG")
dbSetOrder(1)

dbSelectArea("VV1")
dbSetOrder(1)

dbSelectArea("VV2")
dbSetOrder(1)

dbSelectArea("VVH")
dbSetOrder(1)

If len(aSM0) > 0
	
	SetRegua(Len(aSM0))
	
	For nCont := 1 to Len(aSM0)
		
		IncRegua()
		
		cFilAnt := aSM0[nCont]
		
		If !(cFilAnt >= Mv_Par01 .and. cFilAnt <= Mv_Par02)
			loop
		Endif
		
		cFilVV1 := xFilial("VV1")
		cFilVV2 := xFilial("VV2")
		cFilVVH := xFilial("VVH")
		cFilVVC := xFilial("VVC")
		cFilVV0 := xFilial("VV0")
		cFilVVF := xFilial("VVF")
		cFilSF4 := xFilial("SF4")
		cFilSA2 := xFilial("SA2")
		cFilSA1 := xFilial("SA1")		
		cFilVVP := xFilial("VVP")
		cFilSB1 := xFilial("SB1")
		cFilSB2 := xFilial("SB2")
		
		cSQL := "SELECT CASE WHEN TENTRADA.CHAINT IS NOT NULL THEN TENTRADA.CHAINT"
		cSQL +=            " ELSE TSAIDA.CHAINT"
		cSQL +=        " END CHAINT,"
		cSQL +=        " TENTRADA.VVF_DATMOV, TENTRADA.VVF_OPEMOV, TENTRADA.VVF_TRACPA, TENTRADA.VVG_CODTES, TENTRADA.VVF_DTHEMI,"
		cSQL +=        " TSAIDA.VV0_DATMOV, TSAIDA.VV0_OPEMOV, TSAIDA.VV0_NUMTRA, TSAIDA.VVA_CODTES, TSAIDA.VV0_DTHEMI, TSAIDA.VV0_DEPTO, TSAIDA.VV0_NUMNFI"
		cSQL += " FROM ( SELECT TENTTMP.CHAINT, VVF2.VVF_DATMOV, VVF2.VVF_OPEMOV, VVF2.VVF_TRACPA, VVG2.VVG_CODTES, VVF2.VVF_DTHEMI, VVG2.VVG_ESTVEI"
		if "MSSQL" $ cSGBD
			cSQL += " FROM ( SELECT VVG_CHAINT CHAINT , MAX(VVF_DATMOV + VVF_DTHEMI + VVF_TRACPA) VVFTMP"
		else
			cSQL += " FROM ( SELECT VVG_CHAINT CHAINT , MAX(VVF_DATMOV || VVF_DTHEMI || VVF_TRACPA) VVFTMP"
		endif
		cSQL += " FROM "+cNamVVF+" VVF "
		cSQL += " JOIN "+cNamVVG+" VVG ON ( VVG_FILIAL=VVF_FILIAL AND VVG_TRACPA=VVF_TRACPA AND VVG.D_E_L_E_T_=' ' ) "
		cSQL += " JOIN "+cNamSF4+" F4 ON ( F4.F4_FILIAL='"+cFilSF4+"' AND F4.F4_CODIGO=VVG.VVG_CODTES AND "  // Somente TES que movimenta estoque
		if mv_par06 == 1
			cSQL += " F4.F4_ESTOQUE='S' AND "
		Elseif mv_par06 == 2
			cSQL += " F4.F4_ESTOQUE='N' AND "
		Endif	
		cSQL += " F4.D_E_L_E_T_=' ') "  
		if !Empty(MV_PAR03)
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVG_CHAINT AND VV1_CODMAR='"+MV_PAR03+"' "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) " 
		Elseif MV_PAR07 <> 3
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVG_CHAINT "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		endif
		cSQL +=                  " WHERE "
		cSQL +=                    " VVF_FILIAL = '"+cFilVVF+"' AND "
		cSQL +=                    " VVF_OPEMOV IN ('0','1','2','3','4','5','7','8') "
		cSQL +=                    " AND VVF_DATMOV <= '"+DtoS(mv_par04)+"'"
		cSQL +=                    " AND VVF_SITNFI <> '0'"
		cSQL +=                    " AND VVF.D_E_L_E_T_ = ' '"
		cSQL +=                  " GROUP BY VVG_CHAINT ) TENTTMP"
		cSQL +=                 " JOIN "+cNamVVF+" VVF2 ON VVF2.VVF_FILIAL = '"+cFilVVF+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                             " AND VVF2.VVF_TRACPA = SUBSTRING(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		else
			cSQL +=                             " AND VVF2.VVF_TRACPA = SUBSTR(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		endif
		cSQL +=                                 " AND VVF2.D_E_L_E_T_ = ' '"
		cSQL +=                 " JOIN "+cNamVVG+" VVG2 ON VVG2.VVG_FILIAL = '"+cFilVVF+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                             " AND VVG2.VVG_TRACPA = SUBSTRING(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		else
			cSQL +=                             " AND VVG2.VVG_TRACPA = SUBSTR(TENTTMP.VVFTMP,"+cVVFDTH+",10)"
		endif
		cSQL +=                                 " AND VVG2.VVG_CHAINT = TENTTMP.CHAINT "
		cSQL +=                                 " AND VVG2.D_E_L_E_T_ = ' '"
		cSQL +=        " ) TENTRADA"
		cSQL +=        " FULL JOIN"
		cSQL +=        " ( SELECT TSAITMP.CHAINT, VV02.VV0_DATMOV, VV02.VV0_OPEMOV, VV02.VV0_NUMTRA, VVA2.VVA_CODTES, VV02.VV0_DTHEMI, VV02.VV0_DEPTO, VV02.VV0_NUMNFI "
		if "MSSQL" $ cSGBD
			cSQL += " FROM ( SELECT VVA_CHAINT CHAINT, MAX(VV0_DATMOV + VV0_DTHEMI + VV0_NUMTRA) VV0TMP"
		else
			cSQL += " FROM ( SELECT VVA_CHAINT CHAINT, MAX(VV0_DATMOV || VV0_DTHEMI || VV0_NUMTRA) VV0TMP"
		endif
		cSQL += " FROM "+cNamVV0+" VV0 "
		cSQL += " JOIN "+cNamVVA+" VVA ON ( VVA_FILIAL=VV0_FILIAL AND VVA_NUMTRA=VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cSQL += " JOIN "+cNamSF4+" F4 ON ( F4.F4_FILIAL='"+cFilSF4+"' AND F4.F4_CODIGO=VVA.VVA_CODTES AND "  // Somente TES que movimenta estoque
		if mv_par06 == 1
			cSQL += " F4.F4_ESTOQUE='S' AND "
		Elseif mv_par06 == 2
			cSQL += " F4.F4_ESTOQUE='N' AND "
		Endif	                  
		cSQL += " F4.D_E_L_E_T_=' ') "  
		if !Empty(MV_PAR03)
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVA_CHAINT AND VV1_CODMAR='"+MV_PAR03+"' "
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		Elseif MV_PAR07 <> 3
			cSQL += " JOIN "+cNamVV1+" VV1 ON ( VV1_FILIAL='"+cFilVV1+"' AND VV1_CHAINT=VVA_CHAINT " 
			if MV_PAR07 == 1
				cSQL += " AND VV1_IMOBI = '1' "
			Elseif MV_PAR07 == 2
				cSQL += " AND VV1_IMOBI <> '1' "
			Endif
			cSQL += " AND VV1.D_E_L_E_T_=' ' ) "
		Endif
		cSQL +=  " WHERE "
		cSQL +=  " VV0_FILIAL = '"+cFilVV0+"' AND"
		cSQL +=  " VV0_OPEMOV IN ('0','2','3','4','5','6','7')"
		cSQL +=  " AND VV0_DATMOV <= '"+DtoS(mv_par04)+"'"
		cSQL +=  " AND VV0_SITNFI <> '0'"
		cSQL +=  " AND VV0_NUMNFI <> ' '"
		cSQL +=  " AND VV0.D_E_L_E_T_ = ' '"
		cSQL +=  " GROUP BY VVA_CHAINT ) TSAITMP"
		cSQL +=  " JOIN "+cNamVV0+" VV02 ON VV02.VV0_FILIAL = '"+cFilVV0+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                               " AND VV02.VV0_NUMTRA = SUBSTRING(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		else
			cSQL +=                               " AND VV02.VV0_NUMTRA = SUBSTR(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		endif
		cSQL +=                                   " AND VV02.D_E_L_E_T_ = ' '"
		cSQL +=                   " JOIN "+cNamVVA+" VVA2 ON VVA2.VVA_FILIAL = '"+cFilVV0+"'"
		if "MSSQL" $ cSGBD .or. cSGBD == "SYBASE"
			cSQL +=                               " AND VVA2.VVA_NUMTRA = SUBSTRING(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		else
			cSQL +=                               " AND VVA2.VVA_NUMTRA = SUBSTR(TSAITMP.VV0TMP,"+cVV0DTH+",10)"
		endif
		cSQL +=                                  " AND VVA2.VVA_CHAINT = TSAITMP.CHAINT "
		cSQL +=                                  " AND VVA2.D_E_L_E_T_ = ' '"
		cSQL +=        " ) TSAIDA"
		cSQL += " ON TENTRADA.CHAINT = TSAIDA.CHAINT"
		// Filtro por Estado do Veiculo
		if mv_par05 == 1 		// Veiculos Novos
			cSQL += " WHERE TENTRADA.VVG_ESTVEI = '0'"
			// Filtro por Estado do Veiculo
		Elseif mv_par05 == 2	// Veiculos Usados
			cSQL += " WHERE TENTRADA.VVG_ESTVEI = '1'"
		endif
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasTMP, .T., .T. )
		
		cCHAINT := ""
		
		dbSelectArea(cAliasTMP)
		dbGoTop()
		
		while !Eof()
			
			If cCHAINT <> (cAliasTMP)->CHAINT
				cCHAINT := (cAliasTMP)->CHAINT
			Else
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			EndIf
			
			If !VV1->(dbSeek(cFilVV1+(cAliasTMP)->CHAINT))
				MsgAlert(STR0063+" '"+(cAliasTMP)->CHAINT+"' "+STR0064,STR0062) // ChaInt 'XXXXXX' não encontrado no Cadastro de Veículos! / Atencao
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			endif
			
			// Controla o Status do veiculo ...
			cTRB_SITVEI := ""
			
			c_ptodep := "**"
			c_nfsda  := space(9)
			
			// Houve saida dentro do periodo
			IF !Empty((cAliasTMP)->VV0_NUMTRA)
				
				cHoraEnt := AllTrim(Right((cAliasTMP)->VVF_DTHEMI,Len((cAliasTMP)->VVF_DTHEMI)-9))
				cHoraSai := AllTrim(Right((cAliasTMP)->VV0_DTHEMI,Len((cAliasTMP)->VV0_DTHEMI)-9))
				
				// Verifica se a ultima transacao foi de entrada ou saida
				// Se for a mesma data, verifica pela hora da transacao
				// Se a ultima for de saida, deve verificar qual foi o tipo da movimentacao
				IF ( (cAliasTMP)->VVF_DATMOV == (cAliasTMP)->VV0_DATMOV .and. cHoraSai > cHoraEnt) ;
					.or. (cAliasTMP)->VV0_DATMOV > (cAliasTMP)->VVF_DATMOV
					
					// Se for Saida por Remessa ou Consignacao , verifica se é uma remessa em poder de terceiro
					IF (cAliasTMP)->VV0_OPEMOV $ "3,5"
						// Se não for uma TES de remessa com controle de 3º, veiculo nao esta mais no estoque
						cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVA_CODTES+"' AND D_E_L_E_T_=' '")
						IF cPoder3 == "R"
							IF (cAliasTMP)->VV0_OPEMOV == "3"
								cTRB_SITVEI = "7" // Remessa de Propria em Poder de Terceiro
								
								if lc_depto
									c_ptodep := if(!empty((cAliasTMP)->VV0_DEPTO),(cAliasTMP)->VV0_DEPTO,"**")
									c_nfsda := (cAliasTMP)->VV0_NUMNFI
								endif
							ELSEIF  (cAliasTMP)->VV0_OPEMOV == "5"
								cTRB_SITVEI = "4" // Consignado
							ENDIF
						ELSE
							// Veiculo não esta no estoque
							dbSelectArea(cAliasTMP)
							dbSkip()
							Loop
						ENDIF
						// Veiculo não esta no estoque
					ELSE
						dbSelectArea(cAliasTMP)
						dbSkip()
						Loop
					ENDIF
				ENDIF
			ENDIF
			
			If ExistBlock("VVC060PE")
				lRet := ExecBlock("VVC060PE",.f.,.f.)
				If !lRet
					dbSelectArea(cAliasTMP)
					dbSkip()
					Loop
				Endif
			Endif
			
			// Se nao tiver em branco, se trata de uma remessa propria para terceiros e ja foi encontrado o STATUS do veiculo
			IF Empty(cTRB_SITVEI)
				
				// Mov. de Entrada Normal, Devolucao, Retorno de Remessa ou Retorno de Consig.
				if (cAliasTMP)->VVF_OPEMOV $ "0,5"
					cTRB_SITVEI := "0" // Estoque
					
					// Mov. de Entrada por Remessa ou Consignacao
				elseif (cAliasTMP)->VVF_OPEMOV $ "2,4"
					// Verifica se a TES é uma [R]emessa de poder de Terceiros
					cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVG_CODTES+"' AND D_E_L_E_T_=' '")
					IF cPoder3 == "R"
						IF (cAliasTMP)->VVF_OPEMOV == "2"
							cTRB_SITVEI := "3" // Remessa de Terceiro em Nosso Poder
						ELSEIF (cAliasTMP)->VVF_OPEMOV == "4"
							cTRB_SITVEI := "4" // Consignado
						ENDIF
					ENDIF
					
					// Mov. de Entrada por Transferencia
				elseif (cAliasTMP)->VVF_OPEMOV == "3"
					cTRB_SITVEI := "5" // Transferido
					
					// Mov. de Entrada por Retorno de Remessa e Retorno de Consignacao
				elseif (cAliasTMP)->VVF_OPEMOV $ "7,8"
					// Verifica se a TES é uma [D]emessa de poder de Terceiros
					cPoder3 := FM_SQL("SELECT F4_PODER3 FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+(cAliasTMP)->VVG_CODTES+"' AND D_E_L_E_T_=' '")
					IF cPoder3 == "D"
						cTRB_SITVEI := "0" // Estoque
					Else
						DBSelectArea("SB1")
						DBSetOrder(7)
						MsSeek(cFilSB1+cGruVei+VV1->VV1_CHAINT)
						If FM_SQL("SELECT R_E_C_N_O_ FROM "+cNamSB2+" WHERE B2_FILIAL='"+cFilSB2+"' AND B2_COD='"+SB1->B1_COD+"' AND B2_QATU>0  AND D_E_L_E_T_=' '") > 0
							cTRB_SITVEI := "0" // Estoque
						EndIf
					ENDIF
				endif
				//
				
			ENDIF
			
			// Veiculo nao esta no estoque
			if Empty(cTRB_SITVEI)
				dbSelectArea(cAliasTMP)
				dbSkip()
				Loop
			endif
			
			VVF->(MsSeek(cFilVVF+(cAliasTMP)->VVF_TRACPA))
			VVG->(MsSeek(cFilVVF+(cAliasTMP)->VVF_TRACPA+VV1->VV1_CHAINT))
			VV2->(MsSeek(cFilVV2+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			
			nValTab := 0
			if "DB2" $ cSGBD
				cSQL := "SELECT VVP_VALTAB "
			elseif "ORACLE" $ cSGBD
				cSQL := "SELECT * FROM ( SELECT VVP_VALTAB "
			else
				cSQL := "SELECT TOP 1 VVP_VALTAB "
			endif
			cSQL += " FROM "+cNamVVP+" VVP"
			cSQL += " WHERE "
			cSQL += "VVP.VVP_FILIAL='"+cFilVVP+"' AND"
			cSQL += " VVP.VVP_CODMAR = '"+VV1->VV1_CODMAR+"'"
			cSQL += " AND VVP.VVP_MODVEI = '"+VV1->VV1_MODVEI+"'"
			cSQL += " AND VVP.VVP_SEGMOD = '"+VV2->VV2_SEGMOD+"'"
			cSQL += " AND VVP.VVP_DATPRC >= '" + DtoS(MV_PAR04) + "'"
			cSQL += " AND VVP.D_E_L_E_T_ = ' '"
			cSQL += " ORDER BY VVP_DATPRC"
			if "DB2" $ cSGBD
				cSQL += " FETCH FIRST 1 ROW ONLY"
			elseif "ORACLE" $ cSGBD
				cSQL += " ) WHERE ROWNUM <= 1"
			endif
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), "TVALTAB", .T., .T. )
			IF !TVALTAB->(Eof())
				nValtab := TVALTAB->VVP_VALTAB
			ENDIF
			TVALTAB->(dbCloseArea())
			
			cTipFat := VVG->VVG_ESTVEI
			
			
			if VVF->VVF_CLIFOR = "F"
				cFornece := FM_SQL("SELECT A2_NOME FROM "+cNamSA2+" WHERE A2_FILIAL='"+cFilSA2+"' AND A2_COD='"+VVF->VVF_CODFOR+"' AND A2_LOJA='"+VVF->VVF_LOJA+"' AND D_E_L_E_T_=' '")
			else
				cFornece := FM_SQL("SELECT A1_NOME FROM "+cNamSA1+" WHERE A1_FILIAL='"+cFilSA1+"' AND A1_COD='"+VVF->VVF_CODFOR+"' AND A1_LOJA='"+VVF->VVF_LOJA+"' AND D_E_L_E_T_=' '")			
			endif
			
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			
			DBSelectArea("SB2")
			DBSetOrder(1)
			MsSeek(cFilSB2+SB1->B1_COD+VV1->VV1_LOCPAD)
			
			DbSelectArea("TRB")
			RecLock("TRB",.t.)
			TRB_FILIAL := VV1->VV1_FILENT
			TRB_FILENT := VVF->VVF_FILIAL
			TRB_TIPOVV := VVG->VVG_ESTVEI
			TRB_PROVVV := if(left(VV1->VV1_PROVEI,1)$"0,3,4,5,8","0","1") //0-nacional, 1-importado
			TRB_DIAEST := mv_par04-VVF->VVF_DATMOV
			TRB_NUMNFI := VVF->VVF_NUMNFI
			TRB_DATEMI := VVF->VVF_DATEMI
			TRB_FORNEC := cFornece
			TRB_DTDIGI := VVF->VVF_DATMOV
			TRB_MODELO := VV1->VV1_CODMAR+" "+Left(VV2->VV2_DESMOD,20)
			TRB_MARMOD := VV1->VV1_CODMAR+" "+left(VV1->VV1_MODVEI,10)+"-"+Left(VV2->VV2_DESMOD,10)
			TRB_CHASSI := VV1->VV1_CHASSI
			TRB_CORVEI := left(FM_SQL("SELECT VVC_DESCRI FROM "+cNamVVC+" WHERE VVC_FILIAL='"+cFilVVC+"' AND VVC_CODMAR='"+VV1->VV1_CODMAR+"' AND VVC_CORVEI='"+VV1->VV1_CORVEI+"' AND D_E_L_E_T_=' '"),10)
			TRB_VALNFI := VVG->VVG_VALUNI+VVG->VVG_VALIPI+VVG->VVG_TOTSEG+VVG->VVG_TOTFRE+VVG->VVG_ICMRET
			TRB_PICRET := VVG->VVG_PISENT+VVG->VVG_COFENT
			TRB_VALFRE := VVG->VVG_VALFRE
			TRB_VALTAB := nValTab
			TRB_CODIND := VVG->VVG_CODIND
			TRB_DESIND := FM_SQL("SELECT VVH_DESCRI FROM "+cNamVVH+" WHERE VVH_FILIAL='"+cFilVVH+"' AND VVH_CODIND='"+VVG->VVG_CODIND+"' AND D_E_L_E_T_=' '")
			TRB_TIPFAT := cTipFat
			
			TRB_CUSTOV := SB2->B2_CM1
			TRB_CUSATU := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATMOV,dDataBase)+FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATMOV,dDataBase,"V")
			TRB_SITVEI := cTRB_SITVEI
			TRB_PLAVEI := VV1->VV1_PLAVEI
			TRB_MODVEI := VV1->VV1_MODVEI
			TRB_ANOMOD := VV1->VV1_FABMOD
			TRB_POSIPI := VV1->VV1_POSIPI
			TRB_DISEIX := VV1->VV1_DISEIX
			TRB_DEPTO  := c_ptodep
			TRB_NFSAI  := c_NFSda
			MsUnlock()
			nTotCUSCo  += SB2->B2_CM1
			DbSelectArea(cAliasTMP)
			DbSkip()
			
		Enddo
		
		(cAliasTMP)->(dbCloseArea())
		
	Next
	
Endif

cFilAnt := cFilBkp

DbSelectArea("TRB")
DbSetOrder(1)
DbGoTop()

nLin      := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1
cTipoVV   := ""
cProvVei  := ""
cTipoCor  := ""
cSituac   := ""
c_dep     := ""
cDesTipo  := " "
nTotVNF   := 0
nTotVNFCor:= 0
nTotVNFCor := 0
nTFrete   := 0
nTFreteCor:= 0
nQtdVei   := 0
nQtdVeiCor:= 0
nTCUSCo   := 0
nTCUSCoCor:= 0
nTCUCCo   := 0
nTotCUCCo  := 0
nTCUCCoCor:= 0
nTValTb	 := 0
nTotValTb := 0
nTValTbCor:= 0
nTotVNFg  := 0
nTFreteg  := 0
nQtdVeig  := 0
nTCUSCog  := 0
nTCUCCog  := 0
nTValTbg	 := 0
nQtVeiEst := 0
nTotVNFgEst := 0
nTFretegEst := 0
nTFreteSCor := 0
nTFreteCCor := 0
nTFreteTInd := 0
nQtVeiRem   := 0
nTotVNFgRem := 0
nTFretegRem := 0
nTFreRemSCo := 0
nTFreRemCCo := 0
nTFreRemTIn := 0
nQtVeiRnp   := 0
nTotVNFgRnp := 0
nTFretegRnp := 0
nTFreRnpSCo := 0
nTFreRnpCCo := 0
nTFreRnpTIn := 0
nQtVeiCon   := 0
nTotVNFgCon := 0
nTFretegCon := 0
nTFreConSCo := 0
nTFreConCCo := 0
nTFreConTIn := 0
nQtVeiTra   := 0
nTotVNFgTra := 0
nTFretegTra := 0
nTFreTraSCo := 0
nTFreTraCCo := 0
nTFreTraTIn := 0
nQtVeiRes   := 0
nTotVNFgRes := 0
nTFretegRes := 0
nTFreResSCo := 0
nTFreResCCo := 0
nTFreResTIn := 0
cSituac     := "" //TRB_SITVEI
nTotVNF_dp  := 0
nTFrete_dp  := 0
nTCUSCo_dp  := 0
nTCUCCo_dp  := 0
nTValTb_dp  := 0
nQtdVei_dp  := 0
nTotVNFg_dp := 0
nTFreteg_dp := 0
nTCUSCog_dp := 0
nTCUCCog_dp := 0
nTValTbg_dp  := 0
nQtdVeig_dp  := 0
nCont  := 0
cTipoA := 0
nAchou := 0
c_DesDepto := ""
nQtVeiNac   := 0
nTotVNFgNac := 0    
nTFretegNac  := 0
nTFreNacSCo := 0
nTFreNacCCo := 0
nTFreNacTIn := 0
nQtVeiImp   := 0
nTotVNFgImp := 0
nTFretegImp  := 0
nTFreImpSCo := 0
nTFreImpCCo := 0
nTFreImpTIn := 0
nQtVeiNov   := 0
nTotVNFgNov  := 0
nTFretegNov  := 0
nTFreNovSCo  := 0
nTFreNovCCo  := 0
nTFreNovTIn  := 0
nQtVeiUsa    := 0
nTotVNFgUsa  := 0
nTFretegUsa  := 0
nTFreUsaSCo  := 0
nTFreusaCCo  := 0
nTFreUsaTIn  := 0 

While !Eof()
	
	if mv_par05 == 1 .or. mv_par05 == 2 .or. mv_par05 == 3
		
		nTotVNF   := TRB_VALNFI
		nTFrete   := TRB_VALFRE
		nTCUSCo   := TRB_CUSTOV                      	
		nTCUCCo   := TRB_CUSATU
		nTValTb   := TRB_VALTAB
		cTipoA   := 0

		nQtdVei   := 1
		nTotVNFg  := nTotVNFg + TRB_VALNFI
		nTFreteg  := nTFreteg + TRB_VALFRE
		nTCUSCog  := nTCUSCog + TRB_CUSTOV // Total do Custo Sem Correcao
		nTCUCCog  := nTCUCCog + TRB_CUSATU // Total do Custo Com Correcao
		nTValTbg  := nTValTbg + TRB_VALTAB // Total de Tabela
		nQtdVeig  := nQtdVeig + 1
		
	
	   if TRB->TRB_TIPOVV = "0" //NOVO
			nQtVeiNov  := nQtVeiNov + 1
			nTotVNFgNov  := nTotVNFgNov + TRB_VALNFI
			nTFretegNov  := nTFretegNov + TRB_VALFRE
			nTFreNovSCo  := nTFreNovSCo + TRB_CUSTOV
			nTFreNovCCo  := nTFreNovCCo + TRB_CUSATU
			nTFreNovTIn  := nTFreNovTIn + TRB_VALTAB
	   
	   elseif TRB->TRB_TIPOVV = "1" //USADO
			nQtVeiUsa  := nQtVeiUsa + 1
			nTotVNFgUsa  := nTotVNFgUsa + TRB_VALNFI
			nTFretegUsa  := nTFretegUsa + TRB_VALFRE
			nTFreUsaSCo  := nTFreUsaSCo + TRB_CUSTOV
			nTFreusaCCo  := nTFreUsaCCo + TRB_CUSATU
			nTFreUsaTIn  := nTFreUsaTIn + TRB_VALTAB 
	   endif
	
		if TRB->TRB_SITVEI = "0"		// Estoque
			cSitVei := STR0012
			nQtVeiEst  := nQtVeiEst + 1
			nTotVNFgEst  := nTotVNFgEst + TRB_VALNFI
			nTFretegEst  := nTFretegEst + TRB_VALFRE
			nTFreteSCor  := nTFreteSCor + TRB_CUSTOV
			nTFreteCCor  := nTFreteCCor + TRB_CUSATU
			nTFreteTInd  := nTFreteTInd + TRB_VALTAB
		
		elseif TRB->TRB_SITVEI = "3"	// Remessa de Terceiro em Nosso Poder
			cSitVei := STR0013
			nQtVeiRem  := nQtVeiRem + 1
			nTotVNFgRem  := nTotVNFgRem + TRB_VALNFI
			nTFretegRem  := nTFretegRem + TRB_VALFRE
			nTFreRemSCo  := nTFreRemSCo + TRB_CUSTOV
			nTFreRemCCo  := nTFreRemCCo + TRB_CUSATU
			nTFreRemTIn  := nTFreRemTIn + TRB_VALTAB
		
		elseif TRB->TRB_SITVEI = "7"	// Remessa Propria em Poder de Terceiro
			cSitVei := "R N P T" // Remessa Nossa em Poder de Terceiros
			nQtVeiRnp++
			nTotVNFgRnp  += TRB_VALNFI
			nTFretegRnp  += TRB_VALFRE
			nTFreRnpSCo  += TRB_CUSTOV
			nTFreRnpCCo  += TRB_CUSATU
			nTFreRnpTIn  += TRB_VALTAB
		
		elseif TRB->TRB_SITVEI = "4"	// Consignado
			cSitVei := STR0061
			nQtVeiCon    := nQtVeiCon + 1
			nTotVNFgCon  := nTotVNFgCon + TRB_VALNFI
			nTFretegCon  := nTFretegCon + TRB_VALFRE
			nTFreConSCo  := nTFreConSCo + TRB_CUSTOV
			nTFreConCCo  := nTFreConCCo + TRB_CUSATU
			nTFreConTIn  := nTFreConTIn + TRB_VALTAB
		
		elseif TRB->TRB_SITVEI = "5"	// Transferido
			cSitVei := STR0015
			nQtVeiTra    := nQtVeiTra + 1
			nTotVNFgTra  := nTotVNFgTra + TRB_VALNFI
			nTFretegTra  := nTFretegTra + TRB_VALFRE
			nTFreTraSCo  := nTFreTraSCo + TRB_CUSTOV
			nTFreTraCCo  := nTFreTraCCo + TRB_CUSATU
			nTFreTraTIn  := nTFreTraTIn + TRB_VALTAB
		
		elseif TRB->TRB_SITVEI = "6"	// Reservado
			cSitVei := STR0016
			nQtVeiRes    := nQtVeiRes + 1
			nTotVNFgRes  := nTotVNFgRes + TRB_VALNFI
			nTFretegRes  := nTFretegRes + TRB_VALFRE
			nTFreResSCo  := nTFreResSCo + TRB_CUSTOV
			nTFreResCCo  := nTFreResCCo + TRB_CUSATU
			nTFreResTIn  := nTFreResTIn + TRB_VALTAB
		endif

		if cSituac # TRB_SITVEI  //estoque / remessa/ consignado/ transferencia
		
			if cProvVei = "0"  .and. nQtVeiNac > 0 //nacional - tratamento da S0 na gravação do arquivo
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4) + STR0044+Space(96),96) + trans(nQtVeiNac,"@E 999999") + Space(23) + trans(nTotVNFgNac,"@E 999,999,999.99") + trans(nTFretegNac,"@E 999,999.99")+" "+ trans(nTFreNacSCo,"@E 9,999,999.99")+" "+trans(nTFreNacCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiNac   := 0
				nTotVNFgNac := 0
				nTFretegNac  := 0
				nTFreNacSCo := 0
				nTFreNacCCo := 0
				nTFreNacTIn := 0
				nLin := nLin + 1
				     
			ElseIf cProvVei = "1" .and. nQtVeiImp > 0//importado 
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4) + STR0045+Space(96),96) + trans(nQtVeiImp,"@E 999999") + Space(23) + trans(nTotVNFgImp,"@E 999,999,999.99") + trans(nTFretegImp,"@E 999,999.99")+" "+ trans(nTFreImpSCo,"@E 9,999,999.99")+" "+trans(nTFreImpCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiImp   := 0
				nTotVNFgImp := 0
				nTFretegImp  := 0
				nTFreImpSCo := 0
				nTFreImpCCo := 0
				nTFreImpTIn := 0
				nLin := nLin + 1
			EndIf
			
			cProvVei := TRB_PROVVV

			if cSituac == "0" .and. nQtVeiEst > 0 //Estoque
				@ nLin++
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4)+STR0017+Space(96),96) + trans(nQtVeiEst,"@E 999999") + Space(23) + trans(nTotVNFgEst,"@E 999,999,999.99") + trans(nTFretegEst,"@E 999,999.99")+" "+trans(nTFreteSCor,"@E 9,999,999.99")+" "+trans(nTFreteCCor,"@E 9,999,999.99") //"T o t a l  d e  E s t o q u e "
				@ nLin++,00 psay Repl("-",220)
	
				nQtVeiEst   := 0
				nTotVNFgEst := 0
				nTFretegEst := 0
				nTFreteSCor := 0
				nTFreteCCor := 0
				nTFreteTInd := 0
				nLin := nLin + 2
			endif
		
			if cSituac == "3" .and. nQtVeiRem > 0	// Remessa de Terceiro em Nosso Poder
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4)+STR0018+Space(96),96) + trans(nQtVeiRem,"@E 999999") + Space(23) + trans(nTotVNFgRem,"@E 999,999,999.99") + trans(nTFretegRem,"@E 999,999.99")+" "+trans(nTFreRemSCo,"@E 9,999,999.99")+" "+trans(nTFreRemCCo,"@E 9,999,999.99") //"T o t a l  d e  R e m e s s a "
				@ nLin++,00 psay Repl("-",220)
	
				nQtVeiRem   := 0
				nTotVNFgRem := 0
				nTFretegRem := 0
				nTFreRemSCo := 0
				nTFreRemCCo := 0
				nTFreRemTIn := 0
				nLin := nLin + 2
			Endif
	
			if cSituac == "7"	.and. ( nQtVeiRnp > 0 .or. nQtdVei_dp > 0 )// Remessa de Propria em Poder de 3º

				if !Empty(c_dep)
					nLin := nLin + 1
					@ nLin++,00 psay Repl("-",220)
					@ nLin++,00 psay left(STR0006 + c_DesDepto+Space(96),96) + trans(nQtdVei_dp,"@E 999999") + Space(23) + trans(nTotVNF_dp,"@E 999,999,999.99") + trans(nTFrete_dp,"@E 999,999.99") +" "+ trans(nTCUSCo_dp,"@E 9,999,999.99") +" "+ trans(nTCUCCo_dp,"@E 9,999,999.99") //"T O T A L   D E   "
					@ nLin++,00 psay Repl("-",220)
					c_dep := ""
				Endif
					
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ 	nLin++,00 psay left(space(4)+STR0018+Space(96),96) + trans(nQtVeiRnp,"@E 999999") + Space(22) + ;
				trans(nTotVNFgRnp,"@E 999,999,999.99") +""+ ;
				trans(nTFretegRnp,"@E 999,999.99")+" "+;
				trans(nTFreRnpSCo,"@E 9,999,999.99")+" "+;
				trans(nTFreRnpCCo,"@E 9,999,999.99") //"T o t a l  d e  R e m e s s a "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiRnp   := 0
				nTotVNFgRnp := 0
				nTFretegRnp := 0
				nTFreRnpSCo := 0
				nTFreRnpCCo := 0
				nTFreRnpTIn := 0
				nLin := nLin + 2
			Endif
			
			if cSituac == "4"	.and. nQtVeiCon > 0// Consignado
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4)+STR0019 +Space(96),96) + trans(nQtVeiCon,"@E 999999") + Space(23) + trans(nTotVNFgCon,"@E 999,999,999.99") + trans(nTFretegCon,"@E 999,999.99")+" "+ trans(nTFreConSCo,"@E 9,999,999.99")+" "+trans(nTFreConCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiCon   := 0
				nTotVNFgCon := 0
				nTFretegCon := 0
				nTFreConSCo := 0
				nTFreConCCo := 0
				nTFreConTIn := 0
				nLin := nLin + 2
			Endif
			
			if cSituac == "5"	.and. nQtVeiTra > 0 .and. cSituac = TRB_SITVEI // Transferido
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4)+STR0020+Space(96),96) + trans(nQtVeiTra,"@E 999999") + Space(23) + trans(nTotVNFgTra,"@E 999,999,999.99") + trans(nTFretegTra,"@E 999,999.99")+" "+trans(nTFreTraSCo,"@E 9,999,999.99")+" "+trans(nTFreTraCCo,"@E 9,999,999.99") //"T o t a l  d e  T r a n s f e r e n c i a "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiTra   := 0
				nTotVNFgTra := 0
				nTFretegTra := 0
				nTFreTraSCo := 0
				nTFreTraCCo := 0
				nTFreTraTIn := 0
				nLin := nLin + 2
			Endif
	
			if cSituac == "6"	.and. nQtVeiRes > 0// Reservado
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4)+STR0021+Space(96),96) + trans(nQtVeiRes,"@E 999999") + Space(23) + trans(nTotVNFgRes,"@E 999,999,999.99") + trans(nTFretegRes,"@E 999,999.99")+" "+trans(nTFreResSCo,"@E 9,999,999.99")+" "+trans(nTFreResCCo,"@E 9,999,999.99") //"T o t a l  d e  R e s e r v a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiRes   := 0
				nTotVNFgRes := 0
				nTFretegRes := 0
				nTFreResSCo := 0
				nTFreResCCo := 0
				nTFreResTIn := 0
				nLin := nLin + 2
			Endif
			
			cSituac := TRB_SITVEI


		elseif cProvVei # TRB_PROVVV  //nacional, importado

			if cProvVei = "0"  .and. nQtVeiNac > 0 //nacional - tratamento da S0 na gravação do arquivo
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4) + STR0044+Space(96),96) + trans(nQtVeiNac,"@E 999999") + Space(23) + trans(nTotVNFgNac,"@E 999,999,999.99") + trans(nTFretegNac,"@E 999,999.99")+" "+ trans(nTFreNacSCo,"@E 9,999,999.99")+" "+trans(nTFreNacCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiNac   := 0
				nTotVNFgNac := 0
				nTFretegNac  := 0
				nTFreNacSCo := 0
				nTFreNacCCo := 0
				nTFreNacTIn := 0
				nLin := nLin + 1

			ElseIf cProvVei = "1" .and. nQtVeiImp > 0//importado 
				nLin := nLin + 1
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(space(4) + STR0045+Space(96),96) + trans(nQtVeiImp,"@E 999999") + Space(23) + trans(nTotVNFgImp,"@E 999,999,999.99") + trans(nTFretegImp,"@E 999,999.99")+" "+ trans(nTFreImpSCo,"@E 9,999,999.99")+" "+trans(nTFreImpCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
				@ nLin++,00 psay Repl("-",220)
				nQtVeiImp   := 0
				nTotVNFgImp := 0
				nTFretegImp  := 0
				nTFreImpSCo := 0
				nTFreImpCCo := 0
				nTFreImpTIn := 0
				nLin := nLin + 1
			EndIf
		
			cProvVei := TRB_PROVVV
		
		endif

		if TRB->TRB_PROVVV = "0" //NACIONAL
			nQtVeiNac    := nQtVeiNac + 1
			nTotVNFgNac  := nTotVNFgNac + TRB_VALNFI
			nTFretegNac  := nTFretegNac + TRB_VALFRE
			nTFreNacSCo  := nTFreNacSCo + TRB_CUSTOV
			nTFreNacCCo  := nTFreNacCCo + TRB_CUSATU
			nTFreNacTIn  := nTFreNacTIn + TRB_VALTAB

		elseif TRB->TRB_PROVVV = "1" //IMPORTADO
			nQtVeiImp    := nQtVeiImp + 1
			nTotVNFgImp  := nTotVNFgImp + TRB_VALNFI
			nTFretegImp  := nTFretegImp + TRB_VALFRE
			nTFreImpSCo  := nTFreImpSCo + TRB_CUSTOV
			nTFreImpCCo  := nTFreImpCCo + TRB_CUSATU
			nTFreImpTIn  := nTFreImpTIn + TRB_VALTAB
		endif

		if cTipoVV # TRB_TIPOVV  //novo,usado

			If cTipoVV == "0" .and.  nQtVeiNov > 0//novo

				if cProvVei # TRB_PROVVV  //nacional, importado

					if cProvVei = "0"  .and. nQtVeiNac > 0 //nacional - tratamento da S0 na gravação do arquivo
						nLin := nLin + 1
						@ nLin++,00 psay Repl("-",220)
						@ nLin++,00 psay left(space(4) + STR0044+Space(96),96) + trans(nQtVeiNac,"@E 999999") + Space(23) + trans(nTotVNFgNac,"@E 999,999,999.99") + trans(nTFretegNac,"@E 999,999.99")+" "+ trans(nTFreNacSCo,"@E 9,999,999.99")+" "+trans(nTFreNacCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
						@ nLin++,00 psay Repl("-",220)
						nQtVeiNac   := 0
						nTotVNFgNac := 0
						nTFretegNac  := 0
						nTFreNacSCo := 0
						nTFreNacCCo := 0
						nTFreNacTIn := 0
						nLin := nLin + 1

					ElseIf cProvVei = "1" .and. nQtVeiImp > 0//importado 
						nLin := nLin + 1
						@ nLin++,00 psay Repl("-",220)
						@ nLin++,00 psay left(space(4) + STR0045+Space(96),96) + trans(nQtVeiImp,"@E 999999") + Space(23) + trans(nTotVNFgImp,"@E 999,999,999.99") + trans(nTFretegImp,"@E 999,999.99")+" "+ trans(nTFreImpSCo,"@E 9,999,999.99")+" "+trans(nTFreImpCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
						@ nLin++,00 psay Repl("-",220)
						nQtVeiImp   := 0
						nTotVNFgImp := 0
						nTFretegImp  := 0
						nTFreImpSCo := 0
						nTFreImpCCo := 0
						nTFreImpTIn := 0
						nLin := nLin + 1
					EndIf
			
					cProvVei := TRB_PROVVV
				endif

				@ nLin := nLin + 2
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(STR0006 + STR0065+Space(96),96) + trans(nQtVeiNov,"@E 999999") + Space(23) + trans(nTotVNFgNov,"@E 999,999,999.99") + trans(nTFretegNov,"@E 999,999.99") +" "+ trans(nTFreNovSCo,"@E 9,999,999.99") +" "+ trans(nTFreNovCCo,"@E 9,999,999.99") //"T O T A L   D E   "
				@ nLin++,00 psay Repl("-",220)

				nQtVeiNov   := 0
				nTotVNFgNov  := 0
				nTFretegNov  := 0
				nTFreNovSCo  := 0
				nTFreNovCCo  := 0
				nTFreNovTIn  := 0
				
				nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,ctamanho,nCaracter) + 1

			ElseIf cTipoVV == "1" .and. nQtVeiUsa > 0 // Usado

				if cProvVei # TRB_PROVVV  //nacional, importado

					if cProvVei = "0"  .and. nQtVeiNac > 0 //nacional - tratamento da S0 na gravação do arquivo
						@ nLin++,00 psay Repl("-",220)
						@ nLin++,00 psay left(space(4) + STR0044+Space(96),96) + trans(nQtVeiNac,"@E 999999") + Space(23) + trans(nTotVNFgNac,"@E 999,999,999.99") + trans(nTFretegNac,"@E 999,999.99")+" "+ trans(nTFreNacSCo,"@E 9,999,999.99")+" "+trans(nTFreNacCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
						@ nLin++,00 psay Repl("-",220)
						nQtVeiNac   := 0
						nTotVNFgNac := 0
						nTFretegNac  := 0
						nTFreNacSCo := 0
						nTFreNacCCo := 0
						nTFreNacTIn := 0
						nLin := nLin + 1

			      ElseIf cProvVei = "1" .and. nQtVeiCon > 0//importado 
						@ nLin++,00 psay Repl("-",220)
						@ nLin++,00 psay left(space(4) + STR0045+Space(96),96) + trans(nQtVeiImp,"@E 999999") + Space(23) + trans(nTotVNFgImp,"@E 999,999,999.99") + trans(nTFretegImp,"@E 999,999.99")+" "+ trans(nTFreImpSCo,"@E 9,999,999.99")+" "+trans(nTFreImpCCo,"@E 9,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
						@ nLin++,00 psay Repl("-",220)
						nQtVeiImp   := 0
						nTotVNFgImp := 0
						nTFretegImp  := 0
						nTFreImpSCo := 0
						nTFreImpCCo := 0
						nTFreImpTIn := 0
						nLin := nLin + 1
					EndIf
			
					cProvVei := TRB_PROVVV
				endif

				nLin := nLin + 2
				@ nLin++,00 psay Repl("-",220)
				@ nLin++,00 psay left(STR0006 + STR0066+Space(96),96) + trans(nQtVeiUsa,"@E 999999") + Space(23) + trans(nTotVNFgUsa,"@E 999,999,999.99") + trans(nTFretegUsa,"@E 999,999.99") +" "+ trans(nTFreUsaSCo,"@E 9,999,999.99") +" "+ trans(nTFreUsaCCo,"@E 9,999,999.99") //"T O T A L   D E   "
				@ nLin++,00 psay Repl("-",220)
				
				nQtVeiUsa   := 0
				nTotVNFgUsa  := 0
				nTFretegUsa  := 0
				nTFreUsaSCo  := 0
				nTFreUsaCCo  := 0
				nTFreUsaTIn  := 0
				nLin := nLin + 2
			endif

			cTipoVV := TRB_TIPOVV
		endif

		cDia := substr(dtoc(TRB_DATEMI),1,2)
		cMes := substr(dtoc(TRB_DATEMI),4,2)
		cAno := substr(dtoc(TRB_DATEMI),7,4)
		if Len(Alltrim(cAno)) == 4
			cAno := substr(cAno,3,2)
		Endif
		dData   := cDia+"/"+cMes+"/"+cAno
		cAnoMod := substr(TRB_ANOMOD,5,4)
		cDtDia := substr(dtoc(TRB_DTDIGI),1,2)
		cDtMes := substr(dtoc(TRB_DTDIGI),4,2)
		cDtAno := substr(dtoc(TRB_DTDIGI),7,4)
		if Len(Alltrim(cDtAno)) == 4
			cDtAno := substr(cDtAno,3,2)
		Endif
		dDtDigi  := cDtDia+"/"+cDtMes+"/"+cDtAno

		If cTipoVV = "0" .and.  nQtVeiNov = 1//novo
			@ nLin++,00 psay Repl("-",220)
			@ nLin++,00 psay left(STR0065+Space(96),96)
			@ nLin++,00 psay Repl("-",220)
			@ nLin++
		ElseIf cTipoVV == "1" .and. nQtVeiUsa = 1 // Usado
			@ nLin++,00 psay Repl("-",220)
			@ nLin++,00 psay left(STR0066+Space(96),96)
			@ nLin++,00 psay Repl("-",220)
			@ nLin++
		Endif

		nTotCUCCo += nTCUCCo

		@ nLin,00 psay trans(TRB_DIAEST,"99999") + " " +TRB_FILIAL+space(9-len(TRB_FILIAL))+" "+TRB_FILENT+space(9-len(TRB_FILIAL))+" "+ TRB_NUMNFI + " " +dDtDigi+" "+ dData + " " +substr(TRB_FORNEC,1,10)+" "+TRB_MARMOD+ " " +cAnoMod+ " " +substr(TRB_CHASSI,1,18) + " " + TRB_CORVEI + " "+;
		trans(TRB_VALNFI,"@E 99,999,999.99") + trans(TRB_VALFRE,"@E 999,999.99") +" "+ ;
		trans(TRB_CUSTOV,"@E 99999,999.99") +" "+ trans(TRB_CUSATU,"@E 99999,999.99") + " " + TRB_CODIND + "-" + substr(TRB_DESIND,1,06) + " " + Left(cSitVei+Space(8),8) + " " +Trans(TRB_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI")))+" "+left(TRB_POSIPI,8)+" "+trans(TRB_DISEIX,"@E 999,999")
		@ nLin++
		
		if nLin > 55
			nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,ctamanho,nCaracter) + 1
		Endif
		
		DbSelectArea("TRB")
		DbSkip()
		
	Endif
		
Enddo

if cProvVei = "0"
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4) + STR0044+Space(96),96) + trans(nQtVeiNac,"@E 999999") + Space(23) + trans(nTotVNFgNac,"@E 999,999,999.99") + trans(nTFretegNac,"@E 999,999.99")+" "+ trans(nTFreNacSCo,"@E 99,999,999.99")+" "+trans(nTFreNacCCo,"@E 99,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
	@ nLin++,00 psay Repl("-",220)
	nQtVeiNac   := 0
	nTotVNFgNac := 0
	nTFretegNac  := 0
	nTFreNacSCo := 0
	nTFreNacCCo := 0
	nTFreNacTIn := 0
	nLin := nLin + 1

ElseIf cProvVei = "1"
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4) + STR0045+Space(96),96) + trans(nQtVeiImp,"@E 999999") + Space(23) + trans(nTotVNFgImp,"@E 999,999,999.99") + trans(nTFretegImp,"@E 999,999.99")+" "+ trans(nTFreImpSCo,"@E 99,999,999.99")+" "+trans(nTFreImpCCo,"@E 99,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
	@ nLin++,00 psay Repl("-",220)
	nQtVeiImp   := 0
	nTotVNFgImp := 0
	nTFretegImp  := 0
	nTFreImpSCo := 0
	nTFreImpCCo := 0
	nTFreImpTIn := 0
	nLin := nLin + 1
EndIf


if cSituac == "0"		// Estoque
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4)+STR0017+Space(96),96) + trans(nQtVeiEst,"@E 999999") + Space(23) + trans(nTotVNFgEst,"@E 999,999,999.99") + trans(nTFretegEst,"@E 999,999.99")+" "+trans(nTFreteSCor,"@E 99,999,999.99")+" "+trans(nTFreteCCor,"@E 99,999,999.99") //"T o t a l  d e  E s t o q u e "
	@ nLin++,00 psay Repl("-",220)
Endif
if cSituac == "3"	// Remessa de Terceiro em Nosso Poder
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4)+STR0018+Space(96),96) + trans(nQtVeiRem,"@E 999999") + Space(23) + trans(nTotVNFgRem,"@E 999,999,999.99") + trans(nTFretegRem,"@E 999,999.99")+" "+trans(nTFreRemSCo,"@E 99,999,999.99")+" "+trans(nTFreRemCCo,"@E 99,999,999.99") //"T o t a l  d e  R e m e s s a "
	@ nLin++,00 psay Repl("-",220)
Endif
if cSituac == "7"	// // Remessa de Propria em Poder de Terceiro
	if !Empty(c_dep)
		nLin := nLin + 1
		@ nLin++,00 psay Repl("-",220)
		@ nLin++,00 psay left(STR0006 + c_DesDepto+Space(96),96) + trans(nQtdVei_dp,"@E 999999") + Space(23) + ;
		trans(nTotVNF_dp,"@E 999,999,999.99") + ;
		trans(nTFrete_dp,"@E 999,999.99") +" "+ ;
		trans(nTCUSCo_dp,"@E 99,999,999.99") +" "+ ;
		trans(nTCUCCo_dp,"@E 99,999,999.99")  //"T O T A L   D E   "
		@ nLin++,00 psay Repl("-",220)
	Endif
	@ nLin++,00 psay Repl("-",220)
	//+++++++++++++++
	@ nLin++,00 psay left(space(4)+STR0050+Space(96),96) + trans(nQtVeiRnp,"@E 999999") + Space(23) + ;
	trans(nTotVNFgRnp,"@E 999,999,999.99") +""+ ;
	trans(nTFretegRnp,"@E 999,999.99")+" "+;
	trans(nTFreRnpSCo,"@E 99,999,999.99")+" "+;
	trans(nTFreRnpCCo,"@E 99,999,999.99")
	@ nLin++,00 psay Repl("-",220)
Endif
if cSituac == "4"	// Consignado
	nLin := nLin + 1
	if cTipoVV $ "10/11"
		@ nLin++,00 psay Repl("-",220)
		@ nLin++,00 psay left(STR0019 + Space(96),96) + trans(nQtVeiCon,"@E 999999") + Space(23) + trans(nTotVNFgCon,"@E 999,999,999.99") + trans(nTFretegCon,"@E 999,999.99")+" "+ trans(nTFreConSCo,"@E 99,999,999.99")+" "+trans(nTFreConCCo,"@E 99,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
		@ nLin++,00 psay Repl("-",220)
	Else
		@ nLin++,00 psay Repl("-",220)
		@ nLin++,00 psay left(STR0019 + Space(96),96)+ trans(nQtVeiCon,"@E 999999") + Space(23) + trans(nTotVNFgCon,"@E 999,999,999.99") + trans(nTFretegCon,"@E 999,999.99")+" "+ trans(nTFreConSCo,"@E 99,999,999.99")+" "+trans(nTFreConCCo,"@E 99,999,999.99") //"T o t a l  d e  C o n s i g n a d o "
		@ nLin++,00 psay Repl("-",220)
	EndIf
Endif
if cSituac == "5"	// Transferido
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4)+STR0020+Space(96),96) + trans(nQtVeiTra,"@E 999999") + Space(23) + trans(nTotVNFgTra,"@E 999,999,999.99") + trans(nTFretegTra,"@E 999,999.99")+" "+trans(nTFreTraSCo,"@E 99,999,999.99")+" "+trans(nTFreTraCCo,"@E 99,999,999.99") //"T o t a l  d e  T r a n s f e r e n c i a "
	@ nLin++,00 psay Repl("-",220)
Endif
if cSituac == "6"	// Reservado
	nLin := nLin + 1
	@ nLin++,00 psay Repl("-",220)
	@ nLin++,00 psay left(space(4)+STR0021+Space(96),96) + trans(nQtVeiRes,"@E 999999") + Space(23) + trans(nTotVNFgRes,"@E 999,999,999.99") + trans(nTFretegRes,"@E 999,999.99")+" "+trans(nTFreResSCo,"@E 99,999,999.99")+" "+trans(nTFreResCCo,"@E 99,999,999.99") //"T o t a l  d e  R e s e r v a d o "
	@ nLin++,00 psay Repl("-",220)
Endif

if mv_par05 == 1 .or. mv_par05 == 2 .or. mv_par05 == 3

	If cTipoVV == "0" .and.  nQtVeiNov > 0//novo
		nLin := nLin + 2
		@ nLin++,00 psay Repl("-",220)
		@ nLin++,00 psay left(STR0006 + STR0065+Space(96),96) + trans(nQtVeiNov,"@E 999999") + Space(23) + trans(nTotVNFgNov,"@E 999,999,999.99") + trans(nTFretegNov,"@E 999,999.99") +" "+ trans(nTFreNovSCo,"@E 99,999,999.99") +" "+ trans(nTFreNovCCo,"@E 99,999,999.99") //"T O T A L   D E   "
		@ nLin++,00 psay Repl("-",220)

		nQtVeiNov   := 0
		nTotVNFgNov  := 0
		nTFretegNov  := 0
		nTFreNovSCo  := 0
		nTFreNovCCo  := 0
		nTFreNovTIn  := 0
		
	ElseIf cTipoVV == "1" .and. nQtVeiUsa > 0 // Usado
		nLin := nLin + 2
		@ nLin++,00 psay Repl("-",220)
		@ nLin++,00 psay left(STR0006 + STR0066+Space(96),96) + trans(nQtVeiUsa,"@E 999999") + Space(23) + trans(nTotVNFgUsa,"@E 999,999,999.99") + trans(nTFretegUsa,"@E 999,999.99") +" "+ trans(nTFreUsaSCo,"@E 99,999,999.99") +" "+ trans(nTFreUsaCCo,"@E 99,999,999.99") //"T O T A L   D E   "
		@ nLin++,00 psay Repl("-",220)
				
		nQtVeiUsa   := 0
		nTotVNFgUsa  := 0
		nTFretegUsa  := 0
		nTFreUsaSCo  := 0
		nTFreUsaCCo  := 0
		nTFreUsaTIn  := 0
	endif

Endif

nLin := nLin + 5
@ nLin++,00 psay Repl("-",220)
@ nLin++,00 psay left(STR0011+Space(96),96) + trans(nQtdVeig,"@E 999999") + Space(23) + trans(nTotVNFg,"@E 999,999,999.99") + trans(nTFreteg,"@E 999,999.99")+""+ trans(nTotCUSCo,"@E 99,999,999.99")  + trans(nTotCUCCo,"@E 99,999,999.99") //"T O T A L   G E R A L   D E   V E I C U L O S"
@ nLin++,00 psay Repl("-",220)

nLin++
@ nLin,01 psay &cNormal + " "

Ms_Flush()

Set Printer to
Set Device  to Screen

oObjTempTable:CloseTable()

Return

/*
_____________________________________________________________________________
_____________________________________________________________________________
__+-----------------------------------------------------------------------+__
__¦Funçäo    ¦ LeDriver ¦ Autor ¦ Tecnologia            ¦ Data ¦ 17/05/00 ¦__
__+----------+------------------------------------------------------------¦__
__¦Descriçao ¦ Emissao da Nota Fiscal de Balcao                           ¦__
__+----------+------------------------------------------------------------¦__
__¦Parametros¦                                                            ¦__
__+----------+------------------------------------------------------------¦__
__¦Uso       ¦ Geral                                                      ¦__
__+-----------------------------------------------------------------------+__
_____________________________________________________________________________
_____________________________________________________________________________
*/
Static Function LEDriver()
Local aSettings := {}
Local cStr, cLine, i

if !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
Endif
Return aSettings

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPergº Autor ³ Rogerio Vaz Melonioº Data ³  18/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descricao ³ Acompanhamento de Vendas por Recepcioniosta                ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(cPerg+"02") .and. SX1->X1_TIPO == "D"
	dbSeek(cPerg+"01")
	While !Eof() .and. SX1->X1_GRUPO == cPerg
		RecLock("SX1",.f.,.t.)
		dbDelete()
		MsUnLock()
		DbSkip()
	EndDo
EndIf

// Grupo/Ordem/Pergunta/Pergunta Espanhol/Pergunta Ingles/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSpa1/DefEng1/Cnt01/Var02/Def02/DefSpa2/DefEng2/Cnt02/Var03/Def03/DefSpa3/DefEng3/Cnt03/Var04/Def04/DefSpa4/DefEng4/Cnt04/Var05/Def05/DefSpa5/DefEng5/Cnt05/F3/GRPSX6
aAdd(aRegs,{cPerg,"01",STR0058,"","","mv_ch1","C",FWSizeFilial(),0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","XM0","",""})
aAdd(aRegs,{cPerg,"02",STR0059,"","","mv_ch2","C",FWSizeFilial(),0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","XM0","",""})
aAdd(aRegs,{cPerg,"03",STR0051,"","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04",STR0052,"","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05",STR0054,"","","mv_ch5","N",01,0,2,"C","","mv_par05",STR0072,"","","","",STR0073,"","","","",STR0071,"","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cPerg,"06",STR0067,"","","mv_ch6","N",01,0,0,"C","","mv_par06",STR0069,"","","","",STR0070,"","","","",STR0071,"","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cPerg,"07",STR0068,"","","mv_ch7","N",01,0,0,"C","","mv_par07",STR0069,"","","","",STR0070,"","","","",STR0071,"","","","","","","","","","","","","","","","","","","" } )
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
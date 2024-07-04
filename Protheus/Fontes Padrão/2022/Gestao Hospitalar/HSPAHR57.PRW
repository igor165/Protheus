#INCLUDE "HSPAHR57.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR57 บ       ณ MARCELO JOSE       บ Data ณ 28/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DE PERMANENCIA POR CONVENIO                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHR57()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Total de Movimenta็๕es"
Local cPict          := ""
Local cTitulo        := STR0003
Local nLin           := 80
Local imprime        := .T.
Local aOrd           := {}
Local cDataDe
Local cDataAte 
Local cSetorDe 
Local cSetorAte
Local cConvDe  
Local cConvAte 
Local cSltPag  
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private Tamanho     := "P"
Private NomeProg    := "HSPAHR57" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1} //
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := NomeProg
Private nTam        := 132
Private Titulo       := cDesc3
Private Cabec1       := STR0004 //"Tipo de Leito    Admissoes   Saidas   Total de dias"
Private Cabec2       := ""
Private cString      := ""
Private cPerg        := "HSPR57"
Private cCODIMP      := ""
Private nMaxLin      := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte(cPerg,.T.)
	Return( NIL )
EndIf
cDataDe   := mv_par01
cDataAte  := mv_par02
cSetorDe  := mv_par03
cSetorAte := mv_par04
cConvDe   := mv_par05
cConvAte  := mv_par06
cSltPag   := mv_par07
 
nMaxLin := HS_MaxLin(cCODIMP)

 wnrel := SetPrint("GB1", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GN4")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, Titulo)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRUNREPREL บ       ณ MARCELO JOSE       บ Data ณ 28/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXECUTA A IMPRESSAO DO RELATORIO                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RunReport()
Local bWhile    := {||!Eof()},;
cAliasQRY := "R57QRY",;
cQuery    := "",;
nCtaFor   := 1,;
aMatImp   := {},;
nPos      := 0,;
cQbrSetor := "",;
cQbrConve := "",;
nSubtSet1 := 0, nSubtSet2 := 0, nSubtSet3 := 0,;
nSubtCon1 := 0, nSubtCon2 := 0, nSubtCon3 := 0,;
nTotger1  := 0, nTotger2  := 0, nTotger3  := 0,;
cDescTpLt := "", cDescModel := ""
Local lImprime  := .T.              
Local cAltaObt  := TRIM(GETMV("MV_TPALTA"))
Local cAltaTra  := TRIM(GETMV("MV_ALTATRA"))
Private nLin    := nMaxLin * 2

cQuery := " SELECT 'ADM' AS COL, GB1_CODLOC, GA9.GA9_NOME, GCZ.GCZ_CODCON, GAV.GAV_TIPO, GAV.GAV_MODELO, GCS.GCS_NOMLOC, COUNT(DISTINCT GB1_REGATE||GB1_CODLOC) QTDE"
cQuery += " FROM " + RetSQLName("GB1") + " GB1 "
cQuery += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'  AND GCZ_REGATE = GB1.GB1_REGATE"
cQuery += " AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cQuery += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' AND GCY.GCY_REGATE = GB1.GB1_REGATE "
cQuery += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC
cQuery += " AND GAV.GAV_QUARTO = GB1.GB1_QUARTO	AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_TIPO <> '2' AND GAV.GAV_TIPO <> '7' AND GAV.GAV_ESTATI = '1' "
cQuery += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "
cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cQuery += " WHERE "
cQuery += " GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE " 
cQuery += " AND (GB1.GB1_DATAE <= '" + DTOS(MV_PAR02) + "' AND GB1.GB1_DATAE >= '" + DTOS(MV_PAR01) + "')"
cQuery += " AND GB1.GB1_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += " AND GB1.GB1_REGATE||GB1.GB1_DATAE||GB1.GB1_HORAE NOT IN (SELECT GB1_REGATE||MIN(GB1_DATAE||GB1_HORAE) FROM " + RetSQLName("GB1") + " GB1 GROUP BY GB1_REGATE) "
cQuery += " GROUP BY GB1_CODLOC, GA9.GA9_NOME, GCZ.GCZ_CODCON,GAV.GAV_TIPO, GAV.GAV_MODELO, GCS.GCS_NOMLOC "
cQuery += " UNION "
cQuery += " SELECT 'SAI' AS COL, GB1_CODLOC, GA9.GA9_NOME, GCZ.GCZ_CODCON, GAV.GAV_TIPO, GAV.GAV_MODELO, GCS.GCS_NOMLOC, COUNT(DISTINCT GB1_REGATE||GB1_CODLOC) QTDE"
cQuery += " FROM " + RetSQLName("GB1") + " GB1 "
cQuery += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'  AND GCZ_REGATE = GB1.GB1_REGATE"
cQuery += " AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cQuery += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA IN ('"+ cAltaObt + cAltaTra +"') AND GCY.GCY_REGATE = GB1.GB1_REGATE "
cQuery += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC
cQuery += " AND GAV.GAV_QUARTO = GB1.GB1_QUARTO	AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_TIPO <> '2' AND GAV.GAV_TIPO <> '7' AND GAV.GAV_ESTATI = '1' "
cQuery += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "
cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cQuery += " WHERE "
cQuery += " GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE "  
cQuery += " AND (GB1.GB1_DATAS <= '" + DTOS(MV_PAR02) + "' AND GB1.GB1_DATAS >= '" + DTOS(MV_PAR01) + "')"
cQuery += " AND GB1.GB1_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += " GROUP BY GB1_CODLOC,GA9.GA9_NOME,GCZ.GCZ_CODCON,GAV.GAV_TIPO, GAV.GAV_MODELO, GCS.GCS_NOMLOC"


cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
DbSelectArea(cAliasQRY)

If Eof()
  HS_MsgInf("Nenhum dado foi encontrado para a selecao efetuada.", "Aten็ใo", "Rotina de execucao do relatorio")
  DbSelectArea(cAliasQRY)
  DbCloseArea()
  Return()
 EndIf

ProcRegua(1000)  // seta o tamanho da regua

While (cAliasQRY)->(Eval(bWhile))
	
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif 

	If (cAliasQRY)->GAV_TIPO == "0"
		cDescTpLt := STR0007 //"Bercario"
	ElseIf (cAliasQRY)->GAV_TIPO == "1"
		cDescTpLt := STR0008 //"Posto"
	ElseIf (cAliasQRY)->GAV_TIPO == "3"
		cDescTpLt := STR0009 //"Ambulatorio"
	ElseIf (cAliasQRY)->GAV_TIPO == "4"
		cDescTpLt := STR0010 //"U.T.I."
	ElseIf (cAliasQRY)->GAV_TIPO == "5"
		cDescTpLt := STR0011 //"Pre-Operatorio"
	EndIf
	                               
	If (cAliasQRY)->GAV_MODELO == "0"
	 cDescModel := "AMBULATORIO"
	ElseIf (cAliasQRY)->GAV_MODELO == "1"
  cDescModel := "ENFERMARIA"	
	ElseIf (cAliasQRY)->GAV_MODELO == "2"
  cDescModel := "APARTAMENTO"	  
	ElseIf (cAliasQRY)->GAV_MODELO == "3"
  cDescModel := "SUITE"	    
	ElseIf (cAliasQRY)->GAV_MODELO == "4"
  cDescModel := "SALA CIRURGICA"	      
	ElseIf (cAliasQRY)->GAV_MODELO == "5"
  cDescModel := "UTI"	      
	ElseIf (cAliasQRY)->GAV_MODELO == "6"
  cDescModel := "UTI-NEO"	      
	ElseIf (cAliasQRY)->GAV_MODELO == "7"
  cDescModel := "SEMI-UTI"	        
 EndIf 	
 
	nPos:= aScan(aMatImp, {| aVet | aVet[1] == (cAliasQRY)->GB1_CODLOC;
	.And. aVet[3] == (cAliasQRY)->GCZ_CODCON;
	.And. aVet[5] == (cAliasQRY)->GAV_TIPO;
 .And. aVet[6] == (cAliasQRY)->GAV_MODELO	})
	
	If nPos <= 0
		aadd(aMatImp,{ (cAliasQRY)->GB1_CODLOC,;
		(cAliasQRY)->GCS_NOMLOC,;
		(cAliasQRY)->GCZ_CODCON,;
		(cAliasQRY)->GA9_NOME,;
		(cAliasQRY)->GAV_TIPO,;
		(cAliasQRY)->GAV_MODELO,;
		IIf((cAliasQRY)->COL=='ADM',QTDE,0),;
		IIf((cAliasQRY)->COL=='SAI',QTDE,0),;
		FS_TOTDIA((cAliasQRY)->GB1_CODLOC,(cAliasQRY)->GCZ_CODCON, (cAliasQRY)->GAV_TIPO, (cAliasQRY)->GAV_MODELO) ,;
		cDescTpLt,;
		cDescModel})
	Else
		 IIf((cAliasQRY)->COL=='ADM',aMatImp[nPos,7] :=QTDE, aMatImp[nPos,8] :=QTDE)
	EndIf
	
	DbSkip()
EndDo

DbSelectArea(cAliasQRY)
dbCloseArea()

ProcRegua(Len(aMatImp))  // seta o tamanho da regua

For nCtaFor = 1 to Len(aMatImp)

 IncProc("Imprimindo " + Alltrim(Str(nCtaFor)) + " de " + Alltrim(Str(Len(aMatImp))))
	
	If lAbortPrint
		@nLin,00 PSAY STR0012 //"INTERROMPIDO PELO USUARIO"
		Exit
	Endif
	
	If nLin > 60
		
		If nCtaFor > 1
			@nLin+1,00 PSAY STR0013 //"Continua..."
		EndIf
		
		Fs_Cabec()
		If nCtaFor > 1
			@ 08,00 PSAY STR0014 //"...continuacao"
			nLin++
		Else
			nLin++
		EndIf
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณcontrole de quebra por SETOR   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cQbrSetor != aMatImp[nCtaFor,1]
		
		If nCtaFor > 1
			@ nLin,00  Psay STR0015 //"Total Convenio"
			@ nLin,20  Psay Str(nSubtCon1,6,0)
			@ nLin,29  Psay Str(nSubtCon2,6,0)
			@ nLin,45  Psay Str(nSubtCon3,6,0)
			nLin = nLin + 2
			@ nLin,00  Psay STR0016 //"Total  S E T O R"
			@ nLin,20  Psay Str(nSubtSet1,6,0)
			@ nLin,29  Psay Str(nSubtSet2,6,0)
			@ nLin,45  Psay Str(nSubtSet3,6,0)
			nLin++
			@nLin, 000 PSAY __PRTTHINLINE()
			nLin = nLin + 2
		EndIf

  If nCtaFor > 1
   If MV_PAR07 == 2
  		Fs_Cabec()
  	EndIf	       
 	EndIf
		
		@ nLin,00  Psay STR0017 + aMatImp[nCtaFor,1] + " - " + aMatImp[nCtaFor,2] //"S E T O R ==> "
		nLin := nLin + 2
		@ nLin,00  Psay STR0018 + aMatImp[nCtaFor,3] + " - " + aMatImp[nCtaFor,4] //"Convenio => "
		nLin++
		
		cQbrSetor :=	aMatImp[nCtaFor,1]
		cQbrConve := aMatImp[nCtaFor,3]
		
		nSubtSet1 := 0; nSubtSet2 := 0; nSubtSet3 := 0; nSubtCon1 := 0; nSubtCon2 := 0; nSubtCon3 := 0
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณcontrole de quebra por CONVENIOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cQbrConve != aMatImp[nCtaFor,3]
		
		@ nLin,00  Psay STR0015 //"Total Convenio"
		@ nLin,20  Psay Str(nSubtCon1,6,0)
		@ nLin,29  Psay Str(nSubtCon2,6,0)
		@ nLin,45  Psay Str(nSubtCon3,6,0)
		nLin := nLin+2
		
		nSubtCon1 := 0; nSubtCon2 := 0; nSubtCon3 := 0
		@ nLin,00  Psay STR0018 + aMatImp[nCtaFor,3] + " - " + aMatImp[nCtaFor,4] //"Convenio => "
		nLin++
		cQbrConve := aMatImp[nCtaFor,3]
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ IMPRESSAO DOS ITENS           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ nLin,00  Psay aMatImp[nCtaFor,11]
	@ nLin,20  Psay Str(aMatImp[nCtaFor, 7],6,0)
	@ nLin,29  Psay Str(aMatImp[nCtaFor, 8],6,0)
	@ nLin,45  Psay Str(aMatImp[nCtaFor, 9],6,0)
	nLin++
	nSubtSet1 := nSubtSet1 + aMatImp[nCtaFor,7]
	nSubtSet2 := nSubtSet2 + aMatImp[nCtaFor,8]
	nSubtSet3 := nSubtSet3 + aMatImp[nCtaFor,9]
	nSubtCon1 := nSubtCon1 + aMatImp[nCtaFor,7]
	nSubtCon2 := nSubtCon2 + aMatImp[nCtaFor,8]
	nSubtCon3 := nSubtCon3 + aMatImp[nCtaFor,9]    
	nTotger1  := nTotger1  + aMatImp[nCtaFor,7]
	nTotger2  := nTotger2  + aMatImp[nCtaFor,8]
	nTotger3  := nTotger3  + aMatImp[nCtaFor,9]
	
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImpressao dos TOTAIS FINAIS    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nLin,00  Psay STR0015 //"Total Convenio"
@ nLin,20  Psay Str(nSubtCon1,6,0)
@ nLin,29  Psay Str(nSubtCon2,6,0)
@ nLin,45  Psay Str(nSubtCon3,6,0)
nLin := nLin + 2
@ nLin,00  Psay STR0016 //"Total  S E T O R"
@ nLin,20  Psay Str(nSubtSet1,6,0)
@ nLin,29  Psay Str(nSubtSet2,6,0)
@ nLin,45  Psay Str(nSubtSet3,6,0)
nLin++
@nLin, 000 PSAY __PRTTHINLINE()
nLin++
@ nLin,00  Psay STR0019 //"TOTAL GERAL ==> "
@ nLin,20  Psay Str(nTotger1,6,0)
@ nLin,29  Psay Str(nTotger2,6,0)
@ nLin,45  Psay Str(nTotger3,6,0)
nLin++
@nLin, 000 PSAY __PRTTHINLINE()

 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return()      

Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return() 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TOTDIA บ       ณ MARCELO JOSE       บ Data ณ 21/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CALCULA A QTDE DE DIAS DE OCUPACAO DOS PACIENTES NO LEITO  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_TOTDIA(cSet,cConv, cTipLei, cModel)
 Local aArea	   := GetArea()
 Local nRet     := 0
 Local cSql     := ""
        
 cSql:= "SELECT GB1_DATAE, GB1_DATAS" + ;
               "FROM " + RetSqlName("GB1") + " GB1 " + ;
               "JOIN " + RetSqlName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_CODLOC = GB1_CODLOC AND GAV_QUARTO = GB1_QUARTO AND GAV_LEITO = GB1_LEITO AND GAV_ESTATI = '1' AND GAV.GAV_TIPO = '" + cTipLei + "'  AND GAV.GAV_MODELO = '" + cModel + "' " + ;
               "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'  AND GCZ.GCZ_REGATE = GB1.GB1_REGATE " + ;
               " AND GCZ.GCZ_CODCON = '" + cConv + "' " + ;
               "WHERE GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' " + ; 
               " 										AND GB1.GB1_CODLOC = '" + cSet + "' " + ; 
               "           AND ((GB1.GB1_DATAE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')"+ ;
               "           OR   (GB1.GB1_DATAS BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'))"+ ;
               "           OR  (GB1.GB1_DATAE < '" + DTOS(MV_PAR02) + "' AND (GB1.GB1_DATAS IS NULL OR GB1.GB1_DATAS > '" + DTOS(MV_PAR02)+ "')) " ;


 cSql := ChangeQuery(cSql)

 dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "QTDLEI", .T., .T.)
 While !Eof()
  If Empty(TRIM(QTDLEI->GB1_DATAS)) .or. STOD(QTDLEI->GB1_DATAS)> IIf(!Empty(MV_PAR02),MV_PAR02,0)
   nRet := nRet + ( MV_PAR02 - IIf(STOD(QTDLEI->GB1_DATAE)<MV_PAR01,MV_PAR01,STOD(QTDLEI->GB1_DATAE))) 
  Else
   nRet := nRet + (STOD(QTDLEI->GB1_DATAS) -  IIf(STOD(QTDLEI->GB1_DATAE)>MV_PAR01,STOD(QTDLEI->GB1_DATAE),MV_PAR01))
  EndIf
 
  DbSkip()
 End
 dbCloseArea()           
 RestArea(aArea)
Return(nRet)


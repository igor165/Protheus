#INCLUDE "HSPAHR07.ch"
#include "Protheus.ch"
#include "TopConn.ch"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR07 º       ³ MARCELO JOSE       º Data ³ 03/08/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CONTAS AUDITADAS - POR USUARIO CONVENIO                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HSPAHR07()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"CONTAS AUDITADAS - POR USUARIO CONVENIO"
 Local cCabec1        := STR0004 //"Atendimento  Nome                                       V$ Realizado   V$ Faturado    Diferenca   total    Diferenca Pro/Hon    Diferenca Tax/Dia    Diferenca Mat/Med"
 Local cCabec2        := STR0013 //"                                                                                       R$ Valor   %Perc     R$ Valor   %Perc     R$ Valor   %Perc     R$ Valor   %Perc"     
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60

 Private nLin         := 80
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "G"
 Private limite       := 220
 Private m_pag        := 01
 Private nomeprog     := "HSPAHR07"
 Private nTipo        := 18
 Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHR07"
 Private cString      := "GCZ"
 Private aContas      := {}
 Private cPerg        := "HSPR07"

 Private bWhile     := {||!Eof()}, cAliasQRY := "R07QRY", cRegAte := "", cNome := "", cUsuar := "", cConve := "", lStart := .F.  
 Private nRealiz    := 0, nFatura    := 0, nDifTotVal := 0, nDifTotPer := 0
 Private nDifPH_Val := 0, nDifPH_Per := 0, nDifTD_Val := 0, nDifTD_Per := 0, nDifMM_Val := 0, nDifMM_Per := 0   
 Private nSomaDPH   := 0, nSomaEPH   := 0, nSomaDTD   := 0, nSomaETD   := 0, nSomaDMM   := 0, nSomaEMM   := 0  
 Private nSomaC_DPH := 0, nSomaC_EPH := 0, nSomaC_DTD := 0, nSomaC_ETD := 0, nSomaC_DMM := 0, nSomaC_EMM := 0   
 Private nSomaU_DPH := 0, nSomaU_EPH := 0, nSomaU_DTD := 0, nSomaU_ETD := 0, nSomaU_DMM := 0, nSomaU_EMM := 0  
 Private nTConv0    := 0, nTUsua0    := 0 /* soma do realizado                 */
 Private nTConv1    := 0, nTUsua1    := 0 /* soma do faturado                  */
 Private nTConv2    := 0, nTUsua2    := 0 /* soma do diferenca total em valor  */
 Private nTConv3    := 0, nTUsua3    := 0 /* soma do diferenca total em percen */
 Private nTConv4    := 0, nTUsua4    := 0 /* soma do diferenca pro/hon valor   */
 Private nTConv5    := 0, nTUsua5    := 0 /* soma do diferenca pro/hon percen  */
 Private nTConv6    := 0, nTUsua6    := 0 /* soma do diferenca tax/dia valor   */
 Private nTConv7    := 0, nTUsua7    := 0 /* soma do diferenca tax/dia percen  */
 Private nTConv8    := 0, nTUsua8    := 0 /* soma do diferenca mat/med valor   */
 Private nTConv9    := 0, nTUsua9    := 0 /* soma do diferenca mat/med percen  */

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte(cPerg,.T.)
  Return( Nil )
 EndIf          

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 If nLastKey == 27
  Return( Nil )
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
  Return( Nil )
 Endif
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLinTotal)}, cTitulo)
Return( Nil )


Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLinTotal)

 FS_MontaQ() /* MONTA A QUERY */
 DbSelectArea(cAliasQRY)

 If nLin > nMaxLin
  Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
  nLin := 9
 EndIf

	While (cAliasQRY)->(Eval(bWhile))
  If nLin > nMaxLin
   If lStart
    nLIn++
    @ nLin,01 Psay STR0007 //"Continua..."
   EndIf
   Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
   nLin := 9
   If lStart
    @ nLin,000 PSAY STR0008 //"...Continuacao"
    nLin++
   EndIf
  Endif

  If (cNome # (cAliasQRY)->NOME)  /* verifica se mudou o PACIENTE */
   If lStart /* se nao for a primeira vez apresenta o paciente */
    FS_MudouP()
   EndIf  
   cRegAte    := (cAliasQRY)->REGATE
   cNome      := (cAliasQRY)->NOME
   IF cUsuar # (cAliasQRY)->USUAR /* verifica se mudou de USUARIO */
    If lStart /* se nao for a primeira vez */
     FS_MudouC()
     FS_MudouU()
    EndIf 
    cUsuar  := (cAliasQRY)->USUAR
    nLin++
    @ nLin,000 PSAY STR0009 + cUsuar //"U s u a r i o: "
    nLin += 2
    cConve := (cAliasQRY)->CONVE
    @ nLin,000 PSAY STR0010 + cConve //"C o n v e n i o: "
    nLin++
   EndIf 
  EndIf

  IF (cConve # (cAliasQRY)->CONVE) /* verifica se mudou de CONVENIO */
   If lStart /* se nao for a primeira vesz */
    FS_MudouC()
   EndIf 
   cConve := (cAliasQRY)->CONVE
   nLIn += 1
   @ nLin,000 PSAY STR0010 + cConve //"C o n v e n i o: "
   nLin++
  EndIf

  /* soma os dados se nao mudar o paciente */
  nRealiz    := nRealiz  + (cAliasQRY)->D_MATMED + (cAliasQRY)->D_TAXDIA + (cAliasQRY)->D_PROHON 
  nFatura    := nFatura  + (cAliasQRY)->E_MATMED + (cAliasQRY)->E_TAXDIA + (cAliasQRY)->E_PROHON
  nSomaDPH   := nSomaDPH + (cAliasQRY)->D_PROHON
  nSomaEPH   := nSomaEPH + (cAliasQRY)->E_PROHON
  nSomaDTD   := nSomaDTD + (cAliasQRY)->D_TAXDIA
  nSomaETD   := nSomaETD + (cAliasQRY)->E_TAXDIA
  nSomaDMM   := nSomaDMM + (cAliasQRY)->D_MATMED
  nSomaEMM   := nSomaEMM + (cAliasQRY)->E_MATMED

  /* soma dos dados para fechar o convenio */
  nSomaC_DPH := nSomaC_DPH + (cAliasQRY)->D_PROHON
  nSomaC_EPH := nSomaC_EPH + (cAliasQRY)->E_PROHON 
  nSomaC_DTD := nSomaC_DTD + (cAliasQRY)->D_TAXDIA
  nSomaC_ETD := nSomaC_ETD + (cAliasQRY)->E_TAXDIA 
  nSomaC_DMM := nSomaC_DMM + (cAliasQRY)->D_MATMED
  nSomaC_EMM := nSomaC_EMM + (cAliasQRY)->E_MATMED  

  /* soma dos dados para fechar o usuario */
  nSomaU_DPH := nSomaU_DPH + (cAliasQRY)->D_PROHON
  nSomaU_EPH := nSomaU_EPH + (cAliasQRY)->E_PROHON 
  nSomaU_DTD := nSomaU_DTD + (cAliasQRY)->D_TAXDIA
  nSomaU_ETD := nSomaU_ETD + (cAliasQRY)->E_TAXDIA 
  nSomaU_DMM := nSomaU_DMM + (cAliasQRY)->D_MATMED
  nSomaU_EMM := nSomaU_EMM + (cAliasQRY)->E_MATMED  

  lStart  := .T.             

  DbSkip()
 EndDo  
 /******************************************** encerra o loop e inicia a impressao dos dados finais */
 /* fecha pacinte */
 FS_MudouP()
 /* fecha convenio */
 FS_MudouC()
 /* fecha usuario */
 FS_MudouU()

 DbSelectArea(cAliasQRY)
 dbCloseArea()
 
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)



Static Function FS_MontaQ()
	#IFDEF TOP
	 If TCSrvType() <> "AS/400"
 	 cQuery := "SELECT "
 	 cQuery += "GCZ.GCZ_REGATE REGATE, "
 	 cQuery += "GCZ.GCZ_USGERA USUAR, "
 	 cQuery += "GBH.GBH_NOME NOME, "
 	 cQuery += "GA9.GA9_NREDUZ CONVE, "
 	 cQuery += "GE5.GE5_VALDES E_MATMED, "
 	 cQuery += "GE6.GE6_VALDES E_TAXDIA, "
   cQuery += "GE7.GE7_VALDES E_PROHON, "
   cQuery += "GD5.GD5_VALDES D_MATMED, "
 	 cQuery += "GD6.GD6_VALDES D_TAXDIA, "
   cQuery += "GD7.GD7_VALDES D_PROHON "
 	 cQuery += "FROM " + RetSqlName("GCZ") + " GCZ " 
 	 cQuery += "JOIN " + RetSqlName("GBH") + " GBH ON (GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_FILIAL = '" + xFilial( "GBH" ) + "') " 
 	 cQuery += "JOIN " + RetSqlName("GA9") + " GA9 ON (GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_FILIAL = '" + xFilial( "GA9" ) + "') "
 	 cQuery += "LEFT OUTER JOIN " + RetSqlName("GE5") + " GE5 ON (GE5.GE5_NRSEQG = GCZ.GCZ_NRSEQG AND GE5.D_E_L_E_T_ <> '*' AND GE5.GE5_FILIAL = '" + xFilial( "GE5" ) + "' ) "  
 	 cQuery += "LEFT OUTER JOIN " + RetSqlName("GE6") + " GE6 ON (GE6.GE6_NRSEQG = GCZ.GCZ_NRSEQG AND GE6.D_E_L_E_T_ <> '*' AND GE6.GE6_FILIAL = '" + xFilial( "GE6" ) + "' ) "  	 
 	 cQuery += "LEFT OUTER JOIN " + RetSqlName("GE7") + " GE7 ON (GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.D_E_L_E_T_ <> '*' AND GE7.GE7_FILIAL = '" + xFilial( "GE7" ) + "' ) " 
 	 cQuery += "LEFT OUTER JOIN " + RetSqlName("GD5") + " GD5 ON (GD5.GD5_NRSEQG = GCZ.GCZ_NRSEQG AND GD5.D_E_L_E_T_ <> '*' AND GD5.GD5_FILIAL = '" + xFilial( "GD5" ) + "' ) " 
   cQuery += "LEFT OUTER JOIN " + RetSqlName("GD6") + " GD6 ON (GD6.GD6_NRSEQG = GCZ.GCZ_NRSEQG AND GD6.D_E_L_E_T_ <> '*' AND GD6.GD6_FILIAL = '" + xFilial( "GD6" ) + "' ) "  	 
   cQuery += "LEFT OUTER JOIN " + RetSqlName("GD7") + " GD7 ON (GD7.GD7_NRSEQG = GCZ.GCZ_NRSEQG AND GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_FILIAL = '" + xFilial( "GD7" ) + "' ) " 
 	 cQuery += "WHERE "
 	 cQuery += "GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "' " 
   If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
    cQuery += "AND GCZ.GCZ_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	  EndIf
   If !Empty(MV_PAR03) .Or. !Empty(MV_PAR04) 
    cQuery += "AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	 	EndIf
	 	If !Empty(MV_PAR05) .Or. !Empty(MV_PAR06) 
    cQuery += "AND UPPER(GCZ.GCZ_USGERA) BETWEEN '" + UPPER(MV_PAR05) + "' AND '" + UPPER(MV_PAR06) + "' "
	 	EndIf
   cQuery += "ORDER BY 2,4,3"
	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
  EndIf
 #ENDIF 
Return( Nil )



Static Function FS_MudouP()
 nDifTotVal := nRealiz - nFatura
 nDifTotPer := (nFatura / nRealiz) * 100
 nDifPH_Val := ( nSomaDPH - nSomaEPH )
 nDifPH_Per := ( nSomaEPH / nSomaDPH ) * 100
 nDifTD_Val := ( nSomaDTD - nSomaETD )
 nDifTD_Per := ( nSomaETD / nSomaDTD ) * 100
 nDifMM_Val := ( nSomaDMM - nSomaEMM )
 nDifMM_Per := ( nSomaEMM / nSomaDMM ) * 100
 nTConv0    := nTConv0 + nRealiz    
 nTConv1    := nTConv1 + nFatura    
 nTConv2    := nTConv2 + nDifTotVal 
 nTConv4    := nTConv4 + nDifPH_Val 
 nTConv6    := nTConv6 + nDifTD_Val 
 nTConv8    := nTConv8 + nDifMM_Val 
 nLin++
/*
123456789d123456789v123456789t123456789q123456789c123456789s123456789s123456789o123456789n123456789c123456789d123456789v123456789
                                                      123456789d123 123456789d123 123456789d12345
*/
 @ nLin,000 PSAY cRegAte
 @ nLin,013 PSAY cNome
 @ nLin,056 PSAY Str(nRealiz   ,12,2)
 @ nLin,070 PSAY Str(nFatura   ,12,2)                                                 
 @ nLin,083 PSAY Str(nDifTotVal,12,2)
 
 @ nLin,098 PSAY Str(nDifTotPer,7,2)
 @ nLin,107 PSAY Str(nDifPH_Val,12,2)
 @ nLin,120 PSAY Str(nDifPH_Per,7,2)
 @ nLin,127 PSAY Str(nDifTD_Val,12,2)
 @ nLin,140 PSAY Str(nDifTD_Per,7,2)
 @ nLin,148 PSAY Str(nDifMM_Val,12,2)
 @ nLin,161 PSAY Str(nDifMM_Per,7,2)
 nRealiz    := 0
 nFatura    := 0
 nDifTotVal := 0
 nDifTotPer := 0
 nDifPH_Val := 0
 nDifPH_Per := 0 
 nDifTD_Val := 0
 nDifTD_Per := 0 
 nDifMM_Val := 0
 nDifMM_Per := 0 
 nSomaDPH   := 0
 nSomaEPH   := 0
 nSomaDTD   := 0
 nSomaETD   := 0
 nSomaDMM   := 0
 nSomaEMM   := 0
Return( Nil )




Static Function FS_MudouC()
 nTConv3 := ( nTConv1 / nTconv0 ) * 100
 nTConv5 := ( nSomaC_EPH / nSomaC_DPH ) * 100
 nTConv7 := ( nSomaC_ETD / nSomaC_DTD ) * 100
 nTConv9 := ( nSomaC_EMM / nSomaC_DMM ) * 100
 nTUsua0 := nTUsua0 + nTConv0
 nTUsua1 := nTUsua1 + nTConv1
 nTUsua2 := nTUsua2 + nTConv2
 nTUsua4 := nTUsua4 + nTConv4
 nTUsua6 := nTUsua6 + nTConv6
 nTUsua8 := nTUsua8 + nTConv8
 nLin += 2
 @ nLin,000 PSAY STR0011 + ALLTRIM(cConve) //"==> Total do convenio: "

 @ nLin,055 PSAY Str(nTConv0   ,12,2)
 @ nLin,069 PSAY Str(nTConv1   ,12,2)                                                 
 @ nLin,082 PSAY Str(nTConv2   ,12,2)

 @ nLin,097 PSAY Str(nTConv3,7,2)
 @ nLin,106 PSAY Str(nTConv4,12,2)
 @ nLin,119 PSAY Str(nTConv5,7,2)
 @ nLin,126 PSAY Str(nTConv6,12,2)
 @ nLin,139 PSAY Str(nTConv7,7,2)
 @ nLin,147 PSAY Str(nTConv8,12,2)
 @ nLin,160 PSAY Str(nTConv9,7,2)
 nLin++
 nTConv0    := 0 
 nTConv1    := 0 
 nTConv2    := 0 
 nTConv3    := 0 
 nTConv4    := 0 
 nTConv5    := 0 
 nTConv6    := 0 
 nTConv7    := 0 
 nTConv8    := 0 
 nTConv9    := 0 
 nSomaC_DPH := 0
 nSomaC_EPH := 0
 nSomaC_DTD := 0
 nSomaC_ETD := 0
 nSomaC_DMM := 0
 nSomaC_EMM := 0
Return( Nil )




Static Function FS_MudouU()
 nTUsua3 := ( nTUsua1 / nTUsua0 ) * 100
 nTUsua5 := ( nSomaU_EPH / nSomaU_DPH ) * 100
 nTUsua7 := ( nSomaU_ETD / nSomaU_DTD ) * 100
 nTUsua9 := ( nSomaU_EMM / nSomaU_DMM ) * 100
 nLin += 1
 @ nLin,000 PSAY STR0012 + ALLTRIM(cUsuar) //"==> Total do usuario: "
 
 @ nLin,055 PSAY Str(nTUsua0   ,12,2)
 @ nLin,069 PSAY Str(nTUsua1   ,12,2)                                                 
 @ nLin,082 PSAY Str(nTUsua2   ,12,2)
 
 @ nLin,097 PSAY Str(nTUsua3,7,2)
 @ nLin,106 PSAY Str(nTUsua4,12,2)    
 @ nLin,119 PSAY Str(nTUsua5,7,2)
 @ nLin,126 PSAY Str(nTUsua6,12,2)
 @ nLin,139 PSAY Str(nTUsua7,7,2)
 @ nLin,147 PSAY Str(nTUsua8,12,2)
 @ nLin,160 PSAY Str(nTUsua9,7,2)
 nLin++
 @ nLin,000 PSAY REPLI("_",220)
 nLin++    
 cUsuar  := (cAliasQRY)->USUAR
 nTUsua0 := 0
 nTUsua1 := 0
 nTUsua2 := 0 
 nTUsua3 := 0
 nTUsua4 := 0
 nTUsua5 := 0
 nTUsua6 := 0
 nTUsua7 := 0
 nTUsua8 := 0
 nTUsua9 := 0   
 nSomaU_DPH := 0
 nSomaU_EPH := 0
 nSomaU_DTD := 0
 nSomaU_ETD := 0
 nSomaU_DMM := 0
 nSomaU_EMM := 0
Return( Nil )

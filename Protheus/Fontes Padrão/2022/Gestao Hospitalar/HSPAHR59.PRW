#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR56 บ Autor ณ Monica Y. Miyamoto บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valor Minimo/Teto Mensal                                   บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR59()

 Local cDesc1 := "Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := "de acordo com os parametros informados pelo usuario."
 Local cDesc3 := "Valor Minimo/Teto Mensal - Ref: "
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := "                                                                                                                           Ult. Mes"
 Private Cabec2 := "Prestador                                Setor                                                Minimo           Teto      Fechamento"
 //                 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR59" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1} //
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132

 Private dDatOrc_De  := ""
 Private dDatOrc_Ate := ""
 Private nStatus     := 0
 Private nImpDes     := 0
 Private nclassif    := 0

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Referencia ?                                              ณ
 //ณ MV_PAR02	Do Prestador ?                                            ณ
 //ณ MV_PAR03	Ate Prestador ?                                           ณ
 //ณ MV_PAR04	Impressora ?                                              ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 cPerg := "HSPR59"
 If !Pergunte(cPerg,.T.)
  return
 oReport := ReportDef()
 oReport:PrintDialog()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
             
 cMesRef  := mv_par01
 cPreIni  := mv_par02
 cPreFin  := mv_par03
 cSetImp  := mv_par04 

 Titulo := cDesc3 + mv_par01
 
 wnrel := SetPrint("GAZ", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn,"GAZ")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Monica Y. Miyamoto บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()        
 Local   cSql    := "", nGAZValMin :=0 , nGAZValMax :=0
 Local   cAnomes := Substr(cMesRef, 4, 4)+Substr(cMesRef, 1, 2)
 Local   nValMax := 0, nValMin := 0, lImprime:= .T., cCodLoc :=""
 Private nLin    := nMaxLin * 2

 cSQL := "SELECT GAZ.GAZ_CODPRE , GAZ.GAZ_FANPRE, GAZ.GAZ_CTLOCM, GAZ.GAZ_VALMAX, GAZ.GAZ_VLMAXD, GAZ.GAZ_VALMIN, GAZ.GAZ_VLMIND "
 cSQL += " FROM " + RetSQLName("GAZ") + " GAZ "
 cSQL += " WHERE GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' " 
 cSQL += " AND (GAZ.GAZ_CTLOCM = '0' OR GAZ.GAZ_CTLOCM = '1')" // desconsidera os "SEM CONTROLE"
 If !Empty(cPreIni)
  cSQL += " AND GAZ.GAZ_CODPRE >='"+ cPreIni + "'"
 EndIf
 If !Empty(cPreFin)
  cSQL += " AND GAZ.GAZ_CODPRE <='"+ cPreFin + "'"
 EndIf
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 If Eof()
  HS_MsgInf("Nenhum dado foi encontrado para a selecao efetuada.", "Aten็ใo", "Rotina de execucao do relatorio")
  DbSelectArea("QRY")
  DbCloseArea()
  Return()
 EndIf
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 SetRegua(1000)
 DbSelectArea("QRY")
 DbGoTop()
 While !EOF()                                                                                
  IncRegua()

  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  @nLin, 000 PSAY QRY->GAZ_CODPRE  
  @nLin, 007 PSAY "-"
  @nLin, 009 PSAY QRY->GAZ_FANPRE
  If HS_CountTB("GEG","GEG_ANOMES  = '" +Substr(cMesRef, 4, 4)+Substr(cMesRef, 1, 2)+ "' AND GEG_CODPRE ='" + QRY->GAZ_CODPRE + "'")  > 0
	   // jแ foi pago, pega valores da GEG
	 	 cSQL := "SELECT GEG.GEG_ANOMES, GEG.GEG_CODPRE, GEG.GEG_CODLOC, GEG.GEG_VALMIN, GEG.GEG_VALMAX
			 cSQL += " FROM " + RetSQLName("GEG") + " GEG "
			 cSQL += " WHERE GEG.GEG_FILIAL = '" + xFilial("GEG") + "' AND GEG.D_E_L_E_T_ <> '*' " 
		  cSQL += " AND GEG.GEG_CODPRE ='"+ QRY->GAZ_CODPRE + "'"
		  cSQL += " AND GEG.GEG_ANOMES ='"+ Substr(cMesRef, 4, 4)+Substr(cMesRef, 1, 2) + "'"
			 cSQL := ChangeQuery(cSQL)
	 	 TCQUERY cSQL NEW ALIAS "QRYGEG"
			 DbSelectArea("QRYGEG")
    While !EOF() 
			  If Eof()
	      @nLin, 0110 PSAY "SEM INFORMACAO"
	    Else
	     nValMax:=QRYGEG->GEG_VALMAX
	     nValMin:=QRYGEG->GEG_VALMIN
	    EndIf 
		   @nLin, 040 PSAY QRYGEG->GEG_CODLOC
		   If !Empty(QRYGEG->GEG_CODLOC)
		    @nLin, 043 PSAY "-"
		   EndIf
		   @nLin, 045 PSAY HS_IniPadr("GCS",1,	QRYGEG->GEG_CODLOC,"GCS_NOMLOC")
 		  @nLin, 089 PSAY TRANSFORM(nValMin, "@E  9999,999.99")
 	   @nLin, 105 PSAY TRANSFORM(nValMax, "@E  9999,999.99") 
 	   FS_MesRef(QRYGEG->GEG_CODPRE)
     nLin++       
     lImprime := .F.   
     DbSelectArea("QRYGEG")
     DbSkip()           
    End 
    DbSelectArea("QRYGEG")
	   DbCloseArea()
	  Else 
   DbSelectArea("QRY")
   // nใo jแ foi pago, pega valores da GAZ - se ctlocm=0 ou da GEF - se ctlocm=1
	  If QRY->GAZ_CTLOCM == "0" //nใo - imprime valores do GAZ
	   If QRY->GAZ_VALMAX >0
	    nValMax:=QRY->GAZ_VALMAX
	   Else                   
	    If !Empty(cMesRef)                     
  	   cAnoMes:=Substr(cMesRef, 4, 4)+Substr(cMesRef, 1, 2)
	     nGAZValMax := QRY->GAZ_VLMAXD
	     nValMax:=nGAZValMax * F_UltDia(STOD(cAnoMes+"01"))
	    Else
	     nValMax:=0	    
	    EndIf 
	  EndIf  
	   If QRY->GAZ_VALMIN >0
	    nValMin:=QRY->GAZ_VALMIN
	   Else
	    If !Empty(cMesRef)                     
 		   cAnoMes:=Substr(cMesRef, 4, 4)+Substr(cMesRef, 1, 2)
	     nGAZValMin := QRY->GAZ_VLMIND
	     nValMin:= nGAZValMin * F_UltDia(STOD(cAnoMes+"01"))
	    Else
	     nValMax:=0	    
	    EndIf
	   EndIf  
	  ElseIf QRY->GAZ_CTLOCM == "1"
	   //imprime valores do GEF
			 cSQL := "SELECT GEF.GEF_CODLOC, GEF.GEF_DATVIG, GEF.GEF_VALMAX, GEF.GEF_VLMAXD, GEF.GEF_VALMIN, GEF.GEF_VLMIND "
			 cSQL += " FROM " + RetSQLName("GEF") + " GEF "
			 cSQL += " WHERE GEF.GEF_FILIAL = '" + xFilial("GEF") + "' AND GEF.D_E_L_E_T_ <> '*' " 
		  cSQL += " AND GEF.GEF_CODPRE ='"+ QRY->GAZ_CODPRE + "'"
		  cSQL += " ORDER BY GEF.GEF_CODPRE, GEF.GEF_CODLOC, GEF.GEF_DATVIG DESC"
			 cSQL := ChangeQuery(cSQL)
			
	 	 TCQUERY cSQL NEW ALIAS "QRYGEF"
			 DbSelectArea("QRYGEF")
			 If Eof()
			  //HS_MsgInf("Nenhum dado foi encontrado para a selecao efetuada.", "Aten็ใo", "Rotina de execucao do relatorio")
			  DbSelectArea("QRYGEF")
			  DbCloseArea()
			 Else             
			  lImprime := .T.
			  DbGoTop()                
			  cCodLoc:=" "
     While !EOF() 
      If QRYGEF->GEF_CODLOC <> cCodLoc			  
					  @nLin, 040 PSAY QRYGEF->GEF_CODLOC
					  If !Empty(QRYGEF->GEF_CODLOC)
					   @nLin, 043 PSAY "-"
					  EndIf
					  @nLin, 045 PSAY HS_IniPadr("GCS",1,	QRYGEF->GEF_CODLOC,"GCS_NOMLOC")
				   If QRYGEF->GEF_VALMAX >0
				    nValMax:=QRYGEF->GEF_VALMAX
				   Else
				    nValMax:=QRYGEF->GEF_VLMAXD * F_UltDia(STOD(cAnoMes+"01"))
				   EndIf  
				   If QRYGEF->GEF_VALMIN >0
				    nValMin:=QRYGEF->GEF_VALMIN
				   Else
				    nValMin:=QRYGEF->GEF_VLMIND * F_UltDia(STOD(cAnoMes+"01"))
				   EndIf  
		 		  @nLin, 089 PSAY TRANSFORM(nValMin, "@E  9999,999.99")
		 	   @nLin, 105 PSAY TRANSFORM(nValMax, "@E  9999,999.99") 
		 	   FS_MesRef(QRY->GAZ_CODPRE)
	      nLin++       
	      lImprime := .F.              
	 			  DbSelectArea("QRYGEF")              
	 			  cCodLoc := QRYGEF->GEF_CODLOC 			  
      EndIf
	     DbSkip()
		   End
		   DbCloseArea()
			 EndIf                            
	  Endif
  Endif
  If lImprime
 		@nLin, 089 PSAY TRANSFORM(nValMin, "@E 9999,999.99")
	  @nLin, 105 PSAY TRANSFORM(nValMax, "@E 9999,999.99")
	  FS_MesRef(QRY->GAZ_CODPRE)
  EndIf                     
  DbSelectArea("QRY")
  If lImprime
   nLin++ 
  EndIf
  lImprime := .T.
  DbSkip()               
 End  
 DbSelectArea("QRY")
 DbCloseArea()
  
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
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Monica Y. Miyamoto บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 9
Return()   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MesRef บ Autor ณ Monica Y. Miyamoto บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MesRef(cPrest)
Local cSQL:=""

 //busca o mes/ano do ultimo fechamento para esse prestador
 cSQL := "SELECT MAX(GEG.GEG_ANOMES) GEGREF
 cSQL += " FROM " + RetSQLName("GEG") + " GEG "
 cSQL += " WHERE GEG.GEG_FILIAL = '" + xFilial("GEG") + "' AND GEG.D_E_L_E_T_ <> '*' " 
 cSQL += " AND GEG.GEG_CODPRE ='"+ cPrest + "'"
 cSQL := ChangeQuery(cSQL)	
	TCQUERY cSQL NEW ALIAS "QRYREF"
	DbSelectArea("QRYREF")
	DbGoTop()
	If !Empty(QRYREF->GEGREF)
	 @nLin, 0124 PSAY Substr(QRYREF->GEGREF, 5, 2)+"/"+Substr(QRYREF->GEGREF, 1, 4)
	EndIf  
	DbSelectArea("QRYREF")
	DbCloseArea()
Return
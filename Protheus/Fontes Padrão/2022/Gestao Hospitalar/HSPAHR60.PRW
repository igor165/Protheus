#Include "hspahr60.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR60 บ Autor ณ Monica Y. Miyamoto บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pagamento de Plantใo M้dico                                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR60()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"PAGAMENTO DE PLANTAO MEDICO -"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := ""
 //                 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2 := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := STR0004 // Coloque aqui o nome do programa para impressao no cabecalho //"HSPAHR60"
 Private nTipo       := 18
 Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
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
 Private nMaxLin := 0  // quantidade maxima de linhas p/ impressao
 Private aTitulo := {} //guarda os numeros do titulos   
 Private aTotal  := {} //guarda valores para quadro de totalizacao 
                                                                                                  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Da Data ?                                                 ณ
 //ณ MV_PAR02	Ate a Data ?                                              ณ
 //ณ MV_PAR03	Do Prestador ?                                            ณ
 //ณ MV_PAR04	Ate Prestador ?                                           ณ
 //ณ MV_PAR05	Do Profissional ?                                         ณ
 //ณ MV_PAR06	Ate Profissional ?                                        ณ
 //ณ MV_PAR07	Do Setor ?                                                ณ
 //ณ MV_PAR08	Ate Setor ?                                               ณ
 //ณ MV_PAR09	Tipo ?                                                    ณ
 //ณ MV_PAR10	Mostrar quadro ?                                          ณ
 //ณ MV_PAR11	Relacionar titulos ?                                      ณ
 //ณ MV_PAR12	Pula pagina ?                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPR60"   
 
 If !Pergunte(cPerg,.T.)
  return
 EndIf
 
 nMaxLin := HS_MaxLin(cCODIMP)

 dDatIni  := mv_par01
 dDatFin  := mv_par02
 cPreIni  := mv_par03
 cPreFin  := mv_par04 
 cProIni  := mv_par05
 cProFin  := mv_par06 
 cSetIni  := mv_par07
 cSetFin  := mv_par08 
 cTipo    := mv_par09
 cQuadro  := mv_par10 
 cTitulo  := mv_par11 
 cPulPag  := mv_par12
 
//IIf(mv_par09 == 3, mv_par11:=2,)
  

 if !Empty(mv_par01)
    DO CASE
	   CASE !Empty(mv_par02)
     Titulo +=  " " + DTOC(mv_par01) + STR0008 + DTOC(mv_par02) //HS_DTOC(STOD(mv_par01),2) + " A " + HS_DTOC(STOD(mv_par02),2) //" A "
		  CASE Empty(mv_par02)
     Titulo +=  STR0009 + DTOC(mv_par01) //HS_DTOC(STOD(mv_par01),2) //" A PARTIR DE "
    ENDCASE
 Else
    DO CASE
	   CASE !Empty(mv_par02)
     Titulo +=  STR0010 + DTOC(mv_par02) //HS_DTOC(STOD(mv_par02),2) //" ATE "
		  CASE Empty(mv_par02)
     HS_MsgInf(STR0011, STR0012, STR0013)  //"Data inicial e/ou final deve ser preenchida."###"Aten็ใo"###"Rotina de execucao do relatorio"
     DbCloseArea()
     Return()
    ENDCASE
 Endif  

 DO CASE
	 CASE cTipo == 1
   Cabec1 := STR0014 //"PROFISSIONAL                            ESPECIALIDADE                         QTDE         DIURNO      NOTURNO       FERIADO   TOTAL"
   Titulo += STR0015 //" (PRESTADOR/SETOR)"
	 CASE cTipo == 2
   Cabec1 := STR0016 //"PROFISSIONAL                                     ESPECIALIDADE                                                      TOTAL"
   Titulo += STR0017 //" (RESUMO)"
	 CASE cTipo == 3
   Cabec1 := STR0016 //"PROFISSIONAL                                     ESPECIALIDADE                                                      TOTAL"
   Titulo += STR0018 //" (PROFISSIONAL)"
 ENDCASE

 wnrel := SetPrint("GN4", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Monica Y. Miyamoto บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql    := "",  cPrestador :="", cSetor:="", nTotValPre:=0
 Private nLin    := nMaxLin * 2
 Private cCodLoc := ""


 cSQL := "SELECT GN4_CODPRE, GAZ.GAZ_FANPRE, GN4_CODLOC, GCS.GCS_NOMLOC, GN4_CODCRM, SRA.RA_NOME, GBJ.GBJ_ESPEC1, GFR.GFR_DSESPE, COUNT(*) TOTREG,SUM(GN4_VLRTOT) TOTVAL, " 
 cSQL += " SUM(ROUND(GN4.GN4_QTDDIU*(GN4.GN4_VLRDIU/CASE WHEN GN4_FATORH = 0 THEN 1 ELSE GN4_FATORH END),2)) TOTDIU, "
 cSQL += " SUM(ROUND(GN4.GN4_QTDNOT*(GN4.GN4_VLRNOT/CASE WHEN GN4_FATORH = 0 THEN 1 ELSE GN4_FATORH END),2)) TOTNOT, "
 cSQL += " SUM(ROUND(GN4.GN4_QTDFER*(GN4.GN4_VLRFER/CASE WHEN GN4_FATORH = 0 THEN 1 ELSE GN4_FATORH END),2)) TOTFER "
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " JOIN " + RetSQLName("GN3") + " GN3 ON GN4.GN4_NRSEQP = GN3.GN3_NRSEQP AND GN3.GN3_FILIAL = '" + xFilial("GN3") + "' AND GN3.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GN4.GN4_CODCRM    = GBJ.GBJ_CRM    AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GFR") + " GFR ON GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE AND GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GN4.GN4_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON GN4.GN4_CODCRM    = SRA.RA_CODIGO  AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GAZ") + " GAZ ON GN4.GN4_CODPRE    = GAZ.GAZ_CODPRE  AND GAZ.GAZ_FILIAL  = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If !Empty(dDatIni)
  cSQL += " AND GN4_DATINI >= '" + DTOS(dDatIni) + "'" 
 Endif                                           
 If !Empty(dDatFin)
  cSQL += " AND GN4_DATINI <= '" + DTOS(dDatFin) + "'"
 Endif                                            
 If !Empty(cPreIni)
  cSQL += " AND GN4_CODPRE >= '" + cPreIni + "'"
 Endif                                            
 If !Empty(cPreFin)
  cSQL += " AND GN4_CODPRE <= '" + cPreFin + "'"
 Endif                                                                 
 If !Empty(cProIni)
  cSQL += " AND GN4_CODCRM >= '" + cProIni+ "'"
 Endif                                            
 If !Empty(cProFin)
  cSQL += " AND GN4_CODCRM <= '" + cProFin+ "'" 
 Endif                                           
 If !Empty(cSetIni)
  cSQL += " AND GN4_CODLOC >= '" + cSetIni+ "'" 
 Endif                                            
 If !Empty(cSetFin)
  cSQL += " AND GN4_CODLOC <= '" + cSetFin + "'"
 Endif      
 cSQL += " GROUP BY GN4_CODPRE, GAZ.GAZ_FANPRE, GN4_CODLOC, GCS.GCS_NOMLOC, GN4_CODCRM, SRA.RA_NOME, GBJ.GBJ_ESPEC1, GFR.GFR_DSESPE"                                     

 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 If Eof()
  HS_MsgInf(STR0019, STR0012, STR0013) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 SetRegua(1000)
 DbGoTop() 

 While !EOF()                                                                                
  IncRegua()

  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif

	 aAdd(aTotal,{QRY->GN4_CODPRE,QRY->GAZ_FANPRE,QRY->GN4_CODLOC,QRY->GCS_NOMLOC,QRY->TOTVAL})

 If cTipo <> 3
  If QRY->GN4_CODPRE <> cPrestador                                                          
     If cPulPag == 1 .and. nLin > 7// SALTA PAGINA POR SETOR
      FS_Cabec()                 
     Endif 
    cPrestador := QRY->GN4_CODPRE
    
		  nLin += 1
     @nLin, 000 PSAY STR0020   //"PRESTADOR: "
     @nLin, 011 PSAY QRY->GN4_CODPRE
     @nLin, 017 PSAY "-"
     @nLin, 018 PSAY QRY->GAZ_FANPRE 
	     	nLin += 1
  EndIf
	  If QRY->GN4_CODLOC <> cSetor
		    nLin += 2
      @nLin, 000 PSAY STR0021 //"SETOR: "
	     @nLin, 008 PSAY QRY->GN4_CODLOC
      @nLin, 011 PSAY "-"
	     @nLin, 013 PSAY QRY->GCS_NOMLOC
		    nLin += 1
   Endif
  EndIf 
		  nLin += 1
    @nLin, 000 PSAY QRY->GN4_CODCRM + "-" 
		  @nLin, 008 PSAY QRY->RA_NOME
    If cTipo == 1
			  @nLin, 040 PSAY QRY->GBJ_ESPEC1 + "-" 
			  @nLin, 043 PSAY QRY->GFR_DSESPE 
			  @nLin, 083 PSAY QRY->TOTREG
     @nLin, 091 PSAY TRANSFORM(QRY->TOTDIU, "@E 99,999.99")
     @nLin, 101 PSAY TRANSFORM(QRY->TOTNOT, "@E 99,999.99")
     @nLin, 111 PSAY TRANSFORM(QRY->TOTFER, "@E 99,999.99")
     @nLin, 123 PSAY TRANSFORM(QRY->TOTVAL, "@E 999,999.99")
    Else
     @nLin, 049 PSAY QRY->GBJ_ESPEC1 + "-" 
     @nLin, 052 PSAY QRY->GFR_DSESPE
     @nLin, 121 PSAY TRANSFORM(QRY->TOTVAL, "@E 9999,999.99") 
    EndIf
		  
		  nTotValPre += QRY->TOTVAL

    If cTipo <>3
     If cQuadro == 1 .or. cTitulo == 1
      Fs_DetPla(QRY->GN4_CODPRE,QRY->GN4_CODLOC,QRY->GN4_CODCRM)
     EndIf
    Else  
     If cQuadro == 1
      Fs_DetPro(QRY->GN4_CODCRM)
     EndIf
    EndIf
    
    cSetor:=QRY->GN4_CODLOC
      
  DbSelectArea("QRY")
  DbSkip()  
  If cTipo <> 3 
	  If QRY->GN4_CODPRE <> cPrestador 
	   If cTitulo == 1 
	    Fs_ImpQua()
	   EndIf 
	   nLin += 1       
    @nLin, 090 PSAY STR0022 //"TOTAL PRESTADOR"
    @nLin, 121 PSAY TRANSFORM(nTotValPre, "@E 9999,999.99") 
	   nLin += 1 
	   nTotValPre:= 0
	  EndIf
  EndIf
 End 
  
 If Eof() 
  If cTipo=3
   nLin += 2
   @nLin, 087 PSAY STR0023 //"TOTAL GERAL"
   @nLin, 121 PSAY TRANSFORM(nTotValPre, "@E 9999,999.99") 
  Else
	 	If cTitulo == 1
 	 	Fs_ImpQua()   
  	EndIf
  EndIf
 Fs_ImpTot()
 EndIf
    
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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
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
 nLin := 7
Return()                                                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_DetPla บ Autor ณ Monica Y. Miyamoto บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime detalhes do plantao                                บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_DetPla(cCodPre,cCodLoc,cCodCRM)
Local aAreaOld  := GetArea() , cSql :="" , lCabQua := .T., lTitulo := .T., i :=0

 cSQL := "SELECT GN4.GN4_DATINI, GN4.GN4_HORINI, GN4.GN4_DATFIN, GN4.GN4_HORFIN, " 
 cSQL += " GN4.GN4_STATUS, GN4.GN4_PROSUB, GN4.GN4_VLRTOT, GN4.GN4_DATREF, GDX.GDX_CODCPG "
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " LEFT JOIN " + RetSQLName("GDX") + " GDX ON GN4.GN4_NREXTM = GDX.GDX_NREXTM AND GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' 
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If !Empty(dDatIni)
  cSQL += " AND GN4_DATINI >= '" + DTOS(dDatIni) + "'"
 Endif                                            
 If !Empty(dDatFin)
  cSQL += " AND GN4_DATINI <= '" + DTOS(dDatFin) + "'" 
 Endif                                            
 cSQL += " AND GN4_CODPRE = '" + cCodPre + "'"
 cSQL += " AND GN4_CODLOC = '" + cCodLoc + "'"
 cSQL += " AND GN4_CODCRM = '" + cCodCRM + "'" 
 cSQL += " ORDER BY GN4.GN4_DATINI, GN4.GN4_HORINI" 
 

 cSQL := ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRYQUA"
 
 DbSelectArea("QRYQUA")
              
 DbGoTop()
  While !EOF()                                         
                                         
  // monta array para imprimir os titulos por prestador
  If cTitulo == 1
	  For i :=1 to Len(aTitulo)
	   if QRYQUA->GDX_CODCPG == atitulo[i,1]
	    lTitulo := .F.
	   EndIf
	  Next 
	  If lTitulo
	    aAdd(aTitulo,{QRYQUA->GDX_CODCPG})
	  EndIf
	 EndIf
  
  If cQuadro == 1 
	  If lCabQua == .T. 
	   nLin += 1   
    @nLin, 000 PSAY REPLICATE("-", 132)
	   nLin += 1
    @nLin, 012 PSAY STR0024 //"INTERVALO               STATUS       SUBSTITUIDO          VALOR DATA FECHAMENTO   NRO TITULO"
	   nLin += 1  
	   lCabQua := .F.
	  Endif
	
	  @nLin, 000 PSAY HS_DTOC(STOD(QRYQUA->GN4_DATINI),2) 
	  @nLin, 011 PSAY QRYQUA->GN4_HORINI
	  @nLin, 017 PSAY HS_DTOC(STOD(QRYQUA->GN4_DATFIN),2) 
	  @nLin, 028 PSAY QRYQUA->GN4_HORFIN                    
	
		 DO CASE
			 CASE QRYQUA->GN4_STATUS == '0'
     @nLin, 036 PSAY STR0025 //"NORMAL"
			 CASE QRYQUA->GN4_STATUS == '1'
     @nLin, 036 PSAY STR0026 //"TROCA"
			 CASE QRYQUA->GN4_STATUS == '2'
     @nLin, 036 PSAY STR0027 //"FALTA"
			 CASE QRYQUA->GN4_STATUS == '3'
     @nLin, 036 PSAY STR0028 //"CANCELADO"
		 ENDCASE
						  
	  @nLin, 049 PSAY QRYQUA->GN4_PROSUB
   @nLin, 066 PSAY TRANSFORM(QRYQUA->GN4_VLRTOT, "@E 99,999.99")
	  @nLin, 076 PSAY HS_DTOC(STOD(QRYQUA->GN4_DATREF),2) 
	  @nLin, 094 PSAY QRYQUA->GDX_CODCPG
	  nLin += 1
 	EndIf
	 DbSkip()                      
 End 
 If cQuadro==1 .and. cTipo <> 3 
  @nLin, 000 PSAY REPLICATE("-", 132)
 	nLin += 1
 EndIf  
DbCloseArea()
RestArea(aAreaOld)                                     

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpQua บ Autor ณ Monica Y. Miyamoto บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime dados do quadro                                    บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_ImpQua()
Local aAreaOld  := GetArea() , cSql :="" , lCabQua := .T., i :=0

For i := 1 to Len(aTitulo)

 cSQL := "SELECT SE2.E2_FORNECE, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_EMISSAO, SE2.E2_VENCTO, SE2.E2_VALOR, SE2.E2_SALDO" 
 cSQL += " FROM " + RetSQLName("SE2") + " SE2 "
 cSQL += " WHERE SE2.E2_NUM = '"+ aTitulo[i,1] + "' AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' " 
 cSQL += " ORDER BY SE2.E2_VENCTO" 
 

 cSQL := ChangeQuery(cSQL)
                                                       
 TCQUERY cSQL NEW ALIAS "QRYTIT"
 DbSelectArea("QRYTIT")
              
 DbGoTop()
  While !EOF()                                                                                
 
  If lCabQua == .T. 
   nLin += 1   
   @nLin, 000 PSAY REPLICATE("-", 132)
   nLin += 1
   @nLin, 000 PSAY STR0029 //"FORNECEDOR PREFIXO TITULO PARCELA TIPO   EMISSAO   VENCIMENTO       VALOR        SALDO"
   nLin += 1                 
   lCabQua := .F.
  Endif
  
  @nLin, 000 PSAY QRYTIT->E2_FORNECE        
  @nLin, 011 PSAY QRYTIT->E2_PREFIXO
  @nLin, 019 PSAY QRYTIT->E2_NUM
  @nLin, 026 PSAY QRYTIT->E2_PARCELA
  @nLin, 034 PSAY QRYTIT->E2_TIPO    
  @nLin, 039 PSAY HS_DTOC(STOD(QRYTIT->E2_EMISSAO),2)
  @nLin, 051 PSAY HS_DTOC(STOD(QRYTIT->E2_VENCTO),2)
  @nLin, 061 PSAY TRANSFORM(QRYTIT->E2_VALOR, "@E 9,999,999.99")
  @nLin, 074 PSAY TRANSFORM(QRYTIT->E2_SALDO, "@E 9,999,999.99")
  nLin += 1
  DbSkip()                      
 End  
DbCloseArea()
Next

 @nLin, 000 PSAY REPLICATE("-", 132)
 nLin += 1

RestArea(aAreaOld)                                     
aTitulo := {}
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Monica Y. Miyamoto บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime quadro de totais                                   บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_ImpTot()
Local aAreaOld  := GetArea() , cSql :="" , lCabQua := .T., cPrestador := "", nTotGer := 0, nTotPre :=0

 cSQL := "SELECT GN4_CODPRE, GAZ.GAZ_FANPRE, GN4_CODLOC, GCS.GCS_NOMLOC, SUM(GN4_VLRTOT) TOTVAL " 
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GN4.GN4_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GAZ") + " GAZ ON GN4.GN4_CODPRE    = GAZ.GAZ_CODPRE  AND GAZ.GAZ_FILIAL  = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If !Empty(dDatIni)
  cSQL += " AND GN4_DATINI >= '" + DTOS(dDatIni) + "'" 
 Endif                                           
 If !Empty(dDatFin)
  cSQL += " AND GN4_DATINI <= '" + DTOS(dDatFin) + "'"  
 Endif
 If !Empty(cPreIni)
  cSQL += " AND GN4_CODPRE >= '" + cPreIni + "'"
 Endif                                            
 If !Empty(cPreFin)
  cSQL += " AND GN4_CODPRE <= '" + cPreFin + "'"
 Endif                                                                 
 If !Empty(cProIni)
  cSQL += " AND GN4_CODCRM >= '" + cProIni+ "'"
 Endif                                            
 If !Empty(cProFin)
  cSQL += " AND GN4_CODCRM <= '" + cProFin+ "'" 
 Endif                                           
 If !Empty(cSetIni)
  cSQL += " AND GN4_CODLOC >= '" + cSetIni+ "'" 
 Endif                                            
 If !Empty(cSetFin)
  cSQL += " AND GN4_CODLOC <= '" + cSetFin + "'"
 Endif      
 cSQL += " GROUP BY GN4_CODPRE, GAZ.GAZ_FANPRE, GN4_CODLOC, GCS.GCS_NOMLOC" 

 cSQL := ChangeQuery(cSQL)
                                                       
 TCQUERY cSQL NEW ALIAS "QRYTOT"
 DbSelectArea("QRYTOT")
              
 DbGoTop()
  While !EOF()                                                                                
 
  	If lCabQua == .T. 
  		FS_Cabec() 
	   nLin += 1   
	   @nLin, 000 PSAY REPLICATE("-", 132)
	   nLin += 1
	   @nLin, 000 PSAY STR0030 //"PRESTADOR                              SETOR                                                    TOTAL"
	   nLin += 1   
	   @nLin, 000 PSAY REPLICATE("-", 132)
	   nLin += 1  
	   lCabQua := .F.
	Endif

	If QRYTOT->GN4_CODPRE <> cPrestador  
		@nLin, 000 PSAY QRYTOT->GN4_CODPRE        
   		@nLin, 006 PSAY "-"
	  	@nLin, 007 PSAY QRYTOT->GAZ_FANPRE
	  	cPrestador := QRYTOT->GN4_CODPRE
	EndIf
 	
 	@nLin, 039 PSAY QRYTOT->GN4_CODLOC
 	@nLin, 041 PSAY "-"    
  	@nLin, 042 PSAY QRYTOT->GCS_NOMLOC
  	@nLin, 121 PSAY TRANSFORM(QRYTOT->TOTVAL, "@E 9999,999.99") 
  	nTotPre +=QRYTOT->TOTVAL
  	nTotGer +=QRYTOT->TOTVAL
  	nLin += 1                                        
  DbSkip()  		                      
  
  If QRYTOT->GN4_CODPRE <> cPrestador  
  	@nLin, 074 PSAY STR0031 //"TOTAL PRESTADOR"
   	@nLin, 121 PSAY TRANSFORM(nTotPre, "@E 9999,999.99")
   	nTotPre :=0    
   	nLin += 2
  EndIf
   //cPrestador:= QRYTOT->GN4_CODPRE
 End        
 nLin += 1
 @nLin, 074 PSAY STR0032 //"TOTAL GERAL"
 @nLin, 121 PSAY TRANSFORM(nTotGer, "@E 9999,999.99")
  
DbCloseArea()
 nLin += 1
 @nLin, 000 PSAY REPLICATE("-", 132)
 nLin += 1

RestArea(aAreaOld)                                     
aTitulo := {}
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_DetPro บ Autor ณ Monica Y. Miyamoto บ Data ณ  25/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime detalhes do profissional                           บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_DetPro(cCodCRM)
Local aAreaOld  := GetArea() , cSql :="" , lCabPro := .T.

 cSQL := "SELECT GN4.GN4_DATINI, GN4.GN4_HORINI, GN4.GN4_DATFIN, GN4.GN4_HORFIN, " 
 cSQL += " GN4.GN4_STATUS, GN4.GN4_PROSUB, GN4.GN4_VLRTOT, GN4.GN4_CODLOC, GCS.GCS_NOMLOC "
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GN4.GN4_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If !Empty(dDatIni)
  cSQL += " AND GN4_DATINI >= '" + DTOS(dDatIni) + "'"
 Endif                                            
 If !Empty(dDatFin)
  cSQL += " AND GN4_DATINI <= '" + DTOS(dDatFin) + "'" 
 Endif                                            
 cSQL += " AND GN4_CODCRM = '" + cCodCRM + "'" 
 cSQL += " ORDER BY GN4.GN4_DATINI, GN4.GN4_HORINI" 
 

 cSQL := ChangeQuery(cSQL)

 
 TCQUERY cSQL NEW ALIAS "QRYPRO"
 DbSelectArea("QRYPRO")
              
 DbGoTop()
  While !EOF()                                                                           

	  If lCabPro == .T. 
	   nLin += 1   
    @nLin, 000 PSAY REPLICATE("-", 132)
	   nLin += 1
    @nLin, 012 PSAY STR0033 //"INTERVALO               SETOR                            STATUS    SUBSTITUIDO          VALOR"
	   nLin += 1  
	   lCabPro := .F.
	  Endif
	
	  @nLin, 000 PSAY HS_DTOC(STOD(QRYPRO->GN4_DATINI),2) 
	  @nLin, 011 PSAY QRYPRO->GN4_HORINI
	  @nLin, 017 PSAY HS_DTOC(STOD(QRYPRO->GN4_DATFIN),2) 
	  @nLin, 028 PSAY QRYPRO->GN4_HORFIN                    
   @nLin, 036 PSAY QRYPRO->GN4_CODLOC
   @nLin, 038 PSAY "-"
   @nLin, 039 PSAY QRYPRO->GCS_NOMLOC	
		 DO CASE
			 CASE QRYPRO->GN4_STATUS == '0'
     @nLin, 070 PSAY STR0025 //"NORMAL"
			 CASE QRYPRO->GN4_STATUS == '1'
     @nLin, 070 PSAY STR0026 //"TROCA"
			 CASE QRYPRO->GN4_STATUS == '2'
     @nLin, 070 PSAY STR0027 //"FALTA"
			 CASE QRYPRO->GN4_STATUS == '3'
     @nLin, 070 PSAY STR0028 //"CANCELADO"
		 ENDCASE
						  
	  @nLin, 080 PSAY QRYPRO->GN4_PROSUB
   @nLin, 097 PSAY TRANSFORM(QRYPRO->GN4_VLRTOT, "@E 99,999.99")
	  nLin += 1

	 DbSkip()                      
 End 
  @nLin, 000 PSAY REPLICATE("-", 132)
 	nLin += 1
DbCloseArea()
RestArea(aAreaOld)                                     

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ        
ฑฑบFuno    ณFS_VldR60 บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldR60()
 Local lRet := .T.

If ReadVar() == "MV_PAR01" // Data Inicial
   If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02
    HS_MsgInf(STR0034, STR0012, STR0035) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Relatorio"
	 		lRet := .F.
	 	EndIf	
ElseIf ReadVar() == "MV_PAR02" // Data Final
  If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02
    HS_MsgInf(STR0034, STR0012, STR0035) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Relatorio"
	 		lRet := .F.
	 EndIf	
ElseIf ReadVar() == "MV_PAR11" // Relacionar titulos
  If MV_PAR09 == 3 .And. MV_PAR11 == 1
    HS_MsgInf(STR0036, STR0012, STR0035) //"As informa็๕es referentes ao(s) tํtulo(s) nใo serใo apresentadas para o tipo selecionado: 'Profissional'"###"Aten็ใo"###"Relatorio"
	 		lRet := .F.
	 EndIf	
EndIf
Return(lRet)                                                       

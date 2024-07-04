#INCLUDE "HSPAHR46.ch"
#INCLUDE "TopConn.ch"    
#define TRACE  repl("_",132)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR46 บ Autor ณ MARIO ARIZONO      บ Data ณ  30/11/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO ESTATISTICA DAS MARCACOES                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR46()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Locais                                      ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local Titulo         := STR0003 //"Estatistica das Marcacoes."
 Local Cabec1         := ""
 Local Cabec2         := ""
 Local aOrd           := {}
 Local aArea          := GetArea()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Privadas                                    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR46"
 Private nTipo        := 18
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private m_pag        := 01
 Private wnrel        := "HSPAHR46"
 Private cString      := ""
 Private aRegistros   := {}
 Private nLin         := 80

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Da Data Agenda                                            ณ
 //ณ MV_PAR02	Ate a Data Agenda                                         ณ
 //ณ MV_PAR03	Do Setor                                                  ณ
 //ณ MV_PAR04	Ate o Setor                                               ณ
 //ณ MV_PAR05	Do Medico                                                 ณ
 //ณ MV_PAR06	Ate o Medico                                              ณ
 //ณ MV_PAR07	Emite:  1-Analitico 2-Sintetico 3-Ambos                   ณ
 //| MV_PAR08 Emite Grafico: 1-Sim 2-Nao                                |
 //| MV_PAR09 Impressora ?                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPR46"       
 Pergunte(cPerg,.T.)             

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin 			:= nMaxLin * 2
                                                                                                  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                        
 //ณ Monta a interface padrao com o usuario...                           ณ                        
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 If nLastKey == 27
  Return
 Endif          
 
 SetDefault(aReturn,cString)   
 
 If nLastKey == 27
  Return
 Endif            
 
 nTipo := If(aReturn[4]==1,15,18)
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
 
 RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ MARIO ARIZONO      บ Data ณ30/11/2005   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo)
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Definicao das variแveis locais.                                     ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local   cCodloc   := ""
 Local   cNomcrm   := "" 
 Local   cSQL      := "" 
 Local   nASint    := 0
 Local   aVetGraf  := {}  
 Local   nTSetDis  := 0, nTSetAge := 0, nTSetCon := 0, nTSetAte := 0, nTSetCAte:= 0, nTSetFal:= 0, nTSetCFal:= 0 
 Local   nTGerDis  := 0, nTGerAge := 0, nTGerCon := 0, nTGerAte := 0, nTGerCAte:= 0, nTGerFal:= 0, nTGerCFal:= 0
 Private nTotDis   := 0, nTotAge  := 0, nTotCon  := 0, nTotAte  := 0, nTotCAte := 0, nTotFal := 0, nTotCFal := 0
 Private nPerDAg   := 0, nPerCon  := 0, nPerAte  := 0, nPerCAte := 0, nPerFal  := 0, nPerCFal:= 0
 Private aASint    := {}
 
 Titulo := IIF(mv_par07 == 1,STR0006,IIF(mv_par07 == 2,STR0007,STR0008)) //"Relatorio Analitico - Estatistica das Marcacoes"###"Resumo - Estatistica das Marcacoes"###"Relatorio Analitico/Resumo - Estatistica das Marcacoes"
  
 cSQL := " SELECT GM8.GM8_CODCRM, GM8.GM8_DATAGE, GM8.GM8_CODLOC,GM8.GM8_DATCFM, GM8.GM8_STATUS, GCS.GCS_NOMLOC, "
 cSQL += " SRA.RA_NOME "
 cSQL += " FROM " + RetSQLName("GM8") + " GM8"  
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GM8.GM8_CODLOC"                                 
 cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GBJ.GBJ_CRM    = GM8.GM8_CODCRM"
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GBJ.GBJ_CRM"
 cSQL += " WHERE"
 cSQL += "     GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' " 
 cSQL += " AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' " 
 cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cSQL += " AND GM8.GM8_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 
 cSQL += " AND GM8.GM8_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cSQL += " AND GM8.GM8_STATUS NOT IN ('2') "
 If mv_par07 == 1 .OR. mv_par07 == 3
  cSQL += " ORDER BY GCS_NOMLOC, RA_NOME "
 ElseIf mv_par07 == 2
  cSQL += " ORDER BY RA_NOME "
 Endif 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  HS_MsgInf(STR0009, STR0027, STR0028)  //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return()
 Endif
  
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(500)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Carrega o vetor aRegistros com todos os dados a serem impressos.    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
  
 While !EOF()

  IncRegua()     
  
  If lAbortPrint
   @nLin,00 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif                                                                              
      /*    	    			             1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
    		     	           0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
  Cabec1 := STR0011 //"Medico                        Dispon. Agenda.    %    Confir.    %    Atendi.    %    C.Aten.    %    Faltos.    %    C.Falt.    %   "
 
	 If nLin > nMaxLin
	   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 9
  Endif
  If mv_par07 == 1 .OR. mv_par07 == 3  //Emite Analitico ou Analitico e Resumo
   If cCodloc <> QRY->GM8_CODLOC
    If !Empty(cCodLoc) 
     nLin := FS_ImpEst(nLin, cNomCrm) 
     nLin ++ 
     @nLin,000 PSAY "Total Setor: "
     @nLin,030 PSAY TRANSFORM(nTSetDis ,"@E 999,999") 
     @nLin,038 PSAY TRANSFORM(nTSetAge,"@E 999,999")
     @nLin,046 PSAY TRANSFORM((nTSetAge/nTSetDis)*100,"@E 999.99") + "%"                           
 	   @nLin,054 PSAY TRANSFORM(nTSetCon,"@E 999,999")
     @nLin,062 PSAY TRANSFORM((nTSetCon/nTSetAge)*100,"@E 999.99") + "%"    
     @nLin,070 PSAY TRANSFORM(nTSetAte,"@E 999,999")
     @nLin,078 PSAY TRANSFORM((nTSetAte/nTSetAge)*100,"@E 999.99") + "%"    
     @nLin,086 PSAY TRANSFORM(nTSetCAte,"@E 999,999")
     @nLin,094 PSAY TRANSFORM((nTSetCAte/nTSetAte)*100,"@E 999.99") + "%"
     @nLin,102 PSAY TRANSFORM(nTSetFal,"@E 999,999")
     @nLin,110 PSAY TRANSFORM((nTSetFal/nTSetAge)*100,"@E 999.99") + "%"    
     @nLin,118 PSAY TRANSFORM(nTSetCFal,"@E 999,999")
     @nLin,126 PSAY TRANSFORM((nTSetCFal/nTSetFal)*100,"@E 999.99") + "%"    
   
     Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
     nLin := 9    
     If mv_par07 == 3
      @nLin,000 PSAY PADC(STR0012,132) //"Analitico"
      nLin +=2
     Endif 
     @nLin,000 PSAY STR0013 + QRY->GM8_CODLOC +" - "+ QRY->GCS_NOMLOC    //"Setor: "
     nLin += 2
     nTSetDis := 0; nTSetAge := 0; nTSetCon := 0; nTSetAte := 0; nTSetCAte:= 0; nTSetFal := 0; nTSetCFal:= 0  
     nTotDis  := 0; nTotAge  := 0; nTotCon  := 0; nTotAte  := 0; nTotCAte := 0; nTotFal  := 0; nTotCFal := 0
     nPerDAg  := 0; nPerCon  := 0; nPerAte  := 0; nPerCAte := 0; nPerFal  := 0; nPerCFal := 0
     cNomCrm  := ""
    Else
     If mv_par07 == 3
      @nLin,000 PSAY PADC(STR0012,132) //"Analitico"
      nLin +=2
     Endif 
     @nLin,000 PSAY STR0013 + QRY->GM8_CODLOC +" - "+ QRY->GCS_NOMLOC //"Setor: "
     nLin +=2
    EndIf
   Endif  
   cCodloc := QRY->GM8_CODLOC
  Endif
  
  If cNomCrm <> QRY->RA_NOME  
   If !Empty(cNomCrm)
    nLin := FS_ImpEst(nLin, cNomCrm) 
    nTotDis  := 0; nTotAge  := 0; nTotCon  := 0; nTotAte  := 0; nTotCAte := 0; nTotFal  := 0; nTotCFal := 0
    nPerDAg  := 0; nPerCon  := 0; nPerAte  := 0; nPerCAte := 0; nPerFal  := 0; nPerCFal := 0
   Endif
  Endif
  
  nTotDis ++
  nTSetDis++
  nTGerDis ++ 
  If !(QRY->GM8_STATUS $ ("0/2"))
   nTotAge ++
   nTSetAge++
   nTGerAge ++  
  Endif 
  
  If !Empty(QRY->GM8_DATCFM)
   nTotCon ++
   nTSetCon++ 
   nTGerCon ++ 
  Endif 
  
  If QRY->GM8_STATUS == "3"
   nTotAte ++
   nTSetAte++  
   nTGerAte ++ 
  Endif
  
  If QRY->GM8_STATUS == "3" .AND. !Empty(QRY->GM8_DATCFM)
   nTotCAte ++ 
   nTSetCAte++
   nTGerCAte ++ 
  Endif
  
  If !(QRY->GM8_STATUS $ ("0/2/3")) .AND. CTOD(QRY->GM8_DATAGE) < dDatabase
   nTotFal ++ 
   nTSetFal++ 
   nTGerFal ++ 
  Endif
  
  If QRY->GM8_STATUS == "5" .AND. !Empty(QRY->GM8_DATCFM)
   nTotCFal ++
   nTSetCFal++
   nTGerCFal ++ 
  Endif 
  
  cNomCrm := QRY->RA_NOME

  
  DbSkip()
  
  If EOF() 
   nLin := FS_ImpEst(nLin, cNomCrm)
   If mv_par07 == 1 .OR. mv_par07 == 3
    nLin ++
    @nLin,000 PSAY STR0014 //"Total Setor: "
    @nLin,030 PSAY TRANSFORM(nTSetDis ,"@E 999,999") 
    @nLin,038 PSAY TRANSFORM(nTSetAge,"@E 999,999")
    @nLin,046 PSAY TRANSFORM((nTSetAge/nTSetDis)*100,"@E 999.99") + "%"                           
 	  @nLin,054 PSAY TRANSFORM(nTSetCon,"@E 999,999")
    @nLin,062 PSAY TRANSFORM((nTSetCon/nTSetAge)*100,"@E 999.99") + "%"    
    @nLin,070 PSAY TRANSFORM(nTSetAte,"@E 999,999")
    @nLin,078 PSAY TRANSFORM((nTSetAte/nTSetAge)*100,"@E 999.99") + "%"    
    @nLin,086 PSAY TRANSFORM(nTSetCAte,"@E 999,999")
    @nLin,094 PSAY TRANSFORM((nTSetCAte/nTSetAte)*100,"@E 999.99") + "%"
    @nLin,102 PSAY TRANSFORM(nTSetFal,"@E 999,999")
    @nLin,110 PSAY TRANSFORM((nTSetFal/nTSetAge)*100,"@E 999.99") + "%"    
    @nLin,118 PSAY TRANSFORM(nTSetCFal,"@E 999,999")
    @nLin,126 PSAY TRANSFORM((nTSetCFal/nTSetFal)*100,"@E 999.99") + "%"    
   Endif
   nLin++
   @nLin,000 PSAY TRACE
   nLin++
   @nLin,000 PSAY STR0015 //"Total Geral: "
   @nLin,030 PSAY TRANSFORM(nTGerDis ,"@E 999,999") 
   @nLin,038 PSAY TRANSFORM(nTGerAge,"@E 999,999")
   @nLin,046 PSAY TRANSFORM((nTgerAge/nTGerDis)*100,"@E 999.99") + "%"                           
 	 @nLin,054 PSAY TRANSFORM(nTGerCon,"@E 999,999")
   @nLin,062 PSAY TRANSFORM((nTGerCon/nTgerAge)*100,"@E 999.99") + "%"    
   @nLin,070 PSAY TRANSFORM(nTGerAte,"@E 999,999")
   @nLin,078 PSAY TRANSFORM((nTGerAte/nTGerAge)*100,"@E 999.99") + "%"    
   @nLin,086 PSAY TRANSFORM(nTGerCAte,"@E 999,999")
   @nLin,094 PSAY TRANSFORM((nTGerCAte/nTGerAte)*100,"@E 999.99") + "%"
   @nLin,102 PSAY TRANSFORM(nTGerFal,"@E 999,999")
   @nLin,110 PSAY TRANSFORM((nTGerFal/nTGerAge)*100,"@E 999.99") + "%"    
   @nLin,118 PSAY TRANSFORM(nTGerCFal,"@E 999,999")
   @nLin,126 PSAY TRANSFORM((nTGerCFal/nTGerFal)*100,"@E 999.99") + "%"  
  Endif  
 EndDo   
 
 If mv_par07 == 3 //Analitico e Sintetico  
  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
  nLin := 9  
  @nLin,000 PSAY PADC(STR0016,132) //"Resumo"
  nLin +=2 
  aSort(aASint,,,{|x,y| x[1] < y[1]})  
  For nASint := 1 to len(aASint)
   If nLin > nMaxLin
	   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 9 
    @nLin,000 PSAY PADC(STR0016,132) //"Resumo"
    nLin +=2 
   Endif
   @nLin,000 PSAY aASint[nASint,1]
   @nLin,030 PSAY TRANSFORM(aASint[nASint,2],"@E 999,999") 
   @nLin,038 PSAY TRANSFORM(aASint[nASint,3],"@E 999,999")
   @nLin,046 PSAY TRANSFORM(aASint[nASint,4],"@E 999.99") + "%"                           
   @nLin,054 PSAY TRANSFORM(aASint[nASint,5],"@E 999,999")
   @nLin,062 PSAY TRANSFORM(aASint[nASint,6],"@E 999.99") + "%"    
   @nLin,070 PSAY TRANSFORM(aASint[nASint,7],"@E 999,999")
   @nLin,078 PSAY TRANSFORM(aASint[nASint,8],"@E 999.99") + "%"    
   @nLin,086 PSAY TRANSFORM(aASint[nASint,9],"@E 999,999")
   @nLin,094 PSAY TRANSFORM(aASint[nASint,10],"@E 999.99") + "%"
   @nLin,102 PSAY TRANSFORM(aASint[nASint,11],"@E 999,999")
   @nLin,110 PSAY TRANSFORM(aASint[nASint,12],"@E 999.99") + "%"    
   @nLin,118 PSAY TRANSFORM(aASint[nASint,13],"@E 999,999")
   @nLin,126 PSAY TRANSFORM(aASint[nASint,14],"@E 999.99") + "%"  
   @nLin ++
  Next 
   If nLin > (nMaxLin - 2)
	   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 9
   Endif
   nLin++  
   @nLin,000 PSAY TRACE
   nLin++
   @nLin,000 PSAY STR0015 //"Total Geral: "
   @nLin,030 PSAY TRANSFORM(nTGerDis ,"@E 999,999") 
   @nLin,038 PSAY TRANSFORM(nTGerAge,"@E 999,999")
   @nLin,046 PSAY TRANSFORM((nTgerAge/nTGerDis)*100,"@E 999.99") + "%"                           
 	 @nLin,054 PSAY TRANSFORM(nTGerCon,"@E 999,999")
   @nLin,062 PSAY TRANSFORM((nTGerCon/nTgerAge)*100,"@E 999.99") + "%"    
   @nLin,070 PSAY TRANSFORM(nTGerAte,"@E 999,999")
   @nLin,078 PSAY TRANSFORM((nTGerAte/nTGerAge)*100,"@E 999.99") + "%"    
   @nLin,086 PSAY TRANSFORM(nTGerCAte,"@E 999,999")
   @nLin,094 PSAY TRANSFORM((nTGerCAte/nTGerAte)*100,"@E 999.99") + "%"
   @nLin,102 PSAY TRANSFORM(nTGerFal,"@E 999,999")
   @nLin,110 PSAY TRANSFORM((nTGerFal/nTGerAge)*100,"@E 999.99") + "%"    
   @nLin,118 PSAY TRANSFORM(nTGerCFal,"@E 999,999")
   @nLin,126 PSAY TRANSFORM((nTGerCFal/nTGerFal)*100,"@E 999.99") + "%"  
 Endif  
  
 AADD(aVetGraf,{nTGerDis,PADR(STR0017,6)+" "+STR(nTGerDis,6,0)})   //"Disp."
 AADD(aVetGraf,{nTGerAge,PADR(STR0018,6)+" "+STR(nTGerAge,6,0)})    //"Agend."
 AADD(aVetGraf,{nTGerCon,PADR(STR0019,6)+" "+STR(nTGerCon,6,0)})   //"Conf."
 AADD(aVetGraf,{nTGerAte,PADR(STR0020,6)+" "+STR(nTGerAte,6,0)})   //"Atend."
 AADD(aVetGraf,{nTGerFal,PADR(STR0021,6)+" "+STR(nTGerFal,6,0)})   //"Falt."

 If MV_PAR08 == 1 
  oGraf := hsGRAF():NEW(STR0022,STR0023 + DTOC(MV_PAR01) +STR0024 + DTOC(MV_PAR02), STR0025, "", STR0026, "", aVetGraf,1,1,0,0,2,15,6,6,25,20)  //"Estatistica das Marcacoes"###"Periodo de: "###" a "###"Quantidades"###"Situacao"
 EndIf
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Finaliza a execucao do relatorio...                                 ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
  
 DbCloseArea() 
Return              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_IMPEST บ Autor ณ MARIO ARIZONO      บ Data ณ02/12/2005   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao que imprime a estatistica de marcacao de cada       บฑฑ
ฑฑบ          ณ medico.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpEst(nLin,cNomCrm)
 
 nPerDAg  := (nTotAge/nTotDis)*100
 nPerCon  := (nTotCon/nTotAge)*100
 nPerAte  := (nTotAte/nTotAge)*100
 nPerCAte := (nTotCAte/nTotAte)*100 
 nPerFal  := (nTotFal/nTotAge)*100 
 nPerCFal := (nTotCFal/nTotFal)*100 
 
 @nLin,000 PSAY    Substr(cNomCrm,1,28) 
 @nLin,030 PSAY TRANSFORM(nTotDis,"@E 999,999") 
 @nLin,038 PSAY TRANSFORM(nTotAge,"@E 999,999")
 @nLin,046 PSAY TRANSFORM(nPerDAg,"@E 999.99") + "%"                           
 @nLin,054 PSAY TRANSFORM(nTotCon,"@E 999,999")
 @nLin,062 PSAY TRANSFORM(nPerCon,"@E 999.99") + "%"    
 @nLin,070 PSAY TRANSFORM(nTotAte,"@E 999,999")
 @nLin,078 PSAY TRANSFORM(nPerAte,"@E 999.99") + "%"    
 @nLin,086 PSAY TRANSFORM(nTotCAte,"@E 999,999")
 @nLin,094 PSAY TRANSFORM(nPerCAte,"@E 999.99") + "%"
 @nLin,102 PSAY TRANSFORM(nTotFal,"@E 999,999")
 @nLin,110 PSAY TRANSFORM(nPerFal,"@E 999.99") + "%"    
 @nLin,118 PSAY TRANSFORM(nTotCFal,"@E 999,999")
 @nLin,126 PSAY TRANSFORM(nPerCFal,"@E 999.99") + "%"    
 nLin ++   

 If mv_par07 == 3
  aadd(aASint,{cNomCrm,nTotDis,nTotAge,nPerDAg,nTotCon,nPerCon,nTotAte,nPerAte,nTotCAte,nPerCAte,nTotFal,nPerFal,nTotCFal,nPerCFal})
 Endif
 
Return(nLin)
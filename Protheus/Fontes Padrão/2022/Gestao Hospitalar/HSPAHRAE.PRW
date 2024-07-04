#INCLUDE "hspahrae.ch"
#include "rwmake.ch"
#include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRAE บ Autor ณ MARCELO JOSE       บ Data ณ  10/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PRODUCAO POR PRESTADOR/ MEDICO / CONVENIO.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ          
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHRAE()

 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local Titulo         := STR0003 //"Relatorio Analitico de Mat/Med/Tax/Proced/Filmes por Prestador/Convenio."
 Local Cabec2         := ""
 Local aOrd           := {}

 Private lEnd         := .F.
 Private CbTxt        := ""
 Private limite       := 220
 Private tamanho      := "G"
 Private nomeprog     := "HSPAHRAE"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbcont       := 00
 Private cbText       := ""
 Private m_pag        := 01
 Private wnrel        := "HSPAHRAE"
 Private cString      := "GCY"
 Private aMatImp      := {}
 Private aResPre      := {}
 Private aResCon      := {}
 Private aResSet      := {}
 Private aSPrCoSet    := {}
 Private aSPreSet     := {}
 Private aSPreCon     := {}
 Private nCtaReg      := 0
 Private cAliasQRY    := "MMTPFPC"
 Private nLin         := 80
 Private cPrest       := "Start",;  // totais de quebras
         cConven      := "Start",;
         nSomaCon     := 0,; 
         nSomaPre     := 0,;  
         nTotMatPre  := 0, nTotMedPre := 0, nTotTaxPre := 0, nTotFilPre := 0, nTotExaPre := 0, nTotProPre := 0,;
         nTotGloPre  := 0, nVlContPre := 0, nTotAtePre := 0, nTotGer := 0,;
         nTotMatCon  := 0, nTotMedCon := 0, nTotTaxCon := 0, nTotFilCon := 0, nTotExaCon := 0, nTotProCon := 0,; 
         nTotGloCon  := 0, nVlContCon  := 0, nTotAteCon := 0
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                               ณ
 //ณ MV_PAR01	Data P/Processamento?   "Data de Atendimento" - "Data do Lote"  ณ
 //ณ MV_PAR02	De Data de Procesamento ?                                       ณ
 //ณ MV_PAR03	Ate Data de Processamento ?                                     ณ
 //ณ MV_PAR04	Do Prestador    ?                                               ณ
 //ณ MV_PAR05	Ate Prestador   ?                                               ณ
 //ณ MV_PAR06	Gerado Fatura   ?   "Sim" - "Nao" ou "Ambos"                    ณ
 //ณ MV_PAR07 Do Convenio     ?                	 																								     ณ
 //ณ MV_PAR08 Ate Convenio    ?        											      	  														     ณ
 //ณ MV_PAR09	Do Centro de Custo ?                                            ณ
 //ณ MV_PAR10	Ate Centro de Custo ?                                           ณ
 //ณ MV_PAR11	Tipo de Atendimento?  "Internacao" - "Ambulatorio" ou "Ambos"   ณ
 //ณ MV_PAR12	Relatorio?  "Analitico" ou  "Sintetico"                         ณ 
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRAE"

 If !Pergunte(cPerg,.T.)
 	return( Nil )
 EndIf
 
 Cabec1  := Space(95) + STR0006 + Dtoc(mv_par02) + STR0007 + Dtoc(mv_Par03)  //" Periodo de "###" Ate  "

 wnrel := SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

 If nLastKey == 27
	 Return( Nil )
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
 	Return( Nil )
 Endif
 nTipo := If(aReturn[4]==1,15,18)

 MsgRun(STR0008,STR0009,{|| PROCQRY() }) //"Aguarde montando consulta..."###"Processando"

 Processa({|lEnd| RunReport(@lEnd,Cabec1,Cabec2,Titulo/*,nLin*/) })

Return( Nil )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ MARCELO JOSE       บ Data ณ  10/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(lEnd,Cabec1,Cabec2,Titulo)

 Local  bWhile   := {||!Eof()},;
        nContaP  := 1,;
        lQuebra  := .T.
 
 ProcRegua(nCtaReg)
 
 If MV_PAR12 == 1

  While nContaP <= Len(aMatImp)
 
   IncProc( Str(nContaP,7,0) + STR0010 + Str(nCtaReg,7,0) + STR0011 +Alltrim(STR(m_pag, 6, 0)) + STR0012 ) //" de "###" Regs. "###" Pags."
  
   If nLin > 60 
	 	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	 nLin := 9
    IF m_pag > 1
     lQuebra := .T.
     nLin++
    ENDIF 
	  EndIf 	

   If cPrest <> aMatImp[nContaP,1]  // quebra por    P R E S T A D O R
    If cPrest <> "Start"  
     PROTOT(2) // TOTAL CONVENIO/PLANO
     PROTOT(1) // TOTAL PRESTADOR
     If nLin <> 9
    	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    	 nLin := 9                                                    
      IF m_pag > 1
       lQuebra := .T.
       nLin++
      ENDIF 
    	EndIf 
    EndIf
 	  @nLin, 000 Psay STR0013 + aMatImp[nContaP,1] + " - " + aMatImp[nContaP,2]  //"Prestador(a): "
    nLin := nLin+2
    cPrest  := aMatImp[nContaP,1]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf 
 
   If cConven <> aMatImp[nContaP,3] // quebra por    C O N V E N I O
    If cConven <> "Start"  
     PROTOT(2) // TOTAL CONVENIO/PLANO
    EndIf
    nLin++    
    @nLin, 000 Psay STR0014 + aMatImp[nContaP,3] + " - " + aMatImp[nContaP,4]  //"Convenio : "
    nLin := nLin + 2
    cConven := aMatImp[nContaP,3]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf
   IF lQuebra  
    @nLin,000  Psay STR0015 //"DT.ATEND    ATENDIMENTO  AMB/INT/PA  LOTE    FATURADO  NOME                                      SETOR      MATERIAIS   MEDICAMENTOS    TAXAS/DIAR.         FILMES         EXAMES   PROCEDIMENTO        GLOSA   VLR DA CONTA"
    nLin++
    lQuebra := .F.
   ENDIF
   @nLin,000  Psay aMatImp[nContaP, 5] 
   @nLin,012  Psay aMatImp[nContaP, 6] 
   @nLin,028  Psay aMatImp[nContaP, 7] 
   @nLin,037  Psay aMatImp[nContaP, 8] 
   @nLin,047  Psay aMatImp[nContaP, 9] 
   @nLin,055  Psay SUBSTR(aMatImp[nContaP,10],1,40) 
   @nLin,098  Psay aMatImp[nContaP,11] 
   @nLin,102  Psay transform(aMatImp[nContaP,12],"@E 99,999,999.99") 
   @nLin,117  Psay transform(aMatImp[nContaP,13],"@E 99,999,999.99") 
   @nLin,132  Psay transform(aMatImp[nContaP,14],"@E 99,999,999.99") 
   @nLin,147  Psay transform(aMatImp[nContaP,15],"@E 99,999,999.99")
   @nLin,162  Psay transform(aMatImp[nContaP,16],"@E 99,999,999.99") 
   @nLin,177  Psay transform(aMatImp[nContaP,17],"@E 99,999,999.99") 
   @nLin,190  Psay transform(aMatImp[nContaP,19],"@E 99,999,999.99") 
   @nLin,205  Psay transform(aMatImp[nContaP,18],"@E 99,999,999.99") 
   nLin++                                                                            

   nSomaCon := nSomaCon + aMatImp[nContaP,18]
   nSomaPre := nSomaPre + aMatImp[nContaP,18]                                        

   nContaP++  
  
  End
 
  PROTOT(2)
  PROTOT(1)
 
  FS_Resumo(Titulo, Cabec2)
 Else
   Titulo := STR0025 //"Relatorio Sintetico Prestador/Convenio/Setor"
   aSort(aSPrCoSet,,,{|x,y| x[1] + x[3] + x[5] < y[1] + y[3] + y[5]}) 
  While nContaP <= Len(aSPrCoSet) 
   IncProc( STR0026 ) //"Processando Relat. Sint. Prest./Conv./Set." 
     
   If nLin > 60 
	 	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	 nLin := 9
    IF m_pag > 1
     lQuebra := .T.
     nLin++
    ENDIF 
	  EndIf 	

   If cPrest <> aSPrCoSet[nContaP,1]  // quebra por    P R E S T A D O R
    If cPrest <> "Start"  
     PROTOT(4,1) // TOTAL CONVENIO
     PROTOT(3,1) // TOTAL PRESTADOR
     If nLin <> 9
    	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    	 nLin := 9                                                    
      IF m_pag > 1
       lQuebra := .T.
       nLin++
      ENDIF 
    	EndIf 
    EndIf
 	  @nLin, 000 Psay STR0013 + aSPrCoSet[nContaP,1] + " - " + aSPrCoSet[nContaP,2]  //"Prestador(a): "
    nLin := nLin+2
    cPrest  := aSPrCoSet[nContaP,1]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf 
 
   If cConven <> aSPrCoSet[nContaP,3] // quebra por    C O N V E N I O
    If cConven <> "Start"  
     PROTOT(4,1) // TOTAL CONVENIO/PLANO
    EndIf
    nLin++    
    @nLin, 000 Psay STR0014 + aSPrCoSet[nContaP,3] + " - " + aSPrCoSet[nContaP,4]  //"Convenio : "
    nLin := nLin + 2
    cConven := aSPrCoSet[nContaP,3]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf
   IF lQuebra  
              /*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
    @nLin,000  Psay STR0023 //"                                        QTD. ATEND.   SETOR     MATERIAIS   MEDICAMENTOS    TAXAS/DIAR.         FILMES         EXAMES   PROCEDIMENTO        GLOSA   VLR DA CONTA"
    nLin++
    lQuebra := .F.
   ENDIF
   @nLin,041  Psay PADL(ALLTRIM(STR(aSPrCoSet[nContaP, 15])),10)    
   @nLin,057  Psay aSPrCoSet[nContaP, 5]
   @nLin,063  Psay transform(aSPrCoSet[nContaP,8],"@E 99,999,999.99") 
   @nLin,078  Psay transform(aSPrCoSet[nContaP,7],"@E 99,999,999.99") 
   @nLin,093  Psay transform(aSPrCoSet[nContaP,9],"@E 99,999,999.99") 
   @nLin,108  Psay transform(aSPrCoSet[nContaP,10],"@E 99,999,999.99")
   @nLin,123  Psay transform(aSPrCoSet[nContaP,11],"@E 99,999,999.99") 
   @nLin,138  Psay transform(aSPrCoSet[nContaP,12],"@E 99,999,999.99") 
   @nLin,153  Psay transform(aSPrCoSet[nContaP,13],"@E 99,999,999.99") 
   @nLin,168  Psay transform(aSPrCoSet[nContaP,14],"@E 99,999,999.99") 
   nLin++                                                                            

   nTotAtePre := nTotAtePre + aSPrCoSet[nContaP, 15]
   nTotMatPre := nTotMatPre + aSPrCoSet[nContaP, 8]                                     
   nTotMedPre := nTotMedPre + aSPrCoSet[nContaP, 7] 
   nTotTaxPre := nTotTaxPre + aSPrCoSet[nContaP, 9] 
   nTotFilPre := nTotFilPre + aSPrCoSet[nContaP,10] 
   nTotExaPre := nTotExaPre + aSPrCoSet[nContaP,11] 
   nTotProPre := nTotProPre + aSPrCoSet[nContaP,12] 
   nTotGloPre := nTotGloPre + aSPrCoSet[nContaP,13] 
   nVlContPre := nVlContPre + aSPrCoSet[nContaP,14]
   
   nTotAteCon := nTotAteCon + aSPrCoSet[nContaP, 15]
   nTotMatCon := nTotMatCon + aSPrCoSet[nContaP, 8]                                     
   nTotMedCon := nTotMedCon + aSPrCoSet[nContaP, 7] 
   nTotTaxCon := nTotTaxCon + aSPrCoSet[nContaP, 9] 
   nTotFilCon := nTotFilCon + aSPrCoSet[nContaP,10] 
   nTotExaCon := nTotExaCon + aSPrCoSet[nContaP,11] 
   nTotProCon := nTotProCon + aSPrCoSet[nContaP,12] 
   nTotGloCon := nTotGloCon + aSPrCoSet[nContaP,13] 
   nVlContCon := nVlContCon + aSPrCoSet[nContaP,14]
   
   nTotGer := nTotGer + aSPrCoSet[nContaP,14]

   nContaP++  
  
  End
 
  PROTOT(4,1)
  PROTOT(3,1)
  PROTOT(5,1)
  
  nLin    := 61
  lQuebra := .T.
  nContaP := 1
  cPrest  := "Start"
  cConVen := "Start"
  Titulo := STR0027 //"Relatorio Sintetico Prestador/Convenio"
  aSort(aSPreCon,,,{|x,y| x[1] + x[3] < y[1] + y[3]})  
   
 While nContaP <= Len(aSPreCon) 
   IncProc( STR0028 ) //"Processando Relat. Sint. Prest./Conv." 
  
   If nLin > 60 
	 	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	 nLin := 9
    IF m_pag > 1
     lQuebra := .T.
     nLin++
    ENDIF 
	  EndIf 	

   If cPrest <> aSPreCon[nContaP,1]  // quebra por    P R E S T A D O R
    If cPrest <> "Start"  
     PROTOT(3,2) // TOTAL PRESTADOR
     If nLin <> 9
    	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    	 nLin := 9                                                    
      IF m_pag > 1
       lQuebra := .T.
       nLin++
      ENDIF 
    	EndIf 
    EndIf
 	  @nLin, 000 Psay STR0013 + aSPreCon[nContaP,1] + " - " + aSPreCon[nContaP,2]  //"Prestador(a): "
    nLin := nLin+2
    cPrest  := aSPreCon[nContaP,1]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf 
    
   IF lQuebra  
    @nLin,000  Psay STR0024 //"                                        QTD. ATEND.   MATERIAIS   MEDICAMENTOS    TAXAS/DIAR.         FILMES         EXAMES   PROCEDIMENTO        GLOSA   VLR DA CONTA"
    nLin++
    lQuebra := .F.
   ENDIF 
   @nLin,000  Psay SUBSTR(aSPreCon[nContaP, 3],1,3) + " - " + SUBSTR(aSPreCon[nContaP, 4],1,20)
   @nLin,041  Psay PADL(ALLTRIM(STR(aSPreCon[nContaP, 13])),10)    
   @nLin,053  Psay transform(aSPreCon[nContaP,6],"@E 99,999,999.99") 
   @nLin,068  Psay transform(aSPreCon[nContaP,5],"@E 99,999,999.99") 
   @nLin,083  Psay transform(aSPreCon[nContaP,7],"@E 99,999,999.99") 
   @nLin,098  Psay transform(aSPreCon[nContaP,8],"@E 99,999,999.99")
   @nLin,113  Psay transform(aSPreCon[nContaP,9],"@E 99,999,999.99") 
   @nLin,128  Psay transform(aSPreCon[nContaP,10],"@E 99,999,999.99") 
   @nLin,143  Psay transform(aSPreCon[nContaP,11],"@E 99,999,999.99") 
   @nLin,158  Psay transform(aSPreCon[nContaP,12],"@E 99,999,999.99") 
   nLin++                                                                            

   nTotAtePre := nTotAtePre + aSPreCon[nContaP, 13]
   nTotMatPre := nTotMatPre + aSPreCon[nContaP, 6]                                     
   nTotMedPre := nTotMedPre + aSPreCon[nContaP, 5] 
   nTotTaxPre := nTotTaxPre + aSPreCon[nContaP, 7] 
   nTotFilPre := nTotFilPre + aSPreCon[nContaP,8] 
   nTotExaPre := nTotExaPre + aSPreCon[nContaP,9] 
   nTotProPre := nTotProPre + aSPreCon[nContaP,10] 
   nTotGloPre := nTotGloPre + aSPreCon[nContaP,11] 
   nVlContPre := nVlContPre + aSPreCon[nContaP,12]
   
   nTotGer := nTotGer + aSPreCon[nContaP,12]

   nContaP++  
  
  End
 
  PROTOT(3,2)
  PROTOT(5,2)
  
 
  nLin    := 61
  lQuebra := .T.
  nContaP := 1
  cPrest  := "Start"
  cConVen := "Start"
  Titulo := STR0029 //"Relatorio Sintetico Prestador/Setor"
  aSort(aSPreSet,,,{|x,y| x[1] + x[3] < y[1] + y[3]})  
   
 While nContaP <= Len(aSPreSet) 
   IncProc( STR0030 ) //"Processando Relat. Sint. Prest./Set." 
  
   If nLin > 60 
	 	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	 nLin := 9
    IF m_pag > 1
     lQuebra := .T.
     nLin++
    ENDIF 
	  EndIf 	

   If cPrest <> aSPreSet[nContaP,1]  // quebra por    P R E S T A D O R
    If cPrest <> "Start"  
     PROTOT(3,2) // TOTAL PRESTADOR
     If nLin <> 9
    	 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    	 nLin := 9                                                    
      IF m_pag > 1
       lQuebra := .T.
       nLin++
      ENDIF 
    	EndIf 
    EndIf
 	  @nLin, 000 Psay STR0013 + aSPreSet[nContaP,1] + " - " + aSPreSet[nContaP,2]  //"Prestador(a): "
    nLin := nLin+2
    cPrest  := aSPreSet[nContaP,1]
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf 
    
   IF lQuebra  
    @nLin,000  Psay STR0024 //"                                        QTD. ATEND.   MATERIAIS   MEDICAMENTOS    TAXAS/DIAR.         FILMES         EXAMES   PROCEDIMENTO        GLOSA   VLR DA CONTA"
    nLin++
    lQuebra := .F.
   ENDIF 
   @nLin,000  Psay SUBSTR(aSPreSet[nContaP, 3],1,3) + " - " + SUBSTR(aSPreSet[nContaP, 4],1,20)
   @nLin,041  Psay PADL(ALLTRIM(STR(aSPreSet[nContaP, 13])),10)    
   @nLin,053  Psay transform(aSPreSet[nContaP,6],"@E 99,999,999.99") 
   @nLin,068  Psay transform(aSPreSet[nContaP,5],"@E 99,999,999.99") 
   @nLin,083  Psay transform(aSPreSet[nContaP,7],"@E 99,999,999.99") 
   @nLin,098  Psay transform(aSPreSet[nContaP,8],"@E 99,999,999.99")
   @nLin,113  Psay transform(aSPreSet[nContaP,9],"@E 99,999,999.99") 
   @nLin,128  Psay transform(aSPreSet[nContaP,10],"@E 99,999,999.99") 
   @nLin,143  Psay transform(aSPreSet[nContaP,11],"@E 99,999,999.99") 
   @nLin,158  Psay transform(aSPreSet[nContaP,12],"@E 99,999,999.99") 
   nLin++                                                                            

   nTotAtePre := nTotAtePre + aSPreSet[nContaP, 13]
   nTotMatPre := nTotMatPre + aSPreSet[nContaP, 6]                                     
   nTotMedPre := nTotMedPre + aSPreSet[nContaP, 5] 
   nTotTaxPre := nTotTaxPre + aSPreSet[nContaP, 7] 
   nTotFilPre := nTotFilPre + aSPreSet[nContaP,8] 
   nTotExaPre := nTotExaPre + aSPreSet[nContaP,9] 
   nTotProPre := nTotProPre + aSPreSet[nContaP,10] 
   nTotGloPre := nTotGloPre + aSPreSet[nContaP,11] 
   nVlContPre:= nVlContPre + aSPreSet[nContaP,12]
   
   nTotGer := nTotGer + aSPreSet[nContaP,12]

   nContaP++  
  
  End
 
  PROTOT(3,2)
  PROTOT(5,2)
 Endif
 
 Set Printer To
 SET DEVICE TO SCREEN

 If aReturn[5]==1
 	dbCommitAll()
 	SET PRINTER TO
 	OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return ( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PROCQRY  บ Autor ณ MARCELO JOSE       บ Data ณ  10/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MONTA QUERY                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION PROCQRY()

 Local cQuery   := "",;
        bWhile  := {||!Eof()},;
       cTpAten  := "",;
       nPos     := 0, nPosRes := 0,;
       cTipExa  := AllTrim(GetMv("MV_CTIPEXA"))
       
 DbSelectArea("GCY")
 DbSetorder(1)
 /******************************************************   MATERIAIS E MEDICAMENTOS */
 cQuery += "SELECT GCY_DATATE, GCY_CODCRM, GCY_CODLOC, "
 cQuery += "CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END AS CODPRE, "
 cQuery += "GAZ_CODPRE, GAZ_FANPRE, "
 cQuery += "GCS_CODLOC, GCS_NOMLOC, "
 cQuery += "GBI_TIPO, " 
 cQuery += "'          ' AS GAA_CODTXD, ' ' AS GAA_TIPDES, " 
 cQuery += "' ' AS GA7_TIPPRO, "   
 cQuery += "GCZ_REGATE, GCZ_NOME, GCZ_NRFATU, GCZ_ATENDI, GCZ_STATUS, GCZ_CODCON, "  
 cQuery += "GA9_NREDUZ,  "
 cQuery += "GAT_NUMLOT,  "
 cQuery += HS_FValDes("GE5") + " VALDES5, GE5_CODDES, GE5_VALGLO GLOSA5, "  
 cQuery += "0 AS VALDES6, '          ' AS GE6_CODDES, 0 GLOSA6, "  
 cQuery += "0 AS VALDES7, '         ' AS GE7_CODDES, 0 AS GE7_VFILME, 0 GLOSA7  "  

 cQuery += "FROM " + RetSqlName("GCY") + " GCY "

 cQuery += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ_REGATE = GCY_REGATE AND GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR07) .Or. !EMPTY(MV_PAR08) //FILTRA CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR07  + "' AND '" +  MV_PAR08 + "' " 
 EndIf 
 If MV_PAR06 == 1 // FILTRA GERADO FATURA SIM = 1 / NAO = 2
  cQuery += " AND GCZ_STATUS > '3'"
 ElseIf MV_PAR06 == 2
  cQuery += " AND GCZ_STATUS <= '3'"
 EndIf
 cQuery += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cQuery += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 


 cQuery += IIF(MV_PAR01 == 2, "JOIN ","LEFT JOIN ") + RetSqlName("GAT") + " GAT ON GAT_NUMLOT = GCZ_NRLOTE AND GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "
 IF MV_PAR01 == 2  // DATA PROCESSAMENTO = DATA DO LOTE
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO LOTE
   cQuery += " AND GAT_DTCRI BETWEEN '"  + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' " 
  EndIf
 ENDIF

 cQuery += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9_CODCON = GCZ_CODCON AND 	GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cQuery += "JOIN " + RetSqlName("GCS") + " GCS ON GCS_CODLOC = GCY_CODLOC AND 	GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 IF !EMPTY(MV_PAR09) .Or. !EMPTY(MV_PAR10) // FILTRA SETOR
  cQuery += "  AND GCS_CODLOC BETWEEN '" + MV_PAR09  + "' AND '" +  MV_PAR10 + "' " 
 EndIf
	
 cQuery += "LEFT JOIN " + RetSqlName("GE5") + " GE5 ON GE5_NRSEQG = GCZ_NRSEQG AND GE5_FILIAL  = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GBI") + " GBI ON GBI_PRODUT = GE5_CODDES	 AND GBI_FILIAL  = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "  
 
 cQuery += "LEFT JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ_CRM = GE5_CODCRM AND 	GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GFE") + " GFE ON GFE_CODCRM = GE5_CODCRM AND 	GFE_FILIAL = '" + xFilial("GFE") + "' AND GFE.D_E_L_E_T_ <> '*' AND GFE.GFE_CODLOC = GCY.GCY_CODLOC "

 cQuery += "LEFT JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ_CODPRE = (CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END) AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR04) .Or. !EMPTY(MV_PAR05) // FILTRA PRESTADOR
  cQuery += "  AND GAZ_CODPRE BETWEEN '" + MV_PAR04  + "' AND '" +  MV_PAR05 + "' " 
 EndIf

 cQuery += "WHERE "
 cQuery += "GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "

 If MV_PAR01 == 1  // DATA PROCESSAMENTO = DATA ATENDIMENTO
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO ATENDIMENTO
  	cQuery += " AND GCY_DATATE BETWEEN '" + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' "
 	ENDIF
 EndIf          

 IF MV_PAR11 != 4  // FILTRA TIPO DE ATENDIMENTO INT/AMB/PA/TODOS
  IF MV_PAR11 == 1
   cQuery += " AND GCY_ATENDI = '0'"
 	ELSEIF MV_PAR11 == 2                                     
   cQuery += " AND GCY_ATENDI = '1'"
 	ELSEIF MV_PAR11 == 3
   cQuery += " AND GCY_ATENDI = '2'"
  ENDIF
 ENDIF
                                                        
 /*******************************************************   TAXAS E DIARIAS*/
 cQuery += "Union All "
 cQuery += "SELECT GCY_DATATE, GCY_CODCRM, GCY_CODLOC, "
 cQuery += "CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END AS CODPRE, "
 cQuery += "GAZ_CODPRE, GAZ_FANPRE, "
 cQuery += "GCS_CODLOC, GCS_NOMLOC, "
 cQuery += "' ' AS GBI_TIPO, " 
 cQuery += "GAA_CODTXD, GAA_TIPDES, " 
 cQuery += "' ' AS GA7_TIPPRO, "   
 cQuery += "GCZ_REGATE, GCZ_NOME, GCZ_NRFATU, GCZ_ATENDI, GCZ_STATUS, GCZ_CODCON, "  
 cQuery += "GA9_NREDUZ,  "
 cQuery += "GAT_NUMLOT,  "
 cQuery += "0 AS VALDES5, '               ' AS GE5_CODDES, 0 GLOSA5, "  
 cQuery += HS_FValDes("GE6") + " VALDES6, GE6_CODDES, GE6_VALGLO GLOSA6, "  
 cQuery += "0 AS VALDES7, '         ' AS GE7_CODDES, 0 AS GE7_VFILME, 0 GLOSA7 "  

 cQuery += "FROM " + RetSqlName("GCY") + " GCY "

 cQuery += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ_REGATE = GCY_REGATE AND GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR07) .Or. !EMPTY(MV_PAR08) //FILTRA CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR07  + "' AND '" +  MV_PAR08 + "' " 
 EndIf 
 If MV_PAR06 == 1 // FILTRA GERADO FATURA SIM = 1 / NAO = 2
  cQuery += " AND GCZ_STATUS > '3'"
 ElseIf MV_PAR06 == 2
  cQuery += " AND GCZ_STATUS <= '3'"
 EndIf
 cQuery += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cQuery += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno  

 cQuery += IIF(MV_PAR01 == 2, "JOIN ","LEFT JOIN ") + RetSqlName("GAT") + " GAT ON GAT_NUMLOT = GCZ_NRLOTE AND GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "
 IF MV_PAR01 == 2  // DATA PROCESSAMENTO = DATA DO LOTE
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO LOTE
   cQuery += " AND GAT_DTCRI BETWEEN '"  + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' " 
  EndIf
 ENDIF

 cQuery += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9_CODCON = GCZ_CODCON AND 	GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cQuery += "JOIN " + RetSqlName("GCS") + " GCS ON GCS_CODLOC = GCY_CODLOC AND 	GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 IF !EMPTY(MV_PAR09) .Or. !EMPTY(MV_PAR10) // FILTRA SETOR
  cQuery += "  AND GCS_CODLOC BETWEEN '" + MV_PAR09  + "' AND '" +  MV_PAR10 + "' " 
 EndIf

 cQuery += "LEFT JOIN " + RetSqlName("GE6") + " GE6 ON GE6_NRSEQG = GCZ_NRSEQG AND GE6_FILIAL  = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GAA") + " GAA ON GAA_CODTXD = GE6_CODDES	 AND GAA_FILIAL  = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' " 

 cQuery += "LEFT JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ_CRM = GE6_CODCRM AND 	GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GFE") + " GFE ON GFE_CODCRM = GE6_CODCRM AND 	GFE_FILIAL = '" + xFilial("GFE") + "' AND GFE.D_E_L_E_T_ <> '*' AND GFE.GFE_CODLOC = GCY.GCY_CODLOC "

 cQuery += "LEFT JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ_CODPRE = (CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END) AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR04) .Or. !EMPTY(MV_PAR05) // FILTRA PRESTADOR
  cQuery += "  AND GAZ_CODPRE BETWEEN '" + MV_PAR04  + "' AND '" +  MV_PAR05 + "' " 
 EndIf

 cQuery += "WHERE "
 cQuery += "GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "

 If MV_PAR01 == 1  // DATA PROCESSAMENTO = DATA ATENDIMENTO
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO ATENDIMENTO
  	cQuery += " AND GCY_DATATE BETWEEN '" + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' "
 	ENDIF
 EndIf          

 IF MV_PAR11 != 4  // FILTRA TIPO DE ATENDIMENTO INT/AMB/PA/TODOS
  IF MV_PAR11 == 1
   cQuery += " AND GCY_ATENDI = '0'"
 	ELSEIF MV_PAR11 == 2                                     
   cQuery += " AND GCY_ATENDI = '1'"
 	ELSEIF MV_PAR11 == 3
   cQuery += " AND GCY_ATENDI = '2'"
  ENDIF
 ENDIF
 
 /******************************************************   PROCEDIMENTOS E HONORARIOS*/
 cQuery += "Union All "
 cQuery += "SELECT GCY_DATATE, GCY_CODCRM, GCY_CODLOC, "
 cQuery += "CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END AS CODPRE, "
 cQuery += "GAZ_CODPRE, GAZ_FANPRE, "
 cQuery += "GCS_CODLOC, GCS_NOMLOC, "
 cQuery += "' ' AS GBI_TIPO, " 
 cQuery += "'          ' AS GAA_CODTXD, ' ' AS GAA_TIPDES, " 
 cQuery += "GA7_TIPPRO, "   
 cQuery += "GCZ_REGATE, GCZ_NOME, GCZ_NRFATU, GCZ_ATENDI, GCZ_STATUS, GCZ_CODCON, "  
 cQuery += "GA9_NREDUZ,  "
 cQuery += "GAT_NUMLOT,  " 
 cQuery += "0 AS VALDES5, '               ' AS GE5_CODDES, 0 GLOSA5, "  
 cQuery += "0 AS VALDES6, '          ' AS GE6_CODDES, 0 GLOSA6, "  
 cQuery += HS_FValDes("GE7") + " VALDES7, GE7_CODDES, GE7_VFILME, GE7_VALGLO GLOSA7 "  

 cQuery += "FROM " + RetSqlName("GCY") + " GCY "

 cQuery += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ_REGATE = GCY_REGATE AND GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR07) .Or. !EMPTY(MV_PAR08) //FILTRA CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR07  + "' AND '" +  MV_PAR08 + "' " 
 EndIf 
 If MV_PAR06 == 1 // FILTRA GERADO FATURA SIM = 1 / NAO = 2
  cQuery += " AND GCZ_STATUS > '3'"
 ElseIf MV_PAR06 == 2
  cQuery += " AND GCZ_STATUS <= '3'"
 EndIf
 cQuery += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cQuery += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 

 cQuery += IIF(MV_PAR01 == 2, "JOIN ","LEFT JOIN ") + RetSqlName("GAT") + " GAT ON GAT_NUMLOT = GCZ_NRLOTE AND GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "
 IF MV_PAR01 == 2  // DATA PROCESSAMENTO = DATA DO LOTE
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO LOTE
   cQuery += " AND GAT_DTCRI BETWEEN '"  + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' " 
  EndIf
 ENDIF

 cQuery += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9_CODCON = GCZ_CODCON AND 	GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cQuery += "JOIN " + RetSqlName("GCS") + " GCS ON GCS_CODLOC = GCY_CODLOC AND 	GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 IF !EMPTY(MV_PAR09) .Or. !EMPTY(MV_PAR10) // FILTRA SETOR
  cQuery += "  AND GCS_CODLOC BETWEEN '" + MV_PAR09  + "' AND '" +  MV_PAR10 + "' " 
 EndIf

 cQuery += "LEFT JOIN " + RetSqlName("GE7") + " GE7 ON GE7_NRSEQG = GCZ_NRSEQG AND GE7_FILIAL  = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GA7") + " GA7 ON GA7_CODPRO = GE7_CODDES	 AND GA7_FILIAL  = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 
 cQuery += "LEFT JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ_CRM = GE7_CODCRM AND 	GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
 cQuery += "LEFT JOIN " + RetSqlName("GFE") + " GFE ON GFE_CODCRM = GE7_CODCRM AND 	GFE_FILIAL = '" + xFilial("GFE") + "' AND GFE.D_E_L_E_T_ <> '*' AND GFE.GFE_CODLOC = GCY.GCY_CODLOC "

 cQuery += "LEFT JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ_CODPRE = (CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END) AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 IF !EMPTY(MV_PAR04) .Or. !EMPTY(MV_PAR05) // FILTRA PRESTADOR
  cQuery += "  AND GAZ_CODPRE BETWEEN '" + MV_PAR04  + "' AND '" +  MV_PAR05 + "' " 
 EndIf
 
 cQuery += "WHERE "
 cQuery += "GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "

 If MV_PAR01 == 1  // DATA PROCESSAMENTO = DATA ATENDIMENTO
  IF !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03) // FILTRA DATA DO ATENDIMENTO
  	cQuery += " AND GCY_DATATE BETWEEN '" + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03) + "' "
 	ENDIF
 EndIf          

 IF MV_PAR11 != 4  // FILTRA TIPO DE ATENDIMENTO INT/AMB/PA/TODOS
  IF MV_PAR11 == 1
   cQuery += " AND GCY_ATENDI = '0'"
 	ELSEIF MV_PAR11 == 2                                     
   cQuery += " AND GCY_ATENDI = '1'"
 	ELSEIF MV_PAR11 == 3
   cQuery += " AND GCY_ATENDI = '2'"
  ENDIF
 ENDIF

 cQuery += "ORDER BY GAZ_CODPRE, GCZ_CODCON, GCY_DATATE, GCZ_REGATE  "
    
 cQuery := ChangeQuery(cQuery)
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
     
 DbSelectArea(cAliasQRY)
 DbGoTop()
 While (cAliasQRY)->(Eval(bWhile)) 
  nCtaReg++

  If MV_PAR12 == 1
   IIF((cAliasQRY)->GCZ_ATENDI == "0",cTpAten := STR0016,IIF((cAliasQRY)->GCZ_ATENDI == "1",cTpAten := STR0017,IIF((cAliasQRY)->GCZ_ATENDI == "2",cTpAten := STR0018 ,cTpAten := "    "))) //"Int."###"Amb."###"P.A."

   nPos := Ascan(aMatImp,{|x| x[6] == (cAliasQRY)->GCZ_REGATE }) 

   If nPos <= 0  // SE NAO ACHOU ATENDIMENTO ENTAO CRIA NOVO NA MATRIZ
    AADD(aMatImp,{"","","","","","","","","","","",0,0,0,0,0,0,0,0})
    nPos := Len(aMatImp)           
    aMatImp[nPos, 1] := (cAliasQRY)->GAZ_CODPRE
    aMatImp[nPos, 2] := (cAliasQRY)->GAZ_FANPRE
    aMatImp[nPos, 3] := (cAliasQRY)->GCZ_CODCON
    aMatImp[nPos, 4] := (cAliasQRY)->GA9_NREDUZ
    aMatImp[nPos, 5] := dtoc(stod((cAliasQRY)->GCY_DATATE))
    aMatImp[nPos, 6] := (cAliasQRY)->GCZ_REGATE
    aMatImp[nPos, 7] := IIF(!EMPTY(cTpAten ),cTpAten,"    ")
    aMatImp[nPos, 8] := IIF(!EMPTY((cAliasQRY)->GAT_NUMLOT),(cAliasQRY)->GAT_NUMLOT,"      ")
    aMatImp[nPos, 9] := IIf( (cAliasQRY)->GCZ_STATUS > "3" ,STR0019,STR0020) //"Sim"###"Nao"
    aMatImp[nPos,10] := (cAliasQRY)->GCZ_NOME
    aMatImp[nPos,11] := (cAliasQRY)->GCS_CODLOC
   EndIf                           
   
   // MATERIAIS E MEDICAMENTOS  
   IF (cAliasQRY)->GBI_TIPO == "1"
    aMatImp[nPos,13 ] := aMatImp[nPos,13 ] + (cAliasQRY)->VALDES5  // MEDICAMENTOS
    aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA
   Else
    aMatImp[nPos,12 ] := aMatImp[nPos,12 ] + (cAliasQRY)->VALDES5  // MATERIAIS
    aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA 
   ENDIF 
     
   // TAXAS   
   IF (cAliasQRY)->GAA_TIPDES == "2"  .OR. (cAliasQRY)->GAA_TIPDES == "7"
    aMatImp[nPos,14 ] := aMatImp[nPos,14 ] + (cAliasQRY)->VALDES6  // TAXAS
    aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->VALDES6  // VALOR DA CONTA
   ENDIF

   // FILMES EXAMES E PROCEDIMENTOS
   aMatImp[nPos,15 ] := aMatImp[nPos,15 ] + (cAliasQRY)->GE7_VFILME  // FILMES
   aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->GE7_VFILME  // VALOR DA CONTA

   IF (cAliasQRY)->GA7_TIPPRO $ cTipExa
    aMatImp[nPos,16 ] := aMatImp[nPos,16 ] + (cAliasQRY)->VALDES7  // EXAMES        
    aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ELSE
    aMatImp[nPos,17 ] := aMatImp[nPos,17 ] + (cAliasQRY)->VALDES7  // PROCEDIMENTOS
    aMatImp[nPos,18 ] := aMatImp[nPos,18 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ENDIF 
               
   //GLOSA
   aMatImp[nPos,19 ] := aMatImp[nPos,19 ] + (cAliasQRY)->GLOSA5 + (cAliasQRY)->GLOSA6 + (cAliasQRY)->GLOSA7
  
   nPosRes := Ascan(aResPre,{|x| x[1] == (cAliasQRY)->GAZ_CODPRE })
   If nPosRes == 0 
    AADD(aResPre, {(cAliasQRY)->GAZ_CODPRE, (cAliasQRY)->GAZ_FANPRE,(cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME })
   Else
    aResPre[nPosRes, 3] := aResPre[nPosRes, 3] + (cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME
   Endif
   
    nPosRes := Ascan(aResCon,{|x| x[1] == (cAliasQRY)->GCZ_CODCON })
   If nPosRes == 0 
    AADD(aResCon, {(cAliasQRY)->GCZ_CODCON, (cAliasQRY)->GA9_NREDUZ,(cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME})
   Else
    aResCon[nPosRes, 3] := aResCon[nPosRes, 3]+ (cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME
   Endif
   
    nPosRes := Ascan(aResSet,{|x| x[1] == (cAliasQRY)->GCS_CODLOC })
   If nPosRes == 0 
    AADD(aResSet, {(cAliasQRY)->GCS_CODLOC, (cAliasQRY)->GCS_NOMLOC, (cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME})
   Else
    aResSet[nPosRes, 3] := aResSet[nPosRes, 3] + (cAliasQRY)->VALDES5 + (cAliasQRY)->VALDES6 + (cAliasQRY)->VALDES7 + (cAliasQRY)->GE7_VFILME
   Endif
  
  Else
   // Relatorio Sintetico Prestador/Convenio/Setor
  
   nPos := Ascan(aSprCoSet,{|x| x[1] + x[3] + x[5] == (cAliasQRY)->GAZ_CODPRE + (cAliasQRY)->GCZ_CODCON + (cAliasQRY)->GCS_CODLOC }) 

   If nPos <= 0  // SE NAO ACHOU ATENDIMENTO ENTAO CRIA NOVO NA MATRIZ
    AADD(aSprCoSet,{"","","","","","", 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
    nPos := Len(aSprCoSet)           
    aSprCoSet[nPos, 1] := (cAliasQRY)->GAZ_CODPRE
    aSprCoSet[nPos, 2] := (cAliasQRY)->GAZ_FANPRE
    aSprCoSet[nPos, 3] := (cAliasQRY)->GCZ_CODCON
    aSprCoSet[nPos, 4] := (cAliasQRY)->GA9_NREDUZ
    aSprCoSet[nPos, 5] := (cAliasQRY)->GCS_CODLOC
    aSprCoSet[nPos, 6] := (cAliasQRY)->GCS_NOMLOC
   EndIf                           
   
   // MATERIAIS E MEDICAMENTOS  
   IF (cAliasQRY)->GBI_TIPO == "1"
    aSprCoSet[nPos, 7 ] := aSprCoSet[nPos, 7 ] + (cAliasQRY)->VALDES5  // MEDICAMENTOS
    aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA
   Else
    aSprCoSet[nPos, 8 ] := aSprCoSet[nPos, 8 ] + (cAliasQRY)->VALDES5  // MATERIAIS
    aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA 
   ENDIF 
     
   // TAXAS   
   IF (cAliasQRY)->GAA_TIPDES == "2"  .OR. (cAliasQRY)->GAA_TIPDES == "7"
    aSprCoSet[nPos, 9 ] := aSprCoSet[nPos, 9 ] + (cAliasQRY)->VALDES6  // TAXAS
    aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->VALDES6  // VALOR DA CONTA
   ENDIF

   // FILMES EXAMES E PROCEDIMENTOS
   aSprCoSet[nPos,10 ] := aSprCoSet[nPos,10 ] + (cAliasQRY)->GE7_VFILME  // FILMES
   aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->GE7_VFILME  // VALOR DA CONTA

   IF (cAliasQRY)->GA7_TIPPRO $ cTipExa
    aSprCoSet[nPos,11 ] := aSprCoSet[nPos,11 ] + (cAliasQRY)->VALDES7  // EXAMES        
    aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ELSE
    aSprCoSet[nPos,12 ] := aSprCoSet[nPos,12 ] + (cAliasQRY)->VALDES7  // PROCEDIMENTOS
    aSprCoSet[nPos,14 ] := aSprCoSet[nPos,14 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ENDIF 
               
   //GLOSA
   aSprCoSet[nPos,13 ] := aSprCoSet[nPos,13 ] + (cAliasQRY)->GLOSA5 + (cAliasQRY)->GLOSA6 + (cAliasQRY)->GLOSA7
   
   //QtdAten
   aSprCoSet[nPos,15 ] := aSprCoSet[nPos,15 ] + 1
  
   //Relatorio Sintetico Prestador/Convenio
   
   nPos := Ascan(aSPreCon,{|x| x[1] + x[3] == (cAliasQRY)->GAZ_CODPRE + (cAliasQRY)->GCZ_CODCON }) 

   If nPos <= 0  // SE NAO ACHOU ATENDIMENTO ENTAO CRIA NOVO NA MATRIZ
    AADD(aSPreCon,{"","","","", 0, 0, 0, 0, 0, 0, 0, 0, 0})
    nPos := Len(aSPreCon)           
    aSPreCon[nPos, 1] := (cAliasQRY)->GAZ_CODPRE
    aSPreCon[nPos, 2] := (cAliasQRY)->GAZ_FANPRE
    aSPreCon[nPos, 3] := (cAliasQRY)->GCZ_CODCON
    aSPreCon[nPos, 4] := (cAliasQRY)->GA9_NREDUZ
   EndIf                           
   
   // MATERIAIS E MEDICAMENTOS  
   IF (cAliasQRY)->GBI_TIPO == "1"
    aSPreCon[nPos, 5 ] := aSPreCon[nPos, 5 ] + (cAliasQRY)->VALDES5  // MEDICAMENTOS
    aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA
   Else
    aSPreCon[nPos, 6 ] := aSPreCon[nPos, 6 ] + (cAliasQRY)->VALDES5  // MATERIAIS
    aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA 
   ENDIF 
     
   // TAXAS   
   IF (cAliasQRY)->GAA_TIPDES == "2"  .OR. (cAliasQRY)->GAA_TIPDES == "7"
    aSPreCon[nPos, 7 ] := aSPreCon[nPos, 7 ] + (cAliasQRY)->VALDES6  // TAXAS
    aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->VALDES6  // VALOR DA CONTA
   ENDIF

   // FILMES EXAMES E PROCEDIMENTOS
   aSPreCon[nPos, 8 ] := aSPreCon[nPos, 8 ] + (cAliasQRY)->GE7_VFILME  // FILMES
   aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->GE7_VFILME  // VALOR DA CONTA

   IF (cAliasQRY)->GA7_TIPPRO $ cTipExa
    aSPreCon[nPos, 9 ] := aSPreCon[nPos, 9 ] + (cAliasQRY)->VALDES7  // EXAMES        
    aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ELSE
    aSPreCon[nPos,10 ] := aSPreCon[nPos,10 ] + (cAliasQRY)->VALDES7  // PROCEDIMENTOS
    aSPreCon[nPos,12 ] := aSPreCon[nPos,12 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ENDIF 
               
   //GLOSA
   aSPreCon[nPos,11 ] := aSPreCon[nPos,11 ] + (cAliasQRY)->GLOSA5 + (cAliasQRY)->GLOSA6 + (cAliasQRY)->GLOSA7
   
   //QtdAten
   aSPreCon[nPos,13 ] := aSPreCon[nPos,13 ] + 1
  
  //Relatorio Sintetico Prestador/Setor
  
  nPos := Ascan(aSPreSet,{|x| x[1] + x[3] == (cAliasQRY)->GAZ_CODPRE + (cAliasQRY)->GCS_CODLOC }) 

   If nPos <= 0  // SE NAO ACHOU ATENDIMENTO ENTAO CRIA NOVO NA MATRIZ
    AADD(aSPreSet,{"","","","", 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
    nPos := Len(aSPreSet)           
    aSPreSet[nPos, 1] := (cAliasQRY)->GAZ_CODPRE
    aSPreSet[nPos, 2] := (cAliasQRY)->GAZ_FANPRE
    aSPreSet[nPos, 3] := (cAliasQRY)->GCS_CODLOC
    aSPreSet[nPos, 4] := (cAliasQRY)->GCS_NOMLOC
   EndIf                           
   
   // MATERIAIS E MEDICAMENTOS  
   IF (cAliasQRY)->GBI_TIPO == "1"
    aSPreSet[nPos, 5 ] := aSPreSet[nPos, 5 ] + (cAliasQRY)->VALDES5  // MEDICAMENTOS
    aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA
   Else
    aSPreSet[nPos, 6 ] := aSPreSet[nPos, 6 ] + (cAliasQRY)->VALDES5  // MATERIAIS
    aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->VALDES5  // VALOR DA CONTA 
   ENDIF 
     
   // TAXAS   
   IF (cAliasQRY)->GAA_TIPDES == "2"  .OR. (cAliasQRY)->GAA_TIPDES == "7"
    aSPreSet[nPos, 7 ] := aSPreSet[nPos, 7 ] + (cAliasQRY)->VALDES6  // TAXAS
    aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->VALDES6  // VALOR DA CONTA
   ENDIF

   // FILMES EXAMES E PROCEDIMENTOS
   aSPreSet[nPos, 8 ] := aSPreSet[nPos, 8 ] + (cAliasQRY)->GE7_VFILME  // FILMES
   aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->GE7_VFILME  // VALOR DA CONTA

   IF (cAliasQRY)->GA7_TIPPRO $ cTipExa
    aSPreSet[nPos, 9 ] := aSPreSet[nPos, 9 ] + (cAliasQRY)->VALDES7  // EXAMES        
    aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ELSE
    aSPreSet[nPos,10 ] := aSPreSet[nPos,10 ] + (cAliasQRY)->VALDES7  // PROCEDIMENTOS
    aSPreSet[nPos,12 ] := aSPreSet[nPos,12 ] + (cAliasQRY)->VALDES7  // VALOR DA CONTA
   ENDIF 
               
   //GLOSA
   aSPreSet[nPos,11 ] := aSPreSet[nPos,11 ] + (cAliasQRY)->GLOSA5 + (cAliasQRY)->GLOSA6 + (cAliasQRY)->GLOSA7
   
   //QtdAten
   aSPreSet[nPos,13 ] := aSPreSet[nPos,13 ] + 1
  
  Endif
  dbSkip()
   
 End
 dbCloseArea()

RETURN( NIL )                                                               
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PROTOT   บ Autor ณ MARCELO JOSE       บ Data ณ  07/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PROCESSA TOTAIS DAS QUEBRAS                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION PROTOT(nQual, nTpSin)
 If nQual == 1
  nLin++   
  @nLin, 176 Psay STR0021 + Transform(nSomaPre,"@E 999,999,999.99")  //"Total do Prestador --------> "
  nSomaPre := 0
  cConven := "Start"
 ElseIf nQual == 2
  nLin++ 
  @nLin, 176 Psay STR0022 + Transform(nSomaCon,"@E 999,999,999.99")  //"Total do Convenio ---------> "
  nSomaCon := 0
 ElseIf nQual == 3
  nLin++   
  @nLin,000  Psay STR0021  //"Total do Prestador --------> "   
  @nLin,041  Psay PADL(ALLTRIM(STR(nTotAtePre)),10) 
  @nLin,IIF(nTpSin == 1, 063, 053)  Psay transform(nTotMatPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 078, 068)  Psay transform(nTotMedPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 093, 083)  Psay transform(nTotTaxPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 108, 098)  Psay transform(nTotFilPre,"@E 99,999,999.99")
  @nLin,IIF(nTpSin == 1, 123, 113)  Psay transform(nTotExaPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 138, 128)  Psay transform(nTotProPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 153, 143)  Psay transform(nTotGloPre,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 168, 158)  Psay transform(nVlContPre,"@E 99,999,999.99") 

  nTotAtePre := 0
  nTotMatPre := 0 
  nTotMedPre := 0
  nTotTaxPre := 0  
  nTotFilPre := 0    
  nTotExaPre := 0  
  nTotProPre := 0   
  nTotGloPre := 0  
  nVlContPre := 0
  cConven := "Start"
 ElseIf nQual == 4 
  nLin++   
  @nLin,000  Psay STR0022  //"Total do Convenio ---------> "   
  @nLin,041  Psay PADL(ALLTRIM(STR(nTotAteCon)),10) 
  @nLin,IIF(nTpSin == 1, 063, 053)  Psay transform(nTotMatCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 078, 068)  Psay transform(nTotMedCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 093, 083)  Psay transform(nTotTaxCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 108, 098)  Psay transform(nTotFilCon,"@E 99,999,999.99")
  @nLin,IIF(nTpSin == 1, 123, 113)  Psay transform(nTotExaCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 138, 128)  Psay transform(nTotProCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 153, 143)  Psay transform(nTotGloCon,"@E 99,999,999.99") 
  @nLin,IIF(nTpSin == 1, 168, 158)  Psay transform(nVlContCon,"@E 99,999,999.99") 

  
  nTotAteCon := 0
  nTotMatCon := 0 
  nTotMedCon := 0
  nTotTaxCon := 0  
  nTotFilCon := 0    
  nTotExaCon := 0  
  nTotProCon := 0   
  nTotGloCon := 0  
  nVlContCon := 0  
 ElseIf nQual == 5
  nLin++ 
  @nLin, IIF(nTpSin == 1, 136, 126) Psay "Total Geral ---------------> " + Transform(nTotGer,"@E 9,999,999,999.99")  
  nTotGer := 0
 EndIf
RETURN( NIL )      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Resumo บ Autor ณMario Arizono       บ Data ณ  20/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime Resumo                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_Resumo(Titulo, Cabec2)
 Local nForRes := 0, nTotRes := 0
  
 aSort(aResPre,,,{|x,y| x[2] < y[2]})
 aSort(aResCon,,,{|x,y| x[2] < y[2]})
 aSort(aResSet,,,{|x,y| x[2] < y[2]})
 
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9                                                    
  
 @nLin,   185 psay STR0031 //"RESUMO POR PRESTADOR"
 nLin +=2         
               
                 
For nForRes := 1 To Len(aResPre)
 nLin++
 @nLin, 165 psay SubStr(aResPre[nForRes,2], 1, 30)
 @nLin, 202 psay transform(aResPre[nForRes,3],"@E 9,999,999,999.99")
  
 nTotRes += aResPre[nForRes,3]
 If nLin > 60
  Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  nLin := 9
 Endif      
Next

If nLin > 60
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9
Endif 
 nLin += 2
 @nLin,   172 psay STR0021 //"Total do Prestador------>"
 @nLin,   203 psay transform(nTotRes,"@E 9,999,999,999.99") 
 nTotRes := 0



Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9                                                    
  
 @nLin,   185 psay STR0032 //"RESUMO POR CONVENIO"
 nLin +=2         
               
                 
For nForRes := 1 To Len(aResCon)
 nLin++
 @nLin, 165 psay SubStr(aResCon[nForRes,2], 1, 20)
 @nLin, 203 psay transform(aResCon[nForRes,3],"@E 9,999,999,999.99")
  
 nTotRes += aResCon[nForRes,3]
 If nLin > 60
  Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  nLin := 9
 Endif      
Next

If nLin > 60
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9
Endif
 nLin += 2
 @nLin,   172 psay STR0022 //"Total do Convenio------->"
 @nLin,   203 psay transform(nTotRes,"@E 9,999,999,999.99") 
 nTotRes := 0


Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9                                                    
  
 @nLin,   175 psay STR0033 // "RESUMO POR SETOR"
 nLin +=2         
               
                 
For nForRes := 1 To Len(aResSet)
 nLin++
 @nLin, 165 psay SubStr(aResSet[nForRes,2], 1, 30)
 @nLin, 203 psay transform(aResSet[nForRes,3],"@E 9,999,999,999.99")
  
 nTotRes += aResSet[nForRes,3]
 If nLin > 60
  Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  nLin := 9
 Endif      
Next

If nLin > 60
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9
Endif
 nLin += 2
 @nLin, 172 psay STR0034 //"Total do Setor -----------> "
 @nLin, 203 psay transform(nTotRes,"@E 9,999,999,999.99") 

 aResPre := {}
 aResCon := {}
 aResSet := {}
 
Return (Nil)        

#INCLUDE "HSPAHR44.ch"
#Include "protheus.ch"
#include "TopConn.ch"                                                        


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR44  บ Autor ณ Mario Arizono      บ Data ณ  22/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Solicitacoes por setor/produto                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR44()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         :=  STR0003 //"Solic. Setor/Produto"
Local nLin           := 80 
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				      := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHR44" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}      //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR44" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR44"
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   ณ PARAMETROS                                                       ณ
   ณ MV_PAR01	Do Setor Solicitante                                    ณ
   ณ MV_PAR02	Ate o Setor Solicitante                                 ณ
   ณ MV_PAR03	Da Data de Solicitacao                                  ณ
   ณ MV_PAR04	Ate a Data de Solicitacao                               ณ
   ณ MV_PAR05	Emite Paciente       1=sim;2=nao                        ณ
   ณ MV_PAR06	Emite Parcial        1=sim;2=nao                        ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */


If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  22/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Local nPos       := 0
Local nPosVet    := 0
Private cCodLoc  := ""      
Private cCodPro  := ""
Private cDesPro  := "" 
Private cAprese  := ""
Private nQtdSol  := 0 
Private aVet     := {}   


 cSQL := "SELECT GAI.GAI_CODLOC, GAI.GAI_SOLICI, GAI.GAI_REGATE, GAI.GAI_DATSOL, GAI.GAI_FLGATE, "
 cSQL += "GAJ.GAJ_QTDSOL, GAJ.GAJ_QTDATE, GAJ.GAJ_PROSOL,GCS.GCS_NOMLOC, GCY.GCY_REGGER, GCY.GCY_NOME, "  
 cSQL += "GCY.GCY_QUAINT, GCY.GCY_LEIINT, SB1.B1_DESC, SAH.AH_UMRES "
 cSQL += " FROM " + RetSQLName("GAI") + " GAI"                                   
 cSQL += " JOIN " + RetSQLName("GAJ") + " GAJ ON GAJ.GAJ_SOLICI = GAI.GAI_SOLICI"
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GAI.GAI_CODLOC"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GAI.GAI_REGATE"
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GAJ.GAJ_PROSOL" 
 cSQL += " JOIN " + RetSQLName("SAH") + " SAH ON SAH.AH_UNIMED  = SB1.B1_SEGUM" 
 cSQL += " WHERE"
 cSQL += "     GAI.GAI_FILIAL = '" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAJ.GAJ_FILIAL = '" + xFilial("GAJ") + "' AND GAJ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND SB1.B1_FILIAL = '"  + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "    
 cSQL += " AND SAH.AH_FILIAL = '"  + xFilial("SAH") + "' AND SAH.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GAI.GAI_CODLOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += " AND GAI.GAI_DATSOL BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 If MV_PAR06=1
  cSQL+= "AND GAI.GAI_FLGATE IN ('0','1')"
 Else
  cSQL+= "AND GAI.GAI_FLGATE = '0'"
 Endif   
 If MV_PAR05=2
  cSQL += "ORDER BY GAI_CODLOC, B1_DESC"
 Else
  cSQL += "ORDER BY GAI_CODLOC, B1_DESC, GCY_QUAINT, GCY_LEIINT"
 Endif
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0011, STR0012)  //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Sele็ใo"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
/*              	                       1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        			                   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 := STR0008    //"Produto          Descricao                            Apresentacao   Quantidade"
      Cabec2 := STR0009    //"Quarto    Leito    Nome                                              Quantidade"
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif  
   
   If Empty(cCodLoc)
    If cCodLoc <> QRY->GAI_CODLOC  
     nLin += 2
     @nLin,000 PSAY STR0010 + 	QRY->GAI_CODLOC + " - " + QRY->GCS_NOMLOC    //"Setor......: "
     nLin +=2
    EndIf 
   Endif
   If mv_par05 == 2 .AND. !Empty(cCodPro)
    If cCodPro <> QRY->GAJ_PROSOL .AND. nQtdSol <> 0 
     @nLin,000 PSAY cCodPro  //Codigo do produto
     @nLin,017 PSAY cDesPro  //Descricao do produto 
     @nLin,054 PSAY cAprese  //Apresentacao     
     @nLin,069 PSAY nQtdSol  //Quantidade do produto  
     nLin++
     nQtdSol:=0
    Endif    
   ElseIf mv_par05 <> 2 .AND. !Empty(cCodPro)   
    If cCodPro <> QRY->GAJ_PROSOL .AND. nQtdSol <> 0   
     nLin++
     @nLin,000 PSAY cCodPro
     @nLin,017 PSAY cDesPro   
     @nLin,054 PSAY cAprese       
     @nLin,069 PSAY nQtdSol  
     nLin+=2 
     for nPosVet:=1 to len(aVet) 
      If aVet[nPosVet,4] <> 0  
       @nLin,000 PSAY aVet[nPosVet,1]   //Quarto
       @nLin,010 PSAY aVet[nPosVet,2]   //Leito
       @nLin,019 PSAY aVet[nPosVet,3]   //Paciente
       @nLin,069 PSAY aVet[nPosVet,4]   //Quantidade  do produto solicitada pelo paciente
       nLin++
      Endif   
     next 
     aVet:= {}  
     nQtdSol:=0        
    Endif     
   Endif  
     
   If cCodLoc <> QRY->GAI_CODLOC   
    If !Empty(cCodLoc) 
     nLin += 2
     @nLin,000 PSAY STR0010 + 	QRY->GAI_CODLOC + " - " + QRY->GCS_NOMLOC      //"Setor......: "
     nLin +=2  
    Endif
   EndIf 
   cAprese := QRY->AH_UMRES 
   cDespro := QRY->B1_DESC 
   If mv_par06==1                       
    nQtdSol += (QRY->GAJ_QTDSOL-QRY->GAJ_QTDATE)
   Else
    nQtdSol += QRY->GAJ_QTDSOL
   Endif  
   cCodLoc := QRY->GAI_CODLOC   
   cCodPro := QRY->GAJ_PROSOL   
  
   nPos := aScan(aVet,{|x|x[5]==QRY->GCY_REGGER})  
   If nPos == 0 
    AADD(aVet,{QRY->GCY_QUAINT, QRY->GCY_LEIINT, QRY->GCY_NOME, (QRY->GAJ_QTDSOL-QRY->GAJ_QTDATE), QRY->GCY_REGGER}) 
   Else 
    If mv_par06==2
     aVet[nPos,4] += QRY->GAJ_QTDSOL
    Else
     aVet[nPos,4] += (QRY->GAJ_QTDSOL-QRY->GAJ_QTDATE)
    Endif 
   Endif         
     
  dbSkip() /* Avanca o ponteiro do registro no arquivo */  

EndDo

If EOF () .AND.  MV_PAR05 == 2
 @nLin,000 PSAY cCodPro
 @nLin,017 PSAY cDesPro   
 @nLin,054 PSAY cAprese       
 @nLin,069 PSAY nQtdSol  
 nLin++    
ElseIf EOF () .AND. MV_PAR05 == 1
 nLin++
 @nLin,000 PSAY cCodPro
 @nLin,017 PSAY cDesPro   
 @nLin,054 PSAY cAprese       
 @nLin,069 PSAY nQtdSol  
 nLin+=2     
 for nPosVet:=1 to len(aVet) 
  If aVet[nPosVet,4] <> 0  
   @nLin,000 PSAY aVet[nPosVet,1]
   @nLin,010 PSAY aVet[nPosVet,2]
   @nLin,019 PSAY aVet[nPosVet,3]
   @nLin,069 PSAY aVet[nPosVet,4]
   nLin++
  Endif   
 next 
Endif                                                                                        


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Finaliza a execucao do relatorio...                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return   
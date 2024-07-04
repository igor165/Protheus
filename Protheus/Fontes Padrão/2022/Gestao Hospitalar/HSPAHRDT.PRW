#INCLUDE "HSPAHRDT.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDT  บ Autor ณ Mario Arizono    บ Data ณ  25/07/05     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Equipe por Paciente                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDT()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Equipe por Paciente"
Local nLin           := 80 
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}   


Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "HSPAHRDT" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}      //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDT" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRDT"
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                       ณ
 ณ MV_PAR01	Do Setor                                                ณ
 ณ MV_PAR02	Ate o Setor                                             ณ
 ณ MV_PAR03	Da Data                                                 ณ
 ณ MV_PAR04	Ate a Data                                              ณ
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono     บ Data ณ  25/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Private cCodReg  := ""      


 cSQL := "SELECT GBH.GBH_NOME, GDZ.GDZ_CODCRM, SRA.RA_NOME, GDZ.GDZ_DATATO, GDZ.GDZ_HORATO, GDZ.GDZ_DATSAI,"
 cSQL += "GDZ.GDZ_HORSAI, GCY.GCY_CODLOC, GCS.GCS_NOMLOC, GDZ.GDZ_CODATO, GMC.GMC_DESATO, GCY.GCY_REGATE,"
 cSQL += "GCY.GCY_REGGER"
 cSQL += " FROM " + RetSQLName("GCY") + " GCY"                                   
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER" 
 cSQL += " JOIN " + RetSQLName("GDZ") + " GDZ ON GDZ.GDZ_REGATE = GCY.GCY_REGATE"  
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC"  
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GDZ.GDZ_CODCRM"
 cSQL += " JOIN " + RetSQLName("GMC") + " GMC ON GMC.GMC_CODATO = GDZ.GDZ_CODATO" 
 cSQL += " WHERE"
 cSQL += "     GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "   
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GMC.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GDZ.GDZ_FILIAL = '" + xFilial("GDZ") + "' AND GDZ.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += " AND SRA.RA_FILIAL = '" + xFilial("SRA") + "'  AND SRA.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GMC.GMC_FILIAL = '" + xFilial("GMC") + "' AND GMC.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += " AND GDZ.GDZ_DATATO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSQL += " ORDER BY GBH_NOME, GDZ_DATATO"
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0011, STR0012)  //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Funcao aux. chamada pela RPTSTATUS"
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
/*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 := STR0008 //"Paciente"
      Cabec2 := STR0009    //"Ato Medico                                   CRM       Nome                              Dt. Ent.   Hr. Ent.   Dt. Sai.   Hr. Sai.   Permanencia       Setor "
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 10
   Endif

   If cCodReg <> QRY->GCY_REGATE  
    If !Empty(cCodReg)
     nLin++
    Endif  
    @nLin,000 PSAY QRY->GCY_REGGER +" - "+ QRY->GBH_NOME  
    nLin +=2
   EndIf
    
   cCodReg := QRY->GCY_REGATE
                                 
   @nLin,000 PSAY QRY->GMC_DESATO
   @nLin,045 PSAY QRY->GDZ_CODCRM
   @nLin,055 PSAY QRY->RA_NOME 
   @nLin,089 PSAY DTOC(STOD(QRY->GDZ_DATATO))
   @nLin,100 PSAY QRY->GDZ_HORATO
   @nLin,111 PSAY DTOC(STOD(QRY->GDZ_DATSAI))
   @nLin,122 PSAY QRY->GDZ_HORSAI  
   FS_ImpPer(nLin)
   @nLin,151 PSAY QRY->GCS_NOMLOC 

   dbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
   nLin ++
 EndDo
                                                                                        


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
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpPer บ Autor ณ Mario Arizono     บ Data ณ  25/07/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao utilizada para mostrar no relatorio a permanencia   บฑฑ
ฑฑบ          ณ de cada membro da equipe medica do paciente.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    
Static Function FS_ImpPer(nLin)    
If Empty(QRY->GDZ_HORSAI)
    @nLin, 133 PSAY STR0010 //"Dt. Sai. Branco"
  Else  
    If STOD(QRY->GDZ_DATATO)==STOD(QRY->GDZ_DATSAI)  
      nHoras := SubHoras(QRY->GDZ_HORSAI,QRY->GDZ_HORATO)  
      cHoras := ALLTRIM(STR(nHoras))  
      If Len (ALLTRIM(STR(nHoras))) <= 2
        cHoras := StrZero(nHoras,2)     
        cHoras := Stuff(cHoras,3,3,":")
        cHoras := Stuff(cHoras,4,4,"0")   
        cHoras := Stuff(cHoras,5,5,"0")
      ElseIf Len( ALLTRIM(STR(nHoras)))==3    
        cHoras := ALLTRIM(STR(nHoras))
        cHoras := Stuff(cHoras,1,0,"0")  
        cHoras := Stuff(cHoras,5,5,"0")
        cHoras := Strtran(cHoras,".",":")
      ElseIf Len (ALLTRIM(STR(nHoras)))==4   
        If nHoras > 10  
          cHoras := ALLTRIM(STR(nHoras)) 
          cHoras := Stuff(cHoras,5,5,"0")
          cHoras := Strtran(cHoras,".",":")
        Else 
          cHoras := ALLTRIM(STR(nHoras))
          cHoras := Stuff(cHoras,1,0,"0")
          cHoras := Strtran(cHoras,".",":")     
        Endif   
      Endif         
    @nLin, 133 PSAY Strtran(cHoras,".",":")   
    Else
      If QRY->GDZ_HORATO > QRY->GDZ_HORSAI .AND. ALLTRIM(STR(STOD(QRY->GDZ_DATSAI)-STOD(QRY->GDZ_DATATO)))=="1"
        nHorin  := SubHoras(24,QRY->GDZ_HORATO)
        nHorfin := SubHoras(QRY->GDZ_HORSAI,00)
        nTot    := SomaHoras(nHorin,nHorfin) 
        cHoras  := ALLTRIM(STR(nTot))  
        If Len(ALLTRIM(STR(nTot))) <= 2
          cHoras := StrZero(nTot,2)     
          cHoras := Stuff(cHoras,3,3,":")
          cHoras := Stuff(cHoras,4,4,"0")   
          cHoras := Stuff(cHoras,5,5,"0")
        ElseIf Len(ALLTRIM(STR(nTot)))==3    
          cHoras := ALLTRIM(STR(nTot))
          cHoras := Stuff(cHoras,1,0,"0")  
          cHoras := Stuff(cHoras,5,5,"0")
          cHoras := Strtran(cHoras,".",":")
        ElseIf Len(ALLTRIM(STR(nTot)))==4   
          If nTot > 10  
           cHoras := ALLTRIM(STR(nTot)) 
           cHoras := Stuff(cHoras,5,5,"0")
           cHoras := Strtran(cHoras,".",":")
          Else 
           cHoras := ALLTRIM(STR(nTot))
           cHoras := Stuff(cHoras,1,0,"0")
           cHoras := Strtran(cHoras,".",":")     
          Endif   
        Endif         
      @nLin, 133 PSAY Strtran(cHoras,".",":")   
      ElseIf QRY->GDZ_HORATO > QRY->GDZ_HORSAI .AND. ALLTRIM(STR(STOD(QRY->GDZ_DATSAI)-STOD(QRY->GDZ_DATATO)))>"1"
        nHorin  := SubHoras(24,QRY->GDZ_HORATO)
        nHorfin := SubHoras(QRY->GDZ_HORSAI,00)
        nTot    := SomaHoras(nHorin,nHorfin)
        nTotDat := ALLTRIM(STR((STOD(QRY->GDZ_DATSAI)-STOD(QRY->GDZ_DATATO)-1)*24)) 
        nImpHor := SomaHoras(nTotDat,nTot) 
        cHoras  := ALLTRIM(STR(nImpHor))  
        If Len(ALLTRIM(STR(nImpHor))) <= 2
          cHoras := StrZero(nImpHor,2)     
          cHoras := Stuff(cHoras,3,3,":")
          cHoras := Stuff(cHoras,4,4,"0")   
          cHoras := Stuff(cHoras,5,5,"0")
        ElseIf Len( ALLTRIM( STR(nImpHor) ) )==3    
          cHoras := ALLTRIM(STR(nImpHor))
          cHoras := Stuff(cHoras,1,0,"0")  
          cHoras := Stuff(cHoras,5,5,"0")
          cHoras := Strtran(cHoras,".",":")
        ElseIf Len( ALLTRIM( STR(nImpHor) ) )==4   
          If nImpHor > 10  
            cHoras := ALLTRIM(STR(nImpHor)) 
            cHoras := Stuff(cHoras,5,5,"0")
            cHoras := Strtran(cHoras,".",":")
          Else 
            cHoras := ALLTRIM(STR(nImpHor))
            cHoras := Stuff(cHoras,1,0,"0")
            cHoras := Strtran(cHoras,".",":")     
          Endif   
        Endif         
      @nLin, 133 PSAY Strtran(cHoras,".",":")   
      ElseIf QRY->GDZ_HORSAI >= QRY->GDZ_HORATO
        nHoras  := SubHoras(QRY->GDZ_HORSAI,QRY->GDZ_HORATO)
        nTotHor := ALLTRIM(STR((STOD(QRY->GDZ_DATSAI)-STOD(QRY->GDZ_DATATO))*24+nHoras))
        nTot    := Val(nTotHor)
        cHoras  := ALLTRIM(STR(nTot))  
        If Len(ALLTRIM( STR(nTot))) <= 2
          cHoras := StrZero(nTot,2)     
          cHoras := Stuff(cHoras,3,3,":")
          cHoras := Stuff(cHoras,4,4,"0")   
          cHoras := Stuff(cHoras,5,5,"0")
        ElseIf Len (ALLTRIM(STR(nTot)))==3    
          cHoras := ALLTRIM(STR(nTot))
          cHoras := Stuff(cHoras,1,0,"0")  
          cHoras := Stuff(cHoras,5,5,"0")
          cHoras := Strtran(cHoras,".",":")
        ElseIf Len (ALLTRIM(STR(nTot)))==4   
          If nTot > 10  
            cHoras := ALLTRIM(STR(nTot)) 
            cHoras := Stuff(cHoras,5,5,"0")
            cHoras := Strtran(cHoras,".",":")
          Else 
            cHoras := ALLTRIM(STR(nTot))
            cHoras := Stuff(cHoras,1,0,"0")
            cHoras := Strtran(cHoras,".",":")     
          Endif   
        Endif         
      @nLin, 133 PSAY Strtran(cHoras,".",":")   
      EndIf
    Endif  
EndIf 
Return(NIL)    
                  
 
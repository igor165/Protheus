#INCLUDE "HSPAHRDJ.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDJ  บ Autor ณ Daniel Peixoto     บ Data ณ  20/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio PROCEDIMENTOS REALIZADOS SINTETICO               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDJ()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0031 //"Procedimento Real. Sint."
Local nLin           := 80
/*                       					 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
               					 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
Local Cabec1         := STR0004 //"Grupo de Procedimento"
Local Cabec2         := STR0032 //"            Procedimento                                Qtd     %Grupo    %Geral"
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.             
Private lAbortPrint  := .F.
Private limite       := 80                  
Private tamanho      := "P"
Private nomeprog     := "HSPAHRDJ" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0006, 1, STR0007, 2, 2, 1, "", 1}       //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := nomeprog
Private cPerg        := "HSPRDJ"
Private lErrPerg 	   := .T.  
Private lRetPerg     := .T.
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                           ณ
 ณ MV_PAR01	Do Periodo Atend?                                           ณ
 ณ MV_PAR02	Ate Periodo Atend?                                          ณ
 ณ MV_PAR03	Do Grupo Proced.?                                           ณ
 ณ MV_PAR04	Ate Grupo Proced.?  				  	                            ณ 
 ณ MV_PAR05	Do Proced.?                     					                  ณ
 ณ MV_PAR06	Ate Prced.?                               					        ณ
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  18/05/05   บฑฑ
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
Private cGruPro  := ""
Private cCodPro  := ""
Private nTotPro  := 0
Private nTotGru  := 0
Private nTotGer  := 0     
Private aVetor   := {}

 cSQL := "SELECT "
 cSQL += "GAQ.GAQ_GRUPRO, GAQ.GAQ_DESC, GA9.GA9_CODCON, GA9.GA9_NREDUZ, GCY.GCY_REGATE, GCY.GCY_NOME, GCY.GCY_DATATE, "
 cSQL += "GD7.GD7_DATDES, GD7.GD7_HORDES, GD7.GD7_CODDES, GD7.GD7_QTDDES, GA7.GA7_CODPRO , GA7.GA7_DESC, GCS.GCS_NOMLOC, SRA.RA_NOME "
 cSQL += "FROM " + RetSQLName("GD7") + " GD7 " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GAQ") + " GAQ ON GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GD7.GD7_REGATE  AND GCY.GCY_TPALTA <> '99' " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GD7.GD7_CODLOC " + Chr(13)+Chr(10)
 cSQL += "JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = GD7.GD7_CODCRM " + Chr(13)+Chr(10)
 cSQL += "WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND SRA.RA_FILIAL = '" + xFilial("SRA") + "'  AND SRA.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += "AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cSQL += " AND GA9.GA9_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 cSQL += " AND GAQ.GAQ_GRUPRO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cSQL += " AND GD7.GD7_CODDES BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
 cSQL += " AND GD7.GD7_CODLOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
 cSQL += " AND GD7.GD7_CODCRM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
 cSQL += " ORDER BY GAQ_GRUPRO, GA7_CODPRO "
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0014, STR0033, STR0034) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Funcao aux. chamada pela RPTSTATUS"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 FS_MontaVe()
 
 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0015 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif
   
   If QRY->GAQ_GRUPRO <> cGruPro //mudou GRP PROCED.
     nLin := FS_ImpTPro(nLin)
     nLin := FS_ImpTGru(nLin)
     cCodPro := ""
		 If !EMPTY(cGruPro)
		   @nLin, 000 PSAY REPLICATE("-",80)
  	   nLin += 2
  	 EndIF  
		 cGruPro := QRY->GAQ_GRUPRO
		 @nLin, 000 PSAY QRY->GAQ_GRUPRO + ' - ' + QRY->GAQ_DESC 
		 nLin++ 
   EndIf

   If QRY->GA7_CODPRO <> cCodPro //mudou proced. 
     FS_AchaTGr(cGruPro)
     nLin := FS_ImpTPro(nLin)
     @nLin, 012 PSAY QRY->GA7_CODPRO + " - " + SUBSTR(QRY->GA7_DESC,1,25)
     cCodPro := QRY->GA7_CODPRO
     nTotPro := 0
   EndIF
   
   nTotPro += QRY->GD7_QTDDES
   
   dbSkip() /* Avanca o ponteiro do registro no arquivo */

   If EOF()
     nLin := FS_ImpTPro(nLin)
     nLin := FS_ImpTGru(nLin)
     FS_ImpTGer(nLin)
   EndIf
     
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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDJ  บAutor  Daniel Peixoto       บ Data ณ  23/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Monta o vetor  com os Valores totais de cada Grupo        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_MontaVe()
Local cGrupo:= ""  
  
  While !EOF()
   If (QRY->GAQ_GRUPRO <> cGrupo) //mudou grupo
     If !EMPTY(cGrupo) //insere na matriz
       AADD(aVetor,{"",0})
  	   aVetor[Len(aVetor), 1] := cGrupo
       aVetor[Len(aVetor), 2] := nTotGru
     EndIF
     nTotGer += nTotGru
     nTotGru := 0
   EndIf
   cGrupo := QRY->GAQ_GRUPRO  
   nTotGru += QRY->GD7_QTDDES  
   dbSkip()
  EndDo
  AADD(aVetor,{"",0})
  aVetor[Len(aVetor), 1] := cGrupo
  aVetor[Len(aVetor), 2] := nTotGru
  nTotGer += nTotGru    
  nTotGru := 0
  DbGoTop()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDJ  บAutor  Daniel Peixoto       บ Data ณ  23/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Busca no vetor o total de procedimentos do                บฑฑ
ฑฑบ          ณ  Grupo Atual                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_AchaTGr(cGruPro)
Local nCont := 1  
Local lAchou := .F.

  While nCont <= Len(aVetor) .AND. !lAchou
    If aVetor[nCont , 1] == cGruPro
     nTotGru := aVetor[nCont , 2]
     lAchou := .T. 
    Else
     nCont ++
    EndIf 
  EndDo
  
Return(nTotGru)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDI  บAutor  ณDaniel Peixoto      บ Data ณ  18/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ rotinas de impressao do total                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpTPro(nLin)

  If !Empty(cCodPro)
    @nLin, 051 PSAY TRANSFORM(nTotPro, "@E 9999,999") //qtidade
    @nLin, 064 PSAY TRANSFORM( ((nTotPro * 100) / nTotGru), "@E 999.99" ) //% grupo
    @nLin, 074 PSAY TRANSFORM( ((nTotPro * 100) / nTotGer), "@E 999.99" ) //% geral
    nLin++
  EndIf
  
Return(nLin)

Static Function FS_ImpTGru(nLin)
  
  If !Empty(cGruPro)
    @nLin, 024 PSAY STR0016 //"Total do Grupo:"
    @nLin, 051 PSAY TRANSFORM(nTotGru, "@E 9999,999")
    @nLin, 074 PSAY TRANSFORM( (nTotGru * 100) / nTotGer , "@E 999.99") //imprimi a porcentagem do grupo em relacao ao total geral
    nLin += 2
  EndIf

Return(nLin)  
  
Static Function FS_ImpTGer(nLin)
  
    @nLin, 024 PSAY STR0017 //"Total Geral:"
    @nLin, 051 PSAY TRANSFORM(nTotGer, "@E 9999,999")
 
Return()  
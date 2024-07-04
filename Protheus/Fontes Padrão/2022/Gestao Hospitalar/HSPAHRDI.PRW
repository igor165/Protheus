#INCLUDE "HSPAHRDI.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "Report.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDI  บ Autor ณ Daniel Peixoto     บ Data ณ  18/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio PROCEDIMENTOS REALIZADOS                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑบAltera็๕esณ Daniel Peixoto  05/04/06 -> Inclusao do Par. "Agrupar por?"บฑฑ
ฑฑบAltera็๕esณ Eduardo Alves   02/05/06 -> Criacao do Par. "Tipo de Relatoบฑฑ
ฑฑบ          ณ                             rio (Uniao RDJ).               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDI()

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         	:= ""
Local cPict          	:= ""
Local titulo         	:= STR0003 //"Procedimento Realizados"
Local nLin           	:= 80
Local Cabec1         	:= ""
Local Cabec2         	:= ""
Local imprime        	:= .T.
Local aOrd 				      	:= {}    

Private lEnd         	:= .F.             
Private lAbortPrint  	:= .F.
Private limite       	:= 80                  
Private tamanho      	:= "M"
Private nomeprog     	:= "HSPAHRDI" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        	:= 18
Private aReturn      	:= {STR0006, 1, STR0007, 2, 2, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey     	:= 0
Private cbtxt        	:= Space(10)
Private cbcont       	:= 00
Private CONTFL       	:= 01
Private m_pag        	:= 01
Private wnrel        	:= nomeprog
Private cPerg        	:= "HSPRDI"
Private nAgrupar     	:= 0
Private nTpRel								:= 0
Private lVerif			:= .F. // Usado para entrar no R3 ou no R4
Private cString  					:= ""

Private cCODIMP 						:= ""
Private nMaxLin 						:= 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                           ณ
 ณ MV_PAR01	Da Data Atend.                                              ณ
 ณ MV_PAR02	Ate Data Atend.                                             ณ
 ณ MV_PAR03	Da Data Proced.                                             ณ
 ณ MV_PAR04	Ate Data Proced.                                            ณ
 ณ MV_PAR05	Do Convenio                                                 ณ
 ณ MV_PAR06	Ate Convenio        						                                  ณ 
 ณ MV_PAR07	Do Gr Proced.                   					                       ณ
 ณ MV_PAR08	Ate Gr proced.                            					             ณ
 ณ MV_PAR09	Do Proced.                                       					     	ณ
 ณ MV_PAR10	Ate Proced.                                      					      ณ
 ณ MV_PAR11	Do Setor                                                    ณ
 ณ MV_PAR12	Ate Setor                                                   ณ
 ณ MV_PAR13	Do  Medico                                                  ณ
 ณ MV_PAR14	Ate Medico                                                  ณ
 ณ MV_PAR15	Do  Prestador                                               ณ
 ณ MV_PAR16	Ate Prestador                                               ณ
 ณ MV_PAR17	Ordenar Por                                                 ณ
 ณ MV_PAR18	Agrupar Por                                                 ณ
 | MV_PAR19 Tipo de Relatorio                                           |
 | MV_PAR20 Impressora ?                                                |
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If FindFunction("TRepInUse") .And. TRepInUse() 
	lVerif := .T.
EndIf


If !Pergunte(cPerg,.T.)
	return
EndIf 





nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2      

nAgrupar := MV_PAR18
nTpRel			:= MV_PAR19 // Tipo de Relatorio: 1 = Analitico / 2 = Sintetico


If nTpRel == 1 //Analitico
 																							/*								1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
               					 			0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
	If nAgrupar == 1 //Grp\Conv
 	Cabec1 := STR0004 	//"Convenio"
 	Cabec2 := STR0005 	//"Paciente                            Data Real. Hora    Procedimento                       Qtd   Setor                 Medico"
	Else//Pres\prof.
 	Cabec1 := STR0063 //"Profissional" 
 	Cabec2 := STR0064 //"Paciente                            Data Real. Hora    Procedimento                       Qtd   Setor" 
	EndIf 
	
	Titulo := STR0003 //"Procedimento Realizados"

Else // Sintetico
	If nAgrupar == 1 //Grp\Conv	
		Cabec1	:= 	STR0069 //"Grupo de Procedimento"
		Cabec2	:= 	STR0070 //" Conv๊nio            Procedimento                                Qtd     %Grupo    %Geral"
	Else//Pres\prof.
 																							/*								1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
         			 											0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
		Cabec1	:= 	STR0071 //"Prestador"
		Cabec2	:= 	STR0072 //" Profissional        Procedimento                                Qtd     %Grupo    %Geral"
	EndIf                                                                             	
	
	Titulo := STR0073	 //"Procedimento Real. Sint."

EndIf

If lVerif
	pergunte("HSPRDI",.F.)
	oReport := ReportDef() 
	oReport:PrintDialog() 
Else
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
endif
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

	Local cSQL 	     	:= ""
	Local nCount						:= 0
	Local aProced					:= {} // Guarda a quantidade dos procedimentos para totalizar e colocar a frente da linha do procedimento.
	Private cGruPro 	 := "" , 	cCodCon  := "" , nTotGru  := 0 , nTotCon  := 0
	Private cCodPre  	:= "" , 	cCodCrm  := "" , nTotPre  := 0 , nTotCrm  := 0
	Private cCodPro 		:= "" ,		nTotPro  := 0
	Private cDatPro   := "" , nTotDia  := 0, aTotDia := {'','','','','','','',''}

	Private nTotGer  := 0                                                        
	Private aVetor   := {} // Vetor utilizado para guardar os totais.
 
 cSQL := "SELECT "
 cSQL += " GAQ.GAQ_GRUPRO, GAQ.	GAQ_DESC, GA9.GA9_CODCON, GA9.GA9_NREDUZ, GCY.GCY_REGATE, GCY.GCY_NOME, GCY.GCY_DATATE, "
 cSQL += " GD7.GD7_DATDES, GD7.GD7_HORDES, GD7.GD7_CODDES, GD7.GD7_QTDDES, GA7.GA7_CODPRO , GA7.GA7_DESC, GCS.GCS_NOMLOC,"
 cSQL += " SRA.RA_NOME, GAZ.GAZ_FANPRE, GD7.GD7_CODPRE, GD7.GD7_CODCRM "
 cSQL += " FROM " + RetSQLName("GD7") + " GD7 "
 cSQL += " JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GD7.GD7_CODPRE AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "  
 cSQL += " JOIN " + RetSQLName("GAQ") + " GAQ ON GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GD7.GD7_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' "
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GD7.GD7_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cSQL += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_CODATO = GD7.GD7_CODATO AND GMC.	GMC_FILIAL = '" + xFilial("GMC") + "' AND GMC.D_E_L_E_T_ <> '*' " // 20/03/07 bops 119029
 cSQL += " WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' " 
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cSQL += " AND GD7.GD7_DATDES BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSQL += " AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cSQL += " AND GAQ.GAQ_GRUPRO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
 cSQL += " AND GD7.GD7_CODDES BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
 cSQL += " AND GD7.GD7_CODLOC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
 cSQL += " AND GD7.GD7_CODCRM BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "
 cSQL += " AND GD7.GD7_CODPRE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' "
 cSQL += " AND (GMC.GMC_TIPATM = '0' OR GD7_CODATO = '" + Space( (TamSx3("GD7_CODATO")[1]) ) + "') "  // 28/03/07 bops 119029 
 
 
 If MV_PAR18 == 3 .AND. nTpRel == 2 //Data\Grupo                      	
  cSQL += IIf( nTpRel == 1, " ORDER BY GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON ", " ORDER BY GAQ_GRUPRO, GA9_CODCON, GD7_DATDES, GD7_CODDES")
 ElseIf MV_PAR18 == 2  //Prestador\Prof.
  cSQL += IIf( nTpRel == 1, " ORDER BY GAZ_FANPRE, GD7_CODPRE, RA_NOME, GD7_CODCRM ", " ORDER BY GAZ_FANPRE, GD7_CODPRE, RA_NOME, GD7_CODCRM, GA7_CODPRO ")
 Else	//Grupo proc\Convenio
  cSQL += IIf( nTpRel == 1, " ORDER BY GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON ", " ORDER BY GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON, GA7_CODPRO")
 Endif
  
 If MV_PAR17 == 1  //ORDENAR POR NOME PACIENTE
 	cSQL += ", GCY_NOME "
 ElseIf MV_PAR17 == 2  //ORDENAR POR DAT + HOR
  cSQL += IIf(MV_PAR18 == 3 .AND. nTpRel == 2, ", GD7_HORDES", ", GD7_DATDES, GD7_HORDES ")
 ElseIf MV_PAR17 == 3 .and. nTpRel == 1//ORDENAR POR PROCED.
  cSQL += ", GA7_CODPRO " 
 ElseIf MV_PAR17 == 4  //ORDENAR POR SETOR
  cSQL += ", GD7_CODLOC "  
 ElseIf MV_PAR17 == 5 .and. MV_PAR18 == 1 //ORDENAR POR NOME MED
   cSQL += ", RA_NOME " 
 EndIf  
 
 cSql := ChangeQuery(cSql)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  HS_MsgInf(STR0020, STR0062, STR0003) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Procedimento Realizados"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
	nTotReg := FS_MontaVe()
	SetRegua(nTotReg)                      	

 While !EOF()
  
  If lAbortPrint
     @nLin,00 PSAY STR0021 //"*** CANCELADO PELO OPERADOR ***"
     Exit
  Endif
  
  If nLin > nMaxLin
     Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
     nLin := 9
  Endif
  
  //GRUPO POR GRUPO DE PROCEDIMENTO OU PRESTADOR
  If IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), QRY->GAQ_GRUPRO <> cGruPro, QRY->GD7_CODPRE <> cCodPre) //mudou GRP PROCED. ou Prestador
   nLin := FS_ImpTot1(IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), "CON", "CRM"), nLin)
	  nLin := FS_ImpTot2(IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), "GRP", "PRE"), nLin)
 	 If nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2)//Grupo Proc.\Conv.
 		 cGruPro := QRY->GAQ_GRUPRO
  	 @nLin, 000 PSAY IIF( nTpRel == 1, STR0022 + QRY->GAQ_DESC, QRY->GAQ_DESC) //"Grupo de Procedimento: "
  	 cCodCon := ""
 		Else 
 		 cCodPre := QRY->GD7_CODPRE
  	 @nLin, 000 PSAY IIf( nTpRel == 1, STR0065 + QRY->GAZ_FANPRE, QRY->GAZ_FANPRE) //"Prestador: "
  	 cCodCrm := ""
 		EndIf 
 		cCodPro := ""      
  EndIf
  
  //GRUPO POR CONVENIO OU PROFISSIONAL
  If IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), QRY->GA9_CODCON <> cCodCon, QRY->GD7_CODCRM <> cCodCrm) //mudou Convenio ou profissional
	  nLin := FS_ImpTot1(IIF(nAgrupar == 1 .Or. (nAgrupar == 3 .AND. nTpRel == 2), "CON", "CRM"), nLin)
   nLin ++
   nCol := IIf(nTpRel == 1, 000, 001)
   If nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2)//Grupo Proc.\Conv.
 	  @nLin, nCol PSAY QRY->GA9_NREDUZ
  	 cCodCon := QRY->GA9_CODCON
  	Else
  	 @nLin, nCol PSAY QRY->RA_NOME
  	 cCodCrm := QRY->GD7_CODCRM 
  	EndIf
  	cCodPro := "" 
   nTotDia := 0
 	 nLin ++
  EndIf
  
		//PROCEDIMENTO (SOMENTE QUANDO FOR SINTETICO)
  If nTpRel == 2
	  If QRY->GA7_CODPRO <> cCodPro //mudou Procedimento
		  
		  cCodPro := QRY->GA7_CODPRO                              
	  
		  // Adiciona os Procedimentos IGUAIS em um vetor para poder somar o total dos Procedimentos.
		  While QRY->GA7_CODPRO == cCodPro .And. IIf(nAgrupar == 1 .OR. nAgrupar == 3, QRY->GA9_CODCON == cCodCon, QRY->GD7_CODCRM == cCodCrm) .And. IIF(nAgrupar == 1 .OR. nAgrupar == 3, QRY->GAQ_GRUPRO == cGruPro, QRY->GD7_CODPRE == cCodPre)
		  	nTotCon += QRY->GD7_QTDDES
		  	nTotCrm += QRY->GD7_QTDDES
		  	cDatPro := QRY->GD7_DATDES
		  	If nAgrupar == 3
		  	 aAdd(aProced, {QRY->GAQ_GRUPRO, QRY->GA7_CODPRO, SUBSTR(QRY->GA7_DESC,1,19), QRY->GD7_QTDDES, QRY->GD7_DATDES})
		  	Else
		  	 aAdd(aProced, {IIF(nAgrupar == 1, QRY->GAQ_GRUPRO, QRY->GD7_CODPRE), QRY->GA7_CODPRO, SUBSTR(QRY->GA7_DESC,1,19), QRY->GD7_QTDDES})
		  	EndIf
		  	DbSkip()
		  	IncRegua()
		  EndDo                                          
		  
    If nAgrupar == 3
     aTotDia[5] := IIf(Empty(aTotDia[1]), aProced[1][2], aTotDia[1]) //Procedimento Antigo recebe Atual
 	   aTotDia[6] := IIf(Empty(aTotDia[2]), QRY->GD7_DATDES, aTotDia[2]) //Data Antiga recebe Atual
 	   aTotDia[7] := IIf(Empty(aTotDia[3]), cGruPro, aTotDia[3]) //Codigo Quebra antigo recebe Atual
 	   aTotDia[8] := IIf(Empty(aTotDia[4]), cCodCon, aTotDia[4]) 
	    aTotDia[1] := aProced[1][2]  //Procedimento Atual
	    aTotDia[2] := QRY->GD7_DATDES //Data Atual
				 aTotDia[3] := cGruPro //Codigo Quebra Atual
				 aTotDia[4] := cCodCon 
				EndIf
				// Soma total dos procedimentos que estao no vetor.
		  For nCount := 1 To Len(aProced)
		  	nTotPro := nTotPro + aProced[nCount][4]      
 	  Next nCount
                                              
    // Imprime os Procedimentos.
				If nAgrupar == 3
				 @nLin, 010 PSAY STOD(aProced[1][5])
				EndIf
				@nLin, 021 PSAY aProced[1][2] + " - " + aProced[1][3]
				@nLin, 060 PSAY		PadL(AllTrim(TRANSFORM(nTotPro, "@E 9999,999")), 8, " ")
				FS_AchaTGr(aProced[1][1])
				@nLin, 071 PSAY		PadL(AllTrim(TRANSFORM( ((nTotPro * 100) / nTotGru), "@E 9999.999")), 8, " ")
				@nLin, 081 PSAY		PadL(AllTrim(TRANSFORM( ((nTotPro * 100) / nTotGer), "@E 9999.999")), 8, " ")
	
		  nTotDia += nTotPro
		   
				aProced := {}
				nTotPro := 0
	 	 nLin ++
	  EndIf
		
		Else // PROCEDIMENTO (SOMENTE SE ANALITICO)
 		          
 		@nLin, 000 PSAY QRY->GCY_REGATE + " - " + SUBSTR(QRY->GCY_NOME,1,25)
 		@nLin, 036 PSAY DTOC(STOD(QRY->GD7_DATDES))
 		@nLin, 047 PSAY QRY->GD7_HORDES
 		@nLin, 055 PSAY QRY->GA7_CODPRO + " - " + SUBSTR(QRY->GA7_DESC,1,19)
 		@nLin, 090 PSAY QRY->GD7_QTDDES
 		@nLin, 096 PSAY SUBSTR(QRY->GCS_NOMLOC,1,IIF(nAgrupar == 1, 21, 35))
   
  	If nAgrupar == 1
 			@nLin, 118 PSAY SUBSTR(QRY->RA_NOME,1,16)
   	nTotCon += QRY->GD7_QTDDES
  	Else
   	nTotCrm += QRY->GD7_QTDDES
  	EndIf 
  
  	dbSkip() /* Avanca o ponteiro do registro no arquivo */
  	IncRegua()
  EndIf
  
 	nLin := IIf( nTpRel == 1, nLin + 1, nLin + 0)

  If nAgrupar == 3 .AND. nTpRel == 2
   If ((QRY->GD7_DATDES <> aTotDia[2]) .OR. (aTotDia[3] <> QRY->GAQ_GRUPRO)) .OR. (QRY->GD7_DATDES <> aTotDia[6]) .OR. (QRY->GA9_CODCON <> aTotDia[4])
    @nLin, 010 PSAY "Total do dia " + DTOC(STOD(aTotDia[6])) + " -----------> "
				@nLin++, 060 PSAY		PadL(AllTrim(TRANSFORM(nTotDia, "@E 9999,999")), 8, " ")
    nTotDia := 0
   EndIf
  EndIf

 	// Final do arquivo imprime total GERAL.
 	If EOF()
 	If nAgrupar == 1
	  nLin := FS_ImpTot1(IIF(nAgrupar == 1, "CON", "CRM"), nLin)
	  nLin := FS_ImpTot2(IIF(nAgrupar == 1, "GRP", "PRE"), nLin) 
  Endif
	  nLin := FS_ImpTot1(IIF(nAgrupar == 1 .AND. (nAgrupar == 3 .AND. nTpRel == 2), "CON", "CRM"), nLin)
	  nLin := FS_ImpTot2(IIF(nAgrupar == 1 .AND. (nAgrupar == 3 .AND. nTpRel == 2), "GRP", "PRE"), nLin)
	  @nLin, 010 PSAY STR0066 //"Total Geral --------------------->"   
	  @nLin, 060 PSAY PadL( nTotGer, 8, " ")
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
ฑฑบPrograma  ณFS_ImpTot1บAutor  ณDaniel Peixoto      บ Data ณ  04/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprimi o total do Convenio ou profissional, de acordo     บฑฑ
ฑฑบ          ณ com o parametro "Agrupar por?"                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpTot1(cTipo, nLin)
		
  If IIF(cTipo == "CON", !Empty(cCodCon), !Empty(cCodCrm))
    @nLin, 010 		PSAY IIF(cTipo == "CON", STR0024, STR0067) //"Total do Profissional ----------->"###"Total do Convenio --------------->"
    @nLin, 060 	PSAY PadL(IIF(cTipo == "CON", nTotCon, nTotCrm), 8, " ")
    nLin ++
  EndIF
  If cTipo == "CON" 
   nTotCon := 0
  Else 
   nTotCrm := 0
  EndIf              
Return(nLin)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_impTot2บAutor  ณDaniel peixoto      บ Data ณ  04/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de impressao do total do Grupo ou Prestador de      บฑฑ
ฑฑบ          ณ acordo com o parametro "Agrupar por"                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpTot2(cTipo, nLin)
		
		If IIF(cTipo == "GRP", !Empty(cGruPro), !Empty(cCodPre))
				FS_AchaTGr(IIF(cTipo == "GRP", cGruPro, cCodPre))
    @nLin, 010 		PSAY IIF(cTipo == "GRP", STR0023, STR0068)  //"Total por Grupo de Procedimento ->" ###"Total por Prestador ------------->"
    @nLin, 060 	PSAY PadL( nTotGru, 8, " ")
 	  nLin += 2
 	  @nLin, 000 PSAY __PRTTHINLINE() //REPLICATE("-",137)
	   nLin += 2
  EndIf
  
Return(nLin)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDI  บAutor  |Daniel Peixoto      บ Data ณ  23/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o vetor  com os Valores totais de cada Grupo         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MontaVe()
Local cQuebra:= ""
Local nTotal := 0
While !EOF()
	If (IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), QRY->GAQ_GRUPRO <> cQuebra, QRY->GD7_CODPRE <> cQuebra))
		If !EMPTY(cQuebra) //insere na matriz
			AADD(aVetor,{"",0})
			aVetor[Len(aVetor), 1] := cQuebra
			aVetor[Len(aVetor), 2] := nTotGru
		EndIF
		nTotGer += nTotGru
		nTotGru := 0
	EndIf
	cQuebra := IIF(nAgrupar == 1 .OR. (nAgrupar == 3 .AND. nTpRel == 2), QRY->GAQ_GRUPRO, QRY->GD7_CODPRE)
	nTotGru += QRY->GD7_QTDDES
	nTotal ++
	dbSkip()
EndDo
AADD(aVetor,{"",0})                                                                         

aVetor[Len(aVetor), 1] := cQuebra
aVetor[Len(aVetor), 2] := nTotGru
nTotGer += nTotGru
nTotGru := 0
DbGoTop()
Return (nTotal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDI  บAutor  |Daniel Peixoto      บ Data ณ  23/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca no vetor o total de procedimentos do                  บฑฑ
ฑฑบ          ณGrupo Atual                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
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



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณReportDef ณ Autor ณ Rogerio Tabosa        ณ Data ณ 31/07/08 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   

Static Function ReportDef()
 
Local oReport 
Local oSection1,oSection2,oSection3
Local oCell
Local oBreak  
Local oTotaliza,oTotaliz4,oTotaliz
Local cAliasQry := GetNextAlias()                                                                           
 
oReport := TReport():New("HSPAHRDI",STR0003,"HSPRDI",{|oReport| RDIIMP(oReport,cAliasQry)}, STR0001 + STR0002)

oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, IIF(nAgrupar == 1, STR0022,STR0065), {"GAQ","SRA","QRYSQL"})
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.) 
oSection1:SetHeaderSection(.T.)  
oSection1:SetTotalInLine(.F.)              

oCell := TRCell():New(oSection1,"cPront","QRYSQL", IIF(nAgrupar == 1, STR0022,STR0063),, 60,,{|| cPront :=  IIF(nAgrupar == 1, ("QRYSQL")->GAQ_DESC, ("QRYSQL")-> RA_NOME)  }) //"GRUPO"                                             

oSection2 := TRSection():New(oSection1, IIF(nAgrupar == 1, STR0004,STR0063), {"GA9","GAZ","QRYSQL"})
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderBreak(.F.)
oSection2:SetHeaderSection(.T.)
oSection2:SetTotalInLine(.F.)      

oCell := TRCell():New(oSection2,"cPront1","QRYSQL",IIF(nAgrupar == 1, STR0004,STR0065),, 60,,{|| cPront1 := IIF(nAgrupar == 1, ("QRYSQL")->GA9_NREDUZ,("QRYSQL")->GAZ_FANPRE) }) //"Convenio"

oSection3 := TRSection():New(oSection2, IIF(nAgrupar == 1, STR0004,STR0063), {"GCY","GD7","GCS","GAQ","SRA","QRYSQL"})
oSection3:SetHeaderPage(.T.)
oSection3:SetHeaderBreak(.F.)
oSection3:SetHeaderSection(.T.)  
oSection3:SetTotalInLine(.F.)              


If nTpRel==1
oCell := TRCell():New(oSection3,"cPront","",IIF(nTpRel==1,substr(STR0005,1,9)," ")  ,, 60,,{|| cPront := ("QRYSQL")->GCY_REGATE +"-"+ ("QRYSQL")->GCY_NOME })//PACIENTE
oCell := TRCell():New(oSection3,"GD7_DATDES","QRYSQL",IIF(nTpRel==1,STR0074," "),,50)//"Data REAL"
oCell := TRCell():New(oSection3,"GD7_HORDES","QRYSQL",IIF(nTpRel==1,STR0075," "),,20)//"Hora"
oCell := TRCell():New(oSection3,"RA_NOME","QRYSQL",IIF(nTpRel==1,STR0078," ") ,, 60)//"MEDICO?"
Endif

oCell := TRCell():New(oSection3,"Proc","QRYSQL",STR0076,, 100,,{|| cProc := ("QRYSQL")->GA7_CODPRO +"-"+ ("QRYSQL")->GA7_DESC })//PROCEDIMENTO
oCell := TRCell():New(oSection3,"GCS_NOMLOC","QRYSQL",IIF(nTpRel==1,STR0058,"") ,, 60)//"SETOR"
oCell := TRCell():New(oSection3,"cQtd","QRYSQL",STR0077 ,, 10,,{|| cQtd := Str(("QRYSQL")->GD7_QTDDES,3)})//"Qtd"
oCell := TRCell():New(oSection3,"cGrupo","QRYSQL",IIF(nTpRel==2 ,STR0079," "),, 60,,{|| cGrupo :=PadL(TRANSFORM(("QRYSQL")->GD7_QTDDES/HS_Perc(IIF(nAgrupar == 1,("QRYSQL")->GAQ_GRUPRO , ("QRYSQL")->GD7_CODCRM))*100, "@E 99,999.9999"), 11)})//"%GRUPO."
oCell := TRCell():New(oSection3,"cGeral","QRYSQL",IIF(nTpRel==2 ,STR0080," "),, 60,,{|| cGeral :=PadL(TRANSFORM(("QRYSQL")->GD7_QTDDES/nTotQry *100, "@E 99,999.9999"), 11)})//"%GERAL."



DEFINE FUNCTION FROM oSection3:Cell("cQtd") OF oSection1 FUNCTION SUM TITLE STR0023 NO END REPORT //" Total Convenio===> "
oTotaliza:=  TRFunction():New(oSection3:Cell("cQtd")	,/* cID */,"SUM",,/*cTitle*/ ,"9999"  ,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //Total Grupo Geral
oTotaliz4 := TRFunction():new(oSection3:Cell("cQtd")   ,        ,"MAX",,/*cTitle*/  ,"9999"  ,{||(nTotQry)},.F.,.T.,.F.)  //"Total Geral"
 
 
Return (oReport)         
                                                                         	`					
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R84Imp   ณ Autor ณ Rogerio Tabosa        ณ Data ณ 31/07/08 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   

Static Function RDIIMP(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)

Local cCond1 := ""
Local cCond2 := ""
Local cCond3 := ""
Local cCond4 := ""
Local cCond5 := ""
Private nTotQry:=0
Private aVetDados:={}

MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()

cCond1 += "% GAQ.GAQ_GRUPRO, GAQ.GAQ_DESC, GA9.GA9_CODCON, GA9.GA9_NREDUZ,"
If nTpRel==1
	cCond1 += " GCY.GCY_REGATE, GCY.GCY_NOME, GCY.GCY_DATATE, GD7.GD7_DATDES, GD7.GD7_HORDES,GD7.GD7_CODDES,GD7.GD7_QTDDES,"
Else
	cCond1 +=" GD7.GD7_CODDES,SUM(GD7.GD7_QTDDES) GD7_QTDDES,"
Endif
cCond1 +=" GA7.GA7_CODPRO , GA7.GA7_DESC, GCS.GCS_NOMLOC,  "
cCond1 +=" SRA.RA_NOME, GAZ.GAZ_FANPRE, GD7.GD7_CODPRE, GD7.GD7_CODCRM,GD7.GD7_CODLOC"

cCond2 += "% " + RetSqlName("GD7") + " GD7 "
cCond2 += " JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GD7.GD7_CODPRE AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GAQ") + " GAQ ON GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_REGATE = GD7.GD7_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99'  "
cCond2 += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GD7.GD7_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'  "
cCond2 += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'  "
cCond2 += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'  "
cCond2 += " JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*'  "
cCond2 += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_CODATO = GD7.GD7_CODATO AND GMC.	GMC_FILIAL = '" + xFilial("GMC") + "' AND GMC.D_E_L_E_T_ <> '*' %"


cCond3 += "% GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*'  "
cCond3 += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
cCond3 += " AND GD7.GD7_DATDES BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cCond3 += " AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cCond3 += " AND GAQ.GAQ_GRUPRO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
cCond3 += " AND GD7.GD7_CODDES BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cCond3 += " AND GD7.GD7_CODLOC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cCond3 += " AND GD7.GD7_CODCRM BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "
cCond3 += " AND GD7.GD7_CODPRE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' "
cCond3 += " AND (GMC.GMC_TIPATM = '0' OR GD7_CODATO = '" + Space( (TamSx3("GD7_CODATO")[1]) ) + "') %"

cCond4 := "%"

If MV_PAR18 == 3 .AND. nTpRel == 2 //Data\Grupo
	cCond4 += IIf( nTpRel == 1, "  GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON ", "  GAQ_GRUPRO, GA9_CODCON, GD7_DATDES, GD7_CODDES ")
ElseIf MV_PAR18 == 2  //Prestador\Prof.
	cCond4 += IIf( nTpRel == 1, "  GAZ_FANPRE, GD7_CODPRE, RA_NOME, GD7_CODCRM ", "   GAZ_FANPRE, GD7_CODPRE, RA_NOME, GD7_CODCRM, GA7_CODPRO ")
Else	//Grupo proc\Convenio
	cCond4 += IIf( nTpRel == 1, "  GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON ", "  GAQ_DESC, GAQ_GRUPRO, GA9_NREDUZ, GA9_CODCON, GA7_CODPRO ")
Endif

If MV_PAR17 == 1  //ORDENAR POR NOME PACIENTE
	cCond4 += ", GCY_NOME  "
ElseIf MV_PAR17 == 2  //ORDENAR POR DAT + HOR
	cCond4 += IIf(MV_PAR18 == 3 .AND. nTpRel == 2, ", GD7_HORDES", ", GD7_DATDES, GD7_HORDES  ")
ElseIf MV_PAR17 == 3 .and. nTpRel == 1//ORDENAR POR PROCED.
	cCond4 += ", GA7_CODPRO   "
ElseIf MV_PAR17 == 4  //ORDENAR POR SETOR
	cCond4 += ", GD7_CODLOC   "
ElseIf MV_PAR17 == 5 .and. MV_PAR18 == 1 //ORDENAR POR NOME MED
	cCond4 += ", RA_NOME  "
EndIf

cCond1 += "%"
cCond4 += "%"

If nTpRel==2
	cCond5 += "% GAQ.GAQ_GRUPRO, GAQ.GAQ_DESC, GA9.GA9_CODCON, GA9.GA9_NREDUZ,GD7.GD7_CODDES, GD7.GD7_DATDES, GA7.GA7_CODPRO , GA7.GA7_DESC,GCS.GCS_NOMLOC, SRA.RA_NOME, GAZ.GAZ_FANPRE, GD7.GD7_CODPRE, GD7.GD7_CODCRM,GD7.GD7_CODLOC,GD7.GD7_HORDES"
	If MV_PAR17 == 1
		cCond5 += ", GCY.GCY_NOME %"
	Else
		cCond5 += " %"
	EndIf
Endif

If nTpRel==2
	BeginSql alias "QRYSQL"
		SELECT		%Exp:cCond1%
		FROM     	%Exp:cCond2%
		WHERE    	%Exp:cCond3%
		GROUP BY  	%Exp:cCond5%
		ORDER BY   %Exp:cCond4%
	EndSql
Else
	BeginSql alias "QRYSQL"
		SELECT		%Exp:cCond1%
		FROM     	%Exp:cCond2%
		WHERE    	%Exp:cCond3%
		ORDER BY   %Exp:cCond4%
	EndSql
Endif

oSection1:EndQuery()

DbSelectArea("QRYSQL")
DbGoTop()


If nTpRel=1
	
	oSection3:Cell("cGrupo"):Hide()
	oSection3:Cell("cGeral"):Hide()
Endif


oSection2:SetParentQuery()
oSection2:SetParentFilter( {|P|  IIF(nAgrupar == 1,("QRYSQL")->GAQ_GRUPRO , ("QRYSQL")->GD7_CODPRE)   == P }, {||   IIF(nAgrupar == 1,("QRYSQL")->GAQ_GRUPRO , ("QRYSQL")->GD7_CODPRE)   } )// Quebra por GRUPO

oSection3:SetParentQuery()
oSection3:SetParentFilter( {|P|  IIF(nAgrupar == 1,("QRYSQL")->GAQ_GRUPRO +("QRYSQL")->GA9_CODCON, ("QRYSQL")->GD7_CODPRE+("QRYSQL")->GD7_CODCRM)    == P }, {||   IIF(nAgrupar == 1,("QRYSQL")->GAQ_GRUPRO +("QRYSQL")->GA9_CODCON, ("QRYSQL")->GD7_CODPRE+("QRYSQL")->GD7_CODCRM)  } )// Quebra por procedimento/medico por medico/procedimento

While ("QRYSQL")->(!Eof())
	nTotQry+=("QRYSQL")->GD7_QTDDES
	DbSkip()
End


oSection1:Print()
oReport:SetMeter(QRYSQL->(LastRec()))

Return (Nil)


Static Function HS_Perc(cGrupo)

Local cSQL:=""
Private nQuant:=0

cSQL := "SELECT "
cSQL += " SUM(GD7_QTDDES) QTDE "
cSQL += " FROM " + RetSQLName("GD7") + " GD7 "
cSQL += " JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GD7.GD7_CODPRE AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GAQ") + " GAQ ON GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GD7.GD7_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' "
cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GD7.GD7_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_CODATO = GD7.GD7_CODATO AND GMC.	GMC_FILIAL = '" + xFilial("GMC") + "' AND GMC.D_E_L_E_T_ <> '*' " // 20/03/07 bops 119029
cSQL += " WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
cSQL += " AND GD7.GD7_DATDES BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cSQL += " AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cSQL += " AND GAQ.GAQ_GRUPRO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
cSQL += " AND GD7.GD7_CODDES BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " AND GD7.GD7_CODLOC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
cSQL += " AND GD7.GD7_CODCRM BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "
cSQL += " AND GD7.GD7_CODPRE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' "

IF(nAgrupar == 1)
	cSQL += " AND GAQ.GAQ_GRUPRO = '" + cGrupo+ "' "
Else
	cSQL += " AND GD7.GD7_CODCRM = '" + cGrupo+ "' "
Endif

cSQL += " AND (GMC.GMC_TIPATM = '0' OR GD7_CODATO = '" + Space( (TamSx3("GD7_CODATO")[1]) ) + "') "  // 28/03/07 bops 119029

cSql := ChangeQuery(cSql)

TCQUERY cSQL NEW ALIAS "QRY1"
DbSelectArea("QRY1")
DbGoTop()
nQuant:=QRY1->QTDE

QRY1->(dbCloseArea())

Return(nQuant) 

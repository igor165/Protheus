#INCLUDE "HSPAHR67.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR67  บ Autor ณ Saude              บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ATENDIMENTO POR CONVENIO x FATURADO                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR67()

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local cPict         := ""
Local imprime       := .T.
Local aOrd 			:= {}    

Private Cabec1      := ""
Private Cabec2      := ""
Private titulo      := STR0003 //"Atendimento por convenio x Faturado"
Private lEnd        := .F.             
Private lAbortPrint	:= .F.
Private limite      := 80 
Private tamanho     := "G"
Private nomeprog    := STR0004 //"HSPAHR67"
Private nTipo       := 18
Private aReturn     := {STR0005, 1, STR0006, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := nomeprog
Private cPerg       := STR0007 //"HSPR67"

Private cString  	:= ""
Private cCODIMP 	:= ""
Private nMaxLin 	:= 0 // quantidade maxima de linhas p/ impressao
Private nLin    	:= 0
Private dDatIni  	:= ""
Private dDatFin  	:= ""
Private cSetIni  	:= ""
Private cSetFin  	:= ""       
Private cConIni  	:= ""
Private cConFin  	:= ""       
Private cPlaIni  	:= ""
Private cPlaFin  	:= ""       
Private cTipo    	:= ""
Private cResumo  	:= ""       
Private cImpre   	:= ""
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ PARAMETROS                                                         ณ
ณ MV_PAR01	De data atendimento                                      ณ
ณ MV_PAR02	Ate data atendimento                                     ณ
ณ MV_PAR03	De convenio                                              ณ
ณ MV_PAR04	Ate convenio                                             ณ
ณ MV_PAR05	De plano                                                 ณ
ณ MV_PAR06	Ate plano			                                     ณ 
ณ MV_PAR07	De setor                    					         ณ
ณ MV_PAR08	Ate setor                          					     ณ
ณ MV_PAR09	Tipo atendimento                   					     ณ
ณ MV_PAR10	Resumo                                         		     ณ
ณ MV_PAR11	Impressora                                               ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
*/

If !Pergunte(cPerg,.T.)
	return
EndIf

dDatIni  := mv_par01
dDatFin  := mv_par02
cConIni  := mv_par03
cConFin  := mv_par04 
cPlaIni  := mv_par05
cPlaFin  := mv_par06 
cSetIni  := mv_par07
cSetFin  := mv_par08 
cTipo    := mv_par09
cResumo  := mv_par10 
cImpre   := mv_par11

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2      

/*								1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
Cabec1	:= STR0008 //"Setor"
Cabec2 := STR0009 //"Convenio                                      Plano                                Tp.Atendimento           Qtde Atend.   Qtde Atend. Faturado   Valor Faturado     %"
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Saude              บ Data ณ  28/11/07   บฑฑ
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
Local cSetor		:= ""
Local cSQL			:= ""
Local cPlano		:= ""               
Local cNome			:= ""   
Local nCtaFor		:= 0  
Local nTotConv1		:= 0
Local nTotConv2		:= 0
Local nTotConv3		:= 0              
Local nTotGer1		:= 0
Local nTotGer2		:= 0
Local nTotGer3		:= 0 
Local aMatImp		:= {}
Local aMatAte		:= {}  
Private cConv		:= ""
Private aMatRes		:= {}
Private aMatPla		:= {}
Private aMatCon		:= {} 
Private lImpTotCon	:= .F.
Private lImpTotPla	:= .F.
Private nTotGerVal	:= 0
Private nTotGerAte	:= 0
Private nTotGerFat	:= 0
Private cSetAnt		:= ""	
Private cConAnt		:= ""
Private cPlaAnt		:= ""
   
  
cSql := "SELECT  'FAT' AS TIPO, GCY.GCY_LOCATE, GCS.GCS_NOMLOC, GCZ.GCZ_CODCON, GA9.GA9_NOME, GCZ.GCZ_CODPLA, GCM.GCM_DESPLA, GCY_ATENDI, COUNT(GCY_ATENDI) QTDE, SUM(GCZ_VLGUIA) VALFAT"
cSql += " FROM " + RetSQLName("GCY") + " GCY "
cSql += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'  AND GCY_REGATE = GCZ.GCZ_REGATE"
If !Empty(cConIni) .OR. !Empty(cConFin)
	cSql += " AND GCZ.GCZ_CODCON BETWEEN '" + cConIni + "' AND '" + cConFin + "' "
EndIf
If !Empty(cPlaIni) .OR. !Empty(cPlaFin)
	cSql += " AND GCZ.GCZ_CODPLA BETWEEN '" + cPlaIni + "' AND '" + cPlaFin + "' "
EndIf
cSql += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCZ.GCZ_LOCATE "
cSql += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cSql += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
cSql += " WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' "
If cTipo == 3
	cSql += " AND GCY.GCY_ATENDI = '0' "
ElseIf cTipo == 4
	cSql += " AND GCY.GCY_ATENDI IN ('0','1','2') "
ElseIf cTipo <= 2
	cSql += " AND GCY.GCY_ATENDI = '" + ALLTRIM(STR(cTipo)) + "'"
EndIf  
cSql+="AND GCZ.GCZ_STATUS IN ('2','3','4','5','6','7')"
If !Empty(dDatIni) .OR. !Empty(dDatFin)
	cSql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFin) + "' "
EndIf  
If !Empty(cSetIni) .OR. !Empty(cSetFin)
	cSql += " AND GCY.GCY_LOCATE BETWEEN '" + cSetIni + "' AND '" + cSetFin + "' "  
EndIf  

cSql += " GROUP BY  GCY.GCY_LOCATE, GCS.GCS_NOMLOC, GCZ.GCZ_CODCON, GA9.GA9_NOME, GCZ.GCZ_CODPLA, GCM.GCM_DESPLA, GCY_ATENDI "
cSql += " ORDER BY  GCY_LOCATE, GCS_NOMLOC, GCZ_CODCON, GA9_NOME, GCZ_CODPLA, GCM_DESPLA, GCY_ATENDI "  

cSql := ChangeQuery(cSql)
 
TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
 
If Eof()
	HS_MsgInf(STR0010, STR0011, STR0012) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Procedimento Realizados"
Endif

aMatImp:={}   
While !EOF()
 
	cAtend := ""
	If QRY->GCY_ATENDI == "0"
		cAtend := STR0013 //"INTERNACAO"
	ElseIf QRY->GCY_ATENDI == "1"
		cAtend := STR0014 //"AMBULATORIO"
	ElseIf QRY->GCY_ATENDI == "2"
		cAtend := STR0015 //"P.ATENDIMENTO"
	EndIf 	                    
 
	// totaliza por atendimento  
	If cResumo ==2 .OR. cResumo == 3
		nPos:= aScan(aMatAte, {| aVet | aVet[1] == cAtend })
		If nPos <= 0
			AADD(aMatAte,{ cAtend,;
				IIf(QRY->TIPO=='ATE',QRY->QTDE,0),;
				IIf(QRY->TIPO=='FAT',QRY->QTDE,0),;
				IIf(QRY->TIPO=='FAT',QRY->VALFAT,0)})
		Else
			If QRY->TIPO=='FAT' 
				aMatAte[nPos,3]+=QRY->QTDE
				aMatAte[nPos,4]+=QRY->VALFAT
			Else
				aMatAte[nPos,2]+=QRY->QTDE
			EndIf    
		EndIf
	EndIf
 
	nPos:= aScan(aMatImp, {| aVet | aVet[1] == QRY->GCY_LOCATE ;
	.AND. aVet[3] == QRY->GCZ_CODCON ;
	.AND. aVet[5] == QRY->GCZ_CODPLA ;
	.AND. aVet[7] == cATEND })
	
	If nPos <= 0 
		AADD(aMatImp,{ QRY->GCY_LOCATE,		QRY->GCS_NOMLOC,	QRY->GCZ_CODCON,	QRY->GA9_NOME,	QRY->GCZ_CODPLA,	QRY->GCM_DESPLA,	cAtend,;
		IIf(QRY->TIPO=='ATE',QRY->QTDE,0),;
		IIf(QRY->TIPO=='FAT',QRY->QTDE,0),;
		IIf(QRY->TIPO=='FAT',QRY->VALFAT,0)})
		IIf(QRY->TIPO=='ATE',nTotGerAte += QRY->QTDE,nTotGerFat += QRY->QTDE)
	Else 
		If QRY->TIPO=='FAT' 
			aMatImp[nPos,9]+=QRY->QTDE
			aMatImp[nPos,10]+=QRY->VALFAT
			nTotGerFat += QRY->QTDE
		Else
			aMatImp[nPos,8]+=QRY->QTDE
			nTotGerAte += QRY->QTDE
		EndIf
	EndIf

                                                   
	//total do plano
	nPos:= aScan(aMatPla, {| aVet | aVet[1] == QRY->GCY_LOCATE ;
	.AND. aVet[3] == QRY->GCZ_CODCON ;
	.AND. aVet[5] == QRY->GCZ_CODPLA}) 
	If nPos <= 0
		AADD(aMatPla,{ QRY->GCY_LOCATE,;
		QRY->GCS_NOMLOC,;
		QRY->GCZ_CODCON,;
		QRY->GA9_NOME,;
		QRY->GCZ_CODPLA,;
		QRY->GCM_DESPLA,;
		IIf(QRY->TIPO=='ATE',QRY->QTDE,0),;
		IIf(QRY->TIPO=='FAT',QRY->QTDE,0),;
		IIf(QRY->TIPO=='FAT',QRY->VALFAT,0)})
	Else
		If QRY->TIPO=='FAT' 
			aMatPla[nPos,8]+=QRY->QTDE
			aMatPla[nPos,9]+=QRY->VALFAT
		Else
			aMatPla[nPos,7]+=QRY->QTDE
		EndIf
	EndIf

 	//total do convenio
	nPos:= aScan(aMatCon, {| aVet | aVet[1] == QRY->GCY_LOCATE ;
	.AND. aVet[3] == QRY->GCZ_CODCON}) 
	If nPos <= 0 
		AADD(aMatCon,{ QRY->GCY_LOCATE,;
		QRY->GCS_NOMLOC,;
		QRY->GCZ_CODCON,;
		QRY->GA9_NOME,;
 		IIf(QRY->TIPO=='ATE',QRY->QTDE,0),;
 		IIf(QRY->TIPO=='FAT',QRY->QTDE,0),;
 		IIf(QRY->TIPO=='FAT',QRY->VALFAT,0)})
	Else
		If QRY->TIPO=='FAT' 
			aMatCon[nPos,6]+=QRY->QTDE
			aMatCon[nPos,7]+=QRY->VALFAT
		Else
			aMatCon[nPos,5]+=QRY->QTDE
		EndIf
	EndIf

	nTotGerVal += QRY->VALFAT

	QRY->(dbSkip())

End


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
 
SetRegua(len(aMatImp))
 
For nCtaFor := 1 to len(aMatImp)
  
	If nLin > nMaxLin
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
    
	If lAbortPrint
		@nLin,00 PSAY STR0016 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	lImpTotPla := .F.
	lImpTotCon := .F.
	If aMatImp[nCtaFor][5] <> cPlaAnt
		lImpTotPla := .T.
	EndIf             
	If aMatImp[nCtaFor][3]  <> cConAnt  
		lImpTotCon := .T.   
	EndIf
	If aMatImp[nCtaFor][1]  <> cSetAnt  
		lImpTotPla := .T.  
		lImpTotCon := .T.   
	EndIf

	//totaliza por plano
	If lImpTotPla 
		Fs_ImpTotPla(nLin)
		nLin++
	EndIf              

	//totaliza por convenio
	If lImpTotCon  
		Fs_ImpTotCon(nLin)
		nLin+=1
	EndIf

	If (aMatImp[nCtaFor][1] <> cSetor)  //.or. lQbrSet
		@nLin, 000 PSAY __PRTTHINLINE()  
		nLin += 1
		@nLin, 000 PSAY aMatImp[nCtaFor][1]
		@nLin, 003 PSAY "-"
		@nLin, 005 PSAY aMatImp[nCtaFor][2] 
		cSetor := aMatImp[nCtaFor][1]
		nLin += 1  
		lQbrSet    := .T. 
	EndIf

	If aMatImp[nCtaFor][3] <> cConv .OR.  lQbrSet
		nLin +=1
		@nLin, 000 PSAY aMatImp[nCtaFor][3]
		@nLin, 004 PSAY "-"
		@nLin, 005 PSAY aMatImp[nCtaFor][4]
		cConv:=aMatImp[nCtaFor][3]  
		lQbrCon := .T.
		lQbrSet := .F.
	EndIf

	If aMatImp[nCtaFor][5] <> cPlano  .OR. lQbrCon
		@nLin, 046 PSAY aMatImp[nCtaFor][5]
		@nLin, 052 PSAY "-"
		@nLin, 053 PSAY aMatImp[nCtaFor][6]  
		cPlano := aMatImp[nCtaFor][5]                
		lQbrCon := .F.
	Endif
   
	//total do plano - para calculo do percentual
	nPos:= aScan(aMatPla, {| aVet | aVet[1] == aMatImp[nCtaFor][1] ;
	.AND. aVet[3] == aMatImp[nCtaFor][3] ;
	.AND. aVet[5] == aMatImp[nCtaFor][5]})
 	
	@nLin, 084 PSAY aMatImp[nCtaFor][7]
   //	@nLin, 108 PSAY TRANSFORM(aMatImp[nCtaFor][8], "@E 999,999.99")
	@nLin, 128 PSAY TRANSFORM(aMatImp[nCtaFor][9], "@E 999,999.99") 
	@nLin, 140 PSAY TRANSFORM(aMatImp[nCtaFor][10],"@E 999,999,999.99")
	@nLin, 156 PSAY TRANSFORM(((aMatImp[nCtaFor][10]/aMatPla[nPos][9])*100),"@E 999.99")    
 
	lImpTotPla := .F.
	lImpTotCon := .F.
	If aMatImp[nCtaFor][5] <> cPlaAnt
		lImpTotPla := .T.
	EndIf             
	If aMatImp[nCtaFor][3]  <> cConAnt  
		lImpTotCon := .T.   
	EndIf
	If aMatImp[nCtaFor][1] <> cSetAnt .AND. aMatImp[nCtaFor][5] = cPlaAnt 
		lImpTotPla := .T.                                            
	EndIf

	cSetAnt := aMatImp[nCtaFor][1]
	cConAnt := aMatImp[nCtaFor][3]
	cPlaAnt := aMatImp[nCtaFor][5]
	IncRegua()
	nLin++
Next   
 
If lImpTotPla
	Fs_ImpTotPla(nLin)
	nLin++
EndIf   

If lImpTotCon
	Fs_ImpTotCon(nLin)
EndIf
  
 // Imprime resumos
If cResumo <> 4
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
EndIf
 
// CONVENIOS
If cResumo == 1 .OR. cResumo == 3
	nLin +=1
	@nLin, 000 PSAY __PRTTHINLINE()
	nLin +=1
	@nLin, 000 PSAY STR0017 //"Convenio"
   //	@nLin, 045 PSAY STR0018 //"Qtde atendida"
	@nLin, 065 PSAY STR0019 //"Qtde atend. faturados"
	@nLin, 095 PSAY STR0020 //"Valor faturado"
	@nLin, 127 PSAY "%"
	nLin+=1
	@nLin, 000 PSAY __PRTTHINLINE()  
	nLin +=1
	nTotConv1:=0
	nTotConv2:=0
	nTotConv3:=0
	For nCtaFor:=1 to Len(aMatRes)  
		@nLin, 000 PSAY aMatRes[nCtaFor][1] + "-" + aMatRes[nCtaFor][2]
	   //	@nLin, 048 PSAY TRANSFORM(aMatRes[nCtaFor][3], "@E 999,999.99")
		@nLin, 076 PSAY TRANSFORM(aMatRes[nCtaFor][4], "@E 999,999.99") 
		@nLin, 095 PSAY TRANSFORM(aMatRes[nCtaFor][5], "@E 999,999,999.99")
		@nLin, 115 PSAY TRANSFORM(((aMatRes[nCtaFor][5]/nTotGerVal)*100),"@E 999,999,999.99")    
		nlin+= 1         
		nTotGer1 += aMatRes[nCtaFor][3]
		nTotGer2 += aMatRes[nCtaFor][4]
		nTotGer3 += aMatRes[nCtaFor][5]
		nTotConv1 += aMatRes[nCtaFor][3]
		nTotConv2 += aMatRes[nCtaFor][4]
		nTotConv3 += aMatRes[nCtaFor][5]
	Next
	@nLin, 000 PSAY STR0021 //"Total Geral de Atendimentos"
   //	@nLin, 048 PSAY TRANSFORM(nTotGer1, "@E 999,999.99")
	@nLin, 076 PSAY TRANSFORM(nTotGer2, "@E 999,999.99") 
	@nLin, 095 PSAY TRANSFORM(nTotGer3, "@E 999,999,999.99")
	nLin+=1
	@nLin, 000 PSAY __PRTTHINLINE()
	nLin+=1
EndIf

	// TIPO DE ATENDIMENTO
	If cResumo == 2 .OR. cResumo == 3  
	nlin+=1
	@nLin, 000 PSAY __PRTTHINLINE()
	nLin +=1
	@nLin, 000 PSAY STR0022 //"Tipo de atendimento"
//	@nLin, 045 PSAY STR0018 //"Qtde atendida"
	@nLin, 065 PSAY STR0019 //"Qtde atend. faturados"
	@nLin, 095 PSAY STR0020 //"Valor faturado"
	@nLin, 127 PSAY "%"
	nLin+=1
	@nLin, 000 PSAY __PRTTHINLINE()
	nLin+=1
	For nCtaFor:=1 to Len(aMatAte)
		@nLin, 000 PSAY aMatAte[nCtaFor][1]
	   //	@nLin, 048 PSAY TRANSFORM(aMatAte[nCtaFor][2], "@E 999,999.99")
		@nLin, 076 PSAY TRANSFORM(aMatAte[nCtaFor][3], "@E 999,999.99") 
		@nLin, 095 PSAY TRANSFORM(aMatAte[nCtaFor][4], "@E 999,999,999.99")
		@nLin, 115 PSAY TRANSFORM(((aMatAte[nCtaFor][4]/nTotGerVal)*100),"@E 999,999,999.99")    
		nlin+= 1
	Next  
	@nLin, 000 PSAY STR0025 //"Total Geral de Guias"
   //	@nLin, 048 PSAY TRANSFORM(nTotGerAte, "@E 999,999.99")
	@nLin, 076 PSAY TRANSFORM(nTotGerFat, "@E 999,999.99") 
	@nLin, 095 PSAY TRANSFORM(nTotGerVal, "@E 999,999,999.99")
	nLin+=1
	@nLin, 000 PSAY __PRTTHINLINE()
	EndIf
  
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Finaliza a execucao do relatorio...                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
SET DEVICE TO SCREEN

/*
 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Saude              บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para imprimir o total por plano.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fs_ImpTotPla(nLin)
// imprime total por plano
nPos:= aScan(aMatPla, {| aVet | aVet[1] == cSetAnt .AND. aVet[3] == cConAnt .AND. aVet[5] ==cPlaAnt}) 
If nPos > 0
	@nLin, 084 PSAY STR0023 //"Total por Plano:"
  //	@nLin, 108 PSAY TRANSFORM(aMatPla[npos][7], "@E 999,999.99")
	@nLin, 128 PSAY TRANSFORM(aMatPla[npos][8], "@E 999,999.99")
	@nLin, 140 PSAY TRANSFORM(aMatPla[npos][9], "@E 999,999,999.99")
	nPosRes:= aScan(aMatCon, {| aVet | aVet[1] == cSetAnt .AND. aVet[3] == cConAnt}) 
	@nLin, 156 PSAY TRANSFORM((aMatPla[npos][9]/aMatCon[nposRes][7])*100, "@E 999.99")	  
	lImpTotPla:= .F. 
EndIf 
Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Saude              บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para imprimir o total por convenio.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fs_ImpTotCon(nLin)
Local nPosRes := 0

// imprime total por convenio
nPos:= aScan(aMatCon, {| aVet | aVet[1] == cSetAnt .AND. aVet[3] == cConAnt}) 
If nPos > 0
	@nLin, 084 PSAY STR0024 //"Total por Convenio:"
  //	@nLin, 108 PSAY TRANSFORM(aMatCon[npos][5], "@E 999,999.99")
	@nLin, 128 PSAY TRANSFORM(aMatCon[npos][6], "@E 999,999.99")
	@nLin, 140 PSAY TRANSFORM(aMatCon[npos][7], "@E 999,999,999.99")
	@nLin, 156 PSAY TRANSFORM((aMatCon[npos][7]/nTotGerVal)*100, "@E 999.99")
	lImpTotCon:=.F.
	
	//resumo do convenio
	If cResumo ==1 .OR. cResumo == 3
		nPosRes:= aScan(aMatRes, {| aVet | aVet[1] == cConAnt})
		If nPosRes <= 0
			AADD(aMatRes,{cConAnt,;
			HS_IniPadR("GA9", 1, cConAnt, "GA9_NOME"),;
			aMatCon[npos][5],;
			aMatCon[npos][6],;
			aMatCon[npos][7]})
		Else
			aMatRes[nPosRes][3]+=aMatCon[npos][5]
			aMatRes[nPosRes][4]+=aMatCon[npos][6]
			aMatRes[nPosRes][5]+=aMatCon[npos][7]
		EndIf
	EndIf
EndIf
Return(nLin)     

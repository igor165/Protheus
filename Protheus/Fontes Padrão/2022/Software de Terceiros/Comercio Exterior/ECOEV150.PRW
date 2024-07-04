#INCLUDE "ECOEV150.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

//Compatibilização com a 8.11- 28-06-05 - Alcir Alves
//Revisão - 11-05-05 - Alcir Alves
**********************************************************
FUNCTION ECOEV150A
**********************************************************
ECOEV150(1) //Seguro
Return .t.
**********************************************************
FUNCTION ECOEV150B
**********************************************************
ECOEV150(2) //Frete
Return .t.

/*
Programa        : ECOEV150
Obejetivo       : Relatorio de Variação Cambial sobre Seguro ou Frete
Parametros      : 1 - Seguro , 2 - Frete
Data            : 30/09/04
*/


**********************************************************
FUNCTION ECOEV150(nType)
**********************************************************
LOCAL cSX1CMP  // LCS.06/05/2009.17:06
Local  lRet :=.t.,i:=0
Private aFilSel:={},cFilStr:=""
Private wnrel
Private lTop:=.f.
Private cForn,cProcesso,dDataI , dDataF, cTpRel, nTpProc
Private cFilECF := xFilial("ECF")
Private cFilECA := xFilial("ECA")
Private cFilEEC := xFilial("EEC")
Private cFilSA2 := xFilial("SA2")
Private aWork:= {}
Private nTipo:= nType
#IFDEF TOP
	lTop := .t.
#ENDIF

/*
cSX1CMP := PADR("ECOVCF",LEN(SX1->X1_GRUPO)," ")
dbselectarea("sx1")
SX1->(dbSetOrder(1))
///if SX1->(!dbSeek("ECOVCF"+"01"))
if SX1->(!dbSeek(cSX1CMP+"01"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "01"
	SX1->X1_VARIAVL := "mv_ch1"
	SX1->X1_VAR01   := "mv_par01"
	SX1->X1_PERGUNT := "Fornecedor"
	SX1->X1_TIPO    := AVSX3("ECF_FORN",2)
	SX1->X1_TAMANHO := AVSX3("ECF_FORN",3)
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := 'IF(!EMPTY(mv_par01),ExistCpo("SA2",mv_par01),.T.)'
	SX1->X1_F3      := "SA2"
	SX1->(msUnlock())
endif
///if SX1->(!dbSeek("ECOVCF"+"02"))
if SX1->(!dbSeek(cSX1CMP+"02"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "02"
	SX1->X1_VARIAVL := "mv_ch2"
	SX1->X1_VAR01   := "mv_par02"
	SX1->X1_PERGUNT := "Processo"
	SX1->X1_TIPO    := AVSX3("ECF_PREEMB",2)
	SX1->X1_TAMANHO := AVSX3("ECF_PREEMB",3)
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := 'IF(!EMPTY(mv_par02),ExistCpo("EEC",mv_par02),.T.)'
	SX1->X1_F3      := "EEC"
	SX1->(msUnlock())
endif
///if SX1->(!dbSeek("ECOVCF"+"03"))
if SX1->(!dbSeek(cSX1CMP+"03"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "03"
	SX1->X1_VARIAVL := "mv_ch3"
	SX1->X1_VAR01   := "mv_par03"
	SX1->X1_PERGUNT := "Data Inic. Contab. ?"
	SX1->X1_TIPO    := "D"
	SX1->X1_TAMANHO :=  8
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := 'NaoVazio()'
	SX1->(msUnlock())
endif
///if SX1->(!dbSeek("ECOVCF"+"04"))
if SX1->(!dbSeek(cSX1CMP+"04"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "04"
	SX1->X1_VARIAVL := "mv_ch4"
	SX1->X1_VAR01   := "mv_par04"
	SX1->X1_PERGUNT := "Data Final Contab. ?"
	SX1->X1_TIPO    := "D"
	SX1->X1_TAMANHO :=  8
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := 'NaoVazio()'
	SX1->(msUnlock())
endif
///if SX1->(!dbSeek("ECOVCF"+"05"))
if SX1->(!dbSeek(cSX1CMP+"05"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "05"
	SX1->X1_VARIAVL := "mv_ch5"
	SX1->X1_VAR01   := "mv_par05"
	SX1->X1_PERGUNT := "Tipo de relatório"
	SX1->X1_TIPO    := "N"
	SX1->X1_TAMANHO :=  1
	SX1->X1_GSC     := "C"
	SX1->X1_DEF01   := "Impressão"
	SX1->X1_DEF02   := "no MsExcel"
	SX1->X1_DEF03   := "no Arquivo"
	SX1->(msUnlock())
ENDIF
///if SX1->(!dbSeek("ECOVCF"+"06"))
if SX1->(!dbSeek(cSX1CMP+"06"))
	SX1->(RecLock("SX1",.T.))
	SX1->X1_GRUPO   := "ECOVCF"
	SX1->X1_ORDEM   := "06"
	SX1->X1_VARIAVL := "mv_ch6"
	SX1->X1_VAR01   := "mv_par06"
	SX1->X1_PERGUNT := "Desmembrar Processos ?"
	SX1->X1_TIPO    := "N"
	SX1->X1_TAMANHO :=  1
	SX1->X1_GSC     := "C"
	SX1->X1_DEF01   := "Sim"
	SX1->X1_DEF02   := "Nao"
	SX1->(msUnlock())
ENDIF


sx1->(dbcommitall())
*/

dbselectarea("ECF")
aFilSel:=AvgSelectFil(.T.,"ECF") //Alcir Alves - 27/06/05 - conceito multifilial
//aadd(aFilSel,"02")
if aFilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
	cFilStr:=""
	for i:=1 to len(aFilSel)
		cFilStr+=iif(!empty(cFilStr),",","")+"'"+aFilSel[i]+"'"
	next
	If Pergunte("ECOVCF",.t.)
		If !empty(mv_par03) .and. !empty(mv_par04)
			cForn     := mv_par01
			cProcesso := mv_par02
			dDataI    := mv_par03
			dDataF    := mv_par04
			nTpRel    := mv_par05
			nTpProc   := mv_par06
			If lTop
				MsAguarde({|| GeraQuery(nTipo)},STR0001) //"Pesquisando processos"
			Else
				MsAguarde({|| GrvWorks(nTipo)},STR0001) //"Pesquisando processos"
			EndIf
			If WKECF->(BOF()) .AND. WKECF->(EOF()) .AND. WKECA->(BOF()) .AND. WKECA->(EOF())
				msginfo(STR0002) //"Não existem dados a processar"
			Else
				GrvAWork ()
				If nTpRel = 1
					RelPrint(nTipo)
				ElseIf nTpRel = 2
					EXPORTA (nTipo ,.T.)
				ElseIf nTpRel =3
					EXPORTA (nTipo ,.F.)
				EndIf
			EndIf
		Else
			msginfo(STR0003) //"Os periodos de data devem ser preenchidos"
			Return .F.
		EndIf
		
		WKECF->(dbclosearea())
		WKECA->(dbclosearea())
		If !lTop
			WKECF->(E_EraseArq(cNomArq1))
			WKECA->(E_EraseArq(cNomArq2))
		EndIf
	Endif
Endif

RETURN .T.
/*
Function        : GeraQuery
Autor           : Lucas Rolim Rosa Lopes
Parametros      : 1 - Seguro , 2 - Frete
Data            : 30/09/04
*/

**********************************************************
FUNCTION GeraQuery (nTipo)
**********************************************************
Local cQuery1,cQuery2
Local cCond := if( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local dFinal  := alltrim(alltrim(str(year(dDataF)))+alltrim(substr(dtoc(dDataF),4,2))+alltrim(substr(dtoc(dDataF),1,2)))
Local cWhere1 := "ECF."+cCond +" AND EEC."+cCond+" AND ECF.ECF_FILIAL in ("+cFilStr+") AND EEC.EEC_FILIAL =ECF.ECF_FILIAL  AND ECF.ECF_PREEMB = EEC.EEC_PREEMB AND ECF.ECF_DTCONT <= '"+dFinal+"' AND ECF.ECF_TP_FOR = '2' "
Local cWhere2 := "ECA."+cCond +" AND EEC."+cCond+" AND ECA.ECA_FILIAL in ("+cFilStr+") AND EEC.EEC_FILIAL =ECA.ECA_FILIAL  AND ECA.ECA_PREEMB = EEC.EEC_PREEMB AND ECA.ECA_DT_CON <= '"+dFinal+"' AND ECA.ECA_TP_FOR = '2' "
If !Empty(cForn)
	cWhere1+= "AND ECF.ECF_FORN = '"+cForn+"'"
	cWhere2+= "AND ECA.ECA_FORN = '"+cForn+"'"
endif

If !Empty(cProcesso)
	cWhere1+= "AND ECF.ECF_PREEMB = '"+cProcesso+"'"
	cWhere2+= "AND ECA.ECA_PREEMB = '"+cProcesso+"'"
endif

If nTipo == 1
	cWhere1+= "AND ECF.ECF_ID_CAM IN('103','105','151','572','573','532','533','611','804') "
	cWhere2+= "AND ECA.ECA_ID_CAM IN('103','105','151','572','573','532','533','611','804') "
Else
	cWhere1+= "AND ECF.ECF_ID_CAM IN('102','104','150','570','571','530','531','610','803') "
	cWhere2+= "AND ECA.ECA_ID_CAM IN('102','104','150','570','571','530','531','610','803') "
EndIF

cQuery1:="SELECT ECF.ECF_FILIAL,ECF.ECF_DTCONT, ECF.ECF_FORN,ECF.ECF_PREEMB, ECF.ECF_ID_CAM , ECF.ECF_VALOR  ,ECF.ECF_MOEDA , ECF.ECF_VL_MOE , EEC.EEC_DTEMBA FROM "
cQuery1+=RetSqlName("ECF")+ " ECF, "+RetSqlName("EEC")+" EEC WHERE " + cWhere1 + " ORDER BY  ECF.ECF_FILIAL,ECF.ECF_DTCONT , ECF.ECF_FORN , ECF.ECF_PREEMB , ECF.ECF_ID_CAM "

cQuery2:="SELECT ECA.ECA_FILIAL,ECA.ECA_DT_CON, ECA.ECA_FORN,ECA.ECA_PREEMB, ECA.ECA_ID_CAM , ECA.ECA_VALOR  ,ECA.ECA_MOEDA , ECA.ECA_VL_MOE , EEC.EEC_DTEMBA FROM "
cQuery2+=RetSqlName("ECA")+ " ECA, "+RetSqlName("EEC")+" EEC WHERE " + cWhere2 + " ORDER BY ECA.ECA_FILIAL,ECA.ECA_DT_CON , ECA.ECA_FORN , ECA.ECA_PREEMB ,ECA.ECA_ID_CAM "

cQuery1:=ChangeQuery(cQuery1)
TcQuery cQuery1 ALIAS "WKECF" NEW
TcSetField("WKECF","ECF_DTCONT","D")
TcSetField("WKECF","EEC_DTEMBA","D")
cQuery2:=ChangeQuery(cQuery2)
TcQuery cQuery2 ALIAS "WKECA" NEW
TcSetField("WKECA","ECA_DT_CON","D")
TcSetField("WKECA","EEC_DTEMBA","D")
Return .T.
/*
Function        : GeraQuery
Autor           : Lucas Rolim Rosa Lopes
Parametros      : 1 - Seguro , 2 - Frete
Data            : 30/09/04
*/

**********************************************************
FUNCTION GrvAWork ()
**********************************************************
Local nLenW,cAtuFil //Alcir Alves - 11-05-05 - tamanho do array
Local nTp_eve:=1 //Alcir Alves - 02-06-05 - tipo de evento 1-cambio   2-nota
Local cFornec, cProces ,nPos, nPOsDel
Local aAux
lOCAL lIgnora1:=.f.  //saldo anterior
lOCAL lIgnora2:=.f.  //saldo atual
Local I
//          1          2          3                4                   5                 6
//aWork[FORNECEDOR,PROCESSO,SALDO ANTERIOR, SALDO ANTERIOR MOEDA , FRETE/SEGURO , FRETE/SEGURO MOEDA  ,
//           7               8              9                10         11             12            13
//      VARIAÇÂO CAMBIAL ,ABATIMENTOS, ABATIMENTOS MOEDA , LIQUID , LIQUID MOEDA , SALDO ATUAL , SALDO ATUAL MOEDA ,
//             14                                    15              16    17            18           19
//      FRETE/SEGURO -PODE SER SUBISTITUIDO ,SUBISTITUI SLD ANT ,SUBTRAI,SUBITRAI MOE ,MOEDA,DATA DE EMBARQUE]
aWork:= {}
DbSelectArea("WKECA")
Do While WKECA->(!EOF())
	cFornec := WKECA->ECA_FORN
	cProces := WKECA->ECA_PREEMB
	cAtuFil:= WKECA->ECA_FILIAL
	Do While cProces == WKECA->ECA_PREEMB .AND. cFornec == WKECA->ECA_FORN .AND. cAtuFil==WKECA->ECA_FILIAL .AND. WKECA->(!EOF())
		//Alcir Alves - 02-06-05 - verificação da origem do evento
		if WKECA->ECA_ID_CAM $ "530/531/532/533/105/104" //evento de notas
			nTp_eve:=2
		else
			nTp_eve:=1
		endif
		nPos :=AScan(aWork,{|x| x[1]=cFornec .And. x[2]=cProces .And. x[20]=nTp_eve .AND. x[21]=cAtuFil})
		if nPos = 0  //  1        2    3 4 5 6 7 8 9 0 1 2 3 4  5  6 7   8
			lIgnora1:=.f.
			lIgnora2:=.f.
			Aadd(aWork,{cFornec,cProces,0,0,0,0,0,0,0,0,0,0,0,"","",0,0,WKECA->ECA_MOEDA,WKECA->EEC_DTEMBA,nTp_eve,cAtuFil})
			nPos :=AScan(aWork,{|x| x[1]=cFornec .And. x[2]=cProces .And. x[20]=nTp_eve .AND. x[21]=cAtuFil})
		EndIf
		If WKECA->ECA_DT_CON < dDataI
			Do Case
				Case WKECA->ECA_ID_CAM $ "103/102" .and. lIgnora1==.f.
					aWork[nPos][3]  += WKECA->ECA_VALOR
					aWork[nPos][4]  += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $  "105/104"
					if lIgnora1==.f.
						aWork[nPos][3] = 0
						aWork[nPos][4] = 0
						lIgnora1:=.t.
					endif
					aWork[nPos][3] += WKECA->ECA_VALOR
					aWork[nPos][4] += WKECA->ECA_VL_MOE
					
				Case WKECA->ECA_ID_CAM $ "150/151"
					aWork[nPos][3] += WKECA->ECA_VALOR
					aWork[nPos][4] += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $ "570/571/530/531/572/573/532/533" //Variação Cambial
					aWork[nPos][3] += WKECA->ECA_VALOR
				Case WKECA->ECA_ID_CAM $ "803/804/610/611"
					aWork[nPos][3] -= WKECA->ECA_VALOR
					aWork[nPos][4] -= WKECA->ECA_VL_MOE
					
			EndCase
		ElseIF WKECA->ECA_DT_CON >= dDataI .AND. WKECA->ECA_DT_CON <=dDataF
			Do Case
				Case WKECA->ECA_ID_CAM $ "103/102" .and. lIgnora2==.f.  //FRETE /SEGURO
					aWork[nPos][5] +=  WKECA->ECA_VALOR
					aWork[nPos][6] += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $  "105/104" //FRETE /SEGURO
					if lIgnora2==.f.
						aWork[nPos][5] := 0
						aWork[nPos][6] := 0
						lIgnora2:=.t.
					endif
					aWork[nPos][5] += WKECA->ECA_VALOR
					aWork[nPos][6] += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $ "150/151"
					aWork[nPos][5] += WKECA->ECA_VALOR
					aWork[nPos][6] += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $ "570/571/530/531/572/573/532/533" //Variação Cambial
					aWork[nPos][7] += WKECA->ECA_VALOR
				Case WKECA->ECA_ID_CAM $ "803/804"
					aWork[nPos][8] += WKECA->ECA_VALOR
					aWork[nPos][9] += WKECA->ECA_VL_MOE
				Case WKECA->ECA_ID_CAM $ "610/611"
					aWork[nPos][10] += WKECA->ECA_VALOR
					aWork[nPos][11] += WKECA->ECA_VL_MOE
			EndCase
		EndIf
		//Alcir Alves - 11-05-05
		aWork[nPos][12] := aWork[nPos][3] + aWork[nPos][5] +aWork[nPos][7] -aWork[nPos][8] - aWork[nPos][10]
		aWork[nPos][13] := aWork[nPos][4] + aWork[nPos][6] -aWork[nPos][9] -aWork[nPos][11]
		//
		WKECA->(DbSkip())
	EndDo
EndDo
DbSelectArea("WKECF")
Do While WKECF->(!EOF())
	cFornec := WKECF->ECF_FORN
	cProces := WKECF->ECF_PREEMB
	cAtuFil:= WKECF->ECF_FILIAL
	Do While cProces == WKECF->ECF_PREEMB .AND. cFornec == WKECF->ECF_FORN .AND. WKECF->(!EOF())
		//Alcir Alves - 02-06-05 - verificação da origem do evento
		if WKECF->ECF_ID_CAM $ "530/531/532/533/105/104" //evento de notas
			nTp_eve:=2
		else
			nTp_eve:=1
		endif
		nPos :=AScan(aWork,{|x| x[1]=cFornec .And. x[2]=cProces .And. x[20]=nTp_eve .AND. x[21]=cAtuFil})
		if nPos = 0  //  1        2    3 4 5 6 7 8 9 0 1 2 3 4  5  6 7     8              9
			lIgnora1:=.f.
			lIgnora2:=.f.
			Aadd(aWork,{cFornec,cProces,0,0,0,0,0,0,0,0,0,0,0,"","",0,0,WKECF->ECF_MOEDA,WKECF->EEC_DTEMBA,nTp_eve,cAtuFil})
			nPos :=AScan(aWork,{|x| x[1]=cFornec .And. x[2]=cProces .And. x[20]=nTp_eve .AND. x[21]=cAtuFil})
		EndIf
		If WKECF->ECF_DTCONT < dDataI
			Do Case
				Case WKECF->ECF_ID_CAM $ "103/102" .and. lIgnora1==.f.
					aWork[nPos][3]  += WKECF->ECF_VALOR
					aWork[nPos][4]  += WKECF->ECF_VL_MOE
					aWork[nPos][15] := "S"
					aWork[nPos][16] += WKECF->ECF_VALOR
					aWork[nPos][17] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $  "105/104"
					if lIgnora1==.f.
						aWork[nPos][3] = 0
						aWork[nPos][4] = 0
						lIgnora1:=.t.
					endif
					aWork[nPos][3] += WKECF->ECF_VALOR
					aWork[nPos][4] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $ "150/151"
					aWork[nPos][3] += WKECF->ECF_VALOR
					aWork[nPos][4] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $ "570/571/530/531/572/573/532/533" //Variação Cambial
					aWork[nPos][3] += WKECF->ECF_VALOR
				Case WKECF->ECF_ID_CAM $ "803/804/610/611"
					aWork[nPos][3] -= WKECF->ECF_VALOR
					aWork[nPos][4] -= WKECF->ECF_VL_MOE
					
			EndCase
		ElseIF WKECF->ECF_DTCONT  >= dDataI .AND. WKECF->ECF_DTCONT  <=dDataF
			Do Case
				Case WKECF->ECF_ID_CAM $ "103/102" .and. lIgnora2==.f. //FRETE /SEGURO
					aWork[nPos][5] +=  WKECF->ECF_VALOR
					aWork[nPos][6] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $  "105/104" //FRETE /SEGURO
					if lIgnora2==.f.
						aWork[nPos][5] := 0
						aWork[nPos][6] := 0
						lIgnora2:=.t.
					endif
					aWork[nPos][5] += WKECF->ECF_VALOR
					aWork[nPos][6] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $ "150/151"
					aWork[nPos][5] += WKECF->ECF_VALOR
					aWork[nPos][6] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $ "570/571/530/531/572/573/532/533" //Variação Cambial
					aWork[nPos][7] += WKECF->ECF_VALOR
				Case WKECF->ECF_ID_CAM $ "803/804"
					aWork[nPos][8] += WKECF->ECF_VALOR
					aWork[nPos][9] += WKECF->ECF_VL_MOE
				Case WKECF->ECF_ID_CAM $ "610/611"
					aWork[nPos][10] += WKECF->ECF_VALOR
					aWork[nPos][11] += WKECF->ECF_VL_MOE
			EndCase
		EndIf
		//Alcir Alves - 11-05-05
		aWork[nPos][12] := aWork[nPos][3] + aWork[nPos][5] +aWork[nPos][7] -aWork[nPos][8] - aWork[nPos][10]
		aWork[nPos][13] := aWork[nPos][4] + aWork[nPos][6] -aWork[nPos][9] -aWork[nPos][11]
		//
		WKECF->(DbSkip())
	EndDo
EndDo

// ----------------------------- MJA 13/10/05
FOR I = 1 TO LEN(aWork)
	if aWork[i][20] = 1
		cFornec := aWork[i][1]
		cProces := aWork[i][2]
		nPos :=  AScan(aWork,{|x| x[1]=cFornec .And. x[2]=cProces .And. x[20]=2})
		if nPos > 0
			IF aWork[i][5] = 0
				aWork[i][5] := aWork[nPos][12]
				aWork[i][12] += aWork[nPos][12]
				aWork[i][13] += aWork[nPos][13]
			Endif
			aWork[nPos][12] := 0
			aWork[nPos][13] := 0
		endif
	endif
Next I


ASORT(aWork,,, { |x, y| x[1] + x[2]  < y[1] + y[2]    })
return .t.

/*
Function        : RelPrint
Autor           : Lucas Rolim Rosa Lopes
Parametros      : 1 - Seguro , 2 - Frete
Data            : 30/09/04
*/

**********************************************************
FUNCTION RelPrint(nTipo)
**********************************************************
Local cForn
Private cDesc1       := STR0004 //"Este programa tem como objetivo imprimir relatório de"
Private cDesc2       := STR0005+ If (nTipo = 1 ,STR0006,STR0007) //"Relatório de variação cambial sobre "###"seguro"###"frete"
Private cDesc3       := "", cPict := "", imprime := .T.
Private ctitulo       := STR0005+ If (nTipo = 1 ,STR0006,STR0007) //"Relatório de variação cambial sobre "###"seguro"###"frete"
Private nLin         := 99, Cabec1 :="",Cabec2 := ""
Private lAbortPrint  := .F., limite:= 220, tamanho:= "G"
//Private tamanho      := "G"
Private nomeprog     := if (nTipo = 1 ,"ECOEV150A", "ECOEV150B")
Private aReturn      :={"Zebrado", 1,"Contabil", 1, 2, 1, "",1 }
Private nLastKey     := 0, cbtxt := Space(10), cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := if (nTipo = 1 ,"ECOEV150A", "ECOEV150B") // Coloque aqui o nome do arquivo usado para impressao em disco
wnrel := SetPrint("ECA",Nomeprog,"",cTitulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,"ECA")

Processa({||Imprime()},STR0008) //"Pesquisando Processos..."


Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

Return .T.

**************************
Static FUNCTION IMPRIME()
**************************
Local cFil_Atu,cForn ,i,l,w
Local lPVez := .T.
Local aSemTotal:={}
Local cSeeProc, dDtaDesp, cMoeDesp, nSldDespR := 0, nSldDesp := 0, nFrDespR := 0, nFrDesp := 0, nVCTot := 0
Local nLiqDespR := 0, nLiqDesp  := 0, nSldAtuaR := 0, nSldAtua := 0, nTotGerR := 0
Local aTotGerM := {}
//Local nGeralR := 0, nGeralM
Private nCol01:= 000, nCol02:= 022, nCol03:= 038, nCol04:= 058, nCol05:= 078, nCol06:= 098, nCol07:= 117, nCol08:= 136
Private nCol09:= 156, nCol10:= 176, nCol11:= 197, nCol12:= 33
Private cPicture := AVSX3("ECF_VALOR",6)
Private aTotForn := aTotGeral:= {}
Private aTotFornR := {}
Private aTotGeralR := {}
Private nPag:= 0
cForn := ""
aadd(aTotFornR,{0,0,0,0,0})
aadd(aTotFornR,{0,0,0,0,0})

aadd(aTotGeralR,{0,0,0,0,0})
aadd(aTotGeralR,{0,0,0,0,0})
cForn := ""
cFil_Atu:=""
lPVez:=.t.
For i := 1 to len(aWork)
	If cForn != aWork[i][1] //Fornecedor
		if lPVez==.t.
			cForn := aWork[i][1]
			lPVez:=.f.
		else
			if aTotFornR[1][1]==0 .and. aTotFornR[1][2]==0 .and. aTotFornR[1][3]==0 .and. aTotFornR[1][4]==0 .and. aTotFornR[1][5]==0 .and. aTotFornR[2][1]==0 .and. aTotFornR[2][2]==0 .and. aTotFornR[2][3]==0 .and. aTotFornR[2][4]==0 .and. aTotFornR[2][5]==0
				aadd(aSemTotal,cForn)
			endif
			aTotFornR := {}
			aadd(aTotFornR,{0,0,0,0,0})
			aadd(aTotFornR,{0,0,0,0,0})
			cForn := aWork[i][1]//Fornecedor
		endif
	endif
	CalcTot(i)
next
if aTotFornR[1][1]==0 .and. aTotFornR[1][2]==0 .and. aTotFornR[1][3]==0 .and. aTotFornR[1][4]==0 .and. aTotFornR[1][5]==0 .and. aTotFornR[2][1]==0 .and. aTotFornR[2][2]==0 .and. aTotFornR[2][3]==0 .and. aTotFornR[2][4]==0 .and. aTotFornR[2][5]==0
	aadd(aSemTotal,cForn)
endif

lPVez:=.t.
cForn := ""
aTotForn := {}
aTotGeral:= {}
aTotFornR := {}
aTotGeralR := {}
aadd(aTotFornR,{0,0,0,0,0})
aadd(aTotFornR,{0,0,0,0,0})
aadd(aTotGeralR,{0,0,0,0,0})
aadd(aTotGeralR,{0,0,0,0,0})


For i := 1 to len(aWork)
	if AScan(aSemTotal,{|x| x=aWork[i][1]})=0
		If cForn != aWork[i][1]//Fornecedor
			PulaLinha()
			aTotGerM := {}
			nTotGerR := 0
			If !lPVez
				//   @ nLin, 000 PSAY  __PrtThinLine()
				PulaLinha()
				@ nLin,nCol01 PSay STR0009//+" "+STR0018        //"Total do Fornecedor :"
				@ nLin,nCol10+12 PSay "R$"
				@ nLin,nCol11 PSay Transform(aTotFornR[2][5],cPicture)
				PulaLinha()
				For l:= 1 to Len(aTotForn)
					if aTotForn[l][6]==2
						@ nLin,nCol10+12 PSay aTotForn[l][1]
						@ nLin,nCol11 PSay Transform(aTotForn[l][5],cPicture)
					endif
					PulaLinha()
				Next
				PulaLinha()
			EndIf
			PulaLinha()
			@ nLin,00 PSAY  __PrtThinLine()
			PulaLinha()
			
			@ nLin,000 PSay STR0010+ aWork[i][1] +" - "+ Posicione("SA2",1,cFilSA2+aWork[i][1],"A2_NOME") //"Fornecedor : "
			PulaLinha()
			PulaLinha()
			cForn := aWork[i][1]//Fornecedor
			aTotForn:= {}
			aTotFornR:={}
			aadd(aTotFornR,{0,0,0,0,0})
			aadd(aTotFornR,{0,0,0,0,0})
		EndIf
		cSeeProc := aWork[i][2]
		j := i
		begin sequence //AAS - 25-10-05 - acerto do posicionamento
		DO WHILE aWork[j][2] == cSeeProc
			dDtaDesp := ALLTRIM(DTOC(aWork[j][19]))
			cMoeDesp := aWork[j][18]
			nSldDespR += aWork[j][3]
			nSldDesp +=  aWork[j][4]
			if aWork[j][20]==2 // tipo Cambio=1 / NF=2
				nFrDespR := aWork[j][5]
				nFrDesp  := aWork[j][6]
			endif
			nVCTot += aWork[j][7]
			nLiqDespR += aWork[j][10]
			nLiqDesp  += aWork[j][11]
			nSldAtuaR += aWork[j][12]
			nSldAtua  += aWork[j][13]
			j++
			i++    //AAS - 25-10-05 - acerto do posicionamento
			if LEN(aWork) < j
				//i := j-1
				i:=LEN(aWork)
				break
			endif
		ENDDO
		i:=i-1
		end sequence
		IF nLiqDesp+nSldAtua # 0
			@ nLin,nCol01 PSay alltrim(cSeeProc) // PROCESSO
			@ nLin,nCol02+1 PSay dDtaDesp // DATA
			@ nLin,nCol12 PSay cMoeDesp // MOEDA
			@ nLin,nCol03 PSay Transform(nSldDespR,cPicture) // SLD. ANTERIOR R$
			@ nLin,nCol04 PSay Transform(nSldDesp,cPicture) // SLD ANTERIOR MOEDA
			@ nLin,nCol05 PSay Transform(nFrDespR,cPicture) // FRETE NO PERIODO R$
			@ nLin,nCol06 PSay Transform(nFrDesp,cPicture) // FRETE NO PERIODO MOEDA
			@ nLin,nCol07 PSay Transform(nVCTot,cPicture) // VC
			@ nLin,nCol08 PSay Transform(nLiqDespR,cPicture) // LIQ. PERIODO R$
			@ nLin,nCol09 PSay Transform(nLiqDesp,cPicture) // LIQ. PERIODO MOEDA
			IF nSldAtuaR < 0.03
				nSldAtuaR := 0 // SLD ATUAL R$
			ENDIF
			@ nLin,nCol10 PSay Transform(nSldAtuaR,cPicture) // SLD ATUAL R$
			@ nLin,nCol11 PSay Transform(nSldAtua,cPicture) // SLD ATUAL MOEDA
			
			nPos :=  AScan(aTotGerM,{|x| x[1]=cMoeDesp})
			if nPos = 0
				AADD(aTotGerM,{cMoeDesp,nSldAtua})
			else
				aTotGerM[nPos][2] += nSldAtua
			endif
			nTotGerR += nSldAtuaR
			
			PulaLinha()
			CalcTot(i)
			lPVez:= .F.
		ENDIF
		//IF aWork[i][2] == cSeeProc
		//   IF i < LEN(aWork)
		//      i += 1
		//   endif
		//ENDIF
		nSldDespR := 0
		nSldDesp := 0
		nFrDespR := 0
		nFrDesp := 0
		nVCTot := 0
		nLiqDespR := 0
		nLiqDesp  := 0
		nSldAtuaR := 0
		nSldAtua := 0
		
	endif
    if i<len(aWork)
      if cFil_Atu!=aWork[i+1][21] //filial
         PtotForn() 
         cForn := aWork[i+1][1]//Fornecedor
         PtotFil()
         PulaLinha()
         @nLin,0 PSAY replicate("*",220)
         PulaLinha()
         cFil_Atu:=aWork[i+1][21]
         @ nLin,02 PSAY "Filial"+" "+cFil_Atu+" - "+AvgFilName({cFil_Atu})[1]
         PulaLinha()
         @nLin,0 PSAY replicate("*",220)
         PulaLinha()  
         PulaLinha()
         cForn := aWork[i+1][1]//Fornecedor
         @ nLin,000 PSay STR0010+ aWork[i+1][1] +" - "+ Posicione("SA2",1,cFilSA2+aWork[i+1][1],"A2_NOME") //"Fornecedor : "
         PulaLinha()  
         lPrim:=.f.    
      endif
   else
      PtotForn()
      cForn := aWork[i][1]//Fornecedor
      PtotFil()
   endif
Next

/*
PulaLinha()
@ nLin,nCol01 PSay STR0009//+" "+STR0018         //"Total do Fornecedor :"
@ nLin,nCol10+12 PSay "R$"
@ nLin,nCol11 PSay Transform(nTotGerR,cPicture)
PulaLinha()
For w := 1 to Len(aTotGerM)
	@ nLin,nCol10+12 PSay aTotGerM[w][1]
	@ nLin,nCol11 PSay Transform(aTotGerM[w][2],cPicture)
	PulaLinha()
Next w
@ nLin,00 PSAY  __PrtThinLine()
*/


Return .t.

**********************************************************
STATIC FUNCTION CalcTot(i)
**********************************************************
Local nPosFron, nPosGeral
nPosForn := ASCAN(aTotForn,{ |x| x[1] = aWork[i][18]  .and. x[6] = aWork[i][20] })
if nPosForn = 0
	AADD(aTotForn,{aWork[i][18],aWork[i][4],aWork[i][6],aWork[i][11],aWork[i][13],aWork[i][20]})
else
	aTotForn[nPosForn,2] += aWork[i][4] //Sld Anterior
	aTotForn[nPosForn,3] += aWork[i][6] //Seguro/Frete
	aTotForn[nPosForn,4] += aWork[i][11] //Liquidados
	aTotForn[nPosForn,5] += aWork[i][13]//Saldo Atual
endif

if aWork[i][20]==1  //cambio
	aTotFornR[1][1] += aWork[i][3] //Sld Anterior
	aTotFornR[1][2] += aWork[i][5]//Seguro/Frete
	aTotFornR[1][3] += aWork[i][7] //Variação Cambial
	aTotFornR[1][4] += aWork[i][10]//Liquidados
	aTotFornR[1][5] += aWork[i][12]//Saldo Atual
else  //nota
	nAze :=  AScan(aWork,{|x| x[1]=aWork[i][1] .And. x[2]=aWork[i][2] .And. x[20]=1})
	if nAze = 0
		aTotFornR[2][1] += aWork[i][3] //Sld Anterior
		aTotFornR[2][2] += aWork[i][5]//Seguro/Frete
		aTotFornR[2][3] += aWork[i][7] //Variação Cambial
		aTotFornR[2][4] += aWork[i][10]//Liquidados
		aTotFornR[2][5] += aWork[i][12]//Saldo Atual
	endif
endif



//nPosGeral := ASCAN(aTotGeral,{ |x| x[1] = aWork[i][18] .and. x[6] = aWork[i][20] })
nPosGeral := ASCAN(aTotGeral,{ |x| x[1] = aWork[i][18] })
if nPosGeral = 0  // Reais
	AADD(aTotGeral,{ aWork[i][18],aWork[i][4],aWork[i][6],aWork[i][11],aWork[i][13],aWork[i][20]})
else
	IF aWork[i][13] > 0
		aTotGeral[nPosGeral,2] += aWork[i][4] //Sld Anterior
		aTotGeral[nPosGeral,3] += aWork[i][6] //Seguro/Frete
		aTotGeral[nPosGeral,4] += aWork[i][11] //Liquidados
		aTotGeral[nPosGeral,5] += aWork[i][13]//Saldo Atual
	ENDIF
endif

if aWork[i][20]==1 //cambio
	aTotGeralR[1][1] += aWork[i][3] //Sld Anterior
	aTotGeralR[1][2] += aWork[i][5]//Seguro/Frete
	aTotGeralR[1][3] += aWork[i][7] //Variação Cambial
	aTotGeralR[1][4] += aWork[i][10]//Liquidados
	aTotGeralR[1][5] += aWork[i][12]//Saldo Atual
else      //nota
	nAze :=  AScan(aWork,{|x| x[1]=aWork[i][1] .And. x[2]=aWork[i][2] .And. x[20]=1})
	if nAze = 0
		aTotGeralR[1][1] += aWork[i][3] //Sld Anterior
		aTotGeralR[1][2] += aWork[i][5]//Seguro/Frete
		aTotGeralR[1][3] += aWork[i][7] //Variação Cambial
		aTotGeralR[1][4] += aWork[i][10]//Liquidados
		aTotGeralR[1][5] += aWork[i][12]//Saldo Atual
	endif
	
endif


ASORT(aTotForn ,,, { |x, y| x[1]   < y[1]  })
ASORT(aTotGeral,,, { |x, y| x[1]   < y[1]  })
Return .T.

**********************************************************
STATIC FUNCTION CabecPg(nTipo)
**********************************************************
@ 0,0 psay ""
nLin:=Cabec(cTitulo + STR0012+dtoc(dDataI)+STR0013+dtoc(dDataF),"","","REL_VC_FRETE","G",1)                                       //" - Perido de "###" até "
//                         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1          1                    2

If nTipo =1
	@ nLin+1,1 psay STR0014 //"Embarque             Dt. Emb.  Moeda             Sld. Anterior                        Seguro no periodo            Variacao Cambial          Liquidacoes no periodo                        Saldo Atual                "
Else
	@ nLin+1,1 psay STR0015 //"Embarque             Dt. Emb.  Moeda             Sld. Anterior                        Frete  no periodo            Variacao Cambial          Liquidacoes no periodo                        Saldo Atual                "
EndIF
@ nLin+2,1 psay STR0017
//@ nLin+3,1 psay "12345678901234567890 01/23/12   123  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99 999,999,999,999.99 999,999,999,999.99  999,999,999,999.99  999,999,999,999.99   999,999,999,999.99"
//@ nLin+4,1 psay "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890012345678901234567890"
nLin:=nLin+2
nPag:=nPag+1
RETURN .T.

**********************************************************
STATIC FUNCTION PulaLinha()
**********************************************************
If nLin > 65
	CabecPg(nTipo)
Else
	nLin++
EndIf
RETURN .T.

**********************************************************
FUNCTION GRvWorks (nTipo)
**********************************************************
Local bWECFEve:= bWECAEve:= bWECFForn := bWECAForn := bWECFProc := bWECAProc := { || .T. }
CriaWorks ()
ECF->(DbSetOrder(7))
ECA->(DbSetOrder(7))
If !Empty(cForn)
	bWECFForn:= { || ECF->ECF_FORN == cForn }
	bWECAForn:= { || ECA->ECA_FORN == cForn }
endif

If !Empty(cProcesso)
	bWECFProc:=  {|| ECF->ECF_PREEMB == cProcesso}
	bWECAProc:=  {|| ECA->ECA_PREEMB == cProcesso}
endif

If nTipo == 1
	bWECFEve:= {|| ECF->ECF_ID_CAM $ "103/105/151/572/573/532/533/611/804" }
	bWECAEve:= {|| ECA->ECA_ID_CAM $ "103/105/151/572/573/532/533/611/804" }
Else
	bWECFEve:= {|| ECF->ECF_ID_CAM $ "102/104/150/570/571/530/531/610/803" }
	bWECAEve:= {|| ECA->ECA_ID_CAM $ "102/104/150/570/571/530/531/610/803" }
EndIf


DbSelectArea("ECF")
ECF->(DbSeek(cFilECF))
Do While ECF->(!EOF()) .AND. ECF->ECF_FILIAL == cFilECF .AND.ECF->ECF_DTCONT <= dDataF
	If ECF->ECF_TP_FOR == '2' .AND. Eval(bWECFForn) .AND. Eval(bWECFProc) .AND. Eval(bWECFEve)
		RecLock("WKECF",.T.)
		WKECF->ECF_FILIAL :=ECF->ECF_FILIAL
		WKECF->ECF_DTCONT :=ECF->ECF_DTCONT
		WKECF->ECF_FORN   :=ECF->ECF_FORN
		WKECF->ECF_PREEMB :=ECF->ECF_PREEMB
		WKECF->ECF_ID_CAM :=ECF->ECF_ID_CAM
		WKECF->ECF_VALOR  :=ECF->ECF_VALOR
		WKECF->ECF_MOEDA  :=ECF->ECF_MOEDA
		WKECF->ECF_VL_MOE :=ECF->ECF_VL_MOE
		WKECF->EEC_DTEMBA :=Posicione("EEC",1,cFilEEC+ECF->ECF_PREEMB,"EEC_DTEMBA")
		WKECF->(MsUnlock())
	EndIF
	ECF->(DbSkip())
EndDo
DbSelectArea("ECA")
ECA->(DbSeek(cFilECA))
Do While ECA->(!EOF()) .AND. ECA->ECA_FILIAL == cFilECA .AND.ECA->ECA_DT_CON <= dDataF
	If ECA->ECA_TP_FOR == '2' .AND. Eval(bWECAForn) .AND. Eval(bWECAProc) .AND. Eval(bWECAEve)
		RecLock("WKECA",.T.)
		WKECA->ECA_FILIAL :=ECA->ECA_FILIAL
		WKECA->ECA_DT_CON :=ECA->ECA_DT_CON
		WKECA->ECA_FORN   :=ECA->ECA_FORN
		WKECA->ECA_PREEMB :=ECA->ECA_PREEMB
		WKECA->ECA_ID_CAM :=ECA->ECA_ID_CAM
		WKECA->ECA_VALOR  :=ECA->ECA_VALOR
		WKECA->ECA_MOEDA  :=ECA->ECA_MOEDA
		WKECA->ECA_VL_MOE :=ECA->ECA_VL_MOE
		WKECA->EEC_DTEMBA :=Posicione("EEC",1,cFilEEC+ECA->ECA_PREEMB,"EEC_DTEMBA")
		WKECA->(MsUnlock())
	EndIf
	ECA->(DbSkip())
EndDo
WKECF->(DbGOTOp())
WKECA->(DbGOTOp())
Return .T.
**********************************************************
FUNCTION CriaWorks ()
**********************************************************
//Local cNomeArq1, cNomeArq2
Private aHeader[0],aCampos := {}
PRIVATE aEstru := {}
AADD(aEstru,{ "ECF_FILIAL" ,  AVSX3("ECF_FILIAL",2) , AVSX3("ECF_FILIAL",3), AVSX3("ECF_FILIAL",4)  }) //ALCIR ALVES - 27-05-06
AADD(aEstru,{ "ECF_DTCONT" ,  AVSX3("ECF_DTCONT",2) , AVSX3("ECF_DTCONT",3), AVSX3("ECF_DTCONT",4)  })
AADD(aEstru,{ "ECF_FORN  " ,  AVSX3("ECF_FORN  ",2) , AVSX3("ECF_FORN  ",3), AVSX3("ECF_FORN  ",4)  })
AADD(aEstru,{ "ECF_PREEMB" ,  AVSX3("ECF_PREEMB",2) , AVSX3("ECF_PREEMB",3), AVSX3("ECF_PREEMB",4)  })
AADD(aEstru,{ "ECF_ID_CAM" ,  AVSX3("ECF_ID_CAM",2) , AVSX3("ECF_ID_CAM",3), AVSX3("ECF_ID_CAM",4)  })
AADD(aEstru,{ "ECF_VALOR"  ,  AVSX3("ECF_VALOR" ,2) , AVSX3("ECF_VALOR" ,3), AVSX3("ECF_VALOR" ,4)  })
AADD(aEstru,{ "ECF_MOEDA"  ,  AVSX3("ECF_MOEDA" ,2) , AVSX3("ECF_MOEDA" ,3), AVSX3("ECF_MOEDA" ,4)  })
AADD(aEstru,{ "ECF_VL_MOE" ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "EEC_DTEMBA" ,  AVSX3("EEC_DTEMBA",2) , AVSX3("EEC_DTEMBA",3), AVSX3("EEC_DTEMBA",4)  })

cNomArq1:=E_CriaTrab(,aEstru,"WKECF")
IndRegua("WKECF",cNomArq1+TEOrdBagExt(),"DToS(ECF_DTCONT)+ECF_FORN+ECF_PREEMB+ECF_ID_CAM")
aEstru := {}
AADD(aEstru,{ "ECA_FILIAL" ,  AVSX3("ECA_FILIAL",2) , AVSX3("ECA_FILIAL",3), AVSX3("ECA_FILIAL",4)  }) //ALCIR ALVES - 27-05-06
AADD(aEstru,{ "ECA_DT_CON" ,  AVSX3("ECA_DT_CON",2) , AVSX3("ECA_DT_CON",3), AVSX3("ECA_DT_CON",4)  })
AADD(aEstru,{ "ECA_FORN  " ,  AVSX3("ECA_FORN  ",2) , AVSX3("ECA_FORN  ",3), AVSX3("ECA_FORN  ",4)  })
AADD(aEstru,{ "ECA_PREEMB" ,  AVSX3("ECA_PREEMB",2) , AVSX3("ECA_PREEMB",3), AVSX3("ECA_PREEMB",4)  })
AADD(aEstru,{ "ECA_ID_CAM" ,  AVSX3("ECA_ID_CAM",2) , AVSX3("ECA_ID_CAM",3), AVSX3("ECA_ID_CAM",4)  })
AADD(aEstru,{ "ECA_VALOR"  ,  AVSX3("ECA_VALOR" ,2) , AVSX3("ECA_VALOR" ,3), AVSX3("ECA_VALOR" ,4)  })
AADD(aEstru,{ "ECA_MOEDA"  ,  AVSX3("ECA_MOEDA" ,2) , AVSX3("ECA_MOEDA" ,3), AVSX3("ECA_MOEDA" ,4)  })
AADD(aEstru,{ "ECA_VL_MOE" ,  AVSX3("ECA_VL_MOE",2) , AVSX3("ECA_VL_MOE",3), AVSX3("ECA_VL_MOE",4)  })
AADD(aEstru,{ "EEC_DTEMBA" ,  AVSX3("EEC_DTEMBA",2) , AVSX3("EEC_DTEMBA",3), AVSX3("EEC_DTEMBA",4)  })
cNomArq2:=E_CriaTrab(,aEstru,"WKECA")
IndRegua("WKECA",cNomArq2+TEOrdBagExt(),"DToS(ECA_DT_CON)+ECA_FORN+ECA_PREEMB+ECA_ID_CAM")
Return .T.
************************************************************************
static FUNCTION EXPORTA (nTipo ,lExcel)
************************************************************************
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp,i
Local aEstru:= {}
Local cPath := AllTrim(GetTempPath())
Local cDirDocs := MsDocPath()
AADD(aEstru,{ "FILIAL"    ,  AVSX3("ECF_FILIAL",2) , AVSX3("ECF_FILIAL",3), AVSX3("ECF_FILIAL",4)  })
AADD(aEstru,{ "FORN  " ,  AVSX3("ECA_FORN  ",2) , AVSX3("ECA_FORN  ",3), AVSX3("ECA_FORN  ",4)  })
AADD(aEstru,{ "PROCESSO" ,  AVSX3("ECA_PREEMB",2) , AVSX3("ECA_PREEMB",3), AVSX3("ECA_PREEMB",4)  })
AADD(aEstru,{ "DT_EMBARQ"    ,  AVSX3("EEC_DTEMBA",2) , AVSX3("EEC_DTEMBA",3), AVSX3("EEC_DTEMBA",4)  })
AADD(aEstru,{ "MOEDA   "     ,  AVSX3("ECF_MOEDA" ,2) , AVSX3("ECF_MOEDA" ,3), AVSX3("ECF_MOEDA" ,4)  })
AADD(aEstru,{ "SLD_ANT"      ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "SLD_ANT_M"    ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
If nTipo = 1
	AADD(aEstru,{ "SEGURO_R"  ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
	AADD(aEstru,{ "SEGURO_MOE",  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
Else
	AADD(aEstru,{ "FRETE_R"   ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
	AADD(aEstru,{ "FRETE_MOE" ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
EndIf

AADD(aEstru,{ "V_CAMBIAL"    ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "LIQUID"       ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "LIQUID_M"     ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "SLD_ATU"      ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })
AADD(aEstru,{ "SLD_ATU_M"    ,  AVSX3("ECF_VL_MOE",2) , AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4)  })


cDirDocs := E_CriaTrab(, aEstru, cArquivo)


For i :=1 to Len (aWork)
	(cArquivo)->( DbAppend() )
	(cArquivo)->FILIAL        := aWork[i][21]
	(cArquivo)->FORN      := aWork[i][1]
	(cArquivo)->PROCESSO  := aWork[i][2]
	(cArquivo)->DT_EMBARQ := aWork[i][19]
	(cArquivo)->MOEDA     := aWork[i][18]
	(cArquivo)->SLD_ANT   := aWork[i][3]
	(cArquivo)->SLD_ANT_M := aWork[i][4]
	If nTipo = 1
		(cArquivo)->SEGURO_R   := aWork[i][5]
		(cArquivo)->SEGURO_MOE := aWork[i][6]
	Else
		(cArquivo)->FRETE_R    := aWork[i][5]
		(cArquivo)->FRETE_MOE  := aWork[i][6]
	EndIf
	(cArquivo)->V_CAMBIAL     := aWork[i][7]
	(cArquivo)->LIQUID        := aWork[i][10]
	(cArquivo)->LIQUID_M      := aWork[i][11]
	(cArquivo)->SLD_ATU       := aWork[i][12]
	(cArquivo)->SLD_ATU_M     := aWork[i][13]
	
Next

if lExcel
	(cArquivo)->( DbCloseArea() )
	CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )
	
	//Envia ao Excel
	If ! ApOleClient( 'MsExcel' )
		Msgstop(STR0016) //"MsExcel não instalado."
		RETURN .F.
	else
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf
else
	//Abre para criacao do arquivo.
	TR350ARQUIVO(cArquivo)
	(cArquivo)->( DbCloseArea() )
endif
RETURN .T.

************************************************************************
Static function PtotForn() // Alcir Alves - 28-06-05 - total por fornecedor
************************************************************************
local l:=0
If Len(aTotForn) > 0 .OR. Len(aTotFornR) > 0
	//   @ nLin, 000 PSAY  __PrtThinLine()
	If nLin > 58
		nLin:=66
		PulaLinha()
	ENDIF
	PulaLinha()
	@ nLin,nCol01 PSay STR0009+" "+STR0018         //"Total do Fornecedor :"
	@ nLin,nCol12 PSay "R$"
	@ nLin,nCol04 PSay Transform(aTotFornR[2][1],cPicture)
	@ nLin,nCol06 PSay Transform(aTotFornR[2][2],cPicture)
	@ nLin,nCol07 PSay Transform(aTotFornR[2][3],cPicture)
	@ nLin,nCol09 PSay Transform(aTotFornR[2][4],cPicture)
	@ nLin,nCol11 PSay Transform(aTotFornR[2][5],cPicture)
	PulaLinha()
	For l:= 1 to Len(aTotForn)
		if aTotForn[l][6]==2
			@ nLin,nCol12 PSay aTotForn[l][1]
			@ nLin,nCol04 PSay Transform(aTotForn[l][2],cPicture)
			@ nLin,nCol06 PSay Transform(aTotForn[l][3],cPicture)
			@ nLin,nCol09 PSay Transform(aTotForn[l][4],cPicture)
			@ nLin,nCol11 PSay Transform(aTotForn[l][5],cPicture)
			PulaLinha()
		endif
	Next
	PulaLinha()
	@ nLin,nCol01 PSay STR0009+" "+STR0019         //"Total do Fornecedor :"
	@ nLin,nCol12 PSay "R$"
	@ nLin,nCol04 PSay Transform(aTotFornR[1][1],cPicture)
	@ nLin,nCol06 PSay Transform(aTotFornR[1][2],cPicture)
	@ nLin,nCol07 PSay Transform(aTotFornR[1][3],cPicture)
	@ nLin,nCol09 PSay Transform(aTotFornR[1][4],cPicture)
	@ nLin,nCol11 PSay Transform(aTotFornR[1][5],cPicture)
	PulaLinha()
	For l:= 1 to Len(aTotForn)
		if aTotForn[l][6]==1
			@ nLin,nCol12 PSay aTotForn[l][1]
			@ nLin,nCol04 PSay Transform(aTotForn[l][2],cPicture)
			@ nLin,nCol06 PSay Transform(aTotForn[l][3],cPicture)
			@ nLin,nCol09 PSay Transform(aTotForn[l][4],cPicture)
			@ nLin,nCol11 PSay Transform(aTotForn[l][5],cPicture)
			PulaLinha()
		endif
	Next
	aTotForn:= {}
	aTotFornR:={}
	aadd(aTotFornR,{0,0,0,0,0})
	aadd(aTotFornR,{0,0,0,0,0})
	
EndIf
return .t.

************************************************************************
Static function PtotFil() // Alcir Alves - 28-06-05 - total por filial
************************************************************************
local l:=0
If Len(aTotGeral) > 0 .OR. Len(aTotGeralR) > 0
	If nLin > 58
		nLin:=66
		PulaLinha()
	ENDIF
	@ nLin, 000 PSAY  __PrtThinLine()
	PulaLinha()
	@ nLin,nCol01 PSay STR0011+" "+STR0018         //"Total Geral :"
	@ nLin,nCol12 PSay "R$"
	@ nLin,nCol04 PSay Transform(aTotGeralR[2][1],cPicture)
	@ nLin,nCol06 PSay Transform(aTotGeralR[2][2],cPicture)
	@ nLin,nCol07 PSay Transform(aTotGeralR[2][3],cPicture)
	@ nLin,nCol09 PSay Transform(aTotGeralR[2][4],cPicture)
	@ nLin,nCol11 PSay Transform(aTotGeralR[2][5],cPicture)
	PulaLinha()
	For l:= 1 to Len(aTotGeral)
		if aTotGeral[l][6]==2
			@ nLin,nCol12 PSay aTotGeral[l][1]
			@ nLin,nCol04 PSay Transform(aTotGeral[l][2],cPicture)
			@ nLin,nCol06 PSay Transform(aTotGeral[l][3],cPicture)
			@ nLin,nCol09 PSay Transform(aTotGeral[l][4],cPicture)
			@ nLin,nCol11 PSay Transform(aTotGeral[l][5],cPicture)
			PulaLinha()
		endif
	Next
	PulaLinha()
	@ nLin,nCol01 PSay STR0011+" "+STR0019         //"Total Geral :"
	@ nLin,nCol12 PSay "R$"
	@ nLin,nCol04 PSay Transform(aTotGeralR[1][1],cPicture)
	@ nLin,nCol06 PSay Transform(aTotGeralR[1][2],cPicture)
	@ nLin,nCol07 PSay Transform(aTotGeralR[1][3],cPicture)
	@ nLin,nCol09 PSay Transform(aTotGeralR[1][4],cPicture)
	@ nLin,nCol11 PSay Transform(aTotGeralR[1][5],cPicture)
	PulaLinha()
	For l:= 1 to Len(aTotGeral)
		if aTotGeral[l][6]==1
			@ nLin,nCol12 PSay aTotGeral[l][1]
			@ nLin,nCol04 PSay Transform(aTotGeral[l][2],cPicture)
			@ nLin,nCol06 PSay Transform(aTotGeral[l][3],cPicture)
			@ nLin,nCol09 PSay Transform(aTotGeral[l][4],cPicture)
			@ nLin,nCol11 PSay Transform(aTotGeral[l][5],cPicture)
			PulaLinha()
		endif
	Next
	PulaLinha()
	@ nLin, 000 PSAY  __PrtThinLine()
	PulaLinha()
	aTotForn := aTotGeral:= {}
	aTotFornR := {}
	aTotGeralR := {}
	nPag:= 0
	aadd(aTotFornR,{0,0,0,0,0})
	aadd(aTotFornR,{0,0,0,0,0})
	aadd(aTotGeralR,{0,0,0,0,0})
	aadd(aTotGeralR,{0,0,0,0,0})
EndIf
return .t.


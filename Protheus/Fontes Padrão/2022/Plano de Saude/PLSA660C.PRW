#INCLUDE "PROTHEUS.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSA660.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSA660C º Autor ³ Otacilio A. Junior º Data ³  03/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamada do programa.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA660C          

If MsgYesNo(STR0047,STR0048)//"Prosseguir com a Copia do Sub-Contrato selecionado?","Atenção"
	Processa({|| Run_Copia(),PLS660VAR("BQC",BQC->(Recno()),4)},STR0049)//"Copiando Sub-Contrato..."
Endif

Return                                               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Run_Copia º Autor ³ Otacilio A. Junior º Data ³  03/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo para copia de subcontrato.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Run_Copia

LOCAL adados  :={}
LOCAL aNewDad :={}
LOCAL aHeader :={}
LOCAL ncols   := 0
LOCAL nCont   := 0
LOCAL cCampo  := ""
LOCAL cSubCon := ""
LOCAL I,J,H,G,nI,nPos
LOCAL nIndexBQC := BQC->(IndexOrd())

LOCAL aArray:={	{"BQC",1,"BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)"},;
				{"BQD",1,"BQD->(BQD_FILIAL+BQD_CODIGO+BQD_NUMCON+BQD_VERCON+BQD_SUBCON+BQD_VERSUB)"},;
				{"BT6",1,"BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB)"},;
				{"BT7",1,"BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB)"},;
				{"BHF",1,"BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB)"},;
				{"BT8",1,"BT8->(BT8_FILIAL+BT8_CODINT+BT8_CODIGO+BT8_NUMCON+BT8_VERCON+BT8_SUBCON+BT8_VERSUB)"},;
				{"BW5",1,"BW5->(BW5_FILIAL+BW5_CODINT+BW5_CODIGO+BW5_NUMCON+BW5_VERCON+BW5_SUBCON+BW5_VERSUB)"},;
				{"BEY",1,"BEY->(BEY_FILIAL+BEY_CODINT+BEY_CODIGO+BEY_NUMCON+BEY_VERCON+BEY_SUBCON+BEY_VERSUB)"},;
				{"BA6",1,"BA6->(BA6_FILIAL+BA6_CODINT+BA6_CODIGO+BA6_NUMCON+BA6_VERCON+BA6_SUBCON+BA6_VERSUB)"},;
				{"BT9",1,"BT9->(BT9_FILIAL+BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB)"},;
				{"BTK",1,"BTK->(BTK_FILIAL+BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB)"},;
				{"BR6",1,"BR6->(BR6_FILIAL+BR6_CODIGO+BR6_NUMCON+BR6_VERCON+BR6_SUBCON+BR6_VERSUB)"},;
				{"BFV",1,"BFV->(BFV_FILIAL+BFV_CODIGO+BFV_NUMCON+BFV_VERCON+BFV_SUBCON+BFV_VERSUB)"},;
				{"BHG",1,"BHG->(BHG_FILIAL+BHG_CODINT+BHG_CODIGO+BHG_NUMCON+BHG_VERCON+BHG_SUBCON+BHG_VERSUB)"},;
				{"BHN",1,"BHN->(BHN_FILIAL+BHN_CODINT+BHN_CODIGO+BHN_NUMCON+BHN_VERCON+BHN_SUBCON+BHN_VERSUB)"},;
				{"BT0",1,"BT0->(BT0_FILIAL+BT0_CODIGO+BT0_NUMCON+BT0_VERCON+BT0_SUBCON+BT0_VERSUB)"},;
				{"BHS",1,"BHS->(BHS_FILIAL+BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB)"},;
				{"BJW",1,"BJW->(BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB)"},;
				{"BGP",1,"BGP->(BGP_FILIAL+BGP_CODINT+BGP_CODIGO+BGP_NUMCON+BGP_VERCON+BGP_SUBCON+BGP_VERSUB)"},;
				{"BGG",1,"BGG->(BGG_FILIAL+BGG_CODINT+BGG_CODIGO+BGG_NUMCON+BGG_VERCON+BGG_SUBCON+BGG_VERSUB)"},;
				{"BOR",1,"BOR->(BOR_FILIAL+BOR_CODINT+BOR_CODEMP+BOR_NUMCON+BOR_VERCON+BOR_SUBCON+BOR_VERSUB)"},;
				{"BJC",1,"BJC->(BJC_FILIAL+BJC_CODINT+BJC_CODEMP+BJC_NUMCON+BJC_VERCON+BJC_SUBCON+BJC_VERSUB)"},;
				{"BCO",1,"BCO->(BCO_FILIAL+BCO_CODOPE+BCO_CODEMP+BCO_NUMCON+BCO_VERCON+BCO_SUBCON+BCO_VERSUB)"},;
				{"BMF",1,"BMF->(BMF_FILIAL+BMF_CODINT+BMF_CODEMP+BMF_NUMCON+BMF_VERCON+BMF_SUBCON+BMF_VERSUB)"},;
				{"BMG",1,"BMG->(BMG_FILIAL+BMG_CODINT+BMG_CODEMP+BMG_NUMCON+BMG_VERCON+BMG_SUBCON+BMG_VERSUB)"},;
				{"BMH",1,"BMH->(BMH_FILIAL+BMH_CODINT+BMH_CODEMP+BMH_NUMCON+BMH_VERCON+BMH_SUBCON+BMH_VERSUB)"},;
				{"BMI",1,"BMI->(BMI_FILIAL+BMI_CODINT+BMI_CODEMP+BMI_NUMCON+BMI_VERCON+BMI_SUBCON+BMI_VERSUB)"},;
				{"BML",1,"BML->(BML_FILIAL+BML_CODINT+BML_CODEMP+BML_NUMCON+BML_VERCON+BML_SUBCON+BML_VERSUB)"},;
				{"BMM",1,"BMM->(BMM_FILIAL+BMM_CODINT+BMM_CODEMP+BMM_NUMCON+BMM_VERCON+BMM_SUBCON+BMM_VERSUB)"},;
				{"BKA",1,"BKA->(BKA_FILIAL+BKA_CODINT+BKA_CODEMP+BKA_NUMCON+BKA_VERCON+BKA_SUBCON+BKA_VERSUB)"},;
				{"BKB",1,"BKB->(BKB_FILIAL+BKB_CODINT+BKB_CODEMP+BKB_NUMCON+BKB_VERCON+BKB_SUBCON+BKB_VERSUB)"},;
				{"BG6",1,"BG6->(BG6_FILIAL+BG6_CODINT+BG6_CODEMP+BG6_NUMCON+BG6_VERCON+BG6_SUBCON+BG6_VERSUB)"},;
				{"BLU",1,"BLU->(BLU_FILIAL+BLU_CODINT+BLU_CODIGO+BLU_NUMCON+BLU_VERCON+BLU_SUBCON+BLU_VERSUB)"},;
				{"BLW",1,"BLW->(BLW_FILIAL+BLW_CODINT+BLW_CODIGO+BLW_NUMCON+BLW_VERCON+BLW_SUBCON+BLW_VERSUB)"},;
				{"BLT",1,"BLT->(BLT_FILIAL+BLT_CODINT+BLT_CODIGO+BLT_NUMCON+BLT_VERCON+BLT_SUBCON+BLT_VERSUB)"},;
				{"BLX",1,"BLX->(BLX_FILIAL+BLX_CODINT+BLX_CODIGO+BLX_NUMCON+BLX_VERCON+BLX_SUBCON+BLX_VERSUB)"},;
				{"BWV",1,"BWV->(BWV_FILIAL+BWV_CODINT+BWV_CODIGO+BWV_NUMCON+BWV_VERCON+BWV_SUBCON+BWV_VERSUB)"},;
				{"BTN",1,"BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB)"},;
				{"BFT",1,"BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB)"},;
				{"BHE",1,"BHE->(BHE_FILIAL+BHE_CODINT+BHE_CODIGO+BHE_NUMCON+BHE_VERCON+BHE_SUBCON+BHE_VERSUB)"},;
				{"BBX",1,"BBX->(BBX_FILIAL+BBX_CODIGO+BBX_NUMCON+BBX_VERCON+BBX_SUBCON+BBX_VERSUB)"},;
				{"BGW",1,"BGW->(BGW_FILIAL+BGW_CODIGO+BGW_NUMCON+BGW_VERCON+BGW_SUBCON+BGW_VERSUB)"},;
				{"BYF",1,"BYF->(BYF_FILIAL+BYF_CODOPE+BYF_CODEMP+BYF_CONEMP+BYF_VERCON+BYF_SUBCON+BYF_VERSUB)"},;
				{"BGS",1,"BGS->(BGS_FILIAL+BGS_CODINT+BGS_CODIGO+BGS_NUMCON+BGS_VERCON+BGS_SUBCON+BGS_VERSUB)"},;
				{"BGL",1,"BGL->(BGL_FILIAL+BGL_CODINT+BGL_CODIGO+BGL_NUMCON+BGL_VERCON+BGL_SUBCON+BGL_VERSUB)"},;
				{"BYA",1,"BYA->(BYA_FILIAL+BYA_CODINT+BYA_CODIGO+BYA_NUMCON+BYA_VERSAO+BYA_SUBCON+BYA_VERSUB)"},;
				{"BS9",1,"BS9->(BS9_FILIAL+BS9_SUBCON)"},;
				{"BNX",1,"BNX->(BNX_FILIAL+BNX_SUBCON)"},;
				{"BNZ",1,"BNZ->(BNZ_FILIAL+BNZ_SUBCON)"}}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusção de campos para gravação       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL660CP")
   aadd(aNewDad,Execblock("PL660CP",.F.,.F.,{}))
Endif        
                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratameto das tabelas entes de gravar   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS660TAB")
	aArray := Execblock("PLS660TAB",.F.,.F.,{aArray})
Endif


cSubCon := BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
BQC->(DbSetOrder(1))
BQC->(MSSeek(xFilial("BQC")+SUBSTR(cSubCon,1,23)+"Z",.T.))
BQC->(DbSkip(-1))
nSubCon:= StrZero(Val(BQC->BQC_SUBCON)+1,09)
ProcRegua(Len(aArray))

For i := 1 To Len(aArray)
	aDados := {} 
	aHeader:= &(aArray[i,1])->(DbStruct())
	nCols  := Len(&(aArray[i,1])->(DbStruct()))
	nCont  := 0
	dbSelectArea(aArray[i,1])
	dbSetOrder(aArray[i,2])
	If MsSeek(xFilial(aArray[i,1])+cSubCon)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega matriz com o registro a ser clonado do BMQ Grp.Ope X Procedimentos X SubItens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !(&(aArray[i,1])->(Eof())) .and. ( xFilial(aArray[i,1])+cSubCon == &(aArray[i,3]) )
			nCont++
			aadd(aDados,Array(nCols))
			For nI := 1 to nCols
				aDados[nCont,nI] := &(aArray[i,1])->(FieldGet(nI))
			Next nI                           
			&(aArray[i,1])->(DbSkip())
		End	   
       
		For h := 1 to Len(aDados)
			RecLock(aArray[i,1],.T.)
			For g := 1 to nCols 
				If (nPos:= Ascan(aNewDad,{|x| alltrim(x[1]) == alltrim(aHeader[g,1])})) == 0
					&(aArray[i,1])->(FieldPut(g,aDados[h,g]))
				EndIf
			Next g 
                                         
			If aArray[i,1] == "BQC"
				&(aArray[i,1])->(FieldPut(FieldPos("BQC_DATCON"),Date()))
				&(aArray[i,1])->(FieldPut(FieldPos("BQC_VALID"),CtoD("  /  /  ")))
			ElseIf aArray[i,1] == "BQD"
				&(aArray[i,1])->(FieldPut(FieldPos("BQD_DATINI"),Date()))
			EndIf                                               
	       
			cCampo	:= aArray[i,1]+"->"+aArray[i,1]+"_SUBCON"
			If aArray[i,1] $ "BS9,BNX,BNZ"
				&(cCampo) := SubStr(&(cCampo),1,23)+nSubCon+"001"
			Else
				&(cCampo):= nSubCon 
				cCampo	:= aArray[i,1]+"->"+aArray[i,1]+"_VERSUB"
				&(cCampo):= "001"
				&(aArray[i,1])->(MsUnlock())
			EndIf
		Next h
	EndIf                               
	IncProc()
Next i

BQC->(DbSetOrder(nIndexBQC))

Return

#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE008()
Carrega tabela com fator de correcao a 20 graus para efeito de historico.
Adaptação da função TDCEE008
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
@return nFATCO
/*/
//-------------------------------------------------------------------
Function DCLEE008()
Local nPosCod		:= 0
Local nPosTT    	:= 0
Local nPosTA    	:= 0
Local nPosDA    	:= 0
Local nPosFAT   	:= 0
Local nTTANQUE	:= 0
Local nTAMOSTRA	:= 0
Local nDAMOSTRA	:= 0
Local nFATCO		:= 0
Local cCOD			:= ""
Local cMens		:= ""
Local aArea		:= GetArea()
Local lMvc			:= Type("oModelDcl") <> "U"
Local oModDH4		:= IIF(lMvc,oModelDcl:GetModel("DH4DETAIL"),NIL)

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

IF READVAR() == "M->D3_FATCORR"
    cCOD		:= M->D3_COD
	nTTANQUE	:= M->D3_TEMPTAQ
	nTAMOSTRA	:= M->D3_TEMPAMO
	nDAMOSTRA	:= M->D3_DENSAMB
	nFATCO   	:= M->D3_FATCORR
ENDIF

IF READVAR() == "M->D3A_FATOR"
	nPosTT		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D3A_TEMP"})
	nPosTA		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D3A_TEMPAM"})
	nPosDA		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D3A_DENSID"})
	cCOD		:= DH7->DH7_COD
	nTTANQUE 	:= Acols[N,nPosTT]
	nTAMOSTRA	:= Acols[N,nPosTA]
	nDAMOSTRA	:= Acols[N,nPosDA]
	nFATCO   	:= M->D3A_FATOR
ENDIF

IF READVAR() == "M->DH4_FATCOR"
	nPosCod	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
	cCOD		:= Acols[N,nPosCod]
	If !lMvc
		nPosTT		:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TMPTAQ"})
		nPosTA  	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TMPAMO"})
		nPosDA  	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_DENSID"})
		nPosFAT 	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_FATCOR"})
		
		nTTANQUE 	:= Acols[N,nPosTT]
		nTAMOSTRA	:= Acols[N,nPosTA]
		nDAMOSTRA	:= Acols[N,nPosDA]
		nFATCO   	:= Acols[N,nPosFAT]
	Else
		nTTANQUE 	:= oModDH4:GetValue("DH4_TMPTAQ")
		nTAMOSTRA	:= oModDH4:GetValue("DH4_TMPAMO")
		nDAMOSTRA	:= oModDH4:GetValue("DH4_DENSID")
		nFATCO   	:= oModDH4:GetValue("DH4_FATCOR")
	EndIf
ENDIF

IF READVAR() == "M->DH9_FATCOI"
	cCOD     	:= M->DH9_COD
	nTTANQUE 	:= M->DH9_TEMPTI
	nTAMOSTRA	:= M->DH9_TEMPI 
	nDAMOSTRA	:= M->DH9_DENSI 
	nFATCO   	:= M->DH9_FATCOI
ENDIF

IF READVAR() == "M->DH9_FATCOF"
    cCOD     := M->DH9_COD
	nTTANQUE := M->DH9_TEMPTF
	nTAMOSTRA:= M->DH9_TEMPF 
	nDAMOSTRA:= M->DH9_DENSF 
	nFATCO   := M->DH9_FATCOF
ENDIF

IF READVAR() == "M->DH7_FATCOR"
    cCOD     := M->DH7_COD
	nTTANQUE := M->DH7_TEMP  
	nTAMOSTRA:= M->DH7_AMTEMP 
	nDAMOSTRA:= M->DH7_AMDENS
	nFATCO   := M->DH7_FATCOR
ENDIF

IF !EMPTY(cCOD).AND.;
	nTTANQUE <> 0 .AND.;
	nTAMOSTRA <> 0 .AND.;
	nDAMOSTRA <> 0 .AND.;
	nFATCO <> 0
	SB1->(DBSEEK(XFILIAL() + cCOD))
    DBSELECTAREA("DHC")
	IF ! DHC->(DBSEEK(XFILIAL("DHC") + cCOD + STR(nTTANQUE,5,2) + STR(nTAMOSTRA,5,2) + STR(nDAMOSTRA,6,4)))
		cMens+=" Produto...............: " + SB1->B1_DESC + CHR(13) + CHR(13)
		cMens+=" Temperatura do Tanque.: " + STR(nTTANQUE,5,2) + CHR(13) + CHR(13)
		cMens+=" Temperatura da Amostra: " + STR(nTAMOSTRA,5,2) + CHR(13) + CHR(13)
		cMens+=" Densidade da Amostra..: " + STR(nDAMOSTRA,6,4) + CHR(13) + CHR(13)
		cMens+=" Fator de Correcao.....: " + STR(nFATCO,6,4) + CHR(13) + CHR(13)
		cMens+=" Inclui Fatores para Historico ? " + CHR(13)
		IF MsgYesNo(cMens,"Fatores")
			DBSELECTAREA("DHC")
			RECLOCK("DHC",.T.)
				DHC->DHC_FILIAL	:= xFilial("DHC")
				DHC->DHC_CODPRO	:= cCOD
				DHC->DHC_TEMPTQ	:= nTTANQUE
				DHC->DHC_TEMPAM	:= nTAMOSTRA
				DHC->DHC_AMBDEN	:= nDAMOSTRA
				DHC->DHC_FATCOR	:= nFATCO
			MSUNLOCK()
		ENDIF
	ENDIF
ENDIF
RestArea(aArea)
Return(nFATCO)

#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE007()
Carrega valores para itens da nota  fiscal atraves do mov. provisorio
Adaptação da função TDCEE007
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
@return nRet
/*/
//------------------------------------------------------------------- 
Function DCLEE007()   
Local aArea		:= GetArea()
Local nPosLocal  := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_LOCAL"})
Local nPosX_TQ   := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TANQ"})
Local nPosX_ENT  := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_DTENT"})
Local nPosT_TA   := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TMPAMO"})
Local nPosT_TT   := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TMPTAQ"})
Local nPosT_FATCO:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_FATCOR"})
Local nPosQTD20G := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_QTD20G"})
Local nPosT_DENSA:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_DENSID"})
Local nPosT_QTAMB:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_QTDAPU"})
Local nPosX_VIA  := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_TDCARG"})
Local nPosX_ATUTQ:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "DH4_ATUTNQ"})

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbSelectArea("SD3")
SD3->(DbSetOrder(16))
IF SD3->(DbSeek(xFilial() + M->DH4_DCPROV + "PR" + " "))
   Acols[N,nPosLocal]  := SD3->D3_LOCAL
   Acols[N,nPosX_TQ]   := SD3->D3_TANQUE
   Acols[N,nPosX_ENT]  := SD3->D3_EMISSAO
   Acols[N,nPosT_TA]   := SD3->D3_TEMPAMO
   Acols[N,nPosT_TT]   := SD3->D3_TEMPTAQ
   Acols[N,nPosT_FATCO]:= SD3->D3_FATCORR
   Acols[N,nPosQTD20G] := SD3->D3_QUANT
   Acols[N,nPosT_DENSA]:= SD3->D3_DENSA
   Acols[N,nPosT_QTAMB]:= SD3->D3_QTDAMB
   Acols[N,nPosX_VIA]  := "02"
   Acols[N,nPosX_ATUTQ]:= "S"
ENDIF
RestArea(aArea)
Return(M->DH4_DCPROV)


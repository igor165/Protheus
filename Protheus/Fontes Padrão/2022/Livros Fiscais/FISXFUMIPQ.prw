#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFUMIPQ
    (Componentização da função MaFisFMPEQ - 
    Fundo Municipal de Fomento à Micro e Pequena Empresa (Fumipeq)
    
	@author Rafael.soliveira
    @since 17/02/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction	
    /*/
Function FISXFUMIPQ(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
Local lTribGen 		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FUMIPQ)
Local nPosTgFUMI 	:= 0

If !lTribGen
    aNfItem[nItem][IT_VALFMP] := 0
    aNfItem[nItem][IT_BASEFMP]:= 0
    aNfItem[nItem][IT_ALQFMP] := aInfNat[25]
    
    IF ((aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_UFDEST] == "AM") .Or. aNfCab[NF_TIPONF]=="D") .And. aInfNat[24] == "1" .And. aNfItem[nItem][IT_ALQFMP] > 0
        aNfItem[nItem][IT_BASEFMP]:= aNfItem[nItem][IT_TOTAL]
        aNfItem[nItem][IT_VALFMP] := aNfItem[nItem][IT_BASEFMP] * (aNfItem[nItem][IT_ALQFMP]/100)
    EndIf
Else

    IF (nPosTgFUMI := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FUMIPQ})) >0  
    
        aNfItem[nItem][IT_VALFMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUMI][TG_IT_VALOR]
        aNfItem[nItem][IT_BASEFMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUMI][TG_IT_BASE]
        aNfItem[nItem][IT_ALQFMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUMI][TG_IT_ALIQUOTA]
    Endif
EndIf

Return

/*/{Protheus.doc} FMPQConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 24/11/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado	
ccampo -> Campo que esta sendo alterado	
/*/
Function FMPQConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VALFMP"
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo == "IT_BASEFMP"	
    cCampoConv := "TG_IT_BASE"				
Elseif cCampo == "IT_ALQFMP"
    cCampoConv := "TG_IT_ALIQUOTA"				
Endif

Return cCampoConv
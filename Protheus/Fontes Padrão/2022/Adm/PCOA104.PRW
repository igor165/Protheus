#Include 'Protheus.CH'
#Include "ApWizard.ch"        
#Include "PCOA104.ch"

Static __nDisPer := 0
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA104    บAutor  ณAlvaro Camillo Neto บ Data ณ  20/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para distribuir os valores nado                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA104(cPlan, cRev, cCta, aHeadAK2, aColsAK2)
Local aArea	   := GetArea()
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAKE := AKE->(GetArea())
Local aAreaAK5 := AK5->(GetArea())
Local oGetAMZ		:= Nil
Local aConfig 		:= {}
Local aPeriodos 	:= {} 
Local lRet := .T.

__nDisPer := 0

lRet := PCO104Wiz(cPlan,cRev,cCta,@aConfig,@aPeriodos,@oGetAMZ)
If lRet 
	PCO104Comp(aConfig,aPeriodos,oGetAMZ, @aHeadAK2, @aColsAK2)
EndIf

RestArea(aAreaAK5)
RestArea(aAreaAKE)
RestArea(aAreaAK3)
RestArea(aAreaAK2)
RestArea(aAreaAK1)
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104CompบAutor  ณAlvaro Camillo Neto บ Data ณ  10/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104Comp(aConfig,aPeriodos,oGetAMZ, aHeadAK2, aColsAK2)
Local lRet 		:= .T.
Local nX 		:= 0
Local nY		:= 0
Local aColsAMZ  := oGetAMZ:aCols
Local aHeadAMZ  := oGetAMZ:aHeader                   
Local nCols		:= 0
Local nAMZCC	:= aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_CC"})
Local nAMZItCtb := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ITCTB"})
Local nAMZClvCtb:= aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_CLVLR"})
Local nAMZClasse:= aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_CLASSE"})
Local nAMZOper  := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_OPER"})
Local nAMZChave := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_CHAVE"})
Local nAMZPerc  := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_PERC"})
Local nAMZUniOrc:= aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_UNIORC"})
Local nAMZEnt05 := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ENT05" })
Local nAMZEnt06 := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ENT06" })
Local nAMZEnt07 := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ENT07" })
Local nAMZEnt08 := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ENT08" })
Local nAMZEnt09 := aScan(aHeadAMZ,{|x| Alltrim(x[2]) == "AMZ_ENT09" })
Local nPercDist := aConfig[3] / 100                                       
Local nValorDist:= aConfig[2] * nPercDist 
Local cIdent	:= ""
Local cUnidMed	:= ""
Local nPosPer	:= 0
Local nValor	:= 0 

aColsAK2 := {}

For nX := 1 to Len(aColsAMZ)
	nCols++
	aAdd( aColsAK2 , Array(Len(aHeadAK2) + 1 ) )
	
	If !Empty( aColsAMZ[nX][nAMZClasse] ) .And. AK6->(MsSeek( xFilial("AK6") + aColsAMZ[nX][nAMZClasse] ) ) .And. !Empty(aColsAMZ[nX][nAMZChave])
		dbSelectArea(Substr(aColsAMZ[nX][nAMZChave],1,3))
		dbSetOrder(If(!Empty(Substr(aColsAMZ[nX][nAMZChave] ,4,2)), Val(Substr(	aColsAMZ[nX][nAMZChave],4,2)), 1))
		dbSeek(Substr(	aColsAMZ[nX][nAMZChave],6,Len(	aColsAMZ[nX][nAMZChave] )))
		
		If !Empty(AK6->AK6_VISUAL)
			cIdent:= &(AK6->AK6_VISUAL)
		EndIf
		
	EndIf

	AK6->(DbSetOrder(1))
	AK6->(MsSeek( xFilial("AK6") + aColsAMZ[nX][nAMZClasse] ))
	If !Empty(AllTrim(AK6->AK6_UM))
		cUnidMed :=  &(AK6->AK6_UM)
	EndIf
	
	aColsAK2[nCols][Len(aHeadAK2)+1] := .F.
	
	For nY := 1 to Len(aHeadAK2)
		
		aColsAK2[nCols][nY] := CriaVar(aHeadAK2[nY][2])
				
		If Alltrim(aHeadAK2[nY][2]) == "AK2_CC"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZCC]	
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ID"
			aColsAK2[nCols][nY] := "*"
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ITCTB"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZItCtb]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_CLVLR"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZClvCtb] 
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_CLASSE"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZClasse]  
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_DESCLA"
			aColsAK2[nCols][nY] := AK6->AK6_DESCRI 
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_OPER"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZOper]  
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_IDENT"
			aColsAK2[nCols][nY] := cIdent
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_UM"
			aColsAK2[nCols][nY] := cUnidMed 
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_CHAVE"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZChave] 
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_MOEDA" 
        	aColsAK2[nCols][nY] := CriaVar("AK2_MOEDA")
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_UNIORC"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZUniOrc]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ENT05"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZEnt05]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ENT06"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZEnt06]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ENT07"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZEnt07]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ENT08"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZEnt08]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_ENT09"
			aColsAK2[nCols][nY] := aColsAMZ[nX][nAMZEnt09]
		ElseIf Alltrim(aHeadAK2[nY][2]) == "AK2_VAL"
			nPosPer := aScan(aPeriodos, {|x| Alltrim(x[1]) == Alltrim(aHeadAK2[nY][1]) })
			If nPosPer > 0
				nValor	:= nValorDist * ( aColsAMZ[nX][nAMZPerc] / 100 )
				nValor  := nValor * ( aPeriodos[nPosPer][2] / 100 )
				aColsAK2[nCols][nY] := PcoPlanCel(nValor, aColsAMZ[nX][nAMZClasse])  
			EndIf 
		EndIf  
	Next nY
Next nX

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104Wiz บAutor  ณAlvaro Camillo Neto บ Data ณ  21/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard para op็๕es da distribui็ใo de valores               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104Wiz(cPlan,cRev,cCta,aRetConfig,aPeriodos,oGetAMZ)
Local oWizard 		:= Nil
Local lConfirma		:= .F.
Local aRetPeriod	:= {} 
Local aPerPeriod	:= {}

AK1->(dbSetOrder(1)) //AK1_FILIAL+AK1_CODIGO+AK1_VERSAO
AK5->(dbSetOrder(1)) //AK5_FILIAL+AK5_CODIGO
If FunName()!= "PCOA120"  //revisao da planilha nใo pode posicionar pois ainda nao existe AK1 p versao em revisao
	AK1->(MsSeek(xFilial("AK1") + cPlan + cRev  ))
EndIf	
AK5->(MsSeek(xFilial("AK5") + cCta ))


DEFINE WIZARD oWizard TITLE STR0001 ;//"Distribu็ใo de valores por entidade "
       HEADER STR0001;//"Distribu็ใo de valores por entidade"  	
       MESSAGE STR0002 ;//"Este assistente lhe ajudarแ gerar as linhas do or็amento das entidades baseado em uma regra de distribui็ใo pr้-cadastrada "
       TEXT STR0003 +; //"Voce devera escolher a regra de distribui็ใo e o valor a distribuir e ao finalizar o assistente, este valor serแ rateado conforme os parametros solicitados."
									CRLF+CRLF+ STR0004 +Alltrim(AK1->AK1_CODIGO)+" - "+PadR(AK1->AK1_DESCRI,50)+; //"Planilha : "
									CRLF+CRLF+ STR0005 +Alltrim(AK5->AK5_CODIGO)+" - "+PadR(AK5->AK5_DESCRI,50) ; //"Conta : "
       NEXT {||.T.} ;
       FINISH {|| .T. } ; 
       PANEL

   CREATE PANEL oWizard ;
          HEADER STR0006  ; //"Configura็ใo da regra de distribui็ใo "
          MESSAGE ;
          BACK {|| .T. } ;
          NEXT {|| PCO104VCFG(aRetConfig) } ; 
          EXEC {|| PCO104MCFG(oWizard:GetPanel(oWizard:nPanel),@aRetConfig) } ;
          PANEL
          
   CREATE PANEL oWizard ;
          HEADER STR0007  ; //"Regra de Distribui็ใo "
          MESSAGE ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ; 
          EXEC {|| PCO104MReg(oWizard:GetPanel(oWizard:nPanel), @oGetAMZ , aRetConfig[1] ) } ;
          PANEL
          
   CREATE PANEL oWizard ;
          HEADER STR0008  ; //"Percentuais para os periodos "
          MESSAGE ;
          BACK {|| .T. } ;
          NEXT {|| PCO104VPer(aRetConfig[4],aRetPeriod) } ; 
          EXEC {|| PCO104MPer(oWizard:GetPanel(oWizard:nPanel),aRetConfig[4],@aPerPeriod,@aRetPeriod,cPlan,cRev ) } ;
          PANEL

   CREATE PANEL oWizard ;
          HEADER STR0009 ; //"Confirma็ใo " 
          MESSAGE STR0010 ;//"Confirma a distribui็ใo do valor nas entidades selecionadas? "
          BACK {|| .T. } ; 
          FINISH {|| lConfirma := .T., .T. } ;
          EXEC {|| aPeriodos := PCO104FWiz(aPerPeriod,aRetPeriod) } ;
          PANEL

ACTIVATE WIZARD oWizard CENTERED


Return lConfirma  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA104   บAutor  ณMicrosiga           บ Data ณ  10/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104FWiz(aPerPeriod,aRetPeriod) 
Local aPeriodos := {}
Local nX		:= 0

For nX :=1 to Len(aPerPeriod)
	aAdd(aPeriodos,{aPerPeriod[nX][2],aRetPeriod[nX]})
Next nX

Return aPeriodos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104MCFGบAutor ณAlvaro Camillo Neto บ Data ณ  21/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Painel das configura็๕es da distribui็ใo          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104MCFG(oPanel,aRetConfig)
Local aPerConfig := {}

aAdd(aPerConfig,{ 1,    STR0011 ,CriaVar("AMW_CODIGO"), "@!","","AMW","",50,.T.})//"Regra Distribuicao" 
aAdd(aPerConfig,{ 1,    STR0012,CriaVar("AK2_VALOR"), PesqPict("AK2","AK2_VALOR"),"","","",100,.T.}) //"Valor"
aAdd(aPerConfig,{ 1,    STR0013,0, "@E 999.9999 %" ,"","","",65,.T.}) //"Percentual a Distribuir"
aAdd(aPerConfig,{ 3,    STR0014 ,1, {STR0015,STR0016 } ,65,"",.T.,""}) //"Distribui็ใo no Periodo"##"Replicar"##"Dividir"
If Len(aRetConfig) == 0
	aRetConfig  := {CriaVar("AMW_CODIGO"),0,100,1}
EndIf
ParamBox(aPerConfig,STR0017, @aRetConfig,,,,,,oPanel)//"Configura็๕es" 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104VCFGบAutor ณAlvaro Camillo Neto บ Data ณ  21/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o painel de configura็ใo da distribui็ใo            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104VCFG(aRetConfig)
Local lRet 	:= .T.
Local nX	:= 0

If lRet
	For nX := 1 to Len(aRetConfig)
		If Empty(aRetConfig[nX]) 
			HELP("  ",1,"OBRIGAT")
			lRet := .F.
			Exit
		EndIf
	Next nX
EndIf

If lRet
	lRet := ExistCpo("AMW",aRetConfig[1])
EndIf

If lRet
	If aRetConfig[2] < 0
    	HELP("   ",1,"P104VLINV",,STR0018,3,0)//"Valor a distribuir Invแlido"
    	lRet := .F.
	EndIf 
EndIf

If lRet
	If aRetConfig[3] < 0 .Or. aRetConfig[3] > 100 
    	HELP("   ",1,"P104PERCINV",,STR0019,3,0)//"Percentual a distribuir Invแlido"
    	lRet := .F.
	EndIf 
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104MRegบAutor  ณAlvaro Camillo Neto บ Data ณ  21/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Painel das regra de distribui็ใo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104MReg(oPanel, oGetAMZ , cRegraDist )
Local aCpos := {}
Local aCols := {}

aCpos := {"AMZ_ITEM","AMZ_CLASSE","AMZ_OPER","AMZ_CC","AMZ_ITCTB","AMZ_CLVLR","AMZ_IDENT","AMZ_CHAVE","AMZ_UM","AMZ_PERC"}  

PCOPrepList (@aCpos)
PCOVrfUNIORC(@aCpos)  

aHeader := GetaHeader("AMZ",aCpos)
aCols	:= CriaAcols(aHeader,cRegraDist) 

oGetAMZ	:= MsNewGetDados():New(0,0,90,305,0,"", ,"",,,,,,,oPanel,aHeader,aCols) 
oGetAMZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  PCOPrepList       |                       ณ Data ณ11/11/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMonta Lista de nomes de campos das entidades novas          ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function PCOPrepList(aEntids)                                                        
Local nCont                                                                                     
Local cCampo
Local aAreaAMZ		:= GetArea()
Static nQtdEntid:= Nil

If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf           

for nCont := 5 to  nQtdEntid
	if nCont < 10
		cCampo := "AMZ_ENT0" + AllTrim(STR(nCont))
	else
		cCampo := "AMZ_ENT"  + AllTrim(STR(nCont))
	EndIf
        
	aadd (aEntids, cCampo)     
next                 

RestArea(aAreaAMZ)
return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOVrfUNIORC ณ                                ณ Data ณ02/11/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณVerifica habilita็ใo de acesso do usuแrio a UNIDADE ORวAMENTมRIA ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PCOVrfUNIORC(aEntids)
Local aAreaAMZ		:= GetArea()
Local cUnidOrc := ''
                
dbSelectArea("AMZ")
dbSetOrder(1)                        

aadd (aEntids, "AMZ_UNIORC")     

AMZ->(dbCLoseArea())

RestArea(aAreaAMZ)
Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO104MPerบAutor  ณAlvaro Camillo Neto บ Data ณ  21/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o Painel da distribui็ใo dos periodos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104MPer(oPanel,nOpcPer,aPerPeriod,aRetPeriod,cPlan,cRev)
Local aPeriodos := {}
Local nX		:= 0 
Local nPerc		:= 0
Local nPercSoma	:= 0
Local nLenPer   := 0

AK1->(dbSetOrder(1)) //AK1_FILIAL+AK1_CODIGO+AK1_VERSAO
AK5->(dbSetOrder(1)) //AK5_FILIAL+AK5_CODIGO
If FunName() != "PCOA120"  //revisao da planilha nao existe ainda ak1 para a versao em revisao
	AK1->(MsSeek(xFilial("AK1") + cPlan + cRev  ))
EndIf
aPeriodos := PcoRetPer()
nLenPer := Len(aPeriodos)

If __nDisPer != nOpcPer
	aRetPeriod := Array(nLenPer)
	__nDisPer  := nOpcPer
EndIf

aPerPeriod :=  {}

For nX := 1 to nLenPer

	aAdd(aPerPeriod,{ 1, aPeriodos[nX] ,0, "@E 999.9999 %" ,"","",IIF(nOpcPer == 1, ".F." , ".T." ),65,.T.})
	If nOpcPer == 1
		nPerc := 100
	Else
		If nX == Len(aPeriodos)
			nPerc := 100 - nPercSoma
		Else
			nPerc := 100 / nLenPer
			nPercSoma += nPerc 
		EndIf 
	EndIf
	 
	aRetPeriod[nX] := nPerc
	 
Next nX 

ParamBox(aPerPeriod,STR0020, @aRetPeriod,,,,,,oPanel)//"Periodos"
 
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA104   บAutor  ณMicrosiga           บ Data ณ  10/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO104VPer(nOpcPer,aRetPeriod)
Local lRet := .T.
Local nX   := 0
Local nSoma:=0

If nOpcPer == 2
	For nX := 1 to Len(aRetPeriod)
   		nSoma += aRetPeriod[nX]
	Next nX
	
	If nSoma != 100 
	    HELP("   ",1,"P104PERIINV",,STR0021,3,0)//"Percentual distribuido nos perํodos invแlido"
		lRet := .F.
	EndIf 
	
EndIf  


Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cRegraDist)
Local nX			:= 0
Local nCols		    := 0
Local nPosChave		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CHAVE" })
Local nPosClass		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLASSE" })
Local nPosIdent		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_IDENT" })
Local nPosUM		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UM" }) 
Local aCols			:= {}
Local aArea			:= GetArea()
Local aAreaAMZ		:= AMZ->(GetArea())

AMZ->(dbSetOrder(1)) // AMZ_FILIAL+AMZ_CODIGO+AMZ_ITEM
AMZ->(dbSeek(xFilial("AMZ") + cRegraDist))
AK6->(dbSetOrder(1)) //AK6_FILIAL+AK6_CODIGO+AK6_DESCRI
 
While AMZ->(!Eof()) .And. AMZ->(AMZ_FILIAL+AMZ_CODIGO) == xFilial("AMZ") + cRegraDist
	aAdd(aCols,Array(Len(aHeader)+1))
	nCols ++
	For nX := 1 To Len(aHeader)
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := AMZ->(FieldGet(FieldPos(aHeader[nX][2])))
		ElseIf (aHeader[nX][8] == "M") // Campo Memo
			aCols[nCols][nX] := MSMM(AMZ->(&(cCPOMemo)), TamSX3(cMemo)[1] )
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	
	If !Empty( aCols[nCols][nPosClass] ) .And. !Empty(aCols[nCols][nPosChave]) .And. AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] ) )
		dbSelectArea(Substr(aCols[nCols][nPosChave],1,3))
		dbSetOrder(If(!Empty(Substr(aCols[nCols][nPosChave] ,4,2)), Val(Substr(	aCols[nCols][nPosChave],4,2)), 1))
		dbSeek(Substr(	aCols[nCols][nPosChave],6,Len(	aCols[nCols][nPosChave] )))
		
		If !Empty(AK6->AK6_VISUAL)
			aCols[nCols][nPosIdent] := &(AK6->AK6_VISUAL)
		EndIf
		
	EndIf
	aCols[nCols][Len(aHeader)+1] := .F.
    
	AK6->(DbSetOrder(1))
	AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] ) )
	If !Empty(AllTrim(AK6->AK6_UM))
		aCols[nCols][nPosUM] :=  &(AK6->AK6_UM)
	EndIf

	AMZ->(dbSkip())
End

RestArea(aAreaAMZ)
RestArea(aArea)
Return(aCols)




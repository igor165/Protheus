#include "TOTVS.CH"
#include "PROTHEUS.CH" 
#include "FINA085A.CH"
#include "FWBROWSE.CH"

//Posicoes do Array ASE2
#DEFINE _FORNECE  1
#DEFINE _LOJA     2
#DEFINE _VALOR    3
#DEFINE _MOEDA    4
#DEFINE _SALDO    5
#DEFINE _SALDO1   6           
#DEFINE _EMISSAO  7
#DEFINE _VENCTO   8
#DEFINE _PREFIXO  9
#DEFINE _NUM     10                        
#DEFINE _PARCELA 11 
#DEFINE _TIPO    12
#DEFINE _RECNO   13
#DEFINE _RETIVA  14
#DEFINE _RETIB   15
#DEFINE _NOME    16
#DEFINE _JUROS   17
#DEFINE _DESCONT 18
#DEFINE _NATUREZ 19
#DEFINE _ABATIM  20
#DEFINE _PAGAR   21
#DEFINE _MULTA   22
#DEFINE _RETIRIC 23 
#DEFINE _RETSUSS 24
#DEFINE _RETSLI  25
#DEFINE _RETIR   26 
#DEFINE _RETIRC  27 //Portugal
#DEFINE _RETISI  28
#DEFINE _RETRIE  29 //Angola
#DEFINE _RETIGV  30 //PERU
#DEFINE _CBU     31 //Controle de CBU - Argentina  
#DEFINE _NRCHQ   32 //EQUADOR

#DEFINE _ELEMEN  32 //indica o tamanho para o array ase2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850  บAutor  ณMicrosiga           บ Data ณ  10/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฬฑฑ
ฑฑบPROGRAMADOR ณ DATA   ณ BOPS   ณ  MOTIVO DA ALTERACAO                   บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฬฑฑ
ฑฑบLaura Medinaณ03/03/17ณMMI-4166ณSe inicializa de forma correcta el valorบฑฑ
ฑฑบ            ณ        ณ        ณde la variable cAliasSE2, cuando se     บฑฑ
ฑฑบ            ณ        ณ        ณgenera una orden de pago a partir de unaบฑฑ
ฑฑบ            ณ        ณ        ณpre-orden.                              บฑฑ
ฑฑบRaul Ortiz  ณ28/03/17|MMI-4546ณSe considera el calculo IVA correcta-   บฑฑ
ฑฑบ            ณ        ณ        ณmente para acumulados                   บฑฑ
ฑฑบLaura Medinaณ15/06/17ณMMI-5343ณSe inicializa de forma correcta el tama-บฑฑ
ฑฑบ            ณ        ณ        ณ๑o de un arreglo, se agrega validaci๓n  บฑฑ
ฑฑบ            ณ        ณ        ณpara % en calculo de Ret. IVA           บฑฑ
ฑฑศออออออออออออฯออออออออฯออออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AcmIVA(cTpAcm,dDtRef,cFornece,cLoja,cFilOr,cCFO,cCFOV)
Local aAreaSE2	:= {}
Local dDataIni	:=	""
Local dDataFim	:= 	""
Local cChaveSFE 	:= ""
Local cAliasSE2	:= ""
Local cMrkSE2		:= ""		
Local cDoc 		:= ""
Local lEmpty		:= .F.
Local lValid		:= .F.
Local lRegSel		:= .F.
Local nValImp 	:= 0
Local nValRet		:= 0
Local nTotal		:= 0
Local nTotOP		:= 0 
Local nPosDoc		:= 0
Local nPosSE2		:= 0
Local nParc		:= 0
Local aRet			:= Array(5)
Local aDados 		:= {} 
Local aParcelas	:= {}
Local cQuery	:=	""
Local cAlias	:=	""
Local nPosPar	:= 0
Local lRetTotal := .F.

DEFAULT cTpAcm		:= 0
DEFAULT dDtRef 		:= dDataBase 
DEFAULT cFornece		:= ""
DEFAULT cLoja    		:= ""
DEFAULT cFilOr		:= ""
DEFAULT cCFO 			:= ""
DEFAULT cCFOV 			:= ""

If cTpAcm == "1" //Acumulo anual
	dDataIni := Ctod("01/01/"+Str(Year(dDtRef),4))	
	dDataFim := Ctod("31/12/"+Str(Year(dDtRef),4))	
ElseIf cTpAcm == "2" //Acumulo mensal
	dDataIni := FirstDay(dDtRef)
	dDataFim := LastDay(dDtRef)
Else 
	dDataIni := dDtRef
	dDataFim := dDtRef
Endif                          

//Atribui o alias e as respectivas marcas para valida็ใo dos tํtulos em sele็ใo
Do Case
	Case FunName() == "FINA855"
		cAliasSE2 	:= "FA855SE2"
		cMrkSE2 	:= cMarca
	Case FunName() == "FINR851"
		cAliasSE2 	:= "SE2"
	Case FunName() == "FINA850" .And. Type("lShowPOrd") <> "U" .And. lShowPOrd
		cAliasSE2 	:= cAliasPOP
		cMrkSE2 	:= cMarcaE2
	Case Type("cAliasTmp") <> "U"
		cAliasSE2 	:= cAliasTmp
		cMrkSE2 	:= cMarcaE2	
EndCase

dbSelectArea(cAliasSE2)
aAreaSE2 := (cAliasSE2)->(GetArea())

   		//Somar acumulado                                 
		cQuery	:=	" SELECT D1_TOTAL, F1_DOC, F1_SERIE, F1_MOEDA, "
		If cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
			cQuery	+=	" F1_ORDPAGO, "	
		EndIf
		cQuery 	+=  " SE2.R_E_C_N_O_ E2_RECNO, " 
		cQuery 	+=  " SF1.R_E_C_N_O_ F1_RECNO" 
		cQuery 	+=  " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1, "+RetSqlName("SE2")+" SE2 "
		cQuery	+=	" WHERE "
		If !lMsFil
			cQuery	+=	" D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery	+=	" F1_FILIAL = '"+xFilial("SF1")+"' AND "
			cQuery	+=	" E2_FILIAL = '"+xFilial("SE2")+"' AND "
		Else                           
			cQuery	+= " F1_FILIAL = D1_FILIAL AND "  
			//Ajuste para a diferen็a de compartilhamento
			If !Empty(xFilial("SE2")) .And. !Empty(xFilial("SF1"))
				cQuery	+=	" F1_FILIAL = E2_FILIAL AND "
			EndIf           
		Endif
		cQuery	+=	" D1_FORNECE 	= '"+cFornece+ "' AND "
		cQuery	+=	" D1_LOJA	 	= '"+cLoja+ "' AND "
		If !Empty(cCFO)
			cQuery +=	" D1_CF 		= '"+cCFO+ "' AND "
		EndIf
		cQuery	+=	" F1_SERIE 	= D1_SERIE AND " 
		cQuery	+=	" F1_DOC 		= D1_DOC AND " 
		cQuery	+=	" F1_ESPECIE 	= D1_ESPECIE AND " 
		cQuery	+=	" F1_LOJA 		= D1_LOJA AND " 
		cQuery	+=	" F1_FORNECE	= D1_FORNECE AND "		
		cQuery	+=	" "+SerieNFID("SF1",3,"F1_SERIE")+" = E2_PREFIXO AND "
		cQuery	+=	" F1_DOC 		= E2_NUM AND " 
		cQuery	+=	" F1_ESPECIE 	= E2_TIPO AND " 
		cQuery	+=	" F1_LOJA 		= E2_LOJA AND " 
		cQuery	+=	" F1_FORNECE	= E2_FORNECE AND "   
		   
		cQuery	+=	" D1_TIPO IN ('C','N') AND "
		
		cQuery	+=	" F1_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' AND "
		
		cQuery	+=	" SE2.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SF1.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SD1.D_E_L_E_T_ = '' "
		
		cQuery 	:= 	ChangeQuery(cQuery)                    
		cAlias		:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
		//Processa o arquivo para valida็ใo das parcelas
		(cAlias)->(dbGoTop())
		While !(cAlias)->(Eof())
			nPosDoc := aScan(aParcelas,{|x| x[1] == (cAlias)->F1_RECNO})	
			If nPosDoc == 0
				aAdd(aParcelas,{(cAlias)->F1_RECNO,{(cAlias)->E2_RECNO},.F.})
			Else
				nPosPar := aScan(aParcelas[nPosDoc][2],{|x| x == (cAlias)->E2_RECNO})
				If nPosPar == 0
					aAdd(aParcelas[nPosDoc][2],(cAlias)->E2_RECNO)
				EndIf
			EndIf
			(cAlias)->(dbSkip())
		EndDo
		
		//Calcula os valores
		(cAlias)->(dbGoTop())
		While !(cAlias)->(Eof())
		    
    		nPosDoc := aScan(aParcelas,{|x| x[1] == (cAlias)->F1_RECNO})
		 	If nPosDoc > 0
		 		nParc := Len(aParcelas[nPosDoc][2])	
		 	Else
		 		nParc := 1
		 	EndIf	
		    
		    nTotal += xMoeda((cAlias)->D1_TOTAL,(cAlias)->F1_MOEDA,1,dDataBase)/nParc
			
			If cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
				If !Empty((cAlias)->F1_ORDPAGO)
					cDoc := (cAlias)->F1_DOC+(cAlias)->F1_SERIE    
				 
					//Valida se nใo foi reten็ใo parcial
					SFE->(dbSetOrder(4))
					If SFE->(MsSeek(xFilial("SFE")+cFornece+cLoja+cDoc+"I"))
				  	   	cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
						While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
							If SFE->FE_TIPO =="I" .and. SFE->FE_RETENC > 0
								nValImp := SFE->FE_VALIMP
								nValRet += SFE->FE_RETENC 
							EndIf
							SFE->(dbSkip())
						EndDo
						
						If nValImp == nValRet
				   			nTotOP += xMoeda((cAlias)->D1_TOTAL,(cAlias)->F1_MOEDA,1,dDataBase)/nParc
				   			lEmpty := .F. //Nใo zero o numero da OP nos casos de baixas totais
							lRetTotal := .T.
				  		Else
				  			lEmpty := .T. //Zero o numero da OP nos casos de baixas parciais
				  			lValid := .T. //Recalcula os impostos para o saldo nas baixas parciais
				  		EndIf 
				  	   
				  		nValImp := 0
						nValRet := 0 		
					Else     
						nTotOP += xMoeda((cAlias)->D1_TOTAL,(cAlias)->F1_MOEDA,1,dDataBase)/nParc	
					EndIf  
				Else
					lValid := .T.	
				EndIf
			EndIf
			//aDados - Dados adicionais do cแlculo de cumulatividade
			//1 = Selecionado na OP - .T. ou .F.
			//2 = Retido em alguma OP - campo F1_ORDPAGO
			//3 = Recno da nota (SF1) - para grava็ใo do nบ da OP para reten็ใo acumulada

			If FunName() == "FINR851" .And. Type("aRecnoSE2") <> "U"
				nPosSE2 := aScan(aRecnoSE2,{|x| x[8] == (cAlias)->E2_RECNO})
				If nPosSE2 > 0
					lRegSel := .T.
				Else
					lRegSel := .F.		
				EndIf
			ElseIf FunName() == "FINA850" .And. Type("lShowPOrd") <> "U" .And. lShowPOrd
				lRegSel := .T.
			Else
				dbSelectArea(cAliasSE2)
				(cAliasSE2)->(dbGoTop())
				
				While !(cAliasSE2)->(Eof())	
					//Valida si es calculo acumulado de iva limpieza y viene de ordenes previas.
					If FunName() == "FINA847" .And. MV_PAR05 == 2 .And. cTpAcm == "2" .And. cPaisLoc == "ARG"
						lRegSel := .F.
						Exit
					EndIf

					//Valida si viene de ordenes de pago y si se esta mostrando porr ordenes previas.
					If FunName() == "FINA847" .And. MV_PAR05 == 2
						lRegSel := .T.
						Exit
					Else
						If (cAliasSE2)->E2_RECNO == (cAlias)->E2_RECNO
							If (cAliasSE2)->E2_OK == cMrkSE2
								lRegSel := .T.
							Else
								lRegSel := .F.
							EndIf
							Exit
						EndIf
					EndIf
					(cAliasSE2)->(dbSkip())
				EndDo
			EndIf
			
			aAdd(aDados,{lRegSel,If(lEmpty,"",(cAlias)->F1_ORDPAGO),(cAlias)->F1_RECNO,"SF1",(cAlias)->E2_RECNO,(100/nParc), !lRetTotal .And. Alltrim((cAlias)->F1_ORDPAGO) != "" })
			lRegSel := .F.
			lEmpty  := .F.
			lRetTotal := .F.
			(cAlias)->(DbSkip())
		EndDo 
		
		(cAlias)->(DbCloseArea())
	
		cQuery	:=	" SELECT D2_TOTAL, F2_MOEDA, F2_DOC, F2_SERIE, "
		cQuery	+=	" F2_ORDPAGO, "	
		cQuery 	+=  " SE2.R_E_C_N_O_ E2_RECNO, " 
		cQuery 	+=  " SF2.R_E_C_N_O_ F2_RECNO" 
		cQuery 	+=  " FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SE2")+" SE2 "
		cQuery	+=	" WHERE "
		If !lMsFil
			cQuery	+=	" D2_FILIAL = '"+xFilial("SD2")+"' AND "
			cQuery	+=	" F2_FILIAL = '"+xFilial("SF2")+"' AND "
			cQuery	+=	" E2_FILIAL = '"+xFilial("SE2")+"' AND "
		Else                           
			cQuery	+= " F2_FILIAL = D2_FILIAL AND " 
			//Ajuste da diferen็a de compartilhamento
			If !Empty(xFilial("SE2")) .And. !Empty(xFilial("SF2"))
				cQuery	+=	" F2_FILIAL	= E2_FILIAL AND "
			EndIf          
		Endif
		cQuery	+=	" D2_CLIENTE 	= '"+cFornece+ "' AND "
		cQuery	+=	" D2_LOJA	 	= '"+cLoja+ "' AND "
		If cPaisLoc <> "ARG" .and. !Empty(cCFO)
			cQuery +=	" D2_CF 		= '"+cCFO+ "' AND "
		ElseIF cPaisLoc == "ARG" .and. !Empty(cCFOV)
			cQuery +=	" D2_CF 		= '"+cCFOV+ "' AND "
		EndIf
		cQuery	+=	" F2_SERIE 	= D2_SERIE AND " 
		cQuery	+=	" F2_DOC 		= D2_DOC AND " 
		cQuery	+=	" F2_ESPECIE 	= D2_ESPECIE AND " 
		cQuery	+=	" F2_LOJA 		= D2_LOJA AND " 
		cQuery	+=	" F2_CLIENTE	= D2_CLIENTE AND "
		cQuery	+=	" "+SerieNFID("SF2",3,"F2_SERIE")+" = E2_PREFIXO AND "
		cQuery	+=	" F2_DOC 		= E2_NUM AND " 
		cQuery	+=	" F2_ESPECIE 	= E2_TIPO AND " 
		cQuery	+=	" F2_LOJA 		= E2_LOJA AND "
		cQuery	+=	" F2_CLIENTE	= E2_FORNECE AND " 
		   
		cQuery	+=	" D2_TIPO IN ('D','N') AND "
		
		cQuery	+=	" F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' AND "
		
		cQuery	+=	" SE2.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SF2.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SD2.D_E_L_E_T_ = '' "
		
		cQuery 	:= 	ChangeQuery(cQuery)                    
		cAlias	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
		aParcelas := {}
		
		//Processa o arquivo para valida็ใo das parcelas
		(cAlias)->(dbGoTop())
		While !(cAlias)->(Eof())
			nPosDoc := aScan(aParcelas,{|x| x[1] == (cAlias)->F2_RECNO})	
			If nPosDoc == 0
				aAdd(aParcelas,{(cAlias)->F2_RECNO,{(cAlias)->E2_RECNO}})
			Else
				nPosPar := aScan(aParcelas[nPosDoc][2],{|x| x == (cAlias)->E2_RECNO})
				If nPosPar == 0
					aAdd(aParcelas[nPosDoc][2],(cAlias)->E2_RECNO)
				EndIf	
			EndIf
			(cAlias)->(dbSkip())
		EndDo
		
		//Calcula os valores
		(cAlias)->(dbGoTop())
		While !(cAlias)->(Eof())
		    
    		nPosDoc := aScan(aParcelas,{|x| x[1] == (cAlias)->F2_RECNO})
		 	If nPosDoc > 0
		 		nParc := Len(aParcelas[nPosDoc][2])	
		 	Else
		 		nParc := 1
		 	EndIf	
		    
		    nTotal -= xMoeda((cAlias)->D2_TOTAL,(cAlias)->F2_MOEDA,1,dDataBase)/nParc
			
			If !Empty((cAlias)->F2_ORDPAGO)
				cDoc := (cAlias)->F2_DOC+(cAlias)->F2_SERIE    
				//Valida se nใo foi reten็ใo parcial
				SFE->(dbSetOrder(4))
				If SFE->(MsSeek(xFilial("SFE")+cFornece+cLoja+cDoc+"I"))
			  	   	cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
					While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
						If SFE->FE_TIPO =="I" .and. SFE->FE_RETENC < 0
							nValImp := SFE->FE_VALIMP
							nValRet += SFE->FE_RETENC 
						EndIf
						SFE->(dbSkip())
					EndDo
					
					If nValImp == nValRet
			   			nTotOP -= xMoeda((cAlias)->D2_TOTAL,(cAlias)->F2_MOEDA,1,dDataBase)/nParc
			   			lEmpty := .F. //Nใo zero o numero da OP nos casos de baixas totais
						lRetTotal := .T.
			  		Else
			  			lEmpty := .T. //Zero o numero da OP nos casos de baixas parciais
			  			lValid := .T. //Recalcula os impostos para o saldo nas baixas parciais
			  		EndIf 
			  	   
			  		nValImp := 0
					nValRet := 0 		 		
				Else     
					nTotOP -= xMoeda((cAlias)->D2_TOTAL,(cAlias)->F2_MOEDA,1,dDataBase)/nParc	
				EndIf  
			Else
				lValid := .T.
			EndIf
			
			//aDados - Dados adicionais do cแlculo de cumulatividade
			//1 = Selecionado na OP - .T. ou .F.
			//2 = Retido em alguma OP - campo F1_ORDPAGO
			//3 = Recno da nota (SF1) - para grava็ใo do nบ da OP para reten็ใo acumulada
			
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbGoTop())
			
			If FunName() == "FINR851" .And. Type("aRecnoSE2") <> "U"
				nPosSE2 := aScan(aRecnoSE2,{|x| x[8] == (cAlias)->E2_RECNO})
				If nPosSE2 > 0
					lRegSel := .T.
				Else
					lRegSel := .F.		
				EndIf
			ElseIf FunName() == "FINA850" .And. Type("lShowPOrd") <> "U" .And. lShowPOrd
				lRegSel := .T.
			Else	
				While !(cAliasSE2)->(Eof()) 
				
					//Valida si es calculo acumulado de iva limpieza y viene de ordenes previas.
					If FunName() == "FINA847" .And. MV_PAR05 == 2 .And. cTpAcm == "2" .And. cPaisLoc == "ARG"
						lRegSel := .F.
						Exit
					EndIf

					//Valida si viene de ordenes de pago y si se esta mostrando porr ordenes previas.
					If FunName() == "FINA847" .And. MV_PAR05 == 2							
						lRegSel := .T.
						Exit
					Else
						If (cAliasSE2)->E2_RECNO == (cAlias)->E2_RECNO
							If (cAliasSE2)->E2_OK == cMrkSE2
								lRegSel := .T.
							Else
								lRegSel := .F.
							EndIf
							Exit
						EndIf
					EndIf
					(cAliasSE2)->(dbSkip())
				EndDo
			EndIf
			aAdd(aDados,{lRegSel,Iif(lEmpty,"",(cAlias)->F2_ORDPAGO),(cAlias)->F2_RECNO,"SF2",(cAlias)->E2_RECNO,(100/nParc), !lRetTotal .And. Alltrim((cAlias)->F2_ORDPAGO) != "" })
			lRegSel := .F.
			lEmpty  := .F.
			lRetTotal := .F.
			(cAlias)->(DbSkip())
		EndDo 
		
		aRet[1] := nTotal
		aRet[2] := nTotOP
		aRet[3] := aDados
		aRet[4] := lValid	
		
		(cAlias)->(DbCloseArea())
		


RestArea(aAreaSE2)

Return aRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850  บAutor  ณMicrosiga           บ Data ณ  10/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IVA acumulado de outros documentos					     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F850DocIVA(cFornece,cLoja,nPagar,nRetIVAT)
       
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSFF := SFF->(GetArea())
Local aAreaSFH := SFH->(GetArea())
    
Local aIVA 		:= {}
Local aConfIVA 	:= {}
Local aDocs		:= {}
                            
Local cAliasSF	:= ""
Local cAliasSD	:= ""
Local cChaveSF	:= ""
Local cFilSF		:= ""
Local cTotal		:= ""
Local cSerie		:= ""
Local cDoc			:= ""
Local cCFO			:= ""
Local cSFE			:= ""
Local nMoedaDc		:= 1
Local nTxaDc		:= 1
Local cChaveSFE	:= ""
Local nX 			:= 0
Local nAliq 		:= 0 
Local nSigno	 	:= 1
Local nPorcIva 	:= 1           
Local nValor		:= 0
Local nTotRetSFE	:= 0
Local cCFOSD		:= ""
Local nCountI		:= 0
Local nTotRet 	:= 0
Local nReaj		:= 0  

DEFAULT cFornece	:= ""
DEFAULT cLoja	 	:= ""
DEFAULT nPagar	:= 0
DEFAULT nRetIvaT	:= 0

If IsInCallStack("F850Recal") .And. nMoedaCor != 1
	nRetIVAT := Round(xMoeda(nRetIVAT,nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) 
EndIf

If Len(aRetIvAcm) > 0
	
	If aRetIvAcm[1] <> Nil
		aConfIVA := aRetIvAcm[1]	
	EndIf
	
	If aRetIvAcm[2] <> Nil
		aDocs := aRetIvAcm[2]
	EndIf

EndIf

If cFornece <> Nil .And. cLoja <> Nil
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	If SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
		nPorcIva := SA2->A2_PORIVA/100	
	EndIf
EndIf

If Len(aDocs) > 0 .And. Len(aConfIVA) > 0

	nTotRet += nRetIvaT
	
	nAliq := aConfIVA[1]/100
	
	For nX := 1 to Len(aDocs)
		
		If aDocs[nX][3] //Calcula IVA para o documento
		
			cAliasSF := aDocs[nX][2]
			dbSelectArea(cAliasSF)
			
			(cAliasSF)->(dbGoTo(aDocs[nX][1]))
				
			If cAliasSF == "SF1"
				cAliasSD := "SD1"
				nSigno 	:= 1    
				cChaveSF 	:= "F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA"  
				cTotal	 	:= "D1_TOTAL"
				cFilSF  	:= "F1_FILIAL"
				cSerie	 	:= "F1_SERIE"
				cDoc	 	:= "F1_DOC" 
				cCFO	 	:= "D1_CF" 
				cSFE 	 	:= "F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE"
				cForn	 	:= "D1_FORNECE"
				cLojaForn	:= "D1_LOJA"
				cDocSD  	:= "D1_DOC"
				cSerieSD	:= "D1_SERIE"
				nMoedaDc	:= "F1_MOEDA"
				nTxaDc		:= "F1_TXMOEDA"
			Else
				cAliasSD 	:= "SD2"
				nSigno 	:= -1
				cChaveSF 	:= "F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA"
				cFilSF  	:= "F2_FILIAL"
				cTotal	 	:= "D2_TOTAL"
				cSerie	 	:= "F2_SERIE"
				cDoc	 	:= "F2_DOC"
				cCFO	 	:= "D2_CF" 
				cSFE 	 	:= "F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE"
				cForn	 	:= "D2_CLIENTE"
				cLojaForn	:= "D2_LOJA   
				cDocSD  	:= "D2_DOC"
				cSerieSD	:= "D2_SERIE"
				nMoedaDc	:= "F2_MOEDA"
				nTxaDc		:= "F2_TXMOEDA"
			EndIf 
			cCFOSD		:= ""   
		                    
			dbSelectArea(cAliasSD)
			If cAliasSD == "SD1" 
				(cAliasSD)->(dbSetOrder(1))
			Else
				(cAliasSD)->(dbSetOrder(3))	
			EndIf
		
		   (cAliasSD)->(MsSeek((cAliasSF)->&(cFilSF)+(cAliasSF)->&(cChaveSF)))
			While !(cAliasSD)->(Eof()) .And. (cAliasSD)->&(cDocSD)+ (cAliasSD)->&(cSerieSD)+(cAliasSD)->&(cForn)+(cAliasSD)->&(cLojaForn) ==(cAliasSF)->&(cChaveSF)
				nValor += (cAliasSD)->&(cTotal)
				cCFOSD	:= (cAliasSD)->&(cCFO)
				(cAliasSD)->(dbSkip()) 
			EndDo
			
			nValor := nValor * (aDocs[nX][4]/100)
			
			AAdd(aIVA,Array(11))
			aIVA[Len(aIVA)][1]  := (cAliasSF)->&(cDoc)        			//FE_NFISCAL
			aIVA[Len(aIVA)][2]  := (cAliasSF)->&(cSerie)       			//FE_SERIE
			aIVA[Len(aIVA)][3]  := Round(xMoeda((nValor*nSigno),(cAliasSF)->&(nMoedaDc),1,,5,,aTxMoedas[(cAliasSF)->&(nMoedaDc)][2]),MsDecimais((cAliasSF)->&(nMoedaDc))) //FE_VALBASE
			aIVA[Len(aIVA)][4]  := Round(xMoeda((nValor*nAliq)*nSigno,(cAliasSF)->&(nMoedaDc),1,,5,,aTxMoedas[(cAliasSF)->&(nMoedaDc)][2]),MsDecimais((cAliasSF)->&(nMoedaDc)))	//FE_VALIMP
			aIVA[Len(aIVA)][5]  := nPorcIva*100    						//FE_PORCRET
			aIVA[Len(aIVA)][6]  := (aIVA[Len(aIVA)][4] * nPorcIva) //FE_RETENC
			aIVA[Len(aIVA)][9]  := cCFOSD 			//Gravar CFOP da opera็ใo
			aIVA[Len(aIVA)][10] := aConfIVA[1]					//Manter a estrutura do array de reten็ใo do IVA - gravado o mesmo CFO
			
			If cAliasSF == "SF1"
				SFF->(DbSetOrder(5)) 
			Else
				SFF->(DbSetOrder(6))
			EndIf
			SFF->(MsSeek(xFilial("SFF")+"IVR" + cCFOSD))
			If !Empty(SFF->FF_CFO)
				aIVA[Len(aIVA)][11] := SFF->FF_CFO	
			Else
				MsgAlert(STR0256)
				aIVA[Len(aIVA)][11] := " "	
			EndIf		
        
	        //Levanta quanto ja foi retido
			SFE->(dbSetOrder(4))
			If SFE->(MsSeek(xFilial("SFE")+(cAliasSF)->&(cSFE)+"I"))
		  	   	cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
				While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
					If SFE->FE_TIPO =="I" .and. ((SFE->FE_RETENC < 0 .and. cAliasSF == "SF2") .or. (SFE->FE_RETENC > 0 .and. cAliasSF == "SF1"))
						nTotRetSFE += SFE->FE_RETENC
					EndIf
					SFE->(dbSkip())
				EndDo
	
				//Abate da retencao que foi calculada.	
				aIVA[Len(aIVA)][6] -= nTotRetSFE * (aDocs[nX][4]/100) 
				nTotRetSFE := 0							
			EndIf
	        nTotRet += aIVA[Len(aIVA)][6] 
	        nValor := 0
	        (cAliasSD)->(dbCloseArea())
	        (cAliasSF)->(dbCloseArea())
	                               	  
		EndIf

	Next nX
	
	If nPagar <= nTotRet
		nPagar -= nRetIVAT
		nTotRet -= nRetIVAT
		For nCountI := 1 To Len(aIVA)
			nReaj := IIF(aIVA[nCountI][6] >= 0, (nPagar * (aIVA[nCountI][6] /nTotRet)),-(nPagar * (aIVA[nCountI][6] /nTotRet)))
			aIVA[nCountI][6] := Iif(nReaj>0,nReaj,0)
		Next nCountI		
	EndIf
	
EndIf      

aRetIvAcm[3] := aIVA

SA2->(RestArea(aAreaSA2))
SE2->(RestArea(aAreaSE2))
SD1->(RestArea(aAreaSD1))
SF1->(RestArea(aAreaSF1))
SD2->(RestArea(aAreaSD2))
SF2->(RestArea(aAreaSF2))
SFF->(RestArea(aAreaSFF))
SFH->(RestArea(aAreaSFH))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850  บAutor  ณMicrosiga           บ Data ณ  10/25/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PropIV(nValPag,nRetIva,aSE2TMP,nReten)
                             
Local nX 	:= 0
Local nA 	:= 0       
Local nProp := 0
Local nSoma := 0
Local lEsNCR:= .F.

DEFAULT nValPag	  := 0 
DEFAULT nRetIVA	  := 0 
DEFAULT aSE2TMP   := {}   
DEFAULT nReten    := 0

//Proporcionaliza็ใo
If  cPaisLoc == "ARG" .And. (IsInCallStack("F850recal") .Or. IsInCallStack("Fn850GtRet")) .And. SE2->E2_TIPO $ MV_CPNEG 
	lEsNCR := .T.  //En caso de que venga de re-calculo y sea NC's
Endif  

If !IsInCallStack("Fn850GtRet") .And. (aSE2TMP[1][1][4] != 1 .Or. (aSE2TMP[1][1][4] == 1 .And. nMoedaCor != 1))
	nRetIVA := Round(xMoeda(nRetIVA,nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) 
	nReten := Round(xMoeda(nReten,nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) 
EndIf

If(Iif((IsInCallStack("F850Ordens") .Or. IsInCallStack("Fn850GtRet")) .and. Ascan(aSE2TMP[1],{|X| Alltrim(X[_TIPO]) == "PA"}), nValPag > 0,.T.))
	nValPag := nValPag - nReten
Endif

If  (nValPag < nRetIVA  .OR. (lEsNCR .And. nValPag < abs(nRetIVA)) ) .And. ;
	(Iif((IsInCallStack("F850Ordens") .Or. IsInCallStack("Fn850GtRet")) .and. Ascan(aSE2TMP[1],{|X| Alltrim(X[_TIPO]) == "PA"}) > 0, nValPag > 0,.T.)) 
	nProp := nValPag/nRetIVA
Else
	nProp := 1
EndIf 
  
If nProp < 1 .And. nProp != 0
	//Proporcionaliza o valor de IVA das notas pendentes
	For nX := 1 to Len(aRetIvAcm[3])
		If nValPag > 0
			aRetIvAcm[3][nX][6] := Round(aRetIvAcm[3][nX][6] * nProp,MsDecimais(1))
			nSoma += aRetIvAcm[3][nX][6]  
		EndIf
	Next nX
	                
	//Proporcionaliza o valor do IVA das notas selecionadas na OP
	If Len(aSE2TMP) > 0
		For nA	:=	1	To	Len(aSE2TMP[1])
			For nX	:=	1	To	Len(aSE2TMP[1][nA][_RETIVA])	
				aSE2TMP[1][nA][_RETIVA][nX][6] := Round(aSE2TMP[1][nA][_RETIVA][nX][6] * nProp,MsDecimais(1))
				nSoma += aSE2TMP[1][nA][_RETIVA][nX][6]  
			Next nX
		Next nA
	EndIf           
	
	//Ajusta os centavos no ๚ltimo tํtulo	
	If nSoma > nValPag            
		If Len(aSE2TMP) > 0
			If Len(aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA]) > 0	
				aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA][Len(aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA])][6] -= (nSoma - nValPag)
			EndIf
		EndIf  
	ElseIf (nValPag - nSoma) == 0.01
		If Len(aSE2TMP) > 0
			If Len(aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA]) > 0	
				aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA][Len(aSE2TMP[1][Len(aSE2TMP[1])][_RETIVA])][6] += 0.01
			EndIf
		EndIf 	 
	EndIf
EndIf
	
Return

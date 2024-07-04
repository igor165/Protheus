#INCLUDE "PROTHEUS.CH" 
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NfdsXml001³ Autor ³ Roberto Souza         ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exemplo de geracao da Nota Fiscal Digital de Serviços       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Xml para envio                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da NF                                           ³±±
±±³          ³       [0] Entrada                                          ³±±
±±³          ³       [1] Saida                                            ³±±
±±³          ³ExpC2: Serie da NF                                          ³±±
±±³          ³ExpC3: Numero da nota fiscal                                ³±±
±±³          ³ExpC4: Codigo do cliente ou fornecedor                      ³±±
±±³          ³ExpC5: Loja do cliente ou fornecedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31.01.2017³M.Camargo      ³MMI-301                                     ³±±
±±³          ³               ³Realizar la transmisión de las notas fiscale³±±
±±³          ³               ³cuando la factura sea emitida en pesos      ³±±              
±±³          ³               ³(moneda 01) pero con una tasa igual a dólar ³±±
±±³          ³               ³(moneda 02)Al transmitir la factura en pesos³±±
±±³          ³               ³ a la AFIP, la tasa debe ser igual 1.       ³±±
±±³          ³               ³MMI-325 Se implementan las opciones de      ³±±
±±³          ³               ³consulta, solicitud y transmisión de CAEA   ³±±
±±³          ³               ³Nominal                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                       

User Function NFAEXml001(cTipo,cSerie,cNota,cClieFor,cLoja,nUltId,cTipoNF,cCAEA)

Local nX        := 0
Local nY          := 0
Local cString    := ""
Local cAliasSD1  := "SD1"
Local cAliasSD2  := "SD2"
Local cMensCli   := ""
Local cMensFis   := ""
Local lQuery    := .F.
Local aDest     := {}
Local aProd     := {}
Local acabNF :={}
Local aPed :={}             
Local aNfVinc:={}       
Local cCodUM:=""
Local lPedido :=""                                                                    
Local cUltId:= AllTrim(str(PARAMIXB[6])) 
Local nIB:=0
Local nIV:=0
Local cBonTS	:= SuperGetMv("MV_BONUSTS",,"")
Local lBnTs	:= .F.
Local cTes		:= ""
Local lCmpA2Afip	:= SA2->(ColumnPos("A2_AFIP")) > 0
Local lCmpA1Afip	:= SA1->(ColumnPos("A1_AFIP")) > 0  
Local cRG4919     	:= GetMV("MV_RG4919",.F., '')
Local cCBUCFE     	:= GetMV("MV_CCBUCFE",.F.,'')
Local lSA1RG4919  	:= AI0->(ColumnPos("AI0_RG4919")) > 0 
Local lSA2RG4919  	:= SA2->(ColumnPos("A2_RG4919"))  > 0 
Local lSA1CBUFCE  	:= AI0->(ColumnPos("AI0_CBUFCE")) > 0 
Local lSA2CBUFCE  	:= SA2->(ColumnPos("A2_CBUFCE")) > 0
Local cConteud		:= ""

Private aColIB	:={}
Private aColIVA	:={}
Private aIB:={}
Private aIVA:={} 
Private _cSerie := ""
Private aCposRG3668 := {}
Private nTamPV := TamSX3("F2_PV")[1]

PRIVATE aTamSx3Prc  := TamSx3("D2_PRCVEN")
Private cRG1415 := ""
DEFAULT cTipo   := PARAMIXB[1]
DEFAULT cSerie  := PARAMIXB[2]
DEFAULT cNota   := PARAMIXB[3]
DEFAULT cClieFor:= PARAMIXB[4]
DEFAULT cLoja   := PARAMIXB[5]
DEFAULT cTipoNF	:= PARAMIXB[7]
DEFAULT cCAEA	:= PARAMIXB[8]

If cTipo == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona NF                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF2")
	dbSetOrder(1)
	DbGoTop()
	If MsSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)	
		aadd(aCabNF,SF2->F2_EMISSAO)
		aadd(aCabNF,Subs(SF2->F2_DOC,1,nTamPV))
		aadd(aCabNF,Subs(SF2->F2_DOC,nTamPV+1,8))                  
		aadd(aCabNF,IIf(Strzero(SF2->F2_MOEDA,2) == "01", 1, SF2->F2_TXMOEDA))  
		aadd(aCabNF,SF2->F2_VALBRUT)
		If Substr(Alltrim(cSerie),1,1) == "A" .And. cTipoNF $ "1|5"
			ObtCposRG3668() 
		EndIf
		Impostos(cTipoNF)
		nVlIb:=0
		For nIB := 1 To Len(aColIB)
		    If &("SF2->F2_VALIMP"+aColIB[nIB][1]) > 0
				aadd(aIB,{&("SF2->F2_VALIMP"+aColIB[nIB][1]),;                    
								&("SF2->F2_BASIMP"+aColIB[nIB][1]),;              
									aColIB[nIB][2],;                              
									aColIB[nIB][3],;                              
									aColIB[nIB][4],;                              
									})
			EndIf						
			nVlIb:= nVlIb + &("SF2->F2_VALIMP"+aColIB[nIB][1])		
		Next				
			
		nVlIv:=0
		For nIV := 1 To Len(aColIVA)			
			
			nVlIv:= nVlIv + &("SF2->F2_VALIMP"+aColIVA[nIV][1])
			If  &("SF2->F2_VALIMP"+aColIVA[nIV][1]) > 0				
				aadd(aIVA,{&("SF2->F2_VALIMP"+aColIVA[nIV][1]),;
							&("SF2->F2_BASIMP"+aColIVA[nIV][1]),;
								aColIVA[nIV][2],;
								aColIVA[nIV][3],;
								aColIVA[nIV][4],;								
								})
			EndIf					
		Next		
		aadd(aCabNF,nVlIb)  
		aadd(aCabNF,nVlIv)  
		aadd(aCabNF,SF2->F2_FRETE+SF2->F2_DESPESA+SF2->F2_SEGURO)  
		aadd(aCabNF,SF2->F2_SERIE)
		aadd(aCabNF,SF2->F2_ESPECIE)
		aadd(aCabNF,SF2->F2_VALMERC)  
		cRG1415 := SF2->F2_RG1415
		
		_cSerie		:= SF2->F2_SERIE 
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona cliente ou fornecedor                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If Alltrim(SF2->F2_ESPECIE)=="NDI"  
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			aadd(aDest,AllTrim(SA2->A2_PAIS))
			aadd(aDest,SA2->A2_NOME)
			aadd(aDest,AllTrim(SA2->A2_CGC))
			aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[1])
			//Pega o Tipo do Documento do Fornecedor/Cliente
			If lCmpA2Afip
				aadd( aDest, AfipCode(SA2->A2_AFIP) )
			Else
				aadd( aDest, AfipCode("1") )					
			EndIf
			If lSA2RG4919 .and. !Empty(SA2->A2_RG4919)
				aadd( aDest,SA2->A2_RG4919 )
			Else
				aadd( aDest,cRG4919 )
			EndIf
			If lSA2CBUFCE .and. !Empty(SA2->A2_CBUFCE) 
				aadd( aDest,SA2->A2_CBUFCE)
			Else
				aadd( aDest,cCBUCFE )
			EndIf
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			aadd(aDest,AllTrim(SA1->A1_PAIS))
			aadd(aDest,SA1->A1_NOME)
			aadd(aDest,AllTrim(SA1->A1_CGC))
			aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[1])
			If lCmpA1Afip
				aadd( aDest, AfipCode(SA1->A1_AFIP) )
			Else
				aadd( aDest, AfipCode("1") )					
			EndIf
			If lSA1RG4919
				cConteud:= Posicione("AI0",1,xFilial("AI0")+SA1->(A1_COD+A1_LOJA),'AI0_RG4919')
				If !Empty(cConteud)
					cRG4919:= cConteud
				EndIf
			EndIf
			aadd( aDest,cRG4919 )
			
			If lSA1CBUFCE
				cConteud:= Posicione("AI0",1,xFilial("AI0")+SA1->(A1_COD+A1_LOJA),'AI0_CBUFCE') 
				If !Empty(cConteud)
					cCBUCFE:= cConteud
				EndIf
			EndIf
			aadd( aDest,cCBUCFE )
			
		EndIf	
		
		dbSelectArea("SF2")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa itens de nota                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		dbSelectArea("SD2")
		dbSetOrder(3)	
		lQuery  := .T.
		cAliasSD2 := GetNextAlias()
		BeginSql Alias cAliasSD2
			SELECT * FROM %Table:SD2% SD2
			WHERE
			SD2.D2_FILIAL = %xFilial:SD2% AND
			SD2.D2_SERIE = %Exp:SF2->F2_SERIE% AND 
			SD2.D2_DOC = %Exp:SF2->F2_DOC% AND 
			SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND 
			SD2.D2_LOJA = %Exp:SF2->F2_LOJA% AND 
			SD2.%NotDel%
			ORDER BY %Order:SD2%
		EndSql
		dbSelectArea(cAliasSD2)
		While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
			SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
			SF2->F2_DOC == (cAliasSD2)->D2_DOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica as notas vinculadas                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty((cAliasSD2)->D2_NFORI)  .and. (cTipoNF $ "1|3|5" .Or. (cTipoNF = "4" .And. SF2->F2_RG1415 != Nil .And. VAL(SF2->F2_RG1415) > 200))
				If (cAliasSD2)->D2_TIPO $ "DBN"
					dbSelectArea("SD1")
					dbSetOrder(1)
					If MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI) .or. ;
					(   Val(SF1->F1_RG1415) >  200 .and.	MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
						
						dbSelectArea("SF1")
						dbSetOrder(1)
						MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
						If SD1->D1_TIPO $ "DB"
							dbSelectArea("SA1")
							dbSetOrder(1)
							MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
						Else
							dbSelectArea("SA2")
							dbSetOrder(1)
							MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
						EndIf
						
						aadd(aNfVinc,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,IIF(SD1->D1_TIPO $ "DB",IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA1->A1_CGC),IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA2->A2_CGC)),SM0->M0_ESTCOB,SF1->F1_ESPECIE,SF1->F1_RG1415})
					EndIf
				Else
					aOldReg  := SD2->(GetArea())
					aOldReg2 := SF2->(GetArea())
					dbSelectArea("SD2")
					dbSetOrder(3)
					If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)      .OR. ;      
					    (   Val(SF2->F2_RG1415)>200 .and. MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)  )

						dbSelectArea("SF2")
						dbSetOrder(1)
						MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
						If !SD2->D2_TIPO $ "DB"
							dbSelectArea("SA1")
							dbSetOrder(1)
							MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
						Else
							dbSelectArea("SA2")
							dbSetOrder(1)
							MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
						EndIf
						
						If aScan(aNFVinc,{|z| z[2]+z[3]+z[6] == SD2->(D2_SERIE+D2_DOC+AllTrim(D2_ESPECIE)) }) == 0
							aadd(aNfVinc,{SD2->D2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,AllTrim(SF2->F2_ESPECIE),SF2->F2_RG1415})
						EndIf
					Else
						dbSelectArea("SD1")
						dbSetOrder(1)
						If  Val(SF2->F2_RG1415) >  200 .and.	MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
							dbSelectArea("SF1")
							dbSetOrder(1)
						   	If MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
								dbSelectArea("SA1")
								dbSetOrder(1)
								If	MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
							   		aadd(aNfVinc,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,SF1->F1_ESPECIE,SF1->F1_RG1415}) 
							 	EndIf
						 	EndIf	
						EndIf
					EndIf
					RestArea(aOldReg)
					RestArea(aOldReg2)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem os dados do produto                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			dbSelectArea("SB1")
			dbSetOrder(1)
			MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
						
			cMensFis:=""
			lPedido:=.F.
			If !Empty((cAliasSD2)->D2_PEDIDO)
				dbSelectArea("SC5")
				dbSetOrder(1)
				MsSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
			
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)
			
				If !AllTrim(SC5->C5_MENNOTA) $ cMensCli
					cMensCli += AllTrim(SC5->C5_MENNOTA)
				EndIf
				If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
					cMensFis += AllTrim(FORMULA(SC5->C5_MENPAD))
				EndIf
				lPedido:=.T.
			EndIf     
			
			If lPedido
					aadd(aPed,SC5->C5_TPVENT)
			Else
					aadd(aPed,SF2->F2_TPVENT)
			EndiF 

			aadd(aPed,SF2->F2_ESPECIE) 		
			aadd(aPed,AllTrim(SA1->A1_CGC)) 
			aadd(aPed,AllTrim(SA1->A1_PAIS))
			aadd(aPed,MyGetEnd(SA1->A1_ENDENT,"SA2")[1])
			aadd(aPed,cMensFis)                         
			
			If lPedido            
				aadd(aPed,Alltrim(SC5->C5_INCOTER))  
				aadd(aPed,SC5->C5_PERMISSO)
				aadd(aPed,Iif(SYA->(MsSeek(xFilial("SYA")+ SC5->C5_PAISENT)),SYA->YA_SISEXP, SC5->C5_PAISENT) )
			Else
				aadd(aPed,Alltrim(SF2->F2_INCOTER))	 
				aadd(aPed,If(Alltrim(SF2->F2_TPVENT) $ '1|B',' ',SF2->F2_PERMISSO))
				aadd(aPed,Iif(SYA->(MsSeek(xFilial("SYA")+ SF2->F2_PAISENT)),SYA->YA_SISEXP, SF2->F2_PAISENT) )
            EndIf
         				
			cMoeda:='GetMV("MV_SIMB'+Alltrim(str(SF2->F2_MOEDA))+'")'
			If(SYF->(MsSeek(xFilial("SYF")+&cMoeda)) )
				aadd(aPed,SYF->YF_COD_GI)      
			Else
				aadd(aPed,"01")   
			EndIf                      
				
			If lPedido            
				aadd(aPed,SC5->C5_IDIOMA)
			 	aadd(aPed,Iif(SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)),SE4->E4_FMPAGEX,"")) 
			Else
				aadd(aPed,SF2->F2_IDIOMA)
				aadd(aPed,Iif(SE4->(MsSeek(xFilial("SE4")+SF2->F2_COND)),SE4->E4_FMPAGEX,"")    )  
			EndIf	
			aadd(aPed,SF2->F2_VALMERC)   
				
			dbSelectArea(cAliasSD2)	
			While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
				SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
				SF2->F2_DOC == (cAliasSD2)->D2_DOC
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem os dados do produto                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				
				dbSelectArea("SAH")
				dbSetOrder(1)
		      If SAH->(MsSeek(xFilial("SAH")+(cAliasSD2)->D2_UM)   )
					cCodUM := SAH->AH_CODUMFE
				Else  
					cCodUM	:=	"98"   
				EndIf				
				
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD) 				
				
				cTes:= (cAliasSD2)->D2_TES
				lBnTs := cTes $ cBonTS //$ cTes					
		 		aadd(aProd,	{Len(aProd)+1,;
							(cAliasSD2)->D2_COD,;
							IIF(!Empty((cAliasSD2)->D2_PEDIDO).And. Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI),;
							(cAliasSD2)->D2_QUANT,;
							cCodUM,;
							(cAliasSD2)->D2_PRCVEN,;
							IIf(lBnTs,((cAliasSD2)->D2_TOTAL -(cAliasSD2)->D2_PRCVEN),(cAliasSD2)->D2_TOTAL),;							
							Substr(SB1->B1_CODBAR,1,13),;
							IIf(lBnTs,(cAliasSD2)->D2_PRCVEN,(cAliasSD2)->D2_DESCON)})						
							
				For nX:=1 to Len(aColIB)
					If &(cAliasSD2+"->D2_VALIMP"+aColIB[nX][1])>0
						If Len(aColIB[nX][2])>0
							nY:=AScan( aColIB[nX][2], { |y| y[1] == &(cAliasSD2+"->D2_ALQIMP"+aColIB[nX][1])} )
							If  nY==0			 
								AADD(aColIB[nX][2],{&(cAliasSD2+"->D2_ALQIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_VALIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_BASIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_DESGR"+aColIB[nX][1])})
					   		Else
					    		aColIB[nX][2][nY][2]:=aColIB[nX][2][nY][2] + &(cAliasSD2+"->D2_VALIMP"+aColIB[nX][1])
					    		aColIB[nX][2][nY][3]:=aColIB[nX][2][nY][3] + &(cAliasSD2+"->D2_BASIMP" +aColIB[nX][1])
					    	EndIf
					    Else
					    	AADD(aColIB[nX][2],{&(cAliasSD2+"->D2_ALQIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_VALIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_BASIMP"+aColIB[nX][1]),&(cAliasSD2+"->D2_DESGR"+aColIB[nX][1])})	
				    	EndIf
				    EndIf	
                Next          
                
                For nX:=1 to Len(aColIVA)
                	If &(cAliasSD2+"->D2_VALIMP"+aColIVA[nX][1]) >0
                		If cTipoNf $ "1|3|4|5|7"
                			aadd(aProd[Len(aProd)],aColIVA[nX][3]) 
                		EndIF					
						If Len(aColIVA[nX][2])>0
							nY:=AScan( aColIVA[nX][2], { |y| y[1] == &(cAliasSD2+"->D2_ALQIMP"+aColIVA[nX][1])} )

				 			If  nY==0
				 				AADD(aColIVA[nX][2],{&(cAliasSD2+"->D2_ALQIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_VALIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_BASIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_DESGR"+aColIVA[nX][1])})
			   				Else
			   					If cTipoNf $ "1|3|4|5"
			   						aadd(aProd[Len(aProd)],&(cAliasSD2+"->D2_VALIMP"+aColIVA[nX][1])) 
			    					aadd(aProd[Len(aProd)],&(cAliasSD2+"->D2_ALQIMP"+aColIVA[nX][1])) 
									aadd(aProd[Len(aProd)],&(cAliasSD2+"->D2_BASIMP"+aColIVA[nX][1])) 
									aadd(aProd[Len(aProd)],&(cAliasSD2+"->D2_DESGR"+aColIVA[nX][1])) 
			    				EndIf	
			    				
			    				aColIVA[nX][2][nY][2]:=aColIVA[nX][2][nY][2] + &(cAliasSD2+"->D2_VALIMP"+aColIVA[nX][1])
			    				aColIVA[nX][2][nY][3]:=aColIVA[nX][2][nY][3] + &(cAliasSD2+"->D2_BASIMP"+aColIVA[nX][1])
			    				aColIVA[nX][2][nY][4]:=aColIVA[nX][2][nY][4] + &(cAliasSD2+"->D2_DESGR"+aColIVA[nX][1])			    					    				
			    			EndIf 
			    	    Else						
		    	    		AADD(aColIVA[nX][2],{&(cAliasSD2+"->D2_ALQIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_VALIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_BASIMP"+aColIVA[nX][1]),&(cAliasSD2+"->D2_DESGR"+aColIVA[nX][1])})
		    	    		If cTipoNf $ "1|3|4|5"
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][2]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][1]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][3]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][4]) 
			    			EndIf		
			    		EndIf
			    	EndIf
			    
                Next
                
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciono elementos em branco quando não tem IVA, para não estourar o array na montagem do XML³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
                If Len(aProd[Len(aProd)]) < 10 .and. (cTipoNf $ "1|3|4|5|7") 
               		aadd(aProd[Len(aProd)],IIf(lBnTs,"4","2")) 
            		aadd(aProd[Len(aProd)],0) 
           			aadd(aProd[Len(aProd)],0) 
       				aadd(aProd[Len(aProd)],0) 
   					aadd(aProd[Len(aProd)],0) 
			    EndIf
			    			    
			    aadd(aProd[Len(aProd)], TRANSFORM(SB1->B1_POSIPI,  PesqPict("SB1","B1_POSIPI")))     
			    
			    if (cAliasSD2)->(ColumnPos("D2_DESPESA")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD2)->D2_DESPESA)
			    else
			    	aadd (aProd[Len(aProd)],0)	
			    endif
			    if (cAliasSD2)->(ColumnPos("D2_SEGURO")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD2)->D2_SEGURO)
			    else
			    	aadd (aProd[Len(aProd)],0)
			    endif
			    if (cAliasSD2)->(ColumnPos("D2_VALFRE")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD2)->D2_VALFRE)
			    else
			    	aadd (aProd[Len(aProd)],0)
			    endif
                
			    aadd (aProd[Len(aProd)],(cAliasSD2)->D2_TES)
				dbSelectArea(cAliasSD2)
				dbSkip()
			EndDo	
	    EndDo
	    
	    If lQuery
	    	dbSelectArea(cAliasSD2)
	    	dbCloseArea()
	    	dbSelectArea("SD2")
	    EndIf
	
	EndIf
Else
	dbSelectArea("SF1")
	dbSetOrder(1)
	If MsSeek(xFilial("SF1")+cNota+cSerie+cClieFor+cLoja)
		aadd(aCabNF,SF1->F1_EMISSAO)
		aadd(aCabNF,Subs(SF1->F1_DOC,1,nTamPV))
		aadd(aCabNF,Subs(SF1->F1_DOC,nTamPV+1,8))
		aadd(aCabNF,IIf(Strzero(SF1->F1_MOEDA,2) == "01", 1, SF1->F1_TXMOEDA))  
		aadd(aCabNF,SF1->F1_VALBRUT) 		
		cTipoCond:=Iif(SE4->(MsSeek(xFilial("SE4")+SF1->F1_COND)),SE4->E4_FMPAGEX,"")  
		If !(cTipoNF $ "1|5")
			aadd(aCabNF,cTipoCond)
		EndIf
		
		Impostos(cTipoNF)
		nVlIb:=0
		For nIB := 1 To Len(aColIB)
		    If &("SF1->F1_VALIMP"+aColIB[nIB][1]) > 0
				aadd(aIB,{&("SF1->F1_VALIMP"+aColIB[nIB][1]),;                    
								&("SF1->F1_BASIMP"+aColIB[nIB][1]),;              
									aColIB[nIB][2],;                              
									aColIB[nIB][3],;                              
									aColIB[nIB][4],;                              
									})
			EndIf						
			nVlIb:= nVlIb + &("SF1->F1_VALIMP"+aColIB[nIB][1])
		Next				
			
		nVlIv:=0
		For nIV := 1 To Len(aColIVA)
			nVlIv:= nVlIv + &("SF1->F1_VALIMP"+aColIVA[nIV][1])
			If  &("SF1->F1_VALIMP"+aColIVA[nIV][1]) > 0
				aadd(aIVA,{&("SF1->F1_VALIMP"+aColIVA[nIV][1]),;
							&("SF1->F1_BASIMP"+aColIVA[nIV][1]),;
								aColIVA[nIV][2],;
								aColIVA[nIV][3],;
								aColIVA[nIV][4],;
								})
			EndIf					
		Next		
		aadd(aCabNF,nVlIb)  
		aadd(aCabNF,nVlIv)  
		aadd(aCabNF,SF1->F1_FRETE+SF1->F1_DESPESA+SF1->F1_SEGURO)  
		aadd(aCabNF,SF1->F1_SERIE)
		aadd(aCabNF,AllTrim(SF1->F1_ESPECIE))
		aadd(aCabNF,SF1->F1_VALMERC)  
		aadd(aCabNF,SF1->F1_DESCONT) 
		
		cRG1415 := SF1->F1_RG1415
		_cSerie		:= SF1->F1_SERIE 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona cliente ou fornecedor                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		
			If SF1->F1_TIPO $ "DB"  .Or. Alltrim(SF1->F1_ESPECIE)=="NCI" 
			    If Alltrim(SF1->F1_ESPECIE)=="NCI"
				    dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
					aadd(aDest,AllTrim(SA2->A2_PAIS))
					aadd(aDest,SA2->A2_NOME)
					aadd(aDest,AllTrim(SA2->A2_CGC))
					aadd(aDest,MyGetEnd(SA2->A2_END,"SA1")[1])
					If lCmpA2Afip
						aadd( aDest, AfipCode(SA2->A2_AFIP) )
					Else
						aadd( aDest, AfipCode("1") )					
					EndIf				
				If lSA2RG4919 .and. !Empty(SA2->A2_RG4919)
						aadd( aDest,SA2->A2_RG4919 )
					Else
						aadd( aDest,cRG4919 )
				EndIf
				If lSA2CBUFCE  .and. !Empty(SA2->A2_CBUFCE) 
					aadd( aDest, SA2->A2_CBUFCE)
				Else
					aadd( aDest,cCBUCFE )
				EndIf
			   Else		
					dbSelectArea("SA1")
					dbSetOrder(1)
					MsSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
					aadd(aDest,AllTrim(SA1->A1_PAIS))
					aadd(aDest,SA1->A1_NOME)
					aadd(aDest,AllTrim(SA1->A1_CGC))
					aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[1])
					If lCmpA1Afip
						aadd( aDest, AfipCode(SA1->A1_AFIP) )
					Else
						aadd( aDest, AfipCode("1") )					
					EndIf
					If lSA1RG4919
						cConteud:= Posicione("AI0",1,xFilial("AI0")+SA1->(A1_COD+A1_LOJA),'AI0_RG4919') 						
						If !Empty(cConteud)
							cRG4919:=cConteud
						EndIf
					EndIf
					aadd( aDest,cRG4919 )
				
					If lSA1CBUFCE
						cConteud:= Posicione("AI0",1,xFilial("AI0")+SA1->(A1_COD+A1_LOJA),'AI0_CBUFCE') 
						If !Empty(cConteud)
							cCBUCFE:=cConteud
						EndIf
					EndIf
				
					aadd( aDest,cCBUCFE )
				EndIf	
			    	
				dbSelectArea("SD1")
				dbSetOrder(1)	

				lQuery  := .T.
				cAliasSD1 := GetNextAlias()
				BeginSql Alias cAliasSD1
				SELECT * FROM %Table:SD1% SD1
				WHERE
				SD1.D1_FILIAL = %xFilial:SD1% AND
				SD1.D1_SERIE = %Exp:SF1->F1_SERIE% AND 
				SD1.D1_DOC = %Exp:SF1->F1_DOC% AND 
				SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE% AND 
				SD1.D1_LOJA = %Exp:SF1->F1_LOJA% AND 
				SD1.D1_FORMUL = 'S' AND 
				SD1.%NotDel%
				ORDER BY %Order:SD1%
				EndSql

			While !Eof() .And. xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
				SF1->F1_SERIE == (cAliasSD1)->D1_SERIE .And.;
				SF1->F1_DOC == (cAliasSD1)->D1_DOC .And.;
				SF1->F1_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
				SF1->F1_LOJA ==  (cAliasSD1)->D1_LOJA				
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as notas vinculadas                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				
				If !Empty((cAliasSD1)->D1_NFORI)  .And. (cTipoNF $ "1|3|5" .Or. (cTipoNF = "4" .And. SF1->F1_RG1415 != Nil .And. VAL(SF1->F1_RG1415) > 200))
					
					If !(cAliasSD1)->D1_TIPO $ "DBNC"
						aOldReg  := SD1->(GetArea())
						aOldReg2 := SF1->(GetArea())
						dbSelectArea("SD1")
						dbSetOrder(1)
						
						If MsSeek(xFilial("SD1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI) .or. ;
							( Val(SF1->F1_RG1415) >  200 .and.  MsSeek(xFilial("SD1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
							
							dbSelectArea("SF1")
							dbSetOrder(1)
							MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
							If SD1->D1_TIPO $ "DBC"
								dbSelectArea("SA1")
								dbSetOrder(1)
								MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
							EndIf
							If aScan(aNFVinc,{|z| z[2]+z[3]+z[6] == SD1->(D1_SERIE+D1_DOC+AllTrim(D1_ESPECIE)) }) == 0
								aadd(aNfVinc,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SM0->M0_CGC,SF1->F1_PROVENT,AllTrim(SF1->F1_ESPECIE),SF1->F1_RG1415})
							EndIf
						EndIf
						RestArea(aOldReg)
						RestArea(aOldReg2)
					Else					
						dbSelectArea("SD2")
						dbSetOrder(3)
						
						
						If MsSeek(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI)  .or. ;
							( Val (SF1->F1_RG1415) > 200   .and.     MsSeek(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)   )
							
							dbSelectArea("SF2")
							dbSetOrder(1)
							MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
							If !SD2->D2_TIPO $ "DBC"
								dbSelectArea("SA1")
								dbSetOrder(1)
								MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)    
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							EndIf							
							If aScan(aNFVinc,{|z| z[2]+z[3]+z[6] == SD2->(D2_SERIE+D2_DOC+AllTrim(D2_ESPECIE)) }) == 0
								aadd(aNfVinc,{SD2->D2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SM0->M0_CGC,SF2->F2_PROVENT,AllTrim(SF2->F2_ESPECIE),SF2->F2_RG1415})
							EndIf
						EndIf
					EndIf				
				EndIf			 				

				aadd(aPed,SF1->F1_TPVENT) 								
				aadd(aPed,SF1->F1_ESPECIE)					 			
				aadd(aPed,AllTrim(SA1->A1_CGC))                
				aadd(aPed,AllTrim(SA1->A1_PAIS))               
				aadd(aPed,MyGetEnd(SA1->A1_ENDENT,"SA2")[1])   
				aadd(aPed,cMensFis)                            
			

				aadd(aPed,SF1->F1_INCOTER)	 
				aadd(aPed,SF1->F1_PERMISSO)     
				aadd(aPed,Iif(SYA->(MsSeek(xFilial("SYA")+ SF1->F1_PAISENT)),SYA->YA_SISEXP,SF1->F1_PAISENT) )

				cMoeda:='GetMV("MV_SIMB'+Alltrim(str(SF1->F1_MOEDA))+'")'
				If(SYF->(MsSeek(xFilial("SYF")+&cMoeda)) )
					aadd(aPed,SYF->YF_COD_GI)       
				Else
					aadd(aPed,"01")                 
				EndIf
				aadd(aPed,SF1->F1_IDIOMA)
				aadd(aPed,Iif(SE4->(MsSeek(xFilial("SE4")+SF1->F1_COND)),SE4->E4_FMPAGEX,"")    )  
				aadd(aPed,SF1->F1_VALMERC)   
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem os dados do produto                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				dbSelectArea("SAH")
				dbSetOrder(1)
		         If SAH->(MsSeek(xFilial("SAH")+(cAliasSD1)->D1_UM) )
		        	 cCodUM:=AH_CODUMFEX
				Else  				
					cCodUM	:=	"98"    
				EndIf
		
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD)
							
				aadd(aProd,	{Len(aProd)+1,;
							(cAliasSD1)->D1_COD,;
							SB1->B1_DESC,;
							(cAliasSD1)->D1_QUANT,;
							 cCodUM,;
							(cAliasSD1)->D1_VUNIT,;
							(cAliasSD1)->D1_TOTAL,;							
							Substr(SB1->B1_CODBAR,1,13),;
							((cAliasSD1)->D1_VALDESC  )})
					
				For nX:=1 to Len(aColIB)
					If &(cAliasSD1+"->D1_VALIMP"+aColIB[nX][1])>0
						If Len(aColIB[nX][2])>0
							nY:=AScan( aColIB[nX][2], { |y| y[1] == &(cAliasSD1+"->D1_ALQIMP"+aColIB[nX][1])} )
							If  nY==0			 
								AADD(aColIB[nX][2],{&(cAliasSD1+"->D1_ALQIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_VALIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_BASIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_DESGR"+aColIB[nX][1])})
					   		Else
					    		aColIB[nX][2][nY][2]:=aColIB[nX][2][nY][2] + &(cAliasSD1+"->D1_VALIMP"+aColIB[nX][1])
					    		aColIB[nX][2][nY][3]:=aColIB[nX][2][nY][3] + &(cAliasSD1+"->D1_BASIMP" +aColIB[nX][1])
					    	EndIf
					    Else
					    	AADD(aColIB[nX][2],{&(cAliasSD1+"->D1_ALQIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_VALIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_BASIMP"+aColIB[nX][1]),&(cAliasSD1+"->D1_DESGR"+aColIB[nX][1])})	
				    	EndIf
				    EndIf	
                Next          
                
                For nX:=1 to Len(aColIVA)
                	If &(cAliasSD1+"->D1_VALIMP"+aColIVA[nX][1]) >0
                		If cTipoNf $ "1|3|4|5"
                			aadd(aProd[Len(aProd)],aColIVA[nX][3]) 
                		EndIF					
						If Len(aColIVA[nX][2])>0
							nY:=AScan( aColIVA[nX][2], { |y| y[1] == &(cAliasSD1+"->D1_ALQIMP"+aColIVA[nX][1])} )

				 			If  nY==0
				 				AADD(aColIVA[nX][2],{&(cAliasSD1+"->D1_ALQIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_VALIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_BASIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_DESGR"+aColIVA[nX][1])})
			   				 Else
			   				 	If cTipoNf $ "1|3|4|5"
			    					aadd(aProd[Len(aProd)],&(cAliasSD1+"->D1_VALIMP"+aColIVA[nX][1])) 
			    					aadd(aProd[Len(aProd)],&(cAliasSD1+"->D1_ALQIMP"+aColIVA[nX][1])) 
									aadd(aProd[Len(aProd)],&(cAliasSD1+"->D1_BASIMP"+aColIVA[nX][1])) 
									aadd(aProd[Len(aProd)],&(cAliasSD1+"->D1_DESGR"+aColIVA[nX][1])) 
			    				EndIf
			    				aColIVA[nX][2][nY][2]:=aColIVA[nX][2][nY][2] + &(cAliasSD1+"->D1_VALIMP"+aColIVA[nX][1])
			    				aColIVA[nX][2][nY][3]:=aColIVA[nX][2][nY][3] + &(cAliasSD1+"->D1_BASIMP"+aColIVA[nX][1])
			    				//aColIVA[nX][2][nY][4]:=aColIVA[nX][2][nY][4] + &(cAliasSD1+"->D1_ALQIMP"+aColIVA[nX][1])
			    				aColIVA[nX][2][nY][4]:=aColIVA[nX][2][nY][4] + &(cAliasSD1+"->D1_DESGR"+aColIVA[nX][1])
			    				
			    			EndIf 
			    	    Else			    	    						
		    	    		AADD(aColIVA[nX][2],{&(cAliasSD1+"->D1_ALQIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_VALIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_BASIMP"+aColIVA[nX][1]),&(cAliasSD1+"->D1_DESGR"+aColIVA[nX][1])})
		    	       		If cTipoNf $ "1|3|4|5"
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][2]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][1]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][3]) 
			    				aadd(aProd[Len(aProd)],aColIVA[nX][2][1][4]) 
			    			EndIf		
			    	   	Endif	
			    	EndIf	
                Next          

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciono elementos em branco quando não tem IVA, para não estourar o array na montagem do XML³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If Len(aProd[Len(aProd)]) < 10 .and. (cTipoNf $ "1|3|4|5") 
               		aadd(aProd[Len(aProd)],"2") 
            		aadd(aProd[Len(aProd)],0) 
           			aadd(aProd[Len(aProd)],0) 
       				aadd(aProd[Len(aProd)],0) 
   					aadd(aProd[Len(aProd)],0) 
			    EndIf
	    	    
	    	    aadd(aProd[Len(aProd)], TRANSFORM(SB1->B1_POSIPI,  PesqPict("SB1","B1_POSIPI")))  
			    
			    if (cAliasSD1)->(ColumnPos("D1_DESPESA")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD1)->D1_DESPESA)
			    else
			    	aadd (aProd[Len(aProd)],0)	
			    endif
			    if (cAliasSD1)->(ColumnPos("D1_SEGURO")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD1)->D1_SEGURO)
			    else
			    	aadd (aProd[Len(aProd)],0)
			    endif
			    if (cAliasSD1)->(ColumnPos("D1_VALFRE")) > 0
			    	aadd (aProd[Len(aProd)],(cAliasSD1)->D1_VALFRE)
			    else
			    	aadd (aProd[Len(aProd)],0)
			    endif
                					
			    aadd (aProd[Len(aProd)],(cAliasSD1)->D1_TES) // RRA ESTO FALTA
				dbSelectArea(cAliasSD1)
				dbSkip()
			EndDo
		    If lQuery
		    	dbSelectArea(cAliasSD1)
		    	dbCloseArea()
		    	dbSelectArea("SD1")
		    EndIf                                                               
		EndIf
	EndIf
EndIf

If !Empty(aCabNF)
	If cTipoNF $ "1|5" //nacional
		cString += NFSECabN(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cCAEA,cTipoNF)	                                                          
	ElseIf cTipoNF == "2"  //exportacao
		cString += NfseCab(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cTipo,cTipoNF)
	Elseif cTipoNF $ "3|7"  // reg. nominac
		cString += NfseCabR(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cTipo)
	Else //bono
		cString += NfseCabB(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cTipo)	
	EndIf	
		
EndIf

Return(cString)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfseCabR ºAutor  ³Camila Januário      º Data ³  19/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera string com conteúdo XML                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Elet. Argentina - Reg. Nominación     		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NfseCabR(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId, cTipo)

Local cString    := ""
Local Nx 		 := 0
Local cTpExp 	 := ""
Local nIb		 := 0
Local nIv		 := 0
Local nIBs		 := 0
local nIVa		 := 0
Local nExento	 := 0
Local nBasIva	 := 0
Local nImpSub 	 := 0
Local cCompVinc  := ""
Local nBasNoGrv	 := 0
Local nImpOTrib  := 0
Local nVlDesgr   := 0 
Local nLoop      := 0
Local dFchDesde  := CTOD("//")
Local dFchHasta  := CTOD("//")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o tipo de venda (bens serv, ambos)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If Alltrim(aPed[1])$"B|1"
	cTpExp:="1"  //produtos
ElseIf Alltrim(aPed[1])$"S|2"
	cTpExp:="2" //servicos
ElseIf Alltrim(aPed[1])$"A|3" //ambos
	cTpExp:="3"
Else 
	cTpExp:="4"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Faz a busca do valor exento no livro fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù

If Alias()$ ("SD1|SF1")
	nExento:= 0
   	SF3->(DbSetOrder(4))
   	If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
	 	While SF3->(!EOF()) .And. xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE ==;
  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
		  	nExento:=nExento + SF3->F3_EXENTAS
			SF3->(dbSkip())
		EndDo	
	EndIf		
Else
	nExento:= 0
   	SF3->(DbSetOrder(4))
   	If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
	 	While SF3->(!EOF()) .And. xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE ==;
  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
		  	nExento:=nExento + SF3->F3_EXENTAS
			SF3->(dbSkip())
		EndDo	
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte o valor de exento para a moeda da factura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCabNF[4] <> 1
	nExento:=nExento / aCabNF[4]
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula valores de IVA e de Importe Não Gravado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBasIva:=0
For nIv:=1 to Len(aIVA)
	nBasIva:= nBasIva + aIVA[nIv][2]
	If aIVA[nIv][4] == "1"
		nBasNoGrv += nBasIva
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula valores de IB - Otros Tributos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nImpOTrib:=0
For nIb:=1 to Len(aIB)
	nImpOTrib +=aIB[nIb][1] 
Next


nVlDesgr := ValDesgr(aIva,aColIVa)

nImpSub := nBasIva+nExento+nBasNoGrv 

If PARAMIXB[7] == "3"
  cString += '<comprobanteCAERequest>'
else
  cString += '<comprobanteCAEARequest>'
EndIf
If !Empty(cRG1415)
	cString += '<codigoTipoComprobante>'+AllTrim(cRG1415)+'</codigoTipoComprobante>'
Else
	cString += '<codigoTipoComprobante>'+CodComp(aCabNf)+'</codigoTipoComprobante>'
EndIf
cString += '<numeroPuntoVenta>'+aCabNF[2]+'</numeroPuntoVenta>'
cString += '<numeroComprobante>'+aCabNF[3]+'</numeroComprobante>'
cString += '<fechaEmision>'+alltrim(str(year(aCabNF[1])))+"-"+strzero(month(aCabNF[1]),2)+"-"+alltrim(str(day(aCabNF[1])))+'</fechaEmision>'

If PARAMIXB[7] == "7"
	DbSelectArea("CG6")
	CG6->(DbSetOrder(1))
	If CG6->(MsSeek(xFilial("CG6")+SF3->F3_FILIAL+PARAMIXB[8]))
		//Opcional: cString += '<codigoTipoAutorizacion>'+ 'XXXXXXXX' +'</codigoTipoAutorizacion>'
		cString += '<codigoAutorizacion>'+ CG6->CG6_CAEA  +'</codigoAutorizacion>'
		//Opcional: cString += '<fechaVencimiento>'+ CG6->CG6_FHCVAT +'</fechaVencimiento>'
	EndIf
EndIf

cString += '<codigoTipoDocumento>' + aDest[5] + '</codigoTipoDocumento>'
cString += '<numeroDocumento>' + aDest[3] + '</numeroDocumento>'

If cTipo == "1" 
	cString += '<importeGravado>'+ConvType(aCabNf[11]-(nVlDesgr+nExento),15,2)+'</importeGravado>' 
Else
	cString += '<importeGravado>'+ConvType(aCabNf[12]-(nVlDesgr+nExento) - aCabNf[13],15,2)+'</importeGravado>'     
EndIf
cString += '<importeNoGravado>'+ConvType(nBasNoGrv,15,2)+'</importeNoGravado>'
cString += '<importeExento>'+ConvType(nExento+nVlDesgr,15,2)+'</importeExento>'
cString += '<importeSubtotal>'+ConvType(nImpSub,15,2)+'</importeSubtotal>'
If Len(aIB) > 0
	cString += '<importeOtrosTributos>'+ConvType(nImpOTrib,15,2)+'</importeOtrosTributos>'  
EndIF	
cString += '<importeTotal>'+ConvType(aCabNF[5],15,2)+'</importeTotal>'
cString += '<codigoMoneda>'+ConvType(aPed[10],3,0)+'</codigoMoneda>'

If Alltrim(aPed[10]) == "PES"
	cString += '<cotizacionMoneda>'+"1"+'</cotizacionMoneda>'	
Else
	cString += '<cotizacionMoneda>'+Alltrim(STR(aCabNF[4]))+'</cotizacionMoneda>'
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Observacoes de pedido de venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aPed[6])
	cString += '<observaciones>'+aPed[6]+'</observaciones>'
EndIf   

cString += '<codigoConcepto>'+cTpExp+'</codigoConcepto>'
//If PARAMIXB[7] == "7" .And. (cTpExp $ "2|3")
//cString += '<fechaServicioDesde>'+ 'XXXXXXXX' +'</fechaServicioDesde>'
//cString += '<fechaServicioHasta>'+ 'XXXXXXXX' +'</fechaServicioHasta>'
//cString += '<fechaVencimientoPago>'+ 'XXXXXXXX' +'</fechaVencimientoPago>'
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Datas de início e fim do serviço são gerados se a nota for do tipo serviço/ambos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMiPyme:= .F.

If Alias()$ ("SD2|SF2")
	cEspec	:= AllTrim(SF2->F2_ESPECIE)
	dDataEmi:= SF2->F2_EMISSAO
	lMiPyme := Val(SF2->F2_RG1415) > 200
Else
	cEspec	:= AllTrim(SF1->F1_ESPECIE)
	dDataEmi:= SF1->F1_EMISSAO
	lMiPyme := Val(SF1->F1_RG1415) > 200
EndIf
If Alias()$ ("SD2|SF2")
	If Alltrim(aPed[1]) $ "S|A|2|3"
		cString += '<fechaServicioDesde>'+alltrim(str(year(SF2->F2_FECDSE)))+'-'+strzero(month(SF2->F2_FECDSE),2)+'-'+alltrim(strzero(day(SF2->F2_FECDSE),2))+'</fechaServicioDesde>'
		cString += '<fechaServicioHasta>'+alltrim(str(year(SF2->F2_FECHSE)))+'-'+strzero(month(SF2->F2_FECHSE),2)+'-'+alltrim(strzero(day(SF2->F2_FECHSE),2))+'</fechaServicioHasta>'
	EndIf
	cPrefixo := IIf (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal
	SE1->(dbSetOrder(2))

	If lMiPyme
		If Alltrim(SF2->F2_ESPECIE) == "NF"
			If SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SF2->F2_DOC))
					cString += '<fechaVencimientoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+'-'+strzero(month(SE1->E1_VENCREA),2)+'-'+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</fechaVencimientoPago>'
			Else
				cString += '<fechaVencimientoPago>'+alltrim(str(year(aCabNF[1])))+'-'+strzero(month(aCabNF[1]),2)+'-'+alltrim(strzero(day(aCabNF[1]),2))+'</fechaVencimientoPago>'
			EndIf
		EndIf
	Else
		If (Alltrim(aPed[1])$"S|A|2|3")
			If SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SF2->F2_DOC))
				cString += '<fechaVencimientoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+'-'+strzero(month(SE1->E1_VENCREA),2)+'-'+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</fechaVencimientoPago>'
			Else
				cString += '<fechaVencimientoPago>'+alltrim(str(year(aCabNF[1])))+'-'+strzero(month(aCabNF[1]),2)+'-'+alltrim(strzero(day(aCabNF[1]),2))+'</fechaVencimientoPago>'
			EndIf
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Considera notas de crédito/entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(aPed[1]) $ "S|A|2|3"
		cString += '<fechaServicioDesde>'+alltrim(str(year(SF1->F1_FECDSE)))+'-'+strzero(month(SF1->F1_FECDSE),2)+'-'+alltrim(strzero(day(SF1->F1_FECDSE),2))+'</fechaServicioDesde>'
		cString += '<fechaServicioHasta>'+alltrim(str(year(SF1->F1_FECHSE)))+'-'+strzero(month(SF1->F1_FECHSE),2)+'-'+alltrim(strzero(day(SF1->F1_FECHSE),2))+'</fechaServicioHasta>'
	EndIf

	cPrefixo := Iif(Empty (SF1->F1_PREFIXO), &(SuperGetMV ("MV_2DUPREF")), SF1->F1_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal
	SE1->(dbSetOrder(2))

	If lMiPyme
		If Alltrim(SF1->F1_ESPECIE) == "NF"
			If SE1->(MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC))
				cString += '<fechaVencimientoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+'-'+strzero(month(SE1->E1_VENCREA),2)+'-'+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</fechaVencimientoPago>'
			Else
				cString += '<fechaVencimientoPago>'+alltrim(str(year(aCabNF[1])))+'-'+strzero(month(aCabNF[1]),2)+'-'+alltrim(strzero(day(aCabNF[1]),2))+'</fechaVencimientoPago>'
			EndIf
		EndIf
	Else
		If Alltrim(aPed[1]) $ "S|A|2|3"
			If SE1->(MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC))
				cString += '<fechaVencimientoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+'-'+strzero(month(SE1->E1_VENCREA),2)+'-'+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</fechaVencimientoPago>'
			Else
				cString += '<fechaVencimientoPago>'+alltrim(str(year(aCabNF[1])))+'-'+strzero(month(aCabNF[1]),2)+'-'+alltrim(strzero(day(aCabNF[1]),2))+'</fechaVencimientoPago>'
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados de comprovantes associados (notas de credito e debito) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1 – Factura A         ³
//³2 – Nota de Débito A  ³
//³3 – Nota de Crédito A ³
//³6 – Factura B         ³
//³7 – Nota de Débito B  ³
//³8 – Nota de Crédito B ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

If (CodComp(aCabNf)) $ "2|3|7|8"	
	If Len(aNfVinc)>0
		cString += '<arrayComprobantesAsociados>'
			For Nx := 1 to Len(aNfVinc)			
				If (SUBS(Alltrim(aNfVinc[Nx][2]),1,1) == "A")
					If(Alltrim(aNfVinc[Nx][6]) == "NF")
						cCompVinc := "1"	
					Else
					    If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
					    	cCompVinc := "2"
					    Else
					        cCompVinc := "3"
					    EndIf    		
					EndIf
				Else
					If(Alltrim(aNfVinc[Nx][6]) == "NF")
						cCompVinc := "6"	
					Else
					    If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
					    	cCompVinc := "7"
					    Else
					        cCompVinc := "8"
					    EndIf    		
					EndIf				
				EndIf				
				cString += '<comprobanteAsociado>'
				cString += 		'<codigoTipoComprobante>'+AllTrim(aNFVinc[nX][7])+'</codigoTipoComprobante>'
				cString += '<numeroPuntoVenta>'+SUBS(aNfVinc[Nx][3],1,nTamPV)+'</numeroPuntoVenta>'
				cString += '<numeroComprobante>'+SUBS(aNfVinc[Nx][3],nTamPV+1,8)+'</numeroComprobante>'
				If lMiPyme
					cString += 		'<cuit>'+ AllTrim(aNfVinc[Nx][4])+'</cuit>'
				EndIf
				cString += 		'<fechaEmision>'+alltrim(str(year(aNfVinc[Nx][1])))+'-'+strzero(month(aNfVinc[Nx][1]),2)+'-'+alltrim(strzero(day(aNfVinc[Nx][1]),2))+'</fechaEmision>'	
				cString += '</comprobanteAsociado>'		
			Next	
		cString += '</arrayComprobantesAsociados>'
	EndIf
EndIF	
// periodoComprobantesAsociados

lMiPyme:= .F.
	
If  (( VAL(SF1->F1_RG1415) > 200  .and.  ( Alias()$ ("SD1|SF1"))) ; 
                      .OR. ( VAL(SF2->F2_RG1415) > 200  .and.  ( Alias()$ ("SD2|SF2"))) )
      lMiPyme:= .T.
EndIf	
If Alias()$ ("SD2|SF2")
	cEspec	:= AllTrim(SF2->F2_ESPECIE)	
	dDataEmi:= SF2->F2_EMISSAO
	If SF2->(ColumnPos("F2_FEFIHTA")) > 0 .And. SF2->(ColumnPos("F2_FEFIDDE")) > 0
		dFchDesde := SF2->F2_FEFIDDE
		dFchHasta := SF2->F2_FEFIHTA
	EndIf
Else
	cEspec	:= AllTrim(SF1->F1_ESPECIE)
	dDataEmi:= SF1->F1_EMISSAO
	If SF1->(ColumnPos("F1_FEFIHTA")) > 0 .And. SF1->(ColumnPos("F1_FEFIDDE")) > 0
		dFchDesde := SF1->F1_FEFIDDE
		dFchHasta := SF1->F1_FEFIHTA
	EndIf
Endif

If !lMiPyme .And. Subs(cEspec,1,2) $ "ND|NC" .And. Len(aNfVinc) == 0
	If !Empty(dFchDesde) .And. !Empty(dFchHasta)
		cString += '<periodoComprobantesAsociados>' 
		cString += '<fechaDesde>'+alltrim(str(year(dFchDesde)))+"-"+strzero(month(dFchDesde),2)+"-"+alltrim(strzero(day(dFchDesde),2))+'</fechaDesde>' 
		cString += '<fechaHasta>'+alltrim(str(year(dFchHasta)))+"-"+strzero(month(dFchHasta),2)+"-"+alltrim(strzero(day(dFchHasta),2))+'</fechaHasta>'      
		cString += '</periodoComprobantesAsociados>'
	Else
		cString += '<periodoComprobantesAsociados>' 
		cString += '<fechaDesde>'+alltrim(str(year(dDataEmi)))+"-"+strzero(month(dDataEmi),2)+"-"+alltrim(strzero(day(dDataEmi),2))+'</fechaDesde>' 
		cString += '<fechaHasta>'+alltrim(str(year(dDataEmi)))+"-"+strzero(month(dDataEmi),2)+"-"+alltrim(strzero(day(dDataEmi),2))+'</fechaHasta>'      
		cString += '</periodoComprobantesAsociados>'
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados de impostos Ingresos Brutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If Len(aIB) > 0
   	lPrim:=.T.
	For nIb:=1 to Len(aColIB)
           If Len(aColIB[nIB][2])>0
			If lPrim
			  	cString += '<arrayOtrosTributos>' 
	  	    EndIf   
	  	    lPrim:=.F.
	  		For nIBs:=1 to Len(aColIB[nIB][2])
		  		cString += '<otroTributo>' 
		 		cString += '<codigo>'+aColIB[nIB][3]+'</codigo>'
		 		If aColIB[nIB][3] <> "99"
		    		cString += '<descripcion>'+ConvType(aColIB[nIB][4],15,2)+'</descripcion>'
		    	EndIf
	    		cString += '<baseImponible>'+ConvType((aColIB[nIB][2][nIBs][3]*(1-(aColIB[nIB][2][nIBs][4]/100))),15,2)+'</baseImponible>' 	
	    		cString += '<importe>'+ConvType(aColIB[nIB][2][nIBs][2],15,2)+'</importe>'
	    		cString += '</otroTributo>' 
	    	Next	
	    EndIf	
	Next 
	If !lPrim	 
	   	cString += '</arrayOtrosTributos>'	
	EndIf
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens da factura ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += '<arrayItems>'
For Nx := 1 to Len(aProd)
		cString += '<item>'			
			If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97")
				cString += '<unidadesMtx>'+"1"+'</unidadesMtx>'
			   	cString += '<codigoMtx>'+Alltrim(aProd[Nx][08])+'</codigoMtx>' 
			EndIF
			cString += '<codigo>'+Alltrim(aProd[Nx][02])+'</codigo>'
			cString += '<descripcion>'+ConvType(Alltrim(aProd[Nx][03]))+'</descripcion>'
			cString += '<cantidad>'+ConvType(aProd[Nx][04],15,2)+'</cantidad>'		
			cString += '<codigoUnidadMedida>'+Alltrim(aProd[Nx][05])+'</codigoUnidadMedida>'
		   	
		   	If cTipo == "1" //saida
				If substr(_cSerie,1,1) == 'B' 
					cString += '<precioUnitario>'+ConvType((aProd[Nx][07]+aProd[Nx][09]+aProd[Nx][11])/aProd[Nx][04],15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>'	//somo o desconto e vejo se tem desgravacao ** Dante 4 decimales						
				else
					cString += '<precioUnitario>'+ConvType((aProd[Nx][06]+(if(aProd[Nx][09]>0, aProd[Nx][09]/aProd[Nx][04],aProd[Nx][09]))*(1-(aProd[Nx][14]/100))),15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>' 
				Endif	
			Else // Entrada - NCC
				If substr(_cSerie,1,1) == 'B' 
					cString += '<precioUnitario>'+ConvType((aProd[Nx][07]+aProd[Nx][11])/aProd[Nx][04],15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>'	//somo o desconto e vejo se tem desgravacao ** Dante 4 decimales						
				else				
					cString += '<precioUnitario>'+ConvType(aProd[Nx][06]*(1-(aProd[Nx][14]/100)),15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>' 
				endif	
			EndIf  			
			If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97") 					
				cString += '<importeBonificacion>'+ConvType(aProd[Nx][09],15,2)+'</importeBonificacion>'				
			EndIF			
			cString += '<codigoCondicionIVA>'+aProd[Nx][10]+'</codigoCondicionIVA>'			
			If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97") 
				If substr(_cSerie,1,1) <> 'B' 
					If (aProd[Nx][10] $ "4|5|6")
						cString += '<importeIVA>'+ConvType(aProd[Nx][11],15,2)+'</importeIVA>' //valimp
					Else
						cString += '<importeIVA>'+ConvType(0,15,2)+'</importeIVA>'
					EndIf
				EndIf		
			EndIf				
			If aProd[Nx][13] > 0		
					cString += '<importeItem>'+ConvType((aProd[Nx][13]*(1-(aProd[Nx][14]/100)))+aProd[Nx][11],15,2)+'</importeItem>'	//basimp-desgrav+valimp
			elseif aProd[Nx][10] == "2"
				cString += '<importeItem>'+ConvType(aProd[Nx][07],15,2)+'</importeItem>'
			Else
				cString += '<importeItem>'+ConvType(aProd[Nx][6],15,2)+'</importeItem>' //isento de iva
			Endif			
		
		cString += '</item>' 		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¤[¿
		//³Item que representa a desgravação de impostos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¤[Ù		
		IF	aProd[Nx][14] > 0
			cString += '<item>'			
				If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97")
					cString += '<unidadesMtx>'+"1"+'</unidadesMtx>'
				   	cString += '<codigoMtx>'+Alltrim(aProd[Nx][08])+'</codigoMtx>' 
				EndIF
				cString += '<codigo>'+Alltrim(aProd[Nx][02])+'</codigo>'
				cString += '<descripcion>'+ConvType(Alltrim(aProd[Nx][03]))+'</descripcion>'
				cString += '<cantidad>'+ConvType(aProd[Nx][04],15,2)+'</cantidad>'		
				cString += '<codigoUnidadMedida>'+Alltrim(aProd[Nx][05])+'</codigoUnidadMedida>'
				
				If cTipo == "1" 
					If substr(_cSerie,1,1) == 'B' 
						cString += '<precioUnitario>'+ConvType((aProd[Nx][07]+aProd[Nx][11])/aProd[Nx][04],15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>'	//somo o desconto e vejo se tem desgravacao ** Dante 4 decimales						
					else
						cString += '<precioUnitario>'+ConvType((aProd[Nx][06]+aProd[Nx][09])*(1-(aProd[Nx][14]/100)),15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>' 
					Endif	
				Else
					If substr(_cSerie,1,1) == 'B' 
						cString += '<precioUnitario>'+ConvType((aProd[Nx][07]+aProd[Nx][11])/aProd[Nx][04],15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>'	//somo o desconto e vejo se tem desgravacao ** Dante 4 decimales						
					else				
						cString += '<precioUnitario>'+ConvType(aProd[Nx][06]*(1-(aProd[Nx][14]/100)),15,IIf(aTamSx3Prc[2]=3,4,aTamSx3Prc[2]) )+'</precioUnitario>' 
					endif	
				EndIf  						
				If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97") 					
					cString += '<importeBonificacion>'+ConvType(aProd[Nx][09],15,2)+'</importeBonificacion>'				
				EndIF
				cString += '<codigoCondicionIVA>'+"2"+'</codigoCondicionIVA>' //exento				
				If (Alltrim(aProd[Nx][05]) <> "99" .or. Alltrim(aProd[Nx][05]) <> "97") 				
					cString += '<importeIVA>'+ConvType(0,15,2)+'</importeIVA>' //valimp				
				EndIf				
				cString += '<importeItem>'+ConvType((aProd[Nx][06]+aProd[Nx][09])*(aProd[Nx][14]/100),15,2)+'</importeItem>'
	   		cString += '</item>'		
		EndIf
					
Next
cString += '</arrayItems>'	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Dados de imposto IVA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
If Len(aColIVA)  >0
	lPrim:=.T.
	For nIv:=1 to Len(aColIVA)		
    	If Len(aColIVA[nIv][2])>0
			If lPrim
				cString += '<arraySubtotalesIVA>'
			EndIf
			lPrim:=.F.
			For nIVa:=1 To Len(aColIVA[nIv][2])
				cString += '<subtotalIVA>'
				cString += '<codigo>'+aColIVA[nIv][3]+'</codigo>'
				cString += '<importe>'+ConvType(aColIVA[nIv][2][nIVa][2],15,2)+'</importe>'      
		 		cString += '</subtotalIVA>'
			Next			
		EndIf	
	Next
	If !lPrim
		cString += '</arraySubtotalesIVA>'
	EndIf
EndIf
If lMiPyme
	cString += '<arrayDatosAdicionales>'
	If !(cEspec $ 'NCC|NDC')
		cString += 	'<datoAdicional>'
		cString += 		'<t>21</t>'
		cString += 		'<c1>' + SuperGetMv("MV_CCBUCFE",.F.," ") + '</c1>'
		cString += 	'</datoAdicional>'
	EndIf
	For nLoop := 1 To Len(aCposRG3668)
		cString += '<datoAdicional>'
		cString += aCposRG3668[nLoop]
		cString += '</datoAdicional>'
	Next

	cString += '</arrayDatosAdicionales>'
Else
	If Len(aCposRG3668) > 0
		cString += '<arrayDatosAdicionales>'
		For nLoop := 1 To Len(aCposRG3668)
			cString += '<datoAdicional>'
			cString += aCposRG3668[nLoop]
			cString += '</datoAdicional>'
		Next
		cString += '</arrayDatosAdicionales>'
	EndIf
EndIf
If PARAMIXB[7] == "3"
  cString += '</comprobanteCAERequest>'
else
  cString += '</comprobanteCAEARequest>'
EndIf

Return cString 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfseCabºAutor  ³Microsiga           º Data ³                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota fiscal eletr. Argentina - Exportação                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
    
Static Function NfseCab(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cTipo,cTipoNF)
Local cString := ""
Local Nx :=0
Local cTpExp:=""         
Local lVencto:=.F.
Local cPrefixo	:= ""
Local nPorAI0 	:= 0
Local cCodAI0	:= ""

Default cTipo:=""
Default cTipoNF  := "2"
 
If aPed[1] $ "B|1"
	cTpExp := "1"
ElseIf aPed[1] $ "S|2"
	cTpExp := "2"
Else
	cTpExp := "4"
EndIf
cString +='<Cmp>'
cString +='<Id>'+cUltId+'</Id>'
cString +='<fecha_cbte>'+alltrim(str(year(aCabNF[1])))+strzero(month(aCabNF[1]),2)+alltrim(str(day(aCabNF[1])))+'</fecha_cbte>'

if alltrim(aPed[2])=='NCC'
	cString += '<Tipo_cbte>21</Tipo_cbte>'
elseif alltrim(aPed[2])=='NDC'
	cString += '<Tipo_cbte>20</Tipo_cbte>'
elseif (alltrim(aPed[2])<>'NCC' .and. alltrim(aPed[2])<>'NDC')
	cString += '<Tipo_cbte>19</Tipo_cbte>'
	lVencto:=IIf(cTpExp $ "2|4",.T.,.F.)
endif
cString += '<Punto_vta>'+Alltrim(STR(Val(aCabNF[2])))+'</Punto_vta>'
cString += '<Cbte_nro>'+aCabNF[3]+'</Cbte_nro>'

cString += '<Tipo_expo>'+cTpExp+'</Tipo_expo>'
If (alltrim(aPed[2]) == "NDC" 	.Or. alltrim(aPed[2]) == "NCC") .Or. (alltrim(aPed[2]) == "NF" .And. cTpExp <> "1") 
	cString += '<Permiso_existente></Permiso_existente>'      
Else 
	cString += '<Permiso_existente>'+IiF(alltrim(aPed[2])=="NF" .and. cTpExp=="1",IIF(!Empty(aPed[8]),"S","N"),"")+'</Permiso_existente>'      
	If !Empty(aPed[8]) .and. cTpExp=="1"       
		cString += '<Permisos>'        
		cString += '<Permiso>'
			cString += '<Id_permiso>'+IIF(cTpExp=="1",aPed[8],"")+'</Id_permiso>'  
			cString += '<Dst_merc>'+IIF(cTpExp=="1",aPed[9],"")+'</Dst_merc>'    
		cString += '</Permiso>'      
		cString += '</Permisos>'    		
	EndIf	
Endif		
cString += '<Dst_cmp>'+aPed[9]+'</Dst_cmp>'
cString += '<Cliente>'+ConvType(aDest[2])+'</Cliente>'
cString += '<Cuit_pais_cliente>'+aDest[3]+'</Cuit_pais_cliente>'
cString += '<Domicilio_cliente>'+aDest[4]+'</Domicilio_cliente>'
cString += '<Moneda_Id>'+ConvType(aPed[10],3,0)+'</Moneda_Id>'
cString += '<Moneda_ctz>'+ConvType(aCabNF[4],10,6)+'</Moneda_ctz>'
If !Empty(aPed[6])
	cString += '<Obs_comerciales>'+aPed[6]+'</Obs_comerciales>'
EndIf
cString += '<Imp_total>'+ConvType(aCabNF[5],15,2)+'</Imp_total>'
cString += '<Obs></Obs>'
cString += Iif( cTipo=="2", RetCMPS(aNfVinc), "" )  
cString += '<Forma_pago>'+aPed[12]+'</Forma_pago>'
cString += '<Incoterms>'+Alltrim(aPed[7])+'</Incoterms>'
cString += '<Idioma_cbte>'+aPed[11]+'</Idioma_cbte>'

cString += '<Items>'

For Nx := 1 to Len(aProd)
	cString+= '<Item>'   
	cString += '<Pro_codigo>'+aProd[Nx][02]+'</Pro_codigo>'	
	cString += '<Pro_ds>'+ConvType(aProd[Nx][03])+'</Pro_ds>'
	cString += '<Pro_qty>'+ConvType(aProd[Nx][04],12,2)+'</Pro_qty>'
	cString+= '<Pro_umed>'+aProd[Nx][05]+'</Pro_umed>'
	cString += '<Pro_precio_uni>'+ConvType(aProd[Nx][06],12,3)+'</Pro_precio_uni>'
	if alltrim(aPed[2])=='NCC'
		cString += '<Pro_total_item>'+ConvType(aProd[Nx][07]+aProd[Nx][11]+aProd[Nx][12]+aProd[Nx][13]-aProd[Nx][9],14,3)+'</Pro_total_item>'
	else 
		cString += '<Pro_total_item>'+ConvType(aProd[Nx][07]+aProd[Nx][11]+aProd[Nx][12]+aProd[Nx][13],14,3)+'</Pro_total_item>'	
	endif
	cString += '</Item>'
Next
cString += '</Items>'

If  cTpExp == "1" .And. AI0->(ColumnPos("AI0_CODCON")) >0  .AND. AI0->(ColumnPos("AI0_PERCCO")) >0  .AND. AI0->(ColumnPos("AI0_CONDO")) >0 .And. ;
	( ( Alias()$ ("SD2|SF2")  .And. Alltrim(aPed[2])  $ 'NF|NDC') .Or. ( Alias()$ ("SD1|SF1")  .And. Alltrim(aPed[2])  $ 'NCC') )  
	nPorAI0 := Posicione("AI0",1,xFilial("AI0")+SF2->(F2_CLIENTE+F2_LOJA),'AI0_PERCCO')  
	cCodAI0 := Posicione("AI0",1,xFilial("AI0")+SF2->(F2_CLIENTE+F2_LOJA),'AI0_CODCON')
	If  nPorAI0 > 0 .And. !Empty(cCodAI0)
		cString += '<Compradores>'
		cString +=  '<comprador>'
		cString +=		'<codigoTipoDocumento>'
		cString +=		 	aDest[5]
		cString +=		'</codigoTipoDocumento>'
		cString += 		'<numeroDocumento>'
		cString += 			 aDest[3]
		cString += 		'</numeroDocumento>
		cString += 		'<porcentaje>' 
		cString +=  		ConvType(nPorAI0,5,2) 
		cString += 		'</porcentaje>'
		cString += 	 '</comprador>'
		cString +=    Comprador(cCodAI0,cTipoNF)
		cString += '</Compradores>'
	Endif
Endif

If lVencto 
	cPrefixo	:= 	Iif (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)
	If SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SF2->F2_DOC)) 
		cString += '<Fecha_pago>'+alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</Fecha_pago>'
	EndIf
EndIf

cString +='</Cmp>'

Return(cString)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvType ºAutor  ³Microsiga           º Data ³              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Converte tipos                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConvType(xValor,nTam,nDec)
Local cNovo := ""
DEFAULT nDec := 0
Default nTam := 60
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))
			cNovo := StrTran(cNovo,",",".")
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NoAcento ºAutor  ³Microsiga           º Data ³              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida acentos                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"
Local cEComer:= "&"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cEComer
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	 	nY:= At(cChar,cEComer)
	 	If nY > 0
			cString := StrTran(cString,cChar,SubStr("y",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyGetEnd  ³ Autor ³ Liber De Esteban             ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o participante e do DF, ou se tem um tipo de endereco ³±±
±±³          ³ que nao se enquadra na regra padrao de preenchimento de endereco  ³±±
±±³          ³ por exemplo: Enderecos de Area Rural (essa verificção e feita     ³±±
±±³          ³ atraves do campo ENDNOT).                                         ³±±
±±³          ³ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ³±±
±±³          ³ Endereco (sem numero ou complemento). Caso contrario ira retornar ³±±
±±³          ³ o padrao do FisGetEnd                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta funcao so pode ser usada quando ha um posicionamento de      ³±±
±±³          ³ registro, pois será verificado o ENDNOT do registro corrente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyGetEnd(cEndereco,cAlias)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}   

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(ColumnPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco)
EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfseCabN ºAutor  ³Microsiga           º Data ³              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota fiscal eletr. Argentina - Nacional                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NfseCabN(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId,cCAEA,cTipoNF)
Local cString := ""
Local cTpExp:=""
Local nIb	:=0
Local nIv	:=0
Local nIBs	:=0
local nIVa	:=0
Local nExento:= 0
Local nBasIva:= 0
Local nVlDesgr := 0                                                          
Local nLoop := 0       
Local Nx := 0                                                  
Local nTamPV:= TamSx3("F2_PV")[1]
Local nTamNF:= TamSx3("F2_DOC")[1]
Local nPorAI0 	:= 0
Local cCodAI0   := 0
Local dFchDesde  := CTOD("//")
Local dFchHasta  := CTOD("//")

Default cCAEA := "" 
Default cTipoNF  := "3" 


If Alltrim(aPed[1]) $"B|1"
	cTpExp:="1"  //produtos
ElseIf Alltrim(aPed[1]) $"S|2"
	cTpExp:="2" //servicos
ElseIf Alltrim(aPed[1]) $ "A|3"//ambos
	cTpExp:="3"
Else 
	cTpExp:="4"
EndIf

	nVlDesgr := ValDesgr(aIva,aColIVa)
	
	if cTipoNF == "5"
		cString +='<FECAEADetRequest>'
	else	
		cString +='<FECAEDetRequest>'			
	endif

	cString += '<Concepto>'+cTpExp+'</Concepto>' 
	cString += '<DocTipo>'+aDest[5]+'</DocTipo>'
	cString += '<DocNro>'+aDest[3]+'</DocNro>'
	cString += '<CbteDesde>'+Alltrim(str(Val(aCabNF[3])))+'</CbteDesde>'
	cString += '<CbteHasta>'+Alltrim(str(Val(aCabNF[3])))+'</CbteHasta>'
	cString += '<CbteFch>'+alltrim(str(year(aCabNF[1])))+strzero(month(aCabNF[1]),2)+alltrim(strzero(day(aCabNF[1]),2))+'</CbteFch>'
	cString += '<ImpTotal>'+ConvType(aCabNF[5],15,2)+'</ImpTotal>'
	
	If Alias()$ ("SD1|SF1")
		nExento:= 0
	   	SF3->(DbSetOrder(4))
	   	If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
  		 	While SF3->(!EOF()) .And. xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE ==;
 	  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
   			  	nExento:=nExento + SF3->F3_EXENTAS
				SF3->(dbSkip())
   			EndDo	
		EndIf
		
	Else
		nExento:= 0
	   	SF3->(DbSetOrder(4))
	   	If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
  		 	While SF3->(!EOF()) .And. xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE ==;
 	  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
   			  	nExento:=nExento + SF3->F3_EXENTAS
				SF3->(dbSkip())
   			EndDo	
		EndIf	
	EndIf	

	If aCabNF[4] <> 1
		nExento:=nExento / aCabNF[4]
	Endif                                                     

	nBasIva:=0
	For nIv:=1 to Len(aIVA)
		nBasIva:= nBasIva + aIVA[nIv][2]
	Next  
		
	cString += '<ImpTotConc>'+ConvType(nExento+nVlDesgr,15,2)+ '</ImpTotConc>'
	If Len(aIVA)  >0
		cString += '<ImpNeto>'+ConvType(nBasIva-nVlDesgr,15,2)+'</ImpNeto>'
	Else
		cString += '<ImpNeto>'+ConvType(0,15,2)+'</ImpNeto>'		
	EndIf      
	If Alias()$ ("SD2|SF2")
	If Left(SF2->F2_SERIE,1) == 'C'
		cString += '<ImpOpEx>'+ConvType(0,15,2)+'</ImpOpEx>'
	Else
		cString += '<ImpOpEx>'+ConvType(SF2->F2_VALMERC-(nBasIva+nExento)+ SF2->F2_DESPESA,15,2)+'</ImpOpEx>'
	EndIf
    Else
		cString += '<ImpOpEx>'+ConvType((SF1->F1_VALMERC-SF1->F1_DESCONT)-(nBasIva+nExento)+ SF1->F1_DESPESA,15,2)+'</ImpOpEx>'     
	Endif
	
	cString += '<ImpTrib>'+ConvType(aCabNF[6],15,2)+'</ImpTrib>' 
	cString += '<ImpIVA>'+ConvType(aCabNF[7],15,2)+'</ImpIVA>'
	
	If Alltrim(aPed[1])$"S|A|2|3" .And. Alias()$ ("SD2|SF2")
		cString += '<FchServDesde>'+alltrim(str(year(SF2->F2_FECDSE)))+strzero(month(SF2->F2_FECDSE),2)+alltrim(strzero(day(SF2->F2_FECDSE),2))+'</FchServDesde>' 
		cString += '<FchServHasta>'+alltrim(str(year(SF2->F2_FECHSE)))+strzero(month(SF2->F2_FECHSE),2)+alltrim(strzero(day(SF2->F2_FECHSE),2))+'</FchServHasta>' 
	EndIf    
		cPrefixo	:= 	Iif (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal
		SE1->(dbSetOrder(2))
		
	If (Alltrim(aPed[1])$"S|A|2|3" .And. Alias()$ ("SD2|SF2") )   .or.  (Alltrim(aPed[1])$"1|2" .And. Alias()$ ("SD2|SF2")  .and. VAL(SF2->F2_RG1415) >200  .and. Alltrim(SF2->F2_ESPECIE)=="NF" )
		If   (VAL(SF2->F2_RG1415) <200	.And. Alltrim(SF2->F2_ESPECIE)=="NF")  .Or.   VAL(SF2->F2_RG1415) >=200 
			If Alias()$"SF2|SD2" .And. SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SF2->F2_DOC)) 
				cString += '<FchVtoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</FchVtoPago>'
			Else
				cString += '<FchVtoPago>'+alltrim(str(year(aCabNF[1])))+strzero(month(aCabNF[1]),2)+alltrim(strzero(day(aCabNF[1]),2))+'</FchVtoPago>'
			EndIf
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        
	//³Considera notas de crédito/entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Alltrim(aPed[1])$"S|A|2|3" .And. Alias()$ ("SD1|SF1")
		cString += '<FchServDesde>'+alltrim(str(year(SF1->F1_FECDSE)))+strzero(month(SF1->F1_FECDSE),2)+alltrim(strzero(day(SF1->F1_FECDSE),2))+'</FchServDesde>' 
		cString += '<FchServHasta>'+alltrim(str(year(SF1->F1_FECHSE)))+strzero(month(SF1->F1_FECHSE),2)+alltrim(strzero(day(SF1->F1_FECHSE),2))+'</FchServHasta>' 
	Endif   
		cPrefixo	:= 	Iif (Empty (SF1->F1_PREFIXO), &(SuperGetMV ("MV_2DUPREF")), SF1->F1_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal
		SE1->(dbSetOrder(2))
	 If (Alltrim(aPed[1])$"S|A|2|3" .And. Alias()$ ("SD1|SF1") ) 
		If  ( VAL(SF1->F1_RG1415) < 200   )       .Or.      (Alltrim(aPed[1])$"1|2" .And.   VAL(SF1->F1_RG1415) >= 200    )    //  .and. (Alias() $ "SF1|SD1")) 
			If Alias()$"SF1|SD1" .And. SE1->(MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC)) 
					cString += '<FchVtoPago>'+alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</FchVtoPago>'
			Else
					cString += '<FchVtoPago>'+alltrim(str(year(aCabNF[1])))+strzero(month(aCabNF[1]),2)+alltrim(strzero(day(aCabNF[1]),2))+'</FchVtoPago>'
			EndIf
		EndIf	
	EndIf
	
	
	
	cString += '<MonId>'+ConvType(aPed[10],3,0)+'</MonId>'
	cString += '<MonCotiz>'+ConvType(aCabNF[4],10,6)+'</MonCotiz>'	
	//Associados
	lMiPyme:= .F.
	lRG1415:= .F.
	If  (( VAL(SF1->F1_RG1415) > 200  .and.  ( Alias()$ ("SD1|SF1"))) ; 
	                      .OR. ( VAL(SF2->F2_RG1415) > 200  .and.  ( Alias()$ ("SD2|SF2"))) )
       lMiPyme:= .T.
	EndIf	
	If Len(aNfVinc)>0
		cString += '<CbtesAsoc>'
		For Nx := 1 to Len(aNfVinc)			
				
			If len(aNfVinc[Nx])>=7 .and. !Empty(aNfVinc[Nx][7])
				cCompVinc:= aNfVinc[Nx][7]
				lRG1415:= .T.
				
			EndIf
				
			If !lRG1415 .And.  (SUBS(Alltrim(aNfVinc[Nx][2]),1,1) == "A")
				If(Alltrim(aNfVinc[Nx][6]) == "NF")
					cCompVinc := "201"	
				Else
					If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
						cCompVinc := "202"
					Else
						cCompVinc := "203"
					EndIf    		
				EndIf
			ElseIf !lRG1415 
				If(Alltrim(aNfVinc[Nx][6]) == "NF")
					cCompVinc := "206"	
				Else
					If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
						cCompVinc := "207"
					Else
						cCompVinc := "208"
					EndIf    		
				EndIf				
			EndIf				
			cString += '<CbteAsoc>'
			cString += '<Tipo>'+cCompVinc+'</Tipo>'
			cString += '<PtoVta>'+SUBS(aNfVinc[Nx][3],1,nTamPV)+'</PtoVta>'
			cString += '<Nro>'+SUBS(aNfVinc[Nx][3],nTamPV+1,(nTamNf - nTamPV))+'</Nro>'
			cString += '<Cuit>'+ AllTrim(aNfVinc[Nx][4])+'</Cuit>'
			cString += '<CbteFch>'+alltrim(str(year(aNfVinc[Nx][1])))+strzero(month(aNfVinc[Nx][1]),2)+alltrim(strzero(day(aNfVinc[Nx][1]),2))+'</CbteFch>'
			cString += '</CbteAsoc>'		
			If lMiPyme
				Nx :=  Len(aNfVinc)
			EndIf			
		Next	
		cString += '</CbtesAsoc>'
		
	EndIf

	If Alias()$ ("SD2|SF2")
		cEspec := AllTrim(SF2->F2_ESPECIE)
		dDataEmi:= SF2->F2_EMISSAO
		If SF2->(ColumnPos("F2_FEFIHTA")) > 0 .And. SF2->(ColumnPos("F2_FEFIDDE")) > 0
			dFchDesde := SF2->F2_FEFIDDE
			dFchHasta := SF2->F2_FEFIHTA
		EndIf
    Else
		cEspec := AllTrim(SF1->F1_ESPECIE)
		dDataEmi:= SF1->F1_EMISSAO
		If SF1->(ColumnPos("F1_FEFIHTA")) > 0 .And. SF1->(ColumnPos("F1_FEFIDDE")) > 0
			dFchDesde := SF1->F1_FEFIDDE
			dFchHasta := SF1->F1_FEFIHTA
		EndIf
	Endif

	If Len(aIB)  >0
      	lPrim:=.T.
		For nIb:=1 to Len(aColIB)
            If Len(aColIB[nIB][2])>0
				If lPrim
				  	cString += '<Tributos>'
		  	    EndIf   
		  	    lPrim:=.F.
		  		For nIBs:=1 to Len(aColIB[nIB][2])
			  		cString += '<Tributo>'
			 		cString += '<Id>'+aColIB[nIB][3]+'</Id>'
			    	cString += '<Desc>'+ConvType(aColIB[nIB][4],15,2)+'</Desc>'
		    		cString += '<BaseImp>'+ConvType(aColIB[nIB][2][nIBs][3]*(1-(aColIB[nIB][2][nIBs][4]/100)),15,2)+'</BaseImp>'
			    	cString += '<Alic>'   +ConvType(aColIB[nIB][2][nIBs][1],15,2)+'</Alic>'
		    		cString += '<Importe>'+ConvType(aColIB[nIB][2][nIBs][2],15,2)+'</Importe>'
		    		cString += '</Tributo>'
		    	Next	
		    EndIf	
		Next 
		If !lPrim	 
		   	cString += '</Tributos>'
		EndIf
	EndIf
	If Len(aColIVA)  >0
		lPrim:=.T.
		For nIv:=1 to Len(aColIVA) 
             If Len(aColIVA[nIv][2])>0
				If lPrim
					cString += '<Iva>'
				EndIf
				lPrim:=.F.
				For nIVa:=1 To Len(aColIVA[nIv][2])
		   			cString += '<AlicIva>'
					cString += '<Id>'+aColIVA[nIv][3]+'</Id>'
					cString += '<BaseImp>'+ConvType(aColIVA[nIv][2][nIVa][3]*(1-(aColIva[nIv][2][nIVa][4]/100)),15,2)+'</BaseImp>'
					cString += '<Importe>'+ConvType(aColIVA[nIv][2][nIVa][2],15,2)+'</Importe>'      
		 			cString += '</AlicIva>'
				Next		
			
			EndIf	
		Next
		If !lPrim
			cString += '</Iva>'
		EndIf
	EndIf	
	
	If   VAL(SF1->F1_RG1415) > 200  .and.  ( Alias()$ ("SD1|SF1"))  .or.  VAL(SF2->F2_RG1415) > 200  .and.  ( Alias()$ ("SD2|SF2"))
	  
		cString += '<Opcionales>'    
		If (cEspec $ 'NCC|NDC')
			cString += '<Opcional>'
           	cString += '<Id>22</Id>     	
           	If Alias()$ ("SD1|SF1") .And.  SF1->(ColumnPos("F1_TPAJUS")) >0 .And. SF1->F1_TPAJUS=="R"
           		cString += '<Valor>S</Valor>'
           	Else
           		cString += '<Valor>N</Valor>'
           	EndIf
			cString += '</Opcional>'   
		Else // es factura y solo en este comprobante se informa CBU
			If !Empty(aDest[7])
				cString += 	'<Opcional>'
				cString += 		'<Id>2101</Id>'
				cString += 		'<Valor>' + aDest[7] + '</Valor>'
				cString += 	'</Opcional>'
			EndIf
			If !Empty(aDest[6])
				cString += '<Opcional>'
				cString += 		'<Id>27</Id>
				cString += 		'<Valor>' + aDest[6] + '</Valor>'
				cString += '</Opcional>'
			EndIf
		EndIf
		
		For nLoop := 1 To Len(aCposRG3668) 
			cString += '<Opcional>'
			cString += aCposRG3668[nLoop]
			cString += '</Opcional>'
		Next
		
		cString += '</Opcionales>'
	Else
		If Len(aCposRG3668) > 0
			cString += '<Opcionales>' 
			For nLoop := 1 To Len(aCposRG3668) 
				cString += '<Opcional>'
				cString += aCposRG3668[nLoop]
				cString += '</Opcional>'
			Next
			cString += '</Opcionales>'
		EndIf	
		
	EndIf
	
	If  cTpExp == "1" .And.  AI0->(ColumnPos("AI0_CODCON")) >0  .AND. AI0->(ColumnPos("AI0_PERCCO")) >0 .And. AI0->(ColumnPos("AI0_CONDO")) >0 .And. ;
	    ( ( Alias()$ ("SD2|SF2")  .And. cEspec $ 'NF|NDC') .Or. ( Alias()$ ("SD1|SF1")  .And. cEspec $ 'NCC') ) 			
		nPorAI0 := Posicione("AI0",1,xFilial("AI0")+SF2->(F2_CLIENTE+F2_LOJA),'AI0_PERCCO')  
		cCodAI0 := Posicione("AI0",1,xFilial("AI0")+SF2->(F2_CLIENTE+F2_LOJA),'AI0_CODCON')
		If  nPorAI0 > 0 .And. !Empty(cCodAI0) 
			cString += '<Compradores>'
			cString +=  '<Comprador>'
			cString +=		 '<DocTipo>'
			cString +=		 	aDest[5]
			cString +=		 '</DocTipo>'
			cString += 		 '<DocNro>'
			cString += 			 aDest[3] 
			cString += 		 '</DocNro>
			cString += 		'<Porcentaje>' 
			cString +=  		ConvType(nPorAI0,5,2) 
			cString += 		'</Porcentaje>'
			cString += 	 '</Comprador>'
			cString += 	 Comprador(cCodAI0,cTipoNF)
			cString += '</Compradores>'
		Endif  
	Endif
		
If !lMiPyme .And. Subs(cEspec,1,2) $ "ND|NC" .And. Len(aNfVinc) == 0
	If !Empty(dFchDesde) .And. !Empty(dFchHasta)
		cString += '<PeriodoAsoc>' 
		cString += '<FchDesde>'+alltrim(str(year(dFchDesde)))+strzero(month(dFchDesde),2)+alltrim(strzero(day(dFchDesde),2))+'</FchDesde>' 
		cString += '<FchHasta>'+alltrim(str(year(dFchHasta)))+strzero(month(dFchHasta),2)+alltrim(strzero(day(dFchHasta),2))+'</FchHasta>'      
		cString += '</PeriodoAsoc>'
	Else
		cString += '<PeriodoAsoc>' 
		cString += '<FchDesde>'+alltrim(str(year(dDataEmi)))+strzero(month(dDataEmi),2)+alltrim(strzero(day(dDataEmi),2))+'</FchDesde>' 
		cString += '<FchHasta>'+alltrim(str(year(dDataEmi)))+strzero(month(dDataEmi),2)+alltrim(strzero(day(dDataEmi),2))+'</FchHasta>'      
		cString += '</PeriodoAsoc>'
	EndIf
EndIf

if cTipoNF == "5"
	cString +=  '<CAEA>'+Alltrim(cCAEA)+'</CAEA>'
	cString +='</FECAEADetRequest>'
else
	cString +='</FECAEDetRequest>'
endif	

Return(cString)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfseCabBºAutor  ³Camila Januário       º Data ³  02/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera string com conteúdo XML                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Elet. Argentina - Reg. Bienes de Capital - Bonoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NfseCabB(aCabNf,aDest,aPed,aProd,aNfVinc,cUltId, cTipo)

Local cString    := ""
Local Nx 		 := 0
Local nTamPV     := TamSx3("F2_PV")[1]
Local nTamNF     := TamSx3("F2_DOC")[1]
Local cTpExp 	 := ""
Local nIb		 := 0
Local nIv		 := 0
Local nIBs		 := 0
local nIVa		 := 0
Local nExento	 := 0
Local nBasIva	 := 0
Local nImpSub 	 := 0
Local cCompVinc  := ""
Local nBasNoGrv	 := 0
Local nImpOTrib  := 0
Local nVlDesgr   := 0
Local aNfeImp 	 := {}
Local cBonTS	 := SuperGetMv("MV_BONUSTS",,"")
Local lBnTs	     := .F.
Local cTes		 := ""
Local lRG1415    := .F.
Local cEspec     :=IIF(Alias()$ ("SD2|SF2"), AllTrim(SF2->F2_ESPECIE), AllTrim(SF1->F1_ESPECIE))
Local lMiPyme    := cRG1415 != Nil .And. VAL(cRG1415) > 200 .And. (Alias()$ ("SD2|SF2") .Or. Alias()$ ("SD1|SF1"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Faz a busca do valor exento no livro fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
If Alias()$ ("SD1|SF1")
	nExento:= 0
   	SF3->(DbSetOrder(4))
   	If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
	 	While SF3->(!EOF()) .And. xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE ==;
  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
		  	nExento:=nExento + SF3->F3_EXENTAS
			SF3->(dbSkip())
		EndDo	
	EndIf		
Else
	nExento:= 0
   	SF3->(DbSetOrder(4))
   	If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
	 	While SF3->(!EOF()) .And. xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE ==;
  			SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
		  	nExento:=nExento + SF3->F3_EXENTAS
			SF3->(dbSkip())
		EndDo	
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte o valor de exento para a moeda da factura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCabNF[4] <> 1
	nExento:=nExento / aCabNF[4]
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula valores de IVA e de Importe Não Gravado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBasIva := 0
For nIv:=1 to Len(aIVA)
	nBasIva:= nBasIva + aIVA[nIv][2]
	If aIVA[nIv][4] == "1"
		nBasNoGrv += nBasIva
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula valores de IB - Otros Tributos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nImpOTrib:=0
For nIb:=1 to Len(aIB)
	nImpOTrib +=aIB[nIb][1] //importe
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca valores de desgravação do IVA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlDesgr := ValDesgr(aIva,aColIVa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Busca valores de impostos: Nacionais, Internos, Municipais, 		   ³
//³Ganancias, IIB e IVA 
// Retorno:	aRet(nImpLiq,nImpLiqRNI,nImpPerc,nImpIIBB,nImpMun,nImpInt) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
aNfeImp := NfeTotImp(cTipo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(¿
//³Cabeçalho e dados da factura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(Ù
cString += '<Cmp>'
cString += '<Id>'+Str(nLastID+1)+'</Id>'
cString += '<Tipo_doc>'+aDest[5]+'</Tipo_doc>'
cString += '<Nro_doc>'+aDest[3]+'</Nro_doc>'
cString += '<Zona>'+"1"+'</Zona>'
cString += '<Tipo_cbte>'+RetTpCbte(aCabNF)+'</Tipo_cbte>'
cString += '<Punto_vta>'+aCabNF[2]+'</Punto_vta>'
cString += '<Cbte_nro>'+aCabNF[3]+'</Cbte_nro>'
cString += '<Imp_total>'+ConvType(aCabNF[5],15,2)+'</Imp_total>' 
cString += '<Imp_tot_conc>'+ConvType(nExento+nVlDesgr,15,2)+'</Imp_tot_conc>'  
If Len(aIVA)  >0 
	cString += '<Imp_neto>'+ConvType(nBasIva-nVlDesgr,15,2)+'</Imp_neto>' 
Else
	cString += '<Imp_neto>'+ConvType(0,15,2)+'</Imp_neto>' 
Endif
cString += '<Impto_liq>'+ConvType(aNfeImp[1],15,2)+'</Impto_liq>' 
cString += '<Impto_liq_rni>'+ConvType(aNfeImp[2],15,2)+'</Impto_liq_rni>' 
cString += '<Imp_op_ex>'+ConvType(nExento+nVlDesgr,15,2)+'</Imp_op_ex>' 
cString += '<Imp_perc>'+ConvType(aNfeImp[3],15,2)+'</Imp_perc>' 
cString += '<Imp_iibb>'+ConvType(aNfeImp[4],15,2)+'</Imp_iibb>'
cString += '<Imp_perc_mun>'+ConvType(aNfeImp[5],15,2)+'</Imp_perc_mun>'
cString += '<Imp_internos>'+ConvType(aNfeImp[6],15,2)+'</Imp_internos>'

cString += '<Imp_moneda_Id>'+ConvType(aPed[10],3,0)+'</Imp_moneda_Id>'
If Alltrim(aPed[10]) == "PES"
	cString += '<Imp_moneda_ctz>'+"1"+'</Imp_moneda_ctz>'
Else
    cString += '<Imp_moneda_ctz>'+Alltrim(STR(aCabNF[4]))+'</Imp_moneda_ctz>'
Endif
cString += '<Fecha_cbte>'+alltrim(str(year(aCabNF[1])))+strzero(month(aCabNF[1]),2)+alltrim(strzero(day(aCabNF[1]),2))+'</Fecha_cbte>'
If lMiPyme
	SE1->(dbSetOrder(2))
	If Alias()$ ("SD2|SF2") .And. cEspec == "NF"
		cPrefixo := Iif (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)
		If SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SF2->F2_DOC)) 
			cString += '<Fecha_vto_pago>'+alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))+'</Fecha_vto_pago>'
		EndIf
	EndIf

	cString += '<Opcionales>'    
	If (cEspec $ 'NCC|NDC')
		cString += '<Opcional>'
		cString += '<Id>22</Id>'
		If Alias()$ ("SD1|SF1") .And.  SF1->(ColumnPos("F1_TPAJUS")) >0 .And. SF1->F1_TPAJUS=="R"
			cString += '<Valor>S</Valor>'
		Else
			cString += '<Valor>N</Valor>'
		EndIf
		cString += '</Opcional>'   
	Else // es factura y solo en este comprobante se informa CBU
		If !Empty(aDest[7])
			cString += 	'<Opcional>'
			cString += 		'<Id>2101</Id>'
			cString += 		'<Valor>' + aDest[7] + '</Valor>'
			cString += 	'</Opcional>'
		EndIf
		If !Empty(aDest[6])
			cString += '<Opcional>'
			cString += 		'<Id>27</Id>'
			cString += 		'<Valor>' + aDest[6] + '</Valor>'
			cString += '</Opcional>'
		EndIf
	EndIf	
	cString += '</Opcionales>'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens da factura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += '<Items>'
For Nx := 1 to Len(aProd)
	cTes:= aProd[Nx][19]
	lBnTs := cTes $ cBonTS
	cString += '<Item>'	
		cString += '<Pro_codigo_ncm>'+Alltrim(aProd[Nx][15])+'</Pro_codigo_ncm>'		
		cString += '<Pro_ds>'+ConvType(Alltrim(aProd[Nx][03]))+'</Pro_ds>'
		cString += '<Pro_qty>'+ConvType(aProd[Nx][04],15,2)+'</Pro_qty>'
		cString += '<Pro_umed>'+Alltrim(aProd[Nx][05])+'</Pro_umed>'
		If cTipo == "1" 
			cString += '<Pro_precio_uni>'+ConvType(Iif(lBnTs,aProd[Nx][06],(aProd[Nx][06]+(aProd[Nx][09]/aProd[Nx][04]))*(1-(aProd[Nx][14]/100))),15,2)+'</Pro_precio_uni>'
		Else  
			cString += '<Pro_precio_uni>'+ConvType(aProd[Nx][06]*(1-(aProd[Nx][14]/100)),15,2)+'</Pro_precio_uni>'
		Endif	
		cString += '<Imp_bonif>'+ConvType(aProd[Nx][09],15,2)+'</Imp_bonif>'
		If (aProd[Nx][13] > 0 .Or. aProd[Nx][14] >0 .Or. aProd[Nx][11] >0)
			cString += '<Imp_total>'+ConvType((aProd[Nx][13]*(1-(aProd[Nx][14]/100))),15,2)+'</Imp_total>'
		Else
			cString += '<Imp_total>'+ConvType(aProd[Nx][7],15,2)+'</Imp_total>'
		Endif
		cString += '<Iva_id>'+aProd[Nx][10]+'</Iva_id>'
	cString += '</Item>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¤[¿
	//³Item que representa a desgravação de impostos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¤[Ù		
	IF	aProd[Nx][14] > 0
		cString += '<Item>'	
			cString += '<Pro_codigo_ncm>'+Alltrim(aProd[Nx][15])+'</Pro_codigo_ncm>'		
			cString += '<Pro_ds>'+ConvType(Alltrim(aProd[Nx][03]))+'</Pro_ds>'
			cString += '<Pro_qty>'+ConvType(aProd[Nx][04],15,2)+'</Pro_qty>'
			cString += '<Pro_umed>'+Alltrim(aProd[Nx][05])+'</Pro_umed>'
			If cTipo == "1" 
				cString += '<Pro_precio_uni>'+ConvType((aProd[Nx][06]+aProd[Nx][09])*(1-(aProd[Nx][14]/100)),15,2)+'</Pro_precio_uni>'
			Else
				cString += '<Pro_precio_uni>'+ConvType(aProd[Nx][06]*(1-(aProd[Nx][14]/100)),15,2)+'</Pro_precio_uni>'
			Endif	
			cString += '<Imp_bonif>'+ConvType(aProd[Nx][09],15,2)+'</Imp_bonif>'
			cString += '<Imp_total>'+ConvType((aProd[Nx][06]+aProd[Nx][09])*(aProd[Nx][14]/100),15,2)+'</Imp_total>'
			cString += '<Iva_id>'+aProd[Nx][10]+'</Iva_id>'
   		cString += '</Item>'		
	EndIf
Next				
cString += '</Items>'
If Len(aNfVinc)>0
	cString += '<CbtesAsoc>'
	For Nx := 1 to Len(aNfVinc)	

	If len(aNfVinc[Nx])>=7 .and. !Empty(aNfVinc[Nx][7])
			cCompVinc:= aNfVinc[Nx][7]
			lRG1415:= .T.		
	EndIf	
	If !lRG1415 .And.  (SUBS(Alltrim(aNfVinc[Nx][2]),1,1) == "A")
		If(Alltrim(aNfVinc[Nx][6]) == "NF")
			cCompVinc := "201"	
		Else
			If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
				cCompVinc := "202"
			Else
				cCompVinc := "203"
			EndIf    		
		EndIf
	ElseIf !lRG1415 
		If(Alltrim(aNfVinc[Nx][6]) == "NF")
			cCompVinc := "206"	
		Else
			If (Alltrim(aNfVinc[Nx][6]) $ "NDC|NDP|NDE|NDI")
				cCompVinc := "207"
			Else
				cCompVinc := "208"
			EndIf    		
		EndIf				
	EndIf				
	cString += '<CbteAsoc>'
	cString += '<Tipo_cbte>'+cCompVinc+'</Tipo_cbte>'
	cString += '<Punto_vta>'+SUBS(aNfVinc[Nx][3],1,nTamPV)+'</Punto_vta>'
	cString += '<Cbte_nro>'+SUBS(aNfVinc[Nx][3],nTamPV+1,(nTamNf - nTamPV))+'</Cbte_nro>'
	cString += '<Cuit>'+ AllTrim(aNfVinc[Nx][4])+'</Cuit>'
	cString += '<Fecha_cbte>'+alltrim(str(year(aNfVinc[Nx][1])))+strzero(month(aNfVinc[Nx][1]),2)+alltrim(strzero(day(aNfVinc[Nx][1]),2))+'</Fecha_cbte>'
	cString += '</CbteAsoc>'		
	If lMiPyme
		Nx :=  Len(aNfVinc)
	EndIf			
	Next	
	cString += '</CbtesAsoc>'
EndIf
cString += '</Cmp>'

Return cString

                                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpostosºAutor  ³Microsiga           º Data ³               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Impostos(cTipoNF)  
Local nAliq:= 0
Local cFiltroIf:=""


/*
	  	1P-IB
		2I-Imp. Interno
		5M-Imp Municipal
		3P-Imp IVA

*/
cFiltroIf := 'SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"1P"  '
cFiltroIf :=cFiltroIf +'.Or. SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"2I" ' 
cFiltroIf :=cFiltroIf +'.Or. SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"3P" '
If cTipoNF $ "1|3|7"
	cFiltroIf :=cFiltroIf +'.Or. SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"5P" ' 
EndIf

DbSelectArea("SFB") 
SFB->(DBGOTOP()) 
While !SFB->(EOF()) 
	If &cFiltroIf
		If SFB->FB_CLASSE<>"R"
			IF(LEN(SFB->FB_CPOLVRO)<>0) 
				nAliq:=SFB->FB_ALIQ
				If Len(aColIB)<>0 
					If  AScan( aColIB, { |x| x[1] == SFB->FB_CPOLVRO } ) ==0   
						AADD(aColIB,{SFB->FB_CPOLVRO,{},ALLTRIM(SFB->FB_CODAFIP),SFB->FB_DESCR,SFB->FB_TIPO,SFB->FB_CLASSE,SFB->FB_CLASSIF}) 
			        EndIf
				Else 
					AADD(aColIB,{SFB->FB_CPOLVRO,{},ALLTRIM(SFB->FB_CODAFIP),SFB->FB_DESCR,SFB->FB_TIPO,SFB->FB_CLASSE,SFB->FB_CLASSIF}) 
				EndIf
			Endif  
		Endif 
	ElseIf SFB->FB_FILIAL+SFB->FB_CLASSIF+SFB->FB_CLASSE==xFilial("SFB")+"3I"  //IVA 
		cColIVA   :=SFB->FB_CPOLVRO 
		IF(LEN(SFB->FB_CPOLVRO)<>0)         
			If Len(aColIVA)<>0 
				If  AScan( aColIVA, { |x| x[1] == SFB->FB_CPOLVRO } ) ==0   
					AADD(aColIVA,{SFB->FB_CPOLVRO,{},ALLTRIM(SFB->FB_CODAFIP),SFB->FB_DESCR,SFB->FB_TIPO,SFB->FB_CLASSE,SFB->FB_CLASSIF}) 
		        EndIf
			Else 
				AADD(aColIVA,{SFB->FB_CPOLVRO,{},ALLTRIM(SFB->FB_CODAFIP),SFB->FB_DESCR,SFB->FB_TIPO,SFB->FB_CLASSE,SFB->FB_CLASSIF}) 
			EndIf
		Endif              
	Endif 
	SFB->(DBSkip()) 
Enddo 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CodCompºAutor  ³Camila Januário     º Data ³  21/07/11      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o código do comprovante válido pela AFIP          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Eletr. Reg. Nominación                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CodComp(aNF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1 – Factura A         ³
//³2 – Nota de Débito A  ³
//³3 – Nota de Crédito A ³
//³6 – Factura B         ³
//³7 – Nota de Débito B  ³
//³8 – Nota de Crédito B ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCod := "" 

	If (Alltrim(aNF[10]) == "NF") .OR. (Alltrim(aNF[11]) == "NF")  
		If (SUBS(Alltrim(aNF[9]),1,1)== "A") .OR. (SUBS(Alltrim(aNF[10]),1,1)== "A")  
		    cCod := "1"
		Else
			cCod := "6"	
		EndIf
	Else
		If (SUBS(Alltrim(aNF[9]),1,1) == "A") .OR. (SUBS(Alltrim(aNF[10]),1,1) == "A")		
			If (Alltrim(aNF[11]) $ "NDC|NDP|NDE|NDI") .OR. (Alltrim(aNF[10]) $ "NDC|NDP|NDE|NDI")
				cCod := "2"
			Else
				cCod := "3"
			EndIf
		Else
			If (Alltrim(aNF[11]) $ "NDC|NDP|NDE|NDI") .OR. (Alltrim(aNF[10]) $ "NDC|NDP|NDE|NDI")
				cCod := "7"
			Else
				cCod := "8"	
			EndIF		
		EndIf	
	EndIf

Return cCod

                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValDesgr ºAutor  ³Camila Januário      º Data ³  01/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula valor de isento quando há desgravação de impostos  º±±
±±º          ³                                                   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Eletrônica - Argentina                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValDesgr(aIva,aColIVa)

Local nDesgr := 0
Local nIv
Local nIva

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
//³Obtem valor de desgravação de IVA caso D2/D1_DESGR for maior que 0    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ
If Len(aColIVA)  > 0
	For nIv:=1 to Len(aColIVA) 
	    If Len(aColIVA[nIv][2])>0		
			For nIVa:=1 To Len(aColIVA[nIv][2])
            	If aColIVA[nIv][2][nIVa][4] > 0
	  				nDesgr += aColIVA[nIv][2][nIVa][3]-(aColIVA[nIv][2][nIVa][3]*(1-(aColIVA[nIv][2][nIVa][4]/100)))
            	EndIf
			Next				
		EndIf	
	Next
EndIf                                         

Return nDesgr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetTpCbteºAutor  ³Camila Januário      º Data ³  09/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o tipo de comprovante                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nfe Argentina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetTpCbte(aNF)
Local cCbte := "" 
Local lRG200 := cRG1415 != Nil .And. VAL(cRG1415)>200

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno os tipos de comprovantes com seus codigos respectivos³
//³aceitos pela AFIP                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If (Subs(Alltrim(aNF[9]),1,1)== "A") .OR. (Subs(Alltrim(aNF[10]),1,1)== "A") //serie A 

	If ((Alltrim(aNF[10]) == "NF") .OR. (Alltrim(aNF[11]) == "NF")) 
		cCbte := IIF(lRG200,"201","01")
	Elseif ((Alltrim(aNF[10]) $ "NDC|NDI") .OR. (Alltrim(aNF[11]) $ "NDC|NDI")) 
			cCbte :=  IIF(lRG200,"202","02")		
    Elseif ((Alltrim(aNF[10]) $ "NCC|NCI") .OR. (Alltrim(aNF[11]) $ "NCC|NCI"))  
    		cCbte :=  IIF(lRG200,"203","03")
    Else
    	cCbte := "39"
    Endif
Elseif (Subs(Alltrim(aNF[9]),1,1)== "B") .OR. (Subs(Alltrim(aNF[10]),1,1)== "B") //serie B

	If ((Alltrim(aNF[10]) == "NF") .OR. (Alltrim(aNF[11]) == "NF")) 
		cCbte :=  IIF(lRG200,"206","06")
	Elseif ((Alltrim(aNF[10]) $ "NDC|NDI") .OR. (Alltrim(aNF[11]) $ "NDC|NDI")) 
			cCbte :=  IIF(lRG200,"207","07")		
	Elseif ((Alltrim(aNF[10]) $ "NCC|NCI") .OR. (Alltrim(aNF[11]) $ "NCC|NCI")) 
	  		cCbte :=  IIF(lRG200,"208","08")
	Else
	   	cCbte := "40"
	Endif	
Endif

Return cCbte 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfeTotImpºAutor  ³Camila Januário      º Data ³  15/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca totais de impostos Municipais, Internos, Ganancias,  º±±
±±º          ³ Iva, Ingresos Brutos                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Factura eletrônica                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function NfeTotImp(cTip)

Local aRet := {}
Local nImpLiq:=nImpLiqRNI:=nImpPerc:=nImpIIBB:=nImpMun:=nImpInt:=0
Local aImpIVA := {}
Local aImpGAN := {}
Local aImpIIBB := {}
Local aImpMUN  := {}
Local aImpINT  := {} 
Local lCliente := IIF(cTip=="1",.T.,.F.)
Local cAlias := IIF(cTip=="1","SF2->F2","SF1->F1")
Local aArea := GetArea()

DbSelectArea("SFB") 
SFB->(DBGOTOP()) 
While !SFB->(EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impto_Liq = Nacional, Imposto e IVA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	 
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"NI3" 
	   	IF (LEN(SFB->FB_CPOLVRO)<>0)
	   		cCpoLvr:= SFB->FB_CPOLVRO	   		
			nImpLiq += &(cAlias+"_VALIMP"+cCpoLvr)				
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impto_Liq_RNI = Nacional, Percep e IVA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"NP3" 
	   	IF(LEN(SFB->FB_CPOLVRO)<>0)
	   		cCpoLvr:= SFB->FB_CPOLVRO
            If lCliente
	            DbSelectArea("SA1")
	            DbSetOrder(1)
	            If MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
					If SA1->A1_TIPO == "S"
						nImpLiqRNI +=  &(cAlias+"_VALIMP"+cCpoLvr)
					Endif				
				Endif
			Endif	
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imp_Perc = Nacional, Percep e IVA ou Ganancias	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 	
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"NP3" ;	   	
		.OR. SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"NP4" 
	   	IF(LEN(SFB->FB_CPOLVRO)<>0)
	   		cCpoLvr:= SFB->FB_CPOLVRO
            If lCliente
	            DbSelectArea("SA1")
	            DbSetOrder(1)
	            If MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
					If SA1->A1_TIPO <> "S"
						nImpPerc +=  &(cAlias+"_VALIMP"+cCpoLvr)
					Endif				
				Endif
			Else
			    DbSelectArea("SA2")
	            DbSetOrder(1)
	            If MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
					If SA2->A2_TIPO <> "S"
						nImpPerc +=  &(cAlias+"_VALIMP"+cCpoLvr)
					Endif				
				Endif			
			Endif	
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imp_IIBB = Provincia, Percep e Ingresos Brutos	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"PP1" 
		If !Empty(SFB->FB_CPOLVRO)
	   		cCpoLvr:= SFB->FB_CPOLVRO	   		
			nImpIIBB += &(cAlias+"_VALIMP"+cCpoLvr)				
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imp_perc_mun = Municipal, Percep e Municipais	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 	
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"MP5" 
		If !Empty(SFB->FB_CPOLVRO)
	   		cCpoLvr:= SFB->FB_CPOLVRO	   		
			nImpMun += &(cAlias+"_VALIMP"+cCpoLvr)				
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imp_perc_mun = Nacional, Imposto e Interno		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
	If SFB->FB_FILIAL+SFB->FB_TIPO+SFB->FB_CLASSE+SFB->FB_CLASSIF==xFilial("SFB")+"NI2" 
		If !Empty(SFB->FB_CPOLVRO)
	   		cCpoLvr:= SFB->FB_CPOLVRO	   		
			nImpInt += &(cAlias+"_VALIMP"+cCpoLvr)				
		Endif		
	Endif
	SFB->(DBSkip()) 
Enddo										

aadd(aRet,nImpLiq)
aadd(aRet,nImpLiqRNI)
aadd(aRet,nImpPerc)
aadd(aRet,nImpIIBB)
aadd(aRet,nImpMun)
aadd(aRet,nImpInt)

RestArea(aArea) 

Return aRet


//------------------------------------------------------------------------
/*/{Protheus.doc} AfipCode
Função que retorna o código da AFIP conforme tabe OC, do SX5.

@param cCadCode		Código da tabela do cadastro do Cliente ou Fornecedor
						Campo A1/A2_AFIP
		
@return cCadCode		Código da AFIP encontrado na tabela SX5.

@author Rafael Iaquinto
@since 13/11/2013
@version 10.8
/*/
//------------------------------------------------------------------------

Static Function AfipCode(cCadCode)

Local cAfipCode	:= "80"
Local aAreaSX5 := SX5->(GetArea())

Default cCadCode := "1"

SX5->( dbSetOrder(1) )

If SX5->( MsSeek(xFilial("SX5")+"OC"+cCadCode) )
	cAfipCode := SubStr(X5DESCRI(),1,2)
endIf

RestArea(aAreaSX5)

Return cAfipCode
/*Agregar valores opcionales para RG3668*/
Static Function ObtCposRG3668

Local cCBU:=""

If ColumnPos("F2_ADIC5") > 0  .and. !Empty(SF2->F2_ADIC5) 
		   
	aAdd(aCposRG3668, '<Id>5</Id>' + '<Valor>'+ Alltrim(SF2->F2_ADIC5) +'</Valor>')

EndIf
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetCMPS   ºAutor  ³Alberto Nunes       º Data ³  29/03/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o CMPS referente aos comprovantes vinculados para NCC º±±
±±º          ³ Ref. DMICNS-5954                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Elet. Argentina - Reg. Nominación     		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±                                                                                                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function RetCMPS(aNfVinc)  // DMICNS-5954 - Retornar Bloco CMPS_ASOC Obrigatorio para NCC

Local cStr := ""
Local aNF  := {}
Local nX:=0
Local nTamPV:= TamSx3("F2_PV")[1]

For nX := 1 To Len(aNfVinc)
	If   Ascan(aNF, { |x| x[2] == aNfVinc[nX,2] .AND. x[3] == aNfVinc[nX,3] } ) == 0
		Aadd(aNF, { aNfVinc[nX,1] , aNfVinc[nX,2] , aNfVinc[nX,3] , aNfVinc[nX,4] , aNfVinc[nX,5] , aNfVinc[nX,6] , aNfVinc[nX,7] } )  // Emissao , Serie , Doc , M0_CGC , EstCob , Especie, RG1415 
	EndIf
Next nX

If Len(aNF) > 0    .AND.    (    (   Alias()$ ("SD1|SF1") .and.     AllTrim(SF1->F1_ESPECIE) $ "NCC"      )   .Or.    (    Alias()$ ("SD2|SF2" )  .And.     AllTrim(SF2->F2_ESPECIE) $ "NDC"   )  ) // Especie do Doc deve ser igual a NDC
	
	cStr += "<Cmps_asoc>"
	
	For nx := 1 To Len(aNF)
		cStr += "<Cmp_asoc>"
		cStr += "<CBte_tipo>" + aNF[nX,7] + "</CBte_tipo>"  // No Manual esta como <Cbte_tipo> mas no webservice consta <CBte_tipo>
		cStr += "<Cbte_punto_vta>" + AllTrim(Str(Val( Substr(aNF[nX,3],1,nTamPV) ))) + "</Cbte_punto_vta>"
		cStr += "<Cbte_nro>" + Substr(aNF[nX,3],nTamPV+1,Len(aNF[nX,3])-nTamPV) + "</Cbte_nro>"
		cStr += "<Cbte_cuit>" + AllTrim(aNF[nX,4]) + "</Cbte_cuit>"
		cStr += "</Cmp_asoc>"	
	Next nx
	
	cStr += "</Cmps_asoc>"

EndIf
	
Return(cStr )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Comprador   ºAutor  ³Laura M.         º Data ³  17/08/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera el nodo referente a Compradores.                    º±±
±±º          ³ DMICNS-9489                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nota Fiscal Elet. Argentina - Reg. Compradores   		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±                                                                                                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function Comprador(cCodAI0,cTipoNF) 
Local cStr  	:= ""
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local lRet 		:= .T. 
Local cAliasQry	:= GetNextAlias()
Local lCmpA1Afip:= SA1->(ColumnPos("A1_AFIP")) > 0  

Default cTipoNF := 3

cQuery := "SELECT A1_CGC, A1_AFIP, AI0_PERCCO "
cQuery += "FROM "+RetSqlName("SA1")+" SA1, "+RetSqlName("AI0")+" AI0 "
cQuery += "WHERE SA1.A1_COD = AI0.AI0_CODCLI "
cQuery += "AND SA1.A1_LOJA = AI0.AI0_LOJA "
cQuery += "AND AI0_FILIAL = '" + xFilial("AI0") + "' "
cQuery += "AND A1_FILIAL  = '" + xFilial("SA1") + "' "
cQuery += "AND SA1.D_E_L_E_T_ = ' '  "
cQuery += "AND AI0.D_E_L_E_T_ = ' '  "
cQuery += "AND AI0_CONDO = '2' AND AI0_CODCON = '"+cCodAI0+"' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
DbSelectArea(cAliasQry)

While (cAliasQry)->(!Eof())
	If  cTipoNF $ "1|5" //nacional
		cStr +=  '<Comprador>'
		cStr +=		'<DocTipo>'
		cStr +=		 	 Iif(lCmpA1Afip, AfipCode((cAliasQry)->A1_AFIP) ,AfipCode("1"))
		cStr +=		'</DocTipo>'
		cStr += 	'<DocNro>'
		cStr += 		 Alltrim((cAliasQry)->A1_CGC) 
		cStr += 	'</DocNro>
		cStr += 	'<Porcentaje>' 
		cStr +=  		ConvType((cAliasQry)->AI0_PERCCO,5,2) 
		cStr += 	'</Porcentaje>'
		cStr +=  '</Comprador>'	
	Elseif cTipoNF == "2"  //exportacao
		cStr +=  '<comprador>'
		cStr +=		'<codigoTipoDocumento>'
		cStr +=		 	 Iif(lCmpA1Afip, AfipCode((cAliasQry)->A1_AFIP) ,AfipCode("1"))
		cStr +=		'</codigoTipoDocumento>'
		cStr += 	'<numeroDocumento>'
		cStr += 		 Alltrim((cAliasQry)->A1_CGC) 
		cStr += 	'</numeroDocumento>
		cStr += 	'<porcentaje>' 
		cStr +=  		ConvType((cAliasQry)->AI0_PERCCO,5,2) 
		cStr += 	'</porcentaje>'
		cStr +=  '</comprador>'		
	Endif
	(cAliasQry)->(DbSkip())
EndDo


(cAliasQry)->(DbCloseArea())
RestArea(aArea) 	

Return(cStr)


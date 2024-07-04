#include "MATIDI.CH"
#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MTGerFSB1()
Função que cria o arquivo XML de Produtos para integração com o DI
 
@return Booleano, caso tenha gerado o arquivo retorna .T. senão .F.  
@author Matheus Lando Raimundo
@since 01/05/2014
@version P12
/*/
//-------------------------------------------------------------------
Function MTGerFSB1()
Local cDiretorio	:= SuperGetMv("MV_LJNEOUT",.F.,"")  
Local cNumDoc 		:= SuperGetMv("MV_DOCINTDI",.F.,"000000001")
Local cQuery		:= "%%"
Local cQueryPE 	:= ""
Local lRet 		:= .T.
Local nHandle		:= ""
Local nArq			:= 0
Local cTime 		:= Time()
Local cNomeArqPr	:= ""
Local cData		:= ""
Local cAtivo		:= ""
Local cAliasSB1	:= GetNextAlias()

If MTIVParams(cNumDoc, @cDiretorio)
	DbSelectArea("SA2")
	DbSetOrder(1)
	
	/* Exemplo da criação do Ponte de Entrada
	User Function MTGrSB1Fil()

	Return '% AND SB1.B1_COD = ' + "'" +  '001' + "'%"
	*/
				
	If ExistBlock("MTGrSB1Fil")
		cQueryPE := ExecBlock("MTGrSB1Fil")
		If Valtype(cQueryPE) == "C" .And. !Empty(cQueryPE)	
			cQuery := cQueryPE
		EndIf 
	EndIf
				
	BeginSQL Alias cAliasSB1
		SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_PROC, SB1.B1_LOJPROC, SB1.B1_CODBAR, SB1.B1_QE, SB1.B1_PRV1, SB1.B1_DESC, SB1.B1_ATIVO 
		FROM %table:SB1% SB1
	   	
	   		RIGHT JOIN %table:SB5% SB5 ON  
					SB1.B1_FILIAL = SB5.B5_FILIAL AND 
					SB1.B1_COD = SB5.B5_COD
		WHERE SB1.B1_FILIAL  = %xfilial:SB1%
			AND SB5.B5_INTDI = '2'
			AND SB1.%NotDel%
			AND SB5.%NotDel%	
			AND SUBSTRING(SB1.B1_COD,1,3) <> 'MOD' 
			AND SB1.B1_GCCUSTO = ' ' 
			AND SB1.B1_CCCUSTO = ' '
			%exp:cQuery%									
	EndSQL
		
	If (cAliasSB1)->(!Eof())				 		
		cTime 		:= Stuff( Time(), 3, 1, "")
		cTime 		:= Stuff( cTime, 5, 1, "")
		cData		:= DtoS(Date()) + Substr(cTime, 1, Len(cTime) - 2)
					
		cNomeArqPr := cDiretorio +  "RELPRO_" +  SM0->M0_CGC +  "_"  + cData + ".xml"
		
		If Ferror() # 0 .And. nArq = -1
			Help('',1, "MATIGRVARQ",,STR0001 +  STR(Ferror()) ,1)	//"Erro de Gravacao do Arquivo :"
			lRet := .F.
		Endif
		
		If lRet 
			If File(cNomeArqPr)
				nHandle := Ferase(cNomeArqPr)
			EndIf
	
			nHandle := MSFCREATE(cNomeArqPr, 0)
		
			fWrite(nHandle, "<?xml version='1.0' encoding='ISO-8859-1'?>")
			fWrite(nHandle, "<int xmlns='Produto'>")
								
			fWrite(nHandle, "<RegisterType>01</RegisterType>" )
			fWrite(nHandle, "<Identification>RELPRO</Identification>") 		
			fWrite(nHandle, "<Version>050</Version>")
			fWrite(nHandle, "<ReportNumber>" + cNumDoc + "</ReportNumber>")			
			fWrite(nHandle, "<DocumentDateTime>" + cData + "</DocumentDateTime>")		
			fWrite(nHandle, "<IssuingCNPJ>"+SM0->M0_CGC+"</IssuingCNPJ>")
			fWrite(nHandle, "<ReceiverCNPJ>03887830009046</ReceiverCNPJ>")											
			fWrite(nHandle, "<Itens>")
			
			While (cAliasSB1)->(!Eof()) .And. xFilial("SB1") == (cAliasSB1)->B1_FILIAL	
				If SB5->( DbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD) )
								
					fWrite(nHandle, "<Item>")
						
					fWrite(nHandle, "<RegisterType>02</RegisterType>")				
							
					If SA2->(DbSeek( xFilial("SA2")+ (cAliasSB1)->B1_PROC + (cAliasSB1)->B1_LOJPROC ))
						fWrite(nHandle, "<SupplierCNPJ>" + SA2->A2_CGC + "</SupplierCNPJ>")
					Else
						fWrite(nHandle, "<SupplierCNPJ> </SupplierCNPJ>" )
					EndIf
						
					fWrite(nHandle, "<ItemCode>" + (cAliasSB1)->B1_COD + "</ItemCode>")
					fWrite(nHandle, "<ProductCode>" + (cAliasSB1)->B1_CODBAR + "</ProductCode>")
					fWrite(nHandle, "<ItemType>1</ItemType>")					
					fWrite(nHandle, "<QuantityPerPackage>" + Str((cAliasSB1)->B1_QE) + "</QuantityPerPackage>")
					fWrite(nHandle, "<SellPrice>" + Str((cAliasSB1)->B1_PRV1) + "</SellPrice>")		
					fWrite(nHandle, "<ItemInternalDescription>" + (cAliasSB1)->B1_DESC + "</ItemInternalDescription>")
					
					If (cAliasSB1)->B1_ATIVO == 'S'					
						cAtivo := '01'
					ElseIf (cAliasSB1)->B1_ATIVO == 'N'
						cAtivo := '02'
					EndIf				
										
					fWrite(nHandle, "<ProductStatus>" + cAtivo + "</ProductStatus>")
						
					fWrite(nHandle, "</Item>")
											
					RecLock("SB5",.F.)
					SB5->B5_INTDI = "1"
					SB5->(MsUnlock())					
				EndIf			
							
				(cAliasSB1)->(DbSkip())									
			EndDo
			
			fWrite(nHandle, "</Itens>")
			fWrite(nHandle, "</int>")
			FClose(nHandle)
			cNumDoc := Soma1(cNumDoc)
			PutMv( "MV_DOCINTDI" , cNumDoc )																
		EndIf
	Else
		lRet := .F.											
	EndIf					
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTGerFSB2()
Função que cria o arquivo XML de Estoque para integração com o DI
 
@return Booleano, caso tenha gerado o arquivo retorna .T. senão .F.  
@author Matheus Lando Raimundo
@since 01/05/2014
@version P12
/*/
//-------------------------------------------------------------------
Function MTGerFSB2()
Local cDiretorio	:= SuperGetMv("MV_LJNEOUT",.F.,"")  
Local cNumDoc 		:= SuperGetMv("MV_DOCINTDI",.F.,"000000001")
Local cQuery		:= "%%"
Local cQueryPE 	:= ""
Local lRet 		:= .T.
Local nHandle		:= ""
Local nArq			:= 0
Local cTime 		:= Time()
Local cNomeArqPr	:= ""
Local cData		:= ""
Local nSomaSld		:= 0
Local cAliasSB1	:= GetNextAlias()

If MTIVParams(cNumDoc, @cDiretorio)		
	/* Exemplo da criação do Ponte de Entrada
	User Function MTGrSB2Fil()

	Return '% AND SB1.B1_COD = ' + "'" +  '001' + "'%"
	*/
	If ExistBlock("MTGrSB2Fil")
		cQueryPE := ExecBlock("MTGrSB2Fil")
		If Valtype(cQueryPE) == "C" .And. !Empty(cQueryPE)
			cQuery := cQueryPE
		EndIf 
	EndIf
				
	BeginSQL Alias cAliasSB1		
		SELECT SB1.B1_FILIAL, SB1.B1_COD, SB2.B2_COD, SB2.B2_QATU, SB2.B2_STATUS, SB2.B2_QEMP, SB2.B2_QEMPPRJ, SB2.B2_LOCAL, 
					SB2.B2_RESERVA, SB2.B2_QACLASS, SB2.B2_QEMPSA, SB2.B2_QTNP, SB2.B2_QEMPN, SB2.B2_QNPT
		FROM %table:SB1% SB1
	   		RIGHT JOIN %table:SB2% SB2 ON  
					SB1.B1_FILIAL = SB2.B2_FILIAL AND 
					SB1.B1_COD	    = SB2.B2_COD
		WHERE SB1.B1_FILIAL = %xfilial:SB1%			
			AND SB1.%NotDel%
			AND SB2.%NotDel%	
			AND SUBSTRING(SB1.B1_COD,1,3) <> 'MOD' 
			AND SB1.B1_GCCUSTO = ' ' 
			AND SB1.B1_CCCUSTO = ' '			
			%exp:cQuery%									
	EndSQL
		
	If (cAliasSB1)->(!Eof())				
		cTime 		:= Stuff( Time(), 3, 1, "")
		cTime 		:= Stuff( cTime, 5, 1, "")
		cData		:= DtoS(Date()) + Substr(cTime, 1, Len(cTime) - 2)
				
		cNomeArqPr := cDiretorio +  "RELEST_03887830009046_" + SM0->M0_CGC + "_"  + cData + ".xml"
		
		IF Ferror() # 0 .And. nArq = -1
			Help('',1, "MATIGRVARQ",,STR0001 +  STR(Ferror()) ,1)	
			lRet := .F.
		Endif
		
		If lRet 
			If File(cNomeArqPr)
				nHandle := Ferase(cNomeArqPr)
			EndIf
	
			nHandle := MSFCREATE(cNomeArqPr, 0)
		
			fWrite(nHandle, "<?xml version='1.0' encoding='ISO-8859-1'?>")
			fWrite(nHandle, "<int xmlns='Estoque'>")
			
			fWrite(nHandle, "<RegisterType>01</RegisterType>") 
			fWrite(nHandle, "<Identification>RELEST</Identification>") 		
			fWrite(nHandle, "<Version>050</Version>")
			fWrite(nHandle, "<ReportNumber>" + cNumDoc + "</ReportNumber>")
			fWrite(nHandle, "<DocumentDateTime>" + cData + "</DocumentDateTime>")
			fWrite(nHandle, "<StockStartDate>"+  cData + "</StockStartDate>")
			fWrite(nHandle, "<StockFinalDate>"+  cData + "</StockFinalDate>")			
			fWrite(nHandle, "<IssuingCNPJ>"+SM0->M0_CGC+"</IssuingCNPJ>")
			fWrite(nHandle, "<ReceiverCNPJ>03887830009046</ReceiverCNPJ>")		
												
			fWrite(nHandle, "<Itens>")
											
			While (cAliasSB1)->(!Eof())	
				nSomaSld := 0
				cCodProd := (cAliasSB1)->B1_COD
																										
				While (cAliasSB1)->(!Eof()) .And. (cAliasSB1)->B1_COD == cCodProd														
					DbSelectArea(cAliasSB1)	
					nSomaSld += SaldoSB2(,,,,,cAliasSB1)														 															
					(cAliasSB1)->(DbSkip())
				EndDo									
				
																									
				fWrite(nHandle, "<Item>")
				fWrite(nHandle, "<RegisterType>02</RegisterType>")
				fWrite(nHandle, "<DateTime>" + cData + "</DateTime>")																							
				fWrite(nHandle, "<ItemCode>" + cCodProd + "</ItemCode>")				
				fWrite(nHandle, "<StockAmount>" + Str(nSomaSld) + "</StockAmount>")
				
				fWrite(nHandle, "<TransitionStockAmount>" + Str(MTSldTrans(cCodProd))  + "</TransitionStockAmount>")										
				fWrite(nHandle, "</Item>")																													
			EndDo
			
			fWrite(nHandle, "</Itens>")
			fWrite(nHandle, "</int>")
			FClose(nHandle)
			cNumDoc := Soma1(cNumDoc)
			PutMv( "MV_DOCINTDI" , cNumDoc )																
		EndIf
	Else
		lRet := .F.						
	EndIf					
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTSldTrans()
Função para retornar o saldo em trânsito de um produto
 
@return Númerico  
@author Matheus Lando Raimundo
@since 07/05/2014
@version P12
/*/
//-------------------------------------------------------------------
Function MTSldTrans(cProduto)
Local nSaldo := 0

BeginSQL Alias "TMPTRANS"
	SELECT SB2.B2_COD,SUM(SB2.B2_QATU) AS SLDTRANS
	FROM	%Table:SB2% SB2
	WHERE	SB2.B2_COD = %Exp:cProduto% AND
			SB2.B2_FILIAL = %Exp:xFilial("SB2")% AND
			SB2.B2_LOCAL = %Exp:GetMvNNR('MV_LOCTRAN','95')% AND 
			SB2.B2_STATUS <> '2' AND 
			SB2.%NotDel%
	GROUP BY SB2.B2_COD
EndSql

BeginSQL Alias "TMPTRANS2"	
	SELECT SD2.D2_COD,SUM(SD2.D2_QUANT) TRANSITO
	FROM %Table:SD2% SD2,%Table:SF4% SF4,%Table:SD1% SD1
	WHERE 	SF4.%NotDel% AND
			SD1.%NotDel% AND
			SD2.%NotDel% AND
	      	SD2.D2_TES = SF4.F4_CODIGO AND
	      	SF4.F4_FILIAL = %Exp:xFilial("SF4")% AND
	        SF4.F4_ESTOQUE = 'S' AND
	        SF4.F4_TRANFIL = '1' AND
	        SD1.D1_FILIAL = %Exp:xFilial("SD1")% AND
	        SD1.D1_DOC = SD2.D2_DOC AND
	        SD1.D1_SERIE = SD2.D2_SERIE AND
	        SD1.D1_COD = SD2.D2_COD AND
	        SD1.D1_TES = '   ' AND
			SD2.D2_FILIAL <> %Exp:xFilial("SD2")% AND
	      	SD2.D_E_L_E_T_ <> '*' AND
	      	SD2.D2_COD = %Exp:cProduto%
	GROUP BY SD2.D2_COD	
EndSql

nSaldo := TMPTRANS->SLDTRANS + TMPTRANS2->TRANSITO

TMPTRANS->(dbCloseArea())
TMPTRANS2->(dbCloseArea())

Return nSaldo


//-------------------------------------------------------------------
/*/{Protheus.doc} MTIVParams()
Função para validar os parâmetros da integração
 
@return Booleano  
@author Matheus Lando Raimundo
@since 07/05/2014
@version P12
/*/
//-------------------------------------------------------------------
Function MTIVParams(cNumDoc, cDiretorio)
Local lRet 		:= .T.

If Empty(cDiretorio)
	Help('',1,'MATILJNEOUT')	
	lRet := .F.
EndIf

If lRet .And. !ExistDir(cDiretorio) .And. MakeDir(cDiretorio) <> 0
	Help('',1,'MATINDIR')		
	lRet := .F.	
EndIf

If lRet .And. Empty(cNumDoc)
	Help('',1,'MATINUMDOC')	
	lRet := .F.
EndIf

If lRet 	
	If SubStr(cDiretorio, Len(cDiretorio))  <> '\'
		cDiretorio += '\'		
	EndIf
EndIf

Return lRet
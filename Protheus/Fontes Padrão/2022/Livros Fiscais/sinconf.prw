#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Sinconf   ºAutor  ³Andressa Ataides    º Data ³ 16/05/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Itens Mestre Mercadorias/Servicos -SAIDAS e ENTRADAS-       º±±
±±º          ³ Notas Canceladas - 4.3.2                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SincoNF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SincoNf(cNrLivro)
          
	Local cAliasSFT	:=	"SFT"
	Local aStruS02	:= {}	// Saidas
	Local aStruE02	:= {}  // Entradas
	Local cArqS02	:= ""
	Local cArqE02	:= ""
	Local cArqSft	:= ""
	Local aArea		:=	GetArea ()
	
	#IFDEF TOP  // Verificando as variaveis utilizadas em cada ambiente (TOP/CODBASE)
		Local nX		:= 0
		Local aStruSFT	:= {}
		Local lQuery	:= .F.
	#ENDIF


    //SAIDAS                              
	AADD(aStruS02,{"MOV"   	,"C",001,0})
	AADD(aStruS02,{"MOD"	,"C",002,0})
	AADD(aStruS02,{"SERIE"	,"C",005,0})
	AADD(aStruS02,{"NF"		,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruS02,{"EMISS"	,"D",008,0})
	AADD(aStruS02,{"ITEM"	,"C",003,0})
	AADD(aStruS02,{"CODMER"	,"C",020,0})
	AADD(aStruS02,{"DESMER"	,"C",045,0})
	AADD(aStruS02,{"CODCFO"	,"C",004,0})
	AADD(aStruS02,{"CODCLA"	,"C",008,0})
	AADD(aStruS02,{"QUANT"	,"N",017,3})
	AADD(aStruS02,{"UNITAR"	,"N",017,4})
	AADD(aStruS02,{"TOTAL"	,"N",017,2})
	AADD(aStruS02,{"DESC"	,"N",017,2})
	AADD(aStruS02,{"IPI"	,"C",001,0})
	AADD(aStruS02,{"ALIPI"	,"N",005,2})
	AADD(aStruS02,{"BSIPI"	,"N",017,2})
	AADD(aStruS02,{"VLIPI"	,"N",017,2})
	AADD(aStruS02,{"ICMS"	,"C",001,0})
	AADD(aStruS02,{"ALICM"	,"N",005,2})
	AADD(aStruS02,{"BSICM"	,"N",017,2})
	AADD(aStruS02,{"VLICM"	,"N",017,2})
	AADD(aStruS02,{"VLSUB"	,"N",017,2})
	AADD(aStruS02,{"ICMSUB"	,"N",017,2})
	AADD(aStruS02,{"ESTOQ"	,"C",001,0})
	//
	cArqS02	:=	CriaTrab(aStruS02)
	dbUseArea(.T.,__LocalDriver,cArqS02,"S02")
	IndRegua("S02",cArqS02,"NF+SERIE+CODCFO")

    //ENTRADAS
	AADD(aStruE02,{"MOV"   	,"C",001,0})
	AADD(aStruE02,{"MOD"	,"C",002,0})
	AADD(aStruE02,{"SERIE"	,"C",005,0})
	AADD(aStruE02,{"NF"		,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruE02,{"EMISS"	,"D",008,0})
	AADD(aStruE02,{"ITEM"	,"C",003,0})
	AADD(aStruE02,{"CODMER"	,"C",020,0})
	AADD(aStruE02,{"DESMER"	,"C",045,0})
	AADD(aStruE02,{"CODCFO"	,"C",004,0})
	AADD(aStruE02,{"CODCLA"	,"C",008,0})
	AADD(aStruE02,{"QUANT"	,"N",017,3})
	AADD(aStruE02,{"UNITAR"	,"N",017,4})
	AADD(aStruE02,{"TOTAL"	,"N",017,2})
	AADD(aStruE02,{"DESC"	,"N",017,2})
	AADD(aStruE02,{"IPI"	,"C",001,0})
	AADD(aStruE02,{"ALIPI"	,"N",005,2})
	AADD(aStruE02,{"BSIPI"	,"N",017,2})
	AADD(aStruE02,{"VLIPI"	,"N",017,2})
	AADD(aStruE02,{"ICMS"	,"C",001,0})
	AADD(aStruE02,{"ALICM"	,"N",005,2})
	AADD(aStruE02,{"BSICM"	,"N",017,2})
	AADD(aStruE02,{"VLICM"	,"N",017,2})
	AADD(aStruE02,{"VLSUB"	,"N",017,2})
	AADD(aStruE02,{"ICMSUB"	,"N",017,2})
	AADD(aStruE02,{"ESTOQ"	,"C",001,0})
	//                              
	cArqE02	:=	CriaTrab(aStruE02)
	dbUseArea(.T.,__LocalDriver,cArqE02,"E02")
	IndRegua("E02",cArqE02,"NF") // ordernar por nf -- chave NF

	dbSelectArea("SFT")
	dbSetOrder(1)
	ProcRegua(LastRec())

	SFT->(DbGoTop())
	
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
	    	lQuery	  := .T.       
	    	cAliasSFT := "SFT_SINCO"	
			aStruSFT  := SFT->(dbStruct())
			cQuery := "SELECT * "
			cQuery += "FROM " + RetSqlName("SFT") + " "
			cQuery += "WHERE FT_FILIAL='" + xFilial("SFT") + "' AND " 
			cQuery += "FT_ENTRADA >= '" + DTOS(MV_PAR01) + "' AND "
			cQuery += "FT_ENTRADA <= '" + DTOS(MV_PAR02) + "' AND "                
			cQuery += "FT_DTCANC <> '' AND " 
			If cNrLivro <> "*"
				cQuery += "FT_NRLIVRO ='"+ cNrLivro +"' AND "
			EndIf 
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SFT->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)
		
			For nX := 1 To len(aStruSFT)
				If aStruSFT[nX][2] <> "C" .And. FieldPos(aStruSFT[nX][1])<>0
					TcSetField(cAliasSFT,aStruSFT[nX][1],aStruSFT[nX][2],aStruSFT[nX][3],aStruSFT[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSFT)	
		Else
	#ENDIF
		    cArqSft   := CriaTrab(NIL,.F.)
		    cCondicao := 'FT_FILIAL == "' + xFilial("SFT") + '" .And. '
		   	cCondicao += 'DTOS(FT_ENTRADA) >= "' + DTOS(MV_PAR01) + '" '
		   	cCondicao += '.And. DTOS(FT_ENTRADA) <= "' + DTOS(MV_PAR02) + '"'
		    If (cNrLivro<>"*")
			    cCondicao += '.And. FT_NRLIVRO =="'+cNrLivro+'" '
		   	EndIf
			cCondicao += '.And. !Empty(FT_DTCANC) '
		    IndRegua(cAliasSFT,cArqSft,SFT->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SFT")
			#IFNDEF TOP
				dbSetIndex(cArqSft+OrdBagExt())
				dbSelectArea("SFT")
			    dbSetOrder(nIndex+1)
			#ENDIF    
		    dbSelectArea(cAliasSFT)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF       

	Do While !(cAliasSFT)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando as Nfs Saida               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr((cAliasSFT)->FT_CFOP,1,1) >= "5"
		
			DbSelectArea ("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO))
		
			RecLock("S02",.T.)
			S02->MOV	:= "S"
 			S02->MOD	:= (cAliasSFT)->FT_ESPECIE
			S02->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
			S02->NF		:= (cAliasSFT)->FT_NFISCAL
			S02->EMISS	:= (cAliasSFT)->FT_EMISSAO
			S02->ITEM	:= (cAliasSFT)->FT_ITEM
			S02->CODMER	:= (cAliasSFT)->FT_PRODUTO
			S02->DESMER	:=  SB1->B1_DESC
			S02->CODCFO	:= (cAliasSFT)->FT_CFOP
			S02->CODCLA	:=  SB1->B1_POSIPI
			S02->QUANT	:= (cAliasSFT)->FT_QUANT
			S02->UNITAR	:= (cAliasSFT)->FT_VALCONT
			S02->TOTAL	:= (cAliasSFT)->FT_VALCONT
			S02->DESC	:= (cAliasSFT)->FT_DESCONT
			S02->IPI	:= If(!Empty((cAliasSFT)->FT_VALIPI),"1",If(!Empty((cAliasSFT)->FT_ISENIPI),"2","3"))
			S02->ALIPI	:= (cAliasSFT)->FT_ALIQIPI
			S02->BSIPI	:= If((cAliasSFT)->FT_ALIQIPI>0,(cAliasSFT)->FT_VALIPI/((cAliasSFT)->FT_ALIQIPI/100),0)
			S02->VLIPI	:= (cAliasSFT)->FT_VALIPI
			S02->ICMS	:= If(!Empty((cAliasSFT)->FT_VALICM),"1",If(!Empty((cAliasSFT)->FT_ISENICM),"2","3"))
			S02->ALICM	:= (cAliasSFT)->FT_ALIQICM
			S02->BSICM	:= (cAliasSFT)->FT_BASEICM
			S02->VLICM	:= (cAliasSFT)->FT_VALICM
			S02->VLSUB	:= (cAliasSFT)->FT_BASERET
			S02->ICMSUB	:= (cAliasSFT)->FT_ICMSRET
			S02->ESTOQ	:= (cAliasSFT)->FT_ESTOQUE
		    //
			MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processando as Nfs Entrada - Formulario Proprio                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFT)->FT_FORMUL=='S'

				DbSelectArea ("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO))
		
				RecLock("E02",.T.)
				E02->MOV	:= "E"
	 			E02->MOD	:= (cAliasSFT)->FT_ESPECIE
				E02->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
				E02->NF		:= (cAliasSFT)->FT_NFISCAL
				E02->EMISS	:= (cAliasSFT)->FT_EMISSAO
				E02->ITEM	:= (cAliasSFT)->FT_ITEM
				E02->CODMER	:= (cAliasSFT)->FT_PRODUTO
				E02->DESMER	:=  SB1->B1_DESC
				E02->CODCFO	:= (cAliasSFT)->FT_CFOP
				E02->CODCLA	:=  SB1->B1_POSIPI
				E02->QUANT	:= (cAliasSFT)->FT_QUANT
				E02->UNITAR	:= (cAliasSFT)->FT_VALCONT
				E02->TOTAL	:= (cAliasSFT)->FT_VALCONT
				E02->DESC	:= (cAliasSFT)->FT_DESCONT
				E02->IPI	:= If(!Empty((cAliasSFT)->FT_VALIPI),"1",If(!Empty((cAliasSFT)->FT_ISENIPI),"2","3"))
				E02->ALIPI	:= (cAliasSFT)->FT_ALIQIPI
				E02->BSIPI	:= If((cAliasSFT)->FT_ALIQIPI>0,(cAliasSFT)->FT_VALIPI/((cAliasSFT)->FT_ALIQIPI/100),0)
				E02->VLIPI	:= (cAliasSFT)->FT_VALIPI
				E02->ICMS	:= If(!Empty((cAliasSFT)->FT_VALICM),"1",If(!Empty((cAliasSFT)->FT_ISENICM),"2","3"))
				E02->ALICM	:= (cAliasSFT)->FT_ALIQICM
				E02->BSICM	:= (cAliasSFT)->FT_BASEICM
				E02->VLICM	:= (cAliasSFT)->FT_VALICM
				E02->VLSUB	:= (cAliasSFT)->FT_BASERET
				E02->ICMSUB	:= (cAliasSFT)->FT_ICMSRET
				E02->ESTOQ	:= (cAliasSFT)->FT_ESTOQUE
				//
				MsUnlock()                    
			Endif
		Endif
		(cAliasSFT)->(dbSkip())
	Enddo                  
	SFT->(DbCloseArea ())
	//
	RetIndex ("SFT")
	Ferase (cArqSft+SFT->(OrdBagExt ()))
	SFT->(DbClearFilter ())
	RestArea (aArea)

Return()

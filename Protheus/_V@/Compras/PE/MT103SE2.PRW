#INCLUDE 'PROTHEUS.CH'

User Function MT103SE2()
	Local aRet:= {}// Customizações desejadas para adição do campo no grid de informações

	aAdd(aRet,{;
				AllTrim(GetSx3Cache("E2_LINDIG","X3_TITULO")),;
				"E2_LINDIG",;
				AllTrim(GetSx3Cache("E2_LINDIG","X3_PICTURE")),;
				GetSx3Cache("E2_LINDIG","X3_TAMANHO"),;
				GetSx3Cache("E2_LINDIG","X3_DECIMAL"),;
				"Vazio() .OR. VldCodBar(M->E2_LINDIG) ",;
				GetSx3Cache("E2_LINDIG","X3_USADO"),;
				GetSx3Cache("E2_LINDIG","X3_TIPO"),;
				"",;
				"",;
				"",;
				"",;
				".T.";
				})
				//"Vazio() .OR. ( VldCodBar(M->E2_LINDIG) .and. U_M103VDB() )",;
				//"Vazio() .OR. ( VldCodBar(M->E2_LINDIG) .and. U_M103VDB() )",;
Return aRet

User Function M103VDB()
	Local lRet := .T.
	Local cMsg := ""
	Local nI
	Local cLinDig := AllTrim(M->E2_LINDIG)

	if Type("aCBrMT103") <> 'U'
		For nI := 1 to Len(aCBrMT103)
			if aCBrMT103[nI,2] == cLinDig
				cMsg := "Código inserido já está na "
				cMsg += "linha: " + AllTrim(Str(nI))
				
				lRet := .F.
				exit
			endif
		Next nI

		if !lRet
			MsgStop(cMsg,"Boleto Invalido!")
		else
			nValBol := SubStr(cLinDig,Len(cLinDig)-9,Len(cLinDig))
			nValBol := SubStr(nValBol,1,8) + '.' + SubStr(nValBol,9,2)

			if aCols[n,3] <> Val(nValBol)
				cMsg := "Código de boleto inválido!" + CRLF
				cMsg += "Valor do boleto não corresponde ao valor do titulo!"+ CRLF
				cMsg += "Valor do boleto: " + nValBol + CRLF
				cMsg += "Valor do titulo: " + cLinDig + CRLF
				
				lRet := .F.
			endif
			
			if !lRet
				MsgStop(cMsg,"Boleto Invalido!")
			endif

		endif

	endif

Return lRet

//85850000001782201851124059018392008120240924
//00190000090315010700500251639175998470000037600

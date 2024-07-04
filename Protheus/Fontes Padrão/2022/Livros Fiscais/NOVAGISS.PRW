#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GissOL    ³ Autor ³ Luccas Curcio      ³ Data ³10/05/2011   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Arquivo gerador da GissOnline - 17ª edição                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array com as informacoes preenchidas.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo                              ³±±
±±³          ³ExpD -> Data final do periodo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GissOL (dDataDe, dDataAte, aFilsCalc)
Static lC5_OBRA := SC5->(FieldPos("C5_OBRA")) > 0

Local aRet      := {}
Local cIndic    := ""
Local cPais     := ""
Local cLayout   := ""
Local cTipoNf   := ""
Local cEstab    := ""
Local cLocPS    := ""
Local cCodObra  := ""
Local cCodObraP := ""
Local cAlias    := "SF3"
Local cIndex    := ""
Local cValor    := ""
Local cBase     := ""
Local cEmissao  := ""
Local cTbEnqua  := ""
Local cWhere    := "%%"
Local cMunCli   := ""
Local cCidade   := ""  
Local cMV_OBRA  := Alltrim(GetNewPar("MV_CODOBRA",""))
Local cMV_OBR2  := Alltrim(GetNewPar("MV_CODOBR2",""))
Local cMV_TBEN  := Alltrim(GetNewPar("MV_TBENQUA",""))
Local cMV_CBSC  := Alltrim(GetNewPar("MV_CODBSC" ,""))
Local cMVSIMPLES:= Alltrim(GetNewPar("MV_SIMPLES",""))
Local lObra     := GetNewPar("MV_GISSOBR",.F.)
Local lCodesp   := GetNewPar("MV_GISSCOD",.F.)
Local lOrgPubl  := GetNewPar("MV_GISSPUB",.F.)
Local lBanco    := GetNewPar("MV_GISSBAN",.F.)
Local lRegObra  := .F.  
Local lCodObra  := .F.
Local lNFSe	    := .F.
Local nIndex    := 0
Local nForFilial:= 0
Local cFilOrig  := cFilAnt
Local aMVtpnf	:= {}
Local lMVtpnf	:= .F.
Local nX		:= 0

Default aFilsCalc:= { { .T., cFilAnt } }

//-- Monta arquivo temporario
MontTrab(@aRet)

If !Pergunte("NOVAGISS",.T.)
	Return (aRet)
EndIf

DbSelectArea('SF3')
SF3->(DbSetOrder(1))

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]

		lMVtpnf	:= .F.

		aMVtpnf := &(GetNewPar("MV_GISTPNF",'{"","","","","","","",""}'))
		
		If ValType( aMVtpnf) == "A" .and. len(aMVtpnf) == 8			
			For nX:= 1 to Len(aMVtpnf)
				If !empty(aMVtpnf[nX])
					lMVtpnf := .T.					
				EndIf				
			Next nX
		EndIf

		cAlias	:= 'SF3'
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAlias := GetNextAlias()
				If MV_PAR01 == 1
					//-- Prestador (Saidas)
					cWhere := "%SF3.F3_CFO >= '5' AND%"
				ElseIf MV_PAR01 == 2
					//-- Tomador (Entradas)
					cWhere := "%SF3.F3_CFO <= '3' AND%"
				EndIf
				BeginSql alias cAlias
					SELECT *
					FROM
						%table:SF3% SF3
					WHERE
						SF3.F3_FILIAL = %xfilial:SF3% AND
						SF3.F3_ENTRADA >= %exp:DToS (dDataDe)% AND
						SF3.F3_ENTRADA <= %exp:DToS (dDataAte)% AND
						SF3.F3_CODISS <> ' ' AND
						%Exp:cWhere%
						SF3.%notDel%
					ORDER BY
						F3_FILIAL
				EndSql
			Else
		#ENDIF
			cIndex := CriaTrab (NIL,.F.)
			cQuery := "F3_FILIAL='"+xFilial("SF3")+"' AND F3_EMISSAO>='"+DTOS(MV_PAR01)+"' AND F3_EMISSAO<='"+DTOS(MV_PAR02)+"' AND F3_CODISS<>'"+Space(Len(SF3->F3_CODISS))+"'"
			IndRegua (cAlias, cIndex, SF3->(IndexKey ()),, cQuery)
			nIndex := RetIndex(cAlias)
			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			DbSelectArea (cAlias)
			DbSetOrder (nIndex+1)
		#IFDEF TOP
			Endif
		#ENDIF
		
		Do While !(cAlias)->(Eof ())
		
			cCodObra := ""
			If Substr((cAlias)->F3_CFO,1,1) <= "3"
				DbSelectArea("SA2")
				SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
				SA2->(dbSeek(xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA))
				
				DbSelectArea("SFT")
				SFT->(dbSetOrder(3)) //FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3
				SFT->(dbSeek(xFilial("SF3")+"E"+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA+(cAlias)->F3_SERIE+(cAlias)->F3_NFISCAL+(cAlias)->F3_IDENTFT))

				DbSelectArea("SF1")
				SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(dbSeek(xFilial("SF1")+(cAlias)->F3_NFISCAL+(cAlias)->F3_SERIE+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA))
					//-- Nao considerar devolucoes.
					If MV_PAR03 == 2 .And. F1_TIPO == "D"
						(cAlias)->(DbSkip())
						Loop
					EndIf
					cCidade := Alltrim(UfCodIBGE(SF1->F1_ESTPRES)+SF1->F1_INCISS)
				EndIf
						
				// Este seek só é necessário se o parâmetro MV_CODOBR2 conter um campo da SD1 para o código da obra
				If at("D1_",cMV_OBR2) > 0    
				   DbSelectArea("SD1")
				     SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				     SD1->(dbSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
				EndIf
		
				//Registro de Obra ?
				//Para que seja gerado os Registros de Obra (H ou I), o campo informado no parâmetro MV_CODOBR2 deverá estar diferente de vazio  
				// (deve ser informado "SEM CODIGO" caso não seja uma Obra sem código ou com o Código da Obra)
				lRegObra := iif(!Empty(&(cMV_OBR2)), .T., .F.)
				//Possui Código de obra?
			   	If lRegObra
					lCodObra := iif(At("SEM CODIGO",UPPER(ALLTRIM((&(cMV_OBR2))))) > 0, .F., .T. )
				
					// Com obras/Sem Obra
					If ((MV_PAR04 == 1 .And. !lCodObra ) .OR. (MV_PAR04 == 2 .And. lCodObra))
						(cAlias)->(DbSkip())
						Loop
					EndIf
				Else
					//Se não tiver conteudo da obra no campo da A2 e mesmo assim selecionou com obra
					If MV_PAR04 == 1
						(cAlias)->(DbSkip())
						Loop
					EndIf						
				EndIf		  
				
				If (cAlias)->F3_ISSSUB <> 0
					cIndic := "2"
					cLayout:= "2"
				Elseif (cAlias)->F3_ISSMAT <> 0
					cIndic := "1"
					cLayout:= "1"	
				ElseIf lBanco
					cIndic := "A"
					cLayout:= "1"
				Elseif SA2->A2_EST == "EX"
					cIndic := "F"
					cLayout:= "4"
				Elseif lRegObra
					If lCodObra 
						cIndic   := "H"
						cLayout  := "6"
						cCodObra := &(cMV_OBR2)
					Else 
						cIndic   := "I"
						cLayout  := "3"
						cCodObra := ""
					Endif	
				Elseif lOrgPubl
					cIndic := "D"
					cLayout:= "1"				
				Else
					cIndic := "T"
					cLayout:= "1"
				Endif				
				
				If lMVtpnf // havendo configuração no array os campos serão preenchidos conforme o conteúdo das posições

					If !Empty((cAlias)->F3_DTCANC)// se a data de cancelamento não estiver vazia
						If !Empty(aMVtpnf[2])
							cTipoNf := aMVtpnf[2] // considera o que há no array
						Elseif!Empty(aMVtpnf[3])
							cTipoNf := aMVtpnf[3] // considera o que há no array
						Else
							cTipoNf := "2"	// cancelado conforme o leiaute
						EndIf						
					Elseif (cAlias)->F3_ISENICM > 0 
						If !Empty(aMVtpnf[4]) 
							cTipoNf := aMVtpnf[4] // considera o que há no array
						Else
							cTipoNf := "4"	//isento conforme o leiaute
						EndIf						
					Elseif (cAlias)->F3_RECISS $"2N" 
						If !Empty(aMVtpnf[5])
							cTipoNf := aMVtpnf[5] // considera o que há no array
						Else
							cTipoNf := "5"	// retida conforme o leiaute
						EndIf
					Else
						If !Empty(aMVtpnf[1])
							cTipoNf := aMVtpnf[1] // não retida	
						Elseif!Empty(aMVtpnf[6])
							cTipoNf := aMVtpnf[6] // pago pelo prestador
						Else
							cTipoNf := "1"	// não retida conforme o leiaute
						EndIf
					Endif

				Else // se nenhuma posição do array estiver preenchida o sistema faz como sempre fez

					//Tipo NF
					If !Empty((cAlias)->F3_DTCANC)// cancelado
						cTipoNf := "2"
					Elseif (cAlias)->F3_ISENICM > 0 // isento
						cTipoNf := "4"
					Elseif (cAlias)->F3_RECISS $"2N" // retida
						cTipoNf := "5"				
					Else 
						cTipoNf := "1" // não retida
					Endif

				EndIf
				
				cCidade := IIf( Empty(cCidade),Alltrim(UfCodIBGE(SA2->A2_EST)+SA2->A2_COD_MUN), AllTrim(cCidade))
				
				//Verifica se fornecedor é de dentro ou fora do município		
				cEstab := Iif( Alltrim(UfCodIBGE(SA2->A2_EST)+SA2->A2_COD_MUN) == Alltrim(SM0->M0_CODMUN), "S", "N")
				
				//Local Prestação do Serviço (Dentro ou Fora do Municipio)
				cLocPS := Iif(cCidade == Alltrim(SM0->M0_CODMUN), "D", "F")
		
				//Pais
				cPais := IIf(SA2->A2_EST == "EX", &(Alltrim(GetNewPar("MV_SIGLA"))), "BR")
		
				//Formatação do campo VL_DOC_NF conforme Manual da GISS
				cValor   := Transform((cAlias)->F3_VALCONT, "@E 999999999.99")
				cValor   := Alltrim(Strtran((cValor) ,",",""))
				
				//Formatação do campo VL_BASE_CALCULO conforme Manual da GISS
				cBase    := Transform((cAlias)->F3_BASEICM, "@E 999999999.99")  
				cBase    := Alltrim(Strtran((cBase) ,",",""))
				
				//Formatação do campo DT_EMISSAO_NF conforme Manual da GISS
				cEmissao := Substr((cAlias)->F3_EMISSAO,7,2)+"/"+Substr((cAlias)->F3_EMISSAO,5,2)+"/"+Substr((cAlias)->F3_EMISSAO,1,4)
		
				//Tratamento para que não seja considerado no arquivo Serviço Tomado através de NFS-e de fornecedor de dentro do Município
				//Notas de fora do município serão todas consideradas
				lNFSe := IIF(cEstab=="S" .And. Alltrim((cAlias)->F3_ESPECIE)=='NFSE', .T., .F.)

				//-- Verifica se fornecedor é de dentro ou fora do município
				If (MV_PAR02==1 .And. cEstab=="S" .And. !lNFSe) .Or. (MV_PAR02==2 .And. cEstab=="N") .Or. (MV_PAR02==3 .And. !lNFSe) 
					RecLock("ARQ",.T.)
					ARQ->ARQ_INDIC  := cIndic
					ARQ->ARQ_LAYOUT := cLayout
					ARQ->ARQ_EMISSA := cEmissao
					ARQ->ARQ_NFINI  := (cAlias)->F3_NFISCAL
					ARQ->ARQ_SERIE  := SerieNfId(cAlias,2,"F3_SERIE")				
					ARQ->ARQ_NFFIM  := (cAlias)->F3_NFISCAL
					ARQ->ARQ_TIPONF := cTipoNf
					ARQ->ARQ_VALOR  := cValor
					ARQ->ARQ_BASE   := cBase	
					ARQ->ARQ_ATIVID := Iif(!Empty(cMV_CBSC) .And. SF3->(FieldPos(cMV_CBSC)) > 0, (cAlias)->(&cMV_CBSC), (cAlias)->F3_CODISS)
					ARQ->ARQ_ESTAB  := cEstab
					ARQ->ARQ_LOCPS  := cLocPS
					ARQ->ARQ_RAZSOC := SA2->A2_NOME
					ARQ->ARQ_CNPJ   := SA2->A2_CGC
					ARQ->ARQ_TPCAD  := IIf(SA2->A2_TIPO="J","2","1")
					ARQ->ARQ_INSCM  := Val(Left(Alltrim(aRetDig(SA2->A2_INSCRM,.F.)),10))
					ARQ->ARQ_DIGIT  := Iif(len(alltrim(SA2->A2_INSCRM))>10,SubStr(SA2->A2_INSCRM,11,2), "")
					ARQ->ARQ_INSCE  := Iif(Upper(AllTrim(SA2->A2_INSCR))=="ISENTO","",StrTran(SA2->A2_INSCR,".",""))
					ARQ->ARQ_INSCE  := StrTran(ARQ->ARQ_INSCE,"-","")
					ARQ->ARQ_INSCE  := StrTran(ARQ->ARQ_INSCE,"/","")
					ARQ->ARQ_TPLOGR := Substr (SA2->A2_END, 1, At(" ", SA2->A2_END))
					ARQ->ARQ_TITLOG := ""
					ARQ->ARQ_LOGRAD := Substr (SA2->A2_END, At(" ",SA2->A2_END)+1,Iif(At (",", SA2->A2_END)>0,(At (",", SA2->A2_END)-At (" ", SA2->A2_END))-1,len(SA2->A2_END)))
					ARQ->ARQ_COMPL  := FisGetEnd(SA2->A2_END)[4]
					ARQ->ARQ_NUMERO := Iif ("," $ SA2->A2_END, FisGetEnd(SA2->A2_END)[3], "")
					ARQ->ARQ_CEP    := Val(aRetDig(SA2->A2_CEP,.F.))
					ARQ->ARQ_BAIRRO := SA2->A2_BAIRRO
					ARQ->ARQ_UF     := SA2->A2_EST
					ARQ->ARQ_CIDADE := SA2->A2_MUN
					ARQ->ARQ_PAIS   := cPais
					ARQ->ARQ_OBSERV := ""
					ARQ->ARQ_PLNCTA := Iif(!Empty(SFT->FT_CONTA),SFT->FT_CONTA,"")
					ARQ->ARQ_ALVARA := cCodObra
					ARQ->ARQ_ORIGEM := "R"
					ARQ->ARQ_ENQUAD := ""
					ARQ->ARQ_PLCTAP := Iif(!Empty(SFT->FT_CONTA),SFT->FT_CONTA,"") 
					ARQ->ARQ_RECIMP := Iif((cAlias)->F3_RECISS$"1S","0","1")
			        ARQ->ARQ_ALIQ   := Iif(SA2->A2_SIMPNAC$"S1" .And. (cAlias)->F3_ALIQICM > 0 ,strzero((cAlias)->F3_ALIQICM,6,3),"")
					ARQ->ARQ_ISENIE := IIf(Empty(SA2->A2_INSCR) .OR. Upper(AllTrim(SA2->A2_INSCR))=="ISENTO","S","N")
					ARQ->ARQ_SIMPNA := Iif(SA2->A2_SIMPNAC$"S1","S","N")		
					MsUnlock()		
				EndIf
			Else
				DbSelectArea("SA1")
				SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
				SA1->(dbSeek(xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA))
				
				DbSelectArea("SFT")
				SFT->(dbSetOrder(3)) //FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3
				SFT->(dbSeek(xFilial("SF3")+"S"+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA+(cAlias)->F3_SERIE+(cAlias)->F3_NFISCAL+(cAlias)->F3_IDENTFT))
				
				DbSelectArea("SD2")
				SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				SD2->(dbSeek(xFilial("SF3")+(cAlias)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))					

				//-- Nao considerar devolucoes.
				If MV_PAR03 == 2 .And. SD2->D2_TIPO == "D"
					(cAlias)->(DbSkip())
					Loop
				EndIf

				DbSelectArea("SC5")
				SC5->(dbSetOrder(3)) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
				SC5->(dbSeek(xFilial("SC5")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_PEDIDO))					

				// Com obras/Sem Obra
				If	(MV_PAR04 == 1 .And. (Empty(SC5->C5_OBRA) .And. Empty(&(cMV_OBRA)))) .Or.;
					(MV_PAR04 == 2 .And. (!Empty(SC5->C5_OBRA) .Or. !Empty(&(cMV_OBRA))))
					(cAlias)->(DbSkip())
					Loop
				EndIf
		
				If lC5_OBRA
					cCodObraP := SC5->C5_OBRA
				EndIf
				If (cAlias)->F3_ISSSUB <> 0
					cIndic := "2"
					cLayout:= "2"
				Elseif (cAlias)->F3_ISSMAT <> 0
					cIndic := "1"
					cLayout:= "1"	
				ElseIf lBanco
					cIndic := "A"
					cLayout:= "1"
				Elseif SA1->A1_EST == "EX"
					If lCodesp
						cIndic  := "S"
						cLayout := "2"
					Else
						cIndic  := "C"
						cLayout := "2"
					Endif
				Elseif lObra
					If  (Empty(cCodObraP) .And. SA1->A1_PESSOA == "F") .And. (Empty(&(cMV_OBRA)) .And. SA1->A1_PESSOA == "F")  
						cIndic   := "G"
						cLayout  := "1"
						cCodObra := ""
					Elseif (Empty(cCodObraP) .And. SA1->A1_PESSOA == "J") .And. (Empty(&(cMV_OBRA)) .And. SA1->A1_PESSOA == "J") 		
						cIndic   := "G"
						cLayout  := "2"
						cCodObra := "" 
					Elseif (!(Empty(cCodObraP)) .And. SA1->A1_PESSOA == "F")  .Or. (!(Empty(&(cMV_OBRA))) .And. SA1->A1_PESSOA == "F") 
						cIndic   := "X"
						cLayout  := "4"
						cCodObra :=  If(!Empty(cCodObraP),cCodObraP,&(cMV_OBRA))     
					Else
						cIndic   := "X"
						cLayout  := "5"
						cCodObra := If(!Empty(cCodObraP),cCodObraP,&(cMV_OBRA))
					Endif
				Elseif lCodesp
					If SA1->A1_PESSOA == "F"
						cIndic  := "S"
						cLayout := "1"
					Else
						cIndic  := "S"
						cLayout := "3"
					Endif
				Else
					If SA1->A1_PESSOA == "F"
						cIndic  := "C"
						cLayout := "1"
					Else
						cIndic  := "C"
						cLayout := "3"
					Endif
				Endif
				
				If !Empty((cAlias)->F3_DTCANC)
					cTipoNf := "2"
				Elseif (cAlias)->F3_ISENICM > 0 .Or. (cAlias)->F3_OUTRICM > 0
					cTipoNf := "4"
				Elseif (cAlias)->F3_RECISS $"1S"
					cTipoNf := "5"
				Else
					cTipoNf := "1"
				Endif

				//Municipio Cliente 
				cMunCli := Alltrim(UfCodIBGE(SA1->A1_EST)+SA1->A1_COD_MUN)
		
				//Cliente (Dentro ou Fora Municipio)
				cEstab := iif(cMunCli == Alltrim(SM0->M0_CODMUN), "S", "N")
				
				//Local Prestação Serviço (Dentro ou Fora Municipio)
				cLocPS := iif(cMunCli == Alltrim(SM0->M0_CODMUN) .And. (cAlias)->F3_ISSST == "1", "D", "F")
		
				//País
		 		cPais := iif(SA2->A2_EST == "EX", &(Alltrim(GetNewPar("MV_PSIGLA1"))), "BR")
		
				
				If !Empty(&(cMV_TBEN))
					cTbEnqua := &(cMV_TBEN)
				Endif 
				
				//Formatação do campo VL_DOC_NF conforme Manual da GISS
				cValor   := Transform((cAlias)->F3_VALCONT, "@E 999999999.99")
				cValor   := Alltrim(Strtran((cValor) ,",",""))
				
				//Formatação do campo VL_BASE_CALCULO conforme Manual da GISS
				cBase    := Transform((cAlias)->F3_BASEICM, "@E 999999999.99")  
				cBase    := Alltrim(Strtran((cBase) ,",",""))
				
				//Formatação do campo DT_EMISSAO_NF conforme Manual da GISS
				cEmissao := Substr((cAlias)->F3_EMISSAO,7,2)+"/"+Substr((cAlias)->F3_EMISSAO,5,2)+"/"+Substr((cAlias)->F3_EMISSAO,1,4)
				
				//-- Verifica se servico prestado dentro ou fora do municipio
				If (MV_PAR02==1 .And. cEstab=="S") .Or. (MV_PAR02==2 .And. cEstab=="N") .Or. (MV_PAR02==3)  
					RecLock("ARQ",.T.)
					ARQ->ARQ_INDIC  := cIndic
					ARQ->ARQ_LAYOUT := cLayout
					ARQ->ARQ_EMISSA := cEmissao
					ARQ->ARQ_NFINI  := (cAlias)->F3_NFISCAL
					ARQ->ARQ_SERIE  := SerieNfId(cAlias,2,"F3_SERIE")
					ARQ->ARQ_NFFIM  := (cAlias)->F3_NFISCAL
					ARQ->ARQ_TIPONF := cTipoNf
					ARQ->ARQ_VALOR  := cValor
					ARQ->ARQ_BASE   := cBase
					ARQ->ARQ_ATIVID := Iif(!Empty(cMV_CBSC) .And. SF3->(FieldPos(cMV_CBSC)) > 0, (cAlias)->(&cMV_CBSC), (cAlias)->F3_CODISS)
					ARQ->ARQ_ESTAB  := cEstab
					ARQ->ARQ_LOCPS  := cLocPS
					ARQ->ARQ_RAZSOC := SA1->A1_NOME
					ARQ->ARQ_CNPJ   := SA1->A1_CGC
					ARQ->ARQ_TPCAD  := IIf(SA1->A1_PESSOA="J","2","1")
					ARQ->ARQ_INSCM  := Val(Left(Alltrim(aRetDig(SA1->A1_INSCRM,.F.)),10))
					ARQ->ARQ_DIGIT  := Iif(len(alltrim(SA1->A1_INSCRM))>10,SubStr(SA1->A1_INSCRM,11,2), "")
					ARQ->ARQ_INSCE  := Iif(Upper(Alltrim(SA1->A1_INSCR)) == "ISENTO","",StrTran(SA1->A1_INSCR,".",""))
					ARQ->ARQ_INSCE  := StrTran(ARQ->ARQ_INSCE,"-","")
					ARQ->ARQ_INSCE  := StrTran(ARQ->ARQ_INSCE,"/","")
					ARQ->ARQ_TPLOGR := Substr (SA1->A1_END, 1, At(" ", SA1->A1_END))
					ARQ->ARQ_TITLOG := ""
					ARQ->ARQ_LOGRAD := Substr (SA1->A1_END, At(" ",SA1->A1_END)+1,Iif(At (",", SA1->A1_END)>0,(At (",", SA1->A1_END)-At (" ", SA1->A1_END))-1,len(SA1->A1_END)))
					ARQ->ARQ_COMPL  := FisGetEnd(SA1->A1_END)[4] 
					ARQ->ARQ_NUMERO := Iif ("," $ SA1->A1_END, FisGetEnd(SA1->A1_END)[3], "")
					ARQ->ARQ_CEP    := Val(aRetDig(SA1->A1_CEP,.F.))
					ARQ->ARQ_BAIRRO := SA1->A1_BAIRRO
					ARQ->ARQ_UF     := SA1->A1_EST
					ARQ->ARQ_CIDADE := SA1->A1_MUN
					ARQ->ARQ_PAIS   := cPais
					ARQ->ARQ_OBSERV := ""
					ARQ->ARQ_PLNCTA := Iif(!Empty(SFT->FT_CONTA),SFT->FT_CONTA,"")
					ARQ->ARQ_ALVARA := cCodObra
					ARQ->ARQ_ORIGEM := "R"
					ARQ->ARQ_ENQUAD := cTbEnqua
					ARQ->ARQ_PLCTAP := Iif(!Empty(SFT->FT_CONTA),SFT->FT_CONTA,"") 
					ARQ->ARQ_RECIMP := Iif((cAlias)->F3_RECISS$"2N","1","0")
					ARQ->ARQ_ALIQ   := Iif(cMVSIMPLES$"S" .And. (cAlias)->F3_ALIQICM > 0 ,strzero((cAlias)->F3_ALIQICM,6,3),"")
					ARQ->ARQ_ISENIE := IIf(Empty(SA1->A1_INSCR) .OR. Upper(AllTrim(SA1->A1_INSCR))=="ISENTO","S","N") 
					ARQ->ARQ_SIMPNA := Iif(cMVSIMPLES$"S","S","N")		
					MsUnlock()
				EndIf
			Endif
			(cAlias)->(DbSkip())
		EndDo

	EndIf
Next

cFilAnt := cFilOrig
Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontTrab  ºAutor  ³Luccas Curcio       º Data ³  14/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tabela temporaria                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontTrab(aRet)

Local aStru  := {}
Local cArq   := ""
Default aRet := {}

aAdd (aStru,{"ARQ_INDIC",	"C",	001,	0})
aAdd (aStru,{"ARQ_LAYOUT",	"C",	001,	0})
aAdd (aStru,{"ARQ_EMISSA",	"C",	010,	0})
aAdd (aStru,{"ARQ_NFINI",	"C",	010,	0})
aAdd (aStru,{"ARQ_SERIE",	"C",	010,	0})
aAdd (aStru,{"ARQ_NFFIM",	"C",	010,	0})
aAdd (aStru,{"ARQ_TIPONF",	"C",	001,	0})
aAdd (aStru,{"ARQ_VALOR",	"C",	012,	0})
aAdd (aStru,{"ARQ_BASE",	"C",	012,	0})
aAdd (aStru,{"ARQ_ATIVID",	"C",	020,	0})
aAdd (aStru,{"ARQ_ESTAB",	"C",	001,	0})
aAdd (aStru,{"ARQ_LOCPS",	"C",	001,	0})
aAdd (aStru,{"ARQ_RAZSOC",	"C",	100,	0})
aAdd (aStru,{"ARQ_CNPJ",	"C",	014,	0})
aAdd (aStru,{"ARQ_TPCAD",	"C",	001,	0})
aAdd (aStru,{"ARQ_INSCM",	"N",	010,	0})
aAdd (aStru,{"ARQ_DIGIT",	"C",	002,	0})
aAdd (aStru,{"ARQ_INSCE",	"C",	015,	0})
aAdd (aStru,{"ARQ_TPLOGR",	"C",	005,	0})
aAdd (aStru,{"ARQ_TITLOG",	"C",	005,	0})
aAdd (aStru,{"ARQ_LOGRAD",	"C",	050,	0})
aAdd (aStru,{"ARQ_COMPL",	"C",	040,	0})
aAdd (aStru,{"ARQ_NUMERO",	"C",	010,	0})
aAdd (aStru,{"ARQ_CEP",		"N",	008,	0})
aAdd (aStru,{"ARQ_BAIRRO",	"C",	050,	0})
aAdd (aStru,{"ARQ_UF",		"C",	002,	0})
aAdd (aStru,{"ARQ_CIDADE",	"C",	050,	0})
aAdd (aStru,{"ARQ_PAIS",	"C",	002,	0})
aAdd (aStru,{"ARQ_OBSERV",	"C",	200,	0})
aAdd (aStru,{"ARQ_PLNCTA",	"C",	080,	0})
aAdd (aStru,{"ARQ_ALVARA",	"C",	015,	0})
aAdd (aStru,{"ARQ_ORIGEM",	"C",	001,	0})
aAdd (aStru,{"ARQ_ENQUAD",	"C",	001,	0})
aAdd (aStru,{"ARQ_PLCTAP",	"C",	080,	0})
aAdd (aStru,{"ARQ_RECIMP",	"C",	001,	0})
aAdd (aStru,{"ARQ_ALIQ",	"C",	022,	0})
aAdd (aStru,{"ARQ_ISENIE",	"C",	001,	0})
aAdd (aStru,{"ARQ_SIMPNA",	"C",	001,	0})

cArq := CriaTrab(aStru)
DbUseArea (.T., __LocalDriver, cArq, "ARQ")
IndRegua ("ARQ", cArq, "ARQ_INDIC")

aAdd (aRet, {cArq, "ARQ"})

Return()

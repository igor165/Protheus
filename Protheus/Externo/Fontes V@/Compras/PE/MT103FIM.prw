#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function MT103FIM()
	Local aArea        := GetArea()
	Local aAreaD1      := SD1->(GetArea())
	Local nOpcao       := PARAMIXB[1] // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
	Local nConfirma    := PARAMIXB[2] // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
	Local cTMEntra     := GetMV("MV_X_TMCEN",,"301") // Tipo de Movimento de Entrada para Quebra a Maior no peso de Milho da NF
	Local cTMSaida     := GetMV("MV_X_TMCSA",.T.,"801") // Tipo de Movimento de Saida para Quebra a Menor no peso de Milho da NF
	Local nTolRec      := GetMV("MV_TOLREC",,40) // Tolerancia no recebimento de insumos se peso for inferior a tolerancia avisa sobre diferença
	Local cGrpAju      := GetMV("MV_GRPAJU",,"02;03") // Grupo de Produtos que será ajustado pela TM
	Local cProdMil     := GetMV("MV_X_PRDMI",,"020017;020080;020079;") // Indica códigos de prudutos que NÃO deverão passar pela regra de
	Local lCmpAut      := IIF("S"==GetMV("MV_X_CMPAU",,"S"),.T.,.F.) // Compensa automatico S-sim ou N-nao
	Local QryDia       := "" // Query Diárias
	Local cB1Diari     := ""
	// Local cZ7Fil       := ""
	Local QtdDia       := 0
	Local nDif         := 0

	Local lTemContrato := .F.
	Local lFormProp    := If(Type("cFormul")<>"U",IIF(cFormul=="S",.T.,.F.),.F.)
	
	ConOut('MT103FIM - Opção: ' + cValToChar(nOpcao) )

	/* MJ : 26/12/18
		-> Gravar Data de Inclusao do documento; */
	If nConfirma==1 .and. (nOpcao==3 .or. nOpcao==4)
	//SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	//If SF1->( DbSeek( xFilial('SF1')+cNFiscal+cSerie+ca100For+cLoja ) )
		If Empty(SF1->F1_X_DTINC)
			
			// Alert('[MT103FIM] Gravando: F1_X_DTINC')
			
			RecLock( 'SF1', .F.)
				SF1->F1_X_DTINC := MsDate()
			SF1->(MsUnlock())
			
		EndIf
	//EndIf
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1) 	// B1_FILIAL + B1_COD

	DbSelectArea("SD1")
	DbSetOrder(1) 	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM

	DbSelectArea("SF4")
	DbSetOrder(1) 	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM

	DbSelectArea("SFT")
	DbSetOrder(1)

	DbSelectArea("CD2")
	DbSetOrder(1)

	//Se for confirmado
	If (nConfirma==1)  .and. nOpcao==3 // inclusao apenas

		// Compensacao automatica de titulos de nf com PA
		If lCmpAut
			u_CmpAutTit('P',SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)
		EndIf

		DbSelectArea("SD1")
		//Posicionando nos registros conforme dados do Cabeçalho
		If Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			
			//Enquanto não estiver no fim dos registros e os dados forem referentes ao Cabeçalho
			While !SD1->(EOF()) .AND. (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) == (SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
				
		 		//Seleciona a tabela de TES e Posiciona referente ao Documento de Entrada
				DbSelectArea("SF4")
				SF4->(DbSetOrder(1))
				If SF4->(Dbseek(xFilial("SF4")+SD1->D1_TES))

					U_PegaUmidade( xFilial('SD1'), SD1->D1_PEDIDO, -1, @lTemContrato )
					ConOut("[MT103FIM] Pega Umidade: " + cValToChar(lTemContrato))
					If lTemContrato // contrato de milho na ZBC
						
						If lFormProp == .F.
							LanClassif(SD1->D1_FILIAL, "E", cTMSaida, SD1->D1_COD, SD1->D1_LOCAL, (SD1->D1_X_PESOB-SD1->D1_X_PESOL), 0.01, SD1->D1_DTDIGIT, 'REF. NF ' +SD1->D1_DOC+ '-'+SD1->D1_SERIE+'-EMISSAO ' +DTOC(SD1->D1_EMISSAO)+ '-FORNECEDOR ' +SD1->D1_FORNECE+ '-PESO NF: ' +AllTrim(STR(SD1->D1_QUANT))+ ' PESO BALANCA: '+AllTrim(STR(SD1->D1_X_PESOB))+ ' PESO LIQUIDO: '+AllTrim(STR(SD1->D1_X_PESOL))+'', '', '', '', SD1->D1_FORNECE, SD1->D1_DOC)
							MsgInfo('Realizada Saida em estoque de '  + AllTrim(Str(SD1->D1_X_PESOB-SD1->D1_X_PESOL)) +  ' Kgs referente a recebimento a menor.')
						EndIf
						
					Else
						If Alltrim(SD1->D1_GRUPO)$cGrpAju .AND. !Alltrim(SD1->D1_COD)$cProdMil .AND.;
								SF4->F4_DUPLIC=='S' .AND.;
								SF4->F4_ESTOQUE =='S' .AND.;
								SF4->F4_TRANFIL=='2' .AND.;
								SD1->D1_QUANT > SD1->D1_X_PESOB

							// Lancar Movimento para Registrar a quantidade de classificacao
							If nTolRec < (SD1->D1_QUANT - SD1->D1_X_PESOB )
								nDif := (SD1->D1_QUANT - SD1->D1_X_PESOB)
								MsgInfo('Providenciar Devolução de '  + AllTrim(Str(nDif)) +  ' Kgs referente a diferença da Nota Fiscal')
								
								DocEmail() // Comunicar envolvidos
								
							EndIf
						ElseIf Alltrim(SD1->D1_GRUPO)$cGrpAju.AND.!Alltrim(SD1->D1_COD)$cProdMil.AND.;
								SF4->F4_DUPLIC=='S' .AND.;
								SF4->F4_ESTOQUE =='S' .AND.;
								SF4->F4_TRANFIL=='2' .AND.;
								(SD1->D1_QUANT < SD1->D1_X_PESOB)

							MsgInfo('Realizada Entrada em estoqe de '  + AllTrim(Str(nDif)) +  ' Kgs referente a recebimento a maior.')
							LanClassif(SD1->D1_FILIAL, "E", cTMEntra, SD1->D1_COD, SD1->D1_LOCAL, (SD1->D1_X_PESOB - SD1->D1_QUANT), 0.01, SD1->D1_DTDIGIT, 'REF. NF ' +SD1->D1_DOC+ '-'+SD1->D1_SERIE+'-EMISSAO ' +DTOC(SD1->D1_EMISSAO)+ '-FORNECEDOR ' +SD1->D1_FORNECE+ '-PESO NF: ' +AllTrim(STR(SD1->D1_QUANT))+ ' PESO BALANCA: '+AllTrim(STR(SD1->D1_X_PESOB))+ ' PESO LIQUIDO: '+AllTrim(STR(SD1->D1_X_PESOL))+'', '', '', '', SD1->D1_FORNECE, SD1->D1_DOC)
						EndIf
					EndIf
				EndIf

				cB1Diari := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_X_DIARI")

				If cB1Diari=="S"
					QryDia :=  "  SELECT * "
					QryDia +=  "  FROM "+RetSqlName('SZ7')+" SZ7 "
					QryDia +=  "  WHERE SZ7.D_E_L_E_T_ = '' "
					QryDia +=  "  AND Z7_SERVICO = '"+SD1->D1_COD+"' "
					QryDia +=  "  AND Z7_PEDIDO	 = '"+SD1->D1_PEDIDO+"' "
					QryDia +=  "  AND Z7_FORNECE = '"+SD1->D1_FORNECE+"' "
					QryDia +=  "  AND Z7_LOJA 	 = '"+SD1->D1_LOJA+"' "
					QryDia +=  "  AND Z7_STATUS  = 'P' "
					QryDia +=  "  ORDER BY Z7_FILIAL, Z7_COD "
					
					If Select("QRYZ7") > 0
						QRYZ7->(DbCloseArea())
					EndIf
					TcQuery QryDia New Alias "QRYZ7"
					
					QtdDia := SD1->D1_QUANT // Quantidade e abater da Diaria

					If !QRYZ7->(EOF())
						While  QtdDia > 0
							
								SZ7->(dbGoTo(QRYZ7->R_E_C_N_O_))
								
								QtdDia := QtdDia - SZ7->Z7_QUANT
								
								RecLock("SZ7",.F.)
									Z7_FILDOC	:= SD1->D1_FILIAL
									Z7_DOC		:= SD1->D1_DOC
									Z7_SERIE	:= SD1->D1_SERIE
									Z7_ITEMNF	:= SD1->D1_ITEM  
									Z7_STATUS	:= 'A' // ATENDIDO	     
								SZ7->(MSUnLock())
								
								QRYZ7->(dbSkip()) 
								
							If QRYZ7->(EOF())
								Exit
							EndIf
						EndDo
					EndIf
				EndIf

				SD1->(dbSkip())
			Enddo
		EndIf

		/* MB : 25.08.2020
			nova ideia para validacao do campo item; Erro do ICMS; */
		/*
		tirei para testar, 
		corrigimos o fonte MT103VPC ; campo item sendo carregado fixo com a informacao 001
		*/
		// mbVldICMS( SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE)

		//EndIf
		// FIM Conforme Sim e Inclusão

		/*
		Excluir itens SD1;
		*/
	ElseIf  (nConfirma==1)  .and. nOpcao==5 // Exclusão apenas

		//Posicionando nos registros conforme dados do Cabeçalho
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		While SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

			RecLock('SD1', .F.)
			SD1->(DbDelete())
			SD1->(MsUnlock())

			SD1->(dbSkip())
		EndDo
	EndIf

	SD1->(dbCloseArea())
	RestArea(aAreaD1)
	RestArea(aArea)
Return Nil


Static Function mbVldICMS( __cFilial, __cDoc, __cSerie )
	Local aArea    := GetArea()
	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaCD2 := CD2->(GetArea())
	Local aAreaSFT := SFT->(GetArea())
	Local _cQry    := ""
	Local _cAlias  := GetNextAlias()

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	DbSelectArea("CD2")
	CD2->(DbSetOrder(1))

	DbSelectArea("SFT")
	SFT->(DbSetOrder(1))

	_cQry := " SELECT D1_ITEM,  D1.R_E_C_N_O_ RecnoD1," + CRLF
	_cQry += " 		  CD2_ITEM, D2.R_E_C_N_O_ RecnoCD2," + CRLF
	_cQry += " 		  FT_ITEM,  FT.R_E_C_N_O_ RecnoFT" + CRLF
	_cQry += " FROM    SC7010 C7" + CRLF
	_cQry += " JOIN	SD1010 D1 ON C7_FILIAL+C7_NUM+C7_PRODUTO+convert(varchar,CONVERT(int, C7_ITEM)) = D1_FILIAL+D1_PEDIDO+D1_COD+convert(varchar,CONVERT(int, D1_ITEM))" + CRLF
	_cQry += " 						AND C7.D_E_L_E_T_=' ' AND D1.D_E_L_E_T_=' '" + CRLF
	_cQry += " JOIN	CD2010 D2 ON CD2_FILIAL+CD2_DOC+CD2_SERIE+CD2_CODPRO+convert(varchar,CONVERT(int, CD2_ITEM)) = D1_FILIAL+D1_DOC+D1_SERIE+D1_COD+convert(varchar,CONVERT(int, D1_ITEM))" + CRLF
	_cQry += " 						AND D2.D_E_L_E_T_=' '" + CRLF
	_cQry += " JOIN	SFT010 FT ON FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_PRODUTO+convert(varchar,CONVERT(int, FT_ITEM)) = D1_FILIAL+D1_DOC+D1_SERIE+D1_COD+convert(varchar,CONVERT(int, D1_ITEM))" + CRLF
	_cQry += " 						AND FT.D_E_L_E_T_=' '" + CRLF
	_cQry += " WHERE 	-- C7_FILIAL+C7_NUM IN ('01028650')" + CRLF
	_cQry += " 	  	  D1_FILIAL='" + __cFilial + "'" + CRLF
	_cQry += " 	  AND D1_DOC='" + __cDoc + "'" + CRLF
	_cQry += " 	  AND D1_SERIE='" + __cSerie + "'" + CRLF
	_cQry += " 	  AND (" + CRLF
	_cQry += " 	  	    LEN(rTrim(D1_ITEM)) <> LEN(rTrim(CD2_ITEM))" + CRLF
	_cQry += " 	  	 OR LEN(rTrim(D1_ITEM)) <> LEN(rTrim(FT_ITEM ))" + CRLF
	_cQry += " 	  )"

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

	While !(_cAlias)->(Eof())
		SD1->(DbGoTo((_cAlias)->RecnoD1))

		CD2->(DbGoTo((_cAlias)->RecnoCD2))
		If AllTrim(CD2->CD2_ITEM) <> AllTrim(SD1->D1_ITEM)
			RecLock("CD2", .F.)
				CD2->CD2_ITEM := SD1->D1_ITEM
			CD2->(MsUnLock())
		EndIf

		SFT->(DbGoTo((_cAlias)->RecnoFT))
		If AllTrim(SFT->FT_ITEM) <> AllTrim(SD1->D1_ITEM)
			RecLock("SFT", .F.)
				SFT->FT_ITEM := SD1->D1_ITEM
			SFT->(MsUnLock())
		EndIf

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

	RestArea(aAreaSFT)
	RestArea(aAreaCD2)
	RestArea(aAreaSD1)
	RestArea(aArea)
Return nil


Static Function DocEmail()
	Local xAssunto  := "Recebimento de Mercadoria menor que nota fiscal"
	Local xaDados 	:= {}
	Local xHTM		:= ""
// Local cFornece  := ""
	Local nDif	    := 0
	Local xEmail	:= GetMV("MV_RECINS",,"miguel.bernardo@vistaalegre.agr.br,"+;
		"arthur.toshio@vistaalegre.agr.br") // Emails que receberao o email da funcao FECHAMES

	// xEmail := "miguel.bernardo@vistaalegre.agr.br"

	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	aTelEmp:= FisGetTel(SM0->M0_TEL)
	cTelEmp := "" //IIF(aTelDest[1] > 0,U_ConvType(aTelDest[1],3),"") // Código do Pais
	cTelEmp += "("+ IIF(aTelEmp[2] > 0,U_ConvType(aTelEmp[2],3),"") + ") " // Código da Área
	cTelEmp += IIF(aTelEmp[3] > 0,U_ConvType(aTelEmp[3],9),"") // Código do Telefone
	//cFoneEmp:= "Telefone: " + cFoneEmp

	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacin g: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)
	xHTM += 		" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
	xHTM += '<hr>'
	cTitulo := "Quantidade Recebida Ultrapassou a Tolerância"
	xHTM += '<b><font face="Verdana" SIZE=3>'+cTitulo+'</b></p>'
	xHTM += '<hr>'
	xHTM += '<font face="Verdana" SIZE=2>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
	xHTM += '<br><br>'
	xHTM += '<div>'
	cFornec := Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")
	xHTM += 'Fornecedor: ' + cFornec +'</b>'
	xHTM += '<br>'
	xHTM += 'Nota Fiscal '+SD1->D1_DOC+'-'+SD1->D1_SERIE+'</b>'
	xHTM += '<br>'
	xHTM += 'Emissão ' +DTOC(SD1->D1_EMISSAO) + '</b>'
	xHTM += '<br>'
	cProd := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")
	xHTM += 'Produto: ' +cProd+ '</b>'
	xHTM += '<br>'
	nQtNf := SD1->D1_QUANT
	xHTM += 'Peso NF: ' +AllTrim(str(nQtNf))+ '</b>'
	xHTM += '<br>'
	nQtRec := SD1->D1_X_PESOB
	xHTM += 'Peso Chegada: ' +AllTrim(Str(nQtRec))+ '</b>'
	xHTM += '<br>'
	nDif := (SD1->D1_QUANT - SD1->D1_X_PESOB)
	xHTM += 'Diferença: '+ AllTrim(Str(nDif)) +'</b>'
	xHTM += '<br>'
	xHTM += 'Data de Lançamento da NF ' +DTOC(SF1->F1_X_DTINC)+ '</b>'
	xHTM += '</div>'
	xHTM += '</BODY></HTML>'

	MemoWrite( "C:\totvs_relatorios\difrecebimento.html", xHTM )

	Processa({ || u_EnvMail(xEmail	,;		 //_cPara
				"" 					,;		 //_cCc
				""					,;		 //_cBCC
				xAssunto			,;		 //_cTitulo
				xaDados				,;		 //_aAnexo
				xHTM				,;		 //_cMsg
				.T.)}, "Enviando e-mail...") //_lAudit
Return nil


/****************************************************************
Ponto de Entrada - Exclusão do Documento de Entrada
****************************************************************/
/* MB : 10.02.2020 -> Retirado de operacao a pedido do Toshio, 
        nao esta mais em uso o processo implementado neste P.E.
 
User Function SD1100E()
Local aArea 	:= GetArea()
Local cB1Diari 	:= ''
Local QryDia 	:= ''
		// Tratamento para limpar flags das Diarias, quando ocorrer a exclusao da NF
		cB1Diari := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_X_DIARI")
	If cB1Diari=="S"
			QryDia :=  "  SELECT * "
			QryDia +=  "  FROM "+RetSqlName('SZ7')+" SZ7 "
			QryDia +=  "  WHERE SZ7.D_E_L_E_T_ = '' "
			QryDia +=  "  AND Z7_SERVICO = '"+SD1->D1_COD+"' "
			QryDia +=  "  AND Z7_FORNECE = '"+SD1->D1_FORNECE+"' "
			QryDia +=  "  AND Z7_LOJA 	 = '"+SD1->D1_LOJA+"' "
			QryDia +=  "  AND Z7_DOC 	 = '"+SD1->D1_DOC+"' "
			QryDia +=  "  AND Z7_SERIE 	 = '"+SD1->D1_SERIE+"' "
			QryDia +=  "  AND Z7_ITEMNF	 = '"+SD1->D1_ITEM+"' "
					
		If Select("QRYZ7") > 0
			 	QRYZ7->(DbCloseArea())
		EndIf
			TcQuery QryDia New Alias "QRYZ7"
					
		While  !QRYZ7->(EOF())
			 	SZ7->(dbGoTo(QRYZ7->R_E_C_N_O_))			
			 	RecLock("SZ7",.F.)
			 		Z7_FILDOC	:= ''
			 		Z7_DOC		:= ''
			 		Z7_SERIE	:= ''
			 		Z7_ITEMNF	:= ''
			 		Z7_STATUS	:= 'P' // Pendente	     
			 	SZ7->(MSUnLock())
				QRYZ7->(dbSkip()) 			 				
		EndDo
	EndIf
RestArea(aArea)
Return	              
*/


/****************************************************************
Função para lançamento de movimento interno automatico
****************************************************************/
/*
cTFil		-> D3_FILIAL (Filial) 
cTipo		-> Tipo (E-Entrada, S-Saida) 
cTTM		-> D3_TM (Tipo de Movimentacao) 
cTProd		-> D3_COD (Produto) 
cTLocal		-> D3_LOCAL (Armazem/Local)
nTQtd 		-> D3_QUANT (Quantidade)
nTCusto		-> D3_CUSTO1 (Custo da moeda 1)	
dTData		-> D3_EMISSAO (Data Emissao)
cTObs		-> D3_X_OBS (Observacao)
cTCC		-> D3_CC (Centro de Custo)
cTItemCta	-> D3_ITEMCTA (Item Contabil) 
cTCLVL		-> D3_CLVL (Classe Valor)
*/
Static Function LanClassif(cTFil, cTipo, cTTM, cTProd, cTLocal, nTQtd,;
		nTCusto, dTData, cTObs, cTCC, cTItemCta, cTCLVL,;
		cFornece, cDocumento, RECNOSD3 )
	Local aMovimento  	:= {}
	Private lMsErroAuto := .F.

//Analisa os tipos e monta os dois arrays (Entrada e Saída)
//	If (cTipo == "E") // Entrada
	aMovimento := {{"D3_FILIAL"	, cTFil				, NIL},;
		{"D3_TM"		, cTTM				, NIL},;
		{"D3_COD"		, cTProd			, NIL},;
		{"D3_LOCAL"		, cTLocal           , NIL},;
		{"D3_EMISSAO"	, dTData          	, NIL},;
		{"D3_X_QTD"		, nTQtd      		, NIL},;
		{"D3_QUANT"		, nTQtd      		, NIL},;
		{"D3_CUSTO1"	, nTCusto      		, NIL},;
		{"D3_X_OBS"    	, cTObs			    , NIL},;
		{"D3_CC"    	, cTCC			    , NIL},;
		{"D3_ITEMCTA"   , cTItemCta			, NIL},;
		{"D3_CLVL"    	, cTCLVL            , NIL},;
		{"D3_DOC"    	, cDocumento        , NIL},;
		{"D3_FORNECE"   , cFornece			, NIL},;
		{"D3_NOMEFOR"   , Posicione('SA2', 1, xFilial('SA2')+cFornece, 'A2_NOME')			, NIL}}
	// Inclui D3_OBSERVA - SE FOR MOR MOVIMENTAÇÃO PREENCHER COM NUMERO DA NF, SERIE E DATA DE EMISSAO
//	EndIf

	// Gerar Movimento Interno
	If (cTipo == "E") // Entrada
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento,3)

	ElseIf cTipo == "X" // Exclusão
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento, 5)

	EndIf

	If lMsErroAuto
		MostraErro()
	EndIf

Return !lMsErroAuto

User Function ConvType(xValor,nTam,nDec)

	Local cNovo := ""
	DEFAULT nDec := 0
	Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
	EndCase
Return(cNovo)


// // antes da gravacao
// User Function MT100AG()
// 	ConOut('MT100AG' /* + U_AtoS(aColsSDE) */) 
// Return
// 
// // depios da gravacao
// User Function MT100AGR()
// 	ConOut('MT100AGR' /* + U_AtoS(aColsSDE) */) 
// Return

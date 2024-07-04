#INCLUDE "DIEFCE.CH"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DiefCe    ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para a DIEF - CE               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array com as informacoes preenchidas no CFP.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN -> 1-Gerar a rotina, 2-Excluir temporarios.            ³±±
±±³          ³ExpA -> Array contendo os TRB para exclusao.                ³±±
±±³          ³ExpD -> Data incial do periodo                              ³±±
±±³          ³ExpD -> Data final do periodo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DiefCe (nOpcao, aTrbs, dDataDe, dDataAte,cNrLivro, lConsolida, lRegSTQ)

	Local	aRet  		:=	{}
	Local	aStru		:=	{}
	Local	aSf6		:=	{"SF6", ""}
    Local	aMVGNRCE	:=  {}
	Local	aMVAIDFCE	:=	&(GetNewPar ("MV_AIDFCE", "{}"))
	Local	aTotaliza	:=	{"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local	cQuery		:=	""
	Local	cIndex		:=	""
	Local	cSF3		:=	"SF3"
	Local	cSF6		:=	"SF6"
	Local	cArq		:=	""
	Local	cMVUNDIEF	:=	GetNewPar ("MV_UNDIEF",	"")
	Local	cUn			:=	""
	Local	cControle	:=	"00000000000000000000"
	Local	cMVA2SUFR	:=	GetNewPar ("MV_A2SUFR", "")		//Campo da tabela SA2 que se relaciona o numero de inscricao no suframa para o fornecedor
	Local	cMVPRDPRI	:=	GetNewPar ("MV_PRDPRI", "")		//Campo da tabela SB5 que identifica se o produtos eh primario ou nao para a geracao do registro PRI.
	Local	cMunic		:=	""
	Local	cEstEntr	:=	""
	Local	cUnid		:=	""
	Local	cMVDISPAUT	:=	GetNewPar ("MV_DISPAUT", "")	//Campos da tabela SF1 / SF2 que possuem os campos com numero do formulario de impressao da NF
	Local	cTipoCompl	:=	""
	Local 	cTitulo		:=	""
	Local	cMensagem	:=	""
	Local	cHelp		:=	""
	Local	cMVDIEFECF	:=	GetNewPar("MV_DIEFECF","")		//Indica quais situacoes tributarias (D2_CLASFIS) deverao ser tratadas como Nao incidencia no cupom fiscal
	Local 	cModelo		:= 	""

	Local	lServico	:=	.F.
	Local	lCFC		:=	.F.
	Local	lDOC		:=	.F.
	Local	lComplemento:=	.F.

	Local	nI			:=	0
	Local	nMVA2SUFR	:=	SA2->(FieldPos (cMVA2SUFR))
	Local	nMVPRDPRI	:=	SB5->(FieldPos (cMVPRDPRI))
	Local	nQtd		:=	0
	Local   nItensD1    :=  1
 	Local   nItensD2    :=  1
                                                      
	Local	cVersao		:= _aTotal[004][1][11]		//Versao do Layout    
	Local   cMunicCo    := ""
	Local   cEstCo      := ""
	Local   aArray		:=	{"","","",0,"",""}						
	Local   lQuery      := .F.				
	Local  lIntTms		:= SuperGetMV("MV_INTTMS",,.F.) .And. !SuperGetMV("MV_DIEFTMS",,.F.)

Local	cMsg		:= ''
Local 	nOpca		:= 0
Local 	lFirst		:= .T.
 
Local 	aAreaSM0	:= SM0->(GetArea())
	#IFDEF TOP
		Local	aStruSF3	:=	{}
		Local	nX			:=	0
	#ENDIF
	//      
// Variáveis para o controle de geração consolidada
Local nFilAtu		:= 0   
Local lPriTmp		:= .T.
Local lPassou 		:= .T.  
Local aValid		:= {}
Default lConsolida	:= .F.
Private aFilCons	:= {}		// Será utilizada nas sub-funções
Default lRegSTQ		:= .T.

// Apaga todos os arquivos temporários
If (nOpcao==2) 
	For nI := 1 To Len (aTrbs)
		If (File (aTrbs[ni, 1]+GetDBExtension ()))
			DbSelectArea (aTrbs[ni, 2])
			(aTrbs[ni,2])->(DbCloseArea ())
			FErase (aTrbs[nI, 1]+GetDBExtension ())
			FErase (aTrbs[nI, 1]+OrdBagExt ())
		Endif	
	Next
	Return

EndIf	
    
    //verifica se parametro foi criado corretamente
    If AT("{", SuperGetMV("MV_GNRCE",,.F.))<=0 .Or. AT("}", SuperGetMV("MV_GNRCE",,.F.))<=0
        MV_GNRCE := "{'','','','','',''}"
        aMVGNRCE := {'','','','','',''}
    Else
   	    aMVGNRCE :=	&(GetNewPar ("MV_GNRCE", "{'','','','','',''}"))       
    EndIf
	If ValType(aMVGNRCE)=="U" .Or. !Len(aMVGNRCE)>0	    
		aMVGNRCE := {'','','','','',''}
	EndIf
	
	//	
	If (nMVPRDPRI==0)
		cTitulo		:= STR0001 // "Parâmetro Inconsistente"
		cMensagem	:= STR0002 // "O parâmetro MV_PRDPRI n]ao está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0003 // "Para que a rotina seja processada corretamente, "
		cMensagem	+= STR0004 // "será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0005 // "Incluir o parâmetro MV_PRDPRI na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0006 // "<campo da tabela SB5 com a identificação de produto primário>. "
		cHelp		+= STR0007 // "Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
	EndIf
	//
	If Empty (aMVGNRCE) .Or. Len (aMVGNRCE)<>6 .Or. !Empty(aMVGNRCE[1]) .And. SF6->(FieldPos (aMVGNRCE[1]))==0 .Or. !Empty(aMVGNRCE[2]) .And. SF6->(FieldPos (aMVGNRCE[2]))==0 .Or.;
		!Empty(aMVGNRCE[3]) .And. SF6->(FieldPos (aMVGNRCE[3]))==0 .Or. !Empty(aMVGNRCE[4]) .And. SF6->(FieldPos (aMVGNRCE[4]))==0 .Or. !Empty(aMVGNRCE[5]) .And. SF6->(FieldPos (aMVGNRCE[5]))==0 .Or. !Empty(aMVGNRCE[6]) .And. SF6->(FieldPos (aMVGNRCE[6]))==0
		cTitulo		:= STR0001 // "Parâmetro Inconsistente"
		cMensagem	:= STR0008 // "O parâmetro MV_GNRCE n]ao está definido no dicionário, ou seu conteúdo não foi preenchido corretamente. "
		cMensagem   += STR0003 // "Para que a rotina seja processada corretamente, "
		cMensagem	+= STR0004 // "será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0009 // "Incluir o parâmetro MV_GNRCE na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0010 // "<campos da tabela SF6 referentes à autenticação bancária, atualização monetária, juros, multa, convênio.>. "
		cHelp		+= STR0007 // "Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
	EndIf	
	//
	If (nMVA2SUFR==0)
		cTitulo		:= STR0001 // "Parâmetro Inconsistente"
		cMensagem	:= STR0011 // "O parâmetro MV_A2SUFR n]ao está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0003 // "Para que a rotina seja processada corretamente, "
		cMensagem	+= STR0004 // "será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0012 // "Incluir o parâmetro MV_A2SUFR na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0013 // "<campo da tabela SA2 com o número de inscrição na SUFRAMA do fornecedor>. "
		cHelp		+= STR0007 // "Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
	EndIf       
	//
	If Empty(cMVDIEFECF)
		cTitulo		:= STR0001 // "Parâmetro Inconsistente"
		cMensagem	:= STR0014 // "O parâmetro MV_DIEFECF não está definido no dicionário de dados ou o seu conteúdo é inválido. "
		cMensagem   += STR0015 // "Caso sejam exportadas informações sobre cupom fiscal, "
		cMensagem	+= STR0004 // "será necessário respeitar a solução proposta abaixo."
		cHelp		:= STR0016 // "Incluir o parâmetro MV_DIEFECF na tabela SX6 com a seguinte estrutura: "
		cHelp		+= STR0017 // "<situacoes tributarias que deverao ser tratadas como Nao Incidencia nos itens do cupom fiscal>. "
		cHelp		+= STR0007 // "Para maiores referências, consultar a documentação que acompanha a rotina."
		xMagHelpFis(cTitulo,cMensagem,cHelp)
	EndIf       
	//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONAMENTO DAS TABELAS UTILIZADAS   ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
DT6->(DbSetOrder(1))
DTC->(DbSetOrder(7))
SA1->(DbSetOrder(1))
SA2->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SB5->(DbSetOrder(1))
SD1->(DbSetOrder(1))
SD2->(DbSetOrder(3))
SF1->(DbSetOrder(1))
SF2->(DbSetOrder(1))
SF3->(DbSetOrder(1))
SF4->(DbSetOrder(1))
SM0->(DbSetOrder(1))

If lConsolida
	aFilCons := aFilsCalc

	// Irá checar se há filiais fora do Estado do CE selecionadas para exibir mensagem
	For nFilAtu := 1 to Len(aFilCons)
		// Verifica se estao marcadas
		If !aFilCons[ nFilAtu, 1 ]
			Loop
		EndIf
		
		If nOpca == 0 .and. SM0->(dbSeek(cEmpAnt+aFilCons[ nFilAtu, 2 ],.F.)) .and. SM0->M0_ESTENT # 'CE'
			cMsg	:= 'Foram selecionadas filiais em Estados diferentes do Ceará.'+Chr(10)+Chr(13)+'Como deseja prosseguir?'
			nOpca	:= Aviso('Atenção',cMsg,{'Manter','Remover'},1)

			If nOpca == 2	// Remover filiais
				For nFilAtu := nFilAtu to Len(aFilCons)
					If aFilCons[ nFilAtu, 1 ] .and. SM0->(dbSeek(cEmpAnt+aFilCons[ nFilAtu, 2 ],.F.)) .and. SM0->M0_ESTENT # 'CE'
						aFilCons[ nFilAtu, 1 ]	:= .F.    
					Else 
						aAdd(aValid,aFilCons[nFilAtu])
						IF  lPassou
							cFilAnt:= aFilCons[ nFilAtu, 2 ]
						    lPassou:= .F.  
						EndIF
					EndIf
      			Next
						
			EndIf
		EndIf
	Next
	
Else
	nFilAtu := Ascan(aFilsCalc,{|x|AllTRim(x[2])==AllTrim(cFilAnt)})
	aAdd(aFilCons, {} )
	aFilCons[1]	:= aFilsCalc[nFilAtu]
EndIf
IIF(!Empty(aValid),aFilCons:= aValid,)
//IIF(!Empty(aValid),aFilsCalc:= aValid,)
// Formar loop principal aqui, rodar todas as filiais
For nFilAtu := 1 to Len(aFilCons)
	
	// Verifica se estao marcadas
	If !aFilCons[ nFilAtu, 1 ]
		Loop
	EndIf

	cFilAnt := aFilCons[ nFilAtu, 2 ]
    
    If !lConsolida .or. lPriTmp
	   	aRet 	:= fCriaTemp()
	   	lPriTmp	:= .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera Registro Tipo INV/EST - Inventario	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(Alltrim(_aTotal[004][1][13]),2)$"02"
		GeraINV()
		Return (aRet)
	Endif		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Processa Layout Versao 3.0                              ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If cVersao == "300".Or. cVersao == "400".Or. cVersao == "500" .Or. cVersao == "600" .Or. cVersao == "608"
		//Grava Registro Tipo VIC - Substitui o VIR na versao 3.00
		GeraVIC()
		//Grava Registro Tipo STQ - Regime ME, MS, ESPECIAL e OUTROS
		If Left(Alltrim(_aTotal[004][1][1]),2) $ "03/04/05/06" .And. lRegSTQ
			GeraSTQ()
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESSAMENTO DOS DOCUMENTOS DE ENTRADAS³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DbSelectArea('SF3')
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
		    lQuery := .T.
			cSF3		:=	"SF3_ENTRADA"
			aStruSF3	:=	SF3->(DbStruct ())
			//
			cQuery 		:=	"SELECT * "
			cQuery		+=	"FROM "+RetSqlName ("SF3")+" SF3 "
			cQuery		+=	"WHERE "
			cQuery 		+=	"F3_FILIAL='"+xFilial ("SF3")+"' AND "
			cQuery 		+= 	"F3_ENTRADA BETWEEN '"+DToS (dDataDe)+"' AND '"+DToS (dDataAte)+"' AND "
			cQuery		+=	"SUBSTRING(F3_CFO, 1, 1) IN ('1','2','3') AND F3_ESPECIE NOT IN('NFFA','NFA') AND "
			If cNrLivro <> "*"
				cQuery += "F3_NRLIVRO ='"+ cNrLivro +"' AND "
			EndIf	
			cQuery		+=	"D_E_L_E_T_=' ' "
			//
			//Verifico se devo considerar notas fiscais de servico
			If !(lServico)
				cQuery	+=	"AND F3_CODISS=' ' AND F3_TIPO<>'S' "
			EndIf
			//
			cQuery 		+=	"ORDER BY "+SqlOrder (SF3->(IndexKey ()))
			//
			cQuery := ChangeQuery (cQuery)
			DbUseArea (.T., "TOPCONN", TcGenQry (,, cQuery), cSF3)
		
			For nX := 1 To Len (aStruSF3)
				If (aStruSF3[nX][2]<>"C") .And. (FieldPos (aStruSF3[nX][1])<>0)
					TcSetField (cSF3, aStruSF3[nX][1], aStruSF3[nX][2], aStruSF3[nX][3], aStruSF3[nX][4])
				EndIf
			Next nX
		Else
	#ENDIF
			cIndex	:=	CriaTrab (NIL,.F.)
			cQuery	:=	"F3_FILIAL='"+xFilial("SF3")+"' .And. DToS (F3_ENTRADA)>='"+DToS (dDataDe)+"' .And. DToS (F3_ENTRADA)<='"+DToS (dDataAte)+"' .And. SubStr (F3_CFO, 1, 1)$'123' "
			//
			//Verifico se devo considerar notas fiscais de servico
			If !(lServico)
				cQuery	+=	".And. Empty (F3_CODISS) .And. !'S'$F3_TIPO "
			EndIf
			//
			IndRegua (cSF3, cIndex, (cSF3)->(IndexKey ()),, cQuery)
	#IFDEF TOP
		EndIf
	#ENDIF
	(cSf3)->(DbGoTop ())
	//
	Do While !(cSF3)->(Eof ())
		//
		//Para notas fiscais canceladas monto somente o registro DCE
		If !(cSF3)->F3_DTCANC==CToD ("  /  /  ") .And. Empty((cSF3)->F3_PDV)
			cModelo	:=	aModNot((cSF3)->F3_ESPECIE)
			MontDCE (cSF3, aMVAIDFCE, cMVDISPAUT, cModelo, .F.)
			//
			SkipSf3 (cSF3)
			Loop
		EndIf
		//
		cControle		:=	StrZero (Val (cControle)+1, 20)		
		aTotaliza		:=	{"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		aTotaliza[1]	:=	cControle		
		cEstEntr		:=	""
		//
		//Gravavao do registro PAR
		cMunic	:=	PAR (cSF3, "E", cControle, nMVA2SUFR,, @cEstEntr)	//So SF3, SA1 e SA2
		//
		//Se encontrar SF1 correspondente continuo ou aborta o processamento
		If SF1->(DbSeek (xFilial ("SF1")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro DFR somente na saida conforme e-mail de 11/10/2005³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//I-ICMS P-IPI C-Preco/Frete
			lComplemento	:=	("I"$SF1->F1_TIPO .Or. "P"$SF1->F1_TIPO .Or. "C"$SF1->F1_TIPO)
			cTipoCompl		:=	SF1->F1_TIPO
			//
			//Se encontrar SD1 correspondente continuo ou aborta o processamento
			If SD1->(DbSeek (xFilial ("SD1")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA))
				//
				cChave	:=	xFilial("SD1")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA
				nItensD1:=  1
				Do While !SD1->(Eof ()) .And.;
					cChave==xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
					//
					//Preciso gerar de acordo com o documento fiscal e tambem por cfop os registros
					If (SD1->D1_CF==(cSF3)->F3_CFO)
						//
						//Nao gerar iten para notas fiscais de complemento, pois o validador acusa erro
						If !(lComplemento)
							aTotaliza[5]	+=	SD1->D1_VALDESC+SD1->D1_DESCICM
							//Verifica se TES está com campo F4_INCSOL como "N"
							IF AllTrim(Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_INCSOL")) == "N"
								aTotaliza[6]	+=	(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_SEGURO+SD1->D1_DESPESA+SD1->D1_VALFRE)-SD1->D1_VALDESC-SD1->D1_DESCICM
							Else
								aTotaliza[6]	+=	(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_SEGURO+SD1->D1_DESPESA+SD1->D1_VALFRE)-SD1->D1_VALDESC-SD1->D1_DESCICM
							EndIf	
							aTotaliza[2]	+=	SD1->D1_TOTAL
							aTotaliza[3]	+=	SD1->D1_VALFRE
							aTotaliza[4]	+=	SD1->D1_DESPESA
							aTotaliza[18]	+=	SD1->D1_SEGURO
							//
							//Se encontrar SF4 correspondente continuo ou aborta o processamento
							If SF4->(DbSeek (xFilial ("SF4")+SD1->D1_TES))				
								//
								//Se encontrar SB1 correspondente continuo ou aborta o processamento
								If (SB1->(DbSeek (xFilial ("SB1")+SD1->D1_COD)))				
									//Verifica preenchimento do parametro MV_UNDIEF
									If !Empty(cMVUNDIEF)
										nPos := at(SB1->B1_UM+"=",cMVUNDIEF)
										If nPos > 0
											cUn := Substr(cMVUNDIEF,at(SB1->B1_UM+"=",cMVUNDIEF)+3,2)
										Else
											cUn := SB1->B1_UM
			                            Endif
	    		                    Else
	            			           	cUn := SB1->B1_UM
			                        Endif
			        				//
									If !(PRD->(DbSeek (SD1->D1_COD))) .And. !Left(Alltrim(_aTotal[004][1][1]),2) $ "06"
										RecLock ("PRD", .T.)
											PRD->PRD_CODI	:=	SD1->D1_COD
											PRD->PRD_DESC	:=	SB1->B1_DESC
											PRD->PRD_UNID	:=	Iif(AllTrim(cUn)=="TL","KG",cUn)
											PRD->PRD_TPPR	:=	Iif (Empty (SB1->B1_CODISS), 1, IiF ("S"$SF4->F4_ICM, 2, 3))
											PRD->PRD_NCM	:=	SB1->B1_POSIPI
											PRD->PRD_CLPR	:=	""
										MsUnLock ()	
									EndIf
									//
								    //Se encontrar SB5 correspondente continuo ou aborta o processamento
									If (SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD)))
										//
										//Gravacao do registro tipo PRI
										If (nMVPRDPRI<>0) .And. (SB5->(FieldGet(nMVPRDPRI))$"1S")
											If (SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)) .And. SA2->A2_EST == "CE")
												cMunic := SubStr(SA2->A2_COD_MUN,1,5)
											EndIf

											If SA2->A2_EST == "CE"
												If !(PRI->(dbSeek(StrZero(Val(cMunic),5))))
													RecLock ("PRI", .T.)
													PRI->PRI_MUNI := Val(cMunic)
												Else
													RecLock ("PRI", .F.)
												EndIf
												PRI->PRI_VRAQ += SD1->D1_TOTAL
												MsUnLock ()
											EndIf
										EndIf
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Gravacao dos itens do documento fiscal.                 ³
										//³A variavel cControle identifica um bloco de nota fiscal.³
										//³Exemplo:                                                ³
										//³DOC ou CFC                                              ³
										//³      ITE                                               ³
										//³      DCT                                               ³
										//³      PAR                                               ³
										//³      REF                                               ³
										//³TOT                                                     ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										//Somente incluo conforme conforme lancado na NF
										If !Left(Alltrim(_aTotal[004][1][1]),2) $ "06"
											RecLock ("ITE", .T.)
												ITE->ITE_CONT	:=	cControle
												ITE->ITE_ITEM	:=	nItensD1++							
												ITE->ITE_CODI	:=	SD1->D1_COD
												ITE->ITE_QTDE	:=	Iif(AllTrim(cUn)=="TL",SD1->D1_QUANT*1000,SD1->D1_QUANT)
												_nVunit 		:=  SD1->D1_VUNIT-SD1->D1_DESCICM-(SD1->D1_VALDESC/SD1->D1_QUANT)
												ITE->ITE_VRUN	:=	Iif(AllTrim(cUn)=="TL",_nVunit/1000,_nVunit)
												ITE->ITE_CFOP	:=	Val (SD1->D1_CF)
												ITE->ITE_BCIC	:=	SD1->D1_BASEICM
												ITE->ITE_ICMS	:=	SD1->D1_VALICM
												ITE->ITE_BCSU	:=	SD1->D1_BRICMS
												ITE->ITE_ICSU	:=	SD1->D1_ICMSRET
												ITE->ITE_CVF	:=	Iif (SF4->F4_LFICM$"T", 1, Iif (SF4->F4_LFICM$"IN", 2, 3))
												ITE->ITE_BCIP	:=	Iif (SF4->F4_LFIPI$"T", SD1->D1_BASEIPI, 0)
												ITE->ITE_IIPI	:=	Iif (SF4->F4_LFIPI$"IN", SD1->D1_BASEIPI, 0)
												ITE->ITE_OIPI	:=	Iif (SF4->F4_LFIPI$"O", SD1->D1_BASEIPI, 0)
												ITE->ITE_IPI	:=	Iif (SF4->F4_LFIPI$"T", SD1->D1_VALIPI, 0)
												ITE->ITE_CVFI	:=	Iif (SF4->F4_LFIPI$"T", 1, Iif (SF4->F4_LFIPI$"IN", 2, 3))
												ITE->ITE_DESC	:=	SD1->D1_VALDESC+SD1->D1_DESCICM
												ITE->ITE_ACRE	:=	0
											MsUnLock ()
										EndIf
										//
										//Informacoes para o Registro DCT
										//Verifica preenchimento do parametro MV_UNDIEF
										If !Empty(cMVUNDIEF)
											nPos := at(SD1->D1_UM+"=",cMVUNDIEF)
											If nPos > 0
												cUn := Substr(cMVUNDIEF,at(SD1->D1_UM+"=",cMVUNDIEF)+3,2)
											Else
												cUn := SD1->D1_UM
	                        	            Endif
	                            	    Else
	                                		cUn := SD1->D1_UM
	                                    Endif
										cUnid	:=	cUn
										nQtd	+=	SD1->D1_QUANT
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					//
					SD1->(DbSkip ())
				EndDo

				cUnid		:=	""
				nQtd		:=	0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravacao do cabecalho dos documentos fiscais³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DOC_CFC (aMVAIDFCE, SF1->F1_FRETE, cControle, cSF3, cMVDISPAUT)	//So SF3
			EndIf
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para nao duplicar SF1 quando a mesma nota gerar mais de um SF3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave	:=	(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
		Do While !(cSF3)->(Eof ()) .And.;
			cChave==(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
			//
			//Totalizo o documento fiscal de acordo com o livro fiscal
			If (lComplemento)	
				//Para o valor total da NF de compelemente de ICMS [2] devo pegar o valor do ICMS pois para este tipo de NF o VALCONT deve estar zerado.
				//	Agora nas NF de Complemento de Preco/Frete e IPI, devo utilizar o VALCONT, pois deve contar preenchido.
				If ("I"$cTipoCompl)	//ICMS
					aTotaliza[2]	+=	(cSF3)->F3_VALICM
				Else
					aTotaliza[2]	+=	(cSF3)->F3_VALCONT
				EndIf
				aTotaliza[4]	+=	(cSF3)->F3_DESPESA
				aTotaliza[6]	+=	(cSF3)->F3_VALCONT
			EndIf
			aTotaliza[7]	+=	(cSF3)->F3_ICMSRET
			aTotaliza[8]	+=	(cSF3)->F3_BASEICM
			aTotaliza[9]	+=	(cSF3)->F3_VALICM
			aTotaliza[10]	+=	(cSF3)->F3_ISENICM
			aTotaliza[11]	+=	(cSF3)->F3_OUTRICM
			aTotaliza[12]	+=	(cSF3)->F3_BASERET
			aTotaliza[13]	+=	(cSF3)->F3_ICMSRET
			aTotaliza[14]	+=	(cSF3)->F3_BASEIPI
			aTotaliza[15]	+=	(cSF3)->F3_ISENIPI
			aTotaliza[16]	+=	(cSF3)->F3_OUTRIPI
			aTotaliza[17]	+=	(cSF3)->F3_VALIPI			
			//
			(cSF3)->(DbSkip ())
		EndDo
		//
		//totalizador de documentos fiscais
		TOT (aTotaliza)	//So no array passado como parametro
	EndDo
	// Fecha Doc Entrada
	If lQuery
		dbSelectArea(cSF3)
		dbCloseArea()
	Else
		dbSelectArea(cSF3)
		RetIndex(cSF3)
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESSAMENTO DOS DOCUMENTOS DE SAIDAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ('SF3')
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
		    lQuery := .T.
			cSF3		:=	"SF3_SAIDA"
			aStruSF3	:=	SF3->(DbStruct ())
			cQuery 		:=	"SELECT * "
			cQuery		+=	"FROM "+RetSqlName ("SF3")+" SF3 "
			cQuery		+=	"WHERE "
			cQuery 		+=	"F3_FILIAL='"+xFilial ("SF3")+"' AND "
			cQuery 		+= 	"F3_ENTRADA BETWEEN '"+DToS (dDataDe)+"' AND '"+DToS (dDataAte)+"' AND "
			cQuery		+=	"SUBSTRING(F3_CFO, 1, 1) IN ('5','6','7') AND F3_ESPECIE NOT IN('NFFA','NFA') AND "
			If cNrLivro <> "*"
				cQuery += "F3_NRLIVRO ='"+ cNrLivro +"' AND "
			EndIf	
			cQuery		+=	"D_E_L_E_T_=' ' AND "
			cQuery		+=	"F3_PDV='' "
			//
			//Verifico se devo considerar notas fiscais de servico
			If !(lServico)
				cQuery	+=	"AND F3_CODISS=' ' AND F3_TIPO<>'S' "
			EndIf
			//
			cQuery 		+=	"ORDER BY "+SqlOrder (SF3->(IndexKey ()))
			//
			cQuery := ChangeQuery (cQuery)
			DbUseArea (.T., "TOPCONN", TcGenQry (,, cQuery), cSF3)
		
			For nX := 1 To Len (aStruSF3)
				If (aStruSF3[nX][2]<>"C") .And. (FieldPos (aStruSF3[nX][1])<>0)
					TcSetField (cSF3, aStruSF3[nX][1], aStruSF3[nX][2], aStruSF3[nX][3], aStruSF3[nX][4])
				EndIf
			Next nX
		Else
	#ENDIF
			cIndex	:=	CriaTrab (NIL,.F.)
			cQuery	:=	"F3_FILIAL='"+xFilial("SF3")+"' .And. DToS (F3_ENTRADA)>='"+DToS (dDataDe)+"' .And. DToS (F3_ENTRADA)<='"+DToS (dDataAte)+"' .And. SubStr (F3_CFO, 1, 1)$'567' .And. Empty (F3_PDV) "
			//
			//Verifico se devo considerar notas fiscais de servico
			If !(lServico)
				cQuery	+=	".And. Empty (F3_CODISS) .And. !'S'$F3_TIPO "
			EndIf
			//
			IndRegua (cSF3, cIndex, (cSF3)->(IndexKey()),, cQuery)
	#IFDEF TOP
		EndIf
	#ENDIF
	(cSf3)->(DbGoTop ())
	//
	Do While !(cSF3)->(Eof ())
		//
		//Monto o Registro DCE - Qdo. Regime de Pagamento for ME, MS, OUTROS E ESPECIAL
		If Left(Alltrim(_aTotal[004][1][1]),2) $ "03/04/05/06" .And. Empty((cSF3)->F3_DTCANC) .And. ModDief (aModNot((cSF3)->F3_ESPECIE))$ "1|2|3|4|5|6|7|8|9"
			MontDCE2 (cSF3, aMVAIDFCE, cMVDISPAUT)
		Endif

		//Para notas fiscais canceladas monto somente o registro DCE
		If !(cSF3)->F3_DTCANC==CToD ("  /  /  ") .And. Empty((cSF3)->F3_PDV)
			cModelo	:=	aModNot((cSF3)->F3_ESPECIE)
			MontDCE (cSF3, aMVAIDFCE, cMVDISPAUT, cModelo, .F.)
			//
			SkipSf3 (cSF3)
			Loop
		EndIf
		//
		cControle		:=	StrZero (Val (cControle)+1, 20)
		aTotaliza		:=	{"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,""}		//Posicao 19-CFOP
		aTotaliza[1]	:=	cControle
		aTotaliza[19]	:=	(cSF3)->F3_CFO
		cEstEntr		:=	""
		//
		//Gravavao do registro PAR
		cMunic	:=	PAR (cSF3, "S", cControle, nMVA2SUFR,, @cEstEntr)
		//
		//Se encontrar SF2 correspondente continuo ou aborta o processamento
		If SF2->(DbSeek (xFilial ("SF2")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA))
			//
			//I-ICMS P-IPI C-Preco/Frete
			lComplemento	:=	("I"$SF2->F2_TIPO .Or. "P"$SF2->F2_TIPO .Or. "C"$SF2->F2_TIPO)
			cTipoCompl		:=	SF2->F2_TIPO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro DFR somente na saida conforme e-mail de 11/10/2005³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Processamento de documentos diferidos. (Devolucao, Complemento, Beneficiamento)
            DFR (cSF3, cControle, aMVAIDFCE, lComplemento, cMVDISPAUT,.F.)    //So SF3
			//
			//Se encontrar SD2 correspondente continuo ou aborta o processamento
			If SD2->(DbSeek (xFilial ("SD2")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA))
				//
				cChave	:=	xFilial("SD2")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA
				nItensD2:=  1
				Do While !SD2->(Eof ()) .And.;
					cChave==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
					//
					//Preciso gerar de acordo com o documento fiscal e tambem por cfop os registros
					If (SD2->D2_CF==(cSF3)->F3_CFO)
						//
						//Nao gerar iten para notas fiscais de complemento, pois o validador acusa erro
						If !(lComplemento)
							aTotaliza[5]	+=	SD2->D2_DESCON+SD2->D2_DESCICM

							//Verifica se TES está com campo F4_INCSOL como "N"
							IF AllTrim(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_INCSOL")) == "N"
								aTotaliza[6]	+=	SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_SEGURO+SD2->D2_DESPESA+SD2->D2_VALFRE-SD2->D2_DESCICM	//o D2_TOTAL ja esta com o desconto
							Else
								aTotaliza[6]	+=	SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET+SD2->D2_SEGURO+SD2->D2_DESPESA+SD2->D2_VALFRE-SD2->D2_DESCICM	//o D2_TOTAL ja esta com o desconto
							EndIf	
							aTotaliza[2]	+=	SD2->D2_TOTAL+SD2->D2_DESCON
							aTotaliza[3]	+=	SD2->D2_VALFRE
							aTotaliza[4]	+=	SD2->D2_DESPESA
							aTotaliza[18]	+=	SD2->D2_SEGURO
							//
							//Se encontrar SF4 correspondente continuo ou aborta o processamento
							If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
								//
								//Se encontrar SB1 correspondente continuo ou aborta o processamento
								If SB1->(DbSeek (xFilial ("SB1")+SD2->D2_COD))
									//Verifica preenchimento do parametro MV_UNDIEF
									If !Empty(cMVUNDIEF)
										nPos := at(SB1->B1_UM+"=",cMVUNDIEF)
										If nPos > 0
											cUn := Substr(cMVUNDIEF,at(SB1->B1_UM+"=",cMVUNDIEF)+3,2)
										Else
											cUn := SB1->B1_UM
	                                    Endif
	                                Else
	                                	cUn := SB1->B1_UM
                                    Endif
                                    //
									If !(PRD->(DbSeek (SD2->D2_COD)))
										RecLock ("PRD", .T.)
											PRD->PRD_CODI	:=	SD2->D2_COD
											PRD->PRD_DESC	:=	SB1->B1_DESC
											PRD->PRD_UNID	:=	Iif(AllTrim(cUn)=="TL","KG",cUn)
											PRD->PRD_TPPR	:=	Iif (Empty (SB1->B1_CODISS), 1, IiF ("S"$SF4->F4_ICM, 2, 3))
											PRD->PRD_NCM	:=	SB1->B1_POSIPI
											PRD->PRD_CLPR	:=	""
										MsUnLock ()	
									EndIf
									//
									//Se encontrar SB5 correspondente continuo ou aborta o processamento
									If SB5->(DbSeek (xFilial ("SB5")+SB1->B1_COD))
										//
										//Gravacao do registro tipo PRI
										If (nMVPRDPRI<>0) .And. (SB5->(FieldGet (nMVPRDPRI))$"S")
										
											If SubStr(SD2->D2_CF,1,1) == "6" .Or. SubStr(SD2->D2_CF,1,1) == "5"
           										// Alterado conforme FNC 000000336702011
           										// Empresas que emitem CT-e possuem a UF antes do codigo de municipio
           										// Portanto este campo pode ficar com o formato UFXXXXX (7 posicoes)
           										If Len(Alltrim(SM0->M0_CODMUN))<=5
           											cMunic := Substr(Alltrim(SM0->M0_CODMUN),1,5)
           										Else           											
           											cMunic := Substr(Alltrim(SM0->M0_CODMUN),3,5)
           										EndIf	
                                            EndIf
                                            
											If !(PRI->(DbSeek (StrZero (Val (cMunic), 5))))
												RecLock ("PRI", .T.)
													PRI->PRI_MUNI	:=	Val (cMunic)
											Else
												RecLock ("PRI", .F.)
											EndIf
											PRI->PRI_VRAQ	+=	SD2->D2_TOTAL
											MsUnLock ()
										EndIf
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Gravacao dos itens do documento fiscal.                 ³
										//³A variavel cControle identifica um bloco de nota fiscal.³
										//³Exemplo:                                                ³
										//³DOC ou CFC                                              ³
										//³      ITE                                               ³
										//³      DCT                                               ³
										//³      PAR                                               ³
										//³      REF                                               ³
										//³TOT                                                     ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										//Somente incluo conforme conforme lancado na NF
										RecLock ("ITE", .T.)
											ITE->ITE_CONT	:=	cControle
											ITE->ITE_ITEM	:=	nItensD2++
											ITE->ITE_CODI	:=	SD2->D2_COD
											ITE->ITE_QTDE	:=	Iif(AllTrim(cUn)=="TL",SD2->D2_QUANT*1000,SD2->D2_QUANT)
											_nVunit 		:=  SD2->D2_PRCVEN-SD2->D2_DESCICM
											ITE->ITE_VRUN	:=	Iif(AllTrim(cUn)=="TL",_nVunit/1000,_nVunit)
											ITE->ITE_CFOP	:=	Val (SD2->D2_CF)
											ITE->ITE_CST	:=	SD2->D2_CLASFIS
											ITE->ITE_BCIC	:=	SD2->D2_BASEICM
											ITE->ITE_ICMS	:=	SD2->D2_VALICM
											ITE->ITE_BCSU	:=	SD2->D2_BRICMS
											ITE->ITE_ICSU	:=	SD2->D2_ICMSRET
											ITE->ITE_CVF	:=	0	//Informar apenas nas entradas
											ITE->ITE_BCIP	:=	Iif (SF4->F4_LFIPI$"T", SD2->D2_BASEIPI, 0)
											ITE->ITE_IIPI	:=	Iif (SF4->F4_LFIPI$"IN", SD2->D2_BASEIPI, 0)
											ITE->ITE_OIPI	:=	Iif (SF4->F4_LFIPI$"O", SD2->D2_BASEIPI, 0)
											ITE->ITE_IPI	:=	Iif (SF4->F4_LFIPI$"T", SD2->D2_VALIPI, 0)
											ITE->ITE_CVFI	:=	0	//Informar apenas nas entradas
											ITE->ITE_DESC	:=	SD2->D2_DESCON+SD2->D2_DESCICM
											ITE->ITE_ACRE	:=	0
										MsUnLock ()
										//
										//Informacoes para o Registro DCT
										//Verifica preenchimento do parametro MV_UNDIEF
										If !Empty(cMVUNDIEF)
											nPos := at(SD2->D2_UM+"=",cMVUNDIEF)
											If nPos > 0
												cUn := Substr(cMVUNDIEF,at(SD2->D2_UM+"=",cMVUNDIEF)+3,2)
											Else
												cUn := SD2->D2_UM
	                        	            Endif
	                            	    Else
	                                		cUn := SD2->D2_UM
	                                    Endif
										cUnid	:=	cUn
										nQtd	+=	SD2->D2_QUANT
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					//
					SD2->(DbSkip ())
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Detalhe do conhecimento de Transporte.           ³
				//³8 - Conhecimento de Transporte Rodoviario (CTR)  ³
				//³9 - Conhecimento de Transporte Aquaviario (CTA)  ³
				//³10 - Conhecimento Aereo (CA)                     ³
				//³11 - Conhecimento de Transporte Ferroviario (CTF)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If ExistBlock("DIEFDCT")   
					aArray:=ExecBlock("DIEFDCT",.F.,.F.)
					cMunic   := aArray[1]
					cEstEntr := aArray[2]
					cUnid 	 := aArray[3]
					nQtd 	 := aArray[4]  
					cMunicCo := aArray[5] 
					cEstCo   := aArray[6]   
				EndIf 
					
				MontDCT (cControle, nQtd, cUnid, cMunic, cEstEntr, cSf3, lComplemento,cMunicCo,cEstCo)
				cUnid		:=	""
				nQtd		:=	0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravacao do cabecalho dos documentos fiscais³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DOC_CFC (aMVAIDFCE, SF2->F2_FRETE, cControle, cSF3, cMVDISPAUT)	//So SF3
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para nao duplicar SF1 quando a mesma nota gerar mais de um SF3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cChave	:=	(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
		Do While !(cSF3)->(Eof ()) .And.;
			cChave==(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
			//
			//Totalizo o documento fiscal de acordo com o livro fiscal
			If (lComplemento)	
				//Para o valor total da NF de compelemente de ICMS [2] devo pegar o valor do ICMS pois para este tipo de NF o VALCONT deve estar zerado.
				//	Agora nas NF de Complemento de Preco/Frete e IPI, devo utilizar o VALCONT, pois deve contar preenchido.
				If ("I"$cTipoCompl)		//ICMS
					aTotaliza[2]	+=	(cSF3)->F3_VALICM
				Else
					aTotaliza[2]	+=	(cSF3)->F3_VALCONT
				EndIf
				aTotaliza[4]	+=	(cSF3)->F3_DESPESA
				aTotaliza[6]	+=	(cSF3)->F3_VALCONT
			EndIf
			aTotaliza[7]	+=	(cSF3)->F3_ICMSRET
			aTotaliza[8]	+=	(cSF3)->F3_BASEICM
			aTotaliza[9]	+=	(cSF3)->F3_VALICM
			aTotaliza[10]	+=	(cSF3)->F3_ISENICM
			aTotaliza[11]	+=	(cSF3)->F3_OUTRICM
			aTotaliza[12]	+=	(cSF3)->F3_BASERET
			aTotaliza[13]	+=	(cSF3)->F3_ICMSRET
			aTotaliza[14]	+=	(cSF3)->F3_BASEIPI
			aTotaliza[15]	+=	(cSF3)->F3_ISENIPI
			aTotaliza[16]	+=	(cSF3)->F3_OUTRIPI
			aTotaliza[17]	+=	(cSF3)->F3_VALIPI
			//
			(cSF3)->(DbSkip ())
		EndDo
		//
		//totalizador de documentos fiscais
		TOT (aTotaliza)

		//Grava Registro Tipo MES - Regime ME, MS, OUTROS e ESPECIAL
		If (cVersao == "300" .Or. cVersao == "400" .Or. cVersao == "500" .Or. cVersao == "600" .Or. cVersao == "608") .And. Left(Alltrim(_aTotal[004][1][1]),2) $ "03/04/05/06"
			GeraMES(aTotaliza)
		Endif
	EndDo
   	
   	If lQuery
        dbSelectArea(cSF3)
        dbCloseArea()
    Else
       	dbSelectArea(cSF3)
		RetIndex(cSF3)
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do Registro Tipo DCE - Ordem de Coleta de Cargas                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntTms
		RegOCC(dDataDe, dDataAte,aMVAIDFCE)
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do Registro Tipo GNR - Geracao das informacoes referente as guias de recolhimento.³
	//³Parametro relacionado eh de formato de array com 5 posicoes para alguns dos campos abaixo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GNRE (dDataDe, dDataAte, aMVGNRCE)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utiliza informacoes digitadas na apuracao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Apuracao (dDataDe)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera informacoes de base de cupons fiscais.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ApurEcf (dDataDe, dDataAte, cControle, nMVPRDPRI, nMVA2SUFR,aMVAIDFCE,cMVDISPAUT)
Next
// Volta posicionamento da filial no SM0 - gerava problema no .ini ficando desposicionado
RestArea(aAreaSM0)

If aScan(aFilCons, {|x|x[1] == .T.}) == 0
	Aviso('Atenção',"As Filiais Selecionadas não fazem parte do estado do Ceará",{'Ok'})
	lAbtMT950:=.T.
	Return
EndIf

cFilAnt := FwCodFil()
// Variável para sair do loop de filiais consolidadas na MATA950, mantendo o legado
lExitPFil	:= lConsolida .and. MV_PAR06 ==1
Return (aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontDCT   ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para os Conhecimentos  ³±±
±±³          ³ de transporte.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Controle do bloco de gravacao. Todos registros vao  ³±±
±±³          ³ExpN -> Quantidade de itens da NF                           ³±±
±±³          ³ExpC -> Unidade de Medida da NF                             ³±±
±±³          ³ExpC -> Codigo do municipio (A1 ou A2 COD_MUN)              ³±±
±±³          ³ExpC -> Estado do cliente/fornecedor                        ³±±
±±³          ³ExpC -> Codigo do municipio coleta (se dieferente Sigamat)  ³±±
±±³          ³ExpC -> Estado (se dieferente Sigamat)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontDCT (cControle, nQtd, cUnid, cMunic, cEstEntr, cSf3, lComplemento,cMunicCo,cEstCo)

Local	cModelo		:=	aModNot((cSF3)->F3_ESPECIE)
Local	nUniMed		:=	Iif ("KG"$cUnid, 1, 2)
Local 	lMV_parDief	:=	GetNewPar("MV_DIEFQTD",.F.)
Local aArea       	:= GetArea("SF2")
Local aArea2       	:= GetArea("DT6")
// Para emissores de CT-e, Municipio da SM0 possuem mais que 5 posicoes, UFXXXXX
Local cMunSM0       := AllTrim(SM0->M0_CODMUN)

//-- Verificando se o CTRC é de DEVOLUÇÃO, REENTREGA ou COMPLEMENTO pois no
//-- SF2 consta como nota NORMAL.
If SF2->(DbSeek (xFilial ("SF2")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE)) 
	If ( DT6->(DbSeek (xFilial ("DT6")+SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)) .And. ;
		DT6->DT6_DOCTMS=="6" .Or. DT6->DT6_DOCTMS=="7" .Or. DT6->DT6_DOCTMS=="8")
		//-- CTRC Devolução, Reentrega ou Complemento.
		//-- Tratamento necessário pois CTRC de Complemento não possui DTC.
		//-- com isso e necessário buscar pelo CTRC Original.
		lComplemento := .T.
	EndIf
EndIf
RestArea( aArea )
RestArea( aArea2 )
	
//
If (cModelo$"/08/09/10/11")		//CTR, CTA, CA e CTF
	If !(DCT->(DbSeek (ccontrole)))
		If len(cMunSM0) <= 5
			cMunSM0 := SUBS(AllTrim(SM0->M0_CODMUN),1,5)
		Else
			cMunSM0 := SUBS(AllTrim(SM0->M0_CODMUN),3,5)			
		EndIf
		RecLock ("DCT", .T.)
			DCT->DCT_CONT	:=	cControle
			If Left( (cSF3)->F3_CFO,1 )<"5" .And. Empty (SF1->F1_ORIGLAN) //Se preenchido comprei mercadoria + CTR
				DCT->DCT_MUCO	:=	If(!Empty(cMunicCo),Val(SUBS(AllTrim(cMunicCo),1,5)),Val (cMunSM0))
				DCT->DCT_UFCO	:=	If(!Empty(cEstCo),cEstCo,SM0->M0_ESTENT)
				DCT->DCT_MUEN	:=	Val (cMunic)
				DCT->DCT_UFEN	:=	cEstEntr
			Else
				DCT->DCT_MUCO	:=	Val (cMunic)
				DCT->DCT_UFCO	:=	cEstEntr
				DCT->DCT_MUEN	:= If(!Empty(cMunicCo),Val(SUBS(AllTrim(cMunicCo),1,5)),Val (cMunSM0))
				DCT->DCT_UFEN	:= If(!Empty(cEstCo),cEstCo,SM0->M0_ESTENT)
			Endif
			DCT->DCT_QTDE	:=	Iif(lComplemento .And. lMV_parDief,1,nQtd)
			DCT->DCT_UNID	:=	nUniMed
		MsUnLock ()
	EndIf
EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GNRE      ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para as GNREs          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo                              ³±±
±±³          ³ExpD -> Data final do periodo                               ³±±
±±³          ³ExpA -> Array contendo os alguns campos necessarios na tabe-³±±
±±³          ³ la SF6.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GNRE (dDataDe, dDataAte, aMVGNRCE)
	Local	lRet	:=	.T.
	Local	aSf6	:=	{"SF6",""} 
	
	//
	FsQuery (aSf6, 1, "F6_FILIAL='"+xFilial("SF6")+"' AND F6_DTARREC>='"+DTOS (dDataDe)+"' AND F6_DTARREC<='"+DTOS (dDataAte)+"' AND F6_TIPOIMP IN ('1', '3') ", "F6_FILIAL='"+xFilial("SF6")+"' .AND. DTOS (F6_DTARREC)>='"+DTOS (dDataDe)+"' .AND. DTOS (F6_DTARREC)<='"+DTOS (dDataAte)+"' .AND. F6_TIPOIMP$'13' ", "F6_TIPOIMP+F6_CODREC")
	SF6->(DbGotop ())
	//
	Do While !SF6->(Eof ())
		RecLock ("GNR", .T.)
			GNR->GNR_ES		:=	Iif ("CE"$SF6->F6_EST, "E", "S")
			GNR->GNR_IEDE	:=	SF6->F6_INSC
			GNR->GNR_UFOR	:=	SF6->F6_EST
			GNR->GNR_BANC	:=	SF6->F6_BANCO
			GNR->GNR_AGEN	:=	Left (AllTRim (SF6->F6_AGENCIA), Len (AllTRim (SF6->F6_AGENCIA))-2)
			GNR->GNR_DIGI	:=	Right (AllTRim (SF6->F6_AGENCIA), 2)
			//
			//Autenticacao banco 
		   		If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[1]))>0)
					GNR->GNR_AUTE	:=	SF6->(FieldGet (FieldPos (aMVGNRCE[1])))
				Else
					GNR->GNR_AUTE	:=	""
				EndIf
			//
			GNR->GNR_DREC	:=	DToS (SF6->F6_DTARREC)
			//
			//Codigo Receita de 6 posicoes para DIEF
			If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[6]))>0)
				GNR->GNR_CODR	:=	Val (SF6->(FieldGet (FieldPos (aMVGNRCE[6]))))
			Else
				GNR->GNR_CODR	:=	Val (SF6->F6_CODREC)
			EndIf
			//
			GNR->GNR_VENC	:=	DToS (SF6->F6_DTVENC)
			GNR->GNR_REFE	:=	Left (DToS (SF6->F6_DTVENC), 6)
			GNR->GNR_VRPR	:=	SF6->F6_VALOR
			//
			//Atualizacao monetaria
			If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[2]))>0)
				GNR->GNR_ATUA	:=	SF6->(FieldGet (FieldPos (aMVGNRCE[2])))
			Else
				GNR->GNR_ATUA	:=	0
			EndIf
			//
			//juros
			If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[3]))>0)
				GNR->GNR_JURO	:=	SF6->(FieldGet (FieldPos (aMVGNRCE[3])))
			Else
				GNR->GNR_JURO	:=	0 
				
				
			EndIf
			//
			//multa
			If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[4]))>0)
				GNR->GNR_MULT	:=	SF6->(FieldGet (FieldPos (aMVGNRCE[4])))
			Else
				GNR->GNR_MULT	:=	0
			EndIf
			//
			GNR->GNR_VRTO	:=	SF6->F6_VALOR
			//
			//convenio ou protocolo/mercadorias
			If Len (aMVGNRCE[1])>0 .And. (SF6->(FieldPos (aMVGNRCE[5]))>0)
				GNR->GNR_CONV	:=	SF6->(FieldGet (FieldPos (aMVGNRCE[5])))
			Else
				GNR->GNR_CONV	:=	""
			EndIf
		MsUnLock ()
		//
		SF6->(DbSkip ())
	EndDo
	//
	FsQuery (aSf6, 2)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DOC_CFC   ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessarias para os registros DOC ³±±
±±³          ³e CFC                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±³          ³ExpN -> Valor do frete                                      ³±±
±±³          ³ExpC -> Controle do bloco de gravacao. Todos registros vao  ³±±
±±³          ³ ter o mesmo codigo de controle.                            ³±±
±±³          ³ExpC -> Alias da tabela SF3                                 ³±±
±±³          ³ExpL -> Flag de existencia do parametro MV_AIDFCE na dicio- ³±±
±±³          ³ nario de dados.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DOC_CFC (aMVAIDFCE, nFrete, cControle, cSF3, cMVDISPAUT)
	Local	lRet		:=	.T.
	Local	cOperacao	:=	""
	Local	lCFC		:=	.F.
	Local	lDOC		:=	.F.
	Local	cModelo		:=	ModDief (aModNot((cSF3)->F3_ESPECIE))
	Local	cMVDIEFSS	:=	""	//Define os CFOPs de servico sujeito ao ICMS, exemplo, servico transporte
	Local	cF3NumF		:= IIf(!Empty(GetNewPar("MV_F3NUMF","F3_NFISCAL")),GetNewPar("MV_F3NUMF","F3_NFISCAL"),"F3_NFISCAL")
	
	SX6->(DbSetOrder (1))
	//--1.o Busca o parametro para filial corrente:
	If SX6->(DbSeek(cFilAnt+"MV_DIEFSS"))
		While !SX6->(Eof()) .And. SX6->X6_FIL == cFilAnt .And. "MV_DIEFSS" $ SX6->X6_VAR
			cMVDIEFSS += SX6->X6_CONTEUD
			SX6->(DbSkip())
		End
	Else
		//--2.o Se nao encontrou o parametro p/ filial, 
		//--busca o parametro cadastrado com a filial em branco
		If SX6->(DbSeek(xFilial('SX6') + "MV_DIEFSS"))
			While !SX6->(Eof()) .And. SX6->X6_FIL == xFilial('SX6') .And. "MV_DIEFSS" $ SX6->X6_VAR
				cMVDIEFSS += SX6->X6_CONTEUD
				SX6->(DbSkip())
			End
		EndIf
	EndIf
		
	If SubStr (AllTrim ((cSF3)->F3_CFO) ,1 ,1)>="5"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para o tipo de operacao na saida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOperacao	:=	"03"	//Saidas de mercadorias
		If !(AllTrim ((cSF3)->F3_CFO)$cMVDIEFSS)	//Se nao for servico sujeito ao ICMS
			If ("S"$(cSF3)->F3_TIPO)	//Se for servico sujetico somente ao ISS
				cOperacao	:=	"12"
			EndIf
		Else	//Prestacao de servico sujeito ao ICMS
			cOperacao	:=	"05"
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para o tipo de operacao na entrada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(AllTrim ((cSF3)->F3_CFO)$cMVDIEFSS)	//Se nao for servico sujeito ao ICMS
			If ("S"$(cSF3)->F3_TIPO)	//Se for servico sujetico somente ao ISS
				cOperacao	:=	"12"
			Else
				If "S"$(cSF3)->F3_FORMUL	//Documento fiscal emitido pelo proprio contribuinte
					cOperacao	:=	"01"
				Else	//Documento fiscal emitido por outro contribuinte
					cOperacao	:=	"02"
				EndIf
			EndIf
		Else	//Aquisicao de servico sujeito ao ICMS
			cOperacao	:=	"05"//"04"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico qual registro gerar:                                    ³
	//³DOC para todas menos as tratadas no registro CFC, conforme segue:³
	//³- Nota Venda Consumidor(2)                                       ³
	//³- Bilhetes de passagem(13,14,15,16)                               ³
	//³- Contas Energia Eletrica e Telefone(6,21,22)                    ³
	//³- Cupons fiscais(37)                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aModNot((cSF3)->F3_ESPECIE)$"02#06#13#14#15#16#21#22#37")
		If !(TRB->(DbSeek ("CFC"+cControle)))
			lCFC	:=	.T.
			lDOC	:=	.F.
		Else
			lCFC	:=	.F.
			lDOC	:=	.F.
		EndIf
	Else
		If !(TRB->(DbSeek ("DOC"+cControle)))
			lCFC	:=	.F.
			// Conforme Layout DIECE este registro não deve ser gerado para notas de saída para estes regimes
			If ((_aTotal[004][1][1]$"03-Microempresa|04-Microempresa Social|05-Regime Especial|06-Regime Outros|07-Microempresa-Simples Nacional|08-EPP-Simples Nacional") .And. Val((cSF3)->F3_CFO) >= 5000)  
	             lDoc := .F.
	       	Else 
	             lDOC := .T.
          	EndIf	
		Else
			lCFC	:=	.F.
			lDOC	:=	.F.
		EndIf
	EndIf
	//Gravacao
	If (lCFC) .Or. (lDOC)
		RecLock ("TRB", .T.)
			If (lCFC)
				TRB->TRB_REGI	:=	"CFC"
			ElseIf (lDOC)
				TRB->TRB_REGI	:=	"DOC"
			EndIf
			//
			TRB->TRB_NCXA	:=	0	//Para ECF tem uma funcao propria.
			TRB->TRB_OPER	:=	cOperacao
			TRB->TRB_MODE	:=	cModelo
			TRB->TRB_SERI	:=	SerieNfId(cSF3,2,"F3_SERIE") 
			TRB->TRB_SUBS	:=	""
			TRB->TRB_NUMI	:=	Val ((cSF3)->F3_NFISCAL)
			TRB->TRB_NUMF	:=	IIf(lCFC,Val((cSF3)->&cF3NumF),Val((cSF3)->F3_NFISCAL))
			TRB->TRB_CFOP	:=	Val ((cSF3)->F3_CFO)
			TRB->TRB_DEMI	:=	DToS ((cSF3)->F3_EMISSAO)
			TRB->TRB_DOPE	:=	DToS ((cSF3)->F3_ENTRADA)
			TRB->TRB_FRET	:=	Iif (nFrete>0, "1", "2")
			//
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorna os Dados da AIDF                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDisp	:=	RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT)
			TRB->TRB_DISP	:=	aDisp[2]
			//
			If cModelo == '55'  // Nota Fiscal Eletronica
				TRB->TRB_AIDF	:=	0
				TRB->TRB_NIND	:=	0
				TRB->TRB_NFID	:=	0
			Else
				TRB->TRB_AIDF	:=	aDisp[1]
				TRB->TRB_NIND	:=	aDisp[7]
				TRB->TRB_NFID	:=	aDisp[8]
			EndIf
			//
			TRB->TRB_CONT	:=	cControle
		MsUnLock ()
	EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PAR       ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para o registro PAR    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> Codigo do municipio para gravacao do registro PRI   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Alias da tabela SF3                                 ³±±
±±³          ³ExpC -> Flag de 'E'-Entrada, 'S'-Saida                      ³±±
±±³          ³ExpC -> Controle do bloco de gravacao. Todos registros vao  ³±±
±±³          ³ ter o mesmo codigo de controle.                            ³±±
±±³          ³ExpL -> Se for ECF(.T.) gero em cima do MV_CLIPAD e MV_LOJPAD³±±
±±³          ³cEstEntr -> Estado de entrega para o registro DCT.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PAR (cSF3, cEntSai, cControle, nMVA2SUFR, lEcf, cEstEntr)	//Monto de acordo com a SISIF
	Local	cRet		:=	""	
	Local	cCli		:=	""
	Local	cLoj		:=	""
	Local 	lVendLoj	:= .F.
	Local 	cMV_EST		:= SuperGetMV("MV_ESTADO" , , "")
	Local 	lIntTms		:= SuperGetMV("MV_INTTMS",,.F.) .And. !SuperGetMV("MV_DIEFTMS",,.F.)
	//
	lEcf	:=	Iif (lEcf==Nil, .F., lEcf)	
	//

	If cSF3 == "SF3_SAIDA"	
	If SD2->(DBSeek( xFilial("SD2") + (cSF3)->F3_NFISCAL + (cSF3)->F3_SERIE + (cSF3)->F3_CLIEFOR + (cSF3)->F3_LOJA)	)
			If SD2->D2_ORIGLAN $ "LO"
				lVendLoj	:= .T.		
			EndIf
		EndIf
	ElseIf  cSF3 $ "a940ASD2"
		lVendLoj	:= .T.
	EndIf
	
	If (lEcf) .Or. ((("E"$cEntSai) .And. (AllTrim ((cSF3)->F3_TIPO)$"DB")) .Or.;	//Entrada devolucao ou beneficiamento
		(("S"$cEntSai) .And. !(AllTrim ((cSF3)->F3_TIPO)$"DB")))	//Saida Normal
		If (lEcf)
			cCli	:=	IIf(Empty((cSF3)->D2_CLIENTE),SuperGetMv ("MV_CLIPAD"),(cSF3)->D2_CLIENTE)
			cLoj	:=	IIf(Empty((cSF3)->D2_LOJA),SuperGetMv ("MV_LOJAPAD"),(cSF3)->D2_LOJA)
		ElseIf lIntTms
			//-- Faz com que seja utilizado o cliente DEVEDOR.
		If SF2->(DbSeek (xFilial ("SF2")+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE))
				If ( DT6->(DbSeek (xFilial ("DT6")+SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)) .And. ;
					DT6->DT6_DOCTMS=="6" .Or. DT6->DT6_DOCTMS=="7" .Or. DT6->DT6_DOCTMS=="8")
					//-- CTRC Devolução, Reentrega ou Complemento .
					//-- Tratamento feito pois CTRC de de DEVOLUÇÃO, REENTREGA ou COMPLEMENTO não possui DTC.
					//-- com isso e necessário buscar pelo CTRC Original.
				If DTC->(DbSeek (xFilial ("DTC")+DT6->DT6_DOCDCO+DT6->DT6_SERDCO+DT6->DT6_FILDCO)) 
						cCli	:=	DTC->DTC_CLIDEV
						cLoj	:=	DTC->DTC_LOJDEV
					EndIf
				Else			
//				DbSelectArea ("DTC")
//				DTC->(DbSetOrder (7))
				If DTC->(DbSeek (xFilial ("DTC")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_FILIAL)) 
						cCli	:=	DTC->DTC_CLIDEV
						cLoj	:=	DTC->DTC_LOJDEV
					EndIf
				EndIf
			EndIf
		Else
			cCli	:=	(cSF3)->F3_CLIEFOR
			cLoj	:=	(cSF3)->F3_LOJA
		EndIf
		//
	If SA1->(DbSeek (xFilial ("SA1")+cCli+cLoj))
			RecLock ("PAR", .T.)
				PAR_CONT	:=	cControle
				PAR_COND	:=	Iif (lEcf, 3, Iif ("E"$cEntSai, Iif ((cSF3)->F3_FORMUL=="S", 2, 1), 3))
				PAR_CNPJ	:=	Iif (SA1->A1_TIPO=="X", "", SA1->A1_CGC)
				PAR_CGF		:=	Iif ("ISENT"$Upper (SA1->A1_INSCR), "", SA1->A1_INSCR)
				PAR_NOME	:=	SA1->A1_NOME
				PAR_UF		:=	IIf( lVendLoj , cMV_EST , SA1->A1_EST )
				PAR_SUFR	:=	Val (SA1->A1_SUFRAMA)
			MsUnLock ()
			//-- Condição para descobrir a origem do transporte para geração correta do registro DCT.
			If (DTC->DTC_SELORI == "2")
			If SA1->(DbSeek (xFilial ("SA1")+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
			cRet		:=	SA1->A1_COD_MUN
			cEstEntr	:=	SA1->A1_EST
		EndIf
			ElseIF(DTC->DTC_SELORI == "1")
				// Alterado conforme FNC 000000336702011
				// Empresas que emitem CT-e possuem a UF antes do codigo de municipio
				// Portanto este campo pode ficar com o formato UFXXXXX (7 posicoes)
				If Len(Alltrim(SM0->M0_CODMUN))<=5			
					cRet		:=	SUBS(AllTrim(SM0->M0_CODMUN),1,5)
				Else
					cRet		:=	SUBS(AllTrim(SM0->M0_CODMUN),3,5)					
				EndIf
				cEstEntr	:=	SM0->M0_ESTENT
			EndIF
		EndIf
	Else
	If SA2->(DbSeek (xFilial ("SA2")+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA))
			RecLock ("PAR", .T.)
				PAR_CONT	:=	cControle
				PAR_COND	:=	Iif ("E"$cEntSai, 1, 3)
				PAR_CNPJ	:=	Iif (SA2->A2_TIPO=="X", "", SA2->A2_CGC)
				PAR_CGF		:=	Iif ("ISENT"$Upper (SA2->A2_INSCR), "", SA2->A2_INSCR)
				PAR_NOME	:=	SA2->A2_NOME
				PAR_UF		:=	IIf( lVendLoj , cMV_EST , SA2->A2_EST )
				PAR_SUFR	:=	Val (Iif (nMVA2SUFR<>0, SA2->(FieldGet (nMVA2SUFR)), "0"))
			MsUnLock ()
			//
			cRet		:=	SA2->A2_COD_MUN
			cEstEntr	:=	SA2->A2_EST
		EndIf
	EndIf
Return (cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ModDief   ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizada para transformar o resultado da aModNot no formato³±±
±±³          ³ aceito pela DIEF.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> Modelo documento.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Modelo conforme aModNot                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModDief (cMod)
	Local	cModelo	:=	""
	//
	Do Case
		Case ("01"$cMod)
			cModelo	:=	"1"
		Case ("02"$cMod)
			cModelo	:=	"2"
		Case ("03"$cMod)
			cModelo	:=	"3"
		Case ("04"$cMod)
			cModelo	:=	"4"
		Case ("05"$cMod)
			cModelo	:=	"5"
		Case ("06"$cMod)
			cModelo	:=	"6"
		Case ("07"$cMod)
			cModelo	:=	"7"
		Case ("08"$cMod)
			cModelo	:=	"8"
		Case ("09"$cMod)
			cModelo	:=	"9"
		Otherwise
			cModelo	:=	cMod
	EndCase
Return (cModelo)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DFR       ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para o registro DEF    ³±±
±±³          ³ Somente na Saida, conforme troca de e-mail em 11/10/2005   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Alias da tabela SF3                                 ³±±
±±³          ³ExpC -> Controle do bloco de gravacao. Todos registros vao  ³±±
±±³          ³ ter o mesmo codigo de controle.                            ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±³          ³ExpL -> Flag de existencia do parametro MV_AIDFCE na dicio- ³±±
±±³          ³ nario de dados.                                            ³±±
±±³          ³ExpL -> Identifica se a NF e de complemento de ICMS ou Preco³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DFR (cSF3, cControle, aMVAIDFCE, lComplemento, cMVDISPAUT,lEcfDFR)
	Local	lRet	:=	.T.
	Local	aDisp	:=	{}
	//
	
	If (lEcfDFR) .Or. ("D"$(cSF3)->F3_TIPO) .Or. ("B"$(cSF3)->F3_TIPO) .Or. (lComplemento) 
		If !(DFR->(DbSeek (cControle))) 
			RecLock ("DFR", .T.)		
				DFR->DFR_CONT	:=	cControle
		     	DFR->DFR_MODE	:=	ModDief (aModNot ((cSF3)->F3_ESPECIE))
		     	DFR->DFR_SERI	:=	SerieNfId(cSF3,2,"F3_SERIE")
		     	DFR->DFR_SUBS	:=	""
		     	DFR->DFR_NUMI	:=	Val ((cSF3)->F3_NFISCAL)
		     	DFR->DFR_NUMF	:=	Val ((cSF3)->F3_NFISCAL)
		     	DFR->DFR_REFE	:=	99
				//
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retorna os Dados da AIDF                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aDisp	:=	RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT)
				//
				DFR->DFR_AIDF	:=	aDisp[1]
				DFR->DFR_DISP	:=	aDisp[2]
				DFR->DFR_NUID	:=	aDisp[7]
				DFR->DFR_NUFD	:=	aDisp[8]
				//
				
				If ("D"$(cSF3)->F3_TIPO)
					DFR->DFR_OBS	:=	"NOTA FISCAL DE DEVOLUCAO"			
				ElseIf lComplemento
					DFR->DFR_OBS	:=	"NOTA FISCAL DE COMPLEMEMTO"
				ElseIf (cSF3)->F3_TIPO=="B"
					DFR->DFR_OBS	:=	"NOTA FISCAL DE BENEFICIAMENTO"
				ElseIf lEcfDFR 
					DFR->DFR_OBS	:=	"CUPOM FISCAL"
				Endif
			MsUnLock ()
		Endif
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TOT       ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para o registro TOT    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> Totalizadores                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TOT (aTotaliza)
	Local	lRet	:=	.T.
	//
	If !(TOT->(DbSeek (aTotaliza[1])))
		RecLock ("TOT", .T.)
			TOT->TOT_CONT	:=	aTotaliza[1]
			TOT->TOT_VRPR	:=	aTotaliza[2]
			TOT->TOT_FRET	:=	aTotaliza[3]
			TOT->TOT_DESP	:=	aTotaliza[4]
			TOT->TOT_DESC	:=	aTotaliza[5]
			TOT->TOT_VRDO	:=	aTotaliza[6]
			TOT->TOT_RETI	:=	aTotaliza[7]
			TOT->TOT_BCIC	:=	aTotaliza[8]
			TOT->TOT_ICMS	:=	aTotaliza[9]
			TOT->TOT_ISEN	:=	aTotaliza[10]
			TOT->TOT_OUTR	:=	aTotaliza[11]
			TOT->TOT_BCSU	:=	aTotaliza[12]
			TOT->TOT_ICSU	:=	aTotaliza[13]
			TOT->TOT_BCIP	:=	aTotaliza[14]
			TOT->TOT_ISIP	:=	aTotaliza[15]
			TOT->TOT_OUIP	:=	aTotaliza[16]
			TOT->TOT_IPI	:=	aTotaliza[17]
			TOT->TOT_SEGU	:=	aTotaliza[18]
		MsUnLock ()
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraMES   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 27.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera o Registro Tipo MES somente para os Regimes ME, MS,    ³±±
±±³          ³ESPECIAL e OUTROS.                                          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> Totalizadores                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraMES(aTotaliza)

Local aArea := GetArea()
Local cCfop := StrZero(Val(aTotaliza[19]),5)

dbSelectArea("MES")
dbSetOrder(1)
If !(MES->(dbSeek(cCfop)))
	RecLock("MES",.T.)
	MES->MES_CFOP := cCfop
Else
	RecLock("MES",.F.)
Endif
MES->MES_VRPR	+= aTotaliza[2]
MES->MES_BCIC	+= aTotaliza[8]
MES->MES_ISEN	+= aTotaliza[10]	//Isento
MES->MES_OUTR	+= aTotaliza[11]	//Outras
MES->MES_VRDO	+= aTotaliza[6]
MsUnLock ()

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraVIC   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 27.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Substitui o Registro Tipo VIR da versao 2.00                ³±±
±±³          ³Valores do ICMS a Recolher dos Contribuintes Credenciados   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> Totalizadores                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraVIC()

Local aArea	:= GetArea()
Local nX 	:= 0

dbSelectArea("VIC")
For nX := 1 To Len(_aTotal[004][3])
	If Val(_aTotal[004][3][nX]) > 0 .and. !VIC->(dbSeek(StrZero(nX,2),.F.))
		RecLock ("VIC", .T.)
		VIC->VIC_COD  := StrZero(nX,2)				//Codigo para Indice apenas
		VIC->VIC_COCR := nX							//Codigo do ICMS - Tabela 24
		VIC->VIC_VLCR := Val(_aTotal[004][3][nX])	//Valor do ICMS
		MsUnLock ()
	Endif
Next

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraSTQ   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 28.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera o Arquivo STQ - Totais refentes ao Estoque             ³±±
±±³          ³Regimes ME, MS, ESPECIAL e OUTROS                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSTQ()

Local aArea := GetArea()

FsEstInv( {"DIV",""},1,,,mv_par02, , , , , , , , , , aFilCons, .T., , , )
//Function FsEstInv( aAlias, nTipo, lCliFor, lMovimen, dUltFec, lNCM, lST, lSelB5, cFiltraB5,; 
//				   aNFsProc, aProcCod, cFiltraB1, aProd, aProcesso, aFiliais, lSelFil,;
//				   cFilDe, cFilAte, lAddRecno )
	dbSelectArea("DIV")
	dbGoTop()
	While !Eof() 
		If STQ->(LastRec()) == 0
			RecLock("STQ",.T.)
			STQ->STQ_DEST := mv_par02		//Data do Estoque
		Else
			STQ->(RecLock("STQ",.F.))
		Endif
		STQ->STQ_TRIB += IIf (DIV->CLASSFIS == "00",DIV->CUSTO,0)		//Tributada Integralmente
		STQ->STQ_SUBT += IIf (DIV->CLASSFIS == "10",DIV->CUSTO,0)		//Sujeitas a ST
		STQ->STQ_ISEN += IIf (DIV->CLASSFIS $ "40/41",DIV->CUSTO,0)	//Isentas ou S/Incidencia
		MsUnlock()
		
		dbSelectArea("DIV")	
		dbSkip()
	Enddo
FsEstInv({"DIV",""},2)

RestArea(aArea)

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraINV   ³ Autor ³Andressa ATaides       ³ Data ³ 24.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera Registro INV e EST - Inventario			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraINV()

Local aArea := GetArea()
Local cMVUNDIEF	 :=	GetNewPar("MV_UNDIEF",	"")
Local lMVDIEFINV := GetNewPar("MV_DIEFINV", .F.)
Local lMVDIEFSIT := GetNewPar("MV_DIEFSIT", .F.)    
Local cCodSitu   := ""    

//Gravacao do Registro Inventario
FsEstInv( {"ARQ",""},1,,,mv_par02, , , , , , , , , , aFilCons, .T., , , )
//Function FsEstInv( aAlias, nTipo, lCliFor, lMovimen, dUltFec, lNCM, lST, lSelB5, cFiltraB5,; 
//				   aNFsProc, aProcCod, cFiltraB1, aProd, aProcesso, aFiliais, lSelFil,;
//				   cFilDe, cFilAte, lAddRecno )
ARQ->(DbGoTop())
Do While !ARQ->(Eof())
	If ( SB1->( DbSeek( xFilial( "SB1" )+ARQ->CODIGO ) ) ) .And. ARQ->QUANT>0
		//Verifica preenchimento do parametro MV_UNDIEF
		If !Empty(cMVUNDIEF)
			nPos := at(SB1->B1_UM+"=",cMVUNDIEF)
			If nPos > 0
				cUn := Substr(cMVUNDIEF,at(SB1->B1_UM+"=",cMVUNDIEF)+3,2)
			Else
				cUn := SB1->B1_UM
	        Endif
	    Else
	       	cUn := SB1->B1_UM
	    Endif

		If !(PRD->(DbSeek(ARQ->CODIGO)))
			RecLock ("PRD", .T.)
				PRD->PRD_CODI	:=	ARQ->CODIGO
				PRD->PRD_DESC	:=	SB1->B1_DESC
				PRD->PRD_UNID	:=	Iif(AllTrim(cUn)=="TL","KG",cUn)
				PRD->PRD_TPPR	:=	Iif( Empty( SB1->B1_CODISS ), 1, 3 )
				PRD->PRD_NCM	:=	SB1->B1_POSIPI
				PRD->PRD_CLPR	:=	""
			MsUnLock ()	
		EndIf

        //verifica se o campo codigo da situacao sera preenchido de acordo com
        //o campo B5_SITDIEF
	    If (SB5->(DbSeek(xFilial("SB5")+ARQ->CODIGO)))
		cCodSitu := SB5->B5_SITDIEF
	    EndIf
        If Len(Alltrim(cCodSitu))==0
            cCodSitu := Iif(ARQ->TIPO=="MP","02",Iif(ARQ->TIPO=="PA" .Or. ARQ->TIPO=="PI" .And. lMVDIEFINV,"04","07"))
        EndIf
		RecLock ("INV", .T.)
			INV->INV_CODI	:= ARQ->CODIGO
			INV->INV_QTDE	:= ARQ->QUANT
			INV->INV_VRUN	:= (ARQ->CUSTO/ARQ->QUANT)
			INV->INV_COND	:= ARQ->SITUACA
			INV->INV_SITU	:= cCodSitu
		MsUnLock ()	
		
		_aTotal[008]	+=	ARQ->CUSTO
	Endif
	ARQ->(DbSkip())
Enddo									
FsEstInv({"ARQ",""},2)
RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TOT       ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para os registros  OCR ³±±
±±³          ³ ODB, DED de acordo com lancamentos na apuracao de ICMS.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data inicial do periodo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Apuracao (dDataDe)
	Local	lRet		:=	.T.
	Local	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local	nI			:=	0
	Local	nIx			:=	0
	Local	cDescOutCrd	:=	""
	Local	aApICMMe	:=	{}
	Local	aDAE		:=	{}
	Local	cDAE		:=	""
	Local	aIDA		:=	{}
	Local	cIDA		:=	""
	Local	nPos		:=	0
	//
	aApICMMe	:=	FisApur ("IC", Year (dDataDe), Month (dDataDe), 2, 0, "*", .F., {}, 1, .F., "")
	aSort (aApICMMe,,, {|x, y| y[4] > x[4]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outros Creditos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	//Credito Presumido   	
	aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.01"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.01"})][3], 0)
	//credito antecipado
	aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.02"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.02"})][3], 0)
	//Credito diferencial aliquota
	aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.03"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.03"})][3], 0)
	//credito transferencia de credito
	aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.04"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.04"})][3], 0)
	//credito bens de ativo imobilizado
	aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.05"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.05"})][3], 0)
	//credito restituicao de indebito
	nPos	:=	aScan (aApICMMe, {|a| a[4]=="006.06"})
	If (nPos<>0)
		For nI := nPos To Len (aApICMMe)	//Verificacao para mais de um lancamento com o codigo 006.06 para numeros do DAE diferentes
			If ("006.06"$aApICMMe[nI][4])
				aValor[6]	+=	aApICMMe[nI][3]
				cDAE	:=	SubStr (aApICMMe[nI][2], At ("[", aApICMMe[nI][2])+1, At ("]", aApICMMe[nI][2])-At ("[", aApICMMe[nI][2])-1)
				aAdd (aDAE, {cDAE, aApICMMe[nI][3]})
			EndIf
		Next (nI)
	EndIf
	//credito ICMS a mais ou em duplicidade
	aValor[7]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.07"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.07"})][3], 0)
	//credito ICMS importacao diferido
	aValor[8]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.08"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.08"})][3], 0)
	//credito decorrente de auto de infracao
	aValor[9]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.09"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.09"})][3], 0)
	//estrono debito reversao de reserva de transferencia
	aValor[10]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="007.11"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="007.11"})][3], 0)
	//saldo credor do periodo anterior
	aValor[11]	:=	Iif (aScan (aApICMMe, {|a| a[1]=="009"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="009"})][3], 0)
	//alteracao de regime EPP/NL
	aValor[12]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.13"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.13"})][3], 0)
	//alteracao de regime NL/EPP
	aValor[13]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.14"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.14"})][3], 0)
	//Creditos extemporaneos
	aValor[14]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.15"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.15"})][3], 0)
	//Saldo de ICMS antecipado - EPP
	aValor[15]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.16"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.16"})][3], 0)
	//Creditos outros
	aValor[16]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="006.91"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.91"})][3], 0)
	If (aValor[16]>0)
		cDescOutCrd	:=	aApICMMe[aScan (aApICMMe, {|a| a[4]=="006.91"})][2]
	EndIf
	//Estorno debitos outros
	aValor[17]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="007.92"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="007.92"})][3], 0)
	//
	For nI := 1 To Len (aValor)
		nIx++
		If (nIx==10) .Or. (nIx==17)
			If (nIx==10)
				nIx	:=	11
			Else
				nIx	:=	91
			EndIf
		EndIf
			//
		If (aValor[nI]>0)
			RecLock ("APU", .T.)
				APU->APU_TIPO	:=	"OCR"
				APU->APU_ESPE	:=	nIx
				APU->APU_VALO	:=	aValor[nI]
				APU->APU_DSOC	:=	Iif (nIx==91, cDescOutCrd, "")
			MsUnLock ()
		EndIf	
	Next (nI)
	//
	//Gravacao do registro tipo DAE
	For nI := 1 To Len (aDAE)
		RecLock ("APU", .T.)
			APU->APU_TIPO	:=	"DAE"
			APU->APU_NUME	:=	Val (aDAE[nI][1])
			APU->APU_VALO	:=	aDAE[nI][2]
		MsUnLock ()
	Next (nI)
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outros Debitos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIx			:=	0
	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
	//Debito reserva transferencia de credito	
	aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="002.01"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="002.01"})][3], 0)
	//debito diferencial de aliquota
	aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="002.02"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="002.02"})][3], 0)
	//debito transferencia de credito
	aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="002.03"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="002.03"})][3], 0)
	//debito compensacao de devitos na divida ativa
	nPos	:=	aScan (aApICMMe, {|a| a[4]=="002.04"})
	If (nPos<>0)
		For nI := nPos To Len (aApICMMe)	//Verificacao para mais de um lancamento com o codigo 002.04 para numeros de IDA diferentes
			If ("002.04"$aApICMMe[nI][4])
				aValor[4]	+=	aApICMMe[nI][3]
				cIDA	:=	SubStr (aApICMMe[nI][2], At ("[", aApICMMe[nI][2])+1, At ("]", aApICMMe[nI][2])-At ("[", aApICMMe[nI][2])-1)
				aAdd (aIDA, {cIDA, aApICMMe[nI][3]})
			EndIf
		Next (nI)
	EndIf
	//estorno de credito saidas isentas/nao-tributadas
	aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="003.06"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="003.06"})][3], 0)
	//estorno de creditos de bens do ativo permanente por saidas nao tributadas
	aValor[6]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="003.07"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="003.07"})][3], 0)
	//estorno de credito suframa
	aValor[7]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="003.08"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="003.08"})][3], 0)
	//estorno de credito de bens do ativo por baixa
	aValor[8]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="003.09"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="003.09"})][3], 0)
	//FECOP ICMS normal
	aValor[9]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="002.10"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="002.10"})][3], 0)
	//Debitos outros
	aValor[10]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="002.98"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="002.98"})][3], 0)
	//Estorno de creditos outros
	aValor[11]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="003.99"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="003.99"})][3], 0)
	//
	For nI := 1 To Len (aValor)
		nIx++
		If (nIx==5) .Or. (nIx==11)
			If (nIx==5)
				nIx	:=	6
			Else
				nIx	:=	98
			EndIf
		EndIf
		//
		If (aValor[nI]>0)
			RecLock ("APU", .T.)
				APU->APU_TIPO	:=	"ODB"
				APU->APU_ESPE	:=	nIx
				APU->APU_VALO	:=	aValor[nI]
				APU->APU_DSOC	:=	""
			MsUnLock ()
		EndIf	
	Next (nI)
	//
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Deducoes³
	//ÀÄÄÄÄÄÄÄÄÙ
	nIx			:=	0
	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
	//Deducao referente ao FDI - provin
	aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="012.01"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="012.01"})][3], 0)
	//Deducao referente ao FECOP do ICMS Normal
	aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="012.02"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="012.02"})][3], 0)
	//incentivo fiscal
	aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="012.03"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="012.03"})][3], 0)
	//
	For nI := 1 To Len (aValor)
		If (aValor[nI]>0)
			RecLock ("APU", .T.)
				APU->APU_TIPO	:=	"DED"
				APU->APU_ESPE	:=	nI
				APU->APU_VALO	:=	aValor[nI]
				APU->APU_DSOC	:=	""
			MsUnLock ()
		EndIf	
	Next (nI)
	//
	//Gravacao do registro tipo IDA
	For nI := 1 To Len (aIDA)	
		RecLock ("APU", .T.)
			APU->APU_TIPO	:=	"IDA"
			APU->APU_NUME	:=	Val (aIDA[nI][1])
			APU->APU_VALO	:=	aIDA[nI][2]
		MsUnLock ()
	Next (nI)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ApurEcf   ³ Autor ³Gustavo G. Rueda       ³ Data ³23.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para os cupons fiscais ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo de processamento.            ³±±
±±³          ³ExpD -> Data final do periodo de processamento.             ³±±
±±³          ³ExpC -> Controle do bloco de gravacao. Todos registros vao  ³±±
±±³          ³ ter o mesmo codigo de controle.                            ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±³          ³ExpL -> Flag de existencia do parametro MV_AIDFCE na dicio- ³±±
±±³          ³ nario de dados.                                            ³±±
±±³          ³ExpN -> Posicao do campo relacionado no paramentro MV_PRDPRI³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ApurEcf (dDtIni, dDtFim, cControle, nMVPRDPRI, nMVA2SUFR, aMVAIDFCE, cMVDISPAUT)
	Local	cAliasSfi	:=	"SFI"
	Local	cAliasSD2	:=	"SD2"
	Local	cQuery		:=	""
	Local	nItem		:=	0
	Local	cProdutoCf	:=	""
	Local	lFirst		:=	.T.
	Local	cMunic		:=	""
	Local	aTotaliza	:=	{"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local	cNumPdv		:=	""
	Local	cEstEntr	:=	""
	Local	nTotal		:=	0
	Local	cMVUNDIEF	:=	GetNewPar ("MV_UNDIEF",	"")
	Local	cMVDIEFECF	:=	GetNewPar ("MV_DIEFECF","")  // Indica quais situacoes tributarias (D2_CLASFIS) deverao ser tratadas como Nao incidencia no cupom fiscal
	Local	cVersao		:= _aTotal[004][1][11]		//Versao do Layout
	Local	cSerCup		:=	""
	Local	cCupom		:=	""
	Local	cUn			:=	""
	Local   nValorTol   :=  0
	//                                               
	#IFDEF TOP
		Local	aStruSFI 	:= 	SFI->(dbStruct())		
		Local	nSfi		:=	0
		Local	aStruSd2	:= 	SD2->(dbStruct ())
		Local	nX			:=	0
	#ELSE
		Local	cIndex 	:=	""
		Local	cKey 	:= 	""
	#ENDIF
	//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONAMENTO DAS TABELAS UTILIZADAS   ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
SF1->(DbSetOrder(1))
SF4->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SB5->(DbSetOrder(1))
SF2->(DbSetOrder(1))
SF3->(DbSetOrder(6))

	DbSelectArea (cAliasSfi)
		(cAliasSfi)->(DbSetOrder (1))
	//
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
		    cAliasSFI:= "A940aSFI"
			cQuery := "SELECT * "
			cQuery += "FROM "
			cQuery += RetSqlName ("SFI") + " SFI "
			cQuery += "WHERE "
			cQuery += "SFI.FI_FILIAL = '"+xFilial ("SFI")+"' AND "
			cQuery += "SFI.FI_DTMOVTO>='"+Dtos (dDtIni)+"' AND "
			cQuery += "SFI.FI_DTMOVTO<='"+Dtos (dDtFim)+"' AND "
			cQuery += "SFI.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder (SFI->(IndexKey()))
			//
			cQuery := ChangeQuery (cQuery)
		 	//
			DbUseArea (.T., "TOPCONN", TcGenQry (,, cQuery), cAliasSFI)
			//
			For nSFI := 1 To Len (aStruSFI)
				If (aStruSFI[nSFI][2]<>"C") .And. (SFI->(FieldPos (aStruSFI[nSFI][1]))>0)
					TcSetField (cAliasSFI, aStruSFI[nSFI][1], aStruSFI[nSFI][2], aStruSFI[nSFI][3], aStruSFI[nSFI][4])
				EndIf
			Next (nSFI)
		Else
	#ENDIF	
			cIndex 	:=	CriaTrab (,.F.)
			cKey 	:= 	(cAliasSfi)->(IndexKey ())
			cQuery 	:= 	'FI_FILIAL == "'+xFilial("SFI")+'" .And. (Dtos(FI_DTMOVTO) >= "'+Dtos(dDtIni)+'" .And. Dtos(FI_DTMOVTO) <= "'+Dtos(dDtFim)+'")'
			IndRegua (cAliasSFI, cIndex, cKey,, cQuery, "Selecionando Registros...")
	#IFDEF TOP
		Endif
	#ENDIF	
	//
	DbSelectArea (cAliasSFI)
		(cAliasSfi)->(DbGoTop ())
	Do While !(cAliasSFI)->(Eof ())
		//
		//Concatenado Zero devido ao loja gravar no SFI 3 posicoes para o campo FI_PDV e no SD2 com 4 posicoes no campo D2_PDV. Instrucao passada pelo pessoal do loja.
		If Len (AllTrim ((cAliasSfi)->FI_PDV))==3
			cNumPdv	:=	"0"+AllTrim ((cAliasSfi)->FI_PDV)
		Else
			cNumPdv	:=	AllTrim ((cAliasSfi)->FI_PDV)
		EndIf

		//
		cAliasSd2	:=	"SD2"
		DbSelectArea (cAliasSd2)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
			    cAliasSD2 	:= 	"a940ASD2"
				cQuery 		:= 	"SELECT * "
				cQuery 		+= 	"FROM "+RetSqlName ("SD2")+" "
				cQuery 		+= 	"WHERE D2_FILIAL='"+xFilial ("SD2")+"' AND "
				cQuery 		+= 	"D2_EMISSAO='"+DToS ((cAliasSFI)->FI_DTMOVTO)+"' AND "
				cQuery		+= 	"(D2_CF LIKE '5%' OR D2_CF LIKE '6%' OR D2_CF LIKE '7%') AND "
				cQuery		+= 	"D2_PDV='"+cNumPdv+"' AND "
				cQuery		+= 	"D_E_L_E_T_ = ' ' "
				cQuery		+=	"ORDER BY D2_COD, D2_CF "
		   		//
				cQuery	:=	ChangeQuery(cQuery)
				DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSD2, .T., .T.)
				//
				For nX := 1 To Len (aStruSd2)
					If aStruSd2[nX][2]<>"C" .And. SD2->(FieldPos(aStruSd2[nX][1])<>0)
						TcSetField (cAliasSD2, aStruSd2[nX][1], aStruSd2[nX][2], aStruSd2[nX][3], aStruSd2[nX][4])
					EndIf
				Next (nX)
			 Else
		#ENDIF			
			     cIndex 	:=	CriaTrab(NIL,.F.)
				 cKey	 	:= 	'D2_COD+D2_CF'
				 cQuery 	:= 	'D2_FILIAL == "'+xFilial ("SD2")+'" .And. Dtos (D2_EMISSAO)=="'+DToS((cAliasSFI)->FI_DTMOVTO)+'" '
				 cQuery 	+= 	'.And. AllTrim (D2_PDV)="'+cNumPdv+'" '
				 cQuery		+= 	'.And. Substr(D2_CF,1,1)$"5,6,7"'
				 //
				 IndRegua (cAliasSD2, cIndex, cKey,,cQuery, "D2_COD+D2_CF")
				 nIndex := RetIndex (cAliasSD2)
				 #IFNDEF TOP
				 	DbSetIndex (cIndex+OrdBagExt ())
				 #ENDIF			 
				 DbSelectArea (cAliasSD2)
				 DbSetOrder (nIndex+1)
		#IFDEF TOP
			 EndIf
		#ENDIF
		//
		nItem	:=	0		
		//
			(cAliasSD2)->(DbGotop())
		Do While !(cAliasSd2)->(Eof ()) 		
			// VERIFICA SE O ITEM SELECIONADO E UMA NOTA SE NAO FOR SEGUE
			SF2->(DbSeek (xFilial ("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_FORMUL))
			If Empty(SF2->F2_PDV)
				(cAliasSd2)->(DbSkip())
			    Loop
			EndIf
			
			//
			aTotaliza		:=	{"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,""}
			cControle		:=	StrZero (Val (cControle)+1, 20)	
			aTotaliza[1]	:=	cControle
			aTotaliza[19]	:=	(cAliasSD2)->D2_CF
			cProdutoCf		:=	(cAliasSD2)->D2_COD+(cAliasSD2)->D2_CF
			lFirst			:=	.T.			
			cEstEntr		:=	""
			//
			Do While !(cAliasSd2)->(Eof ()) .And. cProdutoCf==(cAliasSD2)->D2_COD+(cAliasSD2)->D2_CF  
					// VERIFICA SE O ITEM SELECIONADO E UMA NOTA SE NAO FOR SEGUE
				SF2->(DbSeek (xFilial ("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_FORMUL))
				If Empty(SF2->F2_PDV)
					(cAliasSd2)->(DbSkip())
				    Loop
				EndIf
		
				aTotaliza[2]	+=	(cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
				aTotaliza[3]	+=	(cAliasSD2)->D2_VALFRE
				aTotaliza[4]	+=	(cAliasSD2)->D2_DESPESA
				aTotaliza[5]	+=	(cAliasSD2)->D2_DESCON

				//Verifica se TES está com campo F4_INCSOL como "N"
				IF AllTrim(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_INCSOL")) == "N"
					aTotaliza[6]	+=	((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA+(cAliasSD2)->D2_VALFRE)
				Else
					aTotaliza[6]	+=	((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA+(cAliasSD2)->D2_VALFRE)
				EndIf	

				aTotaliza[18]	+=	(cAliasSD2)->D2_SEGURO
				nTotal			:=	((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA+(cAliasSD2)->D2_VALFRE)
				//
				If 	(lFirst)
					lFirst	:=	.F.					
					nItem++
					//
					cMunic	:=	PAR (cAliasSD2, "S", cControle, nMVA2SUFR, .T., @cEstEntr)	//So SF3, SA1 e SA2
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Registro DFR somente na saida conforme e-mail de 11/10/2005³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Processamento de documentos diferidos. (Cupom Fiscal)
					If !Empty(SF2->F2_NFCUPOM)
						cSerCup	:=	Padr(SubStr(SF2->F2_NFCUPOM,1, SerieNfId("SF2",6,"F2_SERIE") ), SerieNfId("SF2",6,"F2_SERIE")  )
						cCupom	:=	Padr(SubStr(SF2->F2_NFCUPOM, SerieNfId("SF2",6,"F2_SERIE")+1,TamSx3("F2_DOC")[1]+ SerieNfId("SF2",6,"F2_SERIE") ),TamSx3("F2_DOC")[1])
	
						If SF3->(dbSeek(xFilial("SF3")+cCupom+cSerCup))
					       DFR ("SF3", cControle, aMVAIDFCE,.F., cMVDISPAUT,.T.)    //So SF3
					    EndIf   
				    EndIf
					//
					RecLock ("TRB", .T.)
						TRB->TRB_REGI	:=	"CFC"
						TRB->TRB_NCXA	:=	Val ((cAliasSfi)->FI_PDV)
						TRB->TRB_OPER	:=	"11"
						TRB->TRB_MODE	:=	ModDief ("37")
						TRB->TRB_SERI	:=	""
						TRB->TRB_SUBS	:=	""
						TRB->TRB_NUMI	:=	Val ((cAliasSfi)->FI_COO)
						TRB->TRB_NUMF	:=	Val ((cAliasSfi)->FI_COO)
						TRB->TRB_CFOP	:=	Val ((cAliasSD2)->D2_CF)
						TRB->TRB_DEMI	:=	DToS ((cAliasSFI)->FI_DTMOVTO)
						TRB->TRB_DOPE	:=	DToS ((cAliasSFI)->FI_DTMOVTO)
						TRB->TRB_AIDF	:=	0
						TRB->TRB_DISP	:=	5
						TRB->TRB_NIND	:=	0
						TRB->TRB_NFID	:=	0
						TRB->TRB_CONT	:=	cControle
					MsUnLock ()
					//
					//Se encontrar SF4 correspondente continuo ou aborta o processamento
					If SF4->(DbSeek (xFilial ("SF4")+(cAliasSD2)->D2_TES))
						//
						//Se encontrar SB1 correspondente continuo ou aborta o processamento
						If (SB1->(DbSeek (xFilial ("SB1")+(cAliasSD2)->D2_COD)))				
							//Verifica preenchimento do parametro MV_UNDIEF
							If !Empty(cMVUNDIEF)
								nPos := at(SB1->B1_UM+"=",cMVUNDIEF)
								If nPos > 0
									cUn := Substr(cMVUNDIEF,at(SB1->B1_UM+"=",cMVUNDIEF)+3,2)
								Else
									cUn := SB1->B1_UM
	                            Endif
	                        Else
	                        	cUn := SB1->B1_UM
                            Endif
                            //
							If !(PRD->(DbSeek ((cAliasSD2)->D2_COD)))
								RecLock ("PRD", .T.)
									PRD->PRD_CODI	:=	(cAliasSD2)->D2_COD
									PRD->PRD_DESC	:=	SB1->B1_DESC
									PRD->PRD_UNID	:=	Iif(AllTrim(cUn)=="TL","KG",cUn)
									PRD->PRD_TPPR	:=	Iif (Empty (SB1->B1_CODISS), 1, IiF ("S"$SF4->F4_ICM, 2, 3))
									PRD->PRD_NCM	:=	SB1->B1_POSIPI
									PRD->PRD_CLPR	:=	""
								MsUnLock ()	
							EndIf
							//
							//Se encontrar SB5 correspondente continuo ou aborta o processamento
							If (SB5->(DbSeek (xFilial ("SB5")+SB1->B1_COD)))
								//
								//Gravacao do registro tipo PRI
								If (nMVPRDPRI<>0) .And. (SB5->(FieldGet (nMVPRDPRI))$"S")
								
									If SubStr(SD2->D2_CF,1,1) == "6"
         								// Alterado conforme FNC 000000336702011
           								// Empresas que emitem CT-e possuem a UF antes do codigo de municipio
           								// Portanto este campo pode ficar com o formato UFXXXXX (7 posicoes)
           								If Len(Alltrim(SM0->M0_CODMUN))<=5									
											cMunic := Substr(Alltrim(SM0->M0_CODMUN),1,5)
										Else
											cMunic := Substr(Alltrim(SM0->M0_CODMUN),1,5)
										EndIf											
                                    EndIf
									If !(PRI->(DbSeek (StrZero (Val (cMunic), 5))))
										RecLock ("PRI", .T.)
											PRI->PRI_MUNI	:=	Val (cMunic)
									Else
										RecLock ("PRI", .F.)
									EndIf
											PRI->PRI_VRAQ	+=	(cAliasSD2)->D2_TOTAL
										MsUnLock ()
								EndIf
					        EndIf
					    EndIf
					EndIf
					//
					RecLock ("ITE", .T.)
						ITE->ITE_CONT	:=	cControle
						ITE->ITE_ITEM	:=	nItem
						ITE->ITE_CODI	:=	(cAliasSD2)->D2_COD
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³O codigo da Situacao Tributaria para Cupom Fiscal deve ser o da tabela 18³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cClasFis := ""                                
						Do Case
						Case SubStr((cAliasSD2)->D2_CLASFIS,2,2) == "00" 			// Tributada Integralmente
							If (cAliasSD2)->D2_PICM == 17
								cClasFis := "T17"
							ElseIf (cAliasSD2)->D2_PICM == 7
								cClasFis := "T07"
							ElseIf (cAliasSD2)->D2_PICM == 12
								cClasFis := "T12"               
							ElseIf (cAliasSD2)->D2_PICM == 25
								cClasFis := "T25"
							Endif
						Case SubStr((cAliasSD2)->D2_CLASFIS,2,2) == "20" 			// Reducao na Base de Calculo
							cClasFis := "TR"
						Case SubStr((cAliasSD2)->D2_CLASFIS,2,2) $ "40/41"			// Isenta/Nao Tributada
							cClasFis := "I"
						Case SubStr((cAliasSD2)->D2_CLASFIS,2,2) $ "10/30/60/70" 	// Substituicao
							cClasFis := "F"
						Case SubStr((cAliasSD2)->D2_CLASFIS,2,2) $ cMVDIEFECF	 	// Nao Incidencia
							cClasFis := "N"
						EndCase
						ITE->ITE_CST	:=	cClasFis
				Else
					//
					DbSelectArea ("SF4")
						SF4->(DbSetOrder (1))
					SF4->(DbSeek (xFilial ("SF4")+(cAliasSD2)->D2_TES))		
					//
					RecLock ("ITE", .F.)
				EndIf
					ITE->ITE_QTDE	+=	Iif(AllTrim(cUn)=="TL",(cAliasSD2)->D2_QUANT*1000,(cAliasSD2)->D2_QUANT)
					_nVunit 		:=  (cAliasSD2)->D2_PRCVEN
					nValorTol    	+=	Iif(AllTrim(cUn)=="TL",_nVunit/1000,(cAliasSD2)->D2_TOTAL)
					ITE->ITE_VRUN	:=  (nValorTol/ITE->ITE_QTDE)
					ITE->ITE_BCIC	+=	(cAliasSD2)->D2_BASEICM
					ITE->ITE_ICMS	+=	(cAliasSD2)->D2_VALICM
					ITE->ITE_BCSU	+=	(cAliasSD2)->D2_BRICMS
					ITE->ITE_ICSU	+=	(cAliasSD2)->D2_ICMSRET
					ITE->ITE_CVF	+=	0	//Informar apenas nas entradas
					ITE->ITE_BCIP	+=	Iif (SF4->F4_LFIPI$"T", (cAliasSD2)->D2_BASEIPI, 0)
					ITE->ITE_IIPI	+=	Iif (SF4->F4_LFIPI$"IN", Iif ("N"$SF4->F4_IPI, nTotal, (cAliasSD2)->D2_BASEIPI), 0)
					ITE->ITE_OIPI	+=	Iif (SF4->F4_LFIPI$"O", (cAliasSD2)->D2_BASEIPI, 0)
					ITE->ITE_IPI	+=	Iif (SF4->F4_LFIPI$"T", (cAliasSD2)->D2_VALIPI, 0)
					ITE->ITE_CVFI	+=	0	//Informar apenas nas entradas
					ITE->ITE_DESC	+=	(cAliasSD2)->D2_DESCON
					ITE->ITE_ACRE	+=	0
				MsUnLock ()
				//
				aTotaliza[7]	+=	(cAliasSD2)->D2_ICMSRET
				aTotaliza[8]	+=	Iif (SF4->F4_LFICM$"T", (cAliasSD2)->D2_BASEICM, 0)
				aTotaliza[9]	+=	Iif (SF4->F4_LFICM$"T", (cAliasSD2)->D2_VALICM, 0)
				aTotaliza[10]	+=	Iif (SF4->F4_LFICM$"IN", Iif ("N"$SF4->F4_ICM, nTotal, (cAliasSD2)->D2_BASEICM), 0)
				aTotaliza[11]	+=	Iif (SF4->F4_LFICM$"O", Iif ("N"$SF4->F4_ICM, nTotal, (cAliasSD2)->D2_BASEICM), 0)
				aTotaliza[12]	+=	(cAliasSD2)->D2_BRICMS
				aTotaliza[13]	+=	(cAliasSD2)->D2_ICMSRET
				aTotaliza[14]	+=	Iif (SF4->F4_LFIPI$"T", (cAliasSD2)->D2_BASEIPI, 0)
				aTotaliza[15]	+=	Iif (SF4->F4_LFIPI$"IN", Iif ("N"$SF4->F4_IPI, nTotal, (cAliasSD2)->D2_BASEIPI), 0)
				aTotaliza[16]	+=	Iif (SF4->F4_LFIPI$"O", Iif ("N"$SF4->F4_IPI, nTotal, (cAliasSD2)->D2_BASEIPI), 0)
				aTotaliza[17]	+=	Iif (SF4->F4_LFIPI$"T", (cAliasSD2)->D2_VALIPI, 0)
				//
				(cAliasSd2)->(DbSkip ())				
			EndDo
			//
			//totalizador de documentos fiscais				
			TOT (aTotaliza)

			//Grava Registro Tipo MES - Regime ME, MS, OUTROS e ESPECIAL
			If (cVersao == "300" .Or. cVersao == "400" .Or. cVersao == "500" .Or. cVersao == "600" .Or. cVersao == "608") .And. Left(Alltrim(_aTotal[004][1][1]),2) $ "03/04/05/06"
				GeraMES(aTotaliza)
			Endif

		EndDo
		//
		(cAliasSfi)->(DbSkip ())
		//
		#IFDEF TOP
			DbSelectArea (cAliasSd2)
			DbCloseArea ()
		#ENDIF
	EndDo
	//
	#IFDEF TOP
		DbSelectArea (cAliasSfi)
		DbCloseArea ()
	#ENDIF
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontDCE   ³ Autor ³Gustavo G. Rueda       ³ Data ³21.09.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessaias para documentos fiscais³±±
±±³          ³ cancelados.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSF3 -> Alias da tabela SF3 em processamento.               ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontDCE (cSF3, aMVAIDFCE, cMVDISPAUT, cModelo, lColeta)
	Local	lRet	:=	.T.
	Local	aDisp	:=	{}
	
	If ValType(lColeta) != 'L'
		lColeta := .F.
	EndIf
	
	aDisp:= RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT, lColeta)
	//
	RecLock ("DCE", .T.)
		DCE->DCE_DISP	:=	aDisp[2]			    //Tipo do Dispositivo
		DCE->DCE_SITU	:=	2					    //Situacao = Cancelada(2)
		If cModelo <> '55'  // Nota Fiscal Eletronica
			If (aDisp[2]==1 .Or. aDisp[2]==4)
				DCE->DCE_NUMI	:=	aDisp[3]		//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
				DCE->DCE_NUMF	:=	aDisp[4]		//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
			else
				DCE->DCE_NIND	:=	aDisp[7]		//Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
				DCE->DCE_NFID	:=	aDisp[8]		//Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
	    	endif	 
			DCE->DCE_AIDF	:=	aDisp[1]		 	//Numero da AIDF dos documentos fiscais autorizados		
	    Else
			DCE->DCE_NUMI	:=	0					//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
			DCE->DCE_NUMF	:=	0					//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
			DCE->DCE_AIDF	:=	0		 	    	//Numero da AIDF dos documentos fiscais autorizados			    
	    Endif	
		DCE->DCE_MODE	:=	aDisp[6]			    //Modelo dos documentos fiscais autorizados
		DCE->DCE_SERI	:=	aDisp[9]			    //Serie dos documentos fiscais autorizados
		DCE->DCE_SUBS	:=	""					    //SubSerie dos documentos fiscais autorizados
	MsUnLock ()	
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontDCE2  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 27.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Para o Regime de Pagamento ME, MS, OUTROS ou ESPECIAL.      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSF3 -> Alias da tabela SF3 em processamento.               ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontDCE2 (cSF3, aMVAIDFCE, cMVDISPAUT)
	Local aDisp := RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT)
	//
	RecLock ("DCE", .T.)
		DCE->DCE_DISP	:=	aDisp[2]					//Tipo do Dispositivo
		DCE->DCE_SITU	:=	1					        //Situacao Emitido(1)
			If (aDisp[2]==1 .Or. aDisp[2]==4)
				DCE->DCE_NUMI	:=	aDisp[3]			//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
				DCE->DCE_NUMF	:=	aDisp[4]			//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
			Else	
				DCE->DCE_NIND	:=	aDisp[7]			//Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
				DCE->DCE_NFID	:=	aDisp[8]		    //Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
			EndIF	
		DCE->DCE_MODE	:=	aDisp[6]					//Modelo dos documentos fiscais autorizados
		DCE->DCE_SERI	:=	aDisp[9]					//Serie dos documentos fiscais autorizados
		DCE->DCE_SUBS	:=	""							//SubSerie dos documentos fiscais autorizados
		DCE->DCE_AIDF	:=	aDisp[1]					//Numero da AIDF dos documentos fiscais autorizados		
	MsUnLock ()	
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetDisp   ³ Autor ³Gustavo G. Rueda       ³ Data ³21.09.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna informacoes sobre a AIDF e o dispositivo ³±±
±±³          ³ autorizado para o documento fiscal de acordo com campos da |±±
±±³          ³ tabela SF1 ou SF2, caso nao existam os campos, os valores  |±±
±±³          ³ retornam zerados.                                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array na seguinte estrutura:                        ³±±
±±³          ³ [1] = Numero da AIDF dos documentos fiscais autorizados    |±±
±±³          ³ [2] = Tipo do Dispositivo                                  |±±
±±³          ³ [3] = Numero inicial dos documentos fiscais autorizados    |±±
±±³          ³ [4] = Numero fim dos documentos fiscais autorizados        |±±
±±³          ³ [5] = Data de Autorizacao                                  |±±
±±³          ³ [6] = Modelo dos documentos fiscais autorizados            |±±
±±³          ³ [7] = Numero inicial do dispositivo autorizado             |±±
±±³          ³ [8] = Numero final do dispositivo autorizado               |±±
±±³          ³ [9] = Serie dos documentos fiscais autorizados             |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSF3 -> Alias da tabela SF3 em processamento.               ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±³          ³ExpA -> valores contidos no parametro MV_DISPAUT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT, lColeta)
	Local aRet	:=	{0, 0, 0, 0, CToD ("  /  /  "), "", 0, 0, ""}
	Local aDisp	:=	{}
	Local cMvSerCol	:= SuperGetMV("MV_SERCOL",.F.,"")	
	Local nPosIni     := 0
	Local nTamIni     := 0  
	Local cSerCol     := ""   
	
	If ValType(lColeta) != 'L'
		lColeta := .F.
	EndIf
	
	If !lColeta
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento somente para formulario proprio igual a SIM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Left ((cSF3)->F3_CFO, 1)$"1#2#3") .And. (("N"$(cSF3)->F3_FORMUL) .Or. (Empty ((cSF3)->F3_FORMUL)))
			Return (aRet)
		EndIf
		//
		If Empty (aMVAIDFCE) .Or. Len (aMVAIDFCE)<>4
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Formato do array retornado pela funcao RetAIDF()³
			//³[1] = Numero da AIDF                            ³
			//³[2] = Tipo de Impressao ou Dispositivo          ³
			//³[3] = Numero Inicial                            ³
			//³[4] = Numero Final                              ³
			//³[5] = Data de Autorizacao                       ³
			//³[6] = Modelo da Nota Fiscal                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDisp	:=	RetAIDF ((cSF3)->F3_NFISCAL, (cSF3)->F3_SERIE)
			aRet[1]	:=	Val(SubStr(aRetDig(aDisp[1], .F.),1,11))	
			aRet[2]	:=	Val (aDisp[2])
			aRet[3]	:=	Val ((cSF3)->F3_NFISCAL)        
			aRet[4]	:=	Val ((cSF3)->F3_NFISCAL)       
			aRet[5]	:=	aDisp[5]
			aRet[6]	:=	ModDief (aModNot (aDisp[6]))   
			aRet[7]	:=  Iif("55"$aRet[6],0,Val ((cSF3)->F3_NFISCAL))
			aRet[8]	:=	Iif("55"$aRet[6],0,Val ((cSF3)->F3_NFISCAL))
		Else
			aRet[1]	:=	aMVAIDFCE[1]
			aRet[2]	:=	aMVAIDFCE[2]
			aRet[3]	:=	Val ((cSF3)->F3_NFISCAL)
			aRet[4]	:=	Val ((cSF3)->F3_NFISCAL)
			aRet[5]	:=	MV_PAR02
			aRet[6]	:=	ModDief (aModNot ((cSF3)->F3_ESPECIE))
			aRet[7]	:=	Iif("55"$aRet[6],0,aMVAIDFCE[3])
			aRet[8]	:=	Iif("55"$aRet[6],0,aMVAIDFCE[4])
		EndIf
		aRet[9]	:=	SerieNfId(cSF3,2,"F3_SERIE")
		//
	Else   	
		If !Empty(cMvSerCol)
			If (nPosIni := At('COL'+"=",cMvSerCol)) <> 0
				nPosIni += Len('COL'+"=")
				If (nTamIni := At(";",Substr(cMvSerCol,nPosIni)) - 1) <= 0
					nTamIni := Len(Alltrim(Substr(cMvSerCol,nPosIni))) + 1
				EndIf
				cSerCol := PadR(Substr(cMvSerCol,nPosIni,nTamIni),SerieNfId(cSF3,2,"F3_SERIE") )    
			EndIf   
		Else
			cSerCol:= "COL"
		EndIf                                    
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Formato do array retornado pela funcao RetAIDF()³
		//³[1] = Numero da AIDF                            ³
		//³[2] = Tipo de Impressao ou Dispositivo          ³
		//³[3] = Numero Inicial                            ³
		//³[4] = Numero Final                              ³
		//³[5] = Data de Autorizacao                       ³
		//³[6] = Modelo da Nota Fiscal                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDisp	:=	RetAIDF ((cSF3)->nNumSolIni, cSerCol)
		aRet[1]	:=	Val(SubStr(aRetDig(aDisp[1], .F.),1,11))	
		aRet[2]	:=	Val(aDisp[2])
		aRet[3]	:=	Val((cSF3)->nNumSolIni)        
		aRet[4]	:=	Val((cSF3)->nNumSolFim)       
		aRet[5]	:=	aDisp[5]
		aRet[6]	:=	'20'  
		aRet[7]	:= Iif("55"$aRet[6],0,Val ((cSF3)->nNumSolIni))
		aRet[8]	:=	Iif("55"$aRet[6],0,Val ((cSF3)->nNumSolFim))
		aRet[9]	:=	cSerCol    
	EndIf  
	
	If (LeDispAIDF (cMVDISPAUT, @aDisp, cSF3))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorno array com o conteudo dos campos relacionados no paramentro MV_AIDFAUT exista no dicionario de dados³
		//³[1] = Numero do dispositivo inicial                                                                        ³
		//³[2] = Numero do dispositivo final                                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet[1]	:=	Val(SubStr(aRetDig(aDisp[3], .F.),1,11))	
		aRet[2]	:=	Val (aDisp[4])                             
		aRet[5]	:=	aDisp[5]
		aRet[7]	:=	Val (SubStr (aDisp[1], 1, 10))
		aRet[8]	:=	Val (SubStr (aDisp[2], 1, 10))
	EndIf
Return (aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeDispAIDF³ Autor ³Gustavo G. Rueda       ³ Data ³21.09.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna em uma array passado como referencia     ³±±
±±³          ³ as informacoes sobre o dispositivo (formulario) autorizado |±±
±±³          ³ para o documento fiscal de acordo com campos da tabela SF1 |±±
±±³          ³ ou SF2.                                                    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. se os campos existirem e possuirem conteudo ou  ³±±
±±³          ³ .F. caso contrario.                                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> valores contidos no parametro MV_DISPAUT            ³±±
±±³          ³aDisp -> Array passado por referencia que contera os dispositivos³±±
±±³          ³ExpC -> Alias para a tabela SF3 em processamento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function LeDispAIDF (cMVDISPAUT, aDisp, cSF3)
	Local	lRet		:=	.F.
	Local	nAtCntSF	:=	0
	Local	cCntSF		:=	""     
	Local   aDispAux    := {"", "", "", "", CToD ("  /  /  "), "", ""}
	//
	aDisp				:=	{"", "", "", "", ctod("  /  /  ")} 
	//
	If !(Empty (cMVDISPAUT))
		If (SF3->(FieldPos (cMVDISPAUT))>0)
			cCntSF	:=	(cSF3)->&(cMVDISPAUT)
		EndIf
		cCntSF	:=	AllTrim (Iif (ValType (cCntSF)=="N", Str (cCntSF), cCntSF))
		//
		//Somente se os campos existirem
		If !(Empty (cCntSF))
			lRet	:=	.T.
			//
			If At(";",cCntSF)>0	//Possibilito interpretacao do campo quando tiver o numero do dispositivo inicial e final seprada por ";"
				nAtCntSF := At(";",cCntSF)
				aDisp[1]	:=	SubStr (AllTrim (cCntSF), 1, nAtCntSF-1)		//Dispositivo incial
				aDisp[2]	:=	SubStr (AllTrim (cCntSF), nAtCntSF+1)			//Dispositivo final
			Else
				aDisp[1]	:=	cCntSF											//Dispositivo incial
				aDisp[2]	:=	cCntSF				  							//Dispositivo final
			EndIf
			If !Empty(aDisp[1]) .and. !Empty(aDisp[2]) 
				aDispAux := Dispaut(aDisp, (cSF3)->F3_SERIE)
				aDisp[3] := aDispAux[1]									 	//Numero da Aidf
				aDisp[4] := aDispAux[2]		 								//Tipo de Impressao ou dispositivo
				aDisp[5] := aDispAux[5]										//Data de Autorizacao                       
			EndIf
		EndIf
	EndIf
Return (lRet)                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Dispaut   ºAutor  ³Juliana Taveira     º Data ³  12/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca os dados da aidf pelo numero do dispositivo inicial e º±±
±±º          ³final definido pelo parametro MV_DISPAUT                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                      
Static Function Dispaut(aNf, cSer)
Local aRet		:=	{"", "", "", "", CToD ("  /  /  "), "", ""}
Local aArea		:= 	GetArea ()
Local aSFS		:= 	{}

aSFS := SFS->(GetArea())
DbSelectArea("SFS")
SFS->(DbSetOrder (2))
If SFS->(DbSeek (xFilial ("SFS")+cSer))
	Do While !SFS->(Eof ()) .And. SFS->FS_FILIAL+SFS->FS_SERIE==xFilial("SFS")+cSer
		If (Val(aNf[1])>=Val (SFS->FS_NUMINI)) .And. (Val (aNf[2])<=Val (SFS->FS_NUMFIM))
			aRet[1] := SFS->FS_AIDF	 		//Numero da AIDF
			aRet[2] := SFS->FS_TPIMPR		//Tipo de Impressao ou Dispositivo
			aRet[3] := SFS->FS_NUMINI		//Numero Inicial
			aRet[4] := SFS->FS_NUMFIM		//Numero Final
			aRet[5] := SFS->FS_DATA	  		//Data de Autorizacao
			aRet[6] := SFS->FS_MODELO 		//Modelo da Nota Fiscal
		Endif
		SFS->(DbSkip ())
	Enddo
EndIf
//
RestArea (aSFS)
RestArea (aArea)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SkipSf3   ³ Autor ³Gustavo G. Rueda       ³ Data ³21.09.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que forca skip por nota nara tabela SF3.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Alias para a tabela SF3 em processamento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function SkipSf3 (cSF3)
	Local	lRet	:=	.T.
	Local	cChave	:=	(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
	//
	Do While !(cSF3)->(Eof ()) .And.;
		cChave==(cSF3)->F3_FILIAL+DToS ((cSF3)->F3_ENTRADA)+(cSF3)->F3_NFISCAL+(cSF3)->F3_SERIE+(cSF3)->F3_CLIEFOR+(cSF3)->F3_LOJA+(cSF3)->F3_CFO
		//
		(cSF3)->(DbSkip ())
	EndDo
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegOCC    ³ Autor ³Katia                  ³ Data ³30.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Registros de Ordem de Coleta cARGA- TMS                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
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
Static Function RegOCC(dDataDe, dDataAte, aMVAIDFCE)
Local aArea   := GetArea()
Local cDT5	  := GetNextAlias()   
Local lColeta := .T.         	

//----- Solicitacoes de Coletas Canceladas
	cQuery := "SELECT DT5_NUMSOL nNumSolIni, DT5_NUMSOL nNumSolFim FROM "+RetSQLTab("DT5") 
	cQuery += "JOIN " + RetSQLTab('DUE') 
	cQuery += "  ON  DUE.DUE_FILIAL  = '" + xFilial('DUE') + "' AND "
	cQuery += "      DUE.DUE_CODSOL  = DT5.DT5_CODSOL AND "
	cQuery += "      DUE.D_E_L_E_T_ = ' ' "
 	cQuery += "JOIN " + RetSQLTab('SA1')
	cQuery += "  ON  SA1.A1_FILIAL  = '" + xFilial('SA1') + "' AND "
	cQuery += "      SA1.A1_COD  = DUE.DUE_CODCLI AND "
	cQuery += "      SA1.A1_LOJA = DUE.DUE_LOJCLI AND "
 	cQuery += "      SA1.A1_EST = 'CE' AND "
	cQuery += "      SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DT5_FILIAL = '"+xFilial("DT5")+"'"
	cQuery += "   AND DT5_DATSOL >= '"+DToS(dDataDe)+"'"
	cQuery += "   AND DT5_DATSOL <= '"+DToS(dDataAte)+"'"
	cQuery += "   AND DT5_STATUS = '"+StrZero(9,Len(DT5->DT5_STATUS))+ "'"
	cQuery += "   AND DT5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cDT5)
	While (cDT5)->(!Eof())
		lRet:= .T.
		MontDCE (cDT5, '','','',lColeta)
		(cDT5)->(dbSkip())	
	EndDo
	(cDT5)->(dbCloseArea())		
   
//----- Solicitacoes de Coletas Emitidas
	cDT5:= GetNextAlias() 
	cQuery := "SELECT MIN(DT5_NUMSOL) nNumSolIni, MAX(DT5_NUMSOL) nNumSolFim FROM "+RetSQLTab("DT5")
	cQuery += "JOIN " + RetSQLTab('DUE') 
	cQuery += "  ON  DUE.DUE_FILIAL  = '" + xFilial('DUE') + "' AND "
	cQuery += "      DUE.DUE_CODSOL  = DT5.DT5_CODSOL AND "
	cQuery += "      DUE.D_E_L_E_T_ = ' ' "
	cQuery += "JOIN " + RetSQLTab('SA1')
	cQuery += "  ON  SA1.A1_FILIAL  = '" + xFilial('SA1') + "' AND "
	cQuery += "      SA1.A1_COD  = DUE.DUE_CODCLI AND "
	cQuery += "      SA1.A1_LOJA = DUE.DUE_LOJCLI AND "
 	cQuery += "      SA1.A1_EST = 'CE' AND "
	cQuery += "      SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DT5_FILIAL = '"+xFilial("DT5")+"'"
	cQuery += "   AND DT5_DATSOL >= '"+DToS(dDataDe)+"'"
	cQuery += "   AND DT5_DATSOL <= '"+DToS(dDataAte)+"'"
	cQuery += "   AND DT5_STATUS <> '"+StrZero(9,Len(DT5->DT5_STATUS))+ "'"
	cQuery += "   AND DT5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cDT5)
	If (cDT5)->(!Eof()) .And. !Empty((cDT5)->nNumSolIni)
		lRet:= .T.
		MontDCE3 (cDT5, '','','',lColeta)
	EndIf
	(cDT5)->(dbCloseArea())			      
	
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontDCE3  ³ Autor ³Katia                  ³ Data ³31.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacoes das informacoes necessarias para Ordem de Coletas ³±±
±±³          ³emitidas.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSF3 -> Alias da tabela SF3 em processamento.               ³±±
±±³          ³ExpA -> valores contidos no parametro MV_AIDFCE             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontDCE3(cSF3, aMVAIDFCE, cMVDISPAUT, cModelo, lColeta)

Local	lRet	   :=	.T.
Local	aDisp    :=	{}

aDisp:= RetDisp (cSF3, aMVAIDFCE, cMVDISPAUT, .T.)  //Coleta        

RecLock ("DCE", .T.)
	DCE->DCE_DISP	:=	aDisp[2]			    //Tipo do Dispositivo
	DCE->DCE_SITU	:=	2					    //Situacao = Cancelada(2)
	If cModelo <> '55'  						// Nota Fiscal Eletronica
		If (aDisp[2]==1 .Or. aDisp[2]==4)
			DCE->DCE_NUMI	:=	aDisp[3]		//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
			DCE->DCE_NUMF	:=	aDisp[4]		//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
		Else
			DCE->DCE_NIND	:=	aDisp[7]		//Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
			DCE->DCE_NFID	:=	aDisp[8]		//Numero do documento fiscal cancelado caso esp. autorizado for 2- formulario continuo 3- formulario de seguranca
    	Endif	 
		DCE->DCE_AIDF	:=	aDisp[1]		 	//Numero da AIDF dos documentos fiscais autorizados		
    Else
		DCE->DCE_NUMI	:=	0					//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
		DCE->DCE_NUMF	:=	0					//Numero do documento fiscal cancelado caso esp. autorizado for 1- blocos 4- jogos soltos
		DCE->DCE_AIDF	:=	0		 	    	//Numero da AIDF dos documentos fiscais autorizados			    
    Endif	
	DCE->DCE_MODE	:=	aDisp[6]			    //Modelo dos documentos fiscais autorizados
	DCE->DCE_SERI	:=	aDisp[9]			    //Serie dos documentos fiscais autorizados
	DCE->DCE_SUBS	:=	""					    //SubSerie dos documentos fiscais autorizados
MsUnLock ()	 

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIEFCE    ºAutor  ³Microsiga           º Data ³  08/21/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcçao de criação de arquivos, necessário a partir da al- º±±
±±º          ³ teração para gestão corporativa.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fCriaTemp()

Local aStru	:= {}
Local aRet	:= {}

aAdd (aStru,{"PRD_CODI",	"C",	030,	0})	//Codigo Produto
aAdd (aStru,{"PRD_DESC",	"C",	060,	0})	//Descricao Produto
aAdd (aStru,{"PRD_UNID",	"C",	002,	0})	//UM Produto
aAdd (aStru,{"PRD_TPPR",	"N",	001,	0})	//Tipo produto/servico - 1-Mercadoria, 2-Serv. com incidencia ICMS, 3-Serv. sem incidencia ICMS
aAdd (aStru,{"PRD_NCM",		"C",	020,	0})	//NCM Produto
aAdd (aStru,{"PRD_CLPR",	"C",	010,	0})	//Classificacao Produto
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "PRD")
IndRegua ("PRD", cArq, "PRD_CODI")
//
aAdd (aRet, {cArq, "PRD"})
//
aStru	:=	{}
aAdd (aStru,{"GNR_ES",	     "C",	001,	0})	//Se o recolhimento eh em favor do estado(E), ou outros estados(S)
aAdd (aStru,{"GNR_IEDE",	 "C",	020,	0})	//IE da UF destintaria do estabelecimento substituto tributario
aAdd (aStru,{"GNR_UFOR",	 "C",	002,	0})	//UF Origem
aAdd (aStru,{"GNR_BANC",	 "C",	004,	0})	//Banco arracadador
aAdd (aStru,{"GNR_AGEN",	 "C",	005,	0})	//Agencia Banco arrecadador
aAdd (aStru,{"GNR_DIGI",	 "C",	002,	0})	//Digito agencia banco arrecadador
aAdd (aStru,{"GNR_AUTE",	 "C",	020,	0})	//Autenticacao mecanica do banco
aAdd (aStru,{"GNR_DREC",	 "C",	008,	0})	//Data recolhimento
aAdd (aStru,{"GNR_CODR",	 "N",	006,	0})	//Codigo da receita
aAdd (aStru,{"GNR_VENC",	 "C",	008,	0})	//Data vencimento
aAdd (aStru,{"GNR_REFE",	 "C",	006,	0})	//Periodo referencia
aAdd (aStru,{"GNR_VRPR",	 "N",	013,	2})	//Valor principal
aAdd (aStru,{"GNR_ATUA",	 "N",	013,	2})	//Valor da atualizacao monetaria
aAdd (aStru,{"GNR_JURO",	 "N",	013,	2})	//juros
aAdd (aStru,{"GNR_MULT",	 "N",	013,	2})	//multa
aAdd (aStru,{"GNR_VRTO",	 "N",	013,	2})	//vlr total
aAdd (aStru,{"GNR_CONV",	 "C",	030,	0})	//Numero do convenio ou protocolo/mercadorias. Campo 15 da GNRE
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "GNR")
IndRegua ("GNR", cArq, "GNR_ES+GNR_IEDE+GNR_UFOR")
//
aAdd (aRet, {cArq, "GNR"})
//
aStru	:=	{}
aAdd (aStru,{"TRB_REGI",	     "C",	003,	0})
aAdd (aStru,{"TRB_OPER",	     "C",	002,	0})
aAdd (aStru,{"TRB_MODE",	     "C",	002,	0})
aAdd (aStru,{"TRB_SERI",	     "C",	003,	0})
aAdd (aStru,{"TRB_SUBS",	     "C",	003,	0})
aAdd (aStru,{"TRB_NUMI",	     "N",	010,	0})
aAdd (aStru,{"TRB_NUMF",	     "N",	010,	0})
aAdd (aStru,{"TRB_CFOP",	     "N",	005,	0})
aAdd (aStru,{"TRB_DEMI",	     "C",	008,	0})
aAdd (aStru,{"TRB_DOPE",	     "C",	008,	0})
aAdd (aStru,{"TRB_FRET",	     "C",	001,	0})
aAdd (aStru,{"TRB_AIDF",	     "N",	011,	0})
aAdd (aStru,{"TRB_DISP",	     "N",	002,	0})
aAdd (aStru,{"TRB_NIND",	     "N",	010,	0})
aAdd (aStru,{"TRB_NFID",	     "N",	010,	0})
//
aAdd (aStru,{"TRB_NCXA",	     "N",	004,	0})		
//
aAdd (aStru,{"TRB_CONT",	     "C",	020,	0})		
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "TRB")
IndRegua ("TRB", cArq, "TRB_REGI+TRB_CONT")
//
aAdd (aRet, {cArq, "TRB"})
//
aStru	:=	{}
aAdd (aStru,{"ITE_CONT",	     "C",	020,	0})
aAdd (aStru,{"ITE_ITEM",	     "N",	004,	0})
aAdd (aStru,{"ITE_CODI",	     "C",	030,	0})
aAdd (aStru,{"ITE_QTDE",	     "N",	017,	8})
aAdd (aStru,{"ITE_VRUN",	     "N",	015,	6})
aAdd (aStru,{"ITE_CFOP",	     "N",	005,	0})
aAdd (aStru,{"ITE_CST",		     "C",	003,	0})
aAdd (aStru,{"ITE_BCIC",	     "N",	013,	2})
aAdd (aStru,{"ITE_ICMS",	     "N",	013,	2})
aAdd (aStru,{"ITE_BCSU",	     "N",	013,	2})
aAdd (aStru,{"ITE_ICSU",	     "N",	013,	2})
aAdd (aStru,{"ITE_CVF",		     "N",	002,	0})
aAdd (aStru,{"ITE_BCIP",	     "N",	013,	2})
aAdd (aStru,{"ITE_IIPI",	     "N",	013,	2})
aAdd (aStru,{"ITE_OIPI",	     "N",	013,	2})
aAdd (aStru,{"ITE_IPI",		     "N",	013,	2})
aAdd (aStru,{"ITE_CVFI",	     "N",	002,	0})
aAdd (aStru,{"ITE_DESC",	     "N",	015,	6})
aAdd (aStru,{"ITE_ACRE",	     "N",	015,	6})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "ITE")
IndRegua ("ITE", cArq, "ITE_CONT+StrZero (ITE_ITEM, 4)+ITE_CODI")
//
aAdd (aRet, {cArq, "ITE"})
//
aStru	:=	{}
aAdd (aStru,{"PAR_CONT",	"C",	020,	0})	//Condicao Participante
aAdd (aStru,{"PAR_COND",	"N",	002,	0})	//Condicao Participante
aAdd (aStru,{"PAR_CNPJ",	"C",	014,	0})	//CNPJ ou CPF do Participante
aAdd (aStru,{"PAR_CGF",		"C",	020,	0})	//CGF Participante
aAdd (aStru,{"PAR_NOME",	"C",	060,	0})	//Nome Participante
aAdd (aStru,{"PAR_UF",		"C",	002,	0})	//UF Participante
aAdd (aStru,{"PAR_SUFR",	"N",	014,	0})	//Inscricao SUFRAMA participante
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "PAR")
IndRegua ("PAR", cArq, "PAR_CONT+PAR_CNPJ")
//
aAdd (aRet, {cArq, "PAR"})
//
aStru	:=	{}
aAdd (aStru,{"DFR_CONT",	"C",	020,	0})
aAdd (aStru,{"DFR_MODE",	"C",	002,	0})
aAdd (aStru,{"DFR_SERI",	"C",	003,	0})
aAdd (aStru,{"DFR_SUBS",	"C",	003,	0})
aAdd (aStru,{"DFR_NUMI",	"N",	010,	0})
aAdd (aStru,{"DFR_NUMF",	"N",	010,	0})
aAdd (aStru,{"DFR_REFE",	"N",	002,	0})
aAdd (aStru,{"DFR_AIDF",	"N",	011,	0})
aAdd (aStru,{"DFR_OBS",		"C",	100,	0})
aAdd (aStru,{"DFR_DISP",	"N",	002,	0})
aAdd (aStru,{"DFR_NUID",	"N",	010,	0})
aAdd (aStru,{"DFR_NUFD",	"N",	010,	0})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "DFR")
IndRegua ("DFR", cArq, "DFR_CONT")
//
aAdd (aRet, {cArq, "DFR"})
//
aStru	:=	{}
aAdd (aStru,{"TOT_CONT",	"C",	020,	0})
aAdd (aStru,{"TOT_VRPR",	"N",	013,	2})
aAdd (aStru,{"TOT_FRET",	"N",	013,	2})
aAdd (aStru,{"TOT_DESP",	"N",	013,	2})
aAdd (aStru,{"TOT_DESC",	"N",	013,	2})
aAdd (aStru,{"TOT_VRDO",	"N",	013,	2})
aAdd (aStru,{"TOT_RETI",	"N",	013,	2})
aAdd (aStru,{"TOT_BCIC",	"N",	013,	2})
aAdd (aStru,{"TOT_ICMS",	"N",	013,	2})
aAdd (aStru,{"TOT_ISEN",	"N",	013,	2})
aAdd (aStru,{"TOT_OUTR",	"N",	013,	2})
aAdd (aStru,{"TOT_BCSU",	"N",	013,	2})
aAdd (aStru,{"TOT_ICSU",	"N",	013,	2})
aAdd (aStru,{"TOT_BCIP",	"N",	013,	2})
aAdd (aStru,{"TOT_ISIP",	"N",	013,	2})
aAdd (aStru,{"TOT_OUIP",	"N",	013,	2})
aAdd (aStru,{"TOT_IPI",		"N",	013,	2})
aAdd (aStru,{"TOT_SEGU",	"N",	013,	2})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "TOT")
IndRegua ("TOT", cArq, "TOT_CONT")
//
aAdd (aRet, {cArq, "TOT"})
//
aStru	:=	{}
aAdd (aStru,{"APU_TIPO",	"C",	003,	0})
aAdd (aStru,{"APU_ESPE",	"N",	002,	0})
aAdd (aStru,{"APU_NUME",	"N",	015,	0})
aAdd (aStru,{"APU_VALO",	"N",	013,	2})
aAdd (aStru,{"APU_DSOC",	"C",	100,	0})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "APU")
IndRegua ("APU", cArq, "APU_TIPO")
//
aAdd (aRet, {cArq, "APU"})
//
aStru	:=	{}
aAdd (aStru,{"PRI_MUNI",	"N",	005,	0})
aAdd (aStru,{"PRI_VRAQ",	"N",	013,	2})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "PRI")
IndRegua ("PRI", cArq, "StrZero (PRI_MUNI, 5)")
//
aAdd (aRet, {cArq, "PRI"})
//
aStru	:=	{}
aAdd (aStru,{"DCT_CONT",	"C",	020,	0})
aAdd (aStru,{"DCT_MUCO",	"N",	005,	0})
aAdd (aStru,{"DCT_UFCO",	"C",	002,	0})
aAdd (aStru,{"DCT_MUEN",	"N",	005,	0})
aAdd (aStru,{"DCT_UFEN",	"C",	002,	0})
aAdd (aStru,{"DCT_QTDE",	"N",	013,	2})
aAdd (aStru,{"DCT_UNID",	"N",	001,	0})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "DCT")
IndRegua ("DCT", cArq, "DCT_CONT")
//
aAdd (aRet, {cArq, "DCT"})
//
aStru	:=	{}
aAdd (aStru,{"DCE_DISP",	"N",	002,	0})		//Especie de dispositivo autorizado, vide tabela 05.
aAdd (aStru,{"DCE_SITU",	"N",	001,	0})		//Situacao dos documentos, vide tabela 06.
aAdd (aStru,{"DCE_NUMI",	"N",	010,	0})		//Numero inicial dos documentos fiscais autorizados
aAdd (aStru,{"DCE_NUMF",	"N",	010,	0})		//Numero final dos documentos fiscais autorizados
aAdd (aStru,{"DCE_NIND",	"N",	010,	0})		//Numero inicial do dispositivo autorizado
aAdd (aStru,{"DCE_NFID",	"N",	010,	0})		//Numero final do dispositivo autorizado
aAdd (aStru,{"DCE_MODE",	"C",	002,	0})		//Modelos de documentos fiscais autorizados, vide tabela 21
aAdd (aStru,{"DCE_SERI",	"C",	003,	0})		//Serie dos documentos fiscais autorizados
aAdd (aStru,{"DCE_SUBS",	"C",	003,	0})		//SubSerie dos documentos fiscais autorizados
aAdd (aStru,{"DCE_AIDF",	"N",	011,	0})		//Numero da AIDF dos documentos fiscais autorizados.
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "DCE")
IndRegua ("DCE", cArq, "StrZero (DCE_NUMI, 10)+DCE_SERI")
//
aAdd (aRet, {cArq, "DCE"})
//
aStru	:=	{}
aAdd (aStru,{"MES_CFOP",	"C",	005,	0})
aAdd (aStru,{"MES_VRPR",	"N",	013,	2})
aAdd (aStru,{"MES_BCIC",	"N",	013,	2})
aAdd (aStru,{"MES_ISEN",	"N",	013,	2})
aAdd (aStru,{"MES_OUTR",	"N",	013,	2})
aAdd (aStru,{"MES_VRDO",	"N",	013,	2})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "MES")
IndRegua ("MES", cArq, "MES_CFOP")
//
aAdd (aRet, {cArq, "MES"})
//
aStru	:=	{}
aAdd (aStru,{"VIC_COD",		"C",	002,	0})
aAdd (aStru,{"VIC_COCR",	"N",	002,	0})
aAdd (aStru,{"VIC_VLCR",	"N",	013,	2})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "VIC")
IndRegua ("VIC", cArq, "VIC_COD")
//
aAdd (aRet, {cArq, "VIC"})
//
aStru	:=	{}
aAdd (aStru,{"STQ_TRIB",	"N",	013,	2})
aAdd (aStru,{"STQ_SUBT",	"N",	013,	2})
aAdd (aStru,{"STQ_ISEN",	"N",	013,	2})	
aAdd (aStru,{"STQ_DEST",	"D",	008,	0})
//
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "STQ")
//
aAdd (aRet, {cArq, "STQ"})

//Inventario
aStru	:=	{}
aAdd (aStru,{"INV_CODI",	"C",	030,	0})
aAdd (aStru,{"INV_QTDE",	"N",	017,	8})
aAdd (aStru,{"INV_VRUN",	"N",	017,	8})	
aAdd (aStru,{"INV_COND",	"C",	001,	0})
aAdd (aStru,{"INV_SITU",	"C",	002,	0})
cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "INV")
IndRegua ("INV", cArq, "INV_CODI")
aAdd (aRet, {cArq, "INV"})

Return(aRet)

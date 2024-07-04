#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISA037.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA037  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 05.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o arquivo e relatorio de conferencia da declaracao    ³±±
±±³          ³ jurada de IVA - Formulario 3323                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - CHI                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA037()

	Local nI       := 0
	Local cQry     := ""
	Local aHead    := {}
	Local aTotal   := {}
	Local aFiliais := {}
	Local cPerg    := "FISA037"

	If Pergunte(cPerg,.T.)
	
		dDataIni := MV_PAR01
		dDataFin := MV_PAR02
		lDebNeg  := .T.		
		aFiliais := MatFilCalc(MV_PAR03 == 1)
		
		If Iif(MV_PAR03 == 1,Len(aFiliais)>0,.T.)
		
			If !(SF3->(FieldPos("F3_VALIMP"+MV_PAR06)) > 0 .and. SF3->(FieldPos("F3_VALIMP"+MV_PAR07)) > 0)
				MsgAlert(STR0016)
				Return Nil
			EndIf
			
			cQry := " SELECT CGC"
			cQry += " ,SUM(NF_NDP) AS NF_NDP"
			cQry += " ,SUM(C_RET) AS C_RET"
			cQry += " ,SUM(QNF_NDP) AS QNF_NDP"
			cQry += " ,SUM(NCP) AS NCP"
			cQry += " ,SUM(QNCP) AS QNCP"
			cQry += " ,SUM(NF_NDC) AS NF_NDC"
			cQry += " ,SUM(V_RET) AS V_RET"
			cQry += " ,SUM(QNF_NDC) AS QNF_NDC"
			cQry += " ,SUM(NCC) AS NCC"
			cQry += " ,SUM(QNCC) AS QNCC"
			cQry += " FROM ("
			cQry += "  SELECT (CASE WHEN SF3.F3_TIPOMOV = 'V' THEN A1_CGC ELSE A2_CGC END) AS CGC"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'C' AND (SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'NDP')) THEN SF3.F3_VALIMP"+MV_PAR06+" ELSE 0 END) AS NF_NDP"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'C') THEN SF3.F3_VALIMP"+MV_PAR07+" ELSE 0 END) AS C_RET"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'C' AND SF3.F3_VALIMP"+MV_PAR06+" > 0 AND (SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'NDP')) THEN 1 ELSE 0 END) AS QNF_NDP"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'C' AND SF3.F3_ESPECIE = 'NCP') THEN SF3.F3_VALIMP"+MV_PAR06+" ELSE 0 END) AS NCP"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'C' AND SF3.F3_VALIMP"+MV_PAR06+" > 0 AND SF3.F3_ESPECIE = 'NCP') THEN 1 ELSE 0 END) AS QNCP"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'V' AND (SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'NDC')) THEN SF3.F3_VALIMP"+MV_PAR06+" ELSE 0 END) AS NF_NDC"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'V') THEN SF3.F3_VALIMP"+MV_PAR07+" ELSE 0 END) AS V_RET"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'V' AND SF3.F3_VALIMP"+MV_PAR06+" > 0 AND (SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'NDC')) THEN 1 ELSE 0 END) AS QNF_NDC"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'V' AND SF3.F3_ESPECIE = 'NCC') THEN SF3.F3_VALIMP"+MV_PAR06+" ELSE 0 END) AS NCC"
			cQry += "  ,(CASE WHEN (SF3.F3_TIPOMOV = 'V' AND SF3.F3_VALIMP"+MV_PAR06+" > 0 AND SF3.F3_ESPECIE = 'NCC') THEN 1 ELSE 0 END) AS QNCC"
			cQry += "  FROM "+RetSqlName("SF3")+" SF3"
			cQry += "  LEFT JOIN "+RetSqlName("SA1")+" SA1 ON (SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA AND SF3.F3_TIPOMOV = 'V') 
			cQry += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON (SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SF3.F3_TIPOMOV = 'C') 
			cQry += "  WHERE SF3.D_E_L_E_T_ = ' ' 
			If MV_PAR03 == 1
				cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
				For nI:=1 To Len(aFiliais)
					If aFiliais[nI,1]
						cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
					EndIf
				Next nI
				cQry += " )"
			Else
				cQry += " AND SF3.F3_FILIAL = '"+xFilial("SF3")+"'"
			EndIf
			cQry += "  AND SF3.F3_EMISSAO >= '"+DTOS(MV_PAR01)+"' 
			cQry += "  AND SF3.F3_EMISSAO <= '"+DTOS(MV_PAR02)+"'
			cQry += "  ) AS FORMUL"
			cQry += " WHERE"
			cQry += " NF_NDP > 0 OR"
			cQry += " C_RET > 0 OR"
			cQry += " QNF_NDP > 0 OR"
			cQry += " NCP > 0 OR"
			cQry += " QNCP > 0 OR"
			cQry += " NF_NDC > 0 OR"
			cQry += " V_RET > 0 OR"
			cQry += " QNF_NDC > 0 OR"
			cQry += " NCC > 0 OR"
			cQry += " QNCC > 0"
			cQry += " GROUP BY CGC"
			
			TCQUERY cQry NEW ALIAS "QRYLVR"
			
			aAdd(aHead,{"A1_CGC",STR0001,"CGC"})//Rut Receptor
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0004,"NF_NDP"})//Total Anual IVA###Compras (NF,NDP)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0005,"C_RET"})//Total Anual IVA###Compras Retido
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0003+CRLF+STR0006+CRLF+STR0007,"QNF_NDP"})//Quantidade###Documentos###IVA (NF,NDP)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0008,"NCP"})//Total Anual IVA###Compras(NCP)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0003+CRLF+STR0006+CRLF+STR0009,"QNCP"})//Quantidade###Documentos###IVA (NCP)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0010,"NF_NDC"})//Total Anual IVA###Vendas (NF,NDC)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0011,"V_RET"})//Total Anual IVA###Vendas Retido
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0003+CRLF+STR0006+CRLF+STR0012,"QNF_NDC"})//Quantidade###Documentos###IVA (NF,NDC)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0002+CRLF+STR0013," NCC"})//Total Anual IVA###Vendas (NCC)
			aAdd(aHead,{"F3_VALIMP"+MV_PAR06+"",STR0003+CRLF+STR0006+CRLF+STR0014,"QNCC"})//Quantidade###Documentos###IVA (NCC)
		
			If FGerTRep(STR0015,aHead,aTotal)//"Declaracao Jurada de IVA - Formulario 3323"
				FGerArq(MV_PAR04,MV_PAR05)
			EndIf
			QRYLVR->(dbCloseArea())
			
		EndIf
	
	EndIf

Return Nil

/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraHead ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera vetor com as definicoes do campo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCampos - [1] Nome do campo da SX3.                        ³±±
±±³          ³           [2] Titulo do campo.                             ³±±
±±³          ³           [3] Nome que deve ser redefinido o campo.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Vetor com as definicoes dos campos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA037                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraHead(aCampos)

	Local nI    := 0
	Local aHead := {}

	//Busca dados dos campos a serem apresentados
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nI:=1 To Len(aCampos)		
		SX3->(dbSeek(Separa(aCampos[nI,1],"+")[1]))
		Aadd(aHead,{ Iif(Len(aCampos[nI])>1,aCampos[nI,2],AllTrim(X3Titulo())),;
		     Iif(Len(aCampos[nI])>2,aCampos[nI,3],TRIM(SX3->X3_CAMPO)),;
		     SX3->X3_PICTURE,;
		     SX3->X3_TAMANHO,;
		     SX3->X3_DECIMAL,;
	         SX3->X3_VALID,;
	         SX3->X3_USADO,;
	         SX3->X3_TIPO,;
	         SX3->X3_ARQUIVO,;
	         SX3->X3_CONTEXT } )
	Next nI

Return aHead

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGerTRep ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao de totas as sections.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Titulo do relatorio.                              ³±±
±±³          ³ aPar02 - array com os campos.                              ³±±
±±³          ³ aPar03 - array com os campos do totalizador.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA037                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGerTRep(cTitulo,aHead,aTotal)

	Local lConfirm := .F.
	Local oReport  := Nil
	Local aCampos  := {}
		
	aCampos := GeraHead(aHead)
	oReport := TReport():New("CONIMP",cTitulo,,{|oReport| FSetImp(oReport,aCampos,aTotal)},cTitulo)
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)
	lConfirm := oReport:PrintDialog()

Return lConfirm

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FSetImp  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao dos dados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar01 - Objeto de impressao.                              ³±±
±±³          ³ aPar02 - array com os campos.                              ³±±
±±³          ³ aPar03 - array com os campos do totalizador.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Query ja montada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA037                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FSetImp(oReport,aCampos,aTotal)

	Local nI      := 0
	Local nLin    := 0
	Local nAltPag := 0
	
	//Define a section principal e os campos
	oDados := TRSection():New(oReport,"",{"QRYLVR"})
	For nI:=1 To Len(aCampos)
		If aCampos[nI,8] == "D"
			TCSetField("QRYLVR",aCampos[nI,2],"D",8,0)  
		EndIf
		TRCell():New(oDados,aCampos[nI,2],"QRYLVR",aCampos[nI,1],aCampos[nI,3],aCampos[nI,4],.F.)
	Next nI
	
	For nI:=1 To Len(aTotal)
		TRFunction():New(oDados:Cell(aTotal[nI]),,"SUM",oBreak,,,,.F.,.F.,.F.)
	Next nI
	
	nAltPag := oReport:PageHeight() - 2
	nLin := 0
	oReport:SetMeter(QRYLVR->(RecCount()) + 1)
	oDados:Init()
	
	dbSelectArea("QRYLVR")
	QRYLVR->(dbGoTop())
	If QRYLVR->(!EOF())
	
		oDados:Init()
		
		Do While QRYLVR->(!EOF())
	        
			//Faz a impressao dos dados
			oDados:PrintLine()
			
			//Quebra de pagina
			nLin := oReport:Row()
			If nLin >= nAltPag
				oReport:EndPage()
				oDados:Finish()
				oDados:Init()
			Endif
			
			QRYLVR->(dbSkip())
			oReport:IncMeter()			
		EndDo
		oDados:Finish()
		
		oReport:IncMeter() 
	
	EndIf
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGerArq  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 05.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a gravacao do arquivo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Diretorio onde o arquivo sera gerado              ³±±
±±³          ³ aPar02 - Nome do arquivo que sera gerado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA037                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGerArq(cDir,cArq)

	Local nHdl		:= 0
	Local cLinha	:= ""
	
	cDir := AllTrim(cDir)
	cArq := AllTrim(cArq)
	
	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop(STR0017)//"Ocorreu um erro ao criar o arquivo."
	Endif
	
	dbSelectArea("QRYLVR")
	QRYLVR->(dbGoTop())
	While QRYLVR->(!EOF())
		cLinha := SubStr(QRYLVR->CGC,1,8)+";"
		cLinha += SubStr(QRYLVR->CGC,9,1)+";"
		cLinha += AllTrim(Str(NF_NDP))+";"
		cLinha += AllTrim(Str(C_RET))+";"
		cLinha += AllTrim(Str(QNF_NDP))+";"
		cLinha += AllTrim(Str(NCP))+";"
		cLinha += AllTrim(Str(QNCP))+";"
		cLinha += AllTrim(Str(NF_NDC))+";"
		cLinha += AllTrim(Str(V_RET))+";"
		cLinha += AllTrim(Str(QNF_NDC))+";"
		cLinha += AllTrim(Str(NCC))+";"
		cLinha += AllTrim(Str(QNCC))+";"
		cLinha += chr(13)+chr(10)
		fWrite(nHdl,cLinha)
		QRYLVR->(dbSkip())
	EndDo
	
	If nHdl > 0
		fClose(nHdl)
	Endif

Return Nil

#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISR006.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISR006  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 28.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime livro de saida/entrada - Costa Rica.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao Efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fiscal - Costa Rica                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR006()
                       
	Local   nI       := 0
	Local   aFiliais := {}
	Local   cQry     := ""
	Local   cTitulo  := ""
	Local   cPerg    := "FISR006"
	Private cTipMov  := "V"
	
	If Pergunte(cPerg,.T.)
		
		cTipMov  := Iif(MV_PAR05 == 1,"V","C")
		aFiliais := MatFilCalc(MV_PAR03 == 1)
		
		cQry := " SELECT"
		cQry += "  SF3.F3_EMISSAO"
		cQry += " ,SF3.F3_NFISCAL"
		cQry += " ,SF3."+SerieNfId('SF3',3,'F3_SERIE')+" F3_SERIE "
		cQry += " ,SF3.F3_BASIMP4"
		cQry += " ,SF3.F3_VALIMP4"
		cQry += " ,SF3.F3_EXENTAS"
		cQry += " ,SF3.F3_BASIMP1"
		cQry += " ,SF3.F3_VALIMP1"
		cQry += " ,SF3.F3_VALMERC"
		cQry += " ,SF3.F3_CLIEFOR"
		cQry += " ,SF3.F3_LOJA"
		cQry += " ,SF3.F3_TIPO"
		cQry += " ,SF3.F3_TES"
		If cTipMov == "C"
			cQry += " ,(CASE WHEN F3_TIPO <> 'D' THEN SF1.F1_MOEDA ELSE SF2.F2_MOEDA END) AS F1_MOEDA"
			cQry += " ,(CASE WHEN F1_TIPO <> 'D' THEN SF1.F1_VALBRUT ELSE SF2.F2_VALBRUT END) AS F1_VALMERC"
			cQry += " ,(CASE WHEN F3_TIPO <> 'D' THEN SF1.F1_TXMOEDA ELSE SF2.F2_TXMOEDA END) AS F1_TXMOEDA"
			cQry += " ,SA2.A2_NOME AS NOME"
			cQry += " ,SFC.FC_IMPOSTO"
			cQry += " ,(CASE WHEN SFC.FC_IMPOSTO = 'ISC' AND SFC.FC_CREDIMP = '1' THEN 1 ELSE 0 END) AS CREDISC"
			cQry += " ,(CASE WHEN SFC.FC_IMPOSTO = 'IVA' AND SFC.FC_CREDIMP = '1' THEN 1 ELSE 0 END) AS CREDIVA"
		Else
			cQry += " ,(CASE WHEN F3_TIPO = 'D' THEN SF1.F1_MOEDA ELSE SF2.F2_MOEDA END) AS F1_MOEDA"
			cQry += " ,(CASE WHEN F1_TIPO = 'D' THEN SF1.F1_VALBRUT ELSE SF2.F2_VALBRUT END) AS F1_VALMERC"
			cQry += " ,(CASE WHEN F3_TIPO = 'D' THEN SF1.F1_TXMOEDA ELSE SF2.F2_TXMOEDA END) AS F1_TXMOEDA"
			cQry += " ,SA1.A1_NOME AS NOME"
		EndIf
		cQry += " FROM "+RetSqlName("SF3")+" SF3"
		If cTipMov == "C"
			cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON (SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ')"
			cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC ON (SFC.FC_FILIAL = '" + xFilial("SFC") + "' AND SF3.F3_TES = SFC.FC_TES AND SFC.D_E_L_E_T_ = ' ')"
			cQry += " LEFT JOIN "+RetSqlName("SF2")+" SF2 ON (SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF3.F3_TIPO = 'D' AND SF3.F3_ESPECIE = SF2.F2_ESPECIE AND SF2.D_E_L_E_T_ = ' ')"
			cQry += " LEFT JOIN "+RetSqlName("SF1")+" SF1 ON (SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF3.F3_TIPO <> 'D' AND SF3.F3_ESPECIE = SF1.F1_ESPECIE AND SF1.D_E_L_E_T_ = ' ')"
		Else
			cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON (SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' ')"
			cQry += " LEFT JOIN "+RetSqlName("SF2")+" SF2 ON (SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF3.F3_TIPO <> 'D' AND SF3.F3_ESPECIE = SF2.F2_ESPECIE AND SF2.D_E_L_E_T_ = ' ')"
			cQry += " LEFT JOIN "+RetSqlName("SF1")+" SF1 ON (SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF3.F3_TIPO = 'D' AND SF3.F3_ESPECIE = SF1.F1_ESPECIE AND SF1.D_E_L_E_T_ = ' ')"
		EndIf
		cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
		cQry += " AND SF3.F3_TIPOMOV = '"+cTipMov+"'"
		cQry += " AND SF3.F3_EMISSAO >= '"+DTOS(MV_PAR01)+"'"
		cQry += " AND SF3.F3_EMISSAO <= '"+DTOS(MV_PAR02)+"'
		cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
		For nI:=1 To Len(aFiliais)
			If aFiliais[nI,1]
				cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
			EndIf
		Next nI
		cQry += " )"
		cQry += " ORDER BY"
		cQry += "  SF3.F3_EMISSAO"
		cQry += " ,SF3.F3_NFISCAL"
		cQry += " ,SF3.F3_SERIE"
		cQry += " ,SF3.F3_CLIEFOR"
		cQry += " ,SF3.F3_LOJA"
		cQry += " ,SF3.F3_TIPO"
		If cTipMov == "C"
			cQry += " ,SFC.FC_IMPOSTO"
		EndIf
		
		TCQUERY cQry NEW ALIAS "QRYLVR"
		TCSetField("QRYLVR","F3_EMISSAO","D",8,0)
		
		If cTipMov == "V"
			cTitulo := STR0001//"Livro de vendas - Moeda: "
		Else
			cTitulo := STR0002//"Livro de compras - Moeda: "
		EndIf
		
		FGerTRep(cTitulo+GetNewPar("MV_MOEDA"+AllTrim(Str(MV_PAR04)),"CRC"))
		QRYLVR->(dbCloseArea())
		
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGerTRep ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o relatorio.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo - Titulo do relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISR007                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGerTRep(cTitulo)

	Local oReport := Nil

	oReport := TReport():New("LVRCOS",cTitulo,,{|oReport| FSetImp(oReport)},cTitulo)
	oReport:SetLandscape()
	oReport:PrintDialog()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FSetImp  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao dos dados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar01 - Objeto de impressao.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Query ja montada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISR007                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FSetImp(oReport)

	Local nI      := 0
	Local nPos    := 0
	Local nSinal  := 0
	Local nTaxC   := 0
	Local nGrvISC := 0
	Local nImpISC := 0
	Local nCrdISC := 0
	Local nExtIVA := 0
	Local nGrvIVA := 0
	Local nImpIVA := 0
	Local nCrdIVA := 0
	Local nTotal  := 0
	Local cTipo   := ""
	Local cChave  := ""
	Local dData   := dDataBase
	Local aTotTip := Array(3,9)
	Local lTemIVA := .F.
	Local cTes    := ""

	aFill(aTotTip[1],0)
	aFill(aTotTip[2],0)
	aFill(aTotTip[3],0)
	
	oDados := TRSection():New(oReport,"",{"QRYLVR"})
	
	TRCell():New(oDados,"F3_EMISSAO","QRYLVR",STR0003,PesqPict("SF3","F3_EMISSAO"),TamSx3("F3_EMISSAO")[1],.F.)//"Data"
	TRCell():New(oDados,"F3_NFISCAL","QRYLVR",STR0004,PesqPict("SF3","F3_NFISCAL"),TamSx3("F3_NFISCAL")[1],.F.)//"Número"
	TRCell():New(oDados,"F3_SERIE"  ,"QRYLVR",STR0005,PesqPict('SF3',SerieNfId('SF3',3,'F3_SERIE'))  ,SerieNfId('SF3',6,'F3_SERIE')  ,.F.)//"Série"
	TRCell():New(oDados,"NOME"      ,"QRYLVR",STR0006,PesqPict("SA2","A2_NOME")   ,20                     ,.F.)//"Fornecedor"	
	TRCell():New(oDados,"F3_TIPO"   ,"QRYLVR",STR0007,PesqPict("SF3","F3_TIPO")   ,10                     ,.F.)//"Tipo"
	TRCell():New(oDados,"F1_MOEDA"  ,"QRYLVR",STR0008,"@!"                        ,3                       ,.F.)//"Moeda"
	TRCell():New(oDados,"F1_VALMERC","QRYLVR",STR0009,PesqPict("SF1","F1_VALMERC"),TamSx3("F1_VALMERC")[1],.F.)//"Valor Original"
	TRCell():New(oDados,"F1_TXMOEDA","QRYLVR",STR0010,PesqPict("SF1","F1_TXMOEDA"),TamSx3("F1_TXMOEDA")[1],.F.)//"TC"
	TRCell():New(oDados,"F3_BASIMP4","QRYLVR",STR0011,PesqPict("SF3","F3_BASIMP4"),TamSx3("F3_BASIMP4")[1],.F.)//"ISC Gravado"
	TRCell():New(oDados,"F3_VALIMP4","QRYLVR",STR0012,PesqPict("SF3","F3_VALIMP4"),TamSx3("F3_VALIMP4")[1],.F.)//"ISC Imposto"
	If cTipMov == "C"
		TRCell():New(oDados,"ISCCRED"   ,"QRYLVR",STR0013,PesqPict("SF3","F3_VALIMP4"),TamSx3("F3_VALIMP4")[1],.F.)//"ISC Creditável"
	EndIf
	TRCell():New(oDados,"F3_EXENTAS","QRYLVR",STR0014,PesqPict("SF3","F3_EXENTAS"),TamSx3("F3_EXENTAS")[1],.F.)//"IVA Isento"
	TRCell():New(oDados,"F3_BASIMP1","QRYLVR",STR0015,PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],.F.)//"IVA Gravado"
	TRCell():New(oDados,"F3_VALIMP1","QRYLVR",STR0016,PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],.F.)//"IVA Imposto"
	If cTipMov == "C"
		TRCell():New(oDados,"IVACRED"   ,"QRYLVR",STR0017,PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],.F.)//"IVA Creditável"
	EndIf
	TRCell():New(oDados,"F3_VALMERC","QRYLVR",STR0018,PesqPict("SF3","F3_VALMERC"),TamSx3("F3_VALMERC")[1],.F.)//"Total"
		
	dbSelectArea("QRYLVR")
	oDados:Init()
	Do While QRYLVR->(!EOF())
	
		//Busca a taxa de conversão
		If MV_PAR04 <> QRYLVR->F1_MOEDA
			nTaxC := 0//RecMoeda(QRYLVR->F3_EMISSAO,MV_PAR04)
		Else
			nTaxC := QRYLVR->F1_TXMOEDA
		EndIf
		
		//Define valor negativo as notas de debito
		If QRYLVR->F3_TIPO == "D"
			nSinal := -1
		Else
			nSinal := 1
		EndIf
		
		nGrvISC := 0
		nImpISC := 0
		nCrdISC := 0
		nExtIVA := 0
		nGrvIVA := 0
		nImpIVA := 0
		nCrdIVA := 0
		cChave  := DTOS(QRYLVR->F3_EMISSAO)+QRYLVR->F3_NFISCAL+QRYLVR->F3_SERIE+QRYLVR->F3_CLIEFOR+QRYLVR->F3_LOJA+QRYLVR->F3_TIPO
		cTes    := QRYLVR->F3_TES
		
		Do While cChave == DTOS(QRYLVR->F3_EMISSAO)+QRYLVR->F3_NFISCAL+QRYLVR->F3_SERIE+QRYLVR->F3_CLIEFOR+QRYLVR->F3_LOJA+QRYLVR->F3_TIPO
		
			If cTipMov == "C"
				If QRYLVR->FC_IMPOSTO == "ISC"
					nGrvISC += QRYLVR->F3_BASIMP4*nSinal
					nImpISC += QRYLVR->F3_VALIMP4*nSinal
					If QRYLVR->CREDISC == 1
						nCrdISC += QRYLVR->F3_VALIMP4*nSinal
					EndIf
				ElseIf QRYLVR->FC_IMPOSTO $ "IVA|IVC"
					nExtIVA += QRYLVR->F3_EXENTAS*nSinal
					nGrvIVA += QRYLVR->F3_BASIMP1*nSinal
					nImpIVA += QRYLVR->F3_VALIMP1*nSinal
					If QRYLVR->CREDIVA == 1
						nCrdIVA += QRYLVR->F3_VALIMP1*nSinal
					EndIf
				EndIf
			Else
				nGrvISC += QRYLVR->F3_BASIMP4*nSinal
				nImpISC += QRYLVR->F3_VALIMP4*nSinal
				nExtIVA += QRYLVR->F3_EXENTAS*nSinal
				nGrvIVA += QRYLVR->F3_BASIMP1*nSinal
				nImpIVA += QRYLVR->F3_VALIMP1*nSinal
			EndIf
			
			oDados:Cell("F3_EMISSAO"):SetValue(QRYLVR->F3_EMISSAO)
			oDados:Cell("F3_NFISCAL"):SetValue(QRYLVR->F3_NFISCAL)
			oDados:Cell("F3_SERIE"  ):SetValue(QRYLVR->F3_SERIE  )
			oDados:Cell("NOME"      ):SetValue(QRYLVR->NOME      )
			If QRYLVR->F3_TIPO == "N"
				oDados:Cell("F3_TIPO"):SetValue(STR0019)//"Fatura"
			ElseIf QRYLVR->F3_TIPO == "C"
				oDados:Cell("F3_TIPO"):SetValue(STR0020)//"Crédito"
			Else
				oDados:Cell("F3_TIPO"):SetValue(STR0021)//"Débito"
			EndIf
			oDados:Cell("F1_MOEDA"  ):SetValue(GetNewPar("MV_SIMB"+AllTrim(Str(QRYLVR->F1_MOEDA)),"CRC"))
			oDados:Cell("F1_VALMERC"):SetValue(QRYLVR->F1_VALMERC*nSinal)
			oDados:Cell("F1_TXMOEDA"):SetValue(xMoeda(1,QRYLVR->F1_MOEDA,MV_PAR04,QRYLVR->F3_EMISSAO,4,,nTaxC))
			nTotal := xMoeda(QRYLVR->F1_VALMERC,QRYLVR->F1_MOEDA,1,QRYLVR->F3_EMISSAO,4,,nTaxC)*nSinal
			dData  := QRYLVR->F3_EMISSAO
			cTipo  := QRYLVR->F3_TIPO
		
			QRYLVR->(dbSkip())
		EndDo
		
		nGrvISC := xMoeda(nGrvISC,1,MV_PAR04,dData,,,nTaxC)
		nImpISC := xMoeda(nImpISC,1,MV_PAR04,dData,,,nTaxC)
		nCrdISC := xMoeda(nCrdISC,1,MV_PAR04,dData,,,nTaxC)
		nExtIVA := xMoeda(nExtIVA,1,MV_PAR04,dData,,,nTaxC)
		nGrvIVA := xMoeda(nGrvIVA,1,MV_PAR04,dData,,,nTaxC)
		nImpIVA := xMoeda(nImpIVA,1,MV_PAR04,dData,,,nTaxC)
		nCrdIVA := xMoeda(nCrdIVA,1,MV_PAR04,dData,,,nTaxC)
		nTotal  := xMoeda(nTotal ,1,MV_PAR04,dData,,,nTaxC)
		
		If nExtIVA <> 0
			DbSelectArea("SFC")
			SFC->(dbSetOrder(2))
			DbGoTop()
			lTemIVA := .F.			
			If SFC->(DbSeek(xFilial("SFC")+cTes))
				While xFilial("SFC") == SFC->FC_FILIAL .And. SFC->FC_TES == cTes .And.!SFC->(Eof())			
					If SFC->FC_IMPOSTO == "IVA" .Or. SFC->FC_IMPOSTO == "IVC" 
						lTemIVA := .T.
						Exit
					Endif
					SFC->(DbSkip())
				End		
			EndIf	
		EndIf
		
		If !lTemIVA 
			nExtIVA := 0
		EndIf			

		dbSelectArea("QRYLVR")
		
		oDados:Cell("F3_BASIMP4"):SetValue(nGrvISC)
 		oDados:Cell("F3_VALIMP4"):SetValue(nImpISC)
		oDados:Cell("F3_EXENTAS"):SetValue(nExtIVA)		
		oDados:Cell("F3_BASIMP1"):SetValue(nGrvIVA)
		oDados:Cell("F3_VALIMP1"):SetValue(nImpIVA)
		oDados:Cell("F3_VALMERC"):SetValue(nTotal)
		If cTipMov == "C"
			oDados:Cell("ISCCRED"):SetValue(nCrdISC)
			oDados:Cell("IVACRED"):SetValue(nCrdIVA)
		EndIf
		
		//Adiciona no totalizador do tipo		
		If cTipo == "N"
			nPos := 1
		ElseIf cTipo == "C" 
			nPos := 2
		Else
			nPos := 3
		EndIf
		aTotTip[nPos,1] += 1
		aTotTip[nPos,2] += nGrvISC
		aTotTip[nPos,3] += nImpISC
		aTotTip[nPos,4] += nCrdISC
		aTotTip[nPos,5] += nExtIVA
		aTotTip[nPos,6] += nGrvIVA
		aTotTip[nPos,7] += nImpIVA
		aTotTip[nPos,8] += nCrdIVA
		aTotTip[nPos,9] += Round(nTotal,2)
		
		//Faz a impressao dos dados
		oDados:PrintLine()
		
		//Quebra de pagina
		nLin := oReport:Row()
		If nLin >= oReport:PageHeight() - 2
			oReport:EndPage()
			oDados:Finish()
			oDados:Init()
		Endif
		
		oReport:IncMeter()			
		
	EndDo
	
	oDados:Cell("F3_EMISSAO"):Hide()
	oDados:Cell("F3_NFISCAL"):Hide()
	oDados:Cell("F3_SERIE"  ):Hide()
	oDados:Cell("NOME"      ):SetValue(STR0022)//"Totais"
	oDados:Cell("F3_TIPO"   ):Hide()
	oDados:Cell("F1_MOEDA"  ):Hide()
	oDados:Cell("F1_VALMERC"):Hide()
	oDados:Cell("F1_TXMOEDA"):Hide()
	oDados:Cell("F3_BASIMP4"):SetValue(aTotTip[1,2]+aTotTip[2,2]+aTotTip[3,2])
	oDados:Cell("F3_VALIMP4"):SetValue(aTotTip[1,3]+aTotTip[2,3]+aTotTip[3,3])
	oDados:Cell("F3_EXENTAS"):SetValue(aTotTip[1,5]+aTotTip[2,5]+aTotTip[3,5])
	oDados:Cell("F3_BASIMP1"):SetValue(aTotTip[1,6]+aTotTip[2,6]+aTotTip[3,6])
	oDados:Cell("F3_VALIMP1"):SetValue(aTotTip[1,7]+aTotTip[2,7]+aTotTip[3,7])
	oDados:Cell("F3_VALMERC"):SetValue(aTotTip[1,9]+aTotTip[2,9]+aTotTip[3,9])
	If cTipMov == "C"
		oDados:Cell("IVACRED"):SetValue(aTotTip[1,8]+aTotTip[2,8]+aTotTip[3,8])
		oDados:Cell("ISCCRED"):SetValue(aTotTip[1,4]+aTotTip[2,4]+aTotTip[3,4])
	EndIf
	oDados:PrintLine()
	oDados:Finish()
	
	oDados := TRSection():New(oReport,"",{"QRYLVR"})
	TRCell():New(oDados,"F3_TIPO"   ,"",STR0007,PesqPict("SF3","F3_TIPO")   ,10                      ,.F.)//"Tipo"
	TRCell():New(oDados,"QUANT"     ,"",STR0023,"@E 999999"                 ,6                       ,.F.)//"Quantidade"
	TRCell():New(oDados,"F3_BASIMP4","",STR0011,PesqPict("SF3","F3_BASIMP4"),TamSx3("F3_BASIMP4")[1],.F.)//"ISC Gravado"
	TRCell():New(oDados,"F3_VALIMP4","",STR0012,PesqPict("SF3","F3_VALIMP4"),TamSx3("F3_VALIMP4")[1],.F.)//"ISC Imposto"
	If cTipMov == "C"
		TRCell():New(oDados,"ISCCRED"   ,"",STR0013,PesqPict("SF3","F3_VALIMP4"),TamSx3("F3_VALIMP4")[1],.F.)//"ISC Creditável"
	EndIf
	TRCell():New(oDados,"F3_EXENTAS","",STR0014,PesqPict("SF3","F3_EXENTAS"),TamSx3("F3_EXENTAS")[1],.F.)//"IVA Isento"
	TRCell():New(oDados,"F3_BASIMP1","",STR0015,PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],.F.)//"IVA Gravado"
	TRCell():New(oDados,"F3_VALIMP1","",STR0016,PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],.F.)//"IVA Imposto"
	If cTipMov == "C"
		TRCell():New(oDados,"IVACRED"   ,"",STR0017,PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],.F.)//"IVA Creditável"
	EndIf
	TRCell():New(oDados,"F3_VALMERC","",STR0018,PesqPict("SF3","F3_VALMERC"),TamSx3("F3_VALMERC")[1],.F.)//"Total"
	oDados:Init()
	For nI:=1 To Len(aTotTip)
		If nI == 1
			oDados:Cell("F3_TIPO"):SetValue(STR0019)//"Fatura"
		ElseIf nI == 2
			oDados:Cell("F3_TIPO"):SetValue(STR0020)//"Crédito"
		Else
			oDados:Cell("F3_TIPO"):SetValue(STR0021)//"Débito"
		EndIf
		oDados:Cell("QUANT"):SetValue(aTotTip[nI,1])
		oDados:Cell("F3_BASIMP4"):SetValue(aTotTip[nI,2])
		oDados:Cell("F3_VALIMP4"):SetValue(aTotTip[nI,3])
		oDados:Cell("F3_EXENTAS"):SetValue(aTotTip[nI,5])
		oDados:Cell("F3_BASIMP1"):SetValue(aTotTip[nI,6])
		oDados:Cell("F3_VALIMP1"):SetValue(aTotTip[nI,7])
		oDados:Cell("F3_VALMERC"):SetValue(aTotTip[nI,9])
		If cTipMov == "C"
			oDados:Cell("ISCCRED"):SetValue(aTotTip[nI,4])
			oDados:Cell("IVACRED"):SetValue(aTotTip[nI,8])
		EndIf
		oDados:PrintLine()
	Next nI
	oDados:Finish()

Return Nil
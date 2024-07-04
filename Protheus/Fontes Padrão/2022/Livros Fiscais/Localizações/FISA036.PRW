#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISA036.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA036  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime livro de saida/entrada.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Chile                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA036()
                       
	Local cQry      := ""
	Local cTitulo   := ""
	Local aHead     := {}
	Local aTotal    := {}
	Local aQuebra   := {}
	Local aSections := {}
	Local aFiliais  := {}
	Local cPerg     := "FISA036"

	Private nPagIni  := 1                //Pagina Inicial
	Private nPagFin  := 0                //Pagina Final
	Private lSelFil  := .F.              //Chama tela de selecao de filiais
	Private lImpCab  := .T.              //Defini se imprime cabecalho e rodape
	Private lDebNeg  := .F.              //Mostra valores de debito como negativo
	Private cTipMov  := "V"              //Tipo do movimento C:Compra - V:Venda
	Private dDataIni := CTOD("01/01/60") //Data inicial do Periodo
	Private dDataFin := CTOD("12/12/40") //Data final do periodo
	
	If Pergunte(cPerg,.T.)
	
		dDataIni := MV_PAR01
		dDataFin := MV_PAR02
		lSelFil  := MV_PAR03 == 1
		lImpCab  := MV_PAR04 <> 2
		nPagFin  := Iif(MV_PAR04 == 3,MV_PAR05,0)
		nPagIni  := MV_PAR06
		cTipMov  := Iif(MV_PAR07 == 1,"V","C")
		lDebNeg  := .T.
		
		aFiliais := MatFilCalc(lSelFil)
		
		If MV_PAR04 <> 3
			cTitulo := Iif(cTipMov == "V",STR0001,STR0023)//"Livro de venda"###"Livro de compra"
			aHead   := {{"F3_ESPECIE"},{"F3_EMISSAO"},{"F3_NFISCAL"}}
			If cTipMov == "V"
				aAdd(aHead,{"A1_NOME"})
				aAdd(aHead,{"A1_CGC"})				
			Else
				aAdd(aHead,{"A2_NOME"})
				aAdd(aHead,{"A2_CGC"})
			EndIf
			aQuebra := {"F3_ESPECIE"}
			aTotal  := {}
			FAglLiv(@aHead,@aTotal)
			aAdd(aHead,{"F3_EXENTAS"})
			aAdd(aTotal,"F3_EXENTAS")
			aAdd(aHead,{"F3_VALCONT"})
			aAdd(aTotal,"F3_VALCONT")
			cQry := GeraQry(aFiliais,aHead,{"F3_ESPECIE","F3_EMISSAO","F3_NFISCAL"})
			aAdd(aSections,{cQry,aHead,aTotal,aQuebra})
			
			aHead   := {{"F3_TIPO"},{"F3_SERIE"},{"COUNT(*)",STR0002,"QUANT"}}//"Quantidade"
			aTotal  := {"QUANT"}
			aQuebra := {"F3_TIPO"}
			FAglLiv(@aHead,@aTotal)
			aAdd(aHead,{"F3_EXENTAS"})
			aAdd(aTotal,"F3_EXENTAS")
			aAdd(aHead,{"F3_VALCONT"})
			aAdd(aTotal,"F3_VALCONT")
			cQry := GeraQry(aFiliais,aHead)
			aAdd(aSections,{cQry,aHead,aTotal,aQuebra})
			
			If lSelFil
				aHead  := {{"F3_FILIAL"}}
				aTotal := {}
				FAglLiv(@aHead,@aTotal)
				aAdd(aHead,{"F3_EXENTAS"})
				aAdd(aTotal,"F3_EXENTAS")
				aAdd(aHead,{"F3_VALCONT"})
				aAdd(aTotal,"F3_VALCONT")
				cQry := GeraQry(aFiliais,aHead)
				aAdd(aSections,{cQry,aHead,aTotal})
			EndIf
		EndIf
	
		FGerTRep(cTitulo,aSections)
	
	EndIf

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FAglLiv  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incrementa os vetores de cabecalho e total para a          ³±±
±±³          ³ implementacao do campo FB_AGLLIV que define se o imposto   ³±±
±±³          ³ deve aparecer de maneira destacada ou aglutinada na        ³±±
±±³          ³ impressao do livro.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - array com os campos que deve ser incrementado.    ³±±
±±³          ³ aPar02 - array do totalizador que deve ser incrementado.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - [1] array com os campos ja incrementado.            ³±±
±±³          ³        [2] array do totalizador ja incrementado.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FAglLiv(aHead,aTotal)

	Local nI    := 0
	Local cQry  := ""
	Local cAglu := ""
	Local aImps := {}
	Local aRet  := {}
	
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	SFB->(dbGoTop())
	SFB->(dbSeek(xFilial("SFB")))
	Do While SFB->(!EOF()) .and. SFB->FB_FILIAL == xFilial("SFB")
		If SFB->FB_AGLLIV=="2"
			aAdd(aImps,{"F3_BASIMP"+SFB->FB_CPOLVRO,STR0024})//"Afeta"
			aAdd(aImps,{"F3_VALIMP"+SFB->FB_CPOLVRO,SFB->FB_CODIGO})
		Else
			cAglu += "F3_VALIMP"+SFB->FB_CPOLVRO+"+"
		EndIf
		SFB->(dbSkip())
	EndDo

	For nI:=1 To Len(aImps)
		aAdd(aHead,aImps[nI])
		aAdd(aTotal,Separa(aImps[nI,1],"+")[1])
	Next nI
	
	If !Empty(cAglu)
		aAdd(aHead,{SubStr(cAglu,1,Len(cAglu)-1),STR0020,"OUTROS"})//"Outros"
		aAdd(aTotal,"OUTROS")
	EndIf
	
	If cPaisLoc == "CHI"
		cQry := NoUtiQry(aHead,"F3_VALIMP1")//SubStr(cTotLin,1,Len(cTotLin)-1))
		aAdd(aHead,{cQry,STR0021,"NOUTI"})//"Nao utilizavel"
		aAdd(aTotal,"NOUTI")
	EndIf
	
	aAdd(aRet,aHead)
	aAdd(aRet,aTotal)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraQry  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera a query para a impressao de acordo com os parametros  ³±±
±±³          ³ informados.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - array com as filiais.                             ³±±
±±³          ³ aPar02 - array com os campos.                              ³±±
±±³          ³ aPar04 - array com os campor que definem a ordem da query. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Query ja montada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraQry(aFiliais,aHead,aOrdem)

	Local   nI       := 0
	Local   cQry     := ""
	Local   cDebNeg  := ""
	Local   aCampos  := {}	
	Default aFiliais := {}
	Default aHead    := {}
	Default aOrdem   := {}
	
	aCampos := GeraHead(aHead)
	
	If lDebNeg
		cDebNeg := " * (CASE WHEN F3_TIPO = 'D' THEN -1 ELSE 1 END)"
	Else
		cDebNeg := ""
	EndIf
	
	cQry := "SELECT"
	cQry += " SF3.F3_FILIAL"
	For nI:=1 To Len(aCampos)
		If aCampos[nI,8] == "N"
			cQry += " ,SUM(("+aHead[nI,1]+")"+cDebNeg+") AS "+aCampos[nI,2]
		Else
			cQry += " ,"+aHead[nI,1]+" AS "+aCampos[nI,2]
		EndIf
	Next nI
	
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	If cTipMov == "V"
		cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON (SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA)"
	Else
		cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON (SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA)"		
	EndIf
	cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
	If lSelFil
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
	cQry += " AND SF3.F3_TIPOMOV = '"+cTipMov+"'"
	cQry += " AND SF3.F3_EMISSAO >= '"+DTOS(dDataIni)+"'"
	cQry += " AND SF3.F3_EMISSAO <= '"+DTOS(dDataFin)+"'
	If cTipMov == "C"
		cQry += " AND SF3.F3_RECHON <> '1'"
	EndIf
	cQry += " GROUP BY"
	cQry += " SF3.F3_FILIAL"
	For nI:=1 To Len(aCampos)
		If aCampos[nI,8] <> "N" .and. !(Len(aHead[nI]) > 2)
			cQry += " ,"+aCampos[nI,2]
		EndIf
	Next nI
	If Len(aOrdem) > 0
		cQry += " ORDER BY "
		For nI:=1 To Len(aOrdem)
			If nI == 1
				cQry += aOrdem[nI]
			Else
				cQry += " ,"+aOrdem[nI]
			EndIf
		Next nI
	EndIf
	
	//cQry := ChangeQuery(cQry)	

Return cQry

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ NoUtiQry ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Traz as notas de devolucao que foram devolvidas em um      ³±±
±±³          ³ periodo maior que tres meses.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - array com os campos.                              ³±±
±±³          ³ aPar02 - campos dos impostos utilizados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Query ja montada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036 - Chile                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NoUtiQry(aHead,cCampos)

	Local   nI      := 0
	Local   cQry    := ""
	Local   cDebNeg := ""
	Local   aCampos := {}
	
	aCampos := GeraHead(aHead)
	
	If lDebNeg
		cDebNeg := " * (CASE WHEN F3_TIPO = 'D' THEN -1 ELSE 1 END)"
	Else
		cDebNeg := ""
	EndIf
	
	cQry += " (SELECT"
	cQry += " SUM(("+cCampos+")"+cDebNeg+") AS NOUTI"
	
	cQry += " FROM "+RetSqlName("SF3")+" SF32"
	If cTipMov == "V"
		cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON (SF32.F3_CLIEFOR = SA1.A1_COD AND SF32.F3_LOJA = SA1.A1_LOJA)"
		cQry += " INNER JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D_E_L_E_T_ = ' ' AND SF32.F3_FILIAL = SD1.D1_FILIAL AND SF32.F3_NFISCAL = SD1.D1_DOC AND SF32.F3_SERIE = SD1.D1_SERIE AND SF32.F3_CLIEFOR = SD1.D1_FORNECE AND SF32.F3_LOJA = SD1.D1_LOJA"
		cQry += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_ = ' ' AND SF2.F2_FILIAL = SD1.D1_FILIAL AND SF2.F2_DOC = SD1.D1_NFORI AND SF2.F2_SERIE = SD1.D1_SERIORI AND SF2.F2_CLIENTE = SD1.D1_FORNECE AND SF2.F2_LOJA = SD1.D1_LOJA"
	Else
		cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON (SF32.F3_CLIEFOR = SA2.A2_COD AND SF32.F3_LOJA = SA2.A2_LOJA)"
		cQry += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_ = ' ' AND SF32.F3_FILIAL = SD2.D2_FILIAL AND SF32.F3_NFISCAL = SD2.D2_DOC AND SF32.F3_SERIE = SD2.D2_SERIE AND SF32.F3_CLIEFOR = SD2.D2_CLIENTE AND SF32.F3_LOJA = SD2.D2_LOJA"		
		cQry += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.D_E_L_E_T_ = ' ' AND SF1.F1_FILIAL = SD2.D2_FILIAL AND SF1.F1_DOC = SD2.D2_NFORI AND SF1.F1_SERIE = SD2.D2_SERIORI AND SF1.F1_FORNECE = SD2.D2_CLIENTE AND SF1.F1_LOJA = SD2.D2_LOJA"
	EndIf
	cQry += " WHERE SF3.F3_FILIAL = SF32.F3_FILIAL"
	For nI:=1 To Len(aCampos)
		If aCampos[nI,8] <> "N" .and. "F3_" $ aCampos[nI,2]
			cQry += " AND SF3."+aHead[nI,1]+" = SF32."+aHead[nI,1]
		EndIf
	Next nI
	
	If AllTrim(TCGetDB()) == "DB2"
		If cTipMov == "V"
			cQry += " AND (CASE WHEN INT(SUBSTR(F3_EMISSAO,5,2)) > INT(SUBSTR(F2_EMISSAO,5,2)) THEN INT(SUBSTR(F2_EMISSAO,5,2))+12 ELSE INT(SUBSTR(F2_EMISSAO,5,2)) END) - INT(SUBSTR(F3_EMISSAO,5,2)) > 3"
		Else
			cQry += " AND (CASE WHEN INT(SUBSTR(F3_EMISSAO,5,2)) > INT(SUBSTR(F1_EMISSAO,5,2)) THEN INT(SUBSTR(F1_EMISSAO,5,2))+12 ELSE INT(SUBSTR(F1_EMISSAO,5,2)) END) - INT(SUBSTR(F3_EMISSAO,5,2)) > 3"
		EndIf
	Else
		If cTipMov == "V"
			cQry += " AND (CASE WHEN MONTH(F3_EMISSAO) > MONTH(F2_EMISSAO) THEN MONTH(F2_EMISSAO)+12 ELSE MONTH(F2_EMISSAO) END) - MONTH(F3_EMISSAO) > 3"
		Else
			cQry += " AND (CASE WHEN MONTH(F3_EMISSAO) > MONTH(F1_EMISSAO) THEN MONTH(F1_EMISSAO)+12 ELSE MONTH(F1_EMISSAO) END) - MONTH(F3_EMISSAO) > 3"
		EndIf
	EndIf
	cQry += ")"

Return cQry

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
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
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
±±³Descricao ³ Gera o relatorio.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo - Titulo do relatorio.                             ³±±
±±³          ³ aSections [x,1] Query com os dados para serem impressos.   ³±±
±±³          ³           [x,2] Array com os campos utilizados.            ³±±
±±³          ³           [x,3] Array com os campos com totalizador.       ³±±
±±³          ³           [x,3] Array com a chave para a quebra.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGerTRep(cTitulo,aSections)

	Local   oReport   := Nil	
	Default aSections := {}

	oReport := TReport():New("CONIMP",cTitulo,,{|oReport| FGerSect(oReport,aSections)},cTitulo)
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)
	oReport:lHeaderVisible := lImpCab // Não imprime cabeçalho do protheus
	oReport:lFooterVisible := lImpCab // Não imprime rodapé do protheus
	oReport:PrintDialog()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGerSect ³ Autor ³ Ivan Haponczuk      ³ Data ³ 08.09.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao de totas as sections.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oReport - Objeto de impressao.                             ³±±
±±³          ³ aSections [x,1] Query com os dados para serem impressos.   ³±±
±±³          ³           [x,2] Array com os campos utilizados.            ³±±
±±³          ³           [x,3] Array com os campos com totalizador.       ³±±
±±³          ³           [x,3] Array com a chave para a quebra.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGerSect(oReport,aSections)

	Local nI      := 0
	Local nJ      := 0
	Local aCampos := {}
	
	oReport:SetPageNumber(nPagIni)
	For nI:=1 To Len(aSections)
	
		For nJ:=Len(aSections[nI]) To 4
			aAdd(aSections[nI],Nil)
		Next nJ
	
		Default aSections[nI,1] := ""
		Default aSections[nI,2] := {}
		Default aSections[nI,3] := {}
		Default aSections[nI,4] := {}
		
		aCampos := GeraHead(aSections[nI,2])
		TCQUERY aSections[nI,1] NEW ALIAS "QRYLVR"
		FSetImp(oReport,aCampos,aSections[nI,3],aSections[nI,4])
		QRYLVR->(dbCloseArea())
	Next nI

	nLin := oReport:Page()
	For nI:=nLin To nPagFin
		oReport:EndPage()
		oReport:StartPage()
	Next nI

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
±±³          ³ aPar02 - array com os campos.                              ³±±
±±³          ³ aPar03 - array com os campos do totalizador.               ³±±
±±³          ³ aPar04 - array com os campor chave para a quebra.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Query ja montada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA036                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FSetImp(oReport,aCampos,aTotal,aQuebra)

	Local nI      := 0
	Local nJ      := 0
	Local nLin    := 0
	Local nPos    := 0
	Local nAltPag := 0
	Local lQuebra := .T.
	Local aQbrAux := Array(Len(aQuebra))
	Local aTotAux := Array(Len(aTotal))
	
	For nI:=1 To Len(aTotal)
		aTotAux[nI] := 0
	Next nI
	
	//Define a section principal e os campos
	oDados := TRSection():New(oReport,"",{"QRYLVR"})
	For nI:=1 To Len(aCampos)
		If aCampos[nI,8] == "D"
			TCSetField("QRYLVR",aCampos[nI,2],"D",8,0)  
		EndIf
		TRCell():New(oDados,aCampos[nI,2],"QRYLVR",aCampos[nI,1],aCampos[nI,3],aCampos[nI,4],.F.)
	Next nI
	
	//Define a quebra e o totalizador da quebra
	For nI:=1 To Len(aQuebra)
		oDados:Cell(aQuebra[nI]):Disable()
		oBreak := TRBreak():New(oDados,oDados:Cell(aQuebra[nI]),"",.F.)
		For nJ:=1 To Len(aTotal)
			TRFunction():New(oDados:Cell(aTotal[nJ]),,"SUM",oBreak,,,,.F.,.F.,.F.)
		Next nJ
	Next nI
	
	//Define a section de cabecalho da quebra
	If Len(aQuebra) > 0
		oQuebra := TRSection():New(oReport,"",{"QRYLVR"})
		For nI:=1 To Len(aQuebra)
			nPos := aScan(aCampos,{|x| x[2] == aQuebra[nI] })
			TRCell():New(oQuebra,aCampos[nPos,2],"QRYLVR",aCampos[nPos,1],,aCampos[nPos,4],.F.)
		Next nI
	EndIf
	
	nAltPag := oReport:PageHeight() - 2
	nLin := 0
	oReport:SetMeter(QRYLVR->(RecCount()) + 1)
	oDados:Init()
	
	dbSelectArea("QRYLVR")
	If QRYLVR->(!EOF())
	
		//Imprime o cabecalho e inicia o controle da quebra
		If Len(aQuebra)>0
			For nI:=1 To Len(aQuebra)
				aQbrAux[nI] := &("QRYLVR->"+aQuebra[nI])
			Next nI
			oQuebra:Init()
			oQuebra:PrintLine()
			oQuebra:Finish()
	   	EndIf
		oDados:Init()
		
		Do While QRYLVR->(!EOF())
	        
			//Imprime o cabecalho na quebra
			If Len(aQuebra)>0
				For nI:=1 To Len(aQuebra)
					lQuebra := aQbrAux[nI] <> &("QRYLVR->"+aQuebra[nI])
					If lQuebra
						Exit
					EndIf
				Next nI
				If lQuebra
					For nI:=1 To Len(aQuebra)
						aQbrAux[nI] := &("QRYLVR->"+aQuebra[nI])
					Next nI
					oDados:Finish()
					oQuebra:Init()
					oQuebra:PrintLine()
					oQuebra:Finish()
					oDados:Init()
				EndIf
			EndIf
	        
			//Faz a impressao dos dados
			oDados:PrintLine()
			
			//Quebra de pagina
			nLin := oReport:Row()
			If nLin >= nAltPag
				oReport:EndPage()
				oDados:Finish()
				oDados:Init()
			Endif
			
			For nI:=1 To Len(aTotal)
				aTotAux[nI] += &("QRYLVR->"+aTotal[nI])
			Next nI
			
			QRYLVR->(dbSkip())
			oReport:IncMeter()			
		EndDo
		oDados:Finish()
		If Len(aQuebra) > 0
			oQuebra:Finish()
		EndIf
		
		If Len(aQuebra) > 0
			oDados:Init()
			oDados:SetHeaderSection(.F.)
			oReport:SkipLine(1)
			oReport:PrintText(STR0022)//"Total Geral:"
			For nI:=1 To Len(aCampos)
				nPos := aScan(aTotal,{|x| x == aCampos[nI,2] })
			   	If nPos > 0
					oDados:Cell(aCampos[nI,2]):SetValue(aTotAux[nPos])
				EndIf
				oDados:Cell(aCampos[nI,2]):Disable()
			Next nI
			oDados:PrintLine()
			oDados:Finish()
		Else
			oDados:Init()
			oDados:SetHeaderSection(.F.)
			oReport:ThinLine()
			For nI:=1 To Len(aCampos)
				nPos := aScan(aTotal,{|x| x == aCampos[nI,2] })
			   	If nPos > 0
					oDados:Cell(aCampos[nI,2]):SetValue(aTotAux[nPos])
				Else
					oDados:Cell(aCampos[nI,2]):Hide()
				EndIf
			Next nI
			oDados:PrintLine()
			oDados:Finish()
		EndIf
		oReport:IncMeter() 
	
	EndIf
	
Return Nil
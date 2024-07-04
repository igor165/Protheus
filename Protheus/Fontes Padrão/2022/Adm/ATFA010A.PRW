#INCLUDE "Protheus.ch"
#INCLUDE "ATFA010A.CH"

// *******************************
// Controle de multiplas moedas  *
// *******************************
STATIC lMultMoed := FindFunction("AtfMoedas")
STATIC lAvpAtf	 := .F.
STATIC lAvpAtf2	 := NIL
STATIC aHeadAvp := {}	//Header da GetDados do AVP
STATIC aColsAvp := {}	//Acols da GetDados do AVP
STATIC __cGrupoFNG := ""

STATIC aHeadMrg := {}		//Header da GetDados da Margem Gerencial
STATIC aColsMrg := {}		//Acols da GetDados  da Margem Gerencial

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
STATIC cIdioma 		:= Upper( Left( FWRetIdiom(), 2 ) )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010ATXT³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recupera um texto do arquivo de descri‡”es extendidas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³af010Texto( )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATXT(cChave)
cTexto:=""

dbSelectArea("SN2")
IF dbSeek(cChave)
	nAnterior:=0
	While !Eof() .and. SN2->N2_FILIAL+SN2->N2_CBASE+SN2->N2_ITEM==cChave
		If SN2->N2_SEQ = SN3->N3_SEQ
			cTexto += Iif(!Empty(SN2->N2_HISTOR),SN2->N2_HISTOR,"") + Chr(13) + Chr(10)
			nAnterior++
			dbSkip( )
			Loop
		Endif
		dbSkip()
	EndDo
EndIf

Return cTexto

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010AAQUI³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se lei 8.200 e Reavali‡„o ‚ valida.                ³±±
±±³          ³Somente ser„o v lidas, se existir aquisi‡„o ou adiantamento.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AAQUI()
Local lRet:=.T., nReg:=0,nx,n1
Local cAlias:=Alias( )
Local l01:=.F.
Local ny
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := AtfNValMod({1}, "|")
	aTypes10 := Separa(cTypes10, "|", .f.)
Endif
aadd( aTypes10, "10") 

cTipoSn3 := &(ReadVar())

If cTipoSn3 $ "02,04,07,08,09"
	dbSelectArea( "SN3" )
	Reg := Sn3->(RecNo( ))
	dbSetOrder( 1 )
	IF !dbSeek( xFilial("SN3") + m->n1_cbase+m->n1_item + "01" ) 

		For nTypes10 := 1 to len(aTypes10)
			If !dbSeek( xFilial("SN3") + m->n1_cbase+m->n1_item + aTypes10[nTypes10] )
				For nx:=1 To Len(aCols)
					IF nx != n1
						For ny:=1 To Len(aHeader)
							If Trim(aHeader[ny][2]) == "N3_TIPO"
								Do Case
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verificar se eh a linha de edicao atual e aplicar validacao do que ³
									//³foi digitado atraves variavel do buffer.                           ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Case nx == n //Verifico se eh a linha atual e aplico a validacao na memoria
										if cTipoSn3 $ ("01|10" + "|" + cTypes10) .and. ! aCols[nx][nUsado+1]
											l01 := .T.
										end
									Case aCols[nx][ny] == "01" .and. ! aCols[nx][nUsado+1]
										l01 := .T.
								EndCase
							End
						Next ny
					End
				Next nx
			Endif
		Next nTypes10
		IF !l01
			Help( " ", 1, "AF010AQUIS",, If(cTipoSn3$"07,08,09","","")  )
			lRet := .F.
		End
	End
	IF !Empty( N3_DTBAIXA ) .and. lRet
		Help( " ", 1, "AF010BAIXA" )
		lRet:=.F.
	End
	dbGoTo( nReg )
End

If cPaisLoc == "ANG"
	If !(cTipoSn3 $ "01/03/07")
		Help( " ", 1, "AF010ANG" )
		lRet:=.F.
	EndIf
EndIf

If cPaisLoc $ "ARG|BRA|COS"
	If lRet .And. cTipoSn3 $ "11" .and. !INCLUI //.and. !aCols[n][Len(aHeader)+1]
		Help(" ",1,"AF010TP11",,STR0030,1,0)		//"Tipo de ativo valido somente na inclusão de um ativo"
		lRet:= .F.
	EndIf
EndIf
dbSelectArea( cAlias )
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010ACHV ³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se ha' chave duplicada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ACHV()
Local lRet := lOk := .T.
Local nPosTipo:=0
Local nLinhaTipo:=0
Local cTypes10		:= ""
cTipoSn3 := &(ReadVar())


If Type('aCols') # 'U' .and. Type('aHeader')#'U'
	nPosTipo:=aScan(aHeader,{|x|alltrim(x[2])=="N3_TIPO"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite mais de uma reavalia‡„o ³
//³ ou mais de um adiantamento.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cTipoSn3 $ "02,05" ) .or. ( cTipoSn3 $ "03/13" ) .Or. ( cTipoSN3 $ ("10" + cTypes10) ) .or. (cTipoSN3 == "11" .and. cPaisLoc $ "ARG|BRA|COS")
	lOk := .F.
Endif

If lOk
	dbSelectArea( "SN3" )
	dbSetOrder( 1 )//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	
	IF SN3->(dbSeek( xFilial("SN3") + M->N1_CBASE+M->N1_ITEM + cTipoSn3+"0" )) // Verifica se existe tipos ativo
		If nPosTipo>0
			If (nLinhaTipo:=aScan(aCols,{|x|rTrim(x[1])==rTrim(cTipoSn3)}))>0 .and. !aCols[nLinhaTipo][(Len(aHeader))+1]//linha não pode estar deletada
				Help( " ",1,"A010JADIG" )
				lRet := .f.
			Endif
		Else//mantendo compatibilidade caso a validação nao venha do acols.
			Help( " ",1,"A010JADIG" )
			lRet := .f.
		Endif
			
	Endif
EndIf
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010ATAXA  ³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche Taxa deprecia‡„o para todas das moedas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATAXA(lGrupo)
Static lZeraDepr
Local nTaxa := 0, ny, aAreaSx3, uRet
local nI	:= 0
Local aPosTaxa	:= {}
Local alMoeda	:= {}
Local nX

Local lOk := .T.
Local aEntidade := {}
Local aHelpPor  := {}
Local aHelpSpa  := {}
Local aHelpEng  := {}
Local lRet := .T.
Local nPosSNG := 0
Local lClass := IIF(type("lClassifica")=="U",.F.,lClassifica)

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

// *******************************
// Controle da moeda Fiscal/PTG  *
// *******************************
Local cMoedaFisc := AllTrim(GetMV("MV_ATFMOED"))
Local cNomeTFSN3 := Subs("N3_TXDEPRn",1,10-len(cMoedaFisc) ) +cMoedaFisc
Local cNomeTFSNG := Subs("NG_TXDEPRn",1,10-len(cMoedaFisc) ) +cMoedaFisc
Local nTxMoedaGF := 0
Local nTxMoedaC  := 0
Local nPos       := 0
Local cNestaCOL  := ""
Local nInc		 := 0
Local lCcdp		 := GetMv("MV_ATFCCDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_CCCUSTO sera replicado para o campo N3_CCDESP
Local lSCdp 	 := GetMv("MV_ATFSCDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_SUBCTA sera replicado para o campo N3_SUBCDEP
Local lCVDP 	 := GetMv("MV_ATFCVDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_CLVL sera replicado para o campo N3_CLVLDEP
DEFAULT lGrupo   := .F.

// *******************************
// Controle de multiplas moedas  *
// *******************************
aAdd( alMoeda , nil )
For nX:= 2 to __nQuantas
	aAdd( alMoeda , Empty(GETMV("MV_MOEDA" + ALLTRIM(Str(nX)))) )
Next

//Validação para verificar se o grupo contabil é igual da tabela SN3 quando for alteração
//Não se aplica quando for Classificação de Compras
If lGrupo .And. !Empty(M->N1_GRUPO) .And. ALTERA .And. FunName() != "ATFA240"
	// Cria array com os nomes dos campos do SNG (Cadastro de grupos)
	SX3->(MsSeek("SNG"))
	SX3->(DbEval( { || Aadd(aEntidade, SX3->X3_CAMPO ) }, , { || SX3->X3_ARQUIVO == "SNG" } ) )
	dbSelectArea("SN3")
	dbSeek(xFilial("SN3") + M->(N1_CBASE+N1_ITEM))
	dbSelectArea("SNG")
	dbSeek(xFilial("SNG") + M->N1_GRUPO)
	For nY := 1 To Len(aEntidade)
		If SN3->(FieldPos("N3_" + Subs(aEntidade[nY], 4))) <> 0 .And. aEntidade[nY] != "NG_FILIAL"
			lRet:= .T.
			If ExistBlock("ATLIBGRP")
				lRet:= ExecBlock("ATLIBGRP",.F.,.F.,{FunName()})
			EndIf
			If SN3->&("N3_" + Subs(aEntidade[nY], 4)) != &("SNG->NG_" + Subs(aEntidade[nY], 4)) .And. lRet
				Help(" ",1,"AF010GRP")
				Return .F.
			EndIf
		Endif
	Next
EndIf

If lGrupo .And. (Empty(M->N1_GRUPO) .Or. !(INCLUI .or. lClass))
	lOk := .F.
Endif

If lOk
	If lGrupo
		SNG->(DbSeek(xFilial("SNG") + M->N1_GRUPO))
	Endif
	If lZeraDepr == Nil
		lZeraDepr := GetNewPar("MV_ZRADEPR",.F.)
	Endif
	
	// Cria array com os nomes dos campos do SNG (Cadastro de grupos)
	IF Len(aEntidade) == 0
		SX3->(MsSeek("SNG"))
		SX3->(DbEval( { || Aadd(aEntidade, SX3->X3_CAMPO ) }, , { || SX3->X3_ARQUIVO == "SNG" } ) )
	ENDIF
	
	For ny:=1 To Len(aHeader)
		If lGrupo .And. "AF010GRUPO" $ Upper(aHeader[ny][11])
			If aAreaSx3 = Nil
				aAreaSx3 := SX3->(GetArea())
				SX3->(DbSetOrder(2))
			Endif
			SX3->(DbSeek(aHeader[ny][2]))
			uRet := CriaVar(aHeader[ny][2])
			If uRet <> Nil
				aCols[n][ny] := uRet
			Endif
		ElseIf Trim(aHeader[nY][2]) != "N3_FILIAL" .AND. aHeader[nY][8] == "C" .AND.; // SOMENTE CAMPOS CARACTER
			(nPosSNG := aScan(aEntidade,{|cEntidade| ALLTRIM(SUBSTR(cEntidade,4,10)) == ALLTRIM(SUBSTR(aHeader[nY][2],4,10))})) > 0
			If lGrupo .and. !EMPTY(&("SNG->"+ALLTRIM(aEntidade[nPosSNG])))
				aCols[n][ny] := &("SNG->"+aEntidade[nPosSNG])
			Endif
		EndIf
	Next ny
	
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	aPosTaxa := If(lMultMoed,AtfMultPos(aHeader,"N3_TXDEPR"),;
		{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR1" } ),;
		Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR2" } ),;
		Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR3" } ),;
		Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR4" } ),;
		Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR5" } ) })
	If !lGrupo
		aCols[n][aPosTaxa[1]] := &(ReadVar())
	Else
		aCols[n][aPosTaxa[1]] := SNG->NG_TXDEPR1
	Endif
	
	If lZeraDepr .and. !lGrupo
		nTaxa := &(ReadVar())
	EndIf
	
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	For nX := 2 to __nQuantas
		If aPosTaxa[nX] <= 0
			Loop
		EndIf
		If alMoeda[nX]	/// Se não tem a moeda informada no parâmetro (Moeda em branco)
			If nX > 9
				If SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX)) ))) > 0
					aCols[n][aPosTaxa[nX]] := 0
				Endif
			Else
				If SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)) ))) > 0
					aCols[n][aPosTaxa[nX]] := 0
				Endif
			Endif
		Elseif !lGrupo
			aCols[n][aPosTaxa[nX]] :=&(ReadVar())
		Else
			If nX > 9
				If SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX)) ))) > 0
					aCols[n][aPosTaxa[nX]] := SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX)) )))
				Endif
			Else
				If SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)) ))) > 0
					aCols[n][aPosTaxa[nX]] := SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)) )))
				Endif
			EndIf
		EndIf
	Next
	
	If aAreaSx3 <> Nil
		SX3->(RestArea(aAreaSx3))
	Endif
	
	If lZeraDepr .and. !lGrupo .And. aCols[n][01] $ "02#05"
		// Assume a ultima taxa para todos os itens
		For nInc := 1 To Len( aCols )
			aEval( aPosTaxa, { |x| aCols[nInc][x] := nTaxa } )
		Next
	Endif
	
	// ************************************
	//*  Regra na moeda Fiscal /PORTUGAL  *
	//*  eh usado como gatilho no valor   *
	//*  inicial na taxa da moeda Fiscal  *
	//   Adilson Soeiro em 18/02/2010     *
	// ************************************
	If cPAISLOC == "PTG" .And. !Empty(cMoedaFisc)
		If M->N1_ART32 == "S"
			Af010Art32()
		Else
			cNestaCOL := ReadVar()
			If 'N3_TXDEPR1' $ cNestaCOL				// Moeda 1/Contabil
				nTxMoedaGF := &("SNG->"+cNomeTFSNG)	// Taxa do Grupo Fiscal
				nTxMoedaC  := &(ReadVar())			// Moeda 1/Contabil
				nPos := Ascan(aHeader, {|e| Alltrim(e[2]) == cNomeTFSN3 })	// Busca a posicao da Moeda Fiscal
				if nPos > 0
					If nTxMoedaC > nTxMoedaGF
						aCols[n][nPos] := nTxMoedaGF
					Else
						aCols[n][nPos] := &(ReadVar())
					Endif
				Endif
			Endif
		EndIf
	Endif
	  
	If lGrupo

		If cPaisLoc == "BRA"
			M->N1_DETPATR := SNG->NG_DETPATR
			M->N1_UTIPATR := SNG->NG_UTIPATR
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gatilho do campo N1_PRZDEPR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "PTG" .And. lGrupo .And. SN1->(FieldPos("N1_PRZDEPR")) > 0 .And. SNG->(FieldPos("NG_PRZDEPR")) > 0
			M->N1_PRZDEPR := SNG->NG_PRZDEPR
		EndIf
	
		If lCcdp
			nPos  := Ascan(aHeader,{|e| Alltrim(e[2]) == "N3_CCDESP" })
			If nPos > 0
				aCols[1][nPos] := SNG->NG_CCUSTO
			Endif
		Endif
	
		If lSCdp
			nPos  := Ascan(aHeader,{|e| Alltrim(e[2]) == "N3_SUBCDEP" })
			If nPos > 0
				aCols[1][nPos] := SNG->NG_SUBCTA
			Endif
		Endif
	
		If lCVDP
			nPos  := Ascan(aHeader,{|e| Alltrim(e[2]) == "N3_CLVLDEP" })
			If nPos > 0
				aCols[1][nPos] := SNG->NG_CLVL
			Endif
		Endif
	
		If SN3->(FieldPos("N3_VMXDEPR")) > 0 .And. SNG->(FieldPos("NG_VMXDEPR")) > 0
			nPos  := Ascan(aHeader,{|e| Alltrim(e[2]) == "N3_VMXDEPR" })
			If nPos > 0
				aCols[1][nPos] := SNG->NG_VMXDEPR
			Endif
		Endif
	Endif
	
	If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
		__oGet:Refresh()
	EndIf
		
EndIf

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010ATIPO  ³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consiste tipo do bem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATIPO( cTipo, nLinha, lLinOk )
Local lRet:= .T.
Local l01 := .F.
Local nx, ny,nw
Local nPosVOrig
Local nAscan
// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas 	:= If(lMultMoed,AtfMoedas(),5)
Local aTipos 		:= {}
// ***********************************************************
// Tipos de ativo que podem possuir multiplas cópias ativas  *
// ***********************************************************
Local aTiposMulti 	:= {"02","03","05","10","11"}
Local aTiposBase   	:= {"01","03","10","13"}
Local aTiposTrans	:= {"01","10"}
Local aTipoUnico	:= {}
Local nPosTipo		:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_TIPO"})
Local nPosTpDepr	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_TPDEPR"})
Local nPosVMxDepr	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_VMXDEPR"})
Local nPosVlSalv1	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_VLSALV1"})
Local nPosViUtil	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PERDEPR"} )
Local nPosPrdMes	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODMES"} )
Local nPosPrdAno	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODANO"} )
Local nPosDtBaixa	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_DTBAIXA"} )
//AVP
Local cIdProcAvp := ''
Local aTipoADT   := {}

//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)
Local cTypes10	:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10	:= {}
Local nTypes10	:= 0
Local cTypes12	:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models

DEFAULT cTipo := &(ReadVar())
DEFAULT nLinha := n
DEFAULT lLinOk := .F.

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := AtfNValMod({1}, ";")
	aTypes10 := Separa(cTypes10, ';', .f.)
	For nTypes10 := 1 to len(aTypes10)
		Aadd(aTiposMulti	, aTypes10[nTypes10])
		Aadd(aTiposBase	, aTypes10[nTypes10])
		Aadd(aTiposTrans	, aTypes10[nTypes10])
	Next nTypes10
	
	cTypes10 += "|" + cTypes10
Endif

//AVP
//Verifica de o AVP esta implantado na base
lAvpAtf := If(FindFunction("AFAvpAtf"),AFAvpAtf(),.f.)

IF cPaisLoc == "COL"
	// Tipos de ativo liberados para uso na localização
	aTipos := {"01","02","03","05","07","10","12","50","51","52","53","54"}
ENDIF

If cPaisLoc == "COS"
	aTipos := {"01","02","03","04","05","06","07","10"}
EndIf


//Expressão removida da validação direta do campo para contemplar os novos tipos incluido no SX5->TABELA G1
//PERTENCE("01\02\03\04\05\06\07")
IF Len(aTipos) == 0
	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5")+"G1"))
	WHILE SX5->(!EOF()) .AND. SX5->X5_TABELA == "G1"
		AADD(aTipos,ALLTRIM(SX5->X5_CHAVE))
		SX5->(DbSkip())
	END
ENDIF

IF M->N1_PATRIM == "T" .AND. aScan(aTiposTrans,{|cTipos| cTipos == cTipo}) == 0 .And. !aCols[nLinha][Len(aHeader)+1]
	Help( " ", 1, "AF010NOTIPO",, STR0002 + STR0059, 1, 0 ) // "Não é permitido usar o tipo nesta operação!"
	lRet := .F.
EndIf

IF lRet .AND. aScan(aTipos,{|cTipos| cTipos == cTipo}) == 0 .And. !aCols[nLinha][Len(aHeader)+1]
	Help( " ", 1, "AF010NOTIPO",, STR0002, 1, 0 ) // "Não é permitido usar o tipo nesta operação!"
	lRet := .F.
ENDIF

If !lLinOk .And. len(aCols) <= nOriginal .And. !aCols[nLinha][Len(aHeader)+1] // permite altera‡„o somente em linhas novas
	Help( " ", 1, "AF010NOALTERA",, STR0003, 1, 0 ) // "A linha não pode ser alterada!"
	lRet := .F.
Endif

//AVP
If lRet .And. !lLinOk .and. lAvpAtf .and. ( len(aCols) > nOriginal .or. !lCopia) .and. cTipo == "14" .And. !aCols[nLinha][Len(aHeader)+1]
	Help( " ", 1, "AF010NOT14",, STR0052, 1, 0 )	//"Não é permitida a inclusão manual de Tipo 14. Utilize o processo de AVP padrão."
	lRet := .F.
EndIf

//MRG
If lRet .And. !lLinOk .and. lAvpAtf .and. ( len(aCols) > nOriginal .or. !lCopia) .and. cTipo == "15" .And. !aCols[nLinha][Len(aHeader)+1]
	Help( " ", 1, "AF010NOT15",, STR0061, 1, 0 )	//"Não é permitida a inclusão manual de Tipo 15. Utilize o processo de Margem Gerencial padrão."
	lRet := .F.
EndIf

// *********************************************************************
// Valida os tipos de ativo que podem possuir multiplas cópias ativas  *
// *********************************************************************
If lRet .and.  !aCols[nLinha][Len(aHeader)+1]
	For nx:=1 To Len(aCols)
		IF nx != nLinha .And. !aCols[nX][Len(aHeader)+1]
			If aCols[nx][nPosTipo] == cTipo .And. (aScan(aTiposMulti,{|x| aCols[nx][nPosTipo] == x}) == 0)
				l01 := .T.
			Endif
		Endif
	Next nx
	
	IF l01
		If cTipo $ ("01*10" + cTypes10)
			Help( " ", 1, "AF010TIPO",, STR0004, 1, 0 ) //"É permitido a inclusão de apenas 1 aquisição por ativo!"
		Else
			Help( " ", 1, "A010JADIG",, STR0005, 1, 0 ) //"O tipo já foi informado!"
		Endif
		lRet := .F.
	End
Endif

If lRet
	For nx:=1 To Len(aCols)
		If aScan(aTipoUnico,{|x| aCols[nx][nPosTipo] == x}) > 0 .And. Len(aCols) > 1 .And. !aCols[nX][Len(aHeader)+1]
			lRet := .F.
			Help( " ", 1, "A010UNIC",, STR0038, 1, 0 )//"Caso o bem possua esse tipo, ele deve ser o único no cadastro"
			Exit
		Endif
	Next nx
EndIf

// ***************************************************************************************************
// Valida os tipos de bens base, ou seja bens que podem ser cadastrados independentes de outros tipos*
// ***************************************************************************************************
If lRet .AND. aScan(aTiposBase,{|x| cTipo == x}) == 0 .and. !Empty (cTipo)
	l01 := .F.
	For nx:=1 To Len(aCols)
		IF nx != nLinha .And. !aCols[nX][Len(aHeader)+1]
			If aScan(aTiposBase,{|x| aCols[nx][nPosTipo] == x}) != 0
				l01 := .T.
			Endif
		Endif
	Next nx
	IF !l01
		Help( " ",1,"AF010TIPO" )
		lRet := .F.
	EndIf
Endif

If lRet
	// Na reavaliacao ou depreciacao acelerada, copia os itens
	If cTipo $ "02,05,07,08,11" .And. Len(aCols) > 1 .And. !IsInCallStack("ATFA175") .And. !aCols[nLinha][Len(aHeader)+1]
		For ny:=1 To Len(aHeader)
			If cTipo $ "11" .And. Trim(aHeader[ny][2]) = "N3_TPDEPR"
				nAscan := Ascan(aCols,{|e| e[1] == "01"})
				If nAscan > 0 .and. nPosTpDepr > 0
					aCols[nLinha][nPosTpDepr] := aCols[nAscan][nPosTpDepr]
				Endif
				
			ElseIf Trim(aHeader[ny][2]) != "N3_TIPO" .And.;
				Trim(aHeader[ny][2]) != "N3_HISTOR" .and. Empty(aCols[n][ny])
				If !Empty(aCols[nLinha][ny]) .And. ValType(aCols[nLinha][ny]) != "N"  
					aCols[nLinha][nY] := aCols[nLinha-1][ny]
				Else
					// Atribui ao valor original, o saldo remanescente para calculo da depreciacao acelerada
					If cTipo $ "07,08" .And. Trim(aHeader[ny][2]) = "N3_VORIG1"
						
						// *******************************
						// Controle de multiplas moedas  *
						// *******************************
						For nX := 1 To __nQuantas
							nPosVOrig	:= Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG"+AllTrim(Str(nX)) } )
							// Valor original do item de depreciacao acelerada sera o valor original do item 01
							nAscan := Ascan(aCols,{|e| e[1] == "01"})
							If nAscan > 0
								aCols[nLinha][nPosVOrig] := aCols[nAscan][nPosVOrig]
							Endif
						Next nX
					Endif
				End
			End
		Next ny
	Endif
EndIf

IF cPaisLoc == "COL"
	If lRet .And. nPosTipo > 0 .And. cTipo $ "50/51/52/53/54"
		For nX := 1 to Len(aCols)
			If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And. aCols[nX][nPosTipo] $ "50/51/52/53/54"
				HELP("",1,"A010JADIG")
				lRet := .F.
				Exit
			EndIf
		Next nx
	EndIf
ENDIF

If lRet .And. cTipo $ ("10/12" + cTypes10 + cTypes12) .And. !(nPosTpDepr>0 .And. nPosVMxDepr>0 .And. nPosVlSalv1>0 .And. nPosViUtil>0 .And. nPosPrdMes>0 .And. nPosPrdAno>0) .And. !aCols[nLinha][Len(aHeader)+1]
	Help( " ", 1, "AF010NOC10",, STR0026, 1, 0 ) //  "Campos para controle de tipos depreciação não encontrados, por favor execute a ultima versão do atualizador"
	lRet := .F.
EndIf

// Realiza a validação do tipo de ativo 03 ativo
If lRet .and. lLinOk
	aAdd(aTipoADT,{"03","03/13/15" })
	aAdd(aTipoADT,{"13","03/13/15" })
	For nY := 1 to Len(aTipoADT)
		cTpAux := aTipoADT[nY][1] 
		
		l03 := .F. 
		
		For nX := 1 to Len(aCols)
			If !aCols[nX][Len(aHeader)+1] .And. ( aCols[nX][nPosTipo] == cTpAux )
				l03 := .T. 
				Exit 
			EndIf
		Next nx
		
		If l03 
			For nX := 1 to Len(aCols)
				cTpAux := IIF( nX == nLinha , cTipo , aCols[nX][nPosTipo] ) 
				If !aCols[nX][Len(aHeader)+1 ] .And. !( cTpAux $ aTipoADT[nY][2] )
					Help( " ", 1, "AF010TPADT",, STR0079+ " " +aTipoADT[nY][2]+" " + STR0080+ " "  + aTipoADT[nY][1] , 1, 0 ) //apenas os tipos -- " podem ser cadastrados em conjunto com o tipo de ativo "
					lRet := .F.
					Exit
				EndIf
			Next nx
		EndIf
		
		If !lRet
			Exit
		EndIf 		
	Next nY
EndIf

if lRet .and. M->N1_PATRIM = 'E' .and. !cTipo $ "03/13" 
	Help( " ", 1, "AF010NOTIPO",, STR0081, 1, 0 ) //""Só permitidos os tipos 03 ou 13 quando o Bem for classificado como Custo de Emprestimo"
	lRet := .F.
endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010ADLAT Autor ³ TOTVS SA              ³ Data ³10.08.10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os arquivos apos a exclusao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void AF010AtuArq( )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Af010Delet                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ADLAT(cAlias1, lCprova,lMostra,lContab,aCIAP,aRateio)
Local aArea := { Alias(), IndexOrd() }
Local cLoteAtf := LoteCont("ATF"), lPadrao := .F., cPadrao, nTotal := 0
Local nHdlPrv := 0, cArquivo
Local cTipoImob := ""
Local cTipoCorr := ""
Local aRecAtf  := {}

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local aValorMoed
Local aValDepr	:= {}
Local cPadAnt	:= ""
Local lPadAnt

// Verificação da classificação de Ativo se sofre depreciação
Local lAtClDepr := .F.
Local cTypesNM	:= IIF(lIsRussia,"/" + AtfNValMod({1,2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable models

Default aCIAP	:= {}
Default aRateio := {}

lCprova := IIf(lCprova == nil, .F. , lCprova)
lMostra := IIf(lMostra == nil, .F. , lMostra)
lContab := IIf(lContab == nil, .F. , lContab)

If  ExistBlock("AF010DEL")
	ExecBlock("AF010DEL",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Prote‡„o Via TTS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

dbSelectArea(cAlias1)
dbSeek( xFilial(cAlias1)+SN1->N1_CBASE+SN1->N1_ITEM )
While !EOF() .And. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == xFilial(cAlias1)+SN1->N1_CBASE+SN1->N1_ITEM
	
	dbSelectArea(cAlias1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera‡„o de lancamentos Contabeis                          ³
	//³ Devera' ser gerado de acordo com o tipo de ativo cadastra-³
	//³ do.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPadrao := AF010AQPAD(SN3->N3_TIPO,.T.)
		
	lPadrao := VerPadrao(cPadrao)
	
	If lContab
		IF lPadrao
			IF !lCprova
				lCprova := .T.
				nHdlPrv := HeadProva(cLoteAtf,"ATFA010",Substr(cUsername,1,6),@cArquivo)
			EndIf
			nTotal += DetProva(nHdlPrv,cPadrao,"ATFA010",cLoteAtf)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Saldos do Ativo          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAtClDepr := Iif(FindFunction("AtClssVer"), AtClssVer(SN1->N1_PATRIM), SN1->N1_PATRIM $ "NID")
	IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
		cTipoImob := Iif(SN3->N3_TIPO$"02,05","3","1")
		cTipoCorr := "6"
	Elseif SN1->N1_PATRIM $ "CSA"
		cTipoImob := "A"
		cTipoCorr := "O"
	Else
		cTipoImob := "B"
		cTipoCorr := "6"
	End
	
	dbSelectArea( "SN3" )
	// Pela implanta‡„o
	If ! SN3->N3_TIPO $ "07, 08, 09"
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		If lMultMoed
			aValorMoed := AtfMultMoe("SN3","N3_VORIG")
		EndIf
		ATFSaldo(	SN3->N3_CCONTAB,SN1->N1_AQUISIC,cTipoImob, SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3 ,;
		SN3->N3_VORIG4,SN3->N3_VORIG5 ,"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		If lMultMoed
			aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
		EndIf
		ATFSaldo(	SN3->N3_CCONTAB,SN1->N1_AQUISIC,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
	Endif
	// Pelo calculo mensal
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	If lMultMoed
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
	EndIf
	ATFSaldo(	SN3->N3_CCORREC,SN1->N1_AQUISIC,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
	"-",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed )
	
	lAtClDepr := Iif(FindFunction("AtClssVer"), AtClssVer(SN1->N1_PATRIM), SN1->N1_PATRIM $ "NID")
	IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
		// Pelo calculo mensal
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for conta de Capital social, nÆo lan‡a contra-partida da corre‡Æo monet ria. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		If lMultMoed
			aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
		EndIf
		cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,14,50,51,52,53,54" + cTypesNM), "4", If(SN3->N3_TIPO $ ("10,12,14,50,51,52,53,54" + cTypesNM),"Y",If(SN3->N3_TIPO=="09","L","K")))
		ATFSaldo(	SN3->N3_CCDEPR ,SN1->N1_AQUISIC,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2,SN3->N3_VRDACM3 ,;
		SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		If lMultMoed
			aValorMoed := AtfMultMoe(,,{|x| if(x=1,SN3->N3_VRCDA1,0) })
		EndIf
		ATFSaldo(	SN3->N3_CDESP  ,SN1->N1_AQUISIC,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed )
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		If lMultMoed
			aValorMoed := AtfMultMoe(,,{|x| if(x=1,SN3->N3_VRCDA1,0) })
		EndIf
		ATFSaldo(	SN3->N3_CCDEPR ,SN1->N1_AQUISIC,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )     
		
	End
	//Acrescentado Por Fernando Radu Muscalu em 08/06/11
	If SN3->(FieldPos("N3_CRIDEPR")) > 0 .And. FindFunction("AFXVerRat") .And. AFXVerRat()
		
		If Alltrim(SN3->N3_CRIDEPR) == "03" .AND. Alltrim(SN3->N3_RATEIO) == "1" .AND. !Empty(SN3->N3_CODRAT)
			
			aValDepr := AtfMultMoe(,,{|x| SN3->&( If( x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
			
			If nHdlPrv == 0
				If lContabiliza .AND. VerPadrao("828") //ESTORNO CALCULO DE DEPRECIACAO: RATEIO DE DESPESAS
					nHdlPrv := 	HeadProva(cLoteAtf,"ATFA010",Substr(cUsername,1,6),@cArquivo)
				Endif
			Endif
			
			ATFRTMOV(	SN3->N3_FILIAL,;
			SN3->N3_CBASE,;
			SN3->N3_ITEM,;
			SN3->N3_TIPO,;
			SN3->N3_SEQ,;
			SN4->N4_DATA,;
			SN4->N4_IDMOV,;
			aValDepr,;
			lContabiliza,;
			"2",;
			nHdlPrv,;
			cLoteATF,;
			@nTotal )
			
			If nTotal > 0
				lCprova := .T.
			Endif
			
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Registro Movimenta‡„o      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN4")
	dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO)
	cChave := xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO
	While !Eof() .And. SN4->N4_FILIAL+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO == cChave
	
		If SN4->N4_OCORR == "09"
	        nRecno := SN4->(Recno())
			Af251DelSn4(xFilial("SN4")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+DtoS(SN4->N4_DATA), SN4->N4_CODBAIX,, { "09", "" },.T.)
        	DbGoTo(nRecno)
   		Else
			Reclock("SN4",.F.,.T.)
			dbDelete()
			FkCommit()
   		EndIf
		
		//grava em array os recnos utilizados para integracao com PCO
		Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao		
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Descricoes Analiticas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN2")
	dbSeek( xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO )
	cChave := xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO
	While !Eof() .and. SN2->N2_FILIAL+SN2->N2_CBASE+SN2->N2_ITEM+SN2->N2_TIPO == cChave
		Reclock("SN2" ,.F.,.T.)
		dbDelete()
		FkCommit()
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui apontamento de estimativa inicial de produção	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc $ "ARG|BRA|COS"
		If AliasInDic("FNA")
			dbSelectArea("FNA")
			dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
			dbGoTop()
			If FNA->(MsSeek(xFilial("FNA")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)))
				While FNA->(!EoF()) .And.;
					FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)
					RecLock("FNA",.F.)
					
					//Salva o LP anterior
					cPadAnt := cPadrao
					lPadAnt := lPadrao
					
					Do Case
						Case FNA->FNA_OCORR == "P0"
							cPadrao := "875"		//Estorno de apontamento de estimativa de produção
						Case FNA->FNA_OCORR == "P1"
							cPadrao := "876"		//Estorno de apontamento de revisão de estimativa de produção
						Case FNA->FNA_OCORR == "P2"
							cPadrao := "877"		//Estorno de apontamento de produção
						Case FNA->FNA_OCORR == "P3"
							cPadrao := "878"		//Estorno de apontamento de encerramento de produção
						Case FNA->FNA_OCORR == "P4"
							cPadrao := "879"		//Estorno de apontamento de complemento de produção
					EndCase
					
					lPadrao := VerPadrao(cPadrao)
					
					If ValType(nHdlPrv) != "N" .Or. nHdlPrv <= 0
						nHdlPrv := HeadProva(cLoteAtf,"ATFA010",Substr(cUsername,1,6),@cArquivo)
					EndIf
					
					If lPadrao
						nTotal += DetProva(nHdlPrv,cPadrao,"ATFA010",cLoteAtf)
					EndIf
					
					//Restaura o LP anterior
					cPadrao := cPadAnt
					lPadrao := lPadAnt
					
					dbDelete()
					MsUnlock()
					FNA->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
	If FindFunction("AFXVerRat") .And. AFXVerRat()
		If SN3->N3_RATEIO == "1"
			//alterado por Fernando Radu Muscalu em 01/11/2011
			//Estava gerando duplicidades de rateios no array aRateio
			If aScan(aRateio,{|x| alltrim(x[1]) == alltrim(SN3->N3_CODRAT) }) == 0
				aAdd(aRateio,{SN3->N3_CODRAT})
			Endif
		Endif
	EndIf
	//AVP
	//Verifica se o bem possui AVP constituido
	//Neste caso, o bem podera ser excluido
	If lAvpAtf .and. SN3->N3_TIPO == '14'
		FNF->(DbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If FNF->(DbSeek(XFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)+'1'))

			While !(FNF->(EOF())) .AND. FNF->(FNF_FILIAL+FNF_CBASE+FNF_ITEM) == ;
				XFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)

				If FNF->FNF_TPMOV == '1' //Exclusao de Constituicao
					RecLock("FNF",.F.)
					//Movimento de constituicao ativo e contabilizado
					If FNF->FNF_STATUS == '1' .and. !Empty(FNF->FNF_DTCONT)

						//Salva o LP anterior
						cPadAnt := cPadrao
						lPadAnt := lPadrao

						cPadrao	:= "867" //Estorno de constituição de AVP
						lPadrao 	:= VerPadrao(cPadrao)

						If ValType(nHdlPrv) != "N" .Or. nHdlPrv <= 0
							nHdlPrv := HeadProva(cLoteAtf,"ATFA010",Substr(cUsername,1,6),@cArquivo)
							lCprova := .T.
							lHeader := .T.
						EndIf

						If lPadrao
							nTotal += DetProva(nHdlPrv,cPadrao,"ATFA010",cLoteAtf)
						EndIf

						//Restaura o LP anterior
						cPadrao := cPadAnt
						lPadrao := lPadAnt

					Endif

					cBaseAVP    := FNF->FNF_CBASE
					cItemAVP    := FNF->FNF_ITEM
					cTpSLDAVP   := FNF->FNF_TPSALD

					//Excluo o registro
					FNF->(dbDelete())
					FNF->(MsUnlock())

					AFGrvPrjAvp(cBaseAVP,cItemAVP,'10',cTpSLDAVP)

				ElseIf FNF->FNF_TPMOV $ '9|A' //Exclusao de Ajuste de AVP por Revisão
					RecLock("FNF",.F.)
					FNF->(DbDelete())
					FNF->(MsUnlock())
				EndIf

			FNF->(DbSkip())
			EndDo
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Ativos Imobilizados        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SN3" )
	RecLock( "SN3" ,.F.,.T.)
	dbDelete()
	FkCommit()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a amarracao com os conhecimentos SN3 - LAUDO          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsDocument( Alias(), RecNo(), 2, , 3 )
	
	//grava em array os recnos utilizados para integracao com PCO
	Pco_aRecno(aRecAtf, "SN3", 3)  //inclusao
	
	dbSeek( xFilial("SN1")+SN1->N1_CBASE+SN1->N1_ITEM )
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Rateio			          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc $ "ARG|BRA|COS" .AND. FindFunction("AF011DEL") .and. len(aRateio) > 0
	If !AF011DEL(aRateio,.T.)//AF011GRAVA(5, aRateio) //mudar para a chamada da funcao - AF011DEL(aRateio,.t.)
		Help(" ",1,"AF010AEEXR",,STR0062,1,0) //"Erro ao excluir rateio"
	EndIf
	
	aRateio := {}
Endif
IF lCProva .And. lContab .And. nTotal > 0
	RodaProva(nHdlPrv,nTotal)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lancamento Contabil                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lMostra,.F.)
End

//	IF nCnt != 0
// ****************** CIAP *********************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Cadastro do CIAP                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !Empty(SN1->N1_CODCIAP) )
	dbSelectArea("SF9")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) )
		RecLock("SF9")
		SF9->F9_ICMIMOB -= SN1->N1_ICMSAPR
	EndIf
EndIf
AADD(aCIAP,{SN1->N1_CODCIAP})
// ****************** CIAP *********************

//AVP2
//Excluo os bens de provisao relacionados ao bem de orcamento com AVP parcela
dbSelectArea( "SN1" )
If Type("lAvpAtf2")=="L" .and. lAvpAtf2 .and. SN1->N1_TPAVP == '2' .AND. SN1->N1_PATRIM = 'O'
	AF010CANPrv(SN1->N1_CBASE,SN1->N1_ITEM)
Endif

dbSelectArea( "SN1" )
RecLock( "SN1", .F., .T.)
dbDelete( )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui a amarracao com os conhecimentos SN1                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsDocument( Alias(), RecNo(), 2, , 3 )

//grava em array os recnos utilizados para integracao com PCO
Pco_aRecno(aRecAtf, "SN1", 3)  //exclusao

//	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Final  da Prote‡„o Via TTS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
End Transaction

//integracao com modulo de planejamento e controle orcamentario
If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	Atf_IntPco(aRecAtf)
EndIf

dbSelectArea( aArea[1] )
dbSetOrder( aArea[2] )
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010AVLDL³ Autor ³ Alice Y Yamamoto      ³ Data ³26.01.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Ativo pode ser excluido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void AF010Delet() / Mata100 -> Intergracao com compras       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Af010Delet ()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AVLDL(cAlias1, lCompra,lHelp)
Local aArea := { Alias(), IndexOrd() }
Local lREt := .T.
Local nCont := 0
Local nBaixado := 0
Local nSavRecSN3
Local lOk := .F.
Local aAreaSN4 := SN4->(GetArea())
Local lTemDeprec :=  .F.
//Data de Bloqueio da Movimentação - MV_ATFBLQM
Local dDataBloq := GetNewPar("MV_ATFBLQM",CTOD(""))
Default lHelp := .T.

If ExistBlock("F010VldDel")
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este PE sera executado em substituicao a rotina de validacao³
	//³da exclusao do ativo. Devera retornar .T. para prosseguir a ³
	//³exclusao, ou .F. caso contrario.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	lRet := ExecBlock("F010VldDel",.F.,.F.,{cAlias1, lCompra})
	
Else
	If FindFunction("NGINTIMOBIL")
		lRet := NGINTIMOBIL(SN1->N1_CBASE,SN1->N1_ITEM,.T.) // INTEGRACAO NG - VERIFICA SE EXISTE O REGISTRO NAS TABELAS DA NG
	Endif
	If lRet
		lCompra := IIf(lCompra = Nil,.F.,lCompra)
		dbSelectArea(cAlias1)
		dbSetOrder( 1 )
		
		If dbSeek(xFilial("SN1")+SN1->N1_CBASE+SN1->N1_ITEM)
			nSavRecSN3 := Recno()
			// Se houver depreciacao acumulada ou
			// o bem estiver baixado, nao permite a exclusao.
			lTemDeprec := !Empty( SN1->N1_BAIXA) .Or. IIf(SN3->N3_VRDACM1 != 0,ATFVDEPRAC(SN3->N3_CBASE, SN3->N3_ITEM),.F.)
			If lTemDeprec .And. !IsInCallStack("AF060CaTra")
				If (lHelp,Help(" ",1, "AF010DEL"),)
				lRet := .F.
			EndIf
			If !Empty(dDataBloq) .AND. (SN1->N1_AQUISIC <= dDataBloq)
				If (lHelp,Help(" ",1,"AF010ABLQM",,STR0019 + DTOC(dDataBloq) ,1,0),) //"A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
				lRet := .F.
			EndIf
			If lRet
				While !Eof() .And. XFILIAL("SN3")+SN3->N3_CBASE+SN3->N3_ITEM == XFILIAL("SN1")+SN1->N1_CBASE+SN1->N1_ITEM
					IF Val( SN3->N3_BAIXA ) # 0
						nBaixado++
					EndIf
					nCont++
					SN3->(dbSkip( ))
				EndDo
				SN3->(dbGoto(nSavRecSN3))
				If nCont == 0
					If (lHelp,HELP(" ",1,"AF010NITEM"),)
					lRet := .F.
				EndIf
				If lRet
					If lCompra .And. !Empty(SN3->N3_CCONTAB)
						If (lHelp,Help("  ",1,"AF240CLASS"),)
						lRet := .F.
						lOk  := .T.
					EndIf
					dbSelectArea(cAlias1)
					dbSetOrder(1)
					dbGoto(nSavRecSn3)
				EndIf
			EndIf
		EndIf
		If lRet .Or. lOk
			dbSelectArea( aArea[1] )
			dbSetOrder( aArea[2] )
		EndIf
	EndIf
EndIf
//Não Excluir Bem Efetivado pela Rotina ATFA310 se o campo N1_ORIGEM igual "ATFA310" e N1_STATUS = '0' e Rotina que chamou se for diferente de "A310GRVATF"
If lRet .And. SN1->(FieldPos("N1_STATUS")) > 0 .And.  SN1->N1_STATUS = '0'
	If Alltrim(SN1->N1_ORIGEM) == 'ATFA310' 
	    If !IsInCallStack("A310GRVATF") 
			If (lHelp, Help(" ",1,"AF010EPA",,STR0029,1,0),)	//'Bem planejado somente poderá ser excluido através do estorno da efetivação na rotina de planejamento de ativo (ATFA310)'
			lRet := .F.
		Endif
	EndIf
EndIf
RestArea(aAreaSN4)
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010AGRP ³ Autor ³ TOTVS SA              ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche entidades contabeis no bem de acordo com grupo [SNG]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AGRP(cEntidade)

Local cRetorno := ""
Local lErr	:= .F.
Local lSemIndice
Local nOrdem
Local lAtfa240 := Alltrim(FunName()) == "ATFA240"



If Type("M->N1_GRUPO") <> "U"
	lSemIndice := Upper( SubStr(SN3->(IndexKey()),1,26) ) <> "N3_FILIAL+N3_CBASE+N3_ITEM"
	If lSemIndice
		nOrdem := SN3->( IndexOrd() )
		SN3->( DbSetOrder(1) )
	EndIf
	If lAtfa240
		// Na rotina de classificacao, pesquisa o SN3 pelos dados do SN1, pois se o codigo foi alterado em tela,
		// este ainda nao foi gravado na tabela SN3 e consequentemente o registro nao eh encontrado
		SN3->(MsSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)))
	Else
		SN3->(MsSeek(xFilial("SN3")+M->(N1_CBASE+N1_ITEM)))
	Endif
	If ! Empty(M->N1_GRUPO)
		If SNG->NG_GRUPO <> M->N1_GRUPO
			SNG->(DbSeek(xFilial("SNG") + M->N1_GRUPO))
		Endif
		If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) > 0
			If Empty(&("SN3->N3_" + Subs(cEntidade, 4))) .OR. lCopia
				cRetorno := &("SNG->NG_" + Subs(cEntidade, 4))
			Else
				cRetorno := &("SN3->N3_" + Subs(cEntidade, 4))
			Endif
		Else
			lErr := .T.
		Endif
	else
		If cEntidade <> nil .and. TamSX3(cEntidade)[3] == "N"
			cRetorno := 0
		EndIf
	Endif
	If lSemIndice
		SN3->( DbSetOrder(nOrdem) )
	EndIf
Else
	If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) <> 0
		cRetorno := &("SN3->" + cEntidade)
	Else
		lErr := .T.
	Endif
Endif

// Alterado, caso nao exista o campo, o gatilho irá retornar em branco 

Return cRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010AAT32 ³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche Taxa deprecia‡„o para todas das moedas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Af010Art32                                                   ³±±
±±³          ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AAT32()
Local aPosTaxa	:= {}
Local nX
Local lRet := .T.

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

// *******************************
// Controle de multiplas moedas  *
// *******************************
aPosTaxa := If(lMultMoed,AtfMultPos(aHeader,"N3_TXDEPR"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TXDEPR5" } ) })


// *******************************
// Controle de multiplas moedas  *
// *******************************
If Alltrim(M->N1_ART32) == "S"
	For nX := 1 to __nQuantas
		aCols[n][aPosTaxa[nX]] := (100 / (13 - Month(M->N1_AQUISIC) ) ) * 12
	Next
EndIf

If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
	__oGet:Refresh()
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF010ACHAP³ Autor ³ TOTVS                 ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a chapa informada ja existe e se pode repetila ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ af010Chapa(cChapa, lRepChapa)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Criacao Automatica de bens.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION AF010ACHAP(cChapa,lRepChapa)

Local aArea 		:= GetArea()
Local aAreaSN1  	:= SN1->(GetArea())
Local lRet			:= .T.
Local cRotina		:= Alltrim(FunName())

Default cChapa 		:= M->N1_CHAPA
Default lRepChapa 	:= Nil

If lRepChapa == Nil
	IF cRotina == "ATFA010" .or. cRotina == "ATFA040" .or. cRotina == "ATFA040"
		lRepChapa := MV_PAR02 == 1
	ElseIF cRotina == "ATFA250" .or. cRotina == "ATFA251"
		lRepChapa := MV_PAR03 == 1
	Else 
		lRepChapa := MV_PAR02 == 1
	EndIf
EndIf
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000120962 - CENTRALIZACAO DA VALIDACAO DA CHAPA E P.E.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("AF010CHP")
	
	lRet := ExecBlock("AF010CHP",.F.,.F.,{cChapa,lRepChapa})
	lRet := IIF(ValType(lRet) == "L",lRet,.F.)
	
ELSE
	
	IF !lRepChapa
		IF Empty(cChapa)
			HELP( " ",1,"AFA010JAEX" )	// Criar Help (Este campo nao pode ficar em branco)
			lRet := .F.
		ELSE
			dbSelectArea("SN1")
			dbSetOrder(2)
			IF dbSeek(xFilial("SN1")+cChapa)
				HELP( " ",1,"AFA010CHAP" )		/// Criar Help (Esta chapa ja existe.)
				lRet := .F.
			ENDIF
		ENDIF
	ENDIF
	
ENDIF

RestArea(aAreaSN1)
RestArea(aArea)
RETURN lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ATFVDEPRAC³ Autor ³ Rodrigo Gimenes ³      Data ³19.10.2010³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que verifica se o N4_IDMOV da depreciação é o mesmo  ±±
±± que o da inclusão, ou se houve depreciação após a inclusão.             ++
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Código do bem e C´ódigo do Item                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFVDEPRAC(cCodigoBem,cCdgItem,cTipo,cTipoSld,cOcorAquis)
Local lRetorno := .T.
Local aSaveArea:= GetArea()
Local aAreaSn4 := SN4->(GetArea())
Local lIdMovCpo := SN4->(FieldPos("N4_IDMOV")) > 0
Local bWhile	:= {|| }
Local cIdAquisic:= ""

Default cTipo    := ""
Default cTipoSld := ""
Default cOcorAquis := "05" // 05- Aquisicao ou 16 - Aquisicao por transf 

dbSelectArea("SN4")
SN4->(dbSetOrder(4)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)

If lIdMovCpo
	If Empty(cTipo)
		SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem ))
		While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM))
			If SN4->N4_OCORR == cOcorAquis
				cIdAquisic := AllTrim(SN4->N4_IDMOV)
				Exit
			EndIf
			SN4->(dbSkip())
		EndDo
	Else
		SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo + cOcorAquis ))
		If Empty(cTipoSld) .Or. SN4->(FieldPos("N4_TPSALDO")) <= 0
			cIdAquisic := AllTrim(SN4->N4_IDMOV)
		Else
			While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo + cOcorAquis) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO + N4_OCORR ))
				If  Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)
					cIdAquisic := AllTrim(SN4->N4_IDMOV)
				EndIf
				SN4->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If !Empty(cIdAquisic)
		If Empty(cTipo)
			bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM)) }
		Else
			bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo ) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO )) }
		EndIf
		
		SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR
		SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo ,.T.))
		lRetorno := .F.
		While Eval(bWhile)
			If AllTrim(cIdAquisic) != AllTrim(SN4->N4_IDMOV)
				lRetorno := .T.
				Exit
			EndIf
			SN4->( DBSkip() )
		EndDo
	EndIf
EndIf



RestArea(aAreaSn4)
RestArea(aSaveArea)


Return(lRetorno)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AtfVldCpoCfg³ Autor ³ Claudio Donizete Souza³ Data ³ 29.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o campo eh obrigatorio, conforme configuracao do   ³±±
±±³          ³ grupo de campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfGrvCfg(cGrupo, cBase)
Local lAtualiza := .T.

If AliasInDic("SNK").And. SNK->(MsSeek(xFilial("SNK")+cGrupo))
	If "EXECBLOCK" $ Upper(SNK->NK_CBASE) .Or. "U_" $ Upper(SNK->NK_CBASE)
		lAtualiza := .F.
	Endif
	While SNK->NK_FILIAL == xFilial("SNK") .And.;
		SNK->NK_GRUPO == cGrupo
		RecLock("SNK",.F.)
		SNK->NK_UCBASE := cBase
		If lAtualiza
			SNK->NK_CBASE := '"'+Soma1(Alltrim(cBase))+'"'
		Endif
		MsUnlock()
		SNK->(DbSkip())
	End
Endif

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfGatilho  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 25/07/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gatilho de campos do Config. de Grupos de Campos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDom, cContraDom                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfGatilho(cDom, cContraDom)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ ATFA275 										   							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AtfGatilho(cDom, cContraDom)
Local cRet := ""
Local nLencBase := Len(SN1->N1_CBASE)
Local aAreaSn1 := SN1->(GetArea())

If cDom # "N1_GRUPO"
	SX3->(DbSetOrder(2))
	SX3->(MsSeek(M->&cDom))
Endif

If cContraDom == "NK_TITULO"
	cRet := X3TITULO()
ElseIf cContraDom == "NK_DESCRIC"
	cRet :=	X3Descric()
ElseIf cDom == "N1_GRUPO"
	If Empty(M->N1_CBASE)
		If SNK->(MsSeek(xFilial("SNK") + M->&cDom))
			//cRet := &(SNK->NK_CBASE)
			If !Empty(SNK->NK_CBASE)
				cRet := &(SNK->NK_CBASE)
				cRet := SubStr(cRet,1,TamSX3("N1_CBASE")[1])
				SN1->(DbSetOrder(1))
				While SN1->(MsSeek(xFilial("SN1")+cRet))
					cRet := Soma1(cRet,nLencBase)
				EndDo
				SN1->(RestArea(aAreaSn1))
			EndIf
		Endif
	Else
		cRet := M->N1_CBASE
	EndIf
Endif

Return cRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtfIniPad   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 25/07/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicializador padrao de campos do Config. de Grupos de Campos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfIniPad(cCampo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ ATFA275 										   							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AtfIniPad(cCampo)
Local cRet
Local lVazio := .F.

If Type("aCols") == "A" .And. Type("n") == "N" .And. !Empty(aCols)
	If n+1 > Len(aCols)
		n := 0
	Endif
	lVazio := Empty(GdFieldGet("NK_CAMPO",n+1))
Endif
Do Case
	Case cCampo == "NK_DGRUPO"
		cRet := If(!INCLUI .And. !lVazio,Posicione("SNG",1,xFilial("SNG")+SNK->NK_GRUPO,"NG_DESCRIC"),"")
	Case cCampo == "NK_TITULO"
		cRet := If(!INCLUI .And. !lVazio,Posicione("SX3",2,SNK->NK_CAMPO,"X3TITULO()"),"")
	Case cCampo == "NK_DESCRIC"
		cRet := If(!INCLUI .And. !lVazio,Posicione("SX3",2,SNK->NK_CAMPO,"X3Descric()"),"")
EndCase

Return cRet





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010AVLGRºAutor  ³Marcelo Akama       º Data ³  04/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação dos campos dos metodos de depreciacao gerencial   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AVlGr(cField)
Local lRet 			:= .F.
Local nPosTpDepr 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TPDEPR" } )
Local nPosVlSalv1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VLSALV1"} )
Local nPosPerDepr	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PERDEPR"} )
Local nPosProdMes	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODMES"} )
Local nPosProdAno	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODANO"} )
Local nPosVMxDepr	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VMXDEPR"} )
Local nPosCodInd    := aScan(aHeader, {|x| AllTrim(x[2]) == "N3_CODIND"} )
Local lAtfctap		:= IIF(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)

DEFAULT cField := ReadVar()

If At("->",cField)>0
	cField := SubStr(cField,At("->",cField)+2,len(cField))
EndIf

If nPosTpDepr>0 .And. !Empty(&(ReadVar()))
	Do Case
		Case aCols[n][nPosTpDepr]=='2'
			lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
		Case aCols[n][nPosTpDepr]=='3'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='4'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='5'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='6'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='7'
			lRet := cField $ "N3_VMXDEPR"
		Case aCols[n][nPosTpDepr]=='8'
			lRet := cField $ "N3_PRODANO"
		Case aCols[n][nPosTpDepr]=='9'
			lRet := cField $ "N3_PRODANO"
		Otherwise // =='1'
			lRet := .F.
	EndCase
	If !lRet .And. !IsBlind()
		Help( " ", 1, "AF010FDNTUS",, STR0025, 1, 0 ) // "Esse campo não é utilizado pelo método de depreciação selecionado, o valor informado não será considerado."
	EndIf
EndIf

/*
1-Linea	2-RedSl	3-SAnos	4-UnPrd	5-HrPrd	6-SDigi	7-LVlMx	8-ExLin	9-ExSld
N3_PERDEPR			   X	   X					   X
N3_VLSALV1			   X
N3_PRODMES							   X	   X
N3_PRODANO							   X	   X						X		X
N3_VMXDEPR													   X
*/
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010VlMaxºAutor  ³Microsiga           º Data ³  02/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do valor máximo da depreciação                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010VlMax(nVlMaxDepr)
Local lRet := .T.
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," "))>0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Local cCpoOrig   := "N3_VORIG"+cValToChar(nMoedaVMax)
Local nPosVMOrig := Ascan(aHeader, {|x| Alltrim(x[2]) == Alltrim(cCpoOrig) } )

Default nVlMaxDepr := M->N3_VMXDEPR

If nVlMaxDepr > aCols[n][nPosVMOrig]
	Help( " ", 1, "AF010VMXDEPR",,STR0027, 1, 0 ) // "Valor Máximo de Deprecição não pode ser maior que o valor original na moeda configurada no parametro MV_ATFMDMX "
	lRet := .F.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010AFNG ºAutor  ³Microsiga           º Data ³  04/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao para campo N1_GRUPO captura dados da FNG 		  º±±
±±º          ³ e preenche aCols		                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AFNG()
Local aArea := GetArea()
Local aArea2:= {}
Local lCont	:= .T.
Local nLin	:= 0
Local lRet	:= .T.
Local lAtfCusPrv := If (FindFunction('AFXAtCsPrv'),AFXAtCsPrv(),.F.)


If !IsBlind() .and. (IsInCallStack("ATFA010") .Or. IsInCallStack("ATFA240"))
	If AliasInDic("FNG") .and. INCLUI .And. Type("__oGet") == "O"
		nLin := __oGet:obrowse:nAt
		aArea2:=FNG->(GetArea())
		FNG->(DbSetOrder(1))
		If FNG->(DbSeek(xFilial("FNG")+M->N1_GRUPO))
			
			If !Empty(aCols[1,GdFieldPos("N3_TIPO")]) .And. !Empty(__cGrupoFNG)
				If __cGrupoFNG != M->N1_GRUPO
					If !IsBlind() .AND. MsgYesNo(STR0047) //"Essa alteração implicará na perda dos dados digitados, deseja continuar?"
						aCols := {}
						__oGet:AddLine(.T.)
						nLin := __oGet:obrowse:nAt
					Else
						lCont  := .F.
						lRet   := .F.
					EndIf
				Else
					lCont:= .F.
					lRet   := .T.
				EndIf
			Else
				__cGrupoFNG := M->N1_GRUPO
			EndIf
			
			If lCont
				
				//Posiciona a SNG para obter o valor maximo de depreciacao
				SNG->(dbSetOrder(1))
				SNG->(MsSeek(xFilial("SNG")+M->N1_GRUPO))
				
				While FNG->(!EOF()) .and. M->N1_GRUPO == FNG->FNG_GRUPO .AND. FNG->FNG_FILIAL == xFilial("FNG")
					aCols[nLin,GdFieldPos("N3_TIPO")]		:= FNG->FNG_TIPO
					aCols[nLin,GdFieldPos("N3_HISTOR")]		:= FNG->FNG_HISTOR
					aCols[nLin,GdFieldPos("N3_TPSALDO")]	:= IiF(!Empty(FNG->FNG_TPSALD)	,FNG->FNG_TPSALD,aCols[nLin,GdFieldPos("N3_TPSALDO")])
					aCols[nLin,GdFieldPos("N3_TPDEPR")]		:= IiF(!Empty(FNG->FNG_TPDEPR)	,FNG->FNG_TPDEPR,aCols[nLin,GdFieldPos("N3_TPDEPR")])
					aCols[nLin,GdFieldPos("N3_TXDEPR1")]	:= IiF(FNG->FNG_TXDEP1 != 0 	,FNG->FNG_TXDEP1,aCols[nLin,GdFieldPos("N3_TXDEPR1")])
					aCols[nLin,GdFieldPos("N3_TXDEPR2")]	:= IiF(FNG->FNG_TXDEP2 != 0 	,FNG->FNG_TXDEP2,aCols[nLin,GdFieldPos("N3_TXDEPR2")])
					aCols[nLin,GdFieldPos("N3_TXDEPR3")]	:= IiF(FNG->FNG_TXDEP3 != 0 	,FNG->FNG_TXDEP3,aCols[nLin,GdFieldPos("N3_TXDEPR3")])
					aCols[nLin,GdFieldPos("N3_TXDEPR4")]	:= IiF(FNG->FNG_TXDEP4 != 0 	,FNG->FNG_TXDEP4,aCols[nLin,GdFieldPos("N3_TXDEPR4")])
					aCols[nLin,GdFieldPos("N3_TXDEPR5")]	:= IiF(FNG->FNG_TXDEP5 != 0 	,FNG->FNG_TXDEP5,aCols[nLin,GdFieldPos("N3_TXDEPR5")])

					If cPaisLoc == "ARG"
					   aCols[nLin,GdFieldPos("N3_CRIDEPR")]	:= FNG->FNG_CRIDEP//IiF(!Empty(FNG->FNG_TIPDEP) ,FNG->FNG_TIPDEP,aCols[nLin,GdFieldPos("N3_TIPDEPR")])
					   aCols[nLin,GdFieldPos("N3_CALDEPR")]	:= FNG->FNG_CALDEP//IiF(!Empty(FNG->FNG_CALDEP) ,FNG->FNG_CALDEP,aCols[nLin,GdFieldPos("N3_CALDEPR")])
					EndIf

					//Ativos Custo/provisao
					If lAtfCusPrv
						aCols[nLin,GdFieldPos("N3_ATFCPR")]	:= FNG->FNG_ATFCPR
					Endif					

					aCols[nLin,GdFieldPos("N3_VMXDEPR")]	:= IiF(FNG->FNG_TPDEPR == '7' 	,SNG->NG_VMXDEPR,0)
					FNG->(DbSkip())
					If FNG->(!EOF()) .and. M->N1_GRUPO == FNG->FNG_GRUPO .AND. FNG->FNG_FILIAL == xFilial("FNG")
						__oGet:AddLine(.T.)
						nLin := __oGet:obrowse:nAt
					EndIf
					
				EndDo
				__cGrupoFNG := M->N1_GRUPO
			EndIf
		EndIf
		FNG->(RestArea(aArea2))
	EndIf
	RestArea(aArea)
	If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
		//Posiciona na primeira linha
		__oGet:GoTo(1)
		__oGet:Refresh()
	EndIf
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af010CotaDepr³ Rev.  ³Fernando Radu Muscalu  ³ Data ³08.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executa os calculos de depreciacao de acordo com os     ³±±
±±³			 ³metodos e o criterio de Exercicio Completo ("03")	para         ³±±
±±³			 ³acumular os valores e retorna-los aos campos relacionados.  	 ³±±
±±³			 ³Ex: N3_VRDACM1										      	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Af010CotaDepr(aTaxaRef,aCotaM,aParam,aValores,dInDepr,	     ³±±
±±³			 ³				nMoedaVMax)	 								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aTaxaRef	- Array: Taxa de depreciacao mensal por moeda   	 ³±±
±±³          ³aCotaM	- Array: Valor da Cota depreciada por moeda		   	 ³±±
±±³          ³aParam	- Array: Parametros referente aos campos do SN3   	 ³±±
±±³          ³	aParam[1] - Numeric: Valor Original na Moeda 1			   	 ³±±
±±³          ³	aParam[2] - Numeric: Valor Depreciacao Acumulada na Moeda 1	 ³±±
±±³          ³	aParam[3] - Char: Metodo de Depreciacao						 ³±±
±±³          ³				"1" - Linear									 ³±±
±±³          ³				"2" - Reducao de Saldos							 ³±±
±±³          ³				"3" -                							 ³±±
±±³          ³				"4" - Unidades Produzidas   					 ³±±
±±³          ³				"5" - Horas trabalhadas       					 ³±±
±±³          ³				"6" - Soma dos Digitos       					 ³±±
±±³          ³				"7" - Linear com Valor Maximo de Depreciacao     ³±±
±±³          ³				"8" - Exaustao Linear						     ³±±
±±³          ³				"9" - Exaustao Valor Residual				     ³±±
±±³          ³	aParam[4] - Numeric: Valor Maximo de Depreciacao			 ³±±
±±³          ³	aParam[5] - Numeric: Periodo de Depreciacao      			 ³±±
±±³          ³	aParam[6] - Numeric: Valor de Salvamento	      			 ³±±
±±³          ³	aParam[7] - Numeric: Producao Mensal		      			 ³±±
±±³          ³	aParam[8] - Numeric: Producao Prevista		      			 ³±±
±±³          ³	aParam[9] - N3_FIMDEPR						      			 ³±±
±±³          ³aValores	- Array: Valores Originais por moedas			   	 ³±±
±±³          ³dInDepr	- Data: Inicio de Depreciacao					   	 ³±±
±±³          ³nMoedaVMax- Numeric: Moeda para o Valor Maximo de Depreciacao	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil	    								    				 ³±±
±±³		     ³Por Referencia: aCotaM					    				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³AF010VLAEC()			    									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af010CotaDepr(aTaxaRef,aCotaM,aParam,aValores,dInDepr,nMoedaVMax,lResid,nLinha)

Local aVlrOrig		:= aClone(aValores[1])
Local aVlrAcum		:= aClone(aValores[2])
Local aVlrAmpl		:= aClone(aValores[3])
Local aVlrCAcm		:= aClone(aValores[4])
Local aVlrCda		:= aClone(aValores[5])

Local cMoedaAtf 	:= GetMV("MV_ATFMOED")
Local cTCalcAF		:= GetMV("MV_TCALCAF",.F.,"0")`

Local nDiferenca	:= 0				// Auxiliar na verificacao de saldo residual.
Local nCusto		:= 0				// Auxiliar Custo de Aquisição
Local nDecimal		:= 0				// Auxiliar número de decimais
Local nI			:= 0				// Auxiliar Contador
Local nMFiscal		:= 0
Local nDecTax		:= 0
Local nPropBase		:= 0
Local nVlrOriSal	:= 0

Local lVlrMxDp		:= .F.
Local lVlrSalv		:= .F.

//Local aCotaDepr	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} ) // Array com as posicoes relativas as cotas de depreciacao nas moedas.

//Default aCotaM 		:= AtfMultMoe(,,{|x| 0})
Default nMoedaVMax  := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Default aParam		:= {}
Default lResid		:= .f.


//³Mapeamento do conteudo de aParam					  ³
//³aParam[1] - N3_VORIG1							  ³
//³aParam[2] - N3_VRDACM1							  ³
//³aParam[3] - N3_TPDEPR							  ³
//³aParam[4] - N3_VMXDEPR							  ³
//³aParam[5] - N3_PERDEPR							  ³
//³aParam[6] - N3_VLSALV1							  ³
//³aParam[7] - N3_PRODMES							  ³
//³aParam[8] - N3_PRODANO							  ³
//³aParam[9] - N3_FIMDEPR							  ³

/*

N3_VRCDA1	- Corr Depr Acumulada
N3_VRCACM1  - Correcao Acumulada Moeda1

*/

nMFiscal := if(SN3->(FieldPos("N3_VLACTXP"))> 0 .And. SN3->(FieldPos("N3_TPDEPR"))> 0, Val(cMoedaAtf), 0) // O vlr zero exclui a condicao da moeda fiscal

lVlrSalv := SN3->(FieldPos("N3_VLSALV1")) > 0 .And. SN3->(FieldPos("N3_TPDEPR")) > 0 .And. aParam[3] == "2" //SN3->N3_TPDEPR == '2'

/*Verificacao do tratamento de valor maximo de depreciacao*/
lVlrMxDp := SN3->(FieldPos("N3_VMXDEPR"))> 0 .AND. nMoedaVMax > 0 .AND. aParam[4] > 0//SN3->N3_VMXDEPR > 0

/*Define regra de proporcionalizacao para outras moedas*/
If lVlrMxDp
	nPropBase 	:= aParam[4] / aVlrOrig[nMoedaVMax,1] + aVlrAmpl[nMoedaVMax]	//SN3->N3_VMXDEPR /(&("N3_VORIG"  + Str(nMoedaVMax,1)) + &("N3_AMPLI" + Str(nMoedaVMax,1)))
ElseIf lVlrSalv
	nPropBase 	:= aParam[6] / (aVlrOrig[1,1] + aVlrAmpl[1])					//SN3->N3_VLSALV1 / SN3->(N3_VORIG1+N3_AMPLIA1)
Endif

/*Implementation*/
If dInDepr <= dDataBase
	
	For nI := 1 to Len( aCotaM )
		
		nDecimal := aVlrOrig[nI,2]	//X3Decimal( "N3_VORIG" + AllTrim(Str(nI)) )
		
		If aTaxaRef[ nI ] # 0
			
			
			nDecTax		:= aVlrOrig[nI,2]	//TAMSX3("N3_VORIG"  + AllTrim(Str(nI)))[2]
			nDeprAcum	:= aVlrAcum[nI]	+ Af010GetSldAcel( Str(nI,1), nLinha )	//&("N3_VRDACM" + Str(nI,1)) + GetSldAcel( Str(nI,1) )
			nCusto		:= aVlrOrig[nI,1] + aVlrAmpl[nI]					//&("N3_VORIG"  + Str(nI,1)) + &("N3_AMPLIA" + Str(nI,1))
			
			// Tratamento da correção Monetária
			If nI == 1
				nDeprAcum	+= aVlrCda[1]	//N3_VRCDA1	// Round( N3_VRCDA1 / RecMoeda( dDataBase, i ), nDecimal )
				nCusto		+= aVlrCAcm[1]	//N3_VRCACM1	// Round( N3_VRCACM1 / RecMoeda( dDataBase, i ), nDecimal )
			Endif
			
			If  nI == nMoedaVMax .And. lVlrMxDp
				//habilita o "Valor maximo de depreciação" no calculo de depreciação na moeda definida
				nCusto	:=	iif(Empty(aParam[4]),nCusto, aParam[4])	//iif(Empty(SN3->N3_VMXDEPR),nCusto, SN3->N3_VMXDEPR)
			ElseIf nI != nMoedaVMax .And. lVlrMxDp
				// Proporcionaliza a base para as outras moedas
				nCusto := ROUND(NOROUND(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax),nDecTax+1),nDecTax)
			Endif
			
			If lVlrSalv .And. nI == 1
				nVlrOriSal := nCusto - aParam[6]	//SN3->N3_VLSALV1
				nCusto := Abs(nCusto - nDeprAcum)
			ElseIf lVlrSalv .And. nI >= 2
				nVlrOriSal := nCusto - ROUND(NOROUND(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax),nDecTax+1),nDecTax)
				nCusto := Abs(nCusto - nDeprAcum)
			EndIf
			
			// Se possuir valor residual, efetua o calculo da cota.
			If  ( !lVlrSalv .And. Abs( nDeprAcum ) <= Abs( nCusto ) ) .Or. ( lVlrSalv .And. Abs( nDeprAcum ) <= Abs( nVlrOriSal ) )
				
				aCotaM[nI] := If( Empty( aParam[9] ),Round( nCusto * aTaxaRef[nI], nDecimal ), 0 )
				
				// Verifica se o valor da cota eh maior do que o valor residual.
				If lVlrSalv
					nDiferenca := Abs(nVlrOriSal) - ( Abs(aCotaM[nI]) + Abs(nDeprAcum) )
				Else
					nDiferenca := Abs(nCusto) - ( Abs(aCotaM[nI]) + Abs(nDeprAcum) )
				EndIf
				
				// Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual.
				If !lVlrSalv .And. Round( nDiferenca, nDecimal ) <= 0.99
					aCotaM[nI] := nCusto - nDeprAcum
				ElseIf lVlrSalv .And. Round( nDiferenca, nDecimal ) <= 0.99
					aCotaM[nI] := nVlrOriSal - nDeprAcum
				ElseIf lResid
					aCotaM[nI] := Round( (nCusto - nDeprAcum) * aTaxaRef[nI],nDecimal )		//Round(nDiferenca * aTaxaRef[nI],nDecimal)
				Endif
			Endif
		Endif
	Next nI
Endif

//a funcao abaixo precisa ser analisada pois nao tem efeito os calculos que sao realizados por ela
If cTCalcAF == "1"	// Saldos Decrescentes
	Degressiva( cMoedaATF, cPerRegres, nMesRegres, aCotaM, aValores, nLinha )
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/28/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Degressiva(cMoedaATF, cPeriodo, nMes, aCotaM, aValores, nLinha )

Local aVlrOrig		:= aClone(aValores[1])
Local aVlrAcum		:= aClone(aValores[2])
Local aVlrAmpl		:= aClone(aValores[3])
Local aVlrCAcm		:= aClone(aValores[4])
Local aVlrCda		:= aClone(aValores[5])
Local aVlDepr		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Local aCotas		:= AF010CDegres(cMoedaATF, cPeriodo, nMes)

Local nI			:= 0						//Contador - Auxiliar
Local nVlAtivo		:= 0
Local nDeprAcum		:= 0
Local nDif			:= 0
Local __nQuantas 	:= If(lMultMoed,AtfMoedas(),5)

Local cPos			:= 0						//Posição de Campo - Auxiliar

For nI := 1 to __nQuantas
	
	//Saldo de depreciação acumulada na moeda i --------------------
	
	nDeprAcum := aVlrAcum[nI]	//SN3->( FieldGet( FieldPos(If(i>9,'N3_VRDAC','N3_VRDACM') + cPos ) ) )
	nDeprAcum += Af010GetSldAcel( Alltrim(Str(nI)), nLinha )
	
	If nI == 1
		//Este campo é tratado apenas na moeda 1
		nDeprAcum += aVlrCda[1] //SN3->( FieldGet( FieldPos('N3_VRCDA' + cPos ) ) )
	Endif
	
	//--------------------------------------------------------------
	
	//Valor Total do Ativo na moeda i ------------------------------
	
	nVlAtivo := aVlrOrig[nI,1]	//SN3->( FieldGet( FieldPos('N3_VORIG' + cPos ) ) )
	nVlAtivo += aVlrAmpl[nI]	//SN3->( FieldGet( FieldPos(If(i>9,'N3_AMPLI','N3_AMPLIA') + cPos ) ) )
	
	If nI == 1
		//Este campo é tratado apenas na moeda 1
		nVlAtivo += aVlrCAcm[1]	//SN3->( FieldGet( FieldPos(If(i>9,'N3_VRCAC','N3_VRCACM') + cPos ) ) )
	Endif
	
	//--------------------------------------------------------------
	
	If Abs( nDeprAcum ) < Abs( nVlAtivo )
		
		aVlDepr[nI] := Round( aCotas[nI], aVlrOrig[nI,2] )
		
		nDif := Abs( nVlAtivo ) - ( Abs( aValDepr[2] ) + Abs( nDeprAcum ) )
		
		If Round( nDif, aVlrOrig[nI,2] ) <= 0
			aVlDepr[nI] := nVlAtivo - nDeprAcum
		Endif
	Endif
	
next nI

If lMultMoed
	AtfMultMoe(,, {|x| aCotaM[x] := aCotaDepr[x] })
Else
	aCotaM[1] := aCotaDepr[1]
	aCotaM[2] := aCotaDepr[2]
	aCotaM[3] := aCotaDepr[3]
	aCotaM[4] := aCotaDepr[4]
	aCotaM[5] := aCotaDepr[5]
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/28/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Af010GetSldAcel( cMoedaATF, nLinha )

Local cFieldAcum	:= 	IIf( val(cMoedaATF) > 9, "N3_VRDAC", "N3_VRDACM" ) + cMoedaAtf
Local nLinCols		:= nLinha
Local nPTipo		:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_TIPO"})
Local nPVlrAcum		:= aScan(aHeader,{|x| alltrim(x[2]) == cFieldAcum})
Local nResult 		:= 0.00
Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif
If nPTipo > 0 .and. nPVlrAcum > 0
	
	If Alltrim(aCols[nLinCols,nPTipo]) == "07"
		
		nLinha := aScan(aCols,{|x| Alltrim(x[nPTipo]) $ ("01|10" + cTypes10) })
		
		If nLinha > 0
			nResult += aCols[nLinha,nPVlrAcum]
		Endif
		
	Endif
	
	If Alltrim(aCols[nLinCols,nPTipo]) $ ("01|10" + cTypes10)
		
		nLinha := aScan(aCols,{|x| Alltrim(x[nPTipo]) == "07"})
		
		If nLinha > 0
			nResult += aCols[nLinha,nPVlrAcum]
		Endif
		
	Endif
	
Endif

nLinha := nLinCols

Return(nResult)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/28/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010CDegres(cMoedaATF,cPeriodo,nMes)

Local aResult		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )					//Valor de Retorno
Local aLiquido		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )					//Valor Liquido - Auxiliar
Local nAnosDecor	:= 0							//Tempo Decorrido em anos desde o início dos cálculos.
Local nAnosRest		:= 0		  					//Tempo restante em anos para o término dos cálculos.
Local aTaxaMax		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Local i, j			:= 0							//Contador - Auxiliar
Local lUsaCoefic	:= .T.							//Coeficiente aplicado sobre a Taxa de Depreciação

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

aTaxaMax   := MaxTxDegr( lUsaCoefic )
nAnosDecor := 1 + ( Year( dDataBase ) - Year( SN3->( N3_DINDEPR ) ) )
nAnosRest  := PrzTotPrev(cMoedaATF) - nAnosDecor

for i := 1 to __nQuantas
	aLiquido[ i ] := SN3->&('N3_VORIG' + Alltrim(Str(i)) )
	for j := 1 to nAnosDecor
		//Regra: Quando a Cota Anual (VlLiquido * Taxa) FOR MENOR QUE (VlLiquido/Anos Restantes)
		//de vida util, considerar (VlLiquido/Anos Restantes).
		if (aLiquido[ i ] * ( aTaxaMax[ i ] / 100 )) < ( aLiquido[ i ] / nAnosRest )
			aResult[ i ] := aLiquido[ i ] / nAnosRest
			aLiquido[ i ] -= aResult[ i ]
		else
			aResult[ i ] := ( aLiquido[ i ] * ( aTaxaMax[ i ] / 100 ) )
			aLiquido[ i ] -= aResult[ i ]
		endif
	next j
	if cPeriodo == 'M'
		aResult[ i ] /= 12
	endif
next i

Return aResult
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010MOEDºAutor  ³Totvs           º Data ³  27/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do valor máximo da depreciação                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010MOED()
Local cCpo			:= ""
Local dDtConv		:= Ctod("//")
Local nValor		:= 0
Local nDPAcum		:= 0
Local nDPAcBl		:= 0
Local nDPAcMe		:= 0
Local nX			:= 0
Local nPosVOrig		:= 0
Local nLenAcols		:= 0
Local nLAcols		:= 0
Local nPosTipo		:= 0
Local __nQuantas	:= If(lMultMoed,AtfMoedas(),5)
Local aPosVOrig		:= {}
Local aPosVAcum		:= {}
Local aPosVAcBl		:= {}
Local aPosVAcMe		:= {}

cCpo := ReadVar()
If cCpo $ "M->N1_MOEDAQU|M->N1_TXMOEDA"
	aPosVOrig:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })
	aPosVAcum:= If(lMultMoed,AtfMultPos(aHeader,"N3_VRDACM"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM5" } ) })
	aPosVAcBl:= If(lMultMoed,AtfMultPos(aHeader,"N3_VRDBAL"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDBAL1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDBAL2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDBAL3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDBAL4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDBAL5" } ) })
	aPosVAcMe:= If(lMultMoed,AtfMultPos(aHeader,"N3_VRDMES"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDMES1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDMES2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDMES3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDMES4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDMES5" } ) })
	nLenAcols := Len(aCols)
	nPosTipo := Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_TIPO" } )
	For nLAcols := 1 To nLenAcols
		dDtConv := If( aCols[nLAcols][nPosTipo] == "02", dDataBase, M->N1_AQUISIC)
		nValor := aCols[nLAcols,aPosVOrig[1]]
		nDPAcum := aCols[nLAcols,aPosVAcum[1]]
		nDPAcBal := aCols[nLAcols,aPosVAcBl[1]]
		For nX := 2 To  __nQuantas
			If aPosVOrig[1] > 0
				If nX == M->N1_MOEDAQU
					aCols[nLAcols,aPosVOrig[nX]] := nValor / If(Empty(M->N1_TXMOEDA),RecMoeda(M->N1_AQUISIC,nX),M->N1_TXMOEDA)
					aCols[nLAcols][aPosVAcum[nX]] := nValor / If(Empty(M->N1_TXMOEDA),RecMoeda(M->N1_AQUISIC,nX),M->N1_TXMOEDA)
				Else
					aCols[nLAcols,aPosVOrig[nX]] := nValor / RecMoeda(dDtConv,nX)
					aCols[nLAcols,aPosVAcum[nX]] := nValor / RecMoeda(M->N1_AQUISIC,nX)
				Endif
			Endif
			If aPosVAcum[1] > 0
				If nX == M->N1_MOEDAQU
					aCols[nLAcols][aPosVAcum[nX]] := nDPAcum / If(Empty(M->N1_TXMOEDA),RecMoeda(M->N1_AQUISIC,nX),M->N1_TXMOEDA)
				Else
					aCols[nLAcols,aPosVAcum[nX]] := nDPAcum / RecMoeda(M->N1_AQUISIC,nX)
				Endif
			Endif
			If aPosVAcBl[1] > 0
				If nX == M->N1_MOEDAQU
					aCols[nLAcols][aPosVAcBl[nX]] := nDPAcBl / If(Empty(M->N1_TXMOEDA),RecMoeda(M->N1_AQUISIC,nX),M->N1_TXMOEDA)
				Else
					aCols[nLAcols,aPosVAcBl[nX]] := nDPAcBl / RecMoeda(M->N1_AQUISIC,nX)
				Endif
			Endif
			If aPosVAcMe[1] > 0
				If nX == M->N1_MOEDAQU
					aCols[nLAcols][aPosVAcMe[nX]] := nDPAcMe / If(Empty(M->N1_TXMOEDA),RecMoeda(M->N1_AQUISIC,nX),M->N1_TXMOEDA)
				Else
					aCols[nLAcols,aPosVAcMe[nX]] := nDPAcMe / RecMoeda(M->N1_AQUISIC,nX)
				Endif
			Endif
		Next
	Next
	If Valtype(oGet) != "U"
		oGet:oBrowse:Refresh()
	EndIf
Endif
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010PERDPºAutor  ³Microsiga           º Data ³  08/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilhos para os campos N3_TXDEPR1 e N3_PERDEPR            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                             	          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010PERDP(nLinha)
Local lCalcMes	:= (ALLTRIM(GetMv("MV_CALCDEP",,"1")) == "0")	//Verifica a formula de calculo de depreciacao
Local cVar 		:= ReadVar()
Local nTxVal	:= &(ReadVar())
Local nVal		:= 0
Local oModelSN3 := Nil

Default nLinha := n // linha do acols para a MSGEtDados

If "N3_TXDEPR" $ cVar
	If nTxVal > 0
		nVal	:= (100/nTxVal)
		nVal 	:= Round(IiF(lCalcMes,(nVal*12),nVal),0)
	ElseIf IsBlind() .And. Type("M->N3_PERDEPR") <> "U"
		nVal	:= M->N3_PERDEPR
	EndIf

ElseIf "N3_PERDEPR" $ cVar

	If IsInCallStack('ATFA155')
		oModelSN3 := FwModelActive()
		aCols := aClone(oModelSN3:GetModel('SN3DETAIL'):aCols)
	EndIf

	If nTxVal > 0
		nVal := If(lCalcMes,(nTxVal/12),nTxVal)
		nVal := (100/nVal)
	EndIf

	If AllTrim(aCols[nLinha,5]) $ "1|7"	     
		If IsBlind() .And. nTxVal == 0 .And. Type("M->N3_TXDEPR1") <> "U" //Tratamento para rotina automática
			nVal := M->N3_TXDEPR1
		Else
			AF010TXDP(nVal)
		EndIf
	Else
		nVal := 0
		AF010TXDP(nVal)
	Endif
EndIf

Return nVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010PERDPºAutor  ³Microsiga           º Data ³  11/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilhos para os campos N3_TXDEPR2...5                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                             	          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010TXDP(nTxDep,nLinha)
Local cVar 		:= ReadVar()
Local nQtdMo    := AtfMoedas()
Local nI        := 0  
Local nPosTaxa  := 0
Local lAT155	:= IsInCallStack('ATFA155')
Local oModelSN3 := Nil
Local aHeaderX	:= {}

Default nTxDep	:= 0
Default nLinha	:= n //linha do acols para a MSGEtDados

If lAT155
	oModelSN3 := FwModelActive()
	aHeaderX  := aClone(oModelSN3:GetModel('SN3DETAIL'):aHeader)
EndIf

If "N3_PERDEPR" $ cVar
	For nI := 1 To nQtdMo
		nPosTaxa := aScan(Iif(lAT155,aHeaderX,aHeader), {|x| AllTrim(x[2]) == "N3_TXDEPR" + Alltrim(Str(nI))})
		If nPosTaxa > 0
			aCols[nLinha,nPosTaxa] := nTxDep
		EndIf
	Next nI
Endif

Return

//--------------------------------------------------------------------------------
//AVP
//--------------------------------------------------------------------------------
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFAvpAtf   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida existencia das informacoes necessarias para AVP na    ³±±
±±³          ³ base Ativo Fixo							 								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AFAvpAtf(lHelp)					                               ³±±
±±³Parametros³ lHelp -> Mostra Help       			                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFAvpAtf(lHelp)

Return .T. //RETIRADO ALIASINDIC / FIELDPOS / FINDFUNCTION PARA VERSAO 12.1.17


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFAvpAtf2  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida existencia das informacoes necessarias para AVP na    ³±±
±±³          ³ base Ativo Fixo (AVP PARCELA)			 	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AFAvpAtf2(lHelp)					                            ³±±
±±³Parametros³ lHelp -> Mostra Help       			                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFAvpAtf2(lHelp)

Return .T. //RETIRADO ALIASINDIC / FIELDPOS / FINDFUNCTION PARA VERSAO 12.1.17


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA010VldAvp³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida preenchimento dos campos necessarios para AVP         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ FA010VldAvp(dDataAVP,cIndAVP)                                ³±±
±±³Parametros³ dDataAvP -> Data de realizacao do bem                        ³±±
±±³          ³ cIndAvp  -> Codigo do indice financeiro utilizado p/ calcular³±±
±±³          ³             o valor presente do vem 								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA010VldAvp(dDataAVP,cIndAVP)
Local lRet		:= .F.
Local lRet14	:= .F.
Local cVar		:= ReadVar()
Local aReg14	:= {}  //Acols auxiliar da AcolsAVP em tempo de inclusao
Local nPosVlr	:= 0
Local nX        := 0
Local nY        := 0
Local nUsado	:= 0
Local nCntFor	:= 0
Local nQtdEntid:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_TPSALDO/N3_VORIG1/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
Local __nQuantas := AtfMoedas()
Local nAVPMan   := 0

DEFAULT dDataAVP	:= Ctod("//")
DEFAULT cIndAVP	:= ""

//Alimento aHeader da tela APV
If Len(aHeadAVP) == 0

	For nX := 2 to __nQuantas
		cCampos += "/N3_VORIG" + cValtoChar(nX)
	Next nX

	//novas entidades contaveis
	For nX := 5 to nQtdEntid
		cCampos += "/N3_EC"+StrZero(nX, 2)+"DB"
	Next

	//Monta aHeader do AVP
	AtfX3AVP( "SN3", cCampos , Type('lAtfAuto')== "L" .And. lAtfAuto )

Endif

nPosTpSld := aScan( aHeadAvp, { |x| AllTrim( x[2] ) == "N3_TPSALDO" } )

//AVP
//Verifica de o AVP esta implantado na base
lAvpAtf := If(FindFunction("AFAvpAtf"),AFAvpAtf(),.f.)

//Se os campos referente a AVP estiverem em branco
//devo validar como OK mas sem calculos ou geracao do Tipo 14
If !lAvpAtf .or. lCopia
	lRet := .T.
ElseIf (cVar == "M->N1_INDAVP" .And. Empty(cIndAVP)) .Or. (cVar == "M->N1_DTAVP")
	lRet := .T.	
Else
	If cVar == "M->N1_INDAVP" .And. !Empty(cIndAVP)
		FIT->(dbSetOrder(1))
		If !(FIT->(MsSeek(xFilial("FIT")+M->N1_INDAVP)))
			Help("  ",1,"NOINDAVP",,STR0054,1,1)  //"Código de indice financeiro não cadastrado."
		Else
			lRet := .T.
		Endif
	ElseIf !Empty(cIndAVP) .And. !Empty(dDataAVP)
		lRet := .T.
	Endif

	If lRet
		//Pego Indice - Ultimo valor
		cCodInd  := M->N1_INDAVP
		cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + M->N1_INDAVP)
		nTaxa		:= AtfRetInd(cCodInd,M->N1_INIAVP /*dDataProc*/)
		nValVP	:= 0
		nValAVP	:= 0
		nRecno	:= 1
		//Atualiza a taxa em tela
		M->N1_TAXAVP := nTaxa

		//Gera movimento tipo 14 para cada Tipo 10 existente no detalhe da ficha de ativo
		lRet14 := AF010Ger14(aReg14)

		//Se foi criado algum retistro Tipo 14, atualizo aCols
		If lRet14
			For nX := 1 to Len(aReg14)
				For nY := 1 to __nQuantas
					nPosVlr  := aScan( aHeadAvp, { |x| AllTrim( x[2] ) == "N3_VORIG" + cValToChar(nY) } )
					nAVPMan  := Ascan( aHeadAvp , {|e| Alltrim(e[2])   == "N3AVPPLAN" } )
					If nPosVlr > 0
						nValItem := aReg14[nX][nPosVlr]
						If Alltrim(M->N1_TPAVP) != '2'
							If nValItem > 0 .And. nAVPMan > 0 .And. aReg14[nX][nAVPMan] > 0 .And. nY == 1
								nValAVP      := aReg14[nX][nAVPMan]
								nTaxa        := AFCalcTx(cCodInd,nValItem,nValAVP,M->N1_INIAVP,M->N1_DTAVP)
								M->N1_TAXAVP := nTaxa
							Else
								AFCalcAVP("C",nTaxa,cCodInd,nValItem,cPeriodo,M->N1_INIAVP,@nValVP,@nValAVP,M->N1_DTAVP)
							EndIf

							//Atualizo o valor no aColsAVP
							If nValAVP > 0
								aReg14[nX][nPosVlr] := nValAVp

								nPos	:= aScan( aColsAvp, { |x| AllTrim( x[nPosTpSld] ) == aReg14[nX][nPosTpSld] } )

								If nPos == 0
									AADD(aColsAvp, aReg14[nX])
								Else
									aColsAvp[nPos][nPosVlr] := aReg14[nX][nPosVlr]
								Endif
							Endif
						EndIf
					EndIf
				Next nY
			Next nX
		Endif
	Endif

Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF010Ger14 ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera registro 14 - Inclusao (tela AVP)					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AF010Ger14(aReg14)			                                  ³±±
±±³Parametros³ aReg14 - > array com a estrutura dos campos a serem apresenta³±±
±±³          ³             dos na tela de AVP. Esta tela eh acionada atraves³±±
±±³          ³             do botao AVP presente na tela de inclusao do AVP ³±±
±±³          ³             Passado como referencia para ser atualizado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010Ger14(aReg14)
Local lRet      := .F.
Local nInc      := 1
Local nX        := 0
Local nPos      := 0
Local nLinha    := 0
Local nUsado2	  := 0
Local nPosDado  := 0
Local nPosTpSal := 0
Local nPosTipo  := 0
Local nPosSald  := 0
Local cTypes10  := "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

DEFAULT aReg14 := {}  //Acols auxiliar da AcolsAVP em tempo de inclusao
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

nPosTpSal  := aScan( aHeadAVP, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
nPosTpMov  := aScan( aHeadAVP, { |x| AllTrim( x[2] ) == "N3_TIPO"        } )
nPosTipo   := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TIPO"     } )
nPosSald   := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )

For nInc := 1 To Len( aCols )
	//Busca os tipos 10 para gerar os tipos 14
	If aCols[nInc][nPosTipo] $ ("10" + cTypes10)

		//Verifico se tenho registro do tipo 14 para o Tipo 10 + Tipo Saldo
		nPos := aScan( aReg14, { |x| AllTrim( x[nPosSald] ) == Alltrim(aCols[nInc][nPosTpSal]) } )

		//Caso nao exista registro do tipo 14 para o Tipo 10 + Tipo Saldo
		//Incluo um registro tipo 14 + Tipo Saldo
		If nPos == 0
			nUsado2 := Len(aHeadAvp)+1
			nLinha  := Len(aReg14)+1
			AADD(aReg14,Array( nUsado2 ))
			aReg14[nLinha][nUsado2] := .F.

			For nX := 1 to Len(aHeadAvp)
				nPosDado	:= aScan( aHeader, { |x| AllTrim( x[2] ) == AllTrim(aHeadAvp[nX][2])  } )
				aReg14[nLinha][nX] := aCols[nInc,nPosDado]
			Next
			aReg14[nLinha][nPosTpMov] := '14'
		Endif

		lRet := .T.

	Endif
Next

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Af010Avp   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao chamada do botao AVP na tela da ficha do ativo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af010Avp()

Local lEnchBar		:= .T.									// Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao		:= .F.									// Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY			:= 400									// Altura mínima da janela
Local aSize			:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local cCadastro		:= STR0048  //"Calculo AVP"
Local cLinhaOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos		:= ""									// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze		:= 000									// Campos estaticos na GetDados.
Local aAlter		:= {}									// Campos a serem alterados pelo usuario
Local cFieldOk		:= "AllwaysTrue"						// Funcao executada na validacao do campo
Local cSuperDel		:= "AllwaysTrue"						// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk		:= "AllwaysTrue"						// Funcao executada para validar a exclusao de uma linha do aCols
Local nX			:= 0
Local lContinua		:= .F.

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(.T.),.F.)
Endif


If AF010TPAVP()	//Valida se o tipo de AVP e valido

	//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela, 
	//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
	If !(lAvpAtf2 .and. M->N1_TPAVP == '2' .AND. M->N1_PATRIM = 'O')
	
		FA010VldAvp(M->N1_DTAVP,M->N1_INDAVP)
		
		//Monta tela do AVP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definiçãod dos Objetos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgAVP TITLE cCadastro From aSize[7],aSize[2] to aSize[6],aSize[5] of oMainWnd PIXEL
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura de Panels³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPanelAvp			:= TPanel():New(0,0,'',oDlgAVP,, .T., .T.,, ,100,100,.T.,.T. )
		oPanelAvp:Align 	:= CONTROL_ALIGN_ALLCLIENT
		
		If Len(aHeadAvp) > 0
			For nX := 1 to Len(aHeadAvp)
				If AllTrim( aHeadAvp[nX][2] ) $ "N3_HISTOR/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"		
					AADD(aAlter, aHeadAvp[nX][2])
				Endif
			Next
		Endif	
		
		oGetAvp	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(aColsAVP),cFieldOk,cSuperDel,cDelOk,oPanelAvp,aHeadAvp,aColsAvp)
		oGetAvp:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE MSDIALOG oDlgAvp ON INIT EnchoiceBar(oDlgAvp,{||nOpca:=1,If(MsgYesNo(STR0036,STR0037),(aColsAVP := aClone(oGetAvp:aCols),oDlgAvp:End()),nOpca:=0)},{||oDlgAvp:End()}) CENTERED	//"Confirma Alteracao?"###"Atenção"
	Else
		Help( " ", 1, "AF010NOAVP",, STR0055, 1, 0 )  //"Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela, o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões."
	Endif	
Endif

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF010Grv14 ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera registro 14 no Acols (SN3) para Gravacao do SN3         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AF010Grv14(aCols14)			                                  ³±±
±±³Parametros³ aCols14 - > array com a estrutura do SN3 Tipo 10 a partir do ³±±
±±³          ³             qual sera gerado o regitro Tipo 14 (AVP)         ³±±
±±³          ³             Passado como referencia para ser atualizado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010Grv14(aCols14)
Local lRet       := .F.
Local nInc       := 1
Local nX         := 0
Local nPos       := 0
Local nLinha     := 0
Local nUsado2    := 0
Local nPosDado   := 0
Local nPosTpSal  := 0
Local nPosTipo   := 0
Local nPosSald   := 0
Local nPosVMax   := 0
Local nPosVSav   := 0
Local nVlrTp10   := 0
Local nVlrMax    := 0
Local nVlrSav    := 0
Local nProp      := 0
Local nMoedaAtf  := Val(GetMV("MV_ATFMOED"))
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), nMoedaAtf )

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })

Local aPosVDep:= If(lMultMoed,AtfMultPos(aHeader,"N3_VRDACM"),;
	{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM1" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM2" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM3" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM4" } ),;
	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM5" } ) })

Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

DEFAULT aCols14 := {}    //Acols auxiliar da Acols em tempo de gravacao

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(.T.),.F.)
Endif

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If !(lAvpAtf2 .and. M->N1_TPAVP == '2' .and. M->N1_PATRIM == 'O')

	//Arrays utilizados nesta rotina
	//aCols = aCols da GetDados do SN3 da inclusao do imobilizado (PRIVATE)
	//aCols14 = array contendo copia do registro SN3 tipo 10 e depois atualizado com os dados do AVP (LOCAL POR REFERENCIA)
	//aColsAVP = aCols da Getdados da tela de AVP (STATIC)
	
	//Valida os dados do AVP
	FA010VldAvp(M->N1_DTAVP,M->N1_INDAVP)

	nPosTpSal := aScan( aHeadAVP, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosTipo  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TIPO"  } )
	nPosSald  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosVlr01 := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VORIG1"  } )
	nPosVMax  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
	nPosVSav  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )


	For nInc := 1 To Len( aCols )
		//Busca os tipos 10 para gerar os tipos 14
		If aCols[nInc][nPosTipo] $ ("10" + cTypes10)

			//Verifico se tenho registro do tipo 14 para o Tipo 10 + Tipo Saldo
			nPos := aScan( aColsAVP, { |x| AllTrim( x[nPosTpSal] ) == Alltrim(aCols[nInc][nPosSald]) } )

			//Caso exista registro do tipo 14 para o Tipo 10 + Tipo Saldo
			//Incluo um registro tipo 14 + Tipo Saldo no aCols14
			If nPos > 0
				nUsado2 := Len(aHeader)+1
				AADD(aCols14,aClone(aCols[nInc])) //Copio a linha do tipo 10
				nLinha  := Len(aCols14)

				//Se a linha nao esta deletada, vou gravar no array aCols14
				//Que posteriormente sera incluido no aCols do SN3 antes de gravar a tabela
				If !aCols14[nLinha][nUsado2]
					For nX := 1 to Len(aHeadAVP)
						nPosDado	:= aScan( aHeader, { |x| AllTrim( x[2] ) == AllTrim(aHeadAvp[nX][2])  } )
						aCols14[nLinha][nPosDado] := aColsAvp[nPos,nX]
					Next
				Endif

				For nX := 1 to __nQuantas
					//Acerto o valor maximo de depreciacao e valor de salvamento
					//Acho a proporcao entre o valor do Tipo 10 liquido e Bruto
					//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
					nVlrTp10 := aCols[nInc][aPosVOrigX[nX]] - aCols14[nLinha][aPosVOrigX[nX]]
					nProp 	:= (nVlrTp10 / aCols[nInc][aPosVOrigX[nX]])

					If nX == nMoedaVMax
						nVlrMax  := aCols[nInc][nPosVMax]
						aCols[nInc][nPosVMax]     := nVlrMax * nProp
						aCols14[nLinha][nPosVMax] := nVlrMax - aCols[nInc][nPosVMax]
					EndIf

					If nX == 1
						nVlrSav                   := aCols[nInc][nPosVSav]
						aCols[nInc][nPosVSav]     := nVlrSav * nProp
						aCols14[nLinha][nPosVSav] := nVlrSav - aCols[nInc][nPosVSav]
					EndIf

					//Calcula a Depreciação Acumulada
					aCols[nInc][aPosVDep[nX]]  		:= aCols[nInc][aPosVDep[nX]] * nProp
					aCols14[nLinha][aPosVDep[nX]]   -= aCols[nInc][aPosVDep[nX]]
					//Atualizo os valores da linha do tipo 10 diminuindo o valor de AVP Constituicao
					aCols[nInc][aPosVOrigX[nX]] -= aCols14[nLinha][aPosVOrigX[nX]]
				Next nX
			Endif
			
			lRet := .T.
			
		Endif
	Next
EndIf

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFStartAvp ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reinicia o aCols e aHeader do AVP						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFStartAvp()

aColsAvp := {}
aHeadAvp := {}

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF010AVCLS³ Autor ³Alvaro Camillo Neto    ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o preenchimento do campo N1_PATRIM em função das    ³±±
±±³ 		 ³ opções disponíveis na tabela auxiliar do ativo SN0 07.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF010AVCLS()
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local cPatrim  := M->N1_PATRIM

SN0->(dbSetOrder(1)) //N0_FILIAL+N0_TABELA+N0_CHAVE
If SN0->(!MsSeek( xFilial("SN0") + "07" + cPatrim))
	Help( " ", 1, "AF010AVCLS",,STR0034, 1, 0 ) // "Classificação do ativo incorreta , verifique a tabela 07 dos dados auxiliares do ativo"
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Atf010x3tituloºAutor³Fernando Radu Muscaluº Data ³ 02/12/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o titulo do campo no dic SX3.						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                             	          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Atf010x3titulo(cCampo)

Local cRet		:= ""

Local aAreaSX3	:= SX3->(GetArea())

Default cCampo := ReadVar()

If Valtype(cCampo) == "C"
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))
	cRet := SX3->(X3TITULO())
Endif

RestArea(aAreaSX3)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ATXDP  ºAutor  ³Renan Guedes      º Data ³  12/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função utilizada como WHEN dos campos de taxa da depreciaçãoº±±
±±º          ³N3_TXDEPR                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATXDP(nLinha)

Local lRet			:= .T.
Local nPosN3TpDp 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
Local cTpDepr 		:= ""

Default nLinha 		:= n

cTpDepr := IIf(nPosN3TpDp > 0, aCols[nLinha][nPosN3TpDp], '')

If cTpDepr == "A"
	lRet := .F.
EndIf

Return(lRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A010VInAVPºAutor  ³Alvaro Camillo Neto º Data ³  13/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do campo de inicio de AVP                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VInAVP()
Local lRet := .T.

If M->N1_INIAVP < M->N1_AQUISIC
	Help( " ", 1, "AF010INIAVP",,STR0044, 1, 0 ) // "Data de Inicio do AVP deve ser maior ou igual que a data de aquisição do ativo"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010TPAVPºAutor  ³Mauricio Pequim Jr. º Data ³  15/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do campo de tipo de AVP                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF010TPAVP()
Local lRet := .T.

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(.T.),.F.)
Endif

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If lAvpAtf2
	If M->N1_TPAVP == '2' .and. M->N1_PATRIM != 'O'
		Help( " ", 1, "AF010TPAVP",,STR0051, 1, 0 ) //'O tipo de AVP por parcela somente pode ser utilizada para classificação patrimonial "Orçamento de Provisão de despesas". Para as demais classificações, utilizar tipo AVP igual a Total.'
		lRet := .F.
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010VlGrMºAutor  ³Alvaro Camillo Neto º Data ³  13/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o movimento de implantação pode ser gravado     º±±
±±º          ³ protegendo a alteracao do registro de movimentacao         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010VlGrM(lInclui,cBase,cItem,cTipo,cSeq,cSeqReav)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())

If !lInclui
	// Caso o indice exista, busca pelo indice para o tratamento de multiplos tipos de saldo
	If !Empty(SN4->(IndexKey(9)))
		SN4->(dbSetOrder(9)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR
		If SN4->(MsSeek(xFilial("SN4") +cBase+cItem+cTipo+cSeqReav+cSeq ))
			lRet := .F.
		EndIf
	Else // Caso contrario, busca no indice antigo
		SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR
		If SN4->(MsSeek(xFilial("SN4") +cBase+cItem+cTipo ))
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaSN4)
RestArea(aArea)
Return  lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010VLocºAutor  ³Alvaro Camillo Neto º Data ³  15/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de validação do campo N1_LOCAL                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010VLoc()
Local lRet    := .T.
Local cDescri := ""

lRet := Vazio() .Or. ExistCpo( "SNL", M->N1_LOCAL )

If lRet
	cDescri := GetAdvFVal("SNL","NL_DESCRIC", xFilial("SNL") + M->N1_LOCAL)
EndIf

M->N1_DLOCAL := cDescri

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF10aExcId ºAutor ³Microsiga           º Data ³  02/29/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a exclusao dos movimentos do SN4 do bem quando      º±±
±±º          ³com o mesmo ID                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF10aExcId(cBase,cItem,cTipo,cSeqReav,cSeq,cIdMov,aRecAtf)
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())

SN4->(dbSetOrder(9))//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR

If SN4->(MsSeek(xFilial("SN4") + cBase + cItem + cTipo + cSeqReav + cSeq ))
	While SN4->(!EOF()) .And. SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ) == xFilial("SN4") + cBase + cItem + cTipo + cSeqReav + cSeq
		If Alltrim(SN4->N4_IDMOV) == Alltrim(cIdMov)
			RecLock("SN4",.F.)
			dbDelete()
			FkCommit()
			msUnlock()
			//grava em array os recnos utilizados para integracao com PCO
			Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao
		EndIf
		SN4->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSN4)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFXLGrp   ºAutor  ³Alvaro Camillo Neto º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa a variavel de grupo de bens                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFXLGrp()
	__cGrupoFNG := ""
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ATPSALºAutor ³TOTVS				 º Data ³  22/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de validação do campo N3_TPSALD                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATPSAL()
Local lRet := .T.

If FunName() == "ATFA010" // Validacao valida apenas para a rotina ATFA010

	If n <= nOriginal
		Help(" ",1,"AFA010NAOP")
		lRet := .F.
	Endif 

Endif

Return lRet

//AVP2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ProvisºAutor³Microsiga           º Data ³  05/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gero os provisorios caso o bem de orcamento                º±±
±±º          ³ possua depreciacao acumulada                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010Provis(cBase,cItem)
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())
Local aAreaSN1 := SN1->(GetArea())
Local aAVPMan  := {}
Local lRet     := .T.

If Type('lAtfAuto')== "L" .And. lAtfAuto .And. Type('aAutoItens')== "A" 
	aAVPMan := aClone(aAutoItens) 
Else
	aAVPMan := {}	
EndIf

//Posiciono no SN4
SN4->(DBSETORDER(1))
SN1->(DBSETORDER(1))

If SN1->(MsSeek(xFilial("SN1") + cBase + cItem ))
	If SN4->(MsSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM)+'01'+Dtos(dDatabase)+'06')) .Or. SN4->(MsSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM)+'10'+Dtos(dDatabase)+'20'))
		//Incluo os novo bens (se houve depreciacao)
		lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(),.f.)
		If lAvpAtf2
			//Se o bem for classificado como Orcamento e o AVP deste for por parcela
			//Verifico se ouve depreciacao e gero o ativo de provisao
			If SN1->N1_PATRIM == 'O' .and. SN1->N1_TPAVP == '2'
				MsgRun(STR0057,"",{|| lRet := AF460Apur(.T.,SN1->N1_GRUPO,SN4->N4_IDMOV,dDatabase,aAVPMan) })//"Convertendo Bem Aguarde"
				Pergunte("AFA010",.F.)
			Endif
		Endif
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aAreaSN4)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010CANPrvºAutor  ³Microsiga           º Data ³  05/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excluo os provisorios relacionados ao bem                  º±±
±±º          ³ de orcamento em exclusao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF010CANPrv(cBaseSup,cItemSup)

Local lRet := .T.
Local aArea := GetArea()
Local aRecFNO := {}

DEFAULT cBaseSup := ""
DEFAULT cItemSup := ""

If Empty(cBaseSup) .or. Empty(cItemSup)
	lRet := .F.
Endif

//Posiciono no SN4
//Incluo os novo bens (se houve depreciacao)
If lRet .and. (lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(),.f.))

	dbSelectArea("FNO")
	FNO->(dbSetOrder(3)) //Filial + BaseSup + ItemSup
	If FNO->(MsSeek(xFilial("FNO")+cBaseSup+cItemSup))

		//Enquanto for o mesmo ATIVO SUPERIOR
		While !( FNO->(Eof()) ) .AND. xFilial("FNO")+cBaseSup+cItemSup == FNO->(FNO_FILIAL+FNO_BASESP+FNO_ITEMSP)

			SN1->(dbSetOrder(1))
			If SN1->(MsSeek(xFilial("SN1")+FNO->(FNO_CBASE+FNO_ITEM)))
				//Obtenho os recnos dos filhos para posterior exclusao
				aadd(aRecFNO,{ FNO->(Recno()) } )
			Endif				
			FNO->(dbSkip())		
		Enddo
	Endif
	
	//Estorno o provisorio
	If Len(aRecFNO) > 0
		MsgRun(STR0058,"",{|| AF460EstPrv(aRecFNO,1,.T.) })//"Convertendo Bem Aguarde"
	Endif

	Pergunte("AFA010",.F.)
	
Endif

RestArea(aArea)

Return lRet


//BPI - Baixa de Provisao de Imobilizado
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010UPRJ  ³Autor  ³Mauricio Pequim Jr     ³ Data ³ 24/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o When do campo N1_PROJETO a partir da implementacao  ³±±
±±³          ³ da Baixa de Provisao de Imobilizados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AF010UPRJ()

Local lRet := .F.

//Verifico se a Baixa de Provisao de Imobilizado esta implantada
Local lBpiAtf := If(FindFunction("AFVldBpi"),AFVldBpi(),.F.)

//Apenas bens que nao tenham sido geradas por projeto poderao ter acesso ao campo N1_PROJETO
If Alltrim(M->N1_ORIGEM) != "ATFA430"
	If lBpiAtf
		//Se processo de Inclusao
		If Inclui
			lRet := .T.
		//Se processo de Alteracao
		ElseIf Altera 
			If Empty( M->N1_PROJETO ) 
				lRet := .T.
			//Verifica se esse bem NAO possui relacionamento de execuao com projeto
			ElseIf !(FaVRelPrj(3,xFilial("FNJ")+M->N1_PROJETO+M->N1_CBASE+M->N1_ITEM))
				lRet := .T.
			Endif					
		Endif
	Endif
Endif

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010VLPRJ ³Autor  ³Mauricio Pequim Jr     ³ Data ³ 26/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos campos N1_PROJETO e N1_PROJREV a partir da     ³±±
±±³          ³ implementacao da Baixa de Provisao de Imobilizados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AF010VLPRJ()

Local lRet := .T.                           

//Verifico se a Baixa de Provisao de Imobilizado esta implantada
If FindFunction("AFVldBpi") .and. AFVldBpi()
	lRet := Vazio().Or.ExistCpo('FNB',M->N1_PROJETO,,,,.F.)
Endif

Return lRet	

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF010AQPAD ³Autor  ³Alvaro Camillo Neto     ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função para determinar qual o códido do lançamento padrão     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function AF010AQPAD(cTipoATF,lEstorno)
Local cPadrao := ""
Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

Default lEstorno := .F. 

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "*" + AtfNValMod({1}, "*")
Endif

If lEstorno
	If cTipoATF $ ("01*10" + cTypes10)
		cPadrao := "805"
	ElseIf cTipoATF $ "02,05"
		cPadrao := "806"
	ElseIf cTipoATF $ "03*13"
	    cPadrao := "807"
	ElseIf cTipoATF == "04"
		cPadrao := "808" 
	ElseIf cTipoATF == "11"
		cPadrao := "822"
	Else
		cPadrao := "80B"
	EndIf
Else
	If cTipoATF $ ("01*10" + cTypes10)
		cPadrao := "801"
	ElseIf cTipoATF $ "02,05"
		cPadrao := "802"
	ElseIf cTipoATF $ "03*13"
	    cPadrao := "803"
	ElseIf cTipoATF == "04"
		cPadrao := "804" 
	ElseIf cTipoATF == "11"
		cPadrao := "821"
	Else
		cPadrao := "80A"
	EndIf
EndIf

Return cPadrao






//MRG
//-- MARGEM GERENCIAL (TIPO 15) -----

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Af010Margem ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao chamada do botao Margem na tela da ficha do ativo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af010Margem()

Local lEnchBar		:= .T.									// Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao		:= .F.									// Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY			:= 400									// Altura mínima da janela
Local aSize			:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local cCadastro		:= "Margem Gerencial"
Local cLinhaOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos		:= ""									// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze		:= 000									// Campos estaticos na GetDados.
Local aAlter		:= {}									// Campos a serem alterados pelo usuario
Local cFieldOk		:= "AllwaysTrue"						// Funcao executada na validacao do campo
Local cSuperDel		:= "AllwaysTrue"						// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk		:= "AllwaysTrue"						// Funcao executada para validar a exclusao de uma linha do aCols
Local nX			:= 0
Local lContinua		:= .F.
//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela, 
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If lMargem .and. !Empty(M->N1_MARGEM) .and. !Empty(M->N1_REVMRG)

	If FA010MrgVld(M->N1_MARGEM,M->N1_REVMRG)
		
		//Monta tela da Margem Gerencial
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definiçãod dos Objetos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgMrg TITLE cCadastro From aSize[7],aSize[2] to aSize[6],aSize[5] of oMainWnd PIXEL
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura de Panels³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPanelMrg			:= TPanel():New(0,0,'',oDlgMrg,, .T., .T.,, ,100,100,.T.,.T. )
		oPanelMrg:Align 	:= CONTROL_ALIGN_ALLCLIENT
		
		If Len(aHeadMrg) > 0
			For nX := 1 to Len(aHeadMrg)
				If AllTrim( aHeadMrg[nX][2] ) $ "N3_HISTOR/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"		
					AADD(aAlter, aHeadMrg[nX][2])
				Endif
			Next
		Endif	
		
		oGetMrg	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(aColsMrg),cFieldOk,cSuperDel,cDelOk,oPanelMrg,aHeadMrg,aColsMrg)
		oGetMrg:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE MSDIALOG oDlgMrg ON INIT EnchoiceBar(oDlgMrg,{||nOpca:=1,If(MsgYesNo(STR0036,STR0037),(aColsMrg := aClone(oGetMrg:aCols),oDlgMrg:End()),nOpca:=0)},{||oDlgMrg:End()}) CENTERED	//"Confirma Alteracao?"###"Atenção"
	Endif	
Endif	


Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF010Grv15 ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera registro 15 no Acols (SN3) para Gravacao do SN3         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AF010Grv15(aCols15)			                                ³±±
±±³Parametros³ aCols15 - > array com a estrutura do SN3 Tipo 10 a partir do ³±±
±±³          ³             qual sera gerado o regitro Tipo 15 (Margem)      ³±±
±±³          ³             Passado como referencia para ser atualizado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010Grv15(aCols15)
Local lRet       := .F.
Local nInc       := 1
Local nX         := 0
Local nPos       := 0
Local nLinha     := 0
Local nUsado2    := 0
Local nPosDado   := 0
Local nPosTpSal  := 0
Local nPosTipo   := 0
Local nPosSald   := 0
Local nPosVMax   := 0
Local nPosVSav   := 0
Local nVlrTp10   := 0
Local nVlrMax    := 0
Local nVlrSav    := 0
Local nProp      := 0
Local nMoedaAtf  := Val(GetMV("MV_ATFMOED"))
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), nMoedaAtf )

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeader,"N3_VORIG"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })

Local aPosVDep:= If(lMultMoed,AtfMultPos(aHeader,"N3_VRDACM"),;
{ 	Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM1" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM2" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM3" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM4" } ),;
Ascan(aHeader	, {|e| Alltrim(e[2]) == "N3_VRDACM5" } ) })

//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem	:= If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)
Local aColsAlt	:= aClone(aCols)
Local nPos15	:= 0

Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

DEFAULT aCols15 := {}    //Acols auxiliar da Acols em tempo de gravacao

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Arrays utilizados nesta rotina
//aCols = aCols da GetDados do SN3 da inclusao do imobilizado (PRIVATE)
//aCols15 = array contendo copia do registro SN3 tipo 10 e depois atualizado com os dados da Margem Gerencial (LOCAL POR REFERENCIA)
//aColsMRG = aCols da Getdados da tela de Margem Gerencial (STATIC)
If lMargem .and. !Empty(M->N1_MARGEM) .and. !Empty(M->N1_REVMRG)

	nPosTpSal := aScan( aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosTipo  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TIPO"     } )
	nPosSald  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosVlr01 := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VORIG1"   } )
	nPosVMax  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VMXDEPR"  } )
	nPosVSav  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VLSALV1"  } )
	
	
	For nInc := 1 To Len( aCols )
		//Busca os tipos 10 para gerar os tipos 15
		If aCols[nInc][nPosTipo] $ ("10#13" + cTypes10)
			
			//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo preexistente
			nPos15 := aScan( aColsAlt , { |x| AllTrim( x[nPosTipo] ) + AllTrim( x[nPosSald] ) == "15" + Alltrim(aCols[nInc][nPosSald]) } )

//			nPos15 := aScan( aColsAlt , { |x| AllTrim( x[1] ) + AllTrim( x[2] )  ==  AllTrim( cEtpFND ) + AllTrim( cItmFND ) } ) 
			If nPos15 == 0

				//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo
				nPos := aScan( aColsMRG, { |x| AllTrim( x[nPosTpSal] ) == Alltrim(aCols[nInc][nPosSald]) } )
				
				//Caso exista registro do tipo 15 para o Tipo 10 + Tipo Saldo
				//Incluo um registro tipo 15 + Tipo Saldo no aCols15
				If nPos > 0
	
					nUsado2 := Len(aHeader)+1
					AADD(aCols15,aClone(aCols[nInc])) //Copio a linha do tipo 10/13
					nLinha  := Len(aCols15)
					
					//Se a linha nao esta deletada, vou gravar no array aCols14
					//Que posteriormente sera incluido no aCols do SN3 antes de gravar a tabela
					If !aCols15[nLinha][nUsado2]
						For nX := 1 to Len(aHeadMRG)
							nPosDado	:= aScan( aHeader, { |x| AllTrim( x[2] ) == AllTrim(aHeadMRG[nX][2])  } )
							aCols15[nLinha][nPosDado] := aColsmRG[nPos,nX]
						Next
					Endif
					
					For nX := 1 to __nQuantas
						//Acerto o valor maximo de depreciacao e valor de salvamento
						//Acho a proporcao entre o valor do Tipo 10 liquido e Bruto
						//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
						nProp 	:= (aCols15[nLinha][aPosVOrigX[nX]] / aCols[nInc][aPosVOrigX[nX]])
						
						If nX == nMoedaVMax
							nVlrMax                   := aCols[nInc][nPosVMax]
							aCols[nInc][nPosVMax]     := nVlrMax * nProp
							aCols15[nLinha][nPosVMax] := nVlrMax - aCols[nInc][nPosVMax]
						EndIf
						
						If nX == 1
							nVlrSav                   := aCols[nInc][nPosVSav]
							aCols[nInc][nPosVSav]     := nVlrSav * nProp
							aCols15[nLinha][nPosVSav] := nVlrSav - aCols[nInc][nPosVSav]
						EndIf
						
						//Calcula a Depreciação Acumulada
						aCols[nInc][aPosVDep[nX]]  		:= aCols[nInc][aPosVDep[nX]] * nProp
						aCols15[nLinha][aPosVDep[nX]]   -= aCols[nInc][aPosVDep[nX]]
	 
 					Next nX
				Endif
			
				lRet := .T.
			Endif
			
		Endif
	Next
EndIf

Return lRet





/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFStartMrg ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reinicia o aCols e aHeader da Margem gerencial               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFStartMrg()

aColsMrg := {}
aHeadMrg := {}

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA010MrgVld³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida preenchimento dos campos necessarios para AVP         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ FA010MrgVld(cMargem,cRevMrg)                                 ³±±
±±³Parametros³ cMargem -> Código da regra de margem gerencial               ³±±
±±³          ³ cRevMrg -> código da revisao da regra de margem gerencial    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA010MrgVld(cMargem,cRevMrg)

Local lRet		:= .F.
Local lRet15	:= .F.
Local aReg15	:= {}  //Acols auxiliar da AcolsMRG em tempo de inclusao
Local nPosVlr	:= 0
Local nX        := 0
Local nY        := 0
Local nProp		:= 1
Local nQtdEntid:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_TPSALDO/N3_VORIG1/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
Local __nQuantas := AtfMoedas()
//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)
Local nValM1	:= 0

DEFAULT cMargem := ""
DEFAULT cRevMrg	:= ""

//Alimento aHeader da tela Margem Gerencial
If Len(aHeadMrg) == 0
	
	For nX := 2 to __nQuantas
		cCampos += "/N3_VORIG" + cValtoChar(nX)
	Next nX
	
	//novas entidades contaveis
	For nX := 5 to nQtdEntid
		cCampos += "/N3_EC"+StrZero(nX, 2)+"DB"
	Next
	
	//Monta aHeader da Margem Gerencial
	AtfX3Mrg( "SN3", cCampos )
	
Endif

nPosTpSld := aScan( aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TPSALDO" } )

//Se os campos referente a AVP estiverem em branco
//devo validar como OK mas sem calculos ou geracao do Tipo 15
If !lMargem .or. Empty(cMargem) 
	
	//Caso o codigo de margem tenha sido zerado, limpo o campo de 
	If lMargem .and. Empty(cMargem)
		M->N1_REVMRG := ""
	Endif

	lRet := .T.
Else
	If Empty(cRevMrg)
		cRevMrg := IIf(FindFunction("AF470GetRev"),AF470GetRev(cMargem),"")	
	Endif	

	FNQ->(dbSetOrder(1))
	If !(FNQ->(MsSeek(xFilial("FNQ")+cMargem+cRevMrg)))
		Help("  ",1,"NOMARGEM",,STR0063,1,1)    //"Regra de Margem Gerencial não cadastrada"
		lRet := .F.
	ElseIf FNQ->FNQ_STATUS == "2"  //Revisado 
		Help("  ",1,"MARGEMREV",,STR0064,1,1)	//"Regra de Margem Gerencial possui revisão posterior. Utilize a ultima revisão ativa da regra de margem gerencial"
		lRet := .F.
	ElseIf FNQ->FNQ_MSBLQL == "1"  //Bloqueado
		Help("  ",1,"MARGEMBLQ",,STR0065,1,1)	//"Regra de Margem Gerencial bloqueada para uso. Utilize outra regra cadastrada"
		lRet := .F.
	Else	
		lRet := .T.
	Endif
	
	If lRet
		//Pego Indice - Ultimo valor
		cTipo  		:= FNQ->FNQ_TIPO
		nValTaxa  	:= If(cTipo == "1", FNQ->FNQ_PERCEN, FNQ->FNQ_VLRFIX)
		nRecno	:= 1
		
		//Carrego o codigo da revisao ativa
		M->N1_REVMRG := FNQ->FNQ_REV
				
		//Gera movimento tipo 15 para cada Tipo 10 existente no detalhe da ficha de ativo
		lRet15 := AF010Ger15(aReg15)
		
		//Se foi criado algum retistro Tipo 14, atualizo aCols
		If lRet15
			For nX := 1 to Len(aReg15)
				For nY := 1 to __nQuantas
					nPosVlr	 := aScan( aHeadMrg, { |x| AllTrim( x[2] ) == "N3_VORIG" + cValToChar(nY) } )
					If nPosVlr > 0
						nValItem := aReg15[nX][nPosVlr]

						//Atualizo o valor no aColsAVP
						If nValTaxa > 0
							If cTipo == "1"		//Percenual
								aReg15[nX][nPosVlr] := aReg15[nX][nPosVlr] * (nValTaxa/100)
							Else				//Falor Fizo
								aReg15[nX][nPosVlr] := nValTaxa
							Endif

							nPos := aScan( aColsMrg, { |x| AllTrim( x[nPosTpSld] ) == aReg15[nX][nPosTpSld] } )
							
							If nPos == 0
								AADD(aColsMrg, aReg15[nX])
							Else
								aColsMrg[nPos][nPosVlr] := aReg15[nX][nPosVlr]
							Endif
						Endif
					EndIf
				Next nY
			Next nX
		Endif
	Endif
	
Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF010Ger15 ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera registro 15 - Inclusao (tela Margem Gerencial)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AF010Ger15(aReg15)			                                ³±±
±±³Parametros³ aReg15 - > array com a estrutura dos campos a serem apresenta³±±
±±³          ³             dos na tela de Margem. Esta tela eh acionada     ³±±
±±³          ³             atraves do botao Margem presente na tela de      ³±±
±±³          ³             inclusao da margem Gerencial						³±±
±±³          ³             Passado como referencia para ser atualizado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010Ger15(aReg15)

Local lRet		:= .F.
Local nInc		:= 1
Local nX			:= 0
Local nPos		:= 0
Local nLinha	:= 0
Local nUsado2	:= 0
Local nPosDado := 0
Local nPosTpSal:= 0
Local nPosTipo	:= 0
Local nPosSald := 0
Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

DEFAULT aReg15 := {}  //Acols auxiliar da AcolsAVP em tempo de inclusao
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

nPosTpSal	:= aScan( aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
nPosTpMov	:= aScan( aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TIPO"  } )
nPosTipo	:= aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TIPO"  } )
nPosSald	:= aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )

For nInc := 1 To Len( aCols )
	//Busca os tipos 10 para gerar os tipos 15
	If aCols[nInc][nPosTipo] $ ("10#13" + cTypes10)
		
		//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo
		nPos := aScan( aReg15, { |x| AllTrim( x[nPosSald] ) == Alltrim(aCols[nInc][nPosTpSal]) } )
		
		//Caso nao exista registro do tipo 15 para o Tipo 10 + Tipo Saldo
		//Incluo um registro tipo 15 + Tipo Saldo
		If nPos == 0
			nUsado2 := Len(aHeadMrg)+1
			nLinha  := Len(aReg15)+1
			AADD(aReg15,Array( nUsado2 ))
			aReg15[nLinha][nUsado2] := .F.
			
			For nX := 1 to Len(aHeadMrg)
				nPosDado	:= aScan( aHeader, { |x| AllTrim( x[2] ) == AllTrim(aHeadMrg[nX][2])  } )
				aReg15[nLinha][nX] := aCols[nInc,nPosDado]
			Next
			aReg15[nLinha][nPosTpMov] := '15'
		Endif
		
		lRet := .T.
		
	Endif
Next

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010MrgWhen³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When do campo N1_MARGEM                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Permitir ou nao a digitacao do campo N1_MARGEM               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010MrgWhen()

Local lRet := .T.
Local aArea := GetArea()
Local aAreaSN3 := SN3->(GetArea())

//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)

//PRV
//Verifica implementacao da Controle de Provisao
Local lProvis := If(FindFunction("AFPrvAtf"),AFPrvAtf(),.F.)


//Se o tratamento de Margem Gerencial nao estiver implementado, nao posso alterar o campo N1_MARGEM
If !lMargem
	lRet := .F.
Endif

//PRV
//Se o tratamento de controle de provisao estiver preenchido, nao se aplica esse controle
If lProvis .and. lRet .and. !Empty(M->N1_PROVIS)
	lRet := .F.
Endif

//Bens ligados a projeto nao tem margem gerencial
//Bens que possuam AVP nao podem ter margem gerencial
If lRet .and. (!Empty(M->N1_PROJETO) .or. !Empty(M->N1_INDAVP))
	lRet := .F.
Endif
	
//Se a ficha de imobilizado ja possuir bem do tipo 15, nao posso alterar o campo N1_MARGEM
If lRet
	SN3->(dbSetOrder(1))  //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	If SN3->(MsSeek(xFilial("SN3")+M->N1_CBASE+M->N1_ITEM+"15"))  //Ja existe regra de margem gerencial
		lRet := .F.
	Endif
Endif

RestArea(aAreaSN3)
RestArea(aArea)
	     
Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010AvpWhen³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When do campo N1_INDAVP                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Permitir ou nao a digitacao do campo N1_INDAVP               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010AVPWhen()

Local lRet := .T.
Local aArea := GetArea()

//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := If(FindFunction("AFMrgAtf"),AFMrgAtf(),.F.)

//PRV
//Verifica implementacao da Controle de Provisao
Local lProvis := If(FindFunction("AFPrvAtf"),AFPrvAtf(),.F.)

//Se o tratamento de Margem Gerencial nao estiver implementado, nao se aplica esse controle
If lMargem .and. !Empty(M->N1_MARGEM)
	lRet := .F.
Endif
	
//PRV
//Se o tratamento de controle de provisao estiver preenchido, nao se aplica esse controle
If lProvis .and. lRet .and. !Empty(M->N1_PROVIS)
	lRet := .F.
Endif

RestArea(aArea)
	     
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010PrvWhen³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When do campo N1_PROVIS                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Permitir ou nao a digitacao do campo N1_PROVIS               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//PRV
Function A010PrvWhen()

Local lRet := .T.
Local aArea := GetArea()
Local aAreaSN3 := SN3->(GetArea())

//PRV
//Verifica implementacao da Controle de Provisao
Local lProvis := If(FindFunction("AFPrvAtf"),AFPrvAtf(),.F.)

//Se o tratamento de Controle de Provisao estiver implementado, nao posso alterar o campo N1_MARGEM
If !lProvis
	lRet := .F.
Endif

//Bens ligados a projeto nao podem ser relacionados a um controle de provisão
//Bens que possuam AVP nao podem ser relacionados a um controle de provisão
//Bens que possuam margem gerencial nao podem ser relacionados a um controle de provisão
If lRet .and. (!Empty(M->N1_PROJETO) .or. !Empty(M->N1_INDAVP) .or. !Empty(M->N1_MARGEM))
	lRet := .F.
Endif
	
//Se a ficha de imobilizado ja estiver relacionada a um controle de provisão, nao posso alterar o campo N1_PROVIS
If lRet .and. !Empty(SN1->N1_PROVIS)
	FNX->(dbSetOrder(2))  //FNX_FILIAL+FNX_CBASE+FNX_ITEM+FNX_TIPO+FNX_TPSALD
	If FNX->(MsSeek(xFilial("FNX")+M->N1_CBASE+M->N1_ITEM))  //Ja existe regra de margem gerencial
		lRet := .F.
	Endif
Endif	

RestArea(aAreaSN3)
RestArea(aArea)
	     
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA010PrvVld³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 08/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida preenchimento dos campos necessarios para Provisao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ FA010PrvVld(cProvis)			                                ³±±
±±³Parametros³ cMargem -> Código da regra de margem gerencial               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA010PrvVld(cProvis)

Local lRet		:= .F.
Local cRevPrv	:= ""

//PRV
//Verifica implementacao do controle de provisao
Local lProvis := If(FindFunction("AFPrvAtf"),AFPrvAtf(),.F.)

DEFAULT cProvis := ""

//Se os campos referente a Provisao estiverem em branco
If !lProvis .or. Empty(cProvis) 
	lRet := .T.
Else
	cRevPrv := IIf(FindFunction("AF490GetRev"),AF490GetRev(cProvis,.F.),"")	

	FNU->(dbSetOrder(1))
	If !(FNU->(MsSeek(xFilial("FNU")+cProvis+cRevPrv)))
		Help("  ",1,"NOPROVIS",,STR0067,1,1)	//"Controle de Provisão não cadastrado"
		lRet := .F.
	ElseIf FNU->FNU_MSBLQL == "1"  //Bloqueado
		Help("  ",1,"PROVISBLQ",,STR0069,1,1)		//"Controle de provisão bloqueado para uso. Utilize outro controle de provisão"
		lRet := .F.
	ElseIf (FNU->FNU_STATUS $ "0/3")  //1 = Ativo; A = Pendente Realizacao
		Help("  ",1,"PROVISATV",,STR0068,1,1)		//"Controle de provisão possui status que não permite relacionamento de bens de execução. Apenas controles de provisão com status Ativo ou Pendente Realização podem ser relacionadas a um imobilizado."
		lRet := .F.
	Else	
		lRet := .T.
	Endif
Endif

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010GrvAVP³ Autor ³ Alvaro Camillo Neto    ³ Data ³ 22/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010GrvAVP(lContabiliza,nTotal,nHdlPrv,cLoteAtf)
Local cIdProcAVP := ""
Local cTipoSLD     := SN3->N3_TPSALDO
Local aRet       := {0,0}
Local nPosAVP    := 0
Local nPosTipo   := 0
Local nPosTipSld := 0
Local nX         := 0
Local aAux       := {}
Local nValRlz    := 0

Local cTypes10		:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Obtenho o ID de processo
cIdProcAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)
//Gravo o movimento de constituicao do AVP pela inclusao do bem
AfGrvAvp(cFilAnt,"1",SN1->N1_INIAVP,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,SN3->N3_VORIG1,lContabiliza,@nTotal,@nHdlPrv,cLoteAtf,SN3->(RECNO()),cIdProcAVP,/*aRecCtb*/,/*lBxTotal*/,SN4->N4_IDMOV)


If Type('lAtfAuto')== "L" .And. lAtfAuto .And. Type('aAutoItens')== "A"
	aAVPMan := aClone(aAutoItens)

	For nX := 1 to Len(aAVPMan)
		aAux       := aAVPMan[nX]
		nPosTipSld := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TPSALDO'})
		nPosTipo   := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TIPO'})
		nPosAVPRZ  := ascan(aAux,{|x| Alltrim(x[1]) == 'N3AVPREAL'})
		If nPosTipSld > 0 .And. nPosAVPRZ > 0
			If Alltrim(aAux[nPosTipSld][2]) == Alltrim(cTipoSLD) .And. Alltrim(aAux[nPosTipo][2]) $ ("10" + cTypes10)
				nValRlz := aAux[nPosAVPRZ][2]
				Exit
			EndIf
		EndIf
	Next nX
	
	If nValRlz > 0
		//Gravo o movimento de realização do AVP pela inclusao do bem
		//a taxa será zero, pois o valor foi informado
		AfGrvAvp(cFilAnt,"2",SN1->N1_INIAVP,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,nValRlz,lContabiliza,@nTotal,@nHdlPrv,cLoteAtf,SN3->(RECNO()),cIdProcAVP,/*aRecCtb*/,/*lBxTotal*/,SN4->N4_IDMOV,/*nValPres*/,/*cRotina*/,/*cArquivo*/,/*nRecFNF*/,/*lCvMtdDpr*/,/*cIndAvp*/,/*cPerInd*/,0.0,/*dDtExecAVP*/)

	EndIf
EndIf

//Confirmo o ID do processo nas tabelas de controle
ConfirmSX8()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ACHSC( cFieldTarget )

Local nI		:= 0
Local nPosField	:= aScan( aHeader, {|x| x[2] == cFieldTarget} )
Local cItem		:= &(ReadVar())

If nPosField > 0
	For nI := 1 to Len( aCols )
			aCols[nI][nPosField] := cItem
	Next nI
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ACHCV( cFieldTarget )

Local nI		:= 0
Local nPosField	:= aScan( aHeader, {|x| x[2] == cFieldTarget} )
Local ccLASSE	:= &(ReadVar())

If nPosField > 0
	For nI := 1 to Len( aCols )
			aCols[nI][nPosField] := cClasse
	Next nI
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ATpBm ºAutor  ³Microsiga           º Data ³  02/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do Tipo de Bem                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ATpBm()

Local cTab := ""
Local lRet := .T.

If !Empty(M->N1_TPBEM)
	If Empty(M->N1_TPCUSTD)
		cTab := 'GF'
	Else
		cTab := 'GE'
	EndIf
	
	lRet := ExistCpo("SX5",cTab+M->N1_TPBEM)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010ACMntºAutor  ³Microsiga           º Data ³  27/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da digitação do código do bem                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010ACMnt()

Local lRet := .T.

If !Empty(M->N1_CODBEM)
	dbSelectArea("ST9")
	ST9->(dbSetOrder(1))
	ST9->(dbGoTop())
	
	If !ST9->(dbSeek(xFilial("ST9")+M->N1_CODBEM))
		lRet := .F.
		Help(" ",1,"REGNOIS")		
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA010A  ºAutor  ³Microsiga           º Data ³  02/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AApol()

Local lRet := .T.

If !Empty(M->N1_APOLICE)
	dbSelectArea("SNB")
	SNB->(dbSetOrder(1))
	SNB->(dbGoTop())
	
	If !SNB->(dbSeek(xFilial("SNB")+M->N1_APOLICE))
		lRet := .F.
		Help(" ",1,"REGNOIS")		
	EndIf
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} AF010VExc
Valida a possibilidade de se excluir um imobilizado

@author pequim

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF010VExc(lHelp,lLote)

Local aArea 	:= GetArea()
Local lAtfa460  := IsInCallStack("ATFA460") .or. IsInCallStack("F460DELPRV")
Local cQuery	:= ""
Local cChaveSNN := ""  
Local lRet		:= .T.	 
Local nSaveSx8Len := GetSx8Len()

DEFAULT lHelp		:= .T.
DEFAULT lLote		:= .T.

If ExistBlock("AF010EXC")
	lRet:= ExecBlock("AF010EXC",.F.,.F.)
EndIf

//Não Altera bens Bloqueados
If SN1->N1_STATUS $ '2/3'
	If lHelp
		Help(" ",1,"AF010BLOQ")
		lRet := .F.
	EndIf
EndIf

If ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, lHelp ) .and. !lAtfa460 
	lRet := .F.
EndIf

//Não exclui bens relacionados a Planejamento de Aquisição.
dbSelectArea("SNN") 
cChaveSNN:=IndexKey(2)
If AllTrim(cChaveSNN) == "NN_FILIAL+NN_CODEFTV+NN_ITMEFTV+NN_CODIGO+NN_ITEM"
	dbSetOrder( 2 )
	If MsSeek(xFilial("SNN")+SN1->N1_CBASE+SN1->N1_ITEM)
		If lHelp
			Help(" ",1,"AF010PLAT",,STR0087,1,0)	//"Este Ativo esta associado a um Planejamento de Aquisição e não pode ser excluido."
		Endif
		lRet := .F.
	EndIf               
EndIf

dbSelectArea("SN1")
//Não exclui bens relacionados a controle de provisão
If !Empty(SN1->N1_PROVIS) .and. !lAtfa460
	If lHelp
		Help(" ",1,"AF010PRV",,STR0072,1,0)	//'Este Ativo esta associado a controle de provisao e não pode ser excluido.'
	Endif
	lRet := .F.
EndIf
     
//Não exclui bens relacionados a Base instalada (SIGATEC)
If lRet .And. AliasInDic("AA3")
	If Select("TRBAA3") > 0
		dbSelectArea("TRBAA3")
		dbCloseArea()
	Endif

	cQuery := "SELECT COUNT(*) RECAA3 FROM "
	cQuery += RetSqlName("AA3") + " AA3 "
	cQuery += " WHERE "                                    
	cQuery += "AA3_FILIAL = '"+xFilial("AA3")+"' AND "
	cQuery += "AA3_CBASE = '" + SN1->N1_CBASE + "' AND "
	cQuery += "AA3.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBAA3",.F.,.T.)

	If TRBAA3->RECAA3 > 0
		lRet := .F.  
		If lHelp
			Help(" ",1,"AF010BASE") // Este Ativo esta associado a base instalada, e não pode ser excluido.   
		Endif
	Endif
	TRBAA3->(dbCloseArea())							
EndIf        

//Verifica se o ativo foi gerado a partir de um custo de emprestimo
If lRet .and. AFVCustEmp(SN1->N1_CBASE,SN1->N1_ITEM,lHelp)
	lRet := .F.
EndIf

//Nao permite a exclusão de bens com CIAP associado.
dbSelectArea("SF9")
dbSetOrder(1)
If lRet .AND. (!Empty(SN1->N1_CODCIAP) ) .AND. ( MsSeek(xFilial("SF9")+SN1->N1_CODCIAP) )
	If !IsBlind()
		lRet := MsgYesNo(STR0073 + SN1->N1_CODCIAP +STR0075  ,STR0074)//""O Bem possui um CIAP associado deseja Continuar a exclusão ?"
	Else
		lRet := .F.
	Endif
Endif

If lRet .and. SN1->N1_FILIAL != xFilial("SN1")
	If lHelp
		HELP(" ",1,"A000FI")
	Endif
	lRet  := .F.
	xRet := .T.
Endif

//Nao permite exclusao de bem cadastrado via SIGAMNT	
If lRet .And. !IsInCallStack( "AF060ExcAu" )
	ST9->(dbSetOrder(1))
	IF ST9->(dbSeek(xFilial()+SN1->N1_CBASE))
		If lHelp
			Help(" ",1,"AF010EXAMNT",,STR0013,1,0)//'Este Ativo esta associado a um bem cadastrado no SIGAMNT.'
		Endif
		lRet  := .F.
		xRet := .T.
	Endif
Endif		

//Verifica se o bem possui AVP apropriado
//Neste caso, o bem não podera ser excluido, mas apenas baixado
If lRet
	FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
	IF FNF->(dbSeek(xFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)+'2'+'1'))
		Help(" ",1,"AF010EXAVP",,STR0046,1,0)//'Este Ativo possui movimentos de aproppriação AVP e não poderá ser excluido.'
		lRet  := .F.
		xRet := .T.
	Endif
Endif

//Verifica se o bem foi gerado por constituição de provisão
If lRet .and. Alltrim(SN1->N1_ORIGEM) == 'ATFA460' .and. !lAtfa460
	If lHelp
		Help(" ",1,"AF010A460E",,STR0049 ,1,0) //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo somente poderá ser cancelado a partir do processo que o gerou'
	Endif		
	lRet  := .F.
	xRet := .T.
Endif	

//Verificacao de possibilidade de deleção
If lRet .and. !Af010VldDel("SN3",,lHelp)
	If !lLote
		While GetSx8Len() > nSaveSx8Len
			RollBackSX8()
		EndDo
	Endif	
	lRet  := .F.
	xRet := .T.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MaxTxDegr   ³ Autor ³ Norberto M Melo       ³ Data ³01/06/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Taxa Máxima de Depreciação que via de regra deverá ser infor  ³±±
±±³          ³ mada no cadastro de grupos, porém na falta deste cadastro     ³±±
±±³          ³ será considerado o valor informado no N3                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprL1 - Aplicar o coeficiente sobre a taxa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com cinco elementos contendo a taxa respectiva de cada  ³±±
±±³          ³ moeda.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA      ³ Programador   ³ Manutencao Efetuada                           ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaxTxDegr( lUsaCoefic )

Local aMaxTxDegr:= IIf(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} ) //Valor de Retorno
Local aAreaNG	:= SNG->( GetArea( ) )		//Tabela de Grupos
Local i 		:= 0								//Contador - Auxiliar
Local nCoefici	:= 0

SNG->( dbSetOrder( 1 ) )
SNG->( DBSeek( xFilial( "SN1" ) + SN1->N1_GRUPO ) )
for i := 1 to Len( aMaxTxDegr )
	if !SNG->( EOF() )
		aMaxTxDegr[ i ] := SNG->&( IIf(i>9,"NG_TXDEP","NG_TXDEPR") + Alltrim(Str(i)) )
	else
		aMaxTxDegr[ i ] := SN3->&( IIf(i>9,"N3_TXDEP","N3_TXDEPR") + Alltrim(Str(i)) )
	endif

	if lUsaCoefic
		aMaxTxDegr[ i ] *= IIf( SN3->N3_COEFICI > 0,SN3->N3_COEFICI, IIf( SNG->NG_COEFICI > 0, SNG->NG_COEFICI,1 ) )
	endif

Next i

SNG->( RestArea( aAreaNG ) )
Return aMaxTxDegr

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ PrzTotPrev  ³ Autor ³ Norberto M Melo       ³ Data ³01/06/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tempo total para a depreciação em anos                        ³±±
±±³          ³ Se não informada através de N1_PRZDEPR efetua um cálculo utili³±±
±±³          ³ zando a taxa anual cadastrada no N3                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor numérico representado a quantidade em anos.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA      ³ Programador   ³ Manutencao Efetuada                           ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PrzTotPrev( cMoedaATF )

Local 	nPrzTotPrev	:= 1	//Valor de Retorno

If (cPaisLoc == "PTG")
	if Empty( SN1->N1_PRZDEPR )
		nPrzTotPrev := 100 / SN3->&(IIf(Val(cMoedaATF)>9,"N3_TXDEP","N3_TXDEPR") + cMoedaATF)
	endif
endif

Return nPrzTotPrev

#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOXDIV.CH"

#Define BMP_CHK    "NOTE_PQ"
#Define BMP_INCL   "PCOBRANCO"

#Define COL_EDIT aScan(aAuxHeader,{|x| AllTrim(x[2])=="AK2_ALTER"})

STATIC nSaveSX8		:= 0
Static aLineNew		:=	{}
Static nQtdEntid
Static aClassOrc
Static _TamValor1   := NIL
Static oHashAK6  	:= Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoLoad   ³ Autor ³ Protheus Controladoria³ Data ³ 01-01-2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes e consistencias de abertura do ambiente           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoLoad()

Local cSinc := SuperGetMV("MV_PCOSINC",.T.,"1")

PCODefLoad() // Funcao do fonte PCOXLOAD.PRW

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAtuPlan³ Autor ³ Edson Maricate        ³ Data ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAddPlan(cOrcame,cVersao,cCO,cArquivo,nNivelAtu,nNivelMax,aExpand,lUser,cFiltro,cAK3RCV,lFiltroAK3)

Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
Local bBlock	:= ErrorBlock()
Local aProcForm	:= {}, cBlock := ""
Local nx
Local ny
Local lFilho	:= .F.
Local lHaveStr	:= .F.
Local aRecPai
Local aStruAK3      := {}
Local cAliasAK3     := ""
Local cCALLAK3      := ""
Local cQuery        := ""
Local lFiltroCall   := .F.
Local nLoop         := 0

DEFAULT lFiltroAK3 := .T.

DEFAULT cAK3RCV := "AK3"

If nNivelMax >= Val((cAK3RCV)->AK3_NIVEL) .And. (cAK3RCV)->(&(cFiltro))
	If PcoChkUser(cOrcame,cCO,(cAK3RCV)->AK3_PAI,1,"ESTRUT",(cAK3RCV)->AK3_VERSAO)
		If Val((cAK3RCV)->AK3_NIVEL)+1 > nNivelAtu
			nNivelAtu := Val((cAK3RCV)->AK3_NIVEL)+1
		EndIf
		RecLock(cArquivo,.T.)
		aSize(aProcForm, 0)
		
		For nx := 1 to Len(aAuxCps)
			If aAuxCps[nx][1]=="AK3_DESCRI"
				If (cAK3RCV)->(FieldPos(aAuxCps[nx][2])) > 0
					FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL((cAK3RCV)->AK3_NIVEL)-1)*5)+(cAK3RCV)->(FieldGet(FieldPos(aAuxCps[nx][2]))))
				Endif
			ElseIf Substr(aAuxCps[nx][1],1,1)=="%"
				aAdd(aProcForm,nx)
			Else
				If Substr(aAuxCps[nx][1],1,1)=="$"
					FieldPut(FieldPos(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),&(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)+"(3,'AK3',AK3->(RecNo()))"))
				Else
					If Substr(aAuxCps[nx][1],1,1)!="|"
						If (cAK3RCV)->(FieldPos(aAuxCps[nx][2])) > 0
							FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),(cAK3RCV)->(FieldGet(FieldPos(aAuxCps[nx][2]))))
						Endif
					Endif
				EndIf
			EndIf
		Next

		bErro := ErrorBlock({|e| ChecErro(e)})
		For nx := 1 to Len(aProcForm)
			nCntLet := 0
			nCount := 0

			For ny := 1 to Len(aAuxCps)
				If Substr(aAuxCps[ny][1], 1, 1) # "|"
					nCntLet++
					If nCntLet > 26
						nCntLet	:= 1
						nCount++
					EndIf
					If nCount > 0
						If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
							&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny+1))
						Else
							&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny))
						EndIf
					Else
						If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
							&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny+1))
						Else
							&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny))
						EndIf
					EndIf

				EndIf
			Next

			If RepVar(@cBlock, Substr(aAuxCps[aProcForm[nx]][1],58,60))==-1
				HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[aProcForm[nx]][1],2,12)+"="+cBlock)
			EndIf

			Begin Sequence
				FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)), &(cBlock))

				// recalcula as formulas anteriores (somente as formulas)
				// este recalculo e necessario para formulas que utilizam
				// formulas ainda nao calculadas
				// o recalculo deve ser feito apos o calculo da formula atual
				cBlock := ""
				nCntLet := 0
				nCount := 0

				For ny := 1 to Len(aAuxCps)
					If Substr(aAuxCps[ny][1], 1, 1) # "|"
						nCntLet++
						If nCntLet > 26
							nCntLet	:= 1
							nCount++
						EndIf

						If Substr(aAuxCps[ny][1],1,1)=="%"
							If RepVar(@cBlock, Substr(aAuxCps[ny][1],58,60))==-1
								HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[ny][1],2,12)+"="+cBlock)
								MsUnlock()
								Return
							EndIf
						Else
							Loop
						EndIf
						If nCount > 0
							&(Chr(64+nCntLet)+Chr(48+nCount)) := &(cBlock)
						Else
							&(Chr(64+nCntLet)) := &(cBlock)
						EndIf

						FieldPut(FieldPos("FORM"+StrZero(ny,2,0)), &(cBlock))
					EndIf
				Next
				Recover
				MsUnlock()
				ErrorBlock(bBlock)
				Return
			End Sequence
						//FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)),&(cBlock))
		Next
		ErrorBlock(bBlock)

		If lFiltroAK3
			(cArquivo)->RECNO := AK3->(RecNo())
		Else
			(cArquivo)->RECNO := ( cAK3RCV )->AK3RECNO
		EndIf

		(cArquivo)->ALIAS := "AK3"
		MsUnlock()
		aRecPai := (cArquivo)->(GetArea())
		If lUser
			dbSelectArea("AKG")
			dbSetOrder(1)
			MsSeek(xFilial()+cOrcame+cCO)
			While !Eof() .And. AKG->AKG_FILIAL+AKG->AKG_ORCAME+AKG->AKG_CO==xFilial("AKG")+cOrcame+cCO
				RecLock(cArquivo,.T.)
				(cArquivo)->RECNO := AKG->(RecNo())
				(cArquivo)->ALIAS := "AKG"
				For nx := 1 to Len(aAuxCps)
					If aAuxCps[nx][1]=="AK3_DESCRI"
						FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL((cAK3RCV)->AK3_NIVEL)-1)*5)+UsrRetName(AKG->AKG_USER))
					EndIf
				Next
				MsUnlock()
				dbSelectArea("AKG")
				dbSkip()
			End
		EndIf
		RestArea(aRecPai)
	EndIf
EndIf

aRecPai := (cArquivo)->(GetArea())
dbSelectArea("AK3")
dbSetOrder(2)

aStruAK3 := AK3->( dbStruct())

cAliasAK3 := GetNextAlias()

cQuery := "SELECT AK3.*,AK3.R_E_C_N_O_ AK3RECNO FROM " + RetSqlName( "AK3" ) + " AK3 "
cQuery += "WHERE "
cQuery += "AK3.AK3_FILIAL='" + xFilial( "AK3" ) + "' AND "
cQuery += "AK3.AK3_ORCAME='" + cOrcame          + "' AND "
cQuery += "AK3.AK3_VERSAO='" + cVersao          + "' AND "
cQuery += "AK3.AK3_PAI='"    + cCO              + "' AND "
cQuery += "AK3.D_E_L_E_T_=' ' "
cQuery += "ORDER BY " + SqlOrder( AK3->( indexkey() ) )

cQuery := ChangeQuery( cQuery )

dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), cAliasAK3, .F., .T. )

TcSetField( cAliasAK3, "AK3RECNO", "N", 12, 0 )

// Ajusta os demais campos da estrutura

AEval( aStruAK3, { |x| If( x[2] <> "C" .And. x[2] <> "M", TcSetField(cAliasAK3,x[1],x[2],x[3],x[4]), ) } )

aSize(aStruAK3, 0)

// Verifica se na proxima chamada existe filtro ativo

lFiltroCall := ( AllTrim( Upper( cFiltro ) ) <> ".T." )

// Se existe filtro, o alias da proxima chamada sera o AK3 real

If lFiltroCall
	cCallAK3 := "AK3"
Else
	cCallAK3 := cAliasAK3
EndIf

While !( cAliasAK3 )->( Eof() )

	// Se existe filtro, deve posicionar no AK3 real

	If lFiltroCall
		AK3->( dbGoto( ( cAliasAK3 )->AK3RECNO ) )
		dbSelectArea( "AK3" )
	EndIf

	lHaveStr := .T.
	If nNivelMax >= Val( (cAliasAK3)->AK3_NIVEL)
		If aExpand == Nil .Or.Empty(aExpand).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )>0 .And. aExpand[aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )][2]).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )<=0).Or.nNivelMax<10000
			lFilho := .T.
			PcoAddPlan((cAliasAK3)->AK3_ORCAME,(cAliasAK3)->AK3_VERSAO,(cAliasAK3)->AK3_CO,cArquivo,@nNivelAtu,@nNivelMax,aExpand,lUser,cFiltro,cCallAK3, lFiltroCall )
		EndIf
	Else
		Exit
	EndIf

	( cAliasAK3 )->( dbSkip())
EndDo

// Exclui a area de trabalho da query

( cAliasAK3 )->( dbCloseArea() )
dbSelectArea( "AK3" )

If lHaveStr
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"AK1"
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "+"
		MsUnlock()
	EndIf
EndIf
If lFilho
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"AK1"
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "-"
		MsUnlock()
	EndIf
	If aExpand != Nil
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XK3_CO,.T.})
	EndIf
EndIf

RestArea(aAreaAK3)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanCel³ Autor ³ Edson Maricate        ³ Data ³ 23-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o conteudo caracter de acordo com as configuracoes    ³±±
±±³          ³de exibicao da classe.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanCel(nVal,cClasse,nTamanho,cPicture)
Local cTexto		:= ""
Local aArea
Local aAreaAK6
Local nX 			:= 0
Local cBuscaAK6    	:= ""
Local lFoundAK6 	:= .F.
Local aRetAK6   	:= {}

If _TamValor1 == NIL
	_TamValor1 := TamSx3("AKD_VALOR1")[1]
EndIf

DEFAULT nVal    := 0
DEFAULT cClasse := "|"
DEFAULT nTamanho:= _TamValor1   //variavel static para nao ficar chamando TamSx3 a cada chamada desta funcao
DEFAULT cPicture:= ""

cBuscaAK6 := cEmpAnt + xFilial("AK6") + cClasse

//procura no cache (aClassOrc) das pictures da classe orcamentaria
If aClassOrc != NIL .And. ValType(aClassOrc) == "A"
	lFoundAK6 := HMGet(oHashAK6, cBuscaAK6, @aRetAK6) //Faz a busca da chave dentro do Objeto, ele vai retornar o logico e o vetor com a linha encontrada

	If lFoundAK6
		cPicture := aRetAK6[1][2]
	Else
		aSize(aClassOrc, 0)
		aClassOrc := NIL
		
		aSize(aRetAK6, 0)
		HMClean(oHashAK6) //Limpa o HashMap
		FreeObj(oHashAK6)
	EndIf
EndIf

If aClassOrc == NIL  //se nao inicializado array monta cache das pictures varrendo todo AK6
	aArea		:= GetArea()
	aAreaAK6	:= AK6->(GetArea())

	dbSelectArea("AK6")
	dbSetOrder(1)
	If MsSeek(xFilial())
		aClassOrc := {}
	EndIf

	If cClasse == "|"   //se nao passado classe e atribuido o default
		If aClassOrc == NIL
			aClassOrc := {}
		EndIf

		nX := nTamanho //tamSx3("AKD_VALOR1")[1]
		//********************************
		// Monta Picture de acordo com o *
		// campo AKD_VALOR1.			 *
		//********************************
		While nX>0
			If nX>=4
				@cPicture := "999" + cPicture
				nX -= 3
				If nX > 1
					@cPicture := "," + cPicture
					nX -= 1
				Else
					nX := 0
				EndIf
			Else
				@cPicture := Replicate("9",nX) + cPicture
				nX := 0
			EndIf
		EndDo
		@cPicture := "@E " + cPicture

		aAdd( aClassOrc, { cEmpAnt+xFilial("AK6")+cClasse, cPicture, ""/*AK6->AK6_FORMAT*/, ""/*AK6->AK6_SYMBOL*/} )

	EndIf

	While AK6->( !Eof() .And. AK6_FILIAL == xFilial("AK6") )
		If Empty(AK6->AK6_CUSTOM)
			If AK6->AK6_FORMAT $ "1/3"
				nX := nTamanho   //tamSx3("AKD_VALOR1")[1]
				If AK6->AK6_DECIMA > 0
					nX -= (AK6->AK6_DECIMA + 1 )
				EndIf
				If AK6->AK6_FORMAT $ "3/4" .And. nVal < 0
					nX -= 1
				Endif
				If !Empty(AK6->AK6_SYMBOL)
					nX -= Len(Alltrim(AK6->AK6_SYMBOL)) + 1
				EndIf
				cPicture := "@E " + Replicate("9",nX )
				If AK6->AK6_DECIMA > 0
					cPicture += "."+Replicate("9",AK6->AK6_DECIMA)
				EndIf
			Else
				nX := nTamanho //tamSx3("AKD_VALOR1")[1]
				If AK6->AK6_DECIMA > 0
					@cPicture := "."+Replicate("9",AK6->AK6_DECIMA)
					nX -= (AK6->AK6_DECIMA + 1 )
				EndIf
				If AK6->AK6_FORMAT $ "3/4" .And. nVal < 0
					nX -= 1
				Endif
				If !Empty(AK6->AK6_SYMBOL)
					nX -= Len(Alltrim(AK6->AK6_SYMBOL)) + 1
				EndIf
				//********************************
				// Monta Picture de acordo com o *
				// campo AKD_VALOR1.			 *
				//********************************
				While nX>0
					If nX>=4
						@cPicture := "999" + cPicture
						nX -= 3
						If nX > 1
							@cPicture := "," + cPicture
							nX -= 1
						Else
							nX := 0
						EndIf
					Else
						@cPicture := Replicate("9",nX) + cPicture
						nX := 0
					EndIf
				EndDo
				@cPicture := "@E " + cPicture
			EndIf
		Else
			@cPicture := AK6->AK6_CUSTOM
		EndIf

		aAdd( aClassOrc, { cEmpAnt+xFilial("AK6")+AK6->AK6_CODIGO, cPicture, AK6->AK6_FORMAT, AK6->AK6_SYMBOL } )

		AK6->( dbSkip() )

	EndDo

	RestArea(aAreaAK6)
	RestArea(aArea)

	If aClassOrc != NIL
		oHashAK6 := tHashMap():New() //Cria o Objeto do Hash Map
		oHashAK6 := AToHM(aClassOrc, 1) //Converto o Vetor no Objeto Hash e indico qual sera a chave para a busca

		lFoundAK6 := HMGet(oHashAK6, cBuscaAK6, @aRetAK6) //Faz a busca da chave dentro do Objeto, ele vai retornar o logico e o vetor com a linha encontrada

		If lFoundAK6
			cPicture := aRetAK6[1][2]
		EndIf
	EndIf

EndIf

cTexto	:= Transform(nVal,cPicture)

If lFoundAK6
	If  aRetAK6[1,3] $ "3/4" .And. nVal < 0
		cTexto := "("+AllTrim(StrTran(cTexto,"-",""))+")"
	EndIf
	If !Empty( aRetAK6[1,4])
		cTexto := Alltrim( aRetAK6[1,4]) + " " + cTexto
	EndIf
EndIf

Return cTexto

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoRevisa³ AUTOR ³ Edson Maricate         ³ DATA ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao de geracao da nova versao da Planilha Orcamentaria    ³±±
±±³          ³ utilizada na Revisao da Planilha.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PcoRevisa                                                    ³±±
±±³_DESCRI_  ³ Funcao de geracao da nova versao da Planilha Orcamentaria    ³±±
±±³_DESCRI_  ³ utilizada na Revisao da Planilha.                            ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada para criacao das tabelas    ³±±
±±³          ³ referentes a planilha orcamentaria na revisao da mesma.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : RecNo do AK1 da Planilha                             ³±±
±±³_PARAMETR_³ ExpN2 : Codigo do evento                                     ³±±
±±³_PARAMETR_³         [1] Revisao                                          ³±±
±±³_PARAMETR_³         [2] Simulacao                                        ³±±
±±³_PARAMETR_³         [3] Exclusao                                         ³±±
±±³_PARAMETR_³ ExpC3 : Codigo da versao origem (Opcional)                   ³±±
±±³_PARAMETR_³ ExpC4 : Codigo da versao destino (Opcional)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoRevisa(nRecAK1,nEvento,cVerAtu,cNextVer,lIncrNext,lRevisao,lSimulac,lGravaAKE)

Processa({||AuxRevisa(nRecAK1,nEvento,cVerAtu,@cNextVer,lIncrNext,lRevisao,lSimulac,lGravaAKE)})

Return cNextVer

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRevisa³ Autor ³ Edson Maricate         ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma no revisao na Planilha Orcamentaria                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO, PCOXFUN --> PCOREVISA()                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxRevisa(nRecAK1,nEvento,cVerAtu,cNextVer,lIncrNext,lRevisao,lSimulac,lGravaAKE)
Local aArea			:= GetArea()
Local aAreaAK1		:= AK1->(GetArea())
Local aAreaAK2		:= AK2->(GetArea())
Local aAuxCpy		:= {}
Local aAliasCpy		:= {"AK2","AK3"}
Local aCpyRlz	:= {}
Local aAuxArea
Local aEntidades	:= Bco_Entidades(aClone({"AKE","AK3"}))
Local aRecAK3		:= {}
Local aRecNew		:= {}
Local aDocs			:= {}
Local aChavDoc		:= {}
Local aRecACB		:= {}
Local aRecAC9		:= {}
Local nx			:= 0
Local ny			:= 0
Local nRecNew		:= 0
Local bCampo		:= {|n| FieldName(n) }
Local cVerRlz		:= ""
Local cCodEnt		:= ""
Local cChaveAKE		:= ""
Local cQuery		:= ""
Local cAliasTmp		:= ""
Local cMemoAK3		:= ""
Local cCpo			:= ""
Local lPCOCOP		:= ExistBlock("PCOCOP")
Local lPCOENTREV 	:= ExistBlock("PCOENTREV")
Local aNewEntid 	:={}
Local nThread       := SuperGetMv("MV_PCOTHRD",.T.,10)
Local nMultThread   := SuperGetMv("MV_PCOMTHR",.T.,0)   // Default 0 - sem multithread, 1 - com multthread
Local lProc         := If( (Alltrim(Upper(TcGetDb())) $ "MSSQL7|ORACLE|DB2|POSTGRES"),.T., .F.) .and. nMultThread == 1

dbSelectArea("AK1")
MsGoto(nRecAK1)
cVerRlz				:= AK1->AK1_VERSAO
DEFAULT nEvento		:= 1
DEFAULT cVerAtu		:= AK1->AK1_VERSAO
DEFAULT cNextVer	:= Soma1(AK1->AK1_VERSAO)
DEFAULT lIncrNext	:= .T.
DEFAULT lGravaAKE   := .F.
//Caso o nro de threads seja maior q 2 fazer com

If ExistBlock("PCOENTREV")
	aNewEntid := ExecBlock("PCOENTREV",.F.,.F.)
	If ValType(aNewEntid) == "A"  .And. Len(aNewEntid)>0
   		For nx	:= 1 To Len(aNewEntid)
			aAdd(aAliasCpy,aNewEntid[nx])
		Next nx
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a versao nao existe e pega a proxima                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AKE")
dbSetOrder(1)

If nEvento == 1 .And. lIncrNext
	While dbSeek(xFilial()+AK1->AK1_CODIGO+cNextVer)
		cNextVer := Soma1(cNextVer)
	End
EndIf

Do Case
	Case nEvento == 1 .Or. nEvento == 2
		ProcRegua(((Len(aAliasCpy)+Len(aCpyRlz))*2))
		begin transaction
		//atualizar AK1-Planilha orcamentaria
		If nEvento == 1
			RecLock("AK1",.F.)
			AK1->AK1_VERREV	:= cNextVer
			AK1->AK1_STATUS := "2"
			MsUnlock()
		EndIf
		//cria registro no AKE-Controle de Revisoes
		If nEvento == 1 .And. lGravaAKE
			RecLock("AKE",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AKE->AKE_FILIAL := xFilial("AKE")
			AKE->AKE_REVISA := AK1->AK1_VERREV
			MsUnlock()
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica e deleta os registros da proxima versao                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AK1->AK1_CODIGO+cNextVer)
			While !Eof() .And. FieldGet(FieldPos(aAliasCpy[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_VERSAO"))==;
								xFilial(aAliasCpy[ny])+;
								AK1->AK1_CODIGO+;
								cNextVer
				If aAliasCpy[ny]=="AK2"
					If lSimulac
						PcoDetLan("000252","03","PCOA100",.T.)
					ElseIf lRevisao
						PcoDetLan("000252","02","PCOA100",.T.)
					EndIf
				EndIf
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AK1->AK1_CODIGO+cNextVer)
			While !Eof() .And. FieldGet(FieldPos(aCpyRlz[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aCpyRlz[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aCpyRlz[ny]+"_VERSAO"))==;
								xFilial(aCpyRlz[ny])+;
								AK1->AK1_CODIGO+;
								cNextVer
				RecLock(aAlias[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		end transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria os registros da nova versao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProc
			// Faz a inserção no AK2 e AK3 por procedures se estas foram criadas
			//(cCodigoAK1, cVerAtu, cNextVer, cArq, aProc, cArqTemp  )
			ConoutR("Vai chamar a Procedure  " + time())
			lProc := PcoProcRev(AK1->AK1_CODIGO, cVerAtu, cNextVer, aAliasCpy, @aRecAK3, @aRecNew, lSimulac, lRevisao, lPCOCOP )    // pto de entrada
			If lProc
				ConoutR("Terminou a Procedure  " + time())
			Else
				ConoutR("vai fazer pelo padrao "+time())
			EndIf
		Endif
		///sem procedure
		If !lProc
			PcoIniLan("000252")
			For nY := 1 to Len(aAliasCpy) //Laco na AK2(Itens do orcamento) e AK3(Estrutura do orcamento)

				IncProc() //Incrementa valor na regua de progressao

				cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa query para obter todos os registros da tabela AK2 ou AK3³
				//³para geracao da nova revisao                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT * FROM " + RetSqlName( aAliasCpy[ny] )
				cQuery += " WHERE "
				cQuery += aAliasCpy[ny]+"_FILIAL='" + xFilial( aAliasCpy[ny] ) + "' AND "
				cQuery += aAliasCpy[ny]+"_ORCAME='" + AK1->AK1_CODIGO          + "' AND "
				cQuery += aAliasCpy[ny]+"_VERSAO='" + cVerAtu                  + "' AND "
				cQuery += " D_E_L_E_T_= ' ' "
				cQuery += " ORDER BY "
				cQuery += SqlOrder( (aAliasCpy[ny])->( indexkey() ) )

				cQuery := ChangeQuery( cQuery )

				dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

				While (cAliasTmp)->(!Eof())

					nRecNew := 0

					If lPCOCOP
						nRecNew := ExecBlock("PCOCOP",.F.,.F., {aAliasCpy[ny]})
					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Processo para obter o valor do campo AK3_MEMO³
						//³pois a query não retorna este campo          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aAliasCpy[ny] == "AK3"
							AK3->( DbGoTo( (cAliasTmp)->R_E_C_N_O_ ) )
							cMemoAK3 := AK3->AK3_MEMO
						EndIf

						RecLock(aAliasCpy[ny],.T.)

						For nX := 1 To FCount()

							cCpo := FieldName(nx)

							If cCpo == (aAliasCpy[ny]+"_VERSAO") //Tratamento para preencher o campo AK2_VERSAO ou AK3_VERSAO com a nova versao
								FieldPut(FieldPos(aAliasCpy[ny]+"_VERSAO"),cNextVer)
							ElseIf cCpo == (aAliasCpy[ny]+"_MEMO") //Tratamento para preencher o campo AK3_MEMO
								FieldPut(FieldPos(aAliasCpy[ny]+"_MEMO"),cMemoAK3)
							Else
								FieldPut(nx,(cAliasTmp)->&(cCpo)) //Copia o restante dos dados da versao atual para a nova versao
							EndIf

						Next nX
						(aAliasCpy[ny])->(MsUnlock())
						FkCommit()
						nRecNew := (aAliasCpy[ny])->(Recno()) //Obtem o recno do novo registro

					EndIf

					If aAliasCpy[ny]=="AK3"
						aAdd(aRecAK3, (cAliasTmp)->(Recno()))	//Armazena o recno da versao atual
						aAdd(aRecNew, nRecNew)					//Armazena o recno da nova versao
					EndIf
					If aAliasCpy[ny]=="AK2"
						AK2->(dbGoto(nRecNew))
						If lSimulac
							PcoDetLan("000252","03","PCOA100")
						ElseIf lRevisao
							PcoDetLan("000252","02","PCOA100")
						EndIf
					EndIf

				(cAliasTmp)->(dbSkip())
				EndDo

			(cAliasTmp)->(dbCloseArea())
			Next nY
			PcoFinLan("000252")
		EndIf
		//replicar banco de conhecimento
		DbSelectArea("AK1")
		MsGoto(nRecAk1)
		//posicionar em AKE para buscar os documentos da planilha
		dbSelectArea("AKE")
		dbSetOrder(1)
		cChaveAKE := AK1->AK1_CODIGO+cVerAtu
		dbSeek(xFilial("AKE")+cChaveAKE)

		aRecACB := {}
		aRecAC9 := {}
		cEntidade:="AKE"
		aChavDoc := aClone(aEntidades[1][2])
		cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
		cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
		MsDocArray( cEntidade, cCodEnt, , , aRecAC9 , 1, aRecACB)
		aAdd(aDocs, {cEntidade, nRecAK1, 0, aClone(aRecACB), aClone(aRecAC9)})

		dbSelectArea("AK3")
		For nY := 1 TO Len(aRecAK3)
			dbGoto(aRecAK3[nY])
			aRecACB := {}
			aRecAC9 := {}
			cEntidade:="AK3"
			aChavDoc := aClone(aEntidades[2][2])
			cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
			cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
			MsDocArray( cEntidade, cCodEnt, , , aRecAC9 , 1, aRecACB)
			aAdd(aDocs, {cEntidade, aRecAK3[nY], aRecNew[nY], aClone(aRecACB), aClone(aRecAC9)})
		Next //nY
		//copia os documentos para nova revisao
		PcoCopyDocs(aDocs, aEntidades, cVerAtu, cNextVer, lRevisao, lSimulac)

	Case nEvento == 3
		ProcRegua(Len(aAliasCpy)+Len(aCpyRlz))
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AK1->AK1_CODIGO+cVerAtu)
			While !Eof() .And. FieldGet(FieldPos(aAliasCpy[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_VERSAO"))==;
								xFilial(aAliasCpy[ny])+;
								AK1->AK1_CODIGO+;
								cVerAtu
				If aAliasCpy[ny]=="AK2"
					If lSimulac
						PcoDetLan("000252","03","PCOA120",.T.)
					ElseIf lRevisao
						PcoDetLan("000252","02","PCOA120",.T.)
					EndIf
				EndIf
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AK1->AK1_CODIGO+cVerAtu)
			While !Eof() .And. FieldGet(FieldPos(aCpyRlz[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aCpyRlz[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aCpyRlz[ny]+"_VERSAO"))==;
								xFilial(aCpyRlz[ny])+;
								AK1->AK1_CODIGO+;
								cVerAtu
				RecLock(aAlias[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
EndCase

RestArea(aAreaAK2)
RestArea(aAreaAK1)
RestArea(aArea)

Return cNextVer

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PCOA020TXT³ Autor ³ Edson Maricate        ³ Data ³ 22.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a formula do texto digitado esta OK.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA020TXT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA020 --> SX3                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PCOVldForm()

Local xResult
Local cForm:=&(ReadVar())
Local lRet:=.T.
Local aRetSyntax := {}
Local cLine := ""
Local lExec := .T.
Local nPos
Local lTxt
Local bBlock

aRetSyntax := ParAnalise(cForm)	// An lise estrutural de sintaxe

IF !empty(aRetSyntax[1])
	Help(" ",1,"ERR_FORM",,OemToAnsi( STR0002 + aRetSyntax[1]),3,0)  //"Estrutura Inconsistente : "
	Return .F.
Endif

If Alltrim(ReadVar()) $ "M->AKC_KEYREF|M->AKI_KEYREF"
	lRet := PcoVld_Key_Ref()
EndIf

For nPos:=1 to len(aRetSyntax[2])
	cLine	:= upper(aRetSyntax[2][nPos])
	If "M->" $ cLine .or. "U_" $ cLine
		lExec := .F.
	Endif
	If "EXECBLOCK" $ cLine .or. lTxt
		lExec :=.F.
	EndIf
	If "GDFIELDGET" $ cLine
		lExec :=.F.
	EndIf
	If "FWFLDGET" $ cLine
		lExec :=.F.
	EndIf
Next nX
If lExec
	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cForm
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ChecErro ³ Autor ³ Edson Maricate        ³ Data ³22.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina verificadora do erro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChecErro()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F./Nenhum                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCOA020 --> PCOA020TXT()                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION ChecErro(e)

Help(" ",1,"ERR_FORM",,e:Description,3,1)
BREAK

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ParAnalise³ Autor ³ J£lio Wittwer         ³ Data ³ 17.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza an lise estrutural de parƒmetros / delimitadores   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ParAnalise(cExpressao)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor [1] cStack -> Se preenchido, indica qual caracter na ³±±
±±³          ³ estrutura n„o est  coerente com a mesma.                   ³±±
±±³          ³ Vetor [2] aParam -> Array com os textos correspondentes    ³±±
±±³          ³ dentro das estruturas.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA080                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ expC1 = Texto a ser analisado.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ParAnalise(cTexto)
Local cStack:=""  , cAspas:=""
Local aSepFunc:={"()","[]","{}"}, aParam:={}
Local nPosAt:=1 , uLastPar:=1 , cPosAtual
Local uAbre , uFecha , cSeparador:=","
// Arranca os caracteres da esquerda se forem 'espa‡o' ou 'TAB'
While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
   cTexto:=right(cTexto,len(cTexto)-1)
EndDo
While nPosAt<=len(cTexto)
   cPosAtual:=substr(cTexto,nPosAt,1)
   If cPosAtual==chr(34) .or. cPosAtual==chr(39)	// Achou "ASPAS"
		cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
   Endif
   If empty(cAspas)			// Apenas analiza a estrutura caso nao esteja entre aspas
      uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
      uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
      If uAbre+uFecha>0		// Abriu ou Fechou uma estrutura
         If uAbre>0	// Abriu uma estrutura ! Acrescenta no STACK
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
         Else			// Fechou uma estrutura : Checa o STACK
            If right(cStack,1)==Left(aSepFunc[uFecha],1)	// Se fechou certo, tira do Stack
               cStack:=left(cStack,len(cStack)-1)
				Else	// Estrutura fechada incorretamente
					cStack:=right(aSepFunc[uFecha],1)
					EXIT
            Endif
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1
         Endif
      Else	// Verifica separador
			If cPosAtual==cSeparador
            aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            uLastPar:=nPosAt+1
         Endif
      Endif
   Endif
	nPosAt++
EndDo
IF !empty(cTexto) .and. len(aParam) == 0
	aadd(aParam,alltrim(cTexto))
Endif
cStack+=if(empty(cAspas),"",cAspas)
Return {cStack,aParam}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoRetCO³ Autor ³ Edson Maricate          ³ Data ³ 01-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o codigo do CO aplicando-se a configuração de mascara ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoRetCO(cCO,cCodMasc)
Local aArea		:= GetArea()
Local aAreaAK5	:= AK5->(GetArea())
Local cCodRet	:= cCO
Local cSeparador:= ""
Local cMascara	:= ""


If Empty(cCodMasc)
	cCodMasc := SuperGetMV("MV_PCOMASC",.F.,"")
	If cCo == AK5->AK5_CODIGO
		cCodMasc := AK5->AK5_MASC
	Else
		dbSelectArea("AK5")
		If IndexOrd() > 0
			dbSetOrder(1)
			If(dbSeek(xFilial("AK5")+cCo) .And. !Empty(AK5->AK5_MASC))
				cCodMasc := AK5->AK5_MASC
			EndIf
		EndIf
	EndIf
EndIf

If !Empty(cCodMasc)
	cMascara:= RetMasCtb(cCodMasc,@cSeparador)
	If !Empty(cMascara)
		cCodRet	:= MascaraCTB(cCO,cMascara,,cSeparador)
	EndIf
EndIf

RestArea(aAreaAK5)
RestArea(aArea)
Return cCodRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChk_CC ºAutor  ³Paulo Carnelossi    º Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito ao centro de   º±±
±±º          ³custo informado e vericacao dos direitos                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_CC(cArquivo, oGetDados, nLin)
Local nDireito, cCentroCusto, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "CCUSTO"
Local lRet := .F.
Local aAreaAK3 := AK3->(GetArea())
Local nCpoCC := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AK2_CC"})

If nCpoCC > 0  // Se campo AK2_CC ESTIVER EM USO VALIDA DIR USUARIO
	cOrcame := AK1->AK1_CODIGO

	dbSelectArea("AK3")
	dbGoto((cArquivo)->RECNO)
	cCO :=  (cArquivo)->XK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO

	If ReadVar() == "M->AK2_CC"
		cCentroCusto := M->AK2_CC
	Else
		cCentroCusto := oGetDados:aCols[nLin][nCpoCC]
	EndIf

	lRet := PcoCC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cCentroCusto,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T. //se campo AK2_CC == NAO USADO
EndIf

RestArea(aAreaAK3)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChk_IC ºAutor  ³Paulo Carnelossi    º Data ³  26/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito ao Item Conta- º±±
±±º          ³bil informado e vericacao dos direitos                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_IC(cArquivo, oGetDados, nLin)
Local nDireito, cItemCtb, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "ITMCTB"
Local lRet := .F.
Local aAreaAK3 := AK3->(GetArea())
Local nCpoIC   := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AK2_ITCTB"})


If nCpoIC > 0 // se campo AK2_ITCTB ESTIVER EM USO VALIDA DIREITO USUARIO
	cOrcame := AK1->AK1_CODIGO

	dbSelectArea("AK3")
	dbGoto((cArquivo)->RECNO)
	cCO :=  (cArquivo)->XK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO

	If ReadVar() == "M->AK2_ITCTB"
		cItemCtb := M->AK2_ITCTB
	Else
		cItemCtb := oGetDados:aCols[nLin][nCpoIC]
	EndIf

	lRet := PcoIC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cItemCtb,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T. // Se campo AK2_ITCTB == NAO USADO
EndIf

RestArea(aAreaAK3)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChk_CV ºAutor  ³Paulo Carnelossi    º Data ³  26/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito a classe de    º±±
±±º          ³valor informado e vericacao dos direitos                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_CV(cArquivo, oGetDados, nLin)
Local nDireito, cClasseValor, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "CLAVLR"
Local lRet := .F.
Local aAreaAK3 := AK3->(GetArea())
Local nCpoCV := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AK2_CLVLR"})


If nCpoCV > 0 // se campo AK2_CLVLR ESTIVER EM USO VALIDA DIREITO DO USUARIO

	cOrcame := AK1->AK1_CODIGO

	dbSelectArea("AK3")
	dbGoto((cArquivo)->RECNO)
	cCO :=  (cArquivo)->XK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO

	If ReadVar() == "M->AK2_CLVLR"
		cClasseValor := M->AK2_CLVLR
	Else
		cClasseValor := oGetDados:aCols[nLin][nCpoCV]
	EndIf

	lRet := PcoCV_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cClasseValor,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T.  // se campo AK2_CLVLR == NAO USADO
EndIf

RestArea(aAreaAK3)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChk_AcessoºAutor ³Paulo Carnelossi    º Data ³ 26/10/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito ao centro de   º±±
±±º          ³custo/item contabil/classe de valor informado e vericacao   º±±
±±º          ³dos direitos do usuario nas contas superior                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_Acesso(cArquivo, oGetDados, nLin)
Local lRet := .T.
Local nPosId	:=	aScan( oGetDados:aHeader, {|x|AllTrim(x[2])=="AK2_ID"})	// Posicao da Classe Orcamentaria no aCols
Local lIncluiLin := .F.
Local lViewModify := .F.
Local lModify := .F.
Local cChvLck := ""
Local aColAlt := {}
/*
Implementar para entidade e para CO
*/
dbSelectArea("AK3")
dbGoto((cArquivo)->RECNO)

If oGetDados:lNewLine
	aAdd(aLineNew, AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados:aCols[nLin][nPosID] )
EndIf

If Ascan( aLineNew, AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados:aCols[nLin][nPosID] ) > 0
	lIncluiLin := .T.
EndIf

If lIncluiLin .Or. oGetDados:aCols[nLin][nPosID] == PadR("*", Len(AK2->AK2_ID))
	lRet    := .T.
Else
    //somente entra quando em alteracao da linha
	cChvLck := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados:aCols[nLin][nPosID]
	lRet	:=	PcoLockAK2(cChvLck,,@lViewModify)
EndIf

If lRet
	lRet := PCOChk_CC(cArquivo, oGetDados, nLin)
Endif

If lRet
	lRet := PCOChk_IC(cArquivo, oGetDados, nLin)
EndIf

If lRet
	lRet := PCOChk_CV(cArquivo, oGetDados, nLin)
EndIf

If lIncluiLin .And. lRet
	oGetDados:Acols[nLin, nPosId] := PadR("*", Len(AK2->AK2_ID))
EndIf

If lRet .And. lViewModify
   lModify := PcoModifyAK2(cChvLck,oGetDados,nPosId,aColAlt)
   If lModify
		Aviso(STR0004, STR0035, {"Ok"})  //"Atencao"###"Foram alterados alguns valores deste item orcamentario apos a leitura. Dados serao atualizados."
			//se nao, destrava registro lockado e voltapara tela de digitacao
		Pco_Alt_Lin_GetDados(oGetDados,nPosId,aColAlt)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoVerAtu(cPlanilha)
Local cAlias := ALIAS()
Local aArea  := GetArea()
Local aAreaAK1 := AK1->(GetArea())
Local cVerAtu := ""
Local nRecAK1

dbSelectArea("AK1")
dbSetOrder(1)

If MSSeek(xFilial("AK1")+PadR(cPlanilha,Len(AK1->AK1_CODIGO)))
	While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial("AK1")+cPlanilha)
		cVerAtu	:= AK1->AK1_VERSAO
		nRecAK1 := AK1->(Recno())
		AK1->(dbSkip())
	End
	AK1->(dbGoto(nRecAK1))
EndIf

RestArea(aAreaAK1)
RestArea(aArea)
dbSelectArea(cAlias)

Return(cVerAtu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_NewAcesso(oGetDados, nLin, cCampo,cRevisa,lValid)
Local lRet := .T.
Local nPosCC, nPosIC, nPosCV,nPosItem
Local nPosId	:=	aScan( oGetDados[1]:aHeader, {|x|AllTrim(x[2])=="AK2_ID"})	// Posicao do ID
Local	nHeadCtaOrc	:= aScan(  oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})
Local lIncluiLin := .F.
Local lViewModify := .F.
Local lModify := .F.
Local cChvLck := ""
Local aColAlt := {}
Local aColEsp
Local cEnt := ""
Local aNPosEnts := {}
Local nQtd

AK3->(DbSetorder(1))
If nHeadCtaOrc == 0
	nHeadCtaOrc	:= aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CO"})
	If nHeadCtaOrc > 0
		cCo	:=	oGetDados[2]:aCols[1, nHeadCtaOrc] //so existe uma linha na grade de filtro
		AK3->(DbSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCo))
	EndIf
Else
	AK3->(DbSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+oGetDados[1]:aCols[nLin][nHeadCtaOrc]))
	cCo	:=	oGetDados[1]:aCols[nLin][nHeadCtaOrc]
Endif

cCampo := AllTrim(cCampo)
/* Implementar para entidade e para CO */

If Ascan( aLineNew, AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados[1]:aCols[nLin][nPosID] ) = 0  .And. ;
	( Empty(oGetDados[1]:aCols[nLin][nPosID]) .Or. oGetDados[1]:aCols[nLin][nPosID] == Padr("*", Len(AK2->AK2_ID)) ) // Tratamento para evitar que uma linha seja adicionada na alteração filtrada da planilha

	oGetDados[1]:aCols[nLin][nPosID] := PadR("*", Len(AK2->AK2_ID))
	aAdd(aLineNew, AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados[1]:aCols[nLin][nPosID] )
	lIncluiLin := .T.
EndIf

If oGetDados[1]:lNewLine .And. Empty(oGetDados[1]:aCols[nLin][nPosID]) .And. ! Empty(M->AK2_CLASSE)
	PcoPlanCl()	
EndIf	

If lIncluiLin
	lRet    := .T.
Else
	cChvLck := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGetDados[1]:aCols[nLin][nPosID]
	lRet	:=	PcoLockAK2(cChvLck,,@lViewModify)
EndIf

If lRet
	If  ! PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,3,"ITENS",cRevisa)
		lRet	:=	.F.
	Endif
	If  lRet .And. lRevisao .And. ! PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"REVISA",cRevisa)
		lRet	:=	.F.
	EndIf
	If lRet
		If Alltrim(cCampo) != "AK2_CO" .And. Empty(M->AK2_CO)
			Aviso(STR0004, STR0007, {"Ok"}) //"Atencao"###"Nao digitado conta orcamentaria"
		Else
			lRet := .T.
			nPosCC := aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CC"})

			If nPosCC > 0 .And. !Empty(oGetDados[2]:aCols[1, nPosCC])
				M->AK2_CC := oGetDados[2]:aCols[1, nPosCC]
			Else
				nPosCC := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CC"})
				If nPosCC > 0
					If ReadVar() != "M->AK2_CC"
						M->AK2_CC := oGetDados[1]:aCols[nLin, nPosCC]
					EndIf
				Else
					M->AK2_CC := Space(Len(AK2->AK2_CC))
				EndIf
			EndIf

			nPosIC := aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_ITCTB"})
			If nPosIC > 0.And. !Empty(oGetDados[2]:aCols[1, nPosIC])
				M->AK2_ITCTB := oGetDados[2]:aCols[1, nPosIC]
			Else
				nPosIC := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_ITCTB"})
				If nPosIC > 0
					If ReadVar() != "M->AK2_ITCTB"
						M->AK2_ITCTB := oGetDados[1]:aCols[nLin, nPosIC]
					EndIf
				Else
					M->AK2_ITCTB := Space(Len(AK2->AK2_ITCTB))
				EndIf
			EndIf

			nPosCV := aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CLVLR"})
			If nPosCV > 0 .And. !Empty(oGetDados[2]:aCols[1, nPosCV])
				M->AK2_CLVLR := oGetDados[2]:aCols[1, nPosCV]
			Else
				nPosCV := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CLVLR"})
				If nPosCV > 0
					If ReadVar() != "M->AK2_CLVLR"
						M->AK2_CLVLR := oGetDados[1]:aCols[1, nPosCV]
					EndIf
				Else
					M->AK2_CLVLR := Space(Len(AK2->AK2_CLVLR))
				EndIf
			EndIf

			If(AK2->(FieldPos("AK2_UNIORC")) >  0)
					nPosUni := aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_UNIORC"})
				If nPosUni > 0 .And. !Empty(oGetDados[2]:aCols[1, nPosUni])
					M->AK2_UNIORC := oGetDados[2]:aCols[1, nPosUni]
				Else
					nPosUni := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_UNIORC"})
					If nPosUni > 0
						If ReadVar() != "M->AK2_UNIORC"
							M->AK2_UNIORC := oGetDados[1]:aCols[1, nPosUni]
						EndIf
					Else
						M->AK2_UNIORC := Space(Len(AK2->AK2_UNIORC))
					EndIf
				EndIf
			EndIf

			// Verifica a quantidade de entidades contabeis
			If nQtdEntid == NIL
				If cPaisLoc == "RUS"
					nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
				Else
					nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
				EndIf
			EndIf

			If nQtdEntid > 4
				aNPosEnts := Array(nQtdEntid)
				For nQtd := 5 To nQtdEntid
					cEnt := "AK2_ENT"+STRZERO(nQtd,2)

					If(AK2->(FieldPos("AK2_ENT"+STRZERO(nQtd,2))) >  0)
						aNPosEnts[nQtd] := aScan(oGetDados[2]:aHeader,{|x| AllTrim(x[2])=="XK2_ENT"+STRZERO(nQtd,2)})
						If aNPosEnts[nQtd] > 0 .And. !Empty(oGetDados[2]:aCols[1, aNPosEnts[nQtd]])
							M->&cEnt := oGetDados[2]:aCols[1, aNPosEnts[nQtd]]
						Else
							aNPosEnts[nQtd] := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_ENT"+STRZERO(nQtd,2)})
							If aNPosEnts[nQtd] > 0
								If ReadVar() != "M->AK2_ENT"+STRZERO(nQtd,2)
									M->&cEnt := oGetDados[1]:aCols[1, aNPosEnts[nQtd]]
								EndIf
							Else
								M->&cEnt := Space(Len(AK2->&cEnt))
							EndIf
						EndIf
					EndIf
				Next
			EndIf

			If !Empty(cCO)

				lRet := PCOChkCC_New(oGetDados, nLin, AllTrim(M->AK2_CC))
				lRet := lRet .And. PCOChkIC_New(oGetDados, nLin, AllTrim(M->AK2_ITCTB))
				lRet := lRet .And. PCOChkCV_New(oGetDados, nLin, AllTrim(M->AK2_CLVLR))
			EndIf
		EndIf
	Endif
	If lRet .And. lViewModify
        aColEsp := {}
        PcoCposEsp(aColEsp, oGetDados[2])
		lModify := PcoModifyAK2(cChvLck,oGetDados[1],nPosId,aColAlt,aColEsp)
		If lModify
			Aviso(STR0004, STR0035, {"Ok"})  //"Atencao"###"Foram alterados alguns valores deste item orcamentario apos a leitura. Dados serao atualizados."
			//se nao, destrava registro lockado e voltapara tela de digitacao
			Pco_Alt_Lin_GetDados(oGetDados[1],nPosId,aColAlt,aColEsp)
		EndIf
	EndIf
Endif

//O ReadVar() foi acrescentado pois campo "M->AK2_VAL" nao passa pelo valid
//entao as validacoes sao feitas no when() nos demais so entra pelo Valid
If lRet .And. (lValid .OR. ReadVar() = "M->AK2_VAL") .And. ;
	!(	oGetDados[1]:aCols[nLin][COL_EDIT] == BMP_CHK .OR. ;
		oGetDados[1]:aCols[nLin][COL_EDIT] == BMP_INCL )
	nPosItem := aScan(oGetDados[1]:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
	If !Empty(oGetDados[1]:aCols[nLin][nPosItem] ) .And. Padr(oGetDados[1]:aCols[nLin][nPosItem], Len(AK2->AK2_ID)) != Padr("*", Len(AK2->AK2_ID))
		oGetDados[1]:aCols[nLin][COL_EDIT] := BMP_CHK
	Else
		oGetDados[1]:aCols[nLin][COL_EDIT] := BMP_INCL
		oGetDados[1]:aCols[nLin][nPosItem] := Padr("*", Len(AK2->AK2_ID))
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChkCC_New ºAutor  ³Paulo Carnelossi  º Data ³ 02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito ao centro de   º±±
±±º          ³custo informado e vericacao dos direitos                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChkCC_New(oGetDados, nLin, cChvCC)
Local cCentroCusto, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "CCUSTO"
Local lRet := .F.

If !Empty(cChvCC)  // Se campo AK2_CC ESTIVER EM USO VALIDA DIR USUARIO
	cOrcame := AK1->AK1_CODIGO

	cCO :=  AK3->AK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO
	cCentroCusto := cChvCC

	lRet := PcoCC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cCentroCusto,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T. //se campo AK2_CC == NAO USADO
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChkIC_New ºAutor  ³Paulo Carnelossi  º Data ³ 02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito ao Item Conta- º±±
±±º          ³bil informado e vericacao dos direitos                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChkIC_New(oGetDados, nLin, cChvIC)
Local cItemCtb, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "ITMCTB"
Local lRet := .F.

If !Empty(cChvIC) // se campo AK2_ITCTB ESTIVER EM USO VALIDA DIREITO USUARIO
	cOrcame := AK1->AK1_CODIGO

	cCO :=  AK3->AK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO
	cItemCtb := cChvIC

	lRet := PcoIC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cItemCtb,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T. // Se campo AK2_ITCTB == NAO USADO
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOChkCV_New ºAutor ³Paulo Carnelossi  º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para validacao se usuario tem direito a classe de    º±±
±±º          ³valor informado e vericacao dos direitos                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChkCV_New(oGetDados, nLin, cChvCV)
Local cClasseValor, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local cCampo := "CLAVLR"
Local lRet := .F.

If !Empty(cChvCV) // se campo AK2_CLVLR ESTIVER EM USO VALIDA DIREITO DO USUARIO

	cOrcame := AK1->AK1_CODIGO

	cCO :=  AK3->AK3_CO
	cCOPai := AK3->AK3_PAI
	cRevisa := AK3->AK3_VERSAO
	cClasseValor := cChvCV

	lRet := PcoCV_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cClasseValor,2/*nDireito*/)

	If !lRet
		HELP("  ",1,"PCONOITEM")
	EndIf
Else
	lRet := .T.  // se campo AK2_CLVLR == NAO USADO
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoEntd_User ³ Autor ³ Paulo Carnelossi   ³ Data ³ 26/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario x Entidade.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoEntd__User(cOrcame,cCO,cCOPai,nCheck,cRevisa,cEntidade,cChvEntid,nDireito)
Local lRet	:= .F.
Local aArea	:= GetArea()
Local aAreaAK2	:= AK2->(GetArea())
Local aAreaAK1	:= AK1->(GetArea())
Local aAreaAKG	:= AKG->(GetArea())
Local aAreaAK3	:= AK3->(GetArea())
//Local cCampo    := "ENTIDA"
Local nDirUsu
DEFAULT nDireito := 0

AK1->(dbSetOrder(1))
AK1->(MsSeek(xFilial()+cOrcame))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o controle de usuarios esta habilitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AK1->AK1_CTRUSR == "2"  //se nao tem retorna sempre .t.
	RestArea(aAreaAK1)
	RestArea(aAreaAK2)
	RestArea(aArea)
	Return(.T.)
ElseIf Empty(cChvEntid)
	Aviso(STR0004, STR0015+cEntidade+STR0016,{"Ok"})//"Entidade - "###" - Chave de pesquisa não informado."
	Return(.F.)
EndIf

If __cUserID=="000000"
	lRet := .T.
Else
	dbSelectArea("AKG")
	dbSetOrder(1)
	If MsSeek(xFilial()+cOrcame+cCO+__cUserID)
		//Se tem acesso total libera
		If Val(AKG->AKG_ENTIDA) > 1
			lRet := .T.
		Else
			//Analisa o acesso por entidades para a conta
			nDirUsu := PcoDirEnt_User(cEntidade, cChvEntid, __cUserID, .F.)
			lRet := (nDirUsu >= nDireito)
		Endif
	Else
		//Avalia os acessos para a conta PAI.
		AK3->(dbSetOrder(1))
		If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
			lRet	:=	 PcoEntd__User(cOrcame,AK3->AK3_CO,AK3->AK3_PAI,nCheck,cRevisa,cEntidade,cChvEntid,nDireito)
		EndIf
	EndIf
EndIf

RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAKG)
RestArea(aAreaAK3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco_ChkUsu(oGetDados, nLin, nRecAK3, aFixos)
Local lRet := .F.
DEFAULT aFixos := {}

lRet := PCOChk_Entida(oGetDados, nLin, nRecAK3, aFixos)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOChk_Entida(oGetDados, nLin, nRecAK3, aFixos)
Local nDireito, cChvEntida, cOrcame, cCO, cCOPai, cRevisa
Local nCheck := 2
Local lRet := .F.
Local aRet := {}, lContinua := .T., nY
Local aArea 	:= GetArea()
Local aAreaAK3 	:= AK3->(GetArea())
Local aAreaSX2 := SX2->(GetArea())
Local aAreaAL6
Local nCpoAux := 0
Local nCpoFil := 0

dbSelectArea("SX2")
If !dbSeek("AL6")
	RestArea(aAreaSX2)
	RestArea(aArea)
	Return(.T.)
EndIf
RestArea(aAreaSX2)
RestArea(aArea)

aAreaAL6 := AL6->(GetArea())

dbSelectArea("AK3")
dbGoto(nRecAK3)
cOrcame := AK1->AK1_CODIGO
cCO :=  AK3->AK3_CO
cCOPai := AK3->AK3_PAI
cRevisa := AK3->AK3_VERSAO

dbSelectArea("AL6")
dbSetOrder(1)
lRet := ! dbSeek(xFilial("AL6"))  //se nao estiver populado nem entra na validacao

While AL6->(!Eof() .And. AL6_FILIAL == xFilial("AL6"))
    nCpoAux := 0
    nCpoFil := 0
	cCpoEntidade := Alltrim(AL6->AL6_CPOITE)

	If AL6->AL6_ATIVO=="1"
		If !Empty(aFixos)
			nCpoFil := aScan(aFixos,{|x| AllTrim(x[1]) == cCpoEntidade .Or.AllTrim(x[1]) == 'X'+Substr(cCpoEntidade,2) })
		EndIf

		If nCpoAux == 0
			nCpoAux := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == cCpoEntidade})
		EndIf

		If nCpoAux+nCpoFil > 0  // Se campo ESTIVER EM USO VALIDA DIR USUARIO

			If nCpoFil >0
				cChvEntida := aFixos[nCpoFil][2]
			Else
				cChvEntida := oGetDados:aCols[nLin][nCpoAux]
			EndIf

			lRet := PcoEntd__User(cOrcame,cCO,cCOPai,nCheck,cRevisa,AL6->AL6_ENTIDA,cChvEntida,2/*nDireito*/)

			If !lRet
				lContinua := .F.
				Exit
			EndIf
		Else
			lRet := .T. //se campo == NAO USADO
		EndIf
	Else
		lRet := .T. //se campo == NAO ATIVO
	EndIf

	aAdd(aRet, lRet)

	dbSelectArea("AL6")
	dbSkip()

End

If lContinua .And. !Empty(aRet)
	For nY := 1 TO Len(aRet)
	    If ! aRet[nY]
	    	 lRet := .F.
	    	 Exit
	    Else
			lRet := aRet[nY]
	    EndIf
	Next
EndIf

RestArea(aAreaAL6)
RestArea(aAreaAK3)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Bco_Entidades(aAlias)
Local aEntidAux := MsRelation()
Local aEntidade := {}
Local nX, nScan

For nX := 1 TO Len(aAlias)
	If !Empty( nScan := AScan( aEntidAux, { |x| x[1] == aAlias[nX] } ) )
       aAdd(aEntidade, aClone(aEntidAux[nScan]))
	EndIf
Next

Return(aEntidade)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCopyDocs(aDocs, aEntidades, cVerAtu, cNextVer, lRevisao, lSimulac)
Local cDirDocs   := MsDocPath()
Local cDrive := ""
Local cFile := ""
Local cFileNew := ""
Local cExtensao := ""
Local cNewArq := ""
Local lCopia
Local nRecNew
Local cNewCod
Local aRecACB := {}
Local nX, nY
Local nScan
Local InicCodObj
Local nSaveSx8   := 0
Local cChaveAKE
Local nRecACC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira a ultima barra invertida ( se houver )                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDirDocs  := MsDocRmvBar( cDirDocs )
InicCodObj := Posicione("SX3", 2, "ACB_CODOBJ", "X3_RELACAO")

//primeiro vou copias os objetos do banco de conhecimento
For nX := 1 TO Len(aDocs)
	For nY := 1 TO Len(aDocs[nX][04])
		If (nScan := AScan( aRecACB, { |x| x[1] == aDocs[nX][04][nY] })) == 0
			dbSelectArea("ACB")
			dbGoto(aDocs[nX][04][nY])
			SplitPath(cDirDocs+"\"+Alltrim(ACB->ACB_OBJETO), @cDrive, @cDirDocs, @cFile, @cExtensao )

			//tem que usar a funcao novamente pois SplitPath sempre atualiza o valor de cDirDocs
			cDirDocs  := MsDocRmvBar( cDirDocs )
			cNewArq := PcoNameFile(@cDirDocs, @cFile, @cExtensao, @cFileNew, cVerAtu, cNextVer, ACB->ACB_OBJETO)

			If File(cDirDocs + "\" +Alltrim(ACB->ACB_OBJETO)).And. ;
				!File(cNewArq)
				lCopia := .F.
				Processa( { || __CopyFile( cDirDocs + "\" +Alltrim(ACB->ACB_OBJETO), ;
											 cNewArq ),;
											 lCopia := File(cNewArq) },;
											  STR0013,STR0014 ,.F.)//"Copiando objeto"###"Aguarde..."
                If lCopia
    				nRecNew := 0
    				cNewCod := If(!Empty(InicCodObj), &(InicCodObj), GetSxeNum("ACB","ACB_CODOBJ"))
					PmsCopyReg("ACB",aDocs[nX][04][nY],{{"ACB_CODOBJ",cNewCod},{"ACB_OBJETO",cFileNew}},@nRecNew)
					While (GetSx8Len() > nSaveSx8)
						ConfirmSX8()
					EndDo
					aAdd(aRecACB, {aDocs[nX][04][nY], nRecNew, cNewCod, ACB->ACB_CODOBJ})
                EndIf
			EndIf
		EndIf
	Next //nY
Next //nx

//Atualizar palavras chave do banco de conhecimento
DbSelectArea("ACC")
dbSetOrder(1)
For nX := 1 TO Len(aRecACB)
	If dbSeek(xFilial("ACC")+aRecACB[nx][4])
		While ACC->(ACC_FILIAL+ACC_CODOBJ==xFilial("ACC")+aRecACB[nx][4])
			nRecACC := ACC->(Recno())
			PmsCopyReg("ACC",ACC->(Recno()),{{"ACC_CODOBJ", aRecACB[nx][3]}},@nRecNew)
			ACC->(dbGoto(nRecACC))
			ACC->(dbSkip())
		End
	EndIf
Next


//criar os registros de relacionamento para a nova revisao
DbSelectArea("AKE")
dbSetOrder(1)

If lRevisao
	cChaveAKE := AK1->AK1_CODIGO+AK1->AK1_VERREV
ElseIf lSimulac
	cChaveAKE := AK1->AK1_CODIGO+cNextVer
Else
	cChaveAKE := AK1->AK1_CODIGO+AK1->AK1_VERSAO
EndIf
dbSeek(xFilial("AKE")+cChaveAKE)
cEntidade:="AKE"
aChavDoc := aClone(aEntidades[1][2])
cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )

//sempre o primeiro elemento do array aDocs se refere a tabela AKE
For nx := 1 TO Len(aDocs[1][5])   //onde esta gravado aRecAC9
	dbSelectArea("AC9")
	dbGoto(aDocs[1][5][nx])
	cCodObjAnt := AC9->AC9_CODOBJ
	cCodObjAtu := PcoCodAtu(cCodObjAnt, aRecACB)
	If !Empty(cCodObjAtu)
		PmsCopyReg("AC9",aDocs[1][5][nx],{{"AC9_CODOBJ",cCodObjAtu},{"AC9_CODENT",cCodEnt}},@nRecNew)
	EndIf
Next

//do segundo elemento em diante do array aDocs se refere a tabela AK3
dbSelectArea("AK3")
cEntidade:="AK3"
aChavDoc := aClone(aEntidades[2][2])

For nY := 2 TO Len(aDocs)

	If !Empty(aDocs[nY][5])
		For nx := 1 TO Len(aDocs[1][5])   //onde esta gravado aRecAC9
			dbSelectArea(AK3)
			dbGoto(aDocs[ny][3])
			cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
			cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
			dbSelectArea("AC9")
			dbGoto(aDocs[ny][5][nx])
			cCodObjAnt := AC9->AC9_CODOBJ
			cCodObjAtu := PcoCodAtu(cCodObjAnt, aRecACB)
			If !Empty(cCodObjAtu)
				PmsCopyReg("AC9",aDocs[ny][5][nx],{{"AC9_CODOBJ",cCodObjAtu},{"AC9_CODENT",cCodEnt}},@nRecNew)
			EndIf
		Next //nx
	EndIf
Next //nY

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCodAtu(cCodObjAnt, aRecACB)
Local cCodObj := "", nScan := 0

nScan := aScan( aRecACB, { |x| x[4] == cCodObjAnt})
If nScan > 0
	cCodObj := aRecACB[nScan][3]
Else
	Aviso(STR0011, STR0012+cCodObjAnt, {"Ok"})	//"Erro na Copia"###"Nao encontrado o objeto correspondente ao "
EndIf

Return(cCodObj)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoNameFile(cDirDocs, cFile, cExtensao, cFileNew, cVerAtu, cNextVer, cObjeto)
Local cNewArq := ""
Local cPlanilha := ""
Local cVerPla := ""
Local cArqNovo := ""
Local aArqObj := {"","",""}

cObjeto := Alltrim(cObjeto)
aArqObj := PcoEstr_Name(cObjeto)
cPlanilha := aArqObj[1]
cVerPla   := aArqObj[2]
cArqNovo  := aArqObj[3]

If At("["+Alltrim(AKE->AKE_ORCAME)+"]["+cVerAtu+"]", cObjeto) > 0 .OR. ;
    Empty(cPlanilha+cVerPla)
	cNewArq := cDirDocs + "\" + "["+Alltrim(AKE->AKE_ORCAME)+"]["+cNextVer+"]"+cArqNovo
	cFileNew := "["+Alltrim(AKE->AKE_ORCAME)+"]["+cNextVer+"]"+cArqNovo
Else
	If cPlanilha+cVerPla <> Alltrim(AKE->AKE_ORCAME)+cNextVer
		cNewArq := cDirDocs + "\" + "["+Alltrim(AKE->AKE_ORCAME)+"]["+cNextVer+"]"+cArqNovo
		cFileNew := "["+Alltrim(AKE->AKE_ORCAME)+"]["+cNextVer+"]"+cArqNovo
	Else
		MsgStop(STR0009+"["+Alltrim(AKE->AKE_ORCAME)+"]["+cNextVer+"]"+cArqNovo+STR0010)//"Erro ao definir nome do arquivo: "###" . Ja existente!)"
	EndIf
EndIf

Return(cNewArq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoEstr_Name(cObjeto)
Local aEstrNome := {"","",""}
Local nPos1, nPos2, nPos3
If Left(cObjeto,1)=="[" .And. At("][",cObjeto)>0
	nPos1 := 1
	nPos2 := At("][",cObjeto)
	nPos3 := At("]",Subs(cObjeto, nPos2+2))
	aEstrNome[1] := Subs(cObjeto,nPos1+1,nPos2-2)
	aEstrNome[2] := Subs(cObjeto,nPos2+2,nPos3-1)
	aEstrNome[3] := Subs(cObjeto,nPos2+2+nPos3)
Else
	aEstrNome[3] := cObjeto
EndIf
Return(aEstrNome)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoVld_Key_Ref ºAutor ³ Paulo Carnelossi º Data ³ 25/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao a ser adicionada nos campos AKC_KEYREF/AKI_KEYREF de º±±
±±º          ³forma a minimizar erros de configuracao do lancto/bloqueio  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoVld_Key_Ref()
Local aArea := GetArea()
Local aAreaSIX := SIX->(GetArea())
Local aAreaSX2 := SX2->(GetArea())
Local lRet := .T.
Local cCampo := ReadVar()
Local cArq := ""
Local nInd := 0
Local cChv := ""
Local cCont := ""
Local xVar  := ""

If Alltrim(Subs(cCampo, 4)) $ "AKC_KEYREF|AKI_KEYREF"
	xVar := &(ReadVar())
	If !Empty(xVar)
		cCont := &(xVar)
		cArq := Subs(cCont,1,3)
		nInd := Val(Subs(cCont,4,2))
		cChv := Subs(cCont,6)
		dbSelectArea("SX2")
		dbSetOrder(1)
		lRet := dbSeek(cArq)
		If lRet
			dbSelectArea("SIX")
			dbSetOrder(1)
			lRet := dbSeek(cArq+StrZero(nInd,1))
		EndIf
		If lRet
			lRet := Aviso(STR0003, STR0017+" ["+STR0018+"] ? "+CRLF+;  //"Confirma a configuracao do campo"###"Chave Identificador"
    							STR0019+" : "+cArq+" - "+X2NOME()+CRLF+;  //"Entidade (Tabela)"
    							STR0020+"            : "+StrZero(nInd,1)+" - "+STR0021+" + "+SixDescricao()+CRLF+;//"Indice"##"Filial"
    							STR0022+" : "+cChv+CRLF, {STR0005, STR0006},2,STR0026+" ?",,"CADEADO") == 1  //"Chave a Pesquisar"###"Confirma"###"Cancela"###"Confirma a configuracao"
    	Else
    		Aviso(STR0003, STR0023+" ["+STR0018+"]."+CRLF+;  //"Verifique a configuração do campo"###"Chave Identificador"
    						STR0024+CRLF+CRLF+;  //" Onde as Posicões:"
    							"1-3           = "+STR0019+CRLF+;  //"Entidade (Tabela do Sistema)"
    							"4-5           = "+STR0020+CRLF+;  //"Indice"
    							STR0027+"     = "+STR0022+CRLF, {"Ok"},3,STR0025+"!",,"CADEADO") //"Chave a Pesquisar"###"Configuração Inválida"###"Demais"
    	EndIf
    EndIf
EndIf

RestArea(aAreaSX2)
RestArea(aAreaSIX)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOTotCO ºAutor  ³ Gustavo Henrique   º Data ³  28/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Totaliza as contas orcamentarias analiticas e sinteticas   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Planilha orcamentaria                              º±±
±±º          ³ EXPC2 - Versao da planilha                                 º±±
±±º          ³ EXPA3 - Vetor de filtro das CO's                           º±±
±±º          ³         aFilCO[ 1 ] - CO inicial                           º±±
±±º          ³         aFilCO[ 2 ] - CO final                             º±±
±±º          ³ EXPA4 - Vetor de filtro das Operacoes                      º±±
±±º          ³         aFilOper[ 1 ] - Operacao Inicial                   º±±
±±º          ³         aFilOper[ 2 ] - Operacao final                     º±±
±±º          ³ EXPC5 - Processa contas sinteticas                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPA1 - Array com as CO's sinteticas/analiticas totalizadasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOTotCO( cOrcame, cVersao, aFilCO, lProcSint, aFilOper)

Local cQuery 	:= ""

Local nPos		:= 0

Local aTotCO	:= {}			// Vetor com o total das contas orcamentarias
Local aArea		:= GetArea()
Local aAreaAK5	:= AK5->(GetArea())

Default aFilCO	:= {}
DEFAULT aFilOper := {}

cQuery := "Select "
cQuery += "    AK3.AK3_PAI, AK2.AK2_CO, Sum(AK2.AK2_VALOR) TOT_CO "
cQuery += "From " + RetSqlName("AK3") + " AK3 "
cQuery += "Inner Join " + RetSqlName("AK2") + " AK2 On "
cQuery += "    AK2.AK2_FILIAL = '" + xFilial("AK2") + "' "
cQuery += "And AK2.AK2_ORCAME = '" + cOrcame + "' "
cQuery += "And AK2.AK2_VERSAO = '" + cVersao + "' "
If Len(aFilCO) > 0	// Se passou filtro por CO
	cQuery += "And AK2.AK2_CO BETWEEN '" + aFilCO[1] + "' And '" + aFilCO[2] + "' "
EndIf
If Len(aFilOper) > 0	// Se passou filtro por Operacao
	cQuery += "And AK2.AK2_OPER BETWEEN '" + aFilOper[1] + "' And '" + aFilOper[2] + "' "
EndIf
cQuery += "And AK2.D_E_L_E_T_ = ' ' "
cQuery += "Where "
cQuery += "    AK3.AK3_FILIAL = '" + xFilial("AK3") + "' "
cQuery += "And AK3.AK3_CO = AK2.AK2_CO "
cQuery += "And AK3.AK3_ORCAME = '" + cOrcame + "' "
cQuery += "And AK3.AK3_VERSAO = '" + cVersao + "' "
cQuery += "And AK3.D_E_L_E_T_ = ' ' "
cQuery += "Group By AK3.AK3_PAI, AK2.AK2_CO "
cQuery += "Order By AK3.AK3_PAI, AK2.AK2_CO "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .T. )
TCSetField( "TRB", "TOT_CO", "N", 14, 2 )

AK5->( dbSetOrder(1) )

Do While TRB->( ! EoF() )
    AAdd( aTotCO, { TRB->AK2_CO, TRB->TOT_CO, TRB->AK3_PAI } )
	nPos := AScan( aTotCO, { |aDet| aDet[1] == TRB->AK3_PAI } )
	If lProcSint .And. nPos == 0
		PCOTotSup( aTotCO[Len(aTotCO),3], cOrcame, cVersao, @aTotCo, aFilCO, aFilOper )
	EndIf
	TRB->( dbSkip() )
EndDo

aSort( aTotCO,,, {|x,y| x[1] < y[1] } )

TRB->( dbCloseArea() )

RestArea( aArea )
RestArea( aAreaAK5 )

Return aTotCO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOTotSup  ºAutor ³ Gustavo Henrique  º Data ³  28/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta o array aTotCO com os valores para as contas         º±±
±±º          ³ sinteticas, a partir de uma conta analitica.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Conta orcamentaria superior                        º±±
±±º          ³ EXPC2 - Planilha orcamentaria                              º±±
±±º          ³ EXPC3 - Versao da planilha                                 º±±
±±º          ³ EXPA4 - Vetor com o total das contas sinteticas/analiticas º±±
±±º          ³         aTotCO[ n, 1 ] - Conta orcamentaria                º±±
±±º          ³         aTotCO[ n, 2 ] - Total da conta orcamentaria       º±±
±±º          ³         aTotCO[ n, 3 ] - Conta orcamentaria superior       º±±
±±º          ³ EXPA5 - Vetor de filtro das CO's                           º±±
±±º          ³         aFilCO[ 1 ] - CO inicial                           º±±
±±º          ³         aFilCO[ 2 ] - CO final                             º±±
±±º          ³ EXPA6 - Vetor de filtro das Operacoes                      º±±
±±º          ³         aFilOper[ 1 ] - Operacao Inicial                   º±±
±±º          ³         aFilOper[ 2 ] - Operacao final                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOTotSup( cCOSup, cOrcame, cVersao, aTotCo, aFilCO, aFilOper )

Local cQuery	:= ""
Local nPos		:= 0
DEFAULT aFilOper  := {}

AK5->( MsSeek( xFilial("AK5") + cCOSup ) )

cQuery := "Select "
cQuery += "    AK3.AK3_PAI, Sum(AK2.AK2_VALOR) TOT_CO "
cQuery += "From " + RetSqlName("AK3") + " AK3 "
cQuery += "Inner Join " + RetSqlName("AK2") + " AK2 On "
cQuery += "    AK2.AK2_FILIAL = '" + xFilial("AK2") + "' "
cQuery += "And AK2.AK2_ORCAME = '" + cOrcame + "' "
cQuery += "And AK2.AK2_VERSAO = '" + cVersao + "' "
If Len( aFilCO ) > 0	// Se passou filtro por CO
	cQuery += "And AK2.AK2_CO BETWEEN '" + aFilCO[1] + "' And '" + aFilCO[2] + "' "
EndIf
If Len(aFilOper) > 0	// Se passou filtro por Operacao
	cQuery += "And AK2.AK2_OPER BETWEEN '" + aFilOper[1] + "' And '" + aFilOper[2] + "' "
EndIf
cQuery += "And AK2.D_E_L_E_T_ = ' ' "
cQuery += "Where "
cQuery += "    AK3.AK3_FILIAL = '" + xFilial("AK3") + "' "
cQuery += "And AK3.AK3_ORCAME = '" + cOrcame + "' "
cQuery += "And AK3.AK3_VERSAO = '" + cVersao + "' "
cQuery += "And AK3.AK3_PAI   >= '" + cCOSup + "' "
cQuery += "And AK3.AK3_PAI   <= '" + AllTrim(cCOSup) + Replicate( "Z", (TamSX3("AK2_CO")[1]-Len(AllTrim(cCOSup))) ) + "' "
cQuery += "And AK3.AK3_CO     = AK2.AK2_CO "
cQuery += "And AK3.D_E_L_E_T_ = ' ' "
cQuery += "Group By AK3.AK3_PAI "
cQuery += "Order by AK3.AK3_PAI "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB01", .T., .T. )
TCSetField( "TRB01", "TOT_CO", "N", 14, 2 )

Do While TRB01->( ! EoF() )
	nPos := aScan( aTotCO, { |x| x[1] == cCoSup } )
	If nPos == 0
		AAdd(aTotCO, { cCoSup, TRB01->TOT_CO, AK5->AK5_COSUP } )
	Else
		aTotCO[nPos,2] += TRB01->TOT_CO
	EndIf
    TRB01->( dbSkip() )
EndDo

TRB01->( dbCloseArea() )
dbSelectArea("AK3")

If !Empty(AK5->AK5_COSUP) .And. ( aScan( aTotCO, { |x| x[1] == AK5->AK5_COSUP } ) == 0 )
	PCOTotSup( AK5->AK5_COSUP, cOrcame, cVersao, @aTotCO, aFilCO, aFilOper )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoSaveGraf  ºAutor  ³Paulo Carnelossi  º Data ³ 11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva o grafico em arquivo com formato .BMP                 º±±
±±º          ³Sera utilizado nas consultas do PCO que tem grafico exibido º±±
±±º          ³Grava no diretorio /SYSTEM do servidor                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoSaveGraf(oGraphic, lPergNomeArq, lShowMessage, lImprime, aListArq)
Local lRet 		:= .F.
Local cBmpName 	:= ""
Local cNomeArq 	:= ""
Local cBarra 	:= If(issrvunix(), "/", "\") 
Local cBarraInv	:= If(issrvunix(), "\", "/") 
Local cRaizServer := GetSrvProfString("StartPath", "\undefined")

DEFAULT lPergNomeArq 	:= .F.
DEFAULT lShowMessage 	:= .T.
DEFAULT lImprime 		:= .F.

cBmpName := Lower(CriaTrab(,.F.)+".BMP")

If !( Rat("\",GetSrvProfString("StartPath", "\undefined") ) > 0 .Or. Rat("/",GetSrvProfString("StartPath", "\undefined") ) > 0 )
	cRaizServer += cBarra
Endif

If ( At(cBarraInv,cRaizServer) > 0 )
	cRaizServer := StrTran(cRaizServer,cBarraInv,cBarra)
EndIf	

oGraphic:SaveToBMP( cBmpName, cRaizServer )

If lPergNomeArq
	cNomeArq := Lower(PcoNomeGrf())
	If !Empty(cNomeArq)
		__CopyFile(cRaizServer+cBmpName,cNomeArq+".BMP")
		If !File(cNomeArq+".BMP")
			Alert(STR0028)  //"Erro ao gravar o arquivo de imagem. Tente novamente"
			lRet := .F.
		Else
			aAdd(aListArq, cNomeArq+".BMP")
			lRet := .T.
		Endif
	EndIf
Else
	lRet := ( Len(Alltrim(cBmpName)) > 4 )
	__CopyFile(cRaizServer+cBmpName,cBmpName)
	If !File(cBmpName)
		Alert(STR0028)  //"Erro ao gravar o arquivo de imagem. Tente novamente"
		lRet := .F.
	Else
		aAdd(aListArq, cBmpName)
		cNomeArq := Left(cBmpName,8)
		lRet := .T.
	Endif
EndIf

If lRet .And. lShowMessage
	lImprime := Aviso(STR0008,  STR0029 + Alltrim(cNomeArq) + STR0030,{STR0031, STR0001})==1  //"Atencao"##"Fechar"##"O arquivo [ "##".BMP ] gerado com sucesso."##"Imprimir"
EndIf

If lRet .And. lImprime
	PcoImprGraph(cRaizServer+cBmpName)
EndIf

If lRet  //apagar o arquivo de trabalho gerado no root do server
	Ferase(cRaizServer+cBmpName)
EndIf

Return(cNomeArq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoNomeGrf   ºAutor  ³Paulo Carnelossi  º Data ³ 11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pergunta e retorna nome do arquivo que sera gravado no      º±±
±±º          ³formato .BMP (8 CARACTERES)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoNomeGrf()
Local aRet := {}
Local cGrafName := ""

//While Empty(cGrafName)
	If ParamBox( {	{1,STR0032,Space(8),"","","","", 120,.T.} },STR0033, aRet,,,,,,,,.F.,)  //"Digite Nome do Arquivo"##"Arquivo em formato BMP"
		cGrafName := PadR(aRet[1], 8)
	EndIf
//EndDo

Return(Alltrim(cGrafName))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoImprGraph ºAutor  ³Paulo Carnelossi  º Data ³ 11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o grafico gravado no arquivo                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PcoImprGraph(cBmpFile)
Local oPrint

If FindFunction("TRepInUse") .And. TRepInUse()
	oPrint := TReport():New(FunName(),"",, ;
			{|oReport| ReportPrint(oReport,cBmpFile)},;
			"")
	oPrint:SetPortrait()
	oPrint:PrintDialog()
Else
	oPrint := TMSPrinter():New("")
	oPrint:SetPortrait()
	oPrint:Setup()
	oPrint:StartPage()
	oPrint:SayBitmap( 250, 020 ,cBmpFile, 2400, 1200)
	oPrint:EndPage()
	oPrint:Preview()
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrint  ºAutor  ³Paulo Carnelossi  º Data ³ 11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o grafico gravado no arquivo treport - R4           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oPrint,cBmpFile)

oPrint:StartPage()
oPrint:SayBitmap( 250, 020 ,cBmpFile, 2400, 1200)
oPrint:EndPage()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoArqSave   ºAutor  ³Paulo Carnelossi  º Data ³ 11/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva os arquivos gerados conforme lista do array           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoArqSave(aListArq)
Local nX
Local cDirAtu := ""
Local cRelArq := STR0034+Repl(".",10)  //"Salvar os arquivos em formato .BMP gerados "

If Len(aListArq) > 0
	For nX := 1 TO Len(aListArq)
		cRelArq += If(nX==1," | ","")+aListArq[nX] + " | "
	Next
    If Aviso(STR0004,cRelArq+" ?",{STR0036, STR0037})==1  //"Atencao"##"Sim"##"Nao"
		cDirAtu := cGetFile(,STR0038,,cDirAtu,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+128) //"Selecione o diretório "
    EndIf
	For nX := 1 TO Len(aListArq)
		__CopyFile(aListArq[nX], cDirAtu+aListArq[nX])
		Ferase(aListArq[nX])
	Next
	aListArq := {}
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOCVldPer ºAutor ³ Gustavo Henrique  º Data ³  18/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao de periodos utilizado nas consultas de saldos    º±±
±±º          ³ por periodo e visao por periodo.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPD1 - Data inicial do periodo                            º±±
±±º          ³ EXPD2 - Data final do periodo                              º±±
±±º          ³ EXPL3 - Indicar se deve mostrar a mensagem de validacao    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consultas de Saldos / Visoes por periodo                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOCVldPer( dDataIni, dDataFim, lShowHelp)
Local lRet := .T.

Default lShowHelp := .T.

lRet := dDataFim >= dDataIni

If !lRet .and. lShowHelp
	Aviso( STR0008, STR0039, {"Ok"} )	// "Atenção" ### "Período final informado é maior que o período inicial."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOCleanSt
Realiza limpeza das variáveis statis da rotina

@author  Totvs
@version P12
@since   02/06/2020
@return  Nil

/*/
//-------------------------------------------------------------------

Function PCOCleanSt()

//Limpa array
If aClassOrc != Nil
	aClassOrc := Nil
EndIf

//Limpa objeto
If oHashAK6 != Nil
	FreeObj(oHashAK6)
EndIf

Return Nil

#INCLUDE "MATA982.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATA982   ³ Autor ³Gustavo G. Rueda       ³ Data ³11.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Integracao com o Word para geracao de um relatorio por for- ³±±
±±³          ³necedor referente IN SRF 381, de 30/12/2003 que trata sobre ³±±
±±³          ³a retencao das obrigacoes sociais(CSLL, COFINS, PIS/PASEP). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL = lRet = .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA982 ()
	Local		lRet		:=	.T.
	Local		cPerg		:=	"MTA982"
	Local		aIndexSA2	:=	{}
	Local		cFiltraSA2	:=	'A2_FILIAL==xFilial ("SA2") .And. A2_COD>=MV_PAR05 .And. A2_LOJA>=MV_PAR07 .And. A2_COD<=MV_PAR06 .And. A2_LOJA<=MV_PAR08'
	Local   	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private		bFiltraBrw	:=	{|| Nil}
	Private		cWord		:=	""
	Private 	cCadastro 	:= OemToAnsi(STR0001)
	Private		cPath		:=	""
	Private		cArquivo	:=	""
	Private 	aRotina		:= 	MenuDef()
	Private		cTipoR		:= ""
	//
	If !lVerpesssen .Or. !(Pergunte (cPerg, .T.))
	    Return (lRet)
	Endif
	//
	cArquivo 	:=	Alltrim (MV_PAR02)
	cPath		:=	AllTrim (MV_PAR03)
	//
	If !(File (cPath+cArquivo))
		Help(" ",1,"A9810001") //"Arquivo de Modelo nao encontrado !!"
		Return (lRet)
	Endif
	//
	cWord	:=	OLE_CreateLink ()
	If (cWord < "0")
		Help(" ",1,"A9810004") //"MS-WORD nao encontrado nessa maquina !!"
		Return (lRet)
	Endif
	OLE_SetProperty(cWord, oleWdVisible  ,.F. )
	//
	DbSelectArea ("SA2")
	SA2->(DbSetOrder (1))
	//
	bFiltraBrw := {|| FilBrowse ("SA2", @aIndexSA2, @cFiltraSA2)}
	Eval (bFiltraBrw)
	mBrowse (6, 1, 22, 75, "SA2")
   	EndFilBrw ("SA2", aIndexSA2)
   	//
   	OLE_CloseLink(cWord) //fecha o Link com o Word
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A982Impri ³ Autor ³Gustavo G. Rueda       ³ Data ³13.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que trata sobre a integracao.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL = lRet = .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A982Impri (cAlias, nReg, nOpcao)
	#IFDEF TOP
		Local	aCamposSE5	:=	{}
		Local	aStruSE5	:=	{}
	#ENDIF
	Local	lRet		:=	.T.
	Local	cQuery		:=	""
	Local	cAliasSe5	:=	"SE5"
	Local	nX			:=	0
	Local	cIndex		:=	""
	Local	nIndex		:=	0
	Local	aTrbs		:=	{}
	Local	nY			:=	0
	Local	lGerou		:=	.F.
	Local	lFornec		:=	.F.
	Local	nVar4Word	:=	30
	Local	nCtd4Word	:=	1
	Local	cChaveWhile	:=	""
	Local	nValRet		:=	0
	Local	cMV_PISNAT	:=	PadR( SuperGetMv( "MV_PISNAT" ) , TamSx3( "E2_NATUREZ" )[1])
	Local	cMV_CSLL	:=	PadR( SuperGetMv( "MV_CSLL" ) , TamSx3( "E2_NATUREZ" )[1])
	Local	cMV_COFINS	:=	PadR( SuperGetMv( "MV_COFINS" ) , TamSx3( "E2_NATUREZ" )[1])
	Local 	cMV_IRPJ	:= 	PadR( SuperGetMv( "MV_IRPJ" ) , TamSx3( "E2_NATUREZ" )[1])
	Local	cCodRet		:=	""
	Local	aSe5		:=	{}
	Local	cCodFornece	:=	Iif (nOpcao==3, SA2->A2_COD, "")
	Local	cLojFornece	:=	Iif (nOpcao==3, SA2->A2_LOJA, "")
	Local   cFilFornece :=  xFilial ("SA2")
	Local	cUniao		:=	AllTrim (SuperGetMv ("MV_UNIAO"))
	Local	aTit		:=	{}
	Local	lAchou		:=	.F.
	Local	nValTitPri	:=	0
	Local	aChaveTitPai:=	{}
	Local	cNomeArq	:=	"CompRet"
	Local	nNomeArq	:=	1
	Local 	cFilIni 	:= Iif(Empty(MV_PAR11),cFilAnt,MV_PAR11) 
	Local 	cFilFin 	:= Iif(Empty(MV_PAR12),cFilAnt,MV_PAR12) 
	Local 	cFilOri		:= SM0->M0_CODFIL     
    Local 	cCnpj		:= SM0->M0_CGC
	Local	cRazao		:= SM0->M0_NOME
	Local cSGBD         := TCGetDB()

	//Gestão de Empresas
	Local 	lSelFil     := Iif(MV_PAR14==1,.T.,.F.) 
	Local 	lAglFil     := Iif(MV_PAR15==1,.T.,.F.)
	Local 	aFilsCalc	:= {}  
	Local 	nForFilial	:= 0  
	Local 	aEmpresa	:= {}   
	Local 	nFil		:= 1
	Local 	cNoMovFil	:= ""
	Local   cNoComFil	:= ""

	cTipoR	 	:= Iif(MV_PAR13 == NIL,"",Iif(MV_PAR13 == 1,"1","2"))     
	aTrbs	:=	CriaTrb ()
	//
	DbSelectArea (cAliasSe5)
	(cAliasSe5)->(DbSetOrder (7))
	//	                               

	//Gestao corporativa
	If lSelFil      //Seleciona Filial = Sim
		aFilsCalc := MatFilCalc(lSelFil,,,lAglFil,,Iif(lAglFil,3,0)) //Parametro Exp6 Valida apenas CNPJ Raiz iguais
		If Empty( aFilsCalc )
			Return
		EndIf
		For nForFilial := 1 To Len( aFilsCalc )
			If aFilsCalc[ nForFilial, 1 ]
				aAdd(aEmpresa,{ IIf(!Empty(aFilsCalc[nForFilial][4]), aFilsCalc[nForFilial][4], Replic("0",14) ), cEmpAnt, aFilsCalc[nForFilial][2] } )
			EndIf
	    Next                                  
	EndIf 
	
	//Fim Gestão
    
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			aStruSE5	:=	(cAliasSe5)->(DbStruct ())
	   	    cAliasSe5	:=	"TOP"
	    	//
	    	aAdd (aCamposSE5, "E5_FILIAL")
	    	aAdd (aCamposSE5, "E5_PREFIXO")
	    	aAdd (aCamposSE5, "E5_NUMERO")
	    	aAdd (aCamposSE5, "E5_PARCELA")
	    	aAdd (aCamposSE5, "E5_TIPO")
	    	aAdd (aCamposSE5, "E5_NATUREZ")
	    	aAdd (aCamposSE5, "E5_CLIFOR")
	    	aAdd (aCamposSE5, "E5_LOJA")
	    	aAdd (aCamposSE5, "E5_VALOR")
	    	aAdd (aCamposSE5, "E5_DATA")
	    	aAdd (aCamposSE5, "E5_SEQ")
	    	aAdd (aCamposSE5, "E5_RECPAG")
	    	aAdd (aCamposSE5, "E5_AGLIMP")
	     EndIF	
	#ENDIF		    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle por filial.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cFilIni,.T.))
					                      
	While Iif(!lSelFil,!SM0->(Eof()) .And. FWGrpCompany() == cEmpAnt .And. FWCodFil() <= cFilFin, nFil <= Len(aEmpresa) )   //! SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilFin
		
		If !lSelFil
			cFilAnt:= SM0->M0_CODFIL
		Else
			cFilAnt:=aEmpresa[nFil,3] //cFilAnt:= SM0->M0_CODFIL
			SM0->(dbSeek(aEmpresa[nFil,3],.T.))
		EndIF
	
		#IFDEF TOP
		    If TcSrvType()<>"AS/400"
	   	    	cQuery	:=	"SELECT "
		    	For nX := 1 To (Len (aCamposSE5)-1)
		    		cQuery	+=	aCamposSE5[nX]+", "
		    	Next (nX)
	    		cQuery	+=	aCamposSE5[Len (aCamposSE5)]+" "
		    	cQuery	+=	"FROM "+RetSqlName ("SE5")+" "
		    	cQuery	+=	"WHERE E5_FILIAL='"+xFilial ("SE5")+"' AND SUBSTRING(E5_DATA, 1, 4)='"+StrZero (MV_PAR01, 4)+"' AND "
		    	cQuery	+=	"E5_NATUREZ IN('"+cMV_PISNAT+"', '"+cMV_COFINS+"', '"+cMV_CSLL+"', '"+Iif(cTipoR == "2",cMV_IRPJ,"")+"') AND E5_TIPO IN('"+MVTAXA+"') "
				cQuery	+=	"AND E5_CLIFOR='"+cUniao+"' AND 
				If cSGBD = 'ORACLE'
    				cQuery += "SUBSTR(E5_LOJA,1,2) = '00' "
				Else
   					cQuery += "LEFT(E5_LOJA,2) = '00' "
				EndIf "' AND E5_SITUACA='' AND E5_RECPAG='P' "
		    	cQuery	+=	"AND D_E_L_E_T_=' ' "
				cQuery	+=	"ORDER BY "+SqlOrder (SE5->(IndexKey ()))
		    	//
				cQuery := ChangeQuery (cQuery)
				DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSe5)
				//
				For nX := 1 To Len (aStruSE5)
					If (aStruSE5[nX][2]<>"C") .And. (FieldPos(aStruSE5[nX][1])<>0) .And. (aScan (aCamposSE5, AllTrim (aStruSE5[nX][1]))<>0)
						TcSetField (cAliasSe5, aStruSE5[nX][1], aStruSE5[nX][2], aStruSE5[nX][3], aStruSE5[nX][4])
					EndIf
				Next (nX)
				DbSelectArea (cAliasSe5)
		    Else
		#ENDIF
			cIndex		:= 	CriaTrab (Nil, .F.)
			cQuery		:=	'E5_FILIAL=="'+xFilial("SE5")+'" .And. StrZero (Year (E5_DATA), 4)=="'+StrZero (MV_PAR01, 4)+'" .And. '
			cQuery		+=	'AllTrim (E5_NATUREZ)$("'+cMV_PISNAT+','+cMV_COFINS+','+cMV_CSLL+','+Iif(cTipoR == "2",cMV_IRPJ,"")+'") .And. "TX"$E5_TIPO '
			cQuery		+=	'.And. "'+cUniao+'"$E5_CLIFOR .And. "00"$E5_LOJA .And. Empty (E5_SITUACA) .And. !E5_RECPAG$"R" '
			//
		    IndRegua (cAliasSe5, cIndex, (cAliasSe5)->(IndexKey()),, cQuery)
		    nIndex := RetIndex(cAliasSe5)
		    //
			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			//
			DbSelectArea (cAliasSe5)
		    DbSetOrder (nIndex+1)
		#IFDEF TOP
			EndIf
		#ENDIF
	    (cAliasSe5)->(DbGoTop ())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Crio um espelho da query para que eu possa processar em paralelo.      ³
		//³Ocorre casos de eu estar posicionado na tabela SE5 e precisar pesquisar³
		//³outro registro desta mesma tabela SE5, como nao posso utilizar         ³
		//³o controle pelo Recno, precisei criar esta temporaria.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nX	:=	aScan (aTrbs, {|x| x[1]=="TRB2"})
		If (nX<>0)
			Do While !((cAliasSe5)->(Eof ()))
				//
				aSe5	:=	{}
				aAdd (aSe5, (cAliasSe5)->E5_PREFIXO) 	//01
				aAdd (aSe5, (cAliasSe5)->E5_NUMERO)	//02
				aAdd (aSe5, (cAliasSe5)->E5_PARCELA)	//03
				aAdd (aSe5, (cAliasSe5)->E5_TIPO)		//04
				aAdd (aSe5, (cAliasSe5)->E5_CLIFOR)	//05
				aAdd (aSe5, (cAliasSe5)->E5_LOJA)		//06
				aAdd (aSe5, (cAliasSe5)->E5_VALOR)		//07
				aAdd (aSe5, (cAliasSe5)->E5_NATUREZA)	//08
				aAdd (aSe5, (cAliasSe5)->E5_DATA)		//09
				aAdd (aSe5, (cAliasSe5)->E5_RECPAG)	//10
				aAdd (aSe5, (cAliasSe5)->E5_SEQ)		//11
				aAdd (aSe5, (cAliasSe5)->E5_AGLIMP)	//12
				//
				(aTrbs[nX][1])->(RecLock (aTrbs[nX][1], .T.))
					(aTrbs[nX][1])->TRB_PREF	:=	aSe5[01]
					(aTrbs[nX][1])->TRB_NUM	:=	aSe5[02]
					(aTrbs[nX][1])->TRB_PARC	:=	aSe5[03]
					(aTrbs[nX][1])->TRB_TIPO	:=	aSe5[04]
					(aTrbs[nX][1])->TRB_FORN	:=	aSe5[05]
					(aTrbs[nX][1])->TRB_LOJA	:=	aSe5[06]
					(aTrbs[nX][1])->TRB_DATA	:=	aSe5[09]
					(aTrbs[nX][1])->TRB_VALOR	:=	aSe5[07]
					(aTrbs[nX][1])->TRB_AGLUT	:=	aSe5[12]
					(aTrbs[nX][1])->TRB_NATUR	:=	aSe5[08]
				(aTrbs[nX][1])->(MsUnLock ())
				//
				(cAliasSe5)->(DbSkip ())
			EndDo
		EndIf
		//
	    (cAliasSe5)->(DbGoTop ())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preparo o TRB com os conteudos corretos para impressao posterior.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nX	:=	aScan (aTrbs, {|x| x[1]=="TRB"})
		If (nX<>0)
			Do While !((cAliasSe5)->(Eof ()))
				aSe5	:=	{}
				aAdd (aSe5, (cAliasSe5)->E5_PREFIXO) 	//01
				aAdd (aSe5, (cAliasSe5)->E5_NUMERO)	//02
				aAdd (aSe5, (cAliasSe5)->E5_PARCELA)	//03
				aAdd (aSe5, (cAliasSe5)->E5_TIPO)		//04
				aAdd (aSe5, (cAliasSe5)->E5_CLIFOR)	//05
				aAdd (aSe5, (cAliasSe5)->E5_LOJA)		//06
				aAdd (aSe5, (cAliasSe5)->E5_VALOR)		//07
				aAdd (aSe5, (cAliasSe5)->E5_NATUREZA)	//08
				aAdd (aSe5, (cAliasSe5)->E5_DATA)		//09
				aAdd (aSe5, (cAliasSe5)->E5_RECPAG)	//10
				aAdd (aSe5, (cAliasSe5)->E5_SEQ)		//11
				aAdd (aSe5, (cAliasSe5)->E5_AGLIMP)	//12
				//
				If !(Empty (aSe5[12]))
					(cAliasSe5)->(DbSkip ())
					Loop
				EndIf
				//
				nY	:=	aScan (aTrbs, {|x| x[1]=="TRB2"})
				If (nY>0) .And. ((aTrbs[nY][1])->(MsSeek (aSe5[02]+aSe5[08])))
					//
					Do While !(aTrbs[nY][1])->(Eof ()) .And. aSe5[02]+aSe5[08]==((aTrbs[nY][1])->TRB_AGLUT+(aTrbs[nY][1])->TRB_NATUR)
						//
						cCodRet		:=	""
						cCodFornece	:=	Iif (nOpcao==3, SA2->A2_COD, "")
						cLojFornece	:=	Iif (nOpcao==3, SA2->A2_LOJA, "")
						cFilFornece :=  xFilial ("SA2")
						aTit		:=	{(aTrbs[nY][1])->TRB_PREF, (aTrbs[nY][1])->TRB_NUM, (aTrbs[nY][1])->TRB_PARC, (aTrbs[nY][1])->TRB_TIPO}
						lAchou		:=	MT982Pai (@nValRet, @cCodFornece, @cLojFornece, (aTrbs[nY][1])->TRB_TIPO, (aTrbs[nY][1])->TRB_NATUR, cMV_PISNAT, cMV_CSLL, cMV_COFINS, cAliasSe5, aTit, @cCodRet, cUniao, @nValTitPri, @aChaveTitPai,cMV_IRPJ)
						//
						If (lAchou)
							lGerou	:=	.T.
							If !(aTrbs[nX][1])->(DbSeek (StrZero (Year (aSe5[09]), 4)+cCodFornece+cLojFornece+StrZero (Month (aSe5[09]), 2)+cCodRet))
								(aTrbs[nX][1])->(RecLock (aTrbs[nX][1], .T.))
									(aTrbs[nX][1])->TRB_FORN	:=	cCodFornece
									(aTrbs[nX][1])->TRB_LOJA	:=	cLojFornece
									(aTrbs[nX][1])->TRB_ANO	:=	StrZero (Year (aSe5[09]), 4)
									(aTrbs[nX][1])->TRB_MES	:=	StrZero (Month (aSe5[09]), 2)
									(aTrbs[nX][1])->TRB_CODRET	:=	cCodRet
									(aTrbs[nX][1])->TRB_FILIAL	:=	cFilFornece
							Else
								(aTrbs[nX][1])->(RecLock (aTrbs[nX][1], .F.))
							EndIf
									(aTrbs[nX][1])->TRB_VLRPGO	+=	nValTitPri
									(aTrbs[nX][1])->TRB_VLRRET	+=	nValRet
								(aTrbs[nX][1])->(MsUnLock ())
						EndIf
						//
						(aTrbs[nY][1])->(DbSkip ())
					EndDo
				ElseIf (nY>0)
					cCodRet		:=	""
					cCodFornece	:=	Iif (nOpcao==3, SA2->A2_COD, "")
					cLojFornece	:=	Iif (nOpcao==3, SA2->A2_LOJA, "")
					cFilFornece :=  xFilial ("SA2")
					lAchou		:=	MT982Pai (@nValRet, @cCodFornece, @cLojFornece, (cAliasSe5)->E5_TIPO, (cAliasSe5)->E5_NATUREZ, cMV_PISNAT, cMV_CSLL, cMV_COFINS, cAliasSe5, {}, @cCodRet, cUniao, @nValTitPri, @aChaveTitPai,cMV_IRPJ)
					//
					If (lAchou)
						lGerou	:=	.T.
						If !(aTrbs[nX][1])->(DbSeek (StrZero (Year (aSe5[09]), 4)+cCodFornece+cLojFornece+StrZero (Month (aSe5[09]), 2)+cCodRet))
							(aTrbs[nX][1])->(RecLock (aTrbs[nX][1], .T.))
								(aTrbs[nX][1])->TRB_FORN	:=	cCodFornece
								(aTrbs[nX][1])->TRB_LOJA	:=	cLojFornece
								(aTrbs[nX][1])->TRB_ANO	:=	StrZero (Year (aSe5[09]), 4)
								(aTrbs[nX][1])->TRB_MES	:=	StrZero (Month (aSe5[09]), 2)
								(aTrbs[nX][1])->TRB_CODRET	:=	cCodRet
								(aTrbs[nX][1])->TRB_FILIAL	:=	cFilFornece
						Else
							(aTrbs[nX][1])->(RecLock (aTrbs[nX][1], .F.))
						EndIf
								(aTrbs[nX][1])->TRB_VLRPGO	+=	nValTitPri							
								(aTrbs[nX][1])->TRB_VLRRET	+=	nValRet
							(aTrbs[nX][1])->(MsUnLock ())
					EndIf
				EndIf
				//
				(cAliasSe5)->(DbSkip ())
			EndDo
			//
			If !lGerou
				If (nOpcao==3)
					Help (" ", 1, "SEMINF",,STR0045, 1, 0)
				Else
					Help (" ", 1, "SEMINF",,STR0048, 1, 0)
				EndIf
			EndIf
			//
			#IFDEF TOP
				DbSelectArea (cAliasSe5)
				(cAliasSe5)->(DbCloseArea ())
			#ELSE
			  	DbSelectArea (cAliasSe5)
				RetIndex (cAliasSe5)
				(cAliasSe5)->(DbClearFilter ())
				Ferase (cIndex+OrdBagExt())
			#ENDIF
			//
		EndIf
		SM0->(dbSkip())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta a empresa anteriormente selecionada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
	cFilAnt := SM0->M0_CODFIL
	
	//
	If (lGerou)
		If (cWord >= "0")		
			OLE_CloseLink(cWord) //fecha o Link com o Word
			cWord	:=	OLE_CreateLink ()
			If (cWord < "0")
				Help(" ",1,"A9810004") //"MS-WORD nao encontrado nessa maquina !!"
				Return (lRet)
			Endif
			//
			OLE_NewFile (cWord, cPath+cArquivo)
			If nOpcao==3
				OLE_SetProperty (cWord, oleWdVisible, .T.)
				OLE_SetProperty (cWord, oleWdPrintBack, .T.)
			Else
				OLE_SetProperty (cWord, oleWdVisible, .F.)
				OLE_SetProperty (cWord, oleWdPrintBack, .F.)
			EndIf
			//
			nX	:=	aScan (aTrbs, {|x| x[1]=="TRB"})
			If (nX<>0)
				//
				(aTrbs[nX][1])->(DbGoTop ())
				//
				Do While !((aTrbs[nX][1])->(Eof ()))
					//
						cChaveWhile	:=	(aTrbs[nX][1])->TRB_FILIAL+(aTrbs[nX][1])->TRB_FORN+(aTrbs[nX][1])->TRB_LOJA
					//
					DbSelectArea ("SA2")
						SA2->(MsSeek (cChaveWhile))  
						lFornece :=SA2->(MsSeek (cChaveWhile)) 
					//
					OLE_SetDocumentVar (cWord, "c_Calendario" , StrZero (MV_PAR01, 4))
					OLE_SetDocumentVar (cWord, "c_Nome1" , SM0->M0_NOME)
						OLE_SetDocumentVar (cWord, "c_Cnpj1" , Transform (cCnpj, "@R 99.999.999/9999-99"))
					OLE_SetDocumentVar (cWord, "c_Nome2" , SA2->A2_NOME)
					OLE_SetDocumentVar (cWord, "c_Cnpj2" , Transform (SA2->A2_CGC, "@R 99.999.999/9999-99"))
					//
					Do While !((aTrbs[nX][1])->(Eof ())) .And. (cChaveWhile==(aTrbs[nX][1])->TRB_FILIAL+(aTrbs[nX][1])->TRB_FORN+(aTrbs[nX][1])->TRB_LOJA)
						OLE_SetDocumentVar (cWord, "c_Mes"+AllTrim (Str (nCtd4Word)), MesExtenso (Val ((aTrbs[nX][1])->TRB_MES)))
						OLE_SetDocumentVar (cWord, "c_Codigo"+AllTrim (Str (nCtd4Word)), (aTrbs[nX][1])->TRB_CODRET)
						OLE_SetDocumentVar (cWord, "c_ValorPg"+AllTrim (Str (nCtd4Word)), Transform ((aTrbs[nX][1])->TRB_VLRPGO, "@E 999,999,999,999.99"))
						OLE_SetDocumentVar (cWord, "c_ValorRet"+AllTrim (Str (nCtd4Word)), Transform ((aTrbs[nX][1])->TRB_VLRRET, "@E 999,999,999,999.99"))
						//
						nCtd4Word++
						(aTrbs[nX][1])->(DbSkip ())
					EndDo
					//
					For nY := nCtd4Word To nVar4Word
						OLE_SetDocumentVar (cWord, "c_Mes"+AllTrim (Str (nY)), " ")
						OLE_SetDocumentVar (cWord, "c_Codigo"+AllTrim (Str (nY)), " ")
						OLE_SetDocumentVar (cWord, "c_ValorPg"+AllTrim (Str (nY)), " ")
						OLE_SetDocumentVar (cWord, "c_ValorRet"+AllTrim (Str (nY)), " ")
					Next (nX)
					nCtd4Word	:=	1
					//
					OLE_SetDocumentVar (cWord, "c_Nome5", AllTrim (MV_PAR04))
					//
					OLE_UpdateFields(cWord)
					//
						If (nOpcao==4) .and. lfornece 
						If (MV_PAR09==1)
							OLE_PrintFile(cWord,"ALL",,,)
						Else
							OLE_SaveAsFile (cWord, AllTrim (MV_PAR10)+cNomeArq+StrZero (nNomeArq++, 3)+".DOC" )
						EndIF
					EndIf
				EndDo
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Removo todos os temporarios criados pela funcao CriaTrb.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len (aTrbs)
		DbSelectArea (aTrbs[nX][1])
			(aTrbs[nX][1])->(DbCloseArea ())
		Ferase (aTrbs[nX][2]+GetDBExtension ())
		Ferase (aTrbs[nX][2]+OrdBagExt ())
	Next (nX)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CriaTrb   ³ Autor ³Gustavo G. Rueda       ³ Data ³13.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que trata sobre a criacao do arquivos de trabalho.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA = aRet = Array contendo {Alias, NomeTrb}               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTrb ()
	Local	aRet		:=	{}
	Local	aTrb		:=	{}
	Local	cAliasTrb	:=	""
	//
	aTrb	:=	{}
	//
	aAdd (aTrb, {"TRB_FORN",	"C",	TamSX3("A2_COD")[1],	TamSX3("A2_COD")[2]})
	aAdd (aTrb, {"TRB_LOJA",	"C",	TamSX3("A2_LOJA")[1],	TamSX3("A2_LOJA")[2]})
	aAdd (aTrb, {"TRB_MES",		"C",	02,	0})
	aAdd (aTrb, {"TRB_ANO",		"C",	04,	0})
	aAdd (aTrb, {"TRB_CODRET",	"C",	04,	0})
	aAdd (aTrb, {"TRB_VLRPGO",	"N",	16,	2})
	aAdd (aTrb, {"TRB_VLRRET",	"N",	16,	2})
	aAdd (aTrb, {"TRB_FILIAL",	"C",	TamSX3("A2_FILIAL")[1],	TamSX3("A2_FILIAL")[2]})
	//
	cAliasTrb	:=	CriaTrab (aTrb)
	DbUseArea (.T., __LocalDriver, cAliasTrb, "TRB")
	IndRegua ("TRB", cAliasTrb,"TRB_ANO+TRB_FORN+TRB_LOJA+TRB_MES+TRB_CODRET")
	//
	aAdd (aRet, {"TRB", cAliasTrb})
	//
	aTrb	:=	{}
	//
	aAdd (aTrb, {"TRB_PREF",	"C",	03,	0})
	aAdd (aTrb, {"TRB_NUM",		"C",	TamSX3("F2_DOC")[1],	0})
	aAdd (aTrb, {"TRB_PARC",	"C",	01,	0})
	aAdd (aTrb, {"TRB_TIPO",	"C",	03,	0})
	aAdd (aTrb, {"TRB_FORN",	"C",	TamSX3("A2_COD")[1],	TamSX3("A2_COD")[2]})
	aAdd (aTrb, {"TRB_LOJA",	"C",	TamSX3("A2_LOJA")[1],	TamSX3("A2_LOJA")[2]})
	aAdd (aTrb, {"TRB_AGLUT",	"C",	06,	0})
	aAdd (aTrb, {"TRB_DATA",	"D",	08,	0})
	aAdd (aTrb, {"TRB_VALOR",	"N",	16,	2})
	aAdd (aTrb, {"TRB_NATUR",	"C",	10,	0})
	//
	cAliasTrb	:=	CriaTrab (aTrb)
	DbUseArea (.T., __LocalDriver, cAliasTrb, "TRB2")
	IndRegua ("TRB2", cAliasTrb,"TRB_AGLUT+TRB_NATUR")
	//
	aAdd (aRet, {"TRB2", cAliasTrb})
Return (aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT982Pai  ³ Autor ³Gustavo G. Rueda       ³ Data ³11.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizada para posicionar a tabela SE2 no registro pai dos  ³±±
±±³          ³TX gerados na tabela SE5.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL = lAchou = .T.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nValRet -> Valor Retido a ser retornado pela funcao. Passado|±±
±±³          ³  por referencia.                                           ³±±      
±±³          ³cCodFornece -> Codigo do fornecedor.Passado por refetencia. ³±±
±±³          ³cLojFornece -> Loja do fornecedor. Passado por refetencia.  ³±±
±±³          ³cE5_TIPO -> Tipo do titulo baixado.                         ³±±
±±³          ³cE5_NATUREZ -> Natureza do titulo baixado.                  ³±±
±±³          ³cMV_PISNAT -> Natureza padrao para titulos TX PIS.          ³±±
±±³          ³cMV_CSLL -> Natureza padrao para titulos TX CSLL.           ³±±
±±³          ³cMV_COFINS -> Natureza padrao para titulos TX COFINS.       ³±±
±±³          ³cAliasSe5 -> Alias da tabela SE5 corrente.                  ³±±
±±³          ³aTit -> Prefixo+Numero+Parcela+Tipo do titulo que resultou o³±±
±±³          ³  aglutinado. Caso este array esteja vazio, nao esta sendo  ³±±
±±³          ³cCodRet -> Codigo de retencao de acordo com o SE2. Parametro³±±
±±³          ³  passado por referencia.                                   ³±±
±±³          ³cUniao -> Contem o conteudo do parametro MV_UNAO            |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion MT982Pai (nValRet, cCodFornece, cLojFornece, cE5_TIPO, cE5_NATUREZ, cMV_PISNAT, cMV_CSLL, cMV_COFINS, cAliasSe5,;
				 aTit, cCodRet, cUniao, nValTitPri, aChaveTitPai, cMV_IRPJ)
	Local	lAchou			:=	.F.
	Local	aAchou			:=	{.F., .F.}
	Local	cPrefixo 		:= 	Iif (Len (aTit)>0, aTit[1], (cAliasSe5)->E5_PREFIXO)
	Local	cNum			:= 	Iif (Len (aTit)>0, aTit[2], (cAliasSe5)->E5_NUMERO)
	Local	cParcela 		:= 	Iif (Len (aTit)>0, aTit[3], (cAliasSe5)->E5_PARCELA)
	Local	cTipoPai		:= 	Iif (Len (aTit)>0, aTit[4], (cAliasSe5)->E5_TIPO)
	Local	cParcPai 		:=	""
	Local	cValorPai		:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico qual campo de valor a ser verificado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cE5_TIPO$MVTAXA+"/"+MVTXA)
		Do Case
			Case (Alltrim (cE5_NATUREZ)$cMV_PISNAT)
				cValorPai 	:= 	"SE2->E2_PIS"
				cParcPai 	:= 	"E2_PARCPIS"
			Case (Alltrim (cE5_NATUREZ)$cMV_COFINS)
				cValorPai 	:=	"SE2->E2_COFINS"
				cParcPai 	:= 	"E2_PARCCOF"
			Case (Alltrim (cE5_NATUREZ)$cMV_CSLL)
				cValorPai	:=	"SE2->E2_CSLL"
				cParcPai 	:=	"E2_PARCSLL"
			Case (Alltrim (cE5_NATUREZ)$cMV_IRPJ)
				If cTipoR == "2"
					cValorPai	:=	"SE2->E2_IRRF"
					cParcPai 	:=	"E2_PARCIR"
				EndIf
			OtherWise
				cValorPai 	:=	""
				cParcPai 	:=	""
		EndCase	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura o titulo principal na tabela SE2 e o mantem posicionado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Empty (cVAlorPai)) .And. !(Empty (cParcPai))
		//
		DbSelectArea ("SE2")
			SE2->(DbSetOrder (1))
			nRegSE2	:=	SE2->(Recno ())
		If (SE2->(DbSeek (xFilial ("SE2")+cPrefixo+cNum)))
			Do While !(SE2->(Eof ())) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM)==(xFilial ("SE2")+cPrefixo+cNum)
				// Titulos TX
				If Empty (cCodRet) .And. "TX"$SE2->E2_TIPO .And. SE2->E2_PARCELA==cParcela .And.;
					AllTrim (cUniao)$SE2->E2_FORNECE .And. "00"$SE2->E2_LOJA
					cCodRet	:=	SE2->E2_CODRET
					aAchou[1]	:=	.T.
					//
				EndIf
				//
				//Titulo principal
				If ((SE2->E2_FORNECE+SE2->E2_LOJA>=MV_PAR05+MV_PAR07) .And. (SE2->E2_FORNECE+SE2->E2_LOJA<=MV_PAR06+MV_PAR08)) .And.;
					((Empty (cCodFornece+cLojFornece)) .Or. (SE2->E2_FORNECE+SE2->E2_LOJA==cCodFornece+cLojFornece))
					//
					If (&(cParcPai)==cParcela) .And. Iif (cTipoPai$MVTXA, SE2->E2_TIPO$MVPAGANT+"/"+MV_CPNEG, .T.)
						//
						If (&(cValorPai)!=0)					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³So gera o Valor do Titulo uma vez para cada título.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (aScan (aChaveTitPai, cPrefixo+cNum+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)==0)
								aAdd (aChaveTitPai, cPrefixo+cNum+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
								nValTitPri	:=	SE2->E2_VALOR+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_INSS+SE2->E2_ISS+SE2->E2_IRRF
							Else
								nValTitPri	:=	0
							EndIf
							//
							nValRet		:=	&(cValorPai)
							cCodFornece	:=	SE2->E2_FORNECE
							cLojFornece	:=	SE2->E2_LOJA
							//
							aAchou[2]	:=	.T.
						EndIf
						//
					EndIf
					//
				EndIF
				//
				If (aAchou[1] .And. aAchou[2])
					lAchou	:=	.T.
					Exit
				EndIf
				//
				SE2->(DbSkip ())
			Enddo
		EndIf
	EndIf
Return (lAchou)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
     
Private aRotina	:=	{	{ STR0002,"PesqBrw"   , 0 , 1 , 0 , .F.},;	//"Pesquisar"
								{ STR0003,"AxVisual"  , 0 , 2 , 0 , NIL},;	//"Visualizar"
								{ STR0004,"A982Impri" , 0 , 4 , 0 , NIL},;	//"Manual"
								{ STR0005,"A982Impri" , 0 , 4 , 0 , NIL}}	//"Automatica"


If ExistBlock("MT982MNU")
	ExecBlock("MT982MNU",.F.,.F.)
EndIf

Return(aRotina)

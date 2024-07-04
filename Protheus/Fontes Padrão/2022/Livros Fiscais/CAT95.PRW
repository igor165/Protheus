#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Cat95     ³ Autor ³Gustavo G. Rueda       ³ Data ³30.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para a Portaria CAT 95         ³±±
±±³          ³ que trata de informacoes (Reg. 88) para combustiveis.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Retorna em array o Alias e Nome dos TRB's criados.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPermitidos -> Array contendo todos os codigos de produtos  ³±±
±±³          ³ combustiveis permitidos para a geracao dos registros 88.   ³±±
±±³          ³nOpcao -> Verifica se esta funcao esta sendo utilizada para ³±±
±±³          ³ montagem dos TRB's que serao utilizados pelo CAT95.INI     ³±±
±±³          ³ ou se esta sendo chama para deletar os TRB's criados(OPC 2)³±±
±±³          ³aTrbs -> TRB's criados durante o processamento da funcao.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Cat95 (aPermitidos, nOpcao, aTrbs)
	Local	aRet		:=	{}
	Local	cCfop		:=	""
	Local	aReg88C		:=	{}
	Local	lTransp		:=	.F.
	Local	cCnpjE		:=	""
	Local	cUfE		:=	""
	Local	cIeE		:=	""	
	Local	cCnpjS		:=	""
	Local	cUfS		:=	""
	Local	cIeS		:=	""
	Local	cCnpjFrt	:=	"S/MOV.FISICA"
 	Local	cUfFrt		:=	""
 	Local	cIeFrt		:=	""
	Local	cModalFrt	:=	""
	Local	aTransp		:=	{}
	Local 	nCont       :=  0
	Local cSerieView	:= ""
	//
	Local	lMV_CAT95	:=	!"XXX"$GetNewPar ("MV_CAT95", "XXX")	
	Local	nMV_CAT95	:= 	Iif (lMV_CAT95, SB5->(FieldPos (SuperGetMv ("MV_CAT95"))), 0)
	//
	Local	lMV_95TR	:=	!"XXX"$GetNewPar ("MV_CAT95TR", "XXX")	
	Local	nMV_95TR	:= 	Iif (lMV_95TR, SF1->(FieldPos (SuperGetMv ("MV_CAT95TR"))), 0)
	//
	Local	lMV_SF2		:=	!"XXX"$GetNewPar ("MV_ENTSF2", "XXX")	
	Local	nMV_SF21	:= 	Iif (lMV_SF2, SF2->(FieldPos (&(SuperGetMv ("MV_ENTSF2"))[1])), 0)
	Local	nMV_SF22	:= 	Iif (lMV_SF2, SF2->(FieldPos (&(SuperGetMv ("MV_ENTSF2"))[2])), 0)
	Local	nMV_SF23	:= 	Iif (lMV_SF2, SF2->(FieldPos (&(SuperGetMv ("MV_ENTSF2"))[3])), 0)
	//
	Local	lMV_SF1		:=	!"XXX"$GetNewPar ("MV_ENTSF1", "XXX")	
	Local	nMV_SF11	:= 	Iif (lMV_SF1, SF1->(FieldPos (&(SuperGetMv ("MV_ENTSF1"))[1])), 0)
	Local	nMV_SF12	:= 	Iif (lMV_SF1, SF1->(FieldPos (&(SuperGetMv ("MV_ENTSF1"))[2])), 0)
	Local	nMV_SF13	:= 	Iif (lMV_SF1, SF1->(FieldPos (&(SuperGetMv ("MV_ENTSF1"))[3])), 0)
	//
	Local	lMV_P1		:=	!"XXX"$GetNewPar ("MV_CAT95P1", "XXX")	
	Local	nMV_P11		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[1])), 0)
	Local	nMV_P12		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[2])), 0)
	Local	nMV_P13		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[3])), 0)
	Local	nMV_P14		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[4])), 0)
	Local	nMV_P15		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[5])), 0)
	Local	nMV_P16		:=	Iif (lMV_P1, SF1->(FieldPos (&(SuperGetMv ("MV_CAT95P1"))[6])), 0)
	//
	Local	lMV_P2		:=	!"XXX"$GetNewPar ("MV_CAT95P2", "XXX")	
	Local	nMV_P21		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[1])), 0)
	Local	nMV_P22		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[2])), 0)
	Local	nMV_P23		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[3])), 0)
	Local	nMV_P24		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[4])), 0)
	Local	nMV_P25		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[5])), 0)
	Local	nMV_P26		:=	Iif (lMV_P2, SF2->(FieldPos (&(SuperGetMv ("MV_CAT95P2"))[6])), 0)
	//
	Default	nOpcao	:=	1
	Default	aTrbs	:=	{}
	//
	If (nOpcao==1)
		aRet		:=	Cat95Trb (1, aTrbs)
	Else
		aRet		:=	Cat95Trb (2, aTrbs)
		Return (aRet)
	EndIf
	//
	If (nMV_CAT95==0)
		Return (aRet)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribuindo valores para o Registro 88C³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB5->(DbSetOrder (1))
	//
	R54->(DbGoTop ())
	Do while !R54->(Eof ())
  	    If (SB5->(MsSeek (R54->A54_FILIAL+R54->A54_PRORI))) .And. (aScan (aPermitidos, SB5->(FieldGet (nMV_CAT95)))<>0)  	   
			nCont := aScan (aPermitidos, SB5->(FieldGet (nMV_CAT95)))
			If aPermitidos[nCont]<>"0000"				 		
				//		
				If (aScan (aReg88C, R54->A54_CNPJ+R54->A54_SERIE+R54->A54_NFISC+Iif (SubStr (R54->A54_CFOP, 1, 1)<"5","E","S"))==0)
					aAdd (aReg88C, R54->A54_CNPJ+R54->A54_SERIE+R54->A54_NFISC+Iif (SubStr (R54->A54_CFOP, 1, 1)<"5", "E", "S"))
				EndIf
				//			
				If (AllTrim (Left (R54->A54_CFOP, 3))$"199/299/599/699")
					cCfop	:=	Substr (R54->A54_CFOP, 1, 3)
				Else
					cCfop	:=	Substr (R54->A54_CFOP, 1, 4)
				EndIf
				RecLock ("C88", .T.)
					C88->C88_CNPJ	:=	AFISFILL (Num2Chr (Val (R54->A54_CNPJ), 14, 0), 14)
					C88->C88_MODELO	:=	AFISFILL (R54->A54_MODELO, 02)
					C88->C88_SERIE	:=	AFISFILL (FisGetSer (R54->A54_SERIE), 03) 
					C88->C88_SDOC		:=	AFISFILL (FisGetSer (R54->A54_SDOC), 03)
					C88->C88_NUMERO	:=	R54->A54_NFISC
					C88->C88_CFOP	:=	AFISFILL (Num2Chr (Val (cCfop), 04, 0), 04)
					C88->C88_NUMITE	:=	AFISFILL (FisGetSer (R54->A54_NUMITE), 03) 
					C88->C88_PRODUT	:=	AFISFILL (R54->A54_PRODUT, 14)
					C88->C88_QTD	:=	R54->A54_QUANT
					C88->C88_BCST	:=	Iif (Left (R54->A54_CFOP, 1)=="6", R54->A54_BSICM, 0)
					C88->C88_VLRST	:=	Iif (Left (R54->A54_CFOP, 1)=="6", R54->A54_VALICM, 0)
					C88->C88_VLRSTC	:=	Iif (Left (R54->A54_CFOP, 1)=="6", 0, 0)
					C88->C88_RET	:=	R54->A54_BRICMS
					C88->C88_PARCIM	:=	R54->A54_ICMRET
				MsUnLock ()
			EndIf	
		EndIf
		//
		R54->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribuindo valores para o Registro 88D e 88T³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF3->(DbSetOrder (4))
	SA4->(DbSetOrder (1))
	SA2->(DbSetOrder (1))
	SA1->(DbSetOrder (1))
	SF1->(DbSetOrder (1))
	SF2->(DbSetOrder (1))
	//
	R50->(DbGoTop ())
	Do While !R50->(Eof ())
		lTransp		:=	.F.
		cCnpj		:=	AFISFILL (Num2Chr (Val (R50->A50_CNPJ), 14, 0), 14)
		cIe			:=	AFISFILL (R50->A50_IE, 14)
		cUf			:=	AFISFILL (R50->A50_UF, 2)
		cModelo		:=	AFISFILL (R50->A50_MODELO, 2)
		cSerie			:=	AFISFILL (FisGetSer (R50->A50_SERIE), 3)
		cSerieView		:=	AFISFILL (FisGetSer (R50->A50_SDOC), 3)
		cNumero		:=	R50->A50_NFISC
		cEmitente	:=	R50->A50_EMIT
		cEmissao	:=	DToS (R50->A50_EMISS)
		cCnpjE		:=	""
		cUfE		:=	""
		cIeE		:=	""	
		cCnpjS		:=	""
		cUfS		:=	""
		cIeS		:=	""
 		cCnpjFrt	:=	"S/MOV.FISICA"
 		cUfFrt		:=	""
 		cIeFrt		:=	""
 		cModalFrt	:=	""
 		aTransp		:=	{}
		//
		If !(D88->(DbSeek (cCnpj+cIe+cUf+cModelo+cSerie+cNumero+cEmitente+cEmissao)))	//Nao gero duplicidade de chaves para o registro 88D
			//Verifico se foi gerado um registro 88C para este 88D
			If (aScan (aReg88C, R50->A50_CNPJ+R50->A50_SERIE+R50->A50_NFISC+Iif (SubStr (R50->A50_CFOP, 1, 1)<"5", "E", "S"))<>0)	
				//				
				If (SF3->(MsSeek (R50->A50_FILIAL+R50->A50_CLIENT+R50->A50_LOJA+R50->A50_NFISC+R50->A50_SERIE)))
					//
					//SAIDAS
					If (Left (AllTrim (R50->A50_CFOP), 1)>="5")
						//
						SF2->(MsSeek(R50->A50_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
						//
						If (SA4->(MsSeek(xFilial ("SA4")+SF2->F2_TRANSP)))
							lTransp		:=	.T.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Informacoes para o registro 88T³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 		cCnpjFrt	:=	AFISFILL (Num2Chr (Val (SA4->A4_CGC), 14, 0), 14)
					 		cUfFrt		:=	SA4->A4_EST
					 		cIeFrt		:=	SA4->A4_INSEST
 							//
				 			Do Case
				 				Case ("RODOVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"1"
									//
									aAdd (aTransp, Iif (nMV_P21==0, "", SF2->(FieldGet (nMV_P21))))
									aAdd (aTransp, Iif (nMV_P22==0, "", SF2->(FieldGet (nMV_P22))))
									aAdd (aTransp, Iif (nMV_P23==0, "", SF2->(FieldGet (nMV_P23))))
									aAdd (aTransp, Iif (nMV_P24==0, "", SF2->(FieldGet (nMV_P24))))
									aAdd (aTransp, Iif (nMV_P25==0, "", SF2->(FieldGet (nMV_P25))))
									aAdd (aTransp, Iif (nMV_P26==0, "", SF2->(FieldGet (nMV_P26))))
							 	Case ("FERROVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"2"
							 	Case ("RODOFERROVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"3"
							 	Case ("AQUAVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"4"
							 	Case ("DUTOVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"5"
							 	Case ("AEREO"$SA4->A4_VIA)
							 		cModalFrt	:=	"6"
							 	OtherWise
							 		cModalFrt	:=	"7"
							 EndCase
						EndIf
						//
						If (lTransp)
							cCnpjS	:=	AFISFILL (Num2Chr (Val (SM0->M0_CGC), 14, 0), 14)
							cUfS	:=	SM0->M0_ESTENT
							cIeS	:=	Iif (Empty (SM0->M0_INSC), "ISENTO", SM0->M0_INSC)
						EndIf
						//Para devolucao o Beneficiamento.
						If (SF3->F3_TIPO$"DB")
							//Verifico se o campo filial foi inseria na 3 posicao do Parametro array MV_ENTSF2
							If (nMV_SF23==0)		//Se o campo nao existir utilizo a funcao xFilial
								//
								If (nMV_SF21==0 .And. nMV_SF22==0) .Or. (Empty (SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
									SA2->(DbSeek (xFilial ("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
								Else
									SA2->(DbSeek (xFilial ("SA2")+SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
								EndIf
							Else	//Caso contrario utilizo o conteudo do campo filial criado na tabela SF2 e referenciado no parametro para posicionar a tabela SA2.
								//Verifico se o conteudo os campos mencionados nas posicoes 1 e 2 do Parametro array MV_ENTSF2 NAO estao preenchidos para que eu possa utilizar o conteudo dos campos padroes da tabela SF2.
								If (nMV_SF21==0 .And. nMV_SF22==0 .And. nMV_SF23==0) .Or. (Empty (SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))+SF2->(FieldGet (nMV_SF23))))
									SA2->(DbSeek (xFilial ("SF2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
								Else //Caso contrario utilizo o conteudo dos campos preenchidos e referenciados atraves do parametro MV_ENTSF2.
									SA2->(DbSeek (SF2->(FieldGet (nMV_SF23))+SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
								EndIf
							EndIf
							//
							If (lTransp)
								cCnpjE	:=	AFISFILL (Num2Chr (Val (SA2->A2_CGC), 14, 0), 14)
								cUfE	:=	SA2->A2_EST
								cIeE	:=	Iif (Empty (SA2->A2_INSCR), "ISENTO", SA2->A2_INSCR)
							EndIf
						Else	//Quando nao for DEVOLUCAO
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³As descricoes acima valem para este else tambem. Este else diferencia o posicionamento quando devolucao.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (nMV_SF23==0)	//Se a posicao da filial no paramentro estiver ""
								//
								If (nMV_SF21==0 .And. nMV_SF22==0) .Or. (Empty (SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
									SA1->(DbSeek (xFilial ("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
								Else
									SA1->(DbSeek (xFilial ("SA1")+SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
								EndIf
							Else
								//
								If (nMV_SF21==0 .And. nMV_SF22==0 .And. nMV_SF23==0) .Or. (Empty (SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))+SF2->(FieldGet (nMV_SF23))))
									SA1->(DbSeek (xFilial ("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
								Else
									SA1->(DbSeek (SF2->(FieldGet (nMV_SF23))+SF2->(FieldGet (nMV_SF21))+SF2->(FieldGet (nMV_SF22))))
								EndIf
							EndIf
						EndIf
						//
						If (lTransp)
							cCnpjE	:=	AFISFILL (Num2Chr (Val (SA1->A1_CGC), 14, 0), 14)
							cUfE	:=	SA1->A1_EST
							cIeE	:=	Iif (Empty (SA1->A1_INSCR), "ISENTO", SA1->A1_INSCR)
						EndIf
					//
					//ENTRADAS
					Else
						SF1->(MsSeek(R50->A50_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
						//
						If (nMV_95TR<>0) .And. (SA4->(MsSeek(xFilial ("SA4")+SF1->(FieldGet (nMV_95TR)))))
							lTransp		:=	.T.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Informacoes para o registro 88T³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 		cCnpjFrt	:=	AFISFILL (Num2Chr (Val (SA4->A4_CGC), 14, 0), 14)
					 		cUfFrt		:=	SA4->A4_EST
					 		cIeFrt		:=	SA4->A4_INSEST
 							//
				 			Do Case
				 				Case ("RODOVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"1"
									//
									aAdd (aTransp, Iif (nMV_P11==0, "", SF1->(FieldGet (nMV_P11))))
									aAdd (aTransp, Iif (nMV_P12==0, "", SF1->(FieldGet (nMV_P12))))
									aAdd (aTransp, Iif (nMV_P13==0, "", SF1->(FieldGet (nMV_P13))))
									aAdd (aTransp, Iif (nMV_P14==0, "", SF1->(FieldGet (nMV_P14))))
									aAdd (aTransp, Iif (nMV_P15==0, "", SF1->(FieldGet (nMV_P15))))
									aAdd (aTransp, Iif (nMV_P16==0, "", SF1->(FieldGet (nMV_P16))))
							 	Case ("FERROVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"2"
							 	Case ("RODOFERROVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"3"
							 	Case ("AQUAVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"4"
							 	Case ("DUTOVIARIO"$SA4->A4_VIA)
							 		cModalFrt	:=	"5"
							 	Case ("AEREO"$SA4->A4_VIA)
							 		cModalFrt	:=	"6"
							 	OtherWise
							 		cModalFrt	:=	"7"
							 EndCase
						EndIf
						//
						If (lTransp)
							cCnpjE	:=	AFISFILL (Num2Chr (Val (SM0->M0_CGC), 14, 0), 14)
							cUfE	:=	SM0->M0_ESTENT
							cIeE	:=	Iif (Empty (SM0->M0_INSC),"ISENTO", SM0->M0_INSC)
						EndIf
						//
						//Para devolucao o Beneficiamento.
						If (SF3->F3_TIPO$"DB")
							//Verifico se o campo filial foi inseria na 3 posicao do Parametro array MV_ENTSF1
							If (nMV_SF13==0)		//Se o campo nao existir utilizo a funcao xFilial
								//
								If (nMV_SF11==0 .And. nMV_SF12==0) .Or. (Empty (SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
									SA1->(DbSeek (xFilial ("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
								Else
									SA1->(DbSeek (xFilial ("SA1")+SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
								EndIf
							Else	//Caso contrario utilizo o conteudo do campo filial criado na tabela SF1 e referenciado no parametro para posicionar a tabela SA1.
								//Verifico se o conteudo os campos mencionados nas posicoes 1 e 2 do Parametro array MV_ENTSF1 NAO estao preenchidos para que eu possa utilizar o conteudo dos campos padroes da tabela SF1.
								If (nMV_SF11==0 .And. nMV_SF12==0 .And. nMV_SF13==0) .Or. (Empty (SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))+SF1->(FieldGet (nMV_SF13))))
									SA1->(DbSeek (xFilial ("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
								Else //Caso contrario utilizo o conteudo dos campos preenchidos e referenciados atraves do parametro MV_ENTSF1.
									SA1->(DbSeek (SF1->(FieldGet (nMV_SF13))+SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
								EndIf
							EndIf
							//
							If (lTransp)
								cCnpjS	:=	AFISFILL (Num2Chr (Val (SA1->A1_CGC), 14, 0), 14)
								cUfS	:=	SA1->A1_EST
								cIeS	:=	Iif (Empty (SA1->A1_INSCR), "ISENTO", SA1->A1_INSCR)
							EndIf
						Else	//Quando nao for DEVOLUCAO
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³As descricoes acima valem para este else tambem. Este else diferencia o posicionamento quando devolucao.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (nMV_SF23==0)
								//
								If (nMV_SF11==0 .And. nMV_SF12==0) .Or. (Empty (SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
									SA2->(DbSeek (xFilial ("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
								Else
									SA2->(DbSeek (xFilial ("SA2")+SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
								EndIf
							Else
								//
								If (nMV_SF11==0 .And. nMV_SF12==0 .And. nMV_SF13==0) .Or. (Empty (SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))+SF1->(FieldGet (nMV_SF13))))
									SA2->(DbSeek (xFilial ("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
								Else
									SA2->(DbSeek (SF1->(FieldGet (nMV_SF13))+SF1->(FieldGet (nMV_SF11))+SF1->(FieldGet (nMV_SF12))))
								EndIf
							EndIf
							//
							If (lTransp)
								cCnpjS	:=	AFISFILL (Num2Chr (Val (SA2->A2_CGC), 14, 0), 14)
								cUfS	:=	SA2->A2_EST
								cIeS	:=	Iif (Empty (SA2->A2_INSCR), "ISENTO", SA2->A2_INSCR)
							EndIf
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribuindo valores para o Registro 88D      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock ("D88", .T.)
						D88->D88_CNPJ	:=	cCnpj
						D88->D88_IE		:=	cIe
						D88->D88_UF		:=	cUf
						D88->D88_MODELO	:=	cModelo
						D88->D88_SERIE	:=	cSerie
						D88->D88_SDOC		:=	cSerieView
						D88->D88_NUMERO	:=	cNumero
						D88->D88_EMIT	:=	cEmitente
						D88->D88_DTEMIS	:=	cEmissao
						D88->D88_DTSAID	:=	If (lTransp, DToS (SF3->F3_ENTRADA), "")
						D88->D88_CNPJS	:=	cCnpjS
						D88->D88_UFS	:=	cUfS
						D88->D88_IES	:=	cIeS
						D88->D88_CNPJE	:=	cCnpjE
						D88->D88_UFE	:=	cUfE
						D88->D88_IEE	:=	cIeE
					MsUnLock ()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribuindo valores para o Registro 88T      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(T88->(DbSeek (cCnpj+cUf+cModelo+cSerie+cNumero+cEmitente)))
						RecLock ("T88", .T.)
							T88->T88_CNPJ	:=	cCnpj
							T88->T88_DTEMIS	:=	DToS (R50->A50_EMISS)
							T88->T88_UF		:=	cUf
							T88->T88_MODELO	:=	cModelo
							T88->T88_SERIE	:=	cSerie
							T88->T88_SDOC		:=	cSerieView
							T88->T88_NUMERO	:=	cNumero
							T88->T88_EMIT	:=	cEmitente
							T88->T88_CIFFOB	:=	"1"
							T88->T88_CNPJF	:=	cCnpjFrt
							T88->T88_UFF	:=	cUfFrt
							T88->T88_IEF	:=	cIeFrt
							T88->T88_MODAL	:=	cModalFrt
							T88->T88_PL1	:=	Iif ("1"$cModalFrt, aTransp[1], "")
							T88->T88_UF1	:=	Iif ("1"$cModalFrt, aTransp[2], "")
							T88->T88_PL2	:=	Iif ("1"$cModalFrt, aTransp[3], "")
							T88->T88_UF2	:=	Iif ("1"$cModalFrt, aTransp[4], "")
							T88->T88_PL3	:=	Iif ("1"$cModalFrt, aTransp[5], "")
							T88->T88_UF3	:=	Iif ("1"$cModalFrt, aTransp[6], "")
						MsUnLock ()
					EndIf
				EndIf
			EndIf
		EndIf
		//
		R50->(DbSkip ())
	EndDo
Return (aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Cat95Trb  ³ Autor ³Gustavo G. Rueda       ³ Data ³30.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos TRB's a serem utilizados no processaento.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aTrbs -> Retorna em array o Alias e Nome dos TRB's criados. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao -> Verifica se esta funcao esta sendo utilizada para ³±±
±±³          ³ montagem dos TRB's que serao utilizados pelo CAT95.INI     ³±±
±±³          ³ ou se esta sendo chama para deletar os TRB's criados(OPC 2)³±±
±±³          ³aDel -> TRB's criados durante o processamento da funcao.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cat95Trb (nOpcao, aDel)
	Local	aTrbs	:=	{}
	Local	aStru	:=	{}
	Local	nI		:=	0
	Local	cArq	:=	""
	//
	If (nOpcao==1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do trb para o registro 88C.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aAdd (aStru, {"C88_CNPJ",	"C",	014,	0})
		aAdd (aStru, {"C88_MODELO",	"C",	002,	0})
		aAdd (aStru, {"C88_SERIE",	"C",	TamSX3("F2_SERIE")[1],	0})
		aAdd (aStru, {"C88_SDOC",	"C",	003,	0})
		aAdd (aStru, {"C88_NUMERO",	"C",	TamSX3("F2_DOC")[1],	0})
		aAdd (aStru, {"C88_CFOP",	"C",	004,	0})
		aAdd (aStru, {"C88_NUMITE",	"C",	003,	0})
		aAdd (aStru, {"C88_PRODUT",	"C",	014,	0})
		aAdd (aStru, {"C88_QTD",	"N",	011,	3})
		aAdd (aStru, {"C88_BCST",	"N",	012,	2})
		aAdd (aStru, {"C88_VLRST",	"N",	012,	2})
		aAdd (aStru, {"C88_VLRSTC",	"N",	012,	2})
		aAdd (aStru, {"C88_RET",	"N",	012,	2})
		aAdd (aStru, {"C88_PARCIM",	"N",	012,	2})
		//
		cArq  :=	CriaTrab (aStru)
		dbUseArea (.T., __LocalDriver, cArq,"C88")
		IndRegua ("C88", cArq, "C88_CNPJ+C88_SERIE+C88_NUMERO+C88_NUMITE")
		aAdd (aTrbs, {"C88", cArq})             
		
		
		dbClearIndex()	
		cIndex2	:= CriaTrab(NIL,.F.)
		cKey	:= 'C88_CNPJ+C88_SERIE+C88_NUMERO+C88_CFOP+C88_NUMITE'   
		IndRegua("C88",cIndex2,cKey)     
		dbClearIndex()
	
		dbSelectArea("C88")
		dbSetIndex(cArq+OrdBagExt())
		dbSetIndex(cIndex2+OrdBagExt())
		dbSetorder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do trb para o registro 88D.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aStru	:=	{}
		aAdd (aStru, {"D88_CNPJ",		"C",	014,	0})
		aAdd (aStru, {"D88_IE",			"C",	014,	0})
		aAdd (aStru, {"D88_UF",			"C",	002,	0})
		aAdd (aStru, {"D88_MODELO",		"C",	002,	0})
		aAdd (aStru, {"D88_SERIE",		"C",	TamSX3("F2_SERIE")[1],	0})
		aAdd (aStru, {"D88_SDOC",		"C",	003,	0})
		aAdd (aStru, {"D88_NUMERO",		"C",	TamSX3("F2_DOC")[1],	0})
		aAdd (aStru, {"D88_EMIT",		"C",	001,	0})
		aAdd (aStru, {"D88_DTEMIS",		"C",	008,	0})
		aAdd (aStru, {"D88_DTSAID",		"C",	008,	0})
		aAdd (aStru, {"D88_CNPJS",		"C",	014,	0})
		aAdd (aStru, {"D88_UFS",		"C",	002,	0})
		aAdd (aStru, {"D88_IES",		"C",	014,	0})
		aAdd (aStru, {"D88_CNPJE",		"C",	014,	0})
		aAdd (aStru, {"D88_UFE",		"C",	002,	0})
		aAdd (aStru, {"D88_IEE",		"C",	014,	0})	
		//
		cArq  :=	CriaTrab (aStru)
		dbUseArea (.T., __LocalDriver, cArq, "D88")
		IndRegua ("D88", cArq, "D88_CNPJ+D88_IE+D88_UF+D88_MODELO+D88_SERIE+D88_NUMERO+D88_EMIT+D88_DTEMIS")
		aAdd (aTrbs, {"D88", cArq})	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do trb para o registro 88E.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aStru	:=	{}
		aAdd (aStru, {"T88_CNPJ",		"C",	014,	0})
		aAdd (aStru, {"T88_DTEMIS",		"C",	008,	0})
		aAdd (aStru, {"T88_UF",			"C",	002,	0})
		aAdd (aStru, {"T88_MODELO",		"C",	002,	0})
		aAdd (aStru, {"T88_SERIE",		"C",	TamSX3("F2_DOC")[1],	0})
		aAdd (aStru, {"T88_SDOC",		"C",	003,	0})
		aAdd (aStru, {"T88_NUMERO",		"C",	TamSX3("F2_DOC")[1],	0})
		aAdd (aStru, {"T88_EMIT",		"C",	001,	0})
		aAdd (aStru, {"T88_CIFFOB",		"C",	001,	0})
		aAdd (aStru, {"T88_CNPJF",		"C",	014,	0})
		aAdd (aStru, {"T88_UFF",		"C",	002,	0})
		aAdd (aStru, {"T88_IEF",		"C",	014,	0})	
		aAdd (aStru, {"T88_MODAL",		"C",	001,	0})
		aAdd (aStru, {"T88_PL1",		"C",	007,	0})
		aAdd (aStru, {"T88_UF1",		"C",	002,	0})
		aAdd (aStru, {"T88_PL2",		"C",	007,	0})
		aAdd (aStru, {"T88_UF2",		"C",	002,	0})
		aAdd (aStru, {"T88_PL3",		"C",	007,	0})
		aAdd (aStru, {"T88_UF3",		"C",	002,	0})
		//
		cArq  :=	CriaTrab (aStru)
		dbUseArea (.T., __LocalDriver, cArq, "T88")
		IndRegua ("T88", cArq, "T88_CNPJ+T88_UF+T88_MODELO+T88_SERIE+T88_NUMERO+T88_EMIT")
		aAdd (aTrbs, {"T88", cArq})	
	Else
		For nI:= 1 To Len (aDel)
			If (File (aDel[nI,1]+GetDBExtension ()))
				DbSelectArea (aDel[ni,2])
				DbCloseArea ()
				Ferase (aDel[nI,1]+GetDBExtension ())
				Ferase (aDel[nI,1]+OrdBagExt ())
			Endif	
		Next
	EndIf
Return (aTrbs)

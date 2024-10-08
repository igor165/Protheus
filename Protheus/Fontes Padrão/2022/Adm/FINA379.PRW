#Include "FINA379.CH"
#Include "PROTHEUS.CH"
#INCLUDE "FONT.CH"

Static lBlind	:= IsBlind()
Static lFWCodFil := .T.
Static dLastPcc  	:= CTOD("22/06/2015")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINA379	� Autor � Adrianne Furtado	     � Data � 03.04.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de apura��o dos impostos Pis, Cofins e 				  ���
���          � CSLL que permite desfazer/descalcular t�tulos de impostos, ���
���          � quando gerados atrav�s de border� e tornando-se indevidos  ���
���          � posteriomente com rela��o ao valor m�nimo de reten��o      ���
���          � (par�metro MV_VL10925).									  			  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SigaFin - FINA379										 				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA379()
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local nX				:= 0
Local aBackMVPAR		:= {}

aPar379 := If (Type("aPar379") != "A",{},aPar379)

If cPaisLoc == "BRA"
	If GetMv("MV_BX10925") <> "1"
		//"Atencao""Essa rotina calcula a diferenca de impostos Pis, Cofins e CSLL gerados na baixa (MV_BX10925 = '1').""Ok"
		If !lBlind
			Aviso(STR0004,STR0007,{STR0006})
		Endif
		Return()
	EndIf

	If !Empty(aPar379) .or. lBlind //Chamada semi-automatica ou via schedule
		Pergunte("FIN379",.F.)   //Pergunta para chamada da rotina semi-automatica
		nOpca := 1
		lBlind := .T.
		If !Empty(aPar379) //Se chamada semi-automatica
			aAdd( aBackMVPAR , MV_PAR01 )
			aAdd( aBackMVPAR , MV_PAR02 )
			aAdd( aBackMVPAR , MV_PAR03 )
			aAdd( aBackMVPAR , MV_PAR04 )
			aAdd( aBackMVPAR , MV_PAR05 )
			MV_PAR01 := aPar379[1]	//Mes do periodo
			MV_PAR02 := aPar379[2]	//Ano do periodo
			MV_PAR03 := aPar379[3]	//Fornecedor De
			MV_PAR04 := aPar379[4]	//Fornecedor Ate
			MV_PAR05 := aPar379[5]	//Mostra Tela Contabilizacao
		Endif
	Else
		Pergunte("FIN379",.T.)  //Pergunta para chamada da rotina via menu
		Private cCadastro	:= OemToAnsi(STR0001)  //"Verificacao dos titulos de PCC - OffLine"
	
		Aadd(aSays,OemToAnsi(STR0002)) //"Este programa tem como objetivo permitir verifica��o dos impostos Pis, "
		Aadd(aSays,OemToAnsi(STR0003)) //"Cofins e CSLL gerados por meio de border�, em rela��o ao valor "
		Aadd(aSays,OemToAnsi(STR0025)) //"m�nimo de reten��o (par�metro MV_VL10925)."
	
		AADD(aButtons, { 5,.T.,{|| Pergunte("FIN379",.T.) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	
		FormBatch( cCadastro, aSays, aButtons)// ,,,428)
	EndIf

	//��������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                   �
	//�========================================================�
	//� mv_par01 // M�s                                        �
	//� mv_par02 // Ano			                                �
	//� mv_par03 // De Fornecedor							  			  �
	//� mv_par04 // At� Fornecedor                             �
	//� mv_par05 // Mostra tela contabilizacao                 �
	//����������������������������������������������������������
	If nOpca == 1
		If Empty(mv_par01) .or. Empty(mv_par02)
			//"Atencao","As perguntas devem estar preenchidas.""Ok"
			If !lBlind
				Aviso(STR0004,STR0009,{STR0006})
			Endif
			Return()
		EndIf
		If !lBlind .and. ((mv_par02 > Year(dDataBase)) .or.;
			((mv_par01 > Month(dDatabase)) .and. (mv_par02 == Year(dDataBase))))
			//"O per�odo mes+ano selecionado � posterior a DataBase."
			//"Deseja continuar mesmo assim?""Aten��o"
			If !MsgYesNo(STR0010+Chr(13)+STR0011,STR0004)
				Return()
			EndIf
		EndIf
	
		Processa({|| Fina379Apur(nOpca)})
	Endif
	
	If lBlind .And. !Empty( aBackMVPAR )
		MV_PAR01 := aBackMVPAR[ 1 ]
		MV_PAR02 := aBackMVPAR[ 2 ]
		MV_PAR03 := aBackMVPAR[ 3 ]
		MV_PAR04 := aBackMVPAR[ 4 ]
		MV_PAR05 := aBackMVPAR[ 5 ]
	EndIf
EndIf

aSize( aBackMVPAR , 0 )
aBackMVPAR := Nil

Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINA379	� Autor � Adrianne Furtado		  � Data � 03.04.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para montagem dos titulos de Pis, Cofins e CSLL - ���
���          � OffLine																	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SigaFin - FINA379														  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fina379Apur(nOpca)
Local cForneceOld	:= ""
Local dDataIni
Local dDataFin
Local nX, nY, nI
Local nDiaFim		:= 31
Local nDifRet		:= 0
Local cForUniao		:= GetMv("MV_UNIAO")
Local cSepNeg   	:= If("|"$MV_CPNEG,"|",",")
Local cSepProv  	:= If("|"$MVPROVIS,"|",",")
Local cSepRec   	:= If("|"$MVPAGANT,"|",",")
Local nConta		:=	0
Local aFiliais 		:= {}
Local cFilOld		:= cFilAnt
Local lTodasFil 	:= .F.
Local lMostraLC		:=	mv_par05 == 1
Local lPergunta 	:= .F.
Local lRecalc		:= .F. //Verifica se teve que recalcular.
Local lMultFil		:= .F.
Local aExcluidos	:= {}
Local cListBox
Local cAtuFilial
Local cForneDe		:= MV_PAR03
Local cForneAte		:= MV_PAR04
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local nVlMinImp		:= GetNewPar("MV_VL10925",5000)

Public aDadosRef 	:= Array(7)
Public aDadosRet 	:= Array(7)
Public aDados379	:= Array(2)
Public aBaixa		:= {}
Public nValPgto 	:= 0
Public nOldValPgto	:= 0
Public nPis 		:= 0
Public nCofins		:= 0
Public nCsll		:= 0
Public nIss			:= 0
Public nIrrf		:= 0
Public lMsErroAuto  := .F.

dDataIni := CToD("01/"+Str(mv_par01)+"/"+Str(mv_par02))
While CToD(Str(nDiaFim)+Str(mv_par01)+"/"+Str(mv_par02)) == CToD("  /  /  ")
	nDiaFim --
EndDo
dDataFim := CToD(Str(nDiaFim)+Str(mv_par01)+"/"+Str(mv_par02))
While Len(cForUniao) < Len(SE2->E2_FORNECE)
	cForUniao := cForUniao + " "
EndDo

//multi-filiais
If !Empty(xFilial( "SE2")) .And. !Empty(xFilial("SE5"))
	lMultFil := .T.
	aFiliais := {}

	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt
			AADD( aFiliais, aSM0[nInc][2] )
		EndIf
	Next
Else
	AADD(aFiliais,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
EndIf

If nOpca == 1

	If !lBlind
		If GetMv("MV_CANBORP") == "S"
			//"Atencao"
			//"O parametro MV_CANBORP est� preenchido com 'S'. Quando a rotina de apura��o cancelar as baixas referentes aos TXs"
			//" o t�tulo principal ser� retirado do bordero. Tem certeza que deseja continuar?"
			If !MsgYesNo(STR0016+STR0017, STR0004)
				//"O parametro MV_CANBORP est� preenchido com 'N', ao cancelar as baixas dos TX o sistema voltar� o saldo do t�tulo pai."+;
				//"por�m n�o ir� retirar o t�tulo pai do border�."
				Aviso(STR0004,STR0018+STR0019,{STR0006})
				Return()
			EndIf
		Else
			//"O parametro MV_CANBORP est� preenchido com 'N', ao cancelar as baixas dos TX o sistema voltar� o saldo do t�tulo pai."+;
			//"por�m n�o ir� retirar o t�tulo pai do border�."
			Aviso(STR0004,STR0018+STR0019,{STR0006})
		EndIf
	Endif

	For nI := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nI]

		DbSelectArea("SE2")
		DbSetOrder(6)
		If lMultFil
			cAtuFilial := aFiliais[nI]
		Else
			cAtuFilial := xFilial("SE2")
		Endif

		cQuery := "SELECT R_E_C_N_O_ RECSE2 FROM "+RetSqlName("SE2")+" WHERE "
		cQuery += "E2_FILIAL='"+cAtuFilial+"' AND "
		cQuery += "E2_FORNECE BETWEEN '"+cForneDe+"' AND '"+cForneAte+"' AND "
		//oU O BORDERO ESTA PREENCHIDO, OU TEVE MOVIMENTO A PARTIR DA DATA DE INICIO
		cQuery += "((E2_NUMBOR <> '' AND E2_DTBORDE BETWEEN '"+Dtos( dDataIni) +"' AND '"+Dtos( dDataFim) +"') OR E2_MOVIMEN >='"+Dtos( dDataIni) +"') AND "
		cQuery += "(E2_PRETPIS <> '1' OR E2_PRETCOF <> '1' OR E2_PRETCSL <> '1' ) AND "
		cQuery += "E2_TIPO <>'TX ' AND "
		cQuery += "E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
		cQuery += "E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
		cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
		cQuery += "E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " AND "

		cQuery += "D_E_L_E_T_<>'*'  "
		cQuery += " ORDER BY "+SqlOrder(SE2->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		cNextAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

		aDados379	:=	{{},0}
		DbSelectArea('SE2')
		DbGoTo((cNextAlias)->RECSE2)
		cForneceOld	:= SE2->E2_FORNECE
		While !(cNextAlias)->(EOF())
			DbSelectArea("SE2")
			AADD(aDados379[1],{SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ,SE2->E2_PARCCOF,SE2->E2_PARCPIS,SE2->E2_PARCSLL})
			If Alltrim(SE2->E2_NUMBOR) <> ""
				aDados379[2]	+=	xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1)
			EndIf
			If SE2->E2_SALDO <> SE2->E2_VALOR
				SE5->(MsSeek(SE2->E2_FILIAL))
				aBaixaSE5 := {}
				Sel080Baixa("VL /BA /CP /",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,0,0,SE2->E2_FORNECE,SE2->E2_LOJA,.F.,.F.,.F.,0,.F.,.T.)
				For nY := 1 to Len(aBaixaSE5)
					If aBaixaSE5[nY][7] >=dDataIni .And. aBaixaSE5[nY][7] <= dDataFim
						aDados379[2] += SE5->E5_VALOR
					EndIf
				Next
			Endif

			(cNextAlias)->(DbSkip())
			If (cNextAlias)->(Eof())
				Exit
			EndIf
			
			// Valida data da nova lei de PCC VL13137
			If dDataBase >= dLastPcc
				nVlMinImp	:= 0				
			EndIf
			
			DbSelectArea("SE2")
			MsGoTo((cNextAlias)->RECSE2)
			If (SE2->E2_FORNECE <> cForneceOld) .and. (cForneceOld <> GetMv("MV_MUNIC"));
				.and. (cForneceOld <> GetMv("MV_FORINSS")) .and. (cForneceOld <> GetMv("MV_UNIAO"))
				If aDados379[2] < nVlMinImp .and. aDados379[2]<>0
					//verifica o que est� retido
					aArea := SE2->(GetArea())
					SE2->(DbSetOrder(1))
					For nX := 1 To Len(aDados379[1])
						For nY := 9 to 11
							//verificar se j� est� baixado por da��o e originado dessa rotina
							If SE2->(DbSeek(aDados379[1,nX,1]+aDados379[1,nX,2]+aDados379[1,nX,3]+aDados379[1,nX,nY]+GetSESNew("TX ")+cForUniao))
								nDifRet += SE2->E2_SALDO
							EndIf
						Next nY
					Next nX
					RestArea(aArea)

					//"H� casos de fornecedores que reteram impostos, por�m a soma dos t�tulos baixados � inferior ao "
					//"valor m�nimo informado no par�metro MV_VL10925."
					//"Deseja que esses t�tulos de impostos sejam cancelados?"
					//"Aten��o - Fornecedor: "
					If nDifRet >0 .and. (lBlind .or. lPergunta .or. MsgYesNo(STR0012+STR0013+STR0014,;
												 STR0004))
						lPergunta := .T.
						aArea := SE2->(GetArea())
						SE2->(DbSetOrder(1))
						//cancelar os t�tulos de impostos
						For nX := 1 To Len(aDados379[1])
							ProcRegua(Len(aDados379[1,nX])-8)
							For nY := 9 to 11
								If SE2->(MsSeek(aDados379[1,nX,1]+aDados379[1,nX,2]+aDados379[1,nX,3]+aDados379[1,nX,nY]+GetSESNew("TX ")+cForUniao)) .And. SE2->E2_SALDO > 0									//montar array com as informa��es dos TX que dever�o ser baixados.
									If nY == 9
										//"Principal: "
										Aadd(aExcluidos,STR0022+aDados379[1,nX,1]+aDados379[1,nX,2]+aDados379[1,nX,3]+aDados379[1,nX,4]+aDados379[1,nX,5]+aDados379[1,nX,6])
									EndIf
									Aadd(aExcluidos,aDados379[1,nX,1]+aDados379[1,nX,2]+aDados379[1,nX,3]+aDados379[1,nX,nY]+GetSESNew("TX ")+cForUniao)
									//"Excluindo: "
									IncProc(STR0015 + cForneceOld + STR0023+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))
									lMsErroAuto := .F.
									aBaixa		:= {}
									AADD(aBaixa,{'E2_FILIAL',SE2->E2_FILIAL,Nil})
									AADD(aBaixa,{'E2_PREFIXO',SE2->E2_PREFIXO,Nil})
									AADD(aBaixa,{'E2_NUM',SE2->E2_NUM,Nil})
									AADD(aBaixa,{'E2_PARCELA',SE2->E2_PARCELA,Nil})
									AADD(aBaixa,{'E2_TIPO',SE2->E2_TIPO,Nil})
									AADD(aBaixa,{'E2_FORNECE',SE2->E2_FORNECE,Nil})
									AADD(aBaixa,{'E2_LOJA',SE2->E2_LOJA,Nil})
									//Apagar os impostos indevidos
									MSExecAuto({|a,b,c,d,e,f,g| Fina050(a,b,c,d,e,f,g)}, aBaixa, ,5,,,lMostraLC,.T.)
									If lMsErroAuto
										MostraErro()
									EndIf
									lRecalc	  := .T.
								EndIf
							Next nY
						Next nX

						SE2->(DbSetOrder(1))
						//Cancelar as baixas referentes aos impostos que foram excluidos
						For nX := 1 To Len(aDados379[1])
							SE2->(DbSeek(aDados379[1,nX,1]+aDados379[1,nX,2]+aDados379[1,nX,3]+aDados379[1,nX,4]+aDados379[1,nX,5]+aDados379[1,nX,6]+aDados379[1,nX,7]))

							nPisRet		:=	0
							nCofRet		:=	0
							nCslRet		:=	0
							/*
							//���������������������������������������������������������������������������Ŀ
							//�Se o valor foi retido em outro titulo, procurar pelo SFQ e tirar dos "VRET"�
							//�da baixa deste titulo o valor que foi retido.                              �
							//�����������������������������������������������������������������������������
							*/
							If (SE2->E2_PRETPIS == "2" .Or. SE2->E2_PRETCOF == "2" .Or. SE2->E2_PRETCSL == "2")
								DbSelectArea('SFQ')
								DbSetOrder(2)
								While SFQ->(DBSeek(	If(lMultFil,aFiliais[nI],xFilial())+"SE2"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
									cChaveSE2	:=	SFQ->(FQ_PREFORI+FQ_NUMORI+FQ_PARCORI+FQ_TIPOORI+FQ_CFORI+FQ_LOJAORI)
									DbSelectArea('SE2')
									DbSetOrder(1)
									DbSeek(If(lMultFil,aFiliais[nI],xFilial())+cChaveSE2)
									DbSelectArea('SE5')
									DbSetOrder(7)
									DbSeek(If(lMultFil,aFiliais[nI],xFilial())+cChaveSE2)
									While !EOF().And.If(lMultFil,aFiliais[nI],xFilial('SE5'))+cChaveSE2 ==;
											E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA
										If E5_MOTBX == 'PCC' .AND. E5_TIPODOC == 'BA' .AND. E5_SITUACA != 'C'
											cSeq	:=	E5_SEQ
											aBaixaSE5 := {}//carregaga pela sel080Baixa
											Sel080Baixa("VL /BA /CP /",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,0,.F.,SE2->E2_FORNECE,SE2->E2_LOJA,.F.,.F.,.F.,0,.F.,.T., .T.)
											nBaixa	:=	Ascan(aBaixaSE5,{|x| x[9] == cSeq})
											aBaixa	:=	{}
											AADD(aBaixa,{'E2_FILIAL',SE2->E2_FILIAL,Nil})
											AADD(aBaixa,{'E2_PREFIXO',SE2->E2_PREFIXO,Nil})
											AADD(aBaixa,{'E2_NUM',SE2->E2_NUM,Nil})
											AADD(aBaixa,{'E2_PARCELA',SE2->E2_PARCELA,Nil})
											AADD(aBaixa,{'E2_TIPO',SE2->E2_TIPO,Nil})
											AADD(aBaixa,{'E2_FORNECE',SE2->E2_FORNECE,Nil})
											AADD(aBaixa,{'E2_LOJA',SE2->E2_LOJA,Nil})

											lMsErroAuto := .F.
											MSExecAuto({|a, b, c, d,e,f | Fina080(a,b,c,d,e,f)}, aBaixa, 5 , Nil , nBaixa,lMostraLC,.T.)
											If lMsErroAuto
												MostraErro()
											EndIf
											DbSelectArea("SE5")
											Exit
										Endif
										DbSkip()
									Enddo
									RecLock("SE2",.F.)
									SE2->E2_PRETPIS := "1"
									SE2->E2_PRETCOF := "1"
									SE2->E2_PRETCSL := "1"
									SE2->E2_VRETPIS := nPisRet
									SE2->E2_VRETCOF := nCofRet
									SE2->E2_VRETCSL := nCslRet
									MsUnlock()
								EndDo
							ElseIf (SE2->E2_PRETPIS == "4" .Or. SE2->E2_PRETCOF == "4" .Or. SE2->E2_PRETCSL == "4")
								cChaveSE2	:=	SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
								DbSelectArea('SE2')
								DbSetOrder(1)
								DbSeek(If(lMultFil,aFiliais[nI],xFilial())+cChaveSE2)
								DbSelectArea('SE5')
								DbSetOrder(7)
								If MsSeek(If(lMultFil,aFiliais[nI],xFilial())+cChaveSE2)
									While !EOF().And.If(lMultFil,aFiliais[nI],xFilial('SE5'))+cChaveSE2 ==;
											E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA
										If E5_MOTBX == 'PCC' .AND. E5_TIPODOC == 'BA' .and. E5_SITUACA != 'C'
											cSeq	:=	E5_SEQ
											aBaixaSE5 := {}//carregaga pela sel080Baixa
											Sel080Baixa("VL /BA /CP /",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,0,.F.,SE2->E2_FORNECE,SE2->E2_LOJA,.F.   ,.F.       ,.F.     ,0         ,.F.    ,.T., .T.)
											DbSelectArea('SE5')
											DbSetOrder(7)
											nBaixa	:=	Ascan(aBaixaSE5,{|x| x[9] == cSeq})
											aBaixa	:=	{}
											AADD(aBaixa,{'E2_FILIAL',SE2->E2_FILIAL,Nil})
											AADD(aBaixa,{'E2_PREFIXO',SE2->E2_PREFIXO,Nil})
											AADD(aBaixa,{'E2_NUM',SE2->E2_NUM,Nil})
											AADD(aBaixa,{'E2_PARCELA',SE2->E2_PARCELA,Nil})
											AADD(aBaixa,{'E2_TIPO',SE2->E2_TIPO,Nil})
											AADD(aBaixa,{'E2_FORNECE',SE2->E2_FORNECE,Nil})
											AADD(aBaixa,{'E2_LOJA',SE2->E2_LOJA,Nil})
											MSExecAuto({|a, b, c, d ,e,f| Fina080(a,b,c,d,e,f)}, aBaixa, 5 , Nil , nBaixa,lMostraLC ,.T.)
											If lMsErroAuto
												MostraErro()
											EndIf

											DbSelectArea("SE5")
											Exit
										Endif
										DbSkip()
									Enddo
									RecLock("SE2",.F.)
									SE2->E2_PRETPIS := "1"
									SE2->E2_PRETCOF := "1"
									SE2->E2_PRETCSL := "1"
									SE2->E2_VRETPIS := nPisRet
									SE2->E2_VRETCOF := nCofRet
									SE2->E2_VRETCSL := nCslRet
									MsUnlock()
								Endif
							Endif
						Next nX
						nConta++
						RestArea(aArea)
					EndIf
				EndIf
				aDados379	:=	{{},0}
				nDifRet		:= 0
				DbSelectArea(cNextAlias)
				cForneceOld	:= SE2->E2_FORNECE
			EndIf
		EndDo
		DbSelectArea(cNextAlias)
		(cNextAlias)->( dbCloseArea() )
	Next nI

	cFilAnt := cFilOld

	If !lBlind
		If !lRecalc
			//"Atencao""N�o houveram recalculos""Ok"
			Aviso(STR0004,STR0021,{STR0006})
		Else
			DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE STR0024 //"T�tulos recalculados"

			@  .5, 2 LISTBOX cListBox ITEMS aExcluidos SIZE 150 , 40 Font oDlg:oFont
			DEFINE SBUTTON FROM 055,109.1 TYPE 6 ACTION (F379ImpRec(aExcluidos),oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 055,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	Endif
EndIf

aDadosRef   := {}
aDadosRet   := {}
aDados379   := {}
aBaixa      := {}
nValPgto    := 0
nOldValPgto := 0   
nPis        := 0
nCofins     := 0
nCsll       := 0
nIss        := 0
nIrrf       := 0

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VMesAno379�Autor  �Adrianne Furtado    � Data �08.04.2008   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o M�s e Ano informado na Pergunte()                  ���
�������������������������������������������������������������������������͹��
���Uso       � FINA379                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VMesAno379(nMes, nAno)
Local lRet
Default nMes := Nil
Default nAno := Nil
If ValType(nMes) == "N"
	If nMes >=1 .and. nMes<=12
		lRet := .T.
	Else
		//"Aten��o""O m�s informado � inv�lido. Verifique a informa��o correta e preencha novamente.""Ok"
		If !lBlind
			Aviso(STR0004, STR0008,{STR0006})
		Endif
		lRet := .F.
	EndIf
EndIf
If ValType(nAno) == "N"
	If nAno >= 1900 .and. nAno <= Year(dDataBase)+1
		lRet := .T.
	Else
		//"Aten��o""O ano informado � inv�lido. Verifique a informa��o correta e preencha novamente.""Ok"
		If !lBlind
			Aviso(STR0004, STR0020,{STR0006})
		Endif
		lRet := .F.
	EndIf
EndIf

Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � F379ImpRec � Autor � Adrianne Furtado      � Data � 22/04/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para imprimir os t�tulos que tiveram PCC recalculado  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FINA069()							 									    ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA069		 															    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function F379ImpRec(aExcluidos)

Local 	cDesc1      := "Relatorio com a lista de titulos processados "
Local 	cDesc2      := ""
Local 	cDesc3      := ""
Local 	titulo      := "Lista de t�tulos recalculados"
Local 	nLin        := 80
Local 	Cabec1      := "         Filial   Prefixo   Numero  Parcela    Tipo  Fornecedor"
Local 	imprime     := .T.
Local 	aOrd 		:= {}
Private NomeProg	:= "FINA379" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= NomeProg // Coloque aqui o nome do arquivo usado para impressao em disco

wnrel := SetPrint(/*cAreaTRB*/,NomeProg,/*cPerg*/,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,/*Tamanho*/,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,/*cAreaTRB*/)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Titulo,nLin,aExcluidos) },Titulo)

lPrint := .T.

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � RUNREPORT  � Autor � Adrianne Furtado      � Data � 22/04/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS.                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA379		 											    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RunReport(Cabec1,Titulo,nLin,aExcluidos)

Local nP		:= 0
Local cLinha	:= ""
Local cSepara	:= "-----------------------------------------------------------------------------"

SetRegua( Len(aExcluidos) )

For nP := 1 To Len( aExcluidos )
	If lAbortPrint
		@nLin,00 PSAY STR0024 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	If nLin > 55
		nLin := (Cabec(Titulo,Cabec1,"",NomeProg,/*Tamanho*/,nTipo)+1)
	Endif

	If At(":", aExcluidos[nP]) > 0
		@ nLin,01 PSAY ""
		nLin++
		cLinha := MontaLinha(aExcluidos[nP])
		@ nLin,01 PSAY cLinha
		nLin++
		@ nLin,01 PSAY cSepara
	Else
		cLinha := MontaLinha(aExcluidos[nP])
		@ nLin,01 PSAY cLinha
	EndIf
	nLin++
Next nP

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontaLinha�Autor  �Adrianne Furtado    � Data �  22/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Manipula o conteudo do array com os dados a serem impressos ���
���          �de forma que retorne a linha formatada para impress�o		  ���
�������������������������������������������������������������������������͹��
���Uso       � FINA379                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MontaLinha(cTexto)
Local cRet := ""

	If At(":", cTexto) > 0
		cRet := SubStr(cTexto,1,At(":", cTexto)+1)
		cTexto := SubStr(cTexto,At(":", cTexto)+2,Len(cTexto))
	Else
		cRet := Space(11)
	EndIf
	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_FILIAL")[1]) + Space(6)
	cTexto := SubStr(cTexto,TamSx3("E2_FILIAL")[1]+1,Len(cTexto))

	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_PREFIXO")[1]) + Space(6)
	cTexto := SubStr(cTexto,TamSx3("E2_PREFIXO")[1]+1,Len(cTexto))

	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_NUM")[1]) + Space(3)
	cTexto := SubStr(cTexto,TamSx3("E2_NUM")[1]+1,Len(cTexto))

	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_PARCELA")[1]) + Space(5)
	cTexto := SubStr(cTexto,TamSx3("E2_PARCELA")[1]+1,Len(cTexto))

	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_TIPO")[1]) + Space(3)
	cTexto := SubStr(cTexto,TamSx3("E2_TIPO")[1]+1,Len(cTexto))

	cRet := cRet + SubStr(cTexto,1,TamSx3("E2_FORNECE")[1]) + Space(3)
	cTexto := SubStr(cTexto,TamSx3("E2_FORNECE")[1]+1,Len(cTexto))

Return cRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AdmAbreSM0� Autor � Orizio                � Data � 22/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com as informacoes das filias das empresas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

#INCLUDE "PROTHEUS.CH"

Static cAJ8FILF3

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsIniGCTP� Autor � Edson Maricate        � Data � 17-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa as funcoes de calculo de Custos de Projetos (COTP) ���
���          �baseado em uma consulta gerencial.                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 : Codigo da Consulta Gerencial                          ���
���          �ExpD2 : Data de Refencia                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsIniGCTP(cCodCGP,dDataRef)
Local aArea     := GetArea()
Local aArrayTrb	:= {}
Local nPosEnt	:= 0
Local aCusto	:= {}
Local aHandle	:= {}
Local cAuxPrj	:= ""

DEFAULT dDataRef := dDataBase

dbSelectArea("AJ8")
dbSetOrder(4)
dbSeek(xFilial()+cCodCGP)
While !Eof() .And. xFilial()+cCodCGP==AJ8->AJ8_FILIAL+AJ8->AJ8_CODPLA
	If AJ8->AJ8_TIPO == "2" .And. !Empty(AJ8_PROJPM) .And. !Empty(AJ8_TASKPM+AJ8_EDTPMS)
		If cAuxPrj <> AJ8->AJ8_PROJPM
			AF8->(dbSetOrder(1))
			AF8->(dbSeek(xFilial()+AJ8->AJ8_PROJPM))
			cAuxPrj := AJ8->AJ8_PROJPM
			aHandle	:= PmsIniCOTP(AJ8->AJ8_PROJPM,AF8->AF8_REVISA,dDataRef)
		EndIf
		If !Empty(AJ8->AJ8_TASKPM)
			aCusto	:= PmsRetCOTP(aHandle,1,AJ8->AJ8_TASKPM)
		Else
			aCusto	:= PmsRetCOTP(aHandle,2,AJ8->AJ8_EDTPMS)
		EndIf
		nPosEnt := aScan(aArrayTrb,{|x|x[1]==AJ8->AJ8_CONTAG})
		If nPosEnt <= 0
			aAdd(aArrayTrb,{AJ8->AJ8_CONTAG,{0,0,0,0,0}})
			nPosEnt	:= Len(aArrayTrb)
		EndIf
		aArrayTrb[nPosEnt][2][1] += aCusto[1]
		aArrayTrb[nPosEnt][2][2] += aCusto[2]
		aArrayTrb[nPosEnt][2][3] += aCusto[3]
		aArrayTrb[nPosEnt][2][4] += aCusto[4]
		aArrayTrb[nPosEnt][2][5] += aCusto[5]
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,AJ8->AJ8_CTASUP)
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,"!$TOTALGERAL$!")		
	EndIf
	dbSkip()
End

RestArea(aArea)

Return aArrayTrb

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsIniGCTE� Autor � Edson Maricate        � Data � 17-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa as funcoes de calculo de Custos de Projetos (COTE) ���
���          �baseado em uma consulta gerencial.                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 : Codigo da Consulta Gerencial                          ���
���          �ExpD2 : Data de Refencia                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsIniGCTE(cCodCGP,dDataRef)
Local aArea     := GetArea()
Local aArrayTrb	:= {}
Local nPosEnt	:= 0
Local aCusto	:= {}
Local aHandle	:= {}
Local cAuxPrj	:= ""

DEFAULT dDataRef := dDataBase

dbSelectArea("AJ8")
dbSetOrder(4)
dbSeek(xFilial()+cCodCGP)
While !Eof() .And. xFilial()+cCodCGP==AJ8->AJ8_FILIAL+AJ8->AJ8_CODPLA
	If AJ8->AJ8_TIPO == "2" .And. !Empty(AJ8_PROJPM) .And. !Empty(AJ8_TASKPM+AJ8_EDTPMS)
		If cAuxPrj <> AJ8->AJ8_PROJPM
			AF8->(dbSetOrder(1))
			AF8->(dbSeek(xFilial()+AJ8->AJ8_PROJPM))
			cAuxPrj := AJ8->AJ8_PROJPM
			aHandle	:= PmsIniCOTE(AJ8->AJ8_PROJPM,AF8->AF8_REVISA,dDataRef)
		EndIf
		If !Empty(AJ8->AJ8_TASKPM)
			aCusto	:= PmsRetCOTE(aHandle,1,AJ8->AJ8_TASKPM)
		Else
			aCusto	:= PmsRetCOTE(aHandle,2,AJ8->AJ8_EDTPMS)
		EndIf
		nPosEnt := aScan(aArrayTrb,{|x|x[1]==AJ8->AJ8_CONTAG})
		If nPosEnt <= 0
			aAdd(aArrayTrb,{AJ8->AJ8_CONTAG,{0,0,0,0,0}})
			nPosEnt	:= Len(aArrayTrb)
		EndIf
		aArrayTrb[nPosEnt][2][1] += aCusto[1]
		aArrayTrb[nPosEnt][2][2] += aCusto[2]
		aArrayTrb[nPosEnt][2][3] += aCusto[3]
		aArrayTrb[nPosEnt][2][4] += aCusto[4]
		aArrayTrb[nPosEnt][2][5] += aCusto[5]
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,AJ8->AJ8_CTASUP)
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,"!$TOTALGERAL$!")		
	EndIf
	dbSkip()
End

RestArea(aArea)

Return aArrayTrb

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsIniGCRE� Autor � Edson Maricate        � Data � 17-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa as funcoes de calculo de Custos de Projetos (CRTE) ���
���          �baseado em uma consulta gerencial.                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 : Codigo da Consulta Gerencial                          ���
���          �ExpD2 : Data de Refencia                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsIniGCRE(cCodCGP,dDataRef)
Local aArea     := GetArea()
Local aArrayTrb	:= {}
Local nPosEnt	:= 0
Local aCusto	:= {}
Local aHandle	:= {}
Local cAuxPrj	:= ""

DEFAULT dDataRef := dDataBase

dbSelectArea("AJ8")
dbSetOrder(4)
dbSeek(xFilial()+cCodCGP)
While !Eof() .And. xFilial()+cCodCGP==AJ8->AJ8_FILIAL+AJ8->AJ8_CODPLA
	If AJ8->AJ8_TIPO == "2" .And. !Empty(AJ8_PROJPM) .And. !Empty(AJ8_TASKPM+AJ8_EDTPMS)
		If cAuxPrj <> AJ8->AJ8_PROJPM
			AF8->(dbSetOrder(1))
			AF8->(dbSeek(xFilial()+AJ8->AJ8_PROJPM))
			cAuxPrj := AJ8->AJ8_PROJPM
			aHandle	:= PmsIniCRTE(AJ8->AJ8_PROJPM,AF8->AF8_REVISA,dDataRef)
		EndIf
		If !Empty(AJ8->AJ8_TASKPM)
			aCusto	:= PmsRetCRTE(aHandle,1,AJ8->AJ8_TASKPM)
		Else
			aCusto	:= PmsRetCRTE(aHandle,2,AJ8->AJ8_EDTPMS)
		EndIf
		nPosEnt := aScan(aArrayTrb,{|x|x[1]==AJ8->AJ8_CONTAG})
		If nPosEnt <= 0
			aAdd(aArrayTrb,{AJ8->AJ8_CONTAG,{0,0,0,0,0}})
			nPosEnt	:= Len(aArrayTrb)
		EndIf
		aArrayTrb[nPosEnt][2][1] += aCusto[1]
		aArrayTrb[nPosEnt][2][2] += aCusto[2]
		aArrayTrb[nPosEnt][2][3] += aCusto[3]
		aArrayTrb[nPosEnt][2][4] += aCusto[4]
		aArrayTrb[nPosEnt][2][5] += aCusto[5]
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,AJ8->AJ8_CTASUP)
		AddCGTPSup(@aArrayTrb,aCusto,cCodCGP,"!$TOTALGERAL$!")
	EndIf
	dbSkip()
End

RestArea(aArea)

Return aArrayTrb

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �AddCGTPSup� Autor � Edson Maricate        � Data � 17-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Adiciona o custo na Entidade superior da consulta selecionada.���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function AddCGTPSup(aArrayTrb,aCusto,cCodCGP,cEntSup)
Local aArea		:= GetArea()
Local aAreaAJ8	:= AJ8->(GetArea())
Local nPosEntSup:= aScan(aArrayTrb,{|x|x[1]==cEntSup})

If nPosEntSup > 0
	aArrayTrb[nPosEntSup][2][1] += aCusto[1]
	aArrayTrb[nPosEntSup][2][2] += aCusto[2]
	aArrayTrb[nPosEntSup][2][3] += aCusto[3]
	aArrayTrb[nPosEntSup][2][4] += aCusto[4]
	aArrayTrb[nPosEntSup][2][5] += aCusto[5]
Else
	aAdd(aArrayTrb,{cEntSup,{0,0,0,0,0}})
	nPosEntSup	:= Len(aArrayTrb)
	aArrayTrb[nPosEntSup][2][1] := aCusto[1]
	aArrayTrb[nPosEntSup][2][2] := aCusto[2]
	aArrayTrb[nPosEntSup][2][3] := aCusto[3]
	aArrayTrb[nPosEntSup][2][4] := aCusto[4]
	aArrayTrb[nPosEntSup][2][5] := aCusto[5]
EndIf

dbSelectArea("AJ8")
dbSetOrder(2)
If !Empty(AJ8->AJ8_CTASUP).And. MsSeek(xFilial()+cCodCGP+cEntSup)
	AddCGTPSup(aArrayTrb,aCusto,cCodCGP,AJ8->AJ8_CTASUP)
EndIf

RestArea(aAreaAJ8)
RestArea(aArea)
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsRetCGER� Autor � Edson Maricate        � Data � 18-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os custos da Entidade da consulta gerencial           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsRetCGER(aArrayTrb,cCodigo)
Local aCusto	:= {0,0,0,0,0}
Local nPosSeek	:= aScan(aArrayTrb,{|x|x[1]==cCodigo})

If nPosSeek>0
	aCusto := aArrayTrb[nPosSeek][2]
EndIf

Return aCusto

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsAJ8F3 � Autor � Edson Maricate         � Data � 18-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o filtro utilizado na consulta F3 do plano gerencial  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsAJ8F3()

If cAJ8FILF3 == Nil
	If FunName() == "PMSA430"
		cAJ8FILF3 := "AJ8->AJ8_CODPLA == M->AJ8_CODPLA"
	Else
		cAJ8FILF3 := ".T."
	EndIf
EndIf

Return &cAJ8FILF3

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsAJ8FilF3� Autor � Edson Maricate       � Data � 18-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Seta o filtro da consulta F3 do AJ8                           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsAJ8FilF3(nFiltro)

Do Case
	Case nFiltro == 1
		cAJ8FILF3 := 'AJ8->AJ8_CODPLA==M->AJ8_CODPLA.And.AJ8->AJ8_TIPO=="1"'
EndCase

Return .T.

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsIniGFin� Autor � Edson Maricate             � Data � 18-04-2003 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que inicializa os valores financeiros da consulta gerencial ���
���          �de projetos                                                        ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                        	 ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Function PmsIniGFin(cCodCGP,lFluxo,nMoeda)
Local aArea     := GetArea()
Local aArrayTrb	:= {}
Local cAuxPrj	:= ""
DEFAULT lFluxo	:= .F.
DEFAULT nMoeda	:= 1

dbSelectArea("AJ8")
dbSetOrder(4)
dbSeek(xFilial()+cCodCGP)
While !Eof() .And. xFilial()+cCodCGP==AJ8->AJ8_FILIAL+AJ8->AJ8_CODPLA
	If AJ8->AJ8_TIPO == "2" .And. !Empty(AJ8_PROJPM) .And. !Empty(AJ8_TASKPM+AJ8_EDTPMS)
		If cAuxPrj <> AJ8->AJ8_PROJPM
			AF8->(dbSetOrder(1))
			AF8->(dbSeek(xFilial()+AJ8->AJ8_PROJPM))
			cAuxPrj := AJ8->AJ8_PROJPM
			aHandle	:= PmsIniFin(AJ8->AJ8_PROJPM,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),lFluxo,nMoeda)
		EndIf
		If !Empty(AJ8->AJ8_TASKPM)
			aAuxRet	:= PmsRetFinVal(aHandle,1,AJ8->AJ8_TASKPM)
			aAuxFlux:= PmsRetFinVal(aHandle,3,AJ8->AJ8_TASKPM)
		Else
			aAuxRet	:= PmsRetFinVal(aHandle,2,AJ8->AJ8_EDTPMS)
			aAuxFlux:= PmsRetFinVal(aHandle,4,AJ8->AJ8_EDTPMS)
		EndIf
		nPosEnt := aScan(aArrayTrb,{|x|x[1]==AJ8->AJ8_CONTAG})
		If nPosEnt <= 0
			aAdd(aArrayTrb,{AJ8->AJ8_CONTAG,,Nil,Nil})
			nPosEnt	:= Len(aArrayTrb)
		EndIf
		aArrayTrb[nPosEnt][3] := aClone(aAuxRet)
		aArrayTrb[nPosEnt][4] := aClone(aAuxFlux)
		AddCGValSup(@aArrayTrb,aAuxRet,aAuxFlux,cCodCGP,AJ8->AJ8_CTASUP)
		AddCGValSup(@aArrayTrb,aAuxRet,aAuxFlux,cCodCGP,"!$TOTALGERAL$!")		
	EndIf
	dbSkip()
End

RestArea(aArea)

Return aArrayTrb

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �AddCGValSup� Autor � Edson Maricate            � Data � 21-05-2002 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que totaliza os valores financeiros na Entidade Superior    ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                        	 ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Function AddCGValSup(aArrayTrb,aVlrFin,aFluxo,cCodCGP,cEntSup)
Local nX
Local nPosDt
Local aArea		:= GetArea()
Local aAreaAJ8	:= AJ8->(GetArea())
Local nPosSup	:= aScan(aArrayTrb,{|x|x[1]==cEntSup})

If nPosSup > 0
	aArrayTrb[nPosSup][3][1] += aVlrFin[1]
	aArrayTrb[nPosSup][3][2] += aVlrFin[2]
	aArrayTrb[nPosSup][3][3] += aVlrFin[3]
	aArrayTrb[nPosSup][3][4] += aVlrFin[4]
	aArrayTrb[nPosSup][3][5] += aVlrFin[5]
	aArrayTrb[nPosSup][3][6] += aVlrFin[6]
	//�����������������������������������������������������Ŀ
	//� Atualiza o fluxo de caixa                           �
	//�������������������������������������������������������
	aArrayTrb[nPosSup][4][3] += aFluxo[3]
	aArrayTrb[nPosSup][4][6] += aFluxo[6]
	For nx := 1 to Len(aFluxo[1])
		nPosDt := aScan(aArrayTrb[nPosSup][4][1],{|x| x[1]==aFluxo[1,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosSup][4][1][nPosDt][2] += aFluxo[1,nX,2]
		Else
		    aAdd(aArrayTrb[nPosSup][4][1],{aFluxo[1,nX,1],aFluxo[1,nX,2]})
		EndIf
	Next
	For nx := 1 to Len(aFluxo[2])
		nPosDt := aScan(aArrayTrb[nPosSup][4][2],{|x| x[1]==aFluxo[2,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosSup][4][2][nPosDt][2] += aFluxo[2,nX,2]
		Else
		    aAdd(aArrayTrb[nPosSup][4][2],{aFluxo[2,nX,1],aFluxo[2,nX,2]})
		EndIf
	Next
	For nx := 1 to Len(aFluxo[4])
		nPosDt := aScan(aArrayTrb[nPosSup][4][4],{|x| x[1]==aFluxo[4,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosSup][4][4][nPosDt][2] += aFluxo[4,nX,2]
		Else
		    aAdd(aArrayTrb[nPosSup][4][4],{aFluxo[4,nX,1],aFluxo[4,nX,2]})
		EndIf
	Next
	For nx := 1 to Len(aFluxo[5])
		nPosDt := aScan(aArrayTrb[nPosSup][4][5],{|x| x[1]==aFluxo[5,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosSup][4][5][nPosDt][2] += aFluxo[5,nX,2]
		Else
		    aAdd(aArrayTrb[nPosSup][4][5],{aFluxo[5,nX,1],aFluxo[5,nX,2]})
		EndIf
	Next
Else
	aAdd(aArrayTrb,{cEntSup,,aClone(aVlrFin),aClone(aFluxo)})
EndIf

dbSelectArea("AJ8")
dbSetOrder(2)
If !Empty(AJ8->AJ8_CTASUP).And. MsSeek(xFilial()+cCodCGP+cEntSup)
	AddCGValSup(aArrayTrb,aVlrFin,aFluxo,cCodCGP,AJ8->AJ8_CTASUP)
EndIf

RestArea(aAreaAJ8)
RestArea(aArea)
Return
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PmsRetGFin� Autor � Edson Maricate        � Data � 04-07-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os custos da tarefa,EDT ou Bloco de Trabalho          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PmsRetGFin(aArrayTrb,nTipo,cCodigo)
Local aValFin := {{},{},0,{},{},0}

Do Case
	Case nTipo == 1
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek][3]
		EndIf
	Case nTipo == 2
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek][4]
		EndIf
EndCase

Return aValFin
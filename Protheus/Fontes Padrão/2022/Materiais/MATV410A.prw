#INCLUDE "RWMAKE.CH"   
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

Static __aMCPdCpy		:= {} // Cache para n�o repetir a mensagem do mesmo produto durante a copia caso o mesmo estiver bloqueado.
Static __lA410Mta410	:= FindFunction("A410Mta410")
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MATN410   � Autor � Eduardo Riera         � Data �12.02.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funciones de rutina de pedidos de venta.                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���02/03/2018�A. Rodriguez   �DMINA-1832 Correcci�n en A410MultT()        ���
���          �               �aCols[n,nPTES] es NIL cuando valida TES en  ���
���          �               �pedido autom�tico de entrega futura. COL    ���
���06/06/2018�A.Luis Enr�quez�DMINA-2980 Se agrega validaci�n en funci�n  ���
���          �               �A410TudOk para datos comercio exterior (MEX)���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �a410TudOk � Rev.  �Eduardo Riera          � Data �26.08.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao de toda a GetDados                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto da GetDados                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao em toda a ���
���          �Getdados                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Materiais/Distribuicao/Logistica                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410TudOk(o)

Local aArea      := GetArea()
Local aChkPMS	 := {}
Local aHandFat	 := {}
Local aContrato  := {}
Local aInfo      := {{"Projeto","Tarefa","Faturamento","Remessas","Saldo Faturam.","Saldo Rem."}}
Local nPProduto	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPTes		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPItem	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPQtdVen	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPValor	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPPrj		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROJPMS"})
Local nPTsk		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TASKPMS"})
Local nPEDT		 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_EDTPMS"})
Local nPQtdLib	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPContrat  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItemCon  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPNfOrig   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSerOrig  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItOrig   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPNumOrc   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMORC"})
Local nPReserva  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_RESERVA"})
Local nPLocal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nMaxArray	 := Len(aCols)
Local nCntFor	 := 0
Local lRetorna	 := .T.
Local nQtdDel	 := 0
Local nX	     := 0
Local nSldPms	 := 0
Local nSldPmsR	 := 0
Local nTotPed    := 0
Local cAuxPrj	 := ""
Local cTesAux    := ""
Local nTpProd    := aScan(aHeader,{|x| AllTrim(x[2])== "C6_TPPROD"})
Local nProdVnd	 := 0
Local nProdDsv	 := 0
Local cVend	 	 := ""
Local cVendedor  := ""
Local lGem410Li  := ExistBlock("GEM410LI") 
Local lGem410LiT := ExistTemplate("GEM410LI")
Local cMV1DupNat := ""
Local cMV2DupNat := ""
Local cPVNaturez := ""

Local lIFatDpr	  := SuperGetMV("MV_IFATDPR",.F.,.F.)
Local lMV_LIBACIM := SuperGetMv("MV_LIBACIM")
Local lMV_PMSBLQF := SuperGetMv("MV_PMSBLQF",,"0") == "1"
Local cMV_PMSTSV  := SuperGetMv("MV_PMSTSV",,"")
Local cMV_PMSTSR  := SuperGetMv("MV_PMSTSR",,"")
Local lMV_CHCLRES := SuperGetMv("MV_CHCLRES",,.F.)
Local lCFDUso     := SuperGetMv("MV_CFDUSO",.T.,"1") <> "0"
Local l410ExecAuto := (Type("l410Auto") <> "U" .And. l410Auto)

If nMaxArray == 1 .AND. Empty(aCols[nMaxArray][nPProduto])
	Help(" ",1,"A410SEMREG")
	lRetorna	 := .F.
EndIf

If lRetorna .And. M->C5_TIPO $ "DB" .And. M->C5_ACRSFIN <> 0
	Help(" ",1,"A410DEVACR")
	lRetorna := .F.
Endif

If lRetorna .And. IsInCallStack("A410COPIA") .And. !l410Auto
	cVend := "1"
	For nX := 1 To Fa440CntVen()
		cVendedor := &("C5_VEND"+cVend)
		If !Empty(cVendedor)
			dbSelectArea("SA3")
			dbSetOrder(1)
			If dbSeek(xFilial("SA3") + cVendedor) .AND. !RegistroOk("SA3",.F.)
				Help(" ",1,"A410VENDBLK",,STR0172 + cVendedor + STR0173,1,0)	//##"Codigo do vendedor: "##" utilizado por este cliente esta bloqueado no cadastro de vendedores!"
				lRetorna:= .F.
				Exit
			EndIf
		EndIf
		cVend := Soma1(cVend,1)
	Next nX
	SE4->(DBSetOrder(1))
	If SE4->(DBSeek(xFilial("SE4")+M->C5_CONDPAG) .And. !RegistroOk("SE4",.F.))
		Help(" ",1,"A410CPGBLK",,STR0379,1,0)	//##"Condi��o de Pagamento utilizada encontra-se bloqueada para uso"
		lRetorna := .F.
	EndIf
EndIf

If lRetorna
	If M->C5_TIPO $ 'NCIP'
		cMV1DupNat := Upper(AllTrim(SuperGetMv("MV_1DUPNAT",.F.,"")))

		If "C5_NATUREZ" $ cMV1DupNat
			cPVNaturez	:= M->C5_NATUREZ
		ElseIf "A1_NATUREZ" $ cMV1DupNat
			cPVNaturez	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NATUREZ")
		Else
			cPVNaturez	:= &(cMV1DupNat)
		EndIf
	Else
		cMV2DupNat := Upper(AllTrim(SuperGetMv("MV_2DUPNAT",.F.,"")))
		
		If "C5_NATUREZ" $ cMV2DupNat
			cPVNaturez	:= M->C5_NATUREZ
		ElseIf "A2_NATUREZ" $ cMV2DupNat
			cPVNaturez := Posicione("SA2",1,xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI,"A2_NATUREZ")
		Else
			cPVNaturez	:=  &(cMV2DupNat)
		EndIf
	EndIf

	SED->(DBSetOrder(1))
	If SED->(DBSeek(xFilial("SED")+cPVNaturez) .And. !RegistroOk("SED",.F.))
		Help(" ",1,"A410NATBLK",,STR0406,1,0)	//##"Natureza utilizada encontra-se bloqueada para uso"
		lRetorna := .F.
	EndIf
EndIf

//���������������������������������������������������Ŀ
//�Verifica se o usuario tem premissao para alterar o �
//�pedido de venda                                    �
//�����������������������������������������������������
If cPaisLoc <> "BRA" .AND. SC5->(ColumnPos("C5_CATPV")) > 0 .AND. !Empty(M->C5_CATPV) .AND. AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
	AGR->(DBSetOrder(1))
	If AGR->(DBSeek(xFilial("AGR") +M->C5_CATPV)) 
		IF AGR->AGR_STATUS<>"1"
			Help(NIL, NIL, STR0410, NIL, STR0411, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0412})
			lRetorna := .F.
		ENDIF
	EndIf
	
	AGS->(DBSetOrder(1))
	If AGS->(DBSeek(xFilial("AGS") + __cUserId)) //Se n�o encontrar o usu�rio na tabela, permite ele alterar o pedido
		If AGS->(! DBSeek(xFilial("AGS") + __cUserId + M->C5_CATPV)) //Verifica se o usuario tem premissao
			MsgStop(STR0167 + " " + STR0003 + " " + STR0168)//"Este usuario nao tem permissao para incluir pedidos de venda com essa categoria."
			lRetorna := .F.
		EndIf
	EndIf
EndIf

//���������������������������������������������������������������������������������������������������Ŀ
//� Para integracao SIGAFAT com SIGADPR somente um item do tipo desenvolvimento por pedido de venda. �
//����������������������������������������������������������������������������������������������������
If ( lIFatDpr .AND. (Type("lExAutoDPR") == "L" .AND. !(lExAutoDPR)) .AND.  SC6->(ColumnPos("C6_TPPROD")) > 0 ) 
	For nCntFor := 1 to nMaxArray
		If !aCols[nCntFor][Len(aCols[nCntFor])]
			If aCols[nCntFor][nTpProd] == "1"
				nProdVnd++
			ElseIf aCols[nCntFor][nTpProd] == "2"
				nProdDsv++
			EndIf
			If nProdDsv > 1 .OR. ( nProdVnd > 0 .AND. nProdDsv > 0 )
				MsgAlert(STR0310) //"� permitido somente um item do tipo Desenvolvimento por Pedido de Venda!"
				lRetorna := .F.
				Exit
			EndIf
		EndIf		
	Next nCntFor
EndIf

//������������������������������������������������������Ŀ
//� Valida se a nota ainda esta no CQ.                   �
//��������������������������������������������������������
If lRetorna .AND. M->C5_TIPO == "D"
	For nCntFor := 1 to nMaxArray
		If !aCols[nCntFor][Len(aCols[nCntFor])]
			lRetorna := Ma410VldQEK( M->C5_CLIENTE,M->C5_LOJACLI,aCols[nCntFor][nPNfOrig],aCols[nCntFor][nPSerOrig],aCols[nCntFor][nPItOrig],aCols[nCntFor][nPProduto]) 
  	 	 	If !lRetorna
   			 	Exit
   		 	EndIf
		EndIF
	Next nCntFor
EndIf

If cPaisLoc == "MEX" .And. SC5->(ColumnPos("C5_TIPOPE")) > 0 .AND. (M->C5_TIPOPE) $ "1|2" .And. SuperGetMV("MV_CFDIEXP",.F.,.F.)
	If Empty(M->C5_CVEPED) .Or. Empty(M->C5_CERORI) .Or. Empty(M->C5_INCOTER) .Or. Empty(M->C5_SUBDIV) .Or. Empty(M->C5_TCUSD) .Or. Empty(M->C5_TOTUSD)
		MSGINFO(STR0326 + CRLF + ; //"Para el tipo de operaci�n Exportaci�n deben de existir los siguientes datos: "
		        STR0327 + CRLF + ; //" - Clave de Pedimento"
		        STR0328 + CRLF + ; //" - Certificado Origen"
		        STR0329 + CRLF + ; //" - Incoterm"
		        STR0330 + CRLF + ; //" - Subdivisi�n"
		        STR0331 + CRLF + ; //" - Tipo Cambio USD"
	            STR0332 + CRLF + ; //" - Total USD" 
	            STR0333) //" - Mercancias"
		lRetorna := .F.
	EndIf
	If lRetorna .And. SC5->(ColumnPos("C5_CONUNI")) > 0  
		If FindFunction("ValIMMEX")
			lRetorna :=ValIMMEX(M->C5_CONUNI,M->C5_CLIENTE,M->C5_LOJACLI,"1","C5")
		EndIf		
	EndIF
EndIf

If lRetorna .And. cPaisLoc == "PER" .And. FindFunction("M486VLDPER")
	lRetorna := M486VLDPER(M->C5_NUM)
ElseIf lRetorna .And. cPaisLoc == "EQU" .And. FindFunction("fVldEqu")
	lRetorna := fVldEqu(M->C5_NUM)
EndIf

//------------------------------------------------------------------
// Realiza valida��o de integra��o com SIGAMNT
//------------------------------------------------------------------
If lRetorna .And. SuperGetMV( 'MV_NGMNTES', .F., 'N' ) == 'S' .And. M->C5_TIPO == "D" .And. FindFunction( 'MNTINTSD1' )
	lRetorna := MNTINTSD1( 6, 'MATV410A' )
EndIf

If lRetorna .And. cPaisLoc == "BRA"
	If M->C5_TIPO == "C" .And. M->C5_TPCOMPL == "1"
		For nCntFor := 1 to nMaxArray
			If aCols[nCntFor][nPQtdVen] > 0
				If l410ExecAuto 
					A410QtdCpPrc(nPQtdVen, nPQtdLib, nCntFor, nMaxArray)
				ElseIf MsgYesNo(OemToAnsi(STR0359),OemToAnsi(STR0360))  //"Confirma a Inclusao do Pedido ?"###"Pedido de Complemento de Pre�o"
					A410QtdCpPrc(nPQtdVen, nPQtdLib, nCntFor, nMaxArray)
				Else
					lRetorna	:= .F.
				EndIf
				Exit
			EndIf
		Next
	EndIf
EndIf

If lRetorna .And. IntWms()
	lRetorna := WmsAvalSC5("1")
EndIf

//������������������������������������������������������Ŀ
//� verifica se o ultimo elemento do array esta em branco�
//��������������������������������������������������������
If ( lRetorna )
	
	SC6->( DBSetOrder( 1 ) )
	For nCntFor := 1 to nMaxArray
		//������������������������������������������������������������������������Ŀ
		//�Deleta os itens com  produto em branco                                  �
		//��������������������������������������������������������������������������
		If ( Empty(aCols[nCntFor,nPProduto]) )
			aCols[nCntFor,Len(aCols[nCntFor])] := .T.
		EndIf
		If ( !aCols[nCntFor][Len(aCols[nCntFor])] )//Deletado
			If Empty(cTesAux)
			   cTesAux:= aCols[nCntFor][nPTes] 
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Avalia o Tes                                                            �
			//��������������������������������������������������������������������������
			If (nCntFor > 1 .And. !aCols[nCntFor-1][Len(aCols[nCntFor-1])])  //verifica se esta deletado
				lRetorna	:= A410ValTES(aCols[nCntFor][nPTes],IIf(nCntFor > 1,aCols[nCntFor-1][nPTes],NIL))
			Else
				lRetorna	:= A410ValTES(aCols[nCntFor][nPTes],cTesAux)
			EndIf
			If ( NoRound(aCols[nCntFor][nPQtdLib],aHeader[nPQtdLib,4]) > NoRound(aCols[nCntFor][nPQtdVen],aHeader[nPQtdVen,4]) .And. lMV_LIBACIM )
				Help(" ",1,"QTDLIBMAI")
				lRetorna := .F.
			EndIf
			//����������������������������������������������������������������������Ŀ
			//� Verifica os campos C6_PRCVEN, C6_VALOR e C6_PRUNIT se estao em branco|
			//������������������������������������������������������������������������
			If ( lRetorna .And. AT(M->C5_TIPO,"CIP")==0 )
				If ( Empty(aCols[nCntFor,nPPrcven]) ) .or. ( Empty(aCols[nCntFor,nPValor]) )
					//����������������������������������������������������������������������������������������
					//Tratamento para quando for valor do item igual a zero permitido quando F4_VLRZERO = SIM�
					//����������������������������������������������������������������������������������������
					If cPaisLoc <> "BRA" 
						Help(" ",1,"A410VZ")
						lRetorna := .F.
					Else
						If !Posicione("SF4",1,xFilial("SF4")+aCols[nCntFor][nPTes],"SF4->F4_VLRZERO") == "1"
							Help(" ",1,"A410VZ")
							lRetorna := .F.
						EndIf		
					EndIf
				EndIf
			EndIf
			
			If ( lRetorna .And. AT(M->C5_TIPO,"CIP") <> 0 )
				If ( Empty(aCols[nCntFor,nPPrcven]) ) .or. ( Empty(aCols[nCntFor,nPValor]) )
					If cPaisLoc == "BRA" .And. M->C5_TIPO $ "C" .And. M->C5_TPCOMPL == "2" 	//Compl. Quantidade
						//����������������������������������������������������������������������������������������
						//Tratamento para quando for valor do item igual a zero permitido quando F4_VLRZERO = SIM�
						//����������������������������������������������������������������������������������������
						If !Posicione("SF4",1,xFilial("SF4")+aCols[nCntFor][nPTes],"SF4->F4_VLRZERO") == "1"
							Help(" ",1,"A410VZ2")
							lRetorna := .F.
						EndIf
					Else
						Help(" ",1,"A410VZ2")
						lRetorna := .F.
					EndIf
				EndIf
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Verifica o contrato de parceria                              �
			//����������������������������������������������������������������
			If nPContrat<>0 .And. nPItemCon<>0 .And. !Empty(aCols[nCntFor][nPContrat])
				nX := aScan(aContrato,{|x| x[1] == aCols[nCntFor][nPContrat] .And. x[2] == aCols[nCntFor][nPItemCon]})
				If nX == 0
					aAdd(aContrato,{aCols[nCntFor][nPContrat],aCols[nCntFor][nPItemCon],aCols[nCntFor][nPQtdVen]})
					nX := Len(aContrato)
				Else
					aContrato[nX][3] += aCols[nCntFor][nPQtdVen]
				EndIf
			EndIf
			//�����������������������������������������������������������������������Ŀ
			//�Valida��es do m�dulo WMS referente ao item da linha                    �
			//�������������������������������������������������������������������������
			If lRetorna .And. ALTERA .And. IntWms(aCols[nCntFor,nPProduto])
				lRetorna := WmsAvalSC6("3","SC6",aCols,n,aHeader,ALTERA)
			EndIf
			//��������������������������������������������������Ŀ
			//�Verifica se os projetos possuem saldo para faturar�
			//����������������������������������������������������  
			If lRetorna .And. lMV_PMSBLQF
				If !Empty(aCols[nCntFor][nPPrj])
					If !Empty(aCols[nCntFor][nPEDT])
						Aviso(STR0072,STR0073+aCols[nCntFor][nPItem]+".",{STR0074},2)
						lRetorna := .F.
					Else
						nPosChk := aScan(aChkPMS,{|x| x[2]+x[3]==aCols[nCntFor][nPPrj]+aCols[nCntFor][nPTsk]})
						If nPosChk > 0 
							If aCols[nCntFor][nPTes] $ cMV_PMSTSV
								aChkPMS[nPosChk][1] += aCols[nCntFor][nPValor]
							EndIf
							If aCols[nCntFor][nPTes] $ cMV_PMSTSR
								aChkPMS[nPosChk][4] += aCols[nCntFor][nPValor]
							EndIf
						Else
							If aCols[nCntFor][nPTes] $ cMV_PMSTSV
								aAdd(aChkPMS,{aCols[nCntFor][nPValor],aCols[nCntFor][nPPrj],aCols[nCntFor][nPTsk],0})
							EndIf
							If aCols[nCntFor][nPTes] $ cMV_PMSTSR
								aAdd(aChkPMS,{0,aCols[nCntFor][nPPrj],aCols[nCntFor][nPTsk],aCols[nCntFor][nPValor]})
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//������������������������������������������������������Ŀ
			//�Verifica se o pedido e uma devolucao de compra, um    �
			//�complemento de ICMS ou IPI, para validar a nota fiscal�
			//�de origem.                                            �
			//��������������������������������������������������������
			If ( lRetorna .And. Empty( aCols[nCntFor,nPNfOrig] ) .And. At(M->C5_TIPO,"CIPD") <> 0 ) 
				If ( At(M->C5_TIPO,"CIP") <> 0 )
					Help(" ",1,"A410COMPIP")
				Else
					Help(" ",1,"A410NFORI")
				EndIf
				lRetorna := .F.
			EndIf
			//��������������������������������������������������������������Ŀ
			//� Verifica as faixas da condicao de pagamento                  �
			//����������������������������������������������������������������
			nTotPed += aCols[nCntFor][nPValor]
			//��������������������������������������������������������������Ŀ
			//� Verifica o contrato de parceria                              �
			//����������������������������������������������������������������
			If nPContrat<>0 .And. nPItemCon<>0 
				If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nCntFor][nPItem]) ) .And. !Empty(SC6->C6_CONTRAT)
					nX := aScan(aContrato,{|x| x[1] == SC6->C6_CONTRAT .And. x[2] == SC6->C6_ITEMCON})
					If nX == 0
						aAdd(aContrato,{SC6->C6_CONTRAT,SC6->C6_ITEMCON,0})
						nX := Len(aContrato)
					EndIf
					aContrato[nX][3] -= SC6->C6_QTDVEN
				EndIf
			EndIf
			If lRetorna .And. lMV_CHCLRES
				If nPReserva>0 .And. !Empty(aCols[nCntFor][nPReserva])
					If SC0->(MsSeek(xFilial("SC0")+aCols[nCntFor][nPReserva]+aCols[nCntFor][nPProduto]+aCols[nCntFor][nPLocal]))
						If SC0->C0_TIPO == "CL" .And. SC0->C0_DOCRES <> M->C5_CLIENTE
							MsgAlert(STR0093 + Alltrim(aCols[nCntFor][nPReserva]) + STR0094 + SC0->C0_DOCRES)
							lRetorna := .F.
						Endif
					Endif
				Endif
			Endif
		Else
			nQtdDel++
		EndIf
		//
		// Template GEM - Gestao de Empreendimentos Imobiliarios
		//
		// Valida a linha do browse
		//
		If lRetorna 
			If lGem410Li 
				lRetorna := ExecBlock("GEM410LI",.F.,.F.,{ nCntFor })
			ElseIf lGem410LiT 
				lRetorna := ExecTemplate("GEM410LI",.F.,.F.,{ nCntFor })
			Endif
		EndIf

		If ( !lRetorna )
			Exit
		EndIf
	Next nCntFor
	If ( nQtdDel >= nMaxArray .And. ALTERA )
		Help(" ",1,"EXCLTODOS")
		lRetorna := .F.
	EndIf
EndIf

If lRetorna .And. cPaisLoc == "BOL" .And. lCFDUso .And. FindFunction("M486XVldBO")
	If SC5->(ColumnPos("C5_CODMPAG")) > 0 // c�d. Met. Pago
		lRetorna := M486XVldBO(M->C5_CODMPAG,"C5_CODMPAG") //M486XVldBO contenida en Locxbol
	EndIf
	If SC5->(ColumnPos("C5_TPDOCSE")) > 0 .and. lRetorna  // Tip. doc. Sector
		lRetorna := M486XVldBO(M->C5_TPDOCSE,"C5_TPDOCSE") //M486XVldBO contenida en Locxbol
	EndIf
EndIf

If lRetorna
	aChkPMS := aSort(aChkPMS,,,{|x,y| x[2] < y[2] })
	cAuxPrj	:= ""
	For nX := 1 to Len(aChkPMS)
		If cAuxPrj <> aChkPMS[nX,2]
			AF8->(dbSetOrder(1))
			AF8->(MsSeek(xFilial()+aChkPMS[nX,2]))
			aHandFat := PmsIniFat(AF8->AF8_PROJET,AF8->AF8_REVISA,AF8->AF8_PROJET+SPACE(2))
		EndIf
		If !PmsChkSldF(aHandFat,M->C5_MOEDA,aChkPMS[nX,1],aChkPMS[nX,2],"",aChkPMS[nX,3],Altera,M->C5_EMISSAO,@nSldPms,aChkPMS[nX,4],nSldPmsR)
			aAdd(aInfo,{aChkPMS[nX,2],aChkPMS[nX,3],TransForm(aChkPMS[nX,1],"@E 999,999,999,999.99"),TransForm(aChkPMS[nX,4],"@E 999,999,999,999.99"),TransForm(nSldPms,"@E 999,999,999,999.99"),TransForm(nSldPmsR,"@E 999,999,999,999.99")})
			lRetorna := .F.
		EndIf
	Next nX
	If !lRetorna
		If Aviso(STR0075,STR0076,{STR0077,STR0074},2)==1
			PmsDispBox(aInfo,6,STR0078,{30,60,50,50,50,50},,1)
		EndIf
	EndIf
EndIf

If lRetorna .And. SuperGetMv("MV_RSATIVO",.F.,.F.) .And. !lPlanRaAtv
	MsgAlert(STR0373)	//"MV_RSATIVO Habilitado.Para o tratamento da primeira sa�da do Ativo, selecionar a op��o Planilha para valida��o da digita��o."
	lRetorna := .F.
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica o contrato de parceria                              �
//����������������������������������������������������������������
If lRetorna
	For nX := 1 To Len(aContrato)
		ADB->( DBSetOrder( 1 ) )
		ADB->( MsSeek(xFilial("ADB")+aContrato[nX][1]+aContrato[nX][2]) )
		If aContrato[nX][3] > ADB->ADB_QUANT-ADB->ADB_QTDEMP .And. (nPNumOrc > 0 .And. Empty(aCols[nX][nPNumOrc]))
			Help(" ",1,"A410QTDCTR2")
			lRetorna := .F.
		EndIf
	Next nX
EndIf
//������������������������������������������������������������������������Ŀ
//�Verifica a Condicao de Pagamento Tipo 9                                 �
//��������������������������������������������������������������������������
If lRetorna
	If cPaisLoc == "EUA"
		If FindFunction("LocxVldTp9")
			lRetorna  := LocxVldTp9()
		Else
			Help(" ",1,"A410VLDTP9",,STR0367,1,0) //"No se encontr� la funci�n LocxVldTp9(), es necesario actualizar la rutina LocxGen."
			lRetorna  := .F.
		EndIf
	Else
		If !A410Tipo9()
			lRetorna  := .F.
		EndIf
	EndIf
EndIf
//���������������������������������������������������������Ŀ
//�Verifica se a tabela de precos eh valida                 �
//�����������������������������������������������������������
If lRetorna
	lRetorna := MaVldTabPrc(M->C5_TABELA,M->C5_CONDPAG,,M->C5_EMISSAO)
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica as faixas da condicao de pagamento                  �
//����������������������������������������������������������������
If lRetorna
	SE4->( DBSetOrder( 1 ) )
	SE4->( MsSeek(xFilial("SE4")+M->C5_CONDPAG) )
	If nTotPed > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0 .And. GetNewPar("MV_CNDPLIM","1")=="1"
		Help(" ","1","LJLIMSUPER")
		lRetorna := .F.
	ElseIf nTotPed < SE4->E4_INFER .AND. SE4->E4_INFER <> 0 .And. GetNewPar("MV_CNDPLIM","1")=="1"
		Help(" ","1","LJLIMINFER")
		lRetorna := .F.
	Endif
EndIf             

If lRetorna .And. M->C5_DESCONT > 0 .And. M->C5_DESCONT > nTotPed
	Help(" ",1,"A410DESCONT",,STR0323,1,0)	//##"O valor do desconto de indeniza��o est� maior que o valor total dos itens do pedido."
	lRetorna := .F.
EndIf

If lRetorna .And. M->C5_DESC4 >= 100
	Help(" ",1,"A410DESCONT",,STR0364,1,0)	//##"O valor do desconto est� maior que o valor total dos itens do pedido."
	lRetorna := .F.
EndIf

If lRetorna .And. CtoD(SuperGetMv("MV_NT2006I",.F.,"05/04/2021")) <= dDataBase //Valida a vigencia da NT2020-006
	If SC5->(ColumnPos("C5_CODA1U")) > 0 //Existe o campo do C�digo do Intermediador no Pedido de Venda (Campo inserido durante a Vers�o 12.1.27)
		If !( M->C5_INDPRES $ "12349" ) .AND. !Empty(M->C5_CODA1U)
			Help(" ",1,"A410CODA1U02",,STR0408,1,0)	//"N�o � permitido informar o C�digo do Intermediador para o Pedido de Venda conforme o campo Presen�a do Comprador (C5_INDPRES)."
			lRetorna := .F.
		EndIf
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica a Validacao dos Pontos de Entrada                              �
//��������������������������������������������������������������������������
If lRetorna .AND. ExistTemplate("MTA410",,.T.)
	lRetorna  := ExecTemplate("MTA410",.F.,.F.)
EndIf
If lRetorna .AND. ExistBlock("MTA410",,.T.)
	lRetorna  := ExecBlock("MTA410",.F.,.F.)
EndIf

RestArea(aArea)
Return( lRetorna )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �a410LinOk � Rev.  �Eduardo Riera          � Data �26.08.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Linha da Getdados                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto da GetDados                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao da linhaOk���
���          � da getdados                                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Materiais/Distribuicao/Logistica                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410LinOk(o)

Local aArea    	:= GetArea()
Local aPedido   	:= {}
Local aVlrDev   	:= {}

Local aContrato 	:= {}
Local lRetorno 	:= .T.
Local lGrade   	:= MaGrade()
Local lGradeReal	:= .F.
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"  
Local lRevProd  	:= SuperGetMv("MV_REVPROD",.F.,.F.)

Local cRvSB5		:= ""
Local cBlqSG5		:= ""    
Local cStatus		:= ""
Local cAviso    	:= ""
Local cItemSC6 	:= ""
Local cProduto 	:= ""
Local cTes     	:= ""
Local cNumRes  	:= ""
Local cLocal   	:= ""
Local cLoteCtl 	:= ""
Local cNumLote 	:= ""
Local cLocaliza  := Space(TamSX3("C0_LOCALIZ")[1])
Local cNumSerie	:= Space(TamSX3("C0_NUMSERI")[1])
Local cNfOrig  	:= ""
Local cSerieOri	:= ""
Local cItemOri	:= ""
Local cItemGrad	:= ""
Local cIdentB6 	:= ""
Local cServico	:= ""
Local cOpc      	:= ""
Local cOpcional 	:= ""
Local cOpcioAux 	:= "" 
Local cOpcioAnt 	:= ""
Local aOpcional 	:={}
Local cMascara  	:= SuperGetMv("MV_MASCGRD")
Local cBonusTes	:= SuperGetMv("MV_BONUSTS")
Local nTamRef		:= Val(Substr(cMascara,1,2))

Local nQtdRese 	:= 0
Local nCntFor  	:= 0
Local nQtdVen  	:= 0
Local nQtdLib  	:= 0
Local nPrcVen  	:= 0
Local nValor   	:= 0
Local nSaldo   	:= 0
Local nPosIdB6 	:= 0
Local nPosQtdVen	:= 0
Local nPosQtdLib	:= 0
Local nPosLocal 	:= 0
Local nPosProd  	:= 0
Local nPosNfOrig	:= 0
Local nPosSerOri	:= 0
Local nPosItemOr	:= 0
Local nPosServ  	:= 0
Local nPrUnit   	:= 0      
Local nRevisao  	:= 0
Local lOpcPadrao	:= SuperGetMv("MV_REPGOPC",.F.,"N") == "N"			//Determina se ser� poss�vel repetir o mesmo grupo de opcionais em v�rios n�veis da estrutura.
Local nPosTes   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPContrat 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItContr 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM" })
Local nPQtdVen  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
Local nPLocal   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPEntreg  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG" })
Local nPOpcional	:= aScan(aHeader,{|x| AllTrim(x[2])==IIf(lOpcPadrao,"C6_OPC","C6_MOPC")})
Local nPPrcVen  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPPrUnit  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPDescon		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPosValDesc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPIdentB6 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPQtdLib	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nUsado   		:= Len(aHeader)
Local nValDesc  	:= 0
Local nX        	:= 0
Local nY        	:= 0
Local nAux		  	:= 0
Local nPNumOrc   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMORC"})
Local nValorTot  	:= 0
Local nLinha     	:= 0
Local nColuna    	:= 0
Local nTotPoder3 	:= 0
Local nQtdOC	  	:= 0	
Local lWmsNew    	:= SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS  	:= Nil // S� inst�ncia em caso de uso

Local nPProduto 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPNfOrig 	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSerOrig 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItOrig		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPC6_PROJPMS	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROJPMS"})
Local nPC6_EDTPMS  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_EDTPMS"})
Local nPC6_TASKPMS 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TASKPMS"})

Local nPLoteCtl 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"}) 
Local nPRateio	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_RATEIO" })
Local nPosCc	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CC"})
Local nPEnder	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCALIZ"})
Local lValidOpc		:= .T.
Local lTabCli   	:= (SuperGetMv("MV_TABCENT",.F.,"2") == "1") 
Local cCliTab   	:= ""   
Local cLojaTab  	:= ""

Local l410ExecAuto	:= (Type("l410Auto") <> "U" .And. l410Auto)

// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec	:= SuperGetMV("MV_PRCDEC",,.F.)
Local aQtdP3 	:= {}

Local lAltCtr3	:= SuperGetMV("MV_ALTCTR3",.F.,.F.)
Local lGrdMult	:= "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
Local lTranCQ    	:= IsTranCQ()   
Local nVlrTab	 	:= 0
Local lVldDev	 	:= .T.
Local lCalcOpc  	:= .T.
Local lPrcMan	 	:= .F.
Local lBLOQSB6	:= SuperGetMv("MV_BLOQSB6",.F.,.F.) 
Local lLIBESB6 	:= SuperGetMv("MV_LIBESB6",.F.,.F.)
Local nAuxPrcVen	:= 0
Local cFieldFor	:= ""
Local lVlrZero	:= .F.
Local lRefGrd	:= 	lGrade .And. MatGrdPrrf(@aCols[n,nPProduto])
Local nComplPrc	:= 0
Local cFilSGA	:= ''
Local lContercOk:= .F.
Local nInd		:= 0
Local nTamLin 	:= 0
Local nPosItm 	:= 0
Local nLinDelAgg:= 0
Local lAchouOri	:= .F.
Local nPC6_OPER := 0
Local lDevArred	:= .F.
Local lItemFat  := .T.
Local nTamDec   := GetSX3Cache("C6_PRCVEN","X3_DECIMAL")		

Static __lTM410LiOk 	:= ExistTemplate("M410LIOK")
Static __lM410LiOk  	:= ExistBlock("M410LIOK")
Static __lM410ACDL		:= ExistBlock("M410ACDL")
Static __lMA410Pr 		:= ExistBlock("MA410PR")
Static __lA410CpyStack	:= IsInCallStack("A410COPIA") 
STATIC __lMetric 		:= Nil

aHeadAGG := IIf( Type( 'aHeadAGG' ) == 'A', aHeadAGG, {} )
aColsAGG := IIf( Type( 'aColsAGG' ) == 'A', aColsAGG, {} )

//����������������������������������Ŀ
//� Verifica a permissao do armazem. �
//������������������������������������
lRetorno := MaAvalPerm(3,{aCols[n][nPLocal],aCols[n][nPProduto]})

//�������������������������������������������������������Ŀ
//� Verifica se o item deletado possui ordem de separacao �
//���������������������������������������������������������
If lIntACD .and. aCols[n][Len(aCols[n])]
	lRetorno := CBM410ACDL()
EndIf 

//������������������������������������������������������Ŀ
//� verifica se linha do acols foi preenchida            �
//��������������������������������������������������������
If lRetorno .And. ( !CheckCols(n,aCols) )
	lRetorno := .F.
EndIf

//������������������������������������������������������Ŀ
//�  Caso o item nao esteja deletado                     �
//��������������������������������������������������������
If ( !aCols[n][Len(aCols[n])] .And. lRetorno )
	
	//������������������������������������������������������������������������Ŀ
	//�Verifica se os campos obrigatorios nao estao em branco                  �
	//��������������������������������������������������������������������������
	For nCntFor := 1 To nUsado
		
		cFieldFor := AllTrim(aHeader[nCntFor][2])
		
		Do Case
			Case ( cFieldFor == "C6_QTDVEN" )
				nQtdVen	:= aCols[n][nCntFor]
				nPosQtdVen	:= nCntFor
			Case ( cFieldFor == "C6_ITEM" )
				cItemSC6	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_QTDLIB" )
				nQtdLib 	:= aCols[n][nCntFor]
				nPosQtdLib  := nCntFor
			Case ( cFieldFor == "C6_PRCVEN" )
				nPrcVen 	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_VALOR" )
				nValor 	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_PRUNIT" )
				nPrUnit 	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_VALDESC" )
				nValDesc	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_PRODUTO" )
				cProduto	:= aCols[n][nCntFor]
				nPosProd	:= nCntFor
				//������������������������������������������������������Ŀ
				//�Verifica se a grade esta ativa, e se o produto digita-�
				//�do e' uma referencia                                  �
				//��������������������������������������������������������
				If ( lGrade ) .And. MatGrdPrRf(@cProduto)
					lGradeReal := .T.
				EndIf             
		   	Case ( cFieldFor == "C6_REVPROD" )
				nRevisao	:= nCntFor				
			Case ( cFieldFor == "C6_LOCAL" )
				cLocal   := aCols[n][nCntFor]
				nPosLocal:= nCntFor
			Case ( cFieldFor == "C6_TES" )
				cTes     := aCols[n][nCntFor]
			Case ( cFieldFor == "C6_NUMLOTE" )
				cNumLote := aCols[n][nCntFor]
			Case ( cFieldFor == "C6_LOTECTL" )
				cLoteCtl	:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_LOCALIZ" )
				cLocaliza := aCols[n][nCntFor]
			Case ( cFieldFor == "C6_NUMSERI" )
				cNumSerie := aCols[n][nCntFor]
			Case ( cFieldFor == "C6_IDENTB6" )
				cIdentB6  := aCols[n][nCntFor]
				nPosIdB6  := nCntFor
			Case ( cFieldFor == "C6_NFORI" )
				cNfOrig		:= aCols[n][nCntFor]
				nPosNfOrig	:= nCntFor
			Case ( cFieldFor == "C6_SERIORI" )
				cSerieOri	:= aCols[n][nCntFor]
				nPosSerOri  := nCntFor
			Case ( cFieldFor == "C6_ITEMORI" )
				cItemOri 	:= aCols[n][nCntFor]
				nPosItemOr 	:= nCntFor
			Case ( cFieldFor == "C6_GRADE" )
				cItemGrad:= aCols[n][nCntFor]
			Case ( cFieldFor == "C6_RESERVA" )
				cNumRes := aCols[n][nCntFor]
			Case ( cFieldFor == "C6_SERVIC" )
				nPosServ  := nCntFor
				cServico := aCols[n][nCntFor]
		EndCase
		
		If ( Empty(aCols[n][nCntFor]) )
			//����������������������������������������������������������������������������������������
			//Tratamento para quando for valor do item igual a zero permitido quando F4_VLRZERO = SIM�
			//����������������������������������������������������������������������������������������
			If cPaisLoc == "BRA"
				lVlrZero :=  Posicione("SF4",1,xFilial("SF4")+aCols[n][nPosTes],"F4_VLRZERO") == "1"
			EndIf	
			If ( lRetorno .And. AT(M->C5_TIPO,"CIP")==0 )
				If (	(cFieldFor == "C6_QTDVEN" .And. !MaTesSel(aCols[n][nPosTes])).Or.;
						cFieldFor == "C6_PRCVEN" .Or.;
						cFieldFor == "C6_VALOR"  .Or.;
						cFieldFor == "C6_TES" )
					If !lVlrZero
						Help(" ",1,"A410VZ")
						lRetorno := .F.
					ElseIf aCols[n][nPosValDesc ] != 0 .And. aCols[n][nPPrcVen] == 0 .And. !lVlrZero
						Help(" ",1,"410VALDESC")
						lRetorno := .F.						
					EndIf
				EndIf
			EndIf
			If ( lRetorno .And. AT(M->C5_TIPO,"CIP") <> 0 )
				If cPaisLoc == "BRA"
					If M->C5_TIPO $ "C" .And. M->C5_TPCOMPL == "2" .And.;	//Compl. Quantidade
						(	cFieldFor == "C6_QTDVEN" .Or.;
							cFieldFor == "C6_PRCVEN" .Or.;
							cFieldFor == "C6_VALOR"  .Or.;
							cFieldFor == "C6_TES" )
						If !lVlrZero .Or. (lVlrZero .And. aCols[n][nPosQtdVen] == 0)
							Help(" ",1,"A410VZ")
							lRetorno := .F.
						EndIf
					ElseIf (	cFieldFor == "C6_PRCVEN" .Or.;
								cFieldFor == "C6_VALOR"  .Or.;
								cFieldFor == "C6_TES" )
							Help(" ",1,"A410VZ2")
							lRetorno := .F.
					EndIf
				ElseIf (	cFieldFor == "C6_PRCVEN" .Or.;
							cFieldFor == "C6_VALOR"  .Or.;
							cFieldFor == "C6_TES" )
						Help(" ",1,"A410VZ2")
						lRetorno := .F.
				EndIf
			EndIf
			//������������������������������������������������������Ŀ
			//�Verifica se o pedido e uma devolucao de compra, um    �
			//�complemento de ICMS ou IPI, para validar a nota fiscal�
			//�de origem.                                            �
			//��������������������������������������������������������
			If ( lRetorno .And. At(M->C5_TIPO,"CIPD") <> 0 ) .AND. cFieldFor == "C6_NFORI"
				If ( At(M->C5_TIPO,"CIP") <> 0 )
					Help(" ",1,"A410COMPIP")
				Else
					Help(" ",1,"A410NFORI")
				EndIf
				lRetorno := .F.
			EndIf
			If cPaisLoc != "BRA" .AND. M->C5_TIPO $ "C" .And. Str(nPrcVen,15,2) <> Str(nValor,15,2) .And. nCntFor == nUsado //so testar na ultima vez
				 Help("",1,"A410VLPRC",,STR0424,1,0,,,,,,{STR0426}) //"O valor total n�o confere com o pre�o unit�rio"#"Verifique o valor total se condiz com o valor do pre�o de unit�rio e quantidade"		
				lRetorno := .F.
			EndIf
	
			//������������������������������������������������������Ŀ
			//�Verifica se o pedido e uma devolucao de compra,e se   �
			//�o produto possui rastro, se positivo o numero do lote �
			//�e' obrigatorio                                        �
			//��������������������������������������������������������
			If ( lRetorno .And. M->C5_TIPO == "D" .And. AvalTes(cTes,"S"))
				If ( 	( cFieldFor == "C6_NUMLOTE" .And.;
						Rastro(cProduto,"S") ) .Or.;
						( cFieldFor == "C6_LOTECTL" .And.;
						Rastro(cProduto,"L")) )
					HELP(" ",1,"A100S/LOT")
					lRetorno := .F.
				EndIf
			EndIf
		Else
			If ( cFieldFor == "C6_QTDVEN" .And. MaTesSel(aCols[n][nPosTes]) )
				aCols[n][nPosQtdVen] := 0
			EndIf
		EndIf
		
		If ( !lRetorno )
			nCntFor := nUsado + 1
		EndIf
		
	Next nCntFor
	
	//������������������������������������������������������������������������Ŀ
	//�Verifica se o produto nao esta preenchido.                              �
	//��������������������������������������������������������������������������
	If ( Empty(cProduto) )
		lRetorno := .F.
	EndIf

	//�����������������������������������������������������Ŀ
	//� Analisa se o tipo do armazem permite a movimentacao |
	//�������������������������������������������������������
	If lRetorno .And. !lRefGrd .And. AvalBlqLoc(aCols[n,nPProduto],aCols[n,nPLocal],aCols[n,nPosTes])
		lRetorno := .F.
	EndIf
			
	//������������������������������������������������������������������������Ŀ
	//�Valida se existe o local (armaz�m)informado			                   �
	//��������������������������������������������������������������������������
	If lRetorno .And. !Empty(cLocal)
		NNR->(DBSetOrder(1))	
		If !NNR->(dbSeek(xFilial("NNR")+cLocal))
			Help(" ",1,"A430LOCAL")
			lRetorno:= .F. 
		EndIf
	EndIf

	If lRetorno
		dbSelectArea("SC6")
        dbSetOrder(1)
        MsSeek(xFilial("SC6")+M->C5_NUM+cItemSC6+cProduto)
        If aCols[n][nPQtdVen]  <> SC6->C6_QTDVEN  .Or. ;
           aCols[n][nPPrcVen] <> SC6->C6_PRCVEN .Or. ;
           aCols[n][nPValor]  <> SC6->C6_VALOR  .Or. ;
           aCols[n][nPQtdLib] <> SC6->C6_QTDLIB .Or. ;
           aCols[n][nPosTes] <> SC6->C6_TES   .Or. ;
           aCols[n][nPLocal] <> SC6->C6_LOCAL
			If !ExistCpo("NNR",cLocal)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
				
	//������������������������������������������������������������������������Ŀ
	//�Posiciona Registros.                                                    �
	//��������������������������������������������������������������������������
	If lRetorno

		dbSelectArea("SF4")
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+cTes)

		dbSelectArea("SC0")
		dbSetOrder(1)
		MsSeek(xFilial("SC0")+cNumRes+cProduto+cLocal)

		If M->C5_TIPO == "D"
			dbSelectArea("SD1")
			dbSetOrder(1)
			lAchouOri := MsSeek(xFilial("SD1")+cNfOrig+cSerieOri+M->C5_CLIENTE+M->C5_LOJACLI+cProduto+cItemOri)
			If lAchouOri
				aVlrDev := A410SNfOri(SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_DOC,SD1->D1_SERIE ,SD1->D1_ITEM,SD1->D1_COD)
			EndIf
		Else
			If SF4->F4_PODER3=="D" .And. nPIdentB6 <> 0
				If !Empty(aCols[n][nPIdentB6])
					dbSelectArea("SD1")
					dbSetOrder(4)
					MsSeek(xFilial("SD1")+aCols[n][nPIdentB6])

					If 		!(AllTrim(SD1->D1_DOC) 		== AllTrim(aCols[n][nPNfOrig]) ;
						.AND. AllTrim(SD1->D1_SERIE) 	== AllTrim(aCols[n][nPSerOrig]);
						.AND. AllTrim(SD1->D1_ITEM) 	== AllTrim(aCols[n][nPItOrig]))
							Help("",1,"NFxIDENTB6",, STR0370,1,0,,,,,,{STR0371})	//"O campo Ident.Poder3 n�o condiz com a Nota Fiscal informada." / "Consulte as notas fiscais dispon�veis utilizando a tecla de atalho F4 na edi��o do campo quantidade."
							lRetorno := .F. 
					EndIf

					//Verifica se esta em um processo de integra��o (MATI411) e se tem informa��o de desconto
					//Caso sim, a valida��o do pre�o unitario � SD1 com SB6, caso n�o � nPrcVen com SB6.
					If IsInCallStack("MATI411") .And. SD1->D1_VALDESC > 0
						nAuxPrcVen := SD1->D1_VUNIT
					Else 
						nAuxPrcVen := nPrcVen 
					Endif

					dbSelectArea("SB6")
					dbSetOrder(3)	//B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3	
					MsSeek(xFilial("SB6")+aCols[n][nPIdentB6]+cProduto+"R")
												
					If Findfunction("MaAvCpUnit")
						nComplPrc := MaAvCpUnit(SB6->(B6_FILIAL+B6_IDENT+B6_PRODUTO)+"R")
					EndIf
					//Valida��o sobre o valor unit�rio da devolu��o conforme CAT n� 92/2001
					If A410Arred(nAuxPrcVen,"C6_PRCVEN")	  > A410Arred(SB6->B6_PRUNIT + nComplPrc, 'C6_PRCVEN')
						Help("",1,"A410VPPDR3",,STR0418,1,0,,,,,,{STR0419})//"Este produto pertence a poder de terceiros, onde o valor unit�rio deve ser condizente o documento de origem."#"Verifique se o valor unit�rio est� menor que o valor unit�rio registrado no Saldo em Poder de Terceiros."         
						lRetorno := .F. 
					Else
						If nQtdVen == SB6->B6_QUANT .And. ;
							A410Arred(nAuxPrcVen,"C6_PRCVEN") < A410Arred(SB6->B6_PRUNIT + nComplPrc, 'C6_PRCVEN')
							If A410Arred(((SD1->D1_QUANT * SD1->D1_VUNIT) - SD1->D1_VALDESC)/SD1->D1_QUANT,"C6_PRCVEN") <> A410Arred(nAuxPrcVen,"C6_PRCVEN")
								If !lLIBESB6
									Help("",1,"A410VSPDR3",,STR0418,1,0,,,,,,{STR0420})//Este produto pertence a poder de terceiros, onde o valor unit�rio deve ser condizente com o documento de origem#"Verifique se o valor unit�rio est� menor que o valor unit�rio registrado no Saldo em Poder de Terceiros." 
									lRetorno := .F.
								EndIf
							EndIf
						EndIf
					EndIf
					
					//������������������������������������������������������������������������Ŀ
					//�Retorna o valor total do saldo de/em poder de terceiros.                �
					//��������������������������������������������������������������������������
					If lRetorno
						nTotPoder3 := A410TotPoder3(cProduto,M->C5_TIPO,M->C5_CLIENTE,M->C5_LOJACLI,aCols[n][nPIdentB6])
					EndIf	
					If IsInCallStack("A410COPIA") .And. nTotPoder3 == 0 .And. !IsTriangular()
						Help(" ",1,"A100USARF4")
						lRetorno := .F.					
					EndIf
				Else
					Help(" ",1,"A100USARF4")
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
		//������������������������������������������������������Ŀ
		//� Verifica se tes � de canje 							  �
		//��������������������������������������������������������
		If cPaisLoc $ "ARG" .and. SF4->(ColumnPos( "F4_CANJE" )) > 0 .and. SC5->(ColumnPos( "C5_CANJE" )) > 0
			If !(SF4->F4_CANJE == M->C5_CANJE) .or. (SF4->F4_CANJE == "" .and. M->C5_CANJE == "1")
				Aviso( STR0038, STR0372, { "Ok" } )
				lRetorno := .F.
			EndIf
		EndIF
    EndIf
	//������������������������������������������������������������������������Ŀ
	//�Verifica se o cliente ou fornecedor � valido.                           �
	//��������������������������������������������������������������������������
	If lRetorno
		dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
		dbSetOrder(1)
		If MsSeek(xFilial(IIF(M->C5_TIPO$"DB","SA2","SA1"))+M->C5_CLIENTE+M->C5_LOJACLI)
			If !RegistroOk(IIF(M->C5_TIPO$"DB","SA2","SA1"))
				lRetorno	 := .F.
			Endif
		Endif
	Endif
	
	If lRetorno
		dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
		dbSetOrder(1)
		If MsSeek(xFilial(IIF(M->C5_TIPO$"DB","SA2","SA1"))+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT)
			If !RegistroOk(IIF(M->C5_TIPO$"DB","SA2","SA1"))
				lRetorno	 := .F.
			Endif
		Endif
	Endif	
	//������������������������������������������������������Ŀ
	//� Verifica a quantidade do pedido em relacao a quanti- �
	//� dade reservada.                                      �
	//��������������������������������������������������������
	If ( lRetorno .And. !Empty(cNumRes) )
		If ( !INCLUI ) .AND. ( SC6->(Found()) )
			nQtdRese += SC6->C6_QTDRESE
		EndIf
		If ( SC0->(Found()) )
			If ( SC0->C0_QUANT+nQtdRese < 0 )
				Help(" ",1,"A410RESERV")
				lRetorno := .F.
			EndIf
			If lRetorno .AND. GetNewPar("MV_CHCLRES",.F.) .AND. SC0->C0_TIPO == "CL" .AND. SC0->C0_DOCRES <> M->C5_CLIENTE
				lRetorno := .F.
				MsgAlert(STR0093 + Alltrim(cNumRes) + STR0094 + SC0->C0_DOCRES)
			Endif
			If ( lRetorno .And. (  SF4->F4_ESTOQUE=="N" .Or. M->C5_TIPO$"CIP") )
				Help(" ",1,"A410RESERV")
				lRetorno := .F.
			EndIf
			If ( (SC0->C0_LOTECTL <> cLoteCtl	.Or.;
					SC0->C0_NUMLOTE <> cNumLote	.Or.;
					SC0->C0_LOCALIZ <> cLocaliza	.Or.;
					SC0->C0_NUMSERI <> cNumSerie) )
				Help(" ",1,"A410RESERV")
				lRetorno := .F.
			EndIf
		Else
			Help(" ",1,"A410RESERV")
			lRetorno := .F.
		EndIf
	EndIf
	If ( lRetorno )
		//������������������������������������������������������������������Ŀ
		//�Verifica se eh grade para calcular o valor total por item da grade�
		//��������������������������������������������������������������������
		nValorTot := 0
        
		If M->C5_TIPO == "D" .And. lAchouOri .And. Len( aVlrDev ) > 0 .And. (QtdComp(nQtdVen) == QtdComp(aVlrDev[1]))
			nValorTot := aVlrDev[2]
		Else
			If lGrade .And. lGradeReal  .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
				If lGrdMult
					If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
						nValorTot := nValor 
					Else
						nValorTot := a410Arred(oGrade:SomaGrade("C6_VALOR",n),"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					EndIf
				Else
					For nLinha := 1 To Len(oGrade:aColsGrade[n])
						For nColuna := 2 To Len(oGrade:aHeadGrade[n])
							If ( oGrade:aColsFieldByName("C6_QTDVEN",n,nLinha,nColuna) <> 0 )
								If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
									nValorTot := nValor 
								Else
									nValorTot += a410Arred(oGrade:aColsFieldByName("C6_QTDVEN",n,nLinha,nColuna)*nPrcVen,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL))
								EndIf
							Endif
						Next nColuna
					Next nLinha
				EndIf
			Else
				If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
					nValorTot := nValor 
				Else
					nValorTot := A410Arred(nPrcVen*nQtdVen,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL))
					lDevArred := nPrcVen/nPrUnit == (nPrcVen*nQtdVen)/(nPrUnit*nQtdVen) //Se o valor da divis�o for o mesmo a diferen�a � de arredondamento
				EndIf
			EndIf
		EndIf

		//������������������������������������������������������������������������Ŀ
		//�Consiste o valor total do pedido de venda                               �
		//��������������������������������������������������������������������������
		Do Case
		Case cPaisLoc == "BRA" .And. ( AT(M->C5_TIPO,"DCIP") == 0 .AND.  SF4->F4_PODER3<>"D" ) .Or.;
				((M->C5_TIPO == "D" .Or. SF4->F4_PODER3=="D").And. QtdComp(nQtdVen)<>QtdComp(SD1->D1_QUANT))
			If ((nValor <> nValorTot .And. !lDevArred) .And. !MaTesSel(aCols[n][nPosTES])) .Or.;
					(nValor <> A410Arred(nPrcVen,"C6_VALOR") .And. MaTesSel(aCols[n][nPosTES]))		
				Help("",1,"A410VTDNO",,STR0422,1,0,,,,,,{STR0423}) //"O valor total n�o confere com o valor unit�rio x quantidade"#"Verifique o valor do pedido em rela��o ao documento de origem ou se a quantidade entregue condiz a quantidade vendida"
				lRetorno := .F.
			EndIf
			If !SD1->(Found()) .And. SF4->F4_PODER3=="D"
				Help(" ",1,"A100USARF4")
				lRetorno := .F.
			EndIf
		Case M->C5_TIPO == "D" .OR. SF4->F4_PODER3== "D"
			If lBLOQSB6 .Or. (!lBLOQSB6 .And. !lLIBESB6)
				If A410Arred(nValor,"C6_VALOR") <> A410Arred(IIf(Empty(nTotPoder3),SD1->D1_TOTAL-SD1->D1_VALDESC-SD1->D1_VALDEV,nTotPoder3),"C6_VALOR") .And.;
					!MaTesSel(aCols[n][nPosTES]).And.(!SC6->(Found()).Or.SC6->C6_QTDVEN-SC6->C6_QTDENT > 0)
					Help("",1,"A410TOTDPRC",,STR0422,1,0,,,,,,{STR0425})//"O valor total n�o confere com o valor unit�rio x quantidade"#"Verifique se a multiplica��o da quantidade e pre�o unit�rio condiz com o valor total"
					lRetorno := .F.
				EndIf
			EndIf	
			If !SD1->(Found()) .And. SF4->F4_PODER3=="D"
				Help(" ",1,"A100USARF4")
				lRetorno := .F.
			EndIf
		Case AT(M->C5_TIPO,"CIP") <> 0
			If cPaisLoc == "BRA"
				If M->C5_TIPO $ "C" .And. M->C5_TPCOMPL == "2" 	//Compl. Quantidade
					If ( A410Arred(nValor,"C6_VALOR") <> A410Arred(nValorTot,"C6_VALOR") )
				    	Help("",1,"A410TOTCPRC",,STR0422,1,0,,,,,,{STR0425})//"O valor total n�o confere com o pre�o de unit�rio"#"Verifique se a multiplica��o da quantidade e pre�o unit�rio condiz com o valor total"
						lRetorno := .F.
					EndIf								
				Else
					If ( A410Arred(nValor,"C6_VALOR") <> A410Arred(nPrcVen,"C6_VALOR") )
				        Help("",1,"A410VTPRC",,STR0424,1,0,,,,,,{STR0426}) //"O valor total n�o confere com o pre�o de unit�rio"#"Verifique o valor total se condiz com o valor do pre�o de unit�rio e quantidade"
						lRetorno := .F.
					EndIf				
				EndIf
			Else
				If ( A410Arred(nValor,"C6_VALOR") <> A410Arred(nPrcVen,"C6_VALOR") )
					Help("",1,"A410MIPRC",,STR0424,1,0,,,,,,{STR0426}) //"O valor total n�o confere com o pre�o de unit�rio"#"Verifique o valor total se condiz com o valor do pre�o de unit�rio e quantidadeo"
					lRetorno := .F.
				EndIf
			EndIf
		EndCase
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Verifica o TES                                                          �
	//��������������������������������������������������������������������������
	If ( lRetorno )
		If (n > 1 .And. !aCols[n-1][Len(aCols[n-1])])  //verifica se esta deletado
			lRetorno := A410ValTES(cTes,IIf(n > 1 ,aCols[n-1][nPosTes],Nil))
		Else
			lRetorno := A410ValTES(cTes,Nil)
		EndIf
	EndIf
	//������������������������������������������������������������������������������Ŀ
	//�Verifica se Existe Registro na Tabela de Rateio com o Campo C6_RATEIO = Sim  �
	//��������������������������������������������������������������������������������
	If aCols[n][nPRateio] == '1' //Rateio Igual a 1=Sim
		If Len( aHeadAGG ) == 0 .And. Len( aColsAGG ) == 0
			Help(" ",1,"A410RATEIO",, STR0404 + aCols[n][nPItem] + STR0405 , 2 ) //"O Item [ " " ] Esta Configurado com a Opcao de Rateio Igual a Sim e N�o Possui Rateio Cadastrado para ele."
			lRetorno := .F.
		Else
			nTamLin := 1 + Len( aHeadAGG )
			nPosItm := Ascan( aColsAGG, { | x | AllTrim( x[1] ) == AllTrim( aCols[n][nPItem] ) } )
			If nPosItm == 0
				Help(" ",1,"A410RATEIO",, STR0404 + aCols[n][nPItem] + STR0405 , 2 ) //"O Item [ " " ] Esta Configurado com a Opcao de Rateio Igual a Sim e N�o Possui Rateio Cadastrado para ele."
				lRetorno := .F.
			Else
				For nInd := 1 To Len( aColsAGG[ nPosItm ][ 2 ] )
					If aColsAGG[ nPosItm ][ 2 ][ nInd ][ nTamLin ]
						nLinDelAgg ++
					EndIf
				Next nInd

				If nLinDelAgg == Len( aColsAGG[ nPosItm ][ 2 ] )
					Help(" ",1,"A410RATEIO",, STR0404 + aCols[n][nPItem] + STR0405 , 2 ) //"O Item [ " " ] Esta Configurado com a Opcao de Rateio Igual a Sim e N�o Possui Rateio Cadastrado para ele."
					lRetorno := .F.				
				EndIf

			EndIf
		EndIf
	EndIf
	If ( lRetorno .And. Empty(cNumRes) )
		//������������������������������������������������������������������������Ŀ
		//�Consiste o item quanto a Rastro  ou Localizacao Fisica.                 �
		//��������������������������������������������������������������������������
		If ( SF4->F4_ESTOQUE=="N" .And. (!Empty(cLoteCtl) .Or. !Empty(cNumLote)) )
			If FindFunction("EstArmTerc")
				lContercOk:= EstArmTerc() //� Verifica de armzem de terceiro ativo �
			Else
				lContercOk:= .F.
			EndIF 	
		
			If !lContercOk .Or. (lContercOk .And. SF4->F4_CONTERC <> "1")
				Help(" ",1,"A410TEEST")
				lRetorno := .F.
			EndIf
		Else
			If ( SF4->F4_ESTOQUE =="S" .And. !(M->C5_TIPO $ "CIP") .And. SuperGetMv("MV_GERABLQ")=="N" )
				If !(lWmsNew .And. IntWms(cProduto))
					nSaldo := SldAtuEst(cProduto,cLocal,nQtdVen,cLoteCtl,cNumLote,cLocaliza,cNumSerie,cNumRes ,nil,nil,nil,nil,cServico)
				Else 
					oSaldoWMS := Iif(oSaldoWMS==Nil,WMSDTCEstoqueEndereco():New(),oSaldoWMS)
					nSaldo := oSaldoWMS:GetSldWMS(cProduto,cLocal,cLocaliza,cLoteCtl,cNumLote,cNumSerie)
				EndIf
				nSaldo += SC6->C6_QTDEMP
				If ( Localiza(cProduto,.T.)  )
					If ( M->C5_TIPO == "D" )
						If ( nSaldo < nQtdVen )
							Help(" ",1,"SALDOLOCLZ")
							lRetorno:=.F.
						EndIf
					Else
						If ( nSaldo < nQtdLib )
							If  ! l410ExecAuto
								Help(" ",1,"SALDOLOCLZ")
							EndIf
							nQtdLib := nSaldo
							aCols[n][nPosQtdLib] := nQtdLib
						EndIf
					EndIf
				EndIf
				If ( Rastro(cProduto) )
					If ( M->C5_TIPO == "D" )
						If ( nQtdVen > nSaldo )
							Help(" ",1,"A440ACILOT")
							lRetorno := .F.
						EndIf
					Else
						If ( nQtdLib > nSaldo )
							Help(" ",1,"A440ACILOT")
							nQtdLib := nSaldo
							aCols[n][nPosQtdLib] := nQtdLib
						EndIf
					EndIf
				EndIf
			EndIf
			If Findfunction("MtVlQtSe") .and. SF4->F4_ESTOQUE =="S" .And. !(M->C5_TIPO $ "CIP") .And. !Empty(cNumSerie) .and. Localiza(cProduto,.T.)
				lRetorno := MtVlQtSe(cProduto, cNumSerie, nQtdVen, nQtdLib)
			EndIf				
		EndIf
	EndIf
	//������������������������������������������������������Ŀ
	//�Verifica se o pedido se trata de poder de terceiros   �
	//�se positivo, verifica se e' um item de grade          �
	//�se for informa que a grade nao esta disponivel para   �
	//�poder de terceiros                                    �
	//��������������������������������������������������������
	If ( lRetorno .And. SF4->F4_PODER3 $ "RD" ) .AND. ( cItemGrad == "S" )
		Help(" ",1,"A410GRATER")
		lRetorno:=.F.
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Verifica o saldo do Poder de Terceiro                                   �
	//��������������������������������������������������������������������������
	If ( lRetorno .And. SF4->F4_PODER3=="D" )
		aQtdP3 := A410SNfOri(M->C5_CLIENTE,M->C5_LOJACLI,cNfOrig,cSerieOri,"",cProduto,cIdentB6,aCols[n][nPosLocal],,@aPedido)
		If ( aQtdP3[1] < 0 )
			If !Empty(aPedido)
				cAviso := ""
				For nX:=1 To Len(aPedido)
					cAviso += aPedido[nX] + " | "
				Next nX
				Aviso( STR0038, STR0087+cAviso, { "Ok" } )
				lRetorno := .F.
			Else
				Help(" ",1,"A100USARF4")
				lRetorno := .F.
			EndIf
		Else
			//������������������������������������������������������������������������Ŀ
			//�Verifica o saldo da Liberacao de CQ                                     �
			//��������������������������������������������������������������������������
			If aQtdP3[4][6] > 0 
				If (aQtdP3[5]+aQtdP3[6]) > (aQtdP3[4][1]-aQtdP3[4][6])
					Aviso( STR0038, STR0113, { "Ok" } )
					lRetorno := .F.				
				Endif
			Endif			
		EndIf
	EndIf
	//������������������������������������������������������Ŀ
	//� Nao permite a inclusao do produto se o almoxarifado  �
	//� for igual o do CQ e o tipo do pedido for NORMAL.     �
	//� e n�o for transferencia. 							     �
	//����������������������������������������������Larson����
	If lRetorno                                        .AND.;
	   ( M->C5_TIPO $ "NB" .AND. SF4->F4_PODER3<>"D" ) .AND.;
	   cLocal == GetMv("MV_CQ")                        .AND.;
	   !(SF4->F4_TRANFIL=='1' .And. lTranCQ .And. SF4->F4_TRANCQ=='1' .And. IsInCallStack("MATA310"))

		Help(" ",1,"ARMZCQ",,GetMv("MV_CQ"),2,15)
		lRetorno := .F.
	EndIf

	//������������������������������������������������������Ŀ
	//�Quando devolucao verifica se a nota fiscal de origem  �
	//�existe                                                �
	//��������������������������������������������������������
	If ( lRetorno .And. M->C5_TIPO == "D" )
		dbSelectArea("SD1")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SD1")+cNfOrig+cSerieOri+M->C5_CLIENTE+M->C5_LOJACLI+cProduto) .And. Empty(cItemOri) )
			Help(" ",1,"A410S/ITDE")
			lRetorno := .F.
		Else
			//������������������������������������������������������������������������Ŀ
			//�Consiste no acols a saldo em quantidade e valor da devolucao            �
			//��������������������������������������������������������������������������
			If lRetorno .And. !Empty(cItemOri)
				aVlrDev := a410SNfOri(M->C5_CLIENTE,M->C5_LOJACLI,cNfOrig,cSerieOri,cItemOri,cProduto,Nil,aCols[n][nPosLocal])

				//������������������������������������������������������������������Ŀ
				//� Se o campo do valor unit�rio tiver mais que 2 casas decimais e a �
				//� diferen�a for menor que 0.01, n�o faz a valida��o dos valores.	 �
				//��������������������������������������������������������������������
				If TamSX3("C6_PRCVEN")[2] > 2 .And. SuperGetMv("MV_ARREFAT")=="S" .AND. (nValor - aVlrDev[2]) <= 0.01
					lVldDev := .F.
				EndIf
				
				If lVldDev .And. (nPrcVen != Iif(nQtdVen==0,Round(nPrcVen-nValDesc,nTamDec),Round(((nPrUnit*nQtdVen)-nValDesc)/nQtdVen,nTamDec)))
					Help("",1,"A410VLDIF",,STR0427,1,0,,,,,,{STR0428})//"Por se tratar de uma Nota Fiscal de Devolu��o, o valor unit�rio deve ser igual ao da Nota Fiscal de Origem"#"Verificar o valor da nota fiscal original"
					lRetorno := .F.
				Else
					If ( nQtdVen > aVlrDev[1] )	
						Help(" ",1,"A410NSALDO")
						lRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Valida��es do m�dulo WMS referente ao item da linha                     �
	//��������������������������������������������������������������������������
	If lRetorno .And. IntWms(cProduto)
		lRetorno := WmsAvalSC6("1","SC6",aCols,n,aHeader,ALTERA)
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Verifica a integridade do contrato de parceira                          �
	//��������������������������������������������������������������������������
	If lRetorno .And. nPContrat > 0 .And. nPItContr > 0 .And. ADB->(LastRec())<>0
	
		//������������������������������������������������������������������������Ŀ
		//�Busca quantidade do item da Ordem de Carregamento - SIGAAGR -UBS   	   �
		//��������������������������������������������������������������������������
		If AliasIndic("NPN")
			NPN->(dbSetOrder(3))
			If INCLUI .And. IsIncallStack("AGRA900")
				nQtdOC := aCols[n][nPQtdVen]
			ElseIf ALTERA .And. NPN->(dbSeek(xFilial("NPN")+SC6->(C6_NUM+C6_ITEM)))
				nQtdOC := NPN->NPN_QUANT
			EndIf
		EndIf

		//������������������������������������������������������Ŀ
		//� Verifica o saldo de contratos deste pedido de venda  �
		//��������������������������������������������������������
		For nY := 1 To Len(aCols)
			If !aCols[nY][nUsado+1] .And. N <> nY .And. !Empty(aCols[nY][nPContrat])
				nX := aScan(aContrato,{|x| x[1] == aCols[nY][nPContrat] .And. x[2] == aCols[nY][nPItContr]})
				If nX == 0
					aAdd(aContrato,{aCols[nY][nPContrat],aCols[nY][nPItContr],aCols[nY][nPQtdVen]})
					nX := Len(aContrato)
				Else
					aContrato[nX][3] += aCols[nY][nPQtdVen]
				EndIf
			EndIf
			dbSelectArea("SC6")
			dbSetOrder(1)
			If ALTERA .And. MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nY][nPItem]) .And. !Empty(SC6->C6_CONTRAT)
				nX := aScan(aContrato,{|x| x[1] == SC6->C6_CONTRAT .And. x[2] == SC6->C6_ITEMCON})
				If nX == 0
					aAdd(aContrato,{SC6->C6_CONTRAT,SC6->C6_ITEMCON,0})
					nX := Len(aContrato)
				EndIf
				aContrato[nX][3] -= SC6->C6_QTDVEN
			EndIf
		Next nY

		dbSelectArea("ADB")
		dbSetOrder(1)
		If MsSeek(xFilial("ADB")+aCols[n][nPContrat]+aCols[n][nPItContr])
			//������������������������������������������������������������������������Ŀ
			//�Verifica a quantidade                                                   �
			//��������������������������������������������������������������������������
			If Empty(ADB->ADB_PEDCOB) .And. !Empty(ADB->ADB_TESCOB)
				If nQtdVen <> ADB->ADB_QUANT .Or. aCols[n][nPosTES] <> ADB->ADB_TESCOB
					Help(" ",1,"A410CTRQT1")
					lRetorno := .F.
				EndIf
			Else
				nX := aScan(aContrato,{|x| x[1] == aCols[n][nPContrat] .And. x[2] == aCols[n][nPItContr]})
				If nQtdVen > ADB->ADB_QUANT - (ADB->ADB_QTDEMP - nQtdOC)-If(nX>0,aContrato[nX][3],0) .And. (nPNumOrc==0 .Or. Empty(aCols[n][nPNumOrc]))
					Help(" ",1,"A410CTRQT2")
					lRetorno := .F.
				EndIf
				//������������������������������������������������������������������������Ŀ
				//�Verifica o preco de venda                                               �
				//��������������������������������������������������������������������������
				If lRetorno .And. ADB->ADB_PRCVEN>nPrcVen .And. !lAltCtr3 .And. !(M->C5_TIPO $ "I|P")
					Aviso(STR0038, STR0079, {'Ok'})
					lRetorno := .F.
				EndIf                  
				
				//������������������������������������������������������������������������Ŀ
				//�Valida quantidade da ordem de carregamento - SIGAAGR(UBS)               �
				//��������������������������������������������������������������������������
				If lRetorno .AND. !Empty(SC6->C6_NUM+SC6->C6_ITEM)
					NPN->(dbSetOrder(3))
					If NPN->(dbSeek(xFilial("NPN")+SC6->(C6_NUM+C6_ITEM)))
						If nQtdVen <> If(nX>0,ABS(aContrato[nX][3]),0)
							Help(" ",1,"A410QTDOC")
							lRetorno := .F.
						EndIf
					EndIf	
				EndIf
			Endif
		Else
			aCols[n][nPContrat] := CriaVar("C6_CONTRAT",.F.)
			aCols[n][nPItContr] := CriaVar("C6_ITEMCON",.F.)
		EndIf
	EndIf
    
	//���������������������������������������������������������������������������������������������������������������Ŀ
	//� Verifica se o produto est� em revisao vigente e envia para armazem de CQ para ser validado pela engenharia    �
	//�����������������������������������������������������������������������������������������������������������������         
	If lRetorno .And. lRevProd
	 
		cRvSB5 := Posicione("SB5",1,xFilial("SB5")+aCols[n,nPosProd],"B5_REVPROD")
		cBlqSG5:= Posicione("SG5",1,xFilial("SG5")+aCols[n,nPosProd]+aCols[n,nRevisao],"G5_MSBLQL")  
		cStatus:= Posicione("SG5",1,xFilial("SG5")+aCols[n,nPosProd]+aCols[n,nRevisao],"G5_STATUS")
	    If cRvSB5=="1"
		    If Empty(cRvSB5)
				Aviso(STR0038,STR0209,{STR0040})//"N�o foi encontrado registro do produto selecionado na rotina de Complemento de Produto."  
				lRetorno:= .F.
			ElseIf Empty(cBlqSG5)
				Aviso(STR0038,STR0210,{STR0040})//"O produto selecionado n�o possui revis�o em uso. Verifique o cadastro de Revis�es."	
				lRetorno:= .F. 
			ElseIf cBlqSG5=="1"
				Help(" ",1,"REGBLOQ")	
				lRetorno:= .F.        
			ElseIf cStatus=="2" .AND. cTes < "500"
				Aviso(STR0038,STR0211,{STR0040})//"Esta revis�o n�o pode ser alimentada pois est� inativa."
				lRetorno:= .F.		
			EndIf
		EndIf
	EndIf 

	//������������������������������������������������������������������������Ŀ
	//� Valida as colunas do browse referente ao SIGAPMS                       �
	//� Colunas: C6_PROJPMS, C6_EDTPMS, C6_TASKPMS                             �
	//��������������������������������������������������������������������������
	If lRetorno .AND. ( nPC6_PROJPMS > 0 .AND. nPC6_EDTPMS > 0 .AND. nPC6_TASKPMS > 0 )
		lRetorno := a410VldPMS(aCols[n][nPC6_PROJPMS],aCols[n][nPC6_EDTPMS],aCols[n][nPC6_TASKPMS],SF4->F4_MOVPRJ,M->C5_TIPO )
	EndIf

	//
	// Template GEM 
	// valida o empreendimento e o codigo do produto
	//
	If lRetorno 
		If ExistBlock("GEM410LI") 
			lRetorno := ExecBlock("GEM410LI",.F.,.F.,{N})
		ElseIf ExistTemplate("GEM410LI") 
			lRetorno := ExecTemplate("GEM410LI",.F.,.F.,{N})
		Endif
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Atualiza os Opcionais                                                   �
	//��������������������������������������������������������������������������
	If lRetorno .And. If(Type("lShowOpc")=="L",lShowOpc,.F.) .And. !( Type("l410Auto") != "U" .And. l410Auto ) .And. nPOpcional > 0
		lValidOpc := ( Empty(aCols[n][nPOpcional]) )
		cOpcional := aCols[n][nPOpcional]
		cOpcioAnt := aCols[n][nPOpcional]

		If !lOpcPadrao
			aOpcional := STR2ARRAY(cOpcional,.F.)
			If ValType(aOpcional)=="A" .And. Len(aOpcional) > 0
				For nAux := 1 To Len(aOpcional)
					cOpcional += aOpcional[nAux][2]
					cOpcioAnt += aOpcional[nAux][2]
				Next nAux
			EndIf	
		EndIf
		
		lRetorno := SeleOpc(2,"MATA410",cProduto,,,aCols[n][nPOpcional],"M->C6_PRODUTO",,aCols[n,nPQtdVen],aCols[n,nPEntreg])

		If !lRetorno  
			aCols[n][nPOpcional] := cOpcioAnt
		EndIf

		If !lOpcPadrao
			aOpcional := STR2ARRAY(aCols[n][nPOpcional],.F.)
			If ValType(aOpcional)=="A" .And. Len(aOpcional) > 0
				For nAux := 1 To Len(aOpcional)
					cOpcional += aOpcional[nAux][2]
				Next nAux
			Else
				cOpcional := ""
				cOpcioAnt := ""
			EndIf	
		Else
			cOpcional := aCols[n][nPOpcional]
		EndIf

		If !Empty(cOpcional) .and. (lValidOpc .or. cOpcional <> cOpcioAux)		
			If lTabCli
				Do Case
					Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
						cCliTab   := M->C5_CLIENT
						cLojaTab  := M->C5_LOJAENT
					Case Empty(M->C5_CLIENT) 
						cCliTab   := M->C5_CLIENTE
						cLojaTab  := M->C5_LOJAENT
					OtherWise
						cCliTab   := M->C5_CLIENTE
						cLojaTab  := M->C5_LOJACLI
				EndCase					
			Else
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJACLI
			Endif
			
			// Como o campo C6_OPC est� preenchido, a soma dos valores dos opcionais no preco de lista sera feito na funcao
			nVlrTab := Iif(A410Tabela(	aCols[n][nPProduto],;
													M->C5_TABELA,;
													n,;
													aCols[n][nPQtdVen],;
													cCliTab,;
													cLojaTab,;
													If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
													If(nPNumLote>0,aCols[n][nPNumLote],"")	)>0,A410Tabela(	aCols[n][nPProduto],;
													M->C5_TABELA,;
													n,;
													aCols[n][nPQtdVen],;
													cCliTab,;
													cLojaTab,;
													If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
													If(nPNumLote>0,aCols[n][nPNumLote],"")	),aCols[n][nPPrUnit])
		
		Else
			nVlrTab := aCols[n][nPPrUnit]
		EndIf										

		If !lGrdMult  
			If aCols[n][nPPrcVen] > 0 .And. aCols[n][nPPrUnit] == 0 .And. cOpcional <> cOpcioAnt
				//Se for informado somente o pre�o unit�rio (C6_PRCVEN).
				aCols[n][nPPrcVen] += nVlrTab
				aCols[n][nPValor]  := a410Arred(IIf(nQtdVen==0,1,nQtdVen) * aCols[n][nPPrcVen],"C6_VALOR") 
				lPrcMan := .T.
				lCalcOpc := .F.
			ElseIf aCols[n][nPPrUnit] > 0 .And. aCols[n][nPPrcVen] > 0 .And. Empty(M->C5_TABELA)
				If MaTabPrVen(M->C5_TABELA,aCols[n][nPProduto],aCols[n][nPQtdVen],cCliTab,cLojaTab) > 0
					lPrcMan := .F.
					lCalcOpc := .T.
				Else
					lPrcMan := .T.
					lCalcOpc := .T.
				EndIf	
			ElseIf aCols[n][nPPrUnit] > 0 .And. aCols[n][nPPrcVen] > 0 .And. !Empty(M->C5_TABELA)
				If cOpcional <> cOpcioAnt .And. aCols[n][nPPrUnit] <> MaTabPrVen(M->C5_TABELA,aCols[n][nPProduto],aCols[n][nPQtdVen],cCliTab,cLojaTab)
					lPrcMan := .T.
					lCalcOpc := .T.
				EndIf
			ElseIf aCols[n][nPPrUnit] > 0 
				aCols[n][nPPrUnit] := nVlrTab
			EndIf
		EndIf			

		If !Empty(cOpcioAnt) .And. !lPrcMan
			If cOpcional == cOpcioAnt .And. aCols[n][nPPrcVen] <> aCols[n][nPPrUnit]
				lCalcOpc := .F.
			ElseIf cOpcional == cOpcioAnt .And. aCols[n][nPPrcVen] == aCols[n][nPPrUnit]
				lCalcOpc := .F.
			ElseIf cOpcional <> cOpcioAnt  .And. aCols[n][nPPrcVen] <> aCols[n][nPPrUnit]
				aCols[n][nPPrcVen] := A410Arred(FtDescCab(aCols[n][nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
				aCols[n][nPValor]  := A410Arred(aCols[n][nPPrcVen]*nQtdVen,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL))
				lCalcOpc := .T.
			Else
				lCalcOpc := .T.
			EndIf	
		EndIf
		
		If __lMA410Pr .And. (!Empty(cOpcional) .Or. !Empty(cOpcioAnt))
			aCols[n][nPPrcVen] := ExecBlock("MA410PR",.F.,.F.) 
			aCols[n][nPValor]  := a410Arred(IIf(nQtdVen==0,1,nQtdVen) * aCols[n][nPPrcVen],"C6_VALOR")
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Aqui � efetuado o tratamento diferencial de Precos para os   �
		//� Opcionais do Produto.                                        �
		//����������������������������������������������������������������
		SGA->( DBSetOrder( 1 ) ) //GA_FILIAL+GA_GROPC+GA_OPC     
		cFilSGA := xFilial("SGA")
		
		While !Empty(cOpcional) .And. lCalcOpc
			cOpc      := SubStr(cOpcional,1,At("/",cOpcional)-1)
			cOpcional := SubStr(cOpcional,At("/",cOpcional)+1)

			If SGA->( DbSeek(cFilSGA+cOpc) ) .AND. AT(M->C5_TIPO,"CIP") == 0 
				aCols[n][nPPrcVen] += SGA->GA_PRCVEN
				aCols[n][nPValor]  := A410Arred(aCols[n][nPPrcVen]*nQtdVen,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL))
			EndIf
		EndDo

		If lRetorno
			lShowOpc := .F.
		EndIf
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verificar se for devolucao e o produto for quality, se o mesmo ja foi   �
//�liberado do estoque na qualidade.                                       �
//��������������������������������������������������������������������������
If ( lRetorno .And. !aCols[n][Len(aCols[n])] .and. M->C5_TIPO == "D" )
	lRetorno := Ma410VldQEK( M->C5_CLIENTE,M->C5_LOJACLI,aCols[n][nPNfOrig],aCols[n][nPSerOrig],aCols[n][nPItOrig],aCols[n][nPProduto]) 
EndIF

If ( aCols[n][Len(aCols[n])] .And. lRetorno )
	//������������������������������������������������������������������������Ŀ
	//�Posiciona Registros.                                                    �
	//��������������������������������������������������������������������������
	SC6->( DBSetOrder( 1 ) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]) )
		//������������������������������������������������������������������������Ŀ
		//�Qdo um item possuir quantidade entregue nao deve ser permitida a        �
		//�exclusao neste item.                                                    �
		//��������������������������������������������������������������������������
		If lRetorno .And.;
		   ( ( SC6->C6_QTDENT <> 0 .And. !(aCols[n][nPosTes] $ AllTrim(cBonusTes)) ) .OR.;
		     ( SC5->C5_TIPO == "I" .And. !Empty(SC6->C6_NOTA) ) )
			Help(" ",1,"A410FAT")
			lRetorno := .F.
		EndIf
		//��������������������������������������������������������������������������������Ŀ
		//�Se utilizar grade de produtos verifica a grade referente ao produto selecionado.�
		//�Caso exista quantidade entregue para algum item da grade n�o permite a exclus�o.�
		//����������������������������������������������������������������������������������
		If ( lRetorno .And. lGrade )
			While SC6->(! EOF())                                          .AND.;
			      SC6->C6_FILIAL == xFilial("SC6")                        .AND.;
				  SC6->C6_NUM == M->C5_NUM                                .AND.;
				  Substr(SC6->C6_PRODUTO,1,nTamRef) $ aCols[n][nPProduto] .AND.;
				  SC6->C6_GRADE == "S"

				If SC6->C6_QTDENT <> 0
					Help(" ",1,"A410FAT")
					lRetorno := .F.
				EndIf
				SC6->(dbSkip())
			EndDo	
		EndIf
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//�Impede a exclusao de Itens do Pedido com Servico de WMS jah executado  �
	//�������������������������������������������������������������������������
	nPosProd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	If lRetorno .And. IntWms(aCols[n, nPosProd]) .And. ALTERA
		lRetorno := WmsAvalSC6("2","SC6",aCols,n,aHeader,ALTERA)
	EndIf
EndIf

dbSelectArea("SC6")
//������������������������������������������������������������������������Ŀ
//� Pontos de Entrada 				                                       �
//��������������������������������������������������������������������������
If lRetorno .And. __lTM410LiOk
	lRetorno := ExecTemplate("M410LIOK",.F.,.F.,o)
EndIf

If lRetorno .And. __lM410LiOk
	lRetorno := ExecBlock("M410LIOK",.F.,.F.,o)
EndIf 

If lRetorno .And. __lM410ACDL
	lRetorno := ExecBlock("M410ACDL",.F.,.F.)
EndIf

If lRetorno
	//������������������������������������������������������������������Ŀ
	//�Valida a TES informada em relacao ao conteudo do campo C5_LIQPROD �
	//��������������������������������������������������������������������			
	lRetorno := IIF(cPaisLoc == "ARG", A410VldTes(), lRetorno)
EndIf

If lRetorno .And. FWIsInCallStack("MATA410")
	//����������������������������������������������������������������������������������������Ŀ
	//�Posiciona Registros e verifica se o item j� foi faturado, para n�o validar CC bloqueado �
	//������������������������������������������������������������������������������������������
	SC6->( DBSetOrder( 1 ) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]) )
		lItemFat := (Empty(SC6->C6_NOTA) .And. Empty(SC6->C6_DATFAT))
	EndIf
EndIf

If lRetorno	.And. nPosCc > 0 .And. !Empty( aCols[n][nPosCc] ) .And. lItemFat
	lRetorno := CTB105CC( aCols[n][nPosCc] )
EndIf

If lRetorno	.And. nPEnder > 0 .And. !Empty( aCols[n][nPEnder] )
	SBE->( dbSetOrder( 1 ) )
	If SBE->( dBSeek( xFilial( "SBE" ) + aCols[n][nPLocal] + aCols[n][nPEnder] ) ) .And. !RegistroOk("SBE",.F.)
		Help( "", 1, "REGBLOQ",,"SBE" + Chr(13) + Chr(10) + AllTrim( RetTitle( "BE_LOCALIZ" ) ) + ": " + SBE->BE_LOCAL + "-" + SBE->BE_LOCALIZ, 3, 0 )
		lRetorno := .F.
	EndIf
EndIf

//Valida a data da LIB para utiliza��o na Telemetria
If lRetorno	.And. FatLibMetric()
	nPC6_OPER := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})
	If nPC6_OPER > 0
		//Telemetria - Se utiliza TES Inteligente no Pedido - "1- Utiliza TES Intelig�nte e 2- N�o utiliza"
		FwCustomMetrics():setUniqueMetric("MATA410","faturamento-protheus_utilizacao-tes-inteligente-pedido-de-venda_total",IIf(!Empty(aCols[n][nPC6_OPER]),"1","2"),/*dDateSend*/,/*nLapTime*/,"MATA410")
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//� Restaura a integridade da rotina                                       �
//��������������������������������������������������������������������������
If !l410ExecAuto
	Ma410Rodap(o)
EndIf

RestArea(aArea)
Return(lRetorno)       

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410ValDel� Autor � Aline Correa do Vale  � Data �05/03/02  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a exclusao de itens com OP na alteracao do PV       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function A410ValDel(lVldOP)      

Local lRet		:= .T.
Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPosTes   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosOP  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OP"})
Local nPosNumOP  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMOP"})
Local nPosItemOP  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMOP"})
Local lAtuSGJ	:= SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local lM410lDel := ExistBlock("M410lDel")	//Ponto de entrada para validar a exclusao de itens na alteracao
Local lPrcPod3  := ( GetNewPar( "MV_PRCPOD3", "1" ) == "2" )                    
Local lRetPE    := .F.
Local cPoder3	:= ""
Local lIncMat416:= ( IsInCallStack("MATA416") .And. IsInCallStack("A410INCLUI") )
Local cNumpedido:= M->C5_NUM

Default lVldOP := .T.

If lVldOP .Or. lIncMat416 
	//������������������������������������������������������Ŀ
	//� Trata se exclui ou nao itens que geraram OPs         �
	//��������������������������������������������������������
	If !aCols[n][Len(aCols[n])]
		SC6->(dbSetOrder(1))
		If SC6->(MsSeek(xFilial("SC6")+cNumpedido+aCols[n][nPosItem]+aCols[n][nPosProd])) .Or. lIncMat416
			If (SC6->C6_OP $ "01/03") .Or. (lIncMat416 .And. aCols[n][nPosOP] $ "01/03")
				If !lAtuSGJ .And. SuperGetMv("MV_DELPVOP",.F.,.T.)
					If lIncMat416
						lRet:=(Aviso(OemToAnsi(STR0014),STR0027+aCols[n][nPosItem]+" - "+aCols[n][nPosProd]+STR0028+aCols[n][nPosNumOP]+" "+aCols[n][nPosItemOP]+"."+STR0029,{STR0030,STR0031}) == 1) //"Aten��o"###"O item "###" gerou a Ordem de Producao "###"Confirma Exclusao ?"###"Sim"###"Nao"
					Else
						lRet:=(Aviso(OemToAnsi(STR0014),STR0027+SC6->C6_ITEM+" - "+SC6->C6_PRODUTO+STR0028+SC6->C6_NUMOP+" "+SC6->C6_ITEMOP+"."+STR0029,{STR0030,STR0031}) == 1) //"Aten��o"###"O item "###" gerou a Ordem de Producao "###"Confirma Exclusao ?"###"Sim"###"Nao"
					EndIf	
				Else
					Aviso(OemToAnsi(STR0014),STR0060,{STR0040})
					lRet := .F.
				Endif
			EndIf
   		EndIf
	EndIf
EndIf

If lRet 
	DbSelectArea('TEW')
	TEW->( DbSetOrder( 4 ) )  // TEW_FILIAL+TEW_NUMPED+TEW_ITEMPV
	If TEW->( DbSeek( xFilial('TEW')+M->C5_NUM+aCols[n][nPosItem] ) )
		lRet := .F.
		Help(,,'A410GSLOCLIN',,STR0230,1,0) // 'Item n�o pode ser exclu�do pois � referente � movimenta��o de equipamento para loca��o.'
	EndIf
EndIf

//PONTO DE ENTRADA ORIGINA��O - VALIDA EXCLUSAO
If FindFunction("OGX225B") .AND. (SuperGetMV("MV_AGRUBS",.F.,.F.))
   lRet := OGX225B(lRet)
EndIf

If lRet .AND. lM410lDel
	//��������������������������������������������������������������Ŀ
	//�Ponto de entrada para validar a exclusao de itens na alteracao�
	//����������������������������������������������������������������
   	lRetPE := ExecBlock("M410lDel",.F.,.F.,{lRet})
	lRet   := Iif( ValType(lRetPE) == "L",lRetPE,lRet)
EndIf	

If lRet .And. Type("M->C5_TABELA") != "U" .And. !Empty(M->C5_TABELA)
	
	cPoder3 := "N"
	If nPosTes > 0
		DbSelectArea("SF4")
		DbSetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[n][nPosTes])
			cPoder3 := SF4->F4_PODER3
		EndIf
	EndIf
	
	If Type("M->C5_TIPO") != "U" .And. ( ( M->C5_TIPO=="N" .And. cPoder3 == "N" ) .Or. lPrcPod3 ) 
		A410RvPlan(M->C5_TABELA,aCols[n][nPosProd], .F./*lClear*/, .T./*lDeleta*/)
	EndIf
EndIf

If cPaisLoc == "RUS" .AND. lRet
	MaFisDel(n,aCols[n][Len(aCols[n])])
Endif

If lRet .And. Type("M->C5_MDCONTR") != "U" .And. !Empty(M->C5_MDCONTR)
	lRet := Empty(aCols[n][Len(aHeader)]) //Permite excluir apenas itens inseridos
EndIf

Return lRet                              

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410gValid� Autor �Eduardo Riera          � Data �26.02.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Grade de Produtos                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se os valores digitados na grade sao validos  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Linha do aCols                                       ���
���          �ExpL2: Indica se foi alterada a quantidade vendida          ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a410GValid(nLinAcols,lQtdVen)     // --> Parametros usados para manter legado

Local lRetorno	:=.T.
Local nColuna	:= aScan(oGrade:aHeadGrade[oGrade:nPosLinO],{|x| ValType(x) # "C" .And. AllTrim(x[2]) == AllTrim(Substr(Readvar(),4))})
Local cProdGrd	:= ""
Local xConteudo	:= &(ReadVar())
Local nPDescon  := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_DESCONT" })
Local nPEntreg  := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_ENTREG" })
Local nPOpc     := aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_OPC" })
Local nGrdPrc 	:= 0
Local nTotPrc   := 0
Local aHeadBkp  := {}
Local aColsBkp  := {}
Local nNBkp 	:= 0
Local cOpcMark  := oGrade:aColsGrade[oGrade:nPosLinO,n,nColuna,oGrade:GetFieldGrdPos("C6_OPC")]
Local cOpc	    := ""
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
Local nAcrePrc  := 0

lQtdVen		:= If(lQtdVen==NIL,(oGrade:cCpo<>"C6_QTDLIB"),lQtdVen)
nLinAcols	:= oGrade:oGetDados:oBrowse:nAt
cProdGrd	:= oGrade:GetNameProd(,n,nColuna)

If Posicione("SX3",2,oGrade:cCpo,"X3_TIPO") == "N"
	lRetorno := Positivo()
EndIf

If lRetorno .And. lGrdMult .And. oGrade:cCpo == "C6_PRCVEN" .And. oGrade:aColsFieldByName("C6_PRCVEN",,n,nColuna) <> xConteudo .And. !Empty(oGrade:aColsAux[oGrade:nPosLinO,nPDescon])
	Help(" ",1,"A410PRCD")
	lRetorno := .F.
EndIf

If lRetorno .And. lQtdVen
	lRetorno := RegistroOk("SB1")
EndIf         

If lRetorno
 	lRetorno := A410PedFat(cProdGrd,.T.,xConteudo,lQtdVen) 
EndIf

If lRetorno .AND. ExistBlock("A410GVLD")
	//ATENCAO -> TRATAR ESTE PONTO DE ENTRADA E VER SE SERA NECESSARIO CRIAR VARIAVEIS PARA MANTER LEGADO    
	If Valtype('aHeadGrade')<>'A' .And. Valtype('aColsGrade')<>'A'
		PRIVATE aHeadGrade := {}
		PRIVATE aColsGrade := {}
	EndIf
	aHeadGrade := aClone(oGrade:aHeadGrade)
   	aColsGrade := aClone(oGrade:aColsGrade) 		

	ExecBlock("A410GVLD",.F.,.F.,{nLinAcols,n,nColuna})

	If Valtype('aHeadGrade')=='A' .And. Valtype('aColsGrade')=='A'
		oGrade:aHeadGrade := aClone(aHeadGrade)	
		oGrade:aColsGrade := aClone(aColsGrade)
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica a quantidade Liberada                                          �
//��������������������������������������������������������������������������
If ( !lQtdVen ) .AND. ( SuperGetMv("MV_LIBACIM") )
	If  ( xConteudo > (oGrade:aColsFieldByName("C6_QTDVEN",,n,nColuna) ))
		Help(" ",1,"A410LIB")
		lRetorno := .F.
	EndIf
	If ( lRetorno .And. xConteudo > (oGrade:aColsFieldByName("C6_QTDVEN",,n,nColuna)  - oGrade:aColsFieldByName("C6_QTDENT",,n,nColuna) ) )
		HELP(" ",1,"A440QTDL")
		lRetorno := .F.
	EndIf
EndIf
	
SGA->(dbSetOrder(1))
		                                                                                          
If lRetorno .And. oGrade:cCpo == "C6_QTDVEN"
	If &(ReadVar()) > 0
		//Retorna aHeader, aCols e n para chamada da SeleOpc
		aHeadBkp := aClone(aHeader)
		aColsBkp := aClone(aCols)
		nNBkp	 := n
		aHeader  := aClone(oGrade:aHeadAux)
		aCols	 := aClone(oGrade:aColsAux)
		n		 := oGrade:nPosLinO			
			
		//���������������������������������������������Ŀ
		//� Tratamento diferencial de precos para os    �
		//� opcionais do produto: subtrai para caso	    �
		//� o opcional seja trocado.					�
		//�����������������������������������������������
		If lGrdMult .And. At(M->C5_TIPO,"CIP") == 0 .And. !Empty(cOpcMark)
			nGrdPrc := aScan(oGrade:aBkpMult[1],{|x| ValType(x) # "C" .And. AllTrim(x[2]) == StrTran(ReadVar(),"M->","") .And. AllTrim(x[11]) == "C6_PRCVEN"})
			nTotPrc := aScan(oGrade:aSumCpos,{|x| AllTrim(x[1]) == "C6_PRCVEN"})
			While !Empty(cOpcMark)
				cOpc     := SubStr(cOpcMark,1,At("/",cOpcMark)-1)
				cOpcMark := SubStr(cOpcMark,At("/",cOpcMark)+1)
				If SGA->(dbSeek(xFilial("SGA")+cOpc))
					nAcrePrc += SGA->GA_PRCVEN
				EndIf
			End
			If !Empty(nAcrePrc)
				oGrade:aSumCpos[nTotPrc,2] -= Min(nAcrePrc,oGrade:aBkpMult[2,nNBkp,nGrdPrc])
				oGrade:aBkpMult[2,nNBkp,nGrdPrc] -= Min(nAcrePrc,oGrade:aBkpMult[2,nNBkp,nGrdPrc])
			EndIf
		EndIf
			
		cOpcMark := oGrade:aColsGrade[oGrade:nPosLinO,nNBkp,nColuna,oGrade:GetFieldGrdPos("C6_OPC")]
		lRetorno := SeleOpc(2,"MATA410",cProdGrd,,,cOpcMark,"M->C6_PRODUTO",,xConteudo,aCols[oGrade:nPosLinO,nPEntreg])
		n		 := nNBkp
			
		//���������������������������������������������Ŀ
		//� Tratamento diferencial de precos para os    �
		//� opcionais do produto: se cancelou a tela    �
		//� retorna o preco diferencial do opcional.	�
		//�����������������������������������������������
		If lGrdMult .And. !lRetorno
			oGrade:aBkpMult[2,nNBkp,nGrdPrc] += nAcrePrc
			oGrade:aSumCpos[nTotPrc,2] += nAcrePrc
		EndIf
				
		//������������������������������������������������������������������������Ŀ
		//� Adiciona o opcional do produto no aCols                                �
		//��������������������������������������������������������������������������
		If !Empty(aCols[oGrade:nPosLinO,nPOpc])
			oGrade:aColsGrade[oGrade:nPosLinO][n][nColuna][oGrade:GetFieldGrdPos("C6_OPC")] := aCols[oGrade:nPosLinO,nPOpc]
			aCols[oGrade:nPosLinO,nPOpc] := ""
		EndIf
			
		aHeader	 := aClone(aHeadBkp)
		aCols	 := aClone(aColsBkp)
	Else
		oGrade:aColsGrade[oGrade:nPosLinO,n,nColuna,oGrade:GetFieldGrdPos("C6_OPC")] := ""
	EndIf
EndIf
	
If lRetorno .And. oGrade:cCpo == "C6_PRCVEN"
	//���������������������������������������������Ŀ
	//� Aqui � efetuado o tratamento diferencial de �
	//� Precos para os Opcionais do Produto.        �
	//�����������������������������������������������
	If lGrdMult .And. At(M->C5_TIPO,"CIP") == 0 .And. !Empty(cOpcMark) .And. aCols[n,nColuna] # &(ReadVar())
		While !Empty(cOpcMark)
			cOpc     := SubStr(cOpcMark,1,At("/",cOpcMark)-1)
			cOpcMark := SubStr(cOpcMark,At("/",cOpcMark)+1)
			If SGA->(dbSeek(xFilial("SGA")+cOpc))
				nAcrePrc += SGA->GA_PRCVEN
			EndIf
		End
		If !Empty(nAcrePrc)
			lRetorno := ProcName(2) == "REPLICAITENS" .Or. Aviso(STR0014,STR0174 +AllTrim(Transform(nAcrePrc,PesqPict("SC6","C6_PRCVEN"))) +".",{"OK",STR0175},2,STR0012) == 1 //Conforme opcionais selecionados para este item, o pre�o unit�rio sofrer� acr�scimo de ###
			If lRetorno
				&(ReadVar()) += nAcrePrc
			EndIf
		EndIf
	EndIf
EndIf

If lRetorno .And. oGrade:cCpo == "C6_BLQ"
	If Empty(oGrade:aColsFieldByName("C6_QTDVEN",,n,nColuna))
		Aviso(STR0014,STR0169,{"Ok"}) // Este item nao teve quantidade informada
		lRetorno := .F.
	EndIf

	If lRetorno
		lRetorno := Empty(xConteudo) .Or. ExistCpo("SX5","F1"+xConteudo)
	EndIf

	If lRetorno
		oGrade:ZeraGrade("C6_QTDLIB",oGrade:nPosLinO)
	EndIf
EndIf
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410FmTOk � Autor �Henry Fila             � Data �23.08.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da TudoOk da Getdados das formas de pagamento     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se todos os itens sao validos                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao da TudoOk ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Materiais/Distribuicao/Logistica                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M410FmTok()

Local lRet     := .T.
Local nX       := 0
Local nPercent := 0
Local nPosPer  := Ascan(aHeader,{|x| Alltrim(x[2]) == "CV_RATFOR"})
Local lValida  := .F.

For nX := 1 to Len(aCols)
	If !aCols[nX][Len(aHeader)+1]
		nPercent += aCols[nX][nPosPer]
		lValida  := .T.
	Endif
Next nX
If nPercent <> 100 .And. lValida
	Help(" ",1,"M410FRATEI")
	lRet := .F.
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410FmLOk � Autor �Henry Fila             � Data �23.08.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Linha Ok da Getdados das formas de pagamento   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a linha e valida                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar a validacao da linhaOk���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Materiais/Distribuicao/Logistica                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M410FmLok()

Local lRet     := .T.
Local nX       := 0
Local nPosFor  := Ascan(aHeader,{|x| Alltrim(x[2]) == "CV_FORMAPG"})

If !aCols[n][Len(aHeader)+1]
	For nX := 1 to Len(aCols)
		If !aCols[nX][Len(aHeader)+1] .AND. n <> nX .AND. aCols[nX][nPosFor] == aCols[n][nPosFor]
			Help(" ",1,"M410FORMA")
			lRet := .F.
		Endif
	Next nX
EndIf       
Return(lRet)                

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410DelOk � Autor �Rodrigo de A. Sartorio � Data �21/08/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia geral dos itens de Pedidos de Venda antes da  ���
���          � exclusao.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function A410DelOk()

Local lRet    := .T.
Local z       := 0
Local lAtuSGJ := SuperGetMV("MV_PVCOMOP",.F.,.F.) 
Local lCanDel := SuperGetMv("MV_DELPVOP",.F.,.T.)

//������������������������������������������������������Ŀ
//� Trata se exclui ou nao itens que geraram OPs         �
//��������������������������������������������������������
//������������������������������������������������������Ŀ
//� Estrutura do Array aOPs :                            �
//� aOPs[z,1] := Item do Pedido de Vendas                �
//� aOPs[z,2] := Produto do Pedido de Vendas             �
//� aOPs[z,3] := No. da OP gerada para o PV              �
//� aOPs[z,4] := Item da OP gerada para o PV             �
//� aOPs[z,5] := No. da SC gerada para o PV              �
//� aOPs[z,6] := Item da SC gerada para o PV             �
//��������������������������������������������������������
If Type("l410Auto") == "U" .Or. !l410Auto
	For z:=1 to Len(aOps)
		If lCanDel
		    If ValType(aOps[z,5])=="C" .And. !Empty(aOps[z,5]) .And. !Empty(aOps[z,6])
	    		lRet:=(Aviso(OemToAnsi(STR0014),STR0027+aOps[z,1]+" - "+aOps[z,2]+ " " + OemToAnsi(STR0108)+ " : " + aOps[z,5]+"/"+aOps[z,6]+"."+STR0029,{STR0030,STR0031}) == 1) //"Aten��o"###"O item "###" gerou a Solicitacao de Compras "###"Confirma Exclusao ?"###"Sim"###"Nao"
			ElseIf lAtuSGJ
				Aviso(OemToAnsi(STR0014),STR0060,{STR0040})
				lRet := .F.
	    	Else
				lRet:=(Aviso(OemToAnsi(STR0014),STR0027+aOps[z,1]+" - "+aOps[z,2]+STR0028+aOps[z,3]+"/"+aOps[z,4]+"."+STR0029,{STR0030,STR0031}) == 1) //"Aten��o"###"O item "###" gerou a Ordem de Producao "###"Confirma Exclusao ?"###"Sim"###"Nao"
			EndIf
			If !lRet
				Exit
			EndIf
		Else
			Aviso(OemToAnsi(STR0014),STR0060,{STR0040})
			lRet := .F.
			Exit
		Endif
	Next z
Else
	If !lCanDel .And. Len(aOps) > 0
	 	Help(�"",�1,�STR0014, ,STR0060,2)
		lRet := .F.
	EndIf
EndIf
//Valida��es referentes � integra��o do OMS com o Cockpit Log�stico Neolog
If  lRet .And. SuperGetMV("MV_CPLINT",.F.,"2") == "1" .And. FindFunction('OMSCPLVlPd')
	lRet := OMSCPLVlPd(1,SC5->C5_NUM,aHeader,aCols)
EndIf
Return lRet      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mta410Vis � Autor � Marco Bianchi         � Data � 01/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada a partir da FillGetdados para validar cada ���
���          �registro da tabela. Se retornar .T. FILLGETDADOS considera  ���
���          �o registro, se .F. despreza o registro.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MColsVis()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mta410Vis(cArqQry,nTotPed,nTotDes,lGrade)

Local lRet      := .T.
Local nTamaCols := Len(aCols)
Local nPosItem  := GDFieldPos("C6_ITEM")
Local nPosQtd   := GDFieldPos("C6_QTDVEN")
Local nPosQtd2  := GDFieldPos("C6_UNSVEN")
Local nPosVlr   := GDFieldPos("C6_VALOR")
Local nPosSld   := GDFieldPos("C6_SLDALIB")
Local nPosDesc  := GDFieldPos("C6_VALDESC")
Local lCriaCols := .F.		// Nao permitir que a funcao A410Grade crie o aCols
Local lGrdMult  :="MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
      
//������������������������������������������������������Ŀ
//� Verifica se este item foi digitada atraves de uma    �
//� grade, se for junta todos os itens da grade em uma   �
//� referencia , abrindo os itens so quando teclar enter �
//� na quantidade                                        �
//��������������������������������������������������������
If !lGrdMult .And. (cArqQry)->C6_GRADE == "S" .And. lGrade
	a410Grade(.F.,,cArqQry,.T.,lCriaCols)   
	If ( nTamAcols==0 .Or. aCols[nTamAcols][nPosItem] <> (cArqQry)->C6_ITEM )
		lRet := .T.	
	Else
		lRet := .F.	
		aCols[nTamAcols][nPosQtd]  += (cArqQry)->C6_QTDVEN
		aCols[nTamAcols][nPosQtd2] += (cArqQry)->C6_UNSVEN
		If ( nPosDesc > 0 )
			aCols[nTamAcols][nPosDesc] += (cArqQry)->C6_VALDESC
		Endif
		If ( nPosSld > 0 )
			aCols[nTamAcols][nPosSld] += Ma440SaLib()
		EndIf
		aCols[nTamAcols][nPosVlr] += (cArqQry)->C6_VALOR
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Efetua a Somatoria do Rodape                                            �
//��������������������������������������������������������������������������
nTotPed	+= (cArqQry)->C6_VALOR
If ( (cArqQry)->C6_PRUNIT = 0 )
	nTotDes	+= (cArqQry)->C6_VALDESC
Else
	If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
		nTotDes += Max(0, (cArqQry)->C6_VALDESC)
	Else	
		nTotDes += Max(0, A410Arred(((cArqQry)->C6_PRUNIT*(cArqQry)->C6_QTDVEN),"C6_VALOR")-A410Arred(((cArqQry)->C6_PRCVEN*(cArqQry)->C6_QTDVEN),"C6_VALOR"))
	EndIf
EndIf
Return(lRet)           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mta410Alt � Autor � Marco Bianchi         � Data � 29/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada a partir da FillGetdados para validar cada ���
���          �registro da tabela. Se retornar .T. FILLGETDADOS considera  ���
���          �o registro, se .F. despreza o registro.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MColsAlt()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mta410Alt(cArqQry,nTotalPed,nTotalDes,lGrade,lBloqueio,lNaoFatur,lContrat,aRegSC6)

Local lRet      := .T.           
Local lCriaCols := .F.		// Nao permitir que a funcao A410Grade crie o aCols
Local nTamaCols := Len(aCols)
Local nPosItem  := GDFieldPos("C6_ITEM")
Local nPosQtd   := GDFieldPos("C6_QTDVEN")
Local nPosQtd2  := GDFieldPos("C6_UNSVEN")
Local nPosVlr   := GDFieldPos("C6_VALOR")
Local nPosSld   := GDFieldPos("C6_SLDALIB")
Local nPosDesc  := GDFieldPos("C6_VALDESC")
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
           
If !(("R"$Alltrim((cArqQry)->C6_BLQ)).And.(SuperGetMv("MV_RSDOFAT")=="N"))
	lBloqueio := .F.
EndIf
If !"R"$Alltrim((cArqQry)->C6_BLQ) .Or. SuperGetMv("MV_RSDOFAT")=="S"
	If SC5->C5_TIPO$"CIP"
		If Empty((cArqQry)->C6_NOTA)
			lNaoFatur := .T.
		EndIf
	Else
	    dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+(cArqQry)->C6_TES)
		If ( (cArqQry)->C6_QTDENT < (cArqQry)->C6_QTDVEN .AND. SF4->F4_QTDZERO <> "1" ) .OR. ;
	   		((cArqQry)->C6_QTDENT == (cArqQry)->C6_QTDVEN .AND. SF4->F4_QTDZERO == "1" .AND. Empty((cArqQry)->C6_NOTA))
			lNaoFatur := .T.
		EndIf
	EndIf
EndIf
If !Empty((cArqQry)->C6_CONTRAT) .And. !lContrat
	dbSelectArea("ADB")
	dbSetOrder(1)
	If MsSeek(xFilial("ADB")+(cArqQry)->C6_CONTRAT+SC6->C6_ITEMCON)
		If ADB->ADB_QTDEMP > 0 .And. ADB->ADB_PEDCOB == (cArqQry)->C6_NUM
			lContrat := .T.
		EndIf
	EndIf
	dbSelectArea(cArqQry)
EndIf

//������������������������������������������������������Ŀ
//� Verifica se este item foi digitada atraves de uma    �
//� grade, se for junta todos os itens da grade em uma   �
//� referencia , abrindo os itens so quando teclar enter �
//� na quantidade                                        �
//��������������������������������������������������������
If !lGrdMult .And. (cArqQry)->C6_GRADE == "S" .And. lGrade
	a410Grade(.T.,,cArqQry,.T.,lCriaCols)
	If ( nTamAcols==0 .Or. aCols[nTamAcols][nPosItem] <> (cArqQry)->C6_ITEM )
		lRet := .T.	
	Else
		lRet := .F.	
		aCols[nTamAcols][nPosQtd]  += (cArqQry)->C6_QTDVEN
		aCols[nTamAcols][nPosQtd2] += (cArqQry)->C6_UNSVEN
		If ( nPosDesc > 0 )
			aCols[nTamAcols][nPosDesc] += (cArqQry)->C6_VALDESC
		Endif
		If ( nPosSld > 0 )
			aCols[nTamAcols][nPosSld] += Ma440SaLib()
		EndIf
		aCols[nTamAcols][nPosVlr] += (cArqQry)->C6_VALOR
	EndIf
EndIf

nTotalPed += (cArqQry)->C6_VALOR
If ( (cArqQry)->C6_PRUNIT = 0 )
	nTotalDes += (cArqQry)->C6_VALDESC
Else
	If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
		nTotalDes += (cArqQry)->C6_VALDESC
	Else
		nTotalDes += A410Arred(((cArqQry)->C6_PRUNIT*(cArqQry)->C6_QTDVEN),"C6_VALOR")-A410Arred(((cArqQry)->C6_PRCVEN*(cArqQry)->C6_QTDVEN),"C6_VALOR")
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Guarda os registros do SC6 para posterior gravacao                      �
//��������������������������������������������������������������������������
aAdd(aRegSC6,If((cArqQry)->(ColumnPos("SC6RECNO")) > 0,(cArqQry)->SC6RECNO,(cArqQry)->(RecNo())))
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mta410Del � Autor � Marco Bianchi         � Data � 30/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada a partir da FillGetdados para validar cada ���
���          �registro da tabela. Se retornar .T. FILLGETDADOS considera  ���
���          �o registro, se .F. despreza o registro.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MColsDel()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mta410Del(cArqQry,nTotalPed,nTotalDes,lGrade,aRegSC6,lPedTLMK,lLiber,lFaturado,lContrat)

Local lRet      := .T.
Local lCriaCols := .F.		// Nao permitir que a funcao A410Grade crie o aCols
Local nTamaCols :=Len(aCols)
Local nPosItem  := GDFieldPos("C6_ITEM")
Local nPosQtd   := GDFieldPos("C6_QTDVEN")
Local nPosQtd2  := GDFieldPos("C6_UNSVEN")
Local nPosVlr   := GDFieldPos("C6_VALOR")
Local nPosSld   := GDFieldPos("C6_SLDALIB")
Local nPosDesc  := GDFieldPos("C6_VALDESC")
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

//������������������������������������������������������������������������Ŀ
//� Verifica se algum item foi criado no TLMK                              �
//��������������������������������������������������������������������������
If Left( ( cArqQry )->C6_PEDCLI, 3 ) == "TMK"
	lPedTLMK := .T.
EndIf

If ( (cArqQry)->C6_QTDEMP > 0 )
	lLiber := .T.
EndIf

If AllTrim(SC5->C5_ORIGEM) == "MSGEAI" .AND. !Empty(SC5->C5_NOTA)
	lFaturado := .T.
Endif

If nModulo == 12 .AND. SuperGetMv("MV_LJVFNFS",,.F.) .AND. AllTrim(SuperGetMv("MV_LJVFSER",,"")) == AllTrim(SC5->C5_SERIE)
	lFaturado := .F. 
Else
	If ( (cArqQry)->C6_QTDENT > 0 ) .Or. ( SC5->C5_TIPO $ "CIP" .And. !Empty((cArqQry)->C6_NOTA) )
		lFaturado  :=  .T.
	EndIf
EndIf

If !Empty((cArqQry)->C6_CONTRAT) .And. !lContrat
	dbSelectArea("ADB")
	dbSetOrder(1)
	If MsSeek(xFilial("ADB")+(cArqQry)->C6_CONTRAT+SC6->C6_ITEMCON)
		If ADB->ADB_QTDEMP > 0 .And. ADB->ADB_PEDCOB == (cArqQry)->C6_NUM
			lContrat := .T.
		EndIf
	EndIf
	dbSelectArea(cArqQry)
EndIf

//������������������������������������������������������Ŀ
//� Verifica se este item gerou OP/SC, caso tenha gerado �
//� inclui no array aOPs para perguntar se exclui ou nao �
//��������������������������������������������������������
If (cArqQry)->C6_OP $ "01/03"
	aAdd(aOPs,{(cArqQry)->C6_ITEM,Alltrim((cArqQry)->C6_PRODUTO),(cArqQry)->C6_NUMOP,(cArqQry)->C6_ITEMOP, '',''})
	If !Empty((cArqQry)->C6_NUMSC)
		aOPs[Len(aOPs)][5] := (cArqQry)->C6_NUMSC
		aOPs[Len(aOPs)][6] := (cArqQry)->C6_ITEMSC
	EndIf
EndIf

//������������������������������������������������������Ŀ
//� Verifica se este item foi digitada atraves de uma    �
//� grade, se for junta todos os itens da grade em uma   �
//� referencia , abrindo os itens so quando teclar enter �
//� na quantidade                                        �
//��������������������������������������������������������
If !lGrdMult .And. (cArqQry)->C6_GRADE == "S" .And. lGrade
	a410Grade(.T.,,cArqQry,.T.,lCriaCols)
	If ( nTamAcols==0 .Or. aCols[nTamAcols][nPosItem] <> (cArqQry)->C6_ITEM )
		lRet := .T.	
	Else
		lRet := .F.	
		aCols[nTamAcols][nPosQtd]  += (cArqQry)->C6_QTDVEN
		aCols[nTamAcols][nPosQtd2] += (cArqQry)->C6_UNSVEN
		If ( nPosDesc > 0 )
			aCols[nTamAcols][nPosDesc] += (cArqQry)->C6_VALDESC
		Endif
		If ( nPosSld > 0 )
			aCols[nTamAcols][nPosSld] += Ma440SaLib()
		EndIf
		aCols[nTamAcols][nPosVlr] += (cArqQry)->C6_VALOR
	EndIf
EndIf

nTotalPed += (cArqQry)->C6_VALOR
If ( (cArqQry)->C6_PRUNIT = 0 )
	nTotalDes += (cArqQry)->C6_VALDESC
Else
	If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
		nTotalDes += (cArqQry)->C6_VALDESC
	Else
		nTotalDes += A410Arred(((cArqQry)->C6_PRUNIT*(cArqQry)->C6_QTDVEN),"C6_VALOR")-A410Arred(((cArqQry)->C6_PRCVEN*(cArqQry)->C6_QTDVEN),"C6_VALOR")
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Guarda os registros do SC6 para posterior gravacao                      �
//��������������������������������������������������������������������������
aAdd(aRegSC6,If((cArqQry)->(ColumnPos("SC6RECNO")) > 0,(cArqQry)->SC6RECNO,(cArqQry)->(RecNo())))

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mta410Cop � Autor � Marco Bianchi         � Data � 30/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada a partir da FillGetdados para validar cada ���
���          �registro da tabela. Se retornar .T. FILLGETDADOS considera  ���
���          �o registro, se .F. despreza o registro.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MColsCop()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mta410Cop(cArqQry,nTotalPed,nTotalDes,lGrade, lCopia)

Local lRet      := .T.
Local lCriaCols := .F.		// Nao permitir que a funcao A410Grade crie o aCols
Local nTamaCols :=Len(aCols)
Local nPosItem  := GDFieldPos("C6_ITEM")
Local nPosQtd   := GDFieldPos("C6_QTDVEN")
Local nPosQtd2  := GDFieldPos("C6_UNSVEN")
Local nPosVlr   := GDFieldPos("C6_VALOR")
Local nPosSld   := GDFieldPos("C6_SLDALIB")
Local nPosDesc  := GDFieldPos("C6_VALDESC")
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
                         
//������������������������������������������������������Ŀ
//� Verifica se este item foi digitada atraves de uma    �
//� grade, se for junta todos os itens da grade em uma   �
//� referencia , abrindo os itens so quando teclar enter �
//� na quantidade                                        �
//��������������������������������������������������������
If !lGrdMult .And. (cArqQry)->C6_GRADE == "S" .And. lGrade
	a410Grade(.T.,,cArqQry,.F.,lCriaCols)
	If ( nTamAcols==0 .Or. aCols[nTamAcols][nPosItem] <> (cArqQry)->C6_ITEM )
		lRet := .T.	
	Else
		lRet := .F.	
		aCols[nTamAcols][nPosQtd]  += (cArqQry)->C6_QTDVEN
		aCols[nTamAcols][nPosQtd2] += (cArqQry)->C6_UNSVEN
		If ( nPosDesc > 0 )
			aCols[nTamAcols][nPosDesc] += (cArqQry)->C6_VALDESC
		Endif
		If ( nPosSld > 0 )
			aCols[nTamAcols][nPosSld] += Ma440SaLib()
		EndIf
		aCols[nTamAcols][nPosVlr] += (cArqQry)->C6_VALOR
	EndIf
EndIf
	
nTotalPed += (cArqQry)->C6_VALOR
If ( (cArqQry)->C6_PRUNIT = 0 )
	nTotalDes += (cArqQry)->C6_VALDESC
Else
	If !Empty(SC5->C5_MDCONTR) .Or. !Empty(SC5->C5_MDNUMED)
		nTotalDes += (cArqQry)->C6_VALDESC
	Else
		nTotalDes += A410Arred(((cArqQry)->C6_PRUNIT*(cArqQry)->C6_QTDVEN),"C6_VALOR")-A410Arred(((cArqQry)->C6_PRCVEN*(cArqQry)->C6_QTDVEN),"C6_VALOR")
	EndIf
EndIf

//se for copia e o produto esta bloqueado ignora
If (lCopia)
	dbSelectArea("SB1")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SB1")+(cArqQry)->C6_PRODUTO) ) .AND. (SB1->B1_MSBLQL == "1")
		lRet := .F.
		If aScan( __aMCPdCpy, {|x| x == (cArqQry)->C6_PRODUTO }) == 0
			MsgAlert(STR0212 + AllTrim((cArqQry)->C6_PRODUTO) + STR0213)
			aAdd( __aMCPdCpy, (cArqQry)->C6_PRODUTO )
		EndIf
	EndIf
EndIf

Return lRet

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Program   �MA521VerSC6 � Rev.  � Vendas Clientes       � Data � 26/12/2009 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que verifica se existe amarracao no Pedido de venda com  ��� 
���          �Pedido de Compra, Caso exista e se jah foi feito recebimento de ���
���          �de alguma quantidade no pedido de compra o Pedido de venda nao  ���    
���          �podera ser cancelado.                                           ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Logico .T. para cancelar - .F. nao Cancela                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�PARAM01 - Filial da nota de Saida (SF2)                         ���  
���          �PARAM02 - Numero do Documento                                   ���  
���          �PARAM03 - Serie do Documento                                    ���  
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function A410VerISC6(cFilDoc,cNumDoc,aCols,aHeader)

Local lRet     := .T.
Local aArea    := GetArea()   
Local cFilPCom := ""        // Filial do Pedido de Compras 
Local cPedCom  := ""        // Numero do Pedido de Compras
Local cProd    := ""        // Cod do Produto 
Local cItemPC  := ""        // Item do Pedido de Compra
Local nItem    := aScan( aHeader,{|x| Trim(x[2]) == "C6_ITEM"    } )   
Local cNumC7   := ""        // Guarda o num para nao correr a Tabela Inteira.                               

Default cFilDoc   := ""
Default cNumDoc   := ""
Default aCols     := {}

If !Empty(cFilDoc) .AND. !Empty(cNumDoc) .AND. Len(aCols) > 0 
	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(cFilDoc + cNumDoc + aCols[1][nItem] )
		cFilPCom  := SC6->C6_FILPED	
		cProd     := SC6->C6_PRODUTO
		cPedCom   := SC6->C6_PEDCOM
		cItemPC   := SC6->C6_ITPC
		If Empty (cFilPCom)
			lRet := .T.
		Else
			DbSelectArea("SC7")
			DbSetOrder(4)
			If DbSeek(cFilPCom + cProd + cPedCom + cItemPC ) 
				cNumC7 := SC7->C7_NUM    
				While !Eof() .And. cFilPCom == C7_FILIAL .And. cNumC7 == SC7->C7_NUM .And. cItemPC == SC7->C7_ITEM		
					lRet := If(SC7->C7_QUJE > 0, .F., .T. )
					If !lRet
					   Exit
					EndIf
					SC7->(DbSkip()) 
				End
			EndIf
		EndIf	
	EndIf
EndIf		

RestArea(aArea)
Return (lRet)  

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �a410RatLok � Autor � Eduardo Riera         � Data �15.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da linhaok dos itens do rateio dos itens do documen���
���          �to de entrada                                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a linha esta valida                         ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar a linhaok do rateio dos���
���          �itens do documento de entrada                                ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function a410RatLOk()

Local nPPerc    := aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_PERC"} )
Local lRetorno  := .T.
Local nX        := 0

If !aCols[N][Len(aCols[N])] .AND. aCols[N][nPPerc] == 0
	Help(" ",1,"A103PERC")
	lRetorno := .F.
EndIf

If lRetorno
	nPercRat := 0
	nPercARat:= 0
	For nX	:= 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nPercRat += aCols[nX][nPPerc]
		EndIf
	Next
	nPercARat := 100 - nPercRat
	If Type("oPercRat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
EndIf     

If lRetorno .And. ExistBlock("MRatLOk")
	lRetorno := ExecBlock("MRatLOk",.F.,.F.)
EndIf
Return(lRetorno)        

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �a410RatLok � Autor � Eduardo Riera         � Data �15.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da TudoOk dos itens do rateio dos itens do documen-���
���          �to de entrada                                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a todas as linhas estao validas             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar a tudook do rateio dos ���
���          �itens do documento de entrada                                ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function a410RatTok()

Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_PERC"} )
Local nTotal   := 0
Local nX       := 0
Local lRetorno := .T.

For nX	:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		nTotal += aCols[nX][nPPerc]
	EndIf
Next
If nTotal > 0 .And. nTotal <> 100
	Help(" ",1,"A103TOTRAT")
	lRetorno := .F.
EndIf
Return(lRetorno)       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a410RatAut�Autor  �Microsiga           � Data �  06/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a410RatAut(aRateioPC) 

Local nPosCC	:= 0
Local nPosPerc	:= 0
Local nPosConta	:= 0
Local nPosItem	:= 0
Local nPosClVl	:= 0
Local nTam1		:= 0
Local nTam2		:= 0
Local nTotal	:= 0
Local nX		:= 0
Local nY		:= 0
Local cCCusto		:= ""
Local cConta		:= ""
Local cItem	    	:= ""
Local cClVl  		:= ""
Local cTodosCCusto	:= ""
Local cFilCTT		:= ""
Local lNaoAchouCCusto:= .F.
Local lError100Perc	:=  .F.
Local lContinua		:=  .T.
Local lErrorConta   :=  .F.
Local lErrorItem    :=  .F.
Local lErrorClVl    :=  .F.

Default aRateioPC	:=  {}

/*/
If (Type("l410Auto") <> 'U' .And. l410Auto)
Endif
/*/

//����������������������������������������������������������������������Ŀ
//� No modo Automatico checa Rateio e Adiantamento                       �
//�    1 - A soma dos percentuais de rateios dos C.Custo eh igual a 100% �
//�    2 - Cada C.Custo rateado existe na tabela SCC                     �
//������������������������������������������������������������������������	

//Rateio por Centro de Custo

If len(aRateioPC) > 0
    // vetor aRatCTBPC
	// cada elemento possui um vetor de 2 elementos
	//   elemento 1 - Nro do item do pedido de compra
	//   elemento 2 - vetor contendo todos os campos de cada rateio
    //
    // 1o elemento 
    // 1o elemento, 2O elemento { '01', VETOR }
    //              (1o elemento RATEIO1, 2o elemento RATEIO 2, 3o elemento RATEIO 3) VETOR DE RATEIOS
    //              (1o elemento CAMPO1, 2o elemento CAMPO2, 30 elemento CAMPO3, N elemento CAMPO N) VETOR DE CAMPOS
	//              (1o elemento Nome Campo, 2 elemento CONTEUDO, 3 elemento .T.)  VETOR DE 3 ELEMENTOS
	//

	//Ache a posicao do vetor contendo o nome do campo = "CH_PERC" no 1o elemento [1][2][1] / Pedido de Venda
	nPosPerc  		:= AScan(aRateioPC[1][2][1], { |x| Alltrim(x[1]) =="AGG_PERC"} )
	nPosCC			:= AScan(aRateioPC[1][2][1], { |x| Alltrim(x[1]) =="AGG_CC"  } )
	nPosConta		:= AScan(aRateioPC[1][2][1], { |x| Alltrim(x[1]) =="AGG_CONTA"  } )
	nPosItem		:= AScan(aRateioPC[1][2][1], { |x| Alltrim(x[1]) =="AGG_ITEMCT"  } )
	nPosClVl		:= AScan(aRateioPC[1][2][1], { |x| Alltrim(x[1]) =="AGG_CLVL"  } )

	lNaoAchouCCusto := .F.  // 1- Tratamento Centro de Custo nao cadastrado
	lError100Perc   := .F.  // 2- Tratamento Soma dos percentuais diferente de 100%
	lErrorDados		:= .F.	//  - Erro identificado  
	lErrorConta     := .F.  // Conta Cont�bil n�o existe
	lErrorItem    	:= .F.  // Item Cont�bil n�o existe
	lErrorClVl    	:= .F.  // Classe de Valor n�o existe

	If nPosPerc > 0 .And. nPosCC > 0

		dbSelectArea("CTT")
		dbSetOrder(1)
		cFilCTT		:= xFilial("CTT")
		nTam1		:= Len(aRatCTBPC)
		For nX := 1 To nTam1

			cTodosCCusto:= '/'

			nTotal := 0
			nTam2  := Len( aRateioPC[nX][2] )
			For nY := 1 to nTam2

				//Soma de percentuais
				nTotal  += aRateioPC[nX][2][nY][nPosPerc][2]
	            cCCusto := aRateioPC[nX][2][nY][nPosCC  ][2]
				cConta  := aRateioPC[nX][2][nY][nPosConta][2]
				cItem   := aRateioPC[nX][2][nY][nPosItem][2]
				cClVl   := aRateioPC[nX][2][nY][nPosClVl][2]
				
				If !Empty(cCCusto)
					If (lNaoAchouCCusto := !MsSeek(cFilCTT + cCCusto) )
						lErrorDados := .T.
						Exit
					Endif
					cTodosCCusto += cCCusto + '/'
				Endif	
						
				If !Empty(cConta) .And. !(Ctb105Cta(cConta))
					lErrorConta := .T.
					Exit
				Endif			
				If !Empty(cItem) .And. !(Ctb105Item(cItem))
					lErrorItem := .T.
					Exit
				Endif
				If !Empty(cClVl) .And. !(Ctb105ClVl(cClVl))
					lErrorClVl := .T.
					Exit
				Endif
				
			Next

			If lErrorDados
				Exit
			Endif

		    If nTotal > 0 .And. nTotal <> 100
				lError100Perc := .T.
				Exit
			Endif
		Next
	Endif
    
    //Inconsistencias - Observacao
    //Se o CCusto nao for encontrado, a soma do percental eh descontinuada
	//
	Do case
	   case nPosPerc = 0  .Or. nPosCC = 0
			Help(' ',1,STR0374)	//"Erro na estrutura do vetor de rateio. Procura n�o encontrada!"
			lContinua := .F.
	   case lNaoAchouCCusto
			Help(' ',1,STR0375)	//"C�digo Centro Custo inexistente."
			lContinua := .F.
	   case lError100Perc
			Help(' ',1,'A103TOTRAT')
			lContinua := .F.
	   case lErrorConta
			Help(' ',1,'NOCONTAC')
			lContinua := .F.
	   case lErrorItem
			Help(' ',1,'NOITEM')
			lContinua := .F.
	   case lErrorClVl
			Help(' ',1,'NOCLVL')
			lContinua := .F.
	Endcase
Endif
Return lContinua        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ma410VldQEK� Autor � Cleber Souza         � Data �19/09/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se na devolucao a Nota Original ainda naum foi    ���
���          � liberada do CQ.                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := Ma410VldUs( ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6 ) ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Validacao                                         ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Ma410VldQEK( cForn,cLoja,cNfOri,cSerOri,cItemOri,cProdOri)

Local lRetorna   := .t.
Local aSaldoQEK  := {}
Local aArea      := GetArea()
Local lLibDev    := GetMV("MV_QLIBDEV",.T.,.F.)

//������������������������������������������������������Ŀ
//� verifica se esta liberado pelo Quality.              �
//��������������������������������������������������������

//Pesquisa NF Original
SD1->(dbSetOrder(1))
SD1->(dbSeek(xFilial("SD1")+cNfOri+cSerOri+cForn+cLoja+cProdOri+cItemOri))
	
//������������������������������������������������������Ŀ
//� verifica se tipo de Nota mais TES saum usados no QIE.�
//��������������������������������������������������������
If !QIETipoNf(SD1->D1_TIPO,SD1->D1_TES)
	
	//Posiciona na Entrada do QEK
	dbSelectArea("QEK")
	dbSetOrder(10)
	If dbSeek(xFilial("QEK")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ITEM+SD1->D1_TIPO+SD1->D1_NUMSEQ)
		If QEK->QEK_SITENT $ ("1,0")
			Help(" ",1,"A410SIQEK") //"Ainda nao foi digitado o laudo para esta entrada na Inspecao de Entrada."
			lRetorna := .f.
		Else
			If !lLibDev
				aSaldoQEK := A175CalcQt(SD1->D1_NUMcq, SD1->D1_COD, SD1->D1_LOCAL)
				If aSaldoQEK[6] > 0
					Help(" ",1,"A410SLQEK") //"Ainda existe saldo dessa entrada na Qualidade para ser liberada."
					lRetorna := .f.
				EndIF
			EndIF
		EndIF
	EndIF
EndIF

RestArea(aArea)
Return lRetorna     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410Produt� Autor �Eduardo Riera          � Data � 20.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua a Valida��o do Codigo do Produto e Inicializa as     ���
���          �variaveis do acols.                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Se o Produto eh valido                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do Produto                                    ���
���          �ExpL1: Codigo de Barra                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410Produto(cProduto,lCB)

Local aDadosCfo     := {}

Local lRetorno		:= .T.
Local lContinua		:= .T.
Local lReferencia		:= .F.
Local lDescSubst		:= .F.
Local lGrade			:= MaGrade()
Local lTabCli       	:= (SuperGetMv("MV_TABCENT",.F.,"2") == "1")
Local lGrdMult	  	:= "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPGrade			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_GRADE"})
Local nPItem			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPItemGrd		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMGRD"})
Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPOpcional		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPC"})
Local nPDescon		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPContrat     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItemCon     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPLoteCtl     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPEndPad      	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENDPAD"})
Local nPLocal       	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPTes         	:= GdFieldPos("C6_TES")
Local nITEMED 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEMED"})
Local nCntFor     	:= 0   
Local nPosTes1 		:= 0 
Local lAtuPreco		:= .T.

Local nPrcTab			:= 0

Local cProdRef		:= ""
Local cCFOP			:= Space(Len(SC6->C6_CF))
Local cDescricao		:= ""                                      
Local cCliTab     	:= ""
Local cLojaTab    	:= ""

Local cFieldFor		:= "" 
Local lContrato     := Nil

// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec   		:= SuperGetMV("MV_PRCDEC",,.F.)  

If cPaisLoc == "BRA"
	lDescSubst			:= ( IIf( Valtype( mv_par02 ) == "N", ( Iif( mv_par02 == 1, .T., .F. ) ), .F. ) )  //mv_par02 parametro para deduzir ou nao a Subst. Trib.	
EndIf

mv_par01 := If(ValType(mv_par01)==NIL.or.ValType(mv_par01)!="N",1,mv_par01)
mv_par02 := If(ValType(mv_par02)==NIL.or.ValType(mv_par02)!="N",1,mv_par02)

DEFAULT lCb	:= .F.

aColsCCust := aClone(aCols)

//������������������������������������������������������������������������Ŀ
//�Compatibiliza a Entrada Via Codigo de Barra com a Entrada via getdados  �
//��������������������������������������������������������������������������
If ( lCB )
	SB1->( DBSetOrder( 1 ) )
	If SB1->( MsSeek(xFilial("SB1")+Substr(aCols[Len(aCols)][nPProduto],1,TamSX3("B1_COD")[1]),.F.) )
		cProduto := SB1->B1_COD
	Else
		Help(" ",1,"C6_PRODUTO")
		Return .F.
	EndIf
	n := Len(aCols)
Else
	cProduto := IIF(cProduto == Nil,&(ReadVar()),cProduto)
EndIf
//������������������������������������������������������������������������Ŀ
//�Verifica se o Produto foi Alterado                                      �
//��������������������������������������������������������������������������
If !( Type("l410Auto") != "U" .And. l410Auto )
	If ( nPOpcional > 0 )
		If ( Empty(aCols[n][nPOpcional]) )
			If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
				lContinua := .F.
			EndIf
		ElseIf ( !Empty(aCols[n][nPOpcional]) )
			If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
				lContinua := .F.
			EndIf
		EndIf
	Else
		If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
			lContinua := .F.
		EndIf
	EndIf
EndIf

cProdRef := cProduto
//������������������������������������������������������������������������Ŀ
//�Verifica se a grade esta ativa e se o produto digitado eh uma referencia�
//��������������������������������������������������������������������������
If ( lContinua .And. lGrade )
	lReferencia := MatGrdPrrf(@cProdRef)
	If ( lReferencia )
		If ( M->C5_TIPO $ "D" )
			Help(" ",1,"A410GRADEV")
			lContinua := .F.
			lRetorno	 := .T.
		EndIf
		If ( nPGrade > 0 )
			aCols[n][nPGrade] := "S"
			lReferencia := .T.
		EndIf
		aCols[n,nPItemGrd] := StrZero(1,TamSX3("C6_ITEMGRD")[1])
	Else
		If ( nPGrade > 0 )
			aCols[n][nPGrade] := "N"
		EndIf
	EndIf
	//������������������������������������������������������Ŀ
	//� Monta o AcolsGrade e o AheadGrade para este item     �
	//�������������������������������������������������������� 
	oGrade:MontaGrade(n,cProdRef,.T.,,lReferencia,.T.) 
EndIf

//������������������������������������������������������������������������Ŀ
//�Verificar se o Produto eh valido                                        �
//��������������������������������������������������������������������������
If ( lContinua )
	SB1->( DBSetOrder( 1 ) )
	If !lReferencia .And. SB1->( !MsSeek(xFilial("SB1")+cProdRef,.F.) )
		Help(" ",1,"C6_PRODUTO")
		lContinua := .F.
		lRetorno  := .F.
	Else
		If !lReferencia .And. !RegistroOk("SB1")	
			lContinua := .F.
			lRetorno  := .F.
		Endif	
	EndIf
EndIf

If INCLUI .And. !Empty(M->C5_MDCONTR) .And. !Empty(aCols[n,nITEMED]) .And. M->C6_PRODUTO # aCols[n,nPProduto]
	Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto n�o pode ter este campo alterado.
	lContinua := .F.
	lRetorno  := .F.
EndIf

//������������������������������������������������������Ŀ
//�Checar se este item do pedido nao foi faturado total -�
//�mente ou parcialmente                                 �
//��������������������������������������������������������
If ( lContinua .And. ALTERA )
	SC6->( DBSetOrder(1) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]+aCols[n][nPProduto]) )
		If ( SC6->C6_QTDENT != 0  .And. cProduto != aCols[n][nPProduto] .And. !lCB )
			Help(" ",1,"A410ITEMFT")
			lRetorno 	:= .F.
			lContinua 	:= .F.
		EndIf
	EndIf
EndIf

//������������������������������������������������������Ŀ
//�Checar se este item do pedido esta amarrado com       �
//�alguma Ordem de Producao                              �
//��������������������������������������������������������
If ( lContinua .And. ALTERA )
	SC6->( DBSetOrder(1) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]+aCols[n][nPProduto]) )

		If SC6->C6_OP $ "01#03#05"           .AND.;
		   SuperGetMV("MV_ALTPVOP") == "N"   .AND.;
		   !( !Empty(SC5->C5_PEDEXP)  .AND.;
		      SuperGetMv("MV_EECFAT") .AND.;
			  AvIntEmb() )

			If SC6->C6_OP $ "01#03"
				Help(" ",1,"A410TEMOP")
				lRetorno 	:= .F.
				lContinua 	:= .F.
			Else
				Aviso(STR0038,STR0039,{STR0040}) //"Atencao!"###"Este item foi marcado para gerar uma Ordem de Producao mas nao gerou, pois havia saldo disponivel em estoque. Este Pedido de Venda ja comprometeu o saldo necessario."###'Ok'
			EndIf

		EndIf

	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica o contrato de parceria                                         �
//��������������������������������������������������������������������������
If nPContrat > 0 .And. nPItemCon > 0
	ADB->( DBSetOrder(1) )
	If ADB->( MsSeek(xFilial("ADB")+aCols[N][nPContrat]+aCols[N][nPItemCon]) )
		If ADB->ADB_CODPRO <> M->C6_PRODUTO
			aCols[n][nPContrat] := Space(Len(aCols[n][nPContrat]))
			aCols[n][nPItemCon] := Space(Len(aCols[n][nPItemCon]))
		EndIf		
	Else
		aCols[n][nPContrat] := Space(Len(aCols[n][nPContrat]))
		aCols[n][nPItemCon] := Space(Len(aCols[n][nPItemCon]))
	EndIf
EndIf

//������������������������������������������������������Ŀ
//� Verifica os Opcionais e a Tabela de Precos           �
//��������������������������������������������������������
If ( lContinua )
	
	dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
	dbSetOrder(1)
	MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+IIf(!Empty(M->C5_LOJAENT),M->C5_LOJAENT,M->C5_LOJACLI)) 
				
	//������������������������������������������������������������������������Ŀ
	//�Posicionar o TES para calcular o CFOP                                   �
	//��������������������������������������������������������������������������
   	If !lReferencia .And. nPTes > 0 
   		If ( Type("l410Auto") != "U" .And. l410Auto .And. Type("aAutoItens[n]") !=  "U")
	       		nPosTes1 := aScan(aAutoItens[n],{|x| AllTrim(x[1])=="C6_TES"})
	   	   	If nPosTes1 > 0
	   		   aCols[n][nPTes] := aAutoItens[n][nPosTes1][2]
	   		Endif
	   		If Empty(aCols[n][nPTes])
	   			aCols[n][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
	   		Endif
	   	Else	
	   		aCols[n][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
		EndIF
	ElseIf lReferencia .And. nPTes > 0 .And. MatOrigGrd() == "SB4" 
		aCols[n][nPTes] := SB4->B4_TS
	Endif
	
	SF4->( DBSetOrder(1) )
	If SF4->( MsSeek(xFilial()+aCols[n][nPTes],.F.) )
		if cPaisLoc=="BRA"		
		 	Aadd(aDadosCfo,{"OPERNF","S"})
		 	Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
		 	Aadd(aDadosCfo,{"UFDEST",Iif(M->C5_TIPO$"DB", SA2->A2_EST,SA1->A1_EST)})
		 	Aadd(aDadosCfo,{"INSCR", If(M->C5_TIPO$"DB", SA2->A2_INSCR,SA1->A1_INSCR)})
			Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
			Aadd(aDadosCfo,{"FRETE" ,M->C5_TPFRETE})
	
			cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			
			//��������������������������������������������������������������Ŀ
			//�Atualiza CFO de devido a nao correspondencia do CFO estadual  �
			//����������������������������������������������������������������
			If Left(cCfop,4) == "6405"
				cCfop := "6404"+SubStr(cCfop,5,Len(cCfop)-4)
			Endif	
		Else
			cCfop:=SF4->F4_CF
		EndIf
	EndIf
	//������������������������������������������������������Ŀ
	//� Trazer descricao do Produto                          �
	//��������������������������������������������������������

	SA7->( DBSetOrder(1) )
	If SA7->( MsSeek(xFilial("SA7")+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT+cProdRef,.F.) ) .And. !Empty(SA7->A7_DESCCLI)
		cDescricao := SA7->A7_DESCCLI
	Else
		If ( lReferencia )   
			cDescricao := oGrade:GetDescProd(cProdRef) 
		Else
			cDescricao := SB1->B1_DESC
		EndIf
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Inicializar os campos a partir do produto digitado.                     �
	//��������������������������������������������������������������������������
	If lTabCli
		Do Case
			Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
				cCliTab   := M->C5_CLIENT
				cLojaTab  := M->C5_LOJAENT
			Case Empty(M->C5_CLIENT) 
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJAENT
			OtherWise
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJACLI
		EndCase					
	Else
		cCliTab   := M->C5_CLIENTE
		cLojaTab  := M->C5_LOJACLI
	Endif
	
	lAtuPreco := !(cPaisLoc $ "MEX|PER" .And. FunName() $ "MATA410" .And. IsInCallStack("A410Bonus"))

	For nCntFor :=1 To Len(aHeader)
		cFieldFor := AllTrim(aHeader[nCntFor][2])
		Do Case
			Case cFieldFor == "C6_PRODUTO"
				aCols[n][nPProduto]	:= cProduto
			Case cFieldFor == "C6_UM"
				If !lReferencia
					aCols[n][nCntFor] := SB1->B1_UM
				ElseIf MatOrigGrd() == "SB4"
					aCols[n][nCntFor] := SB4->B4_UM
				Else
					aCols[n][nCntFor] := SBR->BR_UM
				EndIf
			Case cFieldFor == "C6_LOCAL"
				If !lReferencia
					aCols[n][nCntFor] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
				ElseIf MatOrigGrd() == "SB4"
					aCols[n][nCntFor] := SB4->B4_LOCPAD
				Else
					aCols[n][nCntFor] := SBR->BR_LOCPAD
				EndIf
			Case cFieldFor == "C6_DESCRI"
				aCols[n][nCntFor] := PadR(cDescricao,TamSx3("C6_DESCRI")[1])
			Case cFieldFor == "C6_SEGUM"
				If !lReferencia
					aCols[n][nCntFor] := SB1->B1_SEGUM
				ElseIf MatOrigGrd() == "SB4"
				aCols[n][nCntFor] := SB4->B4_SEGUM
				EndIf
			Case cFieldFor == "C6_PRUNIT" .And. !(lReferencia .And. lGrdMult)
				// O preenchimento da variavel nPrcTab soh poderah ter valor diferente se na execucao anterior da funcao
				// A410Tabela for identificado que para o item existe um contrato de parceria. A variavel lContrato tem
				// esta informacao e que eh preenchida apos a primeira execucao da funcao A410Tabela neste loop.
				If ( (lContrato == Nil .Or. lContrato) .AND. lAtuPreco )
					nPrcTab:=A410Tabela(	cProdRef,;
											M->C5_TABELA,;
											n,;
											aCols[n][nPQtdVen],;                                   
											cCliTab,;
											cLojaTab,;
											If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
											If(nPNumLote>0,aCols[n][nPNumLote],""),;
											NIL,;
											NIL,;
											.T.,;
											NIL,;
											@lContrato)
				EndIf		
				aCols[n][nCntFor] := A410Arred(nPrcTab,"C6_PRUNIT")
			Case cFieldFor == "C6_PRCVEN" .And. !(lReferencia .And. lGrdMult)
				// O preenchimento da variavel nPrcTab soh poderah ter valor diferente se na execucao anterior da funcao
				// A410Tabela for identificado que para o item existe um contrato de parceria. A variavel lContrato tem
				// esta informacao e que eh preenchida apos a primeira execucao da funcao A410Tabela neste loop.
				If ( (lContrato == Nil .Or. lContrato) .AND. lAtuPreco )
					nPrcTab:=A410Tabela(	cProdRef,;
											M->C5_TABELA,;
											n,;
											aCols[n][nPQtdVen],;
											cCliTab,;
											cLojaTab,;
											If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
											If(nPNumLote>0,aCols[n][nPNumLote],""),;
											NIL,;
											NIL,;
											.F.,;
											NIL,;
											@lContrato)
				EndIf
				If !(lReferencia .And. lGrdMult) .Or. nPrcTab <> 0
					If ( !lDescSubst)
						aCols[n][nCntFor] := A410Arred(FtDescCab(nPrcTab,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					Else
						aCols[n][nCntFor] := FtDescCab(nPrcTab,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					EndIf
				EndIf
			Case cFieldFor == "C6_UNSVEN"
				A410SegUm(.T.)
			Case cFieldFor == "C6_CF"
				aCols[n][nCntFor] := cCFOP
			Case "C6_COMIS" $ cFieldFor  
				aCols[n][nCntFor] := SB1->B1_COMIS	
			Case cFieldFor == "C6_QTDLIB"
				aCols[n][nCntFor] := 0
			Case cFieldFor == "C6_QTDVEN"
				aCols[n][nCntFor] := 0
			Case cFieldFor == "C6_VALOR"
				aCols[n][nCntFor] := A410Arred(aCols[n,nPPrcVen]*aCols[n,nPQtdVen],"C6_VALOR")
			Case cFieldFor == "C6_VALDESC"
				aCols[n][nCntFor] := 0
			Case cFieldFor == "C6_DESCONT"
				aCols[n][nCntFor] := 0
			Case cFieldFor == "C6_NUMLOTE"
				aCols[n][nCntFor] := CriaVar("C6_NUMLOTE")
			Case cFieldFor == "C6_LOTECTL"
				aCols[n][nCntFor] := CriaVar("C6_LOTECTL")
			Case cFieldFor == "C6_CODISS"
				aCols[n][nCntFor] := RetFldProd(SB1->B1_COD,"B1_CODISS")
			Case cFieldFor == "C6_NFORI"
				aCols[n][nCntFor] := CriaVar("C6_NFORI")
			Case cFieldFor == "C6_SERIORI"
				aCols[n][nCntFor] := CriaVar("C6_SERIORI")
			Case cFieldFor == "C6_ITEMORI"
				aCols[n][nCntFor] := CriaVar("C6_ITEMORI")
			Case cFieldFor == "C6_IDENTB6"
				aCols[n][nCntFor] := CriaVar("C6_IDENTB6")			
			Case cPaisloc <> "RUS" .AND. cFieldFor == "C6_FCICOD" //SIGAFIS
				aCols[n][nCntFor] := Upper( XFciGetOrigem( SB1->B1_COD , M->C5_EMISSAO )[2] )
		EndCase
	Next nCntFor
	If ( MV_PAR01 == 1 .And. lCB )
		MaIniLiber(M->C5_NUM,aCols[n][nPQtdVen],n,lCB)
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Inicializar os campos de enderecamento do WMS para uso na carga         �
	//��������������������������������������������������������������������������
	If !Empty(M->C5_TRANSP)
		SA4->(DbSetOrder(1))
		If SA4->(MsSeek(xFilial("SA4")+M->C5_TRANSP)) .AND.;
		   !Empty(SA4->A4_ESTFIS)                     .AND.;
		   !Empty(SA4->A4_ENDPAD)                     .AND.;
		   !Empty(SA4->A4_LOCAL)                      .AND.;
		   nPEndPad > 0                               .AND.;
		   nPLocal > 0

			aCols[n][nPEndPad] := SA4->A4_ENDPAD
			aCols[n][nPLocal]  := SA4->A4_LOCAL
		Endif
	Endif							

EndIf                                                     

//�����������������������������������������������������������������Ŀ
//� Posiciona nas tabelas SB1 e SF4 para o preenchimento correto da �
//� classifica��o fiscal dos itens C6_CLASFIS atrav�s dos gatilhos. �
//�������������������������������������������������������������������
If !lContinua .And. RTrim(cProdRef) <> RTrim(SB1->B1_COD)
	If lGrade	
		lReferencia := MatGrdPrrf(@cProdRef)
	EndIf
	SB1->(dbSetOrder(1))	
	if !lGrade .and. !lReferencia
		SB1->(MsSeek(xFilial("SB1")+cProdRef))
	Else
		SB1->(MsSeek(xFilial("SB1")+cProdRef),.F.)	
	EndIf
EndIf

TransBasImp(.T.)
Return(lRetorno)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410Local � Autor � Eduardo Riera         � Data � 23.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Avaliar o Almoxarifado Digitado                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410Local()

Local cProduto
Local cVar 			:= &(ReadVar())
Local lGrade 		:= MaGrade()
Local lContinua	:= .T.
Local lRetorno 	:= .T.
Local nPLocal		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPReserva	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_RESERVA"})
Local nPNumLote	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPLoteCtl	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPDtValid	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
Local nPLocaliz 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCALIZ"})
Local nPNumSer		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMSER"})
Local l410ExecAuto	:= (Type("l410Auto") <> "U" .And. l410Auto)
Local lCriaSB2 		:= .T.

//������������������������������������������������������������������������Ŀ
//�Verifica se o Almoxarifado foi alterado                                 �
//��������������������������������������������������������������������������
If ( aCols[n][nPLocal] == Trim(cVar) )
	lContinua := .F.
EndIf

If ( lContinua .And. nPProduto != 0 )
	cProduto := aCols[n][nPProduto]
	If ( lGrade )
		cProduto := aCols[n][nPProduto]
		lGrade := MatGrdPrrf(@cProduto)
	EndIf
	If !lGrade
		dbSelectArea("SB2")
		dbSetOrder(1)
		If ( !MsSeek(xFilial("SB2")+cProduto+cVar,.F.) )
			If !l410ExecAuto //Caso nao for ExecAuto, questiona ao usuaio se deseja criar registro na SB2.
				lCriaSB2 := (MsgYesNo(OemToAnsi(STR0414+cVar+STR0415+STR0416),STR0413+cProduto))//Atencao - ## O Armazem ## nao existe para este produto. Deseja cria-lo agora?	
			EndIf
			If lCriaSB2
				CriaSB2(cProduto,cVar)
			Else
				lRetorno := .F.
				lContinua:= .F.
			EndIf
		EndIf
	EndIf
EndIf
If ( lContinua .And. nPReserva != 0 ) .AND. ( !Empty(aCols[n][nPReserva]) )
	dbSelectArea("SC0")
	dbSetOrder(1)
	If !MsSeek(xFilial("SC0")+aCols[n][nPReserva]+cProduto+cVar,.F.)
		Help(" ",1,"A410RES")
		lRetorno := .F.
		lContinua:= .F.
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Reinicializa os campos de estoque                                       �
//��������������������������������������������������������������������������
If ( !lRetorno )
	If ( nPNumLote	!= 0 )
		aCols[n][nPNumLote]	:= CriaVar("C6_NUMLOTE")
	EndIf
	If ( nPLoteCtl	!= 0 )
		aCols[n][nPLoteCtl]	:= CriaVar("C6_LOTECTL")
	EndIf
	If ( nPDtValid != 0 )
		aCols[n][nPDtValid]	:= CriaVar("C6_DTVALID")
	EndIf
	If ( nPLocaliz	!= 0 )
		aCols[n][nPLocaliz]	:= CriaVar("C6_LOCALIZ")
	EndIf
	If ( nPNumSer	!= 0 )
		aCols[n][nPNumSer]	:= CriaVar("C6_NUMSER")
	EndIf
EndIf
Return(lRetorno)    

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410ValTES� Autor � Claudinei Benzi       � Data � 24.10.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Esta fun� o valida algumas informacoes pertinentes ao TES  ���
���          � informado em relacao ao do primeiro item. Ex. Ao informar  ���
���          � o TES a geracao ou nao da duplicata deve ser igual.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void A410ValTES(ExpC1,ExpC2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do TES a ser comparado.                     ���
���          � ExpC2 = Codigo do TES do primeiro item (padrao para Nota)  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410ValTES(cTesCor,cTes)

Local cNaturez	:= ""
Local lRetorno	:= .T.
Local nRecSF4	:=	0
Local l410Aut   	:= Iif(Type("l410Auto")<> "U",l410Auto, .F.)

SF4->( DBSetOrder( 1 ) )

If SF4->( MsSeek(xFilial()+cTesCor,.F.) )

	If SF4->F4_MSBLQL == "1"
		Help("", 1, STR0118, , STR0336+CRLF+ALLTRIM(SF4->F4_CODIGO),1, )
		lRetorno := .F.
	EndIf

	If lRetorno
		If ( SF4->F4_TIPO == 'S' )
	
			If ( cTes != NIL )
				nRecSF4	:=	SF4->(Recno())
				//cDestaca := SF4->F4_DESTACA
				cTipo    := SF4->F4_TIPO
				If SF4->( MsSeek(xFilial("SF4")+cTes,.F.) )
					If !( /*cDestaca == SF4->F4_DESTACA .And.*/ cTipo == SF4->F4_TIPO )
						Help(" ",1,"A410NAOTES")
						lRetorno := .F.
					EndIf
				Else
					Help(" ",1,"A410TE")
					lRetorno := .F.
				EndIf
				SF4->(MsGoTo(nRecSF4))							
			EndIf
	
			If lRetorno .AND. SF4->F4_DUPLIC == "S" 
				//�����������������������������������������������������������������������������������������Ŀ
				//�Se a TES gera duplicatas e o parametro MV_1DUPNAT indica que natureza a ser considerada �	
				//�est� no campo C5_NATUREZ, obrigar o usuario preencher o campo no cabe�alho do pedido.   �
				//������������������������������������������������������������������������������������������
				If "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,""))  
					If X3Uso(GetSX3Cache("C5_NATUREZ","X3_USADO"))
						If Empty(M->C5_NATUREZ)
							// Se for rotina automatica, retira a natureza do cliente
							If l410Aut 
								cNaturez := GetAdvFval("SA1","A1_NATUREZ",xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)
								If !Empty(cNaturez)
									M->C5_NATUREZ := cNaturez
								Else
									Help(" ",1,"A410NATPED") 
									lRetorno := .F.  
								EndIf		
							Else
								Help(" ",1,"A410NATPED") 
								lRetorno := .F.  
							EndIf	
						EndIf				
					Else
						Help(" ",1,"A410NATUSO") 
						lRetorno := .F. 
					EndIf
				//�������������������������������������������������������������������������������������������������Ŀ
				//�Se a TES gera duplicatas e o parametro MV_1DUPNAT indica que natureza a ser considerada est� no �	
				//�campo A1_NATUREZ, orientar o usuario informar uma natureza padr�o no cadastro de clientes		 �								
				//��������������������������������������������������������������������������������������������������
				ElseIf "A1_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,""))
					If !M->C5_TIPO $ "DB"
						If X3Uso(GetSX3Cache("A1_NATUREZ","X3_USADO"))
							If !Empty(M->C5_CLIENTE) .AND. !Empty(M->C5_LOJACLI) 
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1))
								If DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) .AND. Empty(SA1->A1_NATUREZ)
									Help(" ",1,"A410NATCLI")
									lRetorno := .F.
								EndIf 
							EndIf
						Else
							Help(" ",1,"A410NATUSO") 
							lRetorno := .F. 
						EndIf
					EndIf	
				ElseIf Empty(Upper(SuperGetMv("MV_1DUPNAT",.F.,""))) 
					Help(" ",1,"A410NATVZO") 
					lRetorno := .F.	
				EndIf
			EndIf
	
			If cPaisLoc <> "BRA" .And. lRetorno
				//���������������������������������������������������������Ŀ
				//�Se usa entrega futura, o TES nao deve movimentar estoques�
				//�����������������������������������������������������������
				If  SF4->F4_ESTOQUE == 'S'	.And.(Type("M->C5_DOCGER") <> "U" .And. M->C5_DOCGER == '3')
					Help(" ",1,"A410RMFUT")
					lRetorno := .F.
				EndIf			
				//���������������������������������������������������������������Ŀ
				//�Se o pedido e de consignacao, deve estar preenchido o campo que�
				//�define o TES que deve ser usado no remito, e este TES deve con-�
				//�trolar poder de terceiros.                                     �
				//�����������������������������������������������������������������
				If lRetorno	.And. Type("M->C5_TIPOREM") <> 'U' .And. M->C5_TIPOREM == "A"
					
					//�������������������������������������������������������������������Ŀ
					//�Verificar se esta vazio o campo que define o TES que deve ser usado�
					//�para envio para poder de 3ros e o campo para devolucao             �
					//���������������������������������������������������������������������
					If M->C5_DOCGER <> "1" .And. Empty(SF4->F4_TESENV)
						Help(" ",1,"A410TES001")
						lRetorno := .F.
					Endif
					//�������������������������������������������������������������������Ŀ
					//�Verificar se os TES configurados para envios existem e sao corretos�
					//�(tipo "R" para a saida e "D" para a entrada).                      �
					//���������������������������������������������������������������������
					nRecSF4	:=	SF4->(Recno())
					If lRetorno .And. M->C5_DOCGER <> "1" .And. (!SF4->(MsSeek(xFilial()+SF4->F4_TESENV)) .Or. SF4->F4_PODER3 <> "R" )
						Help(" ",1,"A410TES003")
						lRetorno := .F.
					Endif
					SF4->(MsGoTo(nRecSF4))							
				Endif   	
			Endif
	
		Else
			Help(" ",1,"A410NAOTES")
			lRetorno := .F.
		EndIf
	EndIf

Else
	Help(" ",1,"A410TE")
	lRetorno := .F.
EndIf
Return(lRetorno)         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410Reserv� Autor �Eduardo Riera          � Data �02.03.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Reserva                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410Reserv()

Local aArea  		:= GetArea()
Local aAreaC6		:= SC6->(GetArea())
Local aAreaF4		:= SF4->(GetArea())
Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO" })
Local nPLocal		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPNumLote	    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPLoteCtl		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPLocaliz  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCALIZ"})
Local nPNumSer		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMSERI"})
Local nPReserva		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_RESERVA"})
Local nPTes			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local lGrade		:= MaGrade()
Local lRetorna		:= .T.
Local nQtdRes		:= 0
Local nCntFor 		:= 0
Local cFilSC6		:= xFilial("SC6")
Local lContercOk 	:= .F.

cProduto	:= aCols[n][nPProduto]
cLocal		:= aCols[n][nPLocal]
cReserva	:= If(ReadVar() $ "M->C6_RESERVA", &(ReadVar()), aCols[n][nPReserva])

//������������������������������������������������������������������������Ŀ
//�Nao pode  haver  reserva  com grade                                     �
//��������������������������������������������������������������������������
If lGrade .AND. MatGrdPrrf(aCols[n][nPProduto])
	Help(" ",1,"A410NGRADE")
	lRetorna := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�O tes deve movimentar estoque                                           �
//��������������������������������������������������������������������������
dbSelectArea("SF4")
dbSetOrder(1)
If MsSeek(xFilial("SF4")+aCols[n][nPTes]) .AND. SF4->F4_ESTOQUE == "N"
	lContercOk	:= If(FindFunction("EstArmTerc"), EstArmTerc(), .F.) // Verifica se � armzem de terceiro
	If !lContercOk .Or. (lContercOk .And. SF4->F4_CONTERC <> "1")
		Help(" ",1,"A410TEEST")
		lRetorna := .F.
	EndIf
EndIf

If ( lRetorna )
	dbSelectArea("SC0")
	dbSetOrder( 1 )
	If !MsSeek(xFilial("SC0")+cReserva+cProduto+cLocal)
		Help(" ",1,"A410RES")
		lRetorna := .F.
	ElseIf cPaisLoc$"EUA|POR" .and. SC0->C0_TIPO == "LW" //Tratamento para Lay-Away
		Help(" ",1,"A410RES")
		lRetorna := .F.
	ElseIf GetNewPar("MV_CHCLRES",.F.)
		If SC0->C0_TIPO == "CL" .And. SC0->C0_DOCRES <> M->C5_CLIENTE
			MsgAlert(STR0093 + Alltrim(cReserva) + STR0094 + SC0->C0_DOCRES)
			lRetorna := .F.
		Else
			nQtdRes := SC0->C0_QUANT
		EndIf
	Else
		nQtdRes := SC0->C0_QUANT
	EndIf
EndIf

//������������������������������������������������������Ŀ
//�  Verifica Saldo da Reserva                           �
//��������������������������������������������������������
If ( lRetorna )
	//������������������������������������������������������������������������Ŀ
	//�Verifica a quantidade utilizada neste pedido                            �
	//��������������������������������������������������������������������������
	dbSelectArea("SC6")
	dbSetOrder(2)
	MsSeek(cFilSC6+cProduto+M->C5_NUM,.F.)
	While ( SC6->(!Eof())                     .AND.;
	        cFilSC6         == SC6->C6_FILIAL .AND.;
			SC6->C6_PRODUTO == cProduto       .AND.;
			SC6->C6_NUM		== M->C5_NUM )

		If ( cReserva == SC6->C6_RESERVA .And. cLocal == SC6->C6_LOCAL )
			nQtdRes += SC6->C6_QTDRESE
		EndIf
		SC6->(dbSkip())
	EndDo

	//������������������������������������������������������������������������Ŀ
	//�Verifica a quantidade utilizada no Acols                                �
	//��������������������������������������������������������������������������
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor][Len(aHeader)+1] 			.And.;
				cReserva==aCols[nCntFor][nPReserva] 	.And.;
				cLocal	==aCols[nCntFor][nPLocal] 		.And.;
				cProduto==aCols[nCntFor][nPProduto] 	.And.;
				n 		!=nCntFor)
			nQtdRes -= Min(aCols[nCntFor][nPQtdVen],nQtdRes)
		EndIf
	Next nCntFor

	//������������������������������������������������������������������������Ŀ
	//�Quantida utilizada no item                                              �
	//��������������������������������������������������������������������������
	nQtdRes -= If( nQtdRes==0, aCols[n][nPQtdVen], Min(aCols[n][nPQtdVen],nQtdRes) )

	//������������������������������������������������������������������������Ŀ
	//�Valida a Reserva                                                        �
	//��������������������������������������������������������������������������
	If ( nQtdRes < 0 )
		Help(" ",1,"A410RESERV")
		lRetorna := .F.
	EndIf
EndIf
//������������������������������������������������������Ŀ
//�  Atualiza Quantidade e Nro do Lote                   �
//��������������������������������������������������������
If ( lRetorna )
	If !(Acols[n][nPQtdVen] > 0)
		Acols[n][nPQtdVen] 	:= SC0->C0_QUANT
	EndIf
	If ( nPNumLote != 0 )
		Acols[n][nPNumLote]  := SC0->C0_NUMLOTE
	EndIf
	If ( nPLoteCtl != 0 )
		Acols[n][nPLoteCtl]	:= SC0->C0_LOTECTL
	EndIf
	If ( nPLocaliz != 0 )
		Acols[n][nPLocaliz]	:= SC0->C0_LOCALIZ
	EndIf
	If ( nPNumSer != 0 )
		Acols[n][nPNumSer ] 	:= SC0->C0_NUMSERI
	EndIf
	If ! Empty(aCols[n][nPLoteCtl])
		lRetorna	:= A410LotCTL()
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Retorna os registros alterados                                          �
//��������������������������������������������������������������������������
RestArea(aAreaF4)
RestArea(aAreaC6)
RestArea(aArea)
Return(lRetorna)       

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410NfOrig� Autor �Eduardo Riera          � Data �01.03.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao e Inicializacao da Nota Fiscal Original           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410NfOrig()

Local aArea		:= GetArea()
Local aAreaSB8  := SB8->(GetArea())
Local aValor    := {}
Local cNfOri 	:= ""
Local cSeriOri	:= ""
Local cItemOri	:= ""
Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPValor  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPNumLote	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPLoteCtl	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPDtValid	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
Local nPTES		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPNfori	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSeriori	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItemOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPIdentB6	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPSegum  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SEGUM"})
Local nPValDes 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPDescont 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local lRetorno 	:= .T.
Local cLocCQ    := SuperGetMv('MV_CQ')
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local lOk       := .T. 
Local aEntidades:= {}
Local nEnt		:= 0
Local nDeb		:= 0
Local nPosHead	:= 0
Local cCpo		:= ""
Local cCD1		:= ""

//������������������������������������������������������������������������Ŀ
//�Inicializa Nota,Serie e Item                                            �
//��������������������������������������������������������������������������
If ( Empty(cNfOri) )
	cNfOri  	:= aCols[n][nPNfori]
EndIf
If ( Empty(cSeriOri) )
	cSeriOri := aCols[n][nPSeriori]
EndIf
If ( Empty(cItemOri) )
	cItemOri := aCols[n][nPItemOri]
EndIf
If ( AllTrim(ReadVar()) == "M->C6_NFORI" )
	cNfOri 	:= &(ReadVar())
EndIf
If ( AllTrim(ReadVar()) == "M->C6_SERIORI" )
	cSeriOri	:= &(ReadVar())
EndIf
If ( AllTrim(ReadVar()) == "M->C6_ITEMORI" )
	cItemOri	:= &(ReadVar())
EndIf

If lUsaNewKey .And. !l410Auto
	//������������������������������������������������������������������������Ŀ
	//�Projeto Chave Unica                                                     �
	//�Quando o usuario tenta fazer a devolucao por digitacao na getdados do   �
	//�pedido de vendas eh necessario que seja obrigatoriamente pela dialog de �
	//�selecao da funcao F4NfOri() do SIGACUS.PRW acionada pela funcao A440Stok�
	//�pois como podem existir varias notas com o mesmo numero eh necessario   �
	//�selecionar a NF para carregar o Id de controle correto para o C6_SERIORI�
	//��������������������������������������������������������������������������
	lOk := A440Stok(NIL,"A410")

	If !lOk .And. M->C5_TIPO == "D" .And. nPNfOri != 0 .And. nPSeriOri !=0 .And. nPItemOri != 0
		If ( !Empty(cItemOri) )
			Help(" ",1,"A100NF")
			lRetorno := .F.
		EndIf
		aCols[n][nPNfOri]	:= cNfOri
		aCols[n][nPSeriOri]	:= cSeriOri
		aCols[n][nPItemOri]	:= CriaVar("D1_ITEM",.F.)
	EndIf
	
Else
	//������������������������������������������������������������������������Ŀ
	//�Avalia Notas de Devolucao                                               �
	//��������������������������������������������������������������������������
	If ( M->C5_TIPO == "D" .And. nPNfOri != 0 .And. nPSeriOri !=0 .And. nPItemOri != 0 )

		//������������������������������������������������������������������������Ŀ
		//�Somente Valida a Nota de Devolucao quando for  informado o Nr.Nota,     �
		//�a serie e o item da nota original.                                      �
		//��������������������������������������������������������������������������
		dbSelectArea("SD1")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SD1")+cNfOri+cSeriOri+M->C5_CLIENTE+M->C5_LOJACLI+aCols[n][nPProduto]+cItemOri) )
			aValor := A410SNfOri(SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,SD1->D1_COD,,aCols[n][nPLocal],"SD1")

			//������������������������������������������������������������������������Ŀ
			//�Verifica o Almoxarifado de Entrada                                      �
			//��������������������������������������������������������������������������
			If ( nPLocal <> 0 )
				If SD1->D1_LOCAL == cLocCQ
					aCols[n,nPLocal] := If(!Empty(aCols[n,nPLocal]),aCols[n,nPLocal],SD1->D1_LOCAL)
					M->C6_LOCAL	     := aCols[n,nPLocal]
				ElseIf !(l410Auto .And. Type("aAutoItens") # "U" .And. aScan(aAutoItens[n], {|x| x[1] == "C6_LOCAL"}) > 0)
					aCols[n,nPLocal] := SD1->D1_LOCAL
					M->C6_LOCAL	     := SD1->D1_LOCAL
				EndIf
			EndIf

			//������������������������������������������������������������������������Ŀ
			//�Verifica o Preco Unitario de Entrada                                    �
			//��������������������������������������������������������������������������
			If ( nPPrcVen != 0 )
				If Abs(aCols[n][nPPrcVen]-a410Arred(aValor[2]/IIf(aValor[1]==0,1,aValor[1]),"C6_PRCVEN"))>0.01
					aCols[n][nPPrcVen] := a410Arred(aValor[2]/IIf(aValor[1]==0,1,aValor[1]),"C6_PRCVEN")
					A410MultT("C6_PRCVEN",aCols[N,nPPrcVen])
				EndIf
			EndIf

			//������������������������������������������������������������������������Ŀ
			//�Verifica a quantidade ja devolvida deste item                           �
			//��������������������������������������������������������������������������
			If  ( aCols[n][nPQtdVen] > aValor[1] .Or. aCols[n][nPQtdVen] == 0)
				aCols[n][nPQtdVen]  := aValor[1]
				A410MultT("C6_QTDVEN",aCols[N,nPQtdVen])
			EndIf
			If ( nPSegum != 0 )
				aCols[n][nPSegum] := SD1->D1_SEGUM
			EndIf

			//������������������������������������������������������������������������Ŀ
			//�Verifica o Lote de Entrada                                              �
			//��������������������������������������������������������������������������
			If SF4->(dbSeek(xFilial("SF4")+aCols[N][nPTES])) .And. SF4->F4_ESTOQUE == 'S'
				If ( nPNumLote != 0 ) .And. (SD1->D1_LOCAL<>cLocCQ .Or. (SD1->D1_LOCAL==cLocCQ .And. Empty(aCols[n,nPNumLote])) )
					aCols[n][nPNumLote] := SD1->D1_NUMLOTE
				EndIf
				If ( nPLoteCtl != 0 ) .And. (SD1->D1_LOCAL<>cLocCQ .Or. (SD1->D1_LOCAL==cLocCQ .And. Empty(aCols[n,nPLoteCtl])) )
					aCols[n][nPLoteCtl] := SD1->D1_LOTECTL
				EndIf
				If ( nPDtValid != 0 ) .And. (SD1->D1_LOCAL<>cLocCQ .Or. (SD1->D1_LOCAL==cLocCQ .And. Empty(aCols[n,nPDtValid])) )
					aCols[n][nPDtValid] := SD1->D1_DTVALID
					SB8->(dbSetOrder(3))
					If SB8->(MsSeek(xFilial("SB8")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL+IIf(Rastro(SD1->D1_COD,"S"),SD1->D1_NUMLOTE,"")))
						aCols[n][nPDtValid] := SB8->B8_DTVALID
					EndIf
				EndIf
			EndIf

			//Grava as entidades cont�veis informadas no documento de entrada
			aEntidades := CtbEntArr()
			For nEnt := 1 to Len(aEntidades)
				For nDeb := 1 to 2
					cCpo := "C6_EC"+aEntidades[nEnt]
					cCD1 := "D1_EC"+aEntidades[nEnt]					
					If nDeb == 1
						cCpo += "DB"
						cCD1 += "DB"
					Else
						cCpo += "CR"
						cCD1 += "CR"
					EndIf
					nPosHead := aScan(aHeader,{|x| AllTrim(x[2]) == Alltrim(cCpo) } )
					If nPosHead > 0 .And. SD1->(ColumnPos(cCD1)) > 0
						aCols[Len(aCols)][nPosHead] := SD1->(&(cCD1))
					EndIf
				Next nDeb
			Next nEnt

			//������������������������������������������������������������������������Ŀ
			//�Atualiza o Valor Total                                                  �
			//��������������������������������������������������������������������������
			If ( MV_PAR01 == 1 ) //Sugere Qtd.Liberada
				MaIniLiber(M->C5_NUM,aCols[n][nPQtdVen],n)
			EndIf
		Else
			If ( !Empty(cItemOri) )
				Help(" ",1,"A100NF")
				lRetorno := .F.
			EndIf
			aCols[n][nPNfOri]	:= cNfOri
			aCols[n][nPSeriOri]	:= cSeriOri
			aCols[n][nPItemOri]	:= CriaVar("D1_ITEM",.F.)
		EndIf
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Avalia Complementos                                                     �
	//��������������������������������������������������������������������������
	If ( M->C5_TIPO == "CIP" .And. nPNfOri != 0 .And. nPSeriOri !=0 .And. nPItemOri != 0 )
		dbSelectArea("SD2")
		dbSetOrder(3)
		If (!MsSeek(xFilial("SD2")+cNfOri+cSeriOri+M->C5_CLIENTE+M->C5_LOJACLI+aCols[n][nPProduto]+cItemOri) ) .AND. ( !Empty(cItemOri) )
			Help(" ",1,"A410NF")
			lRetorno := .F.
		EndIf
	EndIf
	
	//������������������������������������������������������������������������Ŀ
	//�Avalia Poder de Terceiros                                               �
	//��������������������������������������������������������������������������
	If ( nPTes  != 0 )
		dbSelectArea("SF4")
		dbSetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[n][nPTes]) .AND. SF4->F4_PODER3 == "D"
			//������������������������������������������������������������������������Ŀ
			//�Verifica o Identificador do Poder de/em Terceiro                        �
			//��������������������������������������������������������������������������
			If ( nPIdentB6 != 0 .And. Empty(cNfOri) )
				aCols[n][nPIdentB6] := ""
			EndIf

			//������������������������������������������������������������������������Ŀ
			//�Verifica o Preco Unitario de Entrada                                    �
			//��������������������������������������������������������������������������
			If nPIdentB6 <> 0 .And. !Empty(aCols[n][nPIdentB6])
				SD1->(dbSetOrder(4))
				If SD1->(MsSeek(xFilial("SD1")+aCols[n][nPIdentB6]))
					If ( nPPrcVen != 0 )
						aCols[n][nPPrcVen] := a410Arred(((SD1->D1_QUANT * SD1->D1_VUNIT)-SD1->D1_VALDESC)/SD1->D1_QUANT,"C6_PRCVEN")
					EndIf
					//������������������������������������������������������������������������Ŀ
					//�Atualiza o Valor Total                                                  �
					//��������������������������������������������������������������������������
					aCols[n][nPValor ]  := a410Arred(aCols[n][nPQtdVen]*aCols[n][nPPrcVen],"C6_VALOR")
					If ( MV_PAR01 == 1 ) //Sugere Qtd.Liberada
						MaIniLiber(M->C5_NUM,aCols[n][nPQtdVen],n)
					EndIf
				EndIf
			Endif
		EndIf
	EndIf
	
EndIf

If nPNfOri > 0 .And. nPSeriOri > 0 .And. nPItemOri > 0
	//Integra��o WMS Logix x Protheus, quando houver desconto na nota original, ajuste nos campo de valor de desconto e zera
	//porcentagem de desconto, para que n�o ocorra problemas de arredondamento.
	If nPValDes > 0 .And. nPDescont > 0 .And. IsInCallStack("MATI411") 
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+cNfOri+cSeriOri+M->C5_CLIENTE+M->C5_LOJACLI+aCols[n][nPProduto]+cItemOri)) .AND. SD1->D1_VALDESC > 0

			nVlrDesc := Round(SD1->D1_VALDESC,TamSx3("C6_VALDESC")[2])
				
			If aCols[n,nPQtdVen] <> SD1->D1_QUANT
				aCols[n,nPValDes] 	:= Round((aCols[n,nPQtdVen]*nVlrDesc)/SD1->D1_QUANT,TamSx3("C6_VALDESC")[2])
				aCols[n,nPDescont]	:= 0
				aCols[n,nPValor]	:= Round(aCols[n,nPValor] - aCols[n,nPValDes],TamSx3("C6_VALOR")[2])
				aCols[n,nPPrcVen]	:= Round(aCols[n,nPValor] / aCols[n,nPQtdVen],TamSx3("C6_PRCVEN")[2])	
			Else
				aCols[n,nPValDes]	:= nVlrDesc
				aCols[n,nPDescont]	:= 0
				aCols[n,nPValor]	:= Round(SD1->D1_TOTAL - aCols[n,nPValDes],TamSx3("C6_VALOR")[2])
				aCols[n,nPPrcVen]	:= Round(aCols[n,nPValor] / aCols[n,nPQtdVen],TamSx3("C6_PRCVEN")[2])
			Endif

		Endif
	Endif
Endif

//������������������������������������������������������������������������Ŀ
//�Restaura a workarea de entrada                                          �
//��������������������������������������������������������������������������
RestArea(aAreaSB8)
RestArea(aArea)
Return(lRetorno)

/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �a410Trava  � Autor � Rosane L. Chene       � Data � 05.12.95 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento de DEAD-LOCK - Arquivo SB2                       ���
��������������������������������������������������������������������������Ĵ��
���Uso       � MatA410                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function A410Trava()

Local ni     := 0
Local aTrava := {}
Local nPosPrd:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPosLoc:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})
Local nPosTes:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
Local lTrava := .T.
Local lTravaSA1 := .T.
Local lTravaSA2 := .T.
Local lTravaSB2 := .T.
Local aRetorno  := {}
Local cFilSF4   := xFilial("SF4")
Local aAreaAnt  := GetArea()
Local CMT410TRV 	:= SupergetMv("MV_FATTRAV",.F.,"") // Desabilita o MultLock dos registros 1= SA1 2= SA2 3= SB2 4= Todos para NF utilizado apenas 3 ou 4

Static lMT410TRV := ExistBlock("MT410TRV")

If ( __TTSInUse )
	// Ponto de Entrada MT410TRV utilizado para desligar o Lock das tabelas SA1 / SA2
	If lMT410TRV
		aRetorno  := ExecBlock("MT410TRV",.F.,.F.,{M->C5_CLIENTE,M->C5_LOJACLI,IIf(M->C5_TIPO$"DB","F","C")})
		If ValType(aRetorno) == "A" .And. Len(aRetorno) >= 3
			lTravaSA1 := aRetorno[1]
			lTravaSA2 := aRetorno[2]
			lTravaSB2 := aRetorno[3]
		EndIf	
	EndIf
	If !lMT410TRV .And. !Empty(CMT410TRV) 
		lTravaSA1 := !(CMT410TRV == "1" .Or. CMT410TRV == "4")
		lTravaSA2 := !(CMT410TRV == "2" .Or. CMT410TRV == "4")
		lTravaSB2 := !(CMT410TRV == "3" .Or. CMT410TRV == "4")
	EndIf
	For nI := 1 to Len(aCols)
		IF ( Len(aCols[nI]) > Len(aHeader) ) .And. !(aCols[ni][Len(aCols[ni])])
			If nPosTes > 0 .And. SF4->( MsSeek(cFilSF4+aCols[ni,nPosTes]) )
				If SF4->F4_ESTOQUE == "S"
					AADD(aTrava,aCols[ni,nPosPrd]+aCols[ni,nPosLoc])
				Endif
			Else
				AADD(aTrava,aCols[ni,nPosPrd]+aCols[ni,nPosLoc])
			EndIf
		EndIf
	Next
	If M->C5_TIPO $ "DB"
		If lTravaSA2
			lTrava :=	MultLock("SA2",{M->C5_CLIENTE+M->C5_LOJACLI},1) .And. ;
						MultLock("SA2",{M->C5_CLIENT+M->C5_LOJAENT},1)			
		EndIf	
	Else
		If lTravaSA1
			lTrava :=	MultLock("SA1",{M->C5_CLIENTE+M->C5_LOJACLI},1) .And. ;
						MultLock("SA1",{M->C5_CLIENT+M->C5_LOJAENT},1)
		EndIf	
	EndIf

	If lTrava .And. Len(aTrava) > 0 .AND. lTravaSB2
		lTrava := MultLock("SB2",aTrava,1)
	EndIf

	If ( !lTrava ) .AND. !InTransact()
		SB2->(MsRUnLock())
		SA1->(MsRUnLock())
		SA2->(MsRUnLock())
	EndIf
EndIf
RestArea(aAreaAnt)
Return ( lTrava )

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A410Quant� Autor � Claudinei M. Benzi    � Data � 10.01.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa Seg. Unidade de Medida pelo Fator de Conversao  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MatA410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410Quant()

Local nSegUm	:= &(ReadVar())
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nQtdConv  := 0
Local lGrade    := MaGrade()
Local cProduto  := ""
Local cItem	    := ""
Local lRet	 	:= .T.

If ( nSegUm != cCampo )
	cProduto := aCols[n][nPProduto]
	cItem		:= aCols[n][nPItem]
	If ( lGrade )
		MatGrdPrrf(@cProduto)
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Posiciona no Item atual do Pedido de Venda                              �
	//��������������������������������������������������������������������������
	dbSelectArea("SC6")
	dbSetOrder(1)
	MsSeek(xFilial("SC6")+M->C5_NUM+cItem+cProduto)
	
	nQtdConv  := Round( ConvUm(cProduto,aCols[n,nPQtdVen],nSegUm,1), TamSX3( "C6_QTDVEN" )[2] )
	lRet := A410MultT("C6_QTDVEN",nQtdConv)
	
	If lRet
		aCols[n,nPQtdVen] := nQtdConv
	
		//��������������������������������������������������������������Ŀ
		//� Nao aceita qtde. inferior `a qtde ja' faturada               �
		//����������������������������������������������������������������
		SC6->(dbEval({|| lRet := If(aCols[n,nPQtdVen] < SC6->C6_QTDENT,.F.,lRet)},Nil,;
		             {|| xFilial("SC6")	==	SC6->C6_FILIAL 	.And.;
		                 M->C5_NUM		==	SC6->C6_NUM		.And.;
		                 cItem			== SC6->C6_ITEM		.And.;
		                 cProduto		== SC6->C6_PRODUTO },Nil,Nil,.T.))
	
		If ( !lRet )
			Help(" ",1,"A410PEDJFT")
		EndIf
	Endif

Else
	lRet := .T.
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410SegUm � Autor � Eduardo Riera         � Data � 26.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Convercao da Primeira para a segunda unidade de medida      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExPL1: Indica se deve ser realizado o  recalculo            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410SegUm(lRecalc)

Local nPrimUm	:= 0
Local nPProduto:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPQtdVen2:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})

lRecalc := IIF(lRecalc==NIL,.F.,lRecalc)
If ( Altera .Or. INCLUI )
	nPrimUm := If(lRecalc, aCols[n][nPQtdVen], &(ReadVar()))
	If ( nPQtdVen2 > 0 )
		aCols[n,nPQtdVen2] := ConvUm(aCols[n,nPProduto],nPrimUm,aCols[n,nPQtdVen2],2)
	EndIf
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a410Refr  �  Autor� Wilson Godoy          � Data � 10.01.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quando acionada a getdados da grade, ele da o refresh para ���
���          � voltar todos os objetos da getdados principal              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCampo -> indica quando e' C6_QTDVEN ou C6_QTDLIB          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410Refr(cCampo)

Local ni			:= 0
Local nCol			:= 0
Local cItemGrade	:= ""

If ( MaGrade() )
	For ni := 1 to Len(aHeader)
		IF Alltrim(aHeader[ni,2]) == cCampo
			nCol := ni
		ElseIf Alltrim(aHeader[ni,2]) == "C6_GRADE" .AND. aCols[n][ni] == "S"
			cItemGrade := "S"
		EndIf
	Next
EndIf
Return .T. 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410LOTCTL� Autor �Rodrigo de A. Sartorio � Data �03.03.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o Lote de Controle digitado pelo usuario             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410LotCTL()

Local aArea		:= GetArea()
Local aAreaF4	:= SF4->(GetArea())
Local aAreaSB8	:= {}
Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPLocal	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
Local nPQtdLib	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPosOper  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})
Local nPTes		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPPrcLis  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPDescon	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPLocaliz	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCALIZ"})
Local nPosClas	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CLASFIS"})
Local nVlrTabela:= 0
Local cProduto	:= aCols[n][nPProduto]
Local cLocal	:= aCols[n][nPLocal]
Local cNumLote	:= ""
Local cLoteCtl  := ""
Local cLocaliza := ""
Local cCliTab  := ""
Local cLojaTab := ""
Local nQtdLib	:= aCols[n,nPQtdLib]
Local lRetorna  := .T.
Local nSaldo	:= 0
Local lGrade 	:= MaGrade()
Local lTabCli     := (SuperGetMv("MV_TABCENT",.F.,"2") == "1")
Local cReadVar	:= Upper(AllTrim(ReadVar()))
Local lContercOk 	:= .F.



//������������������������������������������������������������������������Ŀ
//�Obtem conteudo do Lote e do Sub-Lote                                    �
//��������������������������������������������������������������������������
If cReadVar == "M->C6_LOTECTL"
	cLocaliza	:= aCols[n][nPLocaliz]
	cNumLote	:= aCols[n][nPNumLote]
	cLoteCtl	:= &(cReadVar)
ElseIf cReadVar == "M->C6_NUMLOTE"
	cLocaliza	:= aCols[n][nPLocaliz]
	cNumLote	:= &(cReadVar)
	cLoteCtl	:= aCols[n][nPLoteCtl]
Else
	If	nPNumLote > 0 .AND. nPLoteCtl > 0
		cNumLote	:= aCols[n][nPNumLote]
		cLoteCtl	:= aCols[n][nPLoteCtl]
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica se Movimenta Estoque                                           �
//��������������������������������������������������������������������������
dbSelectArea("SF4")
dbSetOrder(1)
If ( MsSeek(xFilial("SF4")+aCols[n][nPTes]) .And. SF4->F4_ESTOQUE=="N" )
	lContercOk := If(FindFunction("EstArmTerc"), EstArmTerc(), .F.)	// Verifica se � armzem de terceiro
	If cReadVar == "M->C6_LOTECTL" .And. !Empty(cLoteCtl+aCols[n][nPNumLote])
		If !lContercOk .Or. (lContercOk .And. SF4->F4_CONTERC <> "1")
			Help(" ",1,"A410TEEST")
			lRetorna := .F.	
		EndIf
	ElseIf cReadVar == "M->C6_NUMLOTE" .And. !Empty(aCols[n][nPLoteCtl]+cNumLote)
		If !lContercOk .Or. (lContercOk .And. SF4->F4_CONTERC <> "1")
			Help(" ",1,"A410TEEST")
			lRetorna := .F.
		EndIf	
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica se o Produto eh uma referencia                                 �
//��������������������������������������������������������������������������
If  lRetorna .And. lGrade .AND. MatGrdPrrf(cProduto)
	Help(" ",1,"A410NGRADE")
	lRetorna := .F.
EndIf
If FindFunction("A010VlStr") .And. !A010VlStr()
	lRetorna := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica se o Produto possui rastreabilidade                            �
//��������������������������������������������������������������������������
If ( lRetorna .And. !Rastro(cProduto) )
	aCols[n,nPNumLote] := CriaVar( "C6_NUMLOTE" )
	aCols[n,nPLoteCtl] := CriaVar( "C6_LOTECTL" )
	aCols[n,nPDtValid] := CriaVar( "C6_DTVALID" )
	If (!Empty(&(cReadVar)))
		Help( " ", 1, "NAORASTRO" )
		lRetorna := .F.
	EndIf
Else
	If ( lRetorna ) .And. (! Empty(cReadVar))
		nSaldo := SldAtuEst(cProduto,cLocal,nQtdLib,cLoteCtl)

		If ALTERA .And. AtIsRotina("MATA410")
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n,nPItem]+aCols[n,nPProduto])
			nSaldo += SC6->C6_QTDEMP
		Endif

		If ( nQtdLib > nSaldo )
			Help(" ",1,"A440ACILOT")
			lRetorna  := .F.
		EndIf

		If lRetorna
			//���������������������������������������������������������������Ŀ
			//�Caso lote exista, obtem a data de validade                     �
			//�����������������������������������������������������������������
			aAreaSB8 := GetArea()
			SB8->(dbSetOrder(3))
			If SB8->(dbSeek(xFilial("SB8")+cProduto+cLocal+cLoteCtl+IF(Rastro(cProduto,"S"),cNumLote,"")))
				If SuperGetMV("MV_LOTVENC") <> "S" .AND. dDataBase > SB8->B8_DTVALID
					Help(" ",1,"LOTEVENC")//lote com a data de validade vencida
					lRetorna := .F.
				EndIf
				If lRetorna .And. nPDtValid > 0 .And. aCols[n, nPDtValid] # SB8->B8_DTVALID
					If !Empty(aCols[n, nPDtValid]) .AND. Type('lMSErroAuto') <> 'L' .AND. !IsInCallStack("A410Reserv")
						Help(" ",1,"A240DTVALI") //A data de validade do Lote ser� corrigida de acordo com a data de validade original
					EndIf
					M->C6_DTVALID := SB8->B8_DTVALID
					aCols[n,nPDtValid] := SB8->B8_DTVALID
				EndIf
			Endif 
			RestArea(aAreaSB8)

			If cPaisLoc == "BRA" .And. lRetorna .And. nPosClas > 0 .And. SuperGetMV("MV_ORILOTE",.F.,.F.) .And. FindFunction("OrigemLote")			
				If cReadVar == "M->C6_LOTECTL" .And. nPLoteCtl > 0
					aCols[n][nPLoteCtl] := cLoteCtl
				ElseIf cReadVar == "M->C6_NUMLOTE" .And. nPNumLote > 0
					aCols[n][nPNumLote] := cNumLote
				EndIf
				If !Empty(aCols[n][nPosOper])
					aCols[n][nPTes]:= MaTesInt(2,aCols[n][nPosOper],M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[n][nPProduto],"C6_TES") 
				EndIf
				aCols[n,nPosClas] := CodSitTri()
			EndIf

		EndIf
	EndIf
EndIf

If lRetorna
	If lTabCli
		Do Case
			Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
				cCliTab   := M->C5_CLIENT
				cLojaTab  := M->C5_LOJAENT
			Case Empty(M->C5_CLIENT)
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJAENT
			OtherWise
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJACLI
		EndCase
	Else
		cCliTab   := M->C5_CLIENTE
		cLojaTab  := M->C5_LOJACLI
	Endif

	nVlrTabela := A410Tabela(cProduto,M->C5_TABELA,n,aCols[n][nPQtdVen],cCliTab,cLojaTab,cLoteCtl,cNumLote,.T.)
	If nVlrTabela <> 0
		aCols[n][nPPrcVen] := A410Arred(FtDescCab(nVlrTabela,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
		aCols[n][nPPrcLis] := nVlrTabela
		A410MultT("C6_PRCVEN",aCols[n][nPPrcVen])
	Endif
Endif

If lRetorna .And. !Empty(cLocaliza) .AND. !A410RtLtEnd(cProduto,cLoteCtl,cLocaliza)
	Help(NIL, NIL, "A410RtLtEnd", NIL,STR0362, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0363})
	lRetorna  := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Restaura a Entrada da Rotina                                            �
//��������������������������������������������������������������������������
RestArea(aAreaF4)
RestArea(aArea)
aSize(aAreaF4,0)
aSize(aArea,0)
Return(lRetorna)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410FldOk �  Autor� Ben-Hur M Castilho    � Data � 12/12/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impede Alteracoes dos Campos Durante a Visualizacao         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410FldOk(nOpc)

Local lBack   := .T.
Local cMenVar := &(ReadVar())

Default nOpc := 1

If nOpc == 1
	If !(cMenVar == cCampo)
		Help( " ",1,"A410VISUAL" )
		lBack := .F.
	EndIf
ElseIf Type("lShowOpc") == "L"
	lShowOpc := .T.
EndIf
Return( lBack )         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410Blq   � Autor � Eduardo Riera         � Data � 24.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida item com bloqueio por (R) Residuo ou (S) Manual      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico ( Permite alteracao do Status do Bloqueio )   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410Blq()

Local lRetorno	:= .T.
Local nPosBlq	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_BLQ"})
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})

If ( nPosBlq > 0 ) .AND. ( aCols[n][nPosBlq]$"R #S " .And. SuperGetMv("MV_RSDOFAT")=="N" )
	Help(" ",1,"A410ELIM")
	lRetorno := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica se o Pedido foi Totalmente Faturado                            �
//��������������������������������������������������������������������������
If ( lRetorno )
	lRetorno := A410PedFat()
EndIf
If lRetorno 
	DbSelectArea('TEW')
	TEW->( DbSetOrder( 4 ) )  // TEW_FILIAL+TEW_NUMPED+TEW_ITEMPV
	If TEW->( DbSeek( xFilial('TEW')+M->C5_NUM+aCols[n][nPosItem] ) )
		lRetorno := .F.
		Help(,,'A410EQLOC',,STR0231,1,0) // 'N�o � permitida altera��o de item para remessa de equipamento para loca��o'
	EndIf
EndIf
If Type("lShowOpc") == "L"
	lShowOpc := .T.
EndIf
Return(lRetorno)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �a410Tipo9 � Autor � Eduardo Riera         � Data � 25.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Condicao de Pagamento Tipo 9                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410Tipo9()

Local aArea     := GetArea()
Local aAreaSE4  := SE4->(GetArea())
Local cParcela  := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local dParc     := Ctod("")
Local nParc     := 0
Local nAux      := 0
Local nTotLib9  := 0
Local nTot9     := 0
Local nTotal    := 0
Local nQtdLib   := 0
Local nQtdVen   := 0
Local nValor    := 0 
Local nY        := 0 
Local nX        := 0       
Local nParcelas := SuperGetMv("MV_NUMPARC")
Local lRet      :=.T.
Local lIpi      := (GetMV("MV_IPITP9") == "S")
Local lMt410Parc:= Existblock("MT410PC")
Local lParc     := .T.
Local lGCT      := !Empty(M->C5_MDNUMED)
Local cChave 	:= ""
Local cChave1	:= ""
Local aAreaSX3	:= SX3->(GetArea())

If lGCT
   	Return(.T.)
EndIf

If nParcelas > 4
	cChave := "C5_DATA"+Subs(cParcela,nParcelas,1)
	cChave1:= "C5_PARC"+Subs(cParcela,nParcelas,1)
	aAreaSX3 := SX3->(GetArea())
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If !DbSeek(cChave) .or. !DbSeek(cChave1)
		Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
		Return(.F.)        
	EndIf
	Restarea(aAreaSX3)
EndIf

If ( ExistBlock("M410TIP9") )
	lRet := ExecBlock("M410TIP9",.F.,.F.)
Else
	
	For nX := 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			For ny := 1 to Len(aHeader)
				If Trim(aHeader[ny][2]) == "C6_QTDVEN"
					nQtdVen := aCols[nx][ny]
				ElseIf Trim(aHeader[ny][2]) == "C6_QTDLIB"
					nQtdLib := aCols[nx][ny]
				ElseIf Trim(aHeader[ny][2]) == "C6_VALOR"
					nValor := aCols[nx][ny]
				EndIf
			Next ny
			
			nTotal   +=  nValor
			nTotLib9 +=  nQtdLib
			nTot9    +=  nQtdVen
		EndIf
	Next nX
	
	nTotal := nTotal + M->C5_FRETE + M->C5_DESPESA + M->C5_SEGURO + M->C5_FRETAUT 
	
	// permite que o numero de parcela possa se manipulado por customiza��o, independente do parametro
	If lMt410Parc
		nParcelas := Execblock("MT410PC",.F.,.F.)
	Endif
	
	For nX:=1 to nParcelas
		nParc := &("M->C5_PARC"+Substr(cParcela,nx,1))
		dParc := &("M->C5_DATA"+Substr(cParcela,nx,1))
		If nParc > 0 .And. Empty(dParc)
			lParc := .F.
		EndIf
		nAux		+= nParc
	Next nX
	
	If !lParc
		Help(" ",1,"A410TIPO9")		
		lRet := .F.		
	Else	
		dbSelectArea("SE4")
		dbSetOrder(1)
		If MsSeek(xFilial()+M->C5_CONDPAG)
			If SE4->E4_TIPO =="9"
				If ( AllTrim(SE4->E4_COND) = "0" .AND. ( ( lIpi .And. NoRound(nTotal,2) > NoRound(nAux,2)) .OR.;
				                                         (!lIpi .And. NoRound(nTotal,2) <> NoRound(nAux,2)) ) ) .OR.;
				   ( AllTrim(SE4->E4_COND) = "%" .AND. nAux # 100 )

					If ( AllTrim(SE4->E4_COND) = "0" .AND. ( ( lIpi .And. NoRound(nTotal,2) > NoRound(nAux,2)) .OR.;
															 (!lIpi .And. NoRound(nTotal,2) <> NoRound(nAux,2))) )
						Help(" ",1,"A410TIPO9")
					Else
						Help(" ",1,"A410TIPO9P")
					EndIf

					If ( ExistBlock("A410VTIP") )
						lRet := ExecBlock("A410VTIP",.F.,.F.,{lRet})
						If ValType(lRet) <> "L"
							lRet := .F.
						EndIf
					EndIf

					If SuperGetMV("MV_TIPO9SP",,.T.)   // Tipo 9 Sem Parcela informada
						If lRet .AND. ( Type("l410Auto") == "U" .or. ! l410Auto )
							lRet := MsgYesNo(OemToAnsi(STR0013),OemToAnsi(STR0014))  //"Confirma a Inclusao do Pedido ?"###"Atencao"
						Else
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf

				EndIf
			EndIf
		EndIf
	EndIf	
Endif

RestArea(aAreaSE4)
RestArea(aArea)
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410MultT � Autor � Eduardo Riera (Rev.)  � Data � 16.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a Validacao dos campos digitados quanto a quantidade���
���          �,preco, desconto e quantidade liberada.                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410MultT(cReadVar,xConteudo,lHelp)

Local aArea     := GetArea()
Local aDadosCfo := {}
Local aContrato := {}                     

Local cEstado   := SuperGetMv("MV_ESTADO")
Local cProdRef  := ""
Local cCliTab   := ""
Local cLojaTab  := ""

Local nPProd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPSegum   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
Local nPQtdLib  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPValDes  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPDescont := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPCFO     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF"})
Local nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPContrat := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItContr := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPDtEnt 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
Local nITEMED   := Ascan(aHeader,{|x| Alltrim(x[2])=="C6_ITEMED"})
Local nPosBlq	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_BLQ"})
Local nPIPITrf	:= Ascan(aHeader,{|x| Trim(x[2]) == "C6_IPITRF"})
Local nPGrdQtd	:= 0
Local nPGrdPrc	:= 0
Local nPGrdTot	:= 0
Local nUsado    := Len(aHeader)
Local nPrcOld   := 0
Local nX        := 0
Local nY        := 0
Local nRecSC6   := 0
Local nQtdOri   := 0
Local nQtdAnt   := 0
Local nLinha    := 0
Local nColuna   := 0
Local nValorTot := 0
Local nQtdOC	:= 0
Local lRetorno  := .T.
Local lGrade    := MaGrade()
Local lGradeReal:= .F.
Local lTabCli   := (SuperGetMv("MV_TABCENT",.F.,"2") == "1")
Local lSC5Tab	:= !Empty(M->C5_TABELA)
Local lCfo      := .F.    
Local cTesVend  := SuperGetMV("MV_TESVEND",,"")
Local lAtuSGJ	:= SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local lGrdMult	:= "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
Local lApiTrib	  := Type('oApiManager') == 'O' .AND. oApiManager:cAdapter == "MATSIMP" //Indica se foi chamada via API de Tributos

//Tratamento para opcionais
Local lOpcPadrao:= SuperGetMv("MV_REPGOPC",.F.,"N") == "N"
Local nPOpcional:= aScan(aHeader,{|x| AllTrim(x[2])==IIf(lOpcPadrao,"C6_OPC","C6_MOPC")})
Local lOpcional := .F.
Local cOpcional	:= ""
Local cOpc		:= ""
Local nPosTes1 	:= 0 
// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec   := SuperGetMV("MV_PRCDEC",,.F.)

Local lBLOQSB6	:= SuperGetMv("MV_BLOQSB6",.F.,.F.) 
Local lLIBESB6 	:= SuperGetMv("MV_LIBESB6",.F.,.F.)
Local l410ExecAuto := (Type("l410Auto") <> "U" .And. l410Auto)

DEFAULT cReadVar := ReadVar()
DEFAULT xConteudo:= &(cReadVar)
DEFAULT lHelp    := .T.

DEFAULT aCols[n][nPTES] := ""

IF cPaisLoc=="BOL"  .AND. FindFunction("ROUNDICEEX")
	ROUNDICEEX(funname(),cReadVar,@xConteudo,@aCols,n,nPQtdVen,nPPrcVen)
ENDIF

//-- Desativa exibi��o de alertas da grade
If lGrdMult
	oGrade:lShowMsgDiff := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Posiciona os registros                                                  �
//��������������������������������������������������������������������������    
If !l410ExecAuto .Or. !__lA410Mta410
	Pergunte("MTA410",.F.)
ElseIf __lA410Mta410 .And. !A410Mta410()
	Pergunte("MTA410",.F.)
	A410Mta410(.T.)
EndIf
dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
dbSetOrder(1)
MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+IIf(!Empty(M->C5_LOJAENT),M->C5_LOJAENT,M->C5_LOJACLI))

cProduto := aCols[n][nPProd]

If lGrade .And.	MatGrdPrrf(@cProduto)   
	cProdRef   := cProduto	
	lGradeReal := .T.
Else
	cProdRef := aCols[n][nPProd]	
Endif

dbSelectArea("SC6")
dbSetOrder(1)
MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n,nPItem]+cProdRef)
If "C6_TES" $ cReadVar

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+xConteudo)
	If !RegistroOk("SF4") .or. IIF( cPaisLoc=="ARG", !A410VldTes(), .F.)
		lRetorno	 := .F.
	Endif
	
Else
	If cPaisLoc == "COL" .And. l410ExecAuto .And. Type("aAutoItens[n]") != "U" .And. Empty(aCols[n,nPTes])
		nPosTes1 := aScan(aAutoItens[n],{|x| AllTrim(x[1]) == "C6_TES"})
		If nPosTes1 > 0
		   	aCols[n][nPTes] := aAutoItens[n][nPosTes1][2]
		EndIf
	EndIf
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[n,nPTes])
	
	If !RegistroOk("SF4")
		lRetorno	 := .F.
	Endif
EndIf       

//������������������������������������������������������������������������Ŀ
//�Efetua as validacoes referente ao que foi alterado                      �
//��������������������������������������������������������������������������
If ( lRetorno .And. "C6_QTDVEN" $ cReadVar )

	If SC6->( Found() )
		//������������������������������������������������������������������������Ŀ
		//�Verifica se o pedido ja foi faturado para inibir alteracao da qtde      �
		//��������������������������������������������������������������������������
		If lGradeReal
			nRecSC6 := SC6->(Recno())
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem])
			SC6->(dbEval({|| nQtdOri += SC6->C6_QTDENT},;
			             Nil,;
			             {|| xFilial("SC6")   == SC6->C6_FILIAL .And.;
			                 M->C5_NUM        == SC6->C6_NUM    .And.;
			                 aCols[n][nPItem] == SC6->C6_ITEM },Nil,Nil,.T.))
	
			SC6->(MsGoto(nRecSC6))
		Else
			nQtdOri := SC6->C6_QTDENT
		Endif	 
			
		If ( xConteudo < nQtdOri )
			If lHelp
				Help(" ",1,"A410PEDJFT")
			Endif	
			lRetorno := .F.
		Else
			//������������������������������������������������������������������������Ŀ
			//�Verifica se ha OP vinculado a este pedido de venda                      �
			//��������������������������������������������������������������������������
			If SC6->C6_OP $ "01#03#05#08"
				If (SuperGetMV("MV_ALTPVOP") == "N") .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
					Help(" ",1,"A410TEMOP")
					lRetorno := .F.
				Else
					If !l410ExecAuto 
						If lAtuSGJ
							lRetorno := A650VldPV()
						Endif
						If lRetorno
							Help(" ",1,"A410ALTPOP")
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRetorno .And. MaTesSel(aCols[n][nPTes])
		aCols[N][nPQtdVen] := 0
		xConteudo := 0
		M->C6_QTDVEN := 0
		If nPSegum > 0
			aCols[n][nPSegum] := 0
		EndIf
	EndIf
	
	//������������������������������������������������������������������������Ŀ
	//�Verifica a integridade da quantidade qdo ha contrato de parceria        �
	//��������������������������������������������������������������������������
	If lRetorno .And. nPContrat > 0 .And. nPItContr > 0
		If !Empty(aCols[n][nPContrat]) .And. !Empty(aCols[n][nPItContr])
			dbSelectArea("ADB")
			dbSetOrder(1)
			If !Empty(aCols[n][nPContrat]) .And. MsSeek(xFilial("ADB")+aCols[n][nPContrat]+aCols[n][nPItContr])
				If Empty(ADB->ADB_PEDCOB)   .And.;
				   ! Empty(ADB->ADB_TESCOB) .AND.;
				   xConteudo <> ADB->ADB_QUANT

					Help(" ",1,"A410CTRQT1")
					lRetorno := .F.
				EndIf
			Else
				aCols[n][nPContrat] := CriaVar("C6_CONTRAT",.F.)
				aCols[n][nPItContr] := CriaVar("C6_ITEMCON",.F.)
			EndIf		
		EndIf

		//������������������������������������������������������������������������Ŀ
		//�Verifica a integridade da quantidade qdo ha contrato de parceria        �
		//��������������������������������������������������������������������������
		If lRetorno .AND. !Empty(aCols[n][nPContrat]) .And. !Empty(aCols[n][nPItContr])
			//������������������������������������������������������Ŀ
			//� Verifica o saldo de contratos deste pedido de venda  �
			//��������������������������������������������������������		
			For nY := 1 To Len(aCols)
				//������������������������������������������������������������������������Ŀ
				//�Busca quantidade do item da Ordem de Carregamento - SIGAAGR -UBS   	   �
				//��������������������������������������������������������������������������
				If AliasIndic("NPN")
					NPN->(dbSetOrder(3))
					If INCLUI .And. IsIncallStack("AGRA900")
						nQtdOC := aCols[nY][nPQtdVen]
					ElseIf ALTERA .And. NPN->(dbSeek(xFilial("NPN")+SC6->(C6_NUM+C6_ITEM)))
						nQtdOC := NPN->NPN_QUANT

					EndIf
				EndIf
	
				If !aCols[nY][nUsado+1] .And. N <> nY .And. !Empty(aCols[nY][nPContrat])
					If ( nX := aScan(aContrato,{|x| x[1] == aCols[nY][nPContrat] .And. x[2] == aCols[nY][nPItContr]}) ) == 0
						aadd(aContrato,{aCols[nY][nPContrat],aCols[nY][nPItContr],aCols[nY][nPQtdVen]})
						nX := Len(aContrato)
					Else
						aContrato[nX][3] += aCols[nY][nPQtdVen]
					EndIf
				EndIf
				dbSelectArea("SC6")
				dbSetOrder(1)
				If MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nY][nPItem]) .And. !Empty(SC6->C6_CONTRAT)
					If ( nX := aScan(aContrato,{|x| x[1] == SC6->C6_CONTRAT .And. x[2] == SC6->C6_ITEMCON}) ) == 0
						aadd(aContrato,{SC6->C6_CONTRAT,SC6->C6_ITEMCON,0})
						nX := Len(aContrato)
					EndIf
					aContrato[nX][3] -= SC6->C6_QTDVEN
				EndIf
			Next nY

			nX := aScan(aContrato,{|x| x[1] == aCols[n][nPContrat] .And. x[2] == aCols[n][nPItContr]})
			dbSelectArea("ADB")
			dbSetOrder(1)
			If !Empty(aCols[n][nPContrat]) .And. MsSeek(xFilial("ADB")+aCols[n][nPContrat]+aCols[n][nPItContr])
				If !(Empty(ADB->ADB_PEDCOB) .And. !Empty(ADB->ADB_TESCOB))
					If xConteudo > ADB->ADB_QUANT - (ADB->ADB_QTDEMP-nQtdOC)-If(nX>0,aContrato[nX][3],0)
						Help(" ",1,"A410CTRQT2")
						lRetorno := .F.
					EndIf
				EndIf 
					
				//������������������������������������������������������������������������Ŀ
				//�Valida quantidade da ordem de carregamento - SIGAAGR(UBS)               �
				//��������������������������������������������������������������������������
				If lRetorno .AND. !Empty(SC6->C6_NUM+SC6->C6_ITEM)
					NPN->(dbSetOrder(3))
					If NPN->(dbSeek(xFilial("NPN")+SC6->(C6_NUM+C6_ITEM))) .AND. xConteudo <> If(nX>0,ABS(aContrato[nX][3]),0)
						Help(" ",1,"A410QTDOC")
						lRetorno := .F.
					EndIf	
				EndIf	 
			Else
				aCols[n][nPContrat] := CriaVar("C6_CONTRAT",.F.)
				aCols[n][nPItContr] := CriaVar("C6_ITEMCON",.F.)

			EndIf

		EndIf
		If lRetorno
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n,nPItem]+aCols[n,nPProd])		
		EndIf
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica as validacoes referente ao que foi alterado                    �
//��������������������������������������������������������������������������
If lRetorno .And. "C6_QTDVEN" $ cReadVar
	lRetorno := FtVldQtVen(aCols[n,nPProd],xConteudo,lHelp,M->C5_TIPO)
	//-- Caso integrado com GCT, valida quantidade com o saldo da planilha.
	If lRetorno .And. !Empty(nITEMED) .And. !Empty(aCols[n,nITEMED]) .And. INCLUI .And. !Empty(M->C5_MDNUMED)
		CNB->(dbSetOrder(1))
		CNB->(dbSeek(xFilial("CNB",cFilCTR)+cContra+cRevisa+cPlan+aCols[n,nITEMED]))
		If M->C6_QTDVEN > CNB->CNB_SLDMED
			Aviso(STR0127,STR0130,{"Ok"}) //SIGAGCT - Esta quantidade excede o saldo da planilha do contrato.
			lRetorno := .F.
		EndIf
	EndIf
	
	If lRetorno .AND. FindFunction("OGX225E") .AND. (SuperGetMV("MV_AGRUBS",.F.,.F.))
		lRetorno := OGX225E()
	EndIf

	//Valida��es referentes � integra��o do OMS com o Cockpit Log�stico Neolog
	If lRetorno .And. (SuperGetMV("MV_CPLINT",.F.,"2") == "1") .And. FindFunction("OMSCPLVlQt")
		lRetorno := OMSCPLVlQt(cReadVar,xConteudo,lHelp)
	EndIf
Endif	

If lRetorno .And. !Empty(nITEMED) .And. !Empty(aCols[n,nITEMED]) .And. INCLUI .And. Empty(M->C5_MDNUMED) .And. ;
									(("C6_PRUNIT" $ cReadVar .And. M->C6_PRUNIT # aCols[n,nPPrUnit]) .Or. ;
									 ("C6_DESCONT" $ cReadVar .And. M->C6_DESCONT # aCols[n,nPDescont]) .Or. ;
									 ("C6_VALDESC" $ cReadVar .And. M->C6_VALDESC # aCols[n,nPValDes]))
	Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto n�o pode ter este campo alterado.
	lRetorno := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica a alteracao do valor unitario quando for poder de terceiro     �
//��������������������������������������������������������������������������
If lRetorno .And. "C6_PRCVEN" $ cReadVar
	If !Empty(nITEMED) .And. INCLUI .And. Empty(M->C5_MDNUMED) .And. !Empty(aCols[n,nITEMED]) .And. M->C6_PRCVEN # aCols[n,nPPrcVen]
		Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto n�o pode ter este campo alterado.
		lRetorno := .F.
	EndIf
	If aCols[n,nPPrcVen] != xConteudo                             .AND.;
	   ( SF4->F4_PODER3 == "D" .And. !Empty(aCols[n,nPIdentB6]) ) .And.;
	   ( lBLOQSB6 .Or. ( !lBLOQSB6 .And. !lLIBESB6 ) )
		Help("",1,"A410VDPDR3",,STR0418,1,0,,,,,,{STR0421})//"Este produto pertence a poder de terceiros, onde o valor unit�rio deve ser condizente o documeto de origem"#"Verifique o valor unit�rio e as configura��es dos parametros MV_BLOQSB6 e MV_LIBESB6 "
		lRetorno := .F.
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Verifica o valor total calculado para este pedido de venda              �
//��������������������������������������������������������������������������
If lRetorno .And. "C6_VALOR" $ cReadVar

	//������������������������������������������������������������������Ŀ
	//�Verifica se eh grade para calcular o valor total por item da grade�
	//��������������������������������������������������������������������
	nValorTot := 0   
	If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
		If lGrdMult
			nValorTot := a410Arred(oGrade:SomaGrade("C6_VALOR",n),"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
		Else   	
			nPGrdQtd := oGrade:GetFieldGrdPos("C6_QTDVEN")
			For nLinha := 1 To Len(oGrade:aColsGrade[n])
				For nColuna := 2 To Len(oGrade:aHeadGrade[n])
					If (  oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
						nValorTot += a410Arred( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*aCols[n,nPPrcVen],"C6_VALOR")
					Endif	
				Next nColuna
			Next nLinha		
		EndIf
	Else 
		nValorTot := A410Arred(aCols[n,nPPrcVen]*aCols[n,nPQtdVen],"C6_VALOR")
	Endif
	
	Do Case
		Case !M->C5_TIPO$"CIPD" .And. SF4->F4_PODER3<>"D"
			If ((xConteudo <> nValorTot .And. !MaTesSel(aCols[n][nPTES])) .Or.; 
			    (xConteudo <> A410Arred(aCols[n,nPPrcVen],"C6_VALOR") .And. MaTesSel(aCols[n][nPTES]))) .And. !(IsInCallStack("CNTA120") .Or. IsInCallStack("CNTA121"))
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			EndIf
		Case M->C5_TIPO=="D" .Or. SF4->F4_PODER3=="D"
			If (Abs(xConteudo - nValorTot ) > 0.49 .And. !MaTesSel(aCols[n][nPTES])) .Or.;		
				(xConteudo <> A410Arred(aCols[n,nPPrcVen],"C6_VALOR") .And. MaTesSel(aCols[n][nPTES]))
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			EndIf
		Case cPaisLoc == "BRA" .And. M->C5_TIPO $ "C" .And. M->C5_TPCOMPL == "2" //Compl. Quantidade
			If	xConteudo <> A410Arred(aCols[n,nPPrcVen]*aCols[n,nPQtdVen],"C6_VALOR")
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			EndIf
		OtherWise
			If xConteudo <> A410Arred(aCols[n,nPPrcVen],"C6_VALOR")
				Help(" ",1,"TOTAL")
				lRetorno := .F.
			EndIf			
	EndCase
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica o valor do desconto                                            �
//��������������������������������������������������������������������������
If lRetorno .AND. At(M->C5_TIPO,"CIP") == 0 .AND.;
   ("C6_VALDESC" $ cReadVar .AND. xConteudo > aCols[n,nPValor]+aCols[n,nPValDes] .Or.;
   "C6_DESCONT" $ cReadVar .AND. xConteudo > 100)
	Help(" ",1,"410VALDESC")
	lRetorno := .F.
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica a TES                                                          �
//��������������������������������������������������������������������������
If lRetorno .And. "C6_TES"$cReadVar
	If xConteudo <> aCols[n,nPTES] .And. SC6->C6_OP $ "01#03#05"
		If (SuperGetMV("MV_ALTPVOP") == "N") .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
			Help(" ",1,"A410TEMOP")
			lRetorno := .F.
		Else
			If !l410ExecAuto
				Help(" ",1,"A410ALTPOP")
			Endif
		EndIf
	EndIf
	If ( SF4->(Found()) .And. xConteudo > "500" )
		//������������������������������������������������������Ŀ
		//� Verifica se tes for de poder de terceiros o tipo do  �
		//� pedido so pode ser N ou B                            �
		//��������������������������������������������������������
		If ( SF4->F4_PODER3 $ "RD" .And. M->C5_TIPO == "D" )
			Help(" ",1,"A410PODER3")
			lRetorno := .F.
		EndIf
		//������������������������������������������������������Ŀ
		//� Verifica se e' um item de grade e o Tes se refere    �
		//� a poder de terceiros                                 �
		//��������������������������������������������������������
		If ( SF4->F4_PODER3 $ "RD" ) .AND. ( MatGrdPrrf(aCols[n,nPProd]) )
			Help(" ",1,"A410GRATER")
			lRetorno := .F.
		EndIf
		//������������������������������������������������������Ŀ
		//� Se a TES for uma devolu��o de poder de terceiros,    �
		//� n�o permitte eliminar res�duo manualmente (C6_BLQ).  �
		//��������������������������������������������������������
		If ( SF4->F4_PODER3 $ "D" .And. "R" $ aCols[n,nPosBlq] )
			Help(" ",1,"A410RESDEV",,STR0228,1,1)	//"N�o � permitido eliminar res�duo de uma devolu��o de poder de terceiros."
			lRetorno := .F.
		EndIf
	Else
		If (cPaisLoc == "RUS" .And. empty(AllTrim(xConteudo)))
			lRetorno := .T.
		Else
			Help (" ",1,"A410NOTES")
			lRetorno := .F.
		EndIf
	EndIf
	If lRetorno .And. MaTesSel(xConteudo)
		aCols[N][nPQtdVen] := 0
		If nPSegum > 0
			aCols[n][nPSegum] := 0
		EndIf
		aCols[N][nPValor] := aCols[N][nPPrcVen]
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica a data de Entrega                                              �
//��������������������������������������������������������������������������
If lRetorno .And. "C6_ENTREG" $ cReadVar .AND. xConteudo <> aCols[n,nPDtEnt]
	//������������������������������������������������������������������������Ŀ
	//�Verifica se ha OP vinculado a este pedido de venda                      �
	//��������������������������������������������������������������������������
	If SC6->C6_OP $ "01#03#05#08"
		If (SuperGetMV("MV_ALTPVOP") == "N") .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
			Help(" ",1,"A410TEMOP")
			lRetorno := .F.
		Else
			If !l410ExecAuto
				Help(" ",1,"A410ALTPOP")
			EndIf
		EndIf
	EndIf	
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica o tipo de bloqueio                                             �
//��������������������������������������������������������������������������
If lRetorno                          .And.;
   "C6_BLQ" $ cReadVar               .AND.;
   xConteudo <> aCols[n,nPosBlq]     .AND.;
   ( ! Empty(aCols[n,nPTes])         .AND.;
     SF4->F4_PODER3 $ "D"            .AND.;
	 "R" $ xConteudo )

	Help(" ",1,"A410RESDEV",,STR0228,1,1)	//"N�o � permitido eliminar res�duo de uma devolu��o de poder de terceiros."
	lRetorno := .F.

Endif

//������������������������������������������������������������������������Ŀ
//�Dispara as atualizacoes com base nos dados alterados                    �
//��������������������������������������������������������������������������
If lRetorno
	Do Case
		Case "C6_PRCVEN"$cReadVar .And. (At(M->C5_TIPO,"CPI") == 0 .Or. (cPaisLoc == "BRA" .And. AllTrim(M->C5_TIPO) == "C" .And. M->C5_TPCOMPL == "2")) 
			//������������������������������������������������������������������Ŀ
			//�Verifica se eh grade para calcular o valor total por item da grade�
			//��������������������������������������������������������������������   
		   	If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
		   		If lGrdMult
		   			aCols[n,nPValor] := a410Arred(oGrade:SomaGrade("C6_VALOR",n),"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					If !l410ExecAuto
						oGrade:ZeraGrade("C6_VALDESC",n)
						aCols[n,nPValDes] := 0
						aCols[n,nPDescont]:= 0
					EndIf
		   		Else
		   			aCols[n,nPValor] 	:= 0          
					nPGrdQtd 			:= oGrade:GetFieldGrdPos("C6_QTDVEN")   			
					For nLinha := 1 To Len(oGrade:aColsGrade[n])
						For nColuna := 2 To Len(oGrade:aHeadGrade[n])
							If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
								aCols[n,nPValor]  += a410Arred( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*xConteudo,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							EndIf
						Next nColuna
					Next nLinha		
				EndIf
			Else	
				aCols[n,nPValor]  := a410Arred(xConteudo * aCols[n,nPQtdVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
				If !l410ExecAuto .And. M->C5_TIPO <> "D"
					aCols[n,nPValDes] := 0
					aCols[n,nPDescont]:= 0
				EndIf
			Endif	
		Case "C6_QTDVEN"$cReadVar .And. ( At(M->C5_TIPO,"CPI") == 0 .Or. ( cPaisLoc == "BRA" .And. AllTrim(M->C5_TIPO) == "C" .And. M->C5_TPCOMPL == "2" )) 
			If xConteudo <> aCols[n,nPQtdVen] .Or. (lGrade .And. lGradeReal)		
				nQtdAnt            := aCols[n,nPQtdVen]				
				aCols[n,nPQtdVen ] := xConteudo
				If M->C5_TIPO=="N" .And. ( lSC5Tab .Or. aCols[n,nPPrcVen]==0 ) .And. SF4->F4_PODER3<>"D" .And. !(lGrdMult .And. lGrade .And. lGradeReal)
					If lTabCli
						Do Case
							Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
								cCliTab   := M->C5_CLIENT
								cLojaTab  := M->C5_LOJAENT
							Case Empty(M->C5_CLIENT) 
								cCliTab   := M->C5_CLIENTE
								cLojaTab  := M->C5_LOJAENT
							OtherWise
								cCliTab   := M->C5_CLIENTE
								cLojaTab  := M->C5_LOJACLI
						EndCase					
					Else
						cCliTab   := M->C5_CLIENTE
						cLojaTab  := M->C5_LOJACLI
					Endif
			
					nPrcOld := A410Tabela(	aCols[n,nPProd],;
											M->C5_TABELA,;
											n,;
											xConteudo,;
											cCliTab,;
											cLojaTab,;
											If(nPLoteCtl>0,aCols[n,nPLoteCtl],""),;
											If(nPNumLote>0,aCols[n,nPNumLote],""),;
											,;
											,;
											lSC5Tab )
										
					lOpcional := (nPOpcional > 0 .And. !Empty(aCols[n,nPOpcional]))	//Valida se j� foi escolhido um opcional
			 
					If nPrcOld<>aCols[n,nPPrUnit] .And. !lOpcional
						aCols[n,nPPrUnit]  := IIF(nPrcOld == 0, aCols[n,nPPrUnit], nPrcOld) 
						aCols[n,nPValDes]  := 0
						aCols[n,nPDescont] := 0
					EndIf
					If aCols[n,nPPrUnit] <> 0 
						aCols[n,nPPrcVen]  := FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))	
					EndIf
				EndIf                                                
			
			   	If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
			   		If lGrdMult
			   			aCols[n,nPValor] := a410Arred(oGrade:SomaGrade("C6_VALOR" ,n),"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
			   			aCols[n,nPPrUnit]:= a410Arred(oGrade:SomaGrade("C6_PRUNIT",n),"C6_PRUNIT",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
			   		Else
				   		aCols[n,nPValor]	:= 0
				   		nPGrdQtd 			:= oGrade:GetFieldGrdPos("C6_QTDVEN") 
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])
								If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
									aCols[n,nPValor]  += a410Arred(oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*aCols[n,nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Endif	
							Next nColuna
						Next nLinha		
					EndIf
				Else	
					aCols[n,nPValor]   := a410Arred(aCols[n,nPPrcVen] * xConteudo,"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
				Endif 
	
				If nPDescont > 0 .And. nPValDes > 0
					If M->C5_TIPO == "N"
						aCols[n,nPDescont] := FtRegraDesc(1)
						If !(lGrdMult .And. lGrade .And. lGradeReal)
							If aCols[n,nPDescont]<>0 .And. nPPrUnit <> 0
								aCols[n,nPPrcVen] := FtDescItem(FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4}),@aCols[n,nPPrcVen],xConteudo,@aCols[n,nPValor],@aCols[n,nPDescont],@aCols[n,nPValDes],@aCols[n,nPValDes],1,nQtdAnt,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							Else
								If aCols[n,nPPrUnit] > 0 .And. !(IsInCallStack("Ft400Pv"))
									aCols[n,nPPrcVen]  := FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
									aCols[n,nPValor]   := a410Arred(aCols[n,nPPrcVen] * aCols[n,nPQtdVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Else
									//��������������������������������������������������������������Ŀ
									//�Calculo o Preco de Lista quando nao houver tabela de preco    �
									//����������������������������������������������������������������
									aCols[n,nPPrcVen] += a410Arred(aCols[n][nPValDes]/nQtdAnt,"C6_VALOR")
									aCols[n,nPValor]  := a410Arred(aCols[n,nPPrcVen] * aCols[n,nPQtdVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								EndIf
								aCols[n][nPValDes] := 0
							EndIf
							If cPaisLoc $ "CHI|PAR" .And. lPrcDec
								aCols[n,nPPrcVen] := a410Arred(aCols[n,nPPrcVen],"C6_PRUNIT",M->C5_MOEDA)
							EndIf
						EndIf
					ElseIf M->C5_TIPO == "D"
						aCols[n][nPValDes] := a410Arred( ( aCols[n,nPPrUnit] - ( aCols[n,nPValor] / IIf( xConteudo==0, 1, xConteudo ) ) ) * a410Arred( xConteudo, "C6_QTDVEN" ), "C6_VALDESC" )
						aCols[n,nPPrcVen] := a410Arred( aCols[n,nPValor] / IIf( xConteudo==0, 1, xConteudo ), "C6_PRCVEN" )
						
						MT410ItDev(@acols, M->C5_CLIENTE, M->C5_LOJACLI) //Recalcula os valores da linha de acordo com a nota de origem
					EndIf
				EndIf
				If nPOpcional > 0 .And. !Empty(aCols[n,nPOpcional]) .And. aCols[n,nPPrUnit] > 0
					//��������������������������������������������������������������Ŀ
					//� Aqui � efetuado o tratamento diferencial de Precos para os   �
					//� Opcionais do Produto.                                        �
					//����������������������������������������������������������������
					dbSelectArea("SGA")
					dbSetOrder(1)
					cOpcional := aCols[n,nPOpcional]
					While !Empty(cOpcional)
						cOpc      := SubStr(cOpcional,1,At("/",cOpcional)-1)
						cOpcional := SubStr(cOpcional,At("/",cOpcional)+1)
						If ( MsSeek(xFilial("SGA")+cOpc) ) .AND. AT(M->C5_TIPO,"CIP") == 0
							aCols[n][nPPrcVen] += SGA->GA_PRCVEN
							aCols[n,nPValor]   := A410Arred(aCols[n][nPPrcVen]*aCols[n,nPQtdVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcdec,M->C5_MOEDA,NIL))
						EndIf
					EndDo					
				EndIf		
			EndIf
			If ( MV_PAR01 ==1 )
				MaIniLiber(M->C5_NUM,xConteudo-SC6->C6_QTDENT,n)
			EndIf
			If nPIPITrf > 0 .And. aCols[n][nPIPITrf] > 0
				TransBasImp(.T.)
			EndIf	
		Case "C6_DESCONT"$cReadVar .And. At(M->C5_TIPO,"CPI") == 0
			If At(M->C5_TIPO,"CIP") == 0
				If !(lGrdMult .And. lGrade .And. lGradeReal)
					aCols[n,nPPrcVen] := FtDescItem(FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4}),@aCols[n,nPPrcVen],aCols[n,nPQtdVen],@aCols[n,nPValor],@xConteudo,@aCols[n,nPValDes],@aCols[n,nPValDes],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					If cPaisLoc $ "CHI|PAR" .And. lPrcDec
						aCols[n,nPPrcVen] := A410Arred(aCols[n,nPPrcVen],"C6_PRCVEN",M->C5_MOEDA)
					EndIf
				EndIf
				//������������������������������������������������������������������Ŀ
				//�Verifica se eh grade para calcular o valor total por item da grade�
				//��������������������������������������������������������������������
				If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
					If lGrdMult
						//���������������������������������������������������������������Ŀ
						//�Atualiza o preco unitario na grade e tambem os totais no aCols �
						//�����������������������������������������������������������������
						nPGrdQtd := oGrade:GetFieldGrdPos("C6_QTDVEN")
						nPGrdPrc := oGrade:GetFieldGrdPos("C6_PRCVEN")
						nPGrdTot := oGrade:GetFieldGrdPos("C6_VALOR")
						nPGrdVDe := oGrade:GetFieldGrdPos("C6_VALDESC")
						
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])
								If !Empty(oGrade:aColsGrade[n,nLinha,nColuna][nPGrdPrc] > 0)
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc] := FtDescItem(0,@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc],oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd],@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot],@xConteudo,@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe],@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Endif	
							Next nColuna
						Next nLinha
						
						aCols[n,nPPrcVen] := oGrade:SomaGrade("C6_PRCVEN",n)
						aCols[n,nPValor]  := oGrade:SomaGrade("C6_VALOR",n)
						aCols[n,nPValDes] := oGrade:SomaGrade("C6_VALDESC",n)
					Else
			   			aCols[n,nPValor]	:= 0 
						nPGrdQtd			:= oGrade:GetFieldGrdPos("C6_QTDVEN")	   			
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])
								If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
									aCols[n,nPValor]  += a410Arred(oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*aCols[n,nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Endif	
							Next nColuna
						Next nLinha
					EndIf 
				Endif 
			Else
				aCols[n][nPDescont] := 0
				aCols[n][nPValDes] := 0
				M->C6_DESCONT := 0
			EndIf
		Case "C6_VALDESC"$cReadVar .And. At(M->C5_TIPO,"CPI") == 0
			If At(M->C5_TIPO,"CIP") == 0
				If !(lGrdMult .And. lGrade .And. lGradeReal)
					If M->C5_TIPO == "D" .And. aCols[n][nPPrUnit] <> 0 .And. aCols[n][nPPrUnit] <> aCols[n,nPPrcVen]
						MT410ItDev(@acols, M->C5_CLIENTE, M->C5_LOJACLI) //Recalcula os valores da linha de acordo com a nota de origem
						xConteudo := aCols[n,nPValDes]
					Else
						aCols[n,nPPrcVen] := FtDescItem(FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4}),@aCols[n,nPPrcVen],aCols[n,nPQtdVen],@aCols[n,nPValor],@aCols[n,nPDescont],@xConteudo,aCols[n,nPValDes],2,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
					EndIf
				EndIf
				M->C6_VALDESC := xConteudo
				//������������������������������������������������������������������Ŀ
				//�Verifica se eh grade para calcular o valor total por item da grade�
				//��������������������������������������������������������������������  
				If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
					If lGrdMult
						nPGrdQtd := oGrade:GetFieldGrdPos("C6_QTDVEN")	   			
						nPGrdPrc := oGrade:GetFieldGrdPos("C6_PRCVEN")
						nPGrdTot := oGrade:GetFieldGrdPos("C6_VALOR")
						nPGrdVDe := oGrade:GetFieldGrdPos("C6_VALDESC")
										
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])                               
								If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
									//-- Retorna ao valor original para poder ratear
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot] += oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe]
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc] := A410Arred(oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot] / oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd],"C6_PRCVEN")
	
	                                //-- Rateia valor de desconto a partir do valor total dos itens
									nPrcOld := ((oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot]*100) / (aCols[n,nPValor]+aCols[n][nPValDes])/100) //Rateia C6_VALDESC
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe] := A410Arred(xConteudo*nPrcOld,"C6_VALDESC")
									
									oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc] := FtDescItem(0,@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdPrc],oGrade:aColsGrade[n,nLinha,nColuna,nPGrdQtd],@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdTot],@aCols[n,nPDescont],@oGrade:aColsGrade[n,nLinha,nColuna,nPGrdVDe],0,2,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Endif	
							Next nColuna
						Next nLinha
						
						aCols[n,nPPrcVen] := oGrade:SomaGrade("C6_PRCVEN",n)
						aCols[n,nPValor]  := oGrade:SomaGrade("C6_VALOR",n)
						aCols[n,nPValDes] := oGrade:SomaGrade("C6_VALDESC",n)
					Else
			   			aCols[n,nPValor]	:= 0
						nPGrdQtd			:= oGrade:GetFieldGrdPos("C6_QTDVEN")	   			
						For nLinha := 1 To Len(oGrade:aColsGrade[n])
							For nColuna := 2 To Len(oGrade:aHeadGrade[n])
								If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
									aCols[n,nPValor]  += a410Arred(oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*aCols[n,nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
								Endif	
							Next nColuna
						Next nLinha
					EndIf
				Endif	  
			Else
				aCols[n][nPDescont] := 0
				aCols[n][nPValDes] := 0
				M->C6_VALDESC := 0
			EndIf
		Case "C6_BLQ" $ cReadVar .And. At(M->C5_TIPO,"CPI") == 0
			aCols[n][nPQtdLib] := 0
		Case "C6_PRODUTO" $ cReadVar .And. At(M->C5_TIPO,"CPI") == 0
			If xConteudo<>aCols[n,nPProd] .And. nPDescont > 0 .And. nPValDes > 0 .And. M->C5_TIPO=="N"
				aCols[n,nPDescont] := FtRegraDesc(1)
				If aCols[n,nPDescont]<>0 .And. nPPrUnit <> 0
					aCols[n,nPPrcVen] := FtDescItem(FtDescCab(aCols[n,nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4}),@aCols[n,nPPrcVen],aCols[n,nPQtdVen],@aCols[n,nPValor],@aCols[n,nPDescont],@aCols[n,nPValDes],@aCols[n,nPValDes],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
				Else
					aCols[n,nPDescont] := 0
					aCols[n,nPValDes ] := 0
				EndIf
			EndIf
		Case "C6_TES" $ cReadVar
			//�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	   		//�A Consultoria Tribut�ria, por meio da Resposta � Consulta n� 268/2004, determinou a aplica��o das seguintes al�quotas nas Notas Fiscais de venda emitidas pelo vendedor remetente:                                                                         �
	   		//�1) no caso previsto na letra "a" (venda para SP e entrega no PR) - aplica��o da al�quota interna do Estado de S�o Paulo, visto que a opera��o entre o vendedor remetente e o adquirente origin�rio � interna;                                              �
   			//�2) no caso previsto na letra "b" (venda para o DF e entrega no PR) - aplica��o da al�quota interestadual prevista para as opera��es com o Paran�, ou seja, 12%, visto que a circula��o da mercadoria se d� entre os Estado de S�o Paulo e do Paran�.       �
  			//�3) no caso previsto na letra "c" (venda para o RS e entrega no SP) - aplica��o da al�quota interna do Estado de S�o Paulo, uma vez que se considera interna a opera��o, quando n�o se comprovar a sa�da da mercadoria do territ�rio do Estado de S�o Paulo,�
  			//� conforme previsto no art. 36, � 4� do RICMS/SP                                                                                                                                                                                                            �
  			//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

			If cEstado == 'SP'
				If !Empty(M->C5_CLIENT) .And. M->C5_CLIENT <> M->C5_CLIENTE 			
					For nX := 1 To Len(aCols)
			   			If Alltrim(aCols[nX][nPTES])$ Alltrim(cTesVend) .Or. SF4->F4_CODIGO $ Alltrim(cTesVend)
			 				lCfo:= .T.
			 			EndIf
			   		Next 
			   		If lCfo
						dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
						dbSetOrder(1)           
						MsSeek(xFilial()+M->C5_CLIENTE+M->C5_LOJAENT)
						If Iif(M->C5_TIPO$"DB", SA2->A2_EST,SA1->A1_EST) <> 'SP'
							MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT) 
						Else
	 				   		If cPaisLoc=="BRA"
								For nX := 1 To Len(aCols)
				   					If Len(aCols)>1
			 							Aadd(aDadosCfo,{"OPERNF","S"})
			 							Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})					
			 							Aadd(aDadosCfo,{"UFDEST",Iif(M->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST)})
			 							Aadd(aDadosCfo,{"INSCR" ,If(M->C5_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)})		 			 	
										Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
										Aadd(aDadosCfo,{"FRETE" ,M->C5_TPFRETE})

										aCols[nX,nPCFO] := MaFisCfo(,Iif(!Empty(aCols[nX,nPCFO]),aCols[nX,nPCFO],SF4->F4_CF),aDadosCfo)
									EndIf
				   				Next
		 		   			EndIf
						EndIf
					EndIf 
				EndIf
			 EndIF
			 
			//������������������������������������������������������Ŀ
			//�Preenche o CFO                                        �
			//��������������������������������������������������������
			If !(cPaisLoc $ "BRA/RUS" )
				aCols[n,nPCFO]:=AllTrim(SF4->F4_CF)
			ElseIf cPaisLoc=="BRA" // Not Used in Russia         
			 	Aadd(aDadosCfo,{"OPERNF","S"})
			 	Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})					
			 	Aadd(aDadosCfo,{"UFDEST",Iif(M->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST)})
			 	Aadd(aDadosCfo,{"INSCR" ,If(M->C5_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)})
 			 	Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})

			 	Aadd(aDadosCfo,{"FRETE" ,M->C5_TPFRETE})	
				aCols[n,nPCFO] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			EndIf
		Case "C6_PRUNIT" $ cReadVar .AND. ( ( !l410ExecAuto )  .OR.  ( l410ExecAuto .And. (aCols[n,nPValor] == 0 .Or. lApiTrib)) )
			If !(lGrdMult .And. lGrade .And. lGradeReal)
				aCols[n,nPPrcVen] := FtDescItem(FtDescCab(M->C6_PRUNIT,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4}),@aCols[n,nPPrcVen],aCols[n,nPQtdVen],@aCols[n,nPValor],@aCols[n,nPDescont],@aCols[n,nPValDes],@aCols[n,nPValDes],1,,If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
			EndIf
			//������������������������������������������������������������������Ŀ
			//�Verifica se eh grade para calcular o valor total por item da grade�
			//�������������������������������������������������������������������� 
		   	If lGrade .And. lGradeReal .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade) > 0
		   		If lGrdMult
		   			&(cReadVar) := 0
		   		Else
					aCols[n,nPValor]	:= 0
					nPGrdQtd			:= oGrade:GetFieldGrdPos("C6_QTDVEN")	   			
					For nLinha := 1 To Len(oGrade:aColsGrade[n])
						For nColuna := 2 To Len(oGrade:aHeadGrade[n])
							If ( oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd] <> 0 )
								aCols[n,nPValor]  += a410Arred(oGrade:aColsGrade[n,nLinha,nColuna][nPGrdQtd]*aCols[n,nPPrcVen],"C6_VALOR",If(cPaisLoc $ "CHI|PAR" .And. lPrcDec,M->C5_MOEDA,NIL))
							Endif	
						Next nColuna
					Next nLinha
				EndIf
			Endif	  
	EndCase
	If cPaisLoc == "BRA"
		If M->C5_TIPO $ "C" .And. Empty(M->C5_TPCOMPL)
			Help(" ",1,"A410COMPRQ")
			lRetorno := .F.		
		ElseIf ( M->C5_TIPO $ "IP" ) .Or. ( M->C5_TIPO $ "C" .And. M->C5_TPCOMPL == "1"	)	//Compl. Pre�o  
			M->C6_QTDVEN := 0
			aCols[n,nPQtdVen] := 0
		EndIf
	Else
		If ( M->C5_TIPO $ "CIP" )
			M->C6_QTDVEN := 0
			aCols[n,nPQtdVen] := 0
		EndIf
	EndIf
EndIf

If lRetorno .And. cPaisLoc == "BRA" .And. cEstado == "RN" .And. ("C6_PRODUTO" $ cReadVar .Or. "C6_TES" $ cReadVar)
	a410FrPIte(cReadVar,xConteudo)
Endif

//-- Desativa exibi��o de alertas da grade
If lGrdMult
	oGrade:lShowMsgDiff := .F.
EndIf

If lRetorno .And. !IsInCallStack("A410LOTCTL") .And. nPLoteCtl > 0 .And. !Empty(acols[n][nPLoteCtl]) .And. ("C6_QTDVEN" $ cReadVar)
	lRetorno := A410LotCTL()
	If !lRetorno .And. MV_PAR01 == 1	//Sugere Qtd.Liberada
		aCols[n,nPValor]  := A410Arred(aCols[n,nPPrcVen] * nQtdAnt,"C6_VALOR")
		aCols[n,nPQtdLib] := nQtdAnt
	EndIf
EndIf

If cPaisLoc == "RUS"
	MaFisRef("IT_VALMERC","MT410",aCols[n,nPValor]) 
EndIf

RestArea(aArea)
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A410VldPrj� Autor � Edson Maricate        � Data � 22/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do codigo da tarefa digitada.                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA410                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410VldPrj()

Local lRet	:= .F.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local nPosEDT	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_EDTPMS" 	.Or.	Alltrim(x[2])=="D2_EDTPMS"})
Local nPosTrf	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_TASKPMS"	.Or.	Alltrim(x[2])=="D2_TASKPMS"})
Local cContVar	:=	&(ReadVar())
Local SnTipo   
Local lVldCgfNf := cPaisLoc<>"BRA" .And. Type("aCfgNF")=="A" .And. Len(aCfgNF)>0
Local lNFCred   := .F. // Nota de Cr�dito para paises Localizados

//////////////////////////////////
// Somente para paises Localizados
If lVldCgfNf
	//////////////////////////////////////////////////
	// Provem de um define da LocxNF.prw - LocxDlgNF()
	SnTipo  := If( Type("_SnTipo")<>"U",_SnTipo,1) 
	
	//////////////////////////////////////////
	// Definidas em LocxNf.prw
	// 7 = NCP - Nota de Credito do Fornecedor
	// 8 = NDI - Nota de Debito Interna
	lNFCred := aCfgNF[SnTipo]==7 .Or. aCfgNF[SnTipo]==8
Endif

AF8->(dbSetOrder(1))
If AF8->(dbSeek(xFilial()+aCols[n][aScan(aHeader,{|x| Alltrim(x[2])=="C6_PROJPMS" .Or. Alltrim(x[2])=="D2_PROJPMS"})]))
	If AllTrim(ReadVar())=="M->C6_TASKPMS" .Or. AllTrim(ReadVar())=="M->D2_TASKPMS"
		AF9->(dbSetOrder(1))
		If AF9->(dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+cContVar))
			// tarefa pode ser faturada
			If	lNFCred .Or. (AF9->(AF9_FATURA) =="1") // Faturavel
				lRet := .T.
				If nPosEDT > 0
					aCols[n][nPosEDT]	:= SPACE(LEN(AFC->AFC_EDT))
				EndIf
			Else                          				
				HELP("   ",1,"VLDTSKRFAT")
			EndIf
		Else
			HELP("   ",1,"EXISTCPO")
		EndIf             
	Else
		AFC->(dbSetOrder(1))
		If AFC->(dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+cContVar))
			// EDT pode ser faturada
			If AFC->(AFC_FATURA) =="1" 
				lRet := .T.
				aCols[n][nPosTrf]	:= SPACE(LEN(AF9->AF9_TAREFA))
			Else
				HELP("   ",1,"VLDEDTFAT")
			EndIf
		Else
			HELP("   ",1,"EXISTCPO")
		EndIf
	EndIf
Else
	HELP("   ",1,"EXISTCPO")
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)
Return lRet         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A410VldFab� Autor � Eduardo Riera         � Data �05.01.99  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Fabricante no Mata410                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Logico                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A410VldFab()

Local aArea 	:= GetArea()
Local lRetorno := .F.
Local nPosFab  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CODFAB"})
Local nPosLoja := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOJAFA"})
Local cRead 	:= ReadVar()
Local cVariavel:= &(ReadVar())

If ( nPosFab > 0 .And. nPosLoja > 0 )
	dbSelectArea("SA1")
	dbSetOrder(1)	
	If ( "_LOJAFA"$cRead )
		If ( MsSeek(xFilial("SA1")+aCols[n][nPosFab]+cVariavel) )
			lRetorno := .T.
		EndIf
	Else
		If ( SA1->A1_COD == cVariavel .Or. MsSeek(xFilial("SA1")+cVariavel) )
			aCols[n][nPosLoja] := SA1->A1_LOJA
			lRetorno := .T.
		EndIf
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Retorna as condicoes de entrada                                         �
//��������������������������������������������������������������������������
RestArea(aArea)

If ( !lRetorno )
	Help(" ",1,"REGNOIS")
EndIf
Return(lRetorno)            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �a410VldPMS� Autor � Reynaldo Miyashita    � Data �14.06.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina para validar as colunas do browse de itens no pedido ���
���          � de venda. Colunas de Projeto, EDT e Tarefa referentes      ���
���          � ao sigapms                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lOk - Se as colunas do browse estao certas                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cC6_PROJPMS - projeto a ser validado                       ���
���          � cC6_EDTPMS  - codigo da EDT a ser validada                 ���
���          � cC6_TASKPMS - codigo da tarefa a ser validada              ���
���          � cMovPrj     - movimentacao do projeto(SF4->F4_MOVPRJ)      ���
���          � cC5_TIPO    - tipo do pedido de venda                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a410VldPMS( cC6_PROJPMS ,cC6_EDTPMS ,cC6_TASKPMS, cMovPrj, cC5_TIPO)

Local lOk   := .T.
Local aArea := GetArea()
Local nX		:= 0
Local cCNO		:= M->C5_CNO
Local cCampo	:= ReadVar()
Local nPosProj:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROJPMS"})

DEFAULT cC6_PROJPMS	:= ""
DEFAULT cC6_EDTPMS	:= ""
DEFAULT cC6_TASKPMS	:= ""
DEFAULT cMovPrj		:= "1"
DEFAULT cC5_TIPO		:= ""

If cCampo == "M->C5_CNO" .AND. !Empty(cCNO) .AND. AF8->(ColumnPos("AF8_CNO"))>0
	dbSelectArea("AF8")
	AF8->(dbSetOrder(1))	
	For nx := 1 to Len(aCols)
		If AF8->(dbSeek(xFilial("AF8")+aCols[nX][nPosProj])) .AND. cCNO <> AF8->AF8_CNO
			HELP("   ",1,"VLDCNO",,STR0334 + aCols[nX][nPosProj] ,1) //"Este CNO n�o corresponde ao do projeto: "
			lOk := .F.
		EndIf	
	Next 
Else
	If !Empty(cC6_PROJPMS) //Verifca se esta amarrado ao projeto
	
		AF8->(dbSetOrder(1))
		If AF8->(dbSeek(xFilial("AF8")+cC6_PROJPMS ))
			
			If !Empty(cCNO) .AND. AF8->(ColumnPos("AF8_CNO"))>0 .AND. cCNO <> AF8->AF8_CNO
				HELP("   ",1,"VLDCNO",,STR0335 ,1) //"O CNO informado no cabe�alho n�o corresponde com o deste projeto."
				lOk := .F.
			EndIf
			
			If lOk
				Do Case
					
					Case (!Empty(cC6_EDTPMS) .AND. !Empty(cC6_TASKPMS))
						//EDT e Tarefa preenchidas
						HELP("   ",1,"VLDPMSFAT",,STR0088 + CRLF + STR0089 ,1) //"N�o pode existir refer�ncia do C�digo da" " EDT e Codigo da Tarefa no mesmo item."
						lOk := .F.
		
					Case (Empty(cC6_EDTPMS) .AND. Empty(cC6_TASKPMS))
						//EDT e Tarefa naum preenchidas
						HELP("   ",1,"VLDTSKEXIST",,STR0110 ,1) //"O item de venda n�o pode estar amarrado unicamente a um projeto!"
						lOk := .F.
		
					Case ( cC5_TIPO=="D" .And. !(cMovPrj=="4") )
						//pedido de devolucao de compra e TES nao eh de Devolucao do Projeto
						HELP("   ",1,"VLDPRJDEV",,STR0112,1) //"A TES deve ser de Devolucao de Despesa do projeto! Verifique a TES!"
						lOk := .F.
						
					Case !Empty(cC6_EDTPMS)
						//EDT preenchida
						AFC->(DbSetOrder(1))
						If AFC->(DbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+cC6_EDTPMS ))
							// a EDT eh faturavel
							If AFC->AFC_FATURA=="1"
								lOk := .T.
							Else
								HELP("   ",1,"VLDEDTFAT")
								lOk := .F.
							EndIf
						Else
							HELP("   ",1,"VLDEDTEXIST",,STR0090 ,1) //"O C�digo da EDT informado n�o existe."
							lOk := .F.
						EndIf
					
					Case !Empty(cC6_TASKPMS)
						//Tarefa preenchida
			        	AF9->(dbSetOrder(1))
						If AF9->(dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+cC6_TASKPMS ))
							// a TAREFA eh faturavel
							If AF9->AF9_FATURA <> "1"
								HELP("   ",1,"VLDTSKRFAT") //Esta tarefa nao tem permissao para ser faturada.
								lOk := .F.
							EndIf
						Else
							HELP("   ",1,"VLDTSKEXIST",,STR0091 ,1) //"O C�digo de Tarefa informado n�o existe."
							lOk := .F.
						EndIf
				EndCase
			EndIf
		Else
			//O projeto nao existe
			HELP("   ",1,"VLDPRJEXIST",,STR0092 ,1) //"O C�digo de Projeto informado n�o existe."
			lOk := .F.
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return( lOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProvEntPV � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza os itens do Pedido de Venda e Valida Provincia     ���
���          � informada no cabecalho.                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProvEntPV()

Local lRet := .T.
Local nX   := 0
Local nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROVENT"})
Local nPosTes := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})
Local cCpo     := ""
Local cProv    := ""
Local cTes     := ""
Local nProv    := 0

lRet := Vazio() .Or. M->C5_PROVENT == "99" .Or. ExistCpo("SX5","12"+M->C5_PROVENT) 

If lRet .And. nPosProv > 0
	cCpo  := ReadVar()
	cProv := &cCpo
	For nX := 1 to Len(aCols)
		cTes := aCols[nX,nPosTes]
		If VerProEnIt(cProv,cTes,.F.,.F.)
			aCols[nX,nPosProv]:= cProv
		Else
			nProv++
		endif
	Next
	If Type('oGetDad:oBrowse')<>"U"
		oGetDad:oBrowse:Refresh()
	Endif
	If nProv > 0
		MsgAlert(STR0117,STR0118)//("Alguns itens n�o tiveram a prov�ncia alterada pois possuem impostos gravados em um mesmo campo.","Aten��o")
	Endif
Endif 
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProEntItPV� Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza a provincia de entrega						      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProEntItPV()

Local lRet		:= .T.
Local nPosTes	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})
Local cCpo		:= ""
Local cProv		:= ""

If nPosTes > 0
	cCpo  := ReadVar()
	cProv := &cCpo
	lRet  := ValProvEnt(cProv,aCols[n,nPosTes])
Endif
Return lRet      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProEntItPV� Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza/Valida o TES									      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProvTesPV()

Local lRet		:= .T.
Local nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == "C6_PROVENT"})
Local cCpo		:= ""
Local cProv		:= ""

cCpo  := ReadVar()
cTes := &cCpo
If nPosProv > 0
	cProv := aCols[n,nPosProv]
	lRet := VerProEnIt(cProv,cTes,.T.,.F.)
Endif
Return lRet   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A410SitTrib�Autor  � Vendas/CRM        � Data �  06/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o utilizada para posicionar as tabelas SB1 e SF4 no   ���
���          � X3_VALID dos campos C6_OPER e C6_TES.                      ���
�������������������������������������������������������������������������͹��
���Uso       � MATA410A                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A410SitTrib()

Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPTes		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local lGrade	:= MaGrade() .And. MatGrdPrrf(aCols[n][nPProduto])   

If lGrade .AND. !(ALLTRIM(aCols[n][nPProduto]) $ SB1->B1_COD) 
	SB1->(dbgotop())
	SB1->(MsSeek(xFilial("SB1")+AllTrim(aCols[n][nPProduto]),.F.))
EndIf

//�����������������������������������������������������������������Ŀ
//� Posiciona nas tabelas SB1 e SF4 para o preenchimento correto da �
//� classifica��o fiscal dos itens C6_CLASFIS atrav�s dos gatilhos. �
//�������������������������������������������������������������������
If !Empty(aCols[n][nPProduto]) .And. RTrim(aCols[n][nPProduto]) <> RTrim(SB1->B1_COD) .and. !lGrade
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aCols[n][nPProduto]))
EndIf

If !Empty(aCols[n][nPTes]) .And. RTrim(aCols[n][nPTes]) <> RTrim(SF4->F4_CODIGO)
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+aCols[n][nPTes]))
EndIf
Return .T.     

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    �A410VldTes � Autor � Marco Aurelio - Mano    � Data �13/06/11  ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida relacao do campo C6_TES com o campo C5_LIQPROD          ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �A410VldTes(ExpL1)                                              ���
����������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1 = Determina se a chamada foi feita a partir da TudOK     ���
����������������������������������������������������������������������������Ĵ��
���Uso       �MATA410A                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/             
Function A410VldTes(lTOK) 

Local nPosTES  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"}) 	// Posicao do campo C6_TES no aCols
Local aArea    := GetArea()										// Salva ambiente atual para posterior restauracao
Local lRet     := .t.											// Conteudo de retorno
Local cAtuEst  := ""											// Conteudo de retorno

DEFAULT lTOK := .F.

If !aCols[n][Len(aCols[n])] 

	cAtuEst	:= If(lTOK,;
	              Posicione("SF4",1,xFilial("SF4")+aCols[n][nPosTES],"F4_ESTOQUE"),;
				  SF4->F4_ESTOQUE)
	
	If (M->C5_LIQPROD=="1") .and. ( cAtuEst # "N" ) .And. M->C5_DOCGER == "1"
		//�����������������������������������������������������������������������������������������������������������Ŀ
		//�HELP: Para pedidos com o campo "Liquido Prod=Sim" a TES informada n�o deve permitir atualiza��o de estoque �
		//�������������������������������������������������������������������������������������������������������������			
		Help(" ",1,"A410TESINV")
	    lRet := .f.
	EndIf

EndIf

RestArea(aArea)
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410EntCtb
Valida��o chamada da condi��o do gatilho C6_PRODUTO, onde os campos cont�beis 
do pedido de venda, ser�o gatilhados ap�s informar ou trocar um produto 

@sample 	A410EntCtb() 
@param	
@return	lRet - .T. o gatilho ser� disparado
			   .F. o gatilho n�o ser� disparado	 

@author	Servicos
@since		06/05/15    
@version	P11   
/*/
//------------------------------------------------------------------------------ 
Function A410EntCtb()

Local lRet		:= .T.
Local nPosProd	:= aScan(aHeader,{|x| Trim(x[2]) == "C6_PRODUTO"})
Local cCodProd	:= ""	
Local aHeadAGG	:= {}	

If Type("l410Auto") <> "U" .And. (l410Auto .Or. Empty(aColsCCust))
	If Type("aRatCTBPC") == "A" .And. Len(aBkpAGG) == 0 .And. Len(aRatCTBPC) > 0
		aBkpAGG := aRatCTBPC
	Elseif Len(aBkpAGG) == 0 .And. !INCLUI
		A410FRat(@aHeadAGG,@aBkpAGG)
	EndIf
EndIf
// Prote��o para o array aColsCCust quando estiver indefinido ou vazio.
If Type("aColsCCust") == "U" .Or. Empty(aColsCCust)
	aColsCCust := aClone(aCols)
EndIf

If lRet 
	cCodProd := If( Type("M->C6_PRODUTO") == "U",;
	                CriaVar("C6_PRODUTO",.F.),;
					M->C6_PRODUTO )
	//�����������������������������������������������������������������L�
	//�Verifico se o produto informado est� sobrepondo um outro produto �
	//�ou se � a primeira vez que o mesmo � digitado.                   �
	//�����������������������������������������������������������������L�
	If !Empty(cCodProd) .And. (aColsCCust[n][nPosProd] <> cCodProd .Or. Empty(aColsCCust[n][nPosProd]))
		If Empty(aBkpAGG)
	 		lRet := .T.
		Else
			nScan	:= aScan(aBkpAGG,{|x| Val(x[1]) == n})       
			lRet	:= (nScan == 0)
		EndIf	
	Else                         
		lRet := .F.
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A410ClrPCpy()
Limpa o cache para n�o repetir a mensagem do mesmo produto durante a copia caso o mesmo estiver bloqueado.

@param		Nenhum

@return		Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior 
@since		20/10/2017 
/*/
//-------------------------------------------------------------------
Function A410ClrPCpy()

__aMCPdCpy := {}
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TransBasImp
Rotina para transferencia de impostos com base reduzida para outras filiais.
Fun��o chamada do Valid C5_TABTRF, da fun��o A410Produto(), A410MultT, e A410Limpa 

@sample 	TransBasImp() 

@param		lGetd Indica se a valida��o foi chamada da Getdados
	
@return	Nil 

@author	Servicos
@since		15/05/18    
@version	P12 
/*/
//------------------------------------------------------------------------------     
Function TransBasImp(lGetd)

Local aAreaDA1		:= DA1->(GetArea())
Local nPIPITrf		:= Ascan(aHeader,{|x| Trim(x[2]) == "C6_IPITRF"})
Local nPProduto		:= Ascan(aHeader,{|x| Trim(x[2]) == "C6_PRODUTO"})
Local nPQtd			:= Ascan(aHeader,{|x| Trim(x[2]) == "C6_QTDVEN"})		
Local nX			:= 0
Local cVar			:= ReadVar() 
Local cTipo			:= M->C5_TIPO

Default lGetd		:= .F.   

If nPIPITrf > 0 
	DA1->(DBSetOrder(1))
	If !lGetd 
		If cTipo $("N|D|B|") .And. Len(aCols) > 0
			For nX:= 1 To Len(aCols)
				aCols[nX][nPIPITrf]	:= If( DA1->(DBSeek(xFilial("DA1")+M->C5_TABTRF + aCols[nX][nPProduto])),;
				                           DA1->DA1_PRCVEN * Iif(aCols[nX][nPQtd] > 0, aCols[nX][nPQtd], 1),;
										   0 )
			Next nX
	    ElseIf cTipo $("C|I|P|") .And. Len(aCols) > 0
			For nX:= 1 To Len(aCols)
				aCols[nx][nPIPITrf]	:= 0
			Next nX
	    EndIf
	Else	        
		//��������������������������������������������������������������������������������Ŀ
		//�Atualiza o valos do campo C6_IPITRF, conforme o produto informado, caso o mesmo �
		//�exista na tabela DA1, da tabela de transf informada no cabe�alho        	       �
		//����������������������������������������������������������������������������������
		If cVar $("M->C6_PRODUTO")
			aCols[n][nPIPITrf]	:= If( DA1->(DBSeek(xFilial("DA1")+M->C5_TABTRF + M->C6_PRODUTO)),;
			                           DA1->DA1_PRCVEN * Iif(aCols[n][nPQtd] > 0, aCols[n][nPQtd], 1),;
									   0 )
		//���������������������������������������������������������������������Ŀ
		//�Atualiza o valor do campo C6_IPITRF, conforme a quantidade informada �
		//�����������������������������������������������������������������������
		ElseIf cVar $("M->C6_QTDVEN")
			If DA1->(DBSeek(xFilial("DA1")+M->C5_TABTRF + aCols[n][nPProduto]))
				aCols[n][nPIPITrf]	:= DA1->DA1_PRCVEN * Iif(M->C6_QTDVEN > 0, M->C6_QTDVEN, 1)
			EndIf
		EndIf  
	EndIf	
EndIf	
	 
RestArea(aAreaDA1)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410QtdCpPrc
Zera a quantidade e quantidade liberada de pedidos de complemento de Pre�o

@sample	A410QtdCpPrc(nPQtdVen, nPQtdLib, nCntFor, nMaxArray) 

@param 	nPQtdVen	- Quantidade do Pedido de Venda
@param 	nPQtdLib	- Quantidade Liberada do Pedido de Venda
@param 	nCntFor		- Linha em que a quantidade foi encontrada
@param 	nMaxArray	- N�mero de Itens do Pedido
	
@return	Nil 

@author	Servicos
@since		02/07/18    
@version	P12 
/*/
//------------------------------------------------------------------------------     
Function A410QtdCpPrc(nPQtdVen, nPQtdLib, nCntFor, nMaxArray)

Local nCont	:= 0
	
For nCont := nCntFor To nMaxArray
	aCols[nCont][nPQtdVen]	:= 0
	aCols[nCont][nPQtdLib]	:= 0
Next
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MT410ItDev
Ajusta valores da linha para devolu��es de entrada com desconto para evitar discrep�ncias devido arredondamento

@sample	MT410ItDev(acols, cCliente, cLoja) 

@param 	acols	- Grid de itens do pedido de venda
@param 	cCliente- C�digo do cliente (fornecedor por se tratar de devolu��o)
@param 	cLoja	- Loja do cliente (fornecedor por se tratar de devolu��o)
	
@return	Nil 

@author		CRM/Fat
@since		21/12/2021    
@version	P12 
/*/
//------------------------------------------------------------------------------     
Function MT410ItDev(acols, cCliente, cLoja )

Local aArea		:= GetArea()

Local nPProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPValor	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPPrUnit	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPNfori	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSeriori	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItemOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPPrcVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPValDes	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPDescont	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})

Default cCliente := ""
Default cLoja	 := ""

dbSelectArea("SD1")
SD1->(dbSetOrder(1))
If SD1->(DbSeek(xFilial("SD1")+aCols[n][nPNfori]+aCols[n][nPSeriori]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[n][nPProd]+aCols[n][nPItemOri])) .And. SD1->D1_VALDESC > 0
	
	If aCols[n,nPPrcVen] <> ((SD1->D1_TOTAL - SD1->D1_VALDESC)/SD1->D1_QUANT)
		aCols[n,nPPrcVen] := a410Arred(((SD1->D1_TOTAL - SD1->D1_VALDESC)/SD1->D1_QUANT),"C6_PRCVEN")
	EndIf
	
	If aCols[n,nPQtdVen] == SD1->D1_QUANT  //Verifica se a quantidade da devolu��o � total e se houve desconto na entrada
		If ((SD1->D1_QUANT * SD1->D1_VUNIT) - SD1->D1_VALDESC) <> (aCols[n,nPQtdVen] * aCols[n,nPPrcVen]) .And.; //Verifica se o valor total � diferente
				a410Arred(((SD1->D1_TOTAL - SD1->D1_VALDESC)/SD1->D1_QUANT),"C6_PRCVEN") == aCols[n,nPPrcVen] //Verifica se a diferen�a � devido ao trucamento do valor unit�rio
			aCols[n,nPValor] := SD1->D1_TOTAL-SD1->D1_VALDESC
			aCols[n,nPDescont] := A410Arred((1-((SD1->D1_TOTAL - SD1->D1_VALDESC)/SD1->D1_TOTAL))*100,"C6_DESCONT")
			aCols[n,nPValDes] := SD1->D1_VALDESC
		EndIf
	Else 
		aCols[n,nPDescont] := A410Arred((1-((SD1->D1_TOTAL - SD1->D1_VALDESC)/SD1->D1_TOTAL))*100,"C6_DESCONT")
		aCols[n,nPValDes] := A410Arred((aCols[n,nPDescont]/100)*(aCols[n,nPPrUnit]*aCols[n,nPQtdVen]),"C6_VALDESC")
		aCols[n,nPValor] := A410Arred((aCols[n,nPPrcVen]*aCols[n,nPQtdVen]),"C6_VALOR")
	EndIf
	
EndIf

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A410RtLtEnd
Zera a quantidade e quantidade liberada de pedidos de complemento de Pre�o

@sample	A410RtLtEnd(cProduto,cLoteCtl,cLocaliza)

@param 	cProduto	- Codigo do produto
@param 	cLoteCtl	- Lote do Produto
@param 	cLocaliza	- Enderecamento do produto
	
@return	lRet 

@author	Servicos
@since		26/12/18    
@version	P12 
/*/
//------------------------------------------------------------------------------
Static Function A410RtLtEnd(cProduto,cLoteCtl,cLocaliza)

Local lRet 		:= .F.
Local cAliasSql	:= GetNextAlias()

BeginSQL Alias cAliasSql
	SELECT SDB.DB_PRODUTO AS PRODUTO,SDB.DB_LOTECTL AS LOTECTL,SDB.DB_LOCALIZ AS LOCALIZA
	  FROM %table:SDB% SDB
	 WHERE SDB.DB_FILIAL = %xfilial:SDB%
	   AND SDB.DB_PRODUTO = %exp:cProduto%
	   AND SDB.DB_LOTECTL = %exp:cLoteCtl%
	   AND SDB.DB_LOCALIZ = %exp:cLocaliza%
	   AND SDB.%NotDel%
EndSql
If !Empty(PRODUTO)
	lRet := .T.
EndIf
Return lRet

/*/{Protheus.doc} FatLibMetric
Fun��o utilizada para validar a data da LIB para ser utilizada na Telemetria
@type       Function
@author     CRM/Faturamento
@since      Outubro/2021
@version    12.1.27
@return     __lMetric, l�gico, se a LIB pode ser utilizada para Telemetria
/*/
Static Function FatLibMetric()

If __lMetric == Nil 
	__lMetric := FWLibVersion() >= "20210517"
EndIf

Return __lMetric

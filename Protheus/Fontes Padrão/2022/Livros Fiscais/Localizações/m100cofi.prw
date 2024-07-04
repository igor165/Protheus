#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _IMPFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � M100COFI � Autor � Lucas                  � Data � 06.06.01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do Imposto C.O.F.I.S para o Uruguay...			      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � AP5			                                                ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
��� Lucas        �06/06/01�      �Inicio...					                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function M100COFI(cCalculo,nItem,aInfo)
Local aItemINFO
Local xRet,lXFis
Local aDespesas:={}
Local cImpIncid
Local cTec:=	""
Local nE,nI,nOrdSFC,nRegSFC
Local aImpRef,aImpVal
Local nAliq	:=	0
Local aArea		:=	GetArea()
Local aAreaSA1 :=	SA1->(GetArea())
Local lCalcula	:=	.T.
lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=AClone( ParamIxb[2] )
	cImpIncid:=xRet[10]
	If Len(ParamIxb[1]) >= 8
		cTec:=ParamIxb[1][8]
	Endif
	If Len(ParamIxb[1]) >= 9
		aDespesas	:=	ParamIxb[1][9]
	Endif
	If cModulo $ "FRT|OMS|LOJ|FAT"
		If Empty(SA1->A1_CGC)
			lCalcula	:=	.F.
		Endif	
	Endif
Else
	xRet:=0
	cImpIncid:=""
	If MaFisRet(,'NF_CLIFOR')=='C'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial()+MaFisRet(,'NF_CODCLIFOR')+MaFisRet(,'NF_LOJA')))
		If Empty(SA1->A1_CGC)
			lCalcula	:=	.F.
		Endif	
	Endif
EndIf
If lCalcula
	If !lXFis
		//��������������������������������������������������������������Ŀ
		//� Obter Base de C�lculo e Al�quota dos Impostos.				     �
		//����������������������������������������������������������������
		//��������������������������������������������������������������Ŀ
		//� Obs: No Uruguay temos uma alicuota de IVA de 14% ou 23% esta �
		//� realiconada con base na Classifica��o de Produtos e ser�     �
		//� inicializada atraves de Gatilhos disparado na GetDados.		  �
		//����������������������������������������������������������������
		xRet[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
		xRet[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
		xRet[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de C�lculo
		
		If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
			xRet[_BASECALC] -= xRet[18]
		EndIf
		xRet[_ALIQUOTA] := SFB->FB_ALIQ
		
		//��������������������������������������������������������������Ŀ
		//� Soma base dos impostos incidentes...							     �
		//����������������������������������������������������������������
		nI := At( ";",cImpIncid )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
		While nI > 1
			nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
			
			//���������������������������������������������������������������������Ŀ
			//�Nos impostos incluidos, o imposto deve ser tirado da base de calculo,�
			//�e nao somado a base.                                                 �
			//�����������������������������������������������������������������������
			If nE > 0
				xRet[_BASECALC] := xRet[_BASECALC]-aItemINFO[6,nE,_IMPUESTO]
			EndIf
			
			cImpIncid := Stuff( cImpIncid,1,nI,"" )
			nI := At( ";",cImpIncid )
			nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
		End
		
		//��������������������������������������������������������������Ŀ
		//� Efetua o Calculo do imposto...									     �
		//����������������������������������������������������������������
		xRet[_IMPUESTO]  	:= 	xRet[_BASECALC] - (xRet[_BASECALC]/(1+(xRet[_ALIQUOTA]/100)))
		xRet[_BASECALC]	-=		xRet[_IMPUESTO]
		
	Else
		SFB->(DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO] ))
		nAliq	:=	SFB->FB_ALIQ
		Do Case     
			Case cCalculo=="A"
				xRet:= nAliq
			Case cCalculo=="B"
				xRet	:=	MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				//Tira os descontos se for pelo liquido
				nOrdSFC:=(SFC->(IndexOrd()))
				nRegSFC:=(SFC->(Recno()))
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					cImpIncid	:=	SFC->FC_INCIMP
					If SFC->FC_LIQUIDO=="S"
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
				//+---------------------------------------------------------------+
				//� Soma a Base de C�lculo os Impostos Incidentes                 �
				//+----------------------------------------------------------Lucas+
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				nI := At( ";",cImpIncid )
				nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
				While nI > 1
					nE:= AScan( aImpRef,{|x| x[1] == Left(cImpIncid,nI-1) } )
					If nE> 0
						xRet-=aImpVal[nE]
					Endif
					cImpIncid := Stuff( cImpIncid,1,nI,'' )
					nI := At( ";",cImpIncid)
					nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
				EndDo       
				xRet	:=	xRet/(1+(nAliq/100))
			Case cCalculo=="V"
				nE:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nI:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				xRet:=(nE * nI)/100
		EndCase
	Endif
Endif

RestArea(aAreaSA1)	
RestArea(aArea)

Return( xRet )

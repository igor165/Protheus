#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �M100ICA   � Autor � Hermes Ferreira       � Data �07/12/2009���
���          �          �       � Denis Martins		    �      �22/07/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que Calcula ICA - Imposto Industria y Comercio    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M100ICA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Rubens Pan�te�28/01/02 xxxx �Mudado interpretacao da Aliquota para "por���
���          �          � xxxx �mil" ao inves de "por cento". Retirado    ���
���          �          � xxxx �AllTrim() ao pegar CFO, pois o CFO e chave���
���          �          � xxxx �de pesquisa.                              ���
���Altera��es� Foi alterado o criterio da busca da aliquota de calulo do  ���
���			 � ICA, quando a empresa emitir uma nota de compra e o codigo ���
���			 � A2_CODICA estiver vazio, o sismeta usa a base de calculo da���
���			 � SFB, caso esteja preenchido, busca a aliquota na SFF, de   ���
���			 � acordo com o agrupamento do codigo do CIIU.    			  ���
���			 � A base calc.n�o soma outros gastos como Frete,seguro e desp���
���			 � e despesas.												  ���
���R.Berti   �20/10/13�THYBRQ�P/ ICA, deve haver SA2->A2_CODICA ou		  ���
���		     �        �      �SA1->A1_ATIVIDA preenchido. Obtem aliq. SFF:���
���		     �        �      �Munic.+CIIU. Aliq.SFB tem como padrao 0%	  ���
���Jonathan G�10/06/16�TVGUG8�P/ICA, se toma el valor del campo F1_TPACTIV���
���		     �        �      �para respetar la funcionalidad de Tipo Activ���
���		     �        �      �Economica de colombia.                      ���
���Veronica F�19/06/18�DMINA-�Se realizo la modificaci�n para que tomara  ���
���		     �        �  6843�la actividad economica de la NF y NDP.      ���
���		     �        �      �Se realiza el cambio para el calculo del ICA���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Calculo de ICA                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100ICA(cCalculo,nItem,aInfo)
	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������
	Local nDesconto	:=	0,xRet,lXFis,cImp
	Local nAliqSFB	:= 0
	Local nImporte	:= 0
	Local cCodMUn   := MAFISRET(,'NF_CODMUN')
	Local cCatCliFor:= ""
	Local cCodIca	:= ""
	Local cPessoa	:= ""
	Local lCodMUn	:= .F.
	Local nMoedSFF  := 1
	Local nTaxaMoed	:= 0
	Local nMoeda    := 1

	SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
	SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
	SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
	SetPrvt("CRETICA,CMVAGENTE,NPOSLOJA,NPOSFORN,LRETCF")

	lRet	:= .T.
	lRetCF	:= .T.

	lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
	// .T. - metodo de calculo utilizando a matxfis
	// .F. - metodo antigo de calculo
	cAliasRot  := Alias()
	cOrdemRot  := IndexOrd()

	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		cImp:=xRet[1]
		cTes:= MaFisRet(nItem,"IT_TES")
	Else
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
		SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
		cTes := SF4->F4_CODIGO
	Endif

	//�����������������������������������������������������������������������Ŀ
	//�Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
	//�ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
	//�������������������������������������������������������������������������
	If cModulo$'COM|EST|EIC'
		cCatCliFor := SA2->A2_TIPO
		cTipoCliFor:= SA2->A2_TPESSOA
		cPessoa	   := If(SA2->(FieldPos("A2_PESSOA")) > 0,SA2->A2_PESSOA," ")
		cZonfis    := SA2->A2_EST
		//Tratamento para Calcular ou N�o ICA
		Iif((SA2->A2_RETICA == "S"), lRet := .T., lRet := .F.)
		If FunName() $ "MATA101N|MATA466N"
			cCodICA := M->F1_TPACTIV
		Else
			cCodICA := SA2->A2_CODICA
		EndIf
	
	Else
		cCatCliFor := SA1->A1_TIPO
		cTipoCliFor:= SA1->A1_TPESSOA
		cPessoa	   := SA1->A1_PESSOA
		cZonfis    := SM0->M0_ESTENT

		if FunName() == "MATA465N" .AND. GetRpoRelease() > "12.1.007"
			cCodICA := MAFISRET(,'NF_TPACTIV')
		Else
			cCodICA := M->F1_TPACTIV
		EndIf
		//Tratamento para Calcular ou N�o ICA
		Iif((SA1->A1_RETICA == "S"), lRet := .T., lRet := .F.)
	Endif


        // Busca o CFO do Tes Correspondente - SF4
        dbSelectArea("SF4")
        cCFO := SF4->F4_CF

	


	If lRet
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+cImp)
			If If(!lXFis,.T.,cCalculo$"AB")
				nAliqSFB  := SFB->FB_ALIQ // Aliquota padr�o
			EndIf
		EndIf

		//Verifica na SFF se existe CIIU / Municipio correspondente para:
		// * Calculo de Imposto;
		// * Obtencao de Aliquota;
		// * Faixa de Imposto De/Ate.

		If If(!lXFis,.T.,cCalculo$"ABV")

				If Empty(cCodIca)
					nAliq   := nAliqSFB  // Aliquota padr�o
					lRet    := .T.
				Else
					//���������������������������������������������Ŀ
					//�Metodo novo de busca pelo indice "H" da SFF: �
					//�FF_FILIAL+FF_IMPOSTO+FF_CODMUN+FF_CFO_C      �
					//�����������������������������������������������
					If ExistInd()
						dbSelectArea("SFF")
						dbSetOrder(17)
						If dbseek(xFilial("SFF")+cImp+cCodMun) //+cCFO
							While !Eof()
								If SFF->FF_COD_TAB == cCodICA .And.;
									SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun	  //+FF_CFO_C  +cCFO
									If FF_FLAG != "1"  .And. cCalculo <>"V"
										RecLock("SFF",.F.)
										Replace FF_FLAG With "1"
									EndIf
									nAliq   := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
									nImporte:= SFF->FF_IMPORTE
									nMoedSFF:= SFF->FF_MOEDA
									lCodMun := .T.
									lRet 	:= .T.
									Exit
								Else
									lRet := .F.
								EndIf
								dbSkip()
							EndDo
						Endif
					Endif
					If !lCodMun
						//���������������������������������������������������������������������������������������������Ŀ
						//�Metodo antigo de busca , pela zona fiscal (departamento) foi DESATIVADA 						�
						//�caso n�o tenha aliq. por cod.munic�pio, obtera' da SFB, que na Colombia devera' estar ZERADA.�
						//�����������������������������������������������������������������������������������������������
						nAliq   := nAliqSFB  // Aliquota padr�o
						lRet    := .T.
					Endif
				Endif
			//EndIf
		Endif
		If lRet
			//������������������������������������������������������������������������������Ŀ
			//� Efetua o calculo de ICA, taxa sera' calculada por mil (1000)  				 �
			//��������������������������������������������������������������������������������
			If !lXFis
				//����������������������������������������������������������������������������������Ŀ
				//� Calcula o imposto somente se o valor da base for maior ou igual a base minima    �
				//������������������������������������������������������������������������������������
				If nImporte > 0 .And. (aItemINFO[3]) < nImporte
					nAliq := 0
				EndIf
				//Tira os descontos se for pelo liquido .Bruno
				If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
					nDesconto	:=	xRet[18]
				Else
					nDesconto	:=	0
				Endif
				xRet[02]  := nAliq // Alicuota de Zona Fiscal
				xRet[03]  := (aItemINFO[3] - nDesconto)
				xRet[04]  := round(xRet[03] * ( xRet[02]/1000) ,2)

				If nImporte > 0 .And. xRet[04] >= nImporte
					xRet[04]  := xRet[04]
				Else
					xRet[04]  := 0
				EndIf
			Else
				Do Case
					Case cCalculo=="A"
						xRet:=nAliq
					Case cCalculo=="B"
						xRet:= 0
						If GetNewPar('MV_DESCSAI','1')=='1'
							xRet	+= MaFisRet(nItem,"IT_DESCONTO")
						Endif
						//Tira os descontos se for pelo liquido
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_LIQUIDO=="S"
								xRet-=MaFisRet(nItem,"IT_DESCONTO")
							Endif
						Endif
						xRet+= MaFisRet(nItem,"IT_VALMERC") //If(SFC->FC_CALCULO=="T",MaFisRet(,"NF_VALMERC")+MaFisRet(nItem,"IT_VALMERC"),MaFisRet(nItem,"IT_VALMERC"))
					Case cCalculo=="V"
						If Type("M->F1_MOEDA")<>"U" 			   	
							nMoeda := M->F1_MOEDA
							nTaxaMoed := M->F1_TXMOEDA
						ElseIf Type("M->C7_MOEDA")<>"U"
							nMoeda := M->C7_MOEDA
						    nTaxaMoed := M->C7_TXMOEDA				
						ElseIf Type("M->F2_MOEDA")<>"U"
						   	nMoeda := M->F2_MOEDA
						    nTaxaMoed := M->F2_TXMOEDA				
						ElseIf Type("M->C5_MOEDA")<>"U" 
							nMoeda := M->C5_MOEDA
						    nTaxaMoed := M->C5_TXMOEDA	   
						Else
							nMoeda 		:= MAFISRET(,'NF_MOEDA')     
							nTaxaMoed 	:= MaFisRet(,'NF_TXMOEDA')			
						EndIf	        

						If nTaxaMoed==0
							nTaxaMoed:= RecMoeda(nMoeda)
						EndIf
						nVal:=0
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_CALCULO=="T"
								nBase:= MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
								nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),)
							Else
								nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
								nVal	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
							EndIf
						Endif

						nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])

						//����������������������������������������������������������������������������������Ŀ
						//� Calcula o imposto somente se o valor da base for maior ou igual a base minima    �
						//������������������������������������������������������������������������������������
						If xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedSFF,1)
							xRet:=nVal * ( nAliq/1000)
						Else
							xRet:= 0
						EndIf

				EndCase
			Endif
		Endif
	Endif
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
Return( xRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExistInd  �Autor  �Camila Janu�rio     � Data �  09/11/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �  Vefifica exist�ncia da ordem do �ndice                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function ExistInd()
Local lRet := .F.

SIX->(DbSetOrder(1))
If SIX->(DbSeek("SFF"+"H")) .And. SIX->(DbSeek("SFF"+"I"))
	lRet := .T.
Endif

Return lRet

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

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M100CREE � Autor � Ricardo Berti		    � Data �22/11/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que Calcula CREE - Imposto Renta p/ la Equidad    ���
���          � SFF: Mesmo mecanismo do ICA, mas sem Municipio			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M100CREE                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Calculo de CREE (COL)                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function M100CREE(cCalculo,nItem,aInfo)
	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������
	Local nDesconto	:=	0,xRet,lXFis,cImp
	Local nAliqSFB	:= 0
	Local nImporte	:= 0
	Local cCatCliFor:= ""
	Local cCodIca	:= ""
	
	SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
	SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
	SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,LRET")
	SetPrvt("CMVAGENTE,NPOSLOJA,NPOSFORN")

	lRet	:= .T.
	
	lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
	// .T. - metodo de calculo utilizando a matxfis
	// .F. - metodo antigo de calculo
	cAliasRot  := Alias()
	cOrdemRot  := IndexOrd()
	
	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet:= ParamIxb[2]
		cImp:=xRet[1]
		//cTes:= MaFisRet(nItem,"IT_TES")	
	Else
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
		//SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
		//cTes := SF4->F4_CODIGO
	Endif

	//�����������������������������������������������������������������������Ŀ
	//�Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
	//�ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
	//�������������������������������������������������������������������������
	If cModulo$'COM|EST|EIC'
		cCatCliFor := SA2->A2_TIPO
		cTipoCliFor:= SA2->A2_TPESSOA
		cZonfis    := SA2->A2_EST
		cCodICA    := SA2->A2_CODICA
	Else
		cCatCliFor := SA1->A1_TIPO
		cTipoCliFor:= SA1->A1_TPESSOA
		cZonfis    := SM0->M0_ESTENT
		cCodICA    := SA1->A1_ATIVIDA
	Endif

	If lRet
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+cImp)
			If If(!lXFis,.T.,cCalculo$"AB")
				nAliqSFB  := SFB->FB_ALIQ // Aliquota padr�o
			EndIf
		EndIf
		
		//Verifica na SFF se existe CIIU correspondente para:
		// * Calculo de Imposto;
		// * Obtencao de Aliquota;
		// * Faixa de Imposto De/Ate.

		If If(!lXFis,.T.,cCalculo$"ABV")
			
			If Empty(cCodIca)
				nAliq   := nAliqSFB  // Aliquota padr�o
				lRet    := .T.
			Else
				dbSelectArea("SFF")
				dbSetOrder(10)
				If dbseek(xFilial("SFF")+cImp)
					While !Eof() .And. SFF->(FF_IMPOSTO) == cImp
						If SFF->FF_COD_TAB == cCodICA
							If FF_FLAG != "1"  .And. cCalculo <>"V"
								RecLock("SFF",.F.)
								Replace FF_FLAG With "1"
							EndIf
							nAliq   := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
							nImporte:= SFF->FF_IMPORTE
							lRet 	:= .T.
							Exit
						Else
							lRet := .F.
						EndIf
						dbSkip()
					EndDo
				Else
					lRet := .F.
				EndIf
				If !lRet	
					nAliq   := nAliqSFB  // Aliquota padr�o
					lRet    := .T.
				EndIf
			EndIf
		EndIf
		If !lXFis
			//����������������������������������������������������������������������������������Ŀ
			//� Calcula o imposto somente se o valor da base for maior ou igual a base minima    �
			//������������������������������������������������������������������������������������
			If nImporte > 0 .And. (aItemINFO[3]) < nImporte
				nAliq := 0
			EndIf
			//Tira os descontos se for pelo liquido
			If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
				nDesconto	:=	xRet[18]
			Else
				nDesconto	:=	0
			Endif
			xRet[02]  := nAliq // Alicuota de Zona Fiscal
			xRet[03]  := (aItemINFO[3] - nDesconto)  
			xRet[04]  := round(xRet[03] * ( xRet[02]/100) ,2)
			
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
					If nVal >= nImporte
						xRet:=nVal * ( nAliq/100)
					Else
						xRet:= 0
					EndIf

			EndCase
		EndIf
	EndIf
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
Return( xRet ) 

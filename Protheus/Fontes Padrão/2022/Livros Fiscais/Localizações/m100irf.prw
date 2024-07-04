#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
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
���Programa  � M100IRF  � Autor � Camila Janu�rio     � Data � 23.01.2012 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do IRF - Entrada                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),���
���          �          B (base), V (valor).                              ���
���          � nPar02 - Item do documento fiscal.                         ���
���          � aPar03 - Array com as informacoes do imposto.              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATXFIS                                                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���31/07/2019�ARodriguez     �DMINA-6748 CalcRetFis() obtiene CFO de      ���
���          �               �MaFisRet() COL                              ���
���04/09/2019�Oscar G.       �DMINA-6870 CalcRetFis() redondeo de deci-   ���
���          �               �males COL                                   ���
���27/03/2020�Eduardo P.     �DMINA-8462 CalcRetFis() ajuste para aplicar ���
���          �               �correctamente descuento COL                 ���
���10/01/2021�Luis Enr�quez  �DMINA-10739 CalcRetFis() correcci�n p/calcu-���
���          �               �culo de base de Ret. de Fuente en NCC cuando���
���          �               �se aplica descuento por �tem (COL)          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function M100IRF(cCalculo,nItem,aInfo) 

Local aRet
Local cFunct   := ""
Local aCountry := {}
Local lXFis    := .T.
Local aArea    := GetArea()
	
lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
aCountry := GetCountryList()
cFunct   := "M100IRF" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //monta nome da funcao
aRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //executa a funcao do pais

RestArea(aArea)

Return aRet    

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M100IRFUR � Autor � Camila Janu�rio     � Data � 23.01.2012 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do IRF - Entrada - Uruguai			               ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Uruguai 					                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function M100IRFUR(cCalculo,nItem,aInfo,lXFadminis)

Local xRet
Local cRetFuent := ""
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet,nBaseAtu, nMoeda, nTaxaMoed
Local lRet, cGrpIRPF 
Local cTotal
Private clTipo	:= ""  


SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T. 
llRetIVA:= If(cPaisLoc == "URU", .F., llRetIVA)
cAliasRot  := Alias()                                            
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0

If cModulo$'FAT|TMK|LOJA|FRT'
	If FieldPos("A1_RETIRPF")>0     
		cRetFuent	:= Alltrim(SA1->A1_RETIRPF)
	Endif
	clTipo	 	:= Alltrim(SA1->A1_TIPO)	
Else
	cRetFuent   := Alltrim(SA2->A2_RETIRPF)
	clTipo		:= Alltrim(SA2->A2_TIPO)	
Endif	

If cRetFuent == "S" .And. clTipo$"1|2|3"
	
	nBase:=0
	nAliq:=0
	nDesconto:=0
	nVRet:=0
	cGrpIRPF:=""
	aValRet := {0,0}
	
	cZonFis := Space(02)
	If cModulo$'COM'
		cZonfis    := SA2->A2_EST
	ElseIf cModulo$'FAT'
		cZonfis    := SM0->M0_ESTENT
	EndIf
	
	cCFO := MaFisRet(nItem,"IT_CF")
	cTotal := MaFisRet(nItem,"IT_TOTAL")     
	
If cTotal > 0
	
	//�������������������������������������������������������������������Ŀ
	//�Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA�
	//���������������������������������������������������������������������
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
		If cCalculo$"AB"
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				If SFC->FC_LIQUIDO=="S"
					nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			nVal-=nDesconto
			nAliq:=SFB->FB_ALIQ		
			lRet := .F.
			If (clTipo=="3" .And. Alltrim(aInfo[X_IMPOSTO])=="IRN") .Or. Alltrim(aInfo[X_IMPOSTO])=="IR2"
				DbSelectArea("SFF")
				SFF->(DbSetOrder(5))
				SFF->(DbGoTop())
				If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO + cZonFis) 
					nAliq:=SFF->FF_ALIQ                
				Endif
				lRet := .T.			
			Else
				//Verifica na SFF se existe Imposto e Grupo correspondente para realizacao do calculo
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbGoTop())
				If FieldPos("B1_GRPIRPF")>0     
					If DbSeek(xFilial("SB1") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
						cGrpIRPF:=SB1->B1_GRPIRPF
						DbSelectArea("SFF")
						SFF->(DbSetOrder(9))
						SFF->(DbGoTop())
						If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIRPF,"FF_GRUPO"))
							nAliq:=SFF->FF_ALIQ
							lRet := .T.
						Endif		
					Endif
				Endif		
			Endif				
		Else
			lRet:=.T.
		Endif
	Endif
EndIf	

If lRet
	Do Case
		Case cCalculo=="B"
			nVRet:= nVal
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"
			nBase:=MaRetBasT(aInfo[X_NUMIMP],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[X_NUMIMP]))
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])		
			nTaxaMoed := 0
			nMoeda := 1
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
	        EndIf	        
	        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)        						
	        //�������������������������������������������������������Ŀ
	   	   	//�Verifica o valor das reten��es e base de IR acumulados �
	   	   	//���������������������������������������������������������			
			aValRet := RetValIR()
			//aValRet[01] = base acumulada
			//aValRet[02] = retencao acumulada 				
			If (SFF->(FieldPos("FF_IMPORTE")) > 0) .and. (nBaseAtu+aValRet[1]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				nVret := ((nBase + aValRet[1])*(nAliq/100))-aValRet[2]
				nVret := IIf(nVret>0,nVret,0) 			   		
			Else
				nVret := 0
			EndIF				
	EndCase
 Endif  
EndIf
  
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(nVRet)


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M100IRFCO � Autor � Camila Janu�rio     � Data � 23.01.2012 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do IRF - Entrada - Col�mbia			               ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Costa Rica				                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function M100IRFCO(cCalculo,nItem,aInfo,lXFis)

Local xRet
Local llRetIVA	:= .T.
Local clAgen	:= GetMV("MV_AGENTE")
Local cRetFuent := ""
Local cContrib  := ""
Private clTipo	:= ""

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T.
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
	
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
nBase      := 0
clTipo	   := ""
//�����������������������������������������������������������������������Ŀ
//�Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
//�ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
//�������������������������������������������������������������������������
If cTipo = "D"   // devolucao de venda 
	cTipoCliFor := SA1->A1_TPESSOA
	cRetFuent   := SA1->A1_RETFUEN
	cContrib    := SA1->A1_CONTRBE //CONTRIBUINTE    
	cAgRet      := SA1->A1_RETENED
Else
	cTipoCliFor := SA2->A2_TPESSOA
	cRetFuent   := Alltrim(SubStr(clAgen,3,1))
	cContrib    := SA2->A2_CONTRBE //CONTRIBUINTE
	cAgRet      := SA2->A2_RETENED
Endif
cZonFis := Space(02)
If cModulo$'COM'
	If SubStr(clAgen,3,1) != "S"                                                                                                                        
		llRetIVA	:= .F.
	EndIf		
	cZonfis    := SA2->A2_EST
ElseIf cModulo$'FAT'
	If SA1->A1_RETFUEN != 'S'
		llRetIVA	:= .F.
	EndIf		
	cZonfis    := SM0->M0_ESTENT
EndIf
	
//Cliente Tipo Persona Natural 
//1. Se for um proveedor "Regimen Comum" somente pode reter fuente se n�o for " Gran Contribuyente" 
/*If  (cTipoCliFor == "1" .AND. cContrib == "1")
	lRetCF := .F.
Else
	lRetCF := .T.
Endif COMENTADO DEVIDO A FNC 000000199602012*/ 
 /*
    1. Se for um proveedor "Regimen Comum" somente pode reter fuente se n�o for " Gran Contribuyente" 
	2. O proveedor quando � 'Regimen Simplificado" quando tem reten��o de fuente � obrigatorio ter Reten��o de IVA. 
    3. Se o proveedor � "Gran Contribuyente" somente pode reter fuente, n�o pode reter IVA. 
*/	
	
If  (cAgRet == "S") .OR. (cAgRet == "1")
	lRetCF := .T.
Else
	lRetCF := .F.           
Endif

//���������������������������������������������������������������������Ŀ
//�             Verifica se Calcula Retencao en la Fuente:              �
//�                        Cliente / Proveedor                          �
//�����������������������������������������������������������������������
If lRetCF
	If cRetFuent == "S"
		If !lXFis
			If llRetIVA
				CalcRetenEnt()
				xRet:=aImposto
			EndIf
		Else
			If llRetIVA
				xRet:=CalcRetFis(cCalculo,nItem,aInFo)
			EndIf
		Endif
	Endif
Endif

Return( xRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CALCRETEN �Autor  �Denis Martins       � Data �  11/12/99   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo da Retencao do Imposto X Tes - Entrada              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MATA460,MATA100                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CalcRetenEnt()
Local nDesconto	:=	0
Local nMoeda  := Max(SF2->F2_MOEDA,1)
Local nTotBase := 0
SetPrvt("NBASE,NFAXDE,NFAXATE")

nMoeda := IIf(Type("nMoedSel")	=="U", nMoeda ,Max(nMoedSel,1))
//���������������������������������������������������������������������Ŀ
//� Busca o CFO informado no PV - pode ter sido alt. devido o concepto  �
//�                                                                     �
//�����������������������������������������������������������������������
// CFO do pedido pode ter sido alterado, devido o concepto.
cCFO := SC6->C6_CF 
//�������������������������������������������������������������������Ŀ
//�Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA�
//���������������������������������������������������������������������
//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	nDesconto	:=	aImposto[18]
Else
	nDesconto	:=	0
Endif

dbSelectArea("SFF")
dbGoTop()
dbSetOrder(5)
If dbSeek(xFilial("SFF") + aImposto[1] + cCFO)
	If FF_FLAG != "1"
		RecLock("SFF",.F.)
		Replace FF_FLAG With "1"
		Endif
		nFaxde  := SFF->FF_FXDE
		
		aImp:=ParamIxb[2]
		cImp:=aImp[1]
		cImpIncid:=aImp[10]
		If Len(Alltrim(cImpIncid)) >0 
			nTotBase:= 0
			nI:=At(cImpIncid,";" )
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			nI:=At(cImpIncid,";" )
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		
			While nI>1
				nE:=AScan(aItemINFO[6],{|x| x[1]==Left(cImpIncid,nI-1)})
				If nE>0
					nTotBase+=aItemINFO[6,nE,4]
				End
				cImpIncid:=Stuff(cImpIncid,1,nI,"")
				nI:=At(cImpIncid,";")
				nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			End
		Else
				nTotBase := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
		EndIf		
	
		If xMoeda(nTotBase,nMoeda,1)>= xMoeda(nFaxde,SFF->FF_MOEDA,1)
			nAliq   := SFF->FF_ALIQ
			nBase   := (SFF->FF_PERC / 100)
			aImposto[3]  := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
			aImposto[2]  := nAliq
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif

If lRet
	aImposto[4] := aImposto[3] * (aImposto[2]/100)
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CALCRETFIS�Autor  �Denis Martins       � Data � 11/12/1999  ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo da Retencao do Imposto X Tes - Entrada              ���
���          �Alterado para o uso da funcao MATXFIS (Marcello)            ���
�������������������������������������������������������������������������͹��
���Uso       � MATA460,MATA100                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CalcRetFis(cCalculo,nItem,aInfo)
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nTotBase,nVRet
Local nFaxDe,lRet, cGrpIRPF, nImporte, nPosCFO
Local nMoeda:=1                                                     
Local nMoedaSFF:=1    
Local nTaxaMoed:=1 
Local  nI:=1
Local  nVal :=0 
Local  cCF :=""
Local lAplDesc := .T.

If cPaisLoc == "COL" .And. FunName() == "MATA465N" .And. GetNewPar('MV_DESCSAI','1') == '1'
	lAplDesc := .F.
EndIf
                                              
If Type("M->F1_MOEDA")<>"U" 
	nMoeda:= M->F1_MOEDA      
	nTaxaMoed := M->F1_TXMOEDA	
ElseIf Type("M->C7_MOEDA")<>"U"
	nMoeda:= M->C7_MOEDA    
    nTaxaMoed := M->C7_TXMOEDA	
ElseIf Type("M->F2_MOEDA")<>"U" 
	nMoeda:= M->F2_MOEDA    
    nTaxaMoed := M->F2_TXMOEDA	
ElseIf Type("M->C5_MOEDA")<>"U"
	nMoeda:= M->C5_MOEDA      
    nTaxaMoed := M->C5_TXMOEDA	
ElseIf Type("nMoedaPed")<>"U"	 .And. Type("nTxMoeda")<>"U"
	nMoeda:= nMoedaPed         
    nTaxaMoed := nTxMoeda
EndIf		

If nTaxaMoed==0
	nTaxaMoed:= RecMoeda(nMoeda)
EndIf

nBase:=0
nAliq:=0
nDesconto:=0
nVRet:=0
cGrpIRPF:=""
lRet:=.F.
aValRet := {0,0}

cZonFis := Space(02)
If cModulo$'COM'
	cZonfis    := SA2->A2_EST
ElseIf cModulo$'FAT'
	cZonfis    := SM0->M0_ESTENT
EndIf

//���������������������������������������������������������������������Ŀ
//�           Busca o CFO correspondente do documento                   �
//�����������������������������������������������������������������������
cCFO := MaFisRet(nItem,"IT_CF")

//�������������������������������������������������������������������Ŀ
//�Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA�
//���������������������������������������������������������������������
dbSelectArea("SFB")
dbSetOrder(1)
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])

	IF cCF <> cCFO .And. nPosCFO <> Nil .And. cPaisLoc == "COL"
		cCFO:=aCols[nItem][nPosCFO]
	EndIf
	//Tira os descontos se for pelo liquido
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))       
		If SFC->FC_LIQUIDO=="S"	
			nDesconto:=MaFisRet(nItem,"IT_DESCONTO")		
		Endif
	Endif
	cImpIncid:=Alltrim(SFC->FC_INCIMP)
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
	If !Empty(cImpIncid)
		aImpRef:=MaFisRet(nItem,"IT_DESCIV")
		aImpVal:=MaFisRet(nItem,"IT_VALIMP")
		For nI:=1 to Len(aImpRef)
		       If !Empty(aImpRef[nI])
			      IF Trim(aImpRef[nI][1])$cImpIncid
				     nVal+=aImpVal[nI]
			      Endif
			   Endif
		Next	
	Else
		nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If lAplDesc
			nVal -= nDesconto
		EndIf 
	Endif   
	
	nAliq:=SFB->FB_ALIQ
	
	DbSelectArea("SFF")	
	SFF->(DbSetOrder(5))
	SFF->(DbGoTop())

	If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO)		
		If cCalculo == "V"
			nImporte := SFF->FF_IMPORTE               
			//
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
					If SFC->FC_CALCULO=="T"
				      If MaFisRet(,'NF_BASEIV'+aInfo[2])+ MaFisRet(nItem,'IT_BASEIV'+ aInfo[2]) > MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      nVal		:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]))              
			  			Endif
			         ELSE
				        If MaFisRet(nItem,'IT_BASEIV'+aInfo[2]) >   MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      	nVal	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])   
			  			Endif
					Endif
				Endif               
			//
			lRet:=.T.
		ElseIf cCalculo $ "BA" 							
			If FF_FLAG != "1" 
				RecLock("SFF",.F.)
				Replace FF_FLAG With "1"
				SFF->(MsUnlock())
			Endif
			nFaxde   := SFF->FF_FXDE
			nMoedaSFF := SFF->FF_MOEDA
			nTotBase := xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed)
			//If nTotBase >= xMoeda(nFaxde,SFF->FF_MOEDA,1) 
				nAliq:=SFF->FF_ALIQ
				lRet := .T.
				DbGoBottom()                                                
		/*	Else				
				lRet := .F.
			Endif			*/
		Endif           
	Endif                                    
Endif
If lRet
	Do Case
		Case cCalculo=="B"
			nVRet:= nVal
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])		
  	   		If xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedaSFF,1)
				nVRet := Round( nVal * (nAliq/100), 2)
			Else
				nVRet:= 0	   	   				
			EndIf			  	   			   		   	   		   	   		
	EndCase
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(nVRet)

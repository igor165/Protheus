#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M460IMS	³ Autor ³ Percy Horna          ³ Data ³ 19.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO IMPOSTO IMESI - SALIDA                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ URUGUAY 						                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION M460IMS(cCalculo,nItem,aInfo)

Local lXFis,  xRet
Local nAliq := 0
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cGrpIMS	 := ""
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Private clTipo	:= ""
Private cZonFis	:= ""

If cModulo$'FAT|TMK|LOJA|FRT'
	clTipo	 	:= Alltrim(SA1->A1_TIPO)	
	cZonfis     := SA1->A1_EST

Else
	clTipo		:= Alltrim(SA2->A2_TIPO)	
	cZonfis     := SA1->A1_EST
Endif	                                    
xRet:=0
lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXFis
	If clTipo=="2" .And. Alltrim(aInfo[X_IMPOSTO])$"IMS"
		xRet:=CalcRetFis(cCalculo,nItem,aInfo)	
	Endif	
Else                 
	aItemINFO  	:= ParamIxb[1]
	aImposto   	:= ParamIxb[2]
	xRet		:= aImposto
	cCFO 		:= Alltrim(SF4->F4_CF)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza o valor do imposto do IVA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SFB")
	DbSetOrder(1)
	If DbSeek(xFilial("SFB")+aImposto[1])
		nAliq   := SFB->FB_ALIQ
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
			nDesconto	:=	aImposto[18]
		Else
			nDesconto	:=	0
		Endif

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If FieldPos("B1_GRPIMS")>0
			If DbSeek(xFilial("SB1") + AvKey(aImposto[16],"B1_COD") )
				cGrpIMS:=SB1->B1_GRPIMS
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF") + AvKey(aImposto[1],"FF_IMPOSTO") + AvKey(cGrpIMS,"FF_GRUPO"))
					nAliq:=SFF->FF_ALIQ
				Endif
			Endif    
		Else
			DbSelectArea("SFF")
			SFF->(DbSetOrder(6))
			SFF->(DbGoTop())
			If Dbseek(xFilial("SFF")+aImposto[1]+cCFO+cZonfis)
				nFaxde  := SFF->FF_FXDE
				nTotBase := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
				If nTotBase >= nFaxde
					nAliq   := SFF->FF_ALIQ
				Endif       
			EndIf                
		Endif	
		If SubStr(cMvAgente,8,1) == "N" .And. Alltrim(aImposto[1])=="IMS"
			nAliq:=0
		Endif
		aImposto[2] := nAliq		
		aImposto[3]	:= ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
		aImposto[4]	:= aImposto[3] * (aImposto[2]/100)
 	Endif	
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(xRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CALCRETFISºAutor  ³Denis Martins       º Data ³ 11/12/1999  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada              º±±
±±º          ³Alterado para o uso da funcao MATXFIS (Marcello)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcRetFis(cCalculo,nItem,aInfo)
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
Local nFaxDe,lRet, cGrpIMS

nBase:=0
nAliq:=0
nDesconto:=0
nVRet:=0
cGrpIMS:=""
lRet:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³           Busca o CFO do Tes Correspondente - SF4                   ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCFO := MaFisRet(nItem,"IT_CF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFB")
dbSetOrder(1)
If DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	lRet:=.T.	
	nAliq:=SFB->FB_ALIQ
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
		//Verifica na SFF se existe Imposto e Grupo correspondente para realizacao do calculo
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If FieldPos("B1_GRPIMS")>0
			If DbSeek(xFilial("SB1") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
				cGrpIMS:=SB1->B1_GRPIMS
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIMS,"FF_GRUPO"))
					nAliq:=SFF->FF_ALIQ
				Endif
			Endif    
		Else
			//Verifica na SFF se existe Imposto e CFO correspondente para realizacao do calculo
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO + cZonFis)
				If FF_FLAG != "1"
					RecLock("SFF",.F.)
					Replace FF_FLAG With "1"
					SFF->(MsUnlock())
				Endif
				nFaxde  := SFF->FF_FXDE
				nTotBase := nVal //* nBase
				If nTotBase >= nFaxde
					nAliq:=SFF->FF_ALIQ
					DbGoBottom()
				Endif
			Endif
		Endif
	Endif
Endif
If lRet
	Do Case
		Case cCalculo=="B"
			nVRet:=nVal//*nBase
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nVRet:=nBase * (nAliq/100)
	EndCase
Endif
Return(nVRet)

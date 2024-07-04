#INCLUDE "SIGAWIN.CH"
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100PFI	³ Autor ³ MARCELLO GABRIEL     ³ Data ³ 24.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PERCEPCION FIJA SOBRE IVA   (URUGUAY)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												   ³±±
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
Function M100PFI(cCalculo,nItem,aInfo)
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cImpIncid	 :=""         
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet, nI,nAliqI
If Valtype(aInfo)=="U"
	aInfo   := ParamIxb[2]
Endif

nI:=0
nBase:=0
nAliq:=0
nAliqI:=0
nDesconto:=0
nVRet:=0

DbSelectArea("SFB")
SFB->(DbSetOrder(1))
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	cCFO := MaFisRet(nItem,"IT_CF")
	//Tira os descontos se for pelo liquido
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
		If SFC->FC_LIQUIDO=="S"
			nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
		Endif
		cImpIncid:=SFC->FC_INCIMP
	Endif
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
	nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	If GetNewPar('MV_DESCSAI','1')=='2'
		nVal-=nDesconto
	Endif 
	
	If SubStr(cMvAgente,5,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="PFI"
		nAliq:=0
	Else
		DbSelectArea("SFF")
		SFF->(DbSetOrder(5))
		SFF->(DbGoTop())
		If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO )
			nAliq:=SFF->FF_ALIQ                
		Else
			nAliq:=SFB->FB_ALIQ
		Endif
		If !Empty(cImpIncid)		
			nI:=At(";",cImpIncid)
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			nAliqI:=0
			Do While nI>1
				If (SFB->(DbSeek(xFilial("SFB")+Substr(cImpIncid,1,nI-1))))
					nAliqI+=SFB->FB_ALIQ
				Endif
				cImpIncid:=Stuff(cImpIncid,1,nI,"")
				nI := At( ";",cImpIncid)
				nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			End
		Endif 
	Endif	
Endif

Do Case
	Case cCalculo=="B"
		nVRet:=nVal
		If nAliqI>0
			nVRet:=nVal * (nAliqI/100)		
		Endif
		
	Case cCalculo=="A"
		nVRet:=nAliq
	Case cCalculo=="V"
		nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
		nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
		nVRet:=nBase * (nAliq/100)
EndCase
DbSelectArea( cAliasRot )
DbSetOrder( cOrdemRot )
Return(nVRet)
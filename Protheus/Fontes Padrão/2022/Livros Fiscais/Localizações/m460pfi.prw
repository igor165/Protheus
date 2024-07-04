#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M460PFI	³ Autor ³ MARCELLO GABRIEL     ³ Data ³ 24.09.2003 ³±±
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
FUNCTION M460PFI(cCalculo,nItem,aInfo)

LOCAL cFunct
LOCAL aRet
LOCAL lXFis
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,
LOCAL aArea 	:= GetArea()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

aCountry:= GetCountryList()
cFunct	:= "M460PFI" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet	:= &( cFunct )(cCalculo,nItem,aInfo,lXFis)

RestArea( aArea )

RETURN aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460RIVACOºAutor  ³Denis Martins       º Data ³  02/17/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Esse imposto e calculado sobre º±±
±±º          ³o Imposto de Valor Agregado                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460PFIUR(cCalculo,nItem,aInfo,lXFis)
Local xRet, nC                           
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Private CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CTIPOCLI,CTIPOFORN,CCFO
Private NVLIMPOSTOIVA,LRET,CZONFIS,LRETCF

cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
lRet := .F.
cZonFis := ""
nVlImpostoIVA := 0
nBase         := 0

If !lXFis
	If cModulo$'FAT|LOJA|FRT|TMK|OMS|FIS'
		cTipoCliFor := SA1->A1_TPESSOA
	Else
		cTipoCliFor := SA2->A2_TPESSOA
	Endif
Else               
	If MaFisRet(,"NF_CLIFOR") == "C"
		cTipoCliFor := SA1->A1_TPESSOA
	Else
		cTipoCliFor := SA2->A2_TPESSOA
	EndIf
EndIf

If lXFis
	xRet:=M460PFIFUR(cCalculo,nItem,aInfo)
Else                            
	cCFO := Alltrim(SF4->F4_CF)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza o valor do imposto do IVA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC:=1 To Len(aImpVarSD2[6])
		If Substr(aImpVarSD2[6][nC][1],1,2) == "IV"
			nVlImpostoIVA += aImpVarSD2[6][nC][4] 
		Endif
	Next nC
	If SubStr(cMvAgente,5,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="PFI"
		nAliq:=0
	Else
		If FieldPos('F4_PRETIVA') > 0 .And. SF4->F4_PRETIVA > 0
			aImposto[_ALIQUOTA] := SF4->F4_PRETIVA
		Else               
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If dbSeek(xFilial("SFF") + aImposto[1] + cCFO )
				aImposto[_ALIQUOTA] := SFF->FF_ALIQ                
			Else
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+aImposto[1])
					aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				EndIf
			Endif	
		Endif	
    Endif
	aImposto[_BASECALC] := nVlImpostoIVA
	aImposto[_IMPUESTO]  := round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,2)	
	xRet:=aImposto
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(xRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460PFIFUR ºAutor  ³Marcos Kato         º Data ³ 13/08/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±º          ³Alterado para o uso da funcao MATXFIS (Marcello)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460PFIFUR(cCalculo,nItem,aInfo)
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cCFO		 :=""	
Local cImpIncid	 :=""              
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet, nI,nAliqI

nI:=0
nBase:=0
nAliq:=0
nAliqI:=0
nDesconto:=0
nVRet:=0

DbSelectArea("SFB")
SFB->(DbSetOrder(1))
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	If cCalculo$"AB"                    
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
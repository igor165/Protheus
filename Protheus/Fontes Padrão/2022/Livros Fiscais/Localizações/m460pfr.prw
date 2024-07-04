/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ M460PFR	ณ Autor ณ RENATO NAGIB         ณ Data ณ 27.08.20010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ PERCEPCION FIJA SOBRE IVA   (URUGUAY)                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Generico 												   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION M460PFR(cCalculo,nItem,aInfo)
Local lXFis,xRet

lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M460PFRN(cCalculo,nItem,aInfo)
Else
	xRet:=M460PFRA()
Endif
Return(xRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460PFIA  บAutor  ณRENATO NAGIB        บFecha ณ  27/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo Percepcion Fija (Uruguai)                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ URUGUAI                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION M460PFRA()

	Local aItem,aImp
	Local nBase:=0,nAliq:=0,nAliqI:=0
	local cImpIncid
	
	aItem:=ParamIxb[1]
	aImp:=ParamIxb[2]
	cImpIncid:=aImp[10]

	dbSelectArea('SFC')
	SFC->(DbSetOrder(2))
	If SFC->(DbSeek(xFilial("SFC")+Avkey(aItem[1],'FC_TES')+AvKey(aImp[1],'FC_IMPOSTO')))
		cImpIncid:=Alltrim(SFC->FC_INCIMP)
	Endif
	
	dbSelectArea('SFB')
	SFB->(DbSetOrder(1))
	If SFB->(DbSeek(xFilial("SFB")+Alltrim(cImpIncid)))
		nAliqI:=SFB->FB_ALIQ
	Endif
	dbSelectArea('SFF')
	SFF->(dbSetOrder(9))
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(cImpIncid)))
		nAliqI:=SFF->FF_ALIQ			
	EndIf

	If SFB->(DbSeek(xfilial("SFB")+Alltrim(aImp[1])))
		nAliq:=SFB->FB_ALIQ
	endif
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(aImp[1])))
		nAliq:=SFF->FF_ALIQ			
	EndIf

	nBase:=aItem[3]+aItem[4]+aItem[5]//valor total + frete - Descontos
	nBase:=nBase*(nAliqI/100)
	aImp[02]:=nAliq
	aImp[03]:=nBase
	aImp[04]:=(nAliq * nBase)/100
	
Return(aImp)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460PFIN  บAutor  ณMarcello Gabriel    บFecha ณ  24/09/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo Percepcion Fija (Uruguai)                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION M460PFRN(cCalculo,nItem,aInfo)

	Local xRet
	Local nBase:=0,nAliq:=0,nAliqI:=0
	local cImpIncid:=""
	
	dbSelectArea('SFC')
	SFC->(DbSetOrder(2))
	If SFC->(DbSeek(xFilial("SFC")+Avkey(MaFisRet(nItem,"IT_TES"),'FC_TES')+AvKey(aInfo[1],'FC_IMPOSTO')))
		cImpIncid:=Alltrim(SFC->FC_INCIMP)
	Endif
	
	dbSelectArea('SFB')
	SFB->(DbSetOrder(1))
	If SFB->(DbSeek(xFilial("SFB")+Alltrim(cImpIncid)))
		nAliqI:=SFB->FB_ALIQ
	Endif
	dbSelectArea('SFF')
	SFF->(dbSetOrder(9))
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(cImpIncid)))
		nAliqI:=SFF->FF_ALIQ			
	EndIf

	If SFB->(DbSeek(xfilial("SFB")+Alltrim(aInfo[1])))
		nAliq:=SFB->FB_ALIQ
	endif
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(aInfo[1])))
		nAliq:=SFF->FF_ALIQ			
	EndIf

	Do Case
		Case cCalculo=="B"
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")- MaFisRet(nItem,"IT_DESCONTO")
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			xRet:=(nAliq * nBase)/100
	EndCase
Return(xRet)

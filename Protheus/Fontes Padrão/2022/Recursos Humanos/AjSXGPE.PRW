#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXGPE.CH"
#INCLUDE "SHELL.CH"

Main function GPELoad()

	Local lRet		:= .T.

	lRet := fChkConv12()
	If !lRet
		Return
	Endif

Return .T.

/*/{Protheus.doc} fChkConv12
Checa preenchimento de campos P12 pelo GPECONV.
/*/
Function fChkConv12()
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local lTemSRA	:= .T.
	Local lTemSRD	:= .T.
	Local lRhConv := SuperGetMV("MV_RHCONV",,.F.)
	Local cOrder:= ''

	if(lRhConv)
		cOrder:= 'RA_FILIAL+RA_PROCES+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT'		
		SRA->(dbSetOrder(RetOrder("SRA",cOrder)))	
		SRA->(dbGoTop())
		lTemSRA := (!SRA->(Eof()) .AND. Empty(SRA->RA_PROCES))	

		cOrder:= 'RD_FILIAL+RD_PROCES+RD_PERIODO+RD_SEMANA+RD_ROTEIR+RD_CC+RD_MAT'		
		SRD->(dbSetOrder(RetOrder("SRD",cOrder)))
		SRD->(dbGoTop())	
		lTemSRD := (!SRD->(Eof()) .AND. Empty(SRD->RD_PERIODO))

		if(lTemSRA .Or. lTemSRD)
			lRet := .F.
			Final("A base deve ser convertida para atender a P12. Verificar a documentação"," referente ao GPECONV disponivel no TDN no link: http://tdn.totvs.com/x/XMJhE")
		Endif
	endIf

	RestArea(aArea)
Return (lRet)

#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRM002  º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recalcula do saldo dos clientes por safra e armazem.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AGRM002()
	Private cPerg := 'AGRM02'
	Private nEnBrut := 0
	Private nEnDesc := 0
	Private nEnExtr := 0
	Private nEnLiqu := 0
	Private nEnTrfs := 0
	Private nSdBrut := 0
	Private nSdDesc := 0
	Private nSdExtr := 0
	Private nSdLiqu := 0
	Private nSdTrfs := 0
	Private nSaldoI := 0
	Private lExclSA1:= .F.
	Private lExclNPK:= .F.
	Private lExclNPL:= .F.


	If .Not. Pergunte(cPerg,.T.)
		Return()
	Else

		//Verificação do modo de uso de tabelas
		fVerModo()

		Processa({|| fProcessa() },'Recalcula Saldos dos Clientes')

	EndIf
Return()


Static Function fProcessa()

	dbSelectArea('SA1')
	dbSetOrder(1)
	ProcRegua(0)
	dbGotop()
	dbSeek(xFilial('SA1')+AllTrim(MV_PAR02)+AllTrim(MV_PAR03))
	//While .Not. Eof() .And. xFilial('SA1')==cFilial .And. A1_COD >= MV_PAR02 .AND. A1_LOJA>=MV_PAR03 .And. A1_COD <=MV_PAR04 .AND. A1_LOJA<=MV_PAR05
	While .Not. Eof() .And. A1_COD >= MV_PAR02 .AND. A1_LOJA>=MV_PAR03 .And. A1_COD <=MV_PAR04 .AND. A1_LOJA<=MV_PAR05
		dbSelectArea('NNR')
		dbSetOrder(1)
		dbSeek(xFilial('NNR')+AllTrim(MV_PAR06))
		While .Not. Eof() .And. NNR_CODIGO>=MV_PAR06 .And. NNR_CODIGO<=MV_PAR07

			dbSelectArea('NPL')
			dbSetOrder(1)
			If dbSeek(xFilial('NPL')+SA1->A1_COD+SA1->A1_LOJA+MV_PAR01+NNR->NNR_CODIGO)
				RecLock('NPL',.F.)
				dbDelete()
				MsUnLock()
			EndIf

			fSaldoI( SA1->A1_COD+SA1->A1_LOJA,NNR->NNR_CODIGO)
			fEntrada(SA1->A1_COD+SA1->A1_LOJA,NNR->NNR_CODIGO)
			fSaida(  SA1->A1_COD+SA1->A1_LOJA,NNR->NNR_CODIGO)

			If nSaldoI+(nEnBrut+nEnDesc+nEnExtr+nEnLiqu+nEnTrfs+nSdBrut+nSdDesc+nSdExtr+nSdLiqu+nSdTrfs) > 0
				RecLock('NPL',.T.)
				NPL->NPL_FILIAL := xFilial('NPL')
				NPL->NPL_CODCLI := SA1->A1_COD
				NPL->NPL_LOJCLI := SA1->A1_LOJA
				NPL->NPL_NOMCLI := SA1->A1_NOME
				NPL->NPL_SAFRA  := MV_PAR01
				NPL->NPL_ARM    := NNR->NNR_CODIGO
				NPL->NPL_ENBRUT := nEnBrut
				NPL->NPL_ENDESC := nEnDesc
				NPL->NPL_ENEXTR := nEnExtr
				NPL->NPL_ENLIQU := nEnLiqu
				NPL->NPL_ENTRFS := nEnTrfs
				NPL->NPL_SDBRUT := nSdBrut
				NPL->NPL_SDDESC := nSdDesc
				NPL->NPL_SDEXTR := nSdExtr
				NPL->NPL_SDLIQU := nSdLiqu
				NPL->NPL_SDTRFS := nSdTrfs
				NPL->NPL_SALDO  := (nSaldoI+nEnLiqu+nEnTrfs)-(nSdLiqu+nSdTrfs)
				MsUnLock()
			EndIf

			nEnBrut := 0
			nEnDesc := 0
			nEnExtr := 0
			nEnLiqu := 0
			nEnTrfs := 0
			nSdBrut := 0
			nSdDesc := 0
			nSdExtr := 0
			nSdLiqu := 0
			nSdTrfs := 0
			nSaldoI := 0

			dbSelectArea('NNR')
			dbSkip()
			IncProc()
		EndDo

		dbSelectArea('SA1')
		dbSkip()
		IncProc()
	EndDo

Return()

//Verificação do modo de uso de tabelas
Static Function fVerModo()
	Local aArea := GetArea()

	If FWAliasInDic("SA1")

		If FWModeAccess('SA1',3) == 'C'

			lExclSA1:= .F.

		Else

			lExclSA1:= .T.

		EndIf

	Else

		// Exibe Help devido a inexistência da tabela SA1 e sai da rotina
		Help('',1,'AGRM0021',,"SA1 não encontrado no SX2",4,1)
		Return

	EndIf

	If FWAliasInDic("NPK")

		If FWModeAccess('NPK',3) == 'C'

			IF lExclSA1 

				// Exibe Help devido a incompatibilidade entre SA1 e NPK
				Help('',1,'AGRM0024',,"SA1 exclusivo não pode ter NPK compartilhado",4,1)
				Return  

			Else

				lExclNPK:= .F.

			EndIf

		Else

			lExclNPK:= .T.

		EndIf

	Else

		// Exibe Help devido a inexistência da tabela NPK e sai da rotina
		Help('',1,'AGRM0022',,"NPK não encontrado no SX2",4,1)
		Return	

	EndIf

	If FWAliasInDic("NPL")

		If FWModeAccess('NPL',3) == 'C'

			IF lExclNPK 

				// Exibe Help devido a incompatibilidade entre NPK e NPL
				Help('',1,'AGRM0025',,"NPK exclusivo não pode ter NPL compartilhado",4,1)
				Return  

			Else

				lExclNPL:= .F.

			EndIf

		Else

			lExclNPL:= .T.

		EndIf	

	Else

		// Exibe Help devido a inexistência da tabela NPL e sai da rotina
		Help('',1,'AGRM0023',,"NPL não encontrado no SX2",4,1)
		Return	

	EndIf

	If (lExclNPK <> lExclNPL)

		// Exibe Help devido a incompatibilidade entre NPK e NPL e sai da rotina
		Help('',1,'AGRM0026',,"NPL e NPK devem ter modo de acesso igual",4,1)
		Return

	EndIf		      

	RestArea(aArea)
Return

Static Function fSaldoI(cCliente, cArm)

	dbSelectArea('NPK')
	dbSetOrder(1)
	If dbSeek(xFilial('NPK')+cCliente+MV_PAR01+cArm)

		nSaldoI := NPK->NPK_SLDINI

	EndIf

Return()



Static Function fEntrada(cCliente, cArm)
	Local cFiltro := ''

	dbSelectArea('NPO')

	If MV_PAR08 = 1
		cFiltro := "NPO_FILIAL>='"+MV_PAR09+"' .And. NPO_FILIAL<='"+MV_PAR10+"' .And. "	
	Else
		cFiltro := "NPO_FILIAL=='"+xFilial('NPO')+"' .And. "
	EndIf
	cFiltro += "NPO_SAFRA=='"+MV_PAR01+"' .And. "
	cFiltro += "NPO_CODCLI+NPO_LOJCLI=='"+cCliente+"' .And. "
	cFiltro += "NPO_ARM=='"+cArm+"'"
	IndRegua('NPO',CriaTrab(NIL,.F.),'NPO_FILIAL+NPO_SAFRA+NPO_CODCLI+NPO_LOJCLI+NPO_ARM',,cFiltro,"Selecionando Registros ...")

	dbSelectArea('NPO')
	dbGotop()
	While .Not. Eof()

		nEnBrut += NPO_PSSUBT
		nEnDesc += NPO_PSDESC
		nEnExtr += NPO_PSEXTR
		nEnLiqu += NPO_PSREAL

		dbSkip()
		IncProc()
	EndDo

	dbSelectArea('NPI')

	If MV_PAR08 = 1
		cFiltro := "NPI_FILIAL>='"+MV_PAR09+"' .And. NPI_FILIAL<='"+MV_PAR10+"' .And. "	
	Else
		cFiltro := "NPI_FILIAL=='"+xFilial('NPI')+"' .And. "
	EndIf
	cFiltro += "NPI_SAFRA=='"+MV_PAR01+"' .And. "
	cFiltro += "NPI_TIPO<>'I' .And. "
	cFiltro += "NPI_CDCLID+NPI_LJCLID=='"+cCliente+"' .And. "
	cFiltro += "NPI_ARM=='"+cArm+"'"
	IndRegua('NPI',CriaTrab(NIL,.F.),'NPI_FILIAL+NPI_SAFRA+NPI_CDCLID+NPI_LJCLID+NPI_ARM',,cFiltro,"Selecionando Registros ...")

	dbSelectArea('NPI')
	dbGotop()
	While .Not. Eof()

		nEnTrfs += NPI_QUANT

		dbSkip()
		IncProc()
	EndDo

Return()



Static Function fSaida(cCliente, cArm)
	Local cFiltro := ''

	dbSelectArea('NPR')

	If MV_PAR08 = 1
		cFiltro := "NPR_FILIAL>='"+MV_PAR09+"' .And. NPR_FILIAL<='"+MV_PAR10+"' .And. "	
	Else
		cFiltro := "NPR_FILIAL=='"+xFilial('NPR')+"' .And. "
	EndIf

	cFiltro += "NPR_SAFRA=='"+MV_PAR01+"' .And. "
	cFiltro += "NPR_CODCLI+NPR_LOJCLI=='"+cCliente+"' .And. "
	cFiltro += "NPR_ARM=='"+cArm+"'"
	IndRegua('NPR',CriaTrab(NIL,.F.),'NPR_FILIAL+NPR_SAFRA+NPR_CODCLI+NPR_LOJCLI+NPR_ARM',,cFiltro,"Selecionando Registros ...")

	dbSelectArea('NPR')
	dbGotop()
	While .Not. Eof()

		nSdBrut += NPR_PSSUBT
		nSdDesc += NPR_PSDESC
		nSdExtr += NPR_PSEXTR
		nSdLiqu += NPR_PSREAL

		dbSkip()
		IncProc()
	EndDo

	dbSelectArea('NPI')

	If MV_PAR08 = 1
		cFiltro := "NPI_FILIAL>='"+MV_PAR09+"' .And. NPI_FILIAL<='"+MV_PAR10+"' .And. "	
	Else
		cFiltro := "NPI_FILIAL=='"+xFilial('NPR')+"' .And. "
	EndIf
	cFiltro := "NPI_FILIAL=='"+xFilial('NPI')+"' .And. "
	cFiltro += "NPI_SAFRA=='"+MV_PAR01+"' .And. "
	cFiltro += "NPI_TIPO<>'I' .And. "
	cFiltro += "NPI_CDCLIO+NPI_LJCLIO=='"+cCliente+"' .And. "
	cFiltro += "NPI_ARM=='"+cArm+"'"
	IndRegua('NPI',CriaTrab(NIL,.F.),'NPI_FILIAL+NPI_SAFRA+NPI_CDCLID+NPI_LJCLID+NPI_ARM',,cFiltro,"Selecionando Registros ...")

	dbSelectArea('NPI')
	dbGotop()
	While .Not. Eof()

		nSdTrfs += NPI_QUANT

		dbSkip()
		IncProc()
	EndDo

Return()

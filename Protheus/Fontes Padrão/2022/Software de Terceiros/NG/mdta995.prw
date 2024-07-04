#Include 'Protheus.ch'
#Include 'MDTA995.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA995
Fun��o executada via Schedule para deletar exames programados n�o reali_
zados de funcion�rio que tenha sido demitido ou sofrido uma transfer�ncia
de filiais.
Update relacionado a rotina: UPDMDT58.prw
Para uso da rotina deve se cadastrar um schedule invocando a mesma, a
rotina ser� chamada uma vez para cada filial indicada nos parametros do
schedule.

@author Andr� Felipe Joriatti
@since 09/02/2013
@param array aEmpFil(obrigat�rio):aEmpFil[1]: empresa
								  aEmpFil[2]: filial
@return Nil
@version MP11
/*/
//---------------------------------------------------------------------

Function MDTA995( aEmpFil )

	Local aTabelas := { "TM5","TKZ","TM0","SRA","SRE" } // Exames do Func.,Log de MDTA995,Fichas M�dicas,Funcion�rios,Transfer�ncias

	//----------------
	// abre empresa
	//----------------
	fAbreEmpMDT( aEmpFil[1],aEmpFil[2],aTabelas )

	// processa dele��o de exames para filial
	fProcDelTM5( aEmpFil[1],aEmpFil[2] )

	// limpa toda �rea de trabalho (todo o ambiente aberto)
	RpcClearEnv()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAbreEmpMDT
Abre ambiente de empresa/filial definida nos parametros

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cCodEmp(obrigat�rio): indica a empresa que se deseja abrir.
@param String cCodFil(obrigat�rio): indica a filial que se deseja abrir.
@param Array aTable(obrigat�rio): indica tabelas a serem abertas.
@return boolean lOpen: indica sucesso ou falha na abertura da empresa.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fAbreEmpMDT( cCodEmp,cCodFil,aTable )

	Local lOpenEmp  := .F.

	If !( Type( "oMainWnd" ) == "O" )
		Private cAcesso  := ""
		Private cPaisLoc := ""

		RPCSetType( 3 ) // Nao utiliza licen�a

		// Abre empresa/filial/modulo/arquivos
		RPCSetEnv( cCodEmp,cCodFil,"","","MDT","",aTable )

		lOpenEmp := .T.
	EndIf

Return lOpenEmp

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcDelTM5
Deleta exames( TM5 ) de funcion�rios demitidos ou transferidos

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cEmp (obrigat�rio): indica empresa para consultar SRE
@param String cFil (obrigat�rio): indica filial para dele��o de exames
@return Nil
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fProcDelTM5( cEmp,cFil )

	Local lRet        := .F.
	Local aPeriodoDel := {}
	Local aFicsDel    := {} // array com fichas medicas de funcionarios a se deletar exames
	Local nI          := 0
	Local nT          := 0
	Local nContExa    := 0 // conta exames deletados no processamento
	Local nLock       := 5 // n�mero de vezes que vai tentar lockar o registro para tentar deletar
	Local lLock       := .F. // usada para saber se conseguiu lockar o registro para deletar.

	//--------------------------------------------
	// retorna data inicial e final para dele��o
	//--------------------------------------------
	aPeriodoDel := fRetPerDel( cFil )

	//-----------------------------------------------------
	// retorna fichas m�dicas para se deletar exames
	//-----------------------------------------------------
	aFicsDel := If( Len( aPeriodoDel ) != 0,fFunDmTr( cEmp,cFil,aPeriodoDel[1],aPeriodoDel[2] ),{} )

	//--------------------------------------------------------------------
	// processa dele��o de exames para as fichas m�dicas do array aFicsDel
	//--------------------------------------------------------------------
	For nI := 1 To Len( aFicsDel )
		DbSelectArea( "TM5" )
		DbGoTop()
		DbSetOrder( 01 ) // TM5_FILIAL+TM5_NUMFIC+DTOS(TM5_DTPROG)+TM5_EXAME
		DbSeek( xFilial( "TM5" ) + Padr( aFicsDel[nI][1],TAMSX3( "TM5_NUMFIC" )[1] ) )
		While !EoF() .And. TM5->TM5_FILIAL == xFilial( "TM5" ) .And. TM5->TM5_NUMFIC == Padr( aFicsDel[nI][1],TAMSX3( "TM5_NUMFIC" )[1] )

			//-------------------------------------------------------------
			// somente exames n�o realizados, nao relacionados ao ASO e
			// com data de programa��o maior que data de demiss�o/transf
			//-------------------------------------------------------------
			If Empty( TM5->TM5_DTRESU ) .And. Empty( TM5->TM5_NUMASO ) .And. TM5->TM5_DTPROG > aFicsDel[nI][2]

				lLock := .F.
				//----------------------------------------------
				// tenta lockar o registro por nLock vezes para
				// tentativa de dele��o.
				//----------------------------------------------
				For nT := 1 To nLock
					lLock := RecLock( "TM5",.F. )
					If lLock
						DbDelete()
						MsUnlock( "TM5" )
						nContExa++
						Exit
					Else
						//------------------------------------------
						// desativa processamento por 10 segundos
						// antes da pr�xima tentativa de lock
						//------------------------------------------
						Sleep( 10000 )
					EndIf
				Next nT

			EndIf

			DbSelectArea( "TM5" )
			DbSkip()
		EndDo
	Next nI

	//--------------------------------------------------
	// Grava log de processamento de dele��o de exames
	//--------------------------------------------------
	fGrvLogDel( cFil,SuperGetMv( "MV_NG2DEL",.F.," " ),nContExa )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fFunDmTr
Retorna fichas m�dicas de funcion�rios que foram transferidos ou demitidos
dentro do per�odo informado nos parametros para empresa/filial informada
nos parametros bem como a data da movimenta��o transf. ou demiss�o.

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cEmp(obrigat�rio): utilizado para consultar SRE
@param String cFil(obrigat�rio): indica filial da consulta.
@param Date   dInic (obrigat�rio): indica inicio do per�odo a verificar.
@param Date   dFim  (obrigat�rio): indica fim do per�odo a verificar.
@return Array aFics: array com matr�culas de funcion�rios demitidos
					 ou transferidos.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fFunDmTr( cEmp,cFil,dInicPer,dFimPer )

	Local aFics   := {}
	Local aArea   := GetArea()
	Local nIndTM0 := NGRETORDEM( "TM0","TM0_FILIAL+TM0_MAT",.F. )

	DbSelectArea( "SRA" )
	DbSetOrder( 01 ) // RA_FILIAL+RA_MAT
	DbSeek( xFilial( "SRA" ) )
	While !EoF() .And. SRA->RA_FILIAL == xFilial( "SRA" )

		// para funcion�rios demitidos no per�odo
		If !Empty( SRA->RA_DEMISSA ) .And. AllTrim( SRA->RA_SITFOLH ) == "D"
			If SRA->RA_DEMISSA > dInicPer .And. SRA->RA_DEMISSA < dFimPer
				aAdd( aFics,{ NGSEEK( "TM0",Padr( SRA->RA_MAT,TAMSX3( "TM0_MAT" )[1] ),nIndTM0,"TM0->TM0_NUMFIC" ),SRA->RA_DEMISSA } )
			EndIf
		Else // para funcion�rios transferidos no per�odo
			DbSelectArea( "SRE" ) // tabelas de transfer�ncias
			DbSetOrder( 01 ) // RE_EMPD+RE_FILIALD+RE_MATD+DTOS(RE_DATA)
			DbSeek( Padr( cEmp,TAMSX3( "RE_EMPD" )[1] ) + Padr( cFil,TAMSX3( "RE_FILIALD" )[1] ) + Padr( SRA->RA_MAT,TAMSX3( "RE_MATD" )[1] ) )
			While !EoF() .And. SRE->RE_FILIALD == Padr( cFil,TAMSX3( "RE_FILIALD" )[1] ) .And. SRE->RE_MATD == Padr( SRA->RA_MAT,TAMSX3( "RE_MATD" )[1] )

				// verifica se a data de transferencia do funcion�rio esta no per�odo
				If SRE->RE_DATA > dInicPer .And. SRE->RE_DATA < dFimPer
					aAdd( aFics,{ NGSEEK( "TM0",Padr( SRA->RA_MAT,TAMSX3( "TM0_MAT" )[1] ),nIndTM0,"TM0->TM0_NUMFIC" ),SRE->RE_DATA } )
					Exit
				EndIf

				DbSelectArea( "SRE" )
				DbSkip()
			EndDo
		EndIf

		DbSelectArea( "SRA" )
		DbSkip()
	EndDo

	RestArea( aArea )

Return aFics

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetPerDel
Retorna data inicial e data final para exclus�o de exames.

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cFil: indica filial para se consultar periodo.
@return array aDatas: indica per�odo de exclus�o de exames.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fRetPerDel( cFil )

	Local cPerUso  := AllTrim( SuperGetMv( "MV_NG2DEL",.F.," " ) )
	Local aDatas   := {}
	Local dLastDel := fRetDtLastDel( cFil )

	Do Case
		Case cPerUso == "D" // di�rio
			aAdd( aDatas,dLastDel )
			aAdd( aDatas,dDataBase - 1 )
		Case cPerUso == "S" // semanal
			aAdd( aDatas,dLastDel )
			aAdd( aDatas,dDataBase - 7 )
		Case cPerUso == "Q" // quinzenal
		 	aAdd( aDatas,dLastDel )
		 	aAdd( aDatas,dDataBase - 15 )
		Case cPerUso == "M" // mensal
			aAdd( aDatas,dLastDel )
			aAdd( aDatas,dDataBase - 30 )
		Case cPerUso == "T" // trimestral
			aAdd( aDatas,dLastDel )
			aAdd( aDatas,dDataBase - 90 )
	EndCase

Return aDatas

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrvLogDel
Grava log de dele��o de exames.

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cFil(obrigat�rio): indica a filial em que foi executado o processo.
@param String cTipPer(obrigat�rio): indica o tipo de periodicidade referente a execu��o.
@param Numeric cQtdTM5(obrigat�rio): indica quantidade de exames deletados.
@return Numeric cNumTKZ: n�mero do log executado.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fGrvLogDel( cFil,cTipPer,nQtdTM5 )

	Local dData   := dDataBase
	Local cHora   := Time()
	Local cNumTKZ := GETSXENUM( 'TKZ','TKZ_NUM' )
	Local aArea   := GetArea()

	DbSelectArea( "TKZ" )
	RecLock( "TKZ",.T. )
	TKZ->TKZ_FILIAL := cFil
	TKZ->TKZ_NUM    := cNumTKZ
	TKZ->TKZ_DTPRC  := dData
	TKZ->TKZ_HRPRC  := cHora
	TKZ->TKZ_TIPPER := cTipPer
	TKZ->TKZ_QTREG  := nQtdTM5
	MsUnlock( "TKZ" )

	CONFIRMSX8()

	RestArea( aArea )

Return cNumTKZ

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetDtLastDel
Retorna data do �ltimo processamento da rotina MDTA995 para a filial
informada no parametro.

@author Andr� Felipe Joriatti
@since 11/02/2013
@param String cFil: indica a filial para se fazer a consulta.
@return date dLastDelTM5: data do ultimo processamento, caso primeira vez,
						  ir� retornar uma 'data vazia'.
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fRetDtLastDel( cFil )

	Local dLastDelTM5 := CtoD( "  /  /    " )

	DbSelectArea( "TKZ" )
	DbSetOrder( 02 ) // TKZ_FILIAL+DTOS(TKZ_DTPRC)+TKZ_HRPRC+TKZ_TIPPER
	DbGoBottom()
	While !BoF()
		If TKZ->TKZ_FILIAL == Padr( cFil,TAMSX3( "TKZ_FILIAL" )[1] )
			dLastDelTM5 := TKZ->TKZ_DTPRC
			Exit
		Else
			DbSelectArea( "TKZ" )
			DbSkip( -1 )
		EndIf
	EndDo

Return dLastDelTM5
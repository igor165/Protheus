#include 'Protheus.ch'
#include 'MDTA640A.ch'
#include 'FWMVCDEF.ch'
#include 'Totvs.Ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDT640EVEN
Classe de evento do MVC Acidentes de Trabalho.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Class MDT640EVEN FROM FWModelEvent

    Data cChv2210 AS Caracter

	Method New()
	Method GridLinePosVld() //Valida��o LinOk da Grid
	Method GridPosVld() //Valida��o P�s-Valid da Grid
    Method ModelPosVld() //Valida��o P�s-Valid do Modelo
    Method InTTS() //Method executado durante o Commit

End Class

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Mehtod New para cria��o da estancia entre o evento e as classes.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class MDT640EVEN
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Method para p�s-valida��o do Modelo.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDT640EVEN

	Local lRet		:= .T.
	Local aAreaTNC	:= TNC->( GetArea() ) //Salva �rea posicionada.
	Local nOpca		:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo
	Local aOldTNY	:= {}
	Local o685Model

	Private aCHKSQL   := {}  // Vari�vel para consist�ncia na exclus�o (via SX9)
	Private aCHKDEL   := {}  // Vari�vel para consist�ncia na exclus�o (via Cadastro)
	Private cProcesso := ""

	// Recebe SX9 - Formato:
	// 1 - Dom�nio (tabela)
	// 2 - Campo do Dom�nio
	// 3 - Contra-Dom�nio (tabela)
	// 4 - Campo do Contra-Dom�nio
	// 5 - Condi��o SQL
	// 6 - Compara��o da Filial do Dom�nio
	// 7 - Compara��o da Filial do Contra-Dom�nio
	aCHKSQL := NGRETSX9( "TNC" )

	If nOpca == MODEL_OPERATION_DELETE //Exclus�o

		If !NGCHKDEL( "TNC" ) //Verifica a integridade da tabela.
			lRet := .F.
		EndIf

	EndIf

	If lRet .And. ( nOpca == MODEL_OPERATION_INSERT .Or. nOpca == MODEL_OPERATION_UPDATE )

		If AliasInDic( "TBV" ) .And. ( nOpca == MODEL_OPERATION_INSERT .Or. ;
			( nOpca == MODEL_OPERATION_UPDATE .And. oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) <> TNC->TNC_OCOPLA ) )
			dbSelectArea( "TBV" )
			dbSetOrder( 1 )

			If dbSeek( xFilial( "TBV" ) + oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) )
				dbSelectArea( "TBB" )
				dbSetOrder( 1 )

				If dbSeek( xFilial( "TBB" ) + TBV->TBV_CODPLA ) .And. MsgYesNo( STR0001 ) //"Devido ao acidente estar vinculado a uma ocorr�ncia, o plano emergencial precisa ser reavaliado, deseja alterar o seu status?"
					RecLock( "TBB", .F. )
					TBB->TBB_INDAVA := "2"
					TBB->( MsUnLock() )
				EndIf

			EndIf

		EndIf

		// Atualiza o Afastamento vinculado
		If nOpca == MODEL_OPERATION_UPDATE
			aArea 		:= GetArea()
			aAreaTNC 	:= TNC->( GetArea() )
			dbSelectArea( "TNY" )
			dbSetOrder( 5 )//TNY_FILIAL+TNY_ACIDEN+TNY_NUMFIC+DTOS(TNY_DTINIC)+TNY_HRINIC

			If dbSeek( xFilial( "TNY" ) + oModel:GetValue( 'TNCMASTER', 'TNC_ACIDEN' ) )
				//Chamado para manter a compatibilidade
				aOldTNY := MDT685TNYA()
				o685Model := FwLoadModel( "MDTA685" )
				o685Model:SetOperation( MODEL_OPERATION_UPDATE )
				o685Model:Activate()
				lCpoSr8 := .F.
				A685UPDATE( nOpca, o685Model )
				o685Model:DeActivate()
			EndIf

			RestArea( aAreaTNC )
			RestArea( aArea )
		EndIf

		// Verifica consistencia de CID em Diagnostico e Atestado m�dico
		If !Empty( oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ) )
			fConsisCID( oModel:GetValue( 'TNCMASTER', 'TNC_ACIDEN' ), oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), oModel:GetValue( 'TNCMASTER', 'TNC_CID' ) )
		EndIf

	EndIf

	//-------------------------------------------------------------------------------------
	// Realiza as valida��es das informa��es do evento S-2210 que ser�o enviadas ao Governo
	//-------------------------------------------------------------------------------------
	If lRet .And. FindFunction( "MDTIntEsoc" )
		//Vari�vel que guarda a chave atual do registro para busca do registro na RJE e do TAFKEY no TAF
		::cChv2210 := DToS( TNC->TNC_DTACID	) + StrTran( TNC->TNC_HRACID, ":", "" ) + TNC->TNC_TIPCAT

		lRet := MDTIntEsoc( "S-2210", nOpca, oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), , .F., oModel )
	EndIf

	RestArea( aAreaTNC ) //Retorna �rea.

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Method para integra��o com TAF durante o Commit.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method InTTS( oModel, cModelId ) Class MDT640EVEN

	Local nOpcx		:= oModel:GetOperation()
	Local lSendMail	:= SuperGetMv( "MV_NG2EMAC", .F., "N" ) == "S"

	If AliasInDic( "TBV" ) .And. nOpcx == MODEL_OPERATION_DELETE .Or. ;
		( nOpcx == MODEL_OPERATION_UPDATE .And. oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) <> TNC->TNC_OCOPLA )
		dbSelectArea( "TBV" )
		dbSetOrder( 1 ) // TBV_FILIAL+TBV_CODOCO+DTOS(TBV_DATA)+TBV_HORA

		If dbSeek( xFilial( "TBV" ) + oModel:GetValue( 'TNCMASTER', 'TNC_OCOPLA' ) )
			dbSelectArea( "TBB" )
			dbSetOrder( 1 ) // TBB_FILIAL+TBB_CODPLA

			If dbSeek( xFilial( "TBB" ) + TBV->TBV_CODPLA ) .And. MsgYesNo( STR0005 ) //"Devido ao acidente estar vinculado a uma ocorr�ncia, o plano emergencial precisa ser reavaliado, deseja alterar o seu status?"
				RecLock( "TBB", .F. )
				TBB->TBB_INDAVA := "2"
				TBB->( MsUnLock() )
			EndIf
		EndIf
	EndIf

	If lSendMail .And. ( nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx = MODEL_OPERATION_UPDATE ) //Caso Inclus�o ou Altera��o
		fSendMail()
	EndIf

	//-----------------------------------------------------------------
	// Realiza a integra��o das informa��es do evento S-2210 ao Governo
	//-----------------------------------------------------------------
	If FindFunction( "MDTIntEsoc" )
		MDTIntEsoc( "S-2210", nOpcx, oModel:GetValue( 'TNCMASTER', 'TNC_NUMFIC' ), , , oModel, , , ::cChv2210 )
	EndIf

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Method para P�s-Valida��o da linha da GRID.

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.
@param nLine - Num�rico - Numero da linha.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method GridLinePosVld( oSubModel, cModelId, nLina ) Class MDT640EVEN

	Local lRet 		 := .T.
	Local nLenCompl  := oSubModel:Length()
	Local nCont  	 := 0
	Local cCid		 := ""
	Local cGrCid	 := ""
	Local lValid	 := .T.

	If cModelId == "TNMDCOMPL" //Verifica se � a Grid desejada.

		cCid 	 := oSubModel:GetValue( "TKK_CID" ) //CID
		cGrCid	 := oSubModel:GetValue( "TKK_GRPCID" ) //Grupo CID

		If  Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
			lValid := .F.
		EndIf

		If lValid
			For nCont := 1 To nLenCompl
				oSubModel:GoLine( nCont )
				If nLenCompl > 1 .And. Empty( oSubModel:GetValue( "TKK_GRPCID" ) ) .And. !( oSubModel:IsDeleted() ) .And. Empty( oSubModel:GetValue( "TKK_CID" ) )
					Help( , , STR0002, , STR0006, 5, 5 )//"Informe um Grupo de CID ou um CID ."
					lRet := .F.
				EndIf
				If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
					If oSubModel:GetValue( "TKK_GRPCID" ) == cGrCid .And. Empty( cCid )
						Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) +" ' " + STR0008, 5, 5 )//"O campo" ## "deve ser preenchido quando j� existir outro CID do mesmo grupo."
						lRet := .F.
						Exit
					EndIf
				EndIf
				If  lRet .And. nCont <> 1 .And. Empty( cCid ) .And. Empty( cGrCid )
					//Mostra mensagem de Help
					Help( 1, " ", "OBRIGAT2", , , 3, 0 )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

	ElseIf cModelId == "TNMPARTE"

		If Empty( oSubModel:GetValue( "TYF_CODPAR" ) ) .Or. Empty( oSubModel:GetValue( "TYF_LATERA" ) )
			Help( , " ", STR0002, , STR0003 + " " + NGRETTITULO( "TYF_CODPAR" ) + STR0009 + NGRETTITULO( "TYF_LATERA" ) + STR0010, 5, 5, , , , , , { STR0011 } ) //"Os campos XXX e XXX s�o de preenchimento obrigat�rio!"##"Favor preench�-los!"
			lRet := .F.
		EndIf

	EndIf

Return lRet
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridPosVld
Method para P�s-Valida��o da GRID

@param oModel - Objeto - Modelo utilizado.
@param cModelId - Caracter - Id do modelo utilizado.

@class MDT640EVEN - Classe origem.

@author  Guilherme Freudenburg
@since   19/10/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Method GridPosVld( oSubModel, cModelID ) Class MDT640EVEN

	Local lRet 		 := .T.
	Local nLenCompl  := oSubModel:Length()
	Local nCont		 := 0
	Local cCid 		 := ""
	Local cGrCid	 := ""
	Local lCompDel   := !( oSubModel:IsDeleted() )
	Local lValid	 := .T.

	If cModelID == "TNMDCOMPL"

		cCid	:= oSubModel:GetValue( "TKK_CID" ) //CID
		cGrCid	:= oSubModel:GetValue( "TKK_GRPCID" ) //Grupo CID

		If  Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
			lValid := .F.
		EndIf

		If lValid
			For nCont := 1 To nLenCompl
				oSubModel:GoLine( nCont )
				If !( oSubModel:IsDeleted() ) //Verifica se registro est� deletado.
					If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
						If oSubModel:GetValue( "TKK_GRPCID" ) == M->TNC_GRPCID .And. ;
						( Empty( oSubModel:GetValue( "TKK_CID" ) ) .Or. Empty( M->TNC_CID ) ) .And. lCompDel
							Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) + " ' " + STR0008, 5, 5 ) //"o campo" ## "deve ser preenchido quando j� existir outro CID do mesmo grupo."
							lRet := .F.
							Exit
						EndIf
					EndIf
					If lRet .And. !Empty( oSubModel:GetValue( "TKK_GRPCID" ) )
						If oSubModel:GetValue( "TKK_GRPCID" ) == cGrCid .And. Empty( cCid )
							Help( , , STR0002, , STR0007 + " ' " + NGRETTITULO( "TKK_CID" ) + " ' " + STR0008, 5, 5 ) //"o campo" ## "deve ser preenchido quando j� existir outro CID do mesmo grupo."
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				If  lRet .And. nCont <> 1 .And. Empty( cCid ) .And. Empty( cGrCid )
					//Mostra mensagem de Help
					Help( 1, " ", "OBRIGAT2", , , 3, 0 )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf
	EndIf

Return lRet

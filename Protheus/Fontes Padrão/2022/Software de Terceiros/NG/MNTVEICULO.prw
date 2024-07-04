#Include "PROTHEUS.CH"
#Include "MNTVEICULO.CH"

// For�a a publica��o do fonte
Function _MntVeiculo()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntVeiculo
Classe de Veiculos

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
/*/
//------------------------------------------------------------------------------
Class MntVeiculo FROM MntBem

	Method New() CONSTRUCTOR

	// Metodos Publicos
	Method ValidBusiness()
	Method Upsert()
	Method Delete()

	// Metodos Privados
	Method IsTMS()

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Self O objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class MntVeiculo

	_Super:New()

	//TMS
	::SetAlias( 'DA3' )

	// Alias grid
	::SetAliasGrid( 'TT8' )

	// Define quais tabelas n�o relacionadas
	::SetNoDelete('DA3')

	// O informe da tabela n�o � obrigat�rio
	::SetOptional('DA3')

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidBusiness
M�todo que realiza a valida��o da regra de neg�cio da classe.

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return lValid Valida��o ok.
@obs este m�todo n�o � chamado diretamente.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness() Class MntVeiculo

	Local nLine
	Local cError := ''
	Local oModelTMS := FWLoadModel( "OMSA060" )
	Local lDtvSgCnt := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador

	//--------------------------------------------------------------------------
	// Valida��o inicial para frotas
	//--------------------------------------------------------------------------
	If GetRPORelease() < '12.1.033' .And. GetNewPar('MV_NGMNTFR','N') != 'S'
		::AddError( STR0001 ) // 'Para cadastro de ve�culos, precisa integra��o com Frotas(MV_NGMNTFR).'

	ElseIf .Not. ( ::GetValue('T9_CATBEM') $ '24' )
		::AddError( STR0002 ) //'Para cadastro de ve�culos, o bem precisa ser da categoria tipo 2 ou 4 (Ve�culo).'

	ElseIf ::GetValue('T9_CATBEM') == '2' .And.;
	!( GetNewPar('MV_NGMNTMS',' ') $ 'S/P' )
		::AddError( STR0003 ) //'Para cadastro de ve�culos integrados ao TMS, precisa integra��o com TMS(MV_NGMNTMS).'

	ElseIf GetNewPar('MV_NGMNTCC','N') == 'S' .And.;
		::GetValue('T9_PROPRIE') == '1' .And.  Empty(::GetValue('T9_DTCOMPR'))
		::AddError( STR0014 ) //"Quando o campo Propriet�rio (T9_PROPRIE) estiver com a op��o '1=Pr�prio' a Data de Compra (T9_DTCOMPR) � obrigat�ria."
	EndIf

	//--------------------------------------------------------------------------
	// Consistencia com a regra de negocio da classe de bens
	//--------------------------------------------------------------------------
	If ::IsValid()
		_Super:ValidBusiness()
	EndIf

	//--------------------------------------------------------------------------
	// Campos obrigat�rios do TMS
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::IsTMS()
		// Codigo do TMS
		If Empty( ::GetValue('T9_CODTMS') )

			::AddError( ::MsgRequired( "T9_CODTMS" ) )

			// Codigo da placa
		ElseIf Empty( ::GetValue('T9_PLACA') )

			::AddError( ::MsgRequired( "T9_PLACA" ) )

			// Codigo da Placa TMS
		ElseIf !Empty(::GetValue('T9_CODTMS') ) .And. Empty(::GetValue('DA3_PLACA') )

			::AddError( ::MsgRequired( "DA3_PLACA" ) )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Verifica se ja existe outro bem com o mesmo codigo TMS
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInsert() .And. ::IsTMS()
		cAliasQry := GetNextAlias()
		cQuery := "SELECT * "
		cQuery += "    FROM " + RetSqlName("ST9") + " ST9 "
		cQuery += "WHERE "
		cQuery += "    ST9.T9_FILIAL  = '" + xFilial( "ST9" ) + "' AND "
		cQuery += "    ST9.T9_CODTMS  = '" + ::GetValue('T9_CODTMS') + "' AND "
		cQuery += "    ST9.D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T. , "TOPCONN" , TCGENQRY( , , cQuery ),cAliasQry,.F.,.T.)
		If RecCount() > 0
			::AddError( STR0004 ) //"Ja existe Bem com o Codigo do TMS relacionado."
		EndIf
		( cAliasQry )->( dbCloseArea() )
	EndIf

	//--------------------------------------------------------------------------
	// Verifica se ja existe outro TMS com o mesmo codigo de bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::IsTMS()
		cAliasQry := GetNextAlias()
		cQuery := "SELECT * "
		cQuery += "    FROM " + RetSqlName("DA3") + " DA3 "
		cQuery += "WHERE "
		cQuery += "    DA3.DA3_FILIAL  = '" + xFilial( "DA3" ) + "' AND "
		cQuery += "    DA3.DA3_CODBEM  = '" + ::GetValue('T9_CODBEM') + "' AND "
		cQuery += "    DA3.DA3_COD    <> '" + ::GetValue('T9_CODTMS') + "' AND"
		cQuery += "    DA3.D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T. , "TOPCONN" , TCGENQRY( , , cQuery ),cAliasQry,.F.,.T.)
		If RecCount() > 0
			::AddError( STR0005 ) //"Ja existe TMS com o Codigo do Bem relacionado."
		EndIf
		( cAliasQry )->( dbCloseArea() )
	EndIf

	//--------------------------------------------------------------------------
	// Verifica ano de fabrica��o
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And.;
	!Empty(::GetValue('T9_ANOMOD')) .And.;
	!Empty(::GetValue('T9_ANOFAB')) .And.;
	Val(::GetValue('T9_ANOFAB')) > Val(::GetValue('T9_ANOMOD'))
		::AddError( STR0006 ) //"Ano de fabricacao devera ser menor ou igual ao ano do modelo"
	EndIf

	//--------------------------------------------------------------------------
	// Verifica se o tanque foi informado
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And.;
	!Empty(::GetValue('T9_TIPVEI') ) .And.;
	NGIFdbSeek('DUT',::GetValue('T9_TIPVEI'),1) .And.;
	!( DUT->DUT_CATVEI $ "34")

		lHaveTT8 := .F.
		aColsAux := ::GetCols( 'TT8' )

		For nLine := 1 To Len( aColsAux )

			//Somente linhas n�o-excluidas
			If aTail( aColsAux[nLine] )
				Loop
			EndIf

			//Verifica se a linha est� preenchida
			If !_Super:EmptyLine( 'TT8' , nLine )
				lHaveTT8 := .T.
				Exit
			EndIf
		Next

		If !lHaveTT8
			::AddError( STR0007 ) //"Para Bem da categoria ve�culo � obrigat�rio informar os dados do tanque de combust�vel."
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Consist�ncia tipo contador do tanque
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		aHeaderAux := ::GetHeader( 'TT8' )
		aColsAux := ::GetCols( 'TT8' )

		nCodTan := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TT8_CODCOM"})
		nTipCon := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TT8_TPCONT"})

		For nLine := 1 To Len( aColsAux )

			//Termina verifica��o, ao haver inconsistencia
			If !::IsValid() .Or. nTipCon == 0
				Exit
			EndIf

			//Somente linhas n�o-excluidas
			If aTail( aColsAux[nLine] )
				Loop
			EndIf

			//Ultima linha totalmente vazia, desconsidera
			If _Super:EmptyLine( 'TT8' , nLine )
				Loop
			EndIf

			cTipCon := aColsAux[nLine][nTipCon]

			If (::GetValue('T9_TEMCONT') = "S" .Or. !Empty(::GetValue('TPE_POSCON'))) .And. Empty(cTipCon)

				cError := STR0008 //"O bem possui controle por contador"

			ElseIf ::GetValue('T9_TEMCONT') = "S" .And.  Empty(::GetValue('TPE_POSCON')) .And. cTipCon = '2' .Or.;
			       (lDtvSgCnt .And. ::GetValue('TPE_SITUAC') = "2" .And. cTipCon = "2")

				cError := STR0009 //"Bem n�o tem contador 2"

			ElseIf ::GetValue('T9_TEMCONT') <> "S" .And.  !Empty(::GetValue('TPE_POSCON')) .And. cTipCon = '1'

				cError := STR0010 //"Bem n�o tem contador 1"

			ElseIf ::GetValue('T9_TEMCONT') <> "S" .And.  !Empty(::GetValue('TPE_POSCON')) .And. Empty(cTipCon)

				cError := STR0011 //"O bem possui contador 2"

			ElseIf ::GetValue('T9_TEMCONT') <> "S" .And. Empty(::GetValue('TPE_POSCON')) .And. !Empty(cTipCon)

				cError :=  STR0012 //"O bem n�o possui controle por contador"

			EndIf

			If .Not. Empty( cError )
				::AddError( cError + STR0013 ) //'Tanque de combust�vel'
			EndIf
		Next nLine
	EndIf

	//--------------------------------------------------------------------------
	// Verifica integridade com o TMS
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsDelete()

		If ::GetValue('T9_CATBEM') == '2' //Verifica se a categoria do bem � "Frota Integrada ao TMS".
			If !StaticCall( OMSA060,PosVldMdl,oModelTMS ) //Executa a fun��o 'PosVldMdl()', validando integra��o.
				::AddError( oModelTMS:oModel:GetErrorMessage()[6] )
			EndIf
		EndIf

	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Upsert
M�todo para inclusao e alteracao dos alias definidos para a classe.

@author NG Inform�tica Ltda.
@since 10/10/2014
@version P11
@return lUpsert Opera��o ok.
@sample If oObj:valid()
oObj:upsert()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//------------------------------------------------------------------------------
METHOD Upsert() Class MntVeiculo

	Local aUpdPla := {}
	Local cQuery  := ''
	Local cOldPla := ST9->T9_PLACA
	Local nInd    := 0

	//carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	BEGIN TRANSACTION

		_Super:upsert()

		/*---------------------------------------------------------------+
		| Repassa a altera��o do campo T9_PLACA para tabelas associadas. |
		+---------------------------------------------------------------*/
		If ::IsValid() .And. ::IsUpdate() .And. ::GetValue( 'T9_PLACA' ) != cOldPla

			aUpdPla := { 'TQS' }

			For nInd := 1 To Len( aUpdPla )

				cQuery := " UPDATE "
				cQuery +=		RetSqlName( aUpdPla[nInd] )
				cQuery += " SET "
				cQuery += 		aUpdPla[nInd] + "_PLACA = " + ValToSQL( ::GetValue( 'T9_PLACA' ) )
				cQuery += " WHERE "
				cQuery +=		aUpdPla[nInd] + "_FILIAL = " + ValToSQL( xFilial( aUpdPla[nInd] ) ) + " AND "
				cQuery += 		aUpdPla[nInd] + "_PLACA  = " + ValToSQL( cOldPla ) + " AND "
				cQuery +=		"D_E_L_E_T_ = ' ' "

				If TcSQLExec( cQuery ) < 0

					::AddError( TCSQLError() )
					Exit

				EndIf
				
			Next nInd

		EndIf

		//--------------------------------------------------------------------------
		// Grava placa no registro do bem
		//--------------------------------------------------------------------------
		If ::IsValid() .And. ::IsTMS() .And. .Not. Empty(::GetValue('T9_CODTMS'))
			cQuery := "UPDATE "
			cQuery += RetSqlName( "ST9" ) + " "
			cQuery += "SET ""
			cQuery += "  T9_PLACA = '" + ::GetValue('DA3_PLACA') + "' "
			cQuery += "WHERE "
			cQuery += "  T9_FILIAL = '" + xFilial( "ST9" ) + "' AND "
			cQuery += "  T9_CODBEM = '" + ::GetValue('T9_CODBEM') + "' AND"
			cQuery += "  D_E_L_E_T_ <> '*' "
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
			EndIf
		EndIf

		//--------------------------------------------------------------------------
		// Remove qualquer associa��o do TMS com o bem em quest�o
		//--------------------------------------------------------------------------
		If ::IsValid() .And. ::IsTMS() .And. .Not. Empty(::GetValue('T9_CODBEM'))
			cQuery := "UPDATE "
			cQuery += RetSqlName( "DA3" ) + " "
			cQuery += "SET "
			cQuery += "  DA3_CODBEM = '"+Space(TamSX3('DA3_CODBEM')[1])+ "' "
			cQuery += "WHERE "
			cQuery += "  DA3_FILIAL = '" + xFilial( "DA3" ) + "' AND "
			cQuery += "  DA3_CODBEM = '" + ::GetValue('T9_CODBEM') + "' AND"
			cQuery += "  D_E_L_E_T_ <> '*' "
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
			EndIf
		EndIf

		//--------------------------------------------------------------------------
		// Associa o bem somente ao TMS informado
		//--------------------------------------------------------------------------
		If ::IsValid() .And. ::IsTMS() .And. .Not. Empty(::GetValue('T9_CODTMS'))
			cQuery := "UPDATE "
			cQuery += RetSqlName( "DA3" ) + " "
			cQuery += "SET ""
			cQuery += "  DA3_CODBEM = '" + ::GetValue('T9_CODBEM') + "' "
			cQuery += "WHERE "
			cQuery += "  DA3_FILIAL = '" + xFilial( "DA3" ) + "' AND "
			cQuery += "  DA3_COD    = '" + ::GetValue('T9_CODTMS') + "' AND"
			cQuery += "  DA3_PLACA  = '" + ::GetValue('T9_PLACA') + "' AND"
			cQuery += "  D_E_L_E_T_ <> '*' "
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
			EndIf
		EndIf

		//Apaga integra��o com o TMS
		If ::IsValid() .And. !::IsTMS() .And. Empty(::GetValue('T9_CODTMS'))
			cQuery := " UPDATE " + RetSqlName("DA3")
			cQuery += "    SET DA3_CODBEM  = '" + Space(Tamsx3('DA3_CODBEM')[1]) + "' "
			cQuery += "  WHERE DA3_FILIAL  = '" + xFilial( "DA3" )               + "' "
			cQuery += "    AND DA3_COD     = '" + DA3->DA3_COD                   + "' "
			cQuery += "    AND DA3_PLACA   = '" + DA3->DA3_PLACA                 + "' "
			cQuery += "    AND D_E_L_E_T_ <> '*' "
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
			EndIf
		EndIf

		//--------------------------------------------------------------------------
		// Grava relacionamento multi-empresa
		//--------------------------------------------------------------------------

		If ::IsValid() .And. ::GetValue('T9_CATBEM') == '4'

				If .Not. NGIFdbSeek( 'TTM' , ::GetValue('T9_CODBEM') , 1 )
					RecLock( 'TTM' , .T. )
					TTM->TTM_FILIAL := xFilial( 'TTM' )
					TTM->TTM_CODBEM := ::GetValue('T9_CODBEM')
				Else
					RecLock('TTM',.F.)
				EndIf

				TTM->TTM_PLACA  := ::GetValue('T9_PLACA')
				TTM->TTM_EMPROP := SM0->M0_CODIGO
				TTM->TTM_FILPRO := xFilial( "ST9" )
				TTM->TTM_CATBEM := ::GetValue('T9_CATBEM' )
				TTM->TTM_ALUGUE := ::GetValue('T9_ALUGUEL')
				TTM->TTM_PROPRI := ::GetValue('T9_PROPRIE')
				MsUnLock('TTM')


		EndIf

		//--------------------------------------------------------------------------
		// Finaliza processo de grava��o
		//--------------------------------------------------------------------------
		If !::IsValid()
			
			DisarmTransaction()

		EndIf

	END TRANSACTION

	MsUnlockAll()

Return ::IsValid()
//------------------------------------------------------------------------------
/*/{Protheus.doc}Delete
M�todo para exclus�o dos alias definidos para a classe.

@author NG Inform�tica Ltda.
@since 10/10/2014
@version P11
@return lDelete Confirma��o da opera��o.
@sample If oObj:valid()
oObj:upsert()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//------------------------------------------------------------------------------
METHOD Delete() Class MntVeiculo

	// Carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	BEGIN TRANSACTION

	//--------------------------------------------------------------------------
	// Exclui relacionamento multi-empresa
	//--------------------------------------------------------------------------
	If FieldPos("TTM_FILIAL") > 0 //pode ser removido a partir da 12.1.13

		If ::IsValid() .And. NGIFdbSeek( 'TTM' , ::GetValue('T9_CODBEM') ,1 )
			RecLock( 'TTM' , .F. )
			dbDelete()
			MsUnLock( 'TTM' )
		EndIf

	EndIf

	//--------------------------------------------------------------------------
	// Remove qualquer associa��o do TMS com o bem em quest�o
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsTMS() .And. .Not. Empty(::GetValue('T9_CODBEM'))
		cQuery := "UPDATE "
		cQuery += RetSqlName( "DA3" ) + " "
		cQuery += "SET ""
		cQuery += "  DA3_CODBEM = '"+Space(TamSX3('DA3_CODBEM')[1])+ "' "
		cQuery += "WHERE "
		cQuery += "  DA3_FILIAL = '" + xFilial( "DA3" ) + "' AND "
		cQuery += "  DA3_CODBEM = '" + ::GetValue('T9_CODBEM') + "' AND"
		cQuery += "  D_E_L_E_T_ <> '*' "
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui veiculo e relacionados
	//--------------------------------------------------------------------------
	_Super:Delete()

	//--------------------------------------------------------------------------
	// Finaliza processo de grava��o
	//--------------------------------------------------------------------------
	If !::IsValid()
		//END TRANSACTION
		//MsUnlockAll()
	//Else
		DisarmTransaction()
	EndIf

	END TRANSACTION
	MsUnlockAll()

Return ::IsValid()
//--------------------------------------------------------------------
/*/{Protheus.doc}IsTMS
Indica que � frota integrada com TMS

@author NG Inform�tica Ltda.
@since 10/10/2014
@version P11
/*/
//--------------------------------------------------------------------
Method IsTMS() Class MntVeiculo
Return ::GetValue('T9_CATBEM') == '2'

#INCLUDE 'MNTA625.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'   

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA626
Cria uma nova rotina chamada Cadastro de Medi��es do Tanque de Combust�vel do Posto Interno
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 28/09/2021
@return Nil  
/*/ 
//-------------------------------------------------------------------
Function MNTA626()

    Local oBrowse      := FWMBrowse():New()

	Private cPosto     := ''   // Vari�vel usada para consultas padr�o e tamb�m na fun��o MNT626BOM que � usada por outra tabela
	Private cLoja      := ''   // Vari�vel usada para consultas padr�o e tamb�m na fun��o MNT626BOM que � usada por outra tabela
	Private cTanque    := ''   // Vari�vel usada para consultas padr�o e tamb�m na fun��o MNT626BOM que � usada por outra tabela
	Private lPosto     := .T.  // Vari�vel usada no X3_WHEN da tabela TQL
	Private lTanque    := .T.  // Vari�vel usada no X3_WHEN da tabela TQN

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		oBrowse:SetAlias( 'TQK' )         // Alias da tabela utilizada
		oBrowse:SetMenuDef( 'MNTA626' )   // Indica qual o fonte que vai pegar o MenuDef
		oBrowse:SetDescription( STR0006 ) // 'Cadastro de Medi��es do Tanque de Combust�vel do Posto Interno'	

		oBrowse:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Inicializa o MenuDef com as suas op��es
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return fun��o, vai retornar as op��es padr�o do menu, como 'Incluir', 'Alterar', e 'Excluir'
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return FWMVCMenu( 'MNTA626' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Inicializa o ModelDef com as suas op��es
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 28/09/2021
@return objeto, leva as estruturas de metadado do dicion�rio de dados, utilizadas pelas classes Model e View
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTTH := FWFormStruct( 1, 'TQK', , .F. )
    
	 // Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA626', /*bPre*/, {||MNT626TDOK()}, /*bCommit*/, /*bCancel*/ )

	 // Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( 'MNTA626_TQK', Nil, oStructTTH, /*bPre*/, /*bPost*/, /*bLoad*/ )

	oModel:SetDescription( STR0006 ) // 'Cadastro de Medi��es do Tanque de Combust�vel do Posto Interno'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Inicializa o ViewDef com as suas op��es
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return object, Essa vari�vel vai ser respons�vel pela constru��o da View.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'MNTA626' )
	Local oView  := FWFormView():New()

	 // Objeto do model a se associar a view.
	oView:SetModel( oModel )

	 // Adiciona no nosso View um controle do tipo FormFields( antiga enchoice )
	oView:AddField( 'MNTA626_TQK', FWFormStruct( 2, 'TQK', , .T. ), /*cLinkID*/ )

	 // Criar um 'box' horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'MASTER', 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	 // Associa um View a um box
	oView:SetOwnerView( 'MNTA626_TQK', 'MASTER' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626TDOK
Faz as p�s valida��es, nesse momento s� est� validando o funcion�rio, e o posto,
essas valida��es s�o feitas aqui porque precisam da data da medi��o
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 28/10/2021
@return logica, informa se o registro passou ou n�o nas valida��es.
/*/
//-------------------------------------------------------------------
Function MNT626TDOK()

	Local lReturn := .T.
	Local oModel  := FWModelActive()
	Local cCodFun := oModel:GetValue( 'MNTA626_TQK', 'TQK_CODFUN')
	Local dDataMed := oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' )

	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

		// A fun��o NGFRHAFAST est� no fonte mntutil01, e faz a valida��o do funcion�rio inserido
		lReturn := ExistCpo( 'SRA', cCodFun) .And. NGFRHAFAST(cCodFun, dDataMed, dDataMed, .T. )
		If lReturn
			dbSelectArea( 'SRA' )
			dbSetOrder( 1 ) // Matricula + Nome
			If dbSeek( xFilial( 'SRA' ) + cCodFun ) .And. SRA->RA_SITFOLH == "D" .And. dDataMed >= SRA->RA_DEMISSA

				dbSelectArea( 'SX5' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'SX5' ) + '31' + SRA->RA_SITFOLH )

					Help( NIL, 1, STR0007, NIL, STR0022, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0029} ) // "Aten��o"###"Empregado demitido!"###"A data de demiss�o do funcion�rio � anterior a data da medi��o do tanque"

				EndIf

				lReturn := .F.

			EndIf
			
		EndIf

		If lReturn

			dbSelectArea("TQF")
			dbSetOrder(1) // Codigo + Loja
			If dbSeek(xFilial('TQF')+oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' ))
				If TQF->TQF_ATIVO == '2' .And. dDataMed >= TQF->TQF_DTDESA .And. ( Empty(TQF->TQF_DTREAT) .Or. dDataMed < TQF->TQF_DTREAT )
					Help( NIL, 1, STR0007, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031} ) // "Aten��o"###"O posto estava inativo na data da medi��o"###"Verifique novamente as datas de desativa��o/reativa��o do posto inserido"
					lReturn := .F. 
				EndIf
			EndIf
		
		EndIf

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626VLD
Recebe todas as requisi��es de valida��o do dicion�rio, e conforme o campo que solicitou,
chama a sua valida��o
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@param cCampo, caractere, carrega o nome do campo que solicitou a valida��o
@return logica, carrega um valor logico que indica se a valida��o que foi solicitada
foi bem sucedida.
/*/
//-------------------------------------------------------------------
Function MNT626VLD( cCampo )

	Local lReturn := .T.
	Local oModel  := FWModelActive()
	Local cPosto  := oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' )
	Local cLoja   := oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' )

	DO CASE 
	
		CASE cCampo == 'TQK_POSTO'
		 	
			lReturn := ExistCpo( 'TQF', cPosto )
		
		CASE cCampo == 'TQK_TANQUE'
			
			lReturn := ExistCpo( 'TQI', cPosto + cLoja + oModel:GetValue( 'MNTA626_TQK', 'TQK_TANQUE' ) )
		
		CASE cCampo == 'TQK_DTMEDI'
			
			lReturn := MNT626DTM()
		
		CASE cCampo == 'TQK_HRMEDI'
			
			lReturn := MNT626VALI() .And. MNT626HRM()
		
		CASE cCampo == 'TQK_QTDMED'
			
			lReturn := Positivo() .And. MNT626VALM() 
		
		CASE cCampo == 'TQK_CODFUN'
			
			// A fun��o NGFRHAFAST est� no fonte mntutil01, e faz a valida��o do funcion�rio inserido
			lReturn := ExistCpo( 'SRA', oModel:GetValue( 'MNTA626_TQK', 'TQK_CODFUN' ))

		CASE cCampo == 'TQK_LOJA'

			lReturn := ExistCpo( 'TQF', cPosto + oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' ) )

	END CASE

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626VALI

Valida a data e hora da medi��o do tanque de combustivel
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 28/09/2021
@return logica, define se a medi��o poder� ser realizada para a data e hora informada pelo usu�rio. 
/*/
//-------------------------------------------------------------------
Function MNT626VALI()

	Local oModel  := FWModelActive()
	Local lReturn := .T.
	Local aArea   := GetArea()
	Local cDtMedi := SUBSTR(DTOC(oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' )), 7, 4) + SUBSTR(DTOC(oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' )), 4, 2) + SUBSTR(DTOC(oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' )), 1, 2)
	Local cHrMedi := oModel:GetValue( 'MNTA626_TQK', 'TQK_HRMEDI' )
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry
		column TQK_DTMEDI as date
		SELECT TQK.TQK_DTMEDI, TQK.TQK_HRMEDI
			FROM %table:TQK% TQK
		WHERE	TQK.TQK_FILIAL  = %xFilial:TQK%
			AND  TQK.TQK_POSTO  = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' )%
			AND  TQK.TQK_LOJA   = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' )%
			AND  TQK.TQK_TANQUE = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_TANQUE' )%
			AND  (TQK.TQK_DTMEDI > %exp:cDtMedi%
            OR  TQK.TQK_DTMEDI = %exp:cDtMedi% AND TQK.TQK_HRMEDI >= %exp:cHRMedi%)
			AND TQK.%NotDel%
        ORDER BY TQK.TQK_DTMEDI DESC, TQK.TQK_HRMEDI DESC
	EndSql

	If (cAliasQry)->(!EoF())
			
		Help( NIL, 1, STR0007, NIL, STR0011 + Chr( 10 ) + Chr( 13 ) + STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0025} ) // 'ATEN��O'###'Data e Hora da medi��o n�o pode ser menor que o �ltima cadastrada.' // 'Data e Hora inferior a �ltima medi��o ou'###'data com hora ja cadastrada.'###'1) Confirme que a data e hora foram inseridas corretamente'
		lReturn := .F.

	EndIf

	(cAliasQry)->(dbCloseArea())
	
	RestArea( aArea )   


Return lReturn 			

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA626QTI
Fun��o para carregar a quantidade inicial
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return numerica, retorna o valor da quantidade inicial. 
/*/
//-------------------------------------------------------------------
Function MNTA626QTI()

	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local cAliasQry := GetNextAlias()
	Local nQtdIni   := 0

	BeginSQL Alias cAliasQry
		SELECT TQK.TQK_QTDMED
			FROM %table:TQK% TQK
		WHERE	TQK.TQK_FILIAL  = %xFilial:TQK%
			AND  TQK.TQK_POSTO  = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' )%
			AND  TQK.TQK_LOJA   = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' )%
			AND  TQK.TQK_TANQUE = %exp:oModel:GetValue( 'MNTA626_TQK', 'TQK_TANQUE' )%
			AND  TQK.%NotDel%
		ORDER BY TQK.TQK_DTMEDI DESC, TQK.TQK_HRMEDI DESC
	EndSql
	
	// Define a quantidade inicial do campo TQK_QTDINI
	nQtdIni := IIf( (cAliasQry)->( !EoF() ), (cAliasQry)->TQK_QTDMED, 0 )
	
	(cAliasQry)->(dbCloseArea())

	RestArea( aArea )   

Return nQtdIni	

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626VALM
Valida a quantidade medida no tanque
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return logica, define se a quantidade medida est� dentro da capacidade do tanque. 
/*/
//-------------------------------------------------------------------
Function MNT626VALM()

	Local lReturn := .T.
	Local oModel  := FWModelActive()

	DbSelectArea( 'TQI' )
	DbSetOrder( 1 ) // Posto + Loja + Tanque + Combustivel 

	If DBSeek( xFilial( 'TQI' ) + oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' ) + oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' ) + oModel:GetValue( 'MNTA626_TQK', 'TQK_TANQUE' ) ) .And.;
	 oModel:GetValue( 'MNTA626_TQK', 'TQK_QTDMED' ) > TQI->TQI_CAPMAX
		
		Help( NIL, 1, STR0007, NIL, STR0013 + Chr( 10 ) + Chr( 13 ) + STR0014, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0026} ) // 'ATEN��O'###'Quantidade medida � maior que a capacidade'###'m�xima do tanque.'###'1) A quantidade informada deve estar dentro da capacidade m�xima do tanque'
		lReturn := .F.
	
	EndIf

Return lReturn  

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626DTM
Valida se a data inserida n�o � maior que a data atual
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return logica, carrega o retorno da valida��o indicando se a data � ou n�o v�lida. 
/*/
//-------------------------------------------------------------------
Function MNT626DTM()

	Local lReturn := .T.
	Local oModel  := FWModelActive()

	If oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' ) > dDataBase
		
		Help( NIL, 1, STR0007, NIL, STR0018 + Chr( 10 ) + Chr( 13 ) + STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027} ) // 'ATEN��O'###'Data da Medicao do Tanque n�o pode ser ma-'###'ior que a Data corrente.'###'1) Verifique novamente a data inserida'
		lReturn := .F.
	
	EndIf

Return lReturn 

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626HRM
Valida se a hora inserida n�o � maior que a hora atual
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return logica, carrega o retorno da valida��o indicando se a hora � ou n�o v�lida. 
/*/
//-------------------------------------------------------------------
Function MNT626HRM()

	Local oModel     := FWModelActive()
	Local cHrComplt  := substr( Time(), 1, 5 )
	Local lReturn    := .T.

	If oModel:GetValue( 'MNTA626_TQK', 'TQK_HRMEDI' ) > cHrComplt .And. oModel:GetValue( 'MNTA626_TQK', 'TQK_DTMEDI' ) == dDatabase
		
		Help( NIL, 1, STR0007, NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0028} ) // 'ATEN��O'##'Hora da Medi��o do Tanque n�o pode ser maior que a hora corrente.'###'1) Verifique novamente a hora inserida'
		lReturn := .F.
	
	EndIf  

	If lReturn .And. !NGVALHORA(oModel:GetValue( 'MNTA626_TQK', 'TQK_HRMEDI' ), .F.)
		
		Help( NIL, 1, STR0007, NIL, STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027} ) // 'ATEN��O'##'Hora da medi��o n�o pode ser maior que 23:59.'###'1) Verifique novamente a data inserida'
		lReturn := .F.
	
	EndIf		

Return lReturn      

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT626TAN
Fun��o chamada pelo gatilho de sequ�ncia 001 do campo TQK_POSTO
@type Function
@author Jo�o Ricardo Santini Zandon�
@since 29/09/2021
@return caractere, retorna qual o valor a ser inserido no campo TQK_LOJA. 
/*/
//-------------------------------------------------------------------
Function MNT626TAN()

	Local oModel      := FWModelActive()
	Local cPostoUser  := oModel:GetValue( 'MNTA626_TQK', 'TQK_POSTO' )
	Local cLojaUser   := oModel:GetValue( 'MNTA626_TQK', 'TQK_LOJA' )
	cPosto            := cPostoUser

	If Empty( cLojaUser ) // Se o campo TQK_POSTO for preenchido na 'm�o'.

		cLoja := Posicione( 'SA2', 1, xFilial( 'SA2' ) + cPostoUser, 'A2_LOJA' )

	Else
		
		cLoja := cLojaUser
	
	EndIf
	
Return cLoja

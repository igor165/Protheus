#INCLUDE "OGA340.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fweventviewconsts.ch"

 Static __cCodCtr		:= nil	    // -- Será inicializada na funcao no Activate do Model (Devido a Error log se executado em MDI )--/	

/** {Protheus.doc} OGA340
Rotina para autorizacao de contratos de compra, venda e ou armazenagem

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAARM - Originação de Grãos
*/
Function OGA340( pcCodCtr )
	Local oMBrowse := Nil
	Local cFiltroDef := iIf( !Empty( pcCodCtr ), "NJP_CODCTR='"+pcCodCtr+"'", "" )
	
	If IsInCallStack("OGA260") .OR. IsInCallStack("OGA270") .OR. IsInCallStack("OGA280") .OR. IsInCallStack("OGA290")    
		__cCodCtr := pcCodCtr
	EndIf
	
	If NJR->NJR_MODELO = "3"
		Help(,,"HELP",,STR0049,1,0)
		Return 
	EndIf
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJP" )
	oMBrowse:SetDescription( STR0001 ) //"Autorizacao do Contrato"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA340" )
	
	oMBrowse:AddLegend( "NJP_STATUS=='A'", "GREEN"  , X3CboxDesc( "NJP_STATUS", "A" )   ) //"Aberta"
	oMBrowse:AddLegend( "NJP_STATUS=='I'", "YELLOW" , X3CboxDesc( "NJP_STATUS", "I" )   ) //"Iniciada"
	oMBrowse:AddLegend( "NJP_STATUS=='E'", "GRAY"   , X3CboxDesc( "NJP_STATUS", "E" )   ) //"Encerrada"

	oMBrowse:Activate()

Return()


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0005 	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0006	, "ViewDef.OGA340"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0007   	, "ViewDef.OGA340"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0008   	, "ViewDef.OGA340"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0009	, "OGA340E"			, 0, 4, 0, Nil } ) //"Encerrar"
	aAdd( aRotina, { STR0010   	, "ViewDef.OGA340"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0011  	, "ViewDef.OGA340"	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0012    , "ViewDef.OGA340"	, 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0042	, "OGA340HIS"       , 0, 7, 0, Nil } ) //"Histórico"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function ModelDef()
	Local oStruNJP := FWFormStruct( 1, "NJP" )
	Local oModel   := MPFormModel():New( "OGA340" , , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) } )
	Local nOperation := oModel:GetOperation() 

	If !Empty( __cCodCtr )
		oStruNJP:SetProperty( "NJP_CODCTR" , MODEL_FIELD_INIT , { | | __cCodCtr } ) 
		oStruNJP:SetProperty( "NJP_TIPO"   , MODEL_FIELD_VALID, { | oFields | ValCODIGO( oFields ) } )
	EndIf
	oStruNJP:SetProperty( "NJP_CODCTR" , MODEL_FIELD_VALID, {| oFields | ValCODIGO( oFields ) } )
	oStruNJP:SetProperty( "NJP_QTDINI" , MODEL_FIELD_VALID, {| oFields | ValQTDINI( oFields ) } )
	oStruNJP:SetProperty( "NJP_TIPO"   , MODEL_FIELD_WHEN,  {| oFields | vTipoWhen( oFields, nOperation ) } )
	
	If GetRpoRelease() < "12.1.033"
		oStruNJP:SetProperty( "NJP_SDOAUT" , MODEL_FIELD_INIT , { | | IIF( nOperation <> 3,(NJP->NJP_QTDAUT +NJP->NJP_QTDEXC) - NJP->NJP_QTDFCO,0) } ) 	
	EndIf

	oModel:AddFields( "NJPUNICO", Nil, oStruNJP )
	oModel:SetDescription( STR0001 ) //"Autorizacao do Contrato"
	oModel:GetModel( "NJPUNICO" ):SetDescription( STR0013   ) //"Dados da Autorizacao do Contrato"
	
	oModel:SetVldActivate( { | oModel | IniModelo( oModel ) } )
	oModel:SetActivate(   { || fIniModelo() } )
Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao do Contrato
*/
Static Function ViewDef()
	Local oStruNJP := FWFormStruct( 2, "NJP" )
	Local oModel   := FWLoadModel( "OGA340" )
	Local oView    := FWFormView():New()

	If ! Empty( __cCodCtr )
		oStruNJP:SetProperty( "NJP_CODCTR" , MVC_VIEW_CANCHANGE , .F. ) 
	EndIf
		
	oView:SetModel( oModel )
	
	oView:SetAfterViewActivate( { | oMod | fViewQtAut( oMod, oStruNJP ) } )
	
	
	oView:AddField( "VIEW_NJP", oStruNJP, "NJPUNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_NJP", "UM"   )
	oView:SetCloseOnOk( {||.t.} )

Return( oView )


/** {Protheus.doc} ValCODIGO
Validar o código do contrato e retornar a próxima sequencia do item

@param: 	Nil
@return:	.T. / .F.
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function ValCODIGO( oFields )
	Local aAreaAtu 	:= GetArea()
	Local cCodCtr  	:= oFields:GetValue( "NJP_CODCTR" )
	Local cNovoIt		:= ""
	
	If .Not. ExistCpo( 'NJR', cCodCtr )
		Return( .F. )
	EndIf
	
	If !VLDAUTCTR(cCodCtr)
		oFields:LoadValue( "NJP_CODCTR" , "")
		oFields:LoadValue( "NJP_ITEM", "" )
		Return( .F. )
	EndIf
	
	BeginSql Alias 'QryNJP'
		Select Max( NJP_ITEM ) As UltSeq
		  From %Table:NJP% NJP
		 Where NJP.NJP_CODCTR = %Exp:cCodCtr% 
		   And NJP.NJP_FILIAL = %xFilial:NJP% 
		   And NJP.%NotDel%
	EndSql
	
	If .Not. QryNJP->( Eof() )
		If .Not. Empty( AllTrim( QryNJP->( UltSeq ) ) )
			cNovoIt := Soma1( QryNJP->( UltSeq ) )
		Else
			cNovoIt := Soma1( Replicate( "0", TamSX3( "NJP_ITEM" )[1] ) )
		EndIf
	Else
		cNovoIt := Soma1( Replicate( "0", TamSX3( "NJP_ITEM" )[1] ) )
	EndIf
	QryNJP->( dbCloseArea( ) )
	
	oFields:LoadValue( "NJP_ITEM", cNovoIt )
	
	//--<< Inicializa os Campos virtuais >>--
	oFields:LoadValue( "NJP_TOTEFS", NJR->NJR_QTEFCO )
	oFields:LoadValue( "NJP_TOTEFI", NJR->NJR_QTEFIS )
	oFields:LoadValue( "NJP_TOTSFS", NJR->NJR_QTSFCO )
	oFields:LoadValue( "NJP_TOTSFI", NJR->NJR_QTSFIS )
	oFields:LoadValue( "NJP_SLEMBE", Og340InEmb( cCodCtr,'NJP_SLEMBE') )
	oFields:LoadValue( "NJP_SLEMBS", Og340InEmb( cCodCtr,'NJP_SLEMBS') )
	
	RestArea( aAreaAtu )
Return( .T. )


/** {Protheus.doc} ValQTDINI


@param: 	Nil
@return:	
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function ValQTDINI( oFields )
	Local aAreaAtu  := GetArea()
	Local lRetorno  := .t.
	Local nQtdIni   := oFields:GetValue( "NJP_QTDINI" )
	Local nQtdFco	:= oFields:GetValue( "NJP_QTDFCO" )
	Local nQtdFis	:= oFields:GetValue( "NJP_QTDFIS" )

	If nQtdIni < nQtdFco .Or. nQtdIni < nQtdFis

		If nQtdFco > 0 .Or. nQtdFis > 0
			Help( , , STR0014, , STR0015, 1, 0 ) //"AJUDA"###"A Quantidade Incial não pode ser inferior a quantidade ja movimentada!"
		EndIf
		If nQtdFco = 0 .And. nQtdFis = 0
			Help( , , STR0014, , STR0016, 1, 0 ) //"AJUDA"###"A Quantidade Incial não pode ser ZERO!"
		EndIf
		lRetorno := .f.
	
	EndIf

	If lRetorno
		oFields:SetValue( "NJP_QTDAUT", nQtdIni )
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} ValQTDINI


@param:     Nil
@return:    
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA340 - Autorizacao de Contrato
*/
Static Function vTipoWhen( oFields,  nOperation )
    Local aAreaAtu  := GetArea()
    Local lRetorno  := .t.
    Local nQtdFco   := oFields:GetValue( "NJP_QTDFCO" )

    If nOperation == MODEL_OPERATION_UPDATE .and. nQtdFco > 0
       lRetorno := .f.    
    EndIf

    RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} IniModelo


@param: 	Nil
@return:	
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function IniModelo( oModel )
	Local lRetorno   	:= .T.
	Local aAreaNJF		:= NJF->(GETAREA())
	Local nOperation    := oModel:GetOperation() 
    
	If nOperation != MODEL_OPERATION_VIEW 
       	If !Empty(__cCodCtr)
       		lRetorno := VLDAUTCTR( __cCodCtr )
       	ElseIf nOperation != MODEL_OPERATION_INSERT
       		lRetorno := VLDAUTCTR( NJP->(NJP_CODCTR) )
       	EndIf
    EndIf

    If lRetorno .and. nOperation == MODEL_OPERATION_DELETE 
		
		dbSelectArea( 'NJF' )
		dbSetOrder( 5 )
		If dbSeek( xFilial( 'NJF' ) + NJP->(NJP_CODCTR+NJP_ITEM)) .and. ! ISInCallStack('OGA180') // Protegendo chamada de execauto do OGA180
			Help( , , STR0014, , STR0046, 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
			lRetorno := .f.
		EndIf		

		If lRetorno .and. (NJP->( NJP_QTDFCO ) > 0 .Or. NJP->( NJP_QTDFIS ) > 0 .Or. NJP->( NJP_VLRFIS ) > 0) 

			Help( , , STR0014, , STR0017, 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
			lRetorno := .f.

		EndIf
	EndIf
	
	If lRetorno .and. nOperation == MODEL_OPERATION_UPDATE
		dbSelectArea('NJF')
	 	NJF->( dbSetOrder( 5 ) )	
		If NJF->(dbSeek( xFilial( "NJF" ) + NJP->(NJP_CODCTR+NJP_ITEM))) .and. ! ISInCallStack('OGA180') // Protegendo chamada de execauto do OGA180
			Help( , , STR0014, , STR0047, 1, 0 ) //"AJUDA"###"Não é Possivel Alterar Esta -Autorização- Pois Foi Criada Por Outra Rotina!"
			lRetorno := .f.
		EndIf 
		If lRetorno .and. NJP->NJP_STATUS == "E"
		   Help( , , STR0014, , STR0052, 1, 0 ) //"AJUDA"###"Autorização -Encerrada- Não é possivel alterar"
		   lRetorno := .f.
       EndIf
	EndIf		

	RestArea( aAreaNJF )

Return( lRetorno )


/** {Protheus.doc} PosModelo


@param: 	Nil
@return:	
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function PosModelo( oModel )
	Local lRetorno   		:= .t.
	Local nOperation 		:= oModel:GetOperation()
	Local nQtdIni     	:= oModel:GetValue( "NJPUNICO" , "NJP_QTDINI" )
	Local nQtdAut        := oModel:GetValue( "NJPUNICO" , "NJP_QTDAUT" )
	Local cCodCtr  		:= oModel:GetValue( "NJPUNICO" , "NJP_CODCTR" )
	Local cTipo  			:= oModel:GetValue( "NJPUNICO" , "NJP_TIPO" )
	Local nQtdFco        := oModel:GetValue( "NJPUNICO" , "NJP_QTDFCO" )	
	Local nQtAutoriz     := 0 //Quantidade disp a Autorizar.
	
	If nOperation == MODEL_OPERATION_INSERT //.or. nOperation == MODEL_OPERATION_UPDATE ## foi comentado pois não permitia alteração
	
		/** Validar quantidade total do contrato */
		
		dbSelectArea( "NJR" )
		dbSetOrder( 1 )
		IF NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ) )
		
			IF cTipo == 'E' 
				nQtAutoriz := NJR->NJR_QTDCTR -  NJR->NJR_AUTENT
			ElseIF cTipo == 'S' 
				nQtAutoriz := NJR->NJR_QTDCTR - NJR->NJR_AUTSAI
			EndIF
			
		EndIF
		If nQtAutoriz < nQtdIni
			Help( , , STR0014, , STR0044 + Transform(nQtAutoriz ,"@E 9999,999,999.999"), 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
			lRetorno := .f.
		EndIF
		
	elseIf nOperation == MODEL_OPERATION_UPDATE /*validações de update*/
	   //nao deixa informar valor maior que do contrato e as autenticações já realizadas
	   
		   dbSelectArea( "NJR" )
		   dbSetOrder( 1 )
		   IF NJR->(dbSeek( xFilial( "NJR" ) + cCodCtr ) )
	            IF cTipo == 'E' 
	                nQtAutoriz := NJR->NJR_QTDCTR -  NJR->NJR_AUTENT
	            ElseIF cTipo == 'S' 
	                nQtAutoriz := NJR->NJR_QTDCTR - NJR->NJR_AUTSAI
	            EndIF
	       EndIF
                
       nQtAutNJP := NJP->NJP_QTDAUT		//Posicione('NJP',1,xFilial('NJP')+cCodCtr+cCodItem,'NJP_QTDAUT') //pega a quantidade já autorizada
       
       If (nQtAutoriz + nQtAutNJP)  < nQtdAut //nao esta salvando o segundo valor
            Help( , , STR0014, , STR0044 + Transform(nQtAutoriz ,"@E 9999,999,999.999"), 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
            lRetorno := .f.
       EndIF  
       
       if lRetorno
           if nQtdFco > nQtdAut //nao deixa passar se o valor for inferior a quantidade entregue para esta autorização
                Help( , , STR0014, , STR0045 + Transform(nQtdFco ,"@E 9999,999,999.999"), 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
                lRetorno := .f. 
           endif      
       endIf       
       
	EndIf
	
Return( lRetorno )

/** {Protheus.doc} fViewQtAut
Verifica se o campo vai ser utilizado

@param:     oNJP - model ativo
@return:    Atualizado na view;
@author:    Agroindustria
@since:     09/05/2015
@Uso:       OGA340 - Autorização de Contrato
*/
Static Function fViewQtAut( oModel, oNJP)
      
    If oModel:GetOperation() != MODEL_OPERATION_UPDATE
        oNJP:SetProperty( "NJP_QTDAUT" , MVC_VIEW_CANCHANGE , .F. ) 
    Endif
    
Return( nil )
/** {Protheus.doc} GrvModelo


@param: 	Nil
@return:	
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA340 - Autorizacao de Contrato
*/
Static Function GrvModelo( oModel )
	Local aAreaAtu		:= GetArea()
	Local cTitulo		:= ""
	Local cMensagem		:= ""
	Local nOperation 	:= oModel:GetOperation()
	Local oFldNJP		:= oModel:GetModel( "NJPUNICO" )

	If nOperation == MODEL_OPERATION_INSERT
		cTitulo 	:= STR0018 //"Inclusão Autorização de Embarque/Desembarque"
		AGRGRAVAHIS(,,,,{"NJP",xFilial("NJP")+oFldNJP:Getvalue('NJP_CODCTR')+oFldNJP:Getvalue('NJP_ITEM'),"3",STR0007}) //Incluir
	EndIf
	If nOperation == MODEL_OPERATION_UPDATE
		cTitulo 	:= STR0019 //"Alerada Autorização de Embarque/Desembarque"
		AGRGRAVAHIS(,,,,{"NJP",NJP->NJP_FILIAL+NJP->NJP_CODCTR+NJP->NJP_ITEM,"4",STR0008}) //Alterar
	EndIf
	If nOperation == MODEL_OPERATION_DELETE
		cTitulo 	:= STR0020 //"Excluida Autorização de Embarque/Desembarque"
		AGRGRAVAHIS(,,,,{"NJP",NJP->NJP_FILIAL+NJP->NJP_CODCTR+NJP->NJP_ITEM,"5",STR0010}) //Excluir
	EndIf
	
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial("NJR") + oFldNJP:GetValue( "NJP_CODCTR" ) ) )
	cMensagem	:= Chr( 13 ) + Chr( 10 )
	cMensagem	+= STR0021 + AllTrim(Posicione("NJ0",1,xFilial("NJ0")+NJR->(NJR_CODENT)+NJR->(NJR_LOJENT),"NJ0_NOME") ) + " - " + AllTrim( Posicione("NJ0",1,xFilial("NJ0")+NJR->(NJR_CODENT)+NJR->(NJR_LOJENT),"NJ0_NOMLOJ")) + Chr( 13 ) + Chr( 10 )  //"- - - - Entidade: "
	cMensagem	+= STR0022 + oFldNJP:GetValue( "NJP_CODCTR" ) + " - " + AllTrim( NJR->( NJR_DESCRI ) ) + Chr( 13 ) + Chr( 10 )  //"- - - - Contrato: "
	cMensagem	+= STR0023 + oFldNJP:GetValue( "NJP_ITEM" )   + Chr( 13 ) + Chr( 10 ) //"- - -Autorização: "
	cMensagem	+= STR0024 + Posicione('SB1',1,xFilial('SB1')+NJR->(NJR_CODPRO),'B1_DESC')  + Chr( 13 ) + Chr( 10 ) //"- - - - -Produto: "
	cMensagem	+= STR0025 + Transform( oFldNJP:GetValue( "NJP_QTDAUT" ), PesqPict( "NJP", "NJP_QTDAUT" ) ) + Chr( 13 ) + Chr( 10 ) //"- - - Quantidade: "
	cMensagem	+= STR0026 + NJR->( NJR_UM1PRO )   + Chr( 13 ) + Chr( 10 ) //"- Unidade Medida: "
	cMensagem	+= STR0027 + DtoC( oFldNJP:GetValue( "NJP_DATINI" ) ) + Chr( 13 ) + Chr( 10 ) //"- - Data Inicial: "
	cMensagem	+= STR0028 + DtoC( oFldNJP:GetValue( "NJP_DATFIM" ) ) + Chr( 13 ) + Chr( 10 ) //"- - - Data Final: "
	cMensagem	+= STR0029 + STR0030 + Chr( 13 ) + Chr( 10 ) //"- - - - - Status: "###"Autorizada!!!"

	FWFormCommit( oModel )

	dbSelectArea( "NJR" )
	dbSetOrder( 1 )
	If dbSeek( xFilial("NJR") + NJP->( NJP_CODCTR ) )
		//////////////////////////
		// Atualiza autorizações
		//////////////////////////
		OGX010QAut()
	EndIf

	EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "NJO", FW_EV_LEVEL_INFO, "", cTitulo, cMensagem, .t. )

	RestArea( aAreaAtu )
Return( .t. )


/** {Protheus.doc} OGA340E
	Encerra a autorização

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAARM - Originação de Grãos
*/
Function OGA340E( )
	Local aAreaNJP	:= NJP->(GetArea())
	Local cTitulo	:= ""
	Local cMensagem	:= ""
   
   If NJP->NJP_STATUS == "E"
      Help( , , STR0014, , "Autorização já está -Encerrada- ", 1, 0 ) //"AJUDA"###"Não é possivel Altear esta Autorização - Pois foi criada por Outra Rotina"
      RestArea(aAreaNJP)
      return .f.
   EndIf
	
    If !VLDAUTCTR(NJP->(NJP_CODCTR))
    	RestArea(aAreaNJP)
        Return .f.
    EndIf
	
	dbSelectArea( 'NJF' )
	dbSetOrder( 5 )
	If dbSeek( xFilial( 'NJF' ) + NJP->(NJP_CODCTR+NJP_ITEM))
		Help( , , STR0014, , STR0048, 1, 0 ) //"AJUDA"###"Não é possivel excluir esta -Autorização- pois ja existe movimentação!"
        RestArea(aAreaNJP)
        return .f.
	EndIf			
				
	BEGIN TRANSACTION
		
		//"Deseja realmente encerrar esta autorização?"
		If AGRGRAVAHIS(STR0043,"NJP",NJP->NJP_FILIAL+NJP->NJP_CODCTR,"B") = 1
			
			dbSelectArea( "NJP" )
			If RecLock( "NJP", .f. )
				NJP_QTDAUT := NJP_QTDFCO
				NJP_STATUS := "E"
				MsUnLock()
			EndIf

			dbSelectArea( "NJR" )
			dbSetOrder( 1 )
			If dbSeek( xFilial("NJR") + NJP->( NJP_CODCTR ) )
				//////////////////////////
				// Atualiza autorizações
				//////////////////////////
				OGX010QAut()
			EndIf
		EndIf
		
	END TRANSACTION
	
	cTitulo 	:= STR0031 //"Encerramento de Autorização de Embarque/Desembarque"
	cMensagem	:= STR0022 + NJP->( NJP_CODCTR ) + Chr( 13 ) + Chr( 10 )  //"- - - - Contrato: "
	cMensagem	+= STR0023 + NJP->( NJP_ITEM )   + Chr( 13 ) + Chr( 10 ) //"- - -Autorização: "
	cMensagem	+= STR0024 + Posicione('SB1',1,xFilial('SB1')+NJR->(NJR_CODPRO),'B1_DESC')  + Chr( 13 ) + Chr( 10 ) //"- - - - -Produto: "
	cMensagem	+= STR0025 + Transform( NJP->( NJP_QTDAUT ), PesqPict( "NJP", "NJP_QTDAUT" ) ) + Chr( 13 ) + Chr( 10 ) //"- - - Quantidade: "
	cMensagem	+= STR0026 + NJR->( NJR_UM1PRO )   + Chr( 13 ) + Chr( 10 ) //"- Unidade Medida: "
	cMensagem	+= STR0027 + DtoC( NJP->( NJP_DATINI ) ) + Chr( 13 ) + Chr( 10 ) //"- - Data : "
	cMensagem	+= STR0028 + DtoC( NJP->( NJP_DATFIM ) ) + Chr( 13 ) + Chr( 10 ) //"- - - Data Final: "
	cMensagem	+= STR0029 + STR0032 + Chr( 13 ) + Chr( 10 ) //"- - - - - Status: "###"Encerrada!!!"

	EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "NJO", FW_EV_LEVEL_INFO, "", cTitulo, cMensagem, .t. )

    RestArea(aAreaNJP)
Return( Nil )


//--<< Função Inicializador Padrão para Qt a Embarcar de Entrada ou Saida
function og340InEmb( cCodCtr , cCampo)
 	Local aAreaNJP  := NJP->(GETAREA())
	Local nSlaEmbarc := 0

	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	If NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ))
		DO Case
		Case Alltrim(cCampo) == 'NJP_SLEMBE'
			nSlaEmbarc  := NJR->NJR_AUTENT - NJR->NJR_QTEFCO
		Case Alltrim(cCampo) == 'NJP_SLEMBS'
			nSlaEmbarc  := NJR->NJR_AUTSAI - NJR->NJR_QTSFCO
		End Case
	EndIF
	RestArea(aAreaNJP)
Return( nSlaEmbarc )

//--<< Função Inicializador Padrão para Saldo a Autorizar do Ctrato
Function oG340InSlA( cCodCtr , cCampo)
    Local aAreaNJR  := NJR->(GETAREA())
	Local nSaldo := 0	

	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	If NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ))
		DO Case
		Case Alltrim(cCampo) == 'NJP_SLAENT'
			nSaldo  := NJR->NJR_QTDCTR - NJR->NJR_AUTENT 
		Case Alltrim(cCampo) == 'NJP_SLASAI'
			nSaldo  := NJR->NJR_QTDCTR - NJR->NJR_AUTSAI 
		End Case
	EndIF

	RestArea(aAreaNJR)	
Return( nSaldo )

/** {Protheus.doc} OGA340HIS
Descrição: Mostra em tela de Historico das Autorizações

@param: 	Nil
@author: 	Gilson Venturi
@since: 	02/06/2015
@Uso: 		OGA340 
*/
Function OGA340HIS()
	Local cChaveI := "NJP->("+Alltrim(AGRSEEKDIC("SIX","NJP1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NJP",cChaveA)
Return
/*
@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	10/09/2015
@Uso: 		AgroIndustria
*/
Static Function finimodelo()		
 IF __cCodCtr == nIl
 	IF !TYPE('pcCodCtr') = 'U'  
    	__cCodCtr := pcCodCtr
    else
    	pcCodCtr := criavar('NJR_CODCTR',.F.)
    EndIf
 EndIF

Return( .t. )


/*/{Protheus.doc} VLDAUTCTR
//TODO Valida se permite incluir/alterar/excluir/copiar autorização para o contrato
@author claudineia.reinert
@since 30/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function VLDAUTCTR(cCodCtr)
	Local lRet 		:= .T.
	Local aAreaNJR  := NJR->(GETAREA())
	
	NJR->(dbSetOrder(1))
    If NJR->(dbSeek(xFilial("NJR") + cCodCtr))
    	If !((NJR->NJR_MODELO == '2' .Or. NJR->NJR_MODELO == '3') .And. NJR->NJR_STATUS=='A') .AND. ;
           !((NJR->NJR_MODELO == '2' .Or. NJR->NJR_MODELO == '3') .And. NJR->NJR_STATUS=='I')
           //se contrato não estiver aberto(confirmado) ou iniciado não permite trabalhar com a autorização
           AGRHELP(STR0014,STR0050, STR0051) //AJUDA Ação disponível apenas para Contrato com situação Confirmada ou Iniciada. //Verifique a situação do contrato.
           lRet := .F.
           
         EndIf
    EndIf
    
    RestArea(aAreaNJR)

Return lRet

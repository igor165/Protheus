#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA210.CH"
#INCLUDE "FWTABLEATTACH.CH"

Static __cF3UserPaper	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cadastro de Usuários do CRM

@sample		CRMA210( uRotAuto, nOpcAuto )

@param		uRotAuto - Array com os valores 
			nOpcAuto - Numero de identificacao da operacao
			
@return		ExpL - Verdadeiro / Falso  

@author		Thiago Tavares
@since		11/03/2014
@version	P12
/*/
//-------------------------------------------------------------------
Function CRMA210( uRotAuto, nOpcAuto, aAutoAZS )

Local oBrowse   := Nil
Local oTableAtt := TableAttDef()

Private lMsErroAuto := .F.

If uRotAuto == Nil .AND. nOpcAuto == Nil

	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias( "AO3" ) 
	oBrowse:SetDescription( STR0001 )     //  Usuários do CRM	  
	
	oBrowse:SetAttach( .T. ) 				  						// Habilita as visões do Browse

	If oTableAtt <> Nil
		oBrowse:SetViewsDefault( oTableAtt:aViews ) 
		oBrowse:SetChartsDefault( oTableAtt:aCharts ) 					// Passa o gráfico para o Browse
	EndIf
	
	oBrowse:SetTotalDefault( "AO3_CODUSR", "COUNT", STR0016, ) 		// "Total de Registros"
	oBrowse:Activate()

Else
	If SuperGetMv("MV_CRMUAZS",, .F.)
		FWMVCRotAuto( ModelDef(), "AO3", nOpcAuto, { { "AO3MASTER", uRotAuto }, {"AZSDETAIL", aAutoAZS} }, /*lSeek*/, .T. )
	Else
		FWMVCRotAuto( ModelDef(), "AO3", nOpcAuto, { { "AO3MASTER", uRotAuto } }, /*lSeek*/, .T. )
	EndIf
EndIf

Return !( lMsErroAuto )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt 	:= FWTableAtt():New()

// Visões  
Local oAtivos		:= Nil // Usuários do CRM Ativos 
Local oInativos	:= Nil // Usuários do CRM Inativos

//Gráficos
Local oPorUnNeg	:= Nil	// Colunas: Usuários Por Unidade de Negócio
Local oPorEqVend	:= Nil // Colunas: Usuários Por Equipe de Venda

oTableAtt:SetAlias( "AO3" )
	
//----------
// Visões
//---------- 

// Usuários do CRM Ativos 
oAtivos := FWDSView():New()
oAtivos:SetName( STR0012 )			// "Usuários do CRM Ativos"
oAtivos:SetID( "Ativos" )			
oAtivos:SetOrder(1) 				// AO3_FILIAL+ AO3_CODUSR
oAtivos:SetCollumns( {"AO3_CODUSR", "AO3_NOMUSR", "AO3_CODUND", "AO3_NOMUND", "AO3_CODEQP", "AO3_NOMEQP" } )
oAtivos:SetPublic( .T. )
oAtivos:AddFilter( STR0012, "AO3_MSBLQL == '2'" ) // "Usuários do CRM Ativos"

oTableAtt:AddView( oAtivos )

// Usuários do CRM Inativos
oInativos := FWDSView():New()
oInativos:SetName( STR0013 ) 	// "Usuários do CRM Inativos"
oInativos:SetID( "Inativos" )			
oInativos:SetOrder(1) 			// AO3_FILIAL+ AO3_CODUSR
oInativos:SetCollumns( { "AO3_CODUSR", "AO3_NOMUSR", "AO3_CODUND", "AO3_NOMUND", "AO3_CODEQP", "AO3_NOMEQP" } )
oInativos:SetPublic( .T. )
oInativos:AddFilter( STR0013, "AO3_MSBLQL == '1'" ) // "Usuários do CRM Inativos"

oTableAtt:AddView( oInativos )

//------------
// Gráficos
//------------
	
// Colunas: Usuários Por Unidade de Negócio
oPorUnNeg := FWDSChart():New()
oPorUnNeg:SetName( STR0014 ) 	// "Usuários Por Unidade de Negócio"
oPorUnNeg:SetTitle( STR0014 ) 	// "Usuários Por Unidade de Negócio"
oPorUnNeg:SetID( "PorUnNeg" )			
oPorUnNeg:SetType( "BARCOMPCHART" )
oPorUnNeg:SetSeries( { { "AO3", "AO3_CODUSR", "COUNT" } } )
oPorUnNeg:SetCategory( { {"AO3", "AO3_CODUND"} } )
oPorUnNeg:SetPublic( .T. )
oPorUnNeg:SetLegend( CONTROL_ALIGN_BOTTOM ) 	//Inferior
oPorUnNeg:SetTitleAlign( CONTROL_ALIGN_CENTER ) 	

oTableAtt:AddChart( oPorUnNeg )	

// Colunas: Usuários Por Equipe de Venda
oPorEqVend := FWDSChart():New()
oPorEqVend:SetName( STR0015 ) 	//"Usuários Por Equipe de Venda"
oPorEqVend:SetTitle( STR0015 )	// "Usuários Por Equipe de Venda"
oPorEqVend:SetID( "PorEqVend" )			
oPorEqVend:SetType( "BARCOMPCHART" )
oPorEqVend:SetSeries( { { "AO3", "AO3_CODUSR", "COUNT" } } )
oPorEqVend:SetCategory( { {"AO3", "AO3_CODEQP"} } )
oPorEqVend:SetPublic( .T. )
oPorEqVend:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPorEqVend:SetTitleAlign( CONTROL_ALIGN_CENTER ) 

oTableAtt:AddChart( oPorEqVend )	

Return ( oTableAtt )	

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do modelo de Dados

@sample		ModelDef()

@param		Nenhum
			
@return		ExpO - Objeto do modelo de dados  

@author		Thiago Tavares
@since		11/03/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStructAO3	:= FWFormStruct( 1, "AO3", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructAZS	:= Nil
Local bPosValid		:= Nil
Local bCommit		:= { |oMdl| CA210ACmm( oMdl ) }
Local bActivate		:= {|oModel| CRM210Active( oModel )}
Local bPreAZS 		:= { |oModel, nLine, cAction, cField| CRMA210AZSPre(oModel, nLine, cAction, cField) }
Local aAux			:= {}
Local lCRMAZS		:= SuperGetMv("MV_CRMUAZS",, .F.)

If lCRMAZS
	oStructAZS	:= FWFormStruct( 1, "AZS", /*bAvalCampo*/, /*lViewUsado*/ )
	bPosValid	:= {|oModel| CRM210BPosVld( oModel )}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Trigger. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := FwStruTrigger("AO3_CODUSR","AO3_VEND","Posicione('SA3',7,xFilial('SA3')+FwFldGet('AO3_CODUSR'),'A3_COD')",.F.,Nil,Nil,Nil)
oStructAO3:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel := MPFormModel():New( "CRMA210", /*bPreValidacao*/, bPosValid, bCommit, /*bCancel*/ )

oModel:AddFields( "AO3MASTER", /*cOwner*/, oStructAO3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( { "AO3_FILIAL", "AO3_CODUSR" } )
oModel:SetDescription( STR0001 )

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("AO3MASTER", oModel, "AO3" )

If lCRMAZS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grid - Papeis do Usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:AddGrid("AZSDETAIL","AO3MASTER",oStructAZS,bPreAZS,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Relacionamento - Papeis do Usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:SetRelation("AZSDETAIL",{{"AZS_FILIAL","xFilial('AZS')"},{"AZS_CODUSR","AO3_CODUSR"}},AZS->( IndexKey(1) ))
EndIf
Return ( oModel ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da interface

@sample		ViewDef()

@param		Nenhum
			
@return		ExpO - Objeto do modelo da interface  

@author		Thiago Tavares
@since		11/03/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView      	:= Nil 
Local oModel     	:= ModelDef()
Local oStructAO3 	:= FWFormStruct( 2, "AO3", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructAZS	:= Nil
Local lCRMAZS		:= SuperGetMv("MV_CRMUAZS",, .F.)

If lCRMAZS
	oStructAZS := FWFormStruct( 2, "AZS", /*bAvalCampo*/, /*lViewUsado*/ )
	//Remove os campos da View
	oStructAO3:RemoveField("AO3_CODUND") 	//Unidade de Negocio
	oStructAO3:RemoveField("AO3_NOMUND") 	//Nome da Unidade de Negocio
	oStructAO3:RemoveField("AO3_CODEQP")  	//Equipe
	oStructAO3:RemoveField("AO3_NOMEQP")  	//Nome da Equipe
	oStructAO3:RemoveField("AO3_IDESTN")	//Id. Inteligente da Estrutura de negocio
	oStructAO3:RemoveField("AO3_NVESTN")	//Nivel da Estrutura de Negocio
	oStructAO3:RemoveField("AO3_VEND")		//Vendedor
	oStructAO3:RemoveField("AO3_NVEND")	//Vendedor
	oStructAZS:RemoveField("AZS_CODUSR")	//Usuario
EndIf

oView := FWFormView():New()

oView:SetModel( oModel, "AO3MASTER" )

If lCRMAZS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fields - Usuário do CRM.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oView:AddField("VIEW_AO3", oStructAO3, "AO3MASTER" ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grid - Time de Vendas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oView:AddGrid("VIEW_AZS",oStructAZS,"AZSDETAIL")
	oView:AddIncrementField("VIEW_AZS",'AZS_SEQUEN')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grid - Montagem dos Boxs da Inteface. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oView:CreateHorizontalBox( "TOP", 60 )
	oView:SetOwnerView( "VIEW_AO3", "TOP" )
	
	oView:CreateHorizontalBox( "BOTTOM", 40 )
	oView:SetOwnerView( "VIEW_AZS", "BOTTOM" )
	
	oView:EnableTitleView("VIEW_AZS",STR0022)	//"Papéis do Usuário"
Else
	oView:AddField( "VIEW_AO3", oStructAO3, "AO3MASTER" ) 
	oView:CreateHorizontalBox( "ALL", 100 )
	oView:SetOwnerView( "VIEW_AO3", "ALL" )
	oView:SetContinuousForm()
EndIf

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das rotinas do Menu

@sample		MenuDef()

@param		Nenhum
			
@return		ExpA - Array de rotinas   

@author		Thiago Tavares
@since		11/03/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action "VIEWDEF.CRMA210" OPERATION 2 ACCESS 0		// Visualizar		
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.CRMA210" OPERATION 3 ACCESS 0		// Incluir
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.CRMA210" OPERATION 4 ACCESS 0		// Alterar
ADD OPTION aRotina Title STR0005 Action "VIEWDEF.CRMA210" OPERATION 5 ACCESS 0		// Excluir
ADD OPTION aRotina Title STR0008 Action "CA210TfPrv" 	  OPERATION 6 ACCESS 0		// Transf. Priv.

Return ( aRotina )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CA210ACmm

Faz a gravação do Model 

@sample		CA210ACmm( oMdl )

@param		oMdl - Objeto Model

@return		ExpL - Gravação realizada com sucesso Sim (.T.) ou Não (.F.)

@author		Thiago Tavares
@since		19/03/2014
@version	P12
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CA210ACmm( oMdl )

Local aArea	  	:= GetArea()
Local aAreaAO5  := AO5->( GetArea() )
Local aAreaSA3  := {}
Local nOpc		:= oMdl:GetOperation()
Local lRet		:= .T.
Local cFilAZS	:= xFilial("AZS") 
Local cFilAO5	:= xFilial("AO5") 

If FWFormCommit( oMdl, Nil, { || } )
	
	// verificando se é exclusão e se o usuário tem controle total sobre algum registro
	If nOpc == MODEL_OPERATION_DELETE
		
		If SuperGetMv("MV_CRMUAZS",, .F.)
			AZS->( DBSetOrder( 1 ) )
			
			If ( AZS->( MSSeek( cFilAZS + FWFldGet( "AO3_CODUSR" ) ) ) )
				While ( ! AZS->( Eof() ) .And. AZS->AZS_FILIAL == cFilAZS .And.  AZS->AZS_CODUSR == FWFldGet( "AO3_CODUSR" ) )	
					AO5->( DbSetOrder( 2 ) ) // AO5_FILIAL+AO5_ENTANE+AO5_CODANE+AO5_ENTPAI+AO5_CODPAI
					
					If ( AO5->( DbSeek( cFilAO5 + "AZS" + AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL ) ) )
						RecLock( "AO5", .F. )
						AO5->( DbDelete() )
						AO5->( MsUnLock() )
					EndIf
					
					AO5->( DbCloseArea() )
				Enddo
			EndIf
		Else
			// removendo o usuário da estrutura de negócio
			DbSelectArea( "AO5" )			// Estrutura de Negócio
			DbSetOrder( 2 )					// AO5_FILIAL+AO5_ENTANE+AO5_CODANE+AO5_ENTPAI+AO5_CODPAI
			
			If AO5->( DbSeek( cFilAO5 + "USU" + FWFldGet( "AO3_CODUSR" ) ) )
				RecLock( "AO5", .F. )
				AO5->( DbDelete() )
				AO5->( MsUnLock() )
			EndIf
			
			DbCloseArea()
		EndIf
	Else
		//-----------------------------------------------------------------------------
		// Atualiza o cargo do vendedor de acordo com o cadastro de usuário
		//-----------------------------------------------------------------------------
		aAreaSA3 := GetArea()
		
		DbSelectArea( "SA3" )
		DbSetOrder( 7 )
		If SA3->( DbSeek( xFilial( "SA3" ) + FwFldGet( "AO3_CODUSR" ) ) )
			If FwFldGet( "AO3_CARGO" ) != SA3->A3_CARGO
				RecLock( "SA3", .F. )
				SA3->A3_CARGO := FwFldGet( "AO3_CARGO" )
				SA3->( MsUnlock() )
			EndIf
		EndIf
		RestArea( aAreaSA3 )
	EndIf
EndIf


RestArea( aAreaAO5 )
RestArea( aArea )

Return ( lRet )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CA210TfPrv

Faz a transferencia de privilegios entre usuarios 

@sample		CA210TfPrv( )

@param		Nenhum

@return		Nenhum

@author		Thiago Tavares
@since		22/04/2014
@version	P12
/*/
//---------------------------------------------------------------------------------------------------------------
Function CA210TfPrv()

If Aviso( STR0007, STR0009, { STR0010, STR0011 }, 2 ) == 1		// "Atenção"    "Esse processo irá transferir os privilégios dos registros desse usuário e, com isso, ele não terá mais acesso a esses registros. Confirma transferir ?"    "Sim"    "Não"

	FWMsgRun(, {|oSay| TranPriv(oSay) }, , STR0008)

EndIf

Return

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TranPriv

Processa a transferencia de privilegios entre usuarios 

@sample		TranPriv( )

@param		Nenhum

@return		Nenhum

@author		Thiago Tavares
@since		05/06/2018
@version	P12
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function TranPriv()  

Local aArea	  	:= GetArea()
Local aAreaAO4	:= AO4->( GetArea() )
Local cAliasTmp := GetNextAlias()
Local cCodUsr	:= AO3->AO3_CODUSR 

	// Atualizando os registros nos quais o usuário tem o controle total
	BeginSql Alias cAliasTmp
		SELECT AO4.AO4_FILIAL, AO4.AO4_ENTIDA, AO4.AO4_CODUSR, AO4.AO4_CHVREG, AO4.AO4_CTRLTT, AO4.AO4_USRCOM, AO4.R_E_C_N_O_ NUMREC 
		FROM %Table:AO4% AO4 WHERE (AO4.AO4_CODUSR = %Exp:AO3_CODUSR% OR AO4.AO4_USRCOM = %Exp:AO3_CODUSR%) AND AO4.%NotDel%
	EndSql

	If !( cAliasTmp )->( Eof() )   
		
		If ConPad1( , , , "AO3" , , , .F. )
			
			Begin Transaction
				If AllTrim(cCodUsr) != AllTrim(AO3->AO3_CODUSR)
					DbSelectArea( "AO4" )	// Estrutura de Negócio
					DbSetOrder( 1 )    		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR 
					While !( cAliasTmp )->( Eof() )
						
						// Atualizando os registros nos quais o usuário tem controle total	
						TCSetField( ( cAliasTmp ), "AO4_CTRLTT", "L", 1, 0 )  
	
						AO4->(DbGoTo(( cAliasTmp )->NUMREC))					
	
						If AllTrim(AO4->AO4_CODUSR) == AllTrim(cCodUsr)
							If CA210ValSb(AO3->AO3_CODUSR)
								RecLock( "AO4", .F. )	
								AO4->AO4_CODUSR := AO3->AO3_CODUSR
								AO4->( MsUnLock() )							
							Else
								RecLock( "AO4", .F. )
								AO4->( DbDelete() )
								AO4->( MsUnLock() )
							EndIf
						EndIf
	
						// Atualizando os registros que o usuário compartilhou	
						If AllTrim(AO4->AO4_USRCOM) == AllTrim(cCodUsr)
							RecLock( "AO4", .F. )	
							AO4->AO4_USRCOM := AO3->AO3_CODUSR
							AO4->( MsUnLock() )
						EndIf
						
						(cAliasTmp)->( dbSkip() )
		
					End

				EndIf
			End Transaction
		EndIf
	EndIf

RestArea( aAreaAO4 )
RestArea( aArea )

Return

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CA210RetNm

Retorna o nome completo do usuário

@sample		CA210RetNm( cCodUsr )

@param			cCodUsr - Codigo do Usuario

@return		ExpC - Nome completo do Usuário

@author		Thiago Tavares
@since			09/06/2014
@version		P12
/*/
//---------------------------------------------------------------------------------------------------------------
Function CA210RetNm( cCodUsr )

Local aUsers   := FWSFAllUsers()		// Array com todos os usuarios do sistema
Local nPos     := 0
Local cRetorno := ""

nPos := aScan( aUsers, { |x| x[2] == cCodUsr } )
If nPos > 0 
	cRetorno := aUsers[nPos, 4]	
Else
	cRetorno := UsrRetName( cCodUsr )
EndIf

Return cRetorno

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CA210ValSb

Valida se o usuário substituto já tem o privilégio do usuário substituíto

@sample		CA210ValSb(cFilTrb, cEntidade, cChave, cUsrSub)

@param		cUsrSub   - Código do usuário substituto

@return		lRet - .T. caso não seja encontrado registro para o substituto

@author		Nairan Silva
@since		05/06/2018
@version	P12
/*/
//---------------------------------------------------------------------------------------------------------------
Function CA210ValSb(cUsrSub)

Local aAreaAO4	:= AO4->(GetArea())

Local lCtrLtt	:= AO4->AO4_CTRLTT
Local lPerEdt	:= AO4->AO4_PEREDT
Local lPerExc	:= AO4->AO4_PEREXC
Local lPerVis	:= AO4->AO4_PERVIS
Local lPerCom	:= AO4->AO4_PERCOM
Local lRet		:= .T. 

AO4->(DbSetOrder(1))
If AO4->(DbSeek(AO4->(AO4_FILIAL + AO4_ENTIDA + AO4_CHVREG) + cUsrSub))
	
	If !AO4->AO4_CTRLTT
		Reclock("AO4",.F.)
		If !AO4->AO4_CTRLTT .And. lCtrLtt
			AO4->AO4_CTRLTT := .T.
			AO4->AO4_PEREDT := .F.
			AO4->AO4_PEREXC := .F.
			AO4->AO4_PERVIS := .F.
			AO4->AO4_PERCOM := .F.
		Else
			If !AO4->AO4_PEREDT .And. lPerEdt
				AO4->AO4_PEREDT := .T.
			EndIf
			If !AO4->AO4_PEREXC .And. lPerExc
				AO4->AO4_PEREXC := .T.
			EndIf
			If !AO4->AO4_PERVIS .And. lPerVis
				AO4->AO4_PERVIS := .T.
			EndIf
			If !AO4->AO4_PERCOM .And. lPerCom
				AO4->AO4_PERCOM := .T.
			EndIf
		EndIf
		AO4->(MsUnLock())			
	EndIf
	lRet	:= .F.
EndIf

RestArea(aAreaAO4)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210NUPap

Retorna o nome do usuario + nome do seu papel.          

@sample	CRM210NUPap( cIdUserPaper )

@param		cIdUserPaper	,caracter	,Código do Usuário + Sequencia + Papel
 
@return	cName			,caracter	, Nome do Usuario + [ Nome do Papel ]

@author	Anderson Silva
@since		28/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRM210NUPap( cIdUserPaper )

Local cCodUser	:= ""
Local cSeqPaper	:= ""
Local cName		:= ""

Default cIdUserPaper	:= ""

cCodUser := SubStr( cIdUserPaper, 1, 6 )
If !Empty( cIdUserPaper ) .And. SuperGetMv("MV_CRMUAZS",, .F.) 
	cSeqPaper	:= SubStr( cIdUserPaper, 7, Len(cIdUserPaper) )
	cName := AllTrim( CRMXLoadUser( cCodUser )[4] + " [ " + CRM210NPaper( cSeqPaper, .T. ) + " ] " )
Else
	cName := AllTrim( CRMXLoadUser( cCodUser )[4] )
EndIf

Return( cName )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210NPaper()

Retorna o nome do papel vinculado uma sequencia do usuario ou não.                

@sample	CRM210NPaper( cPaper, lSequence )

@param		cPaper		, caracter	, Código do Papel
			lSequence	, logico	, Define se codigo do papel possui sequencia de usuario. 
 

@return	cName		,caracter	, Nome do Papel		

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRM210NPaper( cPaper, lSequence )

Local aAreaAZR	:= {}
Local cName 		:= ""
Local nTamSeq		:= TamSX3("AZS_SEQUEN")[1]
Local nTamPap		:= TamSX3("AZR_PAPEL")[1]

Default cPaper 	:= ""
Default lSequence	:= .F.

If !Empty( cPaper )

	If lSequence 
		cPaper := SubStr( cPaper, nTamSeq+1, nTamPap ) 
	EndIf
	
	If Len( cPaper ) == nTamPap 
	
		aAreaAZR := AZR->(GetArea())
		
		DbSelectArea("AZR")
		AZR->( DbSetOrder(1) ) //AZR_FILIAL+AZR_PAPEL
		
		If AZR->( DbSeek(xFilial("AZR") + cPaper) )
			cName := AllTrim( AZR->AZR_NOMPAP )
		EndIf
		
		RestArea( aAreaAZR )
		
	EndIf	
EndIf

Return( cName )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210VdSP()

Valida a sequencia + papel atribuida para um usuario do CRM.              

@sample	CRM210VdSP( cIdUserPaper )

@param		cIdUserPaper	, caracter	, Id do papel do usuario sendo: Código do usuario + Sequencia + Papel
		
@return	lRetorno	, logico	, Retorna verdadeiro se a sequencia + papel foi atribuido para usuario.

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRM210VdSP( cIdUserPaper )

Local aAreaAZS		:= {}
Local lRet 			:= .T.

Default cIdUserPaper := ""

If !Empty( cIdUserPaper )

	If SuperGetMv("MV_CRMUAZS",, .F.)
		aAreaAZS := AZS->(GetArea())
		
		DbSelectArea("AZS")
		AZS->( DbSetOrder(1) ) //AZS_FILIAL+AZS_CODUSR+AZS_SEQUEN+AZS_PAPEL
			
		If !AZS->( DbSeek(xFilial("AZS") + cIdUserPaper ) )
			lRet := .F.
			Help( " ", 1, "CRM210VDSP", , OemToAnsi( STR0023 ), 3, 0)  //"Papel não existe ou não foi atribuido para este usuario."
		EndIf
	Else
		cIdUserPaper := AllTrim(cIdUserPaper)
		aAreaAZS := AO3->(GetArea())
		
		DbSelectArea("AO3")
		AO3->( DbSetOrder(1) ) //AO3_FILIAL+AO3_CODUSR
			
		If !AO3->( DbSeek(xFilial("AO3") + cIdUserPaper ) )
			lRet := .F.
			Help( " ", 1, "AO3_CODUSR", , OemToAnsi( STR0023 ), 3, 0)  //"Papel não existe ou não foi atribuido para este usuario."
		EndIf
	EndIf
		
	RestArea( aAreaAZS )

EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210BPosVld

Bloco executado para validar o formulario antes da gravação.

@sample	CRM210BPosVld( oModel )

@param		oModel, objeto, Model usuários do CRM

@return	Nenhum

@author	Anderson Silva
@since		11/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM210BPosVld( oModel )

Local nOperation	:= 0
Local lRet 		:= .T.

Default oModel := FwModelActive()

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	//Valida se existe um papel principal para usuario.  
	lRet := CRM210VPPr( oModel )
	
	If lRet
		//Valida se o codigo do vendedor está sendo utilizando por outro papel de usuario.    
		lRet := CRM210VVen( oModel ) 
	EndIf
EndIf

Return( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210Active

Bloco executado ao iniciar o formulario MVC para inclusao, alteracao, exclusao e 
visualizacao.                       

@sample	CRM210Active( oModel )

@param		oModel, objeto, Model usuários do CRM

@return	Nenhum

@author	Anderson Silva
@since		11/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM210Active( oModel )
	Local nOperation := oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		//Inicia um papel padrão para o usuario do CRM na inclusão.   
		CRM210InitPap( oModel )	
	EndIf
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210InitPap()

Inicia um papel padrão para o usuario do CRM caso o mesmo não possui nenhum.                  

@sample	CRM210InitPap( oModel ))

@param		oModel, objeto, Model usuários do CRM

@return	Nenhum

@author	Anderson Silva
@since		11/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM210InitPap( oModel )

Local cUserPaper	:= SuperGetMv("MV_CRMUSRP",,"000001") 
Local oMdlAO3		:= oModel:GetModel("AO3MASTER")
Local oMdlAZS 	:= oModel:GetModel("AZSDETAIL")

//Cadastro de vendedor inicializa automaticamente o papel do padrão.
If !Empty( cUserPaper ) .And. !IsInCallStack("MATA040")
	
	DbSelectArea("AZR")
	AZR->( DbSetOrder(1) ) //AZR_FILIAL+AZR_PAPEL
	
	If AZR->( DbSeek( xFilial("AZR") + cUserPaper ) )  
		If oMdlAZS:IsEmpty()
		
			oMdlAZS:SetValue("AZS_PAPEL" 	, cUserPaper )						//Papel do Usuario
			oMdlAZS:SetValue("AZS_CODUND"	, oMdlAO3:GetValue("AO3_CODUND"	) )	//Unidade de Negocio
			oMdlAZS:SetValue("AZS_CODEQP"	, oMdlAO3:GetValue("AO3_CODEQP"	) ) //Equipe
			oMdlAZS:SetValue("AZS_IDESTN"	, oMdlAO3:GetValue("AO3_IDESTN"	) ) //Id. Inteligente da Estrutura de negocio
			oMdlAZS:SetValue("AZS_NVESTN"	, oMdlAO3:GetValue("AO3_NVESTN"	) ) //Nivel da Estrutura de Negocio
			oMdlAZS:SetValue("AZS_VEND"		, oMdlAO3:GetValue("AO3_VEND"	) ) //Vendedor
			oMdlAZS:SetValue("AZS_PAPPRI"	, "1" ) 								 //Papel Principal?
			
			//Limpa os dados da AO3 para evitar duplicidade nos dados
			oMdlAO3:LoadValue("AO3_CODUND"	,""	)	//Unidade de Negocio
			oMdlAO3:LoadValue("AO3_CODEQP"	,""	)	//Equipe
			oMdlAO3:LoadValue("AO3_IDESTN"	,""	)	//Id. Inteligente da Estrutura de negocio
			oMdlAO3:LoadValue("AO3_NVESTN"	,0	)	//Nivel da Estrutura de Negocio
			oMdlAO3:LoadValue("AO3_VEND"	,""	)	//Vendedor
		
		EndIf
	EndIf
	
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210VPPr()

Valida se existe um papel principal para usuario.            

@sample	CRM210VPPr()

@param		Nenhum
		
@return	lRetorno	, logico	, Retorna verdadeiro se já existe um papel principal.

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM210VPPr( oModel )

	Local lRet 	:= .T.
	Local oMdlAZS	:= Nil
	Local nLinAtu	:= 0
	Local nX		:= 0

	Default oModel:= FwModelActive()
	
	oMdlAZS := oModel:GetModel("AZSDETAIL")
	
	If oMdlAZS:GetValue("AZS_PAPPRI") == "1"
		nLinAtu := oMdlAZS:GetLine()
		For nX := 1 To oMdlAZS:Length()
			oMdlAZS:GoLine( nX )
			If ( !oMdlAZS:IsDeleted() .And. nX <> nLinAtu .And. oMdlAZS:GetValue("AZS_PAPPRI") == "1" )
				Help(" ",1,"CRM210VPPr", , OemToAnsi( STR0024 ), 3, 0) //"Já existe um papel definido como principal."
				lRet := .F.
				Exit
			EndIf
		Next nX
		oMdlAZS:GoLine( nLinAtu )
	EndIf
	
Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210VVen()

Valida se o codigo do vendedor está sendo utilizando por outro papel de usuario.           

@sample	CRM210VVen()

@param		Nenhum
		
@return	lRetorno	, logico	, Retorna verdadeiro se já existe um 
									  outro papel de usuario vinculado a este vendedor.

@author	Anderson Silva
@since		12/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM210VVen( oModel ) 

	Local aAreaAZS	:= AZS->( GetArea() )
	Local lRet			:= .T.
	Local oMdlAO3		:= Nil
	Local oMdlAZS		:= Nil
	Local cCodUser	:= Nil
	Local cCodVend	:= Nil
	Local nLinAtu		:= 0 
	Local nX			:= 0
	
	Default oModel	:= FwModelActive()
	
	oMdlAO3	:= oModel:GetModel("AO3MASTER")
	oMdlAZS	:= oModel:GetModel("AZSDETAIL")
	cCodUser	:= oMdlAO3:GetValue("AO3_CODUSR")
	cCodVend	:= oMdlAZS:GetValue("AZS_VEND")
	
	If !Empty( cCodVend ) 
	
		nLinAtu 	:= oMdlAZS:GetLine()
			
		For nX := 1 To oMdlAZS:Length()
			oMdlAZS:GoLine( nX )
			If ( !oMdlAZS:IsDeleted() .And. nX <> nLinAtu .And. oMdlAZS:GetValue("AZS_VEND") == cCodVend )
				Help(" ",1,"CRM210VVen", , OemToAnsi( STR0025 ), 3, 0) //"Este vendedor está sendo utilizado por outro papel de usuário!"	
				lRet := .F.
				Exit
			EndIf
		Next nX
	
		oMdlAZS:GoLine( nLinAtu )
			
		If lRet	
			DBSelectArea("AZS")
			AZS->(DBSetOrder(4)) //AZS_FILIAL + AZS_VEND
			
			If ( AZS->( DBSeek( xFilial("AZS") + cCodVend ) ) .And. AZS->AZS_CODUSR <> cCodUser	)
				Help(" ",1,"CRM210VVen", , OemToAnsi( STR0025 ), 3, 0) //"Este vendedor está sendo utilizado por outro papel de usuário!"
				lRet := .F.
			EndIf
		EndIf
	
	EndIf
		
RestArea( aAreaAZS )

Return( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA210AZSPre
Pré validação da lista de papeis de usuários. 

@param oModel, objeto, Estrutura de negócio. 
@param nLine, numérico, Linha selecionada na lista.
@param cAction, objeto, Ação realizada na linha. 
@return lOk, lógico, Indica se a ação é válida.

@author  Valdiney V GOMES
@version P12
@since 	 21/01/2015
/*/
//-------------------------------------------------------------------
Static Function CRMA210AZSPre( oModel, nLine, cAction ) 
	Local cUser 	:= ""
	Local cSequence	:= ""
	Local cRole		:= ""
	Local lOk 		:= .T. 

	Default nLine 	:= 0
	Default cAction	:= ""

	If ( cAction == "DELETE" )
	 	cUser 		:= oModel:GetValue("AZS_CODUSR")
	 	cSequence	:= oModel:GetValue("AZS_SEQUEN")	
	 	cRole		:= oModel:GetValue("AZS_PAPEL") 
	
		//-------------------------------------------------------------------
		// Localiza a entidade na estrutura de negócio.  
		//-------------------------------------------------------------------		
		AO5->( DBSetOrder( 2 ) )
		
		If ( AO5->( DBSeek( xFilial("AO5") + "AZS" + cUser + cSequence + cRole ) ) ) 
			Help( ,, "HELP",, STR0026, 1, 0 ) //"Não é possivel excluir papeis vinculados na estrutura de negócio!"
			lOk := .F.
		EndIf
	EndIf
	
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM240F3PAP

Consulta padrão especifica Papeis de Usuário - USRPAP.        

@sample	CRM210F3PAP()

@param		Nenhum
		
@return	lRetorno	, logico	, Retorna verdadeiro para encerrar a consulta apos a utilizacao.

@author	Anderson Silva
@since		27/01/2016
@version	12
/*/
//------------------------------------------------------------------------------
Function CRM210F3PAP()	

	__cF3UserPaper := CRMXUIPaper(/*cCodUser*/, .T., /*cTitle*/, .T., /*lBtnNewPaper*/ )

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM210RF3P

Retorna id do papel Código do Usuário + Sequencia + Papel selecionado no F3-USRPAP

@sample	CRM240F3PAP()

@param		Nenhum
		
@return	cF3UserPaper ,caracter	,Código do Usuário + Sequencia + Papel

@author	Anderson Silva
@since		27/01/2016
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRM210RF3P()
Return( __cF3UserPaper )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AO4GdModel

Cria um GridModel associado ao modelo informado no parãmetro, para evitar
a validação do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		AO4GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function AO4GdModel(cIDMasterM, oModel, cAliasMast )
Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasMast := ""

oModel:AddGrid("AO4CHILD",cIDMasterM,oStructAO4,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGdAO4(oGridModel, lCopy)})
oModel:SetRelation( "AO4CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, AO4->( IndexKey( 1 ) ) )
oModel:GetModel("AO4CHILD"):SetOnlyView()
oModel:GetModel("AO4CHILD"):SetOnlyQuery()
oModel:GetModel("AO4CHILD"):SetOptional(.T.)
oModel:GetModel("AO4CHILD"):SetNoInsertLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGdAO4 

Bloco de carga dos dados do submodelo.
Este bloco sera invocado durante a execução do metodo activate desta classe.
O bloco recebe por parametro o objeto de model do FormGrid(FWFormGridModel) e um 
valor lógico indicando se eh uma operação de copia.

@param, oGridModel, objeto de model do FormGrid, FWFormGridModel
@param, lCopy     , indica se eh uma operação de copia, Boolean

@sample	LoadGdAO4(oGridModel, lCopy)

@return, aLoad, array com os dados que serão carregados no objeto, 
                o array deve ter a estrutura abaixo:
					[n]
					[n][1] ExpN: Id do registro (RecNo)
					[n][2] Array com os dados, os dados devem seguir exatamente 
					       a mesma ordem da estrutura de dados submodelo

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function LoadGdAO4(oGridModel, lCopy)
	
	Local aLoad      := {}
	Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStructAO4:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == "AO4_FILIAL"
			xValue := XFilial("AO4")
			cType  := ""
		Else
			cType  := aFields[nField][4]
			nLen   := aFields[nField][5]	
		EndIf

		Do Case
			Case cType == "C"
				xValue := Space(nLen)
			Case cType == "N"
				xValue := 0
			Case cType == "L"
				xValue := .T.
			Case cType == "D"
				xValue := CToD("  /  /    ")
		End Case

		AAdd(aLoad[1][2], xValue)
	Next nField

	FwFreeObj(oStructAO4)
	FwFreeObj(aFields)

Return aLoad

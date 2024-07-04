#INCLUDE "BCDEFINITION.CH"
#INCLUDE "BCDATABASE.CH"

Static __aShared := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProcessTable
Define a estrutura da tabela de   Processos (Views) e  realiza  a criacao.

@author Helio Leal  
@since 29/08/2017
/*/
//-------------------------------------------------------------------
Function BCProcessTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de processos. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I10", "I10" ) 

	//-------------------------------------------------------------------
	// Campos da tabela. 
	//-------------------------------------------------------------------  
	oQuery:AddField( TBIField():New( "I10_ENTITY", "C", 30, 0)) // Nome da entidade
	oQuery:AddField( TBIField():New( "I10_TYPE"  , "C", 01, 0)) // Tipo da entidade, D=Dimensao, F=Fato
	oQuery:AddField( TBIField():New( "I10_ORIGIN", "C", 03, 0)) // Tabela de Origem do Protheus 
	oQuery:AddField( TBIField():New( "I10_ISTCIA", "C", 02, 0)) // Instancia
	oQuery:AddField( TBIField():New( "I10_EMPRES", "C", 12, 0)) // Empresa
	oQuery:AddField( TBIField():New( "I10_VIEW"  , "C", 50, 0)) // View
	oQuery:AddField( TBIField():New( "I10_QUERY" , "M", 10, 0)) // Query
	oQuery:AddField( TBIField():New( "I10_CRYPT" , "C", 30, 0)) // Tipo de Criptografia
	oQuery:AddField( TBIField():New( "I10_USEVW" , "C", 1, 0)) // Define se a query tem depend?ncia com outras views
	
	
	//-------------------------------------------------------------------
	// Indices da tabela. 
	//-------------------------------------------------------------------  
	oQuery:addIndex( TBIIndex():New( "I101", {"I10_ENTITY", "I10_EMPRES", "I10_ISTCIA"}, .T.) )

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCAppTable
Define a estrutura da tabela de Apps e realiza a criacao.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCAppTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de apps. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I11", "I11" ) 

	oQuery:AddField( TBIField():New( "I11_APP", "C", 30, 0)) // Nome do App
	oQuery:addIndex( TBIIndex():New( "I111", {"I11_APP"}, .T.) )

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela.
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCAppEntTable
Define a estrutura da tabela de Apps X Entidades e realiza a criacao

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCAppEntTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de apps x entidades. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I12", "I12" ) 

	oQuery:AddField( TBIField():New( "I12_APP", "C", 30, 0)) // Nome do App
	oQuery:AddField( TBIField():New( "I12_ENTITY", "C", 30, 0)) // Nome da entidade
	oQuery:addIndex( TBIIndex():New( "I121", {"I12_APP", "I12_ENTITY"}, .T.) )	

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela.
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCRecordEntity
Salva a query de uma entidade na base de dados ERP (na tabela I10).

@param oEntity, object, objeto do tipo dimensao ou fato.
@param cCompany, String, Empresa injetada.

@Return lSuccess, True para quando a execucao do metodo nao houve erros, caso contrario False.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCRecordEntity( oEntity, cCompany )
	Local cView     := ""
	Local cOrigin   := ""
	Local cShared   := ""
	Local cType     := ""
	Local cInstance := BIInstance()
	Local lEntity   := .F.
	Local nStatus	:= 0 
	
	Default oEntity    := Nil 
	Default cCompany   := ""

	cOrigin   := oEntity:GetOrigin( )
	cType 	  := oEntity:GetType( )
	cShared   := BIGetShare ( cOrigin )
	cView     := oEntity:GetView( cCompany )
	nStatus   := oEntity:GetStatus( )

	If nStatus == 0
	
		//-----------------------------------------------------------------------------------------------------------------
		// Nao permitir a gravacao duplicada das FATOS onde a tabela de origem seja compartilhada entre as empresas.
		//-----------------------------------------------------------------------------------------------------------------
		If (Ascan( __aShared, { |x| x[1] == oEntity:GetEntity( ) .And. x[2] == cShared } ) == 0) .or.;
			((Ascan( __aShared, { |x| x[1] == oEntity:GetEntity( ) .And. x[2] == cShared } ) > 0 ) .and. cType = 'D')
		
			
			//-------------------------------------------------------------------
			// Identifica se e para incluir ou atualizar a entidade.
			//-------------------------------------------------------------------	
			lEntity := I10->( DBSeek( ( Padr( AllTrim( oEntity:GetEntity( ) ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance ) )
	
			If( RecLock( "I10", ! lEntity  ) )
				I10->I10_ENTITY := oEntity:GetEntity( )
				I10->I10_TYPE   := oEntity:GetType( )
				I10->I10_ORIGIN := oEntity:GetOrigin( )
				I10->I10_ISTCIA := cInstance
				I10->I10_EMPRES := cCompany
				I10->I10_QUERY  := cView
				I10->I10_CRYPT  := CRYPT_TYPE
				I10->I10_USEVW :=  oEntity:GetUseOtherView( )

				I10->( MsUnlock() )
			EndIf
			
			aAdd(__aShared, { oEntity:GetEntity( ), cShared } )
			Conout( STR0001 + " " + oEntity:GetEntity( ) ) // "BCDataBase: Gravando informacoes da view"			
		EndIf
	Else
		ConOut(I18n( STR0004 , {STR0005, oEntity:GetEntity( ), STR0006} ) ) // "BADataBase #1 #2 #3 ##Entidade ##nao foi gravada na tabela de processos.
	EndIf

Return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} BCSaveApp
Salva o App na base de dados ERP.

@param, cApp, String, Nome do App.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCSaveApp( cApp )
	Local lApp := .F.
	
	Default cApp := ""

	If ! ( Empty( cApp ) )
	
		lApp := I11->( DBSeek( ( Padr( AllTrim( cApp ), 30 ) ) ) )
		If( RecLock( "I11", ! lApp  ) )
			I11->I11_APP := cApp

			I11->( MsUnlock() )
		EndIf
		
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCSaveAppEntity
Salva o App X Entidade na base de dados ERP.

@param, cApp, String, Nome do App.
@param, cEntity, String, Nome da entidade.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCSaveAppEntity( cApp, cEntity )
	Local lAppEntity   := .F.
	
	Default cApp := ""
	Default cEntity := ""	

	If ! ( Empty( cApp ) )
	
		lAppEntity := I12->( DBSeek( ( Padr( AllTrim( cApp ), 30 ) ) + ( Padr( AllTrim( cEntity  ), 30 ) ) ) )

		If( RecLock( "I12", ! lAppEntity  ) )
			I12->I12_APP    := cApp
			I12->I12_ENTITY := cEntity
			I12->( MsUnlock() )
		EndIf
		
	EndIf
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} BCExistView
Verifica se a entidade ja foi gravada por empresa.

@param, cEntity, String, Nome da entidade.
@param, cCompany, String, Codigo da empresa.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Function BCExistView( cEntity, cCompany )
	Local lExist    := .F.
	Local cInstance := BIInstance()
	
	Default cEntity    := ""
	Default cCompany   := ""	

	lExist := I10->( DBSeek( ( Padr( AllTrim( cEntity ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance ) )
	
Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTruncate  
Limpa todos os dados da tabela de processos (I10). 

@author  Andreia Lima
@since   23/04/2019
/*/
//------------------------------------------------------------------- 
Function BCTruncate()
	Local cDDL := ""
	Local lOk  := .T.
	Local cDatabase  := Upper( TcGetDb() )
	
	//-------------------------------------------------------------------
	// Forca a criacao da tabela I10 antes de efetuar o Truncate
	//-------------------------------------------------------------------
	BCProcessTable()

	//-------------------------------------------------------------------
	// Monta a DDL.
	//-------------------------------------------------------------------
	Do Case
		Case ("DB2" $ cDataBase )
			cDDL := "DELETE FROM I10"
		Case ("POSTGRES" $ cDataBase )
			cDDL := "TRUNCATE I10"
		Otherwise
			cDDL := "TRUNCATE TABLE I10"
	EndCase
	
	//-------------------------------------------------------------------
	// Executa a DDL.
	//-------------------------------------------------------------------
	If ! ( TCSQLExec( cDDL ) == 0 )
		ConOut( "BCTruncate: " + TCSQLError() )
		lOk := .F.
	EndIf
Return lOk

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCGetNameView
Retorna o nome da view a ser criada

@param, cEntity, String, Nome da entidade.
@param, cCompany, String, Codigo da empresa.

@return string, nome da view
@author  Andreia Lima
@since   23/04/2019
/*/ 
//-------------------------------------------------------------------- 
Static Function BCGetNameView( cEntity, cCompany )
	Local cView := ""
	
	cView := "VW_" + Upper(cEntity) + "_" + cCompany

Return cView

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCCreateView
Cria a view

@param, cView, String, Query
@param, cNameView, String, Nome da view

@return number, status da criacao da view
@author  Andreia Lima
@since   23/04/2019
/*/ 
//-------------------------------------------------------------------- 
Function BCCreateView( cView, cNameView )
	Local nStatus   := 0
	Local cDDL      := ""
	Local cDrop     := ""
	Local cDatabase := Upper( TcGetDb() )
	
	Default cView     := ""
	Default cNameView := ""
	
	Do Case
		Case (cDataBase $ "ORACLE|POSTGRES" )
			cDDL := "CREATE OR REPLACE VIEW " + cNameView + " AS " + cView
		Case ("MSSQL" $ cDataBase )
			cDrop := "IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = '" + cNameView + "') DROP VIEW " + cNameView
			cDDL :=  "CREATE VIEW " + cNameView + " AS (" + cView + ")"
		Otherwise
			nStatus := MSG_ERR_CREATE_VIEW
	EndCase
	
	If ( nStatus == 0 )
		
		If ! Empty( cDrop )
			If ! ( TCSQLExec( cDrop ) == 0 )
				ConOut( "BCCreateView: " + TCSQLError() )
				nStatus := MSG_ERR_CREATE_VIEW
			EndIf
		EndIf
		
		If ( nStatus == 0 )
			If ! ( TCSQLExec( cDDL ) == 0 )
				ConOut( "BCCreateView: " + TCSQLError() )
				nStatus := MSG_ERR_CREATE_VIEW
			EndIf
		EndIf	
	EndIf	
	
Return nStatus	

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCCountEnt
Conta a quantidade de entidades foram criadas na tabela de controle.

@param cEntity, string, entidade para pesquisa
@param aSM0, array, lista de empresas\filiais do ambiente
@param cAuxAlias, string, alias temporario

@return number, quantidade de registros na I10 para a entidade.
@author  Marcia Junko
@since   16/09/2019
/*/ 
//-------------------------------------------------------------------- 
Function BCCountEnt( cEntity, aSM0, cAuxAlias )
	Local nCount	:= 0
	Local cDDL      := ""
	Local aSaveArea	:= GetArea()
	Local cAuxAlias := GetNextAlias()
	
	Default cEntity   := ""
	Default aSM0 	  := FWLoadSM0()
	Default cAuxAlias := GetNextAlias()

	cDDL := "SELECT I10_EMPRES FROM I10 WHERE I10_ENTITY = '" + cEntity + "' AND D_E_L_E_T_ = ' ' "
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDDL ), cAuxAlias , .T., .F. )

	While ( cAuxAlias )->( !Eof() )
		If AScan( aSM0, {|x| x[1] == alltrim( ( cAuxAlias )->I10_EMPRES ) } ) > 0
			nCount++
		EndIf
		( cAuxAlias )->( DBSkip() )
	End 
	
	( cAuxAlias )->( DBCloseArea() ) 
	
	If !Empty( aSaveArea )
		RestArea( aSaveArea )
	EnDIf

	FWFreeArray( aSaveArea )
Return nCount		

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCRetQuery
Retorna a query descriptografada gravada no banco de dados.

@param nId, number, R_E_C_N_O_ da view

@return string, estrutura da view (SELECT)
@author  Marcia Junko
@since   16/09/2019
/*/ 
//-------------------------------------------------------------------- 
Function BCRetQuery( nID )
	Local cQuery      := ""
	Local aSaveArea	:= GetArea()
	Local cAliasI10 	:= GetNextAlias()
	
	BeginSql Alias cAliasI10
		SELECT I10_QUERY FROM I10 
		WHERE I10.R_E_C_N_O_ = %exp:nID%
		AND I10.%NotDel%
 
	EndSql

	cQuery := BICrypt((cAliasI10)->I10_QUERY, 2)

	If !Empty(aSaveArea)
		RestArea(aSaveArea)
	EnDIf
(cAliasI10)->(dbCloseArea())

	FWFreeArray( aSaveArea )
Return cQuery	


//------------------------------------------------------------------- 
/*/{Protheus.doc} BCUpdVwName

Atualiza o nome da view na tabela I10

@param nId, number, ID da view
@param cViewName, string, conteudo que sera atualizado como nome da view
/*/ 
//-------------------------------------------------------------------- 
Function BCUpdVwName( nID, cViewName )
	Local aSaveArea	:= GetArea()
	Local cDDL 		  :="UPDATE I10 SET I10_VIEW ='" + cViewName +"' WHERE R_E_C_N_O_ = " + cValToChar(nId)

	If ! ( TCSQLExec( cDDL ) == 0 )
		ConOut( "BCUpdVwName: " + TCSQLError() )
	EndIf

	If !Empty(aSaveArea)
		RestArea(aSaveArea)
	EnDIf

	FWFreeArray( aSaveArea )
Return

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCViewList
Funcao que retorna a lista de views da Carol instaladas na base de dados.

@return array, views da Carol instaladas.
@author  Marcia Junko
@since   01/07/2021
/*/ 
//-------------------------------------------------------------------- 
Function BCViewList( )
	Local aSaveArea	:= GetArea()
	Local aListViews := {}
	Local cQuery := ""
	Local cTempAlias := ""
	
	cQuery := "SELECT I10_VIEW FROM I10 WHERE D_E_L_E_T_ = ' ' ORDER BY I10_USEVW, I10_ENTITY, I10_EMPRES"
    cQuery := ChangeQuery( cQuery )  

    cTempAlias := MPSysOpenQuery( cQuery )

	While ( cTempAlias )->( !Eof() )
		IF Ascan( aListViews, { |x| Alltrim( x ) == Alltrim( ( cTempAlias )->I10_VIEW ) } ) == 0
			Aadd( aListViews, Alltrim( ( cTempAlias )->I10_VIEW ) )
		EndIf
		(cTempAlias)->( DBSkip() )
	End
	( cTempAlias )->( DBCloseArea() )

	If !Empty( aSaveArea )
		RestArea( aSaveArea )
	EnDIf

	FWFreeArray( aSaveArea )
Return aListViews

//------------------------------------------------------------------- 
/*/{Protheus.doc} BCReInstall
Funcao que reinstala as views da Carol que ja existiam no ambiente.

OBS: Esta funcao sera chamada pelo UPDDISTR para reinstalar as view da 
Carol, apos a atualizacao da base.
A funcao foi criada como STATIC para controlar a sua execucao.

@return boolean, Indica se as views foram reinstaladas
@author  Marcia Junko
@since   01/07/2021
/*/ 
//-------------------------------------------------------------------- 
Static Function BCReInstall()
	Local oInstaller
	Local lReturn

	oInstaller := BCEmpInstaller():New()
	lReturn := oInstaller:AddViewControl( )
	oInstaller:Destroy()
	oInstaller := Nil
Return lReturn

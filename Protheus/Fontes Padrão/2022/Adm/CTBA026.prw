#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA026.CH'

Static cVerNova	:= ""
Static cVerAnt		:= ""

Static lEfetiva := .F.

//-----------------------------------------------------------
/*/{Protheus.doc} CTBA026
comparativo do plano de contas referencia

@return aDados - dados para carregar o field

@author Mayara Alves
@since 05/05/2015
@version 12
/*/
//-----------------------------------------------------------
Function CTBA026(cAlias,nReg,nOpc)
Local cTexto := ""

Iif (nOpc==11,(lEfetiva:= .T. , cTexto :=STR0001),(lEfetiva:= .F. , cTexto :=STR0002 )) //"Efetivar Revisão" ## "Revisão"

FWExecView(cTexto,'CTBA026', MODEL_OPERATION_UPDATE,, { || .T. }) //'Visualização - Bloqueio de Processo'

Return

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCAB 	:= FWFormStruct( 1, 'CVN', {|x| Alltrim(x) == "CVN_FILIAL"},/*lViewUsado*/ ) 
Local oStruCVN 	:= FWFormStruct( 1, 'CVN', ,/*lViewUsado*/ )
Local oModel		


//Campo virtual para o field
oStruCAB:AddField( STR0003, 		STR0003 , 	'PLANREF',	'C' ,6 , 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Plano Ref."
oStruCAB:AddField( STR0004, 		STR0004, 	'DESCPLA',	'C' ,40, 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Descrição"
oStruCAB:AddField( STR0005, 		STR0005,'VERANT',	'C' ,4 , 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Versão Anterior"
oStruCAB:AddField( STR0006, 		STR0006 , 	'VERNOV',	'C' ,4 , 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) // "Versão Nova"

//Campo virtual para o grid
oStruCVN:AddField( STR0007, 		STR0007 , 	'STATUS',	'C' ,6 , 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Plano Ref."
oStruCVN:AddField(""		,""			,"LEGENDA"	,"C",15,0,,,,,{||},,,.T.) //STR0
oStruCVN:AddField( STR0008, 		STR0008 , 	'CONTANT',	'C' ,6 , 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Conta Ant."
oStruCVN:AddField( STR0009,			STR0009 ,'DESCANT','C' ,40, 0 , Nil, NIL , NIL  ,NIL , NIL, Nil, Nil , .T. ) //"Descrição Ant."

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CTBA026',/*bPreValidacao*/, /*bPosValidacao*/,  { |oModel| CT026GRV( oModel ) }/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CVNMASTER', /*cOwner*/, oStruCAB,/*bPreVld*/, /*bPost*/ , { || LoadCab(oModel)}) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid
 oModel:AddGrid( 'CVNDETAIL', 'CVNMASTER', oStruCVN, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, { |oModel| LoadGrid(oModel)} )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CVNDETAIL', { { 'CVN_FILIAL', 'xFilial( "CVN" )' },{ 'CVN_CODPLA', 'PLANREF' } }, CVN->( IndexKey( 1 ) ) )
                                                                                                                     
oModel:SetPrimaryKey({'xFilial("CVN")','CVN_CODPLA','CVN_LINHA','CVN_VERSAO'})

//Altera o When dos campos
oStruCAB:SetProperty( '*', MODEL_FIELD_WHEN, {|| .F.})
oStruCVN:SetProperty( '*', MODEL_FIELD_WHEN, {|| .F.})

If !lEfetiva
	oStruCVN:SetProperty( 'CVN_CTAREL', MODEL_FIELD_WHEN, {|| WhenCtarel()})
EndIf

//Valid
oStruCVN:SetProperty('CVN_CTAREL'  ,MODEL_FIELD_VALID,{|| VldCtaRel()	} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0010 ) //"Plano de Contas Referencial"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CVNMASTER' ):SetDescription( STR0011)//"Cabeçalho"
oModel:GetModel( 'CVNDETAIL' ):SetDescription( STR0012)//"Plano de Conta"


// Não permite inserir linhas na grid
oModel:GetModel( 'CVNDETAIL' ):SetNoInsertLine( .T. )
// Não permite apagar as linhas da grid
oModel:GetModel( 'CVNDETAIL' ):SetNoDeleteLine( .T. )


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCAB := FWFormStruct( 2, 'CVN',{|x| Alltrim(x) == "CVN_FILIAL"} )
Local oStruCVN := FWFormStruct( 2, 'CVN' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'CTBA026' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

//Insere campos na struct da view 
//		  AddField( cIdField, cOrdem,	 cTitulo, 	cDescric, 			aHelp, cType, cPicture,	bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine )
oStruCAB:AddField('PLANREF','01' , STR0003 , STR0003 ,{ STR0003 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			,/*IIF(!INCLUI,M->CTG_CALEND,"")*/, .T. ,NIL )  //"Plano Ref."
oStruCAB:AddField('DESCPLA','02' , STR0004 , STR0004,{ STR0004 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Descrição"
oStruCAB:AddField('VERANT',	'03' , STR0005 , STR0005,{ STR0005 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Versão Anterior"
oStruCAB:AddField('VERNOV',	'04' , STR0006 , STR0006,{STR0006 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Versão Nova"

oStruCVN:AddField('STATUS',	'01' , STR0007 , STR0007,{ STR0007 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Status"
oStruCVN:AddField("LEGENDA","02","","",,"C","@BMP",,,.F.,,,,,,,,.F.) //Legenda
oStruCVN:AddField('CONTANT','03' , STR0008 , STR0008,{ STR0008 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Conta Ant."
oStruCVN:AddField('DESCANT','04' , STR0009 , STR0009,{ STR0009 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Descrição Ant."

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CAB', oStruCAB, 'CVNMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CVN', oStruCVN, 'CVNDETAIL' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 15 )
oView:CreateHorizontalBox( 'INFERIOR'	, 85 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CVN', 'INFERIOR' )

oView:EnableTitleView( 'VIEW_CAB', STR0011, RGB( 224, 30, 43 )  )//"Cabeçalho"
oView:EnableTitleView( 'VIEW_CVN', STR0012, RGB( 224, 30, 43 )  )//"Plano de Conta"


//Remove campo da estrutura
oStruCVN:RemoveField( 'CVN_CODPLA' ) 
oStruCVN:RemoveField( 'CVN_DSCPLA' ) 
oStruCVN:RemoveField( 'CVN_DTVIGI' ) 
oStruCVN:RemoveField( 'CVN_DTVIGF' ) 
oStruCVN:RemoveField( 'CVN_ENTREF' ) 
oStruCVN:RemoveField( 'CVN_LINHA' ) 
oStruCVN:RemoveField( 'CVN_TPUTIL' ) 
oStruCVN:RemoveField( 'CVN_VERSAO' ) 
oStruCVN:RemoveField( 'CVN_CLASSE' ) 
//oStruCVN:RemoveField( 'CVN_CTASUP' ) 
oStruCVN:RemoveField( 'CVN_STAPLA' ) 

//Botão Legenda
oView:AddUserButton( STR0013, 'CLIPS', { |oView| FLegenda() } )//'Legenda'

If lEfetiva
	//Tratamento para permitir a confirmação, pois a ordem é de alterção  
	oView:lModify := .T.
	oView:oModel:lModify := .T.
EndIf

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} LoadCab
Carrega os dados do cabeçalho

@return aDados - dados para carregar o field

@author Mayara Alves
@since 05/05/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function LoadCab(oModel)
Local aDados		:= {}
Local oStruCAB	:= oModel:GetModelStruct("CVNMASTER")[3]:oFormModelStruct
Local aCposVlr	:= oStruCAB:GetFields()
Local aFilCpos	:= {}
Local nContCpo	:= 0


//Verifica a versão para o comparativo 
cVerNova := FVersao(CVN->CVN_CODPLA,1)
	
//Pega a versão anterior
If cVerNova == CVN->CVN_VERSAO
	cVerAnt := FVersao(CVN->CVN_CODPLA,2)
Else 
	cVerAnt:=  CVN->CVN_VERSAO
EndIf

For nContCpo := 1 To Len(aCposVlr)
	If aCposVlr[nContCpo][3] == "CVN_FILIAL"
		AADD(aFilCpos,xFilial("CVN"))
	ElseIf aCposVlr[nContCpo][3] == "PLANREF"
		AADD(aFilCpos,CVN->CVN_CODPLA)
	ElseIf aCposVlr[nContCpo][3] == "DESCPLA"
		AADD(aFilCpos,CVN->CVN_DSCPLA)
	ElseIf aCposVlr[nContCpo][3] == "VERANT"
		AADD(aFilCpos,cVerAnt)
	ElseIf aCposVlr[nContCpo][3] == "VERNOV"
		AADD(aFilCpos,cVerNova)	
	EndIf
Next nContCpo

aDados := {aFilCpos,0}

Return aDados

//-------------------------------------------------------------------
/*{Protheus.doc} FVersao  
Valida a criação da nova versao

@return cRet - versão

@author Mayara Alves
@version P12
@since   05/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Static Function FVersao(cPlan,nVer)
Local cRet		:= ""
Local cQuery	:= ""
Local cAliasCVN	:= GetNextAlias()
Local cRet		:= ""

Default cPlan := ""
Default nVer	:= 0

If nVer == 1 //Novo plano
	cQuery := " SELECT MAX(CVN_VERSAO) VERSAO" +CRLF
	cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN" +CRLF
	cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' " +CRLF
	cQuery += " AND CVN_CODPLA = '"+cPlan+"'" +CRLF
	cQuery += " AND CVN_STAPLA = '2'" +CRLF
	cQuery += " AND CVN.D_E_L_E_T_ = ' '" +CRLF
ElseIf nVer == 2 //Plano anterior
	cQuery := " SELECT MAX(CVN_VERSAO) VERSAO" +CRLF
	cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN" +CRLF
	cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' " +CRLF
	cQuery += " AND CVN_CODPLA = '"+cPlan+"'" +CRLF
	cQuery += " AND CVN_STAPLA = '1'" +CRLF
	cQuery += " AND CVN.D_E_L_E_T_ = ' '" +CRLF
EndIf
cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCVN)

DbSelectArea(cAliasCVN)
If (cAliasCVN)->(!Eof()) 
	cRet := (cAliasCVN)->VERSAO
EndIf
	
	(cAliasCVN)->(dbCloseArea())

Return cRet



//-----------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Carrega os dados do Grid

@return aDados - dados para carregar o grid

@author Mayara Alves
@since 05/05/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function LoadGrid(oModel)
Local aDados		:= {}
Local oView		:= FWViewActive()
Local oStruCVN	:= oModel:GetStruct()
Local oModelCab	:= oModel:GetModel()
Local oModelCVN	:= oModelCab:GetModel("CVNDETAIL")
Local cAliasCVN	:= FQryCVN(CVN->CVN_CODPLA)
Local aCposVlr	:= {}
Local aFilCpos	:= {}
Local nContCpo	:= 0
Local cVerNova	:= ""
Local cVerAnt		:= ""


aCposVlr := oStruCVN:GetFields()


While (cAliasCVN)->(!Eof())

	cLegen := fCorLeg(AllTrim((cAliasCVN)->(STACOMP)))
	For nContCpo := 1 To Len(aCposVlr)
	
	If aCposVlr[nContCpo][3] == "CVN_FILIAL"
		AADD(aFilCpos,xFilial("CVN"))
	ElseIf aCposVlr[nContCpo][3] == "CVN_CODPLA"
		AADD(aFilCpos,CVN->CVN_CODPLA)
	ElseIf aCposVlr[nContCpo][3] == "CVN_DSCPLA"
		AADD(aFilCpos,CVN->CVN_DSCPLA)
	ElseIf aCposVlr[nContCpo][3] == "CVN_DTVIGI"
		AADD(aFilCpos,Date())
	ElseIf aCposVlr[nContCpo][3] == "CVN_DTVIGF"
		AADD(aFilCpos,Date())
	ElseIf aCposVlr[nContCpo][3] == "CVN_ENTREF"
		AADD(aFilCpos,(cAliasCVN)->(ENTREF))
	ElseIf aCposVlr[nContCpo][3] == "CVN_LINHA"
		AADD(aFilCpos,(cAliasCVN)->(LINHA))
	ElseIf aCposVlr[nContCpo][3] == "CVN_CTAREF" //PLANO NOVO
		AADD(aFilCpos,(cAliasCVN)->(CONTANOV))	
	ElseIf aCposVlr[nContCpo][3] == "CVN_DSCCTA" //PLANO NOVO
		AADD(aFilCpos,(cAliasCVN)->(DESCNOV))	
	ElseIf aCposVlr[nContCpo][3] == "CVN_TPUTIL"
		AADD(aFilCpos,(cAliasCVN)->(TPUTIL))
	ElseIf aCposVlr[nContCpo][3] == "CVN_NATCTA"
		AADD(aFilCpos,(cAliasCVN)->(NATCTA))
	ElseIf aCposVlr[nContCpo][3] == "CVN_VERSAO"
		AADD(aFilCpos,(cAliasCVN)->(VERNOV))
	ElseIf aCposVlr[nContCpo][3] == "CVN_CLASSE"
		AADD(aFilCpos,(cAliasCVN)->(CLASSE))		
	ElseIf aCposVlr[nContCpo][3] == "CVN_CTASUP"
		AADD(aFilCpos,(cAliasCVN)->(CTASUP))	
	ElseIf aCposVlr[nContCpo][3] == "CVN_CTAREL"
		AADD(aFilCpos,(cAliasCVN)->(CTAREL))		
	ElseIf aCposVlr[nContCpo][3] == "STATUS"
		AADD(aFilCpos,(cAliasCVN)->(STACOMP))
	ElseIf aCposVlr[nContCpo][3] == "LEGENDA"
		AADD(aFilCpos,cLegen)
	ElseIf aCposVlr[nContCpo][3] == "CONTANT" //PLANO ANTIGO
		AADD(aFilCpos,(cAliasCVN)->(CONTANT))
	ElseIf aCposVlr[nContCpo][3] == "DESCANT"	//PLANO ANTIGO
		AADD(aFilCpos,(cAliasCVN)->(DESCANT))	
	Else
		AADD(aFilCpos,CriaVar(aCposVlr[nContCpo][3],.F.))
	EndIf
	
	Next nProc
	
	AADD(aFilCpos,.T.	)
	AADD(aDados,{0,aFilCpos})

	aFilCpos := {}
	
(cAliasCVN)->(DbSkip())
EndDo

If Select(cAliasCVN) > 0
	(cAliasCVN)->(DbCloseArea())
EndIf
Return aDados



//-----------------------------------------------------------
/*/{Protheus.doc} FQryCVN
Gera a query com os planos de contas das duas verções
para carregar o grid.

@return cNextAlias - alias com query.

@author Mayara Akves
@since 06/05/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function FQryCVN(cPlan)
Local aArea		:= GetArea()
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''

// --Totalmente Igual - Status NA
cQuery := " SELECT CVN1.CVN_CTAREF CONTANT, CVN1.CVN_DSCCTA DESCANT, CVN2.CVN_CTAREF CONTANOV, CVN2.CVN_DSCCTA DESCNOV, CVN1.CVN_CODPLA CVN_CODPLA, CVN1.CVN_VERSAO VERANT,"+CRLF
cQuery += " CVN2.CVN_VERSAO VERNOV,CVN2.CVN_LINHA LINHA, CVN2.CVN_TPUTIL TPUTIL,CVN2.CVN_NATCTA NATCTA, CVN2.CVN_CLASSE CLASSE,CVN2.CVN_CTASUP CTASUP,CVN2.CVN_CTAREL CTAREL,CVN2.CVN_ENTREF ENTREF,'NA' STACOMP" +CRLF
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN1" +CRLF
cQuery += " INNER JOIN " + RetSqlname( "CVN" ) + " CVN2" +CRLF
cQuery += " ON CVN2.CVN_FILIAL= CVN1.CVN_FILIAL" +CRLF
cQuery += " AND CVN2.CVN_CODPLA = CVN1.CVN_CODPLA" +CRLF
cQuery += " AND CVN2.CVN_DSCCTA = CVN1.CVN_DSCCTA" +CRLF
cQuery += " AND CVN2.CVN_CTAREF = CVN1.CVN_CTAREF " +CRLF
cQuery += " AND CVN2.CVN_VERSAO = '"+cVerNova+"'"+CRLF
cQuery += " WHERE CVN1.CVN_FILIAL = '"+xFilial("CVN")+"' " +CRLF
cQuery += " AND CVN1.CVN_VERSAO = '"+cVerAnt+"'"+CRLF
cQuery += " AND CVN1.CVN_CODPLA = '"+cPlan+"'"+CRLF
cQuery += " AND CVN1.D_E_L_E_T_ = ''" +CRLF
cQuery += " AND CVN2.D_E_L_E_T_ = ''" +CRLF
cQuery += " UNION" +CRLF
// --Totalmente Igual - Descrição Diferente
cQuery += " SELECT CVN1.CVN_CTAREF CONTANT, CVN1.CVN_DSCCTA DESCANT, CVN2.CVN_CTAREF CONTANOV, CVN2.CVN_DSCCTA DESCNOV,CVN1.CVN_CODPLA CVN_CODPLA, CVN1.CVN_VERSAO VERANT,"+CRLF
cQuery += "  CVN2.CVN_VERSAO VERNOV,CVN2.CVN_LINHA LINHA, CVN2.CVN_TPUTIL TPUTIL,CVN2.CVN_NATCTA NATCTA,CVN2.CVN_CLASSE CLASSE,CVN2.CVN_CTASUP CTASUP,CVN2.CVN_CTAREL CTAREL,CVN2.CVN_ENTREF ENTREF,'AD' STACOMP" +CRLF
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN1" +CRLF
cQuery += " INNER JOIN " + RetSqlname( "CVN" ) + " CVN2" +CRLF
cQuery += " ON CVN2.CVN_FILIAL= CVN1.CVN_FILIAL" +CRLF
cQuery += " AND CVN2.CVN_CODPLA = CVN1.CVN_CODPLA" +CRLF
cQuery += " AND CVN2.CVN_DSCCTA <> CVN1.CVN_DSCCTA" +CRLF
cQuery += " AND CVN2.CVN_CTAREF = CVN1.CVN_CTAREF " +CRLF
cQuery += " AND CVN2.CVN_VERSAO = '"+cVerNova+"'"+CRLF
cQuery += " WHERE CVN1.CVN_FILIAL ='"+xFilial("CVN")+"' " +CRLF
cQuery += " AND CVN1.CVN_VERSAO = '"+cVerAnt+"'"+CRLF
cQuery += " AND CVN1.CVN_CODPLA = '"+cPlan+"'"+CRLF
cQuery += " AND CVN1.D_E_L_E_T_ = ''" +CRLF
cQuery += " AND CVN2.D_E_L_E_T_ = ''" +CRLF

cQuery += " UNION" +CRLF
//--Excluido
cQuery += " SELECT  CONTANT,  DESCANT,  CONTANOV,  DESCNOV,CVN_CODPLA, VERANT,"+CRLF
cQuery += "  VERNOV, LINHA, TPUTIL, NATCTA, CLASSE, CTASUP, CTAREL, ENTREF,  STACOMP FROM " +CRLF  
cQuery += " ( " +CRLF
cQuery += " SELECT CVN1.CVN_CTAREF CONTANT, CVN1.CVN_DSCCTA DESCANT, ISNULL(CVN2.CVN_CTAREF,'') CONTANOV, CVN2.CVN_DSCCTA DESCNOV,CVN1.CVN_CODPLA CVN_CODPLA, CVN1.CVN_VERSAO VERANT,"+CRLF
cQuery += " CVN2.CVN_VERSAO VERNOV,CVN1.CVN_LINHA LINHA,CVN1.CVN_TPUTIL TPUTIL,CVN1.CVN_NATCTA NATCTA ,CVN1.CVN_CLASSE CLASSE,CVN1.CVN_CTASUP CTASUP,CVN2.CVN_CTAREL CTAREL,CVN2.CVN_ENTREF ENTREF, 'E' STACOMP" +CRLF  
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN1" +CRLF
cQuery += " LEFT JOIN " + RetSqlname( "CVN" ) + " CVN2" +CRLF
cQuery += " ON" +CRLF
cQuery += " CVN2.CVN_VERSAO = '"+cVerNova+"'"+CRLF
cQuery += " AND CVN2.CVN_FILIAL ='"+xFilial("CVN")+"' " +CRLF
cQuery += " AND CVN1.CVN_FILIAL = CVN2.CVN_FILIAL" +CRLF
cQuery += " AND CVN2.CVN_CODPLA =  CVN1.CVN_CODPLA" +CRLF
cQuery += " AND CVN2.CVN_CTAREF = CVN1.CVN_CTAREF " +CRLF
cQuery += " AND CVN2.D_E_L_E_T_ = ''" +CRLF
cQuery += " WHERE " +CRLF
cQuery += " CVN1.CVN_CODPLA = '"+cPlan+"'"+CRLF
cQuery += " AND CVN1.CVN_VERSAO = '"+cVerAnt+"'"+CRLF 
cQuery += " AND CVN1.D_E_L_E_T_ = ''" +CRLF
cQuery += " ) EXC" +CRLF
cQuery += " WHERE " +CRLF
cQuery += " CONTANOV = '' " +CRLF
cQuery += " UNION" +CRLF
// --Incluido
cQuery += " SELECT  CONTANT,  DESCANT,  CONTANOV,  DESCNOV,CVN_CODPLA, VERANT,"+CRLF
cQuery += "  VERNOV, LINHA, TPUTIL, NATCTA, CLASSE, CTASUP, CTAREL, ENTREF,  STACOMP FROM " +CRLF  
cQuery += " ( 
cQuery += " SELECT ISNULL(CVN2.CVN_CTAREF,'') CONTANT, CVN2.CVN_DSCCTA DESCANT, CVN1.CVN_CTAREF CONTANOV, CVN1.CVN_DSCCTA DESCNOV,CVN1.CVN_CODPLA CVN_CODPLA, CVN2.CVN_VERSAO VERNOV ,"+CRLF
cQuery += " CVN1.CVN_VERSAO VERANT,CVN1.CVN_LINHA LINHA,CVN1.CVN_TPUTIL TPUTIL,CVN1.CVN_NATCTA NATCTA,CVN1.CVN_CLASSE CLASSE,CVN1.CVN_CTASUP CTASUP,CVN1.CVN_CTAREL CTAREL,CVN1.CVN_ENTREF ENTREF, 'I' STACOMP" +CRLF 
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN1" +CRLF
cQuery += " LEFT JOIN " + RetSqlname( "CVN" ) + " CVN2" +CRLF
cQuery += " ON CVN2.CVN_FILIAL ='"+xFilial("CVN")+"' " +CRLF
cQuery += " AND CVN1.CVN_FILIAL = CVN2.CVN_FILIAL
cQuery += " AND CVN2.D_E_L_E_T_ = ''" +CRLF
cQuery += " AND CVN2.CVN_VERSAO = '"+cVerAnt+"'"+CRLF
cQuery += " AND CVN2.CVN_CODPLA =  CVN1.CVN_CODPLA" +CRLF
cQuery += " AND CVN2.CVN_CTAREF = CVN1.CVN_CTAREF " +CRLF
cQuery += " WHERE " +CRLF
cQuery += " CVN1.CVN_CODPLA = '"+cPlan+"'"+CRLF
cQuery += " AND CVN1.CVN_VERSAO = '"+cVerNova+"'"+CRLF
cQuery += " AND CVN1.D_E_L_E_T_ = ''" +CRLF
cQuery += " ) INC" +CRLF
cQuery += " WHERE " +CRLF
cQuery += " CONTANT = '' " +CRLF

cQuery := ChangeQuery(cQuery)  

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)  

RestArea(aArea)

Return (cNextAlias)


//-----------------------------------------------------------
/*/{Protheus.doc} fCorLeg
Legenda do grid

@param  cStatus - status da legenda

@return cNextAlias - alias com query.

@author Mayara Akves
@since 06/05/2015
@version 12
/*/
//-----------------------------------------------------------
Static Function  fCorLeg(cStatus)
Local cRet	:= ""

Do Case
	Case cStatus == "NA" 	//Nada alterado
		cRet := "BR_VERDE"	
	Case cStatus == "AD"		//Descrição diferente
		cRet := "BR_AMARELO"	
	Case cStatus == "E"		//excluida
		cRet := "BR_VERMELHO" 	
	Case cStatus == "I" 		//incluida
		cRet := "BR_LARANJA"	
EndCase


Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FLegenda
Botão de legenda
@author Mayara Alves
@since  06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function FLegenda()
Local aLegenda	 := {}

aAdd(aLegenda,{"BR_VERDE"		,STR0014}) //"Nada Alterado"
aAdd(aLegenda,{"BR_AMARELO" 	,STR0015}) //"Descrição Alterada"
aAdd(aLegenda,{"BR_VERMELHO" 	,STR0016})//"Conta Excluida"
aAdd(aLegenda,{"BR_LARANJA" 	,STR0017})//"Conta Incluida"



BrwLegenda("STR0013","STR0013", aLegenda )//"Legenda"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc}CT026GRV
gravação do model
@author Mayara Alves
@since  06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function CT026GRV( oModel )

Local oModelCVN	:= oModel:GetModel('CVNDETAIL')
Local nX	:= 0 //para percorrer o grid
Local aArea	:= GetArea()
Local aAreaCVN	:= CVN->(GetArea())
Local aAreaCVD	:= CVD->(GetArea())
Local lAtu		:= .F. //Atualiza CVN
Local aNConta	:= {}
Local aButtons	:= {}
                                                                                                      

//Revisão
If !lEfetiva
	dbSelectArea("CVN")
	CVN->(dbSetOrder(1))//CVN_FILIAL+CVN_CODPLA+CVN_LINHA+CVN_VERSAO
	BEGIN TRANSACTION
		For nX := 1 to oModelCVN:Length()
		
			oModelCVN:GoLine( nX )
			If !Empty(oModelCVN:GetValue("CVN_CTAREL"))
				DbSelectArea("CVN")
				If CVN->(dbSeek(xFilial("CVN")+oModelCVN:GetValue("CVN_CODPLA")+oModelCVN:GetValue("CVN_LINHA")+FWFldGet("VERNOV")))
					CVN->(RecLock("CVN" , .F.))
					CVN->CVN_CTAREL	:= oModelCVN:GetValue("CVN_CTAREL")
					CVN->(MsUnlock("CVN"))
				EndIf
			EndIf
		Next nX
	END TRANSACTION
Else

	dbSelectArea("CVD")
	CVD->(dbSetOrder(5))//CVD_FILIAL+CVD_CODPLA+CVD_CTAREF+CVD_VERSAO+CVD_CONTA                                                                                                           
 	BEGIN TRANSACTION
		For nX := 1 to oModelCVN:Length()
		
			oModelCVN:GoLine( nX )
			If oModelCVN:GetValue("STATUS") == "NA" .Or. oModelCVN:GetValue("STATUS") == "AD"	 	//Nada alterado ou descrição diferente
				If CVD->(dbSeek(xFilial("CVD")+oModelCVN:GetValue("CVN_CODPLA")+oModelCVN:GetValue("CVN_CTAREF")+FWFldGet("VERANT")))
					cConta := CVD->CVD_CONTA
					cCC		:= CVD->CVD_CUSTO
				
					CVD->(RecLock("CVD" , .T.))
					CVD->CVD_FILIAL := xFilial("CVD")
					CVD->CVD_CONTA := cConta
					CVD->CVD_ENTREF := oModelCVN:GetValue("CVN_ENTREF")
					CVD->CVD_CODPLA := oModelCVN:GetValue("CVN_CODPLA")
					CVD->CVD_CTAREF := oModelCVN:GetValue("CVN_CTAREF")
					CVD->CVD_CLASSE := oModelCVN:GetValue("CVN_CLASSE") 
					CVD->CVD_CUSTO := cCC
					CVD->CVD_TPUTIL := oModelCVN:GetValue("CVN_TPUTIL")
					CVD->CVD_VERSAO := oModelCVN:GetValue("CVN_VERSAO")
					CVD->CVD_NATCTA := oModelCVN:GetValue("CVN_NATCTA")
					CVD->CVD_CTASUP := oModelCVN:GetValue("CVN_CTASUP")
					CVD->(MsUnlock("CVD"))
					
					lAtu := .T.
				Else //Contas não relacionadas no CT1
					AADD(aNConta,oModelCVN:GetValue("CONTANT") +" - " +oModelCVN:GetValue("DESCANT")+ " " +oModelCVN:GetValue("CVN_LINHA"))
	
				EndIf
			ElseIf AllTrim(oModelCVN:GetValue("STATUS")) == "I"	//Inclusão
				If CVD->(!dbSeek(xFilial("CVD")+oModelCVN:GetValue("CVN_CODPLA")+oModelCVN:GetValue("CVN_CTAREL")+FWFldGet("VERNOV")))
					//posiciona na versão antiga
					CVD->(dbSeek(xFilial("CVD")+oModelCVN:GetValue("CVN_CODPLA")+oModelCVN:GetValue("CVN_CTAREL")+FWFldGet("VERANT")))
					cConta := CVD->CVD_CONTA
					cCC		:= CVD->CVD_CUSTO
					If !Empty(cConta)
						CVD->(RecLock("CVD" , .T.))
						CVD->CVD_FILIAL := xFilial("CVD")
						CVD->CVD_CONTA := cConta
						CVD->CVD_ENTREF := oModelCVN:GetValue("CVN_ENTREF")
						CVD->CVD_CODPLA := oModelCVN:GetValue("CVN_CODPLA")
						CVD->CVD_CTAREF := oModelCVN:GetValue("CVN_CTAREF")
						CVD->CVD_CUSTO := cCC
						CVD->CVD_TPUTIL := oModelCVN:GetValue("CVN_TPUTIL")
						CVD->CVD_CLASSE := oModelCVN:GetValue("CVN_CLASSE")
						CVD->CVD_NATCTA := oModelCVN:GetValue("CVN_NATCTA")
						CVD->CVD_CTASUP := oModelCVN:GetValue("CVN_CTASUP")
						CVD->CVD_VERSAO := FWFldGet("VERNOV")
						CVD->(MsUnlock("CVD"))
					EndiF
					lAtu := .T.
				EndIf
			Else //Contas não relacionadas no CT1
				AADD(aNConta,oModelCVN:GetValue("CONTANT") +" - " +oModelCVN:GetValue("DESCANT")+ " " +oModelCVN:GetValue("CVN_LINHA"))
			EndIf
			
		Next nX
		
		dbSelectArea("CVN")
								
		CVN->(dbSetOrder(3))	//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTASUP+CVN_CTAREF
		
		
		//versão antiga
		If CVN->(dbSeek(xFilial("CVN")+FWFldGet("PLANREF")+FWFldGet("VERANT")))
			While (xFilial("CVN")+FWFldGet("PLANREF")+FWFldGet("VERANT") == CVN->CVN_FILIAL+CVN->CVN_CODPLA+CVN->CVN_VERSAO)
				CVN->(RecLock("CVN" , .F.))
				CVN->CVN_STAPLA	:= "3" // Encerrado
				CVN->(MsUnlock("CVN"))
			
				CVN->(DbSkip())
			End
		EndIf
		
		
		//versão nova
		If CVN->(dbSeek(xFilial("CVN")+FWFldGet("PLANREF")+FWFldGet("VERNOV")))
			While (xFilial("CVN")+FWFldGet("PLANREF")+FWFldGet("VERNOV") == CVN->CVN_FILIAL+CVN->CVN_CODPLA+CVN->CVN_VERSAO)
				CVN->(RecLock("CVN" , .F.))
				CVN->CVN_STAPLA	:= "1" // Ativa
				CVN->(MsUnlock("CVN"))
		
					CVN->(DbSkip())
			End
		EndIf


		//Log de contas não relacionadas
		ProcLogIni({})

		FormBatch( STR0018, aNConta, aButtons,, 220, 560 )//'Contas não relacionadas'

	  END TRANSACTION
EndIf

	
RestArea(aArea)
RestArea(aAreaCVN)	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}WhenCtarel
when CVN_CTAREL
@author Mayara Alves
@since  06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function WhenCtarel()
Local lRet := .T.
Local oModel		:= FWModelActive()
Local oModelCab	:= oModel:GetModel()
Local oModelCVN	:= oModelCab:GetModel("CVNDETAIL")

If Alltrim((oModelCVN:GetValue("STATUS"))) == "E"   .Or. lEfetiva
	lRet := .F.
EndIf 
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb026Filt
Filtro consulta padrão
@author Mayara Alves
@since  06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb026Filt()
Local cRet	:= ""

cRet	:= CVN->CVN_CODPLA ==FWFldGet("PLANREF").And. CVN->CVN_VERSAO == FWFldGet("VERANT")

Return(cRet)



//-------------------------------------------------------------------
/*/{Protheus.doc}VldCtaRel
Validação do campo
@author Mayara Alves
@since  06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function VldCtaRel()
Local lRet := .T.
Local oModel	:= FWModelActive()
Local oModelCAB	:= oModel:GetModel('CVNMASTER')
Local oModelCVN	:= oModel:GetModel('CVNDETAIL')
Local aArea		:= GetArea()
Local cAliasCVN	:= GetNextAlias()
Local cQuery		:= ''

If !Empty(oModelCVN:GetValue("CVN_CTAREL"))               //valida o valor do campo conta versao anterior. 
	cQuery := " SELECT CVN_CTAREF, CVN_CLASSE "+CRLF
	cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN" +CRLF
	cQuery += " WHERE CVN_FILIAL ='"+xFilial("CVN")+"' " +CRLF
	cQuery += " AND CVN_CODPLA = '"+FWFldGet("PLANREF")+"'"+CRLF
	cQuery += " AND CVN_VERSAO = '"+FWFldGet("VERANT")+"'"+CRLF
	cQuery += " AND CVN_CTAREF = '"+oModelCVN:GetValue("CVN_CTAREL")+"'"+CRLF
	cQuery += " AND CVN.D_E_L_E_T_ = ''" +CRLF
	
	cQuery := ChangeQuery(cQuery)  
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCVN,.T.,.T.)  
	
	If (cAliasCVN)->(Eof())
		lRet := .F.
	Else
		If (cAliasCVN)->CVN_CLASSE <> OMODELCVN:GETVALUE("CVN_CLASSE")
			lRet	:= .F.
		EndIf
	EndIf
	
	(cAliasCVN)->(DbCloseArea())  
	  
EndIf

Return lRet

#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA891.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Realiza apontamento dos materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruTFL 	:= 	FWFormStruct( 1, 'TFL' )
Local oStruTGU 	:= 	FWFormStruct( 1, 'TGU' )
Local bCommit	:= {|oModel|At891Commit(oModel)}
Local oModel 	:= MPFormModel():New( 'TECA891',/*bPreValidacao*/,/*bPosVld*/,bCommit,/*bCancel*/)

oStruTFL:AddField( STR0001 ,STR0001 ,'TFL_DESLOC', 'C', 60, 0,/*bValid*/,/*bWhen*/, /*aValues*/, .F., ,/*lKey*/, /*lNoUpd*/, .F./*lVirtual*/,/*cValid*/) //Descrição
oStruTFL:AddField( STR0002 ,STR0002 ,'TFL_SALDO' , 'N', 16, 2,,/*bWhen*/, /*aValues*/, .F., ,/*lKey*/, /*lNoUpd*/, .F./*lVirtual*/,/*cValid*/)			  //Status
oStruTFL:AddField( STR0026 ,STR0026 ,'TFL_CNTREC', 'C', TAMSX3("TFJ_CNTREC")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {|| Posicione("TFJ", 1, xFilial("TFJ") + TFL->TFL_CODPAI ,"TFJ_CNTREC") } ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Contrato recorrente"##"Contrato Recorrente"

oModel:AddFields( 'MODEL_TFL' , /*cOwner*/ , oStruTFL )

oModel:AddGrid ( 'MODEL_TGU' , 'MODEL_TFL' , oStruTGU, {|oModel,nLine,cAction| FDelReg(oModel,nLine,cAction)} )
oModel:GetModel( 'MODEL_TGU' ):SetUniqueLine( { 'TGU_COD'} )

oModel:SetRelation( 'MODEL_TGU', { { 'TGU_FILIAL', 'xFilial( "TGU" )' }, { 'TGU_CODTFL', 'TFL_CODIGO' } }, TGU->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_TGU' ):SetOptional(.T.)

//Aplica o filtro no model
oModel:GetModel( 'MODEL_TGU' ):SetLoadFilter( { { 'TGU_APURAC', "' '" } } )

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return ( oModel )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Realiza apontamento dos materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel ( 'TECA891' )
Local oView 	:= 	FWFormView():New()

Local oStruTFL  :=  Nil
Local oStruTGU 	:= 	Nil

cCmpsFil   :=  '|TFL_LOCAL|'
oStruTFL 	:= 	FWFormStruct( 2, 'TFL', {|cCampo| ( AllTrim( cCampo )+"|" $ cCmpsFil ) } )

cCmpsFil	:= '|TGU_CODTWZ|'
oStruTGU   := 	FWFormStruct( 2, 'TGU', {|cCampo| !( AllTrim( cCampo )+"|" $ cCmpsFil ) } )

oStruTFL:SetProperty('TFL_LOCAL', MVC_VIEW_CANCHANGE, .F.)

oView:SetModel( oModel )            
                                        
oStruTFL:AddField( 'TFL_DESLOC', ; // cIdField
       			 '04', ; // cOrdem
                   STR0001, ; // cTitulo - Descrição
                   STR0001, ; // cDescric  - Descrição
                   {}, ; // aHelp
                   'C', ; // cType
                   '', ; // cPicture
       			  Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    '', ; // cIniBrow
                    .T., ; // lVirtual
                    '' ) // cPictVar
                    
oStruTFL:AddField( 'TFL_CONTRT', ; // cIdField
       				'05',; // cOrdem
                    STR0003,; // cTitulo - Contrato
                    STR0003 , ; // cDescric - Contrato
                    {}, ; // aHelp
                   	'C', ; // cType
                   	'', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar     
                    
oStruTFL:AddField( 'TFL_CONREV', ; // cIdField
       				'06', ; // cOrdem
                    STR0004 , ; // cTitulo - Revisão
                    STR0004 , ; // cDescric - Revisão
                    {}, ; // aHelp
                   	'C', ; // cType
                   	'', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar    
                    
oStruTFL:AddField( 'TFL_SALDO', ; // cIdField
       				'07', ; // cOrdem
                    STR0002 , ; // cTitulo - Saldo
                    STR0002 , ; // cDescric - Saldo
                    {}, ; // aHelp
                   	'N', ; // cType
                   	'@E 999,999,999.99', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar     

oStruTFL:AddField( 'TFL_CNTREC', ; // cIdField
       				'08', ; // cOrdem
                     STR0026, ; // "Contrato Recorrente"
                     STR0026, ; // "Contrato Recorrente"
                     {}, ; // aHelp
                   	'C', ; // cType
                   	'@ ', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .F., ; // lCanChange
                    '', ; // cFolder
                     Nil, ; // cGroup
                     {STR0027,STR0028}, ; // aComboValues "1=Sim"##"2=Não"
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar

//Exibindo os titulos da tela
oView:AddField( 'VIEW_TFL', oStruTFL, 'MODEL_TFL' )
oView:EnableTitleView( 'VIEW_TFL', STR0005 ) //Local de Atendimento"

oView:AddGrid ( 'VIEW_TGU', oStruTGU, 'MODEL_TGU' )
oView:EnableTitleView( 'VIEW_TGU', STR0006 ) //Apontamento por Valor

oView:AddUserButton(STR0009,"",{|oView| FHist891()}) //"Histórico" 
oView:AddUserButton(STR0031,"", {|oView| At890CpAp( oModel  )}) //"Copiar apontamentos"

//Definindo os espaços de tela
oView:CreateHorizontalBox( 'FIELDSTFL', 30 )
oView:CreateHorizontalBox( 'GRIDTGU', 70 )

oView:SetOwnerView( 'VIEW_TFL', 'FIELDSTFL' )
oView:SetOwnerView( 'VIEW_TGU', 'GRIDTGU' )


Return ( oView ) 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Realiza a inicialização dos valores na carga da tela

@Param
oModel - Model Corrente 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------	
Static Function InitDados( oModel )

Local cDesLoc   := ''
Local cQuery    := ''
Local cSelect   := ''
Local cFrom     := '' 
Local cWhere    := '' 
Local cAliasQry := ''
Local nSaldo    := 0
Local lCntRec   := oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1" .And. (Posicione( "TFJ", 1, xFilial("TFJ") + FWFLDGET("TFL_CODPAI"), "TFJ_GESMAT") <> "5")
Local dDtIni    := FirstDate(dDataBase)
Local dDtFim    := LastDate(dDataBase)

//Grava a descrição do Local de Atendimento para exibição no cabeçalho
cDesLoc := Alltrim( Posicione( "ABS", 1, xFilial("ABS") + FWFLDGET("TFL_LOCAL"), "ABS_DESCRI") )
oModel:LoadValue("MODEL_TFL", "TFL_DESLOC", cDesLoc)

//	Soma os Apontamentos por Valor
cAliasQry := GetNextAlias() 
cQuery    := "SELECT SUM( "
If lCntRec
	cQuery += "  CASE WHEN TGU_DATA BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "' "
	cQuery += "       THEN TGU_QUANT * TGU_VALOR "
	cQuery += "       ELSE 0  END "
Else
	cQuery += "       TGU_QUANT * TGU_VALOR "
Endif
cQuery    += "  ) AS SALDO"
cQuery    += "  FROM " + RetSqlName("TGU")"
cQuery    += " WHERE D_E_L_E_T_ = ' '  "
cQuery    += "   AND TGU_FILIAL = '" + xFilial("TGU")  + "' "
cQuery    += "   AND TGU_CODTFL = '" + TFL->TFL_CODIGO + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
nSaldo := (cAliasQry)->SALDO
(cAliasQry)->(dbCloseArea())

//Busca o valor de materiais de todos os itens de recursos humanos utilizados no local de trabalhoTFF
cSelect := "%SUM( TFF_VLRMAT ) TFF_VLRMAT%"
cFrom   := "%"+RetSqlName("TFF")+"%" 	
cWhere  := "%TFF_LOCAL = '" + TFL->TFL_LOCAL  + "' AND"  
cWhere  += " TFF_CODPAI = '" + TFL->TFL_CODIGO + "'" 
cWhere  += " AND " + RetSqlName("TFF") + ".D_E_L_E_T_ = ''%"
cAliasQry := GetNextAlias() 
BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere% 
EndSql
nSaldo := (cAliasQry)->TFF_VLRMAT - nSaldo
(cAliasQry)->(dbCloseArea())

//Atualiza o campo de Saldo do cabeçalho
oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F891VldGrid
Atualiza o valor do Saldo 

@Param
cCmp - Campo que será validado

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function F891VldGrid( cCmp )

Local nX      := 0
Local cCmp    := cCmp
Local lRet    := .T.
 
Local nTotAtu := 0
Local nSaldo  := 0

Local nPosAtu := 0
Local lCntRec := .F.
Local dDtIni  := FirstDate(dDataBase)
Local dDtFim  := LastDate(dDataBase)

oView 		:= 	FWViewActive()	//Recuperando a view ativa da interface
oModel 		:= 	FWModelActive()	//Recuperando a view ativa da interface

nSaldo := oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' ) //Valor Anterior
lCntRec := oModel:GetValue( 'MODEL_TFL' , 'TFL_CNTREC' ) == "1"

if 'TGU_QUANT' $ cCmp
	If lCntRec
		If oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) >= dDtIni .And. oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) <= dDtFim
			nTotAtu := M->TGU_QUANT * ( oModel:GetValue( 'MODEL_TGU' , 'TGU_VALOR' ) )
		Endif	
	Else
		nTotAtu := M->TGU_QUANT * ( oModel:GetValue( 'MODEL_TGU' , 'TGU_VALOR' ) )		
	Endif

elseif 'TGU_VALOR' $ cCmp
	If lCntRec
		If oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) >= dDtIni .And. oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) <= dDtFim
			nTotAtu := ( oModel:GetValue( 'MODEL_TGU' , 'TGU_QUANT' ) ) * M->TGU_VALOR
		Endif
	Else
		nTotAtu := ( oModel:GetValue( 'MODEL_TGU' , 'TGU_QUANT' ) ) * M->TGU_VALOR	
	Endif
else
	Return ( .T. )	
	
endif 

if nTotAtu <> nSaldo
	nSaldo :=  nTotAtu - nSaldo	
else
	nSaldo := 0
endif

nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) - nSaldo 
if nSaldo >= 0
	//Atualiza o campo de Saldo do cabeçalho
	oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo)
	
else
	Help( ' ', 1, 'TECA891', , STR0007 , 1, 0 ) //Limite de saldo excedido
	lRet := .F.
	
endif
 
Return ( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVld891Dt
Verifica se a data informada esta no período de vigência 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FVld891Dt()

Local lRet := .T.
Local dDtIni  	:= FirstDate(dDataBase)
Local dDtFim  	:= LastDate(dDataBase)
Local oModel 	:= FWModelActive()	//Recuperando a view ativa da interface
Local lCntRec	:= oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1"

if ( M->TGU_DATA > TFL->TFL_DTFIM ) .Or. ( M->TGU_DATA < TFL->TFL_DTINI )
	Help( ' ', 1, 'TECA891', , STR0008, 1, 0 ) //Data fora do período de vigência do local
	lRet := .F.
endif

If lRet .And. lCntRec .And. !(M->TGU_DATA >= dDtIni .And. M->TGU_DATA <= dDtFim)
	Help( ' ', 1, 'TECA891', , STR0029+cValTochar(dDtIni)+STR0030+cValTochar(dDtFim), 1, 0 ) //"Data fora do período de recorrencia "##" a "
	lRet := .F.
Endif

Return ( lRet )                                                                                                                      

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FHist891
Monta tela de Histórico de apontamento de materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function FHist891()

Local cAliasPro	:= "AT891QRY"
Local cRotina  := 'TECA891'
Local cTitulo  := STR0009 //Histórico
Local cQuery   := ''

Local aSize	 	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aFields  := {}

Local oPanel   := Nil
Local oFWLayer := Nil
Local oBrowse  := Nil

oBrowse := FWFormBrowse():New()

aColumns := At891Cols()
cQuery   := At891Query()

DEFINE DIALOG oDlg TITLE STR0009 FROM aSize[1] + 100,aSize[2] + 100 TO aSize[3] - 100, aSize[4] - 100 PIXEL //Histórico
	
// Cria um Form Browse
oBrowse := FWFormBrowse():New()

// Atrela o browse ao Dialog form nao abre sozinho
oBrowse:SetOwner(oDlg)

// Indica que vai utilizar query
oBrowse:SetAlias(cAliasPro)
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQuery)


oBrowse:SetColumns(aColumns)						 
oBrowse:DisableDetails()

oBrowse:AddButton( STR0010 , { || oDlg:End() },,,, .F., 2 ) //Sair	

oBrowse:SetDescription(STR0009)	//Histórico

oBrowse:Activate()

ACTIVATE DIALOG oDlg CENTERED

Return ( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At891Cols
Monta as colunas de exibição da GRID 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At891Cols()

Local nI		:= 0 
Local aArea		:= GetArea()
Local aColumns	:= {}

Local aCampos 	:= { "TGU_DATA", "TGU_PROD", "B1_DESC", "TGU_QUANT", "TGU_VALOR", "TGU_TOTAL", "TGU_APURAC" }
							
DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)

	if aCampos[nI] == 'TGU_TOTAL'

		cCampo := aCampos[nI]
		
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType("N")
	   	aColumns[nLinha]:SetTitle(STR0011) //Total
		aColumns[nLinha]:SetSize(14)
		aColumns[nLinha]:SetDecimal(2)
		aColumns[nLinha]:SetPicture("@E 999,999,999.99" )
		aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))		
				
	else
		If SX3->(dbSeek(aCampos[nI]))
		
			cCampo := AllTrim(SX3->X3_CAMPO)
			
			AAdd(aColumns,FWBrwColumn():New())
			nLinha := Len(aColumns)
		   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
		   	aColumns[nLinha]:SetTitle(X3Titulo())
			aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
			aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
			aColumns[nLinha]:SetPicture(SX3->X3_PICTURE)
			
			If SX3->X3_TIPO == "D"
				aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))		
			Else
				aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))	
			EndIf		
			
		EndIf
	endif
	
Next nI

SX3->(dbCloseArea())

RestArea(aArea)

Return(aColumns)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At891Query
Monta a Query de Exibição na GRID 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At891Query()

cQuery := " SELECT TGU_DATA, TGU_PROD, B1_DESC, TGU_QUANT, TGU_VALOR, ( TGU_QUANT * TGU_VALOR ) TGU_TOTAL, TGU_APURAC "
 
cQuery += " FROM " + RetSqlName("TGU")

cQuery += " INNER JOIN " + RetSqlName("SB1")
cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND"
cQuery += " TGU_PROD = B1_COD "
  
cQuery += " WHERE TGU_APURAC <> ''"
cQuery += " AND TGU_CODTFL = '" + TFL->TFL_CODIGO + "'"
cQuery += " AND "+RetSqlName("TGU")+".D_E_L_E_T_ = ''"
cQuery += " AND "+RetSqlName("SB1")+".D_E_L_E_T_ = ''"

cQuery += " ORDER BY TGU_DATA"

Return ( cQuery )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FDelReg
Realiza o Delete / Undelete da GRID 


@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function FDelReg(oMdlApt, nLine, cAction)
Local lRet		:= .T.
Local oModel 	:= FWModelActive()	//Recuperando a view ativa da interface
Local lCntRec 	:= oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1"
Local dDtIni  	:= FirstDate(dDataBase)
Local dDtFim  	:= LastDate(dDataBase)

If lCntRec .And. !Empty(oMdlApt:GetValue("TGU_DATA")) .And. !(oMdlApt:GetValue("TGU_DATA") >= dDtIni .And. oMdlApt:GetValue("TGU_DATA") <= dDtFim) 
	lRet := .F.		
	If cAction == 'DELETE'	
		Help( ' ', 1, 'FDelReg', , STR0029+cValTochar(dDtIni)+STR0030+cValTochar(dDtFim), 1, 0 ) //"Data fora do período de recorrencia "##" a "
	Endif
Endif

if lRet .And. cAction == 'DELETE'	
	If (Empty(oMdlApt:GetValue("TGU_DATA")) .AND. Empty(oMdlApt:GetValue("TGU_PROD")) .AND. Empty(oMdlApt:GetValue("TGU_QUANT")) .AND. Empty(oMdlApt:GetValue("TGU_VALOR")))		
		TGU->(RollBackSx8())	
	Else
		nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) + oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' )
		oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )
	EndIf
	
elseif lRet .And. cAction == 'UNDELETE'
	nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) - oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' )
	If nSaldo >= 0
		oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )
	Else
		Help( ' ', 1, 'TECA891', , STR0007 , 1, 0 ) //Limite de saldo excedido
		lRet := .F.
	EndIf
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At891Commit()
Commit do Modelo de Dados

@sample		At891Commit(oModel)

@param		ExpO - Modelo de Dados
	
@return		ExpL - Retorna Verdadeiro, caso a Inclusão dos campos foram feitos com sucesso

@author		Serviços
@since		02/02/2017
@version	12  
/*/
//------------------------------------------------------------------
Static Function At891Commit(oModel)
Local lRet 		:= .T.
Local bAfter	:= {|oModel,cID,cAlias| At891After(oModel,cID,cAlias)}

FWModelActive( oModel )
lRet := FWFormCommit( oModel,/*bBefore*/,bAfter,NIL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At891After()
Função para Realizar a Inclusão do Custo

@sample		At891After(oModel,cID,cAlias)

@param		ExpO - Modelo de Dados
			ExpC - ID do Modelo
			ExpC - Alias da Tabela
	
@return		ExpL - Retorna Verdadeiro, caso a Inclusão dos campos foram feitos com sucesso

@author		Serviços
@since		02/02/2017
@version	12  
/*/
//------------------------------------------------------------------
Static Function At891After(oModel,cID,cAlias)
Local lRet 		:= .T.
Local cCodTWZ	:= ""
Local aAlter	:= {}
Local oMdlFull	:= Nil

If ( cId == "MODEL_TGU" .AND. cAlias == "TGU" )
	oMdlFull := FwModelActive()
	Do Case
		Case oModel:IsDeleted()
			If !Empty(oModel:GetValue("TGU_CODTWZ"))
				At995ExcC(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),oModel:GetValue("TGU_CODTWZ"))
			EndIf	
		Case oModel:IsInserted()
			cCodTWZ := At995Custo(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),;
						NIL,oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODIGO"),;
						oModel:GetValue("TGU_PROD"),"5",oModel:GetValue("TGU_TOTAL"),"TECA891")
			If !Empty(cCodTWZ)
				RecLock("TGU", .F.)
					TGU->TGU_CODTWZ := cCodTWZ
				TWZ->(MsUnlock())
			EndIf		
		Case oModel:IsUpdated()
			At995ExcC(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),oModel:GetValue("TGU_CODTWZ"))
			cCodTWZ := At995Custo(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),;
						NIL,oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODIGO"),;
						oModel:GetValue("TGU_PROD"),"5",oModel:GetValue("TGU_TOTAL"),"TECA891")
			If !Empty(cCodTWZ)
				RecLock("TGU", .F.)
					TGU->TGU_CODTWZ := cCodTWZ
				TWZ->(MsUnlock())
			EndIf				
	End Case
EndIf

Return lRet


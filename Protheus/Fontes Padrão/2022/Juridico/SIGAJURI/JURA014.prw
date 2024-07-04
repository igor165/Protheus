#INCLUDE "JURA014.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static nOperacao := 0

//----------------------------------------------------------------------------
/*/{Protheus.doc} JURA014
Configuração Relatório / Tipo de Assunto Jurídico

@author Clovis E. Teixeira dos Santos
@since 12/01/10
@version 1.0
/*/
//----------------------------------------------------------------------------
Function JURA014()
Local oBrowse  

oBrowse := FWMBrowse():New()    
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQY" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL
//----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clovis E. Teixeira dos Santos
@since 12/01/10
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"     , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "JA014Opc(1)" , 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "JA014Opc(3)" , 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "JA014Opc(4)" , 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "JA014Opc(5)" , 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0022, "JA014ExPro"  , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina
//----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Configurações de Relatórios

@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel      := FWLoadModel("JURA014")
Local oStructNQY  := FWFormStruct(2, "NQY")    
Local oStructNVL  := FWFormStruct(2, "NVL")
Local oStrNYO     := FWFormStruct(2, "NYO")
Local oStrNYO2    := FWFormStruct(2, "NYO")
Local nOpc        := nOperacao
Local lCondNYO    := (nOpc <> 3 .And. Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ NQY->NQY_CRPT, "NQR_EXTENS")) == "2") .Or. nOpc == 0 //Condição para exibir grid de variáveis

If !IsInCallStack("JA014Opc") .And. nOpc == 0 .And. !IsInCallStack("JA014ExPro") // Significa que foi chamado a partir de F3
	lCondNYO := .F.
EndIf

oStrNYO:SetProperty( "NYO_NOMVAR" , MVC_VIEW_TITULO, PadR( STR0011, LEN(GetSx3Cache("NYO_NOMVAR","X3_TITULO"))) )
oStrNYO2:SetProperty( "NYO_NOMVAR" , MVC_VIEW_TITULO, PadR( STR0013, LEN(GetSx3Cache("NYO_NOMVAR","X3_TITULO"))) )

oStructNVL:RemoveField("NVL_CODCON")
oStrNYO:RemoveField("NYO_CODCON")
oStrNYO:RemoveField("NYO_FLAG")
oStrNYO2:RemoveField("NYO_CODCON")
oStrNYO2:RemoveField("NYO_FLAG")

oStrNYO:SetProperty(  'NYO_NOMVAR', MVC_VIEW_LOOKUP, 'NYN' )
oStrNYO2:SetProperty( 'NYO_NOMVAR', MVC_VIEW_LOOKUP, 'NYM' )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0007 ) // "Configuração Relatório "

oView:AddField("JURA014_NQY", oStructNQY, "NQYMASTER")   
oView:AddGrid( "JURA014_NVL", oStructNVL, "NVLDETAIL")

If lCondNYO
	oView:AddGrid( "JURA014_NYO", oStrNYO, "NYODETAIL")
	oView:AddGrid( "JURA014_NYO2", oStrNYO2, "NYODETAIL2")
EndIf

oView:CreateHorizontalBox("FORMCONFIG", 40)
oView:CreateHorizontalBox("FORMDETAIL", 60)

oView:CreateFolder("FOLDER_01","FORMDETAIL")
oView:AddSheet("FOLDER_01", "ABA_NVL", STR0012 )//"Tipo de Assunto Jurídico"

If lCondNYO
	oView:AddSheet("FOLDER_01", "ABA_NYO", STR0011 )//"Variáveis"
	oView:AddSheet("FOLDER_01", "ABA_NYO2", STR0013 )//"Textos"
EndIf

oView:CreateHorizontalBox("FORMFOLDERNVL",100,,,'FOLDER_01',"ABA_NVL")

If lCondNYO
	oView:CreateHorizontalBox("FORMFOLDERNYO",100,,,'FOLDER_01',"ABA_NYO")
	oView:CreateHorizontalBox("FORMFOLDERNYO2",100,,,'FOLDER_01',"ABA_NYO2")
EndIf

oView:SetOwnerView("JURA014_NQY", "FORMCONFIG")  
oView:SetOwnerView("JURA014_NVL", "FORMFOLDERNVL")

If lCondNYO
	oView:SetOwnerView("JURA014_NYO", "FORMFOLDERNYO")
	oView:SetOwnerView("JURA014_NYO2", "FORMFOLDERNYO2")
EndIf  

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Configurações de Relatórios
@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
@obs NU2MASTER - Dados das Configurações de Relatórios
/*/
//----------------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNQY  := FWFormStruct(1, "NQY" )    
Local oStructNVL  := FWFormStruct(1, "NVL" )     
Local oStrNYO     := FWFormStruct(1, "NYO" )
Local oStrNYO2    := FWFormStruct(1, "NYO" )
Local nOpc        := nOperacao
Local lCondNYO    := (nOpc <> 3 .And. Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ NQY->NQY_CRPT, "NQR_EXTENS")) == "2") .Or. nOpc == 0 //Condição para exibir grid de variáveis

// Significa que foi chamado a partir de F3 ou pela rotina do WS
If nOpc == 0 ;
	.And. !IsInCallStack("JA014Opc");
	.And. !IsInCallStack("JA014ExPro");
	.And. !IsInCallStack("GravaConfig")
	lCondNYO := .F.	
EndIf

oStructNVL:RemoveField("NVL_CODCON")
oStrNYO:RemoveField("NYO_CODCON")
oStrNYO2:RemoveField("NYO_CODCON")

oStrNYO:SetProperty(  'NYO_NOMVAR', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .OR. (ExistCPO("NYN", M->NYO_NOMVAR) .AND. ExistChav("NYO", FwFldGet("NQY_COD") + M->NYO_NOMVAR, 1))') )
oStrNYO2:SetProperty( 'NYO_NOMVAR', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .OR. (ExistCPO("NYM", M->NYO_NOMVAR) .AND. ExistChav("NYO", FwFldGet("NQY_COD") + M->NYO_NOMVAR, 1))') )

//----------------------------------------------
//Monta o modelo do formulário
//----------------------------------------------
oModel:= MPFormModel():New("JURA014", /*{|oModel| JA014PreVld(oModel)}*//*Pre-Validacao*/, {|oModel| JA014TOK(oModel)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription(STR0008) // "Modelo de Dados de Configuração Relatório / Tipo de Assunto Jurídico"
nOpc  := oModel:GetOperation()

JurSetRules(oModel, "NQYMASTER",, "NQY")

oModel:AddFields("NQYMASTER", NIL, oStructNQY, /*Pre-Validacao*/, /*Pos-Validacao*/ )    
oModel:AddGrid( "NVLDETAIL", "NQYMASTER" /*cOwner*/, oStructNVL, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

If lCondNYO
	oModel:AddGrid( "NYODETAIL" , "NQYMASTER" /*cOwner*/, oStrNYO, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NYODETAIL2", "NQYMASTER" /*cOwner*/, oStrNYO2, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
EndIf

oModel:GetModel("NQYMASTER"):SetDescription(STR0009) // "Dados de Configuração Relatório""  
oModel:GetModel("NVLDETAIL"):SetDescription(STR0012) // "Tipo de Assunto Jurídico"   

If lCondNYO
	oModel:GetModel("NYODETAIL"):SetDescription( STR0011 ) // "Variáveis"
	oModel:GetModel("NYODETAIL2"):SetDescription( STR0013 ) // "Textos"
EndIf

oModel:SetRelation( "NVLDETAIL", { { "NVL_FILIAL", "XFILIAL('NVL')" }, { "NVL_CODCON", "NQY_COD" } }, NVL->( IndexKey( 1 ) ) )  

If lCondNYO 
	oModel:SetRelation( "NYODETAIL", { { "NYO_FILIAL", "XFILIAL('NYO')" }, { "NYO_CODCON", "NQY_COD" } }, NYO->( IndexKey( 1 ) ) )
	oModel:SetOptional( "NYODETAIL" , .T. )
	oModel:SetRelation( "NYODETAIL2", { { "NYO_FILIAL", "XFILIAL('NYO')" }, { "NYO_CODCON", "NQY_COD" } }, NYO->( IndexKey( 1 ) ) )
	oModel:SetOptional( "NYODETAIL2" , .T. )
EndIf

oModel:GetModel( "NVLDETAIL" ):SetUniqueLine({'NVL_CTIPOA'})

If lCondNYO
	oModel:GetModel( "NYODETAIL" ):SetUniqueLine({'NYO_NOMVAR'})
	oModel:GetModel( "NYODETAIL2" ):SetUniqueLine({'NYO_NOMVAR'})
	
	oModel:GetModel( 'NYODETAIL' ):SetLoadFilter( { { 'NYO_FLAG', "'1'" } } )
	oModel:GetModel( 'NYODETAIL2' ):SetLoadFilter( { { 'NYO_FLAG', "'2'" } } )
	EndIf                   

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014Opc
Determinar a acao

@author Jorge Luis Branco Martins Junior
@since 24/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA014Opc( nOpc )
Local lConfirmou := .F.

nOperacao := nOpc

If     nOperacao == 1
	FWExecView( STR0007, 'JURA014', 1,, { || lConfirmou := .T. } ) //"Configurações de Relatórios"
ElseIf nOperacao == 3
	FWExecView( STR0007, 'JURA014', 3,, { || lConfirmou := .T. } ) //"Configurações de Relatórios"
ElseIf nOperacao == 4
	FWExecView( STR0007, 'JURA014', 4,, { || lConfirmou := .F. } ) //"Configurações de Relatórios"
ElseIf nOperacao == 5
	FWExecView( STR0007, 'JURA014', 5,, { || lConfirmou := .T. } ) //"Configurações de Relatórios"		
EndIF

nOperacao := 0

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014TOK
Valida informações ao salvar.
Uso na configuração de relatório

@param 	oModel  	Model a ser verificado

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 27/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA014TOK(oModel)
Local aArea      := GetArea()
Local aAreaNVL   := NVL->(GetArea())
Local aAreaNYO   := NYO->(GetArea())
Local lRet       := .T.
Local nOpc       := oModel:GetOperation()
//Local oModelNVL  := oModel:GetModel('NVLDETAIL')
Local oModelNYO  := oModel:GetModel('NYODETAIL')
Local oModelNYO2 := oModel:GetModel('NYODETAIL2')
Local nI         := 0
//Local nJ         := 0

If nOpc == 4 

	If (Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ M->NQY_CRPT, "NQR_EXTENS")) <> "2")  

		If oModelNYO <>  NIL
			For nI := 1 To oModelNYO:GetQtdLine()
			  If !oModelNYO:IsDeleted(nI) .and. !Empty(oModelNYO:GetValue('NYO_NOMVAR', nI))
					lRet := .F.
					JurMsgErro(STR0014) //"Só é permitido existir variáveis para uma configuração de relatório .DOT"
				EndIf
			Next
		EndIf
		
		If oModelNYO2 <>  NIL
			For nI := 1 To oModelNYO2:GetQtdLine()
			  If !oModelNYO2:IsDeleted(nI) .and. !Empty(oModelNYO2:GetValue('NYO_NOMVAR', nI))
					lRet := .F.
					JurMsgErro(STR0014) //"Só é permitido existir variáveis para uma configuração de relatório .DOT"
				EndIf
	
			Next
		EndIf

	Else

		If oModelNYO <> NIL
			For nI := 1 To oModelNYO:GetQtdLine()
			  oModelNYO:GoLine( nI )
			  If !oModelNYO:IsDeleted(nI) .and. !Empty(oModelNYO:GetValue('NYO_NOMVAR', nI))
					oModelNYO:SetValue('NYO_FLAG', '1')
				EndIf
			Next
		EndIf

		If oModelNYO2 <> NIL
			For nI := 1 To oModelNYO2:GetQtdLine()
				oModelNYO2:GoLine( nI )
			  If !oModelNYO2:IsDeleted(nI) .and. !Empty(oModelNYO2:GetValue('NYO_NOMVAR', nI))
					oModelNYO2:SetValue('NYO_FLAG', '2')
				EndIf
			Next
		EndIf

	EndIf	
EndIf

RestArea( aAreaNYO )
RestArea( aAreaNVL )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014PreVld
Pré-valida informações ao salvar.
Uso na configuração de relatório

@param 	oModel  	Model a ser verificado

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 30/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA014PreVld(oModel)
Local aArea      := GetArea()
Local aAreaNVL   := NVL->(GetArea())
Local aAreaNYO   := NYO->(GetArea())
Local lRet       := .T.
Local nOpc       := oModel:GetOperation()
Local oModelNYO  := oModel:GetModel('NYODETAIL')
Local oModelNYO2 := oModel:GetModel('NYODETAIL2')
Local nI         := 0

If nOpc == 4 .And. (Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ M->NQY_CRPT, "NQR_EXTENS")) == "2")

	If oModelNYO <> NIL
		For nI := 1 To oModelNYO:GetQtdLine()
		  oModelNYO:GoLine( nI )
		  If !oModelNYO:IsDeleted(nI) .and. !Empty(oModelNYO:GetValue('NYO_NOMVAR', nI))
				oModelNYO:SetValue('NYO_FLAG', '1')
			EndIf
		Next
	EndIf
	
	If oModelNYO2 <> NIL
		For nI := 1 To oModelNYO2:GetQtdLine()
			oModelNYO2:GoLine( nI )
		  If !oModelNYO2:IsDeleted(nI) .and. !Empty(oModelNYO2:GetValue('NYO_NOMVAR', nI))
				oModelNYO2:SetValue('NYO_FLAG', '2')
			EndIf
		Next
	EndIf

EndIf

RestArea( aAreaNYO )
RestArea( aAreaNVL )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014CONFG()
Configuração inicial de configuração de relatório

@Return lRet	 	.T./.F. Indica se a configuração foi feita com sucesso.

@author Jorge Luis Branco Martins Junior
@since 19/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA014CONFG()
Local aArea      := GetArea()
Local aAreaNQY   := NQY->( GetArea() )
Local lRet       := .T.
Local lCampo     := .F.
Local oModel     := ModelDef()
Local oModelNVL  
Local oModelNYO  
Local aDados     := {}
Local aJURD001   := { 'ANOATUAL', 'VARACIVEL', 'COMARCA', 'PROCESSONUM', 'NOMEREU', 'TIPOACAO', 'NOMEAUTOR', 'ENDERECOPASSIVO', 'BAIRROPASSIVO', 'CIDADEPASSIVO', 'CEPPASSIVO', 'ESTADOPASSIVO', 'DIAATUAL', 'MESATUAL', 'NOMEADVOGADO', 'OABADVOGADO', 'MUNPROCURACAO' }
Local aJURD002   := { 'BAIRROOUTORGADO', 'BAIRROOUTORGANTE', 'ANOPROCURACAO', 'BAIRROREPLEGAL', 'CEPOUTORGADO', 'CEPOUTORGANTE', 'CEPREPLEGAL', 'CIDADEOUTORGADO', 'CIDADEOUTORGANTE', 'CIDADEREPLEGAL', 'CNPJOUTORGANTE', 'CPFOUTORGADO', 'CPFREPLEGAL', 'DIAPROCURACAO', 'ENDOUTORGADO', 'ENDOUTORGANTE', 'ENDREPLEGAL', 'ESTADOOUTORGADO', 'ESTADOOUTORGANTE', 'ESTADOREPLEGAL', 'ESTCIVILOUTORGADO', 'ESTCIVILREPLEGAL', 'IEOUTORGANTE', 'MESPROCURACAO', 'MUNPROCURACAO', 'NACIOOUTORGADO', 'NACIOREPLEGAL', 'OABOUTORGADO', 'OUTORGADO', 'OUTORGANTE', 'PODERES', 'PROFISSAOOUTORGADO', 'PROFISSAOREPLEGAL', 'REPLEGAL', 'RGREPLEGAL' }
Local aJURD003   := { 'ANOPROCURACAO', 'BAIRROCONTRATADO', 'BAIRROCONTRATANTE', 'BAIRROOUTORGADO', 'CEPCONTRATADO', 'CEPCONTRATANTE', 'CIDADECONTRATADO', 'CIDADECONTRATANTE', 'CNPJCONTRATADO', 'CNPJCONTRATANTE', 'CONDPGCONTRATO', 'CONTRATADO', 'CONTRATANTE', 'DIAPROCURACAO', 'ENDCONTRATADO', 'ENDCONTRATANTE', 'ESTADOCONTRATADO', 'ESTADOCONTRATANTE', 'FIMVIGCONTRATO', 'INDICEMULTACONTRATO', 'INIVIGCONTRATO', 'MESPROCURACAO', 'MULTACONTRATO', 'MULTAEXTCONTRATO', 'MUNPROCURACAO', 'OBJCONTRATO', 'VALORCONTRATO', 'VALOREXTCONTRATO' } 
Local aErro      := {}
Local aAll       := {'001','002','003','004','005','006','007','008','009','010','011'}
Local nI         := 0
Local nT         := 0
Local nErro      := 0
Local cCod001    := ""
Local cCod002    := ""
Local cCod003    := ""
Local cCod076A   := ""
Local cCod076B   := ""
Local cCod095    := ""
Local cCod095M   := ""
Local cCod095S   := ""
Local cCod098    := ""
Local cCod100    := ""
Local cCod124    := ""
Local cCod132    := ""

nOperacao := 0

oModelNVL  := oModel:GetModel( "NVLDETAIL" )
oModelNYO  := oModel:GetModel( "NYODETAIL" )

	If ApMsgYesNo( STR0018 ) //"Serão incluídos novas configurações de relatórios do padrão. Deseja continuar?"

		aDados := {}

		cCod001  := JA014CODRE('JURD001', '2')
		cCod002  := JA014CODRE('JURD002', '2')
		cCod003  := JA014CODRE('JURD003', '2')
		cCod095  := JA014CODRE('JURR095', '3')
		cCod095M := JA014CODRE('JURR095M','3')
		cCod095S := JA014CODRE('JURR095S','3')
		cCod124  := JA014CODRE('JURR124' ,'3')

		If !Empty(Alltrim(cCod001))  .And. !Empty(Alltrim(cCod002))  .And. !Empty(Alltrim(cCod003)) .And. ;
		   !Empty(Alltrim(cCod095)) .And.  !Empty(Alltrim(cCod095M)) .And. !Empty(Alltrim(cCod095S)) .And.; 
		   !Empty(Alltrim(cCod124))  
			
			If !JurTabEmpt('NYB')

				ProcRegua(7)
				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod001)) .AND. !JA014EXVAR(STR0015, cCod001) 
					aAdd( aDados, { STR0015 , AllTrim(cCod001), {'001'}, aJURD001, '2' } )   //"Contestação" 
				EndIf
				
				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod002)) .AND. !JA014EXVAR(STR0016, cCod002) 
					aAdd( aDados, { STR0016 , AllTrim(cCod002), {'007'}, aJURD002, '2' } )	//"Procuração"
				EndIf	
	
				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod003)) .AND. !JA014EXVAR(STR0017, cCod003)
					aAdd( aDados, { STR0017 , AllTrim(cCod003), {'006'}, aJURD003, '2' } )	//"Contrato"
				EndIf

				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod095)) .AND. !JA014EXVAR(STR0027, cCod095) 
					aAdd( aDados, { STR0027 , AllTrim(cCod095), {'001','002','003','004','005','009'}, {}, '2' } )	//"ASSUNTOS JURÍDICOS"             
				EndIf
				
				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod095M)) .AND. !JA014EXVAR(STR0028, cCod095M)
					aAdd( aDados, { STR0028 , AllTrim(cCod095M), {'011'}, {}, '2' } )	//"MARCAS E PATENTES"
				EndIf
				
				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod095S)) .AND. !JA014EXVAR(STR0029, cCod095S) 
					aAdd( aDados, { STR0029 , AllTrim(cCod095S), {'008'}, {}, '2' } )	//"SOCIETÁRIO"
				EndIf	

				IncProc(STR0037)//'Gerando configurações dos relatórios'
				If !Empty(AllTrim(cCod124)) .AND. !JA014EXVAR(STR0032, cCod124) 
					aAdd( aDados, { STR0032 , AllTrim(cCod124), {'008'}, {}, '2' } )	//"CONCESSÕES"
				EndIf	

				IncProc(STR0038)//'Finalizando geração das configurações'
		
				oModel:SetOperation( 3 )
		
				If Len(aDados) > 0
					ProcRegua(Len(aDados))
					For nI := 1 To Len( aDados )
						IncProc(STR0039)//'Confirmando informações'
					  If nErro < 1
						  oModel:Activate()

							If oModel:GetModel("NQYMASTER"):HasField("NQY_CFGJUR")
								lCampo := !oModel:SetValue('NQYMASTER','NQY_CFGJUR',aDados[nI][5])
							EndIf

							If !oModel:SetValue("NQYMASTER",'NQY_DESC',aDados[nI][1]) .Or. !oModel:SetValue("NQYMASTER",'NQY_CRPT',aDados[nI][2]) .Or. lCampo
								lRet := .F.
								nErro++
								JurMsgErro(STR0019)//"Campo não permitido"
								Exit
							EndIf
		
							For nT := 1 To Len(aDados[nI][3])
								If !oModel:SetValue("NVLDETAIL","NVL_CTIPOA",aDados[nI][3][nT])
									lRet := .F.
									nErro++
									JurMsgErro(STR0020)//"Tipo de assunto não permitido"
									Exit
								EndIf
		
								If nT < Len(aDados[nI][3])
									If oModelNVL:AddLine() != (nT + 1)
										lRet := .F.
										nErro++
										JurMsgErro(STR0020)//"Tipo de assunto não permitido"
										Exit
									Endif
								Endif
							Next
		
							If Len(aDados[nI][4]) > 0					
								For nT := 1 To Len(aDados[nI][4])
									If !oModel:SetValue("NYODETAIL","NYO_NOMVAR",aDados[nI][4][nT]) .Or. !oModel:SetValue("NYODETAIL","NYO_FLAG","1")
										lRet := .F.
										nErro++
										JurMsgErro(STR0021)//"É necessário que a Conf. Inicial de Variáveis tenha sido executada. Verifique."
										Exit
									EndIf
			
									If nT < Len(aDados[nI][4])
										If oModelNYO:AddLine() != (nT + 1)
											lRet := .F.
											nErro++
											JurMsgErro(STR0021)//"É necessário que a Conf. Inicial de Variáveis tenha sido executada. Verifique."
											Exit
										EndIf
									EndIf
								Next
							EndIf
		
							If	lRet
								If ( lRet := oModel:VldData() )
									oModel:CommitData()				
									If __lSX8
										ConfirmSX8()
									Else
										RollBackSX8()
									EndIf
								Else
									aErro := oModel:GetErrorMessage()
									JurMsgErro(aErro[6])				
								EndIf
							EndIf
		
						  oModel:DeActivate()
						EndIf
					Next
		
					If Len(aDados) > 0
						ProcRegua(0)
						IncProc(STR0035)//'Aguarde'
					EndIf
		
					If lRet
						ApMsgInfo(STR0024)//"Configuração criada com sucesso"
					EndIf
		
				Else
					ApMsgInfo(STR0023)//"Já existem as configurações do padrão."
				EndIf
				
			Else
				ApMsgInfo(STR0040)//"O cadastro de assuntos jurídicos não foi configurado. Verifique!"
			EndIf

		Else
			ApMsgInfo(STR0034)//"O cadastro de relatórios não foi configurado. Verifique!"
		EndIf

	EndIf

RestArea(aAreaNQY)
RestArea(aArea)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014EXVAR
Valida se a configuração já existe na NQY

@Param cConf  	Configuração que será validada na NQY

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Jorge Luis Branco Martins Junior
@since 19/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA014EXVAR(cConf, cCrpt)
Local lRet := .F.
Local aArea    := GetArea()
Local aAreaNQY := NQY->( GetArea() )

dbSelectArea('NQY')
dbSetOrder(2)

If dbSeek(xFilial('NQY') + cConf)
	If NQY->NQY_CRPT == cCrpt
		lRet := .T.
	EndIf
Endif

RestArea(aAreaNQY)
RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014CODRE
Retorna código do relatório (DOT) que contém a descrição indicada no 
parâmetro

@Param cDesc  Descrição
@Param cExt   Extensão

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Jorge Luis Branco Martins Junior
@since 19/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA014CODRE(cDesc, cExt)
Local aArea    := GetArea()
Local aAreaNQR := NQR->( GetArea() )
Local cQuery   := ""
Local cRet     := ""
Local cAlias

	cQuery := " SELECT NQR_COD CODIGO"
	cQuery +=     " FROM "+RetSqlName("NQR")+" NQR"
	cQuery +=   " WHERE NQR_FILIAL = '" + xFilial( "NQR" ) + "'"
	cQuery +=     " AND NQR_NOMRPT = '" + cDesc + "' "
	cQuery +=     " AND NQR_EXTENS = '" + cExt + "' "
	cQuery +=     " AND NQR.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	While !(cAlias)->( EOF() )
		cRet := (cAlias)->CODIGO
		(cAlias)->(DbSkip())
	End

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNQR)
RestArea(aArea)
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA014ExPro()
Rotina que faz a chamada do processamento da carga inicial

@author Jorge Luis Branco Martins Junior
@since 04/04/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA014ExPro()
	Processa( {|| JA014CONFG() } , STR0035, STR0036, .F. ) // 'Aguarde', 'Gerando...'
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J014WHENCF()
Habilita campo que indica se a configuração do relatório usa 
os campos indicados na configuração do assunto jurídico

@author Wellington Coelho
@since 15/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J014WHENCF()
Local lRet      := .T.
Local cTipoRel  := JurGetDados("NQR", 1, xFilial("NQR") + M->NQY_CRPT, "NQR_EXTENS") 

If cTipoRel == '3'
	lRet := .F.
EndIf

Return lRet

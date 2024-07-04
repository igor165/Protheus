#INCLUDE "JURA037.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA037
Classif. Tipo de Honorários. 

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA037()
Local oBrowse

Private lBloqueia501 := .F. 

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRA" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
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

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA037", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA037", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA037", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA037", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA037", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0070, "JA037CARGA()"   , 0, 3, 0, NIL } ) // "Carga. Inicial"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Classif. Tipo de Honorários

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA037" )
Local oStruct    := FWFormStruct( 2, "NRA" )
Local oStructNTH := FWFormStruct( 2, "NTH" )

oStructNTH:RemoveField( "NTH_CTPHON" )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA037_VIEW", oStruct, "NRAMASTER"  )
oView:AddGrid(  "JURA037_GRID", oStructNTH, "NTHDETAIL"  )

oView:AddUserButton( STR0014, 'AVGLBPAR1', { | oView | JURA37COP( oView ) } ) // "Copiar"

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "GRID"     , 80 )
oView:SetOwnerView( "JURA037_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA037_GRID", "GRID"      )

oView:SetDescription( STR0007 ) // "Classif. Tipo de Honorários"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Classif. Tipo de Honorários

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0

@obs NRAMASTER - Dados do Classif. Tipo de Honorários
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oModelNTH  := NIL
Local oStruct    := FWFormStruct( 1, "NRA" )
Local oStructNTH := FWFormStruct( 1, "NTH" )
Local oCommit    := JA037COMMIT():New()

oModel:= MPFormModel():New( "JURA037", /*Pre-Validacao*/, {|oX| JURA037OK(oX)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRAMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )  
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Classif. Tipo de Honorários"
oModel:GetModel( "NRAMASTER" ):SetDescription( STR0009 ) // "Dados de Classif. Tipo de Honorários"
oModel:AddGrid( "NTHDETAIL", "NRAMASTER" /*cOwner*/, oStructNTH, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NTHDETAIL" ):SetUniqueLine( { "NTH_CAMPO","NTH_CTPHON" } )
oModel:SetRelation( "NTHDETAIL", { { "NTH_FILIAL", "XFILIAL('NTH')" }, { "NTH_CTPHON", "NRA_COD" } }, NTH->( IndexKey( 1 ) ) )
oModel:GetModel( "NTHDETAIL" ):SetDescription( STR0010 ) //"Campos das Condições de Faturamento"

JurSetRules( oModel, 'NRAMASTER', 'NRA' )
JurSetRules( oModel, 'NTHDETAIL', 'NTH' )

oModelNTH := oModel:GetModel('NTHDETAIL')
oModelNTH:SetMaxLine( 9999 )

oModel:InstallEvent("JA037COMMIT", /*cOwner*/, oCommit)

If Val(NRA->NRA_COD) < 501 // Para códigos de tipo de honorário < 501, apenas o campo 'Ativo' s/n pode ser alterado. Apenas a carga inicial pode alterar estes dados.
	lBloqueia501 := .T. 
	oStruct:SetProperty( 'NRA_DESC'  , MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_COBRAH', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_COBRAF', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_NCOBRA', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_ATIVO' , MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_PARCAT', MODEL_FIELD_NOUPD, .T. )

	oStructNTH:SetProperty( 'NTH_CAMPO' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESCPO', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESTIP', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_VISIV' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_OBRIGA', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_VLPAD' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_BOTAO' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESCBX', MODEL_FIELD_NOUPD, .T. )
Else
	lBloqueia501 := .F.   
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA037OK
Valida informações ao salvar.

@param 	oFormField  	FormField a ser verificado	
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Fabio Crespo Arruda
@since 07/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA037OK(oModel)
Local lRet      := .T.
Local nDeleted  := 0
Local nI        := 0
Local nY        := 0
Local oModelNTH := oModel:GetModel("NTHDETAIL")
Local nQtdNTH   := oModelNTH:GetQtdLine()
Local cFalta    := ''
Local lExiste   := .F.
Local aCampos   := {}
Local aCPOUser  := {}
Local nQtdCpo   := 0
Local lCarga    := IsInCallStack('JA037CARGA')
Local aCpoObr   := J037Campos()

For nI := 1 to Len(aCpoObr)
	If X3USADO(aCpoObr[nI])
		Aadd(aCampos, aCpoObr[nI])
	EndIf
Next

If ExistBlock( 'JA037CPO' )
	aCPOUser := Execblock('JA037CPO', .F., .F.)
	If Valtype( aCPOUser ) == 'A'
		aEval( aCPOUser, { |x| IF( aScan(aCampos, Alltrim(x) ) > 0 , aAdd( aCampos, x  ), ) } )
	EndIf
EndIf
	
nQtdCpo := LEN(aCampos)
	
lRet := JURA037VH(oModel)
	
If lRet .And. (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4)
	
	For nI := 1 To LEN(aCampos)
			
		For nY := 1 To nQtdNTH
			If !oModelNTH:IsDeleted(nY)
				If AllTrim(oModelNTH:GetValue("NTH_CAMPO", nY)) == AllTrim(aCampos[nI])
					lExiste := .T.
					If lCarga
						Exit
					EndIf
				EndIf
			Else
				nDeleted++
			EndIf
		Next nY
		  
		If !lExiste
			cFalta += IIF(Empty(cFalta), aCampos[nI], ', '+aCampos[nI])
			lRet   := .F.
		EndIf
		lExiste := .F.

	Next nI
	
	If !lRet
		JurMsgErro(STR0032 +cFalta+ STR0033) // "Os campos obrigatóros(" + cFalta + ") não estão cadastrados!"
	EndIf
	
	Do Case
		Case nQtdNTH-nDeleted > nQtdCpo .And. lRet .And. !lCarga
			JurMsgErro(STR0035) // "Existem campos configurados a mais do que os obrigatórios."
			lRet := .F.

		Case nQtdNTH-nDeleted < nQtdCpo .And. lRet .And. !lCarga
			JurMsgErro(STR0034) // "Todos os campos obrigatórios do contrato devem estar configurados."
			lRet := .F.
	EndCase
	  
EndIf

If lRet
	lRet := JA037POSVAL(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA037VH
Valida os Dados de NRA

@param 	oFormField  	FormField a ser verificado	
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample oModel:AddFields( "NRAMASTER", NIL, oStruct, {|oX| JURA037TOK(oX)})

@author Felipe Bonvicini Conti
@since 08/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA037VH(oModel)
Local lRet       := .T.
Local oFormField := oModel:GetModel("NRAMASTER")  
Local cCOBRAH    := oFormField:GetValue("NRA_COBRAH")
Local cCOBRAF    := oFormField:GetValue("NRA_COBRAF")
Local cNCOBRA    := oFormField:GetValue("NRA_NCOBRA")

If (cNCOBRA == '1') .And. ( (cCOBRAH == '1') .Or. (cCOBRAF == '1') )
	JurMsgErro(STR0013)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR037VC
Validacao dos campos

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR037VC( cCampo )
Local lRet := .T.

cCampo := Alltrim(cCampo)

If cCampo == 'NTH_CAMPO'
	lRet := ( SubStr( FwFldGet( 'NTH_CAMPO' ), 1, 3) == 'NT0' )
	If !(lRet)
		JurMsgErro( STR0011 ) // "Só são permitidos campos da tabela de Contratos de Faturamento (NT0)"
	EndIf
	
ElseIf cCampo == 'NTH_OBRIGA'
	lRet := !( FwFldGet( 'NTH_OBRIGA' ) == '1' .AND. Posicione( 'SX3', 2, FwFldGet( 'NTH_CAMPO' ), 'X3_CONTEXT' ) == 'V' )
	If !(lRet)
		JurMsgErro( STR0012 ) // "Campos virtuais não podem ser obrigatórios"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA37COP
Copia os campos para outro tipo

@author Fabio Crespo Arruda
@since 08/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA37COP( oView )
Local lRet      := .T.
Local oModel    := FwModelActive()
Local aArea     := GetArea()
Local aAreaNRA  := NRA->( GetArea() )
Local aAreaNTH  := NTH->( GetArea() )
Local cGetDe    := CriaVar( 'NTH_CTPHON', .T. )
Local cGetPara  := CriaVar( 'NTH_CTPHON', .T. )
Local nTam      := CalcFieldSize( 'C', TamSX3( 'NTH_CTPHON' )[1] )
Local oModelNRA := oView:GetModel("NRAMASTER")
Local oModelNTH := oView:GetModel("NTHDETAIL")
Local cCOBRAF   := ""
Local cNCOBRA   := ""
Local cATIVO    := ""
Local cPARCAT   := ""
Local cCOBRAH   := ""   
Local oDlg      := Nil
Local oGetDe    := Nil 

cGetPara := oModelNRA:GetValue('NRA_COD')
Define MsDialog oDlg Title STR0014 From 404, 284 To 490, 420 Pixel // "Copiar"

@ 008, 005 Say STR0023  Size 035, 008  Pixel Of oDlg // "De Tipo"
@ 007, 040 MsGet oGetDe Var cGetDe Size nTam, 009 F3 'NRA' Valid ExistCpo( 'NRA', cGetDe, 1 ) Pixel Of oDlg HasButton
oGetDe:bF3 := {|| JbF3LookUp('NRA', oGetDe, @cGetDe) }

Define SButton From 028, 005 Type 1 Enable Of oDlg Action ( lRet := .T., oDlg:End() )
Define SButton From 028, 035 Type 2 Enable Of oDlg Action ( lRet := .F., oDlg:End() )

oDlg:lEscClose := .F.

Activate MsDialog oDlg Centered

If !lRet
	Return .F.
EndIf

cCOBRAF   := GetAdvFVal( "NRA", "NRA_COBRAF", XFILIAL("NRA") + cGetDe ) 
cNCOBRA   := GetAdvFVal( "NRA", "NRA_NCOBRA", XFILIAL("NRA") + cGetDe ) 
cATIVO    := GetAdvFVal( "NRA", "NRA_ATIVO" , XFILIAL("NRA") + cGetDe )
cPARCAT   := GetAdvFVal( "NRA", "NRA_PARCAT", XFILIAL("NRA") + cGetDe ) 
cCOBRAH   := GetAdvFVal( "NRA", "NRA_COBRAH", XFILIAL("NRA") + cGetDe ) 

NTH->( dbSetOrder ( 1 ) )

If cGetDe == cGetPara
	JurMsgErro( STR0016 ) // "Tipo de origem e destino são iguais."
	Return NIL
EndIf

If !NTH->( dbSeek( xFilial( 'NTH' ) + cGetDe   )  )
	JurMsgErro( STR0017 ) // "Configuração do tipo informado na origem não cadastrado."
	lRet := .F.
EndIf

If oModelNTH:GetQtdLine() > 1
 
	If ApMsgYesNo( STR0018, STR0019 ) // "Já existe configuração para o tipo de destino informado. As configurações do destino serão perdidas. Continuar ?"###"ATENÇÃO"

		oModelNTH:GoLine(1)
		while oModelNTH:nLine <= oModelNTH:GetQtdLine()
		  oModelNTH:DeleteLine()
		  oModelNTH:nLine += 1
		End
		oModelNTH:GoLine(oModelNTH:GetQtdLine())
		oModelNTH:AddLine()
		
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. ApMsgYesNo( STR0020, STR0019 ) // "Confirma a cópia da configuração ?"###"ATENÇÃO"
	
	oModel:SetValue('NRAMASTER','NRA_COBRAF',cCOBRAF)
	oModel:SetValue('NRAMASTER','NRA_NCOBRA',cNCOBRA)
	oModel:SetValue('NRAMASTER','NRA_ATIVO' ,cATIVO)
	oModel:SetValue('NRAMASTER','NRA_PARCAT',cPARCAT) 
	oModel:SetValue('NRAMASTER','NRA_COBRAH',cCOBRAH)
	
	MsgRun( STR0021+STR0025, STR0014, { || JUR037CPAX( cGetDe, cGetPara, oModelNTH ), oView:Refresh() } ) // "Aguarde... Copiando..."###"Copiar"
EndIf

RestArea( aAreaNTH )
RestArea( aAreaNRA )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR037CPAX
Rotina auxiliar para copiar configurações

@author Ernani Forastieri
@since 08/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR037CPAX(cDe, cPara, oModelNTH)
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )
Local nI        := 0
Local nCt       := 0
Local lRet      := .T.   
Local aCampos   := oModelNTH:GetStruct():GetFields()         
Local xValor    := Nil
Local cCampo    := ""

NTH->( dbSetOrder (1) )
NTH->( dbSeek( xFilial('NTH') + cDe )  )

While !NTH->( EOF() ) .AND. NTH->( NTH_FILIAL + NTH_CTPHON ) == xFilial( 'NTH' ) + cDe
	nCt++
	
	cCampo := NTH->( FieldGet( FieldPos( "NTH_CAMPO" ) ) )
	
	If X3USADO(cCampo)
		If nCt >  1 
			oModelNTH:AddLine()
		EndIf
		
		For nI := 1 To Len( aCampos )
			cCampo :=aCampos[nI][MODEL_FIELD_IDFIELD]
			xValor := NTH->( FieldGet( FieldPos( cCampo ) ) )
			If !Empty(xValor) .And. xValor <> NIL
				If  !oModelNTH:SetValue( cCampo , xValor )
					lRet := .F.
					JurMsgErro( STR0031 + cCampo ) // "Erro ao preencher o valor do campo: "
					Exit
				EndIf
			EndIf
		Next
		
		If nCt == 1
			oModelNTH:SetValue("NTH_DESTIP", oModelNTH:InitValue("NTH_DESTIP"))
			oModelNTH:SetValue("NTH_DESCBX", oModelNTH:InitValue("NTH_DESCBX"))
		EndIf
	EndIf
	
	NTH->( dbSkip() )
EndDo

oModelNTH:GoLine( 1 )

RestArea( aAreaNTH )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA037CARGA
Realiza a carga inicial da configuração dos tipos padrão de honorários

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/03/10
@version 1.0
/*/                                                               
//------------------------------------------------------------------- 
Function JA037CARGA()
Local lRet      := .T. 

Processa( { || lRet := J037CgInit() }, STR0021, STR0070, .F. ) // "Aguarde... "###"Carga. Inicial"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GETCODTPHONORARIO()
Retorna o primeiro código de tipo de honorário disponível e       
customizável, ou seja, apartir da numeração 501 onde os próprios
usuários podem criar seus tipos de honorários. 

@Return cRet	 Novo código de tipo de honorário disponível.

@author Julio de Paula Paz
@since 17/03/2014
@version 1.0
/*/                                                               
//------------------------------------------------------------------- 
Function GETCODTPHONORARIO()
Local cRet := "501"
Local cCod := "501"
Local aOrd := SaveOrd({"NRA"})
Local nCod := 501

Begin Sequence
	NRA->(DbSetOrder(1))
	cCod := GETSXENUM("NRA", "NRA_COD")

	Do While .T.
		If nCod > 999
			JurMsgErro(STR0075 + Alltrim(Str(nCod,4)) + STR0076 ) //  "A numeração do código do tipo de honorário [" ### "] ultrapassa o tamanho do campo. Entre em contado com a administrador do sistema." 
			cRet := Space(3)
			Break
		EndIf
		If NRA->(DbSeek(xFilial("NRA") + StrZero(nCod, 3)))
			nCod += 1
			Loop     
		EndIf

		If Val(AllTrim(cCod)) < nCod
			cCod := GETSXENUM("NRA", "NRA_COD")
			Loop
		Else
			Exit
		EndIf
	EndDo
	cRet := StrZero(nCod,3)

End Sequence

Restord(aOrd, .T.)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA037POSVAL(oModel)
No caso de alteração ou exclusão, não permite manuteção se o tipo de honorário for
padrão, de 001 a 500.

@Return .T. / .F. - True = Manutenção permitida. False = Alteração/Exclusão não permitida.

@author Julio de Paula Paz
@since 18/03/2014
@version 1.0
/*/                                                               
//------------------------------------------------------------------- 
Function JA037POSVAL(oModel) 
Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local oModelNRA  := oModel:GetModel('NRAMASTER')

Begin Sequence
	If nOperation == MODEL_OPERATION_DELETE
		If Val(oModelNRA:GetValue('NRA_COD')) < 501
			JurMsgErro(STR0073) // "Este tipo de honorário é padrão. Não é permitido excluí-lo. Qualquer manutenção deve ser realizada através da rotina de carga inicial."
			lRet := .F.
		EndIf
	EndIf
End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J037CgInit
Realiza a carga inicial da configuração dos tipos padrão de honorários

@Param  lMigrador, Se .T. a excução é chamada pelo Migrador
@Param  oProcess , Objeto de processamento do migrador
@Param  lAutomato, Se .T. a excução é chamada pela Automação

@Return lRet .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/03/10
@version 1.0
/*/                                                               
//------------------------------------------------------------------- 
Function J037CgInit(lMigrador, oProcess, lAutomato)
Local lRet       := .T.    
Local aArea      := GetArea()
Local oModel     := FWLoadModel("JURA037")
Local aNTH       := {}
Local aDados     := {} 
Local aDadosNTH  := JA037NTH()
Local nI         := 1
Local nY         := 1
Local oModelNTH  := Nil
Local lIncluNRA  := .F.  
Local nLinha     := 0
Local nJ         := 0
Local lIncluiNTH := .F.  
Local oStruct    := oModel:GetModel( 'NRAMASTER' ):GetStruct()  
Local oStructNTH := oModel:GetModel( 'NTHDETAIL' ):GetStruct() 

Default lMigrador := .F. // Indica se a execução é via migrador
Default oProcess  := Nil
Default lAutomato := .F. // Indica se a execução é via automação

If !lMigrador .And. !lAutomato
	If !ApMsgYesNo(STR0074) // "Confirma a execução da rotina de carga inicial?"  
		Return .F.
	EndIf
EndIf

If lBloqueia501  // Para códigos de tipo de honorário < 501, apenas o campo 'Ativo' s/n pode ser alterado. Apenas a carga inicial pode alterar estes dados.
	oStruct:SetProperty( 'NRA_DESC'  , MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_COBRAH', MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_COBRAF', MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_NCOBRA', MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_ATIVO' , MODEL_FIELD_NOUPD, .F. )
	oStruct:SetProperty( 'NRA_PARCAT', MODEL_FIELD_NOUPD, .F. )

	oStructNTH:SetProperty( 'NTH_CAMPO' , MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_DESCPO', MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_DESTIP', MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_VISIV' , MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_OBRIGA', MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_VLPAD' , MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_BOTAO' , MODEL_FIELD_NOUPD, .F. )
	oStructNTH:SetProperty( 'NTH_DESCBX', MODEL_FIELD_NOUPD, .F. )
EndIf   

dbSelectArea( 'NRA' )
	
// Quando existirem dados, a rotina deve realizar apenas aterações, com exceção do campo NRA_ATIVO. 	
aDados := {}
//              'Código','Tipo Honorario','Descrição','Cobrar Hora?','Cobrar Fixo?','Não Cobrar?','Ativo?','Parc Automat?','Dados NTH'
aAdd( aDados, { '001'   ,' '             ,STR0036    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[1]}) // 'Hora'
aAdd( aDados, { '002'   ,' '             ,STR0037    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[2]}) // 'Hora - Limite Geral'
aAdd( aDados, { '003'   ,' '             ,STR0038    ,'2'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[3]}) // 'Fixo - Partido'
aAdd( aDados, { '004'   ,' '             ,STR0039    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[4]}) // 'Hora - Limite por Fatura'
aAdd( aDados, { '005'   ,' '             ,STR0040    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[5]}) // 'Fixo - Parc. Pre-Definido' 
aAdd( aDados, { '006'   ,' '             ,STR0041    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[6]}) // 'Fixo - Parc. Ocorrência'
aAdd( aDados, { '007'   ,' '             ,STR0042    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[7]}) // 'Fixo e Hora - Misto'
aAdd( aDados, { '008'   ,' '             ,STR0043    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[8]}) // 'Fixo e Hora - Valor mínimo'
aAdd( aDados, { '009'   ,' '             ,STR0044    ,'2'           ,'2'           ,'1'          ,'1'     ,'2'            ,aDadosNTH[9]}) // 'Não cobrar' 
aAdd( aDados, { '010'   ,' '             ,STR0045    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[10]}) // 'Fixo - Final de Contrato'
aAdd( aDados, { '011'   ,' '             ,STR0046    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[11]}) // 'Hora e Fixo (Partido)'
aAdd( aDados, { '012'   ,' '             ,STR0047    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[12]}) // 'Hora - Limite geral e por Fatura'
aAdd( aDados, { '013'   ,' '             ,STR0048    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[13]}) // 'Hora e Fixo (Pré-Definido)' 
aAdd( aDados, { '014'   ,' '             ,STR0049    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[14]}) // 'Hora e Fixo (Ocorrência)' 
aAdd( aDados, { '015'   ,' '             ,STR0050    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[15]}) // 'Hora (Limite por Fatura) e Fixo (Partido)'
aAdd( aDados, { '016'   ,' '             ,STR0051    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[16]}) // 'Hora (Limite por Fatura) e Fixo (Pré-Definido)'  
aAdd( aDados, { '017'   ,' '             ,STR0052    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[17]}) // 'Hora (Limite de Fatura) e Fixo (Ocorrência)' 
aAdd( aDados, { '018'   ,' '             ,STR0053    ,'2'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[18]}) // 'Fixo (Partido) com Faixa e Valor (Quantidade de Casos/Processos)' 
aAdd( aDados, { '019'   ,' '             ,STR0054    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[19]}) // 'Hora com Faixa de Valor'
aAdd( aDados, { '020'   ,' '             ,STR0055    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[20]}) // 'Hora (Limite por Fatura) com Faixa de Valor'
aAdd( aDados, { '021'   ,' '             ,STR0056    ,'2'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[21]}) // 'Fixo (Partido) com Limite geral'
aAdd( aDados, { '022'   ,' '             ,STR0057    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[22]}) // 'Fixo (Pre-Definido) com Limite geral'
aAdd( aDados, { '023'   ,' '             ,STR0058    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[23]}) // 'Fixo (Ocorrência) com Limite geral' 
aAdd( aDados, { '024'   ,' '             ,STR0059    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[24]}) // 'Fixo e Hora (Misto) com Limite geral' 
aAdd( aDados, { '025'   ,' '             ,STR0060    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[25]}) // 'Fixo e Hora (Valor Mínimo) com Limite geral'
aAdd( aDados, { '026'   ,' '             ,STR0061    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[26]}) // 'Hora e Fixo (Partido) com Limite geral'
aAdd( aDados, { '027'   ,' '             ,STR0062    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[27]}) // 'Hora e Fixo (Pre-Definido) com limite geral'
aAdd( aDados, { '028'   ,' '             ,STR0063    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[28]}) // 'Hora e Fixo (Ocorrência) com Limite geral'
aAdd( aDados, { '029'   ,' '             ,STR0064    ,'1'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[29]}) // 'Hora (Limite por Fatura) e Fixo (Partido) com Limite geral'
aAdd( aDados, { '030'   ,' '             ,STR0065    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[30]}) // 'Hora (Limite por Fatura) e Fixo (Pré-Definido) com limite geral'
aAdd( aDados, { '031'   ,' '             ,STR0066    ,'1'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[31]}) // 'Hora (Limite por Fatura) e Fixo (Ocorrência) com limite geral'
aAdd( aDados, { '032'   ,' '             ,STR0067    ,'2'           ,'1'           ,'2'          ,'1'     ,'1'            ,aDadosNTH[32]}) // 'Fixo (Partido) com Faixa de Valor (Quant. Casos/Processos) e Limite Geral'
aAdd( aDados, { '033'   ,' '             ,STR0068    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[33]}) // 'Hora com Faixa de Valor e Limite Geral'
aAdd( aDados, { '034'   ,' '             ,STR0069    ,'1'           ,'2'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[34]}) // 'Hora (Limite por Fatura) com Faixa de Valor e Limite geral'
aAdd( aDados, { '035'   ,' '             ,STR0071    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[35]}) // 'Fixo (Pré-Definido) com Faixa de Valor (Quantidade de Casos/Processos)'
aAdd( aDados, { '036'   ,' '             ,STR0072    ,'2'           ,'1'           ,'2'          ,'1'     ,'2'            ,aDadosNTH[36]}) // 'Fixo (Ocorrência) com Faixa de Valor (Quantidade de Casos/Processos)'

NRA->(DbSetOrder(1)) 

If !lAutomato
	If lMigrador
		oProcess:SetRegua2(Len( aDados ))
	Else
		ProcRegua(Len( aDados ))
	EndIf
EndIf

For nI := 1 To Len( aDados )
	If !lAutomato
		If lMigrador
			oProcess:IncRegua2(i18n("Importando registro #1 de #2",{nI, Len(aDados)}))
		Else
			IncProc(STR0077 + aDados[nI][3]) //"Configurando tipo: " 
		EndIf
	EndIf
		
	If NRA->(DbSeek(xFilial("NRA") + aDados[nI, 1]))
		oModel:SetOperation( 4 ) // Operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
		lIncluNRA := .F. 
	Else
		oModel:SetOperation( 3 ) // Operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
		lIncluNRA := .T.
	EndIf	

	oModel:Activate() // Ativa o Model para cada iteração do loop.	

	If  !oModel:SetValue("NRAMASTER", 'NRA_COD', aDados[nI][1]) .Or. !oModel:SetValue("NRAMASTER", 'NRA_SIGLA', aDados[nI][2]) .Or.;
		!oModel:SetValue("NRAMASTER", 'NRA_DESC', aDados[nI][3]) .Or. !oModel:SetValue("NRAMASTER", 'NRA_COBRAH', aDados[nI][4]) .Or.;
		!oModel:SetValue("NRAMASTER", 'NRA_COBRAF', aDados[nI][5]) .Or. !oModel:SetValue("NRAMASTER", 'NRA_NCOBRA', aDados[nI][6]) .Or.;
		!oModel:SetValue("NRAMASTER", 'NRA_PARCAT', aDados[nI][8])
		lRet := .F.
		JurMsgErro( STR0012 ) // "Campos virtuais não podem ser obrigatórios"
		Exit
	EndIf	
		
	If lIncluNRA  // O campo NRA_ATIVO não pode ser alterado. 
		If !oModel:SetValue("NRAMASTER", 'NRA_ATIVO', aDados[nI][7]) 
			lRet := .F.
			JurMsgErro( STR0012 ) // "Campos virtuais não podem ser obrigatórios"
			Exit
		EndIf
	EndIf 

	If lRet
		oModelNTH := oModel:GetModel('NTHDETAIL')
		aNTH := aDados[nI][9]

		For nY := 1 To Len(aNTH)
			If ! lIncluNRA 
				lIncluiNTH := .T.  
				nLinha := oModelNTH:GetLine()
				For nJ := 1 To oModelNTH:Length()
					oModelNTH:GoLine(nJ)
					If AllTrim(oModelNTH:GetValue('NTH_CTPHON')) == AllTrim(aNTH[nY][1]) .And. ;
						AllTrim(oModelNTH:GetValue('NTH_CAMPO ')) == AllTrim(aNTH[nY][2])
						lIncluiNTH := .F.
						Exit
					EndIf
				Next
					
				If lIncluiNTH 
					If oModelNTH:AddLine() <> nY
						lRet := .F.
						JurMsgErro()
						Exit
					EndIf
				EndIf
			Else
				If oModelNTH:AddLine() <> nY
					lRet := .F.
					JurMsgErro()
					Exit
				EndIf
			EndIf
				
			If !oModel:LoadValue("NTHDETAIL", 'NTH_CTPHON', aNTH[nY][1]) .Or. !oModel:SetValue("NTHDETAIL", 'NTH_CAMPO', aNTH[nY][2]) .Or.;
			   !oModel:SetValue("NTHDETAIL", 'NTH_VISIV', aNTH[nY][3]) .Or. !oModel:SetValue("NTHDETAIL", 'NTH_OBRIGA', aNTH[nY][4]) .Or.;
			   !oModel:SetValue("NTHDETAIL", 'NTH_VLPAD', aNTH[nY][5]) .Or. !oModel:SetValue("NTHDETAIL", 'NTH_BOTAO', Val(aNTH[nY][6]))
			   lRet := .F.
			   JurMsgErro()
			   Exit
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			oModel:CommitData()
			If __lSX8
				ConfirmSX8()
			EndIf
		Else
			aErro := oModel:GetErrorMessage()
			JurMsgErro(aErro[6])
		EndIf
	EndIf
	oModel:DeActivate()
Next

RestArea(aArea)

If lBloqueia501 // Para códigos de tipo de honorário < 501, apenas o campo 'Ativo' s/n pode ser alterado. Apenas a carga inicial pode alterar estes dados.
	oStruct:SetProperty( 'NRA_DESC'  , MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_COBRAH', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_COBRAF', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_NCOBRA', MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_ATIVO' , MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NRA_PARCAT', MODEL_FIELD_NOUPD, .T. )

	oStructNTH:SetProperty( 'NTH_CAMPO' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESCPO', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESTIP', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_VISIV' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_OBRIGA', MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_VLPAD' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_BOTAO' , MODEL_FIELD_NOUPD, .T. )
	oStructNTH:SetProperty( 'NTH_DESCBX', MODEL_FIELD_NOUPD, .T. )
EndIf   

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA037NTH
Efetua a carga do cadastro da NTH.

@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 05/03/10
@version 1.0
/*/                                                               
//------------------------------------------------------------------- 
Static Function JA037NTH()
Local aDados := {}
Local aCod   := {}

aAdd( aDados, { '001','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '001','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '001','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '001','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '001','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '001','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '001','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '001','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '001','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '001','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '001','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '001','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '001','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '001','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '001','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '001','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '001','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '001','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '001','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '001','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '001','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '001','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '001','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '001','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '001','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '001','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '001','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '001','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '001','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '001','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '001','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '001','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '001','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '001','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '001','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '001','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '001','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '001','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '001','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '002','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '002','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '002','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '002','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '002','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '002','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '002','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '002','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '002','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '002','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '002','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '002','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '002','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '002','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '002','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '002','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '002','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '002','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '002','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '002','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '002','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '002','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '002','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '002','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '002','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '002','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '002','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '002','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '002','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '002','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '002','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '002','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '002','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '002','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '002','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '002','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '002','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '002','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '002','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '003','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '003','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '003','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '003','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '003','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '003','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '003','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '003','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '003','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '003','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '003','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '003','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '003','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '003','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '003','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '003','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '003','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '003','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '003','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '003','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '003','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '003','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '003','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '003','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '003','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '003','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '003','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '003','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '003','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '003','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '003','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '003','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '003','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '003','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '003','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '003','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '003','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '003','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '003','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '004','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '004','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '004','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '004','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '004','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '004','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '004','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '004','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '004','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '004','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '004','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '004','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '004','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '004','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '004','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '004','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '004','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '004','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '004','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '004','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '004','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '004','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '004','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '004','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '004','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '004','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '004','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '004','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '004','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '004','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '004','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '004','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '004','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '004','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '004','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '004','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '004','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '004','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '004','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '005','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '005','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '005','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '005','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '005','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '005','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '005','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '005','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '005','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '005','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '005','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '005','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '005','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '005','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '005','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '005','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '005','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '005','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '005','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '005','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '005','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '005','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '005','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '005','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '005','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '005','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '005','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '005','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '005','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '005','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '005','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '005','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '005','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '005','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '005','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '005','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '005','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '005','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '005','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '006','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '006','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '006','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '006','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '006','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '006','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '006','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '006','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '006','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '006','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '006','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '006','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '006','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '006','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '006','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '006','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '006','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '006','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '006','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '006','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '006','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '006','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '006','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '006','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '006','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '006','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '006','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '006','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '006','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '006','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '006','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '006','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '006','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '006','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '006','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '006','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '006','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '006','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '006','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '007','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '007','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '007','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '007','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '007','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '007','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '007','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '007','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '007','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '007','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '007','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '007','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '007','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '007','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '007','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '007','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '007','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '007','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '007','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '007','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '007','NT0_LIMEXH','1','2','0','1'} )
aAdd( aDados, { '007','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '007','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '007','NT0_PERCD','1','2','0','1'} )
aAdd( aDados, { '007','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '007','NT0_PEREX','1','1','0','1'} )
aAdd( aDados, { '007','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '007','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '007','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '007','NT0_TPCEXC','1','1','','1'} )
aAdd( aDados, { '007','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '007','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '007','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '007','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '007','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '007','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '007','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '007','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '007','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '008','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '008','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '008','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '008','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '008','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '008','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '008','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '008','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '008','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '008','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '008','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '008','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '008','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '008','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '008','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '008','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '008','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '008','NT0_FIXEXC','2','2','1','1'} )
aAdd( aDados, { '008','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '008','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '008','NT0_LIMEXH','1','2','0','1'} )
aAdd( aDados, { '008','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '008','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '008','NT0_PERCD','1','2','0','1'} )
aAdd( aDados, { '008','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '008','NT0_PEREX','2','2','1','1'} )
aAdd( aDados, { '008','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '008','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '008','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '008','NT0_TPCEXC','1','1','','1'} )
aAdd( aDados, { '008','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '008','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '008','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '008','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '008','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '008','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '008','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '008','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '008','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '009','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '009','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '009','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '009','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '009','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '009','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '009','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '009','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '009','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '009','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '009','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '009','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '009','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '009','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '009','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '009','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '009','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '009','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '009','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '009','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '009','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '009','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '009','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '009','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '009','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '009','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '009','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '009','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '009','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '009','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '009','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '009','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '009','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '009','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '009','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '009','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '009','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '009','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '009','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '010','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '010','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '010','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '010','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '010','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '010','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '010','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '010','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '010','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '010','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '010','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '010','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '010','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '010','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '010','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '010','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '010','NT0_FINAJU','2','2','1','1'} )
aAdd( aDados, { '010','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '010','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '010','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '010','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '010','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '010','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '010','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '010','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '010','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '010','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '010','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '010','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '010','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '010','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '010','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '010','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '010','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '010','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '010','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '010','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '010','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '010','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '011','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '011','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '011','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '011','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '011','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '011','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '011','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '011','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '011','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '011','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '011','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '011','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '011','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '011','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '011','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '011','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '011','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '011','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '011','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '011','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '011','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '011','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '011','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '011','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '011','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '011','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '011','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '011','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '011','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '011','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '011','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '011','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '011','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '011','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '011','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '011','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '011','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '011','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '011','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '012','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '012','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '012','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '012','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '012','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '012','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '012','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '012','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '012','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '012','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '012','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '012','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '012','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '012','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '012','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '012','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '012','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '012','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '012','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '012','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '012','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '012','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '012','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '012','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '012','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '012','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '012','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '012','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '012','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '012','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '012','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '012','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '012','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '012','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '012','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '012','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '012','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '012','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '012','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '013','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '013','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '013','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '013','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '013','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '013','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '013','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '013','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '013','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '013','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '013','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '013','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '013','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '013','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '013','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '013','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '013','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '013','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '013','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '013','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '013','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '013','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '013','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '013','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '013','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '013','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '013','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '013','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '013','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '013','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '013','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '013','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '013','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '013','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '013','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '013','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '013','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '013','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '013','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '014','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '014','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '014','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '014','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '014','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '014','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '014','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '014','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '014','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '014','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '014','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '014','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '014','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '014','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '014','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '014','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '014','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '014','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '014','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '014','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '014','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '014','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '014','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '014','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '014','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '014','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '014','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '014','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '014','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '014','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '014','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '014','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '014','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '014','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '014','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '014','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '014','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '014','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '014','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '015','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '015','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '015','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '015','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '015','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '015','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '015','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '015','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '015','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '015','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '015','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '015','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '015','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '015','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '015','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '015','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '015','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '015','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '015','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '015','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '015','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '015','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '015','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '015','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '015','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '015','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '015','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '015','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '015','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '015','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '015','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '015','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '015','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '015','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '015','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '015','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '015','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '015','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '015','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '016','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '016','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '016','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '016','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '016','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '016','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '016','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '016','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '016','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '016','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '016','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '016','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '016','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '016','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '016','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '016','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '016','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '016','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '016','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '016','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '016','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '016','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '016','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '016','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '016','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '016','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '016','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '016','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '016','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '016','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '016','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '016','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '016','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '016','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '016','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '016','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '016','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '016','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '016','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '017','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '017','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '017','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '017','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '017','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '017','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '017','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '017','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '017','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '017','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '017','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '017','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '017','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '017','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '017','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '017','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '017','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '017','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '017','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '017','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '017','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '017','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '017','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '017','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '017','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '017','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '017','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '017','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '017','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '017','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '017','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '017','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '017','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '017','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '017','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '017','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '017','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '017','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '017','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '018','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '018','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '018','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '018','NT0_CINDIC','1','2','','2'} )
aAdd( aDados, { '018','NT0_CMOEF','1','1','','2'} )
aAdd( aDados, { '018','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '018','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '018','NT0_DECPAR','1','2','','2'} )
aAdd( aDados, { '018','NT0_DESPAR','1','2','','2'} )
aAdd( aDados, { '018','NT0_DINDIC','1','2','','2'} )
aAdd( aDados, { '018','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '018','NT0_DMOEF','1','2','','2'} )
aAdd( aDados, { '018','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '018','NT0_DTBASE','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '018','NT0_DTREFI','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '018','NT0_DTVENC','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '018','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '018','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '018','NT0_FXABM','1','1','2','2'} )
aAdd( aDados, { '018','NT0_FXENCM','1','1','2','2'} )
aAdd( aDados, { '018','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '018','NT0_PARCE','2','2','2','2'} )
aAdd( aDados, { '018','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '018','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '018','NT0_PERCOR','1','2','0','2'} )
aAdd( aDados, { '018','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '018','NT0_PERFIX','1','1','0','2'} )
aAdd( aDados, { '018','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '018','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '018','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '018','NT0_TPCORR','1','1','1','2'} )
aAdd( aDados, { '018','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '018','NT0_VLRBAS','1','1','0','2'} )
aAdd( aDados, { '018','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '018','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '018','NT0_VALORA','1','2','0','2'} )
	aAdd( aDados, { '018','NT0_DATAAT','1','2','CToD( "  /  / " )','2'} )
	aAdd( aDados, { '018','NT0_CASPRO','1','1','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '018','NT0_FIXREV','1','1','2','2'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '019','NT0_CALFX','1','1','','2'} )
aAdd( aDados, { '019','NT0_CFACVL','2','2','1','1'} )
aAdd( aDados, { '019','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '019','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '019','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '019','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '019','NT0_CTBCVL','2','2','1','1'} )
aAdd( aDados, { '019','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '019','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '019','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '019','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '019','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '019','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '019','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '019','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '019','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '019','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '019','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '019','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '019','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '019','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '019','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '019','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '019','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '019','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '019','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '019','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '019','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '019','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '019','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '019','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '019','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '019','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '019','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '019','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '019','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '019','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '019','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '019','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '020','NT0_CALFX','1','1','','2'} )
aAdd( aDados, { '020','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '020','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '020','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '020','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '020','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '020','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '020','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '020','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '020','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '020','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '020','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '020','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '020','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '020','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '020','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '020','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '020','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '020','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '020','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '020','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '020','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '020','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '020','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '020','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '020','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '020','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '020','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '020','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '020','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '020','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '020','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '020','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '020','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '020','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '020','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '020','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '020','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '020','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '021','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '021','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '021','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '021','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '021','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '021','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '021','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '021','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '021','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '021','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '021','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '021','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '021','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '021','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '021','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '021','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '021','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '021','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '021','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '021','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '021','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '021','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '021','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '021','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '021','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '021','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '021','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '021','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '021','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '021','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '021','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '021','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '021','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '021','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '021','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '021','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '021','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '021','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '021','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '022','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '022','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '022','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '022','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '022','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '022','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '022','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '022','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '022','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '022','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '022','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '022','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '022','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '022','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '022','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '022','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '022','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '022','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '022','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '022','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '022','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '022','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '022','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '022','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '022','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '022','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '022','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '022','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '022','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '022','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '022','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '022','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '022','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '022','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '022','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '022','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '022','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '022','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '022','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '023','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '023','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '023','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '023','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '023','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '023','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '023','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '023','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '023','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '023','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '023','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '023','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '023','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '023','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '023','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '023','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '023','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '023','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '023','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '023','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '023','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '023','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '023','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '023','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '023','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '023','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '023','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '023','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '023','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '023','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '023','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '023','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '023','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '023','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '023','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '023','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '023','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '023','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '023','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '024','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '024','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '024','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '024','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '024','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '024','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '024','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '024','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '024','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '024','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '024','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '024','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '024','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '024','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '024','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '024','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '024','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '024','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '024','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '024','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '024','NT0_LIMEXH','1','2','0','1'} )
aAdd( aDados, { '024','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '024','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '024','NT0_PERCD','1','2','0','1'} )
aAdd( aDados, { '024','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '024','NT0_PEREX','1','1','0','1'} )
aAdd( aDados, { '024','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '024','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '024','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '024','NT0_TPCEXC','1','1','','1'} )
aAdd( aDados, { '024','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '024','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '024','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '024','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '024','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '024','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '024','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '024','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '024','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '025','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '025','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '025','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '025','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '025','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '025','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '025','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '025','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '025','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '025','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '025','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '025','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '025','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '025','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '025','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '025','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '025','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '025','NT0_FIXEXC','2','2','1','1'} )
aAdd( aDados, { '025','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '025','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '025','NT0_LIMEXH','1','2','0','1'} )
aAdd( aDados, { '025','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '025','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '025','NT0_PERCD','1','2','0','1'} )
aAdd( aDados, { '025','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '025','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '025','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '025','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '025','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '025','NT0_TPCEXC','1','1','','1'} )
aAdd( aDados, { '025','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '025','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '025','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '025','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '025','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '025','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '025','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '025','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '025','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '026','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '026','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '026','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '026','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '026','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '026','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '026','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '026','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '026','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '026','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '026','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '026','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '026','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '026','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '026','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '026','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '026','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '026','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '026','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '026','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '026','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '026','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '026','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '026','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '026','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '026','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '026','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '026','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '026','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '026','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '026','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '026','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '026','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '026','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '026','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '026','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '026','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '026','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '026','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '027','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '027','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '027','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '027','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '027','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '027','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '027','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '027','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '027','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '027','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '027','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '027','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '027','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '027','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '027','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '027','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '027','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '027','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '027','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '027','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '027','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '027','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '027','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '027','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '027','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '027','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '027','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '027','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '027','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '027','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '027','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '027','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '027','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '027','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '027','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '027','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '027','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '027','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '027','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '028','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '028','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '028','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '028','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '028','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '028','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '028','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '028','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '028','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '028','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '028','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '028','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '028','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '028','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '028','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '028','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '028','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '028','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '028','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '028','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '028','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '028','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '028','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '028','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '028','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '028','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '028','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '028','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '028','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '028','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '028','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '028','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '028','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '028','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '028','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '028','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '028','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '028','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '028','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '029','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '029','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '029','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '029','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '029','NT0_CMOEF','1','1','','1'} )
aAdd( aDados, { '029','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '029','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '029','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '029','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '029','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '029','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '029','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '029','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '029','NT0_DTBASE','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '029','NT0_DTREFI','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '029','NT0_DTVENC','1','1','CToD( "  /  / " )','1'} )
aAdd( aDados, { '029','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '029','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '029','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '029','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '029','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '029','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '029','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '029','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '029','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '029','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '029','NT0_PERFIX','1','1','0','1'} )
aAdd( aDados, { '029','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '029','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '029','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '029','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '029','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '029','NT0_VLRBAS','1','1','0','1'} )
aAdd( aDados, { '029','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '029','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '029','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '029','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '029','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '029','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '030','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '030','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '030','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '030','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '030','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '030','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '030','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '030','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '030','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '030','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '030','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '030','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '030','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '030','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '030','NT0_DTREFI','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '030','NT0_DTVENC','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '030','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '030','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '030','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '030','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '030','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '030','NT0_PARCE','2','2','1','1'} )
aAdd( aDados, { '030','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '030','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '030','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '030','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '030','NT0_PERFIX','1','2','0','1'} )
aAdd( aDados, { '030','NT0_QTPARC','1','2','0','1'} )
aAdd( aDados, { '030','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '030','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '030','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '030','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '030','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '030','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '030','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '030','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '030','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '030','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '030','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '031','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '031','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '031','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '031','NT0_CINDIC','1','2','','1'} )
aAdd( aDados, { '031','NT0_CMOEF','1','2','','1'} )
aAdd( aDados, { '031','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '031','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '031','NT0_DECPAR','1','2','','1'} )
aAdd( aDados, { '031','NT0_DESPAR','1','2','','1'} )
aAdd( aDados, { '031','NT0_DINDIC','1','2','','1'} )
aAdd( aDados, { '031','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '031','NT0_DMOEF','1','2','','1'} )
aAdd( aDados, { '031','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '031','NT0_DTBASE','1','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '031','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '031','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '031','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '031','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '031','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '031','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '031','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '031','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '031','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '031','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '031','NT0_PERCOR','1','2','0','1'} )
aAdd( aDados, { '031','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '031','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '031','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '031','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '031','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '031','NT0_TPCORR','1','1','1','1'} )
aAdd( aDados, { '031','NT0_TPFX','2','2','','2'} )
aAdd( aDados, { '031','NT0_VLRBAS','1','2','0','1'} )
aAdd( aDados, { '031','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '031','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '031','NT0_VALORA','1','2','0','1'} )
	aAdd( aDados, { '031','NT0_DATAAT','1','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '031','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '031','NT0_FIXREV','1','1','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '032','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '032','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '032','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '032','NT0_CINDIC','1','2','','2'} )
aAdd( aDados, { '032','NT0_CMOEF','1','1','','2'} )
aAdd( aDados, { '032','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '032','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '032','NT0_DECPAR','1','2','','2'} )
aAdd( aDados, { '032','NT0_DESPAR','1','2','','2'} )
aAdd( aDados, { '032','NT0_DINDIC','1','2','','2'} )
aAdd( aDados, { '032','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '032','NT0_DMOEF','1','2','','2'} )
aAdd( aDados, { '032','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '032','NT0_DTBASE','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '032','NT0_DTREFI','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '032','NT0_DTVENC','1','1','CToD( "  /  / " )','2'} )
aAdd( aDados, { '032','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '032','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '032','NT0_FXABM','1','1','2','2'} )
aAdd( aDados, { '032','NT0_FXENCM','1','1','2','2'} )
aAdd( aDados, { '032','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '032','NT0_PARCE','2','2','2','2'} )
aAdd( aDados, { '032','NT0_PARFIX','2','2','1','1'} )
aAdd( aDados, { '032','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '032','NT0_PERCOR','1','2','0','2'} )
aAdd( aDados, { '032','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '032','NT0_PERFIX','1','1','0','2'} )
aAdd( aDados, { '032','NT0_QTPARC','2','2','0','2'} )
aAdd( aDados, { '032','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '032','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '032','NT0_TPCORR','1','1','1','2'} )
aAdd( aDados, { '032','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '032','NT0_VLRBAS','1','1','0','2'} )
aAdd( aDados, { '032','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '032','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '032','NT0_VALORA','1','2','0','2'} )
	aAdd( aDados, { '032','NT0_DATAAT','1','2','CToD( "  /  / " )','2'} )
	aAdd( aDados, { '032','NT0_CASPRO','1','1','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '032','NT0_FIXREV','1','1','2','2'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '033','NT0_CALFX','1','1','','2'} )
aAdd( aDados, { '033','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '033','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '033','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '033','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '033','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '033','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '033','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '033','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '033','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '033','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '033','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '033','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '033','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '033','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '033','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '033','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '033','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '033','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '033','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '033','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '033','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '033','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '033','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '033','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '033','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '033','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '033','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '033','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '033','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '033','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '033','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '033','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '033','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '033','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '033','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '033','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '033','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '033','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '034','NT0_CALFX','1','1','','2'} )
aAdd( aDados, { '034','NT0_CFACVL','1','1','1','1'} )
aAdd( aDados, { '034','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '034','NT0_CINDIC','2','2','','1'} )
aAdd( aDados, { '034','NT0_CMOEF','2','2','','1'} )
aAdd( aDados, { '034','NT0_CMOELI','1','1','','1'} )
aAdd( aDados, { '034','NT0_CTBCVL','1','1','1','1'} )
aAdd( aDados, { '034','NT0_DECPAR','2','2','','1'} )
aAdd( aDados, { '034','NT0_DESPAR','2','2','','1'} )
aAdd( aDados, { '034','NT0_DINDIC','2','2','','1'} )
aAdd( aDados, { '034','NT0_DISPON','1','2','0','1'} )
aAdd( aDados, { '034','NT0_DMOEF','2','2','','1'} )
aAdd( aDados, { '034','NT0_DMOELI','1','2','','1'} )
aAdd( aDados, { '034','NT0_DTBASE','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '034','NT0_DTREFI','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '034','NT0_DTVENC','2','2','CToD( "  /  / " )','1'} )
aAdd( aDados, { '034','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '034','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '034','NT0_FXABM','2','2','2','2'} )
aAdd( aDados, { '034','NT0_FXENCM','2','2','2','2'} )
aAdd( aDados, { '034','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '034','NT0_PARCE','2','2','2','1'} )
aAdd( aDados, { '034','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '034','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '034','NT0_PERCOR','2','2','0','1'} )
aAdd( aDados, { '034','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '034','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '034','NT0_QTPARC','2','2','0','1'} )
aAdd( aDados, { '034','NT0_SALDOI','1','2','0','1'} )
aAdd( aDados, { '034','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '034','NT0_TPCORR','2','2','1','1'} )
aAdd( aDados, { '034','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '034','NT0_VLRBAS','2','2','0','1'} )
aAdd( aDados, { '034','NT0_VLRLI','1','1','0','1'} )
aAdd( aDados, { '034','NT0_VLRLIF','1','1','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '034','NT0_VALORA','2','2','0','1'} )
	aAdd( aDados, { '034','NT0_DATAAT','2','2','CToD( "  /  / " )','1'} )
	aAdd( aDados, { '034','NT0_CASPRO','2','2','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '034','NT0_FIXREV','2','2','2','1'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '035','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '035','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '035','NT0_CFXCVL','2','2','1','1'} )
aAdd( aDados, { '035','NT0_CINDIC','1','2','','2'} )
aAdd( aDados, { '035','NT0_CMOEF','1','2','','2'} )
aAdd( aDados, { '035','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '035','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '035','NT0_DECPAR','1','2','','2'} )
aAdd( aDados, { '035','NT0_DESPAR','1','2','','2'} )
aAdd( aDados, { '035','NT0_DINDIC','1','2','','2'} )
aAdd( aDados, { '035','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '035','NT0_DMOEF','1','2','','2'} )
aAdd( aDados, { '035','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '035','NT0_DTBASE','1','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '035','NT0_DTREFI','1','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '035','NT0_DTVENC','1','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '035','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '035','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '035','NT0_FXABM','1','1','2','2'} )
aAdd( aDados, { '035','NT0_FXENCM','1','1','2','2'} )
aAdd( aDados, { '035','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '035','NT0_PARCE','2','2','1','2'} )
aAdd( aDados, { '035','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '035','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '035','NT0_PERCOR','1','2','0','2'} )
aAdd( aDados, { '035','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '035','NT0_PERFIX','1','2','0','2'} )
aAdd( aDados, { '035','NT0_QTPARC','1','2','0','2'} )
aAdd( aDados, { '035','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '035','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '035','NT0_TPCORR','1','1','1','2'} )
aAdd( aDados, { '035','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '035','NT0_VLRBAS','1','2','0','2'} )
aAdd( aDados, { '035','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '035','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '035','NT0_VALORA','1','2','0','2'} )
	aAdd( aDados, { '035','NT0_DATAAT','1','2','CToD( "  /  / " )','2'} )
	aAdd( aDados, { '035','NT0_CASPRO','1','1','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '035','NT0_FIXREV','1','1','2','2'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

aAdd( aDados, { '036','NT0_CALFX','2','2','','2'} )
aAdd( aDados, { '036','NT0_CFACVL','2','2','2','1'} )
aAdd( aDados, { '036','NT0_CFXCVL','2','2','2','1'} )
aAdd( aDados, { '036','NT0_CINDIC','1','2','','2'} )
aAdd( aDados, { '036','NT0_CMOEF','1','2','','2'} )
aAdd( aDados, { '036','NT0_CMOELI','2','2','','1'} )
aAdd( aDados, { '036','NT0_CTBCVL','2','2','2','1'} )
aAdd( aDados, { '036','NT0_DECPAR','1','2','','2'} )
aAdd( aDados, { '036','NT0_DESPAR','1','2','','2'} )
aAdd( aDados, { '036','NT0_DINDIC','1','2','','2'} )
aAdd( aDados, { '036','NT0_DISPON','2','2','0','1'} )
aAdd( aDados, { '036','NT0_DMOEF','1','2','','2'} )
aAdd( aDados, { '036','NT0_DMOELI','2','2','','1'} )
aAdd( aDados, { '036','NT0_DTBASE','1','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '036','NT0_DTREFI','2','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '036','NT0_DTVENC','2','2','CToD( "  /  / " )','2'} )
aAdd( aDados, { '036','NT0_FINAJU','2','2','2','1'} )
aAdd( aDados, { '036','NT0_FIXEXC','2','2','2','1'} )
aAdd( aDados, { '036','NT0_FXABM','1','1','2','2'} )
aAdd( aDados, { '036','NT0_FXENCM','1','1','2','2'} )
aAdd( aDados, { '036','NT0_LIMEXH','2','2','0','1'} )
aAdd( aDados, { '036','NT0_PARCE','2','2','2','2'} )
aAdd( aDados, { '036','NT0_PARFIX','2','2','2','1'} )
aAdd( aDados, { '036','NT0_PERCD','2','2','0','1'} )
aAdd( aDados, { '036','NT0_PERCOR','1','2','0','2'} )
aAdd( aDados, { '036','NT0_PEREX','2','2','0','1'} )
aAdd( aDados, { '036','NT0_PERFIX','2','2','0','1'} )
aAdd( aDados, { '036','NT0_QTPARC','2','2','0','2'} )
aAdd( aDados, { '036','NT0_SALDOI','2','2','0','1'} )
aAdd( aDados, { '036','NT0_TPCEXC','2','2','','1'} )
aAdd( aDados, { '036','NT0_TPCORR','1','1','1','2'} )
aAdd( aDados, { '036','NT0_TPFX','1','1','','2'} )
aAdd( aDados, { '036','NT0_VLRBAS','1','2','0','2'} )
aAdd( aDados, { '036','NT0_VLRLI','2','2','0','1'} )
aAdd( aDados, { '036','NT0_VLRLIF','2','2','0','1'} )

If NT0->(ColumnPos("NT0_VALORA"))>0 //PROTEÇÃO
	aAdd( aDados, { '036','NT0_DATAAT','1','2','CToD( "  /  / " )','2'} )
	aAdd( aDados, { '036','NT0_VALORA','1','2','0','2'} )
	aAdd( aDados, { '036','NT0_CASPRO','1','1','1','2'} )
EndIf
If NT0->(ColumnPos("NT0_FIXREV")) > 0
	aAdd( aDados, { '036','NT0_FIXREV','1','1','2','2'} )
EndIf

aAdd( aCod, aDados )
aDados := {}

Return aCod

//-------------------------------------------------------------------
/*/{Protheus.doc} J037Campos()
Rotina para retornar um array com os campos de preenchimento obrigatorio
para o tipo de honorário.

@Return aCampo Campos de preenchimento obrigatorio para o tipo de honorário.

@author Abner Fogaça Oliveira / Luciano Pereira dos Santos
@since 29/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J037Campos()
Local aCampos := {}
Local cCampos := "NT0_CALFX|NT0_CMOEF|NT0_CMOELI|NT0_DMOEF|NT0_DMOELI|NT0_DTBASE|NT0_DTREFI|NT0_DTVENC|NT0_FINAJU|NT0_FIXEXC|NT0_FXABM|" + ;
                 "NT0_FXENCM|NT0_LIMEXH|NT0_PARFIX|NT0_PERCD|NT0_PERCOR|NT0_PEREX|NT0_PERFIX|NT0_SALDOI|NT0_TPCEXC|NT0_TPFX|NT0_VLRBAS|" + ;
                 "NT0_VLRLI|NT0_VLRLIF|NT0_TPCORR|NT0_CINDIC|NT0_DINDIC|NT0_PARCE|NT0_DISPON|NT0_DESPAR|NT0_CFXCVL|NT0_CTBCVL|NT0_CFACVL|" + ;
                 "NT0_QTPARC|NT0_DECPAR" + ; 
                 Iif(NT0->(ColumnPos("NT0_VALORA")) > 0, "|NT0_VALORA|NT0_DATAAT|NT0_CASPRO","") + ; // PROTEÇÃO
                 Iif(NT0->(ColumnPos("NT0_FIXREV")) > 0, "|NT0_FIXREV","") // PROTEÇÃO

aCampos := StrTokArr(cCampos, "|")

Return aCampos

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA037COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA037COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA037COMMIT
Return

Method InTTS(oModel, cModelId) Class JA037COMMIT
	JFILASINC(oModel:GetModel(), "NRA", "NRAMASTER", "NRA_COD")
Return
 
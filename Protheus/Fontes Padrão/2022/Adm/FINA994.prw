#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA994.CH' 

Static lFA944QRY := nil
Static lFA944ARR := nil
Static lRlOrigem := nil 
Static aTamValor := nil
Static lAvisoFOD := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA994
Cadastro de socios da sociedade em conta de participação SCP e seus lucros/dividendos mensais

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function FINA994()
Local oBrowse

If AliasInDic("FOD")
	DbSelectArea("FOD")
	If ColumnPos("FOD_FILCEN") > 0
		DbSelectArea("FOE")
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('FOD')
		oBrowse:SetDescription(STR0001)//'Cadastro de sócio SCP e dos lucros/dividendos' 

		oBrowse:Activate()
	Else
		MsgStop(STR0013+" "+STR0015)	//Campo FOD_FILCEN não existe. / "Necessário rodar o UPDDISTR!"
	EndIf	
Else
	MsgStop(STR0002)	//"Tabela FOD não existe. Necessário rodar o U_UPDFIN2!"
EndIf
Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.FINA994' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FINA994' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0005 	 ACTION 'VIEWDEF.FINA994' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0006	 ACTION 'VIEWDEF.FINA994' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFOD := FWFormStruct( 1, 'FOD', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFOE := FWFormStruct( 1, 'FOE', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

oStruFOD:SetProperty('FOD_FILSCP',MODEL_FIELD_VALID, {|| F994FILSOC() })
oStruFOD:SetProperty('FOD_FILSOC',MODEL_FIELD_VALID, {|| F994FILSOC() })
oStruFOD:SetProperty('FOD_FILCEN',MODEL_FIELD_VALID, {|| F994FILSOC() }) 
oStruFOD:SetProperty('FOD_FILCEN',MODEL_FIELD_WHEN, {|| f994WHEN() })
//oStruFOD:SetProperty('FOD_CGCCPF',MODEL_FIELD_WHEN, {|| .F. })

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FINA994',  /*bPreValidacao*/, {|| F994TIPOP() } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FODMASTER', /*cOwner*/, oStruFOD )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'FOEDETAIL', 'FODMASTER', oStruFOE, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetPrimaryKey({'FOD_FILIAL','FOD_FILCEN','FOD_FILSCP','FOD_FILSOC'})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FOEDETAIL', { { 'FOE_FILIAL', 'xFilial( "FOE" )' }, { 'FOE_FILCEN', 'FOD_FILCEN' },{ 'FOE_FILSCP', 'FOD_FILSCP' }, { 'FOE_FILSOC', 'FOD_FILSOC' } }, FOE->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FOEDETAIL' ):SetUniqueLine( {"FOE_MES","FOE_ANO"})

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'FOEDETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 )//'Cadastro de Sócio(s) SCP'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FODMASTER' ):SetDescription( STR0007 )
oModel:GetModel( 'FOEDETAIL' ):SetDescription( STR0008  ) //'Lucro/Dividendos mensais'

oModel:SetVldActivate( {|oModel| F994VldAct(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria a view

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruFOD := FWFormStruct( 2, 'FOD' , { |x| !ALLTRIM(x) $ "FOD_TIPOPE"} )
Local oStruFOE := FWFormStruct( 2, 'FOE' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'FINA994' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FOD', oStruFOD, 'FODMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FOE', oStruFOE, 'FOEDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FOD', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_FOE', 'INFERIOR' )

oView:EnableTitleView('VIEW_FOE',STR0008)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F994TIPOP
preenche o campo tipo pessoa

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function F994TIPOP() 
Local oModel      := FWModelActive()
Local oModelFOD := oModel:GetModel( "FODMASTER" )
If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If 	Len(Alltrim(oModelFOD:GetValue("FOD_CGCCPF"))) < 14
		oModelFOD:SetValue("FOD_TIPOPE","F")
	Else
		oModelFOD:SetValue("FOD_TIPOPE","J")
	EndIf
EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F994ValMes
Valid do campo FOE_MES

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994ValMes()    
Local lRet := .T.

If !PERTENCE("01,02,03,04,05,06,07,08,09,10,11,12")
	Help( ,,"FOE_MESVAL",,STR0009, 1, 0 ) //"Mês Inválido! Informe um mês entre 01 a 12!(Formato MM)"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F994ValAno
Valid do campo FOE_ANO

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994ValAno()
Local oModel      := FWModelActive()
Local oModelFOE := oModel:GetModel( "FOEDETAIL" )                                                                                                               
Local lRet := .T.
If	Len(Alltrim(oModelFOE:GetValue("FOE_ANO"))) != 4
	lRet := .F.
	Help( ,,"FOE_ANOVAL",,STR0010, 1, 0 )//"Ano inválido! Informe o ano no formato AAAA."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F994FILSOC
Valid do campo FOD_FILSOC, FOD_FILSCP, FOD_FILCEN

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function F994FILSOC()
Local oModel      := FWModelActive()
Local oModelFOD := oModel:GetModel( "FODMASTER" )
Local lRet := .T.
Local cSocio := oModelFOD:GetValue("FOD_FILSOC")
Local cCentral := oModelFOD:GetValue("FOD_FILCEN")
Local cFilSCP := oModelFOD:GetValue("FOD_FILSCP")

/*If oModelFOD:GetValue("FOD_FILSCP") == cSocio
	Help( ,,"FOD_FILSOC",,STR0011, 1, 0 )//"Filial socio não pode ser igual a filial principal da SCP!"
	lRet := .F.
EndIf
*/
If !ExistChav("FOD",cCentral+cFilSCP+cSocio,,)
	lRet := .F.
EndIf
If lRet .and. !Empty(cCentral) .and. !ExistCpo("SM0",cEmpAnt+cCentral)
	lRet := .F. 
EndIf
If lRet .and. !Empty(cFilSCP) .and. !ExistCpo("SM0",cEmpAnt+cFilSCP)
	lRet := .F. 
EndIf
If lRet .and. !Empty(cSocio) 
	If Select('SM0') == 0
		OpenSM0()
	EndIf
	dbSelectArea( 'SM0' )
	If SM0->(dbSeek(cEmpAnt + cSocio))
		If !Empty(SM0->M0_NOMECOM)
			oModelFOD:LoadValue("FOD_NOME",SM0->M0_NOMECOM)
		EndIf
		If !Empty(SM0->M0_CGC)	
			oModelFOD:LoadValue("FOD_CGCCPF",SM0->M0_CGC)
		EndIf	
	Else
		Help( ,,"REGNOIS",,, 1, 0 )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f994WHEN
WHEN do campo  FOD_FILCEN

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
                   
Static function f994WHEN()
Local oModel      := FWModelActive()
Local oModelFOD := oModel:GetModel( "FODMASTER" )
Local lRet := .F.
Local cCentral := oModelFOD:GetValue("FOD_FILCEN")

If Empty(FOD->FOD_FILCEN) .or. oModel:GetOperation() == MODEL_OPERATION_INSERT
	lRet := .T.
EndIf

Return lRet
                   
//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994DIRF()
Retorna array com as informações cadastradas do socio

@param cAno,caracter, informa qual ano deve ser retornado

@return aSCP, array, array multidimensional contendo a filial SCP e seus socios e seus lucros/dividendos

array[1] - array socio ostensivo
array[1][1] - Filial socio ostensivo
array[1][2] - Nome socio ostensivo
array[1][3] - CNPJ socio ostensivo
array[1][4] - array sócios da sCP 
array[1][4][1] - array informacoes sócios da sCP
array[1][4][1][1] - Filial socio da SCP
array[1][4][1][2] - Tipo Pessoa F ou J
array[1][4][1][3] - Nome do socio
array[1][4][1][4] - CPF ou CGC do socio
array[1][4][1][5] - Percentual de participacao
array[1][4][1][6] - array com os valores mensais
array[1][4][1][6][1][1] - Mes
array[1][4][1][6][1][2] - Ano
array[1][4][1][6][1][3] - Valor

array[1][4][1][6][2][1] - Mes
array[1][4][1][6][2][2] - Ano
array[1][4][1][6][2][3] - Valor

array[1][4][2] - array informacoes do segundo socio da sCP
array[1][4][2][1] - Filial socio da SCP
array[1][4][2][2] - Tipo Pessoa F ou J
array[1][4][2][3] - Nome do socio
array[1][4][2][4] - CPF ou CGC do socio
array[1][4][2][5] - Percentual de participacao
array[1][4][2][6] - array com os valores mensais
array[1][4][2][6][1][1] - Mes
array[1][4][2][6][1][2] - Ano
array[1][4][2][6][1][3] - Valor

array[1][4][2][6][2][1] - Mes
array[1][4][2][6][2][2] - Ano
array[1][4][2][6][2][3] - Valor

array[2] - array o segundo socio ostensivo
array[2][1] - Filial socio ostensivo
array[2][2] - Nome socio ostensivo
array[2][3] - CNPJ socio ostensivo
array[2][4] - array sócios da sCP 
array[2][4][1] - array informacoes sócios da sCP

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------

Function F994DIRF(cAno,cFilCen)
Local aSCP := {}
Local cQuery := "" 
Local cAliasQry := GetNextAlias()
Local aTamPercen := TamSX3("FOD_PERCEN")
Local aTamValor := TamSX3("FOE_VALOR")
Local cFilScpAnt := ""
Local cFilSocAnt := ""
Local aSocio := {}
Local aMeses := {}
Local lSkip := .F. 
Local cNome := ""
Local cCNPJ := ""
Local aRetARR := {}
Local aAreaAnt := GetArea()

If !AliasInDic("FOD")
	Return aClone(aSCP)
EndIf

DbSelectArea("FOD")

If ColumnPos("FOD_FILCEN") == 0 
	If !lAvisoFOD
		MsgStop(STR0013+" "+STR0015)
	EndIf	
	lAvisoFOD := .T.
	Return aClone(aSCP)
EndIf

DbSelectArea("FOE")
If lFA944QRY == nil
	lFA944QRY := ExistBlock("FA944QRY")
EndIf	
If lFA944ARR == nil
	lFA944ARR := ExistBlock("FA944ARR")
EndIf

#IFDEF TOP
	cQuery := "SELECT FOD.FOD_FILSCP, FOD.FOD_FILSOC, FOD.FOD_NOME, FOD.FOD_CGCCPF, FOD.FOD_PERCEN ,"
	cQuery += "FOD.FOD_TIPOPE, FOE.FOE_MES,FOE.FOE_ANO, FOE.FOE_VALOR "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD LEFT JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOD.FOD_FILCEN = FOE.FOE_FILCEN "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' " 
	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_FILCEN = '" + cFilCen + "' "
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FOD.FOD_FILSCP, FOD.FOD_TIPOPE, FOD.FOD_CGCCPF, FOE.FOE_MES " 

	If lFA944QRY
		cQuery := ExecBlock("FA944QRY",.F.,.F.,{cQuery, cAno})
		cQuery := ChangeQuery(cQuery)
	EndIf	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
		
	TCSetField(cAliasQry, "FOD_PERCEN", "N", aTamPercen[1] ,aTamPercen[2])
	TCSetField(cAliasQry, "FOE_VALOR", "N", aTamValor[1] ,aTamValor[2])	
	
	If Select('SM0') == 0
		OpenSM0()
	EndIf
	dbSelectArea( 'SM0' )
	
	While (cAliasQry)->(!Eof())
		If cFilScpAnt != (cAliasQry)->FOD_FILSCP
			If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSCP ))
				cNome := SM0->M0_NOMECOM
				cCNPJ := SM0->M0_CGC
			EndIf
			If Empty(cFilScpAnt)
				aAdd(aSCP,{ (cAliasQry)->FOD_FILSCP, cNome, cCNPJ })
			Else
				aAdd(aSCP[nLen], aClone(aSocio))
				aAdd(aSCP,{ (cAliasQry)->FOD_FILSCP, cNome, cCNPJ  })
			EndIf
			cFilScpAnt := (cAliasQry)->FOD_FILSCP
			cFilSocAnt := (cAliasQry)->FOD_FILSOC
			aSize(aSocio,0)
			aSocio := {}
			aSize(aMeses,0)
			aMeses := {}
		EndIf
			
		nLen := Len(aSCP)
		lSkip := .F. 
		aAdd(aSocio, {(cAliasQry)->FOD_FILSOC, (cAliasQry)->FOD_TIPOPE,(cAliasQry)->FOD_NOME, (cAliasQry)->FOD_CGCCPF, (cAliasQry)->FOD_PERCEN })
		aMeses := {}
		While (cAliasQry)->(!Eof()) .and. (cAliasQry)->FOD_FILSOC == cFilSocAnt
			If !Empty((cAliasQry)->FOE_MES )
				aAdd(aMeses, {(cAliasQry)->FOE_MES, (cAliasQry)->FOE_ANO, (cAliasQry)->FOE_VALOR} )
			EndIf	  
			lSkip := .T.
			(cAliasQry)->(DBSkip())
		EndDo
		
		If (cAliasQry)->FOD_FILSOC != cFilSocAnt .or. (cAliasQry)->(Eof())
			aAdd(aSocio[Len(aSocio)], aClone(aMeses) )
			cFilSocAnt := (cAliasQry)->FOD_FILSOC
			Loop
		EndIf
		If !lSkip
			aAdd(aSocio[Len(aSocio)], aClone(aMeses) )
			(cAliasQry)->(DBSkip())
		EndIf
		
	EndDo
	
	If Len(aSCP) > 0
		//adiciona o ultimo laco
		aAdd(aSCP[Len(aSCP)], aClone(aSocio))
	EndIf	
	
	(cAliasQry)->(DBCloseArea())
#ENDIF


aSize(aSocio,0)
aSocio := {}
aSize(aMeses,0)
aMeses := {}

If lFA944ARR
	aRetARR := ExecBlock("FA944ARR",.F.,.F.,aClone(aSCP))
	If ValType(aRetARR)== "A"
		aSCP := aClone(aRetARR)
	EndIf	
EndIf	

aSort(aSCP,,,{ |x,y| x[3] <  y[3] } )
RestArea(aAreaAnt)
Return aClone(aSCP)

//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994SRL()
Alimenta a SRL com os dados dos socios SCP

@cAno cAno,caracter, informa qual ano deve ser pesquisado

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------

Function F994SRL(cAno,cFilCen)
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local aAreaSRL := SRL->(GetArea())
Local cCodRet := "6910"
Local cRaMat := ""
Local cTipoFj := ""
Local cCGCMatriz := ""
Local cNomeMatriz := ""
Local nRegEmp	:= SM0->(Recno())
Local lF994CodD := Existblock("F994CodD")

Default cAno := Year(ddatabase)

#IFDEF TOP
	IF lRlOrigem == nil
		lRlOrigem := SRL->(FieldPos("RL_ORIGEM")) > 0
	EndIF

	dbSelectArea( 'SM0' )
	SM0->(MsSeek(cEmpAnt+cFilCen))
	cCGCMatriz := SM0->M0_CGC
	cNomeMatriz := SM0->M0_NOMECOM

	cQuery := "SELECT DISTINCT FOD.FOD_FILSOC, FOD.FOD_NOME, FOD.FOD_CGCCPF, FOD.FOD_PERCEN , FOD.FOD_TIPOPE "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD INNER JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOD.FOD_FILCEN = FOE.FOE_FILCEN "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' " 
	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_FILCEN = '" + cFilCen + "' "
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY FOD.FOD_TIPOPE" 
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
	
	
	dbSelectArea("SRL")
	SRL->(dbSetOrder(2))
	
	While (cAliasQry)->(!Eof())
		If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSOC ))
			cTipoFj := If((cAliasQry)->FOD_TIPOPE == "F" , "1", "2")
			If lF994CodD
				cCodRet := ExecBlock("FA944QRY",.F.,.F.)
			EndIf
			If !SRL->(MsSeek(xFilial("SRL")+Padr(SM0->M0_CGC,Len(SRL->RL_CGCFONT))+ ;
					cCodRet +cTipoFj+ (cAliasQry)->FOD_CGCCPF  ))
	
				Reclock("SRL", .T.)
	
				cRaMat := GetSxENum( "SRL" , "RL_MAT")
	
				SRL->RL_FILIAL  := xFilial("SRL")
				SRL->RL_MAT     := If(Val(SRA->RA_MAT) < 900000 .And. Val(cRaMat) < 900000, "900000",cRaMat)
				SRL->RL_CODRET  := cCodRet
				SRL->RL_TIPOFJ  := cTipoFj
				SRL->RL_CPFCGC  := (cAliasQry)->FOD_CGCCPF
				SRL->RL_BENEFIC := (cAliasQry)->FOD_NOME
				SRL->RL_ENDBENE := Alltrim(SM0->M0_ENDCOB) 
				SRL->RL_UFBENEF := Alltrim(SM0->M0_ESTCOB) 
				SRL->RL_COMPLEM := Alltrim(SM0->M0_COMPCOB) 
				SRL->RL_CGCFONT := cCGCMatriz
				SRL->RL_NOMFONT := cNomeMatriz
	
				If lRlOrigem
					SRL->RL_ORIGEM := "2"
				Endif
	
				SRL->(MsUnlock())
			EndIf	
		EndIf
		(cAliasQry)->(DbSkip())	
	EndDo
	
	(cAliasQry)->(DBCloseArea())

#ENDIF

RestArea(aAreaSRL)
SM0->(dbGoTo(nRegEmp))
Return 


//-------------------------------------------------------------------//-------------------------------------------------------------------
/*/{Protheus.doc} F994Rend(cAno, cCGCCPF)
retorna o rendimento anual do socio

@cAno cAno,caracter, informa qual ano deve ser pesquisado
@cCGCCPF , caracter, informar o cpf/cgc do socio 

@return  array
Array[1][1]: Filial do Socio Ostensiva (pagador)
Array[1][2]: CNPJ do Socio Ostensiva
Array[1][3]: Valor repassado no ano

@author Karen Honda
@since 11/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F994Rend(cAno,cCGCCPF)
Local aRet := {}
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local nRegEmp	:= SM0->(Recno())

#IFDEF TOP
	If aTamValor == nil
		aTamValor := TamSX3("FOE_VALOR")
	EndIf	
	cQuery := "SELECT FOD.FOD_FILSCP,FOD.FOD_FILSOC, SUM(FOE.FOE_VALOR) FOE_VALOR "
	cQuery += "FROM " + RetSqlName("FOD") + " FOD INNER JOIN " + RetSqlName("FOE") + " FOE "
	cQuery += "ON ( "	
	cQuery += "FOD.FOD_FILIAL  = FOE.FOE_FILIAL "
	cQuery += "AND FOD.FOD_FILSCP = FOE.FOE_FILSCP "
	cQuery += "AND FOD.FOD_FILSOC = FOE.FOE_FILSOC "
	cQuery += "AND FOE.FOE_ANO = '" + cAno + "' "
 	cQuery += "AND FOE.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE " 
	cQuery += "FOD.FOD_FILIAL = '" + xFilial("FOD") + "' "
	cQuery += "AND FOD.FOD_CGCCPF = '" + cCGCCPF + "' "	
	cQuery += "AND FOD.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY FOD.FOD_FILSCP,FOD.FOD_FILSOC" 
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)	
	
	TCSetField(cAliasQry, "FOE_VALOR", "N", aTamValor[1] ,aTamValor[2])	
	
	While (cAliasQry)->(!Eof())
		If SM0->(dbSeek(cEmpAnt + (cAliasQry)->FOD_FILSCP ))
			aAdd(aRet,{(cAliasQry)->FOD_FILSCP, SM0->M0_CGC, Iif(Empty((cAliasQry)->FOE_VALOR), 0, (cAliasQry)->FOE_VALOR )  })
		EndIf
		(cAliasQry)->(DbSkip())
				
	EndDo
	
	(cAliasQry)->(DBCloseArea())
	
	SM0->(dbGoTo(nRegEmp))
#ENDIF		

Return aClone(aRet)	


/*/{Protheus.doc} F994VldAct
	(long_description)
	@type  Function
	@author rafael.rondon
	@since 12/12/2019
	@version 12.1.27
	@param 
	@return lRet, Logical, 
	@see (links_or_references)
/*/
Function F994VldAct(oModel AS Object) As Logical

Local lRet 			As Logical
Local nOperation	As Numeric

lRet := .T.
nOperation := oModel:GetOperation()

If nOperation <> 1 // Visualizar
	If GetHlpLGPD({'FOD_NOME', 'FOD_CGCCPF'})
		lRet := .F.
	EndIf
EndIf	

Return lRet


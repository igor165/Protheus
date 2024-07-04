#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA060.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA060
Cadastro MVC - T010, Cadastro de Plano de Contas Contábeis

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA060()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Plano de Contas Contábeis
oBrw:SetAlias( 'C1O')
oBrw:SetMenuDef( 'TAFA060' )
  
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf060Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA060" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC1O	:=	FWFormStruct( 1, "C1O" )
Local oStruCH5	:=	FWFormStruct( 1, "CH5" )
Local oStruCHH	:=	FWFormStruct( 1, "CHH" )
Local oModel		:=	MPFormModel():New( "TAFA060",,, { |oModel| SaveModel( oModel ) } )
Local lCH_ANOCAL	:=	.F.

If TAFColumnPos( "CH5_ANOCAL" ) .and. TAFColumnPos( "CHH_ANOCAL" )
	lCH_ANOCAL := .T.
EndIf

oModel:AddFields( "MODEL_C1O", /*cOwner*/, oStruC1O )

oModel:AddGrid( "MODEL_CH5", "MODEL_C1O", oStruCH5 )
oModel:GetModel( "MODEL_CH5" ):SetOptional( .T. )

If lCH_ANOCAL
	oModel:GetModel( "MODEL_CH5" ):SetUniqueLine( { "CH5_IDCTAR", "CH5_CODCUS", "CH5_ANOCAL" } )
Else
	oModel:GetModel( "MODEL_CH5" ):SetUniqueLine( { "CH5_IDCTAR", "CH5_CODCUS" } )
EndIf

oModel:AddGrid( "MODEL_CHH", "MODEL_C1O", oStruCHH )
oModel:GetModel( "MODEL_CHH" ):SetOptional( .T. )

If lCH_ANOCAL
	oModel:GetModel( "MODEL_CHH" ):SetUniqueLine( { "CHH_CODGRU", "CHH_ANOCAL" } )
Else
	oModel:GetModel( "MODEL_CHH" ):SetUniqueLine( { "CHH_CODGRU" } )
EndIf

oModel:SetRelation( "MODEL_CH5", { { "CH5_FILIAL", 'xFilial( "CH5" )' }, { "CH5_ID", "C1O_ID" } }, CH5->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_CHH", { { "CHH_FILIAL", 'xFilial( "CHH" )' }, { "CHH_ID", "C1O_ID" } }, CHH->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C1O" ):SetPrimaryKey( { "C1O_CODIGO" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:=	FwLoadModel( "TAFA060" )
Local oStruC1O	:=	FwFormStruct( 2, "C1O" )
Local oStruCH5	:=	FwFormStruct( 2, "CH5" )
Local oStruCHH	:=	FwFormStruct( 2, "CHH" )
Local oView		:=	FwFormView():New()
Local aCombo		:=	{}
Local lCH_ANOCAL	:=	.F.

If TAFColumnPos( "CH5_ANOCAL" ) .and. TAFColumnPos( "CHH_ANOCAL" )
	lCH_ANOCAL := .T.
EndIf

oView:SetModel( oModel )

//Ordenação manual pois UPDDISTR não altera X3_ORDEM
If TamSX3("C1O_ID")[1]  == 36
	oStruC1O:SetProperty( "C1O_CCTARF", MVC_VIEW_ORDEM, "10" )
	oStruC1O:SetProperty( "C1O_DCTARE", MVC_VIEW_ORDEM, "11" )
	oStruC1O:SetProperty( "C1O_CNPJ",   MVC_VIEW_ORDEM, "12" )	
	oStruC1O:SetProperty( "C1O_CTASUP", MVC_VIEW_ORDEM, "13" )
	oStruC1O:SetProperty( "C1O_CCTASP", MVC_VIEW_ORDEM, "14" )
	oStruC1O:SetProperty( "C1O_DCTASU", MVC_VIEW_ORDEM, "15" )
	oStruC1O:SetProperty( "C1O_DTALT",  MVC_VIEW_ORDEM, "16" )
	oStruC1O:SetProperty( "C1O_DTCRIA", MVC_VIEW_ORDEM,	"17" )
	oStruC1O:SetProperty( "C1O_NATURE", MVC_VIEW_ORDEM,	"18" )
	
	oStruCH5:SetProperty( "CH5_ANOCAL", MVC_VIEW_ORDEM, "03" )
	oStruCH5:SetProperty( "CH5_TABECF", MVC_VIEW_ORDEM, "04" )
	oStruCH5:SetProperty( "CH5_CTAREF", MVC_VIEW_ORDEM, "05" )
	oStruCH5:SetProperty( "CH5_DCTARE", MVC_VIEW_ORDEM, "06" )
	oStruCH5:SetProperty( "CH5_IDCTAR", MVC_VIEW_ORDEM, "07" )
	oStruCH5:SetProperty( "CH5_CODCUS", MVC_VIEW_ORDEM, "08" )
	oStruCH5:SetProperty( "CH5_DCODCU", MVC_VIEW_ORDEM, "09" )

	oStruCHH:SetProperty( "CHH_ANOCAL", MVC_VIEW_ORDEM, "03" )
	oStruCHH:SetProperty( "CHH_CODGRU", MVC_VIEW_ORDEM, "04" )
	oStruCHH:SetProperty( "CHH_CNTCOR", MVC_VIEW_ORDEM, "05" )
	oStruCHH:SetProperty( "CHH_CCNTCO", MVC_VIEW_ORDEM, "06" )
	oStruCHH:SetProperty( "CHH_DCNTCO", MVC_VIEW_ORDEM, "07" )
	oStruCHH:SetProperty( "CHH_NATCNT", MVC_VIEW_ORDEM, "08" )
	oStruCHH:SetProperty( "CHH_DNATCN", MVC_VIEW_ORDEM, "09" )
	oStruCHH:SetProperty( "CHH_IDNATC", MVC_VIEW_ORDEM, "10" )	
Else
	If lCH_ANOCAL	
		oStruCH5:SetProperty( "CH5_ANOCAL", MVC_VIEW_ORDEM, "03" )
		oStruCH5:SetProperty( "CH5_TABECF", MVC_VIEW_ORDEM, "04" )
		oStruCH5:SetProperty( "CH5_CTAREF", MVC_VIEW_ORDEM, "05" )
		oStruCH5:SetProperty( "CH5_DCTARE", MVC_VIEW_ORDEM, "06" )
		oStruCH5:SetProperty( "CH5_IDCTAR", MVC_VIEW_ORDEM, "07" )
		oStruCH5:SetProperty( "CH5_CODCUS", MVC_VIEW_ORDEM, "08" )
		oStruCH5:SetProperty( "CH5_DCODCU", MVC_VIEW_ORDEM, "09" )
	
		oStruCHH:SetProperty( "CHH_ANOCAL", MVC_VIEW_ORDEM, "03" )
		oStruCHH:SetProperty( "CHH_CODGRU", MVC_VIEW_ORDEM, "04" )
		oStruCHH:SetProperty( "CHH_CNTCOR", MVC_VIEW_ORDEM, "05" )
		oStruCHH:SetProperty( "CHH_DCNTCO", MVC_VIEW_ORDEM, "06" )
		oStruCHH:SetProperty( "CHH_NATCNT", MVC_VIEW_ORDEM, "07" )
		oStruCHH:SetProperty( "CHH_DNATCN", MVC_VIEW_ORDEM, "08" )
		oStruCHH:SetProperty( "CHH_IDNATC", MVC_VIEW_ORDEM, "09" )
	EndIf
EndIf

aAdd( aCombo, "01=L100A" )
aAdd( aCombo, "02=L100B" )
aAdd( aCombo, "03=L100C" )
aAdd( aCombo, "04=L300A" )
aAdd( aCombo, "05=L300B" )
aAdd( aCombo, "06=L300C" )
aAdd( aCombo, "07=P100" )
aAdd( aCombo, "08=P150" )
aAdd( aCombo, "09=U100A" )
aAdd( aCombo, "10=U100B" )
aAdd( aCombo, "11=U100C" )
aAdd( aCombo, "12=U100D" )
aAdd( aCombo, "13=U100E" )
aAdd( aCombo, "14=U150A" )
aAdd( aCombo, "15=U150B" )
aAdd( aCombo, "16=U150C" )
aAdd( aCombo, "17=U150D" )
aAdd( aCombo, "18=U150E" )

oStruCH5:SetProperty( "CH5_TABECF", MVC_VIEW_COMBOBOX, aCombo )

oView:AddField( "VIEW_C1O", oStruC1O, "MODEL_C1O" )
oView:EnableTitleView( "VIEW_C1O", STR0001 ) //Cadastro de Plano de Contas Contábeis

oView:AddGrid( "VIEW_CH5", oStruCH5, "MODEL_CH5" )
oView:EnableTitleView( "VIEW_CH5", STR0002 ) //Cadastro de Plano Contas Referencial

oView:AddGrid( "VIEW_CHH", oStruCHH, "MODEL_CHH" )
oView:EnableTitleView( "VIEW_CHH", STR0005 ) //Cadastro de Subcontas Correlatas

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",40)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

oView:CreateHorizontalBox("PAINEL_INFERIOR",60)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR") 

oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0003) //"Plano Contas Referencial"
oView:CreateHorizontalBox("PAINEL_CH5",100,,,"FOLDER_INFERIOR","ABA01") //CH5

oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0004) //"Subcontas Correlatas"
oView:CreateHorizontalBox("PAINEL_CHH",100,,,"FOLDER_INFERIOR","ABA02") //CHH

oView:SetOwnerView( "VIEW_C1O", "PAINEL_PRINCIPAL" )
oView:SetOwnerView( "VIEW_CH5", "PAINEL_CH5" )
oView:SetOwnerView( "VIEW_CHH", "PAINEL_CHH" )

If ( "J050" $ Upper( FunDesc() ) )
	oStruC1O:RemoveField( "C1O_CTAREF" )
	oStruC1O:RemoveField( "C1O_DCTARE" )
	oStruC1O:RemoveField( "C1O_CNPJ" )
EndIf

If TamSX3("C1O_ID")[1]  == 36
	oStruC1O:RemoveField( "C1O_ID" )
	oStruC1O:RemoveField( "C1O_CTAREF" )
	oStruC1O:RemoveField( "C1O_CTASUP" )
	oStruCHH:RemoveField( "CHH_CNTCOR" )
EndIf

oStruCH5:RemoveField( "CH5_IDCTAR" )
oStruCHH:RemoveField( "CHH_IDNATC" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados

@return .T.

@author Paulo Sérgio V.B. Santana
@since 12/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		C1O->(dbSetorder(3))
		dbSeek( xFilial("C1O") + FWFLDGET("C1O_ID")) 
		If RecLock( "C1O", .F. )
			C1O->C1O_STATUS := ''
			C1O->(MsUnlock())
		EndIf
	Endif

	FwFormCommit( oModel )

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf060Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf060Vld( cAlias, nRecno, nOpc, lJob )

Local cChave		:=	""
Local cIdConta	:=	C1O->C1O_ID
Local cCH5Key		:=	""
Local cCodNat		:=	""
Local cTpContS	:=	""
Local cCodNat		:=	Posicione( "C2R", 3, xFilial( "C2R" ) + C1O->C1O_CODNAT, "C2R_CODIGO" ) //Código da Natureza
Local cNatSup		:=	"" //Código da Natureza da Conta Superior
Local cNivSup		:=	"" //Nível da Conta Superior
Local cContSup	:=	C1O->C1O_CTASUP //Conta Superior
Local cTpConRef	:=	""
Local cIndCta		:=	""
Local nContCdNt	:=	0
Local aLogErro	:=	{}
Local lExstCta	:=	.F.
Local lExstCdNt	:=	.F.

If C1O->C1O_STATUS $ ( " |1" )
     
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C1O->C1O_CODIGO)
		aAdd(aLogErro,{"C1O_CODIGO","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(C1O->C1O_DESCRI)
		aAdd(aLogErro,{"C1O_DESCRI","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(C1O->C1O_INDCTA)
		aAdd(aLogErro,{"C1O_INDCTA","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(C1O->C1O_NIVEL)
		aAdd(aLogErro,{"C1O_NIVEL","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(C1O->C1O_CODNAT)
		aAdd(aLogErro,{"C1O_CODNAT","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(C1O->C1O_DTALT)
		aAdd(aLogErro,{"C1O_DTALT","000001","C1O",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	//---------------------
	// Consultas padrão
	//---------------------
	
	If !Empty( C1O->C1O_CODNAT )
		cChave := C1O->C1O_CODNAT
		xVldECFTab( "C2R", cChave, 3,, @aLogErro, { "C1O", "C1O_CODNAT", nRecno } )
	EndIf
	
	//---------------------
	// Combos
	//---------------------
	If !(C1O->C1O_INDCTA $ ('0|1'))
		aAdd(aLogErro,{"C1O_INDCTA","000002","C1O",nRecno}) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
	EndIf

	If TAFColumnPos( "C1O_NATURE" ) .and. !Empty( C1O->C1O_NATURE ) .and. !( C1O->C1O_NATURE $ ( "1|2" ) )
		aAdd( aLogErro, { "C1O_NATURE", "000002", "C1O", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
	EndIf

	//---------------------
	// Regras específicas
	//---------------------
	
	If !Empty( cContSup )
	
		cChave := cContSup
		xVldECFTab( "C1O", cChave, 3,, @aLogErro, { "C1O", "C1O_CTASUP", nRecno } )

		If C1O->(dbSeek(xFilial("C1O")+cContSup))
			cTpContS:= C1O->C1O_INDCTA // Verifico O indicativo da conta
			cNatSup := Posicione("C2R",3,xFilial("C2R")+C1O->C1O_CODNAT,"C2R_CODIGO")
			cNivSup := C1O->C1O_NIVEL
		Endif	
		
		//Reposicionamento na tabela, pois validacao da conta superior, que fica na mesma tabela, desposicionou o registro
		C1O->( DBGoTo( nRecno ) )
		
	EndIf
		
	If Val(C1O->C1O_NIVEL) <= Val(cNivSup)
		aAdd(aLogErro,{"C1O_NIVEL","000038","C1O",nRecno}) //STR0038 - "O Nível da Conta deve ser maior que o Nível da Conta Superior" 
	EndIf
		
	If !Empty( C1O->C1O_CNPJ )
		If ( Len( AllTrim( C1O->C1O_CNPJ ) ) <> 14 ) .or. !CGC( C1O->C1O_CNPJ,, .F. )
			aAdd( aLogErro, { "C1O_CNPJ", "000006", "C1O", nRecno } ) //STR0006 - "CPF/CNPJ inconsistente."
		EndIf
	EndIf
	
	If Alltrim(C1O->C1O_NIVEL) == '1' .And. !Empty(C1O->C1O_CTASUP)
		aAdd(aLogErro,{"C1O_CTASUP","000034","C1O",nRecno}) //STR0034 - "Para contas com 'Nível da Conta' igual a '1', a 'Cta Superior' não se aplica."     
	EndIf  
	
	If (Val(C1O->C1O_NIVEL) > 1) 
					
		If Empty(C1O->C1O_CTASUP)
			aAdd(aLogErro,{"C1O_CTASUP","000008","C1O",nRecno}) //STR0008 - "Quando o campo Nível for maior que 1, é obrigatório preencher o campo Conta Sup."
		Else
			If cTpContS<>"0" 
				aAdd(aLogErro,{"C1O_CTASUP","000036","C1O",nRecno}) //STR0036- "Para Cadastro de Plano de Contas com Nível maior que '1' o Tipo da Conta Superior deve ser Sintético ('1')."
			Endif
			
			If (Val(C1O->C1O_NIVEL) > 2) .And. cNatSup<>cCodNat 
				aAdd(aLogErro,{"C1O_CODNAT","000037","C1O",nRecno}) //STR0037- "Para Plano de Contas com Nível maior que 2, o Codigo de Natureza da Conta Superior deve ser igual ao Codigo da Natureza da SubConta."
			Endif
		
		Endif
		
	EndIf
	
	//INICIO CH5
	CH5->( DBSetOrder(1) )
	
	cCH5Key := C1O->C1O_ID
	If CH5->( MsSeek( xFilial("CH5") + cCH5Key ) )

		Do While !CH5->( Eof() ) .And. cCH5Key == CH5->CH5_ID
			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CH5->CH5_IDCTAR)
				AADD(aLogErro,{"CH5_IDCTAR","000001","C1O", nRecno }) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf

			/*
			If Empty(CH5->CH5_CODCUS)
				AADD(aLogErro,{"CH5_CODCUS","000001","C1O", nRecno }) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf
			*/		

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(CH5->CH5_IDCTAR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CH5->CH5_IDCTAR
				xVldECFTab( "CHA", cChave, 1,, @aLogErro, { "C1O", "CH5_CTAREF", nRecno } )
			EndIf	

			If !Empty(CH5->CH5_CODCUS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CH5->CH5_CODCUS
				xVldECFTab( "C1P", cChave, 3,, @aLogErro, { "C1O", "CH5_CODCUS", nRecno } )
			EndIf	
			
			//---------------------
			// Regras específicas
			//---------------------
			dbSelectArea("CHA")
			CHA->(dbSetOrder(1))
			If dbSeek(xFilial("CHA") + CH5->CH5_IDCTAR)
				cTpConRef:= CHA->CHA_TPCTA
				cCodNat  := CHA->CHA_CODNAT
			Endif
			
			If cTpConRef<>'2'
				AADD(aLogErro,{"CH5_CTAREF","000039","C1O", nRecno }) //STR0039 - "A 'Conta Referencial' informada deve ser Sintetica"	
			Endif
			
			If cCodNat<>C1O->C1O_CODNAT
				AADD(aLogErro,{"CH5_CTAREF","000040","C1O", nRecno }) //STR0040 - "A 'Natureza' da conta referencial deve ser o mesmo do 'Plano de Contas'"	
			Endif

			CH5->( DbSkip() )
		EndDo
	Else
		cCodNat:= Posicione("C2R",3,xFilial("C2R")+C1O->C1O_CODNAT,"C2R_CODIGO")
		If C1O->C1O_INDCTA=='1' .And. cCodNat $ ("01|02|03|04")
			AADD(aLogErro,{"C1O_ID","000035","C1O", nRecno }) //STR0035 - "Deve existir ao menos um registro de Conta Referencial, para Plano de Contas do tipo Analítico e Codigo da Natureza igual a '01','02','03' ou '04'" 
		Endif
	EndIf
	//FIM CH5
	
	//INICIO CHH
	CHH->( DBSetOrder(1) )
	
	cCHHKey := C1O->C1O_ID
	If CHH->( MsSeek( xFilial("CHH") + cCHHKey ) )

		Do While ! CHH->( Eof() ) .And. cCHHKey == CHH->CHH_ID
			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CHH->CHH_CODGRU)
				AADD(aLogErro,{"CHH_CODGRU","000001","C1O", nRecno }) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If Empty(CHH->CHH_CNTCOR)
				AADD(aLogErro,{"CHH_CNTCOR","000001","C1O", nRecno }) //STR0001 - "Campo inconsistente ou vazio." 
			ElseIf !Empty(CHH->CHH_CNTCOR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CHH->CHH_CNTCOR	
				//Só realizo a validação da consulta padrão se a conta correlata for diferente da conta contabil
				If cChave <> cCHHKey
					xVldECFTab( "C1O", cChave, 3,, @aLogErro, { "C1O", "CHH_CNTCOR", nRecno } )
				EndIf
			EndIf	

			If Empty(CHH->CHH_IDNATC)
				AADD(aLogErro,{"CHH_NATCNT","000001","C1O", nRecno }) //STR0001 - "Campo inconsistente ou vazio." 
			ElseIf !Empty(CHH->CHH_IDNATC)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CHH->CHH_IDNATC
				xVldECFTab( "CHI", cChave, 1,, @aLogErro, { "C1O", "CHH_NATCNT", nRecno } )
			EndIf	
			
			//---------------------
			// Regras específicas
			//---------------------
			//REGRA_REGISTRO_PARA_CONTA_ANALITICA
			cIndCta:= Posicione("C1O",3,xFilial("C1O")+cCHHKey,"C1O_INDCTA")
			If cIndCta <> '1' 
				AADD(aLogErro,{"C1O_INDCTA","000229","C1O", nRecno }) //STR0229 - "O registro Subcontas Correlatas(J053) deve existir somente quando o Tipo da Conta Contábil for igual a 'A'-Analítica." 
			Endif
			
			//Verifica se a subconta correlata foi usada em mais de uma conta contábil num registro válido
			CHH->(DbSetOrder(3))
			
			cCntCorr:= CHH->CHH_CNTCOR			
			If CHH->( MsSeek( xFilial("CHH") + cCntCorr ) )			
				Do While ! CHH->( Eof() ) .And.	 cCntCorr == CHH->CHH_CNTCOR
			
					If	C1O->( MsSeek( xFilial("CHH") + CHH->CHH_ID ) )	
						If C1O->C1O_STATUS == "0"
							lExstCta := .T.	
						EndIf
					EndIf	
				
					CHH->( DbSkip() )	
				
				EndDo							
			EndIf

			//REGRA_COD_CTA_DUPLICIDADE 	
			If lExstCta
				AADD(aLogErro,{"CHH_CNTCOR","000230","C1O", nRecno }) //STR0230 - "A 'Subcta Corr' deve pertencer a uma única conta no plano de contas 'Código'(J050)."

				//REGRA_SUB_CONTA_PAI
				If C1O->( MsSeek( xFilial( "C1O" ) + cCntCorr ) )
					CHH->( DBSetOrder( 1 ) )
					If CHH->( MsSeek( xFilial( "CHH" ) + cCntCorr ) )
						aAdd( aLogErro,{ "CHH_CNTCOR", "000231", "C1O", nRecno } ) //STR0231 - "Essa conta(J050) possui registros filhos(J053) e já foi subconta em outro grupo 'Cod. Grupo'."
					EndIf
				EndIf
			EndIf

			//NAT_SUB_CNT REGRA_NAT_090_UNICA_POR_CONTA
			cCodNatSu := Posicione( "CHI", 1, xFilial( "CHI" ) + CHH->CHH_IDNATC, "CHI_CODIGO" )
			If cCodNatSu $ ( "90|91|92|93|95" )
				//Alteração, passou a ter no máximo duas contas de natureza.
				//Como não possui data, não será possível manter regra legado.
				If lExstCdNt
					aAdd( aLogErro, { "CHH_NATCNT", "000234", "C1O", nRecno } ) //STR0234 - "Deve existir somente uma 'Nat Subcta' '90' ou '91' ou '92' ou '93' ou '95' para cada conta(J050)."
				EndIf

				nContCdNt ++

				If nContCdNt >= 2
					lExstCdNt := .T.
				EndIf
			EndIf

			CHH->( DbSkip() )
		
		EndDo

	EndIf
	//FIM CHH
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//C1O->( MsSeek( xFilial("C1O") + cIdConta ) )
	C1O->( dbGoTo( nRecno ) )
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("C1O",.F.)
		C1O->C1O_STATUS := "1"
		MsUnlock()
	Else
		RecLock("C1O",.F.)
		C1O->C1O_STATUS := "0"
		MsUnlock()
	EndIf	

Else
	AADD(aLogErro,{"C1O_ID","000017", "C1O", nRecno })   //Registros válidos não podem ser validados novamente

EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )
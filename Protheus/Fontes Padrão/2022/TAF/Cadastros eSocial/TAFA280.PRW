#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA280.CH" 

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13

Static oReport     := Nil
Static __lGrvRPT   := Nil
Static cLayNmSpac  := ''
Static lLaySimplif := TAFLayESoc(, .T.)
Static lSimplBeta  := TAFLayESoc("S_01_01_00", .T., .T.)

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA280
Cadastro MVC de Trabalhadores Sem Vinculo de Emprego - Termino (S-2399)

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA280()

	Local aSeek       as array
	Local lFind       as logical
	Local aOnlyFields as array
	
	aSeek       := {}
	lFind       := .F.
	aOnlyFields := {"T92_FILIAL", "T92_ID", "T92_DTRABA", "T92_CPFV", "T92_MATV", "T92_DTERAV", "T92_DMOTDE", "T92_PROTUL"}

	Private oBrw :=	FwMBrowse():New()

	oBrw:SetCacheView(.F.)

	// Tratamento para a simplificação do e-Social
	If !lLaySimplif
		aAdd(aOnlyFields, "T92_NISV")
	EndIf

	If TAFAtualizado(.T., "TAFA280")

		If FindFunction("FilCpfNome") .And. GetSx3Cache("T92_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

			TafNewBrowse( "S-2399", "T92_DTERAV", "", 2, STR0001, aOnlyFields, 2 ) // Cria o browse com o novo painel e o botão de filtro por CPF/NOME/PERÍODO.

		Else

			oBrw:SetDescription( STR0001  ) //"Trabalhadores Sem Vínculo de Emprego - Término"
			oBrw:SetMenuDef( "TAFA280" )
			oBrw:SetAlias( "T92" )

			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("T92","TAFA280","S-2399"))
			Else
				oBrw:SetFilterDefault( "T92_ATIVO == '1'" )
			EndIf

			Aadd(aSeek,{"Filial",{||T92->T92_FILIAL},"C","@!",1,6,0,.F.,, } )
			oBrw:SetFields(aSeek)
			aSeek := {}

			Aadd(aSeek,{"Filial", {{"","C",6,0, "T92_FILIAL" ,"@!"}}, 1, .T. } )
			Aadd(aSeek,{"ID",     {{"","C",6,0, "T92_ID"     ,"@!"}}, 2, .T. } )
			Aadd(aSeek,{"Id Trab",{{"","C",6,0, "T92_TRABAL" ,"@!"}}, 3, .T. } )
			oBrw:SetSeek(.T.,aSeek)
			aSeek := {}

			TafLegend(2,"T92",@oBrw)

			DBSelectArea("C9V")
			C9V->( DBSetOrder( 6 ) )
			If MsSeek( xFilial( "C9V" ) + "S2300" + "1" )
				While C9V->(!Eof()) .And. lFind == .F.

					If C9V->C9V_STATUS = '4'
						lFind := .T.
					EndIf

					C9V->(DBSkip())
				EndDo

				If lFind
					oBrw:Activate()
				Else
					MsgAlert( STR0044 ) //"Não existem trabalhadores com status '4' transmitido."
				EndIf

			Else
				MsgAlert( STR0022 ) //"Não existem trabalhadores cadastrados, operação de alteração não pode ser realizada."
			EndIf
		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array
	
	aFuncao := {}
	aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("T92_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA280' OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TAFA280' OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.TAFA280' OPERATION 4 ACCESS 0 //'Alterar'

	Else

		Aadd( aFuncao, { "" , "TAF280XML" , "1" } )

		//Chamo a Browse do Histórico
		If FindFunction( "xFunNewHis" )
			Aadd( aFuncao, { "" , "xNewHisAlt( 'T92', 'TAFA280' )" , "3" } )
		Else
			Aadd( aFuncao, { "" , "xFunHisAlt( 'T92', 'TAFA280' )" , "3" } )
		EndIf

		Aadd( aFuncao, { "" , "TAFXmlLote( 'T92', 'S-2399' , 'evtTSVTermino' , 'TAF280Xml' )" , "5" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'T92' )" , "10" } )

		lMenuDIf := Iif( Type( "lMenuDIf" ) == "U", .F., lMenuDIf )

		If lMenuDIf
			ADD OPTION aRotina Title "Visualizar" Action "VIEWDEF.TAFA280" OPERATION 2 ACCESS 0 //"Visualizar"

			// Menu dos extemporâneos
			If FindFunction( "xFunNewHis" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
				aRotina	:= xMnuExtmp( "TAFA280", "T92" )
			EndIf
		Else
			aRotina	:=	xFunMnuTAF( "TAFA280", , aFuncao)
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   as object
	Local oStruT92 as object
	Local oStruC9J as object
	Local oStruCMK as object
	Local oStruT3I as object
	Local oStruV9O as object
	Local oStruT3J as object
	Local oStruT3H as object
	LocaL nIT15    as numeric
	Local oStruT15 as object
	Local oStruT16 as object

	oModel   := MpFormModel():New("TAFA280", , , { |oModel| SaveModel( oModel ) })
	oStruT92 := FwFormStruct( 1, "T92" )
	oStruC9J := FwFormStruct( 1, "C9J" )
	oStruCMK := FwFormStruct( 1, "CMK" )
	oStruT3I := FwFormStruct( 1, "T3I" )
	oStruT3J := FwFormStruct( 1, "T3J" )
	oStruT3H := FwFormStruct( 1, "T3H" )
	nIT15    := 0
	
	SetLayout()	

	oStruT15 	:= Iif(!lLaySimplif, FwFormStruct( 1, "T15" ), Nil) // Tratamento para simplificação do e-Social
	oStruT16 	:= Iif(!lLaySimplif, FwFormStruct( 1, "T16" ), Nil) // Tratamento para simplificação do e-Social
	oStruV9O	:= Iif(lSimplBeta, FwFormStruct( 1, "V9O" ), Nil)

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT92:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9J:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCMK:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT3I:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT3J:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT3H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })

		// Tratamento para a simplificação do e-Social
		If !lLaySimplif
			oStruT15:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruT16:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT92:SetProperty( "T92_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields( "MODEL_T92", /*cOwner*/, oStruT92 )

	oModel:AddGrid("MODEL_T3I", "MODEL_T92", oStruT3I)
	oModel:GetModel( "MODEL_T3I" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3I" ):SetUniqueLine( { "T3I_IDEDMD" } )
	oModel:GetModel('MODEL_T3I'):SetMaxLine(50)

	oModel:AddGrid("MODEL_C9J", "MODEL_T92", oStruC9J)
	oModel:GetModel( "MODEL_C9J" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_C9J" ):SetUniqueLine( { "C9J_TPINSC", "C9J_NRINSC" } )
	oModel:GetModel('MODEL_C9J'):SetMaxLine(999)

	oModel:AddGrid("MODEL_T3H", "MODEL_T92", oStruT3H)
	oModel:GetModel( "MODEL_T3H" ):SetOptional( .T. )

	// Tratamento para a simplificação do e-Social
	If !lLaySimplif	
		oModel:GetModel( "MODEL_T3H" ):SetUniqueLine( { "T3H_TPTRIB", "T3H_IDPROC" } )
	Else
		oModel:GetModel( "MODEL_T3H" ):SetUniqueLine( { "T3H_TPTRIB", "T3H_IDPROC", "T3H_IDSUSP" } )
	EndIf

	oModel:GetModel('MODEL_T3H'):SetMaxLine(99)

	If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
		oModel:AddGrid("MODEL_V9O", "MODEL_T3I", oStruV9O)
		oModel:GetModel( "MODEL_V9O" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V9O" ):SetUniqueLine( { "V9O_TPINSC", "V9O_NRINSC" } )
		oModel:GetModel('MODEL_V9O'):SetMaxLine(99)
	EndIf

	oModel:AddGrid("MODEL_T3J", "MODEL_T3I", oStruT3J)
	oModel:GetModel( "MODEL_T3J" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3J" ):SetUniqueLine( { "T3J_ESTABE", "T3J_LOTTRB" } )
	oModel:GetModel('MODEL_T3J'):SetMaxLine(10)

	oModel:AddGrid("MODEL_CMK", "MODEL_T3J", oStruCMK)
	oModel:GetModel( "MODEL_CMK" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_CMK" ):SetUniqueLine( { "CMK_CODRUB" } )
	oModel:GetModel('MODEL_CMK'):SetMaxLine(200)

	// Tratamento para a simplificação do e-Social
	If !lLaySimplif
		oModel:AddGrid("MODEL_T15", "MODEL_T3J", oStruT15)
		oModel:GetModel( "MODEL_T15" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T15" ):SetUniqueLine( { "T15_CNPJOP", "T15_REGANS" } )
		oModel:GetModel('MODEL_T15'):SetMaxLine(99)

		oModel:AddGrid("MODEL_T16", "MODEL_T15", oStruT16)
		oModel:GetModel( "MODEL_T16" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T16"):SetUniqueLine( { "T16_TPDEP", "T16_NOMDEP", "T16_DTNDEP" } )
		oModel:GetModel('MODEL_T16'):SetMaxLine(99)
	EndIf

	oModel:SetRelation("MODEL_C9J",{ {"C9J_FILIAL","xFilial('C9J')"}, {"C9J_ID","T92_ID"}, {"C9J_VERSAO","T92_VERSAO"}},C9J->(IndexKey(1)))
	oModel:SetRelation("MODEL_T3H",{ {"T3H_FILIAL","xFilial('T3H')"}, {"T3H_ID","T92_ID"}, {"T3H_VERSAO","T92_VERSAO"}},T3H->(IndexKey(1)))
	oModel:SetRelation("MODEL_T3I",{ {"T3I_FILIAL","xFilial('T3I')"}, {"T3I_ID","T92_ID"}, {"T3I_VERSAO","T92_VERSAO"}},T3I->(IndexKey(1)))
	If lSimplBeta .And. TafColumnPos("V9O_IDEDMD")
		oModel:SetRelation("MODEL_V9O",{ {"V9O_FILIAL","xFilial('V9O')"}, {"V9O_ID","T92_ID"}, {"V9O_VERSAO","T92_VERSAO"}, {"V9O_IDEDMD","T3I_IDEDMD"} },V9O->(IndexKey(1)))
	EndIf
	oModel:SetRelation("MODEL_T3J",{ {"T3J_FILIAL","xFilial('T3J')"}, {"T3J_ID","T92_ID"}, {"T3J_VERSAO","T92_VERSAO"}, {"T3J_IDEDMD","T3I_IDEDMD"} },T3J->(IndexKey(1)))
	oModel:SetRelation("MODEL_CMK",{ {"CMK_FILIAL","xFilial('CMK')"}, {"CMK_ID","T92_ID"}, {"CMK_VERSAO","T92_VERSAO"}, {"CMK_IDEDMD","T3I_IDEDMD"}, {"CMK_ESTABE","T3J_ESTABE"}, {"CMK_LOTTRB","T3J_LOTTRB"}},CMK->(IndexKey(1)))

	// Tratamento para a simplificação do e-Social
	If !lLaySimplif
		IIF(FWSIXUtil():ExistIndex( "T15", "4"),nIT15 := 4,nIT15 := 1)
		oModel:SetRelation("MODEL_T15",{ {"T15_FILIAL","xFilial('T15')"}, {"T15_ID","T92_ID"}, {"T15_VERSAO","T92_VERSAO"}, {"T15_RECIBO","T3I_IDEDMD"}, {"T15_ESTABE","T3J_ESTABE"}, {"T15_LOTACA","T3J_LOTTRB"}},T15->(IndexKey(nIT15)))
		oModel:SetRelation("MODEL_T16",{ {"T16_FILIAL","xFilial('T16')"}, {"T16_ID","T92_ID"}, {"T16_VERSAO","T92_VERSAO"}, {"T16_RECIBO","T3I_IDEDMD"}, {"T16_ESTABE","T3J_ESTABE"}, {"T16_LOTACA","T3J_LOTTRB"}, {"T16_CNPJOP","T15_CNPJOP"}, {"T16_REGANS","T15_REGANS"}},T16->(IndexKey(1)))
	EndIf

	oModel:GetModel( "MODEL_T92" ):SetPrimaryKey( { "T92_TRABAL" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    as object
	Local oView     as object
	Local oStruT92  as object
	Local oStruT92b as object
	Local oStruT92c as object
	Local oStruT92d as object
	Local oStruCMK  as object
	Local oStruT3I  as object
	Local oStruV9O	as object
	Local oStruT3J  as object
	Local oStruC9J  as object
	Local oStruT3H  as object
	Local oStruT15  as object
	Local oStruT16  as object
	
	Local cCmpTrab1 as character
	Local cCmpFil   as character
	Local cCmpT15   as character
	Local cCmpT16   as character
	Local cCmpT3H   as character
	Local cCmpC9J   as character
	
	oModel    := FWLoadModel( "TAFA280" )
	oView     := FWFormView():New()
	oStruT92  := FwFormStruct( 2, "T92" )
	oStruT92b := Nil
	oStruT92c := Nil
	oStruT92d := Nil
	oStruCMK  := FWFormStruct( 2, "CMK" )
	oStruT3I  := FWFormStruct( 2, "T3I" )
	oStruV9O  := Iif(lSimplBeta, FwFormStruct( 2, "V9O" ), Nil)
	oStruT3J  := FWFormStruct( 2, "T3J" )
	oStruC9J  := Nil
	oStruT3H  := Nil
	oStruT15  := Nil
	oStruT16  := NIl
	
	cCmpTrab1 := ""
	cCmpFil   := ""
	cCmpT15   := ""
	cCmpT16   := ""
	cCmpT3H   := ""
	cCmpC9J   := ""

	If lLaySimplif

		oStruT3J:RemoveField( "T3J_GRAUEX" )
		oStruT3J:RemoveField( "T3J_DGRAUE" )
		oStruCMK:RemoveField( "CMK_VLRUNI" )

		If lSimplBeta
			oStruT92:RemoveField( "T92_DTQUA" )
		Else
			
			If TafColumnPos("T92_INDREM")
				oStruT92:RemoveField( "T92_INDREM" )
				oStruT92:RemoveField( "T92_DTFREM" )
			EndIf

			If TafColumnPos("T3I_INDRRA")			
				oStruT3I:RemoveField( "T3I_INDRRA" )
				oStruT3I:RemoveField( "T3I_TPPRRA" )
				oStruT3I:RemoveField( "T3I_NRPRRA" )
				oStruT3I:RemoveField( "T3I_DESCRA" )
				oStruT3I:RemoveField( "T3I_QTMRRA" )
				oStruT3I:RemoveField( "T3I_VLRCUS" )
				oStruT3I:RemoveField( "T3I_VLRADV" )
			EndIf

		EndIf
	Else
		oStruCMK:SetProperty( "CMK_QTDRUB", MODEL_FIELD_TAMANHO, 7 )
		oStruCMK:RemoveField( "CMK_APURIR" )

		If TafColumnPos("T92_INDREM")
			oStruT92:RemoveField( "T92_INDREM" )
			oStruT92:RemoveField( "T92_DTFREM" )
		EndIf

		If TafColumnPos("T3I_INDRRA")			
			oStruT3I:RemoveField( "T3I_INDRRA" )
			oStruT3I:RemoveField( "T3I_TPPRRA" )
			oStruT3I:RemoveField( "T3I_NRPRRA" )
			oStruT3I:RemoveField( "T3I_DESCRA" )
			oStruT3I:RemoveField( "T3I_QTMRRA" )
			oStruT3I:RemoveField( "T3I_VLRCUS" )
			oStruT3I:RemoveField( "T3I_VLRADV" )
		EndIf
	EndIf

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/
	If lSimplBeta .and. TafColumnPos("T92_INDREM")
		cCmpTrab1 := "T92_ID|T92_TRABAL|T92_DTRABA|T92_DTERAV|T92_MOTDES|T92_PENALI|T92_PERALI|T92_VLPALI|T92_DMOTDE|T92_VERANT|T92_NEWCPF|T92_INDREM|T92_DTFREM|"                    
	Else    
		cCmpTrab1 := "T92_ID|T92_TRABAL|T92_DTRABA|T92_DTERAV|T92_MOTDES|T92_PENALI|T92_PERALI|T92_VLPALI|T92_DMOTDE|T92_DTQUA|T92_VERANT|T92_NEWCPF|"                    
	EndIf

	// Tratamento para a simplificação do e-Social
	If lLaySimplif
		cCmpTrab1 += "T92_TPGUIA|T92_NRPROC|"
	EndIf

	cCmpFil   := cCmpTrab1
	oStruT92a := FwFormStruct( 2, "T92", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder do número do ultimo protocolo
	cCmpFil := 'T92_PROTUL|' 
	oStruT92b := FwFormStruct( 2, 'T92', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil   := "T92_INDMVI|"
	oStruT92c := FwFormStruct( 2, "T92", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("T92_DTRANS")
		cCmpFil   := "T92_DINSIS|T92_DTRANS|T92_HTRANS|T92_DTRECP|T92_HRRECP|"
		oStruT92d := FwFormStruct( 2, "T92",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial
	EndIf

	// Tratamento para simplificação do e-Social
	If !lLaySimplif
		/*-----------------------------------------------------------------------------------
							Estrutura da View Operadoras de Saude
		-------------------------------------------------------------------------------------*/
		cCmpT15  	:= "T15_CNPJOP|T15_REGANS|T15_VLPGTI|"
		oStruT15	:= FwFormStruct( 2, "T15", { |x| AllTrim( x ) + "|" $ cCmpT15 } )

		/*-----------------------------------------------------------------------------------
							Estrutura da View Dependentes
		-------------------------------------------------------------------------------------*/
		cCmpT16  	:= "T16_SEQUEN|T16_TPDEP|T16_DTPDE|T16_CPFDEP|T16_NOMDEP|T16_DTNDEP|T16_VPGDEP|"
		oStruT16	:= FwFormStruct( 2, "T16", { |x| AllTrim( x ) + "|" $ cCmpT16 } )
		oStruT16:SetProperty( "T16_SEQUEN"	, MVC_VIEW_ORDEM, "01" )
		oStruT16:SetProperty( "T16_TPDEP"	, MVC_VIEW_ORDEM, "02" )
		oStruT16:SetProperty( "T16_DTPDE"	, MVC_VIEW_ORDEM, "03" )
		oStruT16:SetProperty( "T16_NOMDEP"	, MVC_VIEW_ORDEM, "04" )
		oStruT16:SetProperty( "T16_DTNDEP"	, MVC_VIEW_ORDEM, "05" )
	EndIf

	/*-----------------------------------------------------------------------------------
						Estrutura da View Processo Judiciario
	-------------------------------------------------------------------------------------*/
	cCmpT3H  	:= " T3H_TPTRIB|T3H_IDPROC|T3H_NRPROC|T3H_CODSUS|"
	oStruT3H	:= FwFormStruct( 2, "T3H", { |x| AllTrim( x ) + "|" $ cCmpT3H } )

	/*-----------------------------------------------------------------------------------
						Estrutura da View Remuneração Outra Empresa
	-------------------------------------------------------------------------------------*/
	cCmpC9J 	:= "C9J_TPINSC|C9J_NRINSC|C9J_CODCAT|C9J_DCODCA|C9J_VLREMU|"
	oStruC9J	:= FwFormStruct( 2, "C9J", { |x| AllTrim( x ) + "|" $ cCmpC9J } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT92b,"T92")
	EndIf

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_T92a", oStruT92a, "MODEL_T92")
	oView:EnableTitleView("VIEW_T92a",STR0028) //"Identificação do Trabalhador"

	oView:AddGrid ( 'VIEW_T3I' , oStruT3I,  'MODEL_T3I')
	oView:EnableTitleView("VIEW_T3I",STR0031) //IdentIficação dos demonstrativos dos pagamentos

	oView:AddGrid ( 'VIEW_C9J' , oStruC9J,  'MODEL_C9J')
	oView:EnableTitleView("VIEW_C9J",STR0032) //"Remuneração de Outra Empresa"

	oView:AddGrid ( 'VIEW_T3H' , oStruT3H,  'MODEL_T3H')
	oView:EnableTitleView("VIEW_T3H",STR0033) //"Informações de processos judiciais do trabalhador"

	If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
		oView:AddGrid( 'VIEW_V9O' , oStruV9O,  'MODEL_V9O')
		oView:EnableTitleView("VIEW_V9O", STR0045)
	EndIf

	oView:AddGrid ( 'VIEW_T3J' , oStruT3J,  'MODEL_T3J')
	oView:EnableTitleView("VIEW_T3J",STR0034) //"IdentIficação do Estabelecimento/Lotação"

	oView:AddGrid ( 'VIEW_CMK' , oStruCMK,  'MODEL_CMK')

	// Tratamento para simplificação do e-Social
	If !lLaySimplif
		oView:AddGrid ( 'VIEW_T15' , oStruT15,  'MODEL_T15')
		oView:EnableTitleView("VIEW_T15",STR0035) //"Operadoras de Planos de Saúde"

		oView:AddGrid ( 'VIEW_T16' , oStruT16,  'MODEL_T16')
		oView:EnableTitleView("VIEW_T16",STR0036) //"Dependente do Plano Privado de Saúde"
		oView:AddIncrementField( 'VIEW_T16', 'T16_SEQUEN' ) 
	EndIf

	oView:AddField("VIEW_T92b", oStruT92b, 'MODEL_T92')
	If TafColumnPos("T1U_PROTUL")
		oView:EnableTitleView( 'VIEW_T92b', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf

	oView:AddField("VIEW_T92c", oStruT92c, 'MODEL_T92')

	If TafColumnPos("T92_DTRANS")
		oView:AddField("VIEW_T92d", oStruT92d, 'MODEL_T92')
		oView:EnableTitleView( 'VIEW_T92d', TafNmFolder("recibo",2) )
	EndIf

	/*-----------------------------------------------------------------------------------
								Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 100 )

	oView:CreateFolder( 'FOLDER_GERAL', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_GERAL', 'ABA01', STR0037 ) //"Identificação do TSV"
	oView:AddSheet( 'FOLDER_GERAL', 'ABA02', STR0038 ) //"Verbas Rescisórias"

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_GERAL', "ABA03", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_GERAL', 'ABA03', STR0039 ) //"Protocolo de Transmissão"
	EndIf

	//Aba 1
	oView:CreateHorizontalBox( 'PAINEL_INFOIMV', 100,,, 'FOLDER_GERAL', 'ABA01' ) //"Informações do Término"/"Informações de Multiplus Vínculos"

	oView:CreateFolder( 'FOLDER_INFOIMV', 'PAINEL_INFOIMV' )

	oView:AddSheet( "FOLDER_INFOIMV", "ABA01", STR0040 ) //"Informações do Trabalhador/Término"
	oView:CreateHorizontalBox( "T92a",100,,, "FOLDER_INFOIMV" , "ABA01" )

	oView:AddSheet( "FOLDER_INFOIMV", "ABA02", STR0030 ) //Informações de Multiplus Vínculos
	oView:CreateHorizontalBox( "T92c",015,,, "FOLDER_INFOIMV" , "ABA02" ) //Indicador de Multiplus Vínculos
	oView:CreateHorizontalBox( "C9J" ,085,,, "FOLDER_INFOIMV" , "ABA02" ) //"Remuneração de Outra Empresa"

	//Aba 2
	oView:CreateHorizontalBox( 'PAINEL_VR', 100,,, 'FOLDER_GERAL', 'ABA02' ) //"Informações do Término"/"Informações de Multiplus Vínculos"

	oView:CreateFolder( 'FOLDER_VR', 'PAINEL_VR' )

	oView:AddSheet( 'FOLDER_VR', 'ABA01', STR0041 )//"Informações de processos judiciais do trabalhador"
	oView:CreateHorizontalBox( "T3H", 100,,, "FOLDER_VR" , "ABA01" )

	oView:AddSheet( 'FOLDER_VR', 'ABA02', STR0038 )//"Verbas Rescisórias do Trabalhador"
	oView:CreateHorizontalBox( "T3I", 030,,, "FOLDER_VR" , "ABA02" )

	If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
		oView:CreateHorizontalBox("PAINEL_RRA",070,,,"FOLDER_VR","ABA02")
		
		oView:CreateFolder( 'FOLDER_RRA', 'PAINEL_RRA' )
		oView:AddSheet( 'FOLDER_RRA', 'ABA01', STR0046 )
		oView:CreateHorizontalBox( "V9O", 050,,, "FOLDER_RRA" , "ABA01" )
		oView:AddSheet( 'FOLDER_RRA', 'ABA02', STR0047 ) 
		oView:CreateHorizontalBox( "T3J", 020,,, "FOLDER_RRA" , "ABA02" )		

		oView:CreateHorizontalBox("PAINEL_RUBOPE",030,,,"FOLDER_RRA","ABA02") //Rubricas/Operadoras de Saude
	Else
		oView:CreateHorizontalBox( "T3J", 030,,, "FOLDER_VR" , "ABA02" )
		oView:CreateHorizontalBox("PAINEL_RUBOPE",040,,,"FOLDER_VR","ABA02") //Rubricas/Operadoras de Saude
	EndIf

	oView:CreateFolder( 'FOLDER_RUBOPE', 'PAINEL_RUBOPE' )
	oView:AddSheet( 'FOLDER_RUBOPE', 'ABA01', STR0042 ) //"Informações Relativas às Verbas Rescisórias do Trabalhador"
	oView:CreateHorizontalBox( 'CMK', 100,,, 'FOLDER_RUBOPE'  , 'ABA01' )

	// Tratamento para simplificação do e-Social
	If !lLaySimplif
		oView:AddSheet( 'FOLDER_RUBOPE', 'ABA02', STR0043 ) //"Informações de Plano Privado Coletivo Empresarial de Assistência à Saúde"
		oView:CreateHorizontalBox( 'T15', 050,,, 'FOLDER_RUBOPE'  , 'ABA02' )
		oView:CreateHorizontalBox( 'T16', 050,,, 'FOLDER_RUBOPE'  , 'ABA02' )
	EndIf

	//Aba 3
	If TafColumnPos("T92_DTRANS")
		oView:CreateHorizontalBox( "T92b",20,,, "FOLDER_GERAL" , "ABA03" )
		oView:CreateHorizontalBox( "T92d",80,,, "FOLDER_GERAL" , "ABA03" )
	Else
		oView:CreateHorizontalBox( "T92b",100, , , "FOLDER_GERAL", "ABA03" )
	EndIf

	/*-----------------------------------------------------------------------------------
							Amarracao para exibicao das informacoes
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_T92a"	, "T92a")
	oView:SetOwnerView( "VIEW_C9J"	, "C9J")
	oView:SetOwnerView( "VIEW_T3I"	, "T3I")
	oView:SetOwnerView( "VIEW_T3H"	, "T3H")
	If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
		oView:SetOwnerView( "VIEW_V9O"	, "V9O")
	EndIf
	oView:SetOwnerView( "VIEW_T3J"	, "T3J")
	oView:SetOwnerView( "VIEW_CMK"	, "CMK")
	oView:SetOwnerView( "VIEW_T92b"	, "T92b")
	oView:SetOwnerView( "VIEW_T92c"	, "T92c")
	If TafColumnPos("T92_DTRANS")
		oView:SetOwnerView( "VIEW_T92d"	, "T92d")
	EndIf

	// Tratamento para simplificação do e-Social
	If !lLaySimplif
		oView:SetOwnerView( "VIEW_T15"	, "T15")
		oView:SetOwnerView( "VIEW_T16"	, "T16")
	EndIf

	///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
	lMenuDIf := Iif( Type( "lMenuDIf" ) == "U", .F., lMenuDIf )

	If !lMenuDIf
		xFunRmFStr(@oStruT92a,"T92")

		oStruT3H:RemoveField('T3H_IDSUSP')
		oStruT3I:RemoveField('T3I_ID')
		oStruT3I:RemoveField('T3I_VERSAO')
		oStruT3J:RemoveField('T3J_ID')
		oStruT3J:RemoveField('T3J_VERSAO')
		oStruT3J:RemoveField('T3J_IDEDMD')
		oStruCMK:RemoveField('CMK_LOTTRB')
		oStruCMK:RemoveField('CMK_IDEDMD')
	EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVersao    as character
	Local cChvRegAnt as character
	Local cStatAlt   as character
	Local cLogOpe    as character
	Local cLogOpeAnt as character
	Local nOperation as numeric
	Local aGrava     as array
	Local aGravaT3H  as array
	Local aGravaC9J  as array
	Local aGravaT3I  as array
	Local aGravaV9O  as array
	Local aGravaT3J  as array
	Local aGravaCMK  as array
	Local aGravaT15  as array
	Local aGravaT16  as array
	Local oModelT92  as object
	Local oModelC9J  as object
	Local oModelT3H  as object
	Local oModelT3I  as object
	Local oModelT3J  as object
	Local oModelCMK  as object
	Local oModelT15  as object
	Local oModelT16  as object
	Local oModelV9O  as object
	Local lInclui    as logical
	Local lRetorno   as logical

	//Relatório de Conferência de Valores
	Local oInfoRPT   as object
	Local cPeriodo   as character
	Local cCPF       as character
	Local cNome      as character
	Local lInfoRPT   as logical

	Default oModel := Nil

	cVersao        := ""
	cChvRegAnt     := ""
	cStatAlt       := ""
	cLogOpe        := ""
	cLogOpeAnt     := ""

	nOperation     := oModel:GetOperation()

	aGrava    := {}
	aGravaT3H := {}
	aGravaC9J := {}
	aGravaT3I := {}
	aGravaV9O := {}
	aGravaT3J := {}
	aGravaCMK := {}
	aGravaT15 := {}
	aGravaT16 := {}

	oModelT92 := oModel:GetModel( "MODEL_T92" )
	oModelC9J := oModel:GetModel( "MODEL_C9J" )
	oModelT3H := oModel:GetModel( "MODEL_T3H" )
	oModelT3I := oModel:GetModel( "MODEL_T3I" )

	If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
		oModelV9O := oModel:GetModel( "MODEL_V9O" )
	Else
		oModelV9O := Nil
	EndIf
	
	oModelT3J := oModel:GetModel( "MODEL_T3J" )
	oModelCMK := oModel:GetModel( "MODEL_CMK" )
	oModelT15 := oModel:GetModel( "MODEL_T15" )
	oModelT16 := oModel:GetModel( "MODEL_T16" )

	oInfoRPT       := Nil
	cPeriodo       := ""
	cCPF           := ""
	cNome          := ""
	lInfoRPT       := .F.

	lInclui        := ( nOperation == MODEL_OPERATION_INSERT )
	lRetorno       := .T.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If __lGrvRPT == Nil
			TAF280Rpt() //Inicializa a variável static __lGrvRPT
		EndIf

		lInfoRPT := __lGrvRPT

		//Realiza a exclusão do registro da tabela do relatório
		If lInfoRPT
			cPeriodo	:=	SubStr( DToS( oModel:GetValue("MODEL_T92","T92_DTERAV") ), 1, 6 )
			cCPF		:=	GetADVFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + oModel:GetValue("MODEL_T92","T92_TRABAL") + "1", 2, "", .T. )
			cNome		:=	GetADVFVal( "C9V", "C9V_NOME", xFilial( "C9V" ) + oModel:GetValue("MODEL_T92","T92_TRABAL") + "1", 2, "", .T. )

			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

			oInfoRPT := oReport:oVOReport
			oInfoRPT:SetIndApu( "1" )
			oInfoRPT:SetPeriodo( cPeriodo )
			oInfoRPT:SetCPF( AllTrim( cCPF ) )
			oInfoRPT:SetNome(cNome )

		EndIf

		If 	lInclui

			TafAjustID( "T92", oModel)

			cVersao := xFunGetVer()
			oModel:LoadValue( "MODEL_T92", "T92_VERSAO", cVersao )
			oModel:LoadValue( "MODEL_T92", "T92_STATUS", "" )

			If TafColumnPos("T92_LAYOUT")
				oModel:LoadValue( "MODEL_T92", "T92_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T92', 'T92_LOGOPE' , '2', '' )
			Endif

			If FwFormCommit( oModel )
				If lInfoRPT
					aAnalitico := LoadReportData(oModel, lInfoRPT)
					oInfoRPT:SetAnalitico(aAnalitico)
					oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT )
				EndIf
			EndIf

		//Alteracao ou exclusao manual do evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//Posicionando no registro para que nao ocorra erros durante o processo de validacao
			T92->( DBSetOrder( 2 ) )
			If lGoExtemp .OR. T92->( MsSeek( xFilial( "T92" ) + M->T92_ID + "1" ) )

				//VerIfica se o evento ja foi trasmitido ao RET
				If T92->T92_STATUS $ ( "4" )
					cStatAlt := "4"

					If TafColumnPos( "T92_LOGOPE" )
						cLogOpeAnt := T92->T92_LOGOPE
					EndIf

					If TafColumnPos("T92_LAYOUT")
						oModel:LoadValue( "MODEL_T92", "T92_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
					EndIf

					//Funcao para carregar os valores correntes do cadastro
		 			TAF280Carr( oModel, oModelT92,oModelC9J, oModelT3H, oModelT3I, oModelT3J, oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H, aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, oModelV9O, aGravaV9O )

					//Seto o registro corrente como Inativo
					FAltRegAnt( "T92", "2" )

					//Esta funcao desativa o model corrente e inicia a operacao de inclusao das operacoes realizadas
					TAF280Comm( oModel, oModelT92,oModelC9J, oModelT3H, oModelT3I, oModelT3J, oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H, aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, .T., cStatAlt, oModelV9O, aGravaV9O )

				ElseIf T92->T92_STATUS == ( "2" )
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				ElseIf T92->T92_STATUS == ( "6" )
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno := .F.
				Else
					//alteração sem transmissão
					If TafColumnPos( "T92_LOGOPE" )
						cLogOpeAnt := T92->T92_LOGOPE
					EndIf

					If TafColumnPos("T92_LAYOUT")
						oModel:LoadValue( "MODEL_T92", "T92_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
					EndIf

				EndIf

				If lRetorno
					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T92', 'T92' )
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T92', 'T92_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					If FwFormCommit( oModel )
						If lInfoRPT
							aAnalitico := LoadReportData(oModel, lInfoRPT)
							oInfoRPT:SetAnalitico(aAnalitico)
							oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT )
						EndIf
					EndIf

					TAFAltStat( "T92", " " )
				EndIf
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			If T92->T92_STATUS == "4" .AND. T92_EVENTO == "E"
				TAFMsgVldOp(oModel,"4")//"Registro não pode ser excluído, pois o evento de exclusão já se encontra base do RET"
				lRetorno := .F.

			ElseIf T92->T92_STATUS == "7" .AND. T92_EVENTO == "E"
	     		TAFMsgVldOp(oModel,"4")//"Registro não pode ser excluído, pois o evento de exclusão já se encontra base do RET"
				lRetorno := .F.
			Else

				cChvRegAnt := T92->(T92_ID + T92_VERANT)
				If !Empty( cChvRegAnt )
					TAFAltStat( 'T92', " " )
					If FwFormCommit( oModel )
						If lInfoRPT
							oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT, .T. )
						EndIf
					EndIf
					If nOperation == MODEL_OPERATION_DELETE
						If T92->T92_EVENTO == "A" .Or. T92->T92_EVENTO == "E"
							TAFRastro( 'T92', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
						EndIf
					EndIf
				Else
					oModel:DeActivate()
					oModel:SetOperation( 5 )
					oModel:Activate()
					If FwFormCommit( oModel )
						If lInfoRPT
							oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT, .T. )
						EndIf
					EndIf
				EndIf

			EndIf

		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF280Carr
Funcao que armazena nos arrays as informacoes correntes do cadastro

@Param

oModelT92 - Model da tabela T92
oModelT92 - Model da tabela T92
oModelCMK - Model da tabela CMK
aGrava    - Array que armazena as informacoes da tabela T92
aGravaT92 - Array que armazena as informacoes da tabela T92
aGravaCMK - Array que armazena as informacoes da tabela CMK

@Return .T.

@Author Felipe C. Seolin
@Since 04/02/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF280Carr( oModel, oModelT92, oModelC9J, oModelT3H, oModelT3I, oModelT3J,;
							oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H,;
							aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, oModelV9O,;
							aGravaV9O )

	Local nI   as numeric
	Local nT3I as numeric
	Local nT3H as numeric
	Local nV9O as numeric
	Local nT3J as numeric
	Local nC9J as numeric
	Local nCMK as numeric
	Local nT15 as numeric
	Local nT16 as numeric

	Default oModel    := Nil
	Default oModelT92 := Nil
	Default oModelC9J := Nil
	Default oModelT3H := Nil
	Default oModelT3I := Nil
	Default oModelV9O := Nil
	Default oModelT3J := Nil
	Default oModelCMK := Nil
	Default oModelT15 := Nil
	Default oModelT16 := Nil
	Default aGrava    := {}
	Default aGravaC9J := {}
	Default aGravaT3H := {}
	
	Default aGravaT3I := {}
	Default aGravaV9O := {}
	Default aGravaT3J := {}
	Default aGravaCMK := {}
	Default aGravaT15 := {}
	Default aGravaT16 := {}

	nI                := 0
	nT3I              := 0
	nT3H              := 0
	nV9O			  := 0
	nT3J              := 0
	nC9J              := 0
	nCMK              := 0
	nT15              := 0
	nT16              := 0

	For nI := 1 to Len( oModelT92:aDataModel[1] )
		aAdd( aGrava, { oModelT92:aDataModel[1,nI,1], oModelT92:aDataModel[1,nI,2] } )
	Next nI

	For nT3I := 1 to oModel:GetModel( "MODEL_T3I" ):Length()
		oModel:GetModel( "MODEL_T3I" ):GoLine(nT3I)
		If !oModel:GetModel( "MODEL_T3I" ):IsDeleted()			

			If lSimplBeta .And. TafColumnPos("T3I_INDRRA")
				aAdd(aGravaT3I,{oModelT3I:GetValue("T3I_IDEDMD"),;
								oModelT3I:GetValue("T3I_INDRRA"),;
								oModelT3I:GetValue("T3I_TPPRRA"),;
								oModelT3I:GetValue("T3I_NRPRRA"),;
								oModelT3I:GetValue("T3I_DESCRA"),;
								oModelT3I:GetValue("T3I_QTMRRA"),;
								oModelT3I:GetValue("T3I_VLRCUS"),;
								oModelT3I:GetValue("T3I_VLRADV")})
			Else
				aAdd(aGravaT3I,{oModelT3I:GetValue("T3I_IDEDMD")})				

			EndIf

			If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
				For nV9O := 1 to oModel:GetModel( "MODEL_V9O" ):Length()
					oModel:GetModel( "MODEL_V9O" ):GoLine(nV9O)
					If !oModel:GetModel( "MODEL_V9O" ):IsEmpty()
						If !oModel:GetModel( "MODEL_V9O" ):IsDeleted()

							aAdd(aGravaV9O ,{oModelT3I:GetValue("T3I_IDEDMD"),;				
											  oModelV9O:GetValue("V9O_VLRADV"),;
											  oModelV9O:GetValue("V9O_TPINSC"),;
											  oModelV9O:GetValue("V9O_NRINSC")})
						EndIf
					EndIf
				Next //nV9O
			EndIf

			For nT3J := 1 to oModel:GetModel( "MODEL_T3J" ):Length()
				oModel:GetModel( "MODEL_T3J" ):GoLine(nT3J)
				If !oModel:GetModel( "MODEL_T3J" ):IsEmpty()
					If !oModel:GetModel( "MODEL_T3J" ):IsDeleted()

							// Tratamento para simplificação do e-Social
							If !lLaySimplif
								aAdd (aGravaT3J ,{oModelT3I:GetValue("T3I_IDEDMD"),;
													oModelT3J:GetValue('T3J_ESTABE'),;
													oModelT3J:GetValue("T3J_LOTTRB"),;
													oModelT3J:GetValue('T3J_GRAUEX'),;
													oModelT3J:GetValue('T3J_INDCSU')})
							Else
								aAdd (aGravaT3J ,{oModelT3I:GetValue("T3I_IDEDMD"),;
													oModelT3J:GetValue('T3J_ESTABE'),;
													oModelT3J:GetValue("T3J_LOTTRB"),;
													oModelT3J:GetValue('T3J_INDCSU')})
							EndIf

						For nCMK := 1 to oModel:GetModel( "MODEL_CMK" ):Length()
								oModel:GetModel( "MODEL_CMK" ):GoLine(nCMK)
							If !oModel:GetModel( "MODEL_CMK" ):IsEmpty()
								If !oModel:GetModel( "MODEL_CMK" ):IsDeleted()

										// Tratamento para a simplificação do e-Social
										If !lLaySimplif
											aAdd (aGravaCMK ,{oModelT3I:GetValue("T3I_IDEDMD"),;
																oModelT3J:GetValue("T3J_ESTABE"),;
																oModelT3J:GetValue('T3J_LOTTRB'),;
																oModelCMK:GetValue('CMK_CODRUB'),;
																oModelCMK:GetValue('CMK_QTDRUB'),;
																oModelCMK:GetValue('CMK_VLRUNI'),;
																oModelCMK:GetValue('CMK_VLRRUB'),;
																oModelCMK:GetValue('CMK_FATORR')})	
										Else
											aAdd (aGravaCMK ,{oModelT3I:GetValue("T3I_IDEDMD"),;
																oModelT3J:GetValue("T3J_ESTABE"),;
																oModelT3J:GetValue('T3J_LOTTRB'),;
																oModelCMK:GetValue('CMK_CODRUB'),;
																oModelCMK:GetValue('CMK_QTDRUB'),;
																oModelCMK:GetValue('CMK_VLRRUB'),;
																oModelCMK:GetValue('CMK_FATORR'),;
																oModelCMK:GetValue('CMK_APURIR')})
										EndIf

								EndIf
							EndIf
						Next //nCMK

						// Tratamento para a simplificação do e-Social
						If !lLaySimplif
							For nT15 := 1 to oModel:GetModel( "MODEL_T15" ):Length()
									oModel:GetModel( "MODEL_T15" ):GoLine(nT15)
								If !oModel:GetModel( "MODEL_T15" ):IsEmpty()
									If !oModel:GetModel( "MODEL_T15" ):IsDeleted()

											aAdd (aGravaT15 ,{oModelT3I:GetValue("T3I_IDEDMD"),;
																oModelT3J:GetValue("T3J_ESTABE"),;
																oModelT3J:GetValue('T3J_LOTTRB'),;
																oModelT15:GetValue('T15_CNPJOP'),;
																oModelT15:GetValue('T15_REGANS'),;
																oModelT15:GetValue('T15_VLPGTI')})

										For nT16 := 1 to oModel:GetModel( "MODEL_T16" ):Length()
												oModel:GetModel( "MODEL_T16" ):GoLine(nT16)
											If !oModel:GetModel( "MODEL_T16" ):IsEmpty()
												If !oModel:GetModel( "MODEL_T16" ):IsDeleted()
														aAdd (aGravaT16 ,{oModelT3I:GetValue("T3I_IDEDMD"),;
																			oModelT3J:GetValue("T3J_ESTABE"),;
																			oModelT3J:GetValue('T3J_LOTTRB'),;
																			oModelT15:GetValue('T15_CNPJOP'),;
																			oModelT16:GetValue('T16_SEQUEN'),;
																			oModelT16:GetValue('T16_TPDEP' ),;
																			oModelT16:GetValue('T16_CPFDEP'),;
																			oModelT16:GetValue('T16_NOMDEP'),;
																			oModelT16:GetValue('T16_DTNDEP'),;
																			oModelT16:GetValue('T16_VPGDEP')})
												EndIf
											EndIf
										Next //nT16

									EndIf
								EndIf
							Next //nT15
						EndIf

					EndIf
				EndIf
			Next //nT3J

		EndIf
	Next //nT3I

	For nT3H := 1 to oModel:GetModel( "MODEL_T3H" ):Length()
						  oModel:GetModel( "MODEL_T3H" ):GoLine(nT3H)
		If !oModel:GetModel( "MODEL_T3H" ):IsEmpty()
			If !oModel:GetModel( "MODEL_T3H" ):IsDeleted()
				aAdd (aGravaT3H ,{oModelT3H:GetValue("T3H_TPTRIB"),;
									   	oModelT3H:GetValue('T3H_IDPROC'),;
									   	oModelT3H:GetValue('T3H_IDSUSP'),;
									   	"S2399"})
			EndIf
		EndIf
	Next//nT3H

	For nC9J := 1 to oModel:GetModel( "MODEL_C9J" ):Length()
					   oModel:GetModel( "MODEL_C9J" ):GoLine(nC9J)
		If !oModel:GetModel( "MODEL_C9J" ):IsEmpty()
			If !oModel:GetModel( "MODEL_C9J" ):IsDeleted()
					aAdd (aGravaC9J ,{oModelC9J:GetValue("C9J_TPINSC"),;
										oModelC9J:GetValue("C9J_NRINSC"),;
										oModelC9J:GetValue("C9J_CODCAT"),;
										oModelC9J:GetValue("C9J_VLREMU")})
			EndIf
		EndIf
	Next//nC9J

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF280Comm
Funcao que realiza a gravacao das informacoes

@Param

oModel    - Model que esta sendo editado
oModelT92 - Model da tabela T92
oModelCMK - Model da tabela CMK
aGrava    - Array que armazena as informações da tabela T92
aGravaCMK - Array que armazena as informações da tabela CMK
lFirsOpe  - Indica se a operacao que esta sendo realizada se refere a uma inclusao, neste caso os campos
			de controle de rastro nao devem ser gravados

@Return .T.

@Author Felipe C. Seolin
@Since 04/02/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF280Comm( oModel, oModelT92, oModelC9J, oModelT3H, oModelT3I, oModelT3J,;
							oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H,;
							aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, lFirsOpe,;
							cStatAlt, oModelV9O, aGravaV9O )

	Local cVersao    as character
	Local cVerAnt    as character
	Local cProtocolo as character
	Local cEvento    as character

	Local nI         as numeric
	Local nT3I       as numeric
	Local nT3H       as numeric
	Local nV9O       as numeric
	Local nT3J       as numeric
	Local nC9J       as numeric
	Local nCMK       as numeric
	Local nT15       as numeric
	Local nT16       as numeric

	Local nV9OAdd    as numeric
	Local nT3JAdd    as numeric
	Local nCMKAdd    as numeric
	Local nT15Add    as numeric
	Local nT16Add    as numeric
	Local nIJAdd     as numeric
	Local nIKAdd     as numeric

	Default oModel    := Nil
	Default oModelT92 := Nil
	Default oModelC9J := Nil
	Default oModelT3H := Nil
	Default oModelT3I := Nil
	Default oModelT3J := Nil
	Default oModelCMK := Nil
	Default oModelT15 := Nil
	Default oModelT16 := Nil
	Default oModelV9O := Nil

	Default aGrava    := {}
	Default aGravaC9J := {}
	Default aGravaT3H := {}
	Default aGravaT3I := {}
	Default aGravaT3J := {}
	Default aGravaCMK := {}
	Default aGravaT15 := {}
	Default aGravaT16 := {}
	Default aGravaV9O := {}

	Default lFirsOpe  := .T.
	Default cStatAlt  := ""

	cVersao           := ""
	cVerAnt           := oModelT92:GetValue( "T92_VERSAO" )
	cProtocolo        := oModelT92:GetValue( "T92_PROTUL" )
	cEvento           := oModelT92:GetValue( "T92_EVENTO" )

	nI                := 0
	nT3I              := 0
	nT3H              := 0
	nV9O              := 0
	nT3J              := 0
	nC9J              := 0
	nCMK              := 0
	nT15              := 0
	nT16              := 0

	nV9OAdd			  := 0
	nT3JAdd           := 0
	nCMKAdd           := 0
	nT15Add           := 0
	nT16Add           := 0
	nIJAdd            := 0
	nIKAdd            := 0

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_T92", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI

	For nT3I := 1 to Len( aGravaT3I )

		If nT3I > 1
			oModel:GetModel( "MODEL_T3I" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T3I", "T3I_IDEDMD", aGravaT3I[nT3I][1] )

		If lSimplBeta .And. TafColumnPos("T3I_INDRRA")
			oModel:LoadValue( "MODEL_T3I", "T3I_INDRRA", aGravaT3I[nT3I][2] )
			oModel:LoadValue( "MODEL_T3I", "T3I_TPPRRA", aGravaT3I[nT3I][3] )
			oModel:LoadValue( "MODEL_T3I", "T3I_NRPRRA", aGravaT3I[nT3I][4] )
			oModel:LoadValue( "MODEL_T3I", "T3I_DESCRA", aGravaT3I[nT3I][5] )
			oModel:LoadValue( "MODEL_T3I", "T3I_QTMRRA", aGravaT3I[nT3I][6] )
			oModel:LoadValue( "MODEL_T3I", "T3I_VLRCUS", aGravaT3I[nT3I][7] )
			oModel:LoadValue( "MODEL_T3I", "T3I_VLRADV", aGravaT3I[nT3I][8] )
		EndIf

		If lSimplBeta .And. TafColumnPos("V9O_TPINSC")
			nV9OAdd := 1
			For nV9O := 1 to Len( aGravaV9O )

				If aGravaV9O[nV9O][1] == aGravaT3I[nT3I][1]
					If nV9OAdd > 1
						oModel:GetModel( "MODEL_V9O" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V9O", "V9O_VLRADV", aGravaV9O[nV9O][2] )
					oModel:LoadValue( "MODEL_V9O", "V9O_TPINSC", aGravaV9O[nV9O][3] )
					oModel:LoadValue( "MODEL_V9O", "V9O_NRINSC", aGravaV9O[nV9O][4] )

				nV9OAdd++
				EndIf
			Next //nV9O
		EndIf

		nT3JAdd := 1
		For nT3J := 1 to Len( aGravaT3J )

			If aGravaT3J[nT3J][1] == aGravaT3I[nT3I][1]
				If nT3JAdd > 1
					oModel:GetModel( "MODEL_T3J" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_T3J", "T3J_ESTABE", aGravaT3J[nT3J][2] )
				oModel:LoadValue( "MODEL_T3J", "T3J_LOTTRB", aGravaT3J[nT3J][3] )

				// Tratamento para a simplificação do e-Social
				If !lLaySimplif
					oModel:LoadValue( "MODEL_T3J", "T3J_GRAUEX", aGravaT3J[nT3J][4] )
					oModel:LoadValue( "MODEL_T3J", "T3J_INDCSU", aGravaT3J[nT3J][5] )
				Else
					oModel:LoadValue( "MODEL_T3J", "T3J_INDCSU", aGravaT3J[nT3J][4] )
				EndIf

				nCMKAdd := 1
				For nCMK := 1 to Len( aGravaCMK )
					If aGravaCMK[nCMK][3] == aGravaT3J[nT3J][3] .and. aGravaCMK[nCMK][2] == aGravaT3J[nT3J][2] .and. aGravaCMK[nCMK][1] == aGravaT3I[nT3I][1]

						If nCMKAdd > 1
							oModel:GetModel( "MODEL_CMK" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_CMK", "CMK_CODRUB", aGravaCMK[nCMK][4] )
						oModel:LoadValue( "MODEL_CMK", "CMK_QTDRUB", aGravaCMK[nCMK][5] )

						// Tratamento para a simplificação do e-Social
						If !lLaySimplif
							oModel:LoadValue( "MODEL_CMK", "CMK_VLRUNI", aGravaCMK[nCMK][6] )
							oModel:LoadValue( "MODEL_CMK", "CMK_VLRRUB", aGravaCMK[nCMK][7] )
							oModel:LoadValue( "MODEL_CMK", "CMK_FATORR", aGravaCMK[nCMK][8] )
						Else
							oModel:LoadValue( "MODEL_CMK", "CMK_VLRRUB", aGravaCMK[nCMK][6] )
							oModel:LoadValue( "MODEL_CMK", "CMK_FATORR", aGravaCMK[nCMK][7] )
							oModel:LoadValue( "MODEL_CMK", "CMK_APURIR", aGravaCMK[nCMK][8] )
						EndIf

						nCMKAdd++
					EndIf
				Next //nCMK

				// Tratamento para a simplificação do e-Social
				If !lLaySimplif
					nT15Add := 1
					For nT15 := 1 to Len( aGravaT15 )
						If aGravaT15[nT15][3] == aGravaT3J[nT3J][3] .and. aGravaT15[nT15][2] == aGravaT3J[nT3J][2] .and. aGravaT15[nT15][1] == aGravaT3I[nT3I][1]

							If nT15Add > 1
								oModel:GetModel( "MODEL_T15" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T15", "T15_CNPJOP", aGravaT15[nT15][4] )
							oModel:LoadValue( "MODEL_T15", "T15_REGANS", aGravaT15[nT15][5] )
							oModel:LoadValue( "MODEL_T15", "T15_VLPGTI", aGravaT15[nT15][6] )
							oModel:LoadValue( "MODEL_T15", "T15_NOMEVE", "S2399")

							nT16Add := 1
							For nT16 := 1 to Len( aGravaT16 )
								If aGravaT16[nT16][4] == aGravaT15[nT15][4] .and. aGravaT16[nT16][3] == aGravaT3J[nT3J][3] .and. aGravaT16[nT16][2] == aGravaT3J[nT3J][2] .and. aGravaT16[nT16][1] == aGravaT3I[nT3I][1]

									If nT16Add > 1
										oModel:GetModel( "MODEL_T16" ):AddLine()
									EndIf
									oModel:LoadValue( "MODEL_T16", "T16_SEQUEN", aGravaT16[nT16][5] )
									oModel:LoadValue( "MODEL_T16", "T16_TPDEP" , aGravaT16[nT16][6] )
									oModel:LoadValue( "MODEL_T16", "T16_CPFDEP", aGravaT16[nT16][7] )
									oModel:LoadValue( "MODEL_T16", "T16_NOMDEP", aGravaT16[nT16][8] )
									oModel:LoadValue( "MODEL_T16", "T16_DTNDEP", aGravaT16[nT16][9] )
									oModel:LoadValue( "MODEL_T16", "T16_VPGDEP", aGravaT16[nT16][10] )
									oModel:LoadValue( "MODEL_T16", "T16_NOMEVE", "S2399" )

									nT16Add++
								EndIf
							Next //nT16

						nT15Add++
						EndIf
					Next //nT15
				EndIf

			nT3JAdd++
			EndIf
		Next //nT3J

	Next //nT3I

	For nT3H := 1 to Len( aGravaT3H )

		oModel:GetModel( "MODEL_T3H" ):LVALID := .T.

		If nT3H > 1
			oModel:GetModel( "MODEL_T3H" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T3H", "T3H_TPTRIB", aGravaT3H[nT3H][1] )
		oModel:LoadValue( "MODEL_T3H", "T3H_IDPROC", aGravaT3H[nT3H][2] )
		oModel:LoadValue( "MODEL_T3H", "T3H_IDSUSP", aGravaT3H[nT3H][3] )
		oModel:LoadValue( "MODEL_T3H", "T3H_NOMEVE", "S2399" )

	Next

	For nC9J := 1 to Len( aGravaC9J )

		oModel:GetModel( "MODEL_C9J" ):LVALID := .T.

		If nC9J > 1
			oModel:GetModel( "MODEL_C9J" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_C9J", "C9J_TPINSC", aGravaC9J[nC9J][1] )
		oModel:LoadValue( "MODEL_C9J", "C9J_NRINSC", aGravaC9J[nC9J][2] )
		oModel:LoadValue( "MODEL_C9J", "C9J_CODCAT", aGravaC9J[nC9J][3] )
		oModel:LoadValue( "MODEL_C9J", "C9J_VLREMU", aGravaC9J[nC9J][4] )
		oModel:LoadValue( "MODEL_C9J", "C9J_NOMEVE", "S2399" )

	Next

	cVersao := xFunGetVer()
	oModel:LoadValue( "MODEL_T92", "T92_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T92", "T92_STATUS", "" )

	If lFirsOpe
		oModel:LoadValue( "MODEL_T92", "T92_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T92", "T92_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_T92", "T92_PROTUL", "" )
		oModel:LoadValue( "MODEL_T92", "T92_STATUS", "" )
		// Tratamento para limpar o ID unico do xml
		cAliasPai := "T92"
		If TAFColumnPos( cAliasPai+"_XMLID" )
			oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
		EndIf

		If cEvento == "E" .Or. cStatAlt <> "4"
			oModel:LoadValue( "MODEL_T92", "T92_EVENTO", "I" )
		Else
			oModel:LoadValue( "MODEL_T92", "T92_EVENTO", "A" )
		EndIf

	Else
		DBSelectArea("T92")
		T92->(DBSetOrder(2))
		T92->(MsSeek( xFilial( "T92" ) + FWFLDGET('T92_ID') + "1" ))
		oModel:LoadValue( "MODEL_T92", "T92_ID"    , T92->T92_ID )
		oModel:LoadValue( "MODEL_T92", "T92_VERSAO", T92->T92_VERSAO)
		oModel:LoadValue( "MODEL_T92", "T92_PROTUL", "" )
		oModel:LoadValue( "MODEL_T92", "T92_EVENTO", "I" )
	EndIf

	If lFirsOpe .And. cStatAlt <> "4"
		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, "MODEL_T92", "T92" )
		EndIf
		FwFormCommit( oModel )
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF280Xml
Funcao de geracao do XML para atender os registros S-2399.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias		-	Alias da Tabela
nRecno		-	Recno do Registro corrente
nOpc		-	Operacao a ser realizada
lJob		-	Informa se foi chamado por Job
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-2399

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF280Xml( cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical,;
					lRemEmp as logical, cSeqXml as character, lInfoRPT as logical )

	Local cXml        as character
	Local cReg        as character
	Local cLayout     as character
	Local cCatci      as character
	Local cXmlDPlan   as character
	Local cXmlProcJud as character
	Local cXmlInfMV   as character
	Local cXmlDev     as character
	Local cCodSusp    as character
	Local cEsocial    as character
	Local cIndRRA     as character
	Local nI          as numeric
	Local lXmlVLd     as logical

	//Relatório de Conferência de Valores
	Local oInfoRPT    as object
	Local cMatric     as character
	Local cCPF        as character
	Local cNome       as character
	Local cCodCat     as character
	Local aAnalitico  as array
	Local aRubrica    as array
	Local nPosValores as numeric

	Default cAlias   := ""
	Default nRecno   := 1
	Default nOpc     := 1
	Default lJob     := .F.
	Default lInfoRPT := .F.

	cXml             := ""
	cReg             := "TSVTermino"
	cLayout          := "2399"
	cCatci           := ""
	cXmlDPlan        := ""
	cXmlProcJud      := ""
	cXmlInfMV        := ""
	cXmlDev          := ""
	cEsocial         := SuperGetMV("MV_TAFVLES")
	cIndRRA          := ""
	cCodSusp         := ""
	oInfoRPT         := Nil
	cMatric          := ""
	cCPF             := ""
	cNome            := ""
	cCodCat          := ""
	aAnalitico       := {}
	aRubrica         := {}
	nPosValores      := 0
	nI               := 0
	lXmlVLd          := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF280XML' ),.T.)

	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))

	DBSelectArea("T3H")
	T3H->(DBSetOrder(1))

	DBSelectArea("T3I")
	T3I->(DBSetOrder(1))

	DBSelectArea("C9J")
	C9J->(DBSetOrder(1))

	If lSimplBeta .And. TAFColumnPos("V9O_TPINSC")
		DBSelectArea("V9O")
		V9O->(DBSetOrder(1))
	EndIf

	DBSelectArea("T3J")
	T3J->(DBSetOrder(1))

	DBSelectArea("CMK")
	CMK->(DBSetOrder(1))

	DBSelectArea("T15")
	T15->(DBSetOrder(1))

	DBSelectArea("T16")
	T16->(DBSetOrder(1))

	DBSelectArea("T92")
	T92->( DBSetOrder( 1 ) )

	If lXmlVLd

		If TAFColumnPos("T92_LAYOUT") .And. !Empty(AllTrim(T92->T92_LAYOUT))
			cEsocial := AllTrim(T92->T92_LAYOUT)
		EndIf

		SetLayout()

		//Verifica se existe as classes necessárias para utilização do relatório persistido
		If lInfoRPT
			If __lGrvRPT == Nil
				TAF280Rpt() //Inicializa a variável static __lGrvRPT
			EndIf

			lInfoRPT := __lGrvRPT
		EndIf

		If lInfoRPT
			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf
		EndIf

		cXml +=	"<ideTrabSemVinculo>"

		C9V->( MSSeek( xFilial("C9V") + T92->T92_TRABAL + "1" ) )

		cCPF	:=	C9V->C9V_CPF
		cNome	:=	C9V->C9V_NOME
		cCodCat	:=	GetADVFVal( "C87", "C87_CODIGO", xFilial( "C87" ) + AllTrim(C9V->C9V_CATCI), 1, "" )

		cXml 	+=	xTafTag("cpfTrab" ,	cCPF )

		// Tratamento para a simplificação do e-Social
		If !lLaySimplif
			cXml += xTafTag("nisTrab" ,	C9V->C9V_NIS,, .T.)
			cXml += xTafTag("codCateg", Posicione("C87", 1, xFilial("C87") + AllTrim(C9V->C9V_CATCI), "C87_CODIGO"))
		Else
			cMatric	:= 	C9V->C9V_MATTSV
			cXml 	+=	xTafTag("matricula" ,	AllTrim(cMatric),, .T.)

			If Empty(cMatric)
				cXml += xTafTag("codCateg", Posicione("C87", 1, xFilial("C87") + AllTrim(C9V->C9V_CATCI), "C87_CODIGO"),, .T.)
			EndIf
		EndIf

		cXml +=	"</ideTrabSemVinculo>"
		cXml += 	"<infoTSVTermino>"
		cXml += 		xTafTag( "dtTerm"	   		, T92->T92_DTERAV )
		cXml +=			xTafTag( "mtvDesligTSV"		, Posicione("CML",1,xFilial("CML") + T92->T92_MOTDES,"CML_CODIGO"),.T.,.T.)
		cXml += 		xTafTag( "pensAlim"	   		, T92_PENALI,,.T. )
		cXml += 		xTafTag( "percAliment"	   	, T92_PERALI,,.T. )
		cXml += 		xTafTag( "vrAlim"	   		, T92_VLPALI,PesqPict( "T92", "T92_VLPALI" ),.T. )

		// Tratamento para a simplificação do e-Social
		If lLaySimplif
			cXml += 		xTafTag( "nrProcTrab"	   	, T92_NRPROC,, .T. )
		EndIf

		xTAFTagGroup( "mudancaCPF", {{ "novoCPF", T92->T92_NEWCPF,, .F. }}, @cXml )

		If T3I->( MSSeek( xFilial("T3I") + T92->(T92_ID + T92_VERSAO )))

			While T3I->(!Eof()) .and. T3I->(T3I_FILIAL + T3I_ID + T3I_VERSAO) == xFilial("T3I") + T92->(T92_ID + T92_VERSAO )
				
				cXmlDev +=	 "<dmDev>"
				cXmlDev +=		xTafTag( "ideDmDev", T3I->T3I_IDEDMD, PesqPict("T3I","T3I_IDEDMD") )

				If lSimplBeta .And. TafColumnPos("T3I_INDRRA") .And. TafColumnPos("V9O_TPINSC")

					cIndRRA	:= Iif( T3I->T3I_INDRRA == "1", "S", "")
					cXmlDev +=		xTafTag( "indRRA", cIndRRA,, .T.)

					If cIndRRA == "S"

						cXmlDev +=		"<infoRRA>"
						cXmlDev +=			xTafTag( "tpProcRRA", T3I->T3I_TPPRRA,, .F. )
						cXmlDev +=			xTafTag( "nrProcRRA", T3I->T3I_NRPRRA,, .T. )
						cXmlDev +=			xTafTag( "descRRA", T3I->T3I_DESCRA,, .F. )
						cXmlDev +=			xTafTag( "qtdMesesRRA", T3I->T3I_QTMRRA,, .F. )

						cXmlDev +=			"<despProcJud>"
						cXmlDev +=				xTafTag( "vlrDespCustas", T3I->T3I_VLRCUS, PesqPict("T3I","T3I_VLRCUS"), .F. )
						cXmlDev +=				xTafTag( "vlrDespAdvogados", T3I->T3I_VLRADV, PesqPict("T3I","T3I_VLRADV"), .F. )
						cXmlDev +=			"</despProcJud>"

						cXmlDev +=		"</infoRRA>"
				
						If V9O->( MsSeek( xFilial("V9O") + T3I->(T3I_ID + T3I_VERSAO + T3I_IDEDMD) ))
							While V9O->(!Eof()) .and. V9O->(V9O_FILIAL + V9O_ID + V9O_VERSAO + V9O_IDEDMD) == xFilial("V9O") + T3I->(T3I_ID + T3I_VERSAO + T3I_IDEDMD)

								xTafTagGroup("ideAdv";
											, {{"tpInsc"		, V9O->V9O_TPINSC, PesqPict( "V9O", "V9O_TPINSC "), .F.};
											,  {"nrInsc"		, V9O->V9O_NRINSC, PesqPict( "V9O", "V9O_NRINSC "), .F.};
											,  {"vlrAdv"		, V9O->V9O_VLRADV, PesqPict( "V9O", "V9O_VLRADV"), .T.}};
											, @cXmlDev )

								V9O->(DBSkip())
							EndDo
						EndIf
					EndIf
				EndIf			

				If T3J->( MSSeek( xFilial("T3J") + T3I->(T3I_ID + T3I_VERSAO + T3I_IDEDMD) ))
					While T3J->(!Eof()) .and. T3J->(T3J_FILIAL + T3J_ID + T3J_VERSAO + T3J_IDEDMD) == xFilial("T3J") + T3I->(T3I_ID + T3I_VERSAO + T3I_IDEDMD)

						cXmlDev += "<ideEstabLot>"
						cXmlDev += 	xTafTag( "tpInsc", POSICIONE("C92",1, xFilial("C92")+T3J->T3J_ESTABE,"C92_TPINSC") )
						cXmlDev += 	xTafTag( "nrInsc", POSICIONE("C92",1, xFilial("C92")+T3J->T3J_ESTABE,"C92_NRINSC") )
						cXmlDev += 	xTafTag( "codLotacao", Posicione("C99",4, xFilial("C99") + T3J->T3J_LOTTRB + '1',"C99_CODIGO") )

						If CMK->( MSSeek( xFilial("CMK") + T3J->(T3J_ID + T3J_VERSAO + T3J_IDEDMD + T3J_ESTABE + T3J_LOTTRB) ) )
							While CMK->(!Eof()) .and. CMK->(CMK_FILIAL + CMK_ID + CMK_VERSAO + CMK_IDEDMD + CMK_ESTABE + CMK_LOTTRB) == xFilial("CMK") + T3J->(T3J_ID + T3J_VERSAO + T3J_IDEDMD + T3J_ESTABE + T3J_LOTTRB)

								cXmlDev += "<detVerbas>"
								cXmlDev += 	xTafTag( "codRubr"   , Posicione("C8R",5,xFilial("C8R") + Alltrim(CMK->CMK_CODRUB) + "1","C8R_CODRUB"), PesqPict("C8R","C8R_CODRUB") )
								cXmlDev +=	xTafTag( "ideTabRubr", C8R->C8R_IDTBRU )

								cXmlDev +=		xTafTag( "qtdRubr"	, CMK->CMK_QTDRUB , PesqPict( "CMK", "CMK_QTDRUB" ),.T.,.T. )
								cXmlDev +=		xTafTag( "fatorRubr"	, CMK->CMK_FATORR,,.T. )

								// Tratamento para a simplificação do e-Social
								If !lLaySimplif
									cXmlDev +=		xTafTag( "vrUnit" 	, CMK->CMK_VLRUNI , PesqPict( "CMK", "CMK_VLRUNI" ),.T.,.T. )
								EndIf

								cXmlDev +=		xTafTag( "vrRubr" 	, CMK->CMK_VLRRUB , PesqPict( "CMK", "CMK_VLRRUB" ) )
								cXmlDev +=		xTafTag( "indApurIR" 	, CMK->CMK_APURIR,, .T. )
								cXmlDev += "</detVerbas>"

								If lInfoRPT
									aRubrica := oReport:GetRubrica( CMK->CMK_CODRUB )

									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric ) 
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T3J->T3J_ESTABE + "1", "C92_TPINSC" ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T3J->T3J_ESTABE + "1", "C92_NRINSC" ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + T3J->T3J_LOTTRB + "1", "C99_CODIGO" ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	CMK->CMK_VLRRUB
								EndIf

								CMK->(DBSkip())

							EndDo
						EndIf

						// Tratamento para a simplificação do e-Social
						If !lLaySimplif
							If T15->( MSSeek( xFilial("T15") + T3J->(T3J_ID + T3J_VERSAO + T3J_IDEDMD + T3J_ESTABE + T3J_LOTTRB) ) )
								While T15->(!Eof()) .and. T15->( T15_FILIAL + T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA)  == xFilial("T15") + T3J->(T3J_ID + T3J_VERSAO + T3J_IDEDMD +  T3J_ESTABE  + T3J_LOTTRB)

									cXmlDPlan += "<detOper>"
									cXmlDPlan +=		xTafTag( "cnpjOper"	, T15->T15_CNPJOP )
									cXmlDPlan +=		xTafTag( "regANS"		, T15->T15_REGANS )
									cXmlDPlan +=		xTafTag( "vrPgTit"	, T15->T15_VLPGTI , PesqPict( "T15", "T15_VLPGTI" ) ,,.T.,.T.) //ALTERADO PARA GERAR A TAG COM VALOR ZERADO

									If T16->(MSSeek( xFilial("T15") + T15->(T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA + T15_CNPJOP) ))
										While T16->(!Eof()) .and. T16->( T16_FILIAL + T16_ID + T16_VERSAO + T16_RECIBO + T16_ESTABE + T16_LOTACA + T16_CNPJOP) == xFilial("T15") + T15->(T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA + T15_CNPJOP)

											cXmlDPlan += "<detPlano>"
											cXmlDPlan +=		xTafTag( "tpDep"   , Posicione( "CMI", 1, xFilial( "CMI" ) + T16->T16_TPDEP, "CMI_CODIGO" ) )
											cXmlDPlan +=		xTafTag( "cpfDep"  , T16->T16_CPFDEP,,.T. )
											cXmlDPlan +=		xTafTag( "nmDep"   , T16->T16_NOMDEP )
											cXmlDPlan +=		xTafTag( "dtNascto", T16->T16_DTNDEP )
											cXmlDPlan +=		xTafTag( "vlrPgDep", T16->T16_VPGDEP, PesqPict( "T16", "T16_VPGDEP" ) )
											cXmlDPlan += "</detPlano>"

											T16->(DBSkip())
										EndDo
									EndIf

									cXmlDPlan += "</detOper>"

									T15->(DBSkip())
								EndDo
							EndIf

							If !Empty(cXmlDPlan)
								cXmlDev += "<infoSaudeColet>"
								cXmlDev += 	cXmlDPlan
								cXmlDev += "</infoSaudeColet>"
							EndIf

							xTafTagGroup("infoAgNocivo"	,{{"grauExp",Posicione("C88",1,xFilial("C88") + T3J->T3J_GRAUEX,"C88_CODIGO"),,.F.}};
															, @cXmlDev)
						EndIf

						xTafTagGroup("infoSimples"	,{{"indSimples",T3J->T3J_INDCSU,,.F.}};
														, @cXmlDev)

						cXmlDev += "</ideEstabLot>"

						//Limpa a variavel
						cXmlDPlan := ""

						T3J->(DBSkip())
					EndDo
				EndIf					

				cXmlDev += "</dmDev>"

				T3I->(DBSkip())
			EndDo
		EndIf

		If T3H->( MSSeek( xFilial("T3H") + T92->(T92_ID + T92_VERSAO )))
			While T3H->(!Eof()) .and. T3H->(T3H_FILIAL + T3H_ID + T3H_VERSAO) == xFilial("T3H") +  T92->(T92_ID + T92_VERSAO )

				cXmlProcJud += "<procJudTrab>"
				cXmlProcJud +=	xTafTag( "tpTrib", T3H->T3H_TPTRIB)
				cXmlProcJud +=	xTafTag( "nrProcJud",Posicione("C1G",8,xFilial("C1G")+T3H->T3H_IDPROC+'1',"C1G_NUMPRO"))

				// Tratamento para a simplificação do e-Social
				If !lLaySimplif
					cXmlProcJud += xTafTag("codSusp", Alltrim(Posicione("T5L",1,xFilial("T5L")+T3H->T3H_IDSUSP,"T5L_CODSUS")),, .T.)
				Else
					cXmlProcJud += xTafTag("codSusp", Alltrim(Posicione("T5L",1,xFilial("T5L")+T3H->T3H_IDSUSP,"T5L_CODSUS")),, .F.)	
				EndIf

				cXmlProcJud += "</procJudTrab>"

				T3H->(DBSkip())
			EndDo
		EndIf

		If !Empty(T92->T92_INDMVI)

			cXmlInfMV += "<infoMV>"
			cXmlInfMV +=		xTafTag( "indMV", T92->T92_INDMVI)

			If C9J->( MSSeek( xFilial("C9J") + T92->(T92_ID + T92_VERSAO )))
				While C9J->(!Eof()) .and. C9J->(C9J_FILIAL + C9J_ID + C9J_VERSAO) == xFilial("C9J") + T92->(T92_ID + T92_VERSAO )

					cXmlInfMV += "<remunOutrEmpr>"
					cXmlInfMV +=		xTafTag( "tpInsc", C9J->C9J_TPINSC)
					cXmlInfMV +=		xTafTag( "nrInsc", C9J->C9J_NRINSC)
					cXmlInfMV +=		xTafTag( "codCateg",Posicione("C87",1,xFilial("C87") + C9J->C9J_CODCAT,"C87_CODIGO"))
					cXmlInfMV +=		xTafTag( "vlrRemunOE", C9J->C9J_VLREMU , PesqPict( "C9J", "C9J_VLREMU" ))
					cXmlInfMV +=	"</remunOutrEmpr>"

					C9J->(DBSkip())
				EndDo
			EndIf

			cXmlInfMV += "</infoMV>"
		EndIf

		If !Empty(cXmlDev)
			cXml += "<verbasResc>"
			cXml +=	cXmlDev + cXmlProcJud + cXmlInfMV
			cXml += "</verbasResc>"
		EndIf

		If lSimplBeta .and. TafColumnPos("T92_INDREM")
			xTafTagGroup("remunAposTerm";
							, {{"indRemun"		, T92->T92_INDREM,, .T.};
							,  {"dtFimRemun"	, T92->T92_DTFREM,, .F.}};
							, @cXml )
		Else
			xTafTagGroup("quarentena"	, { {"dtFimQuar",T92->T92_DTQUA,,.F.}};
											, @cXml)
		EndIf	

		cXml += 	"</infoTSVTermino>"

		//Estrutura do cabecalho
		cXml := xTafCabXml( cXml, "T92", cLayout, cReg,,,, lLaySimplif, cEsocial )

		//Executa gravacao do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf

		If lInfoRPT
			If T92->T92_EVENTO $ "I|A"
				oInfoRPT := oReport:oVOReport
				oInfoRPT:SetIndApu( "1" )
				oInfoRPT:SetPeriodo( SubStr( DToS( T92->T92_DTERAV ), 1, 6 ) )
				oInfoRPT:SetCPF( AllTrim( cCPF ) )
				oInfoRPT:SetNome( AllTrim( cNome ) )
				oInfoRPT:SetAnalitico( aAnalitico )

				oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT )
				EndIf
		EndIf
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF280Grv
Funcao de gravacao para atender o registro S-2399

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF280Grv( cLayout as character, nOpc as numeric, cFilEv as character, oXML as object, cOwner as character,;
 					cFilTran as character, cPredeces as character, nTafRecno as numeric, cComplem as character,;
					cGrpTran as character,cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character,;
					cEvtOri as character, lMigrador as logical, lDepGPE as logical, cKey as character,;
					cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXML as character) 

	Local cCmpsNoUpd  as character
	Local cCabec      as character
	Local cT3IPath    as character
	Local cV9OPath    as character
	Local cT3JPath    as character
	Local cC9JPath    as character
	Local cT3HPath    as character
	Local cCMKPath    as character
	Local cT15Path    as character
	Local cT16Path    as character
	Local cInconMsg   as character
	Local cIdProc     as character
	Local cCodSusp    as character
	Local cMatric     as character
	Local cCPF        as character
	Local cTrabal     as character
	Local cCodCat     as character
	Local cCodEvent   as character
	Local cLogOpeAnt  as character
	Local cIdFunc     as character
	Local cEsocial    as Character
	Local cIndRRA     as character

	Local dDataDem    as date

	Local nI          as numeric
	Local n3          as numeric
	Local nSeqErrGrv  as numeric
	Local nCMK        as numeric
	Local nT3I        as numeric
	Local nV9O        as numeric
	Local nT3J        as numeric
	Local nC9J        as numeric
	Local nT3H        as numeric
	Local nT15        as numeric
	Local nT16        as numeric
	Local nIndChv     as numeric
	
	Local lRet        as logical

	Local aIncons     as array
	Local aRules      as array
	Local aChave      as array
	Local aChkDupl    as array
	Local oModel      as object
	Local cDtTerm     as character
	Local cIdTabR     as character

	//Relatório de Conferência de Valores
	Local oInfoRPT    as object
	Local cNome       as character
	Local cCodRubr    as character
	Local cCodCatXml  as character
	Local cCodCatC9V  as character
	Local nPosValores as numeric
	Local aAnalitico  as array
	Local aRubrica    as array
	Local lInfoRPT    as logical

	Private lVldModel as logical
	Private oDados    as object

	Default cLayout    := ""
	Default nOpc       := 1
	Default cFilEv     := ""
	Default oXML       := Nil
	Default cOwner     := ""
	Default cFilTran   := ""
	Default cPredeces  := ""
	Default nTafRecno  := 0
	Default cComplem   := ""
	Default cGrpTran   := ""
	Default cEmpOriGrp := ""
	Default cFilOriGrp := ""
	Default cXmlID     := ""
	Default cEvtOri    := ""
	Default lMigrador  := ""
	Default lDepGPE    := ""
	Default cKey       := ""
	Default cMatrC9V   := ""
	Default lLaySmpTot := ""
	Default lExclCMJ   := ""
	Default oTransf    := ""
	Default cXML       := ""

	cCmpsNoUpd         := "|T92_FILIAL|T92_ID|T92_VERSAO|T92_VERANT|T92_PROTUL|T92_PROTPN|T92_EVENTO|T92_STATUS|T92_ATIVO|"
	cCabec             := "/eSocial/evtTSVTermino/"
	cT3IPath           := ""
	cV9OPath           := ""
	cT3JPath           := ""
	cC9JPath           := ""
	cT3HPath           := ""
	cCMKPath           := ""
	cT15Path           := ""
	cT16Path           := ""
	cInconMsg          := ""
	cIdProc            := ""
	cCodSusp           := ""
	cMatric            := ""
	cCPF               := ""
	cTrabal            := ""
	cCodCat            := ""
	cCodEvent          := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	cLogOpeAnt         := ""
	cIdFunc            := ""
	cEsocial           := ""
	cIndRRA            := ""
	dDataDem           := CtoD(" / / ")
	nI                 := 0
	n3                 := 0
	nSeqErrGrv         := 0
	nCMK               := 0
	nT3I               := 0
	nV9O               := 0
	nT3J               := 0
	nC9J               := 0
	nT3H               := 0
	nT15               := 0
	nT16               := 0
	nIndChv            := 3
	lRet               := .F.
	aIncons            := {}
	aRules             := {}
	aChave             := {}
	aChkDupl           := {}
	oModel             := Nil
	cDtTerm            := ""
	cIdTabR            := ""
	oInfoRPT           := Nil
	cNome              := ""
	cCodRubr           := ""
	cCodCatXml         := ""
	cCodCatC9V         := ""
	nPosValores        := 0
	aAnalitico         := {}
	aRubrica           := {}
	lInfoRPT           := .F.

	lVldModel          := .T.
	oDados             := oXML
	

	If __lGrvRPT == Nil
		TAF280Rpt() //Inicializa a variável static __lGrvRPT
	EndIf

	lInfoRPT := __lGrvRPT

	If lInfoRPT
		If oReport == Nil
			oReport := TAFSocialReport():New()
		EndIf
	EndIf

	//Recebo o CPF informado no XML
	cCPF		:= oDados:XPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab" )
	cCodCat 	:= oDados:XPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" )

	//Convertendo o código da categoria em ID
	If !Empty( cCodCat )
		cCodCat := Posicione("C87",2,xFilial("C87") + cCodCat,"C87_ID")
	EndIf

	// Tratamento para a simplificação do e-Social
	If lLaySimplif
		cMatric		:= oDados:XPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/matricula" )
	EndIf

	dDataDem	:= FTafGetVal( cCabec + "infoTSVTermino/dtTerm", "D", .F. )

	If oDados:XPathHasNode( cCabec + "infoTSVTermino/dtTerm" )
		cDtTerm		:= Alltrim( oDados:XPathGetNodeValue( cCabec + "infoTSVTermino/dtTerm" ) )
	EndIf

	// Verifica se existe esse trabalhador - Tratamento para a simplificação do e-Social
	If lLaySimplif .AND. !Empty(cMatric)
		cIdFunc := TAFGetIdFunc(cCPF,SubStr(DToS(dDataDem),1,6),dDataDem,"cpfTrab","/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab",,cMatric,,,"matricula","/eSocial/evtTSVTermino/ideTrabSemVinculo/matricula",,,,,@cInconMsg,@nSeqErrGrv,,,cLayout)
	Else
		cIdFunc := TAFGetIdFunc(cCPF,SubStr(DToS(dDataDem),1,6),dDataDem,"cpfTrab","/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab",,,cCodCat,,,,"codCateg","/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg",,,@cInconMsg,@nSeqErrGrv)
	EndIf

	If Empty(cIdFunc)

		Aadd( aIncons, "000028")	//"Para a integração do evento de término S-2399 (Trabalhador Sem Vínculo - Término), é necessário que exista o evento S-2300 (Trabalhador
									//Sem Vínculo - Início) correspondente ao evento de término do trabalhador sem vínculo."
	Else

		C9V->( dbSetOrder(2) )
		If C9V->( dbSeek( xFilial("C9V") + cIdFunc + "1" ) )
			cNome := C9V->C9V_NOME
			cCodCatC9V := IIF(lLaySimplif,Posicione("C87", 1, xFilial("C87") + AllTrim(C9V->C9V_CATCI),"C87_CODIGO"),'')

			If C9V->C9V_STATUS == "3"
				Aadd( aIncons, "000028") //"O evento S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) rejeitado pelo Governo."

			ElseIf C9V->C9V_STATUS <> '4'
				Aadd( aIncons, "000029") //"O evento S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) não se encontra válido ou transmitido com sucesso ao RET."
			Else
				cTrabal:= C9V->C9V_ID
				Aadd( aChave, { "C", "T92_TRABAL", cTrabal , .T.}  )
			EndIf
		EndIf
	EndIf 

	//Verifica se o evento ja existe na base
	T92->( DbSetOrder( nIndChv ) )
	If T92->( MsSeek( xFilial("T92") + cTrabal + '1' ) )
		If !T92->T92_STATUS $ ( "2|6" )
			nOpc := 4
		EndIf
	EndIf

	Begin Transaction

		If Findfunction("TafNameEspace")
			cLayNmSpac := TafNameEspace(cXML)
		EndIf

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "T92", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA280", cCmpsNoUpd )

			If TafColumnPos( "T92_LOGOPE" )
				cLogOpeAnt := T92->T92_LOGOPE
			endif

			//Carrego array com os campos De/Para de gravacao das informacoes ( Sem Vinculo - T92 )
			aRules := TAF280Rul( cCabec, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cIdFunc, cLayout )

			//Quando se tratar de uma exclusao direta apenas preciso realizar
			//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5
				oModel:LoadValue( "MODEL_T92", "T92_FILIAL", T92->T92_FILIAL )

				If TAFColumnPos( "T92_LAYOUT" )
					oModel:LoadValue( "MODEL_T92", "T92_LAYOUT", cLayNmSpac)
				EndIf

				If TAFColumnPos( "T92_XMLID" )
					oModel:LoadValue( "MODEL_T92", "T92_XMLID", cXmlID )
				EndIf

				//Rodo o aRules para gravar as informacoes
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_T92", aRules[nI,1], aRules[nI,2] )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T92', 'T92_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T92', 'T92_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Cadastro de Descrição da Atividade )
				nT3I 	  := 1
				cT3IPath := cCabec + "infoTSVTermino/verbasResc/dmDev[" + AllTrim(Str(nT3I)) + "]"

				If nOpc == 4
					For n3 := 1 to oModel:GetModel( "MODEL_T3I" ):Length()
						oModel:GetModel( "MODEL_T3I" ):GoLine(n3)
						oModel:GetModel( "MODEL_T3I" ):DeleteLine()
					Next n3
				EndIf

				nT3I := 1
				While oDados:XPathHasNode(cT3IPath)

					oModel:GetModel( "MODEL_T3I" ):lValid:= .T.

					If nOpc == 4 .Or. nT3I > 1
						oModel:GetModel( "MODEL_T3I" ):AddLine()
					EndIf

					If oDados:XPathHasNode(cT3IPath + "/ideDmDev")
						oModel:LoadValue( "MODEL_T3I", "T3I_IDEDMD", FTafGetVal( cT3IPath + "/ideDmDev", "C", .F., @aIncons, .F. ) )
	 				EndIf

					If lSimplBeta .And. TafColumnPos("T3I_INDRRA") .And. TafColumnPos("V9O_TPINSC")

						If oDados:XPathHasNode(cT3IPath + "/indRRA")
							cIndRRA := FTafGetVal( cT3IPath + "/indRRA", "C", .F., @aIncons, .F. )
							oModel:LoadValue( "MODEL_T3I", "T3I_INDRRA", Iif(cIndRRA == "S", "1", "")  )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/tpProcRRA")
							oModel:LoadValue( "MODEL_T3I", "T3I_TPPRRA", FTafGetVal( cT3IPath + "/infoRRA/tpProcRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/nrProcRRA")
							oModel:LoadValue( "MODEL_T3I", "T3I_NRPRRA", FTafGetVal( cT3IPath + "/infoRRA/nrProcRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/descRRA")
							oModel:LoadValue( "MODEL_T3I", "T3I_DESCRA", FTafGetVal( cT3IPath + "/infoRRA/descRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/qtdMesesRRA")
							oModel:LoadValue( "MODEL_T3I", "T3I_QTMRRA", FTafGetVal( cT3IPath + "/infoRRA/qtdMesesRRA", "N", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/despProcJud/vlrDespCustas")
							oModel:LoadValue( "MODEL_T3I", "T3I_VLRCUS", FTafGetVal( cT3IPath + "/infoRRA/despProcJud/vlrDespCustas", "N", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT3IPath + "/infoRRA/despProcJud/vlrDespAdvogados")
							oModel:LoadValue( "MODEL_T3I", "T3I_VLRADV", FTafGetVal( cT3IPath + "/infoRRA/despProcJud/vlrDespAdvogados", "N", .F., @aIncons, .F. ) )
	 					EndIf					

						nV9O := 1
						cV9OPath := cT3IPath + "/ideAdv[" + Alltrim(Str(nV9O)) + "]"

						If nOpc == 4 
							For n3 := 1 to oModel:GetModel( "MODEL_V9O" ):Length()
								oModel:GetModel( "MODEL_V9O" ):GoLine(n3)
								oModel:GetModel( "MODEL_V9O" ):DeleteLine()
							Next
						EndIf

						While oDados:XPathHasNode(cV9OPath)
							oModel:GetModel( "MODEL_V9O" ):lValid:= .T.

							If nOpc == 4 .Or. nV9O > 1
								oModel:GetModel( "MODEL_V9O" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV9OPath + "/tpInsc" )
								oModel:LoadValue( "MODEL_V9O", "V9O_TPINSC", FTafGetVal( cV9OPath + "/tpInsc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9OPath + "/nrInsc" )
								oModel:LoadValue( "MODEL_V9O", "V9O_NRINSC", FTafGetVal( cV9OPath + "/nrInsc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9OPath + "/vlrAdv" )
								oModel:LoadValue( "MODEL_V9O", "V9O_VLRADV", FTafGetVal( cV9OPath + "/vlrAdv"	, "N", .F., @aIncons, .F. ) )
							EndIf

							nV9O++
							cV9OPath := cT3IPath + "/ideAdv[" + AllTrim(Str(nV9O)) + "]"
						EndDo

					EndIF

					nT3J := 1
					cT3JPath := cT3IPath + "/ideEstabLot[" + AllTrim(Str(nT3J)) + "]"

					If nOpc == 4
						For n3 := 1 to oModel:GetModel( "MODEL_T3J" ):Length()
							oModel:GetModel( "MODEL_T3J" ):GoLine(n3)
							oModel:GetModel( "MODEL_T3J" ):DeleteLine()
						Next n3
					EndIf

					nT3J := 1
					While oDados:XPathHasNode(cT3JPath)

						oModel:GetModel( "MODEL_T3J" ):lValid:= .T.

						If nOpc == 4 .Or. nT3J > 1
							oModel:GetModel( "MODEL_T3J" ):AddLine()
						EndIf

						If oDados:XPathHasNode(	cT3JPath + "/tpInsc" , cT3JPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_T3J", "T3J_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cT3JPath + "/tpInsc" , cT3JPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) )
						EndIf

						If oDados:XPathHasNode(cT3JPath + "/codLotacao")
							oModel:LoadValue( "MODEL_T3J", "T3J_LOTTRB", FGetIdInt( "codLotacao", "", cT3JPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv ))
	 					EndIf

						// Tratamento para simplificação do e-Social
						If !lLaySimplif
							If oDados:XPathHasNode(cT3JPath + "/infoAgNocivo/grauExp")
								oModel:LoadValue( "MODEL_T3J", "T3J_GRAUEX", FGetIdInt( "grauExp", "", cT3JPath + "/infoAgNocivo/grauExp",,,,@cInconMsg, @nSeqErrGrv))
							EndIf
						EndIf

						If oDados:XPathHasNode( cT3JPath + "/infoSimples/indSimples")
		 					oModel:LoadValue( "MODEL_T3J", "T3J_INDCSU", FTafGetVal( cT3JPath + "/infoSimples/indSimples", "C", .F., @aIncons, .F. ) )
	 					EndIf

						nCMK := 1
						cCMKPath := cT3JPath + "/detVerbas[" + AllTrim(Str(nCMK)) + "]"

						If nOpc == 4
							For n3 := 1 to oModel:GetModel( "MODEL_CMK" ):Length()
								oModel:GetModel( "MODEL_CMK" ):GoLine( n3 )
								oModel:GetModel( "MODEL_CMK" ):DeleteLine()
							Next n3
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
						nCMK := 1
						While oDados:XPathHasNode(cCMKPath)

							oModel:GetModel( "MODEL_CMK" ):lValid:= .T.

							If nOpc == 4 .or. nCMK > 1
								oModel:GetModel( "MODEL_CMK" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cCMKPath + "/ideTabRubr")
								cIdTabR := TAFIdTabRub( FTafGetVal( cCMKPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cCMKPath + "/codRubr", "C", .F., @aIncons, .F. ), cCMKPath, @cInconMsg, @nSeqErrGrv, @aIncons  )
							EndIf

							If oDados:XPathHasNode(cCMKPath + "/codRubr")
								cCodRubr := FGetIdInt( "codRubr","ideTabRubr",FTafGetVal(cCMKPath + "/codRubr", "C", .F., @aIncons,.F.),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,SubStr(StrTran(cDtTerm,"-",""),1,6))
								oModel:LoadValue("MODEL_CMK","CMK_CODRUB", cCodRubr )
	 						EndIf

							If oDados:XPathHasNode(cCMKPath + "/qtdRubr")
								oModel:LoadValue( "MODEL_CMK", "CMK_QTDRUB", FTafGetVal( cCMKPath + "/qtdRubr"		, "N", .F., @aIncons, .F. ) )
	 						EndIf

							// Tratamento para a simplificação do e-Social
							If !lLaySimplif
								If oDados:XPathHasNode(cCMKPath + "/vrUnit")
									oModel:LoadValue( "MODEL_CMK", "CMK_VLRUNI", FTafGetVal( cCMKPath + "/vrUnit"		, "N", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							If oDados:XPathHasNode(cCMKPath + "/vrRubr")
								oModel:LoadValue( "MODEL_CMK", "CMK_VLRRUB", FTafGetVal( cCMKPath + "/vrRubr"		, "N", .F., @aIncons, .F. ) )
	 						EndIf

							If oDados:XPathHasNode(cCMKPath + "/fatorRubr")
								oModel:LoadValue( "MODEL_CMK", "CMK_FATORR", FTafGetVal( cCMKPath + "/fatorRubr"		, "N", .F., @aIncons, .F. ) )
	 						EndIf

							If oDados:XPathHasNode(cCMKPath + "/indApurIR")
								oModel:LoadValue( "MODEL_CMK", "CMK_APURIR", FTafGetVal( cCMKPath + "/indApurIR"		, "C", .F., @aIncons, .F. ) )
	 						EndIf

							If lInfoRPT
								aRubrica := oReport:GetRubrica( cCodRubr )

								aAdd( aAnalitico, Array( 16 ) )
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	Iif( !lLaySimplif, "", AllTrim( oDados:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/matricula" ) ) ) // Tratamento para a simplificação do e-Social
								cCodCatXml := AllTrim( oDados:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" ) )

								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	IIF( Empty( cCodCatXml ) .And. lLaySimplif, cCodCatC9V, cCodCatXml )
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cT3JPath + "/tpInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cT3JPath + "/nrInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cT3JPath + "/codLotacao", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
								aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTafGetVal( cCMKPath + "/vrRubr", "N", .F.,, .F. )
							EndIf

							nCMK++
							cCMKPath := cT3JPath + "/detVerbas[" + AllTrim(Str(nCMK)) + "]"
						EndDo

						// Tratamento para a simplificação do e-Social
						If !lLaySimplif
							nT15 := 1
							cT15Path := cT3JPath + "/infoSaudeColet/detOper[" + AllTrim(Str(nT15)) + "]"

							If nOpc == 4
								For nI := 1 to oModel:GetModel( "MODEL_T15" ):Length()
									oModel:GetModel( "MODEL_T15" ):GoLine( nT15 )
									oModel:GetModel( "MODEL_T15" ):DeleteLine()
								Next nI
							EndIf

							nT15 := 1
							While oDados:XPathHasNode(cT15Path)

								oModel:GetModel( "MODEL_T15" ):lValid:= .T.

								If nOpc == 4 .or. nT15 > 1
									oModel:GetModel( "MODEL_T15" ):AddLine()
								EndIf

								If oDados:XPathHasNode(cT15Path + "/cnpjOper"	)
									oModel:LoadValue( "MODEL_T15", "T15_CNPJOP", FTafGetVal( cT15Path + "/cnpjOper"	, "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(cT15Path + "/regANS"	)
									oModel:LoadValue( "MODEL_T15", "T15_REGANS", FTafGetVal( cT15Path + "/regANS"		, "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(cT15Path + "/vrPgTit"	)
									oModel:LoadValue( "MODEL_T15", "T15_VLPGTI", FTafGetVal( cT15Path + "/vrPgTit"		, "N", .F., @aIncons, .F. ) )
								EndIf

								oModel:LoadValue( "MODEL_T15", "T15_NOMEVE", "S2399" )

								nT16 := 1
								cT16Path := cT15Path + "/detPlano[" + AllTrim(Str(nT16)) + "]"

								If nOpc == 4
									For n3 := 1 to oModel:GetModel( "MODEL_T16" ):Length()
										oModel:GetModel( "MODEL_T16" ):GoLine( nT16 )
										oModel:GetModel( "MODEL_T16" ):DeleteLine()
									Next n3
								EndIf

								//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
								nT16 := 1
								While oDados:XPathHasNode(cT16Path)

									oModel:GetModel( "MODEL_T16" ):lValid:= .T.

									If nOpc == 4 .or. nT16 > 1
										oModel:GetModel( "MODEL_T16" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_T16", "T16_SEQUEN", STRZERO(nT16,3) )

									If oDados:XPathHasNode(cT16Path + "/tpDep")
										oModel:LoadValue( "MODEL_T16", "T16_TPDEP", FGetIdInt( "tpDep", "", cT16Path + "/tpDep",,,, @cInconMsg, @nSeqErrGrv ) )
									EndIf

									If oDados:XPathHasNode(cT16Path + "/cpfDep")
										oModel:LoadValue( "MODEL_T16", "T16_CPFDEP", FTafGetVal( cT16Path + "/cpfDep"	, "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cT16Path + "/nmDep")
										oModel:LoadValue( "MODEL_T16", "T16_NOMDEP", FTafGetVal( cT16Path + "/nmDep"	, "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cT16Path + "/dtNascto")
										oModel:LoadValue( "MODEL_T16", "T16_DTNDEP", FTafGetVal( cT16Path + "/dtNascto"	, "D", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cT16Path + "/vlrPgDep")
										oModel:LoadValue( "MODEL_T16", "T16_VPGDEP", FTafGetVal( cT16Path + "/vlrPgDep"		, "N", .F., @aIncons, .F. ) )
									EndIf

									oModel:LoadValue( "MODEL_T16", "T16_NOMEVE", "S2399" )

									nT16++
									cT16Path := cT15Path + "/detPlano[" + AllTrim(Str(nT16)) + "]"
								EndDo

								nT15++
								cT15Path := cT3JPath + "/infoSaudeColet/detOper[" + AllTrim(Str(nT15)) + "]"
							EndDo
						EndIf

						nT3J++
						cT3JPath := cT3IPath + "/ideEstabLot[" + AllTrim(Str(nT3J)) + "]"
					EndDo

					nT3I++
					cT3IPath := cCabec + "infoTSVTermino/verbasResc/dmDev[" + AllTrim(Str(nT3I)) + "]"
				EndDo

				nT3H := 1
				cT3HPath := cCabec + "infoTSVTermino/verbasResc/procJudTrab[" + AllTrim(Str(nT3H)) + "]"

				If nOpc == 4
					For n3 := 1 to oModel:GetModel( "MODEL_T3H" ):Length()
						oModel:GetModel( "MODEL_T3H" ):GoLine( n3 )
						oModel:GetModel( "MODEL_T3H" ):DeleteLine()
					Next n3
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
				nT3H := 1
				While oDados:XPathHasNode(cT3HPath)

					oModel:GetModel( "MODEL_T3H" ):lValid:= .T.

					If nOpc == 4 .or. nT3H > 1
						oModel:GetModel( "MODEL_T3H" ):AddLine()
					EndIf

					If oDados:XPathHasNode(cT3HPath + "/tpTrib")
						oModel:LoadValue( "MODEL_T3H", "T3H_TPTRIB", FTafGetVal( cT3HPath + "/tpTrib", "C", .F., @aIncons, .F. ) )
	 				EndIf

	 				If oDados:XPathHasNode(cT3HPath + "/nrProcJud")
						cIdProc := FGetIdInt( "nrProcJ", , cT3HPath + "/nrProcJud",,,,@cInconMsg, @nSeqErrGrv)
						oModel:LoadValue("MODEL_T3H", "T3H_IDPROC", cIdProc )
					EndIf

					If !Empty(cIdProc)
						If oDados:XPathHasNode(cT3HPath + "/codSusp" )
							oModel:LoadValue("MODEL_T3H", "T3H_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal( cT3HPath + "/", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )
						EndIf
						cCodSusp := Posicione("T5L",1,xFilial("T5L")+oModel:GetValue("MODEL_T3H", "T3H_IDSUSP") ,"T5L_CODSUS")
						oModel:LoadValue( "MODEL_T3H", "T3H_CODSUS", cCodSusp )
					EndIf

					oModel:LoadValue( "MODEL_T3H", "T3H_NOMEVE", "S2399" )

					nT3H++
					cT3HPath := cCabec + "infoTSVTermino/verbasResc/procJudTrab[" + AllTrim(Str(nT3H)) + "]"
				EndDo

				nC9J := 1
				cC9JPath := cCabec + "infoTSVTermino/verbasResc/infoMV/remunOutrEmpr[" + AllTrim(Str(nC9J)) + "]"

				If nOpc == 4
					For n3 := 1 to oModel:GetModel( "MODEL_C9J" ):Length()
						oModel:GetModel( "MODEL_C9J" ):GoLine( n3 )
						oModel:GetModel( "MODEL_C9J" ):DeleteLine()
					Next n3
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
				nC9J := 1
				While oDados:XPathHasNode(cC9JPath)

					oModel:GetModel( "MODEL_C9J" ):lValid:= .T.

					If nOpc == 4 .or. nC9J > 1
						oModel:GetModel( "MODEL_C9J" ):AddLine()
					EndIf

					If oDados:XPathHasNode(cC9JPath + "/tpInsc")
						oModel:LoadValue( "MODEL_C9J", "C9J_TPINSC", FTafGetVal( cC9JPath + "/tpInsc"	, "C", .F., @aIncons, .F. ) )
	 				EndIf

					If oDados:XPathHasNode(cC9JPath + "/nrInsc")
						oModel:LoadValue( "MODEL_C9J", "C9J_NRINSC", FTafGetVal( cC9JPath + "/nrInsc"  ,"C", .F., @aIncons, .F. ) )
	 				EndIf

					If oDados:XPathHasNode(cC9JPath + "/codCateg")
						oModel:LoadValue( "MODEL_C9J", "C9J_CODCAT", FGetIdInt( "codCateg", "", cC9JPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv ) )
	 				EndIf

					If oDados:XPathHasNode(cC9JPath + "/vlrRemunOE")
						oModel:LoadValue( "MODEL_C9J", "C9J_VLREMU", FTafGetVal( cC9JPath + "/vlrRemunOE","N", .F., @aIncons, .F. ) )
	 				EndIf

					oModel:LoadValue( "MODEL_C9J", "C9J_NOMEVE", "S2399" )

					nC9J++
					cC9JPath := cCabec + "infoTSVTermino/verbasResc/infoMV/remunOutrEmpr[" + AllTrim(Str(nC9J)) + "]"
				EndDo

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg) .And. Empty(aIncons)
				aChkDupl := TafFormCommit( oModel, .T. )
				If ValType( aChkDupl ) == "A"
					If aChkDupl[1]
						Aadd(aIncons, "ERRO19" + "|" + aChkDupl[2] + "|" + aChkDupl[3])
					Else
						lRet := .T.
					EndIf
				ElseIf ValType( aChkDupl ) == "L"
					If aChkDupl
						Aadd(aIncons, "ERRO19")
					Else
						lRet := .T.
					EndIf
				EndIf

				If lRet .And. lInfoRPT
					oInfoRPT := oReport:oVOReport
					oInfoRPT:SetIndApu( "1" )
					oInfoRPT:SetPeriodo( SubStr( StrTran( cDtTerm, "-", "" ), 1, 6 ) )
					oInfoRPT:SetCPF( AllTrim( cCPF ) )
					oInfoRPT:SetNome( AllTrim( cNome ) )
					oInfoRPT:SetAnalitico( aAnalitico )

					oReport:UpSert( "S-2399", "1", xFilial( "T92" ), oInfoRPT )

					oInfoRPT := oReport:oVOReport
					oInfoRPT:SetIndApu( "1" )
					oInfoRPT:SetPeriodo( SubStr( StrTran( cDtTerm, "-", "" ), 1, 6 ) )
					oInfoRPT:SetCPF( AllTrim( cCPF ) )
					oInfoRPT:SetNome( AllTrim( cNome ) )
					oInfoRPT:SetAnalitico( aAnalitico )				

					oReport:UpSert( "S-2399", "2", xFilial( "T92" ), oInfoRPT )
				EndIf

			Else
				Aadd(aIncons, cInconMsg)
				DisarmTransaction()
			EndIf

			oModel:DeActivate()
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
		EndIf

	End Transaction

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF280Rul
Regras para gravacao das informacoes do registro S-2399 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Felipe C. Seolin
@since 28/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF280Rul( cCabec as character, cInconMsg as character, nSeqErrGrv as numeric,;
							cCodEvent as character, cOwner as character, cIDTrabal as character,;
							cLayout as character )

	Local aRull as array

	Default cCabec     := "/eSocial/evtTSVTermino/"
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""
	Default cIDTrabal  := ""
	Default cLayout    := ""

	aRull			:= {}

	// Tratamento para a simplificação do e-Social
	If lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "ideEvento/indGuia"  ))
			aAdd( aRull, {"T92_TPGUIA", FTafGetVal(cCabec + "ideEvento/indGuia", "C", .F.)} )
		EndIf
	EndIf

	If Empty(cIDTrabal)
		// Tratamento para a simplificação do e-Social
		If lLaySimplif .AND. TafXNode( oDados , cCodEvent, cOwner,( cCabec + "ideTrabSemVinculo/matricula" ))
			cIDTrabal := FGetIdInt( "cpfTrab", "matricula", cCabec + "ideTrabSemVinculo/cpfTrab", cCabec + "ideTrabSemVinculo/matricula",,, @cInconMsg, @nSeqErrGrv,,,,,,,,,cLayout )
		Else
			cIDTrabal := FGetIdInt( "cpfTrab",, cCabec + "ideTrabSemVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", cCabec + "ideTrabSemVinculo/codCateg" )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "ideTrabSemVinculo/cpfTrab" ))
		Aadd( aRull, { "T92_TRABAL", cIDTrabal, "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,(cCabec + "infoTSVTermino/dtTerm"))
		aAdd( aRull, { "T92_DTERAV", FTafGetVal( cCabec + "infoTSVTermino/dtTerm", "D", .F. )} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,(cCabec + "infoTSVTermino/mtvDesligTSV"))
		aAdd( aRull, {"T92_MOTDES", FGetIdInt( "mtvDesligTSV","", cCabec + "infoTSVTermino/mtvDesligTSV",,,,@cInconMsg, @nSeqErrGrv )})
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoTSVTermino/pensAlim"  ))
		aAdd( aRull, {"T92_PENALI", FTafGetVal(cCabec + "infoTSVTermino/pensAlim", "C", .F.)} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoTSVTermino/percAliment"  ))
		aAdd( aRull, {"T92_PERALI", FTafGetVal(cCabec + "infoTSVTermino/percAliment", "N", .F.)} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoTSVTermino/vrAlim"  ))
		aAdd( aRull, {"T92_VLPALI", FTafGetVal(cCabec + "infoTSVTermino/vrAlim", "N", .F.)} )
	EndIf

	// Tratamento para a simplificação do e-Social
	If lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoTSVTermino/nrProcTrab"  ))
			aAdd( aRull, {"T92_NRPROC", FTafGetVal(cCabec + "infoTSVTermino/nrProcTrab", "C", .F.)} )
		EndIf
	EndIf

	aAdd( aRull, { "T92_NEWCPF", FTafGetVal(cCabec + "infoTSVTermino/mudancaCPF/novoCPF", "C", .F.) } )

	If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "infoTSVTermino/verbasResc/infoMV/indMV" ))
		aAdd( aRull, { "T92_INDMVI" , FTafGetVal( cCabec + "infoTSVTermino/verbasResc/infoMV/indMV" , "C", .F. )} )
	EndIf

	If lSimplBeta .and. TafColumnPos("T92_INDREM")
		If TafXNode( oDados , cCodEvent, cOwner,(cCabec + "infoTSVTermino/remunAposTerm/indRemun"))
			aAdd( aRull, { "T92_INDREM" , FTafGetVal( cCabec + "infoTSVTermino/remunAposTerm/indRemun", "C", .F.)} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner,(cCabec + "infoTSVTermino/remunAposTerm/dtFimRemun"))
			aAdd( aRull, { "T92_DTFREM" , FTafGetVal( cCabec + "infoTSVTermino/remunAposTerm/dtFimRemun", "D", .F.)} )
		EndIf
	Else
		If TafXNode( oDados , cCodEvent, cOwner,(cCabec + "infoTSVTermino/quarentena/dtFimQuar"))
			aAdd( aRull, { "T92_DTQUA" , FTafGetVal( cCabec + "infoTSVTermino/quarentena/dtFimQuar"	, "D", .F.)} )
		EndIf
	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel as object, nRecno as numeric, lRotExc as logical)

	Local cVerAnt    as character
	Local cProtocolo as character
	Local cVersao    as character
	Local cChvRegAnt as character
	Local cEvento    as character
	Local cId        as character
	Local nOperation as numeric
	Local nI         as numeric
	Local nIJAdd     as numeric
	Local nIKAdd     as numeric

	Local aGrava     as array
	Local aGravaT3H  as array
	Local aGravaC9J  as array
	Local aGravaT3I  as array
	Local aGravaV9O  as array
	Local aGravaT3J  as array
	Local aGravaCMK  as array
	Local aGravaT15  as array
	Local aGravaT16  as array

	Local oModelT92  as object
	Local oModelC9J  as object
	Local oModelT3H  as object
	Local oModelT3I  as object
	Local oModelV9O  as object
	Local oModelT3J  as object
	Local oModelCMK  as object
	Local oModelT15  as object
	Local oModelT16  as object

	Local lInclui    as logical

	Default oModel  := Nil
	Default nRecno  := 1
	Default lRotExc := .F.

	cVerAnt         := ""
	cProtocolo      := ""
	cVersao         := ""
	cChvRegAnt      := ""
	cEvento         := ""
	cId             := ""

	nOperation      := oModel:GetOperation()
	nI              := 0
	nIJAdd          := 0
	nIKAdd          := 0

	aGrava          := {}
	aGravaT3H       := {}
	aGravaC9J       := {}
	aGravaT3I       := {}
	aGravaV9O       := {}
	aGravaT3J       := {}
	aGravaCMK       := {}
	aGravaT15       := {}
	aGravaT16       := {}

	oModelT92       := oModel:GetModel( "MODEL_T92" )
	oModelC9J       := oModel:GetModel( "MODEL_C9J" )
	oModelT3H       := oModel:GetModel( "MODEL_T3H" )
	oModelT3I       := oModel:GetModel( "MODEL_T3I" )

	If lSimplBeta .and. TafColumnPos("V9O_TPINSC")
		oModelV9O       := oModel:GetModel( "MODEL_V9O" )
	EndIf
	
	oModelT3J       := oModel:GetModel( "MODEL_T3J" )
	oModelCMK       := oModel:GetModel( "MODEL_CMK" )
	oModelT15       := oModel:GetModel( "MODEL_T15" )
	oModelT16       := oModel:GetModel( "MODEL_T16" )

	lInclui := ( nOperation == MODEL_OPERATION_INSERT )

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	//Posiciona o item
	T92->( DBGoTo( nRecno ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao anterior do registro para gravacao do rastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVerAnt    := oModelT92:GetValue( "T92_VERSAO" )
	cProtocolo := oModelT92:GetValue( "T92_PROTUL" )
	cEvento    := oModelT92:GetValue( "T92_EVENTO" )
	cId        := oModelT92:GetValue( "T92_ID" )

	//Funcao para carregar os valores correntes do cadastro
	TAF280Carr( oModel, oModelT92, oModelC9J, oModelT3H, oModelT3I, oModelT3J, oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H, aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, oModelV9O, aGravaV9O )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seto o campo como Inativo e gravo a versao do novo registro³
	//³no registro anterior                                       ³
	//|                                                           |
	//|ATENCAO -> A alteracao destes campos deve sempre estar     |
	//|abaixo do Loop do For, pois devem substituir as informacoes|
	//|que foram armazenadas no Loop acima                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FAltRegAnt( "T92", "2" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu preciso setar a operacao do model³
	//³como Inclusao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//Esta funcao desativa o model corrente e inicia a operacao de inclusao das operacoes realizadas
	TAF280Comm( oModel, oModelT92, oModelC9J, oModelT3H, oModelT3I, oModelT3J, oModelCMK, oModelT15, oModelT16, aGrava, aGravaC9J, aGravaT3H, aGravaT3I, aGravaT3J, aGravaCMK, aGravaT15, aGravaT16, lInclui, oModelV9O, aGravaV9O )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao que sera gravada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVersao := xFunGetVer()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|ATENCAO -> A alteracao destes campos deve sempre estar     |
	//|abaixo do Loop do For, pois devem substituir as informacoes|
	//|que foram armazenadas no Loop acima                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:LoadValue( "MODEL_T92", "T92_VERSAO", cVersao    )
	oModel:LoadValue( "MODEL_T92", "T92_VERANT", cVerAnt    )
	oModel:LoadValue( "MODEL_T92", "T92_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_T92", "T92_PROTUL", ""         )
	oModel:LoadValue( "MODEL_T92", "T92_ID"	 , cId        )
	oModel:LoadValue( "MODEL_T92", "T92_EVENTO", "E" )
	oModel:LoadValue( "MODEL_T92", "T92_ATIVO" , "1" )

	//Gravo alteração para o Extemporâneo
	If lGoExtemp
		TafGrvExt( oModel, 'MODEL_T92', 'T92' )
	EndIf

	FwFormCommit( oModel )
	TAFAltStat( 'T92',"6" )

Return ( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF280Rpt
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Victor A. Barbosa
@since			22/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF280Rpt()

__lGrvRPT := TAFAlsInDic( "V3N" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadReportData
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Diego Santos
@since			22/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function LoadReportData(oModel, lInfoRPT)

	Local aSaveLines  := FwSaveRows(oModel)
	Local aArea       := GetArea()
	Local oModelT3I   := oModel:GetModel("MODEL_T3I")
	Local nT3I        := 1
	Local nT3J        := 1
	Local nCMK        := 1
	Local nPosValores := 1
	Local aAnalitico  := {}
	Local aRubrica    := {}
	Local cCodCat     := ""
	Local cMatric     := ""

	C9V->( DBSetOrder( 2 ) )
	If C9V->( MSSeek( xFilial( "C9V" ) + oModel:GetValue("MODEL_T92","T92_TRABAL") + "1" ) )

		// Tratamento para a simplificação do e-Social
		If lLaySimplif
			cMatric := C9V->C9V_MATTSV
		EndIf

		cCodCat	:= GetADVFVal( "C87", "C87_CODIGO", xFilial( "C87" ) + C9V->C9V_CATCI, 1, "" )

		For nT3I := 1 To oModelT3I:Length()
			oModelT3I:GoLine( nT3I )
			If !oModelT3I:IsEmpty() .And. !oModelT3I:IsDeleted()
				oModelT3J := oModel:GetModel("MODEL_T3J")
				For nT3J := 1 To oModelT3J:Length()
					oModelT3J:GoLine( nT3J )
					If !oModelT3J:IsEmpty() .And. !oModelT3J:IsDeleted()
						oModelCMK := oModel:GetModel("MODEL_CMK")
						For nCMK := 1 To oModelCMK:Length()
							oModelCMK:GoLine( nCMK )
							If !oModelCMK:IsEmpty() .And. !oModelCMK:IsDeleted()
								If lInfoRPT
									aRubrica := oReport:GetRubrica( oModelCMK:GetValue("CMK_CODRUB") )

									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT3J:GetValue("T3J_ESTABE") + "1", "C92_TPINSC" ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT3J:GetValue("T3J_ESTABE") + "1", "C92_NRINSC" ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + oModelT3J:GetValue("T3J_LOTTRB") + "1", "C99_CODIGO" ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	oModelCMK:GetValue("CMK_VLRRUB")
								EndIf
							EndIf
						Next nCMK
					EndIf
				Next nT3J
			EndIf
		Next nT3I
	Else
		TAFConOut("Funcionário não encontrado!!! V3N não será gravada")
	EndIf

	RestArea(aArea)
	FWRestRows( aSaveLines )

Return aAnalitico

//---------------------------------------------------------------------
/*/{Protheus.doc} SetLayout

@description	Função para alterar variaveis staticas de controle
				de Layout.
@author			Silas Gomes
@since			23/09/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function SetLayout()

	Local cEsocial   as character
	Local lOperation as logical
	Local lTAF280Xml as logical
	Local lTAF280GRV as logical
	Local lXTAFVEXC  as logical

	cEsocial   := ""
	lOperation := .F.
	lTAF280Xml := FWIsInCallStack("TAF280Xml")
	lTAF280GRV := FWIsInCallStack("TAF280GRV")
	lXTAFVEXC  := FWIsInCallStack("XTAFVEXC")

	If lTAF280GRV
		cEsocial := cLayNmSpac
	Else
		If Type("INCLUI") != "U" .And. Type("ALTERA") != "U"
			lOperation := !INCLUI .And. !ALTERA
		EndIf

		If lTAF280Xml .Or. lOperation .Or. lXTAFVEXC
			If TAFColumnPos("T92_LAYOUT")		
				cEsocial := T92->T92_LAYOUT
			Else
				lLaySimplif  := TAFLayESoc(, .T.)
				lSimplBeta   := TAFLayESoc("S_01_01_00", .T., .T.)			
			EndIf
		EndIf
	EndIf

	If !Empty(cEsocial)
		If Findfunction("TAFIsSimpl")
			lLaySimplif := TAFIsSimpl(AllTrim(cEsocial))
		EndIf

		If AllTrim(cEsocial) == "S_01_01_00"
			lSimplBeta  := .T.
		Else
			lSimplBeta  := .F.
		EndIf
	EndIf
	
Return

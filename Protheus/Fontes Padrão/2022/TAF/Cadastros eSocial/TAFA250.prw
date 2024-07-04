#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA250.CH"

#DEFINE CRLF 							Chr(13) + Chr(10)
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
#DEFINE ANALITICO_RECIBO 				15

Static lLaySimplif		:= TafLayESoc()
Static lSimplBeta   	:= TafLayESoc("S_01_01_00",, .T.)
Static oReport        	:= Nil
Static slRubERPPad    	:= Nil
Static __aRubrica     	:= {}
Static __aIdTabRub    	:= {}
Static __cFilCache    	:= ""
Static __cTmpName     	:= ""
Static __cIDChFil     	:= ""
Static cXmlInteg 		:= ""
Static __cPicFatR     	:= Nil
Static __cPicIdeM     	:= Nil
Static __cPicQtdR     	:= Nil
Static __cPicVlRe     	:= Nil
Static __cPicVlUn     	:= Nil
Static __cPicVlRu     	:= Nil
Static __cPicVlPg     	:= Nil
Static __cPicVPgD     	:= Nil
Static __cPicVAdv 		:= Nil
Static __cPicVCus 		:= Nil
Static __cPicQRRA		:= Nil
Static __lGrvRPT      	:= Nil
Static __lValidTabRub 	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA250
Cadastro de Folha de Pagamento

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA250()

	Private oBrw 		:= FWmBrowse():New()
	Private cNomEve		:= "S1200"
	Private cEvtPosic 	:= ""

	If  TafAtualizado()
		TafNewBrowse( "S-1200",,,, STR0001, , 2, 2 )
	EndIf
	
	oBrw:SetCacheView( .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("C91_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES");
	 .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF250View('C91',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF250Inc('C91',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('C91', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA250"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF250Xml" 						, "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'C91' )" 			, "10"} )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'C91', 'TAFA250' )" 	, "3" } ) //Chamo a Browse do Histórico
		Aadd( aFuncao, { "" , "StaticCall(TAFA250,PreXmlLote)" 	, "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA250' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA250", "C91", .F. ) // Menu dos extemporâneos
		Else
			aRotina	:=	xFunMnuTAF( "TAFA250" , , aFuncao)
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

	TAFXmlLote( 'C91', 'S-1200' , 'evtRemun' , 'TAF250Xml', ,oBrw )
	slRubERPPad := Nil	//Limpa variável no final do processo em lote
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local aTrigger	as array	
	Local nIC9Q   	as numeric
	Local nIT6Z   	as numeric
	Local nIC9M   	as numeric
	Local nIT6Y   	as numeric
	Local nIC9L   	as numeric
	Local oStruV1B	as object
	Local oStruV1C	as object
	Local oModel  	as object
	Local oStruC91	as object
	Local oStruC9K	as object
	Local oStruC9L	as object
	Local oStruC9M	as object
	Local oStruC9N	as object
	Local oStruC9O	as object
	Local oStruC9P	as object
	Local oStruC9Q	as object
	Local oStruC9R	as object
	Local oStruCRN	as object
	Local oStruT14	as object
	Local oStruT6W	as object
	Local oStruT6Y	as object
	Local oStruT6Z	as object
	Local oStruV6K	as object
	Local oStruV9K	as object

	aTrigger	:= TAF250Trigger()
	nIC9Q   	:= 0
	nIT6Z   	:= 0
	nIC9M   	:= 0
	nIT6Y   	:= 0
	nIC9L   	:= 0
	oStruV1B	:= Nil
	oStruV1C	:= Nil
	oModel  	:= MPFormModel():New("TAFA250",,, {|oModel| SaveModel(oModel)})
	oStruC91	:= FWFormStruct(1, "C91")
	oStruC9K	:= FWFormStruct(1, "C9K")
	oStruC9L	:= FWFormStruct(1, "C9L")
	oStruC9M	:= FWFormStruct(1, "C9M")
	oStruC9N	:= FWFormStruct(1, "C9N")
	oStruC9O	:= FWFormStruct(1, "C9O")
	oStruC9P	:= FWFormStruct(1, "C9P")
	oStruC9Q	:= FWFormStruct(1, "C9Q")
	oStruC9R	:= FWFormStruct(1, "C9R")
	oStruCRN	:= FWFormStruct(1, "CRN")
	oStruT14	:= FWFormStruct(1, "T14")
	oStruT6W	:= FWFormStruct(1, "T6W")
	oStruT6Y	:= FWFormStruct(1, "T6Y")
	oStruT6Z	:= FWFormStruct(1, "T6Z")
	oStruV6K	:= FWFormStruct(1, "V6K")
	oStruV9K	:= FWFormStruct(1, "V9K")

	oStruC91:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
	

	If TafColumnPos("C9Q_MATRIC")
		oStruC9Q:AddTrigger("C9Q_MATRIC", "C9Q_DTRABA",, {|| TAFGatC9PQ()})
	EndIf

	If !lLaySimplif
		oStruV1B := FWFormStruct( 1, 'V1B' )
		oStruV1C := FWFormStruct( 1, 'V1C' )
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel

		oStruC91:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT6W:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9K:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9L:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9M:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9N:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9O:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9P:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9Q:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9R:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCRN:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT14:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })

		If !lLaySimplif
			oStruT6Y:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruT6Z:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV1B:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV1C:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		Else
			oStruV6K:SetProperty("V6K_DIA", MODEL_FIELD_VALID, {|oModel| lVldDiaTrb(oModel) })
		EndIf

	EndIf

	//A Obrigatoriedade está sendo colocada no fonte por que a tabela T14
	//é compartilhada com outros eventos e o campo de categoria é obrigatório
	//neste evento e em outros não.
	oStruT14:SetProperty( 'T14_CODCAT'   , MODEL_FIELD_OBRIGAT , .T.  )

	oModel:AddFields('MODEL_C91', /*cOwner*/, oStruC91)

	If !lLaySimplif
		oModel:GetModel('MODEL_C91'):SetPrimaryKey({'C91_TRABAL', 'C91_PERAPU', 'C91_NOMEVE'})
	Else
		oModel:GetModel('MODEL_C91'):SetPrimaryKey({'C91_INDAPU', 'C91_PERAPU', 'C91_TPGUIA', 'C91_TRABAL', 'C91_ORIEVE' })
	EndIf

	//Remuneração do Trab. de Vínculo com Outras Empresas
	oModel:AddGrid('MODEL_T6W', 'MODEL_C91', oStruT6W)
	oModel:GetModel('MODEL_T6W'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6W'):SetUniqueLine({'T6W_TPINSC', 'T6W_NRINSC'})
	oModel:GetModel('MODEL_T6W'):SetMaxLine(999)
	oModel:SetRelation('MODEL_T6W', {{'T6W_FILIAL' , 'xFilial( "T6W" )'}, {'T6W_ID' , 'C91_ID'}, {'T6W_VERSAO' , 'C91_VERSAO'}}, T6W->(IndexKey(1)))

	//Informações de Processos Judiciais de Remuneração
	oModel:AddGrid( "MODEL_CRN", "MODEL_C91", oStruCRN )
	oModel:GetModel( "MODEL_CRN" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_CRN" ):SetUniqueLine( { "CRN_TPTRIB", "CRN_IDPROC", "CRN_CODSUS" } )
	oModel:GetModel( "MODEL_CRN" ):SetMaxLine( 99 )
	oModel:SetRelation( "MODEL_CRN", { { "CRN_FILIAL", 'xFilial( "CRN" )' }, { "CRN_ID", "C91_ID" }, { "CRN_VERSAO", "C91_VERSAO" } }, CRN->( IndexKey( 1 ) ) )
	
	If lLaySimplif
		oModel:AddGrid('MODEL_V6K', 'MODEL_C91', oStruV6K)
		oModel:GetModel('MODEL_V6K'):SetOptional(.T.)
		oModel:GetModel( "MODEL_V6K" ):SetUniqueLine( { "V6K_DIA" } )
		oModel:GetModel( "MODEL_V6K" ):SetMaxLine(31)
		oModel:SetRelation('MODEL_V6K', {{'V6K_FILIAL' , 'xFilial( "V6K" )'}, {'V6K_ID' , 'C91_ID'}, {'V6K_VERSAO' , 'C91_VERSAO'}}, V6K->(IndexKey(1)))
	EndIf

	// IDENTIFICAÇÃO RECIBO DE PAGAMENTO
	oModel:AddGrid('MODEL_T14', 'MODEL_C91', oStruT14)
	oModel:GetModel('MODEL_T14'):SetOptional(.T.)
	oModel:GetModel('MODEL_T14'):SetUniqueLine({'T14_IDEDMD'})
	oModel:GetModel('MODEL_T14'):SetMaxLine(999)

	//INFORMAÇÕES DO ESTABELECIMENTO/LOTAÇÃO
	oModel:AddGrid( "MODEL_C9K", "MODEL_T14", oStruC9K )
	oModel:GetModel( "MODEL_C9K" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_C9K" ):SetUniqueLine( { "C9K_ESTABE", "C9K_LOTACA", "C9K_CODLOT", "C9K_TPINSC", "C9K_NRINSC" } )
	oModel:GetModel( "MODEL_C9K" ):SetMaxLine( 500 )
	oModel:GetModel( 'MODEL_C9K' ):SetLPre({|| PreVldLine()})

	//INFORMAÇÕES DO REMUNERAÇÃO DO PERIODO DE APURAÇÃO
	oModel:AddGrid('MODEL_C9L', 'MODEL_C9K', oStruC9L)
	oModel:GetModel('MODEL_C9L'):SetOptional(.T.)
	oModel:GetModel('MODEL_C9L'):SetUniqueLine( { 'C9L_TRABAL', 'C9L_DTRABA' } )
	oModel:GetModel('MODEL_C9L'):SetMaxLine(8)

	//INFORMAÇÕES DOS ITENS DE REMUNERAÇÃO
	oModel:AddGrid('MODEL_C9M', 'MODEL_C9L', oStruC9M)
	oModel:GetModel('MODEL_C9M'):SetOptional(.T.)
	oModel:GetModel('MODEL_C9M'):SetUniqueLine( {'C9M_CODRUB', 'C9M_RUBRIC', 'C9M_IDTABR' } )
	oModel:GetModel('MODEL_C9M'):SetMaxLine(200)
	oModel:GetModel('MODEL_C9M'):SetPost({|oSubModel| ModelOk(oSubModel)},.F.,.T.)

	If !lLaySimplif

		//INFORMAÇÕES DO PLANO DE SAÚDE
		oModel:AddGrid( 'MODEL_T6Y', "MODEL_C9L", oStruT6Y )
		oModel:GetModel('MODEL_T6Y'):SetOptional( .T. )
		oModel:GetModel('MODEL_T6Y'):SetUniqueLine( { "T6Y_CNPJOP", "T6Y_REGANS" } )
		oModel:GetModel('MODEL_T6Y'):SetMaxLine( 99 )
		oModel:GetModel('MODEL_T6Y'):SetPost({|oSubModel| ModelOk(oSubModel)},.F.,.T.)

		//INFORMAÇÕES DO PLANO DE SAÚDE - Det. Operadora Plano de Saúde
		oModel:AddGrid( "MODEL_T6Z", "MODEL_T6Y", oStruT6Z )
		oModel:GetModel( "MODEL_T6Z" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T6Z" ):SetUniqueLine( { "T6Z_DTNDEP", "T6Z_NOMDEP", "T6Z_TPDEP" } )
		oModel:GetModel( "MODEL_T6Z" ):SetMaxLine( 99 )

	EndIf

	If  lSimplBeta .And. TafColumnPos("T14_INDRRA")
		//IDENTIFICAÇÃO DOS ADVOGADOS
		oModel:AddGrid( "MODEL_V9K", "MODEL_T14", oStruV9K )
		oModel:GetModel( "MODEL_V9K" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V9K" ):SetUniqueLine( { "V9K_TPINSC", "V9K_NRINSC" } )
		oModel:GetModel( "MODEL_V9K" ):SetMaxLine( 99 )
	EndIf

	// INFORMAÇÕES DE ACORDO
	oModel:AddGrid('MODEL_C9N', 'MODEL_T14', oStruC9N)
	oModel:GetModel('MODEL_C9N'):SetOptional(.T.)

	If !lLaySimplif
		oModel:GetModel('MODEL_C9N'):SetUniqueLine({'C9N_DTACOR', 'C9N_TPACOR','C9N_COMPAC','C9N_DTEFAC'})
	Else
		oModel:GetModel('MODEL_C9N'):SetUniqueLine({'C9N_DTACOR', 'C9N_TPACOR'})
	EndIf
	oModel:GetModel('MODEL_C9N'):SetMaxLine(8)

	// Remoção das obrigatoriedades dos múltiplos vínculos
	oStruC9K:SetProperty( 'C9K_ESTABE', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9K:SetProperty( 'C9K_LOTACA', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9L:SetProperty( 'C9L_TRABAL', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9M:SetProperty( 'C9M_CODRUB', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9P:SetProperty( 'C9P_LOTACA', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9P:SetProperty( 'C9P_ESTABE', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9Q:SetProperty( 'C9Q_TRABAL', MODEL_FIELD_OBRIGAT , .F. )
	oStruC9R:SetProperty( 'C9R_CODRUB', MODEL_FIELD_OBRIGAT , .F. )

	// INFORMAÇÕES DO PERIODO
	oModel:AddGrid('MODEL_C9O', 'MODEL_C9N', oStruC9O)
	oModel:GetModel('MODEL_C9O'):SetOptional(.T.)
	oModel:GetModel('MODEL_C9O'):SetUniqueLine({'C9O_PERREF'})
	oModel:GetModel('MODEL_C9O'):SetMaxLine(180)

	//INFORMAÇÕES DO ESTABELECIMENTO/LOTAÇÃO
	oModel:AddGrid( "MODEL_C9P", "MODEL_C9O", oStruC9P )
	oModel:GetModel( "MODEL_C9P" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_C9P" ):SetUniqueLine( { "C9P_ESTABE", "C9P_LOTACA", "C9P_CODLOT", "C9P_TPINSC", "C9P_NRINSC" } )
	oModel:GetModel( "MODEL_C9P" ):SetMaxLine( 500 )

	// INFORMAÇÕES DA REMUNERAÇÃO DO TRABALHADOR
	oModel:AddGrid('MODEL_C9Q', 'MODEL_C9P', oStruC9Q)
	oModel:GetModel('MODEL_C9Q'):SetOptional(.T.)
	oModel:GetModel('MODEL_C9Q'):SetUniqueLine( {'C9Q_TRABAL', "C9Q_DTRABA" , "C9Q_MATRIC"} )
	oModel:GetModel('MODEL_C9Q'):SetMaxLine(8)

	// INFORMAÇÕES DOS ITENS DA REMUNERAÇÃO
	oModel:AddGrid('MODEL_C9R', 'MODEL_C9Q', oStruC9R)
	oModel:GetModel('MODEL_C9R'):SetOptional(.T.)
	oModel:GetModel('MODEL_C9R'):SetUniqueLine( { 'C9R_CODRUB', 'C9R_RUBRIC', 'C9R_IDTABR' } )
	oModel:GetModel('MODEL_C9R'):SetMaxLine(200)

	// RELATIONS DO PERIODO DE APURAÇÃO ANTERIOR
	oModel:SetRelation('MODEL_C9N', {{'C9N_FILIAL' , 'xFilial( "C9N" )'}, {'C9N_ID' , 'C91_ID'}, {'C9N_VERSAO' , 'C91_VERSAO'}, {'C9N_RECIBO' , 'T14_IDEDMD'}}, C9N->(IndexKey(1)))
	If !taf250Leg(C91->C91_FILIAL,C91->C91_ID,C91->C91_VERSAO)

		oModel:SetRelation('MODEL_C9O', {{'C9O_FILIAL' , 'xFilial( "C9O" )'}, {'C9O_ID' , 'C91_ID'}, {'C9O_VERSAO' , 'C91_VERSAO'}, {'C9O_RECIBO' , 'T14_IDEDMD'}, {'C9O_DTACOR' , 'C9N_DTACOR'}, {'C9O_TPACOR' , 'C9N_TPACOR'}, {'C9O_COMPAC' , 'C9N_RELACO'}}, C9O->(IndexKey(1)))
		oModel:SetRelation('MODEL_C9P', {{'C9P_FILIAL' , 'xFilial( "C9P" )'}, {'C9P_ID' , 'C91_ID'}, {'C9P_VERSAO' , 'C91_VERSAO'}, {'C9P_RECIBO' , 'T14_IDEDMD'}, {'C9P_DTACOR' , 'C9N_DTACOR'}, {'C9P_TPACOR' , 'C9N_TPACOR'}, {'C9P_COMPAC' , 'C9N_RELACO'}, {'C9P_PERREF' , 'C9O_PERREF'}}, C9P->(IndexKey(1)))

		IIF(FWSIXUtil():ExistIndex( "C9Q", "C9QI4", .T.), nIC9Q := 4, nIC9Q := 3)
		oModel:SetRelation('MODEL_C9Q', {{'C9Q_FILIAL' , 'xFilial( "C9Q" )'}, {'C9Q_ID' , 'C91_ID'}, {'C9Q_VERSAO' , 'C91_VERSAO'}, {'C9Q_RECIBO' , 'T14_IDEDMD'}, {'C9Q_DTACOR' , 'C9N_DTACOR'}, {'C9Q_TPACOR' , 'C9N_TPACOR'}, {'C9Q_COMPAC' , 'C9N_RELACO'}, {'C9Q_PERREF' , 'C9O_PERREF'}, {'C9Q_ESTABE' , 'C9P_ESTABE'}, {'C9Q_LOTACA' , 'C9P_LOTACA'}, { "C9Q_CODLOT", "C9P_CODLOT" }, { "C9Q_TPINSC", "C9P_TPINSC" }, { "C9Q_NRINSC", "C9P_NRINSC" } }, C9Q->(IndexKey(nIC9Q)))

		oModel:SetRelation('MODEL_C9R', {{'C9R_FILIAL' , 'xFilial( "C9R" )'}, {'C9R_ID' , 'C91_ID'}, {'C9R_VERSAO' , 'C91_VERSAO'}, {'C9R_RECIBO' , 'T14_IDEDMD'},;
			{'C9R_DTACOR' , 'C9N_DTACOR'}, {'C9R_TPACOR' , 'C9N_TPACOR'}, {'C9R_COMPAC' , 'C9N_RELACO'}, {'C9R_PERREF' , 'C9O_PERREF'}, {'C9R_ESTABE' , 'C9P_ESTABE'},;
			{'C9R_LOTACA' , 'C9P_LOTACA'}, {'C9R_TRABAL' , 'C9Q_TRABAL'}, { "C9R_MATRIC", "C9Q_DTRABA" }, { "C9R_CODLOT", "C9P_CODLOT" },;
			{"C9R_TPINSC" ,"C9P_TPINSC"}, {"C9R_NRINSC", "C9P_NRINSC"}  }, C9R->(IndexKey(1)))

	Else

		oModel:SetRelation('MODEL_C9O', {{'C9O_FILIAL' , 'xFilial( "C9O" )'}, {'C9O_ID' , 'C91_ID'}, {'C9O_VERSAO' , 'C91_VERSAO'}, {'C9O_RECIBO' , 'T14_IDEDMD'}, {'C9O_DTACOR' , 'C9N_DTACOR'}, {'C9O_TPACOR' , 'C9N_TPACOR'}, {'C9O_COMPAC' , 'C9N_COMPAC'}}, C9O->(IndexKey(1)))
		oModel:SetRelation('MODEL_C9P', {{'C9P_FILIAL' , 'xFilial( "C9P" )'}, {'C9P_ID' , 'C91_ID'}, {'C9P_VERSAO' , 'C91_VERSAO'}, {'C9P_RECIBO' , 'T14_IDEDMD'}, {'C9P_DTACOR' , 'C9N_DTACOR'}, {'C9P_TPACOR' , 'C9N_TPACOR'}, {'C9P_COMPAC' , 'C9N_COMPAC'}, {'C9P_PERREF' , 'C9O_PERREF'}}, C9P->(IndexKey(1)))

		IIF(FWSIXUtil():ExistIndex( "C9Q", "C9QI4", .T.), nIC9Q := 4, nIC9Q := 3)
		oModel:SetRelation('MODEL_C9Q', {{'C9Q_FILIAL' , 'xFilial( "C9Q" )'}, {'C9Q_ID' , 'C91_ID'}, {'C9Q_VERSAO' , 'C91_VERSAO'}, {'C9Q_RECIBO' , 'T14_IDEDMD'}, {'C9Q_DTACOR' , 'C9N_DTACOR'}, {'C9Q_TPACOR' , 'C9N_TPACOR'}, {'C9Q_COMPAC' , 'C9N_COMPAC'}, {'C9Q_PERREF' , 'C9O_PERREF'}, {'C9Q_ESTABE' , 'C9P_ESTABE'}, {'C9Q_LOTACA' , 'C9P_LOTACA'}, { "C9Q_CODLOT", "C9P_CODLOT" }, { "C9Q_TPINSC", "C9P_TPINSC" }, { "C9Q_NRINSC", "C9P_NRINSC" } }, C9Q->(IndexKey(nIC9Q)))

		oModel:SetRelation('MODEL_C9R', {{'C9R_FILIAL' , 'xFilial( "C9R" )'}, {'C9R_ID' , 'C91_ID'}, {'C9R_VERSAO' , 'C91_VERSAO'}, {'C9R_RECIBO' , 'T14_IDEDMD'},;
			{'C9R_DTACOR' , 'C9N_DTACOR'}, {'C9R_TPACOR' , 'C9N_TPACOR'}, {'C9R_COMPAC' , 'C9N_COMPAC'}, {'C9R_PERREF' , 'C9O_PERREF'}, {'C9R_ESTABE' , 'C9P_ESTABE'},;
			{'C9R_LOTACA' , 'C9P_LOTACA'}, {'C9R_TRABAL' , 'C9Q_TRABAL'}, { "C9R_MATRIC", "C9Q_DTRABA" }, { "C9R_CODLOT", "C9P_CODLOT" },;
			{"C9R_TPINSC" ,"C9P_TPINSC"}, {"C9R_NRINSC", "C9P_NRINSC"}  }, C9R->(IndexKey(1)))

	EndIf
	// RELATIONS DO PERIODO DE APURAÇÃO
	oModel:SetRelation('MODEL_T14', {{'T14_FILIAL' , 'xFilial( "T14" )'}, {'T14_ID' , 'C91_ID'}, {'T14_VERSAO' , 'C91_VERSAO'}}, T14->(IndexKey(1)))
	oModel:SetRelation('MODEL_C9K', {{'C9K_FILIAL' , 'xFilial( "C9K" )'}, {'C9K_ID' , 'C91_ID'}, {'C9K_VERSAO' , 'C91_VERSAO'}, {'C9K_RECIBO' , 'T14_IDEDMD'}}, C9K->(IndexKey(1)))

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oModel:SetRelation('MODEL_V9K', {{'V9K_FILIAL' , 'xFilial( "V9K" )'}, {'V9K_ID' , 'C91_ID'}, {'V9K_VERSAO' , 'C91_VERSAO'}, {'V9K_RECIBO' , 'T14_IDEDMD'}}, V9K->(IndexKey(1)))
	EndIf

	IIF(FWSIXUtil():ExistIndex( "C9L" , "C9LI4" , .T. ), nIC9L := 4, nIC9L := 1)
	oModel:SetRelation('MODEL_C9L', {{'C9L_FILIAL' , 'xFilial( "C9L" )'}, {'C9L_ID' , 'C91_ID'}, {'C9L_VERSAO' , 'C91_VERSAO'}, {'C9L_RECIBO' , 'T14_IDEDMD'} ,{'C9L_ESTABE' , 'C9K_ESTABE'}, {'C9L_LOTACA' , 'C9K_LOTACA'}, {'C9L_CODLOT','C9K_CODLOT'}, {'C9L_TPINSC','C9K_TPINSC'}, {'C9L_NRINSC','C9K_NRINSC'}  }, C9L->(IndexKey(nIC9L)))

	IIF(FWSIXUtil():ExistIndex( "C9M" , "C9MI4" , .T. ), nIC9M := 4, nIC9M := 3)
	oModel:SetRelation('MODEL_C9M', {{'C9M_FILIAL' , 'xFilial( "C9M" )'}, {'C9M_ID' , 'C91_ID'}, {'C9M_VERSAO' , 'C91_VERSAO'}, {'C9M_RECIBO' , 'T14_IDEDMD'}, {'C9M_ESTABE' , 'C9K_ESTABE'}, {'C9M_LOTACA' , 'C9K_LOTACA'}, {'C9M_TRABAL' , 'C9L_TRABAL'}, {'C9M_CODLOT','C9K_CODLOT'}, {'C9M_TPINSC','C9K_TPINSC'}, {'C9M_NRINSC','C9K_NRINSC'}, {'C9M_DTRABA', 'C9L_DTRABA'} }, C9M->(IndexKey(nIC9M)))

	//T6Y_FILIAL+T6Y_ID+T6Y_VERSAO+T6Y_RECIBO+T6Y_ESTABE+T6Y_LOTACA+T6Y_TRABAL+T6sY_CNPJ+T6Y_REGANS
	If !lLaySimplif

		IIF(FWSIXUtil():ExistIndex( "T6Y", "T6YI6", .T.), nIT6Y := 6, nIT6Y := 1)
		oModel:SetRelation('MODEL_T6Y', {{'T6Y_FILIAL' , 'xFilial( "T6Y" )'},{'T6Y_ID' , 'C91_ID'}, {'T6Y_VERSAO' , 'C91_VERSAO'}, {'T6Y_RECIBO' , 'T14_IDEDMD'}, {'T6Y_ESTABE' , 'C9K_ESTABE'}, {'T6Y_LOTACA' , 'C9K_LOTACA'}, {'T6Y_TRABAL' , 'C9L_TRABAL'}, {'T6Y_CODLOT', 'C9K_CODLOT'}, {'T6Y_DTRABA', 'C9L_DTRABA'}, {'T6Y_TPINSC' , 'C9K_TPINSC'}, {'T6Y_NRINSC' , 'C9K_NRINSC'} }, T6Y->(IndexKey(nIT6Y)))
		//T6Z_FILIAL+T6Z_ID+T6Z_VERSAO+T6Z_RECIBO+T6Z_ESTABE+T6Z_LOTACA+T6Z_TRABAL+T6Z_CNPJ+T6Z_REGANS+T6Z_SEQUEN
		IIF(FWSIXUtil():ExistIndex( "T6Z", "T6ZI5", .T.), nIT6Z := 5, nIT6Z := 1)
		oModel:SetRelation('MODEL_T6Z', {{'T6Z_FILIAL' , 'xFilial( "T6Z" )'},{'T6Z_ID' , 'C91_ID'}, {'T6Z_VERSAO' , 'C91_VERSAO'}, {'T6Z_RECIBO' , 'T14_IDEDMD'}, {'T6Z_ESTABE' , 'C9K_ESTABE'}, {'T6Z_LOTACA' , 'C9K_LOTACA'}, {'T6Z_TRABAL' , 'C9L_TRABAL'}, {'T6Z_CNPJOP' , 'T6Y_CNPJOP'}, {'T6Z_REGANS' , 'T6Y_REGANS'}, {'T6Z_CODLOT', 'C9K_CODLOT'}, {'T6Z_DTRABA', 'C9L_DTRABA'}, {'T6Z_TPINSC' , 'C9K_TPINSC'}, {'T6Z_NRINSC' , 'C9K_NRINSC'} }, T6Z->(IndexKey(nIT6Z)))

		//INFORMAÇÕES DE CONVOCAÇÃO DE TRABALHO INTERMITENTE PERIODO DE APURAÇÃO
		oModel:AddGrid('MODEL_V1B', 'MODEL_C9L', oStruV1B)
		oModel:GetModel('MODEL_V1B'):SetOptional(.T.)
		oModel:GetModel('MODEL_V1B'):SetUniqueLine({'V1B_IDCONV'})
		oModel:GetModel('MODEL_V1B'):SetMaxLine(99)

		oModel:SetRelation('MODEL_V1B', {{'V1B_FILIAL' , 'xFilial( "V1B" )'}, {'V1B_ID' , 'C91_ID'}, {'V1B_VERSAO' , 'C91_VERSAO'}, {'V1B_RECIBO' , 'T14_IDEDMD'}, {'V1B_ESTABE' , 'C9K_ESTABE'}, {'V1B_LOTACA' , 'C9K_LOTACA'}, {'V1B_TRABAL' , 'C9L_TRABAL'}}, V1B->(IndexKey(1)))

		//INFORMAÇÕES DE CONVOCAÇÃO DE TRABALHO INTERMITENTE PERIODO DE ANTERIOR
		oModel:AddGrid('MODEL_V1C', 'MODEL_C9Q', oStruV1C)
		oModel:GetModel('MODEL_V1C'):SetOptional(.T.)
		oModel:GetModel('MODEL_V1C'):SetUniqueLine({'V1C_IDCONV'})
		oModel:GetModel('MODEL_V1C'):SetMaxLine(200)

		oModel:SetRelation('MODEL_V1C', {{'V1C_FILIAL' , 'xFilial( "V1C" )'}, {'V1C_ID' , 'C91_ID'}, {'V1C_VERSAO' , 'C91_VERSAO'}, {'V1C_RECIBO' , 'T14_IDEDMD'}, {'V1C_DTACOR' , 'C9N_DTACOR'}, {'V1C_TPACOR' , 'C9N_TPACOR'}, {'V1C_PERREF' , 'C9O_PERREF'}, {'V1C_ESTABE' , 'C9P_ESTABE'}, {'V1C_LOTACA' , 'C9P_LOTACA'}, {'V1C_TRABAL' , 'C9Q_TRABAL'}}, V1C->(IndexKey(1)))
	
	EndIf

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     as object
	Local oStruC91a  as object
	Local oStruC91b  as object
	Local oStruC91c  as object
	Local oStruC91d  as object
	Local oStruT6W   as object
	Local oStruC9K   as object
	Local oStruC9L   as object
	Local oStruC9M   as object
	Local oStruC9N   as object
	Local oStruC9O   as object
	Local oStruC9P   as object
	Local oStruC9Q   as object
	Local oStruC9R   as object
	Local oStruCRN   as object
	Local oStruT14   as object
	Local oStruV6K   as object
	Local oStruT6Y   as object
	Local oStruT6Z   as object
	Local oStruV1B	 as object
	Local oStruV1C	 as object
	Local oStruV9K	 as object
	Local oView      as object
	Local aCmpGrp    as array
	Local cCmpFil    as character
	Local cGrp1      as character
	Local cGrp2      as character
	Local cGrp3      as character
	Local cGrp4      as character
	Local cGrp7      as character
	Local cGrp5      as character
	Local cGrp6      as character
	Local cTpLot     as character
	Local cAbaApur   as character
	Local cAbaAnt    as character
	Local cAbaRRA    as character
	Local nI         as numeric
	Local lIncMV     as logical
	Local lCallInc   as logical

	oModel    := FWLoadModel( 'TAFA250' )
	oStruC91a := Nil
	oStruC91b := Nil
	oStruC91c := Nil
	oStruC91d := Nil
	oStruT6W  := FWFormStruct( 2, 'T6W' )
	oStruC9K  := FWFormStruct( 2, 'C9K' )
	oStruC9L  := FWFormStruct( 2, 'C9L' )
	oStruC9M  := FWFormStruct( 2, 'C9M' )
	oStruC9N  := FWFormStruct( 2, 'C9N' )
	oStruC9O  := FWFormStruct( 2, 'C9O' )
	oStruC9P  := FWFormStruct( 2, 'C9P' )
	oStruC9Q  := FWFormStruct( 2, 'C9Q' )
	oStruC9R  := FWFormStruct( 2, 'C9R' )
	oStruCRN  := FWFormStruct( 2, 'CRN' )
	oStruT14  := FWFormStruct( 2, 'T14' )
	oStruV6K  := FWFormStruct( 2, 'V6K' )
	oStruT6Y  := FWFormStruct( 2, 'T6Y' )
	oStruT6Z  := FWFormStruct( 2, 'T6Z' )
	oStruV1B  := IIF(!lLaySimplif, FWFormStruct( 2, 'V1B' ), Nil)
	oStruV1C  := IIF(!lLaySimplif, FWFormStruct( 2, 'V1C' ), Nil)	
	oView     := FWFormView():New()
	aCmpGrp   := {}
	cCmpFil   := ''
	cGrp1     := ''
	cGrp2     := ''
	cGrp3     := ''
	cGrp4     := ''
	cGrp7     := ''
	cGrp5     := ''
	cGrp6     := ''
	cTpLot    := ''	
	nI        := 0
	lIncMV    := .F.
	lCallInc  := .F.

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)
		
	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		cAbaApur  := "ABA02"
		cAbaAnt   := "ABA03"
		cAbaRRA   := "ABA01"
		oStruV9K  := FWFormStruct( 2, 'V9K' )
	Else
		cAbaApur  := "ABA01"
		cAbaAnt   := "ABA02"
		cAbaRRA   := ""
		oStruV9K  := Nil

		If TafColumnPos("T14_INDRRA")
			oStruT14:RemoveField( "T14_INDRRA" )
			oStruT14:RemoveField( "T14_TPPRRA" )
			oStruT14:RemoveField( "T14_NRPRRA" )
			oStruT14:RemoveField( "T14_DESCRA" )
			oStruT14:RemoveField( "T14_QTMRRA" )
			oStruT14:RemoveField( "T14_VLRCUS" )
			oStruT14:RemoveField( "T14_VLRADV" )
		EndIf
	EndIf	

	// Informações de Apuração/Identificação do Trabalhador
	If !lLaySimplif
		cGrp1 := 'C91_ID|C91_INDAPU|C91_PERAPU|'
	Else
		cGrp1 := 'C91_ID|C91_INDAPU|C91_PERAPU|C91_TPGUIA|'
	EndIf

	oStruC91a := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cGrp1 } )

	If FWIsInCallStack( "TAF250Inc" ) .AND. !FWIsInCallStack( "TAF250AUTI" )
		lCallInc 	:= .T.
		lIncMV 		:= Aviso( "Atenção", "A folha de pagamento a ser incluída é de um funcionário com ";
			+ "múltiplos vínculos?", {"Sim", "Não"}, 2 ) == 1
	ElseIf FWIsInCallStack( "TAF250AUTI" )
		lCallInc 	:= .T.
	EndIf

	// --> Tratamento para múltiplos vínculos, remover os campos de label "redundantes" para o cliente
	If ( lCallInc .And. !lIncMV ) .Or. ( !lCallInc .And. !Empty( C91->C91_TRABAL ) )
		cGrp2 := 'C91_TRABAL|C91_DTRABA|'
	ElseIf !lLaySimplif
		cGrp2 := 'C91_CPF|C91_NIS|'
		cGrp6 := 'C91_NOME|C91_NASCTO|'
	Else
		cGrp2 := 'C91_CPF|'
		cGrp6 := 'C91_NOME|C91_NASCTO|'
	EndIf

	oStruC9P:SetProperty( "C9P_TPINSC", MVC_VIEW_COMBOBOX, {"","1=CNPJ","2=CPF","3=CAEPF","4=CNO"}  )

	If ( lCallInc .And. !lIncMV ) .Or. ( !lCallInc .And. !Empty( C91->C91_TRABAL ) )

		If !lCallInc

			C9K->(DbSetOrder(1))
			C9K->(MsSeek(xFilial("C9K") + C91->C91_ID + C91->C91_VERSAO))	

			C99->(DbSetOrder(1))
			C99->(MsSeek(xFilial("C99") + C9K->C9K_LOTACA))

			cTpLot 	:= C99->C99_TPLOT

		EndIf

		If Empty(cTpLot) .Or. cTpLot <> "000002" .Or. (cTpLot == "000002" .And. !Empty(C9K->C9K_ESTABE) .And. Empty(C9K->C9K_TPINSC))
			oStruC9K:RemoveField( "C9K_CODLOT" )
			oStruC9K:RemoveField( "C9K_TPINSC" )
			oStruC9K:RemoveField( "C9K_NRINSC" )
		EndIf

		oStruC9M:RemoveField( "C9M_RUBRIC" )
		oStruC9M:RemoveField( "C9M_IDTABR" )
		oStruC9P:RemoveField( "C9P_CODLOT" )
		oStruC9P:RemoveField( "C9P_TPINSC" )
		oStruC9P:RemoveField( "C9P_NRINSC" )
		oStruC9R:RemoveField( "C9R_RUBRIC" )
		oStruC9R:RemoveField( "C9R_IDTABR" )

		IF TafColumnPos( "C9Q_MATRIC" )
			oStruC9Q:RemoveField( "C9Q_MATRIC" )
		EndIf

		IF !taf250Leg(C91->C91_FILIAL,C91->C91_ID,C91->C91_VERSAO)
			oStruC9N:RemoveField( "C9N_RELACO" )
		EndIf

	Else

		oStruC9K:RemoveField( "C9K_ESTABE" )
		oStruC9K:RemoveField( "C9K_DESTAB" )
		oStruC9K:RemoveField( "C9K_LOTACA" )
		oStruC9K:RemoveField( "C9K_DLOTAC" )
		oStruC9L:RemoveField( "C9L_TRABAL" )
		oStruC9M:RemoveField( "C9M_CODRUB" )
		oStruC9M:RemoveField( "C9M_DCODRU" )
		oStruC9P:RemoveField( "C9P_LOTACA" )
		oStruC9P:RemoveField( "C9P_DLOTAC" )
		oStruC9P:RemoveField( "C9P_ESTABE" )
		oStruC9P:RemoveField( "C9P_DESTAB" )
		oStruC9Q:RemoveField( "C9Q_TRABAL" )
		oStruC9R:RemoveField( "C9R_CODRUB" )
		oStruC9R:RemoveField( "C9R_DCODRU" )

		oStruC9M:SetProperty( "C9M_RUBRIC"	, MVC_VIEW_ORDEM    , "01" )
		oStruC9M:SetProperty( "C9M_IDTABR"	, MVC_VIEW_ORDEM    , "02" )

		IF !TafColumnPos( "C9Q_MATRIC" )
			oStruC9Q:SetProperty( "C9Q_DTRABA"	, MVC_VIEW_CANCHANGE, .T.  )
		Else
			oStruC9Q:SetProperty( "C9Q_MATRIC"	, MVC_VIEW_ORDEM    , "01" )
			oStruC9Q:RemoveField( "C9Q_DTRABA" )
			oStruC9R:RemoveField( "C9R_MATRIC" )
		EndIf

	EndIf

	If TafColumnPos( "C9L_NOMEVE" )
		oStruC9L:RemoveField( "C9L_NOMEVE" )
		oStruC9Q:RemoveField( "C9Q_NOMEVE" )
	EndIf

	If lLaySimplif
		oStruC9N:RemoveField( "C9N_COMPAC" )
		oStruC9N:RemoveField( "C9N_DTEFAC" )
		oStruC9R:RemoveField( "C9R_VLRUNT" )
		oStruC9M:RemoveField( "C9M_VLRUNT")
	Else
		oStruC9M:RemoveField( "C9M_APURIR")
		oStruC9R:RemoveField( "C9R_APURIR" )
	EndIf

	
	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oStruV9K:RemoveField( "V9K_ESTABE" )	
		oStruV9K:RemoveField( "V9K_DESTAB" )	

		oStruV9K:SetProperty( "V9K_TPINSC"	, MVC_VIEW_ORDEM , "01" )
		oStruV9K:SetProperty( "V9K_NRINSC"	, MVC_VIEW_ORDEM , "02" )
		oStruV9K:SetProperty( "V9K_VLRADV"	, MVC_VIEW_ORDEM , "03" )
	EndIf

	oStruC9Q:SetProperty('C9Q_COMPAC',MVC_VIEW_PVAR ,{||"@R 9999-99"})

	cGrp4 := 'C91_INDMVI|'

	If !lLaySimplif
		cGrp5 := 'C91_QTDINT|'
	EndIf

	cCmpFil := cGrp2 + cGrp3 + cGrp4 + cGrp5

	If !Empty(cGrp6)
		cCmpFil += cGrp6
	EndIf

	If !lLaySimplif
		cGrp7 := 'C91_TPINSC|C91_CNPJEA|C91_MATREA|C91_DTINVI|C91_OBSVIN|'
	Else
		cGrp7 := 'C91_TPINSC|C91_MATREA|C91_DTINVI|C91_OBSVIN|C91_TPINSC|C91_NRINSC|'
	EndIf

	cCmpFil += cGrp7

	oStruC91b := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder do número do ultimo protocolo
	cCmpFil := 'C91_PROTUL|'
	oStruC91c := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("C91_DTRANS")
		cCmpFil := 'C91_DINSIS|C91_DTRANS|C91_HTRANS|C91_DTRECP|C91_HRRECP|'
		oStruC91d := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*-----------------------------------------------------------------------------------
										Grupo de campos Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruC91b:AddGroup( "GRP_TRABALHADOR_02", STR0063, "", 1 ) //"Identificação do Trabalhador"

	If !Empty( cGrp6 )

		oStruC91b:AddGroup( "GRP_TRABALHADOR_06", "Informações complementares para autônomos <infoComplem>", "", 1 ) //"Informações complementares para autônomos <infoComplem>"
		aCmpGrp := StrToKArr(cGrp6,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruC91b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_06")
		Next nI

	EndIf

	oStruC91b:AddGroup( "GRP_TRABALHADOR_03", STR0068, "", 1 ) //'Informações Complementares Do Trabalhador Autônomo'
	oStruC91b:AddGroup( "GRP_TRABALHADOR_04", STR0004, "", 1 ) //"Informações de Multiplos Vínculos"

	aCmpGrp := StrToKArr(cGrp2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC91b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
	Next nI

	aCmpGrp := StrToKArr(cGrp4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC91b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_04")
	Next nI

	oStruC91b:AddGroup( "GRP_TRABALHADOR_07", STR0076, "", 1 ) //"Informações da sucessão de vínculo trabalhista/estatutário"

	aCmpGrp := StrToKArr(cGrp7,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC91b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_07")
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC91c,"C91")
	EndIf

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_C91a', oStruC91a, 'MODEL_C91' )
	oView:EnableTitleView( 'VIEW_C91a', STR0060 ) // Informações de Apuração

	oView:AddField( 'VIEW_C91b', oStruC91b, 'MODEL_C91' )
	oView:EnableTitleView( 'VIEW_C91b', STR0059 ) //Identificação do Trabalhador

	oView:AddField( 'VIEW_C91c', oStruC91c, 'MODEL_C91' )

	If TafColumnPos("C91_PROTUL")
		oView:EnableTitleView( 'VIEW_C91c', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf

	If TafColumnPos("C91_DTRANS")
		oView:AddField( 'VIEW_C91d', oStruC91d, 'MODEL_C91' )
		oView:EnableTitleView( 'VIEW_C91d', TafNmFolder("recibo",2) )
	EndIf

	oView:AddGrid( 'VIEW_T6W', oStruT6W, 'MODEL_T6W' )
	oView:EnableTitleView("VIEW_T6W",STR0064) //"Remuneração do Trab. de Vínculo com Outras Empresas"

	oView:AddGrid( 'VIEW_CRN', oStruCRN, 'MODEL_CRN' )
	oView:EnableTitleView("VIEW_CRN",STR0053) //"Informações de Processos Judiciarios de Remuneração"

	If lLaySimplif
		oView:AddGrid( 'VIEW_V6K', oStruV6K, 'MODEL_V6K' )
		oView:EnableTitleView("VIEW_V6K",STR0079) //Informações relativas ao trabalho intermitente
	EndIf 

	oView:AddGrid( 'VIEW_T14', oStruT14, 'MODEL_T14' )
	oView:EnableTitleView("VIEW_T14",STR0040) //"Informações do Recibo de Pagamento"

	oView:AddGrid( 'VIEW_C9K', oStruC9K, 'MODEL_C9K' )
	oView:EnableTitleView("VIEW_C9K",STR0041) //"Informações do Estabelecimento/Lotação"

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:AddGrid( 'VIEW_V9K', oStruV9K, 'MODEL_V9K' )
		oView:EnableTitleView("VIEW_V9K",STR0081) //"Identificação dos advogados"		
	EndIf

	oView:AddGrid( 'VIEW_C9L', oStruC9L, 'MODEL_C9L' )
	oView:EnableTitleView("VIEW_C9L",STR0042) //"Informações da Remuneração do Trabalhador no Período de Apuração"

	oView:AddGrid( 'VIEW_C9M', oStruC9M, 'MODEL_C9M' )

	If lLaySimplif
		
		oView:EnableTitleView("VIEW_C9M",STR0036) //"Informações da Remuneração do Trabalhador no Período de Apuração"

	Else 

		oView:AddGrid( 'VIEW_T6Y', oStruT6Y, 'MODEL_T6Y' )
		oView:EnableTitleView("VIEW_T6Y",STR0067) //"Informações Operadoras de Planos de Saúde"
	
		oView:AddGrid( 'VIEW_T6Z', oStruT6Z, 'MODEL_T6Z' )
		oView:AddIncrementField( 'VIEW_T6Z', 'T6Z_SEQUEN' )
		oView:EnableTitleView("VIEW_T6Z",STR0043) //"Informações do Dependente"

	EndIf

	oView:AddGrid( 'VIEW_C9N', oStruC9N, 'MODEL_C9N' )
	oView:EnableTitleView("VIEW_C9N",STR0046) //"Informações de Acordo"

	oView:AddGrid( 'VIEW_C9O', oStruC9O, 'MODEL_C9O' )
	oView:EnableTitleView("VIEW_C9O",STR0048) //"Informações do Periodo"

	oView:AddGrid( 'VIEW_C9P', oStruC9P, 'MODEL_C9P' )
	oView:EnableTitleView("VIEW_C9P",STR0041) //"Informações da Remuneração do Trabalhador"

	oView:AddGrid( 'VIEW_C9Q', oStruC9Q, 'MODEL_C9Q' )
	oView:EnableTitleView("VIEW_C9Q",STR0042) //"Informações da Remuneração do Trabalhador no Período de Apuração"

	oView:AddGrid( 'VIEW_C9R', oStruC9R, 'MODEL_C9R' )

	oView:EnableTitleView("VIEW_C9R",STR0036) //"Itens da Remuneração do Trabalhador"

	If !lLaySimplif
		oView:AddGrid( 'VIEW_V1B', oStruV1B, 'MODEL_V1B' )
		oView:AddGrid( 'VIEW_V1C', oStruV1C, 'MODEL_V1C' )
	EndIf 

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/

	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0002 )   //"Informações da Folha"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0061 )   //"Recibo de Pagamentos"

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0052 )   //"Protocolo de Transmissão"
	EndIf

	If lLaySimplif

		oView:CreateHorizontalBox( 'C91a',  010,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'C91b',  030,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T6W' ,  020,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'CRN' ,  020,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'V6K' ,  020,,, 'FOLDER_SUPERIOR', 'ABA01' )

	Else 

		oView:CreateHorizontalBox( 'C91a',  020,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'C91b',  030,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T6W' ,  030,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'CRN' ,  020,,, 'FOLDER_SUPERIOR', 'ABA01' )

	EndIf

	If TafColumnPos("C91_DTRANS")
		oView:CreateHorizontalBox( 'C91c',  20,,, 'FOLDER_SUPERIOR', 'ABA03' )
		oView:CreateHorizontalBox( 'C91d',  80,,, 'FOLDER_SUPERIOR', 'ABA03' )
	Else
		oView:CreateHorizontalBox( 'C91c',  100,,, 'FOLDER_SUPERIOR', 'ABA03' )
	EndIf

	oView:CreateHorizontalBox( 'T14',   020,,, 'FOLDER_SUPERIOR', 'ABA02' )

	oView:CreateHorizontalBox("PAINEL_INFOPERAPUR",80,,,"FOLDER_SUPERIOR","ABA02")
	oView:CreateFolder( 'FOLDER_INFOPERAPUR', 'PAINEL_INFOPERAPUR' )

	If lLaySimplif

		If lSimplBeta .And. TafColumnPos("T14_INDRRA")
			oView:AddSheet( 'FOLDER_INFOPERAPUR', cAbaRRA, STR0080 ) //"Informações complementares de RRA" 			
			oView:CreateHorizontalBox( 'V9K'   ,   080,,, 'FOLDER_INFOPERAPUR', cAbaRRA )
		EndIf

		oView:AddSheet( 'FOLDER_INFOPERAPUR', cAbaApur, STR0065 )   //"Informações relativas a remuneração do trabalhador no período de apuração"
		oView:CreateHorizontalBox( 'C9K',   025,,, 'FOLDER_INFOPERAPUR', cAbaApur )
		oView:CreateHorizontalBox( 'C9L',   025,,, 'FOLDER_INFOPERAPUR', cAbaApur )
		oView:CreateHorizontalBox( 'C9M',   025,,, 'FOLDER_INFOPERAPUR', cAbaApur )

	Else 

		oView:AddSheet( 'FOLDER_INFOPERAPUR', 'ABA01', STR0065 )   //"Informações relativas a remuneração do trabalhador no período de apuração"
		oView:CreateHorizontalBox( 'C9K',   025,,, 'FOLDER_INFOPERAPUR', 'ABA01' )
		oView:CreateHorizontalBox( 'C9L',   025,,, 'FOLDER_INFOPERAPUR', 'ABA01' )
		
		oView:CreateHorizontalBox("PAINEL_REMUN",050,,,"FOLDER_INFOPERAPUR","ABA01")
		oView:CreateFolder( 'FOLDER_REMUN', 'PAINEL_REMUN' )

		oView:AddSheet( 'FOLDER_REMUN', 'ABA01', STR0036 ) //"Itens da Remuneração do Trabalhador"
		oView:CreateHorizontalBox ( 'C9M', 100,,, 'FOLDER_REMUN'  , 'ABA01' )
		oView:AddSheet( 'FOLDER_REMUN', 'ABA02', STR0034 ) //"Informação do Plano de Saúde"
		oView:CreateHorizontalBox ( 'T6Y', 050,,, 'FOLDER_REMUN'  , 'ABA02' )
		oView:CreateHorizontalBox ( 'T6Z', 050,,, 'FOLDER_REMUN'  , 'ABA02' )
		oView:AddSheet( 'FOLDER_REMUN', 'ABA03', STR0070 ) //"Informações das convocações de Trabalho Intermitente"
		oView:CreateHorizontalBox ( 'V1B', 100,,, 'FOLDER_REMUN'  , 'ABA03' )

	EndIf

	/*------------------------
	PERIODO DE APUR. ANT.
	--------------------------*/
	oView:AddSheet( 'FOLDER_INFOPERAPUR', cAbaAnt, STR0066 )   //"Informações relativas a remuneração do trabalhador em períodos anteriores ao período de apuração"

	oView:CreateHorizontalBox ( 'C9N', 20,,, 'FOLDER_INFOPERAPUR'  , cAbaAnt )
	oView:CreateHorizontalBox ( 'C9O', 20,,, 'FOLDER_INFOPERAPUR'  , cAbaAnt )
	oView:CreateHorizontalBox ( 'C9P', 20,,, 'FOLDER_INFOPERAPUR'  , cAbaAnt )
	oView:CreateHorizontalBox ( 'C9Q', 20,,, 'FOLDER_INFOPERAPUR'  , cAbaAnt )

	If !lLaySimplif

		oView:CreateHorizontalBox("PAINEL_REMUNANT",20,,,"FOLDER_INFOPERAPUR", cAbaAnt)
		oView:CreateFolder( 'FOLDER_REMUNANT', 'PAINEL_REMUNANT' )
		oView:AddSheet( 'FOLDER_REMUNANT', 'ABA01', STR0036 ) //"Itens da Remuneração do Trabalhador"
		oView:AddSheet( 'FOLDER_REMUNANT', 'ABA02', STR0070 ) //"Informações das convocações de Trabalho Intermitente"

		oView:CreateHorizontalBox ( 'C9R', 100,,, 'FOLDER_REMUNANT'  , 'ABA01' )
		oView:CreateHorizontalBox ( 'V1C', 100,,, 'FOLDER_REMUNANT'  , 'ABA02' )

	Else

		oView:CreateHorizontalBox ( 'C9R', 20,,, 'FOLDER_INFOPERAPUR'  , cAbaAnt )

	EndIf 

	oView:SetOwnerView( 'VIEW_C91a' , 'C91a')
	oView:SetOwnerView( 'VIEW_C91b' , 'C91b')
	oView:SetOwnerView( 'VIEW_C91c' , 'C91c')

	If TafColumnPos("C91_DTRANS")
		oView:SetOwnerView( 'VIEW_C91d' , 'C91d')
	EndIf

	oView:SetOwnerView( 'VIEW_T6W' , 'T6W')
	oView:SetOwnerView( 'VIEW_CRN' , 'CRN')
	oView:SetOwnerView( 'VIEW_T14' , 'T14')
	oView:SetOwnerView( 'VIEW_C9K' , 'C9K')
	oView:SetOwnerView( 'VIEW_C9L' , 'C9L')
	oView:SetOwnerView( 'VIEW_C9M' , 'C9M')

	If !lLaySimplif
		oView:SetOwnerView( 'VIEW_T6Y' , 'T6Y')
		oView:SetOwnerView( 'VIEW_T6Z' , 'T6Z')
	Else 
		oView:SetOwnerView( 'VIEW_V6K' , 'V6K')
	EndIf

	oView:SetOwnerView( 'VIEW_C9N' , 'C9N')
	oView:SetOwnerView( 'VIEW_C9O' , 'C9O')
	oView:SetOwnerView( 'VIEW_C9P' , 'C9P')
	oView:SetOwnerView( 'VIEW_C9Q' , 'C9Q')
	oView:SetOwnerView( 'VIEW_C9R' , 'C9R')

	If !lLaySimplif
		oView:SetOwnerView( 'VIEW_V1B' , 'V1B')
		oView:SetOwnerView( 'VIEW_V1C' , 'V1C')	
	EndIf

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:SetOwnerView( 'VIEW_V9K' , 'V9K')
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif

		xFunRmFStr(@oStruC91a,"C91")

		oStruT14:RemoveField('T14_NOMEVE')
		oStruT6W:RemoveField('T6W_NOMEVE')	

		If !lLaySimplif	
			oStruT6Y:RemoveField('T6Y_NOMEVE')
			oStruT6Z:RemoveField('T6Z_NOMEVE')
			oStruV1B:RemoveField('V1B_IDCONV')
			oStruV1C:RemoveField('V1C_IDCONV')
		EndIf 

		oStruCRN:RemoveField('CRN_IDSUSP')
		oStruC91a:RemoveField('C91_ID')

	EndIf

	If !lLaySimplif
		oStruC91b:SetProperty( "C91_TPINSC"	, MVC_VIEW_ORDEM, "42" )
	EndIf

	//-----------------------------------------------------------------------
	// Altera consulta padrão do beneficiário para apenas exibir autonomos
	//-----------------------------------------------------------------------
	If FWIsInCallStack( "TAF250AUTI" )
		oStruC91b:SetProperty( "C91_TRABAL"	, MVC_VIEW_LOOKUP, "C9VAUT" )
	EndIf
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Xml
Funcao de geracao do XML para atender o registro S-1200
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-1200

@author Vitor Siqueira
@since 08/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF250Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical, lRemEmp as logical, cSeqXml as character, lInfoRPT as logical)

	Local aMensal    	as array
	Local aAuxPerAnt 	as array
	Local aAnalitico 	as array
	Local aRubrica   	as array
	Local cXml       	as character
	Local cXmlCompl  	as character
	Local cRubrica   	as character
	Local cTabRubric 	as character
	Local cIDTabRubr 	as character
	Local cCodCat    	as character
	Local cSucVinc   	as character
	Local cNISFunc   	as character
	Local cCompConv  	as character
	Local cMatric    	as character
	Local cGrauExp   	as character
	Local cOriEve    	as character
	Local cEvent     	as character
	Local cRemuns    	as character
	Local cCPFApu		as character
	Local cCPFAnt		as character
	Local cIdeDmd		as character
	Local cLayout    	as character
	Local cReg       	as character
	Local cFilBkp    	as character
	Local cCPF       	as character
	Local cNome      	as character
	Local cTipoEstab 	as character
	Local cEstab     	as character
	Local cLotacao   	as character
	Local cCodRubr   	as character
	Local cChvC9N    	as character
	Local cMVIDETABR 	as character
	Local cFilRub		as character
	Local cIndRRA		as character
	Local cXmlProcJud	as character
	Local cXmlIdeAdv	as character
	Local lFindAuto  	as logical
	Local lFindMatr  	as logical
	Local lMV        	as logical
	Local lGeraC9Q   	as logical
	Local lGeraC9R   	as logical
	Local lFindT6Y   	as logical
	Local lFindT6Z   	as logical
	Local lT3A       	as logical
	Local lC9NOld    	as logical
	Local lCodRub    	as logical
	Local lInfoCompl	as logical
	Local lInfoCompC	as logical
	Local lHasS2300		as logical
	Local lRubERPPad 	as logical
	Local lC9K       	as logical
	Local lV9K			as logical
	Local lC9L       	as logical
	Local lC9M       	as logical
	Local lT6Y       	as logical
	Local lC9N       	as logical
	Local lC9O       	as logical
	Local lC9Q       	as logical
	Local lC9P       	as logical
	Local lC9R       	as logical
	Local lV1B       	as logical
	Local lV1C       	as logical
	Local lXmlVLd    	as logical
	Local lMatC9L       as logical
	Local lMatC9Q       as logical
	Local lAct23        as logical
	Local nPosRubric 	as numeric
	Local nRecnoSM0  	as numeric
	Local nPosValores	as numeric
	Local nTipPer    	as numeric
	Local oInfoRPT   	as object

	Default cAlias		:= ""
	Default cSeqXml		:= ""
	Default lInfoRPT  	:= .F.
	Default lJob		:= .F.
	Default lRemEmp		:= .F.
	Default nRecno		:= 0
	Default nOpc		:= 0

	aMensal     := {}
	aAuxPerAnt  := {}
	cXml        := ""
	cXmlProcJud	:= ""
	cXmlIdeAdv	:= ""
	cXmlCompl   := ""
	cRubrica    := ""
	cTabRubric  := ""
	cIDTabRubr  := ""
	cCodCat     := ""
	cSucVinc    := ""
	cNISFunc    := ""
	cCompConv   := ""
	cMatric     := ""
	cGrauExp    := ""
	cOriEve     := ""
	cEvent      := ""
	cRemuns     := ""
	cCPFApu		:= ""
	cCPFAnt		:= ""
	cIdeDmd		:= ""
	cLayout     := "1200"
	cReg        := "Remun"
	cFilBkp     := cFilAnt
	cMVIDETABR  := SuperGetMV("MV_IDETABR", .F., "0")
	cFilRub		:= ""
	cIndRRA		:= ""
	lFindAuto   := .F.
	lFindMatr   := .F.
	lMV         := .F.
	lGeraC9Q    := .F.
	lGeraC9R    := .F.
	lFindT6Y    := .F.
	lFindT6Z    := .F.
	lT3A        := .F.
	lC9NOld     := .F.
	lCodRub     := .F.
	lInfoCompl  := .T.
	lInfoCompC	:= .T.
	lHasS2300	:= .T.
	lRubERPPad  := .T.
	lC9K        := .T.
	lV9K		:= .T.
	lC9L        := .T.
	lC9M        := .T.
	lT6Y        := .T.
	lC9N        := .T.
	lC9O        := .T.
	lC9Q        := .T.
	lC9P        := .T.
	lC9R        := .T.
	lV1B        := .T.
	lV1C        := .T.
	lMatC9L     := .F.
	lMatC9Q     := .F.
	lXmlVLd     := IIf(FindFunction( 'TafXmlVLD' ), TafXmlVLD( 'TAF250XML' ), .T.)
	lAct23      := .F.
	nPosRubric  := 0
	nRecnoSM0   := SM0->(Recno())

	//Relatório de Conferência de Valores
	aAnalitico 	:= {}
	aRubrica   	:= {}
	cCPF       	:= ""
	cNome      	:= ""
	cTipoEstab 	:= ""
	cEstab     	:= ""
	cLotacao   	:= ""
	cCodRubr   	:= ""
	cChvC9N    	:= ""
	nPosValores	:= 0
	nTipPer    	:= 1
	oInfoRPT   	:= Nil

	If lXmlVLd

		//Verifica se existe as classes necessárias para utilização do relatório persistido
		If lInfoRPT

			If __lGrvRPT == Nil
				TAF250Rpt() //Inicializa a variável static __lGrvRPT
			EndIf

			lInfoRPT := __lGrvRPT

		EndIf
		
		If lInfoRPT
			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf
		EndIf

		If IsInCallStack("TafNewBrowse") .And. ( C91->C91_FILIAL <> cFilAnt )
			cFilAnt := C91->C91_FILIAL
		EndIf

		If C91->C91_MV == "1"
			lMV 	:= .T.
		EndIf

		If IsInCallStack("TAFA250") .AND. !IsInCallStack("XmlErpxTaf") .AND. (IsInCalLStack("TAFXmlLote") .OR. IsInCallStack("TAF250Xml")) 

			If lMV

				lRubERPPad := .T.
				
			ElseIf slRubERPPad == Nil

				lRubERPPad := cMVIDETABR == "1" .Or. (cMVIDETABR == "0" .And. ApMsgYesNo("Deseja gerar o conteúdo da tag 'ideTabRubr' com o código padrão deste ERP ou conforme ERP de Origem?" + CRLF + " - Sim para código padrão(T3M_ID)." + CRLF + " - Não para conforme ERP de Origem (T3M_CODERP).", "Conteúdo 'ideTabRubr' padrão?"))
				
				If IsInCalLStack("TAFXmlLote")
					slRubERPPad	:= lRubERPPad
				EndIf

			Else

				lRubERPPad	:= slRubERPPad

			EndIf

		EndIf

		If C91->C91_EVENTO $ "I|A|E" 

			AADD(aMensal,C91->C91_INDAPU)

			If Len(Alltrim(C91->C91_PERAPU)) <= 4
				AADD(aMensal,C91->C91_PERAPU)
			Else
				AADD(aMensal,substr(C91->C91_PERAPU, 1, 4) + '-' + substr(C91->C91_PERAPU, 5, 2) )
			EndIf
			
			//-----------------------------
			//Início da TAG ideTrabalhador
			//-----------------------------
			C9V->( DBSetOrder( 2 ) )
			CUP->( DBSetOrder( 4 ) )

			lFindAuto := .F.
			lFindMatr := .F.

			If lLaySimplif

				cOriEve := C91->C91_ORIEVE

				If cOriEve != "S2190"

					If C9V->( MsSeek( xFilial( "C9V" ) + C91->C91_TRABAL + "1" ) )

						If C9V->C9V_NOMEVE == "TAUTO"
							lFindAuto := .T.
						Else
							lFindMatr := .T.
						EndIf

					Else 

						C9V->( DbSetOrder (3) )

						If C9V->( MsSeek( xFilial("C9V") + C91->C91_CPF + "1") )

							If C9V->C9V_NOMEVE == "TAUTO"
								lFindAuto := .T.
							EndIf

						EndIf

					EndIf

				Else

					T3A->( DbSetOrder (3) )
					If T3A->( MsSeek( xFilial("T3A") + C91->C91_TRABAL + "1") )
						lT3A := .T.
					EndIf

				EndIf

			Else

				If C9V->( MsSeek( xFilial( "C9V" ) + C91->C91_TRABAL + "1" ) )

					If C9V->C9V_NOMEVE == "TAUTO"
						lFindAuto := .T.
					Else
						lFindMatr := .T.
					EndIf

				Else 

					C9V->( DbSetOrder (3) )
					If C9V->( MsSeek( xFilial("C9V") + C91->C91_CPF + "1") )

						If C9V->C9V_NOMEVE == "TAUTO"
							lFindAuto := .T.
						EndIf

					EndIf

				EndIf

			EndIf

			//Se encontrar o trabalhador com vinculo ou um trabalhador autonomo ou dados informados direto no s1200
			If lFindAuto .or. lFindMatr .Or. lMV .OR. lT3A

				cXml +=	"<ideTrabalhador>"

				If !lLaySimplif .And. (lFindMatr .Or. lFindAuto)
					
					cCPF	:=	Iif(!Empty(C91->C91_CPF), C91->C91_CPF, C9V->C9V_CPF)
					cNome	:=	C9V->C9V_NOME
					cEvent  :=	C9V->C9V_NOMEVE

					cXml +=		xTafTag("cpfTrab",cCPF)

					TAFConOut("TAF250Xml |" + FWTimeStamp(3) + " - Chave de busca do funcionario: |" + C9V->C9V_FILIAL + C9V->C9V_ID + C9V->C9V_NIS + "| Recno: " + Str(C9V->(Recno())))

					cNISFunc	:= TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, C91->C91_PERAPU,C9V->C9V_NOMEVE)

					TAFConOut("TAF250Xml |" + FWTimeStamp(3) + " - NIS retornado do funcionario: |" + C9V->C9V_FILIAL + C9V->C9V_ID + C9V->C9V_NIS + "| Recno: " + Str(C9V->(Recno())) + " | NIS: " + cNISFunc )

					cXml +=		xTafTag("nisTrab",cNISFunc,,.T.)

				Else

					If !lLaySimplif

						cCPF	:=	Iif(!Empty(C91->C91_CPF), C91->C91_CPF, C9V->C9V_CPF)
						cNome	:=	C9V->C9V_NOME
						cEvent  :=	C9V->C9V_NOMEVE

					Else	

						cEvent  :=	C91->C91_ORIEVE//C9V->C9V_NOMEVE

						If !cEvent $ "S2190"					
							cNome	:=	C9V->C9V_NOME
							cCPF	:=	Iif(!Empty(C91->C91_CPF), C91->C91_CPF, C9V->C9V_CPF)
						Else
							cNome	:=	"TRABALHADOR PRELIMINAR"
							cCPF	:=	T3A->T3A_CPF
						EndIf

					EndIf

					cXml +=		xTafTag("cpfTrab", cCPF)
					
					If !lLaySimplif
						cXml +=		xTafTag("nisTrab", C91->C91_NIS,,.T.)
					EndIf

				EndIf

				If !Empty(C91->C91_INDMVI)

					cXml +=	"<infoMV>"
					cXml +=	xTafTag("indMV",C91->C91_INDMVI)

					T6W->(DbSetOrder(1))

					If T6W->(MsSeek(xFilial("T6W") + C91->(C91_ID + C91_VERSAO)))

						If __cPicVlRe == Nil
							__cPicVlRe := PesqPict("T6W", "T6W_VLREMU")
						EndIf

						C87->(DbSetOrder(1))

						While !T6W->(EOF()) .And. AllTrim(C91->(C91_ID + C91_VERSAO)) == AllTrim(T6W->(T6W_ID + T6W_VERSAO))

							C87->(MsSeek(xFilial("C87") + T6W->T6W_CODCAT))
							
							cCodCat := C87->C87_CODIGO

							cXml +=	"<remunOutrEmpr>"
							cXml +=	xTafTag("tpInsc"		, T6W->T6W_TPINSC)
							cXml +=	xTafTag("nrInsc"		, SubStr(T6W->T6W_NRINSC, 1, 14))
							cXml +=	xTafTag("codCateg"		, cCodCat)
							cXml +=	xTafTag("vlrRemunOE"	, T6W->T6W_VLREMU, __cPicVlRe,,, .T.)
							cXml +=	"</remunOutrEmpr>"

							T6W->(DbSkip())

						EndDo

					EndIf

					cXml +=	"</infoMV>"

				EndIf

				// Posiciona na C9N
				C9N->( DbSetOrder( 1 ) )
				If C9N->( MsSeek( xFilial("C9N") + C91->(C91_ID + C91_VERSAO)))

					While C9N->(!EoF()) .And. AllTrim(C91->(C91_ID + C91_VERSAO)) == AllTrim(C9N->(C9N_ID + C9N_VERSAO))

						cRemuns := C9N->C9N_REMUNS
						C9N->(dbSkip())

					EndDo

				EndIf

				//Somente gera para o trabalhador autônomo, a tabela é a mesma C9V, porém o campo _NOMEVE é gravado como TAUTO
				//E SOMENTE PARA S2200 COM remunSuc = 's'
				If lFindAuto .OR.(cRemuns == '1' .AND. cEvent == "S2200")
							
					If !lLaySimplif 

						xTafTagGroup( "sucessaoVinc"	, {	{ "tpInscAnt", C91->C91_TPINSC,, .T. };
								,	{ "cnpjEmpregAnt", C91->C91_CNPJEA,, .T. };
								, 	{ "matricAnt", C91->C91_MATREA,, .F. };
								, 	{ "dtAdm", C91->C91_DTINVI,, .T. };
								, 	{ "observacao", C91->C91_OBSVIN,, .F. } };
								, @cSucVinc )

					Else

						xTafTagGroup( "sucessaoVinc"	, {	{ "tpInsc", C91->C91_TPINSC,, .F. };
								,	{ "nrInsc", C91->C91_NRINSC,, .F. };
								, 	{ "matricAnt", C91->C91_MATREA,, .T. };
								, 	{ "dtAdm", C91->C91_DTINVI,, .F. };
								, 	{ "observacao", C91->C91_OBSVIN,, .T. } };
								, @cSucVinc )				
								
					EndIf

					xTafTagGroup( "infoComplem"	, {	{ "nmTrab", C9V->C9V_NOME,, .F. };
						, 	{ "dtNascto", C9V->C9V_DTNASC,, .F. }};				
						, @cXmlCompl;
						, { { "sucessaoVinc", cSucVinc, 0 } } )	
										

					//Inserção de flag para substituição pelo cXmlCompl ao final da montagem do Xml.
					//É necessário verificar se o S-1200 é somente de Trabalhador Autônomo ( TAUTO ), e neste caso, o grupo infoComplem deve ser enviado.
					//Caso o 1200 possua um S-2200 ou S-2300, não é necessário enviar o grupo infoComplem.
					cXml += "FlagInfoComplem"

				EndIf

				CRN->(DbSetOrder(1))

				If CRN->(MsSeek(xFilial("CRN") + C91->(C91_ID + C91_VERSAO)))

					C1G->(DbSetOrder(8))
					T5L->(DbSetOrder(1))

					While !CRN->(EOF()) .And. AllTrim(C91->(C91_ID + C91_VERSAO)) == AllTrim(CRN->(CRN_ID + CRN_VERSAO))

						C1G->(MsSeek(xFilial("C1G") + CRN->CRN_IDPROC + "1"))
						T5L->(MsSeek(xFilial("T5L") + CRN->CRN_IDSUSP))

						cXml += "<procJudTrab>"
						cXml +=	xTafTag("tpTrib", CRN->CRN_TPTRIB)
						cXml +=	xTafTag("nrProcJud", C1G->C1G_NUMPRO)
						cXml += xTafTag("codSusp", T5L->T5L_CODSUS,, .T.)
						cXml += "</procJudTrab>"

						CRN->(DbSkip())

					EndDo

				EndIf

				If !lLaySimplif

					xTafTagGroup( "infoInterm"	, {	{ "qtdDiasInterm", C91->C91_QTDINT,, .T. }}, @cXml )

				Else

					If V6K->( MsSeek( xFilial("V6K")+C91->(C91_ID+C91_VERSAO) ) )
			
						While !V6K->(Eof()) .And. AllTrim(V6K->(V6K_ID+V6K_VERSAO)) == AllTrim(C91->(C91_ID+C91_VERSAO))
							
							xTafTagGroup( "infoInterm"	, {	{ "dia", V6K->V6K_DIA,, .T. }}, @cXml )

							V6K->(DbSkip())

						EndDo

					EndIf

				EndIf

				cXml +=	"</ideTrabalhador>"

				/*----------------------------------------------------------
						Inicio da TAG DmDev
				----------------------------------------------------------*/
				// Posiciona na T14
				T14->(DbSetOrder(1))

				If T14->(MsSeek(C91->(C91_FILIAL + C91_ID + C91_VERSAO)))

					If __cPicIdeM == Nil
						__cPicIdeM := PesqPict("T14", "T14_IDEDMD")
					EndIf

					C87->(DbSetOrder(1))
					C9K->(DbSetOrder(1))
					
					While !T14->(EOF()) .And. AllTrim(C91->(C91_ID+C91_VERSAO)) == AllTrim(T14->(T14_ID+T14_VERSAO))
						lV9K 		:= .T.
						cXmlProcJud := ""
						cXmlIdeAdv	:= ""
						cIdeDmd 	:= T14->T14_IDEDMD

						cXml	+= "<dmDev>"
						cXml	+= xTafTag("ideDmDev", cIdeDmd, __cPicIdeM)
						
						C87->(MsSeek(xFilial("C87") + T14->T14_CODCAT))
						
						cCodCat := C87->C87_CODIGO

						cXml += xTafTag("codCateg", cCodCat)

						If lSimplBeta .And. TafColumnPos("T14_INDRRA") 							
							V9K->(DbSetOrder(1))

							cIndRRA 	:= IIF( T14->T14_INDRRA=="1", "S", "" )
							
							cXml += xTafTag("indRRA", cIndRRA,, .T.)

							If cIndRRA == "S"

								If __cPicVAdv == Nil
									__cPicVAdv := PesqPict("T14", "T14_VLRADV")
									__cPicVCus := PesqPict("T14", "T14_VLRCUS")
									__cPicQRRA := PesqPict("T14", "T14_QTMRRA")									
								EndIf
								
								xTafTagGroup("despProcJud";	
									,{{"vlrDespCustas"		, T14->T14_VLRCUS, __cPicVCus, .F.};
									, {"vlrDespAdvogados"	, T14->T14_VLRADV, __cPicVAdv, .F.}};						
									, @cXmlProcJud)
								
								If V9K->(MsSeek(T14->(T14_FILIAL + T14_ID + T14_VERSAO + T14_IDEDMD)))

									While lV9K
										
										xTafTagGroup("ideAdv";	
											,{{"tpInsc"	, V9K->V9K_TPINSC,			  , .F.};
											, {"nrInsc"	, V9K->V9K_NRINSC,			  , .F.};
											, {"vlrAdv"	, V9K->V9K_VLRADV, __cPicVAdv , .T.}};						
											, @cXmlIdeAdv)
										
										V9K->(DbSkip())
										lV9K := !V9K->(Eof()) .And. AllTrim(V9K->(V9K_ID+V9K_VERSAO+V9K_RECIBO)) == AllTrim(T14->(T14_ID+T14_VERSAO+T14_IDEDMD))
									
									EndDo

								EndIf
								
								xTafTagGroup("infoRRA";	
									,{{"tpProcRRA"		,T14->T14_TPPRRA ,			 , .F.};
									, {"nrProcRRA"		,T14->T14_NRPRRA ,			 , .T.};
									, {"descRRA"		,T14->T14_DESCRA ,			 , .F.};
									, {"qtdMesesRRA"	,T14->T14_QTMRRA , __cPicQRRA, .F.}};									
									, @cXml;
									, { { "despProcJud" , cXmlProcJud	 , 0 } ;
									, { "ideAdv"		, cXmlIdeAdv	 , 0 } },, .T.)

							EndIf

						EndIf

						If C9K->(MsSeek(T14->(T14_FILIAL + T14_ID + T14_VERSAO + T14_IDEDMD)))

							If __cPicQtdR == Nil
								__cPicQtdR := PesqPict("C9M", "C9M_QTDRUB")
								__cPicFatR := PesqPict("C9M", "C9M_FATORR")
								__cPicVlUn := PesqPict("C9M", "C9M_VLRUNT")
								__cPicVlRu := PesqPict("C9M", "C9M_VLRRUB")  
								__cPicVlPg := PesqPict("T6Y", "T6Y_VLPGTI")
								__cPicVPgD := PesqPict("T6Z", "T6Z_VPGDEP")
							EndIf

							cXml += "<infoPerApur>"
							
							C9L->(DbSetOrder(3))
							C92->(DbSetOrder(1))
							C99->(DbSetOrder(1))
							T3A->(DbSetOrder(1))
							C9V->(DbSetOrder(1))
							C88->(DbSetOrder(1))

							While lC9K

								cXml +=	"<ideEstabLot>"

								If !Empty(C9K->C9K_TPINSC) .And. !Empty(C9K->C9K_NRINSC) .And. !Empty(C9K->C9K_CODLOT)

									cTipoEstab	:= C9K->C9K_TPINSC
									cEstab		:= C9K->C9K_NRINSC
									cLotacao	:= C9K->C9K_CODLOT

								Else

									C92->(MsSeek(xFilial("C92") + C9K->C9K_ESTABE))
									C99->(MsSeek(xFilial("C99") + C9K->C9K_LOTACA))

									cTipoEstab	:= C92->C92_TPINSC
									cEstab		:= C92->C92_NRINSC
									cLotacao 	:= C99->C99_CODIGO

								EndIf

								cXml +=	xTafTag("tpInsc"	, cTipoEstab)
								cXml +=	xTafTag("nrInsc"    , SubStr(cEstab, 1, 14))
								cXml +=	xTafTag("codLotacao", cLotacao)
								cXml +=	xTafTag("qtdDiasAv"	, C9K->C9K_QTDDIA,, .T.)

								//proteção para mundaça do SIX da C9L
								If C9L->(IndexKey(3)) $ "C9L_FILIAL+C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_ESTABE+C9L_LOTACA+C9L_TPINSC+C9L_NRINSC+C9L_CODLOT"
									C9L->(MsSeek(xFilial("C9L", C9K->C9K_FILIAL) + C9K->(C9K_ID + C9K_VERSAO + C9K_RECIBO + C9K_ESTABE + C9K_LOTACA + C9K_TPINSC + C9K_NRINSC + C9K_CODLOT))) 
								Else
									C9L->(MsSeek(xFilial("C9L", C9K->C9K_FILIAL) + C9K->(C9K_ID + C9K_VERSAO + C9K_RECIBO + C9K_ESTABE + C9K_LOTACA + C9K_CODLOT + C9K_TPINSC + C9K_NRINSC)))
								EndIf

								While lC9L

									cXml +=	"<remunPerApur>"

									If Empty(C9L->C9L_DTRABA)
										If lLaySimplif .And. C9L->C9L_NOMEVE == 'S2190'
											T3A->(MsSeek(xFilial("T3A") + C9L->C9L_TRABAL))
											
											cMatric := T3A->T3A_MATRIC
											cCPFApu	:= T3A->T3A_CPF
										Else
											C9V->(MsSeek(xFilial("C9V") + C9L->C9L_TRABAL))
											
											cMatric := C9V->C9V_MATRIC
											cCPFApu	:= C9V->C9V_CPF
										EndIf
									Else
										cMatric := C9L->C9L_DTRABA
									EndIf

									lMatC9L := Empty(cMatric)
									
									If !Empty(C91->C91_CPF)
										cCPFApu := C91->C91_CPF
									EndIf

									If lInfoCompl
										lInfoCompl := InfoCompl(cCPFApu, {"S-2200", "S-2300"} )
									EndIf

									If lInfoCompC
										InfoCompl(cCPFApu, {"S-2300"}, @lAct23)
									EndIf 

									cXml +=	xTafTag("matricula", cMatric,, .T.)

									cXml +=	xTafTag("indSimples", C9L->C9L_INDCON,, .T.)

									If !Empty(C9L->C9L_ESTABE) .And. !Empty(C9L->C9L_LOTACA)
										C9M->(DbSetOrder(1))
										C9M->(MsSeek(xFilial("C9M") + C9L->(C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_ESTABE + C9L_LOTACA + C9L_TRABAL)))
									Else
										C9M->(DbSetOrder(3))
										C9M->(MsSeek(xFilial("C9M") + C9L->(C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_CODLOT + C9L_TPINSC + C9L_NRINSC + C9L_DTRABA)))
									EndIf

									While lC9M

										If !Empty(__aRubrica)
											nPosRubric := aScan(__aRubrica, {|x| x[5] == C9M->C9M_FILIAL + C9M->C9M_CODRUB})
										EndIf

										If nPosRubric > 0

											cIDTabRubr	:= __aRubrica[nPosRubric][1]
											cCodRubr	:= __aRubrica[nPosRubric][2]
											cTabRubric 	:= __aRubrica[nPosRubric][3]
											cRubrica	:= __aRubrica[nPosRubric][4]	

										Else

											C8R->(DbSetOrder(5))
											C8R->(MsSeek(xFilial("C8R") + C9M->C9M_CODRUB + "1"))
									
											cIDTabRubr := C8R->C8R_IDTBRU

											If !Empty(C9M->C9M_CODRUB) .And. !Empty(cIDTabRubr)

												cFilRub	 := C9M->C9M_FILIAL
												cCodRubr := C9M->C9M_CODRUB
												cRubrica := C8R->C8R_CODRUB

												T3M->(DbSetOrder(1))
												T3M->(MsSeek(xFilial("T3M") + cIDTabRubr))
												
												cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)

												AAdd(__aRubrica, {cIDTabRubr, cCodRubr, cTabRubric, cRubrica, cFilRub + cCodRubr})

											Else

												cCodRubr	:= C9M->C9M_RUBRIC
												cIDTabRubr	:= C9M->C9M_IDTABR
												cRubrica	:= cCodRubr
												cTabRubric	:= cIDTabRubr

											EndIf

										EndIf		

										cXml +=	"<itensRemun>"
										cXml +=	xTafTag("codRubr"	, cRubrica)			
										cXml +=	xTafTag("ideTabRubr", cTabRubric,, .T.)
										cXml +=	xTafTag("qtdRubr"	, C9M->C9M_QTDRUB, __cPicQtdR, .T., .T.)
										cXml +=	xTafTag("fatorRubr"	, C9M->C9M_FATORR, __cPicFatR, .T., .T.)
										
										If !lLaySimplif
											cXml +=	xTafTag("vrUnit", C9M->C9M_VLRUNT, __cPicVlUn, .T., .T.)
										EndIf

										cXml +=	xTafTag("vrRubr", C9M->C9M_VLRRUB, __cPicVlRu,, .T.)

										If lLaySimplif
											cXml +=	xTafTag("indApurIR", C9M->C9M_APURIR,, .T., .T.)
										EndIf

										cXml +=	"</itensRemun>"

										If lInfoRPT
											aRubrica := oReport:GetRubrica(cCodRubr, cIDTabRubr, C91->C91_PERAPU, lCodRub)

											aAdd(aAnalitico, Array(16))
											nPosValores := Len(aAnalitico)

											aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
											aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
											aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
											aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
											aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
											aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
											aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
											aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
											aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
											aAnalitico[nPosValores][ANALITICO_VALOR]				:= C9M->C9M_VLRRUB
											aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)
										EndIf

										C9M->(DbSkip())

										If !lMV
											lC9M := !C9M->(Eof()) .And. AllTrim(C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_ESTABE+C9L_LOTACA+C9L_TRABAL)) ==;
																		AllTrim(C9M->(C9M_ID+C9M_VERSAO+C9M_RECIBO+C9M_ESTABE+C9M_LOTACA+C9M_TRABAL))
										Else
											lC9M := !C9M->(Eof()) .And. AllTrim(C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_DTRABA+C9L_CODLOT+C9L_TPINSC+C9L_NRINSC)) ==;
																		AllTrim(C9M->(C9M_ID+C9M_VERSAO+C9M_RECIBO+C9M_DTRABA+C9M_CODLOT+C9M_TPINSC+C9M_NRINSC))
										EndIf

									EndDo

									lC9M := .T.

									lFindT6Y := .F.

									If !lMV
										T6Y->( DbSetOrder(1) )
										lFindT6Y := T6Y->( MsSeek( xFilial("T6Y")+C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_ESTABE+C9L_LOTACA+C9L_TRABAL)))
									Else
										T6Y->( dbSetOrder(5) )
										lFindT6Y := T6Y->( MsSeek( xFilial("T6Y")+C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_TPINSC+C9L_NRINSC+C9L_DTRABA+C9L_CODLOT)))
									EndIf

									If !lLaySimplif

										If lFindT6Y

											cXml +=	"<infoSaudeColet>"

											While lT6Y

												cXml +=	"<detOper>"
												cXml +=	xTafTag("cnpjOper"	, T6Y->T6Y_CNPJOP)
												cXml +=	xTafTag("regANS"	, T6Y->T6Y_REGANS)
												cXml +=	xTafTag("vrPgTit"	, T6Y->T6Y_VLPGTI, __cPicVlPg,, .T., .T.)

												lFindT6Z := .F.

												If !lMV
													T6Z->( DbSetOrder( 1 ) )
													lFindT6Z := T6Z->( MsSeek ( xFilial("T6Z")+T6Y->(T6Y_ID+T6Y_VERSAO+T6Y_RECIBO+T6Y_ESTABE+T6Y_LOTACA+T6Y_TRABAL+T6Y_CNPJOP+T6Y_REGANS)))
												Else
													T6Z->( DbSetOrder(4) )
													lFindT6Z := T6Z->( MsSeek( xFilial("T6Z")+T6Y->(T6Y_ID+T6Y_VERSAO+T6Y_RECIBO+T6Y_TPINSC+T6Y_NRINSC+T6Y_DTRABA+T6Y_CNPJOP+T6Y_REGANS)))
												EndIf

												If lFindT6Z

													CMI->(DbSetOrder(1))

													While !T6Z->(EOF()) .And. AllTrim(T6Y->(T6Y_FILIAL + T6Y_ID + T6Y_VERSAO + T6Y_RECIBO + T6Y_ESTABE + T6Y_LOTACA + T6Y_TRABAL + T6Y_CNPJOP + T6Y_REGANS + T6Y_TPINSC + T6Y_NRINSC + T6Y_DTRABA + T6Y_CODLOT)) ==;
																			AllTrim(T6Z->(T6Z_FILIAL + T6Z_ID + T6Z_VERSAO + T6Z_RECIBO + T6Z_ESTABE + T6Z_LOTACA + T6Z_TRABAL + T6Z_CNPJOP + T6Z_REGANS + T6Z_TPINSC + T6Z_NRINSC + T6Z_DTRABA + T6Z_CODLOT))
														CMI->(MsSeek(xFilial("CMI") + T6Z->T6Z_TPDEP))

														cXml +=	"<detPlano>"
														cXml +=	xTafTag("tpDep"		, CMI->CMI_CODIGO)
														cXml +=	xTafTag("cpfDep"	, T6Z->T6Z_CPFDEP,, .T.)
														cXml +=	xTafTag("nmDep"		, T6Z->T6Z_NOMDEP)
														cXml +=	xTafTag("dtNascto" 	, T6Z->T6Z_DTNDEP)
														cXml +=	xTafTag("vlrPgDep"	, T6Z->T6Z_VPGDEP, __cPicVPgD,, .T., .T.)
														cXml +=	"</detPlano>"
														
														T6Z->(DbSkip())

													EndDo

												EndIf

												cXml +=	"</detOper>"
											
												T6Y->(DbSkip())

												If !lMV
													lT6Y := !T6Y->(Eof()) .And. AllTrim(C9L->(C9L_FILIAL+C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_ESTABE+C9L_LOTACA+C9L_TRABAL)) ==;
																				AllTrim(T6Y->(T6Y_FILIAL+T6Y_ID+T6Y_VERSAO+T6Y_RECIBO+T6Y_ESTABE+T6Y_LOTACA+T6Y_TRABAL))
												Else
													lT6Y := !T6Y->(Eof()) .And. AllTrim( C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_TPINSC+C9L_NRINSC+C9L_DTRABA+C9L_CODLOT) ) ==;
																				AllTrim( T6Y->(T6Y_ID+T6Y_VERSAO+T6Y_RECIBO+T6Y_TPINSC+T6Y_NRINSC+T6Y_DTRABA+T6Y_CODLOT) )
												EndIf

											EndDo

											lT6Y := .T.
											cXml +=	"</infoSaudeColet>"
											
										EndIf

									EndIf

									If !Empty(C9L->C9L_GRAEXP)

										C88->(MsSeek(xFilial("C88") + C9L->C9L_GRAEXP))
											
										cGrauExp := AllTrim(C88->C88_CODIGO)

										If Len(cGrauExp) == 2
											cGrauExp :=	StrTran	(cGrauExp, "0", "")
										EndIf

										cXml +=	"<infoAgNocivo>"
										cXml +=	xTafTag("grauExp", cGrauExp)
										cXml +=	"</infoAgNocivo>"

									EndIf

									If !lLaySimplif

										lV1B := .T.

										V1B->(DbSetOrder(1))

										If V1B->( MsSeek(xFilial("V1B") + C9L->(C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_ESTABE + C9L_LOTACA + C9L_TRABAL)))
											
											T87->(DbSetOrder(4))

											While lV1B

												T87->(MsSeek(xFilial("T87") + V1B->V1B_IDCONV + "1"))

												cXml +=	"<infoTrabInterm>"
												cXml +=	xTafTag("codConv", T87->T87_CONVOC)										
												cXml +=	"</infoTrabInterm>"
												
												V1B->( dbSkip() )

												lV1B := V1B->( !Eof() ) .And. C9L->( C9L_FILIAL + C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_ESTABE + C9L_LOTACA + C9L_TRABAL ) ==;
																			xFilial("V1B") + V1B->( V1B_ID + V1B_VERSAO + V1B_RECIBO + V1B_ESTABE + V1B_LOTACA + V1B_TRABAL )
											
											EndDo

										EndIf

									EndIf

									cXml +=	"</remunPerApur>"

									C9L->(DbSkip())
									lC9L := !C9L->(Eof()) .And. AllTrim(C9K->(C9K_ID+C9K_VERSAO+C9K_RECIBO+C9K_ESTABE+C9K_LOTACA+C9K_TPINSC+C9K_NRINSC+C9K_CODLOT)) ==;
																AllTrim(C9L->(C9L_ID+C9L_VERSAO+C9L_RECIBO+C9L_ESTABE+C9L_LOTACA+C9L_TPINSC+C9L_NRINSC+C9L_CODLOT))

								EndDo

								lC9L := .T.
								cXml +=	"</ideEstabLot>"
								C9K->(DbSkip())
								lC9K := !C9K->(Eof()) .And. AllTrim(C9K->(C9K_ID+C9K_VERSAO+C9K_RECIBO)) == AllTrim(T14->(T14_ID+T14_VERSAO+T14_IDEDMD))

							EndDo

							lC9K := .T.
							cXml +=		"</infoPerApur>"

						EndIf

						lC9NOld :=  taf250Leg(T14->T14_FILIAL, T14->T14_ID, T14->T14_VERSAO, T14->T14_IDEDMD)

						/*----------------------------------------------------------
								Inicio da TAG infoPerAnt
						----------------------------------------------------------*/
						// Posiciona na C9N
						C9N->(DbSetOrder(1))

						If C9N->(MsSeek(xFilial("C9N") + T14->(T14_ID + T14_VERSAO + T14_IDEDMD)))

							If __cPicQtdR == Nil
								__cPicQtdR := PesqPict("C9R", "C9R_QTDRUB")
								__cPicFatR := PesqPict("C9R", "C9R_FATORR")
								__cPicVlUn := PesqPict("C9R", "C9R_VLRUNT")
								__cPicVlRu := PesqPict("C9R", "C9R_VLRRUB")   
							EndIf

							C92->(DbSetOrder(1))
							C99->(DbSetOrder(1))
							C9V->(DbSetOrder(1))
							T3A->(DbSetOrder(1))

							cXml +=	"<infoPerAnt>"
							
							While lC9N

								cXml +=	"<ideADC>"

								If C9N->C9N_TPACOR $ "ABCDE"
									cXml +=		xTafTag("dtAcConv",C9N->C9N_DTACOR)
								Else
									cXml +=		xTafTag("dtAcConv",C9N->C9N_DTACOR,,.T.)
								EndIf

								cXml +=		xTafTag("tpAcConv",C9N->C9N_TPACOR)

								If !lLaySimplif
									cCompConv := Iif( Empty( C9N->C9N_COMPAC ), "", SubStr( C9N->C9N_COMPAC, 1, 4 ) + "-" + SubStr( C9N->C9N_COMPAC, 5, 2 ) )
									cXml +=		xTafTag( "compAcConv", cCompConv,, .T. )
									cXml +=		xTafTag( "dtEfAcConv", C9N->C9N_DTEFAC,, .T. )
								EndIf

								cXml +=		xTafTag("dsc",NoAcento(AnsiToOem(C9N->C9N_DSC)) )
								cXml +=		xTafTag("remunSuc",xFunTrcSN(C9N->C9N_REMUNS,1) )

								C9O->( DbSetOrder( 1 ) ) 
                                If lC9NOld
                                    cChvC9N := C9N->(C9N_ID+C9N_VERSAO+C9N_RECIBO+DTOS(C9N_DTACOR)+C9N_TPACOR+C9N_COMPAC)
                                Else 
							        cChvC9N := C9N->(C9N_ID+C9N_VERSAO+C9N_RECIBO+DTOS(C9N_DTACOR)+C9N_TPACOR+C9N_RELACO)
						        EndIf 
								C9O->( MsSeek( xFilial("C9O")+cChvC9N))
								
								While lC9O

									cXml +=	"<idePeriodo>"

									If Len(Alltrim(C9O->C9O_PERREF)) <= 4
										cXml +=		xTafTag("perRef",C9O->C9O_PERREF)
									Else
										cXml +=		xTafTag("perRef",substr(C9O->C9O_PERREF, 1, 4) + '-' +  substr(C9O->C9O_PERREF, 5, 2) )
									EndIf

									C9P->( DbSetOrder( 1 ) ) //C9P_FILIAL, C9P_ID, C9P_VERSAO, C9P_RECIBO, C9P_DTACOR, C9P_TPACOR, C9P_COMPAC, C9P_PERREF, C9P_ESTABE, C9P_LOTACA, R_E_C_N_O_, D_E_L_E_T_
									C9P->( MsSeek( xFilial("C9P")+C9O->(C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_COMPAC+C9O_PERREF)))
									
									While lC9P

										cXml +=	"<ideEstabLot>"

										If !lMV .Or. Empty(C9P->C9P_CODLOT)

											C92->(MsSeek(xFilial("C92") + C9P->C9P_ESTABE))
											C99->(MsSeek(xFilial("C99") + C9P->C9P_LOTACA))

											cTipoEstab	:= C92->C92_TPINSC
											cEstab		:= C92->C92_NRINSC
											cLotacao 	:=	C99->C99_CODIGO

										Else

											cTipoEstab	:= C9P->C9P_TPINSC
											cEstab		:= C9P->C9P_NRINSC
											cLotacao	:= C9P->C9P_CODLOT

										EndIf

										cXml +=	xTafTag("tpInsc"    , cTipoEstab)
										cXml +=	xTafTag("nrInsc"	, SubStr(cEstab, 1, 14))
										cXml +=	xTafTag("codLotacao", cLotacao)

										If lMv .And. TafColumnPos( "C9Q_MATRIC" )
											C9Q->( DbSetOrder( 3 ) )                     
											C9Q->( MsSeek( xFilial("C9Q")+	C9P->C9P_ID+C9P->C9P_VERSAO+C9P->C9P_RECIBO+DTOS(C9P->C9P_DTACOR)+C9P->C9P_TPACOR+C9P->C9P_PERREF+C9P->C9P_ESTABE+C9P->C9P_LOTACA+cLotacao))
										Else
											C9Q->( DbSetOrder( 1 ) )
											C9Q->( MsSeek( xFilial("C9Q")+C9P->C9P_ID+C9P->C9P_VERSAO+C9P->C9P_RECIBO+DTOS(C9P->C9P_DTACOR)+C9P->C9P_TPACOR+Iif(TAFColumnPos("C9Q_COMPAC"), C9P->C9P_COMPAC, "")+C9P->C9P_PERREF+C9P->C9P_ESTABE+C9P->C9P_LOTACA))
										EndIf

										While lC9Q

											lGeraC9Q := .F.

											// Saída contorno para limitação do tamanho de índice do cTree - Orientação FrameWork
											If lMV

												If C9Q->( C9Q_CODLOT+C9Q_TPINSC+C9Q_NRINSC ) == C9P->( C9P_CODLOT+C9P_TPINSC+C9P_NRINSC )
													lGeraC9Q := .T.
												EndIf

											Else

												lGeraC9Q := .T.

											EndIf

											If lGeraC9Q	

												nTipPer	:= 2	// 1=Período Atual; 2=Período Anterior
												cXml 	+= "<remunPerAnt>"
									
												If !lMV .Or. IIf(TafColumnPos("C9Q_MATRIC"), Empty(C9Q->C9Q_MATRIC), Empty(C9Q->C9Q_DTRABA)) 
													If lLaySimplif .And. C9Q->C9Q_NOMEVE == 'S2190'
														T3A->(MsSeek(xFilial("T3A") + C9Q->C9Q_TRABAL))

														cMatric := T3A->T3A_MATRIC
														cCPFAnt	:= T3A->T3A_CPF
													Else
														C9V->(MsSeek(xFilial("C9V") + C9Q->C9Q_TRABAL))

														cMatric := C9V->C9V_MATRIC
														cCPFAnt	:= C9V->C9V_CPF
													EndIf

													cXml += xTafTag("matricula", cMatric,, .T.)
												Else
													If  TafColumnPos( "C9Q_MATRIC")
														cMatric := C9Q->C9Q_MATRIC
													Else
														cMatric := C9Q->C9Q_DTRABA
													EndIf
													
													cXml += xTafTag( "matricula", cMatric )
												EndIf
												
												lMatC9Q := Empty( cMatric )

												If !Empty(C91->C91_CPF)
													cCPFAnt := C91->C91_CPF
												EndIf

												If lInfoCompl
													lInfoCompl := InfoCompl(cCPFAnt, {"S-2200", "S-2300"} )
												EndIf

												If lInfoCompC
													InfoCompl(cCPFAnt, {"S-2300"}, @lAct23)
												EndIf

												cXml +=	xTafTag("indSimples", C9Q->C9Q_INDCON,, .T.)

												C9R->( DbSetOrder( 1 ) ) //C9R_FILIAL, C9R_ID, C9R_VERSAO, C9R_RECIBO, C9R_DTACOR, C9R_TPACOR, C9R_COMPAC, C9R_PERREF, C9R_ESTABE, C9R_LOTACA, C9R_TRABAL, C9R_CODRUB
												C9R->( MsSeek( xFilial("C9R")+C9Q->(C9Q_ID+C9Q_VERSAO+C9Q_RECIBO+DTOS(C9Q_DTACOR)+C9Q_TPACOR+Iif(TAFColumnPos("C9Q_COMPAC"), C9Q_COMPAC, C9P->C9P_COMPAC)+C9Q_PERREF+C9Q_ESTABE+C9Q_LOTACA+C9Q_TRABAL)))

												While lC9R

													lGeraC9R := .F.

													// Saída contorno para limitação do tamanho de índice do cTree - Orientação FrameWork
													If lMV

														If C9R->( C9R_ESTABE + C9R_CODLOT + C9R_TPINSC + C9R_NRINSC + C9R_MATRIC ) == C9Q->( C9Q_ESTABE + C9Q_CODLOT + C9Q_TPINSC + C9Q_NRINSC + C9Q_DTRABA )
															lGeraC9R := .T.
														EndIf

													Else

														lGeraC9R := .T.

													EndIf

													If lGeraC9R

														If lMV .And. !Empty(C9R->C9R_RUBRIC)

															cCodRubr	:= C9R->C9R_RUBRIC
															cIDTabRubr	:= C9R->C9R_IDTABR
															cRubrica	:= cCodRubr
															cTabRubric	:= cIDTabRubr
															lCodRub     := .T.

														Else

															cCodRubr := C9R->C9R_CODRUB
															lCodRub  := .F.
															cFilRub	 := C9R->C9R_FILIAL

															If !Empty(__aRubrica)
																nPosRubric := aScan(__aRubrica, {|x| x[5] == cFilRub + cCodRubr})
															EndIf
															
															If nPosRubric > 0

																cIDTabRubr	:= __aRubrica[nPosRubric][1]
																cCodRubr	:= __aRubrica[nPosRubric][2]
																cTabRubric 	:= __aRubrica[nPosRubric][3]
																cRubrica	:= __aRubrica[nPosRubric][4]

															Else

																C8R->(DbSetOrder(5))
																C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))

																cIDTabRubr 	:= C8R->C8R_IDTBRU
																cRubrica	:= C8R->C8R_CODRUB

																T3M->(DbSetOrder(1))
																T3M->(MsSeek(xFilial("T3M") + cIDTabRubr))
																
																cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)

																AAdd(__aRubrica, {cIDTabRubr, cCodRubr, cTabRubric, cRubrica, cFilRub + cCodRubr})

															EndIf

														EndIf

														cXml +=	"<itensRemun>"
														cXml +=	xTafTag("codRubr"	, cRubrica)
														cXml +=	xTafTag("ideTabRubr", cTabRubric,, .T.)
														cXml +=	xTafTag("qtdRubr"	, C9R->C9R_QTDRUB, __cPicQtdR, .T., .T.)
														cXml +=	xTafTag("fatorRubr"	, C9R->C9R_FATORR, __cPicFatR, .T., .T.)
														 
														If !lLaySimplif
															cXml +=	xTafTag("vrUnit", C9R->C9R_VLRUNT, __cPicVlUn, .T., .T.)
														EndIF
														
														cXml +=	xTafTag("vrRubr", C9R->C9R_VLRRUB, __cPicVlRu,, .T.)
														
														If lLaySimplif
															cXml +=	xTafTag("indApurIR", C9R->C9R_APURIR,, .T., .T.)
														EndIf
														
														cXml +=	"</itensRemun>"

														If lInfoRPT
															aRubrica := oReport:GetRubrica(cCodRubr, cIDTabRubr, C91->C91_PERAPU, lCodRub, nTipPer)

															aAdd(aAnalitico, Array(16))
															nPosValores := Len(aAnalitico)

															aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
															aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
															aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
															aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
															aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
															aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
															aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
															aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
															aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
															aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
															aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
															aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
															aAnalitico[nPosValores][ANALITICO_VALOR]				:= C9R->C9R_VLRRUB
															aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)
														EndIf

													EndIf

													C9R->(DbSkip())

													If lMV
														lC9R := !C9R->(Eof()) .And. AllTrim(C9Q->(C9Q_ID+C9Q_VERSAO+C9Q_RECIBO+DTOS(C9Q_DTACOR)+C9Q_TPACOR+C9Q_PERREF)) ==;
														AllTrim(C9R->(C9R_ID+C9R_VERSAO+C9R_RECIBO+DTOS(C9R_DTACOR)+C9R_TPACOR+C9R_PERREF))
													Else 
														lC9R := !C9R->(Eof()) .And. AllTrim(C9Q->(C9Q_ID+C9Q_VERSAO+C9Q_RECIBO+DTOS(C9Q_DTACOR)+C9Q_TPACOR+C9Q_PERREF+C9Q_ESTABE+C9Q_LOTACA+C9Q_TRABAL)) == AllTrim(C9R->(C9R_ID+C9R_VERSAO+C9R_RECIBO+DTOS(C9R_DTACOR)+C9R_TPACOR+C9R_PERREF+C9R_ESTABE+C9R_LOTACA+C9R_TRABAL))	
													EndIf

												EndDo

												lC9R := .T.

												If !Empty(C9Q->C9Q_GRAEXP)

													C88->(DbSetOrder(1))
													C88->(MsSeek(xFilial("C88") + C9Q->C9Q_GRAEXP))
													
													cGrauExp := AllTrim(C88->C88_CODIGO)

													If Len(cGrauExp) == 2
														cGrauExp :=	StrTran(cGrauExp, "0", "")
													EndIf

													cXml +=	"<infoAgNocivo>"
													cXml +=	xTafTag("grauExp", cGrauExp)
													cXml +=	"</infoAgNocivo>"

												EndIf

												If !lLaySimplif

													V1C->(DbSetOrder(1))

													If V1C->(MsSeek(xFilial("V1C") + C9Q->(C9Q_ID + C9Q_VERSAO + C9Q_RECIBO + DToS(C9Q_DTACOR) + C9Q_TPACOR + C9Q_PERREF + C9Q_ESTABE + C9Q_LOTACA + C9Q_TRABAL)))
														
														cXml +=	"<infoTrabInterm>"
														
														T87->(DbSetOrder(4))

														While lV1C

															T87->(MsSeek(xFilial("T87") + V1C->V1C_IDCONV + "1"))
															
															cXml +=	xTafTag("codConv", T87->T87_CONVOC)

															V1C->(DbSkip())

															lV1C := !V1C->(EOF()) .And. AllTrim(C9Q->(C9Q_ID + C9Q_VERSAO + C9Q_RECIBO + DToS(C9Q_DTACOR) + C9Q_TPACOR + C9Q_PERREF + C9Q_ESTABE + C9Q_LOTACA + C9Q_TRABAL)) == AllTrim(V1C->(V1C_ID + V1C_VERSAO + V1C_RECIBO + DToS(V1C_DTACOR) + V1C_TPACOR + V1C_PERREF + V1C_ESTABE + V1C_LOTACA + V1C_TRABAL))
														
														EndDo

														lV1C := .T.
														cXml +=	"</infoTrabInterm>"

													EndIf

												EndIf

												cXml +=	"</remunPerAnt>"

											EndIf

											C9Q->(DbSkip())

											If !lMV
												lC9Q := !C9Q->(Eof()) .And. AllTrim(C9P->(C9P_ID+C9P_VERSAO+C9P_RECIBO+DTOS(C9P_DTACOR)+C9P_TPACOR+C9P_PERREF+C9P_ESTABE+C9P_LOTACA)) == AllTrim(C9Q->(C9Q_ID+C9Q_VERSAO+C9Q_RECIBO+DTOS(C9Q_DTACOR)+C9Q_TPACOR+C9Q_PERREF+C9Q_ESTABE+C9Q_LOTACA))
											Else
												lC9Q := !C9Q->(Eof()) .And. AllTrim(C9P->(C9P_ID+C9P_VERSAO+C9P_RECIBO+DTOS(C9P_DTACOR)+C9P_TPACOR+C9P_PERREF+C9P_ESTABE+C9P_LOTACA+C9P_CODLOT+C9P_TPINSC+C9P_NRINSC)) ==;
												AllTrim(C9Q->(C9Q_ID+C9Q_VERSAO+C9Q_RECIBO+DTOS(C9Q_DTACOR)+C9Q_TPACOR+C9Q_PERREF+C9Q_ESTABE+C9Q_LOTACA+C9Q_CODLOT+C9Q_TPINSC+C9Q_NRINSC))
											EndIf

										EndDo

										lC9Q := .T.
										cXml +=	"</ideEstabLot>"
										C9P->(DbSkip())
										lC9P := !C9P->(Eof()) .And. AllTrim(C9O->(C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_PERREF)) == AllTrim(C9P->(C9P_ID+C9P_VERSAO+C9P_RECIBO+DTOS(C9P_DTACOR)+C9P_TPACOR+C9P_PERREF))

									EndDo

									lC9P := .T.
									cXml +=	"</idePeriodo>"
									C9O->(DbSkip())
									lC9O := !C9O->(Eof()) .And.  AllTrim(cChvC9N) == AllTrim(C9O->(C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_COMPAC))

								EndDo

								lC9O := .T.
								cXml += "</ideADC>"
								C9N->(Dbskip())
								lC9N := !C9N->(Eof()) .And. AllTrim(T14->(T14_ID+T14_VERSAO+T14_IDEDMD)) == AllTrim(C9N->(C9N_ID+C9N_VERSAO+C9N_RECIBO))

							EndDo

							lC9N := .T.
							cXml += "</infoPerAnt>"

						EndIf

						If T14->(FieldPos("T14_CODCBO")) <> 0 .And. T14->(FieldPos("T14_NATATV")) <> 0 .And. T14->(FieldPos("T14_QTDTRB")) <> 0
							C8Z->(DbSetOrder(1))
							C8Z->(MsSeek(xFilial("C8Z") + T14->T14_CODCBO))

							
							If !C91->C91_ORIEVE $ ("S2190|S2200|S2300") 
						
								If !lLaySimplif
									xTafTagGroup("infoComplCont", {	{ "codCBO"		, C8Z->C8Z_CODIGO	,, .F. };
																, 	{ "natAtividade", T14->T14_NATATV	,, .T. };
																, 	{ "qtdDiasTrab"	, T14->T14_QTDTRB	,, .T. }};
																, @cXml,, .T.)						
								Else
									xTafTagGroup("infoComplCont", {	{ "codCBO"		, C8Z->C8Z_CODIGO	,, .F. };
																, 	{ "natAtividade", T14->T14_NATATV	,, .T. };
																, 	{ "qtdDiasTrab"	, T14->T14_QTDTRB	,, .T. }};
																, @cXml,, GeraComplCont(lMatC9L, lMatC9Q, lAct23, cCodCat))
								EndIf
							EndIf
						EndIf

						cXml +=	"</dmDev>"

						T14->(DbSkip())
					EndDo

				EndIf

			EndIf

		EndIf

		// Verifica o "TAUTO" informado diretamente na folha
		If !lInfoCompl .And. lMV .And. !Empty(C91->C91_NOME)
			lInfoCompl := .T.
		EndIf

		//E SOMENTE PARA S2200 COM remunSuc = 's' E TAUTO
		If lInfoCompl .OR. (cRemuns == '1' .AND. cEvent == "S2200")
			cXml := StrTran( cXml, "FlagInfoComplem", cXmlCompl )
		Else
			cXml := StrTran( cXml, "FlagInfoComplem", "" )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRecnoSM0 > 0
			SM0->(dbGoto(nRecnoSM0))
		EndIf
		cXml := xTafCabXml(cXml,"C91",cLayout,cReg,aMensal)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

		If lInfoRPT
			If C91->C91_EVENTO $ "I|A"
				InfoRPTObj(AllTrim(C91->C91_INDAPU), AllTrim(C91->C91_PERAPU), cCPF, cNome, aAnalitico,, @oInfoRPT)

				oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT)
			EndIf
		EndIf

		TAFEncArr(aAuxPerAnt)

		cFilAnt := cFilBkp

	EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Grv
@type			function
@description	Função de gravação para atender o registro S-1200.
@author			Vitor Siqueira
@since			08/01/2016
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF250Grv(cLayout as character, nOpc as numeric, cFilEv as character, oXML as object, cOwner as character, cFilTran as character, cPredeces as character, nTafRecno as numeric, cComplem as character, cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character, lMigrador as logical, lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXml as character)

	Local aInfComp     	as array
	Local aAuxInfComp  	as array
	Local aIncons      	as array
	Local aRules       	as array
	Local aChave       	as array
	Local aEvento      	as array
	Local aAnalitico   	as array
	Local aRubrica     	as array
	Local cLogOpeAnt   	as character
	Local cMatricC9L   	as character
	Local cMatricC9Q   	as character
	Local cT6WPath     	as character
	Local cT14Path     	as character
	Local cC9KPath     	as character
	Local cC9LPath     	as character
	Local cC9MPath     	as character
	Local cT6YPath     	as character
	Local cT6ZPath     	as character
	Local cC9NPath     	as character
	Local cC9OPath     	as character
	Local cC9PPath     	as character
	Local cC9QPath     	as character
	Local cC9RPath     	as character
	Local cCRNPath     	as character
	Local cV1BPath     	as character
	Local cOwExi       	as character
	Local cNewOw       	as character
	Local cV1CPath     	as character
	Local cPeriodo     	as character
	Local cChave       	as character
	Local cInconMsg    	as character
	Local cIdProc      	as character
	Local cIdConv      	as character
	Local cIdTrab      	as character
	Local cCodConv     	as character
	Local cCodCat		as character
	Local cCPF			as character
	Local cIdTabR      	as character
	Local cCodRubr     	as character
	Local cIdC9V       	as character
	Local cV6KPath     	as character
	Local cIDCat       	as character
	Local cIdConvT     	as character
	Local cTpLot       	as character
	Local cCpfT3A      	as character
	Local cEvtNew      	as character
	Local cPathPerAnt  	as character
	Local cPathPerApu  	as character
	Local cCmpsNoUpd   	as character
	Local cCodEvent    	as character
	Local cNome        	as character
	Local cNomEvC9V    	as character
	Local cDtAcEfe     	as character
	Local cCompAcConv  	as character
	Local cC9L_TRABAL  	as character
	Local cC9Q_TRABAL  	as character 
	Local cMatricula	as character
	Local cV9KPath		as character
	Local cIndRRA		as character
	Local nT6W         	as numeric 
	Local nT14         	as numeric 
	Local nC9K         	as numeric 
	Local nC9L         	as numeric 
	Local nC9M         	as numeric 
	Local nT6Y         	as numeric 
	Local nT6Z         	as numeric 
	Local nC9N         	as numeric 
	Local nC9O         	as numeric 
	Local nC9P         	as numeric 
	Local nC9Q         	as numeric 
	Local nC9R         	as numeric 
	Local nCRN         	as numeric 
	Local nV1B         	as numeric 
	Local nV1C         	as numeric 
	Local nJ           	as numeric 
	Local nlI          	as numeric 
	Local nSeqErrGrv   	as numeric 
	Local nChvIndex    	as numeric 
	Local nV6K         	as numeric 
	Local nT6Z_SEQUEN  	as numeric 
	Local nPosValores  	as numeric
	Local nTipPer      	as numeric
	Local nV9K      	as numeric
	Local lRet         	as logical 
	Local lInfoCompl   	as logical 
	Local lMultVinc    	as logical 
	Local lExistTrab   	as logical 
	Local lFindTrab    	as logical 
	Local lAtvVerif    	as logical
	Local lNovCenar    	as logical
	Local lInfoRPT     	as logical
	Local oModel       	as object 
	Local oModelT14    	as object 
	Local oModelC9K    	as object 
	Local oModelC9L    	as object 
	Local oModelC9M    	as object 
	Local oModelT6Y    	as object 
	Local oModelT6Z    	as object 
	Local oModelC9N    	as object 
	Local oModelC9O    	as object 
	Local oModelC9P    	as object 
	Local oModelC9Q    	as object 
	Local oModelC9R    	as object 
	Local oModelV1B    	as object 
	Local oModelV1C    	as object
	Local oModelV9K    	as object 
	Local oMdlNvCen    	as object
	Local oInfoRPT     	as object
	Local xChkDupl 		as variant

	Private lVldModel  	as logical
	Private oDados     	as object

	Default cOwner    	:= ""
	Default cKey      	:= ""
	Default cGrpTran  	:= ""
	Default cFilTran  	:= ""
	Default cPredeces 	:= ""
	Default cLayout   	:= ""
	Default cFilEv    	:= ""
	Default cComplem  	:= ""
	Default cGrpTran  	:= ""
	Default cEmpOriGrp	:= ""
	Default cFilOriGrp	:= ""
	Default cXmlID    	:= ""
	Default cMatrC9V	:= ""
	Default cXml		:= ""
	Default nTafRecno 	:= 0
	Default nOpc      	:= 1
	Default oXML      	:= Nil		
	Default oTransf		:= Nil 
	Default lLaySmpTot	:= .F.
	Default lExclCMJ	:= .F.
	
	aInfComp   	:= {}
	aAuxInfComp	:= {}
	aIncons    	:= {}
	aRules     	:= {}
	aChave     	:= {}
	aEvento    	:= {}
	cLogOpeAnt 	:= ""
	cMatricC9L 	:= ""
	cMatricC9Q 	:= ""
	cT6WPath   	:= ""
	cT14Path   	:= ""
	cC9KPath   	:= ""
	cC9LPath   	:= ""
	cC9MPath   	:= ""
	cT6YPath   	:= ""
	cT6ZPath   	:= ""
	cC9NPath   	:= ""
	cC9OPath   	:= ""
	cC9PPath   	:= ""
	cC9QPath   	:= ""
	cC9RPath   	:= ""
	cCRNPath   	:= ""
	cV1BPath   	:= ""
	cOwExi     	:= ""
	cNewOw     	:= ""
	cV1CPath   	:= ""
	cPeriodo   	:= ""
	cChave     	:= ""
	cInconMsg  	:= ""
	cIdProc    	:= ""
	cIdConv    	:= ""
	cIdTrab    	:= ""
	cCodConv   	:= ""
	cCodCat		:= ""
	cCPF		:= ""
	cIdTabR     := ""
	cCodRubr    := ""
	cIdC9V      := "" // Variavel utilizada apenas para verificar se o trabalhador possui um registro que seja diferente de TAUTO, com o intuito de evitar a geração da tag infoComplem.
	cV6KPath    := ""
	cIDCat      := ""
	cIdConvT    := ""
	cTpLot      := ""
	cCpfT3A     := ""
	cEvtNew     := ""
	cC9L_TRABAL := ""
	cC9Q_TRABAL := ""
	cMatricula	:= ""
	cPathPerAnt := "/eSocial/evtRemun/dmDev[1]/infoPerAnt/ideADC[1]/idePeriodo[1]/ideEstabLot[1]/remunPerAnt[1]"
	cPathPerApu := "/eSocial/evtRemun/dmDev[1]/infoPerApur/ideEstabLot[1]/remunPerApur"
	cCmpsNoUpd  := "|C91_FILIAL|C91_ID|C91_VERSAO|C91_VERANT|C91_PROTPN|C91_EVENTO|C91_STATUS|C91_ATIVO|"
	cCodEvent   := Posicione("C8E", 2, xFilial("C8E") + "S-" + cLayout, "C8E->C8E_ID")
	cV9KPath	:= ""
	cIndRRA		:= ""
	cXmlInteg  	:= cXml
	nT6W        := 0
	nT14        := 0
	nC9K        := 0
	nC9L        := 0
	nC9M        := 0
	nT6Y        := 0
	nT6Z        := 0
	nC9N        := 0
	nC9O        := 0
	nC9P        := 0
	nC9Q        := 0
	nC9R        := 0
	nCRN        := 0
	nV1B        := 0
	nV1C        := 0
	nJ          := 0
	nlI         := 0
	nSeqErrGrv  := 0
	nChvIndex   := 0
	nV6K        := 0
	nV9K		:= 0
	nT6Z_SEQUEN	:= TamSX3("T6Z_SEQUEN")[1]
	lRet        := .F.
	lInfoCompl  := .F.
	lMultVinc   := .F.
	lExistTrab  := .F.
	lFindTrab   := .F.
	lAtvVerif	:= SuperGetMV("MV_TAFFLMV", .F., .F.)
	oModel   	:= Nil
	oModelT14	:= Nil
	oModelC9K	:= Nil
	oModelC9L	:= Nil
	oModelC9M	:= Nil
	oModelT6Y	:= Nil
	oModelT6Z	:= Nil
	oModelC9N	:= Nil
	oModelC9O	:= Nil
	oModelC9P	:= Nil
	oModelC9Q	:= Nil
	oModelC9R	:= Nil
	oModelV1B	:= Nil
	oModelV1C	:= Nil
	oModelV9K	:= Nil
	xChkDupl 	:= Nil

	//Relatório de Conferência de Valores
	aAnalitico  := {}
	aRubrica    := {}
	cNome       := ""
	cNomEvC9V   := ""
	cDtAcEfe    := ""
	cCompAcConv := ""
	lNovCenar   := .F.
	lInfoRPT    := .F.
	nPosValores := 0
	nTipPer     := 1
	oMdlNvCen   := Nil
	oInfoRPT    := Nil

	lVldModel  	:= .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	oDados     	:= Nil

	If __lGrvRPT == Nil
		TAF250Rpt() //Inicializa a variável static __lGrvRPT
	EndIf

	lInfoRPT := __lGrvRPT

	If lInfoRPT

		If oReport == Nil
			oReport := TAFSocialReport():New()
		EndIf

	EndIf

	If __lValidTabRub == Nil .Or. (cEmpAnt + cFilAnt != __cFilCache)
		__lValidTabRub := GetNewPar("MV_TAFTRUB",.T.)
		__cFilCache := cEmpAnt + cFilAnt
	EndIf
	
	oDados := oXML

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPeriodo  := FTafGetVal( "/eSocial/evtRemun/ideEvento/perApur", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "C91_INDAPU", FTafGetVal( "/eSocial/evtRemun/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} )
	cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "C91_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	Else
		Aadd( aChave, {"C", "C91_PERAPU", cPeriodo  , .T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	EndIf

	If oDados:XPathHasNode("/eSocial/evtRemun/ideTrabalhador/infoComplem")

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab" ) )
			cNome := FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab", "C", .F.,, .F. )
			aadd( aInfComp, { 'C9V_NOME', cNome } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/dtNascto" ) )
			aadd( aInfComp, { 'C9V_DTNASC', FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/dtNascto","D", .F., , .F.) } )
		EndIf

		If !lLaySimplif

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt" ) )
				aAdd( aInfComp, { "CUP_INSANT", FTAFGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt", "C", .F.,, .F. ) } )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt" ) )
				aAdd( aInfComp, { "CUP_CNPJEA", FTAFGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt", "C", .F.,, .F. ) } )
			EndIf

		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt" ) )
			aAdd( aInfComp, { "CUP_MATANT", FTAFGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt", "C", .F.,, .F. ) } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm" ) )
			aAdd( aInfComp, { "CUP_DTINVI", FTAFGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm", "D", .F.,, .F. ) } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao" ) )
			aAdd( aInfComp, { "CUP_OBSVIN", FTAFGetVal( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao", "M", .F.,, .F. ) } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) )
			aadd( aInfComp, { 'C9V_CPF', FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab","C", .F., , .F.) } )
		EndIf

		If !lLaySimplif

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/nisTrab" ) )
				aadd( aInfComp, { 'C9V_NIS', FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/nisTrab","C", .F., , .F.) } )
			EndIf

		EndIf

		aAuxInfComp := aClone( aInfComp )

	EndIf

	If lLaySimplif
		cCpfT3A := FTafGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F.,, .F.)

		If (oDados:XPathHasNode(cPathPerApu + "/matricula")) .And. !Empty(FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.)) .And. AllTrim( Upper( cComplem ) ) != "MV"
			aEvento := TAFIdFunc(cCpfT3A, FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.),@cInconMsg, @nSeqErrGrv)
			cIdC9V   := aEvento[1]
		ElseIf (oDados:XPathHasNode(cPathPerAnt + "/matricula")) .And. !Empty(FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.)) .And. AllTrim( Upper( cComplem ) ) != "MV"
			aEvento := TAFIdFunc(cCpfT3A, FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.),@cInconMsg, @nSeqErrGrv)
			cIdC9V   := aEvento[1]
		Else
			cIDCat 		:= FGetIdInt("codCateg", "", fTafGetVal("/eSocial/evtRemun/dmDev/codCateg", "C", .F., @aIncons, .F.),, .F.,, @cInconMsg, @nSeqErrGrv)
			cIdC9V   	:= TAFGetIdFunc(fTafGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F.), cPeriodo, Nil, "cpfTrab", "/eSocial/evtRemun/ideTrabalhador/cpfTrab", aInfComp,, cIDCat,, "")
			aInfComp 	:= aClone(aAuxInfComp)
			
			C9V->(DbSetOrder(2))
			C9V->(MsSeek(xFilial("C9V") + cIdC9V + "1"))

			cEvtNew   := IIf(!Empty(AllTrim(C9V->C9V_NOMEVE)), AllTrim(C9V->C9V_NOMEVE), "S2300")
			cNomEvC9V := cEvtNew
		EndIf 

		If !Empty(aEvento)
			cEvtNew   := aEvento[2]
			cNomEvC9V := aEvento[2]
		EndIf
	Else

		If (oDados:XPathHasNode(cPathPerApu + "/matricula")) .And. !Empty(FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.)) .And. AllTrim( Upper( cComplem ) ) != "MV"
			cIdC9V   := FGetIdInt( "matricula", "", FTafGetVal( cPathPerApu + "/matricula", "C", .F., @aIncons, .F. ), , .F.,,@cInconMsg, @nSeqErrGrv)
		ElseIf (oDados:XPathHasNode(cPathPerAnt + "/matricula")) .And. !Empty(FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.)) .And. AllTrim( Upper( cComplem ) ) != "MV"
			cIdC9V   := FGetIdInt( "matricula", "", FTafGetVal( cPathPerAnt + "/matricula", "C", .F., @aIncons, .F. ), , .F.,,@cInconMsg, @nSeqErrGrv)
		Else
			cIDCat := FGetIdInt( "codCateg", "", fTafGetVal( "/eSocial/evtRemun/dmDev/codCateg", "C", .F., @aIncons, .F. ), , .F.,,@cInconMsg, @nSeqErrGrv)
			cIdC9V   := TAFGetIdFunc( fTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ), cPeriodo, Nil, "cpfTrab", "/eSocial/evtRemun/ideTrabalhador/cpfTrab", aInfComp, fTafGetVal( "/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/matricula", "C", .F., @aIncons, .F. ), cIDCat )
			aInfComp := aClone( aAuxInfComp )
		EndIf

		cNomEvC9V := POSICIONE("C9V",2, xFilial("C9V")+cIdC9V+"1","C9V_NOMEVE")

	EndIf

	If lLaySimplif

		Aadd( aChave, {"C", "C91_TPGUIA", FTafGetVal( "/eSocial/evtRemun/ideEvento/indGuia", "C", .F., @aIncons, .F. )  , .T.} )
		cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])

		Aadd( aChave, {"C", "C91_CPF", fTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ), .T.} )
		cChave += Padr( aChave[ 4, 3 ], Tamsx3(aChave[ 4, 2 ])[1])
		nChvIndex := 10

	Else

		Aadd( aChave, {"C", "C91_CPF", fTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ), .T.} )
		cChave += Padr( aChave[ 3, 3 ], Tamsx3(aChave[ 3, 2 ])[1])
		nChvIndex := 7

	EndIf

	Aadd( aChave, {"C", "C91_NOMEVE", "S1200" , .T.} )

	// --> Sempre grava aberto !!
	If AllTrim( Upper( cComplem ) ) == "MV"

		// Não deverá gerar a tag infoComplem caso o funcionário tenha um S2200 ou um S2300 transmitido ao RET
		lInfoCompl	:= oXML:XPathHasNode("/eSocial/evtRemun/ideTrabalhador/infoComplem") .And. (Empty(cIdC9V) .Or.;
						InfoCompl(AllTrim(fTafGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F.)), {"S-2200", "S-2300"} ))
		lMultVinc	:= .T.

	Else

		If lAtvVerif
			lMultVinc 	:= Taf250MV( oXML, @lInfoCompl, cChave, nChvIndex, cFilEv, @aIncons )
		EndIf

		If !lMultVinc
			cIdTrab := cIdC9V
		EndIf

	EndIf

	If !Empty(cIDTrab)

		lExistTrab 	:= .T.

		If cEvtNew == "S2190"
			cNome := "TRABALHADOR PRELIMINAR"
		ElseIf !Empty( cIDTrab )
			cNome := GetADVFVal( "C9V", "C9V_NOME", xFilial( "C9V" ) + cIDTrab, 1, "", .T. )
		EndIf

	ElseIf  (lMultVinc .And. !Empty(cIdC9V))

		cNome := GetADVFVal( "C9V", "C9V_NOME", xFilial( "C9V" ) + cIdC9V, 1, "", .T. )
		
	EndIf

	//Verifica se o evento ja existe na base
	("C91")->( DbSetOrder( nChvIndex ) ) // C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NOMEVE+C91_ATIVO
	If ("C91")->( MsSeek(FTafGetFil(cFilEv,@aIncons,"C91") + cChave + 'S1200' +'1' ) )

		If !C91->C91_STATUS $ ( "2|4|6|" )
			nOpc := 4
		ElseIf lMultVinc .AND. C91->C91_STATUS == "4" .AND. FTafGetVal("/eSocial/evtRemun/ideEvento/indRetif", "C", .F.,, .F. ) == "1"
			nOpc := 4
			lNovCenar := .T.
			oMdlNvCen := FWLoadModel( 'TAFA250' )
			oMdlNvCen:Activate()
		EndIf

	ElseIf nOpc == 4

		aDel(aChave, Len(aChave))
		aDel(aChave, Len(aChave))

		aSize(aChave, 2)

		Aadd( aChave, {"C", "C91_TRABAL", cIdTrab, .T.} )
		cChave += Padr( aChave[ 3, 3 ], Tamsx3(aChave[ 3, 2 ])[1])

		nChvIndex := 2

		Aadd( aChave, {"C", "C91_NOMEVE", "S1200" , .T.} )

		("C91")->( DbSetOrder( nChvIndex ) ) // C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NIS+C91_NOMEVE+C91_ATIVO
		If ("C91")->( MsSeek(FTafGetFil(cFilEv,@aIncons,"C91") + cChave + 'S1200' +'1' ) )

			If !C91->C91_STATUS $ ( "2|4|6|" )
				nOpc := 4
			EndIf

		EndIf

	EndIf

	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( 'C91', nChvIndex, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA250', cCmpsNoUpd )

			If TafColumnPos( "C91_LOGOPE" )
				cLogOpeAnt := C91->C91_LOGOPE
			EndIf

			oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1200" )

			If lLaySimplif
				oModel:LoadValue( "MODEL_C91", "C91_ORIEVE", cEvtNew )
			EndIf

			If lMultVinc
				oModel:LoadValue( "MODEL_C91", "C91_MV", "1" )
			Else
				oModel:SetValue( "MODEL_C91", "C91_MV", "2" )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF250Rul( @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, lMultVinc, lExistTrab, @lFindTrab, lInfoCompl, aInfComp, cIDCat, cIdTrab, cNomEvC9V )

			// O TAUTO é gerado dentro da função acima e quando ele for gerado é necessário validar as informações dos cadastros predecessores.
			If lFindTrab
				lExistTrab := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				/*-----------------------------------------
				C91 - Informações de Folha de Pagamento
				-------------------------------------------*/
				oModel:LoadValue( "MODEL_C91", "C91_INDAPU", C91->C91_INDAPU)
				oModel:LoadValue( "MODEL_C91", "C91_PERAPU", C91->C91_PERAPU)
				oModel:LoadValue( "MODEL_C91", "C91_TRABAL", C91->C91_TRABAL)
				oModel:LoadValue( "MODEL_C91", "C91_CPF   ", C91->C91_CPF   )
				oModel:LoadValue( "MODEL_C91", "C91_NIS   ", C91->C91_NIS   )
				
				//tratamento para os campos tafckey e owner
				If TafColumnPos("C91_TAFKEY") .AND.TafColumnPos("C91_OWNER")

					//Pegar valor do owner
					cOwExi := C91->C91_OWNER
		
					oModel:LoadValue( "MODEL_C91", "C91_TAFKEY ", cKey  )

					If Empty(cOwExi) .AND. !Empty(cOwner)
						oModel:LoadValue( "MODEL_C91", "C91_OWNER ", cOwner  )
					Else
						If !cOwner $(cOwExi) .AND.!Empty(cOwner)
							cNewOw := Alltrim(cOwExi) + " | " + cOwner
							oModel:LoadValue( "MODEL_C91", "C91_OWNER ", cNewOw )
						EndIf
					EndIf

				EndIf

				If TAFColumnPos( "C91_XMLID" )
					oModel:LoadValue( "MODEL_C91", "C91_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_C91", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")

					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '', cLogOpeAnt )
					EndIf

				EndIf
				
				If lNovCenar 
					TafCrrMdl(oMdlNvCen, @oModel, C91->C91_ID, C91->C91_VERSAO )
				EndIf				

				/*------------------------------------------
					Informações relativas ao trabalhador intermitente
				--------------------------------------------*/
				If lLaySimplif

					nV6K := 1
					cV6KPath := "/eSocial/evtRemun/ideTrabalhador/infoInterm[" + CVALTOCHAR(nV6K) + "]"

					If nOpc == 4 .And. oDados:XPathHasNode( cV6KPath )

						For nJ := 1 to oModel:GetModel( 'MODEL_V6K' ):Length()
							oModel:GetModel( 'MODEL_V6K' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_V6K' ):DeleteLine()
						Next nJ

					EndIf

					nV6K := 1
				
					While oDados:XPathHasNode(cV6KPath)

						oModel:GetModel( 'MODEL_V6K' ):LVALID	:= .T.

						If nOpc == 4 .Or. nV6K > 1
							oModel:GetModel( 'MODEL_V6K' ):AddLine()
						EndIf
								
						oModel:LoadValue("MODEL_V6K", "V6K_DIA", FTafGetVal( cV6KPath + "/dia", "C", .F., @aIncons, .F. ) )
						
						nV6K++
						cV6KPath := "/eSocial/evtRemun/ideTrabalhador/infoInterm[" + CVALTOCHAR(nV6K) + "]"

					EndDo

				EndIf 
				/*------------------------------------------
					Informações do periodo de Apuração
					T14 - Informações do Recibo de Pag.
				--------------------------------------------*/
				nT14 := 1
				cT14Path := "/eSocial/evtRemun/dmDev[" + CVALTOCHAR(nT14) + "]"

				cChvFil  := xFilial("C91")
				cChvId   := C91->C91_ID
				cChvVer  := C91->C91_VERSAO
				cChvInd  := Space(TamSX3("T14_INDAPU")[1])
				cChvPer  := Space(TamSX3("T14_PERAPU")[1])
				cChvTrab := Space(TamSX3("T14_TRABAL")[1])				

				oModelT14 := oModel:GetModel( 'MODEL_T14' )

				While oDados:XPathHasNode(cT14Path)
					
					oModel:GetModel( 'MODEL_T14' ):LVALID	:= .T.

					cChvIde  := PadR( FTafGetVal( cT14Path + "/ideDmDev", "C", .F., @aIncons, .F. ), TamSX3( "T14_IDEDMD" )[1] )

					//---------------------------------------------------------------------------------------------------------------
					//Caso encontre a chave do registro na tabela faço a alteração, caso contrário apenas incluo a linha nova na GRID
					//---------------------------------------------------------------------------------------------------------------
					If !oModelT14:SeekLine( { {"T14_FILIAL", cChvFil } , {"T14_ID", cChvId } ,{"T14_VERSAO", cChvVer },{"T14_IDEDMD", cChvIde },{"T14_INDAPU", cChvInd },{"T14_PERAPU", cChvPer },{"T14_TRABAL", cChvTrab } } )
						
						If !oModelT14:IsEmpty()
							oModelT14:AddLine()
						EndIf

					Else

						oModelT14:DeleteLine()
						oModelT14:AddLine()
						
					EndIf

					If oDados:XPathHasNode( cT14Path + "/ideDmDev")
						oModel:LoadValue( "MODEL_T14", "T14_IDEDMD",  FTafGetVal( cT14Path + "/ideDmDev", "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(	cT14Path + "/codCateg")
						oModel:LoadValue( "MODEL_T14", "T14_CODCAT" , FGetIdInt( "codCateg", "",  cT14Path + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
					EndIf

					If lSimplBeta .And. TafColumnPos("T14_INDRRA")					

						If oDados:XPathHasNode(	cT14Path + "/indRRA" )
							cIndRRA := FTafGetVal( cT14Path + "/indRRA", "C", .F., @aIncons, .F. )
							oModel:LoadValue( "MODEL_T14", "T14_INDRRA" , IIF( cIndRRA == "S", "1", "") )
						EndIf
						
						If oDados:XPathHasNode(	cT14Path + "/infoRRA/tpProcRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_TPPRRA" , FTafGetVal( cT14Path + "/infoRRA/tpProcRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/nrProcRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_NRPRRA" , FTafGetVal( cT14Path + "/infoRRA/nrProcRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/descRRA"  )
							oModel:LoadValue( "MODEL_T14", "T14_DESCRA" , FTafGetVal( cT14Path + "/infoRRA/descRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/qtdMesesRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_QTMRRA" , FTafGetVal( cT14Path + "/infoRRA/qtdMesesRRA", "N", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/despProcJud/vlrDespCustas" )
							oModel:LoadValue( "MODEL_T14", "T14_VLRCUS" , FTafGetVal( cT14Path + "/infoRRA/despProcJud/vlrDespCustas", "N", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/despProcJud/ vlrDespAdvogados" )
							oModel:LoadValue( "MODEL_T14", "T14_VLRADV" , FTafGetVal( cT14Path + "/infoRRA/despProcJud/vlrDespAdvogados", "N", .F., @aIncons, .F. ) )
						EndIf

						/*---------------------------------------
						   V9K - Identificação dos advogados
						----------------------------------------*/
						nV9K:= 1
						cV9KPath := cT14Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9K) + "]"

						While oDados:XPathHasNode(cV9KPath)

							oModelV9K := oModel:GetModel( 'MODEL_V9K' )
							oModel:GetModel( 'MODEL_V9K' ):LVALID	:= .T.

							If nV9K > 1
								oModel:GetModel( 'MODEL_V9K' ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV9KPath + "/tpInsc")
								oModel:LoadValue( "MODEL_V9K", "V9K_TPINSC"	, FTafGetVal( cV9KPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9KPath + "/nrInsc")
								oModel:LoadValue( "MODEL_V9K", "V9K_NRINSC"	, FTafGetVal( cV9KPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9KPath + "/vlrAdv")
								oModel:LoadValue( "MODEL_V9K", "V9K_VLRADV"	, FTafGetVal( cV9KPath + "/vlrAdv", "N", .F., @aIncons, .F. ) )
							EndIf

							nV9K++
							cV9KPath := cT14Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9K) + "]"

						EndDo

					EndIf

					If oXML:XPathHasNode(cT14Path + "/infoComplCont") 
						cCodCat := AllTrim(FTafGetVal(cT14Path + "/codCateg", "C", .F., @aIncons, .F.))
						cCPF	:= AllTrim(FTafGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F.))

						If oDados:XPathHasNode(cPathPerApu + "/matricula") .And. !Empty(FTafGetVal(cPathPerApu + "/matricula","C", .F., , .F.))
							cMatricula := AllTrim(FTafGetVal(cPathPerApu + "/matricula", "C", .F., @aIncons, .F.))
						ElseIf oDados:XPathHasNode(cPathPerAnt + "/matricula") .And. !Empty(FTafGetVal(cPathPerAnt + "/matricula","C", .F., , .F.))
							cMatricula := AllTrim(FTafGetVal(cPathPerAnt + "/matricula", "C", .F., @aIncons, .F.))
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoComplCont/codCBO")
							oModel:LoadValue( "MODEL_T14", "T14_CODCBO" , FGetIdInt( "codCBO", "",  cT14Path + "/infoComplCont/codCBO",,,,@cInconMsg, @nSeqErrGrv))
						EndIf

						If oDados:XPathHasNode( cT14Path + "/infoComplCont/natAtividade")
							oModel:LoadValue( "MODEL_T14", "T14_NATATV",  FTafGetVal( cT14Path + "/infoComplCont/natAtividade", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cT14Path + "/infoComplCont/qtdDiasTrab")
							oModel:LoadValue( "MODEL_T14", "T14_QTDTRB",  FTafGetVal( cT14Path + "/infoComplCont/qtdDiasTrab", "C", .F., @aIncons, .F. ) )
						EndIf
						
					EndIf
					
					/*------------------------------------------
						C9K - Informações do Estab./Lotação
					--------------------------------------------*/
					nC9K:= 1
					cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + CVALTOCHAR(nC9K) + "]"

					While oDados:XPathHasNode(cC9KPath)

						oModelC9K := oModel:GetModel( 'MODEL_C9K' )
						oModel:GetModel( 'MODEL_C9K' ):LVALID	:= .T.

						If nC9K > 1
							oModel:GetModel( 'MODEL_C9K' ):AddLine()
						EndIf

						If !lMultVinc .And. lExistTrab
							
							cTpLot := GetADVFVal("C99", "C99_TPLOT", xFilial("C99") + FGetIdInt( "codLotacao", "", cC9KPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv) + '1', 4, "")
							
							If !(cTpLot $ "000002")   
							
								If oDados:XPathHasNode(	cC9KPath + "/tpInsc" , cC9KPath + "/nrInsc" )
									oModel:LoadValue( "MODEL_C9K", "C9K_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cC9KPath + "/tpInsc" , cC9KPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) )
								EndIf

							Else
							
								If oDados:XPathHasNode(	cC9KPath + "/tpInsc" )
									oModel:LoadValue( "MODEL_C9K", "C9K_TPINSC", FTafGetVal( cC9KPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cC9KPath + "/nrInsc" )
									oModel:LoadValue( "MODEL_C9K", "C9K_NRINSC", SubStr(FTafGetVal( cC9KPath + "/nrInsc", "C", .F., @aIncons, .F. ),1,14) )
								EndIf	
								
								If oDados:XPathHasNode(	cC9KPath + "/codLotacao" )
									oModel:LoadValue( "MODEL_C9K", "C9K_CODLOT", FTafGetVal( cC9KPath + "/codLotacao", "C", .F., @aIncons, .F. ) )
								EndIf				
							
							EndIf

							If oDados:XPathHasNode(	cC9KPath + "/codLotacao" )
								oModel:LoadValue( "MODEL_C9K", "C9K_LOTACA", FGetIdInt( "codLotacao", "", cC9KPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv) )
							EndIf

						Else

							If oDados:XPathHasNode(	cC9KPath + "/codLotacao" )
								oModel:LoadValue( "MODEL_C9K", "C9K_CODLOT", FTafGetVal( cC9KPath + "/codLotacao", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cC9KPath + "/tpInsc" )
								oModel:LoadValue( "MODEL_C9K", "C9K_TPINSC", FTafGetVal( cC9KPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cC9KPath + "/nrInsc" )
								oModel:LoadValue( "MODEL_C9K", "C9K_NRINSC", FTafGetVal( cC9KPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
							EndIf

						EndIf

						If oDados:XPathHasNode(cC9KPath + "/qtdDiasAv" )
							oModel:LoadValue( "MODEL_C9K", "C9K_QTDDIA", FTafGetVal( cC9KPath + "/qtdDiasAv", "C", .F., @aIncons, .F. ) )
						EndIf

						/*------------------------------------------
							C9L - Informações da Remuneração Trab.
						--------------------------------------------*/
						nC9L:= 1
						cC9LPath := cC9KPath+"/remunPerApur[" + CVALTOCHAR(nC9L) + "]"

						While oDados:XPathHasNode(cC9LPath)

							oModelC9L := oModel:GetModel( 'MODEL_C9L' )
							oModel:GetModel( 'MODEL_C9L' ):LVALID	:= .T.

							If nC9L > 1
								oModel:GetModel( 'MODEL_C9L' ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cC9LPath + "/infoAgNocivo/grauExp" )
								oModel:LoadValue( "MODEL_C9L", "C9L_GRAEXP", FGetIdInt( "grauExp", "", cC9LPath + "/infoAgNocivo/grauExp",,,,@cInconMsg, @nSeqErrGrv))
							EndIf

							If oDados:XPathHasNode(	cC9LPath + "/indSimples" )
								oModel:LoadValue( "MODEL_C9L", "C9L_INDCON", FTafGetVal( cC9LPath + "/indSimples", "C", .F., @aIncons, .F. ) )
							EndIF

							//Rodrigo Aguilar - 23/05/2017
							//Se existir a TAG sei que se trata de um trabalhador autonomo, sendo assim faço o seek
							//na tabela de trabalhador autonomo, para manter a integridade entre as tabelas PAI e FILHO
							//no cadastro
							If oDados:XPathHasNode("/eSocial/evtRemun/ideTrabalhador/infoComplem") .and. ;
									oDados:XPathHasNode("/eSocial/evtRemun/ideTrabalhador/cpfTrab")

								// --> Somente se não possuir múltiplos vínculos. Caso existe mv, então utiliza as informações do XML ao invés de pegar o ID do trabalhador sem vínculo
								If !lMultVinc
									cC9L_TRABAL := cIdTrab
								EndIf

							//Rodrigo Aguilar - 23/05/2017
							//Caso não seja um trabalhador autonomo faço o seek no trabalhador com a matricula para
							//preencher a tabela
							ElseIf oDados:XPathHasNode(	cC9LPath + "/matricula" )
								
								cMatricC9L := FTafGetVal( cC9LPath + "/matricula", "C", .F., @aIncons, .F. )

								// --> Somente se não possuir múltiplos vínculos. Caso existe mv, então utiliza as informações do XML ao invés de pegar o ID do trabalhador
								If !lMultVinc

									If lLaySimplif
										aEvento := TAFIdFunc(cCpfT3A, cMatricC9L,@cInconMsg, @nSeqErrGrv)
										cC9L_TRABAL := aEvento[1]
									Else
										cC9L_TRABAL := FGetIdInt( "matricula", "", cMatricC9L, , .F.,,@cInconMsg, @nSeqErrGrv)
									EndIf

								EndIf

							Else
								cC9L_TRABAL := ' '
							EndIf

							If !lMultVinc .And. lExistTrab
								oModel:LoadValue("MODEL_C9L", "C9L_TRABAL", cC9L_TRABAL )
								oModel:LoadValue("MODEL_C9L", "C9L_DTRABA", FTafGetVal( cC9LPath + "/matricula", "C", .F., @aIncons, .F. ) )
							Else
								oModel:LoadValue("MODEL_C9L", "C9L_DTRABA", FTafGetVal( cC9LPath + "/matricula", "C", .F., @aIncons, .F. ) )
							EndIf

							If lLaySimplif
								oModel:LoadValue("MODEL_C9L", "C9L_NOMEVE", cEvtNew )
							EndIf

							/*------------------------------------------
								C9M - Itens da Remuneração Trab.
							--------------------------------------------*/
							nC9M := 1
							cC9MPath := cC9LPath+"/itensRemun[" + CVALTOCHAR(nC9M) + "]"

							While oDados:XPathHasNode(cC9MPath)

								oModelC9M := oModel:GetModel( 'MODEL_C9M' )
								oModel:GetModel( 'MODEL_C9M' ):LVALID	:= .T.

								If nC9M > 1
									oModel:GetModel( 'MODEL_C9M' ):AddLine()
								EndIf

								If oDados:XPathHasNode(	cC9MPath + "/ideTabRubr")
									cIdTabR := TAFIdTabRub( FTafGetVal( cC9MPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cC9MPath + "/codRubr", "C", .F., @aIncons, .F. ) )
									
									If Empty(cIdTabR) .And. __lValidTabRub
										//Gera mensagem de erro
										TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', FTafGetVal( cC9MPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), '', , '', '' )
									EndIf

									oModel:LoadValue( "MODEL_C9M", "C9M_IDTABR"	, cIdTabR )

								Else

									cIdTabR := ""

									//Gera mensagem de erro
									TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

								EndIf

								If !lMultVinc .And. lExistTrab

									If oDados:XPathHasNode(	cC9MPath + "/codRubr")
										cCodRubr := FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cC9MPath + "/codRubr", "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-",""))
										oModel:LoadValue( "MODEL_C9M", "C9M_CODRUB", cCodRubr )
									EndIf

								Else

									If oDados:XPathHasNode(	cC9MPath + "/codRubr")
										cCodRubr := FTafGetVal( cC9MPath + "/codRubr", "C", .F., @aIncons, .F. )
										oModel:LoadValue( "MODEL_C9M", "C9M_RUBRIC"	, cCodRubr)
											
									EndIf

								EndIf

								If oDados:XPathHasNode(	cC9MPath + "/qtdRubr")
									oModel:LoadValue( "MODEL_C9M", "C9M_QTDRUB"	, FTafGetVal( cC9MPath + "/qtdRubr", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cC9MPath + "/fatorRubr")
									oModel:LoadValue( "MODEL_C9M", "C9M_FATORR"	, FTafGetVal( cC9MPath + "/fatorRubr", "N", .F., @aIncons, .F. ) )
								EndIf

								If !lLaySimplif

									If oDados:XPathHasNode( cC9MPath + "/vrUnit"	)
										oModel:LoadValue( "MODEL_C9M", "C9M_VLRUNT"	, FTafGetVal( cC9MPath + "/vrUnit", "N", .F., @aIncons, .F. ) )
									EndIf

								EndIf

								If oDados:XPathHasNode( cC9MPath + "/vrRubr")
									oModel:LoadValue( "MODEL_C9M", "C9M_VLRRUB"	, FTafGetVal( cC9MPath + "/vrRubr", "N", .F., @aIncons, .F. ) )
								EndIf

								If lLaySimplif

									If oDados:XPathHasNode( cC9MPath + "/indApurIR")
										oModel:LoadValue( "MODEL_C9M", "C9M_APURIR"	, FTafGetVal( cC9MPath + "/indApurIR", "C", .F., @aIncons, .F. ) )
									EndIf

								EndIf
								
								If lInfoRPT

									aRubrica := oReport:GetRubrica( cCodRubr, cIDTabR, cPeriodo, lMultVinc )

									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cC9LPath + "/matricula", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cT14Path + "/codCateg", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cC9KPath + "/tpInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cC9KPath + "/nrInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cC9KPath + "/codLotacao", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cC9MPath + "/vrRubr", "N", .F.,, .F. )
									aAnalitico[nPosValores][ANALITICO_RECIBO]				:=  AllTrim( FTAFGetVal( cT14Path + "/ideDmDev", "C", .F.,, .F. ) )
								
								EndIf

								nC9M++
								cC9MPath := cC9LPath+"/itensRemun[" + CVALTOCHAR(nC9M) + "]"

							EndDo

							/*-----------------------------------------
								Informações de Planos de Saudade
									T6Y - Valores Pagos
							------------------------------------------*/
							If !lLaySimplif

								nT6Y:= 1
								cT6YPath := cC9LPath+"/infoSaudeColet/detOper[" + CVALTOCHAR(nT6Y) + "]"

								While oDados:XPathHasNode(cT6YPath)

									oModelT6Y := oModel:GetModel( 'MODEL_T6Y' )
									oModel:GetModel( 'MODEL_T6Y' ):LVALID	:= .T.

									If nT6Y > 1
										oModel:GetModel( 'MODEL_T6Y' ):AddLine()
									EndIf

									If oDados:XPathHasNode( cT6YPath + "/cnpjOper")
										oModel:LoadValue( "MODEL_T6Y", "T6Y_CNPJOP",  FTafGetVal( cT6YPath + "/cnpjOper"   , "C", .F.		, @aIncons, .F. ))
									EndIf

									If oDados:XPathHasNode( cT6YPath + "/regANS" )
										oModel:LoadValue( "MODEL_T6Y", "T6Y_REGANS"	, FTafGetVal( cT6YPath + "/regANS"  , "C", .F.	, @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cT6YPath + "/vrPgTit")
										oModel:LoadValue( "MODEL_T6Y", "T6Y_VLPGTI"	, FTafGetVal( cT6YPath + "/vrPgTit" , "N", .F.	, @aIncons, .F. ) )
									EndIF

									oModel:LoadValue( "MODEL_T6Y", "T6Y_NOMEVE"	, "S1200" )

									/*----------------------------------------
										T6Z - Informações dos dependentes
									------------------------------------------*/
									nT6Z := 1
									cT6ZPath := cT6YPath + "/detPlano[" + cValToChar( nT6Z ) + "]"

									While oDados:xPathHasNode( cT6ZPath )
										oModelT6Z := oModel:GetModel( "MODEL_T6Z" )
										oModel:GetModel( "MODEL_T6Z" ):lValid := .T.

										If nT6Z > 1
											oModel:GetModel( "MODEL_T6Z" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_T6Z", "T6Z_SEQUEN", StrZero( nT6Z, nT6Z_SEQUEN ) )

										If oDados:xPathHasNode( cT6ZPath + "/tpDep" )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_TPDEP", FGetIdInt( "tpDep", "", cT6ZPath + "/tpDep",,,, @cInconMsg, @nSeqErrGrv ) )
										EndIf

										If oDados:xPathHasNode( cT6ZPath + "/cpfDep" )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_CPFDEP", FTafGetVal( cT6ZPath + "/cpfDep", "C", .F., @aIncons, .F. ) )
										EndIf

										If oDados:xPathHasNode( cT6ZPath + "/nmDep" )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMDEP", FTafGetVal( cT6ZPath + "/nmDep", "C", .F., @aIncons, .F. ) )
										EndIf

										If oDados:xPathHasNode( cT6ZPath + "/dtNascto" )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_DTNDEP", FTafGetVal( cT6ZPath + "/dtNascto", "D", .F., @aIncons, .F. ) )
										EndIf

										If oDados:xPathHasNode( cT6ZPath + "/vlrPgDep" )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_VPGDEP", FTafGetVal( cT6ZPath + "/vlrPgDep", "N", .F., @aIncons, .F. ) )
										EndIf

										oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMEVE", "S1200" )

										nT6Z ++
										cT6ZPath := cT6YPath + "/detPlano[" + cValToChar( nT6Z ) + "]"

									EndDo

									nT6Y ++
									cT6YPath := cC9LPath + "/infoSaudeColet/detOper[" + cValToChar( nT6Y ) + "]"

								EndDo
							
								/*------------------------------------------
									V1B - Infos Trab Interm Per Apuração
								--------------------------------------------*/
								nV1B:= 1
								cV1BPath := cC9LPath+"/infoTrabInterm[" + CVALTOCHAR(nV1B) + "]"

								While oDados:XPathHasNode(cV1BPath)

									oModelV1B := oModel:GetModel( 'MODEL_V1B' )
									oModel:GetModel( 'MODEL_V1B' ):LVALID	:= .T.

									If nV1B > 1
										oModel:GetModel( 'MODEL_V1B' ):AddLine()
									EndIf

									If oDados:XPathHasNode(	cV1BPath + "/codConv")                                        
										cCodConv    := FTafGetVal( cV1BPath + "/codConv", "C", .F., @aIncons, .F. )
										cIdConvT    := FGetIdInt(   "matricula", "",;
																	fTafGetVal( "/eSocial/evtRemun/dmDev[" + CvalToChar(nT14) + "]/infoPerApur/ideEstabLot[" + CVALTOCHAR(nC9K) + "]/remunPerApur/matricula", "C", .F., @aIncons, .F. ),;
																	,;
																	.F.,;
																	,;
																	@cInconMsg,;
																	@nSeqErrGrv)

										cIdConv     := FGetIdInt( "codConv", "", cIdConvT, cCodConv, .F.,, @cInconMsg, @nSeqErrGrv )
										
										oModel:LoadValue( "MODEL_V1B", "V1B_IDCONV"	, cIdConv )

									EndIf

									nV1B++
									cV1BPath := cC9LPath+"/infoTrabInterm[" + CVALTOCHAR(nV1B) + "]"

								EndDo

							EndIf

							nC9L++
							cC9LPath := cC9KPath + "/remunPerApur[" + CVALTOCHAR(nC9L) + "]"

						EndDo

						nC9K++
						cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + CVALTOCHAR(nC9K) + "]"

					EndDo

					/*-----------------------------------------
					Informações de Periodo de Apur Anterior
							C9N - Informações do Acordo
					------------------------------------------*/
					nC9N := 1
					cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + CVALTOCHAR(nC9N) + "]"

					While oDados:XPathHasNode(cC9NPath)

						cCompAcConv := ""
						cDtAcEfe := ""

						oModelC9N := oModel:GetModel( 'MODEL_C9N' )
						oModel:GetModel( 'MODEL_C9N' ):LVALID	:= .T.

						If nC9N > 1
							oModel:GetModel( 'MODEL_C9N' ):AddLine()
						EndIf

						If oDados:XPathHasNode( cC9NPath + "/dtAcConv")
							oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR"	, FTafGetVal( cC9NPath + "/dtAcConv", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cC9NPath + "/tpAcConv")
							oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR"	, FTafGetVal( cC9NPath + "/tpAcConv", "C", .F., @aIncons, .F. ) )
						EndIf

						If !lLaySimplif

							If oDados:XPathHasNode( cC9NPath + "/compAcConv")
								cCompAcConv := AllTrim(StrTran(FTafGetVal( cC9NPath + "/compAcConv", "C", .F., @aIncons, .F. ), "-", "" ))
								oModel:LoadValue( "MODEL_C9N", "C9N_COMPAC"	, cCompAcConv)
							EndIf

							If oDados:XPathHasNode( cC9NPath + "/dtEfAcConv")
								cDtAcEfe := FTafGetVal( cC9NPath + "/dtEfAcConv", "D", .F., @aIncons, .F. )
								oModel:LoadValue( "MODEL_C9N", "C9N_DTEFAC"	, cDtAcEfe)
								cDtAcEfe := DTOS(cDtAcEfe)
							EndIf

						EndIf

						If TafColumnPos( "C9N_RELACO" ) .And. !Empty(cCompAcConv+cDtAcEfe)
							oModel:LoadValue( "MODEL_C9N", "C9N_RELACO"	, cCompAcConv+cDtAcEfe)
						EndIf 

						If oDados:XPathHasNode( cC9NPath + "/dsc")
							oModel:LoadValue( "MODEL_C9N", "C9N_DSC"	, FTafGetVal( cC9NPath + "/dsc", "M", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cC9NPath + "/remunSuc")
							oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS"	, xFunTrcSN( TAFExisTag( cC9NPath + "/remunSuc" ) ,2))
						EndIf

						nC9O:= 1
						cC9OPath := cC9NPath  + "/idePeriodo[" + CVALTOCHAR(nC9O) + "]"

						While oDados:XPathHasNode(cC9OPath)

							oModelC9O := oModel:GetModel( 'MODEL_C9O' )
							oModel:GetModel( 'MODEL_C9O' ):LVALID	:= .T.

							If nC9O > 1
								oModel:GetModel( 'MODEL_C9O' ):AddLine()
							EndIf

							If oDados:XPathHasNode( cC9OPath + "/perRef" )

								If At("-", FTafGetVal( cC9OPath + "/perRef", "C", .F., @aIncons, .F. )) > 0
									oModel:LoadValue( "MODEL_C9O", "C9O_PERREF"	,StrTran( FTafGetVal( cC9OPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" ) )
								Else
									oModel:LoadValue( "MODEL_C9O", "C9O_PERREF"	,FTafGetVal( cC9OPath + "/perRef", "C", .F., @aIncons, .F. ) )
								EndIf

							EndIf

							/*------------------------------------------
								C9P - Informações do Estab./Lotac.
							--------------------------------------------*/
							nC9P:= 1
							cC9PPath := cC9OPath + "/ideEstabLot[" + CVALTOCHAR(nC9P) + "]

							While oDados:XPathHasNode(cC9PPath)

								oModelC9P := oModel:GetModel( 'MODEL_C9P' )
								oModel:GetModel( 'MODEL_C9P' ):LVALID	:= .T.

								If nC9P > 1
									oModel:GetModel( 'MODEL_C9P' ):AddLine()
								EndIf

								If !lMultVinc .And. lExistTrab

									If oDados:XPathHasNode( cC9PPath + "/tpInsc" ) .or. oDados:XPathHasNode(cC9PPath + "/nrInsc" )
										oModel:LoadValue( "MODEL_C9P", "C9P_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cC9PPath + "/tpInsc" , cC9PPath + "/nrInsc" ,,,@cInconMsg, @nSeqErrGrv))
									EndIf

									If oDados:XPathHasNode( cC9PPath + "/codLotacao" )
										oModel:LoadValue( "MODEL_C9P", "C9P_LOTACA", FGetIdInt( "codLotacao", "", cC9PPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv) )
									EndIf

								Else

									If oDados:XPathHasNode(	cC9PPath + "/codLotacao" )
										oModel:LoadValue( "MODEL_C9P", "C9P_CODLOT", FTafGetVal( cC9PPath + "/codLotacao", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(	cC9PPath + "/tpInsc" )
										oModel:LoadValue( "MODEL_C9P", "C9P_TPINSC", FTafGetVal( cC9PPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(	cC9PPath + "/nrInsc" )
										oModel:LoadValue( "MODEL_C9P", "C9P_NRINSC", SubStr(FTafGetVal( cC9PPath + "/nrInsc", "C", .F., @aIncons, .F. ),1 ,14) )
									EndIf

								EndIf

								/*------------------------------------------
									C9Q - Informações da Remuneração
								--------------------------------------------*/
								nTipPer		:= 2	// 1=Período Atual; 2=Período Anterior
								nC9Q		:= 1
								cC9QPath 	:= cC9PPath+ "/remunPerAnt[" + CVALTOCHAR(nC9Q) + "]"

								While oDados:XPathHasNode(cC9QPath)

									oModelC9Q := oModel:GetModel( 'MODEL_C9Q' )
									oModel:GetModel( 'MODEL_C9Q' ):LVALID	:= .T.

									If nC9Q > 1
										oModel:GetModel( 'MODEL_C9Q' ):AddLine()
									EndIf

									If oDados:XPathHasNode(	cC9QPath + "/infoAgNocivo/grauExp" )
										oModel:LoadValue( "MODEL_C9Q", "C9Q_GRAEXP"	, FGetIdInt( "grauExp", "", cC9QPath + "/infoAgNocivo/grauExp",,,,@cInconMsg, @nSeqErrGrv))
									EndIf

									If oDados:XPathHasNode(	cC9QPath + "/indSimples" )
										oModel:LoadValue( "MODEL_C9Q", "C9Q_INDCON" , FTafGetVal( cC9QPath + "/indSimples", "C", .F., @aIncons, .F. ) )
									EndIf

									If !lMultVinc .And. lExistTrab

										//VERIFICA DE QUAL LUGAR PEGAR O ID DO TRABALHADOR

										If oDados:XPathHasNode( cC9QPath + "/matricula" )

											cMatricC9Q := FTafGetVal( cC9QPath + "/matricula", "C", .F., @aIncons, .F. )

											If lLaySimplif
												aEvento := TAFIdFunc(cCpfT3A, cMatricC9Q,@cInconMsg, @nSeqErrGrv)
												cC9Q_TRABAL := aEvento[1] 
											Else
												cC9Q_TRABAL := FGetIdInt( "matricula", "", cMatricC9Q, , .F.,,@cInconMsg, @nSeqErrGrv)
											EndIf

											oModel:LoadValue( "MODEL_C9Q", "C9Q_TRABAL", cC9Q_TRABAL )

										ElseIf oDados:XPathHasNode( cC9QPath + "/itensRemun[1]" )

											oModel:LoadValue( "MODEL_C9Q", "C9Q_TRABAL", " " )

										EndIf

									Else

										If TafColumnPos( "C9Q_MATRIC" )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_MATRIC", FTafGetVal( cC9QPath + "/matricula", "C", .F., @aIncons, .F. ) )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_DTRABA", PadR(FTafGetVal( cC9QPath + "/matricula", "C", .F., @aIncons, .F. ),TamSX3('C9Q_MATRIC')[1]) + PadR(FTafGetVal( cC9PPath + "/codLotacao", "C", .F., @aIncons, .F. ),TamSX3('C9P_CODLOT')[1]) )
										Else
											oModel:LoadValue( "MODEL_C9Q", "C9Q_DTRABA", FTafGetVal( cC9QPath + "/matricula", "C", .F., @aIncons, .F. ) )
										EndIf

									EndIf
									
									If lLaySimplif
										oModel:LoadValue( "MODEL_C9Q", "C9Q_NOMEVE", cEvtNew )
									EndIf
									
									/*------------------------------------
										C9R - Itens da Remuneração
									--------------------------------------*/
									nC9R:= 1
									cC9RPath := cC9QPath + "/itensRemun[" + CVALTOCHAR(nC9R) + "]"

									While oDados:XPathHasNode(cC9RPath)

										oModelC9R := oModel:GetModel( 'MODEL_C9R' )
										oModel:GetModel( 'MODEL_C9R' ):LVALID	:= .T.

										If nC9R > 1
											oModel:GetModel( 'MODEL_C9R' ):AddLine()
										EndIf

										If oDados:XPathHasNode(	cC9RPath + "/ideTabRubr")

											cIdTabR := TAFIdTabRub( FTafGetVal( cC9RPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cC9RPath + "/codRubr", "C", .F., @aIncons, .F. )  )
				
											If Empty(cIdTabR) .And. __lValidTabRub
												//Gera mensagem de erro
												TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', FTafGetVal( cC9MPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), '', , '', '' )
											EndIf

										Else

											cIdTabR := ""

											//Gera mensagem de erro
											TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

										EndIf

										If !lMultVinc .And. lExistTrab

											If oDados:XPathHasNode( cC9RPath + "/codRubr" )
												cCodRubr := FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cC9RPath + "/codRubr", "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-",""))
												oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB", cCodRubr)
											EndIf

										Else

											If oDados:XPathHasNode(	cC9RPath + "/codRubr")
												cCodRubr := FTafGetVal( cC9RPath + "/codRubr", "C", .F., @aIncons, .F. )
												oModel:LoadValue( "MODEL_C9R", "C9R_RUBRIC"	, cCodRubr )
											EndIf

											If oDados:XPathHasNode(	cC9RPath + "/ideTabRubr")
												oModel:LoadValue( "MODEL_C9R", "C9R_IDTABR"	, cIdTabR )
											EndIf

										EndIf

										If oDados:XPathHasNode( cC9RPath + "/qtdRubr" )
											oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB"	, FTafGetVal( cC9RPath + "/qtdRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode(	cC9RPath + "/fatorRubr")
											oModel:LoadValue( "MODEL_C9R", "C9R_FATORR"	, FTafGetVal( cC9RPath + "/fatorRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If !lLaySimplif

											If oDados:XPathHasNode( cC9RPath + "/vrUnit" )
												oModel:LoadValue( "MODEL_C9R", "C9R_VLRUNT"	, FTafGetVal( cC9RPath + "/vrUnit", "N", .F., @aIncons, .F. ) )
											EndIf

										EndIf

										If oDados:XPathHasNode( cC9RPath + "/vrRubr" )
											oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB"	, FTafGetVal( cC9RPath + "/vrRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If lLaySimplif

											If oDados:XPathHasNode( cC9RPath + "/indApurIR")
												oModel:LoadValue( "MODEL_C9R", "C9R_APURIR"	, FTafGetVal( cC9RPath + "/indApurIR", "C", .F., @aIncons, .F. ) )
											EndIf

										EndIf

										If lInfoRPT

											aRubrica := oReport:GetRubrica( cCodRubr, cIDTabR, cPeriodo, lMultVinc, nTipPer )

											aAdd( aAnalitico, Array( 16 ) )
											nPosValores := Len( aAnalitico )

											aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	PadR(FTAFGetVal( cC9QPath + "/matricula", "C", .F.,, .F. ),TamSX3('C9Q_MATRIC')[1])
											aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cT14Path + "/codCateg", "C", .F.,, .F. ) )
											aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cC9PPath + "/tpInsc", "C", .F.,, .F. ) )
											aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cC9PPath + "/nrInsc", "C", .F.,, .F. ) )
											aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cC9PPath + "/codLotacao", "C", .F.,, .F. ) )
											aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
											aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
											aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
											aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
											aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
											aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cC9RPath + "/vrRubr", "N", .F.,, .F. )
											aAnalitico[nPosValores][ANALITICO_RECIBO]				:=  AllTrim( FTAFGetVal( cT14Path + "/ideDmDev", "C", .F.,, .F. ) )
										
										EndIf

										nC9R++
										cC9RPath := cC9QPath + "/itensRemun[" + CVALTOCHAR(nC9R) + "]"

									EndDo

									If !lLaySimplif

										/*---------------------------------------
											V1C - Infos Trab Interm Per Anterior
										----------------------------------------*/
										nV1C:= 1
										cV1CPath := cC9QPath + "/infoTrabInterm[" + CVALTOCHAR(nV1C) + "]"

										While oDados:XPathHasNode(cV1CPath)

											oModelV1C := oModel:GetModel( 'MODEL_V1C' )
											oModel:GetModel( 'MODEL_V1C' ):LVALID	:= .T.

											If nV1C > 1
												oModel:GetModel( 'MODEL_V1C' ):AddLine()
											EndIf

											If oDados:XPathHasNode(	cV1CPath + "/codConv")
												cCodConv := FTafGetVal( cV1CPath + "/codConv", "C", .F., @aIncons, .F. )
												cIdConv := Posicione("T87",2,xFilial("T87")+PADR(cIdTrab,GetSx3Cache("C91_TRABAL","X3_TAMANHO"))+PADR(cCodConv,GetSx3Cache("T87_CONVOC","X3_TAMANHO"))+"1","T87_ID")
												oModel:LoadValue( "MODEL_V1C", "V1C_IDCONV"	, cIdConv )
											EndIf

											nV1C++
											cV1CPath := cC9QPath + "/infoTrabInterm[" + CVALTOCHAR(nV1C) + "]"

										EndDo

									EndIf

									nC9Q++
									cC9QPath := cC9PPath+ "/remunPerAnt[" + CVALTOCHAR(nC9Q) + "]"

								EndDo

								nC9P++
								cC9PPath := cC9OPath+"/ideEstabLot[" + CVALTOCHAR(nC9P) + "]"

							EndDo

							nC9O++
							cC9OPath := cC9NPath + "/idePeriodo[" + CVALTOCHAR(nC9O) + "]"

						EndDo

						nC9N++
						cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + CVALTOCHAR(nC9N) + "]"

					EndDo
					
					nT14++
					cT14Path := "/eSocial/evtRemun/dmDev[" + CVALTOCHAR(nT14) + "]"

				EndDo

				/*-----------------------------------------
						CRN - Informações de Processos Judic.
				------------------------------------------*/
				nCRN := 1
				cCRNPath := "/eSocial/evtRemun/ideTrabalhador/procJudTrab[" + CVALTOCHAR(nCRN) + "]"

				If nOpc == 4

					For nJ := 1 to oModel:GetModel( 'MODEL_CRN' ):Length()
						oModel:GetModel( 'MODEL_CRN' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_CRN' ):DeleteLine()
					Next nJ

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o XML parseado para gravar as novas informacoes no GRID³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCRN := 1
				While oDados:XPathHasNode(cCRNPath)

					oModel:GetModel( 'MODEL_CRN' ):LVALID	:= .T.

					If nOpc == 4 .Or. nCRN > 1
						oModel:GetModel('MODEL_CRN'):AddLine()
					EndIf

					If oDados:XPathHasNode(cCRNPath + "/tpTrib" )
						oModel:LoadValue("MODEL_CRN", "CRN_TPTRIB", FTafGetVal( cCRNPath + "/tpTrib", "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cCRNPath + "/nrProcJud" )
						cIdProc := FGetIdInt( "nrProcJ", ,cCRNPath + "/nrProcJud",,,,@cInconMsg, @nSeqErrGrv)
						oModel:LoadValue("MODEL_CRN", "CRN_IDPROC", cIdProc )

					EndIf

					If !Empty(cIdProc)

						If oDados:XPathHasNode(cCRNPath + "/codSusp" )
							oModel:LoadValue("MODEL_CRN", "CRN_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal( cCRNPath + "/codSusp", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )
						EndIf

					EndIf

					nCRN++
					cCRNPath := "/eSocial/evtRemun/ideTrabalhador/procJudTrab[" + CVALTOCHAR(nCRN) + "]"

				EndDo

				/*--------------------------------
					T6W - Multiplos Vinculos
				---------------------------------*/
				nT6W := 1
				cT6WPath := "/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr[" + CVALTOCHAR(nT6W) + "]"

				If nOpc == 4

					For nJ := 1 to oModel:GetModel( 'MODEL_T6W' ):Length()
						oModel:GetModel( 'MODEL_T6W' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_T6W' ):DeleteLine()
					Next nJ

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o XML parseado para gravar as novas informacoes no GRID³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nT6W := 1
				While oDados:XPathHasNode(cT6WPath)

					oModel:GetModel( 'MODEL_T6W' ):LVALID	:= .T.

					If nOpc == 4 .Or. nT6W > 1
						oModel:GetModel( 'MODEL_T6W' ):AddLine()
					EndIf

					If oDados:XPathHasNode( cT6WPath + "/tpInsc" )
						oModel:LoadValue( "MODEL_T6W", "T6W_TPINSC"	, FTafGetVal( cT6WPath + "/tpInsc","C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode( cT6WPath + "/nrInsc" )
						oModel:LoadValue( "MODEL_T6W", "T6W_NRINSC"	, SubStr(FTafGetVal( cT6WPath + "/nrInsc","C", .F., @aIncons, .F. ),1,14) )
					EndIf

					If oDados:XPathHasNode( cT6WPath + "/codCateg" )
						oModel:LoadValue( "MODEL_T6W", "T6W_CODCAT" , FGetIdInt( "codCateg", "",  cT6WPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
					EndIf

					If oDados:XPathHasNode( cT6WPath + "/vlrRemunOE" )
						oModel:LoadValue( "MODEL_T6W", "T6W_VLREMU"	, FTafGetVal( cT6WPath + "/vlrRemunOE","N", .F., @aIncons, .F. ) )
					EndIf

					oModel:LoadValue( "MODEL_T6W", "T6W_NOMEVE"	, "S1200" )

					nT6W++
					cT6WPath := "/eSocial/evtRemun/ideTrabalhador/infoMV/remunOutrEmpr[" + CVALTOCHAR(nT6W) + "]"

				EndDo

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg) .And. Empty(aIncons)

				xChkDupl := TafFormCommit( oModel, .T. )

				If ValType( xChkDupl ) == "A"

					If xChkDupl[1]
						Aadd(aIncons, "ERRO19" + "|" + xChkDupl[2] + "|" + xChkDupl[3])
					Else
						lRet := .T.
					EndIf

				ElseIf ValType( xChkDupl ) == "L"

					If xChkDupl
						Aadd(aIncons, "ERRO19")
					Else
						lRet := .T.
					EndIf

				EndIf

				If lRet .And. lInfoRPT
					InfoRPTObj(AllTrim(FTAFGetVal("/eSocial/evtRemun/ideEvento/indApuracao", "C", .F.,, .F.)),;
						AllTrim(StrTran(cPeriodo, "-", "")),; 
						AllTrim(FTAFGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F.,, .F.)),; 
						AllTrim(cNome), aAnalitico,, @oInfoRPT)

					oReport:UpSert("S-1200", "1", xFilial("C91"), oInfoRPT)

					InfoRPTObj(AllTrim(FTAFGetVal("/eSocial/evtRemun/ideEvento/indApuracao", "C", .F.,, .F.)),;
						AllTrim(StrTran(cPeriodo, "-", "")),; 
						AllTrim(FTAFGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F.,, .F.)),; 
						AllTrim(cNome), aAnalitico,, @oInfoRPT)

					oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT)
				EndIf

			Else

				Aadd(aIncons, cInconMsg)
				DisarmTransaction()

			EndIf

		EndIf

	End Transaction

	C9V->(DBCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules     := Nil

	aSize( aChave, 0 )
	aChave     := Nil

	oModel := NIL

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Rul

Regras para gravacao das informacoes do registro S-1200 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes


@author Vitor Siqueira
@since 08/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF250Rul( cInconMsg, nSeqErrGrv, cCodEvent, cOwner, lMultVinc, lExistTrab, lFindTrab, lInfoCompl, aInfComp, cIDCat, cIdTrab, cNomEvC9V )

	Local aRull        := {}
	Local cPeriodo     := FTafGetVal("/eSocial/evtRemun/ideEvento/perApur", "C", .F.,, .F. )
	Local cIdTrabal    := ""
	Local cPathPerAnt  := "/eSocial/evtRemun/dmDev[1]/infoPerAnt/ideADC[1]/idePeriodo[1]/ideEstabLot[1]/remunPerAnt[1]"
	Local cPathPerApu  := "/eSocial/evtRemun/dmDev[1]/infoPerApur/ideEstabLot[1]/remunPerApur"
	Local cCpfT3A      := ""
	Local aIncons      := {}

	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""
	Default lMultVinc  := .F.
	Default lExistTrab := .T.
	Default lFindTrab  := .F.
	Default aInfComp   := {}
	Default cIDCat     := ""
	Default cIdTrab    := ""
	Default cNomEvC9V  := ""

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtRemun/ideEvento/perApur") )

		If At("-", cPeriodo) > 0
			Aadd( aRull, {"C91_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )
		Else
			Aadd( aRull, {"C91_PERAPU", cPeriodo ,"C", .T.} )
		EndIf

		If lLaySimplif
			If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtRemun/ideEvento/indGuia") )
				Aadd( aRull, {"C91_TPGUIA", "/eSocial/evtRemun/ideEvento/indGuia","C",.F.} )
			EndIf
		EndIf

	EndIf

	If oDados:XPathHasNode("/eSocial/evtRemun/ideTrabalhador/infoComplem")

		If !lLaySimplif

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt" ) )
				Aadd( aRull, {"C91_TPINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt","C",.F.} )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt" ) )
				Aadd( aRull, {"C91_CNPJEA", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt","C",.F.} )
			EndIf

		Else

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInsc" ) )
				Aadd( aRull, {"C91_TPINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInsc","C",.F.} )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/nrInsc" ) )
				Aadd( aRull, {"C91_NRINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/nrInsc","C",.F.} )
			EndIf

		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt" ) )
			Aadd( aRull, {"C91_MATREA", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt","C",.F.} )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm" ) )
			Aadd( aRull, {"C91_DTINVI", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm","D",.F.} )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao" ) )
			Aadd( aRull, {"C91_OBSVIN", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao","C",.F.} )
		EndIf

	EndIf

	If !lMultVinc .Or. ( lMultVinc .And. lExistTrab )

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) )

			If lLaySimplif

				cCpfT3A := FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab","C", .F., , .F.)

				If (oDados:XPathHasNode(cPathPerApu + "/matricula")) .And. !Empty(FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.))
					aEvento := TAFIdFunc(cCpfT3A, FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.),@cInconMsg, @nSeqErrGrv)
					cIdTrabal := aEvento[1]
				ElseIf (oDados:XPathHasNode(cPathPerAnt + "/matricula")) .And. !Empty(FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.))
					aEvento := TAFIdFunc(cCpfT3A, FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.),@cInconMsg, @nSeqErrGrv)
					cIdTrabal := aEvento[1]
				ElseIf !Empty(cIdTrab) .AND. cNomEvC9V == "TAUTO"
					cIdTrabal := cIdTrab
				Else
					cIdTrabal := TAFGetIdFunc( FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab","C", .F., , .F.), cPeriodo, Nil, "cpfTrab", "/eSocial/evtRemun/ideTrabalhador/cpfTrab", aInfComp, fTafGetVal( "/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/matricula", "C", .F., @aIncons, .F. ), cIDCat,,"" )
				EndIf

			Else

				If (oDados:XPathHasNode(cPathPerApu + "/matricula")) .And. !Empty(FTafGetVal( cPathPerApu + "/matricula","C", .F., , .F.))
					cIdTrabal := FGetIdInt( "matricula", "", FTafGetVal(cPathPerApu + "/matricula","C", .F., , .F.), , .F.,,@cInconMsg, @nSeqErrGrv)
				ElseIf (oDados:XPathHasNode(cPathPerAnt + "/matricula")) .And. !Empty(FTafGetVal( cPathPerAnt + "/matricula","C", .F., , .F.))
					cIdTrabal := FGetIdInt( "matricula", "", FTafGetVal(cPathPerAnt + "/matricula","C", .F., , .F.), , .F.,,@cInconMsg, @nSeqErrGrv)
				ElseIf !Empty(cIdTrab) .AND. cNomEvC9V == "TAUTO"
					cIdTrabal := cIdTrab
				Else
					cIdTrabal := TAFGetIdFunc( FTafGetVal( "/eSocial/evtRemun/ideTrabalhador/cpfTrab","C", .F., , .F.), cPeriodo, Nil, "cpfTrab", "/eSocial/evtRemun/ideTrabalhador/cpfTrab", aInfComp, fTafGetVal( "/eSocial/evtRemun/dmDev/infoPerApur/ideEstabLot/remunPerApur/matricula", "C", .F., @aIncons, .F. ), cIDCat )
				EndIf

			EndIf

			Aadd( aRull, {"C91_TRABAL", cIdTrabal, "C", .T. } )

			If !Empty( cIdTrabal )
				lFindTrab := .T.
			EndIf

		EndIf
	Else

		If lInfoCompl

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab" ) )
				Aadd( aRull, {"C91_NOME", "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab","C",.F.} )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/dtNascto" ) )
				Aadd( aRull, {"C91_NASCTO", "/eSocial/evtRemun/ideTrabalhador/infoComplem/dtNascto","D",.F.} )
			EndIf

			If !lLaySimplif

				If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt" ) )
					Aadd( aRull, {"C91_TPINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInscAnt","C",.F.} )
				EndIf

				If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt" ) )
					Aadd( aRull, {"C91_CNPJEA", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/cnpjEmpregAnt","C",.F.} )
				EndIf

			Else

				If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInsc" ) )
					Aadd( aRull, {"C91_TPINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/tpInsc","C",.F.} )
				EndIf

				If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/nrInsc" ) )
					Aadd( aRull, {"C91_NRINSC", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/nrInsc","C",.F.} )
				EndIf

			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt" ) )
				Aadd( aRull, {"C91_MATREA", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt","C",.F.} )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm" ) )
				Aadd( aRull, {"C91_DTINVI", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/dtAdm","D",.F.} )
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao" ) )
				Aadd( aRull, {"C91_OBSVIN", "/eSocial/evtRemun/ideTrabalhador/infoComplem/sucessaoVinc/observacao","C",.F.} )
			EndIf
		
		Else
			
			// Caso já tenha sido gerado um RPA para o trabalhador e for identificado que ele possui algum S-2200 ou S-2300, as informações abaixo serão zeradas.
			Aadd( aRull, {"C91_NOME"  , "","C",.T.} )
			Aadd( aRull, {"C91_NASCTO", "","D",.T.} )
			Aadd( aRull, {"C91_CNPJEA", "","C",.T.} )
			Aadd( aRull, {"C91_MATREA", "","C",.T.} )
			Aadd( aRull, {"C91_DTINVI", "","D",.T.} )
			Aadd( aRull, {"C91_OBSVIN", "","C",.T.} )

		EndIf

	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) )
		Aadd( aRull, {"C91_CPF", FTafGetVal("/eSocial/evtRemun/ideTrabalhador/cpfTrab", "C", .F.,, .F. ),"C",.T.} )
	EndIf

	If !lLaySimplif

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/nisTrab" ) )
			Aadd( aRull, {"C91_NIS", FTafGetVal("/eSocial/evtRemun/ideTrabalhador/nisTrab", "C", .F.,, .F. ),"C",.T.} )
		EndIf

	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideEvento/indApuracao" ) )
		Aadd( aRull, {"C91_INDAPU", "/eSocial/evtRemun/ideEvento/indApuracao","C",.F.} )
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoMV/indMV" ) )
		Aadd( aRull, {"C91_INDMVI", "/eSocial/evtRemun/ideTrabalhador/infoMV/indMV", "C", .F. } )
	EndIf

	If !lLaySimplif

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRemun/ideTrabalhador/infoInterm/qtdDiasInterm" ) )
			Aadd( aRull, {"C91_QTDINT", "/eSocial/evtRemun/ideTrabalhador/infoInterm/qtdDiasInterm", "C", .F.} )
		EndIf

	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Vitor Siqueira
@since 11/01/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local aAltRPT		as array
	Local aGrava       	as array
	Local aGravaT14    	as array
	Local aGravaC9L    	as array
	Local aGravaC9M    	as array
	Local aGravaT6Y    	as array
	Local aGravaT6Z    	as array
	Local aGravaC9O    	as array
	Local aGravaC9Q    	as array
	Local aGravaC9R    	as array
	Local aGravaCRN    	as array
	Local aGravaT6W    	as array
	Local aGravaC9K    	as array
	Local aGravaC9N    	as array
	Local aGravaC9P    	as array
	Local aGravaV1B    	as array
	Local aGravaV1C    	as array
	Local aGravaV6K    	as array
	Local aGravaV9K    	as array
	Local cLogOpeAnt   	as character
	Local cVerAnt      	as character
	Local cProtocolo   	as character
	Local cVersao      	as character
	Local cChvRegAnt   	as character
	Local cEvento      	as character
	Local cDmDv        	as character
	Local lRetorno     	as logical
	Local nlI          	as numeric
	Local nlY          	as numeric
	Local nC9O			as numeric
	Local nC9Q			as numeric
	Local nC9R			as numeric
	Local nT14			as numeric
	Local nC9L			as numeric
	Local nC9M			as numeric
	Local nT6Y			as numeric
	Local nT6Z			as numeric
	Local nC9P			as numeric
	Local nT6W			as numeric
	Local nC9N			as numeric
	Local nC9K			as numeric
	Local nV1B			as numeric
	Local nV1C			as numeric
	Local nV9K			as numeric
	Local nC9OAdd		as numeric
	Local nC9QAdd		as numeric
	Local nC9RAdd		as numeric
	Local nC9LAdd		as numeric
	Local nC9MAdd		as numeric
	Local nT6YAdd		as numeric
	Local nT6ZAdd		as numeric
	Local nC9PAdd		as numeric
	Local nC9KAdd		as numeric
	Local nV1BAdd		as numeric
	Local nV1CAdd		as numeric
	Local nV9KAdd		as numeric
	Local nOperation   	as numeric
	Local oModelC91    	as object
	Local oModelT14    	as object
	Local oModelC9L    	as object
	Local oModelC9M    	as object
	Local oModelT6Y    	as object
	Local oModelT6Z    	as object
	Local oModelC9O    	as object
	Local oModelC9Q    	as object
	Local oModelC9R    	as object
	Local oModelCRN    	as object
	Local oModelT6W    	as object
	Local oModelC9K    	as object
	Local oModelC9N    	as object
	Local oModelC9P    	as object
	Local oModelV1B    	as object
	Local oModelV1C    	as object
	Local oModelV6K    	as object
	Local oModelV9K    	as object

	//Relatório de Conferência de Valores
	Local cIndApu       as character
	Local cPeriodo      as character
	Local cCPF          as character
	Local cNome         as character
	Local lInfoRPT      as logical
	Local oInfoRPT      as object 

	aAltRPT			:= {}
	aGrava       	:= {}
	aGravaT14    	:= {}
	aGravaC9L    	:= {}
	aGravaC9M    	:= {}
	aGravaT6Y    	:= {}
	aGravaT6Z    	:= {}
	aGravaC9O    	:= {}
	aGravaC9Q    	:= {}
	aGravaC9R    	:= {}
	aGravaCRN    	:= {}
	aGravaT6W    	:= {}
	aGravaC9K    	:= {}
	aGravaC9N    	:= {}
	aGravaC9P    	:= {}
	aGravaV1B    	:= {}
	aGravaV1C    	:= {}
	aGravaV6K    	:= {}
	aGravaV9K    	:= {}
	cLogOpeAnt   	:= ""
	cVerAnt      	:= ""
	cProtocolo   	:= ""
	cVersao      	:= ""
	cChvRegAnt   	:= ""
	cEvento      	:= ""
	cDmDv        	:= ""	
	lRetorno     	:= .T.
	nlI          	:= 0
	nlY          	:= 0
	nC9O			:= 0
	nC9Q			:= 0
	nC9R			:= 0
	nT14			:= 0
	nC9L			:= 0
	nC9M			:= 0
	nT6Y			:= 0
	nT6Z			:= 0
	nC9P			:= 0
	nT6W			:= 0
	nC9N			:= 0
	nC9K			:= 0
	nV1B			:= 0
	nV1C			:= 0
	nV9K			:= 0
	nC9OAdd			:= 0
	nC9QAdd			:= 0
	nC9RAdd			:= 0
	nC9LAdd			:= 0
	nC9MAdd			:= 0
	nT6YAdd			:= 0
	nT6ZAdd			:= 0
	nC9PAdd			:= 0
	nC9KAdd			:= 0
	nV1BAdd			:= 0
	nV1CAdd			:= 0
	nV9KAdd			:= 0
	nOperation   	:= oModel:GetOperation()
	oModelC91    	:= Nil
	oModelT14    	:= Nil
	oModelC9L    	:= Nil
	oModelC9M    	:= Nil
	oModelT6Y    	:= Nil
	oModelT6Z    	:= Nil
	oModelC9O    	:= Nil
	oModelC9Q    	:= Nil
	oModelC9R    	:= Nil
	oModelCRN    	:= Nil
	oModelT6W    	:= Nil
	oModelC9K    	:= Nil
	oModelC9N    	:= Nil
	oModelC9P    	:= Nil
	oModelV1B    	:= Nil
	oModelV1C    	:= Nil
	oModelV6K    	:= Nil
	oModelV9K    	:= Nil

	//Relatório de Conferência de Valores
	cIndApu       := ""
	cPeriodo      := ""
	cCPF          := ""
	cNome         := ""
	lInfoRPT      := .F.
	oInfoRPT      := Nil

	Begin Transaction

		If __lGrvRPT == Nil
			TAF250Rpt() //Inicializa a variável static __lGrvRPT
		EndIf

		lInfoRPT := __lGrvRPT

		//Realiza a exclusão do registro da tabela do relatório
		If lInfoRPT

			cIndApu		:=	oModel:GetValue("MODEL_C91","C91_INDAPU")
			cPeriodo	:=	oModel:GetValue("MODEL_C91","C91_PERAPU")

			If oModel:GetValue("MODEL_C91","C91_MV") == "1" .Or. Empty( oModel:GetValue( "MODEL_C91", "C91_TRABAL" ) )
				cCPF := oModel:GetValue("MODEL_C91","C91_CPF")
				cNome := oModel:GetValue("MODEL_C91","C91_NOME")
			ElseIf TafColumnPos("C91_ORIEVE") .And. oModel:GetValue("MODEL_C91","C91_ORIEVE") == 'S2190'
				cCPF := GetADVFVal( "T3A", "T3A_CPF", xFilial( "T3A" ) + oModel:GetValue("MODEL_C91","C91_TRABAL") + "1", 3, "", .T. )
			Else
				cCPF := GetADVFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + oModel:GetValue("MODEL_C91","C91_TRABAL") + "1", 2, "", .T. )
				cNome := GetADVFVal( "C9V", "C9V_NOME", xFilial( "C9V" ) + oModel:GetValue("MODEL_C91","C91_TRABAL") + "1", 2, "", .T. )
			EndIf

			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

		EndIf

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_C91", "C91_VERSAO", xFunGetVer() )
			oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1200" )
			oModel:LoadValue( "MODEL_C91", "C91_CPF", cCPF )

			If Empty( oModel:GetValue( "MODEL_C91", "C91_TRABAL" ) )
				oModel:LoadValue( "MODEL_C91", "C91_MV", "1" )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '2', '' )
			Endif
			
			oModelT6W := oModel:GetModel( "MODEL_T6W" )

			For nT6W := 1 to oModelT6W:Length()

				oModelT6W:GoLine( nT6W )

				If !oModelT6W:IsEmpty() .and. !oModelT6W:IsDeleted()
					oModelT6W:LoadValue( "T6W_NOMEVE", "S1200" )
				EndIf

			Next nT6W

			If !lLaySimplif

				oModelT6Y := oModel:GetModel( "MODEL_T6Y" )

				For nT6Y := 1 to oModelT6Y:Length()

					oModelT6Y:GoLine( nT6Y )

					If !oModelT6Y:IsEmpty() .and. !oModelT6Y:IsDeleted()
						oModelT6Y:LoadValue( "T6Y_NOMEVE", "S1200" )
					EndIf

				Next nT6Y

				oModelT6Z := oModel:GetModel( "MODEL_T6Z" )

				For nT6Z := 1 to oModelT6Z:Length()

					oModelT6Z:GoLine( nT6Z )

					If !oModelT6Z:IsEmpty() .and. !oModelT6Z:IsDeleted()
						oModelT6Z:LoadValue( "T6Z_NOMEVE", "S1200" )
					EndIf

				Next nT6Z

			EndIf

			If FWFormCommit(oModel)
				If lInfoRPT
					aAnalitico := LoadReportData(oModel, lInfoRPT)
					
					InfoRPTObj(cIndApu, cPeriodo, cCPF, cNome, aAnalitico,, @oInfoRPT)

					oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT)
				EndIf
			EndIf

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C91->( DbSetOrder( 3 ) )
			If C91->( MsSeek( xFilial( 'C91' ) + M->C91_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C91->C91_STATUS $ ( "4" )

					oModelC91 := oModel:GetModel( 'MODEL_C91' )
					oModelT6W := oModel:GetModel( 'MODEL_T6W' )
					oModelT14 := oModel:GetModel( 'MODEL_T14' )
					oModelC9K := oModel:GetModel( 'MODEL_C9K' )
					oModelC9L := oModel:GetModel( 'MODEL_C9L' )
					oModelC9M := oModel:GetModel( 'MODEL_C9M' )

					If !lLaySimplif
						oModelT6Y := oModel:GetModel( 'MODEL_T6Y' )
						oModelT6Z := oModel:GetModel( 'MODEL_T6Z' )
						oModelV1B := oModel:GetModel( 'MODEL_V1B' )
						oModelV1C := oModel:GetModel( 'MODEL_V1C' )
					EndIf

					oModelC9N := oModel:GetModel( 'MODEL_C9N' )
					oModelC9O := oModel:GetModel( 'MODEL_C9O' )
					oModelC9P := oModel:GetModel( 'MODEL_C9P' )
					oModelC9Q := oModel:GetModel( 'MODEL_C9Q' )
					oModelC9R := oModel:GetModel( 'MODEL_C9R' )
					oModelCRN := oModel:GetModel( 'MODEL_CRN' )

					If lLaySimplif					
						oModelV6K := oModel:GetModel( 'MODEL_V6K' )					
					EndIf

					If lSimplBeta .And. TafColumnPos("T14_INDRRA")
						oModelV9K := oModel:GetModel( 'MODEL_V9K' )	
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt	 	 := oModelC91:GetValue( "C91_VERSAO" )
					cProtocolo	 := oModelC91:GetValue( "C91_PROTUL" )
					cEvento 	 := oModelC91:GetValue( "C91_EVENTO" )

					If TafColumnPos( "C91_LOGOPE" )
						cLogOpeAnt := oModelC91:GetValue( "C91_LOGOPE" )
					EndIf

					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1

						For nlY := 1 To Len( oModelC91:aDataModel[ nlI ] )
							Aadd( aGrava, { oModelC91:aDataModel[ nlI, nlY, 1 ], oModelC91:aDataModel[ nlI, nlY, 2 ] } )
						Next

					Next

					//Posicionando no registro
					DBSelectArea("T14")
					DBSetOrder(1)
					/*------------------------------------------
						T14 - Informações do Recibo de Pag.
					--------------------------------------------*/
					If T14->(MsSeek(xFilial("T14")+C91->(C91_ID + C91_VERSAO) ) )

						For nT14 := 1 To oModel:GetModel( 'MODEL_T14' ):Length()
							oModel:GetModel( 'MODEL_T14' ):GoLine(nT14)

							If !oModel:GetModel( 'MODEL_T14' ):IsDeleted()	

								If lSimplBeta .And. TafColumnPos("T14_INDRRA")

									aAdd (aGravaT14 ,{oModelT14:GetValue('T14_IDEDMD'),;
													  oModelT14:GetValue('T14_CODCAT'),;
													  oModelT14:GetValue('T14_CODCBO'),;
													  oModelT14:GetValue('T14_NATATV'),;
													  oModelT14:GetValue('T14_QTDTRB'),;
													  oModelT14:GetValue('T14_INDRRA'),;
													  oModelT14:GetValue('T14_TPPRRA'),;
													  oModelT14:GetValue('T14_NRPRRA'),;
													  oModelT14:GetValue('T14_DESCRA'),;
													  oModelT14:GetValue('T14_QTMRRA'),;
													  oModelT14:GetValue('T14_VLRCUS'),;
													  oModelT14:GetValue('T14_VLRADV'),;
													 })

									/*------------------------------------------
										V9K - Informações de Valores Pagos
									--------------------------------------------*/
									For nV9K := 1 to oModel:GetModel( "MODEL_V9K" ):Length()

										oModel:GetModel( "MODEL_V9K" ):GoLine(nV9K)

										If !oModel:GetModel( 'MODEL_V9K' ):IsEmpty()

											If !oModel:GetModel( "MODEL_V9K" ):IsDeleted()

												aAdd (aGravaV9K ,{  oModelT14:GetValue('T14_IDEDMD'),;
																	oModelV9K:GetValue('V9K_TPINSC'),;
																	oModelV9K:GetValue('V9K_NRINSC'),;
																	oModelV9K:GetValue('V9K_VLRADV')})
											EndIf

										EndIf

									Next //nV9K	

								Else

									aAdd (aGravaT14 ,{oModelT14:GetValue('T14_IDEDMD'),;
													  oModelT14:GetValue('T14_CODCAT'),;
													  oModelT14:GetValue('T14_CODCBO'),;
													  oModelT14:GetValue('T14_NATATV'),;
													  oModelT14:GetValue('T14_QTDTRB')})

								EndIf

								/*------------------------------------------
									C9K - Informações do Estab/Lotação
								--------------------------------------------*/
								For nC9K := 1 to oModel:GetModel( "MODEL_C9K" ):Length()

									oModel:GetModel( "MODEL_C9K" ):GoLine(nC9K)

									If !oModel:GetModel( 'MODEL_C9K' ):IsEmpty()

										If !oModel:GetModel( "MODEL_C9K" ):IsDeleted()

											aAdd (aGravaC9K ,{	oModelT14:GetValue('T14_IDEDMD'),;
																oModelC9K:GetValue('C9K_ESTABE'),;
																oModelC9K:GetValue('C9K_LOTACA'),;
																oModelC9K:GetValue('C9K_QTDDIA'),;
																oModelC9K:GetValue('C9K_TPINSC'),;
																oModelC9K:GetValue('C9K_NRINSC'),;
																oModelC9K:GetValue('C9K_CODLOT');
																})

											/*------------------------------------------
												C9L - Informações da Remuneração Trab.
											--------------------------------------------*/
											For nC9L := 1 to oModel:GetModel( "MODEL_C9L" ):Length()

												oModel:GetModel( "MODEL_C9L" ):GoLine(nC9L)

												If !oModel:GetModel( 'MODEL_C9L' ):IsEmpty()

													If !oModel:GetModel( "MODEL_C9L" ):IsDeleted()

														aAdd (aGravaC9L ,{	oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC'),;
																			oModelC9L:GetValue('C9L_TRABAL'),;
																			oModelC9L:GetValue('C9L_GRAEXP'),;
																			oModelC9L:GetValue('C9L_INDCON'),;
																			oModelC9L:GetValue('C9L_DTRABA');
																			})

														/*------------------------------------------
															C9M - Itens da Remuneração Trab.
														--------------------------------------------*/
														For nC9M := 1 to oModel:GetModel( "MODEL_C9M" ):Length()

															oModel:GetModel( "MODEL_C9M" ):GoLine(nC9M)

															If !oModel:GetModel( 'MODEL_C9M' ):IsEmpty()

																If !oModel:GetModel( "MODEL_C9M" ):IsDeleted()

																	If lLaySimplif

																		aAdd (aGravaC9M ,{	oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC')+oModelC9L:GetValue('C9L_TRABAL'),;
																							oModelC9M:GetValue('C9M_CODRUB'),;
																							oModelC9M:GetValue('C9M_QTDRUB'),;
																							oModelC9M:GetValue('C9M_VLRUNT'),;
																							oModelC9M:GetValue('C9M_FATORR'),;
																							oModelC9M:GetValue('C9M_VLRRUB'),;
																							oModelC9M:GetValue('C9M_RUBRIC'),;
																							oModelC9M:GetValue('C9M_IDTABR'),;
																							oModelC9M:GetValue('C9M_APURIR');
																						})

																	Else

																		aAdd (aGravaC9M ,{	oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC')+oModelC9L:GetValue('C9L_TRABAL'),;
																							oModelC9M:GetValue('C9M_CODRUB'),;
																							oModelC9M:GetValue('C9M_QTDRUB'),;
																							oModelC9M:GetValue('C9M_VLRUNT'),;
																							oModelC9M:GetValue('C9M_FATORR'),;
																							oModelC9M:GetValue('C9M_VLRRUB'),;
																							oModelC9M:GetValue('C9M_RUBRIC'),;
																							oModelC9M:GetValue('C9M_IDTABR');
																						})	

																	EndIf 	

																EndIf

															EndIf

														Next //nC9M

														If !lLaySimplif

															/*------------------------------------------
																T6Y - Informações de Valores Pagos
															--------------------------------------------*/
															For nT6Y := 1 to oModel:GetModel( "MODEL_T6Y" ):Length()

																oModel:GetModel( "MODEL_T6Y" ):GoLine(nT6Y)

																If !oModel:GetModel( 'MODEL_T6Y' ):IsEmpty()

																	If !oModel:GetModel( "MODEL_T6Y" ):IsDeleted()

																		aAdd (aGravaT6Y ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																							oModelT6Y:GetValue('T6Y_CNPJOP'),;
																							oModelT6Y:GetValue('T6Y_REGANS'),;
																							oModelT6Y:GetValue('T6Y_VLPGTI')})
		
																		/*------------------------------------------
																			T6Z - Informações dos Dependentes
																		--------------------------------------------*/
																		For nT6Z := 1 to oModel:GetModel( "MODEL_T6Z" ):Length()

																			oModel:GetModel( "MODEL_T6Z" ):GoLine(nT6Z)

																			If !oModel:GetModel( 'MODEL_T6Z' ):IsEmpty()

																				If !oModel:GetModel( "MODEL_T6Z" ):IsDeleted()

																					aAdd (aGravaT6Z ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL')+oModelT6Y:GetValue('T6Y_CNPJOP')+oModelT6Y:GetValue('T6Y_REGANS'),;
																										oModelT6Z:GetValue('T6Z_SEQUEN'),;
																										oModelT6Z:GetValue('T6Z_TPDEP') ,;
																										oModelT6Z:GetValue('T6Z_CPFDEP'),;
																										oModelT6Z:GetValue('T6Z_NOMDEP'),;
																										oModelT6Z:GetValue('T6Z_DTNDEP'),;
																										oModelT6Z:GetValue('T6Z_VPGDEP')})
																				EndIf

																			EndIf

																		Next //nT6Z

																	EndIf

																EndIf

															Next //nT6Y	
															
															/*------------------------------------------
																V1B - Infos Trab Interm Per Apuração
															--------------------------------------------*/
															For nV1B := 1 to oModel:GetModel( "MODEL_V1B" ):Length()

																oModel:GetModel( "MODEL_V1B" ):GoLine(nV1B)

																If !oModel:GetModel( 'MODEL_V1B' ):IsEmpty()

																	If !oModel:GetModel( "MODEL_V1B" ):IsDeleted()
																		aAdd (aGravaV1B ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																			oModelV1B:GetValue('V1B_IDCONV')})
																	EndIf

																EndIf

															Next //nV1B

														EndIf

													EndIf
												EndIf
											Next //nC9L

										EndIf
									EndIf
								Next //nC9K

								/*------------------------------------------
									C9N - Informações de Acordo
								--------------------------------------------*/
								For nC9N := 1 To oModel:GetModel( 'MODEL_C9N' ):Length()

									oModel:GetModel( 'MODEL_C9N' ):GoLine(nC9N)

									If !oModel:GetModel( 'MODEL_C9N' ):IsEmpty()

										If !oModel:GetModel( 'MODEL_C9N' ):IsDeleted()

											If !lLaySimplif

												aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
																	oModelC9N:GetValue('C9N_TPACOR'),;
																	oModelC9N:GetValue('C9N_COMPAC'),;
																	oModelC9N:GetValue('C9N_DTEFAC'),;
																	oModelC9N:GetValue('C9N_DSC'   ),;
																	oModelC9N:GetValue('C9N_REMUNS'),;
																	oModelC9N:GetValue('C9N_RELACO'),;
																	oModelT14:GetValue('T14_IDEDMD')})
											Else

												aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
																	oModelC9N:GetValue('C9N_TPACOR'),;
																	oModelC9N:GetValue('C9N_DSC'   ),;
																	oModelC9N:GetValue('C9N_REMUNS'),;
																	oModelC9N:GetValue('C9N_RELACO'),;
																	oModelT14:GetValue('T14_IDEDMD')})

											EndIf

											/*------------------------------------
												C9O - Informações do Periodo
											-------------------------------------*/
											For nC9O := 1 to oModel:GetModel( "MODEL_C9O" ):Length()

												oModel:GetModel( "MODEL_C9O" ):GoLine(nC9O)

												If !oModel:GetModel( 'MODEL_C9O' ):IsEmpty()

													If !oModel:GetModel( "MODEL_C9O" ):IsDeleted()
													
														aAdd (aGravaC9O ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+DtoC(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR'),;
																		oModelC9O:GetValue('C9O_PERREF')})

														/*------------------------------------
														C9P - Informações do Estab/Lotação
														-------------------------------------*/
														For nC9P := 1 to oModel:GetModel( "MODEL_C9P" ):Length()

															oModel:GetModel( "MODEL_C9P" ):GoLine(nC9P)

															If !oModel:GetModel( 'MODEL_C9P' ):IsEmpty()

																If !oModel:GetModel( 'MODEL_C9P' ):IsDeleted()

																	aAdd (aGravaC9P ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF'),;
																					oModelC9P:GetValue('C9P_ESTABE'),;
																					oModelC9P:GetValue('C9P_LOTACA'),;
																					oModelC9P:GetValue('C9P_CODLOT'),;
																					oModelC9P:GetValue('C9P_TPINSC'),;
																					oModelC9P:GetValue('C9P_NRINSC')})

																	/*------------------------------------------
																		C9Q - Informações da Remuneração Trab.
																	--------------------------------------------*/
																	For nC9Q := 1 to oModel:GetModel( "MODEL_C9Q" ):Length()

																		oModel:GetModel( "MODEL_C9Q" ):GoLine(nC9Q)

																		If !oModel:GetModel( 'MODEL_C9Q' ):IsEmpty()

																			If !oModel:GetModel( "MODEL_C9Q" ):IsDeleted()

																				aAdd (aGravaC9Q ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA');
																								+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC'),;
																								oModelC9Q:GetValue('C9Q_TRABAL'),;
																								oModelC9Q:GetValue('C9Q_GRAEXP'),;
																								oModelC9Q:GetValue('C9Q_INDCON'),;
																								oModelC9Q:GetValue('C9Q_MATRIC'),;
																								oModelC9Q:GetValue('C9Q_DTRABA')})

																				/*------------------------------------------
																				C9R - Itens da Remuneração Trab.
																				--------------------------------------------*/
																				For nC9R := 1 to oModel:GetModel( "MODEL_C9R" ):Length()

																					oModel:GetModel( "MODEL_C9R" ):GoLine(nC9R)

																					If !oModel:GetModel( 'MODEL_C9R' ):IsEmpty()

																						If !oModel:GetModel( "MODEL_C9R" ):IsDeleted()

																							If !lLaySimplif

																								aAdd (aGravaC9R ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL');
																												+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC')+oModelC9Q:GetValue('C9Q_MATRIC'),;
																												oModelC9R:GetValue('C9R_CODRUB'),;
																												oModelC9R:GetValue('C9R_QTDRUB'),;
																												oModelC9R:GetValue('C9R_VLRUNT'),;
																												oModelC9R:GetValue('C9R_FATORR'),;																							
																												oModelC9R:GetValue('C9R_VLRRUB'),;
																												oModelC9R:GetValue('C9R_RUBRIC'),;
																												oModelC9R:GetValue('C9R_IDTABR')})

																								Else

																									aAdd (aGravaC9R ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL');
																												+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC')+oModelC9Q:GetValue('C9Q_MATRIC'),;
																												oModelC9R:GetValue('C9R_CODRUB'),;
																												oModelC9R:GetValue('C9R_QTDRUB'),;
																												oModelC9R:GetValue('C9R_FATORR'),;																							
																												oModelC9R:GetValue('C9R_VLRRUB'),;
																												oModelC9R:GetValue('C9R_APURIR'),;
																												oModelC9R:GetValue('C9R_RUBRIC'),;
																												oModelC9R:GetValue('C9R_IDTABR')})

																							EndIf

																						EndIf

																					EndIf

																				Next //nC9R

																				If !lLaySimplif

																					/*------------------------------------------
																						V1C - Infos Trab Interm Per Anterior
																						--------------------------------------------*/
																					For nV1C := 1 to oModel:GetModel( "MODEL_V1C" ):Length()

																						oModel:GetModel( "MODEL_V1C" ):GoLine(nV1C)

																						If !oModel:GetModel( 'MODEL_V1C' ):IsEmpty()

																							If !oModel:GetModel( "MODEL_V1C" ):IsDeleted()
																								aAdd (aGravaV1C ,{AllTrim(oModelT14:GetValue('T14_IDEDMD'))+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL'),;
																												oModelV1C:GetValue('V1C_IDCONV')})
																							EndIf

																						EndIf

																					Next //nV1C

																				EndIf

																			EndIf
																		EndIf
																	Next //nC9Q

																EndIf
															EndIf
														Next //nC9P

													EndIf
												EndIf
											Next //nC9O

										EndIf
									EndIf
								Next //nC9N

							EndIf
						Next //nT14
					EndIf

					For nlI := 1 To oModel:GetModel( 'MODEL_CRN' ):Length()

						oModel:GetModel( 'MODEL_CRN' ):GoLine(nlI)

						If !oModel:GetModel( 'MODEL_CRN' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_CRN' ):IsEmpty()
							aAdd (aGravaCRN,{	oModelCRN:GetValue('CRN_TPTRIB')	,;
								oModelCRN:GetValue('CRN_IDPROC')	,;
								oModelCRN:GetValue('CRN_IDSUSP')	})
						EndIf

					Next

					If lLaySimplif

						For nlI := 1 To oModel:GetModel( 'MODEL_V6K' ):Length()

							oModel:GetModel( 'MODEL_V6K' ):GoLine(nlI)

							If !oModel:GetModel( 'MODEL_V6K' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V6K' ):IsEmpty()
								aAdd (aGravaV6K,{	oModelV6K:GetValue('V6K_DIA')})
							EndIf

						Next

					EndIf 

					For nlI := 1 To oModel:GetModel( 'MODEL_T6W' ):Length()

						oModel:GetModel( 'MODEL_T6W' ):GoLine(nlI)

						If !oModel:GetModel( 'MODEL_T6W' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_T6W' ):IsEmpty()
							aAdd (aGravaT6W ,{	    oModelT6W:GetValue('T6W_TPINSC') ,;
								oModelT6W:GetValue('T6W_NRINSC') ,;
								oModelT6W:GetValue('T6W_CODCAT') ,;
								oModelT6W:GetValue('T6W_VLREMU')	})
						EndIf

					Next

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C91', '2' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_C91', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nlI := 1 To Len( aGravaT6W )

						oModel:GetModel( 'MODEL_T6W' ):LVALID	:= .T.

						If nlI > 1
							oModel:GetModel( 'MODEL_T6W' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T6W", "T6W_TPINSC",	aGravaT6W[nlI][1] )
						oModel:LoadValue( "MODEL_T6W", "T6W_NRINSC",	aGravaT6W[nlI][2] )
						oModel:LoadValue( "MODEL_T6W", "T6W_CODCAT",	aGravaT6W[nlI][3] )
						oModel:LoadValue( "MODEL_T6W", "T6W_VLREMU",	aGravaT6W[nlI][4] )
						oModel:LoadValue( "MODEL_T6W", "T6W_NOMEVE", "S1200")

					Next

					/*------------------------------------------
						T14 - Informações do Recibo de Pag.
					--------------------------------------------*/
					For nT14 := 1 to Len( aGravaT14 )

						oModel:GetModel( 'MODEL_T14' ):LVALID	:= .T.

						If nT14 > 1
							oModel:GetModel( "MODEL_T14" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T14", "T14_IDEDMD", aGravaT14[nT14][1] )
						oModel:LoadValue( "MODEL_T14", "T14_CODCAT", aGravaT14[nT14][2] )
						oModel:LoadValue( "MODEL_T14", "T14_CODCBO", aGravaT14[nT14][3] )
						oModel:LoadValue( "MODEL_T14", "T14_NATATV", aGravaT14[nT14][4] )
						oModel:LoadValue( "MODEL_T14", "T14_QTDTRB", aGravaT14[nT14][5] )

						If lSimplBeta .And. TafColumnPos("T14_INDRRA")

							oModel:LoadValue( "MODEL_T14", "T14_INDRRA", aGravaT14[nT14][6] )
							oModel:LoadValue( "MODEL_T14", "T14_TPPRRA", aGravaT14[nT14][7] )
							oModel:LoadValue( "MODEL_T14", "T14_NRPRRA", aGravaT14[nT14][8] )
							oModel:LoadValue( "MODEL_T14", "T14_DESCRA", aGravaT14[nT14][9] )
							oModel:LoadValue( "MODEL_T14", "T14_QTMRRA", aGravaT14[nT14][10] )
							oModel:LoadValue( "MODEL_T14", "T14_VLRCUS", aGravaT14[nT14][11] )
							oModel:LoadValue( "MODEL_T14", "T14_VLRADV", aGravaT14[nT14][12] )

							/*------------------------------------------
							V9K - Identificação dos advogados   
							--------------------------------------------*/
							nV9KAdd := 1
							For nV9K := 1 to Len( aGravaV9K )

								If  aGravaV9K[nV9K][1] == aGravaT14[nT14][1]

									oModel:GetModel( 'MODEL_V9K' ):LVALID := .T.

									If nV9KAdd > 1
										oModel:GetModel( "MODEL_V9K" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_V9K", "V9K_TPINSC", aGravaV9K[nV9K][2] )
									oModel:LoadValue( "MODEL_V9K", "V9K_NRINSC", aGravaV9K[nV9K][3] )
									oModel:LoadValue( "MODEL_V9K", "V9K_VLRADV", aGravaV9K[nV9K][4] )
								
									nV9KAdd++
								EndIf

							Next

						EndIf

						/*------------------------------------------
						C9K - Informações do Estab/Lotação
						--------------------------------------------*/
						nC9KAdd := 1
						For nC9K := 1 to Len( aGravaC9K )

							If  aGravaC9K[nC9K][1] == aGravaT14[nT14][1]

								oModel:GetModel( 'MODEL_C9K' ):LVALID := .T.

								If nC9KAdd > 1
									oModel:GetModel( "MODEL_C9K" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_C9K", "C9K_ESTABE", aGravaC9K[nC9K][2] )
								oModel:LoadValue( "MODEL_C9K", "C9K_LOTACA", aGravaC9K[nC9K][3] )
								oModel:LoadValue( "MODEL_C9K", "C9K_QTDDIA", aGravaC9K[nC9K][4] )

								oModel:LoadValue( "MODEL_C9K", "C9K_TPINSC", aGravaC9K[nC9K][5] )
								oModel:LoadValue( "MODEL_C9K", "C9K_NRINSC", aGravaC9K[nC9K][6] )
								oModel:LoadValue( "MODEL_C9K", "C9K_CODLOT", aGravaC9K[nC9K][7] )

								/*------------------------------------------
								C9L - Informações da Remuneração Trab.
								--------------------------------------------*/
								nC9LAdd := 1
								For nC9L := 1 to Len( aGravaC9L )

									If aGravaC9L[nC9L][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9K[nC9K][7]+aGravaC9K[nC9K][5]+aGravaC9K[nC9K][6])

										oModel:GetModel( 'MODEL_C9L' ):LVALID := .T.

										If nC9LAdd > 1
											oModel:GetModel( "MODEL_C9L" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_C9L", "C9L_TRABAL", aGravaC9L[nC9L][2] )
										oModel:LoadValue( "MODEL_C9L", "C9L_GRAEXP", aGravaC9L[nC9L][3] )
										oModel:LoadValue( "MODEL_C9L", "C9L_INDCON", aGravaC9L[nC9L][4] )
										oModel:LoadValue( "MODEL_C9L", "C9L_DTRABA", aGravaC9L[nC9L][5] )

										/*------------------------------------------
											C9M - Itens da Remuneração Trab.
										--------------------------------------------*/
										nC9MAdd := 1
										For nC9M := 1 to Len( aGravaC9M )

											If aGravaC9M[nC9M][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9K[nC9K][7]+aGravaC9K[nC9K][5]+aGravaC9K[nC9K][6]+aGravaC9L[nC9L][2])

												oModel:GetModel( 'MODEL_C9M' ):LVALID := .T.

												If nC9MAdd > 1
													oModel:GetModel( "MODEL_C9M" ):AddLine()
												EndIf

												oModel:LoadValue( "MODEL_C9M", "C9M_CODRUB",	aGravaC9M[nC9M][2] )
												oModel:LoadValue( "MODEL_C9M", "C9M_QTDRUB",	aGravaC9M[nC9M][3] )
												oModel:LoadValue( "MODEL_C9M", "C9M_VLRUNT",	aGravaC9M[nC9M][4] )
												oModel:LoadValue( "MODEL_C9M", "C9M_FATORR",	aGravaC9M[nC9M][5] )
												oModel:LoadValue( "MODEL_C9M", "C9M_VLRRUB",	aGravaC9M[nC9M][6] )

												oModel:LoadValue( "MODEL_C9M", "C9M_RUBRIC",	aGravaC9M[nC9M][7] )
												oModel:LoadValue( "MODEL_C9M", "C9M_IDTABR",	aGravaC9M[nC9M][8] )

												If lLaySimplif
													oModel:LoadValue( "MODEL_C9M", "C9M_APURIR",	aGravaC9M[nC9M][9] )
												EndIf

												nC9MAdd++

											EndIf

										Next //nC9M

										If !lLaySimplif
											/*------------------------------------------
												T6Y - Informações de Valores Pagos
											--------------------------------------------*/
											nT6YAdd := 1
											For nT6Y := 1 to Len( aGravaT6Y )

												If aGravaT6Y[nT6Y][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2])

													oModel:GetModel( 'MODEL_T6Y' ):LVALID := .T.

													If nT6YAdd > 1
														oModel:GetModel( "MODEL_T6Y" ):AddLine()
													EndIf

													oModel:LoadValue( "MODEL_T6Y", "T6Y_CNPJOP",	aGravaT6Y[nT6Y][2] )
													oModel:LoadValue( "MODEL_T6Y", "T6Y_REGANS",	aGravaT6Y[nT6Y][3] )
													oModel:LoadValue( "MODEL_T6Y", "T6Y_VLPGTI",	aGravaT6Y[nT6Y][4] )
													oModel:LoadValue( "MODEL_T6Y", "T6Y_NOMEVE", "S1200")

													/*------------------------------------------
														T6Z - Informações dos Dependentes
													--------------------------------------------*/
													nT6ZAdd := 1
													For nT6Z := 1 to Len( aGravaT6Z )

														If aGravaT6Z[nT6Z][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2]+aGravaT6Y[nT6Y][2]+aGravaT6Y[nT6Y][3])
															
															oModel:GetModel( 'MODEL_T6Z' ):LVALID := .T.

															If nT6ZAdd > 1
																oModel:GetModel( "MODEL_T6Z" ):AddLine()
															EndIf

															oModel:LoadValue( "MODEL_T6Z", "T6Z_SEQUEN",	aGravaT6Z[nT6Z][2] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_TPDEP" ,	aGravaT6Z[nT6Z][3] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_CPFDEP",	aGravaT6Z[nT6Z][4] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMDEP",	aGravaT6Z[nT6Z][5] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_DTNDEP",	aGravaT6Z[nT6Z][6] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_VPGDEP",	aGravaT6Z[nT6Z][7] )
															oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMEVE",	"S1200" )

															nT6ZAdd++

														EndIf

													Next //nT6Z

													nT6YAdd++

												EndIf

											Next //nT6Y

											/*------------------------------------------
												V1B - Infos Trab Interm Per Apuração
											--------------------------------------------*/
											nV1BAdd := 1
											For nV1B := 1 to Len( aGravaV1B )

												If aGravaV1B[nV1B][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2])

													oModel:GetModel( 'MODEL_V1B' ):LVALID := .T.

													If nV1BAdd > 1
														oModel:GetModel( "MODEL_V1B" ):AddLine()
													EndIf

													oModel:LoadValue( "MODEL_V1B", "V1B_CODCON",	aGravaV1B[nV1B][2] )
													nV1BAdd++

												EndIf

											Next //nV1B

										EndIf

										nC9LAdd++

									EndIf

								Next //nC9L

								nC9KAdd++

							EndIf

						Next //nC9K

						/*------------------------------------------
							C9N - Informações de Acordo
						--------------------------------------------*/
						For nC9N := 1 to Len( aGravaC9N )

							cDmDv := Iif(lLaySimplif,aGravaC9N[nC9N][6],aGravaC9N[nC9N][8])

							If  cDmDv == aGravaT14[nT14][1]

								oModel:GetModel( 'MODEL_C9N' ):LVALID	:= .T.

								If nC9N > 1
									oModel:GetModel( "MODEL_C9N" ):AddLine()
								EndIf

								If !lLaySimplif

									oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
									oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
									oModel:LoadValue( "MODEL_C9N", "C9N_COMPAC",	aGravaC9N[nC9N][3] )
									oModel:LoadValue( "MODEL_C9N", "C9N_DTEFAC",	aGravaC9N[nC9N][4] )
									oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][5] )
									oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][6] )

									If TafColumnPos( "C9N_RELACO" )
										oModel:LoadValue( "MODEL_C9N", "C9N_RELACO",	aGravaC9N[nC9N][7] )
									EndIf

								Else

									oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
									oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
									oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][3] )
									oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][4] )

								EndIf

								nC9OAdd := 1
								For nC9O := 1 to Len( aGravaC9O )

									If  aGravaC9O[nC9O][1] == AllTrim(aGravaT14[nT14][1]) + (DtoC(aGravaC9N[nC9N][1]) + aGravaC9N[nC9N][2])

										oModel:GetModel( 'MODEL_C9O' ):LVALID := .T.

										If nC9OAdd > 1
											oModel:GetModel( "MODEL_C9O" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_C9O", "C9O_PERREF", aGravaC9O[nC9O][2] )

										/*------------------------------------------
										C9P - Informações do Estab/Lotação
										--------------------------------------------*/
										nC9PAdd := 1
										For nC9P := 1 to Len( aGravaC9P )

											If aGravaC9P[nC9P][1] == AllTrim(aGravaT14[nT14][1]) + (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2])

												oModel:GetModel( 'MODEL_C9P' ):LVALID := .T.

												If nC9PAdd > 1
													oModel:GetModel( "MODEL_C9P" ):AddLine()
												EndIf

												oModel:LoadValue( "MODEL_C9P", "C9P_ESTABE",	aGravaC9P[nC9P][2] )
												oModel:LoadValue( "MODEL_C9P", "C9P_LOTACA",	aGravaC9P[nC9P][3] )
												oModel:LoadValue( "MODEL_C9P", "C9P_CODLOT",	aGravaC9P[nC9P][4] )
												oModel:LoadValue( "MODEL_C9P", "C9P_TPINSC",	aGravaC9P[nC9P][5] )
												oModel:LoadValue( "MODEL_C9P", "C9P_NRINSC",	aGravaC9P[nC9P][6] )

												/*------------------------------------------
												C9Q - Informações da Remuneração Trab.
												--------------------------------------------*/
												nC9QAdd := 1
												For nC9Q := 1 to Len( aGravaC9Q )

													If  aGravaC9Q[nC9Q][1] == AllTrim(aGravaT14[nT14][1]) + (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9P[nC9P][4]+aGravaC9P[nC9P][5]+aGravaC9P[nC9P][6])
														
														oModel:GetModel( 'MODEL_C9Q' ):LVALID := .T.

														If nC9QAdd > 1
															oModel:GetModel( "MODEL_C9Q" ):AddLine()
														EndIf

														oModel:LoadValue( "MODEL_C9Q", "C9Q_TRABAL",	aGravaC9Q[nC9Q][2] )
														oModel:LoadValue( "MODEL_C9Q", "C9Q_GRAEXP",	aGravaC9Q[nC9Q][3] )
														oModel:LoadValue( "MODEL_C9Q", "C9Q_INDCON",    aGravaC9Q[nC9Q][4] )
														oModel:LoadValue( "MODEL_C9Q", "C9Q_MATRIC",    aGravaC9Q[nC9Q][5] )
														oModel:LoadValue( "MODEL_C9Q", "C9Q_DTRABA",    aGravaC9Q[nC9Q][6] )
														
														/*------------------------------------------
															C9R - Itens da Remuneração Trab.
														--------------------------------------------*/
														nC9RAdd := 1
														For nC9R := 1 to Len( aGravaC9R )

															If  aGravaC9R[nC9R][1] == AllTrim(aGravaT14[nT14][1]) + (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2]+aGravaC9P[nC9P][4]+aGravaC9P[nC9P][5]+aGravaC9P[nC9P][6]+aGravaC9Q[nC9Q][5])
																
																oModel:GetModel( 'MODEL_C9R' ):LVALID := .T.

																If nC9RAdd > 1
																	oModel:GetModel( "MODEL_C9R" ):AddLine()
																EndIf

																If !lLaySimplif
																	oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_VLRUNT",	aGravaC9R[nC9R][4] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][5] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][6] )
																Else
																	oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][4] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][5] )
																	oModel:LoadValue( "MODEL_C9R", "C9R_APURIR",	aGravaC9R[nC9R][6] )
																EndIf

																oModel:LoadValue( "MODEL_C9R", "C9R_RUBRIC",	aGravaC9R[nC9R][7] )
																oModel:LoadValue( "MODEL_C9R", "C9R_IDTABR",	aGravaC9R[nC9R][8] )
														
																nC9RAdd++

															EndIf
														Next //nC9R

														If !lLaySimplif
															/*------------------------------------------
																V1C - Infos Trab Interm Per Anterior
															--------------------------------------------*/
															nV1CAdd := 1
															For nV1C := 1 to Len( aGravaV1C )

																If  aGravaV1C[nV1C][1] == AllTrim(aGravaT14[nT14][1]) + (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2])
																	
																	oModel:GetModel( 'MODEL_V1C' ):LVALID := .T.

																	If nV1CAdd > 1
																		oModel:GetModel( "MODEL_V1C" ):AddLine()
																	EndIf

																	oModel:LoadValue( "MODEL_V1C", "V1C_IDCONV",	aGravaV1C[nV1C][2] )

																	nV1CAdd++

																EndIf

															Next //nV1C

														EndIf

														nC9QAdd++

													EndIf

												Next //nC9Q

											EndIf
										Next //nC9P

										nC9OAdd++

									EndIf
								Next //nC9O

							EndIf
						Next //nC9N
				

					Next //nT14

					For nlI := 1 To Len( aGravaCRN )

						oModel:GetModel( 'MODEL_CRN' ):LVALID	:= .T.

						If nlI > 1
							oModel:GetModel( 'MODEL_CRN' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_CRN", "CRN_TPTRIB" ,	aGravaCRN[nlI][1] )
						oModel:LoadValue( "MODEL_CRN", "CRN_IDPROC" ,	aGravaCRN[nlI][2] )
						oModel:LoadValue( "MODEL_CRN", "CRN_IDSUSP" ,	aGravaCRN[nlI][3] )

					Next

					If lLaySimplif

						For nlI := 1 To Len( aGravaV6K )

							oModel:GetModel( 'MODEL_V6K' ):LVALID	:= .T.

							If nlI > 1
								oModel:GetModel( 'MODEL_V6K' ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V6K", "V6K_DIA" ,	aGravaV6K[nlI][1] )

						Next

					EndIf 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( 'MODEL_C91', 'C91_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_C91', 'C91_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_C91', 'C91_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_C91', 'C91_PROTUL', "" )
					oModel:LoadValue( 'MODEL_C91', 'C91_EVENTO', "A" )

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C91"

					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					aAltRPT := SaveAltRPT()

					If FWFormCommit(oModel)
						If lInfoRPT
							If !Empty(aAltRPT)
								InfoRPTObj(aAltRPT[1], aAltRPT[2], aAltRPT[3], aAltRPT[4],,, @oInfoRPT)

								oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT, .T.)

								aAltRPT := {}
							EndIf

							aAnalitico := LoadReportData(oModel, lInfoRPT)

							InfoRPTObj(cIndApu, cPeriodo, cCPF, cNome, aAnalitico,, @oInfoRPT)

							oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT)
						EndIf
					EndIf

					TAFAltStat( 'C91', " " )

				ElseIf C91->C91_STATUS == ( "2" )

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.

				ElseIf C91->C91_STATUS == ( "6" )

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno := .F.

				ElseIf C91->C91_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.

				Else

					oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1200" )

					If TafColumnPos( "C91_LOGOPE" )
						cLogOpeAnt := C91->C91_LOGOPE
					EndIf

					oModelT6W := oModel:GetModel( "MODEL_T6W" )

					For nT6W := 1 to oModelT6W:Length()

						oModelT6W:GoLine( nT6W )

						If !oModelT6W:IsEmpty() .and. !oModelT6W:IsDeleted()
							oModelT6W:LoadValue( "T6W_NOMEVE", "S1200" )
						EndIf

					Next nT6W

					If !lLaySimplif

						oModelT6Y := oModel:GetModel( "MODEL_T6Y" )

						For nT6Y := 1 to oModelT6Y:Length()

							oModelT6Y:GoLine( nT6Y )

							If !oModelT6Y:IsEmpty() .and. !oModelT6Y:IsDeleted()
								oModelT6Y:LoadValue( "T6Y_NOMEVE", "S1200" )
							EndIf

						Next nT6Y

						oModelT6Z := oModel:GetModel( "MODEL_T6Z" )

						For nT6Z := 1 to oModelT6Z:Length()

							oModelT6Z:GoLine( nT6Z )

							If !oModelT6Z:IsEmpty() .and. !oModelT6Z:IsDeleted()
								oModelT6Z:LoadValue( "T6Z_NOMEVE", "S1200" )
							EndIf

						Next nT6Z

					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					aAltRPT := SaveAltRPT()

					If FWFormCommit(oModel)
						If lInfoRPT
							If !Empty(aAltRPT)
								InfoRPTObj(aAltRPT[1], aAltRPT[2], aAltRPT[3], aAltRPT[4],,, @oInfoRPT)
								
								oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT, .T.)

								aAltRPT	:= {}
							EndIf

							aAnalitico := LoadReportData(oModel, lInfoRPT)

							InfoRPTObj(cIndApu, cPeriodo, cCPF, cNome, aAnalitico,, @oInfoRPT)

							oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT)
						EndIf
					EndIf
					
					TAFAltStat( "C91", " " )
					
				EndIf

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := C91->(C91_ID + C91_VERANT)

			TAFAltStat( 'C91', " " )

			If FwFormCommit(oModel)
				If lInfoRPT
					InfoRPTObj(cIndApu, cPeriodo, cCPF, cNome,,, @oInfoRPT)

					oReport:UpSert("S-1200", "2", xFilial("C91"), oInfoRPT, .T.)
				EndIf
			EndIf

			If C91->C91_EVENTO == "A" .Or. C91->C91_EVENTO == "E"
				TAFRastro( 'C91', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
			
		EndIf

	End Transaction

	If !lRetorno
		// Define a mensagem de erro que será exibida após o Return do SaveModel
		TAFMsgDel(oModel,.T.)
	EndIf

	If lRetorno .and. FWIsInCallStack( "TAF250AUTI" )

		//Executa atualização dos registros que são elegí­veis para autônomos do S-1200 
		FwMsgRun(, { || AtuRegC91() }, "Atualizando Registros S-1200 Autônomos...", "Aguarde") 	//"Atualizando Registros S-1200 Autônomos.."

	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} xFunRecibo
Esta função tem por finalidade, retornar o numero do recibo de desligamento
do trabalhador empregado ou do evento de término de contrato no caso do
Diretor Não Empregado com FGTS, para o autopreenchimento da tag nrReciboDeslig,
no caso da geração do XML, ou o campo C9L_NRECDE no caso de Integração.

@Param  aRecibo -> Array contendo as seguintes informacoes:

aRecibo[1][1] - Filial da tabela C9V
aRecibo[1][2] - Id da tabela C9V
aRecibo[1][3] - Versao da tabela C9V
aRecibo[1][4] - Matricula do funcionario

@Return .T.

@author Vitor Siqueira
@since 08/01/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xFunRecibo(aRecibo)

	Local cMatricula := ""

	CUP->(DBSetOrder(1))
	If CUP->(MsSeek(aRecibo[1][1]+aRecibo[1][2]+aRecibo[1][3]))

		If AllTrim(aRecibo[1][4]) == AllTrim(CUP->CUP_MATRIC)

			C87->(DBSetOrder(1))
			If C87->(MsSeek(xFilial("C87")+CUP->CUP_CODCAT))

				If C87->C87_CODIGO == "721"

					CRD->( DbSetOrder( 2 ) )
					If CRD->( MsSeek( xFilial("CRD")+aRecibo[1][2]))

						If CRD->CRD_STATUS $ ("2|3|4") .And. CRD->CRD_ATIVO == "1"
							cMatricula := CRD->CRD_PROTUL
						EndIf

					EndIf

				Else

					CMD->( DbSetOrder( 2 ) )
					If CMD->( MsSeek( xFilial("CMD")+aRecibo[1][2]))

						If CMD->CMD_STATUS $ ("2|3|4") .And. CMD->CMD_ATIVO == "1"
							cMatricula := CMD->CMD_PROTUL
						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

Return(cMatricula)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 11/01/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt       as character
	Local cProtocolo    as character
	Local cVersao       as character
	Local cEvento       as character
	Local cDmDv         as character
	Local nlI           as numeric
	Local nlY           as numeric
	Local nC9O			as numeric 
	Local nC9OAdd 		as numeric
	Local nC9Q			as numeric 
	Local nC9QAdd 		as numeric
	Local nC9R			as numeric 
	Local nC9RAdd 		as numeric
	Local nT14          as numeric
	Local nC9L			as numeric 
	Local nC9LAdd 		as numeric
	Local nC9M			as numeric 
	Local nC9MAdd 		as numeric
	Local nT6Y			as numeric 
	Local nT6YAdd 		as numeric
	Local nT6Z			as numeric 
	Local nT6ZAdd 		as numeric
	Local nC9P			as numeric 
	Local nC9PAdd 		as numeric
	Local nC9N          as numeric
	Local nC9K			as numeric 
	Local nC9KAdd 		as numeric
	Local nV1B			as numeric 
	Local nV1BAdd 		as numeric
	Local nV1C			as numeric 
	Local nV1CAdd 		as numeric
	Local nV9K			as numeric
	Local lInfoRPT 		as logical
	Local aGrava        as array
	Local aGravaT14     as array
	Local aGravaC9L     as array
	Local aGravaC9M     as array
	Local aGravaT6Y     as array
	Local aGravaT6Z     as array
	Local aGravaC9O     as array
	Local aGravaC9Q     as array
	Local aGravaC9R     as array
	Local aGravaCRN     as array
	Local aGravaT6W     as array
	Local aGravaC9K     as array
	Local aGravaC9N     as array
	Local aGravaC9P     as array
	Local aGravaV1B     as array
	Local aGravaV1C     as array
	Local aGravaV6K     as array
	Local aGravaV9K     as array
	Local oModelC91     as object
	Local oModelT14     as object
	Local oModelC9L     as object
	Local oModelC9M     as object
	Local oModelT6Y     as object
	Local oModelT6Z     as object
	Local oModelC9O     as object
	Local oModelC9Q     as object
	Local oModelC9R     as object
	Local oModelCRN     as object
	Local oModelT6W     as object
	Local oModelC9K     as object
	Local oModelC9N     as object
	Local oModelC9P     as object
	Local oModelV1B     as object
	Local oModelV1C     as object
	Local oModelV9K     as object
	
	cVerAnt       := ""
	cProtocolo    := ""
	cVersao       := ""
	cEvento       := ""
	cDmDv         := ""
	nC9O		  := 0
	nC9Q		  := 0
	nC9R		  := 0
	nT14		  := 0
	nC9L		  := 0
	nC9M		  := 0
	nT6Y		  := 0
	nT6Z		  := 0
	nC9P		  := 0
	nC9N		  := 0
	nC9K		  := 0
	nV1B		  := 0
	nV1C		  := 0
	nlI           := 0
	nlY           := 0
	nC9OAdd		  := 0
	nC9QAdd		  := 0
	nC9RAdd		  := 0      
	nC9LAdd		  := 0
	nC9MAdd		  := 0
	nT6YAdd		  := 0
	nT6ZAdd		  := 0
	nC9PAdd		  := 0	
	nC9KAdd		  := 0
	nV1BAdd		  := 0
	nV1CAdd		  := 0
	lInfoRPT 	  := .F.
	aGrava        := {}
	aGravaT14     := {}
	aGravaC9L     := {}
	aGravaC9M     := {}
	aGravaT6Y     := {}
	aGravaT6Z     := {}
	aGravaC9O     := {}
	aGravaC9Q     := {}
	aGravaC9R     := {}
	aGravaCRN     := {}
	aGravaT6W     := {}
	aGravaC9K     := {}
	aGravaC9N     := {}
	aGravaC9P     := {}
	aGravaV1B     := {}
	aGravaV1C     := {}
	aGravaV6K     := {}
	aGravaV9K	  := {}
	oModelC91     := Nil
	oModelT14     := Nil
	oModelC9L     := Nil
	oModelC9M     := Nil
	oModelT6Y     := Nil
	oModelT6Z     := Nil
	oModelC9O     := Nil
	oModelC9Q     := Nil
	oModelC9R     := Nil
	oModelCRN     := Nil
	oModelT6W     := Nil
	oModelC9K     := Nil
	oModelC9N     := Nil
	oModelC9P     := Nil
	oModelV1B     := Nil
	oModelV1C     := Nil
	oModelV9K	  := Nil

	Begin Transaction

		//Posiciona o item
		("C91")->( DBGoTo( nRecno ) )

		oModelC91 := oModel:GetModel( 'MODEL_C91' )
		oModelT6W := oModel:GetModel( 'MODEL_T6W' )
		oModelT14 := oModel:GetModel( 'MODEL_T14' )
		oModelC9K := oModel:GetModel( 'MODEL_C9K' )
		oModelC9L := oModel:GetModel( 'MODEL_C9L' )
		oModelC9M := oModel:GetModel( 'MODEL_C9M' )
		
		If !lLaySimplif
			oModelT6Y := oModel:GetModel( 'MODEL_T6Y' )
			oModelT6Z := oModel:GetModel( 'MODEL_T6Z' )
			oModelV1B := oModel:GetModel( 'MODEL_V1B' )
			oModelV1C := oModel:GetModel( 'MODEL_V1C' )
		EndIf

		oModelC9N := oModel:GetModel( 'MODEL_C9N' )
		oModelC9O := oModel:GetModel( 'MODEL_C9O' )
		oModelC9P := oModel:GetModel( 'MODEL_C9P' )
		oModelC9Q := oModel:GetModel( 'MODEL_C9Q' )
		oModelC9R := oModel:GetModel( 'MODEL_C9R' )
		oModelCRN := oModel:GetModel( 'MODEL_CRN' )

		If lLaySimplif
			oModelV6K := oModel:GetModel( 'MODEL_V6K' )
		EndIf

		If lSimplBeta .And. TafColumnPos("T14_INDRRA")
			oModelV9K := oModel:GetModel( 'MODEL_V9K' )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt		:= oModelC91:GetValue("C91_VERSAO")
		cProtocolo	:= oModelC91:GetValue("C91_PROTUL")
		cEvento		:= oModelC91:GetValue("C91_EVENTO")

		If __lGrvRPT == Nil
			TAF250Rpt()
		EndIf

		lInfoRPT := __lGrvRPT

		If lInfoRPT
			cIndApu		:= oModelC91:GetValue("C91_INDAPU")
			cPeriodo	:= oModelC91:GetValue("C91_PERAPU")

			If oModelC91:GetValue("C91_MV") == "1" .Or. Empty(oModelC91:GetValue("C91_TRABAL"))
				cCPF	:= oModelC91:GetValue("C91_CPF") 
				cNome 	:= oModelC91:GetValue("C91_NOME")
			ElseIf TafColumnPos("C91_ORIEVE") .And. oModelC91:GetValue("C91_ORIEVE") == "S2190"
				cCPF := GetADVFVal("T3A", "T3A_CPF", xFilial("T3A") + oModelC91:GetValue("C91_TRABAL") + "1", 3, "", .T.)
			Else
				cCPF	:= GetADVFVal("C9V", "C9V_CPF", xFilial("C9V") + oModelC91:GetValue("C91_TRABAL") + "1", 2, "", .T.)
				cNome 	:= GetADVFVal("C9V", "C9V_NOME", xFilial("C9V") + oModelC91:GetValue("C91_TRABAL") + "1", 2, "", .T.)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1

			For nlY := 1 To Len( oModelC91:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelC91:aDataModel[ nlI, nlY, 1 ], oModelC91:aDataModel[ nlI, nlY, 2 ] } )
			Next

		Next

		//Posicionando no registro
		DBSelectArea("T14")
		DBSetOrder(1)
		/*------------------------------------------
			T14 - Informações do Recibo de Pag.
		--------------------------------------------*/
		If T14->(MsSeek(xFilial("T14")+C91->(C91_ID + C91_VERSAO) ) )

			For nT14 := 1 To oModel:GetModel( 'MODEL_T14' ):Length()

				oModel:GetModel( 'MODEL_T14' ):GoLine(nT14)

				If !oModel:GetModel( 'MODEL_T14' ):IsDeleted()

					If lSimplBeta .And. TafColumnPos("T14_INDRRA")

						aAdd (aGravaT14 ,{oModelT14:GetValue('T14_IDEDMD'),;
											oModelT14:GetValue('T14_CODCAT'),;
											oModelT14:GetValue('T14_CODCBO'),;
											oModelT14:GetValue('T14_NATATV'),;
											oModelT14:GetValue('T14_QTDTRB'),;
											oModelT14:GetValue('T14_INDRRA'),;
											oModelT14:GetValue('T14_TPPRRA'),;
											oModelT14:GetValue('T14_NRPRRA'),;
											oModelT14:GetValue('T14_DESCRA'),;
											oModelT14:GetValue('T14_QTMRRA'),;
											oModelT14:GetValue('T14_VLRCUS'),;
											oModelT14:GetValue('T14_VLRADV'),;
											})

						/*------------------------------------------
							V9K - Informações de Valores Pagos
						--------------------------------------------*/
						For nV9K := 1 to oModel:GetModel( "MODEL_V9K" ):Length()

							oModel:GetModel( "MODEL_V9K" ):GoLine(nV9K)

							If !oModel:GetModel( 'MODEL_V9K' ):IsEmpty()

								If !oModel:GetModel( "MODEL_V9K" ):IsDeleted()

									aAdd (aGravaV9K ,{  oModelT14:GetValue('T14_IDEDMD'),;
														oModelV9K:GetValue('V9K_TPINSC'),;
														oModelV9K:GetValue('V9K_NRINSC'),;
														oModelV9K:GetValue('V9K_VLRADV')})
								EndIf

							EndIf

						Next //nV9K	

					Else

						aAdd (aGravaT14 ,{oModelT14:GetValue('T14_IDEDMD'),;
											oModelT14:GetValue('T14_CODCAT'),;
											oModelT14:GetValue('T14_CODCBO'),;
											oModelT14:GetValue('T14_NATATV'),;
											oModelT14:GetValue('T14_QTDTRB')})

					EndIf
					
					/*------------------------------------------
						C9K - Informações do Estab/Lotação
					--------------------------------------------*/
					For nC9K := 1 to oModel:GetModel( "MODEL_C9K" ):Length()

						oModel:GetModel( "MODEL_C9K" ):GoLine(nC9K)

						If !oModel:GetModel( 'MODEL_C9K' ):IsEmpty()

							If !oModel:GetModel( "MODEL_C9K" ):IsDeleted()

								aAdd (aGravaC9K ,{oModelT14:GetValue('T14_IDEDMD'),;
													oModelC9K:GetValue('C9K_ESTABE'),;
													oModelC9K:GetValue('C9K_LOTACA'),;
													oModelC9K:GetValue('C9K_QTDDIA'),;
													oModelC9K:GetValue('C9K_CODLOT'),;
													oModelC9K:GetValue('C9K_TPINSC'),;
													oModelC9K:GetValue('C9K_NRINSC') } )

								/*------------------------------------------
									C9L - Informações da Remuneração Trab.
								--------------------------------------------*/
								For nC9L := 1 to oModel:GetModel( "MODEL_C9L" ):Length()

									oModel:GetModel( "MODEL_C9L" ):GoLine(nC9L)

									If !oModel:GetModel( 'MODEL_C9L' ):IsEmpty()

										If !oModel:GetModel( "MODEL_C9L" ):IsDeleted()

											aAdd (aGravaC9L ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC'),;
																oModelC9L:GetValue('C9L_TRABAL'),;
																oModelC9L:GetValue('C9L_GRAEXP'),;
																oModelC9L:GetValue('C9L_INDCON'),;
																oModelC9L:GetValue('C9L_DTRABA') } )

											/*------------------------------------------
												C9M - Itens da Remuneração Trab.
											--------------------------------------------*/
											For nC9M := 1 to oModel:GetModel( "MODEL_C9M" ):Length()

												oModel:GetModel( "MODEL_C9M" ):GoLine(nC9M)

												If !oModel:GetModel( 'MODEL_C9M' ):IsEmpty()

													If !oModel:GetModel( "MODEL_C9M" ):IsDeleted()

														If lLaySimplif

															aAdd (aGravaC9M ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC')+oModelC9L:GetValue('C9L_TRABAL'),;
																			oModelC9M:GetValue('C9M_CODRUB'),;
																			oModelC9M:GetValue('C9M_QTDRUB'),;
																			oModelC9M:GetValue('C9M_VLRUNT'),;
																			oModelC9M:GetValue('C9M_FATORR'),;
																			oModelC9M:GetValue('C9M_VLRRUB'),;
																			oModelC9M:GetValue('C9M_RUBRIC'),;
																			oModelC9M:GetValue('C9M_IDTABR'),;
																			oModelC9M:GetValue('C9M_APURIR') } )

														Else

															aAdd (aGravaC9M ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9K:GetValue('C9K_CODLOT')+oModelC9K:GetValue('C9K_TPINSC')+oModelC9K:GetValue('C9K_NRINSC')+oModelC9L:GetValue('C9L_TRABAL'),;
																			oModelC9M:GetValue('C9M_CODRUB'),;
																			oModelC9M:GetValue('C9M_QTDRUB'),;
																			oModelC9M:GetValue('C9M_VLRUNT'),;
																			oModelC9M:GetValue('C9M_FATORR'),;
																			oModelC9M:GetValue('C9M_VLRRUB'),;
																			oModelC9M:GetValue('C9M_RUBRIC'),;
																			oModelC9M:GetValue('C9M_IDTABR') } )

														EndIf

													EndIf

												EndIf

											Next //nC9M

											If !lLaySimplif

												/*------------------------------------------
													T6Y - Informações de Valores Pagos
												--------------------------------------------*/
												For nT6Y := 1 to oModel:GetModel( "MODEL_T6Y" ):Length()

													oModel:GetModel( "MODEL_T6Y" ):GoLine(nT6Y)

													If !oModel:GetModel( 'MODEL_T6Y' ):IsEmpty()

														If !oModel:GetModel( "MODEL_T6Y" ):IsDeleted()

															aAdd (aGravaT6Y ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																				oModelT6Y:GetValue('T6Y_CNPJOP'),;
																				oModelT6Y:GetValue('T6Y_REGANS'),;
																				oModelT6Y:GetValue('T6Y_VLPGTI')})
		
															/*------------------------------------------
																T6Z - Informações dos Dependentes
															--------------------------------------------*/
															For nT6Z := 1 to oModel:GetModel( "MODEL_T6Z" ):Length()

																oModel:GetModel( "MODEL_T6Z" ):GoLine(nT6Z)

																If !oModel:GetModel( 'MODEL_T6Z' ):IsEmpty()

																	If !oModel:GetModel( "MODEL_T6Z" ):IsDeleted()

																		aAdd (aGravaT6Z ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL')+oModelT6Y:GetValue('T6Y_CNPJOP')+oModelT6Y:GetValue('T6Y_REGANS'),;
																							oModelT6Z:GetValue('T6Z_SEQUEN'),;
																							oModelT6Z:GetValue('T6Z_TPDEP') ,;
																							oModelT6Z:GetValue('T6Z_CPFDEP'),;
																							oModelT6Z:GetValue('T6Z_NOMDEP'),;
																							oModelT6Z:GetValue('T6Z_DTNDEP'),;
																							oModelT6Z:GetValue('T6Z_VPGDEP')})
				
																	EndIf
																EndIf
															Next //nT6Z

														EndIf
													EndIf
												Next //nT6Y

												/*------------------------------------------
													V1B - Infos Trab Interm Per Apuração
												--------------------------------------------*/
												For nV1B := 1 to oModel:GetModel( "MODEL_V1B" ):Length()

													oModel:GetModel( "MODEL_V1B" ):GoLine(nV1B)

													If !oModel:GetModel( 'MODEL_V1B' ):IsEmpty()

														If !oModel:GetModel( "MODEL_V1B" ):IsDeleted()
															aAdd (aGravaV1B ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																			oModelV1B:GetValue('V1B_IDCONV')})
														EndIf

													EndIf

												Next //nV1B

											EndIf

										EndIf
									EndIf
								Next //nC9L

							EndIf
						EndIf
					Next //nC9K

					/*------------------------------------------
						C9N - Informações de Acordo
					--------------------------------------------*/
					If C9N->(MsSeek(xFilial("C9N")+C91->(C91_ID + C91_VERSAO) ) )

						For nC9N := 1 To oModel:GetModel( 'MODEL_C9N' ):Length()

							oModel:GetModel( 'MODEL_C9N' ):GoLine(nC9N)

							If !oModel:GetModel( 'MODEL_C9N' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_C9N' ):IsEmpty()

								If !lLaySimplif

									aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
														oModelC9N:GetValue('C9N_TPACOR'),;
														oModelC9N:GetValue('C9N_COMPAC'),;
														oModelC9N:GetValue('C9N_DTEFAC'),;
														oModelC9N:GetValue('C9N_DSC'   ),;
														oModelC9N:GetValue('C9N_REMUNS'),;
														oModelT14:GetValue('T14_IDEDMD')})

								Else

									aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
														oModelC9N:GetValue('C9N_TPACOR'),;
														oModelC9N:GetValue('C9N_DSC'   ),;
														oModelC9N:GetValue('C9N_REMUNS'),;
														oModelT14:GetValue('T14_IDEDMD')})

								EndIf

								/*------------------------------------
									C9O - Informações do Periodo
								-------------------------------------*/
								For nC9O := 1 to oModel:GetModel( "MODEL_C9O" ):Length()

									oModel:GetModel( "MODEL_C9O" ):GoLine(nC9O)

									If !oModel:GetModel( 'MODEL_C9O' ):IsEmpty()

										If !oModel:GetModel( "MODEL_C9O" ):IsDeleted()

											aAdd (aGravaC9O ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR'),;
															oModelC9O:GetValue('C9O_PERREF')})

											/*------------------------------------
											C9P - Informações do Estab/Lotação
											-------------------------------------*/
											For nC9P := 1 to oModel:GetModel( "MODEL_C9P" ):Length()

												oModel:GetModel( "MODEL_C9P" ):GoLine(nC9P)

												If !oModel:GetModel( 'MODEL_C9P' ):IsEmpty()

													If !oModel:GetModel( 'MODEL_C9P' ):IsDeleted()

														aAdd (aGravaC9P ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF'),;
																			oModelC9P:GetValue('C9P_ESTABE'),;
																			oModelC9P:GetValue('C9P_LOTACA'),;
																			oModelC9P:GetValue('C9P_CODLOT'),;
																			oModelC9P:GetValue('C9P_TPINSC'),;
																			oModelC9P:GetValue('C9P_NRINSC')})

														/*------------------------------------------
															C9Q - Informações da Remuneração Trab.
														--------------------------------------------*/
														For nC9Q := 1 to oModel:GetModel( "MODEL_C9Q" ):Length()

															oModel:GetModel( "MODEL_C9Q" ):GoLine(nC9Q)

															If !oModel:GetModel( 'MODEL_C9Q' ):IsEmpty()

																If !oModel:GetModel( "MODEL_C9Q" ):IsDeleted()

																	aAdd (aGravaC9Q ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA');
																						+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC'),;
																						oModelC9Q:GetValue('C9Q_TRABAL'),;
																						oModelC9Q:GetValue('C9Q_GRAEXP'),;
																						oModelC9Q:GetValue('C9Q_INDCON'),;
																						oModelC9Q:GetValue('C9Q_MATRIC'),;
																						oModelC9Q:GetValue('C9Q_DTRABA')})

																	/*------------------------------------------
																		C9R - Itens da Remuneração Trab.
																	--------------------------------------------*/
																	For nC9R := 1 to oModel:GetModel( "MODEL_C9R" ):Length()

																		oModel:GetModel( "MODEL_C9R" ):GoLine(nC9R)

																		If !oModel:GetModel( 'MODEL_C9R' ):IsEmpty()

																			If !oModel:GetModel( "MODEL_C9R" ):IsDeleted()

																				If !lLaySimplif

																					aAdd (aGravaC9R ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL');
																										+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC')+oModelC9Q:GetValue('C9Q_MATRIC'),;
																										oModelC9R:GetValue('C9R_CODRUB'),;
																										oModelC9R:GetValue('C9R_QTDRUB'),;
																										oModelC9R:GetValue('C9R_VLRUNT'),;
																										oModelC9R:GetValue('C9R_FATORR'),;
																										oModelC9R:GetValue('C9R_VLRRUB'),;
																										oModelC9R:GetValue('C9R_RUBRIC'),;
																										oModelC9R:GetValue('C9R_IDTABR')})

																				Else

																					aAdd (aGravaC9R ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL');
																										+oModelC9P:GetValue('C9P_CODLOT')+oModelC9P:GetValue('C9P_TPINSC')+oModelC9P:GetValue('C9P_NRINSC')+oModelC9Q:GetValue('C9Q_MATRIC'),;
																										oModelC9R:GetValue('C9R_CODRUB'),;
																										oModelC9R:GetValue('C9R_QTDRUB'),;
																										oModelC9R:GetValue('C9R_FATORR'),;
																										oModelC9R:GetValue('C9R_VLRRUB'),;
																										oModelC9R:GetValue('C9R_APURIR'),;
																										oModelC9R:GetValue('C9R_RUBRIC'),;
																										oModelC9R:GetValue('C9R_IDTABR')})

																				EndIf
																					
																			EndIf

																		EndIf

																	Next //nC9R

																	If !lLaySimplif

																		/*------------------------------------------
																			V1C - Infos Trab Interm Per Anterior
																		--------------------------------------------*/
																		For nV1C := 1 to oModel:GetModel( "MODEL_V1C" ):Length()

																			oModel:GetModel( "MODEL_V1C" ):GoLine(nV1C)

																			If !oModel:GetModel( 'MODEL_V1C' ):IsEmpty()

																				If !oModel:GetModel( "MODEL_V1C" ):IsDeleted()
																					aAdd (aGravaV1C ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL'),;
																									oModelV1C:GetValue('V1C_IDCONV')})
																				EndIf

																			EndIf

																		Next //nV1C

																	Endif

																EndIf
															EndIf
														Next //nC9Q

													EndIf
												EndIf
											Next //nC9P

										EndIf
									EndIf
								Next //nC9O

							EndIf
						Next //nC9N

					EndIf
				EndIf
			Next //nT14

		EndIf

		For nlI := 1 To oModel:GetModel( 'MODEL_CRN' ):Length()

			oModel:GetModel( 'MODEL_CRN' ):GoLine(nlI)

			If !oModel:GetModel( 'MODEL_CRN' ):IsDeleted()
				aAdd (aGravaCRN,{	oModelCRN:GetValue('CRN_TPTRIB')	,;
									oModelCRN:GetValue('CRN_IDPROC')	,;
									oModelCRN:GetValue('CRN_IDSUSP')	})
			EndIf

		Next

		If lLaySimplif

			For nlI := 1 To oModel:GetModel( 'MODEL_V6K' ):Length()

				oModel:GetModel( 'MODEL_V6K' ):GoLine(nlI)

				If !oModel:GetModel( 'MODEL_V6K' ):IsDeleted()
					aAdd (aGravaV6K,{	oModelV6K:GetValue('V6K_DIA')})
				EndIf

			Next

		EndIf 

		For nlI := 1 To oModel:GetModel( 'MODEL_T6W' ):Length()

			oModel:GetModel( 'MODEL_T6W' ):GoLine(nlI)

			If !oModel:GetModel( 'MODEL_T6W' ):IsDeleted()
				aAdd (aGravaT6W ,{	    oModelT6W:GetValue('T6W_TPINSC')	,;
										oModelT6W:GetValue('T6W_NRINSC')	,;
										oModelT6W:GetValue('T6W_CODCAT')	,;
										oModelT6W:GetValue('T6W_VLREMU')	})
			EndIf

		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'C91', '2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu preciso setar a operacao do model³
		//³como Inclusao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu realizo a inclusao do novo registro ja³
		//³contemplando as informacoes alteradas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_C91', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		For nlI := 1 To Len( aGravaT6W )

			If nlI > 1
				oModel:GetModel( 'MODEL_T6W' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T6W", "T6W_TPINSC",	aGravaT6W[nlI][1] )
			oModel:LoadValue( "MODEL_T6W", "T6W_NRINSC",	aGravaT6W[nlI][2] )
			oModel:LoadValue( "MODEL_T6W", "T6W_CODCAT",	aGravaT6W[nlI][3] )
			oModel:LoadValue( "MODEL_T6W", "T6W_VLREMU",	aGravaT6W[nlI][4] )
			oModel:LoadValue( "MODEL_T6W", "T6W_NOMEVE",	"S1200" )

		Next

		/*------------------------------------------
			T14 - Informações do Recibo de Pag.
		--------------------------------------------*/
		For nT14 := 1 to Len( aGravaT14 )

			oModel:GetModel( 'MODEL_T14' ):LVALID	:= .T.

			If nT14 > 1
				oModel:GetModel( "MODEL_T14" ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T14", "T14_IDEDMD", aGravaT14[nT14][1] )
			oModel:LoadValue( "MODEL_T14", "T14_CODCAT", aGravaT14[nT14][2] )
			oModel:LoadValue( "MODEL_T14", "T14_CODCBO", aGravaT14[nT14][3] )
			oModel:LoadValue( "MODEL_T14", "T14_NATATV", aGravaT14[nT14][4] )
			oModel:LoadValue( "MODEL_T14", "T14_QTDTRB", aGravaT14[nT14][5] )
			
			If lSimplBeta .And. TafColumnPos("T14_INDRRA")

				oModel:LoadValue( "MODEL_T14", "T14_INDRRA", aGravaT14[nT14][6] )
				oModel:LoadValue( "MODEL_T14", "T14_TPPRRA", aGravaT14[nT14][7] )
				oModel:LoadValue( "MODEL_T14", "T14_NRPRRA", aGravaT14[nT14][8] )
				oModel:LoadValue( "MODEL_T14", "T14_DESCRA", aGravaT14[nT14][9] )
				oModel:LoadValue( "MODEL_T14", "T14_QTMRRA", aGravaT14[nT14][10] )
				oModel:LoadValue( "MODEL_T14", "T14_VLRCUS", aGravaT14[nT14][11] )
				oModel:LoadValue( "MODEL_T14", "T14_VLRADV", aGravaT14[nT14][12] )

				/*------------------------------------------
				V9K - Identificação dos advogados   
				--------------------------------------------*/
				nV9KAdd := 1
				For nV9K := 1 to Len( aGravaV9K )

					If  aGravaV9K[nV9K][1] == aGravaT14[nT14][1]

						oModel:GetModel( 'MODEL_V9K' ):LVALID := .T.

						If nV9KAdd > 1
							oModel:GetModel( "MODEL_V9K" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V9K", "V9K_TPINSC", aGravaV9K[nV9K][2] )
						oModel:LoadValue( "MODEL_V9K", "V9K_NRINSC", aGravaV9K[nV9K][3] )
						oModel:LoadValue( "MODEL_V9K", "V9K_VLRADV", aGravaV9K[nV9K][4] )
					
						nV9KAdd++
					EndIf

				Next

			EndIf

			/*------------------------------------------
			C9K - Informações do Estab/Lotação
			--------------------------------------------*/
			nC9KAdd := 1
			For nC9K := 1 to Len( aGravaC9K )

				If  aGravaC9K[nC9K][1] == aGravaT14[nT14][1]

					oModel:GetModel( 'MODEL_C9K' ):LVALID := .T.

					If nC9KAdd > 1
						oModel:GetModel( "MODEL_C9K" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_C9K", "C9K_ESTABE", aGravaC9K[nC9K][2] )
					oModel:LoadValue( "MODEL_C9K", "C9K_LOTACA", aGravaC9K[nC9K][3] )
					oModel:LoadValue( "MODEL_C9K", "C9K_QTDDIA", aGravaC9K[nC9K][4] )
					oModel:LoadValue( "MODEL_C9K", "C9K_CODLOT", aGravaC9K[nC9K][5] )
					oModel:LoadValue( "MODEL_C9K", "C9K_TPINSC", aGravaC9K[nC9K][6] )
					oModel:LoadValue( "MODEL_C9K", "C9K_NRINSC", aGravaC9K[nC9K][7] )

					/*------------------------------------------
					C9L - Informações da Remuneração Trab.
					--------------------------------------------*/
					nC9LAdd := 1
					For nC9L := 1 to Len( aGravaC9L )

						If aGravaC9L[nC9L][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9K[nC9K][5]+aGravaC9K[nC9K][6]+aGravaC9K[nC9K][7])

							oModel:GetModel( 'MODEL_C9L' ):LVALID := .T.

							If nC9LAdd > 1
								oModel:GetModel( "MODEL_C9L" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_C9L", "C9L_TRABAL", aGravaC9L[nC9L][2] )
							oModel:LoadValue( "MODEL_C9L", "C9L_GRAEXP", aGravaC9L[nC9L][3] )
							oModel:LoadValue( "MODEL_C9L", "C9L_INDCON", aGravaC9L[nC9L][4] )
							oModel:LoadValue( "MODEL_C9L", "C9L_DTRABA", aGravaC9L[nC9L][5] )

							/*------------------------------------------
								C9M - Itens da Remuneração Trab.
							--------------------------------------------*/
							nC9MAdd := 1
							For nC9M := 1 to Len( aGravaC9M )

								If aGravaC9M[nC9M][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9K[nC9K][5]+aGravaC9K[nC9K][6]+aGravaC9K[nC9K][7]+aGravaC9L[nC9L][2])

									oModel:GetModel( 'MODEL_C9M' ):LVALID := .T.

									If nC9MAdd > 1
										oModel:GetModel( "MODEL_C9M" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_C9M", "C9M_CODRUB",	aGravaC9M[nC9M][2] )
									oModel:LoadValue( "MODEL_C9M", "C9M_QTDRUB",	aGravaC9M[nC9M][3] )
									oModel:LoadValue( "MODEL_C9M", "C9M_VLRUNT",	aGravaC9M[nC9M][4] )
									oModel:LoadValue( "MODEL_C9M", "C9M_FATORR",	aGravaC9M[nC9M][5] )
									oModel:LoadValue( "MODEL_C9M", "C9M_VLRRUB",	aGravaC9M[nC9M][6] )
									oModel:LoadValue( "MODEL_C9M", "C9M_RUBRIC",	aGravaC9M[nC9M][7] )
									oModel:LoadValue( "MODEL_C9M", "C9M_IDTABR",	aGravaC9M[nC9M][8] )

									If lLaySimplif
										oModel:LoadValue( "MODEL_C9M", "C9M_APURIR",	aGravaC9M[nC9M][9] )
									EndIf

									nC9MAdd++

								EndIf

							Next //nC9M

							/*------------------------------------------
								T6Y - Informações de Valores Pagos
							--------------------------------------------*/
							nT6YAdd := 1
							For nT6Y := 1 to Len( aGravaT6Y )

								If aGravaT6Y[nT6Y][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2])

									oModel:GetModel( 'MODEL_T6Y' ):LVALID := .T.

									If nT6YAdd > 1
										oModel:GetModel( "MODEL_T6Y" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_T6Y", "T6Y_CNPJOP",	aGravaT6Y[nT6Y][2] )
									oModel:LoadValue( "MODEL_T6Y", "T6Y_REGANS",	aGravaT6Y[nT6Y][3] )
									oModel:LoadValue( "MODEL_T6Y", "T6Y_VLPGTI",	aGravaT6Y[nT6Y][4] )
									oModel:LoadValue( "MODEL_T6Y", "T6Y_NOMEVE",	"S1200" )

									/*------------------------------------------
										T6Z - Informações dos Dependentes
									--------------------------------------------*/
									nT6ZAdd := 1
									For nT6Z := 1 to Len( aGravaT6Z )

										If aGravaT6Z[nT6Z][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2]+aGravaT6Y[nT6Y][2]+aGravaT6Y[nT6Y][3])
											
											oModel:GetModel( 'MODEL_T6Z' ):LVALID := .T.

											If nT6ZAdd > 1
												oModel:GetModel( "MODEL_T6Z" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_T6Z", "T6Z_SEQUEN",	aGravaT6Z[nT6Z][2] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_TPDEP",		aGravaT6Z[nT6Z][3] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_CPFDEP",	aGravaT6Z[nT6Z][4] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMDEP",	aGravaT6Z[nT6Z][5] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_DTNDEP",	aGravaT6Z[nT6Z][6] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_VPGDEP",	aGravaT6Z[nT6Z][7] )
											oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMEVE",	"S1200" )

											nT6ZAdd++

										EndIf
									Next //nT6Z

									nT6YAdd++

								EndIf
							Next //nT6Y

							If !lLaySimplif

								/*------------------------------------------
									V1B - Infos Trab Interm Per Apuração
								--------------------------------------------*/
								nV1BAdd := 1
								For nV1B := 1 to Len( aGravaV1B )

									If aGravaV1B[nV1B][1] == (aGravaT14[nT14][1]+aGravaC9K[nC9K][2]+aGravaC9K[nC9K][3]+aGravaC9L[nC9L][2])

										oModel:GetModel( 'MODEL_V1B' ):LVALID := .T.

										If nV1BAdd > 1
											oModel:GetModel( "MODEL_V1B" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V1B", "V1B_IDCONV",	aGravaV1B[nV1B][2] )

										nV1BAdd++

									EndIf
								Next //nV1B

							EndIf

							nC9LAdd++

						EndIf
					Next //nC9L

					nC9KAdd++

				EndIf
			Next //nC9K

			/*------------------------------------------
				C9N - Informações de Acordo
			--------------------------------------------*/
			For nC9N := 1 to Len( aGravaC9N )

				cDmDv := Iif(lLaySimplif,aGravaC9N[nC9N][5],aGravaC9N[nC9N][7])

				If aGravaT14[nT14][1] == cDmDv

					oModel:GetModel( 'MODEL_C9N' ):LVALID	:= .T.

					If !(oModel:GetModel( "MODEL_C9N" ):IsEmpty())
						oModel:GetModel( "MODEL_C9N" ):AddLine()
					EndIf

					If !lLaySimplif
						oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
						oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
						oModel:LoadValue( "MODEL_C9N", "C9N_COMPAC",	aGravaC9N[nC9N][3] )
						oModel:LoadValue( "MODEL_C9N", "C9N_DTEFAC",	aGravaC9N[nC9N][4] )
						oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][5] )
						oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][6] )
					Else
						oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
						oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
						oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][3] )
						oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][4] )
					EndIf

					nC9OAdd := 1
					For nC9O := 1 to Len( aGravaC9O )

						If  aGravaC9O[nC9O][1] == (aGravaC9N[nC9N][5]+Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2])

							oModel:GetModel( 'MODEL_C9O' ):LVALID := .T.

							If nC9OAdd > 1
								oModel:GetModel( "MODEL_C9O" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_C9O", "C9O_PERREF", aGravaC9O[nC9O][2] )

							/*------------------------------------------
								C9P - Informações do Estab/Lotação
							--------------------------------------------*/
							nC9PAdd := 1
							For nC9P := 1 to Len( aGravaC9P )

					
								If aGravaC9P[nC9P][1] == (aGravaC9N[nC9N][5]+Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2])

									oModel:GetModel( 'MODEL_C9P' ):LVALID := .T.

									If nC9PAdd > 1
										oModel:GetModel( "MODEL_C9P" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_C9P", "C9P_ESTABE",	aGravaC9P[nC9P][2] )
									oModel:LoadValue( "MODEL_C9P", "C9P_LOTACA",	aGravaC9P[nC9P][3] )
									oModel:LoadValue( "MODEL_C9P", "C9P_CODLOT",	aGravaC9P[nC9P][4] )
									oModel:LoadValue( "MODEL_C9P", "C9P_TPINSC",	aGravaC9P[nC9P][5] )
									oModel:LoadValue( "MODEL_C9P", "C9P_NRINSC",	aGravaC9P[nC9P][6] )

									/*------------------------------------------
										C9Q - Informações da Remuneração Trab.
									--------------------------------------------*/
									nC9QAdd := 1
									For nC9Q := 1 to Len( aGravaC9Q )

										If  aGravaC9Q[nC9Q][1] == (aGravaC9N[nC9N][5]+Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9P[nC9P][4]+aGravaC9P[nC9P][5]+aGravaC9P[nC9P][6])

											oModel:GetModel( 'MODEL_C9Q' ):LVALID := .T.

											If nC9QAdd > 1
												oModel:GetModel( "MODEL_C9Q" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_C9Q", "C9Q_TRABAL",	aGravaC9Q[nC9Q][2] )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_GRAEXP",	aGravaC9Q[nC9Q][3] )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_INDCON",    aGravaC9Q[nC9Q][4] )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_MATRIC",    aGravaC9Q[nC9Q][5] )
											oModel:LoadValue( "MODEL_C9Q", "C9Q_DTRABA",    aGravaC9Q[nC9Q][6] )


											/*------------------------------------------
													C9R - Itens da Remuneração Trab.
											--------------------------------------------*/
											nC9RAdd := 1
											For nC9R := 1 to Len( aGravaC9R )

												If  aGravaC9R[nC9R][1] == (aGravaC9N[nC9N][5]+Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2]+aGravaC9P[nC9P][4]+aGravaC9P[nC9P][5]+aGravaC9P[nC9P][6]+aGravaC9Q[nC9Q][5])
													
													oModel:GetModel( 'MODEL_C9R' ):LVALID := .T.

													If nC9RAdd > 1
														oModel:GetModel( "MODEL_C9R" ):AddLine()
													EndIf

													If !lLaySimplif
														oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
														oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
														oModel:LoadValue( "MODEL_C9R", "C9R_VLRUNT",	aGravaC9R[nC9R][4] )
														oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][5] )
														oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][6] )
													Else
														oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
														oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
														oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][4] )
														oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][5] )
														oModel:LoadValue( "MODEL_C9R", "C9R_APURIR",	aGravaC9R[nC9R][6] )
													EndIf

													oModel:LoadValue( "MODEL_C9R", "C9R_RUBRIC",	aGravaC9R[nC9R][7] )
													oModel:LoadValue( "MODEL_C9R", "C9R_IDTABR",	aGravaC9R[nC9R][8] )

													nC9RAdd++

												EndIf

											Next //nC9R

											If !lLaySimplif
												/*------------------------------------------
													V1C - Infos Trab Interm Per Anterior
												--------------------------------------------*/
												nV1CAdd := 1
												For nV1C := 1 to Len( aGravaV1C )

													If  aGravaV1C[nV1C][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2])
														
														oModel:GetModel( 'MODEL_V1C' ):LVALID := .T.

														If nV1CAdd > 1
															oModel:GetModel( "MODEL_V1C" ):AddLine()
														EndIf

														oModel:LoadValue( "MODEL_V1C", "V1C_IDCONV",	aGravaV1C[nV1C][2] )

														nV1CAdd++

													EndIf
												Next //nV1C

											EndIf

											nC9QAdd++

										EndIf
									Next //nC9Q

								EndIf
							Next //nC9P

							nC9OAdd++

						EndIf
					Next //nC9O

				EndIf
			Next //nC9N

		Next //nT14	

		For nlI := 1 To Len( aGravaCRN )

			If nlI > 1
				oModel:GetModel( 'MODEL_CRN' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_CRN", "CRN_TPTRIB" ,	aGravaCRN[nlI][1] )
			oModel:LoadValue( "MODEL_CRN", "CRN_IDPROC" ,	aGravaCRN[nlI][2] )
			oModel:LoadValue( "MODEL_CRN", "CRN_IDSUSP" ,	aGravaCRN[nlI][3] )

		Next

		If lLaySimplif

			For nlI := 1 To Len( aGravaV6K )

				If nlI > 1
					oModel:GetModel( 'MODEL_V6K' ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_V6K", "V6K_DIA" ,	aGravaV6K[nlI][1] )
			Next

		EndIf 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C91", "C91_VERSAO", cVersao 	)
		oModel:LoadValue( "MODEL_C91", "C91_VERANT", cVerAnt 	)
		oModel:LoadValue( "MODEL_C91", "C91_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_C91", "C91_PROTUL", '' 		)
		oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1200" 	)

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C91", "C91_EVENTO"	, "E" )
		oModel:LoadValue( "MODEL_C91", "C91_ATIVO"	, "1" )	

		FwFormCommit(oModel)		
		TAFAltStat("C91", "6")

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} XRetCatTrab
Funcao que retorna a categoria de um trabalhador dependendo de seu evento

@param cIdTrab    - Id do trabalhador

@return cRet - Retorno com a categoria encontrada.

@author Vitor Siqueira
@since 13/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function XRetCatTrab(cAliasTab, cCodTrab)

	Local cRet    := ""
	Local cCodCat := ""
	Local cCampo  := ""
	Local cAlias  := ""

	cAlias := "CUP"
	cCampo := "CUP_CODCAT"

	If !Empty(cAlias)

		cCodCat := POSICIONE(cAlias,1, xFilial(cAlias)+cCodTrab,cCampo)
		cRet    := POSICIONE("C87" ,1, xFilial("C87") +cCodCat,"C87_CODIGO")

		If !Empty(cRet)
			cRet    += " - " + POSICIONE("C87" ,1, xFilial("C87") +cCodCat,"C87_DESCRI")
		EndIf
		
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf250MV
Retorna se o XML possui múltiplos vínculos
@author  Victor A. Barbosa
@since   19/06/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function Taf250MV( oXML, lInfoCompl, cChave, nChvIndex, cFilEv, aIncons )

	Local lRet          := .F.
	Local aChildRem     := {}
	Local aChildPerAnt  := {}
	Local nVinc         := 0
	Local nVincAnt      := 0
	Local nEstab        := 0
	Local nDmDev        := 1
	Local nPerAnt       := 1
	Local cNrInsc       := ""
	Local cMatric       := ""
	Local cPathDmDev    := ""
	Local cPathEstab    := ""
	Local cPathRemun    := ""
	Local cTipoApur     := ""
	Local cPathIdPerAnt := ""

	aChildRem	:= oXML:XPathGetChildArray( '/eSocial/evtRemun' )
	lInfoCompl	:= oXML:XPathHasNode( '/eSocial/evtRemun/ideTrabalhador/infoComplem' )

	aEval( aChildRem, { |x| Iif( x[1] == "dmDev", nVinc++,  ) } )

	cPathDmDev	:= "/eSocial/evtRemun/dmDev[" + cValToChar( nDmDev ) + "]"

	If nVinc > 1

		cTipoApur:= oXML:XPathGetChildArray(cPathDmDev)[3][1]

		If cTipoApur == "infoPerAnt"

			cPathEstab	:= cPathDmDev + "/infoPerAnt/ideADC/idePeriodo[" + cValToChar( nPerAnt ) + "]/ideEstabLot[" + cValToChar( 1 ) + "]"
			cNrInsc 	:= FTafGetVal( cPathEstab + "/nrInsc", "C", .F., {}, .F. )
			cMatric     := FTafGetVal( cPathEstab + "/remunPerAnt/matricula", "C", .F., {}, .F. )

		Else

			cPathEstab	:= cPathDmDev + "/infoPerApur/ideEstabLot[" + cValToChar( 1 ) + "]"
			cNrInsc 	:= FTafGetVal( cPathEstab + "/nrInsc", "C", .F., {}, .F. )
			cMatric     := FTafGetVal( cPathEstab + "/remunPerApur/matricula", "C", .F., {}, .F. )

		EndIf

		While oDados:xPathHasNode( cPathDmDev )

			nEstab		:= 1
			nPerAnt		:= 1

			cTipoApur	:= oXML:XPathGetChildArray(cPathDmDev)[3][1]

			If cTipoApur == "infoPerAnt"

				aChildPerAnt	:= oXML:XPathGetChildArray( "/eSocial/evtRemun/dmDev[" + cValToChar( nDmDev ) + "]/infoPerAnt/ideADC" )
				aEval( aChildPerAnt	, { |x| Iif( x[1] == "idePeriodo", nVincAnt++,  ) } )

				cPathIdPerAnt 	:= cPathDmDev + "/infoPerAnt/ideADC/idePeriodo[" + cValToChar( nPerAnt ) + "]"

				If nVincAnt > 1

					While oDados:xPathHasNode( cPathIdPerAnt )

						nEstab := 1

						cPathEstab		:= cPathDmDev + "/infoPerAnt/ideADC/idePeriodo[" + cValToChar( nPerAnt ) + "]/ideEstabLot[" + cValToChar( nEstab ) + "]"
						cPathRemun 		:= cPathEstab + "/remunPerAnt"

						// --> Se encontrou números de inscrições diferentes ou matrículas diferentes, então é sinal que é múltiplos vínculos
						While oDados:xPathHasNode( cPathEstab )

							If 	cNrInsc <> FTafGetVal( cPathEstab + "/nrInsc"	, "C", .F., {}, .F. ) .Or. ;
								cMatric <> FTafGetVal( cPathRemun + "/matricula", "C", .F., {}, .F. )

								lRet := .T.
								Exit

							EndIf

							nEstab ++
					
							cPathEstab  := cPathDmDev + "/infoPerAnt/ideADC/idePeriodo[" + cValToChar( nPerAnt ) + "]/ideEstabLot[" + cValToChar( nEstab ) + "]"

						EndDo

						nPerAnt++

						cPathIdPerAnt 	:= cPathDmDev + "/infoPerAnt/ideADC/idePeriodo[" + cValToChar( nPerAnt ) + "]"

					EndDo

				EndIf

			Else 

				cPathEstab		:= cPathDmDev + "/infoPerApur/ideEstabLot[" + cValToChar( nEstab ) + "]"
				cPathRemun		:= cPathEstab + "/remunPerApur"

			EndIf

			While oDados:xPathHasNode( cPathEstab )

				// --> Se encontrou números de inscrições diferentes ou matrículas diferentes, então é sinal que é múltiplos vínculos
				If 	cNrInsc <> FTafGetVal( cPathEstab + "/nrInsc"	, "C", .F., {}, .F. ) .Or. ;
					cMatric <> FTafGetVal( cPathRemun + "/matricula", "C", .F., {}, .F. )

					lRet := .T.
					Exit

				EndIf

				nEstab ++
					
				cPathEstab	:= cPathDmDev + "/infoPerApur/ideEstabLot[" + cValToChar( nEstab ) + "]"

			EndDo

			// Se encontrou diferenças, quebra o loop
			If lRet
				Exit
			EndIf

			nDmDev ++
			cPathDmDev := "/eSocial/evtRemun/dmDev[" + cValToChar( nDmDev ) + "]"

		EndDo
		
	Else

		//Verifica se o evento ja existe na base
		("C91")->( DbSetOrder( nChvIndex ) ) // C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NIS+C91_NOMEVE+C91_ATIVO
		If ("C91")->( MsSeek(FTafGetFil(cFilEv,@aIncons,"C91") + cChave + 'S1200' +'1' ) )
		
			("T14")->( DbSetOrder( 1 ) )
			If ("T14")->(MsSeek(FTafGetFil(cFilEv,@aIncons,"C91")+C91->C91_ID+C91->C91_VERSAO ))

				cChvT14 := C91->C91_FILIAL+C91->C91_ID+C91->C91_VERSAO

				While ("T14")->(!EOF()) .AND. T14->(T14_FILIAL+T14_ID+T14_VERSAO) == cChvT14
				
					If AllTrim(T14->T14_IDEDMD) == FTafGetVal("/eSocial/evtRemun/dmDev/ideDmDev", "C", .F., {}, .F. )
						lRet := .F.
						Exit
					Else
						lRet := .T.
					EndIf		
					
					("T14")->(DbSkip())

				End

			EndIf		
			
		EndIf	
			
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIdTabRub
Retorna o ID da tabela de Rúbrica
@author  Victor A. Barbosa
@since   19/06/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAFIdTabRub( cCodERP, cAliasEve, cCodRubr, cRubPath, cInconMsg, nSeqErrGrv, aIncons )

	Local cTmpAlia     := ""
	Local cC8R         := ""
	Local cIDRet       := ""
	Local nCount       := 0

	Default aIncons    := {}
	Default cCodRubr   := ""
	Default cAliasEve  := "T3M"
	Default cInconMsg  := ""
	Default cCodERP    := ""
	Default cRubPath   := ""
	Default nSeqErrGrv := 0

	If Len(__aIdTabRub) > 0
		
		nPosTabRub := aScan(__aIdTabRub,{|t|t[1] == xFilial("T3M") .And. t[2] == AllTrim(cCodERP) .And. t[4] == cCodRubr})

		If nPosTabRub > 0 
			Return __aIdTabRub[nPosTabRub][3]	 
		EndIf 

	EndIf 

	If !Empty(cCodRubr)

		If Empty(__cIDChFil)
			__cIDChFil := UUIDRandom()
		EndIf

		aArea		:= GetArea()
		cC8R		:= GetNextAlias()
		cTmpAlia	:= TAFCacheFil(cAliasEve,,,, __cIDChFil)

		If !TCCanOpen(cTmpAlia)			
			__cIDChFil 	:= UUIDRandom()	
			cTmpAlia	:= TAFCacheFil(cAliasEve,,,, __cIDChFil)
		EndIf

		BeginSQL Alias cC8R
			SELECT 	T3M_ID,
			T3M_CODERP
			FROM %table:T3M% T3M
			INNER JOIN %table:C8R% C8R
			ON T3M_CODERP = %exp:cCodERP%
			AND T3M_ID = C8R_IDTBRU
			AND C8R.C8R_CODRUB = %exp:cCodRubr%
					AND T3M.T3M_FILIAL IN (
						SELECT FILIAIS.FILIAL 
							FROM %temp-table:cTmpAlia% FILIAIS
					)
			AND C8R.%notdel%
			AND T3M.%notdel%
			GROUP BY T3M_ID, C8R_CODRUB,T3M_CODERP
		EndSQL

		While (cC8R)->( !Eof())
			nCount++
			cIDRet 		:= (cC8R)->T3M_ID
			cT3McodERP 	:= AllTrim((cC8R)->T3M_CODERP)
			(cC8R)->(dBSkip())
		EndDo

		If nCount > 1

			If Select(cC8R) > 0
				(cC8R)->(DBCloseArea())
			EndIf

			// Pega o Codigo da tabela de rubricas olhando o status da rubrica
			// desta forma quando o cliente estiver com o código ERP duplicado
			// o sistema conseguirá pegar o código correto.
			BeginSQL Alias cC8R
				SELECT T3M.T3M_ID,
					T3M.T3M_CODERP
					FROM %table:T3M% T3M
					INNER JOIN  %table:C8R% C8R
					ON T3M.T3M_CODERP = %exp:cCodERP%
						AND T3M.T3M_ID = C8R.C8R_IDTBRU
						AND C8R.C8R_CODRUB = %exp:cCodRubr%
						AND T3M.T3M_FILIAL IN (
							SELECT FILIAIS.FILIAL 
								FROM %temp-table:cTmpAlia% FILIAIS
						)
						AND C8R.C8R_FILIAL = %xFilial:C8R%
						AND C8R.C8R_STATUS = "4"
						AND C8R.%notdel%
						AND T3M.%notdel%
			EndSQL

			If !(cC8R)->(EoF())
				cIDRet 		:= (cC8R)->T3M_ID
				cT3McodERP 	:= AllTrim((cC8R)->T3M_CODERP)
			EndIf

		EndIf

		(cC8R)->(DBCloseArea())
	EndIf

	If nCount > 0 .AND. Empty(cIDRet)

		If Empty(cCodRubr) .AND. Empty(cCodERP)
			TAFMsgIncons(@cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', FTafGetVal(cRubPath + "/ideTabRubr", "C", .F., @aIncons, .F.), 'idTabRubr',, 'codRubr', cCodRubr)
		Else
			TAFMsgIncons(@cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cCodERP , 'idTabRubr',, 'codRubr', cCodRubr)
		EndIf	

	ElseIf !Empty(cIDRet)

		aAdd(__aIdTabRub,{xFilial("T3M"),cT3McodERP,cIDRet,cCodRubr})

	EndIf

Return cIDRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250View
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF250View( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 1 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 1 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Inc
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF250Inc( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 3 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Nis
Busca NIS do funcionário

@param lC9VPosc - Indica que a tabela C9V já está posicionada

@author  Leonardo Kichitaro
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF250Nis( cFilialC9V, cIDC9V, cNisC9V, cPerApu, cEvento,lC9VPosc)

	Local cAlias       := GetNextAlias()
	Local cRetNIS      := ""
	Local dFrtDt       := SToD( "" )
	Local dLstDt       := SToD( "" )
	Local aArea        := GetArea()
	Local aAreaT1V     := T1V->( GetArea() )
	Local cCPF         := ""

	Default cFilialC9V := xFilial( "C9V" )
	Default cIDC9V     := ""
	Default cNisC9V    := ""
	Default cPerApu    := ""
	Default cEvento    := ""
	Default lC9VPosc   := .F.


	If Empty( cIDC9V )

		TAFConOut( "TAF250Nis| Erro na busca dos dados do funcionario. ID nao informado." + CRLF ;
					+ "Verifique se o seu cadastro de funcionario esta com todos os ID's preenchidos e se nao ha duplicidade de ID's" + CRLF + CRLF ;
					+ "Tabela envolvida: 'C9V' | Campo: 'C9V_ID'" )

	Else

		If lC9VPosc
			cCPF := C9V->C9V_CPF
		Else
			cCPF := POSICIONE("C9V", 2, cFilialC9V+cIDC9V+"1","C9V->C9V_CPF")
		EndIf 

		//Tratamento para eventos que não possuem período no formato MM/AAAA
		If Len( cPerApu ) == 8

			dFrtDt := SToD( cPerApu )
			dLstDt := SToD( cPerApu )

		Else

			cPerApu := StrTran( cPerApu, "-", "" )
			
			If Len(AllTrim(cPerApu)) == 4 //Folha Anual
				//Folha Anual
				dFrtDt := CTOD("01/01/" + AllTrim(cPerApu))
				dLstDt := LastDate( CTOD("01/12/" + AllTrim(cPerApu)) )
			Else 
				If !( Empty( cPerApu ) )
					dFrtDt := CToD( "01/" + SubStr( cPerApu, 5, 2 ) + "/" + SubStr( cPerApu, 1, 4 ) )
					dLstDt := LastDate( dFrtDt )
				EndIf
			EndIf 

		EndIf

		TAFConOut( "TAF250Nis |" + FWTimeStamp( 3 ) + " - Chave de busca do funcionario: |" + cFilialC9V + cIDC9V + cNisC9V + "| Recno: " + Str( C9V->( Recno() ) ) )

	If FwIsInCallStack("TAFA266") .Or. FwIsInCallStack("TAFA250") //--> Faço essa query abaixo para verificar se o ID posicionado tem correspondência na C9V e T1U

		BeginSql Alias cAlias //--> Mesmo que o CPF existir na T1U (com outro ID), se o ID posicionado em tela (S-2299\S-1200) existir somente na C9V, pego o NIS da C9V.
		
			column T1U_DTALT as Date

			SELECT DISTINCT T1U_NIS, T1U_DTALT
			FROM %table:T1U% T1U
			WHERE T1U.T1U_FILIAL = %exp:cFilialC9V%
				AND T1U.T1U_CPF = %exp:cCPF%
				AND T1U.T1U_ATIVO = '1'
				AND T1U.%notdel%
				AND T1U.T1U_ID = %exp:cIDC9V% 
			ORDER BY T1U_DTALT DESC
		EndSql

	Else 

		BeginSql Alias cAlias //--> Tratamento de NIS com CPF existente na T1U para todos os eventos, exceto S-1200 e S-2299.
		
			column T1U_DTALT as Date

			SELECT DISTINCT T1U_NIS, T1U_DTALT
			FROM %table:T1U% T1U
			WHERE T1U.T1U_FILIAL = %exp:cFilialC9V%
				AND T1U.T1U_CPF = %exp:cCPF%
				AND T1U.T1U_ATIVO = '1'
				AND T1U.%notdel%
			ORDER BY T1U_DTALT DESC
		EndSql

	EndIf 

		While ( cAlias )->( !Eof() )

			If Empty(dLstDt) .Or. ( cAlias )->T1U_DTALT <= dLstDt
				cRetNIS := ( cAlias )->T1U_NIS
				Exit
			EndIf

			( cAlias )->(dBSkip())

		EndDo 

		If Empty( cRetNIS )

			TAFConOut( "TAF250Nis| Erro na busca dos dados do funcionario na tabela de historico. Funcionario nao encontrado." + CRLF ;
						+ "Verifique se o seu cadastro do funcionario possui informacoes na tabela de historico para o ID: " + cIDC9V + " Filial: " + cFilialC9V + CRLF ;
						+ "Caso não tenha, realize o ajuste do cadastro dentro do ERP e re-faça a integração com o TAF." + CRLF + CRLF ;
						+ "Tabelas envolvidas: 'C9V e T1U' | Campos: 'C9V_ID e T1U_ID'" + CRLF ;
						+ "Continuaremos o processo com o NIS informado dentro do cadastro do funcionario: " + cNisC9V + CRLF ; 
						+ "Se o funcionario nao teve alteraçoes cadastrais, desconsiderar esta mensagem." )

			cRetNIS := cNisC9V

		EndIf

	EndIf

	If Select(cAlias) > 0 
		( cAlias )->( DBCloseArea() ) 
	EndIf 

	RestArea( aAreaT1V )
	RestArea( aArea )

Return( cRetNIS )

//---------------------------------------------------------------------
/*/{Protheus.doc} PreVldLine
@type			function
@description	Bloco de código executado ao realizar alguma ação na linha do oSubModel
@author			Marcelo Neumann
@since			24/09/2018
@version		1.0
@return			lRet
/*/
//---------------------------------------------------------------------
Static Function PreVldLine()

	Local oModel := FWModelActive()

	If oModel:GetModel("MODEL_C9L"):IsEmpty()
		oModel:LoadValue("MODEL_C9L","C9L_TRABAL"," ")
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelOk
@type			Function
@description	Bloco de código executado ao Confirmar
@author			Marcelo Neumann
@since			24/09/2018
@version		1.0
@param			oSubModel - SubModelo que chamou a função
@return			lRet
/*/
//---------------------------------------------------------------------
Static Function ModelOk(oSubModel)

	Local oModelPai  := FWModelActive()
	Local nOperation := oModelPai:GetOperation()
	Local lRet       := .T.

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		AddLinC9L(oModelPai)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} AddLinC9L
@type			function
@description	Adiciona uma linha em branco no model C9L quando algum modelo filho estiver prenchido
@author			Marcelo Neumann
@since			24/09/2018
@version		1.0
@param			oModel - Modelo
@return			NIL
/*/
//---------------------------------------------------------------------
Static Function AddLinC9L(oModel)

	Local nT14 := 0
	Local nC9K := 0
	Local nC9L := 0

	For nT14 := 1 to oModel:GetModel("MODEL_T14"):Length()

		oModel:GetModel("MODEL_T14"):GoLine(nT14)

		For nC9K := 1 to oModel:GetModel("MODEL_C9K"):Length()

			oModel:GetModel("MODEL_C9K"):GoLine(nC9K)

			For nC9L := 1 to oModel:GetModel("MODEL_C9L"):Length()

				oModel:GetModel("MODEL_C9L"):GoLine(nC9L)

				If oModel:GetModel("MODEL_C9L"):IsEmpty()
					If !oModel:GetModel("MODEL_C9M"):IsEmpty()
						oModel:LoadValue("MODEL_C9L","C9L_TRABAL"," ")
					EndIf
				EndIf

				If oModel:GetModel("MODEL_C9L"):IsEmpty()
					If !oModel:GetModel("MODEL_T6Y"):IsEmpty()
						oModel:LoadValue("MODEL_C9L","C9L_TRABAL"," ")
					EndIf
				EndIf

			Next nC9L

		Next nC9K

	Next nT14

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 22/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";" 
	cCSS += "padding: 2px 5px;" 
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF250Rpt
@type			function
@description	Inicializa a variável static __lGrvRPT.
@author			Victor A. Barbosa
@since			21/05/2019
/*/
//---------------------------------------------------------------------
Static Function TAF250Rpt()

	__lGrvRPT := TAFAlsInDic( "V3N" )

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Trigger
Criação da trigger
@author  Karyna R. M. Martins
@since   25/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAF250Trigger()

	Local aAux :=   FwStruTrigger(;
				"C91_TRABAL" ,; // Campo Dominio
				"C91_CPF" ,; // Campo de Contradominio
				"TafGetCPF(C91->C91_FILIAL,M->C91_TRABAL,C91->C91_CPF,'C91')",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				"!Empty(M->C91_TRABAL)" ,; // Condicao para execucao do gatilho
				"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)


Return aAux
              
//--------------------------------------------------------------------
/*/{Protheus.doc} TafCrrMdl

Carrega o modelo com os registro para aglutinar no novo cenário

@author Bruno Rosa
@since 29/11/2019
@version 1.0

@param oMdlNvCen - Modelo que contem os registros
@param oModel - Modelo que receberá os dados

/*/
//--------------------------------------------------------------------
Static Function TafCrrMdl(oMdlNvCen, oModel, cIDC91, cVersC91 )

	Local nT14          := 0
	Local nC9K, nC9KAdd := 0
	Local nC9L, nC9LAdd := 0
	Local nC9M, nC9MAdd := 0
	Local nT6Y, nT6YAdd := 0
	Local nT6Z, nT6ZAdd := 0
	Local nC9N          := 0
	Local nC9O, nC9OAdd := 0
	Local nC9P, nC9PAdd := 0
	Local nC9Q, nC9QAdd := 0
	Local nC9R, nC9RAdd := 0
	Local nCRN          := 0
	Local nT6W          := 0
	Local nV1B, nV1BAdd := 0
	Local nV1C, nV1CAdd := 0
	Local nV6K          := 0

	Local aGravaT14     := {}
	Local aGravaC9L     := {}
	Local aGravaC9M     := {}
	Local aGravaT6Y     := {}
	Local aGravaT6Z     := {}
	Local aGravaC9O     := {}
	Local aGravaC9Q     := {}
	Local aGravaC9R     := {}
	Local aGravaCRN     := {}
	Local aGravaT6W     := {}
	Local aGravaC9K     := {}
	Local aGravaC9N     := {}
	Local aGravaC9P     := {}
	Local aGravaV1B     := {}
	Local aGravaV1C     := {}
	Local aGravaV6K     := {}

	oModelT14 := oMdlNvCen:GetModel( 'MODEL_T14' )
	oModelC9K := oMdlNvCen:GetModel( 'MODEL_C9K' )
	oModelC9L := oMdlNvCen:GetModel( 'MODEL_C9L' )
	oModelC9M := oMdlNvCen:GetModel( 'MODEL_C9M' )
	oModelT6Y := oMdlNvCen:GetModel( 'MODEL_T6Y' )
	oModelT6Z := oMdlNvCen:GetModel( 'MODEL_T6Z' )
	oModelC9N := oMdlNvCen:GetModel( 'MODEL_C9N' )
	oModelC9O := oMdlNvCen:GetModel( 'MODEL_C9O' )
	oModelC9P := oMdlNvCen:GetModel( 'MODEL_C9P' )
	oModelC9Q := oMdlNvCen:GetModel( 'MODEL_C9Q' )
	oModelC9R := oMdlNvCen:GetModel( 'MODEL_C9R' )
	oModelCRN := oMdlNvCen:GetModel( 'MODEL_CRN' )
	oModelT6W := oMdlNvCen:GetModel( 'MODEL_T6W' )

	If lLaySimplif
		oModelV6K := oMdlNvCen:GetModel( 'MODEL_V6K' )
	EndIf 

	For nT14 := 1 To oModelT14:Length()
		
		oModelT14:GoLine(nT14)

		If !oModelT14:IsDeleted()

			aAdd (aGravaT14 ,{oModelT14:GetValue('T14_IDEDMD'),;
							oModelT14:GetValue('T14_CODCAT')})

			/*C9K - Informações do Estab/Lotação*/
			For nC9K := 1 to oMdlNvCen:GetModel( "MODEL_C9K" ):Length()

				oMdlNvCen:GetModel( "MODEL_C9K" ):GoLine(nC9K)

				If !oMdlNvCen:GetModel( 'MODEL_C9K' ):IsEmpty()

					If !oMdlNvCen:GetModel( "MODEL_C9K" ):IsDeleted()

						aAdd (aGravaC9K ,{oModelT14:GetValue('T14_IDEDMD'),;
											oModelC9K:GetValue('C9K_ESTABE'),;
											oModelC9K:GetValue('C9K_LOTACA'),;
											oModelC9K:GetValue('C9K_QTDDIA'),;
											oModelC9K:GetValue('C9K_CODLOT'),;
											oModelC9K:GetValue('C9K_TPINSC'),;
											oModelC9K:GetValue('C9K_NRINSC') } )

						/*C9L - Informações da Remuneração Trab.*/
						For nC9L := 1 to oMdlNvCen:GetModel( "MODEL_C9L" ):Length()

							oMdlNvCen:GetModel( "MODEL_C9L" ):GoLine(nC9L)

							If !oMdlNvCen:GetModel( 'MODEL_C9L' ):IsEmpty()

								If !oMdlNvCen:GetModel( "MODEL_C9L" ):IsDeleted()

									aAdd (aGravaC9L ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA'),;
														oModelC9L:GetValue('C9L_TRABAL'),;
														oModelC9L:GetValue('C9L_GRAEXP'),;
														oModelC9L:GetValue('C9L_INDCON'),;
														oModelC9L:GetValue('C9L_DTRABA') } )

									/*C9M - Itens da Remuneração Trab.*/
									For nC9M := 1 to oMdlNvCen:GetModel( "MODEL_C9M" ):Length()

										oMdlNvCen:GetModel( "MODEL_C9M" ):GoLine(nC9M)

										If !oMdlNvCen:GetModel( 'MODEL_C9M' ):IsEmpty()

											If !oMdlNvCen:GetModel( "MODEL_C9M" ):IsDeleted()

												If lLaySimplif

													aAdd (aGravaC9M ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																	oModelC9M:GetValue('C9M_CODRUB'),;
																	oModelC9M:GetValue('C9M_QTDRUB'),;
																	oModelC9M:GetValue('C9M_VLRUNT'),;
																	oModelC9M:GetValue('C9M_FATORR'),;
																	oModelC9M:GetValue('C9M_VLRRUB'),;
																	oModelC9M:GetValue('C9M_RUBRIC'),;
																	oModelC9M:GetValue('C9M_IDTABR'),;
																	oModelC9M:GetValue('C9M_APURIR') } )

												Else 

													aAdd (aGravaC9M ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																		oModelC9M:GetValue('C9M_CODRUB'),;
																		oModelC9M:GetValue('C9M_QTDRUB'),;
																		oModelC9M:GetValue('C9M_VLRUNT'),;
																		oModelC9M:GetValue('C9M_FATORR'),;
																		oModelC9M:GetValue('C9M_VLRRUB'),;
																		oModelC9M:GetValue('C9M_RUBRIC'),;
																		oModelC9M:GetValue('C9M_IDTABR') } )

												EndIf

											EndIf

										EndIf

									Next //nC9M

									If !lLaySimplif

										/*T6Y - Informações de Valores Pagos*/
										For nT6Y := 1 to oMdlNvCen:GetModel( "MODEL_T6Y" ):Length()

											oMdlNvCen:GetModel( "MODEL_T6Y" ):GoLine(nT6Y)

											If !oMdlNvCen:GetModel( 'MODEL_T6Y' ):IsEmpty()

												If !oMdlNvCen:GetModel( "MODEL_T6Y" ):IsDeleted()

													aAdd (aGravaT6Y ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																		oModelT6Y:GetValue('T6Y_CNPJOP'),;
																		oModelT6Y:GetValue('T6Y_REGANS'),;
																		oModelT6Y:GetValue('T6Y_VLPGTI')})

													/*T6Z - Informações dos Dependentes*/
													For nT6Z := 1 to oMdlNvCen:GetModel( "MODEL_T6Z" ):Length()

														oMdlNvCen:GetModel( "MODEL_T6Z" ):GoLine(nT6Z)

														If !oMdlNvCen:GetModel( 'MODEL_T6Z' ):IsEmpty()

															If !oMdlNvCen:GetModel( "MODEL_T6Z" ):IsDeleted()

																aAdd (aGravaT6Z ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL')+oModelT6Y:GetValue('T6Y_CNPJOP')+oModelT6Y:GetValue('T6Y_REGANS'),;
																					oModelT6Z:GetValue('T6Z_SEQUEN'),;
																					oModelT6Z:GetValue('T6Z_TPDEP') ,;
																					oModelT6Z:GetValue('T6Z_CPFDEP'),;
																					oModelT6Z:GetValue('T6Z_NOMDEP'),;
																					oModelT6Z:GetValue('T6Z_DTNDEP'),;
																					oModelT6Z:GetValue('T6Z_VPGDEP')})
															EndIf

														EndIf
													Next //nT6Z
												
												EndIf
											EndIf
										Next //nT6Y
									
										/*V1B - Infos Trab Interm Per Apuração*/
										For nV1B := 1 to oMdlNvCen:GetModel( "MODEL_V1B" ):Length()

											oMdlNvCen:GetModel( "MODEL_V1B" ):GoLine(nV1B)

											If !oMdlNvCen:GetModel( 'MODEL_V1B' ):IsEmpty()

												If !oMdlNvCen:GetModel( "MODEL_V1B" ):IsDeleted()
													aAdd (aGravaV1B ,{oModelT14:GetValue('T14_IDEDMD')+oModelC9K:GetValue('C9K_ESTABE')+oModelC9K:GetValue('C9K_LOTACA')+oModelC9L:GetValue('C9L_TRABAL'),;
																	oModelV1B:GetValue('V1B_IDCONV')})
												EndIf

											EndIf
										Next //nV1B
									EndIf

								EndIf
							EndIf
						Next //nC9L

					EndIf
				EndIf
			Next //nC9K
			
			/*C9N - Informações de Acordo*/
			If C9N->(MsSeek(xFilial("C9N")+cIDC91+cVersC91 ) )

				For nC9N := 1 To oMdlNvCen:GetModel( 'MODEL_C9N' ):Length()

					oMdlNvCen:GetModel( 'MODEL_C9N' ):GoLine(nC9N)

					If !oMdlNvCen:GetModel( 'MODEL_C9N' ):IsDeleted()

						If !lLaySimplif

							aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
												oModelC9N:GetValue('C9N_TPACOR'),;
												oModelC9N:GetValue('C9N_COMPAC'),;
												oModelC9N:GetValue('C9N_DTEFAC'),;
												oModelC9N:GetValue('C9N_DSC'   ),;
												oModelC9N:GetValue('C9N_REMUNS')})
						Else

							aAdd (aGravaC9N ,{oModelC9N:GetValue('C9N_DTACOR')	,;
												oModelC9N:GetValue('C9N_TPACOR'),;
												oModelC9N:GetValue('C9N_DSC'   ),;
												oModelC9N:GetValue('C9N_REMUNS')})

						EndIf

						/*C9O - Informações do Periodo*/
						For nC9O := 1 to oMdlNvCen:GetModel( "MODEL_C9O" ):Length()

							oMdlNvCen:GetModel( "MODEL_C9O" ):GoLine(nC9O)

							If !oMdlNvCen:GetModel( 'MODEL_C9O' ):IsEmpty()

								If !oMdlNvCen:GetModel( "MODEL_C9O" ):IsDeleted()

									aAdd (aGravaC9O ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR'),;
														oModelC9O:GetValue('C9O_PERREF')})

									/*C9P - Informações do Estab/Lotação*/
									For nC9P := 1 to oMdlNvCen:GetModel( "MODEL_C9P" ):Length()

										oMdlNvCen:GetModel( "MODEL_C9P" ):GoLine(nC9P)

										If !oMdlNvCen:GetModel( 'MODEL_C9P' ):IsEmpty()

											If !oMdlNvCen:GetModel( 'MODEL_C9P' ):IsDeleted()

												aAdd (aGravaC9P ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF'),;
																	oModelC9P:GetValue('C9P_ESTABE'),;
																	oModelC9P:GetValue('C9P_LOTACA')})

												/*C9Q - Informações da Remuneração Trab.*/
												For nC9Q := 1 to oMdlNvCen:GetModel( "MODEL_C9Q" ):Length()

													oMdlNvCen:GetModel( "MODEL_C9Q" ):GoLine(nC9Q)

													If !oMdlNvCen:GetModel( 'MODEL_C9Q' ):IsEmpty()

														If !oMdlNvCen:GetModel( "MODEL_C9Q" ):IsDeleted()

															aAdd (aGravaC9Q ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA'),;
																				oModelC9Q:GetValue('C9Q_TRABAL'),;
																				oModelC9Q:GetValue('C9Q_GRAEXP'),;
																				oModelC9Q:GetValue('C9Q_INDCON')})

															/*C9R - Itens da Remuneração Trab.*/
															For nC9R := 1 to oMdlNvCen:GetModel( "MODEL_C9R" ):Length()

																oMdlNvCen:GetModel( "MODEL_C9R" ):GoLine(nC9R)

																If !oMdlNvCen:GetModel( 'MODEL_C9R' ):IsEmpty()

																	If !oMdlNvCen:GetModel( "MODEL_C9R" ):IsDeleted()

																		If !lLaySimplif

																			aAdd (aGravaC9R ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL'),;
																								oModelC9R:GetValue('C9R_CODRUB'),;
																								oModelC9R:GetValue('C9R_QTDRUB'),;
																								oModelC9R:GetValue('C9R_VLRUNT'),;
																								oModelC9R:GetValue('C9R_FATORR'),;
																								oModelC9R:GetValue('C9R_VLRRUB')})
																		Else

																			aAdd (aGravaC9R ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL'),;
																								oModelC9R:GetValue('C9R_CODRUB'),;
																								oModelC9R:GetValue('C9R_QTDRUB'),;
																								oModelC9R:GetValue('C9R_FATORR'),;
																								oModelC9R:GetValue('C9R_VLRRUB'),;
																								oModelC9R:GetValue('C9R_APURIR')})

																		EndIf

																	EndIf

																EndIf

															Next //nC9R
															
															If !lLaySimplif

																/*V1C - Infos Trab Interm Per Anterior*/
																For nV1C := 1 to oMdlNvCen:GetModel( "MODEL_V1C" ):Length()

																	oMdlNvCen:GetModel( "MODEL_V1C" ):GoLine(nV1C)

																	If !oMdlNvCen:GetModel( 'MODEL_V1C' ):IsEmpty()

																		If !oMdlNvCen:GetModel( "MODEL_V1C" ):IsDeleted()

																			aAdd (aGravaV1C ,{oModelT14:GetValue('T14_IDEDMD')+Dtoc(oModelC9N:GetValue('C9N_DTACOR'))+oModelC9N:GetValue('C9N_TPACOR')+oModelC9O:GetValue('C9O_PERREF')+oModelC9P:GetValue('C9P_ESTABE')+oModelC9P:GetValue('C9P_LOTACA')+oModelC9Q:GetValue('C9Q_TRABAL'),;
																							oModelV1C:GetValue('V1C_IDCONV')})
																		EndIf

																	EndIf

																Next //nV1C

															EndIf

														EndIf
													EndIf
												Next //nC9Q

											EndIf
										EndIf
									Next //nC9P

								EndIf
							EndIf
						Next //nC9O

					EndIf
				Next //nC9N

			EndIf
		EndIf
	Next //nT14

	/*CRN - Proc. Judiciario Remuneração  */
	For nCRN := 1 To oMdlNvCen:GetModel( 'MODEL_CRN' ):Length()

		oMdlNvCen:GetModel( 'MODEL_CRN' ):GoLine(nCRN)

		If !oMdlNvCen:GetModel( 'MODEL_CRN' ):IsDeleted()
			aAdd (aGravaCRN,{oModelCRN:GetValue('CRN_TPTRIB')	,;
								oModelCRN:GetValue('CRN_IDPROC')	,;
								oModelCRN:GetValue('CRN_IDSUSP')	})
		EndIf

	Next

	If lLaySimplif

		For nV6K := 1 To oMdlNvCen:GetModel( 'MODEL_V6K' ):Length()

			oMdlNvCen:GetModel( 'MODEL_V6K' ):GoLine(nV6K)

			If !oMdlNvCen:GetModel( 'MODEL_V6K' ):IsDeleted()
				aAdd (aGravaV6K,{oModelV6K:GetValue('V6K_DIA')})
			EndIf

		Next

	EndIf 

	/*T6W - Remuneração Outras Empresas   */
	For nT6W := 1 To oMdlNvCen:GetModel( 'MODEL_T6W' ):Length()

		oMdlNvCen:GetModel( 'MODEL_T6W' ):GoLine(nT6W)

		If !oMdlNvCen:GetModel( 'MODEL_T6W' ):IsDeleted()

			aAdd (aGravaT6W ,{oModelT6W:GetValue('T6W_TPINSC')	,;
								oModelT6W:GetValue('T6W_NRINSC')	,;
								oModelT6W:GetValue('T6W_CODCAT')	,;
								oModelT6W:GetValue('T6W_VLREMU')	})

		EndIf

	Next

	//Gravação no modelo original
	/*T14 - Informações do Recibo de Pag.*/
	For nT14 := 1 to Len( aGravaT14 )

		oModel:GetModel( 'MODEL_T14' ):LVALID	:= .T.

		If nT14 > 1
			oModel:GetModel( "MODEL_T14" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T14", "T14_IDEDMD", aGravaT14[nT14][1] )
		oModel:LoadValue( "MODEL_T14", "T14_CODCAT", aGravaT14[nT14][2] )

		/*C9K - Informações do Estab/Lotação*/
		nC9KAdd := 1
		For nC9K := 1 to Len( aGravaC9K )
		
			If  aGravaC9K[nC9K][1] == aGravaT14[nT14][1]

				oModel:GetModel( 'MODEL_C9K' ):LVALID := .T.
				
				If nC9KAdd > 1
					oModel:GetModel( "MODEL_C9K" ):AddLine()
				EndIf
				
				oModel:LoadValue( "MODEL_C9K", "C9K_ESTABE", aGravaC9K[nC9K][2] )
				oModel:LoadValue( "MODEL_C9K", "C9K_LOTACA", aGravaC9K[nC9K][3] )
				oModel:LoadValue( "MODEL_C9K", "C9K_QTDDIA", aGravaC9K[nC9K][4] )
				oModel:LoadValue( "MODEL_C9K", "C9K_CODLOT", aGravaC9K[nC9K][5] )
				oModel:LoadValue( "MODEL_C9K", "C9K_TPINSC", aGravaC9K[nC9K][6] )
				oModel:LoadValue( "MODEL_C9K", "C9K_NRINSC", aGravaC9K[nC9K][7] )
				
				/*C9L - Informações da Remuneração Trab.*/
				nC9LAdd := 1
				For nC9L := 1 to Len( aGravaC9L )

					If aGravaC9L[nC9L][1] == (aGravaT14[nT14][1]+aGravaC9K[nT14][2]+aGravaC9K[nT14][3])

						oModel:GetModel( 'MODEL_C9L' ):LVALID := .T.
						
						If nC9LAdd > 1
							oModel:GetModel( "MODEL_C9L" ):AddLine()
						EndIf
						
						oModel:LoadValue( "MODEL_C9L", "C9L_TRABAL", aGravaC9L[nC9L][2] )
						oModel:LoadValue( "MODEL_C9L", "C9L_GRAEXP", aGravaC9L[nC9L][3] )
						oModel:LoadValue( "MODEL_C9L", "C9L_INDCON", aGravaC9L[nC9L][4] )
						oModel:LoadValue( "MODEL_C9L", "C9L_DTRABA", aGravaC9L[nC9L][5] )
						
						/*C9M - Itens da Remuneração Trab.*/
						nC9MAdd := 1
						For nC9M := 1 to Len( aGravaC9M )

							If aGravaC9M[nC9M][1] == (aGravaT14[nT14][1]+aGravaC9K[nT14][2]+aGravaC9K[nT14][3]+aGravaC9L[nC9L][2])

								oModel:GetModel( 'MODEL_C9M' ):LVALID := .T.
								
								If nC9MAdd > 1
									oModel:GetModel( "MODEL_C9M" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_C9M", "C9M_CODRUB",	aGravaC9M[nC9M][2] )
								oModel:LoadValue( "MODEL_C9M", "C9M_QTDRUB",	aGravaC9M[nC9M][3] )
								oModel:LoadValue( "MODEL_C9M", "C9M_VLRUNT",	aGravaC9M[nC9M][4] )
								oModel:LoadValue( "MODEL_C9M", "C9M_FATORR",	aGravaC9M[nC9M][5] )
								oModel:LoadValue( "MODEL_C9M", "C9M_VLRRUB",	aGravaC9M[nC9M][6] )
								oModel:LoadValue( "MODEL_C9M", "C9M_RUBRIC",	aGravaC9M[nC9M][7] )
								oModel:LoadValue( "MODEL_C9M", "C9M_IDTABR",	aGravaC9M[nC9M][8] )

								If lLaySimplif
									oModel:LoadValue( "MODEL_C9M", "C9M_APURIR",	aGravaC9M[nC9M][9] )
								EndIf
								
								nC9MAdd++
								
							EndIf

						Next //nC9M
						
						/*T6Y - Informações de Valores Pagos*/
						nT6YAdd := 1
						For nT6Y := 1 to Len( aGravaT6Y )

							If aGravaT6Y[nT6Y][1] == (aGravaT14[nT14][1]+aGravaC9K[nT14][2]+aGravaC9K[nT14][3]+aGravaC9L[nC9L][2])

								oModel:GetModel( 'MODEL_T6Y' ):LVALID := .T.
								
								If nT6YAdd > 1
									oModel:GetModel( "MODEL_T6Y" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_T6Y", "T6Y_CNPJOP",	aGravaT6Y[nT6Y][2] )
								oModel:LoadValue( "MODEL_T6Y", "T6Y_REGANS",	aGravaT6Y[nT6Y][3] )
								oModel:LoadValue( "MODEL_T6Y", "T6Y_VLPGTI",	aGravaT6Y[nT6Y][4] )
								oModel:LoadValue( "MODEL_T6Y", "T6Y_NOMEVE",	"S1200" )
								
								/*T6Z - Informações dos Dependentes*/
								nT6ZAdd := 1
								For nT6Z := 1 to Len( aGravaT6Z )

									If aGravaT6Z[nT6Z][1] == (aGravaT14[nT14][1]+aGravaC9K[nT14][2]+aGravaC9K[nT14][3]+aGravaC9L[nC9L][2]+aGravaT6Y[nT6Y][2]+aGravaT6Y[nT6Y][3])
										
										oModel:GetModel( 'MODEL_T6Z' ):LVALID := .T.
										
										If nT6ZAdd > 1
											oModel:GetModel( "MODEL_T6Z" ):AddLine()
										EndIf
										
										oModel:LoadValue( "MODEL_T6Z", "T6Z_SEQUEN",	aGravaT6Z[nT6Z][2] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_TPDEP",		aGravaT6Z[nT6Z][3] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_CPFDEP",	aGravaT6Z[nT6Z][4] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMDEP",	aGravaT6Z[nT6Z][5] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_DTNDEP",	aGravaT6Z[nT6Z][6] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_VPGDEP",	aGravaT6Z[nT6Z][7] )
										oModel:LoadValue( "MODEL_T6Z", "T6Z_NOMEVE",	"S1200" )
										
										nT6ZAdd++

									EndIf

								Next //nT6Z

								nT6YAdd++

							EndIf
						Next //nT6Y
						
						If !lLaySimplif

							/*V1B - Infos Trab Interm Per Apuração*/
							nV1BAdd := 1
							For nV1B := 1 to Len( aGravaV1B )

								If aGravaV1B[nV1B][1] == (aGravaT14[nT14][1]+aGravaC9K[nT14][2]+aGravaC9K[nT14][3]+aGravaC9L[nC9L][2])

									oModel:GetModel( 'MODEL_V1B' ):LVALID := .T.
									
									If nV1BAdd > 1
										oModel:GetModel( "MODEL_V1B" ):AddLine()
									EndIf
									
									oModel:LoadValue( "MODEL_V1B", "V1B_IDCONV",	aGravaV1B[nV1B][2] )
									
									nV1BAdd++
									
								EndIf
							Next //nV1B

						EndIf
						
						nC9LAdd++

					EndIf
				Next //nC9L

				nC9KAdd++

			EndIf
		Next //nC9K

	Next //nT14

	/*C9N - Informações de Acordo*/
	For nC9N := 1 to Len( aGravaC9N )

		oModel:GetModel( 'MODEL_C9N' ):LVALID	:= .T.
		
		If nC9N > 1
			oModel:GetModel( "MODEL_C9N" ):AddLine()
		EndIf
		
		If !lLaySimplif
			oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
			oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
			oModel:LoadValue( "MODEL_C9N", "C9N_COMPAC",	aGravaC9N[nC9N][3] )
			oModel:LoadValue( "MODEL_C9N", "C9N_DTEFAC",	aGravaC9N[nC9N][4] )
			oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][5] )
			oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][6] )
		Else
			oModel:LoadValue( "MODEL_C9N", "C9N_DTACOR",	aGravaC9N[nC9N][1] )
			oModel:LoadValue( "MODEL_C9N", "C9N_TPACOR",	aGravaC9N[nC9N][2] )
			oModel:LoadValue( "MODEL_C9N", "C9N_DSC"   ,	aGravaC9N[nC9N][3] )
			oModel:LoadValue( "MODEL_C9N", "C9N_REMUNS",	aGravaC9N[nC9N][4] )
		EndIf
		
		For nC9O := 1 to Len( aGravaC9O )

			If  aGravaC9O[nC9O][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2])

				oModel:GetModel( 'MODEL_C9O' ):LVALID := .T.
				
				If nC9OAdd > 1
					oModel:GetModel( "MODEL_C9O" ):AddLine()
				EndIf
				
				oModel:LoadValue( "MODEL_C9O", "C9O_PERREF", aGravaC9O[nC9O][2] )
				
				/*C9P - Informações do Estab/Lotação*/
				nC9PAdd := 1
				For nC9P := 1 to Len( aGravaC9P )

					If aGravaC9P[nC9P][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2])

						oModel:GetModel( 'MODEL_C9P' ):LVALID := .T.
						
						If nC9PAdd > 1
							oModel:GetModel( "MODEL_C9P" ):AddLine()
						EndIf
						
						oModel:LoadValue( "MODEL_C9P", "C9P_ESTABE",	aGravaC9P[nC9P][2] )
						oModel:LoadValue( "MODEL_C9P", "C9P_LOTACA",	aGravaC9P[nC9P][3] )
						
						/*C9Q - Informações da Remuneração Trab.*/
						nC9QAdd := 1
						For nC9Q := 1 to Len( aGravaC9Q )

							If  aGravaC9Q[nC9Q][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3])

								oModel:GetModel( 'MODEL_C9Q' ):LVALID := .T.
								
								If nC9QAdd > 1
									oModel:GetModel( "MODEL_C9Q" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_C9Q", "C9Q_TRABAL",	aGravaC9Q[nC9Q][2] )
								oModel:LoadValue( "MODEL_C9Q", "C9Q_GRAEXP",	aGravaC9Q[nC9Q][3] )
								oModel:LoadValue( "MODEL_C9Q", "C9Q_INDCON",    aGravaC9Q[nC9Q][4] )
								
								/*C9R - Itens da Remuneração Trab.*/
								nC9RAdd := 1
								For nC9R := 1 to Len( aGravaC9R )

									If  aGravaC9R[nC9R][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2])
										
										oModel:GetModel( 'MODEL_C9R' ):LVALID := .T.
										
										If nC9RAdd > 1
											oModel:GetModel( "MODEL_C9R" ):AddLine()
										EndIf
										
										If !lLaySimplif
											oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
											oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
											oModel:LoadValue( "MODEL_C9R", "C9R_VLRUNT",	aGravaC9R[nC9R][4] )
											oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][5] )
											oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][6] )
										Else
											oModel:LoadValue( "MODEL_C9R", "C9R_CODRUB",	aGravaC9R[nC9R][2] )
											oModel:LoadValue( "MODEL_C9R", "C9R_QTDRUB",	aGravaC9R[nC9R][3] )
											oModel:LoadValue( "MODEL_C9R", "C9R_FATORR",	aGravaC9R[nC9R][4] )
											oModel:LoadValue( "MODEL_C9R", "C9R_VLRRUB",	aGravaC9R[nC9R][5] )
											oModel:LoadValue( "MODEL_C9R", "C9R_APURIR",	aGravaC9R[nC9R][6] )
										EndIf	

										nC9RAdd++
										
									EndIf

								Next //nC9R
								
								If !lLaySimplif

									/*V1C - Infos Trab Interm Per Anterior*/
									nV1CAdd := 1
									For nV1C := 1 to Len( aGravaV1C )

										If  aGravaV1C[nV1C][1] == (Dtoc(aGravaC9N[nC9N][1])+aGravaC9N[nC9N][2]+aGravaC9O[nC9O][2]+aGravaC9P[nC9P][2]+aGravaC9P[nC9P][3]+aGravaC9Q[nC9Q][2])
											
											oModel:GetModel( 'MODEL_V1C' ):LVALID := .T.
											
											If nV1CAdd > 1
												oModel:GetModel( "MODEL_V1C" ):AddLine()
											EndIf
											
											oModel:LoadValue( "MODEL_V1C", "V1C_IDCONV",	aGravaV1C[nV1C][2] )
											
											nV1CAdd++

										EndIf
									Next //nV1C

								EndIf
								
								nC9QAdd++

							EndIf
						Next //nC9Q

					EndIf
				Next //nC9P

				nC9OAdd++

			EndIf

		Next //nC9O

	Next //nC9N

	For nCRN := 1 To Len( aGravaCRN )

		If nCRN > 1
			oModel:GetModel( 'MODEL_CRN' ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_CRN", "CRN_TPTRIB" ,	aGravaCRN[nCRN][1] )
		oModel:LoadValue( "MODEL_CRN", "CRN_IDPROC" ,	aGravaCRN[nCRN][2] )
		oModel:LoadValue( "MODEL_CRN", "CRN_IDSUSP" ,	aGravaCRN[nCRN][3] )

	Next

	If lLaySimplif

		For nV6K := 1 To Len( aGravaV6K )

			If nV6K > 1
				oModel:GetModel( 'MODEL_V6K' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_V6K", "V6K_DIA" ,	aGravaV6K[nV6K][1] )
		Next

	EndIf 

	For nT6W := 1 To Len( aGravaT6W )

		If nT6W > 1
			oModel:GetModel( 'MODEL_T6W' ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T6W", "T6W_TPINSC",	aGravaT6W[nT6W][1] )
		oModel:LoadValue( "MODEL_T6W", "T6W_NRINSC",	aGravaT6W[nT6W][2] )
		oModel:LoadValue( "MODEL_T6W", "T6W_CODCAT",	aGravaT6W[nT6W][3] )
		oModel:LoadValue( "MODEL_T6W", "T6W_VLREMU",	aGravaT6W[nT6W][4] )
		oModel:LoadValue( "MODEL_T6W", "T6W_NOMEVE",	"S1200" )
	Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250AUTI
Monta a View dinâmica para trabalhadores autônomos
@author  Ricardo Lovrenovic Bueno
@since   27/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Function TAF250AUTI( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( "Cadastro de Folha de Pagamento Autônomos" )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 3 )

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

	Local aAnalitico  	:= {}
	Local aRubrica    	:= {}
	Local aSaveLines  	:= FwSaveRows(oModel)
	Local aArea       	:= GetArea()
	Local cMatric     	:= ""
	Local cCodCat     	:= ""
	Local cCodRubr    	:= ""
	Local cIDTabRubr  	:= ""
	Local cTipoEstab  	:= ""
	Local cEstab      	:= ""
	Local cLotacao    	:= ""
	Local cIdeDmd		:= ""
	Local lMv         	:= oModel:GetValue("MODEL_C91", "C91_MV") == "1"
	Local nT14        	:= 1
	Local nC9K        	:= 1
	Local nC9L        	:= 1
	Local nC9M        	:= 1
	Local nC9N        	:= 1
	Local nC9O        	:= 1
	Local nC9P        	:= 1
	Local nC9Q        	:= 1
	Local nC9R        	:= 1
	Local nPosValores 	:= 1
	Local oModelT14   	:= oModel:GetModel("MODEL_T14")

	Default oModel 		:= Nil
	Default lInfoRPT 	:= .F.

	For nT14 := 1 To oModelT14:Length()

		oModelT14:GoLine( nT14 )

		If !oModelT14:IsEmpty() .And. !oModelT14:IsDeleted()
			cCodCat := AllTrim(Posicione("C87", 1, xFilial("C87") + oModelT14:Getvalue("T14_CODCAT"), "C87_CODIGO"))
			cIdeDmd := oModelT14:Getvalue("T14_IDEDMD")

			oModelC9K := oModel:GetModel("MODEL_C9K")

			For nC9K := 1 To oModelC9K:Length()

				oModelC9K:GoLine( nC9K )

				If !oModelC9K:IsEmpty() .And. !oModelC9K:IsDeleted()

					If !Empty( oModelC9K:GetValue("C9K_TPINSC") ) .and. !Empty( oModelC9K:GetValue("C9K_NRINSC") ) .and. !Empty( oModelC9K:GetValue("C9K_CODLOT") )
						cTipoEstab	:=	oModelC9K:GetValue("C9K_TPINSC")
						cEstab		:=	oModelC9K:GetValue("C9K_NRINSC")
						cLotacao	:=	oModelC9K:GetValue("C9K_CODLOT")
					Else
						cTipoEstab	:=	Posicione( "C92", 1, xFilial( "C92" ) + oModelC9K:GetValue("C9K_ESTABE"), "C92_TPINSC" )
						cEstab		:=	Posicione( "C92", 1, xFilial( "C92" ) + oModelC9K:GetValue("C9K_ESTABE"), "C92_NRINSC" )
						cLotacao	:=	Posicione( "C99", 1, xFilial( "C99" ) + oModelC9K:GetValue("C9K_LOTACA"), "C99_CODIGO" )
					EndIf

					oModelC9L := oModel:GetModel("MODEL_C9L")

					For nC9L := 1 To oModelC9L:Length()

						oModelC9L:GoLine( nC9L )

						If !oModelC9L:IsEmpty() .And. !oModelC9L:IsDeleted()

							If Empty(oModelC9L:GetValue("C9L_DTRABA") )
								cMatric := Posicione( "C9V", 1, xFilial( "C9V" ) + oModelC9L:GetValue("C9L_TRABAL"), "C9V_MATRIC" )									
							Else
								cMatric := oModelC9L:GetValue("C9L_DTRABA")
							EndIf

							oModelC9M := oModel:GetModel("MODEL_C9M")

							For nC9M := 1 To oModelC9M:Length()

								oModelC9M:GoLine( nC9M )

								If !oModelC9M:IsEmpty() .And. !oModelC9M:IsDeleted()

									If lInfoRPT
										cIDTabRubr := Posicione( "C8R", 5, xFilial( "C8R" ) + oModelC9M:GetValue("C9M_CODRUB") + "1", "C8R_IDTBRU" )

										If !Empty( oModelC9M:GetValue("C9M_CODRUB") ) .and. !Empty( cIDTabRubr )
											cCodRubr := oModelC9M:GetValue("C9M_CODRUB")
										Else
											cCodRubr	:=	oModelC9M:GetValue("C9M_RUBRIC")
											cIDTabRubr	:=	oModelC9M:GetValue("C9M_IDTABR")
										EndIf

										aRubrica := oReport:GetRubrica( cCodRubr, cIDTabRubr, oModel:GetValue("MODEL_C91","C91_PERAPU" ), lMV )

										aAdd( aAnalitico, Array( 16 ) )
										nPosValores := Len( aAnalitico )

										aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
										aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
										aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
										aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
										aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
										aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
										aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
										aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
										aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
										aAnalitico[nPosValores][ANALITICO_VALOR]				:= oModelC9M:GetValue("C9M_VLRRUB")
										aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)
									EndIf								
								EndIf
							Next nC9M

						EndIf
					Next nC9L

				EndIf
			Next nC9K
			//Parte 1 - Fim

			//Parte 2 - Começo
			oModelC9N := oModel:GetModel("MODEL_C9N")

			For nC9N := 1 To oModelC9N:Length()

				oModelC9N:GoLine(nC9N)

				If !oModelC9N:IsEmpty() .And. !oModelC9N:IsDeleted()

					oModelC9O := oModel:GetModel("MODEL_C9O")

					For nC9O := 1 To oModelC9O:Length()

						oModelC9O:GoLine( nC9O )

						If !oModelC9O:IsEmpty() .And. !oModelC9O:IsDeleted()

							oModelC9P := oModel:GetModel("MODEL_C9P")

							For nC9P := 1 To oModelC9P:Length()

								oModelC9P:GoLine( nC9P )

								If !oModelC9P:IsEmpty() .And. !oModelC9P:IsDeleted()

									If !lMV .Or. Empty(oModelC9P:GetValue("C9P_CODLOT"))
										cTipoEstab	:=	Posicione( "C92", 1, xFilial( "C92" ) + oModelC9P:GetValue("C9P_ESTABE"), "C92_TPINSC" )
										cEstab		:=	Posicione( "C92", 1, xFilial( "C92" ) + oModelC9P:GetValue("C9P_ESTABE"), "C92_NRINSC" )
										cLotacao	:=	Posicione( "C99", 1, xFilial( "C99" ) + oModelC9P:GetValue("C9P_LOTACA"), "C99_CODIGO" )
									Else
										cTipoEstab	:=	oModelC9P:GetValue("C9P_TPINSC")
										cEstab		:=	oModelC9P:GetValue("C9P_NRINSC")
										cLotacao	:=	oModelC9P:GetValue("C9P_CODLOT")
									EndIf		

									oModelC9Q := oModel:GetModel("MODEL_C9Q")

									For nC9Q := 1 To oModelC9Q:Length()

										oModelC9Q:GoLine( nC9Q )

										If !oModelC9Q:IsEmpty() .And. !oModelC9Q:IsDeleted()

											If TafColumnPos( "C9Q_MATRIC" )

												If !lMV .Or. Empty(oModelC9Q:GetValue("C9Q_MATRIC")) 
													cMatric := POSICIONE("C9V",1, xFilial("C9V")+oModelC9Q:GetValue("C9Q_TRABAL"),"C9V_MATRIC")
												Else
													cMatric := oModelC9Q:GetValue("C9Q_MATRIC")
												EndIf

											Else

												If !lMV .Or. Empty(oModelC9Q:GetValue("C9Q_DTRABA"))
													cMatric := POSICIONE("C9V",1, xFilial("C9V")+oModelC9Q:GetValue("C9Q_TRABAL"),"C9V_MATRIC")
												Else
													cMatric := oModelC9Q:GetValue("C9Q_DTRABA")
												EndIf

											EndIf

											oModelC9R := oModel:GetModel("MODEL_C9R")

											For nC9R := 1 To oModelC9R:Length()

												oModelC9R:GoLine(nC9R)

												If !oModelC9R:IsEmpty() .And. !oModelC9R:IsDeleted()

													If lInfoRPT
														If lMV .And. !Empty(oModelC9R:GetValue("C9R_RUBRIC") )
															cCodRubr	:=	oModelC9R:GetValue("C9R_RUBRIC")
															cIDTabRubr	:=	oModelC9R:GetValue("C9R_IDTABR")
														Else
															cCodRubr	:=	oModelC9R:GetValue("C9R_CODRUB")
															cIDTabRubr	:=	Posicione( "C8R", 5, xFilial( "C8R" ) + cCodRubr + "1", "C8R_IDTBRU" )
														EndIf

														aRubrica := oReport:GetRubrica( cCodRubr, cIDTabRubr, oModel:GetValue("MODEL_C91","C91_PERAPU" ), lMV )

														aAdd( aAnalitico, Array( 16 ) )
														nPosValores := Len( aAnalitico )

														aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
														aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
														aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
														aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
														aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
														aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
														aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
														aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
														aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
														aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
														aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
														aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
														aAnalitico[nPosValores][ANALITICO_VALOR]				:= oModelC9R:GetValue("C9R_VLRRUB")
														aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)
													EndIf
												EndIf
											Next nC9R

										EndIf
									Next nC9Q

								EndIf
							Next nC9P

						EndIf
					Next nC9O

				EndIf
			Next nC9N

			//Parte 2 - Fim
		EndIf
	Next nT06

	RestArea(aArea)
	FWRestRows( aSaveLines )

Return aAnalitico

Static Function TAFGatC9PQ()

	Local cRet      := ""
	Local oModel    := FWModelActive()
	Local oModelC9Q := oModel:GetModel("MODEL_C9Q")
	Local oModelC9P := oModel:GetModel("MODEL_C9P")

	cRet := oModelC9Q:GetValue("C9Q_MATRIC") + oModelC9P:GetValue("C9P_CODLOT")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} taf250Leg
Verifica se o registro posicionado é legado (antes da criação do campo
C9N_RELACO).
Além de verificar se o campo existe a rotina verifica se há informação
no campo.

@return lC9NOld - SE .T. o registro posicionado é legado.

@author Evandro dos Santos Oliveira
@since 08/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function taf250Leg(cFil, cId, cVersao, cRecibo)

	Local lC9NOld   := .F.

	Default cFil    := ""
	Default cId     := ""
	Default cVersao := ""
	Default cRecibo := ""

	If TafColumnPos( "C9N_RELACO" )

		C9N->(dbSetOrder(1))
		If C9N->(MsSeek(cFil + cId + cVersao + cRecibo))

			If Empty(AllTrim(C9N->C9N_RELACO))

				If FWIsInCallStack("TAF250GRV")
					//Se o campo existir e for de procedencia de integração, o relacionamento deve 
					//Seguir no novo formato, mesmo se o campo C9V_RELACO for vazio.
					lC9NOld	:= .F.
				Else 
					lC9NOld	:= .T.
				EndIf 

			EndIf 

		EndIf

	Else

		lC9NOld	:= .T.
	
	EndIf 

Return lC9NOld
//---------------------------------------------------------------------
/*/{Protheus.doc} lVldDiaTrb

@description	Valida o dia trabalhado para ser entre 1 e 0
@author			José Riquelmo Gomes da Silva	
@since			05/03/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function lVldDiaTrb(oModel)

	Local oMdlV6K := oModel:GetModel("MODEL_V6K")
	Local nDia    := Val(oMdlV6K:GetValue("MODEL_V6K", "V6K_DIA" ))
	Local lRet    := .T.

	If !(nDia >= 1 .AND. nDia <= 31)
		Help( ,, STR0077,, STR0078, 1, 0 ) //"Atenção" # "Dia permitido entre 1 à 31" 
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoCompl
@type			function
@description	Função responsável por verificar se o trabalhador já possui 
				S-2200 e/ou S-2300 ativo, transmitido e protocolado
@author			Melkz Siqueira
@since			28/07/2022
@version		1.0
@param			cCPF		-	CPF do Trabalhador
@param			aEvents		-	Array de eventos a serem considerados na regra
@param			lAct23		-	Caso tenha um s-2300 ativo.
@return			lRet		-	Indica se o trabalhador não possui S-2200 e/ou S-2200
/*/
//---------------------------------------------------------------------
Static Function InfoCompl(cCPF as character, aEvents as array, lAct23 as logical )

	Local cAlias		as character
	Local cINFilMV		as character
	Local cNomEve		as character
	Local lRet			as logical

	Default cCPF		:= ""
	Default lAct23 		:= .F.
	Default aEvents		:= {"S-2200", "S-2300"}
	
	cINFilMV	:= ""
	cNomEve		:= StrTran(ArrTokStr(aEvents), "-")
	cAlias		:= GetNextAlias()
	cINFilMV 	:= TAFCacheFil("C9V")
	lRet		:= .F.
	
	BeginSQL Alias cAlias

		SELECT C9V.C9V_ID, C9V.C9V_NOMEVE, C9V.C9V_STATUS, C9V.C9V_PROTUL
			FROM %table:C9V% C9V
			WHERE C9V.%notdel% 
				AND C9V.C9V_FILIAL IN (
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cINFilMV% FILIAIS
				)
				AND C9V.C9V_CPF = %exp:cCPF%
				AND C9V.C9V_ATIVO = '1'
				AND C9V.%notdel%

	EndSQL

	(cAlias)->(DBGoTop())

	While !(cAlias)->(EOF())
		
		If AllTrim((cAlias)->C9V_NOMEVE) $ "S2300"
			lAct23 := .F.
			If (cAlias)->C9V_STATUS $ "4|6"
				DBSelectArea("T92")
				T92->( DBSetOrder( 3 ) )                                                                                                                
				If T92->( MSSeek( xFilial("T92") + (cAlias)->C9V_ID + "1"))
					If T92->T92_STATUS $ '4|6'
						lAct23 := .F.
					Else
						lAct23 := .T.
					EndIf
				Else
					lAct23 := .T.
				EndIf
			EndIf
		EndIf
		
		If AllTrim((cAlias)->C9V_NOMEVE) $ cNomEve .And. (cAlias)->C9V_STATUS == "4" .And.;
			AllTrim((cAlias)->C9V_PROTUL) != ""
			lRet := .F.

			Exit
		EndIf

		If !lRet .And. AllTrim((cAlias)->C9V_NOMEVE) == "TAUTO"
			lRet := .T.
		EndIf

		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveAltRPT
@type			static function
@description	Armazena os valores da chave do relatório armazenado na V3N antes de 
				serem alterados para que seja possível excluir as informações obsoletas
@author			Melkz Siqueira
@since			31/08/2022
@version		1.0
@param			aAltRPT - Array contendo a chave da V3N antes de ser alterada
/*/
//---------------------------------------------------------------------
Static Function SaveAltRPT()

	Local aAltRPT	as array
	Local cIndApu	as character
	Local cPeriodo	as character
	Local cCPF		as character
	Local cNome		as character

	aAltRPT		:= {}
	cIndApu		:= C91->C91_INDAPU
	cPeriodo	:= C91->C91_PERAPU
	cCPF		:= ""
	cNome		:= ""

	If C91->C91_MV == "1" .Or. Empty(C91->C91_TRABAL)
		cCPF	:= C91->C91_CPF
		cNome 	:= C91->C91_NOME
	ElseIf TafColumnPos("C91_ORIEVE") .And. C91->C91_ORIEVE == "S2190"
		cCPF := GetADVFVal("T3A", "T3A_CPF", xFilial("T3A") + C91->C91_TRABAL + "1", 3, "", .T.)
	Else
		cCPF 	:= GetADVFVal("C9V", "C9V_CPF", xFilial("C9V") + C91->C91_TRABAL + "1", 2, "", .T.)
		cNome 	:= GetADVFVal("C9V", "C9V_NOME", xFilial("C9V") + C91->C91_TRABAL + "1", 2, "", .T.)
	EndIf

	aAltRPT := {cIndApu, cPeriodo, cCPF, cNome}

Return aAltRPT

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoRPTObj
@type			static function
@description	Instancia o objeto oInfoRPT
@author			Melkz Siqueira
@since			16/08/2022
@version		1.0
@param			cIndApu		-	Indicativo de apuração
@param			cPerApu		-	Período de apuração
@param			cCPF		-	CPF do trabalhador
@param			cNome		-	Nome do trabalhador
@param			aAnalitico	-	Array com os dados a serem gravados na V3N
@param			cRecibo		-	Recibo
@param			oInfoRPT	-	Objeto oInfoRPT não instânciado
/*/
//---------------------------------------------------------------------
Static Function InfoRPTObj(cIndApu as character, cPerApu as character, cCPF as character,; 
					cNome as character, aAnalitico as array, cRecibo as character, oInfoRPT as object)

	Default aAnalitico	:= {}
	Default cIndApu		:= ""
	Default cPerApu		:= ""
	Default cCPF		:= ""
	Default cNome		:= ""
	Default cRecibo		:= ""
	Default oInfoRPT	:= Nil
		
	oReport		:= IIf(oReport == Nil, TAFSocialReport():New(), oReport)
	oInfoRPT	:= oReport:oVOReport

	oInfoRPT:SetIndApu(AllTrim(cIndApu))
	oInfoRPT:SetPeriodo(AllTrim(cPerApu))
	oInfoRPT:SetCPF(AllTrim(cCPF))
	oInfoRPT:SetNome(AllTrim(cNome))
	oInfoRPT:SetAnalitico(aAnalitico)
	oInfoRPT:SetRecibo(AllTrim(cRecibo))

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraComplCont
@type			static function
@description	Valida regra para geração de tag Infocomplcont
@author			Alexandre de Lima
@since			16/08/2022
@version		1.0
@param			lMatC9L		-	indica se matricula do grupo remunPerApur está preenchida
@param			lMatC9L		-	indica se matricula do grupo remunPerAnt está preenchida
@param			lAct23		-	.T. para S-2300 ativo na base e transmitido para o ret
@param			cCodCat		-	Codigo de categoria do trabalhador
@Return			lGera		-	Retorna true para obrigatoriedade da tag
/*/
//---------------------------------------------------------------------
Static Function GeraComplCont( lMatC9L as logical, lMatC9Q as logical, lAct23 as logical, cCodCat as character)

	Local lGera as logical

	lGera := .T.

	If ( AllTrim(cCodCat) $ "304|305|901|902|903|904|" .OR. SubStr( AllTrim(cCodCat),1,1 ) $ "2|4|5|7|") .AND. !lAct23 .AND. ( lMatC9L .OR. lMatC9Q ) 
		lGera := .T.
	Else
		lGera := .F.
	EndIf

Return lGera

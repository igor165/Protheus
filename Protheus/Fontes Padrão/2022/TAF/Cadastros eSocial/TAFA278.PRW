#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA278.CH"

Static lLaySimplif	:= Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA278
Cadastro MVC de Cadastramento Admissão do Trabalhador - 2200

@author Felipe C. Seolin / Rodrigo Aguilar
@since 25/10/2013
@version 1.0    
/*/
//---------------------------------------------------------------------
Function TAFA278()

	Private oBrw := FwMBrowse():New()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funçao generica MVC com as opcoes de menu

@Return aRotina - Array com as opções do Menu

@author Felipe C. Seolin / Rodrigo Aguilar
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TAF421XMLVLD(1)"	, "1" } )
	Aadd( aFuncao, { "" , "xCarrHisAlt" 	, "3" } )
	Aadd( aFuncao, { "" , "ExcXmlLote" 		, "5" } )

	//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0002 Action 'xCarrVisul' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA278" , , aFuncao ) 
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC9V 	:= FwFormStruct( 1, "C9V" )
	Local oStruC9Y 	:= FwFormStruct( 1, "C9Y" )
	Local oStruCUP 	:= FwFormStruct( 1, "CUP" )
	Local oStruCRQ 	:= FwFormStruct( 1, "CRQ" )
	Local oStruT3L 	:= FwFormStruct( 1, "T3L" )
	Local oStruT80 	:= FwFormStruct( 1, "T80" )
	Local oStruT90 	:= FwFormStruct( 1, "T90" )
	Local oStruV87 	:= IIF( TAFAlsInDic("V87"), FwFormStruct( 1, "V87"), Nil)
	Local oModel	:= MpFormModel():New( "TAFA278",,,{ |oModel| SaveModel( oModel ) } ) 
	LocaL nICRQ    	:= 0
	LocaL nIT3L    	:= 0
	LocaL nIT80    	:= 0

	Private lFirstOpe  := .T. 

	//Indica se o Model devera ser validado quando realizada operações
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If FindFunction("TAFSetEpoch")
		TAFSetEpoch()
	EndIf

	If lVldModel

		oStruC9V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruC9Y:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCUP:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCRQ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT3L:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT80:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT90:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })

	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruC9V:SetProperty( "C9V_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//C9V - Informações genéricas do funcionário
	oModel:AddFields( "MODEL_C9V", /*cOwner*/, oStruC9V )

	//CUP - Cadastro Inicial do Vínculo
	oModel:AddFields( "MODEL_CUP", "MODEL_C9V", oStruCUP )

	//C9Y - Cadastro de Dependentes
	oModel:AddGrid( "MODEL_C9Y", "MODEL_C9V", oStruC9Y )
	oModel:GetModel( "MODEL_C9Y" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_C9Y" ):SetUniqueLine( { "C9Y_TPDEP","C9Y_NOMDEP","C9Y_DTNASC"} )

	//CRQ - Informações do horário contratual 
	oModel:AddGrid( "MODEL_CRQ", "MODEL_CUP", oStruCRQ )
	oModel:GetModel( "MODEL_CRQ" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_CRQ" ):SetUniqueLine( { "CRQ_CODDIA","CRQ_CODHOR" } )

	//T3L - Identificação do trabalhador substituído
	oModel:AddGrid( "MODEL_T3L", "MODEL_CUP", oStruT3L )
	oModel:GetModel( "MODEL_T3L" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3L" ):SetUniqueLine( { "T3L_CPF" } )

	//T80 - Filiação Sindical do Trabalhador
	oModel:AddGrid( "MODEL_T80", "MODEL_CUP", oStruT80 )
	oModel:GetModel( "MODEL_T80" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T80" ):SetUniqueLine( { "T80_CNPJSD" } )
	oModel:GetModel( "MODEL_T80" ):SetMaxLine(2)

	//T90 - Observações do contrato de trabalho
	oModel:AddGrid( "MODEL_T90", "MODEL_CUP", oStruT90 )
	oModel:GetModel( "MODEL_T90" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T90" ):SetUniqueLine( { "T90_CODOBS" } )
	oModel:GetModel( "MODEL_T90" ):SetMaxLine(99)

	If lLaySimplif == Nil
		TAF278Lay() //Inicializa a variável static lLaySimplif
	EndIf

	If lLaySimplif

		If oStruV87 != Nil //V87 - Cadastro Código de Treinamento			
			oModel:AddGrid( "MODEL_V87", "MODEL_CUP", oStruV87 )
			oModel:GetModel( "MODEL_V87" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V87" ):SetUniqueLine( { "V87_CODTRE" } )
			oModel:GetModel( "MODEL_V87" ):SetMaxLine(99)	
		EndIf

		oStruCUP:SetProperty( 'CUP_DTFGTS', MODEL_FIELD_OBRIGAT , .F.  )
		oStruCUP:SetProperty( 'CUP_UNSLFX', MODEL_FIELD_OBRIGAT , .F.  )
		oStruCUP:SetProperty( 'CUP_TPCONT', MODEL_FIELD_OBRIGAT , .F.  )
		oStruC9V:SetProperty( 'C9V_PRIEMP', MODEL_FIELD_OBRIGAT , .F.  )
		oStruC9V:SetProperty( 'C9V_CODMUN', MODEL_FIELD_OBRIGAT , .F.  )
		oStruC9V:SetProperty( 'C9V_NOMMAE', MODEL_FIELD_OBRIGAT , .F.  )
		oStruC9V:SetProperty( 'C9V_NOMPAI', MODEL_FIELD_OBRIGAT , .F.  )
		oStruC9V:SetProperty( 'C9V_NIS'	  , MODEL_FIELD_OBRIGAT , .F.  )
			
	Else
		oStruC9Y:RemoveField( "C9Y_SEXDEP" )	
	EndIf 

	oStruC9V:SetProperty( 'C9V_NOME',  MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_SEXO',  MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_RCCOR', MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_GRINST',MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_DTNASC',MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_CODPAI',MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_PAINAC',MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_PAIS',  MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_APOSEN',MODEL_FIELD_OBRIGAT , .F.  )

	If TAFColumnPos( "C9V_CATCI" )
		oStruC9V:SetProperty( 'C9V_CATCI', MODEL_FIELD_OBRIGAT , .F.  )
	EndIf

	oStruCUP:SetProperty( 'CUP_VLSLFX',MODEL_FIELD_OBRIGAT , .F.  )	

	/*-----------------------------------------------------------------------------------
	Abaixo realiza-se a amarração das tabelas, no caso deste cadastro a tabela 
	CUP NÃO é filha da tabela C9V, porém por questões de normalização as informações
	foram desmembradas em duas tabelas, o mesmo ocorre para as tabelas T3L e CRQ, que
	pelo Layout são filhas da CUP mas no TAF ficam como filhas da tabela C9V.
	-------------------------------------------------------------------------------------*/
	oModel:SetRelation( "MODEL_C9Y",{ { "C9Y_FILIAL", "xFilial('C9Y')" }, { "C9Y_ID", "C9V_ID" }, { "C9Y_VERSAO", "C9V_VERSAO" }, { "C9Y_NOMEVE", "C9V_NOMEVE" } },C9Y->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_CUP",{ { "CUP_FILIAL", "xFilial('CUP')" }, { "CUP_ID", "C9V_ID" }, { "CUP_VERSAO", "C9V_VERSAO" }, { "CUP_NOMEVE", "C9V_NOMEVE" } },CUP->( IndexKey( 4 ) ) )

	IIF(FWSIXUtil():ExistIndex( "CRQ", "CRQI4",.T.),nICRQ := 4,nICRQ := 3)
	oModel:SetRelation( "MODEL_CRQ",{ { "CRQ_FILIAL", "xFilial('CRQ')" }, { "CRQ_ID", "C9V_ID" }, { "CRQ_VERSAO", "C9V_VERSAO" }, { "CRQ_NOMEVE", "C9V_NOMEVE" } },CRQ->( IndexKey( nICRQ ) ) )

	IIF(FWSIXUtil():ExistIndex( "T3L", "T3LI4",.T.),nIT3L := 4,nIT3L := 3)
	oModel:SetRelation( "MODEL_T3L",{ { "T3L_FILIAL", "xFilial('T3L')" }, { "T3L_ID", "C9V_ID" }, { "T3L_VERSAO", "C9V_VERSAO" }, { "T3L_NOMEVE", "C9V_NOMEVE" } },T3L->( IndexKey( nIT3L ) ) )

	IIF(FWSIXUtil():ExistIndex( "T80", "T80I2", .T.),nIT80 := 2,nIT80 := 1)
	oModel:SetRelation( "MODEL_T80",{ { "T80_FILIAL", "xFilial('T80')" }, { "T80_ID", "C9V_ID" }, { "T80_VERSAO", "C9V_VERSAO" }, { "T80_NOMEVE", "C9V_NOMEVE" } },T80->( IndexKey( nIT80 ) ) )
	oModel:SetRelation( "MODEL_T90",{ { "T90_FILIAL", "xFilial('T90')" }, { "T90_ID", "C9V_ID" }, { "T90_VERSAO", "C9V_VERSAO" }, { "T90_NOMEVE", "C9V_NOMEVE" } },T90->( IndexKey( 1 ) ) )

	If lLaySimplif .And. oStruV87 != Nil
		oModel:SetRelation( "MODEL_V87",{ { "V87_FILIAL", "xFilial('V87')" }, { "V87_ID", "C9V_ID" }, { "V87_VERSAO", "C9V_VERSAO" }, { "V87_NOMEVE", "C9V_NOMEVE" } },V87->( IndexKey( 1 ) ) )
	EndIf

	//Define a chave única de gravação das informações
	oModel:GetModel("MODEL_C9V"):SetPrimaryKey({ "C9V_CPF", "C9V_MATRIC", "C9V_NOMEVE" })


Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local nI		:= 0
	Local aCmpGrp	:= {}
	Local cCmpFil	:= ""
	Local cGrpVinc	:= ""
	Local cGrpVinc1	:= ""
	Local cGrpVinc2	:= ""
	Local cGrpVinc3	:= ""
	Local cGrpVinc4	:= ""
	Local cGrpVinc5	:= ""
	Local cGrpVinc6	:= ""
	Local cGrpVinc7 := ""
	Local cGrpVinc8 := ""

	Local cGrpCelet		:= ""
	Local cGrpCelet1	:= ""
	Local cGrpCelet2	:= ""
	Local cGrpCelet3	:= ""
	Local cGrpCelet4	:= ""
	Local cGrpCelet5	:= ""
	Local cGrpCelet6	:= ""

	Local cGrpContr		:= ""
	Local cGrpContr1	:= ""
	Local cGrpContr2	:= ""
	Local cGrpContr3	:= ""
	Local cGrpContr4	:= ""
	Local cGrpContr5	:= ""
	Local cGrpContr6	:= ""
	Local cGrpContr7	:= ""
	Local cGrpContr8	:= ""
	Local cGrpTra1		:= ""
	Local cGrpTra2		:= ""
	Local cGrpTra3		:= ""
	Local cGrpTra4		:= ""
	Local cGrpTra5		:= ""
	Local cGrpTra6		:= ""
	Local cGrpTra7		:= ""
	Local cGrpTra8		:= ""
	Local cGrpTra9		:= "" 
	Local cGrpTra10		:= ""
	Local cGrpTra11		:= ""

	Local oModel		:= FWLoadModel( "TAFA278" )
	Local oView			:= FWFormView():New()
	Local oStruC9Y		:= FWFormStruct( 2, "C9Y" )
	Local oStruCUP		:= FWFormStruct( 2, "CUP" )
	Local oStruCRQ		:= FWFormStruct( 2, "CRQ" )
	Local oStruT3L		:= FWFormStruct( 2, "T3L" )
	Local oStruT80		:= FWFormStruct( 2, "T80" )
	Local oStruT90		:= FWFormStruct( 2, "T90" )
	Local oStruV87		:= IIF( TAFAlsInDic("V87"), FWFormStruct( 2, "V87"), Nil) 
	Local oStruC9Va		:= Nil
	Local oStruC9Vb		:= Nil
	Local oStruC9Vc		:= Nil
	Local oStruC9Vd		:= Nil
	Local oStruC9Ve		:= Nil
	Local oStruC9Vf		:= Nil
	Local oStruC9Vg		:= Nil
	Local oStruCUPa		:= Nil
	Local oStruCUPb		:= Nil
	Local oStruCUPc		:= Nil
	Local oStruCUPd		:= Nil

	//Seto o Model que sera utilizado no processamento
	oView:SetModel( oModel )

	oStruCUP:RemoveField("CUP_NOMEVE")
	oStruCRQ:RemoveField("CRQ_NOMEVE")
	oStruT3L:RemoveField("T3L_NOMEVE")
	oStruC9Y:RemoveField("C9Y_NOMEVE")
	oStruT80:RemoveField("T80_NOMEVE")
	oStruT90:RemoveField("T90_NOMEVE")

	If lLaySimplif
		IIF( oStruV87 != Nil, oStruV87:RemoveField("V87_NOMEVE"), Nil)
		If !Empty(CUP->CUP_CODTRE) .AND. INCLUI
			oStruCUP:RemoveField("CUP_CODTRE")
			oStruCUP:RemoveField("CUP_DSCTRE")
		EndIf
	EndIf

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/

	If lLaySimplif == Nil
		TAF278Lay() //Inicializa a variável static lLaySimplif
	EndIf

	If !lLaySimplif

		cGrpTra1  := "C9V_ID|C9V_VERSAO|C9V_VERANT|C9V_PROTPN|C9V_EVENTO|C9V_ATIVO|C9V_CPF|C9V_NIS|C9V_NOME|C9V_NOMSOC|C9V_SEXO|C9V_RCCOR|C9V_ESTCIV|C9V_GRINST|C9V_DGRINS|C9V_PRIEMP|"
		cGrpTra2  := "C9V_DTNASC|C9V_CODPAI|C9V_DCODPA|C9V_CODUF|C9V_DCODUF|C9V_CODMUN|C9V_DCODMU|C9V_PAINAC|C9V_DPAINA|C9V_NOMMAE|C9V_NOMPAI|"
		cGrpTra3  := "C9V_NRCTPS|C9V_SERCTP|C9V_UFCTPS|C9V_DUFCTP|"
		cGrpTra4  := "C9V_NRRIC|C9V_OREMRI|C9V_DTEXRI|"
		cGrpTra5  := "C9V_NRRG|C9V_OREMRG|C9V_DTEMRG|"
		cGrpTra6  := "C9V_NRRNE|C9V_OREMRN|C9V_DTEMRN|"
		cGrpTra7  := "C9V_NUMOC|C9V_OREMOC|C9V_DTEXOC|C9V_DTVLOC|"
		cGrpTra8  := "C9V_NRCNH|C9V_DTEXCN|C9V_UFCNH|C9V_DUFCN|C9V_DTVLCN|C9V_DTPCNH|C9V_CATCNH|"
		cGrpTra9  := "C9V_PAIS|C9V_DPAIS|C9V_UF|C9V_DUF|C9V_MUN|C9V_DMUN|C9V_NOMCID|C9V_TPLOGR|C9V_DTPLOG|C9V_LOGRAD|C9V_NRLOG|C9V_COMLOG|C9V_BAIRRO|C9V_CEP|"
		cGrpTra10 := "C9V_APOSEN|"

		cCmpFil   := cGrpTra1 + cGrpTra2 + cGrpTra3 + cGrpTra4 + cGrpTra5 + cGrpTra6 + cGrpTra7 + cGrpTra8 + cGrpTra9 + cGrpTra10

	Else
		cGrpTra1  := "C9V_ID|C9V_VERSAO|C9V_VERANT|C9V_PROTPN|C9V_EVENTO|C9V_ATIVO|C9V_CPF|C9V_NOME|C9V_NOMSOC|C9V_SEXO|C9V_RCCOR|C9V_ESTCIV|C9V_GRINST|C9V_DGRINS|"
		cGrpTra2  := "C9V_DTNASC|C9V_CODPAI|C9V_DCODPA|C9V_PAINAC|C9V_DPAINA|"
		cGrpTra9  := "C9V_PAIS|C9V_DPAIS|C9V_UF|C9V_DUF|C9V_MUN|C9V_DMUN|C9V_NOMCID|C9V_TPLOGR|C9V_DTPLOG|C9V_LOGRAD|C9V_NRLOG|C9V_COMLOG|C9V_BAIRRO|C9V_CEP|"
		cGrpTra11 := "C9V_TPRESI|C9V_CNDING|"

		cCmpFil   := cGrpTra1 + cGrpTra2  + cGrpTra9 + cGrpTra11

	EndIf 
	

	oStruC9Va := FwFormStruct( 2, "C9V",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes do Trabalhador

	If !lLaySimplif
		cCmpFil   := "C9V_DTCHEG|C9V_CCTRAE|C9V_DCONTE|C9V_CASBRA|C9V_FILBRA|"
	EndIf 
	oStruC9Vb := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Trabalhador Estrangeiro


	cCmpFil   := "C9V_DEFINT|C9V_DEFFIS|C9V_DEFMOT|C9V_DEFVIS|C9V_DEFAUD|C9V_REABIL|C9V_INFCOT|C9V_DEFMEN|C9V_OBSDEF|"
	oStruC9Vc := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Deficiencias


	If TafColumnPos("C9V_DDIFPR")
		If !lLaySimplif
			cCmpFil   := "C9V_DDIFPR|C9V_DDDFPR|C9V_FONPRC|C9V_DDIFAL|C9V_DDDFAL|C9V_FONALT|C9V_EMAILP|C9V_EMAILA|"
		Else 
			cCmpFil   := "C9V_DDIFPR|C9V_DDDFPR|C9V_FONPRC|C9V_EMAILP|"
		EndIf 
	Else
		If !lLaySimplif
			cCmpFil   := "C9V_DDDFPR|C9V_FONPRC|C9V_DDDFAL|C9V_FONALT|C9V_EMAILP|C9V_EMAILA|"
		Else 
			cCmpFil   := "C9V_DDDFPR|C9V_FONPRC|C9V_EMAILP|"
		EndIf 
	EndIf

	oStruC9Vd := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações de Contato

	If TafColumnPos("C9V_DDIFPR")
		oStruC9Vd:SetProperty( "C9V_DDIFPR", MVC_VIEW_ORDEM	, "71"	)
	EndIf
	If !lLaySimplif
		oStruC9Vd:SetProperty( "C9V_DDIFAL", MVC_VIEW_ORDEM	, "73"	)
	EndIf

	cCmpFil   := "C9V_PROTUL|"
	oStruC9Ve := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

	If TafColumnPos("C9V_DTRANS")
		cCmpFil   := "C9V_DINSIS|C9V_DTRANS|C9V_HTRANS|C9V_DTRECP|C9V_HRRECP|"
		oStruC9Vg := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC9Ve,"C9V")
	EndIf
	/*-----------------------------------------------------------------------------------
								Estrutura da View do Vínculo
	-------------------------------------------------------------------------------------*/
	cGrpVinc  := "C9V_MATRIC|C9V_CADINI|"
	oStruC9Vf := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cGrpVinc } ) //Campo Matrícula do Trabalhador

	cGrpVinc2 := "CUP_TPREGT|CUP_TPREGP|"

	If TafColumnPos("CUP_INSANT")
		cGrpVinc3 := "CUP_INSANT|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|"
	Else
		cGrpVinc3 := "CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|"
	EndIf

	cGrpVinc4 := "CUP_DTINIA|CUP_MOTVAF|CUP_DMOTVA|"
	cGrpVinc5 := "CUP_DTDESL|"
	cGrpVinc6 := "CUP_CPFSUB|CUP_MATRAN|CUP_DTTRAN|"
	cGrpVinc7 := "CUP_CPFANT|CUP_MATOLD|CUP_DATCPF|CUP_OBSCPF|"

	If !lLaySimplif
		cGrpVinc1 += cGrpVinc2 + cGrpVinc3 + cGrpVinc4 + cGrpVinc5 + cGrpVinc6 + cGrpVinc7
	Else
		cGrpVinc8 := "CUP_DCESSA|"
		cGrpVinc1 += cGrpVinc2 + cGrpVinc3 + cGrpVinc4 + cGrpVinc5 + cGrpVinc6 + cGrpVinc7 + cGrpVinc8
	EndIf 

	oStruCUPa := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpVinc1 } ) //Campos do folder Informações de Vínculo

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador Celetista
	-------------------------------------------------------------------------------------*/

	cGrpCelet1 := "CUP_DTADMI|CUP_TPADMI|CUP_INDADM|CUP_TPREGJ|CUP_NATATV|CUP_DATAB|CUP_CNPJCP|"
		
	If !lLaySimplif	
		cGrpCelet2 := "CUP_FGTSOP|CUP_DTFGTS|"
		cGrpCelet3 := "CUP_MOTCON|CUP_JUSHIP|CUP_TPINCL|"
		cGrpCelet4 := "CUP_TPINST|CUP_NRINST|"
	Else
		cGrpCelet3 := "CUP_MOTCON|CUP_JUSHIP|CUP_NRPROC|"
		cGrpCelet2 := "CUP_DTFGTS|"
	EndIf 

	cGrpCelet5 := "CUP_TPINTT|CUP_NRINTT|"
	cGrpCelet6 := "CUP_TPINAP|CUP_NRINAP|"

	cGrpCelet += cGrpCelet1 + cGrpCelet2 + cGrpCelet3 + cGrpCelet4 + cGrpCelet5 + cGrpCelet6
	oStruCUPb := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpCelet } ) //Campos do folder Trabalhador Celetista

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador Estatutário
	-------------------------------------------------------------------------------------*/
	If lLaySimplif  .and. TafColumnPos("CUP_TERGPS") .and. TafColumnPos("CUP_ABOPER") .and. TafColumnPos("CUP_DTABON")
		cCmpFil   := "CUP_TIPPRO|CUP_DTEXER|CUP_TPLASM|CUP_TERGPS|CUP_ABOPER|CUP_DTABON|"
	Else
		cCmpFil   := "CUP_INDPRO|CUP_TIPPRO|CUP_DTNOME|CUP_DTPOSS|CUP_DTEXER|CUP_TPLASM|CUP_NPROJE|CUP_DNPRJE|"	
	EndIf 
	oStruCUPc := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Trabalhador Estatutário

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Contrato de Trabalho
	-------------------------------------------------------------------------------------*/
	If lLaySimplif
		cGrpContr1 := "CUP_CODCAT|CUP_DCODCA|CUP_NMCARG|CUP_CBOCAR|CUP_DTINCA|CUP_NMFUNC|CUP_CBOFUN|CUP_ACCARG|CUP_DCBOCG|CUP_DCBOFC|"
		cGrpContr2 := "CUP_VLSLFX|CUP_UNSLFX|CUP_DSCSAL|"
	Else
		cGrpContr1 := "CUP_CODCGO|CUP_DCODCG|CUP_CODFUN|CUP_DCODFU|CUP_CODCAT|CUP_DCODCA|CUP_CODCAR|CUP_DESCAR|CUP_DTINGC|"
		cGrpContr2 := "CUP_VLSLFX|CUP_UNSLFX|CUP_DESSVR|"
	EndIf 

	If TafColumnPos("CUP_OBJDET")
		cGrpContr3 := "CUP_TPCONT|CUP_DTTERM|CUP_CLAUAS|CUP_OBJDET|"
	EndIf

	If !lLaySimplif
		cGrpContr4 := "CUP_TPINSC|CUP_NRINSC|CUP_DESLOT|"
	Else
		cGrpContr4 := "CUP_TPINSC|CUP_NRINSC|"
	EndIf 

	cGrpContr5 := "CUP_TPLOGD|CUP_DSCTPL|CUP_DELOGD|CUP_NRLOGD|CUP_COMLGD|CUP_BAIRTD|CUP_CEPLTD|CUP_CMUNTD|CUP_DSCMTD|CUP_UFTRBD|CUP_DUFTRD|"

	If lLaySimplif .AND. TAFColumnPos("CUP_HRSNOT") .AND. TAFColumnPos("CUP_DSCJOR")  
		cGrpContr6 := "CUP_QTDHJS|CUP_TPJORN|CUP_TMPARC|CUP_DSCJOR|CUP_HRSNOT|"
	Else
		cGrpContr6 := "CUP_QTDHJS|CUP_TPJORN|CUP_DTPJOR|CUP_TMPARC|"
	EndIf 

	cGrpContr7 := "CUP_ALVJUD|CUP_DALVJU|"

	If lLaySimplif .AND. !Empty(CUP->CUP_CODTRE) .AND. !INCLUI
		cGrpContr8 := "CUP_CODTRE|CUP_DSCTRE|"
	EndIf  

	If !lLaySimplif
		cGrpContr += cGrpContr1 + cGrpContr2 + cGrpContr3 + cGrpContr4 + cGrpContr5 + cGrpContr6 + cGrpContr7
	Else 
		cGrpContr += cGrpContr1 + cGrpContr2 + cGrpContr3 + cGrpContr4 + cGrpContr5 + cGrpContr6 + cGrpContr7 + cGrpContr8
	EndIf 

	oStruCUPd := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpContr } ) //Campos do folder Contrato de Trabalho

	If lLaySimplif
		
		oStruCUPd:SetProperty( "CUP_NMCARG", MVC_VIEW_ORDEM, "13" )
		oStruCUPd:SetProperty( "CUP_CBOCAR", MVC_VIEW_ORDEM, "14" )	
		oStruCUPd:SetProperty( "CUP_DCBOCG", MVC_VIEW_ORDEM, "15" )
		oStruCUPd:SetProperty( "CUP_DTINCA", MVC_VIEW_ORDEM, "16" )
		oStruCUPd:SetProperty( "CUP_NMFUNC", MVC_VIEW_ORDEM, "17" )
		oStruCUPd:SetProperty( "CUP_CBOFUN", MVC_VIEW_ORDEM, "18" )
		oStruCUPd:SetProperty( "CUP_DCBOFC", MVC_VIEW_ORDEM, "19" )
		oStruCUPd:SetProperty( "CUP_ACCARG", MVC_VIEW_ORDEM, "20" )
		oStruCUPd:SetProperty( "CUP_CODCAT", MVC_VIEW_ORDEM, "21" )
		oStruCUPd:SetProperty( "CUP_DCODCA", MVC_VIEW_ORDEM, "22" )
	Else
		oStruC9Y:RemoveField( "C9Y_SEXDEP" )
	EndIf

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_01", STR0006, "", 1 ) //Dados do Trabalhador
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_02", STR0007, "", 1 ) //Informações de Nascimento
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_03", STR0008, "", 1 ) //Informações da Carteira de Trabalho
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_04", STR0051, "", 1 ) //Informações do Registro de Identificação Civil
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_05", STR0052, "", 1 ) //Informações do Registro Geral (RG)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_06", STR0053, "", 1 ) //Informações do Registro Nacional de Estrangeiro
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_07", STR0054, "", 1 ) //Informações do número de registro em Órgão de Classe (OC)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_08", STR0055, "", 1 ) //Informações da Carteira Nacional de Habilitação (CNH)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_09", STR0009, "", 1 ) //Endereço
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_10", STR0067, "", 1 ) //Informações sobre Aposentadoria
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_11", STR0069, "", 1 ) //Informações do trabalhador imigrante 


	aCmpGrp := StrToKArr(cGrpTra1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpTra2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
	Next nI
	If !lLaySimplif
		aCmpGrp := StrToKArr(cGrpTra3,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_03")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra4,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_04")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra5,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_05")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra6,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_06")
		Next nI 

		aCmpGrp := StrToKArr(cGrpTra7,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_07")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra8,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_08")
		Next nI
	EndIf 

	aCmpGrp := StrToKArr(cGrpTra9,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_09")
	Next nI
	
	If !lLaySimplif
		aCmpGrp := StrToKArr(cGrpTra10,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_10")
		Next nI

	Else
		aCmpGrp := StrToKArr(cGrpTra11,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_11")
		Next nI
	EndIf

	//De acordo com o layout do eSocial, todos os campos do eventos S-2200 podem ser retificado. 
	// DSERTAF1-4206
	/*====================================================================================
								Validação dos Campos editáveis:
	Em caso de retificação eu permito editar, apenas os campos que NÃO estão nos eventos 
	de alteração (S2205 ou S2206)
	======================================================================================*/
	/*If Type( "INCLUI" ) <> "U"
		lCmpEdit := IIF(INCLUI .OR. (ALTERA .AND. C9V->C9V_STATUS <> '4'),.T.,.F.)
	EndIf

	oStruC9Va:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruC9Vb:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruC9Vc:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruC9Vd:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruC9Ve:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruC9Vf:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCUPa:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCUPb:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCUPc:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCUPd:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)

	oStruC9Y:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCUP:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruCRQ:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruT3L:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruT80:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	oStruT90:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)

	//Tratamento feito para que durante a retificação do evento, seja possível editar apenas os campos que não existirem nos eventos de alteração.
	oStruC9Va:SetProperty( "C9V_DTNASC", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_CODMUN", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_CODUF" , MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_CODPAI", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_PAINAC", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_NOMMAE", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_NOMPAI", MVC_VIEW_CANCHANGE , .T. )
	oStruC9Va:SetProperty( "C9V_PRIEMP", MVC_VIEW_CANCHANGE , .T. ) 

	oStruCUPb:SetProperty( "CUP_DTADMI", MVC_VIEW_CANCHANGE , .T. )  
	oStruCUPb:SetProperty( "CUP_INDADM", MVC_VIEW_CANCHANGE , .T. ) 
	oStruCUPb:SetProperty( "CUP_TPADMI", MVC_VIEW_CANCHANGE , .T. ) 
	oStruCUPb:SetProperty( "CUP_FGTSOP", MVC_VIEW_CANCHANGE , .T. ) 
	oStruCUPb:SetProperty( "CUP_DTFGTS", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPb:SetProperty( "CUP_MOTCON", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPb:SetProperty( "CUP_JUSHIP", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPb:SetProperty( "CUP_TPINCL", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPc:SetProperty( "CUP_TPLASM", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPc:SetProperty( "CUP_NPROJE", MVC_VIEW_CANCHANGE , .T. )
	oStruCUPd:SetProperty( "CUP_TPCONT", MVC_VIEW_CANCHANGE , .T. )*/

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Vínculo
	-------------------------------------------------------------------------------------*/
	oStruC9Vf:AddGroup("GRP_VINCULO_01",STR0029,"",1)//Dados do Vínculo 
	oStruCUPa:AddGroup("GRP_VINCULO_01",STR0029,"",1)//Dados do Vínculo 
	oStruCUPa:AddGroup("GRP_VINCULO_02",STR0030,"",1)//Informações da Sucessão de vínculo trabalhista 
	oStruCUPa:AddGroup("GRP_VINCULO_03",STR0031,"",1)//Informações sobre o ASO Admissional
	oStruCUPa:AddGroup("GRP_VINCULO_04",STR0060,"",1)//Informações do Afastamento do Trabalhador
	oStruCUPa:AddGroup("GRP_VINCULO_05",STR0061,"",1)//Informações do Desligamento do Trabalhador
	oStruCUPa:AddGroup("GRP_VINCULO_06",STR0065,"",1)//Informações do Empregado Doméstico Transferido

	If TafLayESoc("02_05_00") .And. ( TafColumnPos("CUP_CPFANT") .And. TafColumnPos("CUP_MATOLD") .And. TafColumnPos("CUP_DATCPF") .And. TafColumnPos("CUP_OBSCPF") )
		oStruCUPa:AddGroup("GRP_VINCULO_07",STR0067,"",1)//Mudança de CPF
	EndIf


	If lLaySimplif
		oStruCUPa:AddGroup("GRP_VINCULO_08",STR0070,"",1)//Data de início da cessão/exercício em outro órgão. 
	EndIf 

	aCmpGrp := StrToKArr(cGrpVinc,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Vf:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpVinc2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpVinc3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_02")
	Next nI
	/*
	aCmpGrp := StrToKArr(cGrpVinc4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_03")
	Next nI
	*/
	aCmpGrp := StrToKArr(cGrpVinc4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_04")
	Next nI

	aCmpGrp := StrToKArr(cGrpVinc5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_05")
	Next nI

	aCmpGrp := StrToKArr(cGrpVinc6,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_06")
	Next nI

	If TafLayESoc("02_05_00") .And. ( TafColumnPos("CUP_CPFANT") .And. TafColumnPos("CUP_MATOLD") .And. TafColumnPos("CUP_DATCPF") .And. TafColumnPos("CUP_OBSCPF") )
		aCmpGrp := StrToKArr(cGrpVinc7,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_07")
		Next nI
	EndIf

	If lLaySimplif  .and. TafColumnPos("CUP_DCESSA")
		aCmpGrp := StrToKArr(cGrpVinc8,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruCUPa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_VINCULO_08")
		Next nI
	EndIf 

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador Celetista
	-------------------------------------------------------------------------------------*/
	oStruCUPb:AddGroup("GRP_CELETISTA_01",STR0050,"",1) //Informações de Trabalhador Celetista
	oStruCUPb:AddGroup("GRP_CELETISTA_02",STR0040,"",1) //Informações do FGTS
	oStruCUPb:AddGroup("GRP_CELETISTA_03",STR0041,"",1) //Dados sobre Trabalho Temporário
	oStruCUPb:AddGroup("GRP_CELETISTA_04",STR0063,"",1) //Identificação do Tomador de Serviço
	oStruCUPb:AddGroup("GRP_CELETISTA_05",STR0064,"",1) //Identificação do Estabelecimento Vinculado
	oStruCUPb:AddGroup("GRP_CELETISTA_06",STR0059,"",1) //Identificação do Contratante de Aprendiz

	aCmpGrp := StrToKArr(cGrpCelet1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpCelet2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_02")
	Next nI

	aCmpGrp := StrToKArr(cGrpCelet3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_03")
	Next nI

	aCmpGrp := StrToKArr(cGrpCelet4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_04")
	Next nI

	aCmpGrp := StrToKArr(cGrpCelet5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_05")
	Next nI

	aCmpGrp := StrToKArr(cGrpCelet6,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CELETISTA_06")
	Next nI
	/*-----------------------------------------------------------------------------------
								Grupo de campos do Contrato do Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruCUPd:AddGroup("GRP_CONTRATO_01",STR0033,"",1) //Informações do Contrato de Trabalho
	oStruCUPd:AddGroup("GRP_CONTRATO_02",STR0035,"",1) //Informações de Remuneração
	oStruCUPd:AddGroup("GRP_CONTRATO_03",STR0036,"",1) //Duração do Contrato de Trabalho
	oStruCUPd:AddGroup("GRP_CONTRATO_04",STR0037,"",1) //Informações do local de Trabalho
	oStruCUPd:AddGroup("GRP_CONTRATO_05",STR0039,"",1) //Local Trabalhador Doméstico
	oStruCUPd:AddGroup("GRP_CONTRATO_06",STR0046,"",1) //Informações do Horário Contratual
	oStruCUPd:AddGroup("GRP_CONTRATO_07",STR0048,"",1) //Informações do Alvará Judicial
	oStruCUPd:AddGroup("GRP_CONTRATO_08",STR0068,"",1) //Treinamentos, capacitações, exercícios simulados ou outras anotações

	aCmpGrp := StrToKArr(cGrpContr1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpContr2,"|")
	For nI := 1 to Len(aCmpGrp)
		//adicionado hasField para alteração do nivel de usuario não gerar error log
		If oStruCUPd:HasFIeld(aCmpGrp[nI])
			oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_02")
		EndIf
	Next nI

	aCmpGrp := StrToKArr(cGrpContr3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_03")
	Next nI


	aCmpGrp := StrToKArr(cGrpContr4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_04")
	Next nI

	aCmpGrp := StrToKArr(cGrpContr5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_05")
	Next nI

	aCmpGrp := StrToKArr(cGrpContr6,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_06")
	Next nI

	aCmpGrp := StrToKArr(cGrpContr7,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_07")
	Next nI

	If lLaySimplif
		aCmpGrp := StrToKArr(cGrpContr8,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_08")
		Next nI
	EndIf 

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC9Ve,"C9V")
	EndIf 

	/*-----------------------------------------------------------------------------------
								Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_C9Va", oStruC9Va, "MODEL_C9V" )

	If !lLaySimplif

		oView:AddField( "VIEW_C9Vb", oStruC9Vb, "MODEL_C9V" )

	EndIf 

	oView:AddField( "VIEW_C9Vc", oStruC9Vc, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vd", oStruC9Vd, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Ve", oStruC9Ve, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vf", oStruC9Vf, "MODEL_C9V" )
	oView:AddField( "VIEW_CUPa", oStruCUPa, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPb", oStruCUPb, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPc", oStruCUPc, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPd", oStruCUPd, "MODEL_CUP" )

	oView:AddGrid( "VIEW_C9Y", oStruC9Y, "MODEL_C9Y" )
	oView:AddIncrementField( "VIEW_C9Y", "C9Y_IDDEP" )

	If !lLaySimplif
		
		oView:AddGrid( "VIEW_CRQ", oStruCRQ, "MODEL_CRQ" )
		oView:EnableTitleView("VIEW_CRQ",STR0049) //"Informações Diárias do Horário Contratual."

	EndIf 

	oView:AddGrid( "VIEW_T3L", oStruT3L, "MODEL_T3L" )
	oView:EnableTitleView("VIEW_T3L",STR0043) //"Identificação do Trabalhador Substituído."

	If !lLaySimplif

		oView:AddGrid( "VIEW_T80", oStruT80, "MODEL_T80" )
		oView:EnableTitleView("VIEW_T80",STR0062) //"Filiação Sindical do Trabalhador"

	EndIf 

	oView:AddGrid( "VIEW_T90", oStruT90, "MODEL_T90" )
	oView:EnableTitleView("VIEW_T90",STR0066) //"Observações do Contrato de Trabalho"
	oView:AddIncrementField( "VIEW_T90", "T90_CODOBS" )

	If lLaySimplif .And. oStruV87 != Nil
		oView:AddGrid( "VIEW_V87", oStruV87, "MODEL_V87" )
	EndIf

	If TafColumnPos("C9V_PROTUL")
		oView:EnableTitleView( 'VIEW_C9Ve', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão" 
	EndIf
	If TafColumnPos("C9V_DTRANS")
		oView:AddField( "VIEW_C9Vg", oStruC9Vg, "MODEL_C9V" )
		oView:EnableTitleView( 'VIEW_C9Vg', TafNmFolder("recibo",2) ) // "Informações de Controle eSocial"
	EndIf

	/*-----------------------------------------------------------------------------------
								Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0012) //Trabalhador

	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0017) //Vínculo 	

	If FindFunction("TafNmFolder")	
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",STR0042)//"Protocolo de Transmissão" 
	EndIf 

	If TafColumnPos("C9V_DTRANS")
		oView:CreateHorizontalBox("C9Ve",20,,,"FOLDER_PRINCIPAL","ABA03")
		oView:CreateHorizontalBox("C9Vg",80,,,"FOLDER_PRINCIPAL","ABA03")
	Else
		oView:CreateHorizontalBox("C9Ve",100,,,"FOLDER_PRINCIPAL","ABA03")
	EndIf

	//////////////////////////////////////////////////////////////////////////////////

	oView:CreateHorizontalBox("PAINEL_TRABALHADOR",100,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder("TRABALHADOR","PAINEL_TRABALHADOR")

	oView:AddSheet("TRABALHADOR","ABA01",STR0013) //Informações do Trabalhador
	oView:CreateHorizontalBox("C9Va",100,,,"TRABALHADOR","ABA01")

	If !lLaySimplif
		oView:AddSheet("TRABALHADOR","ABA02",STR0014) //Informações de Trabalhador Estrangeiro
		oView:CreateHorizontalBox("C9Vb",100,,,"TRABALHADOR","ABA02")
	EndIf 
	oView:AddSheet("TRABALHADOR","ABA03",STR0015) //Informações Deficiência
	oView:CreateHorizontalBox("C9Vc",100,,,"TRABALHADOR","ABA03")

	oView:AddSheet("TRABALHADOR","ABA04",STR0016) //Dependentes
	oView:CreateHorizontalBox("C9Y" ,100,,,"TRABALHADOR","ABA04")

	oView:AddSheet("TRABALHADOR","ABA05",STR0010) //Informações de Contato
	oView:CreateHorizontalBox("C9Vd",100,,,"TRABALHADOR","ABA05")

	//////////////////////////////////////////////////////////////////////////////////
		
	oView:CreateHorizontalBox("PAINEL_VINCULO",100,,,"FOLDER_PRINCIPAL","ABA02")
	oView:CreateFolder("VINCULO","PAINEL_VINCULO")
		
	oView:AddSheet("VINCULO","ABA01",STR0018)//Informações do Vínculo 
	oView:CreateHorizontalBox("C9Vf",15,,,"VINCULO","ABA01")
	oView:CreateHorizontalBox("CUPa",85,,,"VINCULO","ABA01")
	oView:AddSheet("VINCULO","ABA02",STR0019)//Trabalhador Celetista 			
	oView:CreateHorizontalBox("CUPb",70,,,"VINCULO","ABA02")
	oView:CreateHorizontalBox("T3L" ,30,,,"VINCULO","ABA02")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("VINCULO","ABA03",STR0045)//Trabalhador Estatutário
	oView:CreateHorizontalBox("CUPc",35,,,"VINCULO","ABA03")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("VINCULO","ABA04",STR0044)//Contrato de Trabalho	
	oView:CreateHorizontalBox("CUPd" ,75,,,"VINCULO","ABA04")
	oView:CreateHorizontalBox("GRIDS",25,,,"VINCULO","ABA04")

	oView:CreateFolder( "FOLDER_PRINCIPAL_VINCULO" , "GRIDS" )

	If !lLaySimplif

		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA01', STR0049 ) //"Informações Diárias do Horário Contratual"
		oView:CreateHorizontalBox( 'CRQ', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA01' )

		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA02', STR0062 ) //"Filiação Sindical do Trabalhador"
		oView:CreateHorizontalBox( 'T80', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA02' )
	Else
		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA02', STR0071 ) //"Treinamentos, capacitações, exercícios simulados, autorizações ou outras anotações"
		oView:CreateHorizontalBox( 'V87', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA02' )
	EndIf 

	oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA03', STR0066 ) //"Observações do Contrato de Trabalho"
	oView:CreateHorizontalBox( 'T90', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA03' )

	/*-----------------------------------------------------------------------------------
								Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_C9Va", "C9Va" )

	If !lLaySimplif

		oView:SetOwnerView( "VIEW_C9Vb", "C9Vb" )

	EndIf 

	oView:SetOwnerView( "VIEW_C9Vc", "C9Vc" )
	oView:SetOwnerView( "VIEW_C9Vd", "C9Vd" )
	oView:SetOwnerView( "VIEW_C9Ve", "C9Ve" )
	oView:SetOwnerView( "VIEW_C9Vf", "C9Vf" )
	If TafColumnPos("C9V_DTRANS")
		oView:SetOwnerView( "VIEW_C9Vg", "C9Vg" )
	EndIf
	oView:SetOwnerView( "VIEW_CUPa", "CUPa" )
	oView:SetOwnerView( "VIEW_CUPb", "CUPb" )
	oView:SetOwnerView( "VIEW_CUPc", "CUPc" )
	oView:SetOwnerView( "VIEW_CUPd", "CUPd" )
	oView:SetOwnerView( "VIEW_C9Y" , "C9Y"  )

	If !lLaySimplif
		oView:SetOwnerView( "VIEW_CRQ" , "CRQ"  )
	EndIf

	oView:SetOwnerView( "VIEW_T3L" , "T3L"  )

	If !lLaySimplif
		oView:SetOwnerView( "VIEW_T80" , "T80"  )
	ElseIf oStruV87 != Nil
		oView:SetOwnerView( "VIEW_V87" , "V87"  )	
	EndIf 

	oView:SetOwnerView( "VIEW_T90" , "T90"  )

	If !lLaySimplif
		// Após a exibição da view, o NIS é atualizado.
		oView:SetAfterViewActivate( {|oView| UpdateNIS(oView, oModel) , oView:Refresh() } )	
	EndIf

	//Tratamento para que alguns campos de controle interno não sejam exibidos na tela
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruC9Va,"C9V")
	EndIf

	If TafColumnPos("CUP_INSANT")
		oStruCUPa:SetProperty( "CUP_INSANT"	, MVC_VIEW_ORDEM, "40" )
	EndIf


Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin / Rodrigo Aguilar
@Since 25/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpe	 := ""
	Local cLogOpeAnt := ""

	Local cChvRegAnt := ""
	Local cID		   := ""

	Local nOperation := oModel:GetOperation()

	Local aGrava     := {}
	Local aGravaCUP  := {}
	Local aGravaC9Y  := {}
	Local aGravaCRQ  := {}
	Local aGravaT3L  := {}
	Local aGravaT80  := {}
	Local aGravaT90  := {}
	Local aGravaV87  := {}

	//Carrego a Estrutura dos Models a serem gravados
	Local oModelC9V := oModel:GetModel( "MODEL_C9V" )
	Local oModelCUP := oModel:GetModel( "MODEL_CUP" )
	Local oModelC9Y := oModel:GetModel( "MODEL_C9Y" )
	Local oModelCRQ := oModel:GetModel( "MODEL_CRQ" )
	Local oModelT3L := oModel:GetModel( "MODEL_T3L" )
	Local oModelT80 := oModel:GetModel( "MODEL_T80" )
	Local oModelT90 := oModel:GetModel( "MODEL_T90" )
	Local oModelV87 := oModel:GetModel( "MODEL_V87" )

	Local lRetorno	:= .T.

	Private cStaEvC9V	:= "" //Status do Registro do Evento do Trabalhador (S2200 ou S2300)

	cStaEvC9V	:= C9V->C9V_STATUS

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	cLogOpe    	:= ""
	cLogOpeAnt 	:= ""

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT	

			TafAjustID( "C9V", oModel)
		
			dbSelectArea("C9V")
			dbSetOrder(11)
			
			If !msSeek(xFilial("C9V") + oModelC9V:GetValue("C9V_MATRIC"))
				oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", xFunGetVer() )
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2200" )

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, "MODEL_C9V", "C9V" )
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '2', '' )
				Endif

				FwFormCommit( oModel )
			
				//=======================================================================================================================
				//Desativo o objeto e carrego novemnte o modelo com as informações para que seja possivel inserir uma nova linha para o ||
				//registro ORIGI (Consolidado das informações do trabalhador)											                      ||
				//Obs. Esse registro irá conter as informações consolidadas dos dados do trabalhador e será atualizado automáticamente  ||
				//pelo JOB de transmissão dos eventos, após o retorno de aceite do fisco.														 || 
				//=======================================================================================================================	
				//Retirada regra de inclusão do Registro ORIGI (Paulo Santana 26/01/2017)
				/*TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, @aGrava, @aGravaCUP, @aGravaC9Y, @aGravaCRQ, @aGravaT3L )
				TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, .T. )
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "ORIGI" )
				oModel:LoadValue( "MODEL_C9V", "C9V_DESEVE", "2" )
				FwFormCommit( oModel )*/
			Else
				oModel:SetErrorMessage(, , , , ,STR0058, , , )//"Número de Matricula Inválido! Não é Possível inserir a mesma matrícula para mais de um trabalhador."
				lRetorno:= .F.
			Endif
			
		//Alteração Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE 
			
			If cStaEvC9V == "4"

				If TafColumnPos( "C9V_LOGOPE" )
					cLogOpeAnt := oModelC9V:GetValue( "C9V_LOGOPE" )	
				endif
			
				//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )
				TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, @aGrava, @aGravaCUP, @aGravaC9Y, @aGravaCRQ, @aGravaT3L, @aGravaT80, @aGravaT90, oModelV87, @aGravaV87 )
					
				/*---------------------------------------------------------- 
				Seto o campo como Inativo e gravo a versao do novo registro
				no registro anterior                                       
				-----------------------------------------------------------*/                        
				FAltRegAnt( "C9V", "2" )
					
				//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF278CARR 
				TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90,, oModelV87, aGravaV87  )
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2200" )	
				
				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_C9V', 'C9V' )	
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'C9V', " " )
					
			ElseIf	cStaEvC9V == "2"                                                                 
				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno:= .F.
			ElseIf cStaEvC9V == "6"                                                                                                                                                                                                                                                                                                                               
				TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
				lRetorno:= .F.
			Elseif cStaEvC9V == "7"
				TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
				lRetorno:= .F.
			Else

				If TafColumnPos( "C9V_LOGOPE" )
					cLogOpeAnt := C9V->C9V_LOGOPE
				endif

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_C9V', 'C9V' )	
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				//Altero o Status do registro do Evento S2200 e confirmo a alteração.
				TAFAltStat( 'C9V', " " )
				FwFormCommit( oModel )
				cId := C9V->C9V_ID
				
				//Quando se tratar de um evento sem versão anterior devo alterar também o registro ORIGI
				//Retirado o tratamento para o registro ORIGI, pois o mesmo não será mais gerado. (Paulo Santana - 26/01/2017)
				/*If Empty( C9V->C9V_VERANT )
					//Quando o evento ainda não tiver sido transmi
					If C9V->( msSeek( xFilial( "C9V" ) + cId + "ORIGI" + "1" ) )
						nOper := MODEL_OPERATION_UPDATE
						TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, @aGrava, @aGravaCUP, @aGravaC9Y, @aGravaCRQ, @aGravaT3L )
						TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, .T., ,nOper )
						oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "ORIGI" )
						oModel:LoadValue( "MODEL_C9V", "C9V_DESEVE", "2" )
						FwFormCommit( oModel )
						TAFAltStat( 'C9V', " " )  
					EndIf
				Endif*/	
			Endif	
			
		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE	  
			cChvRegAnt := C9V->(C9V_ID + C9V_VERANT) + "S2200"              
			If !Empty( cChvRegAnt ) 
				TAFAltStat( 'C9V', " " )
				FwFormCommit( oModel )				
				If nOperation == MODEL_OPERATION_DELETE
					If C9V->C9V_EVENTO == "A" .Or. C9V->C9V_EVENTO == "E"
						TAFRastro( 'C9V', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
					EndIf
				EndIf
			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 ) 	
				oModel:Activate()
				FwFormCommit( oModel )
			EndIf

		EndIf
		
	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Grv    
Funcao de gravacao para atender o registro S-2200

@Param:
cLayout -  Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
            alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
            tratamentos de acordo com o layout que esta sendo enviado.
            
nOpc    -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )

cFilEv  -  Filial do ERP para onde as informacoes deverao ser importadas

oXML    -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
		  
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin / Rodrigo Aguilar
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF278Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE,cKey,cMatrC9V,lLaySmpTot,lExclCMJ,oTransf)

	Local cLogOpeAnt := '' 
	Local cCmpsNoUpd 	:= "|C9V_FILIAL|C9V_ID|C9V_VERSAO|C9V_NOMEVE|C9V_VERANT|C9V_PROTUL|C9V_PROTPN|C9V_EVENTO|C9V_STATUS|C9V_ATIVO|"
	Local nI        	:= 0
	Local nJ        	:= 0
	Local nX        	:= 0
	Local nIndChv   	:= 10
	Local nSeqErrGrv	:= 0

	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aRulesVinc 	:= {}
	Local aChave     	:= {}

	Local oModel     	:= Nil

	Local cCabecTrab 	:= "/eSocial/evtAdmissao/trabalhador"
	Local cCabecVinc 	:= "/eSocial/evtAdmissao/vinculo"

	Local cC9YPath   	:= ""
	Local cCRQPath   	:= ""
	Local cT3LPath   	:= ""
	Local cT80Path   	:= ""
	Local cT90Path   	:= ""
	Local cV87Path   	:= ""

	Local cMatTrab   	:= ""
	Local cCPF       	:= ""
	Local cEnter     	:= Chr(13) + Chr(10)
	Local cMensagem  	:= ""
	Local cInconMsg  	:= ""
	Local cFilC9V    	:= ""
	Local cChaveOri		:= ""
	Local cProtUl		:= ""
	Local cStatus		:= ""

	Local cChvTrab   	:= C9V->C9V_ID + '1'
	Local cValorXml  	:= ""
	Local cCpfT3A   	:= ""
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

	Local nC9Y 		    := 0
	Local nCRQ		  	:= 0 
	Local nT3L		 	:= 0 	
	Local nT80      	:= 0 
	Local nT90      	:= 0 
	Local nV87	     	:= 0 
	Local nTamModel 	:= 0
	Local nLinha		:= 0

	Local dDtAdm 		:= Date()

	Local lAltPend   	:= .F.
	Local lRet      	:= .F.
	Local lTransmit		:= .F.
	Local lDelLine  	:= .F. 
	Local lEmpty    	:= .F.
	Local lAddLine		:= .T.
	Local lTransf		:= .F.
	Local lMesmaBase 	:= .F. 

	Local xChkDupl		:= {}

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados  	:= {}

	Default cLayout  	:= "2200"
	Default nOpc    	:= 1
	Default cFilEv  	:= ""
	Default oXML    	:= Nil  
	Default cOwner  	:= ""   
	Default cFilTran	:= ""
	Default cGrpTran	:= ""
	Default cEmpOriGrp	:= ""
	Default cFilOriGrp	:= ""
	Default cXmlID		:= ""
	Default lMigrador	:= .F.
	Default lDepGPE		:= .F.
	Default cEvtOri		:= ""
	Default oTransf 	:= Nil 

	cLogOpeAnt := ""

	If lLaySimplif == Nil
		TAF278Lay() //Inicializa a variável static lLaySimplif
	EndIf

	If !TafVldAmb("2")
		cMensagem := STR0056 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()
		Aadd(aIncons, cMensagem)
	Else

	If oTransf == Nil 
		cFilC9V  	:= FTafGetFil(cFilEv,@aIncons,"C9V")
	Else 
		lMesmaBase 	:= oTransf:isSameBaseCNPJ()
		cChaveOri 	:= oTransf:getOriginKey()
		cProtUl 	:= oTransf:getReceipt()
		cStatus		:= oTransf:getStatus()
		lTransf := .T. 
		cFilC9V := oTransf:getDestBranch()
	EndIf 
			
	oDados	:= oXML

	If oDados:XPathHasNode( cCabecVinc + "/matricula"  )
		cMatTrab := oDados:XPathGetNodeValue( cCabecVinc + "/matricula" )
	EndIf
		
	If oDados:XPathHasNode( cCabecTrab + "/cpfTrab"  )
		cCPF	:= oDados:XPathGetNodeValue( cCabecTrab + "/cpfTrab" )
	EndIf
		
	//Chave do Registro
	aAdd( aChave, {"C", "C9V_CPF", cCPF, .T. } )
	aAdd( aChave, {"C", "C9V_MATRIC", cMatTrab, .T. } )
	aAdd( aChave, {"C", "C9V_NOMEVE", "S2200", .T. } )
		
	cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) + Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1] )

	//Verifica se o evento ja existe na base
	("C9V")->( DbSetOrder( nIndChv ) )
	If ("C9V")->( MsSeek( cFilC9V + cChave + '1' ) )
		nOpc := 4
		lTransmit 	:= IIF(C9V->C9V_STATUS == '4',.T.,.F.)

		cChvTrab := C9V->C9V_ID + '1'
		//=======================================================================================================+
		// Posiciona no último evento de alteração (2205) ativo para este trabalhador.                          ||
		// Retorna .F. se não encontrar um registro de alteração ativo para este trabalhador e .T. SE encontrar ||
		//=======================================================================================================+
		If RetUltAtivo('T1U',cChvTrab,2)
			If T1U->T1U_STATUS <> '4'
				Aadd( aIncons, "000025") //"Não é permitido a integração deste evento, enquanto outro tiver pendente de transmissão."
				lAltPend := .T.
			Endif
		EndIf
			
		If !lAltPend
			//=======================================================================================================+
			// Posiciona no último evento de alteração (2206) ativo para este trabalhador.                          ||
			// Retorna .F. se não encontrar um registro de alteração ativo para este trabalhador e .T. SE encontrar ||
			//=======================================================================================================+
			If RetUltAtivo('T1V',cChvTrab,2)
				If T1V->T1V_STATUS <> '4'
					Aadd( aIncons, "000025")//"Não é permitido a integração deste evento, enquanto outro tiver pendente de transmissão."
					lAltPend := .T.
				Endif
			EndIf
		Endif
			
	EndIf

	If lDepGPE

		//Chama função para correção do cadastro de dependentes do S-2200 criado para envio do S-2206 de transferência.
		TafAjustDeps( @oModel, @oDados, "S-2200", "TAFA278", "C9V", @cInconMsg, @aIncons, @nSeqErrGrv )
		//Chama função para correção do cadastro de dependentes do S-2200 criado para envio do S-2206 de transferência.

		///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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
					Aadd(aIncons, "ERRO19" )
				Else
					lRet := .T.
				EndIf
			EndIf
		Else
			Aadd(aIncons, cInconMsg)
		EndIf

		oModel:DeActivate()
		If FindFunction('TafClearModel')
			TafClearModel(oModel)
		EndIf
		
	Else

		//Continua o processo de integração apenas se não houver nenhum evento de alteração pendente
		If !lAltPend
								
			//Funcao para validar se a operacao desejada pode ser realizada
			If FTafVldOpe( "C9V", nIndChv, @nOpc,cFilEv, @aIncons, aChave, @oModel, "TAFA278", cCmpsNoUpd )

				If TafColumnPos( "C9V_LOGOPE" )
					cLogOpeAnt := C9V->C9V_LOGOPE
				endif

				//Caso se trate de uma inclusao/retificação gravo o tipo do evento na tabela C9V
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2200" )
				
				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := FRulCad( cCabecTrab, cLayout, "C9V", cCabecVinc, @cInconMsg, @nSeqErrGrv, lTransmit, @oModel, aChave, @aIncons, cCodEvent, cOwner )
			
				//Carrego array com os campos De/Para de gravacao das informacoes ( Vínculo )
				aRulesVinc := FRulVinc( cCabecVinc, cLayout, "CUP", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )
	
				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes

				If nOpc <> 5
						
					oModel:LoadValue( "MODEL_C9V", "C9V_FILIAL", C9V->C9V_FILIAL )
					oModel:LoadValue( "MODEL_C9V", "C9V_XMLID", cXmlID )
		
					If lTransf

						oModel:LoadValue( "MODEL_C9V", "C9V_IDTRAN", cChaveOri)
						if lMesmaBase
							oModel:LoadValue( "MODEL_C9V", "C9V_PROTUL", AllTrim(cProtUl))
							oModel:LoadValue( "MODEL_C9V", "C9V_STATUS", cStatus)
						endif 
					EndIf 

					//Rodo o aRulesCad para gravar as informacoes
					For nI := 1 to Len( aRulesCad )
						cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )
							
						If aRulesCad[ nI, 01 ] == "C9V_CPF"
							cCpfT3A := cValorXml
						EndIf
							
						oModel:LoadValue("MODEL_C9V", aRulesCad[ nI, 01 ], cValorXml)							 
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//Rodo o aRulesVinc para gravar as informacoes
					For nI := 1 to Len( aRulesVinc )
						cValorXml := FTafGetVal( aRulesVinc[ nI, 02 ], aRulesVinc[nI, 03], aRulesVinc[nI, 04], @aIncons, .F. )
							
						If aRulesVinc[ nI, 01 ] == "CUP_DTADMI"
							dDtAdm := cValorXml
						EndIf

						If aRulesVinc[ nI, 01 ] == "CUP_OBJDET"
							cValorXml := PadR(cValorXml,TamSX3('CUP_OBJDET')[1])
						EndIf
						
						If lLaySimplif .AND. aRulesVinc[ nI, 01 ] $ 'CUP_CODTRE|CUP_CBOCAR|CUP_CBOFUN'
							oModel:LoadValue( "MODEL_CUP", aRulesVinc[ nI, 01 ], aRulesVinc[ nI, 02 ] )
						Else
							oModel:LoadValue("MODEL_CUP", aRulesVinc[ nI, 01 ], cValorXml)
						EndIf
											
					Next nI
						
					//***********
					//Dependentes
					//***********
					cC9YPath 	:= cCabecTrab + "/dependente"
						
					//Recebo o tamanho do modelo
					nTamModel	:= oModel:GetModel( "MODEL_C9Y" ):Length()
					lAddLine 	:= .T.
						
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Dependentes )	
					If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner,(cC9YPath + "[1]/tpDep"), cC9YPath + "/tpDep" ) .AND. ;
										TafXNode( oDados, cCodEvent, cOwner,(cC9YPath + "[1]/nmDep"), cC9YPath + "/nmDep" ) .AND. ;
										TafXNode( oDados, cCodEvent, cOwner,(cC9YPath + "[1]/dtNascto"), cC9YPath + "/dtNascto" )
									
						For nJ := 1 to nTamModel
							oModel:GetModel( "MODEL_C9Y" ):GoLine(nJ)
							oModel:GetModel( "MODEL_C9Y" ):DeleteLine()
						Next nJ
					Else
						lAddLine := .F.
					EndIf		
			
					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Dependentes )
					nC9Y	:= 1					
					While oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nC9Y)+ "]" ) .OR. ( nC9Y <= nTamModel .AND. !lAddLine ) 
						
						If ( nOpc == 3 .And. nC9Y > 1 .And. oDados:XPathHasNode( cC9YPath + "[" + cValToChar(nC9Y)+ "]" ) ) .OR. ( oDados:XPathHasNode( cC9YPath + "[" + cValToChar(nC9Y)+ "]" ) .And. lAddLine )
							
							oModel:GetModel( "MODEL_C9Y" ):lValid:= .T.
							oModel:GetModel( "MODEL_C9Y" ):AddLine()
						
						EndIf						
						
						If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/tpDep"), cC9YPath + "/tpDep")	
							oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP", StrZero(nC9Y,6) )
							oModel:LoadValue( "MODEL_C9Y", "C9Y_TPDEP", FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/tpDep" ,,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/sexoDep"), cC9YPath + "/sexoDep")	
							oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP", StrZero(nC9Y,6) )
							If lLaySimplif
								oModel:LoadValue( "MODEL_C9Y", "C9Y_SEXDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/sexoDep"  , "C", .F., @aIncons, .F., '', '' ) )
							EndIf
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
								
						If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/nmDep"), cC9YPath + "/nmDep") .AND. !lDelLine
							oModel:LoadValue("MODEL_C9Y", "C9Y_NOMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/nmDep", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
								
						If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/dtNascto"), cC9YPath + "/dtNascto") .AND. !lDelLine
							oModel:LoadValue( "MODEL_C9Y", "C9Y_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/dtNascto", "D", .F., @aIncons, .F., '' ,'',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
						
						//Verifico se foi enviado as TAGs no XML
						If oDados:XPathHasNode( cC9YPath + "[" + cValToChar(nC9Y)+ "]" ) .AND. !lDelLine
								
							If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/cpfDep"), cC9YPath + "/cpfDep" )
								oModel:LoadValue( "MODEL_C9Y", "C9Y_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/cpfDep"  , "C", .F., @aIncons, .F., '', '' ) )
							EndIf
									
							If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/depIRRF"), cC9YPath + "/depIRRF" )
								oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/depIRRF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf
									
							If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/depSF"), cC9YPath + "/depSF" )
								oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/depSF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf
							
							If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nC9Y) + "]/incTrab"), cC9YPath + "/incTrab" )
								oModel:LoadValue( "MODEL_C9Y", "C9Y_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nC9Y) + "]/incTrab" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf
						
						EndIf
									
						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine
							
							nLinha := Iif(!lAddLine, nC9Y, nTamModel+nC9Y)		
							
							oModel:GetModel( 'MODEL_C9Y' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_C9Y' ):DeleteLine()
							
							lDelLine := .F.
						
						EndIf
							
						nC9Y++
					EndDo
					//----------	
								
					//***********
					//Hora Contratual
					//***********		
					cCRQPath := cCabecVinc + "/infoContrato/horContratual/horario"
	
					//Recebo o tamanho do modelo
					nTamModel 	:= oModel:GetModel( "MODEL_CRQ" ):Length()
					lAddLine 	:= .T.
					
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Hora Contratual )
					If nOpc == 4 .AND. TafXNode( oDados, cCodEvent, cOwner, (cCRQPath + "[1]/dia"), cCRQPath + "/dia" ) .AND. ;
										TafXNode( oDados, cCodEvent, cOwner, (cCRQPath + "[1]/codHorContrat"), cCRQPath + "/codHorContrat" ) 
										
						For nJ := 1 to nTamModel
							oModel:GetModel( "MODEL_CRQ" ):GoLine(nJ)
							oModel:GetModel( "MODEL_CRQ" ):DeleteLine()
						Next nJ
					Else
						lAddLine := .F.
					EndIf	
		
					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Hora Contratual )
					nCRQ  	:= 1					
					While oDados:XPathHasNode( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nCRQ)+ "]" ) .OR. ( nCRQ <= nTamModel .AND. !lAddLine )
						
						If ( nOpc == 3 .And. nCRQ > 1 .And. oDados:XPathHasNode( cCRQPath + "[" + cValToChar(nCRQ)+ "]" ) ) .OR. ( oDados:XPathHasNode( cCRQPath + "[" + cValToChar(nCRQ)+ "]" ) .And. lAddLine )
							
							oModel:GetModel( "MODEL_CRQ" ):lValid:= .T.
							oModel:GetModel( "MODEL_CRQ" ):AddLine()
						
						EndIf
						
						If TafXNode( oDados, cCodEvent, cOwner, (cCRQPath + "[" + cValToChar(nCRQ) + "]/dia"), cCRQPath + "/dia" )
							oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA", FTafGetVal( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nCRQ) + "]/dia", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
							
						If TafXNode( oDados, cCodEvent, cOwner, (cCRQPath + "[" + cValToChar(nCRQ) + "]/codHorContrat"), cCRQPath + "/codHorContrat" ) .AND. !lDelLine
							oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , FGetIdInt( "codHorContrat", "", cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nCRQ) + "]/codHorContrat",,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
							
						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine
							
							nLinha := Iif(!lAddLine, nCRQ, nTamModel+nCRQ)		
							
							oModel:GetModel( 'MODEL_CRQ' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_CRQ' ):DeleteLine()
							
							lDelLine := .F.
						
						EndIf
							
						nCRQ++
					EndDo
					//---------
									
					//***********
					//Trabalhador Substituido
					//***********	
					cT3LPath := cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido"
	
					//Recebo o tamanho do modelo
					nTamModel	:= oModel:GetModel( "MODEL_T3L" ):Length()
					lAddLine 	:= .T.
		
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Trabalhador Substituido )
					If nOpc == 4 .AND. TafXNode( oDados, cCodEvent, cOwner, ( cT3LPath + "[1]/cpfTrabSubst"), cT3LPath + "/cpfTrabSubst" )					
						For nJ := 1 to nTamModel
							oModel:GetModel( "MODEL_T3L" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T3L" ):DeleteLine()
						Next nJ
					Else
						lAddLine := .F.
					EndIf	
		
					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Trabalhador Substituido )
					nT3L  	:= 1		
					While oDados:XPathHasNode( cT3LPath +"[" + cValToChar(nT3L)+ "]" ) .OR. ( nT3L <= nTamModel .AND. !lAddLine )
	
						If ( nOpc == 3 .And. nT3L > 1 .And. oDados:XPathHasNode( cT3LPath + "[" + cValToChar(nT3L) + "]" ) ) .OR. ( oDados:XPathHasNode( cT3LPath + "[" + cValToChar(nT3L) + "]" ) .And. lAddLine )
					
							oModel:GetModel( "MODEL_T3L" ):lValid:= .T.
							oModel:GetModel( "MODEL_T3L" ):AddLine()
							
						EndIf
											
						If TafXNode( oDados, cCodEvent, cOwner, ( cT3LPath + "[" + cValToChar(nT3L) + "]/cpfTrabSubst"), cT3LPath + "/cpfTrabSubst" )
							oModel:LoadValue( "MODEL_T3L", "T3L_CPF", FTafGetVal( cT3LPath + "[" + cValToChar(nT3L) + "]/cpfTrabSubst", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
							
						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine
							
							nLinha := Iif(!lAddLine, nT3L, nTamModel+nT3L)		
							
							oModel:GetModel( 'MODEL_T3L' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_T3L' ):DeleteLine()
							
							lDelLine := .F.
						
						EndIf
							
						nT3L++
					EndDo
						
					//*********************************
					//Filiação Sindical do Trabalhador
					//*********************************	
					cT80Path := cCabecVinc + "/infoContrato/filiacaoSindical"
					
					//Recebo o tamanho do modelo	
					nTamModel 	:= oModel:GetModel( "MODEL_T80" ):Length()
					lAddLine	:= .T.
			
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Filiação Sindical do Trabalhador )
					If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, ( cT80Path + "[1]/cnpjSindTrab"), cT80Path + "/cnpjSindTrab" )
						For nX := 1 to nTamModel
							oModel:GetModel( "MODEL_T80" ):GoLine(nX)
							oModel:GetModel( "MODEL_T80" ):DeleteLine()
						Next nX
					Else
						lAddLine := .F.
					EndIf	
		
					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Filiação Sindical do Trabalhador )
					nT80	:= 1
					While oDados:XPathHasNode( cT80Path + "[" + cValToChar(nT80)+ "]" ) .OR. ( nT80 <= nTamModel .AND. !lAddLine )
					
						If ( nOpc == 3 .And. nT80 > 1 .And. oDados:XPathHasNode( cT80Path + "[" + cValToChar(nT80) + "]" ) ) .OR. ( oDados:XPathHasNode( cT80Path + "[" + cValToChar(nT80) + "]" ) .And. lAddLine )
					
							oModel:GetModel( "MODEL_T80" ):lValid:= .T.
							oModel:GetModel( "MODEL_T80" ):AddLine()
										
						EndIf
							
						If TafXNode( oDados, cCodEvent, cOwner, ( cT80Path + "[" + cValToChar(nT80) + "]/cnpjSindTrab"), cT80Path + "/cnpjSindTrab" )
							oModel:LoadValue( "MODEL_T80", "T80_CNPJSD", FTafGetVal( cT80Path + "[" + cValToChar(nT80) + "]/cnpjSindTrab", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
							
						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine
							
							nLinha := Iif(!lAddLine, nT80, nTamModel+nT80)		
							
							oModel:GetModel( 'MODEL_T80' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_T80' ):DeleteLine()
							
							lDelLine := .F.
						
						EndIf
					
						nT80++
					EndDo
	
					If lLaySimplif .And. TAFAlsInDic("V87")
						//***********************************
						//Capacitação e Treinamentos
						//***********************************
						cV87Path := cCabecVinc + "/infoContrato/treiCap"
			
						//Recebo o tamanho do modelo
						nTamModel 	:= oModel:GetModel( "MODEL_V87" ):Length()
						lAddLine 	:= .T.
						
						//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Observações do contrato de trabalho )
						If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cV87Path + "[1]/codTreiCap" ), cV87Path + "/codTreiCap" )
							For nX := 1 to nTamModel
								oModel:GetModel( "MODEL_V87" ):GoLine(nX)
								oModel:GetModel( "MODEL_V87" ):DeleteLine()
							Next nX
						Else
							lAddLine := .F.
						EndIf	

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Observações do contrato de trabalho )
						nV87	:= 1			
						While oDados:XPathHasNode( cV87Path + "[" + cValToChar(nV87)+ "]" ) .OR. ( nV87 <= nTamModel .AND. !lAddLine )

							If ( nOpc == 3 .And. nV87 > 1 .And. oDados:XPathHasNode( cV87Path + "[" + cValToChar(nV87) + "]" ) ) .OR. ( oDados:XPathHasNode( cV87Path + "[" + cValToChar(nV87) + "]" ) .And. lAddLine )

								oModel:GetModel( "MODEL_V87" ):lValid:= .T.
								oModel:GetModel( "MODEL_V87" ):AddLine()

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cV87Path +"[" + cValToChar(nV87) + "]/codTreiCap" ), cV87Path + "/codTreiCap" )
								oModel:LoadValue( "MODEL_V87", "V87_CODTRE", FGetIdInt( "codTreiCap", "", cV87Path +"[" + cValToChar(nV87) + "]/codTreiCap",,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty) )
								lDelLine := Iif(lEmpty,.T.,lDelLine)
							EndIf

							//Deleto a linha do modelo caso um campo chave seja excluído
							If lDelLine

								nLinha := Iif(!lAddLine, nV87, nTamModel+nV87)		

								oModel:GetModel( 'MODEL_V87' ):GoLine(nLinha) 
								oModel:GetModel( 'MODEL_V87' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nV87++
						EndDo

					EndIf

					//***********************************
					//Observações do contrato de trabalho
					//***********************************
					cT90Path := cCabecVinc + "/infoContrato/observacoes"
			
					//Recebo o tamanho do modelo
					nTamModel 	:= oModel:GetModel( "MODEL_T90" ):Length()
					lAddLine 	:= .T.
						
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Observações do contrato de trabalho )
					If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT90Path + "[1]/observacao" ), cT90Path + "/observacao" )
						For nX := 1 to nTamModel
							oModel:GetModel( "MODEL_T90" ):GoLine(nX)
							oModel:GetModel( "MODEL_T90" ):DeleteLine()
						Next nX
					Else
						lAddLine := .F.
					EndIf	

					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Observações do contrato de trabalho )
					nT90	:= 1			
					While oDados:XPathHasNode( cT90Path + "[" + cValToChar(nT90)+ "]" ) .OR. ( nT90 <= nTamModel .AND. !lAddLine )
							
						If ( nOpc == 3 .And. nT90 > 1 .And. oDados:XPathHasNode( cT90Path + "[" + cValToChar(nT90) + "]" ) ) .OR. ( oDados:XPathHasNode( cT90Path + "[" + cValToChar(nT90) + "]" ) .And. lAddLine )
					
							oModel:GetModel( "MODEL_T90" ):lValid:= .T.
							oModel:GetModel( "MODEL_T90" ):AddLine()
						
						EndIf
											
						If TafXNode( oDados, cCodEvent, cOwner, (cT90Path +"[" + cValToChar(nT90) + "]/observacao" ), cT90Path + "/observacao" )
							oModel:LoadValue( "MODEL_T90", "T90_CODOBS", StrZero(nT90,6) )
							oModel:LoadValue( "MODEL_T90", "T90_OBSERV", FTafGetVal( cCabecVinc + "/infoContrato/observacoes[" + cValToChar(nT90) + "]/observacao", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf
							
						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine
							
							nLinha := Iif(!lAddLine, nT90, nTamModel+nT90)		
							
							oModel:GetModel( 'MODEL_T90' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_T90' ):DeleteLine()
							
							lDelLine := .F.
						
						EndIf
					
						nT90++
					EndDo
	
				EndIf
				//----------- 
				
				///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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
							Aadd(aIncons, "ERRO19" )
						Else
							lRet := .T.
						EndIf
					EndIf

					If lRet 
						If oTransf != Nil .And. oTransf:isTransferGroup()
							nTafRecno := C9V->(RecNo())
							FAltRegAnt("C9V","0")
						EndIf 
					EndIf 

				Else
					Aadd(aIncons, cInconMsg)
				EndIf

				oModel:DeActivate()
				If FindFunction('TafClearModel')
					TafClearModel(oModel)
				EndIf	
			EndIf
		Endif
	EndIf

	//Zerando os arrays e os Objetos utilizados no processamento	
	aSize( aRulesCad, 0 )
	aRules := Nil
	
	aSize( aRulesVinc, 0 )
	aRules := Nil
	
	aSize( aChave, 0 )
	aChave := Nil
	
EndIf

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Xml

Funcao de geracao do XML para atender os registros S-2200.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2200

@author Felipe C. Seolin / Rodrigo Aguilar
@since 25/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF278Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml    	 := ""
	Local cReg    	 := "Admissao"
	Local cLayout	 := "2200"
	Local cAliasDep	 := "C9Y"
	Local cAliasHora := "CRQ"
	Local cAliasSind := "T80"
	Local cAliasObs	 := "T90"
	Local cAliasCap	 := "V87"

	Default cAlias	:= ""
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default lJob	:= .F.

	cXml += FGetCad( cLayout, "C9V", cAliasDep  )

	dbSelectArea("CUP")
	dbSetOrder(1)

	IF msSeek(xFilial("CUP") + C9V->(C9V_ID +C9V_VERSAO))
		cXml += FGetVinc( cLayout, "CUP", cAliasHora, cAliasSind, cAliasObs,, cAliasCap )
	Endif

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, "C9V", cLayout, cReg )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 04/12/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local aGrava     := {}
	Local aGravaCUP  := {}
	Local aGravaC9Y  := {}
	Local aGravaCRQ  := {}
	Local aGravaT3L  := {}
	Local aGravaT80  := {}
	Local aGravaT90  := {}
	Local aGravaV87  := {}

	//Carrego a Estrutura dos Models a serem gravados
	Local oModelC9V := oModel:GetModel( "MODEL_C9V" )
	Local oModelCUP := oModel:GetModel( "MODEL_CUP" )
	Local oModelC9Y := oModel:GetModel( "MODEL_C9Y" )
	Local oModelCRQ := oModel:GetModel( "MODEL_CRQ" )							
	Local oModelT3L := oModel:GetModel( "MODEL_T3L" )
	Local oModelT80 := oModel:GetModel( "MODEL_T80" )
	Local oModelT90 := oModel:GetModel( "MODEL_T90" )
	Local oModelV87 := oModel:GetModel( "MODEL_V87" )

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("C9V")->( DBGoTo( nRecno ) )
						
		//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )
		TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, @aGrava, @aGravaCUP, @aGravaC9Y, @aGravaCRQ, @aGravaT3L, @aGravaT80, @aGravaT90, oModelV87, @aGravaV87 )
		
		/*---------------------------------------------------------- 
		Seto o campo como Inativo e gravo a versao do novo registro
		no registro anterior                                       
				
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima 
		-----------------------------------------------------------*/
		FAltRegAnt( "C9V", "2" )
		
		//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF278CARR 
		TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90, .T., oModelV87, @aGravaV87 )
		
		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, "MODEL_C9V", "C9V" )
		EndIf
		
		FwFormCommit( oModel )
		TAFAltStat( 'C9V',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelC9V - Model da tabela C9V
oModelC9Y - Model da tabela C9Y
aGrava    - Array que armazena as informações da tabela C9V
aGravaC9Y - Array que armazena as informações da tabela C9Y

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90, oModelV87, aGravaV87 )
 
	Local nI := 0
		
	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelC9Y	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil
	Default oModelV87	:= Nil

	Default aGrava	    := {}
	Default aGravaCUP	:= {}
	Default aGravaC9Y	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}
	Default aGravaV87	:= {}

	nI := 0

	//******************
	//Dados do Trabalhor
	//******************                         
	For nI := 1 to Len( oModelC9V:aDataModel[ 1 ] )
		Aadd( aGrava, { oModelC9V:aDataModel[ 1, nI, 1 ], oModelC9V:aDataModel[ 1, nI, 2 ] } )
	Next nI
	//------------------
					
	//*******
	//Vinculo
	//*******
	For nI := 1 to Len( oModelCUP:aDataModel[ 1 ] )
		Aadd( aGravaCUP, { oModelCUP:aDataModel[ 1, nI, 1 ], oModelCUP:aDataModel[ 1, nI, 2 ] } )
	Next nI
	//-------
					
	//***********
	//Dependentes
	//***********

	If lLaySimplif == Nil
		TAF278Lay() //Inicializa a variável static lLaySimplif
	EndIf

	For nI := 1 to oModel:GetModel( "MODEL_C9Y" ):Length()
		oModel:GetModel( "MODEL_C9Y" ):GoLine(nI)
			If !oModel:GetModel( 'MODEL_C9Y' ):IsEmpty()
				If !oModel:GetModel( "MODEL_C9Y" ):IsDeleted()
					If lLaySimplif
						aAdd(aGravaC9Y,{oModelC9Y:GetValue("C9Y_IDDEP"),;
							oModelC9Y:GetValue("C9Y_TPDEP"),;
							oModelC9Y:GetValue("C9Y_NOMDEP"),;
							oModelC9Y:GetValue("C9Y_DTNASC"),;
							oModelC9Y:GetValue("C9Y_CPFDEP"),;
							oModelC9Y:GetValue("C9Y_DEPIRF"),;
							oModelC9Y:GetValue("C9Y_DEPSFA"),;       
							oModelC9Y:GetValue("C9Y_INCTRB"),;					
							oModelC9Y:GetValue("C9Y_SEXDEP"),;					
							})
					Else
						aAdd(aGravaC9Y,{oModelC9Y:GetValue("C9Y_IDDEP"),;
							oModelC9Y:GetValue("C9Y_TPDEP"),;
							oModelC9Y:GetValue("C9Y_NOMDEP"),;
							oModelC9Y:GetValue("C9Y_DTNASC"),;
							oModelC9Y:GetValue("C9Y_CPFDEP"),;
							oModelC9Y:GetValue("C9Y_DEPIRF"),;
							oModelC9Y:GetValue("C9Y_DEPSFA"),;       
							oModelC9Y:GetValue("C9Y_INCTRB"),;	
							})
					EndIf
				EndIf
			EndIf
	Next nI
	//-----------
					
	//*****************
	//Horario Contratual
	//*****************
	For nI := 1 to oModel:GetModel( "MODEL_CRQ" ):Length()
		oModel:GetModel( "MODEL_CRQ" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_CRQ" ):IsDeleted()
			aAdd(aGravaCRQ,{oModelCRQ:GetValue("CRQ_CODDIA"),;
				oModelCRQ:GetValue("CRQ_CODHOR")})
		EndIf
	Next nI					
	//-----------------
					
	//***********************
	//Trabalhador Substituido
	//***********************
	For nI := 1 to oModel:GetModel( "MODEL_T3L" ):Length()
		oModel:GetModel( "MODEL_T3L" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T3L" ):IsDeleted()
			aAdd(aGravaT3L,{oModelT3L:GetValue("T3L_CPF")})
		EndIf
	Next nI					
	//----------------------		

	//*********************************
	//Filiação Sindical do Trabalhador
	//*********************************
	For nI := 1 to oModel:GetModel( "MODEL_T80" ):Length()
		oModel:GetModel( "MODEL_T80" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T80" ):IsDeleted()
			aAdd(aGravaT80,{oModelT80:GetValue("T80_CNPJSD")})
		EndIf
	Next nI					
	//----------------------				

	//************************************
	//Observações do contrato de trabalho
	//************************************
	For nI := 1 to oModel:GetModel( "MODEL_T90" ):Length()
		oModel:GetModel( "MODEL_T90" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T90" ):IsDeleted()
			aAdd(aGravaT90,{oModelT90:GetValue("T90_CODOBS"),;
							oModelT90:GetValue("T90_OBSERV")})
		EndIf
	Next nI					
	//----------------------

	//************************************
	//Cadastro Código de Treinamento
	//************************************
	If lLaySimplif .And. oModelV87 != Nil
		For nI := 1 to oModel:GetModel( "MODEL_V87" ):Length()
			oModel:GetModel( "MODEL_V87" ):GoLine(nI)
			If !oModel:GetModel( "MODEL_V87" ):IsDeleted()
				aAdd(aGravaV87,{oModelV87:GetValue("V87_CODTRE")})
			EndIf
		Next nI
	EndIf
//----------------------
                        
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelC9V - Model da tabela C9V
oModelC9Y - Model da tabela C9Y
aGrava    - Array que armazena as informações da tabela C9V
aGravaC9Y - Array que armazena as informações da tabela C9Y
lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90, lExclu, oModelV87, aGravaV87 )

	Local cVersao   	:= ""
	Local cVerAnt   	:= ""
	Local cProtocolo	:= ""
	Local cEvento   	:= ""
	Local nI 		 	:= 0

	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelC9Y	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil
	Default oModelV87	:= Nil

	Default aGrava	    := {}
	Default aGravaCUP	:= {}
	Default aGravaC9Y	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}
	Default lExclu		:= .F.
	Default aGravaV87	:= {}

	cVersao   	:= ""
	cVerAnt   	:= ""
	cProtocolo	:= ""
	cEvento   	:= ""
	nI 		 	:= 0	
		
	/*----------------------------------------------------------
	Apos deixar o registro corrente como inativo eu seto a 
	operação para o novo registro
	-----------------------------------------------------------*/
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()
		
	/*----------------------------------------------------------
	Neste momento eu realizo a gravação de um novo registro idêntico
	ao original, apenas com as alterações nos campos modificados
	pelo usuário no cadastro
	-----------------------------------------------------------*/			

	//******************
	//Dados do Trabalhor
	//******************         		
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_C9V", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI

	//*******
	//Vinculo
	//*******
	For nI := 1 to Len( aGravaCUP )
		oModel:LoadValue( "MODEL_CUP", aGravaCUP[ nI, 1 ], aGravaCUP[ nI, 2 ] )
	Next nI
							
	//***********
	//Dependentes
	//***********	
	If lLaySimplif == Nil
		TAF278Lay() //Inicializa a variável static lLaySimplif
	EndIf
	For nI := 1 to Len( aGravaC9Y )
		If nI > 1
			oModel:GetModel( "MODEL_C9Y" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP" , aGravaC9Y[nI][1] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_TPDEP" , aGravaC9Y[nI][2] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_NOMDEP", aGravaC9Y[nI][3] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DTNASC", aGravaC9Y[nI][4] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_CPFDEP", aGravaC9Y[nI][5] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPIRF", aGravaC9Y[nI][6] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPSFA", aGravaC9Y[nI][7] )                                                                                                                           
		oModel:LoadValue( "MODEL_C9Y", "C9Y_INCTRB", aGravaC9Y[nI][8] )
		If lLaySimplif
			oModel:LoadValue( "MODEL_C9Y", "C9Y_SEXDEP", aGravaC9Y[nI][9] )
		EndIf
	Next nI
						
	//*****************
	//Horario Contratual
	//***************** 
	For nI := 1 to Len( aGravaCRQ )
		If nI > 1
			oModel:GetModel( "MODEL_CRQ" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA" , aGravaCRQ[nI][1] )
		oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , aGravaCRQ[nI][2] )
	Next nI		   
						
	//***********************
	//Trabalhador Substituido
	//***********************
	For nI := 1 to Len( aGravaT3L )
		If nI > 1
			oModel:GetModel( "MODEL_T3L" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T3L", "T3L_CPF" , aGravaT3L[nI][1] )
	Next nI

	//********************************
	//Filiação Sindical do Trabalhador
	//********************************
	For nI := 1 to Len( aGravaT80 )
		If nI > 1
			oModel:GetModel( "MODEL_T80" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T80", "T80_CNPJSD" , aGravaT80[nI][1] )
	Next nI					
	//----------------------

	//***********************************
	//Observações do contrato de trabalho
	//***********************************
	For nI := 1 to Len( aGravaT90 )
		If nI > 1
			oModel:GetModel( "MODEL_T90" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T90", "T90_CODOBS" , aGravaT90[nI][1] )
		oModel:LoadValue( "MODEL_T90", "T90_OBSERV" , aGravaT90[nI][2] )
	Next nI				
	//----------------------

	//***********************************
	//Cadastro Código de Treinamento
	//***********************************
	If lLaySimplif .And. TAFColumnPos("V87_CODTRE")
		For nI := 1 to Len( aGravaV87 )
			If nI > 1
				oModel:GetModel( "MODEL_V87" ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_V87", "V87_CODTRE" , aGravaV87[nI][1] )
		Next nI					
	EndIf
	//----------------------

	cVersao := xFunGetVer()

	cVerAnt    := C9V->C9V_VERSAO
	cProtocolo := C9V->C9V_PROTUL
	cEvento    := C9V->C9V_EVENTO

	oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_C9V", "C9V_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_C9V", "C9V_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_C9V", "C9V_PROTUL", "" )
	oModel:LoadValue( "MODEL_C9V", "C9V_STATUS", "" )
	// Tratamento para limpar o ID unico do xml
	cAliasPai := "C9V"
	If TAFColumnPos( cAliasPai+"_XMLID" )
		oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
	EndIf

	IF lExclu
		oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "E" )
		oModel:LoadValue( "MODEL_C9V", "C9V_ATIVO", "1" )
	Else
		If cEvento == "I"
			oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "A" )
		EndIf
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} UpdateNIS
Atualiza o NIS do trabalhador caso o mesmo possua um 2205.

@author Robson Santos
@since 25/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function UpdateNIS(oView, oModel)

	//-- se não for exclusão
	If oView:GetOperation() <> MODEL_OPERATION_DELETE .And. oView:GetOperation() <> MODEL_OPERATION_INSERT
		FwFldPut("C9V_NIS", TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, DTOS(C9V->C9V_DTALT) ),,,,.T.)	
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEmpFilG
Carrega informações do sigamat.emp

@author Equipe TAF e-social
@since 24/07/2019
/*/
//---------------------------------------------------------------------
Static Function TAFEmpFilG()
         
	Local aEmpFil := {}
	Local aSM0    := ftafGetSM0()
	Local nY      := 0
	Local cCodEmp := "" 
	Local cCodFil := ""
	Local nRecno

	IF ( Select( "SM0" ) == 0 )
		Private cArqEmp := "sigamat.emp"
		OpenSM0()
	EndIF

	IF ( Select( "SM0" ) > 0 )   

		For nY := 1 To Len(aSM0)
			
			cCodEmp := aSM0[nY][SM0_GRPEMP]
			cCodFil := aSM0[nY][SM0_CODFIL]
			nRecno  := aSM0[nY][SM0_RECNO] 
		
			aAdd( aEmpFil , { cCodEmp , cCodFil , nRecno } )
			
		Next nY
		
	EndIF

Return( aClone( aEmpFil ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} ftafGetSM0
Retorna Array com as informações do Sigamat.

@author Equipe TAF e-social
@since 24/07/2019
/*/
//---------------------------------------------------------------------
Static Function ftafGetSM0(lFilterGrup)

	Local aSM0      := FWLoadSM0()
	Local aRetSm0   := {} 
	Local i         := 0       

	Default lFilterGrup := .F.
			
	For i := 1 To Len(aSM0)
		If	lFilterGrup .AND. aSM0[i][SM0_GRPEMP] == cEmpAnt
			IF Empty(aSM0[i][SM0_EMPRESA])
				aSM0[i][SM0_EMPRESA] :=	aSM0[i][SM0_GRPEMP] 
			Endif
			aAdd( aRetSm0 , aSM0[i] )
		Elseif !(lFilterGrup)
			IF Empty(aSM0[i][SM0_EMPRESA])
				aSM0[i][SM0_EMPRESA] :=	aSM0[i][SM0_GRPEMP]
			Endif  					    
			aAdd( aRetSm0 , aSM0[i] )
		Endif 					
	Next i

Return (aRetSm0)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF278Lay
@type			function
@description	Inicializa a variável static lLaySimplif
@author			Veronica de Almeida
@since			02/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF278Lay()

	lLaySimplif := TafLayESoc("S_01_00_00")

Return

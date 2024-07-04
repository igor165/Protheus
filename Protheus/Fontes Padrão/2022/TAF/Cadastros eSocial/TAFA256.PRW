#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA256.CH"
#INCLUDE "TOPCONN.CH"

Static lLaySimplif := taflayEsoc("S_01_00_00")

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA256
Cadastro MVC de Admissão do trabalhador - 2200

@author Felipe C. Seolin / Rodrigo Aguilar
@since 09/09/2013
@version 1.0
/*/
//
//---------------------------------------------------------------------
Function TAFA256()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funçao generica MVC com as opcoes de menu

@Return aRotina - Array com as opções do Menu

@author Felipe C. Seolin / Rodrigo Aguilar
@since 09/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TAF256XMLVLD(1)"	, "1" } )
	Aadd( aFuncao, { "" , "TAF256XMLVLD(2)"	, "2" } )
	Aadd( aFuncao, { "" , "xCarrHisAlt" 	, "3" } )
	Aadd( aFuncao, { "" , "ExcXmlLote" 		, "5" } )

	//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif
		ADD OPTION aRotina Title STR0002 Action 'xCarrVisul' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA256" , , aFuncao )
	EndIf

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 09/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC9V := FwFormStruct( 1, "C9V" )
	Local oStruT2E := FwFormStruct( 1, "T2E" )
	Local oStruCUP := FwFormStruct( 1, "CUP" )
	Local oStruCRQ := FwFormStruct( 1, "CRQ" )
	Local oStruT3L := FwFormStruct( 1, "T3L" )
	Local oStruT80 := FwFormStruct( 1, "T80" )
	Local oStruT90 := FwFormStruct( 1, "T90" )
	Local oModel   := MpFormModel():New( "TAFA256",,,{ |oModel| SaveModel( oModel ) } )

	//Indica se o Model devera ser validado quando realizada operações
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruC9V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2E:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
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
	oStruC9V:SetProperty( 'C9V_NIS'   , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_NOME'  , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_SEXO'  , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_RCCOR' , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_GRINST', MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_DTNASC', MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_CODPAI', MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_PAINAC', MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_PAIS'  , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC9V:SetProperty( 'C9V_APOSEN', MODEL_FIELD_OBRIGAT , .F.  )

	//CUP - Cadastro Inicial do Vínculo
	oModel:AddFields( "MODEL_CUP", "MODEL_C9V", oStruCUP )

	//T2E - Cadastro de Dependentes
	oModel:AddGrid ( "MODEL_T2E", "MODEL_C9V", oStruT2E )
	oModel:GetModel( "MODEL_T2E" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T2E" ):SetUniqueLine( { "T2E_TPDEP","T2E_NOMDEP","T2E_DTNASC"} )

	//CRQ - Informações do horário contratual
	oModel:AddGrid ( "MODEL_CRQ", "MODEL_CUP", oStruCRQ )
	oModel:GetModel( "MODEL_CRQ" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_CRQ" ):SetUniqueLine( { "CRQ_CODDIA","CRQ_CODHOR" } )

	//T3L - Identificação do trabalhador substituído
	oModel:AddGrid ( "MODEL_T3L", "MODEL_CUP", oStruT3L )
	oModel:GetModel( "MODEL_T3L" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3L" ):SetUniqueLine( { "T3L_CPF","T3L_NOMEVE"  } )

	//T80 - Filiação Sindical do Trabalhador
	oModel:AddGrid ( "MODEL_T80", "MODEL_CUP", oStruT80 )
	oModel:GetModel( "MODEL_T80" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T80" ):SetUniqueLine( { "T80_CNPJSD" } )
	oModel:GetModel( "MODEL_T80" ):SetMaxLine(2)

	//T90 - Observações do contrato de trabalho
	oModel:AddGrid ( "MODEL_T90", "MODEL_CUP", oStruT90 )
	oModel:GetModel( "MODEL_T90" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T90" ):SetUniqueLine( { "T90_CODOBS" } )
	oModel:GetModel( "MODEL_T90" ):SetMaxLine(99)

	/*-----------------------------------------------------------------------------------
	Abaixo realiza-se a amarração das tabelas, no caso deste cadastro a tabela
	CUP NÃO é filha da tabela C9V, porém por questões de normalização as informações
	foram desmembradas em duas tabelas, o mesmo ocorre para as tabelas T3L e CRQ, que
	pelo Layout são filhas da CUP mas no TAF ficam como filhas da tabela C9V.
	-------------------------------------------------------------------------------------*/
	oModel:SetRelation( "MODEL_T2E",{ { "T2E_FILIAL", "xFilial('T2E')" }, { "T2E_ID", "C9V_ID" }, { "T2E_VERSAO", "C9V_VERSAO" }, { "T2E_NOMEVE", "C9V_NOMEVE" } },T2E->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_CUP",{ { "CUP_FILIAL", "xFilial('CUP')" }, { "CUP_ID", "C9V_ID" }, { "CUP_VERSAO", "C9V_VERSAO" }, { "CUP_NOMEVE", "C9V_NOMEVE" } },CUP->( IndexKey( 4 ) ) )
	oModel:SetRelation( "MODEL_CRQ",{ { "CRQ_FILIAL", "xFilial('CRQ')" }, { "CRQ_ID", "C9V_ID" }, { "CRQ_VERSAO", "C9V_VERSAO" }, { "CRQ_NOMEVE", "C9V_NOMEVE" } },CRQ->( IndexKey( 3 ) ) )
	oModel:SetRelation( "MODEL_T3L",{ { "T3L_FILIAL", "xFilial('T3L')" }, { "T3L_ID", "C9V_ID" }, { "T3L_VERSAO", "C9V_VERSAO" }, { "T3L_NOMEVE", "C9V_NOMEVE" } },T3L->( IndexKey( 3 ) ) )
	oModel:SetRelation( "MODEL_T80",{ { "T80_FILIAL", "xFilial('T80')" }, { "T80_ID", "C9V_ID" }, { "T80_VERSAO", "C9V_VERSAO" }, { "T80_NOMEVE", "C9V_NOMEVE" } },T80->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_T90",{ { "T90_FILIAL", "xFilial('T90')" }, { "T90_ID", "C9V_ID" }, { "T90_VERSAO", "C9V_VERSAO" }, { "T90_NOMEVE", "C9V_NOMEVE" } },T90->( IndexKey( 1 ) ) )
	
	//Define a chave única de gravação das informações
	oModel:GetModel("MODEL_C9V"):SetPrimaryKey({ "C9V_CPF", "C9V_MATRIC","C9V_NOMEVE" })

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View
@return oView - Objeto da View MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 09/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFil

	Local cGrpVinc
	Local cGrpVinc1
	Local cGrpVinc2
	Local cGrpVinc3
	Local cGrpVinc4
	Local cGrpVinc5
	Local cGrpVinc6

	Local cGrpCelet
	Local cGrpCelet1
	Local cGrpCelet2
	Local cGrpCelet3
	Local cGrpCelet4
	Local cGrpCelet5
	Local cGrpCelet6

	Local cGrpContr
	Local cGrpContr1
	Local cGrpContr2
	Local cGrpContr3
	Local cGrpContr4
	Local cGrpContr5
	Local cGrpContr6
	Local cGrpContr7

	Local cGrpTra1
	Local cGrpTra2
	Local cGrpTra3
	Local cGrpTra4
	Local cGrpTra5
	Local cGrpTra6
	Local cGrpTra7
	Local cGrpTra8
	Local cGrpTra9
	Local cGrpTra10

	Local nI

	Local aCmpGrp

	Local oModel
	Local oView

	Local oStruT2E
	Local oStruCUP
	Local oStruCRQ
	Local oStruT3L
	Local oStruT80
	Local oStruT90

	Local oStruC9Va
	Local oStruC9Vb
	Local oStruC9Vc
	Local oStruC9Vd
	Local oStruC9Ve
	Local oStruC9Vf
	Local oStruCUPa
	Local oStruCUPb
	Local oStruCUPc
	Local oStruCUPd
	Local lCmpEdit

	nI			:= 0
	aCmpGrp		:= {}
	lCmpEdit	:= .F.
	cCmpFil		:= ""
	cGrpVinc	:= ""
	cGrpVinc1	:= ""
	cGrpVinc2	:= ""
	cGrpVinc3	:= ""
	cGrpVinc4	:= ""
	cGrpVinc5	:= ""
	cGrpVinc6	:= ""

	cGrpCelet	:= ""
	cGrpCelet1	:= ""
	cGrpCelet2	:= ""
	cGrpCelet3	:= ""
	cGrpCelet4	:= ""
	cGrpCelet5	:= ""
	cGrpCelet6	:= ""

	cGrpContr	:= ""
	cGrpContr1	:= ""
	cGrpContr2	:= ""
	cGrpContr3	:= ""
	cGrpContr4	:= ""
	cGrpContr5	:= ""
	cGrpContr6	:= ""
	cGrpContr7	:= ""
	cGrpTra1	:= ""
	cGrpTra2	:= ""
	cGrpTra3	:= ""
	cGrpTra4	:= ""
	cGrpTra5	:= ""
	cGrpTra6	:= ""
	cGrpTra7	:= ""
	cGrpTra8	:= ""
	cGrpTra9	:= ""
	cGrpTra10	:= ""

	oModel		:= Nil
	oView		:= Nil
	oStruT2E	:= Nil
	oStruCUP	:= Nil
	oStruCRQ	:= Nil
	oStruT3L	:= Nil
	oStruT80	:= Nil
	oStruT90	:= Nil
	oStruC9Va	:= Nil
	oStruC9Vb	:= Nil
	oStruC9Vc	:= Nil
	oStruC9Vd	:= Nil
	oStruC9Ve	:= Nil
	oStruC9Vf	:= Nil
	oStruCUPa	:= Nil
	oStruCUPb	:= Nil
	oStruCUPc	:= Nil
	oStruCUPd	:= Nil

	oModel    := FWLoadModel( "TAFA256" )
	oView     := FWFormView():New()

	oStruT2E  := FWFormStruct( 2, "T2E" )
	oStruCUP  := FWFormStruct( 2, "CUP" )
	oStruCRQ  := FWFormStruct( 2, "CRQ" )
	oStruT3L  := FWFormStruct( 2, "T3L" )
	oStruT80  := FWFormStruct( 2, "T80" )
	oStruT90  := FWFormStruct( 2, "T90" )

	//Seto o Model que sera utilizado no processamento
	oView:SetModel( oModel )

	/*-----------------------------------------------------------------------------------
							Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/
	cGrpTra1  := "C9V_ID|C9V_VERSAO|C9V_VERANT|C9V_PROTPN|C9V_EVENTO|C9V_ATIVO|C9V_CPF|C9V_NIS|C9V_NOME|C9V_NOMSOC|C9V_SEXO|C9V_RCCOR|C9V_ESTCIV|C9V_GRINST|C9V_DGRINS|"
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
	oStruC9Va := FwFormStruct( 2, "C9V",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes do Trabalhador

	cCmpFil   := "C9V_DTCHEG|C9V_CCTRAE|C9V_DCONTE|C9V_CASBRA|C9V_FILBRA|"
	oStruC9Vb := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Trabalhador Estrangeiro

	cCmpFil   := "C9V_DEFINT|C9V_DEFFIS|C9V_DEFMOT|C9V_DEFVIS|C9V_DEFAUD|C9V_REABIL|C9V_INFCOT|C9V_DEFMEN|C9V_OBSDEF|"
	oStruC9Vc := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Deficiencias

	cCmpFil   := "C9V_DDDFPR|C9V_FONPRC|C9V_DDDFAL|C9V_FONALT|C9V_EMAILP|C9V_EMAILA|"
	oStruC9Vd := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações de Contato

	cCmpFil   := "C9V_PROTUL|"
	oStruC9Ve := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

	/*-----------------------------------------------------------------------------------
							Estrutura da View do Vínculo
	-------------------------------------------------------------------------------------*/
	cGrpVinc	:= "C9V_MATRIC|"
	oStruC9Vf	:= FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cGrpVinc } ) //Campo Matrícula do Trabalhador

	cGrpVinc2	:= "CUP_TPREGT|CUP_TPREGP|"


	If TafColumnPos("CUP_INSANT")
		cGrpVinc3	:= "CUP_INSANT|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|"	
	EndIf
	cGrpVinc4	:= "CUP_DTINIA|CUP_MOTVAF|CUP_DMOTVA|"
	cGrpVinc5	:= "CUP_DTDESL|"
	cGrpVinc6	:= "CUP_CPFSUB|CUP_MATRAN|CUP_DTTRAN|"

	cGrpVinc1	+= cGrpVinc2 + cGrpVinc3 + cGrpVinc4 + cGrpVinc5 + cGrpVinc6
	oStruCUPa	:= FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpVinc1 } ) //Campos do folder Informações de Vínculo

	/*-----------------------------------------------------------------------------------
							Estrutura da View do Trabalhador Celetista
	-------------------------------------------------------------------------------------*/
	cGrpCelet1 := "CUP_DTADMI|CUP_TPADMI|CUP_INDADM|CUP_TPREGJ|CUP_NATATV|CUP_DATAB|CUP_CNPJCP|"
	cGrpCelet2 := "CUP_FGTSOP|CUP_DTFGTS|"
	If lLaySimplif .AND. TafColumnPos("CUP_NRPROC")
		cGrpCelet3 := "CUP_MOTCON|CUP_JUSHIP|CUP_TPINCL|CUP_NRPROC|"
	Else 
		cGrpCelet3 := "CUP_MOTCON|CUP_JUSHIP|CUP_TPINCL|"
	EndIf 

	If !lLaySimplif
		cGrpCelet4 := "CUP_TPINST|CUP_NRINST|"
		cGrpCelet5 := "CUP_TPINTT|CUP_NRINTT|"
	EndIf 
	
	cGrpCelet6 := "CUP_TPINAP|CUP_NRINAP|"

	cGrpCelet += cGrpCelet1 + cGrpCelet2 + cGrpCelet3 + cGrpCelet4 + cGrpCelet5 + cGrpCelet6
	oStruCUPb := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpCelet } ) //Campos do folder Trabalhador Celetista

	/*-----------------------------------------------------------------------------------
							Estrutura da View do Trabalhador Estatutário
	-------------------------------------------------------------------------------------*/
	If lLaySimplif .and. TafColumnPos("CUP_TERGPS") .and. TafColumnPos("CUP_ABOPER") .and. TafColumnPos("CUP_DTABON")

		cCmpFil   := "CUP_INDPRO|CUP_TIPPRO|CUP_DTNOME|CUP_DTPOSS|CUP_DTEXER|CUP_TPLASM|CUP_NPROJE|CUP_DNPRJE|CUP_TERGPS|CUP_ABOPER|CUP_DTABON|"


	Else 

		cCmpFil   := "CUP_INDPRO|CUP_TIPPRO|CUP_DTNOME|CUP_DTPOSS|CUP_DTEXER|CUP_TPLASM|CUP_NPROJE|CUP_DNPRJE|"
	
	EndIf
	oStruCUPc := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Trabalhador Estatutário

	/*-----------------------------------------------------------------------------------
							Estrutura da View do Contrato de Trabalho
	-------------------------------------------------------------------------------------*/
	cGrpContr1 := "CUP_CODCGO|CUP_DCODCG|CUP_CODFUN|CUP_DCODFU|CUP_CODCAT|CUP_DCODCA|CUP_CODCAR|CUP_DESCAR|CUP_DTINGC|"

	If !lLaySimplif
		cGrpContr2 := "CUP_VLSLFX|CUP_UNSLFX|CUP_DESSVR|"
	Else
		cGrpContr2 := "CUP_VLSLFX|CUP_UNSLFX|CUP_DSCSAL|"
	EndIf

	If TafColumnPos("CUP_OBJDET")
		cGrpContr3 := "CUP_TPCONT|CUP_DTTERM|CUP_CLAUAS|CUP_OBJDET|"
	EndIf 
	
	cGrpContr4 := "CUP_TPINSC|CUP_NRINSC|CUP_DESLOT|"
	cGrpContr5 := "CUP_TPLOGD|CUP_DSCTPL|CUP_DELOGD|CUP_NRLOGD|CUP_COMLGD|CUP_BAIRTD|CUP_CEPLTD|CUP_CMUNTD|CUP_DSCMTD|CUP_UFTRBD|CUP_DUFTRD|"
	cGrpContr6 := "CUP_QTDHJS|CUP_TPJORN|CUP_DTPJOR|CUP_TMPARC|"
	cGrpContr7 := "CUP_ALVJUD|CUP_DALVJU|"

	cGrpContr += cGrpContr1 + cGrpContr2 + cGrpContr3 + cGrpContr4 + cGrpContr5 + cGrpContr6 + cGrpContr7
	oStruCUPd := FwFormStruct( 2, "CUP",{|x| AllTrim( x ) + "|" $ cGrpContr } ) //Campos do folder Contrato de Trabalho

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
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_10", STR0038, "", 1 ) //Informações sobre Aposentadoria

	aCmpGrp := StrToKArr(cGrpTra1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpTra2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
	Next nI

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

	aCmpGrp := StrToKArr(cGrpTra9,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_09")
	Next nI

	aCmpGrp := StrToKArr(cGrpTra10,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_10")
	Next nI

	/*-----------------------------------------------------------------------------------
							Grupo de campos do Vínculo
	-------------------------------------------------------------------------------------*/
	oStruC9Vf:AddGroup("GRP_VINCULO_01",STR0029,"",1)//Dados do Vínculo
	oStruCUPa:AddGroup("GRP_VINCULO_01",""     ,"",1)//Dados do Vínculo
	oStruCUPa:AddGroup("GRP_VINCULO_02",STR0030,"",1)//Informações da Sucessão de vínculo trabalhista
	oStruCUPa:AddGroup("GRP_VINCULO_03",STR0031,"",1)//Informações sobre o ASO Admissional
	oStruCUPa:AddGroup("GRP_VINCULO_04",STR0060,"",1)//Informações do Afastamento do Trabalhador
	oStruCUPa:AddGroup("GRP_VINCULO_05",STR0061,"",1)//Informações do Desligamento do Trabalhador
	oStruCUPa:AddGroup("GRP_VINCULO_06",STR0068,"",1)//Informações do Empregado Doméstico Transferido


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


	/*-----------------------------------------------------------------------------------
							Grupo de campos do Trabalhador Celetista
	-------------------------------------------------------------------------------------*/
	oStruCUPb:AddGroup("GRP_CELETISTA_01",STR0050,"",1) //Informações de Trabalhador Celetista
	oStruCUPb:AddGroup("GRP_CELETISTA_02",STR0040,"",1) //Informações do FGTS
	oStruCUPb:AddGroup("GRP_CELETISTA_03",STR0037,"",1) //Dados sobre Trabalho Temporário
	oStruCUPb:AddGroup("GRP_CELETISTA_04",STR0066,"",1) //Identificação do Tomador de Serviço
	oStruCUPb:AddGroup("GRP_CELETISTA_05",STR0067,"",1) //Identificação do Estabelecimento Vinculado
	oStruCUPb:AddGroup("GRP_CELETISTA_06",STR0064,"",1) //Identificação do Contratante de Aprendiz

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
	oStruCUPd:AddGroup("GRP_CONTRATO_03",STR0034,"",1) //Duração do Contrato de Trabalho
	oStruCUPd:AddGroup("GRP_CONTRATO_04",STR0036,"",1) //Informações do local de Trabalho
	oStruCUPd:AddGroup("GRP_CONTRATO_05",STR0039,"",1) //Local Trabalhador Doméstico
	oStruCUPd:AddGroup("GRP_CONTRATO_06",STR0046,"",1) //Informações do Horário Contratual
	oStruCUPd:AddGroup("GRP_CONTRATO_07",STR0048,"",1) //Informações do Alvará Judicial

	aCmpGrp := StrToKArr(cGrpContr1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpContr2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCUPd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRATO_02")
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

	/*====================================================================================
                            Validação dos Campos editáveis:
	Em caso de retificação eu permito editar, apenas os campos que NÃO estão nos eventos
	de alteração (S2205 ou S2206)
	======================================================================================*/
	If Type( "INCLUI" ) <> "U"
		lCmpEdit := IIF(INCLUI .OR. (ALTERA .AND. C9V->C9V_STATUS <> '4'),.T.,.F.)
	endif

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

	oStruT2E:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
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
	//oStruC9V:SetProperty( "C9V_PRIEMP", MVC_VIEW_CANCHANGE , .T. )

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

	/*-----------------------------------------------------------------------------------
							Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_C9Va", oStruC9Va, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vb", oStruC9Vb, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vc", oStruC9Vc, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vd", oStruC9Vd, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Ve", oStruC9Ve, "MODEL_C9V" )
	oView:AddField( "VIEW_C9Vf", oStruC9Vf, "MODEL_C9V" )
	oView:AddField( "VIEW_CUPa", oStruCUPa, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPb", oStruCUPb, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPc", oStruCUPc, "MODEL_CUP" )
	oView:AddField( "VIEW_CUPd", oStruCUPd, "MODEL_CUP" )

	oView:AddGrid( "VIEW_T2E", oStruT2E, "MODEL_T2E" )
	oView:AddIncrementField( "VIEW_T2E", "T2E_IDDEP" )

	oView:AddGrid( "VIEW_CRQ", oStruCRQ, "MODEL_CRQ" )
	oView:EnableTitleView("VIEW_CRQ",STR0049) //"Informações Diárias do Horário Contratual."

	oView:AddGrid( "VIEW_T3L", oStruT3L, "MODEL_T3L" )
	oView:EnableTitleView("VIEW_T3L",STR0045) //"Identificação do Trabalhador Substituído."

	oView:AddGrid( "VIEW_T80", oStruT80, "MODEL_T80" )
	oView:EnableTitleView("VIEW_T80",STR0065) //"Filiação Sindical do Trabalhador"

	oView:AddGrid( "VIEW_T90", oStruT90, "MODEL_T90" )
	oView:EnableTitleView("VIEW_T90",STR0069) //"Observações do Contrato de Trabalho"
	oView:AddIncrementField( "VIEW_T90", "T90_CODOBS" )

	/*-----------------------------------------------------------------------------------
							Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0012) //Trabalhador

	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0017) //Vínculo

	oView:AddSheet("FOLDER_PRINCIPAL","ABA03",STR0043) //"Protocolo de Transmissão"
	oView:CreateHorizontalBox("C9Ve",100,,,"FOLDER_PRINCIPAL","ABA03")

	//////////////////////////////////////////////////////////////////////////////////

	oView:CreateHorizontalBox("PAINEL_TRABALHADOR",100,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder("TRABALHADOR","PAINEL_TRABALHADOR")

	oView:AddSheet("TRABALHADOR","ABA01",STR0013) //Informações do Trabalhador
	oView:CreateHorizontalBox("C9Va",100,,,"TRABALHADOR","ABA01")

	oView:AddSheet("TRABALHADOR","ABA02",STR0014) //Informações de Trabalhador Estrangeiro
	oView:CreateHorizontalBox("C9Vb",100,,,"TRABALHADOR","ABA02")

	oView:AddSheet("TRABALHADOR","ABA03",STR0015) //Informações Deficiência
	oView:CreateHorizontalBox("C9Vc",100,,,"TRABALHADOR","ABA03")

	oView:AddSheet("TRABALHADOR","ABA04",STR0016) //Dependentes
	oView:CreateHorizontalBox("T2E" ,100,,,"TRABALHADOR","ABA04")

	oView:AddSheet("TRABALHADOR","ABA05",STR0010) //Informações de Contato
	oView:CreateHorizontalBox("C9Vd",100,,,"TRABALHADOR","ABA05")

	//////////////////////////////////////////////////////////////////////////////////

	oView:CreateHorizontalBox("PAINEL_VINCULO",100,,,"FOLDER_PRINCIPAL","ABA02")
	oView:CreateFolder("VINCULO","PAINEL_VINCULO")

	oView:AddSheet("VINCULO","ABA01",STR0018)//Informações do Vínculo
	oView:CreateHorizontalBox("C9Vf",15,,,"VINCULO","ABA01")
	oView:CreateHorizontalBox("CUPa",85,,,"VINCULO","ABA01")

	oView:AddSheet("VINCULO","ABA02",STR0056)//Trabalhador Celetista
	oView:CreateHorizontalBox("CUPb",70,,,"VINCULO","ABA02")
	oView:CreateHorizontalBox("T3L" ,30,,,"VINCULO","ABA02")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("VINCULO","ABA03",STR0057)//Trabalhador Estatutário
	oView:CreateHorizontalBox("CUPc",35,,,"VINCULO","ABA03")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("VINCULO","ABA04",STR0058)//Contrato de Trabalho
	oView:CreateHorizontalBox("CUPd" ,75,,,"VINCULO","ABA04")
	oView:CreateHorizontalBox("GRIDS",25,,,"VINCULO","ABA04")

	oView:CreateFolder( "FOLDER_PRINCIPAL_VINCULO" , "GRIDS" )

	oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA01', STR0049 ) //"Informações Diárias do Horário Contratual"
	oView:CreateHorizontalBox( 'CRQ', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA01' )

	oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA02', STR0065 ) //"Filiação Sindical do Trabalhador"
	oView:CreateHorizontalBox( 'T80', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA02' )

	oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA03', STR0069 ) //"Observações do Contrato de Trabalho"
	oView:CreateHorizontalBox( 'T90', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA03' )

	/*-----------------------------------------------------------------------------------
							Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_C9Va", "C9Va" )
	oView:SetOwnerView( "VIEW_C9Vb", "C9Vb" )
	oView:SetOwnerView( "VIEW_C9Vc", "C9Vc" )
	oView:SetOwnerView( "VIEW_C9Vd", "C9Vd" )
	oView:SetOwnerView( "VIEW_C9Ve", "C9Ve" )
	oView:SetOwnerView( "VIEW_C9Vf", "C9Vf" )
	oView:SetOwnerView( "VIEW_CUPa", "CUPa" )
	oView:SetOwnerView( "VIEW_CUPb", "CUPb" )
	oView:SetOwnerView( "VIEW_CUPc", "CUPc" )
	oView:SetOwnerView( "VIEW_CUPd", "CUPd" )
	oView:SetOwnerView( "VIEW_T2E" , "T2E"  )
	oView:SetOwnerView( "VIEW_CRQ" , "CRQ"  )
	oView:SetOwnerView( "VIEW_T3L" , "T3L"  )
	oView:SetOwnerView( "VIEW_T80" , "T80"  )
	oView:SetOwnerView( "VIEW_T90" , "T90"  )

	//Tratamento para que alguns campos de controle interno não sejam exibidos no browse
	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	oStruT3L:RemoveField("T3L_NOMEVE")
	oStruCRQ:RemoveField("CRQ_NOMEVE")
	oStruT2E:RemoveField("T2E_NOMEVE")
	oStruT80:RemoveField("T80_NOMEVE")
	oStruT90:RemoveField("T90_NOMEVE")

	If !lMenuDif
		xFunRmFStr(@oStruC9Va,"C9V")
		xFunRmFStr(@oStruT3L ,"T3L")
		xFunRmFStr(@oStruCRQ ,"CRQ")
		xFunRmFStr(@oStruT80 ,"T80")
		xFunRmFStr(@oStruT90 ,"T90")
	EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF256Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param

oModelC9V	- Model da tabela C9V
oModelT3L	- Model da tabela T3L
oModelT2E	- Model da tabela T2E
oModelCUP	- Model da tabela CUP
oModelCRQ	- Model da tabela CRQ
oModelT80	- Model da tabela T80
oModelT90	- Model da tabela T90
aGrava		- Array que armazena as informações da tabela C9V
aGravaT3L	- Array que armazena as informações da tabela T3L
aGravaT2E	- Array que armazena as informações da tabela T2E
aGravaCUP	- Array que armazena as informações da tabela CUP
aGravaCRQ	- Array que armazena as informações da tabela CRQ
aGravaT80	- Array que armazena as informações da tabela T80
aGravaT90	- Array que armazena as informações da tabela T90

@Return .T.

@Author Paulo Sérgio V.B. Santana
@Since 29/03/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF256Carr( oModel, oModelC9V, oModelCUP, oModelT2E, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaT2E, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90 )

	Local nI            := 0

	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelT2E	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil

	Default aGrava		:= {}
	Default aGravaCUP	:= {}
	Default aGravaT2E	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}



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

	//*******************************
	//Dependente
	//*******************************
	For nI := 1 to oModel:GetModel( "MODEL_T2E" ):Length()
		oModel:GetModel( "MODEL_T2E" ):GoLine(nI)
		If !oModel:GetModel( 'MODEL_T2E' ):IsEmpty()
			If !oModel:GetModel( "MODEL_T2E" ):IsDeleted()
				aAdd(aGravaT2E,{oModelT2E:GetValue("T2E_IDDEP"),;
					oModelT2E:GetValue("T2E_TPDEP") ,;
					oModelT2E:GetValue("T2E_NOMDEP"),;
					oModelT2E:GetValue("T2E_DTNASC"),;
					oModelT2E:GetValue("T2E_CPFDEP"),;
					oModelT2E:GetValue("T2E_DEPIRF"),;
					oModelT2E:GetValue("T2E_DEPSFA"),;
					oModelT2E:GetValue("T2E_INCTRB")})
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


Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF256Comm
Função que realiza a gravação das informações

@Param

oModel    - Model que esta sendo editado
oModelC9V - Model da tabela C9V
oModelT3T - Model da tabela T3T
aGrava    - Array que armazena as informações da tabela C9V
aGravaT3T - Array que armazena as informações da tabela T3T
lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
de controle de rastro não devem ser gravados

@Return .T.

@Author Paulo Sérgio V.B. Santana
@Since 29/01/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF256Comm( oModel, oModelC9V, oModelCUP, oModelT2E, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaT2E, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90 )

	Local cVersao		:= ""
	Local cVerAnt		:= ""
	Local cProtocolo	:= ""
	Local cEvento		:= ""

	Local nI 			:= 0

	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelT2E	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil

	Default aGrava		:= {}
	Default aGravaCUP	:= {}
	Default aGravaT2E	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}



	/*----------------------------------------------------------
	Apos deixar o registro corrente como inativo eu seto a
	operação de inclusão para o novo registro
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
	For nI := 1 to Len( aGravaT2E )
		If nI > 1
			oModel:GetModel( "MODEL_T2E" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T2E", "T2E_IDDEP" , aGravaT2E[nI][1] )
		oModel:LoadValue( "MODEL_T2E", "T2E_TPDEP" , aGravaT2E[nI][2] )
		oModel:LoadValue( "MODEL_T2E", "T2E_NOMDEP", aGravaT2E[nI][3] )
		oModel:LoadValue( "MODEL_T2E", "T2E_DTNASC", aGravaT2E[nI][4] )
		oModel:LoadValue( "MODEL_T2E", "T2E_CPFDEP", aGravaT2E[nI][5] )
		oModel:LoadValue( "MODEL_T2E", "T2E_DEPIRF", aGravaT2E[nI][6] )
		oModel:LoadValue( "MODEL_T2E", "T2E_DEPSFA", aGravaT2E[nI][7] )
		oModel:LoadValue( "MODEL_T2E", "T2E_INCTRB", aGravaT2E[nI][8] )
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
	//-----------------

	//***********************
	//Trabalhador Substituido
	//***********************
	For nI := 1 to Len( aGravaT3L )
		If nI > 1
			oModel:GetModel( "MODEL_T3L" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T3L", "T3L_CPF" 	  , aGravaT3L[nI][1] )
	Next nI
	//----------------------

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


	cVersao	:= xFunGetVer()
	cVerAnt   	:= C9V->C9V_VERSAO
	cProtocolo	:= C9V->C9V_PROTUL
	cEvento   	:= C9V->C9V_EVENTO

	oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_C9V", "C9V_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_C9V", "C9V_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_C9V", "C9V_PROTUL", "" )
	oModel:LoadValue( "MODEL_C9V", "C9V_STATUS", "" )

	If cEvento == "E"
		oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "I" )
	Else
		oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "A" )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FRulVinc

Regras para gravacao das informacoes de vinculo do cadastro dos registros
S-2200 do eSocial

@Param
cCabecVinc - Cabecalho de busca das informacoes no Xml
cLayout - Numero do evento do eSocial

@Return
@aRull - Regra para integração do vínculo

@author Felipe C. Seolin / Rodrigo Aguilar
@since 24/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FRulVinc( cCabecVinc, cLayout, cAlias, cInconMsg, nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )

	Local aRull         := {}
	Local aIncons       := {}
	Local cLocTDom	    := IIF(!lLaySimplif,"localTrabDom","localTempDom")


	Default cCabecVinc	:= ""
	Default cLayout		:= ""
	Default cAlias		:= "CUP"
	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default lTransmit	:= .F.
	Default oModel		:= Nil
	Default cCodEvent	:= ""
	Default cOwner 		:= ""

	//*******
	//eSocial/.../
	//*******
	If cLayout == "2200"

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/tpRegTrab"))
			aAdd( aRull, { cAlias + "_TPREGT", cCabecVinc + "/tpRegTrab", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/tpRegPrev"))
			aAdd( aRull, { cAlias + "_TPREGP", cCabecVinc + "/tpRegPrev", "C", .F.} )
		EndIf
		
		If lLaySimplif  

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/nmCargo"))
				aAdd( aRull, { cAlias + "_NMCARG", cCabecVinc + "/infoContrato/nmCargo", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/CBOCargo"))
				aAdd( aRull, { cAlias + "_CBOCAR", FGetIdInt( "codCBO", , cCabecVinc + "/infoContrato/CBOCargo",,,,@cInconMsg, @nSeqErrGrv ), "C", .F.} )
			EndIf
			
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/dtIngrCargo"))
				aAdd( aRull, { cAlias + "_DTINCA", cCabecVinc + "/infoContrato/dtIngrCargo", "D", .F. } )
			Endif
			
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/nmFuncao"))
				aAdd( aRull, { cAlias + "_NMFUNC", cCabecVinc + "/infoContrato/nmFuncao", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/CBOFuncao"))
				aAdd( aRull, { cAlias + "_CBOFUN", FGetIdInt( "codCBO", , cCabecVinc + "/infoContrato/CBOFuncao",,,,@cInconMsg, @nSeqErrGrv ), "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/acumCargo"))
				aAdd( aRull, { cAlias + "_ACCARG", cCabecVinc + "/infoContrato/acumCargo", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/tpJornada"))
				aAdd( aRull, { cAlias + "_TPJORN", cCabecVinc + "/infoContrato/horContratual/tpJornada", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/horNoturno"))
				aAdd( aRull, { cAlias + "_HRSNOT", cCabecVinc + "/infoContrato/horContratual/horNoturno", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/dscJorn"))
				aAdd( aRull, { cAlias + "_DSCJOR", cCabecVinc + "/infoContrato/horContratual/dscJorn", "C", .F.} )
			EndIf

		EndIf

	Else

		If cLayout <> "2206"
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/vinculo/tpRegTrab"))
				aAdd( aRull, { cAlias + "_TPREGT", cCabecVinc + "/vinculo/tpRegTrab", "C", .F.} )
			EndIf
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/vinculo/tpRegPrev"))
				aAdd( aRull, { cAlias + "_TPREGP", cCabecVinc + "/vinculo/tpRegPrev", "C", .F.} )
			EndIf
		Else
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/tpRegPrev"))
				aAdd( aRull, { cAlias + "_TPREGP", cCabecVinc + "/tpRegPrev", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/nmCargo"))
				aAdd( aRull, { cAlias + "_NMCARG", cCabecVinc + "/infoContrato/nmCargo", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/CBOCargo"))
				aAdd( aRull, { cAlias + "_CBOCAR", FGetIdInt( "codCBO", , cCabecVinc + "/infoContrato/CBOCargo",,,,@cInconMsg, @nSeqErrGrv ), "C", .F.} )
			EndIf			
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/nmFuncao"))
				aAdd( aRull, { cAlias + "_NMFUNC", cCabecVinc + "/infoContrato/nmFuncao", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/CBOFuncao"))
				aAdd( aRull, { cAlias + "_CBOFUN", FGetIdInt( "codCBO", , cCabecVinc + "/infoContrato/CBOFuncao",,,,@cInconMsg, @nSeqErrGrv ), "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/acumCargo"))
				aAdd( aRull, { cAlias + "_ACCARG", cCabecVinc + "/infoContrato/acumCargo", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/tpJornada"))
				aAdd( aRull, { cAlias + "_TPJORN", cCabecVinc + "/infoContrato/horContratual/tpJornada", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/horNoturno"))
				aAdd( aRull, { cAlias + "_HRSNOT", cCabecVinc + "/infoContrato/horContratual/horNoturno", "C", .F.} )
			EndIf
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/dscJorn"))
				aAdd( aRull, { cAlias + "_DSCJOR", cCabecVinc + "/infoContrato/horContratual/dscJorn", "C", .F.} )
			EndIf

		EndIf

		If cLayout $ "2200|2300"
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/cadIni"))
				aAdd( aRull, { "C9V_CADINI", cCabecVinc + "/cadIni", "C", .F.} )
			EndIf
		Endif

	EndIf

	//-------------

	//*************
	//eSocial/.../infoRegimeTrab/infoCeletista
	//*************
	If cLayout == "2200"

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/dtAdm"))
			aAdd( aRull, { cAlias + "_DTADMI", cCabecVinc + "/infoRegimeTrab/infoCeletista/dtAdm", "D", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/tpAdmissao"))
			aAdd( aRull, { cAlias + "_TPADMI", cCabecVinc + "/infoRegimeTrab/infoCeletista/tpAdmissao", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/indAdmissao"))
			aAdd( aRull, { cAlias + "_INDADM", cCabecVinc + "/infoRegimeTrab/infoCeletista/indAdmissao", "C", .F.} )
		EndIf

	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/tpRegJor"))
		aAdd( aRull, { cAlias + "_TPREGJ", cCabecVinc + "/infoRegimeTrab/infoCeletista/tpRegJor", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/natAtividade"))
		aAdd( aRull, { cAlias + "_NATATV", cCabecVinc + "/infoRegimeTrab/infoCeletista/natAtividade", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/dtBase"))
		aAdd( aRull, { cAlias + "_DATAB" , cCabecVinc + "/infoRegimeTrab/infoCeletista/dtBase", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/cnpjSindCategProf"))
		aAdd( aRull, { cAlias + "_CNPJCP", cCabecVinc + "/infoRegimeTrab/infoCeletista/cnpjSindCategProf", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/nrProcTrab"))
		aAdd( aRull, { cAlias + "_NRPROC", cCabecVinc + "/infoRegimeTrab/infoCeletista/nrProcTrab", "C", .F.} )
	EndIf
	//------------

	//*************
	//eSocial/.../infoRegimeTrab/infoCeletista/FGTS
	//*************
	If cLayout == "2200" .And. !lLaySimplif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/FGTS/opcFGTS"))
			aAdd( aRull, { cAlias + "_FGTSOP", cCabecVinc + "/infoRegimeTrab/infoCeletista/FGTS/opcFGTS", "C", .F.} )
		EndIf		

	EndIf

	//------------

	If cLayout == "2200"

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/FGTS/dtOpcFGTS"))
			aAdd( aRull, { cAlias + "_DTFGTS", cCabecVinc + "/infoRegimeTrab/infoCeletista/FGTS/dtOpcFGTS", "D", .F.} )
		EndIf

		//*************
		//eSocial/.../infoRegimeTrab/infoCeletista/trabTemporario
		//************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/hipLeg"))
			aAdd( aRull, { cAlias + "_MOTCON", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/hipLeg", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/justContr"))
			aAdd( aRull, { cAlias + "_JUSHIP", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/justContr", "C", .F. } )
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/tpInclContr"))
				aAdd( aRull, { cAlias + "_TPINCL", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/tpInclContr", "C", .F. } )
			EndIf

			//*************
			//eSocial/.../infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ
			//*************
		
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/tpInsc"))
				aAdd( aRull, { cAlias + "_TPINST", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/tpInsc", "C", .F. } )
			Endif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/nrInsc"))
				aAdd( aRull, { cAlias + "_NRINST", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTomadorServ/nrInsc", "C", .F. } )
			Endif
		

		Else
			//------------
	
			//*************
			//eSocial/.../infoRegimeTrab/infoCeletista/trabTemporario/ideEstabVinc
			//*************
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideEstabVinc/tpInsc"))
				aAdd( aRull, { cAlias + "_TPINTT", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideEstabVinc/tpInsc", "C", .F. } )
			Endif
	
	
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideEstabVinc/nrInsc"))
				aAdd( aRull, { cAlias + "_NRINTT", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideEstabVinc/nrInsc", "C", .F. } )
			Endif
		EndIf
		//-------------

		
		//------------
	EndIf

	If cLayout $ "2200|2206"
		//*************
		//eSocial/.../infoRegimeTrab/infoCeletista/aprend
		//*************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/aprend/tpInsc"))
			aAdd( aRull, { cAlias + "_TPINAP", cCabecVinc + "/infoRegimeTrab/infoCeletista/aprend/tpInsc", "C", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/aprend/nrInsc"))
			aAdd( aRull, { cAlias + "_NRINAP", cCabecVinc + "/infoRegimeTrab/infoCeletista/aprend/nrInsc", "C", .F. } )
		Endif
		//------------

	EndIf

	If cLayout == "2200"
		//*************
		//eSocial/.../infoRegimeTrab/infoEstatutario
		//*************
		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/indProvim"))
				aAdd( aRull, { cAlias + "_INDPRO", cCabecVinc + "/infoRegimeTrab/infoEstatutario/indProvim", "C", .F. } )
			Endif
		Else
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/indTetoRGPS"))
				aAdd( aRull, { cAlias + "_TERGPS", cCabecVinc + "/infoRegimeTrab/infoEstatutario/indTetoRGPS", "C", .F. } )
			Endif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/indAbonoPerm"))
				aAdd( aRull, { cAlias + "_ABOPER", cCabecVinc + "/infoRegimeTrab/infoEstatutario/indAbonoPerm", "C", .F. } )
			Endif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtIniAbono")) 
				aAdd( aRull, { cAlias + "_DTABON", cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtIniAbono", "D", .F. } )
			Endif
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/tpProv"))
			aAdd( aRull, { cAlias + "_TIPPRO", cCabecVinc + "/infoRegimeTrab/infoEstatutario/tpProv", "C", .F. } )
		Endif

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtNomeacao"))
				aAdd( aRull, { cAlias + "_DTNOME", cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtNomeacao", "D", .F. } )
			Endif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtPosse"))
				aAdd( aRull, { cAlias + "_DTPOSS", cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtPosse", "D", .F. } )
			Endif
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtExercicio"))
			aAdd( aRull, { cAlias + "_DTEXER", cCabecVinc + "/infoRegimeTrab/infoEstatutario/dtExercicio", "D", .F. } )
		Endif
		
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/infoDecJud/nrProcJud"))
			aAdd( aRull, { cAlias + "_NPROJE", Posicione("C1G", 1, xFilial("C1G") + PadR(FTafGetVal(cCabecVinc + "/infoRegimeTrab/infoEstatutario/infoDecJud/nrProcJud", "C", .F., @aIncons, .F.), GetSX3Cache("C1G_NUMPRO", "X3_TAMANHO")), "C1G_ID"), "C", .T.} )
		Endif

		//-------------
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/tpPlanRP"))
		aAdd( aRull, { cAlias + "_TPLASM", cCabecVinc + "/infoRegimeTrab/infoEstatutario/tpPlanRP", "C", .F. } )
	Endif

	If lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/indTetoRGPS"))
			aAdd( aRull, { cAlias + "_TERGPS", cCabecVinc + "/infoRegimeTrab/infoEstatutario/indTetoRGPS", "C", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoEstatutario/indAbonoPerm"))
			aAdd( aRull, { cAlias + "_ABOPER", cCabecVinc + "/infoRegimeTrab/infoEstatutario/indAbonoPerm", "C", .F. } )
		Endif
	EndIf

	If cLayout == "2206"
		//***********************
		//eSocial/.../infoRegimeTrab/infoCeletista/trabTemp
		//***********************
		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemp/justProrr"))
				aAdd( aRull, { cAlias + "_JUSTPR", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemp/justProrr", "C", .F. } )
			Endif
		Else
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/justProrr"))
				aAdd( aRull, { cAlias + "_JUSTPR", cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/justProrr", "C", .F. } )
			Endif
		EndIf

	EndIf

	//*************
	//eSocial/.../infoContrato
	//*************
	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/codCargo" ))
			aAdd( aRull, { cAlias + "_CODCGO", FGetIdInt( "codCargo" , "", cCabecVinc + "/infoContrato/codCargo",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/codFuncao"))
			aAdd( aRull, { cAlias + "_CODFUN", FGetIdInt( "codFuncao", "", cCabecVinc + "/infoContrato/codFuncao",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
		Endif
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/codCateg"))
		aAdd( aRull, { cAlias + "_CODCAT", FGetIdInt( "codCateg" , "", cCabecVinc + "/infoContrato/codCateg",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
	Endif

	If !lLaySimplif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/codCarreira"))
			aAdd( aRull, { cAlias + "_CODCAR", FGetIdInt( "codCarreira" , "", cCabecVinc + "/infoContrato/codCarreira",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/dtIngrCarr"))
			aAdd( aRull, { cAlias + "_DTINGC", cCabecVinc + "/infoContrato/dtIngrCarr", "D", .F. } )
		Endif

	EndIf

	//------------

	//*************
	//eSocial/.../infoContrato/remuneracao
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/remuneracao/vrSalFx"))
		aAdd( aRull, { cAlias + "_VLSLFX", cCabecVinc + "/infoContrato/remuneracao/vrSalFx", "N", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/remuneracao/undSalFixo"))
		aAdd( aRull, { cAlias + "_UNSLFX", cCabecVinc + "/infoContrato/remuneracao/undSalFixo", "C", .F.} )
	Endif

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/remuneracao/dscSalVar"))
			aAdd( aRull, { cAlias + "_DESSVR", cCabecVinc + "/infoContrato/remuneracao/dscSalVar", "C", .F.} )
		Endif
	Else
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/remuneracao/dscSalVar"))
			aAdd( aRull, { cAlias + "_DSCSAL", cCabecVinc + "/infoContrato/remuneracao/dscSalVar", "C", .F.} )
		Endif
	EndIf
	//-------------

	//*************
	//eSocial/.../infoContrato/duracao
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/duracao/tpContr"))
		aAdd( aRull, { cAlias + "_TPCONT", cCabecVinc + "/infoContrato/duracao/tpContr", "C", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/duracao/dtTerm"))
		aAdd( aRull, { cAlias + "_DTTERM", cCabecVinc + "/infoContrato/duracao/dtTerm" , "D", .F.} )
	Endif

	If cLayout == "2200"
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/duracao/clauAssec"))
			aAdd( aRull, { cAlias + "_CLAUAS", xFunTrcSN( TAFExisTag( cCabecVinc + "/infoContrato/duracao/clauAssec", ) ,2),"C", .T.} )
		Endif
	Endif

	If (cLayout $ "2200|2206") 
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/duracao/objDet"))
			aAdd( aRull, { cAlias + "_OBJDET", cCabecVinc + "/infoContrato/duracao/objDet", "C", .F.} )
		Endif
	Endif

	//-------------

	//*************
	//eSocial/.../infoContrato/localTrabalho/localTrabGeral
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/tpInsc"))
		aAdd( aRull, { cAlias + "_TPINSC", cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/tpInsc", "C", .F. } )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/nrInsc"))
		aAdd( aRull, { cAlias + "_NRINSC", cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/nrInsc", "C", .F. } )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/descComp"))
		aAdd( aRull, { cAlias + "_DESLOT", cCabecVinc + "/infoContrato/localTrabalho/localTrabGeral/descComp", "C", .F. } )
	Endif
	//-------------

	//*************
	//eSocial/.../infoContrato/localTrabalho/localTrabDom v02_05_00
	//eSocial/.../infoContrato/localTrabalho/localTempDom vS_01_00_00 (simplificado)
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/tpLograd"))
		aAdd( aRull, { cAlias + "_TPLOGD", FGetIdInt( "tpLograd", "", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/tpLograd",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/dscLograd"))
		aAdd( aRull, { cAlias + "_DELOGD", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/dscLograd", "C", .F. } )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/nrLograd"))
		aAdd( aRull, { cAlias + "_NRLOGD", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/nrLograd",  "C", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/complemento"))
		aAdd( aRull, { cAlias + "_COMLGD", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/complemento", "C", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/bairro"))
		aAdd( aRull, { cAlias + "_BAIRTD", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/bairro", "C", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/cep"))
		aAdd( aRull, { cAlias + "_CEPLTD", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/cep", "C", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/uf")) .And. TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/codMunic"))
		aAdd( aRull, { cAlias + "_CMUNTD", FGetIdInt( "uf", "codMunic",;
			cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/uf",;
			cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/codMunic",,,@cInconMsg, @nSeqErrGrv ), "C", .T.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/uf"))
		aAdd( aRull, { cAlias + "_UFTRBD", FGetIdInt( "uf", "", cCabecVinc + "/infoContrato/localTrabalho/"+ cLocTDom +"/uf",,,,@cInconMsg, @nSeqErrGrv ), "C", .T.} )
	Endif

	//-------------

	//*************
	//eSocial/.../infoContrato/horContratual
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/qtdHrsSem"))
		aAdd( aRull, { cAlias + "_QTDHJS", cCabecVinc + "/infoContrato/horContratual/qtdHrsSem","N", .F.} )
	Endif

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/tpJornada"))
		aAdd( aRull, { cAlias + "_TPJORN", cCabecVinc + "/infoContrato/horContratual/tpJornada", "C", .F.} )
	Endif

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/dscTpJorn"))
			aAdd( aRull, { cAlias + "_DTPJOR", cCabecVinc + "/infoContrato/horContratual/dscTpJorn", "C", .F. } )
		Endif
	Else
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/horNoturno"))
			aAdd( aRull, { cAlias + "_HRSNOT", cCabecVinc + "/infoContrato/horContratual/horNoturno", "C", .F. } )
		Endif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/horContratual/dscJorn"))
			aAdd( aRull, { cAlias + "_DSCJOR", cCabecVinc + "/infoContrato/horContratual/dscJorn", "C", .F. } )
		Endif
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoContrato/horContratual/tmpParc" ))
		aAdd( aRull, { cAlias + "_TMPARC", cCabecVinc + "/infoContrato/horContratual/tmpParc", "C", .F. } )
	EndIf
	//-------------

	//*************
	//eSocial/.../infoContrato/alvaraJudicial
	//*************
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/alvaraJudicial/nrProcJud"))
		aAdd( aRull, { cAlias + "_ALVJUD", FGetIdInt( "", "nrProcJud",, cCabecVinc + "/infoContrato/alvaraJudicial/nrProcJud",,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
	Endif

	//--------------
	If cLayout == "2206"
		IF !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoContrato/servPubl/mtvAlter"))
				aAdd( aRull, { cAlias + "_MTVALT", cCabecVinc + "/infoContrato/servPubl/mtvAlter","C", .F.} )
			Endif
		EndIf
	EndIf

	If cLayout == "2200"
		//*************
		//eSocial/.../sucessaoVinc
		//*************
		If !lLaySimplif .and. TafColumnPos("CUP_INSANT")
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/tpInscAnt"))
				aAdd( aRull, { cAlias + "_INSANT", cCabecVinc + "/sucessaoVinc/tpInscAnt", "C", .F. } )
			Endif
		Else 
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/tpInsc"))
				aAdd( aRull, { cAlias + "_INSANT", cCabecVinc + "/sucessaoVinc/tpInsc", "C", .F. } )
			Endif
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/cnpjEmpregAnt"))
				aAdd( aRull, { cAlias + "_CNPJEA", cCabecVinc + "/sucessaoVinc/cnpjEmpregAnt", "C", .F. } )
			Endif
		Else 
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/nrInsc"))
				aAdd( aRull, { cAlias + "_CNPJEA", cCabecVinc + "/sucessaoVinc/nrInsc", "C", .F. } )
			Endif
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/matricAnt"))
			aAdd( aRull, { cAlias + "_MATANT", cCabecVinc + "/sucessaoVinc/matricAnt", "C", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/dtTransf"))
			aAdd( aRull, { cAlias + "_DTINVI", cCabecVinc + "/sucessaoVinc/dtTransf", "D", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/sucessaoVinc/observacao"))
			aAdd( aRull, { cAlias + "_OBSVIN", cCabecVinc + "/sucessaoVinc/observacao", "M", .F. } )
		Endif
		//-------------
	EndIf

	If cLayout == "2200"
		//*************
		//eSocial/vinculo/afastamento
		//*************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/afastamento/dtIniAfast"))
			aAdd( aRull, { cAlias + "_DTINIA", cCabecVinc + "/afastamento/dtIniAfast", "D", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/afastamento/codMotAfast"))
			aAdd( aRull, { cAlias + "_MOTVAF", FGetIdInt( "codMotAfast", "", cCabecVinc + "/afastamento/codMotAfast",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
		Endif
		//-------------

		//*************
		//eSocial/vinculo/desligamento
		//*************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/desligamento/dtDeslig"))
			aAdd( aRull, { cAlias + "_DTDESL", cCabecVinc + "/desligamento/dtDeslig", "D", .F. } )
		Endif
		//-------------

		//*************
		//eSocial/vinculo/transfDom
		//*************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/transfDom/cpfSubstituido"))
			aAdd( aRull, { cAlias + "_CPFSUB", cCabecVinc + "/transfDom/cpfSubstituido", "C", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/transfDom/matricAnt"))
			aAdd( aRull, { cAlias + "_MATRAN", cCabecVinc + "/transfDom/matricAnt", "C", .F. } )
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/transfDom/dtTransf"))
			aAdd( aRull, { cAlias + "_DTTRAN", cCabecVinc + "/transfDom/dtTransf", "D", .F. } )
		Endif
		
		If lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/cessao/dtIniCessao"))
				aAdd( aRull, { cAlias + "_DCESSA", cCabecVinc + "/cessao/dtIniCessao", "D", .F. } )
			EndIf 
		Endif
		//-------------
		//**************
		//eSocial/vinculo/mudancaCPF
		//**************
		If  TafColumnPos("CUP_CPFANT") .And. TafColumnPos("CUP_MATOLD") .And. TafColumnPos("CUP_DATCPF") .And. TafColumnPos("CUP_OBSCPF")

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/cpfAnt"))
				aAdd( aRull, { cAlias + "_CPFANT", cCabecVinc + "/mudancaCPF/cpfAnt", "C", .F. } )
			Endif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/matricAnt"))
				aAdd( aRull, { cAlias + "_MATOLD", cCabecVinc + "/mudancaCPF/matricAnt", "C", .F. } )
			Endif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/dtAltCPF"))
				aAdd( aRull, { cAlias + "_DATCPF", cCabecVinc + "/mudancaCPF/dtAltCPF", "D", .F. } )
			Endif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/observacao"))
				aAdd( aRull, { cAlias + "_OBSCPF", cCabecVinc + "/mudancaCPF/observacao", "C", .F. } )
			Endif

		EndIf

	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} getUfMunicipio
Regras para gravacao das informacoes de trabalhador do cadastro dos registros
S-2200, S-2205, S-2206, S-2300 e S-2306 do eSocial

@aRull - Array com os campos que serão persistidos no modelo.
@lValidaUFMun - Indica se deve validar o código do municipio com o código da UF
@cAlias - Alias do evento a ser persistido
@cNodeUF - Nó do XML relativo a UF
@cNodeMunicipio - Nó do XML relativo a municipio.
@cFieldMun - Campo no cadastro relativo ao código do municipio.
@cInconMsg - String contendo os possiveis erros de gravação
@nSeqErrGrv - Sequencia do Erro
@cCodEvent - Código do evento que está sendo integrado
@cOwner -  ERP dono da informação

@return - Nil

@author Evandro dos Santos Oliveira Texeira
@since 01/11/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function getUfMunicipio(aRull,lValidaUFMun,cAlias,cNodeUF,cNodeMunicipio,cFieldMun,cInconMsg,nSeqErrGrv,cCodEvent,cOwner)

	Local cInfNascto := ""
	Local cIDUFNascto := ""

	Default cCodEvent := ""
	Default cOwner := ""

	If TafXNode( oDados , cCodEvent, cOwner,cNodeUF) .And. TafXNode( oDados , cCodEvent, cOwner,cNodeMunicipio)

		If lValidaUFMun

			cInfNascto := FTafGetVal(cNodeMunicipio, , , {}, , ,  )

			C09->( dbSetOrder(4) )
			If C09->( MsSeek( xFilial("C09") + SubStr(cInfNascto, 1, 2) ) )

				cIDUFNascto := C09->C09_ID

				C07->(dbSetOrder(1) )
				If C07->( MsSeek( xFilial("C07") + cIDUFNascto + SubStr(cInfNascto, 3)) )
					aAdd( aRull, { cFieldMun , C07->C07_ID, "C", .T. } )
				EndIf
			EndIf
		Else

			aAdd( aRull, {cFieldMun , FGetIdInt( "uf", "codMunic",cNodeUF,cNodeMunicipio,,,@cInconMsg, @nSeqErrGrv ),"C", .T.} )
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FRulCad
Regras para gravacao das informacoes de trabalhador do cadastro dos registros
S-2200, S-2205, S-2206, S-2300 e S-2306 do eSocial

@Param
aRull  - Regras para a gravacao das informacoes
cCabecTrab - Cabecalho de busca das informacoes no Xml
cLayout - Numero do evento do eSocial

@Return
aRull - Array com as regras do cadastro para integração

@author Felipe C. Seolin / Rodrigo Aguilar
@since 26/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FRulCad( cCabecTrab, cLayout, cAlias, cCabecVinc, cInconMsg, nSeqErrGrv, lTransmit, oModel, aChave, aIncons, cCodEvent, cOwner, aChaveOri)

	Local cDDDPrincip 	:= ""
	Local cDDDAlter   	:= ""
	Local cDDIPrincip 	:= ""
	Local cDDIAlter   	:= ""
	Local cTelPrincip 	:= ""
	Local cTelAlter	 	:= ""
	Local cTelFull	 	:= ""
	Local aTelefone  	:= {}
	Local aTelAlter    	:= {}
	Local aRull      	:= {}
	Local aAreaC9V	 	:= ""
	Local lNoVldEst     := SuperGetMv("MV_TAFVLUF", .F., .F.)

	Default cCabecTrab	:= ""
	Default cLayout		:= ""
	Default cAlias		:= "C9V
	Default cCabecVinc	:= ""
	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default lTransmit	:= .F.
	Default oModel		:= Nil
	Default aChave		:= {}
	Default aIncons		:= {}
	Default cCodEvent	:= ""
	Default cOwner		:= ""
	Default aChaveOri   := {}

	//########################################
	//Inicio das TAGs - Trabalhador
	//########################################
	//***********
	///eSocial/.../
	//***********
	If cLayout <> "2205"

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/cpfTrab"))
			aAdd( aRull, { cAlias + "_CPF", cCabecTrab + "/cpfTrab", "C", .F. } )
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nisTrab"))
				aAdd( aRull, { cAlias + "_NIS", cCabecTrab + "/nisTrab", "C", .F. } )
			EndIf
		EndIf

		If cLayout $ "2200|2206"
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/matricula")) .or. TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/matricula"))
				aAdd( aRull, { cAlias + "_MATRIC", Iif(cLayout == "2206",cCabecTrab,cCabecVinc) + "/matricula", "C", .F. } )
			EndIf

			If cLayout == "2200"
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/cadIni"))
					aAdd( aRull, { cAlias + "_CADINI", xFunTrcSN( TAFExisTag( cCabecVinc + "/cadIni" ) ,2), "C", .T.} )
				EndIf
			EndIf

			If cLayout == "2206"
				If !lLaySimplif
					If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/dtAlteracao"))
						aAdd( aRull, { cAlias + "_DTALT", + cCabecVinc + "/dtAlteracao", "D", .F.} )
					EndIf

					If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/dtEf"))
						aAdd( aRull, { cAlias + "_DTEF", + cCabecVinc + "/dtEf", "D", .F.} )
					EndIf

					If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/dscAlt"))
						aAdd( aRull, { cAlias + "_DESALT", + cCabecVinc + "/dscAlt", "C", .F.} )
					EndIf
				Else
					If TafXNode( oDados , cCodEvent, cOwner, "/eSocial/evtAltContratual/altContratual/dtAlteracao")
						aAdd( aRull, { cAlias + "_DTALT", "/eSocial/evtAltContratual/altContratual/dtAlteracao", "D", .F.} )
					EndIf

					If TafXNode( oDados , cCodEvent, cOwner, "/eSocial/evtAltContratual/altContratual/dtEf" )
						aAdd( aRull, { cAlias + "_DTEF", "/eSocial/evtAltContratual/altContratual/dtEf", "D", .F.} )
					EndIf

					If TafXNode( oDados , cCodEvent, cOwner, "/eSocial/evtAltContratual/altContratual/dscAlt")
						aAdd( aRull, { cAlias + "_DESALT", "/eSocial/evtAltContratual/altContratual/dscAlt", "C", .F.} )
					EndIf
				EndIf
			Endif
		EndIf

		If cLayout == "2306"
			If TafXNode( oDados , cCodEvent, cOwner, "/eSocial/evtTSVAltContr/infoTSVAlteracao/dtAlteracao")
				aAdd( aRull, { cAlias + "_DTALT", "/eSocial/evtTSVAltContr/infoTSVAlteracao/dtAlteracao", "D", .F.} )
			EndIf
			If lLaySimplif
				If TafXNode( oDados , cCodEvent, cOwner, "/eSocial/evtTSVAltContr/ideTrabSemVinculo/matricula")
					aAdd( aRull, { cAlias + "_MATTSV", "/eSocial/evtTSVAltContr/ideTrabSemVinculo/matricula", "C", .F. } )
				EndIf
			EndIf
		EndIf

		If cLayout == "2300"
			If !TAFColumnPos( "C9V_CATCI" )
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/codCateg"))
					aAdd( aRull, { cAlias + "_CATAV" , FGetIdInt( "codCateg" , "", cCabecVinc + "/codCateg",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
				Endif

			Else
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/codCateg"))
					aAdd( aRull, { cAlias + "_CATCI" , FGetIdInt( "codCateg" , "", cCabecVinc + "/codCateg",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
				EndIf
			EndIf

			if TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtTSVInicio/infoTSVInicio/dtInicio" ))
				aAdd( aRull, { cAlias + "_DTINIV", cCabecVinc + "/dtInicio", "D", .F. } )
			Endif


			If TAFColumnPos( "C9V_CADINI" )
				if TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtTSVInicio/infoTSVInicio/cadIni" ))
					aAdd( aRull, { cAlias + "_CADINI", xFunTrcSN( TAFExisTag( cCabecVinc + "/cadIni" ) ,2), "C", .T.} )
				EndIf
			EndIf

			If lLaySimplif
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/matricula" ))
					aAdd( aRull, { cAlias + "_MATTSV", cCabecVinc + "/matricula"                   , "C", .F. } )
				EndIf
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/nrProcTrab" ))
					aAdd( aRull, { cAlias + "_NRPROC", cCabecVinc + "/nrProcTrab"                   , "C", .F. } )
				EndIf
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/natAtividade" ))
					aAdd( aRull, { "C9V_NATATV", cCabecVinc + "/natAtividade"                   , "C", .F. } )
				EndIf
			EndIf
		EndIf

	Else

		If TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtAltCadastral/ideTrabalhador/cpfTrab"))
			aAdd( aRull, { cAlias + "_CPF", "/eSocial/evtAltCadastral/ideTrabalhador/cpfTrab", "C", .F. } )
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/nisTrab"))
				aAdd( aRull, { cAlias + "_NIS", "/eSocial/evtAltCadastral/alteracao/dadosTrabalhador/nisTrab", "C", .F. } )
			EndIf
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtAltCadastral/alteracao/dtAlteracao"))
			aAdd( aRull, { cAlias + "_DTALT", "/eSocial/evtAltCadastral/alteracao/dtAlteracao", "D", .F.} )
		EndIf

	EndIf

	//------------------------------------------------------------------------------
	// A tag nmTrab não existe nos eventos S-2206 e S2306
	// Portanto para gravar o campo _NOME no momento da integração
	// nas tabelas T1V e T0F pego o campo NOME do evento original (S-2200 ou S2300)
	//------------------------------------------------------------------------------
	If cLayout $ "2206|2306"

		aAreaC9V:= ( "C9V" )->( GetArea() )
		dbSelectArea("C9V")

		If aChave[ 1, 1 ] == '2306'
			C9V->( DbSetOrder( 4 ) )
			If ('C9V')->( MsSeek( aChave[1,2] + aChave[1,3] + aChave[1,4] ))
				oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_NOME", C9V->C9V_NOME )
			EndIf
		Else
			C9V->( DbSetOrder( 10 ) )
			If (C9V->( MsSeek( aChave[ 1, 2 ] + aChave[ 1, 3 ] + aChave[ 1, 4 ] + aChave[ 1, 5 ] )) .or.;
					C9V->( MsSeek( aChave[ 1, 2 ] + aChave[ 1, 3 ] + aChave[ 1, 4 ] + aChave[ 1, 6 ] )))
				oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_NOME", C9V->C9V_NOME )
			ElseIf (Len(ACHAVEORI) > 0)
				If C9V->( MsSeek( ACHAVEORI[1][2] + ACHAVEORI[1][3] + ACHAVEORI[1][4] + ACHAVEORI[1][6] ))
					oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_NOME", C9V->C9V_NOME )
				EndIf
			EndIf
		EndIf

		RestArea( aAreaC9V )

	EndIf

	If cLayout $ "2200|2205|2300"
		If cLayout <> "2306" .and. cLayout <> "2206"
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nmTrab"))
				aAdd( aRull, { cAlias + "_NOME",   cCabecTrab + "/nmTrab", "C", .F. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nmSoc"))
				aAdd( aRull, { cAlias + "_NOMSOC",   cCabecTrab + "/nmSoc", "C", .F. } )
			EndIf
		Endif

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/sexo"))
			aAdd( aRull, { cAlias + "_SEXO",   cCabecTrab + "/sexo", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/racaCor"))
			aAdd( aRull, { cAlias + "_RCCOR",  cCabecTrab + "/racaCor", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/estCiv"))
			aAdd( aRull, { cAlias + "_ESTCIV", cCabecTrab + "/estCiv", "C", .F. } )
		EndiF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/grauInstr"))
			aAdd( aRull, { cAlias + "_GRINST", FGetIdInt( "grauInstr", "", cCabecTrab + "/grauInstr",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
		EndIf

		If lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/paisNac"))
				aAdd( aRull, { cAlias + "_PAINAC", FGetIdInt( "paisNac", "", cCabecTrab + "/paisNac",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
			EndIf
		EndIf

	EndIf

	If !lLaySimplif
		If cLayout == "2200"
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/indPriEmpr"))
				aAdd( aRull, { cAlias + "_PRIEMP", xFunTrcSN( TAFExisTag( cCabecTrab + "/indPriEmpr", ) ,2),"C", .T.} )
			EndIf
		EndIf
		//-----------

		If (cLayout $ "2200|2205|2300") 

			//************
			//eSocial/.../nascimento
			//************
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/dtNascto"))
				aAdd( aRull, { cAlias + "_DTNASC", cCabecTrab + "/nascimento/dtNascto", "D" , .F.} )
			EndIf

			/*
			Foi criado o parâmetro MV_TAFVLUF em virtude do cenário no qual o E-Social aceitou registros com a
			chave composta UF+CodMun incorreta. Este parâmetro só deve ser habilitado para casos de
			integração/migração de registros do legado.
			Após o término este parâmetro deve ser desligado.
			*/

			getUfMunicipio(@aRull,lNoVldEst,cAlias,cCabecTrab + "/nascimento/uf",cCabecTrab + "/nascimento/codMunic",cAlias+"_CODMUN",@cInconMsg,@nSeqErrGrv,cCodEvent,cOwner)

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/uf"))
				aAdd( aRull, { cAlias + "_CODUF" , FGetIdInt( "uf", "", cCabecTrab + "/nascimento/uf",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
			EndiF

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/paisNascto"))
				aAdd( aRull, { cAlias + "_CODPAI", FGetIdInt( "paisNascto", "", cCabecTrab + "/nascimento/paisNascto",,,,@cInconMsg, @nSeqErrGrv ), "C",  .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/paisNac"))
				aAdd( aRull, { cAlias + "_PAINAC", FGetIdInt( "paisNac", "", cCabecTrab + "/nascimento/paisNac",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/nmMae"))
				aAdd( aRull, { cAlias + "_NOMMAE", cCabecTrab + "/nascimento/nmMae", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/nmPai"))
				aAdd( aRull, { cAlias + "_NOMPAI", cCabecTrab + "/nascimento/nmPai", "C", .F.} )
			EndIf

		EndIf

		If (cLayout $ "2200|2205|2300") 

			//************
			//eSocial/.../documentos
			//************
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CTPS/nrCtps"))
				aAdd( aRull, { cAlias + "_NRCTPS", cCabecTrab + "/documentos/CTPS/nrCtps", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CTPS/serieCtps"))
				aAdd( aRull, { cAlias + "_SERCTP", cCabecTrab + "/documentos/CTPS/serieCtps", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CTPS/ufCtps"))
				aAdd( aRull, { cAlias + "_UFCTPS", FGetIdInt( "ufCtps", "", cCabecTrab + "/documentos/CTPS/ufCtps",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RIC/nrRic"))
				aAdd( aRull, { cAlias + "_NRRIC",  cCabecTrab + "/documentos/RIC/nrRic", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RIC/orgaoEmissor"))
				aAdd( aRull, { cAlias + "_OREMRI", cCabecTrab + "/documentos/RIC/orgaoEmissor", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RIC/dtExped"))
				aAdd( aRull, { cAlias + "_DTEXRI", cCabecTrab + "/documentos/RIC/dtExped", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RG/nrRg"))
				aAdd( aRull, { cAlias + "_NRRG",   cCabecTrab + "/documentos/RG/nrRg", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RG/orgaoEmissor"))
				aAdd( aRull, { cAlias + "_OREMRG", cCabecTrab + "/documentos/RG/orgaoEmissor", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RG/dtExped"))
				aAdd( aRull, { cAlias + "_DTEMRG", cCabecTrab + "/documentos/RG/dtExped", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RNE/nrRne"))
				aAdd( aRull, { cAlias + "_NRRNE",  cCabecTrab + "/documentos/RNE/nrRne", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RNE/orgaoEmissor"))
				aAdd( aRull, { cAlias + "_OREMRN", cCabecTrab + "/documentos/RNE/orgaoEmissor", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/RNE/dtExped"))
				aAdd( aRull, { cAlias + "_DTEMRN", cCabecTrab + "/documentos/RNE/dtExped", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/OC/nrOc"))
				aAdd( aRull, { cAlias + "_NUMOC",  cCabecTrab + "/documentos/OC/nrOc", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/OC/orgaoEmissor"))
				aAdd( aRull, { cAlias + "_OREMOC", cCabecTrab + "/documentos/OC/orgaoEmissor", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/OC/dtExped"))
				aAdd( aRull, { cAlias + "_DTEXOC", cCabecTrab + "/documentos/OC/dtExped", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/OC/dtValid"))
				aAdd( aRull, { cAlias + "_DTVLOC", cCabecTrab + "/documentos/OC/dtValid", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/nrRegCnh"))
				aAdd( aRull, { cAlias + "_NRCNH",  cCabecTrab + "/documentos/CNH/nrRegCnh", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/dtExped"))
				aAdd( aRull, { cAlias + "_DTEXCN", cCabecTrab + "/documentos/CNH/dtExped", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/ufCnh"))
				aAdd( aRull, { cAlias + "_UFCNH",  FGetIdInt( "ufCnh", "", cCabecTrab + "/documentos/CNH/ufCnh",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/dtValid"))
				aAdd( aRull, { cAlias + "_DTVLCN", cCabecTrab + "/documentos/CNH/dtValid", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/dtPriHab"))
				aAdd( aRull, { cAlias + "_DTPCNH", cCabecTrab + "/documentos/CNH/dtPriHab", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/documentos/CNH/categoriaCnh"))
				aAdd( aRull, { cAlias + "_CATCNH", xFunTrCNH( TAFExisTag(cCabecTrab + "/documentos/CNH/categoriaCnh"), 2) , "C", .T.} )
			EndIf
		EndIf
	Else
		//************
		//eSocial/.../nascimento
		//************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/dtNascto"))
			aAdd( aRull, { cAlias + "_DTNASC", cCabecTrab + "/nascimento/dtNascto", "D" , .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/paisNascto"))
			aAdd( aRull, { cAlias + "_CODPAI", FGetIdInt( "paisNascto", "", cCabecTrab + "/nascimento/paisNascto",,,,@cInconMsg, @nSeqErrGrv ), "C",  .T.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nascimento/paisNac"))
			aAdd( aRull, { cAlias + "_PAINAC", FGetIdInt( "paisNac", "", cCabecTrab + "/nascimento/paisNac",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
		EndIf

	EndIf
	//-------------------------

	//************
	//eSocial/.../endereco
	//************

	If (cLayout $ "2200|2205|2300")

		If AllTrim( FTafGetVal( cCabecTrab + "/endereco/exterior/paisResid", , , {}, , ,  ) ) <> "105";
		 .And. !Empty(AllTrim( FTafGetVal( cCabecTrab + "/endereco/exterior/paisResid", , , {}, , ,  ))) 

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/paisResid"))
				aAdd( aRull, { cAlias + "_PAIS"  , FGetIdInt( "paisResid", "", cCabecTrab + "/endereco/exterior/paisResid",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/dscLograd"))
				aAdd( aRull, { cAlias + "_LOGRAD", cCabecTrab + "/endereco/exterior/dscLograd", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/nrLograd"))
				aAdd( aRull, { cAlias + "_NRLOG" , cCabecTrab + "/endereco/exterior/nrLograd", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/complemento"))
				aAdd( aRull, { cAlias + "_COMLOG", cCabecTrab + "/endereco/exterior/complemento", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/bairro"))
				aAdd( aRull, { cAlias + "_BAIRRO", cCabecTrab + "/endereco/exterior/bairro", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/nmCid"))
				aAdd( aRull, { cAlias + "_NOMCID", cCabecTrab + "/endereco/exterior/nmCid", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/codPostal"))
				aAdd( aRull, { cAlias + "_CEP"   , cCabecTrab + "/endereco/exterior/codPostal", "C", .F.} )
			EndIf

		Else

			aAdd( aRull, { cAlias + "_PAIS"  , FGetIdInt( "paisResid", "", "105", , .F. ,,@cInconMsg, @nSeqErrGrv),"C", .T.} )

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/tpLograd" ))
				aAdd( aRull, { cAlias + "_TPLOGR", FGetIdInt( "tpLograd", "", cCabecTrab + "/endereco/brasil/tpLograd",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/dscLograd"))
				aAdd( aRull, { cAlias + "_LOGRAD", cCabecTrab + "/endereco/brasil/dscLograd", "C", .F. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/nrLograd"))
				aAdd( aRull, { cAlias + "_NRLOG" , cCabecTrab + "/endereco/brasil/nrLograd", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/complemento"))
				aAdd( aRull, { cAlias + "_COMLOG", cCabecTrab + "/endereco/brasil/complemento", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/bairro"))
				aAdd( aRull, { cAlias + "_BAIRRO", cCabecTrab + "/endereco/brasil/bairro", "C", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/cep"))
				aAdd( aRull, { cAlias + "_CEP"   , cCabecTrab + "/endereco/brasil/cep", "C", .F.} )
			EndIf

			getUfMunicipio(@aRull,lNoVldEst,cAlias,cCabecTrab + "/endereco/brasil/uf",cCabecTrab + "/endereco/brasil/codMunic",cAlias+"_MUN",@cInconMsg,@nSeqErrGrv,cCodEvent,cOwner)

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/uf"))
				aAdd( aRull, { cAlias + "_UF", FGetIdInt( "uf", "", cCabecTrab + "/endereco/brasil/uf",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
			EndIf

		EndIf
		//-----------

		If !lLaySimplif

			//**************
			//eSocial/.../trabEstrangeiro
			//**************
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/trabEstrangeiro/dtChegada"))
				aAdd( aRull, { cAlias + "_DTCHEG", cCabecTrab + "/trabEstrangeiro/dtChegada", "D", .F.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/trabEstrangeiro/casadoBr"))
				aAdd( aRull, { cAlias + "_CASBRA", xFunTrcSN( TAFExisTag( cCabecTrab + "/trabEstrangeiro/casadoBr" ) ,2),"C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/trabEstrangeiro/filhosBr"))
				aAdd( aRull, { cAlias + "_FILBRA", xFunTrcSN( TAFExisTag( cCabecTrab + "/trabEstrangeiro/filhosBr" ) ,2),"C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, ( cCabecTrab + "/trabEstrangeiro/classTrabEstrang"))
				aAdd( aRull, { cAlias + "_CCTRAE", FGetIdInt( "classTrabEstrang", "", cCabecTrab + "/trabEstrangeiro/classTrabEstrang",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
			EndIF

		EndIf

		//************** trabImig
		//eSocial/.../trabImig
		//**************
		If lLaySimplif .And. (cLayout $ "2200|2205|2300")

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/trabImig/tmpResid"))
				aAdd( aRull, { cAlias + "_TPRESI", TAFExisTag( cCabecTrab + "/trabImig/tmpResid" ),"C", .T.} )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/trabImig/condIng"))
				aAdd( aRull, { cAlias + "_CNDING", TAFExisTag( cCabecTrab + "/trabImig/condIng" ),"C", .T.} )
			EndIf

		EndIf


		//**************
		//eSocial/.../infoDeficiencia
		//**************
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/defFisica"))
			aAdd( aRull, { cAlias + "_DEFFIS", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/defFisica" ) ,2),"C", .T.} )
		EndIF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/defVisual"))
			aAdd( aRull, { cAlias + "_DEFVIS", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/defVisual" ) ,2),"C", .T.} )
		EndIF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/defAuditiva"))
			aAdd( aRull, { cAlias + "_DEFAUD", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/defAuditiva" ) ,2),"C", .T.} )
		EndIF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/defMental"))
			aAdd( aRull, { cAlias + "_DEFMEN", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/defMental" ) ,2),"C", .T.} )
		EndIF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/defIntelectual"))
			aAdd( aRull, { cAlias + "_DEFINT", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/defIntelectual" ) ,2),"C", .T.} )
		EndIF

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/reabReadap"))
			aAdd( aRull, { cAlias + "_REABIL", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/reabReadap" ) ,2),"C", .T.} )
		EndIF

		If cLayout $ "2200|2205
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/infoCota"))
				aAdd( aRull, { cAlias + "_INFCOT", xFunTrcSN( TAFExisTag( cCabecTrab + "/infoDeficiencia/infoCota" ) ,2),"C", .T.} )
			EndIf
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/infoDeficiencia/observacao"))
			aAdd( aRull, { cAlias + "_OBSDEF", cCabecTrab + "/infoDeficiencia/observacao" ,"M", .F.} )
		EndIF
		//--------------

		If !lLaySimplif

			//*****************
			//eSocial/.../aposentadoria
			//*****************
			If cLayout $ "2200|2205"
				If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/aposentadoria/trabAposent"))
					aAdd( aRull, { cAlias + "_APOSEN", xFunTrcSN( TAFExisTag( cCabecTrab + "/aposentadoria/trabAposent" ) ,2), "C", .T.} )
				EndIF
			EndIf

		EndIf

		//****************/
		//eSocial/.../contato
		//****************
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/contato/fonePrinc"))

			cTelFull  := FTafGetVal( cCabecTrab + "/contato/fonePrinc", "C", .F., @aIncons, .F. )
			cTelFull := AllTrim(cTelFull)

			//A String deve ter + de 9 caracteres para ser possivel a verificação do DDD
			//Se menor que 9 assumo que não foi enviado DDD.
			If Len(cTelFull) > 9
				aTelefone := TafNormTelES(cTelFull)

				cDDDPrincip := aTelefone[1]
				cTelPrincip := aTelefone[2]

				If Len(aTelefone) == 3
					cDDIPrincip := aTelefone[3]
				EndIf

			Else
				cDDDPrincip := ""
				cTelPrincip := cTelFull
			EndIf

			aAdd(aRull, { cAlias + "_DDDFPR", cDDDPrincip , "C", .T.})
			aAdd(aRull, { cAlias + "_FONPRC", cTelPrincip , "C", .T.})

			If Len(aTelefone) == 3
				aAdd(aRull, { cAlias + "_DDIFPR", cDDIPrincip , "C", .T.})
			EndIf

		EndIF

		If !lLaySimplif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/contato/foneAlternat"))

				cTelFull := FTafGetVal( cCabecTrab + "/contato/foneAlternat", "C", .F., @aIncons, .F. )
				cTelFull := AllTrim(cTelFull)

				If Len(cTelFull) > 9
					aTelAlter := TafNormTelES(cTelFull)
					cDDDAlter := aTelAlter[1]
					cTelAlter := aTelAlter[2]

					If Len(aTelAlter) == 3
						cDDIAlter := aTelAlter[3]
					EndIf

				Else
					cDDDAlter := ""
					cTelAlter := cTelFull
				EndIf

				aAdd( aRull, { cAlias + "_DDDFAL", cDDDAlter, "C", .T.} )
				aAdd( aRull, { cAlias + "_FONALT", cTelAlter, "C", .T.} )

				If Len(aTelAlter) == 3
					aAdd(aRull, { cAlias + "_DDIFAL", cDDIAlter , "C", .T.})
				EndIf

			EndIf

		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/contato/emailPrinc"))
			aAdd( aRull, { cAlias + "_EMAILP", cCabecTrab + "/contato/emailPrinc", "C", .F.} )
		EndIF

		If !lLaySimplif

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/contato/emailAlternat"))
				aAdd( aRull, { cAlias + "_EMAILA", cCabecTrab + "/contato/emailAlternat", "C", .F.} )
			EndIF

		EndIf

	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF256Grv
Funcao de gravacao para atender o registro S-2100

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
Function TAF256Grv( cLayout, nOpc, cFilEv, oXML, cOwner )

	Local cCmpsNoUpd  := "|C9V_FILIAL|C9V_ID|C9V_VERSAO|C9V_NOMEVE|C9V_VERANT|C9V_PROTUL|C9V_PROTPN|C9V_EVENTO|C9V_STATUS|C9V_ATIVO|"

	Local nI          := 0
	Local nJ          := 0

	Local lRet        := .F.
	Local lTransmit	  := .F.

	Local aIncons     := {}
	Local aRulesCad   := {}
	Local aRulesVinc  := {}
	Local aChave      := {}

	Local oModel      := Nil
	Local nIndChv     := 10
	Local nSeqErrGrv  := 0

	Local cCabecTrab  := "/eSocial/evtCadInicial/trabalhador"
	Local cCabecVinc  := "/eSocial/evtCadInicial/vinculo"

	Local cT2EPath    := ""
	Local cCRQPath    := ""
	Local cT3LPath    := ""

	Local cMatTrab    := ""
	Local cCPF        := ""
	Local cEnter	  := Chr(13) + Chr(10)
	Local cMensagem   := ""
	Local cInconMsg   := ""
	Local cFilTaf     := ""
	Local cChvTrab    := C9V->C9V_ID + '1'
	Local lAltPend    := .F. //Indica se existe uma alteração pendente.
	Local cCodEvent   := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

	Private lVldModel := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.

	Private oDados    := {}

	Default cLayout   := "2100"
	Default nOpc      := 1
	Default cFilEv    := ""
	Default oXML      := Nil

	If !TafVldAmb("2")

		cMensagem := STR0062 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else

		cFilTaf	:= FTafGetFil( cFilEv , @aIncons , "C9V" )
		oDados 	:= oXML
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/matricula"  ))
			cMatTrab := oDados:XPathGetNodeValue( cCabecVinc + "/matricula" )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecTrab + "/cpfTrab"  ))
			cCPF	  := oDados:XPathGetNodeValue( cCabecTrab + "/cpfTrab" )
		EndIf

		aAdd( aChave, {"C", "C9V_CPF", cCPF, .T. } )
		aAdd( aChave, {"C", "C9V_MATRIC", cMatTrab, .T. } )
		aAdd( aChave, {"C", "C9V_NOMEVE", "S2100", .T. } )

		cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) + Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1] )

		//Verifica se o evento ja existe na base
		dbSelectArea("C9V")
		("C9V")->( DbSetOrder( nIndChv ) )
		If ("C9V")->( MsSeek(cFilTaf + cChave + '1' ) )
			nOpc := 4
			lTransmit 	:= IIF(C9V->C9V_STATUS == '4',.T.,.F.)

			//=======================================================================================================+
			// Posiciona no último evento de alteração (2205) ativo para este trabalhador.                          ||
			// Retorna .F. se não encontrar um registro de alteração ativo para este trabalhador e .T. SE encontrar ||
			//=======================================================================================================+
			IF RetUltAtivo('T1U',cChvTrab,2)
				If T1U->T1U_STATUS <> '4'
					Aadd( aIncons, "ERRO19")
					lAltPend := .T.
				Endif
			EndIf

			if !lAltPend
				//=======================================================================================================+
				// Posiciona no último evento de alteração (2206) ativo para este trabalhador.                          ||
				// Retorna .F. se não encontrar um registro de alteração ativo para este trabalhador e .T. SE encontrar ||
				//=======================================================================================================+
				IF RetUltAtivo('T1V',cChvTrab,2)
					If T1V->T1V_STATUS <> '4'
						Aadd( aIncons, "ERRO19")
						lAltPend := .T.
					Endif
				EndIf
			Endif
		EndIf

		Begin Transaction

			IF !lAltPend //Continua o processo de integração apenas se não houver nenhum evento de alteração pendente.
				//Funcao para validar se a operacao desejada pode ser realizada
				If FTafVldOpe( "C9V", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA256", cCmpsNoUpd )

					//Caso se trate de uma inclusao/retificação gravo o tipo do evento na tabela C9V
					oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2100" )

					//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
					aRulesCad := FRulCad( cCabecTrab, cLayout, 		 , cCabecVinc, @cInconMsg, @nSeqErrGrv, lTransmit, oModel,		,aIncons, cCodEvent, cOwner)


					//Carrego array com os campos De/Para de gravacao das informacoes ( Vínculo )
					aRulesVinc := FRulVinc( cCabecVinc, cLayout, 		,@cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )

					//Quando se tratar de uma Exclusao direta apenas preciso realizar
					//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
					If nOpc <> 5

						oModel:LoadValue( "MODEL_C9V", "C9V_FILIAL", C9V->C9V_FILIAL )
						//Rodo o aRulesCad para gravar as informacoes
						For nI := 1 to Len( aRulesCad )
							oModel:LoadValue( "MODEL_C9V", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
						Next nI


						//Rodo o aRulesVinc para gravar as informacoes
						For nI := 1 to Len( aRulesVinc )
							oModel:LoadValue( "MODEL_CUP", aRulesVinc[ nI, 01 ], FTafGetVal( aRulesVinc[ nI, 02 ], aRulesVinc[nI, 03], aRulesVinc[nI, 04], @aIncons, .F. ) )
						Next nI

						//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Cadastro de Dependentes )
						//***********
						//Dependentes
						//***********
						cT2EPath := cCabecTrab + "/dependente[1]"

						If nOpc == 4 .and. TafXNode( oDados , cCodEvent, cOwner, ( cT2EPath ))
							For nJ := 1 to oModel:GetModel( "MODEL_T2E" ):Length()
								oModel:GetModel( "MODEL_T2E" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T2E" ):DeleteLine()
							Next nJ
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
						nJ := 1
						While oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ)+ "]" )
							If nOpc == 4 .or. nJ > 1
								oModel:GetModel( "MODEL_T2E" ):lValid:= .T.
								oModel:GetModel( "MODEL_T2E" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T2E", "T2E_IDDEP" , StrZero(nJ,6) )

							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/tpDep"))
								oModel:LoadValue( "MODEL_T2E", "T2E_TPDEP" , FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep",,,,@cInconMsg, @nSeqErrGrv))
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_TPDEP" , T2E->T2E_TPDEP )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/nmDep"))
								oModel:LoadValue( "MODEL_T2E", "T2E_NOMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep", "C", .F., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_NOMDEP" , T2E->T2E_NOMDEP )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, ( cCabecTrab + "/dependente/dtNascto"))
								oModel:LoadValue( "MODEL_T2E", "T2E_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto", "D", .F., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_DTNASC" , T2E->T2E_DTNASC )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/cpfDep"))
								oModel:LoadValue( "MODEL_T2E", "T2E_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep", "C", .F., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_CPFDEP" , T2E->T2E_CPFDEP )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/depIRRF"))
								oModel:LoadValue( "MODEL_T2E", "T2E_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF" ) ,2) , "C", .T., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_DEPIRF" , T2E->T2E_DEPIRF )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/depSF"))
								oModel:LoadValue( "MODEL_T2E", "T2E_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF"   ) ,2) , "C", .T., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_DEPSFA" , T2E->T2E_DEPSFA )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/depPlan"))
								oModel:LoadValue( "MODEL_T2E", "T2E_DPPLPS", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depPlan"  ) ,2) , "C", .T., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_DPPLPS" , T2E->T2E_DPPLPS )
							EndIf
							If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dependente/incTrab"))
								oModel:LoadValue( "MODEL_T2E", "T2E_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab"  ) ,2) , "C", .T., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T2E", "T2E_INCTRB" , T2E->T2E_INCTRB )
							EndIf
							nJ ++
						EndDo
						//----------

						//***********
						//Hora Contratual
						//***********
						//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Cadastro de Hora Contratual )

						cCRQPath := cCabecVinc + "/infoContrato/horContratual/horario[1]"
						cCRQXPat := cCabecVinc + "/infoContrato/horContratual/horario"

						If nOpc == 4 .and. oDados:XPathHasNode( cCRQPath )
							For nJ := 1 to oModel:GetModel( "MODEL_CRQ" ):Length()
								oModel:GetModel( "MODEL_CRQ" ):GoLine(nJ)
								oModel:GetModel( "MODEL_CRQ" ):DeleteLine()
							Next nJ
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Hora Contratual )
						If !lLaySimplif
							nJ := 1
							While oDados:XPathHasNode( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nJ)+ "]" )
								If nOpc == 4 .or. nJ > 1
									oModel:GetModel( "MODEL_CRQ" ):lValid:= .T.
									oModel:GetModel( "MODEL_CRQ" ):AddLine()
								EndIf

								If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoContrato/horContratual/horario/dia" ))
									oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA", FTafGetVal( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nJ) + "]/dia", "C", .F., @aIncons, .F. ) )
								ElseIf lTransmit
									oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA" , CRQ->CRQ_CODDIA )
								EndIf

								If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoContrato/horContratual/horario/codHorContrat" ))
									oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , FGetIdInt( "codHorContrat", "", cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nJ) + "]/codHorContrat",,,,@cInconMsg, @nSeqErrGrv))
								ElseIf lTransmit
									oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , CRQ->CRQ_CODHOR )
								EndIf
								nJ ++
							EndDo
						EndIf
						//---------

						//***********
						//Trabalhador Substituido
						//***********
						cT3LPath := cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido[1]"

						If nOpc == 4 .and. oDados:XPathHasNode( cT3LPath )
							For nJ := 1 to oModel:GetModel( "MODEL_T3L" ):Length()
								oModel:GetModel( "MODEL_T3L" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T3L" ):DeleteLine()
							Next nJ
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Trabalhador Substituido )
						nJ := 1
						While oDados:XPathHasNode( cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido[" + cValToChar(nJ)+ "]" )
							If nOpc == 4 .or. nJ > 1
								oModel:GetModel( "MODEL_T3L" ):lValid:= .T.
								oModel:GetModel( "MODEL_T3L" ):AddLine()
							EndIf

							if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido/cpfTrabSubst"))
								oModel:LoadValue( "MODEL_T3L", "T3L_CPF", FTafGetVal( cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido[" + cValToChar(nJ) + "]/cpfTrabSubst",  "C", .F., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T3L", "T3L_CPF" , T3L->T3L_CPF )
							EndIf
							if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido/matricTrabSubst"))
								oModel:LoadValue( "MODEL_T3L", "T3L_MATRIC", FTafGetVal( cCabecVinc + "/infoRegimeTrab/infoCeletista/trabTemporario/ideTrabSubstituido[" + cValToChar(nJ) + "]/matricTrabSubst", "C", .F., @aIncons, .F. ) )
							ElseIf lTransmit
								oModel:LoadValue( "MODEL_T3L", "T3L_MATRIC" , T3L->T3L_MATRIC )
							EndIf
							nJ ++
						EndDo

						//-----------

					EndIf

					///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetiva a operacao desejada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(cInconMsg) .And. Empty(aIncons)
						If TafFormCommit( oModel )
							Aadd(aIncons, "ERRO19")
						Else
							lRet := .T.
						EndIf
					Else
						Aadd(aIncons, cInconMsg)
					EndIf

					fwFormCancel( oModel )
					FreeObj( oModel )

				EndIf
			Endif
		End Transaction

		//Zerando os arrays e os Objetos utilizados no processamento

		aSize( aRulesCad, 0 )
		aRules := Nil

		aSize( aRulesVinc, 0 )
		aRules := Nil

		aSize( aChave, 0 )
		aChave := Nil

		oModel := Nil

	Endif

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF256Xml

Funcao de geracao do XML para atender os registros S-2100.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2100

@author Felipe C. Seolin / Rodrigo Aguilar
@since 30/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF256Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml			:= ""
	Local cReg			:= "CadInicial"
	Local cLayout		:= "2100"
	Local nRecnoSM0 := SM0->(Recno())

	Default lJob		:= .F.

	cXml += FGetCad( cLayout, "C9V")

	cXml += FGetVinc( cLayout, "CUP" )
	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, "C9V", cLayout, cReg )

	//Executa gravacao do registro
	If !lJob
		If nRecnoSM0 > 0
			SM0->(dbGoto(nRecnoSM0))
		endif
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetCad
Funcao para estrutura dos dados de cadastro do Xml 2200 e 2205

@Param:
cLayout - Layout para montagem da estrutura
cAlias  - Alias da Tabela

@Return:
cXml - Estrutura dos dados de cadastro do Xml

@author Felipe C. Seolin / Rodrigo Aguilar
@since 03/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGetCad( cLayout, cAlias, cAliasDep )

	Local cXml			:= ""
	Local cTagTrab		:= ""
	Local cCmpCEP		:= ""
	Local cPais			:= ""
	Local cAuxUf		:= ""
	Local cXmlDocs		:= ""
	Local cDDDPrincip	:= ""
	Local cDDDAlter  	:= ""
	Local cDDIPrincip	:= ""
	Local cDDIAlter  	:= ""
	Local cNis          := ""
	Local cXMLBras		:= ""
	Local cXMLExt		:= ""
	Local cCodMun		:= ""
	Local cCodUF		:= ""
	Local lPosC9V		:= .F.

	Default cLayout		:= ""
	Default cAlias		:= ""
	Default cAliasDep	:= "T2E"

	If cLayout == "2205"
		cTagTrab := "dadosTrabalhador"
	Else
		cTagTrab := "trabalhador"
	EndIf

	DBSelectArea( "C09" )
	C09->( DBSetOrder( 3 ))

	DBSelectArea( "C06" )
	C06->( DBSetOrder( 3 ))

	DBSelectArea( "C07" )
	C07->(DBSetOrder( 3 ))

	DBSelectArea( cAliasDep )
	(cAliasDep)->( DBSetOrder( 1 ))

	DBSelectArea( "CMI" )
	CMI->( DBSetOrder( 1 ))

	If cLayout == "2205"
		cXml += "<ideTrabalhador>"
		cXml +=	 	xTafTag( "cpfTrab", (cAlias)->&( cAlias + "_CPF" ) )
		cXml += "</ideTrabalhador>"
		cXml += "<alteracao>"
		cXml += 	xTafTag("dtAlteracao",(cAlias)->&( cAlias + "_DTALT" ) )
	EndIf

	cXml +=	"<" + cTagTrab + ">"
	If cLayout $ "2200|2300|2306"
		cXml +=	 xTafTag( "cpfTrab", (cAlias)->&( cAlias + "_CPF" ) )
	EndIf

	If FunName() == "TAFMIGR003" .And. cAlias == "C9V"
		lPosC9V := .T. //Quando o Alias vem posicionado
	EndIf

	If !lLaySimplif
		cNis := TAF250Nis( (cAlias)->&( cAlias + "_FILIAL" ), (cAlias)->&( cAlias + "_ID" ), (cAlias)->&( cAlias + "_NIS" ), Dtos((cAlias)->&( cAlias + "_DTALT" )),,lPosC9V)

		If cLayout $ "2205|2300|2306"
			cXml +=	 xTafTag("nisTrab",cNis,,.T. )
		Else
			cXml +=	 xTafTag("nisTrab",cNis)
		EndIf

	EndIf

	If cLayout <> "2206" .And. cLayout <> "2306"

		cXml +=	 xTafTag("nmTrab", FwCutOff((cAlias)->&( cAlias + "_NOME" ), .T.) )
		cXml +=	 xTafTag("sexo",				(cAlias)->&( cAlias + "_SEXO" ) )
		cXml +=	 xTafTag("racaCor",         (cAlias)->&( cAlias + "_RCCOR" ) )
		cXml +=	 xTafTag("estCiv",          (cAlias)->&( cAlias + "_ESTCIV" ),,.T. )
		cXml +=	 xTafTag("grauInstr"	,Posicione("CMH",1,xFilial("CMH") + (cAlias)->&( cAlias + "_GRINST" ),"CMH_CODIGO"))

		If cLayout <> "2200"
			cXml +=	 xTafTag("nmSoc"	,FwCutOff((cAlias)->&( cAlias + "_NOMSOC" ), .T.),,.T. )
		Else
			If !lLaySimplif
				cXml +=	 xTafTag("indPriEmpr",xFunTrcSN((cAlias)->&( cAlias + "_PRIEMP" ),1) ,,.T. )
			EndIf
			cXml +=	 xTafTag("nmSoc"	,FwCutOff((cAlias)->&( cAlias + "_NOMSOC" ), .T.),,.T. )
		EndIf

		If cLayout $ "2205" .And. lLaySimplif
			cXml +=	xTafTag("paisNac", Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAINAC" ),"C08_PAISSX"))
		EndIf

	EndIf

	If !lLaySimplif .And. cLayout $ "2200|2205|2300"

		cXml +=	 "<nascimento>"
		cXml +=	 	xTafTag("dtNascto",(cAlias)->&( cAlias + "_DTNASC" ))
		If C09->(MsSeek(xFilial("C09") + (cAlias)->&( cAlias + "_CODUF" )))
			If C07->(MsSeek(xFilial("C07") + (cAlias)->&( cAlias + "_CODMUN" )))
				cXml +=	xTafTag("codMunic",C09->C09_CODIGO+C07->C07_CODIGO,,.T.)
			EndIf
			cXml +=	xTafTag("uf",C09->C09_UF,,.T.)
		EndIf

		cXml +=		xTafTag("paisNascto",Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_CODPAI" ),"C08_PAISSX"))
		cXml +=		xTafTag("paisNac"	,Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAINAC" ),"C08_PAISSX"))
		cXml +=		xTafTag("nmMae"		,FwCutOff((cAlias)->&( cAlias + "_NOMMAE" ), .T.),,.T. )
		cXml +=		xTafTag("nmPai"		,FwCutOff((cAlias)->&( cAlias + "_NOMPAI" ), .T.),,.T. )
		cXml +=	"</nascimento>"

	ElseIf cLayout $ "2200|2300"

		cXml +=	 "<nascimento>"
		cXml +=	 	xTafTag("dtNascto",(cAlias)->&( cAlias + "_DTNASC" ))
		cXml +=		xTafTag("paisNascto",Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_CODPAI" ),"C08_PAISSX"))
		cXml +=		xTafTag("paisNac"	,Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAINAC" ),"C08_PAISSX"))
		cXml +=	"</nascimento>"

	EndIf

	If !lLaySimplif

		If C09->(MsSeek(xFilial("C09") + (cAlias)->&( cAlias + "_UFCTPS" ) ) )
			cAuxUf := C09->C09_UF
		Else
			cAuxUf := (cAlias)->&( cAlias + "_UFCTPS" )
		EndIf

		xTafTagGroup("CTPS"	,{{"nrCtps"		,(cAlias)->&( cAlias + "_NRCTPS" ) ,,.F.};
			, {"serieCtps"	,(cAlias)->&( cAlias + "_SERCTP" )	,,.F.};
			, {"ufCtps"		,AllTrim(cAuxUf)						,,.F.}};
			, @cXmlDocs)

		xTafTagGroup("RIC"	,{{"nrRic"			,(cAlias)->&( cAlias + "_NRRIC"  )	,,.F.};
			, {"orgaoEmissor"	,(cAlias)->&( cAlias + "_OREMRI" )	,,.F.};
			, {"dtExped"		,(cAlias)->&( cAlias + "_DTEXRI" )	,,.T.}};
			, @cXmlDocs)

		xTafTagGroup("RG"		,{{"nrRg"			,(cAlias)->&( cAlias + "_NRRG"   )	,,.F.};
			, {"orgaoEmissor"	,(cAlias)->&( cAlias + "_OREMRG" )	,,.F.};
			, {"dtExped"		,(cAlias)->&( cAlias + "_DTEMRG" )	,,.T.}};
			, @cXmlDocs)

		xTafTagGroup("RNE"	,{{"nrRne"			,(cAlias)->&( cAlias + "_NRRNE"  )	,,.F.};
			, {"orgaoEmissor"	,(cAlias)->&( cAlias + "_OREMRN" )	,,.F.};
			, {"dtExped"		,(cAlias)->&( cAlias + "_DTEMRN" )	,,.T.}};
			, @cXmlDocs)

		xTafTagGroup("OC"		,{{"nrOc"			,(cAlias)->&( cAlias + "_NUMOC"  )	,,.F.};
			, {"orgaoEmissor"	,(cAlias)->&( cAlias + "_OREMOC" )	,,.F.};
			, {"dtExped"		,(cAlias)->&( cAlias + "_DTEXOC" )	,,.T.};
			, {"dtValid"		,(cAlias)->&( cAlias + "_DTVLOC" )	,,.T.}};
			, @cXmlDocs)

		cAuxUf := Posicione("C09",3,xFilial("C09")+(cAlias)->&( cAlias + "_UFCNH" ),"C09_UF")

		xTafTagGroup("CNH"	,{{"nrRegCnh"		,(cAlias)->&( cAlias + "_NRCNH"  )	,,.F.};
			, {"dtExped"		,(cAlias)->&( cAlias + "_DTEXCN" )	,,.T.};
			, {"ufCnh"			, AllTrim(cAuxUf)						,,.F.};
			, {"dtValid"		,(cAlias)->&( cAlias + "_DTVLCN" )	,,.F.};
			, {"dtPriHab"		,(cAlias)->&( cAlias + "_DTPCNH" )	,,.T.};
			, {"categoriaCnh"	,xFunTrCNH( (cAlias)->&( cAlias + "_CATCNH" ), 1) ,,.F.}};
			, @cXmlDocs)

		If !Empty(cXmlDocs)
			cXml += "<documentos>"
			cXml += cXmlDocs
			cXml += "</documentos>"
		EndIf

	EndIf

	cPais	:= Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAIS" ), "C08_PAISSX")
	cCmpCEP := StrTran( (cAlias)->&( cAlias + "_CEP" ), "-", "" )

	If cPais == "105"
		
		If C07->(MsSeek(xFilial("C07") + (cAlias)->&( cAlias + "_MUN" ) ) )
			If C09->(MsSeek(xFilial("C09") + C07->C07_UF))
				cCodMun := C09->C09_CODIGO + C07->C07_CODIGO
				cCodUF 	:= C09->C09_UF
			EndIf
		EndIf
		
		xTafTagGroup("brasil";
			,{{"tpLograd"	,Posicione("C06",3,xFilial("C06") + (cAlias)->&( cAlias + "_TPLOGR" ),"C06_CESOCI")									,,.T.};
			, {"dscLograd"	,FwCutOff((cAlias)->&( cAlias + "_LOGRAD" ), .T.)	,,.F.};
			, {"nrLograd"	,(cAlias)->&( cAlias + "_NRLOG" )					,,.F.};
			, {"complemento",FwCutOff((cAlias)->&( cAlias + "_COMLOG" ), .T.)	,,.T.};
			, {"bairro"		,FwCutOff((cAlias)->&( cAlias + "_BAIRRO" ), .T.)	,,.T.};
			, {"cep"		,cCmpCEP											,,.F.};
			, {"codMunic"	,cCodMun											,,.F.};
			, {"uf"			,cCodUF												,,.F.}};
			,@cXMLBras)

	Else

		xTafTagGroup("exterior";
			,{{"paisResid"	,Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAIS" ),"C08_PAISSX")	,,.F.};
			, {"dscLograd"	,FwCutOff((cAlias)->&( cAlias + "_LOGRAD" ), .T.)									,,.F.};
			, {"nrLograd"	,(cAlias)->&( cAlias + "_NRLOG" )													,,.F.};
			, {"complemento",FwCutOff((cAlias)->&( cAlias + "_COMLOG" ), .T.)									,,.T.};
			, {"bairro"		,FwCutOff((cAlias)->&( cAlias + "_BAIRRO" ), .T.)									,,.T.};
			, {"nmCid"		,FwCutOff((cAlias)->&( cAlias + "_NOMCID" ), .T.)									,,.F.};
			, {"codPostal"	,cCmpCEP																			,,.T.}};
			,@cXMLExt)

	EndIf

	xTafTagGroup("endereco",;
		,@cXML;
		,{{"brasil"		,cXMLBras,0};
		, {"exterior"	,cXMLExt ,0}};
		,.T.;
		,.T.)

	If !lLaySimplif

		xTafTagGroup("trabEstrangeiro"	,{{"dtChegada"				,(cAlias)->&( cAlias + "_DTCHEG" ) 															,,.T.};
			, {"classTrabEstrang"	,Posicione("T13",1,xFilial("T13")+(cAlias)->&( cAlias + "_CCTRAE" ),"T13_CODIGO")			,,.F.};
			, {"casadoBr"			,xFunTrcSN((cAlias)->&( cAlias + "_CASBRA" ),1)												,,.F.};
			, {"filhosBr"			,xFunTrcSN((cAlias)->&( cAlias + "_FILBRA" ),1)												,,.F.}};
			, @cXml)

	Else

		xTafTagGroup(	"trabImig";
			,{{"tmpResid", (cAlias)->&(cAlias + "_TPRESI"), PesqPict(cAlias, cAlias + "_TPRESI"), .T.};
			,{"condIng" ,  (cAlias)->&(cAlias + "_CNDING"), PesqPict( cAlias, cAlias + "_CNDING"), .T.}};
			,@cXml)

	EndIf
	
	If cLayout $ "2200|2205"
		xTafTagGroup("infoDeficiencia";	
			,{{"defFisica"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFFIS" ),1) 								,,.F.};
			, {"defVisual"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFVIS" ),1)									,,.F.};
			, {"defAuditiva"		,xFunTrcSN((cAlias)->&( cAlias + "_DEFAUD" ),1)									,,.F.};
			, {"defMental"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFMEN" ),1)									,,.F.};
			, {"defIntelectual"		,xFunTrcSN((cAlias)->&( cAlias + "_DEFINT" ),1)									,,.F.};
			, {"reabReadap"			,xFunTrcSN((cAlias)->&( cAlias + "_REABIL" ),1)									,,.F.};
			, {"infoCota"			,xFunTrcSN((cAlias)->&( cAlias + "_INFCOT" ),1)									,,.T.};
			, {"observacao"			,FwNoAccent(StrTran((cAlias)->&( cAlias + "_OBSDEF" ), Chr(13) + Chr(10), " "))	,,.T.}};
			, @cXml)
	Else
		xTafTagGroup("infoDeficiencia";	
			,{{"defFisica"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFFIS" ),1) 								,,.F.};
			, {"defVisual"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFVIS" ),1)									,,.F.};
			, {"defAuditiva"		,xFunTrcSN((cAlias)->&( cAlias + "_DEFAUD" ),1)									,,.F.};
			, {"defMental"			,xFunTrcSN((cAlias)->&( cAlias + "_DEFMEN" ),1)									,,.F.};
			, {"defIntelectual"		,xFunTrcSN((cAlias)->&( cAlias + "_DEFINT" ),1)									,,.F.};
			, {"reabReadap"			,xFunTrcSN((cAlias)->&( cAlias + "_REABIL" ),1)									,,.F.};
			, {"observacao"			,FwNoAccent(StrTran((cAlias)->&( cAlias + "_OBSDEF" ), Chr(13) + Chr(10), " "))	,,.T.}};
			, @cXml)
	EndIf

	If (cAliasDep)->(MsSeek(xFilial(cAliasDep) + (cAlias)->( &( cAlias + "_ID") + &( cAlias + "_VERSAO" ) ) ) )

		While (cAliasDep)->(!Eof()) .and. (cAliasDep)->(&(cAliasDep + "_FILIAL") + &(cAliasDep + "_ID") + &(cAliasDep + "_VERSAO")) == xFilial(cAliasDep) + (cAlias)->( &( cAlias + "_ID" ) + &( cAlias + "_VERSAO" ) )
			cXml +=	"<dependente>"

			If CMI->(MsSeek(xFilial("CMI") + (cAliasDep)->&(cAliasDep + "_TPDEP")))
				cXml +=	xTafTag("tpDep",CMI->CMI_CODIGO)
			EndIf

			cXml +=		xTafTag("nmDep"		,FwCutOff((cAliasDep)->&(cAliasDep + "_NOMDEP"), .T.))
			cXml +=		xTafTag("dtNascto"	,(cAliasDep)->&(cAliasDep + "_DTNASC"))
			cXml +=		xTafTag("cpfDep"	,(cAliasDep)->&(cAliasDep + "_CPFDEP"),,.T.)

			If lLaySimplif .And. cLayout $ "2200|2205"
				cXml +=		xTafTag("sexoDep"	,(cAliasDep)->&(cAliasDep + "_SEXDEP"),,.T.)
			EndIf

			cXml +=		xTafTag("depIRRF"	,xFunTrcSN((cAliasDep)->&(cAliasDep + "_DEPIRF"),1))
			cXml +=		xTafTag("depSF"		,xFunTrcSN((cAliasDep)->&(cAliasDep + "_DEPSFA"),1))
			cXml +=		xTafTag("incTrab"	,xFunTrcSN((cAliasDep)->&(cAliasDep + "_INCTRB"),1))

			cXml +=	"</dependente>"
			(cAliasDep)->(DBSkip())
		EndDo

	EndIf

	If cLayout $ "2200|2205|" .And. !lLaySimplif

		If !Empty((cAlias)->&( cAlias + "_APOSEN" ))
			cXml +=		"<aposentadoria>"
			cXml +=			xTafTag("trabAposent",xFunTrcSN((cAlias)->&( cAlias + "_APOSEN" ), 1) )
			cXml +=		"</aposentadoria>"
		EndIf

	EndIf

	If TafColumnPos("C9V_DDIFPR")
		If !Empty((cAlias)->&( cAlias + "_DDIFPR" ))
			cDDIPrincip := (cAlias)->&( cAlias + "_DDIFPR" )
		EndIf
	EndIf

	If !Empty((cAlias)->&( cAlias + "_DDDFPR" ))
		cDDDPrincip := (cAlias)->&( cAlias + "_DDDFPR" )
	EndIf

	If TafColumnPos("C9V_DDIFAL") .And. !lLaySimplif
		If !Empty((cAlias)->&( cAlias + "_DDIFAL" ))
			cDDIAlter := (cAlias)->&( cAlias + "_DDIFAL" )
		EndIf
		If !Empty((cAlias)->&( cAlias + "_DDDFAL" ))
			cDDDAlter := (cAlias)->&( cAlias + "_DDDFAL" )
		EndIf
	EndIf

	If !lLaySimplif

		xTafTagGroup("contato"		,{{"fonePrinc"			,AllTrim(cDDIPrincip) + AllTrim(cDDDPrincip) + (cAlias)->&( cAlias + "_FONPRC" )		,,.T.};
			, {"foneAlternat"		,AllTrim(cDDIAlter)   + AllTrim(cDDDAlter)   + (cAlias)->&( cAlias + "_FONALT" )		,,.T.};
			, {"emailPrinc"			,FwCutOff((cAlias)->&( cAlias + "_EMAILP" ), .T.)										,,.T.};
			, {"emailAlternat"		,FwCutOff((cAlias)->&( cAlias + "_EMAILA" ), .T.)										,,.T.}};
			, @cXml)

	Else

		xTafTagGroup("contato"		,{{"fonePrinc"			,AllTrim(cDDIPrincip) + AllTrim(cDDDPrincip) + (cAlias)->&( cAlias + "_FONPRC" )		,,.T.};
			, {"emailPrinc"			,FwCutOff((cAlias)->&( cAlias + "_EMAILP" ), .T.)										,,.T.}};
			, @cXml)

	EndIf

	cXml +=	"</" + cTagTrab + ">"

	If cLayout == "2205"
		cXml += "</alteracao>"
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetVinc
Funçao para estrutura dos dados de vinculo do Xml 2200 e 2206

@Param:
cLayout - Layout para montagem da estrutura
cAlias  - Alias da Tabela

@Return:
cXml - Estrutura dos dados de vinculo do Xml

@author Felipe C. Seolin / Rodrigo Aguilar
@since 03/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGetVinc(cLayout, cAlias, cAliasHora , cAliasSind, cAliasObs, cIDC9V, cAliasCap)

	Local aCGCMat		:= {}
	Local aCGCFil		:= {}
	Local cXml			:= ""
	Local cXmlCelet	    := ""
	Local cInfRegTra	:= ""
	Local cInfoEstat	:= ""
	Local cXmlFGTS	    := ""
	Local cXmlTrabT	    := ""
	Local cXmlTomSrv	:= ""
	Local cXmlEstbV	    := ""
	Local cXmlTrabS	    := ""
	Local cXmlApren	    := ""
	Local cXmlProcJ	    := ""
	Local cXmlRemun  	:= ""
	Local cXmlDuracao	:= ""
	Local cCodMun		:= ""
	Local cCodUF		:= ""
	Local cXmlLocTG 	:= ""
	Local cXmlLocTD 	:= ""
	Local cXmlLocTrab	:= ""
	Local cXmlHrCont 	:= ""
	Local cXmlHorar	    := ""
	Local cXmlFSind	    := ""
	Local cXmlAlvJud 	:= ""
	Local cXmlObs		:= ""
	Local cXmlSrvPub	:= ""
	Local cFilMat	    := ""
	Local cTagtrabTm    := ""
	Local cXmlTreiCap   := ""
	Local cNisFunc		:= ""
	Local lCGCOk        := .F.

	Default cLayout		:= ""
	Default cAlias		:= ""
	Default cIDC9V		:= ""
	Default cAliasHora	:= "CRQ"
	Default cAliasSind	:= IIf(cLayout == "2200","T80","T79")
	Default cAliasObs	:= IIf(cLayout == "2200","T90","T91")
	Default cAliasCap	:= IIf(cLayout == "2200","V87","V91")
	
	DBSelectArea("CUP")
	CUP->(DBSetOrder(1))

	DBSelectArea( "C09" )
	C09->( DBSetOrder( 3 ))

	DBSelectArea( "C90" )
	C90->(DBSetOrder( 3 ))

	DBSelectArea("C8B")
	C8B->(DBSetOrder(3))

	DBSelectArea("CM7")
	CM7->(DBSetOrder(1))

	DBSelectArea("C9W")
	C9W->(DBSetOrder(1))

	DBSelectArea( cAliasHora )
	(cAliasHora)->( DBSetOrder( 1 ))

	DBSelectArea( "T3L" )
	T3L->( DBSetOrder( 1 ))

	DBSelectArea( "C07" )
	C07->( DBSetOrder( 3 ))

	CUP->(MsSeek(xFilial("CUP")+C9V->C9V_ID+C9V->C9V_VERSAO))

	cIDC9V  := IIF(Empty( cIDC9V), C9V->C9V_ID,  cIDC9V)

	If TAFColumnPos( cAlias+"_DTALT" )
		cNisFunc := ExistAltNis( C9V->C9V_FILIAL, cIDC9V, C9V->C9V_CPF, C9V->C9V_NOMEVE, (cAlias)->&( cAlias + "_DTALT" ) )
	EndIf

	If cLayout == "2206"

		//********************
		//ideVinculo
		//********************
		cXml += "<ideVinculo>"
		cXml +=		xTafTag("cpfTrab"		,(cAlias)->&( cAlias + "_CPF" ))
		If !lLaySimplif
			If Empty(cNisFunc)
				cXml +=		xTafTag("nisTrab"		,(cAlias)->&( cAlias + "_NIS" ))
			Else
				cXml +=		xTafTag("nisTrab"		,cNisFunc)
			EndIf
		EndIf
		cXml +=		xTafTag("matricula" 	,(cAlias)->&( cAlias + "_MATRIC" ) )
		cXml += "</ideVinculo>"
		//--------------------

		cXml += "<altContratual>"

		cXml +=		xTafTag("dtAlteracao"	,(cAlias)->&( cAlias + "_DTALT" ) )
		cXml +=		xTafTag("dtEf"       	,(cAlias)->&( cAlias + "_DTEF" ),,.T.)
		cXml +=		xTafTag("dscAlt"     	,FwCutOff((cAlias)->&( cAlias + "_DESALT" ), .T.),,.T. )

		//********************
		//vinculo
		//********************
		cXml +=	"<vinculo>"
		cXml +=		xTafTag("tpRegPrev",(cAlias)->&( cAlias + "_TPREGP" ) )
		If !lLaySimplif
			cXml +=	"</vinculo>"
		EndIf

		//--------------------

	Else

		cXml +=	"<vinculo>"
		cXml +=		xTafTag("matricula",IIF(cAlias == "CUP", C9V->C9V_MATRIC,(cAlias)->&( cAlias + "_MATRIC" ) ) )
		cXml +=		xTafTag("tpRegTrab",(cAlias)->&( cAlias + "_TPREGT" ) )
		cXml +=		xTafTag("tpRegPrev",(cAlias)->&( cAlias + "_TPREGP" ) )

		If cLayout == "2200"

			//Verifico se existe uma admissão preliminar para trabalhador que estiver sendo integrado
			cFilC9V := xFilial("C9V")
			T3A->( DbSetOrder( 2 ) )

			If !lLaySimplif

				If T3A->(MsSeek(xFilial('T3A') + C9V->C9V_CPF + DTOS(CUP->CUP_DTADMI) + '1')) //Verificar se existe S-2190 na Filial de Destino

					If Empty(CUP->CUP_MATANT)
						If !Empty(T3A->T3A_PROTUL)
							cXml +=		xTafTag("nrRecInfPrelim", T3A->T3A_PROTUL, , .T. )
						EndIf
					EndIf

				Else

					//Verificar se existe S-2190 na Matriz
					//Regra Especifica do Sistema DataSul, quando não acha o 2190 na filial, procurar na Matriz.
					aCGCMat := TAFGFilMatriz()

					If Len(aCGCMat) > 0

						cFilMat := aCGCMat[2]
						cFilMat := Padr(cFilMat,FWSizeFilial())

						If !FWModeAccess("C9V") == "C"

							aCGCFil := FWSM0Util():GetSM0Data( FWGrpCompany() , cFilC9V , { "M0_CGC", "M0_CODFIL" } )

							If Len(aCGCMat) > 0 .And. Len(aCGCFil) > 0
								lCGCOk := SubStr(AllTrim(aCGCMat[3]),1 ,8) == SubStr(aCGCFil[1][2] ,1 ,8)
							EndIf

						Else
							lCGCOk := .T.
						EndIf

						If lCGCOk 

							T3A->( DbSetOrder( 2 ) )

							If T3A->(MsSeek(cFilMat + C9V->C9V_CPF + DTOS(CUP->CUP_DTADMI) + '1'))

								If !Empty(T3A->T3A_PROTUL)
									cXml +=		xTafTag("nrRecInfPrelim", T3A->T3A_PROTUL, , .T. )
								EndIf

							EndIf

						EndIf
					EndIf
				EndIf
			EndIf

			cXml += 	xTafTag("cadIni",xFunTrcSN(C9V->C9V_CADINI, 1),,.T. )

		EndIf

	EndIf

	/*+------------------------------------------------------------+
	| Data:09.05.2017	     	                 				 		|
	| Responsável: Evandro dos Santos Oliveira             		|
	| Descrição da Alteração: Inserido tratamento para geração  	|
	| de grupos e tags não obrigatórias; Os Grupos filhos foram	|
	| criados antes de seus pais para possibilitar a verificação	|
	| de existência dos mesmos e para permitir a inclusão na 		|
	| função xTafTagGroup responsavel por montar o grupo, seus	|
	| filhos e gerenciar a impressão ou não dos grupos/tags.		|
	+------------------------------------------------------------+*/
	If cLayout != "2206"
		cXml +=	"<infoRegimeTrab>"
	EndIf

	If cLayout == "2200"

		//Monta a tag infoCeletista (de baixo para cima) respeitando a obrigatoriedade dos grupos
		T3L->(dbSetOrder(3))
		If T3L->( MsSeek( xFilial( "T3L" ) + ('C9V')->( &( "C9V_ID") + &( "C9V_VERSAO" )+ &( "C9V_NOMEVE" ) ) ) )
			While T3L->(!Eof()) .And. T3L->( T3L_FILIAL + T3L_ID + T3L_VERSAO) == xFilial( "T3L" ) + ("C9V")->( &( "C9V_ID" ) + &( "C9V_VERSAO" ) )
				If !Empty(T3L->T3L_CPF)
					cXmlTrabS +=	"<ideTrabSubstituido>"
					cXmlTrabS +=		xTafTag("cpfTrabSubst",T3L->T3L_CPF)
					cXmlTrabS +=	"</ideTrabSubstituido>"
				EndIf
				T3L->(DBSkip())
			EndDo
		EndIf

		If !lLaySimplif

			xTafTagGroup("ideEstabVinc"		,{{"tpInsc"				,(cAlias)->&( cAlias + "_TPINTT"),,.F.};
				, {"nrInsc"				,(cAlias)->&( cAlias + "_NRINTT"),,.F.}};
				, @cXmlEstbV)

			xTafTagGroup("aprend"			,{{"tpInsc"				,(cAlias)->&( cAlias + "_TPINAP"),,.F.};
				, {"nrInsc"				,(cAlias)->&( cAlias + "_NRINAP"),,.F.}};
				, @cXmlApren)

			xTafTagGroup("ideTomadorServ"	,{{"tpInsc"				,(cAlias)->&( cAlias + "_TPINST"),,.F.};
				, {"nrInsc"				,(cAlias)->&( cAlias + "_NRINST"),,.F.}};
				, @cXmlTomSrv,{{"ideEstabVinc",cXmlEstbV,0}})

			xTafTagGroup("trabTemporario"	,{{"hipLeg"				,(cAlias)->&( cAlias + "_MOTCON"),,.F.};
				, {"justContr"			,(cAlias)->&( cAlias + "_JUSHIP"),,.F.};
				, {"tpInclContr"			,(cAlias)->&( cAlias + "_TPINCL"),,.T.}};
				, @cXmlTrabT,{{"ideTomadorServ",cXmlTomSrv,1}, {"ideTrabSubstituido",cXmlTrabS,0} })

			xTafTagGroup("FGTS"				,{{"opcFGTS"				,(cAlias)->&( cAlias + "_FGTSOP"),,.F.};
				, {"dtOpcFGTS"			,(cAlias)->&( cAlias + "_DTFGTS"),,.T.}};
				, @cXmlFGTS)

			xTafTagGroup("infoCeletista"	,{{"dtAdm"					,(cAlias)->&( cAlias + "_DTADMI"),,.F.};
				, {"tpAdmissao"			,(cAlias)->&( cAlias + "_TPADMI"),,.F.};
				, {"indAdmissao"			,(cAlias)->&( cAlias + "_INDADM"),,.F.};
				, {"tpRegJor"				,(cAlias)->&( cAlias + "_TPREGJ"),,.F.};
				, {"natAtividade"			,(cAlias)->&( cAlias + "_NATATV"),,.F.};
				, {"dtBase"				,(cAlias)->&( cAlias + "_DATAB" ),,.T.};
				, {"cnpjSindCategProf"	,(cAlias)->&( cAlias + "_CNPJCP"),,.F.}};
				, @cXmlCelet,{	{"FGTS",cXmlFGTS,IIF(.T.,0,1)},{"trabTemporario",cXmlTrabT,0},{"aprend",cXmlApren,0} })

		Else

			xTafTagGroup("ideEstabVinc";		
				,{{"tpInsc"				,(cAlias)->&( cAlias + "_TPINTT")				,,.F.};
				, {"nrInsc"				,Substr((cAlias)->&( cAlias + "_NRINTT"),1,14)	,,.F.}};
				, @cXmlEstbV;
				,, .T.)

			xTafTagGroup("aprend"			,{{"tpInsc"				,(cAlias)->&( cAlias + "_TPINAP"),,.F.};
											, {"nrInsc"				,Substr((cAlias)->&( cAlias + "_NRINAP"),1,14),,.F.}};
											, @cXmlApren)

			xTafTagGroup("trabTemporario";
				,{{"hipLeg"				,(cAlias)->&( cAlias + "_MOTCON"),,.F.};
				, {"justContr"			,(cAlias)->&( cAlias + "_JUSHIP"),,.F.}};
				, @cXmlTrabT;
				,{{"ideEstabVinc"		,cXmlEstbV ,1 };
				, {"ideTrabSubstituido"	,cXmlTrabS ,0 }};
				, .F. )
		
			xTafTagGroup("FGTS"				,{{"dtOpcFGTS"			,(cAlias)->&( cAlias + "_DTFGTS"),,.T.}};
												, @cXmlFGTS)

			If (cAlias)->&( cAlias + "_TPREGT" ) == "1"
				xTafTagGroup("infoCeletista"	,{{"dtAdm"					,(cAlias)->&( cAlias + "_DTADMI"),,.F.};
													, {"tpAdmissao"			,(cAlias)->&( cAlias + "_TPADMI"),,.F.};
													, {"indAdmissao"		,(cAlias)->&( cAlias + "_INDADM"),,.F.};
													, {"nrProcTrab"			,IIF((cAlias)->&( cAlias + "_INDADM") == "3" ,(cAlias)->&( cAlias + "_NRPROC") ,""),,.T.};
													, {"tpRegJor"			,(cAlias)->&( cAlias + "_TPREGJ"),,.F.};
													, {"natAtividade"		,(cAlias)->&( cAlias + "_NATATV"),,.F.};
													, {"dtBase"				,(cAlias)->&( cAlias + "_DATAB" ),,.T.};
													, {"cnpjSindCategProf"	,(cAlias)->&( cAlias + "_CNPJCP"),,.F.}};
													, @cXmlCelet,{	{"FGTS",cXmlFGTS,IIF(.T.,0,1)},{"trabTemporario",cXmlTrabT,0},{"aprend",cXmlApren,0} })
			EndIf									
		
		EndIf

	ElseIf cLayout == "2206"
		xTafTagGroup("aprend"	, {	{"tpInsc", (cAlias)->&(cAlias + "_TPINAP"),, .F.};
								, 	{"nrInsc", (cAlias)->&(cAlias + "_NRINAP"),, .F.}};
								, @cXmlApren)

		If !lLaySimplif
			xTafTagGroup("trabTemp"			,{{"justProrr"			,(cAlias)->&( cAlias + "_JUSTPR"),,.F.}};
				, @cXmlTrabT)
			cTagtrabTm := "trabTemp"
		Else
			cTagtrabTm := "trabTemporario"
			
			xTafTagGroup(cTagtrabTm	, {{"justProrr", (cAlias)->&(cAlias + "_JUSTPR"),, .F.}};
									, @cXmlTrabT)
		EndIf

		xTafTagGroup("infoCeletista", {	{"tpRegJor"				, (cAlias)->&(cAlias + "_TPREGJ"),, .F.};
									, 	{"natAtividade"			, (cAlias)->&(cAlias + "_NATATV"),, .F.};
									, 	{"dtBase"				, (cAlias)->&(cAlias + "_DATAB" ),, .T.};
									, 	{"cnpjSindCategProf"	, (cAlias)->&(cAlias + "_CNPJCP"),, .F.}};
									, @cXmlCelet, {	{cTagtrabTm	, cXmlTrabT, 0};
												,	{"aprend"	, cXmlApren, 0}},, .T.)
		
		If !lLaySimplif
			xTafTagGroup("infoEstatutario", {{"tpPlanRP", (cAlias)->&(cAlias + "_TPLASM"),, .F.}}, @cInfoEstat)
		Else
			xTafTagGroup("infoEstatutario"	, {	{"tpPlanRP"		, (cAlias)->&(cAlias + "_TPLASM"),, .F.};
											, 	{"indTetoRGPS"	, (cAlias)->&(cAlias + "_TERGPS"),, .F.};
											, 	{"indAbonoPerm"	, (cAlias)->&(cAlias + "_ABOPER"),, .F.}};
											, @cInfoEstat)
		EndIf
		
		xTafTagGroup("infoRegimeTrab",, @cInfRegTra	, {	{"infoCeletista"	, cXmlCelet	, 0};
													,	{"infoEstatutario"	, cInfoEstat, 0}}, IIf(lLaySimplif, .F., .T.), .T.)
	Else

		If !Empty((cAlias)->&(cAlias + "_JUSTPR"))
			cXmlTrabT :=	"<trabTemp>"
			cXmlTrabT +=		xTafTag("justProrr",(cAlias)->&( cAlias + "_JUSTPR" ) )
			cXmlTrabT +=	"</trabTemp>"
		EndIf

		xTafTagGroup("infoCeletista"	,{{"tpRegJor"				,(cAlias)->&(cAlias + "_TPREGJ"),,.F.};
			, {"natAtividade"			,(cAlias)->&(cAlias + "_NATATV"),,.F.};
			, {"dtBase"				,(cAlias)->&(cAlias + "_DATAB" ),,.T.};
			, {"cnpjSindCategProf"	,(cAlias)->&(cAlias + "_CNPJCP"),,.F.}};
			, @cXmlCelet,{{"trabTemporario",cXmlTrabT,0}})

	EndIf

	cXml += IIf(cLayout == "2206", cInfRegTra, cXmlCelet)

	If cLayout == "2200"
		If !lLaySimplif	
			If !Empty((cAlias)->&( cAlias + "_NPROJE" ))
				cXmlProcJ := "<infoDecJud>"
				cXmlProcJ += 	xTafTag("nrProcJud",Posicione("C1G",8,xFilial("C1G") + (cAlias)->&( cAlias + "_NPROJE" ),"C1G_NUMPRO"))
				cXmlProcJ += "</infoDecJud>"
			EndIf

			xTafTagGroup("infoEstatutario"	,{{"indProvim"			,(cAlias)->&( cAlias + "_INDPRO"),,.F.};
											, {"tpProv"				,(cAlias)->&( cAlias + "_TIPPRO"),,.F.};
											, {"dtNomeacao"			,(cAlias)->&( cAlias + "_DTNOME"),,.F.};
											, {"dtPosse"			,(cAlias)->&( cAlias + "_DTPOSS"),,.F.};
											, {"dtExercicio"		,(cAlias)->&( cAlias + "_DTEXER"),,.F.};
											, {"tpPlanRP"			,(cAlias)->&( cAlias + "_TPLASM"),,.T.}};
											, @cXml, {{"infoDecJud"	,cXmlProcJ, 1}}, .F., .T.) 
		Else
			xTafTagGroup("infoEstatutario"	,{{"tpProv"					,(cAlias)->&( cAlias + "_TIPPRO"),,.F.};
											, {"dtExercicio"			,(cAlias)->&( cAlias + "_DTEXER"),,.F.};
											, {"tpPlanRP"				,(cAlias)->&( cAlias + "_TPLASM"),,.T.};
											, {"indTetoRGPS"			,(cAlias)->&( cAlias + "_TERGPS"),,.T.};
											, {"indAbonoPerm"			,(cAlias)->&( cAlias + "_ABOPER"),,.T.};
											, {"dtIniAbono"				,(cAlias)->&( cAlias + "_DTABON"),,.T.}};
											, @cXml) 											
		EndIf
	EndIf

	If cLayout != "2206"
		cXml += "</infoRegimeTrab>"
	EndIf
	
	//Inicio <infoContrato>
	If C07->( MsSeek(xFilial("C07") + (cAlias)->&(cAlias + "_CMUNTD")))
		If C09->(MsSeek(xFilial("C09") + C07->C07_UF))
			cCodUF	 := C09->C09_UF
			cCodMun := C09->C09_CODIGO + C07->C07_CODIGO
		Else
			cCodMun := C07->C07_CODIGO
		EndIf
	Else
		If 	Empty((cAlias)->&( cAlias + "_CMUNTD" ))
			cCodMun := (cAlias)->&(cAlias + "_CMUNTD")
		EndIf
		If 	Empty((cAlias)->&( cAlias + "_UFTRBD" ))
			cCodUF := Posicione("C09",3,xFilial("C09")+(cAlias)->&( cAlias + "_UFTRBD" ),"C09_UF")
		EndIf
	EndIf

	If !lLaySimplif
		xTafTagGroup("remuneracao";			
			,{{"vrSalFx"	,(cAlias)->&( cAlias + "_VLSLFX"),PesqPict( cAlias, cAlias + "_VLSLFX" ),.F.,,.T.};
			, {"undSalFixo"	,(cAlias)->&( cAlias + "_UNSLFX"),,.F.};
			, {"dscSalVar"	,(cAlias)->&( cAlias + "_DESSVR"),,.T.}};
			, @cXmlRemun)
	Else
		xTafTagGroup("remuneracao";
			,{{"vrSalFx"	,(cAlias)->&( cAlias + "_VLSLFX"),PesqPict( cAlias, cAlias + "_VLSLFX" ),.F.,,.T.};
			, {"undSalFixo"	,(cAlias)->&( cAlias + "_UNSLFX"),,.F.};
			, {"dscSalVar"	,(cAlias)->&( cAlias + "_DSCSAL"),,.T.}};
			, @cXmlRemun)
	EndIf

	If cLayout == "2200"

		If TafColumnPos("CUP_OBJDET")
			xTafTagGroup("duracao";
				,{{"tpContr"	,(cAlias)->&( cAlias + "_TPCONT" ),,.F.};
				, {"dtTerm"		,(cAlias)->&( cAlias + "_DTTERM" ),,.T.};
				, {"clauAssec"	,xFunTrcSN((cAlias)->&( cAlias + "_CLAUAS" ), 1),,.T.};
				, {"objDet"		,(cAlias)->&( cAlias + "_OBJDET"),,.T.}};
				, @cXmlDuracao)
		Else
			xTafTagGroup("duracao";
				,{{"tpContr"	,(cAlias)->&( cAlias + "_TPCONT" ),,.F.};
				, {"dtTerm"		,(cAlias)->&( cAlias + "_DTTERM" ),,.T.};
				, {"clauAssec"	,xFunTrcSN((cAlias)->&( cAlias + "_CLAUAS" ), 1),,.T.}};
				, @cXmlDuracao)
		EndIf

	ElseIf cLayout == "2206"

		If TafColumnPos("T1V_OBJDET")

			xTafTagGroup("duracao";
				,{{"tpContr"	,(cAlias)->&( cAlias + "_TPCONT" ),,.F.};
				, {"dtTerm"		,(cAlias)->&( cAlias + "_DTTERM" ),,.T.};
				, {"objDet"		,(cAlias)->&( cAlias + "_OBJDET"),,.T.}};
				, @cXmlDuracao)
		Else

			xTafTagGroup("duracao";
				,{{"tpContr"	,(cAlias)->&( cAlias + "_TPCONT" ),,.F.};
				, {"dtTerm"		,(cAlias)->&( cAlias + "_DTTERM" ),,.T.}};
				, @cXmlDuracao)

		EndIf

	EndIf

	xTafTagGroup("localTrabGeral";	
		,{{"tpInsc"		,(cAlias)->&( cAlias + "_TPINSC")				,,.F.};
		, {"nrInsc"		,(cAlias)->&( cAlias + "_NRINSC")				,,.F.};
		, {"descComp"	,FwCutOff((cAlias)->&( cAlias + "_DESLOT"), .T.),,.T.}};
		, @cXmlLocTG;
		,,.F.)

	If !lLaySimplif
		xTafTagGroup("localTrabDom"		,{{"tpLograd"	,Posicione("C06",3,xFilial("C06")+(cAlias)->&( cAlias + "_TPLOGD" ),"C06_CESOCI"),,.T.};
			, {"dscLograd"	,FwCutOff((cAlias)->&( cAlias + "_DELOGD" ), .T.)	,,.F.};
			, {"nrLograd"	,(cAlias)->&( cAlias + "_NRLOGD" )	,,.F.};
			, {"complemento",FwCutOff((cAlias)->&( cAlias + "_COMLGD" ), .T.)	,,.T.};
			, {"bairro"		,FwCutOff((cAlias)->&( cAlias + "_BAIRTD" ), .T.)	,,.T.};
			, {"cep"		,(cAlias)->&( cAlias + "_CEPLTD" )	,,.F.};
			, {"codMunic"	,cCodMun							,,.F.};
			, {"uf"			,cCodUF								,,.F.}};
			, @cXmlLocTD)
	Else
		xTafTagGroup("localTempDom"		,{{"tpLograd"	,Posicione("C06",3,xFilial("C06")+(cAlias)->&( cAlias + "_TPLOGD" ),"C06_CESOCI"),,.T.};
			, {"dscLograd"	,FwCutOff((cAlias)->&( cAlias + "_DELOGD" ), .T.)	,,.F.};
			, {"nrLograd"	,(cAlias)->&( cAlias + "_NRLOGD" )	,,.F.};
			, {"complemento",FwCutOff((cAlias)->&( cAlias + "_COMLGD" ), .T.)	,,.T.};
			, {"bairro"		,FwCutOff((cAlias)->&( cAlias + "_BAIRTD" ), .T.)	,,.T.};
			, {"cep"		,(cAlias)->&( cAlias + "_CEPLTD" )	,,.F.};
			, {"codMunic"	,cCodMun							,,.F.};
			, {"uf"			,cCodUF								,,.F.}};
			, @cXmlLocTD)
	EndIf

	If !Empty(cXmlLocTG+cXmlLocTD)
		cXmlLocTrab := "<localTrabalho>"
		cXmlLocTrab += cXmlLocTG
		cXmlLocTrab += cXmlLocTD
		cXmlLocTrab += "</localTrabalho>"
	EndIf

	If !lLaySimplif
		( cAliasHora )->(dbSetOrder(1))
		If (cAliasHora)->( MsSeek( xFilial( cAliasHora ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")  ) )
			While (cAliasHora)->(!Eof()) .And. (cAliasHora)->( &( cAliasHora + "_FILIAL" ) + &( cAliasHora + "_ID" ) + &( cAliasHora + "_VERSAO" ) ) == xFilial( "C9V" ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")
				cXmlHorar +=	"<horario>"
				cXmlHorar +=	xTafTag("dia",(cAliasHora)->&( cAliasHora + "_CODDIA" ))
				If C90->( MsSeek( xFilial( "C90" ) + (cAliasHora)->&( cAliasHora + "_CODHOR" ) + '1'))
					cXmlHorar +=	xTafTag("codHorContrat",C90->C90_CODIGO)
				EndIf
				cXmlHorar +=		"</horario>"
				(cAliasHora)->(DBSkip())
			EndDo
		EndIf

		xTafTagGroup( "horContratual"	, {	{ "qtdHrsSem",( cAlias )->&( cAlias + "_QTDHJS" ),"99.99", .T. };
			,	{ "tpJornada",( cAlias )->&( cAlias + "_TPJORN" ),, .F. };
			,	{ "dscTpJorn", FWCutOff( ( cAlias )->&( cAlias + "_DTPJOR" ), .T. ),, .T. };
			,	{ "tmpParc", ( cAlias )->&( cAlias + "_TMPARC" ),, .F. } };
			, @cXmlHrCont, { { "horContratual", cXmlHorar, 1 } } )
	Else
		xTafTagGroup( "horContratual";
			, {	{ "qtdHrsSem"	,( cAlias )->&( cAlias + "_QTDHJS" ),"99.99", .T. };
			,	{ "tpJornada"	,( cAlias )->&( cAlias + "_TPJORN" ),		, .F. };
			,	{ "tmpParc"		,( cAlias )->&( cAlias + "_TMPARC" ),		, .F. };
			,	{ "horNoturno"	,( cAlias )->&( cAlias + "_HRSNOT" ),		, .T. };
			,	{ "dscJorn"		,( cAlias )->&( cAlias + "_DSCJOR" ),		, .F. }};
			, @cXmlHrCont )
	EndIf

	If !lLaySimplif
		( cAliasSind )->(dbSetOrder(1))
		If (cAliasSind)->( MsSeek( xFilial( cAliasSind ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")  ) )
			While (cAliasSind)->(!Eof()) .And. (cAliasSind)->( &( cAliasSind + "_FILIAL" ) + &( cAliasSind + "_ID" ) + &( cAliasSind + "_VERSAO" ) ) == xFilial( "C9V" ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")
				If !Empty((cAliasSind)->&( cAliasSind + "_CNPJSD" ))
					cXmlFSind +=	"<filiacaoSindical>"
					cXmlFSind +=		xTafTag("cnpjSindTrab",(cAliasSind)->&( cAliasSind + "_CNPJSD" ))
					cXmlFSind +=	"</filiacaoSindical>"
				Endif
				(cAliasSind)->(DBSkip())
			EndDo
		EndIf
	EndIf

	( cAliasObs )->(dbSetOrder(1))
	If (cAliasObs)->( MsSeek( xFilial( cAliasObs ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")  ) )
		While (cAliasObs)->(!Eof()) .And. (cAliasObs)->( &( cAliasObs + "_FILIAL" ) + &( cAliasObs + "_ID" ) + &( cAliasObs + "_VERSAO" ) ) == xFilial( "C9V" ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")
			If !Empty((cAliasObs)->&( cAliasObs + "_OBSERV" ))
				cXmlObs +=	"<observacoes>"
				cXmlObs +=		xTafTag("observacao",(cAliasObs)->&( cAliasObs + "_OBSERV" ))
				cXmlObs +=	"</observacoes>"
			EndIf
			(cAliasObs)->(DBSkip())
		EndDo

	EndIf

	If !Empty((cAlias)->&( cAlias + "_ALVJUD" ))
		cXmlAlvJud +=			"<alvaraJudicial>"
		cXmlAlvJud +=				xTafTag("nrProcJud",Posicione("C1G",8,xFilial("C1G") + (cAlias)->&( cAlias + "_ALVJUD" ),"C1G_NUMPRO"))
		cXmlAlvJud +=			"</alvaraJudicial>"
	Endif

	If cLayout == "2206" .AND. !lLaySimplif

		If !Empty((cAlias)->&(cAlias + "_MTVALT"))
			cXmlSrvPub := "<servPubl>"
			cXmlSrvPub += 	xTafTag("mtvAlter",(cAlias)->&(cAlias + "_MTVALT"))
			cXmlSrvPub += "</servPubl>"
		EndIf

	EndIf

	If !lLaySimplif

		xTafTagGroup("infoContrato";
			,{{"codCargo"    ,Posicione("C8V",1,xFilial("C8V") + (cAlias)->&( cAlias + "_CODCGO" ),"C8V_CODIGO")	,,.T.};
			, {"codFuncao"	 ,Posicione("C8X",1,xFilial("C8X") + (cAlias)->&( cAlias + "_CODFUN" ),"C8X_CODIGO")	,,.T.};
			, {"codCateg"	 ,Posicione("C87",1,xFilial("C87") + (cAlias)->&( cAlias + "_CODCAT" ),"C87_CODIGO")	,,.F.};
			, {"codCarreira" ,Posicione("T5K",1,xFilial("T5K") + (cAlias)->&( cAlias + "_CODCAR" ),"T5K_CODIGO")	,,.T.};
			, {"dtIngrCarr"	 ,(cAlias)->&(cAlias + "_DTINGC")														,,.T.}};
			, @cXml;
			,{{"remuneracao"		,cXmlRemun	,1};
			, {"duracao"			,cXmlDuracao,1};
			, {"localTrabalho"		,cXmlLocTrab,1};
			, {"horContratual"		,cXmlHrCont	,0};
			, {"filiacaoSindical"	,cXmlFSind	,0};
			, {"alvaraJudicial"		,cXmlAlvJud	,0};
			, {"observacoes"		,cXmlObs	,0};
			, {"servPubl"			,cXmlSrvPub	,0}})
	
	Else
		If TAFAlsInDic( cAliasCap )
			( cAliasCap )->(dbSetOrder(1))
			If (cAliasCap)->( MsSeek( xFilial( cAliasCap ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")  ) )
				While (cAliasCap)->(!Eof()) .And. (cAliasCap)->( &( cAliasCap + "_FILIAL" ) + &( cAliasCap + "_ID" ) + &( cAliasCap + "_VERSAO" ) ) == xFilial( "C9V" ) + (cAlias)->&( cAlias + "_ID") + (cAlias)->&(cAlias + "_VERSAO")
					xTafTagGroup("treiCap"	, {{"codTreiCap", AllTrim(Posicione("V2M", 1, xFilial("V2M") + (cAliasCap)->&(cAliasCap + "_CODTRE"), "V2M_CODIGO")),, .T. }};
											,  @cXmlTreiCap,, .F.)
					(cAliasCap)->(DBSkip())
				EndDo
			ElseIf !Empty(cAlias + "_CODTRE")				
				xTafTagGroup("treiCap"	, {{"codTreiCap", AllTrim(Posicione("V2M", 1, xFilial("V2M") + (cAlias)->&(cAlias + "_CODTRE"), "V2M_CODIGO")),, .T. }};
										,  @cXmlTreiCap,, .F.)				
			EndIf
		Else
			If TafColumnPos(cAlias + "_CODTRE")
				xTafTagGroup("treiCap"	, {{"codTreiCap", AllTrim(Posicione("V2M", 1, xFilial("V2M") + (cAlias)->&(cAlias + "_CODTRE"), "V2M_CODIGO")),, .T. }};
										,  @cXmlTreiCap,, .F.)
			EndIf
		EndIf

		If cLayout == "2200"
			xTafTagGroup("infoContrato";
				,{{"nmCargo"	,(cAlias)->&( cAlias + "_NMCARG" )													,,.T.};
				,{"CBOCargo"	,Posicione("C8Z",1,xFilial("C8Z")+(cAlias)->&( cAlias + "_CBOCAR" ),"C8Z_CODIGO")	,,.T.};
				,{"dtIngrCargo"	,(cAlias)->&( cAlias + "_DTINCA")													,,.T.};
				,{"nmFuncao"	,(cAlias)->&( cAlias + "_NMFUNC" )													,,.T.};
				,{"CBOFuncao"	,Posicione("C8Z",1,xFilial("C8Z")+(cAlias)->&( cAlias + "_CBOFUN" ),"C8Z_CODIGO")	,,.T.};
				,{"acumCargo"	,(cAlias)->&( cAlias + "_ACCARG" )													,,.T.};
				,{"codCateg"	,Posicione("C87",1,xFilial("C87") + (cAlias)->&( cAlias + "_CODCAT" ),"C87_CODIGO")	,,.F.}};
				,@cXml;
				,{{"remuneracao"	,cXmlRemun	,0};
				, {"duracao"		,cXmlDuracao,0};
				, {"localTrabalho"	,cXmlLocTrab,0};
				, {"horContratual"	,cXmlHrCont	,0};
				, {"alvaraJudicial"	,cXmlAlvJud	,0};
				, {"observacoes"	,cXmlObs	,0};
				, {"treiCap"		,cXmlTreiCap,0}})
		Else
			xTafTagGroup("infoContrato";	
				,{{"nmCargo"	,(cAlias)->&( cAlias + "_NMCARG" )													,,.T.};
				,{"CBOCargo"	,Posicione("C8Z",1,xFilial("C8Z")+(cAlias)->&( cAlias + "_CBOCAR" ),"C8Z_CODIGO")	,,.T.};
				,{"nmFuncao"	,(cAlias)->&( cAlias + "_NMFUNC" )													,,.T.};
				,{"CBOFuncao"	,Posicione("C8Z",1,xFilial("C8Z")+(cAlias)->&( cAlias + "_CBOFUN" ),"C8Z_CODIGO")	,,.T.};
				,{"acumCargo"	,(cAlias)->&( cAlias + "_ACCARG" )													,,.T.};
				,{"codCateg"	,Posicione("C87",1,xFilial("C87") + (cAlias)->&( cAlias + "_CODCAT" ),"C87_CODIGO")	,,.F.}};
				,@cXml;
				,{{"remuneracao"	,cXmlRemun	,0};
				, {"duracao"		,cXmlDuracao,0};
				, {"localTrabalho"	,cXmlLocTrab,1};
				, {"horContratual"	,cXmlHrCont	,0};
				, {"alvaraJudicial"	,cXmlAlvJud	,0};
				, {"observacoes"	,cXmlObs	,0};
				, {"treiCap"		,cXmlTreiCap,0}})
		EndIf	
			
	EndIf

	//fim <infoContrato>

	If lLaySimplif .And. cLayout == "2206"
		cXml +=	"</vinculo>"
	EndIf

	If cLayout == "2200"

		If !Empty((cAlias)->&( cAlias + "_INSANT" )) .Or. !Empty((cAlias)->&( cAlias + "_CNPJEA" )) .Or. !Empty((cAlias)->&( cAlias + "_DTINVI" ))

			cXml +=			"<sucessaoVinc>"

			If !lLaySimplif
				cXml +=				xTafTag("tpInscAnt"		,(cAlias)->&( cAlias + "_INSANT" )) 
				cXml +=				xTafTag("cnpjEmpregAnt"	,(cAlias)->&( cAlias + "_CNPJEA" ))				
			Else
				cXml +=				xTafTag("tpInsc"	,(cAlias)->&( cAlias + "_INSANT" )) 		
				cXml +=				xTafTag("nrInsc"	,(cAlias)->&( cAlias + "_CNPJEA" )) 
			EndIf

			cXml +=				xTafTag("matricAnt"		,(cAlias)->&( cAlias + "_MATANT" ),,.T.)
			cXml +=				xTafTag("dtTransf"		,(cAlias)->&( cAlias + "_DTINVI" ))
			cXml +=				xTafTag("observacao"	,(cAlias)->&( cAlias + "_OBSVIN" ),,.T. )
			cXml +=			"</sucessaoVinc>"

		EndIf

	EndIf

	If cLayout == "2200" .And. !lLaySimplif

		xTafTagGroup("transfDom"	,{{"cpfSubstituido"	,(cAlias)->&( cAlias + "_CPFSUB")															,,.F.};
			, {"matricAnt",(cAlias)->&( cAlias + "_MATRAN")																,,.F.};
			, {"dtTransf",(cAlias)->&( cAlias + "_DTTRAN")																,,.F.}};
			, @cXml)

		If TafColumnPos("CUP_CPFANT") .And. TafColumnPos("CUP_MATOLD") .And. TafColumnPos("CUP_DATCPF") .And. TafColumnPos("CUP_OBSCPF")
			xTafTagGroup("mudancaCPF"   ,{;
				{"cpfAnt"	    ,(cAlias)->&( cAlias + "_CPFANT")														,,.F.},;
				{"matricAnt"    ,(cAlias)->&( cAlias + "_MATOLD")														,,.F.},;
				{"dtAltCPF"     ,(cAlias)->&( cAlias + "_DATCPF")														,,.F.},;
				{"observacao"   ,(cAlias)->&( cAlias + "_OBSCPF")														,,.T.}};
				, @cXml)
		EndIf

		xTafTagGroup("afastamento"	,{{"dtIniAfast"	,(cAlias)->&( cAlias + "_DTINIA")																,,.F.};
			, {"codMotAfast",Posicione("C8N",1,xFilial("C8N") + ( cAlias )->&( cAlias + "_MOTVAF" ),"C8N_CODIGO")		,,.F.}};
			, @cXml)

		xTafTagGroup("desligamento"	,{{"dtDeslig"	,(cAlias)->&( cAlias + "_DTDESL")															,,.F.}};
			, @cXml)

	ElseIf  cLayout == "2200" .And. lLaySimplif 
		
		
		xTafTagGroup("transfDom"	,{{"cpfSubstituido"	,(cAlias)->&( cAlias + "_CPFSUB")															,,.F.};
										, {"matricAnt",(cAlias)->&( cAlias + "_MATRAN")																,,.F.};
										, {"dtTransf",(cAlias)->&( cAlias + "_DTTRAN")																,,.F.}};
										, @cXml)

		If TafColumnPos("CUP_CPFANT") .And. TafColumnPos("CUP_MATOLD") .And. TafColumnPos("CUP_DATCPF") .And. TafColumnPos("CUP_OBSCPF")
			xTafTagGroup("mudancaCPF"   ,{;
				{"cpfAnt"	    ,(cAlias)->&( cAlias + "_CPFANT")														,,.F.},;
				{"matricAnt"    ,(cAlias)->&( cAlias + "_MATOLD")														,,.F.},;
				{"dtAltCPF"     ,(cAlias)->&( cAlias + "_DATCPF")														,,.F.},;
				{"observacao"   ,(cAlias)->&( cAlias + "_OBSCPF")														,,.T.}};
				, @cXml)
		EndIf
		
		xTafTagGroup("afastamento"	,{{"dtIniAfast"	,(cAlias)->&( cAlias + "_DTINIA")																,,.F.};
										, {"codMotAfast",Posicione("C8N",1,xFilial("C8N") + ( cAlias )->&( cAlias + "_MOTVAF" ),"C8N_CODIGO")		,,.F.}};
										, @cXml)

		xTafTagGroup("desligamento"	,{{"dtDeslig"	,(cAlias)->&( cAlias + "_DTDESL")															,,.F.}};
										, @cXml)
		
		xTafTagGroup("cessao"	,{{"dtIniCessao"	,(cAlias)->&( cAlias + "_DCESSA")															,,.F.}};
										, @cXml)


	EndIf

	If cLayout == "2206"
		cXml += "</altContratual>"
	Else
		cXml +=	"</vinculo>"
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc  )

	Local cProtocolo 	:= ""
	Local cVersao    	:= ""
	Local cEvento		:= ""

	Local nI         	:= 0

	Local aGrava     	:= {}
	Local aGravaCUP  	:= {}
	Local aGravaT2E  	:= {}
	Local aGravaCRQ  	:= {}
	Local aGravaT3L  	:= {}
	Local aGravaT80  	:= {}
	Local aGravaT90  	:= {}

	Local oModelC9V  	:= Nil
	Local oModelT2E  	:= Nil
	Local oModelCUP  	:= Nil
	Local oModelCRQ  	:= Nil
	Local oModelT3L  	:= Nil
	Local oModelT80  	:= Nil
	Local oModelT90  	:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("C9V")->( DBGoTo( nRecno ) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelC9V := oModel:GetModel( "MODEL_C9V" )
		oModelCUP := oModel:GetModel( "MODEL_CUP" )
		oModelT2E := oModel:GetModel( "MODEL_T2E" )
		oModelCRQ := oModel:GetModel( "MODEL_CRQ" )
		oModelT3L := oModel:GetModel( "MODEL_T3L" )
		oModelT80 := oModel:GetModel( "MODEL_T80" )
		oModelT90 := oModel:GetModel( "MODEL_T90" )

		//Guardo as informações do registro corrente para rastro do registro
		cVerAnt  	:= oModelC9V:GetValue( "C9V_VERSAO" )
		cProtocolo	:= oModelC9V:GetValue( "C9V_PROTUL" )
		cEvento	:= oModelC9V:GetValue( "C9V_EVENTO" )

		//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )

		//******************
		//Dados do Trabalhador
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
		For nI := 1 to oModel:GetModel( "MODEL_T2E" ):Length()
			oModel:GetModel( "MODEL_T2E" ):GoLine(nI)
			If !oModel:GetModel( 'MODEL_T2E' ):IsEmpty()
				If !oModel:GetModel( "MODEL_T2E" ):IsDeleted()
					aAdd(aGravaT2E,{oModelT2E:GetValue("T2E_IDDEP"),;
						oModelT2E:GetValue("T2E_TPDEP") ,;
						oModelT2E:GetValue("T2E_NOMDEP"),;
						oModelT2E:GetValue("T2E_DTNASC"),;
						oModelT2E:GetValue("T2E_CPFDEP"),;
						oModelT2E:GetValue("T2E_DEPIRF"),;
						oModelT2E:GetValue("T2E_DEPSFA"),;
						oModelT2E:GetValue("T2E_INCTRB")})
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

		//******************************
		//InfoContrato/filiacaoSindical
		//******************************
		For nI := 1 to oModel:GetModel( "MODEL_T80" ):Length()
			oModel:GetModel( "MODEL_T80" ):GoLine(nI)
			If !oModel:GetModel( "MODEL_T80" ):IsDeleted()
				aAdd(aGravaT80,{oModelT80:GetValue("T80_CNPJSD")})
			EndIf
		Next nI

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

		/*----------------------------------------------------------
		Seto o campo como Inativo e gravo a versao do novo registro
		no registro anterior

		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		FAltRegAnt( "C9V", "2" )

		/*----------------------------------------------------------
		Apos deixar o registro corrente como inativo eu seto a
		operação de inclusão para o novo registro
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
		For nI := 1 to Len( aGravaT2E )
			If nI > 1
				oModel:GetModel( "MODEL_T2E" ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_T2E", "T2E_IDDEP" , aGravaT2E[nI][1] )
			oModel:LoadValue( "MODEL_T2E", "T2E_TPDEP" , aGravaT2E[nI][2] )
			oModel:LoadValue( "MODEL_T2E", "T2E_NOMDEP", aGravaT2E[nI][3] )
			oModel:LoadValue( "MODEL_T2E", "T2E_DTNASC", aGravaT2E[nI][4] )
			oModel:LoadValue( "MODEL_T2E", "T2E_CPFDEP", aGravaT2E[nI][5] )
			oModel:LoadValue( "MODEL_T2E", "T2E_DEPIRF", aGravaT2E[nI][6] )
			oModel:LoadValue( "MODEL_T2E", "T2E_DEPSFA", aGravaT2E[nI][7] )
			oModel:LoadValue( "MODEL_T2E", "T2E_INCTRB", aGravaT2E[nI][8] )
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

		//Busco a nova versao do registro
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_C9V", "C9V_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_C9V", "C9V_PROTPN", cProtocolo )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "E" )
		oModel:LoadValue( "MODEL_C9V", "C9V_ATIVO", "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, "MODEL_C9V", "C9V" )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'C9V',"6" )

	End Transaction

Return ( .T. )

/*/{Protheus.doc} ExistAltNis
Rotina responsável por verificar se o trabalhador não sofreu
uma alteração cadastral em NIS de modo que invalide a transmissão
do S-2206 no RET.
@type  Static Function
@author Diego Santos
@since 2018-09-26
@version 1.0
@param cFilNis, Caracter, Filial C9V
@param cC9VID, 	Caracter, ID C9V
@param cC9VEV, 	Caracter, Cód Evento
@param cDtAlt, 	Caracter, Dt de Alteração
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function ExistAltNis( cFilNis, cC9VID, cC9VCpf, cC9VEV, dDtAltS2206)

	Local aArea		:= GetArea()
	Local cRet 		:= ""
	Local cQuery	:= ""
	Local cAliasQry := GetNextAlias()

	If cC9VEV == "S2200"

		cQuery := "SELECT T1U.T1U_FILIAL, T1U.T1U_ID, T1U.T1U_CPF, T1U.T1U_DTALT, T1U.T1U_NIS  "
		cQuery += " FROM " + RetSqlName("T1U") + " T1U "
		cQuery += " WHERE "
		cQuery += " T1U.T1U_FILIAL 	= '" + cFilNis 	+ "' AND "
		cQuery += " T1U.T1U_ID 		= '" + cC9VID 	+ "' AND "
		cQuery += " T1U.T1U_CPF 	= '" + cC9VCpf 	+ "' AND "
		cQuery += " T1U.T1U_STATUS  = '4' AND "
		cQuery += " T1U.T1U_PROTUL  <> '' AND "
		cQuery += " T1U.T1U_ATIVO 	= '1' AND "
		cQuery += " T1U.D_E_L_E_T_  <> '*' "

		TcQuery cQuery New Alias (cAliasQry)

		While (cAliasQry)->(!Eof())
			If dDtAltS2206 >= StoD((cAliasQry)->T1U_DTALT)
				cRet := (cAliasQry)->T1U_NIS
			EndIf
			(cAliasQry)->(DbSkip())
		End

		(cAliasQry)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return cRet

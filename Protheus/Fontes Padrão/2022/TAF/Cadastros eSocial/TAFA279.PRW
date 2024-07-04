#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA279.CH"

Static lLaySimplif := Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA279
Cadastro MVC de Trabalhadores Sem Vinculo de Emprego - Inicio

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA279()

cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local aC9VObr	:= {}
	Local aC9VNOb	:= {}
	Local aCUUNOb	:= {}
	Local bValid   	:= {||}
	Local cValid   	:= ""
	Local cC9VObr  	:= ""
	Local cC9VNOb  	:= ""
	Local cCUUNOb  	:= ""
	Local nI	   	:= 0
	Local oStruC9V 	:= FwFormStruct(1, "C9V")
	Local oStruT2F 	:= FwFormStruct(1, "T2F")
	Local oStruCUU 	:= FwFormStruct(1, "CUU")
	Local oModel   	:= MpFormModel():New("TAFA279",,, {|oModel| SaveModel(oModel)})

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 
	
	//Indica se o Model devera ser validado quando realizada operações
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("CUU_CATOME")
		oStruCUU:RemoveField("CUU_CATOME")
		oStruCUU:RemoveField("CUU_DCATOM")
		oStruCUU:RemoveField("CUU_CNPJOM")
		oStruCUU:RemoveField("CUU_MATOME")	
		oStruCUU:RemoveField("CUU_DTEXOM")	
	EndIf
	
	If lVldModel
		oStruC9V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2F:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCUU:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	//Alteração da validação dos campos da chave quando se tratar do S2300
	cValid := 'xFunVldPJF(,1,.F.) .And. XFUNVld(17)' 
	bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )
	oStruC9V:SetProperty( 'C9V_CPF', MODEL_FIELD_VALID, bValid)

	cValid := 'xFunVldCmp("C87",,,,2,.F.) .And. XFUNVld(17)'
	bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )
	oStruC9V:SetProperty( 'C9V_CATCI', MODEL_FIELD_VALID, bValid)

	cValid := 'XFUNVld(17)'
	bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )
	oStruC9V:SetProperty( 'C9V_DTINIV', MODEL_FIELD_VALID, bValid)

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruC9V:SetProperty( "C9V_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//C9V - Informacoes genericas do trabalhador
	oModel:AddFields( "MODEL_C9V", /*cOwner*/, oStruC9V )

	// Campos obrigatórios da C9V	
	cC9VObr := "C9V_NOME|C9V_SEXO|C9V_RCCOR|C9V_GRINST|C9V_DTNASC|C9V_CODPAI|C9V_PAINAC|C9V_PAIS|C9V_CATCI|C9V_DTINIV|C9V_CADINI"
			
	// Campos não obrigatórios da C9V
	cC9VNOb	:= "C9V_NIS|C9V_MATRIC|C9V_APOSEN|"

	// Campos não obrigatórios da CUU
	cCUUNOb := "CUU_DTINAV|CUU_DTERAV"

	If lLaySimplif	
		// Campos não obrigatórios da C9V
		cC9VNOb  += "C9V_NRCTPS|C9V_SERCTP|C9V_UFCTPS|C9V_DUFCTP|"
		cC9VNOb  += "C9V_NRRIC|C9V_OREMRI|C9V_DTEXRI|"
		cC9VNOb  += "C9V_NRRG|C9V_OREMRG|C9V_DTEMRG|"
		cC9VNOb  += "C9V_NRRNE|C9V_OREMRN|C9V_DTEMRN|"
		cC9VNOb  += "C9V_NUMOC|C9V_OREMOC|C9V_DTEXOC|C9V_DTVLOC|"
		cC9VNOb  += "C9V_NRCNH|C9V_DTEXCN|C9V_UFCNH|C9V_DUFCN|C9V_DTVLCN|C9V_DTPCNH|C9V_CATCNH|"
		cC9VNOb  += "C9V_CATCI|C9V_DCATCI|C9V_DTINIV|C9V_CADINI|"
	EndIf

	//Campos obrigatórios C9V
	aC9VObr := StrToKArr(cC9VObr,"|")
	For nI := 1 to Len(aC9VObr)
		oStruC9V:SetProperty(aC9VObr[nI], MODEL_FIELD_OBRIGAT , .T.)
	Next nI

	//Campos não obrigatórios C9V
	aC9VNOb := StrToKArr(cC9VNOb,"|")
	For nI := 1 to Len(aC9VNOb)
		oStruC9V:SetProperty(aC9VNOb[nI], MODEL_FIELD_OBRIGAT , .F.)
	Next nI

	//Campos não obrigatórios CUU
	aCUUNOb := StrToKArr(cCUUNOb,"|")
	For nI := 1 to Len(aCUUNOb)
		oStruCUU:SetProperty(aCUUNOb[nI], MODEL_FIELD_OBRIGAT , .F.)
	Next nI


	If ( X3Uso( Posicione( "SX3", 2, "CUU_CATAV", "X3_USADO" ) ) )
		oStruCUU:SetProperty( 'CUU_CATAV'	, MODEL_FIELD_OBRIGAT , .F.  )
	EndIf

	//CUU - Informacoes Trabalhador Sem Vinculo
	oModel:AddFields( "MODEL_CUU", "MODEL_C9V", oStruCUU )

	//T2F - Cadastro de Dependentes
	oModel:AddGrid( "MODEL_T2F", "MODEL_C9V", oStruT2F )
	oModel:GetModel( "MODEL_T2F" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T2F" ):SetUniqueLine( { "T2F_IDDEP", "T2F_NOMDEP", "T2F_DTNASC" } )

	//=====================================================================
	//Abaixo realiza-se a amarracao das tabelas, no caso deste cadastro		||
	//a tabela CUU nao eh filha da tabela C9V, porem por questoes de	  	||
	//normalizacao as informacoes foram desmembradas em duas tabelas.		||
	//====================================================================*/

	oModel:SetRelation( "MODEL_T2F", { { "T2F_FILIAL", "xFilial('T2F')" }, { "T2F_ID", "C9V_ID" }, { "T2F_VERSAO", "C9V_VERSAO" }, { "T2F_NOMEVE", "C9V_NOMEVE" } },T2F->( IndexKey( 2 ) ) )
	oModel:SetRelation( "MODEL_CUU", { { "CUU_FILIAL", "xFilial('CUU')" }, { "CUU_ID", "C9V_ID" }, { "CUU_VERSAO", "C9V_VERSAO" }, { "CUU_NOMEVE", "C9V_NOMEVE" } },CUU->( IndexKey( 1 ) ) )

	//Define a chave única de gravação das informações
	oModel:GetModel( "MODEL_C9V" ):SetPrimaryKey( { "C9V_CPF", "C9V_NOMEVE" } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( "TAFA279" )
	Local oView     := FWFormView():New()

	Local oStruC9Va := Nil
	Local oStruC9Vb := Nil
	Local oStruC9Vc := Nil
	Local oStruC9Vd := Nil
	Local oStruC9Ve := Nil
	Local oStruC9Vf := Nil

	Local oStruT2F  := FWFormStruct( 2, "T2F" )
	Local oStruCUUa := Nil
	Local oStruCUUb := Nil
	Local oStruCUUc := Nil
	Local lCmpEdit  := .F.

	Local cCmpFil    := ""

	Local cGrpTra1   := ""
	Local cGrpTra2   := ""
	Local cGrpTra3   := ""
	Local cGrpTra4   := ""
	Local cGrpTra5   := ""
	Local cGrpTra6   := ""
	Local cGrpTra7   := ""
	Local cGrpTra8   := ""
	Local cGrpTra9   := ""
	Local cGrpTra10	 := ""

	Local cCmpTSV1   := ""
	Local cCmpTSV2   := ""
	Local cCmpTSV3   := ""
	Local cCmpTSV4   := ""
	Local cCmpTSV5   := ""
	Local cCmpTSV6   := ""
	Local cCmpTSV7   := ""
	Local cCmpTSV8   := ""
	Local cCmpTSV9   := ""
	Local cCmpTSV10  := ""
	Local cCmpTSV11  := ""
	Local cCmpTSV12  := ""
	Local cCmpTSV13  := ""
	Local cCmpTSV14  := ""

	Local nI        := 0

	Local aCmpGrp   := {}

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 

	oView:SetModel( oModel )
	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/
	If !lLaySimplif

		cGrpTra1  := "C9V_ID|C9V_VERSAO|C9V_VERANT|C9V_PROTPN|C9V_EVENTO|C9V_ATIVO|C9V_CPF|C9V_NIS|C9V_NOME|C9V_SEXO|C9V_RCCOR|C9V_ESTCIV|C9V_GRINST|C9V_DGRINS|C9V_NOMSOC|"
		cGrpTra2  := "C9V_DTNASC|C9V_CODMUN|C9V_DCODMU|C9V_CODUF|C9V_DCODUF|C9V_CODPAI|C9V_DCODPA|C9V_PAINAC|C9V_DPAINA|C9V_NOMMAE|C9V_NOMPAI|"
		cGrpTra3  := "C9V_NRCTPS|C9V_SERCTP|C9V_UFCTPS|C9V_DUFCTP|"
		cGrpTra4  := "C9V_NRRIC|C9V_OREMRI|C9V_DTEXRI|"
		cGrpTra5  := "C9V_NRRG|C9V_OREMRG|C9V_DTEMRG|"
		cGrpTra6  := "C9V_NRRNE|C9V_OREMRN|C9V_DTEMRN|"
		cGrpTra7  := "C9V_NUMOC|C9V_OREMOC|C9V_DTEXOC|C9V_DTVLOC|"
		cGrpTra8  := "C9V_NRCNH|C9V_DTEXCN|C9V_UFCNH|C9V_DUFCN|C9V_DTVLCN|C9V_DTPCNH|C9V_CATCNH|"
		cGrpTra9  := "C9V_PAIS|C9V_DPAIS|C9V_UF|C9V_DUF|C9V_MUN|C9V_DMUN|C9V_NOMCID|C9V_TPLOGR|C9V_DTPLOG|C9V_LOGRAD|C9V_NRLOG|C9V_COMLOG|C9V_BAIRRO|C9V_CEP|C9V_CATCI|C9V_DCATCI|C9V_DTINIV|"
		cGrpTra10 := "C9V_CATCI|C9V_DCATCI|C9V_DTINIV|C9V_CADINI|"
		
		cCmpFil   := cGrpTra1 + cGrpTra2 + cGrpTra3 + cGrpTra4 + cGrpTra5 + cGrpTra6 + cGrpTra7 + cGrpTra8 + cGrpTra9 + cGrpTra10 

	Else

		cGrpTra1  := "C9V_ID|C9V_VERSAO|C9V_VERANT|C9V_PROTPN|C9V_EVENTO|C9V_ATIVO|C9V_CPF|C9V_NOME|C9V_SEXO|C9V_RCCOR|C9V_ESTCIV|C9V_GRINST|C9V_DGRINS|C9V_NOMSOC|"
		cGrpTra2  := "C9V_DTNASC|C9V_CODPAI|C9V_DCODPA|C9V_PAINAC|C9V_DPAINA|"
		cGrpTra9  := "C9V_PAIS|C9V_DPAIS|C9V_TPLOGR|C9V_DTPLOG|C9V_LOGRAD|C9V_NRLOG|C9V_COMLOG|C9V_BAIRRO|C9V_CEP|C9V_NOMCID|C9V_MUN|C9V_DMUN|C9V_UF|C9V_DUF|"
		cGrpTra10 := "C9V_CADINI|C9V_MATTSV|C9V_CATCI|C9V_DCATCI|C9V_DTINIV|C9V_NRPROC|C9V_NATATV|"
		cGrpTra11 := "C9V_TPRESI|C9V_CNDING|"

		cCmpFil   := cGrpTra1 + cGrpTra2 + cGrpTra9 + cGrpTra10 + cGrpTra11

	EndIf

	oStruC9Va := FwFormStruct( 2, "C9V",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes do Trabalhador

	If !lLaySimplif
		cCmpFil   := "C9V_DTCHEG|C9V_CCTRAE|C9V_DCONTE|C9V_CASBRA|C9V_FILBRA|"

		oStruC9Vb := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Trabalhador Estrangeiro

	EndIf

	cCmpFil   := "C9V_DEFINT|C9V_DEFFIS|C9V_DEFMOT|C9V_DEFVIS|C9V_DEFAUD|C9V_REABIL|C9V_DEFMEN|C9V_OBSDEF|"
	oStruC9Vc := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Deficiencias

	If !lLaySimplif
		cCmpFil   := "C9V_DDIFPR|C9V_DDDFPR|C9V_FONPRC|C9V_DDIFAL|C9V_DDDFAL|C9V_FONALT|C9V_EMAILP|C9V_EMAILA|"
	Else 
		cCmpFil   := "C9V_DDIFPR|C9V_DDDFPR|C9V_FONPRC|C9V_EMAILP|"
	EndIf 

	oStruC9Vd := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações de Contato

	cCmpFil   := "C9V_PROTUL|"
	oStruC9Ve := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial

	If TafColumnPos("C9V_DTRANS")
		cCmpFil   := "C9V_DINSIS|C9V_DTRANS|C9V_HTRANS|C9V_DTRECP|C9V_HRRECP|"
		oStruC9Vf := FwFormStruct( 2, "C9V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial
	EndIf


	/*-----------------------------------------------------------------------------------
						Grupo de campos das Informacoes Trabalhador Sem Vinculo
	-------------------------------------------------------------------------------------*/

	If !lLaySimplif	
		cCmpTSV1 := "CUU_NATATV|"
		cCmpTSV2 := "CUU_CARCI|CUU_DCARCI|CUU_FUNCI|CUU_DFUNCI|"
		cCmpTSV3 := "CUU_VLSLCI|CUU_UNSLCI|CUU_DSVRCI|"
		cCmpTSV4 := "CUU_OPFGCI|CUU_DTFGCI|"
		cCmpTSV5 := "CUU_CATDS|CUU_DCATDS|CUU_CNPJDS|CUU_DTADDS|CUU_MATODS|"
		cCmpTSV6 := "CUU_CATSP|CUU_DCATSP|CUU_CNPJTC|CUU_MATRCE|CUU_DTADTC|CUU_TPREGT|CUU_TPREGP|CUU_ONUSCE|"
		cCmpTSV7 := "CUU_NATEES|CUU_NIVEES|CUU_AREAES|CUU_NRAPES|CUU_VLBLES|CUU_DTTEES|"
		cCmpTSV8 := "CUU_CNPEES|CUU_NOMEES|CUU_LOGEES|CUU_NLGEES|CUU_BAREES|CUU_CEPES|CUU_UFES|CUU_DUFES|CUU_MUNES|CUU_DMUNES|"
		cCmpTSV9 := "CUU_CNPAES|CUU_NOMAES|CUU_LOGAES|CUU_NLGAES|CUU_BARAES|CUU_CEPAES|CUU_UFAES|CUU_DUFAES|CUU_MUNAES|CUU_DMUNAE|"
		cCmpTSV10:= "CUU_CPFCES|CUU_NOMCES|"
	Else
		cCmpTSV2 := "CUU_CBOCAR|CUU_NMCARG|CUU_CBOFUN|CUU_NMFUNC|"
		cCmpTSV3 := "CUU_VLSLCI|CUU_UNSLCI|CUU_DSCSAL|
		cCmpTSV4 := "CUU_DTFGCI|"
		cCmpTSV5 := "CUU_CATDS|CUU_DCATDS|CUU_TPINSC|CUU_NRINSC|CUU_DTADDS|CUU_MATODS|CUU_REGTRA|CUU_REGPRE|"
		cCmpTSV6 := "CUU_CATSP|CUU_DCATSP|CUU_CNPJTC|CUU_MATRCE|CUU_DTADTC|CUU_TPREGT|CUU_TPREGP|"
		cCmpTSV7 := "CUU_NATEES|CUU_NIVEES|CUU_AREAES|CUU_NRAPES|CUU_DTTEES|"
		cCmpTSV8 := "CUU_CNPEES|CUU_NOMEES|CUU_LOGEES|CUU_NLGEES|CUU_BAREES|CUU_CEPES|CUU_UFES|CUU_DUFES|CUU_MUNES|CUU_DMUNES|"
		cCmpTSV9 := "CUU_CNPAES|"
		cCmpTSV10:= "CUU_CPFCES|"
	EndIf

	cCmpTSV11:= "CUU_DTINIA|CUU_MOTVAF|CUU_DMOTVA|"
	cCmpTSV12:= "CUU_DTTERM|"
	If lLaySimplif .And. TafColumnPos("CUU_MATANT")
		cCmpTSV13:= "CUU_MATANT|CUU_CPFANT|CUU_DALCPF|CUU_OBSCPF|"
	Else
		cCmpTSV13:= "CUU_CPFANT|CUU_DALCPF|CUU_OBSCPF|"
	EndIf

	If lLaySimplif
		cCmpTSV14 := "CUU_INDREM|CUU_TPRTRA|CUU_TPRPRE|"
	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("CUU_CATOME")
		cCmpTSV14 += "CUU_CATOME|CUU_DCATOM|CUU_CNPJOM|CUU_MATOME|CUU_DTEXOM|"
	EndIf

	cCmpFil   := cCmpTSV1 + cCmpTSV11 + cCmpTSV12 + cCmpTSV13
	oStruCUUa := FwFormStruct( 2, "CUU", { |x| AllTrim( x ) + "|" $ cCmpFil } ) // Informacoes Trabalhador Sem Vinculo

	If !lLaySimplif
		cCmpFil   := cCmpTSV2 + cCmpTSV3 + cCmpTSV4 + cCmpTSV5 + cCmpTSV6
	Else
		cCmpFil   := cCmpTSV2 + cCmpTSV3 + cCmpTSV4 + cCmpTSV5 + cCmpTSV6 + cCmpTSV14
	EndIf
	oStruCUUb := FwFormStruct( 2, "CUU", { |x| AllTrim( x ) + "|" $ cCmpFil } ) // Informações Complementares

	cCmpFil   := cCmpTSV7 + cCmpTSV8 + cCmpTSV9 + cCmpTSV10
	oStruCUUc := FwFormStruct( 2, "CUU", { |x| AllTrim( x ) + "|" $ cCmpFil } ) // Informações do Estagiario

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_01", STR0006, "", 1 ) //Dados do Trabalhador
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_02", STR0007, "", 1 ) //Informações de Nascimento
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_03", STR0008, "", 1 ) //Informações da Carteira de Trabalho
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_04", STR0037, "", 1 ) //Informações do Registro de Identificação Civil
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_05", STR0038, "", 1 ) //Informações do Registro Geral (RG)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_06", STR0039, "", 1 ) //Informações do Registro Nacional de Estrangeiro
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_07", STR0040, "", 1 ) //Informações do número de registro em Órgão de Classe (OC)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_08", STR0041, "", 1 ) //Informações da Carteira Nacional de Habilitação (CNH)
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_09", STR0009, "", 1 ) //Endereço
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_10", STR0012, "", 1 ) //Trabalhador Sem Vínculo - Início
	oStruC9Va:AddGroup( "GRP_TRABALHADOR_11", STR0050, "", 1 ) //Informações do trabalhador imigrante 

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
	
	aCmpGrp := StrToKArr(cGrpTra10,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_10")
	Next nI

	//Campos GRP_TRABALHADOR_10 - Trabalhador Sem Vínculo - Início
	oStruC9Va:SetProperty( 'C9V_CADINI' , MVC_VIEW_ORDEM, '01')
	If lLaySimplif
		oStruC9Va:SetProperty( 'C9V_MATTSV' , MVC_VIEW_ORDEM, '02')
	EndIf
	oStruC9Va:SetProperty( 'C9V_CATCI' 	, MVC_VIEW_ORDEM, '03')
	oStruC9Va:SetProperty( 'C9V_DCATCI'	, MVC_VIEW_ORDEM, '04')
	oStruC9Va:SetProperty( 'C9V_DTINIV'	, MVC_VIEW_ORDEM, '05')

	If lLaySimplif
		oStruC9Va:SetProperty( 'C9V_NRPROC'	, MVC_VIEW_ORDEM, '06')
		oStruC9Va:SetProperty( 'C9V_NATATV'	, MVC_VIEW_ORDEM, '07')
		aCmpGrp := StrToKArr(cGrpTra11,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruC9Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_11")
		Next nI
		
	EndIf


	/*====================================================================================
								Validação dos Campos editáveis:
	Em caso de retificação eu permito editar, apenas os campos que NÃO estão nos eventos
	de alteração (S2205 ou S2206)
	======================================================================================*/
	if Type( "INCLUI" ) <> "U"
		lCmpEdit := IIF(INCLUI .OR. (ALTERA .AND. C9V->C9V_STATUS <> '4'),.T.,.F.)
	endif

	//oStruCUUa:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	//oStruCUUb:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)
	//oStruCUUc:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)

	oStruCUUa:SetProperty( "CUU_DMOTVA" , MVC_VIEW_CANCHANGE, .F.)

	If !lLaySimplif
		oStruCUUb:SetProperty( "CUU_DCARCI" , MVC_VIEW_CANCHANGE, .F.)
		oStruCUUb:SetProperty( "CUU_DFUNCI" , MVC_VIEW_CANCHANGE, .F.)
	Else
		oStruCUUb:SetProperty( "CUU_NMCARG" , MVC_VIEW_CANCHANGE, .F.)
		oStruCUUb:SetProperty( "CUU_NMFUNC" , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	oStruCUUb:SetProperty( "CUU_DCATDS" , MVC_VIEW_CANCHANGE, .F.)
	oStruCUUb:SetProperty( "CUU_DCATSP" , MVC_VIEW_CANCHANGE, .F.)

	oStruCUUc:SetProperty( "CUU_DUFES" 	, MVC_VIEW_CANCHANGE, .F.)
	oStruCUUc:SetProperty( "CUU_DMUNES" , MVC_VIEW_CANCHANGE, .F.)
	If !lLaySimplif
		oStruCUUc:SetProperty( "CUU_DUFAES" , MVC_VIEW_CANCHANGE, .F.)
		oStruCUUc:SetProperty( "CUU_DMUNAE" , MVC_VIEW_CANCHANGE, .F.)
	End


	oStruT2F:SetProperty("*", MVC_VIEW_CANCHANGE, lCmpEdit)

	//Tratamento feito para que durante a retificação do evento, seja possível editar apenas os campos que não existirem nos eventos de alteração.
	If !lLaySimplif
		oStruCUUb:SetProperty( "CUU_OPFGCI", MVC_VIEW_CANCHANGE , .T. )
		oStruCUUb:SetProperty( "CUU_ONUSCE", MVC_VIEW_CANCHANGE , .T. )
	EndIf
	oStruCUUb:SetProperty( "CUU_DTFGCI", MVC_VIEW_CANCHANGE , .T. )
	oStruCUUb:SetProperty( "CUU_CATDS" , MVC_VIEW_CANCHANGE , .T. )
	oStruCUUb:SetProperty( "CUU_CNPJTC", MVC_VIEW_CANCHANGE , .T. )
	oStruCUUb:SetProperty( "CUU_MATRCE", MVC_VIEW_CANCHANGE , .T. )
	oStruCUUb:SetProperty( "CUU_DTADTC", MVC_VIEW_CANCHANGE , .T. )

	/*-----------------------------------------------------------------------------------
					Grupo de campos do Informacoes Trabalhador Sem Vinculo
	-------------------------------------------------------------------------------------*/

	oStruCUUa:AddGroup( "GRP_TSV_01", STR0012, "", 1 ) //"Trabalhador Sem Vínculo - Início"
	oStruCUUa:AddGroup( "GRP_TSV_11", STR0047, "", 1 ) //"Afastamento"
	oStruCUUa:AddGroup( "GRP_TSV_12", STR0048, "", 1 ) //"Término"
	oStruCUUa:AddGroup( "GRP_TSV_13", STR0049, "", 1 ) //"Mudança de CPF"

	oStruCUUb:AddGroup( "GRP_TSV_02", STR0013, "", 1 ) //"Cargo e Função do trabalhador"
	oStruCUUb:AddGroup( "GRP_TSV_03", STR0014, "", 1 ) //"Remuneracao"
	oStruCUUb:AddGroup( "GRP_TSV_04", STR0015, "", 1 ) //"FGTS"
	oStruCUUb:AddGroup( "GRP_TSV_05", STR0016, "", 1 ) //"Empresa de Origem do Dirigente Sindical"
	oStruCUUb:AddGroup( "GRP_TSV_06", STR0031, "", 1 ) //"Informações Relativas ao Trabalhador Cedido"
	oStruCUUc:AddGroup( "GRP_TSV_07", STR0032, "", 1 ) //"Informação do Estagiário"
	oStruCUUc:AddGroup( "GRP_TSV_08", STR0033, "", 1 ) //"Instituição de Ensino"
	oStruCUUc:AddGroup( "GRP_TSV_09", STR0034, "", 1 ) //"Agente de Integração"
	oStruCUUc:AddGroup( "GRP_TSV_10", STR0035, "", 1 ) //"Supervisor do Estágio"
	oStruCUUb:AddGroup( "GRP_TSV_14", STR0051, "", 1 ) //"Informações Relativas a Servidor Público Exercente de Mandato Eletivo."

	aCmpGrp := StrToKArr( cCmpTSV1, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUa:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_01" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV2, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_02" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV3, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_03" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV4, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_04" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV5, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_05" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV6, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_06" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV7, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUc:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_07" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV8, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUc:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_08" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV9, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUc:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_09" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV10, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUc:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_10" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV11, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUa:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_11" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV12, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUa:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_12" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV13, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCUUa:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_13" )
	Next nI

	If lLaySimplif
		aCmpGrp := StrToKArr( cCmpTSV14, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCUUb:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_14" )
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

	If TafColumnPos("C9V_PROTUL")
		oView:EnableTitleView( 'VIEW_C9Ve', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("C9V_DTRANS")
		oView:AddField( "VIEW_C9Vf", oStruC9Vf, "MODEL_C9V" )
		oView:EnableTitleView( 'VIEW_C9Vf', TafNmFolder("recibo",2) ) // "Informações de Controle eSocial"
	EndIf

	oView:AddField( "VIEW_CUUa", oStruCUUa, "MODEL_CUU" )
	oView:AddField( "VIEW_CUUb", oStruCUUb, "MODEL_CUU" )
	oView:AddField( "VIEW_CUUc", oStruCUUc, "MODEL_CUU" )

	oView:AddGrid( "VIEW_T2F", oStruT2F, "MODEL_T2F" )
	oView:AddIncrementField( "VIEW_T2F", "T2F_IDDEP" )

	/*-----------------------------------------------------------------------------------
								Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0017) //Trabalhador

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0022 )//"Sem Vínculo"
		
	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_PRINCIPAL',"ABA03", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",STR0043)//"Protocolo de Transmissão"
	EndIf

	If TafColumnPos("C9V_DTRANS")
		oView:CreateHorizontalBox("C9Ve",20,,,"FOLDER_PRINCIPAL","ABA03")
		oView:CreateHorizontalBox("C9Vf",80,,,"FOLDER_PRINCIPAL","ABA03")
	Else
		oView:CreateHorizontalBox("C9Ve",100,,,"FOLDER_PRINCIPAL","ABA03")
	EndIf

	//////////////////////////////////////////////////////////////////////////////////

	oView:CreateHorizontalBox("PAINEL_TRABALHADOR",100,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder("TRABALHADOR","PAINEL_TRABALHADOR")

	oView:AddSheet("TRABALHADOR","ABA01",STR0018) //Informações do Trabalhador
	oView:CreateHorizontalBox("C9Va",100,,,"TRABALHADOR","ABA01")

	If !lLaySimplif
		oView:AddSheet("TRABALHADOR","ABA02",STR0019) //Trabalhador Estrangeiro
		oView:CreateHorizontalBox("C9Vb",100,,,"TRABALHADOR","ABA02")
	EndIf

	oView:AddSheet("TRABALHADOR","ABA03",STR0020) //Deficiência
	oView:CreateHorizontalBox("C9Vc",100,,,"TRABALHADOR","ABA03")

	oView:AddSheet("TRABALHADOR","ABA04",STR0021) //Dependentes
	oView:CreateHorizontalBox("T2F" ,100,,,"TRABALHADOR","ABA04")

	oView:AddSheet("TRABALHADOR","ABA05",STR0010) //Contato
	oView:CreateHorizontalBox("C9Vd",100,,,"TRABALHADOR","ABA05")

	//////////////////////////////////////////////////////////////////////////////////
		
	oView:CreateHorizontalBox( "PAINEL_VINCULO", 100, , , "FOLDER_PRINCIPAL", "ABA02" )
	oView:CreateFolder( "VINCULO", "PAINEL_VINCULO" )
		
	oView:AddSheet( "VINCULO", "ABA01", STR0023 ) //"Informações do Trabalhador Sem Vínculo"
	oView:CreateHorizontalBox( "CUUa", 100, , , "VINCULO", "ABA01" )

	oView:AddSheet( "VINCULO", "ABA02", STR0036 ) //"Informações Complementares"
	oView:CreateHorizontalBox( "CUUb", 100, , , "VINCULO", "ABA02" )

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet( "VINCULO", "ABA03", STR0032 ) //"Informação do Estagiário"
	oView:CreateHorizontalBox( "CUUc", 100, , , "VINCULO", "ABA03" )

	/*-----------------------------------------------------------------------------------
							Amarracao para exibicao das informacoes
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_C9Va", "C9Va" )
	If !lLaySimplif
		oView:SetOwnerView( "VIEW_C9Vb", "C9Vb" )
	EndIf
	oView:SetOwnerView( "VIEW_C9Vc", "C9Vc" )
	oView:SetOwnerView( "VIEW_C9Vd", "C9Vd" )
	oView:SetOwnerView( "VIEW_C9Ve", "C9Ve" )
	If TafColumnPos("C9V_DTRANS")
		oView:SetOwnerView( "VIEW_C9Vf", "C9Vf" )
	EndIf

	oView:SetOwnerView( "VIEW_CUUa", "CUUa" )
	oView:SetOwnerView( "VIEW_CUUb", "CUUb" )
	oView:SetOwnerView( "VIEW_CUUc", "CUUc" )
	oView:SetOwnerView( "VIEW_T2F", "T2F" )

	If lLaySimplif
		oStruCUUb:SetProperty( 'CUU_CBOCAR'	, MVC_VIEW_ORDEM, '01')
		oStruCUUb:SetProperty( 'CUU_NMCARG'	, MVC_VIEW_ORDEM, '02')
		oStruCUUb:SetProperty( 'CUU_CBOFUN'	, MVC_VIEW_ORDEM, '03')
		oStruCUUb:SetProperty( 'CUU_NMFUNC'	, MVC_VIEW_ORDEM, '04')
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr( @oStruC9Va, "C9V" )
		xFunRmFStr( @oStruT2F, "T2F" )
	EndIf
	oStruT2F:RemoveField("T2F_NOMEVE")

	// Auditoria LGPD
	IIf(FindFunction('FwPDLogUser'),FwPDLogUser('TAFA279'),Nil)  

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 25/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local aGrava     	:= {}
	Local aGravaT2F  	:= {}
	Local aGravaCUU  	:= {}
	Local cLogOpeAnt	:= ""
	Local cChvRegAnt	:= ""
	Local cID		   	:= ""
	Local lRetorno  	:= .T.
	Local nOperation 	:= oModel:GetOperation()
	Local oModelC9V 	:= oModel:GetModel("MODEL_C9V")
	Local oModelT2F 	:= oModel:GetModel("MODEL_T2F")
	Local oModelCUU 	:= oModel:GetModel("MODEL_CUU")

	Private cStaEvC9V   := "" //Status do Registro do Evento do Trabalhador (S2200 ou S2300)

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 

	cStaEvC9V   := C9V->C9V_STATUS

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT
		
			TafAjustID( "C9V", oModel)

			oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", xFunGetVer() )
			oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2300" )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '2', '' )
			Endif

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, "MODEL_C9V", "C9V" )
			EndIf

			FwFormCommit( oModel )

		//Alteracao Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//Verifica se o evento ja foi trasmitido ao RET
			If cStaEvC9V == "4"

				If TafColumnPos( "C9V_LOGOPE" )
					cLogOpeAnt := oModelC9V:GetValue( "C9V_LOGOPE" )
				endif

				//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )
				TAF279Carr( oModel, oModelC9V, oModelT2F, oModelCUU, @aGrava, @aGravaT2F, @aGravaCUU )

				//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF279CARR
				TAF279Comm( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU, .F. )
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2300" )

				/*----------------------------------------------------------
				Seto o campo como Inativo e gravo a versao do novo registro
				no registro anterior
				-----------------------------------------------------------*/
				FAltRegAnt( "C9V", "2" )

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, "MODEL_C9V", "C9V" )
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
					TafGrvExt( oModel, "MODEL_C9V", "C9V" )
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'C9V', " " )
				cId := C9V->C9V_ID
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE
			cChvRegAnt := C9V->(C9V_ID + C9V_VERANT)+ "S2300"
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

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} FRulTSVin
Regras para gravacao das informacoes do registro S-2300 do E-Social

@Param
cCabec - Cabecalho de busca das informacoes no Xml

@Return
aRull - Regras para integracao de informacoes do trabalhador sem vinculo

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FRulTSVin(cCabecVinc, cLayout, cAlias, cInconMsg, nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner, lTransf, cFilOri)

	Local aRull  := {}
	Local cCpf   := ""
	Local cFgts	 := ""

	Default cCabecVinc	:= ""
	Default cLayout		:= ""
	Default cAlias		:= "CUU"
	Default cInconMsg		:= ""
	Default nSeqErrGrv	:= 0
	Default lTransmit		:= .F.
	Default oModel		:= Nil
	Default cCodEvent		:= ""
	Default cOwner		:= ""
	Default lTransf		:= .F.
	Default cFilOri		:= ""

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 

	cFgts	 := IIF(lLaySimplif, "FGTS","fgts")

	//*******
	//eSocial/evtTSVInicio/infoTSVInicio
	//*******
	If cLayout == "2306"

		if TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtTSVAltContr/ideTrabSemVinculo/cpfTrab"))
			cCpf:= oDados:XPathGetNodeValue( "/eSocial/evtTSVAltContr/ideTrabSemVinculo/cpfTrab" )
			If !lTransf
				aAdd( aRull, { cAlias + "_NOME" , Posicione("C9V",3, xFilial("C9V") + cCpf + "1" ,"C9V_NOME"), "C", .T. } )
			Else
				aAdd( aRull, { cAlias + "_NOME" , Posicione("C9V",3, cFilOri + cCpf + "1" ,"C9V_NOME"), "C", .T. } )
			EndIf
		Endif

		if TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtTSVAltContr/ideTrabSemVinculo/codCateg"))
			aAdd( aRull, { cAlias + "_CATAV" , FGetIdInt( "codCateg" , "", "/eSocial/evtTSVAltContr/ideTrabSemVinculo/codCateg",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
		Endif
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/natAtividade" ))
		aAdd( aRull, { cAlias + "_NATATV", cCabecVinc + "/natAtividade"                   , "C", .F. } )
	EndIf

	If cLayout == "2300"
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/afastamento/dtIniAfast"))
			aAdd( aRull, { cAlias + "_DTINIA", cCabecVinc + "/afastamento/dtIniAfast", "D", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/afastamento/codMotAfast" ))
			aAdd( aRull, { cAlias + "_MOTVAF", FGetIdInt( "codMotAfast", "", cCabecVinc + "/afastamento/codMotAfast",,,,@cInconMsg, @nSeqErrGrv  ) , "C", .T. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/termino/dtTerm"))
			aAdd( aRull, { cAlias + "_DTTERM", cCabecVinc + "/termino/dtTerm", "D", .F. } )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/cpfAnt" ))
		aAdd( aRull, { cAlias + "_CPFANT", cCabecVinc + "/mudancaCPF/cpfAnt"                   , "C", .F. } )
	EndIf

	If lLaySimplif .And. TafColumnPos( cAlias + "_MATANT")
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/matricAnt" ))
			aAdd( aRull, { cAlias + "_MATANT", cCabecVinc + "/mudancaCPF/matricAnt"                   , "C", .F. } )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/dtAltCPF"))
		aAdd( aRull, { cAlias + "_DALCPF", cCabecVinc + "/mudancaCPF/dtAltCPF", "D", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/mudancaCPF/observacao" ))
		aAdd( aRull, { cAlias + "_OBSCPF", cCabecVinc + "/mudancaCPF/observacao"               , "C", .F. } )
	EndIf    



	//*******
	//eSocial/evtTSVInicio/infoComplementares/cargoFuncao
	//*******
	If !lLaySimplif
		
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/cargoFuncao/codCargo"))
			aAdd( aRull, { cAlias + "_CARCI" , FGetIdInt( "codCargo"  	, "", cCabecVinc + "/infoComplementares/cargoFuncao/codCargo",,,,@cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/cargoFuncao/codFuncao"))
			aAdd( aRull, { cAlias + "_FUNCI" , FGetIdInt( "codFuncao" 	, "", cCabecVinc + "/infoComplementares/cargoFuncao/codFuncao",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
		EndIf

	Else

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/cargoFuncao/CBOCargo"))
			aAdd( aRull, { cAlias + "_CBOCAR" , FGetIdInt( "CBOCargo"  	, "", cCabecVinc + "/infoComplementares/cargoFuncao/CBOCargo",,,, @cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf	

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/cargoFuncao/nmCargo"))
			aAdd( aRull, { cAlias + "_NMCARG" , cCabecVinc + "/infoComplementares/cargoFuncao/nmCargo", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/cargoFuncao/CBOFuncao"))
			aAdd( aRull, { cAlias + "_CBOFUN" , FGetIdInt( "CBOFuncao" 	, "", cCabecVinc + "/infoComplementares/cargoFuncao/CBOFuncao",,,, @cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/cargoFuncao/nmFuncao"))
			aAdd( aRull, { cAlias + "_NMFUNC" , cCabecVinc + "/infoComplementares/cargoFuncao/nmFuncao", "C", .F. } )
		EndIf
		
	EndIf						
	//-----------------------------------

	//*******
	//eSocial/evtTSVInicio/infoComplementares/remuneracao
	//*******
	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/remuneracao/vrSalFx" ))
		aAdd( aRull, { cAlias + "_VLSLCI", cCabecVinc + "/infoComplementares/remuneracao/vrSalFx"                  , "N", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/remuneracao/undSalFixo" ))
		aAdd( aRull, { cAlias + "_UNSLCI", cCabecVinc + "/infoComplementares/remuneracao/undSalFixo"                 , "C", .F. } )
	EndIf

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/remuneracao/dscSalVar"  ))
			aAdd( aRull, { cAlias + "_DSVRCI", cCabecVinc + "/infoComplementares/remuneracao/dscSalVar"             , "C", .F. } )
		EndIf
	Else
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/remuneracao/dscSalVar"  ))
			aAdd( aRull, { cAlias + "_DSCSAL", cCabecVinc + "/infoComplementares/remuneracao/dscSalVar"             , "C", .F. } )
		EndIf	
	EndIf
	//-----------------------------------

	if cLayout == "2300" 
		If !lLaySimplif
			//*******
			//eSocial/evtTSVInicio/infoComplementares/fgts
			//*******
			if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/fgts/opcFGTS" ))
				aAdd( aRull, { cAlias + "_OPFGCI", cCabecVinc + "/infoComplementares/fgts/opcFGTS"                        , "C", .F. } )
			EndIf	
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/" + cFgts + "/dtOpcFGTS" ))
			aAdd( aRull, { cAlias + "_DTFGCI", cCabecVinc + "/infoComplementares/" + cFgts + "/dtOpcFGTS"                        , "D", .F. } )
		EndIf
		//-----------------------------------	
	EndIf

	if cLayout == "2300"
		//*******
		//eSocial/evtTSVInicio/infoComplementares/infoDirigenteSindical
		//*******
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/categOrig"))
			aAdd( aRull, { cAlias + "_CATDS" , FGetIdInt( "categOrig"    , "", cCabecVinc + "/infoComplementares/infoDirigenteSindical/categOrig",,,,@cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf	

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/dtAdmOrig" ))
			aAdd( aRull, { cAlias + "_DTADDS", cCabecVinc + "/infoComplementares/infoDirigenteSindical/dtAdmOrig"                             							     , "D", .F. } )
		EndIf
		
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/matricOrig"  ))
			aAdd( aRull, { cAlias + "_MATODS", cCabecVinc + "/infoComplementares/infoDirigenteSindical/matricOrig"                              								 , "C", .F. } )
		EndIf

		If !lLaySimplif
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/cnpjOrigem"))
				aAdd( aRull, { cAlias + "_CNPJDS", cCabecVinc + "/infoComplementares/infoDirigenteSindical/cnpjOrigem"                                   							 , "C", .F. } )
			EndIf
		Else
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpInsc"))
				aAdd( aRull, { cAlias + "_TPINSC", cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpInsc"                                   							 , "C", .F. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/nrInsc"))
				aAdd( aRull, { cAlias + "_NRINSC", cCabecVinc + "/infoComplementares/infoDirigenteSindical/nrInsc"                                   							 , "C", .F. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegTrab"))
				aAdd( aRull, { cAlias + "_REGTRA", cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegTrab"                                   							 , "C", .F. } )
			EndIf

			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegPrev"))
				aAdd( aRull, { cAlias + "_REGPRE", cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegPrev"                                   							 , "C", .F. } )
			EndIf
		EndIf
		//-----------------------------------	
		
		
		//*******
		//eSocial/evtTSVInicio/infoComplementares/infoTrabCedido
		//*******	
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/categOrig"))
			aAdd( aRull, { cAlias + "_CATSP", FGetIdInt( "categOrig" , "", cCabecVinc + "/infoComplementares/infoTrabCedido/categOrig",,,,@cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf
		
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/cnpjCednt"))
			aAdd( aRull, { cAlias + "_CNPJTC", cCabecVinc + "/infoComplementares/infoTrabCedido/cnpjCednt"                                   						  , "C", .F. } )
		EndIf	
		
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/matricCed" ))
			aAdd( aRull, { cAlias + "_MATRCE", cCabecVinc + "/infoComplementares/infoTrabCedido/matricCed"                                 						  , "C", .F. } )
		EndIf
		
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/dtAdmCed" ))
			aAdd( aRull, { cAlias + "_DTADTC", cCabecVinc + "/infoComplementares/infoTrabCedido/dtAdmCed"                             						      , "D", .F. } )
		EndIf
		
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegTrab"))
			aAdd( aRull, { cAlias + "_TPREGT", cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegTrab", "C", .F.} )
		Endif
		
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegPrev"))
			aAdd( aRull, { cAlias + "_TPREGP", cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegPrev", "C", .F.} )
		Endif
		
		If !lLaySimplif
			if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/infOnus" ))
				aAdd( aRull, { cAlias + "_ONUSCE", cCabecVinc + "/infoComplementares/infoTrabCedido/infOnus"                        									  , "C", .F. } )
			EndIf
		EndIf
		//-----------------------------------	
		
	EndIf

	If lLaySimplif
		If cLayout == "2306"
			//*******
			//eSocial/evtTSVAltContr/infoComplementares/infoDirigenteSindical
			//*******
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegPrev"))
				aAdd( aRull, { cAlias + "_REGPRE", cCabecVinc + "/infoComplementares/infoDirigenteSindical/tpRegPrev"                                   							 , "C", .F. } )
			EndIf

			//*******
			//eSocial/evtTSVAltContr/infoComplementares/infoTrabCedido
			//*******
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegPrev"))
				aAdd( aRull, { cAlias + "_TPREGP", cCabecVinc + "/infoComplementares/infoTrabCedido/tpRegPrev", "C", .F.} )
			Endif
		EndIf

		//*******
		//eSocial/evtTSVInicio/infoComplementares/infoMandElet
		//*******	

		If cLayout == "2300" .And. TAFNT0421(lLaySimplif) .And. TafColumnPos(cAlias + "_CATOME")
			If TafXNode(oDados, cCodEvent, cOwner, cCabecVinc + "/infoComplementares/infoMandElet/categOrig")
				aAdd(aRull, {cAlias + "_CATOME", FGetIdInt("categOrig", "", cCabecVinc + "/infoComplementares/infoMandElet/categOrig",,,, @cInconMsg, @nSeqErrGrv), "C", .T.})
			EndIf

			If TafXNode(oDados, cCodEvent, cOwner, cCabecVinc + "/infoComplementares/infoMandElet/cnpjOrig")
				aAdd(aRull, {cAlias + "_CNPJOM", cCabecVinc + "/infoComplementares/infoMandElet/cnpjOrig", "C", .F.})
			EndIf

			If TafXNode(oDados, cCodEvent, cOwner, cCabecVinc + "/infoComplementares/infoMandElet/matricOrig")
				aAdd(aRull, {cAlias + "_MATOME", cCabecVinc + "/infoComplementares/infoMandElet/matricOrig", "C", .F.})
			EndIf

			If TafXNode(oDados, cCodEvent, cOwner, cCabecVinc + "/infoComplementares/infoMandElet/dtExercOrig")
				aAdd(aRull, {cAlias + "_DTEXOM", cCabecVinc + "/infoComplementares/infoMandElet/dtExercOrig", "D", .F.})
			EndIf
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoMandElet/indRemunCargo"))
			aAdd( aRull, { cAlias + "_INDREM", cCabecVinc + "/infoComplementares/infoMandElet/indRemunCargo"                                   						  , "C", .F. } )
		EndIf

		If cLayout == "2300"	
			If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoMandElet/tpRegTrab"))
				aAdd( aRull, { cAlias + "_TPRTRA", cCabecVinc + "/infoComplementares/infoMandElet/tpRegTrab"                                   						  , "C", .F. } )
			EndIf
		EndIf	
		
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoMandElet/tpRegPrev" ))
			aAdd( aRull, { cAlias + "_TPRPRE", cCabecVinc + "/infoComplementares/infoMandElet/tpRegPrev"                                 						  , "C", .F. } )
		EndIf
	EndIf

	//-----------------------------------	

	//*******
	//eSocial/evtTSVInicio/infoComplementares/infoEstagiario
	//*******
	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/natEstagio"))
		aAdd( aRull, { cAlias + "_NATEES", cCabecVinc + "/infoComplementares/infoEstagiario/natEstagio"                              , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/nivEstagio"))
		aAdd( aRull, { cAlias + "_NIVEES", cCabecVinc + "/infoComplementares/infoEstagiario/nivEstagio"                              , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/areaAtuacao" ))
		aAdd( aRull, { cAlias + "_AREAES", cCabecVinc + "/infoComplementares/infoEstagiario/areaAtuacao"                             , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/nrApol"  ))
		aAdd( aRull, { cAlias + "_NRAPES", cCabecVinc + "/infoComplementares/infoEstagiario/nrApol"                                  , "C", .F. } )
	EndIf

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/infoEstagiario/vlrBolsa" ))
			aAdd( aRull, { cAlias + "_VLBLES", cCabecVinc + "/infoComplementares/infoEstagiario/vlrBolsa"                                , "N", .F. } )
		EndIf
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/infoEstagiario/dtPrevTerm"))
		aAdd( aRull, { cAlias + "_DTTEES", cCabecVinc + "/infoComplementares/infoEstagiario/dtPrevTerm"                       	   , "D", .F. } )
	EndIf
	//-----------------------------------	


	//*******
	//eSocial/evtTSVInicio/infoComplementares/infoEstagiario/instEnsino
	//*******
	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/cnpjInstEnsino"))
		aAdd( aRull, { cAlias + "_CNPEES", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/cnpjInstEnsino"               , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/nmRazao"))
		aAdd( aRull, { cAlias + "_NOMEES", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/nmRazao"                    , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/dscLograd"))
		aAdd( aRull, { cAlias + "_LOGEES", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/dscLograd"               , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/nrLograd" ))
		aAdd( aRull, { cAlias + "_NLGEES", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/nrLograd"                 , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/bairro"))
		aAdd( aRull, { cAlias + "_BAREES", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/bairro"                       , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/cep"  ))
		aAdd( aRull, { cAlias + "_CEPES" , cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/cep"                          , "C", .F. } )
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/uf")) .And. TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/codMunic"))
		If !Empty(oDados:XPathGetNodeValue( cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/codMunic" ))
			aAdd( aRull, { cAlias + "_MUNES" , FGetIdInt( "uf", "codMunic",;
													cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/uf",;
													cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/codMunic",,,@cInconMsg, @nSeqErrGrv      ), "C", .T. } )
		EndIf
	EndIf

	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/uf"))
		If !Empty(oDados:XPathGetNodeValue( cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/uf" ))
			aAdd( aRull, { cAlias + "_UFES"  , FGetIdInt( "uf", "", cCabecVinc + "/infoComplementares/infoEstagiario/instEnsino/uf",,,,@cInconMsg, @nSeqErrGrv     ), "C", .T. } )
		EndIf
	EndIf
	//-----------------------------------	

	//*******
	//eSocial/evtTSVInicio/infoComplementares/infoEstagiario/ageIntegracao
	//*******
	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/cnpjAgntInteg"))
		aAdd( aRull, { cAlias + "_CNPAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/cnpjAgntInteg"      		, "C", .F. } )
	EndIf

	If !lLaySimplif 
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/nmRazao"   ))
			aAdd( aRull, { cAlias + "_NOMAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/nmRazao"                	, "C", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, ( cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/dscLograd"   ))
			aAdd( aRull, { cAlias + "_LOGAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/dscLograd"           	 	, "C", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/nrLograd"  ))
			aAdd( aRull, { cAlias + "_NLGAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/nrLograd"              		, "C", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/bairro"))
			aAdd( aRull, { cAlias + "_BARAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/bairro"                    , "C", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/cep"   ))
			aAdd( aRull, { cAlias + "_CEPAES", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/cep"                       , "C", .F. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/uf")) .And. TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/codMunic"))
			aAdd( aRull, { cAlias + "_MUNAES", FGetIdInt( "uf", "codMunic",;
													cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/uf",;
													cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/codMunic",,,@cInconMsg, @nSeqErrGrv   ), "C", .T. } )
		EndIf

		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/uf"))
			aAdd( aRull, { cAlias + "_UFAES" , FGetIdInt( "uf", "", cCabecVinc + "/infoComplementares/infoEstagiario/ageIntegracao/uf",,,,@cInconMsg, @nSeqErrGrv  ), "C", .T. } )
		EndIf
	EndIf
	//-----------------------------------	

	//*******
	//eSocial/evtTSVInicio/infoComplementares/infoEstagiario/supervisorEstagio
	//*******
	if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/supervisorEstagio/cpfSupervisor"))
		aAdd( aRull, { cAlias + "_CPFCES", cCabecVinc + "/infoComplementares/infoEstagiario/supervisorEstagio/cpfSupervisor"         , "C", .F. } )
	EndIf
	If !lLaySimplif
		if TafXNode( oDados , cCodEvent, cOwner, (cCabecVinc + "/infoComplementares/infoEstagiario/supervisorEstagio/nmSuperv"))
			aAdd( aRull, { cAlias + "_NOMCES", cCabecVinc + "/infoComplementares/infoEstagiario/supervisorEstagio/nmSuperv"        , "C", .F. } )
		EndIf
	EndIf
	//-----------------------------------

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Grv    
Funcao de gravacao para atender o registro S-2300

@Param:
cLayout -  Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
            alimenta mais de um registro do E-Social, para estes casos serao necessarios
            tratamentos de acordo com o layout que esta sendo enviado.
            
nOpc    -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )

cFilEv  -  Filial do ERP para onde as informacoes deverao ser importadas

oXML    -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
		  
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin
@since 26/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF279Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE ,cKey, cMatrC9V, lLaySmpTot,lExclCMJ,oTransf)

Local cLogOpeAnt	:= ""
Local cCmpsNoUpd 	:= "|C9V_FILIAL|C9V_ID|C9V_VERSAO|C9V_NOMEVE|C9V_VERANT|C9V_PROTUL|C9V_PROTPN|C9V_EVENTO|C9V_STATUS|C9V_ATIVO|"
Local cCabecTrab 	:= "/eSocial/evtTSVInicio/trabalhador"
Local cCabecVinc 	:= "/eSocial/evtTSVInicio/infoTSVInicio"
Local cCpf       	:= ""
Local cMensagem		:= ""
Local cEnter	  	:= Chr(13) + Chr(10)
Local cInconMsg  	:= ""
Local cFilC9V		:= ""
Local cChvTrab		:= ""
Local cT2FPath   	:= ""
Local cChave     	:= ""
Local cCodEvent 	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
Local cCateg		:= ""
Local cChaveOri		:= ""
Local cProtUl		:= ""
Local cStatus		:= ""
Local cChvMat		:= ""
Local nI         	:= 0
Local nJ         	:= 0
Local nSeqErrGrv 	:= 0
Local nIndChv    	:= 17

Local lRet       	:= .F.
Local lTransmit		:= .F.
Local lAltPend		:= .F.
Local lTransf		:= .F.
Local lMesmaBase 	:= .F.

Local aIncons    	:= {}
Local aRulesCad  	:= {}
Local aRulesTSV  	:= {}
Local aChave     	:= {}

Local oModel     	:= Nil

Local dDtIniV		:= CtoD("  /  /  ")

Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
Private oDados   	:= {}

Default cLayout  	:= "2300"
Default nOpc     	:= 1
Default cFilEv   	:= ""
Default oXML     	:= Nil
Default cOwner		:= ""
Default cFilTran	:= ""
Default cPredeces	:=	""
Default nTafRecno	:=	0
Default cComplem	:=	""
Default cGrpTran	:=	""
Default cEmpOriGrp	:=	""
Default cFilOriGrp	:=	""
Default cXmlID		:=	""
Default lMigrador	:= .F.
Default lDepGPE		:= .F.
Default cEvtOri		:= ""
Default oTransf 	:= Nil 


If !TafVldAmb("2")
	cMensagem := STR0045 + cEnter // #"Dicionário Incompatível"
	cMensagem += TafAmbInvMsg()

	Aadd(aIncons, cMensagem)
Else

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 

	nIndChv    	:= IIF(lLaySimplif,22,17)

	If oTransf == Nil 
		cFilC9V  := FTafGetFil(cFilEv,@aIncons,"C9V")
	Else 
		lMesmaBase 	:= oTransf:isSameBaseCNPJ()
		cChaveOri 	:= oTransf:getOriginKey()
		cProtUl 	:= oTransf:getReceipt()
		cStatus		:= oTransf:getStatus()
		lTransf := .T. 
		cFilC9V := oTransf:getDestBranch()
	EndIf 

	oDados := oXML

	If oDados:XPathHasNode( cCabecTrab + "/cpfTrab"  )
		cCPF	  := oDados:XPathGetNodeValue( cCabecTrab + "/cpfTrab" )
	EndIf

	If oDados:XPathHasNode( cCabecVinc + "/codCateg"  )
		cCateg	  := FGetIdInt( "codCateg" , "", cCabecVinc + "/codCateg",,,,@cInconMsg, @nSeqErrGrv)
	EndIf

	If lLaySimplif
		If oDados:XPathHasNode( cCabecVinc + "/matricula"  )
			cChvMat	  := oDados:XPathGetNodeValue( cCabecVinc + "/matricula" )
		EndIf
	EndIf

	If oDados:XPathHasNode( cCabecVinc + "/dtInicio"  )
		dDtIniV := SToD( StrTran(oDados:XPathGetNodeValue( cCabecVinc + "/dtInicio" ) , "-", '' ) )
	EndIf

	
	aAdd( aChave, {"C", "C9V_CPF", cCPF, .T. } )	
	If lLaySimplif
		aAdd( aChave, {"C", "C9V_MATTSV", cChvMat, .T. } )	
	EndIf
	aAdd( aChave, {"C", "C9V_CATCI", cCateg, .T. } )
	aAdd( aChave, {"D", "C9V_DTINIV", dDtIniV, .T. } )

	If lLaySimplif
		cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) + Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1] ) +Padr( DTOS(aChave[ 4, 3 ]), Tamsx3( aChave[ 4, 2 ])[1] )
	Else 
		cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) + Padr( DTOS(aChave[ 3, 3 ]), Tamsx3( aChave[ 3, 2 ])[1] )
	EndIf

	//Verifica se o evento ja existe na base
	("C9V")->( DbSetOrder( nIndChv ) )
	If ("C9V")->( MsSeek( cFilC9V + cChave + '1' ) )
		cChvTrab		:= C9V->C9V_ID + '1'
		nOpc 	 := 4
		lTransmit := IIF(C9V->C9V_STATUS == '4',.T.,.F.)
		//=======================================================================================================+
		// Posiciona no último evento de alteração (2306) ativo para este trabalhador.                          ||
		// Retorna .F. se não encontrar um registro de alteração ativo para este trabalhador e .T. SE encontrar ||
		//=======================================================================================================+
		IF RetUltAtivo('T0F',cChvTrab,2)
			If T1U->T1U_STATUS <> '4'
				Aadd( aIncons, "ERRO19")
				lAltPend := .T.
			Endif
		EndIf
	EndIf

	If lDepGPE

		//Chama função para correção do cadastro de dependentes do S-2300 criado para envio do S-2306 de transferência.
		TafAjustDeps( @oModel, @oDados, "S-2300", "TAFA279", "C9V", @cInconMsg, @aIncons, @nSeqErrGrv )
		//Chama função para correção do cadastro de dependentes do S-2300 criado para envio do S-2306 de transferência.

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

		oModel:DeActivate()
		If FindFunction('TafClearModel')
			TafClearModel(oModel)
		EndIf

	Else

		if !lAltPend

			//Funcao para validar se a operacao desejada pode ser realizada
			If FTafVldOpe( "C9V", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA279", cCmpsNoUpd )

				If TafColumnPos( "C9V_LOGOPE" )
					cLogOpeAnt := C9V->C9V_LOGOPE
				endif

				//Caso se trate de uma inclusao/retificação gravo o tipo do evento na tabela C9V
				oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2300" )

				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := FRulCad( cCabecTrab, cLayout, ,cCabecVinc, @cInconMsg, @nSeqErrGrv, lTransmit, oModel,,, cCodEvent, cOwner )

				//Carrego array com os campos De/Para de gravacao das informacoes ( Trabalhador Sem Vinculo )
				aRulesTSV := FRulTSVin( cCabecVinc, cLayout,, @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner ) ///eSocial/evtTSVInicio/infoTSVInicio

				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5

					oModel:LoadValue( "MODEL_C9V", "C9V_FILIAL", C9V->C9V_FILIAL )
					oModel:LoadValue( "MODEL_C9V", "C9V_XMLID", cXmlID )
					
					//Carrego as informações do trabalhador original no evento de transferencia
					If lTransf

						oModel:LoadValue( "MODEL_C9V", "C9V_IDTRAN", cChaveOri)
						if lMesmaBase
							oModel:LoadValue( "MODEL_C9V", "C9V_PROTUL", AllTrim(cProtUl))
							oModel:LoadValue( "MODEL_C9V", "C9V_STATUS", cStatus)
						endif 
					EndIf 

					//Rodo o aRulesCad para gravar as informacoes
					For nI := 1 to Len( aRulesCad )
						oModel:LoadValue( "MODEL_C9V", aRulesCad[nI,1], FTafGetVal( aRulesCad[nI,2], aRulesCad[nI,3], aRulesCad[nI,4], @aIncons, .F. ) )
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//Rodo o aRulesTSV para gravar as informacoes
					For nI := 1 to Len( aRulesTSV )
						oModel:LoadValue( "MODEL_CUU", aRulesTSV[nI,1], FTafGetVal( aRulesTSV[nI,2], aRulesTSV[nI,3], aRulesTSV[nI,4], @aIncons, .F. ) )
					Next nI

					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Cadastro de Dependentes )
					cT2FPath  := cCabecTrab + "/dependente[1]"

					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_T2F" ):Length()
							oModel:GetModel( "MODEL_T2F" ):GoLine( nJ )
							oModel:GetModel( "MODEL_T2F" ):DeleteLine()
						Next nJ
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
					nJ := 1
					While oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ)+ "]" )

						If nOpc == 4 .or. nJ > 1
							oModel:GetModel( "MODEL_T2F" ):lValid:= .T.
							oModel:GetModel( "MODEL_T2F" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T2F", "T2F_IDDEP" , StrZero(nJ,6) )
						if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep")
							oModel:LoadValue( "MODEL_T2F", "T2F_TPDEP" , FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep",,,,@cInconMsg, @nSeqErrGrv))
						EndIf
						if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep")
							oModel:LoadValue( "MODEL_T2F", "T2F_NOMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep"                              , "C", .F., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto")
							oModel:LoadValue( "MODEL_T2F", "T2F_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto"                             , "D", .F., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep" )
							oModel:LoadValue( "MODEL_T2F", "T2F_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep"                               , "C", .F., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF")
							oModel:LoadValue( "MODEL_T2F", "T2F_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF" ) ,2), "C", .T., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF")
							oModel:LoadValue( "MODEL_T2F", "T2F_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF"   ) ,2), "C", .T., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab")
							oModel:LoadValue( "MODEL_T2F", "T2F_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab"  ) ,2) , "C", .T., @aIncons, .F. ) )
						EndIf

						nJ++
					EndDo

				EndIf

				///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cInconMsg) .And. Empty(aIncons)
					If TafFormCommit( oModel )
						Aadd(aIncons, "ERRO19")
					Else
						lRet := .T.
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
	aRulesCad := Nil

	aSize( aRulesTSV, 0 )
	aRulesTSV := Nil

	aSize( aChave, 0 )
	aChave := Nil

Endif

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Xml
Funcao de geracao do XML para atender os registros S-2300.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2300
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF279Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml    	:= ""
Local cReg    	:= "TSVInicio"
Local cLayout	:= "2300"
Local cAliasDep	:= "T2F"

Default lJob  	:= .F.
Default cSeqXml := ""

If FindFunction("TafCacheLayESoc")
	lLaySimplif := TafCacheLayESoc("S_01_00_00")
Else 
	If lLaySimplif == Nil 
		lLaySimplif := TafLayESoc("S_01_00_00")
	EndIf 
EndIf 

cXml += FGetCad( cLayout, cAlias, cAliasDep )

//Garanto que esta posicionado corretamente
CUU->(DBSetOrder(1))
CUU->( MsSeek( xFilial("CUU") + C9V->( C9V_ID + C9V_VERSAO ) ) )

cXml += FGetSVinc( cLayout, "CUU"  )

//Estrutura do cabecalho
cXml := xTafCabXml(cXml,cAlias,cLayout,cReg,,cSeqXml)

//Executa gravacao do registro
If !lJob
	xTafGerXml( cXml, cLayout )
EndIf

Return( cXml )
    
//-------------------------------------------------------------------
/*/{Protheus.doc} FGetSVinc

Funcao para estrutura dos dados de vinculo do Xml 2300

@Param:
cLayout - Layout para montagem da estrutura
cAlias  - Alias da Tabela

@Return:
cXml - Estrutura dos dados de vinculo do Xml

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGetSVinc(cLayout, cAlias)

	Local aInfoMandE	:= {}
	Local cXml 			:= ""
	Local cCategOri 	:= ""
	Local cFgts	 		:= ""	 
	Local cCBOCargo		:= ""	
	Local cCBOFUN		:= ""
	Local cNmCargo		:= ""
	Local cNmFunc		:= ""

	If FindFunction("TafCacheLayESoc")
		lLaySimplif := TafCacheLayESoc("S_01_00_00")
	Else 
		If lLaySimplif == Nil 
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 
	EndIf 

	cFgts	 	:= IIF(lLaySimplif, "FGTS","fgts")

	DBSelectArea("C87")
	C87->( DBSetOrder( 1 ) )

	DBSelectArea("C8V")
	C8V->( DBSetOrder( 1 ) )

	DBSelectArea("C8X")
	C8X->( DBSetOrder( 1 ) )

	DBSelectArea("C8Z")
	C8Z->( DBSetOrder( 1 ) )

	DBSelectArea("C09")
	C09->( DBSetOrder( 3 ) )

	DBSelectArea("C07")
	C07->( DBSetOrder( 3 ) )

	DBSelectArea("C8N")
	C8N->( DBSetOrder( 1 ) )

	If cLayout == "2300"
		cXml += "<infoTSVInicio>"
		//##################
		//Inicio do XML - Trab. Sem Vinculo
		//##################
		cXml += xTafTag("cadIni",xFunTrcSN(C9V->C9V_CADINI, 1),,.T. )
		
		If lLaySimplif 
			cXml +=	xTafTag( "matricula", C9V->C9V_MATTSV,,.T.)		
		EndIf

		If C87->( MsSeek( xFilial("C87") + C9V->C9V_CATCI ) )
			cXml +=	xTafTag( "codCateg", C87->C87_CODIGO )
		Else
			cXml +=	xTafTag( "codCateg", "" )
		EndIf
		
		cXml +=	xTafTag( "dtInicio", C9V->C9V_DTINIV )

		If lLaySimplif 		
			cXml +=	xTafTag( "nrProcTrab", C9V->C9V_NRPROC ,,.T.)
		EndIf
	EndIf

	If !lLaySimplif
		cXml +=	 xTafTag( "natAtividade", ( cAlias )->&( cAlias + "_NATATV" ),,.T.)
	Else
		cXml +=	 xTafTag( "natAtividade", C9V->C9V_NATATV,,.T.)
	EndIf

	//-----------------------------------

	If	!Empty(( cAlias )->&( cAlias + "_CARCI" ))  .or. !Empty(( cAlias )->&( cAlias + "_VLSLCI" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_NATEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMCES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_NIVEES" )) .or. !Empty(( cAlias )->&( cAlias + "_UNSLCI" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_AREAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NRAPES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_VLBLES" )) .or. !Empty(( cAlias )->&( cAlias + "_DTTEES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_CNPEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMEES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_LOGEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NLGEES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_BAREES" )) .or. !Empty(( cAlias )->&( cAlias + "_CEPES"  )) .or.;
		!Empty(( cAlias )->&( cAlias + "_MUNES"  )) .or. !Empty(( cAlias )->&( cAlias + "_UFES"   )) .or.;
		!Empty(( cAlias )->&( cAlias + "_CNPAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMAES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_LOGAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NLGAES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_BARAES" )) .or. !Empty(( cAlias )->&( cAlias + "_CEPAES" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_MUNAES" )) .or. !Empty(( cAlias )->&( cAlias + "_UFAES"  )) .or.;
		!Empty(( cAlias )->&( cAlias + "_CPFCES" )) .or. !Empty(( cAlias )->&( cAlias + "_CBOCAR" )) .or.;
		!Empty(( cAlias )->&( cAlias + "_CBOFUN" ))


		cXml += 	"<infoComplementares>"

		//************************************
		//cargoFuncao
		//************************************

		If !lLaySimplif .And. (!Empty(( cAlias )->&( cAlias + "_CARCI" )) .or. !Empty(( cAlias )->&( cAlias + "_FUNCI" )))
			cXml += 		"<cargoFuncao>"
			If C8V->( MsSeek( xFilial("C8V") + ( cAlias )->&( cAlias + "_CARCI" ) ) )
				cXml +=		xTafTag( "codCargo", C8V->C8V_CODIGO,,.F. )
			Else
				cXml +=		xTafTag( "codCargo", "",,.F. )
			EndIf
			If C8X->( MsSeek( xFilial("C8X") + ( cAlias )->&( cAlias + "_FUNCI" ) ) )
				cXml +=		xTafTag( "codFuncao", C8X->C8X_CODIGO,,.T. )
			Else
				cXml +=		xTafTag( "codFuncao", "" ,,.T. )
			EndIf
			cXml += 		"</cargoFuncao>"
		Else
			If C8Z->( MsSeek( xFilial("C8Z") + (cAlias)->&(cAlias + "_CBOCAR") ) )
				cCBOCargo := C8Z->C8Z_CODIGO
				cNmCargo  := C8Z->C8Z_DESCRI
			EndIf
			If C8Z->( MsSeek( xFilial("C8Z") + (cAlias)->&(cAlias + "_CBOFUN") ) )
				cCBOFUN	  := C8Z->C8Z_CODIGO
				cNmFunc   := C8Z->C8Z_DESCRI
			EndIf
			xTafTagGroup(	"cargoFuncao";
					,{{"nmCargo"	, cNmCargo	 , PesqPict(cAlias, cAlias + "_NMCARG") , .T.};
					,{"CBOCargo" 	, cCBOCargo	 , PesqPict( cAlias, cAlias + "_CBOCAR"), .T.};
					,{"nmFuncao" 	, cNmFunc	 , PesqPict( cAlias, cAlias + "_NMFUNC"), .T.};
					,{"CBOFuncao"	, cCBOFUN	 , PesqPict( cAlias, cAlias + "_CBOFUN"), .T.}};
					,@cXml)
		EndIf

		//--------------------------------------


		//************************************
		//remuneracao
		//************************************
		If !Empty(( cAlias )->&( cAlias + "_VLSLCI" )) .or. !Empty(( cAlias )->&( cAlias + "_UNSLCI" ))
			cXml +=		"<remuneracao>"
			cXml +=			xTafTag( "vrSalFx", 	  ( cAlias )->&( cAlias + "_VLSLCI" ),"@R 9999999999999.99",,.F., .T.)
			cXml +=			xTafTag( "undSalFixo", ( cAlias )->&( cAlias + "_UNSLCI" ) ,,.F.)
			If !lLaySimplif
				cXml +=			xTafTag( "dscSalVar",  ( cAlias )->&( cAlias + "_DSVRCI" ),,.T.)
			Else
				cXml +=			xTafTag( "dscSalVar",  FwNoAccent(StrTran(( cAlias )->&( cAlias + "_DSCSAL" ), Chr(13) + Chr(10), " ")),,.T.)
			EndIf
			
			cXml +=		"</remuneracao>"
		EndIf
		//------------------------------------

		if cLayout == "2300" 
			//************************************
			//fgts
			//************************************
			If !Empty(( cAlias )->&( cAlias + "_OPFGCI" )) .or. !Empty(( cAlias )->&( cAlias + "_DTFGCI" ))
				cXml +=		"<" + cFgts + ">"
				If !lLaySimplif
					cXml +=			xTafTag( "opcFGTS"  , ( cAlias )->&( cAlias + "_OPFGCI" ) )
				EndIf
				cXml +=			xTafTag( "dtOpcFGTS", ( cAlias )->&( cAlias + "_DTFGCI" ),,.T.)
				cXml +=		"</" + cFgts + ">"
			EndIf
			//------------------------------------

			//************************************
			//infoDirigenteSindical
			//************************************		
			If C87->( MsSeek( xFilial("C87") + ( cAlias )->&( cAlias + "_CATDS" ) ) )
				cCategOri += C87->C87_CODIGO 			
			EndIf
			If !lLaySimplif						
				xTafTagGroup(	"infoDirigenteSindical";
					,{{"categOrig"	, cCategOri						 , PesqPict(cAlias, cAlias + "_CATDS") , .F.};
					,{"cnpjOrigem" 	, (cAlias)->&(cAlias + "_CNPJDS"), PesqPict( cAlias, cAlias + "_CNPJDS"), .F.};
					,{"dtAdmOrig" 	, (cAlias)->&(cAlias + "_DTADDS"), PesqPict( cAlias, cAlias + "_DTADDS"), .F.};
					,{"matricOrig"	, (cAlias)->&(cAlias + "_MATODS"), PesqPict( cAlias, cAlias + "_MATODS"), .F.}};
					,@cXml)
			Else
				xTafTagGroup(	"infoDirigenteSindical";
					,{{"categOrig"	, cCategOri						 , PesqPict(cAlias, cAlias + "_CATDS") , .T.};
					,{"tpInsc" 		, (cAlias)->&(cAlias + "_TPINSC"), PesqPict( cAlias, cAlias + "_TPINSC"), .F.};
					,{"nrInsc" 		, (cAlias)->&(cAlias + "_NRINSC"), PesqPict( cAlias, cAlias + "_NRINSC"), .F.};
					,{"dtAdmOrig" 	, (cAlias)->&(cAlias + "_DTADDS"), PesqPict( cAlias, cAlias + "_DTADDS"), .F.};
					,{"matricOrig"	, (cAlias)->&(cAlias + "_MATODS"), PesqPict( cAlias, cAlias + "_MATODS"), .F.};
					,{"tpRegTrab"	, (cAlias)->&(cAlias + "_REGTRA"), PesqPict( cAlias, cAlias + "_REGTRA"), .F.};
					,{"tpRegPrev"	, (cAlias)->&(cAlias + "_REGPRE"), PesqPict( cAlias, cAlias + "_REGPRE"), .T.}};				
					,@cXml)
			EndIf
			//-------------------------------------

			//************************************
			//infoTrabCedido
			//************************************
			If !Empty(( cAlias )->&( cAlias + "_CATSP"  )) .or. !Empty(( cAlias )->&( cAlias + "_CNPJTC" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_MATRCE" )) .or. !Empty(( cAlias )->&( cAlias + "_DTADTC" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_ONUSCE" ))
				cXml +=			"<infoTrabCedido>"
				If C87->( MsSeek( xFilial("C87") + ( cAlias )->&( cAlias + "_CATSP" ) ) )
					cXml +=				xTafTag( "categOrig", C87->C87_CODIGO )
				Else
					cXml +=				xTafTag( "categOrig", "" )
				EndIf
				cXml +=				xTafTag( "cnpjCednt", ( cAlias )->&( cAlias + "_CNPJTC" ) )
				cXml +=				xTafTag( "matricCed", ( cAlias )->&( cAlias + "_MATRCE" ) )
				cXml +=				xTafTag( "dtAdmCed",  ( cAlias )->&( cAlias + "_DTADTC" ) )
				cXml +=				xTafTag( "tpRegTrab", ( cAlias )->&( cAlias + "_TPREGT" ) )
				cXml +=				xTafTag( "tpRegPrev", ( cAlias )->&( cAlias + "_TPREGP" ) )
				If !lLaySimplif
					cXml +=				xTafTag( "infOnus",   ( cAlias )->&( cAlias + "_ONUSCE" ) )
				EndIf
				cXml +=			"</infoTrabCedido>"
			EndIf
			//-------------------------------------

			//************************************
			//infoMandElet
			//************************************
			If lLaySimplif
				If cLayout == "2300" .And. TAFNT0421(lLaySimplif) .And. TafColumnPos(cAlias + "_CATOME")
					aInfoMandE := {	{"categOrig"	, Posicione("C87", 1, xFilial("C87") + (cAlias)->&(cAlias + "_CATOME"), "C87_CODIGO")	},;
									{"cnpjOrig"		, (cAlias)->&(cAlias + "_CNPJOM")														},;
									{"matricOrig"	, (cAlias)->&(cAlias + "_MATOME")														},;
									{"dtExercOrig"	, (cAlias)->&(cAlias + "_DTEXOM")														}	}
				EndIf

				AAdd(aInfoMandE, {"indRemunCargo"	, (cAlias)->&(cAlias + "_INDREM"), PesqPict(cAlias, cAlias + "_INDREM"), .T.})
				AAdd(aInfoMandE, {"tpRegTrab"		, (cAlias)->&(cAlias + "_TPRTRA"), PesqPict(cAlias, cAlias + "_TPRTRA"), .F.})
				AAdd(aInfoMandE, {"tpRegPrev"		, (cAlias)->&(cAlias + "_TPRPRE"), PesqPict(cAlias, cAlias + "_TPRPRE"), .F.})

				xTafTagGroup("infoMandElet", aInfoMandE, @cXml)
			EndIf
		EndIf

		If cLayout == "2306" .And. lLaySimplif
			//****************************************************************
			//infoDirigenteSindical - EXCLUSIVO SIMPLIFICADO
			//****************************************************************	
			xTafTagGroup(	"infoDirigenteSindical";
				,{{"tpRegPrev"	, (cAlias)->&(cAlias + "_REGPRE"), PesqPict( cAlias, cAlias + "_REGPRE"), .T.}};
				,@cXml)
			//----------------------------------------------------------------

			//********************************************************************
			//infoTrabCedido - EXCLUSIVO SIMPLIFICADO
			//********************************************************************
			If !Empty(( cAlias )->&( cAlias + "_TPREGP" ))
				cXml +=			"<infoTrabCedido>"
				cXml +=				xTafTag( "tpRegPrev", ( cAlias )->&( cAlias + "_TPREGP" ) )
				cXml +=			"</infoTrabCedido>"
			EndIf
			//-------------------------------------

			//************************************************************
			//infoMandElet - EXCLUSIVO SIMPLIFICADO
			//************************************************************
			xTafTagGroup(	"infoMandElet";
				,{{"indRemunCargo", (cAlias)->&(cAlias + "_INDREM"), PesqPict(cAlias, cAlias + "_INDREM"), .T.};
				,{"tpRegPrev" ,  (cAlias)->&(cAlias + "_TPRPRE"), PesqPict( cAlias, cAlias + "_TPRPRE"), .F.}};
				,@cXml)
		EndIf

		//************************************
		//infoEstagiario
		//************************************
		If	!Empty(( cAlias )->&( cAlias + "_NATEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NIVEES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_AREAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NRAPES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_NATEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NIVEES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_VLBLES" )) .or. !Empty(( cAlias )->&( cAlias + "_DTTEES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_CNPEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMEES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_LOGEES" )) .or. !Empty(( cAlias )->&( cAlias + "_NLGEES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_BAREES" )) .or. !Empty(( cAlias )->&( cAlias + "_CEPES"  )) .or.;
			!Empty(( cAlias )->&( cAlias + "_MUNES"  )) .or. !Empty(( cAlias )->&( cAlias + "_UFES"   )) .or.;
			!Empty(( cAlias )->&( cAlias + "_CNPAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMAES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_LOGAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NLGAES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_BARAES" )) .or. !Empty(( cAlias )->&( cAlias + "_CEPAES" )) .or.;
			!Empty(( cAlias )->&( cAlias + "_MUNAES" )) .or. !Empty(( cAlias )->&( cAlias + "_UFAES"  )) .or.;
			!Empty(( cAlias )->&( cAlias + "_CPFCES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMCES" ))

			cXml += "<infoEstagiario>"
			cXml +=	xTafTag("natEstagio"	, (cAlias)->&(cAlias + "_NATEES"),, .F.							)
			cXml +=	xTafTag("nivEstagio"	, (cAlias)->&(cAlias + "_NIVEES"),, IIf(lLaySimplif, .T., .F.)	)
			cXml +=	xTafTag("areaAtuacao"	, (cAlias)->&(cAlias + "_AREAES"),, .T.							)
			cXml +=	xTafTag("nrApol"		, (cAlias)->&(cAlias + "_NRAPES"),, .T.							)

			If !lLaySimplif
				If ( cAlias )->&( cAlias + "_VLBLES" ) > 0
					cXml +=					xTafTag( "vlrBolsa", 	( cAlias )->&( cAlias + "_VLBLES" ), PesqPict( cAlias, cAlias + "_VLBLES" ),,.T.,.T.) //ALTERADO PARA GERAR A TAG COM VALOR ZERADO
				EndIf
			EndIf

			cXml += xTafTag("dtPrevTerm", (cAlias)->&(cAlias + "_DTTEES"),, .F.)

			//************************************
			//instEnsino
			//************************************
				cXml +=					"<instEnsino>"
				cXml +=						xTafTag( "cnpjInstEnsino",     ( cAlias )->&( cAlias + "_CNPEES" ),,.T.)
				If ( lLaySimplif .And. Empty(( cAlias )->&( cAlias + "_CNPEES" )) ) .Or. !lLaySimplif
					cXml +=						xTafTag( "nmRazao",   FwCutOff(( cAlias )->&( cAlias + "_NOMEES" ), .T.),,.F.)
					cXml +=						xTafTag( "dscLograd", FwCutOff(( cAlias )->&( cAlias + "_LOGEES" ), .T.),,.T.)
					cXml +=						xTafTag( "nrLograd",           ( cAlias )->&( cAlias + "_NLGEES" ),,.T.)
					cXml +=						xTafTag( "bairro",    FwCutOff(( cAlias )->&( cAlias + "_BAREES" ), .T.),,.T.)
				EndIf
				cXml +=						xTafTag( "cep",                ( cAlias )->&( cAlias + "_CEPES"  ),,.T.)
				If C09->(MsSeek(xFilial("C09") + (cAlias)->&( cAlias + "_UFES" )))
					If C07->(MsSeek(xFilial("C07") + (cAlias)->&( cAlias + "_MUNES" )))
						cXml +=	xTafTag("codMunic",C09->C09_CODIGO+C07->C07_CODIGO,,.T.)
					EndIf
					cXml +=	xTafTag("uf",C09->C09_UF,,.T.)
				EndIf
				cXml +=					"</instEnsino>"
			//-------------------------------------

			//************************************
			//ageIntegracao
			//************************************
			If	!Empty(( cAlias )->&( cAlias + "_CNPAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMAES" )) .or.;
				!Empty(( cAlias )->&( cAlias + "_LOGAES" )) .or. !Empty(( cAlias )->&( cAlias + "_NLGAES" )) .or.;
				!Empty(( cAlias )->&( cAlias + "_BARAES" )) .or. !Empty(( cAlias )->&( cAlias + "_CEPAES" )) .or.;
				!Empty(( cAlias )->&( cAlias + "_MUNAES" )) .or. !Empty(( cAlias )->&( cAlias + "_UFAES"  ))
				cXml +=			"<ageIntegracao>"
				cXml +=				xTafTag( "cnpjAgntInteg", 	   ( cAlias )->&( cAlias + "_CNPAES" ),,.F.)
				If !lLaySimplif
					cXml +=				xTafTag( "nmRazao",	 FwCutOff(( cAlias )->&( cAlias + "_NOMAES" ), .T.) ,,.F.)
					cXml +=				xTafTag( "dscLograd", FwCutOff(( cAlias )->&( cAlias + "_LOGAES" ), .T.) ,,.F.)
					cXml +=				xTafTag( "nrLograd",           ( cAlias )->&( cAlias + "_NLGAES" ),,.F.)
					cXml +=				xTafTag( "bairro", 	 FwCutOff(( cAlias )->&( cAlias + "_BARAES" ), .T.),,.T. )
					cXml +=				xTafTag( "cep",                ( cAlias )->&( cAlias + "_CEPAES" ),,.F.)
					If C09->(MsSeek(xFilial("C09") + (cAlias)->&( cAlias + "_UFAES" )))
						If C07->(MsSeek(xFilial("C07") + (cAlias)->&( cAlias + "_MUNAES" )))
							cXml +=	xTafTag("codMunic",C09->C09_CODIGO+C07->C07_CODIGO,,.T.)
						EndIf
						cXml +=	xTafTag("uf",C09->C09_UF)
					EndIf
				EndIf
				cXml +=			"</ageIntegracao>"
			EndIf
			//-----------------------------------

			//************************************
			//ageIntegracao
			//************************************
			If !Empty(( cAlias )->&( cAlias + "_CPFCES" )) .or. !Empty(( cAlias )->&( cAlias + "_NOMCES" ))
				cXml +=			"<supervisorEstagio>"
				cXml +=				xTafTag( "cpfSupervisor",     ( cAlias )->&( cAlias + "_CPFCES" ),,.F.)
				If !lLaySimplif
					cXml +=				xTafTag( "nmSuperv", FwCutOff(( cAlias )->&( cAlias + "_NOMCES" ), .T.),.F.)
				EndIf
				cXml +=			"</supervisorEstagio>"
			EndIf
			//------------------------------------

			cXml += 		"</infoEstagiario>"
		EndIf
	//------------------------------------
		cXml += 	"</infoComplementares>"
	EndIf

	If cLayout == "2300" .And. TafColumnPos(cAlias + "_MATANT") .And. lLaySimplif
		
		xTafTagGroup("mudancaCPF"   ,{;
		{"cpfAnt"	    ,(cAlias)->&( cAlias + "_CPFANT")														,,.F.},;
		{"matricAnt"    ,(cAlias)->&( cAlias + "_MATANT")														,,.F.},; 
		{"dtAltCPF"     ,(cAlias)->&( cAlias + "_DALCPF")														,,.F.},;
		{"observacao"   ,(cAlias)->&( cAlias + "_OBSCPF")														,,.T.}};
		, @cXml)

	ElseIf cLayout == "2300" .And. !lLaySimplif

		xTafTagGroup("mudancaCPF"   ,{;
		{"cpfAnt"	    ,(cAlias)->&( cAlias + "_CPFANT")														,,.F.},;
		{"dtAltCPF"     ,(cAlias)->&( cAlias + "_DALCPF")														,,.F.},;
		{"observacao"   ,(cAlias)->&( cAlias + "_OBSCPF")														,,.T.}};
		, @cXml)
		
	EndIf

	If cLayout == "2300" .And. C9V->C9V_CADINI == "1"
		//************************************
		//afastamento
		//************************************
		If !Empty(( cAlias )->&( cAlias + "_DTINIA" )) .And. !Empty(( cAlias )->&( cAlias + "_MOTVAF" )) .And. Empty(( cAlias )->&( cAlias + "_DTTERM" ))

			cXml +=			"<afastamento>"

			cXml +=				xTafTag( "dtIniAfast", ( cAlias )->&( cAlias + "_DTINIA" ),,.F.)

			If C8N->(MsSeek(xFilial("C8N") + (cAlias)->&( cAlias + "_MOTVAF" )))
				cXml +=	xTafTag("codMotAfast",C8N->C8N_CODIGO,,.F.)
			EndIf

			cXml +=			"</afastamento>"
		EndIf		

		

		//************************************
		//termino
		//************************************

		If !Empty(( cAlias )->&( cAlias + "_DTTERM" ))
			cXml +=			"<termino>"
			cXml +=				xTafTag( "dtTerm", ( cAlias )->&( cAlias + "_DTTERM" ),,.F.)
			cXml +=			"</termino>"
		EndIf
	Endif    

	If cLayout == "2300"
		cXml += "</infoTSVInicio>"
	Elseif cLayout == "2306"
		cXml += "</infoTSVAlteracao>"
	EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelC9V - Model da tabela C9V
oModelT3T - Model da tabela T3T
aGrava    - Array que armazena as informações da tabela C9V
aGravaT3T - Array que armazena as informações da tabela T3T

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF279Carr( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU )
Local nI := 0

//=========================++
// Dados do Trabalhador	   ||
//=========================++
For nI := 1 to Len( oModelC9V:aDataModel[1] )
	aAdd( aGrava, { oModelC9V:aDataModel[1,nI,1], oModelC9V:aDataModel[1,nI,2] } )
Next nI

//=========================++
// Dependentes			   ||
//=========================++	
For nI := 1 to oModel:GetModel( "MODEL_T2F" ):Length()
	oModel:GetModel( "MODEL_T2F" ):GoLine( nI )
	
	If !oModel:GetModel( 'MODEL_T2F' ):IsEmpty()
		If !oModel:GetModel( "MODEL_T2F" ):IsDeleted()
			aAdd(aGravaT2F,{oModelT2F:GetValue( "T2F_IDDEP" ),;
                oModelT2F:GetValue( "T2F_TPDEP" ),;
                oModelT2F:GetValue( "T2F_NOMDEP" ),;
                oModelT2F:GetValue( "T2F_DTNASC" ),;
                oModelT2F:GetValue( "T2F_CPFDEP" ),;
                oModelT2F:GetValue( "T2F_DEPIRF" ),;
					oModelT2F:GetValue( "T2F_DEPSFA" ),;
					oModelT2F:GetValue( "T2F_INCTRB" )})
			EndIf
		EndIf
	Next nI

//=========================++
// Trabalhador Sem Vínculo ||
//=========================++
For nI := 1 to Len( oModelCUU:aDataModel[1] )
	aAdd( aGravaCUU, { oModelCUU:aDataModel[1,nI,1], oModelCUU:aDataModel[1,nI,2] } )
Next nI

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelC9V - Model da tabela C9V
oModelT2F - Model da tabela T2F
aGrava    - Array que armazena as informações da tabela C9V
aGravaT2F - Array que armazena as informações da tabela T2F
lInclusao - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF279Comm( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU, lExclu )

	Local cVersao    := ""
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cEvento    := ""
	Local nI         := 0

	Default lExclu   := .F.

	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()
		
	/*----------------------------------------------------------
	Neste momento eu realizo a gravação de um novo registro idêntico
	ao original, apenas com as alterações nos campos modificados
	pelo usuário no cadastro
	-----------------------------------------------------------*/			
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_C9V", aGrava[nI,1], aGrava[nI,2] )
	Next nI

	//***********
	//Dependentes
	//***********				
	For nI := 1 to Len( aGravaT2F )

		If nI > 1
			oModel:GetModel( "MODEL_T2F" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T2F", "T2F_IDDEP" , aGravaT2F[nI,1] )
		oModel:LoadValue( "MODEL_T2F", "T2F_TPDEP" , aGravaT2F[nI,2] )
		oModel:LoadValue( "MODEL_T2F", "T2F_NOMDEP", aGravaT2F[nI,3] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DTNASC", aGravaT2F[nI,4] )
		oModel:LoadValue( "MODEL_T2F", "T2F_CPFDEP", aGravaT2F[nI,5] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPIRF", aGravaT2F[nI,6] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPSFA", aGravaT2F[nI,7] )
		oModel:LoadValue( "MODEL_T2F", "T2F_INCTRB", aGravaT2F[nI,8] )

	Next nI

	For nI := 1 to Len( aGravaCUU )
		oModel:LoadValue( "MODEL_CUU", aGravaCUU[nI,1], aGravaCUU[nI,2] )
	Next nI

	//Busco a nova versao do registro
	cVersao := xFunGetVer()

	IF lExclu

		oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "E" )
		oModel:LoadValue( "MODEL_C9V", "C9V_ATIVO", "1" )

	Else

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

		If cEvento == "I"
			oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "A" )
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que 

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

Local cVerAnt    := ""
Local cProtocolo := ""
Local cVersao    := ""
Local cEvento	   := ""
Local cIdTrab    := ""

Local nI         := 0

Local aGrava     := {}
Local aGravaT2F  := {}
Local aGravaCUU  := {}

Local oModelC9V  := Nil
Local oModelT2F  := Nil
Local oModelCUU  := Nil

//Controle se o evento é extemporâneo
lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

Begin Transaction

	//Posiciona o item
	("C9V")->( DBGoTo( nRecno ) )
	cIdTrab   := C9V->C9V_ID
					
	//Carrego a Estrutura dos Models a serem gravados
	oModelC9V := oModel:GetModel( "MODEL_C9V" )
	oModelT2F := oModel:GetModel( "MODEL_T2F" )
	oModelCUU := oModel:GetModel( "MODEL_CUU" )

	//Guardo as informacoes do registro corrente para rastro do registro
	cVerAnt    := oModelC9V:GetValue( "C9V_VERSAO" )
	cProtocolo := oModelC9V:GetValue( "C9V_PROTUL" )
	cEvento    := oModelC9V:GetValue( "C9V_EVENTO" )

	//Armazeno as informacoes correntes do cadastro( Depois da alteracao do Usuario )
	For nI := 1 to Len( oModelC9V:aDataModel[1] )
		aAdd( aGrava, { oModelC9V:aDataModel[1,nI,1], oModelC9V:aDataModel[1,nI,2] } )
	Next nI
	
	For nI := 1 to oModel:GetModel( "MODEL_T2F" ):Length()
		oModel:GetModel( "MODEL_T2F" ):GoLine( nI )
	
		If !oModel:GetModel( 'MODEL_T2F' ):IsEmpty()
			If !oModel:GetModel( "MODEL_T2F" ):IsDeleted()
				aAdd(aGravaT2F,{oModelT2F:GetValue( "T2F_IDDEP" ),;
				                oModelT2F:GetValue( "T2F_TPDEP" ),;
				                oModelT2F:GetValue( "T2F_NOMDEP" ),;
				                oModelT2F:GetValue( "T2F_DTNASC" ),;
				                oModelT2F:GetValue( "T2F_CPFDEP" ),;
				                oModelT2F:GetValue( "T2F_DEPIRF" ),;
				                oModelT2F:GetValue( "T2F_DEPSFA" )})
			EndIf
		EndIf
	Next nI

	For nI := 1 to Len( oModelCUU:aDataModel[1] )
		aAdd( aGravaCUU, { oModelCUU:aDataModel[1,nI,1], oModelCUU:aDataModel[1,nI,2] } )
	Next nI

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
	operacao de inclusao para o novo registro
	-----------------------------------------------------------*/
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	/*----------------------------------------------------------
	Neste momento eu realizo a gravacao de um novo registro
	identico ao original, apenas com as alteracoes nos campos
	modificados pelo usuario no cadastro
	-----------------------------------------------------------*/
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_C9V", aGrava[nI,1], aGrava[nI,2] )
	Next nI
		
	For nI := 1 to Len( aGravaT2F )
		If nI > 1
			oModel:GetModel( "MODEL_T2F" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T2F", "T2F_IDDEP" , aGravaT2F[nI,1] )
		oModel:LoadValue( "MODEL_T2F", "T2F_TPDEP" , aGravaT2F[nI,2] )
		oModel:LoadValue( "MODEL_T2F", "T2F_NOMDEP", aGravaT2F[nI,3] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DTNASC", aGravaT2F[nI,4] )
		oModel:LoadValue( "MODEL_T2F", "T2F_CPFDEP", aGravaT2F[nI,5] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPIRF", aGravaT2F[nI,6] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPSFA", aGravaT2F[nI,7] )
	Next nI

	For nI := 1 to Len( aGravaCUU )
		oModel:LoadValue( "MODEL_CUU", aGravaCUU[nI,1], aGravaCUU[nI,2] )
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
	oModel:LoadValue( "MODEL_C9V", "C9V_PROTUL", "" )
	
	/*---------------------------------------------------------
	Tratamento para que caso o Evento Anterior fosse de exclusão
	seta-se o novo evento como uma "nova inclusão", caso contrário o
	evento passar a ser uma alteração
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_C9V", "C9V_EVENTO", "E" )
	oModel:LoadValue( "MODEL_C9V", "C9V_ATIVO", "1" )
	
	//Gravo alteração para o Extemporâneo
	If lGoExtemp
		TafGrvExt( oModel, 'MODEL_C9V', 'C9V' )
	EndIf
	
	FwFormCommit( oModel )
	TAFAltStat( 'C9V',"6" )
	
End Transaction

Return ( .T. )


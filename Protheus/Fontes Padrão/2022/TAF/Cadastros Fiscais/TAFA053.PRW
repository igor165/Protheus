#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA053.CH"

STATIC aCmpsAlts	:=	{}

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA050
Cadastro de Participante
Controle de Alteração do Participante

@author Marcio Nunes
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA053
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Participante
oBrw:SetAlias( 'C1H')
oBrw:SetMenuDef( 'TAFA053' )  
oBrw:SetCacheView(.F.)
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf053Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA053" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local 	oStruC1H	:= 	FWFormStruct( 1, 'C1H' )
Local 	oStruC1I	:= 	FWFormStruct( 1, 'C1I' )
Local   oStruV3R	:=	Nil
Local 	oModel 		:= MPFormModel():New( 'TAFA053' , , , {|oModel| SaveModel( oModel ) } )
Local lVer20		 := .F. //Campos que pertencem ao layout 2.0 da REINF

If FWAliasInDic("V3R")
	oStruV3R	:= 	FWFormStruct( 1, 'V3R' )
	lVer20 = .T.
EndIf 

aCmpsAlts	:=	{} 

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruC1H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf 

oModel:AddFields('MODEL_C1H', /*cOwner*/, oStruC1H)
oModel:AddGrid  ('MODEL_C1I', 'MODEL_C1H', oStruC1I)  

if lVer20
	oModel:AddGrid  ('MODEL_V3R', 'MODEL_C1H', oStruV3R)  
	oModel:GetModel ('MODEL_V3R'):SetOptional( .T. )
	oModel:GetModel( 'MODEL_V3R' ):SetUniqueLine( { 'V3R_CODIGO'} )
EndIf
  
oModel:GetModel ('MODEL_C1I'):SetOptional( .T. )
oModel:GetModel( 'MODEL_C1I' ):SetUniqueLine( { 'C1I_DTALT', 'C1I_HRALT' , 'C1I_NRCAMP'} )

oModel:SetRelation( 'MODEL_C1I', { { 'C1I_FILIAL', 'xFilial( "C1I" )' } , { 'C1I_ID' , "C1H_ID" } }, C1I->( IndexKey( 1 ) ) )

if lVer20
	oModel:SetRelation( 'MODEL_V3R', { { 'V3R_FILIAL', 'xFilial( "V3R" )' } , { 'V3R_ID' , "C1H_ID" } }, V3R->( IndexKey( 1 ) ) )
EndIf

oModel:GetModel('MODEL_C1H'):SetPrimaryKey( { "C1H_CODPAR" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 		:= 	FWLoadModel( 'TAFA053' )
	Local oStruC1Ha 	:= 	Nil
	Local oStruC1Hb 	:= 	Nil
	Local oStruC1Hc 	:= 	Nil
	Local oStruC1I 		:= 	FWFormStruct( 2, 'C1I' )
	Local oStruV3R 		:=	Nil
	Local oView 		:= 	FWFormView():New()
	Local cCmpsGeral	:= ""
	Local cCmpsExt		:= ""
	Local cCmpsReinf	:= ""	
	Local aCmpC1Ha		:= {}
	Local nI			:= 0
	Local lVer20    	:= .F. //Campos que pertencem ao layout 2.0 da REINF

	If TAFAlsInDic("V3R")
		oStruV3R 	:= 	FWFormStruct( 2, 'V3R' )
		oStruV3R:RemoveField('V3R_ID')
		oStruV3R:RemoveField('V3R_CREDEP')
		lVer20 = .T.
	EndIf

	cCmpsExt 	:= "C1H_PAISEX|C1H_DPAISE|C1H_LOGEXT|C1H_NUMEXT|C1H_COMEXT|C1H_BAIEXT|C1H_NMCEXT|C1H_CDPOSE|"
	If lVer20
		cCmpsExt += "C1H_ESTEXT|C1H_TELEXT|C1H_INDNIF|C1H_NIF|C1H_FRMTRI|C1H_DFTRIB|"
	Endif

	If TAFColumnPos("C1H_PAA")
		cCmpsReinf	:= "C1H_DTMOLE|C1H_RELFON|C1H_DFONTP|C1H_CPRB|C1H_PAA|C1H_INDDES|"
	Else 
		cCmpsReinf	:= "C1H_DTMOLE|C1H_RELFON|C1H_DFONTP|"
	EndIf 
	
	aCmpC1Ha := xFunGetSX3("C1H","",.T.) //,cCmpsExt+cCmpsReinf,.T.)
	
	For nI := 1 To Len(aCmpC1Ha)
		If ! (Alltrim(aCmpC1Ha[nI][2]) $ cCmpsExt .Or. Alltrim(aCmpC1Ha[nI][2]) $ cCmpsReinf)
			cCmpsGeral += AllTrim(aCmpC1Ha[nI][2]) + "|"
		EndIf
	Next nI
	
	oStruC1Ha := FwFormStruct(2,"C1H",{|x|AllTrim(x) + "|" $ cCmpsGeral})
	oStruC1Hb := FwFormStruct(2,"C1H",{|x|AllTrim(x) + "|" $ cCmpsExt})
	oStruC1Hc := FwFormStruct(2,"C1H",{|x|AllTrim(x) + "|" $ cCmpsReinf})
	
	oStruC1Ha:RemoveField('C1H_IDATV')

	oView:SetModel(oModel)
	oView:AddField('VIEW_C1Ha',oStruC1Ha,"MODEL_C1H")
	oView:AddField('VIEW_C1Hb',oStruC1Hb,"MODEL_C1H")
	oView:AddField('VIEW_C1Hc',oStruC1Hc,"MODEL_C1H")
	
	oView:AddGrid ('VIEW_C1I', oStruC1I, 'MODEL_C1I')
	oView:EnableTitleView( 'VIEW_C1I', STR0002 ) //Controle de Alteração do Participante

	If lVer20
		oView:AddGrid ('VIEW_V3R', oStruV3R, 'MODEL_V3R')
		oView:EnableTitleView( 'VIEW_V3R', "Dependentes" ) 
		oStruC1Ha:RemoveField('C1H_IDTRIB')
	EndIF	

	oView:CreateHorizontalBox( 'FIELDSC1H', 65 )
	oView:CreateFolder("FOLDER_SUPERIOR","FIELDSC1H") 

	oView:AddSheet("FOLDER_SUPERIOR","ABA01",STR0004) //"Informações Gerais"
	oView:CreateHorizontalBox("FOLDER01",100,,,"FOLDER_SUPERIOR","ABA01")

	oView:AddSheet("FOLDER_SUPERIOR","ABA02",STR0005) //"Informações Residentes/Domiciliados no Exterior"
	oView:CreateHorizontalBox("FOLDER02",100,,,"FOLDER_SUPERIOR","ABA02")

	oView:AddSheet("FOLDER_SUPERIOR","ABA03",STR0006) //"Informações REINF"
	oView:CreateHorizontalBox("FOLDER03",100,,,"FOLDER_SUPERIOR","ABA03")

	If !lVer20
		oView:CreateHorizontalBox( 'GRIDC1I', 35 )	
	Else
		oView:CreateHorizontalBox( 'FOLDER', 35 )
		oView:CreateFolder("FOLDER_INFERIOR","FOLDER")

		oView:AddSheet("FOLDER_INFERIOR","ABA01", STR0010)//"Histórico" 
		oView:CreateHorizontalBox("FOLDER04",100,,,"FOLDER_INFERIOR","ABA01")
	
		oView:AddSheet("FOLDER_INFERIOR","ABA02", STR0011) //"Dependentes" 
		oView:CreateHorizontalBox("FOLDER05",100,,,"FOLDER_INFERIOR","ABA02")
	EndIf	

	oView:SetOwnerView("VIEW_C1Ha","FOLDER01")
	oView:SetOwnerView("VIEW_C1Hb","FOLDER02")  
	oView:SetOwnerView("VIEW_C1Hc","FOLDER03")  
		
	If !lVer20
		oView:SetOwnerView("VIEW_C1I", "GRIDC1I")
	Else
		oView:SetOwnerView("VIEW_C1I", "FOLDER04")
		oView:SetOwnerView("VIEW_V3R", "FOLDER05")
	EndIf	
	oView:SetContinuousForm(.T.)

	If TamSX3("C1H_ID")[1] == 36
		oStruC1Ha:RemoveField("C1H_ID")				
	EndIf  

Return oView

//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation 	:= oModel:GetOperation()
Local nI        	:= 0  
Local nX			:= 0
Local nlY        	:= 0
Local nCmpAnt		:= 0
Local nC1I  	 	:= 0
Local nPos			:= 0
Local nC1I			:= 0

Local cNumCpo    	:= ""
Local cCTDAnt    	:= ""
Local clAlias		:= "C1H"
Local cUsoCmp		:= ""
Local cExclCmp	:= ""
Local cContPos	:= ""

Local aGravaC1I  	:= {}
Local aC1H		 	:= {}
Local aC1HMemo	:= {}
Local aCmpC1H 	:= {}
Local aC1H			:= {}

Local oModelC1H  := Nil
Local oModelC1I  := Nil


Begin Transaction

If nOperation == MODEL_OPERATION_UPDATE
	
	//Carrego a Estrutura dos Models a serem gravados
	
	oModelC1I := oModel:GetModel( "MODEL_C1I" )
	oModelC1H := oModel:GetModel( "MODEL_C1H" )

	/*+------------------------------------------------------+
	  | Data:28.08.2014	     	                 				 |
	  | Responsável: Evandro dos Santos Oliveira             |
	  | Descrição da Alteração: Grava campos modificados na  |
	  | tabela C1H (histórico)			   	 	 				 |				
	  +------------------------------------------------------+*/ 	
	nPosId := aScan(oModelC1H:aDataModel[1],{|x|AllTrim(x[1]) == "C1H_ID"})
	
	DBSelectArea(clAlias)
	DBSetOrder(5)
	If C1H->(MsSeek(xFilial("C1H")+(oModelC1H:aDataModel[ 1, nPosId , 2 ]) ) ) 

		cExclCmp := "C1H_FILIAL|C1H_ID" 
		aCmpC1H := xFunGetSX3(clAlias, cExclCmp,.F.)
		
		aEval(aCmpC1H,{|x|IIf(!(AllTrim(x[2]) $ cExclCmp);
		,(aAdd(aC1H,{x[2],(clAlias)->&(x[2])}),cUsoCmp += AllTrim(x[2]) + "|"),.F.)})
	
	EndIf
	
	aEval(oModelC1H:aDataModel[1],{|mdC1H| IIf(!(mdC1H[1] $ cExclCmp) .And. (mdC1H[1] $ cUsoCmp);
	,aAdd(aC1HMemo,mdC1H[2]),.F.)})
	
	nCmpAnt := oModel:GetModel( "MODEL_C1I" ):Length()
	
	For nI := 1 to Len(aC1H)
		If aC1H[nI][2] <> aC1HMemo[nI]
		
			cNumCpo := Posicione("C1R",4,xFilial("C1R")+Alltrim(Substr((aC1H[nI][1]),5,6)),"C1R_ID")
			
			if AllTrim(cNumCpo) != ""
				cCTDAnt := TAFRtCmp(aC1H[nI][2],aC1H[nI][1])
				aAdd(aGravaC1I,{	Date() 	,;
									Time()		,;
									cNumCpo 	,;
									cCTDAnt	,;
									aC1H[nI][1]})
			endif							
		EndIf
	Next

	For nC1I := 1 to Len( aGravaC1I )
	
		If (nCmpAnt == 1 .And. !Empty(oModel:GetValue( "MODEL_C1I","C1I_DTALT"))) .Or.;
		   (nCmpAnt > 1)
		   
			oModel:GetModel( 'MODEL_C1I' ):lValid	:= .T.
			oModel:GetModel( "MODEL_C1I" ):AddLine()  
		EndIf
		
		If !Empty(aGravaC1I[nC1I][1])
			
			oModel:LoadValue( "MODEL_C1I", "C1I_DTALT"  , aGravaC1I[nC1I][1] )
			oModel:LoadValue( "MODEL_C1I", "C1I_HRALT"  , aGravaC1I[nC1I][2] ) 
			oModel:LoadValue( "MODEL_C1I", "C1I_NRCAMP" , aGravaC1I[nC1I][3] )
			oModel:LoadValue( "MODEL_C1I", "C1I_CTDANT" , aGravaC1I[nC1I][4] )
			
		EndIf
		
	Next 
	
	TAFAltStat( "C1H", " " )
	
EndIf

FwFormCommit( oModel )

End Transaction


Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRtCmp (Função Auxiliar)
Converte valores de outros tipo em caracter

@param  xPar	  - Conteudo do Campo
@return cCTDAnt - Conteudo normalizado

@author Evandro dos Santos Oliveira
@since 12/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFRtCmp(xPar,cCampo)

	Local cCTDAnt := ""

	If Type(cCampo) == "C"
	
		cCTDAnt  := AllTrim(xPar)
				
	If cCTDAnt == ""
			cCTDAnt := "Campo sem conteúdo / Vazio" // Incluir Define !!!
		EndIf
	ElseIf Type(cCampo) == "N"
		cCTDAnt := AllTrim(Str(xPar))
	ElseIf Type(cCampo) == "D"
		cCTDAnt := DTOC(xPar)
	ElseIf Type(cCampo) == "L"
		cCTDAnt := IIf (xPar,".T.",".F.")
	Else
		cCTDAnt := xPar
	EndIf

Return (cCTDAnt)
		
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF053Vld
	
Validacao dos dados do registro posicionado, verificando inconsistencias
nas informacos caso seja necessario gerar um XML
		
@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Job / Aplicacao
		
@Return:
		
@author Denis R. de Oliveira
@since 14/02/2014
@version 1.0
		
/*/
//------------------------------------------------------------------
Function TAF053Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cPeriodo := ""

Default lJob   := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1H->( Recno() )

If ( C1H->C1H_STATUS $ ( " |1" ) )
	
	//Valida o Codigo do Participante
	If Empty(C1H->C1H_CODPAR)
		Aadd( aLogErro, { "C1H_CODPAR", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Tipo de Pessoa
	If Empty(C1H->C1H_PPES)
		Aadd( aLogErro, { "C1H_PPES", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
	Else
		
		If !(C1H->C1H_PPES $ ("1|2"))
			AADD(aLogErro,{"C1H_PPES","000006","C1H", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIF
		
	EndIf
	
	//Valida o Nome
	If Empty(C1H->C1H_NOME)
		Aadd( aLogErro, { "C1H_NOME", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Endereço
	If Empty(C1H->C1H_END)
		Aadd( aLogErro, { "C1H_END", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Tipo de Logradouro
	If !Empty(C1H->C1H_TPLOGR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C1H->C1H_TPLOGR
		xValRegTab("C06",cChave,3,,@aLogErro,,{ "C1H", "C1H_TPLOGR", nRecno } )
		
		cTpLogr:= Alltrim(Posicione("C06",3,xFilial("C06")+C1H->C1H_TPLOGR,"C06_CODIGO"))
		
		If !(cTpLogr $ ("01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|99"))
			AADD(aLogErro,{"C1H_TPLOGR","000006","C1H", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
		
	EndIf
	
	//Valida o Tipo de Bairro
	If Empty(C1H->C1H_TPBAIR)
	
		// Demetrio - 18/08/2014 
		// Retirada a validação pois  este campo não é obrigatório no Layout TOTVS
		//Aadd( aLogErro, { "C1H_TPBAIR", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
	Else
		If !Empty(C1H->C1H_TPBAIR)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1H->C1H_TPBAIR
			xValRegTab("C86",cChave,1,,@aLogErro,, { "C1H", "C1H_TPBAIR", nRecno } )
			
			cTpBair:= Alltrim(Posicione("C86",1,xFilial("C86")+C1H->C1H_TPBAIR,"C86_CODIGO"))
			
			If !(cTpBair $ ("01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|99"))
				AADD(aLogErro,{"C1H_TPBAIR","000006","C1H", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis
			EndIf
			
		EndIF
		
	EndIf
	
	//Valida o Pais
	If Empty(C1H->C1H_CODPAI)
		Aadd( aLogErro, { "C1H_CODPAI", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
	Else
		If !Empty(C1H->C1H_CODPAI)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1H->C1H_CODPAI
			xValRegTab("C08",cChave,3,,@aLogErro,, { "C1H", "C1H_CODPAI", nRecno } )
		EndIf
	EndIf
	
	//Valida o UF
	If Empty(C1H->C1H_UF)
		Aadd( aLogErro, { "C1H_UF", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
	Else
		If !Empty(C1H->C1H_UF)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1H->C1H_UF
			xValRegTab("C09",cChave,3,,@aLogErro,,{ "C1H", "C1H_UF", nRecno } )
		EndIf
	EndIf
	
	//Valida o Municipio
	If Empty(C1H->C1H_CODMUN)
		Aadd( aLogErro, { "C1H_CODMUN", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
		
	Else
		If !Empty(C1H->C1H_CODMUN)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1H->C1H_CODMUN
			xValRegTab("C07",cChave,3,,@aLogErro,, { "C1H", "C1H_CODMUN", nRecno } )
		EndIf
	EndIf
	
	//Inscrição Estadual
	If !Empty(C1H->C1H_IE)
		If !XFUNVldIE(C1H->C1H_IE,C1H->C1H_UF,.F.)
			Aadd( aLogErro, { "C1H_IE", "000517","C1H", nRecno } ) //000517 - Inscrição Estadual Inválida
		EndIf
	EndIf
	
	//Validacao do campo CNPJ/CPF, dependendo do Tipo de Participante. PJ habilita o CNPJ, Fisica o CPF.
	If !Empty(C1H->C1H_PPES)
		
		cCodPais:= Alltrim(Posicione("C08",3,xFilial("C08")+C1H->C1H_CODPAI,"C08_CODIGO"))
		
		If (cCodPais == '01058') .OR. (cCodPais == '1058') //Para Exterior nao faco validacao
			
			If 	C1H->C1H_PPES=="1"
				
				If Empty(C1H->C1H_CPF) .Or. Len(AllTrim(C1H->C1H_CPF)) <> 11 .Or. !CGC(AllTrim(C1H->C1H_CPF),,.F.)
					aAdd(aLogErro,{'C1H_CPF','000005','C1H',nRecno}) 		//STR0005 - Campo CPF Vazio ou Inválido
				EndIf
				
			EndIf
			
			If	C1H->C1H_PPES=="2"
				
				If Empty(C1H->C1H_CNPJ) .Or. Len(AllTrim(C1H->C1H_CNPJ)) <> 14 .Or. !CGC(AllTrim(C1H->C1H_CNPJ),,.F.)
					aAdd(aLogErro,{'C1H_CNPJ','000005','C1H',nRecno})		//STR0005 - Campo CNPJ Vazio ou Inválido
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	cDtIni:= Posicione("C1E",3,xFilial("C1E")+Alltrim(SM0->M0_CODFIL)+"1","C1E_DTINI")//Recebe o Periodo Inicial da Validade do complemento de empresa
	cDtFin:= Posicione("C1E",3,xFilial("C1E")+Alltrim(SM0->M0_CODFIL)+"1","C1E_DTFIN")//Recebe o Periodo Final da Validade do complemento de empresa
	
	//-----------------------------------------------------//
	/* Valida a Grid Controle de alteração do participante */
	//-----------------------------------------------------//
	dbSelectArea("C1I")
	C1I->(dbSetORder(1))
	If C1I->(MsSeek(xFilial("C1I") + C1H->C1H_ID))
		cId:=C1I->C1I_ID
		While (!C1I->(Eof()) .And. cId==C1I->C1I_ID)
			
			//Valida o Numero do Campo Alterado
			If Empty(C1I->C1I_NRCAMP)
				Aadd( aLogErro, { "C1I_NRCAMP","000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			Else
				
				If !Empty(C1I->C1I_NRCAMP)
					//Chave de busca na tabela FILHO ou Consulta padrao
					cChave := C1I->C1I_NRCAMP
					xValRegTab("C1R",cChave,3,,@aLogErro,, { "C1H", "C1I_NRCAMP", nRecno } )
				EndIf
			EndIf
			
			//Valida a Data da Alteracao
			If Empty(C1I->C1I_DTALT)
				Aadd( aLogErro, { "C1I_DTALT","000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			Else
				
				/*RETIRADO POIS NAO TEM SENTIDO ESSE TRATAMENTO DO E-SOCIAL NO CADASTRO DE PARTICIPANTE QUE
				//ATENDE O ESCOPO FISCAL
				cPeriodo:=Substr(DTOC(C1I->C1I_DTALT),4,2)
				cPeriodo+=Substr(DTOC(C1I->C1I_DTALT),7,4)
				
				If (Substr(cPeriodo,3,4) < Substr(cDtIni,3,4)) .Or. (Substr(cPeriodo,3,4) > Substr(cDtFin,3,4))
					AADD(aLogErro,{"C1I_DTALT","000518","C1H", nRecno }) //STR0518 - "O valor informado no campo deve estar entre o período inicial da validade e o período final da validade do compl. empresa" 
				EndIf
				
				If Substr(cPeriodo,3,4) == Substr(cDtIni,3,4)
					If (Left(cPeriodo,2) < Left(cDtIni,2))
						AADD(aLogErro,{"C1I_DTALT","000518","C1H", nRecno }) //STR0518 - "O valor informado no campo deve estar entre o período inicial da validade e o período final da validade do compl. empresa"
					EndIf
				EndIf
				
				If Substr(cPeriodo,3,4) == Substr(cDtFin,3,4)
					If (Left(cPeriodo,2) > Left(cDtFin,2))
						AADD(aLogErro,{"C1I_DTALT","000518","C1H", nRecno }) //STR0518 - "O valor informado no campo deve estar entre o período inicial da validade e o período final da validade do compl. empresa"
					EndIf
				EndIf
				*/
			EndIf
			
			//Valida o Conteudo Anterior
			If Empty(C1I->C1I_CTDANT)
				Aadd( aLogErro, { "C1I_CTDANT", "000010", "C1H", nRecno } ) //000010 - Campo Inconsistente ou Vazio
			EndIf			
			C1I->(dbSkip())
		Enddo
	Endif
	
	
	//Atualizo o Status do Registro
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C1H",.F.)
			C1H->C1H_STATUS := "1"
		C1H->( MsUnlock() )
	Else
		RecLock("C1H",.F.)
			C1H->C1H_STATUS := "0"
		C1H->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"C1H_ID","000305", "C1H", nRecno })
	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validacao de alguns campos do model.

@param  oModel - parametro com o Model MVC 

@return lRet - Flag de validacao, onde .T. eh valido e .F. NAO valido

@author Fabio V santana
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ValidModel( oModel )
Local	lRet		:=	.T.
Local	cPJPF 		:= 	oModel:GetValue( 'MODEL_C1H' , 'C1H_PPES' )
Local	cCNPJ 		:= 	oModel:GetValue( 'MODEL_C1H' , 'C1H_CNPJ' )
Local	cCPF 		:= 	oModel:GetValue( 'MODEL_C1H' , 'C1H_CPF' )
Local 	nOperation 	:= 	oModel:GetOperation()

cCodPais:= Alltrim(Posicione("C08",3,xFilial("C08")+C1H->C1H_CODPAI,"C08_CODIGO")) 

If( lRet := XFUNReflex( nOperation , aCmpsAlts , 'TAFA053' ) )
	//Validacao do campo CNPJ/CPF, dependendo do Tipo de Participante. PJ habilita o CNPJ, Fisica o CPF.
	If (cCodPais == '01058') .OR. (cCodPais == '1058') .And.;	//Para Exterior nao faco validacao
		!Empty(cPJPF)
		If 	(cPJPF=="1" .And. Empty(cCPF)) .Or.;
			(cPJPF=="2" .And. Empty(cCNPJ))
			Help( ,,"CNPJOUCPF",,, 1, 0 ) 
			lRet	:=	.F.
		EndIf
	EndIf
EndIf
Return lRet
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} A053LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.
                
@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A053LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.

/*/{Protheus.doc} TAF053Cbox
Função utilizada para montar o combo box do campo C1H_ISEIMU,
porque ultrapassa o limite de caracteres do ATUSX. 
                
@author Katielly Feitosa
@since 14/05/2019
@version 1.0
*/

Function TAF053Cbox( cCampo )

Local cString	:=	""
	cString := "1=" +  STR0007 //Não isenta/não imune;
	cString += "2=" +  STR0008 //"Instituição de educação e de assistência social sem fins lucrativos, a que se refere o art. 12 da Lei nº 9.532, de 10 de dezembro de 1997;"
	cString += "3=" +  STR0009 //"Instituição de caráter filantrópico, recreativo, cultural, científico e às associações civis, a que se refere o art. 15 da Lei nº 9.532, de 1997."
Return( cString )


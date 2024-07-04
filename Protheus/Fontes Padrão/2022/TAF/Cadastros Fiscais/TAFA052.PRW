#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA052.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA052
Cadastro MVC de Contabilistas 

@author Fabio V santana
@since 18/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA052()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Contabilistas"
oBrw:SetAlias( 'C2J')
oBrw:SetMenuDef( 'TAFA052' )
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

Aadd( aFuncao, { "" , "Taf052Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA052" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V santana
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2J 	:= 	FWFormStruct( 1, 'C2J' )
Local oModel  	:= MPFormModel():New( 'TAFA052' , , , {|oModel| SaveModel( oModel ) } )

oStruC2J:SetProperty( "C2J_CPF", MODEL_FIELD_WHEN, {|| IIf(FWFLDGET('C2J_TPESTA') == "2",.F.,.T.) })
oStruC2J:SetProperty( "C2J_CNPJ", MODEL_FIELD_WHEN, {|| IIf(FWFLDGET('C2J_TPESTA') == "1",.F.,.T.) })
 
oModel:AddFields('MODEL_C2J', /*cOwner*/, oStruC2J) 
oModel:GetModel('MODEL_C2J'):SetPrimaryKey( {'C2J_CRC','C2J_CPF','C2J_CNPJ'} ) 

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V santana
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA052' )
Local oStruC2J 	:= 	FWFormStruct( 2, 'C2J' )
Local oView 		:= 	FWFormView():New()

oStruC2J:RemoveField('C2J_ID') //Remove o campo da view
oStruC2J:RemoveField('C2J_IDCODQ') //Remove o campo da view

oView:SetModel( oModel )
oView:AddField( 'VIEW_C2J', oStruC2J, 'MODEL_C2J' )

oView:EnableTitleView( 'VIEW_C2J', STR0001 )	//"Cadastro de Contabilistas"
oView:CreateHorizontalBox( 'FIELDSC2J', 100 )
oView:SetOwnerView( 'VIEW_C2J', 'FIELDSC2J' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "C2J", " " )		
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf052Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF052Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}
Local ni:=0
Local cCodQua		:= "" 
Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C2J->( Recno() )

If C2J->C2J_STATUS $ ( " |1" )
	
	//Valida o Nome
	If Empty(C2J->C2J_NOME)
		Aadd( aLogErro, {"C2J_NOME", "000001", "C2J", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Tipo de Logradouro
	If !Empty(C2J->C2J_TPLOGR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C2J->C2J_TPLOGR
		xVldECFTab("C06",cChave,3,,@aLogErro,{ "C2J", "C2J_TPLOGR", nRecno } )
		
	EndIf 
	
	//Valida o Tipo de Bairro
	If !Empty(C2J->C2J_TPBAIR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C2J->C2J_TPBAIR
		xVldECFTab("C86",cChave,1,,@aLogErro, { "C2J", "C2J_TPBAIR", nRecno } )
	EndIf 
			
	//Valida o UF
	If !Empty(C2J->C2J_UF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C2J->C2J_UF
		xVldECFTab("C09",cChave,3,,@aLogErro, { "C2J", "C2J_UF", nRecno } )
	EndIf
	
	//Valida o Municipio
	If !Empty(C2J->C2J_CODMUN)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C2J->C2J_CODMUN
		xVldECFTab("C07",cChave,3,,@aLogErro, { "C2J", "C2J_CODMUN", nRecno } )
	EndIf
	
	//Valida a Qualificação do Assinante
	If !Empty(C2J->C2J_IDCODQ)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C2J->C2J_IDCODQ
		xVldECFTab("CW4",cChave,1,,@aLogErro,{ "C2J", "C2J_CODQUA", nRecno } )
	EndIf
			
	//"REGRA_VALIDA_CPF_CNPJ"
	If Empty(C2J->C2J_TPESTA)
		Aadd( aLogErro, { "C2J_TPESTA", "000001","C2J", nRecno }) //STR0010 - Campo Inconsistente ou Vazio	
	Else	
		If !(C2J->C2J_TPESTA $ ("1|2"))
			AADD(aLogErro,{"C2J_TPESTA","000002","C2J", nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis"
		Else
			If C2J->C2J_TPESTA == '1'
				If Empty(C2J->C2J_CPF)
					Aadd( aLogErro, {"C2J_CPF", "000001", "C2J", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
				ElseIf Len(AllTrim(C2J->C2J_CPF)) <> 11 .Or. !CGC(C2J->C2J_CPF,,.F.)
					aAdd(aLogErro,{'C2J_CPF','000006','C2J',nRecno }) //STR0006 - CPF/CNPJ Inconsistente
				EndIf
						
			Elseif C2J->C2J_TPESTA == '2'
				If Empty(C2J->C2J_CNPJ)
					Aadd( aLogErro, {"C2J_CNPJ", "000001", "C2J", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
				ElseIf Len(AllTrim(C2J->C2J_CNPJ)) <> 14 .Or. !CGC(C2J->C2J_CNPJ,,.F.)
					aAdd(aLogErro,{'C2J_CNPJ','000006','C2J',nRecno }) //STR0006 - CPF/CNPJ Inconsistente
				EndIf
							
			EndIf
		EndIF
	
	EndIf 
	//"FIM REGRA_VALIDA_CPF_CNPJ"
	
	//Regras para a qualificação do assinante for igual a 900-Contador
	dbSelectArea("C2J")
	C2J->(dbSetOrder(5))   
	cCodQua := Alltrim(Posicione("CW4",1,xFilial("CW4")+C2J->C2J_IDCODQ,"CW4_CODIGO"))
	If cCodQua == "900"  
	
		//"REGRA_OBRIGATORIO_CONTADOR"
		If Empty(C2J->C2J_CRC)
			Aadd( aLogErro, { "C2J_CRC", "000127", "C2J", nRecno }) //STR0127 - "Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo Inscrição Contabilista deve ser preenchido obrigatoriamente."
		Endif	
		//"FIM REGRA_OBRIGATORIO_CONTADOR"
	
		//"REGRA_OBRIGATORIO_CONTADOR"
		//Regra removida do layout 2 do campo C2J_EMAIL, porém como não tem campo de data na tabela C2J, para definir qual layout se trata, a regra foi excluída.
		
		//"FIM REGRA_OBRIGATORIO_CONTADOR"
		
	
		//"REGRA_OBRIGATORIO_CONTADOR"
		If Empty(C2J->C2J_DDD)
			Aadd( aLogErro, { "C2J_DDD", "000129", "C2J", nRecno }) //STR0129 - "Se o campo Qualificação do Assinante for igual a 900 (Contador ou Contabilista), o campo DDD do signatário deve ser preenchido obrigatoriamente."
		EndIf
		//"FIM REGRA_OBRIGATORIO_CONTADOR"
		
		//"REGRA_OBRIGATORIO_CONTADOR"
		//Regra removida do layout 2 campo C2J_FONE, porém como não tem campo de data na tabela C2J, para definir qual layout se trata, a regra foi excluída.

		//"FIM REGRA_OBRIGATORIO_CONTADOR"
		
		//"REGRA_CONTADOR_CPF"
		If Len(C2J->C2J_CPF) <> 11 .OR. !CGC(C2J->C2J_CPF,,.F.) .OR. C2J->C2J_TPESTA <> '1' .OR. !Empty(C2J->C2J_CNPJ) 
			Aadd( aLogErro, { "C2J_CPF", "000146", "C2J", nRecno }) //STR0146 - "Para 'Cod. Qualif' '900' o 'Tipo Estab.' deve ser igual a '1' o CPF deve ser válido e o campo CNPJ não deve ser informado"
		Endif
		//"FIM REGRA_CONTADOR_CPF
	
	Else
		If !Empty(C2J->C2J_CNPJ) .And. !Empty(C2J->C2J_CPF) .And. C2J->C2J_TPESTA == '2'
			Aadd( aLogErro, { "C2J_CNPJ", "000227", "C2J", nRecno }) //STR0227 - "Para 'Tipo Estab.' igual a '2' o CNPJ deve ser  válido e o campo CPF não deve ser informado"     
		Endif
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("C2J",.F.)
			C2J->C2J_STATUS := "1"
		C2J->( MsUnlock() )
	Else
		RecLock("C2J",.F.)
			C2J->C2J_STATUS := "0"
		C2J->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"C2J_ID","000017", "C2J", nRecno })//Registros já validado
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)

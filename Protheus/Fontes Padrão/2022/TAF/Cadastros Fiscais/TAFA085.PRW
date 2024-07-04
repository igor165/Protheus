#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA085.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA085
Cadastro MVC de Movimentacao diaria de combustiveis

@author Fabio V Santana
@since 08/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA085
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Movimentacao diaria de combustiveis
oBrw:SetAlias( 'C4N')
oBrw:SetMenuDef( 'TAFA085' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf085Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA085" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4N 	:= 	FWFormStruct( 1, 'C4N' )
Local oStruC4O 	:= 	FWFormStruct( 1, 'C4O' )
Local oStruC4P 	:= 	FWFormStruct( 1, 'C4P' )

Local oModel		:=	MPFormModel():New('TAFA085',,{ |oModel| ValidModel( oModel ) },{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C4N', /*cOwner*/, oStruC4N)

oModel:AddGrid('MODEL_C4O', 'MODEL_C4N', oStruC4O)
oModel:GetModel( 'MODEL_C4O' ):SetUniqueLine({ 'C4O_NUMTAN'}) 

oModel:AddGrid('MODEL_C4P', 'MODEL_C4O', oStruC4P)
oModel:GetModel( 'MODEL_C4P' ):SetUniqueLine({ 'C4P_NUMBIC','C4P_CNPJ','C4P_CPF'})  

oModel:SetRelation( 'MODEL_C4O' , { { 'C4O_FILIAL' , 'xFilial( "C4O" )' } , { 'C4O_ID' , 'C4N_ID' } } , C4O->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C4O' ):SetOptional( .T. )  

oModel:SetRelation( 'MODEL_C4P' , { { 'C4P_FILIAL' , 'xFilial( "C4P" )' } , { 'C4P_ID' , 'C4N_ID' } , { 'C4P_NUMTAN', 'C4O_NUMTAN' } } , C4P->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C4P' ):SetOptional( .T. )

oModel:GetModel( "MODEL_C4N" ):SetPrimaryKey( { "C4N_CODITE", "C4N_DTFECH" } )                                                                                                                          

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA085' )
Local oStruC4N 	:= 	FWFormStruct( 2, 'C4N' )
Local oStruC4O 	:= 	FWFormStruct( 2, 'C4O' )
Local oStruC4P 	:= 	FWFormStruct( 2, 'C4P' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4N', oStruC4N, 'MODEL_C4N' )
oView:EnableTitleView( 'VIEW_C4N', STR0001) //Movimentacao diaria de combustiveis

oView:AddGrid ( 'VIEW_C4O', oStruC4O, 'MODEL_C4O' )
oView:EnableTitleView( 'VIEW_C4O', STR0002) //Movimentação diaria de combustiveis por tanque

oView:AddGrid ( 'VIEW_C4P', oStruC4P, 'MODEL_C4P' )
oView:EnableTitleView( 'VIEW_C4P', STR0003) //Volume de Vendas

oView:CreateHorizontalBox( 'FIELDSC4N', 40 )          

oView:CreateHorizontalBox( 'GRIDC4O', 30,,,,)
oView:CreateHorizontalBox( 'GRIDC4P', 30,,,,)

oView:SetOwnerView( 'VIEW_C4N', 'FIELDSC4N' )
oView:SetOwnerView( 'VIEW_C4O', 'GRIDC4O' )
oView:SetOwnerView( 'VIEW_C4P', 'GRIDC4P' )

If TamSX3("C4N_CODITE")[1] == 36
	oStruC4N:RemoveField("C4N_CODITE")
	oStruC4N:SetProperty("C4N_ITEM", MVC_VIEW_ORDEM, "03" )	
EndIf
Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validacao de alguns campos do model.

@param  oModel - parametro com o Model MVC 

@return lRet - Flag de validacao, onde .T. eh valido e .F. NAO valido

@author Fabio V santana
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local	lRet		:=	.T.

Local	cCNPJ 	:= 	oModel:GetValue( 'MODEL_C4P' , 'C4P_CNPJ' )
Local	cCPF 	:= 	oModel:GetValue( 'MODEL_C4P' , 'C4P_CPF' )
Local	cNome 	:= 	oModel:GetValue( 'MODEL_C4P' , 'C4P_NOMINT' )
Local	cMotInt	:= 	oModel:GetValue( 'MODEL_C4P' , 'C4P_MOTINT' )
Local	cNumInt	:= 	oModel:GetValue( 'MODEL_C4P' , 'C4P_NUMINT' )

//Validacao do campo CNPJ/CPF, Se o campo nome estiver preenchido fica obrigatorio o preenchimento do cpf ou do cnpj
If (!Empty(Trim(cNome)) .And. (Empty(cCPF).And.Empty(cCNPJ))) //.Or. (!Empty(cCPF).And.!Empty(cCNPJ))
	Help( ,,"CNPJOUCPF",,, 1, 0 ) 
	lRet	:=	.F.
Else                                                                                                        
// Valida se algum campo da Intervencao esta preenchido, obrigando o preenchimento do campo 'C4P_NUMINT'
	If ( Empty(cNumInt) .And. (!Empty(cMotInt) .Or. !Empty(cNome) .Or. !Empty(cCPF) .Or. !Empty(cCNPJ))) 
		Help( ,,"NUMINTVAZIO",,, 1, 0 ) 
		lRet	:=	.F.
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C4N", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF085Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF085Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cC4OKey  := ""
Local cC4PKey  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4N->( Recno() )

If C4N->C4N_STATUS $ ( " |1" )

	If Empty(C4N->C4N_CODITE)
		AADD(aLogErro,{"C4N_CODITE","000010", "C4N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4N->C4N_DTFECH)
		AADD(aLogErro,{"C4N_DTFECH","000010", "C4N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C4N->C4N_CODITE)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4N->C4N_CODITE
		xValRegTab("C1L",cChave,3,,@aLogErro,, { "C4N", "C4N_CODITE", nRecno } )
	EndIf	

	If !Empty(C4N->C4N_ESTQAB) .And. !Empty(C4N->C4N_VOLENT)
		If !(C4N->C4N_VOLDIS == (C4N->C4N_ESTQAB + C4N->C4N_VOLENT))
			AADD(aLogErro,{"C4N_VOLDIS","000548", "C4N",nRecno }) //STR0548 - "O valor deve corresponder à soma dos campos 'Estq. Aberto' e 'Vol. Recebido'."
		EndIf
	EndIf	

	If !Empty(C4N->C4N_VOLDIS) .And. !Empty(C4N->C4N_VOLSAI)
		If !(C4N->C4N_ESTQES == (C4N->C4N_VOLDIS - C4N->C4N_VOLSAI))
			AADD(aLogErro,{"C4N_ESTQES","000549", "C4N",nRecno }) //STR0549 - "O valor deve corresponder à soma dos campos 'Vol. Disponiv' e 'Vol. Saida'."
		EndIf
	EndIf	

	//INICIO C4O
	C4O->( DBSetOrder(1) )
	
	cC4OKey := C4N->C4N_ID
	If C4O->( MsSeek( xFilial("C4O") + cC4OKey ) )

		Do While !C4O->( Eof() ) .And. cC4OKey == C4O->C4O_ID

			If Empty(C4O->C4O_NUMTAN)
				AADD(aLogErro,{"C4O_NUMTAN","000010", "C4N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C4O->C4O_ESTQAB) .And. !Empty(C4O->C4O_VOLENT)
				If !(C4O->C4O_VOLDIS == (C4O->C4O_ESTQAB + C4O->C4O_VOLENT))
					AADD(aLogErro,{"C4O_VOLDIS","000548", "C4N",nRecno }) //STR0548 - "O valor deve corresponder à soma dos campos 'Estq. Aberto' e 'Vol. Recebido'."
				EndIf
			EndIf	

			If !Empty(C4O->C4O_VOLDIS) .And. !Empty(C4O->C4O_VOLSAI)
				If !(C4O->C4O_ESTQES == (C4O->C4O_VOLDIS - C4O->C4O_VOLSAI))
					AADD(aLogErro,{"C4O_ESTQES","000549", "C4N",nRecno }) //STR0549 - "O valor deve corresponder à soma dos campos 'Vol. Disponiv' e 'Vol. Saida'."
				EndIf
			EndIf	

			//INICIO C4P
			C4P->( DBSetOrder(1) )
			
			cC4PKey := C4O->(C4O_ID + C4O_NUMTAN)
			If C4P->( MsSeek( xFilial("C4P") + cC4PKey ) )
		
				Do While !C4P->( Eof() ) .And. cC4PKey == C4P->(C4P_ID + C4P_NUMTAN)
		
					If Empty(C4P->C4P_NUMBIC)
						AADD(aLogErro,{"C4P_NUMBIC","000010", "C4N",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//Valido o campo de CNPJ, passando o terceiro parametro da funcao CGC como .F.
					//Para que nao seja apresentado o alert de validacao                          
					If !Empty(C4P->C4P_CNPJ) 
						If !CGC(C4P->C4P_CNPJ,,.F.) 
							AADD(aLogErro,{"C4P_CNPJ", "000005", "C4N", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"    
						EndIf
					EndIf

					If !Empty(C4P->C4P_VFECHA) .And. !Empty(C4P->C4P_VABERT) .And. !Empty(C4P->C4P_VOLAFE)
						If !(C4P->C4P_VOLVEN == (C4P->C4P_VFECHA - (C4P->C4P_VABERT + C4P->C4P_VOLAFE)))
							AADD(aLogErro,{"C4P_VOLVEN","000550", "C4N",nRecno }) //STR0550 - "O valor deve corresponder à subtração do campo 'Val. Fechamen.' menos os campos 'Val. Abertura' e 'Val. Aferição.'."
						EndIf
					EndIf	

					C4P->( DbSkip() )
				EndDo
			EndIf
			//FIM C4P

			C4O->( DbSkip() )
		EndDo
	EndIf
	//FIM C4O

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4N", cStatus )

Else
	AADD(aLogErro,{"C4N_ID","000305","C4N",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)

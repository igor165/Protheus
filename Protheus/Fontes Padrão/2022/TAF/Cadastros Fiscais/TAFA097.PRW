#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA097.CH"                               
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA097
Cadastro MVC da Contribuição previdenciária sobre a receita bruta

@author Fabio V Santana
@since 21/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA097
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Contribuição previdenciária sobre a receita bruta
oBrw:SetAlias( 'C5M')
oBrw:SetMenuDef( 'TAFA097' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf097Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA097" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local lReinf	:=	TAFAlsInDic("T9T")
Local lV48		:= 	TAFAlsInDic("V48")
Local oStruC5M 	:= 	FWFormStruct( 1, 'C5M' )
Local oStruC5N 	:= 	FWFormStruct( 1, 'C5N' )
Local oStruC5O 	:= 	FWFormStruct( 1, 'C5O' )
Local oStruT9T 	:= 	Nil
Local oStruV48	:=  Nil

Local oModel	:= MPFormModel():New( 'TAFA097' ,,,{|oModel| SaveModel(oModel)} )

If lReinf 
	oStruT9T := FWFormStruct(1, 'T9T')
EndIf

If lV48 
	oStruV48 := FWFormStruct(1, 'V48')
EndIf 

oModel:AddFields('MODEL_C5M', /*cOwner*/, oStruC5M)

oModel:AddGrid('MODEL_C5N', 'MODEL_C5M', oStruC5N)
oModel:GetModel( 'MODEL_C5N' ):SetUniqueLine( { 'C5N_NUMCMP','C5N_CODDET'} ) 

oModel:AddGrid('MODEL_C5O', 'MODEL_C5M', oStruC5O)
If lReinf 
	oModel:GetModel( 'MODEL_C5O' ):SetUniqueLine( { 'C5O_NUMPRO', 'C5O_IDSUSP' } )
Else 
	oModel:GetModel( 'MODEL_C5O' ):SetUniqueLine( { 'C5O_NUMPRO' } )
EndIf 

If lReinf
	oModel:AddGrid('MODEL_T9T', 'MODEL_C5M', oStruT9T)  
	oModel:GetModel('MODEL_T9T'):SetUniqueLine({'T9T_ID', 'T9T_CODSEQ'})
EndIf 

If lV48
	DBSelectArea("T9C")//Abre a tabela de Cadastro de Obra
	DBSelectArea("V48")
	oModel:AddGrid('MODEL_V48', 'MODEL_C5M', oStruV48) 
	oModel:GetModel('MODEL_V48'):SetUniqueLine({'V48_ID', 'V48_IDCNO'})
EndIf

oModel:SetRelation( 'MODEL_C5N' , { { 'C5N_FILIAL' , 'xFilial( "C5N" )' } , { 'C5N_ID' , 'C5M_ID' } } , C5N->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C5N' ):SetOptional( .T. ) 
                                                     
oModel:SetRelation( 'MODEL_C5O' , { { 'C5O_FILIAL' , 'xFilial( "C5O" )' } , { 'C5O_ID' , 'C5M_ID' } } , C5O->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C5O' ):SetOptional( .T. )

If lReinf 
	oModel:SetRelation( 'MODEL_T9T', {{'T9T_FILIAL', 'xFilial( "T9T" )'}, {'T9T_ID', 'C5M_ID'}}, T9T->(IndexKey(1)))
	oModel:GetModel( 'MODEL_T9T' ):SetOptional( .T. )  
EndIf 

If lV48
	oModel:SetRelation( 'MODEL_V48', {{'V48_FILIAL', 'xFilial( "V48" )'}, {'V48_ID', 'C5M_ID'}}, V48->(IndexKey(2)))
	oModel:GetModel( 'MODEL_V48' ):SetOptional( .T. )  
EndIf

oModel:GetModel( "MODEL_C5M" ):SetPrimaryKey( { "C5M_DTINI", "C5M_DTFIM", "C5M_CODATI" } )                                                                                                           

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA097' )
Local oStruC5M 	:= 	FWFormStruct( 2, 'C5M' )
Local oStruC5N 	:= 	FWFormStruct( 2, 'C5N' )
Local oStruC5O 	:= 	FWFormStruct( 2, 'C5O' )
Local oStruT9T 	:= 	Nil
Local oStruV48	:=  Nil
Local oView 	:= 	FWFormView():New()
Local lReinf	:=	TAFAlsInDic("T9T")
Local lV48		:= 	TAFAlsInDic("V48")

If lReinf 
	oStruT9T := FWFormStruct( 2, 'T9T' )
EndIf 

If lV48
	oStruV48 := FWFormStruct( 2, 'V48' )
EndIf

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5M', oStruC5M, 'MODEL_C5M' )
oView:EnableTitleView( 'VIEW_C5M', STR0001) //Contribuição previdenciária sobre a receita bruta

oView:AddGrid ( 'VIEW_C5N', oStruC5N, 'MODEL_C5N' )
oView:AddGrid ( 'VIEW_C5O', oStruC5O, 'MODEL_C5O' )

If lReinf 
	oView:AddGrid ( 'VIEW_T9T', oStruT9T, 'MODEL_T9T' )
EndIf 

If lV48
	oView:AddGrid ( 'VIEW_V48', oStruV48, 'MODEL_V48' )
EndIf

oView:CreateHorizontalBox( 'FIELDSC5M', 60 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Complemento da Contribuição - Detalhamento da Apuração da Contribuição
oView:CreateHorizontalBox( 'GRIDC5N', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Processos Referenciados - CP
oView:CreateHorizontalBox( 'GRIDC5O', 100,,, 'FOLDER1', 'ABA02' )

If lReinf 
	oView:AddSheet( 'FOLDER1', 'ABA03', STR0011) //Tipo de Ajuste
	oView:CreateHorizontalBox( 'GRIDT9T', 100,,, 'FOLDER1', 'ABA03' )
EndIf 

If lV48
	oView:AddSheet( 'FOLDER1', 'ABA04', STR0012) //Detalhamento por CNO
	oView:CreateHorizontalBox( 'GRIDV48', 100,,, 'FOLDER1', 'ABA04' )
EndIf

If TamSX3("C5M_CODCTA")[1] == 36
	oStruC5M:RemoveField( "C5M_CODCTA")
	oStruC5M:SetProperty( "C5M_CTACTB", MVC_VIEW_ORDEM, "13" )
EndIf   

If lReinf 
	If oModel:HasField('MODEL_C5O', 'C5O_IDSUSP')
		oStruC5O:RemoveField('C5O_IDSUSP')
	EndIf
	
	If oModel:HasField('MODEL_T9T', 'T9T_CODSEQ')
		oStruT9T:RemoveField('T9T_CODSEQ')
	EndIf
	
	If oModel:HasField('MODEL_T9T', 'T9T_ID')
		oStruT9T:RemoveField('T9T_ID')
	EndIf
EndIf 

If lV48	
	If oModel:HasField('MODEL_V48', 'V48_ID')
		oStruV48:RemoveField('V48_ID')
	EndIf
	If oModel:HasField('MODEL_V48', 'V48_CODCTA')
		oStruV48:RemoveField('V48_CODCTA')
	EndIf
	If oModel:HasField('MODEL_V48', 'V48_IDCNO')
		oStruV48:RemoveField('V48_IDCNO')
	EndIf
	If oModel:HasField('MODEL_V48', 'V48_PROCID')
		oStruV48:RemoveField('V48_PROCID')
	EndIf
EndIf

oView:SetOwnerView( 'VIEW_C5M', 'FIELDSC5M' )
oView:SetOwnerView( 'VIEW_C5N', 'GRIDC5N' )
oView:SetOwnerView( 'VIEW_C5O', 'GRIDC5O' )

If lReinf 
	oView:SetOwnerView( 'VIEW_T9T', 'GRIDT9T' )
EndIf 

If lV48	
	oView:SetOwnerView( 'VIEW_V48', 'GRIDV48' )
EndIf

Return oView


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

Local nOperation 	:= oModel:GetOperation()
Local cFilC5M		:= ""
Local cID			:= ""
Local cAlias		:= GetNextAlias()
Local lV48			:= TAFAlsInDic("V48")
Local aAreaV48   	:= {}

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C5M", " " )
	EndIf  

	If FwFormCommit( oModel )
		If FindFunction('TafEndGRV') 
			TafAtuPrId( "C5M" ) //Apaga V0S de acordo com o procId da C5M

			TafEndGRV( "C5M","C5M_PROCID", '', C5M->(Recno())  )
			If lV48 .and. TAFColumnPos("V48_PROCID")

				cFilC5M := C5M->C5M_FILIAL
				cID		:= C5M->C5M_ID

				BeginSQl Alias cAlias
					SELECT 
						V48.R_E_C_N_O_ AS RECNO
					FROM 
						%Table:V48% V48
					WHERE 
						V48.V48_FILIAL = %Exp:cFilC5M% 
						AND V48.V48_ID = %Exp:cID%
						AND V48.%NotDel%
				EndSQL

				aAreaV48 := V48->(GetArea())

				While (cAlias)->(!EOF())
					V48->( DbGoTo(  (cAlias)->RECNO ) )
					TafAtuPrId( "C5M", "V48" ) //Apaga V0S de acordo com o procId da V48

					TafEndGRV( "V48","V48_PROCID", '', (cAlias)->RECNO  )

					(cAlias)->(DbSkip())

				EndDo

				RestArea(aAreaV48)
			EndIf
		EndIf
	EndIf

End Transaction 

if lV48
	(cAlias)->(DBCloseArea())
endif 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF097Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF097Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cC5NKey  := ""
Local cC5OKey  := ""
Local cV48Key  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5M->( Recno() )

If C5M->C5M_STATUS $ ( " |1" )

	If Empty(C5M->C5M_DTINI)
		AADD(aLogErro,{"C5M_DTINI","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5M->C5M_DTFIM)
		AADD(aLogErro,{"C5M_DTFIM","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5M->C5M_CODATI)
		AADD(aLogErro,{"C5M_CODATI","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C5M->C5M_CODATI)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5M->C5M_CODATI
		xValRegTab("C5V",cChave,3,,@aLogErro,, { "C5M", "C5M_CODATI", nRecno } )
	EndIf	

	If !Empty(C5M->C5M_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5M->C5M_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5M", "C5M_CODCTA", nRecno })
	EndIf	

	If !Empty(C5M->C5M_VATIV) .And. !Empty(C5M->C5M_VEXC)
		If !(C5M->C5M_BASE == (C5M->C5M_VATIV - C5M->C5M_VEXC))
			AADD(aLogErro,{"C5M_BASE","000552", "C5M",nRecno }) //STR0552 - "O valor deve corresponder à subtração de 'Rec. Bruta' menos 'Val. Exclu.'."
		EndIf 
	EndIf
	
	//³INICIO C5N³
	C5N->( DBSetOrder(1) )
	
	cC5NKey := C5M->C5M_ID
	If C5N->( MsSeek( xFilial("C5N") + cC5NKey ) )

		Do While !C5N->( Eof() ) .And. cC5NKey == C5N->C5N_ID

			If Empty(C5N->C5N_NUMCMP)
				AADD(aLogErro,{"C5N_NUMCMP","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C5N->C5N_DETVAL)
				AADD(aLogErro,{"C5N_DETVAL","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C5N->C5N_NUMCMP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5N->C5N_NUMCMP
				xValRegTab("C5X",cChave,3,,@aLogErro,, { "C5M", "C5N_NUMCMP", nRecno })
			EndIf	

			If !Empty(C5N->C5N_CODDET)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5N->C5N_CODDET
				xValRegTab("C5P",cChave,3,,@aLogErro,, { "C5M", "C5N_CODDET", nRecno })
			EndIf

			C5N->( DbSkip() )
		EndDo
	EndIf
	//FIM C5N

	//INICIO C5O
	C5O->( DBSetOrder(1) )
	
	cC5OKey := C5M->C5M_ID
	If C5O->( MsSeek( xFilial("C5O") + cC5OKey ) )

		Do While !C5O->( Eof() ) .And. cC5OKey == C5O->C5O_ID

			If Empty(C5O->C5O_NUMPRO)
				AADD(aLogErro,{"C5O_NUMPRO","000010", "C5M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C5O->C5O_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5O->C5O_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C5M", "C5O_NUMPRO", nRecno })
			EndIf	

			C5O->( DbSkip() )
		EndDo
	EndIf
	//FIM C5O
	
	//INICIO V48
	V48->( DBSetOrder(1) )
	
	cV48Key := C5M->C5M_ID
	If V48->( MsSeek( xFilial("V48") + cV48Key ) )

		Do While !V48->( Eof() ) .And. cV48Key == V48->V48_ID

			If !Empty(V48->V48_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := V48->V48_NUMPRO
				xValRegTab("V48",cChave,2,,@aLogErro,, { "C5M", "V48_CODCNO", nRecno })
			EndIf	

			V48->( DbSkip() )
		EndDo
	EndIf
	//FIM V48

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C5M", cStatus )

Else
	AADD(aLogErro,{"C5M_ID","000305","C5M",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf097Gat

Tratamento do valor do campo C5M_VCON de acordo com o parametro MV_TAFRND (1-ARREDONDAR, 2-TRUNCAR).
Função chamada no gatilho C5M_ALQCON. 
                                                     
@author Katielly Feitosa

@since 08/01/2019
@version 1.0
/*/   
//-------------------------------------------------------------------
Function Taf097Gat(nValor, nDec) 

Local nMVTAFRND := GetMV("MV_TAFRND")

	If nMVTAFRND == '1'
    	nRet  :=  Round( nValor , nDec )	
	Else
    	nRet  :=  NoRound( nValor , nDec )
	EndIf

return (nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafInBrwCC

Inicializador de browse para o campo C5M_CTACTB,
o Posicione foi encapsulado em funcao, quando o mesmo esta diretamente 
no campo X3_INIBRW, em banco de dados informix, a Browse ficava vazio,
ou seja não exibia os dados que existiam na tabela C5M.
//IIF(FINDFUNCTION("TAFINBRWCC"),TAFINBRWCC(),"")

@author Denis Souza

@since 04/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafInBrwCC()

Local cCodCta := ""

if !Empty( C5M->C5M_CODCTA )
	cCodCta := Posicione("C1O", 3, xFilial("C1O") + C5M->C5M_CODCTA  ,"C1O_CODIGO" )
endif

Return cCodCta
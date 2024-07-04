#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA057.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA057 - Identificação do Item (Produtos/Serviços)
@author Mauro A. Gonçalves
@since 23/07/2012
@version 1.0

/*/
//------------------------------------------------------------------
Function TAFA057
	Local	oBrw	:= FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Identificação do Item (Produtos/Serviços)
	oBrw:SetAlias( 'C1L')
	C1L->(DbsetOrder(1))
	oBrw:SetMenuDef( 'TAFA057' )
	oBrw:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Gonçalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "Taf057Vld" , "2" } )
	Aadd( aFuncao, { "" , 'FWMsgRun(,{||TAFA452(.T.)},,"Carregando Cadastro de Insumos... ")' , "6", 3 } ) //A Quarta posição refere-se ao
	aRotina	:=	xFunMnuTAF( "TAFA057" , , aFuncao )
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Gonçalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local 	oStruC1L	:= 	FWFormStruct( 1, 'C1L' )
	Local 	oStruC1M	:= 	FWFormStruct( 1, 'C1M' )
	Local   oModel 	    := 	MPFormModel():New( 'TAFA057' ,,,{|oModel| SaveModel(oModel)} )

	oModel:AddFields  ('MODEL_C1L', /*cOwner*/, oStruC1L)
	oModel:AddGrid    ('MODEL_C1M', 'MODEL_C1L', oStruC1M)

	oModel:GetModel   ( 'MODEL_C1M' ):SetOptional( .T. )
	oModel:GetModel   ( 'MODEL_C1M' ):SetUniqueLine( {'C1M_DTALT','C1M_HRALT','C1M_CTDANT' } )
	oModel:SetRelation( 'MODEL_C1M', { { 'C1M_FILIAL', 'xFilial( "C1M" )' } , { "C1M_ID" , "C1L_ID" } }, C1M->( IndexKey( 1 ) ) )

	oModel:GetModel( "MODEL_C1L" ):SetPrimaryKey( { "C1L_CODIGO" } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Gonçalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 		:= 	FWLoadModel( 'TAFA057' )
	Local oStruC1L 	:= 	FWFormStruct( 2, 'C1L' )
	Local oStruC1M 	:= 	FWFormStruct( 2, 'C1M' )
	Local oView 		:= 	FWFormView():New()

	oView:SetModel( oModel )

	oStruC1L:RemoveField('C1L_IDCFQ')
	oStruC1L:RemoveField('C1L_IDCNM')
	oStruC1L:RemoveField('C1L_IDGLP')
	oStruC1L:RemoveField('C1L_IDAFE')
	oStruC1L:RemoveField('C1L_IDUM')

	If oModel:HasField( 'MODEL_C1L', 'C1L_IDCEST' )
		oStruC1L:RemoveField('C1L_IDCEST')
	EndIf

	If oModel:HasField( 'MODEL_C1L', 'C1L_ESTOQ' )
		oStruC1L:SetProperty('C1L_ESTOQ',MVC_VIEW_INSERTLINE,.T.)
	EndIf
	If TamSX3("C1L_ID")[1] == 36
		oStruC1L:RemoveField("C1L_ID")				
	EndIf

	oView:AddField( 'VIEW_C1L', oStruC1L, 'MODEL_C1L' )
	oView:EnableTitleView( 'VIEW_C1L', STR0001 ) //Identificação do Item (Produtos/Serviços)

	oView:AddGrid ( 'VIEW_C1M', oStruC1M, 'MODEL_C1M' )
	oView:EnableTitleView( 'VIEW_C1M', STR0002 ) //Alteração da Identificação do Item (Produtos/Serviços)

	/*-----------------------------------------------------------------------------------
	Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",69)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	oView:CreateHorizontalBox("PAINEL_INFERIOR",31)
	oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

	oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0002)
	oView:CreateHorizontalBox("PAINEL_C1M",100,,,"FOLDER_INFERIOR","ABA01") //C1M

	oView:SetOwnerView( 'VIEW_C1L', 'PAINEL_PRINCIPAL' )
	oView:SetOwnerView( 'VIEW_C1M', 'PAINEL_C1M' )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 28/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
	Local nOperation		:= oModel:GetOperation()
	Local nI            	:= 0
	Local nX 		    	:= 0
	Local nlY           	:= 0

	Local nC1M  	 		:= 0
	Local cNumCpo    		:= ""
	Local cCTDAnt    		:= ""

	Local aGravaC1M  		:= {}
	Local aC1L		 		:= {}
	Local aC1LMemo	  	:= {}

	Local oModelC1L  		:= Nil
	Local oModelC1M  		:= Nil
	Local nPosId			:= 0
	Local cCmpHist		   	:= ""
	Local cUsoCmp			:= ""
	Local clAlias			:= "C1L"
	Local aCmpC1L	   		:= {}
	Local nCmpAnt			:= 0
	Local nPos				:= 0
	Local cAux				:= ""
	Local cHora			:= ""

	Begin Transaction

		If nOperation == MODEL_OPERATION_UPDATE

			/*+------------------------------------------------------+
			  | Data:28.08.2014	     	                 				 |
			  | Responsável: Evandro dos Santos Oliveira             |
			  | Descrição da Alteração: Grava campos modificados na  |
			  | tabela C1M para gravar o histórico 			   	 	 |
			  +------------------------------------------------------+*/
			oModelC1M := oModel:GetModel( "MODEL_C1M" )
			oModelC1L := oModel:GetModel( "MODEL_C1L" )

			nPosId 	:= aScan(oModelC1L:aDataModel[1],{|x|AllTrim(x[1]) == "C1L_ID"})

			DBSelectArea(clAlias)
			DBSetOrder(3)

			If C1L->(MsSeek(xFilial("C1L")+(oModelC1L:aDataModel[ 1, nPosId , 2 ]) ) )

				cCmpHist:= "C1L_CODIGO|C1L_DESCRI"
				aCmpC1L := xFunGetSX3(clAlias,,.F.)

				aEval(aCmpC1L,{|x|IIf((AllTrim(x[2]) $ cCmpHist);
				,(aAdd(aC1L,{x[2],(clAlias)->&(x[2])}),cUsoCmp += AllTrim(x[2]) + "|"),.F.)})

			EndIf

			aEval(oModelC1L:aDataModel[1],{|mdC1L| IIf((mdC1L[1] $ cCmpHist) .And. (mdC1L[1] $ cUsoCmp);
			,aAdd(aC1LMemo,mdC1L[2]),.F.)})

			nCmpAnt 	:= oModel:GetModel( "MODEL_C1M" ):Length()
			cHora		:= Time()

			For nI := 1 to Len(aC1L)
				If aC1L[nI][2] <> aC1LMemo[nI]

					cHora := IncTime(cHora, 00, 00, 01 )

					cNumCpo := Posicione("C2Q",4,xFilial("C2Q")+Alltrim(Substr((aC1L[nI][1]),5,6)),"C2Q_ID")
					cCTDAnt := TAFRtCmp(aC1L[nI][2],aC1L[nI][1])
					aAdd(aGravaC1M,{	Date() 	    ,;
										cHora		,;
										cNumCpo 	,;
										cCTDAnt	    ,;
										aC1L[nI][1]})

				EndIf
			Next

			For nC1M := 1 to Len( aGravaC1M )

				If (nCmpAnt == 1 .And. !Empty(oModel:GetValue( "MODEL_C1M","C1M_DTALT"))) .Or.;
				   (nCmpAnt > 1)

					oModel:GetModel( 'MODEL_C1M' ):lValid	:= .T.
					oModel:GetModel( "MODEL_C1M" ):AddLine()
				EndIf

				If !Empty(aGravaC1M[nC1M][1])
					oModel:LoadValue( "MODEL_C1M", "C1M_DTALT"  , aGravaC1M[nC1M][1] )
					oModel:LoadValue( "MODEL_C1M", "C1M_HRALT"  , aGravaC1M[nC1M][2] )
					oModel:LoadValue( "MODEL_C1M", "C1M_NRCAMP" , aGravaC1M[nC1M][3] )
					oModel:LoadValue( "MODEL_C1M", "C1M_CTDANT" , aGravaC1M[nC1M][4] )
				EndIf

			Next

			TAFAltStat( "C1L", " " )

		EndIf

		FwFormCommit( oModel )

	End Transaction
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRtCmp (Função Auxiliar)
Converte valores de outros tipo em caracter

@param  xPar	  - Conteudo do Campo
@return cCTDAnt - Conteudo normalizado

@author Evandro dos Santos Oliveira
@since 28/08/2014
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
/*/{Protheus.doc} TAF057Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 28/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF057Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro	:= {}
	Local cStatus		:= ""
	Local cChave		:= ""
	Local cC1MKey		:= ""
	Local aHora     	:= {}
	Local lValido  	:= .T.
	Local cHora		:= ""

	Default lJob 		:= .F.

	//Garanto que o Recno seja da tabela referente ao cadastro principal
	nRecno := C1L->( Recno() )

	If C1L->C1L_STATUS $ ( " |1" )

		//---------------------
		// Campos obrigatórios
		//---------------------
		If Empty(C1L->C1L_CODIGO)
			AADD(aLogErro,{"C1L_CODIGO","000010", "C1L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
		EndIf

		If Empty(C1L->C1L_DESCRI)
			AADD(aLogErro,{"C1L_DESCRI","000010", "C1L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
		EndIf

		//------------------
		// Consultas padrão
		//------------------
		If !Empty(C1L->C1L_UM)
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := C1L->C1L_UM
			xValRegTab("C1J",cChave,3,,@aLogErro,, { "C1L", "C1L_UM", nRecno } )
		EndIf

		/*-----------------------------------------------------------------------------------------------------
		Valida CEST
		-----------------------------------------------------------------------------------------------------*/
		If TafColumnPos('C1L_IDCEST') .And. !Empty(C1L->C1L_IDCEST)
			cChave := C1L->C1L_IDCEST

			xValRegTab("T71",cChave,2,,@aLogErro,, { "T71", "C1L_IDCEST", nRecno } )
		EndIf

		//--------
		// Combos
		//--------
		If !C1L->C1L_ESTOQ $ ('1|2|3| ') // Demetrio - 20/08/2014 - Acrescentado a opção ' ' - em branco - nas opções do combo.
			AADD(aLogErro,{"C1L_ESTOQ","000006", "C1L",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf

		C1M->( DBSetOrder(1) )
		cC1MKey := C1L->C1L_ID
		If C1M->( MsSeek( xFilial("C1M") + cC1MKey ) )

			Do While !C1M->( Eof() ) .And. cC1MKey == C1M->C1M_ID

				//---------------------
				// Campos obrigatórios
				//---------------------
				If Empty(C1M->C1M_DTALT)
					AADD(aLogErro,{"C1M_DTALT","000010", "C1L",nRecno }) 			//STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				If Empty(C1M->C1M_CTDANT)
					AADD(aLogErro,{"C1M_CTDANT","000010", "C1L",nRecno }) 			//STR0010 - "Campo Inconsistente ou Vazio"
				EndIf

				If Empty(C1M->C1M_NRCAMP)
					AADD(aLogErro,{"C1M_NRCAMP","000010", "C1L",nRecno }) 			//STR0010 - "Campo Inconsistente ou Vazio"
				Else
					//Valida Consulta Padrão
					cChave := C1M->C1M_NRCAMP
					xValRegTab("C2Q",cChave,3,,@aLogErro,, { "C1L", "C1M_NRCAMP", nRecno } )
				EndIf

				If Empty(C1M->C1M_HRALT)
					AADD(aLogErro,{"C1M_HRALT","000010", "C1L",nRecno }) 			//STR0010 - "Campo Inconsistente ou Vazio"
				Else
			   		aHora := StrTokArr(C1M->C1M_HRALT,":")
			       If Len(aHora) <> 3
			       	AADD(aLogErro,{"C1M_HRALT","000007", "C1L",nRecno }) 		//STR0007 - "Hora Inconsistente ou Vazia"
			       Else
				   		If Val(aHora[1]) > 23   .OR. Val(aHora[2]) > 59 .OR. Val(aHora[3]) > 59
				       	AADD(aLogErro,{"C1M_HRALT","000007", "C1L",nRecno }) 	//STR0007 - "Hora Inconsistente ou Vazia"
				       Endif

				       If Len(Alltrim(aHora[1])) <> 2  .OR. Len(Alltrim(aHora[2])) <> 2 .OR. Len(Alltrim(aHora[3])) <> 2
				       	AADD(aLogErro,{"C1M_HRALT","000007", "C1L",nRecno }) 	//STR0007 - "Hora Inconsistente ou Vazia"
				       Endif
					EndIf
			    EndIf
				C1M->( DbSkip() )
			EndDo
		EndIf

		//Atualizo o Status do registro
		cStatus := Iif(Len(aLogErro) > 0,"1","0")
		TAFAltStat( "C1L", cStatus )

	Else
		AADD(aLogErro,{"C1L_ID","000305","C1L",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
	EndIf

	//Não apresento o alert quando utilizo o JOB para validar
	If !lJob
		xValLogEr(aLogErro)
	EndIf
Return(aLogErro)
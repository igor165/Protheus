#INCLUDE "Protheus.ch"
#INCLUDE "MDTA092.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 3
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA092
Cadastro de Tarefas por Candidato
@author Hugo Rizzo Pereira - Refeito por: Gabriel Augusto Werlich
@since 01/12/2010 - Revisão: 27/08/2015
/*/
//---------------------------------------------------------------------
Function MDTA092

	//Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	Local oBrowse
	
	Private cCadastro := OemtoAnsi(STR0004)  //"Tarefas por Candidato
	Private lChamTKD := .T.

	If !NGIFDICIONA("SX3","TKD",1,.F.)
  		If !NGINCOMPDIC("UPDMDT23","00000028511/2010")
  			Return .F.
  		EndIf
	EndIf
	
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TM0" ) //Alias da tabela utilizada
		oBrowse:SetMenuDef( "MDTA092" )	//Nome do fonte onde esta a função MenuDef
		oBrowse:SetFilterDefault("Empty(TM0_MAT)") 
		oBrowse:SetDescription( STR0004 )	//Descrição do browse ###"Tarefas por Candidato"
	oBrowse:Activate()
	
	// Devolve as variáveis armazenadas
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Gabriel Augusto Werlich
@since 27/08/15

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.MDTA092' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Tarefas' Action 'VIEWDEF.MDTA092' OPERATION 4 ACCESS 0

//Inicializa MenuDef com todas as opções
Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Gabriel Augusto Werlich
@since 27/08/15

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTM0 := FWFormStruct( 1 ,"TM0" , { | cCampo | fSelectTM0( cCampo ) } , /*lViewUsado*/ )
	Local oStructTKD := FWFormStruct( 1 ,"TKD" , { | cCampo | fSelectTMK( cCampo ) } , /*lViewUsado*/ )

	// Modelo de dados que será construído
	Local oModel
	
	//Trava o campo Data Implementação
	oStructTM0:SetProperty( 'TM0_DTIMPL' , MODEL_FIELD_WHEN,{|x| .F. })
	
	//Trava o campo Data Fim
	oStructTKD:SetProperty( 'TKD_DTTERM' , MODEL_FIELD_WHEN,{|x| fWhenDtFim(x) })
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "MDTA092" ,/*bPre*/,   , /*bCommit*/ , /*bCancel*/ )
		//--------------------------------------------------	
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formulário Principal
		// cId          Identificador do modelo
		// cOwner       Identificador superior do modelo
		// oModelStruct Objeto com  a estrutura de dados
		// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
		// bPost        Code-Block de validação do formulário de edição
		// bLoad        Code-Block de carga dos dados do formulário de edição
		oModel:AddFields( "TM0MASTER" , Nil , oStructTM0 , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
		oModel:AddGrid( "TKDDETAIL" , "TM0MASTER" ,oStructTKD , ,{|oModelGrid|ValidLinha(oModelGrid)} , /*bLoad*/ )
		
		oModel:SetRelation( 'TKDDETAIL', { { 'TKD_FILIAL', 'xFilial( "TKD" )' },{ 'TKD_NUMFIC', 'TM0_NUMFIC' }},TKD->( IndexKey( 1 ) ) )
				
			// Adiciona a descrição do Modelo de Dados (Geral)
			oModel:SetDescription( STR0004 /*cDescricao*/ ) // "Cadastro de Questionario Quimico"
			
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TM0MASTER" ):SetDescription( STR0004 ) //"Tarefas por Candidato"
			oModel:GetModel( "TKDDETAIL" ):SetDescription( STR0004 ) //"Tarefas por Candidato"
			
			//"Valida chave duplicada em uma linha da getdados
			oModel:GetModel( "TKDDETAIL" ):SetUniqueLine( {"TKD_CODTAR"} ) 
			
			//Permite deixar a getdados em branco
			oModel:GetModel( "TKDDETAIL" ):SetOptional( .T. )
			
Return oModel
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Gabriel Augusto Werlich
@since 27/08/15

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA092" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTM0 := FWFormStruct( 2 , "TM0" , { | cCampo | fSelectTM0( cCampo ) } , /*lViewUsado*/ )
	Local oStructTKD := FWFormStruct( 2 , "TKD" , { | cCampo | fSelectTMK( cCampo ) } , /*lViewUsado*/ )
	
	// Interface de visualização construída
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
		// Objeto do model a se associar a view.
		oView:SetModel( oModel )
		// Adiciona no View um controle do tipo formulário (antiga Enchoice)
		// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
		// oStruct - Objeto do model a se associar a view.
		// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
		oView:AddField( "VIEW_TM0" , oStructTM0 , "TM0MASTER" )
		oView:AddGrid( "VIEW_TKD" , oStructTKD , "TKDDETAIL")
		
		oView:SetViewAction( 'BUTTONOK' ,{|x| fTudoOK(x) } )
		
			//Adiciona um titulo para o formulário
			oView:EnableTitleView( "VIEW_TM0" , STR0001 )	// Descrição do browse ###"Cadastro de Questionario Quimico"
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado 
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "SUPERIOR" , 17,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
			oView:CreateHorizontalBox( "INFERIOR" , 83,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TM0" , "SUPERIOR" )
		oView:SetOwnerView( "VIEW_TKD" , "INFERIOR" )

Return oView
//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectTM0
Seleciona os campos a serem mostrados.

@param cCampo - Campos da tabela a serem validados

@author Gabriel Augusto Werlich
@since 27/08/15

@return .T. ou .F. dependendo do que encontrar no Array
/*/
//---------------------------------------------------------------------
Static Function fSelectTM0(cCampo)
	Local aCampos := {"TM0_NUMFIC", "TM0_NOMFIC", "TM0_DTIMPL"}
Return aScan( aCampos, { | x | AllTrim(x) == Alltrim(cCampo) } ) > 0
//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectTMK
Seleciona os campos a serem mostrados.

@param cCampo - Campos da tabela a serem validados

@author Gabriel Augusto Werlich
@since 27/08/15

@return .T. ou .F. dependendo do que encontrar no Array
/*/
//---------------------------------------------------------------------
Static Function fSelectTMK(cCampo)
	Local aCampos := {"TKD_NUMFIC", "TKD_NOMFIC"}
Return aScan( aCampos, { | x | AllTrim(x) == Alltrim(cCampo) } ) == 0
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidLinha
Valida as datas da linha.
     
@param oModelGrid - Modelo de dados da grid

@author Gabriel Augusto Werlich
@since 27/08/15
/*/
//-------------------------------------------------------------------
Static Function ValidLinha(oModelGrid)
	
	Local dDtIni := oModelGrid:GetValue('TKD_DTINIC')
	Local dDtFim := oModelGrid:GetValue('TKD_DTTERM')
	Local lRet := .F.

	If Empty(dDtIni) 
		Help( , , STR0013 , , STR0011 , 4 , 0 )//"ATENÇÃO"###"A data inicial deve ser preenchida."
	ElseIf dDtIni < TM0_DTIMPL 
		Help( , , STR0013 , , STR0012 , 4 , 0 )//"ATENÇÃO"###"A data inicial deve ser maior ou igual a data de implementação da ficha médica."			
	ElseIf !Empty(dDtFim)                 
		If dDtIni > dDtFim
			Help( , , STR0013 , , STR0010 , 4 , 0 )//"ATENÇÃO"###"A data inicial deve ser menor ou igual a data final."
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf
     
Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} fWhenDtFim
Trava o campo de data Final caso a data Inicio não esteja preenchida.
     
@param oModelGrid - Modelo de dados da grid

@author Gabriel Augusto Werlich
@since 27/08/15
/*/
//-------------------------------------------------------------------
Static Function fWhenDtFim(oModelGrid)
	Local dDtIni := oModelGrid:GetValue('TKD_DTINIC')
	Local lRet := .T.
	
	If Empty(dDtIni)
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} fTudoOK
Trava o campo de data Final caso a data Inicio não esteja preenchida.
     
@param oModelGrid - Modelo de dados da grid

@author Gabriel Augusto Werlich
@since 27/08/15
/*/
//-------------------------------------------------------------------
Static Function fTudoOK(oModel)

Local oModelZA2 := oModel:GetModel( 'TKDDETAIL' )
Local lRet := .f.

If !oModelZA2:IsDeleted() .Or. oModelZA2:IsDeleted()
	lRet := .T.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT092LOK
Validacao de linha da getdados  
     
@param cAliasTrf - Alias utilizado

@author Hugo Rizzo Pereira 
@since 01/12/10
/*/
//-------------------------------------------------------------------
Function MDT092LOK(cAliasTrf)
Local xx := 0, nX
Local nCodTar := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == cAliasTrf + "_CODTAR"})
Local nDtInic := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == cAliasTrf + "_DTINIC"})

If acols[n][len(Acols[n])]
	Return .t.
Endif

If Empty(aCOLS[n][nCodTar])
	Help(1," ","OBRIGAT2",,aHeader[nCodTar][1],3,0)
	Return .F.
ElseIf Empty(aCOLS[n][nDtInic])
	Help(1," ","OBRIGAT2",,aHeader[nDtInic][1],3,0)
	Return .F.
Else
	For nX := 1 to Len(aCOLS)
		If nx <> n
			If aCOLS[nX][nCodTar] == aCOLS[n][nCodTar] .and. ;
				aCOLS[nX][nDtInic] == aCOLS[n][nDtInic] .and. ;
				!acols[nX][len(Acols[nX])]
		   	Help(" ",1,"JAEXISTINF")
			   Return .F.
			Endif
		EndIf    
	Next
Endif

PutFileInEof( cAliasTrf )

Return .T.
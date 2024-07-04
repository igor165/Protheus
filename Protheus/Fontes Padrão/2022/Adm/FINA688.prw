#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA688.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA688

Tela de configuração de aprovação automática de viagens 

@author julio.teixeira
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA688()

	//Chama a view da tela de configuração de aprovação
	FWExecView(STR0005,'FINA688', MODEL_OPERATION_INSERT, , { || .T. } )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Modelo de Dados

@author julio.teixeira
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil

/*
 * Cria o objeto do Modelo de Dados
 */ 
Local oStrCab	:= FWFormModelStruct():New()
Local oStrAd	:= FWFormStruct(1,"FW0")// Adiantamento
Local oStrPc	:= FWFormStruct(1,"FW0")// Prestação de Contas
Local oStrSv	:= FWFormStruct(1,"FW0")// Solicitação de Viagem

//Criação do Modelo de Dados
oModel := MPFormModel():New('FINA688', /*bPreValidacao*/, /*{ |oModel| AF036Pos(oModel) }/*bPosValidacao*/,  { |oModel| F688GRV( oModel ) }/*bGravacao*/ , /*bCancel*/ )

//Criando master falso para a alimentação dos details.
oStrCab:AddTable('FW0MASTER',{},'FW0MASTER')
oStrCab:AddField(		  ;
"Campo01"		, ;	// [01] Titulo do campo		//"Nome Fornecedor"
"Campo01"		, ;	// [02] ToolTip do campo	//"Nome Fornecedor"
"FWW_CPO"		, ;	// [03] Id do Field
"C"				, ;	// [04] Tipo do campo
5				, ;	// [05] Tamanho do campo
0				, ;	// [06] Decimal do campo
{ || .T. }		, ;	// [07] Code-block de validação do campo
{ || .T. }		, ;	// [08] Code-block de validação When do campo
				, ;	// [09] Lista de valores permitido do campo
.F.)				// [10] Indica se o campo tem preenchimento obrigatório


oModel:AddFields('FW0MASTER', /*cOwner*/, oStrCab , , ,{|| {}} )
oModel:AddGrid('GRID1'	,'FW0MASTER'	,oStrAd	,,,,, {|| {}} )
oModel:AddGrid('GRID2'	,'FW0MASTER'	,oStrPc	,,,,, {|| {}} )
oModel:AddGrid('GRID3'	,'FW0MASTER' 	,oStrSv	,,,,, {|| {}} )

//Adicional campo OK para controle da operação
oStrAd:AddField('','' , 'OK', 'L', 1, 0, /*bValid */	, , {}	, .F.	, , .F., .F., .F., , )//''#//'Seleção'

//Adicional campo OK para controle da operação
oStrPc:AddField('','' , 'OK', 'L', 1, 0, /*bValid */	, , {}	, .F.	, , .F., .F., .F., , )//''#//'Seleção'

//Adicional campo OK para controle da operação
oStrSv:AddField('','' , 'OK', 'L', 1, 0, /*bValid */	, , {}	, .F.	, , .F., .F., .F., , )//''#//'Seleção'

//Descrição
oModel:SetDescription(STR0004) // "Configuração de Aprovação Automática"
oModel:GetModel('GRID1' ):SetDescription( STR0001 )	//'Adiantamentos' 
oModel:GetModel('GRID2' ):SetDescription( STR0002 )	//'Prestação de Contas'
oModel:GetModel('GRID3' ):SetDescription( STR0003 )	//'Solicitação de Viagem'

//Permite a deleção de todas as linhas do Grid
oModel:GetModel('GRID1'):SetDelAllLine(.T.)
oModel:GetModel('GRID2'):SetDelAllLine(.T.)
oModel:GetModel('GRID3'):SetDelAllLine(.T.)

//Desabilita a Gravação automatica do Model FW0MASTER
oModel:GetModel( 'FW0MASTER'):SetOnlyQuery ( .T. )

oModel:SetPrimarykey({})

oModel:SetActivate( {|oModel| F688Carga(oModel) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da Interface

@author julio.teixeira
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
/*
 * Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
 */
Local oModel	:= FWLoadModel( 'FINA688' )
Local oView	:= Nil

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStrCab	:= FWFormViewStruct():New()	//Cadastro
Local oStrAd	:= FWFormStruct(2, "FW0" )	//
Local oStrPc	:= FWFormStruct(2, "FW0" )	//
Local oStrSv	:= FWFormStruct(2, "FW0" )	//

oStrCab:AddField(	  ;
"FWW_CPO"		, ;		// [01] Id do Field
"01"			, ;		// [02] Ordem
"Campo01" 		, ;		// [03] Titulo do campo		//"Nome Fornecedor"
"Campo01"		, ;		// [04] ToolTip do campo	//"Nome do Fornecedor"
				, ;		// [05] Help
"C"				, ;		// [06] Tipo do campo
"@!"			, ;		// [07] Picture
				, ;		// [08] PictVar
''              )		// [09] F3

/*
 * Cria o objeto de View
 */
oView := FWFormView():New()

/*
 * Define qual o Modelo de dados será utilizado
 */
oView:SetModel(oModel)

oView:AddField('FORM_FAKE'	,oStrCab	,'FW0MASTER') //Cabeçalho falso
oView:AddGrid('GRID_AD'		,oStrAd	,'GRID1' ) //Adiantamentos
oView:AddGrid('GRID_PC'		,oStrPc	,'GRID2' ) //Prestação de Contas
oView:AddGrid('GRID_SV'		,oStrSv	,'GRID3' ) //Solicitação de Viagem

/*
 * Remove Campos não Usados - Adiantamento 
 */
oStrAd:RemoveField( 'FW0_CLASS' )
oStrAd:RemoveField( 'FW0_PREST' )
oStrAd:RemoveField( 'FW0_VIAGE' )
/*
 * Remove Campos não Usados - Prestação de Contas
 */
oStrPc:RemoveField( 'FW0_CLASS' )
oStrPc:RemoveField( 'FW0_ADIANT')
oStrPc:RemoveField( 'FW0_VIAGE' )

/*
 * Remove Campos não Usados - Solicitação de Viagens
 */
oStrSv:RemoveField( 'FW0_CLASS' )
oStrSv:RemoveField( 'FW0_ADIANT')
oStrSv:RemoveField( 'FW0_PREST' )

/*
 * Adiciona Campos Virtuais
 */
oStrAd:AddField( 'OK' ,'01','','',, 'Check' ,,,,,,,,,,,, ) //''#//''
oStrPc:AddField( 'OK' ,'01','','',, 'Check' ,,,,,,,,,,,, ) //''#//''
oStrSv:AddField( 'OK' ,'01','','',, 'Check' ,,,,,,,,,,,, ) //''#//''

/*
 * Criar "box" horizontal para receber algum elemento da view
 */
oView:CreateHorizontalBox('BOXCABEC'	,0) //Cabeçalho
oView:CreateHorizontalBox('BOXAD'		,33) //Adiantamento
oView:CreateHorizontalBox('BOXPC'		,33) //Prestação de Contas
oView:CreateHorizontalBox('BOXSV'		,34) //Solicitação de Viagem

/*
 * Relaciona o ID da View com o "box" para exibicao
 */
oView:SetOwnerView('FORM_FAKE'		,'BOXCABEC' )	// Cabeçalho
oView:SetOwnerView('GRID_AD'		,'BOXAD' )	// 
oView:SetOwnerView('GRID_PC'		,'BOXPC')	// 
oView:SetOwnerView('GRID_SV'		,'BOXSV')	// 

/*
 * Habilita a exibição do titulo
 */
oView:EnableTitleView('GRID_AD'	, STR0001 ) //'Adiantamentos'
oView:EnableTitleView('GRID_PC'	, STR0002 ) //'Prestação de Contas'
oView:EnableTitleView('GRID_SV'	, STR0003 ) //'Solicitação de Viagem'

/*
 * Fecha a tela apos a gravação
 */
oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F688Carga

Realiza a carga de dados nas grides de acordo com a tabela FW0

@author julio.teixeira

@since 23/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F688Carga(oModel)

Local oModelFd	:= oModel:GetModel('FW0MASTER')
Local oModelG1	:= oModel:GetModel('GRID1')
Local oModelG2	:= oModel:GetModel('GRID2')
Local oModelG3	:= oModel:GetModel('GRID3')
Local oView		:= FWViewActive() 
Local nCont 		:= 1

Local aArea 		:= GetArea()

Local cAdiant	:= "1"
Local cPrest 	:= "2"
Local cViagem	:= "3"

//Atualiza o campo falso da field
oModelFd:SetValue("FWW_CPO","*")
	
DbSelectArea("FW0")	

For nCont := 1 to 3
	
	FW0->(DbSetOrder(1))//FILIAL+CLASSIFICASSÃO+ADIANTAMENTO
	//Adiantamento
	If oModelG1:IsEmpty()	
		If FW0->(DbSeek(xFilial("FW0")+cAdiant+"1"))
			oModelG1:SetValue("OK", .T. )
		Endif	
		oModelG1:SetValue("FW0_ADIANT", "1" )
	Elseif nCont == 2
		oModelG1:AddLine()		
		If FW0->(DbSeek(xFilial("FW0")+cAdiant+"2"))
			oModelG1:SetValue("OK", .T. )
		Endif
		oModelG1:SetValue("FW0_ADIANT", "2" )
	Else	
		oModelG1:AddLine()
		If FW0->(DbSeek(xFilial("FW0")+cAdiant+"3"))
			oModelG1:SetValue("OK", .T. )
		Endif
		oModelG1:SetValue("FW0_ADIANT", "3" )	
	Endif	
	oModelG1:SetValue("FW0_CLASS", "1" )	
	
	FW0->(DbSetOrder(2))//FILIAL+CLASSIFICASSÃO+PREST.CONTAS
	//Prestação de contas
	If oModelG2:IsEmpty()
		If FW0->(DbSeek(xFilial("FW0")+cPrest+"1"))
			oModelG2:SetValue("OK", .T. )
		Endif
		oModelG2:SetValue("FW0_PREST", "1" )
	Elseif nCont == 2
		oModelG2:AddLine()		
		If FW0->(DbSeek(xFilial("FW0")+cPrest+"2"))
			oModelG2:SetValue("OK", .T. )
		Endif
		oModelG2:SetValue("FW0_PREST", "2" )
	Else	
		oModelG2:AddLine()
		If FW0->(DbSeek(xFilial("FW0")+cPrest+"3"))
			oModelG2:SetValue("OK", .T. )
		Endif
		oModelG2:SetValue("FW0_PREST", "3" )	
	Endif	
	oModelG2:SetValue("FW0_CLASS", "2" )	
	
	FW0->(DbSetOrder(3))//FILIAL+CLASSIFICASSÃO+SOL.VIAGEM
	//Solicitação de viagem	
	If oModelG3:IsEmpty()
		If FW0->(DbSeek(xFilial("FW0")+cViagem+"1"))
			oModelG3:SetValue("OK", .T. )
		Endif
		oModelG3:SetValue("FW0_VIAGE", "1" )
		oModelG3:SetValue("FW0_CLASS", "3" )	
	Elseif nCont == 2
		oModelG3:AddLine()		
		If FW0->(DbSeek(xFilial("FW0")+cViagem+"2"))
			oModelG3:SetValue("OK", .T. )
		Endif
		oModelG3:SetValue("FW0_VIAGE", "2" )
		oModelG3:SetValue("FW0_CLASS", "3" )	
	Endif
			
Next nCont
/*
 * Bloqueia a inclusão de novas linhas
*/
If Type("oView") == "O"
	oView:SetNoInsertLine('GRID_AD')
	oView:SetNoInsertLine('GRID_PC')
	oView:SetNoInsertLine('GRID_SV')
	/*
	 * Bloqueia a exclusão de linhas do grid
	 */
	oView:SetNoDeleteLine('GRID_AD')
	oView:SetNoDeleteLine('GRID_PC')
	oView:SetNoDeleteLine('GRID_SV')
EndIf
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F688GRV

Prepara e realiza gravação dos dados na tabela

@author julio.teixeira

@since 23/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F688GRV(oModel)

Local oModelG1	:= oModel:GetModel('GRID1')
Local oModelG2	:= oModel:GetModel('GRID2')
Local oModelG3	:= oModel:GetModel('GRID3')
Local oView		:= FWViewActive() 
Local nCont 		:= 1
Local lRet 		:= .T.

/*
 * Desbloqueia a exclusão de linhas do grid
 */
oModelG1:SetNoDeleteLine(.F.)
oModelG2:SetNoDeleteLine(.F.)
oModelG3:SetNoDeleteLine(.F.)

For nCont := 1 to 3
	//Deleta os registros não selecionados
	oModelG1:GoLine(nCont)
	If !(oModelG1:GetValue("OK", nCont))
		Iif(oModelG1:IsDeleted(nCont),,oModelG1:DeleteLine())	
	Endif
		
	//Deleta os registros não selecionados		
	oModelG2:GoLine(nCont)
	If !(oModelG2:GetValue("OK", nCont))
		Iif(oModelG2:IsDeleted(nCont),,oModelG2:DeleteLine())		
	Endif
	
	//Deleta os registros não selecionados		
	If nCont <= 2
		oModelG3:GoLine(nCont)
		If !(oModelG3:GetValue("OK", nCont))
			Iif(oModelG3:IsDeleted(nCont),,oModelG3:DeleteLine())
		Endif
	Endif
Next nCont

/*
 * Limpa a tabela para a gravação apenas dos registros selecionados
 */
DbSelectArea("FW0")
SET FILTER TO FW0_FILIAL == cFilial
FW0->(DbGoTop())
While FW0->(!EOF()) 
	
	RecLock("FW0", .F.)
		FW0->(DbDelete())
	MsUnlock()
	
	FW0->(DbSkip())
Enddo
dbClearFilter()
//Grava no banco										
lRet := FWFormCommit(oModel)

Return lRet
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICAT400.CH"
#Include "TOPCONN.CH"

/*
Programa   : EICAT400
Objetivo   : Rotina - Cadastro de Atributos
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Mar/2020
Obs.       :
*/
function EICAT400(aCapaAuto,aItensAuto,nOpcAuto)
Local aArea := GetArea() 
Local oBrowse

Private aRotina
Private lAT400Auto := ValType(aCapaAuto) <> "U" .Or. ValType(aItensAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private lExibiuMsg := .F.
	
	If !lAT400Auto
	   oBrowse := FWMBrowse():New() //Instanciando a Classe
	   oBrowse:SetAlias("EKG") //Informando o Alias 
	   oBrowse:SetMenuDef("EICAT400") //Nome do fonte do MenuDef
	   oBrowse:SetDescription(STR0007) // "Cadastro de Atributos" 
	  	   	   
	   //Habilita a exibi��o de vis�es e gr�ficos
	   oBrowse:SetAttach( .T. )
	   	   
	   //For�a a exibi��o do bot�o fechar o browse para fechar a tela
	   oBrowse:ForceQuitButton()
	   
	   //Ativa o Browse                                                            
	   oBrowse:Activate()
	Else
	   //Defini��es de WHEN dos campos
	   INCLUI := nOpcAuto == INCLUIR
	   ALTERA := nOpcAuto == ALTERAR
	   EXCLUI := nOpcAuto == EXCLUIR
	
	   FWMVCRotAuto(ModelDef(), "EKG", nOpcAuto, {{"EKGMASTER",aCapaAuto}, {"EKHDETAIL",aItensAuto}/*{"EYYDETAIL",aNFRem}*/ })
	EndIf


RestArea(aArea)
Return Nil

/*
CLASSE PARA CRIA��O DE EVENTOS E VALIDA��ES NOS FORMUL�RIOS
RNLP - RAMON PRADO
 */
Class AT400EV FROM FWModelEvent
     
    Method New()
    Method Activate()
 
End Class
 
Method New() Class AT400EV
Return
 
Method Activate(oModel,lCopy) Class AT400EV
   AT400ATRIB(.T.)
Return

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001   	, "AxPesqui"			, 0, 1, 0, NIL } )	//'Pesquisar'
aAdd( aRotina, { STR0002	   , 'VIEWDEF.EICAT400'	, 0, 2, 0, NIL } )	//'Visualizar'
aAdd( aRotina, { STR0003   	, 'VIEWDEF.EICAT400'	, 0, 3, 0, NIL } )	//'Incluir'
aAdd( aRotina, { STR0004   	, 'VIEWDEF.EICAT400'	, 0, 4, 0, NIL } )	//'Alterar'
aAdd( aRotina, { STR0005   	, 'VIEWDEF.EICAT400'	, 0, 5, 0, NIL } )	//'Excluir'

aAdd( aRotina, {STR0011,"EICAT410",0,3,0,NIL}) //"Integrar Atributos"

Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ModelDef()
Local oStruEKG 			:= FWFormStruct( 1, "EKG", , /*lViewUsado*/ )
Local oStruEKH 			:= FWFormStruct( 1, "EKH", , /*lViewUsado*/ )
Local oModel			   // Modelo de dados que ser� constru�do	
Local oEvent				:= AT400EV():New()
Local bPosValidacao     := {|oModel| AT400POSVLD(oModel)}

// Cria��o do Modelo
oModel := MPFormModel():New( "EICAT400", /*bPreValidacao*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields("EKGMASTER", /*cOwner*/ ,oStruEKG )
//oModel:SetPrimaryKey( { "EKG_FILIAL", "","EKG_COD_I"} )	

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Rela��o de Produtos
oModel:AddGrid("EKHDETAIL","EKGMASTER", oStruEKH, /*bLinePre*/ ,/*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oStruEKH:RemoveField("EKH_COD_I")

//Modelo de rela��o entre Capa - Produto Referencia(EK9) e detalhe Rela��o de Produtos(EKA)
oModel:SetRelation('EKHDETAIL', { 		{ 'EKH_FILIAL'	, 'xFilial("EKH")'  },;
										{ 'EKH_NCM'		, 'EKG_NCM' 	},;
										{ 'EKH_COD_I'	, 'EKG_COD_I' 	}}, EKH->(IndexKey(1)) )
								
oModel:GetModel("EKHDETAIL"):SetUniqueLine({"EKH_CODDOM"} )

//Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel("EKGMASTER"):SetDescription(STR0007) //"Cadastro de Atributos"
oModel:SetDescription(STR0007) // "Cadastro de Atributos"
oModel:GetModel("EKHDETAIL"):SetDescription(STR0008) //'"Rela��o de Dom�nios de Atributos"
oModel:GetModel("EKHDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Dominio de Atrib.

oModel:InstallEvent("AT400EV", , oEvent)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ViewDef()
Local oStruEKG := FWFormStruct( 2, "EKG" )
Local oStruEKH := FWFormStruct( 2, "EKH" )
Local oView
Local oModel   := FWLoadModel( "EICAT400" )

//Cria o objeto de View
oView := FWFormView():New()

// Adiciona no nosso View um controle do tipo formul�rio 
//Define qual o Modelo de dados ser� utilizado na View
oView:SetModel( oModel )

// (antiga Enchoice)
oView:AddField( 'VIEW_EKG', oStruEKG, 'EKGMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKH",oStruEKH , "EKHDETAIL")
oStruEKH:RemoveField("EKH_COD_I")

// Novos Boxes
oView:CreateHorizontalBox( 'SUPERIOR' ,50  )
oView:CreateHorizontalBox( 'INFERIOR' , 50 )
// Relaciona o identificador (ID) da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_EKG', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_EKH', 'INFERIOR' )

Return oView

/*
Fun��o     : AT400Relac(cCampo)
Objetivo   : Inicializar dados dos campos do grid(Dominio de Atributos - Cad. de Atributos)
Par�metros : cCampo - campo a ser inicializado
Retorno    : cRet - Conteudo a ser inicializado
Autor      : Ramon Prado
Data       : Mar/2020
Revis�o    :
*/
Function AT400Relac(cCampo)
Local aArea 		:= getArea()
Local cRet 			:= "" 
Local oModel    	:= FWModelActive()
Local oModelEKG	:= oModel:GetModel("EKGMASTER")
Local aObjetivos	:= {}

If oModel:GetOperation() <> 3
	Do Case
      Case cCampo == "EKG_DSCOBJ"
			If oModel:cId == "EICAT400"
				aObjetivos := StrToKarr(oModelEKG:GetValue("EKG_CODOBJ"),";")
				cRet := AT400DObj(aObjetivos) 
			ElseIf oModel:cId== "EICCP400"
				aObjetivos := StrToKarr(M->EKG_CODOBJ,";")
				cRet := AT400DObj(aObjetivos) 
			EndIf		                                                                                                
	EndCase	
EndIf

RestArea(aArea)
Return cRet

/*
Fun��o     : AT400Valid()
Objetivo   : Validar dados digitados nos campos EKG e EKH
Par�metros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Autor      : Ramon Prado
Data       : Mar/2020
Revis�o    :
*/
Function AT400Valid(cCampo)
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelEKH		:= oModel:GetModel("EKHDETAIL")

Do Case
   Case cCampo == "EKG_NCM"
		lRet := ((Vazio() .Or. (M->EKG_NCM=="99999999" .or. ExistCpo("SYD",M->EKG_NCM))) .And. ;
					IIF(Empty(M->EKG_COD_I),.T., AT400Valid("EKG_COD_I")))
	Case cCampo == "EKH_NCM"	
		lRet := Vazio() .Or. (oModelEKH:GetValue("EKH_NCM")=="99999999" .or. ExistCpo("SYD",oModelEKH:GetValue("EKH_NCM")))
	Case cCampo == "EKG_COD_I"
		lRet := Existchav("EKG",M->EKG_NCM+M->EKG_COD_I,,"EXISTREG")
		EasyHelp(STR0009, STR0010, STR0014) //"Nao pode haver mais de um registro com mesmo Ncm e Cod. do Atributo." ## "Aten��o" ### "Verifique o conte�do destes campos e mude o Ncm ou o Cod. do Atributo."
EndCase		

Return lRet

/*
Fun��o     : AT400Trigg()
Objetivo   : Gatilho do campo 
Par�metros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Autor      : Ramon Prado
Data       : Mar/2020
Revis�o    :
*/
Function AT400Trigg()
Local aArea	:= getArea()	 
Local cRet := ""
Local cCpo   		:= AllTrim(Upper(ReadVar()))
Local aObjetivos	:= {} 

Do Case
	Case cCpo == "M->EKG_CODOBJ"				
		cRet := AT400DObj(aObjetivos) 
	Case cCpo == "M->EKH_DESCRE"	
		cRet := Substr(FwFldGet("EKH_DESCRE"),1,100)
EndCase

RestArea(aArea)
Return cRet

/*
Fun��o     : AT400DObj()
Objetivo   : Retorna preenchimento da descri��o do objetivo
Par�metros : Array contendo codigos de objetivos
Retorno    : cRet - Descri��o do Objetivo
Autor      : Ramon Prado
Data       : Mar/2020
Revis�o    :
*/
Function AT400DObj(aObj)
Local aArea := GetArea()
Local oModel		:= FWModelActive()
Local oModelEKG	:= oModel:GetModel("EKGMASTER")
Local cRet	:= ""

If Empty(aObj)
	aObj := StrToKarr(oModelEKG:GetValue("EKG_CODOBJ"),";")
EndIf

If Len(aObj) > 0
	If aScan(aObj, { |X| Alltrim(X) == "3"}) > 0
		cRet += "Tratamento Administrativo"+CRLF
	EndIf	
	If aScan(aObj,{|X| Alltrim(X) == "6"}) > 0
		cRet += "LPCO"+CRLF
	EndIf	
	If aScan(aObj,{|X| Alltrim(X) == "7"}) > 0
		cRet += "Produto"+CRLF
	EndIf		
EndIf

RestArea(aArea)
Return cRet

/*
Fun��o     : AT400ATRIB()
Objetivo   : Preenchimento do Resumo do campo memo
Par�metros : -
Retorno    : -
Autor      : Ramon Prado
Data       : Mar/2020
Revis�o    :
*/
Function AT400ATRIB(lAtrib)
Local aArea 		:= GetArea()
Local oModel		:= FWModelActive()
Local oModelEKH	:= oModel:GetModel("EKHDETAIL")
Local nI				:= 1
Local lExclui		:= .F.

If oModel:GetOperation() <> 3
	If oModel:GetOperation() == 5 //quando exclusao o comando LoadValue produz um Error, por isso sera a operacao sera setada para 4 e posteriormente restaurada 
		oModel:nOperation := 4
		lExclui				:= .T.
	EndIf
	For nI := 1 To oModelEKH:Length()
		oModelEKH:GoLine( nI )
		If !oModelEKH:IsDeleted()
			oModelEKH:LoadValue("EKH_RESUMO", Substr(oModelEKH:GetValue("EKH_DESCRE"),1,100))
		EndIf
	Next
	If(lExclui,oModel:nOperation := 5, )
EndIf

RestArea(aArea)
Return

/*
Fun��o     : AT400POSVLD()
Objetivo   : Fun��o para valida��o ap�s clique no salvar ou confirmar
Par�metros : oModel - objeto de modelo de dados - ModelDef
Retorno    : lRet - Retorno se .T. validado com sucesso e .F. N�o validado
Autor      : Ramon Prado
Data       : Julho/2021
*/
Static Function AT400POSVLD(oMdl)
Local oModelEKG	:= oMdl:GetModel("EKGMASTER")
Local lRet := .T.

If oMdl:GetOperation() == 5 //Exclus�o
   If AT400EXCLU(oModelEKG:GetValue("EKG_NCM"))
      EasyHelp(STR0012,STR0010, STR0013) //Problema:"Apenas � poss�vel excluir Atributo que n�o esteja sendo utilizado no Cat�logo de produtos."##"Aten��o" Solu��o:"Verifique a real necessidade de exclus�o do atributo j� que est� sendo utilizado em outro cadastro"
      lRet := .F.      
   EndIf
EndIf

Return lRet

/*
Fun��o     : AT400EXCLU()
Objetivo   : Fun��o que verifica se h� atributos do cat�logo de produtos utilizando a ncm.
Par�metros : oModel - objeto de modelo de dados - ModelDef
Retorno    : lRet - Retorno se .T. se encontrou atributo de cat�logo de prod e .F. se N�o encontrou
Autor      : Ramon Prado
Data       : Julho/2021
*/
Static Function AT400EXCLU(cNcmAt)
Local lRet := .F.
Local cQuery := ""
Local cTmpEK9	:= GetNextAlias() 

cQuery := "SELECT EK9_COD_I FROM " + RetSQLName("EK9") + " EK9" 
cQuery += " LEFT JOIN " + RetSQLName("EKC") + " EKC" 
cQuery += "    ON EKC.EKC_FILIAL = EK9.EK9_FILIAL"
cQuery += "       AND EKC.EKC_COD_I = EK9.EK9_COD_I"
cQuery += "       AND EK9.D_E_L_E_T_ = ' ' AND EKC.D_E_L_E_T_ = ' ' "
cQuery += " WHERE EK9.EK9_FILIAL = '" + xFilial("EK9") + "' "
cQuery += "   AND EK9.EK9_NCM =  '" + cNcmAt + "' "   

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmpEK9, .T., .T.)

If (cTmpEK9)->(!EOF())
	lRet := .T. //Encontrou atributo do cat�logo de produtos utilizando a ncm 
EndIf

Return lRet

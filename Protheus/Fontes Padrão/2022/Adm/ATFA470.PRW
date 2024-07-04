#INCLUDE "ATFA470.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*
@author Mauricio Pequim Jr
@since 04/09/2012
@version P11
*/
//-----------------------------------------------------------------

#DEFINE OPER_REVISAR		20
#DEFINE OPER_BLOQUEAR		21


Static __nOper 			:= 0 // Operacao da rotina
Static cMrgOld			:= ""
Static cRevOld			:= ""


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFA470  ³ Autor ³Mauricio Pequim Jr     ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Margens Gerenciais                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFA470()

Local oBrowse := NIL
Local lDefTop := IfDefTopCTB() // verificar se pode executar query (TOPCONN)

// Incluido por causa da rotina MSDOCUMENT, o MVC não precisa de nenhuma variável private
Private cCadastro := STR0001 // //"Cadastro de Regras de Margem Gerencial"
Private aRotina	:= MenuDef()

__nOper := 0

If !lDefTop
	Help("  ",1,"AFR470TOP",,STR0002 ,1,0) // //"Função disponível apenas para ambientes TopConnect" //"Função disponível apenas para ambientes TopConnect"
	Return
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FNQ')
oBrowse:SetDescription(STR0001) // //"Cadastro de Regras de Margem Gerencial"
oBrowse:AddLegend( "FNQ_MSBLQL=='1'", "RED", STR0003 ) // //"Bloqueada"
oBrowse:AddLegend( "FNQ_MSBLQL=='2' .AND. FNQ_STATUS == '1'", "GREEN", STR0004 ) // //"Ativa"
oBrowse:AddLegend( "FNQ_MSBLQL=='2' .AND. FNQ_STATUS == '2'", "BLACK", STR0005 )	 // //"Revisada"
oBrowse:DisableDetails()
oBrowse:Activate()                                   

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³04/09/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	1 - Pesquisa e Posiciona em um Banco de Dados			    ³±±
±±³          ³	2 - Simplesmente Mostra os Campos                        ³±±
±±³          ³	3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³	4 - Altera o registro corrente                          ³±±
±±³          ³	5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0007	Action 'PesqBrw'			OPERATION 1  ACCESS 0 // //"Pesquisar"
ADD OPTION aRotina Title STR0008	Action 'VIEWDEF.ATFA470'	OPERATION 2  ACCESS 0 // //"Visualizar"
ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.ATFA470'	OPERATION 3  ACCESS 0 // //"Incluir"
ADD OPTION aRotina Title STR0010	Action 'VIEWDEF.ATFA470'	OPERATION 4  ACCESS 0 // //"Alterar"
ADD OPTION aRotina Title STR0011	Action 'VIEWDEF.ATFA470'	OPERATION 5  ACCESS 0 // //"Excluir"
ADD OPTION aRotina Title STR0012	Action 'AF470REV'			OPERATION 20 ACCESS 0 // //"Revisar"
ADD OPTION aRotina Title STR0013	Action 'AF470BLQ'			OPERATION 21 ACCESS 0 // //"Bloquear"

Return aRotina


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MODELDEF ³ Autor ³Mauricio Pequim Jr.    ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que define o modelo do cadastro de projeto de  imob ³±±
±±³          ³ ilizado para o MVC                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel		:= NIL
Local oStruFNQ	:= FWFormStruct( 1, "FNQ")

oStruFNQ:AddTrigger( "FNQ_TIPO"  	, 'FNQ_VLRFIX'  		, {|| .T. }  , {|| 0 }  )
oStruFNQ:AddTrigger( "FNQ_TIPO"  	, 'FNQ_PERCEN'  		, {|| .T. }  , {|| 0 }  )

If __nOper == OPER_BLOQUEAR
	// Bloqueia todos os campos menos do bloqueio
	oStruFNQ:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	oStruFNQ:SetProperty('FNQ_MSBLQL', MODEL_FIELD_WHEN , {|| .T. } )
ElseIf __nOper == OPER_REVISAR
	oStruFNQ:SetProperty("FNQ_COD" , MODEL_FIELD_WHEN , {|| .F. } )
	oStruFNQ:SetProperty("FNQ_REV" , MODEL_FIELD_WHEN , {|| .F. } )
EndIf


IF __nOper != OPER_BLOQUEAR
	oStruFNQ:SetProperty('FNQ_MSBLQL', MODEL_FIELD_WHEN , {|| .F. } )
Endif

//Gatrilho FNQ_TIPO
oStruFNQ:AddTrigger( "FNQ_TIPO"  	, "FNQ_TIPO"  	    , {|| .T. }  , {|| AF470GTTP() }  )


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('ATFA470M', /*bPreValidacao*/, { |oModel| AF470VLTOK( oModel) }, { |oModel| AF470GRVMD( oModel ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul?rio de edi??o por campo
oModel:AddFields( 'FNQMASTER', /* cOwner */, oStruFNQ)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription(STR0001) // //"Cadastro de Regras de Margem Gerencial"

oModel:GetModel( 'FNQMASTER' ):SetDescription( STR0014) // //"Margem Gerencial"

oModel:SetVldActivate( {|oModel| AF470VLMod(oModel) } )

Return oModel




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Viewdef  ³ Autor ³Mauricio Pequim Jr.    ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que define a interface do cadastro de regras de     ³±±
±±³          ³ Margem Gerencial para o MVC                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel		:= FWLoadModel( 'ATFA470' )
Local oStruFNQ	:= FWFormStruct( 2, 'FNQ')
Local oView		:= NIL

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FNQ",oStruFNQ,"FNQMASTER")

Return oView



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF470ATU   ³ Autor ³ Ramon Prado		    ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Faz Bloqueio/Desbloqueio de Índices				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF470ATU()                                     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF470ATU()

Local aSaveArea	:= GetArea()
Local aSaveFNQ		:= FNQ->(GetArea())

If FNQ->FNQ_MSBLQL == "1"	//se campo bloqueio? == "1"  (sim)
	if MsgYesNo ( STR0015+Alltrim(FNQ->FNQ_DESC)+' '+STR0016+FNQ->FNQ_COD+'?',STR0017) //### // //"Você deseja desbloquear o Indice: "###"Código: "###"Desbloqueio"

		RecLock( 'FNQ', .F. )
		FNQ->FNQ_MSBLQL := "2"	//campo receberao "2"(nao)
		FNQ->(MsUnlock())
	endif
Else		             //senao, entao, sera == "2"(nao)//campo receberao "1"(sim)
	If MsgYesNo ( STR0018+Alltrim(FNQ->FNQ_DESC)+' '+STR0016+FNQ->FNQ_COD+'?',STR0019) // //### //"Você deseja bloquear o Indice: "###"Código: "###"Bloqueio"
		RecLock( 'FNQ', .F. )
		FNQ->FNQ_MSBLQL := "1"
		FNQ->(MsUnlock())
	endif
EndIf


RestArea(aSaveFNQ)
RestArea(aSaveArea)

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470WHEN ³ Autor ³ Mauricio Pequim Jr.  ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que define o acesso aos campos percentual e valor   ³±±
±±³          ³ fixo, de acordo com o conteudo do campo Tipo (FNQ_TIPO)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao que esta sendo avalidada                      ³±±
±±³          ³       1 - When do campo de percentual                      ³±±
±±³          ³       2 - When do campo de valor fixo                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF470WHEN(nOpc)
Local lRet	 := .F.
Local oModel	 := FWModelActive()
Local cTipo	 := oModel:GetValue("FNQMASTER","FNQ_TIPO")  //Tipo de Margem : 1 = Percentual; 2 = Valor Fixo

//nOpc = 1 - When do campo de percentual
//nOpc = 2 - When do campo de valor fixo

If nOpc == 1 .and. cTipo == "1"  //valida campo Percentual
	lRet := .T.
ElseIf nOpc == 2  .and. cTipo == "2" //valida campo Valor Fixo
	lRet := .T.
Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470VLMod ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a validação do modelo de dados do MVC			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AF470VLMod(oModel)

Local nOperation := oModel:GetOperation()
Local lRet := .T.


//Caso a regra esteja revisada e NAO for inclusao e NAO for visualizacao
If FNQ->FNQ_STATUS == "2" .and. ((nOperation != MODEL_OPERATION_INSERT ) .AND. (nOperation != 1 ))
	Help(" ",1,"AF430REV01",,STR0020 ,1,0) // //"Este regra possui revisão posterior, nao podendo sofrer qualquer ação."
	lRet := .F.
Endif


//ALTERACAO
If lRet .and. (nOperation == MODEL_OPERATION_UPDATE ) .AND. __nOper == 0

	//margens bloqueadas nao sofrem alteracoes
	If FNQ->FNQ_MSBLQL == '1'	
		Help(" ",1,"AF430ALTBLQ",,STR0021 ,1,0) // //"Este registro não pode ser alterado pois o mesmo encontra-se bloqueado."
		lRet := .F.
	Endif

	//margens relacionadas a fichas de ativo nao sao alteraveis
	If  lRet .And. Af470TemATF(FNQ->FNQ_COD, FNQ->FNQ_REV)
		Help(" ",1,"AF430STAALT",,STR0022 ,1,0) // //"Regra de Margem possui fichas de ativo relacionadas. Efetue uma Revisão para alterar informações"
		lRet := .F.
	Endif

EndIf

//EXCLUSAO
If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .AND.  __nOper == 0

	//margens bloqueadas nao podem ser excluidos
	If FNQ->FNQ_MSBLQL == '1'	
		Help(" ",1,"AF430DELBLQ",,STR0035 ,1,0) //"Este registro não pode ser excluido pois o mesmo encontra-se bloqueado."
		lRet := .F.
	Endif

	//margens relacionadas a fichas de ativo nao sao alteraveis
	If lRet .And. Af470TemATF(FNQ->FNQ_COD, FNQ->FNQ_REV)
		Help(" ",1,"AF430STAALT",,STR0023 ,1,0) // //"Regra de Margem possui fichas de ativo relacionadas. Dessa forma não será possivel excluir este registro. Utilize a rotina de bloqueio para desativar esta regra."
		lRet := .F.
	Endif

EndIf

Return lRet



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Af470TemATF ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a relacao se existe ficha de imobilizado utilizando³±±
±±³          ³ a regra de margem gerencial que se deseja atualizar         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodNrg - Codigo da regra de margem gerencial               ³±±
±±³          ³ cRevMrg - Revisao da regra de margem gerencial              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Af470TemATF(cCodMrg, cRevMrg)

Local lRet 		:= .F.
Local cQuery 	:= ""
Local aArea		:= GetArea()
Local cAliasQry := "CHKSN1MRG"

cQuery := " SELECT COUNT(*) SN1MARGEM "
cQuery += " FROM " + RetSqlName("SN1") + " SN1 "
cQuery += " WHERE SN1.N1_FILIAL  = '" + xFilial("SN1") + "' AND "
cQuery += "       SN1.N1_MARGEM  = '" + cCodMrg + "' AND "
cQuery += "       SN1.N1_REVMRG  = '" + cRevMrg + "' AND "
cQuery += "       SN1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
If (cAliasQry)->SN1MARGEM > 0
	lRet := .T.
EndIf

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return lRet

    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470GTTP ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 06/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho para atualização dos campos de percentual ou valor  ³±±
±±³          ³ fixo quando alterado o conteudo do campo tipo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF470GTTP()

Local oModel	:= FWModelActive()
Local cTipo		:= oModel:GetValue("FNQMASTER","FNQ_TIPO")
Local aArea		:= GetArea()
Local nOperation := oModel:GetOperation()

If (nOperation == MODEL_OPERATION_UPDATE  .AND. __nOper == 0) .or. __nOper == OPER_REVISAR

	If cTipo == "1"  //Percentual
		oModel:LoadValue("FNQMASTER","FNQ_VLRFIX", 0 )			
	Else			//Valor Fixo
		oModel:LoadValue("FNQMASTER","FNQ_PERCEN", 0 )	
	Endif

EndIf

RestArea(aArea)


Return cTipo


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470BLQ  ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 06/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bloqueio/Desbloqueio de regra de margem gerencial           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF470BLQ(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo		:= ""
Local cPrograma		:= ""
Local nOperation	:= 0
Local cCodMrg		:= FNQ->FNQ_COD
Local cRevMrg		:= FNQ->FNQ_REV
Local lRet			:= .T.

If FNQ->FNQ_MSBLQL == "1" //Registro Bloqueado

	If  Af470RevPos(cCodMrg, cRevMrg)
		Help(" ",1,"AF470BLOQ",,STR0024,1,0) // //"Não é possivel desbloquear regras de margem gerencial que possuam revisão posterior"
		lRet := .F.
	Endif

EndIf

If lRet
	__nOper		:= OPER_BLOQUEAR
	cTitulo		:= STR0025 // //"Margem Gerencial - Bloqueio/Desbloqueio"
	cPrograma    := 'ATFA470'
	nOperation	:= MODEL_OPERATION_UPDATE
	bOk				:= {|| lRet := MsgNoYes(STR0026) }  // //"Deseja realizar o bloqueio/desbloqueio da regra de margem gerencial ? "
	nRet			:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper      := 0
EndIf

RestArea(aArea)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Af470RevPos ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a se existe regra de margem gerencial posterior a  ³±±
±±³          ³ regra atual                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodNrg - Codigo da regra de margem gerencial               ³±±
±±³          ³ cRevMrg - Revisao da regra de margem gerencial              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Af470RevPos(cCodMrg, cRevMrg)

Local lRet 		:= .F.
Local cQuery 	:= ""
Local aArea		:= GetArea()
Local cAliasQry := "CHKFNQMRG"

cQuery := " SELECT COUNT(*) FNQMARGEM "
cQuery += " FROM " + RetSqlName("FNQ") + " FNQ "
cQuery += " WHERE FNQ.FNQ_FILIAL = '"  + xFilial("FNQ") + "' AND "
cQuery += "       FNQ.FNQ_COD    = '"  + cCodMrg + "' AND "
cQuery += "       FNQ.FNQ_REV    > '"  + cRevMrg + "' AND "
cQuery += "       FNQ.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
If (cAliasQry)->FNQMARGEM > 0
	lRet := .T.
EndIf

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA430CPYºAutor  ³Alvaro Camillo Neto º Data ³  12/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a cópia do projeto                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF470REV(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local lRet          := .T.
Local cRevNew		:= ""

If FNQ->FNQ_MSBLQL == "1"  //Registro Bloqueado
	Help(" ",1,"AF470REVB",,STR0027+CRLF+STR0028,1,0) //### //"Não é possivel revisar regras de margem gerencial que estajam bloqueadas."###"Desbloqueie a regra, se possível, antes de revisá-la."
	lRet := .F.
ElseIf FNQ->FNQ_STATUS == '2' //Registro revisado
	Help(" ",1,"AF470REVR",,STR0029+CRLF+STR0030,1,0) //### //"Não é possivel revisar regras de margem gerencial que possuam revisão posterior"###"Apenas revisões ativas são passíveis de revisão."
	lRet := .F.
EndIf


If lRet
	
	cMrgOld  := FNQ->FNQ_COD
	cRevOld  := FNQ->FNQ_REV
	
	If FNQ->(MsSeek(xFilial("FNQ") + cMrgOld + cRevOld))
		__nOper      := OPER_REVISAR
		cTitulo      := STR0031 // //"Revisão"
		cPrograma    := 'ATFA470'
		nOperation   := MODEL_OPERATION_INSERT
		oModel       := FWLoadModel( cPrograma )
		oModel:SetOperation( nOperation ) // Inclusão
		oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	
		cRevNew :=	AF470INREV()
	
		oModel:LoadValue("FNQMASTER","FNQ_COD",cMrgOld)
		oModel:LoadValue("FNQMASTER","FNQ_REV",cRevNew)		
	
		nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T.} , {|oModel| A470ConfVs(oModel) }/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
		oModel:DeActivate()
		__nOper      := 0
		
	EndIf
Endif
	
RestArea(aArea)

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470INREV  ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 06/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a revisão do projeto conforme operação              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF470INREV()

Local cRevisao 		:= STRZERO(1,TamSx3("FNQ_REV")[1] )
Local aArea			:= GetArea()
Local aAreaFNQ		:= FNQ->(GetArea())
Local cCodMrg		:= ""

FNQ->(dbSetOrder(1)) //FNQ_FILIAL+FNQ_COD+FNQ_REV

If __nOper == OPER_REVISAR
	cCodMrg  := FNQ->FNQ_COD
	cRevisao := AF470GetRev(cCodMrg)
	cRevisao := Soma1(cRevisao)
EndIf

RestArea(aAreaFNQ)
RestArea(aArea)

Return cRevisao


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470GetRev ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 06/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a ultima revisão da regra de margem gerencial       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF470GetRev(cCodMrg)

Local cRet     := ""
Local aArea    := GetArea()
Local aAreaFNQ := FNQ->(GetArea())

FNQ->(DBSetOrder(2)) ////FNQ_FILIAL+FNQ_COD+FNQ_STATUS

If FNQ->(MsSeek(xFilial("FNQ") + cCodMrg + "1" ))
	cRet := FNQ->FNQ_REV
EndIf

RestArea(aAreaFNQ)
RestArea(aArea)

Return cRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Af470GrvMod ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 05/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava model                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodNrg - Codigo da regra de margem gerencial               ³±±
±±³          ³ cRevMrg - Revisao da regra de margem gerencial              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AF470GRVMD( oModel )

Local aArea		:= {}
Local aAreaFNQ	:= {}

//Realiza a gravação do Modelo
FWFormCommit( oModel )

aArea		:= GetArea()
aAreaFNQ	:= FNQ->(GetArea())

If __nOper == OPER_REVISAR
	
	FNQ->(dbSetOrder(1))
	If FNQ->(MsSeek(xFilial("FNQ")+ cMrgOld + cRevOld))
		
		RecLock("FNQ",.F.)
		FNQ->FNQ_STATUS := '2'			
		MsUnLock()

	Endif

EndIf

RestArea(aAreaFNQ)
RestArea(aArea)

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A470ConfVs ³ Autor ³ Mauricio Pequim Jr.³ Data ³ 06/09/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria nova revisão da regra de margem gerencial              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A470ConfVs(oModel)

Local lRet		:= .F.
Local cTipo
Local nValor
Local nPerc

Default oModel	:= FWModelActive()

cTipo	:= oModel:GetValue("FNQMASTER","FNQ_TIPO")
nValor	:= oModel:GetValue("FNQMASTER","FNQ_VLRFIX")
nPerc	:= oModel:GetValue("FNQMASTER","FNQ_PERCEN")


If __nOper == OPER_REVISAR .and. MsgNoYes(STR0032) // //"Deseja gravar a operação, bloqueando a revisão anterior e gerando nova revisão ? "

	//Percentual
	If cTipo == "1" .and. nPerc == 0  
		Help(" ",1,"AF470REV1",,STR0033,1,0) // //"Favor preencher o percentual referente a margem gerencial."
	//Valor Fixo
	ElseIf cTipo == "2" .and. nValor == 0  	
		Help(" ",1,"AF470REV2",,STR0034,1,0) // //"Favor preencher o valor fixo referente a margem gerencial."
	Else
		lRet := .T.
	Endif

EndIf

Return lRet



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF470VLTOK ³ Autor ³ Mauricio Pequim Jr.³ Data ³ 06/09/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ valida percentual / quantidade estao preenchido             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA470                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF470VLTOK(oModel)

Local nOperation := oModel:GetOperation()
Local lRet := .T.


cTipo	:= oModel:GetValue("FNQMASTER","FNQ_TIPO")
nValor	:= oModel:GetValue("FNQMASTER","FNQ_VLRFIX")
nPerc	:= oModel:GetValue("FNQMASTER","FNQ_PERCEN")

//INCLUSAO
If lRet .and. (nOperation == MODEL_OPERATION_INSERT ) .AND. __nOper == 0

    //percentual
	If lRet .and. cTipo == "1" .and. nPerc == 0  
		Help(" ",1,"AF470PERC",,STR0033,1,0) // //"Favor preencher o percentual referente a margem gerencial."
		lRet := .F.
	EndIf
	//Valor Fixo
	If lRet .and. cTipo == "2" .and. nValor == 0  	
		Help(" ",1,"AF470VLR",,STR0034,1,0) // //"Favor preencher o valor fixo referente a margem gerencial."
		lRet := .F.
	EndIf	

EndIf


//ALTERACAO
If lRet .and. (nOperation == MODEL_OPERATION_UPDATE ) .AND. __nOper == 0

	//Percentual
	If lRet .and. cTipo == "1" .and. nPerc == 0  
		Help(" ",1,"AF470PERC",,STR0033,1,0) // //"Favor preencher o percentual referente a margem gerencial."
		lRet := .F.
	EndIf
	//Valor Fixo
	If lRet .and. cTipo == "2" .and. nValor == 0  	
		Help(" ",1,"AF470VLR",,STR0034,1,0) // //"Favor preencher o valor fixo referente a margem gerencial."
		lRet := .F.
	EndIf	
	
EndIf

Return(lRet)
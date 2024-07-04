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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?ATFA470  ?Autor 矼auricio Pequim Jr     ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Cadastro de Margens Gerenciais                             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?SIGAATF                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Function ATFA470()

Local oBrowse := NIL
Local lDefTop := IfDefTopCTB() // verificar se pode executar query (TOPCONN)

// Incluido por causa da rotina MSDOCUMENT, o MVC n鉶 precisa de nenhuma vari醰el private
Private cCadastro := STR0001 // //"Cadastro de Regras de Margem Gerencial"
Private aRotina	:= MenuDef()

__nOper := 0

If !lDefTop
	Help("  ",1,"AFR470TOP",,STR0002 ,1,0) // //"Fun玢o dispon韛el apenas para ambientes TopConnect" //"Fun玢o dispon韛el apenas para ambientes TopConnect"
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  矼enuDef   ?Autor ?Mauricio Pequim Jr    ?Data ?4/09/12  潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Utilizacao de menu Funcional                               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   矨rray com opcoes da rotina.                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros砅arametros do array a Rotina:                               潮?
北?         ?. Nome a aparecer no cabecalho                             潮?
北?         ?. Nome da Rotina associada                                 潮?
北?         ?. Reservado                                                潮?
北?         ?. Tipo de Transa噭o a ser efetuada:                        潮?
北?         ?1 - Pesquisa e Posiciona em um Banco de Dados			    潮?
北?         ?2 - Simplesmente Mostra os Campos                        潮?
北?         ?3 - Inclui registros no Bancos de Dados                 潮?
北?         ?4 - Altera o registro corrente                          潮?
北?         ?5 - Remove o registro corrente do Banco de Dados        潮?
北?         ?. Nivel de acesso                                          潮?
北?         ?. Habilita Menu Funcional                                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?MODELDEF ?Autor 矼auricio Pequim Jr.    ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Fun玢o que define o modelo do cadastro de projeto de  imob 潮?
北?         ?ilizado para o MVC                                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA470                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?Viewdef  ?Autor 矼auricio Pequim Jr.    ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Fun玢o que define a interface do cadastro de regras de     潮?
北?         ?Margem Gerencial para o MVC                                潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA470                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噭o    矨F470ATU   ?Autor ?Ramon Prado		    ?Data ?30/09/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri玢o ?Faz Bloqueio/Desbloqueio de 蚽dices				           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   矨F470ATU()                                     			  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA470                                                   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF470ATU()

Local aSaveArea	:= GetArea()
Local aSaveFNQ		:= FNQ->(GetArea())

If FNQ->FNQ_MSBLQL == "1"	//se campo bloqueio? == "1"  (sim)
	if MsgYesNo ( STR0015+Alltrim(FNQ->FNQ_DESC)+' '+STR0016+FNQ->FNQ_COD+'?',STR0017) //### // //"Voc?deseja desbloquear o Indice: "###"C骴igo: "###"Desbloqueio"

		RecLock( 'FNQ', .F. )
		FNQ->FNQ_MSBLQL := "2"	//campo receberao "2"(nao)
		FNQ->(MsUnlock())
	endif
Else		             //senao, entao, sera == "2"(nao)//campo receberao "1"(sim)
	If MsgYesNo ( STR0018+Alltrim(FNQ->FNQ_DESC)+' '+STR0016+FNQ->FNQ_COD+'?',STR0019) // //### //"Voc?deseja bloquear o Indice: "###"C骴igo: "###"Bloqueio"
		RecLock( 'FNQ', .F. )
		FNQ->FNQ_MSBLQL := "1"
		FNQ->(MsUnlock())
	endif
EndIf


RestArea(aSaveFNQ)
RestArea(aSaveArea)

Return Nil


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?AF470WHEN ?Autor ?Mauricio Pequim Jr.  ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Funcao que define o acesso aos campos percentual e valor   潮?
北?         ?fixo, de acordo com o conteudo do campo Tipo (FNQ_TIPO)    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA470                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?nOpc - Opcao que esta sendo avalidada                      潮?
北?         ?      1 - When do campo de percentual                      潮?
北?         ?      2 - When do campo de valor fixo                      潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?AF470VLMod ?Autor ?Mauricio Pequim Jr. ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Realiza a valida玢o do modelo de dados do MVC			    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA470                                                    潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/

Static Function AF470VLMod(oModel)

Local nOperation := oModel:GetOperation()
Local lRet := .T.


//Caso a regra esteja revisada e NAO for inclusao e NAO for visualizacao
If FNQ->FNQ_STATUS == "2" .and. ((nOperation != MODEL_OPERATION_INSERT ) .AND. (nOperation != 1 ))
	Help(" ",1,"AF430REV01",,STR0020 ,1,0) // //"Este regra possui revis鉶 posterior, nao podendo sofrer qualquer a玢o."
	lRet := .F.
Endif


//ALTERACAO
If lRet .and. (nOperation == MODEL_OPERATION_UPDATE ) .AND. __nOper == 0

	//margens bloqueadas nao sofrem alteracoes
	If FNQ->FNQ_MSBLQL == '1'	
		Help(" ",1,"AF430ALTBLQ",,STR0021 ,1,0) // //"Este registro n鉶 pode ser alterado pois o mesmo encontra-se bloqueado."
		lRet := .F.
	Endif

	//margens relacionadas a fichas de ativo nao sao alteraveis
	If  lRet .And. Af470TemATF(FNQ->FNQ_COD, FNQ->FNQ_REV)
		Help(" ",1,"AF430STAALT",,STR0022 ,1,0) // //"Regra de Margem possui fichas de ativo relacionadas. Efetue uma Revis鉶 para alterar informa珲es"
		lRet := .F.
	Endif

EndIf

//EXCLUSAO
If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .AND.  __nOper == 0

	//margens bloqueadas nao podem ser excluidos
	If FNQ->FNQ_MSBLQL == '1'	
		Help(" ",1,"AF430DELBLQ",,STR0035 ,1,0) //"Este registro n鉶 pode ser excluido pois o mesmo encontra-se bloqueado."
		lRet := .F.
	Endif

	//margens relacionadas a fichas de ativo nao sao alteraveis
	If lRet .And. Af470TemATF(FNQ->FNQ_COD, FNQ->FNQ_REV)
		Help(" ",1,"AF430STAALT",,STR0023 ,1,0) // //"Regra de Margem possui fichas de ativo relacionadas. Dessa forma n鉶 ser?possivel excluir este registro. Utilize a rotina de bloqueio para desativar esta regra."
		lRet := .F.
	Endif

EndIf

Return lRet



/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?Af470TemATF ?Autor ?Mauricio Pequim Jr. ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Verifica a relacao se existe ficha de imobilizado utilizando潮?
北?         ?a regra de margem gerencial que se deseja atualizar         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cCodNrg - Codigo da regra de margem gerencial               潮?
北?         ?cRevMrg - Revisao da regra de margem gerencial              潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?AF470GTTP ?Autor ?Mauricio Pequim Jr.   ?Data ?06/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Gatilho para atualiza玢o dos campos de percentual ou valor  潮?
北?         ?fixo quando alterado o conteudo do campo tipo               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?SIGAATF                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?Nenhum                                                      潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?AF470BLQ  ?Autor ?Mauricio Pequim Jr.   ?Data ?06/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Bloqueio/Desbloqueio de regra de margem gerencial           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?SIGAATF                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?Nenhum                                                      潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
		Help(" ",1,"AF470BLOQ",,STR0024,1,0) // //"N鉶 ?possivel desbloquear regras de margem gerencial que possuam revis鉶 posterior"
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?Af470RevPos ?Autor ?Mauricio Pequim Jr. ?Data ?04/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Verifica a se existe regra de margem gerencial posterior a  潮?
北?         ?regra atual                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cCodNrg - Codigo da regra de margem gerencial               潮?
北?         ?cRevMrg - Revisao da regra de margem gerencial              潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨FA430CPY篈utor  矨lvaro Camillo Neto ?Data ? 12/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza a c髉ia do projeto                                 罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                        罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
	Help(" ",1,"AF470REVB",,STR0027+CRLF+STR0028,1,0) //### //"N鉶 ?possivel revisar regras de margem gerencial que estajam bloqueadas."###"Desbloqueie a regra, se poss韛el, antes de revis?la."
	lRet := .F.
ElseIf FNQ->FNQ_STATUS == '2' //Registro revisado
	Help(" ",1,"AF470REVR",,STR0029+CRLF+STR0030,1,0) //### //"N鉶 ?possivel revisar regras de margem gerencial que possuam revis鉶 posterior"###"Apenas revis鮡s ativas s鉶 pass韛eis de revis鉶."
	lRet := .F.
EndIf


If lRet
	
	cMrgOld  := FNQ->FNQ_COD
	cRevOld  := FNQ->FNQ_REV
	
	If FNQ->(MsSeek(xFilial("FNQ") + cMrgOld + cRevOld))
		__nOper      := OPER_REVISAR
		cTitulo      := STR0031 // //"Revis鉶"
		cPrograma    := 'ATFA470'
		nOperation   := MODEL_OPERATION_INSERT
		oModel       := FWLoadModel( cPrograma )
		oModel:SetOperation( nOperation ) // Inclus鉶
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?AF470INREV  ?Autor ?Mauricio Pequim Jr. ?Data ?06/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Retorna a revis鉶 do projeto conforme opera玢o              潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?AF470GetRev ?Autor ?Mauricio Pequim Jr. ?Data ?06/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Retorna a ultima revis鉶 da regra de margem gerencial       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?Af470GrvMod ?Autor ?Mauricio Pequim Jr. ?Data ?05/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Grava model                                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cCodNrg - Codigo da regra de margem gerencial               潮?
北?         ?cRevMrg - Revisao da regra de margem gerencial              潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/

Static Function AF470GRVMD( oModel )

Local aArea		:= {}
Local aAreaFNQ	:= {}

//Realiza a grava玢o do Modelo
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北矲un噮o    ?A470ConfVs ?Autor ?Mauricio Pequim Jr.?Data ?06/09/12   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escricao ?Cria nova revis鉶 da regra de margem gerencial              潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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


If __nOper == OPER_REVISAR .and. MsgNoYes(STR0032) // //"Deseja gravar a opera玢o, bloqueando a revis鉶 anterior e gerando nova revis鉶 ? "

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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北矲un噮o    ?AF470VLTOK ?Autor ?Mauricio Pequim Jr.?Data ?06/09/12   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escricao ?valida percentual / quantidade estao preenchido             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      ?ATFA470                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
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

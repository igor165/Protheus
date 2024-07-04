#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA806
Funcao para abrir Agendamento de Captação
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPS4(lAutoma)

Local oBrowse
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 //Para fins de automação

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B4K')
oBrowse:SetDescription('Lote RPS')
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS5' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'processa( {|| PRPS5ZZZ()}, "Geração de Lote RPS", "Verificando base de dados...", .f.)'		Operation 3 Access 0 //processa( {|| PLSEEXC(nPos) }, "Protocolo", "Excluindo registros...", .f.)
Add Option aRotina Title 'Gerar RPS'  Action 'PRPSIMPARQ()' 	Operation 4 Access 0
Add Option aRotina Title 'Informar negativa ANS'  Action 'PLRPSNEG(.F.)' Operation 4 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
Local oStrB4K:= FWFormStruct(1,'B4K')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSRPS4' , , {|| PLSRPS4VLD(oModel) }) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB4K',/*cOwner*/,oStrB4K)  // Adiciona ao modelo um componente de formulário

oModel:GetModel('MasterB4K'):SetDescription('Lote RPS') // Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B4K_FILIAL", "B4K_CODOPE", "B4K_NUMLOT"} )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS4' ) // Cria as estruturas a serem usadas na View
Local oStrB4K:= FWFormStruct(2, 'B4K' )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB4K' , oStrB4K,'MasterB4K' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oView:SetOwnerView('ViewB4K','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS4VLD
Validação e confirmação da geração do lote RPS
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSRPS4VLD(oModel)

Local cMsg := ""
Local lRet := .F.
Local oB4K := oModel:getModel("MasterB4K")

oModel:Activate()

If PLSRPSCHK(oB4K:getvalue("B4K_TIPARQ"), oB4K:getValue("B4K_CODOPE"),oB4K:getValue("B4K_TIPCAB") )	
//	Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
	Help(NIL, NIL, 'Não é possível Incluir', NIL, 'Não é possível incluir um lote deste tipo, pois há outro do mesmo tipo em aberto.', 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para incluir um novo é necessário finalizar o atualmente aberto"})
else
	cMsg += " Será gerado um novo lote RPS com os seguinte parâmetros: " + CRLF
	cMsg += " - Tipo de Lote : " + oB4K:getvalue("B4K_TIPARQ") + CRLF
	cMsg += " - Isenção ônus : " + oB4K:getvalue("B4K_ISENON") + CRLF
	cMsg += " - Número da GRU: " + oB4K:getvalue("B4K_NUMGRU") + CRLF
	cMsg += CRLF + " Confirma a geração? "
	If MsgYesNo( cMsg, "Confirmação da geração")
		lRet := .T.
	else
		Help(NIL, NIL, 'Informação', NIL, 'Geração Cancelada', 1, 0, NIL, NIL, NIL, NIL, NIL)
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRPSNEG
Informa o retorno negativo da ANS quanto à um arquivo gerado
@author Oscar Zanin
@since 15/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLRPSNEG(lAutoma)
Local lProcessa := .F.
Local cCodOpe	  := PLSINTPAD()
Local cStaRPS	  := ""
Local cAntRPS	  := ""
Local lret := .F.
default lAutoma := iif(valtype(lAutoma) <> "L", .F., lAutoma )	

//0=Inclusão;1=Alteração;2=Vinculação;3=Exclusão
//B4K_TIPARQ
//0=Nao Enviado; 1=Enviado; 2=Excluido;3=Enviar Alteração;4=enviar Exclusão
If  B4K->B4K_STATUS == "1"
	If lAutoma .Or. MsgYesNo("Esta opção deve ser utilizada para informar que um arquivo não foi acatado pela ANS." + CRLF + "Deseja prosseguir?")
		If lAutoma .Or. MsgYesNo("O lote atual será Aberto para que as inconsistências possam ser corrigidas na base de dados, confirma a ação?")
			Begin Transaction
				B5B->(dbSetOrder(1))
				BAU->(dbsetOrder(1))
				lProcessa := .T.
				B4K->(RecLock("B4K", .f.))
					B4K->B4K_STATUS := "0"
					B4K->B4K_DATARQ := dDataBase
				B4K->(MsUnLock())
				
				If B4K->B4K_TIPARQ == "0"
					cStaRPS := "0"
					cAntRPS := "1"
				elseif B4K->B4K_TIPARQ == "1"
					cStaRPS := "3"
					cAntRPS := "1"
				elseIf B4K->B4K_TIPARQ == "3"
					cStaRPS := "4"
					cAntRPS := "2"
				endIf
				
				If !(EmpTy(cStaRPS))
					B5B->(MsSeek(xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT))
					While xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT == B5B->(B5B_FILIAL+B5B_CODOPE+B5B_NUMLOT) .AND. !(B5B->(eoF()))
						If BAU->(msSeek(xfilial("BAU") + B5B->B5B_CODRDA)) .AND. BAU->BAU_ENVRPS == cAntRPS
							BAU->(RecLock("BAU", .f.))
								BAU->BAU_ENVRPS := cStaRPS
							BAU->(MsUnLock())
						endIf
						B5B->(dbskip())
					EndDo
				endIf
			end transaction
		endIf
	EndIf
else
	Help(NIL, NIL, "Atenção", NIL, "Esta opção deve ser utilizada somente após o envio do arquivo e retorno negativo da ANS. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"O registro atual está com situação 'em Aberto', pois o arquivo ainda não foi gerado"})
endIf
If !lProcessa
	Help(NIL, NIL, "Atenção", NIL, "Operação Não realizada", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
Else
	lret := .T.
	Help(NIL, NIL, "Atenção", NIL, "Operação Concluída", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
endIf

Return lret
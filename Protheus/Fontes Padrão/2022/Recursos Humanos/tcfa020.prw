#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"			
#INCLUDE "TCFA020.CH"
#include "FILEIO.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão      ³ TCFA020  ³ Autor ³ Rogerio Ribeiro da Cruz           ³ Data ³ 02/03/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Cadastro de Artefatos  (RH2)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ TCFA020()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv. ³24/07/2014³TQEA22          ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³              ³          ³                ³a limpeza.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA020
Cadastro de Artefatos

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA020()
	Local oMBrowse

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("RH2")
	oMBrowse:Activate()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@return aRotina - Estrutura
			[n,1] Nome a aparecer no cabecalho
			[n,2] Nome da Rotina associada
			[n,3] Reservado
			[n,4] Tipo de Transação a ser efetuada:
				1 - Pesquisa e Posiciona em um Banco de Dados
				2 - Simplesmente Mostra os Campos
				3 - Inclui registros no Bancos de Dados
				4 - Altera o registro corrente
				5 - Remove o registro corrente do Banco de Dados
				6 - Alteração sem inclusão de registros
				7 - Cópia
				8 - Imprimir
			[n,5] Nivel de acesso
			[n,6] Habilita Menu Funcional

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.TCFA020" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0		//"Visualizar" 
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TCFA020" OPERATION MODEL_OPERATION_INSERT	 ACCESS 0		//"Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TCFA020" OPERATION MODEL_OPERATION_UPDATE	 ACCESS 143		//"Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TCFA020" OPERATION MODEL_OPERATION_DELETE	 ACCESS 144		//"Excluir"
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruRH2	:= FWFormStruct(1, "RH2")
	// Blocos de codigo do modelo
    Local bTdOkModel 	:= { |oMdl| Tc020TdOkModel( oMdl )}

	oStruRH2:SetProperty('RH2_DTFIM',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "ValidDTFIM()" ))
	oModel:= MPFormModel():New("TCFA020", , bTdOkModel)

	oModel:AddFields("TCFA020_RH2", NIL,  oStruRH2)
		
	//Seta um bloco que sera chamado antes do Activate do model
	//oModel:SetVldActivate(bVldActModel)
Return(oModel)


Function ValidDTFIM()
Local lRet 			:= .T.
Local oModel 		:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local cMod			:= "TCFA020_RH2"
	
If nOperation == 4 .or. nOperation == 3
	If !Empty(oModel:GetValue(cMod,'RH2_DTFIM'))
		If oModel:GetValue(cMod,'RH2_DTFIM') < oModel:GetValue(cMod,'RH2_DTINI')
			lRet := .F.
		EndIf	
	EndIf
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da visualização de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oStructRH2
	Local oModel := FWLoadModel("TCFA020")
	
	oView := FWFormView():New()

	oStructRH2 := FWFormStruct(2, "RH2")

	oView:SetModel(oModel)
	oView:AddField( "TCFA020_RH2" , oStructRH2)   
	oView:CreateHorizontalBox("ALL", 100)
    
	//Apenas se optarem futuramente por inserir no menu
	// Criar novo botao na barra de botoes
	//oView:AddUserButton( 'Inclui arquivo', 'CLIPS', { |oView| tcfIncArq() } ) 
	
	oView:SetOwnerView("TCFA020_RH2", "ALL")
	oView:EnableControlBar(.T.)  
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewWebDef
Gera o XML para Web

@author Rogerio Ribeiro da Cruz
@since 29/06/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return oView:GetXML2Web(nOperation, cPk, cFormMVC)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc020TdOkModel³ Autor ³ Emerson Campos        ³ Data ³ 03/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Tudo OK                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ lRet := >t. ou .F.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA020                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc020TdOkModel(oModel)
Local nOperation 	:= oModel:GetOperation()
Local lRet 			:= .T.
Local lLink := valRelacAcao(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO' ), oModel:GetValue( 'TCFA020_RH2', 'RH2_TIPO' )) .AND. oModel:GetValue( 'TCFA020_RH2', 'RH2_TIPO' ) == "2" 
Local lArq	:= !lLink .AND. oModel:GetValue( 'TCFA020_RH2', 'RH2_TIPO' ) == "1" 
Local cSavAlias

If lArq .AND. nOperation == 3  
	If File(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO'))
		lRet := tcfIncArq(AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO')))
	Else
		Alert(STR0005) //"O Endereço e/ou Arquivo não foi localizado, utilize o F3(lupa) para selecionar o arquivo correto."
		lRet := .F.
	EndIf 
ElseIf lArq .AND. nOperation == 4		
	//Se o nome informado for diferente, inicia processo para substituicao do arquivo
	If AllTrim(RH2->RH2_ACAO) <> AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO'))		  
		If File(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO'))
			
			//Exclui o Arquivo Antigo
			tcfExcArq(AllTrim(RH2->RH2_ACAO))
			//Insere o novo arquivo
			lRet := tcfIncArq(AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO')))
		Else
			Alert(STR0005) //"O Endereço e/ou Arquivo não foi localizado, utilize o F3(lupa) para selecionar o arquivo correto."
			lRet := .F.
		EndIf
	ElseIf AllTrim(RH2->RH2_TIPO) == '1' .AND. AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_TIPO')) == '2'
		//Alterou de Arquivo para Link, porém o campo RH2_ACAO não foi alterado
		Alert(STR0010) //"Ao alterar o Tipo de 'Arquivo' para 'Link', é necessário alterar o campo Link/Arquivo, com um conteúdo válido."
		lRet := .F.
	ElseIf AllTrim(RH2->RH2_TIPO) == '2' .AND. AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_TIPO')) == '1'
		//Alterou de Link para Arquivo, porém o campo RH2_ACAO não foi alterado
		Alert(STR0011) //"Ao alterar o Tipo de 'Link' para 'Arquivo', é necessário alterar o campo Link/Arquivo, com um conteúdo válido."
		lRet := .F.			
	EndIf
ElseIf !lLink .AND. !lArq
	//Geralmente quando o usuário salva como ARQUIVO e altera para LINK sem alterar o conteudo do campo RH2_ACAO
	lRet := .F.	 
ElseIf lArq .AND.nOperation == 5
	lRet := tcfExcArq(AllTrim(oModel:GetValue( 'TCFA020_RH2', 'RH2_ACAO')))
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ tcfExcArq    ³ Autor ³ Emerson Campos        ³ Data ³ 02/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui o arquivo se o cadastro for excluido pelo usuario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cArquivo	:= Nome do arquivo a ser excluido                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA020                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function tcfExcArq(cArquivo)
Local aConfRHZ	:= {}//{[C-Filial],[C-Codigo],[C-Ambiente],[C-Servidor],[N-Porta TCP],[C-Porta Web],[C-File To],[C-Instance name]} C=Caracter, N=Numerico
Local lRet		:= .T.
Local nI

	DbSelectArea("RHZ")
	RHZ->(dbGoTop())
	While RHZ->(!Eof())
		aAdd(aConfRHZ, {RHZ->RHZ_FILIAL,RHZ->RHZ_CODIGO,RHZ->RHZ_AMBIEN,RHZ->RHZ_SERVID,RHZ->RHZ_PORTCP,RHZ->RHZ_PORWEB,RHZ->RHZ_ENDERE,RHZ->RHZ_INSTAN})
		RHZ->(dbSkip())
	EndDo
	RHZ->(dbCloseArea())

	For nI := 1 To Len(aConfRHZ)
		lRet := exclArquivo(Alltrim(aConfRHZ[nI,3]), Alltrim(aConfRHZ[nI,4]), aConfRHZ[nI,5], Alltrim(aConfRHZ[nI,7]), cArquivo)
	Next nI

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ tcfIncArq    ³ Autor ³ Emerson Campos        ³ Data ³ 05/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva o arquivo nos servidores de destino                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cFileFrom	:= Path de onde se encontra oa arquivo a ser      ³±±
±±³          ³ transferido                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA020                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function tcfIncArq(cFileFrom)
Local oModel    := FWModelActive()
Local oModelRH2 := oModel:GetModel( 'TCFA020_RH2' )
Local nI		:= 0
Local lRet		:= .T.
Local aArquivo	:= {}
Local cOpc1		:= ""		
Local cOpc2		:= ""
Local aConfRHZ	:= {}//{[C-Filial],[C-Codigo],[C-Ambiente],[C-Servidor],[N-Porta TCP],[C-Porta Web],[C-File To],[C-Instance name]} C=Caracter, N=Numerico

DbSelectArea("RHZ")
RHZ->(dbGoTop())
While RHZ->(!Eof())
	aAdd(aConfRHZ, {RHZ->RHZ_FILIAL,RHZ->RHZ_CODIGO,RHZ->RHZ_AMBIEN,RHZ->RHZ_SERVID,RHZ->RHZ_PORTCP,RHZ->RHZ_PORWEB,RHZ->RHZ_ENDERE,RHZ->RHZ_INSTAN})
	RHZ->(dbSkip())
EndDo
RHZ->(dbCloseArea())

//Apenas se optarem futuramente por inserir no menu
//If Empty(cFileFrom)
	//"Selecione o Arquivo"
	//cFileFrom := cGetFile(,'Selecione o Arquivo',0,,.T.,GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .F.) 
//EndIf
	 
cArquivo	:= cFileFrom

// A função tranfArquivo espera o nome do arquivo sem o diretorio, exemplo: C:, D:, etc
If ( nPos := At(':', cArquivo) ) > 0
	cArquivo := SubS(cArquivo, nPos+1)
EndIf

//Separa o nome do arquivo do endereço completo
Do While At('\', cArquivo) > 0 .Or. At('/', cArquivo)> 0
	If (nPos := At('\', cArquivo)) > 0 .Or. (nPos := At('/', cArquivo)) > 0
		cArquivo := SubS(cArquivo, nPos+1)
	EndIf
EndDo

//Não pode haver espaço no nome do arquivo, senão provoca erro no momento de executar o download
If At(" ", cArquivo) > 0
	aArquivo := StrToKarr(cArquivo, ' ')
	For nI := 1 To Len(aArquivo)
    	If !Empty(cOpc1)
    		cOpc1 += "_"
    		cOpc2 += upper(SubStr(aArquivo[nI],1,1))+lower(SubStr(aArquivo[nI],2))
    	Else	    		
    		cOpc2 += lower(aArquivo[nI])	
    	EndIf
    	cOpc1 += aArquivo[nI] 
	Next nI        
	
	Alert(STR0006+cOpc1+STR0007+cOpc2) //"O arquivo não foi salvo. Remova os espaços vazios entre o nome do arquivo, ou substitua o espaço por algum outro separador, por exemplo: "+xxx+" ou "+xxx
	lRet := .F.
EndIf 

If lRet
	// Função responsavel por salvar o arquivo nos servidores de destino, conforme configuração na tabela RHZ
	For nI := 1 To Len(aConfRHZ)
		lRet := tranfArquivo(Alltrim(aConfRHZ[nI,3]), Alltrim(aConfRHZ[nI,4]), aConfRHZ[nI,5], cFileFrom, Alltrim(aConfRHZ[nI,7]), cArquivo)
	Next nI
	
	//Atualiza o campo RH@_ACAO com o nome do arquivo
	oModelRH2:SetValue( 'RH2_ACAO', cArquivo ) 
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ valRelacAcao ³ Autor ³ Emerson Campos        ³ Data ³ 27/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se existe o protocolo no arquivo ou no link da web      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cAcao	:= Conteudo inserido no campo acao                    ³±±
±±³          ³ cTipo    := O tipo selecionado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA020                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function valRelacAcao(cAcao, cTipo)
Local lRet	:= .T.
If cTipo == "2"   
	If (At('http://' , Lower(cAcao)) > 0 .OR.	At('https://', Lower(cAcao)) > 0 .OR.	At('ftp://'  , Lower(cAcao)) > 0) 
		If !( At('www'     , Lower(cAcao)) > 0 .OR. At('.com'    , Lower(cAcao)) > 0 .OR.;
				At('.br'     , Lower(cAcao)) > 0 .OR. At('.net'    , Lower(cAcao)) > 0)
			If !MsgYesNo(STR0012+cAcao+STR0013 , STR0008) //'O conteúdo do campo "Link/Arquivo, não possui caracteristicas de link web, um exemplo de um link válido seria http://www.totvs.com. Deseja salvar '+cACAO+' como um link válido?' ### 'Atenção!'
				lRet	:= .F. 
			EndIf
		EndIf
	Else
		Alert(STR0014) //'Se o campo “tipo” for informado como Link o campo "Link/Arquivo" deve ser preenchido com um link válido inclusive com o protocolo (http:// ou https://) exemplo: http://www.totvs.com.br.' 
   		lRet	:= .F.		
	EndIf	
EndIf	
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ valRelacAcao ³ Autor ³ Emerson Campos        ³ Data ³ 27/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite preencher a acao somente se o tipo ja estiver selecion.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cTipo    := O tipo selecionado                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA020                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function valWhenAcao(cTipo) 
Local lRet	:= .T.
If Empty(cTipo)
	Alert(STR0009) //"Preeencha o campo 'Tipo' antes de preencher o campo 'Ação'."
	lRet := .F.
EndIf
Return lRet
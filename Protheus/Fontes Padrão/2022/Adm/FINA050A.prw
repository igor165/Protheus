#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'

/*/{Protheus.doc} FINA050A
Função para reservar o nome do fonte.

@author Mateus Gustavo de Freitas e Silva
@since 25/03/2014
@version P11
/*/
User Function FINA050A()

Return

/*/{Protheus.doc} IntegDef
Função para chamar o adapter de mensagem única de substituição de título a pagar.

@author Mateus Gustavo de Freitas e Silva
@since 25/03/2014
@version P11

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
   Local aRet := {}

   aRet := FINI050A(cXML, nTypeTrans, cTypeMessage)
Return aRet

/*/{Protheus.doc} FinDelGPE
Função para excluir o registro na tabela RC1, caso seja excluído pelo financeiro.
@type function
@author Victor Andrade
@since 20/07/2016
@version 1.0
@param cIndexRC1, character, Índice de para seek na tabela RC1.
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Function FinDelGPE(cIndexRC1)

Local aArea := GetArea()

DbSelectArea("RC1") 
RC1->( DbSetOrder(2) )

If RC1->( DbSeek(cIndexRC1) )
	
	Begin Transaction
	//--> Ponto de entrada na exclusão do título na tabela RC1
	If ExistBlock("GPM060EX")
		If ExecBlock("GPM060EX",.F.,.F.)			
			RecLock("RC1", .F.)
			RC1->( DbDelete() )
			RC1->( MsUnLock() )
		
			//Integracao com modulo SIGAPCO
			PcoDetLan("000092","01","GPEM660", .T.)	
		EndIf
	Else	
		RecLock("RC1",.F.)
		RC1->( DbDelete() )
		RC1->( MsUnLock() )
			
		//Integracao com modulo SIGAPCO
		PcoDetLan("000092","01","GPEM660", .T.)		
	EndIf
	
	End Transaction
EndIf

RestArea( aArea )

Return

/*/{Protheus.doc} FinSubNov
Função para o processo de Substituição de Provisórios, com método de Baixa novo.
@type function
@author Daniel Ferraz Lacerda
@since 02/08/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Function FinSubNov()

//Processo novo (baixando o PR)
// Titulo PR será baixado na substituicao automatica
lMsErroAuto := .F.							
cPrefOri  := SE2->E2_PREFIXO
cNumOri   := SE2->E2_NUM
cParcOri  := SE2->E2_PARCELA
cTipoOri  := SE2->E2_TIPO
cCfOri    := SE2->E2_FORNECE
cLojaOri  := SE2->E2_LOJA

//Dados do titulo gerado (Destino)

cPrefDest	:= SE2->E2_PREFIXO
cNumDest	:= SE2->E2_NUM
cParcDest	:= SE2->E2_PARCELA
cTipoDest	:= SE2->E2_TIPO
cCfDest	:= SE2->E2_FORNECE
cLojaDest	:= SE2->E2_LOJA
cFilDest	:= SE2->E2_FILIAL
dDtEmiss	:= SE2->E2_EMISSAO

//Baixa Provisorio
	aVetor 	:= {{"E2_PREFIXO"	, SE2->E2_PREFIXO 		,Nil},;
					{"E2_NUM"		, SE2->E2_NUM       	,Nil},;
					{"E2_PARCELA"	, SE2->E2_PARCELA  		,Nil},;
					{"E2_TIPO"	    , SE2->E2_TIPO     		,Nil},;
					{"E2_FORNECE"	, SE2->E2_FORNECE  		,Nil},;
					{"E2_LOJA"	    , SE2->E2_LOJA     		,Nil},;
					{"AUTMOTBX"	    , "STP"             	,Nil},;
					{"AUTDTBAIXA"	, dDataBase				,Nil},;
					{"AUTDTCREDITO"		, dDataBase				,Nil},;
					{"AUTHIST"	    , "Baixa ref. substituicao de titulo Provisorio para Efetivo."	,Nil}}

					MSExecAuto({|x,y| Fina080(x,y)},aVetor,3)
					
					If lMsErroAuto
							DisarmTransaction()
							MostraErro()
					Else	
					//³		Ponto de gravação dos campos da tabela auxiliar.		³
						If AliasInDic("FII")
						dbselectarea("FII")
							cFIISeq	 := SE5->E5_SEQ
							FCriaFII("SE2", cPrefOri, cNumOri, cParcOri, cTipoOri, cCfOri, cLojaOri,;
											"SE2", cPrefDest, cNumDest, cParcDest, cTipoDest, cCfDest, cLojaDest,;
										cFilDest, cFIISeq )
						EndIf
				Endif

Return .T.




#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'FWADAPTEREAI.CH'
#include 'MATA010PPI.CH'

/*/{Protheus.doc} MATA010PPI
Classe de eventos para integração do produto com o PC Factory.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
CLASS MATA010PPI FROM FWModelEvent
	
	DATA nOpc
	DATA cXML
	DATA cProduto
	DATA lExclusao
	DATA lFiltra
	DATA lPendAut
	
	METHOD New() CONSTRUCTOR
	METHOD InTTS()
	METHOD execute()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cXml, cProd, lExclusao, lFiltra, lPendAut) CLASS MATA010PPI

Default cXml      := ""
Default cProd     := ""
Default lExclusao := .F.
Default lFiltra   := .T.
Default lPendAut  := .F.

	::cXML := cXml
	::cProduto := cProd
	::lExclusao := lExclusao
	::lFiltra := lFiltra
	::lPendAut := lPendAut
Return

METHOD InTTS() CLASS MATA010PPI
Local aArea     := GetArea()
Local aRetXML   := {}
Local aRetWS    := {}
Local aRetData  := {}
Local aRetArq   := {}
Local cGerouXml := ""
Local cOperacao := ""
Local cNomeXml  := ""
Local lRet := .T.
Local cXmlAnt   := ""

//Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI010.
Private lRunPPI := .T.
   
	If !Empty(::cXml)
		If PCPEvntXml(::cXml) == "delete"
			::lExclusao := .T.
		EndIf
	EndIf
	
	If Empty(::cProduto)
		::cProduto := SB1->B1_COD
	EndIf
   	
   //Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
	If !Empty(::cXml) .Or. !::lFiltra .Or. PCPFiltPPI("SB1", ::cProduto, "SB1")
      //Adapter para criação do XML
		If Empty(::cXml)
			aRetXML := MATI010("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
		Else
			aRetXML := {.T.,::cXml}
		EndIf
      /*
         aRetXML[1] - Status da criação do XML
         aRetXML[2] - String com o XML
      */
		If aRetXML[1]
         	//Retira os caracteres especiais
			cXmlAnt    := aRetXML[2] //Guarda o xml antes da retirada dos caracteres especiais
			aRetXML[2] := EncodeUTF8(aRetXML[2])

			//Verifica se houve a conversão de todos os caracteres especiais
			//Quando não há, o retorno do EncodeUTF fica nulo.
			If aRetXML[2] == NIL
				lRet := .F.
				aAdd(aRetWS,"3")
			 	aRetXML[2] := cXmlAnt // Apresenta o xml para o cliente identificar os caracteres especiais
				aAdd(aRetWS,STR0001 + ' ' + ::cProduto) //Não é possível enviar Xml com caracteres especiais. É necessário revisar o cadastro do produto XXXX

				//Busca a data/hora de geração do XML
				aRetData := PCPxDtXml(aRetXML[2])
				/*
					aRetData[1] - Data de geração AAAAMMDD
					aRetData[1] - Hora de geração HH:MM:SS
				*/
			else

				//Busca a data/hora de geração do XML
				aRetData := PCPxDtXml(aRetXML[2])
				/*
					aRetData[1] - Data de geração AAAAMMDD
					aRetData[1] - Hora de geração HH:MM:SS
				*/

				//Envia o XML para o PCFactory
				aRetWS := PCPWebsPPI(aRetXML[2])
				/*
					aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
					aRetWS[2] - Mensagem de retorno do PPI
				*/			
			EndIf 


   
			If aRetWS[1] != "1" .And. Empty(::cXml)
				Help(" ",1,AllTrim(aRetWS[2]))
				lRet := .F.
			EndIf

            //Cria o XML fisicamente no diretório parametrizado
			aRetArq := PCPXmLPPI(aRetWS[1],"SB1",::cProduto,aRetData[1],aRetData[2],aRetXML[2])
            /*
               aRetArq[1] Status da criação do arquivo. .T./.F.
               aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
            */
			
			If !aRetArq[1]
				Help(" ",1,AllTrim(aRetArq[2]))
				lRet := .F.
			Else
				cNomeXml := aRetArq[2]
			EndIf
            
			If Empty(cNomeXml)
				cGerouXml := "2"
			Else
				cGerouXml := "1"
			EndIf
            
            //Cria a tabela SOF
			PCPCriaSOF("SB1",::cProduto,aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
		EndIf
	EndIf
   
   If len(aRetWS) >0 
		If aRetWS[1] != "1"  .And. AllTrim(FunName()) == "PCPA111"
			lRet := .F.
		EndIf 
	EndIf

	RestArea(aArea)
Return lRet

METHOD execute() CLASS MATA010PPI
Return ::InTTS()

#include 'protheus.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} MATA010LOJA
Classe de eventos para integração do produto com o SIGALOJA.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
CLASS MATA010LOJA FROM FWModelEvent
	
	DATA nOpc
	DATA nRecno
	DATA oSB1Adapter
	DATA oProcessAdapter
	
	METHOD New() CONSTRUCTOR
	
	METHOD Before()
	METHOD AfterTTS()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010LOJA
Return

/*/{Protheus.doc} Before
Executado antes de gravar a alteração do produto, dentro da transação

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD Before(oModel, cID) CLASS MATA010LOJA
Local oFactory
Local cChave	:= ""
Local aArea := GetArea()
	
	If cID == "SB1MASTER"
		::nOpc := oModel:GetOperation()
		
		// Se houver integração e não for inclusão ou copia, anota todos os registros para exclusão, caso algum seja excluído
		If ::nOpc != MODEL_OPERATION_INSERT
			oFactory := LJCAdapXmlEnvFactory():New()
			
			::nRecno := SB1->(Recno())
			::oSB1Adapter := oFactory:Create( "SB1" ) //2  
			::oProcessAdapter := oFactory:CreateByProcess( "025" ) //3
					
			cChave 	:= xFilial( "SB1" ) + SB1->B1_COD
		    
		    ::oSB1Adapter:Inserir( "SB1", cChave, "1", "5" )
			::oProcessAdapter:Inserir( "SB1", cChave, "1", "5" )
		    
		    ::oSB1Adapter:Gerar()
			::oProcessAdapter:Gerar()
		EndIf
	EndIf
RestArea(aArea)
Return

/*/{Protheus.doc} AfterTTS
Executado depois da gravação completa do modelo

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD AfterTTS(oModel, cID) CLASS MATA010LOJA
Local aArea				:= GetArea()
Local cChave			:= ""
Local oEntidadeSBM		:= Nil
Local oRecords			:= Nil
Local oFactory			:= LJCAdapXmlEnvFactory():New( )	// Cria a fabrica de Adaptadores de envio
Local oEntidadeFactory	:= LJCEntidadeFactory():New()
Local oSB1Adapter
Local oProdAdapter

	// Verifica se houve algum registro apagado, e gera a integração desse registro
	If ::nOpc != MODEL_OPERATION_INSERT .AND. ::oSB1Adapter <> NIL
		// Procura pelo registro do cabeçalho
		SB1->(MSGoTo( ::nRecno ) )

		// Se não encontrar, significa que o cabeçalho foi apagado, então envia somente a exclusão do cabeçalho
		If SB1->( DELETED() )
			::oSB1Adapter:Finalizar()
		EndIf
	EndIf

	// Independente de ter registros apagados ou não, gera quando não for exclusão, todos os outros registros
	If ::nOpc != MODEL_OPERATION_DELETE
		oSB1Adapter := oFactory:Create( "SB1" ) //2
		oProdAdapter := oFactory:CreateByProcess( "025" )//3
		
		cChave 	:= xFilial( "SB1" ) + SB1->B1_COD

		// Para a tabela SB1
	    oSB1Adapter:Inserir( "SB1", cChave, "1", cValToChar( ::nOpc ) )
	    oSB1Adapter:Gerar()
		oSB1Adapter:Finalizar()

	    // Para o processo 025
		oEntidadeSBM := oEntidadeFactory:Create( "SBM" )
		
		If oEntidadeSBM != Nil
			oEntidadeSBM:DadosSet( "BM_GRUPO", SB1->B1_GRUPO )
			oRecords := oEntidadeSBM:Consultar(1)

			// Insere os registros no adapter e envia pro EAI.
			If oProdAdapter != NIL	.And. oRecords:Count() > 0
				//Insere os dados da carga
				oProdAdapter:Inserir( "SBM", xFilial("SBM") + oRecords:Elements( 1 ):DadosGet( "BM_GRUPO" ) , "1", cValToChar( ::nOpc ))
			EndIf
		EndIf
		
		oProdAdapter:Inserir( "SB1", cChave, "1", cValToChar( ::nOpc ) )
		oProdAdapter:Gerar()
		oProdAdapter:Finalizar()
	EndIf
	
	LJ110AltOk()
	
RestArea(aArea)
Return
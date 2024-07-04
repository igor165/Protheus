#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas - Romaneios  *****/
//===================================================================================


/** {Protheus.doc} AGX500GDCF
Abre o documento fiscal, conforme o tipo do romaneio

@param: 	cRomaneio, Código do Romaneio
@return: 	Nil
@author: 	Ana Laura Olegini
@since: 	20/04/2018
@Uso: 		SIGAAGR
*/
Function AGX500GDCF(cRomaneio, cIteRom, cFilRom)
	Local aAreaAtu		:= GetArea()
	Local aCliFor		:= {}
	Local cFilialNJM	:= ""
	Local cTipoNF		:= ""
	Local cCliFor		:= ""
	Local cLoja 		:= ""
	Local cTipo			:= ""
	Local cCodEnt		:= ""
	Local cLojEnt		:= ""
	Local cTes			:= ""
	Local nQtdFis		:= ""
	Local cDocNum		:= ""
	Local cDocSer		:= ""
	Local cPedido		:= ""
	
	Default cIteRom     := ''
	
	//--Variavel enviada para as rotinas de materiais 
	//--Não será possivel inserir o _ na frente da variavel
	Private aRotina := { { "", "", 0, 1 }, { "", "", 0, 1 } }

	//--Posiciona na tabela NJM com o Romaneio enviado por parametro
	
	//se filial estiver em branco atribui valor da logada
	If Empty(cFilRom)
		cFilRom := FwxFilial("NJM")
	EndIf
	
	cChave:= cFilRom+cRomaneio
	IF !Empty(cIteRom)
		cChave += cIteRom
	EndIF
	 
	dbSelectArea("NJM")
	NJM->( dbSetOrder(1) )
	If NJM->( MsSeek(cChave) )
		cFilialNJM	:= NJM->(NJM_FILIAL)
		cTipo		:= NJM->(NJM_TIPO)
		cCodEnt		:= NJM->(NJM_CODENT)
		cLojEnt		:= NJM->(NJM_LOJENT)
		cTes		:= NJM->(NJM_TES)
		nQtdFis		:= NJM->(NJM_QTDFIS)
		cDocNum		:= NJM->(NJM_DOCNUM)
		cDocSer		:= NJM->(NJM_DOCSER)
		cPedido		:= NJM->(NJM_PEDIDO)
		
		//--Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		//--Função encontra-se no fonte OGA250
		aCliFor	:= OGA250ClFr( cCodEnt, cLojEnt, cTes, cTipo, nQtdFis, cFilialNJM )
		cTipoNF	:= aCliFor[ 1 ]
		cCliFor	:= aCliFor[ 2 ]
		cLoja	:= aCliFor[ 3 ]
		
		//-- Se for romaneio de ENTRADA
		If cTipo $ "3|5|7|9|A" 
	
			//-- Encontra a nota fiscal de entrada
			DbSelectArea( "SF1" )
			SF1->( DbSetOrder( 1 ) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SF1->( DbSeek( FwxFilial( "SF1" ) + cDocNum + cDocSer + cCliFor + cLoja ) )
				//-- Visualização da NF de Entrada 
				A103NFiscal( "SF1", SF1->( Recno() ), 2 )			
			Else
				Help(, , STR0007, , STR0048 + Chr(10) + Chr(13) + "[ " + cDocNum + "/" + cDocSer + " ]", 1, 0 ) //"Ajuda"###"Documento fiscal não encontrado."
			EndIf
		
		//-- Se for romaneio de SAIDA
		ElseIf cTipo $ "2|4|6|8|B" 
			
			//--Encontra a pedido de venda
			DbSelectArea( "SC5" )
			SC5->( DbSetOrder( 1 ) ) //C5_FILIAL+C5_NUM
			If SC5->( DbSeek( FwxFilial( "SC5" ) + cPedido ) ) .OR. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") 
				
				//-- Encontra a nota fiscal de saída
				DbSelectArea( "SF2" )
				SF2->( DbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If SF2->( DbSeek( FwxFilial( "SF2" ) + cDocNum + cDocSer + cCliFor + cLoja ) )
					
					//-- Visualização da NF de Saída 
					Mc090Visual( "SF2", SF2->( recno() ), 1 ) 		
				Else
		            If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")
		            	Help(, , STR0007, , STR0048 + Chr(10) + Chr(13) +  "[ " + cDocNum + "/" + cDocSer + " ]", 1, 0 ) //"#Ajuda"###"Documento fiscal não encontrado."
		             Else
		             	//-- Visualização do Pedido de Vendas
						A410Visual( "SC5", SC5->( Recno() ), 2 )	 	   
					EndIf
				EndIf
			Else // Se não achou pedido de venda
				Help(, , STR0007, , STR0048 + Chr(10) + Chr(13) +  "[ " + cDocNum + "/" + cDocSer + " ]", 1, 0 ) //"#Ajuda"###"Documento fiscal não encontrado."   
			EndIf
		EndIF
	Else
		//--"Documento fiscal não encontrado."
		Help('' ,1,".AGRX500G0001.", , ,1,0)
		Return (.F.)
	EndIf
	RestArea( aAreaAtu )
Return()
#INCLUDE "OGX001.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

//////////////////////////////////////////////////////////////////////////
////                                                                  ////
////  FUNÇÕES GENÉRICAS PARA ABRIR TELAS DE CONSULTAS DO ORIGINAÇÃO   ////
////                                                                  ////
//////////////////////////////////////////////////////////////////////////


/** {Protheus.doc} OGX001Rom
Função para posicionar no registro da NJJ e visualizar um Romaneio 

@param: 	pcFilial 	- Filial do romaneio
@param: 	pcCodRom 	- Código do romaneio
@author: 	Marlon Richard Trettin
@since: 	01/06/2015
@Uso: 		SIGAAGR
*/
Function OGX001Rom( pcFilial, pcCodRom )
	Local aAreaAtu := GetArea()
	Local xRet 
	
	DbSelectArea( "NJJ" )	 // Romaneios
	DbSetOrder( 1 ) 
	If DbSeek( pcFilial + pcCodRom )
		
		OGX001VRom( NJJ->( Recno() ) ) 		// Chama a função de visualização do romaneio
		
	Else
		Help( , , STR0002, , STR0003 + Chr(10) + Chr(13) + "[ " + pcFilial + pcCodRom + " ]", 1, 0 ) //"AJUDA"###"Romaneio nao localizado."
		xRet := .F.
	EndIf
		
	RestArea( aAreaAtu )
Return xRet

/** {Protheus.doc} OGX001VRom
Função para visualização de Romaneio 

@param: 	pnNJJ_RECNO	- Recno da NJJ
@author: 	Marlon Richard Trettin
@since: 	01/06/2015
@Uso: 		SIGAAGR
*/
Function OGX001VRom( pnNJJ_RECNO )
	Local aAreaAtu := GetArea()
	Local xRet 
	Local cFilAtu 	:= cFilAnt //Armazena a filial atual
	
	DbSelectArea( "NJJ" )
	DbGoTo( pnNJJ_RECNO ) 

	cFilAnt 	:= NJJ->NJJ_FILIAL //Posiciona na filial do romaneio para visualização correta dos dados
	
	If NJJ_TIPENT == '1' //Gerencial
		
		//FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
		xRet := FWExecView( STR0001, "OGA255", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
		
	Else
		
		//FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
		xRet := FWExecView( STR0001, "OGA250", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
		
	EndIf
		
	cFilAnt := cFilAtu //Volta para filial atual

	RestArea( aAreaAtu )
Return xRet


/** {Protheus.doc} OGX001Mov
Função para posicionar no registro da NKM e visualizar uma Movimentação 

@param: 	pcIDMov 	- ID da Movimentação
@author: 	Marlon Richard Trettin
@since: 	19/06/2015
@Uso: 		SIGAAGR
*/
Function OGX001Mov( pcIDMov, nOperation )
	Local aAreaAtu := GetArea()
	Local xRet 
	Default nOperation := 5 //Visualizar
	
	If ! Empty( pcIDMov ) 
		
		DbSelectArea( "NKM" )
		DbSetOrder( 1 )
		If DbSeek( xFilial( "NKM" ) + pcIDMov )
			
			OGX001VMov( NKM->( Recno() ), nOperation ) 		// Chama a função de visualização da Movimentação
			
		Else
			Help( , , STR0002, , STR0004 + Chr(10) + Chr(13) + "[ " + xFilial( "NKM" ) + pcIDMov + " ]", 1, 0 ) //"AJUDA"###"Movimentacao nao localizada."
			xRet := .F.
		EndIf
		
	Else
		Help( , , STR0002, , STR0005, 1, 0 ) //"AJUDA"###"Este romaneio nao esta vinculado a uma movimentacao."
		xRet := .F.
	EndIf
		
	RestArea( aAreaAtu )
Return xRet

/** {Protheus.doc} OGX001VMov
Função para visualização de Movimentações dos Contratos 

@param: 	pcIDMov 	- ID da Movimentação
@author: 	Marlon Richard Trettin
@since: 	19/06/2015
@Uso: 		SIGAAGR
*/
Function OGX001VMov( pnNKM_RECNO, nOperation)
	Local aAreaAtu := GetArea()
	Local xRet 
	Default nOperation := 5 //Visualizar
	
	DbSelectArea( "NKM" )
	DbGoTo( pnNKM_RECNO ) 
	
	If  nOperation == 5
	    xRet := FWExecView( STR0001, "OGA440", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
	Else			
	//FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
		xRet := FWExecView( STR0001, "OGA440", nOperation, , , ,5 ) 
	EndIf	
			
	RestArea( aAreaAtu )
Return xRet


/** {Protheus.doc} OGX001Ctr
Função para posicionar no registro da NJR e visualizar um Contrato 

@param: 	pcFilial 	- Filial do contrato
@param: 	pcCodCtr 	- Código do contrato
@author: 	Marlon Richard Trettin
@since: 	01/06/2015
@Uso: 		SIGAAGR
*/
Function OGX001Ctr( pcFilial, pcCodCtr )
	Local aAreaAtu := GetArea()
	Local xRet 
	Local cFilBkp  := cFilAnt //ARMAZENA A FILIAL ATUAL LOGADA
	
	cFilAnt  := pcFilial //LOGA NA FILIAL PASSADA NO PARAMETRO
	
	DbSelectArea( "NJR" )	 // Contratos
	DbSetOrder( 1 ) 
	If DbSeek( FwxFilial("NJR") + pcCodCtr )
		
		OGX001VCtr( NJR->( Recno() ) ) 		// Chama a função de visualização do contrato
		
	Else
		Help( , , STR0002, , STR0006 + Chr(10) + Chr(13) + "[ " + FwxFilial("NJR") + pcCodCtr + " ]", 1, 0 ) //"AJUDA"###"Contrato nao localizado."
		xRet := .F.
	EndIf
		
	RestArea( aAreaAtu )
	
	cFilAnt := cFilBkp //RETORNA PARA A FILIAL LOGADA
	
Return xRet

/** {Protheus.doc} OGX001VCtr
Função para visualização do Contrato 

@param: 	pnNJR_RECNO - número do Recno da tabela NJR (contrato posicionado)
@author: 	Marlon Richard Trettin
@since: 	09/06/15
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX001VCtr( pnNJR_RECNO )
	Local aAreaAtu	:= GetArea()
	
	DbSelectArea( "NJR" )
	DbGoTo( pnNJR_RECNO ) 
	If NJR->( NJR_TIPO ) == "1" 		// Contrato de Compra
		FWExecView( STR0001, "OGA280", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
	ElseIf NJR->( NJR_TIPO ) == "2" 	// Contrato de Venda
		FWExecView( STR0001, "OGA290", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
	ElseIf NJR->( NJR_TIPO ) == "3" 	// Contrato de Depósito de 3o.
		FWExecView( STR0001, "OGA260", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
	ElseIf NJR->( NJR_TIPO ) == "4" 	// Contrato de Depósito em 3o.
		FWExecView( STR0001, "OGA270", MODEL_OPERATION_VIEW, , , ,5 ) //"Visualizar"
	EndIf
	
	RestArea( aAreaAtu )
Return	

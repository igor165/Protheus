#INCLUDE "OGA263.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA263
Rotina para apresentação dos fechamentos dos serviços de armazenagem
***
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA263()
	Local oMBrowse := Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKS" )
	oMBrowse:SetDescription( STR0001 ) //"Fechamentos Serviços de Armazenagem"
	oMBrowse:AddLegend( "NKS_STATUS='1'", "GREEN"	  , STR0002   ) //"Gerado"
	oMBrowse:AddLegend( "NKS_STATUS='2'", "RED"    , STR0003 )   //"Cancelado"
	oMBrowse:AddLegend( "NKS_STATUS='3'", "YELLOW" , STR0004  )  //"Vinculado"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
****
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263 - Movimentos Serviços do Contrato
*/

Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0005, 'OGA263Visual()', 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0006, 'OGA263M(NKS->NKS_FECSER)', 0, 7, 0, Nil } ) //'Movimentos'
	aAdd( aRotina, { STR0007, 'OGA263E(NKS->NKS_STATUS, NKS->NKS_FECSER)', 0, 8, 0, Nil } ) //'Estornar'

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263 - Movimentos Serviços do Contrato
*/
Static Function ModelDef()
	Local oStruNKS := FWFormStruct( 1, "NKS" )
	Local oModel   := MPFormModel():New( "OGA263" )

	oModel:AddFields( 'NKSUNICO', Nil, oStruNKS )
	oModel:SetDescription( STR0011 ) 
	oModel:GetModel( 'NKSUNICO' ):SetDescription( STR0010 ) //"Dados Fechamento Serviços de Armazenagem"

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263 - Movimentos Serviços do Contrato
*/
Static Function ViewDef()
	Local oStruNKS := FWFormStruct( 2, 'NKS' )
	Local oModel   := FWLoadModel( 'OGA263' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NKS', oStruNKS, 'NKSUNICO' )
	oView:CreateHorizontalBox( 'UM'  , 100 )
	oView:SetOwnerView( 'VIEW_NKS', 'UM'   )

	oView:SetCloseOnOk( {||.t.} )

Return oView


/** {Protheus.doc} OGA263Visual
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263 - Movimentos Serviços do Contrato
*/
Function OGA263Visual()

	Local xRet 

	xRet := FWExecView( '','OGA263', MODEL_OPERATION_VIEW )

Return xRet

/** {Protheus.doc} OGA263E
Função que exclui o calculo de serviços

@param: 	cStatus 	-> Status do Fechamento Servico
cFecSer 	-> Nr. do Fechamento de Serviço
lMsgConf	-> Indica se faz o Pergunte de confirma estorno
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263 - Movimentos Serviços do Contrato
*/

Function OGA263E(cStatus, cFecSer, lMsgConf )
Local lRetorno := .T.
Local vServ    := {}
Local nX       := 0

Local aCabPV 	:= {}
Local aItensPV	:= {}

Local aVincCabNF := {}
Local aVincIteNF := {}

Local aVincCab	:= {}
Local aLinhaVinc:= {}
Local aVincITE	:= {}
Local lVinculou := .t.


Private lMsErroAuto := .F.
Private lMSHelpAuto := .T.

Default lMsgConf := .t.

IF lmsgConf
	If .Not. MsgYesNo(STR0009, STR0008) //"Tem certeza que deseja estornar o fechamento de cálculo de serviço selecionado?"###"Estorno de Fechamento de Cálculo de Serviço"
		Return( lRetorno )
	EndIF
EndIF


If cStatus = '1' // Gerado
	dbSelectArea('NKS')
	dbSetOrder(1)
	If dbSeek( xFilial('NKS') + cFecSer )
		
		If !Empty( NKS->NKS_CODROM )
			dbSelectArea( 'NJJ' )
			dbSetOrder( 1 )
			If dbSeek( xFilial('NJJ') + NKS->NKS_CODROM )
				IF NJJ->NJJ_STATUS = '3' //Confirmado
					Help(, , STR0012, , STR0014, 1, 0 )
					Return .f.
				ElseIf NJJ->NJJ_STATUS $ '0|1|2'
					OGA250CAN()
				EndIf
			EndIf
		ElseIf !Empty(NKS->NKS_DOCNUM) .and. ! IsInCallStack('OGX165')
			dbSelectArea('SF2')
			dbSetOrder(1)  // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
			If dbSeek( xFilial('SF2') + NKS->(NKS_DOCNUM + NKS_DOCSER + NKS_CLIENT + NKS_LOJA) )
				//Help(, , STR0012, , STR0015, 1, 0 )
				MsgAlert(STR0015,STR0012)
				Return .f.
			Endif
		EndIf
		
		vServ := {}
		nX    := 0
		
		dbSelectArea('NKG')
		dbSetOrder(4)
		If dbSeek( xFilial('NKG') + NKS->NKS_FECSER )
			
			While !Eof() .And. NKG->NKG_FILIAL = xFilial('NKG') ;
				.And. NKG->NKG_FECSER = NKS->NKS_FECSER
				
				aAdd(vServ,RecNo())
				AGRDBSELSKIP('NKG')
			EndDo
			
			For nX := 1 to Len(vServ)
				dbGoTo(vServ[nX])
				If !Eof() .And. !Bof()
					RecLock('NKG',.f.)
					NKG->NKG_STATUS := '1' //Atualizado
					NKG->NKG_FECSER := ''
					NKG->(MsUnlock())
				Endif
			Next nX
		Endif
		
		IF Empty(NKS->NKS_CODROM) .and. ! Empty(NKS->NKS_DOCNUM) // Indica que é um Fechto Serv. cobrado por Valor
			// Irei tentar ecluir o PV gerado pelo fechto de serviço;
			dBSelectArea('SC5')
			SC5->( DbSetOrder(1)) //C5_FILIAL+C5_NUM
			IF SC5->( DbSeek(FwXfilial('SC5') + NKS->NKS_PEDIDO ))
				aAdd( aCabPV,{ "C5_NUM"	,SC5->C5_NUM,Nil	})
				
				dBSelectArea('SC6')
				SC6->( DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				IF SC6->( DbSeek(FwXfilial('SC6') + SC5->C5_NUM  ))
					While !Eof() .And. SC6->C6_FILIAL == FwXfilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
						aAdd(aItensPV,{	})
						aAdd(aTail(aItensPV),{"C6_NUM" ,SC6->C6_NUM	,Nil})
						aAdd(aTail(aItensPV),{"C6_ITEM",SC6->C6_ITEM,Nil})
						
						// Tratamento para excluir o vinculo
						IF len( avincCab) == 0
							aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
							aadd( aVincCab, { "N8H_NUMPV"    	, SD2->D2_PEDIDO			  			} )
						EndIF
						
						aLinhaVinc := {}
						aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
						aadd( aLinhaVinc, { "N8I_NUMPV"    		, SD2->D2_PEDIDO			} )
						aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SD2->D2_ITEMPV			} )
						
						aAdd(aVincITE, aLInhaVinc )
						
						SC6->(DbSkip() )
					EndDo
				EndIf
				
				IF ! IsInCallStack('OGX165') // Se não foi chamado do meio do processo de exclusão do docto. fiscal
					// Não posso excluir o pv de dentro do ogx165 pois a exclusao da nf. vai tentar
					// posicionar no pv. e vai dar erro.
					IF ! Empty (SC5->C5_LIBEROK)
						RecLock( 'SC5', .T. )
						SC5->C5_LIBEROK := " "
						SC5->( MsUnLock() )
					EndIF
					MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPV,aItensPV,5) // Exclui o Pedido de Vendas
				EndIF
				
				If lMSErroAuto
					MostraErro()
					//Return
				EndIF
			EndIF
			
			IF len( avincCab) > 0 // Chama função pra eliminar registro de vinculo do PV
				lVinculou := fAgrVncPV (aVincCab,aVincITE  , 5)  	//Excluir ( Irá excluir o vinculo de todos os itens do pedido )
			EndIF
		EndIF
		
		dbSelectArea('NKS')
		RecLock('NKS',.f.)
		NKS->NKS_STATUS := '2' //Cancelada
		NKS->(MsUnLock())
	EndIf
ElseIf cStatus = '2' //Cancelado
	Help(, , STR0012, , STR0013, 1, 0 )
	Return .f.
ElseIf cStatus = '3' //Vinculado
	
	
	dbSelectArea('NKS')
	dbSetOrder(1)
	If dbSeek( xFilial('NKS') + cFecSer )
		
		vServ := {}
		nX    := 0
		
		dbSelectArea('NKG')
		dbSetOrder(4)
		If dbSeek( xFilial('NKG') + NKS->NKS_FECSER )
			
			While !Eof() .And. NKG->NKG_FILIAL = xFilial('NKG') ;
				.And. NKG->NKG_FECSER = NKS->NKS_FECSER
				
				aAdd(vServ,RecNo())
				AGRDBSELSKIP('NKG')
			EndDo
			
			For nX := 1 to Len(vServ)
				dbGoTo(vServ[nX])
				If !Eof() .And. !Bof()
					RecLock('NKG',.f.)
					NKG->NKG_STATUS := '1' //Atualizado
					NKG->NKG_FECSER := ''
					NKG->(MsUnlock())
				Endif
			Next nX
		Endif
		
		// Tratamento para Retirar o Vinculo da NF. e do PV.
		//IF .not. IsIncallStack('OGX165') // Chamada vinda da rotina de Exc. Doc. Fiscal, no Meio da transacao
			// Desvincula o romaneio do PV
			SF2->( DbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->( DbSeek( xFilial( "SF2" ) + NKS->(NKS_DOCNUM + NKS_DOCSER + NKS_CLIENT + NKS_LOJA) ))
				// Desvincula o romaneio da NF
				
				SD2->( dbSetOrder( 3 ) )
				SD2->( dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) )
				While .Not. SD2->( Eof() ) ;
					.And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
					
					/***************************************************************************/
					//Tratamento para eliminar a tabela de vinculos
					/***************************************************************************/
					// Desvincula o romaneio do item da NF
					//Array de vinculo do Agro com o doc. Sada ( Cab )
					IF Len (aVincCabNF) == 0
						aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8K')	} )
						aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC		} )
						aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
						aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} )
						aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
					EndIf
					
					//Array Vinc. do Agro com doc. saida ( Itens )
					aLinha := {}
					aadd( aLinhaVinc, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
					aadd( aLinhaVinc, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
					aadd( aLinhaVinc, { "N8K_SERIE"    	, SD2->D2_ITEM		} )
					aadd( aLinhaVinc, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} )
					aadd( aLinhaVinc, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
					aadd( aLinhaVinc, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
					aAdd( aVincIteNF, aLinha )
					
					/**********************************************************************************/
					// Tratando o Vinc. do Pv. para ser excluido da tab. de vinculo
					// Podemos ter uma nf. contendo itens de varios pedidos.
					/**********************************************************************************/
					IF len(aVincCab) > 0   			// Chama função pra eliminar registro de vinculo do PV, (caso nf. tenha 2 pedidos em seus itens e o pv mudou)
						nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
						IF ! Alltrim ( aVincCab[nPosCpo] ) ==  SD2->D2_PEDIDO
							lVinculou := fAgrVncPV (aVincCab,aVincITE  , 5)  	//Excluir ( Irá excluir o vinculo de todos os itens do pedido )
						EndIF
						aVincCab := {}
						aVincITE := {}
					EndIF
					
					IF len( avincCab) == 0
						aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
						aadd( aVincCab, { "N8H_NUMPV"    	, SD2->D2_PEDIDO			  			} )
					EndIF
					
					aLinhaVinc := {}
					aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
					aadd( aLinhaVinc, { "N8I_NUMPV"    		, SD2->D2_PEDIDO			} )
					aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SD2->D2_ITEMPV			} )
					
					aAdd(aVincITE, aLInhaVinc )
					
					SD2->( DbSkip() )
				EndDo
				
				IF Len(aVincCabNF) > 0 .and. .not. IsIncallStack('OGX165') // Elimina o vinc. do nf. se foi chamado do menu de manut. fechto serv
																		   // Se veio da rotina de exc. da nf. não exclui o vinc. pq sera feito
																		   // Pela rotina de exc.
					lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 5)  		//Excluir
					aVincCabNF := {}
					aVincIteNF := {}
				EndIF
				
				IF len( avincCab) > 0 // Chama função pra eliminar registro de vinculo do PV
					lVinculou := fAgrVncPV (aVincCab,aVincITE  , 5)  	//Excluir ( Irá excluir o vinculo de todos os itens do pedido )
				EndIF
			EndIf
		//EndIF
	EndIF
	
	
	dbSelectArea('NKS')
	RecLock('NKS',.f.)
	NKS->NKS_STATUS := '2' //Cancelada
	NKS->(MsUnLock())
Endif

Return lRetorno


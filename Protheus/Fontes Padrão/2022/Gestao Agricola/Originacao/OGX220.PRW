#include "protheus.ch"
#include "ogx220.ch"

/** {Protheus.doc} OGX220
Rotina chamada através do Pedido de Venda
( MATA410 - nao passa ao incluir  apenas alterar/copia/visualiza)
@author: 	Vanilda Moggio
@since: 	24/03/2015
@Uso: 		SIGAAGR - Gestão Agrícola
**/
Function OGX220(cOpcao)
	Local lRetorno 	:= .T.

	If SuperGetMv("MV_AGRORI",,.F.) .AND. !ISINCALLSTACK("OGA300") .And. SC5->(ColumnPos('C5_TRCNUM')) > 0
		If  cOpcao == 'C'
			SC5->C5_TRCNUM := "0"
		ElseIf  cOpcao == 'A'
			If 	!(empty(SC5->C5_TRCNUM)) .or. SC5->C5_TRCNUM != "0"
				dbSelectArea('NKT')
				NKT->( dbSetOrder( 1 ) )
				If dbSeek(fwxfilial("NKT")+SC5->C5_TRCNUM) .and. !(Empty(NKT_NUMPED))
					Help(,, STR0006,,STR0002 , 1, 0 ) //#Ajuda #Pedido de Venda para troca deve ser alterado no Acordo de Troca
					lRetorno 	:= .F.
				Endif
			Endif
		ElseIf  cOpcao == 'E'
			if 	!(empty(SC5->C5_TRCNUM)) .or. SC5->C5_TRCNUM != "0"
				dbSelectArea('NKT')
				NKT->( dbSetOrder( 1 ) )
				If dbSeek(fwxfilial("NKT")+SC5->C5_TRCNUM) .and. !empty(NKT_NUMPED)
					Help(,, STR0006,,STR0003 , 1, 0 ) //#Ajuda #Pedido de Venda para troca deve ser eliminado no Acordo de Troca
					lRetorno 	:= .F.
				endif
			Endif
		ElseIf cOpcao == 'L'
			dbSelectArea('NKT')
			NKT->( dbSetOrder( 1 ) )
			If dbSeek(fwxfilial("NKT")+SC5->C5_TRCNUM) .and. (NKT_STATUS == '01')
				Help(,, STR0006,,STR0004 , 1, 0 ) //#Ajuda #Acordo de troca deve estar liberado
				lRetorno 	:= .F.
			Endif
		Endif
	Endif 
	
	IF lRetorno .and. (SuperGetMV("MV_AGRUBS",.F.,.F.)) .and. Alltrim(cOpcao) $ 'A|E'  
		//Verifica para os PVs. de Prod. sementes se os mesmos tem lotes direcionados 
		//Pedidos com lotes direcionados não podem ser alterados ou Excluidos
		//sem antes ter os direcionamentos Cancelados do Pedidos.
	   lRetorno := fLtSemDir( cOpcao)
	EndIF


Return( lRetorno )

/*{Protheus.doc} fLtSemDir()
Função que verifica se o pedido é de semente e se contem lotes direcionados para o pedido.

@param     cOpca ( Recebe A = Alteração , E=Exclusão)
@sample    fLtSemDir()
@return    Se pode ou não continuar com Alteração ou Exclusao do PV
@author    Agroindustria
@since      Agosto/2020
@version    P12
*/
static Function fLtSemDir(cOpcao)
	Local   lRet     :=.T.
	Local   i
	Local   cAliasQry  := ''

	Local   lTemLTDir	:= .f.

	If TableInDic('ND5') 

		cAliasQry  := GetNextAlias()
		BeginSQL Alias cAliasQRY
			SELECT COUNT(ND5_PEDIDO) NPEDIDOS from %Table:ND5% ND5
			WHERE ND5_PEDIDO = %exp:SC5->C5_NUM%
			AND ND5_STATUS = '1'
			AND ND5_FILIAL = %xFilial:ND5% 
			AND ND5.%notDel%
		EndSQL
	
		IF (cAliasQRY)->NPEDIDOS > 0
			lTemLTDir := .t.
		EndIF
		
		(cAliasQRY)->( dBClosearea() )
		
		lRet := !lTemLTDir
	
	
		IF !lRet = .t.
			Do case
			Case cOpcao == 'E'
				Help(NIL, NIL, 'Ajuda', NIL, 'Exclusão não permitida.PV. possui itens com Lotes direcionados', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Para excluir PV. Cancele o direcionamento de lotes no painel de direcionamento.'})                  
			Case cOpcao == 'A'
				Help(NIL, NIL, 'Ajuda', NIL, 'Alteração não permitida.PV. possui itens com Lotes direcionados', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Para Alterar PV. Cancele o direcionamento de lotes no painel de direcionamento.'})                  
			EndCase
		
		EndIF
		
	EndIF

Return(lRet)


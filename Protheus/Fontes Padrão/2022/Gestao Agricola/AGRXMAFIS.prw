#include 'protheus.ch'
#include 'totvs.ch'
#include 'parmtype.ch'
#INCLUDE 'matxdef.ch'    /* Include da MATXFIS */

/*/{Protheus.doc} AgrXFat Bloco de codigo chamado no 14*. parametro da Chamada da MAPVLNFS
@author emerson.coelho
@since 22/02/2018
@version 1.0
@return Array Private com vinculo entre PV e item da matxfis
@param cPedido,	Pedido de venda
@param cItPed, 	item do Pedido
@param cSeq, 	Sequencia da SC9
@param nMafisITEM , Item de correspondencia da MATXFIS ( aNfItem )
@type function
/*/
function AgrXFat(cPedido, cItPed, cSeq, nPrcVnd, nMafisITEM )
 
	AgrPvMafis( cPedido, cItPed, cSeq, nPrcVnd, nMafisITEM )

return


// Criando referencia entre o Iem do pedido x Item PV Agro x Item da matxfis // 
// Razão preciso garantir que garantir que o nitem 1 da matxfis, refere-se, 


/*/{Protheus.doc} AgrPvMafis	-> Função responsavel por criar vinculo entre o item do PV faturado e o nItem da MATXFIS
								-> Tbem verifica na tab. de vinculo do agro se o produto possui um tipo
								Função visa responder a pergunta o nitem da matxfis corresponde a qual item do PV de vneda
@author emerson.coelho
@since 22/02/2018
@version 1.0
@return Array Privado contendo nItem da Matxfis x Item do PV 
		1a posição = Pedido
		2a posição = Item do PV
		3a posição = Sequencia da C9
		4a posição = Preço de venda
		5a posição = nItem da correspondente da matxfis
@param cPedido, 	Numero do Pedido de Vendas
@param cItPed,  	Item do Pedido de vendas
@param cSeq,    	Sequencia da SC9 ( não necessita )
@param nMafisITEM	Numero do Item na Matxfis
@type function
/*/
Function AgrPvMafis(cPedido, cItPed, cSeq, nPrcVnd, nMafisITEM )
	Local cTpProd	:= ''

	cTpProd := Posicione('N8I',1, fwXfilial('N8I') + cPedido + cItPed, 'N8I_TPPROD' )  

	aAdd(aAgrItFat,{cPedido, cItPed, cSeq, cTpProd, nPrcVnd, nMafisItem  })

Return



/*/{Protheus.doc} AgrICMPaut	-> 	Que busca pauta ICMS,  por qualificador do produto x UfOri x Ufdest
									Chamada na MaExcecao
@author emerson.coelho
@since 22/02/2018
@version 1.0
@return Pauta de ICMS por qualificador do Agro na exceção fiscal
@param aNfCab 	-> Array de  Cabeçãlho do doc. fiscal ( Padrão Matxfis )
@param aNfItem	-> Array dos Itens     do doc. fiscal ( Padrão Matxfis) 
@type function
/*/
Function AgrICMPaut(aNfCab, aNfItem, nItem, aExcecao )
	Local nPosItem		:= 0	
	Local cTpProd		:= ''
	Local cAliasN8R		:= GetNextAlias()
	Local nVrPauta		:= 0	
	Local lFound		:= .f.
	Local cTpFret		:=   aNfCab[ NF_TPFRETE ]
	Local cUFOri 		:=   aNFCab[ NF_UFORIGEM]
	Local cUFDest		:= 	 aNFCab[ NF_UFDEST]	
	Local cProduto		:=   aNfItem[ nItem ,IT_PRODUTO ]		

	IF ! Type("aAgrItFat") == "A" 
		Return
	EndIF

	nPosItem    := aScan(aAgrItFat,{|x| x[6] == nItem    })

	IF nPosItem == 0
		Return
	EndIF

	//Buscando possivel pauta de ICMS em tabela especifica do Agro	
	cTpProd		:= aAgrItFat[nPosItem, 4]	

	If empty(cTpProd)
		cTpProd := Space( TamSX3( "N8R_TIPO" )[1] )
	EndIf	
		
    While .t.
        //  1a. Busca por UF X UF ESPECIFICA EX ( SP X MG)
        //  2a. Busca por UF X UF onde a origem é especifica e o destino pode ser N. ( Ex: SP X ** )
        BeginSql alias cAliasN8R
            SELECT N8R.* FROM     %table:N8R% N8R
            WHERE	N8R.N8R_FILIAL		= %xfilial:N8R%
            AND		N8R.N8R_PROD		= %Exp:Alltrim(cProduto)%
            AND		N8R.N8R_TIPO		= %Exp:cTpProd%
            AND		N8R.N8R_UFORIG		= %Exp:cUfOri%
            AND		N8R.N8R_UFDEST		= %Exp:cUfDest%
            AND     N8R.N8R_DTINVG		<= %Exp:dDatabase%
            AND		N8R.%notDel%
            ORDER BY N8R_DTINVG DESC
        EndSql

        (cAliasN8R)->(DbGoTop())
        
        IF ( cUfDest == '**' ) .and. (cAliasN8R)->( Eof())
            lFound := .f.
            Exit 
        ElseIF (cAliasN8R)->( Eof())  // Identifica que não existe Pauta para o produto e tipo na Tab. de Pautas do Agro, ( Não será feito nada )
            (cAliasN8R)->( DbCloseArea() )
            //  Busca por UF X UF onde a origem é especifica e o destino pode ser N. ( Ex: SP X ** )
            cUfDest := '**'
        Else
            Exit
        EndIF
    EndDO	
    

    IF (cAliasN8R)->( Eof())  // Identifica que não existe Pauta para o produto e tipo na Tab. de Pautas do Agro, ( Não será feito nada )
        lfound := .f.
    Else				
        lFound := .t.
        IF cTpfret == 'F'   //Encontrou Pauta e o Tipo do Frete é Fob
            Do Case
                Case  (cAliasN8R)->N8R_VLFOBP > 0 		//Atribui Pauta fob caso a mesma seja maior que Zero
                nVrPauta :=  (cAliasN8R)->N8R_VLFOBP
                OtherWise								//Se Tp. da venda for FOB, Porem a Pauta FOB for zero, Entendemos que devemos pegar a Pauta, Normal
                nVrPauta := (cAliasN8R)->N8R_VLICMP
            EndCase
        Else     		//Se Venda não for FOB, buscamos a Pauta normal
            nVrPauta := (cAliasN8R)->N8R_VLICMP
        EndIF
    EndIF
    
    (cAliasN8R)->( DbCloseArea() )		
	
	IF nVrPauta > 0   // So irei considerar se O PRODUTO, UFORI / UFDST esta cadastrado na Tab. Pauta do Agro e Se tem algum Vr.
		IF Len ( aExcecao ) > 0
			If cTpfret == 'F'
                aExcecao[32] := nVrPauta
            Else
                aExcecao[16] := nVrPauta
            EndIf
		EndIF
	EndIF

Return( ) 


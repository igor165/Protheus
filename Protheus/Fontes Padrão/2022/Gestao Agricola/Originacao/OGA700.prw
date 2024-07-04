#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "fwMvcDef.ch"
#INCLUDE "OGA700.ch"
#INCLUDE "TOTVS.CH"
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI

/** {Protheus.doc} OGA700 
Rotina para cadastro de novos Negócios

@param:     Nil
@author:    Equipe Agroindustria
@since:     27/03/2017
@Uso:       SIGAAGR - Originação de Grãos
*/

Static __cPergunte 	  := "OGA70001"
Static __lViewAGRA060 := .F.
Static __lnewNeg	  := SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de comercialização
Static __aFixDisp     := {}  //array para guardar valores de qtd disponivel da cadencia para fixação.
Static _cProduto      := ""   
Static _cMoeda        := ""
Static __cCLTTEMP
Static __cRet		 := Nil
Static __lAutomato   := IsBlind() .and. !(IsInCallStack("EVALMDL")) //automação - EVALMDL é para o robo do frame que valida os models
Static __cAutoTest   := Iif(__lAutomato,iif(Type("_cAutoTest") != "U",_cAutoTest,""),"")
Static __lRegOpcional  := FWIsInCallStack("AGRXCNGC")
Static __lCtrRisco 	 := SuperGetMv('MV_AGRO041', , .F.) 

function OGA700()
	Local oMBrowse  := Nil
	Local bTeclaF12 := SetKey( VK_F12, { || Pergunte("OGA700MAIL", .T.) } )    
	
	//-- Proteção de Código
    If ! TableInDic('N79') .OR. ! TableInDic('N7A')  .OR. ! TableInDic('N7B') .OR. ! TableInDic('N7C') 
        MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
        Return()
    Endif

    AtuStatus()

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N79" )
	oMBrowse:SetDescription( STR0053 ) //"Negociações"
	oMBrowse:SetMenuDef( "OGA700" )
	oMBrowse:AddLegend( "N79_STATUS=='1'"  , "RED"         , X3CboxDesc( "N79_STATUS", "1" )   ) //"Pendente"
	oMBrowse:AddLegend( "N79_STATUS=='5'"  , "BR_VIOLETA"  , X3CboxDesc( "N79_STATUS", "5" )   ) //"Pedido em aprovação"
	oMBrowse:AddLegend( "N79_STATUS=='2'"  , "ORANGE"      , X3CboxDesc( "N79_STATUS", "2" )   ) //"Trabalhando"
	oMBrowse:AddLegend( "N79_STATUS=='6'"  , "BLUE"        , X3CboxDesc( "N79_STATUS", "6" )   ) //"Completar"
	oMBrowse:AddLegend( "N79_STATUS=='3'"  , "GREEN"       , X3CboxDesc( "N79_STATUS", "3" )   ) //"Completo"
	oMBrowse:AddLegend( "N79_STATUS=='4'"  , "BR_CANCEL"   , X3CboxDesc( "N79_STATUS", "4" )   ) //"Cancelado"
	
	oMBrowse:aColumns[1]:cTitle := STR0071
	oMBrowse:aColumns[1]:nalign := 1

	//---------------
	//Seta tecla F12
	//---------------
	SetKey( VK_F12, bTeclaF12 )
	//"Não Enviado"(vermelho) "Aguardando" (Azul) "Pendente de Ajuste" (Branco) "Rejeitado"(Cancel) "Aprovado" (verde)
	bColor02 := { || Iif(N79->N79_STCLIE=='1' .or. Empty(N79->N79_STCLIE),'BR_VERMELHO', Iif(N79->N79_STCLIE=='2','BR_AZUL', Iif(N79->N79_STCLIE=='3','BR_BRANCO', IIF(N79->N79_STCLIE=='4',"BR_VERDE",''))))}
	ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oMBrowse| OGA700Leg() }  OF oMBrowse	
	
	oMBrowse:aColumns[2]:cTitle := STR0072	
	oMBrowse:aColumns[2]:nalign := 1

	oMBrowse:AddStatusColumns( {||OGA700Est(N79->( N79_TIPO ))}, {||OGA700Legen()})
	oMBrowse:aColumns[3]:cTitle := RetTitle("N79_TIPO") //"Tipo Negócio"
		
	oMBrowse:SetAttach( .T. ) //visualizações
	oMBrowse:DisableDetails()
	oMBrowse:Activate()	
	
	SetKey(VK_F12,{||})
	
return()


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contrato de Venda
*/
Static Function MenuDef()
	Local aRotina  := {}
	Local aRotina1 := {}
    Local aRotina2 := {}

	aAdd( aRotina1, { STR0076 ,"OGA700MAIL", 0, 4, 0, Nil } )      //Enviar email
	aAdd( aRotina1, { STR0058 ,"OGA700APMA('4')", 0, 4, 0, Nil } ) //Aprovar
	aAdd( aRotina1, { STR0230 ,"OGA700REAB()", 0, 4, 0, Nil } )    //"Reabrir"	
	
	aAdd( aRotina, { STR0054 , "PesqBrw"      , 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0055 , "OGA700VISU"   , 0, 2, 0, .f. } ) //"Visualizar"
	aAdd( aRotina, { STR0056 , "ViewDef.OGA700"   , 0, 3, 0, .t. } ) //"Incluir"
	aAdd( aRotina, { STR0057 , "OGA700UPDT"   , 0, 4, 0, .f. } ) //"Alterar"
	aAdd( aRotina, { STR0070 , "OGA700CPY"   , 0, 9, 0, .f. } )  //"Copiar"
	aAdd( aRotina, { STR0058 , "OGA700APVA()"   , 0, 4, 0, .f. } ) //"Aprovar"
	aAdd( aRotina, { STR0059 , "OGA700REPR()"   , 0, 4, 0, .f. } ) //"Rejeitar"
	aAdd( aRotina, { STR0233 , "OGA700CANC"   , 0, 4, 0, .f. } ) //"Cancelar Quantidade/Fixação"
	aAdd( aRotina, { STR0234 , "OGA335(N79->N79_CODCTR,N79->N79_FILIAL) " , 0, 4, 0, .f. } ) // # "Aditar Contrato"
	aAdd( aRotina, { STR0061 , "OGA700FIXA()" , 0, 4, 0, .f. } ) //"Fixar"
	aAdd( aRotina, { STR0069 , "AGRCONHECIM('N79')" , 0, 4, 0, .f. } ) //"Conhecimento"
	aAdd( aRotina, { STR0063 , "OGA700HIST"   , 0, 7, 0, .f. } ) //"Histórico"
	aAdd( aRotina, { STR0103 , "OGA700MODF"   , 0, 4, 0, .f. } ) //"Modificar Fixação" 
	aAdd( aRotina, { STR0075 , aRotina1 , 0, 4, 0, Nil } ) //"Aceite Cliente" 

    If __lCtrRisco
		aAdd( aRotina2, { STR0256,"OGA700CTRF(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, 'S')", 0, 4, 0, Nil } )    //Selecionar
	    aAdd( aRotina2, { STR0257,"OGA700CTRF(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, 'R')", 0, 4, 0, Nil } )    //Remover

        aAdd( aRotina, { STR0198, aRotina2 , 0, 4, 0, .f. } ) //"Contratos Futuros"	
	EndIf

Return( aRotina )

/*{Protheus.doc} OGA700VISU
Visualização de Negócio
@author jean.schulze
@since 11/10/2017
@version undefined
@type function
*/
Function OGA700VISU()
	FWExecView('', 'VIEWDEF.OGA700', MODEL_OPERATION_VIEW, , {|| .T. }) //executado para refazer a view - reload da estrutura de campos
return(.t.)

/*{Protheus.doc} OGA700UPDT
Executa a operação de Alteração
@author jean.schulze
@since 11/10/2017
@version undefined
@type function
*/
Function OGA700UPDT()
	
	If (N79->N79_STATUS $ "4")
		Help( ,,STR0031,, STR0104, 1, 0 ) //"AJUDA"# "Não é permitido alterar negócio com status cancelado."
		return(.F.)
	endif

	If (N79->N79_TIPO $ "2|3|5") .and. N79->N79_STATUS != '1' 
		Help( ,,STR0031,, STR0105, 1, 0 ) //"AJUDA"# "Não é permitido alterar fixação e cancelamento."
		return(.F.)
	endif
	
	If ("4" $ N79->N79_STCLIE) .and. (N79->N79_STATUS $ "3") .AND. !__lRegOpcional
		Help( ,,STR0031,, STR0106, 1, 0 ) //"AJUDA"# "Não é permitido alterar negócio com o status cliente como aprovado e status negócio como completo."
		return(.F.)
	endif
	
	if !empty(N79->N79_FLUIG) .and. N79->N79_STCLIE == "2" .and. N79->N79_TIPO == "1"	//está aguardando
		Help( , , STR0031, , STR0248 + N79->N79_FLUIG + STR0249, 1, 0 )
		return .f.
	endif	
	
	cStatusNJR := GetDataSql("select NJR_MODELO from " + RetSqlName("NJR") + " NJR " + ;
			                     "where NJR_FILIAL = '" + fwxFilial("NJR") + "' "        + ;
			                     "and NJR_CODCTR = '" + (N79->N79_CODCTR) + "' " + ;
			                     "and D_E_L_E_T_ = ' '" )	

	If !__lAutomato
        FWExecView('', 'VIEWDEF.OGA700', MODEL_OPERATION_UPDATE, , {|| .T. })  //executado para refazer a view - reload da estrutura de campos
    EndIf
return(.t.)

/*{Protheus.doc} OGA700CPY
//Executa a operação de cópia.
@author roney.maia
@since 31/01/2018
@version 1.0
@type function
*/
Function OGA700CPY()
	Private _aNCPN79	:= {"N79_CODNGC", "N79_DATA", "N79_CODCTR", "N79_STCLIE", "N79_STATUS", "N79_TIPO", "N79_GERCTR"} // ! Não remover variavel privada, sem analisar o uso em outros fontes
	Private _aNCPN7A	:= {"*"}  // ! Não remover variavel privada, sem analisar o uso em outros fontes
	Private _aNCPN7C	:= {"*"}  // ! Não remover variavel privada, sem analisar o uso em outros fontes
	Private _aNCPN7O	:= {"*"}  // ! Não remover variavel privada, sem analisar o uso em outros fontes
		
	Private _lOGA700I	:= .T. // Variavel para tratamento de inicializador padrão
	Private _lOGA700CP	:= .T. // Variável para determinar a operação de cópia
	
	If !(N79->N79_TIPO $ "1") 
		Help( , , STR0031, , STR0108, 1, 0 )//"AJuda"#"Somente novos negócios podem ser copiados."
		Return .F.
	EndIf
	
	If !__lAutomato
        FWExecView('', 'VIEWDEF.OGA700', 9, , {|| .T. }) 
    EndIf
Return .T.

/*{Protheus.doc} OGA700HIST
Listagem de Histórico de Negociação.
@author jean.schulze
@since 31/10/2017
@version undefined
@type function
*/
Function OGA700HIST()
	Local cArea   := GetArea()
	Local cChaveI := "N79->("+Alltrim(AGRSEEKDIC("SIX","N791",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
	
	dbSelectArea('NK9') // trata para somente mostrar os itens que possuem histórico
	NK9->(DbSetOrder(2))
	If NK9->(DbSeek(FwXfilial("NK9")+"N79"+&(cChaveI)))
		NK9->(dbCloseArea())
		AGRHISTTABE('N79', cChaveA)
	else
		Help( , , STR0031, , STR0109, 1, 0 )//"Ajudar"#"A negociação não possui histórico."
		NK9->(dbCloseArea())
	EndIf
	
	Restarea(cArea)
return .t.

/*{Protheus.doc} OGA700FIXA
//Chamada de Fixação
@author jean.schulze
@since 27/09/2017
@version undefined
@type function
*/
function OGA700FIXA(pcCodCaden)
	Local aArea	    := GetArea()
	Local aAreaNJR  := NJR->(GetArea())
	Local lExistSld := .f.
	
	Private cFilNgcFix  := "" //filial do negócio fixado
	Private cCodNgcFix  := "" //negócio originador da fixação
	Private cCodVrsFix  := "" //versão do negócio para fixação
	Private cCodCadFix  := "" //Cadencia que vai ser manutenida.

	// Validações de fixação a partir do menu Fixar
	If N79->N79_TIPO != '1' // Se o tipo de negócio for diferente de 1 - Novo
		Help( , , STR0031, , STR0110, 1, 0 )//"Ajuda"#"A fixação deve ser realizada apenas quando o negócio for do tipo (Novo)."
		Return .F.
	ElseIf Empty(N79->N79_CODCTR)
		Help( , , STR0031, , STR0111, 1, 0 )//"Ajuda"#"Para realizar a fixação, o novo negócio deve possuir um contrato vinculado."
		Return .F.
	ElseIf !Empty(N79->N79_CODCTR) // Validação se existe contrato, colocada em ifelse para o caso de acrescimo de outras validações.
		dbSelectArea('NJR') // Seleciona o alias para atualizar o que esteja sendo manipulado e alterado na NJR, para fazer o posicione
		If !(AllTrim(Posicione("NJR",1,FwXFilial("NJR") + N79->N79_CODCTR, "NJR_STATUS")) $ 'A|I') .AND. !__lRegOpcional
			Help( , , STR0031, , STR0112, 1, 0 )//Ajuda#"Para realizar a fixação, o contrato vinculado ao novo negócio deve estar confirmado."
			RestArea(aArea)
			Return .F.
		//ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '2')) //verifica se tem algum negócio em execução, trava de fixação
		//	Help( , , STR0031, , STR0113 + cNgcCtr, 1, 0 )//Ajuda#"Já existe uma fixação em andamento para o contrato. Negócio: "
		//	Return .F.
		ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '3')) //verifica se tem algum negócio em execução, trava de fixação
			Help( , , STR0031, , STR0114 + cNgcCtr, 1, 0 )//Ajuda#"Já existe um cancelamento em andamento para o contrato. Negócio: "
			Return .F.
		ElseIf Posicione("N8C",1,FwXFilial("N8C") + N79->N79_BOLSA, "N8C_PRCBOL") == "2" //bolsa com indice(ESALQ)	
			Help( , , STR0031, , STR0115, 1, 0 )//"AJuda"#"Não é póssível fixar o contrato, pois o mesmo utiliza bolsa de indíces."
			Return .F.	
		EndIf
		
	EndIf
	NJR->(RestArea(aAreaNJR))

	//valida os saldos das cadências
	DbselectArea( "NNY" )
	NNY->(DbGoTop())
	NNY->(dbSetOrder(1))
		
	if valtype(pcCodCaden) <> "U" .and. !empty(pcCodCaden)

		if NNY->(DbSeek(N79->N79_FILIAL+N79->N79_CODCTR+pcCodCaden))
			if  OGX700TNN8(NNY->NNY_FILIAL, NNY->NNY_CODCTR, NNY->NNY_ITEM) <  NNY->NNY_QTDINT
				lExistSld := .t. //atualiza variavel para informa q temos saldo.
			endif
		else
			Help( , , STR0031, , STR0116, 1, 0 )//"Ajuda"#"Cadência não encontrada para o contrato."
			Return .F.	
		endif
		
	else //valida se temos alguma cadencia disponível de fixação
		
		if NNY->(DbSeek(N79->N79_FILIAL+N79->N79_CODCTR))
			
			while NNY->( !Eof() ) .and. !lExistSld .and. alltrim(NNY->NNY_FILIAL+NNY->NNY_CODCTR) == alltrim(N79->N79_FILIAL+N79->N79_CODCTR)
				if  OGX700TNN8(NNY->NNY_FILIAL, NNY->NNY_CODCTR, NNY->NNY_ITEM) <  NNY->NNY_QTDINT
					lExistSld := .t. //atualiza variavel para informa q temos saldo.
				endif
				NNY->(DbSkip())
			enddo
			
		endif			
	endif	
	
	if !lExistSld .AND. !__lRegOpcional
		Help( , , STR0031, , STR0117, 1, 0 )//"Ajuda"#"O contrato já está plenamente fixado"
		return .f. 
	endif
	
	//apropria os dados para população da fixação
	cFilNgcFix  := N79->N79_FILIAL //filial do negócio fixado
    cCodNgcFix  := N79->N79_CODNGC //negócio originador da fixação
    cCodVrsFix  := N79->N79_VERSAO //versao
    cCodCadFix  := iif(valtype(pcCodCaden) <> "U" .and. !empty(pcCodCaden), pcCodCaden, "")
    
    _cProduto   := N79->N79_CODPRO
	_cMoeda     := N79->N79_MOEDA
    
	If !__lAutomato         
		If __lRegOpcional
			FWExecView(STR0118 + N79->N79_DESCTR, 'VIEWDEF.OGA700', MODEL_OPERATION_UPDATE, , {|| .T. })//"Fixação de Contrato - "
		Else
			FWExecView(STR0118 + N79->N79_DESCTR, 'VIEWDEF.OGA700', MODEL_OPERATION_INSERT, , {|| .T. })//"Fixação de Contrato - "
		EndIf
    EndIf
	
return(.t.)

/*{Protheus.doc} OGA700CANC
Rotina que trata o cancelamento de fixações
@author jean.schulze
@since 27/10/2017
@version undefined
@type function
*/
Function OGA700CANC()
	Local aArea	    := GetArea()
	Local lExistSld := .f.

	Private cFilNgcFix  := "" //filial do negócio fixado
	Private cCodNgcFix  := "" //negócio originador da fixação
	Private cCodVrsFix  := "" //versão do negócio para fixação

	// Validações de fixação a partir do menu Fixar
	If N79->N79_STATUS <> '3' // Se o tipo de negócio for diferente de 3 - finalziado
		Help( , , STR0031, , STR0119, 1, 0 )//"Ajuda"#"O cancelamento só pode ser realizado para negócios finalizados."
		Return .F.
	ElseIf !(N79->N79_TIPO $ '1|2|5') //Novo Negócio - Fixação
		Help( , , STR0031, , STR0120, 1, 0 )//"Ajuda"#"O cancelamento deve ser realizada apenas quando o negócio for do tipo (Novo/Fixação)."
		Return .F.
	ElseIf Empty(N79->N79_CODCTR)
		Help( , , STR0031, , STR0121, 1, 0 )//"Ajudar"#"Para realizar a fixação, o novo negócio deve possuir um contrato vinculado."
		Return .F.
	ElseIf !Empty(N79->N79_CODCTR) // Validação se existe contrato, colocada em ifelse para o caso de acrescimo de outras validações.
		dbSelectArea('NJR') // Seleciona o alias para atualizar o que esteja sendo manipulado e alterado na NJR, para fazer o posicione
		If !(AllTrim(Posicione("NJR",1,FwXFilial("NJR") + N79->N79_CODCTR, "NJR_STATUS")) $ 'A|I')
			Help( , , STR0031, , STR0122, 1, 0 )//"Ajuda"#"Para realizar a fixação, o contrato vinculado ao novo negócio deve estar confirmado."
			NJR->(dbCloseArea())
			RestArea(aArea)
			Return .F.
		ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '3')) //verifica se tem algum negócio em execução, trava de fixação
			Help( , , STR0031, , STR0123 + cNgcCtr, 1, 0 )//"Ajuda"#"Já existe um cancelamento em andamento para o contrato. Negócio: "
			Return .F.
		//ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '2')) //verifica se tem algum negócio em execução, trava de fixação
		//	Help( , , STR0031, , STR0124 + cNgcCtr, 1, 0 )//"Ajuda"#"Já existe uma fixação em andamento para o contrato. Negócio: "
		//	Return .F.	
		EndIf
		NJR->(dbCloseArea())
		RestArea(aArea)
	Endif
	
	if N79->N79_TIPO == "1" //novo negócio
	
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				if OGX700SDCQ(N79->N79_FILIAL, N79->N79_CODCTR, N7A->N7A_CODCAD) > 0
					lExistSld := .t.
				endif
				N7A->(DbSkip())
			enddo
		endif	
	endif						
	
	if N79->N79_FIXAC == "1" //preço -  validar NN8
		
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
			
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				if  OGX700SLDP(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, N7A->N7A_CODCAD) > 0
					lExistSld := .t. //atualiza variavel para informa q temos saldo.
				endif
				N7A->(DbSkip())
			enddo
			
		endif							
	elseif N79->N79_FIXAC == "2" //Componente -  validar N7M
		
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
									
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				DbselectArea( "N7C" )
				N7C->(DbGoTop())
				N7C->(dbSetOrder(1))
				if N7C->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N7A->N7A_CODCAD))
					
					while N7C->( !Eof() ) .and. !lExistSld .and. alltrim(N7C->N7C_FILIAL+N7C->N7C_CODNGC+N7C->N7C_VERSAO+N7C->N7C_CODCAD) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N7A->N7A_CODCAD)
						if N7C->N7C_QTAFIX > 0
							if  OGX700SLDC(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, N7A->N7A_CODCAD, N7C->N7C_CODCOM) > 0
								lExistSld := .t. //atualiza variavel para informa q temos saldo.
							endif
						endif	
						N7C->(DbSkip())
					enddo
					
				endif	
				
				N7A->(DbSkip())
			enddo
			
		endif
	endif
	
	if !lExistSld
		Help( , , STR0031, , STR0125, 1, 0 )//"Ajuda"#"O negócio não possui saldo para cancelar."
		Return .F.
	endif
	
	//apropria os dados para população da fixação
	cFilNgcFix  := N79->N79_FILIAL //filial do negócio fixado
    cCodNgcFix  := N79->N79_CODNGC //negócio originador da fixação
    cCodVrsFix  := N79->N79_VERSAO //versao
    cCodCadFix  := "" //reset
    
    _cProduto   := N79->N79_CODPRO
	_cMoeda     := N79->N79_MOEDA
    
	If !__lAutomato
        nRet := FWExecView('', 'VIEWDEF.OGA700', MODEL_OPERATION_INSERT, , {|| .T. })
    EndIf

	
return(.t.)

/*{Protheus.doc} OGA700MODF
Função para modificar fixação
@author jean.schulze
@since 24/09/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGA700MODF()
	Local aArea	    := GetArea()
	Local lExistSld := .f.	

	Private cFilNgcFix  := "" //filial do negócio fixado
	Private cCodNgcFix  := "" //negócio originador da fixação
	Private cCodVrsFix  := "" //versão do negócio para fixação

	// Validações de fixação a partir do menu Fixar
	If N79->N79_STATUS <> '3' // Se o tipo de negócio for diferente de 3 - finalziado
		Help( , , STR0031, , STR0126, 1, 0 )//"Ajuda"#"A modificação só pode ser realizada para negócios finalizados."
		Return .F.
	ElseIf !(N79->N79_TIPO $ '1|2|5') //Novo Negócio - Fixação
		Help( , , STR0031, , STR0127, 1, 0 )//"Ajuda"#"A Modificação deve ser realizada apenas quando o negócio for do tipo (Novo/Fixação/Modificação1)."
		Return .F.
	ElseIf Empty(N79->N79_CODCTR)
		Help( , , STR0031, , STR0128, 1, 0 )//"Ajuda"#"Para realizar a modificação, o novo negócio deve possuir um contrato vinculado."
		Return .F.
	ElseIf !Empty(N79->N79_CODCTR) // Validação se existe contrato, colocada em ifelse para o caso de acrescimo de outras validações.
		//removida validação do contrato a pedido da SLC.
		//dbSelectArea('NJR') // Seleciona o alias para atualizar o que esteja sendo manipulado e alterado na NJR, para fazer o posicione
		//If !(AllTrim(Posicione("NJR",1,FwXFilial("NJR") + N79->N79_CODCTR, "NJR_STATUS")) $ 'A|I')
		//	Help( , , STR0031, , STR0128, 1, 0 )//"Ajuda"#"Para realizar a fixação, o contrato vinculado ao novo negócio deve estar confirmado."
		//	NJR->(dbCloseArea())
		//	RestArea(aArea)
		//	Return .F.
		//Else
		If !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '3')) //verifica se tem algum negócio em execução, trava de fixação
			Help( , , STR0031, , STR0128 + cNgcCtr, 1, 0 )//"Ajuda"#"Já existe um cancelamento em andamento para o contrato. Negócio: "
			Return .F.
		//ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '2')) //verifica se tem algum negócio em execução, trava de fixação
		//	Help( , , STR0031, , STR0129 + cNgcCtr, 1, 0 )//"Ajuda"#"Já existe uma fixação em andamento para o contrato. Negócio: "
		//	Return .F.	
		ElseIf !Empty(cNgcCtr := OGX700VNGA(N79->N79_FILIAL, N79->N79_CODCTR, '5')) //verifica se tem algum negócio em execução, trava de fixação
			Help( , , STR0031, , STR0130 + cNgcCtr, 1, 0 )//"Ajuda"#"Já existe uma modificação em andamento para o contrato. Negócio: "
			Return .F.		
		EndIf
		NJR->(dbCloseArea())
		RestArea(aArea)
	Endif
	
	if N79->N79_TIPO == "1" //novo negócio
	
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				if OGX700SDCQ(N79->N79_FILIAL, N79->N79_CODCTR, N7A->N7A_CODCAD) > 0
					lExistSld := .t.
				endif
				N7A->(DbSkip())
			enddo
		endif	
		
	endif						
	
	if N79->N79_FIXAC == "1" //preço -  validar NN8
		
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
			
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				if  OGX700SLDP(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, N7A->N7A_CODCAD) > 0
					lExistSld := .t. //atualiza variavel para informa q temos saldo.
				endif
				N7A->(DbSkip())
			enddo
			
		endif							
	elseif N79->N79_FIXAC == "2" //Componente -  validar N7M
		
		DbselectArea( "N7A" )
		N7A->(DbGoTop())
		N7A->(dbSetOrder(1))
		if N7A->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO))
									
			while N7A->( !Eof() ) .and. !lExistSld .and. alltrim(N7A->N7A_FILIAL+N7A->N7A_CODNGC+N7A->N7A_VERSAO) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO)
				DbselectArea( "N7C" )
				N7C->(DbGoTop())
				N7C->(dbSetOrder(1))
				if N7C->(DbSeek(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N7A->N7A_CODCAD))
					
					while N7C->( !Eof() ) .and. !lExistSld .and. alltrim(N7C->N7C_FILIAL+N7C->N7C_CODNGC+N7C->N7C_VERSAO+N7C->N7C_CODCAD) == alltrim(N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N7A->N7A_CODCAD)
						if N7C->N7C_QTAFIX > 0
							if  OGX700SLDC(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO, N7A->N7A_CODCAD, N7C->N7C_CODCOM) > 0
								lExistSld := .t. //atualiza variavel para informa q temos saldo.
							endif
						endif	
						N7C->(DbSkip())
					enddo
					
				endif	
				
				N7A->(DbSkip())
			enddo
			
		endif
	endif
	
	if !lExistSld
		Help( , , STR0031, , STR0131, 1, 0 )//"Ajuda"#"O negócio não possui saldo para modificar."
		Return .F.
	endif
	
	//apropria os dados para população da fixação
	cFilNgcFix  := N79->N79_FILIAL //filial do negócio fixado
    cCodNgcFix  := N79->N79_CODNGC //negócio originador da fixação
    cCodVrsFix  := N79->N79_VERSAO //versao
    cCodCadFix  := "" //reset
    
    _cProduto   := N79->N79_CODPRO
	_cMoeda     := N79->N79_MOEDA
    
	If !__lAutomato
        FWExecView('', 'VIEWDEF.OGA700', MODEL_OPERATION_INSERT, , {|| .T. })
    EndIf
	
return(.t.)

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA700 - Negociações
*/
Static Function ModelDef()
	Local oStruN79  := FWFormStruct( 1, "N79" )	
	Local oStruN7A  := FWFormStruct( 1, "N7A", { |x| !ALLTRIM(x) $ 	'N7A_CODNGC, N7A_VERSAO'} )
	Local oStruN7C  := FWFormStruct( 1, "N7C", { |x| !ALLTRIM(x) $ 	'N7C_CODNGC, N7C_VERSAO,  N7C_CODCAD '} )
	Local oStruN7O  := FWFormStruct( 1, "N7O", { |x| !ALLTRIM(x) $ 	'N7O_CODNGC, N7O_VERSAO , N7O_CODCAD, N7O_CODCOM '} )
	Local oStruN8S  := FWFormStruct( 1, "N8S", { |x| !ALLTRIM(x) $ 	'N8S_CODNGC, N8S_VERSAO'} )
	Local oModel    := MPFormModel():New( 'OGA700' , , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) } )
	Local lModeView := iif(FWIsInCallStack("OGA700MODF") .OR. FWIsInCallStack("OGA700CANC"), .T. , .F.)//abre em modo resumido
	Local nIt		:= 0
	Local lCopy		:= (Type("_lOGA700CP") == "L" .AND. _lOGA700CP)
	Local cUMPrc    := ""   
	Local cUMPrd    := ""

	If lCopy		
		If !Empty(_aNCPN79) .AND. Len(_aNCPN79) == 1 .AND. "*" $ _aNCPN79[1]
			For nIt := 1 To Len(oStruN79:GetFields())
				aAdd(_aNCPN79, oStruN79:GetFields()[nIt][3])
			Next nIt
		EndIf
		
		If !Empty(_aNCPN7A) .AND. Len(_aNCPN7A) == 1 .AND. "*" $ _aNCPN7A[1]
			For nIt := 1 To Len(oStruN7A:GetFields())
				aAdd(_aNCPN7A, oStruN7A:GetFields()[nIt][3])
			Next nIt
		EndIf
		
		If !Empty(_aNCPN7C) .AND. Len(_aNCPN7C) == 1 .AND. "*" $ _aNCPN7C[1]
			For nIt := 1 To Len(oStruN7C:GetFields())
				aAdd(_aNCPN7C, oStruN7C:GetFields()[nIt][3])
			Next nIt
		EndIf
		
		If !Empty(_aNCPN7O) .AND. Len(_aNCPN7O) == 1 .AND. "*" $ _aNCPN7O[1]
			For nIt := 1 To Len(oStruN7O:GetFields())
				aAdd(_aNCPN7O, oStruN7O:GetFields()[nIt][3])
			Next nIt
		EndIf		
	EndIf	
	
	oStruN79:SetProperty( "N79_QTDNGC", MODEL_FIELD_OBRIGAT, .F.  ) //remove a obrigatoriedade - forçar a respeitar os tratamentos de negócio
	oStruN7A:SetProperty( "N7A_QTDINT", MODEL_FIELD_OBRIGAT, .F.  ) //remove a obrigatoriedade - forçar a respeitar os tratamentos de negócio	
	oStruN7C:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F.  ) //remove a obrigatoriedade - forçar a respeitar os tratamentos de negócio	

	If !__lCtrRisco
		oStruN7C:RemoveField("N7C_QTDCTR") 
		oStruN7C:RemoveField("N7C_CODBCO") 
		oStruN7C:RemoveField("N7C_OPEFIX") 
	EndIf
		
	If oStruN7C:HasField("N7C_QTDCTR")
        oStruN7C:SetProperty( "N7C_QTDCTR", MODEL_FIELD_VALID, {|| OGA700VQTC() } )
    EndIf

	oStruN79:SetProperty( "N79_CODFIN", MODEL_FIELD_OBRIGAT, .F.  )
	oStruN79:SetProperty( 'N79_BOLSA' , MODEL_FIELD_INIT , {|| OGA700INB()})

	If oStruN79:HasField("N79_CLASSP")
		oStruN79:SetProperty( 'N79_CLASSP' , MODEL_FIELD_INIT , {|| OGA700ICPQ()})
	EndIf
	If oStruN79:HasField("N79_CLASSQ")
		oStruN79:SetProperty( 'N79_CLASSQ' , MODEL_FIELD_INIT , {|| OGA700ICPQ()})
	EndIf

	oStruN79:SetProperty( "N79_FILORG", MODEL_FIELD_VALID, {| oField | OGA700VDQT( oField, 'N79_FILORG' ) } )
	If FWIsInCallStack("OGC004") .OR. FWIsInCallStack("OGA700FIXA")
		oStruN79:SetProperty( "N79_QTDNGC", MODEL_FIELD_VALID, {| oField | OGA700VDQ2( oField, 'N79_QTDNGC' ) } ) //gatilho de quantidade - qtd
	EndIf
	oStruN79:SetProperty( "N79_TIPFIX", MODEL_FIELD_VALID, {| oField | OGA700VDQT( oField, 'N79_TIPFIX' ) } ) //gatilho de quantidade - opção fixo/fixar
	oStruN79:SetProperty( "N79_FIXAC" , MODEL_FIELD_VALID, {| oField | OGA700VDQT( oField, 'N79_FIXAC' ) } )
	oStruN79:SetProperty( "N79_TPCANC", MODEL_FIELD_VALID, {| oField | OGA700VDQT( oField, 'N79_TPCANC' ) } )
	oStruN7A:SetProperty( "N7A_QTDINT", MODEL_FIELD_VALID, {| oField | OGA700VDQT( oField, 'N7A_QTDINT' ) } ) //gatilho de quantidade - opção fixo/fixar
	oStruN7A:SetProperty( "N7A_IDXCTF", MODEL_FIELD_VALID, {|| BuscaBolsa() } )
	oStruN79:SetProperty( "N79_BOLSA",  MODEL_FIELD_VALID, {|| OGA700VLD() } )

	//tratamento para composição de entidades
	oStruN79:SetProperty( "N79_NOMENT", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N79_NOMENT") } ) 
	oStruN79:SetProperty( "N79_NLJENT", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N79_NLJENT") } ) 
	oStruN7A:SetProperty( "N7A_IDXCTF", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N7A_IDXCTF") } ) 
	oStruN7C:SetProperty( "N7C_VLRCOM", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N7C_VLRCOM") } )
	
	If oStruN79:HasField("N79_TOETAP")
        oStruN79:SetProperty( "N79_TOETAP", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N79_TOETAP") } )
    EndIf
	
	//oStruN79:SetProperty( "N79_QTDNGC", MODEL_FIELD_WHEN, {| oField | OGA700VWHN(oField, "N79_QTDNGC") } ) 

	oStruN79:AddTrigger( "N79_CODENT", "N79_TPCONT", { || .T. }, { | oField | OGA700TRIG( oField, "N79_TPCONT" ) } )
	oStruN79:AddTrigger( "N79_LOJENT", "N79_TPCONT", { || .T. }, { | oField | OGA700TRIG( oField, "N79_TPCONT" ) } )
	oStruN79:AddTrigger( "N79_TPCONT", "N79_CODENT", { || .T. }, { | oField | OGA700TRIG( oField, "N79_CODENT" ) } )
	//oStruN79:AddTrigger( "N79_UM2PRO", "N79_UM2PRO", { || .T. }, { | x | fTrgN79CVT( x ) } )

	If oStruN79:HasField("N79_TOETAP")
        oStruN79:AddTrigger( "N79_TOETAP", "N79_DESTPO", { || .T. }, { | oField | OGA700VTO(oField,"N79_TOETAP")} )
    EndIf

	oStruN7C:AddTrigger( "N7C_VLRCOM", "N7C_VLRUN1", { || .T. }, { | oField | OGX700GVLR( oField, "N7C_VLRUN1" ) } )
	oStruN7C:AddTrigger( "N7C_TXCOTA", "N7C_VLRUN1", { || .T. }, { | oField | OGX700GVLR( oField, "N7C_VLRUN1" ) } )
	oStruN7C:AddTrigger( "N7C_QTAFIX", "N7C_VLTOTC", { || .T. }, { | oField | OGX700GVLR( oField, "N7C_VLTOTC" ) } )

	oStruN7C:AddField("TP" , "Legenda", 'N7C_STSLEG', 'BT' , 1 , 0, , ;
  					   NIL , NIL, NIL, {||iif(!empty(N7C->(N7C_TPCALC)), OGX700LEG(N7C->(N7C_TPCALC)),"")}, NIL, .F., .T.) // Adiciona a Estrutura da Grid o Botão de Legenda

	oModel:SetDescription( STR0132 ) //"Registro de Negócios"

	oModel:AddFields("N79UNICO", /*cOwner*/, oStruN79,{|oFieldModel, cAction, cIDField, xValue| PreValN79(oFieldModel, cAction, cIDField, xValue)} , /*bPost*/, /*bLoad */  )
	oModel:GetModel( "N79UNICO" ):SetDescription( STR0133 ) //"Dados do Negócio"

	/***CADENCIAS****/
	oModel:AddGrid( "N7AUNICO", "N79UNICO", oStruN7A, , , { | oGrid, nLine, cAction, cIDField, xValue, xCurrentValue | ValChkN7A( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue ) }, , {|oObj, lCopia| LoadN7A(oObj, lCopia)})
	
	oModel:GetModel( "N7AUNICO" ):SetDescription( STR0064 ) //"Previsão de Entrega"
	oModel:GetModel( "N7AUNICO" ):SetUniqueLine( { "N7A_CODCAD" } )
	oModel:GetModel( "N7AUNICO" ):SetOptional( .T. )
	oModel:SetRelation( "N7AUNICO", { { "N7A_FILIAL", "xFilial( 'N7A' )" }, { "N7A_CODNGC", "N79_CODNGC" }, { "N7A_VERSAO", "N79_VERSAO" }  }, N7A->( IndexKey( 1 ) ) )

	/***COMPONENTES****/
	oModel:AddGrid( "N7CUNICO", "N7AUNICO", oStruN7C,{ | oGrid, nLine, cAction, cIDField, xValue, xCurrentValue | ValChkN7C( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue ) } , , , /*{ | oGrid | ValPosNN7( oGrid ) }*/, {|oGrid| LoadN7C(oGrid)} )
	oModel:GetModel( "N7CUNICO" ):SetDescription( STR0065 ) //"Componentes"
	oModel:GetModel( "N7CUNICO" ):SetOptional( .T. )
	oModel:SetRelation( "N7CUNICO", { { "N7C_FILIAL", "xFilial( 'N7C' )" }, { "N7C_CODNGC", "N79_CODNGC" }, { "N7C_VERSAO", "N79_VERSAO" }, { "N7C_CODCAD", "N7A_CODCAD" }  }, N7C->( IndexKey( 1 ) ) )
	oModel:GetModel( "N7CUNICO" ):SetNoDelete( .t. )
	oModel:GetModel( "N7CUNICO" ):SetNoInsert( .t. )
	
	/***Negócios(Fixados) X Componentes Fixados ****/
	oModel:AddGrid( "N7OUNICO", "N7CUNICO", oStruN7O, , , ,  )
	oModel:GetModel( "N7OUNICO" ):SetDescription( "Negócios(Fixados) X Componentes Fixados " ) //Negócios(Fixados) X Componentes Fixados 
	oModel:GetModel( "N7OUNICO" ):SetOptional( .T. )
	oModel:SetRelation( "N7OUNICO", { { "N7O_FILIAL", "xFilial( 'N7O' )" }, { "N7O_CODNGC", "N79_CODNGC" }, { "N7O_VERSAO", "N79_VERSAO" }, { "N7O_CODCAD", "N7A_CODCAD" } , { "N7O_CODCOM", "N7C_CODCOM" }  }, N7O->( IndexKey( 1 ) ) )
		
	/***Portos****/
	oModel:AddGrid( "N8SUNICO", "N79UNICO", oStruN8S, , , ,  )
	oModel:GetModel( "N8SUNICO" ):SetDescription( "Portos/Aeroportos" ) //Portos/Aeroportos
	oModel:GetModel( "N8SUNICO" ):SetOptional( .T. )
	oModel:GetModel( "N8SUNICO" ):SetUniqueLine( { "N8S_TIPO", "N8S_CODROT"  } )
	oModel:SetRelation( "N8SUNICO", { { "N8S_FILIAL", "xFilial( 'N8S' )" }, { "N8S_CODNGC", "N79_CODNGC" }, { "N8S_VERSAO", "N79_VERSAO" }  }, N8S->( IndexKey( 1 ) ) )

	/*Totalizadores*/
	If !lModeView

		oModel:AddCalc( 'OGA700CALC1', 'N79UNICO', 'N7AUNICO', 'N7A_QTDINT', 'N7A__TOT01', 'SUM', ,,STR0211 ) //##Total quantidade
		oModel:AddCalc( 'OGA700CALC1', 'N79UNICO', 'N7AUNICO', 'N7A_QTDINT', 'N7A__TOT02', 'FORMULA',;
			,,STR0212 , {|oModel,nTotalAtual,xValor,lSomando| OGA7002UND(oModel,nTotalAtual,xValor,lSomando)} ) //#Quantidade total em
	
	Endif

	If lCopy
		oModel:GetModel( "N79UNICO" ):SetFldNoCopy(_aNCPN79)
		oModel:GetModel( "N7AUNICO" ):SetFldNoCopy(_aNCPN7A)
		oModel:GetModel( "N7CUNICO" ):SetFldNoCopy(_aNCPN7C)
		oModel:GetModel( "N7OUNICO" ):SetFldNoCopy(_aNCPN7O)		
	EndIf

	oModel:SetVldActivate(	{ | oModel | VldActveMd( oModel, oModel:GetOperation() ) })
	oModel:SetActivate( 	{ | oModel | ActivateMD( oModel, oModel:GetOperation() ) } )


Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function ViewDef()
	Local cCampN7C  := SuperGetMV("MV_AGRO011",.f.,"N7C_DESCRI,N7C_DMOECO,N7C_UMCOM,N7C_TIPORD,N7C_VLRIDX,N7C_QTAFIX,N7C_VLRCOM,N7C_QTDFIX,N7C_VLRFIX,N7C_TXCOTA,N7C_VLRUN1,N7C_VLRUN2,N7C_VLTOTC,N7C_QTDCTR") 
	Local oStruN79  := FWFormStruct( 2, "N79", { |x| !ALLTRIM(x) $  'N79_GENMOD|N79_TECGMO|N79_CODIQL|N79_CLASSP|N79_CLASSQ|N79_CODMDT'+;
                                                                    '|N79_FLUIG|N79_RESMIN|N79_OBSINT|N79_FILCNP|N79_LSTSTS|N79_SELCTR'+;
                                                                    '|N79_TOETAP|N79_DESTPO' } )    

	Local oStruN7A  := FWFormStruct( 2, "N7A", { |x| !ALLTRIM(x) $ 	'N7A_CODNGC,N7A_VERSAO,N7A_QTDFIX,N7A_MESBOL,N7A_MESANO,N7A_USOFIX,N7A_MEMBAR,N7A_QTDDIS,N7A_QTDBLQ, N7A_TIPRES'} )
	Local oStruN7C  := FWFormStruct( 2, "N7C", { |x|  ALLTRIM(x) $ 	cCampN7C}  )
	Local oStruN8S  := FWFormStruct( 2, "N8S", { |x| !ALLTRIM(x) $ 	'N8S_CODNGC,N8S_VERSAO'} )
	Local oStruAux  := nil //estrutura auxiliar visualização compacta
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel( "OGA700" )
	Local lModeView := iif(FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC")  .or. FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO $ "2|3|5") .or. FWIsInCallStack("A097Visual"), SuperGetMv("MV_AGRO007",,.T.) , .F.)//abre em modo resumido
	Local nI        := 0
    Local aFields   := {}
    Local lCopy	    := (Type("_lOGA700CP") == "L" .AND. _lOGA700CP)
	Local lGodao	:= .F. 
	Local lInsNew	:= .F. //inclusão
   	
	Local oCalcN7A := IIf(!lModeView, FWCalcStruct( oModel:GetModel('OGA700CALC1')), Nil)

	oView:SetModel( oModel )

	lGodao	:= fAlgodao(oModel)	
	lInsNew := fVldInsNew(oModel) 

	oStruN7C:AddField( "N7C_STSLEG" ,'01' , "", "Legenda" , {} , 'BT' ,'@BMP', ;//Tipo do Calculo
	 					NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	//mesmo se estes campos forem incluidos no parametro, precisam ser retirados da estrutura.
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_CODNGC") //RemoveField
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_VERSAO")
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_CODCAD")
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_TPCALC")
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_CODCOM")
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_ITEMCO")
	oStruN7C := AlteraStru(oStruN7C, 0, "N7C_NUMPED")
	
	If !__lCtrRisco
		oStruN7C := AlteraStru(oStruN7C, 0, "N7C_QTDCTR")
		oStruN7C := AlteraStru(oStruN7C, 0, "N7C_CODBCO")
		oStruN7C := AlteraStru(oStruN7C, 0, "N7C_OPEFIX")
	EndIf

	If oStruN7C:HasField("N7C_QTDCTR")
        oStruN7C:SetProperty('N7C_QTDCTR',MVC_VIEW_PICT,'@E 9,999,999.99')
    EndIf
	
	oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_ORDEM, "N7C_DESCRI", "07") //MVC_VIEW_ORDEM
	oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_ORDEM, "N7C_DMOECO", "08")
	oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_ORDEM, "N7C_UMCOM" , "09")
    
    AGRXSTPROP(oStruN79, "N79_CODENT" , MVC_VIEW_LOOKUP , { || OGA700F3EP() })   
    
    If !lInsNew //inclusao via menu
    	If lCopy
    		cUmProd := Posicione("SB5",1,FwxFilial("SB5")+N79->N79_CODPRO,"B5_UMPRC")
    	Else
    		cUmProd := N79->N79_UMPRC
    	EndIf
    	oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_TITULO, "N7C_VLRUN1" , AGRMVSIMB(N79->N79_MOEDA) + " / " + cUmProd)
    	oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_TITULO, "N7C_VLRUN2" , AGRMVSIMB(N79->N79_MOEDA) + " / " + N79->N79_UM1PRO)
    	
    ElseIf ValType(_cProduto) != "U" .And. ValType(_cMoeda) != "U" 
    	If !Empty(_cProduto) .and. !Empty(_cMoeda)
    		oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_TITULO, "N7C_VLRUN1" , AGRMVSIMB(_cMoeda) + " / " + If(!Empty(AgrUmPrc( _cProduto )),AgrUmPrc( _cProduto ),""))
    		oStruN7C := AlteraStru(oStruN7C, MVC_VIEW_TITULO, "N7C_VLRUN2" , AGRMVSIMB(_cMoeda)  + " / " + Posicione("SB1",1,FwxFilial("SB1") + _cProduto,"B1_UM"))
    	EndIf
    	    	
	Endif	
	
	//verifica a necessidade para exibir o botão de reserva de fardos
	if lInsNew .or. ((FWIsInCallStack("OGA700UPDT") .or. FWIsInCallStack("OGA700CPY")) .and. N79->N79_TIPO $ "1") 
		if ( lInsNew .and. AGRTPALGOD(_cProduto)) .or. AGRTPALGOD(N79->N79_CODPRO)  //É algodão
			oView:AddUserButton(STR0219 ,'',{|oView| OGA700TKUP(oView)}) // # "Reserva de Fardos"
		endif
	endif

	oView:AddUserButton(STR0218,'',{|| OGC180(M->N79_CODPRO)})
	
    AGRXSTPROP(oStruN79, "N79_CODPRO" , MVC_VIEW_CANCHANGE , .F.)  //bloqueia o campo Produto
    AGRXSTPROP(oStruN79, "N79_MOEDA" , MVC_VIEW_CANCHANGE , .F.)  //bloqueia o campo Moeda
    
	oStruN79:SetProperty("N79_QTDNGC",MVC_VIEW_CANCHANGE,.F.) //bloqueia o campo de quantidade.
	oStruN79:SetProperty("N79_QTDUM2",MVC_VIEW_CANCHANGE,.F.) //bloqueia o campo de quantidade.
	oStruN79:SetProperty("N79_UM2PRO",MVC_VIEW_CANCHANGE,.F.) //bloqueia o campo de quantidade.		

	oStruN7A:RemoveField("N7A_FILCNP") // REMOVE O CAMPO N7A_FILCNP DA VIEW
			
	If oStruN7C:HasField("N7C_TIPORD")	
		oStruN7C:RemoveField("N7C_TIPORD")
	EndIf
	
	oStruN79:RemoveField("N79_CODFIN")			
	oStruN79:RemoveField("N79_DESFIN")
	
	if lModeView //visualização resumida - fixação e cancelamento

		oStruN7A  := FWFormStruct( 2, "N7A", { |x| !ALLTRIM(x) $ 'N7A_CODNGC,N7A_VERSAO,N7A_QTDFIX,N7A_MESBOL,N7A_MESANO,N7A_ENTORI,N7A_LOJORI,N7A_ENTDES,N7A_LOJDES,N7A_DATFIM,N7A_DATINI,N7A_MEMBAR,N7A_CODRES,N7A_TIPRES'} ) //somente os campos Necessários

		if FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("A097Visual") .or. FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO $ "3|5") 
			oStruN79  := FWFormStruct( 2, "N79", { |x| ALLTRIM(x) $  'N79_CODENT,N79_LOJENT, N79_NOMENT, N79_NLJENT, N79_CODCTR, N79_DATA, N79_CODSAF, N79_CODPRO, N79_DESPRO, N79_FIXAC, N79_NGCREL, N79_VRSREL, N79_SELCTR'}) //somente os campos necessários
			oStruAux  := FWFormStruct( 2, "N79", { |x| ALLTRIM(x) $  'N79_QTDNGC,N79_DTMULT, N79_TPCANC, N79_CODMTV'})
			
            AGRXSTPROP(oStruN79, "N79_FIXAC" , MVC_VIEW_CANCHANGE , .F.) //bloqueia o campo
			
			if FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO $ "5") 
				oStruAux:RemoveField("N79_DTMULT")
				oStruAux:RemoveField("N79_TPCANC") 
				oStruAux:RemoveField("N79_CODMTV")
			else
				oStruN7C:RemoveField("N7C_QTDFIX")
				oStruN7C:RemoveField("N7C_VLRFIX")
			endif
			
			oStruAux:SetProperty("N79_QTDNGC",MVC_VIEW_CANCHANGE,.F.)					

			If (N79->N79_TIPO $ "2") //fixação e cancelamento
                AGRXSTPROP(oStruAux, "N79_TPCANC" , MVC_VIEW_CANCHANGE , .F.) //bloqueia o campo
                AGRXSTPROP(oStruAux, "N79_CODMTV" , MVC_VIEW_CANCHANGE , .F.) //bloqueia o campo
			endif
			
		else				
			oStruN79  := FWFormStruct( 2, "N79", { |x| ALLTRIM(x) $  'N79_CODENT,N79_LOJENT, N79_NOMENT, N79_NLJENT, N79_CODCTR, N79_DATA, N79_CODSAF, N79_CODPRO, N79_DESPRO, N79_SELCTR'}) //somente os campos necessários
			oStruAux  := FWFormStruct( 2, "N79", { |x| ALLTRIM(x) $  'N79_FIXAC, N79_QTDNGC'})

			If __lRegOpcional
				if N79->N79_TIPFIX == "1" 
					oStruAux:SetProperty("N79_FIXAC",MVC_VIEW_COMBOBOX,{'1=Preço'}) 
				Else
					oStruAux:SetProperty("N79_FIXAC",MVC_VIEW_COMBOBOX,{'2=Componente'}) 
				EndIf
			EndIf
		endif		
		
		//reset folders
		oStruN79:SetNoFolders(.t.) 
		oStruAux:SetNoFolders(.t.) 
		oStruN79:SetNoGroups(.t.) 
		oStruAux:SetNoGroups(.t.) 
		
        //bloqueia a edição dos campos
        aFields := Separa("N79_CODSAF;N79_CODENT;N79_LOJENT;N79_NOMENT;N79_NLJENT;N79_CODPRO", ";")
        For nI := 1 To Len(aFields)
            AGRXSTPROP(oStruN79, aFields[nI] , MVC_VIEW_CANCHANGE , .F.)
        Next nI

        aFields := Separa("N7A_DTLFIX;N7A_VMESAN;N7A_IDXNEG;N7A_IDXCTF;N7A_FILORG", ";")
        For nI := 1 To Len(aFields)
            AGRXSTPROP(oStruN7A, aFields[nI] , MVC_VIEW_CANCHANGE , .F.)
        Next nI
		
		//tratamento do campo de seleção de cadência
        AGRXSTPROP(oStruN7A, "N7A_USOFIX" , MVC_VIEW_CANCHANGE , .F.) //não deixamos alterar, colocamos evento dbclick
        AGRXSTPROP(oStruN7A, "N7A_USOFIX" , MVC_VIEW_WIDTH , 40) 
        AGRXSTPROP(oStruN7A, "N7A_USOFIX" , MVC_VIEW_TITULO , " ")  
        AGRXSTPROP(oStruN7A, "N7A_USOFIX" , MVC_VIEW_ORDEM , "01")  
	
		oView:CreateHorizontalBox( "TOP" , 12 )
		oView:CreateHorizontalBox( "MIDDLE" , 28 )
		oView:CreateHorizontalBox( "BOTTOM" , 60 )
		
		oView:CreateFolder( "FOLDERS", "BOTTOM")
		oView:AddSheet( "FOLDERS", "FOLDERN7C", STR0134 ) //"Componentes"
		oView:AddSheet( "FOLDERS", "FOLDERN79", STR0135 ) //"Dados Negócio"
		
		oView:CreateHorizontalBox( "BOX_N7C", 100, , , "FOLDERS", "FOLDERN7C" )
		oView:CreateHorizontalBox( "BOX_N79", 100, , , "FOLDERS", "FOLDERN79" )
	
		//add campos
		oView:AddField( "VIEW_N79", oStruN79,  "N79UNICO")
		oView:AddField( "VIEW_AUX", oStruAux,  "N79UNICO")
		oView:AddGrid( "VIEW_N7A" , oStruN7A,  "N7AUNICO")
		oView:AddGrid( "VIEW_N7C" , oStruN7C,  "N7CUNICO", {|oGridModel, cIDField, xValue| OGX700TLG(oModel, oGridModel, cIDField, xValue, "OGA700")})
		
		oView:SetOwnerView( "VIEW_AUX", "TOP" )	
		oView:SetOwnerView( "VIEW_N7A", "MIDDLE" )		
		oView:SetOwnerView( "VIEW_N7C", "BOX_N7C" )
		oView:SetOwnerView( "VIEW_N79", "BOX_N79" )
		
		oView:AddIncrementField( "VIEW_N7A", "N7A_CODCAD" )
		
		oView:SetViewProperty("VIEW_N7C", "ENABLENEWGRID")
	    oView:SetViewProperty("VIEW_N7C", "GRIDNOORDER")
	    oView:SetViewProperty("VIEW_N7A", "GRIDDOUBLECLICK", {{|oGrid,cFieldName,nLineGrid,nLineModel| SetMarkN7A(oGrid,cFieldName,nLineGrid,nLineModel)}}) 
	    oView:SetViewProperty("VIEW_N7C", "GRIDFILTER")
	    
	    oView:SetViewProperty( 'VIEW_N7A', "CHANGELINE", {{ |oView, cViewID| oView:GetViewObj("VIEW_N7C")[3]:obrowse:ExecuteFilter() }} )

	else

		oView:AddField('CALC', oCalcN7A,'OGA700CALC1') 
		
        AGRXSTPROP(oStruN79, "N79_USERNG" , MVC_VIEW_CANCHANGE , .F.)
		
		//verifica os campos que não poderam ser manutenidos no FIXAR
		if (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO $ "2|3|5" )  .or. FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF")
			
            aFields := Separa("N79_OPENGC;N79_CODSAF;N79_TIPFIX;N79_TPFRET;N79_CODENT;N79_LOJENT;N79_DESCTR;N79_CODOPE;N79_MODAL;N79_TABELA;N79_BOLSA", ";")
            For nI := 1 To Len(aFields)
                AGRXSTPROP(oStruN79, aFields[nI] , MVC_VIEW_CANCHANGE , .F.)
            Next nI

            aFields := Separa("N79_TIPMER;N7A_DTLFIX;N7A_ENTORI;N7A_LOJORI;N7A_ENTDES;N7A_LOJDES;N7A_DATFIM;N7A_DATINI;N7A_VMESAN;N7A_IDXNEG;N7A_IDXCTF;N7A_FILORG", ";")
            For nI := 1 To Len(aFields)
                AGRXSTPROP(oStruN7A, aFields[nI] , MVC_VIEW_CANCHANGE , .F.)
            Next nI
                    					
		else //não é processo de fixação + reset
			if !FWIsInCallStack("OGA700VISU") //se for diferente de  remove o campo de tipo de fixação
				oStruN79:RemoveField("N79_FIXAC") //grava conforme
			endif
			
			if !N79->N79_TIPO $ "2|5"
				oStruN7C:RemoveField("N7C_QTDFIX")
				oStruN7C:RemoveField("N7C_VLRFIX")
			endif			
		endif
		
		//tratamento cancelar
		if ((FWIsInCallStack("OGA700UPDT") .or.  FWIsInCallStack("OGA700VISU") ) .and. N79->N79_TIPO == "3") .or. FWIsInCallStack("OGA700CANC") //campos travados ao cancelar
            AGRXSTPROP(oStruN79, "N79_FIXAC" , MVC_VIEW_CANCHANGE , .F.)
			oStruN7C:RemoveField("N7C_QTDFIX")
			oStruN7C:RemoveField("N7C_VLRFIX")
		else //remove campos desnecessários 
			oStruN79:RemoveField("N79_NGCREL")
			oStruN79:RemoveField("N79_VRSREL")	
			oStruN79:RemoveField("N79_DTMULT")
			oStruN79:RemoveField("N79_TPCANC")			
			oStruN79:RemoveField("N79_CODMTV")
		endif
		oStruN79:RemoveField("N79_EMAILT")
			    
		If !lGodao
			oStruN7A:RemoveField("N7A_CODRES")
			oStruN7A:RemoveField("N7A_DTLTKP")
		Endif
	
		oView:CreateFolder( "MASTER") //Cria uma Folder superior para PRINCIPAL E PRECIFICAÇÃO
	
		oView:AddSheet('MASTER', 'PRINCIPAL',    STR0136) // #Principal
		oView:AddSheet('MASTER', 'PRECIFICACAO', STR0137) // #Precificação
	
		//layout Principal
		oView:CreateHorizontalBox( "TOP_PRINCIPAL"   , 100 , , , "MASTER", "PRINCIPAL") //Principal
	
		//layout precificação
		oView:CreateHorizontalBox( "TOP_PRECIFICACAO" , 30 , , , "MASTER", "PRECIFICACAO") //Cadências
		oView:CreateHorizontalBox( "BOT_PRECIFICACAO" , 55 , , , "MASTER", "PRECIFICACAO") //Principal
		oView:CreateHorizontalBox( "TOTALIZADORES" , 15 , , , "MASTER", "PRECIFICACAO") //Principal
	
		//add campos
		oView:AddField( "VIEW_N79", oStruN79,  "N79UNICO")
		oView:AddGrid( "VIEW_N7A" , oStruN7A,  "N7AUNICO")
		oView:AddGrid( "VIEW_N7C" , oStruN7C,  "N7CUNICO", {|oGridModel, cIDField, xValue| OGX700TLG(oModel, oGridModel, cIDField, xValue, "OGA700")})
	
		//seta propriedade
		oView:SetOwnerView( "VIEW_N79", "TOP_PRINCIPAL" )
		oView:SetOwnerView( "VIEW_N7A", "TOP_PRECIFICACAO" )
		oView:SetOwnerView( "VIEW_N7C", "BOT_PRECIFICACAO" )
		oView:SetOwnerView('CALC','TOTALIZADORES')
	
		oView:EnableTitleView( "VIEW_N79" )
		oView:EnableTitleView( "VIEW_N7A" )
		oView:EnableTitleView( "VIEW_N7C" )
	
		oView:AddIncrementField( "VIEW_N7A", "N7A_CODCAD" )
		
		oView:SetViewProperty("VIEW_N7C", "ENABLENEWGRID")
	    oView:SetViewProperty("VIEW_N7C", "GRIDNOORDER")
	    oView:SetViewProperty("VIEW_N7C", "GRIDFILTER")
	    
	    oView:SetViewProperty( 'VIEW_N7A', "CHANGELINE", {{ |oView, cViewID| OGA700CHG(oView, cViewID) }} )

		// Portos somente devem ser modificados quando for novo negpócio
		if lInsNew  .or. FWIsInCallStack("OGA700VISU") .or. (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO == "1" ) .or.; 
			(FWIsInCallStack("OGA700CPY") .and. N79->N79_TIPO == "1" ) 

			oView:AddSheet('MASTER', 'PORTOS'  , "Portos") // #Portos
			
			oView:CreateHorizontalBox( "TOP_PORTOS"   , 100 , , , "MASTER", "PORTOS") //Portos
			
			oView:AddGrid( "VIEW_N8S" , oStruN8S,  "N8SUNICO")
			
			oView:SetOwnerView( "VIEW_N8S", "TOP_PORTOS" )
			
			oView:EnableTitleView( "VIEW_N8S" )
			
			oView:AddIncrementField( "VIEW_N8S", "N8S_ITEM" )
			
			if lInsNew .or. FWIsInCallStack("OGA700CPY") //inclusao ou copia
				oView:SetViewAction( 'BUTTONCANCEL', {|oView|fCancRes(oView:GetModel())} )
			endif
	
		endif

	oView:SetViewCanActivate({|oView|fPreVIEW(oView)})

	endif

	oView:SetFieldAction( "N7A_IDXNEG",  { |oView| OGX700VUPV(oView) }  )
	oView:SetFieldAction( "N7C_VLRCOM",  { |oView| OGX700VUPV(oView) }  )
	oView:SetFieldAction( "N7C_TXCOTA",  { |oView| OGX700VUPV(oView) }  )
		
Return( oView )

/*/{Protheus.doc} fPreVIEW
pre validação da ativação da view
@type function
@version P12
@author claudineia.reinert
@since 07/03/2022
@param oView, object, objeto da view
/*/
Static function fPreVIEW(oView)
	Local lInsNew := fVldInsNew(oView:GetModel())
	Local cUmPrc := ""
	Local cUMPrd := ""
	Local lModeView := iif(FWIsInCallStack("OGA700MODF") .OR. FWIsInCallStack("OGA700CANC"), .T. , .F.)//abre em modo resumido

	//quando inclui chama o pergunte via OGA700VALT
	If lInsNew .AND. !FWIsInCallStack("AGRXCNGC") .AND. !OGA700VALT()
		return .f.
	EndIf
	
	If !lModeView
		If !FWIsInCallStack("AGRA720MVC")	
			If lInsNew
				cUMPrc := AgrUmPrc(MV_PAR02)	
				cUMPrd := POSICIONE('SB1',1,FwxFilial("SB1")+MV_PAR02,'B1_UM')	
			Else
				cUMPrc := AgrUmPrc(N79->N79_CODPRO)	
				cUMPrd := POSICIONE('SB1',1,FwxFilial("SB1")+N79->N79_CODPRO,'B1_UM')	
			EndIf

			If Empty(cUMPrc)
				cUMPrc := cUMPrd
			EndIf
		Endif
		//Ajusta titulo dos campos de totalizadores
		oView:GetViewStruct("OGA700CALC1"):SetProperty("N7A__TOT01", MVC_VIEW_TITULO, STR0211+cUMPrd)
		oView:GetViewStruct("OGA700CALC1"):SetProperty("N7A__TOT02", MVC_VIEW_TITULO, STR0212+cUMPrc)
	EndIf
			
Return .T.

/** {Protheus.doc} /** {Protheus.doc} ActivateMD
Função executada logo apos ativar o modelo de dados
@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@author:    Equipe Agroindustria
@since:     02/08/16
@Uso:       OGA280 - Contratos
@type function
*/
Static Function ActivateMD( oModel, nOperation )
	Local oModelN79 := oModel:GetModel( "N79UNICO" )
	Local cUser 	:= RetCodUsr()
	Local cNomUsu   := UsrRetName(cUser)
	Local cAliasQry := GetNextAlias()
	Local cQuery := ""
	Local lInsNew := fVldInsNew(oModel)

	LoadUmCpy(oModel)
    dbSelectArea("N79") //colocado devido alias() dentro da funcao UsrExist chamada pelo valid do campo N79_USERNG
	If nOperation == MODEL_OPERATION_INSERT 

		Pergunte('OGA70001', .F.)

			If TableInDic("N8U") .and. TableInDic("N8C") 

				cQuery := "SELECT count(N8U_CODBOL) AS NUMREG "
				cQuery += " FROM " + RETSQLNAME('N8U') + ' N8U '
				cQuery += " WHERE N8U.N8U_FILIAL = '"+ FWxFilial('N8U') + "'"
				cQuery += " AND N8U.D_E_L_E_T_ = ' ' "
				If !Empty(MV_PAR02)
					cQuery += " AND N8U.N8U_CODPRO = '"+MV_PAR02+ "'"
				endif

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
				dbSelectArea(cAliasQry)
				If (cAliasQry)->( !Eof() ) .AND. (cAliasQry)->(NUMREG) = 1
					cCodBol := GetDataSql("SELECT N8U_CODBOL FROM " + RetSqlName("N8U") +;
								 " WHERE N8U_FILIAL = '" + FwXFilial("N8U") + "' AND D_E_L_E_T_ = ' ' AND N8U_CODPRO = '"+MV_PAR02+ "'")
					oModelN79:SetValue("N79_BOLSA", cCodBol )
					oModelN79:LoadValue("N79_DBOLSA", POSICIONE('N8C',1,FwxFILIAL('N8C') + cCodBol , 'N8C_DESCR' )  )

				Endif
				(cAliasQry)->( dbCloseArea() )
				DbSelectArea("N79")
			EndIf
		
		if lInsNew .OR. FWIsInCallStack("AGRXCNGC")	
		
			If __lRegOpcional //se for contrato sem negócio
			
				FwFldPut( 'N79_CODPRO' 	, _cCodPro ) // Produto
				FwFldPut( 'N79_CODSAF' 	, _cCodSaf ) // Safra
				FwFldPut( 'N79_MOEDA' 	, _cMoedaCtr ) // Moeda	
				FwFldPut( 'N79_OPENGC' 	, _cTipoNgc ) // Tipo Operação compra/venda	
				
			Else
				If !Empty(MV_PAR01)
					FwFldPut( 'N79_CODSAF' 		, MV_PAR01 ) // Safra                    
				EndIf	
				If !Empty(MV_PAR02)
					FwFldPut( 'N79_CODPRO' 		, MV_PAR02 ) // Produto
				EndIf			
				If !Empty(MV_PAR04)
					If ValType(MV_PAR04) == "N"
						FwFldPut( 'N79_MOEDA' 		, MV_PAR04 ) // Moeda
					EndIf
				EndIf

				If VALTYPE(MV_PAR05) == "N" //proteção do sx1 - no dicionario esta como tipo caracter porem VALTYPE retorna como numerico 
					FwFldPut( 'N79_OPENGC' 		, cValToChar(MV_PAR05) ) // Tipo Operação compra/venda
				EndIf
					
			EndIf		

        EndIf
		
		oModel:SetValue("N79UNICO", "N79_VERSAO", "1" )

		If !__lRegOpcional		
			oModel:SetValue("N79UNICO", "N79_USERNG", cUser)
			oModel:SetValue("N79UNICO", "N79_NOMUSU", cNomUsu)
		EndIF

		if !FWIsInCallStack("OGA700CANC") .AND. __cAutoTest != "CANC" //não é cancelamento e rotina canc automação
			oModel:SetValue("N79UNICO", "N79_CODNGC", GETSXENUM('N79','N79_CODNGC')    )                                                                                                
		endif		
		if FWIsInCallStack("OGA700FIXA") .or. __cAutoTest $ "FIXA"  //ou rotina de função fixação ou rotina
			oModel:SetValue("N79UNICO", "N79_TIPO", "2" )  //fixação	
		
			if !OGA700FDNG(oModel, cFilNgcFix, cCodNgcFix, cCodVrsFix, cCodCadFix, "1" ) //busca os dados para monta a fixação
				return .f.
			endif
		elseif FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF") .or. __cAutoTest $ "CANC|MODF"  //função fixação ou rotina AUTOMAÇÃO 	
			
			if FWIsInCallStack("OGA700MODF") .or. __cAutoTest $ "MODF"
				oModel:SetValue("N79UNICO", "N79_TIPO", "5" )  //alteracao
			else
				oModel:SetValue("N79UNICO", "N79_TIPO", "3" )  //cancelamento
			endif
			
			oModel:SetValue("N79UNICO", "N79_VERSAO", alltrim(str(OGX700N79S(cFilNgcFix, cCodNgcFix) + 1)) ) //obtem conforme o ultimo registro
			oModel:SetValue("N79UNICO", "N79_NGCREL", cCodNgcFix )
			oModel:SetValue("N79UNICO", "N79_CODNGC", cCodNgcFix ) //registro conforme dados do negócio
			oModel:SetValue("N79UNICO", "N79_VRSREL", cCodVrsFix )
			
					
			if !OGA700FDNG(oModel, cFilNgcFix, cCodNgcFix, cCodVrsFix, cCodCadFix, iif(FWIsInCallStack("OGA700CANC") .or. __cAutoTest == "CANC" ,"2","3") ) //busca os dados para monta o cancelamento
				return .f.
			endif
			
			if FWIsInCallStack("OGC004CANQ")
				oModel:SetValue("N79UNICO", "N79_TPCANC", "2") //força para ser cancelamento
			endif
			
		else		
			oModel:SetValue("N79UNICO", "N79_TIPO", "1" )  //1=Novo;2=Fixacao;3=Cancelamento;4=Estorno Alteracao;5=Alteracao;6=Estorno Execucao;7=Mudanca Execucao
		endif
				
		if lInsNew ;
		 .OR. FWIsInCallStack("OGA290");
		 .OR. FWIsInCallStack("OGA280");
		 .OR. (Type("_lOGA700CP") == "L" .AND. _lOGA700CP)
		    PrecifComp(oModel) 
		endif	

	Else
		If !(nOperation == 5)
			cUser 	  := M->N79_USERNG
			cNomUsu   := UsrRetName(cUser)
			oModel:LoadValue("N79UNICO", "N79_NOMUSU", cNomUsu)
		EndIf
	EndIf
	
	//bloqueia as cadências no cancel e fixar
	if FWIsInCallStack("OGA700CANC") .or.  FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700MODF")  .or.  (FWIsInCallStack("OGA700UPDT") .and. oModel:GetValue("N79UNICO", "N79_TIPO") $ "2|3|5" )
		oModel:GetModel( "N7AUNICO" ):SetNoDelete( .t. )
		oModel:GetModel( "N7AUNICO" ):SetNoInsert( .t. )
	endif
		
Return( .t. )

/*/{Protheus.doc} PreValN79()
	(long_description)
	@type  Static Function
	@author mauricio.joao
	@since 17/02/2020
	@version 1.0
	/*/
Static Function PreValN79(oFieldModel, cAction, cIDField, xValue)
	Local lRet := .T.

	//proteção do parametro novo
	If VALTYPE(MV_PAR05) == "N" 
		//bloqueio do campo de tipo de operação do negócio.
		If cAction == "CANSETVALUE"  .and. cIDField == "N79_OPENGC"
			 lRet := .F. 
		EndIf
	EndIf

Return lRet
/** {Protheus.doc} AlteraStru
Função que altera propriedades da estrutura de uma View

@param:     oStru: Estrutura de dados
            cTpAlt: 1 - Remove
            		2 - SetProperty - MVC_VIEW_WIDTH
            		3 - SetProperty - MVC_VIEW_ORDEM
@return:    oStru: Estrutura de dados
@author:    Equipe Agroindustria
@since:     05/02/2018
@Uso:       OGA700 - Negócios
*/
Static Function AlteraStru(oStru, nProperty, cCampo, xConteudo)


	if oStru:HasField( cCampo )
		if nProperty = 0
			oStru:RemoveField( cCampo )
		else
	 		oStru:SetProperty( cCampo, nProperty, xConteudo )
		endif
	endif

Return oStru

/** {Protheus.doc} VldActveMd
Função que valida o modelo de dados antes da ativação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2017
@Uso:       OGA700 - Negócios
*/
Static Function VldActveMd( oModel )
	Local lRetorno      := .t.
	Local nOperation    := oModel:GetOperation()
	Local cStatus       := N79->( N79_STATUS )

	if nOperation == MODEL_OPERATION_DELETE .AND. !__lRegOpcional

		If cStatus != "1"
			Help( ,,STR0031,, STR0002, 1, 0 ) //"Ajuda"#"A Opção de Exluir é somente para negócios com status 'Pendente'"
			lRetorno := .f.
		EndIf
	ElseIf nOperation == MODEL_OPERATION_INSERT 
		If !__lnewNeg
			Help( ,, STR0031,,STR0073, 1, 0 )  //"AJUDA",,"Seu sistema não está configurado para utilizar o conceito de comercialização através de novos negócios. favor utilizar as rotinas de contratos para registrar um negócio."
			lRetorno := .f.
		EndIf	
	EndIf

Return( lRetorno )

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos de Venda
*/
Static Function PosModelo( oModel )
	Local lContinua     := .T.
	Local oModelN79     := oModel:GetModel( "N79UNICO" )
	Local oModelN7A     := oModel:GetModel( "N7AUNICO" )
	Local oModelN7C     := oModel:GetModel( "N7CUNICO" )
	Local dQtdCaden     := 0
	Local iCont         := 0
	Local nX            := 0
	Local lCadSelec     := .f. //Possui cadencia selecionada
	Local aSaveLines  	:= FWSaveRows()	
	Local nSldCan       := 0
	Local nQtdEnt       := 0
	Local lFilorg       := .F.
	Local lvalida       := .T.
	Local lFindPV       := .F.
	Local lModeView     := iif(FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF")  .or. (FWIsInCallStack("OGA700UPDT") .and. N79->N79_TIPO $ "2|3|5") , SuperGetMv("MV_AGRO007",,.T.) , .F.)//abre em modo resumido
	Local cGrupo        := '' 
	Local cMesano       := '' 
	Local nQtdNeg       := 0
	Local nN7A          := 0
	Local lBolsaInd     := .F.
		
	For nN7A := 1 To oModelN7A:Length()
		oModelN7A:Goline(nN7A)
		If !oModelN7A:IsDeleted()
			nQtdNeg += oModelN7A:GetValue("N7A_QTDINT")
		Endif
	Next

	oModelN79:SetValue("N79_QTDNGC", nQtdNeg)

	//valida a quantidade da negociação
	if !(oModel:GetValue("N79UNICO", "N79_TIPO") $ "2|3|5" .and.  oModel:GetValue("N79UNICO", "N79_FIXAC") == "2") .and. oModel:GetValue("N79UNICO", "N79_TPCANC") == "1"  //diferente de Fixação e Componente
		If Empty(oModelN79:GetValue("N79_QTDNGC")) .or. oModelN79:GetValue("N79_QTDNGC") <= 0 // Se não foi informado o valor
			Help( , , STR0031, , STR0032, 1, 0, ,,,,,{STR0033} ) // # Campo (Valor Total) não informado. "A quantidade da Negociação não foi informada." "Por favor, informe a quantidade da negociação."
			Return .F.
		EndIf
	endif

	//Valida tipo de fixação
	if oModel:GetValue("N79UNICO", "N79_TIPFIX") == "1" .and. oModel:GetValue("N79UNICO", "N79_FIXAC") == "1" .AND. oModel:GetValue("N79UNICO", "N79_TIPO") != "1" .and. oModel:GetValue("N79UNICO", "N79_TPCANC") == '1' //Fixo - Preço
		If Empty(oModelN79:GetValue("N79_VALOR")) .or. oModelN79:GetValue("N79_VALOR") < 0 // Se não foi informado o valor
			Help( , , STR0031, , STR0034, 1, 0,,,,,,{STR0035} ) // # Campo (Valor Total) não informado. "Para negócios fixos o valor do negócio deve ser informado. Por favor, verifique os componente de resultado de Preço Negociado."
			Return .F.
		EndIf
	endif
	
	if !Empty(oModelN79:GetValue("N79_BOLSA")) 
		dbSelectArea('N8C') // Seleciona o alias para atualizar o que esteja sendo manipulado e alterado na NJR, para fazer o posicione
		if Posicione("N8C",1,FwXFilial("N8C") + oModelN79:GetValue("N79_BOLSA"), "N8C_PRCBOL") == '2' .AND. oModelN79:GetValue("N79_TIPFIX") = '1'
			Help( , 1 ,".OGA700000002.") //A Bolsa Ref. selecionada possui preço relacionado à índice e não à fixação.
			N8C->(dbCloseArea())
			Return .F.
		endif
	endif
	
	If !FWIsInCallStack("OGA700FIXA") .and. !FWIsInCallStack("OGA700CANC")
		If !OGA700ENTI()
			Return .F.
		EndIf
	Endif
	
	//validações relativas a cadência
	For iCont := 1 to oModelN7A:Length()
		oModelN7A:GoLine( iCont )
		if !oModelN7A:IsDeleted() .AND. lContinua 
		
			If Empty(oModelN7A:GetValue( "N7A_DATFIM" ))
				Help( , , STR0031, , STR0203, 1, 0,,,,,,{STR0036} ) //"Data Final da Previsão de Entrega deve ser informada."  Cadastrar mensagem
				lContinua := .F. 
			EndIf

			If oModel:GetValue("N79UNICO", "N79_TIPFIX") == "2" .AND.;
			   !OGX700CFUT(oModel,oModelN7A:GetValue("N7A_CODCAD",iCont))
			   lContinua := .F.
			EndIf

			//A fixar - deve preencher data Limite de Fixacao
			If oModel:GetValue("N79UNICO", "N79_TIPO") == "1" .And. oModel:GetValue("N79UNICO", "N79_TIPFIX") == "2" 
			
				If !Empty(oModelN79:GetValue("N79_BOLSA"))  
					lBolsaInd := IIF(Posicione("N8C",1,FwXFilial("N8C") + oModelN79:GetValue("N79_BOLSA"), "N8C_PRCBOL") == '2', .t.,.f.) 
					//Se o preço da bolsa for por índice não deve validar a data de fixação
				Endif		    
				If Empty(oModelN7A:GetValue( "N7A_DTLFIX" )) .And. !lBolsaInd				
					//"O Campo 'Tipo de Preco' foi preenchido como 'A fixar' e a 'Data de Limite de Fixacao' esta vazia."
					//"Favor preencher a 'Data de Limite de Fixacao' na aba 'Precificacao'." 
					Help( , , STR0079, , STR0204, 1, 0,,,,,,{STR0205} )
					oModelN7A:GoLine(1)
					Return .F.
				EndIf 
			EndIf
		
			if oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" //sem delete e marcado para fixar
				
				lCadSelec := .t. //informa que temos cadencia selecionada
				
				If !Empty(oModelN7A:GetValue( "N7A_DATFIM" ))
					If oModelN7A:GetValue( "N7A_DATFIM" ) <  oModelN7A:GetValue( "N7A_DATINI" )
					 	Help( , , STR0031, , STR0003, 1, 0,,,,,,{STR0036} ) //"Data limite da cadência deve ser maior que a data inicial da cadencia"
					 	lContinua := .F. 
					EndIf 
				EndIf
				
				//fixação
				if oModel:GetValue("N79UNICO", "N79_TIPO") == "2"  //fixação
					if (oModelN7A:GetValue("N7A_QTDINT") >  OGX700QLMT(oModelN79:GetValue("N79_FILIAL"), oModelN79:GetValue("N79_CODCTR"), oModelN7A:GetValue("N7A_CODCAD"), oModelN79:GetValue("N79_CODNGC"), oModelN79:GetValue("N79_VERSAO")))
						Help( , , STR0031, , STR0004, 1, 0,,,,,,{STR0036} ) //"Data final da fixação deve ser menor que a data final da cadência" "Por favor, verifique os dados informados." 
						lContinua := .F. 
					endif
				Elseif oModel:GetValue("N79UNICO", "N79_TIPO") == "1"   //novo
					
					If Empty(oModelN7A:GetValue( "N7A_QTDINT" )) .or. oModelN7A:GetValue( "N7A_QTDINT" ) = 0  
						Help( , , STR0031, , STR0138, 1, 0,,,,,,{STR0036} ) //"Quantidade da negociação na previsão de entrega não foi informada."#"Por favor, verifique os dados informados." 
						lContinua := .F.					
					Endif
					
					//verifica se para negócios à fixar existem indices
					If oModel:GetValue("N79UNICO", "N79_TIPFIX") == "2" .and.  Empty(oModelN7A:GetValue( "N7A_IDXNEG" )) 
						Help( , , STR0031, , STR0167, 1, 0,,,,,,{STR0036} ) //"Para negócios à fixar, o índice de negócio é obrigatório."#"Por favor, verifique os dados informados." 
						lContinua := .F.					
					Endif
					
				EndIf
				
				//se for cancelamento, válida se o negócio tem a quantidade apropriada
			    if oModel:GetValue("N79UNICO", "N79_TIPO") $ "3|5"  //cancelamento
			    	//quantidade
			    	if oModel:GetValue("N79UNICO", "N79_TPCANC") == '2' .and. (Empty(oModelN7A:GetValue("N7A_QTDINT")) .or. oModelN7A:GetValue("N7A_QTDINT") == 0)  
			    		Help( , , STR0031, , STR0138, 1, 0,,,,,,{STR0036} ) //"Quantidade da negociação na previsão de entrega não foi informada."#"Por favor, verifique os dados informados." 
			    		lContinua := .F.					
			    	endif	
			    		
			    	if oModel:GetValue("N79UNICO", "N79_FIXAC") == "1" .and. (oModel:GetValue("N79UNICO", "N79_TPCANC") == "1" .or. oModel:GetValue("N79UNICO", "N79_TIPO") == "5" ) //cancelamento e preço
				    	nQtdEnt := OGX700SLDP(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_NGCREL"), oModelN79:GetValue("N79_VRSREL") ,oModelN7A:GetValue("N7A_CODCAD"))
				    	if oModelN7A:GetValue("N7A_QTDINT") > nQtdEnt
				    		Help( , , STR0031, , STR0037 + CRLF + STR0028+ " "+cValTochar(nQtdEnt)+ CRLF+STR0029+" "+cValToChar(oModelN7A:GetValue("N7A_QTDINT")), 1, 0,,,,,,{STR0038} ) // "Quantidade a ser cancelada da Previsão de Entrega excede a quantidade da disponível." "Quantidade disponível para cancelamento: Quantidade informada:" Devido haver quantidades entregues, por favor informe quantidades dentro das disponíveis para cancelamento." 
				    		lContinua := .F.  //não precisa validar o resto		
				    	endif
				    	nSldCan := Round(OGX700SLCA(oModelN79:GetValue("N79_NGCREL"), oModelN79:GetValue("N79_VRSREL") ,oModelN7A:GetValue("N7A_CODCAD")),0)		    	
				    	if oModelN7A:GetValue("N7A_QTDINT") >  nSldCan //erro
				    		Help( , , STR0031, , STR0027 + CRLF + STR0028 + " " + cValTochar(nSldCan)+ CRLF+STR0029 + " " + cValToChar(oModelN7A:GetValue("N7A_QTDINT")), 1, 0, .F., , ,,,{STR0030}) //A quantidade informada é superior ao limite disponível.  Quantidade disponível para cancelamento: Quantidade informada: Por favor, verifique as quantidades vínculadas à fixação. 
				    		lContinua := .F. //não precisa validar o resto		
				    	endif
				    endif
			    endif
			    
			    //verifica se o indice utilizado está de acordo com a bolsa
			    if !Empty(oModelN79:GetValue("N79_BOLSA")) 
			    	if !Empty(oModelN7A:GetValue("N7A_IDXNEG")) .and. POSICIONE('NK0',1,XFILIAL('NK0')+oModelN7A:GetValue("N7A_IDXNEG"),'NK0_CODBOL') <> oModelN79:GetValue("N79_BOLSA")
			    		Help( , , STR0031, , STR0138, 1, 0, .F., , ,,,{STR0139}) //"Ajuda"#"O indíce de negócio é inválido para a bolsa da negociação."#"Selecione um indíce compatível com a bolsa de referência"   Deve-se ter ao menos uma previsão de entrega com a filial de origem informada no negócio. Por favor, verifique na pasta Principal a filial de origem informada e revise as filiais de origem informadas nas previsões de entrega. 
			    		lContinua := .F. //não precisa validar o resto
			    	endif
			    	if !Empty(oModelN7A:GetValue("N7A_IDXCTF")) .and. POSICIONE('NK0',1,XFILIAL('NK0')+oModelN7A:GetValue("N7A_IDXCTF"),'NK0_CODBOL') <> oModelN79:GetValue("N79_BOLSA")
			    		Help( , , STR0031, , STR0140, 1, 0, .F., , ,,,{STR0139}) //"Ajuda"#"O indíce de contratos futuros é inválido para a bolsa da negociação."#"O indíce de contratos futuros é inválido para a bolsa da negociação."   Deve-se ter ao menos uma previsão de entrega com a filial de origem informada no negócio. Por favor, verifique na pasta Principal a filial de origem informada e revise as filiais de origem informadas nas previsões de entrega. 
			    		lContinua := .F. //não precisa validar o resto
			    	endif
			    endif
			    
			    /* Comentado, pois será tratado posteriormente. Campo ficará na N79.
			    // Se o produto é diferente de algodão valida a obrigatoriedade da filial da cadência			    
			    If  oModel:GetValue("N79UNICO", "N79_TIPO") != "1" 
			    	If Empty(oModelN7A:GetValue('N7A_FILORG', iCont))
			    		Help( , , STR0031, , STR0039, 1, 0,,,,,,{STR0040}) //"AJUDA"###" "Filial da Previsão de Entrega não foi informada para o produto selecionado." "Por favor, informe a filial da Previsão de Entrega."
			    		lContinua := .F. 
			    	EndIf
				EndIf
				*/
				
				If  !(oModelN7A:IsInserted(iCont) .and. !oModelN7A:IsUpdated(iCont))
					If oModelN79:GetValue( "N79_FILORG" ) == oModelN7A:GetValue( "N7A_FILORG" ) 
						lFilorg := .T.   // ao menos precisa ter um filorg igual
					EndIf
					//Emitir alerta caso quantidade caso ultrapasse a quantidade planejada plano de venda
					If lValida .and.  !FWIsInCallStack("OGA700FIXA") .and. !FWIsInCallStack("OGA700CANC") .and. !FWIsInCallStack("OGA700MODF")  .and. N79->N79_TIPO $ "1"
						lFindPV := .F.
						cGrupo  := Posicione('SB1', 1, xFilial('SB1') + oModelN79:GetValue( "N79_CODPRO" ), 'B1_GRUPO')
						cMesano := AllTrim(StrZero (Month(oModelN7A:GetValue("N7A_DATFIM")),2)) + "/" + AllTrim(Str(Year(oModelN7A:GetValue("N7A_DATFIM"))))
						nVlVenPV := OGA700PV( oModelN79:GetValue( "N79_FILORG" ), oModelN79:GetValue( "N79_CODSAF" ), cGrupo, oModelN79:GetValue( "N79_CODPRO" ), cMesano, @lFindPV)
	                    IF lFindPV .and. nVlVenPV - oModelN7A:GetValue("N7A_QTDINT") < 0 					                     					
							lvalida  := .F.        
					    EndIF
				    EndIF
				EndIf
				
				If iCont == oModelN7A:Length() .And. !lFilorg
					Help( , , STR0031, , STR0089, 1, 0, .F., , ,,,{STR0090}) //Deve-se ter ao menos uma previsão de entrega com a filial de origem informada no negócio. Por favor, verifique na pasta Principal a filial de origem informada e revise as filiais de origem informadas nas previsões de entrega. 
			    	lContinua := .F. //não precisa validar o resto
				EndIf
				
				//validação de reserva selecionada
				if lContinua .and. oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. oModel:GetValue("N79UNICO", "N79_TIPO") == "1" //novo negócio
				  	
				 	if !fValidResv(oModel) //valida a reserva selecionada
				 		lContinua := .f.
				 	endif
					
				endif				
				
				dQtdCaden += oModelN7A:GetValue("N7A_QTDINT")
				
			endif	
		endif	
	next iCont	

	If __lCtrRisco
		For iCont := 1 To oModelN7A:Length()
			oModelN7A:GoLine(iCont)
			If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue("N7A_USOFIX") != "LBNO"
				For nX := 1 to oModelN7C:Length()
					oModelN7C:GoLine(nX)
					If oModelN7C:GetValue("N7C_HEDGE") == "1"
						If !FwIsInCallStack("OGWSPUTFIX") //ignora quando vem do fluig
							If !((oModelN7C:GetValue("N7C_QTDCTR") - INT( oModelN7C:GetValue("N7C_QTDCTR") ) ) = 0 )
								lContinua := .F.
								//"A quantidade do Contrato Futuro deve ser um número inteiro."
								//oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0188, STR0151, "", "")
								Help( , , STR0031, , STR0188, 1, 0,,,,,,{STR0151} ) //"AJUDA # A quantidade do Contrato Futuro deve ser um número inteiro."#"Informe uma quantidade válida."
								exit
							EndIf
						EndIf
                        
                        If oModelN7C:GetValue("N7C_QTDCTR") > 0  .AND. Empty(oModelN7C:GetValue("N7C_CODBCO"))
                            AgrHelp(STR0031,STR0254 +  chr(10) + chr(10) + STR0064 + ": "+ oModelN7A:GetValue("N7A_CODCAD") + chr(10) + STR0134 + ": " + oModelN7C:GetValue("N7C_DESCRI"),STR0255)   //"Código do banco não foi informado para o componente com hedge." //"Por favor informe o código do banco no componente de preço."
                            lContinua := .F.
                            exit
                        EndIf 

                        If oModelN7C:GetValue("N7C_QTDCTR") > 0 .and. oModelN79:GetValue("N79_OPENGC") == "1" .and. !oModelN7C:GetValue("N7C_OPEFIX")  $ "2|3"
                            AgrHelp(STR0031,STR0251,STR0252)    //"O tipo de operação está incorreto." "Para negociação de compra informe o tipo de operação Venda ou Liquidação."
                            lContinua := .F.
                            exit
                        ElseIf oModelN7C:GetValue("N7C_QTDCTR") > 0 .and. oModelN79:GetValue("N79_OPENGC")  == "2" .and. !oModelN7C:GetValue("N7C_OPEFIX") $ "1|3"
                            AgrHelp(STR0031,STR0251,STR0253)   //"O tipo de operação está incorreto." "Para negociação de venda informe o tipo de operação Compra ou Liquidação."
                            lContinua := .F.
                            exit
                        EndIf
					EndIf
				Next nX
			EndIf
		Next iCont
	EndIf

	//validar volume da cadencia e plano vendas
	 IF !lvalida  
	    Help( , , STR0031, , STR0208 + AllTrim(oModelN79:GetValue( "N79_CODPRO" )) + ',' + STR0209 + AllTrim(oModelN79:GetValue( "N79_CODSAF" )) + ',' + STR0210 + AllTrim(oModelN79:GetValue( "N79_FILORG" )) + ' ' + STR0207 +  ' :  ' + cMesano + ' ' + STR0206 + ' ( ' + cValToChar(nVlVenPV)  + ")", 1, 0, .F., , ,,,) //"O Produto : xxx , Safra: xxx , unidade de negocio: xxx para o periodo 99/9999 ultrapassou o saldo total a vender (99,99)
		lContinua := .F.
	EndIF                                                      
       

	//minimo 1 cadencia
	if lContinua
		IF !lCadSelec
			Help( , , STR0031, , STR0041, 1, 0,,,,,,{STR0042} ) //"AJUDA"###" "Nenhuma Previsão de Entrega foi selecionada." "Por favor, informe uma Previsão de Entrega."   
			lContinua := .F.
		elseif dQtdCaden <> oModelN79:GetValue("N79_QTDNGC") .and. oModelN79:GetValue("N79_TPCANC") == '1' 
			Help( , , STR0031, , STR0007, 1, 0,,,,,,{STR0043} ) //"AJUDA"###" //"A quantidade total das Previsões de Entrega estão em disconformidade com a quantidade do negócio."    "Por favor, verifique a quantidade informada nas Previsões de Entrega."
			lContinua := .F.
		EndIf
	endif
	
	//VALIDA OS COMPONENTES DA NEGOCIAÇÃO
	if lContinua
		lContinua := fVldCompon(oModel)
		
		If __lViewAGRA060
			OGA700ACO(oModel, oModelN7C, oModelN7A) //Qdo houve cadastro de Conv. UM. deve atualizar os valores
		EndIf
	endif
	
	//validação da modalidade
	if lContinua .AND. !lModeView
		if !Empty(oModelN79:GetValue("N79_MODAL")) .and. oModelN79:GetValue("N79_TIPO") == "1" //Novo negócio
			dbSelectArea('NK5') // Seleciona o alias para atualizar o que esteja sendo manipulado e alterado na NJR, para fazer o posicione
			cTipFix:= Posicione("NK5",1,FwXFilial("NK5") + oModelN79:GetValue("N79_MODAL"), "NK5_TIPFIX")
			cTIpMer:= Posicione("NK5",1,FwXFilial("NK5") + oModelN79:GetValue("N79_MODAL"), "NK5_TIPMER")
			NK5->(dbCloseArea())			
			If (cTipFix != '3' .and. cTipFix != oModelN79:GetValue("N79_TIPFIX")) .or. (cTipMer != '3' .and. cTipMer != oModelN79:GetValue("N79_TIPMER"))   
				Help( , 1 ,".OGA700000001.") //O tipo de preço e/ou tipo de mercado devem estar de acordo com a modalidade informada.
				lContinua := .F.
			endif
		endif
	endif
	
	//validação relativa ao cancelamento
	if lContinua .and. oModelN79:GetValue("N79_TPCANC") = '2' //quantidade
		if Empty(oModelN79:GetValue("N79_CODMTV"))
			Help( , , STR0031, , STR0141, 1, 0, .F., , ,,,{STR0142}) //"Ajuda"#"O código do motivo da alteração é obrigatório ao cancelar quantidade."#"Informe um motivo de alteração."    O código do motivo da alteração é obrigatório ao cancelar quantidade.
			lContinua := .F.
		else
			if Posicione("NNQ",1, FwXFilial("NNQ")+oModelN79:GetValue("N79_CODMTV"), "NNQ_TIPO") = '1' //aditação
				Help( , , STR0031, , STR0143, 1, 0, .F., , ,,,{STR0144}) //"Ajuda"#"Código do motivo de alteração selecionado não é um código de supressão."#"Informe um motivo de alteração de supressão."    O código do motivo da alteração é obrigatório ao cancelar quantidade.
				lContinua := .F.
			endif			
		endif
	endif 

	//Validação Mercado x Cliente 
	If lContinua 
		if oModelN79:GetValue("N79_TIPMER") = '2' .AND. oModelN79:GetValue("N79_UF") != "EX"
			Help( , , STR0031, , STR0243, 1, 0, ,,,,,{STR0244} )
			lContinua := .F.
		elseIf oModelN79:GetValue("N79_TIPMER") = '1' .AND. oModelN79:GetValue("N79_UF") = "EX"
			Help( , , STR0031, , STR0245, 1, 0, ,,,,,{STR0244} )
			lContinua := .F.
		endif
	Endif 

	AtuStatus()

	FWRestRows(aSaveLines)	
	
Return(lContinua)

/*{Protheus.doc} fVldCompon
//Valida os componentes da negociação
@author jean.schulze
@since 10/11/2017
@version undefined
@param oModel, object, descricao
@type function
*/
static function fVldCompon(oModel)
	Local oModelN79     := oModel:GetModel( "N79UNICO" )
	Local oModelN7A     := oModel:GetModel( "N7AUNICO" )
	Local oModelN7C     := oModel:GetModel( "N7CUNICO" )
	Local cMoedactr     := oModel:GetValue( "N79UNICO","N79_MOEDA"  )
	Local cUMPreco      := oModel:GetValue( "N79UNICO","N79_UMPRC"  )
	Local cUMProd       := oModel:GetValue( "N79UNICO","N79_UM1PRO" )
	Local cTipo         := oModel:GetValue( "N79UNICO","N79_TIPO"   ) 
	Local nX            := 0
	Local nC	        := 0
	Local nQtdOrgCad    := 0   //quantidade original da cadencia
	Local lCompInfo     := .f. //Possui cadencia selecionada
	Local lBolsaInd     := .f.
    Local aAreaNk7      := {}
    Local aTipsMult     := {}
    Local cProblema     := ''
    Local cSolucao      := ''
	
	if !Empty(oModelN79:GetValue("N79_BOLSA")) 
		lBolsaInd := IIF(Posicione("N8C",1,FwXFilial("N8C") + oModelN79:GetValue("N79_BOLSA"), "N8C_PRCBOL") == '2', .t.,.f.) 
	endif
	
	__lViewAGRA060 := .F.
	
	nX := 1
	//valida alguns campos do cabeçalho X cadencia X componente
	while nX <= oModelN7A:Length()
		oModelN7A:GoLine( nX )
		if !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO"
		
			if cTipo == "2" 
		    	nQtdOrgCad := Posicione("NNY",1, oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_CODCTR")+oModelN7A:GetValue("N7A_CODCAD"), "NNY_QTDINT") //atribui a quantidade total da cadencia
		    endif
		    
		    lCompInfo := .f. //reset
		    
		    //busca os componentes já cadastrados
			For nC := 1 to oModelN7C:Length()
			    oModelN7C:GoLine( nC )

				If oModelN7A:GetValue("N7A_USOFIX") == "LBOK" .AND.;
				   !Empty(oModelN7A:GetValue("N7A_QTDINT")) .AND.;
				   Empty(oModelN7C:GetValue("N7C_VLRCOM")) .AND.;
				   oModelN7C:GetValue("N7C_TPPREC") = '2' .AND.;
				   cTipo == "2"
				   cProblema := AllTrim(RetTitSx3("N7C_VLRCOM")) + STR0096 //" não foi informado!"
				   cSolucao  := STR0097 + "'" + AllTrim(RetTitSx3("N7C_VLRCOM")) + "'" + STR0098 + oModelN7A:GetValue("N7A_CODCAD") + "." //"Preencher a coluna " ### " da cadência " 
				   Help( , , STR0031, , cProblema, 1, 0,,,,,,{cSolucao} )
				   Return .F.
				EndIf
			    
			    //verificar se está realizando alguma operação
			    if !lCompInfo .and. oModelN7C:GetValue("N7C_QTAFIX") > 0 
			    	lCompInfo := .t. //está fixando algum componente
			    endif			    
			    
		    	If fVldInsNew(oModel) .Or. FWIsInCallStack("OGA700UPDT") .Or. FWIsInCallStack("OGA700FIXA") .or. __cAutoTest $ "INSR|UPDT|FIXA"
			    	If oModelN7C:GetValue("N7C_UMCOM") != cUMPreco
				    	While .T.
					    	If !OGX700CVUM(oModelN7C:GetValue("N7C_UMCOM"), cUMPreco)
					    	    If MsgYesNo(STR0044 + Alltrim(oModelN7C:GetValue("N7C_UMCOM")) + STR0045 + Alltrim(cUMPreco) + STR0046 + Alltrim(oModelN7C:GetValue("N7C_DESCRI"))+"." + Chr(10) + Chr(13) + STR0047 ) //O fator de conversão de unidade de medida de <> para <> não foi encontrado para o componente <>. Deseja Cadastrar? 				    		
					    	    	FWExecView('', 'VIEWDEF.AGRA060', MODEL_OPERATION_INSERT, , {|| .T. })
					    	    	__lViewAGRA060 := .T.				    	    					    	    					    	    					    	    	
					    		Else
					    			Help( , , STR0031, , STR0044 + Alltrim(oModelN7C:GetValue("N7C_UMCOM")) + STR0045 + Alltrim(cUMPreco) + STR0046 +Alltrim(oModelN7C:GetValue("N7C_DESCRI"))+".", 1, 0,,,,,,{STR0048} ) //O fator de conversão de unidade de medida de <> para <> não foi encontrado para o componente <>. Por favor, realize o cadastro de conversão para as unidades de medida informadas.
					    			Return .F.
					    		EndIf
					    	Else
					    		If __lViewAGRA060					    	    
						    	    Help( , , STR0031, , STR0049, 1, 0,,,,,,{STR0050} ) ////"Os valores fixados foram atualizados devido ao cadastro do fator de conversão entre as unidades de medida." "Por favor, verifique os novos valores."
						    	    Return .F. //Retorna para poder atualizar o model N7C quando houve cadastro de CONV. UM
						    	Else
						    		exit
						    	EndIf
					    	EndIf				    	
					    EndDo
				    EndIf
				    
				    If oModelN7C:GetValue("N7C_UMCOM") != cUMProd
				    	While .T.
					    	If !OGX700CVUM(oModelN7C:GetValue("N7C_UMCOM"), cUMProd)
					    	    If MsgYesNo(STR0044 + Alltrim(oModelN7C:GetValue("N7C_UMCOM")) + STR0045 + Alltrim(cUMProd) + STR0046 + Alltrim(oModelN7C:GetValue("N7C_DESCRI"))+"." + Chr(10) + Chr(13) + STR0047 ) //O fator de conversão de unidade de medida de <> para <> não foi encontrado para o componente <>. Deseja Cadastrar?
					    	    	FWExecView('', 'VIEWDEF.AGRA060', MODEL_OPERATION_INSERT, , {|| .T. }) 
					    	    	__lViewAGRA060 := .T.				    	    					    	    	
					    		Else
					    			Help( , , STR0031, , STR0044 + Alltrim(oModelN7C:GetValue("N7C_UMCOM")) + STR0045 + Alltrim(cUMProd) + STR0046 + Alltrim(oModelN7C:GetValue("N7C_DESCRI"))+".", 1, 0,,,,,,{STR0048} ) //O fator de conversão de unidade de medida de <> para <> não foi encontrado para o componente <>. Por favor, realize o cadastro de conversão para as unidades de medida informadas.
					    			Return .F.
					    		EndIf
					    	Else
					    		If __lViewAGRA060
					    	    	Help( , , STR0031, , STR0049, 1, 0,,,,,,{STR0050} ) ////"Os valores fixados foram atualizados devido ao cadastro do fator de conversão entre as unidades de medida." "Por favor, verifique os novos valores."
					    	    	Return .F. //Retorna para poder atualizar o model N7C quando houve cadastro de CONV. UM
					    		Else
					    			exit
					    		EndIf
					    	EndIf
					    EndDo 
				    EndIf
				EndIf
			    
			    If oModelN7C:GetValue("N7C_QTAFIX") > 0
				    If oModelN7C:GetValue("N7C_MOEDCO") != cMoedactr
				    	If oModelN7C:GetValue("N7C_TXCOTA") <= 0				    		
				    		Help( , , STR0031, , STR0051 + Alltrim(oModelN7C:GetValue("N7C_DESCRI")) + ".", 1, 0,,,,,,{STR0052} ) // "Não foi informada cotação da moeda para o componente <>. "Por favor, informe a cotação."           
				    		Return .F.
				    	EndIf 
				    EndIf		    
				EndIf
			    
			    //valida as regras de componente -  verificar o que retornou tbm da função ogx700 - itens que n
			    if !oModelN7C:IsDeleted() .and. !empty(oModelN7C:GetValue("N7C_REGRA")) //existe regra de aplicação
			    	//verifica se a regra está ainda atendida
			    	if !OGX700CKRG(oModelN7C:GetValue("N7C_REGRA"), oModelN79)
			    		Help( , , STR0031, , STR0008, 1, 0 ) //"AJUDA"###""Existem componentes com regras não contempladas. Precifique novamente o produto."
			    		return .f. //não precisa validar o resto
			    	endif
			    endif
			    
			     //se for fixação valida a quantidade já fixada para o componente/cadencia
			    if oModel:GetValue("N79UNICO", "N79_TIPO") == "2" 
			    	if oModelN7C:GetValue("N7C_QTAFIX") +  OGX700QN7M(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_CODCTR"),oModelN7A:GetValue("N7A_CODCAD"), oModelN7C:GetValue("N7C_CODCOM")) + ;
					   OGX700CBLQ(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_CODCTR"),oModelN7A:GetValue("N7A_CODCAD"), oModelN7C:GetValue("N7C_CODCOM"), oModelN79:GetValue("N79_CODNGC"), oModelN79:GetValue("N79_VERSAO")) > nQtdOrgCad //erro					  
			    		Help( , , STR0031, , STR0146, 1, 0 ) //"AJUDA"###""Quantidade Fixada do Componente excede a quantidade da cadência."
			    		return .f. //não precisa validar o resto		
			    	endif
			    endif
			    
			    //se for cancelamento, válida se o negócio tem a quantidade apropriada
			    if oModel:GetValue("N79UNICO", "N79_TIPO") == "3"
			    	if oModelN7C:GetValue("N7C_TPCALC") != "M" .and. oModel:GetValue("N79UNICO", "N79_FIXAC") == "2" .and. oModelN7C:GetValue("N7C_QTAFIX") >  OGX700SLDC(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_NGCREL"), oModelN79:GetValue("N79_VRSREL") ,oModelN7A:GetValue("N7A_CODCAD"), oModelN7C:GetValue("N7C_CODCOM")) //erro
			    		Help( , , STR0031, , STR0147, 1, 0 ) //"AJUDA"###""Quantidade a ser cancelada do Componente excede a quantidade disponível."
			    		return .f. //não precisa validar o resto
                    // Verifica os componentes do tipo multa que foram informados o valor de multa
                    endif
                    if oModelN7C:GetValue("N7C_TPCALC") == "M" .and. oModelN7C:GetValue("N7C_VLRCOM") != 0 
                        aAreaNk7 := GetArea()
                        
                        DbselectArea("NK7")
						NK7->(DbGoTop())
						NK7->(DbSetOrder(1)) //busca por contrato
						// Verifica se a multa ja existe no array, se não existe adiciona a mesma, para depois validar	
                        If NK7->(DbSeek(FwXfilial("NK7")+oModelN7C:GetValue("N7C_CODCOM")))	.AND. aScan(aTipsMult, NK7->NK7_GERMUL) == 0									
                            aAdd(aTipsMult, NK7->NK7_GERMUL)    									
                        EndIf

                        RestArea(aAreaNk7)
			    	endif
			    endif
			    
			    if oModel:GetValue("N79UNICO", "N79_TIPO") <> "3" //tratado para cancelamento
				    //valida se a quantidade excede a quantidade da cadência
				    if (oModelN7C:GetValue("N7C_QTAFIX") + oModelN7C:GetValue("N7C_QTDFIX")) > oModelN7A:GetValue("N7A_QTDINT") .and. oModelN7C:GetValue("N7C_QTAFIX") > 0 //escape fixações de preço parciais 
				    	//se não se trata de fixação de componente estora o erro pois pode ser 0
				    	if !(oModel:GetValue("N79UNICO", "N79_TIPO") $ "2|5" .and.  oModel:GetValue("N79UNICO", "N79_FIXAC") == "2") 
				    		Help( , , STR0031, , STR0009, 1, 0 ) //"AJUDA"###""A quantidade fixada para os componentes excede a quantidade da Previsão de Entrega"
				    		return .f. //não precisa validar o resto			    	
				    	endif	
				    endif
			    endif
			    
			    //verifica se o componente de bolsa está preenchido quando é esalq
			    if lBolsaInd .and. oModelN7C:GetValue("N7C_QTAFIX") > 0 .and. Posicione("NK7", 1, FwXFilial("NK7")+oModelN7C:GetValue( "N7C_CODCOM"), "NK7_BOLSA") == '1' //é componente de bolsa
			    	Help( , , STR0031, , STR0148, 1, 0 ) //"AJUDA"###""Quando a Bolsa do Negócio segue indíce, não é permitido informar o componente de bolsa."
				    return .f. //não precisa validar o resto	
			    endif
			    
			    //verifica se o valor preenchido para o componente é diferente da cadencia
			    if lBolsaInd .and. oModelN7C:GetValue("N7C_QTAFIX") > 0 .and. oModelN7C:GetValue("N7C_QTAFIX") <> oModelN7A:GetValue("N7A_QTDINT") //é componente de bolsa
			    	Help( , , STR0031, , STR0149, 1, 0 ) //"AJUDA"###""Quando a Bolsa do Negócio segue indíce, os componentes fixados devem possuir a mesma quantidade da previsão de entrega."
				    return .f. //não precisa validar o resto	
			    endif
			    			    
			nExt nC
            
			//verifica se está preenchendo algum valor
			if oModel:GetValue("N79UNICO", "N79_TIPO") $ "2|3|5" .and.  oModel:GetValue("N79UNICO", "N79_FIXAC") == "2".and. oModel:GetValue("N79UNICO", "N79_TPCANC") == "1" .and. !lCompInfo
				Help( , , STR0031, , STR0150, 1, 0 ) //"AJUDA"###""Para realizar uma negociação envolvendo apenas componentes, é necessário informar a quantidadade para o componente em edição."
				return .f. //não precisa validar o resto	
			endif

		endif
		nX++
	endDo

    if Len(aTipsMult) > 1 // Se há mais que um tipo de multa no array, então está invalido.
        Help( , , "OGA700MULT") // # "Foram informados valores em componentes de multa distintos." # Informar o valor para apenas um tipo de multa.
        return .f.
    endif
	
return .t.

/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação
@param:     oModel - Modelo de dados
@return:    .t. - sempre verdadeiro
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function GrvModelo( oModel )
	Local lContinua   := .T.
    Local lAprovTrb   := .f.

	If !(oModel:GetOperation() == 5)
        lAprovTrb := oModel:GetValue("N79UNICO","N79_STATUS")  == "2" .and. oModel:GetValue("N79UNICO","N79_TIPO") $ "2|3"
		oModel:SetValue("N79UNICO","N79_LSTSTS", IIF(!empty(oModel:GetValue("N79UNICO","N79_STATUS")),oModel:GetValue("N79UNICO","N79_STATUS"),"1") ) //seta o ultimo status antes de aprovar
		oModel:SetValue("N79UNICO","N79_STATUS", OGA700STU(oModel) ) //retorna o próximo status
		
		//Altera o status de pendente de ajuste pra não enviado.
		If oModel:GetValue("N79UNICO","N79_STCLIE") == '3' //pendente de ajuste
			oModel:SetValue("N79UNICO","N79_STCLIE", '1')//não enviado
		EndIf
	EndIf

	Begin Transaction
        If __lCtrRisco .and. lAprovTrb
            If oModel:GetValue("N79UNICO","N79_TIPO") == "2"
                OGX702BXFUT(xFilial("N79"), oModel:GetValue("N79UNICO","N79_CODNGC"), oModel:GetValue("N79UNICO","N79_VERSAO"))
            ElseIf oModel:GetValue("N79UNICO","N79_TIPO") == "3"
                OGX702RTFUT(xFilial("N79"), oModel:GetValue("N79UNICO","N79_CODNGC"), oModel:GetValue("N79UNICO","N79_VERSAO"))
            EndIf
        EndIf

	   	if !OGA700UPDN(oModel) //opção padrao - só funciona para fixação
			lContinua := .f.
			DisarmTransaction()     			
			break
   	   	else
		   	If !OGX700SLFX(oModel)
				lContinua := .f.
				DisarmTransaction()  		   		
				break
		   	else
				if !FWFormCommit( oModel ) //commit dos dados	
					 
					lContinua := .f.
					DisarmTransaction()  		   		
					break
				endif	   			
			EndIf
   	   endif		  
	   	 
	End Transaction
	
	//atualiza as regras fiscais, somente se está completo e o prod. for granel, para algodão o valor tem que estar vinculado ao fardo.
	if lContinua .and. !AGRTPALGOD(oModel:GetValue("N79UNICO","N79_CODPRO")) .and. oModel:GetValue("N79UNICO","N79_STATUS") == "3" .AND. !FWISINCALLSTACK('A094Commit')
		if oModel:GetValue("N79UNICO","N79_TIPO")  $ "2|3|5" .and. oModel:GetValue("N79UNICO","N79_FIXAC") == "1" //fixação ou cancelamento
			 OGX055(FwxFilial("NJR"),oModel:GetValue("N79UNICO","N79_CODCTR")) //recalcula os valores das regras fiscais
		endif
	endif		
	
Return( lContinua )

/*{Protheus.doc} OGA700UPDN
Verifica a função de atualização de contrato a ser chamado
@author jean.schulze
@since 28/09/2017
@version undefined
@param oModel, object, descricao
@type function
*/
Function OGA700UPDN(oModel)
	Local lRet := .t.
	Local cTipo := oModel:GetValue("N79UNICO","N79_TIPO")

	If cTipo == "1" /*Novo Negócio*/
		If oModel:GetValue("N79UNICO", "N79_TIPFIX") = "2" .and. __lCtrRisco
		   lRet := OGA700VQCT( 'N79_QTDCTR', oModel )  ////Valida a quantidade de contratos futuros - Tem que ser um número INTEIRO
		EndIf
		If lRet 
			If ((oModel:GetValue("N79UNICO", "N79_STCLIE") $ "2|3|4") .OR. (oModel:GetValue("N79UNICO", "N79_STATUS") $ "3")) .AND. Empty(oModel:GetValue("N79UNICO", "N79_CODCTR")) //sem contrato gerado  
				lRet := OGX700CTR(oModel) //cria o contrato
		   	ElseIf !Empty(oModel:GetValue("N79UNICO", "N79_CODCTR")) // Se é apenas uma atualização de novo negócio com um contrato ja gerado
		   		lRet := OGX700ACTR(oModel) // Verifica se houve alguma alteração no negócio e replica para o contrato, caso o contrato for um pre-contrato.
		   	EndIf	
		EndIf
	Else //demais mods
		if oModel:GetValue("N79UNICO","N79_STATUS") $ "3" /*Completo*/
			if  oModel:GetValue("N79UNICO","N79_TIPO") == "2" /*Fixação*/
				lRet := OGX700FIXA(oModel)
			elseif  oModel:GetValue("N79UNICO","N79_TIPO") == "3" /*Cancelamento*/
				//Validação de consistencia do cadastrado de entidade
				If VldEnt( oModel:GetValue("N79UNICO","N79_CODENT"), oModel:GetValue("N79UNICO","N79_LOJENT"), oModel:GetValue("N79UNICO","N79_OPENGC")  )
					lRet := OGX700CANC(oModel)
				Else
					lRet :=  .F.
				EndIf
			elseif  oModel:GetValue("N79UNICO","N79_TIPO") == "5" /*Modifica*/
				lRet := OGX700MODF(oModel)	
			endif
		elseif oModel:GetValue("N79UNICO","N79_STATUS") $ "5" /**/
			  lRet := OGX700MPAG( oModel )
		elseif oModel:GetValue("N79UNICO","N79_STATUS") $ "1" .and. __lCtrRisco /**/
		      lRet := OGA700VQCT( 'N79_QTDCTR', oModel )  //Validacao quantidade contrato futuro
		endif
	endif
return lRet

/*{Protheus.doc} OGA700VDQ2
Válida as cadências e suas Quantidades
@author marcos.wagner
@since 01/03/2019
@version undefined
@param oField, object, descricao
@param cFldVld, characters, descricao
@type function
*/
Static Function OGA700VDQ2(oField, cFldVld)

	lRet := OGA700VDQT( oField, 'N79_QTDNGC' )

Return lRet

/*{Protheus.doc} OGA700VDQT
Válida as cadências e suas Quantidades
@author jean.schulze
@since 29/08/2017
@version undefined
@param oField, object, descricao
@param cFldVld, characters, descricao
@type function
*/
Static Function OGA700VDQT(oField, cFldVld)
	Local aArea		:= GetArea()
	Local oView		:= FwViewActive()
	Local oModel    := oField:GetModel()
	Local oModelN7A := oModel:GetModel( "N7AUNICO" )
	Local oModelN79 := oModel:GetModel( "N79UNICO" )
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	Local nQtdNegoc := oModel:GetValue( "N79UNICO","N79_QTDNGC" )
	Local cTipFix   := oModel:GetValue( "N79UNICO","N79_TIPFIX" )
	Local cFixMode  := oModel:GetValue( "N79UNICO","N79_FIXAC" )
	Local cTipoNgc  := oModel:GetValue( "N79UNICO","N79_TIPO" )
	Local cTpCanc   := oModel:GetValue( "N79UNICO","N79_TPCANC" ) //cancelamento fixação/quantidade
	Local lRet      := .t.
	Local nX        := 0
	Local nLinhaFlg := 0
	Local nProp		:= 0
	Local aLinhaFlg := {}
	Local aSaveRows	:= FwSaveRows(oModel) 
	Local nQuantAux	:= 0
	Local nIt		:= 0
	Local lModeView := iif(FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. cTipoNgc $ "2|3") , SuperGetMv("MV_AGRO007",,.T.) , .F.)//abre em modo resumido
	Local cHedge    := ""
	Local nLimite   := 0
	 
	If oModelN79:GetValue("N79_TIPO") <> "1" //novo
		If cFldVld == 'N7A_QTDINT' .and. oField:GetValue("N7A_QTDINT") != 0 .and.  oModelN7A:GetValue( "N7A_USOFIX" ) == "LBNO"
			oModelN7A:SetValue( "N7A_USOFIX", "LBOK" )
		EndIF
	
		/*If cFldVld == 'N7A_QTDINT' .and. oField:GetValue("N7A_QTDINT") == 0 .and.  oModelN7A:GetValue( "N7A_USOFIX" ) == "LBOK"
			oModelN7A:SetValue( "N7A_USOFIX", "LBNO" )
		EndIF*/ 
	EndIf

	If cFldVld == "N79_BOLSA"		
		cBolsa := StrTran(oModelN79:GetValue("N79_BOLSA"),"'")
	    oModelN79:LoadValue("N79_BOLSA", cBolsa)		
	Endif		
	
	If cFldVld == "N79_FILORG"		
		If !Empty(oModelN79:GetValue("N79_FILORG"))
			lRet := OGX700VSM0(oModelN79:GetValue("N79_FILORG"), .T.)		                                                                                           
		
			If lRet
				nX := 1
				While nX <= oModelN7A:Length()
					oModelN7A:GoLine( nX )
					oModelN7A:SetValue("N7A_FILORG", oModelN79:GetValue("N79_FILORG"))
					If Empty(oModelN7A:GetValue("N7A_FILORG"))
						oModelN7A:SetValue("N7A_FILDES", alltrim(OGX700PSM0("N7A_FILORG")))     
					EndIf
					nX++
				EndDo	
				If valType(oView) == 'O' .and. !FWIsInCallStack("OGA700FDNG");
					.and. !FWIsInCallStack("OGA290") .and. !FWIsInCallStack("OGA280") 			
					oView:GetViewObj("VIEW_N7A")[3]:Refresh()		
				endif			
			EndIf		
		EndIf
	EndIf
	
	//validação padrão dos campos
	if cFldVld == 'N79_QTDNGC' .and. (nQtdNegoc < 1 .and. !(cFixMode == "2" .and. cTipoNgc == "2"))
		oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0012, STR0151, "", "")//"A quantidade do negócio deve ser um valor positivo."#"Informe uma quantidade válida."
		lRet      := .f.
	elseif cFldVld == 'N7A_QTDINT' .and. (oField:GetValue("N7A_QTDINT") < 1 .and. !(cFixMode == "2" .and. (cTipoNgc $ "2|3|5")) .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" .and. cTpCanc == '1')
		oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", STR0012, STR0151, "")//"A quantidade do negócio deve ser um valor positivo."#"Informe uma quantidade válida."   
		lRet      := .f.
	elseif cFldVld == 'N79_TIPFIX' .and. !(cTipFix $ "1|2")
		oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0013, STR0152, "")//"O Tipo de Preço deve ser Fixo ou À Fixar"#"Informe um tipo de fixação válido."
		lRet      := .f.
	elseif cFldVld == 'N79_FIXAC' .and. !(cFixMode $ "1|2")
		oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0014, STR0153, "")//"O Tipo de Fixação deve ser Preço ou Componente"#"Informe um modo de fixação válido."
		lRet      := .f.
	endif
	
	//validação de fixação
	if cTipoNgc == "2" //fixação
		If cFldVld == 'N79_QTDNGC'
			for nX := 1 to oModelN7A:Length()
				oModelN7A:GoLine(nX)
				nLimite += OGX700QLMT(oModelN79:GetValue("N79_FILIAL"), oModelN79:GetValue("N79_CODCTR"), oModelN7A:GetValue("N7A_CODCAD"), oModelN79:GetValue("N79_CODNGC"), oModelN79:GetValue("N79_VERSAO"))
			next nX
			
			If nQtdNegoc > nLimite
				oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", "A quantidade digitada ultrapassa o limite da fixação da(s) cadência(s).", "A quantidade não poderá ser maior que "+AllTrim(Str(nLimite)), "", "")//215 e 216
				lRet      := .f.
			EndIf
		EndIf

		If cFldVld == 'N7A_QTDINT' .and. (oField:GetValue("N7A_QTDINT") >  OGX700QLMT(oModelN79:GetValue("N79_FILIAL"), oModelN79:GetValue("N79_CODCTR"), oField:GetValue("N7A_CODCAD"), oModelN79:GetValue("N79_CODNGC"), oModelN79:GetValue("N79_VERSAO"), oField:GetValue("N7A_QTDFIX")))
			oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", STR0154, STR0155, "", "")//"A quantidade ultrapassa o limite da fixação para a cadência."#"Utilizar o valor limite da Cadência."
			lRet      := .f.
		endif
	elseif cTipoNgc == "3" //cancelamento
		if cFldVld == 'N7A_QTDINT' .and. oField:GetValue("N7A_QTDINT") > 1 .and.  oModelN7A:GetValue( "N7A_USOFIX" ) == "LBNO"
			oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", STR0156, STR0157, "", "")//"A quantidade só pode ser informado para a cadência a serem aplicadas."#"Selecione a Cadência para informar o valor para a mesma."
			lRet      := .f.
		elseif cFldVld == 'N7A_QTDINT' .and. oModelN79:GetValue("N79_TPCANC") == '1' .and. (oField:GetValue("N7A_QTDINT") > OGX700SLDP(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_NGCREL"), oModelN79:GetValue("N79_VRSREL") ,oModelN7A:GetValue("N7A_CODCAD")))
			oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", STR0158, STR0159, "", "")//"A quantidade ultrapassa o limite da fixação para a cadência."#"Utilizar o valor limite da Cadência."
			lRet      := .f.
		elseif cFldVld == 'N7A_QTDINT' .and. oModelN79:GetValue("N79_TPCANC") == '2' .and. (oField:GetValue("N7A_QTDINT") > OGX700SDCQ(oModelN79:GetValue("N79_FILIAL"),oModelN79:GetValue("N79_CODCTR"), oModelN7A:GetValue("N7A_CODCAD")))
			oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN7A:GetId(), "", "", STR0160, STR0159, "", "")//"A quantidade ultrapassa o limite de cancelamento para a cadência."#"Utilizar o valor limite da Cadência."
			lRet      := .f.			
		endif
	endif
	
	if lRet

		//verifica a quantidade de cadências
		if cFldVld == 'N79_QTDNGC'
			
			//reposiciona na linha correta
			oModelN7A:Goline(1)
			oModelN7C:Goline(1)
						
			if (cFixMode == "2" .and. cTipoNgc == "2") //fixação de componente
					
				//reseta todos os valores
				nX := 1
			    while nX <= oModelN7A:Length()
					oModelN7A:GoLine( nX )
					if oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO"
						oModelN7A:SetValue("N7A_QTDINT", 0)
					endif	
					nx++
				enddo
							
			else
			 	if oModelN7A:Length() <= 1 //só tem uma cadência
					//coloca a quantidade na cadência
					oModelN7A:SetValue("N7A_QTDINT", nQtdNegoc)
				else //verifica se tem uma ativa somente			
					//reseta todos os valores
					nX := 1
				    while nX <= oModelN7A:Length()
						oModelN7A:GoLine( nX )
						if oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO"
							If	cTipoNgc == "1" //novo negócio
								aAdd(aLinhaFlg, {nX ,  oModelN7A:GetValue( "N7A_QTDINT" ) })
							Else
								aAdd(aLinhaFlg, {nX ,  oModelN7A:GetValue( "N7A_QTDDIS" ) })
							EndIf
							nLinhaFlg++
						endif	
						nx++
					enddo
					
					nProp := nQtdNegoc // Variavel auxiliar para controlar a quantidade disponivel para debitar
					
					nX := 1
					while nX <= Len(aLinhaFlg) //respeita primeiro o que está selecionado
						oModelN7A:GoLine( aLinhaFlg[nX][1] )
						If nProp >= aLinhaFlg[nX][2] .and. aLinhaFlg[nX][2] > 0  
							oModelN7A:SetValue("N7A_USOFIX", 'LBOK')
							oModelN7A:SetValue("N7A_QTDINT", aLinhaFlg[nX][2])
							nProp -= aLinhaFlg[nX][2] // Debita da quantidade disponivel
						ElseIf nProp > 0
						 	oModelN7A:SetValue("N7A_USOFIX", 'LBOK')
						 	oModelN7A:SetValue("N7A_QTDINT", nProp) // Atribui o restante de proporcional a cadencia
						 	nProp := 0 // Apos atribuir a quantidade restante, zera as demais quantidades de cadencia disponiveis
						Else
							oModelN7A:SetValue("N7A_USOFIX", 'LBNO') // Atribui o restante de proporcional a cadencia
							oModelN7A:SetValue("N7A_QTDINT", 0) 
						EndIf
						
						nx++
					enddo
					
					if nProp > 0 //recoloca nos demais itens fifo
						nX := 1
						while nX <= oModelN7A:Length()
							oModelN7A:GoLine( nX )
							if oModelN7A:GetValue( "N7A_USOFIX" ) == "LBNO" .and. nProp > 0
								If cTipoNgc != "1" 								
									If nProp >= oModelN7A:GetValue( "N7A_QTDDIS" ) .and. oModelN7A:GetValue( "N7A_QTDDIS" ) > 0
										oModelN7A:SetValue("N7A_USOFIX", 'LBOK') 
										oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue( "N7A_QTDDIS" ))
										nProp -= oModelN7A:GetValue( "N7A_QTDDIS" )// Debita da quantidade disponivel
									ElseIf nProp > 0
									 	oModelN7A:SetValue("N7A_USOFIX", 'LBOK') 
									 	oModelN7A:SetValue("N7A_QTDINT", nProp) // Atribui o restante de proporcional a cadencia
									 	nProp := 0 // Apos atribuir a quantidade restante, zera as demais quantidades de cadencia disponiveis
									endif
								Else
									If nProp >= oModelN7A:GetValue( "N7A_QTDINT" ) .and. oModelN7A:GetValue( "N7A_QTDINT" ) > 0
										oModelN7A:SetValue("N7A_USOFIX", 'LBOK') 
										oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue( "N7A_QTDINT" ) + nProp)										
									ElseIf nProp > 0
									 	oModelN7A:SetValue("N7A_USOFIX", 'LBOK') 
									 	oModelN7A:SetValue("N7A_QTDINT", nProp) // Atribui o restante de proporcional a cadencia
									 	nProp := 0 // Apos atribuir a quantidade restante, zera as demais quantidades de cadencia disponiveis
									endif
								EndIf															
							endif	
							nx++
						enddo
					endif
					
				endif
			endif
			
		endif

		//troca de forma de tipo
		if cFldVld == 'N79_TIPFIX'
			oModel:SetValue( "N79UNICO","N79_FIXAC", iif(cTipFix == "1", "1", "2") ) //1 - Preço, 2-Componente
			If (cTipFix == "1" .and. cTipoNgc == "1") // Se for um novo negocio e o tipo preço fixo, replica a quantidade da cadencia para os respectivos componentes
				For nIt := 1 To oModelN7A:Length()
					oModelN7A:GoLine(nIt)
					oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue("N7A_QTDINT"), .T.) // força aplicação do mesmo valor para acionar o valid de atualização da grid de componentes
				Next nIt	
			EndIf
			
			If (cTipFix == "2" .and. cTipoNgc == "1") // Se for um novo negocio e o tipo preço fixo, replica a quantidade da cadencia para os respectivos componentes
				For nIt := 1 To oModelN7A:Length()					
					oModelN7A:Goline(nIt)
					oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue("N7A_QTDINT"), .T.)
				Next nIt	
			EndIf
			
			//trata operação
			nX := 1
			while nX <= oModelN7A:Length()
				oModelN7A:GoLine( nX )
				For nIt := 1 To oModelN7C:Length()					
					oModelN7C:Goline(nIt)
					cHedge := POSICIONE("NK7", 1, FwXFilial("NK7") + oModelN7C:GetValue("N7C_CODCOM"), iif(cTipFix == "1","NK7_HEDGE","NK7_FHEDGE"))
					oModelN7C:LoadValue("N7C_HEDGE",(IIF(cHedge == "1", "1", "")) )
				Next nIt
				nX++	
			enddo
		endif

		if cFldVld == 'N79_FIXAC'
			//reposiciona na linha correta
			oModelN7A:Goline(1) 
			oModelN7C:Goline(1) 
			
			//fixação de componente - reset quantidade
			if (cFixMode == "2" .and. cTipoNgc == "2")
				oModelN79:ClearField("N79_QTDNGC")
				For nIt := 1 To oModelN7A:Length()
					oModelN7A:GoLine(nIt)
					oModelN7A:SetValue("N7A_QTDINT", 0)
				Next nIt
			elseif (cFixMode == "1" .and. cTipoNgc == "2")
				For nIt := 1 To oModelN7A:Length()
					oModelN7A:GoLine(nIt)
					If oModelN7A:GetValue("N7A_USOFIX") == "LBOK" 
						oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue( "N7A_QTDDIS" ))
					EndIf				
				Next nIt
			endif
		endif

		//troca da quantidade da cadencia
		if cFldVld == 'N7A_QTDINT'
			oModelN7C:Goline(1)
			
			fCalcQtd(oModel, oField:GetValue("N7A_QTDINT"), oModelN7A:GetValue("N7A_QTDFIX"))
						
			if !(Readvar() $ "N79_QTDNGC") //só quando for o read var da cadencia vamos refazer a quantidade total
			    
				nQuantAux := 0

				For nIt := 1 To oModelN7A:Length()
					oModelN7A:Goline(nIt)
                    BuscaBolsa()
					If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue('N7A_USOFIX', nIt) == "LBOK"
						nQuantAux += oModelN7A:GetValue('N7A_QTDINT', nIt)
					EndIf
				Next nIt				
				
			   	If oModelN79:GetValue("N79_TPCANC") == '1'
			   	   oModelN79:LoadValue('N79_QTDNGC', nQuantAux)
					
					fTrgN79CVT()//atualiza  segunda unidade de medida
					
			   	EndIF
			endif
		endif

		//troca da quantidade da cadencia
		if cFldVld == 'N79_TPCANC'
			if oModelN79:GetValue("N79_TPCANC") == '2'
				oModelN79:LoadValue("N79_QTDNGC", 0)
			else
				//oModelN79:LoadValue("N79_CODMTV", '')
			endif	
			For nIt := 1 To oModelN7A:Length()
				oModelN7A:GoLine(nIt)
				
				if oModelN79:GetValue("N79_TPCANC") = '2' //quantidade					
					nQtdCadPrc := OGX700SDCQ(oModelN79:GetValue("N79_FILIAL"), oModelN79:GetValue("N79_CODCTR"), oModelN7A:GetValue("N7A_CODCAD"))

					oModelN7A:SetValue("N7A_QTDINT", nQtdCadPrc )
					oModelN7A:LoadValue("N7A_QTDDIS", nQtdCadPrc) //quantidade disponivel para o cancelamento
				else 
					If (nPos := aScan(__aFixDisp, {|x| x[1] == oModelN7A:GetValue("N7A_CODCAD")})) > 0
						oModelN7A:LoadValue("N7A_QTDDIS", __aFixDisp[nPos][2])
						if oModelN79:GetValue("N79_FIXAC") == '1' .and. oModelN7A:GetValue("N7A_QTDDIS") > 0 //quando é preço, realiza setvalue para recalcular o N79_QTDNGC 
							oModelN7A:SetValue("N7A_QTDINT", __aFixDisp[nPos][2])
						else   //quando é componente, realiza load para não alterar a quantidade dos componentes.
							oModelN7A:LoadValue("N7A_QTDINT", __aFixDisp[nPos][2])
						endif
					EndIf
				endif
			Next nIt
		endif

		
		FwRestRows(aSaveRows)

		If valType(oView) == 'O' ;
		.and. !FWIsInCallStack("OGA700FDNG") ;
		.AND. !FWIsInCallStack("ActivateMD") ;
		.and.  cFldVld != "N79_FILORG";
		.and. !FWIsInCallStack("OGA290");
		.and. !FWIsInCallStack("OGA280")	 //função que retorna os dados de fixação
			oView:Refresh("VIEW_N7A")
			oView:Refresh("VIEW_N7C")
			if lModeView .AND. !FWIsInCallStack("OGA700VDQ2")
				oView:Refresh("VIEW_AUX")
		    endif
		endif

	endif
	
	RestArea(aArea)

Return(lRet)


/*{Protheus.doc} OGA700VDQT
Válida a quantidade do contrato futuro
@author Marcelo Ferrari
@since 29/08/2017
@version undefined
@param oField, object, descricao
@param cFldVld, characters, descricao
@type function
*/
Static Function OGA700VQCT( cFldVld, oModel )
	Local aArea		:= GetArea()
	Local oModelN79 := oModel:GetModel( "N79UNICO" )
	Local oModelN7A := oModel:GetModel( "N7AUNICO" )
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	Local lRet      := .t.
	Local nX        := 0
	Local nIt		:= 0
	Local aSaveRows	:= FwSaveRows(oModel) 
	Local cTipoCtr	:= oModelN79:GetValue("N79_OPENGC")
	Local cTipoPrc	:= oModelN79:GetValue("N79_TIPFIX")

	if (cFldVld == 'N79_QTDCTR' .And. cTipoPrc == "2") .OR. (cFldVld == 'N79_QTDCTR' .and. oModel:GetValue("N79UNICO","N79_TIPO") == "2")
		//reposiciona na linha inicial
		oModelN7A:Goline(1) 
		oModelN7C:Goline(1) 
		
		//fixação de componente - quantidade de contrato futuro
		For nIt := 1 To oModelN7A:Length()
			oModelN7A:GoLine(nIt)
			If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue("N7A_USOFIX") != "LBNO"
				For nX := 1 to oModelN7C:Length()
					oModelN7C:GoLine(nX)
					If oModelN7C:GetValue("N7C_HEDGE") == "1"
						If !FwIsInCallStack("OGWSPUTFIX") //ignora quando vem do fluig
							If Empty(oModelN7C:GetValue("N7C_OPEFIX")) .AND. oModel:GetValue("N79UNICO","N79_TIPO") == "2"
								lRet :=  .F.
								//"Favor selecionar a operação de fixação em Componentes. "Realize o preenchimento do campo de acordo com o tipo do contrato."
								oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0182, STR0183, "", "")
								exit
							ElseIf oModelN7C:GetValue("N7C_OPEFIX") = "1" .And. cTipoCtr = "1"
								lRet :=  .F.
								//"O tipo do contrato é de Compra e foi selecionada a operação de fixação de Compra.", "Favor preencher a operação de fixação como Venda."
								oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0184, STR0185, "", "")
								exit
							ElseIf oModelN7C:GetValue("N7C_OPEFIX") = "2" .And. cTipoCtr = "2"
								lRet :=  .F.
								//"O tipo do contrato é de Venda e foi selecionada a operação de fixação de Venda.", "Favor preencher a operação de fixação como Compra.
								oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0186, STR0187, "", "")
								exit
							EndIf
						
							If !((oModelN7C:GetValue("N7C_QTDCTR") - INT( oModelN7C:GetValue("N7C_QTDCTR") ) ) = 0 )
								lRet :=  .F.
								//"A quantidade do Contrato Futuro deve ser um número inteiro."
								oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0188, STR0151, "", "")//"A quantidade do Contrato Futuro deve ser um número inteiro."#"Informe uma quantidade válida."
								exit
							EndIf
						EndIf
					EndIf				
				Next nX
			EndIf
			If !lRet
				Exit
			Endif
		Next nIt
	endif
		
	FwRestRows(aSaveRows)
	RestArea(aArea)

Return(lRet)

/*{Protheus.doc} fCalcQtd
Apropia quantidades nos componentes
@author jean.schulze
@since 29/08/2017
@version undefined
@param oModel, object, descricao
@param nQtdNegoc, numeric, descricao
@type function
*/
Static function fCalcQtd(oModel, nQtdNegoc, nQtdFixPrc)
	Local oModelN7C  := oModel:GetModel( "N7CUNICO" )
	Local cFixMode   := oModel:GetValue( "N79UNICO","N79_FIXAC" )
	Local cTpCanc    := oModel:GetValue( "N79UNICO","N79_TPCANC" )
	Local nLinhaCom  := oModelN7C:GetLine()
	Local nQtdMaxCmp := 0
	Local nx         := 0
	Local aSaveRows	 := FwSaveRows(oModel)
	
	//busca as fixações já efetuadas
	OGA700GN7M(oModel)

	//atualizar componentes
	For nX := 1 to oModelN7C:Length()
	    oModelN7C:GoLine( nX )
	    
	     //monta a quantidade para o componente
	    if oModel:GetValue("N79UNICO","N79_TIPO") $ "2|5" /*Fixação*/   
		    nQtdMaxCmp := nQtdNegoc  - oModelN7C:GetValue( "N7C_QTDFIX")  //quantidade fixavel - quantidade já fixada
	    else
	    	nQtdMaxCmp := nQtdNegoc
	    endif
	    
	  	if nQtdMaxCmp < 0
	  		nQtdMaxCmp := 0 //valor máximo somente 0
	  	endif	  	
	  	
	  	cCalcul := POSICIONE("NK7",1,FwXFILIAL("NK7")+oModelN7C:GetValue("N7C_CODCOM"),"NK7_CALCUL")
	  	
	  	//update da quantidade
    	oModelN7C:LoadValue( "N7C_QTAFIX", iif( cTpCanc == '2' .and. cCalcul == 'M' , nQtdMaxCmp, iif( cFixMode = '1', nQtdMaxCmp, 0))) //negocio é fixo atualiza as quantidades
    	
    	//calcula a linha
    	OGX700LNCP(oModel:GetModel( "N7CUNICO" ),oModel:GetValue("N79UNICO","N79_UMPRC"),oModel:GetValue("N79UNICO","N79_UM1PRO"),  iif(oModel:GetValue("N79UNICO","N79_TIPO") $ "2|5" /*Fixação*/ .and. oModel:GetValue("N79UNICO","N79_FIXAC") == "1" /*Preço*/,.t.,.f.), oModel:GetValue("N79UNICO","N79_CODPRO")) //aplica o valor total
	  	

	 nExt nX

	 //reposiciona na linha
	 oModelN7C:GoLine(nLinhaCom)

	 //atualiza os campos totais
	 OGX700CTPP(oModel)

	 //atualiza valores na variavel principal
	 OGX700GTOT(oModel)
	 
	 
	 FwRestRows(aSaveRows)

return(.t.)

/*{Protheus.doc} fOpen701
Pré processador da tela de precificação
@author jean.schulze
@since 29/08/2017
@version undefined
@param oView, object, descricao
@type function
*/
Static Function fOpen701(oModel)
	Local cTp        := iif(oModel:GetValue( "N79UNICO","N79_OPENGC" ) == "1" /*Compra*/, "C", "V")
	Local cProduto   := oModel:GetValue( "N79UNICO","N79_CODPRO" )
	Local cCodSaf    := oModel:GetValue( "N79UNICO","N79_CODSAF" )
	Local nQtdNegoc  := oModel:GetValue( "N7AUNICO","N7A_QTDINT" )
	Local cMoedactr  := oModel:GetValue( "N79UNICO","N79_MOEDA"  )
	Local oModelN7A  := oModel:GetModel( "N7AUNICO" )
	Local aCompDados := {}
	Local cX         := 1

	if !empty(cProduto) .or. !empty(cMoedactr) //só chama quando esses caras estão OK!
		
		//monta com os valores dos componentes atuais
		aCompDados := OGX700COM(cTp ,cProduto, cCodSaf, nQtdNegoc, dDataBase, dDataBase, dDatabase, cMoedactr, .f.  )//gatilha os componentes

		//remove componentes com regra
		aCompDados := OGX700RECG(aCompDados, oModel)
		
		//verifcia se é todos os componentes
		if oModel:GetValue( "N79UNICO","N79_APLCAD" ) 
			//replica os valores em todas as cadencias
			while cX <= oModelN7A:Length()

			    oModelN7A:GoLine( cX )

			    //limpa os dados
			    fLstCompN7C(aCompDados, oModel, iif(oModel:GetOperation() ==  MODEL_OPERATION_INSERT, .t.,.f.))
			  	cX++
			endDo
		else
			//replcia os valor somente na cadencia atual	
			fLstCompN7C(aCompDados, oModel, iif(oModel:GetOperation() ==  MODEL_OPERATION_INSERT, .t.,.f.))
		endif
		
		//insere os valores na tela de valor
		OGX700GTOT(oModel)
				
	else
		//para precificar é necessário ter os dados de quantidade e produto e safra
		Help( ,,STR0031,, STR0015, 1, 0 )//"Ajuda"#"Para precificar é necessário ter os dados de produto e moeda."
	endif

return(.t.)

/*{Protheus.doc} fLstCompN7C
Carga dos componentes
@author jean.schulze
@since 29/08/2017
@version undefined
@param aLstComp, array, descricao
@param oModel, object, descricao
@type function
*/
Static Function fLstCompN7C(aLstComp, oModel, lReset)
	Local nI        := 0
	Local oModelN79	:= oModel:GetModel( "N79UNICO" )
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	Local oModelN7A := oModel:GetModel( "N7AUNICO" )
 	Local cMoedactr := oModel:GetValue( "N79UNICO","N79_MOEDA"  )
	Local c1aUM 	:= oModel:GetValue( "N79UNICO","N79_UM1PRO"  )
	Local cUmPrc 	:= oModel:GetValue( "N79UNICO","N79_UMPRC"  )
	Local cTipFix   := oModel:GetValue( "N79UNICO","N79_TIPFIX" )
	Local nPos      := 0
	Local lPrim     := .T. 

	/*Libera edição*/
	oModel:GetModel( "N7CUNICO" ):SetNoDelete( .f. )
	oModel:GetModel( "N7CUNICO" ):SetNoInsert( .f. )

	IF lReset //reseta os componentes
		oModelN7C:cleardata() // Limpa o Grid
		oModelN7C:InitLine()
	endif

	//Aplica os valores para cada cadência
	for nI:=1 to len(aLstComp)
	
		if aLstComp[nI][14] <> "T" //é tributo

			IF oModel:GetOperation() ==  MODEL_OPERATION_INSERT

				If lPrim 
					lPrim = .F.
				Else
					oModelN7C:AddLine()
				EndIF
				oModelN7C:GoLine( oModelN7C:Length() )
				
				//verifica se ocorreu um erro
				If OGX700ERRO(oModel)
					return .f.
				EndIf				
			else
				//trata o update
				if !oModelN7C:SeekLine( { {"N7C_CODCOM", aLstComp[nI][1]  } } ) //posiciona no componente
					oModelN7C:AddLine()			   	  
					oModelN7C:GoLine(oModelN7C:Length()) //posiciona na ultima linha

					//verifica se ocorreu um erro
					if OGX700ERRO(oModel)
						return .f.
					endif
				endif
			endif

			//load values
			oModelN7C:LoadValue( "N7C_STSLEG", OGX700LEG(aLstComp[nI][14]))
			oModelN7C:LoadValue( "N7C_CODCOM", aLstComp[nI][1])
			oModelN7C:LoadValue( "N7C_TPCALC", aLstComp[nI][14])
			oModelN7C:LoadValue( "N7C_ITEMCO" ,aLstComp[nI][2])
			oModelN7C:LoadValue( "N7C_CODIDX", aLstComp[nI][3])
			oModelN7C:LoadValue( "N7C_DESCRI", aLstComp[nI][4])
			oModelN7C:LoadValue( "N7C_MOEDA" , cMoedactr)
			oModelN7C:LoadValue( "N7C_TXCOTA", aLstComp[nI][6])
			oModelN7C:LoadValue( "N7C_MOEDCO", aLstComp[nI][5])
			oModelN7C:LoadValue( "N7C_DMOECO", AGRMVSIMB(aLstComp[nI][5]))
			oModelN7C:LoadValue( "N7C_UMCOM" , aLstComp[nI][7])
			oModelN7C:LoadValue( "N7C_VLRIDX", aLstComp[nI][8])
			oModelN7C:LoadValue( "N7C_VLRCOM", aLstComp[nI][9])
			oModelN7C:LoadValue( "N7C_QTAFIX", iif(cTipFix == "1",oModelN7A:GetValue("N7A_QTDINT"),aLstComp[nI][20]))
			oModelN7C:LoadValue( "N7C_UMPROD", c1aUM)
			oModelN7C:LoadValue( "N7C_UMPRC" , cUmPrc)
			oModelN7C:LoadValue( "N7C_TPPREC", aLstComp[nI][17])
			oModelN7C:LoadValue( "N7C_ORDEM",  aLstComp[nI][15])
			oModelN7C:LoadValue( "N7C_REGRA",  aLstComp[nI][18])
			oModelN7C:LoadValue( "N7C_VISUAL", iiF(aLstComp[nI][19] == "0", "S", "N"))
			oModelN7C:LoadValue( "N7C_ALTVLR", aLstComp[nI][21])
			oModelN7C:LoadValue( "N7C_QTDFIX", aLstComp[nI][22])
			oModelN7C:LoadValue( "N7C_VLRFIX", aLstComp[nI][23])
			oModelN7C:LoadValue( "N7C_BOLSA" , aLstComp[nI][27])
			
			if oModelN79:GetValue("N79_TIPFIX") == "1"
				oModelN7C:LoadValue( "N7C_HEDGE" ,  iif(aLstComp[nI][28] > "0",aLstComp[nI][28],""))
			else
				oModelN7C:LoadValue( "N7C_HEDGE" ,  iif(aLstComp[nI][29] > "0",aLstComp[nI][29],""))
			endif
				
			//calcula a linha
			OGX700LNCP(oModel:GetModel( "N7CUNICO" ),cUmPrc,c1aUM, iif(oModel:GetValue("N79UNICO","N79_TIPO") $ "2|5" /*Fixação*/ .and. oModel:GetValue("N79UNICO","N79_FIXAC") == "1" /*Preço*/,.t.,.f.),oModel:GetValue("N79UNICO","N79_CODPRO")) //aplica o valor total
		endIf
	nExt nI

	//remove os inutilizados - somente update
	IF oModel:GetOperation() ==  MODEL_OPERATION_UPDATE
		for nI:=1 to oModelN7C:Length()
		    oModelN7C:GoLine( nI )
		    If ( nPos := aScan( aLstComp, { |x| AllTrim( x[1] ) == AllTrim( oModelN7C:GetValue("N7C_CODCOM") ) } ) ) = 0 //não tem no array o componente
		        oModelN7C:DeleteLine()
		    endif
		next nI
	endif

	//atualiza os campos totais
	OGX700CTPP(oModel)

	//posiciona na primeira linha - aplicação dos whens e outros
	if len(aLstComp) > 0
		oModelN7C:GoLine( 1 )
	endif

	//bloqueia edição
	oModel:GetModel( "N7CUNICO" ):SetNoDelete( .t. )
	oModel:GetModel( "N7CUNICO" ):SetNoInsert( .t. )
	
return(.t.)

/*{Protheus.doc} ValChkN7A
Valida as cadencias para remover os dados/ incluir
@author jean.schulze
@since 29/08/2017
@version undefined
@param oGrid, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
*/
Static Function ValChkN7A(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local oModel    := oGrid:GetModel()
	Local lRet      := .t.
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	
	Local aSaveLines  := FWSaveRows()
	Local cX        := 0

	If cAction == "SETVALUE" .and. ( ( oModelN7C:Length() <= 1 .and. empty(oModelN7C:GetValue("N7C_CODCOM")) ) .or.  oModelN7C:Length() < 1)  //só faz se não carregou para o componente

		//atualiza valores na variavel principal
		OGX700GTOT(oModel)

	ElseIf cAction == "DELETE" // Se a Ação for Delete

		/*Libera edição*/
		oModel:GetModel( "N7CUNICO" ):SetNoDelete( .f. )
		oModel:GetModel( "N7CUNICO" ):SetNoInsert( .f. )
		
		For cX := 1 to oModelN7C:Length()
		    oModelN7C:GoLine( cX )
		    oModelN7C:DeleteLine()
		next cX

		/*Bloqueia edição*/
		oModel:GetModel( "N7CUNICO" ):SetNoDelete( .t. )
		oModel:GetModel( "N7CUNICO" ):SetNoInsert( .t. )
		

		//atualiza valores na variavel principal
		OGX700GTOT(oModel)


	ElseIf cAction == "UNDELETE"

		/*Libera edição*/
		oModel:GetModel( "N7CUNICO" ):SetNoDelete( .f. )
		oModel:GetModel( "N7CUNICO" ):SetNoInsert( .f. )

		For cX := 1 to oModelN7C:Length()
		    oModelN7C:GoLine( cX )
		    oModelN7C:UnDeleteLine()
		next cX

		/*Bloqueia edição*/
		oModel:GetModel( "N7CUNICO" ):SetNoDelete( .t. )
		oModel:GetModel( "N7CUNICO" ):SetNoInsert( .t. )
		
		//atualiza valores na variavel principal
		OGX700GTOT(oModel, .t.)
	endif
	
	FWRestRows(aSaveLines)
		
return(lRet)

/*{Protheus.doc} ValChkN7C
Tratamento de dados da Negociação
@author jean.schulze
@since 08/11/2017
@version undefined
@param oGrid, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
*/
Static Function ValChkN7C(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local oModel    := oGrid:GetModel()
	Local lRet      := .t.
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )

	If cAction == "SETVALUE" .and. M->N79_APLCAD
		
		if cIDField $ "N7C_VLRCOM|N7C_TXCOTA"
			if !FWIsInCallStack("OGX700RPLI") //matando a recursividade
				//atualiza valores na variavel principal
				OGX700RPLI(oModel, cIDField, xValue,  oModelN7C:GetValue("N7C_CODCOM"))
			endif
		endif
		
	endif

return(lRet)

/** {Protheus.doc} OGA700APVA
Função que Aprova o Negócio
@param  :   nIL
Retorno :  .t. ou .f. Indicando que o produto está ok.
@author :   Equipe Agroindustria
@since  :   02/10/2016
@Uso    :   SIGAAGR - Originação de Grãos
*/
Function OGA700APVA()
	
	Local aArea			:= GetArea()
	Local cIniMsg 		:= ""
	Local oModel 		:= Nil
	Local lReturn       := .f.
	Local lGrvMotiv     := .T.		

	If !(N79->N79_STATUS $ "1|2")
		Iif(!__lRegOpcional,Help( ,,STR0031,, STR0018, 1, 0),) //"AJUDA"# "A Opção de Aprovação é somente para negócios com status 'Pendente' ou 'Trabalhando'"
		return(.F.)
	endif

	If N79->N79_STATUS == '1'
		cIniMsg := STR0025 + " - " // # "Aprovação de Negócio"
	ElseIf N79->N79_STATUS == '2'
    		cIniMsg := STR0026 + " - " // # "Aprovação de Banking"
	EndIf
	
	oModel := FwLoadModel("OGA700")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	
	If oModel:Activate()
	
		If !FWIsInCallStack("OGA700FIXA") .and. !FWIsInCallStack("OGA700CANC")
			If !OGA700ENTI()
				oModel:DeActivate() // Desativa o model
				oModel:Destroy() // Destroi o objeto do model
				RestArea(aArea)
				Return .F.
			EndIf
		Endif
	
		If __lCtrRisco .AND. N79->N79_TIPO == '2' .AND. N79->N79_STATUS == "2" 
			If !OGX700NCT(oModel)
				//Selecionar Ctr. Futuro. "Os contratos futuros não foram selecionados na fixação.
				//Realize a seleção através da ação relacionada 'Selecionar Contratos Futuros' da fixação. 
				AGRHELP(STR0191,STR0192,STR0193 )
                oModel:DeActivate() // Desativa o model
				oModel:Destroy() // Destroi o objeto do model
				RestArea(aArea)
				return(.F.)
			endif
		EndIf
		
		If __lAutomato .OR. __lRegOpcional 
            lGrvMotiv := .T.
        Else
            lGrvMotiv := AGRGRAVAHIS(STR0019,"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,"A", , cIniMsg) = 1
        EndIf		
		
		If lGrvMotiv	
			
			If lReturn := oModel:VldData()  // Valida o Model
				lReturn := oModel:CommitData() // Realiza o commit	

				//ajustado para atualizar os dados do negócio quando aprovar a fixação
				If lReturn .AND. N79->N79_TIPO == "2" .AND. !Empty(N79->N79_CODCTR)
					OGX310(2,N79->N79_CODCTR)
				EndIf	
			EndIf	
			
			if !lReturn
				OGX700ERRO(oModel)
			endif
			
			oModel:DeActivate() // Desativa o model
			oModel:Destroy() // Destroi o objeto do model
			
		endif
	EndIf
	
	RestArea(aArea)
	
return lReturn

/*{Protheus.doc} OGA700REPR
Reprovar negócio
@author jean.schulze
@since 31/10/2017
@version undefined
@type function
*/
Function OGA700REPR()
	Local aArea	      := GetArea()
	Local cIniMsg     := ""
	Local oModelTemp  := nil
	Local lCancelou	  := .F.
	Local cCodCtr     := ""
	Local lUpdCtr     := .f.
	Local lGrvMotiv   := .T.	
		
	If !(N79->N79_STATUS $ "1|2|3|") .OR. (N79->N79_TIPO $ '2|3' .AND. N79->N79_STATUS == '3')
		Help( ,,STR0031,, STR0067 + " " + STR0201, 1, 0 ) //"AJUDA"# "A Opção de Reprovação é somente para negócios com status 'Pendente', 'Trabalhando' ou 'Finalizado'" //Fixações ou cancelamentos finalizados também não são permitidos.
		return(.F.)
	endif
	
	If N79->N79_STATUS == '1'
		cIniMsg := STR0161 + " - " // # "Reprovação de Negócio"
	ElseIf N79->N79_STATUS == '2'
		cIniMsg := STR0162 + " - " // # "Reprovação de Banking"
	ElseIf N79->N79_STATUS == '3'
	    cIniMsg := STR0163 + " - " // # "Reprovação de Banking"
	EndIf

	BEGIN TRANSACTION		
		
        If !__lAutomato
            lGrvMotiv := AGRGRAVAHIS(STR0068,"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,"R", , cIniMsg) = 1 
        EndIf		
		
		If lGrvMotiv //"Informe o motivo da rejeição"
			
			cCodCtr := N79->N79_CODCTR
			lUpdCtr := !Empty(N79->N79_CODCTR) //Se registro de negocio tiver contrato gerado
			
			//delete para SX9 
			RECLOCK("N79", .F.)
				N79->N79_LSTSTS := N79->N79_STATUS //status atual
				N79->N79_STATUS := "4" //cancelado
				if N79->N79_TIPO == '1' //somente novos negócios
				N79->N79_CODCTR := "" 
				N79->N79_GERCTR := "2"
				endif				
			MSUNLOCK()	
			
			//remove o contrato
			IF lUpdCtr .and. N79->N79_TIPO == '1' //somente novos negócios   
			   If !OGX700CNEG(cCodCtr)
			      DisarmTransaction() // Erro na exclusão do pré-contrato
			      Break
			   EndIf 
			ENDIF
			
			lCancelou := .T.
		EndIf
	END TRANSACTION
	
	RestArea(aArea)
 
	If lCancelou 
		oModelTemp := FwLoadModel("OGA700")
		If .Not. oModelTemp:IsActive()
			oModelTemp:SetOperation(MODEL_OPERATION_VIEW)
			oModelTemp:Activate()
		Endif
		
		//retorna saldo dos componentes alocados
		OGX700SLFX(oModelTemp)

		//implementação de delete de fardos
		fCancRes(oModelTemp, .t.)
		
		//CONTRATO FUTURO
		if N79->N79_TIPO = '2' .And. __lCtrRisco						
			N79->(dbSetOrder(1))
			If N79->(dbSeek(FwXfilial('N79') + N79->N79_CODNGC + N79->N79_VERSAO + "2"))					
				OGX702REM(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO)				
			EndIf			
		endif
		
		oModelTemp:DeActivate()
  		oModelTemp:Destroy() 
		
	endif
	
	RestArea(aArea)
return(.t.)

/*{Protheus.doc} OGA700FDNG
Obtem os dados para fixação
@author jean.schulze
@since 25/09/2017
@version undefined
@param oModel, object, descricao
@param cFilNgc, characters, descricao
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGA700FDNG(oModel, cFilNgc, cCodNgc, cVersao, cCodCad, cTipo) //obtem os dados do negócio para criação
	Local oModelN79  := oModel:GetModel("N79UNICO")
	Local oModelN7A  := oModel:GetModel("N7AUNICO")
	Local oModelN7C  := oModel:GetModel("N7CUNICO")
	Local oStruN79   := FWFormStruct( 1, "N79", { |x| !ALLTRIM(x) $ 	'N79_CODNGC, N79_VERSAO, N79_STATUS, N79_TIPO, N79_DATA, N79_QTDNGC, N79_VALOR, N79_VLRUNI, N79_USERNG, N79_DTMULT, N79_APLCAD, N79_CODENT, N79_LOJENT, N79_TPCONT, N79_STCLIE, N79_TPCANC,N79_CODMTV,N79_CODNGC,N79_VRSREL'} ) //campos que não queremos que sejam copiados
	Local oStruN7A   := FWFormStruct( 1, "N7A", { |x| !ALLTRIM(x) $ 	'N7A_CODNGC, N7A_VERSAO, N7A_QTDINT, N7A_USOFIX, N7A_QTDDIS, N7A_TIPRES, N7A_CODRES, N7A_QTDBLQ'} ) //campos que não queremos que sejam copiados
	Local oStruN7C   := FWFormStruct( 1, "N7C", { |x| !ALLTRIM(x) $ 	'N7C_CODNGC, N7C_VERSAO, N7C_CODCAD, N7C_NUMPED, N7C_VLRCOM, N7C_QTAFIX, N7C_VLRFIX, N7C_QTDFIX, N7C_VLRUN2, N7C_VLRUN1, N7C_VLORIG, N7C_HEDGE, N7C_TIPORD, N7C_COMAJU'} ) //campos que não queremos que sejam copiados
	Local nA         := 0
	Local nQtdCadPrc := 0
	Local nQtdPrcNgc := 0
	Local aCompDados := {}
	Local lExistCad  := .f. //controle de inserção de linhas
	Local nVrIndice  := 0
	Local nQtdDispFx := 0
	Local nLinha     := 1	
	Local cTipFixCtr := ""
	Local nQtdBlq	 := 0
		
	Private cAliasN79 := GetNextAlias()
	Private cAliasN7A := GetNextAlias()
	Private cAliasN7C := GetNextAlias()

	if cTipo == '1' //fixação
	   oStruN79:RemoveField("N79_TIPFIX")  	
	   oStruN79:RemoveField("N79_FIXAC")   
	endif

    If !__lCtrRisco
		oStruN7C:RemoveField("N7C_QTDCTR") 
		oStruN7C:RemoveField("N7C_CODBCO") 
		oStruN7C:RemoveField("N7C_OPEFIX") 
	EndIf
	
	//reset permissão add
	oModel:GetModel( "N7CUNICO" ):SetNoInsert( .f. )
	oModel:GetModel( "N7CUNICO" ):SetNoDelete( .f. )
		
	//consulta os dados do Negócio - não se trata de uma cópia literal - tratado -- colocar a quantidade do contrato - adiçoes superiores
	BeginSql Alias cAliasN79

		SELECT N79.*
		   FROM %Table:N79% N79
		 WHERE N79.%notDel%
		   AND N79_FILIAL = %exp:cFilNgc%
		   AND N79_CODNGC = %exp:cCodNgc%
		   AND N79_VERSAO = %exp:cVersao%

	EndSQL

	DbselectArea( cAliasN79 )
	DbGoTop()
	if ( cAliasN79 )->( !Eof() )
		//informa os dados do negócio originador
		For nA:=1 to Len(oStruN79:aFields)
			if !oStruN79:GetProperty(oStruN79:aFields[nA][3], MODEL_FIELD_VIRTUAL) .and. oStruN79:GetProperty(oStruN79:aFields[nA][3], MODEL_FIELD_TIPO) <> "M" .and. !empty(&("( cAliasN79 )->"+oStruN79:aFields[nA][3]))
				oModelN79:LoadValue(oStruN79:aFields[nA][3], iif(oStruN79:GetProperty(oStruN79:aFields[nA][3], MODEL_FIELD_TIPO)  <> "D",  &("( cAliasN79 )->"+oStruN79:aFields[nA][3]), StoD( &("( cAliasN79 )->"+oStruN79:aFields[nA][3])) ) )
			endif
		next nA++
	endif
	
	//atualiza os campos do complete do contrato
	DbselectArea( "NJR" )
	NJR->(DbGoTop())
	NJR->(DbSetOrder(1)) //Filial+Codtr
	if NJR->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_CODCTR")))  
		//vamos atualizar alguns dados do contrato
		oModelN79:SetValue("N79_DESCTR", alltrim(NJR->NJR_DESCRI))
		oModelN79:SetValue("N79_CODENT", alltrim(NJR->NJR_CODENT))
		oModelN79:SetValue("N79_LOJENT", alltrim(NJR->NJR_LOJENT))
		oModelN79:SetValue("N79_CODOPE", alltrim(NJR->NJR_CODOPE))
		oModelN79:SetValue("N79_MODAL" , alltrim(NJR->NJR_MODAL))	
		cTipFixCtr := NJR->NJR_TIPFIX	
	endif				
	
	//para negócios fixos e cancelar o status do cliente sempre será aprovado	
	oModelN79:SetValue("N79_STCLIE" , "4")

	//verifica se ocorreu um erro
	if OGX700ERRO(oModel)
		return .f.
	endif
	
	//consulta as cadencias
	BeginSql Alias cAliasN7A

		SELECT N7A.*
		  FROM %Table:N7A% N7A
		 WHERE N7A.%notDel%
		   AND N7A_FILIAL = %exp:(cAliasN79)->N79_FILIAL%
		   AND N7A_CODNGC = %exp:(cAliasN79)->N79_CODNGC%
		   AND N7A_VERSAO = %exp:(cAliasN79)->N79_VERSAO%
		 ORDER BY N7A_CODCAD

	EndSQL
	
	DbselectArea( cAliasN7A )
	DbGoTop()
	while ( cAliasN7A )->( !Eof() )
		
		if ( cAliasN7A )->N7A_USOFIX == "LBNO"
			( cAliasN7A )->( dbSkip() )		
			Loop
		elseIf cTipo == '1' .AND. Posicione("NNY", 1, (cAliasN79)->N79_FILIAL+(cAliasN79)->N79_CODCTR+(cAliasN7A)->N7A_CODCAD, "NNY_QTDINT")  - OGX700TNN8((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODCTR, (cAliasN7A)->N7A_CODCAD) == 0
			( cAliasN7A )->( dbSkip() )
			Loop
		ElseIf cTipo == '2' .AND. oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/ .AND. OGX700SLDP((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODNGC, (cAliasN79)->N79_VERSAO, (cAliasN7A)->N7A_CODCAD) == 0 .and. OGX700SDCQ((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODCTR, (cAliasN7A)->N7A_CODCAD) == 0
			( cAliasN7A )->( dbSkip() )
			Loop
		EndIf
		
		//verifica a necessidade de criar mais uma linha
		if lExistCad 
		   oModelN7A:AddLine()
		   oModelN7A:GoLine(oModelN7A:Length())
		else
		   lExistCad := .t.
		endif
				
		//apropria os valores
		For nA:=1 to Len(oStruN7A:aFields)
			if !oStruN7A:GetProperty(oStruN7A:aFields[nA][3], MODEL_FIELD_VIRTUAL) .and. oStruN7A:GetProperty(oStruN7A:aFields[nA][3], MODEL_FIELD_TIPO) <> "M" .and. !empty(&("( cAliasN7A )->"+oStruN7A:aFields[nA][3]))
				if !empty(&("( cAliasN7A )->"+oStruN7A:aFields[nA][3]))
					oModelN7A:LoadValue(oStruN7A:aFields[nA][3],  IIF(oStruN7A:GetProperty(oStruN7A:aFields[nA][3], MODEL_FIELD_TIPO) <> "D", &("( cAliasN7A )->"+oStruN7A:aFields[nA][3]), StoD(&("( cAliasN7A )->"+oStruN7A:aFields[nA][3]))))
				endif
			endif
		next nA++
		
		//verifica se o campo deve vir selecionado
		if empty(cCodCad) .or. alltrim(cCodCad) == alltrim((cAliasN7A)->N7A_CODCAD) //selecionado
			nLinha := oModelN7A:GetLine()
			oModelN7A:SetValue("N7A_USOFIX", "LBOK" )
		else //não selecionado
			oModelN7A:SetValue("N7A_USOFIX", "LBNO")
		endif	
		
		//Campo virtual para gravar o N7A_MESBOL e N7A_MESANO
		oModelN7A:SetValue("N7A_VMESAN", AGRMESANO( (cAliasN7A)->N7A_MESANO, 1 ) )
		
		//busca a quantidade a ser fixada de preço
		if cTipo == "1" //fixacao 
			
			nQtdBlq    := OGX700MFIX((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODCTR, (cAliasN7A)->N7A_CODCAD, (cAliasN79)->N79_CODNGC, (cAliasN79)->N79_VERSAO)
			nQtdCadPrc := OGX700TNN8((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODCTR, (cAliasN7A)->N7A_CODCAD) + nQtdBlq
			nQtdDispFx := Iif(__lRegOpcional,nQtdCadPrc,;
				 Posicione("NNY", 1, (cAliasN79)->N79_FILIAL+(cAliasN79)->N79_CODCTR+(cAliasN7A)->N7A_CODCAD, "NNY_QTDINT") - nQtdCadPrc)
					
			oModelN7A:LoadValue("N7A_QTDFIX", nQtdCadPrc) //quantidade de preço fixado
			oModelN7A:LoadValue("N7A_QTDDIS", nQtdDispFx) //quantidade de preço fixado	
			If oModelN7A:HasField("N7A_QTDBLQ") 
				oModelN7A:LoadValue("N7A_QTDBLQ", nQtdBlq) //quantidade de preço fixado	
			EndIf
			
			if oModelN7A:GetValue("N7A_USOFIX") <>  "LBNO"
				nQtdPrcNgc += nQtdDispFx
				oModelN7A:LoadValue("N7A_QTDINT", nQtdDispFx)
							    
			    if oModelN7A:GetValue("N7A_QTDINT") == 0
					oModelN7A:LoadValue("N7A_USOFIX", "LBNO")
			    endif						
			endif		
							
		else //verfica a quantidade de saldo cancelamento
			
			if ( cAliasN79 )->N79_FIXAC == "1" //preço
				nQtdCadPrc := OGX700SLDP((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODNGC, (cAliasN79)->N79_VERSAO, (cAliasN7A)->N7A_CODCAD)
			    nQtdPrcNgc += nQtdCadPrc
				
				oModelN7A:LoadValue("N7A_QTDINT", nQtdCadPrc )
				oModelN7A:LoadValue("N7A_QTDDIS", nQtdCadPrc) //quantidade disponivel para o cancelamento
				
				aAdd(__aFixDisp,{(cAliasN7A)->N7A_CODCAD, nQtdCadPrc}) 
				
				if oModelN7A:GetValue("N7A_QTDINT") == 0
					oModelN7A:LoadValue("N7A_USOFIX", "LBNO")
				endif 					
			else
				if ( cAliasN7A )->N7A_USOFIX == "LBNO"
					oModelN7A:LoadValue("N7A_USOFIX", "LBNO")
				endif
				aAdd(__aFixDisp,{(cAliasN7A)->N7A_CODCAD, 0}) 
			endif
						
		endif
		
		//verifica se ocorreu um erro
		if OGX700ERRO(oModel)
			return .f.
		endif
			
		//consulta os componentes - verifica o tipo de fixação(preço componente) - verifcar a atela do datasul
		BeginSql Alias cAliasN7C

			SELECT N7C.*
			  FROM %Table:N7C% N7C
			 WHERE N7C.%notDel%
			   AND N7C_FILIAL = %exp:(cAliasN79)->N79_FILIAL%
			   AND N7C_CODNGC = %exp:(cAliasN79)->N79_CODNGC%
			   AND N7C_VERSAO = %exp:(cAliasN79)->N79_VERSAO%
			   AND N7C_CODCAD = %exp:(cAliasN7A)->N7A_CODCAD%
			 ORDER BY N7C_ORDEM

		EndSQL

		DbselectArea( cAliasN7C )
		DbGoTop()
				
		while ( cAliasN7C )->( !Eof() )

			//apropria os valores
			For nA:=1 to Len(oStruN7C:aFields)
				if !oStruN7C:GetProperty(oStruN7C:aFields[nA][3], MODEL_FIELD_VIRTUAL) .and. oStruN7C:GetProperty(oStruN7C:aFields[nA][3], MODEL_FIELD_TIPO) <> "M" .and. !empty(&("( cAliasN7C )->"+oStruN7C:aFields[nA][3]))
					oModelN7C:LoadValue(oStruN7C:aFields[nA][3],  &("( cAliasN7C )->"+oStruN7C:aFields[nA][3]) )					
				endif
			next nA++

			//apropria a descrição
			oModelN7C:LoadValue("N7C_DESCRI", ALLTRIM(POSICIONE("NK7",1,XFILIAL("NK7")+( cAliasN7C )->N7C_CODCOM,"NK7_DESABR")) )

			//Descricao da moeda
			oModelN7C:LoadValue( "N7C_DMOECO", AGRMVSIMB(( cAliasN7C )->N7C_MOEDCO  ))
			
			//legenda
			oModelN7C:LoadValue( "N7C_STSLEG", OGX700LEG( ( cAliasN7C )->N7C_TPCALC ))
			
			//hedge
			if POSICIONE("NK7", 1, FwXFilial("NK7") + oModel:GetValue("N7CUNICO","N7C_CODCOM"), iif(cTipFixCtr == "1","NK7_HEDGE","NK7_FHEDGE")) == "1"
				oModelN7C:LoadValue( "N7C_HEDGE", "1")
			endif
				
			//obtem o indice atualizado
			nVrIndice := 0
			dbSelectArea("NK0")
			NK0->( dbSetOrder(1) )

			If NK0->(DbSeek(xFilial("NK0") + (cAliasN7C)->N7C_CODIDX ))
				nVrIndice := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataBase )
			EndIF

			oModelN7C:LoadValue("N7C_VLRIDX", nVrIndice)
						
			if cTipo == "1" //fixacao 
				if oModelN7A:GetValue("N7A_USOFIX") <>  "LBNO"
					//atualiza a quantidade disponivel
					oModelN7C:LoadValue("N7C_QTAFIX", oModelN7A:GetValue("N7A_QTDINT")) //qtd fix
				endif
				oModelN7C:LoadValue("N7C_VLRCOM", iif(ALLTRIM(POSICIONE("NK7",1,XFILIAL("NK7")+( cAliasN7C )->N7C_CODCOM,"NK7_ALTERA")) == '1', nVrIndice, 0 ))
			else
				if ( cAliasN79 )->N79_FIXAC == "1" //preço
					oModelN7C:LoadValue("N7C_QTAFIX",  oModelN7A:GetValue("N7A_QTDINT")) //qtd fix
				else
					oModelN7C:LoadValue("N7C_QTAFIX",  OGX700SLDC((cAliasN79)->N79_FILIAL, (cAliasN79)->N79_CODNGC, (cAliasN79)->N79_VERSAO, (cAliasN7A)->N7A_CODCAD, (cAliasN7C)->N7C_CODCOM )) //qtd fix
				endif
				
				if (cAliasN7C )->N7C_TPCALC <> "R" //somente o que não é resultado
					oModelN7C:LoadValue("N7C_VLRCOM", ( cAliasN7C )->N7C_VLRCOM )	
				endif				
			endif            
			
			//devido a atualização da quantidade, o valor total do componente precisa ser atualizado.
			OGX700LNCP(oModelN7C, oModelN79:GetValue("N79_UMPRC"), oModelN79:GetValue("N79_UM1PRO"),  iif(oModelN79:GetValue("N79_TIPO") $ "2|5" /*Fixação*/ .and. oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/,.t.,.f.),oModelN79:GetValue("N79_CODPRO")) //aplica o valor total
			
			( cAliasN7C )->( dbSkip() )

			if ( cAliasN7C )->( !Eof() ) //ainda vai ter registros
			   oModelN7C:AddLine()			   	 
			   oModelN7C:GoLine(oModelN7C:Length())
			endif

		Enddo
		
		if cTipo == "2" //cancelamento
			//busca os componentes de multa
			aCompDados := OGX700COM( iif(oModelN79:GetValue("N79_OPENGC" ) == "1" /*Compra*/, "C", "V") ,oModelN79:GetValue("N79_CODPRO" ), oModelN79:GetValue("N79_CODSAF" ), oModelN7A:GetValue("N7A_QTDINT"), dDataBase, dDataBase, dDatabase,  oModelN79:GetValue( "N79_MOEDA"  ), .t.  )//gatilha os componentes
			
			//remove componentes com regra
			aCompDados := OGX700RECG(aCompDados, oModel)
			
			if len(aCompDados) > 0 //add linha 
				oModelN7C:AddLine()			   	 
				oModelN7C:GoLine(oModelN7C:Length())
			endif
			
			//insere o campo de multa
			fLstCompN7C(aCompDados, oModel, .f.) //sem reset de componente	
			
			//reset
			oModel:GetModel( "N7CUNICO" ):SetNoDelete( .f. )
			oModel:GetModel( "N7CUNICO" ):SetNoInsert( .f. )
						
		endif
		
		//verifica se ocorreu um erro
		if OGX700ERRO(oModel)
			return .f.
		endif
		
		//busca as fixações já efetuadas
		OGA700GN7M(oModel)
		
		//recalcula os totais
		OGX700CTPP(oModel) 
				
		( cAliasN7A )->( dbSkip() ) //próximo registro
			
		( cAliasN7C )->( dbCloseArea() )
	Enddo
	
	IIF(empty(cCodCad), oModelN7A:GoLine(1),oModelN7A:GoLine(nLinha)) //posiciona na linha marcada
	oModelN7C:Goline(1)
	
	if cTipo == "1" //fixacao 
		//coloca a quantidade de fixação total
		oModelN79:LoadValue("N79_QTDNGC", nQtdPrcNgc )
	else
		if ( cAliasN79 )->N79_FIXAC == "1" //preço
			oModelN79:LoadValue("N79_QTDNGC", nQtdPrcNgc )		
		endif	
		oModelN79:LoadValue("N79_FIXAC" , ( cAliasN79 )->N79_FIXAC)	
	endif
	
	//atualiza valores na variavel principal
	OGX700GTOT(oModel)
	
	//reset close area
	( cAliasN7A )->( dbCloseArea() )
	( cAliasN79 )->( dbCloseArea() )
	
	//verifica se ocorreu um erro
	if OGX700ERRO(oModel)
		return .f.
	endif
	
	//reset permissão add
	oModel:GetModel( "N7CUNICO" ):SetNoInsert( .t. )
	oModel:GetModel( "N7CUNICO" ):SetNoDelete( .t. )
	
		
return(.t.)


/*{Protheus.doc} PrecifComp()
Função do botão F12 ou ativação do modelo
Exibe todos os componentes? 1= SIM/2= NÃO

@author 	ana.olegini
@since 		17/08/2017
@param 		cPergunta, characters, Informa qual pergunte(SX1) mostrar no botão F12
@return 	lRetorno,  logico, Retorno logico .T. ou .F.
*/
Static Function PrecifComp(oModel)
	Local lRetorno 	:= .T.

	fOpen701(oModel)

Return(lRetorno)

/*{Protheus.doc} OGA700VDUM
Função para validação da unidade de medida de preço cadastrada
na aba de Agro de complemento de produto
X3_VALID = N79_CODPRO

@author 	ana.olegini
@since 		28/08/2017
@param 		cProduto,	caractere,	Código do Produto
@return 	lRetorno,	logico, 	Retorno logico .T. ou .F.
*/
Function OGA700VDUM(cProduto, cTabela)
	Local lRetorno 	:= .T.
	Local lAlgodao  := .F.
	Local cUMPRC	:= AgrUmPrc(cProduto)	//Função do fonte AGRXFUN1.PRW
	Local nIt       := 0
	Local oModel	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oModelN7A	:= Nil
	Local oModelN79	:= Nil
	Local nLineN7A	:= 0
	
	If ValType(oModel) != 'U' .AND. oModel:GetId() == 'OGA700'
		oModelN79 := oModel:GetModel('N79UNICO')
		oModelN7A := oModel:GetModel('N7AUNICO')
		nLineN7A := oModelN7A:GetLine()
	EndIf
	
	//*Verifica se produto é algodão
	If AGRTPALGOD(cProduto)
		If ! EMPTY(cTabela)
			//Limpa tabela em tempo de execução.
			M->N79_TABELA := ""
		EndIf
		
		lAlgodao := .T.
		
		If ( FWIsInCallStack("OGA700UPDT") .OR. fVldInsNew(oModel) .or. __cAutoTest $ "CANC|MODF" ) .AND. oModelN79:GetValue('N79_TIPO') $ '1'
			If oModelN7A != Nil
				For nIt := 1 To oModelN7A:Length()
					oModelN7A:GoLine(nIt)
					oModelN7A:ClearField('N7A_FILORG', , .T.) // Se for algodão limpa as filiais da cadencia e os gatilhos
				Next nIt
				
				If nLineN7A != 0
					oModelN7A:GoLine(nLineN7A)
				EndIf
				
				If ValType(oView) != 'U'
					oView:Refresh('VIEW_N7A')
				EndIf	
			EndIf
		EndIf
	EndIf

	//Se Unidade Medida for vazia - valida
	If Empty(cUMPRC)
		Help( , , STR0031, , STR0020, 1, 0 ) //"AJUDA"###"Produto nao possui UM.Preço."
		lRetorno := .F.
	EndIf

	If lRetorno .AND. ! lAlgodao
		lRetorno := OGA700VDTA(cProduto, cTabela)
	EndIf

Return(lRetorno)

/*{Protheus.doc} OGA700VDTA
Função para validação da tabela de classificação de acordo com o produto
X3_VALID = N79_TABELA

@author 	ana.olegini
@since 		28/08/2017
@param 		cProduto,	caractere,	Código do Produto
@param 		cTabela,	caractere,	Código da Tabela de Classificação
@return 	lRetorno,	logico, 	Retorno logico .T. ou .F.
*/
Function OGA700VDTA(cProduto, cTabela)
	Local lRetorno  := .T.

    If __lRegOpcional //valida contrato sem reg. de negócio.
		Return .T.
	EndIf

	If !AGRTPALGOD(cProduto) // verifica se é algodão
		//Se cTabela não for vazio
		IF !Empty(cTabela)									//Ini 1
			//*Tabela de Descontos
			dbSelectArea( "NNI" )
			//**NNI_FILIAL+NNI_CODIGO
			dbSetOrder( 1 )
			If dbSeek( xFilial( "NNI" ) + cTabela )			//Ini 2
				//Se cProduto não for vazio
				If !Empty(cProduto)              			//Ini 3

					//Verifica se produto é igual o da tabela informada (cTabela)
					If NNI->( NNI_CODPRO ) <> cProduto
						//Se produto não for vazio - valida tabela divergente do produto
						If !Empty(cProduto)
							Help( , , STR0031, , STR0021, 1, 0 )	//"AJUDA"###"Tabela nao cadastrada para este produto."
							lRetorno := .F.
						//Se produto for vazio - valida produto sem tabela cadastrada
						ElseIf Empty(cProduto)
							Help( , , STR0031, , STR0022, 1, 0 ) 	//"AJUDA"###"Informar produto compatível com a tabela selecionada."
							lRetorno := .F.
							Return( lRetorno )
						EndIf
					EndIf

					//Valida se a tabela não possui data inicial ou data final menor que a data base
					If ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
						Help( , , STR0031, , STR0023, 1, 0 )    //"AJUDA"###"Tabela fora da validade."
						lRetorno := .F.
					EndIf
				EndIf	//Fim 3
			EndIf	//Fim 2


		EndIF	//Fim 1
	EndIF //lAlgodao
Return( lRetorno )

/*{Protheus.doc} LoadN7A
//Load da Grid N7A para quando em operação de copia
não acrescentar linhas a mais.
@author roney.maia
@since 01/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oObj, object, descricao
@param lCopia, logical, descricao
@type function
*/
Static Function LoadN7A(oObj,lCopia)

	Local aLoadGrid	:= FormLoadGrid(oObj, .T.)
	Local nIt		:= 0
	
	If lCopia // Se for copia
		For nIt := Len(aLoadGrid) To 1 Step -1 // Remove as posições do array de forma decrescente onde comtem os dados de cada linha
			aDel(aLoadGrid, nIt)
			aSize(aLoadGrid, nIt - 1)
		Next nIt
	EndIf

Return aLoadGrid

/*{Protheus.doc} LoadN7C
@author Jonisson.Henckel
@since 22/09/2017
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@type function
*/
Static Function LoadN7C(oGrid)
	Local nOperacao := oGrid:GetModel():GetOperation()
	Local aStruct := oGrid:oFormModelStruct:GetFields()
	Local nAt := 0
	Local aRet := {}

	If nOperacao <> MODEL_OPERATION_INSERT

		aRet := FormLoadGrid( oGrid )

		// Ordena crescente pela sequencia
		If ( nAt := aScan( aStruct, { |aX| aX[MODEL_FIELD_IDFIELD] == 'N7C_ORDEM' } ) ) > 0
			aSort( aRet,,, { |aX,aY| aX[2][nAt] < aY[2][nAt] } )
		EndIf
	EndIf

Return aRet

/*{Protheus.doc} OGA700HDG
//Verifica se os componentes possuem Hedge.
@author roney.maia
@since 24/10/2017
@version 1.0
@return ${return}, ${.T. - Possui Hedge, .F. - Não possui Hedge}
@param aCompsFix, array, oModel da rotina OGA700
@type function
*/
Function OGA700HDG(oModel)

	Local lRet 		:= .F.
	Local oModelN7C	:= oModel:GetModel("N7CUNICO")
	Local oModelN7A	:= oModel:GetModel("N7AUNICO")
	Local nIt		:= 0
	Local nX		:= 0
	
	For nX	:= 1 To oModelN7A:Length() // Percorre as cadencias		
		oModelN7A:GoLine(nX)
		If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue("N7A_USOFIX") != "LBNO"
			For nIt := 1 To oModelN7C:Length() // Percorre os componentes
				If oModelN7C:GetValue("N7C_QTAFIX", nIt) > 0 .and. oModelN7C:GetValue("N7C_HEDGE", nIt) = "1"
					lRet := .t.	
				EndIf
			Next nIt
		EndIf		
	Next nX
	
Return lRet

/*{Protheus.doc} OGA700LAPR
//Função que verifica os parametros de aprovação e banking.
@author roney.maia
@since 25/10/2017
@version 1.0
@return ${return}, ${Array contendo aRet[1][1] = Aprovação, aRet[1][2] = Aprovação Banking}
@param oModel, object, Objeto model ativo da rotina OGA700
@type function
*/
Function OGA700LAPR(oModel)

	Local aAprovacao  	:= SuperGetMV("MV_AGRO003",.F., "1;2;3") //necessidade de aprovar o negócio
	Local lAprNewNgc  	:= .F. // Variável que define se passará pela aprovação de um novo negócio
	Local lAprFix	  	:= .F. // Variável que define se passará pela aprovação de uma fixação
	Local lAprCanc    	:= .F. // Variável que define se passará pela aprovação de um cancelamento
	Local aAprovBank  	:= SuperGetMV("MV_AGRO006",.F., "1;2;3") //necessidade de aprovar o negócio via banking
	Local lAprNNgcBk  	:= .F. // Variável que define se passará pela aprovação de banking em um novo negócio
	Local lAprFixBk	  	:= .F. // Variável que define se passará pela aprovação de banking em uma fixação
	Local lAprCancBk  	:= .F. // Variável que define se passará pela aprovação de banking em um cancelamento
	Local cTipo	 	  	:= oModel:GetModel("N79UNICO"):GetValue("N79_TIPO") // Tipo de negócio
	Local nIt		 	:= 0
	Local aRet 		  	:= {} 

	If !Empty(aAprovacao) // Verifica o parametro dos tipos de aprovações do negócio
		aAprovacao := Separa(aAprovacao, ";")
		For nIt := 1 To Len(aAprovacao)
			If AllTrim(aAprovacao[nIt]) == '1' // Requer aprovação para o Novo Negócio
				lAprNewNgc := Iif(AllTrim(cTipo) == '1', .T., .F.) // Verifica o tipo de nogócio
			ElseIf AllTrim(aAprovacao[nIt]) == '2' // Requer aprovação para a Fixação
				lAprFix := Iif(AllTrim(cTipo) == '2', .T., .F.)
			ElseIf AllTrim(aAprovacao[nIt]) == '3' // Requer aprovação para o Cancelamento
				lAprCanc := Iif(AllTrim(cTipo) == '3', .T., .F.)
			EndIf
		Next nIt
	EndIf
	
	If !Empty(aAprovBank) // Verifica o parametro dos tipos de aprovações do negócio
		aAprovBank := Separa(aAprovBank, ";")
		For nIt := 1 To Len(aAprovBank)
			If AllTrim(aAprovBank[nIt]) == '1' // Requer aprovação para o Novo Negócio
				lAprNNgcBk := Iif(AllTrim(cTipo) == '1', .T., .F.) // Verifica o tipo de nogócio
			ElseIf AllTrim(aAprovBank[nIt]) == '2' // Requer aprovação para a Fixação
				lAprFixBk := Iif(AllTrim(cTipo) == '2', .T., .F.)
			ElseIf AllTrim(aAprovBank[nIt]) == '3' // Requer aprovação para o Cancelamento
				lAprCancBk := Iif(AllTrim(cTipo) == '3', .T., .F.)
			EndIf
		Next nIt
	EndIf
	
	aAdd(aRet, {(lAprNewNgc .or. lAprFix .or. lAprCanc), (lAprNNgcBk .OR. lAprFixBk .OR. lAprCancBk)}) // adiciona a aprovação que atendeu as validações
		
Return aRet

/*{Protheus.doc} OGA700VLMA
//Função responsável por validar o mes/ano da bolsa. 
Tem que ser maior ou igual ao inicio da cadência
@author marcelo.ferrari
@since 24/10/2017
@version 1.0
@param cOrig , Char , Indica o campo de origem (N7A_MESBOL ou N7A_VMESAN)
@type function
*/
Function OGA700VLMA(cOrig)
	Local aArea		:= GetArea()
	Local lRet      := .F.
	Local oModel    := FwModelActive()
	Local oModelN7A	:= oModel:GetModel("N7AUNICO")
	Local cMesBol   := oModelN7A:GetValue("N7A_MESBOL")
	Local cVMesBol  := oModelN7A:GetValue("N7A_VMESAN")
	Local dIniCad   := oModelN7A:GetValue("N7A_DATINI")
	Local cMesEmb   := oModelN7A:GetValue("N7A_MESEMB")
	Local dFimCad   := oModelN7A:GetValue("N7A_DATFIM")
	Local cMesEmbN	:= ""

	If cOrig == 1
	   If !Empty(cMesBol)
	      lRet := cMesBol >= AnoMes(dIniCad) 
	   EndIf
	ElseIf cOrig == 3 
		If !Empty(cMesEmb)
			cMesEmbN := AGRMesAno(cMesEmb, 1)
			If Alltrim(cMesEmbN) == "000000" .OR. !(cMesEmbN == cMesEmb)
				Help( , , STR0031, , STR0164, 1, 0 ) //"AJUDA"###""A data informada deve seguir o modelo de mês/ano. Exemplo: mm/aaaa."
				RestArea(aArea)
				Return .F.
			ElseIf AGRMesAno(cMesEmbN, 2) < AnoMes(dFimCad)
				Help( , , STR0031, , STR0165, 1, 0 ) //"AJUDA"###""O mês de embarque informado é inferior a data final da cadência."
				RestArea(aArea)
				Return .F.
			EndIf
		EndIf
		lRet := .T.	
	Else
	   If !Empty(cVMesBol)
	      cVMesBol := AGRMesAno(cVMesBol, 0)
	      lRet := cVMesBol >= AnoMes(dIniCad) 
	   EndIf
	EndIf
	
	If !lRet
	   Help(" ",1,"N7A_VMESAN") //Help do campo N7A_VMESAN => Campo para informar o mês/ano para bolsa. Informar nos formatos mmm/aaaa ou mm/aaaa.
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*{Protheus.doc} OGA700CPMU
//Verifica nos componentes do negócio se os mesmos possuem
o tipo de multa específico via parâmetro.
@author roney.maia
@since 07/11/2017
@version 1.0
@return ${return}, ${.T. - Possui a multa, .F. - Não possui a multa}
@param oModel, object, Objeto modelo da rotina OGA700
@param cTpMulta, characters, Tipo de multa do componente. 1 - Titulo a pagar, 2 - Titulo a receber; 3 - Pedido de Compra
@type function
*/
Function OGA700CPMU(oModel, cTpMulta)

	Local aArea		  := GetArea()
	Local lRet 		  := .F.
	Local oModelN7C	  := oModel:GetModel("N7CUNICO")
	Local oModelN7A	  := oModel:GetModel("N7AUNICO")
	Local nIt		  := 0
	Local nX		  := 0
    Local nNK7_ALCADA := NK7->(FieldPos("NK7_ALCADA"))
	
	If nNK7_ALCADA > 0
        dbSelectArea('NK7')
        NK7->(dbSetOrder(1))
        NK7->(dbGoTop())
        
        For nX := 1 To oModelN7A:Length()
            oModelN7A:GoLine(nX)
            If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue("N7A_USOFIX") != "LBNO"
                For nIt := 1 To oModelN7C:Length()
                    If NK7->(dbSeek(FwXFilial('NK7') + oModelN7C:GetValue("N7C_CODCOM", nIt))) .AND. NK7->NK7_CALCUL == 'M' ;
                        .AND. NK7->NK7_GERMUL == cTpMulta .AND. oModelN7C:GetValue("N7C_VLTOTC", nIt) > 0 .AND. NK7->NK7_ALCADA == "1"
                        Return .T.
                    EndIf
                next nIt
            EndIf
        Next nX
        
        NK7->(dbCloseArea())
    EndIf
	RestArea(aArea)
	
Return lRet

/*{Protheus.doc} SetMarkN7A
Realiza a marcação dos itens que serão utilizados na fixação
@author jean.schulze
@since 08/11/2017
@version undefined
@param oGrid, object, descricao
@param cFieldName, characters, descricao
@param nLineGrid, numeric, descricao
@param nLineModel, numeric, descricao
@type function
*/
Static Function SetMarkN7A(oGrid,cFieldName,nLineGrid,nLineModel)
	Local oModelN7A := oGrid:GetModel()
	Local cFixMode	:= oGrid:GetModel():GetModel():GetValue("N79UNICO", "N79_FIXAC")
	Local cTipNgc	:= oGrid:GetModel():GetModel():GetValue("N79UNICO", "N79_TIPO")
	Local lAtivo    := ""
	
	if cFieldName == "N7A_USOFIX"
		
		//verifica qual vai ser a propriedade
		lAtivo := iif(oModelN7A:GetValue("N7A_USOFIX") == "LBOK" ,"LBNO", "LBOK")
		
		oModelN7A:SetValue("N7A_USOFIX", lAtivo)	
		
		if !(cFixMode == "2" .and. cTipNgc == "2")
			if lAtivo == "LBNO" //remover a cadencia
			   oModelN7A:SetValue("N7A_QTDINT", 0)
			else
			   oModelN7A:SetValue("N7A_QTDINT", oModelN7A:GetValue("N7A_QTDDIS"))
			endif
		endif
				
		oGrid:Refresh()
	elseif cFieldName == "N7A_QTDINT" .and. !OGA700WQTI()
		return .f. //stop na operacao -  problema no uso do when
	endif
		
return .t.

/*{Protheus.doc} OGA700WQTD
When de Campo de Quantidade
@author jean.schulze
@since 10/11/2017
@version undefined
@type function
*/
Function OGA700WQTD()
	Local oModel    := FwModelActive()
	Local lRet      := .t.
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" 
		 	if oModel:GetValue("N79UNICO","N79_TPCANC") == '2' .AND. !FWIsInCallStack('OGA700MODF')  .AND. !FWIsInCallStack('OGA700CANC') .and. !(__cAutoTest $ "CANC|MODF") //quantidade
		 		lRet := .f.
		 	endIf
		 	if lRet .AND. !FWIsInCallStack('OGA700VDQT') .AND. !FWIsInCallStack('OGA700MODF') .AND. !FWIsInCallStack('OGA700CANC') .and. !(__cAutoTest $ "CANC|MODF") //model de negócio
		 		if oModel:GetValue("N79UNICO","N79_TIPO") <> "1" .and. oModel:GetValue("N79UNICO","N79_FIXAC") == "2" //Fixação/Cancelamento de Componente
		 			lRet := .f.
		 		endif
		 	endif
		endif
	endif	
	
return lRet

/*{Protheus.doc} OGA700WQTI
When de Campo de Quantidade
@author jean.schulze
@since 10/11/2017
@version undefined
@type function
*/
Function OGA700WQTI()
	Local oModel    := FwModelActive()
	Local lRet      := .t.
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" .AND. !FWIsInCallStack('OGA700VDQT')//model de negócio
			if (oModel:GetValue("N79UNICO","N79_TIPO") <> "1" .and. oModel:GetValue("N79UNICO","N79_FIXAC") == "2" .and. oModel:GetValue("N79UNICO","N79_TPCANC") == "1");
               .OR. oModel:GetValue("N79UNICO","N79_TIPO") == "5" //Fixação/Cancelamento de Componente/modificação
				 lRet := .f.
			endif
		endif
	endif	
	
return lRet

/*{Protheus.doc} OGA700WFUT
When dos campos relacionados a contratos futuros
@author rafael.voltz
@since 30/06/2020
@version undefined
@type function
*/
Function OGA700WFUT()
	Local oModel    := FwModelActive()
	Local lRet      := .t.
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" 
			If oModel:GetValue("N79UNICO","N79_TIPO") == "5" //modificacao da fixacao
			    lRet := .f.
			endif
		endif
	endif	
	
return lRet

/*{Protheus.doc} OGA700CHG
//Ao adicionar uma nova linha na N7A, realiza a replicação de componentes e valores para a N7C
@author roney.maia
@since 04/12/2017
@version 1.0
@return ${return}, ${Validação de troca de linha da view}
@param oView, object, Objeto da view
@param cViewID, characters, Id da View que chamou o evento
@type function
*/
Function OGA700CHG(oView, cViewID, oModel)

	Local lRet 		:= .T.

	Local oModelN7C	as object
	Local aFldsN7C	as array

	Local nIt		:= 0
	Local nIb		:= 0
	Local nIdx      := 0
	Local nCom      := 0
	Local nQtd      := 0
	Local nCodCom   := 0
	Local cComp     := ""
	Local aCargN7C	:= {}
	Default oModel := oView:GetModel()

	oModelN7C	:= oModel:GetModel('N7CUNICO')
	nLinBkp     := oModel:GetModel('N7AUNICO'):GetLine()
	aFldsN7C	:= oModelN7C:GetStruct():GetFields()

	oModel:GetModel('N7AUNICO'):GoLine(1) //vou para a primeira

	aCargN7C 		:= oModelN7C:GetData() //pego os dados da N7C	

	oModel:GetModel('N7AUNICO'):GoLine(nLinBkp)	 //volto pra linha que guardei.
	
	If nLinBkp > 1 .and. oModelN7C:IsInserted() .and. oModelN7C:length() != Len(aCargN7C) //Esta sendo adicionado uma nova linha na cadencia(N7A), então carrega dados na grid de componentes(N7C) copiando da primeira cadencia
		/*Libera edição*/
		oModelN7C:SetNoDelete(.F.)
		oModelN7C:SetNoInsert(.F.)
	
		For nIt := 1 To Len(aCargN7C) // 1 Linha

			nIdx    := aScan( aFldsN7C, { |aX| aX[MODEL_FIELD_IDFIELD] == 'N7C_VLRIDX' } )
			nCom    := aScan( aFldsN7C, { |aX| aX[MODEL_FIELD_IDFIELD] == 'N7C_VLRCOM' } )
			nQtd    := aScan( aFldsN7C, { |aX| aX[MODEL_FIELD_IDFIELD] == 'N7C_QTAFIX' } )
			nCodCom := aScan( aFldsN7C, { |aX| aX[MODEL_FIELD_IDFIELD] == 'N7C_CODCOM' } )
			
			For nIb := 1 To Len(aFldsN7C) // Campo 1
				 
				// se posição do campo for o campo quantidade, considerar zero pois na cópia não deve trazer o valor da cadencia anterior
				if nIb == nQtd
					oModelN7C:LoadValue(aFldsN7C[nIb][3], 0)
				elseif nIb = nCom .and. !oModel:GetValue("N79UNICO", "N79_APLCAD")   //quando não replica valores, utilizar o mesmo valor do indice. 
					oModelN7C:LoadValue(aFldsN7C[nIb][3], iif(ALLTRIM(POSICIONE("NK7",1,XFILIAL("NK7")+cComp,"NK7_ALTERA")) == '1', aCargN7C[nIt][1][1][nIdx], 0 ))  //utiliza valor do indice
				else
					if nIb = nCodCom
						cComp := aCargN7C[nIt][1][1][nIb]
					endif				
					oModelN7C:LoadValue(aFldsN7C[nIb][3], aCargN7C[nIt][1][1][nIb])
				end if
				
			Next nIb
			If nIt != Len(aCargN7C)
				oModelN7C:AddLine()
			EndIf
		Next nIt
		
		/*Bloqueia edição*/
		oModelN7C:SetNoDelete(.T.)
		oModelN7C:SetNoInsert(.T.)	
		
        If nIt > 0 .AND. !__lAutomato .AND. !FWIsInCallStack("AGRXCNGC") .AND. ValType(oView) == "O"
			oModelN7C:GoLine(1)			
            oView:ReFresh('VIEW_N7C')			
		EndIf		
		
	EndIf
	
	If !__lAutomato .AND. !FWIsInCallStack("AGRXCNGC") .AND. ValType(oView) == "O"
        oView:GetViewObj("VIEW_N7C")[3]:obrowse:ExecuteFilter()
    EndIf
Return lRet

/*{Protheus.doc} OGA700VALT
Executa o gatilho de inclusão
@author marcelo.wesan
@since 20/12/2017
@version undefined
@type function
*/
Static Function OGA700VALT()
      
   	While  Pergunte('OGA70001', .T.,STR0166)//"Gatilho de Inclusão"
     	If Empty(MV_PAR02)
			Help ('',1, 'OGA700PRO')//OGA700PRO Informe o produto do negócio
			exit
     	ElseIf !Empty(MV_PAR02) // verificar se existe produto para a filial
			DbselectArea( "SB1" )
			SB1->(DbGoTop())
			SB1->(DbSetOrder(1)) //Filial + Produto
			If !SB1->(DbSeek(FwXfilial("SB1")+MV_PAR02))  
			Help ('',1, 'OGA700PRO')//OGA700PRO Informe o produto do negócio
			exit
			ElseIf Empty(MV_PAR04) .and. ValType(MV_PAR04) == 'N'     		 
					Help ('',1, 'OGA700MOE')// OGA700MOE Informe a moeda do negócio             
					exit
			ElseIf Empty(MV_PAR03) .and. ValType(MV_PAR03) == 'N'     		       
				Help ('',1, 'OGA700MOE')// OGA700MOE Informe a moeda do negócio       
				exit
			Else  
				_cProduto   := MV_PAR02
				If valType(MV_PAR04) == "N"
					_cMoeda     := MV_PAR04
				Else
					_cMoeda     := MV_PAR03
				EndIf
				Return .T.
			EndIf	
		EndIf
   
   	EndDo

Return .F.

/*/{Protheus.doc} OGA700ACO
//Função para recalcular as colunas de valores de todos os componentes 
@author rafael.voltz
@since 27/12/2017
@version undefined
@param oModel, object, descricao
@param oModelN7C, object, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
static Function OGA700ACO(oModel, oModelN7C, oModelN7A)
	
	Local oView		    := FwViewActive()
	Local nX            := 0
	Local nY            := 0
	
	while nY <= oModelN7A:Length()
		oModelN7A:GoLine( nY )
		if !oModelN7A:IsDeleted() 
			For nX := 1 to oModelN7C:Length()
			 	oModelN7C:GoLine( nX )
				OGX700GVLR( oModel, "N7C_VLRUN1" )
				OGX700GVLR( oModel, "N7C_VLRUN1" )
				OGX700GVLR( oModel, "N7C_VLTOTC" )
			Next
		EndIf
		nY++
	EndDo
	
	oModelN7A:GoLine( 1 )
	oModelN7C:GoLine( 1 )
	oView:Refresh()

Return 

/*{Protheus.doc} OGA700GN7M
//realiza a apropriação de dados na N7O
@author jean.schulze
@since 26/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
function OGA700GN7M(oModel)
	Local oModelN79  := oModel:GetModel("N79UNICO")
	Local oModelN7A  := oModel:GetModel("N7AUNICO") 
	Local oModelN7C  := oModel:GetModel("N7CUNICO")
	Local oModelN7O  := oModel:GetModel("N7OUNICO")
	Local aSaveRows	 := FwSaveRows(oModel)
	Local cAliasN7O  := GetNextAlias()
	Local nX         := 1
	Local nY         := 1
	Local lCriaLine  := .f.
	Local nPorcApro  := 0
	
	//realizar por cadência selecionada
	//if for fixação e fixação de preço ? -- fixação de componente é 0
	if oModelN79:GetValue("N79_TIPO") == "2" //fixação 
		while nX <= oModelN7C:Length()
			oModelN7C:GoLine(nX)
			
			if oModel:GetOperation() <> 4 //atualizar
				oModelN7O:ClearData() //reset for data
				oModelN7O:InitLine()
			else
				//delete manual
				for nY := 1 to oModelN7O:Length()
					oModelN7O:GoLine(nY)
					if !oModelN7O:IsDeleted()
						oModelN7O:DeleteLine()
					endif	
				next nY
				
				//create line
				oModelN7O:Addline()
				
			endif
			
			nValorComp := 0	
			nQtAprFix  := oModelN7A:GetValue("N7A_QTDINT") 
			
			//reset quantidade e valor fix
			oModelN7C:LoadValue("N7C_VLRFIX",  0) //valor fix
			oModelN7C:LoadValue("N7C_QTDFIX",  0) //qtd fix
								
			if nQtAprFix > 0 //temos componentes fixados para usar
																							
				DbselectArea( "N7M" )
				N7M->(DbGoTop())
				N7M->(dbSetOrder(1))
				if N7M->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_CODCTR")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM")))
					
					nValorComp := 0 //reset value
					lCriaLine  := .f.
					
					while N7M ->( !Eof() )  .and. nQtAprFix > 0 .and. alltrim(N7M->N7M_FILIAL+N7M->N7M_CODCTR+N7M->N7M_CODCAD+N7M->N7M_CODCOM) == alltrim(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_CODCTR")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM"))
						
						//debita a N7M
						if N7M->N7M_QTDSLD > 0 
							
							if lCriaLine // já passou 1
								oModelN7O:Addline()
							endif
																
							nQtUseFix := IIF(nQtAprFix > N7M->N7M_QTDSLD, N7M->N7M_QTDSLD, nQtAprFix )	
							
							oModelN7O:SetValue("N7O_SEQFIX", N7M->N7M_SEQFIX)
							oModelN7O:SetValue("N7O_CODCTR", N7M->N7M_CODCTR)
							oModelN7O:SetValue("N7O_QTDALO", nQtUseFix)
							oModelN7O:SetValue("N7O_VALOR" , N7M->N7M_VALOR)
							oModelN7O:SetValue("N7O_ORINGC", N7M->N7M_CODNGC)
							oModelN7O:SetValue("N7O_ORIVER", N7M->N7M_VERSAO)
							
							nValorComp      += N7M->N7M_VALOR * nQtUseFix
							nQtAprFix       -= nQtUseFix  //reduzo a quantidade que estou usando   
							lCriaLine       := .t.															
							
						endif
						
						N7M ->(dbSkip())	
						
					enddo
						
					//atualizar a qtd fixada e valor fixado
					oModelN7C:LoadValue("N7C_QTDFIX",  (oModelN7A:GetValue("N7A_QTDINT") - nQtAprFix) ) //qtd fix
					oModelN7C:LoadValue("N7C_VLRFIX",  nValorComp / oModelN7C:GetValue("N7C_QTDFIX") ) //valor fix
				
					if oModelN7A:GetValue("N7A_USOFIX") <>  "LBNO"
						//atualiza a quantidade disponivel
						oModelN7C:LoadValue("N7C_QTAFIX", oModelN7A:GetValue("N7A_QTDINT") - oModelN7C:GetValue("N7C_QTDFIX") ) //qtd fix
					endif
					
					//refaz o calculo dos totais
					OGX700LNCP(oModelN7C, oModelN79:GetValue("N79_UMPRC"), oModelN79:GetValue("N79_UM1PRO"),  iif(oModelN79:GetValue("N79_TIPO") $ "2|5" /*Fixação*/ .and. oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/,.t.,.f.),oModelN79:GetValue("N79_CODPRO")) //aplica o valor total
								
				endif				
								
			endif			
			
			nX++ //counter
		enddo
	elseif oModelN79:GetValue("N79_TIPO") == "5" //modificação 
		
		//busca a quantidade disponivel para modificação.
		nQtdTotDis := OGX700SLDP(oModelN79:GetValue("N79_FILIAL"), oModelN79:GetValue("N79_NGCREL"), oModelN79:GetValue("N79_VRSREL"), oModelN7A:GetValue("N7A_CODCAD"))
		
		//verifica se é modificação proporcional ou completa
		if nQtdTotDis <> oModelN7A:GetValue("N7A_QTDINT")
			nPorcApro := ((100 / nQtdTotDis) * oModelN7A:GetValue("N7A_QTDINT") / 100)   
		else 
			nPorcApro := 1
		endif
		
		while nX <= oModelN7C:Length()
			oModelN7C:GoLine(nX)
			
			if oModel:GetOperation() <> 4 //atualizar
				oModelN7O:ClearData() //reset for data
				oModelN7O:InitLine()
			else
				//delete manual
				for nY := 1 to oModelN7O:Length()
					oModelN7O:GoLine(nY)
					if !oModelN7O:IsDeleted()
						oModelN7O:DeleteLine()
					endif	
				next nY
				
				//create line
				oModelN7O:Addline()
				
			endif
			
			nValorComp := 0	
			nQtAprFix  := oModelN7A:GetValue("N7A_QTDINT")
			
			   
			//reset quantidade e valor fix
			oModelN7C:LoadValue("N7C_VLRFIX",  0) //valor fix
			oModelN7C:LoadValue("N7C_QTDFIX",  0) //qtd fix
								
			if nQtAprFix > 0 //temos componentes fixados para usar
				
				//busca somente fixações de outras negociaçãoes				
				BeginSql Alias cAliasN7O
		
					SELECT N7O.*
					  FROM %Table:N7O% N7O
					 WHERE N7O.%notDel%
					   AND N7O_FILIAL = %exp:oModelN79:GetValue("N79_FILIAL")%
					   AND N7O_CODNGC = %exp:oModelN79:GetValue("N79_NGCREL")%
					   AND N7O_VERSAO = %exp:oModelN79:GetValue("N79_VRSREL")%
					   AND N7O_CODCAD = %exp:oModelN7A:GetValue("N7A_CODCAD")%
					   AND N7O_CODCOM = %exp:oModelN7C:GetValue("N7C_CODCOM")%
					   AND (N7O_ORINGC <> %exp:oModelN79:GetValue("N79_NGCREL")% OR N7O_ORIVER <> %exp:oModelN79:GetValue("N79_VRSREL")% )					   	
				EndSQL
				
				DbselectArea( cAliasN7O )
				DbGoTop()
						
				while ( cAliasN7O )->( !Eof() )
					
					if lCriaLine // já passou 1
						oModelN7O:Addline()
					endif	
														
					oModelN7O:SetValue("N7O_SEQFIX", ( cAliasN7O )->N7O_SEQFIX)
					oModelN7O:SetValue("N7O_CODCTR", ( cAliasN7O )->N7O_CODCTR)
					oModelN7O:SetValue("N7O_QTDALO", round(( cAliasN7O )->N7O_QTDALO * nPorcApro, TamSx3("N7O_QTDALO")[2]))
					oModelN7O:SetValue("N7O_VALOR" , ( cAliasN7O )->N7O_VALOR)
					oModelN7O:SetValue("N7O_ORINGC", ( cAliasN7O )->N7O_ORINGC)
					oModelN7O:SetValue("N7O_ORIVER", ( cAliasN7O )->N7O_ORIVER)
								
					nValorComp      += oModelN7O:GetValue("N7O_VALOR") * oModelN7O:GetValue("N7O_QTDALO")
					nQtAprFix       -= oModelN7O:GetValue("N7O_QTDALO") //reduzo a quantidade que estou usando   
					lCriaLine       := .t.	
					
					( cAliasN7O )->( dbSkip() )
				enddo
				( cAliasN7O )->( dbCloseArea() )
				
				//atualizar a qtd fixada e valor fixado
				oModelN7C:LoadValue("N7C_QTDFIX",  (oModelN7A:GetValue("N7A_QTDINT") - nQtAprFix) ) //qtd fix
				oModelN7C:LoadValue("N7C_VLRFIX",  nValorComp / oModelN7C:GetValue("N7C_QTDFIX") ) //valor fix
			
				if oModelN7A:GetValue("N7A_USOFIX") <>  "LBNO"
					//atualiza a quantidade disponivel
					oModelN7C:LoadValue("N7C_QTAFIX", oModelN7A:GetValue("N7A_QTDINT") - oModelN7C:GetValue("N7C_QTDFIX") ) //qtd fix
				endif
				
				//refaz o calculo dos totais
				OGX700LNCP(oModelN7C, oModelN79:GetValue("N79_UMPRC"), oModelN79:GetValue("N79_UM1PRO"),  iif(oModelN79:GetValue("N79_TIPO") $ "2|5" /*Fixação*/ .and. oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/,.t.,.f.),oModelN79:GetValue("N79_CODPRO")) //aplica o valor total
								
			endif			
			
			nX++ //counter
		enddo
		
	endif	
	FwRestRows(aSaveRows)
return .t.


/*{Protheus.doc} OGA700F3EP
F3 Dinâmico do Campo de Entidade
@author jean.schulze
@since 30/01/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGA700F3EP()
	Local oModel  := FwModelActive()
	Local cF3     := "NJ0SA1" //Cliente
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			if oModel:GetValue("N79UNICO","N79_TPCONT") == "2" //prospect
				cF3 := "NJ0SUS"
			elseif oModel:GetValue("N79UNICO","N79_OPENGC") == "1" //Compras
				cF3 := "NJ0SA2" //Fornecedor
			endif
		Endif
	Endif		
	
return cF3

/*{Protheus.doc} OGA700VWHN
When dos campos 
@author jean.schulze
@since 30/01/2018
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@type function
*/
function OGA700VWHN(oField, cField)
	Local oModelN79 := oField:GetModel():GetModel("N79UNICO")
	Local oModelN7C := oField:GetModel():GetModel("N7CUNICO")
	Local lModeView := iif(FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. oModelN79:GetValue("N79_TIPO") $ "2|3|5") , .T. , .F.)//abre em modo resumido
	Local lRet := .t.	
	
	If cField $ "N79_NOMENT|N79_NLJENT"
		if !lModeView .and.  oModelN79:GetValue("N79_TPCONT") <> "3" //somente novos negócios
			if !FWIsInCallStack("OGA700TRIG") //funtion de atualizacao
				lRet := .f.
			endif
		endif 
	EndIf
	
	If cField $ "N79_QTDUM2|N7A_QT2UM"
		If !lModeView .and.  Empty(oModelN79:GetValue("N79_UM2PRO"))
			lRet := .f.		
		EndIf 
	EndIf

	If cField $ "N79_QTDNGC"
		If .Not. Empty(M->N79_CODCTR) .And. oModelN79:GetValue("N79_STCLIE") = "4"  //4 = Aprovado
			lRet := .f.		
		EndIf 
	EndIf
	

	If cField $ "N7A_IDXCTF"
		If oModelN79:GetValue("N79_TIPFIX") = "1"  //4 = Fixo
			lRet := .f.		
		EndIf 
	EndIf

	If cField $ "N7C_VLRCOM"
        If oModelN79:GetValue("N79_TIPO") = "3" .and. oModelN7C:GetValue("N7C_TPCALC") != "M" //Cancelamento e diferente de multa 
           lRet := .f.     
        EndIf 
    EndIf
    
    If cField $ "N79_TOETAP"
		if oModelN79:GetValue("N79_INCOTE") != "EXW" //somente quando for EXW
			lRet := .F.
			oModelN79:ClearField("N79_TOETAP")
			oModelN79:ClearField("N79_DESTPO")
		endif
	EndIf

return lRet

/*{Protheus.doc} OGA700TRIG
Gatilho de atualização dos campos de entidade
@author jean.schulze
@since 30/01/2018
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@param cFieldDt, characters, descricao
@type function
*/
function OGA700TRIG(oField, cFieldDt)
	Local oModel := oField:GetModel()
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local cRetorno  := oModelN79:GetValue(cFieldDt)
	
	if oModelN79:GetValue("N79_TPCONT") <> "3" .and. !empty(oModelN79:GetValue("N79_CODENT")) .and. !empty(oModelN79:GetValue("N79_CODENT"))
		if oModelN79:GetValue("N79_TPCONT") == "2" //prospect
			oModelN79:LoadValue("N79_NOMENT", POSICIONE('SUS',1,XFILIAL('SUS')+oModelN79:GetValue("N79_CODENT")+oModelN79:GetValue("N79_LOJENT"),'US_NOME'))
			oModelN79:LoadValue("N79_NLJENT", POSICIONE('SUS',1,XFILIAL('SUS')+oModelN79:GetValue("N79_CODENT")+oModelN79:GetValue("N79_LOJENT"),'US_NREDUZ'))
		else 
			oModelN79:LoadValue("N79_NOMENT", POSICIONE('NJ0',1,XFILIAL('NJ0')+oModelN79:GetValue("N79_CODENT")+oModelN79:GetValue("N79_LOJENT"),'NJ0_NOME'))
			oModelN79:LoadValue("N79_NLJENT", POSICIONE('NJ0',1,XFILIAL('NJ0')+oModelN79:GetValue("N79_CODENT")+oModelN79:GetValue("N79_LOJENT"),'NJ0_NOMLOJ'))
		endif
	elseif oModelN79:GetValue("N79_TPCONT") <> "3"
		oModelN79:LoadValue("N79_NOMENT", Space(TamSX3("N79_NOMENT")[1]))
		oModelN79:LoadValue("N79_NLJENT", Space(TamSX3("N79_NLJENT")[1]))
		
	endif
	
return cRetorno


/*{Protheus.doc} OGA700WHEN
WHEN de campos
@author marcelo.wesan
@since 05/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
 function OGA700WHEN() 
 	Local aArea 		:= GetArea()
	Local lRet			:= .T. 
	Local oModel    	:= Nil
	Local oModelN79 	:= Nil
	Local cFrete       := ""
 
    oModel    := FWModelActive() // Obtém o Model Ativo
    oModelN79 := oModel:GetModel("N79UNICO") // Obtém o modelo N79
    cFrete    := POSICIONE('SYJ',1,XFILIAL('SYJ')+ oModelN79:GetValue("N79_INCOTE"),'YJ_CLFRETE')                    
	lRet      := cFrete = "1" // Verifica se o icoterm usa frete
    
    RestArea(aArea)
Return(lRet)

/*{Protheus.doc} OGA700APMA
WHEN de campos
@author marcelo.wesan
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/

Function OGA700APMA(cStatusCli, cTemplate, lForce)
    
 Local aArea      := GetArea() 
 Local oModel     := Nil
 Local lRet       := .T.
 Local cProcess   := ""
 Local cProcWork  := ""
 Local cChave     := N79->N79_FILIAL + N79->N79_CODNGC + N79->N79_VERSAO + N79->N79_TIPO	
 Local cFolder    := SuperGetMv("MV_AGRWFFD", .F., STR0091) // # negociacao
 Local cWfId      := ""
 Local cBarras    := If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
 Local cForm      := "" 
 Local cRet       := ""
 Local cAliasN8G  := ""
 Private oProcess := nil
 Private oProces2 := nil

 Default lForce := .F.
 
    If (N79->N79_STCLIE $ "4") .AND. !lForce //aprovado         
		Iif(!__lRegOpcional,MsgInfo( STR0092, STR0079),)//"Este negócio já foi aprovado."
		Return .F.
	EndIf          

	If N79->N79_STATUS = "4"		
		Help( ,,STR0031,,STR0250, 1, 0 ) //"AJUDA" //Aprovação não permitida. Registro de negócio encontra-se rejeitado.
		Return .F.
	EndIf          
	
	If cStatusCli == "4" .AND. Empty(N79->N79_CODENT)
		Help( ,,STR0031,,STR0267, 1, 0 ) //"AJUDA" //Aprovação não permitida. Registro de negócio encontra-se rejeitado.
		Return .F.
	EndIf

	oModel := FwLoadModel("OGA700")		
	oModel:SetOperation(MODEL_OPERATION_UPDATE)

	If oModel:Activate()
	   
	   If !FWIsInCallStack("OGA700FIXA") .and. !FWIsInCallStack("OGA700CANC")
		  If !OGA700ENTI()
		  	  oModel:DeActivate() // Desativa o model
		      oModel:Destroy() // Destroi o objeto do model
		      RestArea(aArea)
			  Return .F.
		  EndIf
	   Endif	   
	   	
	   If cStatusCli == "4" .AND. !lForce //Aprovado
	        If __lAutomato .OR. __lRegOpcional 
				lRet := .T.
			Else
                lRet := AGRGRAVAHIS(STR0074,"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,"A", ,STR0074) = 1 //Deseja aprovar o negocio?
            EndIf
            
            If lRet
                oModel:SetValue("N79UNICO","N79_STCLIE", cStatusCli)                
            EndIf
	   Else
	   		oModel:SetValue("N79UNICO","N79_STCLIE", cStatusCli)	   
	   		If !Empty(cTemplate)
	   			oModel:SetValue("N79UNICO","N79_EMAILT", cTemplate)
	   		EndIf
	   	EndIf	   
		if lRet 
			If oModel:VldData()  // Valida o Model
				oModel:CommitData() // Realiza o commit
				oModel:DeActivate() // Desativa o model
				oModel:Destroy() // Destroi o objeto do model
			EndIf
		else
		   	oModel:DeActivate() // Desativa o model
		   	oModel:Destroy() // Destroi o objeto do model
		EndIf
	    If cStatusCli = "4"
	        cProcess   := POSICIONE("N7L",1,xFilial("N7L")+ N79->N79_EMAILT,"N7L_PWORKF")
		    cProcWork  := POSICIONE("N8G",2,xFilial("N8G") + cChave,"N8G_CODIGO")//posiciona o id do processo workflow
            cRet       := POSICIONE("N8G",2,xFilial("N8G") + cChave,"N8G_PRCRET")
		    If  !Empty(cProcWork)
		       oProcess := TWFProcess():New(cProcess,,allTrim(cProcWork))// se o processo worflow é encontrado, instacia-o para que posso ser acessado
		       
		       oProces2 := TWFProcess():New(cProcess,,allTrim(cRet))
		       
		       cWfId := SubStr(oProcess:oHtml:RetByName("WFMAILID"), 3, Len(oProcess:oHtml:RetByName("WFMAILID"))) // Remove o WF inicial
		      
		       cForm := cBarras + "messenger"+ cBarras + "emp" + Alltrim(SM0->M0_CODIGO) + cBarras + cFolder + cBarras + cWfId + ".htm"
		       
		       cAliasN8G := GetSqlAll("SELECT N8G_CODIGO, N8G_ROTINA, N8G_CALIAS, N8G_CHAVE, N8G_FUNCAO FROM " + RetSqlName("N8G") +;
		 		" N8G WHERE N8G_FILIAL = '" + FwXFilial("N8G") + "' AND D_E_L_E_T_ <> '*' AND N8G_CODIGO = '" + cWfId + "'")
		
				If !(cAliasN8G)->(Eof())
					aRet := { (cAliasN8G)->N8G_ROTINA, (cAliasN8G)->N8G_CALIAS , (cAliasN8G)->N8G_CHAVE , (cAliasN8G)->N8G_FUNCAO }
				EndIf
		
				(cAliasN8G)->(dbCloseArea())
				If Empty(aRet)
			        RestArea(aArea)
		        Else 
					 If File(cForm) .AND. FErase(cForm) < 0
						FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0094 + ": " + cForm , 0, 0, {}) // # "Falha ao apagar formulário workflow de resposta."
					 EndIf
					 oProcess:Finish() // finaliza o processo workflow
				     oProces2:Finish() // finaliza o processo workflow
				EndIf
			 EndIf
          EndIf
	   EndIf

   RestArea(aArea)
	
return(.t.)
/*{Protheus.doc} OGA700MAIL
Função para envio de e-mail via WorkFlow
@author rafael.voltz
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGA700MAIL()

	Local cEmails 	:= "" // E-mails de envio, ou seja, os destinatários. ! Não obrigatório
	Local cBody	 	:= "" // Corpo da mensagem, caso exista. ! Não obrigatório
	Local cChaveFt	:= "N79_CODNGC = '" + N79->N79_CODNGC + "'" // Chave para trazer somente os dados referente ao registro posicionado. ! Obrigatório
	Local cProcess	:= "" // 001 Código do processo. ! Obrigatório
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cMsg		:= ""
	Local cChave 	:= N79->N79_FILIAL + N79->N79_CODNGC + N79->N79_VERSAO + N79->N79_TIPO	
	Local cEmailT   := ""	
	Local lRet      := .T.
	Local cProcCod  := ""
	Local lCancelou := .F.
	Local cBarras 	:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cFolder	:= SuperGetMv("MV_AGRWFFD", .F., STR0091) // # negociacao
	Local cForm		:= ""
	Local cProcWf	:= ""
	Local oProcess	:= Nil                                                                                            
	
	/*Caso exista contrato gerado, permitir reenviar e-mail somente quando status for pré-contrato ou previsto */
	If !Empty(N79->N79_CODCTR) ///pré-contrato ou previsto
		NJR->(DbSetOrder(1))
		If NJR->(DBSeek(xFilial("NJR")+N79->N79_CODCTR))
			If ((NJR->NJR_MODELO=='2' .Or. NJR->NJR_MODELO=='3') .And. NJR->NJR_STATUS=='P') .Or. NJR->NJR_MODELO=='1'
			Else
			    MsgInfo( STR0086, STR0079) //Somente é permitido enviar e-mail para Contratos com status de Pré-contrato ou Previsto.
			    Return 
			EndIf  
		EndIf
	EndIf	 
		
	//1=Nao Enviado;2=Aguardando;3=Pendente de Ajuste;4=Rejeitado;5=Aprovado	
	If  !(N79->N79_STATUS $ "2|3|6") .OR. N79->N79_TIPO != "1" //somente é permitido enviar para o status 2=Trabalhando;3=Completo;6=Completar	
		MsgInfo( STR0078, STR0079) //"A situação do negócio não permite o envio de e-mail. Somente nas situações Completar, Completo ou Trabalhando e tipo 'Novo Negócio' essa funcionalidade está disponível."                                                                                                                                                                                                                                                                                                                                          
	Else
		If Empty(N79->N79_EMAILT)
			lRet 	   := Pergunte("OGA700MAIL")
			cProcess   := MV_PAR01
			cTemplate  := MV_PAR02	
		Else
			cProcess   := POSICIONE("N7L",1,xFilial("N7L") + N79->N79_EMAILT,"N7L_PROCES")
			cProcWf	   := POSICIONE("N7L",1,xFilial("N7L") + N79->N79_EMAILT,"N7L_PWORKF") // Processo workflow utilizado
			cTemplate  := N79->N79_EMAILT
		EndIF
		
		If lRet
			cEmails := OGA700DEST()

			If !Empty(cProcWf) // Se existe um template workflow para o negocio em questão e o mesmo possue um processo workflow
				cProcCod := GetDataSql("SELECT N8G_CODIGO FROM " + RetSqlName("N8G") +;
								 " WHERE N8G_FILIAL = '" + FwXFilial("N8G") + "' AND D_E_L_E_T_ = ' ' AND N8G_CHAVE='" + cChave + "'")
			
				If !Empty(cProcCod) // Verificação de processo workflow pendente
					If MsgYesNo(STR0095) // # "Há um processo de e-mail workflow pendente de aprovação. Deseja encerrar o processo ao enviar um novo e-mail ?"
						lCancelou := .T. // Variavel de controle para o caso de ocorrer error ou cancelamento no envio de e-mail, para posteriormente deletar o vinculo de processo
					Else
						RestArea(aArea)
						Return
					EndIf
				EndIf
			EndIf
			
			aRet := OGX017(cEmails, cBody, , cChaveFt, cProcess, , , , /*cRemetent*/, cTemplate, .F., .T., {"OGA700", "N79", cChave, "OGA700WFRT()", {N79->N79_CODCOR, N79->N79_CODENT, N79->N79_CODNGC}}) // Chama a tela de envio de email, passando os emails e o corpo da mensagem, alias e a chave referente ao filtro.
			
			If len(aRet) > 0 .AND. Len(aRet[1]) == 4 .AND. aRet[1][4] == .F. // Se foi fechado a janela de envio de e-mail
				RestArea(aArea)
				Return
			EndIf

			If len(aRet) > 0

				If lCancelou // Se existe um processo workflow pendentente e foi selecionado a opção sim para finalizar

					oProcess := TWFProcess():New(cProcWf,,allTrim(cProcCod)) // Instancia o processo em execução
					cForm := cBarras + "messenger"+ cBarras + "emp" + Alltrim(SM0->M0_CODIGO) + cBarras + cFolder + cBarras + AllTrim(cProcCod) + ".htm"

					oProcess:Finish() // Finaliza o processo

					If File(cForm) .AND. FErase(cForm) < 0 // Apaga o formulário referente ao processo
						FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0094 + ": " + cForm , 0, 0, {}) // # "Falha ao apagar formulário workflow de resposta."
					EndIf

					// ##### Deleta o vinculo do processo com o workflow #####
					OGX017N8G(cProcCod, 1, , "D")
				EndIf

				If .NOT. Select("SX2") > 0 // Se a SX2 estiver fechada, reabre a mesma
				     dbSelectArea("SX2")
				EndIf
				
				 cEmailT := aRet[1][3]
		
				 cMsg += STR0087 + AllTrim(aRet[1][1]) + CRLF //DESTINATÁRIO
			     cMsg += STR0088 + AllTrim(aRet[1][2]) + CRLF //ASSUNTO
			     AGRGRAVAHIS(,,,,{"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,"K",cMsg})		
			Else
				Alert(STR0081) //Não foi possível enviar e-mail. 
			EndIf
			
			//Gera pré-contrato, mesmo caso tenha havido erro no envio do e-mail
			If !OGA700APMA("2", cEmailT, .T.) //Aguardando retorno
				Alert( STR0080) //Não foi possível gerar o pré-contrato.
			EndIf
		EndIf
     EndIf
	 RestArea(aArea)
Return 

/*{Protheus.doc} OGA700DEST
Função para buscar os destinatários de e-mails.
@author rafael.voltz
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function OGA700DEST()
	Local aArea    := getArea()
	Local cEmails  := ""
	Local cCliente := ""
	Local cLoja    := ""
	Local cParAgro015 := SuperGetMv('MV_AGRO015', , .T.) //Define que o Corretor é o destinatário padrão do e-mail de aceite
 
	If cParAgro015 .AND. !Empty(N79->N79_CODCOR)
		cEmails  := POSICIONE("SA2",1,xFilial("SA2") + N79->N79_CODCOR, "A2_EMAIL")
	EndIf
	
	If Empty(cEmails)
		Do Case
			Case N79->N79_TPCONT == "1" //Entidade
				cCliente := POSICIONE("NJ0",1,xFilial("NJ0") + N79->N79_CODENT + N79->N79_LOJENT,"NJ0_CODCLI")
				cLoja    := POSICIONE("NJ0",1,xFilial("NJ0") + N79->N79_CODENT + N79->N79_LOJENT,"NJ0_LOJCLI")
				cEmails  := POSICIONE("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_EMAIL")		
				
			Case N79->N79_TPCONT == "2" //Prospect			
				cEmails  := POSICIONE("SUS",1,xFilial("SUS") + N79->N79_CODENT + N79->N79_LOJENT,"US_EMAIL")		  
		EndCase
	EndIf

	//email interessados estiver preenchido, então adiciona na lista de destinatários
	If !Empty(N79->N79_EMAILA)
		cEmails := AllTrim(cEmails)
		cSep := IIF( (Len(cEmails) > 0 .AND. !(SUBSTR(cEmails, LEN(cEmails), 1) $ ";") ) , "" , ";" )
		cEmails := AllTrim(cEmails) + cSep + AllTrim(N79->N79_EMAILA)
	EndIf
	
	RestArea(aArea)

Return cEmails

/** {Protheus.doc} OGA700Leg
Legenda para o status do negócio com o cliente.

@param.:  Nil
@return:  Nil
@author:  Rafael Völtz
@since.:  02/02/2018
@Uso...:  OGA700Leg - Negócio
*/
Function OGA700Leg()
	Local oLegenda  :=  FWLegend():New()     // Objeto FwLegend.
		
	oLegenda:Add( "N79_STCLIE=='1'"  , "RED"         , X3CboxDesc( "N79_STCLIE", "1" )   ) //"Não Enviado"
	oLegenda:Add( "N79_STCLIE=='2'"  , "BLUE"    	 , X3CboxDesc( "N79_STCLIE", "2" )   ) //"Aguardando
	oLegenda:Add( "N79_STCLIE=='3'"  , "WHITE"       , X3CboxDesc( "N79_STCLIE", "3" )   ) //"Pendente de Ajuste"	
	oLegenda:Add( "N79_STCLIE=='4'"  , "GREEN"  	 , X3CboxDesc( "N79_STCLIE", "4" )   ) //"Aprovado"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return(.T.)

/*{Protheus.doc} OGA700STU
Verifica o Status do negócio
@author jean.schulze
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Function OGA700STU(oModel)
	Local cStatus       := "1"
	Local lHedge	  	:= .F. // Verifica se algum componente da negociação possui hedge
	Local aAprova	  	:= {}  // Verifica aprovação de negócio e banking, através de parametros e o tipo de negócio
	Local lMultaPg		:= .F.
	Local lCmp          := OGA700EMTP(oModel)	
	
	lMultaPg  := OGA700CPMU(oModel, "1") //verifica se é uma multa à pagar
	lHedge	  := OGA700HDG(oModel) // Verifica se algum componente da negociação possui hedge
	aAprova	  := OGA700LAPR(oModel) // Verifica aprovação de negócio e banking, através de parametros e o tipo de negócio

    if FWIsInCallStack("OGA700APVA") .or. FWIsInCallStack("OGX700ALCD" ) // FWIsInCallStack("OGX700ALCD" )  - Indica que nao irá passar o tit. de canc. a pagar pelo ctrole de alçadas.	
		if oModel:GetValue("N79UNICO","N79_STATUS") = "1"
			if lCmp == .F. 
				cStatus := "6" //COMPLETAR			
			elseif oModel:GetValue("N79UNICO","N79_TIPO") == "3" .and. lMultaPg
				cStatus := "5" //CANCELAMENTO
			elseif aAprova[1][2] .AND. lHedge
				cStatus := "2" //TRABALHANDO
			else		
				cStatus := "3" //COMPLETO
			endif

		else
			if lCmp == .F. 
				cStatus := "6" //COMPLETAR
			elseif oModel:GetValue("N79UNICO","N79_STATUS") = "5" .and. aAprova[1][2] .AND. lHedge
				cStatus := "2" //TRABALHANDO
			else		
				cStatus := "3" //COMPLETO
			endif
		endif			
	else
		if lCmp == .F. 
			cStatus := "6" //COMPLETAR
		elseif !empty(oModel:GetValue("N79UNICO","N79_FLUIG")) .and. oModel:GetOperation() == 3 //inclusão do fluig -  aprovação padrão
			cStatus := "1" //PENDENTE
		elseif oModel:GetValue("N79UNICO","N79_STATUS") $ "1|6" .and. aAprova[1][1]
			cStatus := "1" //PENDENTE
		elseif oModel:GetValue("N79UNICO","N79_STATUS") = "2" .AND. aAprova[1][2] .AND. lHedge 
			cStatus :=  "2" //TRABALHANDO
		elseif oModel:GetValue("N79UNICO","N79_STATUS") $ "1|3" .And. lMultaPg == .T.  .AND. !FWIsInCallStack("OGX701AALC")
			cStatus := "5"   //cancelamento				
		elseif lCmp == .T. .AND. !(oModel:GetValue("N79UNICO","N79_STATUS") = "3")
			if oModel:GetValue("N79UNICO","N79_STATUS") == "4" .AND. lMultaPg 
				cStatus := "4" //REJEITADO			
			elseif aAprova[1][2] .AND. lHedge
				cStatus := "2" //TRABALHANDO
			else
				cStatus := "3" //COMPLETO
			endIf
		elseif lCmp == .T.
			cStatus :=  "3" //COMPLETO
		endif
	endif

	If cStatus == "3" .AND. Empty(oModel:GetValue("N79UNICO","N79_CODENT")) //Mesmo se estiver configurado com apr. auto, irá deixar pendente 
		cStatus := "1" //PENDENTE
	EndIf

Return cStatus		

/*{Protheus.doc} OGA700EMTP
Verifica o Complete
@author jean.schulze
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Function OGA700EMTP(oModel)
   Local oModelN79 	:= Nil
   Local oModelN7A  := Nil 
   Local iCont      := 0
   Local lContinua  := .T.
   Local nQtdCaden  := 0
 
   oModelN79 := oModel:GetModel( "N79UNICO" )
   oModelN7A := oModel:GetModel( "N7AUNICO" )
  
   if oModel:GetValue("N79UNICO","N79_TIPO") == "1" 
	   If (Empty(oModel:GetValue("N79UNICO","N79_QTDNGC")) .or. oModel:GetValue("N79UNICO","N79_QTDNGC") = 0) .and. oModel:GetValue("N79UNICO","N79_TIPO") == '1'    
	        Return lContinua := .F.
	   Elseif oModel:GetValue("N79UNICO", "N79_TIPFIX") == "1" .and. oModel:GetValue("N79UNICO", "N79_FIXAC") == "1"  //Fixo - Preço - Fixação
			If Empty(oModelN79:GetValue("N79_VALOR")) .or. oModelN79:GetValue("N79_VALOR") < 0 // Se não foi informado o valor
				Return lContinua := .F.
			EndIf    
	   EndIf

	   If Empty(oModel:GetValue("N79UNICO", "N79_CODENT")) .OR. Empty(oModel:GetValue("N79UNICO", "N79_LOJENT"))
	   		Return lContinua := .F.
	   EndIf
	    
	   For iCont := 1 to oModelN7A:Length()
	    	oModelN7A:GoLine( iCont )
	    	If lContinua 
	    		If !oModelN7A:IsDeleted()  //.and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" //sem delete e marcado para fixar
					
	    			lCadSelec := .t. //informa que temos cadencia selecionada
					
					If Empty(oModelN7A:GetValue( "N7A_DATFIM" )) //ok
						Return lContinua := .F.
					ElseIf Empty(oModelN7A:GetValue( "N7A_DATINI" )) //ok
				    	Return lContinua := .F. 
					EndIf

					nQtdCaden += oModelN7A:GetValue("N7A_QTDINT")
					
				EndIf
				
				//soma as quantidades para arrumar em momento futuro.
				
				
			endif	
		next iCont	
	     
	    if lContinua
			IF !lCadSelec
				Return lContinua := .F.
			elseif nQtdCaden <> oModelN79:GetValue("N79_QTDNGC") 
				Return lContinua := .F.
			EndIf
		endif
	endif
Return lContinua

/*{Protheus.doc} OGA700WFRT
//Função de retorno do workflow para atualização do negócio.
@author roney.maia
@since 08/02/2018
@version 1.0
@param oProcess, object, descricao
@param aRet, array, descricao
@type function
*/
Function OGA700WFRT(oProcess, aRet)
	Local aArea		:= GetArea()
	Local aAreaN8G  := N8G->(GetArea())
	Local aAreaNJR  := NJR->(GetArea())
	Local aAreaN79  := N79->(GetArea())	
	Local cRetSts	:= oProcess:oHtml:RetByName("cBtRetorno") // Retorno do botão de formulario
	Local cWfId		:= oProcess:oHtml:RetByName("WFMAILID") // id do processo
	Local cObs		:= DecodeUTF8(oProcess:oHtml:RetByName("cObs")) // Campo de obeservação do formulario de retorno, decodifica para utf8 devido a caracters especiais
	Local cMsg		:= ""
	Local cCRLF		:= CHR(13)+CHR(10)
	Local cChaveN8G := ''
	Local lAtuNJR   := .f.

	If cRetSts == "4"// Monta a mensagem do historico
		cMsg += STR0082 + ": " + SubStr(cWfId, 3, Len(cWfId)) + cCRLF + STR0083 + ". " + STR0084 + ": " + cRetSts + cCRLF + cObs // # Processo # Realizado a aprovação # Opção
	ElseIf cRetSts == "3"
		cMsg += STR0082 + ": " + SubStr(cWfId, 3, Len(cWfId)) + cCRLF + STR0085 + ". " + STR0084 + ": " + cRetSts + cCRLF + cObs // # Processo # Realizado a solicitação de Ajuste
	EndIf
		
	AGRGRAVAHIS(,,,"W",{aRet[2], aRet[3] ,"W", cMsg}) // Grava o historico	
					
	dbSelectArea("N79") // Realiza a alteração de status conforme retorno do formulário
	N79->(dbSetOrder(1))
	If N79->(dbSeek(aRet[3])) .AND. "2" $ N79->N79_STCLIE // Alterado em 03/07/2018 por Tiago Dantas da Cruz - Problema com Compartilhamento de tabela X2_MODO=C|X2_MODOUN=C|X2_MODOEMP=C
	//If N79->(dbSeek(AllTrim(aRet[3]))) .AND. "2" $ N79->N79_STCLIE // Se estiver em status aguardando chamar a rotina de aprovação de e-mail para gerar o contrato
		
		cChaveN8G := N79->N79_FILIAL + N79->N79_CODNGC + N79->N79_VERSAO + N79->N79_TIPO
		
		//Removido o transactio pois estava causando travamento
		//BEGIN TRANSACTION
	 		If SimpleLock("N79", .F.)		 		
	 			N79->N79_STCLIE := cRetSts // Valor do status informado
	 			N79->(MsUnlock())

		 		If N79->N79_STATUS == '3'
					dbSelectArea("NJR") // Realiza a alteração de status conforme retorno do formulário
					NJR->(dbSetOrder(1))
					If dbSeek(xFilial("NJR")+N79->N79_CODCTR)
				 		If SimpleLock("NJR", .F.)		
				 		 						 			
				 			If cRetSts == '4'				 	
				 				NJR->NJR_MODELO := '2'
				 				NJR->NJR_STATUS := 'P'
				 			EndIf
				 			
				 			NJR->(MsUnlock())
				 			
				 			lAtuNJR := .t.
				 		EndIf
					EndIf
				EndIf
	 		EndIf

	 		cChaveN8G := N79->N79_FILIAL + N79->N79_CODNGC + N79->N79_VERSAO + N79->N79_TIPO
	 		If !lAtuNJR //Só gera a 'inconsistência' (grava o status) na N8G caso não tenha conseguido gravar as 2 tabelas (N79 e NJR)
	 			//cChaveN8G := xFilial("N8G")+N79->N79_CODNGC
				dbSelectArea("N8G")
				N8G->(dbSetOrder(2))
				If dbSeek(xFilial("N8G")+cChaveN8G)
					If RecLock("N8G", .F.)
						N8G->N8G_STATUS := cRetSts
						N8G->(MsUnlock())
					EndIf
				EndIf
			Else
				OGX017N8G(cChaveN8G, 2, , "D") // Deleta o vinculo da tabela N8G
	 		EndIf

			oProcess:Finish()

 		//END TRANSACTION
		 
	EndIf

	RestArea(aArea)
	RestArea(aAreaN8G)
	RestArea(aAreaNJR)	
	RestArea(aAreaN79)

Return .T.

/*{Protheus.doc} AtuStatus
Função que varre a tabela N8G para verificar se algum
status de Negocio ficou pendente de alteração.

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     07/08/2018
@Uso:       OGA700 - Novos Negócios
*/
Static Function AtuStatus()
	Local aAreaN8G  := N8G->(GetArea())
	Local aAreaNJR  := NJR->(GetArea())
	Local aAreaN79  := N79->(GetArea())
	Local nTam      := TamSX3("N8G_FILIAL")[1]+TamSX3("N8G_CODIGO")[1]
	Local cAliasN8G := GetNextAlias()
	Local lAtuNJR   := .f.
	Local cChaveN8G := ''

	cQry := " SELECT N8G_CHAVE, N8G_STATUS, R_E_C_N_O_ REGISTRO "
	cQry += "   FROM " + RetSqlName('N8G')
	cQry += "  WHERE N8G_ROTINA  = 'OGA700' "
	cQry += "    AND N8G_CALIAS  = 'N79' "
	cQry += "    AND D_E_L_E_T_  = ' ' "
	cQry += "    AND N8G_STATUS <> ' ' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasN8G, .F., .T. )

	dbSelectArea(cAliasN8G)
	dbGoTop()
	While (cAliasN8G)->(!Eof())

		lAtuNJR   := .f.

		dbSelectArea("N79")
		dbSetOrder(1)
		If dbSeek(SubStr((cAliasN8G)->N8G_CHAVE,1,nTam))
			If SimpleLock("N79",.f.)
				N79->N79_STCLIE := (cAliasN8G)->N8G_STATUS
				N79->(MsUnlock())

		 		If N79->N79_STATUS == '3'
					dbSelectArea("NJR") // Realiza a alteração de status conforme retorno do formulário
					NJR->(dbSetOrder(1))
					If dbSeek(xFilial("NJR")+N79->N79_CODCTR)
				 		If SimpleLock("NJR", .F.)		 		
				 						 			
				 			If N79->N79_STCLIE == '4'	
				 				NJR->NJR_MODELO := '2'
				 				NJR->NJR_STATUS := 'P'
				 			EndIf
				 			
				 			NJR->(MsUnlock())

				 			lAtuNJR := .t.
				 		EndIf
					EndIf
				EndIf

				If lAtuNJR //Só atualiza a N8G (retirando a 'inconsistência') caso a N79 e NJR tenham sido atualizadas.
					dbSelectArea("N8G")
					dbGoTo((cAliasN8G)->REGISTRO)
					If RecLock("N8G",.f.)
						N8G->N8G_STATUS := " "
						N8G->(MsUnlock())

						cChaveN8G := N79->N79_FILIAL + N79->N79_CODNGC + N79->N79_VERSAO + N79->N79_TIPO
						OGX017N8G(cChaveN8G, 2, , "D") // Deleta o vinculo da tabela N8G
					EndIf
				EndIf

			EndIf
		EndIf

		(cAliasN8G)->(dbSkip())
	End

	(cAliasN8G)->(dbCloseArea())

	RestArea(aAreaN8G)
	RestArea(aAreaNJR)	
	RestArea(aAreaN79)

Return .t.

/*/{Protheus.doc} OGA700BCO
//Validacao do banco com msgalert para ser exibido em tela
@author carlos.augusto
@since 31/08/2018
@version undefined
@type function
/*/
Function OGA700BCO()
	Local lRet		:= .T.

	If .Not. Empty(M->N7C_CODBCO)
		DbselectArea( "SA6" )
		SA6->(dbSetOrder(1))
		if .Not. SA6->(DbSeek(FwXFilial("SA6") + M->N7C_CODBCO))
			lRet := .F.
			MsgAlert( STR0099, STR0079) //Atencao,"Banco não cadastrado."
		endif
	EndIf

Return lRet


/*{Protheus.doc} OGA700TKUP
Funcao para criar reserva especifica.
@author jean.schulze
@since 10/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
*/
Function OGA700TKUP(oView)
	Local oModel 	:= oView:GetModel()
	Local oModelN79	:= oModel:GetModel('N79UNICO')
	Local oModelN7A	:= oModel:GetModel('N7AUNICO')
	Local cReserva  := oModelN7A:GetValue("N7A_CODRES")
	
	Private _cSafraCad 	:= alltrim(oModelN79:GetValue("N79_CODSAF"))
	Private _cCodOgCli	:= alltrim(oModelN79:GetValue("N79_CODENT"))
	Private _cCodOgLoj	:= alltrim(oModelN79:GetValue("N79_LOJENT"))
	Private _cCdResN79  := "" //grava o codigo da reserva
	
	dbSelectArea("DXP")
	dbSetOrder(1)
	If !empty(cReserva) .and. DXP->(dbSeek(FwXFilial("DXP")+cReserva))
		//*Para alteração
		cTitulo  := STR0169
		nRetorno := FWExecView (cTitulo, "AGRA720", MODEL_OPERATION_UPDATE,/*oDlg*/ , {||.T.}, /*bOk*/ ,12/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
	Else
    	//*Para inclusão
    	cTitulo  := STR0170
    	nRetorno := FWExecView (cTitulo, "AGRA720", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},{|oView| fGrvCodRes(oView)} /*bOk*/ ,12/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
    Endif

	If nRetorno == 0 //clicou em OK
		oModelN7A:SetValue("N7A_CODRES",_cCdResN79)
		oModelN7A:SetValue("N7A_TIPRES","2") //reserva de negócio
	EndIf
	
return .t.

/*{Protheus.doc} fGrvCodRes
Trata para obter o campo da Reserva no execview
@author jean.schulze
@since 10/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
*/
Static Function fGrvCodRes(oView)
	Local oModelDXP := oView:GetModel()
	Local cCodRes   := oModelDXP:GetModel("DXPMASTER"):GetValue("DXP_CODIGO")
	
	//atibui o código da reserva
	_cCdResN79 := cCodRes 

return .t.

/*{Protheus.doc} fCancRes
Função para o controle e delete de reservas do negócio
@author jean.schulze
@since 10/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Static Function fCancRes(oModel, lUpdate)
	Local oModelN79  := oModel:GetModel( "N79UNICO" )
	Local oModelN7A  := oModel:GetModel( "N7AUNICO" )
	Local nX         := 0
	Local cCodRes    := ""
	Local nExecResv  := 1 //1=Pergunta,2=sim, 3=Não
		
	Default lUpdate    := .f. //manipular erros de SX9
	
	//se for novo negócio e algodao
	If oModelN79:GetValue("N79_TIPO") == "1" .and. AGRTPALGOD(oModelN79:GetValue("N79_CODPRO")) 
		For nX := 1 To oModelN7A:Length()
			oModelN7A:Goline(nX)
							
			//verifica se trata-se de uma reserva do negócio
			if !empty(oModelN7A:GetValue("N7A_CODRES")) .and. oModelN7A:GetValue("N7A_TIPRES") == "2" .and. nExecResv < 3
				
				//pergunta se gostaria de deleta
				if nExecResv == 1 //primeira verificação
					If MsgYesNo(STR0168) //"Há reserva vinculada! Deseja excluir?"
						nExecResv := 2 //sim		 
					Else
						nExecResv := 3 //não
					EndIf
				endif
				
				if nExecResv < 3
					//apropria para uso correto
					cCodRes  := oModelN7A:GetValue("N7A_CODRES")
					
					//verifica a necessidade de remover o vinculo
					if lUpdate
						dbSelectArea("N7A")
						N7A->(dbSetOrder(1))
						if N7A->(dbSeek(FwXFilial("N7A")+oModelN79:GetValue("N79_CODNGC")+oModelN79:GetValue("N79_VERSAO")+oModelN7A:GetValue("N7A_CODCAD")))
							RECLOCK("N7A", .F.)
								N7A->N7A_CODRES := "" //remove o vinculo
								N7A->N7A_TIPRES := "" //reset
							N7A->(MSUNLOCK())		
						endif
					endif
					
					dbSelectArea("DXP")
					DXP->(dbSetOrder(1))
					If DXP->(dbSeek(FwXFilial("DXP")+cCodRes))
						
						//vamos dar o delete
						oModel := FwLoadModel("AGRA720") // Carrega o modelo da rotina de Reservas
						oModel:SetOperation(5)	//5 - Delete
						
						//Verificando se o Activate Falhou
				   		If !oModel:Activate()
							cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
							Help( ,,STR0031,,cMsg, 1, 0 ) //"AJUDA"
							Return(.F.)
						EndIf
						
						//Commit do modelo - delete
						if !oModel:CommitData()
							cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
							Help( ,,STR0031,,cMsg, 1, 0 ) //"AJUDA"
							Return(.F.)
						endif
						
					endif
				endif	
			endif
				
			
		Next nX		
	endif
return .t.

/*{Protheus.doc} fValidResv
Valida os dados da reserva inseridos.
@author jean.schulze
@since 15/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
static function fValidResv(oModel)
	Local oModelN7A := oModel:GetModel("N7AUNICO")
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local lRet      := .t.
	Local nQtdReser := 0
	
	if !empty(oModelN7A:GetValue("N7A_CODRES")) 
		
		//busca os dados da reserva
		dbSelectArea("DXP")
		DXP->(dbSetOrder(1))
		If DXP->(dbSeek(FwXFilial("DXP")+oModelN7A:GetValue("N7A_CODRES")))
			
			//verifica a safra
			if !empty(DXP->DXP_SAFRA) .and. alltrim(DXP->DXP_SAFRA) <> alltrim(oModelN79:GetValue("N79_CODSAF"))
				Help( ,,STR0031,,STR0171+oModelN7A:GetValue("N7A_CODRES")+STR0172, 1, 0 ) //" está com safra diferente da Negociação."
				Return(.F.)
			endif
			
			//verifica o cliente
			if !empty(DXP->DXP_CLIENT) .and. !empty(DXP->DXP_LJCLI) .and. (alltrim(DXP->DXP_CLIENT) <> alltrim(oModelN79:GetValue("N79_CODENT")) .or. alltrim(DXP->DXP_LJCLI) <> alltrim(oModelN79:GetValue("N79_LOJENT")) )
				Help( ,,STR0031,,STR0171+oModelN7A:GetValue("N7A_CODRES")+STR0173, 1, 0 ) //" está com entidade/loja diferente da Negociação."
				Return(.F.)
			endif
			
			//verifica o tipo == somente reserva especifica
			if DXP->DXP_TIPRES == "1" //reserva de contrato 
				Help( ,,STR0031,,STR0171+oModelN7A:GetValue("N7A_CODRES")+STR0174, 1, 0 ) //" é uma reserva de contrato. Para vincular uma reserva ao negócio a mesma deve ser uma reserva específica."
				Return(.F.)
			endif
			
			//busca a quantidade conforme os dados da DXQ
			dbSelectArea("DXQ")
			DXQ->(dbSetOrder(1))
			If DXQ->(dbSeek(FwXFilial("DXQ")+DXP->DXP_CODIGO))
				
				while alltrim(DXQ->DXQ_FILIAL+DXQ->DXQ_CODRES) == alltrim(DXP->DXP_FILIAL+DXP->DXP_CODIGO)	 
					nQtdReser += DXQ->DXQ_PSLIQU
					DXQ->(dbSkip())
				enddo
				
			endif
			
			if nQtdReser > oModelN7A:GetValue("N7A_QTDINT")
				//a quantidade da reserva não está sendo respeitada.
				Help( ,,STR0031,,STR0171+oModelN7A:GetValue("N7A_CODRES")+STR0175 + alltrim(str(oModelN7A:GetValue("N7A_QTDINT"))) + STR0176 + alltrim(str(nQtdReser))+ ".", 1, 0 ) //" possui quantidade superior a quantidade da cadência. Quantidade cadência: "
				Return(.F.)
			endif
			
		else
			//nao achou a reserva - erro
			Help( ,,STR0031,,STR0171+oModelN7A:GetValue("N7A_CODRES")+STR0177, 1, 0 ) //" não foi encontrada."
			Return(.F.)
		endif	
	endif
	
return lRet

/*/{Protheus.doc} LoadUmCpy
Função executada apenas na opção de cópia, para recarregar a 
UM caso tenha sido alterada
@author marcos.wagner
@since 17/10/2018
@version undefined
@return lRetorno, logic, verdadeiro ou falso
@param oModel, object, Modelo de dados
@type function
/*/
Static Function LoadUmCpy( oModel )
	Local lCopy	   := (Type("_lOGA700CP") == "L" .AND. _lOGA700CP)
	Local aAreaSB5 := SB5->(GetArea())

	If lCopy
		dbSelectArea("SB5")
		dbSetOrder(1)
		If dbSeek(FwxFilial("SB5")+N79->N79_CODPRO)
			If N79->N79_UMPRC <> SB5->B5_UMPRC
				oModel:SetValue("N79UNICO", "N79_UMPRC", SB5->B5_UMPRC )
			EndIf
		EndIf

		RestArea(aAreaSB5)
	EndIf

Return .t.


/*/{Protheus.doc} VldEnt
	Verifica se a entidade possui fornecedor cadastrado para gerar a multa a Pagar
	@type  Static Function
	@author mauricio.joao
	@since 05/11/2018
	@version 1.0
	@param cCodEnt, Char, Codigo da Entidade
	@param cLojEnt, Char, Loja da Entidade
	@param cTipoCtr, Char, Tipo do Contrato (2 - Venda/1 - Compra)
	@return lRet, Logical, validação
	/*/
Static Function VldEnt( cCodEnt as char , cLojEnt as char, cTipoCtr as char )
	
	Local lRet      as logical

	lRet 		:= .T.
	aAreaNJ0 	:= NJ0->(GetArea())
		
	NJ0->(dbSetOrder(1))
	If NJ0->(dbSeek( xFilial( "NJ0" ) + cCodEnt + cLojEnt ))
		If cTipoCtr == "2"
			If Empty(NJ0->NJ0_CODCLI)
				lRet := .F.
				Help(, , STR0178, , STR0179, 1, 0, , , , , , {STR0217+cCodEnt+STR0181+cLojEnt}) //"Cadastro de Entidade" ## "O cadastro de Entidade está incomplento, favor verificar." ## "Informar um Cliente para a Entidade Codigo: " ## " Loja: "			
			EndIf
		Else
			If Empty(NJ0->NJ0_CODFOR) 			
				lRet := .F.
				Help(, , STR0178, , STR0179, 1, 0, , , , , , {STR0180+cCodEnt+STR0181+cLojEnt}) //"Cadastro de Entidade" ## "O cadastro de Entidade está incomplento, favor verificar." ## "Informar um Fornecedor para a Entidade Codigo: " ## " Loja: "			
			EndIf
		Endif
	EndIf
	
	RestArea(aAreaNJ0)	

Return lRet

/*/{Protheus.doc} OGA700Est(cStatus)
Define a cor do farol da Legenda
@type  Static Function
@author Christopher.miranda
@since 07/11/2018
@version 1.0
@param cStatus, caractere, Conteudo do campo N82_STATUS, N82_STAPES, N82_STAQUA posicionado
@return cStatus, caractere, nome do icone de legenda  ser exibido.
@example
(examples)
@see (links_or_references)
/*/
Static Function OGA700Est(cStatus)

	Do Case
		Case cStatus == "1"
		cStatus := "BR_CINZA" 		//Novo 
		Case cStatus == "2"
		cStatus := "BR_AMARELO" //Fixação
		Case cStatus == "3"
		cStatus := "BR_VERMELHO" //Cancelamento
		Case cStatus == "4"
		cStatus := "BR_LARANJA" //Estorno Alteração
		Case cStatus == "5"
		cStatus := "BR_AZUL" //Alteração
		Case cStatus == "6"
		cStatus := "BR_VERDE" //Estorno Execução
		Case cStatus == "7"
		cStatus := "BR_VERDE_ESCURO" //Mudança Execução
	EndCase
    
Return cStatus

/*/{Protheus.doc} OGA700Legen()
Exibe a Legenda
@type  Static Function
@author Christopher.miranda
@since 07/11/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGA700Legen()

	Local oLegenda := FWLegend():New() // Objeto FwLegend.

	oLegenda:Add("","BR_CINZA" 	 	 , X3CboxDesc("N79_TIPO",'1')) // "Novo"
	oLegenda:Add("","BR_AMARELO" 	 , X3CboxDesc("N79_TIPO",'2')) // "Fixação"
	oLegenda:Add("","BR_VERMELHO" 	 , X3CboxDesc("N79_TIPO",'3')) // "Cancelamento"
	oLegenda:Add("","BR_LARANJA" 	 , X3CboxDesc("N79_TIPO",'4')) // "Estorno Alteração"
	oLegenda:Add("","BR_AZUL" 	 	 , X3CboxDesc("N79_TIPO",'5')) // "Alteração"
	oLegenda:Add("","BR_VERDE" 	 	 , X3CboxDesc("N79_TIPO",'6')) // "Estorno Execução"
	oLegenda:Add("","BR_VERDE_ESCURO", X3CboxDesc("N79_TIPO",'7')) // "Mudança Execução"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return .T.

/*{Protheus.doc} fTrgN79CVT
Função gatilho de Campo de Quantidade convertida
@author Christopher.miranda
@since 11/12/2018
@version undefined
@type static function
*/
Static Function fTrgN79CVT()
	Local aAreaAnt 	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oModelN79 := oModel:GetModel( "N79UNICO" )
	Local nQtUM		:= 0
	
	cUMOrig 	:= oModelN79:GetValue("N79_UM1PRO")
	cProduto	:= oModelN79:GetValue("N79_CODPRO")
	nQntIni		:= oModelN79:GetValue("N79_QTDNGC")
	DbselectArea( "SB1" )
	SB1->(DbGoTop())
	SB1->(DbSetOrder(1)) //Filial + Produto
	If SB1->(DbSeek(FwXfilial("SB1")+cProduto))  
		cUMDest := B1_SEGUM	
	
		nQtUM		:= AGRX001(cUMOrig, cUMDest, nQntIni, cProduto)

		oModelN79:LoadValue("N79_QTDUM2", nQtUM)
		oModelN79:LoadValue("N79_UM2PRO", cUMDest)
		
	endif 
	
	RestArea(aAreaAnt)
Return( nQtUM )

/*/{Protheus.doc} OGA700CTRF
//Executa Selecao de Contratos Futuros. Mas antes valida se eh necessario
@author carlos.augusto
@since 06/12/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OGA700CTRF(cFilN79, cCodNeg, cVersao, cOperacao)
	Local oModel 	:= Nil	

    Default cFilN79     := ""
    Default cCodNeg     := ""
    Default cVersao     := ""
    Default cOperacao   := ""
    
    If cOperacao == "S" //Selecionar contratos futuros
        N79->(dbSetOrder(1)) 
        If N79->(dbSeek(cFilN79 + cCodNeg + cVersao))      	
            If N79->N79_TIPO = "2"
                If N79->N79_STATUS == "2"
                    oModel := FwLoadModel("OGA700")
                    oModel:SetOperation(MODEL_OPERATION_UPDATE)            
                    If oModel:Activate()
                        If !OGX700NCT(oModel)
                            OGX702(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO,2, N79->N79_OPENGC)
                        else
                            AGRHELP(STR0194,STR0200,"") //Vinc. Ctr Futuro. "Os contratos futuros já foram vinculados."
                        EndIf
                        oModel:DeActivate() // Desativa o model
                        oModel:Destroy() // Destroi o objeto do model
                    EndIf                        
                else
                    AGRHELP(STR0194,STR0259,"") //"Situação da negociação não permite vincular contratos futuros. O vínculo somente é permitido na situação de 'Trabalhando'."
                EndIf
            Else
                AGRHELP(STR0194,STR0202,"") //"O tipo de negócio deve ser fixação."
            EndIf
        EndIf  
    elseif cOperacao == "R" //remover vínculos contratos futuros
        If N79->N79_TIPO == "2" .and. N79->N79_STATUS == "2"
            If OGX702TEMFUT(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO)
                If MsgYesNo(STR0260) //"Deseja remover todos os contratos futuros vinculados a essa fixação?"
                    If OGX702REM(N79->N79_FILIAL, N79->N79_CODNGC, N79->N79_VERSAO)
                        MsgInfo(STR0262) //"Os contratos futuros foram removidos da fixação."
                    Else        
                        AGRHELP(STR0194, STR0261, "")  //"Houve um problema e não possível remover os contratos futuros da fixação."
                    EndIf
                EndIf
            else
                AGRHELP(STR0194,STR0263, "") //"Não foram encontrados contratos futuros vinculados a essa fixação."
            EndIf
        Else
            AGRHELP(STR0194,STR0264, "") //""Ação permitida somente para registros do tipo 2-Fixação e que esteja com status 2-Trabalhando."
        EndIf
    else
        AGRHELP(STR0194, STR0258, "") //"Operação inválida. As opções são disponíveis são S - Seleção de contratos ou R - Remover contratos futuros."
    EndIf
Return 

/*/{Protheus.doc} OGA700CTRF
//Encontra plano de venda relacionado e verifica se o saldo a vender foi ultrapassado 
@author carlos.augusto
@since 06/12/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function OGA700PV(cFilNEG, cSafra, cGrProd, cCodPro, cData, lTemPV )
	Local nVlVenPV := 0	
	
	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DO DCO
	
	//--ALTERA A FILIAL CORRENTE PARA A FILIAL Do DCO
	cFilAnt := cFilNEG 	
	
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT N8W_QTPRVE"
	cQuery += " FROM " + RetSqlName("N8W") + " N8W "
	cQuery += " INNER JOIN " + RetSqlName("N8Y") + " N8Y ON N8Y.D_E_L_E_T_ = '' AND N8Y.N8Y_FILIAL = N8W.N8W_FILIAL AND N8Y.N8Y_CODPLA = N8W.N8W_CODPLA " //AND N8Y.N8Y_ATIVO = '1' -- sem dic
	cQuery += " WHERE N8W.N8W_FILIAL = '" + FwXfilial("N8W") + " '"
	cQuery += " AND   N8W.N8W_SAFRA  = '" + cSafra + "' "
	cQuery += " AND ((N8W_CODPRO = '"  +  cCodPro + "' OR N8W_GRPROD = '" + cGrProd + "') OR (N8W_CODPRO = ' ' AND N8W_GRPROD = '" + cGrProd + "' ))"
	cQuery += " AND   N8W.N8W_MESANO = '" + cData + "' "
	cQuery += " AND   N8W.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY  N8W.N8W_FILIAL, N8W.N8W_SAFRA, N8W.N8W_CODPRO, N8W.N8W_GRPROD "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	
	While (cAliasQry)->(!Eof())
		lTemPV := .T.
		nVlVenPV += (cAliasQry)->N8W_QTPRVE
		(cAliasQry)->(DbSkip())					
	Enddo
	(cAliasQry)->(DbcloseArea())
	
	//--RETORNA COM A FILIAL DE ORIGEM 
	cFilAnt := cFilOri
	
Return nVlVenPV


/*/{Protheus.doc} OGA7002UND
//Trata segunda unidade de medida
@author mauricio.joao
@since 14/02/2019
@version 1.0
/*/
Static Function OGA7002UND(oModel,nTotalAtual,xValor,lSomando)
	
	Local oModelN79 as object
	Local oModelN7A as object
	Local cUnPrc 	as char
	Local cProduto  as char		
	Local cUMOrig   as char
	Local nCalc		as numeric
	Local nRet		as numeric
	Local lDelet    as logical
	
	oModelN79 		:= oModel:GetModel( "N79UNICO" )
	oModelN7A       := oModel:GetModel( "N7AUNICO" )
	cUnPrc 			:= ""
	cProduto		:= oModelN79:GetValue("N79_CODPRO")
	cUMOrig			:= oModelN79:GetValue("N79_UM1PRO")		

	If oModelN7A:IsModified()
		If !oModelN7A:IsDeleted()
			lDelet := .T.
		Endif
	Endif

	If !lDelet
		cUnPrc 	:= fwfldget("N79_UMPRC")
	Else
		cUnPrc 	:= oModelN79:GetValue("N79_UMPRC")
	Endif
	
	//Se algum campo estiver vazio, ele retorna zero na conversão
	If Empty(oModelN79) .OR. Empty(cUnPrc) .OR. Empty(cProduto) .OR. Empty(cUMOrig)
		
		nRet  := 0
	Else	
			
		//retorno o valor calculado
		nCalc := AGRX001(cUMOrig, cUnPrc, xValor, cProduto)	

		/*
		Quando se usa formula o AddCalc roda duas vezes, uma com a somatória dos valores, e outra subtraindo. 
		*/

		If lSomando
			nRet := nTotalAtual + nCalc //atual + conversão
		Else
			nRet := nTotalAtual - nCalc //atual - conversão
		EndIf	
		
	EndIf	
	
Return nRet


/*{Protheus.doc} OGA700VQTC
Válida a quantidade do contrato futuro (Grid)
@author marcos.wagner
@since 13/02/2019
@version undefined
@type function
*/
Static Function OGA700VQTC()

	Local oModel  as object
	Local lRet    as logical
	Local nQtdCtr as numeric	
	Local nValor  as numeric	
	Local nMax	  as numeric
	Local nMin	  as numeric
	Local nRowN7A as numeric

	oModel  	:= FwModelActive()
	lRet    	:= .F.
	nRowN7A		:= oModel:GetModel("N7AUNICO"):GetLine()
	/*
	se o calculo for zerado não deixo passar, porque provavelmente 
	não foi digitado o indice da bolsa na linha da prev de entrega.
	*/
	If !Empty(oModel:GetModel("N7AUNICO"):GetValue('N7A_IDXCTF',nRowN7A))
	
		//Retorno a quantidade de contrato futuro
		nQtdCtr := OGX700TQCT(oModel, "N7C_QTDCTR" )

		If !Empty(nQtdCtr)
			
			//Pego o maior valor permitido
			nMax := Ceiling(nQtdCtr)
			//pego o menor valor permitido
			nMin := Int(nQtdCtr)
			//pego o valor que foi colocado no campo
			nValor := oModel:GetModel('N7CUNICO'):GetValue('N7C_QTDCTR')
		
			//se o valor digitado ser o max ou min do nqtdctr, passa.
			If (nValor == nMax) .OR. (nValor == nMin)
				lRet := .T.
			EndIf	
		
		EndIf
	Else
		//ATENCAO ## Não foi possivel calcular a Quantidade de Contrato Futuro ## Preencher indice de Contrato futuro na cadencia:
		 Help(NIL, NIL,STR0031, NIL, STR0213, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0214,oModel:GetModel("N7AUNICO"):GetValue('N7A_CODCAD',nRowN7A)})
	EndIf
	 
Return lRet


/*{Protheus.doc} BuscaBolsa
Busca o valor cadastrado para a Bolsa
@author marcos.wagner
@since 13/02/2019
@version undefined
@type function
*/
Static Function BuscaBolsa()
	Local aAreaN8U   := N8U->(GetArea())
	Local oModel     := FwModelActive()
	Local oModelN7C  := oModel:GetModel( "N7CUNICO" )
    Local nX         := 1

	//Atualiza o campo com q quantidade de contrato na Bolsa
	If __lCtrRisco .and. oModel:GetValue("N79UNICO", "N79_TIPO") $  '2|3'
		For nX := 1 To oModelN7C:Length()
            oModelN7C:GoLine(nX)
            If oModelN7C:GetValue("N7C_HEDGE") == '1'
                oModelN7C:LoadValue( "N7C_QTDCTR", OGX700TQCT(oModel, "N7C_QTDCTR" ) )
            EndIf
        Next nX
        oModelN7C:GoLine(1)
	EndIf

	RestArea(aAreaN8U)

Return .t.


/*{Protheus.doc} fAlgodao
Busca o valor do Códgio do produto
@author Christopher.miranda
@since 14/02/2019
@version undefined
@type function
*/
Static Function fAlgodao(oModel)
	Local aArea   := GetArea()
	Local lRet	  := .T.
	Local cProd	  := N79->N79_CODPRO

	if fVldInsNew(oModel) //inclusao
		If Posicione("SB5",1,fwxFilial("SB5")+_cProduto,"B5_TPCOMMO") != '2'
			lRet := .F.
		endif
	else
		If Posicione("SB5",1,fwxFilial("SB5")+cProd,"B5_TPCOMMO") != '2'
			lRet :=.F.
		endif
	endif

	RestArea(aArea)

Return (lRet)

/*{Protheus.doc} OGA700INB
Busca o valor do Códgio do produto
@author gustavo.pereira
@since 14/02/2019
@version undefined
@type function
*/
Static Function OGA700INB()

	Local oModel     := FwModelActive()
	Local cAliasQry  := "" 
	Local cQuery     := ""
	Local nCount     := 0
	Local cBolsa     := ""
	Local cRet       := ""

	If (oModel:GetOperation() == 3 .And. FWIsInCallStack("OGA700") .And. !FWIsInCallStack("OGA700CANC")) .or. (oModel:GetOperation() == 3 .and. __lAutomato .and. __cAutoTest != "CANC")
		
		
		cAliasQry  := GetNextAlias()
		cQuery := "SELECT N8U_CODBOL"
		cQuery += " FROM " + RetSqlName("N8U") + " N8U "		
		cQuery += " WHERE N8U.N8U_FILIAL  = '" + FwXfilial("N8U") + " '"
		cQuery += " AND   N8U.N8U_CODPRO  = '" + _cProduto + "' "	
		cQuery += " AND   N8U.D_E_L_E_T_ = ' ' "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		
		While (cAliasQry)->(!Eof())
			nCount++

			If nCount > 1
				Exit
			Endif
			
			cBolsa := (cAliasQry)->N8U_CODBOL

			(cAliasQry)->(DbSkip())					
		Enddo
	
		If nCount == 1 
			cRet := cBolsa
		Endif
		
		(cAliasQry)->(DbcloseArea())
	Endif

Return cRet

/*/{Protheus.doc} OGA700ICPQ
	Inicialização para os campos N79_CLASSP e N79_CLASSQ
	para alterar o padrão do dicionario quando venda
	@type  Function
	@author claudineia.reinert
	@since 26/06/2020
	/*/
Static Function OGA700ICPQ()

	Local oModel     := FwModelActive()
	Local nOperation := oModel:GetOperation()
	Local cRet       := "1"

	If nOperation == MODEL_OPERATION_INSERT
		If valType(MV_PAR05) == "N" .AND. MV_PAR05 = 2
			//VIA dicionario sempre carrega 1=destino, na venda padrão será 2=origem
           cRet := "2"
		EndIf
	EndIf


Return cRet

/*/{Protheus.doc} OGA700FLB
	Filtro Por Produto
	@type  Function
	@author Christopher.miranda
	@since 28/02/2019
	/*/
 Function OGA700FLB()

	Local oModel    := FwModelActive()
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local cFiltro := "@D_E_L_E_T_ = ' '"

	If FWIsInCallStack("OGA700")
		If !Empty(oModelN79:GetValue("N79_CODPRO"))
			cFiltro += " AND N8U_CODPRO = '"+ AllTrim(oModelN79:GetValue("N79_CODPRO")) + "'"
		EndIf
	endif

Return(cFiltro)

/*/{Protheus.doc} OGA700FLCTR
	Filtro de produtos e com vencimento maior ou igual ao mês de embarque
	@type  Function
	@author Christopher.miranda
	@since 28/02/2019
	/*/
 Function OGA700FLCTR()

	Local oModel    := FwModelActive()
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local oModelN7A := oModel:GetModel("N7AUNICO")
	Local cFiltro := "@D_E_L_E_T_ = ' '"

	If FWIsInCallStack("OGA700")
		If !Empty(oModelN79:GetValue("N79_CODPRO"))
			cFiltro += " AND NK0_CODPRO = '"+ AllTrim(oModelN79:GetValue("N79_CODPRO")) + "'"
		EndIf
		If !Empty(oModelN7A:GetValue("N7A_MEMBAR")) 
			cFiltro += " AND NK0_MESBOL >= '"+ oModelN7A:GetValue("N7A_MEMBAR") + "'"
		EndIf
	endif

Return(cFiltro)

/*/{Protheus.doc} OGA700VLD
	Validação para o campo bolsa referencia
	@type  Function
	@author Christopher.miranda
	@since 28/02/2019
	/*/
Function OGA700VLD()

	Local lRet 		:= .T.
	Local cAliasQry := GetNextAlias()
	Local cQuery 	:= " "
	Local oModel 	:= FwModelActive()
	Local oModelN79 := oModel:GetModel( "N79UNICO" )

	If oModelN79:GetValue("N79_TIPFIX") != '1' //não pode ser tipo fixo. 
		If TableInDic("N8U") 

			cQuery := "SELECT * "
			cQuery += " FROM " + RETSQLNAME('N8U') + ' N8U '
			cQuery += " WHERE N8U.N8U_FILIAL = '"+ FWxFilial('N8U') + "'"
			cQuery += "   AND N8U.N8U_CODBOL = '"+ oModelN79:GetValue("N79_BOLSA") + "'"
			cQuery += "   AND N8U.N8U_CODPRO = '"+ oModelN79:GetValue("N79_CODPRO") + "'"
			cQuery += " AND N8U.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
			dbSelectArea(cAliasQry)
			If (cAliasQry)->(Eof())
				lRet := .f.
			Endif
			(cAliasQry)->( dbCloseArea() )
		EndIf
	EndIf

return(lRet)

/*{Protheus.doc} OGA700ENTI
Reprovar negócio
@author marcos.wagner
@since 09/03/2019
@version undefined
@type function
*/
Function OGA700ENTI()
	Local lRet := .t.
	Local oModel	:= FwModelActive()
	Local oModelN79 

	If FWIsInCallStack("OGA700APVA")
		If valtype(oModel) <> "U" .AND. Empty(oModel:GetValue("N79UNICO","N79_CODENT")) 
			oModelN79 := oModel:GetModel( "N79UNICO" )
			oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0232, STR0231, "", "")//"O campo 'Entidade' não foi informado!" ### "O campo 'Entidade' deverá ser informado." ###
			lRet := .F.
		ElseIf valtype(oModel) == "U" .AND. Empty(N79->N79_CODENT)
			MsgInfo( STR0231, STR0232 ) // "O campo 'Entidade' deverá ser informado." ### "O campo 'Entidade' não foi informado!"
			lRet := .F.
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} OGA700VTO
//TODO Descrição auto-gerada.
@author brunosilva
@since 26/02/2019
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@param cField, characters, descricao
@type function
/*/
Static Function OGA700VTO(oField,cField)
	Local aArea    	:= GetArea()
	Local oModel   	:= FwModelActive()
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local cTpOper  	:= ""
	Local cFilOrg  	:= oModelN79:GetValue("N79_FILORG")
	
    If oModelN79:HasField("N79_TOETAP")
        cTpOper  	:= oModelN79:GetValue("N79_TOETAP") //FwFldGet("N79_TOETAP")
        If !Empty(cTpOper)
            If FWModeAccess("N92", 1) == "E"
                cTpOper := POSICIONE("N92",1,cFilOrg+cTpOper,"N92_DESCTO")
            else 
                cTpOper := POSICIONE("N92",1,fwxFilial("N92")+cTpOper,"N92_DESCTO")
            endif 
        EndIf
    EndIf
	
	RestArea(aArea)
	
Return cTpOper


/*/{Protheus.doc} OGA700N92
//Responsável por retornar os tipos de operação de romaneio filtrados pelo produto
// e somente do tipo 4 - Saída.
@author brunosilva
@since 26/02/2019
@version 1.0

@type function
/*/
Function OGA700N92(cToEtap)
	Local cFiltro 	:= ""
	Local oModel	:= FwModelActive()
	Local oModelN79	:= oModel:GetModel( "N79UNICO" )
	Local cCodPro	:= oModelN79:GetValue("N79_CODPRO")
	Local cFilOrg	:= oModelN79:GetValue("N79_FILORG")
	
	cFiltro += "@ D_E_L_E_T_ = ' ' "
	cFiltro += "AND N92_TIPO = '4' "
	cFiltro += "AND ((N92_CODIGO IN(SELECT NCB_CODTO FROM " + RetSqlName('NCB') + " "
	cFiltro += "   WHERE D_E_L_E_T_ = ' ' "
	cFiltro += "   AND NCB_FILIAL = '" + cFilOrg + "' "
	cFiltro += "   AND NCB_CODPRO = '" + cCodPro + "')) "
	cFiltro += "   OR (N92_CODIGO NOT IN "
	cFiltro += "  	(SELECT NCB_CODTO FROM " + RetSqlName('NCB') + " WHERE NCB_FILIAL = '" + cFilOrg + "' ) ) )"
	
return cFiltro

/*/{Protheus.doc} OGA700N92V
// Responsável por validar 
@author brunosilva
@since 26/02/2019
@version 1.0
@param cToEtap, characters, descricao
@type function
/*/
Function OGA700N92V(cToEtap)
	Local lRet 	:= .F.
	Local cQry	:= ""
	Local oModel	:= FwModelActive()
	Local oModelN79	:= oModel:GetModel( "N79UNICO" )
	Local cCodPro	:= oModelN79:GetValue("N79_CODPRO")
	Local cFilOrg	:= oModelN79:GetValue("N79_FILORG")
	Local cRet		:= ""
	
	cQry += "SELECT N92_CODIGO FROM " + RetSqlName('N92') + " "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "AND N92_FILIAL = '" + cFilOrg + "' "
	cQry += "AND N92_CODIGO = '" + cToEtap + "' "
	cQry += "AND N92_TIPO   = '4' "
	cQry += "AND ((N92_CODIGO IN(SELECT NCB_CODTO FROM " + RetSqlName('NCB') + " "
	cQry += "   WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND NCB_FILIAL = '" + cFilOrg + "' "
	cQry += "   AND NCB_CODPRO = '" + cCodPro + "')) "
	cQry += "   OR (N92_CODIGO NOT IN "
	cQry += "  	(SELECT NCB_CODTO FROM " + RetSqlName('NCB') + ") ) )"
	
	cRet := GetDataSql(cQry)
	
	if !EMPTY(cRet)
		lRet := .T.
	else
		lRet := .F.
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", "Ajuda", "Tipo de Operação não compatível", "", "")
	endIf
	
return lRet

/*/{Protheus.doc} OGA700REAB()
Volta o aceite do cliente para "Não Enviado" para permitir alterações no registro de negócio.
@type  Function
@author rafael.kleestadt
@since 07/03/2019
@version 1.0
@param param, param_type, param_descr
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGA700REAB()

	Local cTitStsCli := AllTrim(RetTitle("N79_STCLIE")) //"Status Clie"
	Local cOpcStsCli := AllTrim(X3CboxDesc( "N79_STCLIE", "4" )) //"Aprovado"
	Local cStsContra := Posicione("NJR",1,xFilial("NJR")+N79->N79_CODCTR, "NJR_STATUS")
	Local cTitStsCtr := AllTrim(RetTitle("NJR_STATUS")) //"Status Ctr."
	Local cStsCtrAbe := AllTrim(X3CboxDesc( "NJR_STATUS", "A" )) //"Aberto"
	Local cStsCtrPre := AllTrim(X3CboxDesc( "NJR_STATUS", "P" )) //"Previsto"
	Local cStatusCli := N79->N79_STCLIE
	Local cTitStsNeg := AllTrim(RetTitle("N79_STATUS")) //"Status"
	Local cOpcStsNeg := AllTrim(X3CboxDesc( "N79_STATUS", "4" )) //"Rejeitado"
	Local cStatusNeg := N79->N79_STATUS
	Local lRet       := .T.

	Do Case

		Case cStatusCli <> "4"

			HELP(' ',1,cTitStsCli,,cTitStsCli + STR0220,2,0,,,,,, {STR0221+cTitStsCli+ STR0222 +cOpcStsCli+ STR0223})
		             //"Status Clie" ### "Status Clie" ### " inválido!" ### "Somente negócios com " ### " igual a " ### " podem ser reabertos."
		Case cStatusNeg = "4"

			HELP(' ',1,cTitStsNeg,,cTitStsNeg + STR0220,2,0,,,,,, {STR0221+cTitStsNeg+ STR0224 +cOpcStsNeg+ STR0223})
					 //"Status" ### "Status" ### " inválido!" ### "Somente negócios com " ### " diferente de " ### " podem ser reabertos."
		Case .Not. cStsContra $ "P|A"

			HELP(' ',1,cTitStsCtr,,cTitStsCtr + STR0220,2,0,,,,,, {STR0225 +cStsCtrPre+ STR0226 +cStsCtrAbe+ STR0223})
		             //""Status Ctr."" ### ""Status Ctr."" ### " inválido!" ### "Somente negócios com contrato igual a " ### " ou " ### " podem ser reabertos."
		OTHERWISE

		oModel := FwLoadModel("OGA700")		
		oModel:SetOperation(MODEL_OPERATION_UPDATE)

		If oModel:Activate()
			If !__lAutomato
                lRet := AGRGRAVAHIS(STR0227,"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,"B", ,STR0228) = 1 //"Deseja Reabrir o Negócio?" ### "Reabrir Registro de Negócio."
            EndIf
            
            If lRet
                oModel:SetValue("N79UNICO","N79_STCLIE", "1") //"Não Enviado"                
                lRet := fAtuModCtr(N79->N79_CODCTR)
            Else
                Return .T.
            EndIf
	   
			If lRet 
				If oModel:VldData()  // Valida o Model
					oModel:CommitData() // Realiza o commit
					oModel:DeActivate() // Desativa o model
					oModel:Destroy() // Destroi o objeto do model
				EndIf
			Else
				oModel:DeActivate() // Desativa o model
				oModel:Destroy() // Destroi o objeto do model
			EndIf
			
		EndIf

	EndCase

Return .T.


/*/{Protheus.doc} fAtuModCtr()
Atualiza o valor do campo NJR_MODELO para 1=Pré-Contrato
@type  Static Function
@author rafael.kleestadt
@since 08/03/2019
@version 1.0
@param cCodCtr, caractere, conteúdo do campo N79_CODCTR
@return True, Logycal, True or False.
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtuModCtr(cCodCtr)

	DbSelectArea("NJR")
	NJR->(DbSetOrder(1))
	If NJR->(DBSeek(xFilial("NJR")+cCodCtr))

		IF RecLock("NJR", .F.)
			NJR->NJR_MODELO := '1'
			NJR->(MsUnLock())
		Else
			Return .F.
		EndIf

	Else
		Return .F.
	EndIf
	NJR->(DbCloseArea())

Return .T.


/*/{Protheus.doc} AGRA510CON
//Consulta de Tipo Operação 
@author Christopher.miranda	
@since 15/03/2019
@version undefined
@param lDialog, characters, indica se deve abrir a dialog para selecao de registro
@param cCLTAux, characters, alias da tabela temporaria passada por referencia
@type function
/*/
Function AGRA510CON()
	Local aArea       	:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) //Tamanho tela
	Local nAltura  		
	Local nLargura 		
	Local aColFilter 	:= {}
	Local aSeek        	:= {} 
	Local oPnTipoOp		:= Nil
	Local oDlgClt     	:= Nil
	Local oFwLayer    	:= Nil
	Local aColTipoOp 	:= {}
	Local oBrwClt     	:= Nil
	Local nx
	Local nCol
	Local lSemErro		:= .T. //Tratar selecao no grid futuramente
   	Local aStrTpOp		:= DEFTMPREG() //Estrutura da TT
   	Local lRet			:= .T.
   	
	Private _oCLTTEMP				//Objeto para TT

	If N79->(ColumnPos("N79_TOETAP")) > 0
        __cRet := Space(TamSx3("N79_TOETAP")[1])
    EndIf

	nAltura		:= aCoors[3] * 0.7  //Tamanho tela
	nLargura	:= aCoors[4] * 0.7  //Tamanho tela
	
	//Tabela Temporária de Consulta de Ordem de Colheita, caso nao tenha sido enviada
	
	__cCLTTEMP := CriaTmpReg(aStrTpOp, @__cCLTTEMP)
	
		PegaDados(@__cCLTTEMP)

		DEFINE MSDIALOG oDlgClt TITLE STR0235 FROM aCoors[1], aCoors[2] TO nAltura, nLargura PIXEL OF oMainWnd //"Consulta Tipos de Operação do Romaneio"
	
		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlgClt, .f., .t. )
		oFWLayer:AddLine( 'GRID', 100, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
	
		oWIN   := oFWLayer:GetColPanel( 'ALL', 'GRID' )
		
		//Monta as colunas desconsiderando os campos abaixo
		nCol := 1
		For nX := 1 to Len(aStrTpOp)
			aAdd(aColTipoOp,FWBrwColumn():New())
			aColTipoOp[nCol]:SetData(&("{||"+aStrTpOp[nX,1]+"}"))
			aColTipoOp[nCol]:SetTitle(aStrTpOp[nX,5])
			aColTipoOp[nCol]:SetPicture(aStrTpOp[nX,6])
			aColTipoOp[nCol]:SetType(aStrTpOp[nX,2])
			aColTipoOp[nCol]:SetSize(aStrTpOp[nX,3])
			aColTipoOp[nCol]:SetReadVar(aStrTpOp[nX,1])
			nCol++
		Next nX
	    
		aColFilter := ColFilter()
		Aadd(aSeek,{STR0236 ,{{"", 'C' , 26 , 0 , "@!" }}, 1, .T. } ) //
	
		DEFINE FWFORMBROWSE oBrwClt DATA TABLE ALIAS __cCLTTEMP DESCRIPTION STR0237 OF oPnTipoOp //Ordens de Colheita
		oBrwClt:SetSeek( ,aSeek)
		oBrwClt:SetTemporary(.T.)
		oBrwClt:SetFieldFilter(aColFilter)
		oBrwClt:SetColumns(aColTipoOp)
		oBrwClt:SetOwner(oWIN)
		oBrwClt:SetDBFFilter(.T.)
		oBrwClt:SetUseFilter(.T.)
		oBrwClt:DisableDetails(.F.)
		oBrwClt:SetDoubleClick( {|| lSemErro := AGRA510SEL(), IIf(lSemErro, oDlgClt:End(),)   })
		oBrwClt:AddButton(STR0238,{|| oDlgClt:end()},,9,0) //Sair
		ACTIVATE FWFORMBROWSE oBrwClt
		ACTIVATE MSDIALOG oDlgClt CENTERED

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} DEFTMPREG
//Retorna estrutura da tabela temporária de Consulta de Tipo de Operação
@author christopher.miranda
@since 15/03/2019
@version 12.1.20
@type static function
/*/
Static Function DEFTMPREG()
	Local aCLTTEMP := {}

	aAdd(aCLTTEMP,{ "N92_CODIGO", TamSX3("N92_CODIGO")[3], TamSX3("N92_CODIGO")[1], TamSX3("N92_CODIGO")[2], AGRTITULO("N92_CODIGO") , PesqPict("N92", "N92_CODIGO")})
	aAdd(aCLTTEMP,{ "N92_DESCTO", TamSX3("N92_DESCTO")[3], TamSX3("N92_DESCTO")[1], TamSX3("N92_DESCTO")[2], AGRTITULO("N92_DESCTO") , PesqPict("N92", "N92_DESCTO")})
	
Return aCLTTEMP

/*/{Protheus.doc} CriaTmpReg
//Cria a tabela temporária de Tipo de Operação
@author christopher.miranda
@since 15/03/2019
@version undefined
@type static function
/*/
Static Function CriaTmpReg(aStrTpOp)
	Local cCLTAux := GetNextAlias()
	Local oCLTTEMP
	
	oCLTTEMP := FwTemporaryTable():New(cCLTAux)
	oCLTTEMP:SetFields(aStrTpOp)
	oCLTTEMP:AddIndex("1",{"N92_CODIGO"})
	oCLTTEMP:Create()
		
Return cCLTAux


/*/{Protheus.doc} PegaDados
//ZOOM da consulta Tipo de Operação
@author christopher.miranda
@since 15/03/2019
@version undefined
@type static function
/*/
Static Function PegaDados(cCLTTEMP)
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local oModel	:= FwModelActive()
	Local oModelN79	:= oModel:GetModel( "N79UNICO" )
	Local cCodPro	:= oModelN79:GetValue("N79_CODPRO")
	Local cFilOrg	:= oModelN79:GetValue("N79_FILORG")
	Local cTipo		:= Iif(oModelN79:GetValue("N79_OPENGC") = '2','4','5')

	cQuery += "SELECT N92_CODIGO,N92_DESCTO FROM " + RetSqlName('N92') + " N92 " 
	cQuery += 	"WHERE "
	cQuery += 		"N92.D_E_L_E_T_ = ' ' "
	If FWModeAccess("N92", 1) == "E"
		cQuery += 		"AND N92_FILIAL = '" + cFilOrg + "' "
	else 
		cQuery += 		"AND N92_FILIAL = '" + FwXFilial("N92") + "' "
	endif
	cQuery += 		"AND N92_TIPO   =  '"+ cTipo + "' "
	cQuery += 		"AND N92_CODPRO =  '"+ cCodPro + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
	dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		
		While (cAliasQry)->(!Eof())

			If RecLock(cCLTTEMP,.T.)

					(cCLTTEMP)->N92_CODIGO    := (cAliasQry)->N92_CODIGO 
					(cCLTTEMP)->N92_DESCTO    := (cAliasQry)->N92_DESCTO 

				(cCLTTEMP)->(MsUnlock())
			EndIf
			(cAliasQry)->(DbSkip())					
		Enddo
	
Return cCLTTEMP


/*/{Protheus.doc} ColFilter
//Alterar nome das colunas para campos na opcao 'Criar Filtro'
@author Christopher.miranda
@since 15/03/2019
@version undefined
@type Static function
/*/
Static Function ColFilter()
	Local aColFilter  := {}
	
	aAdd(aColFilter, {"N92_CODIGO", AGRTITULO("N92_CODIGO"),TamSX3("N92_CODIGO")[3], TamSX3("N92_CODIGO")[1], TamSX3("N92_CODIGO")[2], PesqPict("N92", "N92_CODIGO")} )
	aAdd(aColFilter, {"N92_DESCTO", AGRTITULO("N92_DESCTO"),TamSX3("N92_DESCTO")[3], TamSX3("N92_DESCTO")[1], TamSX3("N92_DESCTO")[2], PesqPict("N92", "N92_DESCTO")} )

Return aColFilter


/*/{Protheus.doc} AGRA510SEL
//Confirma selecao de Tipo de Operação
@author Christopher.miranda
@since 15/13/2019
@version undefined
@type function
/*/
Function AGRA510SEL()

	__cRet := (__cCLTTEMP)->N92_CODIGO

Return(.T.)


/*/{Protheus.doc} AGRA510RET
//Retorno NJJES1
@author Christopher.miranda
@since 15/03/2019
@version undefined
@type function
/*/
Function AGRA510RET()
	Local lRet := .T.
	
	Iif( __cRet = Nil, __cRet := Space(TamSx3("N92_CODIGO")[1]),)
	
	If .Not. Empty(__cRet)
				lRet := TpOperVld(__cRet, @__cCLTTEMP)
	EndIf
Return(__cRet)


/*/{Protheus.doc} TpOperVld
//Valida tipo de operação 
@author Christopher.miranda
@since 15/03/2019
@version undefined
@type Static function
/*/
Static Function TpOperVld(__cRet, __cCLTTEMP)
	Local lRet := .T.

Return lRet


/*/{Protheus.doc} OG700VN92
	Validação do Tipo Operação 
	@type  logico 
	@author christopher.miranda
	@since 19/03/2019
	/*/
 Function OG700VN92()
	Local cAliasQry := GetNextAlias()
	Local lRet 	:= .F.
	Local cQuery	:= ""
	Local oModel	:= FwModelActive()
	Local oModelN79	:= oModel:GetModel( "N79UNICO" )
	Local cCodPro	:= oModelN79:GetValue("N79_CODPRO")
	Local cCodTOp	:= ""
	Local cFilOrg	:= oModelN79:GetValue("N79_FILORG")
	Local cTipo		:= Iif(oModelN79:GetValue("N79_OPENGC") = '2','4','5')

	If oModelN79:HasField("N79_TOETAP")
        cCodTOp	:= oModelN79:GetValue("N79_TOETAP")    

        cQuery += "SELECT N92_CODIGO,N92_DESCTO FROM " + RetSqlName('N92') + " N92 " 
        cQuery += 	"WHERE "
        cQuery += 		"N92.D_E_L_E_T_ = ' ' "
        If FWModeAccess("N92", 1) == "E"
            cQuery += 		"AND N92_FILIAL = '" + cFilOrg + "' "
        else 
            cQuery += 		"AND N92_FILIAL = '" + FwXFilial("N92") + "' "
        endif
        cQuery += 		"AND N92_CODIGO = '" + cCodTOp + "' "
        cQuery += 		"AND N92_TIPO   =  '"+ cTipo + "' "
        cQuery += 		"AND N92_CODPRO =  '"+ cCodPro + "' "
        
        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
        If (cAliasQry)->( !Eof() )
            lRet := .T. 
        Endif
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OGA700AUT
Função chamada pelo teste automatizado
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGA700AUT(cAcao, oModel) 
 
 If cAcao == "CARGA_COMP"
    OGA700CHG(, , oModel)
 EndIf

Return

/*/{Protheus.doc} fVldInsNew
Valida se a inclusão é de um novo registro de negocio em branco, zerado
@type function
@version P12 
@author claudineia.reinert
@since 28/02/2022
@param nOperModel, numeric, Valor referente a operação do modelo de dados
@return variant, valor logico .T. ou .F.
/*/
Static Function fVldInsNew(oModel)
	Local lRet := .F.
	Local nOperModel := oModel:GetOperation()

	If nOperModel = MODEL_OPERATION_INSERT .and. !FWIsInCallStack("OGA700CPY") .and. !FWIsInCallStack("OGA700FIXA") .and. !FWIsInCallStack("OGA700CANC")  .and. !FWIsInCallStack("OGA700MODF") ;
		.and. !(__cAutoTest $ "FIXA|CANC|MODF")
		//se for inclusão e não é uma fixação/cancelamento/modificação de negocio
		lRet := .T. //é uma inclusão limpa de um novo negocio do zero
	EndIf

Return lRet

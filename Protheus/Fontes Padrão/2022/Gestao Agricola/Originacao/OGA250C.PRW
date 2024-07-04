#INCLUDE "OGA250C.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/** Variaveis Statics da Rotina
Atenção Com  statics  declaradas  fora  de função, pois ao inicializar a  Var	aParBal := AGRX003E( .f. )
a  rotina  AGRX003E  faz  referencia a uma tabela (DX6) quando  estamos executando  com SIGAADV, tudoOK, porem
se executamos via SIGAMDI, dá  erro de DX6 não existe, a razão é que em MDI, ao clicar na opção de menu o ERP,
possibilita  trocar  de Empresa / filial, o que faz com que	o TOP feche as conexões com o banco,retornando assim
mensagem de erro. Para solucionar o problema inicializei no method Activate ( oModel:SetActivate ) do modelo.
**/


/** {Protheus.doc} OGA250ATUC
Rotina para Atualizar o romaneio Valida e atualiza dados do contrato

@param: 	cAlias - Tabela do Romaneio
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	15/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250C( cAlias, nReg, nAcao, lAuto )
	Local lRetorno		:= .T.
	Local aAreaAtu  	:= GetArea()
	Local _NK1VALOR  	:= 0
	local nVlrUni		:= 0
	Local nItens		:= 0
	Local cCodCtr		:= ""
	Local cCodAutorz	:= ""
	Local cMsgErro		:= ""
    Local cMsgSoluc		:= ""
	Local lGerencial	:= ( NJJ->NJJ_TIPENT == "1" ) // 1=Gerencial
	Local lSimbolico	:= ( NJJ->NJJ_TIPENT == "2" ) // 2=Simbolico
	Local cNfpSer 		:= ""
	Local cNfpNum 		:= ""
	Local lErrExc  		:= .F.
	Local nQtdEContr 	:= 0
	Local nQtdSContr 	:= 0
	Local nQtdRoman  	:= 0 	
	Local nTotAdtv   	:= 0
	Local nQtdCons	 	:= 0
	Local nQtdResta  	:= 0
	Local nSaldCrt   	:= 0
	Local nQtAtuAut  	:= 0
	Local lUtiNfp    	:= SuperGetMV("MV_AGRO205",.T.,.F.)
	Local lRastFIFO  	:= SuperGetMv("MV_AGRO019",.F.,.F.)
	Local lRestA     	:= .F.
	Local cSubTipo   	:= ''
	Local cLote      	:= ''
	Local lUpdRegFis 	:= .F. //.F. NÃO consome qtd/saldos regra fiscal
	Local nQtdRet	 	:= 0
	Local cAliasQry  	:= GetNextAlias()
	Local cQuery     	:= ''
	Local lUsaIE     	:= .F.
	Local lOPEspec  	:= .F.
	Local cNumOP		:= ""
	Local nIt  			:= 0
	Local cSeq 			:= '01'
	Local aStruct 		:= NJM->(dBStruct()) // Obtém a estrutura
	Local aAux 			:= {}
	Local aNJM 			:= {}
	Local cTipMer    	:= '' //tipo de mercado
	Local aRetorno 		:= {0,''} //array de retorno da precificação, inicia ZERO para validação do Legado
	Local lAlgodao 		:= nil
	Local cCondAgr   	:= SuperGetMV( "MV_AGRCPVD", .f., " " ) 
	Local aDcos      	:= {}
	Local nQtdTotIE  	:= 0
	Local aAreaNJR   	:= NJR->(GetArea())
	Local lAdd       	:= .f.
	Local cValid     	:= .F.
	Local aRegFis	 	:= {}
	Local nPos		 	:= 0
	Local nCont      	:= 1 
	Local nPerc      	:= 0
	Local nQuant     	:= 0
	Local cClassRom  	:= cDefClasDesc(NJJ->(NJJ_TIPO),,.T.,(NJJ->(NJJ_TPFRET) = 'F'.and. NJJ->( NJJ_TPFORM ) == "1")) //Obtem o mandante da classificação do romaneio
	Local lFretOrig 	:= .F.
	Local cCodProd      := ""
	Local cCodEmit      := ''
	Local cCodLoj       := ''
	Private aDocFis		:= {}

	Default lAuto		:= .f.
	Default _lfutura    := .F.
	Default _lComplRom  := .F. //para complementos

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

	If __lnewNeg
		lAlgodao := If(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	EndIf
	
	lOPEspec := ExistBlock("AGRA50OP")

	//OP (ordem produção) específica enviada pelo cliente por ponto entrada
	If lOPEspec
		cNumOP := ExecBlock('AGRX50OP',.F.,.F.,)
	else
		cNumOP := ""
	EndIf

	//Salvando area atual
	aAreaNJJ := NJJ->(GetArea())
	aAreaNJM := NJM->(GetArea())

	If (ExistBlock("OG250ATUC"))
		If ExecBlock("OG250ATUC",.F.,.F.) = .f. 
			Return .F.
		EndIF
	EndIf
	//Restaurando area após a chamada do PE.
	RestArea(aAreaNJJ)
	RestArea(aAreaNJM)

	If !OGA250PNJJ()
		Return .F.
	EndIF
	
	DBSelectArea("NJM")
	DbSetOrder(1)
	DbSeek(xFilial("NJM")+NJJ->NJJ_CODROM)
	aAreaNJM := NJM->(GetArea()) //armazena primeira NJM posicionada do romaneio
	While !( NJM->(Eof()) ) .AND. xFilial("NJM")+NJJ->NJJ_CODROM == NJM->NJM_FILIAL + NJM->NJM_CODROM
		If nCont == 1 //Validações da primeira linha da NJM
			//verificação se o romaneio simbolico é de nota complementar emitida pelo modulo do faturamento 
			If !Empty(NJM->NJM_PEDIDO)   
				_lComplRom := POSICIONE("SC5",1,xFilial( "SC5" ) + NJM->NJM_PEDIDO,"C5_TIPO") == "C"
			elseif !Empty(NJM->NJM_DOCNUM) 
				//DAGROOGD-16074 - utiliza o codigo da entidade para buscar o documento correto
				DbSelectArea("NJ0")
				DbSetOrder(1)
				DbSeek(xFilial("NJ0")+ NJM->NJM_CODENT + NJM->NJM_LOJENT)
				cCodEmit := Posicione('SA1',1,xFilial('SA1')+NJ0->NJ0_CODCLI+NJ0->NJ0_LOJCLI,'A1_COD')
				cCodLoj  := Posicione('SA1',1,xFilial('SA1')+NJ0->NJ0_CODCLI+NJ0->NJ0_LOJCLI,'A1_LOJA')
				_lComplRom := POSICIONE("SF1",1,xFilial( "SF1" ) + NJM->NJM_DOCNUM + NJM->NJM_DOCSER + cCodEmit + cCodLoj,"F1_TIPO") == "C"
			EndIf
			
			If !Empty(NJM->NJM_CODCTR)
				dbSelectArea( "NJR" )
				dbSetOrder( 1 )
				If dbSeek( FWxFilial( "NJR" ) + NJM->NJM_CODCTR )				   
				   If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato											
				      lFretOrig := (NJR->NJR_CLASSF = '2')
					ENDIF
					// Se tipo do contrato for incompatível com tipo do romaneio
					If NJR->( NJR_TIPO ) <> OGX010TC( NJJ->NJJ_TIPO )  						
                        AGRHELP(STR0001,STR0002 + "[ " + X3CboxDesc( "NJR_TIPO", NJR->( NJR_TIPO ) ) + " ]",STR0070) //"Ajuda" #"O -Contrato- informado não pode ser utilizado neste romaneio, pois é um contrato do tipo " #Informe um contrato compatível com o tipo do romaneio.
						RestArea(aAreaNJR)
						Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
					EndIf
				EndIf			

				If Empty(NJM->NJM_CODENT) .Or. Empty(NJM->NJM_LOJENT)
					If .Not. lAuto
						AgrHelp(STR0001,STR0072,STR0006) //'AJUDA' #"O código da Entidade ou da Loja não foram informados." #"Informe o Codigo e Loja da Entidade"                          
					EndIf
					RestArea(aAreaNJR)
					Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
				EndIf
			EndIf
		else //Validações Das demais linhas
			If Empty(NJM->NJM_CODSAF) .Or. Empty(NJM->NJM_CODPRO) .OR. empty(NJM->NJM_CODENT) .OR. empty(NJM->NJM_LOJENT)
				AGRHELP(STR0001,STR0071,STR0060) //"Ajuda" #"Há campos não informados nos itens da aba Comercialização." #"É necessário informar os dados de Safra, Produto e Entidade em todas as linhas da aba Comercialização"
				RestArea(aAreaNJR)
				Return( .f. ) 		
			Endif
		EndIf
		//Validação de mesmo produto em todas as linhas da NJM
		If cCodProd == ""
			cCodProd := NJM->NJM_CODPRO
		elseIf cCodProd <> NJM->NJM_CODPRO
			AgrHelp(STR0001,STR0107,STR0108) //"Ajuda" #"Há itens de romaneio que possuem produto diferente entre si. #"É necessário que todos os produtos do romaneio sejam do mesmo código."
			RestArea(aAreaNJR)
			Return( .f. ) 		
		EndIf
		//Validação de percentual e quantidade 
	 	nPerc     += NJM->NJM_PERDIV
	 	nQuant    += NJM->NJM_QTDFCO

		nCont ++
		NJM->(DbSkip())
	EndDo
	RestArea(aAreaNJM) //RESTAURA AREA da NJM para manter primeira NJM posicionada

	If _lComplRom
		If !Empty(nPerc) .OR. !Empty(nQuant) //não pode haver quantidades preenchidas no complemento.			
			AGRHELP(STR0001,STR0063,STR0064) //Ajuda #"Para romaneios simbólicos de complemento de preço, não deve ser preenchido os campos de peso."  #"Alterar o romaneio e remover as informações de Peso.")
			RestArea(aAreaNJR)
			Return( .f. )
		EndIf
	Else
		If NJJ->( NJJ_STATUS ) <> "1" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
			If .Not. lAuto
				//--Quando é executado pelo GFE a função HELP não é executada.
				//--Nesse cenário devemos utilizar a função MSGINFO.		
				If FwIsInCallStack("GFEA523")
					MSGINFO(STR0003,STR0001)	//'Ajuda'###"Somente Romaneios com status de -Completo- podem ser -Atualizados-."
				Else
					AgrHelp(STR0001,STR0074,STR0003) //'Ajuda' #"Não é possível atualizar o romaneio." #"Somente Romaneios com status de -Completo- podem ser -Atualizados-."                    
				EndIf
			EndIf
			//Return( Nil )
			Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
		EndIf
		
		If nPerc <> 100 
			AgrHelp(STR0001,STR0061,STR0075) //Ajuda #"A Soma dos percentuais da aba de Comercialização difere de 100%" #"Ajuste os percentuais na aba de Comercialização."            
			RestArea(aAreaNJR)
			Return( .f. ) 	
		elseif nQuant <> NJJ->NJJ_PSLIQU .And. ; 
		       !(lFretOrig .And. NJJ->(NJJ_TIPO) == '5' .And.  NJJ->(NJJ_TPFRET)  = 'F' .And. NJJ->( NJJ_TPFORM ) = "1")  
			AgrHelp(STR0001,STR0062,STR0076) //Ajuda #"A Soma das quantidades da aba de Comercialização difere da Quantidade Física do Romaneio" #"Ajuste as quantidades do peso físico na aba de Comercialização."            
			RestArea(aAreaNJR)
			Return( .f. ) 			
		EndIf
	EndIf
	If Empty(NJJ->NJJ_TIPO) 
		If .Not. lAuto
			AgrHelp(STR0001,STR0077,STR0004) //Ajuda #"Tipo do romaneio não foi informado." #"Informe o Tipo do Romaneio"
		EndIf
		Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
	EndIf	

	//Obriga informar as classificações somente depois de saber o mandante conforme o contrato - DAGROGAP-446
	If NJJ->( NJJ_STSCLA ) <> "1"  .And. !( NJJ->( NJJ_TIPO ) $ "2|4|6|8") .And. !Empty(NJJ->(NJJ_CODCTR)) .And. !SuperGetMV( "MV_AGOCLAS",, .F. )
		If .Not. lAuto
			AgrHelp(STR0001,STR0078,STR0079) //'Ajuda' #""Romaneio não classificado." "Informe os resultados na aba classificação do romaneio."            
		EndIf
		Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
	EndIf

	DbSelectArea("NJK")
	DbSetOrder(1)
	DbSeek(xFilial("NJK")+NJJ->NJJ_CODROM)
	While NJK->(!Eof()) .AND. xFilial("NJK")+NJJ->NJJ_CODROM == NJK->NJK_FILIAL + NJK->NJK_CODROM
		If NJK->NJK_OBRGT == '1' .AND. Empty(NJK->NJK_PERDES) .AND. ;
		    (!__lnewNeg .OR. (__lnewNeg .AND. cClassRom == NJK->NJK_TPCLAS))
			AgrHelp(STR0001,STR0055,STR0079) //'Ajuda' #"Romaneio possui Itens de Classificação obrigatórios não informados" #"Informe os resultados na aba classificação do romaneio."                        
			Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
		EndIf
		NJK->(DbSkip())
	EndDo

	If __lnewNeg //validações novo negocio antes tela confirmar atualização				
        
		IF N9E->(dbSeek(xFilial("N9E") + NJJ->NJJ_CODROM))

            N7Q->(DbSetOrder(1)) 
            N9E->(DbSetorder(1))
            NJR->(DbSetOrder(1))
            N7S->(DbSetOrder(1))
            N8O->(dbSetOrder(1))
			While !N9E->(Eof()) .AND. ( xFilial("N9E") + N9E->N9E_CODROM == NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM )				
				
				lAdd := .f.
				If FwIsInCallStack("AGRA500") .AND. !Empty(N9E->N9E_CODAUT) .AND. !Empty(N9E->N9E_ITEMAC)
					If N8O->(dbSeek(FwxFilial("N8O")+N9E->N9E_CODAUT+N9E->N9E_ITEMAC))
						nQtdTotIE += N8O->N8O_QTD
						lAdd := .t.
					EndIf
				EndIf

				If !Empty(N9E->N9E_CODINE)
					//validação do status da assinatura da IE
                    //If FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("OGA250") .OR. FwIsInCallStack("OGA251") .OR. FwIsInCallStack("OGA710") .OR. FwIsInCallStack("GFEA523") .OR. FunName() == "OGA250" 					
                        
                        If N7Q->(DbSeek(FwxFilial("N7Q")+N9E->N9E_CODINE)) //N7Q_FILIAL+N7Q_CODINE							
                                
                            If N7S->(DbSeek(FwxFilial("N7S") + N9E->N9E_CODINE))
                                cCodCtr := N7S->N7S_CODCTR
                                If !lAdd //Pelo AGRA500 não deverá entrar aqui. Apenas pelo OGA250
                                    While N7S->( !Eof() ) .And. N7S->N7S_CODINE == N9E->N9E_CODINE	
                                        If N7S->N7S_FILORG == FwxFilial("NJJ")		
                                            nQtdTotIE += N7S->N7S_QTDVIN - N7S->N7S_QTDREM //OGA710SCad(N7S->N7S_CODCTR, N7S->N7S_ITEM, N7S->N7S_SEQPRI,.T.)
                                        EndIf                                            
                                        
                                        NJR->(DBSEEK(xFilial("NJR")+cCodCtr))
                                        //status IE 3=Sem Assinatura
                                        If N7Q->N7Q_STSASS == "3" .AND. NJR->NJR_STSASS == "A"
                                            If FwIsInCallStack("GFEA523")
                                                MSGINFO(STR0054, STR0001)	//'Ajuda' #"Status de assinatura contrato e/ou IE em aberto" 
                                            Else
                                                AgrHelp(STR0001,STR0054,STR0080) //'Ajuda' #"Status de assinatura contrato e/ou IE em aberto" #"Realize a assinatura no Contrato ou na Instrução de Embarque."                                                    
                                            EndIf
                                            Return( .F. )
                                        EndIf

                                        N7S->(DbSkip())
                                    EndDo
                                EndIf
                            EndIf                           
                            lUsaIE := .T.                        
                            N7Q->(dbCloseArea())
                        EndIf
                    //EndIf
				EndIf	
				N9E->(DbSkip())
			EndDo
		EndIf
		
		//Obriga informar a IE e/ou contrato se romaneio for do tipo Vendas ou Remessa para Terceiros e utiliza Registro de Negócios
		If  NJJ->( NJJ_TIPO ) $ "2|4|5"
			
			If Empty(cCodCtr) .and. !Empty(NJM->NJM_CODCTR)
				cCodCtr := NJM->NJM_CODCTR 
			EndIf

			If !lUsaIE .and. Empty(cCodCtr) 				
                If .Not. lAuto
                    If FwIsInCallStack("GFEA523")
                        MsgInfo( STR0037 ) 
                    Else
                        AgrHelp(STR0001,STR0081,STR0069) //'Ajuda' #"Não foi informado o contrato no romaneio."  #"Para atualizar o romaneio é necessário informar uma Instrução de Embarque e/ou Contrato."
                    EndIf
                endIf
                Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar				
			EndIf			

			If !lUsaIE .and. !Empty(cCodCtr) 
				//validações se não tem instrução de embarque, mas tem contrato(regras fiscais) informado (instrução de embarque opcional)
				aAreaNJM := NJM->(GetArea())
				DBSelectArea("NJM")
				NJM->(DbSetOrder(1))
				NJM->(DbSeek(xFilial("NJM")+NJJ->NJJ_CODROM))
				While .Not. NJM->(Eof()) .And. NJM->(NJM_FILIAL) == FWxFilial( "NJM" ) .And. NJM->(NJM_CODROM) == NJJ->( NJJ_CODROM ) 
					If Empty(NJM->NJM_CODCTR) .or. Empty(NJM->NJM_ITEM) .or. Empty(NJM->NJM_SEQPRI)
						AgrHelp(STR0001,STR0082,STR0057) //Ajuda #"Há campos obrigatórios não informados na aba comercialização." #"Para atualizar o romaneio é necessario na aba itens de comercialização informar os campos contrato, intervalo e Id Regra."                         
						Return .F.
					EndIf
					
					DBSelectArea("N7S")
					N7S->(DbSetOrder(2))
					If N7S->(DbSeek(xFilial("N7S")+NJM->(NJM_CODCTR))) //esta vinculado a uma instrução de embarque
						AgrHelp(STR0001,STR0059,STR0083) //Ajuda #Não foi possivel atualizar o romaneio." #"Contrato informado no romaneio esta vinculado a uma instrução de embarque. Para usar o romaneio sem informar instrução de embarque é obrigatório que o contrato não esteja vinculado a uma instrução de embarque."                        
						Return .F.
					EndIf

					//NÃO PERMITE NJM COM MESMA REGRA FISCAL, SOMENTE NO ATUALIZAR IRÁ QUEBRAR A NJM COM MESMA REGRA FISCAL SE NECESSARIO
					nPos := aScan( aRegFis, alltrim(NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI))
					If nPos == 0
						aAdd( aRegFis, alltrim(NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI) )					
					Else
						Agrhelp(STR0001,STR0065,STR0066) //Ajuda #"Romaneio possui itens da comercialização com regras fiscais de contrato duplicado." #"Ajuste os itens da comercialização, verificando os campo 'Contrato','Intervalo' e 'Id. Seq'."
						Return .F.
					EndIf

					NJM->( dbSkip() )
				EndDo
				RestArea(aAreaNJM)
			EndIf

		EndIf

		//Validação da cond de pagamento para tipo 9
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial('SE4')+cCondAgr)) 
			If (SE4->( E4_TIPO ) <> '9')
				AgrHelp(STR0047, STR0048, STR0049+SE4->( E4_CODIGO )) //"Inconsistência de cadastro" #"O Tipo da Condição de Pagamento utilizada no parâmetro MV_AGRCPVD está diferente de 9." #"Alterar para Tipo 9 a Condição de Pagamento código :"
				Return( .F. )	
			EndIf
		EndIf

		If NJJ->NJJ_TIPO $ 'A|B' 
			If Empty(NJM->NJM_LOTCTL) 
				IF Rastro(NJJ->NJJ_CODPRO)
					AgrHelp(STR0001,STR0034, STR0084 + alltrim(NJJ->NJJ_CODPRO) + STR0085) //#Ajuda #"Este produto possui rastro por lote." #"Informe lote para o produto " #" na aba de comercialização."                    
					Return .F.
				EndIf	
			EndIf
		EndIf

		If FwIsInCallStack("AGRA500") .AND. NJJ->NJJ_TIPO <> "1"
			If Empty(NJM->NJM_TES)
				If .Not. lAuto
					Help('' ,1,".OGA250C00001.", , ,1,0)	//TES do Romaneio não informada.#Informe a TES para atualizar o Romaneio.
				EndIf
				Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
			EndIf
		EndIf

		//If FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523")	
		If .NOT. NJJ->NJJ_STATUS $ '3|5'
			If lAlgodao
				//Verifica se foi vinculado fardão/fardinho quando for algodão, se tiver marcado no tipo de operação o vinculo
				If .Not. A500VLDFAR()

					If !(FwIsInCallStack("GFEA523"))
						Help('' ,1,".AGRA50000024.", , ,1,0) //Não foi vínculado fardinho/ fardão ao romaneio.//Quando produto for algodão, deve ser vinculado fardinho/ fardão ao romaneio.
					Else
						MsgInfo( STR0043 ) //"Não foi vínculado fardinho/fardão ao romaneio. Quando produto for algodão, deve ser vinculado fardinho/fardão ao romaneio."
					EndIf

					Return .F.
				EndIf 
			EndIf
		EndIf
    EndIf //fim validações novo negocio

	If !FwIsInCallStack("AGRA500")
		If ( !(NJJ->NJJ_TIPO  $ "4|6") .AND. (Empty(NJJ->NJJ_ENTENT) .OR. Empty(NJJ->NJJ_ENTLOJ) )) .OR. ( !Empty(NJJ->NJJ_ENTENT) .AND. Empty(NJJ->NJJ_ENTLOJ) )
			If .Not. lAuto           
				AgrHelp(STR0001,STR0073,STR0007)  //'AJUDA' #"O código da Entidade ou da Loja de Entrega não foram informados." #"Informe o Codigo e Loja da Entidade de Entrega"                              
			EndIf
			Return( .f. ) 
		EndIf
	EndIf
	
	
	If IsBlind()
		lAuto := .t.
	EndIf

	If .Not. lAuto .and. .Not. _lComplRom
		If .Not. MsgYesNo(STR0008, STR0009) //"Tem certeza que deseja fechar este romaneio?"###"Fechamento do Romaneio"
			//Return( Nil )
			Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
		EndIf
	EndIf

	// Valida as quantidades do romaneio: peso, descontos, classificação, qtdes na NJM, percentuais
	If .Not. OGA250VQTD()
		//Return( Nil )
		Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
	EndIf	

	/*Fução para validar parecer da qualidade*/
	If SuperGetMV("MV_OGQLPES",.F.,.F.) .AND. !OGA250PQL() 
		Return( .f. )  
	EndIf
	If __lnewNeg
		//**Função para gerar romaneio quando for entidade propria
		//**DAGROUBA-3341 - Não chamar OGA250GERO quando tipo de entrada for por produção e entidade for de classe própria
		If (NJJ->NJJ_TIPO <> "1" .AND. NJJ->NJJ_TIPO <> "A" .AND. NJJ->NJJ_TIPO <> "B")	//1=Entrada por Produção
			If  NJJ->NJJ_TIPO == "9" 
				//validação para não permitir atualizar romaneio de devolução com formulario proprio não, caso a entidade do romaneio seja diferente da entidade das NFs de origem vinculadas(N9E)
				cQuery := " SELECT N9E_CLIFOR, N9E_LOJA  "
				cQuery += " FROM " + RetSqlName('N9E') + " N9E "
				cQuery += " WHERE N9E.N9E_CODROM = '" + NJJ->NJJ_CODROM + "' "
				cQuery += " AND N9E.N9E_FILIAL = '" + NJJ->NJJ_FILIAL + "' "
				cQuery += " AND N9E.D_E_L_E_T_ = '' "
				cQuery += " AND N9E.N9E_ORIGEM = '7' "  
				cQuery := ChangeQuery( cQuery ) 
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

				While (cAliasQry)->( !Eof() )        
					DbSelectArea("NJ0")
					DbSetOrder(1)
					DbSeek(xFilial("NJ0")+NJJ->NJJ_CODENT+NJJ->NJJ_LOJENT )
					If ( NJ0->NJ0_CODCLI + NJ0->NJ0_LOJCLI <> (cAliasQry)->N9E_CLIFOR + (cAliasQry)->N9E_LOJA ) 
						AgrHelp(STR0001,STR0086,STR0046) //#Ajuda #"A entidade informada é diferente das notas vinculadas." #"Para romaneio de devolução com formulario proprio igual a NÃO, a entidade informada deve ser a mesma entidade das NFs Vinculadas."
						(cAliasQry)->(dbCloseArea())
						Return .F.
					EndIf
					(cAliasQry)->( dbSkip() )
				EndDo
				(cAliasQry)->(dbCloseArea())

			EndIf
		EndIf

		dbSelectArea( "NJ0" )
		dbSetOrder(1)
		If dbSeek( xFilial( "NJ0" ) + NJJ->NJJ_CODENT + NJJ->NJJ_LOJENT)		
			If NJ0->NJ0_CLASSE == '1' //Proprio
				//Busca a Filial 
				cFilEnt := NJ0->NJ0_CODCRP				
				//Envia código do Romaneio e falso [para não realizar comit]
				lRetorno := OGA250GERO(.F., cFilEnt)			
				If !lRetorno
					Return(.F.)
				EndIf

			EndIf			
		EndIf
	EndIf 

	BEGIN TRANSACTION
		//Gera subprodutos e NFs Financeiras
		BeginSql Alias "QryNJMTot"
			column NJM_DOCEMI As Date
			Select Count( * ) As Total 
			From %table:NJM% NJM
			Where NJM.NJM_FILIAL = %xFilial:NJM% 
			And NJM.NJM_CODROM = %Exp:NJJ->( NJJ_CODROM )%
			And NJM.%NotDel%
		EndSql
		dbGoTop()

		While .Not. QryNJMTot->( Eof() )
			nItens 	:= QryNJMTot->( Total ) 
			QryNJMTot->( dbSkip() )
		Enddo		

		QryNJMTot->( dbCloseArea( ) )

		//Gera subprodutos e NFs Financeiras
		BeginSql Alias "QryNJM"
			column NJM_DOCEMI As Date
			Select *
			From %table:NJM% NJM
			Where NJM.NJM_FILIAL = %xFilial:NJM% 
			And NJM.NJM_CODROM = %Exp:NJJ->( NJJ_CODROM )%
			And NJM.%NotDel%
		EndSql
		dbGoTop()

		While .Not. QryNJM->( Eof() )
			// Gera dados do SubProduto
			dbSelectArea( "NJK" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "NJK" ) + QryNJM->( NJM_CODROM ) )
			While .Not. Eof() .And. NJK->NJK_FILIAL = xFilial( "NJK" ) .And. NJK->NJK_CODROM = QryNJM->( NJM_CODROM )
				If NJK->NJK_QTDDES <> 0
					dbSelectArea( "NNH" )
					dbSetOrder( 1 )
					If dbSeek(FWxFilial( "NNH" ) + NJK->NJK_CODDES)
						IF !Empty( NNH->NNH_CODPRO )
							nItens 	+= 1
							OGA250GSubPr(nItens)
						EndIf
					EndIf
				EndIf
				dbSelectArea( "NJK" )
				dbSkip()
			EndDo

			If NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. __lnewNeg
				if !Empty(QryNJM->(NJM_SUBTIP))
					cSubTipo := QryNJM->(NJM_SUBTIP)
				EndIf

				if !Empty(QryNJM->(NJM_LOTCTL))
					cLote := QryNJM->(NJM_LOTCTL)
				EndIf
			EndIf

			QryNJM->( dbSkip() )
		Enddo		

		QryNJM->( dbCloseArea( ) )

		/* Quando utiliza o novo processo pelo registro de negócio */
		If __lnewNeg .and. !_lComplRom
	
			//RATEIO FARDINHOS DE ALGODÃO - nao fazer para romaneio de venda - exportacao  
			If NJJ->(NJJ_TIPO) $ "4|2" .AND. AGRTPALGOD(NJJ->(NJJ_CODPRO)) .AND. OG250DVFT(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM) != "43" // 43 - (S) VENDA ENTREGA FUTURA 
				MsgRun(STR0031, STR0009 , {|| lRetorno := OG250BRPFA(NJJ->(NJJ_CODROM),1)})                      

				// Alterar Movto Fardo
				If lRetorno
					// Atualiza o movimento dos fardos (07 - Romaneio)
					OG250EATMF(.T., "07", NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)					
				EndIf                      
			EndIf

			If lRetorno .AND. NJJ->(NJJ_TIPO) $ "4|2|5"			
				/* Verifica se é um romaneio mercado interno/externo - Não entra quando Venda Futura */
				cTipMer := OG250DVMI()

				If cTipMer $ "1|2" .and. !_lfutura //(1-interno; 2-externo)
					
					/* Se o produto for GRÃOS */
					If !AGRTPALGOD(NJJ->NJJ_CODPRO)
						/* Realiza a quebra da NJM de acordo o peso informado para os contratos/cadências/regras fiscais das IEs 
						informadas (Apenas para Mercado Interno/Externo - Grãos) */
						If !OG250DQNJM(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, NJJ->NJJ_PESO3, NJJ->NJJ_VLRUNI, NJJ->NJJ_NFPSER, NJJ->NJJ_NFPNUM, 1, cSubTipo, NJJ->(NJJ_TIPO), cTipMer, cLote)
							lRetorno := .F.
						EndIf  
					ElseIf lRetorno     /* se é algodão e não ocorreu problema no rateio de fardos */           
						/* Realiza a quebra da NJM de acordo o peso informado para os contratos/cadências/regras fiscais de acordo com os fardos 
						vinculados (Apenas para Mercado Interno/Externo - Algodão) */
						If !OG250DQNJM(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, NJJ->NJJ_PESO3, NJJ->NJJ_VLRUNI, NJJ->NJJ_NFPSER, NJJ->NJJ_NFPNUM, 2, cSubTipo, NJJ->(NJJ_TIPO), cTipMer, cLote)
							lRetorno := .F.
						EndIf
					EndIf
				EndIf	
			ElseIf NJJ->(NJJ_TIPO) $ "7|9" // Devolução de Remessa ou Devolução de Venda
				nQtdRet := OG251AQN9E(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)

				If nQtdRet == 0
					AgrHelp(STR0001,STR0045, STR0087) //#Ajuda #"Não foram vinculadas notas fiscais de origem." #"Informe a nota fiscal de origem na opção 'Outras Ações -> Vincular NF de Origem' do romaneio. "                    
					lRetorno := .f.					
				ElseIf nQtdRet <> NJJ->NJJ_QTDFIS .AND. NJJ->NJJ_TPFORM == "2"
					AgrHelp(STR0001,STR0035,STR0088) //#Ajuda #"Quantidade fiscal está diferente da quantidade das notas fiscais de origem vinculadas." #"Verifique as quantidades das notas vinculadas na opção 'Outras Ações -> Vincular NF de Origem' do romaneio."                    
					lRetorno := .F.
				EndIf

				// Realiza a quebra da NJM conforme as notas fiscais informadas na N9E (Integrações do Romaneio)
				If lRetorno .AND. !OG250DQDEV(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
					lRetorno := .F.
				EndIf
			EndIf				
		EndIf

		If .Not. OGA250ENTOK() // Valida informações do fornecedor associado a entidade			
			lRetorno := .F.  
		EndIf

		//If NJJ->( NJJ_TIPO ) <> "1" //romaneio de produção não tem validação na NJM
		If lRetorno .AND. NJJ->( NJJ_TIPO ) $ "2|3|4|5|6|7|8|9"
			dbSelectArea( "NJM" )
			dbSetOrder( 1 )
			dbSeek( FWxFilial( "NJM" ) + NJJ->( NJJ_CODROM ) )
			While .Not. Eof() .And. NJM->(NJM_FILIAL) = FWxFilial( "NJM" ) .And. NJM->(NJM_CODROM) = NJJ->( NJJ_CODROM ) .And. lRetorno

				If  __lnewNeg
					/* Se o produto não é algodão (grãos), tem rastro por lote e não tem lote na NJM */
					If !AGRTPALGOD(NJJ->NJJ_CODPRO).And. Rastro(NJM->NJM_CODPRO) .And. Empty(NJM->NJM_LOTCTL)
						IF (NJM->NJM_SUBTIP $ '20|21|40|41|42|44|46|52|71' .And. !lRastFIFO ) .Or. !(NJM->NJM_SUBTIP $ '20|21|40|41|42|43|44|45|46|52|71') 
							AgrHelp(STR0001,STR0034,STR0084 + alltrim(NJJ->NJJ_CODPRO) + STR0085) //#Ajuda #"Este produto possui rastro por lote." #"Informe lote para o produto " #" na aba de comercialização."                                                
							lRetorno := .F.                            
							Exit
						EndIf									
					EndIF

					/* Se o produto não é algodão (grãos),Se o produto nao controla rastro e foi informado Lote, nao deve permitir continuar */
					If  !AGRTPALGOD(NJJ->NJJ_CODPRO) .AND. !Rastro(NJM->NJM_CODPRO) .AND. !Empty(NJM->NJM_LOTCTL)
						AgrHelp(STR0001,STR0044,STR0089) //#Ajuda #"Foi informado lote para um produto que não possui rastro." #"Remova o lote informado na aba comercialização."                        
						lRetorno := .F.
						Exit
					EndIf  
				EndIf

				// Se contrato não foi informado
				If Empty(NJM->( NJM_CODCTR )) .AND. !__lnewNeg

					// Tenta buscar o contrato automaticamente, se houver APENAS UM para a condição: mesma entidade, loja, safra e produto. 
					// OGX010BC = Rotina auxiliar para seleção de contratos;   OGX010TC = Converte o tipo do romaneio no tipo do contrato.
					cCodCtr := OGX010BC(OGX010TC(NJJ->(NJJ_TIPO)), NJM->(NJM_CODENT), NJM->(NJM_LOJENT), NJM->(NJM_CODSAF), NJM->(NJM_CODPRO))[1]
				
					// Caso não encontre somente 1 contrato válido, abre tela para informar o contrato.
					If Empty( cCodCtr )
						OGX010CT(OGX010TC(NJJ->(NJJ_TIPO)) , NJM->(NJM_CODENT), NJM->(NJM_LOJENT), NJM->(NJM_CODSAF), NJM->(NJM_CODPRO),.T.)
						cCodCtr := __cCodigo
					EndIf

					If Empty( cCodCtr )
						cMsgErro  += Chr(13) + STR0012	//#"Um ou mais contratos nao foram informados, ou o sistema nao pode determinar um contrato automaticamente."
						cMsgSoluc += STR0091            //#"Informe um contrato."
                        lRetorno := .f.
						Exit
					EndIf

				Else
					cCodCtr := NJM->( NJM_CODCTR )
				EndIf

				If lGerencial
					// Verifica se o contrato é válido para um Romaneio Gerencial
					If ! OGA255VCTR( "GRID", cCodCtr )
						lRetorno := .f.
						Exit
					EndIf
				EndIf


				NJR->( dbSetOrder( 1 ) )
				If 	NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtr ) )
					If NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. ( __lnewNeg .OR. (!__lnewNeg .AND. NJR->NJR_TIPO == "2"))
						If !NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM
							cValid := .T.
						EndIf
					Else
						cValid := .T.
					EndIf

					If cValid
						/* Validar a quantidade autorizada apenas para contratos que não sejam automáticos */
						If   NJR->( NJR_MODELO ) <> "3" ;   // 3= Automatico 
						.or. NJJ->NJJ_TIPO       == "6" ;   // 6= (S) Devolucao de Deposito
						.or. NJJ->NJJ_TIPO       == "7" ;   // 7= (E) Devolucao de Remessa     
						.or. NJJ->NJJ_TIPO       == "8" ;   // 8= (S) Devolucao de Compra       
						.or. NJJ->NJJ_TIPO       == "9"     // 9= (E) Devolucao de Venda     

							If NJR->NJR_CLASSP == "2"
								nQtdEContr := NJR->NJR_QTEFIS
								nQtdSContr := NJR->NJR_QTSFIS

								If NJM->( NJM_TPFORM ) = "1" .and. !lGerencial .and. !lSimbolico
									nQtdRoman := NJM->( NJM_QTDFCO )
								Else
									nQtdRoman := NJM->( NJM_QTDFIS )
								EndIf								
							Else
								nQtdEContr := NJR->NJR_QTEFCO
								nQtdSContr := NJR->NJR_QTSFCO
								nQtdRoman  := NJM->NJM_QTDFCO
							EndIf     

							If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
								//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM
								IF NJR->NJR_CLASSF == "2" .AND. NJJ->(NJJ_TIPO) == '5' .and.  NJJ->(NJJ_TPFRET)  = 'F' .and. NJM->( NJM_TPFORM ) = "1"  
									nQtdEContr := NJR->NJR_QTEFIS
									nQtdSContr := NJR->NJR_QTSFIS
									nQtdRoman := NJM->( NJM_QTDFIS )								
								EndIf
							EndIf

							// saldo contrato 
							Do Case         
								Case NJJ->NJJ_TIPO == "2" // 2= (S) Remessa para Deposito
								nQtSdoCtr := NJR->NJR_QTDCTR - ( nQtdSContr + nQtdRoman )
								Case NJJ->NJJ_TIPO == "3" // 3= (E) Entrada para Deposito
								nQtSdoCtr := NJR->NJR_QTDCTR - ( nQtdEContr + nQtdRoman )
								Case NJJ->NJJ_TIPO == "4" // 4= (S) Saida por Venda   
								nQtSdoCtr := (NJR->NJR_QTDCTR + nQtdEContr )  - ( nQtdSContr + nQtdRoman ) 
								Case NJJ->NJJ_TIPO == "5" // 5= (E) Entrada por Compra
								nQtSdoCtr := (NJR->NJR_QTDCTR + nQtdSContr )  - ( nQtdEContr + nQtdRoman )
							EndCase 

							If  NJJ->NJJ_TIPO $ "2|3|4|5" .AND. nQtSdoCtr < 0 

								lErrExc := .T.


								//Verifica se contrato permite excedente ==> 1-Não permite;2-Última Carga;3-%Tolerância
								If AGRColPos('NJR_TPEXC') .AND. NJR->NJR_TPEXC == '2' //Última Carga
									//Gera Aditivo no Contrato
									lErrExc := !(OGA250ExcC(nQtSdoCtr * -1 )) 
									nQtAtuAut := nQtSdoCtr * -1
								ElseIf AGRColPos('NJR_TPEXC') .AND. NJR->NJR_TPEXC == '3' //% Tolerância DAGROGAP-708
									DbSelectArea("NNW")
									NNW->(dbGoTop())
									While !Eof()
										If NNW->(NNW_ADEXCE) = "1" .And. NNW->(NNW_CODCTR) = NJR->NJR_CODCTR .And.;
										NNW->(NNW_TIPO) == "1" .And. NNW->(NNW_STATUS) = "2"
											nTotAdtv += NNW->NNW_QTDALT
										EndIf
										("NNW")->( dbSkip() )
									EndDo
									NNW->(dbCloseArea())

									//Verifica se o contrato controla o saldo por 1-Física, 2=Fiscal
									IF NJR->(NJR_CLASSP) == "1"
										nSaldCrt := NJR->(NJR_QSLFCO)	
									Else
										nSaldCrt := NJR->(NJR_SLDFIS)
									EndIf
									
									//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM										
									If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
										IF NJR->NJR_CLASSF == "2" .AND. NJJ->NJJ_TPFRET = 'F' .and. NJM->( NJM_TPFORM ) = "1" .and. NJJ->NJJ_TIPO == "5" // 2 = Contrato Fob Origem F=Frete FOB  1=Formulario Proprio 5= (E) Entrada por Compra
											SaldCrt := NJR->(NJR_SLDFIS)
										EndIf
									EndIf								

									//Quantidade a considerar do contrato
									nQtdCons := NJR->(NJR_QTDCTR) - nTotAdtv
									//Quantidade excedente tolerada
									nQtdExcTo := (nQtdCons * (NJR->(NJR_TOLENT)/100))
									//Quantidade restante do contrato
									nQtdResta := (nSaldCrt  + nQtdExcTo - nTotAdtv)																
									//Cria o aditivo conforme quantidade restante do contrato vs. peso liq. romaneio  
									If nSaldCrt > 0 .And. nQtdRoman <= nQtdResta
										nQtAtuAut := nQtdRoman - nSaldCrt 
										lErrExc := !(OGA250ExcC(nQtAtuAut)) 
									ElseIf nQtdRoman <= nQtdResta 
										lErrExc := !(OGA250ExcC(nQtdRoman))
										nQtAtuAut := nQtdRoman
									EndIf
								EndIF

								If lErrExc									
									cMsgErro  += Chr(13) + STR0013  //#"Quantidade do romaneio maior que o saldo físico do contrato."
                                    cMsgSoluc += STR0092            //#"Ajuste a quantidade no romaneio ou realize uma aditação no contrato."
                                    lRetorno := .f.
									Exit
								Else
									// Buscar a Autorização referente ao contrato selecionado 
									cCodAutorz := OGX010SAut( cCodCtr, NJJ->( NJJ_TIPO ) )

									AtualizaNJP( xFilial( "NJP" ) + NJR->( NJR_CODCTR ) + cCodAutorz , nQtAtuAut, nQtAtuAut )

									// Atualiza autorizações
									OGX010QAut()

								EndIf  

							EndIf

							If __lnewNeg .and. NJJ->NJJ_TIPO $ '4|5'
							//Valida o SALDO N9A com quantidade NJM 
								N9A->(DbSetOrder(1))
								If N9A->(DbSeek(xFilial("N9A")+NJM->(NJM_CODCTR)+NJM->(NJM_ITEM)+NJM->(NJM_SEQPRI)))
									If N9A->N9A_SDONF < nQtdRoman .AND. NJM->(NJM_TPFORM) == "1" .AND. ( NJR->NJR_TPEXC == "1" .OR. nQtSdoCtr > 0 ) //SE NÃO PERMITIR EXCEDENTE OU PERMITE E O CONTRATO AINDA TEM SALDO
										Agrhelp(STR0001,STR0067,STR0068) //Ajuda #"Romaneio possui itens da comercialização com quantidade maior que o saldo da regra fiscal do contrato." #"Ajuste os itens da comercialização do romaneio ou o Contrato/Regras fiscais."
										lRetorno := .f.
										exit
									EndIf
								EndIf
							EndIf

						EndIf  

						// reservas 
						if   (NJJ->NJJ_TIPO == "6" ;   // 6= (S) Devolucao de Deposito
						.AND.  (nQtdEContr - (nQtdSContr + NJR->NJR_QTDRES + nQtdRoman ) < 0)) ;
						.or. (NJJ->NJJ_TIPO == "7" ;   // 7= (E) Devolucao de Remessa     
						.AND.  (nQtdSContr - (nQtdEContr + NJR->NJR_QTDRES + nQtdRoman ) < 0)) ;
						.or. (NJJ->NJJ_TIPO == "8" ;   // 8= (S) Devolucao de Compra       
						.AND.  (nQtdEContr - (nQtdSContr + NJR->NJR_QTDRES + nQtdRoman ) < 0)) ;
						.or. (NJJ->NJJ_TIPO == "9" ;   // 9= (E) Devolucao de Venda     
						.AND.  (nQtdSContr - (nQtdEContr + NJR->NJR_QTDRES + nQtdRoman ) < 0)) 
							cMsgErro  += Chr(13) + STR0014	    //#"Quantidade Disponível no contrato insuficiente!"
							cMsgSoluc += STR0092                //#"Ajuste a quantidade no romaneio ou realize uma aditação no contrato."
                            lRetorno := .f.
							Exit
						EndIf 
						// Quando for retenção não exigir que seja informada autorização
						If NJJ->NJJ_TIPENT  <> "3" //0=Físico;1=Gerencial;2=Simbolico;3=Retenção

							// Se não foi informada Autorização Tenta Buscar Automaticamente
							IF NJR->( NJR_CTRLLG ) = "1" /* Ctrl.Logist -> 1=Sim */ .And. ;
							NJR->( NJR_CTRLCD ) <> "0" /* Ctrl.Ent/Sai -> 0=Nenhum */ .And. ;
							Empty(NJM->NJM_CODAUT)

								// Buscar a Autorização referente ao contrato selecionado 
								cCodAutorz := OGX010SAut( cCodCtr, NJJ->( NJJ_TIPO ) )

								If RecLock('NJM', .F.)
									If Empty(NJM->( NJM_CODCTR ))
										NJM->( NJM_CODCTR ) := cCodCtr
										NJM->NJM_FILORG     := FWxFilial("NJR")
									EndIf

									NJM->NJM_CODAUT := cCodAutorz 
									NJM->( msUnLock() )
								Endif

								If !Empty(NJJ->( NJJ_CODCTR ))
									If RecLock('NJJ', .F.)
										NJJ->NJJ_CODAUT := cCodAutorz 
										NJJ->( msUnLock() )
									Endif
								Endif
							Endif

							// Se mandante da classificação é 2-Fiscal então obriga informar a Qtd. Física - NJJ_PESO3 - DAGROGAP-446
							If  NJR->(NJR_CLASSP) = "2" .AND. !_lComplRom
								If Empty(NJJ->( NJJ_PESO3 ))
									AgrHelp(STR0001, STR0015,STR0090)    //#Ajuda #"Quantidade física não informada." #"Quando a classificação fiscal é 2-Fiscal deve ser informada a quantidade física."                                    
									cMsgErro  := STR0016 + " " + STR0015 //#"Quantidade física não informada."
                                    cMsgSoluc := STR0090                 //#"Quando a classificação fiscal é 2-Fiscal deve ser informada a quantidade física."
									lRetorno := .f.
									Exit 
								EndIf
							EndIF

							//salva a area da NJM posicionada - DAGROGAP-446
							aAreaNJM := NJM->(GetArea())
							lRestA := .T.

							//Grava o mandante da classificação na NJJ conforme NJR - DAGROGAP-446
							If  NJR->(NJR_CLASSP) = "1" .Or. NJR->(NJR_CLASSP) = ""
								If RecLock('NJJ', .F.)
									NJJ->(NJJ_TPCLAS) := "1"
									NJJ->( msUnLock() )
								EndIf
							Else
								If RecLock('NJJ', .F.)
									NJJ->(NJJ_TPCLAS) := "2"
									NJJ->( msUnLock() )
								EndIf
							EndIf

							//Grava o Valor dos campos nas variaveis para utilizar mais adiante - DAGROGAP-446
							cNfpSer := AllTrim(NJM->(NJM_NFPSER)) //correção DAGROBEN-240

							cNfpNum := AllTrim(NJM->(NJM_NFPNUM))

							//Refaz os calculos dos descontos conforme o mandante da classificação - DAGROGAP-446
							OGA250DCBrw(.T.)

							//Verifica as classificações obrigatórias confore mandante do romaneio - DAGROGAP-446
							If lRetorno
								lRetorno := OGA250PNJK(cCodCtr,lSimbolico)
								If !lRetorno									                                    
									lRetorno := .F.
									Exit
								EndIf   
							EndIf

						Endif

                        // Valida quantidade do romaneio com as quantidades do contrato e autorizações
                        If NJR->NJR_MODELO != "3"
                            If ! OGA250VAUT( cCodCtr, nQtAtuAut, nTotAdtv )                                
                                lRetorno := .F.
                                Exit
                            EndIf
                        EndIf
					Else					
						cNfpSer := AllTrim(NJM->(NJM_NFPSER))
						cNfpNum := AllTrim(NJM->(NJM_NFPNUM))		
					EndIf
				ElseIf !NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM					
                    cMsgErro  += Chr(13) + STR0018 + "[" + FWxFilial( "NJR" ) +" - " + cCodCtr + "]"     //#"Não existe o -Contrato- informado."
                    cMsgSoluc += STR0091                                                                 //#"Informe um contrato."
					lRetorno := .f.
					Exit
				EndIf	

				If !OGA330VLD( cCodCtr, NJJ->( NJJ_TIPO ) )					
					lRetorno := .f.
					Exit
				EndIf
				//Restaura a area da NJM posicionada anteriormente - DAGROGAP-446
				If lRestA
					RestArea(aAreaNJM)
					lRestA := .F.
				EndIf

				//Utiliza as variaveis alimentadas anteriormente - DAGROGAP-446
				If cPaisLoc <> "PAR" .And. cPaisLoc <> "ARG"
					If lUtiNfp == .F.	
						If NJM->NJM_TPFORM = "1";			// 1=Sim (form. próprio) 
						.And. NJJ->( NJJ_TIPO ) $ "3|5" 	// 3=(E) Entrada para Deposito; 5=(E) Entrada por Compra
							if ( Empty( cNfpSer ) .Or. Empty( cNfpNum));
							.And. NJJ->NJJ_TIPENT == "0" 	// 0=Fisico 
								cMsgErro  += Chr(13) + STR0093 //#"Nota fiscal do produtor não foi informada." 
								cMsgSoluc += STR0020           //#"Em caso de formulario proprio, favor prencher os campos referentes a Nota Fiscal do Produtor."
                                lRetorno := .f.
								Exit
							Endif
						EndIf
					EndIf
				EndIf

				If NJM->NJM_TPFORM = "2" ;			// 2=Não
				.And. NJJ->( NJJ_TIPO ) $ "1|3|5"	// 1=(E) Entrada por Producao; 3=(E) Entrada para Deposito; 5=(E) Entrada por Compra
					If cPaisLoc <> "PAR" .And. cPaisLoc <> "ARG"
						If Empty( AllTrim(NJM->NJM_DOCSER) ) .Or. Empty( AllTrim(NJM->NJM_DOCNUM) )
							cMsgErro  += Chr(13) + STR0094  //#'Nota fiscal de Terceiro/Trânsito não foi informada.' 
                            cMsgSoluc += STR0033            //#"Em caso de NF de Terceiro/Transito, favor prencher os campos referentes a Nota Fiscal do Terceiro/Trânsito."
							lRetorno := .f.
							Exit
						EndIf
					EndIf

					If NJM->NJM_DOCESP = "SPED" .And. Empty( AllTrim(NJM->NJM_CHVNFE) )
						cMsgErro  += Chr(13) + STR0095  //#"A chave acesso da NF-e não foi informada."
						cMsgSoluc += STR0021            //#"É obrigatório informar a Chave de acesso da NF-e quando a Espécie do Documento Fiscal é SPED."
                        lRetorno := .f.
						Exit
					EndIf

					If Empty(NJM->( NJM_LOCAL )) .And. Empty(NJJ->( NJJ_LOCAL ))
						cMsgErro  += Chr(13) + STR0096  //#"Local de estoque não foi informado."
                        cMsgSoluc += STR0022            //#"Informe o local de estoque na aba 'Análise' e na 'Comercialização'."
						lRetorno := .f.
						Exit
					EndIf
				EndIf

				RecLock( "NJM", .f. )
				NJM->( NJM_TIPO ) := NJJ->( NJJ_TIPO )

				If Empty(NJM->( NJM_TIPMOV ))
					NJM->( NJM_TIPMOV ) := "1" //1=Fisico; 2=Financeiro
				EndIf 

				If Empty(NJM->( NJM_CODCTR ))	
					NJM->( NJM_CODCTR ) := cCodCtr
					If NJM->(ColumnPos('NJM_FILORG')) > 0 .and. __lnewNeg


						NJM->( NJM_FILORG ) := FWxFilial("NJR")
					EndIf

				EndIf

				If Empty(NJM->( NJM_LOCAL ))	
					NJM->( NJM_LOCAL ) := NJJ->( NJJ_LOCAL )
				EndIf

				NJR->( dbSetOrder( 1 ) )
				NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )

				If !__lnewNeg .AND. NJJ->NJJ_TIPO == "4" //venda modelo classico OP. TRIANGULAR
					If NJR->(NJR_OPETRI) == "1" 
						NJM->NJM_SUBTIP := "45"
						NJM->NJM_IDMOV  := "45"
					EndIf
				EndIf

				// Se Formulário próprio = "SIM" e Tipo de Entrada <> "Gerencial"
				If  (NJM->( NJM_TPFORM ) = "1" .and. NJJ->( NJJ_TIPENT ) <> "1") .or. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //Dekalpar atualizar valor e quantidade 

					If .Not. lSimbolico
						if (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") 
							if NJM->( NJM_QTDFIS ) == 0
								NJM->( NJM_QTDFIS ) := NJM->( NJM_QTDFCO )
							EndIf
					    ELSE						
							if NJR->(FieldPos("NJR_CONPES") > 0)
								if (NJR->( NJR_CONPES )) = '2' //peso base
									NJM->( NJM_QTDFIS ) := NJJ->( NJJ_PSSUBT )
								else
									NJM->( NJM_QTDFIS ) := NJM->( NJM_QTDFCO )
								EndIf
							else
								NJM->( NJM_QTDFIS ) := NJM->( NJM_QTDFCO )
							endIf

							If NJR->(ColumnPos('NJR_CLASSF')) > 0 //Proteção Campo novo contrato			
								//NFP ENTRADA COMPRA COM FRETE FOB CONSIDERAR QUANTIDADE\QUALIDADE DA ORIGEM															
								IF NJR->NJR_CLASSF == "2" .AND. NJJ->(NJJ_TPFRET) == "F" .AND. NJJ->(NJJ_TIPO)== '5' 							   
									// Se for entrada Com nota do produtor e o contrato permitir controle de frete FOB na Origem 
									// Se romaneio tem pesagem (físico) e o tipo de frete é FOB(por conta da empresa), 
									// Significa que a qtde física foi pesada na origem, então não pode penalizar o produtor
									NJM->( NJM_QTDFCO	) := NJM->( NJM_QTDFIS )						
								ENDIF
							ENDIF	
						endIf
					EndIf

					/*** Executa precificação ****/
					If __lnewNeg .AND. NJM->NJM_SUBTIP $ "21|40|41|42|43|45|48|50|51"  //subtipos que executa a precificação
						lUpdRegFis := .F.

						If NJM->NJM_SUBTIP $ "21|40|41|42|45|48|50" //subtipos que consome qtd na regra fiscal(N9A)
							lUpdRegFis := .T. //.T. consome qtd/saldos regra fiscal
						EndIf						

						//Grãos - contrato fixo que nao tem preço nao pode atualizar romaneio
						// avaliar pra trocar por gatilho q vai travar e niciar campo que existe no contrato
						IF  NJR->NJR_TIPFIX == "1" .and. !AGRTPALGOD(NJJ->NJJ_CODPRO) .and. NJM->NJM_SUBTIP <> "21"
							nQtd := 0 												
							DbSelectArea("N8D") 
							N8D->(DbSetOrder(3))
							//If N8D->(DbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR )  + NJM->NJM_ITEM  ))
							If N8D->(DbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )
								//While N8D->( !Eof() ) .and. alltrim(N8D->(N8D_FILIAL+N8D_CODCTR+N8D_CODCAD))= alltrim(FWxFilial( "NJR" ) + NJM->( NJM_CODCTR )  + NJM->NJM_ITEM )
								While N8D->( !Eof() ) .and. alltrim(N8D->(N8D_FILIAL+N8D_CODCTR )) = alltrim(FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) )
									if (N8D_CODCAD+N8D->N8D_REGRA) ==  (NJM->NJM_ITEM+NJM->NJM_SEQPRI)
										nQtd += N8D->N8D_QTDVNC - N8D->N8D_QTDFAT
									endif
									N8D->(DbSkip())
								EndDo		
							EndIf

							IF nQtd - NJM->( NJM_QTDFIS ) < 0													
								lExcedente := .F.
								IF NJR->NJR_TPEXC == '3'
									cSqlN8D := "SELECT SUM((N8D_QTDVNC) * (1 + NJR_TOLENT / 100 ) ) MAXREGFIS, " + ;
									"SUM( N8D_QTDFAT ) SQTDFAT " + ;
									"FROM " + RetSqlName("N8D")+ " N8D " + ;
									"INNER JOIN " + RetSqlName("NJR")+ " NJR ON " + ;
									"  NJR_FILIAL = '"+ fwxFilial("NJR") +"' AND " + ;
									"  N8D_CODCTR = NJR_CODCTR AND " + ;
									"  N8D.D_E_L_E_T_ = NJR.D_E_L_E_T_ " + ;
									"WHERE N8D_CODCTR = '" + NJM->NJM_CODCTR + "' " + ;
									" AND N8D_FILIAL = '"+ fwxFilial("N8D") +"' " + ;
									"  AND N8D_CODCAD = '" + NJM->NJM_ITEM + "' " + ;
									"AND N8D.D_E_L_E_T_ = ' '" "
									aN8DSld := {}
									aN8DSld := GetDataSqA(cSqlN8D)
									//Verifica se a quantidade da NJM é maior que o saldo disponivel considerando a tolerância do contrato
									lExcedente := !((aN8DSld[1] - aN8DSld[2] )- NJM->( NJM_QTDFIS ) < 0) //Saldo >= 0   Então OK!!
							    ElseIf NJR->NJR_TPEXC == '2'
									lExcedente := .T.
								EndIf

								If !lExcedente
									cMsgErro  += Chr(13) + STR0097 //#"Não foi encontrada precificação priorizada. "
                                    cMsgSoluc += STR0051 + NJM->( NJM_CODCTR ) 	//#"Precificação para o contrato Fixo deve ser priorizada. Acesse no contrato 'Outras Ações -> Precificação'. Contrato: "
									lRetorno := .f.
									Exit
								EndIf
							EndIF
						EndIF

						//chama rotina que executa a precificação retornando o preço medio
						aRetorno := OG250DMPRC(NJM->NJM_FILIAL, NJM->NJM_CODROM,NJM->NJM_ITEROM,lUpdRegFis)
						If Empty(aRetorno[2])//não teve erros
							NJM->NJM_VLRUNI := aRetorno[1]
						Else
							cMsgErro += Chr(13) + aRetorno[2] 	//#"Erro no processo de precificação: "
                            cMsgSoluc += STR0098                //#"Verifique as fixações de preço do contrato."
							lRetorno := .f.
							Exit		
						EndIf

					EndIf
					/*** Fim execução precificação  ****/

					//realizado ajuste no if pois nao encontramos logica no que estava sendo feito.
					If NJM->( NJM_VLRUNI ) == 0 .AND. aRetorno[1] == 0 ///(NJM->( NJM_VLRUNI ) == 0 .or. (cPaisLoc != "PAR" .and. cPaisLoc != "ARG")) .AND. aRetorno[1] == 0 //Dekalpar
						If .Not. Empty( NJR->( NJR_CODIDX ) )
							NK0->( dbSetOrder( 1 ) )
							If NK0->( dbSeek( xFilial( "NK0" ) + NJR->( NJR_CODIDX ) ) )

								// Busca valor do índice de acordo com o tipo de cotação (diária ou mais atual)
								nVlrUni := AgrGetInd( NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase, NJR->NJR_CODPRO, '', NJR->NJR_CODSAF )

								If Empty( nVlrUni )
									IF NK0->NK0_TPCOTA == 'A'										
                                        cMsgErro  += Chr(13) + STR0023 + NJR->( NJR_CODIDX )	//#"Não existe Cotação ou a Cotação mais Atual está com valor zero. Código do índice: "                                        
										cMsgSoluc += STR0099                                    //#"Verifique a cotação para o índice."
                                        lRetorno := .f.
										Exit						   
									Else // 'D'
										cMsgErro += Chr(13) + STR0026 + NJR->( NJR_CODIDX )	    //#"Não existe cotação de índice para o dia na tabela: "
										cMsgSoluc += STR0099                                    //#"Verifique a cotação para o índice."
                                        lRetorno := .f.
										Exit
									EndIF
								EndIf
								// Converte a Cotação do Índice (NK1) da unidade de medida do indice (NK0) para a unidade de medida do Contrato (NJR)
								//_NK1VALOR := AGRX001( NJR->NJR_UM1PRO, NK0->NK0_UM1PRO, NK1->NK1_VALOR )
								_NK1VALOR := AGRX001( NJR->NJR_UM1PRO, NK0->NK0_UM1PRO, nVlrUni, NJR->NJR_CODPRO )
								//nVlrUni := IIf( NK0->( NK0_MOEDA ) != 1, xMoeda( _NK1VALOR, NK0->( NK0_MOEDA ), 1, dDataBase ), _NK1VALOR )
								IF ! NK0->( NK0_MOEDA ) = 1   // Moeda do indice é diferente de 1;
									nVlrUni :=  xMoeda( _NK1VALOR, NK0->( NK0_MOEDA ), 1, dDataBase )
									IF ! nVlrUni > 0
										cMsgErro += Chr(13) + STR0024				//#"O índice que está sendo Utilizado no Contrato está com a moeda "  
										cMsgErro += ' ' + STRZERO(NK0->NK0_MOEDA,1)
                                        cMsgErro += STR0100                         //#" e não foi encontrada cotação."
										cMsgSoluc+= STR0025							//#'Favor cadastrar o valor da moeda no sistema.' 
										lRetorno := .f.
										Exit
									EndIF
								Else
									nVlrUni := _NK1VALOR
								EndIF 
							Else
								cMsgErro  += Chr(13) + STR0027 + NJR->( NJR_CODIDX )	//#"Índice não encontrado na tabela de Índices (NK0): "
                                cMsgSoluc += STR0101                                    //#"Informe um índice válido no contrato."
								lRetorno := .f.
								Exit
							EndIf
						Else
							//nVlrUni := IIf( NJR->( NJR_MOEDA ) != 1, xMoeda( NJR->NJR_VLRBAS, NJR->NJR_MOEDA, 1, dDataBase ), NJR->( NJR_VLRBAS ) )

							IF ! NJR->( NJR_MOEDA ) = 1
								If NJR->NJR_TXMOED > 0 //taxa moeda fixa no contrato
									nVlrUni := xMoeda( NJR->NJR_VLRBAS, NJR->NJR_MOEDA, 1, dDataBase, , NJR->NJR_TXMOEDA, 1 )									
								Else 
									nVlrUni := xMoeda( NJR->NJR_VLRBAS, NJR->NJR_MOEDA, 1, dDataBase )
								EndIf
								IF ! nVlrUni > 0									
                                    cMsgErro += Chr(13) + STR0028			            //#"A moeda do contrato, não possui valor cadastrado no sistema."		
                                    cMsgErro += ' ' + STRZERO(NJR->NJR_MOEDA,1) + '.'
                                    cMsgSoluc += STR0025                                 //#"Favor cadastrar o valor da moeda no sistema."
									lRetorno := .f.
									Exit
								EndIF					  	
							Else
								nVlrUni := NJR->NJR_VLRBAS
							EndIF

							IF ! Alltrim(NJR->NJR_UMPRC) = Alltrim( NJJ->NJJ_UM1PRO )//--<< UM do produto não é Igual  a UM de Preço do Contrato >>--
								nQTUmPRC := AGRX001( NJR->NJR_UMPRC , NJJ->NJJ_UM1PRO ,1, NJR->NJR_CODPRO) 
								nVlrUni := nVlrUni / nQTUmPRC
							EndIF

							If nVlrUni <= 0
								cMsgErro += Chr(13) + STR0029 + NJM->( NJM_CODCTR ) + STR0030	//#'Valor base do contrato: '###' não pode ser 0.'
                                cMsgSoluc += STR0102                                            //#"Informe o valor base no contrato."
								lRetorno := .f.
								Exit
							EndIf
						EndIf
						If  .NOT. Empty("NJM_VLRUNI") .AND. .NOT. NJM->( NJM_VLRUNI ) = 0 //correção para usar o valor unitário informado no romaneio
							NJM->( NJM_VLRUNI ) :=  NJM->( NJM_VLRUNI ) 
						Else
							NJM->( NJM_VLRUNI ) := Round( nVlrUni, TamSX3( "NJM_VLRUNI" )[2] ) // se valor unitario no romaneio for vazio ou 0 utiliza-se o valor unitario do contrato
						EndIf					
					EndIf				
				EndIf

				If __lnewNeg
					// Validar preco minimo aviso dco - PEPRO - PEP
					If NJJ->(NJJ_TIPO) $ "4" .AND. NJM->(ColumnPos('NJM_NUMAVI')) > 0 .AND. !Empty(NJM->NJM_NUMAVI) // venda	
				
						/* Verifica se é um romaneio mercado interno/externo */
						cTMerc := OG250DVMI()
											
						If !OGX810VPRC(NJM->NJM_NUMAVI, NJM->NJM_VLRUNI, cTMerc, NJM->NJM_CODENT, NJM->NJM_LOJENT,; 
									NJM->NJM_FILORG, NJM->NJM_CODCTR, NJM->NJM_ITEM, NJM->NJM_SEQPRI, NJM->NJM_FILIAL)
							EXIT
						EndIf				
					
					ElseIF NJJ->(NJJ_TIPO) $ "2" .and. __lnewNeg .AND. NJM->NJM_SUBTIP $ "21" //remessa 
						If AGRTPALGOD(NJJ->NJJ_CODPRO) // algodao
						//TODO: Validação do preço para remessa formação de lote de algodão
						EndIF									
					EndIf
					//FIM Validar preco minimo aviso dco - PEPRO - PEP	

					//Atualiza a previsão de recebimento DCO
					If NJJ->(NJJ_TIPO) $ "4" .And. lRetorno .AND. NJM->(ColumnPos('NJM_NUMAVI')) > 0 .AND. !Empty(NJM->NJM_NUMAVI) // venda
						
						//Atualiza a previsão de recebimento DCO
						If aScan(aDcos, NJM->NJM_NUMAVI+NJM->NJM_NUMDCO) == 0
							Processa({|| OGA810AVLP(NJM->NJM_FILIAL, NJM->NJM_NUMAVI, NJM->NJM_NUMDCO)}, STR0050) //"Atualizando previsão de recebimento do DCO..."
							aAdd(aDcos, NJM->NJM_NUMAVI+NJM->NJM_NUMDCO)
						EndIf

					EndIf

				Endif
				If NJJ->NJJ_TPFORM == '1' //Só recalcula o total se for formulario proprio
					NJM->( NJM_VLRTOT ) := NJM->( NJM_VLRUNI ) * NJM->( NJM_QTDFIS )
				EndIf
				If NJJ->( NJJ_TIPO ) $ "1|2|3|4|5|A|B"
					NJM->( NJM_TRANS ) := "1" // 1=Entrega
				Else
					NJM->( NJM_TRANS ) := "2" // 2=Devolução
				EndIf

				If NJR->NJR_TIPO = "2" //Venda
					If Empty(NJM->( NJM_CONDPG ))
						NJM->( NJM_CONDPG ) := SuperGetMV( "MV_AGRCPVD", .f., " " ) 

						If Empty(NJM->( NJM_CONDPG ))
							NJM->( NJM_CONDPG ) := SuperGetMV( "MV_CONDPAD", .f., "001" )
						Endif
					EndIf
				Else
					If Empty(NJM->( NJM_CONDPG ))
						NJM->( NJM_CONDPG ) := SuperGetMV( "MV_CONDPAD", .f., "001" ) 
					EndIf
				Endif

				/////////////////////////
				/// Tratamento da TES ///
				/////////////////////////

				// Se o usuário não informou a TES no item do romaneio (NJM)
				IF Empty(NJM->( NJM_TES ))

					// Se foi informada a TES no cabeçalho do romaneio
					If ! Empty( NJJ->( NJJ_TES ) )
						// Atribui a TES do cabeçalho do romaneio ao item
						NJM->( NJM_TES ) 	:= NJJ->( NJJ_TES )

					Else // Senão, usuário não informou nenhuma TES. 
						// Então busca a TES automaticamente do contrato, e caso for romaneio tipo 6 ou 7

						If NJM->( NJM_TIPMOV ) = "2" .OR. ( !__lnewNeg .AND. NJM->(NJM_SUBTIP) == "45") //1=Física;2=Financeira ou OP. Triangular venda classica
							NJM->( NJM_TES ) 	:= NJR->( NJR_TESFIN )
							NJJ->( NJJ_TES )    := NJR->( NJR_TESFIN )
						Else
							NJM->( NJM_TES )	:= NJR->( NJR_TESEST )
							NJJ->( NJJ_TES )    := NJR->( NJR_TESEST )
						EndIf

						If NJM->NJM_TRANS = "2" // 2=Devolução
							//TES DEVOLUCAO
							dbSelectArea("SF4")
							SF4->( dbSetOrder( 1 ) )
							If SF4->( dbSeek( FWxFilial( "SF4" ) + NJM->( NJM_TES ) ) )

								NJM->( NJM_TES ) := ""

								If !Empty (SF4->(F4_TESDV))
									NJM->( NJM_TES ) := SF4->(F4_TESDV)
									NJJ->( NJJ_TES ) := SF4->(F4_TESDV)
								EndIf
							Else
								NJM->( NJM_TES ) := ""							
							EndIf
						EndIf

						If Empty( NJM->( NJM_TES ) ) .Or. NJJ->( NJJ_TIPO ) $ "6|7" // 6 - (S) Devolução de Depósito | 7 - (E) Devolução de Remessa

							// Abre a tela de diálogo para o usuário confirmar a TES
							cTes := OGA250GTES( NJM->( NJM_TES ), NJJ->( NJJ_TIPO ) )

							If !Empty(cTes)
								NJM->( NJM_TES ) := cTes
							Else
								lRetorno := .F.
								Exit
							EndIf

						EndIf

					EndIf
				EndIF

				IF !Empty(NJM->( NJM_TES ))
				   // Senão, se a TES já foi informada no item do romaneio (NJM), valida abaixo...

					// Verifica se a TES informada está de acordo com o tipo do romaneio
					If .Not. OGA250VTES( NJM->( NJM_TES ), NJJ->( NJJ_TIPO ) )

						// Se não estiver ok, abre a tela de diálogo para o usuário confirmar a TES
						cTes := OGA250GTES( NJM->( NJM_TES ), NJJ->( NJJ_TIPO ) )

						If !Empty(cTes)
							NJM->( NJM_TES ) := cTes
						Else
							lRetorno := .F.
							Exit
						EndIf

					EndIf	

				EndIf

				If !__lnewNeg .AND. NJM->NJM_TIPO == "4" .AND. NJM->NJM_SUBTIP == "45" .AND. Alltrim(NJM->( NJM_TES )) != NJR->NJR_TESFIN 
					cMsgErro += Chr(13) + STR0103 + NJM->( NJM_CODCTR )	//##"TES Informada é divergente da TES do contrato "
					cMsgSoluc += STR0104 //##"Para contrato com operação trianguar, devrá ser informado a mesma TES do contrato que movimenta financeiro. "
					lRetorno := .f.
					Exit
				EndIf

				//Tratamento Classe de Valor
				IF NJM->(ColumnPos('NJM_CLVL')) > 0 .and. __lnewNeg .and. Empty(NJM->( NJM_CLVL ))
					NJM->( NJM_CLVL ) 	:= NJR->( NJR_CLVL )
				endif				

				If lGerencial
					NJM->( NJM_DTRANS ) := dDataBase
				EndIf

				NJM->( msUnLock() )

				If NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. __lnewNeg
					//Atualiza Contrato caso tipo de movimento do romaneio seja fisico // 1=Fisico
					If NJM->( NJM_TIPMOV ) = "1" .AND. !NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM 

						NJR->( dbSetOrder( 1 ) )
						NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )
						If RecLock( "NJR", .f. )
							If NJJ->( NJJ_TIPO ) $ "1|3|5|7|9"
								NJR->( NJR_QTEFCO ) += NJM->( NJM_QTDFCO )
								NJR->( NJR_QTEFIS ) += NJM->( NJM_QTDFIS ) 
								NJR->( NJR_VLEFIS ) += NJM->( NJM_VLRTOT ) 
							Else
								NJR->( NJR_QTSFCO ) += NJM->( NJM_QTDFCO )
								NJR->( NJR_QTSFIS ) += NJM->( NJM_QTDFIS ) 
								NJR->( NJR_VLSFIS ) += NJM->( NJM_VLRTOT )
							EndIf
							NJR->( msUnLock() )
						EndIf

						// Atualiza qtdes do contrato				
						OGX010QTDS()

					EndIf
				ElseIf  NJM->( NJM_TIPMOV ) = "1" .and. !__lnewNeg  
					NJR->( dbSetOrder( 1 ) )
					NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )
					If RecLock( "NJR", .f. )
						If NJJ->( NJJ_TIPO ) $ "1|3|5|7|9" //entrada 
							NJR->( NJR_QTEFCO ) += NJM->( NJM_QTDFCO )
							NJR->( NJR_QTEFIS ) += NJM->( NJM_QTDFIS ) 
							NJR->( NJR_VLEFIS ) += NJM->( NJM_VLRTOT ) 
						Else //saida
							//verifica se o contrato é de Venda futura
							If NJR->( NJR_OPEFUT ) == '1' //venda futura 

								//verifica se a TES movimenta estoque
								If Posicione('SF4',1,fwxFilial("SF4")+NJM->( NJM_TES ),'F4_ESTOQUE') == "S" //movimenta
									NJR->( NJR_QTSFCO ) += NJM->( NJM_QTDFCO )									
								Else //não movimenta estoque (apenas duplicada)
									NJR->( NJR_QTSFIS ) += NJM->( NJM_QTDFIS ) 
									NJR->( NJR_VLSFIS ) += NJM->( NJM_VLRTOT )
								EndIf

							Else //saida normal.
								NJR->( NJR_QTSFCO ) += NJM->( NJM_QTDFCO )
								NJR->( NJR_QTSFIS ) += NJM->( NJM_QTDFIS ) 
								NJR->( NJR_VLSFIS ) += NJM->( NJM_VLRTOT )
							EndIf
						EndIf
						NJR->( msUnLock() )
					EndIf

					// Atualiza qtdes do contrato				
					OGX010QTDS()

				EndIf

				If NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. __lnewNeg
					// Atualizando Autorizacoes
					If !Empty( NJM->NJM_CODAUT ) .AND. !NJM->NJM_SUBTIP $ "43|46|51" // (S) VENDA ENTREGA FUTURA / (S) REMESSA POR VENDA A ORDEM
						
						AtualizaNJP( xFilial( "NJP" ) + NJM->( NJM_CODCTR ) + NJM->( NJM_CODAUT ) , NJM->( NJM_QTDFCO ), NJM->( NJM_QTDFIS ) )

					EndIf
				ElseIf !Empty( NJM->NJM_CODAUT ) .and. !__lnewNeg .and. !NJM->NJM_SUBTIP $ "46" //(S) REMESSA POR VENDA A ORDEM
					
					AtualizaNJP( xFilial( "NJP" ) + NJM->( NJM_CODCTR ) + NJM->( NJM_CODAUT ) , NJM->( NJM_QTDFCO ), NJM->( NJM_QTDFIS ) )

				EndIf
				
				If NJM->(ColumnPos('NJM_SUBTIP')) > 0 
					If  NJM->NJM_SUBTIP = '45' //Venda a Ordem
						aAux:={}
						For nIt := 1 To Len(aStruct)
							AADD(aAux,{ aStruct[nIt][1] , NJM->&(AllTrim(aStruct[nIt][1]))  } )
						Next nIt
						AADD(aNJM,aAux)
						cSeq := NJM->NJM_ITEROM
					EndIf
				EndIf
				// Passa para o próximo registro de NJM
				NJM->( dbSkip() )
			EndDo	
			//Retorna area para evitar problemas de saldo/posição do laço
			RestArea(aAreaNJM)		
		EndIf

		If lRetorno .AND. NJJ->( NJJ_TIPO ) = '1'
			//Verifica as classificações obrigatórias conforme mandante do romaneio - DAGROGAP-446
			If !OGA250PNJK(,lSimbolico)
				DisarmTransaction()
				break
				lRetorno := .F.
			EndIf   
		EndIf

		If .Not. lRetorno
			If !empty(cMsgErro)
				AgrHelp(STR0001, cMsgErro, cMsgSoluc) //###'Ajuda'                
			EndIf
			DisarmTransaction()
			break
		Else

			If NJJ->(ColumnPos('NJJ_DTULAL')) > 0 .and. __lnewNeg
				If RecLock('NJJ', .F.)
					NJJ->NJJ_DTULAL := dDataBase
					NJJ->NJJ_HRULAL := Time()
					NJJ->(MsUnLock())
				EndIf
			EndIf


			If NJJ->( NJJ_TIPO ) $ '3|5'
				If !OGA200GrRsv( NJJ->(NJJ_CODROM) ) //caso não consiga criar a reserva se houver
					DisarmTransaction()
					break
					lRetorno := .f.
				EndIf
			EndIf

			If lRetorno
				//Criar registro de comercialização para a Remessa por Ordem Terceiros (DAGROGAP-4141)
				If Len(aNJM) > 0 .and. !copyNJM(aNJM,cSeq)
					DisarmTransaction()
					break
					lRetorno := .f.
				EndIf

				dbSelectArea( "NJJ" )
				If NJJ->(RecLock( "NJJ", .f. ))
					If lGerencial
						NJJ->( NJJ_STATUS ) := "3" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
						NJJ->( NJJ_DTRANS ) := dDataBase
					Else
						NJJ->( NJJ_STATUS ) := "2" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado
					EndIf
					If Empty(NJJ->( NJJ_CODCTR )) 
						If !lUsaIE //nao tem IE
							NJJ->( NJJ_CODCTR ) := cCodCtr 
						EndIf
						If NJJ->(ColumnPos('NJJ_FILORG')) > 0 .and. __lnewNeg
							NJJ->NJJ_FILORG		:= FWxFilial("NJR")
						EndIf
						NJJ->( NJJ_STACTR ) := "2" //1=Sem CTR;2=Com CTR
					EndIf
					msUnLock()
				EndIf
			EndIf
		EndIf

		If lRetorno .AND. __lnewNeg
			If (NJJ->NJJ_TIPO <> "1" .AND. NJJ->NJJ_TIPO <> "A" .AND. NJJ->NJJ_TIPO <> "B")
				/* Grava as quantidades informadas na NJM (Comercialização) das regras fiscais das IEs e do contrato */
				If !OG250DGQTD(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, .T.)
					DisarmTransaction()
					break
					lRetorno := .F.
				EndIf	

				/* Atualiza a quantidade do retorno formação de lote */
				If lRetorno .AND. NJJ->NJJ_TIPO == "7"
					If !OG250HRN9I(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, .T.)
						DisarmTransaction()
						break
						lRetorno := .F.
					EndIf
				EndIf	

				/* Atualiza a quantidade instruida da IE (N7Q/N7S) considerando o ganho de peso */
				/* Apenas para algodão */
				If lRetorno .AND. AGRTPALGOD(NJJ->NJJ_CODPRO) 
					OG250EAQIE('07', NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
				EndIf
			EndIf
		EndIf

	END TRANSACTION

	AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+NJJ->( NJJ_CODROM ),"T", STR0032 + " " + cMsgErro})	//"Atualizar"
	
	//Se não for gerencial e não estiver vindo do 'SALVAR' do romaneio unificado
	If !lGerencial .AND. !(ISINCALLSTACK('AGRA500') .AND. ISINCALLSTACK('GrvModelo'))
		If .NOT. NJJ->NJJ_TIPO $ 'A|B'
			if lRetorno 
				If SuperGetMV( "MV_OG250FE", .f., .f. ) 
					If __lnewNeg
						BEGIN TRANSACTION
							If NJJ->NJJ_TIPO == '4' // saída por venda
								If .NOT. lAlgodao
									lRetorno := AX500PSVen(cNumOP) //Função no fonte AGRX500P.PRW
								EndIf
							EndIf
	
							If .NOT. lRetorno
								DisarmTransaction()
								lRetorno := .F.
								break
							EndIf
	
						END TRANSACTION	
					EndIf
					
					If lRetorno .OR. ISINCALLSTACK('OGA455TRF')
						//PE para manipular os dados do romaneio já atualizado.
						//A execução deste PE não influencia no andamento da rotina.
						If EXISTBLOCK ("OG250ATLZ")
							ExecBlock("OG250ATLZ",.F.,.F.,{NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM })
						EndIf
		
						lRetorno := OGA250NF( Alias(), Recno(), 4, .t. )
					EndIf
				else
					//PE para manipular os dados do romaneio já atualizado.
					//A execução deste PE não influencia no andamento da rotina.
					If EXISTBLOCK ("OG250ATLZ")
						ExecBlock("OG250ATLZ",.F.,.F.,{NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM })
					EndIf
				EndIf
			endIf
		EndIf	
	EndIf
	
	If FwIsInCallStack("GFEA523")
		//---Mensagens com a função de HELP não funciona pelo GFE
		If lRetorno
			MSGINFO(STR0038)	//"Romaneio atualizado com sucesso."
		Else 
			MSGINFO(STR0039)	//"Romaneio não atualizado."
		EndIf
	EndIf	

	RestArea( aAreaAtu )
Return lRetorno

/** {Protheus.doc} copyNJM
Criar registro de comercialização para a Remessa por Ordem Terceiros (DAGROGAP-4141)
@param: 	aNJM - array de dados da NJM para cópia
@param: 	cSeq - sequencial para criação do campo ITEROM
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	17/04/2018
@Uso: 		OGA250 - Romaneio
*/
Function copyNJM(aNJM,cSeq)

	Local nX := 0
	Local nY := 0
	Local aDados := {}
	Local lRet := .T.
	Local aAreaNJR	:= NJR->(GetArea())
	
	For nX := 1 To Len(aNJM)

		aDados := aNJM[nX]

		If RecLock("NJM", .T.) // Se for inclusão, então grava os dados
			cSeq := Soma1(cSeq)
			NJM->NJM_ITEROM  := cSeq  
			For nY := 1 To Len(aDados)
				If !(AllTrim(aDados[nY][1]) $ "NJM_ITEROM") 
					NJM->&(aDados[nY][1]) := aDados[nY][2]
				EndIF								
			Next nX
			
			NJM->NJM_SUBTIP := '46' //Remessa por Venda a Ordem
			NJM->NJM_PERDIV := 0

			If __lnewNeg
				DbSelectArea("N9A")
				N9A->(DbSetOrder(1))
				If N9A->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODCTR+NJM->NJM_ITEM+NJM->NJM_SEQPRI))  
					NJM->NJM_TES    := N9A->N9A_TESAUX
					NJM->NJM_OPEFIS := ''
					NJM->NJM_CODENT := N9A->N9A_ENTENT
					NJM->NJM_LOJENT := N9A->N9A_LJEENT
				EndIf
				N9A->(dbCloseArea())

				//Se usa IE usa Entidade Entrega da IE
				DbSelectArea("N7Q")				
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If N7Q->(DbSeek(NJM->NJM_FILORG+NJM->NJM_CODINE))
					NJM->NJM_CODENT := N7Q->N7Q_ENTENT
					NJM->NJM_LOJENT := N7Q->N7Q_LOJENT
				EndIf
				N7Q->(dbCloseArea())
			Else
				DbSelectArea("NJR")	
				NJR->(DbSetOrder(1)) 	
				If 	NJR->( dbSeek( FWxFilial( "NJR" ) + NJM->NJM_CODCTR ) )
					NJM->NJM_TES    := NJR->NJR_TESEST
					NJM->NJM_OPEFIS := ''
					NJM->NJM_CODENT := NJR->NJR_CODTER
					NJM->NJM_LOJENT := NJR->NJR_LOJTER
				EndIf
			EndIf

			NJM->(MsUnlock())
		EndIf

		If Empty(NJM->NJM_CODENT) .or. Empty(NJM->NJM_LOJENT)
			AgrHelp(STR0001,STR0105,STR0106) //##"Entidade de entrega inválida ou não informada no contrato. Para contrato com operação triangular é obrigatório informar o campo codigo e loja de terceiro no contrato."//##"Verifique no contrato se foi informado o campo codigo e loja de terceiro."
			lRet := .F.
			Exit
		EndIf

	Next nX
	RestArea(aAreaNJR)

Return lRet

/** {Protheus.doc} AtualizaNJP
Atualiza qunatidades da autorização e status 
@return:	Nil
@author: 	Felipe Mendes
@since: 	17/02/2022
@Uso: 		OGA250 - Romaneio
*/
Static Function AtualizaNJP( cDbSeek , nNJM_QTDFCO, nNJM_QTDFIS )

	dbSelectArea( "NJP" ) // Autorizacao
	dbSetOrder( 1 )
	If dbSeek( cDbSeek )

		If RecLock( "NJP", .f. )

			NJP->( NJP_QTDFCO ) += nNJM_QTDFCO
			NJP->( NJP_QTDFIS ) += nNJM_QTDFIS
			//Verifica se os valores da quantidade fisica já excederam a quantidade autorizada + quantidade excedida
			If NJP->( NJP_QTDFCO ) >=  NJP->( NJP_QTDAUT ) 
				NJP->( NJP_STATUS ) := 'E'	
			Else 
				NJP->( NJP_STATUS ) := 'I'	
			EndIf
			NJP->( msUnLock() )
		EndIf
	EndIf
	
Return 

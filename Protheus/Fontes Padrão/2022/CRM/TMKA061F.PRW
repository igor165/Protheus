#INCLUDE "TMKA061F.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA061C  บAutor  ณVendas Clientes     บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFonte com as funcoes de processo da Lista de Contato.       บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTK061Del     บAutor ณVendas Clientes      บ Data ณ 21/07/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Exclusao de Lista           					   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                    	              	   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Del()

Local lRet			:= .F.
Local cU4_Operad 	:= ""  

#IFDEF TOP
	Local cQuery 		:= ""
#ENDIF

BEGIN TRANSACTION

	If TmkOk(STR0001)	 //"Confirma a exclusใo da Lista de Contatos? "
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga os itens da lista de contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		#IFDEF TOP
			cQuery += "DELETE FROM "
			cQuery += RetSqlName("SU6")+" "
			cQuery += "WHERE U6_FILIAL='"+xFilial("SU6")+"' AND "
			cQuery += "U6_LISTA='"+SU4->U4_LISTA+"' "
			
			TcSqlExec(cQuery)			
		
		#ELSE
			DbSelectArea("SU6")
			DbSetOrder(1)
		
			If DbSeek(xFilial("SU6") + SU4->U4_LISTA)
				While (!Eof()) .AND. (SU6->U6_FILIAL == xFilial("SU6")) .AND. (SU6->U6_LISTA == SU4->U4_LISTA)
					Reclock( "SU6" ,.F.,.T.)
					DbDelete()
					MsUnlock()
					DbSkip()
				End
			Endif
		#ENDIF
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga o memo da mensagem do EMAILณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		MSMM(SU4->U4_CODMENS,80,,,2)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se a lista ja foi finalizada para posterior retirada de tarefa do Operadorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If  SU4->U4_STATUS == "1" // Ativa
			cU4_Operad := SU4->U4_OPERAD
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga o codigo da lista de AB9 e AB7 quando for lista de O.S. do sigatec           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("AB9")		
		DbSetOrder(8) // FILIAL+AB9_TMKLST
		If MsSeek(XFilial("AB9")+SU4->U4_LISTA)
			While !Eof() 
				If AB9_FILIAL == XFilial("AB9") .AND. AB9_TMKLST == SU4->U4_LISTA
					RecLock( "AB9", .F. )
					Replace AB9->AB9_TMKLST With Space(Len(SU4->U4_LISTA))
					AB9->(MsUnLock())
				EndIf					
				AB9->(DbSkip())
			End		
		EndIf
			
		DbSelectArea("AB7")
		DbSetOrder(8) // FILIAL+AB7_TMKLST
		If MsSeek(XFilial("AB7")+SU4->U4_LISTA)
			While !Eof() 				
				If AB7_FILIAL == XFilial("AB7") .AND. AB7_TMKLST == SU4->U4_LISTA
					RecLock( "AB7", .F. )
					Replace AB7->AB7_TMKLST With Space(Len(SU4->U4_LISTA))
					AB7->(MsUnLock())
				EndIf	
				AB7->(DbSkip())
			End						
		EndIf								

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga o cabecalho da lista de contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SU4")
		Reclock( "SU4" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		
		If !EMPTY(cU4_Operad)
			Tk061GrvTarefa(cU4_Operad,2)
		Endif
		
		lRet:= .T.
	Endif
	
END TRANSACTION

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk061Grava ณ Autor ณ Vendas Clientes       ณ Data ณ 28/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณGravacao da lista de contatos SU4 e SU6  com integridade.    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณLista de Contatos                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk061Grava(nOpc			,aLista	,cAssunto	,cMensagem	,;
						cAttach	,aAttach	,cFiltro	,cSelOper	,;
						lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
						cOSFim		,lEntMonOS)

Local nCampo	:= 0				 				// Variavel para gravacao dos campos
Local lRec		:= .T.			   					// Retorno da funcao
Local nI 		:= 0 				  				// Contador
Local aArea		:= GetArea()		   				// Salva a area atual
Local lTK61ValC	:= ExistBlock("TK61VALC") 			// P.E  Antes da grava็ใo da lista.
Local lRet 		:= .T.   							// Variavel de retorno para o P.E.
Local lTK061Grv	:= ExistBlock("TK061GRV")			// Controle de ponto de entrada   
Local aSLARegister := {}							// Retorno da rotina de SLA

Default lOS		:= .F.
Default lEntMonOS	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a gravacao da geracao de contatos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BEGIN TRANSACTION

	If !lGrvCab
		If nOpc == ALTERAR
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณApaga o memo da mensagem .ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				MSMM(SU4->U4_CODMENS,80,,,2)  	//nao ha alteracao de dados de lista ja gerada.
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEfetua verificacao do tipo de operacao para a execucao do RecLockณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If 	nOpc <> INCLUIR .AND. nOpc <> INCLUIAUTO .AND. nOpc <> ASSISTENTE
			lRec := .F.
		Else
			lRec := .T.
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava o cabecalho da Lista de Contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("SU4",lRec)
		For nCampo:= 1 To FCount()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso nao seja uma ALTERACAO grava normalmente o cabecalho.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nOpc != ALTERAR 
			
				Do Case
					Case (FieldName(nCampo) == "U4_FILIAL" )
						FieldPut(nCampo, xFilial("SU4"))
					
					Case (FieldName(nCampo) == "U4_ASSUNTO" )
						FieldPut(nCampo, cAssunto)
						
					Case (FieldName(nCampo) == "U4_ATTACH" )
						FieldPut(nCampo, cAttach)
						
					Case (FieldName(nCampo) == "U4_FILTRO" )
						FieldPut(nCampo, cFiltro)
						
					Case (FieldName(nCampo) == "U4_STATUS" )
						FieldPut(nCampo, "1")
						
					Case (FieldName(nCampo) == "U4_OPERAD" )
						FieldPut(nCampo, cSelOper)  
					OtherWise               	
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				EndCase
			            
				If nModulo == 73 //SIGACRM
			       SU4->U4_ORIGEM := M->U4_ORIGEM
			       SU4->U4_CUSTO  := M->U4_CUSTO
				EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso seja Alteracao grava somente os campos que podem ser alterados. ณ
			//ณNeste caso a funcao de Montagem da Lista foi pulada, pois nao poderaoณ
			//ณser gravados campos que influenciem em seus dados ja selecionados.   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Else
				Do case
					Case (FieldName(nCampo) == "U4_ASSUNTO" )
						FieldPut(nCampo, cAssunto)
						
					Case (FieldName(nCampo) == "U4_ATTACH" )
						FieldPut(nCampo, cAttach)
	
					Case (FieldName(nCampo) == "U4_OPERAD" )
						FieldPut(nCampo, cSelOper)
	
					Case (FieldName(nCampo) == "U4_MALADIR" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_ETIQUET" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				
					Case (FieldName(nCampo) == "U4_CODCAMP" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_DESCCAM" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
						
					Case (FieldName(nCampo) == "U4_SCRIPT" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_EVENTO" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
						
					Case (FieldName(nCampo) == "U4_DESC" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_CONFIG" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_TELE" )	
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				EndCase     
		
			Endif	
		Next nCampo         
		 If nModulo == 73 //SIGACRM
		     SU4->U4_DTUPD := DDataBase 
		     SU4->U4_ORIGEM := M->U4_ORIGEM
		     SU4->U4_CUSTO  := M->U4_CUSTO
		 EndIf
	     
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ           
		//ณGrava a mensagem do e-mail.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู             
		
		If !Empty(cMensagem)
			MSMM(,80,,cMensagem,1,,,"SU4","U4_CODMENS") //Mensagem do Email
		Endif
	    
	    
		cMensagem:= Space(400)
		cAssunto := CriaVar("U4_ASSUNTO",.F.)
		aAttach  := {}
		cAttach  := ""
        cFiltro	 := ""
        
		lGrvCab := .T.
		FKCOMMIT()
	Endif
	
	If lOS
		DbSelectArea( "AB7" )
		DbSetOrder(6)
		If AB7->(DBSeek( xFilial( "AB7" ) + aLista[1][8], .T. )) //Codigo do Contato
			While	xFilial( "AB7" ) + aLista[1][8] == AB7->AB7_FILIAL + AB7->AB7_CODCON	.And.	;
					AB7->(!EOF())
				
				If !lEntMonOS // Pesquisa de Satisfa็ใo				
					DbSelectArea( "AB9" )
					DbSetOrder( 1 )
					If AB9->(DbSeek( xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM ))					
						While	xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM == AB9->AB9_FILIAL + AB9_NUMOS	.And.	;
								AB9->(!EOF())
							If AB9->AB9_TIPO == '1' .And. Empty(AB9->AB9_TMKLST)
								If !Empty(cOSIni) .Or. !Empty(cOSFim)
									If !(AB9->AB9_NUMOS >= cOSIni .And. AB9->AB9_NUMOS <= cOSFim)
										RecLock( "AB9", .F. )
										Replace AB9->AB9_TMKLST With U4_LISTA
										AB9->(MsUnLock())
									EndIf
								EndIf 
							EndIf
							AB9->(DbSkip())
						End
					EndIf
				Else //Entrega e Montagem
					DbSelectArea( "AB6" )
					DbSetOrder( 1 )
					If AB6->(DbSeek( xFilial("AB6") + AB7->AB7_NUMOS ))					
						If !Empty(AB6->AB6_NUMLOJ) 
							If !Empty(cOSIni) .Or. !Empty(cOSFim)
								If !(AB7->AB7_NUMOS >= cOSIni .And. AB7->AB7_NUMOS <= cOSFim) 
										RecLock( "AB7", .F. )
										Replace AB7->AB7_TMKLST With U4_LISTA
										AB7->(MsUnLock())	
								EndIf														
							EndIf 
						EndIf
					End				
				EndIf				        
				AB7->(DbSkip())					
			End	
		EndIf                                                                       
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava as chamadas a serem executadas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpc <> ALTERAR  // Na alteracao nao sao gravados os itens.
	
		If lTK61ValC
			lRet := U_TK61ValC(aLista)
		
			// Se o retorno for .F. nao prossegue com a grava็ใo
		   
			If (ValType(lRet) <> "L")
				lRet := .T.
	   		Endif
		Endif
	    				    
		  	If M->U4_BLQCONT == "2" 
				If lRet := TK700VldAut(M->U4_BLQCONT,M->U4_FORMA,M->U4_TIPOTEL,M->U4_TELE,aLista[1,8])
					
					If lRet
						DbSelectArea("SU6")
						
						RecLock("SU6",.T.)
						Replace U6_FILIAL  With aLista[1][1]  //Filial
						Replace U6_LISTA   With aLista[1][2]  //Codigo da Lista
						Replace U6_CODIGO  With aLista[1][3]  //Codigo de Interacao
						Replace U6_FILENT  With aLista[1][4]  //Filial da Entidade
						Replace U6_ENTIDA  With aLista[1][5]  //Entidade
						Replace U6_CODENT  With aLista[1][6]  //Codigo da Entidade
						Replace U6_ORIGEM  With aLista[1][7]  //Origem da Interacao
						Replace U6_CONTATO With aLista[1][8]  //Contato
						Replace U6_DATA    With aLista[1][9]  //Data
						Replace U6_HRINI   With aLista[1][10] //Hora Inicio
						Replace U6_HRFIM   With aLista[1][11] //Hora Fim
						Replace U6_STATUS  With aLista[1][12] //Status da Interacao
						
						If Len(aLista[1]) > 12 .AND. !Empty(aLista[1][13])
							Replace U6_NUMOS  With aLista[1][13] //Numero O.S. Field
						EndIf
					
						Replace U6_DTBASE	With dDataBase
											
						MsUnlock()
						FkCommit()
					Endif
					
                EndIf
		        
			Else
		        
		        	If lRet
						DbSelectArea("SU6")
						
						RecLock("SU6",.T.)
						Replace U6_FILIAL  With aLista[1][1]  //Filial
						Replace U6_LISTA   With aLista[1][2]  //Codigo da Lista
						Replace U6_CODIGO  With aLista[1][3]  //Codigo de Interacao
						Replace U6_FILENT  With aLista[1][4]  //Filial da Entidade
						Replace U6_ENTIDA  With aLista[1][5]  //Entidade
						Replace U6_CODENT  With aLista[1][6]  //Codigo da Entidade
						If nModulo <> 73 //SIGACRM
							Replace U6_ORIGEM  With aLista[1][7]  //Origem da Interacao
						EndIf
						Replace U6_CONTATO With aLista[1][8]  //Contato
						Replace U6_DATA    With aLista[1][9]  //Data
						Replace U6_HRINI   With aLista[1][10] //Hora Inicio
						Replace U6_HRFIM   With aLista[1][11] //Hora Fim
						Replace U6_STATUS  With aLista[1][12] //Status da Interacao
						
						If Len(aLista[1]) > 12 .AND. !Empty(aLista[1][13]) .And.nModulo <> 73 //SIGACRM
							Replace U6_NUMOS  With aLista[1][13] //Numero O.S. Field
						EndIf
						
						Replace U6_DTBASE	With dDataBase
						
						MsUnlock()
						FkCommit()
					Endif
		
				EndIf 	
				
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEm caso de alteracao serao apagados os itens que estiverem deletados do aCols.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else
		DbSelectArea("SU6")
		DbSetOrder(1) // FILIAL + LISTA + CODIGO
		
		For nI:= 1 To Len(aCols)
			If aCols[nI][Len(aHeader)+1]
				If DbSeek(xFilial("SU6") + M->U4_LISTA+ aCols[nI][Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CODIGO"  })])
					If !Empty(SU6->U6_REGSLA)   
						Tk061FimSLA(SU6->U6_REGSLA)
					EndIf                          
					Reclock("SU6",.F.,.T.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next nI
	Endif    

END TRANSACTION

If nOpc <> ALTERAR .AND. lRet
	If !Empty(M->U4_SERVSLA)
		aSLARegister := Tk061SLA(M->U4_SERVSLA)
		If Len(aSLARegister)>0
			Reclock("SU6",.F.,.T.)
			Replace U6_REGSLA	With aSLARegister[1]
			MsUnlock()
		EndIf
	EndIf
EndIf

If lTK061Grv
	ExecBlock("TK061GRV",.F.,.F.,{} )
EndIf

RestArea(aArea)

Return lRet
                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061GrvTarefaบAutor  ณVendas Clientes     บ Data ณ  07/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a tarefa no SU7 para o operador.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo do operador                                       บฑฑ
ฑฑบ          ณExpN1: Opcao selecionada 1- Soma 2- Subtrai                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061GrvTarefa(cSelOper,nOpX)
Local lRet   := .F.
Local aSArea := GetArea()
Local nVal   := 0

DbSelectArea("SU7")
DbSetOrder(1)
IF DbSeek(xFilial("SU7")+ cSelOper)
    nVal := SU7->U7_TAREFA
    
    If nOpX == 1
 	   nVal++
	ElseIf nOpX == 2
	   If nVal > 0
	      nVal--
	   Endif   
	Endif
	
	If RecLock("SU7",.F.)
		Replace SU7->U7_TAREFA With nVal
		MsUnlock()
		DbCommit()
		lRet := .T.
	Endif	
Endif
RestArea(aSArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061GrvTrans บAutor  ณVendas Clientes     บ Data ณ  07/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a transferencia de Listas                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as listas.                                     บฑฑ
ฑฑบ          ณExpD1: Data para transferencia                                  บฑฑ
ฑฑบ          ณExpC1: Codigo do Operador                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK061GrvTrans(aListas,dData,cOperad)
Local lRet 	:= .F.	// Retorno da funcao
Local nI	:= 0 	// Controle do for
DbSelectArea("SU4")
DbSetOrder(1)

BEGIN TRANSACTION 
	For nI := 1 To Len(aListas)
		If aListas[nI][1]
			If SU4->(DbSeek(xFilial("SU4")+aListas[nI][2]))
				SU4->(Reclock( "SU4" ,.F.))
				REPLACE SU4->U4_DATA   WITH dData
				REPLACE SU4->U4_OPERAD WITH cOperad
				SU4->(MsUnlock())
				lRet := .T.
				If SU4->U4_TIPO == "1"	//"Marketing"
					//Atualiza o atendimento com o novo operador
					dbSelectArea("SUC")
					SUC->(dbSetOrder(1))
					If SUC->(dbSeek(xFilial("SUC")+SU4->U4_CODLIG ))
						SUC->(RecLock("SUC",.F.))
							SUC->UC_OPERADO := cOperad
						SUC->(MsUnlock())				
					EndIf
				ElseIf SU4->U4_TIPO == "3"	//"Vendas"
					//Atualiza o atendimento com o novo operador
					dbSelectArea("SUA")
					SUA->(dbSetOrder(1))
					If SUA->(dbSeek(xFilial("SUA")+SU4->U4_CODLIG ))
						SUA->(RecLock("SUA",.F.))
							SUA->UA_OPERADO := cOperad
						SUA->(MsUnlock())				
					EndIf				
				EndIf	
			Endif
		Endif	
	Next nI
END TRANSACTION

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK061COPIAบAutor  ณVendas Clientes     บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que executa a copia de listas de contato.            บฑฑ
ฑฑบ          ณGravacao com Integridade.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Copia(oSay,oMeter,cAlias,nReg,nOpc,cNome,dData,cOperad,lAutomato)

Local cLista     := ""					// Codigo da Lista
Local cNovaLista := ""					// Codigo da nova Lista
Local nCampo     := 0					// Campo para FieldPut
Local nRecord    := 0					// Contole
Local aCampos    := Array(1,FCount())	// Array com campos para copia
Local lRet		 := .F.
Local nTotCpy	 := 0
Local cChave     := ""
Local aAutoAO4   := {}

Default lAutomato := .F.

DbSelectArea(cAlias)
DbSetOrder(1)

If !lAutomato
	oSay:Show()
	oMeter:Show()
	oMeter:Refresh()   
EndIf

DbGoto(nReg)

If Eof()
	HELP("",1,"ARQVAZIO")
	lRet := .F.
Else
	
	cLista := SU4->U4_LISTA
	
	If !lAutomato
		nTotCpy:= Tk061TotCpy(cLista)
		oMeter:SetTotal(nTotCpy)
		nTotCpy := 0
	EndIf
	
	BEGIN TRANSACTION
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCopia o SU4.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู
		For nCampo := 1 To FCount()
			aCampos[1,nCampo]:= FieldGet(nCampo)
		Next nCampo
		
		RecLock("SU4",.T.)
		For nCampo:=1 To FCount()
			
			Do Case
				
				Case (Field(nCampo) == "U4_LISTA")
					cNovaLista:= GetSxeNum("SU4","U4_LISTA")
					FieldPut(nCampo,cNovaLista)
					ConfirmSx8()
					
				Case (Field(nCampo) == "U4_DESC")
					FieldPut(nCampo,cNome)
					
				Case (Field(nCampo) == "U4_DATA")
					FieldPut(nCampo,dData)
					                      
				Case (Field(nCampo) == "U4_OPERAD")
					FieldPut(nCampo,cOperad)	

				Case (Field(nCampo) == "U4_STATUS")
					FieldPut(nCampo,"1")	// 1=Ativa;2=Encerrada;3=Em Andamento

				OtherWise
					FieldPut(nCampo,aCampos[1,nCampo])
					
			EndCase
			
		Next nCampo
		
		MsUnLock()
		DbCommit()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCopia o SU6 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6") + cLista)
			aCampos := {}
			
			While !Eof() .AND. (xFilial("SU6") == SU6->U6_FILIAL) .AND. (cLista == SU6->U6_LISTA)
				Aadd(aCampos,Array(FCount()))
				
				For nCampo := 1 To FCount()
					aCampos[Len(aCampos),nCampo]:= FieldGet(nCampo)
				Next nCampo	
				
				DbSkip()
			End
			
			For nRecord:=1 To Len(aCampos)
				RecLock("SU6",.T.)
				For nCampo:= 1 To FCount()
					If (Field(nCampo) == "U6_LISTA")
						FieldPut(nCampo,cNovaLista)
					ElseIf (Field(nCampo) == "U6_STATUS")
						FieldPut(nCampo,"1")	// 1=Nao Enviado;2=Em Uso;3=Enviado
					ElseIf (Field(nCampo) == "U6_DATA")
						FieldPut(nCampo,dData)
					ElseIf (Field(nCampo) == "U6_DTBASE")
						FieldPut(nCampo,dDataBase)
					Else
						FieldPut(nCampo,aCampos[nRecord,nCampo])
					Endif
				Next nCampo
				
				MsUnLock()
				DbCommit()
				
				If !lAutomato
					//Atualiza barra de progressao
					oMeter:Set(nTotCpy+1)
					oMeter:Refresh()
				EndIf
				
			Next nRecord
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAdiciona ou Remove o privilegios deste registro.  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nModulo == 73 //SIGACRM
				cChave   := PadR(xFilial("SU4")+cNovaLista+dTos(dData),TAMSX3("AO4_CHVREG")[1])		
				aAutoAO4 := CRMA200PAut(nOpc,"SU4",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
				lRet 	  := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],3)
			EndIf 
			
		Endif
		
	END TRANSACTION
	
	lRet := .T.
Endif

Return (lRet)
                                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061SLA      บAutor  ณVendas CRM          บ Data ณ  09/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicia um novo SLA                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray                                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo do Servico de SLA                                 บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061SLA(codService)
Local oSLAService	:= SLAService():New()	//Objeto SLAService
Local cCodRespons	:= RetCodUsr()			//Primeiro usuario responsavel pelo SLA 
Local aSLARegister	:= {}					//Array de retorno com dados do SLA

	If oSLAService:load( codService )
		If oSLAService:find()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Cria um novo registro para o SLA encontrado ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If oSLAService:start(cCodRespons)
				//Salva o registro de SLA (SK5)
				oSLAService:save()
				ConOut("1 - Criou novo reg. SLA: " + oSLAService:getRegisterID())
			Else
				ConOut("1 - Nao foi possivel iniciar o registro de SLA")
			EndIf
		EndIf
	Else
		ConOut("1 - Nao foi possivel carregar o Servico de SLA: " + codService )		
	EndIf

	If !Empty(oSLAService:getRegisterID())
		aAdd(aSLARegister, oSLAService:getRegisterID())
		aAdd(aSLARegister, oSLAService:getDateToExpire())
		aAdd(aSLARegister, oSLAService:getSeverity())
	EndIf	

Return aSLARegister

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061SLA      บAutor  ณVendas CRM          บ Data ณ  09/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Finaliza o SLA                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo do Registro de SLA                                บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061FimSLA(codRegSLA)
Local lRet := .F.
Local oSLAService	:= SLAService():New()	//Objeto SLAService

If oSLAService:finish( codRegSLA )
	oSLAService:save()
	ConOut("1 - Finalizou o SLA : " +  codRegSLA)	
EndIf

Return lRet    




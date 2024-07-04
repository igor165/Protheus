#INCLUDE "TMKA062A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "MSOle.Ch"

#DEFINE VISUAL  	2
#DEFINE INCLUIR 	3
#DEFINE ALTERAR 	4
#DEFINE EXCLUIR 	5
#DEFINE PENDENTE   2

Static lSQL			:= !(Upper(TcSrvType())$"AS/400%ISERIES") .And. !(Upper(TCGetDB()) $ "DB2|INFORMIX")
Static _lTMK062Lis	:= ExistBlock("TK062LIS")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออหออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk062OutraLista บAutor  ณVendas Clientes บDataณ  04/22/02   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออสออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณVerifica se o contato ja esta em alguma outra lista		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062OutraLista(cContato,lTmkList,lSimultaneo,cFilSU4,cFilSU6)

Local aArea  		:= GetArea()
Local lCodeBase 	:= .T.
Local lRet   		:= .F.
Local cAliasAux		:= GetNextAlias()

Default cFilSU4		:= xFilial("SU4")
Default cFilSU6		:= xFilial("SU6")
Default lTmkList	:= GetNewPar("MV_TMKLIST" ,.F.)		    //Determina nใo utiliza็ใo de contatos ja presente em lista de cobran็a ativa/ em andamento
Default lSimultaneo	:= TkPosto(TkOperador(),"U0_VALCONT") == "2"

If lTmkList

	BeginSql alias cAliasAux
		SELECT SU4.U4_FILIAL, SU4.U4_TIPO, SU4.U4_STATUS, SU4.U4_LISTA, SU6.U6_FILIAL, SU6.U6_LISTA, SU6.U6_CONTATO, SU6.U6_DATA, SU6.U6_STATUS
		  FROM %Table:SU4% SU4, %Table:SU6% SU6
		 WHERE SU4.U4_FILIAL = %xfilial:SU4%
		   AND SU6.U6_FILIAL = %xfilial:SU6%
		   AND SU6.U6_CONTATO = %exp:cContato%
		   AND SU4.U4_TIPO = '2'
		   AND SU6.U6_LISTA = SU4.U4_LISTA
		   AND ( SU6.U6_DATA = %exp:DtoS(dDatabase)% OR ( SU6.U6_DATA <> %exp:DtoS(dDatabase)% AND SU4.U4_STATUS <> '2' ) )
		   AND SU4.%NotDel%
		   AND SU6.%NotDel%
	EndSql

	If (cAliasAux)->(! Eof())
		lRet:= .T.
	EndIf
	(cAliasAux)->(DbCloseArea())

Else

	If lSQL .And. !lA062Auto	// se for dbAccess
		If Type("cTblSU6")=="C" // Private declarado na TMKA062
			dbSelectArea(cTblSU6)
			If MsSeek(cContato)
				lRet := (cTblSU6)->TOTALREG > 0
			Else
				lRet := .F.
			EndIF
			lCodeBase := .F. // Jแ foi validado, nใo precisa passar pela validacao via codebase
		EndIf
	EndIf

	If lCodeBase .Or. lA062Auto
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se ja existe alguma lista para o contato no mesmo dia.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SU6")
		DbSetOrder(2)
		If MsSeeK(cFilSU6 + Dtos(M->U4_DATA) + cContato)
			While	SU6->(! Eof())				.AND.;
					SU6->U6_FILIAL == cFilSU6 	.AND.;
					SU6->U6_DATA == dDataBase	.AND.;
					SU6->U6_CONTATO == cContato
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณIndependente do Status, se o contato existir em outra Lista  ณ
				//ณpara o mesmo dia ele nao sera incluido nesta geracao.        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If (SU6->U6_STATUS == "1").OR.(SU6->U6_STATUS == "2").OR.(SU6->U6_STATUS == "3") //Nao-Enviado,Em Uso ou Enviado - Este la็o pode ser substituido por um lRet := .T.
					lRet:= .T.
					Exit
				Endif
				DbSkip()
			End
		Endif
	EndIf

	lData := .F.

	//Permite que o contato esteja em duas lista de formas de contato diferentes.
	//Se for selecionado 1 ( Exclusivo ) a avaliacao abaixo nao sera efetuada.
	If lRet .AND. lSimultaneo // U0_VALCONT == 2
		DbSelectArea("SU4")
		DbSetOrder(1)
		If MsSeeK(cFilSU4 + SU6->U6_LISTA)
			If SU4->U4_FORMA <> M->U4_FORMA
				lRet := .F.
			Endif
		Endif
	Endif

EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk062Grava ณ Autor ณ Vendas Clientes       ณ Data ณ 02/07/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณGrava a Lista e os itens no SU4 e SU6                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		    	            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk062Grava(	nOpc,    aLista,    cAssunto, cMensagem,;
						cAttach, aAttach,   cFiltro,  cSelOper,;
						lGrvCab, nChamadas, nSaveSX8, nTipo)
Local nCampo:= 0
Local aAux := {}
Local lPosU6Dt	:= SU6->(ColumnPos("U6_DTBASE")) > 0
Local cFilialSU4 := xFilial("SU4")
Local cFilialSK1 := xFilial("SK1")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a gravacao da geracao de co ntatos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BEGIN TRANSACTION

	If !lGrvCab
		Do Case
			Case nOpc == INCLUIR
				While (GetSx8Len() > nSaveSx8)
					ConfirmSx8()
				EndDo
				
			Case nOpc == ALTERAR
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณApaga o memo da mensagem .ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				MSMM(SU4->U4_CODMENS,80,,,2) //nao ha alteracao de dados de lista ja gerada.
		Endcase
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava o cabecalho da Lista de Contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("SU4",IIF(nOpc#3, .F., .T.))
		For nCampo := 1 To FCount()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso nใo seja uma altera็ใo grava normalmente o cabe็alho.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			IF nOpc <> 4
				
				Do Case
					Case (FieldName(nCampo) == "U4_FILIAL" )
						FieldPut(nCampo, cFilialSU4)
						
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
						
					Case (FieldName(nCampo) == "U4_LOJA" )
						FieldPut(nCampo, IIF(nChamadas>=0 .And. nTipo==2,StrZero(nChamadas,2),""))
						
					OtherWise
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				EndCase
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCaso seja Altera็ใo grava somente os campos que podem ser alterados. ณ
				//ณNeste caso a funcao de Montagem da Lista foi pulada, pois nao poderaoณ
				//ณser gravados campos que influenciem em seus dados jแ selecionados.   ณ
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
						
				EndCase
				
			Endif
		Next nCampo
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava a mensagem do e-mail.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cMensagem)
			MSMM(,80,,cMensagem,1,,,"SU4","U4_CODMENS") //Mensagem do Email
		Endif
		
		cMensagem	:= Space(400)
		cAssunto	:= CriaVar("U4_ASSUNTO",.F.)
		aAttach	:= {}
		cAttach	:= ""
		cFiltro	:= ""
		
		lGrvCab	:= .T.
		FkCommit()
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao para ordernar o array alista. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
	If _lTMK062Lis
		aAux := ExecBlock("TK062LIS", .F., .F.,{aClone(aLista), cAssunto, cMensagem,;
		                                        cAttach, aAttach, cFiltro, cSelOper,;
		                                        lGrvCab, nChamadas, nSaveSX8})
		If ValType(aAux) == "A"
			aLista := aAux
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava as chamadas a serem executadas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpc <> 4  // Na alteracao nao sao gravados os itens.
		DbSelectArea("SU6")
		For nCampo := 1 TO Len(aLista)
			
			RecLock("SU6",.T.)
			
			Replace U6_FILIAL  With aLista[nCampo][1]  //Filial
			Replace U6_LISTA   With aLista[nCampo][2]  //Codigo da Lista
			Replace U6_CODIGO  With aLista[nCampo][3]  //Codigo de Interacao
			Replace U6_FILENT  With aLista[nCampo][4]  //Filial da Entidade
			Replace U6_ENTIDA  With aLista[nCampo][5]  //Entidade
			Replace U6_CODENT  With aLista[nCampo][6]  //Codigo da Entidade
			Replace U6_ORIGEM  With aLista[nCampo][7]  //Origem da Interacao
			Replace U6_CONTATO With aLista[nCampo][8]  //Contato
			Replace U6_DATA    With aLista[nCampo][9]  //Data
			Replace U6_HRINI   With aLista[nCampo][10] //Hora Inicio
			Replace U6_HRFIM   With aLista[nCampo][11] //Hora Fim
			Replace U6_STATUS  With aLista[nCampo][12] //Status da Interacao
			
			If lPosU6Dt
				Replace U6_DTBASE	With dDataBase
			EndIf

			MsUnlock()
			
			DbSelectArea("SK1")
			DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
			MSSeeK(cFilialSK1 + AllTrim(SU6->U6_CODENT))
			While	!Eof()										.AND.;
				SK1->K1_FILIAL == cFilialSK1				.AND.;
				SK1->K1_CLIENTE == SubStr(SU6->U6_CODENT,1,6)	.AND.;
				SK1->K1_LOJA == SubStr(SU6->U6_CODENT,7,2)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se o tํtulo estแ em exce็ใo.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If SK1->K1_OPERAD == "XXXXXX"
					SK1->(DbSkip())
					Loop
				Endif
				
				RecLock("SK1", .F.)
				Replace SK1->K1_OPERAD With SU4->U4_OPERAD
				MsUnLock()
				
				DbSkip()
			EndDo
			
		Next nCampo
	Endif
	
END TRANSACTION

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk062SA12  ณ Autor ณ Vendas Clientes       ณ Data ณ 02/07/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณRealiza a selecao dos parametros para o SA1                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca).                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Function Tk062SA12(	ceMv_Par01,	ceMv_Par02,	ceMv_Par03,	ceMv_Par04,;
						ceMv_Par05,	ceMv_Par06,	ceMv_Par07,	ceMv_Par08,;
						ceMv_Par09,	ceMv_Par10,	ceMv_Par11,	ceMv_Par12,;
						dDataLista,	nChamadas,		lLog,			ceMv_Par13,;
						cTipo,			cCodEnt, 		cFilialSK1,	cFilialACG,;
						cFilOrig, nTipo )

Local aArea		:= GetArea()
Local lRet			:= .F.									// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local nTotCham	:= 0
Local lPosK1FilO	:= SK1->(FieldPos("K1_FILORIG")) > 0
Local lCodeBase  := .T.

Default cTipo		:= UPPER(GetNewPar("MV_TMKCOBR","")) 	// Contem os tipos de titulos que devem ser utilizados para cobranca
Default cFilialSK1 := xFilial("SK1")
Default cFilialACG := xFilial("ACG")
Default cFilOrig := xFilial("SE1")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametros enviados para a selecao                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Pergunte TMK062
//Mv_Par01 	//Do Prefixo
//Mv_Par02 	//Ate o Prefixo
//Mv_Par03 	//Do Titulo
//Mv_Par04 	//Ate o Titulo
//Mv_Par05 	//Do Banco
//Mv_Par06 	//Ate o Banco
//Mv_Par07 	//Do Vencimento
//Mv_Par08 	//Ate o Vencimento
//Mv_Par09 	//Da Natureza
//Mv_Par10 	//Ate a Natureza
//Mv_Par11 	//Da Emissao
//Mv_Par12 	//Ate a Emissao

If lSQL // se for dbAccess
	If !lLog
		lCodeBase := .F. // Jแ foi validado, nใo precisa passar pela validacao via codebase
		lRet := .T.		// Se for top, esta validado na query
	Else
		If Type("cTblSK1")=="C" // Private declarado na TMKA062
			dbSelectArea(cTblSK1)
			If MsSeek(Alltrim(cCodEnt))
				lRet := (cTblSK1)->TOTALREG > 0
			Else
				lRet := .F.
			EndIF
			lCodeBase := .F. // Jแ foi validado, nใo precisa passar pela validacao via codebase
		EndIf
	Endif
EndIf
	
// se for codebase
If lCodeBase
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSomente os titulos que estiverem no SK1 podem ser cobradosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	  
	DbSelectArea("SK1")
	DbSetOrder(4) //K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
	MSSeeK(cFilialSK1+ AllTrim(cCodEnt))
	While (!EOF() .AND.;
			cFilialSK1 == SK1->K1_FILIAL .AND.;
			AllTrim(cCodEnt) == AllTrim(SK1->K1_CLIENTE+SK1->K1_LOJA))
				
		If lPosK1FilO
			cFilorig := SK1->K1_FILORIG
		EndIf
	
		DbSelectArea("SE1")
		DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		MSSeeK(cFilorig + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO, .T.)
		
		While	(!Eof()) .AND.;
				(cFilorig == SE1->E1_FILIAL) .AND.;
				(SE1->E1_PREFIXO == SK1->K1_PREFIXO) .AND.;
				(SE1->E1_NUM == SK1->K1_NUM) .AND.;
				(SE1->E1_PARCELA == SK1->K1_PARCELA) .AND.;
				(SE1->E1_TIPO == SK1->K1_TIPO)
		
			If	SE1->E1_PREFIXO >= ceMv_Par01 .AND. SE1->E1_PREFIXO <= ceMv_Par02 .AND.;
				SE1->E1_NUM     >= ceMv_Par03 .AND. SE1->E1_NUM     <= ceMv_Par04 .AND.;
				SE1->E1_PORTADO >= ceMv_Par05 .AND. SE1->E1_PORTADO <= ceMv_Par06 .AND.;
				SE1->E1_VENCREA >= ceMv_Par07 .AND. SE1->E1_VENCREA <= ceMv_Par08 .AND.;
				SE1->E1_NATUREZ >= ceMv_Par09 .AND. SE1->E1_NATUREZ <= ceMv_Par10 .AND.;
				SE1->E1_EMISSAO >= ceMv_Par11 .AND. SE1->E1_EMISSAO <= ceMv_Par12 .AND.;
				SE1->E1_VENCREA <  dDataLista .AND. SE1->E1_SALDO   >  0          .AND.;
				IIf(!Empty(ceMv_Par13), SE1->E1_SITUACA == ceMv_Par13, .T.)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSepara o que e abatimento quando o parametro MV_TMKCOBR  que contem	ณ
				//ณos tipos de titulos a serem cobrados nao foi criado, caso contrario	ณ
				//ณconsidera apenas os tipos informados no parametro.                 	ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Empty(cTipo)
					If SE1->E1_TIPO $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM
						DbSelectArea("SE1")
						SE1->(DbSkip())
						Loop
					Endif
				Else
					If !(Alltrim(SE1->E1_TIPO) $ cTipo)
						DbSelectArea("SE1")
						SE1->(DbSkip())
						Loop
					Endif
				Endif
	
				//ฺฤฤTELECOBRANCAฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณNeste ponto da query esta sendo tratando se a lista de inadimplentes eh diferenciada, ondeณ
				//ณa quantidade de cobrancas feitas para cada titulo eh considerada, pois influencia no trataณ
				//ณmento dado pelo operador que estah gerando a lista de inadimplencia. A variavel nChamadas ณ
				//ณesta no botao Detalhes da Toolbar da Lista de Cobranca.                                   ณ
				//ณSe nChamadas = 0, os tํtulos que jแ possuem atendimento ficarใo fora da lista. Pode ser	 ณ
				//ณutilizado para filtrar os tํtulos que foram reagendados para uma data futura.			 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DbSelectArea("ACG")
				DbSetOrder(2)
				If MSSeeK(cFilialACG + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
					While	!Eof() .AND.;
						ACG->ACG_PREFIX == SE1->E1_PREFIXO .AND.;
						ACG->ACG_TITULO == SE1->E1_NUM .AND.;
						ACG->ACG_PARCEL == SE1->E1_PARCELA .AND.;
						ACG->ACG_TIPO == SE1->E1_TIPO
						nTotCham++
						DbSkip()
					EndDo
				Endif
				If (nTotCham == nChamadas .And. nTipo == 2) .Or. nTipo == 1
					lRet := .T.
				Endif
				nTotCham := 0
				Exit
			Endif
			DbSelectArea("SE1")
			DbSkip()
		EndDo
		DbSelectArea("SK1")
		DbSkip()
	EndDo
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK062Mala บAutor ณVendas Clientes      บ Data ณ  08/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao com o Microsoft Word para criacao dos arquivos  บฑฑ
ฑฑบ          ณ de Mala Direta                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑฬออออออออออุออออออออหออออออหออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Mala(cLista,cArquivo,cLabel,cEtiqueta)

Local cWord     := Nil 							// Versao do Office
Local lTmkMala  := ExistBlock("TMKMALA")
Local lRet      := .F.
Local cEnvServ  := GetEnvServer()
Local cIniFile  := GetADV97()
Local cRootPath := GetPvProfString(cEnvServ,"RootPath","",cIniFile)
Local aSArea    := GetArea()
Local cFilialSU6 := xFilial("SU6")

If Subs(cArquivo,1,1) == "\"
	If Rat("\",cRootPath) == Len(Alltrim(cRootPath))
		cRootPath := Substr(cRootPath,1,Len(Alltrim(cRootPath))-1)
	Endif
	cArquivo := cRootPath + cArquivo
Endif

If lTmkMala
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAbre o link com o wordณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWord := OLE_CreateLink()
	
	If ValType(cWord) == "C" .AND. (cWord >= "0")
		OLE_NewFile( cWord,cArquivo)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFuncao que faz o Word aparecer na Area de Transferencia do Windows,     ณ
		//ณsendo que para habilitar/desabilitar e so colocar .T. ou .F.            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		OLE_SetProperty(cWord, oleWdVisible  ,.F. )
		OLE_SetProperty(cWord, oleWdPrintBack,.F. )
		
		DbSelectArea("SU6")
		DbSetOrder(1)
		MSSeeK(cFilialSU6 + cLista)
		While !Eof() .AND. (SU6->U6_FILIAL == cFilialSU6) .AND. (SU6->U6_LISTA == cLista)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณExecuta o ponto de entrada TMKMALA que ira         ณ
			//ณatualizar as variaveis do documento de mala direta.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			U_TMKMALA(cWord,SU6->U6_ENTIDA,SU6->U6_CODENT,SU6->U6_CONTATO) //Entidade,Cod.Entidade,Contato
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ-Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a  ณ
			//ณfuncao OLE_SetDocumentVar().														  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			OLE_UpdateFields(cWord)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ-Funcao que imprime o Documento corrente podendo ser especificado o numero de copias,  ณ
			//ณpodedo tambem imprimir com um intervalo especificado nos parametros "nPagInicial" ate  ณ
			//ณ"nPagFinal" retirando o parametro "ALL".												  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			OLE_PrintFile(cWord,"ALL",,,)
			
			DbSkip()
		EndDo
	
		OLE_CloseFile(cWord)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFuncao que fecha o Link com o Word.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		OLE_CloseLink(cWord)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o status da lista de mala direta para encerrado.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk062Status(cLista,.T.)
		lRet := .T.

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณImpressao do arquivo de etiquetas.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
		If cLabel = "1"
			If TmkOk(STR0001) //"Deseja imprimir o arquivo de etiquetas agora?"
				DbSelectArea("SU6")
				DbSetOrder(1)
				MSSeeK(cFilialSU6 + cLista)
				Tk062Etiq(cEtiqueta,cLista)
			Else
				Help(" ",1,"TK061NOIMP")
			Endif
		Endif
	Else
		Help(" ",1,"TK061MALA") //("Problemas na comunicacao com o editor de mala direta")
	Endif
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe nao existir o rdmake padrao de mala avisa o usuario.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Help(" ",1,"NO_IX",,"TMKMALA",3,5)
Endif

RestArea(aSArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK062Etiq บAutor ณVendas Clientes      บ Data ณ  08/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Integracao com o Microsoft Word para criacao dos arquivos  บฑฑ
ฑฑบ          ณ de Etiqueta                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Tk062Etiq(cEtiqueta,cLista)

Local cWord           							// Versao do Office
Local lTmkEtiq  := ExistBlock("TMKETIQ")
Local cEnvServ  := GetEnvServer()
Local cIniFile  := GetADV97()
Local cRootPath := GetPvProfString(cEnvServ,"RootPath","",cIniFile)
Local aSArea    := GetArea()

If Subs(cEtiqueta,1,1) == "\"
	If Rat("\",cRootPath) == Len(Alltrim(cRootPath))
		cRootPath := Substr(cRootPath,1,Len(Alltrim(cRootPath))-1)
	Endif
	cEtiqueta := cRootPath + cEtiqueta
Endif

If lTmkEtiq
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAbre o link com o wordณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWord:= OLE_CreateLink()
	
	If ValType(cWord) == "C" .AND. (cWord >= "0")
		OLE_NewFile( cWord,cEtiqueta)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFuncao que faz o Word aparecer na Area de Transferencia do Windows,     ณ
		//ณsendo que para habilitar/desabilitar e so colocar .T. ou .F.            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		OLE_SetProperty(cWord, oleWdVisible  ,.F. )
		OLE_SetProperty(cWord, oleWdPrintBack,.F. )
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta o ponto de entrada TMKMALA que ira         ณ
		//ณatualizar as variaveis do documento de mala direta.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		U_TMKETIQ(cWord,SU6->U6_ENTIDA,SU6->U6_CODENT,SU6->U6_CONTATO,cLista) //Entidade,Cod.Entidade,Contato,Numero da Etiqueta

		Tk062Status(cLista,.F.)
		
		OLE_CloseFile(cWord)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFuncao que fecha o Link com o Word.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		OLE_CloseLink(cWord)
	Else
		Help(" ",1,"TK061MALA") //("Problemas na comunicacao com o editor de mala direta")
	Endif
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe nao existir o rdmake padrao de mala avisa o usuario.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Help(" ",1,"NO_IX",,"TMKETIQ",3,5)
Endif

RestArea(aSArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณTK062StatusบAutor ณVendas Clientes      บ Data ณ  08/08/01  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza o status da lista para enviado					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk062Status(cLista, lMala)

Local aArea:= GetArea()
Local cStatus := "2"
Local cFilialSU6 := xFilial("SU6")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o status da lista para Enviado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If MSSeeK(xFilial("SU4") + cLista)

	// C๓digos de Status
	// 1 - Nada impresso
	// 2 - Mala e Etiqueta impressos
	// 3 - Somente mala impressa
	// 4 - Somente Etiqueta impressa
	If SU4->U4_STATUS == "3" .OR. SU4->U4_STATUS == "4"
		cStatus := "2"
	Elseif lMala
		cStatus := "3"
	Elseif !lMala
		cStatus := "4"
	Endif
	
	RecLock("SU4",.F.)
	Replace SU4->U4_STATUS With cStatus
	MsUnLock()
	DbCommit()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o status de cada contato como Encerrado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU6")
DbSetOrder(1)
If MSSeeK(cFilialSU6 + cLista,.T.)
	While !Eof() .AND. (cFilialSU6 == SU6->U6_FILIAL) .AND. (cLista == SU6->U6_LISTA)
		RecLock("SU6",.F.)
		Replace SU6->U6_STATUS With "3"
		MsUnLock()
		DbCommit()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza o historico de marketing.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Tk400Hist(SU6->U6_LISTA,SU6->U6_CODIGO,"8")
		
		DbSkip()
	EndDo
Endif

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณTK062Imp   บAutor ณVendas Clientes      บ Data ณ  09/08/01  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime a mala direta a partir do menu   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Imp(cAlias,nReg,nOpc,Param4,cMens,lUseVarMem)

Local oDlg
Local lEtiq    := .F.
Local lMala    := .F.
Local oEtiq
Local oMala
Local cLblEtiq := STR0002  //"Etiquetas"
Local cLblMala := STR0003  //"Mala Direta"
Local cMyAlias := "SU4"

Default cMens := STR0004   //"Escolha abaixo o que deseja imprimir"
Default lUseVarMem := .F.

If lUseVarMem
	cMyAlias := "M"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o arquivo esta vazio.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lUseVarMem .AND. SU4->(Eof())
	Help(" ",1,"A000FI")

Elseif ((cMyAlias)->U4_FORMA <> "4")// Mala Direta
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se a lista de contatos ้ mala direta.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Help(" ",1,"TK061NOMA") //("Esta lista nao e mala direta !")

Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,300 TITLE STR0012 PIXEL //"Impressใo Mala Direta/Etiquetas"
	
		@ 03,10 SAY cMens OF oDlg PIXEL SIZE 145,25
		
		@ 25,0 TO 26,250 OF oDlg PIXEL
		
		@ 33,10 CHECKBOX oMala VAR lMala SIZE 130,8 PIXEL OF oDlg PROMPT cLblMala
		
		@ 45,10 CHECKBOX oEtiq VAR lEtiq SIZE 130,8 PIXEL OF oDlg PROMPT cLblEtiq
		
		// C๓digos de Status
		// 1 - Nada impresso
		// 2 - Mala e Etiqueta impressos
		// 3 - Somente mala impressa
		// 4 - Somente Etiqueta impressa
		If ((cMyAlias)->U4_STATUS == "2")
			lEtiq := .F.
			lMala := .F.
			oEtiq:Disable()
			oMala:Disable()
			cLblEtiq := STR0013 //"Etiquetas (impressas)"
			oEtiq:cTitle := cLblEtiq
			cLblMala := STR0014 //"Mala Direta (Impressa)"
			oMala:cTitle := cLblMala

		Elseif ((cMyAlias)->U4_STATUS == "3")

			If ((cMyAlias)->U4_LABEL == "1")
				lEtiq := .T.
			Else
				lEtiq := .F.
				oEtiq:Disable()
				cLblEtiq := STR0019			//"Etiquetas (Nใo Imprimir)"
				oEtiq:cTitle := cLblEtiq
			Endif
			lMala := .F.
			oMala:Disable()
			cLblMala := STR0020			//"Mala Direta (Jแ Impresso)"
			oMala:cTitle := cLblMala

		Elseif ((cMyAlias)->U4_STATUS == "4")
			lEtiq := .F.
			lMala := .T.
			oEtiq:Disable()
			cLblEtiq := STR0021			//"Etiquetas (Jแ impresso)"
			oEtiq:cTitle := cLblEtiq
		Endif
		
		DEFINE SBUTTON FROM 60,088 TYPE 1 ENABLE OF oDlg ACTION (TK062Imprime( lEtiq, lMala, cMyAlias ),oDlg:End()) //Fecha a tela
		DEFINE SBUTTON FROM 60,120 TYPE 2 ENABLE OF oDlg ACTION oDlg:End() //Fecha a tela
		
	ACTIVATE MSDIALOG oDlg CENTER
Endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK062Imprime บAutor  ณVendas Clientes  บ Data ณ  22/04/02   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMonta a lista para a impressao da mala direta.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TK062Imprime( lEtiq, lMala, cMyAlias )

Local aArea  := GetArea()

If (lEtiq .OR. lMala)
	DbSelectArea("SU6")
	DbSetOrder(1)
	If MSSeeK(xFilial("SU6") + SU4->U4_LISTA)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta a impressao de mala direta.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lMala
			Tk062Mala((cMyAlias)->U4_LISTA,(cMyAlias)->U4_MALADIR,(cMyAlias)->U4_LABEL,(cMyAlias)->U4_ETIQUET)  // imprimir a mala
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณImprime a etiqueta caso necessario.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lEtiq
			Tk062Etiq((cMyAlias)->U4_ETIQUET,(cMyAlias)->U4_LISTA)
		Endif
	Else
		Help(" ",1,"TK061CONT") //"Esta lista nao possui contatos para a impressao da mala direta"
	Endif
	
Endif
			
RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTK062Itens  บAutor ณVendas Clientes      บ Data ณ 09/08/01  บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Exibe os itens da lista de contatos						  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Tk062Itens(ExpC1, ExpC2, ExpC3, ExpC4,                     ณฑฑ
ฑฑณ          ณ            ExpC5, ExpL6, ExpL7, ExpN8)                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo da lista a ser exibida                      ณฑฑ
ฑฑณ          ณ ExpC2 = Codigo da Entidade                                 ณฑฑ
ฑฑณ          ณ ExpC3 = Mensagem a ser exibida                             ณฑฑ
ฑฑณ          ณ ExpC4 = Assunto                                            ณฑฑ
ฑฑณ          ณ ExpC6 = Attach                                             ณฑฑ
ฑฑณ          ณ ExpL7 = Se deve exibir vazio o acols                       ณฑฑ
ฑฑณ          ณ ExpN8 = Opcao referente a opcao                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Itens(cLista,cEntidade,cMensagem,cAssunto,cAttach,lFillEmpty,lEnd, nOpcX)

Local aArea		:= GetArea()
Local nRecAtu   := 0
Local nRecTot   := 0
Local cQryTot   := ""
Local cQuery    := ""
Local bCond //Condicao para o registro ser adicionado no Acols
Local cFilialSU6 := xFilial('SU6')

Default lFillEmpty := .F.

cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SU6")+" SU6  "
cQuery += "WHERE SU6.U6_FILIAL='"+cFilialSU6+"' AND "
cQuery += "SU6.U6_LISTA='"+cLista+"' AND "
cQuery += "SU6.D_E_L_E_T_ = ' ' "

// O filtro esta montado e o ORDER BY nao esta na query entao ้ hora de montar o contator da regua
// Monto o SELECT que conta e aproveito o filtro da outra query
cQryTot := "SELECT COUNT(*) U6TOTAL " + SubStr(cQuery,AT("FROM ",cQuery),Len(cQuery))

cQuery += "ORDER BY "+SqlOrder(SU6->(IndexKey()))

cQryTot := ChangeQuery(cQryTot)
DbSelectArea("SU6")
DbCloseArea()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTot), "SU6", .F., .T.)
nRecTot := SU6->U6TOTAL

DbSelectArea("SU6")
DbCloseArea()

cSeek	:= cFilialSU6 + cLista
cWhile	:= "SU6->U6_FILIAL + SU6->U6_LISTA"
bCond	:= {||IIf(SU6->U6_FILIAL == cFilialSU6 .AND. SU6->U6_LISTA = cLista,.T.,.F.)}

aHeader := {}
aCols	:= {}
FillGetDados(	nOpcX /*nOpcX*/, "SU6"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,;
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,;
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, lFillEmpty/*lEmpty*/,; 
				/*aHeaderAux*/, /*aColsAux*/, {||TK062SetProc(@nRecAtu, nRecTot)}/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, "SU6"/*cAliasQry*/)

FATPDLogUser('TK062ITENS')	// Log de Acesso LGPD

DbSelectArea("SU6")
DbCloseArea()	
RestArea(aArea)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    |TK062SetProcบAutor ณVendas Clientes      บ Data ณ 16/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณIncrementa a contador de atividades       				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณnExp1: Numero do processo atual.                            ณฑฑ
ฑฑณ          ณcExp2: Total de processos a serem executados                ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                     	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TK062SetProc(nRecAtu, nRecTot)  

nRecAtu++
IncProc( STR0022 + StrZero(nRecAtu,6) + STR0023 + StrZero(nRecTot,6) )		// "Lendo reg. ", " ate "
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTK062ExibeArquivo บAutor ณVendas Clientes      บ Data ณ 10/08/01  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Exibe o arquivo de mala direta/etiqueta selecionado				บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	                ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062ExibeArquivo(cArquivo)

Local cWord		:= ""
Local cEnvServ	:= GetEnvServer()
Local cIniFile	:= GetADV97()
Local cRootPath	:= GetPvProfString(cEnvServ,"RootPath","",cIniFile)

If Subs(cArquivo,1,1) == "\"
	If Rat("\",cRootPath) == Len(Alltrim(cRootPath))
		cRootPath := Substr(cRootPath,1,Len(Alltrim(cRootPath))-1)
	Endif
	cArquivo := cRootPath + cArquivo
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o link com o wordณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cWord	:= OLE_CreateLink()

If (cWord > "0")
	OLE_NewFile( cWord,cArquivo)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao que faz o Word aparecer na Area de Transferencia do Windows,     ณ
	//ณsendo que para habilitar/desabilitar e so colocar .T. ou .F.            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	OLE_SetProperty(cWord, oleWdVisible  ,.T. )
	OLE_SetProperty(cWord, oleWdPrintBack,.T. )
	
Else
	Help(" ",1,"TK061MALA") //("Problemas na comunicacao com o editor de mala direta")
Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTK062Excluir บAutor ณVendas Clientes      บ Data ณ 10/08/01  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Exclui a lista de contatos								   บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Excluir()

Local lRet				:= .F.
Local cU4_Operad	 	:= ""
Local aCodEntidade	:= {}				//Codigos das Entidades existentes no SU6
Local nY				:= 0        		//Controle
Local aArea			:= GetArea("SK1")  // Guarda a area do SK1
Local cFilialSU6		:= xFilial("SU6")
Local cFilialSK1		:= xFilial("SK1")
Local cQuery			:= ""
Local cAliasAux		:= ""      			//Arquivo de trabalho
Local cLista			:= ""

If TmkOk(STR0015)	 		   			//"Confirma a exclusใo da lista de contatos ?"

	BEGIN TRANSACTION

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta query para armazenar os codigos das entidades,ณ
		//ณque serao utilizadas para pesquisa  no SK1          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cAliasAux	:= GetNextAlias()
		cLista		:= SU4->U4_LISTA
		BeginSql alias cAliasAux
			SELECT SU6.U6_CODENT CODENT
			  FROM %Table:SU6% SU6
			 WHERE SU6.U6_FILIAL = %xfilial:SU6%
			   AND SU6.U6_LISTA = %exp:cLista%
			   AND SU6.%NotDel%
			 ORDER BY CODENT
		EndSql

		While (cAliasAux)->(! Eof())
			aAdd(aCodEntidade,{(cAliasAux)->CODENT})
			(cAliasAux)->(DbSkip())
		EndDo
		(cAliasAux)->(DbCloseArea())

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga os itens da lista de contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		DbSelectArea("SU6")
		cQuery += "DELETE FROM "
		cQuery += RetSqlName("SU6")+" "
		cQuery += "WHERE U6_FILIAL='"+cFilialSU6+"' AND "
		cQuery += "U6_LISTA='"+SU4->U4_LISTA+"' "
			
		TcSqlExec(cQuery)
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga o memo da mensagem do EMAILณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Val(SU4->U4_FORMA) == CROSSPOSTING
			MSMM(SU4->U4_CODMENS,80,,,2)
		Endif
        
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se a lista ja foi finalizada para posterior retirada de tarefa do Operadorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If  SU4->U4_STATUS == "1" // Ativa
			cU4_Operad := SU4->U4_OPERAD
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApaga o cabecalho da lista de contatos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SU4")
		Reclock( "SU4" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		If !EMPTY(cU4_Operad)
			Tk062GrvTarefa(cU4_Operad,2)
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLimpa o codigo do operador no arquivo de referencia - SK1    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nY := 1 to Len(aCodEntidade)
			DbSelectArea("SK1")
			DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
			If MSSeeK(cFilialSK1 + Alltrim(aCodEntidade[nY,1]))
				While	!Eof()										.AND.;
					SK1->K1_FILIAL == cFilialSK1				.AND.;
					SK1->K1_CLIENTE == SubStr(aCodEntidade[nY,1],1,6)	.AND.;
					SK1->K1_LOJA == SubStr(aCodEntidade[nY,1],7,2)
					RecLock("SK1", .F.)
					Replace SK1->K1_OPERAD With ""
					MsUnLock()
					DbSkip()
				EndDo
			Endif
		Next nY
					
		lRet:= .T.
	                                                       
	END TRANSACTION
Endif

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTK062DesformaบAutor ณVendas Clientes      บ Data ณ 10/08/01  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Exclui a lista de contatos								   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	           ณฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062DescForma(cForma)

Local cDesc:= ""

Do Case
	Case (cForma == "1") //Voz
		cDesc:= STR0005 //"Voz"
		
	Case (cForma == "2") //Fax
		cDesc:= STR0006 //"Fax"
		
	Case (cForma == "3") //Cross Posting
		cDesc:= STR0007 //"Cross Posting"
		
	Case (cForma == "4") //Mala Direta
		cDesc:= STR0003 //"Mala Direta"
		
	Case (cForma == "5") //Pendencia
		cDesc:= STR0016 //"Pend๊ncia"
		
	Case (cForma == "6") //WebSite
		cDesc:= STR0017  //"WebSite"
EndCase

Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuncao    ณTK062VldAuto  บVendas Clientes             บ Data ณ 10/08/01 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Verifica o acols informado pela rotina automatica    	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	           ณฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062VldAuto(	nOpc		,aLista		,cSelOper	,cAssunto,;
						cMensagem	,cAttach	,aAttach	,cFiltro,;
						nSaveSX8, nTipo) 

Local lRet 	   := .F.
Local nFor 	   := 0
Local cContato := ""
Local cFilEnt  := ""
Local cEntida  := ""
Local cCodEnt  := ""
Local lGrvCab  := .F.
Local cFilialSU5 := xFilial("SU5")

INCLUI := IIf (nOpc == 3, .T., .F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se o contato ja esta em alguma lista de pendencia.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nFor := 1 to Len(aAutoItens)
	
	cContato := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] == "U6_CONTATO"} )][2]	)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida Codigo do Contatoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Tk062OutraLista(cContato)
		Loop
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre o cadastro de contatos :                    ณ
	//ณ1) Se nao tiver o telefone selecionado gravado SKIP  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SU5")
	DbSetOrder(1)
	If MSSeeK(cFilialSU5+cContato)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida o tipo de telefone para contato.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Do Case
			Case (M->U4_FORMA == "1")   	//Voz
				
				If M->U4_TIPOTEL == "1" 	// Residencial
					cTel := SU5->U5_FONE
					
				ElseIf M->U4_TIPOTEL == "2" // Celular
					cTel := SU5->U5_CELULAR
					
				ElseIf M->U4_TIPOTEL == "3" // Fax
					cTel := SU5->U5_FAX
					
				ElseIf M->U4_TIPOTEL == "4" // Comercial 1
					cTel := SU5->U5_FCOM1
					
				ElseIf M->U4_TIPOTEL == "5" // Comercial 2
					cTel := SU5->U5_FCOM2
				Endif
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o tipo de telefone para a geracao da lista naoณ
				//ณexistir no contato, passa para o proximo contato.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Empty(cTel)
					Loop
				Endif
				
			Case (M->U4_FORMA == "2")   //Fax
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o contato nao possuir numero de fax passa para o proximo contato.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Empty(SU5->U5_FAX)
					Loop
				Endif
				
				
			Case (M->U4_FORMA == "3")  //Cross-Posting
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o contato nao possuir e-mail passa para o proximo contato.       ณ
				//ณOu se o contato nใo autorizar a intera็ใo via e-mail.               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				If Empty(SU5->U5_EMAIL) .OR. (SU5->U5_AUTORIZ <> "1")// SIM
					Loop
				Endif
				
			Case (M->U4_FORMA == "4")  //Mala-Direta
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o contato nao possuir endereco passa para o proximo contato.     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Empty(SU5->U5_END)
					Loop
				Endif
				
		Endcase
	Endif
	
	cFilEnt  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] = "U6_FILENT"} )][2])
	cEntida  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] = "U6_ENTIDA"} )][2])
	cCodEnt  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] = "U6_CODENT"} )][2])
	
	AAdd(aLista,{	xFilial("SU6"),;			    // Filial
					M->U4_LISTA,;       			// Lista
					GetSxeNum("SU6","U6_CODIGO"),;  // Codigo
					cFilEnt,;  						// Filial da Entidade
					cEntida,;  						// Chave da entidade
					cCodEnt,;						// Codigo da Entidade
					"1",;							// Origem da Interacao
					cContato,;  					// Codigo do Contato
					M->U4_DATA,;					// Data
					CriaVar("U6_HRINI",.T.),; 		// Hora Inicial
					CriaVar("U6_HRFIM",.T.),; 		// Hora Final
					"1"})					  		// Status da Interacao
					
Next nFor

lRet	:= Tk062Grava(nOpc, aLista, @cAssunto, @cMensagem,;
    	              @cAttach, @aAttach, @cFiltro, @cSelOper,;
    	              @lGrvCab, -1, nSaveSX8, nTipo)

CursorArrow()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuncao    ณTk062RetU4Cmp บVendas Clientes             บ Data ณ 05/04/02 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Retorna os campos da MsMGet que poderao ser alterados.      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062RetU4Cmp(nOpc,cAlias,nReg)

Local aArea 	:= GetArea()
Local aCampos 	:= {}
Local cCampos   := "U4_OPERAD;U4_MALADIR;U4_ETIQUET,U4_CODCAMP;U4_DESCCAM;U4_SCRIPT;U4_EVENTO"	 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEm caso de alteracao verifica  se a lista ja foi executada. Se o retorno forณ
//ณpositivo a campanha nao podera ser alterada.                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == ALTERAR
	If Tk062ValAlt(cAlias,nReg,nOpc)
		cCampos   := "U4_OPERAD;U4_MALADIR;U4_ETIQUET,U4_CODCAMP;U4_DESCCAM;U4_SCRIPT;U4_EVENTO"
	Else
		cCampos   := "U4_OPERAD;U4_MALADIR;U4_ETIQUET"
	Endif
Endif

DbSelectArea("SX3")
DbSetOrder(1)
If MSSeeK("SU4")
	While !Eof() .AND. SX3->X3_ARQUIVO == "SU4"
		If X3USO(SX3->X3_USADO)
	  		//Carrega todos os campos exceto o U4_CONFIG
			If nOpc <> 4
				If !(ALLTRIM(Upper(SX3->X3_CAMPO)) == "U4_CONFIG")
					Aadd( aCampos, SX3->X3_CAMPO )
				Endif
			Else
				If (ALLTRIM(Upper(SX3->X3_CAMPO)) $ cCampos)
					Aadd( aCampos, SX3->X3_CAMPO )
				Endif
			Endif
		Endif
		DbSkip()
	End
Endif

RestArea(aArea)
Return(aCampos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK062SELOPERบAutor  ณVendas Clientes     บ Data ณ  07/13/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a selecao automatica do operador que recebera a tarefa.บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062SelOper()

Local aArea 		:= GetArea()
Local aOper 		:= {}       // Array com operadores
Local aOper2		:= {}       // Operadores selecionados
Local aSortOper 	:= {}   // Ordena operadores por ordem crescente de tarefas.
Local nOper 		:= 1
Local nForOp		:= 0
Local oDlg			:= Nil
Local oOpers		:= Nil
Local oOk        	:= LoaDbitmap(GetResources(),"LBOK")	// LOGO Verde
Local oNo        	:= LoaDbitmap(GetResources(),"LBNO")
Local cFilialSU7 	:= xFilial("SU7")
Local aPDCols		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega os operadores para a selecao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU7")
DbSetOrder(1)
MSSeeK(cFilialSU7)

While (!Eof()) .AND. cFilialSU7 == SU7->U7_FILIAL
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPara a Lista de Cobranca sao selecionados Operadores validos com Rotina = TELECOBRANCA e TODOSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Val(SU7->U7_VALIDO) == VALIDO .AND. (SU7->U7_TIPOATE == "3" .OR. SU7->U7_TIPOATE == "4")
		Aadd(aOper,{.F.,SU7->U7_COD,SU7->U7_NOME,SU7->U7_TAREFA}) //LOGO,codigo,Nome,Qtd de Tarefas
	Endif
	DbSkip()
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for rotina automatica apresenta as telasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lA062Auto
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEsta tela permite a selecao dos operadores que participarao da avaliacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aOper)> 0
		
		DEFINE MSDIALOG oDlg TITLE STR0008 FROM 00,00 TO 250,500 PIXEL OF oMainWnd  //"Operadores - Avalia็ใo/Grava็ใo automแtica"
		
		@02,02 TO 120,210 LABEL "" PIXEL OF oDlg
		@05,04 LISTBOX oOpers FIELDS ;
										HEADER ;
										"",;
										STR0009,;		//Codigo
										STR0010,;		//Nome
										STR0011; 		//Listas
										ON DbLCLICK (aOper[oOpers:nAt,1]:= !aOper[oOpers:nAt,1], oOpers:Refresh());
										ON CHANGE (nOper:= oOpers:nAt) SIZE 205,115 OF oDlg PIXEL NOSCROLL
		
		oOpers:SetArray(aOper)
		oOpers:bLine:={||{IIF(aOper[oOpers:nAt,1],oOk,oNo),;
		                  aOper[oOpers:nAt,2],;
		                  aOper[oOpers:nAt,3],;
						  aOper[oOpers:nAt,4]}}
		
		If FATPDActive() .And. FTPDUse(.T.)
			aPDCols := {"","","U7_NOME",""}    
			oOpers:aObfuscatedCols := FATPDColObfuscate(aPDCols)
		Endif
		oOpers:Refresh() 
		
		DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlg ACTION oDlg:End()
		
		FATPDLogUser('TK062SELOP')	// Log de Acesso LGPD
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega Array com os operadores selecionadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nForOp := 1 To Len(aOper)
		IF aOper[nForOp][1]   // Avalia se foi selecionado
			Aadd(aOper2,aOper[nForOp])
		Endif
	Next nForOp
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe nenhum operador for selecionado todos serao consideradosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aOper2) == 0
		aOper2 := aClone(aOper)
	Endif
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRotina automatica. Nao ha interface. Todos os operadores serao selecionados    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aOper2 := aClone(aOper)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena array.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aOper2)>0
	aSortOper := ASORT(aOper2,,, { |x, y| x[4] < y[4] }) //CRESCENTE
Else
	Aadd(aSortOper,{"",""})
Endif

RestArea(aArea)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ O primeiro item do array sera o operador que possui a menor quantidade de tarefas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return (aSortOper[1][2])

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062GrvTarefaบAutor  ณVendas Clientes     บ Data ณ  07/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a tarefa no SU7 para o operador.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo do operador                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ   DATA   ณ Programador   ณManutencao Efetuada                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ               ณ                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062GrvTarefa(cSelOper,nOpX)

Local lRet := .F.
Local aSArea := GetArea()
Local nVal   := 0

DbSelectArea("SU7")
DbSetOrder(1)
IF MSSeeK(xFilial("SU7")+ cSelOper)
    nVal := SU7->U7_TAREFA
    
    If nOpX == 1
 	   nVal++
	Else
	   If nVal > 0
	      nVal--
	   Endif
	Endif
	
	RecLock("SU7",.F.)
	Replace U7_TAREFA  With  nVal
	MsUnlock()
	DbCommit()
	lRet := .T.
Endif
RestArea(aSArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062Vld  บAutor  ณVendas Clientes     บ Data ณ  30/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o campo U4_MALA para quando a op็ใo for diferente de บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
 Funcao Tk061VLD esta no fonte Tmka061 da Lista de Contatos padrao.
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062Help บAutor  ณVendas Clientes     บ Data ณ  30/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe todas as inconformidades de dados que nao permitiram aบฑฑ
ฑฑบ          ณgeracao da Lista.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Help(cText,nHandle)

Local cPath		:= AllTrim(GetTempPath())
Local nErase	:= 1
Local lHtml		:= FindFunction("ISHTML") .AND. IsHTML()		// Indica se e remote HTML
Local lSrvUnix	:= IsSrvUnix()								//Verifica se o server ้ Linux
Local cOrigem	:= ""
Local cArqLog	:= "TMKSU4LISTA_" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".LOG"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o SmartClient for HTML, bloqueia o log (poque nao consegue acessar diretorio local) |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If lHtml
	Aviso(STR0026,STR0027,{"OK"},2)
	Return(NIL)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApago arquivo antigo do tempณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If File(cPath + cArqLog)
	nErase := FERASE(cPath + cArqLog)

	While nErase = -1
		nErase := FERASE(cPath + cArqLog)
	EndDo
Endif

If lSrvUnix
	cOrigem := Lower(GetSrvProfString("Startpath","") + cArqLog)
	CpyS2T( cOrigem ,cPath, .F.)
Else
	CpyS2T(GetSrvProfString("Startpath","") + cArqLog, cPath, .T.)
EndIf

Help(" ",1,"TK062OCORR")
WinExec("NOTEPAD "+ cPath + cArqLog, 1)
cText := ""
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK062SETFILTบAutor  ณVendas Clientes     บ Data ณ  08/13/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa o filtro selecionado.                                บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062SetFilt(cFiltro,cEntidade)

Local aArea := GetArea()

DbSelectArea(cEntidade)
DbCloseArea()
ChkFile(cEntidade)

Set Filter To &(cFiltro)

RestArea(aArea)
Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062RetEveบAutor  ณVendas Clientes     บ Data ณ  08/26/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta customizada de Eventos.  Utilizada para verificar a บฑฑ
ฑฑบ          ณamarracao que existe no SUW.                                 บฑฑ
ฑฑบ          ณExibe somente os eventos amarrados a campanhas.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCodigo do Evento selecionado.                                บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062RetEve()

Local nEvento    := 0		//Evento selecionado no ListBox
Local oDlgEve				//Objeto do dialogo
Local aEventos   := {}		//Array com eventos para exibicao na ListBox
Local lRet       := .F.		//Retorno da funcao
Local cFilialSUW := xFilial("SUW")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs dados de Campanha e Script devem estar preenchidos para o relacionamento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(M->U4_CODCAMP) .OR. Empty(M->U4_SCRIPT)
	Help(" ",1,"TMK061EVEN")//"A Campanha ou o Script nใo foram selecionados. Para a sele็ใo do Evento ้ necessแrio o preenchimento dos campos."
	Return (lRet)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o array de eventos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SUW")
DbSetOrder(1)
If MSSeeK(cFilialSUW+ M->U4_CODCAMP+ M->U4_SCRIPT )
	While !(SUW->(EOF())) .AND. (cFilialSUW == SUW->UW_FILIAL) .AND. (SUW->UW_CODCAMP == M->U4_CODCAMP) .AND. (SUW->UW_CODSCRI == M->U4_SCRIPT)
    	Aadd(aEventos,{SUW->UW_CODEVE, SUW->UW_DESCEVE})
		SUW->(DbSkip())
	End
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se foram encontrados eventosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aEventos) == 0
	MsgInfo(STR0025) //"Nenhum evento foi encontrado para a campanha selecionada."
	Return (lRet)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDialog.                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgEve FROM  00,00 TO 230,440 TITLE STR0018 PIXEL  //"Consulta de Eventos"
	
	@ 05,05 LISTBOX oLbx FIELDS ;
		    HEADER ;
			    STR0009,;   //"Cขdigo"
			    STR0010;	//"Nome"
		    SIZE 180,100  NOSCROLL OF oDlgEve PIXEL ;
	        ON DBLCLICK(nEvento := oLbx:nAt,oDlgEve:End())
	       	
			oLbx:SetArray(aEventos)
			oLbx:nAt:= Len(aEventos)
			oLbx:bLine:={||{aEventos[oLbx:nAt,1],;  //Cขdigo
							aEventos[oLbx:nAt,2] }} //Evento

	DEFINE SBUTTON FROM 05,190 TYPE 1  	ENABLE OF oDlgEve ACTION (nEvento:=oLbx:nAt ,oDlgEve:End())
	DEFINE SBUTTON FROM 20,190 TYPE 2  	ENABLE OF oDlgEve ACTION (oDlgEve:End())

ACTIVATE MSDIALOG oDlgEve CENTERED

If nEvento > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona no registro correto para ser atualizado o campo .ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRet := .T.
	DbSelectArea("ACD")
	DbSetOrder(1)
	MSSeeK(xFilial("ACD") + Alltrim(aEventos[nEvento,1]))
	
Endif
 
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062ContDescบAutor  ณVendas Clientes     บ Data ณ  30/07/02   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descricao do contato. Objetivo Salvar a area anteriorบฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	             ณฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062ContDesc(cContato)

Local aArea := GetArea()
Local cDesc	:= ""

SU5->(DbSetOrder(1))
If	SU5->(MsSeek(xFilial("SU5")+cContato))
	cDesc	:= Alltrim(SU5->U5_CONTAT)
	FATPDLogUser('TK062CONTD')	// Log de Acesso LGPD
EndIf

RestArea(aArea)
Return(cDesc+" ")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK062VALSUCบAutor  ณVendas Clientes    บ Data ณ  11/20/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se existem registros pendentes do Atend. TeleMarke- บฑฑ
ฑฑบ          ณting. Caso exista este contato nใo sera incluso na lista.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK062VALSUC(cContato, cFilialSUC)

Local lRet 		:= .T.
Local lCodeBase 	:= .T.

Default cFilialSUC := xFilial("SUC")

If lSQL // se for dbAccess
	If Type("cTblSUC")=="C" // Private declarado na TMKA062
		If (cTblSUC)->(MsSeek(cContato))
			lRet := !( (cTblSUC)->TOTALREG > 0 ) // se encontou mais de um registro com UC_STATUS='2'
		Else
			lRet := .T.
		EndIF
		lCodeBase := .F. // Jแ foi validado, nใo precisa passar pela validacao via codebase
	EndIf
EndIf

If lCodeBase
	SUC->(DbSetOrder(6))
	If 	SUC->(MsSeek(cFilialSUC + cContato))
		While SUC->(!Eof()) .AND. cFilialSUC == SUC->UC_FILIAL .AND. cContato == SUC->UC_CODCONT
			If Val(SUC->UC_STATUS) == 2
				lRet  := .F.
				Exit
			Endif
			SUC->(DbSkip())
		EndDo
	Endif
EndIf
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062WriteบAutor  ณVendas Clientes     บ Data ณ  27/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Avalia o tamanho do texto de log, armazena em disco e     บฑฑ
ฑฑบ          ณ limpa variแel para nao existir estouro de pilha.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK062Write(cText,nHandle,lFim)

DEFAULT lFim := .F.

//Se tamanho do texto for maior que 200 bites grava no arquivo texto
If ((Len(cText)>200) .OR. (lFim))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEscreve arquivo de Log.                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FWrite(nHandle, cText)
	cText := ""
Endif

If lFim
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFecho arquivo para poder movelo.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FClose(nHandle)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk062AtivaบAutor  ณVendas Clientes     บ Data ณ  08/18/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla a geracao de listas para OutBound.Listas Ativas    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcAlias: Alias da Rotina                  	              	  ณฑฑ
ฑฑณ          ณnReg:   Registro posicionado          	              	  ณฑฑ
ฑฑณ          ณnOpc:   Opcao selecionada             	              	  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Ativa(cAlias,nReg,nOpc)

Local lTk062Out  := ExistBlock("TK062OUT") // Ponto de entrada para geracao de listas OutBound

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se esta lista ja foi trabalhada. Caso contrario ela poderaณ
//ณser utilizada.                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Tk062ValAlt(cAlias,nReg,nOpc)
	Help(" ",1,"TK062LSTEX")
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona dicionarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea(cAlias)
DbSetOrder(1)
MsGoTo(nReg)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta o ponto de entrada e aguarda retorno.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTk062Out
	If U_Tk062OUT(SU4->U4_LISTA)// RdMake
		Help(" ",1,"TK062SUCES")
	Else
		Help(" ",1,"TK062ERROR")
	Endif
Else
	Help(" ",1,"NO_IX",,"TK062OUT",3,5)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK062ArqOutบAutor ณVendas Clientes     บ Data ณ  08/18/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera arquivo de comunicacao para liga็๕es preditivas        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcLista: Codigo da Lista de Contatos      	              	  ณฑฑ
ฑฑณ          ณcDir  : Endereco onde sera gravado o arquivo texto    	  ณฑฑ
ฑฑณ          ณcFile : Nome do arquivo texto. Este deve conter a extensao. ณฑฑ
ฑฑณ          ณlAgente:Identificacao do Agente no arquivo. True-Identifica.ณฑฑ
ฑฑฬออออออออ	ออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062ARQOUT(cLista,cDir,cFile,lAgente)

Local lRet 		:= .T. 	// Retorno da Funcao
Local nHandle	:= 0	// Arquivo txt
Local nErase	:= 1	// Controle de delecao
Local cTpFoneU4	:= ""   // Variavel de auxilio para geracao das informacoes
Local cFone		:= ""	// Variavel de auxilio para geracao das informacoes
Local nCont		:= 0	// Contador
Local aUser   	:= {}	// Array com os dados do usuแrio
Local cAgentID	:= "" 	// Id do Agente para arquivo // Ramal do configurador.
Local aFone		:= {}	// Array com os telefones para contato
Local cComplTel := ""	// Complemento para discagem externa
Local cFilialSU6 := xFilial("SU6")
Local cFilialSU5 := xFilial("SU5")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o arquivo ja existe e nao permite uma nova geracao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If File(cDir+cFile)
	Help(" ",1,"TK062ARQUI",,cDir + cFile,3,0)
	Return .F.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrimeiramente o arquivo sera criado no SigaAdv e posteriormenteณ
//ณcopiado para o diretorio informado pelo usuแrio.               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//Verifica se o arquivo esta no SigaAdv
If File(cFile)
	// Limpa SigaAdv
	nErase := FERASE(cFile)
	
	While nErase = -1
		nErase := FERASE(cFile)
	EndDo
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria novo Arquivo  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FCREATE(cFile,1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDetalhes da informacao     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If MSSeeK(xFilial("SU4")+cLista)

	Do Case
		Case SU4->U4_TIPOTEL == "1"
			cTpFoneU4	:= "HomePhone"
		Case SU4->U4_TIPOTEL == "2"
			cTpFoneU4	:= "Mobile"
		Case SU4->U4_TIPOTEL == "3"
			cTpFoneU4	:= "NoContactType"
		Case SU4->U4_TIPOTEL == "4"
			cTpFoneU4	:= "DirectBusinessPhone"
		Case SU4->U4_TIPOTEL == "5"
			cTpFoneU4	:= "DirectBusinessPhone"
	EndCase
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAvalia o complemento do Telefone. Caso seja necessario utilizar o campo U0_EXTERNAณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cComplTel := TkPosto(SU4->U4_OPERAD,"U0_EXTERNA")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca o login do agente com base no operador.			ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If lAgente
		DbSelectArea("SU7")
		DbSetOrder(1)
		If MSSeeK(xFilial("SU7")+SU4->U4_OPERAD)
			cChave := SU7->U7_CODUSU
		Endif

		PswOrder(1)
		PswSeek(cChave)
		aUser:= PswRet(1)
		If Len(aUser) > 0
			cAgentID:= aUser[1][20]
		Endif
	Endif
    		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca informacoes da Lista para gera็ใo do Arquivo Texto.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SU6")
	DbSetOrder(1)
	If MSSeeK(cFilialSU6+cLista)
		While (	 !EOF()							 .AND.;
				 cFilialSU6==SU6->U6_FILIAL .AND.;
				 cLista==SU6->U6_LISTA )
                                    
			DbSelectArea("SU5")
			DbSetOrder(1)
			If MSSeeK(cFilialSU5 + SU6->U6_CONTATO)
				aFone:= SGReadTel("SU5",SU6->U6_CONTATO)
				Do Case
					Case SU4->U4_TIPOTEL == "1"
						cFone:=	ALLTRIM(cComplTel) + aFone[1]
					Case SU4->U4_TIPOTEL == "2"
						cFone:= ALLTRIM(cComplTel) + aFone[2]
					Case SU4->U4_TIPOTEL == "4"
						cFone:=	ALLTRIM(cComplTel) + aFone[3]
					Case SU4->U4_TIPOTEL == "5"
						cFone:=	ALLTRIM(cComplTel) + aFone[4]
				EndCase

			Endif

		    // Volta laco para SU6
			DbSelectArea("SU6")

			nCont++

			FWrite(nHandle,;
					"record_id="+AllTrim(STR(nCont))					+;//Transform(nCont,"999999")
					"|phone="+Alltrim(cFone)							+;
					"|phone_type="+"DirectBusinessPhone"				+;//Alltrim(cTpFoneU4)
					"|record_type="+"General"							+;
					"|record_status="+"Ready"							+;
					"|call_result="+"Unknown"							+;
					"|attempt=0"										+;
					"|dial_sched_time="			 						+;
					"|call_time="										+;
					"|daily_from=" + SU6->U6_HRINI						+;
					"|daily_till=" + SU6->U6_HRFIM						+;
					"|tz_dbid=-10800"    		 						+;
					"|campaign_id="	    		 						+;
					"|agent_id="+cAgentID  		 						+;
					"|chain_id="+AllTrim(STR(nCont))					+;
					"|chain_n=0"	    		 						+; // envio sempre um unico telefone
					"|ID_Cliente="	    		 						+;
					CRLF)
			DbSkip()
		EndDo
	Endif
Endif

//Zera contador.
nCont	:= 0

// Fecha arquivo para copia.
FClose(nHandle)
__CopyFIle(cFile,cDir+cFile)

FATPDLogUser('TK062ARQOU',2)	// Log de Acesso LGPD

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTkValAlt  บAutor  ณVendas Clientes     บ Data ณ  07/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Verifica se a Lista ja foi executada, caso positivo o     บฑฑ
ฑฑบ          ณ cadastro  nao sera aberto para alteracao.                  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcAlias: Alias da Rotina                  	              	  ณฑฑ
ฑฑณ          ณnReg:   Registro posicionado          	              	  ณฑฑ
ฑฑณ          ณnOpc:   Opcao selecionada             	              	  ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณUso		 ณ Lista de Inadimplentes (TeleCobranca)		   	          ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062ValAlt(cAlias,nReg,nOpc)

Local lRet			:= .T.    					// Flag que define se pode alterar.
Local aArea		:= GetArea("SU4")
Local cLista		:= ""
Local cAliasAux	:= ""

DbSelectArea(cAlias)
DbSetOrder(1)
MsGoTo(nReg)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNessa rotina somente as Listas de Cobranca pode ser manipuladasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Val(SU4->U4_TIPO) == COBRANCA
	cAliasAux	:= GetNextAlias()
	cLista		:= SU4->U4_LISTA
	BeginSql alias cAliasAux
		SELECT count(*) REGS
		  FROM %Table:SU6% SU6
		 WHERE SU6.U6_FILIAL = %xfilial:SU6%
		   AND SU6.U6_LISTA = %exp:cLista%
		   AND SU6.U6_STATUS <> '1'
		   AND SU6.%NotDel%
	EndSql

	lRet := !( (cAliasAux)->REGS > 0 )
	(cAliasAux)->(DbCloseArea())
Else
	Help(" ",1,"TK062NOCOB") // Essa lista nao e de Cobranca
	lRet := .F.
Endif

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK062Legenda บAutor  ณVendas Clientes  บ Data ณ  23/07/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegendas dos browses de Lista de Cobrancas                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CALL CENTER                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk062Legenda()

BrwLegenda(cCadastro,STR0024,{{"BR_VERDE",    STR0028},;	//"Legenda"##"Vendas"
                              {"BR_AZUL",     STR0029},;	//"Marketing"
                              {"BR_VERMELHO", STR0030}})	//"Cobran็a"
Return(.T.)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta fun็ใo deve utilizada somente ap๓s a inicializa็ใo das variaveis 
    atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive

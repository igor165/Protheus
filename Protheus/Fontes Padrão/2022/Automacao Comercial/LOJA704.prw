#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA704.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOJA704  ³ Autor ³ Alan Oliveira         ³ Data ³ 11/04/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de Reservas pelo EAI                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO EAI                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA704(aCabReser, aGridReser, nOper, cXMLRet, aProdRet)

    Local aCliente 		:= {} 
    Local aReservas		:= {}
    Local aLin			:= {}
    Local dDtLimite   	:= ctod("  /  /    ")
    Local cReserv		:= ""
    Local nx			:= 1
    Local aSldEst		:= {}
    Local cMvLjGerSC    := cValToChar( SuperGetMv("MV_LJGERSC",,1) )    //Gera solicitação de compras para reserva sem estoque. 1=Desabilitado o conceito; 2=Habilita o processo; 3=Pergunta 
    Local lRet          := .T.
    Local aLoteAuto     := {}
    Local nLote         := 0
    Local aHeaderAux    := {}
    Local aColsAux      := {}
    Local nQtdJson      := 0
    Local nQtdLote      := 0
    Local nY
    Local aGridAux      := {}
        
    Default aCabReser	:= {}
    Default aGridReser	:= {}
    Default nOper		:= 1
    Default cXMLRet		:= ""
    Default aProdRet	:= {}

    If !Len(aGridReser) > 0

        lRet    := .F.
        cXMLRet += STR0001  //"Itens da reserva não foram enviados."
    Else

        nPosItem   := aScan(aGridReser[1],{|x| x[1] == "C0_PRODUTO" })
        nPosQtd	   := aScan(aGridReser[1],{|x| x[1] == "C0_QUANT"   })
        nPosLoc    := aScan(aGridReser[1],{|x| x[1] == "C0_LOCAL"   })
        nPosLote   := aScan(aGridReser[1],{|x| x[1] == "C0_LOTECTL" })
        nPosSublot := aScan(aGridReser[1],{|x| x[1] == "C0_NUMLOTE" })
        nPosSerie  := aScan(aGridReser[1],{|x| x[1] == "C0_NUMSERI" })
        nPosLocal  := aScan(aGridReser[1],{|x| x[1] == "C0_LOCALIZ" })
        nPosFil	   := aScan(aGridReser[1],{|x| x[1] == "C0_FIL"     })
        nPosDtLim  := aScan(aGridReser[1],{|x| x[1] == "C0_VALIDA"  })

        //Carrega aHeader e aCols que será passado para a função a430Reserv para gerar a reserva
        For nx:=1 To Len(aCabReser)

            //Despresa campos que já são carregados mais abaixo no array aCliente
            If !( AllTrim( aCabReser[nx][1] ) $ "C0_DOCRES|C0_SOLICIT|C0_FILRES" )

                Aadd(aHeaderAux, {  /*X3_TITULO*/                       ,;
                                    aCabReser[nx][1]    /*X3_CAMPO*/    ,;
                                    /*X3_PICTURE*/      ,;
                                    /*X3_TAMANHO*/      ,;
                                    /*X3_DECIMAL*/      ,;
                                    /*X3_VALID  */      ,;
                                    /*X3_USADO  */      ,;
                                    /*X3_TIPO   */      ,;
                                    /*X3_ARQUIVO*/      ,;
                                    "R"                 /*X3_CONTEXT*/  }   )

                //Carrega o acols
                Aadd(aColsAux, aCabReser[nx][2])
            EndIf

        Next nx

        For nx:=1 To Len(aGridReser)

            //Inclusão ou Alteração
            If nOper== 1 .OR. nOper == 2

                SB1->( DbSetOrder(1) )
                If SB1->( DbSeek(xFilial("SB1") + aGridReser[nx][nPosItem][2] + aGridReser[nx][nPosLoc][2]) )
                    
                    SB2->( DbSetOrder(1) )
                    If SB2->( DbSeek(xFilial("SB2") + aGridReser[nx][nPosItem][2] + aGridReser[nx][nPosLoc][2]) )

                        //Valida se o controle de rastro esta ativo ou Controla apenas Endereçamento.
                        If Rastro( aGridReser[nx][nPosItem][2], /*cTipo*/ ) .Or. SB1->B1_LOCALIZ=='S'

                            aSldEst   := SldPorLote(    aGridReser[nx][nPosItem][2]     ,;
                                                        aGridReser[nx][nPosLoc][2]      ,;
                                                        aGridReser[nx][nPosQtd][2]      ,;
                                                        0                               ,;
                                                        aGridReser[nx][nPosLote][2]     ,;
                                                        aGridReser[nx][nPosSublot][2]   ,;
                                                        aGridReser[nx][nPosLocal][2]    ,;
                                                        aGridReser[nx][nPosSerie][2]    )

                            LjGrvLog(SB1->B1_COD, "Produto com rastro, saldo por lote:", aSldEst)

                            If Len(aSldEst) > 0                               

                                nQtdJson := aGridReser[nx][nPosQtd][2]
                                nTamReserv := Len(aGridReser)
                                nLotes := Len(aSldEst)

                                If nLotes >= 1                                                                    
                                    For nY := 1 To nLotes 
                                        aadd(aGridAux,Aclone(aGridReser[nx]))
                                
                                        aGridAux[nY][nPosLote][2]   := aSldEst[nY][1] //LOTE
                                        aGridAux[nY][nPosSublot][2] := aSldEst[nY][2] //SUBLOTE
                                        aGridAux[nY][nPosLocal][2]  := aSldEst[nY][3] //ENDERECO
                                        aGridAux[nY][nPosSerie][2]  := aSldEst[nY][4] //SERIE
                                        aGridAux[nY][nPosQtd][2]    := aSldEst[nY][5] //QTD

                                        nQtdLote += aGridAux[nY][nPosQtd][2]
                               
                                    Next nY
                                EndIf

                                If !(nQtdJson == nQtdLote)

                                    cXMLRet += I18n(STR0002, { cValToChar(aGridReser[nx][nPosQtd][2]) } )   //"Não existe um Lote que consiga atender a quantidade solicitada(#1). Verifique o Saldo por Lote!"
                                    lRet    := .F.

                                    For nLote:=1 To Len(aSldEst)

                                        Aadd(aProdRet, {    Alltrim(aGridReser[nx][nPosItem][2]),;  //PRODUTO
                                                            aSldEst[nLote][5]                   ,;  //QUANTIDADE
                                                            aSldEst[nLote][1]                   ,;  //LOTE
                                                            aSldEst[nLote][2]                   ,;  //SUBLOTE
                                                            aSldEst[nLote][3]                   ,;  //ENDERECO
                                                            aSldEst[nLote][4]   }               )   //SERIE
                                    Next nLote
                                    cReserv := "" //Caso não atenda a quantidade retorna branco para a chamada para rollback
                                    Exit
                                EndIf
                                nQtdLote := 0
                            Else

                                cXMLRet += I18n(STR0003, { Alltrim(aGridReser[nx][nPosItem][2]) } )     //"Não existe Saldo por Lote para o Produto #1."
                                lRet    := .F.
                                Aadd(aProdRet, {    Alltrim(aGridReser[nx][nPosItem][2]),;
                                                    0                                   ,;
                                                    aGridReser[nx][nPosLote][2]         ,;
                                                    aGridReser[nx][nPosSublot][2]       ,;
                                                    aGridReser[nx][nPosLocal][2]        ,;
                                                    aGridReser[nx][nPosSerie][2]    }   )
                                cReserv := "" //Caso não tenha saldo retorna branco para a chamada para rollback
                                Exit
                            Endif

                        ElseIf SaldoSb2() < aGridReser[nx][nPosQtd][2] .AND. Alltrim(cMvLjGerSC) == "1"
                            cXMLRet += I18n(STR0004, { Alltrim(aGridReser[nx][nPosItem][2]) } )     //"Saldo do Produto #1 é menor que a quantidade solicitada!"
                            lRet    := .F.
                            Aadd(aProdRet, { Alltrim(aGridReser[nx][nPosItem][2]), SaldoSb2(), "", "", "", ""} )
                        else
                            //alimenta o array para produto sem rastro
                            aadd(aGridAux,Aclone(aGridReser[nx]))
                        EnDif
                    Else

                        If !Alltrim(cMvLjGerSC) == "1"
                            cXMLRet += STR0005 + aGridReser[nx][nPosItem][2]    //"Não existe saldo para o Produto: "
                            lRet    := .F.
                            Aadd(aProdRet, { Alltrim(aGridReser[nx][nPosItem][2]), 0, "", "", "", ""} )		
                        Endif
                    Endif

                Endif
            else
                //alimenta o array para oper=3 --exclusão
                aadd(aGridAux,Aclone(aGridReser[nx]))                        
            Endif

            If lRet
                For nY := 1 To Len(aGridAux)
                    //Armazenas os dados do cliente em um array para enviar via RPC para cadas
                    //tra-lo na outra loja se necessario	
                    aAdd(aCliente,{"EAILOJA704",.T.				 , Nil })
                    AAdd(aCliente,{"C0_DOCRES" , aCabReser[aScan(aCabReser,{|x| x[1] == "C0_DOCRES"})][2]	 , Nil })
                    AAdd(aCliente,{"C0_SOLICIT", aCabReser[aScan(aCabReser,{|x| x[1] == "C0_SOLICIT"})][2]	 , Nil })
                    AAdd(aCliente,{"C0_FILRES" , aCabReser[aScan(aCabReser,{|x| x[1] == "C0_FILRES"})][2]	 , Nil })

                    aadd(aLin ,StrZero(nY,2)) 		  			//NÚMERO DO ITEM
                    aadd(aLin ,aGridAux[nY][nPosItem][2])		//CÓDIGO DO PRODUTO
                    aadd(aLin ,aGridAux[nY][nPosQtd][2])		//QUANTIDADE
                    aadd(aLin ,{{aGridAux[nY][nPosLoc][2],;	//LOCAL	
                                0}} )				 			//QUANTIDADE EM ESTOQUE
                    aadd(aLin ,aGridAux[nY][nPosLoc][2])		//LOCAL ONDE SERA FEITA A RESERVA

                    aadd(aLin ,{aGridAux[nY][nPosSublot][2],;	//SUBLOTE
                                aGridAux[nY][nPosLote][2],;	//LOTE
                                aGridAux[nY][nPosLocal][2],;	//ENDERECO
                                aGridAux[nY][nPosSerie][2]})	//SERIE

                    aadd(aReservas,aLin)
                    
                    dDtLimite := aGridAux[nY][nPosDtLim][2]
                    
                    LjGrvLog(Nil, "Conteudo da variavel aReservas enviado como parametro na funcao Lj7GeraSC0()", aReservas)
                    LjGrvLog(Nil, "Conteudo da variavel aCliente enviado como parametro na funcao Lj7GeraSC0()", aCliente)
                    cReserv := Lj7GeraSC0(aReservas, dDtLimite  , aCliente, cFilAnt   , .F.       ,;
                                        .F.      , /*aNumRes*/, @cXMLRet, aHeaderAux, aColsAux  )
                    LjGrvLog(Nil, "Retorno da funcao Lj7GeraSC0 (Geracao da Reserva)", cReserv)
                    
                    If Empty(cReserv) .and. nOper == 1
                        Exit
                    Endif		
                    
                    aLin	 := {}
                    aReservas:= {}
                    aCliente := {}
                Next nY
            EndIf           
            aSldEst  := {}            
            aGridAux := {}
        Next nx
    EndIf

    aSize(aLoteAuto , 0)
    aSize(aSldEst   , 0)
    aSize(aLin      , 0)
    aSize(aReservas , 0)    
    aSize(aCliente  , 0)

Return cReserv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º 	      ³ IntegDef º Autor ³ Alan Oliveira        º Data ³  08/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Funcao de tratamento para o recebimento/envio de mensagem    º±±
±±º           ³ unica de Reserva de produtos.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ LOJA704                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage , cVersion, cTransaction, lJSon )

    Local 	aRet := {}

    Default xEnt 			:= Nil
    Default cTypeMessage 	:= ""
    Default cVersion		:= ""
    Default cTransaction	:= ""
    Default lJSon 			:= .F.

    aRet := LOJI704(xEnt, nTypeTrans, cTypeMessage , lJSon)

Return aRet

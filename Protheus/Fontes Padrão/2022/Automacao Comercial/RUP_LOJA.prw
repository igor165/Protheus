#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_LOJA.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_LOJA 
Função para compatibilização do release incremental. 
Esta função é relativa ao módulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA  

@Author Edilson Cruz
@since 19/10/2015
@version P12
*/
//-------------------------------------------------------------------
Function RUP_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

    Local aSX2			:= {}
    Local aSX3			:= {}											//Dados da SX3
    Local aSX9			:= {}
    Local aSX3Old		:= {}											//Dados anteriores da estrutura SX3
    Local aSX3Estr		:= {}											//Estrutura da SX3
    Local aSX2Estr		:= {}
    Local aSX9Estr		:= {}
    Local aTabelasLJ	:= {}											//Tabelas para Loja
    Local nCountTabLJ	:= 0											//Contador

    //Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
    //Passa uma vez para cada empresa
    If cMode == "1" 

        //-------------------------------------------------------------------
        //Atualizações necessárias para o release V12.1.17
        //-------------------------------------------------------------------
        If cRelStart >= "001"

            aSX2Estr := {;
                        "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"    , "X2_NOMESPA", "X2_NOMEENG", ;
                        "X2_DELET"  , "X2_MODO"   , "X2_MODOUN" , "X2_MODOEMP" , "X2_TTS"     , "X2_ROTINA",;
                        "X2_PYME"   , "X2_UNICO"  , "X2_MODULO" }

            aSX3Estr := {;
                            "X3_ARQUIVO"	,	"X3_ORDEM"		,	"X3_CAMPO"		,	"X3_TIPO",;
                            "X3_TAMANHO"	,	"X3_DECIMAL"	,	"X3_TITULO"		,	"X3_TITSPA",;
                            "X3_TITENG"		,	"X3_DESCRIC"	,	"X3_DESCSPA"	,	"X3_DESCENG",;
                            "X3_PICTURE"	,	"X3_VALID"		,	"X3_USADO"		,	"X3_RELACAO",;
                            "X3_F3"			,	"X3_NIVEL"		,	"X3_RESERV"		,	"X3_CHECK",;
                            "X3_TRIGGER"	,	"X3_PROPRI"		,	"X3_BROWSE"		,	"X3_VISUAL",;
                            "X3_CONTEXT"	,	"X3_OBRIGAT"	,	"X3_VLDUSER"	,	"X3_CBOX",;
                            "X3_CBOXSPA"	,	"X3_CBOXENG"	,	"X3_PICTVAR"	,	"X3_WHEN",;
                            "X3_INIBRW"		,	"X3_GRPSXG"		,	"X3_FOLDER"		,	"X3_PYME" }
            
            aSX9Estr := {;
                        "X9_DOM"	, "X9_IDENT"	, "X9_CDOM"		, "X9_EXPDOM"	,;
                        "X9_EXPCDOM", "X9_PROPRI"	, "X9_LIGDOM"	, "X9_LIGCDOM"	,;
                        "X9_CONDSQL", "X9_USEFIL"	, "X9_ENABLE"	, "X9_VINFIL"	,;
                        "X9_CHVFOR"	;
                        }
            
            //SX2 que precisam ser alterados, baseados em seus alias
            aSX2 := {"MBU","MBV","MBW","MBX"}

            //SX9 que precisa ser alterado/removido
            Aadd(aSX9,{'SA2',NIL,'SLK', NIL ,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})	

            //Atualiza o dicionario de dados
            AtuSX2(aSX2, aSX2Estr)
                                                                            
            AtuSX3(aSX3, aSX3Estr, aSX3Old)
            
            AtuSX9(aSX9, aSX9Estr)
        EndIf

        //-------------------------------------------------------------------
        //Atualizações necessárias para o release V12.1.25
        //-------------------------------------------------------------------
        If cRelStart <= "025" .And. cRelFinish >= "025"

            //-------------------------------------------
            //DVARLOJ1-4114 - Retirada de gatilhos da SL2
            //-------------------------------------------
            LOJ1_4114()
        EndIf

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX2()
@Param aSX2Estr, Array , contendo campos do SX2

@author Julio.Nery
@since 18/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX2(aSX2,aSX2Estr)

    Local cAltX2Rot	:= "MBU,MBV,MBW,MBX" 
    Local nX		:= 0

    DbSelectArea('SX2')
    SX2->(DbSetOrder(1))

    For nX := 1 to Len(aSX2)
        If (aSX2[nX] $ cAltX2Rot) .And. SX2->(DbSeek(aSX2[nX]))
            RecLock("SX2",.F.)
            REPLACE SX2->X2_ROTINA WITH "LOJA1156()"
            SX2->(MsUnlock())
            SX2->(dbCommit())
            Conout(JurTimeStamp( 2 ) + " X2_ROTINA alterado [" + SX2->X2_ARQUIVO + " ] ")
        EndIf
    Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX3(aSX3)
Função para ajustar o SX3. Caso aSX3Old tenha conteúdo, a alteração é 
realizada apenas se o conteúdo for igual a base do cliente.
Uso Geral

@Param aSX3 Array com alterações do arquivo SX3
@Return

@author Cristina Cintra
@since 15/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX3(aSX3, aSX3Estr, aSX3Old)

    Local nI	:= 0
    Local nJ	:= 0
    Local nPos	:= 0
    Local cKey	:= ""
    Local lInclui:= .T.			//Status de inclusão ou alteração
    /*
    aSX3Estr/aSX3
    [1]X3_ARQUIVO
    [2]X3_CAMPO
    */

    DbSelectArea("SX3")
    SX3->( DbSetOrder(2) )		//X3_CAMPO

    For nI:= 1 To Len(aSX3)

        If !Empty(aSX3[nI][1])
            
            cKey := PadR( aSX3[nI][3], 10)
            
            If SX3->( DbSeek(cKey) ) 
                lInclui := .F.
            Else
                lInclui := .T.
            EndIf
            
            If lInclui
                //Atribuo a ordem nova para o registro
                aSX3[nI][2] := ProxSX3(aSX3[nI][1],aSX3[nI][3])
            
                RecLock("SX3",lInclui)
            
                For nJ:=1 To Len(aSX3[nI])
                    nPos := ColumnPos(aSX3Estr[nJ])
                    If nPos  > 0
                        //Só altera se não tiver conteudo anterior ou o conteudo do campo X3_XXX atual for igual ao conteudo do release para não alterar customizações.
                        If Len(aSX3Old) == 0 .OR. ( Upper(Alltrim(SX3->&(aSX3Estr[nJ]))) == Upper(Alltrim(aSX3Old[nI][nJ])) )
                            //Adiciona novo valor no X3_XXX do campo
                            FieldPut(nPos,aSX3[nI,nJ])
                        EndIf	
                    EndIf
                Next nJ
            
                MsUnLock("SX3")
                SX3->(dbCommit())
            
                ConOut( JurTimeStamp( 2 ) + " " + STR0001 + cKey )	//"Campo não encontrado: Criado campo "
            EndIf		
        EndIf
    Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX9()
@Param aSX9Estr, Array , contendo campos do SX9
@author Julio.Nery
@since 07/11/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX9(aSX9,aSX9Estr)

    Local nX		:= 0
    Local nTamSeek  := 0
    Local lFind		:= .F.
    Local cContDom	:= ""

    DbSelectArea('SLK')
    DbSelectArea('SX9')

    nTamSeek := Len( SX9->X9_DOM )

    SX9->(DbSetOrder( 2 ))   

    //Removo esse relacionamento pois os campos não existem no Dicionário Atual
    For nX := 1 to Len(aSX9)
        If aSX9[nX][1] == "SA2" .And. aSX9[nX][3] == "SLK" .And. aSX9[nX][2] == NIL
            lSeek := SX9->( dbSeek( PadR( aSX9[nX][3], nTamSeek) + PadR( aSX9[nX][1], nTamSeek)))
            
            While lSeek  .And. (AllTrim(SX9->X9_DOM) == "SA2") .And. (AllTrim(SX9->X9_CDOM) == "SLK") .And. !SX9->(Eof())
                lFind	:= .F.
                cContDom := AllTrim(SX9->X9_EXPDOM) + "|" + AllTrim(SX9->X9_EXPCDOM) 
                
                If "LK_FORNECE" $ cContDom 
                    lFind := .T.
                EndIf
                
                If "LK_LOJA" $ cContDom
                    lFind := .T.
                EndIf
                
                If lFind
                    Conout(JurTimeStamp( 2 ) + " SX9 deletado [ " + cContDom + " ] ")
                    RecLock("SX9",.F.)
                    SX9->(DbDelete())
                    SX9->(DbCommit())
                    SX9->(MsUnlock())
                EndIf
                
                SX9->(DbSkip())
            End
        EndIf
    Next nX

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ProxSX3  ³ Autor ³                       ³ Data ³ 23/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a próxima ordem disponivel no SX3 para o ALIAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProxSX3(cAlias, cCpo)

    Local aArea 		:= GetArea()
    Local aAreaSX3 		:= SX3->(GetArea())
    Local nOrdem		:= 0
    Local nPosOrdem		:= 0
    Local xRet			:= NIL

    Static aOrdem		:= {}

    Default cCpo		:= ""

    If !Empty(cCpo)
        SX3->(DbSetOrder(2))
        If SX3->(MsSeek(cCpo))
            nOrdem := Val(RetAsc(SX3->X3_ORDEM,3,.F.))
        Endif
    Endif
    If Empty(cCpo) .OR. nOrdem == 0
        If (nPosOrdem := aScan(aOrdem, {|aLinha| aLinha[1] == cAlias})) == 0
            SX3->(dbSetOrder(1))
            SX3->(MsSeek(cAlias))
            While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
                nOrdem++
                SX3->(dbSkip())
            EndDo
            nOrdem++
            aAdd(aOrdem,{cAlias,nOrdem})
        Else
            aOrdem[nPosOrdem][2]++
            nOrdem := aOrdem[nPosOrdem][2]
        Endif
    Endif
    RestArea(aAreaSX3)
    RestArea(aArea)

    xRet := RetAsc(Str(nOrdem),2,.T.)

Return xRet

//-------------------------------------------------------------------
/*{Protheus.doc} LOJ1_4114 
Função necessária para a issue DVARLOJ1-4114.
Retirada de gatilhos da SL2.

@since  04/11/2019
*/
//-------------------------------------------------------------------
Static Function LOJ1_4114()

    Local aArea 	:= {}
    Local aAreaSX3  := {}
    Local aAreaSX7  := {}
    Local cTabela   := "SL2"
    Local cCampo    := ""

    aArea    := GetArea()
    aAreaSX3 := SX3->( GetArea() )
    aAreaSX7 := SX7->( GetArea() )

    SX3->( DbSetOrder(1) )
    SX3->( DbSeek(cTabela) )
    While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cTabela

        If SX3->X3_TRIGGER == "S"

            Begin Transaction

                cCampo := SX3->X3_CAMPO

                SX7->( DbSetOrder(1) )
                SX7->( DbSeek(cCampo) )
                While !SX7->( Eof() ) .And. SX7->( DbSeek(cCampo) )
                    RecLock("SX7", .F.)
                        SX7->( DbDelete() )
                    SX7->( MsUnlock() )

                    SX7->( DbSkip() )
                EndDo
                
                RecLock("SX3", .F.)
                    SX3->X3_TRIGGER := ""
                SX3->( MsUnlock() )

            End Transaction

        EndIf

        SX3->( DbSkip() )
    EndDo

    RestArea(aAreaSX7)
    RestArea(aAreaSX3)
    RestArea(aArea)

Return Nil
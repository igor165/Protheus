#include 'TOTVS.ch'
#include 'fileio.ch'
#include 'RWMAKE.CH'
#include 'protheus.ch'
#include 'parmtype.ch'

/* IGOR OLIVEIRA 29/03/2022
    RELATÓRIO CORRETORES */
 USER FUNCTION VAESTIG3()
    Local cTimeINi  := Time()
    Local cStyle    := ""
    Local cXML      := ""
    Local lTemDados := .T.
    Local cPerg     := "VAESTIG3"
    Private cTitulo     := "Relatório - Corretores"
    Private cPath       := "C:\TOTVS_RELATORIOS\"
    Private cArquivo    := cPath + cPerg +;
                                    DToS(dDataBase)+;//converte a data para aaaammdd
                                    "_"+;
                                    StrTran(Subs(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcelApp   := nil
    Private _cAliasC    := GetNextAlias()  //Corretores

    Private nHandle     := 0
    Private nHandAux    := 0

    GeraX1(cPerg)

    IF Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)

        IF Len(Directory(cPath + "*.*","D")) == 0
            IF Makedir(cPath) == 0 
                ConOut('Diretório criado com sucesso.')
                MsgAlert('Diretorio criado com sucesso: ', + cPath, 'Aviso')
            ELSE
                ConOut("Não foi possivel criar o diretório. Erro: " + CValToChar(FError()))
                MsgAlert('Não foi possível criar o diretório. Erro', CValToChar(FError()),'Aviso')
            ENDIF
        ENDIF
    ENDIF
    
    nHandle := FCREATE(cArquivo)
    IF nHandle = -1
        ConOut("Erro ao criar arquivo - ferror" + Str(FError()))
    ELSE
        cStyle  := U_defStyle()
        
        cXML    := U_CabXMLExcel(cStyle)
        IF !Empty(cXML)
            FWrite(nHandle, EncodeUTF8(cXML))
            cXML := ""
        ENDIF
            // Processar SQL
            FWMsgRun(, {|| lTemDados := fLoadSQL("Corretor", @_cAliasC ) },;
			    'Por Favor Aguarde...',;
				'Processando Banco de Dados - Corretores')
            IF lTemDados
                FWMsgRun(, {|| fQuadro1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro 1')       
            
            
                // Final - encerramento do arquivo
                FWrite(nHandle, EncodeUTF8('</Workbook>'))

                FClose(nHandle)

                IF ApoLeClient("MSExcel") // Verifica se o excel está instado
                    oExcelApp   := MsExcel():New()
                    oExcelApp:WorkBooks:Open(cArquivo)
                    oExcelApp:SetVisible(.T.)
                    oExcelApp:Destroy()
                ELSE
                    MsgAlert("O Excel não foi encontrado. Arquivo" + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado")
                ENDIF            
            ELSE    
                MsgAlert("Os parametros informados não retornaram nenhuma informação do banco de dados." + CRLF + ;
			    "Por isso o excel não será aberto automaticamente.", "Dados não localizados")
            ENDIF    

        (_cAliasC)->(DbCloseArea())        

        IF Lower(cUserName) $ 'ioliveira'
            Alert('Tempo de processamento: ' + ElapTime(cTimeINi, Time()))
        ENDIF

        ConOut('Activate: ' + Time())
    ENDIF
RETURN NIL

STATIC FUNCTION GeraX1(cPerg)
    Local _aArea	:= GetArea()
    Local aRegs     := {}
    Local nX		:= 0
    Local nPergs	:= 0
    Local i
    Local j

    //Conta quantas perguntas existem atualmente.
    DbSelectArea('SX1')
    DbSetOrder(1)
    SX1->(DbGoTop())
    IF SX1->(DbSeek(cPerg))
        WHILE !SX1->(Eof()) .And. X1_GRUPO = cPerg
            nPergs++
            SX1->(DbSkip())
        ENDDO
    ENDIF
         	  
    AADD(aRegs,{cPerg,"01","Data de            ?",Space(20),Space(20),"mv_ch1", 'D'                    ,08                      ,0                       ,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data ate           ?",Space(20),Space(20),"mv_ch2", 'D'                    ,08                      ,0                       ,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"03","Corretor           ?",Space(20),Space(20),"mv_ch3", TamSX3("ZCC_CODCOR")[3], TamSX3("ZCC_CODCOR")[1], TamSX3("ZCC_CODCOR")[2],0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZCC","","","","",""})

//Se quantidade de perguntas for diferente, apago todas
    SX1 -> (DbGoTop())
    IF nPergs <> Len(aRegs)
        FOR nX := 1 to nPergs
            IF  SX1 -> (DbSeek(cPerg))
                IF  RecLock('SX1', .F.)
                    SX1 -> (DbDelete())
                    SX1 -> (MsUnlock())
                ENDIF               
            ENDIF
        NEXT nX
    ENDIF

// gravação das perguntas na tabela SX1
    IF nPergs <> Len(aRegs)
        DbSelectArea("SX1")
        DbSetOrder(1)
        FOR i := 1 to Len(aRegs)
            IF !DbSeek(cPerg+aRegs[i,2])
                RecLock("SX1", .T.)
                    FOR j := 1 to FCOUNT()
                        IF j <= Len(aRegs[i])
                            FieldPut(j,aRegs[i,j])
                        ENDIF
                    NEXT j
                MsUnlock()
            ENDIF
        NEXT i 
    ENDIF

    RestArea(_aArea)
RETURN NIL
// FIM: GeraX1


STATIC FUNCTION fLoadSQL(cTipo, _cAlias)
    Local _cQry := ""

    IF cTipo == "Corretor"   
       _cQry := "SELECT D1_FILIAL -- FILIAL" + CRLF  
       _cQry += "        , ZCC_CODIGO -- CODIGO " + CRLF
       _cQry += "        , D1_PEDIDO -- PEDIDO" + CRLF
       _cQry += "        , A2_NOME -- NOME" + CRLF
       _cQry += "        , D1_COD -- PRODUTO" + CRLF
       _cQry += "        , C7_DESCRI -- DESC PROD." + CRLF
       _cQry += "        , D1_QUANT -- QTDE" + CRLF
       _cQry += "        , D1_TOTAL -- R$ TOTAL" + CRLF
       _cQry += "        , D1_DOC -- NUM NF" + CRLF
       _cQry += "        , D1_SERIE -- NUM SERIE" + CRLF
       _cQry += "        , D1_EMISSAO -- DT EMISSAO" + CRLF
       _cQry += "        , ZCC_CODCOR -- COD. CORRETOR" + CRLF
       _cQry += "        , A3_NOME -- NOME CORRETOR" + CRLF
       _cQry += "        , ZBC_COMUNI -- R$ COMISSAO / CABEÇA" + CRLF
       _cQry += "        , ZBC_VLRCOM -- R$ COMISSÃO TOTAL" + CRLF
       _cQry += "        , ZBC_PESO -- PESO COMPRA" + CRLF
       _cQry += "        , ZBC_REND -- RENDIMENTO COMPRA" + CRLF
       _cQry += "        , ZBC_ARROV -- VALOR COMBINADO" + CRLF
       _cQry += "    FROM " + RetSqlName("SD1") +" SD1" + CRLF
       _cQry += "    JOIN " + RetSqlName("ZBC") +" ZBC ON" + CRLF
       _cQry += "        ZBC_FILIAL = D1_FILIAL " + CRLF
       _cQry += "    AND ZBC_PEDIDO = D1_PEDIDO" + CRLF
       _cQry += "    AND ZBC_PRODUT = D1_COD" + CRLF
       _cQry += "    AND ZBC.D_E_L_E_T_ = ' ' " + CRLF
       _cQry += "    JOIN " + RetSqlName("SC7") +" SC7 ON " + CRLF
       _cQry += "        C7_FILENT = D1_FILIAL" + CRLF
       _cQry += "    AND C7_NUM = D1_PEDIDO" + CRLF
       _cQry += "    AND C7_PRODUTO = D1_COD" + CRLF
       _cQry += "    AND SC7.D_E_L_E_T_ = ' '" + CRLF
       _cQry += "    JOIN " + RetSqlName("ZCC") +" ZCC on" + CRLF
       _cQry += "        ZCC_FILIAL = D1_FILIAL" + CRLF
       _cQry += "    AND ZCC_CODIGO = ZBC_CODIGO" + CRLF
       _cQry += "    AND ZCC_VERSAO = ZBC_VERSAO" + CRLF
       _cQry += "    AND ZCC_CODFOR = ZBC_CODFOR" + CRLF
       _cQry += "    AND ZCC_LOJFOR = ZBC_LOJFOR" + CRLF
       _cQry += "    AND ZCC.D_E_L_E_T_ = ' ' " + CRLF
       _cQry += "    JOIN " + RetSqlName("SA2") +" SA2 ON " + CRLF
       _cQry += "        A2_FILIAL = ' '" + CRLF
       _cQry += "    AND A2_COD+A2_LOJA = D1_FORNECE+D1_LOJA" + CRLF
       _cQry += "    AND SA2.D_E_L_E_T_ = ' ' " + CRLF
       _cQry += "    JOIN " + RetSqlName("SA3") + " SA3 ON " + CRLF
       _cQry += "        A3_COD = ZCC_CODCOR" + CRLF
       _cQry += "    AND SA3.D_E_L_E_T_ = ' '" + CRLF
       _cQry += "    WHERE D1_GRUPO = 'BOV' " + CRLF
       _cQry += "    AND D1_EMISSAO BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "'" + CRLF 
       IF(!Empty(mv_par03))
       _cQry += "    AND ZCC_CODCOR = '" + mv_par03 + "'" + CRLF 
       ENDIF
       _cQry += "    AND SD1.D_E_L_E_T_ = ' ' " + CRLF                           
    ENDIF
    IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    ENDIF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

RETURN !(_cAlias)->(Eof())
//fLoadSQL

STATIC FUNCTION fQuadro1()//Quadro de Carregamento
    LOCAL nRegistros    := 0
    LOCAL cXML          := ""
    LOCAL cWorkSheet    := ""

    (_cAliasC)->(DbEval({|| nRegistros++}))

    (_cAliasC) -> (DbGoTop())

    IF  !(_cAliasC)->(DbGoTop())

        cWorkSheet  := "Corretores"

        cXML += U_prtCellXML( 'Worksheet', cWorkSheet )


	    cXML += ' <Names>'+CRLF
	    cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	    cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+1)+'C17"'+CRLF
	    cXML += ' 	ss:Hidden="1"/>'+CRLF
	    cXML += ' </Names>'+CRLF
        
        cXML += '  <Table>' + CRLF
        cXML += ' <Column ss:Width="33"/>' + CRLF
        cXML += ' <Column ss:Width="43"/>' + CRLF
        cXML += ' <Column ss:Width="41"/>'  + CRLF
        cXML += ' <Column ss:Width="236"/>' + CRLF
        cXML += ' <Column ss:Width="125"/>' + CRLF
        cXML += ' <Column ss:AutoFitWidth="0" ss:Width="102"/>' + CRLF
        cXML += ' <Column ss:Width="30"/>' + CRLF
        cXML += ' <Column ss:Width="53"/>' + CRLF
        cXML += ' <Column ss:Width="44"/>' + CRLF
        cXML += ' <Column ss:Width="56"/>' + CRLF
        cXML += ' <Column ss:Width="62"/>' + CRLF
        cXML += ' <Column ss:Width="81"/>' + CRLF
        cXML += ' <Column ss:Width="135"/>' + CRLF
        cXML += ' <Column ss:Width="117"/>' + CRLF
        cXML += ' <Column ss:Width="102"/>' + CRLF
        cXML += ' <Column ss:Width="74"/>' + CRLF
        cXML += ' <Column ss:Width="114"/>' + CRLF
        cXML += ' <Column ss:Width="101"/>' + CRLF

        cXML += U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
    
        cXML += U_prtCellXML( 'Row',,'33' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'FILIAL'				    ,,.T. )//FILIAL
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'CODIGO' 			        ,,.T. )//CODIGO
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'PEDIDO' 	                ,,.T. )//PEDIDO
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NOME' 	                ,,.T. )//NOME
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'PRODUTO' 			    ,,.T. )//PRODUTO
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'DESC PROD'		        ,,.T. )//DESC PROD
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'QTDE'			        ,,.T. )//QTDE
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ TOTAL'				,,.T. )//R$ TOTAL
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NUM NF'			        ,,.T. )//NUM NF
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NUM SÉRIE'               ,,.T. )//NUM SÉRIE
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'DT EMISSÃO'		        ,,.T. )//DT EMISSÃO
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'COD. CORRETOR'		    ,,.T. )//COD. CORRETOR
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'NOME CORRETOR'	        ,,.T. )//NOME CORRETOR
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ COMISSÃO / CABEÇA'	,,.T. )//R$ COMISSÃO / CABEÇA
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'R$ COMISSÃO TOTAL'		,,.T. )//R$ COMISSÃO TOTAL
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'PESO COMPRA'		        ,,.T. )//PESO COMPRA
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'RENDIMENTO COMPRA'		,,.T. )//RENDIMENTO COMPRA
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s65', 'String', /*cFormula*/, 'VALOR COMBINADO'	        ,,.T. )//VALOR COMBINADO
        cXML += U_prtCellXML( '</Row>' )

        While !(_cAliasC)->(Eof())

	    cXML += U_prtCellXML( 'Row' )
/*01*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_FILIAL    )   ,,.T. )	
/*02*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZCC_CODIGO   )   ,,.T. )  
/*03*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_PEDIDO    )   ,,.T. )
/*04*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> A2_NOME      )   ,,.T. )
/*05*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_COD       )   ,,.T. )	   
/*06*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> C7_DESCRI    )   ,,.T. )	   
/*07*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_QUANT     )   ,,.T. )			
/*08*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_TOTAL     )   ,,.T. )			
/*09*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_DOC       )   ,,.T. )		
/*10*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> D1_SERIE     )   ,,.T. )		
/*11*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> D1_EMISSAO   )   ,,.T. )   
/*12*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto' , 'String', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZCC_CODCOR   )   ,,.T. ) 	    	
/*13*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'String', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> A3_NOME      )   ,,.T. )		       
/*14*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZBC_COMUNI   )   ,,.T. )		
/*15*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZBC_VLRCOM   )   ,,.T. )  
/*16*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZBC_PESO     )   ,,.T. )			
/*17*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sComDig', 'Number', /*cFormula*/ , U_FrmtVlrExcel( (_cAliasC)-> ZBC_REND     )   ,,.T. )
/*18*/  cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig', 'Number',  /*cFormula*/, U_FrmtVlrExcel( (_cAliasC)-> ZBC_ARROV    )   ,,.T. )     
        cXML += U_prtCellXML( '</Row>' )

    	(_cAliasC)->(DbSkip())
		
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
		EndIf
	    
        cXML := ""
    ENDDO

        //linha média geral
        cXML += ' <Row> ' +CRLF
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'1' ,/*cMergeAcross*/,'s65',     'String',  /*cFormula*/,"Total"                                 ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'7' ,/*cMergeAcross*/,'sComDig', 'Number', "=SUM(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",     ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,    ,/*cMergeAcross*/,'sComDig', 'Number', "=SUM(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)",     ,,.T. )
        cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,'16',/*cMergeAcross*/,'sComDig', 'Number', "=AVERAGE(R[-"+CValToChar(nRegistros+1)+"]C:R[-1]C)", ,,.T. )
        cXML += ' </Row> ' +CRLF  

        //fim da tabela 
        cXML += ' </Table>' + CRLF
        cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF
        cXML += '   <PageSetup>' + CRLF
        cXML += '    <Header x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '    <Footer x:Margin="0.31496062000000002"/>' + CRLF
        cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"' + CRLF
        cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>' + CRLF
        cXML += '   </PageSetup>' + CRLF
        cXML += '   <Selected/>' + CRLF
        cXML += '   <TopRowVisible>30</TopRowVisible>' + CRLF
        cXML += '   <LeftColumnVisible>4</LeftColumnVisible>' + CRLF
        cXML += '   <Panes>' + CRLF
        cXML += '    <Pane>' + CRLF
        cXML += '     <Number>3</Number>' + CRLF
        cXML += '     <ActiveRow>33</ActiveRow>' + CRLF
        cXML += '     <ActiveCol>17</ActiveCol>' + CRLF
        cXML += '    </Pane>' + CRLF
        cXML += '   </Panes>' + CRLF
        cXML += '   <ProtectObjects>False</ProtectObjects>' + CRLF
        cXML += '   <ProtectScenarios>False</ProtectScenarios>' + CRLF
        cXML += '  </WorksheetOptions>' + CRLF
        cXML += ' </Worksheet>' + CRLF

        If !Empty(cXML)
		    FWrite(nHandle, EncodeUTF8( cXML ) )
	    EndIf
    	cXML := ""
    ENDIF
RETURN

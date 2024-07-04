#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "RPTDef.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"

//RELATÓRIO TESTE MOVIMENTAÇÃO DE GADO

USER FUNCTION VAEST000()
  Private cPerg := nil

  cPerg := "VAEST000"
  _cQry := ""

  Valida(cPerg)

  While Pergunte(cPerg, .T.)
    MsgRun("Gerando Relatório, Aguarde...","",{|| CursorWait(),ImpRel(@cPerg),CursorArrow()})
  ENDDO


RETURN

STATIC FUNCTION Valida(cPerg)
    LOCAL _sAlias, i, j

    _sAlias :=  Alias()
    DbSelectArea("SX1")
    DbSetOrder(1)
    cPerg := PADR( cPerg, 10)
    aRegs := {}

    aAdd(aRegs,{cPerg,"01","Data de               ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"02","Data até              ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"03","TM Nascimento         ?",Space(20),Space(20),"mv_ch5","C",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"04","TM Morte              ?",Space(20),Space(20),"mv_ch6","C",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

    FOR i := 1 to Len(aRegs)
      IF !dbSeek(cPerg+aRegs[i,2])
          RecLock("SX1", .T.)
          FOR j := 1 to FCOUNT()
              FieldPut(j,aRegs[i,j])
          NEXT
          MsUnlock()
          dbCommit()
      ENDIF
        
    NEXT
    DbSelectArea(_sAlias)
RETURN

STATIC FUNCTION ImpRel(cPerg)
  Private oExcel
  Private oExcelApp
  oExcel  := FWMSExcel():New()//Método Construtor da Classe Excel.
  Private cArquivo := GetTempPath()+'VAEST000_'+StrTran(DToC(dDataBase),'', '')+'_'+StrTran(Time(), ':', '-',)+'.xml'

  

  oExcel:SetFont('Arial')
  oExcel:SetBgColorHeader(ColorToRgb(CLR_GREEN)) // Cor Cabeçalho
  oExcel:SetLineBgColor(ColorToRgb(CLR_GREY))  // Cor Linha 1
  oExcel:Set2LineBgColor(ColorToRgb(CLR_GREY)) //Cor Linha 2

  fQuadro1(cPerg)
  fQuadro12(cPerg)

  oExcel:Activate()
  oExcel:GetXMLfile(cArquivo)

  //Abrindo o Excel e o arquivo XML
  oExcelApp := MsExcel():New()        //Abre uma nova Conexão com o excel
  oExcelApp:Workbooks:Open(cArquivo)  //Abre a Planilha
  oExcelApp:SetVisible(.T.)           //Visualiza a Planilha
  oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas


RETURN

STATIC FUNCTION fQuadro1(cPerg)
  LOCAL aArea       := GetArea()
  LOCAL _cQry       := ''
  LOCAL cAlias      := CriaTrab(,.F.)
  LOCAL cWorkSheet  := "TESTE QUADRO 1"
  LOCAL cTitulo     := "TESTE TITULO 1"
  cTitulo += "- TESTE: " + DToC(MV_PAR01) + " - " + DToC(MC_PAR02)

  oExcel:AddworkSheet(cWorkSheet)
  oExcel:AddTable(cWorkSheet, cTitulo)

    _cQry := "        SELECT  D3.D3_FILIAL                  FILIAL," + CRLF
    _cQry := "                D3.D3_EMISSAO                 EMISSAO," + CRLF
    _cQry := "                B1.B1_XLOTE                   LOTE_ANIMAL," + CRLF
    _cQry := "                D3.D3_COD                     CODIGO," + CRLF
    _cQry := "                B1.B1_DESC                    DESCRICAO," + CRLF
    _cQry := "                D3.D3_OP                      ORDEM_PRODUCAO," + CRLF
    _cQry := "                D3.D3_UM                      UDM," + CRLF
    _cQry := "                D3.D3_QUANT                   QUANTIDADE," + CRLF
    _cQry := "                D3I.D3_COD                    INSUMO," + CRLF
    _cQry := "                D3I.D3_UM                     UM," + CRLF
    _cQry := "                D3I.D3_QUANT                  QTDE" + CRLF
    _cQry := "          FROM  "+RetSqlName("SD3")+"                 D3" + CRLF
    _cQry := "    INNER JOIN  "+RetSqlName("SB1")+"                 B1" + CRLF
    _cQry := "            ON  B1.B1_XLOTE                       =       D3.D3_COD" + CRLF
    _cQry := "            AND B1.D_E_L_E_T_                     =         ' '" + CRLF
    _cQry := "    INNER JOIN  "+RetSqlName("SD3")+"         D3I" + CRLF
    _cQry := "            ON  D3I.D3_OP                         =       D3.D3_OP" + CRLF
    _cQry := "            AND D3I.D3_FILIAL                     =       D3.D3_FILIAL" + CRLF
    _cQry := "            AND D3I.D_E_L_E_T_                    =      ' '" + CRLF
    //_cQry := "          --AND D3I.D3_COD                        <>    D3.D3_COD" + CRLF
    _cQry := "          WHERE D3.D3_GRUPO                       IN      ('LOTE')" + CRLF
    _cQry := "            AND D3.D3_EMISSAO                      =      '"+dTos(mv_par01)+"'AND'"+dTos(mv_par02)+"'" + CRLF
    _cQry := "            AND D3.D3_TM                          IN       ('001','002')" + CRLF
    _cQry := "                UNION ALL "                                                   + CRLF
    _cQry := "         SELECT D3.D3_FILIAL                  FILIAL," + CRLF
    _cQry := "                D3.D3_EMISSAO                 EMISSAO," + CRLF
    _cQry := "                B1.B1_XLOTE                   LOTE_ANIMAL," + CRLF
    _cQry := "                D3.D3_COD                     CODIGO," + CRLF
    _cQry := "                B1.B1_DESC                    DESCRICAO," + CRLF
    _cQry := "                D3.D3_OP                      ORDEM_PRODUCAO," + CRLF
    _cQry := "                D3.D3_UM                      UDM," + CRLF
    _cQry := "                D3.D3_QUANT                   QUANTIDADE," + CRLF
    _cQry := "                D3I.D3_COD                    INSUMO," + CRLF
    _cQry := "                D3I.D3_UM                     UM," + CRLF
    _cQry := "                D3I.D3_QUANT                  QTDE" + CRLF
    _cQry := "           FROM "+RetSqlName("SD3")+"               D3" + CRLF
    _cQry := "     INNER JOIN "+RetSqlName("SB1")+"               B1" + CRLF
    _cQry := "             ON B1.B1_COD                         =       D3.D3_COD" + CRLF
    _cQry := "            AND B1.D_E_L_E_T_                     =      ' '" + CRLF
    _cQry := "     INNER JOIN "+RetSqlName("SD3")+"               D3I" + CRLF
    _cQry := "             ON D3I.D3_OP                         =       D3.D3_OP" + CRLF
    _cQry := "            AND D3I.D3_FILIAL                     =       D3.D3_FILIAL" + CRLF
    _cQry := "            AND D3I.D_E_L_E_T_                    =       ' '" + CRLF
    _cQry := "            AND D3I.D3_COD                        <>      D3.D3_COD" + CRLF
    _cQry := "            AND D3I.D3_CF                         =      'RE1'" + CRLF
    _cQry := "          WHERE D3.D3_FILIAL                      =      '01'  " + CRLF // -- FILIAL 01 (MATRIZ)"
    _cQry := "            AND D3.D3_GRUPO                       IN      ('BOV')   " + CRLF //-- NO ALTERAR (GRUPO DE PRODUTO - FILTRO)
    _cQry := "            AND D3.D3_EMISSAO                     =      '"+dTos(mv_par01)+"'AND'"+dTos(mv_par02)+"'" + CRLF //-- FILTRAR DATA / PERODO
    _cQry := "            AND D3.D3_TM                          IN      ('001','002') " + CRLF //-- NO ALTERAR - SEPARA MOVIMENTAES DE PRODUO
    _cQry := "       ORDER BY FILIAL, EMISSAO, LOTE_ANIMAL, CODIGO, DESCRICAO" + CRLF

  IF Select(cAlias) > 0
    (cAlias) -> (DbCloseArea())
  ENDIF

  MemoWrite(StrTran(cArquivo,".xml","")+"Teste.sql" , _cQry)

  dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry1),(cAlias),.F.,.F.)

  /*TcSetField(cAlias,"D3.EMISSAO", "D") /*AO REALIZAR A ABERTURA DE UMA QUERY. ATRÁVES DESTA FUNÇÃO, TODOS OS CMAPOS NUMÉRICOS SÃO RETORNADOS 
  COM O TAMANHO 15,8(MÁXIMO DE 15 DIGITOS, SENDO 8 DECIMAIS), E OS DEMAIS CAMPOS SÃO TRATADOS E RETORNADOS COM TIPO CARACTERE.
  DESTA FORMA, APÓS ABRIR UMA QUERY SOBRE UMA TABELA DE DADOS DO ERP, PODEMOS UTILIZAR A FUNÇÃO TCSETFIELD, PARA REALIZAR AS ADEQUAÇÕES DE PRECISÃO 
  DE RETORNO PARA CAMPOS NUMÉRICOS, CONVERSÃO AUTOMÁTICA DE TIPOS DE RETORNO PARA OS CAMPOS QUE NÃO SEJAM EXPLICITAMENTE "C" OU "M"(MEMO)*/
  //TcSetField(cAlias,"EMISSAO","D")
  //TcSetField(cAlias,"LOTE_ANIMAL","N")
  //TcSetField(cAlias,"CODIGO","N")

  oExcel:AddColumn( cWorkSheet, cTitulo, "Filial"               , 1, 2)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Emissão"              , 1, 4)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Lote_Animal"          , 1, 2)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Código"               , 1, 1)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Descrição"            , 1, 1)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Ordem de Produção"    , 1, 1)
  oExcel:AddColumn( cWorkSheet, cTitulo, "UDM"                  , 1, 1)
  oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade"           , 1, 1, .T.)
  //oExcel:AddColumn( cWorkSheet, cTitulo, "Insumo"               , 1, 1)
  //oExcel:AddColumn( cWorkSheet, cTitulo, "Quantidade D3"        , 1, 1, .T.)

  dbGotop()

  While !(cAlias)->(EOF())

    oExcel:AddRow( cWorkSheet, cTitulo, ;
                    {(cAlias)->FILIAL, ;
                     (cALias)->EMISSAO, ;
                     (cAlias)->LOTE, ;
                     (cAlias)->COD, ;
                     (cAlias)->DESC, ;
                     (cALias)->OP, ;
                     (cAlias)->UM, ;
                     (cAlias)->QUANT})
                     //(cALias)->COD, ;
                     //(cAlias)->UM, ;
                     /*(cAlias)->QUANT})*/

        (cALias)->(DbSkip())
       /* FILIAL," + CRLF
    _cQry := "                D3.D3_EMISSAO                 EMISSAO," + CRLF
    _cQry := "                B1.B1_XLOTE                   LOTE_ANIMAL," + CRLF
    _cQry := "                D3.D3_COD                     CODIGO," + CRLF
    _cQry := "                B1.B1_DESC                    DESCRICAO," + CRLF
    _cQry := "                D3.D3_OP                      ORDEM_PRODUCAO," + CRLF
    _cQry := "                D3.D3_UM                      UDM," + CRLF
    _cQry := "                D3.D3_QUANT                   QUANTIDADE," + CRLF
    _cQry := "                D3I.D3_COD                    INSUMO," + CRLF
    _cQry := "                D3I.D3_UM                     UM," + CRLF*/
  EndDO
      RestArea(aArea)
RETURN











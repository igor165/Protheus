// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 005    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "PROTHEUS.CH"
#include "fileio.ch"
#include "OFIXR001.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007398_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXR001   | Autor |  Luis Delorme         | Data | 05/02/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Relatório de Produtos Pendentes                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXR001()

//+-------------------------------------------------------------------------------
//| Declaracoes de variaveis
//+-------------------------------------------------------------------------------

Local cDesc1  := STR0001         
Local cDesc2  := STR0002
Local cDesc3  := STR0003

Private cString  := "SC7"
Private Tamanho  := "M"
Private aReturn  := { STR0004,1,STR0005,2,2,1,"",1 }
Private wnrel    := "OFIXR001"
Private NomeProg := "OFIXR001"
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := STR0006
Private cPerg    := "OXR001"
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := STR0007
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   
Private Cabec2   

#IFNDEF TOP
   MsgInfo(STR0008,STR0041)
   RETURN
#ENDIF

aAdd( aOrd, STR0009 )
aAdd( aOrd, STR0010 )
aAdd( aOrd, STR0011 )
aAdd( aOrd, STR0012 )
aAdd( aOrd, STR0013 )

// "Fornecedor de" ,"C",TamSx3("C7_FORNECE")[1]
// "Loja"          ,"C",TamSx3("C7_LOJA")[1]
// "Fornecedor ate","C",TamSx3("C7_FORNECE")[1]
// "Loja"          ,"C",TamSx3("C7_LOJA")[1]
// "Armazém De"    ,"C",TamSx3("C7_LOCAL")[1]
// "Armazém Até"   ,"C",TamSx3("C7_LOCAL")[1]
Pergunte(cPerg,.F.)

//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
set printer to &wnrel
set printer on
set device to printer

wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.t.,Tamanho,,.F.)

//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
   Return
Endif

//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)

//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)

//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
   Return
Endif

//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------

RptStatus({|lEnd| RelSQLImp(@lEnd, wnrel, cString) }, STR0014, STR0015, .T. )

Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | Relatorio_SQL.prw    | AUTOR | Robson Luiz  | DATA | 18/01/2004 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - u_RelSQLImp()                                          |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Funcao de impressao                                             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function RelSQLImp(lEnd,wnrel,cString)
Local cQueryA   := ""
Local aCol      := {}
Local cArqExcel := ""
Local oExcel

//+-----------------------
//| Cria filtro temporario
//+-----------------------
cQueryA := "SELECT SB1.B1_GRUPO,SB1.B1_COD,SC7.C7_FORNECE,SC7.C7_LOJA,SC7.C7_LOCAL,SB1.B1_CODITE,SB1.B1_DESC,SA2.A2_NOME,SC7.C7_NUM,SC7.C7_EMISSAO,SC7.C7_QUANT,SC7.C7_QUJE,SC7.C7_RESIDUO,SC7.C7_PRECO, VEI_TIPPED "
cQueryA += "FROM "+RetSQLName("SB1")+" SB1 "
cQueryA += "INNER JOIN "+RetSQLName("SBM")+" SBM ON ( SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.D_E_L_E_T_=' ' ) "
cQueryA += "INNER JOIN "+RetSQLName("SC7")+" SC7 ON ( SC7.C7_FILIAL='"+xFilial("SC7")+"' AND SC7.C7_PRODUTO=SB1.B1_COD AND SC7.D_E_L_E_T_=' ' ) "
cQueryA += "INNER JOIN "+RetSQLName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SC7.C7_FORNECE AND SA2.A2_LOJA=SC7.C7_LOJA AND SA2.D_E_L_E_T_=' ' ) "
cQueryA += "LEFT JOIN "+RetSQLName("VEI")+" VEI ON ( VEI.VEI_FILIAL='"+xFilial("VEI")+"' AND VEI.VEI_CODMAR=SBM.BM_CODMAR AND VEI.VEI_NUM=SC7.C7_NUM AND VEI.D_E_L_E_T_=' ' ) "
cQueryA += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "   

if !Empty(MV_PAR01) .or. !Empty(MV_PAR03)
	cQueryA += "SC7.C7_FORNECE+SC7.C7_LOJA>='"+MV_PAR01+MV_PAR02+"' AND SC7.C7_FORNECE+SC7.C7_LOJA <= '"+MV_PAR03+MV_PAR04+"' AND "      
Endif	
   
if !Empty(MV_PAR05) .or. !Empty(MV_PAR06)
	cQueryA += "SC7.C7_LOCAL>='"+MV_PAR05+"' AND SC7.C7_LOCAL <= '"+MV_PAR06+"' AND "      
Endif	

cQueryA += "( SC7.C7_QUANT-SC7.C7_QUJE > 0 ) AND SC7.C7_RESIDUO=' ' AND "
cQueryA += "SB1.D_E_L_E_T_=' '"                                             
cQueryA += "ORDER BY VEI_TIPPED ASC, "
//+-----------------------
//| Cria indice temporario
//+-----------------------
If aReturn[8] == 1 
   cQueryA += "B1_COD ASC"
Elseif aReturn[8] == 2
   cQueryA += "C7_PRECO DESC"
Elseif aReturn[8] == 3
   cQueryA += "C7_EMISSAO ASC"
Elseif aReturn[8] == 4
   cQueryA += "C7_QUANT DESC"
Elseif aReturn[8] == 5
   cQueryA += "C7_NUM ASC"
Endif

Titulo += aOrd[aReturn[8]]

//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQueryA), "TRB", .T., .F. )

dbSelectArea("TRB")
dbGoTop()
SetRegua( RecCount() )

//+--------------------
//| Cria Planilha Excel
//+--------------------
oExcel := FWMSEXCEL():New()

oExcel:AddworkSheet(Titulo)

oExcel:AddTable (Titulo, NomeProg)

oExcel:AddColumn(Titulo, NomeProg, STR0017, 1, 1) // Tipo de Pedido
oExcel:AddColumn(Titulo, NomeProg, STR0016, 1, 1) // Código
oExcel:AddColumn(Titulo, NomeProg, STR0018, 1, 1) // Descrição 
oExcel:AddColumn(Titulo, NomeProg, STR0042, 1, 1) // Fornecedor
oExcel:AddColumn(Titulo, NomeProg, STR0043, 1, 1) // Armazém
oExcel:AddColumn(Titulo, NomeProg, STR0019, 1, 1) // Número do Pedido
oExcel:AddColumn(Titulo, NomeProg, STR0020, 1, 2) // Data Emissão
oExcel:AddColumn(Titulo, NomeProg, STR0021, 1, 3) // Quantidade
oExcel:AddColumn(Titulo, NomeProg, STR0022, 1, 3) // Preço

While !Eof()
	aCol := {}

	aAdd(aCol, TRB->VEI_TIPPED)
	aAdd(aCol, TRB->B1_COD)
	aAdd(aCol, Left(TRB->B1_DESC,40))
	aAdd(aCol, TRB->C7_FORNECE+"/"+TRB->C7_LOJA)
	aAdd(aCol, TRB->C7_LOCAL)
	aAdd(aCol, TRB->C7_NUM)
	aAdd(aCol, dtoc(stod(TRB->C7_EMISSAO)))
	aAdd(aCol, Transform(TRB->C7_QUANT,"@E 999999"))
	aAdd(aCol, Transform(TRB->C7_PRECO,"@E 999,999,999.99"))

	oExcel:AddRow(Titulo, NomeProg, aCol)

	dbSkip()
EndDo

oExcel:Activate()
cArqExcel := __RELDIR+NomeProg+Substr(cUsuario,7,4)+".XLS"
oExcel:GetXMLFile(cArqExcel)
oExcel:DeActivate()

dbSelectArea("TRB")
dbCloseArea()

//+--------------------
//| Cria Impressão
//+--------------------
If aReturn[5] == 1
   dbCommitAll()
   Set Printer TO
   Ourspool(wnrel)
EndIf

Ms_Flush()

Return

